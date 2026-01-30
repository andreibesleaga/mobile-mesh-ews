# C4 Component Diagram - SwarmSystem

## Component Architecture Overview

This document details the key components within each major container of the SwarmSystem, showing internal structure and responsibilities.

## Central Platform Components

```mermaid
C4Component
    title Component Diagram - Central Platform

    Container_Boundary(central, "Central Platform") {
        Component(data_ingest, "Data Ingestion Service", "Dataflow", "Receives streams from mesh, normalizes, routes to storage")
        Component(event_bus, "Event Bus", "Pub/Sub", "Decouples producers/consumers, ensures delivery")
        Component(system_status_db, "System Status DB", "TimescaleDB", "Live conditions, locations, sensor health, mesh status")
        Component(settings_db, "Settings DB", "PostgreSQL", "Thresholds, configs, decision logic trees")
        Component(decision_engine, "Decision Engine", "Cloud Run", "Evaluates triggers, coordinates responses")
        Component(api_services, "API Services", "Cloud Endpoints", "REST/GraphQL for external consumers")
    }

    Container(bigdata_ai, "BigData AI Engine", "", "ML processing")
    Container(cap_gateway, "CAP Gateway", "", "Alert dissemination")
    Container(mobile_mesh, "Mobile Mesh", "", "Sensor network")

    Rel(mobile_mesh, data_ingest, "Sensor data", "Protobuf/gRPC")
    Rel(data_ingest, event_bus, "Normalized events", "Pub/Sub")
    Rel(event_bus, system_status_db, "Store status", "SQL")
    Rel(decision_engine, settings_db, "Read thresholds", "SQL")
    Rel(decision_engine, bigdata_ai, "Query forecasts", "gRPC")
    Rel(decision_engine, cap_gateway, "Trigger alert", "Internal API")
    Rel(api_services, system_status_db, "Query data", "SQL")
```

### Central Platform Component Details

| Component | Technology | Responsibility | REQ Reference |
|-----------|------------|----------------|---------------|
| **Data Ingestion Service** | GCP Dataflow | Stream processing, schema validation, routing | REQ-PLAT-001 |
| **Event Bus** | GCP Pub/Sub | Async messaging, guaranteed delivery | REQ-PLAT-001 |
| **System Status DB** | TimescaleDB | Live conditions, locations, sensor health, coverage areas | REQ-PLAT-002 |
| **Settings DB** | PostgreSQL (3NF) | Thresholds, configs, historical stats, decision logic | REQ-PLAT-003 |
| **Decision Engine** | Cloud Run | Swarm decisions, incident response decisions | REQ-PLAT-004, REQ-PLAT-005 |
| **API Services** | Cloud Endpoints | External data access for researchers, 3rd parties | REQ-PLAT-008 |

---

## BigData AI Engine Components

```mermaid
C4Component
    title Component Diagram - BigData AI Engine

    Container_Boundary(ai_engine, "BigData AI Engine") {
        Component(ai_generate, "AI.GENERATE", "Gemini/PaLM", "Dynamic data parsing, semantic field mapping")
        Component(ai_forecast, "AI.FORECAST", "ARIMA_PLUS/TimesFM", "Time-series predictions with confidence intervals")
        Component(vector_search, "Vector Search", "BigQuery Vector", "Semantic search over historical reports")
        Component(rag_engine, "RAG Engine", "Vertex AI", "Retrieval-augmented generation for context")
        Component(model_registry, "Model Registry", "Vertex AI", "Version control for trained models")
        Component(training_pipeline, "Training Pipeline", "Dataflow", "Online/offline model training loops")
    }

    Container(framework_ai, "Framework AI", "", "External learning")
    Container(central, "Central Platform", "", "Decision coordination")

    Rel(central, ai_generate, "Raw payloads", "SQL/gRPC")
    Rel(ai_generate, ai_forecast, "Normalized data", "Internal")
    Rel(ai_forecast, central, "Predictions + CI", "gRPC")
    Rel(vector_search, rag_engine, "Retrieved context", "Internal")
    Rel(rag_engine, central, "Enriched decisions", "gRPC")
    Rel(framework_ai, training_pipeline, "External data", "MCP/A2A")
    Rel(training_pipeline, model_registry, "New models", "Vertex API")
```

### BigData AI Component Details

| Component | Technology | Responsibility | REQ Reference |
|-----------|------------|----------------|---------------|
| **AI.GENERATE** | Gemini/PaLM via BigQuery Remote Models | Schema-drift-resilient data parsing | PRD Other #3.1 |
| **AI.FORECAST** | ARIMA_PLUS, TimesFM | Rolling 6-hour forecasts, 15-min granularity | PRD Other #3.2, REQ-AI-003 |
| **Vector Search** | BigQuery Vector Index | Semantic search over climate reports | PRD Other #3.3 |
| **RAG Engine** | Vertex AI | Contextual enrichment from historical events | REQ-AI-006 |
| **Model Registry** | Vertex AI Model Registry | Model versioning, shadow mode evaluation | REQ-LOOP-002 |
| **Training Pipeline** | Dataflow + Federated Learning | Hybrid cloud/edge training | REQ-AI-001, REQ-AI-002 |

---

## Mobile Sensor Mesh Components

```mermaid
C4Component
    title Component Diagram - Mobile Sensor Mesh

    Container_Boundary(mesh, "Mobile Sensor Mesh") {
        Component(sensor_array, "Sensor Array", "MEMS/Optical/Chemical", "Multi-modal data acquisition")
        Component(edge_ai, "Edge AI Processor", "ESP32/ARM + TFLite", "Local preprocessing, feature extraction")
        Component(mesh_router, "Mesh Router", "802.15.4/BLE Mesh", "Peer-to-peer data relay")
        Component(localization, "Localization Module", "GPS/UWB/Visual Odometry", "Position awareness in all environments")
        Component(formation_ctrl, "Formation Controller", "Swarm AI", "Autonomous geometric arrangement")
        Component(cluster_leader, "Cluster Leader", "Elected Node", "Local aggregation, tier coordination")
    }

    Container(comm_gateway, "Communication Gateway", "", "Backhaul")

    Rel(sensor_array, edge_ai, "Raw readings", "Internal")
    Rel(edge_ai, mesh_router, "Features", "Mesh Protocol")
    Rel(mesh_router, cluster_leader, "Aggregated", "Mesh")
    Rel(cluster_leader, comm_gateway, "Cluster data", "5G/Satellite")
    Rel(localization, formation_ctrl, "Position", "Internal")
    Rel(formation_ctrl, mesh_router, "Waypoints", "Internal")
```

### Mesh Component Details

| Component | Responsibility | REQ Reference |
|-----------|----------------|---------------|
| **Sensor Array** | Multi-modal sensing (optical, thermal, chemical, seismic, hydro) | REQ-EDGE-004 |
| **Edge AI Processor** | Local inference, feature extraction (<1MB models) | REQ-EDGE-003 |
| **Mesh Router** | Self-healing relay, dynamic routing | REQ-COM-001, REQ-COM-002 |
| **Localization Module** | GPS + relative positioning in denied environments | REQ-EDGE-007 |
| **Formation Controller** | Autonomous arrangement (search lines, perimeters) | REQ-EDGE-009 |
| **Cluster Leader** | Democratic election, local aggregation | REQ-GEN-003 |

---

## Framework AI Components

```mermaid
C4Component
    title Component Diagram - Framework AI (Learning & Communication)

    Container_Boundary(framework, "Framework AI") {
        Component(chatbot_engine, "Chatbot Engine", "GENIEAI/OPEA", "Natural language interaction with users")
        Component(doc_ingestion, "Document Ingestion", "Haystack/LangChain", "PDF, news, reports parsing")
        Component(mcp_client, "MCP Client", "Model Context Protocol", "Context-aware agent communication")
        Component(a2a_client, "A2A Client", "Agent-to-Agent Protocol", "Inter-agent capability discovery")
        Component(embedding_service, "Embedding Service", "Vertex Embeddings", "Text-to-vector conversion")
        Component(learning_loop, "Learning Loop", "Fine-tuning Pipeline", "Continuous model improvement")
    }

    Container(bigdata_ai, "BigData AI", "", "Vector storage")
    Container(external, "External Sources", "", "Any data source")

    Rel(external, doc_ingestion, "Documents/APIs", "HTTP/MCP")
    Rel(doc_ingestion, embedding_service, "Text chunks", "Internal")
    Rel(embedding_service, bigdata_ai, "Vectors", "Vector API")
    Rel(mcp_client, external, "Context queries", "MCP")
    Rel(a2a_client, external, "Agent discovery", "A2A")
    Rel(chatbot_engine, embedding_service, "Query vectors", "Internal")
    Rel(learning_loop, bigdata_ai, "Model updates", "Vertex API")
```

### Framework AI Component Details

| Component | Technology | Responsibility | REQ Reference |
|-----------|------------|----------------|---------------|
| **Chatbot Engine** | GENIEAI/OPEA/Haystack | User communication, natural language queries | User Req #6 |
| **Document Ingestion** | LangChain/Haystack | Parse any document format for learning | User Req #8 |
| **MCP Client** | Model Context Protocol | Context-aware external data queries | PRD Other #5.2 |
| **A2A Client** | Agent-to-Agent Protocol | Capability discovery, inter-agent coordination | PRD Other #5.2 |
| **Embedding Service** | Vertex AI Embeddings | Convert text to searchable vectors | PRD Other #3.3 |
| **Learning Loop** | Continuous fine-tuning | Improve models from new external data | REQ-AI-004 |

---

## CAP Alert Gateway Components

```mermaid
C4Component
    title Component Diagram - CAP Alert Gateway

    Container_Boundary(cap, "CAP Alert Gateway") {
        Component(cap_serializer, "CAP Serializer", "XML Builder", "JSON to CAP v1.2 XML conversion")
        Component(translation_mw, "Translation Middleware", "Gemini NMT", "Multi-language info block generation")
        Component(geo_converter, "Geo Converter", "S2 to Polygon", "Convert S2 cells to CAP area elements")
        Component(hardware_driver, "Hardware Driver", "RS-485/IP", "Fire panel and LED sign actuation")
        Component(dissemination, "Dissemination Service", "mTLS Client", "IPAWS, WEA carrier connections")
        Component(audit_logger, "Audit Logger", "Blockchain Writer", "Immutable decision logging")
    }

    Container(central, "Central Platform", "", "Alert triggers")
    Container_Ext(ipaws, "IPAWS/WEA", "", "Alert networks")
    Container_Ext(hardware, "Legacy Hardware", "", "Physical alerts")

    Rel(central, cap_serializer, "Alert object", "Internal API")
    Rel(cap_serializer, translation_mw, "Primary CAP", "Internal")
    Rel(translation_mw, geo_converter, "Multi-lang CAP", "Internal")
    Rel(geo_converter, dissemination, "Final CAP", "Internal")
    Rel(dissemination, ipaws, "CAP XML", "mTLS/HTTPS")
    Rel(hardware_driver, hardware, "Commands", "RS-485/IP")
    Rel(cap_serializer, audit_logger, "Decision record", "Ledger API")
```

### CAP Gateway Component Details

| Component | Responsibility | REQ Reference |
|-----------|----------------|---------------|
| **CAP Serializer** | Map internal severity to CAP enumerations (Urgency, Severity, Certainty) | PRD Other #4.1 |
| **Translation Middleware** | <200ms multi-language generation | PRD Other #4.2 |
| **Geo Converter** | S2 cell to polygon/circle for area targeting | PRD Other #4.1 |
| **Hardware Driver** | Notifier fire panels, LED signs, sirens | PRD Other #4.3 |
| **Dissemination Service** | Secure connections to IPAWS, carriers | PRD Other #4.4 |
| **Audit Logger** | Blockchain logging for accountability | REQ-PLAT-006 |

---

## Communication Gateway Components

```mermaid
flowchart TB
    subgraph CommGateway["Communication Gateway"]
        MESH_PROTO["Mesh Protocol Handler<br/>(AODV/TORA/ACO)"]
        SPECTRUM["Spectrum Manager<br/>(Cognitive Radio)"]
        SAT_MOD["Satellite Modem<br/>(LEO Interface)"]
        CELL_MOD["Cellular Modem<br/>(5G/6G NR)"]
        DTN["DTN Handler<br/>(Store-and-Forward)"]
        CAMARA_CL["CAMARA Client<br/>(Mobile Network APIs)"]
    end

    MESH_PROTO --> SPECTRUM
    SPECTRUM --> SAT_MOD
    SPECTRUM --> CELL_MOD
    CELL_MOD --> CAMARA_CL
    DTN --> SAT_MOD
```

### Communication Gateway Component Details

| Component | Responsibility | REQ Reference |
|-----------|----------------|---------------|
| **Mesh Protocol Handler** | AODV (stable), TORA (dynamic), ACO (optimization) | REQ-COM-004, REQ-COM-005, REQ-COM-006 |
| **Spectrum Manager** | Cognitive radio, TV white spaces, interference avoidance | REQ-COM-009 |
| **Satellite Modem** | LEO constellation interface (Starlink/Iridium) | REQ-COM-010 |
| **Cellular Modem** | 5G/6G with OTFS modulation for high-velocity | REQ-COM-007, REQ-COM-008 |
| **DTN Handler** | Store-and-forward for connectivity gaps | REQ-COM-011 |
| **CAMARA Client** | Mobile network APIs for urban context | User Req #5 |

---

*Diagram follows C4 Model Level 3 (Component) - shows internal structure of each container.*
