# Comprehensive Risk Assessment - Mobile Mesh EWS

## Overview
This document outlines the identified risks across Technical, Product, Business, and Compliance domains for the **Live Mobile Edge Sensors Swarm System**. It serves as a living registry to track potential failure modes and their mitigation strategies.

**Risk Matrix Key:**
*   **Probability:** Low (<20%), Medium (20-50%), High (>50%)
*   **Impact:** Low (Minor annoyance), Medium (Operational degradation), High (System failure/Safety hazard)

---

## 1. Technical Risks

### 1.1 Mesh Network & Connectivity
| Risk | Probability | Impact | Mitigation Strategy |
| :--- | :--- | :--- | :--- |
| **Network Partitioning**<br>Mesh splits into isolated islands due to distance/terrain. | High | High | **DTN Protocols (REQ-COM-011)**: Store-and-forward capability to ferry data when connection is restored. Satellite Backhaul (Starlink) for island bridges. |
| **Spectral Jamming**<br>RF interference (intentional or environmental) blocks 5G/6G. | Medium | High | **Cognitive Radio (REQ-COM-009)**: Frequency hopping. **Optical comms** (FSO) as backup. **Fail-Safe Mode (REQ-REL-004)**: Return-to-base if heartbeat lost. |
| **Routing Loop / Storm**<br>Rapid topology changes cause AODV/TORA to flood network with control packets. | Medium | Medium | **Hybrid Routing**: Switch to TORA only for fast movers. Implement "Time-to-Live" (TTL) limits and control packet throttling. |

### 1.2 AI & Data Accuracy
| Risk | Probability | Impact | Mitigation Strategy |
| :--- | :--- | :--- | :--- |
| **Hallucination / False Positives**<br>AI detects "fire" from sunset reflection or fog. | Medium | High | **Multi-Modal Fusion (REQ-EDGE-006)**: Require correlation (Visual + Thermal + Chemical) before alerting. **Human-in-the-Loop**: High-risk alerts require manual verify. |
| **Model Drift**<br>Models trained on historical data fail in new climate conditions. | High | Medium | **Continuous Learning Loop (REQ-AI-004)**: Federated learning updates models daily based on verified local ground truth. |
| **Edge Compute Saturation**<br>Complex models drain battery or freeze ESP32 nodes. | High | Medium | **Model Quantization**: Use TFLite Micro int8 quantization. **Hardware Offload**: Use specialized NPUs (e.g., Hailo, Coral) on gateways. |

### 1.3 Hardware & Power
| Risk | Probability | Impact | Mitigation Strategy |
| :--- | :--- | :--- | :--- |
| **Battery Depletion**<br>Nodes die mid-mission, breaking the mesh. | High | High | **Energy Harvesting (REQ-REL-002)**: Solar/Thermal monitoring. **Duty Cycling**: Sleep modes when inactive. **Swarm Rotation**: Rotate drones out of active line for charging. |
| **Harsh Environment Failure**<br>Heat/Water destroys sensors. | Medium | High | **Ruggedization (REQ-REL-001)**: IP68 rated enclosures. Cooling systems for active electronics using phase-change materials. |

---

## 2. Product & Requirements Risks

### 2.1 Scope & Usability
| Risk | Probability | Impact | Mitigation Strategy |
| :--- | :--- | :--- | :--- |
| **Complexity Overload**<br>Operator overwhelmed by 1000s of swarm inputs. | High | High | **Intent-Based C2 (REQ-HSI-002)**: Abstract individual drones; operator controls "Search Areas" only. **AR Visualization**: Clean overlay of data. |
| **Alert Fatigue**<br>Public ignores alerts due to frequent minor warnings. | High | High | **Targeted Polygons (REQ-EXT-007)**: Only alert users in immediate danger. **Severity Filtering**: Reserve "Extreme" tone for life threats only. |

### 2.2 Integration
| Risk | Probability | Impact | Mitigation Strategy |
| :--- | :--- | :--- | :--- |
| **Hardware Heterogeneity**<br>Third-party drones fail to join mesh or send non-standard data. | Medium | Medium | **Standardized Protocol (MCP)**: Enforce strict schema validation. **Certification Program**: "Swarm Ready" badge for compliant vendors. |

---

## 3. Business & Management Risks

### 3.1 Market & Adoption
| Risk | Probability | Impact | Mitigation Strategy |
| :--- | :--- | :--- | :--- |
| **Government Bureaucracy**<br>Sales cycle to B2G takes 24+ months, draining cash. | High | High | **Dual-Use Strategy**: Sell "Commercial Analytics" (B2B) to insurance/telecoms for immediate revenue while pursuing gov contracts. |
| **High Initial CAPEX**<br>Cost of deploying thousands of sensors is prohibitive. | Medium | High | **DaaS Model**: "Data as a Service" - keep ownership of hardware, sell the insights. **Crowdsourcing**: Use civilian phones/cars as nodes. |

### 3.2 Legal & Liability
| Risk | Probability | Impact | Mitigation Strategy |
| :--- | :--- | :--- | :--- |
| **False Negative Liability**<br>System fails to warn of flood; users sue. | Low | High | **SLA Disclaimers**: "Best Effort" clauses. **Insurance Provider Partnership**: Shared liability models. Immutable logs (Blockchain) to prove system function. |

---

## 4. Compliance & Ethics Risks

### 4.1 Regulatory (EU AI Act / GDPR)
| Risk | Probability | Impact | Mitigation Strategy |
| :--- | :--- | :--- | :--- |
| **"High-Risk" Classification**<br>Strict auditing delays deployment. | n/a (Fact) | Medium | **Compliance by Design**: Maintain `Compliance_and_Ethics.md`. Implement **Human Oversight** for all critical decisions (Art. 14). |
| **Privacy Violation (GDPR)**<br>Camera drone records identifiable faces. | Medium | High | **Edge Anonymization**: Blur faces on-device. **Data Minimization**: Transmit features ("Person at X"), not video, unless SAR mode authorized. |
| **Spectrum Violation**<br>Mesh transmits on restricted military bands. | Low | Medium | **Geo-fenced Spectrum DB**: Auto-lockout of restricted frequencies based on GPS location. |

### 4.2 Ethical Misuse
| Risk | Probability | Impact | Mitigation Strategy |
| :--- | :--- | :--- | :--- |
| **Dual-Use Weaponization**<br>System used for offensive targeting. | Low | Critical | **License Restrictions**: Strict Terms of Use. **Technical Limitations**: Hardcoded "No Payload" logic. **Fail-Safe**: Remote kill-switch for hijacked clusters. |

---

## 5. Security Risks

### 5.1 Cyber Threats
| Risk | Probability | Impact | Mitigation Strategy |
| :--- | :--- | :--- | :--- |
| **Sybil Attack**<br>Adversary spawns fake nodes to poison data. | Medium | High | **Decentralized PKI**: Hardware-backed identity (TPM/Secure Element). **Consensus**: Outlier detection ignores data deviation >3 sigma. |
| **Supply Chain Attack**<br>Compromised firmware on imported sensors. | Low | High | **Secure Boot**: Crypto-signed firmware updates. **SBOM** (Software Bill of Materials) auditing. |
| **Jamming / DoS**<br>Radio flooding disrupts comms. | Medium | High | **Anti-Jamming Protocols**: Networking fallback (Mesh -> Sat -> DTN). **Physical Hardening**: Shielded electronics. |

---

## 6. Implementation Plan Risks (Current)

### 6.1 Timeline
| Risk | Probability | Impact | Mitigation Strategy |
| :--- | :--- | :--- | :--- |
| **Integration Testing Delays**<br>Simulating 1000 nodes is complex. | High | Medium | **VisualGridDev**: Use digital twin simulation before physical field tests. |
| **Tech Stack Churn**<br>Switching between AWS/GCP/OSS. | Medium | Low | **Abstraction Layers**: Use Interfaces (e.g., `NotificationService`) to decouple logic from vendor APIs. |

---

*Verified against PRD v1.2 and Architecture Specifications v2.0*
*Last Updated: February 2026*
