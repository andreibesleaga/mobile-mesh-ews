-- ============================
-- Decision Engine View QA Checks
-- ============================
-- 1. Smoke check: basic row count
SELECT 'vw_decision_engine' AS view_name,
    COUNT(*) AS row_count
FROM `climate_ai.vw_decision_engine`;
-- 2. Distribution by severity
SELECT alert_level,
    COUNT(*) AS count_rows
FROM `climate_ai.vw_decision_engine`
GROUP BY alert_level
ORDER BY CASE
        alert_level
        WHEN 'CRITICAL' THEN 1
        WHEN 'WARNING' THEN 2
        ELSE 3
    END;
-- 3. Out-of-range value detection
SELECT *
FROM `climate_ai.vw_decision_engine`
WHERE (
        avg_temp < -90
        OR avg_temp > 60
    )
    OR (
        fc_temp_next6h < -90
        OR fc_temp_next6h > 60
    )
    OR (
        avg_precip < 0
        OR avg_precip > 500
    )
    OR (
        fc_precip_next6h < 0
        OR fc_precip_next6h > 500
    )
    OR (
        max_fire_index < 0
        OR max_fire_index > 1
    )
    OR (
        max_flood_index < 0
        OR max_flood_index > 1
    )
    OR (
        wildfire_risk_score < 0
        OR wildfire_risk_score > 100
    )
    OR (
        flood_risk_score < 0
        OR flood_risk_score > 100
    );
-- 4. Null forecast audit
SELECT *
FROM `climate_ai.vw_decision_engine`
WHERE fc_temp_next6h IS NULL
    OR fc_precip_next6h IS NULL
ORDER BY alert_level;
-- 5. Sample preview (top risk cases first)
SELECT location_id,
    lat,
    lon,
    risk_classification,
    alert_level,
    wildfire_risk_score,
    flood_risk_score,
    avg_temp,
    fc_temp_next6h,
    avg_precip,
    fc_precip_next6h,
    max_fire_index,
    max_flood_index,
    recommended_action
FROM `climate_ai.vw_decision_engine`
ORDER BY CASE
        alert_level
        WHEN 'CRITICAL' THEN 1
        WHEN 'WARNING' THEN 2
        ELSE 3
    END,
    GREATEST(wildfire_risk_score, flood_risk_score) DESC
LIMIT 10;