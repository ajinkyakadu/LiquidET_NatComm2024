<h1 align="center">LiquidET_NatComm2024</h1>
<p align="center">
  <b>Reconstruction Algorithm and Post-Processing for 3D Colloidal Assemblies</b>
</p>

---

## About This Repository

This repository features the **CS-DART** (Compressed Sensing Discrete Algebraic Reconstruction Technique) algorithm and associated post-processing codes. These are central to the research presented in our submission to *Nature Communications*. The details are as follows:

```bibtex
@article{arenas2023liquid,
  title={Liquid phase fast electron tomography unravels the true 3D structure of colloidal assemblies},
  author={Arenas Esteban, Daniel and Wang, Da and Kadu, Ajinkya and Olluyn, Noa and S{\'a}nchez Iglesias, Ana and Gomez Perez, Alejandro and Gonzalez Casablanca, Jesus and Nicolopoulos, Stavros and Liz-Marz{\'a}n, Luis M and Bals, Sara},
  journal={arXiv e-prints},
  pages={arXiv--2311},
  year={2023}
}
```
CS-DART combines compressed sensing with discrete tomographic principles to improve the 3D reconstruction of colloidal particles in liquid environment under HAADF-STEM imaging, despite the high electron dose sensitivity and significant missing wedge issues faced due to liquid-cell holder.

## Highlights

- **Advanced 3D Reconstruction**: CS-DART improves the reconstruction of colloidal particles from electron tomography data, revealing structures in liquid conditions.
  
- **Complex Structures Unveiled:** This method reveals the detailed 3D arrangements of gold nanoparticles, uncovering structures like tetrahedrals and other polyhedral geometries for particles counts N = 4, 5, 6.

- **Quantitative Analysis:** Provides detailed morphological analysis and spatial relationship metrics, utilizing alpha shapes for overall shape description.

- **Experimental Validation:** Demonstrates effectiveness against both synthetic and experimental datasets in challenging liquid environments.

---

## System Requirements

### Software Dependencies

- **MATLAB**: Tested with MATLAB R2023a.
- **Operating Systems**: Windows 10.

### MATLAB Toolboxes Required

- Image Processing Toolbox
- Statistics and Machine Learning Toolbox
- Computer Vision Toolbox (optional for some functions)

### Hardware Requirements

- Minimum **32 GB RAM**.
- **CPU**: Intel(R) Core(TM) i7-8700 @ 3.20GHz or similar.
- **GPU**: At least 8 GB of memory, tested with Nvidia RTX 2070.

### External Dependencies

- **ASTRA-Toolbox** v2.1.0: A framework for tomographic operators. [More Info](https://astra-toolbox.com/)
- **SPOT**: Simplifies modeling of linear operators in tomography. [More Info](https://www.cs.ubc.ca/labs/scl/spot/index.html)
- **MinConf Optimization Package**: Optimizes objectives including CS-DART. [More Info](https://www.cs.ubc.ca/~schmidtm/Software/minConf.html)

---

## Installation Guide

### Getting Started

1. **Clone the Repository**
   ```bash
   git clone https://github.com/ajinkyakadu/LiquidET_NatComm2024.git
   cd LiquidET_NatComm2024
   ```

2. **Set Up MATLAB Environment**
   ```matlab
   run('setup.m');
   ```

#### Installation Time

- Typical setup time is under **1 minute** on a standard desktop.


---

### Quick Start Guide

1. **Prepare the Environment**
   ```matlab
   cd examples
   ```

2. **Run Reconstruction Script**
   ```matlab
   ex01_step01_N4Liquid
   ```

3. **Execute Post-Processing**
   ```matlab
   ex01_step02_N4Liquid
   ```

#### Expected Outputs

- **Reconstructed Volume**: Saved as `csdart_reconstructed_volume.rec` in the `data` folder.
- **Quantitative Descriptors**: Stored as `quant_descriptors_NP.mat` in the `data` folder.

#### Expected Demo Time

- Approximately **30 minutes** on a standard desktop.

### Data Access

Access the dataset for different colloidal systems (N = 4, 5, 6) at [Zenodo](https://zenodo.org/records/11175299). Zenodo DOI: 10.5281/zenodo.11175299

---

## Usage

To adapt the software for your data:

1. **Data Preparation**
   Ensure your data is formatted correctly and placed in the `data` directory.

2. **Script Adjustments**
   - Modify `ex01_step01_N4Liquid.m` to reference your dataset and adjust parameters for CS-DART reconstruction scheme.
   - Adjust parameters like `cropRadius` and `minArea` in `ex01_step02_N4Liquid.m` to fit your data.

3. **Execute the Analysis**
   Follow the demo steps with your data specifics.

---

<div align="center">
  <b>Explore. Reconstruct. Analyze.</b>
</div>

