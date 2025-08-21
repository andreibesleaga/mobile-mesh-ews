-- =========================================
-- Climate AI - Fixed Schema & Pipeline DDL
-- =========================================
-- 1. Sensor acquisition data
CREATE OR REPLACE TABLE `climate_ai.sensor_data` (
        sensor_id STRING NOT NULL,
        timestamp TIMESTAMP NOT NULL,
        sensor_type STRING NOT NULL,
        location_id STRING NOT NULL,
        lat FLOAT64 NOT NULL,
        lon FLOAT64 NOT NULL,
        elevation_m FLOAT64,
        temperature FLOAT64,
        humidity FLOAT64,
        wind_speed FLOAT64,
        wind_dir_deg FLOAT64,
        precipitation FLOAT64,
        pressure FLOAT64,
        data_quality STRING,
        value FLOAT64,
        source STRING,
        image_ref STRUCT < uri STRING,
        tstamp TIMESTAMP >,
        ingestion_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
    ) PARTITION BY DATE(timestamp) CLUSTER BY location_id,
    sensor_id;
-- 2. Simulated Earth Images
CREATE OR REPLACE TABLE `climate_ai.earth_images` (
        uri STRING,
        ref STRING,
        tstamp TIMESTAMP,
        content_type STRING
    );
-- 3. Imagery view
CREATE OR REPLACE VIEW `climate_ai.imagery_objects` AS
SELECT uri,
    ref,
    SAFE_CAST(JSON_VALUE(ref, '$.lat') AS FLOAT64) AS lat,
    SAFE_CAST(JSON_VALUE(ref, '$.lon') AS FLOAT64) AS lon,
    tstamp
FROM `climate_ai.earth_images`;
-- 4. Imagery Metadata
CREATE OR REPLACE TABLE `climate_ai.imagery_metadata` (
        image_id STRING,
        location_id STRING,
        capture_time TIMESTAMP,
        gcs_uri STRING,
        fire_index FLOAT64,
        flood_index FLOAT64
    );
-- 5. Sensor data enriched with nearest satellite image
CREATE OR REPLACE TABLE `climate_ai.sensor_data_with_images` AS
SELECT s.*,
    img.uri AS image_uri,
    img.ref AS image_ref_json -- renamed to avoid clash with struct
FROM `climate_ai.sensor_data` s
    LEFT JOIN `climate_ai.imagery_objects` img ON ABS(s.lat - img.lat) < 0.01
    AND ABS(s.lon - img.lon) < 0.01
    AND TIMESTAMP_DIFF(s.timestamp, img.tstamp, MINUTE) BETWEEN -10 AND 10;
-- 6. Simulated embedding model output table (no model required yet)
CREATE OR REPLACE TABLE `climate_ai.multimodal_embedding_model` (
        input STRING,
        ml_generate_embedding_result ARRAY < FLOAT64 >
    );
-- =========================================================
-- ORIGINAL ML.GENERATE_EMBEDDING (commented until model exists)
-- ---------------------------------------------------------
-- CREATE OR REPLACE MODEL `climate_ai.multimodal_embedding_model`
-- OPTIONS(
--   MODEL_TYPE = 'EMBEDDING',
--   REMOTE_MODEL = 'vertexai.multimodalembedding',
--   ENDPOINT = 'multimodalembedding@001'
-- ) AS
-- SELECT
--   uri AS image_uri,
--   ref AS metadata_json
-- FROM `climate_ai.earth_images`;
-- =========================================================
-- 7. Earth image embeddings (stub array, matching shape)
CREATE OR REPLACE TABLE `climate_ai.earth_image_embeddings` AS
SELECT uri,
    ARRAY(
        SELECT 0.0
        FROM UNNEST(GENERATE_ARRAY(1, 512))
    ) AS ml_generate_embedding_result
FROM `climate_ai.earth_images`
WHERE content_type = 'image/jpeg';
-- 8. Fire signature query embedding (stub)
CREATE OR REPLACE TABLE `climate_ai.fire_signature_query_embedding` AS
SELECT "visible wildfire signature: plume, heat, smoke" AS content,
    ARRAY(
        SELECT 0.0
        FROM UNNEST(GENERATE_ARRAY(1, 512))
    ) AS ml_generate_embedding_result;
-- 9. Fire image candidates (stub, no VECTOR_SEARCH until model is ready)
CREATE OR REPLACE TABLE `climate_ai.fire_image_candidates` AS
SELECT uri AS gcs_uri,
    RAND() AS distance
FROM `climate_ai.earth_images`
WHERE content_type = 'image/jpeg'
LIMIT 5;
-- 10. Fire forecast
CREATE OR REPLACE TABLE `climate_ai.fire_forecast` (
        lat FLOAT64,
        lon FLOAT64,
        forecast_value FLOAT64
    );
-- 11. Emergency routing (fires)
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
-- 12. Disaster event forecast
CREATE OR REPLACE TABLE `climate_ai.disaster_event_forecast` (
        event_type STRING NOT NULL,
        lat FLOAT64 NOT NULL,
        lon FLOAT64 NOT NULL,
        forecast_time TIMESTAMP NOT NULL,
        forecast_value FLOAT64,
        confidence FLOAT64,
        ai_status STRING,
        action_required BOOL
    ) PARTITION BY DATE(forecast_time) CLUSTER BY event_type;
-- 13. Emergency routing output
CREATE OR REPLACE TABLE `climate_ai.emergency_routing_output` (
        event_type STRING NOT NULL,
        lat FLOAT64 NOT NULL,
        lon FLOAT64 NOT NULL,
        route_time TIMESTAMP NOT NULL,
        dispatch_type STRING NOT NULL,
        rationale STRING
    ) PARTITION BY DATE(route_time) CLUSTER BY event_type,
    dispatch_type;
-- 14. Sensor alert logs
CREATE OR REPLACE TABLE `climate_ai.sensor_alert_logs` (
        location_id STRING NOT NULL,
        lat FLOAT64 NOT NULL,
        lon FLOAT64 NOT NULL,
        avg_temp FLOAT64,
        avg_precip FLOAT64,
        avg_pressure FLOAT64,
        temp_forecast FLOAT64,
        max_fire_index FLOAT64,
        max_flood_index FLOAT64,
        risk_classification STRING,
        alert_level STRING,
        alert_message STRING,
        log_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
    ) PARTITION BY DATE(log_timestamp) CLUSTER BY alert_level,
    location_id;
-- Disaster event forecast
CREATE OR REPLACE TABLE `climate_ai.disaster_event_forecast` (
        event_type STRING NOT NULL,
        lat FLOAT64 NOT NULL,
        lon FLOAT64 NOT NULL,
        forecast_time TIMESTAMP NOT NULL,
        forecast_value FLOAT64,
        confidence FLOAT64,
        ai_status STRING,
        action_required BOOL
    ) PARTITION BY DATE(forecast_time) CLUSTER BY event_type;