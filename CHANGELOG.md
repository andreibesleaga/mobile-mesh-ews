# Changelog

All notable changes to this repository are recorded in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and
this project uses [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

A "release" here is a tagged snapshot of the specification set, not a deployed
service. Version numbers describe the documentation and research artefacts;
they say nothing about operational readiness. See
[PROJECT_STATUS.md](PROJECT_STATUS.md) for the maturity boundary.

## [0.3.0] - 2026-09-12

### Added

- Documentation gate tooling: `tools/check_links.py` (relative links and heading
  anchors), `tools/check_rtm.py` (PRD and traceability agreement), and
  `tools/check_mermaid.py` (diagram rendering).
- Continuous integration: documentation workflow (lint, links, traceability,
  diagrams), security workflow (secret scanning, OSV-Scanner, Trivy, dependency
  review, OpenSSF Scorecard), and an SBOM workflow that attaches a CycloneDX
  document to tagged releases.
- Community and governance files: `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`,
  `SECURITY.md`, `LICENSES_AND_ATTRIBUTION.md`, `CHANGELOG.md`,
  `DOCUMENTATION_REVIEW_CHECKLIST.md`, issue forms, and a pull-request template.
- `PROJECT_STATUS.md` stating evidenced maturity, a claim policy, and release
  gates.
- `ARCHITECTURE/ASSUMPTIONS_AND_BOUNDARIES.md` (scope, trust boundaries, safety
  states) and `ARCHITECTURE/DECISIONS.md` (six numbered decision records).
- `OBSERVABILITY.md` prescribing the observability contract any future runtime
  must satisfy.
- Dependabot configuration for pip and GitHub Actions.
- `contracts/` with non-normative OpenAPI and AsyncAPI sketches of the proposed
  alert-proposal API and observation stream.
- SPDX licence and copyright headers on the Python and JavaScript artefacts.
- Repository `.gitignore` for Python, Node tooling, editor, and generated output.

### Changed

- [README.md](README.md) rewritten around the status and safety boundary, the
  four separated concerns, and the authoritative reading order.
- [ARCHITECTURE/Security.md](ARCHITECTURE/Security.md) rebuilt as a required-control
  and evidence specification instead of a capability description.
- [RISKS.md](RISKS.md) converted to a register with required mitigations, release
  gates, and an escalation policy.
- [Compliance_and_Ethics.md](Compliance_and_Ethics.md) restated as a design-time
  governance baseline with explicit "not legal advice" framing.
- [Requirements_Traceability_Matrix.md](Requirements_Traceability_Matrix.md)
  reduced to a status baseline with an explicit definition of each status.
- PRD and C4 views now carry lifecycle interpretation notes.
- [CITATION.cff](CITATION.cff) version aligned with the tagged release series.

### Removed

- Unsupported performance, latency, and compliance claims from the principal summary documents.
- Duplicated narrative that restated the same architecture in several documents.
- The requirement to broadcast Wireless Emergency Alerts to the public, and the
  requirement to actuate fire-alarm panels and third-party signage. Both were
  incompatible with ADR-001; see the audit follow-up in `PROJECT_STATUS.md`.
- The defence, border-surveillance, and tactical-response material in
  `Business_Strategy.md`, `ARCHITECTURE/System_Architectures.md`, and
  `ARCHITECTURE/TechnicalStacks.md`.

### Known remaining work

A claim-consistency pass is required in the PRD, `PRD_Other_Integrations.md`,
`Business_Strategy.md`, and `BigData_AI_Decision_System/` for quantitative
figures that are still stated without a target label. This is recorded as open,
not closed.

## [0.2.0] - 2026-02-21

### Added

- Illustrative Python swarm simulation under `Algorithms/Swarm-EWS-Simulation/`
  with a pinned dependency set and animation output.

### Changed

- README installation and repository-URL corrections.

## [0.1.0] - 2026-02-08

### Added

- Initial specification set: product requirements document, requirements
  traceability matrix, architecture views (C4 context, container, component,
  data flow, deployment, scalability, security, protocols, user flows), risk
  register, innovation comparison, references, and business strategy.
- `CITATION.cff` and the Creative Commons licence.

[0.3.0]: https://github.com/andreibesleaga/mobile-mesh-ews/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/andreibesleaga/mobile-mesh-ews/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/andreibesleaga/mobile-mesh-ews/releases/tag/v0.1.0
