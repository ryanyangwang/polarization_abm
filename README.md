# Overview

This repository contains the simulation code, model files, and output visualizations for the following study:

**"Selective Exposure to News, Homogeneous Political Discussion Networks, and Affective Political Polarization: An Agent-Based Modeling of Minimal Versus Strong Communication Effects"**  
By [Gil de Zúñiga, H., Wang, R. Y. & Cheng, Z.], [2025]  

This study uses an agent-based modeling (ABM) approach to simulate how interpersonal political discussions and selective exposure to media interact to shape **affective polarization**, **social diversity**, and **media diversity** within a hostile partisan environment. The model explores four communication scenarios: minimal, strong, social-dominant, and media-dominant, across 16 parameter combinations, calibrated with U.S. survey data.

---

## Contents

| File | Description |
|------|-------------|
| `simulation_model.nlogo` | NetLogo model implementing the main simulation described in the paper |
| `validation_model.nlogo` | Validation version using empirically calibrated agent attributes |
| `simulation.csv` | Output data from 16 experimental conditions (100 iterations each) |
| `visualization.R` | R script for plotting affective polarization, social/media diversity, and partisan differences (as presented in the paper) |
| `appendix.pdf` | Technical appendix detailing data calibration, variable definitions, parameter settings, and model algorithms |

---

## Model Implementation

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

## Model Introduction

### 1. **Model versions**

- `simulation_model.nlogo`: The base version of the model with **generalized (non-calibrated)** agent attributes and randomized initialization.
- `validation_model.nlogo`: The **empirically calibrated** version of the model based on a nationally representative U.S. survey (see Appendix for calibration details).
- All simulation results were generated using NetLogo’s **BehaviorSpace** tool, which executed **16 experimental conditions** (four combinations of social/media influence × homogeneous discussion/selective exposure) as described in the **technical appendix**.

### 2. **Visualizing results from `simulation.csv`**

To reproduce the key visualizations presented in the paper:

- Run the `visualization.R` script using R (recommended: R ≥ 4.2).
- The script will generate:
  - Affective polarization trends over time  
  - Social diversity index (based on interpersonal interactions)  
  - Media diversity index (based on news consumption)  
  - Partisan comparisons at the final simulation step

Figures correspond to those reported in the manuscript and supplement.

---

## Citation

If you use these materials, please cite the paper as:

[Gil de Zúñiga, H., Wang, R. Y. & Cheng, Z.]. (2025). Selective Exposure to News, Homogeneous Political Discussion Networks, and Affective Political Polarization: A Agent-Based Modeling of Minimal Versus Strong Communication Effects. [Social Science Computer Review].

---

## Contact

For questions or feedback of the model, please contact:  
**[Ryan Y. Wang]** – [ryan.wang@lsu.edu]  
[Louisiana State University, United States]

---

## Note

This repository is shared for academic and non-commercial use. Please do not distribute modified versions without attribution.
