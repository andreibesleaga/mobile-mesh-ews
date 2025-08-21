-- =========================================
-- Climate AI Export Reports with AI.GENERATE
-- =========================================
-- Innovative AI-powered export system for climate emergency management
-- Generates custom reports, summaries, and actionable intelligence
-- =========================================
-- 📊 EXECUTIVE DASHBOARD EXPORT
-- =========================================
-- Create comprehensive executive summary table
CREATE OR REPLACE TABLE `climate_ai.executive_reports` AS WITH risk_overview AS (
        SELECT COUNT(*) as total_locations,
            COUNT(
                CASE
                    WHEN alert_level = 'CRITICAL' THEN 1
                END
            ) as critical_alerts,
            COUNT(
                CASE
                    WHEN alert_level = 'WARNING' THEN 1
                END
            ) as warning_alerts,
            AVG(wildfire_risk_score) as avg_wildfire_risk,
            AVG(flood_risk_score) as avg_flood_risk,
            MAX(latest_hour) as last_update
        FROM `climate_ai.vw_decision_engine`
    ),
    ai_executive_summary AS (
        SELECT ML.GENERATE_TEXT_LLM(
                prompt => CONCAT(
                    'Generate an executive summary for a climate emergency operations center. Current status: ',
                    total_locations,
                    ' monitoring locations, ',
                    critical_alerts,
                    ' critical alerts, ',
                    warning_alerts,
                    ' warning alerts. ',
                    'Average wildfire risk: ',
                    CAST(ROUND(avg_wildfire_risk, 1) AS STRING),
                    '/100, ',
                    'Average flood risk: ',
                    CAST(ROUND(avg_flood_risk, 1) AS STRING),
                    '/100. ',
                    'Last updated: ',
                    CAST(last_update AS STRING),
                    '. ',
                    'Provide: 1) Overall situation assessment, 2) Top 3 priorities, 3) Resource allocation recommendation. ',
                    'Format as professional briefing, 150 words max.'
                ),
                connection_id => 'projects/YOUR_PROJECT_ID/locations/us-central1/connections/gemini'
            ) AS executive_summary,
            *
        FROM risk_overview
    )
SELECT 'EXECUTIVE_DASHBOARD' as report_type,
    executive_summary,
    total_locations,
    critical_alerts,
    warning_alerts,
    avg_wildfire_risk,
    avg_flood_risk,
    last_update,
    CURRENT_TIMESTAMP() as report_generated
FROM ai_executive_summary;
-- =========================================
-- 🌍 GEOGRAPHIC INTELLIGENCE EXPORT
-- =========================================
-- Create location-specific intelligence reports
CREATE OR REPLACE TABLE `climate_ai.geographic_intelligence` AS WITH location_analysis AS (
        SELECT location_id,
            lat,
            lon,
            risk_classification,
            alert_level,
            wildfire_risk_score,
            flood_risk_score,
            avg_temp,
            avg_precip,
            fc_temp_next6h,
            fc_precip_next6h,
            -- Geographic context generation
            ML.GENERATE_TEXT_LLM(
                prompt => CONCAT(
                    'You are a geographic analyst. Analyze location ',
                    location_id,
                    ' at coordinates (',
                    CAST(lat AS STRING),
                    ', ',
                    CAST(lon AS STRING),
                    '). ',
                    'Current conditions: ',
                    risk_classification,
                    ', temp: ',
                    CAST(avg_temp AS STRING),
                    '°C, ',
                    'precipitation: ',
                    CAST(avg_precip AS STRING),
                    'mm. ',
                    '6h forecast: temp ',
                    CAST(fc_temp_next6h AS STRING),
                    '°C, precip ',
                    CAST(fc_precip_next6h AS STRING),
                    'mm. ',
                    'Provide: 1) Geographic risk factors, 2) Terrain considerations, 3) Population impact assessment. ',
                    'Be specific about elevation, water bodies, urban density if determinable from coordinates.'
                ),
                connection_id => 'projects/YOUR_PROJECT_ID/locations/us-central1/connections/gemini'
            ) AS geographic_context,
            -- Operational recommendations
            ML.GENERATE_TEXT_LLM(
                prompt => CONCAT(
                    'Generate operational recommendations for location ',
                    location_id,
                    ' with current alert level: ',
                    alert_level,
                    ' and risk: ',
                    risk_classification,
                    '. ',
                    'Consider wildfire risk score: ',
                    CAST(wildfire_risk_score AS STRING),
                    ' and flood risk score: ',
                    CAST(flood_risk_score AS STRING),
                    '. ',
                    'Provide specific, actionable recommendations in JSON format: ',
                    '{"immediate_actions": ["action1", "action2"], "equipment_needed": ["item1", "item2"], ',
                    '"personnel_required": number, "estimated_duration_hours": number, "priority_ranking": "1-10"}. ',
                    'JSON only, no additional text.'
                ),
                connection_id => 'projects/YOUR_PROJECT_ID/locations/us-central1/connections/gemini'
            ) AS operational_recommendations
        FROM `climate_ai.vw_decision_engine`
        WHERE alert_level IN ('CRITICAL', 'WARNING')
    )
SELECT 'GEOGRAPHIC_INTEL' as report_type,
    location_id,
    CONCAT(
        'POINT(',
        CAST(lon AS STRING),
        ' ',
        CAST(lat AS STRING),
        ')'
    ) as location_wkt,
    risk_classification,
    alert_level,
    geographic_context,
    operational_recommendations,
    wildfire_risk_score,
    flood_risk_score,
    CURRENT_TIMESTAMP() as report_generated
FROM location_analysis;
-- =========================================
-- 📈 PREDICTIVE ANALYTICS EXPORT  
-- =========================================
-- Create AI-powered trend analysis and predictions
CREATE OR REPLACE TABLE `climate_ai.predictive_analytics` AS WITH trend_analysis AS (
        SELECT location_id,
            COUNT(*) as data_points,
            AVG(avg_temp) as avg_temperature,
            AVG(avg_precip) as avg_precipitation,
            AVG(avg_pressure) as avg_pressure,
            STDDEV(avg_temp) as temp_volatility,
            STDDEV(avg_precip) as precip_volatility,
            MAX(wildfire_risk_score) as peak_wildfire_risk,
            MAX(flood_risk_score) as peak_flood_risk
        FROM `climate_ai.vw_decision_engine`
        GROUP BY location_id
    ),
    ai_predictions AS (
        SELECT location_id,
            ML.GENERATE_TEXT_LLM(
                prompt => CONCAT(
                    'You are a climate data scientist analyzing location ',
                    location_id,
                    '. ',
                    'Data shows: Average temp ',
                    CAST(ROUND(avg_temperature, 1) AS STRING),
                    '°C, ',
                    'precipitation ',
                    CAST(ROUND(avg_precipitation, 1) AS STRING),
                    'mm, ',
                    'pressure ',
                    CAST(ROUND(avg_pressure, 1) AS STRING),
                    'hPa. ',
                    'Temperature volatility: ',
                    CAST(ROUND(temp_volatility, 2) AS STRING),
                    ', ',
                    'precipitation volatility: ',
                    CAST(ROUND(precip_volatility, 2) AS STRING),
                    '. ',
                    'Peak wildfire risk: ',
                    CAST(peak_wildfire_risk AS STRING),
                    ', ',
                    'peak flood risk: ',
                    CAST(peak_flood_risk AS STRING),
                    '. ',
                    'Provide 24-48 hour outlook with confidence levels and key risk indicators to monitor.'
                ),
                connection_id => 'projects/YOUR_PROJECT_ID/locations/us-central1/connections/gemini'
            ) AS climate_forecast,
            ML.GENERATE_TEXT_LLM(
                prompt => CONCAT(
                    'Based on climate volatility data for ',
                    location_id,
                    ', generate a JSON risk assessment: ',
                    '{"stability_index": "stable|moderate|volatile", "confidence_level": "0-100", ',
                    '"primary_risk": "wildfire|flood|heat|storm", "monitoring_frequency": "hourly|4hour|daily", ',
                    '"alert_threshold_adjustment": "+10|-10|0", "resource_preposition": "yes|no"}. ',
                    'Temperature volatility: ',
                    CAST(ROUND(temp_volatility, 2) AS STRING),
                    ', ',
                    'precipitation volatility: ',
                    CAST(ROUND(precip_volatility, 2) AS STRING),
                    '. ',
                    'JSON only.'
                ),
                connection_id => 'projects/YOUR_PROJECT_ID/locations/us-central1/connections/gemini'
            ) AS risk_adjustment_json,
            *
        FROM trend_analysis
    )
SELECT 'PREDICTIVE_ANALYTICS' as report_type,
    location_id,
    climate_forecast,
    risk_adjustment_json,
    avg_temperature,
    avg_precipitation,
    temp_volatility,
    precip_volatility,
    peak_wildfire_risk,
    peak_flood_risk,
    CURRENT_TIMESTAMP() as report_generated
FROM ai_predictions;
-- =========================================
-- 🚨 CRISIS COMMUNICATION EXPORT
-- =========================================
-- Generate multi-channel crisis communication content
CREATE OR REPLACE TABLE `climate_ai.crisis_communications` AS WITH critical_situations AS (
        SELECT location_id,
            risk_classification,
            alert_level,
            avg_temp,
            avg_precip,
            wildfire_risk_score,
            flood_risk_score,
            recommended_action
        FROM `climate_ai.vw_decision_engine`
        WHERE alert_level = 'CRITICAL'
    ),
    ai_communications AS (
        SELECT location_id,
            -- Twitter/X Post (280 chars)
            ML.GENERATE_TEXT_LLM(
                prompt => CONCAT(
                    'Write a Twitter alert for ',
                    location_id,
                    ' experiencing ',
                    risk_classification,
                    '. ',
                    'Include: ⚠️ emoji, location, brief risk description, main action, hashtag #ClimateAlert. ',
                    'Under 280 characters. Authoritative but not alarming tone.'
                ),
                connection_id => 'projects/YOUR_PROJECT_ID/locations/us-central1/connections/gemini'
            ) AS twitter_alert,
            -- Press Release
            ML.GENERATE_TEXT_LLM(
                prompt => CONCAT(
                    'Write a press release headline and first paragraph for emergency at ',
                    location_id,
                    '. ',
                    'Situation: ',
                    risk_classification,
                    ' with ',
                    alert_level,
                    ' alert level. ',
                    'Risk scores - Wildfire: ',
                    CAST(wildfire_risk_score AS STRING),
                    ', Flood: ',
                    CAST(flood_risk_score AS STRING),
                    '. ',
                    'Format: "FOR IMMEDIATE RELEASE" header, compelling headline, 50-word first paragraph with key facts.'
                ),
                connection_id => 'projects/YOUR_PROJECT_ID/locations/us-central1/connections/gemini'
            ) AS press_release,
            -- Emergency Broadcast
            ML.GENERATE_TEXT_LLM(
                prompt => CONCAT(
                    'Write an emergency broadcast script for ',
                    location_id,
                    '. ',
                    'Alert level: ',
                    alert_level,
                    ', situation: ',
                    risk_classification,
                    '. ',
                    'Temperature: ',
                    CAST(avg_temp AS STRING),
                    '°C, precipitation: ',
                    CAST(avg_precip AS STRING),
                    'mm. ',
                    'Recommended action: ',
                    recommended_action,
                    '. ',
                    'Format as 30-second radio script with clear, calm delivery instructions. ',
                    'Include "This is an official Climate AI Early Warning System alert."'
                ),
                connection_id => 'projects/YOUR_PROJECT_ID/locations/us-central1/connections/gemini'
            ) AS emergency_broadcast,
            *
        FROM critical_situations
    )
SELECT 'CRISIS_COMMUNICATIONS' as report_type,
    location_id,
    risk_classification,
    alert_level,
    twitter_alert,
    press_release,
    emergency_broadcast,
    wildfire_risk_score,
    flood_risk_score,
    CURRENT_TIMESTAMP() as report_generated
FROM ai_communications;
-- =========================================
-- 📋 RESOURCE OPTIMIZATION EXPORT
-- =========================================
-- AI-driven resource allocation recommendations
CREATE OR REPLACE TABLE `climate_ai.resource_optimization` AS WITH resource_analysis AS (
        SELECT location_id,
            lat,
            lon,
            alert_level,
            wildfire_risk_score,
            flood_risk_score,
            -- Calculate resource priority score
            (wildfire_risk_score + flood_risk_score) / 2 as combined_risk_score,
            CASE
                WHEN alert_level = 'CRITICAL' THEN 3
                WHEN alert_level = 'WARNING' THEN 2
                ELSE 1
            END as urgency_multiplier
        FROM `climate_ai.vw_decision_engine`
    ),
    ai_resource_planning AS (
        SELECT location_id,
            ML.GENERATE_TEXT_LLM(
                prompt => CONCAT(
                    'You are a emergency resource manager. For location ',
                    location_id,
                    ' at (',
                    CAST(lat AS STRING),
                    ', ',
                    CAST(lon AS STRING),
                    ') ',
                    'with alert level ',
                    alert_level,
                    ', combined risk score ',
                    CAST(ROUND(combined_risk_score, 1) AS STRING),
                    '/100. ',
                    'Generate optimal resource allocation in JSON: ',
                    '{"fire_crews": number, "flood_teams": number, "evacuation_buses": number, ',
                    '"medical_units": number, "supply_drops": number, "helicopter_hours": number, ',
                    '"estimated_cost_usd": number, "deployment_priority": "1-10", "staging_location": "nearest_city"}. ',
                    'Consider geographic accessibility and population density. JSON only.'
                ),
                connection_id => 'projects/YOUR_PROJECT_ID/locations/us-central1/connections/gemini'
            ) AS resource_allocation_json,
            ML.GENERATE_TEXT_LLM(
                prompt => CONCAT(
                    'Create a logistics plan for ',
                    location_id,
                    ' emergency response. ',
                    'Alert level: ',
                    alert_level,
                    ', risk score: ',
                    CAST(ROUND(combined_risk_score, 1) AS STRING),
                    '. ',
                    'Address: 1) Equipment pre-positioning, 2) Transportation routes, 3) Communication setup, ',
                    '4) Supply chain requirements, 5) Timeline milestones. ',
                    'Format as numbered action items with estimated timeframes.'
                ),
                connection_id => 'projects/YOUR_PROJECT_ID/locations/us-central1/connections/gemini'
            ) AS logistics_plan,
            *
        FROM resource_analysis
        WHERE alert_level IN ('CRITICAL', 'WARNING')
    )
SELECT 'RESOURCE_OPTIMIZATION' as report_type,
    location_id,
    resource_allocation_json,
    logistics_plan,
    combined_risk_score,
    urgency_multiplier,
    alert_level,
    CURRENT_TIMESTAMP() as report_generated
FROM ai_resource_planning;
-- =========================================
-- 🎯 FINAL MASTER EXPORT QUERY
-- =========================================
-- Comprehensive export combining all AI-generated reports
SELECT 'MASTER_CLIMATE_INTELLIGENCE_EXPORT' as export_type,
    CURRENT_TIMESTAMP() as export_timestamp,
    -- Executive Summary
    (
        SELECT executive_summary
        FROM `climate_ai.executive_reports`
        LIMIT 1
    ) as executive_summary,
    -- Geographic Intelligence Count
    (
        SELECT COUNT(*)
        FROM `climate_ai.geographic_intelligence`
    ) as locations_analyzed,
    -- Crisis Communications Count  
    (
        SELECT COUNT(*)
        FROM `climate_ai.crisis_communications`
    ) as critical_alerts_issued,
    -- Resource Optimization Count
    (
        SELECT COUNT(*)
        FROM `climate_ai.resource_optimization`
    ) as resource_plans_generated,
    -- Combined insights
    CONCAT(
        'Climate AI Intelligence Export Generated: ',
        CAST(CURRENT_TIMESTAMP() AS STRING),
        '. Analysis covers ',
        CAST(
            (
                SELECT COUNT(DISTINCT location_id)
                FROM `climate_ai.vw_decision_engine`
            ) AS STRING
        ),
        ' monitoring locations with AI-powered insights across executive reporting, ',
        'geographic intelligence, predictive analytics, crisis communications, and resource optimization.'
    ) as export_metadata;
-- =========================================
-- 📤 EXPORT VERIFICATION QUERIES
-- =========================================
-- Verify all exports were created successfully
SELECT 'EXPORT_STATUS' as status_type,
    table_name,
    row_count,
    'SUCCESS' as status
FROM (
        SELECT 'executive_reports' as table_name,
            COUNT(*) as row_count
        FROM `climate_ai.executive_reports`
        UNION ALL
        SELECT 'geographic_intelligence',
            COUNT(*)
        FROM `climate_ai.geographic_intelligence`
        UNION ALL
        SELECT 'predictive_analytics',
            COUNT(*)
        FROM `climate_ai.predictive_analytics`
        UNION ALL
        SELECT 'crisis_communications',
            COUNT(*)
        FROM `climate_ai.crisis_communications`
        UNION ALL
        SELECT 'resource_optimization',
            COUNT(*)
        FROM `climate_ai.resource_optimization`
    )
ORDER BY table_name;