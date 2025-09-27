# Replication Materials

This repository contains the full replication package for the paper:

**"Selective Exposure to News, Homogeneous Political Discussion Networks, and Affective Political Polarization: A Agent-Based Modeling of Minimal Versus Strong Communication Effects"**  
By [Author Names], [Year]  
(Forthcoming / Under Review — journal name redacted)

---

## Overview

This study uses an agent-based modeling (ABM) approach to simulate how interpersonal political discussions and selective exposure to media interact to shape **affective polarization**, **social diversity**, and **media diversity** within a hostile partisan environment. The model explores four communication scenarios: minimal, strong, social-dominant, and media-dominant, across 16 parameter combinations, calibrated with U.S. survey data.

---

## Contents

| File | Description |
|------|-------------|
| `simulation_model.nlogo` | NetLogo model implementing the main simulation described in the paper |
| `validation_model.nlogo` | Validation version using empirically calibrated agent attributes |
| `simulation.csv` | Output data from 16 experimental conditions (100 iterations each) |
| `visualization.R` | R script for plotting affective polarization, social/media diversity, and partisan differences (as presented in the paper) |

---

## Model implementation

The model was developed in **NetLogo 6.4.0** and simulates interactions between two types of agents:

- **Human agents** with ideological positions, party ID, affective polarization, and behavioral rules for news consumption and discussion
- **Media agents** with ideological positions and influence weights

Key mechanisms include:
- Selective exposure and homophily in partner/media choice
- Ideological updating with potential **backfire effects**
- Affective polarization dynamics
- Mobility driven by satisfaction and ideological discomfort

See `Appendix.pdf` for full technical specifications and parameter settings.

---

## Model introduction

1. **Run the model**:
   - Open `simulation_model.nlogo` or `validation_model.nlogo` (along with thein NetLogo 6.4.0
   - Use the included **BehaviorSpace** configuration to simulate the four scenarios with all parameter combinations

2. **Visualize results**:
   - Run `visualization.R` to generate key figures:
     - Affective polarization over time
     - Social diversity and media diversity indices
     - Partisan comparisons at simulation end

---

## 📚 Citation

If you use these materials, please cite the paper as:
