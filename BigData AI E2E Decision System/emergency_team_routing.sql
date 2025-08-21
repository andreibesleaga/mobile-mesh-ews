-- =========================================
-- Emergency Team Routing System
-- =========================================
-- Identifies imminent hazard zones requiring immediate emergency team
-- intervention based on real-time risk assessment and alert levels
-- =========================================
-- PRIMARY EMERGENCY TEAM ROUTING QUERY
-- =========================================
WITH imminent_hazard_analysis AS (
    SELECT location_id,
        lat,
        lon,
        risk_classification,
        alert_level,
        wildfire_risk_score,
        flood_risk_score,
        avg_temp,
        avg_precip,
        avg_pressure,
        fc_temp_next6h,
        fc_precip_next6h,
        max_fire_index,
        max_flood_index,
        latest_hour,
        recommended_action,
        -- Calculate imminent danger score (0-100)
        LEAST(
            100,
            GREATEST(
                0,
                -- Current risk level (40% weight)
                (
                    GREATEST(wildfire_risk_score, flood_risk_score) * 0.4
                ) + -- Alert severity (30% weight)  
                (
                    CASE
                        WHEN alert_level = 'CRITICAL' THEN 30
                        WHEN alert_level = 'WARNING' THEN 20
                        ELSE 5
                    END
                ) + -- Environmental accelerators (20% weight)
                (
                    CASE
                        WHEN avg_temp > 40
                        OR fc_temp_next6h > 40 THEN 15 -- Extreme heat
                        WHEN avg_temp > 35
                        OR fc_temp_next6h > 35 THEN 10 -- High heat
                        ELSE 0
                    END
                ) + (
                    CASE
                        WHEN avg_precip > 100
                        OR fc_precip_next6h > 100 THEN 15 -- Extreme precipitation
                        WHEN avg_precip > 80
                        OR fc_precip_next6h > 80 THEN 10 -- Heavy precipitation
                        ELSE 0
                    END
                ) + -- Pressure indicators (5% weight)
                (
                    CASE
                        WHEN avg_pressure < 990 THEN 5 -- Very low pressure (storm systems)
                        WHEN avg_pressure < 1000 THEN 3 -- Low pressure
                        ELSE 0
                    END
                ) + -- Satellite imagery confirmation (5% weight)
                (
                    CASE
                        WHEN max_fire_index > 0.8
                        OR max_flood_index > 0.8 THEN 5
                        WHEN max_fire_index > 0.6
                        OR max_flood_index > 0.6 THEN 3
                        ELSE 0
                    END
                )
            )
        ) AS imminent_danger_score,
        -- Determine primary hazard type
        CASE
            WHEN wildfire_risk_score > flood_risk_score THEN 'WILDFIRE'
            WHEN flood_risk_score > wildfire_risk_score THEN 'FLOOD'
            WHEN wildfire_risk_score = flood_risk_score
            AND wildfire_risk_score > 50 THEN 'MULTI_HAZARD'
            ELSE 'WEATHER_EMERGENCY'
        END AS primary_hazard_type,
        -- Calculate response time criticality
        CASE
            WHEN alert_level = 'CRITICAL'
            AND (
                wildfire_risk_score > 85
                OR flood_risk_score > 85
            ) THEN 'IMMEDIATE_RESPONSE_15MIN'
            WHEN alert_level = 'CRITICAL'
            AND (
                wildfire_risk_score > 70
                OR flood_risk_score > 70
            ) THEN 'URGENT_RESPONSE_30MIN'
            WHEN alert_level = 'CRITICAL' THEN 'PRIORITY_RESPONSE_1HR'
            WHEN alert_level = 'WARNING'
            AND (
                wildfire_risk_score > 80
                OR flood_risk_score > 80
            ) THEN 'URGENT_RESPONSE_30MIN'
            WHEN alert_level = 'WARNING' THEN 'SCHEDULED_RESPONSE_2HR'
            ELSE 'ROUTINE_MONITORING'
        END AS response_time_requirement
    FROM `climate_ai.vw_decision_engine`
    WHERE alert_level IN ('CRITICAL', 'WARNING') -- Only actionable alerts
),
team_allocation_analysis AS (
    SELECT *,
        -- Determine required team composition
        CASE
            primary_hazard_type
            WHEN 'WILDFIRE' THEN JSON_OBJECT(
                'fire_suppression_crews',
                CASE
                    WHEN imminent_danger_score > 80 THEN 3
                    WHEN imminent_danger_score > 60 THEN 2
                    ELSE 1
                END,
                'evacuation_coordinators',
                CASE
                    WHEN imminent_danger_score > 70 THEN 2
                    ELSE 1
                END,
                'medical_response_units',
                1,
                'incident_commanders',
                1,
                'communication_specialists',
                1,
                'estimated_total_personnel',
                CASE
                    WHEN imminent_danger_score > 80 THEN 25
                    WHEN imminent_danger_score > 60 THEN 18
                    ELSE 12
                END
            )
            WHEN 'FLOOD' THEN JSON_OBJECT(
                'water_rescue_teams',
                CASE
                    WHEN imminent_danger_score > 80 THEN 2
                    WHEN imminent_danger_score > 60 THEN 1
                    ELSE 1
                END,
                'evacuation_coordinators',
                CASE
                    WHEN imminent_danger_score > 70 THEN 3
                    ELSE 2
                END,
                'sandbag_deployment_crews',
                CASE
                    WHEN imminent_danger_score > 60 THEN 2
                    ELSE 1
                END,
                'medical_response_units',
                1,
                'incident_commanders',
                1,
                'estimated_total_personnel',
                CASE
                    WHEN imminent_danger_score > 80 THEN 22
                    WHEN imminent_danger_score > 60 THEN 16
                    ELSE 11
                END
            )
            WHEN 'MULTI_HAZARD' THEN JSON_OBJECT(
                'fire_suppression_crews',
                2,
                'water_rescue_teams',
                1,
                'evacuation_coordinators',
                3,
                'medical_response_units',
                2,
                'incident_commanders',
                2,
                'communication_specialists',
                2,
                'estimated_total_personnel',
                35
            )
            ELSE JSON_OBJECT(
                'emergency_response_teams',
                1,
                'medical_response_units',
                1,
                'incident_commanders',
                1,
                'estimated_total_personnel',
                8
            )
        END AS required_team_composition,
        -- Equipment requirements
        CASE
            primary_hazard_type
            WHEN 'WILDFIRE' THEN ARRAY [
        'Fire engines', 'Water tankers', 'Helicopter support', 'Evacuation buses', 
        'Medical ambulances', 'Communication equipment', 'Breathing apparatus'
      ]
            WHEN 'FLOOD' THEN ARRAY [
        'Rescue boats', 'High-water vehicles', 'Sandbags', 'Water pumps',
        'Evacuation buses', 'Medical ambulances', 'Emergency shelters'
      ]
            WHEN 'MULTI_HAZARD' THEN ARRAY [
        'Fire engines', 'Rescue boats', 'Helicopter support', 'Evacuation buses',
        'Medical ambulances', 'Mobile command center', 'Satellite communication'
      ]
            ELSE ARRAY [
        'Emergency response vehicles', 'Medical ambulances', 'Communication equipment'
      ]
        END AS required_equipment,
        -- Generate intervention strategy
        CONCAT(
            'EMERGENCY INTERVENTION REQUIRED: ',
            primary_hazard_type,
            ' at ',
            location_id,
            '. ',
            'Danger level: ',
            CAST(ROUND(imminent_danger_score, 1) AS STRING),
            '/100. ',
            'Response time: ',
            response_time_requirement,
            '. ',
            'Environmental factors: Temp ',
            CAST(ROUND(avg_temp, 1) AS STRING),
            '°C',
            CASE
                WHEN fc_temp_next6h > avg_temp + 3 THEN ' (rising to ' || CAST(ROUND(fc_temp_next6h, 1) AS STRING) || '°C)'
                ELSE ''
            END,
            ', Precip ',
            CAST(ROUND(avg_precip, 1) AS STRING),
            'mm',
            CASE
                WHEN fc_precip_next6h > avg_precip + 10 THEN ' (forecast ' || CAST(ROUND(fc_precip_next6h, 1) AS STRING) || 'mm)'
                ELSE ''
            END,
            '. Recommended action: ',
            recommended_action
        ) AS intervention_strategy
    FROM imminent_hazard_analysis
    WHERE imminent_danger_score >= 50 -- Only significant hazards
),
geographic_response_routing AS (
    SELECT *,
        -- Calculate response zones using geographic clustering
        ST_CLUSTERDBSCAN(ST_GEOGPOINT(lon, lat), 25000, 1) OVER () AS response_zone_id,
        -- Determine incident complexity level
        CASE
            WHEN imminent_danger_score >= 90 THEN 'TYPE_1_INCIDENT' -- National level response
            WHEN imminent_danger_score >= 80 THEN 'TYPE_2_INCIDENT' -- Regional level response  
            WHEN imminent_danger_score >= 70 THEN 'TYPE_3_INCIDENT' -- Local multi-agency
            WHEN imminent_danger_score >= 60 THEN 'TYPE_4_INCIDENT' -- Local single agency
            ELSE 'TYPE_5_INCIDENT' -- Single resource
        END AS incident_complexity_level,
        -- Evacuation zone estimation (radius in meters)
        CASE
            WHEN primary_hazard_type = 'WILDFIRE'
            AND imminent_danger_score > 80 THEN 5000
            WHEN primary_hazard_type = 'WILDFIRE'
            AND imminent_danger_score > 60 THEN 3000
            WHEN primary_hazard_type = 'WILDFIRE' THEN 1500
            WHEN primary_hazard_type = 'FLOOD'
            AND imminent_danger_score > 80 THEN 3000
            WHEN primary_hazard_type = 'FLOOD'
            AND imminent_danger_score > 60 THEN 2000
            WHEN primary_hazard_type = 'FLOOD' THEN 1000
            WHEN primary_hazard_type = 'MULTI_HAZARD' THEN 5000
            ELSE 500
        END AS evacuation_radius_meters
    FROM team_allocation_analysis
) -- =========================================
-- MAIN EMERGENCY TEAM ROUTING OUTPUT
-- =========================================
SELECT 'EMERGENCY_TEAM_DISPATCH' AS routing_type,
    ROW_NUMBER() OVER (
        ORDER BY imminent_danger_score DESC,
            CASE
                response_time_requirement
                WHEN 'IMMEDIATE_RESPONSE_15MIN' THEN 1
                WHEN 'URGENT_RESPONSE_30MIN' THEN 2
                WHEN 'PRIORITY_RESPONSE_1HR' THEN 3
                ELSE 4
            END
    ) AS dispatch_priority,
    location_id,
    lat,
    lon,
    primary_hazard_type,
    ROUND(imminent_danger_score, 1) AS danger_score,
    response_time_requirement,
    incident_complexity_level,
    required_team_composition,
    required_equipment,
    evacuation_radius_meters,
    intervention_strategy,
    response_zone_id,
    -- Current conditions summary
    STRUCT(
        avg_temp AS current_temp_c,
        fc_temp_next6h AS forecast_temp_c,
        avg_precip AS current_precip_mm,
        fc_precip_next6h AS forecast_precip_mm,
        avg_pressure AS pressure_hpa,
        wildfire_risk_score,
        flood_risk_score,
        alert_level
    ) AS situation_summary,
    -- Geographic data for routing systems
    CONCAT(
        'POINT(',
        CAST(lon AS STRING),
        ' ',
        CAST(lat AS STRING),
        ')'
    ) AS incident_location_wkt,
    -- Estimated civilian impact (population within evacuation radius)
    -- This would be calculated with actual population density data
    CASE
        WHEN evacuation_radius_meters >= 5000 THEN 'HIGH_POPULATION_IMPACT'
        WHEN evacuation_radius_meters >= 2000 THEN 'MODERATE_POPULATION_IMPACT'
        ELSE 'LIMITED_POPULATION_IMPACT'
    END AS estimated_population_impact,
    CURRENT_TIMESTAMP() AS dispatch_routing_generated
FROM geographic_response_routing
ORDER BY imminent_danger_score DESC,
    CASE
        response_time_requirement
        WHEN 'IMMEDIATE_RESPONSE_15MIN' THEN 1
        WHEN 'URGENT_RESPONSE_30MIN' THEN 2
        WHEN 'PRIORITY_RESPONSE_1HR' THEN 3
        ELSE 4
    END
LIMIT 15;
-- Top 15 emergency priorities
-- =========================================
-- EMERGENCY RESPONSE ANALYTICS
-- =========================================
-- Response time summary
SELECT 'RESPONSE_TIME_ANALYSIS' AS analysis_type,
    response_time_requirement,
    COUNT(*) AS incident_count,
    AVG(imminent_danger_score) AS avg_danger_score,
    STRING_AGG(DISTINCT primary_hazard_type) AS hazard_types,
    -- Estimated total personnel needed
    SUM(
        CAST(
            JSON_VALUE(
                required_team_composition,
                '$.estimated_total_personnel'
            ) AS INT64
        )
    ) AS total_personnel_needed
FROM geographic_response_routing
GROUP BY response_time_requirement
ORDER BY CASE
        response_time_requirement
        WHEN 'IMMEDIATE_RESPONSE_15MIN' THEN 1
        WHEN 'URGENT_RESPONSE_30MIN' THEN 2
        WHEN 'PRIORITY_RESPONSE_1HR' THEN 3
        WHEN 'SCHEDULED_RESPONSE_2HR' THEN 4
        ELSE 5
    END;
-- Hazard type distribution
SELECT 'HAZARD_TYPE_ANALYSIS' AS analysis_type,
    primary_hazard_type,
    COUNT(*) AS incident_count,
    AVG(imminent_danger_score) AS avg_danger_score,
    AVG(evacuation_radius_meters) AS avg_evacuation_radius,
    COUNT(
        CASE
            WHEN response_time_requirement LIKE '%IMMEDIATE%' THEN 1
        END
    ) AS immediate_response_count
FROM geographic_response_routing
GROUP BY primary_hazard_type
ORDER BY avg_danger_score DESC;
-- Response zone clustering
SELECT 'RESPONSE_ZONE_ANALYSIS' AS analysis_type,
    response_zone_id,
    COUNT(*) AS incidents_in_zone,
    AVG(lat) AS zone_center_lat,
    AVG(lon) AS zone_center_lon,
    MAX(imminent_danger_score) AS highest_danger_score,
    STRING_AGG(DISTINCT primary_hazard_type) AS hazard_types_in_zone,
    MAX(
        CASE
            response_time_requirement
            WHEN 'IMMEDIATE_RESPONSE_15MIN' THEN 1
            WHEN 'URGENT_RESPONSE_30MIN' THEN 2
            WHEN 'PRIORITY_RESPONSE_1HR' THEN 3
            ELSE 4
        END
    ) AS highest_urgency_level
FROM geographic_response_routing
WHERE response_zone_id IS NOT NULL
GROUP BY response_zone_id
HAVING COUNT(*) >= 1
ORDER BY highest_danger_score DESC,
    highest_urgency_level;
-- =========================================
-- RESOURCE ALLOCATION SUMMARY
-- =========================================
-- Equipment needs aggregation
SELECT 'EQUIPMENT_NEEDS' AS resource_type,
    equipment_item,
    COUNT(*) AS incidents_requiring,
    SUM(
        CASE
            WHEN response_time_requirement LIKE '%IMMEDIATE%' THEN 1
            ELSE 0
        END
    ) AS immediate_needs,
    AVG(imminent_danger_score) AS avg_incident_severity
FROM geographic_response_routing,
    UNNEST(required_equipment) AS equipment_item
GROUP BY equipment_item
ORDER BY incidents_requiring DESC;
-- Personnel allocation summary  
SELECT 'PERSONNEL_ALLOCATION' AS resource_type,
    incident_complexity_level,
    COUNT(*) AS incident_count,
    SUM(
        CAST(
            JSON_VALUE(
                required_team_composition,
                '$.estimated_total_personnel'
            ) AS INT64
        )
    ) AS total_personnel_needed,
    AVG(imminent_danger_score) AS avg_danger_score,
    MAX(response_time_requirement) AS most_urgent_response_time
FROM geographic_response_routing
GROUP BY incident_complexity_level
ORDER BY total_personnel_needed DESC;