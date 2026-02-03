# References & Citations

This document serves as the authoritative source of truth for all external references, standards, research papers, and industrial case studies cited throughout the **Mobile Mesh EWS** project.

---

## 1. Official Standards & Protocols

### Emergency & Alerting
*   **CAP (Common Alerting Protocol) v1.2**: OASIS Standard for exchanging public warnings.
    *   [Specification](https://docs.oasis-open.org/emergency/cap/v1.2/CAP-v1.2-os.html)
    *   [DHS Implementation Guide](https://www.dhs.gov/sites/default/files/publications/Alert-Protocol-TG_0215-508.pdf)
*   **Wireless Emergency Alerts (WEA)**: FCC/ATIS standards for cellular broadcasting.
    *   [FEMA WEA Resources](https://www.fema.gov/emergency-managers/practitioners/integrated-public-alert-warning-system/public/wireless-emergency-alerts)

### Data Governance & Metadata
*   **ISO 19115-1:2014**: Geographic information — Metadata.
    *   [ISO Standard](https://www.iso.org/standard/53798.html)
*   **OGC SensorThings API**: Standard for internet of things sensing.
    *   [OGC Standard](https://www.ogc.org/standards/sensorthings)
*   **W3C PROV-O**: The PROV Ontology for data provenance and audit trails.
    *   [W3C Recommendation](https://www.w3.org/TR/prov-o/)

### Telecommunications & 6G (CAMARA/GSMA)
*   **CAMARA Project**: The Telco Global API Alliance.
    *   [CAMARA Project Home](https://camaraproject.org/)
    *   [Location Retrieval API](https://github.com/camaraproject/LocationRetrieval) - For verifying device location.
    *   [Quality on Demand (QoD) API](https://github.com/camaraproject/QualityOnDemand) - For prioritizing emergency traffic.
*   **IEEE 802.11s**: Wireless Mesh Networking standard (comparison vs BATMAN-ADV).
    *   [IEEE Standard](https://standards.ieee.org/standard/802_11s-2011.html)

### Safety & Fail-Safe Design
*   **IEEE P7009**: Standard for Fail-Safe Design of Autonomous and Semi-Autonomous Systems.
    *   [IEEE Standards Association](https://standards.ieee.org/project/7009.html)
    *   *Note: Used for the "Return-to-Base" and Kill-Switch implementations.*

---

## 2. Research & Academic Literature

### Swarm Intelligence & Mesh Networks
*   **BATMAN-ADV vs 802.11s**: Performance comparisons in dynamic environments.
    *   *Comparisons of Mesh Routing Protocols in Indoor and Outdoor Scenarios* (ResearchGate).
    *   *Performance Analysis of BATMAN-ADV and IEEE 802.11s in Underground Mines*, MDPI (2024). [Link](https://www.mdpi.com/1424-8220/24/5/1689)
*   **Swarm Intelligence in 6G**:
    *   *The 6G Mobile Network as a Smart Sensor Platform*, IEEE Xplore. [Link](https://ieeexplore.ieee.org/abstract/document/10209)
    *   *Why Swarm Intelligence Will Revolutionize 6G Networks*, 6G Academy. [Link](https://www.6gacademy.com/why-swarm-intelligence-will-revolutionize-6g-networks/)

### AI & Edge Computing
*   **Federated Learning for Disaster Response**:
    *   *Federated Learning — Enabling Swarm Intelligence*, Bosch Research. [Link](https://www.bosch.com/research/news/federated-learning/)
    *   *An IoT-Based Sensor Mesh Network Architecture for Waste Management in Smart Cities* (Swarm Logic application), Journal of Communications. [Link](https://www.jocm.us/2025/JCM-V20N2-153.pdf)
*   **Environmental Monitoring**:
    *   *Optimized Wireless Sensor Network Architecture for AI-Based Wildfire Detection*, MDPI (2025). [Link](https://www.mdpi.com/2571-6255/8/7/245)
    *   *Post-Disaster Recovery Monitoring with Google Earth Engine*, MDPI. [Link](https://www.mdpi.com/2076-3417/10/13/4574)

---

## 3. Industrial Case Studies & Verifications

These real-world projects validatethe architectural choices made in the **Mobile Mesh EWS**.

### RainForest Connection (RFCx)
*   **Relevance**: Validates the "Bio-logging" and "Edge AI" sensor concept.
*   **Implementation**: Uses upcycled solar-powered phones ("Guardians") in tree canopies to detect illegal logging acoustics in real-time.
*   **Documentation**: [RFCx Impact & Technology](https://rfcx.org/)

### Airly
*   **Relevance**: Validates the "High Density Deployment" business model for air quality.
*   **Implementation**: A global network of 40,000+ small-form-factor PM2.5 sensors aimed at municipalities.
*   **Documentation**: [Airly Sensor Network](https://airly.org/)

### Red Hook Mesh (Brooklyn, NY)
*   **Relevance**: Validates "Community-Owned Infrastructure" resilience during disasters (Hurricane Sandy).
*   **Implementation**: A local mesh network that maintained connectivity when major ISPs failed.
*   **Documentation**: [Red Hook WiFi](https://redhookwifi.org/)

---

## 4. Technical Specifications & Documentation

### Cloud & AI Infrastructure
*   **Google BigQuery AI**:
    *   [BigQuery ML Introduction](https://cloud.google.com/bigquery/docs/bqml-introduction)
    *   [Generative AI in BigQuery](https://docs.cloud.google.com/bigquery/docs/generative-ai-overview)
*   **Google Earth Engine**:
    *   [Platform Documentation](https://earthengine.google.com/)
    *   [Flood Prediction Case Study](https://www.youtube.com/watch?v=AbYB6DkQFq8)
*   **NASA FIRMS (Fire Information for Resource Management System)**:
    *   [API Documentation](https://firms.modaps.eosdis.nasa.gov/api/)

### AI Frameworks
*   **OPEA (Open Platform for Enterprise AI)**: [https://opea.dev/](https://opea.dev/)
*   **Haystack (LLM Orchestration)**: [https://haystack.deepset.ai/](https://haystack.deepset.ai/)

---

## 5. Regulatory & Compliance

### EU AI Act
*   **Classification**: "High-Risk AI Systems" (Annex III) - Critical Infrastructure & Emergency Services.
*   **Text**: [The Artificial Intelligence Act](https://artificialintelligenceact.eu/)
*   **Key Requirement**: Human oversight for critical decisions (Article 14).

### GDPR & Privacy
*   **General Data Protection Regulation**: [Official Legal Text](https://gdpr-info.eu/)
*   **Privacy by Design**: [ICO Guidelines](https://ico.org.uk/for-organisations/guide-to-data-protection/guide-to-the-general-data-protection-regulation-gdpr/accountability-and-governance/data-protection-by-design-and-default/)

### Cybersecurity
*   **NIST Cybersecurity Framework for IoT**:
    *   [NIST IoT Program](https://www.nist.gov/internet-of-things-iot)
*   **EU Cyber Resilience Act (CRA)**: [European Commission Proposal](https://digital-strategy.ec.europa.eu/en/library/cyber-resilience-act)

---

## 6. Project Internal References
Links to key internal architecture documents:
*   [Product Requirements (PRD)](./PRD_Swarm_System_Requirements_Specification.md)
*   [System Architecture Diagrams](./ARCHITECTURE/System_Architectures.md)
*   [Security Architecture](./ARCHITECTURE/Security.md)
*   [Business Strategy](./Business_Strategy.md)
*   [Compliance Report](./Compliance_and_Ethics.md)
*   [Requirement Traceability Matrix](./Requirements_Traceability_Matrix.md)


---

#### **Works cited PRD**

1. Optimized Wireless Sensor Network Architecture for AI-Based Wildfire Detection in Remote Areas \- MDPI, accessed January 30, 2026, [https://www.mdpi.com/2571-6255/8/7/245](https://www.mdpi.com/2571-6255/8/7/245)  
2. Recent Advances in Internet of Things Solutions for Early Warning Systems: A Review, accessed January 30, 2026, [https://pmc.ncbi.nlm.nih.gov/articles/PMC8954208/](https://pmc.ncbi.nlm.nih.gov/articles/PMC8954208/)  
3. Communication architecture of an early warning system \- NHESS, accessed January 30, 2026, [https://nhess.copernicus.org/articles/10/2215/2010/nhess-10-2215-2010.pdf](https://nhess.copernicus.org/articles/10/2215/2010/nhess-10-2215-2010.pdf)  
4. Cohere Technologies fights to keep 6G doors open for something new \- Light Reading, accessed January 30, 2026, [https://www.lightreading.com/6g/cohere-technologies-fights-to-keep-6g-doors-open-for-something-new](https://www.lightreading.com/6g/cohere-technologies-fights-to-keep-6g-doors-open-for-something-new)  
5. Google Earth Engine, accessed January 30, 2026, [https://earthengine.google.com/](https://earthengine.google.com/)  
6. FIRMS | NASA Earthdata, accessed January 30, 2026, [https://www.earthdata.nasa.gov/data/tools/firms](https://www.earthdata.nasa.gov/data/tools/firms)  
7. Why Swarm Intelligence Will Revolutionize 6G Networks \- 6G Academy, accessed January 30, 2026, [https://www.6gacademy.com/why-swarm-intelligence-will-revolutionize-6g-networks/](https://www.6gacademy.com/why-swarm-intelligence-will-revolutionize-6g-networks/)  
8. Routing Methods for Mobile Ad-hoc Network: A Review and Comparison of Multi-criteria Approaches \- Journal of Communications, accessed January 30, 2026, [http://www.jocm.us/uploadfile/2021/0922/20210922025755593.pdf](http://www.jocm.us/uploadfile/2021/0922/20210922025755593.pdf)  
9. The 6G Mobile Network as a Smart Sensor Platform \- IEEE Xplore, accessed January 30, 2026, [https://ieeexplore.ieee.org/iel8/10209/11016131/11016142.pdf](https://ieeexplore.ieee.org/iel8/10209/11016131/11016142.pdf)  
10. A Federated Learning Latency Minimization Method for UAV Swarms Aided by Communication Compression and Energy Allocation \- MDPI, accessed January 30, 2026, [https://www.mdpi.com/1424-8220/23/13/5787](https://www.mdpi.com/1424-8220/23/13/5787)  
11. Mobile Alerting Practices Version 1.0 \- Index of /, accessed January 30, 2026, [https://docs.oasis-open.org/emergency/mapcn/v1.0/cn01/mapcn-v1.0-cn01.pdf](https://docs.oasis-open.org/emergency/mapcn/v1.0/cn01/mapcn-v1.0-cn01.pdf)  
12. Exploring the Future of Agentic AI Swarms \- Codewave, accessed January 30, 2026, [https://codewave.com/insights/future-agentic-ai-swarms/](https://codewave.com/insights/future-agentic-ai-swarms/)  
13. Wild Swarms: Autonomous Drones for Environmental Monitoring and Protection \- VTT's Research Information Portal, accessed January 30, 2026, [https://cris.vtt.fi/ws/portalfiles/portal/106558343/2023.Saffre.FinDrones\_Accepted\_Author\_Manuscript.pdf](https://cris.vtt.fi/ws/portalfiles/portal/106558343/2023.Saffre.FinDrones_Accepted_Author_Manuscript.pdf)  
14. Swarm Intelligence Techniques for Mobile Wireless Charging \- MDPI, accessed January 30, 2026, [https://www.mdpi.com/2079-9292/11/3/371](https://www.mdpi.com/2079-9292/11/3/371)  
15. An IoT-Based Sensor Mesh Network Architecture for Waste Management in Smart Cities \- Journal of Communications, accessed January 30, 2026, [https://www.jocm.us/2025/JCM-V20N2-153.pdf](https://www.jocm.us/2025/JCM-V20N2-153.pdf)  
16. Routing Protocols for Mobile Sensor Networks: A Comparative Study \- arXiv, accessed January 30, 2026, [https://arxiv.org/pdf/1403.3162](https://arxiv.org/pdf/1403.3162)  
17. The Why and How of Polymorphic Artificial Autonomous Swarms \- MDPI, accessed January 30, 2026, [https://www.mdpi.com/2504-446X/9/1/53](https://www.mdpi.com/2504-446X/9/1/53)  
18. Real-Time Deployment of Mesh Networks | NIST, accessed January 30, 2026, [https://www.nist.gov/ctl/real-time-deployment-mesh-networks](https://www.nist.gov/ctl/real-time-deployment-mesh-networks)  
19. Wireless ad hoc network \- Wikipedia, accessed January 30, 2026, [https://en.wikipedia.org/wiki/Wireless\_ad\_hoc\_network](https://en.wikipedia.org/wiki/Wireless_ad_hoc_network)  
20. Intelligent Swarm Robotics for Disaster Response and Obstacle Avoidance \- IEEE Xplore, accessed January 30, 2026, [https://ieeexplore.ieee.org/iel8/11034707/11034773/11035980.pdf](https://ieeexplore.ieee.org/iel8/11034707/11034773/11035980.pdf)  
21. SwarmC2 Swarm Command & Control System View product \- UDS, accessed January 30, 2026, [https://www.udefenses.com/products/swarm-c2](https://www.udefenses.com/products/swarm-c2)  
22. Autonomous Swarming Takes Flight: The Next Era of UAV Operations \- Palladyne AI, accessed January 30, 2026, [https://www.palladyneai.com/blog/autonomous-swarming-takes-flight-the-next-era-of-uav-operations/](https://www.palladyneai.com/blog/autonomous-swarming-takes-flight-the-next-era-of-uav-operations/)  
23. Drone-swarm based surveillance system for autonomous machine safety functionality in, accessed January 30, 2026, [https://brill.com/edcollchap-oa/book/9789004725232/BP000077.xml](https://brill.com/edcollchap-oa/book/9789004725232/BP000077.xml)  
24. Mesh networks and real-time data collection are the new foundations of industry, accessed January 30, 2026, [https://www.macnica.co.jp/en/business/maas/columns/146721/](https://www.macnica.co.jp/en/business/maas/columns/146721/)  
25. DFDM: Decentralized fault detection mechanism to improving fault management in Wireless Sensor Networks | IEEE Conference Publication | IEEE Xplore, accessed January 30, 2026, [https://ieeexplore.ieee.org/document/5979417/](https://ieeexplore.ieee.org/document/5979417/)  
26. Mobile ad hoc network (MANET) routing protocols comparison for wireless sensor network, accessed January 30, 2026, [https://ieeexplore.ieee.org/document/5993439/](https://ieeexplore.ieee.org/document/5993439/)  
27. Survey on swarm intelligence based routing protocols for wireless sensor networks: An extensive study \- IEEE Xplore, accessed January 30, 2026, [https://ieeexplore.ieee.org/document/7475064/](https://ieeexplore.ieee.org/document/7475064/)  
28. Swarm-Intelligence-Centric Routing Algorithm for Wireless Sensor Networks \- MDPI, accessed January 30, 2026, [https://www.mdpi.com/1424-8220/20/18/5164](https://www.mdpi.com/1424-8220/20/18/5164)  
29. Evolving Towards Artificial-Intelligence-Driven Sixth-Generation Mobile Networks: An End-to-End Framework, Key Technologies, and Opportunities \- MDPI, accessed January 30, 2026, [https://www.mdpi.com/2076-3417/15/6/2920](https://www.mdpi.com/2076-3417/15/6/2920)  
30. 6G Networks and the AI Revolution—Exploring Technologies, Applications, and Emerging Challenges \- PMC \- PubMed Central, accessed January 30, 2026, [https://pmc.ncbi.nlm.nih.gov/articles/PMC10975185/](https://pmc.ncbi.nlm.nih.gov/articles/PMC10975185/)  
31. (PDF) Communication architecture of an early warning system \- ResearchGate, accessed January 30, 2026, [https://www.researchgate.net/publication/224992833\_Communication\_architecture\_of\_an\_early\_warning\_system](https://www.researchgate.net/publication/224992833_Communication_architecture_of_an_early_warning_system)  
32. Federated Learning — Enabling Swarm Intelligence | Bosch Global, accessed January 30, 2026, [https://www.bosch.com/research/news/federated-learning/](https://www.bosch.com/research/news/federated-learning/)  
33. Federated Reinforcement Learning‐Based UAV Swarm System for Aerial Remote Sensing \- DSpace@HANSUNG, accessed January 30, 2026, [https://dspace.hansung.ac.kr/bitstream/2024.oak/1800/2/AR\_E1A1A3\_Federated%20Reinforcement%20Learning-Based%20UAV%20Swarm%20System%20for%20Aerial%20Remote%20Sensing.pdf](https://dspace.hansung.ac.kr/bitstream/2024.oak/1800/2/AR_E1A1A3_Federated%20Reinforcement%20Learning-Based%20UAV%20Swarm%20System%20for%20Aerial%20Remote%20Sensing.pdf)  
34. Post-Disaster Recovery Monitoring with Google Earth Engine \- MDPI, accessed January 30, 2026, [https://www.mdpi.com/2076-3417/10/13/4574](https://www.mdpi.com/2076-3417/10/13/4574)  
35. Google Earth Engine for Disaster Management: Mitigating Impacts of Flood \- YouTube, accessed January 30, 2026, [https://www.youtube.com/watch?v=AbYB6DkQFq8](https://www.youtube.com/watch?v=AbYB6DkQFq8)  
36. NASA | LANCE | FIRMS, accessed January 30, 2026, [https://firms.modaps.eosdis.nasa.gov/api/](https://firms.modaps.eosdis.nasa.gov/api/)  
37. Designing a User-Centered Interaction Interface for Human–Swarm Teaming \- MDPI, accessed January 30, 2026, [https://www.mdpi.com/2504-446X/5/4/131](https://www.mdpi.com/2504-446X/5/4/131)  
38. Part I: Usability of Human-swarm Interaction Interface \- TAS Hub, accessed January 30, 2026, [https://tas.ac.uk/usability-of-human-swarm-interaction-interface/](https://tas.ac.uk/usability-of-human-swarm-interaction-interface/)  
39. Command and Control of a Large Scale Swarm Using Natural Human Interfaces \- IEEE Xplore, accessed January 30, 2026, [https://ieeexplore.ieee.org/iel8/10854677/10875987/10876045.pdf](https://ieeexplore.ieee.org/iel8/10854677/10875987/10876045.pdf)  
40. Characterization of Indicators for Adaptive Human-Swarm Teaming \- PMC \- PubMed Central, accessed January 30, 2026, [https://pmc.ncbi.nlm.nih.gov/articles/PMC8891141/](https://pmc.ncbi.nlm.nih.gov/articles/PMC8891141/)  
41. Environmental Monitoring with Distributed Mesh Networks: An Overview and Practical Implementation Perspective for Urban Scenario \- PubMed Central, accessed January 30, 2026, [https://pmc.ncbi.nlm.nih.gov/articles/PMC6960639/](https://pmc.ncbi.nlm.nih.gov/articles/PMC6960639/)  
42. The Modeling and Detection of Attacks in Role-Based Self-Organized Decentralized Wireless Sensor Networks \- MDPI, accessed January 30, 2026, [https://www.mdpi.com/2673-4001/5/1/8](https://www.mdpi.com/2673-4001/5/1/8)  
43. UAV swarm communication and control architectures: a review, accessed January 30, 2026, [https://cdnsciencepub.com/doi/10.1139/juvs-2018-0009](https://cdnsciencepub.com/doi/10.1139/juvs-2018-0009)  
44. AI-Automated Swarm Drone System with Advanced Targeting, Added Countermeasures, and Improved Stealth Technology \- Preprints.org, accessed January 30, 2026, [https://www.preprints.org/manuscript/202511.0792/v1](https://www.preprints.org/manuscript/202511.0792/v1)


#### **Works cited PRD_Integrations**

1. Climate Early Warning System - Big Data AI Engine | Kaggle, accessed January 30, 2026, [https://www.kaggle.com/competitions/bigquery-ai-hackathon/writeups/climate-early-warning-system-big-data-ai-engine](https://www.kaggle.com/competitions/bigquery-ai-hackathon/writeups/climate-early-warning-system-big-data-ai-engine)
2. Request for Bids Works Procurement... KEMFSED, accessed January 30, 2026, [https://kemfsed.org/wp-content/uploads/2022/10/VOLUME-3-SPECIFICATIONS-5.pdf](https://kemfsed.org/wp-content/uploads/2022/10/VOLUME-3-SPECIFICATIONS-5.pdf)
3. Emerging IT technologies for Multi-Hazard Early Warning Systems | by Andrei Besleaga (Nicolae) - Medium, accessed January 30, 2026, [https://medium.com/predict/innovative-usage-of-emerging-it-technologies-in-multi-hazard-early-warning-systems-7bcfe3d170b9](https://medium.com/predict/innovative-usage-of-emerging-it-technologies-in-multi-hazard-early-warning-systems-7bcfe3d170b9)
4. Andrei Besleaga (Nicolae) andreibesleaga - GitHub, accessed January 30, 2026, [https://github.com/andreibesleaga](https://github.com/andreibesleaga)
5. forward-compatible · GitHub Topics, accessed January 30, 2026, [https://github.com/topics/forward-compatible](https://github.com/topics/forward-compatible)
6. Smart Roadway Lighting... Tondo Smart, accessed January 30, 2026, [https://tondo-iot.com/wp-content/uploads/2024/05/Tondo-Catalog-Spring-2024.pdf](https://tondo-iot.com/wp-content/uploads/2024/05/Tondo-Catalog-Spring-2024.pdf)
7. BigQuery | AI data platform | Lakehouse | EDW - Google Cloud, accessed January 30, 2026, [https://cloud.google.com/bigquery](https://cloud.google.com/bigquery)
8. Pattern Matching at Scale with BigQuery's Generative AI — Part 2 | by Tiyab K. - Medium, accessed January 30, 2026, [https://medium.com/@ktiyab_42514/pattern-matching-at-scale-with-bigquerys-generative-ai-part-2-aab65a5822b6](https://medium.com/@ktiyab_42514/pattern-matching-at-scale-with-bigquerys-generative-ai-part-2-aab65a5822b6)
9. Generative AI overview | BigQuery - Google Cloud Documentation, accessed January 30, 2026, [https://docs.cloud.google.com/bigquery/docs/generative-ai-overview](https://docs.cloud.google.com/bigquery/docs/generative-ai-overview)
10. Forecasting overview | BigQuery - Google Cloud Documentation, accessed January 30, 2026, [https://docs.cloud.google.com/bigquery/docs/forecasting-overview](https://docs.cloud.google.com/bigquery/docs/forecasting-overview)
11. Common Alerting Protocol Alert Origination Tools Technology Guide - Homeland Security, accessed January 30, 2026, [https://www.dhs.gov/sites/default/files/publications/Alert-Protocol-TG_0215-508.pdf](https://www.dhs.gov/sites/default/files/publications/Alert-Protocol-TG_0215-508.pdf)
12. Notifier-by-Honeywell-world-of-solutions-brochure.pdf - Control Fire Systems, accessed January 30, 2026, [https://www.controlfiresystems.com/media/catalog/brochure/Notifier-by-Honeywell-world-of-solutions-brochure.pdf](https://www.controlfiresystems.com/media/catalog/brochure/Notifier-by-Honeywell-world-of-solutions-brochure.pdf)
13. FIRE ALARM REPLACEMENT PUBLIC SAFETY BUILDING - Delaware Bids and Contracts, accessed January 30, 2026, [https://bidcondocs.delaware.gov/OMB/OMB_MC1002000449_specs.pdf](https://bidcondocs.delaware.gov/OMB/OMB_MC1002000449_specs.pdf)
14. DA-13-280A1.docx - Federal Communications Commission, accessed January 30, 2026, [https://docs.fcc.gov/public/attachments/DA-13-280A1.docx](https://docs.fcc.gov/public/attachments/DA-13-280A1.docx)
15. AI Agent2Agent (A2A), Model Context Protocol (MCP Servers) & Visual Programming Language | by Andrei Besleaga (Nicolae) | Towards AI, accessed January 30, 2026, [https://pub.towardsai.net/agent2agent-a2a-model-context-protocol-mcp-servers-54141b13371f](https://pub.towardsai.net/agent2agent-a2a-model-context-protocol-mcp-servers-54141b13371f)
16. backward-compatibility | Topic | Ecosyste.ms: Repos, accessed January 30, 2026, [https://repos.ecosyste.ms/topics/backward-compatibility](https://repos.ecosyste.ms/topics/backward-compatibility)
17. 47 CFR Part 10 -- Wireless Emergency Alerts - eCFR, accessed January 30, 2026, [https://www.ecfr.gov/current/title-47/chapter-I/subchapter-A/part-10](https://www.ecfr.gov/current/title-47/chapter-I/subchapter-A/part-10)

---
