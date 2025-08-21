-- ========================================
-- Climate AI: Mock Data Population Script
-- ========================================
-- CONFIG
DECLARE num_sensor_rows INT64 DEFAULT 5000;
DECLARE num_imagery_rows INT64 DEFAULT 2000;
DECLARE num_embeddings_rows INT64 DEFAULT 2000;
DECLARE num_fire_forecast_rows INT64 DEFAULT 1000;
DECLARE num_disaster_event_forecast_rows INT64 DEFAULT 200;
DECLARE num_emergency_routing_output_rows INT64 DEFAULT 100;
DECLARE num_sensor_alert_logs_rows INT64 DEFAULT 300;
-- SENSOR DATA
INSERT INTO `climate_ai.sensor_data` (
        sensor_id,
        timestamp,
        sensor_type,
        location_id,
        lat,
        lon,
        elevation_m,
        temperature,
        humidity,
        wind_speed,
        wind_dir_deg,
        precipitation,
        pressure,
        data_quality,
        value,
        source,
        image_ref
    ) WITH seq AS (
        SELECT idx AS id
        FROM UNNEST(GENERATE_ARRAY(1, num_sensor_rows)) AS idx
    )
SELECT CONCAT('SEN-', LPAD(CAST(id AS STRING), 5, '0')),
    TIMESTAMP_SUB(
        CURRENT_TIMESTAMP(),
        INTERVAL CAST(FLOOR(RAND() * 720) AS INT64) MINUTE
    ),
    CONCAT(
        'TYPE-',
        LPAD(CAST(FLOOR(RAND() * 50) + 1 AS STRING), 3, '0')
    ),
    CONCAT(
        'LOC-',
        LPAD(CAST(FLOOR(RAND() * 50) + 1 AS STRING), 3, '0')
    ),
    44.0 + RAND() * 3.0,
    23.0 + RAND() * 4.0,
    100 + RAND() * 1500,
    15 + RAND() * 25,
    10 + RAND() * 90,
    RAND() * 15,
    RAND() * 360,
    RAND() * 100,
    980 + RAND() * 40,
    IF(RAND() < 0.98, 'OK', 'CHECK'),
    15 + RAND() * 25,
    CONCAT(
        'SOURCE-',
        LPAD(CAST(FLOOR(RAND() * 50) + 1 AS STRING), 3, '0')
    ),
    CAST(NULL AS STRUCT < uri STRING, tstamp TIMESTAMP >)
FROM seq;
-- IMAGERY METADATA
INSERT INTO `climate_ai.imagery_metadata` (
        image_id,
        location_id,
        capture_time,
        gcs_uri,
        fire_index,
        flood_index
    ) WITH seq AS (
        SELECT idx AS id
        FROM UNNEST(GENERATE_ARRAY(1, num_imagery_rows)) AS idx
    )
SELECT CONCAT('IMG-', LPAD(CAST(id AS STRING), 6, '0')),
    CONCAT(
        'LOC-',
        LPAD(CAST(FLOOR(RAND() * 50) + 1 AS STRING), 3, '0')
    ),
    TIMESTAMP_SUB(
        CURRENT_TIMESTAMP(),
        INTERVAL CAST(FLOOR(RAND() * 1440) AS INT64) MINUTE
    ),
    CONCAT(
        'gs://climate-ai-bucket/images/',
        CAST(id AS STRING),
        '.jpg'
    ),
    ROUND(RAND(), 2),
    ROUND(RAND(), 2)
FROM seq;
-- EARTH IMAGES
INSERT INTO `climate_ai.earth_images` (uri, ref, tstamp, content_type) WITH seq AS (
        SELECT idx AS id
        FROM UNNEST(GENERATE_ARRAY(1, num_imagery_rows)) AS idx
    )
SELECT CONCAT(
        'gs://climate-ai-bucket/images/',
        CAST(id AS STRING),
        '.jpg'
    ),
    TO_JSON_STRING(
        STRUCT(
            44.0 + RAND() * 3.0 AS lat,
            23.0 + RAND() * 4.0 AS lon,
            CONCAT('IMG-', LPAD(CAST(id AS STRING), 6, '0')) AS image_id
        )
    ),
    TIMESTAMP_SUB(
        CURRENT_TIMESTAMP(),
        INTERVAL CAST(FLOOR(RAND() * 1440) AS INT64) MINUTE
    ),
    'image/jpeg'
FROM seq;
-- IMAGE EMBEDDINGS
INSERT INTO `climate_ai.earth_image_embeddings` (uri, ml_generate_embedding_result) WITH seq AS (
        SELECT idx AS id
        FROM UNNEST(GENERATE_ARRAY(1, num_embeddings_rows)) AS idx
    )
SELECT CONCAT(
        'gs://climate-ai-bucket/images/',
        CAST(id AS STRING),
        '.jpg'
    ),
    ARRAY(
        SELECT RAND()
        FROM UNNEST(GENERATE_ARRAY(1, 512))
    )
FROM seq;
-- FIRE SIGNATURE EMBEDDING
TRUNCATE TABLE `climate_ai.fire_signature_query_embedding`;
INSERT INTO `climate_ai.fire_signature_query_embedding` (ml_generate_embedding_result)
SELECT ARRAY(
        SELECT RAND()
        FROM UNNEST(GENERATE_ARRAY(1, 512))
    );
-- FIRE IMAGE CANDIDATES
INSERT INTO `climate_ai.fire_image_candidates` (gcs_uri, distance) WITH seq AS (
        SELECT idx AS id
        FROM UNNEST(GENERATE_ARRAY(1, num_imagery_rows)) AS idx
    )
SELECT CONCAT(
        'gs://climate-ai-bucket/images/',
        CAST(id AS STRING),
        '.jpg'
    ),
    RAND()
FROM seq;
-- FIRE FORECAST
INSERT INTO `climate_ai.fire_forecast` (lat, lon, forecast_value) WITH seq AS (
        SELECT idx AS id
        FROM UNNEST(GENERATE_ARRAY(1, num_fire_forecast_rows)) AS idx
    )
SELECT 44.0 + RAND() * 3.0,
    23.0 + RAND() * 4.0,
    RAND()
FROM seq;
-- EMERGENCY ROUTING
INSERT INTO `climate_ai.emergency_routing` (
        event_type,
        lat,
        lon,
        route_time,
        dispatch_type,
        rationale
    )
SELECT 'fire',
    lat,
    lon,
    CURRENT_TIMESTAMP(),
    'emergency_team',
    CONCAT(
        'AI forecast fire risk ',
        CAST(forecast_value AS STRING)
    )
FROM `climate_ai.fire_forecast`
WHERE forecast_value > 0.85;
-- DISASTER EVENT FORECAST
INSERT INTO `climate_ai.disaster_event_forecast` (
        event_type,
        lat,
        lon,
        forecast_time,
        forecast_value,
        confidence,
        ai_status,
        action_required
    ) WITH event_types AS (
        SELECT et AS event_type
        FROM UNNEST(['fire', 'flood']) AS et
    ),
    seq AS (
        SELECT idx AS id
        FROM UNNEST(
                GENERATE_ARRAY(1, num_disaster_event_forecast_rows)
            ) AS idx
    )
SELECT e.event_type,
    44.0 + RAND() * 3.0,
    23.0 + RAND() * 4.0,
    TIMESTAMP_ADD(
        CURRENT_TIMESTAMP(),
        INTERVAL CAST(RAND() * 72 AS INT64) HOUR
    ),
    ROUND(RAND(), 2),
    ROUND(0.7 + RAND() * 0.3, 2),
    IF(RAND() < 0.95, 'Success', 'Error'),
    RAND() > 0.5
FROM event_types e
    CROSS JOIN seq;
-- EMERGENCY ROUTING OUTPUT
INSERT INTO `climate_ai.emergency_routing_output` (
        event_type,
        lat,
        lon,
        route_time,
        dispatch_type,
        rationale
    ) WITH event_types AS (
        SELECT et AS event_type
        FROM UNNEST(['fire', 'flood']) AS et
    ),
    dispatch_types AS (
        SELECT dt AS dispatch_type
        FROM UNNEST(['emergency_team', 'sensor_mobile']) AS dt
    ),
    seq AS (
        SELECT idx AS id
        FROM UNNEST(
                GENERATE_ARRAY(1, num_emergency_routing_output_rows)
            ) AS idx
    )
SELECT e.event_type,
    44.0 + RAND() * 3.0,
    23.0 + RAND() * 4.0,
    TIMESTAMP_SUB(
        CURRENT_TIMESTAMP(),
        INTERVAL CAST(RAND() * 1440 AS INT64) MINUTE
    ),
    d.dispatch_type,
    CONCAT(
        "Routing ",
        d.dispatch_type,
        " to handle ",
        e.event_type,
        " risk at coordinates (",
        CAST(ROUND(44.0 + RAND() * 3.0, 3) AS STRING),
        ", ",
        CAST(ROUND(23.0 + RAND() * 4.0, 3) AS STRING),
        ")"
    )
FROM event_types e
    CROSS JOIN dispatch_types d
    CROSS JOIN seq;
-- SENSOR ALERT LOGS
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
    ) WITH seq AS (
        SELECT idx AS id
        FROM UNNEST(GENERATE_ARRAY(1, num_sensor_alert_logs_rows)) AS idx
    )
SELECT CONCAT(
        'LOC-',
        LPAD(CAST(FLOOR(RAND() * 50) + 1 AS STRING), 3, '0')
    ),
    44.0 + RAND() * 3.