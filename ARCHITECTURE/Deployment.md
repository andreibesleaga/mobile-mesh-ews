# Deployment Architecture - SwarmSystem

## Deployment Overview

The SwarmSystem follows a multi-tier deployment model spanning edge devices, communication infrastructure, and cloud services. This document describes the physical and logical deployment topology.

## Deployment Diagram

```mermaid
C4Deployment
    title Deployment Diagram - SwarmSystem

    Deployment_Node(field, "Field Environment", "Physical World") {
        Deployment_Node(drone, "UAV Fleet", "DJI/Custom") {
            Container(drone_node, "Swarm Node", "ARM + TFLite", "Thermal, visual sensors")
        }
        Deployment_Node(vehicle, "Ground Vehicles", "EVs, Rovers") {
            Container(vehicle_node, "Swarm Node", "ESP32", "Air quality, weather sensors")
        }
        Deployment_Node(static, "Static IoT", "Poles, Buoys") {
            Container(static_node, "Edge Sensor", "LoRaWAN", "Fixed monitoring points")
        }
        Deployment_Node(wearable, "Personnel Devices", "AR/Mobile") {
            Container(field_app, "Field App", "iOS/Android", "AR overlay, mesh relay")
        }
    }

    Deployment_Node(comm, "Communication Infrastructure", "Multi-Modal") {
        Deployment_Node(cellular, "5G/6G Network", "Carrier Infra") {
            Container(cell_gateway, "Cell Gateway", "5G NR", "Primary backhaul")
        }
        Deployment_Node(satellite, "LEO Constellation", "Starlink/Iridium") {
            Container(sat_terminal, "Sat Terminal", "Phased Array", "Remote area backhaul")
        }
        Deployment_Node(lora, "LoRaWAN Network", "Private/TTN") {
            Container(lora_gateway, "LoRa Gateway", "SX1302", "Low-power IoT")
        }
    }

    Deployment_Node(cloud, "Google Cloud Platform", "GCP") {
        Deployment_Node(ingest_zone, "Ingestion Zone", "us-central1") {
            Container(pubsub, "Pub/Sub", "Managed", "Event streaming")
            Container(dataflow, "Dataflow", "Apache Beam", "Stream processing")
        }
        Deployment_Node(data_zone, "Data Zone", "us-central1") {
            ContainerDb(timescale, "TimescaleDB", "Cloud SQL", "Time-series data")
            ContainerDb(postgres, "PostgreSQL", "Cloud SQL", "Settings, configs")
            ContainerDb(bigquery, "BigQuery", "Serverless", "Analytics, ML")
        }
        Deployment_Node(compute_zone, "Compute Zone", "Multi-Region") {
            Container(cloud_run, "Cloud Run", "Serverless", "Decision engine, APIs")
            Container(vertex, "Vertex AI", "Managed ML", "Model training, inference")
            Container(gke, "GKE", "Kubernetes", "Framework AI, VisualGridDev")
        }
    }

    Deployment_Node(eoc, "Emergency Operations Center", "On-Premise/Hybrid") {
        Container(c2_console, "C2 Console", "WebApp", "Operator interface")
        Container(local_cache, "Local Cache", "Redis", "Offline resilience")
    }
```

## Deployment Tiers

### Tier 1: Edge Devices

| Device Type | Hardware | Sensors | Connectivity | Deployment Scale |
|-------------|----------|---------|--------------|------------------|
| **UAV (Drone)** | ARM Cortex + GPU, TFLite | Thermal, Visual, Lidar | 5G/Satellite, Mesh | 100s per region |
| **Ground Vehicle** | ESP32, NVIDIA Jetson | Air quality, Weather, Road | 5G, WiFi, Mesh | 1000s per city |
| **Aquatic Buoy** | Solar, Low-power MCU | Water level, Temp, pH | LoRaWAN, Satellite | 10s per waterway |
| **Static Sensor** | ESP32, Energy harvesting | Temp, Humidity, Seismic | LoRaWAN | 1000s per region |
| **Wearable/Mobile** | Smartphone, AR headset | Location, Accelerometer | 5G, WiFi, BLE | Field personnel |

### Tier 2: Communication Infrastructure

| Component | Technology | Coverage | Redundancy |
|-----------|------------|----------|------------|
| **5G/6G Towers** | 5G NR, CAMARA APIs | Urban/suburban | Multi-carrier |
| **LEO Satellites** | Starlink, Iridium | Global | Constellation overlap |
| **LoRaWAN** | SX1302 gateways | Rural, fixed points | Gateway clustering |
| **Ad-hoc Mesh** | 802.15.4, BLE Mesh | Peer-to-peer | Self-healing |

### Tier 3: Cloud Platform (GCP)

| Service | Purpose | Region Strategy | SLA |
|---------|---------|-----------------|-----|
| **Pub/Sub** | Message ingestion | Multi-region | 99.95% |
| **Dataflow** | Stream processing | Regional | 99.9% |
| **BigQuery** | Analytics, ML | US/EU multi-region | 99.99% |
| **Cloud SQL** | Operational DBs | Regional + replicas | 99.95% |
| **Cloud Run** | Serverless compute | Multi-region | 99.95% |
| **Vertex AI** | Model serving | Regional | 99.9% |
| **GKE** | Container orchestration | Regional | 99.95% |

### Tier 4: Operations Center

| Component | Location | Purpose |
|-----------|----------|---------|
| **C2 Console** | EOC on-premise | Primary operator interface |
| **Local Cache** | EOC on-premise | Offline resilience if cloud unavailable |
| **VPN Gateway** | EOC on-premise | Secure cloud connectivity |

## Geographic Distribution

```mermaid
flowchart TB
    subgraph GLOBAL["Global Layer"]
        SAT["LEO Satellites<br/>(Global Coverage)"]
        NASA["NASA/GEE APIs<br/>(Global Data)"]
    end

    subgraph REGIONAL["Regional Layer (per continent)"]
        GCP_R["GCP Region<br/>(BigQuery, Vertex AI)"]
        EOC_R["Regional EOC"]
    end

    subgraph LOCAL["Local Layer (per metro)"]
        CELL["5G Towers"]
        LORA["LoRa Gateways"]
    end

    subgraph EDGE["Edge Layer (field)"]
        DRONES["Drone Swarms"]
        VEHICLES["Ground Sensors"]
        STATIC["Static IoT"]
    end

    SAT <--> GCP_R
    NASA --> GCP_R
    GCP_R <--> EOC_R
    GCP_R <--> CELL
    CELL <--> DRONES
    CELL <--> VEHICLES
    LORA <--> STATIC
    DRONES <--> DRONES
    VEHICLES <--> VEHICLES
```

## Disaster Recovery Strategy

### Failure Scenarios

| Scenario | Impact | Mitigation |
|----------|--------|------------|
| **Cloud region outage** | Platform unavailable | Multi-region failover, edge continues locally |
| **5G network down** | Urban backhaul lost | Automatic satellite failover |
| **Satellite outage** | Remote backhaul lost | DTN store-and-forward, mesh ferrying |
| **EOC destroyed** | Command center lost | Secondary EOC activation, cloud-direct ops |
| **Power grid failure** | Infrastructure down | Solar/battery on edge, generator at EOC |

### Recovery Objectives

| Metric | Target | Mechanism |
|--------|--------|-----------|
| **RTO (Recovery Time)** | <15 minutes | Automated failover |
| **RPO (Data Loss)** | <1 minute | Continuous replication |
| **Edge Autonomy** | Indefinite | Local mesh operation without cloud |

## Environment Configuration

### Development
- GCP Project: `swarm-dev`
- Single region, scaled-down resources
- Synthetic sensor data from simulators

### Staging
- GCP Project: `swarm-staging`
- Multi-region, production-like
- Limited real sensors + synthetic traffic

### Production
- GCP Project: `swarm-prod`
- Full multi-region deployment
- All real sensors, full redundancy
- 24/7 monitoring with PagerDuty

## Requirements Traceability

| Requirement | PRD Reference | Deployment Implementation |
|-------------|---------------|---------------------------|
| Heterogeneous sensors | REQ-GEN-005 | Multiple device types in Tier 1 |
| Satellite backhaul | REQ-COM-010 | LEO constellation in Tier 2 |
| Multi-region resilience | REQ-REL-003 | GCP multi-region deployment |
| No single point of failure | REQ-REL-003 | Mesh + satellite + DTN redundancy |
| Edge autonomy | REQ-GEN-001 | Local operation without cloud |

---

*This document describes the physical deployment architecture of the SwarmSystem.*
