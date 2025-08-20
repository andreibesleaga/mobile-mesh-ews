--Forecasting Disaster Probability with BigQuery AI.FORECAST
-- Predicting Next 6 Hours for Fires in Sonoma County
SELECT *
FROM AI.FORECAST(
    TABLE climate_ai.sensor_data,
    data_col => 'value',
    timestamp_col => 'timestamp',
    id_cols => ['sensor_type', 'lat', 'lon'],
    model => 'TimesFM 2.0',
    horizon => 6,
    confidence_level => 0.95
  )
WHERE sensor_type = 'temp'
  AND lat BETWEEN 38.25 AND 38.35
  AND lon BETWEEN -122.50 AND -122.40 -- Suppose we receive unstructured API logs or sensor events as blobs or JSON.
SELECT *
FROM AI.GENERATE_TABLE(
    MODEL `climate_ai.gemini_flash`,
    (
      SELECT alert_text as prompt
      FROM climate_ai.sensor_alert_logs
    ),
    STRUCT(
      "alert_type STRING, action_required BOOL, affected_area STRING" AS output_schema
    )
  ) -- AI-based time series forecasting of fire risk
SELECT *
FROM AI.FORECAST(
    TABLE climate_ai.sensor_data,
    data_col => 'value',
    timestamp_col => 'timestamp',
    id_cols => ['sensor_type', 'lat', 'lon'],
    model => 'TimesFM 2.0',
    horizon => 6,
    confidence_level => 0.95
  )
WHERE sensor_type = 'temp'
  AND lat BETWEEN 38.25 AND 38.35
  AND lon BETWEEN -122.50 AND -122.40 -- Wildfire Risk Detection
SELECT location_id,
  AVG(temperature) AS avg_temp,
  AVG(pressure) AS avg_pressure,
  COUNT(*) AS readings_count
FROM sensor_data
WHERE timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 24 HOUR)
  AND temperature > 35
  AND pressure < 1000
GROUP BY location_id
HAVING avg_temp > 38
  AND avg_pressure < 995;
-- Flood risk detection
SELECT location_id,
  AVG(precipitation) AS avg_precip,
  COUNT(*) AS readings_count
FROM sensor_data
WHERE timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 48 HOUR)
  AND precipitation > 50
GROUP BY location_id
HAVING avg_precip > 80;
-- Cross-Referencing Sensor and Imagery Data
SELECT s.location_id,
  s.lat,
  s.lon,
  i.fire_index,
  i.flood_index,
  AVG(s.temperature) AS avg_temp,
  AVG(s.precipitation) AS avg_precip
FROM sensor_data s
  JOIN imagery_metadata i ON s.location_id = i.location_id
WHERE s.timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 12 HOUR)
  AND i.capture_time >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 12 HOUR)
GROUP BY s.location_id,
  s.lat,
  s.lon,
  i.fire_index,
  i.flood_index
HAVING i.fire_index > 0.7
  OR i.flood_index > 0.7;
-- Combines live sensor data with satellite imagery metadata to identify high-risk zones.
-- Predictive Time Window Query
SELECT location_id,
  TIMESTAMP_TRUNC(timestamp, HOUR) AS hour_bucket,
  AVG(temperature) AS avg_temp,
  AVG(precipitation) AS avg_precip
FROM sensor_data
WHERE timestamp BETWEEN TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 6 HOUR)
  AND TIMESTAMP_ADD(CURRENT_TIMESTAMP(), INTERVAL 6 HOUR)
GROUP BY location_id,
  hour_bucket
ORDER BY hour_bucket;
-- Prepares time-series data for forecasting models like AI.FORECAST.
-- Location-Based Query for Dispatch Planning
SELECT location_id,
  lat,
  lon,
  MAX(temperature) AS peak_temp,
  MAX(precipitation) AS peak_precip
FROM sensor_data
WHERE timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 1 HOUR)
GROUP BY location_id,
  lat,
  lon
ORDER BY peak_temp DESC,
  peak_precip DESC
LIMIT 5;
-- Identifies top 5 hotspots for immediate emergency response.
-- Forecasting Temperature and Precipitation Trends
SELECT location_id,
  AI.FORECAST(
    MODEL => 'linear_regression',
    TABLE => (
      SELECT TIMESTAMP_TRUNC(timestamp, HOUR) AS time,
        AVG(temperature) AS value
      FROM sensor_data
      WHERE location_id = 'RO-CAMPULUNG-01'
      GROUP BY time
    ),
    HORIZON => 6
  ) AS temp_forecast,
  AI.FORECAST(
    MODEL => 'linear_regression',
    TABLE => (
      SELECT TIMESTAMP_TRUNC(timestamp, HOUR) AS time,
        AVG(precipitation) AS value
      FROM sensor_data
      WHERE location_id = 'RO-CAMPULUNG-01'
      GROUP BY time
    ),
    HORIZON => 6
  ) AS precip_forecast -- Embedding Imagery Metadata for Similarity Search
SELECT image_id,
  ML.GENERATE_EMBEDDING(
    MODEL => 'textembedding-gecko',
    TEXT => CONCAT(
      'Fire risk:',
      fire_index,
      ', Flood risk:',
      flood_index
    )
  ) AS risk_embedding
FROM imagery_metadata
WHERE capture_time >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 1 DAY) -- Converts fire/flood risk scores into vector embeddings for clustering or anomaly detection.
  -- Natural Language Summary of Risk Conditions
SELECT location_id,
  AI.GENERATE(
    MODEL => 'gemini-pro',
    PROMPT => CONCAT(
      'Summarize the wildfire and flood risk for location ',
      location_id,
      ' based on fire index ',
      CAST(fire_index AS STRING),
      ' and flood index ',
      CAST(flood_index AS STRING),
      '.'
    )
  ) AS risk_summary
FROM imagery_metadata
WHERE fire_index > 0.6
  OR flood_index > 0.6 -- Generates human-readable summaries for emergency dashboards or alerts.
  -- Final SQL Pipeline: Climate Disaster Decision Engine
  -- This pipeline combines sensor data, AI forecasts, and imagery metadata to classify locations into risk tiers.
  WITH recent_sensor AS (
    SELECT location_id,
      AVG(temperature) AS avg_temp,
      AVG(precipitation) AS avg_precip,
      AVG(pressure) AS avg_pressure
    FROM sensor_data
    WHERE timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 6 HOUR)
    GROUP BY location_id
  ),
  forecasted_risk AS (
    SELECT location_id,
      AI.FORECAST(
        MODEL => 'linear_regression',
        TABLE => (
          SELECT TIMESTAMP_TRUNC(timestamp, HOUR) AS time,
            AVG(temperature) AS value
          FROM sensor_data
          WHERE location_id IS NOT NULL
          GROUP BY time
        ),
        HORIZON => 6
      ) AS temp_forecast
  ),
  imagery_risk AS (
    SELECT location_id,
      MAX(fire_index) AS max_fire_index,
      MAX(flood_index) AS max_flood_index
    FROM imagery_metadata
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
        AND s.avg_temp > 35 THEN '🔥 High Wildfire Risk'
        WHEN i.max_flood_index > 0.7
        AND s.avg_precip > 80 THEN '🌊 High Flood Risk'
        WHEN s.avg_temp > 30
        AND s.avg_pressure < 1000 THEN '⚠️ Moderate Wildfire Risk'
        WHEN s.avg_precip > 50 THEN '⚠️ Moderate Flood Risk'
        ELSE '✅ Low Risk'
      END AS risk_classification
    FROM recent_sensor s
      JOIN forecasted_risk f USING (location_id)
      JOIN imagery_risk i USING (location_id)
  )
SELECT *
FROM decision_engine
ORDER BY risk_classification DESC;