-- =========================================
-- Mobile Sensor Routing System
-- =========================================
-- Identifies optimal locations for deploying mobile sensors based on
-- data gaps, risk levels, and measurement reliability needs
-- =========================================
-- PRIMARY MOBILE SENSOR ROUTING QUERY
-- =========================================
WITH sensor_coverage_analysis AS (
    SELECT location_id,
        lat,
        lon,
        readings_count,
        avg_temp,
        avg_precip,
        avg_pressure,
        wildfire_risk_score,
        flood_risk_score,
        risk_classification,
        alert_level,
        latest_hour,
        -- Calculate data quality indicators
        CASE
            WHEN readings_count < 5 THEN 'INSUFFICIENT_DATA'
            WHEN readings_count < 15 THEN 'LIMITED_DATA'
            WHEN readings_count < 30 THEN 'ADEQUATE_DATA'
            ELSE 'GOOD_DATA'
        END AS data_quality_level,
        -- Calculate time since last reading
        TIMESTAMP_DIFF(CURRENT_TIMESTAMP(), latest_hour, HOUR) AS hours_since_reading,
        -- Risk-weighted priority score
        (wildfire_risk_score + flood_risk_score) / 2 AS combined_risk_score,
        -- Data freshness penalty
        CASE
            WHEN TIMESTAMP_DIFF(CURRENT_TIMESTAMP(), latest_hour, HOUR) > 12 THEN 50
            WHEN TIMESTAMP_DIFF(CURRENT_TIMESTAMP(), latest_hour, HOUR) > 6 THEN 25
            WHEN TIMESTAMP_DIFF(CURRENT_TIMESTAMP(), latest_hour, HOUR) > 3 THEN 10
            ELSE 0
        END AS freshness_penalty
    FROM `climate_ai.vw_decision_engine`
),
priority_scoring AS (
    SELECT *,
        -- Calculate deployment priority score (0-100)
        LEAST(
            100,
            GREATEST(
                0,
                -- Base risk score (40% weight)
                (combined_risk_score * 0.4) + -- Data insufficiency bonus (30% weight)
                (
                    CASE
                        WHEN data_quality_level = 'INSUFFICIENT_DATA' THEN 30
                        WHEN data_quality_level = 'LIMITED_DATA' THEN 20
                        WHEN data_quality_level = 'ADEQUATE_DATA' THEN 10
                        ELSE 0
                    END
                ) + -- Alert level urgency (20% weight)
                (
                    CASE
                        WHEN alert_level = 'CRITICAL' THEN 20
                        WHEN alert_level = 'WARNING' THEN 15
                        ELSE 5
                    END
                ) + -- Freshness penalty (10% weight)
                (freshness_penalty * 0.1)
            )
        ) AS deployment_priority_score,
        -- Generate deployment reasoning
        CONCAT(
            'Location needs mobile sensor deployment due to: ',
            CASE
                WHEN data_quality_level = 'INSUFFICIENT_DATA' THEN 'Critical data gaps (< 5 readings), '
                WHEN data_quality_level = 'LIMITED_DATA' THEN 'Limited data coverage (< 15 readings), '
                ELSE ''
            END,
            CASE
                WHEN hours_since_reading > 12 THEN 'Stale data (>' || CAST(hours_since_reading AS STRING) || 'h old), '
                WHEN hours_since_reading > 6 THEN 'Aging data (>' || CAST(hours_since_reading AS STRING) || 'h old), '
                ELSE ''
            END,
            CASE
                WHEN combined_risk_score > 70 THEN 'High risk conditions (score: ' || CAST(ROUND(combined_risk_score, 1) AS STRING) || '), '
                WHEN combined_risk_score > 50 THEN 'Elevated risk (score: ' || CAST(ROUND(combined_risk_score, 1) AS STRING) || '), '
                ELSE ''
            END,
            'Current alert level: ',
            alert_level
        ) AS deployment_reasoning
    FROM sensor_coverage_analysis
),
geographic_clustering AS (
    SELECT *,
        -- Calculate geographic clusters for efficient routing
        ST_CLUSTERDBSCAN(ST_GEOGPOINT(lon, lat), 50000, 2) OVER () AS cluster_id,
        -- Estimate deployment logistics
        CASE
            WHEN deployment_priority_score >= 80 THEN 'IMMEDIATE'
            WHEN deployment_priority_score >= 60 THEN 'URGENT'
            WHEN deployment_priority_score >= 40 THEN 'SCHEDULED'
            ELSE 'ROUTINE'
        END AS deployment_urgency,
        -- Recommended sensor type
        CASE
            WHEN wildfire_risk_score > flood_risk_score
            AND wildfire_risk_score > 60 THEN 'FIRE_DETECTION_SUITE'
            WHEN flood_risk_score > wildfire_risk_score
            AND flood_risk_score > 60 THEN 'FLOOD_MONITORING_SUITE'
            WHEN combined_risk_score > 50 THEN 'MULTI_HAZARD_SUITE'
            ELSE 'STANDARD_WEATHER_STATION'
        END AS recommended_sensor_type,
        -- Estimated deployment duration
        CASE
            WHEN alert_level = 'CRITICAL' THEN '72_HOURS'
            WHEN alert_level = 'WARNING' THEN '7_DAYS'
            WHEN data_quality_level = 'INSUFFICIENT_DATA' THEN '30_DAYS'
            ELSE '14_DAYS'
        END AS suggested_deployment_duration
    FROM priority_scoring
    WHERE deployment_priority_score >= 30 -- Filter out low-priority locations
) -- =========================================
-- MAIN MOBILE SENSOR ROUTING OUTPUT
-- =========================================
SELECT 'MOBILE_SENSOR_DEPLOYMENT' AS routing_type,
    ROW_NUMBER() OVER (
        ORDER BY deployment_priority_score DESC,
            combined_risk_score DESC
    ) AS deployment_rank,
    location_id,
    lat,
    lon,
    ROUND(deployment_priority_score, 1) AS priority_score,
    deployment_urgency,
    recommended_sensor_type,
    suggested_deployment_duration,
    data_quality_level,
    CONCAT(ROUND(combined_risk_score, 1), '/100') AS risk_score,
    alert_level,
    readings_count AS current_readings,
    hours_since_reading,
    deployment_reasoning,
    cluster_id AS deployment_cluster,
    -- Geographic coordinates for routing
    CONCAT(
        'POINT(',
        CAST(lon AS STRING),
        ' ',
        CAST(lat AS STRING),
        ')'
    ) AS location_wkt,
    -- Distance estimation (requires base station coordinates)
    -- ST_DISTANCE(ST_GEOGPOINT(lon, lat), ST_GEOGPOINT(-122.4194, 37.7749)) / 1000 AS distance_from_base_km,
    CURRENT_TIMESTAMP() AS routing_generated
FROM geographic_clustering
ORDER BY deployment_priority_score DESC,
    combined_risk_score DESC
LIMIT 20;
-- Top 20 deployment priorities
-- =========================================
-- DEPLOYMENT SUMMARY ANALYTICS
-- =========================================
-- Deployment statistics by urgency
WITH sensor_coverage_analysis AS (
    SELECT location_id,
        lat,
        lon,
        readings_count,
        avg_temp,
        avg_precip,
        avg_pressure,
        wildfire_risk_score,
        flood_risk_score,
        risk_classification,
        alert_level,
        latest_hour,
        -- Calculate data quality indicators
        CASE
            WHEN readings_count < 5 THEN 'INSUFFICIENT_DATA'
            WHEN readings_count < 15 THEN 'LIMITED_DATA'
            WHEN readings_count < 30 THEN 'ADEQUATE_DATA'
            ELSE 'GOOD_DATA'
        END AS data_quality_level,
        -- Calculate time since last reading
        TIMESTAMP_DIFF(CURRENT_TIMESTAMP(), latest_hour, HOUR) AS hours_since_reading,
        -- Risk-weighted priority score
        (wildfire_risk_score + flood_risk_score) / 2 AS combined_risk_score,
        -- Data freshness penalty
        CASE
            WHEN TIMESTAMP_DIFF(CURRENT_TIMESTAMP(), latest_hour, HOUR) > 12 THEN 50
            WHEN TIMESTAMP_DIFF(CURRENT_TIMESTAMP(), latest_hour, HOUR) > 6 THEN 25
            WHEN TIMESTAMP_DIFF(CURRENT_TIMESTAMP(), latest_hour, HOUR) > 3 THEN 10
            ELSE 0
        END AS freshness_penalty
    FROM `climate_ai.vw_decision_engine`
),
priority_scoring AS (
    SELECT *,
        -- Calculate deployment priority score (0-100)
        LEAST(
            100,
            GREATEST(
                0,
                -- Base risk score (40% weight)
                (combined_risk_score * 0.4) + -- Data insufficiency bonus (30% weight)
                (
                    CASE
                        WHEN data_quality_level = 'INSUFFICIENT_DATA' THEN 30
                        WHEN data_quality_level = 'LIMITED_DATA' THEN 20
                        WHEN data_quality_level = 'ADEQUATE_DATA' THEN 10
                        ELSE 0
                    END
                ) + -- Alert level urgency (20% weight)
                (
                    CASE
                        WHEN alert_level = 'CRITICAL' THEN 20
                        WHEN alert_level = 'WARNING' THEN 15
                        ELSE 5
                    END
                ) + -- Freshness penalty (10% weight)
                (freshness_penalty * 0.1)
            )
        ) AS deployment_priority_score
    FROM sensor_coverage_analysis
),
geographic_clustering AS (
    SELECT *,
        -- Calculate geographic clusters for efficient routing
        ST_CLUSTERDBSCAN(ST_GEOGPOINT(lon, lat), 50000, 2) OVER () AS cluster_id,
        -- Estimate deployment logistics
        CASE
            WHEN deployment_priority_score >= 80 THEN 'IMMEDIATE'
            WHEN deployment_priority_score >= 60 THEN 'URGENT'
            WHEN deployment_priority_score >= 40 THEN 'SCHEDULED'
            ELSE 'ROUTINE'
        END AS deployment_urgency,
        -- Recommended sensor type
        CASE
            WHEN wildfire_risk_score > flood_risk_score
            AND wildfire_risk_score > 60 THEN 'FIRE_DETECTION_SUITE'
            WHEN flood_risk_score > wildfire_risk_score
            AND flood_risk_score > 60 THEN 'FLOOD_MONITORING_SUITE'
            WHEN combined_risk_score > 50 THEN 'MULTI_HAZARD_SUITE'
            ELSE 'STANDARD_WEATHER_STATION'
        END AS recommended_sensor_type,
        -- Estimated deployment duration
        CASE
            WHEN alert_level = 'CRITICAL' THEN '72_HOURS'
            WHEN alert_level = 'WARNING' THEN '7_DAYS'
            WHEN data_quality_level = 'INSUFFICIENT_DATA' THEN '30_DAYS'
            ELSE '14_DAYS'
        END AS suggested_deployment_duration
    FROM priority_scoring
    WHERE deployment_priority_score >= 30 -- Filter out low-priority locations
)
SELECT 'DEPLOYMENT_SUMMARY' AS summary_type,
    deployment_urgency,
    COUNT(*) AS locations_count,
    AVG(deployment_priority_score) AS avg_priority_score,
    AVG(combined_risk_score) AS avg_risk_score,
    STRING_AGG(DISTINCT recommended_sensor_type) AS sensor_types_needed
FROM geographic_clustering
GROUP BY deployment_urgency
ORDER BY CASE
        deployment_urgency
        WHEN 'IMMEDIATE' THEN 1
        WHEN 'URGENT' THEN 2
        WHEN 'SCHEDULED' THEN 3
        ELSE 4
    END;
-- =========================================
-- CLUSTER-BASED ROUTING OPTIMIZATION
-- =========================================
WITH sensor_coverage_analysis AS (
    SELECT location_id,
        lat,
        lon,
        readings_count,
        wildfire_risk_score,
        flood_risk_score,
        alert_level,
        latest_hour,
        CASE
            WHEN readings_count < 5 THEN 'INSUFFICIENT_DATA'
            WHEN readings_count < 15 THEN 'LIMITED_DATA'
            WHEN readings_count < 30 THEN 'ADEQUATE_DATA'
            ELSE 'GOOD_DATA'
        END AS data_quality_level,
        TIMESTAMP_DIFF(CURRENT_TIMESTAMP(), latest_hour, HOUR) AS hours_since_reading,
        (wildfire_risk_score + flood_risk_score) / 2 AS combined_risk_score,
        CASE
            WHEN TIMESTAMP_DIFF(CURRENT_TIMESTAMP(), latest_hour, HOUR) > 12 THEN 50
            WHEN TIMESTAMP_DIFF(CURRENT_TIMESTAMP(), latest_hour, HOUR) > 6 THEN 25
            WHEN TIMESTAMP_DIFF(CURRENT_TIMESTAMP(), latest_hour, HOUR) > 3 THEN 10
            ELSE 0
        END AS freshness_penalty
    FROM `climate_ai.vw_decision_engine`
),
priority_scoring AS (
    SELECT *,
        LEAST(
            100,
            GREATEST(
                0,
                (combined_risk_score * 0.4) + (
                    CASE
                        WHEN data_quality_level = 'INSUFFICIENT_DATA' THEN 30
                        WHEN data_quality_level = 'LIMITED_DATA' THEN 20
                        WHEN data_quality_level = 'ADEQUATE_DATA' THEN 10
                        ELSE 0
                    END
                ) + (
                    CASE
                        WHEN alert_level = 'CRITICAL' THEN 20
                        WHEN alert_level = 'WARNING' THEN 15
                        ELSE 5
                    END
                ) + (freshness_penalty * 0.1)
            )
        ) AS deployment_priority_score
    FROM sensor_coverage_analysis
),
geographic_clustering AS (
    SELECT *,
        ST_CLUSTERDBSCAN(ST_GEOGPOINT(lon, lat), 50000, 2) OVER () AS cluster_id,
        CASE
            WHEN deployment_priority_score >= 80 THEN 'IMMEDIATE'
            WHEN deployment_priority_score >= 60 THEN 'URGENT'
            WHEN deployment_priority_score >= 40 THEN 'SCHEDULED'
            ELSE 'ROUTINE'
        END AS deployment_urgency
    FROM priority_scoring
    WHERE deployment_priority_score >= 30
)
SELECT 'ROUTING_CLUSTERS' AS analysis_type,
    cluster_id,
    COUNT(*) AS locations_in_cluster,
    AVG(lat) AS cluster_center_lat,
    AVG(lon) AS cluster_center_lon,
    AVG(deployment_priority_score) AS avg_cluster_priority,
    MAX(deployment_urgency) AS highest_urgency,
    STRING_AGG(
        location_id
        ORDER BY deployment_priority_score DESC
        LIMIT 3
    ) AS top_locations
FROM geographic_clustering
WHERE cluster_id IS NOT NULL
GROUP BY cluster_id
HAVING COUNT(*) >= 2 -- Only show clusters with multiple locations
ORDER BY avg_cluster_priority DESC;
-- =========================================
-- EQUIPMENT PLANNING SUMMARY
-- =========================================
WITH sensor_coverage_analysis AS (
    SELECT location_id,
        lat,
        lon,
        readings_count,
        wildfire_risk_score,
        flood_risk_score,
        alert_level,
        latest_hour,
        CASE
            WHEN readings_count < 5 THEN 'INSUFFICIENT_DATA'
            WHEN readings_count < 15 THEN 'LIMITED_DATA'
            WHEN readings_count < 30 THEN 'ADEQUATE_DATA'
            ELSE 'GOOD_DATA'
        END AS data_quality_level,
        TIMESTAMP_DIFF(CURRENT_TIMESTAMP(), latest_hour, HOUR) AS hours_since_reading,
        (wildfire_risk_score + flood_risk_score) / 2 AS combined_risk_score,
        CASE
            WHEN TIMESTAMP_DIFF(CURRENT_TIMESTAMP(), latest_hour, HOUR) > 12 THEN 50
            WHEN TIMESTAMP_DIFF(CURRENT_TIMESTAMP(), latest_hour, HOUR) > 6 THEN 25
            WHEN TIMESTAMP_DIFF(CURRENT_TIMESTAMP(), latest_hour, HOUR) > 3 THEN 10
            ELSE 0
        END AS freshness_penalty
    FROM `climate_ai.vw_decision_engine`
),
priority_scoring AS (
    SELECT *,
        LEAST(
            100,
            GREATEST(
                0,
                (combined_risk_score * 0.4) + (
                    CASE
                        WHEN data_quality_level = 'INSUFFICIENT_DATA' THEN 30
                        WHEN data_quality_level = 'LIMITED_DATA' THEN 20
                        WHEN data_quality_level = 'ADEQUATE_DATA' THEN 10
                        ELSE 0
                    END
                ) + (
                    CASE
                        WHEN alert_level = 'CRITICAL' THEN 20
                        WHEN alert_level = 'WARNING' THEN 15
                        ELSE 5
                    END
                ) + (freshness_penalty * 0.1)
            )
        ) AS deployment_priority_score
    FROM sensor_coverage_analysis
),
geographic_clustering AS (
    SELECT *,
        CASE
            WHEN deployment_priority_score >= 80 THEN 'IMMEDIATE'
            WHEN deployment_priority_score >= 60 THEN 'URGENT'
            WHEN deployment_priority_score >= 40 THEN 'SCHEDULED'
            ELSE 'ROUTINE'
        END AS deployment_urgency,
        CASE
            WHEN wildfire_risk_score > flood_risk_score
            AND wildfire_risk_score > 60 THEN 'FIRE_DETECTION_SUITE'
            WHEN flood_risk_score > wildfire_risk_score
            AND flood_risk_score > 60 THEN 'FLOOD_MONITORING_SUITE'
            WHEN combined_risk_score > 50 THEN 'MULTI_HAZARD_SUITE'
            ELSE 'STANDARD_WEATHER_STATION'
        END AS recommended_sensor_type,
        CASE
            WHEN alert_level = 'CRITICAL' THEN '72_HOURS'
            WHEN alert_level = 'WARNING' THEN '7_DAYS'
            WHEN data_quality_level = 'INSUFFICIENT_DATA' THEN '30_DAYS'
            ELSE '14_DAYS'
        END AS suggested_deployment_duration
    FROM priority_scoring
    WHERE deployment_priority_score >= 30
)
SELECT 'EQUIPMENT_PLANNING' AS planning_type,
    recommended_sensor_type,
    COUNT(*) AS units_needed,
    SUM(
        CASE
            WHEN deployment_urgency = 'IMMEDIATE' THEN 1
            ELSE 0
        END
    ) AS immediate_deployments,
    AVG(deployment_priority_score) AS avg_priority,
    -- Estimated deployment cost (example rates)
    COUNT(*) * CASE
        WHEN recommended_sensor_type = 'FIRE_DETECTION_SUITE' THEN 15000
        WHEN recommended_sensor_type = 'FLOOD_MONITORING_SUITE' THEN 12000
        WHEN recommended_sensor_type = 'MULTI_HAZARD_SUITE' THEN 20000
        ELSE 8000
    END AS estimated_total_cost_usd
FROM geographic_clustering
GROUP BY recommended_sensor_type
ORDER BY units_needed DESC;
-- =========================================
-- DURATION-BASED PLANNING
-- =========================================
WITH sensor_coverage_analysis AS (
    SELECT location_id,
        readings_count,
        wildfire_risk_score,
        flood_risk_score,
        alert_level,
        latest_hour,
        CASE
            WHEN readings_count < 5 THEN 'INSUFFICIENT_DATA'
            WHEN readings_count < 15 THEN 'LIMITED_DATA'
            WHEN readings_count < 30 THEN 'ADEQUATE_DATA'
            ELSE 'GOOD_DATA'
        END AS data_quality_level,
        TIMESTAMP_DIFF(CURRENT_TIMESTAMP(), latest_hour, HOUR) AS hours_since_reading,
        (wildfire_risk_score + flood_risk_score) / 2 AS combined_risk_score,
        CASE
            WHEN TIMESTAMP_DIFF(CURRENT_TIMESTAMP(), latest_hour, HOUR) > 12 THEN 50
            WHEN TIMESTAMP_DIFF(CURRENT_TIMESTAMP(), latest_hour, HOUR) > 6 THEN 25
            WHEN TIMESTAMP_DIFF(CURRENT_TIMESTAMP(), latest_hour, HOUR) > 3 THEN 10
            ELSE 0
        END AS freshness_penalty
    FROM `climate_ai.vw_decision_engine`
),
priority_scoring AS (
    SELECT *,
        LEAST(
            100,
            GREATEST(
                0,
                (combined_risk_score * 0.4) + (
                    CASE
                        WHEN data_quality_level = 'INSUFFICIENT_DATA' THEN 30
                        WHEN data_quality_level = 'LIMITED_DATA' THEN 20
                        WHEN data_quality_level = 'ADEQUATE_DATA' THEN 10
                        ELSE 0
                    END
                ) + (
                    CASE
                        WHEN alert_level = 'CRITICAL' THEN 20
                        WHEN alert_level = 'WARNING' THEN 15
                        ELSE 5
                    END
                ) + (freshness_penalty * 0.1)
            )
        ) AS deployment_priority_score
    FROM sensor_coverage_analysis
),
geographic_clustering AS (
    SELECT *,
        CASE
            WHEN alert_level = 'CRITICAL' THEN '72_HOURS'
            WHEN alert_level = 'WARNING' THEN '7_DAYS'
            WHEN data_quality_level = 'INSUFFICIENT_DATA' THEN '30_DAYS'
            ELSE '14_DAYS'
        END AS suggested_deployment_duration
    FROM priority_scoring
    WHERE deployment_priority_score >= 30
)
SELECT 'DURATION_PLANNING' AS planning_type,
    suggested_deployment_duration,
    COUNT(*) AS deployments_count,
    AVG(deployment_priority_score) AS avg_priority,
    -- Calculate total sensor-days needed
    COUNT(*) * CASE
        WHEN suggested_deployment_duration = '72_HOURS' THEN 3
        WHEN suggested_deployment_duration = '7_DAYS' THEN 7
        WHEN suggested_deployment_duration = '14_DAYS' THEN 14
        WHEN suggested_deployment_duration = '30_DAYS' THEN 30
        ELSE 14
    END AS total_sensor_days_needed
FROM geographic_clustering
GROUP BY suggested_deployment_duration
ORDER BY total_sensor_days_needed DESC;