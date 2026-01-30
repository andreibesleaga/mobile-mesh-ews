# Auxiliary Systems Diagram (Optional)

## Overview

This diagram visualizes the optional subsystem containers identified during verification (`IoT Manager`, `Ledger Service`, `Notification Service`) which handle specific operational duties distinct from the main data path.

## Integrated Subsystems Architecture

```mermaid
C4Container
    title Optional Container Diagram - Integrated Support Systems

    System_Boundary(swarm_boundary, "SwarmSystem Extensions") {
        
        Container(central_platform, "Central Platform", "Core System", "Main decision engine and event bus")
        Container(mobile_mesh, "Mobile Sensor Mesh", "Edge", "Physical sensors")

        Container_Boundary(ops_layer, "Operational Support Layer") {
            Component(iot_manager, "IoT Manager", "Go/Python", "SIM provisioning, remote device management")
            Component(ledger_svc, "Ledger Service", "Rust/Node", "Blockchain adapter for Hyperledger/Ethereum")
            Component(notify_svc, "Notification Service", "Node.js", "Multi-channel messaging (SMS, WhatsApp)")
        }
    }

    System_Ext(sim_provider, "Telecom Provider", "SIM Activation API")
    System_Ext(blockchain_net, "Distributed Ledger", "Hyperledger Fabric / Ethereum")
    System_Ext(msg_gateway, "Messaging Gateway", "Twilio / WhatsApp Business API")
    System_Ext(user_device, "User Device", "SMS / WhatsApp")

    Rel(central_platform, ledger_svc, "Audit log events", "gRPC")
    Rel(ledger_svc, blockchain_net, "Commit block", "Web3/Fabric SDK")

    Rel(central_platform, notify_svc, "Non-emergency alerts", "Pub/Sub")
    Rel(notify_svc, msg_gateway, "Send message", "HTTPS")
    Rel(msg_gateway, user_device, "Deliver text", "SMS/IP")

    Rel(central_platform, iot_manager, "Device health status", "Internal API")
    Rel(iot_manager, sim_provider, "Manage SIMs", "REST")
    Rel(iot_manager, mobile_mesh, "Remote config", "CoAP/LwM2M")

    UpdateLayoutConfig($c4ShapeInRow="3", $c4BoundaryInRow="1")
```

## Component Responsibilities

| Container | Responsibility | Integration Point |
|-----------|----------------|-------------------|
| **IoT Manager** | Managing SIM lifecycle (activate/deactivate), remote firmware updates, device health checks. | `IoT_Operations` directory |
| **Ledger Service** | Adapter for writing immutable audit logs to blockchain (Hyperledger/Ethereum). Abstracts chain complexity from core platform. | `Distributed_Ledgers_Operations` directory |
| **Notification Service** | Managing low-latency, high-volume notifications via consumer channels (WhatsApp, Telegram, SMS) distinct from official CAP alerts. | `Communications_APIs` directory |
