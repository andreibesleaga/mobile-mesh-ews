# Live Mobile Edge Sensors Swarm System: Simulation

[![Preprint](https://img.shields.io/badge/Preprint-TechRxiv-blue.svg)](https://www.techrxiv.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Python 3.9+](https://img.shields.io/badge/python-3.9+-blue.svg)](https://www.python.org/downloads/)

## Overview

This repository contains the supplementary simulation code for the paper:  
**"Live Mobile Edge Sensors Swarm System: Decentralized AI-Driven Early Warning Architecture for Disaster Response and Climate Monitoring"** *Author: BESLEAGA Andrei Nicolae*

This simulation validates **Innovation 1 (Section 4.1)** of the proposed architecture: the ability of a decentralized swarm to operate as a "Digital Immune System." It demonstrates how independent agents using simple local rules can achieve complex global behaviors—specifically **autonomous hazard detection**, **self-healing mesh formation**, and **consensus-based alert generation**—without reliance on a central cloud controller.

## Simulation Logic

The script `simulation.py` models a swarm of $N$ agents (representing UAVs or mobile sensors) operating in a communications-denied environment.

### 1. Agent State Machine
Each agent operates independently based on the following Finite State Machine (FSM):

* **SEARCHING (Blue):** The agent moves using a semi-random walk (approximating Levy flight) to cover the operational area.
* **VERIFYING (Orange):** Upon detecting a potential anomaly (sensor reading > threshold), the agent slows down and broadcasts a vote to neighbors within mesh range.
* **ALERTING (Red):** If a consensus threshold (>50% of neighbors) is reached, the agent transitions to an ALERT state, simulating a confirmed valid hazard.

### 2. Physics & Swarm Forces
The movement logic implements Reynolds' Boids flocking model, augmented with an attraction vector for hazard gradients:

$$\vec{V}_{new} = \vec{V}_{current} + \alpha \vec{F}_{attract} + \beta \vec{F}_{repulse} + \gamma \vec{F}_{align}$$

* **$\vec{F}_{attract}$:** Gradient descent vector moving toward higher sensor readings (the hazard).
* **$\vec{F}_{repulse}$:** Collision avoidance vector to maintain safe separation.
* **$\vec{F}_{align}$:** Velocity matching with neighbors to maintain mesh topology.

## Installation & Usage

### Prerequisites
* Python 3.8 or higher
* `numpy` (Matrix operations)
* `matplotlib` (Real-time visualization)

### Setup
```bash
# Clone the repository
git clone [https://github.com/your-username/Swarm-EWS-Simulation.git](https://github.com/your-username/Swarm-EWS-Simulation.git)
cd Swarm-EWS-Simulation

# Create a virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt


## Visualization
Since this environment is headless, the simulation will save an animation as `simulation.gif`.

To view the results, download or open `simulation.gif`. It displays the swarm in real-time:

Red Circle: The "Hazard Zone" (e.g., fire perimeter, chemical spill).
Blue Dots: Agents in SEARCH mode.
Orange Dots: Agents detecting a signal but waiting for consensus (VERIFY).
Red Dots: Agents that have achieved consensus (ALERT).
The title bar tracks the frame count. The console will print "ALERT TRIGGERED" once the decentralized consensus mechanism confirms the hazard.

Correlation to Paper Requirements
This simulation validates the following requirements defined in the System Architecture:

Req ID	Description	Implementation in Code
REQ-GEN-002	Emergent global behavior via local rules	Agents converge on hazard without central coordinates.
REQ-GEN-003	Resilience to node independence	No "Leader" node; consensus is peer-to-peer.
REQ-HSI-005	Confidence metrics & Consensus	Voting logic ( > 50% neighbor agreement).
