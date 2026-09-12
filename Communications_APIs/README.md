# Communications APIs

> **Status: candidate design — not verified and not implemented.**
> This document is a proposal for review. It does not describe a deployed
> capability, it authorises no public alert or physical action, and it records
> no verified result. Numeric figures are acceptance targets, not measurements.
> See [PROJECT_STATUS.md](../PROJECT_STATUS.md) for the claim policy and the document
> precedence order.

## Scope

Outbound communication channels — SMS, email, push, voice, and messaging
platforms — used for operator coordination and, under authority control,
for citizen-facing messaging.

## Boundary

- Design material only. No channel, gateway, or provider account is
  configured by this repository.
- Citizen-facing messaging is issued only through an authorised warning
  authority and its approved channels (see ADR-001).

## Related documents

- [Architecture index](../ARCHITECTURE/ARCHITECTURE_INDEX.md)
- [Assumptions and boundaries](../ARCHITECTURE/ASSUMPTIONS_AND_BOUNDARIES.md)
- [Project status](../PROJECT_STATUS.md)
