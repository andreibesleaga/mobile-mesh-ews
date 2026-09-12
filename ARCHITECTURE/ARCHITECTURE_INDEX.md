# Mobile Mesh EWS Architecture

## Authority and lifecycle

This directory describes a **candidate architecture**, not a deployed system. Diagrams and technology names express design options unless a document explicitly labels a statement as verified evidence. The project has no field deployment, public-warning integration, safety case, or production service.

When documents disagree, use this order of authority:

1. [Project status and verification](../PROJECT_STATUS.md)
2. [Assumptions and boundaries](ASSUMPTIONS_AND_BOUNDARIES.md), [Security](Security.md), [Compliance](../Compliance_and_Ethics.md), [Risks](../RISKS.md), and [Observability](../OBSERVABILITY.md)
3. [Decision log](DECISIONS.md) and [Requirements traceability matrix](../Requirements_Traceability_Matrix.md)
4. C4, data-flow, deployment, protocol, scale, and scenario views
5. Background, business, integration, simulation, and prototype material

No diagram authorises a public alert, autonomous vehicle action, access to third-party services, or processing of personal data.

## Reading path

| Step | Document | Question answered |
|---|---|---|
| 1 | [Assumptions and boundaries](ASSUMPTIONS_AND_BOUNDARIES.md) | What is and is not being designed? |
| 2 | [C4 context](C4_Context.md) and [containers](C4_Container.md) | Which actors and logical services are proposed? |
| 3 | [Data flow](DataFlow.md) | How should data be minimised, verified, and reviewed? |
| 4 | [Security](Security.md) | What controls and evidence are required before implementation? |
| 5 | [Deployment](Deployment.md) and [scalability](Scalability.md) | What must be proven under operational conditions? |
| 6 | [Technical protocols](TechnicalProtocols.md) | Which standards and options need a decision record? |
| 7 | [User flows](UserFlows.md) | How should human-authorised workflows behave? |

## Architectural invariants

- An observation is not a verified hazard; a model output is not an alert.
- Only an authorised human role may approve dissemination outside the system boundary.
- Field and third-party data are untrusted until identity, integrity, freshness, quality, and provenance checks pass.
- Critical operation must degrade safely: suppress unverified outputs, preserve evidence, and hand control to authorised people.
- Privacy, accessibility, jurisdiction, aviation, spectrum, and emergency-management requirements are deployment prerequisites, not post-release work.
- Performance figures in legacy views are hypotheses and acceptance targets, never achieved results.

## Existing views

| View | Purpose | Important limitation |
|---|---|---|
| [System overview](System_Architecture_Overview.md) | Broad system-of-systems concept | Candidate components only |
| [Detailed scenarios](System_Architectures.md) | Sector-specific concepts | Not an authorisation for defence, surveillance, or alerting use |
| [Components](C4_Component.md) | Logical component decomposition | Interfaces and trust contracts remain to be specified |
| [Auxiliary systems](AuxiliarySystems.md) | Optional services | Ledger, AI, and notification providers are not committed dependencies |
| [Interface contracts](../contracts/README.md) | Non-normative OpenAPI and AsyncAPI sketches | Not a normative specification; nothing is implemented or binding |
| [Technology stacks](TechnicalStacks.md) | Options comparison | Selection requires ADR, threat model, cost model, and legal review |

## Verification rule

Every proposed requirement must have a measurable acceptance criterion, test method, accountable owner, and recorded result before it can be called implemented. See the [verification plan](../PROJECT_STATUS.md#release-gates) and [traceability matrix](../Requirements_Traceability_Matrix.md).
