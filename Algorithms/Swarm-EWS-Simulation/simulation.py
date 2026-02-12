import numpy as np
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation
import random

# --- CONFIGURATION ---
NUM_AGENTS = 10
AREA_SIZE = 100
ANOMALY_POS = np.array([75, 75])  # Location of the fire/hazard
ANOMALY_RADIUS = 20
COMM_RANGE = 25          # Radius for local communication (mesh)
SENSOR_NOISE = 0.05      # Simulated sensor noise
ALERT_THRESHOLD = 0.5    # Confidence required to vote
CONSENSUS_REQ = 0.5      # % of neighbors needed to trigger global alert

class Agent:
    def __init__(self, id, x, y):
        self.id = id
        self.pos = np.array([float(x), float(y)])
        self.vel = np.random.randn(2)  # Random initial velocity
        self.confidence = 0.0          # Local detection confidence (0.0 - 1.0)
        self.state = "SEARCHING"       # SEARCHING, VERIFYING, ALERTING

    def sense_environment(self):
        # Simulated sensor reading: Higher closer to anomaly
        dist = np.linalg.norm(self.pos - ANOMALY_POS)
        signal = max(0, 1 - (dist / ANOMALY_RADIUS))
        
        # Add sensor noise
        noise = np.random.normal(0, SENSOR_NOISE)
        self.confidence = np.clip(signal + noise, 0.0, 1.0)
        return self.confidence

    def get_neighbors(self, agents):
        neighbors = []
        for agent in agents:
            if agent.id != self.id:
                dist = np.linalg.norm(self.pos - agent.pos)
                if dist < COMM_RANGE:
                    neighbors.append(agent)
        return neighbors

    def update(self, agents):
        # 1. SENSE
        self.sense_environment()
        neighbors = self.get_neighbors(agents)

        # 2. DECIDE (Consensus)
        if self.confidence > ALERT_THRESHOLD:
            self.state = "VERIFYING"
            
            # Gossip Protocol: Check neighbor votes
            votes = sum(1 for n in neighbors if n.confidence > ALERT_THRESHOLD)
            total_neighbors = len(neighbors)
            
            if total_neighbors > 0 and (votes / total_neighbors) > CONSENSUS_REQ:
                self.state = "ALERTING" # Consolidated Alert!
        else:
            self.state = "SEARCHING"

        # 3. ACT (Move)
        # Force 1: Attraction to Anomaly (Gradient Descent)
        if self.confidence > 0.1:
            # We "smell" the fire, move towards gradient
            force_attract = (ANOMALY_POS - self.pos) * 0.05
        else:
            # Random search (Levy flight approximation)
            force_attract = np.random.randn(2) * 0.5

        # Force 2: Repulsion (Collision Avoidance)
        force_repulse = np.zeros(2)
        for n in neighbors:
            dist = np.linalg.norm(self.pos - n.pos)
            if dist < 5: # Too close!
                force_repulse -= (n.pos - self.pos) * (1 / (dist + 0.1))

        # Force 3: Alignment (Flocking)
        force_align = np.zeros(2)
        if neighbors:
            avg_vel = np.mean([n.vel for n in neighbors], axis=0)
            force_align = (avg_vel - self.vel) * 0.1

        # Apply Forces
        total_force = force_attract + force_repulse * 2.0 + force_align
        self.vel += total_force
        
        # Limit speed
        speed = np.linalg.norm(self.vel)
        if speed > 2.0:
            self.vel = (self.vel / speed) * 2.0

        self.pos += self.vel
        
        # Boundary constraints
        self.pos = np.clip(self.pos, 0, AREA_SIZE)

# --- SIMULATION LOOP ---
agents = [Agent(i, np.random.rand()*AREA_SIZE, np.random.rand()*AREA_SIZE) for i in range(NUM_AGENTS)]

# Visualization
fig, ax = plt.subplots(figsize=(8, 8))
scatter = ax.scatter([], [], c=[], cmap='coolwarm', vmin=0, vmax=1, s=50)
circle = plt.Circle(ANOMALY_POS, ANOMALY_RADIUS, color='r', alpha=0.1, label='Hazard Zone')
ax.add_patch(circle)
ax.set_xlim(0, AREA_SIZE)
ax.set_ylim(0, AREA_SIZE)
ax.set_title("Swarm EWS Simulation: Decentralized Search")
ax.legend()

def init():
    scatter.set_offsets(np.empty((0, 2)))
    return scatter,

def update(frame):
    positions = []
    confidences = []
    alert_triggered = False

    for agent in agents:
        agent.update(agents)
        positions.append(agent.pos)
        
        # Color coding: Blue=Searching, Red=Alerting
        if agent.state == "ALERTING":
            confidences.append(1.0) # Red
            alert_triggered = True
        elif agent.state == "VERIFYING":
            confidences.append(0.6) # Orange
        else:
            confidences.append(0.0) # Blue

    if alert_triggered:
        ax.set_xlabel(f"Frame {frame}: ALERT TRIGGERED via Consensus!", color='red', weight='bold')
    else:
        ax.set_xlabel(f"Frame {frame}: Searching...", color='black')

    scatter.set_offsets(positions)
    scatter.set_array(np.array(confidences))
    return scatter,

ani = FuncAnimation(fig, update, frames=200, init_func=init, blit=False)
print("Saving simulation to 'simulation.gif' (this may take a moment)...")
ani.save('simulation.gif', writer='pillow', fps=15)
print("Simulation saved successfully!")