# Security Architecture

## Status and objective

This document specifies controls a future implementation must satisfy. It does not claim that any control is deployed, tested, or sufficient. The objective is to prevent untrusted inputs, identities, dependencies, or operators from causing unsafe evidence, privacy harm, or unauthorised external action.

## Security principles

- Treat every field source, relay, external feed, analytic output, and operator request as untrusted until verified for its context.
- Separate observation, analysis, review, and dissemination duties; no single system identity may silently cross all boundaries.
- Minimise privileges, data, retention, and blast radius; make high-impact actions attributable and reversible.
- Preserve evidence and fail closed for public outputs when identity, integrity, freshness, quality, or supervision is uncertain.
- Design cryptography and key lifecycle for constrained devices, loss, rotation, revocation, recovery, and decommissioning.

## Required control domains

| Domain | Minimum design requirement | Verification evidence |
|---|---|---|
| Asset and identity | Hardware/software inventory, owner, lifecycle state, unique non-secret identity, admission and revocation process | Inventory reconciliation, enrolment/revocation tests |
| Device integrity | Measured boot or equivalent integrity approach, signed update design, rollback and loss response | Tamper/update/rollback tests |
| Transport | Mutual authentication, modern protocol selection, key rotation, replay/freshness controls, message size/rate limits | Protocol and adversarial tests |
| Data quality | Schema, bounds, timestamp, calibration, provenance, duplicate/conflict, and outlier checks with quarantine path | Poisoning, replay, calibration, and false-data tests |
| Platform access | Least privilege, environment separation, strong operator authentication, role separation, secrets management, audit trails | Access review, privileged-action and audit tests |
| Software supply chain | Pinned dependencies, SBOM, provenance, secret scanning, vulnerability review, reproducible release policy | CI records and independent review |
| External integrations | Explicit allow-list, contractual authority, scoped credentials, versioned interfaces, failure fallback | Sandbox, expiry, revocation, and outage tests |
| Alert boundary | No credential or workflow enabling public dissemination without authorised partner control, approval, schema/profile validation, and audit | Tabletop and partner acceptance exercises |

## Threat model baseline

| Threat | Security response |
|---|---|
| Rogue, cloned, or Sybil node | Managed identity lifecycle, admission control, rate limits, provenance, quarantine; never rely solely on reputation scores |
| Replay, tampering, or route manipulation | Origin authentication, integrity protection, sequence/freshness checks, route constraints, telemetry and recovery |
| Sensor poisoning or fault | Calibration, independent corroboration, outlier/conflict handling, bounded confidence, human review |
| Credential theft or insider misuse | Least privilege, MFA, separation of duties, time-bound access, immutable audit records, periodic review |
| Dependency or cloud outage | Graceful degradation, bounded queues, local evidence preservation, explicit operator notification, recovery exercises |
| Supply-chain compromise | Reviewable provenance, dependency and secret scanning, SBOM, signed releases, vulnerability response |
| Public-alert spoofing | Keep alert authority outside this repository; validate CAP/profile only in an approved authority workflow |

## Data protection interface

Security controls cannot compensate for unnecessary collection. Future designs must keep raw media and precise location exceptional, bind access to purpose, log exceptional access, and apply retention/deletion controls. See [Compliance and Ethics](../Compliance_and_Ethics.md) and [Assumptions and Boundaries](ASSUMPTIONS_AND_BOUNDARIES.md).

## Security release evidence

Before any operational use, publish or retain for authorised reviewers: asset inventory; data-flow and threat model; control-to-threat mapping; key and device lifecycle; security test plan and results; third-party dependency assessment; penetration-test report; incident response and recovery exercise; vulnerability disclosure process; and residual-risk approval. Security controls are not accepted on the basis of diagrams or source code alone.
