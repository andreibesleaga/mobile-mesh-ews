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
