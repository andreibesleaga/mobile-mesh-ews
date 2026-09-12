# Mobile Mesh EWS

Mobile Mesh EWS is a public architecture and research repository for a possible multi-hazard early-warning system that combines field sensors, resilient communications, analytical services, and authorised warning operations.

## Status and safety boundary

**This repository is not an operational early-warning system.** It contains requirements, architecture proposals, SQL and simulation artefacts intended for research and design review. It does not operate sensors, validate hazards, issue public warnings, connect to emergency-alerting authorities, or control vehicles or aircraft. Nothing in this repository may be used to make life-safety, evacuation, dispatch, navigation, or regulatory decisions.

The design assumes that any future deployment is owned and operated by a competent authority with jurisdiction over the area and hazard. Automated analysis may produce evidence or recommendations only. A designated human authority must independently verify the evidence and authorise every external warning and every physical actuation. The design does not grant access to WEA, IPAWS, CAP feeds, satellite data, telecom APIs, radio spectrum, or any other third-party service.

The included Python simulation and BigQuery-oriented SQL are demonstrations, not validation evidence or a production baseline. They must not be interpreted as proof of availability, latency, accuracy, coverage, interoperability, privacy, security, or regulatory compliance.

## What is in scope

The proposed system separates four concerns:

1. **Observation:** authenticated field observations and approved external data sources.
2. **Decision support:** provenance-aware aggregation, uncertainty representation, and analyst review.
3. **Authorised warning workflow:** a human authority evaluates a proposed CAP message and controls any publication through its approved channels.
4. **Assurance:** safety, privacy, cybersecurity, accessibility, operational resilience, and audit evidence are designed before implementation.

The proposal is aligned conceptually with the four pillars of the World Meteorological Organization's Early Warnings for All initiative. It is not affiliated with, endorsed by, or connected to WMO, UN agencies, emergency authorities, Google, NASA, ESA, CAMARA, or telecom operators.

## Read first

| Document | Role |
|---|---|
| [Project status and verification](PROJECT_STATUS.md) | Evidenced maturity, known limits, and release gates |
| [Architecture index](ARCHITECTURE/ARCHITECTURE_INDEX.md) | Canonical architecture reading order and document authority |
| [Assumptions and boundaries](ARCHITECTURE/ASSUMPTIONS_AND_BOUNDARIES.md) | Scope, trust boundaries, and non-goals |
| [Security architecture](ARCHITECTURE/Security.md) | Required controls and security assurance evidence |
| [Compliance and ethics](Compliance_and_Ethics.md) | Privacy, AI-governance, and dual-use controls |
| [Risk register](RISKS.md) | Current risks, owners, gates, and residual-risk policy |
| [Requirements traceability matrix](Requirements_Traceability_Matrix.md) | Requirement status and verification strategy |
| [Decision log](ARCHITECTURE/DECISIONS.md) | Design decisions and unresolved choices |

## Repository guide

- `ARCHITECTURE/` contains proposed C4 views, data flows, protocols, and operational concepts.
- `Algorithms/Swarm-EWS-Simulation/` contains a small illustrative simulation; it is not a digital twin or a field test.
- `BigData_AI_Decision_System/` contains exploratory SQL and Earth Engine material; it is not a real-time alerting service.
- [OBSERVABILITY.md](OBSERVABILITY.md) fixes the observability contract any future runtime must satisfy.
- [`contracts/`](contracts/README.md) holds non-normative OpenAPI and AsyncAPI sketches of proposed interfaces; nothing there is implemented or binding.
- The remaining top-level and subsystem Markdown files are design inputs and background material. Where they conflict with the documents listed above, the status, boundary, safety, security, compliance, risk, and traceability documents take precedence.

## Public-repository practices

Please read [CONTRIBUTING.md](CONTRIBUTING.md), [SECURITY.md](SECURITY.md), [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md), [LICENSES_AND_ATTRIBUTION.md](LICENSES_AND_ATTRIBUTION.md), and [References.md](References.md) before reusing or contributing material. Documentation changes are reviewed against [DOCUMENTATION_REVIEW_CHECKLIST.md](DOCUMENTATION_REVIEW_CHECKLIST.md), and the set of changes is tracked in [CHANGELOG.md](CHANGELOG.md). The repository licence is CC BY-NC-ND 4.0; it does not grant rights in third-party material, data, services, standards, trademarks, or images.

If you cite this work, use [CITATION.cff](CITATION.cff).
