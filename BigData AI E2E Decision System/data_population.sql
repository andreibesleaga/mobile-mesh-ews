-- ==============================
-- 1. Sensor acquisition data
-- ==============================
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
    )
VALUES (
        'SEN-001',
        TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 1 HOUR),
        'multiple',
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
        'OK',
        39.5,
        'temperature',
        NULL
    ),
    (
        'SEN-002',
        TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 2 HOUR),
        'multiple',
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
        'OK',
        41.0,
        'temperature',
        NULL
    ),
    (
        'SEN-003',
        TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 30 MINUTE),
        'multiple',
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
        'OK',
        28.0,
        'temperature',
        NULL
    ),
    (
        'SEN-004',
        TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 1 HOUR),
        'multiple',
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
        'OK',
        29.5,
        'temperature',
        NULL
    );
-- ==============================
-- 2. Imagery metadata table
-- ==============================
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
-- ==============================
-- 9. Disaster event forecast mock
-- ==============================
CREATE OR REPLACE TABLE `climate_ai.disaster_event_forecast` (
        event_type STRING,
        lat FLOAT64,
        lon FLOAT64,
        forecast_time TIMESTAMP,
        forecast_value FLOAT64,
        confidence FLOAT64,
        ai_status STRING,
        action_required BOOL
    );
-- Random data population for climate_ai tables
-- 1️⃣ Populate disaster_event_forecast
INSERT INTO `climate_ai.disaster_event_forecast` (
        event_type,
        lat,
        lon,
        forecast_time,
        forecast_value,
        confidence,
        ai_status,
        action_required
    ) WITH base AS (
        SELECT *
        FROM UNNEST(
                [
    STRUCT('fire' AS event_type),
    ('flood')
  ]
            ) t
    )
SELECT event_type,
    30 + RAND() * 20 AS lat,
    -- Random lat between 30–50
    -120 + RAND() * 40 AS lon,
    -- Random lon between -120 to -80
    TIMESTAMP_ADD(
        CURRENT_TIMESTAMP(),
        INTERVAL CAST(RAND() * 72 AS INT64) HOUR
    ) AS forecast_time,
    ROUND(RAND(), 2) AS forecast_value,
    -- Probability 0–1
    ROUND(0.7 + RAND() * 0.3, 2) AS confidence,
    -- Confidence 0.7–1.0
    IF(RAND() > 0.1, 'Success', 'Error') AS ai_status,
    -- Mostly success
    RAND() > 0.5 AS action_required
FROM base,
    UNNEST(GENERATE_ARRAY(1, 10)) AS _;
-- 10 random rows per event_type
-- 2️⃣ Populate emergency_routing_output
INSERT INTO `climate_ai.emergency_routing_output` (
        event_type,
        lat,
        lon,
        route_time,
        dispatch_type,
        rationale
    ) WITH base AS (
        SELECT *
        FROM UNNEST(
                [
    STRUCT('fire' AS event_type),
    ('flood')
  ]
            ) t
    ),
    dispatch AS (
        SELECT *
        FROM UNNEST(
                [
    STRUCT('emergency_team' AS dispatch_type),
    ('sensor_mobile')
  ]
            ) t
    )
SELECT b.event_type,
    30 + RAND() * 20 AS lat,
    -120 + RAND() * 40 AS lon,
    TIMESTAMP_ADD(
        CURRENT_TIMESTAMP(),
        INTERVAL CAST(RAND() * 48 AS INT64) HOUR
    ) AS route_time,
    d.dispatch_type,
    CONCAT(
        "Routing ",
        d.dispatch_type,
        " to handle ",
        b.event_type,
        " risk at coordinates (",
        CAST(ROUND(30 + RAND() * 20, 3) AS STRING),
        ", ",
        CAST(ROUND(-120 + RAND() * 40, 3) AS STRING),
        ")"
    ) AS rationale
FROM base b
    CROSS JOIN dispatch d
    CROSS JOIN UNNEST(GENERATE_ARRAY(1, 5)) AS _;
-- 5 random entries per combination
-- 3️⃣ Populate sensor_alert_logs
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
    )
SELECT CONCAT('LOC_', CAST(FLOOR(RAND() * 1000) AS STRING)) AS location_id,
    30 + RAND() * 20 AS lat,
    -120 + RAND() * 40 AS lon,
    ROUND(15 + RAND() * 25, 2) AS avg_temp,
    ROUND(RAND() * 100, 2) AS avg_precip,
    ROUND(950 + RAND() * 100, 2) AS avg_pressure,
    ROUND(15 + RAND() * 25, 2) AS temp_forecast,
    ROUND(RAND(), 2) AS max_fire_index,
    ROUND(RAND(), 2) AS max_flood_index,
    CASE
        WHEN RAND() > 0.8 THEN 'High Wildfire Risk'
        WHEN RAND() > 0.6 THEN 'High Flood Risk'
        WHEN RAND() > 0.4 THEN 'Moderate Wildfire Risk'
        WHEN RAND() > 0.2 THEN 'Moderate Flood Risk'
        ELSE 'Low Risk'
    END AS risk_classification,
    CASE
        WHEN RAND() > 0.8 THEN 'CRITICAL'
        WHEN RAND() > 0.4 THEN 'WARNING'
        ELSE 'NORMAL'
    END AS alert_level,
    CONCAT(
        "Alert for location ",
        CAST(FLOOR(RAND() * 1000) AS STRING),
        ": conditions indicate ",
        CASE
            WHEN RAND() > 0.8 THEN 'severe risk — immediate action required.'
            WHEN RAND() > 0.4 THEN 'moderate concern — monitor closely.'
            ELSE 'low risk — no immediate action.'
        END
    ) AS alert_message,
    TIMESTAMP_ADD(
        CURRENT_TIMESTAMP(),
        INTERVAL CAST(RAND() * -72 AS INT64) HOUR
    ) AS log_timestamp
FROM UNNEST(GENERATE_ARRAY(1, 20)) AS _;
-- 20 random rows