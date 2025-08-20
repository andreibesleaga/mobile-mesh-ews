-- This file contains SQL commands for creating and managing tables and models in the climate AI project.
-- Sensor acquisition data (extended version proposal of which only some fields are used in queries)
CREATE TABLE `climate_ai.sensor_data` (
    sensor_id STRING NOT NULL,
    -- Unique sensor hardware identifier
    timestamp TIMESTAMP NOT NULL,
    location_id STRING NOT NULL,
    lat FLOAT64 NOT NULL,
    lon FLOAT64 NOT NULL,
    elevation_m FLOAT64,
    -- Elevation in meters
    temperature FLOAT64,
    humidity FLOAT64,
    -- Relative humidity %
    wind_speed FLOAT64,
    -- m/s
    wind_dir_deg FLOAT64,
    -- Wind direction degrees
    precipitation FLOAT64,
    pressure FLOAT64,
    data_quality STRING,
    -- Flags: 'OK', 'ESTIMATED', 'MISSING'
    ingestion_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP() -- When loaded into table
) PARTITION BY DATE(timestamp) CLUSTER BY location_id,
sensor_id;
-- Earth AI Images
CREATE OR REPLACE EXTERNAL TABLE climate_ai.earth_images WITH CONNECTION DEFAULT OPTIONS (
        object_metadata = 'SIMPLE',
        uris = ['gs://climate-ai-satellite-2025/*']
    );
-- Enrich sensor table with nearest satellite image reference
CREATE OR REPLACE TABLE climate_ai.sensor_data_with_images AS
SELECT s.*,
    img.uri AS image_uri,
    img.ref AS image_ref
FROM climate_ai.sensor_data s
    LEFT JOIN climate_ai.earth_images img ON ABS(s.lat - img.lat) < 0.01
    AND ABS(s.lon - img.lon) < 0.01
    AND TIMESTAMP_DIFF(s.timestamp, img.tstamp, MINUTE) BETWEEN -10 AND 10 -- Generate Embeddings for Images
CREATE OR REPLACE MODEL `climate_ai.multimodal_embedding_model` REMOTE WITH CONNECTION DEFAULT OPTIONS (ENDPOINT = 'multimodalembedding@001');
-- Earth Image Embeddings
CREATE OR REPLACE TABLE `climate_ai.earth_image_embeddings` AS
SELECT *
FROM ML.GENERATE_EMBEDDING(
        MODEL `climate_ai.multimodal_embedding_model`,
        (
            SELECT *
            FROM `climate_ai.earth_images`
            WHERE content_type = 'image/jpeg'
        )
    );
-- Vector Search for Fire/Flood Pattern
CREATE OR REPLACE TABLE `climate_ai.fire_signature_query_embedding` AS
SELECT *
FROM ML.GENERATE_EMBEDDING(
        MODEL `climate_ai.multimodal_embedding_model`,
        (
            SELECT "visible wildfire signature: plume, heat, smoke" AS content
        )
    );
-- Semantic search for similar images (wildfire visual cues)
CREATE OR REPLACE TABLE `climate_ai.fire_image_candidates` AS
SELECT base.uri AS gcs_uri,
    distance
FROM VECTOR_SEARCH(
        TABLE `climate_ai.earth_image_embeddings`,
        'ml_generate_embedding_result',
        TABLE `climate_ai.fire_signature_query_embedding`,
        'ml_generate_embedding_result',
        top_k => 5
    );
---- Flag likely fire or flood disaster
CREATE OR REPLACE TABLE climate_ai.emergency_routing AS
SELECT 'fire' AS event_type,
    lat,
    lon,
    CURRENT_TIMESTAMP() AS route_time,
    'emergency_team' AS dispatch_type,
    CONCAT(
        'AI forecast high fire risk. Temperature:',
        CAST(forecast_value AS STRING)
    ) AS rationale
FROM climate_ai.fire_forecast
WHERE forecast_value > 0.85