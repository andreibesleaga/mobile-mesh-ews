# BigData AI E2E Decision System

## Overview

This is an end-to-end AI-powered Early Warning System (EWS) Big Data Decision System and Routing Layer, built on Google BigQuery that processes real-time sensor data and satellite imagery to generate intelligent climate risk alerts. The system combines sensor telemetry, satellite image analysis, and AI models to provide automated decision-making for wildfire and flood risk assessment.

This project uses new features from BigQuery AI like: Generative AI in SQL, Vector Search in SQL, Multimodal Features in SQL, and it can be run as a separate domain system, outside of main EWS system imlementation, or embbeded in the general system architecture, when completed, and has been tested with generated data on a Google Cloud Personal Account, with SQL, and via Kaggle Python scripts.

You can view the project [on Kaggle](https://www.kaggle.com/competitions/bigquery-ai-hackathon/writeups/climate-early-warning-system-big-data-ai-engine), or read an article about it [on Substack](https://andreibesleaga.substack.com/p/climate-early-warning-system-bigquery).

## Features

- **Real-time Sensor Data Processing**: Ingests temperature, precipitation, pressure, humidity, and wind data from IoT sensors
- **Satellite Image Analysis**: Processes earth imagery with multimodal AI embeddings for risk assessment using Google Earth Engine
- **AI-Powered Risk Classification**: Uses machine learning models to classify wildfire and flood risks
- **Intelligent Alerting**: Generates natural language alert messages using Gemini AI
- **Scalable Architecture**: Built on BigQuery with partitioned tables for high-performance analytics
- **Large-scale Testing**: Mock data generators for comprehensive system validation
- **Quality Assurance**: Built-in validation and performance monitoring tools
- **Earth Engine Integration**: Seamless satellite imagery processing and metadata management

## System Components

### Core SQL Scripts
[demo production ready - beta testing in Kaggle/GCP]

- **`create.sql`**: Database schema creation for sensor data, satellite imagery, and AI models
- **`data_population.sql`**: Sample data insertion for testing and demonstration
- **`views.sql`**: Optimized views for hourly and daily sensor data aggregations
- **`optimized_pipeline.sql`**: Performance-optimized decision engine pipeline
- **`alerting.sql`**: Main AI alerting logic with risk classification and message generation
- **`alerts_sink.sql`**: Alert storage and management system
- **`select.sql`**: Query templates for data analysis
- **`earthAI.sql`**: Google Earth Engine and BigQuery integration for satellite imagery processing
- **`mock_data_generator.sql`**: Large-scale mock data generation for testing and development
- **`optimized_pipeline_checks.sql`**: Quality assurance and validation checks for the decision engine

### Earth Engine Integration

- **`earthAi.js`**: Google Earth Engine JavaScript code for satellite image export and processing
- **`earthAI.md`**: Complete documentation and tutorial for Earth Engine integration with step-by-step instructions

### Documentation
[Final Drafts]

- **`EWS BigQuery AI System Prototype.pdf`**: Technical architecture and implementation details
- **`DataflowDiagram.png`**: Visual representation of the data flow
- **`EWS_BigQueryAI.png`**: System architecture diagram

## Risk Classification

The system automatically classifies locations into risk categories:

- **High Wildfire Risk**: Fire index > 0.7 and temperature > 35°C
- **High Flood Risk**: Flood index > 0.7 and precipitation > 80mm
- **Moderate Risks**: Various threshold combinations for temperature, pressure, and precipitation
- **Low Risk**: Normal conditions

## Alert Levels

- **CRITICAL**: Immediate action required (high fire/flood indices)
- **WARNING**: Attention needed (moderate risk conditions)
- **NORMAL**: Standard monitoring

## Technology Stack

- **Google BigQuery**: Data warehouse and analytics platform
- **BigQuery ML**: Machine learning and AI model hosting
- **Gemini AI**: Natural language alert generation
- **Google Cloud Storage**: Satellite imagery storage
- **Google Earth Engine**: Satellite imagery processing and analysis
- **Multimodal Embedding Models**: Image analysis and feature extraction
- **JavaScript**: Earth Engine scripting and automation (Google Earth AI)

## Quick Start

1. **Initialize Database**: Set up BigQuery dataset and run `create.sql` to initialize tables
2. **Generate Test Data**: Use `mock_data_generator.sql` to create large-scale test datasets
3. **Set up Earth Engine**: Follow instructions in `earthAI.md` and use `earthAi.js` for satellite data integration
4. **Create Views**: Deploy optimized views with `views.sql`
5. **Deploy Pipeline**: Set up the decision engine pipeline with `optimized_pipeline.sql`
6. **Validate System**: Run quality checks with `optimized_pipeline_checks.sql`
7. **Enable Alerting**: Deploy alerting logic with `alerting.sql`
8. **Configure Storage**: Set up alert persistence with `alerts_sink.sql`
9. **Integrate Earth AI**: Use `earthAI.sql` to connect satellite imagery processing

(note: you can populate with mock data the tables by modifying and running  `mock_data_generator.sql`)

## Use Cases

- Forest fire early warning systems
- Flood risk monitoring
- Agricultural weather alerts
- Emergency response coordination
- Climate change impact assessment
- Smart city environmental monitoring
- Large-scale disaster preparedness testing
- Satellite-based environmental monitoring
- Multi-modal AI research and development

## Development & Testing

The system includes comprehensive development tools:

- **Mock Data Generation**: Use `mock_data_generator.sql` to create realistic test datasets at scale (5000+ sensor readings, 2000+ imagery records)
- **Quality Assurance**: Run `optimized_pipeline_checks.sql` to validate data quality, detect anomalies, and verify system performance
- **Earth Engine Tutorial**: Complete step-by-step guide in `earthAI.md` for satellite data integration
- **Performance Monitoring**: Built-in checks for out-of-range values, alert distribution analysis, and system health monitoring

---

*This system is a demo and not tested in the wild (only on limited GCP account with live BigQuery AI and mock datasets) and is designed for scalable, real-time environmental monitoring and can be adapted for various climate and weather-related early warning applications.*
