# Inter-Subsystem Contracts (non-normative)

> **Status: non-normative design stubs — not implemented.** The files in this
> directory are illustrative interface sketches, published so that future
> implementers converge on the same shapes. They are **not** a normative
> specification, not a published API, and not evidence of interoperability.
> Nothing here is served, hosted, or validated. See
> [PROJECT_STATUS.md](../PROJECT_STATUS.md).

## Why these exist

The subsystem documents describe responsibilities but not interfaces. Without a
machine-readable sketch, each implementer invents its own vocabulary for the
same concepts, and interoperability has to be retrofitted. These stubs fix
vocabulary early, at low cost, while remaining explicitly non-binding.

## What is here

| File | Purpose | Notes |
|---|---|---|
| [`openapi/alerting.yaml`](openapi/alerting.yaml) | Sketch of an internal **alert-proposal** API | Proposes; never publishes. A human authority decides. |
| [`asyncapi/telemetry.yaml`](asyncapi/telemetry.yaml) | Sketch of the **observation** event stream | Untrusted input; requires admission and quality checks. |

## Conventions

- Field names and enumerations are proposals, not a frozen contract.
- No stub may imply the ability to publish a public warning or actuate a device.
  That boundary is fixed by [ADR-001](../ARCHITECTURE/DECISIONS.md).
- Where a real standard exists (CAP 1.2 for alerting, LwM2M/CoAP for device
  management, CAMARA for network context), the eventual contract must profile
  that standard rather than invent a parallel one.
- Any future change to these files that removes or renames a field is a breaking
  change and requires a versioned decision record.
