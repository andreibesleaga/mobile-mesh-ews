-- ==============================
-- 1. Sensor acquisition data
-- ==============================
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
    )
VALUES (
        'SEN-001',
        TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 1 HOUR),
        'RO-CAMPULUNG-01',
        45.273,
        25.054,
        720,
        39.5,
        15.0,
        4.5,
        180,
        10.0,
        994.5,
        'OK'
    ),
    (
        'SEN-002',
        TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 2 HOUR),
        'RO-CAMPULUNG-01',
        45.273,
        25.054,
        720,
        41.0,
        20.0,
        5.2,
        190,
        15.0,
        992.0,
        'OK'
    ),
    (
        'SEN-003',
        TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 30 MINUTE),
        'RO-PITESTI-01',
        44.856,
        24.869,
        300,
        28.0,
        50.0,
        3.0,
        200,
        90.0,
        1002.0,
        'OK'
    ),
    (
        'SEN-004',
        TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 1 HOUR),
        'RO-PITESTI-01',
        44.856,
        24.869,
        300,
        29.5,
        55.0,
        2.5,
        210,
        85.0,
        1001.5,
        'OK'
    );
-- ==============================
-- 2. Imagery metadata table
-- (not in your pasted SQL but required by decision logic)
-- ==============================
CREATE OR REPLACE TABLE `climate_ai.imagery_metadata` (
        image_id STRING,
        location_id STRING,
        capture_time TIMESTAMP,
        gcs_uri STRING,
        fire_index FLOAT64,
        flood_index FLOAT64
    );
INSERT INTO `climate_ai.imagery_metadata`
VALUES (
        'IMG-001',
        'RO-CAMPULUNG-01',
        TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 1 HOUR),
        'gs://climate-ai-satellite-2025/campulung1.jpg',
        0.82,
        0.10
    ),
    (
        'IMG-002',
        'RO-PITESTI-01',
        TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 2 HOUR),
        'gs://climate-ai-satellite-2025/pitesti1.jpg',
        0.15,
        0.91
    );
-- ==============================
-- 3. Earth AI Images (external table placeholder)
-- ==============================
-- For testing, we’ll create a temporary managed table
-- to mimic expected structure from the EXTERNAL definition.
CREATE OR REPLACE TABLE `climate_ai.earth_images` (
        uri STRING,
        ref STRING,
        lat FLOAT64,
        lon FLOAT64,
        tstamp TIMESTAMP,
        content_type STRING
    );
INSERT INTO `climate_ai.earth_images`
VALUES (
        'gs://climate-ai-satellite-2025/campulung1.jpg',
        'IMG-001',
        45.273,
        25.054,
        TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 1 HOUR),
        'image/jpeg'
    ),
    (
        'gs://climate-ai-satellite-2025/pitesti1.jpg',
        'IMG-002',
        44.856,
        24.869,
        TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 2 HOUR),
        'image/jpeg'
    );
-- ==============================
-- 4. Earth image embeddings mock
-- ==============================
CREATE OR REPLACE TABLE `climate_ai.earth_image_embeddings` (
        uri STRING,
        ml_generate_embedding_result ARRAY < FLOAT64 >
    );
INSERT INTO `climate_ai.earth_image_embeddings`
VALUES (
        'gs://climate-ai-satellite-2025/campulung1.jpg',
        [0.1,0.2,0.3]
    ),
    (
        'gs://climate-ai-satellite-2025/pitesti1.jpg',
        [0.4,0.5,0.6]
    );
-- ==============================
-- 5. Fire signature embedding mock
-- ==============================
CREATE OR REPLACE TABLE `climate_ai.fire_signature_query_embedding` (ml_generate_embedding_result ARRAY < FLOAT64 >);
INSERT INTO `climate_ai.fire_signature_query_embedding`
VALUES ([0.15,0.25,0.35]);
-- ==============================
-- 6. Fire image candidates mock
-- ==============================
CREATE OR REPLACE TABLE `climate_ai.fire_image_candidates` (gcs_uri STRING, distance FLOAT64);
INSERT INTO `climate_ai.fire_image_candidates`
VALUES (
        'gs://climate-ai-satellite-2025/campulung1.jpg',
        0.12
    ),
    (
        'gs://climate-ai-satellite-2025/pitesti1.jpg',
        0.85
    );
-- ==============================
-- 7. Fire forecast mock (needed for emergency_routing)
-- ==============================
CREATE OR REPLACE TABLE `climate_ai.fire_forecast` (
        lat FLOAT64,
        lon FLOAT64,
        forecast_value FLOAT64
    );
INSERT INTO `climate_ai.fire_forecast`
VALUES (45.273, 25.054, 0.90),
    (44.856, 24.869, 0.65);
-- ==============================
-- 8. Emergency routing mock
-- ==============================
CREATE OR REPLACE TABLE `climate_ai.emergency_routing` AS
SELECT 'fire' AS event_type,
    lat,
    lon,
    CURRENT_TIMESTAMP() AS route_time,
    'emergency_team' AS dispatch_type,
    CONCAT(
        'AI forecast high fire risk. Temperature:',
        CAST(forecast_value AS STRING)
    ) AS rationale
FROM `climate_ai.fire_forecast`
WHERE forecast_value > 0.85;