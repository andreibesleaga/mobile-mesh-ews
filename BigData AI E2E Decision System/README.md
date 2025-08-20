# BigData AI E2E Decision System

## Overview

This is an end-to-end AI-powered Early Warning System (EWS) Big Data Decision System and Routing Layer, built on Google BigQuery that processes real-time sensor data and satellite imagery to generate intelligent climate risk alerts. The system combines sensor telemetry, satellite image analysis, and AI models to provide automated decision-making for wildfire and flood risk assessment.

## Features

- **Real-time Sensor Data Processing**: Ingests temperature, precipitation, pressure, humidity, and wind data from IoT sensors
- **Satellite Image Analysis**: Processes earth imagery with multimodal AI embeddings for risk assessment
- **AI-Powered Risk Classification**: Uses machine learning models to classify wildfire and flood risks
- **Intelligent Alerting**: Generates natural language alert messages using Gemini AI
- **Scalable Architecture**: Built on BigQuery with partitioned tables for high-performance analytics

## System Components

### Core SQL Scripts

- **`create.sql`**: Database schema creation for sensor data, satellite imagery, and AI models
- **`data_population.sql`**: Sample data insertion for testing and demonstration
- **`views.sql`**: Optimized views for hourly and daily sensor data aggregations
- **`optimized_pipeline.sql`**: Performance-optimized decision engine pipeline
- **`alerting.sql`**: Main AI alerting logic with risk classification and message generation
- **`alerts_sink.sql`**: Alert storage and management system
- **`select.sql`**: Query templates for data analysis

### Documentation

- **`Business Case - EWS BigQuery AI System.pdf`**: Business justification and requirements
- **`EWS BigQuery AI System Prototype.pdf`**: Technical architecture and implementation details
- **`DataflowDiagram.png`**: Visual representation of the data flow
- **`EWS_BigQueryAI.png`**: System architecture diagram

## Risk Classification

The system automatically classifies locations into risk categories:

- 🔥 **High Wildfire Risk**: Fire index > 0.7 and temperature > 35°C
- 🌊 **High Flood Risk**: Flood index > 0.7 and precipitation > 80mm
- ⚠️ **Moderate Risks**: Various threshold combinations for temperature, pressure, and precipitation
- ✅ **Low Risk**: Normal conditions

## Alert Levels

- **CRITICAL**: Immediate action required (high fire/flood indices)
- **WARNING**: Attention needed (moderate risk conditions)
- **NORMAL**: Standard monitoring

## Technology Stack

- **Google BigQuery**: Data warehouse and analytics platform
- **BigQuery ML**: Machine learning and AI model hosting
- **Gemini AI**: Natural language alert generation
- **Google Cloud Storage**: Satellite imagery storage
- **Multimodal Embedding Models**: Image analysis and feature extraction (Google Earth AI)

## Quick Start

1. Set up BigQuery dataset and run `create.sql` to initialize tables
2. Populate with sample data using `data_population.sql`
3. Create optimized views with `views.sql`
4. Deploy the decision engine pipeline with `optimized_pipeline.sql`
5. Run alerting queries with `alerting.sql`
6. Set up alert storage with `alerts_sink.sql`

(note: you can populate with mock data the tables by modifying and running  `mock_data_generator.sql`)

## Use Cases

- Forest fire early warning systems
- Flood risk monitoring
- Agricultural weather alerts
- Emergency response coordination
- Climate change impact assessment
- Smart city environmental monitoring

---

*This system is a demo and not tested in the wild and is designed for scalable, real-time environmental monitoring and can be adapted for various climate and weather-related early warning applications.*
