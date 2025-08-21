-- Example of SELECTS for Climate AI EWS Unified Analytics Pipeline
-- This script combines forecasting, anomaly detection, AI enrichment, and decision classification
-- examples for Sonoma County (US) and Romania regions, aligned with alerts_sink.sql.
-- Step 1: Forecast Sonoma County temperature risk (6h horizon)
WITH sonoma_forecast AS (
  SELECT *
  FROM AI.FORECAST(
      TABLE `climate_ai.sensor_data`,
      data_col => 'value',
      timestamp_col => 'timestamp',
      id_cols => ['sensor_type', 'lat', 'lon'],
      model => 'TimesFM 2.0',
      horizon => 6,
      confidence_level => 0.95
    )
  WHERE sensor_type = 'temp'
    AND lat BETWEEN 38.25 AND 38.35
    AND lon BETWEEN -122.50 AND -122.40
),
-- Step 2: Forecast Romania temperature risk (example: Arges County bounding box)
romania_forecast AS (
  SELECT *
  FROM AI.FORECAST(
      TABLE `climate_ai.sensor_data`,
      data_col => 'value',
      timestamp_col => 'timestamp',
      id_cols => ['sensor_type', 'lat', 'lon'],
      model => 'TimesFM 2.0',
      horizon => 6,
      confidence_level => 0.95
    )
  WHERE sensor_type = 'temp'
    AND lat BETWEEN 45.00 AND 45.30
    AND lon BETWEEN 24.80 AND 25.10
),
-- Step 3: Structured extraction from alert logs
alert_entities AS (
  SELECT *
  FROM AI.GENERATE_TABLE(
      MODEL `climate_ai.gemini_flash`,
      (
        SELECT alert_text AS prompt
        FROM `climate_ai.sensor_alert_logs`
      ),
      STRUCT(
        "alert_type STRING, action_required BOOL, affected_area STRING" AS output_schema
      )
    )
),
-- Step 4: Wildfire risk detection (global)
wildfire_anomalies AS (
  SELECT location_id,
    AVG(temperature) AS avg_temp,
    AVG(pressure) AS avg_pressure,
    COUNT(*) AS readings_count
  FROM `climate_ai.sensor_data`
  WHERE timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 24 HOUR)
    AND temperature > 35
    AND pressure < 1000
  GROUP BY location_id
  HAVING avg_temp > 38
    AND avg_pressure < 995
),
-- Step 5: Flood risk detection (global)
flood_anomalies AS (
  SELECT location_id,
    AVG(precipitation) AS avg_precip,
    COUNT(*) AS readings_count
  FROM `climate_ai.sensor_data`
  WHERE timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 48 HOUR)
    AND precipitation > 50
  GROUP BY location_id
  HAVING avg_precip > 80
),
-- Step 6: Cross‑reference sensor & imagery data
sensor_imagery_risk AS (
  SELECT s.location_id,
    s.lat,
    s.lon,
    i.fire_index,
    i.flood_index,
    AVG(s.temperature) AS avg_temp,
    AVG(s.precipitation) AS avg_precip
  FROM `climate_ai.sensor_data` s
    JOIN `climate_ai.imagery_metadata` i USING (location_id)
  WHERE s.timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 12 HOUR)
    AND i.capture_time >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 12 HOUR)
  GROUP BY s.location_id,
    s.lat,
    s.lon,
    i.fire_index,
    i.flood_index
  HAVING i.fire_index > 0.7
    OR i.flood_index > 0.7
),
-- Step 7: Predictive time window query
time_window_stats AS (
  SELECT location_id,
    TIMESTAMP_TRUNC(timestamp, HOUR) AS hour_bucket,
    AVG(temperature) AS avg_temp,
    AVG(precipitation) AS avg_precip
  FROM `climate_ai.sensor_data`
  WHERE timestamp BETWEEN TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 6 HOUR)
    AND TIMESTAMP_ADD(CURRENT_TIMESTAMP(), INTERVAL 6 HOUR)
  GROUP BY location_id,
    hour_bucket
),
-- Step 8: Dispatch planning hotspots
dispatch_hotspots AS (
  SELECT location_id,
    lat,
    lon,
    MAX(temperature) AS peak_temp,
    MAX(precipitation) AS peak_precip
  FROM `climate_ai.sensor_data`
  WHERE timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 1 HOUR)
  GROUP BY location_id,
    lat,
    lon
  ORDER BY peak_temp DESC,
    peak_precip DESC
  LIMIT 5
), -- Step 9: Forecast temperature & precipitation trends for Romania (Câmpulung station example)
romania_trends AS (
  SELECT location_id,
    AI.FORECAST(
      model => 'linear_regression',
      table => (
        SELECT TIMESTAMP_TRUNC(timestamp, HOUR) AS time,
          AVG(temperature) AS value
        FROM `climate_ai.sensor_data`
        WHERE location_id = 'RO-CAMPULUNG-01'
        GROUP BY time
      ),
      horizon => 6
    ) AS temp_forecast,
    AI.FORECAST(
      model => 'linear_regression',
      table => (
        SELECT TIMESTAMP_TRUNC(timestamp, HOUR) AS time,
          AVG(precipitation) AS value
        FROM `climate_ai.sensor_data`
        WHERE location_id = 'RO-CAMPULUNG-01'
        GROUP BY time
      ),
      horizon => 6
    ) AS precip_forecast
),
-- Step 10: Risk embeddings from imagery
risk_embeddings AS (
  SELECT image_id,
    ML.GENERATE_EMBEDDING(
      model => 'textembedding-gecko',
      text => CONCAT(
        'Fire risk:',
        CAST(fire_index AS STRING),
        ', Flood risk:',
        CAST(flood_index AS STRING)
      )
    ) AS risk_embedding
  FROM `climate_ai.imagery_metadata`
  WHERE capture_time >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 1 DAY)
),
-- Step 11: Natural language summaries of risk
risk_summaries AS (
  SELECT location_id,
    AI.GENERATE(
      model => 'gemini-pro',
      prompt => CONCAT(
        'Summarize the wildfire and flood risk for location ',
        location_id,
        ' based on fire index ',
        CAST(fire_index AS STRING),
        ' and flood index ',
        CAST(flood_index AS STRING),
        '.'
      )
    ) AS risk_summary
  FROM `climate_ai.imagery_metadata`
  WHERE fire_index > 0.6
    OR flood_index > 0.6
),
-- Step 12: Core decision engine
recent_sensor AS (
  SELECT location_id,
    AVG(temperature) AS avg_temp,
    AVG(precipitation) AS avg_precip,
    AVG(pressure) AS avg_pressure
  FROM `climate_ai.sensor_data`
  WHERE timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 6 HOUR)
  GROUP BY location_id
),
forecasted_risk AS (
  SELECT location_id,
    AI.FORECAST(
      model => 'linear_regression',
      table => (
        SELECT TIMESTAMP_TRUNC(timestamp, HOUR) AS time,
          AVG(temperature) AS value
        FROM `climate_ai.sensor_data`
        WHERE location_id IS NOT NULL
        GROUP BY time
      ),
      horizon => 6
    ) AS temp_forecast
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
    s.avg_temp,
    s.avg_precip,
    s.avg_pressure,
    f.temp_forecast,
    i.max_fire_index,
    i.max_flood_index,
    CASE
      WHEN i.max_fire_index > 0.7
      AND s.avg_temp > 35 THEN 'High Wildfire Risk'
      WHEN i.max_flood_index > 0.7
      AND s.avg_precip > 80 THEN 'High Flood Risk'
      WHEN s.avg_temp > 30
      AND s.avg_pressure < 1000 THEN 'Moderate Wildfire Risk'
      WHEN s.avg_precip > 50 THEN 'Moderate Flood Risk'
      ELSE 'Low Risk'
    END AS risk_classification
  FROM recent_sensor s
    JOIN forecasted_risk f USING (location_id)
    JOIN imagery_risk i USING (location_id)
) -- Final output: Full decision engine results
SELECT *
FROM decision_engine
ORDER BY risk_classification DESC;