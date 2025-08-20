-- 1. Hourly Aggregates View
CREATE OR REPLACE VIEW `your_project.your_dataset.vw_sensor_hourly` AS
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
FROM `your_project.your_dataset.sensor_data`
WHERE timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 7 DAY)
GROUP BY location_id,
    lat,
    lon,
    hour_bucket;
-- Use for: time‑series charts, anomaly detection, and AI.FORECAST inputs.
-- 2. Daily Aggregates View
CREATE OR REPLACE VIEW `your_project.your_dataset.vw_sensor_daily` AS
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
FROM `your_project.your_dataset.sensor_data`
WHERE timestamp >= DATE_SUB(CURRENT_DATE(), INTERVAL 90 DAY)
GROUP BY location_id,
    lat,
    lon,
    date;
-- Use for: seasonal trend tracking, historical pattern analysis.
-- 3. Master Join View with Imagery Risk
CREATE OR REPLACE VIEW `your_project.your_dataset.vw_climate_risk_joined` AS WITH recent_sensor AS (
        SELECT location_id,
            lat,
            lon,
            TIMESTAMP_TRUNC(timestamp, HOUR) AS hour_bucket,
            AVG(temperature) AS avg_temp,
            AVG(precipitation) AS avg_precip,
            AVG(pressure) AS avg_pressure
        FROM `your_project.your_dataset.sensor_data`
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
        FROM `your_project.your_dataset.imagery_metadata`
        WHERE capture_time >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 12 HOUR)
        GROUP BY location_id
    )
SELECT s.*,
    i.max_fire_index,
    i.max_flood_index
FROM recent_sensor s
    LEFT JOIN recent_imagery i USING (location_id);
-- Use for: feeding the decision engine we built earlier, so it always has fresh, aggregated, and joined sensor + imagery data.