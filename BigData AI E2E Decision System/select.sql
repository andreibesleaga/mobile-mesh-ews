-- =========================================
-- Climate AI Unified Analytics & Forecasting (Fixed)
-- =========================================
-- Step 1: Forecast Sonoma County temperature risk (6h horizon)
WITH sonoma_forecast AS (
  SELECT *
  FROM AI.FORECAST(
      (
        SELECT TIMESTAMP_TRUNC(timestamp, HOUR) AS time,
          AVG(temperature) AS value
        FROM `climate_ai.sensor_data`
        WHERE sensor_type = 'temp'
          AND lat BETWEEN 38.25 AND 38.35
          AND lon BETWEEN -122.50 AND -122.40
          AND timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 7 DAY)
        GROUP BY time
        ORDER BY time
      ),
      timestamp_col => 'time',
      data_col => 'value',
      horizon => 6
    )
),
-- Step 2: Forecast Romania temperature risk (Arges County example)
romania_forecast AS (
  SELECT *
  FROM AI.FORECAST(
      (
        SELECT TIMESTAMP_TRUNC(timestamp, HOUR) AS time,
          AVG(temperature) AS value
        FROM `climate_ai.sensor_data`
        WHERE sensor_type = 'temp'
          AND lat BETWEEN 45.00 AND 45.30
          AND lon BETWEEN 24.80 AND 25.10
          AND timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 7 DAY)
        GROUP BY time
        ORDER BY time
      ),
      timestamp_col => 'time',
      data_col => 'value',
      horizon => 6
    )
),
-- Step 3: Structured extraction from alert logs
alert_entities AS (
  SELECT alert_message AS alert_type,
    FALSE AS action_required,
    'N/A' AS affected_area
  FROM `climate_ai.sensor_alert_logs`
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
    JOIN `climate_ai.imagery_metadata` i ON s.location_id = i.location_id -- assumes imagery_metadata now has location_id in schema
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
), -- Step 9: Forecast temperature & precipitation trends for Câmpulung station
-- Step 9a: Temperature forecast for Câmpulung station
campulung_temp_forecast AS (
  SELECT *
  FROM AI.FORECAST(
      (
        SELECT TIMESTAMP_TRUNC(timestamp, HOUR) AS time,
          AVG(temperature) AS value
        FROM `climate_ai.sensor_data`
        WHERE location_id = 'RO-CAMPULUNG-01'
          AND timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 7 DAY)
        GROUP BY time
        ORDER BY time
      ),
      timestamp_col => 'time',
      data_col => 'value',
      horizon => 6
    )
),
-- Step 9b: Precipitation forecast for Câmpulung station
campulung_precip_forecast AS (
  SELECT *
  FROM AI.FORECAST(
      (
        SELECT TIMESTAMP_TRUNC(timestamp, HOUR) AS time,
          AVG(precipitation) AS value
        FROM `climate_ai.sensor_data`
        WHERE location_id = 'RO-CAMPULUNG-01'
          AND timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 7 DAY)
        GROUP BY time
        ORDER BY time
      ),
      timestamp_col => 'time',
      data_col => 'value',
      horizon => 6
    )
),
-- Step 9c: Combine both forecasts
romania_trends AS (
  SELECT 'RO-CAMPULUNG-01' AS location_id,
    'Combined Câmpulung Forecast' AS forecast_type,
    COUNT(*) AS forecast_points_temp,
    COUNT(*) AS forecast_points_precip
  FROM campulung_temp_forecast t
    CROSS JOIN campulung_precip_forecast p
),
-- Step 10: Risk embeddings from imagery (simplified - embedding generation requires specific model setup)
risk_embeddings AS (
  SELECT image_id,
    CONCAT(
      'fire_risk:',
      CAST(fire_index AS STRING),
      '_flood_risk:',
      CAST(flood_index AS STRING)
    ) AS risk_text_signature
  FROM `climate_ai.imagery_metadata`
  WHERE capture_time >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 1 DAY)
),
-- Step 11: Natural language summaries of risk (simplified)
risk_summaries AS (
  SELECT s.location_id,
    CONCAT(
      'Risk Assessment for ',
      s.location_id,
      ': ',
      CASE
        WHEN i.fire_index > 0.8 THEN 'CRITICAL fire risk (index: '
        WHEN i.fire_index > 0.6 THEN 'HIGH fire risk (index: '
        ELSE 'Moderate fire risk (index: '
      END,
      CAST(ROUND(i.fire_index, 2) AS STRING),
      '), ',
      CASE
        WHEN i.flood_index > 0.8 THEN 'CRITICAL flood risk (index: '
        WHEN i.flood_index > 0.6 THEN 'HIGH flood risk (index: '
        ELSE 'Moderate flood risk (index: '
      END,
      CAST(ROUND(i.flood_index, 2) AS STRING),
      ').'
    ) AS risk_summary
  FROM `climate_ai.imagery_metadata` i
    JOIN `climate_ai.sensor_data` s ON s.location_id = i.location_id
  WHERE i.fire_index > 0.6
    OR i.flood_index > 0.6
  GROUP BY s.location_id,
    i.fire_index,
    i.flood_index
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
    -- Simplified forecasting using statistical trends instead of AI.FORECAST with correlated subquery
    avg_temp_recent + (avg_temp_recent - avg_temp_week_ago) * 0.5 AS temp_forecast,
    'forecasted' AS forecast_type
  FROM (
      SELECT location_id,
        AVG(
          CASE
            WHEN timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 24 HOUR) THEN temperature
          END
        ) AS avg_temp_recent,
        AVG(
          CASE
            WHEN timestamp BETWEEN TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 8 DAY)
            AND TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 7 DAY) THEN temperature
          END
        ) AS avg_temp_week_ago
      FROM `climate_ai.sensor_data`
      WHERE timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 8 DAY)
      GROUP BY location_id
      HAVING COUNT(*) > 10 -- Ensure sufficient data
    )
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
) -- Final output
SELECT *
FROM decision_engine;
-- =========================================
-- INNOVATIVE AI.GENERATE USAGE EXAMPLES
-- =========================================
-- ⚡ AI-Generated Risk Assessment Narratives
WITH ai_risk_narratives AS (
  SELECT location_id,
    risk_classification,
    avg_temp,
    avg_precip,
    ML.GENERATE_TEXT_LLM(
      prompt => CONCAT(
        'You are a climate emergency coordinator. Write a 2-sentence executive briefing for location ',
        location_id,
        ' which has ',
        risk_classification,
        ' with current temperature ',
        CAST(avg_temp AS STRING),
        '°C and precipitation ',
        CAST(avg_precip AS STRING),
        'mm. Focus on immediate actions needed and timeline.'
      ),
      connection_id => 'projects/YOUR_PROJECT_ID/locations/us-central1/connections/gemini'
    ) AS executive_briefing
  FROM recent_sensor s
    JOIN forecasted_risk f USING (location_id)
    JOIN imagery_risk i USING (location_id)
  WHERE s.avg_temp > 30
    OR s.avg_precip > 40
),
-- 🌡️ AI-Generated Weather Pattern Analysis
weather_insights AS (
  SELECT location_id,
    ML.GENERATE_TEXT_LLM(
      prompt => CONCAT(
        'Analyze this weather pattern as a meteorologist: Location ',
        location_id,
        ' shows 6-hour averages of Temperature: ',
        CAST(avg_temp AS STRING),
        '°C, ',
        'Precipitation: ',
        CAST(avg_precip AS STRING),
        'mm, ',
        'Pressure: ',
        CAST(avg_pressure AS STRING),
        'hPa. ',
        'Provide a 1-sentence trend analysis and 1-sentence forecast implication.'
      ),
      connection_id => 'projects/YOUR_PROJECT_ID/locations/us-central1/connections/gemini'
    ) AS meteorological_analysis
  FROM recent_sensor
  WHERE avg_temp IS NOT NULL
    AND avg_precip IS NOT NULL
),
-- 🔥 AI-Generated Emergency Response Planning
emergency_protocols AS (
  SELECT location_id,
    risk_classification,
    ML.GENERATE_TEXT_LLM(
      prompt => CONCAT(
        'You are an emergency response planner. For location ',
        location_id,
        ' with risk level: ',
        risk_classification,
        ', generate a JSON response plan with these exact fields: ',
        '{"priority_level": "1-5", "resources_needed": ["list"], "timeline_hours": number, "evacuation_radius_km": number, "contact_agencies": ["list"]}. ',
        'Respond only with valid JSON, no additional text.'
      ),
      connection_id => 'projects/YOUR_PROJECT_ID/locations/us-central1/connections/gemini'
    ) AS response_plan_json
  FROM recent_sensor s
    JOIN forecasted_risk f USING (location_id)
    JOIN imagery_risk i USING (location_id)
  WHERE risk_classification IN ('High Wildfire Risk', 'High Flood Risk')
),
-- 📱 AI-Generated Public Alerts
public_notifications AS (
  SELECT location_id,
    risk_classification,
    ML.GENERATE_TEXT_LLM(
      prompt => CONCAT(
        'Write a clear, calm public emergency alert for residents in ',
        location_id,
        '. Current situation: ',
        risk_classification,
        '. The message should be under 160 characters (SMS friendly), include specific action (evacuate/shelter/prepare), and mention official source. ',
        'Format: [ACTION REQUIRED] brief description - Official Climate AI EWS'
      ),
      connection_id => 'projects/YOUR_PROJECT_ID/locations/us-central1/connections/gemini'
    ) AS sms_alert
  FROM recent_sensor s
    JOIN forecasted_risk f USING (location_id)
    JOIN imagery_risk i USING (location_id)
  WHERE risk_classification != 'Low Risk'
) -- 📊 Combined AI Insights Dashboard Query
SELECT r.location_id,
  r.executive_briefing,
  w.meteorological_analysis,
  e.response_plan_json,
  p.sms_alert,
  CURRENT_TIMESTAMP() as generated_at
FROM ai_risk_narratives r
  LEFT JOIN weather_insights w USING (location_id)
  LEFT JOIN emergency_protocols e USING (location_id)
  LEFT JOIN public_notifications p USING (location_id)
ORDER BY CASE
    WHEN r.risk_classification = 'High Wildfire Risk' THEN 1
    WHEN r.risk_classification = 'High Flood Risk' THEN 2
    ELSE 3
  END;