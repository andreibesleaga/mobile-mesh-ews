-- Optional: BigQuery SQL script to create and manage alerts for a mobile mesh EWS (Early Warning System)
-- PREREQUISITE: Run optimized_pipeline.sql first to create vw_decision_engine view
-- One-time setup
-- Needs optimized pipeline to be run first
-- This script creates a table to store alerts based on the decision engine's output
-- and sets up a scheduled insert to populate it with critical alerts.
-- Check if vw_decision_engine exists before proceeding
-- If this fails, run optimized_pipeline.sql first
SELECT COUNT(*) as view_check
FROM `climate_ai.vw_decision_engine`
LIMIT 1;
CREATE OR REPLACE TABLE `climate_ai.alerts` (
        inserted_at TIMESTAMP NOT NULL,
        location_id STRING NOT NULL,
        lat FLOAT64,
        lon FLOAT64,
        alert_level STRING NOT NULL,
        risk_classification STRING NOT NULL,
        wildfire_risk_score FLOAT64,
        flood_risk_score FLOAT64,
        alert_message STRING,
        recommended_action STRING,
        alert_expires_at TIMESTAMP
    ) PARTITION BY DATE(inserted_at) CLUSTER BY alert_level,
    location_id;
-- Populate from decision engine (to be run on a schedule)
INSERT INTO `climate_ai.alerts` (
        inserted_at,
        location_id,
        lat,
        lon,
        alert_level,
        risk_classification,
        wildfire_risk_score,
        flood_risk_score,
        alert_message,
        recommended_action,
        alert_expires_at
    )
SELECT CURRENT_TIMESTAMP() AS inserted_at,
    location_id,
    lat,
    lon,
    alert_level,
    risk_classification,
    wildfire_risk_score,
    flood_risk_score,
    alert_message,
    recommended_action,
    TIMESTAMP_ADD(CURRENT_TIMESTAMP(), INTERVAL 6 HOUR) AS alert_expires_at
FROM `climate_ai.vw_decision_engine`
WHERE alert_level IN ('CRITICAL', 'WARNING');