# User Flows and Scenarios - SwarmSystem

## User Flows Overview

This document describes the high-level user interactions, system state diagrams, and detailed scenarios for various disaster types supported by the SwarmSystem.

## Actor Flows

### Emergency Operator Flow

```mermaid
flowchart TB
    subgraph OPERATOR["Emergency Operator Workflow"]
        LOGIN["Login to C2 Console"]
        MONITOR["Monitor Dashboard<br/>(Heatmaps, Status)"]
        ASSESS["Assess Threat<br/>(Review AI Predictions)"]
        COMMAND["Issue Command<br/>(Intent-Based)"]
        VERIFY["Verify Execution<br/>(Swarm Response)"]
        ESCALATE["Escalate Alert<br/>(Manual Override)"]
    end

    LOGIN --> MONITOR
    MONITOR --> ASSESS
    ASSESS -->|Threat Detected| COMMAND
    ASSESS -->|No Threat| MONITOR
    COMMAND --> VERIFY
    VERIFY -->|Success| MONITOR
    VERIFY -->|Issue| ESCALATE
    ESCALATE --> COMMAND
```

**Key Interactions:**
- Intent-based commands: "Search Area A", "Monitor Perimeter B"
- Swarm visualizations: Heatmaps, flow vectors (not individual dots)
- Confidence metrics displayed for all AI predictions

**PRD Reference:** REQ-HSI-001, REQ-HSI-002

### Field Personnel Flow

```mermaid
flowchart TB
    subgraph FIELD["Field Personnel Workflow"]
        RECEIVE["Receive Deployment<br/>(Mobile Alert)"]
        CONNECT["Connect to Mesh<br/>(AR Tablet)"]
        NAVIGATE["Navigate via AR<br/>(Sensor Overlay)"]
        VERIFY_F["Verify Event<br/>(Ground Truth)"]
        REPORT["Report Status<br/>(Voice/Text)"]
        RESCUE["Execute Rescue<br/>(Mesh-Guided)"]
    end

    RECEIVE --> CONNECT
    CONNECT --> NAVIGATE
    NAVIGATE --> VERIFY_F
    VERIFY_F --> REPORT
    REPORT --> RESCUE
    RESCUE --> NAVIGATE
```

**Key Features:**
- AR overlay shows sensor data (radiation, heat, gas)
- Mesh connection for local comms even without cell
- Real-time guidance to survivors

**PRD Reference:** REQ-HSI-003

### Civilian User Flow

```mermaid
flowchart TB
    subgraph CIVILIAN["Civilian User Workflow"]
        IDLE["Idle State<br/>(App Background)"]
        ALERT["Receive Alert<br/>(Push/WEA)"]
        VIEW["View Details<br/>(Map, Instructions)"]
        CONFIRM["Confirm/Deny<br/>(Crowdsource)"]
        ACT["Take Action<br/>(Evacuate/Shelter)"]
        OFFLINE["Use Offline Maps<br/>(If Disconnected)"]
    end

    IDLE --> ALERT
    ALERT --> VIEW
    VIEW --> CONFIRM
    CONFIRM --> ACT
    ACT --> IDLE
    VIEW -->|No Connectivity| OFFLINE
    OFFLINE --> ACT
```

**Key Features:**
- Override Do Not Disturb for Immediate alerts
- Multi-language support (auto-detect from device)
- Offline cached maps and evacuation routes

**PRD Reference:** PRD Other #6.1, #6.2

## System State Diagrams

### Node Lifecycle States

```mermaid
stateDiagram-v2
    [*] --> Initializing : Power On

    Initializing --> Discovering : Self-test passed
    Initializing --> Failed : Self-test failed

    Discovering --> Joining : Mesh found
    Discovering --> Isolated : No mesh (DTN mode)

    Joining --> Active : Authenticated
    Joining --> Rejected : Auth failed

    Active --> Monitoring : Normal ops
    Active --> Alerting : Anomaly detected
    Active --> Relocating : Command received

    Monitoring --> Alerting : Threshold breach
    Alerting --> Monitoring : Event resolved
    Alerting --> Emergency : Critical event

    Relocating --> Monitoring : At destination
    
    Emergency --> Active : Event resolved
    
    Active --> LowPower : Battery <20%
    LowPower --> Active : Solar recharged
    LowPower --> Hibernating : Battery <5%

    Hibernating --> [*] : Battery dead
    Failed --> [*] : Decommissioned
```

### Alert State Machine

```mermaid
stateDiagram-v2
    [*] --> Baseline : Normal conditions

    Baseline --> Anomaly : Sensor deviation
    
    Anomaly --> Verified : Multi-sensor fusion
    Anomaly --> FalsePositive : Single sensor, no correlation

    FalsePositive --> Baseline : Cleared

    Verified --> Forecasting : AI prediction running
    
    Forecasting --> Likely : Lower CI within threshold
    Forecasting --> Imminent : Upper CI exceeds threshold

    Likely --> Observed : Both CI exceed threshold
    Imminent --> Observed : Direct observation

    Observed --> Broadcasting : CAP generated
    
    Broadcasting --> Disseminated : IPAWS/WEA sent
    Disseminated --> Tracking : Ongoing monitoring

    Tracking --> Escalated : Conditions worsen
    Tracking --> Deescalated : Conditions improve

    Escalated --> Broadcasting : New CAP (Update)
    Deescalated --> Resolved : Threat passed

    Resolved --> Baseline : All clear
```

### Swarm Formation States

```mermaid
stateDiagram-v2
    [*] --> Dispersed : Initial deployment

    Dispersed --> Converging : Area assigned
    
    Converging --> SearchLine : Linear search pattern
    Converging --> CircularPerimeter : Boundary monitoring
    Converging --> Grid : Area coverage

    SearchLine --> Tracking : Target found
    CircularPerimeter --> Tracking : Breach detected
    Grid --> Tracking : Anomaly located

    Tracking --> CloseFocus : Detailed observation
    CloseFocus --> Tracking : Target moving

    Tracking --> Returning : Mission complete
    Returning --> Dispersed : Ready for new mission

    SearchLine --> Dispersed : Area cleared
    CircularPerimeter --> Dispersed : Stand down
    Grid --> Dispersed : Mapping complete
```

## Disaster Scenarios

### Scenario 1: Wildfire Early Detection

```mermaid
sequenceDiagram
    participant S as Static Sensors
    participant D as Drone Swarm
    participant M as Mesh Network
    participant P as Central Platform
    participant AI as AI Engine
    participant CAP as CAP Gateway
    participant C as Civilians

    Note over S: Phase 1: Monitor
    S->>M: Temp=38°C, Humidity=15% (normal high)
    M->>P: Aggregate readings
    P->>AI: Store in time-series

    Note over S: Phase 2: Detect
    S->>M: Temp SPIKE to 55°C + CO2 surge
    M->>P: Anomaly flagged
    P->>AI: Query: Is this fire?

    Note over D: Phase 3: Verify
    AI->>P: Dispatch drones for verification
    P->>D: "Investigate coordinates X,Y"
    D->>D: Swarm converges
    D->>M: Thermal confirms: Active fire
    D->>M: Visual confirms: Visible flames

    Note over AI: Phase 4: Predict
    AI->>AI: Wind=25km/h NW, Fuel moisture=5%
    AI->>AI: Fire spread model: 10km in 2 hours
    AI->>P: Prediction with 95% CI

    Note over CAP: Phase 5: Alert
    P->>CAP: Generate alert for affected polygon
    CAP->>CAP: Translate to ES, FR
    CAP->>C: WEA broadcast + Push notification

    Note over D: Phase 6: Adapt
    D->>D: Reconfigure to perimeter formation
    D->>M: Track fire line in real-time
    D->>P: Continuous updates
```

**Requirements Covered:** REQ-EDGE-004, REQ-EDGE-006, REQ-AI-001, REQ-EXT-005, REQ-EXT-006

---

### Scenario 2: Flood Early Warning

```mermaid
sequenceDiagram
    participant W as Water Sensors
    participant E as External Data
    participant P as Central Platform
    participant AI as AI Engine
    participant V as Vector Search
    participant CAP as CAP Gateway
    participant HW as Hardware (Sirens)

    Note over W: Phase 1: Monitor
    W->>P: Water level = 3.2m (normal)
    E->>P: Weather API: Heavy rain forecast

    Note over AI: Phase 2: Forecast
    AI->>AI: ARIMA_PLUS: Level will rise
    AI->>AI: 6-hour forecast: Peak at 4.8m
    AI->>P: 95% CI: 4.2m - 5.4m

    Note over V: Phase 3: Context
    P->>V: "Historical floods in this valley"
    V->>AI: 2015 flood breached at 4.5m
    AI->>P: Elevated risk: historical precedent

    Note over W: Phase 4: Trigger
    W->>P: Water level = 4.1m (rising fast)
    P->>AI: Threshold evaluation
    AI->>P: CI lower bound approaching flood stage

    Note over CAP: Phase 5: Alert
    P->>CAP: Urgency=Expected, Certainty=Likely
    CAP->>CAP: Generate multi-language CAP
    CAP->>HW: Trigger local sirens
    HW->>HW: Activate warning signs

    Note over W: Phase 6: Escalate
    W->>P: Water level = 4.6m (breached)
    P->>CAP: Update: Certainty=Observed
    CAP->>CAP: WEA broadcast: EVACUATE NOW
```

**Requirements Covered:** REQ-PLAT-007, REQ-AI-003, PRD Other #3.2, PRD Other #4.3

---

### Scenario 3: Earthquake Response

```mermaid
sequenceDiagram
    participant SEI as Seismic Sensors
    participant M as Mobile Mesh
    participant P as Central Platform
    participant CAP as CAP Gateway
    participant C as Civilians
    participant D as Drone Swarm

    Note over SEI: Phase 1: P-Wave Detection
    SEI->>M: P-wave detected (precursor)
    M->>M: Mesh-to-mesh alert (<200ms)
    M->>C: Immediate local warning

    Note over SEI: Phase 2: S-Wave Impact
    SEI->>P: Magnitude estimate: 6.2
    P->>CAP: Generate CAP: Earthquake
    CAP->>C: WEA: "DROP, COVER, HOLD ON"

    Note over M: Phase 3: Assess Damage
    M->>M: Some nodes offline (destroyed)
    M->>M: Self-healing routing
    M->>P: Partial connectivity restored

    Note over D: Phase 4: Deploy SAR Swarm
    P->>D: Deploy to affected area
    D->>D: Airdrop into rubble zone
    D->>M: Establish ad-hoc mesh

    Note over D: Phase 5: Search
    D->>D: Acoustic sensors: Listen for survivors
    D->>D: Thermal sensors: Heat signatures
    D->>M: "Human signature at coordinates X,Y"

    Note over C: Phase 6: Guide Rescue
    M->>C: Field personnel: Navigate to survivor
    C->>D: AR overlay shows safe path
    D->>C: Real-time hazard updates
```

**Requirements Covered:** REQ-COM-002, REQ-EDGE-004, Use Case 10.2

---

### Scenario 4: Tsunami Warning

```mermaid
sequenceDiagram
    participant NASA as NASA/USGS
    participant SEA as Ocean Buoys
    participant P as Central Platform
    participant AI as AI Engine
    participant CAP as CAP Gateway
    participant CAMARA as CAMARA APIs
    participant C as Coastal Population

    Note over NASA: Phase 1: Earthquake Trigger
    NASA->>P: Undersea earthquake M7.8
    P->>AI: Query historical tsunami risk

    Note over SEA: Phase 2: Wave Detection
    SEA->>P: Unusual wave pattern detected
    P->>AI: Correlate with earthquake

    Note over AI: Phase 3: Model
    AI->>AI: Tsunami propagation model
    AI->>AI: ETA to coast: 45 minutes
    AI->>P: Wave height estimate: 5-8m

    Note over CAP: Phase 4: Mass Alert
    P->>CAP: Urgency=Immediate, Severity=Extreme
    CAP->>CAMARA: Query population density
    CAMARA->>CAP: 500,000 in danger zone

    Note over C: Phase 5: Evacuation
    CAP->>C: WEA: "TSUNAMI WARNING - Move to high ground"
    CAP->>C: Push notification with evacuation routes
    C->>P: Crowdsource confirmation (people moving)

    Note over P: Phase 6: All Clear
    SEA->>P: Wave passed, levels normalizing
    P->>CAP: Update: All Clear
    CAP->>C: "Tsunami warning cancelled"
```

**Requirements Covered:** REQ-EXT-001, REQ-EXT-004, User Req #5 (CAMARA)

---

### Scenario 5: Tornado Warning

```mermaid
sequenceDiagram
    participant W as Weather Sensors
    participant SAT as Satellite Data
    participant P as Central Platform
    participant AI as AI Engine
    participant CAP as CAP Gateway
    participant C as Civilians

    Note over W: Phase 1: Conditions
    W->>P: Temp=35°C, Humidity=80%, Pressure dropping
    SAT->>P: Supercell forming (satellite imagery)

    Note over AI: Phase 2: Prediction
    AI->>AI: Pattern matches tornado precursors
    AI->>P: Tornado Watch issued

    Note over W: Phase 3: Detection
    W->>P: Rotation detected + hail reports
    W->>P: Funnel cloud sighted (visual sensor)

    Note over CAP: Phase 4: Warning
    P->>CAP: Upgrade: Tornado WARNING
    CAP->>C: WEA: "TORNADO WARNING - Take shelter NOW"
    CAP->>C: Include predicted path polygon

    Note over P: Phase 5: Track
    W->>P: Tornado confirmed, moving NE at 50km/h
    P->>CAP: Update path polygon
    CAP->>C: Updated warning area

    Note over P: Phase 6: All Clear
    W->>P: Tornado dissipated
    P->>CAP: All clear for affected area
```

---

### Scenario 6: Urban Mob / Civil Emergency

```mermaid
sequenceDiagram
    participant MOB as Mobile Phones (Mesh)
    participant CAMARA as CAMARA APIs
    participant P as Central Platform
    participant AI as AI Engine
    participant CAP as CAP Gateway
    participant AUTH as Authorities

    Note over CAMARA: Phase 1: Anomaly Detection
    CAMARA->>P: Network congestion spike in area X
    CAMARA->>P: Unusual device density
    MOB->>P: Accelerometer data: People running

    Note over AI: Phase 2: Analysis
    AI->>AI: Pattern: Mass gathering + panic
    AI->>P: Civil emergency detected

    Note over P: Phase 3: Situational Awareness
    P->>AUTH: Alert emergency services
    AUTH->>P: Request more info
    P->>MOB: Request crowdsource verification

    Note over CAP: Phase 4: Public Guidance
    P->>CAP: Issue area-specific guidance
    CAP->>MOB: "Avoid area X, emergency in progress"
    CAP->>MOB: Alternative routes displayed

    Note over AUTH: Phase 5: Coordinate Response
    AUTH->>P: Deploy units to area
    P->>MOB: Mesh provides local comms to first responders
    MOB->>AUTH: Real-time crowd density map

    Note over P: Phase 6: Resolution
    AUTH->>P: Situation contained
    P->>CAP: Update: All clear
```

**Requirements Covered:** User Req #5 (CAMARA), PRD Other #3.4

---

### Scenario 7: Search and Rescue (SAR)

```mermaid
sequenceDiagram
    participant CMD as Incident Commander
    participant C2 as C2 Console
    participant D as Drone Swarm
    participant F as Field Personnel
    participant M as Mesh Network

    Note over CMD: Phase 1: Deploy
    CMD->>C2: "Search Area B"
    C2->>D: Deploy swarm (airdrop)

    Note over D: Phase 2: Network
    D->>D: Self-organize into mesh
    D->>D: Establish local coverage
    D->>M: Backhaul connected

    Note over D: Phase 3: Search
    D->>D: Acoustic scan for voices
    D->>D: Thermal scan for body heat
    D->>D: Grid pattern coverage

    Note over D: Phase 4: Locate
    D->>D: "Heat signature + Sound detected"
    D->>M: Survivor location: coords X,Y,Z
    M->>C2: Display on map

    Note over F: Phase 5: Relay
    C2->>F: Navigate to survivor
    D->>F: AR overlay: Safe path through rubble
    D->>F: Real-time hazard alerts (gas, instability)

    Note over F: Phase 6: Extract
    F->>M: "Survivor extracted, need medical"
    M->>CMD: Medical team dispatched
    D->>D: Continue search pattern
```

**Requirements Covered:** Use Case 10.2, REQ-HSI-003

## Chatbot Interaction Flow (Framework AI)

```mermaid
sequenceDiagram
    participant U as User
    participant APP as Mobile App
    participant CHAT as Chatbot Engine
    participant EMB as Embedding Service
    participant VEC as Vector DB
    participant P as Platform

    U->>APP: "Is there a flood risk in my area?"
    APP->>CHAT: Natural language query
    
    CHAT->>EMB: Convert to vector
    EMB->>VEC: Semantic search
    VEC->>CHAT: Relevant context

    CHAT->>P: Query current status for user location
    P->>CHAT: Status: No current alerts, 10% risk

    CHAT->>APP: "No current flood alerts for your area. Historical risk is low. Last flood was in 2015. Would you like me to set up alerts for river level changes?"
    APP->>U: Display response + offer proactive alerts
```

**Requirements Covered:** User Req #6 (Framework AI chatbot)

## Requirements Summary

| Scenario | PRD Requirements Covered |
|----------|-------------------------|
| Wildfire | REQ-EDGE-004, REQ-EDGE-006, REQ-AI-001, REQ-EXT-005, REQ-EXT-006 |
| Flood | REQ-PLAT-007, REQ-AI-003, PRD Other #3.2, #4.3 |
| Earthquake | REQ-COM-002, REQ-EDGE-004, Use Case 10.2 |
| Tsunami | REQ-EXT-001, REQ-EXT-004, CAMARA (User #5) |
| Tornado | REQ-AI-001, REQ-EXT-005 |
| Urban Mob | CAMARA (User #5), PRD Other #3.4 |
| SAR | Use Case 10.2, REQ-HSI-003 |
| Chatbot | Framework AI (User #6) |

---

*This document describes user flows, system states, and disaster scenarios for the SwarmSystem.*
