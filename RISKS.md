# Risk Register

## Use of this register

This is the authoritative design-time register. Status means the status of the **mitigation evidence**, not a claim that a risk has disappeared. No risk below is accepted for operational use without a named future owner, deployment context, and recorded residual-risk decision.

Likelihood and impact are qualitative design estimates: Low (L), Medium (M), High (H), Critical (C). They must be replaced by evidence during a real safety and operational assessment.

| ID | Risk | L | I | Required mitigation and release gate | Status |
|---|---|---:|---:|---|---|
| R-01 | Untrusted, faulty, replayed, or Sybil sensor inputs lead to false evidence | H | C | Device lifecycle, mutually authenticated transport, freshness/replay controls, calibration, provenance, anomaly handling, quarantine, adversarial testing | Open |
| R-02 | Analyst or system mistakes a model score for an authoritative warning | M | C | Strict decision-support boundary, authorised human approval, evidence package, cancellation path, exercises, and partner acceptance | Baseline documented; evidence open |
| R-03 | Dynamic mesh control-plane load, mobility, or energy depletion prevents timely delivery | H | H | Tiered-topology experiments, traffic model, backpressure, priority rules, offline behaviour, fault/energy tests | Open |
| R-04 | Cloud or external analytic dependency cannot meet time-sensitive needs or costs | H | H | Separate streaming and historical paths, budget guardrails, dependency fallback, measured load and failure tests | Baseline documented; evidence open |
| R-05 | Personal data, location trails, or media create surveillance or re-identification harm | H | C | Data minimisation, data map, DPIA where required, access/retention controls, transfer review, and independent privacy review | Baseline documented; evidence open |
| R-06 | AI model drift, bias, uncertainty, or automation bias causes harmful recommendations | H | C | Intended-purpose limits, representative evaluation, uncertainty and provenance display, human override, monitoring, change control | Open |
| R-07 | Compromise of devices, keys, software supply chain, or operator accounts | H | C | Threat model, hardware/key lifecycle, least privilege, signed releases, SBOM, vulnerability response, pen test, incident exercise | Open |
| R-08 | Physical field-node action harms people, property, or aircraft operations | M | C | Explicit operational design domain, regulator approvals, safe state, geofencing, human control, hazard analysis, controlled pilots | Out of scope pending future programme |
| R-09 | Unauthorised, malformed, or misrouted public message causes panic or misses recipients | M | C | Authority-controlled CAP workflow, schema/profile validation, dual approval, audit, channel tests, cancellation and drills | Out of scope pending future programme |
| R-10 | Third-party data, APIs, licences, or brands are used without permission or with misleading attribution | M | H | Contract/licence register, service approval, source/version capture, attribution and availability review | Open |
| R-11 | Dual-use expansion enables surveillance, targeting, or coercive control | M | C | Scope exclusion, contribution review, access governance, ethics review, and partner due diligence | Baseline documented; evidence open |
| R-12 | Public documentation overstates maturity or validation | H | H | Claim policy, status page, traceability, review checklist, automated document checks | Mitigated in documentation; recurring review required |

## Escalation policy

Critical risks are release blockers. A future owner may accept a residual high risk only with a documented rationale, compensating controls, expiry date, accountable executive, and approval by the competent safety, security, privacy, and operational authorities. Residual risk cannot be accepted by a repository contributor alone.

## Review triggers

Review this register after a change in intended purpose, data types, AI model, dependency, physical hardware, jurisdiction, warning channel, security incident, safety event, field test, or material architecture decision.
