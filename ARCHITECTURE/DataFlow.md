# Data Flow Architecture - SwarmSystem

## Data Flow Overview

This document describes the complete data flow through the SwarmSystem, from edge sensor acquisition through processing, decision-making, and alert dissemination.

## Primary Data Flow Diagram

```mermaid
flowchart TB
    subgraph EDGE["1. Environment (Edge/IoT)"]
        direction TB
        SENSORS["Mobile Sensors<br/>(Temp, Pressure, Chemical)"]
        EDGE_AI["Edge Preprocessing<br/>(Feature Extraction)"]
        MESH["Mesh Relay<br/>(Peer-to-Peer)"]
    end

    subgraph COMM["2. Communication Layer"]
        direction TB
        MESH_PROTO["Mesh Protocol<br/>(AODV/TORA)"]
        CELL["5G/6G Gateway"]
        SAT["Satellite Backhaul"]
        CAMARA_API["CAMARA APIs<br/>(Urban Context)"]
    end

    subgraph PLATFORM["3. Central Platform"]
        direction TB
        INGEST["Data Ingestion<br/>(Dataflow)"]
        PUBSUB["Event Bus<br/>(Pub/Sub)"]
        STATUS_DB[("System Status DB<br/>(TimescaleDB)")]
        SETTINGS_DB[("Settings DB<br/>(PostgreSQL)")]
        DECISION["Decision Engine"]
    end

    subgraph AI["4. AI Engine"]
        direction TB
        AI_GEN["AI.GENERATE<br/>(Data Normalization)"]
        AI_FORECAST["AI.FORECAST<br/>(Predictions)"]
        VECTOR["Vector Search"]
        RAG["RAG Engine"]
    end

    subgraph FRAMEWORK["5. Framework AI"]
        direction TB
        CHATBOT["Chatbot Engine"]
        DOC_INGEST["Document Ingestion"]
        MCP_A2A["MCP/A2A Client"]
    end

    subgraph ALERT["6. Alert Dissemination"]
        direction TB
        CAP_GEN["CAP Generator"]
        TRANSLATE["Translation<br/>(Multi-Language)"]
        HARDWARE["Hardware Driver"]
    end

    subgraph EXTERNAL["7. External Systems"]
        direction TB
        NASA["NASA/GEE"]
        IPAWS["IPAWS/WEA"]
        BLOCKCHAIN["Blockchain<br/>(Audit)"]
        OTHER_DATA["External Data<br/>(Weather, News, Docs)"]
    end

    subgraph OUTPUT["8. Outputs"]
        direction TB
        MOBILE_APP["Mobile App<br/>(Civilian)"]
        C2["C2 Console<br/>(Operator)"]
        SIRENS["Sirens/Signs"]
        MESH_CMD["Mesh Commands<br/>(Swarm Control)"]
    end

    %% Data Flow Arrows
    SENSORS --> EDGE_AI
    EDGE_AI --> MESH
    MESH --> MESH_PROTO
    MESH_PROTO --> CELL
    MESH_PROTO --> SAT
    CELL --> CAMARA_API
    CELL --> INGEST
    SAT --> INGEST
    
    INGEST --> PUBSUB
    PUBSUB --> STATUS_DB
    PUBSUB --> AI_GEN
    AI_GEN --> AI_FORECAST
    AI_FORECAST --> DECISION
    
    SETTINGS_DB --> DECISION
    VECTOR --> RAG
    RAG --> DECISION
    
    NASA --> AI_FORECAST
    OTHER_DATA --> DOC_INGEST
    DOC_INGEST --> VECTOR
    MCP_A2A --> DOC_INGEST
    
    DECISION --> CAP_GEN
    CAP_GEN --> TRANSLATE
    TRANSLATE --> IPAWS
    TRANSLATE --> HARDWARE
    
    DECISION --> BLOCKCHAIN
    DECISION --> MESH_CMD
    
    IPAWS --> MOBILE_APP
    HARDWARE --> SIRENS
    STATUS_DB --> C2
    MESH_CMD --> MESH_PROTO
    
    CHATBOT --> MOBILE_APP
```

## Flow Descriptions

### 1. Sensor Data Acquisition Flow

```mermaid
sequenceDiagram
    participant S as Sensor Node
    participant E as Edge AI
    participant L as Cluster Leader
    participant G as Comm Gateway
    participant P as Central Platform

    S->>E: Raw sensor reading (temp=45°C, CO2=800ppm)
    E->>E: Feature extraction
    E->>L: Compressed features (JSON/Protobuf)
    L->>L: Aggregate cluster data
    L->>G: Cluster summary via mesh
    G->>P: Stream to Pub/Sub (5G/Satellite)
    P->>P: Ingest and normalize
```

**Key Metrics:**
- Edge preprocessing reduces bandwidth by ~80%
- Cluster aggregation further reduces by ~50%
- Target: Edge-to-Cloud latency <5 seconds

### 2. AI Processing Flow

```mermaid
sequenceDiagram
    participant I as Data Ingestion
    participant G as AI.GENERATE
    participant F as AI.FORECAST
    participant V as Vector Search
    participant R as RAG Engine
    participant D as Decision Engine

    I->>G: Raw JSON payload
    G->>G: Semantic field mapping
    G->>F: Normalized record
    F->>F: ARIMA_PLUS forecast
    F->>D: Prediction + 95% CI
    
    D->>V: "Historical floods in this valley?"
    V->>R: Retrieved documents
    R->>D: Contextual enrichment
    
    D->>D: Threshold evaluation
    D-->>D: Alert triggered if breach
```

**AI Processing Stages:**

| Stage | Input | Output | Latency |
|-------|-------|--------|---------|
| AI.GENERATE | Raw JSON | Normalized schema | ~100ms |
| AI.FORECAST | Time-series | 6-hour prediction + CI | ~500ms |
| Vector Search | Query text | Top-K documents | ~50ms |
| RAG Enrichment | Docs + query | Contextual answer | ~200ms |

### 3. External Data Ingestion Flow

```mermaid
sequenceDiagram
    participant EXT as External Source
    participant MCP as MCP/A2A Client
    participant DOC as Document Ingestion
    participant EMB as Embedding Service
    participant VEC as Vector DB
    participant TRAIN as Training Pipeline

    EXT->>MCP: Weather API / Document / News feed
    MCP->>DOC: Structured context
    DOC->>DOC: Parse and chunk
    DOC->>EMB: Text chunks
    EMB->>VEC: Vector embeddings
    
    VEC-->>TRAIN: Periodic batch
    TRAIN->>TRAIN: Fine-tune models
    TRAIN-->>VEC: Updated model weights
```

**Supported External Sources:**
- NASA FIRMS (thermal anomalies)
- Google Earth Engine (geospatial)
- Weather APIs (OpenWeatherMap, etc.)
- Seismic networks (USGS)
- Social media feeds
- Research documents (PDF, reports)
- News archives
- Any API via MCP/A2A adapters

### 4. Alert Generation Flow

```mermaid
sequenceDiagram
    participant D as Decision Engine
    participant C as CAP Serializer
    participant T as Translation MW
    participant IPAWS as IPAWS
    participant WEA as WEA Carriers
    participant HW as Hardware Driver
    participant B as Blockchain

    D->>C: Alert object (severity=Extreme, area=S2Cell)
    D->>B: Log decision (immutable)
    C->>C: Map to CAP enums
    C->>T: CAP XML (English)
    T->>T: Generate ES, FR, ZH info blocks
    T->>IPAWS: Multi-language CAP
    IPAWS->>WEA: Geo-targeted broadcast
    T->>HW: Local actuator commands
    HW->>HW: Trigger sirens, LED signs
```

**Alert Timing Requirements:**

| Stage | Target Latency |
|-------|----------------|
| Detection to Decision | <1 second |
| CAP Generation | <200ms |
| Translation | <200ms |
| IPAWS Delivery | <3 seconds |
| Hardware Actuation | Immediate |

### 5. Feedback Loop Flow

```mermaid
sequenceDiagram
    participant U as Civilian User
    participant A as Mobile App
    participant P as Central Platform
    participant D as Decision Engine
    participant AI as AI Engine

    P->>A: Push alert (CAP)
    A->>U: Display warning
    U->>A: Tap "Confirm" or "Deny"
    A->>P: Verification feedback
    P->>D: Update confidence
    D->>AI: Adjust model weights
    AI-->>D: Improved predictions
```

**Feedback Impact:**
- "Confirmed" by multiple users → Escalate to "Observed"
- "Denied" by multiple users → Flag for false positive review
- Feeds into continuous reinforcement learning (REQ-AI-004)

### 6. Swarm Command Flow

```mermaid
sequenceDiagram
    participant O as Operator
    participant C2 as C2 Interface
    participant D as Decision Engine
    participant VG as VisualGridDev
    participant G as Comm Gateway
    participant M as Mesh Nodes

    O->>C2: "Search Area A"
    C2->>D: Intent command
    D->>D: Generate waypoints
    D->>VG: Logic update
    VG->>VG: Compile flow
    VG->>G: Deploy to fleet
    G->>M: A2A broadcast
    M->>M: Execute formation
    M-->>G: Status update
    G-->>C2: Visualization update
```

**Command Types:**
- High-level intent: "Cover Sector 4", "Monitor Perimeter B"
- Swarm auto-translates to individual waypoints
- Hot-swap logic without firmware updates

## Data Schema Summary

### Sensor Data Event
```json
{
  "event_id": "uuid",
  "timestamp": "ISO8601",
  "source_node": "node-id",
  "location_s2": "S2CellID",
  "readings": {
    "temperature_c": 45.2,
    "humidity_pct": 23,
    "co2_ppm": 800,
    "wind_speed_kmh": 25
  },
  "confidence": 0.95,
  "preprocessing_version": "v2.1"
}
```

### CAP Alert Object
```json
{
  "alert_id": "uuid",
  "urgency": "Immediate",
  "severity": "Extreme", 
  "certainty": "Observed",
  "event_type": "Fire",
  "area_polygon": [[lat, lon], ...],
  "headline": "Wildfire detected in Sector 7",
  "description": "...",
  "instruction": "Evacuate immediately",
  "languages": ["en", "es", "fr"]
}
```

## Requirements Traceability

| Data Flow | PRD Requirement | Implementation |
|-----------|-----------------|----------------|
| Edge preprocessing | REQ-EDGE-003 | Feature extraction before TX |
| Multi-modal fusion | REQ-EDGE-006 | Cluster-level correlation |
| Hybrid mesh routing | REQ-COM-004, REQ-COM-005 | AODV + TORA protocols |
| Big data ingestion | REQ-PLAT-001 | Pub/Sub + Dataflow |
| AI forecasting | REQ-AI-001, REQ-AI-003 | ARIMA_PLUS, LSTM |
| External learning | User Req #8 | MCP/A2A document ingestion |
| CAP compliance | REQ-EXT-005 | CAP v1.2 serialization |
| Blockchain audit | REQ-PLAT-006 | Decision logging |
| Feedback loop | REQ-AI-004 | Crowdsourced verification |

---

*This document describes the complete data flow architecture of the SwarmSystem.*
