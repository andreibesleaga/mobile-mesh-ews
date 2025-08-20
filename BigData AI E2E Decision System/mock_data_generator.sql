-- CONFIG: Set scale for each table
DECLARE num_sensor_rows INT64 DEFAULT 5000;
DECLARE num_imagery_rows INT64 DEFAULT 2000;
DECLARE num_embeddings_rows INT64 DEFAULT 2000;
DECLARE num_fire_forecast_rows INT64 DEFAULT 1000;
-- SENSOR DATA
INSERT INTO `climate_ai.sensor_data` (
        sensor_id,
        timestamp,
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
        data_quality
    ) WITH seq AS (
        SELECT x AS id
        FROM UNNEST(GENERATE_ARRAY(1, num_sensor_rows)) AS x
    )
SELECT CONCAT('SEN-', LPAD(CAST(id AS STRING), 5, '0')),
    TIMESTAMP_SUB(
        CURRENT_TIMESTAMP(),
        INTERVAL CAST(FLOOR(RAND() * 720) AS INT64) MINUTE
    ),
    CONCAT(
        'LOC-',
        LPAD(CAST(FLOOR(RAND() * 50) + 1 AS STRING), 3, '0')
    ),
    44.0 + RAND() * 3.0,
    -- lat ~ Romania area
    23.0 + RAND() * 4.0,
    -- lon ~ Romania area
    100 + RAND() * 1500,
    15 + RAND() * 25,
    -- temperature
    10 + RAND() * 90,
    -- humidity
    RAND() * 15,
    -- wind speed
    RAND() * 360,
    -- wind dir
    RAND() * 100,
    -- precipitation
    980 + RAND() * 40,
    -- pressure
    IF(RAND() < 0.98, 'OK', 'CHECK')
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
        SELECT x AS id
        FROM UNNEST(GENERATE_ARRAY(1, num_imagery_rows))
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
    RAND(),
    RAND()
FROM seq;
-- EARTH IMAGES
INSERT INTO `climate_ai.earth_images` (uri, ref, lat, lon, tstamp, content_type) WITH seq AS (
        SELECT x AS id
        FROM UNNEST(GENERATE_ARRAY(1, num_imagery_rows))
    )
SELECT CONCAT(
        'gs://climate-ai-bucket/images/',
        CAST(id AS STRING),
        '.jpg'
    ),
    CONCAT('IMG-', LPAD(CAST(id AS STRING), 6, '0')),
    44.0 + RAND() * 3.0,
    23.0 + RAND() * 4.0,
    TIMESTAMP_SUB(
        CURRENT_TIMESTAMP(),
        INTERVAL CAST(FLOOR(RAND() * 1440) AS INT64) MINUTE
    ),
    'image/jpeg'
FROM seq;
-- IMAGE EMBEDDINGS
INSERT INTO `climate_ai.earth_image_embeddings` (uri, ml_generate_embedding_result) WITH seq AS (
        SELECT x AS id
        FROM UNNEST(GENERATE_ARRAY(1, num_embeddings_rows))
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
-- FIRE SIGNATURE EMBEDDING (single reference vector)
TRUNCATE TABLE `climate_ai.fire_signature_query_embedding`;
INSERT INTO `climate_ai.fire_signature_query_embedding` (ml_generate_embedding_result)
SELECT ARRAY(
        SELECT RAND()
        FROM UNNEST(GENERATE_ARRAY(1, 512))
    );
-- FIRE IMAGE CANDIDATES
INSERT INTO `climate_ai.fire_image_candidates` (gcs_uri, distance)
SELECT CONCAT(
        'gs://climate-ai-bucket/images/',
        CAST(id AS STRING),
        '.jpg'
    ),
    RAND()
FROM UNNEST(GENERATE_ARRAY(1, num_imagery_rows)) AS id;
-- FIRE FORECAST
INSERT INTO `climate_ai.fire_forecast` (lat, lon, forecast_value) WITH seq AS (
        SELECT x AS id
        FROM UNNEST(GENERATE_ARRAY(1, num_fire_forecast_rows))
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