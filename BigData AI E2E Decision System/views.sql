-- ========================================
-- Climate AI: Unified View Creation Script
-- (with smoke tests & sanity guardrails)
-- ========================================
-- 1. Hourly Aggregates View
CREATE OR REPLACE VIEW `climate_ai.vw_sensor_hourly` AS
SELECT location_id,
    lat,
    lon,
    TIMESTAMP_TRUNC(timestamp, HOUR) AS hour_bucket,
    COUNT(*) AS readings_count,
    AVG(temperature) AS avg_temp,
    AVG(precipitation) AS avg_precip,
    AVG(pressure) AS avg_pressure,
    AVG(humidity) AS avg_humidity,
    AVG(wind_speed) AS avg_wind_speed
FROM `climate_ai.sensor_data`
WHERE timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 7 DAY)
GROUP BY location_id,
    lat,
    lon,
    hour_bucket;
-- 2. Daily Aggregates View
CREATE OR REPLACE VIEW `climate_ai.vw_sensor_daily` AS
SELECT location_id,
    lat,
    lon,
    DATE(timestamp) AS date,
    COUNT(*) AS readings_count,
    AVG(temperature) AS avg_temp,
    MAX(temperature) AS max_temp,
    MIN(temperature) AS min_temp,
    AVG(precipitation) AS avg_precip,
    SUM(precipitation) AS total_precip,
    AVG(pressure) AS avg_pressure
FROM `climate_ai.sensor_data`
WHERE timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 90 DAY)
GROUP BY location_id,
    lat,
    lon,
    date;
-- 3. Master Join View with Imagery Risk
CREATE OR REPLACE VIEW `climate_ai.vw_climate_risk_joined` AS WITH recent_sensor AS (
        SELECT location_id,
            lat,
            lon,
            TIMESTAMP_TRUNC(timestamp, HOUR) AS hour_bucket,
            AVG(temperature) AS avg_temp,
            AVG(precipitation) AS avg_precip,
            AVG(pressure) AS avg_pressure
        FROM `climate_ai.sensor_data`
        WHERE timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 6 HOUR)
        GROUP BY location_id,
            lat,
            lon,
            hour_bucket
    ),
    recent_imagery AS (
        SELECT location_id,
            MAX(fire_index) AS max_fire_index,
            MAX(flood_index) AS max_flood_index
        FROM `climate_ai.imagery_metadata`
        WHERE capture_time >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 12 HOUR)
        GROUP BY location_id
    )
SELECT s.location_id,
    s.lat,
    s.lon,
    s.hour_bucket,
    s.avg_temp,
    s.avg_precip,
    s.avg_pressure,
    i.max_fire_index,
    i.max_flood_index
FROM recent_sensor s
    LEFT JOIN recent_imagery i USING (location_id);
-- 4. Disaster Event Forecast Decision View
CREATE OR REPLACE VIEW `climate_ai.event_decision_view` AS WITH radius_rules AS (
        SELECT 'flood' AS event_type,
            1000 AS match_radius_m
        UNION ALL
        SELECT 'fire',
            300
    ),
    forecasts AS (
        SELECT f.event_type,
            ST_GEOGPOINT(f.lon, f.lat) AS event_point,
            TIMESTAMP_TRUNC(f.forecast_time, HOUR) AS event_hour,
            f.forecast_value,
            f.confidence,
            f.ai_status,
            f.action_required,
            rr.match_radius_m
        FROM `climate_ai.disaster_event_forecast` f
            JOIN radius_rules rr ON f.event_type = rr.event_type
        WHERE f.forecast_value >= 0.7
            AND f.confidence >= 0.8
    ),
    routes AS (
        SELECT event_type,
            ST_GEOGPOINT(lon, lat) AS route_point,
            TIMESTAMP_TRUNC(route_time, HOUR) AS event_hour,
            dispatch_type,
            rationale
        FROM `climate_ai.emergency_routing_output`
    ),
    imagery AS (
        -- Use the parsed lat/lon from the view to form points
        SELECT uri,
            CAST(ref AS STRING) AS ref_str,
            ST_GEOGPOINT(lon, lat) AS image_point,
            TIMESTAMP_TRUNC(tstamp, HOUR) AS event_hour
        FROM `climate_ai.imagery_objects`
    )
SELECT f.event_type,
    ST_Y(f.event_point) AS lat,
    ST_X(f.event_point) AS lon,
    f.event_hour,
    f.forecast_value,
    f.confidence,
    f.ai_status,
    f.action_required,
    r.dispatch_type,
    r.rationale,
    i.uri AS image_uri,
    i.ref_str AS image_metadata
FROM forecasts f
    LEFT JOIN routes r ON f.event_type = r.event_type
    AND f.event_hour = r.event_hour
    AND ST_DWITHIN(f.event_point, r.route_point, f.match_radius_m)
    LEFT JOIN imagery i ON ST_DWITHIN(f.event_point, i.image_point, f.match_radius_m)
    AND f.event_hour = i.event_hour;
-- ============================
-- Smoke Tests: counts
-- ============================
SELECT 'vw_sensor_hourly' AS view_name,
    COUNT(*) AS row_count
FROM `climate_ai.vw_sensor_hourly`
UNION ALL
SELECT 'vw_sensor_daily',
    COUNT(*)
FROM `climate_ai.vw_sensor_daily`
UNION ALL
SELECT 'vw_climate_risk_joined',
    COUNT(*)
FROM `climate_ai.vw_climate_risk_joined`
UNION ALL
SELECT 'event_decision_view',
    COUNT(*)
FROM `climate_ai.event_decision_view`;
-- ============================
-- Sanity Guardrails
-- ============================
-- Check plausible temperature range
SELECT *
FROM `climate_ai.vw_sensor_hourly`
WHERE avg_temp < -90
    OR avg_temp > 60;
-- Check fire/flood index range in joined view
SELECT *
FROM `climate_ai.vw_climate_risk_joined`
WHERE max_fire_index < 0
    OR max_fire_index > 1
    OR max_flood_index < 0
    OR max_flood_index > 1;
-- Check forecast probability & confidence bounds
SELECT *
FROM `climate_ai.event_decision_view`
WHERE forecast_value < 0
    OR forecast_value > 1
    OR confidence < 0
    OR confidence > 1;
-- ============================
-- Quick Previews
-- ============================
SELECT *
FROM `climate_ai.vw_sensor_hourly`
LIMIT 5;
SELECT *
FROM `climate_ai.vw_sensor_daily`
LIMIT 5;
SELECT *
FROM `climate_ai.vw_climate_risk_joined`
LIMIT 5;
SELECT *
FROM `climate_ai.event_decision_view`
LIMIT 5;