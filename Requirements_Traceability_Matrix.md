# Requirements Traceability Matrix

## Status convention

**Specified** means a requirement exists in the PRD. **Demonstrated only** means a local illustrative artefact exists; it is not production, field, safety, or compliance evidence. **Unverified** means no acceptance result is present. No row is “implemented” or “compliant” at this repository's current maturity.

## Traceability baseline

| Requirement group | IDs | Design location | Current status | Required verification before any operational claim |
|---|---|---|---|---|
| System purpose and mesh | REQ-GEN-001–006 | PRD; C4 context; assumptions | Specified | Scale, mobility, join/leave, partition, and energy tests under defined operating conditions |
| Edge sensing and control | REQ-EDGE-001–009 | PRD; data flow; security | Specified | Sensor calibration, environmental, cybersecurity, and safety evidence; no autonomous action without approval |
| Communications | REQ-COM-001–012 | PRD; technical protocols; ADR-002 | Specified | RF/legal assessment, loss/jamming tests, throughput/latency measurement, and fallback validation |
| Platform and analytics | REQ-PLAT-001–008 | PRD; data flow; ADR-003 | Demonstrated only for selected SQL | Reproducible data pipeline, performance/cost tests, backup/recovery, security and privacy assessment |
| AI and learning | REQ-AI-001–006; REQ-LOOP-001–003 | PRD; compliance; risks | Specified | Intended-purpose definition, dataset governance, evaluation, uncertainty, monitoring, human-oversight and change-control evidence |
| External integrations | REQ-EXT-001–007 | PRD; boundaries | Specified | Permission/licence, versioned contract, sandbox interoperability, and authority acceptance evidence |
| Human-system interaction | REQ-HSI-001–005 | PRD; user flows | Specified | Accessibility, usability, training, human-factors, and authority workflow evaluation |
| Performance and reliability | REQ-PERF-001–004; REQ-REL-001–004 | PRD; scalability; deployment | Unverified | Defined SLOs, operational design domain, test plan, reproducible measurements, confidence bounds, and recovery evidence |
| Security | REQ-SEC-001–003 | Security; risks | Specified | Threat-model review, key/device lifecycle tests, adversarial tests, pen test, incident-response exercise |
| Algorithmic flow | REQ-ALG-001–005 | PRD; data flow | Demonstrated only for simulation concepts | Scenario, failure, and adversarial tests with traceable expected outcomes |

## Requirement quality rules

Before implementation, each requirement must define: intended user and hazard; priority; measurable acceptance criterion; operating conditions; safety and privacy impacts; owner; dependencies; verification method; and evidence location. Replace absolute or unsupported claims such as “zero downtime,” “linear scaling,” or fixed accuracy/latency numbers with a measurable, context-bounded acceptance target.

## Explicit gaps

The PRD contains ambitious technology and performance statements that remain hypotheses. It needs a future requirements-baselining pass to establish priority, feasibility, jurisdiction, operational design domain, and acceptance metrics. The repository intentionally does not claim closure of those gaps.
