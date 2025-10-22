# mobile-mesh-ews
## System Architecture - Climate Early Warning System - Live Mobile Swarm Mesh for Early Warnings and other Climate Systems

[Article on Swarm System Architecture With Live Mobile Sensors for Climate Monitoring](https://medium.com/@andrei-besleaga/innovative-swarm-system-architecture-with-live-mobile-edge-sensors-for-climate-monitoring-and-eb0124e7b451)

#### Innovative usage of mobile parts (equipped with sensors for reporting conditions and acquisition of data from different environments), as part of an IoT Edge Cloud Network, autonomously mimicking swarm intelligence, and ready to be integrated or corroborated with other Early Warning Systems or Climate Systems.

Part of the initial idea proposed in [the article](https://medium.com/@andrei-besleaga/innovative-usage-of-emerging-it-technologies-in-multi-hazard-early-warning-systems-7bcfe3d170b9), current repository contains diagramming for such a system (higher-level systems architecture specs) and this presentation, other documentations, proposals, and implementations.
<br>

A distributed network of mobile devices, from vehicles on the ground (EVs, Cars, etc.), water (ships), air (drones, planes), to special designed robots with sensors (used in special cases scenarios and environments), and real-world tracked flora (used as sensors for pollution, weather anomalies) and fauna (tracked animals and existing statistics databases of their movement and habits), can be deployed as mobile sensors to monitor and respond to various climate issues, forming a mesh network mimicking swarm intelligence, to be used as a part of other systems, or used modularly, within a plugin based approach, for different kind of actions from different services integrated.


A separate implementation of the architecture part for the Decision Brain of the System, using BigQuery AI, is listed in the subdirectory: [BigData_AI_Decision_System](https://github.com/andreibesleaga/mobile-mesh-ews/tree/main/BigData_AI_Decision_System).


#### Generic System Overview

![SwarmSystem](https://github.com/andreibesleaga/mobile-mesh-ews/blob/main/SwarmSystem.png)

This repository contains system proposal variants descriptions, general diagrams for general, scaling, security, data flow, architecture of such a system and it's parts.

#### 1. Data Collection and Monitoring

##### EVs and Cars:
- Air Quality Monitoring: Vehicles equipped with air quality sensors can measure pollutants such as NO2, CO2, and other polluants. This data can be used to detect pollution hotspots and track changes over time.
- Weather Conditions: Vehicles can be outfitted with sensors to monitor temperature, humidity, atmospheric pressure, and precipitation. This helps gather hyper-local weather data.
- Road Conditions: Sensors can detect and report on road conditions like flooding, ice, and heat stress, which are important for understanding and predicting the impact of climate change on infrastructure.

##### Ships:
- Marine Environment Monitoring: Ships can carry sensors to measure sea surface temperature, salinity, pH levels, and dissolved oxygen, which are critical for monitoring ocean health and the impacts of climate change.
- Wave and Current Data: Ships equipped with oceanographic instruments can provide data on wave heights and ocean currents, contributing to climate models and forecasts.

##### Drones and other types of aircrafts:
- Remote Sensing: Drones can capture high-resolution aerial imagery and thermal data, useful for monitoring deforestation, glacial melt, and land use changes.
- Atmospheric Data: Drones can measure atmospheric conditions at various altitudes, providing valuable data on temperature, humidity, and pollutant concentrations.
- Disaster Assessment: In the aftermath of a disaster, drones can quickly assess damage, identify survivors, and monitor ongoing hazards.

##### Special designed robots:
- Used for any of the above, in hardly accessible environments.

##### Monitored flora and fauna and existing statistics:
- Used for specific cases for swarm intelligence - from direct input by monitored flora or animal world (tracked animals, existing stats, directly affected, used as "sensors", to detect anomalies).


#### 2. Integration and Communication

##### IoT/Edge and Cloud Computing:

- Real-Time Data Transmission: Vehicles, ships, and drones can be integrated into an IoT Edge network, enabling real-time transmission of collected (and partly processed) data to central cloud servers for analysis, storage, and decision making for next vehicle location.
- Data Aggregation: Cloud platforms can aggregate data from thousands of mobile sensors, providing comprehensive coverage and insights into climate patterns and anomalies (along with other existing data, eg: satellites data).
- 5G/6G Networks: High-speed mobile networks facilitate the rapid transfer of large datasets from sensors on vehicles, ships, and drones to analysis centers and Low Latency Communication ensures timely data relay, crucial for real-time monitoring, decision making of the location of the vehicles in the distributed swarmed network and early warning systems.

#### 3. Disaster Response

- Real-Time Assessments: Data from drones and ships can aid in disaster response by providing up-to-date information on affected areas, facilitating rescue and relief operations.
- Resource Deployment: Optimize the deployment of emergency resources based on real-time data.
- Analysis and algorithms based on swarm models (both statistical and AI supported on specific trained data in dynamic scenarios), to make faster decisions of the mesh parts, and disaster response itself.

#### 4. AI Improved Algorithms

- Special trained AI models can improve the statistical decision algorithms that take decisions both on the system itself (where are the sensors needed to be sent in the system, or how the mobile mesh swarm network evoluates in time), and to the incident response teams or systems, as they can know, based on forecasting, where and when they can action, before critical events.

#### 5. AI Improved Algorithms by External Systems Aggregated Data

- External available resources could be used in the training of the AI models or immediate decision combination in the decision algorithm.
As examples, extensive publicly available data from **Google Earth AI** and others (NASA, Telecomms special APIs, etc), can provide already pre-trained models for weighing the decision and the routing part of the system to most critical areas and most likely predicted with problems from before AI system training, by using their interconnected data for forecasting, for the pre-setup of the system (eg: limit to most probable certain areas conditions), or advanced use combining real-time results of the system with pre-known data.

#### 6. Other APIs & System parts

Libraries and implementations of other external and internal engines and APIs for different specific parts of the system. Examples (not final) include the following:
- BigData_AI_Decision_System - Decision engine variant of the system, as a complete SQL implementation for Google Cloud Datawarehouse & BigQueryAI optimized AI enhanced search for the multitude multi-modal sources of Big Data, to combine and get the best results;
- Communications_APIs - external communications libraries via multiple channels;
- Distributed_Ledgers_Operations - libraries and system for storing eventual external events in need of a Distributed ledger / Blockchain / etc.;
- GENIEAI Framework (OPEA/Haystack/GovStack) - integration of the system with an AI framework which includes multiple capabilities and standards;
- IoT_Operations - IoT / SIM specific operations libraries and system for specific external communications and operations (eg: telecom, robots, edge cases, etc.);


#### Conclusion
This work in progress is a proposal as to the article idea, with things that can be improved in current systems, or thought of as from a different perspective, with their example higher level software architectures, while the final complete system architectures and implementations might be depending on many other factors, but can be assemblied from the parts and implementations of presented system.
