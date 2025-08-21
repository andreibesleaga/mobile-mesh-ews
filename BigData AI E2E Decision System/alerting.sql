-- ========================================
-- Climate AI: Alerting Pipeline + QA Checks
-- ========================================
-- Insert new alerts into logs
INSERT INTO `climate_ai.sensor_alert_logs` (
        location_id,
        lat,
        lon,
        avg_temp,
        avg_precip,
        avg_pressure,
        temp_forecast,
        max_fire_index,
        max_flood_index,
        risk_classification,
        alert_level,
        alert_message,
        log_timestamp
    ) WITH recent_sensor AS (
        SELECT location_id,
            lat,
            lon,
            AVG(temperature) AS avg_temp,
            AVG(precipitation) AS avg_precip,
            AVG(pressure) AS avg_pressure
        FROM `climate_ai.sensor_data`
        WHERE timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 6 HOUR)
        GROUP BY location_id,
            lat,
            lon
    ),
    -- Simplified forecast to avoid correlated subquery issues with AI.FORECAST
    raw_temp_forecast AS (
        SELECT location_id,
            -- Use recent average as baseline forecast with trend adjustment
            AVG(temperature) + (COUNT(*) * 0.1) AS predicted_value
        FROM `climate_ai.sensor_data`
        WHERE timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 12 HOUR)
        GROUP BY location_id
        HAVING COUNT(*) > 5 -- Ensure sufficient data
    ),
    forecasted_risk AS (
        SELECT location_id,
            AVG(predicted_value) AS temp_forecast
        FROM raw_temp_forecast
        GROUP BY location_id
    ),
    imagery_risk AS (
        SELECT location_id,
            MAX(fire_index) AS max_fire_index,
            MAX(flood_index) AS max_flood_index
        FROM `climate_ai.imagery_metadata`
        WHERE capture_time >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 12 HOUR)
        GROUP BY location_id
    ),
    decision_engine AS (
        SELECT s.location_id,
            s.lat,
            s.lon,
            s.avg_temp,
            s.avg_precip,
            s.avg_pressure,
            f.temp_forecast,
            i.max_fire_index,
            i.max_flood_index,
            CASE
                WHEN IFNULL(i.max_fire_index, 0) > 0.7
                AND s.avg_temp > 35 THEN 'High Wildfire Risk'
                WHEN IFNULL(i.max_flood_index, 0) > 0.7
                AND s.avg_precip > 80 THEN 'High Flood Risk'
                WHEN s.avg_temp > 30
                AND s.avg_pressure < 1000 THEN 'Moderate Wildfire Risk'
                WHEN s.avg_precip > 50 THEN 'Moderate Flood Risk'
                ELSE 'Low Risk'
            END AS risk_classification,
            CASE
                WHEN IFNULL(i.max_fire_index, 0) > 0.7
                AND s.avg_temp > 35 THEN 'CRITICAL'
                WHEN IFNULL(i.max_flood_index, 0) > 0.7
                AND s.avg_precip > 80 THEN 'CRITICAL'
                WHEN s.avg_temp > 30
                OR s.avg_precip > 50 THEN 'WARNING'
                ELSE 'NORMAL'
            END AS alert_level
        FROM recent_sensor s
            LEFT JOIN forecasted_risk f USING (location_id)
            LEFT JOIN imagery_risk i USING (location_id)
    )
SELECT location_id,
    lat,
    lon,
    avg_temp,
    avg_precip,
    avg_pressure,
    temp_forecast,
    max_fire_index,
    max_flood_index,
    risk_classification,
    alert_level,
    CONCAT(
        'ALERT: ',
        risk_classification,
        ' detected at ',
        location_id,
        '. Temperature: ',
        CAST(IFNULL(avg_temp, -999) AS STRING),
        '°C',
        ', Precipitation: ',
        CAST(IFNULL(avg_precip, -999) AS STRING),
        'mm',
        ', Fire risk: ',
        CAST(IFNULL(max_fire_index, -1) AS STRING),
        ', Flood risk: ',
        CAST(IFNULL(max_flood_index, -1) AS STRING),
        '. Immediate attention required.'
    ) AS alert_message,
    CURRENT_TIMESTAMP() AS log_timestamp
FROM decision_engine
ORDER BY CASE
        WHEN alert_level = 'CRITICAL' THEN 1
        WHEN alert_level = 'WARNING' THEN 2
        ELSE 3
    END;
-- ============================
-- QA / Guardrail Checks
-- ============================
-- Count of new alerts by severity
SELECT alert_level,
    COUNT(*) AS alerts_created
FROM `climate_ai.sensor_alert_logs`
WHERE log_timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 5 MINUTE)
GROUP BY alert_level;
-- Check for out-of-range averages
SELECT *
FROM `climate_ai.sensor_alert_logs`
WHERE (
        avg_temp < -90
        OR avg_temp > 60
    )
    OR (
        max_fire_index < 0
        OR max_fire_index > 1
    )
    OR (
        max_flood_index < 0
        OR max_flood_index > 1
    )
ORDER BY log_timestamp DESC;
-- Look for missing forecast values
SELECT *
FROM `climate_ai.sensor_alert_logs`
WHERE temp_forecast IS NULL
ORDER BY log_timestamp DESC
LIMIT 10;