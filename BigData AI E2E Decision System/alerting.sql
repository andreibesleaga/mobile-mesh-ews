-- BigQuery SQL to trigger alerts based on thresholds and generate summaries using AI.GENERATE
-- It can be integrated into a decision-making system for climate AI applications and dashboards.
WITH recent_sensor AS (
    SELECT location_id,
        lat,
        lon,
        AVG(temperature) AS avg_temp,
        AVG(precipitation) AS avg_precip,
        AVG(pressure) AS avg_pressure
    FROM sensor_data
    WHERE timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 6 HOUR)
    GROUP BY location_id,
        lat,
        lon
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
        s.lat,
        s.lon,
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
        END AS risk_classification,
        CASE
            WHEN i.max_fire_index > 0.7
            AND s.avg_temp > 35 THEN 'CRITICAL'
            WHEN i.max_flood_index > 0.7
            AND s.avg_precip > 80 THEN 'CRITICAL'
            WHEN s.avg_temp > 30
            OR s.avg_precip > 50 THEN 'WARNING'
            ELSE 'NORMAL'
        END AS alert_level
)
SELECT *,
    AI.GENERATE(
        MODEL => 'gemini-pro',
        PROMPT => CONCAT(
            'Generate a short alert message for location ',
            location_id,
            ' with classification ',
            risk_classification,
            ', temperature ',
            CAST(avg_temp AS STRING),
            ', precipitation ',
            CAST(avg_precip AS STRING),
            ', fire index ',
            CAST(max_fire_index AS STRING),
            ', flood index ',
            CAST(max_flood_index AS STRING),
            '.'
        )
    ) AS alert_message
FROM decision_engine
ORDER BY alert_level DESC;