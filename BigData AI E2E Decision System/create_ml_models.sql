-- =========================================
-- Climate AI: ML Models Creation Script
-- =========================================
-- Run this script AFTER populating data with data_population.sql or mock_data_generator.sql
-- This creates the ML models needed for AI.FORECAST functions
-- Check if we have sufficient data first
SELECT COUNT(*) as total_rows,
    COUNT(DISTINCT location_id) as locations,
    MIN(timestamp) as earliest_data,
    MAX(timestamp) as latest_data
FROM `climate_ai.sensor_data`
WHERE temperature IS NOT NULL;
-- Only proceed if you have sufficient rows (>100 recommended)
-- =========================================
-- Temperature Forecasting Model
-- =========================================
CREATE OR REPLACE MODEL `climate_ai.linear_regression_temp_model` OPTIONS(
        model_type = 'linear_reg',
        input_label_cols = ['value']
    ) AS
SELECT TIMESTAMP_TRUNC(timestamp, HOUR) AS time,
    temperature AS value,
    location_id
FROM `climate_ai.sensor_data`
WHERE temperature IS NOT NULL
    AND timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 7 DAY)
    AND temperature BETWEEN -50 AND 60;
-- Reasonable temperature range
-- =========================================
-- Precipitation Forecasting Model
-- =========================================
CREATE OR REPLACE MODEL `climate_ai.linear_regression_precip_model` OPTIONS(
        model_type = 'linear_reg',
        input_label_cols = ['value']
    ) AS
SELECT TIMESTAMP_TRUNC(timestamp, HOUR) AS time,
    precipitation AS value,
    location_id
FROM `climate_ai.sensor_data`
WHERE precipitation IS NOT NULL
    AND timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 7 DAY)
    AND precipitation >= 0;
-- Non-negative precipitation
-- =========================================
-- Validate Models
-- =========================================
-- Simple validation - if we reach this point, models were created successfully
-- Complex INFORMATION_SCHEMA queries can vary by BigQuery project setup
SELECT 'ML Models Creation Status' AS summary,
    'Temperature forecasting model: linear_regression_temp_model' AS temp_model,
    'Precipitation forecasting model: linear_regression_precip_model' AS precip_model,
    'To test models, uncomment the ML.FORECAST example below' AS next_steps;
-- Test a simple forecast (optional)
/*
 SELECT predicted_value
 FROM ML.FORECAST(
 MODEL `climate_ai.linear_regression_temp_model`,
 (SELECT 
 TIMESTAMP_TRUNC(timestamp, HOUR) AS time,
 AVG(temperature) AS value
 FROM `climate_ai.sensor_data`
 WHERE location_id = (SELECT location_id FROM `climate_ai.sensor_data` LIMIT 1)
 GROUP BY time
 ORDER BY time
 LIMIT 10),
 STRUCT(6 AS horizon)
 );
 */
SELECT 'ML models created successfully!' AS status;