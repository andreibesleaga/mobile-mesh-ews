# Observability Contract (for a future runtime)

> **Status: forward-looking requirement.** No runtime exists in this repository.
> This document fixes the observability contract that any future implementation
> must satisfy, so that it is designed in rather than retrofitted. It is not a
> description of a deployed system. See [PROJECT_STATUS.md](PROJECT_STATUS.md).

## Why this exists

The proposed system touches life-safety decisions. When a decision-support path
cannot be reconstructed after the fact, it cannot be audited, and an
un-auditable early-warning path is not deployable. Observability is therefore a
safety and assurance requirement, not an operational convenience.

## Signals required from any future implementation

| Signal | Requirement | Minimum content |
|---|---|---|
| Traces | OpenTelemetry traces across ingest, analysis, review, and dissemination | trace and span IDs propagated end to end |
| Metrics | OpenTelemetry metrics with documented units and aggregation | counters, gauges, and histograms for volume, latency, error, saturation, and queue depth |
| Logs | Structured, levelled, machine-parseable | timestamp, level, service, event ID, correlation ID, outcome |
| Audit record | Append-only, tamper-evident, retained per policy | actor, action, target, authorisation reference, before/after, outcome |
| Health | Liveness and readiness endpoints for every service | dependency status and degraded-state reason |
| Evidence bundle | Per-decision record linking inputs to output | source versions, model and data versions, uncertainty, reviewer, timestamp |

## Naming and correlation

- One `correlation_id` spans a single observation from ingest to any external
  dissemination decision.
- One `alert_id` identifies a proposed warning and survives every revision,
  rejection, cancellation, and supersession.
- One `event_id` identifies a discrete system event and is stable across retries.
- Identifiers must be correlatable across services without carrying personal
  data; never place raw location, media, or identifiers of people in a signal
  name or label value.

## Logging rules

- Logs never contain credentials, tokens, raw media, precise location, or
  personal data. Use references resolved through an access-controlled store.
- Failures are logged with a stable error code and a human-readable message.
- Debug verbosity is configuration-controlled and defaults to off.
- Redaction is enforced centrally, not per call site.

## Service-level objectives

Any future operator must publish, for a defined operational design domain:
latency budget per stage, availability target, error budget, and the conditions
under which the system degrades. Until a measured result exists, these are
**targets**, never reported results. See the risk and status registers.

## Retention, access, and privacy

- Observability data is subject to the same data-protection rules as the
  observed system: purpose limitation, minimisation, retention limits, and
  access control.
- Audit records and technical logs have different retention and access rules and
  must be stored separately.
- Access to trace-level data is logged; exceptional access requires justification.

## Degradation behaviour

When the observability path is unavailable, the system must not silently
continue in a less accountable mode. It must either preserve the minimum audit
record locally or stop the affected capability and raise an operator-visible
condition. Losing telemetry is not a reason to lose accountability.

## Verification

A future implementation demonstrates this contract with: a sample end-to-end
trace across all stages; evidence of redaction and access control; an exercise
showing recovery after telemetry loss; and a reconstructable decision record for
a synthetic scenario.
