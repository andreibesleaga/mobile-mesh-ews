# Architecture Decision Log

## ADR-001: Decision support is separate from public warning authority

**Status:** Accepted for the architecture baseline.

The system may assemble evidence and a proposed CAP message, but it must not publish an alert. An authorised warning authority owns validation, wording, dissemination, cancellation, and public accountability. This prevents a prototype from being represented as an official alerting service.

## ADR-002: Tiered mesh is the baseline topology hypothesis

**Status:** Proposed; requires simulation and field validation.

Constrained devices are leaf sensors by default. Better-powered, managed nodes may act as gateways only after admission and health checks. This limits control-plane load and energy cost. Cluster selection, routing protocol, and fault thresholds remain open design decisions.

## ADR-003: Streaming decisions are separated from historical analytics

**Status:** Proposed; requires workload and cost validation.

Future time-sensitive evidence processing needs a bounded-latency stream path with explicit backpressure and failure behaviour. Warehousing and model-training workloads belong in a separate analytical path. BigQuery-oriented SQL in this repository is exploratory and must not be treated as the alert path.

## ADR-004: Data minimisation precedes centralisation

**Status:** Accepted for the architecture baseline.

Collect only fields necessary for the documented purpose. Prefer event features, coarse location, and short retention over raw media, persistent identifiers, or continuous precise location. Pseudonymisation, aggregation, and federated techniques reduce risk but do not themselves establish anonymity or legal compliance.

## ADR-005: Fail closed for public output; fail safe for field nodes

**Status:** Accepted for the architecture baseline.

When assurance is insufficient, the proposed system preserves evidence and asks for human intervention; it does not send a warning or command. Any future physical node must define and test a hazard-specific safe state with the responsible operator and regulator.

## ADR-006: Quantitative targets are acceptance criteria, not results

**Status:** Accepted for the architecture baseline.

Latency, availability, packet delivery, detection, coverage, energy, and privacy assertions require a stated operational design domain, method, dataset, confidence bounds, and reproducible result. Unsupported numerical claims are removed from public summaries.
