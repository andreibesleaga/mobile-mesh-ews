# Project Status and Verification

## Current maturity

This repository is at **architecture and research-prototype maturity**. Its Markdown documents specify intent; the included SQL and simulation artefacts illustrate selected ideas. No evidence in this repository demonstrates an operational deployment, a connection to an alert authority, a field trial, a safety case, an approved data-protection impact assessment, an AI conformity assessment, or a security assessment.

| Capability | Current evidence | Public claim permitted |
|---|---|---|
| Requirements and architecture | Markdown specifications and diagrams | A proposed architecture exists |
| Mesh behaviour | A small deterministic simulation | A simulation illustrates local-agent behaviour |
| Analytics | Exploratory SQL and generated-data material | An analytical prototype is documented |
| Alerting | Design material only | CAP is a target interchange format; no alerts are issued |
| AI and privacy | Design intent only | Controls are requirements, not implemented safeguards |
| Availability, scale, latency, and accuracy | No reproducible benchmark evidence | No performance claim |

## Document precedence

Where two documents disagree, the earlier tier wins:

1. **This document** — maturity, claim policy, and release gates.
2. **Boundary and assurance:**
   [ARCHITECTURE/ASSUMPTIONS_AND_BOUNDARIES.md](ARCHITECTURE/ASSUMPTIONS_AND_BOUNDARIES.md),
   [ARCHITECTURE/Security.md](ARCHITECTURE/Security.md),
   [Compliance_and_Ethics.md](Compliance_and_Ethics.md),
   [RISKS.md](RISKS.md), [OBSERVABILITY.md](OBSERVABILITY.md).
3. **Decisions and traceability:**
   [ARCHITECTURE/DECISIONS.md](ARCHITECTURE/DECISIONS.md) and
   [Requirements_Traceability_Matrix.md](Requirements_Traceability_Matrix.md).
4. **Requirements hypothesis:**
   [PRD_Swarm_System_Requirements_Specification.md](PRD_Swarm_System_Requirements_Specification.md).
   It states proposed requirements and is subordinate to tiers 1-3.
5. **Architecture views:** C4, data flow, deployment, scalability, protocols,
   user flows.
6. **Background and exploratory material:** `Business_Strategy.md`,
   `INNOVATION.md`, `References.md`, `UN_Early_Warnings_Reference.md`,
   `PRD_Other_Integrations.md`, the subsystem directories, `Algorithms/`, and
   `BigData_AI_Decision_System/`.

A lower tier never overrides a higher one. **No tier authorises a public alert, a
physical action, a third-party service integration, or the processing of personal
data.**

## Claim policy

Use **proposed**, **illustrative**, **target**, or **requires validation** for design statements. Do not use **live**, **production-ready**, **real-time**, **compliant**, **secure**, **resilient**, **self-healing**, **autonomous**, or quantified performance language unless the claim links to reproducible evidence, test conditions, date, version, and limitation. “CAP-compatible” may be claimed only after schema and profile conformance tests; authority onboarding is a separate claim.

## Release gates

No operational deployment or public-warning use is authorised by this repository. A future sponsor must close every gate below with independently reviewable evidence.

| Gate | Minimum evidence | Accountable role |
|---|---|---|
| Governance and jurisdiction | Named operator, hazard authority, operating jurisdiction, legal basis, escalation and shutdown authority | Programme owner |
| Safety | Hazard analysis, operational design domain, safe-state design, human-factors review, emergency procedures, and field-test approvals | Safety lead |
| Security | Asset inventory, threat model, key lifecycle, penetration test, incident response exercise, and supply-chain review | Security lead |
| Privacy and data governance | Data inventory, lawful basis, DPIA where required, retention/deletion design, processor agreements, and data-subject process | Data protection lead |
| AI assurance | Intended-purpose classification, model/data documentation, evaluation by hazard and population, monitoring, override and change control | AI assurance lead |
| Interoperability | Versioned contracts, CAP schema/profile tests, partner sandbox evidence, and authority acceptance | Integration lead |
| Operational resilience | Measured load, fault, recovery, offline, and communications-loss tests under stated conditions | Operations lead |
| Field validation | Controlled pilots, independent results, residual-risk acceptance, and competent-authority approval | Deployment authority |

## Verification record format

Each future claim must record: repository revision; component version; environment; data provenance; test procedure; pass/fail criterion; actual result; limitation; reviewer; date; and link to retained evidence. An absence of that record means **not verified**.

## Standards and reference position

The project uses the WMO/UN Early Warnings for All pillars as a conceptual frame. CAP 1.2 is the proposed alert-message interchange target, subject to applicable national profiles and the authorising alert authority. Regulatory classification and compliance are deployment-specific legal determinations, not conclusions of this repository.
