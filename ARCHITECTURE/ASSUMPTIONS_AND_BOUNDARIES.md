# Assumptions and Boundaries

## Purpose

Mobile Mesh EWS is a design for decision support around multi-hazard early warning. The boundary exists to prevent an analytical or sensor signal from being mistaken for an authoritative warning or a command to a physical system.

## In scope

- Candidate sensor, mesh, backhaul, ingestion, analysis, and audit concepts.
- Evidence packages that make uncertainty, provenance, and analyst review visible.
- A proposed workflow for an authorised warning authority to create and distribute a warning through its own approved systems.
- Research simulation and generated-data experimentation.

## Out of scope

- Issuing, relaying, or impersonating official warnings; access to IPAWS, WEA, CAP feeds, or emergency networks.
- Autonomous flight, driving, dispatch, navigation, surveillance, targeting, law enforcement, or defence operations.
- Collection of live personal data, biometric data, communications content, or location trails.
- Claims of service level, safety, cybersecurity, privacy, regulatory compliance, field readiness, or operational effectiveness.

## Trust boundaries

| Boundary | Input | Required control before use |
|---|---|---|
| Field source to gateway | Sensor readings, device telemetry, media | Enrolment, cryptographic identity, freshness, integrity, rate limits, calibration state, and quarantine path |
| Mesh to platform | Relayed data and routing state | Mutual authentication, replay protection, provenance preservation, and store-and-forward limits |
| External provider to platform | Satellite, weather, telecom, AI, and map data | Contractual authority, licence review, source/version capture, integrity checks, and availability fallback |
| Analytics to operator | Scores, forecasts, recommended actions | Explainability, uncertainty, source links, conflict display, and human review |
| Operator to external dissemination | Proposed CAP message or other output | Role separation, strong authentication, two-person approval where required, audit record, and partner acceptance |

## Safety states

The future system must default to **observe only**. On failed identity, stale data, quality failure, model uncertainty, conflict, loss of supervision, or dependency failure, it must suppress outward action, preserve the evidence package, notify the responsible operator through an approved channel, and require a new authorised decision. No automatic public warning or physical action is allowed by this design.

## Technology posture

6G, OTFS, federated learning, distributed ledgers, generative AI, satellite backhaul, and autonomous routing are options, not dependencies or current capabilities. Each requires an ADR, measurable benefit, threat and safety analysis, operational feasibility assessment, lifecycle owner, and rollback plan before selection.
