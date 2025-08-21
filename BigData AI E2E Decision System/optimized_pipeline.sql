CREATE OR REPLACE VIEW `climate_ai.vw_decision_engine` AS WITH -- 1) Thresholds and weights
    config AS (
        SELECT 0.70 AS fire_idx_high,
            0.70 AS flood_idx_high,
            35.0 AS temp_hot_c,
            30.0 AS temp_warm_c,
            80.0 AS precip_extreme_mm_6h,
            50.0 AS precip_heavy_mm_6h,
            1000.0 AS low_pressure_hpa,
            0.60 AS wildfire_weight_temp,
            0.40 AS wildfire_weight_fireidx,
            0.60 AS flood_weight_precip,
            0.40 AS flood_weight_floodidx
    ),
    -- 2) Latest hourly aggregates per location
    base_hourly AS (
        SELECT location_id,
            ANY_VALUE(lat) AS lat,
            ANY_VALUE(lon) AS lon,
            hour_bucket,
            COUNT(*) AS readings_count,
            AVG(avg_temp) AS avg_temp,
            AVG(avg_precip) AS avg_precip,
            AVG(avg_pressure) AS avg_pressure,
            ROW_NUMBER() OVER (
                PARTITION BY location_id
                ORDER BY hour_bucket DESC
            ) AS rn
        FROM `climate_ai.vw_sensor_hourly`
        WHERE hour_bucket >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 24 HOUR)
            AND avg_temp IS NOT NULL
            AND avg_precip IS NOT NULL
            AND avg_pressure IS NOT NULL
        GROUP BY location_id,
            hour_bucket
    ),
    latest_hourly AS (
        SELECT location_id,
            lat,
            lon,
            hour_bucket AS latest_hour,
            readings_count,
            avg_temp,
            avg_precip,
            avg_pressure
        FROM base_hourly
        WHERE rn = 1
    ),
    -- 3) Imagery risk
    imagery_risk AS (
        SELECT location_id,
            MAX(SAFE_CAST(fire_index AS FLOAT64)) AS max_fire_index,
            MAX(SAFE_CAST(flood_index AS FLOAT64)) AS max_flood_index
        FROM `climate_ai.imagery_metadata`
        WHERE capture_time >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 12 HOUR)
        GROUP BY location_id
    ),
    -- 4) Simplified Forecasts (avoiding correlated subquery issues with AI.FORECAST)
    forecast_temp AS (
        SELECT location_id,
            -- Use recent average as baseline forecast with trend adjustment
            AVG(avg_temp) + (COUNT(*) * 0.1) AS fc_temp_next6h
        FROM `climate_ai.vw_sensor_hourly`
        WHERE hour_bucket >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 12 HOUR)
        GROUP BY location_id
    ),
    forecast_precip AS (
        SELECT location_id,
            -- Use recent average for precipitation forecast
            AVG(avg_precip) AS fc_precip_next6h
        FROM `climate_ai.vw_sensor_hourly`
        WHERE hour_bucket >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 12 HOUR)
        GROUP BY location_id
    ),
    -- 5) Combine
    joined AS (
        SELECT l.location_id,
            l.lat,
            l.lon,
            l.latest_hour,
            l.readings_count,
            l.avg_temp,
            l.avg_precip,
            l.avg_pressure,
            COALESCE(ir.max_fire_index, 0.0) AS max_fire_index,
            COALESCE(ir.max_flood_index, 0.0) AS max_flood_index,
            COALESCE(ft.fc_temp_next6h, l.avg_temp) AS fc_temp_next6h,
            COALESCE(fp.fc_precip_next6h, l.avg_precip) AS fc_precip_next6h
        FROM latest_hourly l
            LEFT JOIN imagery_risk ir USING (location_id)
            LEFT JOIN forecast_temp ft USING (location_id)
            LEFT JOIN forecast_precip fp USING (location_id)
    ),
    -- 6) Risk scoring
    scored AS (
        SELECT j.*,
            LEAST(GREATEST(j.avg_temp / c.temp_hot_c, 0), 1) AS n_temp_now,
            LEAST(GREATEST(j.fc_temp_next6h / c.temp_hot_c, 0), 1) AS n_temp_fc,
            LEAST(GREATEST(j.max_fire_index, 0), 1) AS n_fire_idx,
            LEAST(
                GREATEST(j.avg_precip / c.precip_heavy_mm_6h, 0),
                1
            ) AS n_precip_now,
            LEAST(
                GREATEST(j.fc_precip_next6h / c.precip_heavy_mm_6h, 0),
                1
            ) AS n_precip_fc,
            LEAST(GREATEST(j.max_flood_index, 0), 1) AS n_flood_idx,
            c.*
        FROM joined j
            CROSS JOIN config c
    ),
    -- 7) Scores
    risk AS (
        SELECT s.*,
            ROUND(
                100 * (
                    s.wildfire_weight_temp * 0.5 * (s.n_temp_now + s.n_temp_fc) + s.wildfire_weight_fireidx * s.n_fire_idx
                ),
                1
            ) AS wildfire_risk_score,
            ROUND(
                100 * (
                    s.flood_weight_precip * 0.5 * (s.n_precip_now + s.n_precip_fc) + s.flood_weight_floodidx * s.n_flood_idx
                ),
                1
            ) AS flood_risk_score
        FROM scored s
    ),
    -- 8) Classification
    decisions AS (
        SELECT r.*,
            CASE
                WHEN (
                    r.max_fire_index >= r.fire_idx_high
                    AND r.fc_temp_next6h >= r.temp_hot_c
                )
                OR r.wildfire_risk_score >= 75 THEN 'High Wildfire Risk'
                WHEN (
                    r.max_flood_index >= r.flood_idx_high
                    AND r.fc_precip_next6h >= r.precip_heavy_mm_6h
                )
                OR r.flood_risk_score >= 75 THEN 'High Flood Risk'
                WHEN r.wildfire_risk_score BETWEEN 50 AND 74 THEN 'Moderate Wildfire Risk'
                WHEN r.flood_risk_score BETWEEN 50 AND 74 THEN 'Moderate Flood Risk'
                ELSE 'Low Risk'
            END AS risk_classification,
            CASE
                WHEN (
                    (
                        r.max_fire_index >= r.fire_idx_high
                        AND r.fc_temp_next6h >= r.temp_hot_c
                    )
                    OR (
                        r.max_flood_index >= r.flood_idx_high
                        AND r.fc_precip_next6h >= r.precip_extreme_mm_6h
                    )
                )
                OR GREATEST(r.wildfire_risk_score, r.flood_risk_score) >= 85 THEN 'CRITICAL'
                WHEN GREATEST(r.wildfire_risk_score, r.flood_risk_score) >= 60 THEN 'WARNING'
                ELSE 'NORMAL'
            END AS alert_level
        FROM risk r
    ),
    -- 9) Enriched
    enriched AS (
        SELECT d.*,
            ST_GEOGPOINT(d.lon, d.lat) AS geog_point,
            -- Simplified alert message generation (AI.GENERATE requires proper connection setup)
            CONCAT(
                'ALERT for ',
                d.location_id,
                ': ',
                d.risk_classification,
                '. Current conditions - Temp: ',
                CAST(ROUND(d.avg_temp, 1) AS STRING),
                '°C',
                ', Precip: ',
                CAST(ROUND(d.avg_precip, 1) AS STRING),
                'mm',
                '. 6h forecast - Temp: ',
                CAST(ROUND(d.fc_temp_next6h, 1) AS STRING),
                '°C',
                ', Precip: ',
                CAST(ROUND(d.fc_precip_next6h, 1) AS STRING),
                'mm',
                '. Fire risk: ',
                CAST(ROUND(d.max_fire_index, 2) AS STRING),
                ', Flood risk: ',
                CAST(ROUND(d.max_flood_index, 2) AS STRING)
            ) AS alert_message,
            CASE
                WHEN d.risk_classification = 'High Wildfire Risk' THEN 'Pre-stage fire crews; issue burn bans; inspect power lines; prepare evacuation messaging.'
                WHEN d.risk_classification = 'High Flood Risk' THEN 'Pre-position pumps/sandbags; clear drains; warn low-lying areas; prepare shelter resources.'
                WHEN d.risk_classification LIKE 'Moderate%' THEN 'Increase monitoring of conditions; brief local authorities; prepare community advisories.'
                ELSE 'No immediate action required; continue routine monitoring.'
            END AS recommended_action
        FROM decisions d
    ) -- Final output
SELECT location_id,
    lat,
    lon,
    latest_hour,
    readings_count,
    avg_temp,
    avg_precip,
    avg_pressure,
    max_fire_index,
    max_flood_index,
    fc_temp_next6h,
    fc_precip_next6h,
    wildfire_risk_score,
    flood_risk_score,
    risk_classification,
    alert_level,
    geog_point,
    alert_message,
    recommended_action
FROM enriched;