-- This file contains SQL commands for creating and managing tables and models in the climate AI project.
-- Sensor acquisition data (extended version proposal of which only some fields are used in queries)
CREATE TABLE `climate_ai.sensor_data` (
    sensor_id STRING NOT NULL,
    -- Unique sensor hardware identifier
    timestamp TIMESTAMP NOT NULL,
    sensor_type STRING NOT NULL,
    -- Type of sensor (e.g., temperature, humidity)
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
    value FLOAT64,
    -- Sensor value (e.g., temperature, humidity, pressure)
    source STRING,
    -- Source of the data (e.g., sensor type)
    image_ref STRUCT < uri STRING,
    -- URI to the image file
    tstamp TIMESTAMP -- Timestamp of the image capture
    >,
    -- Image reference for associated satellite imagery when stored in same table
    ingestion_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP() -- When loaded into table
) PARTITION BY DATE(timestamp) CLUSTER BY location_id,
sensor_id;
-- Earth AI Images
CREATE OR REPLACE EXTERNAL TABLE climate_ai.earth_images WITH CONNECTION `project.region.connection_name` DEFAULT OPTIONS (
        object_metadata = 'SIMPLE',
        uris = ['gs://climate-ai-satellite-2025/*']
    );
-- Imagery Objects View provides a structured way to access imagery metadata.
CREATE OR REPLACE VIEW `climate_ai.imagery_objects` AS
SELECT uri,
    -- GCS URI of image
    ref,
    -- ObjectRef metadata struct
    SAFE_CAST(JSON_VALUE(ref, '$.lat') AS FLOAT64) AS lat,
    SAFE_CAST(JSON_VALUE(ref, '$.lon') AS FLOAT64) AS lon,
    tstamp -- Associated time
FROM `climate_ai.earth_images`;
-- Imagery Metadata Table
CREATE OR REPLACE TABLE `climate_ai.imagery_metadata` (
        image_id STRING,
        location_id STRING,
        capture_time TIMESTAMP,
        gcs_uri STRING,
        fire_index FLOAT64,
        flood_index FLOAT64
    );
-- Enrich sensor table with nearest satellite image reference
CREATE OR REPLACE TABLE climate_ai.sensor_data_with_images AS
SELECT s.*,
    img.uri AS image_uri,
    img.ref AS image_ref
FROM climate_ai.sensor_data s
    LEFT JOIN climate_ai.earth_images img ON ABS(s.lat - img.lat) < 0.01
    AND ABS(s.lon - img.lon) < 0.01
    AND TIMESTAMP_DIFF(s.timestamp, img.tstamp, MINUTE) BETWEEN -10 AND 10;
-- Generate Embeddings for Images
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
-- Fire Forecast Table
CREATE TABLE `climate_ai.fire_forecast` (
    lat FLOAT64,
    lon FLOAT64,
    forecast_value FLOAT64
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
WHERE forecast_value > 0.85;
--- Disaster Event Forecast Table
CREATE TABLE `climate_ai.disaster_event_forecast` (
    event_type STRING NOT NULL,
    -- 'fire', 'flood'
    lat FLOAT64 NOT NULL,
    -- Event latitude
    lon FLOAT64 NOT NULL,
    -- Event longitude
    forecast_time TIMESTAMP NOT NULL,
    -- Forecast for this time
    forecast_value FLOAT64,
    -- Probability (0-1) or intensity score
    confidence FLOAT64,
    -- Confidence of prediction
    ai_status STRING,
    -- 'Success' or 'Error'
    action_required BOOL -- Route detection required (TRUE/FALSE)
) PARTITION BY DATE(forecast_time) CLUSTER BY event_type;
-- Emergency Routing Output
CREATE TABLE `climate_ai.emergency_routing_output` (
    event_type STRING NOT NULL,
    -- 'fire', 'flood'
    lat FLOAT64 NOT NULL,
    -- Target latitude
    lon FLOAT64 NOT NULL,
    -- Target longitude
    route_time TIMESTAMP NOT NULL,
    -- Time routing is issued
    dispatch_type STRING NOT NULL,
    -- 'emergency_team', 'sensor_mobile'
    rationale STRING -- Free text, e.g. from AI.GENERATE
) PARTITION BY DATE(route_time) CLUSTER BY event_type,
dispatch_type;
-- Sensor Alert Logs from Alerting System
CREATE TABLE `climate_ai.sensor_alert_logs` (
    location_id STRING NOT NULL,
    -- Unique location identifier
    lat FLOAT64 NOT NULL,
    -- Latitude of the monitored location
    lon FLOAT64 NOT NULL,
    -- Longitude of the monitored location
    avg_temp FLOAT64,
    -- Average temperature over last 6h
    avg_precip FLOAT64,
    -- Average precipitation over last 6h
    avg_pressure FLOAT64,
    -- Average pressure over last 6h
    temp_forecast FLOAT64,
    -- Forecasted temperature (next 6h)
    max_fire_index FLOAT64,
    -- Maximum observed fire index (last 12h)
    max_flood_index FLOAT64,
    -- Maximum observed flood index (last 12h)
    risk_classification STRING,
    -- Risk classification label (emoji + text)
    alert_level STRING,
    -- 'CRITICAL', 'WARNING', 'NORMAL'
    alert_message STRING,
    -- AI.GENERATE‑produced human‑readable summary
    log_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP() -- When this alert was logged
) PARTITION BY DATE(log_timestamp) CLUSTER BY alert_level,
location_id;