# Compliance and Ethics Baseline

## Status

This is a design-time governance baseline, not legal advice, a certification, or a finding of compliance. The repository does not process live data or operate a service. A future operator must determine applicable law for its intended purpose, jurisdiction, data, partners, and deployment before any pilot or production use.

## Regulatory posture

| Topic | Design position | Evidence required before deployment |
|---|---|---|
| GDPR and local data-protection law | Treat precise location, persistent device identifiers, imagery, audio, and linked telemetry as potentially personal data. Minimise collection and document purpose, lawful basis, roles, transfers, retention, security, and data-subject handling. | Data map; controller/processor allocation; lawful-basis record; DPIA where required; notices; retention schedule; processor and transfer assessments |
| Automated decision-making | No person should be subject to a solely automated decision with legal or similarly significant effects. Public warning and physical-action decisions require accountable human authority. | Workflow, role design, override record, explanation and contestation process |
| EU AI Act | Classification cannot be inferred from the word “emergency.” It depends on intended purpose, product context, and the Annex I/III rules. The system must be classified by the future provider/deployer and reassessed after material changes. | Intended-purpose statement; Article 6 assessment; Annex mapping; applicable conformity, registration, human-oversight, and monitoring records |
| Aviation, spectrum, telecom, emergency management | These are local operational permissions, not capabilities conveyed by this repository. | Jurisdiction-specific approvals, partner agreement, operational procedures, and named accountable authority |
| Accessibility and inclusion | Warnings and operator workflows must be people-centred, accessible, multilingual where appropriate, and resilient to channel and connectivity exclusions. | User research, accessibility testing, community engagement, channel reach and fallback evidence |

The EU AI Act applies from 2 August 2026, with exceptions and staged provisions; Article 6 and its corresponding obligations have a later application date in the Regulation. Legal counsel must verify the relevant date and any later guidance at the time of deployment.

## Privacy-by-design requirements

1. Define a specific, documented purpose before collecting each field.
2. Make raw media, exact location, persistent identifiers, and special-category data exceptional rather than default inputs.
3. Apply data minimisation at the source; coarse aggregation and pseudonymisation reduce risk but do not make personal data anonymous by themselves.
4. Keep provenance separate from identity where feasible; restrict re-identification to an approved, logged, exceptional process.
5. Use short, justified retention and verified deletion, including backups and derived datasets.
6. Do not use location, imagery, or communications data for surveillance, profiling, law-enforcement, or defence purposes without a separately authorised and assessed system.
7. Test for disparate error rates and accessibility failures across hazard context, geography, language, device type, and affected populations.

## Ethical guardrails

| Risk | Guardrail |
|---|---|
| False warning or missed warning | Evidence thresholds, uncertainty display, independent human approval, cancellation workflow, and post-incident review |
| Dual use | Exclude targeting, weapons coordination, individual tracking, and covert surveillance; reject contributions that enable them |
| Automation bias | Show source provenance, conflict, uncertainty, and alternatives; require trained accountable reviewers |
| Data harm | Purpose limitation, minimisation, access logging, retention controls, and community impact review |
| Unequal protection | Evaluate reach and error by population; retain non-digital and accessible warning pathways |

## Governance cadence

Before each material design change, review intended purpose, data categories, threat model, risk register, dependencies, and the classification assessment. Before field testing, obtain independent safety, privacy, security, and community-impact review. Record decisions and residual-risk acceptance in a versioned evidence repository.

## Primary references

- [Regulation (EU) 2016/679 (GDPR)](https://eur-lex.europa.eu/eli/reg/2016/679/oj), especially Articles 5, 22, 25, 32, and 35.
- [Regulation (EU) 2024/1689 (AI Act)](https://eur-lex.europa.eu/eli/reg/2024/1689/oj), especially Articles 6, 9–15, 26, 43, 49, 60, and 113 and Annexes I, III, IV, VI, and VII.
- [WMO Early Warnings for All](https://community.wmo.int/site/knowledge-hub/programmes-and-initiatives/early-warnings-all-ew4all).
