# mobile-mesh-ews
## System architecture proposal for a Mobile Edge Sensors System for Early Warning Systems

#### Innovative usage of vehicles (equipped with sensors for reporting conditions and acquisition of data from different environments), as part of an IoT Edge Cloud Network, autonomously mimicking swarm intelligence, and ready to be integrated to other Early Warning Systems.

Part of the idea proposed in the article: https://medium.com/@andrei-besleaga/innovative-usage-of-emerging-it-technologies-in-multi-hazard-early-warning-systems-7bcfe3d170b9 , current repository contains diagramming for such a system (higher-level systems architecture specs) and this presentation (documentation).
<br>

A distributed network of mobile devices, from vehicles on the ground (EVs, Cars, etc.), water (ships), air (drones, planes), to special designed robots with sensors (used in special cases scenarios and environments), can be deployed as mobile sensors to monitor and respond to various climate issues, forming a mesh network mimicking swarm intelligence, to be an integral part of other multiple early warning systems.


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


#### 2. Integration and Communication

##### IoT/Edge and Cloud Computing:

- Real-Time Data Transmission: Vehicles, ships, and drones can be integrated into an IoT Edge network, enabling real-time transmission of collected (and partly processed) data to central cloud servers for analysis, storage, and decision making for next vehicle location.
- Data Aggregation: Cloud platforms can aggregate data from thousands of mobile sensors, providing comprehensive coverage and insights into climate patterns and anomalies (along with other existing data, eg: satellites data).
- 5G/6G Networks: High-speed mobile networks facilitate the rapid transfer of large datasets from sensors on vehicles, ships, and drones to analysis centers and Low Latency Communication ensures timely data relay, crucial for real-time monitoring, decision making of the location of the vehicles in the distributed swarmed network and early warning systems.

#### 3. Disaster Response

- Real-Time Assessments: Data from drones and ships can aid in disaster response by providing up-to-date information on affected areas, facilitating rescue and relief operations.
- Resource Deployment: Optimize the deployment of emergency resources based on real-time data.
- Analysis and algorithms based on swarm models (both statistical and AI supported on specific trained data in dynamic scenarios), to make faster decisions of the mesh parts, and disaster response itself.
