-- Optional: BigQuery SQL script to create and manage alerts for a mobile mesh EWS (Early Warning System)
-- One-time setup
CREATE TABLE IF NOT EXISTS `climate_ai.alerts` (
    inserted_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(),
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
-- Scheduled insert (e.g., every 15 minutes)
INSERT INTO `climate_ai.alerts` (
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
SELECT location_id,
    lat,
    lon,
    alert_level,
    risk_classification,
    wildfire_risk_score,
    flood_risk_score,
    alert_message,
    recommended_action,
    alert_expires_at
FROM `climate_ai.vw_decision_engine`
WHERE alert_level IN ('CRITICAL', 'WARNING');