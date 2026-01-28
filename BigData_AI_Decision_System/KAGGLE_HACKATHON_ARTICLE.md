# Climate Early Warning System: A Big Data AI Engine for Disaster Prevention

**BigQuery AI Decison Engine**
**Project:** [Climate Early Warning System - Big Data AI Engine](https://www.kaggle.com/competitions/bigquery-ai-hackathon/writeups/climate-early-warning-system-big-data-ai-engine)
**Author:** Andrei Besleaga  
**Date:** October 2025

---

## Summary

This project delivers a decision engine for the Climate Early Warning System (EWS), tailored for the BigQuery AI Hackathon:

- A Big Data AI Decision Engine built natively on Google BigQuery that performs forecasting, risk scoring, alert generation, and routing for both mobile sensors and emergency teams, based on data received from sensor, other external data, and mock data for testing.

### What it solves

- Bridges data gaps inherent in aquired data and enables proactive, AI-driven responses to wildfires and floods, climate emergencies.

### How it works

- Sensor and satellite data (via Google Earth Engine) are ingested into BigQuery.
- The Decision Engine (SQL views + BigQuery AI) calculates wildfire/flood risk, classifies alerts, and generates multi‑channel communications with Gemini.
- Geospatial clustering optimizes sensor deployment and emergency team dispatch.

### How to run (quick path)

 
1) Run `BigData_AI_Decision_System/create.sql` and `views.sql` to create schema and materialized views.
2) Populate data with `mock_data_generator.sql` (or integrate Earth Engine via `earthAI.md`).
3) Deploy the decision view with `optimized_pipeline.sql` and persist alerts with `alerts_sink.sql`.
4) (Optional) Execute `mobile_sensor_routing.sql` and `emergency_team_routing.sql` for operational planning.

### Why it matters

- Delivers proactive, explainable, and scalable climate intelligence using SQL-first AI capabilities available directly in BigQuery, GCP account.

## Abstract

Climate-related disasters are intensifying globally, demanding innovative approaches to early warning systems. This paper presents a revolutionary two-tier architecture combining a **Mobile Mesh Early Warning System** with a **Big Data AI Decision Engine** built entirely on Google BigQuery. The system leverages swarm intelligence for dynamic data collection through mobile IoT sensors (vehicles, drones, ships) and applies cutting-edge BigQuery AI capabilities—including time-series forecasting, generative AI, multimodal embeddings, and geospatial clustering—to deliver real-time risk assessment, intelligent routing, and automated crisis communications for wildfire and flood prevention.

---

## 1. Introduction: The Problem

Traditional early warning systems face critical limitations:

- **Static Sensors**: Fixed monitoring stations create data gaps in rapidly changing environments
- **Delayed Response**: Manual analysis bottlenecks prevent timely interventions
- **Limited Intelligence**: Lack of AI-powered forecasting and pattern recognition
- **Poor Resource Allocation**: Emergency teams and sensors deployed without optimization

This system addresses these challenges through a paradigm shift: combining a **dynamic mobile/external sensor network data** with a **real-time AI decision engine**.

---

## 2. System Architecture

### 2.1 Mobile Mesh Network: The Sensory Layer

As detailed in the project [README](README.md), the foundation is a distributed swarm of mobile sensors mimicking natural swarm intelligence:

#### **Ground Units (Electric Vehicles & Cars)**

- **Air Quality Monitoring**: NO₂, CO₂, and particulate sensors
- **Weather Conditions**: Temperature, humidity, atmospheric pressure
- **Infrastructure Monitoring**: Road conditions, flooding detection, heat stress

#### **Marine Vessels (Ships)**

- **Ocean Health**: Sea surface temperature, salinity, pH levels
- **Oceanographic Data**: Wave heights, current patterns
- **Climate Indicators**: Real-time ocean condition monitoring

#### **Aerial Units (Drones & Aircraft)**

- **Remote Sensing**: High-resolution thermal and visual imagery
- **Inaccessible Areas**: Monitoring deforestation, glacial melt, disaster zones
- **Atmospheric Profiling**: Multi-altitude temperature and humidity data

#### **Specialized Robotics**

- **Extreme Environments**: Hazardous or inaccessible terrain monitoring
- **Custom Deployments**: Tailored sensors for specific climate events

This mobile mesh creates a **dynamic, adaptive monitoring grid** that repositions based on real-time risk assessment—a key innovation over static sensor networks.

![System Architecture](SwarmSystem.png)

### 2.2 BigQuery AI Decision Engine: The Intelligence Layer

The `BigData_AI_Decision_System` is the brain of the operation—a fully serverless, scalable analytics pipeline built natively in BigQuery. As documented in its [README](BigData_AI_Decision_System/README.md), it processes multi-source data streams to generate actionable intelligence.

![Data Flow Architecture](BigData_AI_Decision_System/DataflowDiagram.png)

---

## 3. Innovative AI Capabilities

### 3.1 Time-Series Forecasting with AI.FORECAST

**Implementation**: `optimized_pipeline.sql`, `select.sql`

The system uses BigQuery's `AI.FORECAST` function to predict environmental conditions 6+ hours in advance:

```sql
AI.FORECAST(
  (SELECT TIMESTAMP_TRUNC(timestamp, HOUR) AS time,
          AVG(temperature) AS value
   FROM `climate_ai.sensor_data`
   WHERE sensor_type = 'temp'
   ORDER BY time),
  STRUCT(6 AS horizon)
)
```

**Applications**:

- **Temperature Forecasting**: Predicts heat waves and fire-conducive conditions
- **Precipitation Forecasting**: Anticipates flood risks with 6-hour lead time
- **Pressure Trend Analysis**: Identifies approaching storm systems

**Key Requirements** (from `AI_INNOVATIVE_USES.md`):

- ✅ Ordered time series with `ORDER BY time` clause
- ✅ Minimum 7 days of historical data
- ✅ Sufficient data density for pattern recognition

### 3.2 Generative AI for Multi-Channel Crisis Communications

**Implementation**: `export.sql`, `select.sql`

A groundbreaking feature: using `ML.GENERATE_TEXT_LLM` with Gemini to automatically generate context-aware, multi-format alerts:

#### **Executive Briefings**

```sql
ML.GENERATE_TEXT_LLM(
  prompt => 'You are a climate emergency coordinator. Generate executive briefing 
             with current risk level, forecast, and actionable timeline...',
  connection_id => 'projects/PROJECT_ID/locations/us-central1/connections/gemini'
)
```

#### **Specialized AI Personas Implemented**

- 👨‍💼 **Emergency Coordinator**: Strategic briefings with timelines
- 🌤️ **Meteorologist**: Weather pattern analysis and trend interpretation
- 🗺️ **Geographic Analyst**: Coordinate-based terrain risk assessment
- 📊 **Data Scientist**: Volatility analysis and predictive modeling
- 📢 **Communications Specialist**: Multi-channel crisis messaging (SMS, Twitter, press releases)
- 🚁 **Resource Manager**: Equipment allocation and logistics planning

#### **Channel-Optimized Outputs**

- **SMS Alerts**: 160 characters with action keywords
- **Twitter/Social Media**: 280 characters with emojis and hashtags
- **Press Releases**: Professional format with headlines
- **Radio Scripts**: 30-second timed delivery scripts

### 3.3 Multimodal AI: Fusing Satellite Imagery with Sensor Data

**Implementation**: `train_multimodal_model.sql`, `earthAI.sql`, `earthAi.js`

The system integrates Google Earth Engine to process satellite imagery alongside sensor telemetry:

```sql
FROM ML.GENERATE_EMBEDDING(
  MODEL `climate_ai.multimodal_climate_model`,
  (SELECT image_uri, image_text_description 
   FROM `climate_ai.imagery_metadata`)
)
```

**Earth Engine Integration Workflow** (from `earthAI.md`):

1. Export Sentinel-2/Landsat imagery from Google Earth Engine
2. Store GeoTIFF files in Cloud Storage
3. Generate metadata CSV with coordinates and timestamps
4. Load into BigQuery with `earth_images` table
5. Create embeddings combining visual and textual features

**Benefits**:

- Visual confirmation of fire signatures and flood extent
- Enhanced risk scoring with satellite-derived indices
- Historical imagery analysis for trend detection

### 3.4 Geospatial Intelligence and Routing Optimization

**Implementation**: `mobile_sensor_routing.sql`, `emergency_team_routing.sql`

Two sophisticated routing systems leverage `ST_CLUSTERDBSCAN` for geographic clustering:

#### **Mobile Sensor Routing System**

Optimizes deployment of mobile sensors based on:

- **Data Gap Analysis**: Identifies under-monitored regions
- **Risk-Weighted Prioritization**: Combines risk scores with data quality
- **Geographic Clustering**: Groups deployment zones (50km radius)
- **Cost Estimation**: Calculates fuel, time, and equipment needs

```sql
ST_CLUSTERDBSCAN(ST_GEOGPOINT(lon, lat), 50000, 2) OVER () AS cluster_id
```

**Output**: Prioritized deployment queue with reasoning, duration, and resource requirements.

#### **Emergency Team Routing System**

Dispatches emergency responders to imminent danger zones:

- **Imminent Danger Scoring**: 100-point scale combining multiple risk factors
- **Team Composition Planning**: Suggests personnel and equipment per incident type
- **Multi-Hazard Analysis**: Handles wildfire, flood, and compound emergencies
- **Response Time Categorization**: 15-min, 30-min, 1-hour, 2-hour response tiers

**Example Alert Level**:

- `IMMEDIATE_RESPONSE_15MIN`: Wildfire risk > 85 + CRITICAL alert
- `URGENT_RESPONSE_30MIN`: Flood risk > 70 + CRITICAL alert

---

## 4. Implementation Guide: Step-by-Step Deployment

The system follows a structured deployment sequence documented in `00_execution_order.sql`:

### **Phase 1: Database Initialization**

#### Step 1: Create Schema (`create.sql`)
 
```bash
# In BigQuery Console
bq query --use_legacy_sql=false < create.sql
```

Creates core tables:
 
- `sensor_data`: Partitioned by timestamp, clustered by location
- `earth_images`: Satellite imagery metadata
- `imagery_metadata`: Fire and flood indices from satellite data
- `alert_logs`: Historical alert records

#### Step 2: Populate Test Data (`mock_data_generator.sql`)
 
```sql
-- Generates 5000+ sensor readings across multiple locations
-- Simulates realistic temperature, precipitation, pressure patterns
-- Creates 2000+ imagery records with fire/flood indices
```

**Purpose**: Comprehensive testing and validation without waiting for real sensor data.

### **Phase 2: AI Model Setup**

#### Step 3: Create ML Models (`create_ml_models.sql`)
 
```sql
-- Temperature forecast model (Linear Regression)
CREATE OR REPLACE MODEL `climate_ai.temperature_forecast_model`
OPTIONS(model_type='LINEAR_REG', input_label_cols=['temperature'])
AS SELECT timestamp, temperature, location_id 
FROM `climate_ai.sensor_data`;

-- Precipitation forecast model
CREATE OR REPLACE MODEL `climate_ai.precipitation_forecast_model`
OPTIONS(model_type='LINEAR_REG', input_label_cols=['precipitation'])
AS SELECT timestamp, precipitation, location_id 
FROM `climate_ai.sensor_data`;
```

### **Phase 3: Data Pipeline Deployment**

#### Step 4: Create Aggregation Views (`views.sql`)
 
```sql
-- Hourly sensor aggregations
CREATE OR REPLACE VIEW `climate_ai.vw_sensor_hourly` AS
SELECT location_id, TIMESTAMP_TRUNC(timestamp, HOUR) AS hour_bucket,
       AVG(temperature) AS avg_temp, AVG(precipitation) AS avg_precip
FROM `climate_ai.sensor_data`
GROUP BY location_id, hour_bucket;
```

#### Step 5: Deploy Decision Engine (`optimized_pipeline.sql`)
 
This is the **core intelligence layer**:

```sql
CREATE OR REPLACE VIEW `climate_ai.vw_decision_engine` AS
WITH 
  -- Latest sensor readings with forecasts
  -- Imagery risk assessment
  -- Risk scoring algorithm
  -- Alert classification logic
SELECT location_id, wildfire_risk_score, flood_risk_score, 
       alert_level, recommended_action
FROM risk_classification;
```

**Output**: Real-time view generating:
 
- `wildfire_risk_score` (0-100)
- `flood_risk_score` (0-100)
- `alert_level` (NORMAL | WARNING | CRITICAL)
- `recommended_action` (Monitor | Deploy Teams | Evacuate)

#### Step 6: Activate Alerting (`alerts_sink.sql`)
 
```sql
-- Persist alerts for historical tracking
CREATE OR REPLACE TABLE `climate_ai.alert_logs` AS
SELECT *, CURRENT_TIMESTAMP() AS alert_time
FROM `climate_ai.vw_decision_engine`
WHERE alert_level IN ('WARNING', 'CRITICAL');
```

### **Phase 4: Satellite Integration (Optional)**

#### Step 7: Earth Engine Setup (`earthAi.js`)
 
Run in [Google Earth Engine Code Editor](https://code.earthengine.google.com/):

```javascript
// Export Sentinel-2 imagery to Cloud Storage
var roi = ee.Geometry.Polygon([...]);  // Define region
var s2 = ee.ImageCollection('COPERNICUS/S2_SR')
  .filterBounds(roi)
  .filterDate('2025-07-01', '2025-07-31');
  
Export.image.toCloudStorage({
  image: s2.select(['B4','B3','B2']),
  bucket: 'my-earth-ai-bucket',
  fileFormat: 'GeoTIFF'
});
```

#### Step 8: Load Satellite Data (`earthAI.sql`)
 
```sql
-- Load exported imagery metadata
CREATE EXTERNAL TABLE `climate_ai.gee_export_metadata`
OPTIONS (uris = ['gs://my-earth-ai-bucket/metadata.csv']);

-- Insert into earth_images table
INSERT INTO `climate_ai.earth_images`
SELECT uri, lat, lon, tstamp FROM gee_export_metadata;
```

### **Phase 5: Operational Systems**

#### Step 9: Deploy Routing Systems
 
```bash
# Mobile sensor optimization
bq query < mobile_sensor_routing.sql

# Emergency team dispatch
bq query < emergency_team_routing.sql
```

#### Step 10: Quality Assurance (`optimized_pipeline_checks.sql`)
 
```sql
-- Validate data quality
-- Check for out-of-range values
-- Verify alert distribution
-- Monitor system performance
```

---

## 5. Key Benefits and Impact

### 5.1 Proactive vs. Reactive Response

- **Forecast Window**: Anticipate events before they escalate
- **Early Evacuation**: Move populations before roads become impassable
- **Resource Pre-Positioning**: Stage equipment in optimal locations

### 5.2 Hyper-Local Intelligence

- **Dynamic Coverage**: Mobile sensors fill gaps left by static stations
- **Real-Time Adaptation**: Swarm repositions based on emerging risks
- **Granular Data**: Block-level resolution vs. city-wide averages

### 5.3 Optimized Resource Allocation

- **Sensor Deployment**: AI calculates optimal routes for data collection vehicles
- **Emergency Response**: Teams dispatched to highest-priority zones first
- **Cost Efficiency**: Reduced fuel consumption and equipment wear

### 5.4 Automated Communication Pipeline

- **Zero Manual Bottleneck**: Generative AI creates alerts in seconds
- **Multi-Channel Consistency**: Same information, format-optimized for each medium
- **Language Adaptability**: Can generate alerts in multiple languages

### 5.5 Scale and Performance

- **Petabyte-Scale Processing**: BigQuery handles massive data volumes
- **Sub-Second Queries**: Real-time risk assessment despite data complexity
- **Serverless Architecture**: No infrastructure management overhead

---

## 6. Real-World Use Cases

### Wildfire Prevention (California Scenario)

1. Mobile sensors detect temperature spike + low humidity
2. AI.FORECAST predicts 38°C in 6 hours
3. Satellite imagery confirms dry vegetation
4. **Alert Level: CRITICAL** → Deploy firefighters pre-emptively
5. Generative AI creates evacuation notices in English + Spanish

### Flood Response (Romania Scenario)

1. Ship sensors detect unusual sea surface temperature
2. Drone imagery shows swollen river levels
3. AI.FORECAST predicts 120mm precipitation in 6 hours
4. **Alert Level: WARNING** → Pre-position sandbags and pumps
5. SMS alerts sent to 50,000 residents in flood zone

### Multi-Hazard Event (Compound Disaster)

1. System detects both wildfire risk (75) and flood risk (65)
2. Classification: `MULTI_HAZARD`
3. Emergency routing suggests **Type C teams** (both fire + flood trained)
4. Resource manager AI allocates helicopters for dual-purpose deployment

---

## 7. Technical Innovation Highlights

### BigQuery AI Feature Utilization

✅ **AI.FORECAST**: Time-series prediction for temperature & precipitation  
✅ **ML.GENERATE_TEXT_LLM**: Multi-persona crisis communications  
✅ **ML.GENERATE_EMBEDDING**: Multimodal satellite + sensor fusion  
✅ **ST_CLUSTERDBSCAN**: Geographic clustering for routing optimization  
✅ **Structured Prompting**: JSON-formatted AI outputs for automation  
✅ **Vector Search**: (Planned) Similarity search for historical event matching  

### Architectural Innovations

- **Swarm Intelligence**: First climate EWS using mobile mesh networks
- **Hybrid Forecasting**: AI.FORECAST for static locations + statistical trends for dynamic
- **Multi-Persona AI**: Different AI voices for different stakeholders
- **Real-Time Routing**: Live optimization of both sensors and responders

---

## 8. Performance Metrics

### System Capabilities (validation via `optimized_pipeline_checks.sql`)

- Monitors data quality, out-of-range values, and alert distribution
- Tracks end-to-end pipeline health (ingestion, aggregation, decision view)
- Observes query latencies and pipeline throughput for your dataset size
- Provides sanity guardrails for safe operations in demo or pilot setups

### Cost Efficiency

- **BigQuery On-Demand**: Pay only for queries executed
- **Serverless**: Zero infrastructure maintenance costs
- **Scalability**: Linear cost scaling with data volume

---

## 9. Diagrams and Supporting Docs

- System architecture diagram: `SwarmSystem.png`
- Data flow diagram: `BigData_AI_Decision_System/DataflowDiagram.png`
- BigQuery AI architecture view: `BigData_AI_Decision_System/EWS_BigQueryAI.png`
- Prototype PDF (technical overview): `BigData_AI_Decision_System/EWS BigQuery AI System Prototype.pdf`

---

## 10. Future Enhancements

### Planned Features (from project roadmap)

1. **CAMARA Telecom APIs**: Direct integration with Telco Network APIs for location and emergency services
2. **Distributed Ledger**: Immutable event logging for audit trails
3. **AI Framework**:  AI agent orchestration and framework
5. **Other**: Integration of other services and APIs

---

## 11. Conclusion

The Mobile Mesh EWS with BigQuery AI Decision Engine represents a fundamental rethinking of climate early warning systems. By combining the adaptability of swarm-based sensor networks with the intelligence of BigQuery's AI capabilities, this system that is:

- **Proactive**: Forecasting events hours before they happen
- **Intelligent**: Leveraging generative AI for automated decision-making
- **Scalable**: Built on serverless infrastructure for global deployment
- **Comprehensive**: Handling data collection, analysis, and response in one platform

This system moves beyond traditional "detect and react" approaches to create a truly **predictive, adaptive, and intelligent** climate resilience platform. As climate events intensify, solutions like this will be critical to protecting lives and property.

---

## Appendix: Quick Start Commands

```bash
# 1. Create BigQuery dataset
bq mk --dataset climate_ai

# 2. Initialize schema
bq query --use_legacy_sql=false < BigData_AI_Decision_System/create.sql

# 3. Generate test data
bq query --use_legacy_sql=false < BigData_AI_Decision_System/mock_data_generator.sql

# 4. Create views
bq query --use_legacy_sql=false < BigData_AI_Decision_System/views.sql

# 5. Deploy decision engine
bq query --use_legacy_sql=false < BigData_AI_Decision_System/optimized_pipeline.sql

# 6. Activate alerting
bq query --use_legacy_sql=false < BigData_AI_Decision_System/alerts_sink.sql

# 7. Query current alerts
bq query "SELECT * FROM climate_ai.vw_decision_engine WHERE alert_level = 'CRITICAL'"
```

---

## References

- **Project Repository**: [mobile-mesh-ews](https://github.com/andreibesleaga/mobile-mesh-ews)
- **Medium Article**: [Innovative Swarm System Architecture](https://medium.com/@andrei-besleaga/innovative-swarm-system-architecture-with-live-mobile-edge-sensors-for-climate-monitoring-and-eb0124e7b451)
- **Kaggle Competition**: [BigQuery AI Hackathon](https://www.kaggle.com/competitions/bigquery-ai-hackathon)
- **Google Earth Engine**: [code.earthengine.google.com](https://code.earthengine.google.com/)

---

**Contact**: Andrei Besleaga  
**License**: See project LICENSE files  
**Last Updated**: October 22, 2025
