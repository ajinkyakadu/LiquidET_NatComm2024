# LiquidET_NatComm2024

This repository contains the reconstruction algorithm (CS-DART) and post-processing codes that are used in the following paper
```bibtex
@article{arenas2023liquid,
  title={Liquid phase fast electron tomography unravels the true 3D structure of colloidal assemblies},
  author={Arenas Esteban, Daniel and Wang, Da and Kadu, Ajinkya and Olluyn, Noa and S{\'a}nchez Iglesias, Ana and Gomez Perez, Alejandro and Gonzalez Casablanca, Jesus and Nicolopoulos, Stavros and Liz-Marz{\'a}n, Luis M and Bals, Sara},
  journal={arXiv e-prints},
  pages={arXiv--2311},
  year={2023}
}
```
This paper presents a novel approach to understanding the true three-dimensional (3D) structure of small colloidal assemblies within liquid cells using fast electron tomography. We introduce a new reconstruction algorithm, CS-DART (Compressed Sensing Discrete Algebraic Reconstruction Technique), designed to address the unique challenges posed by the high electron dose sensitivity of samples and the presence of liquid in high-angle annular dark-field scanning transmission electron microscopy (HAADF-STEM) imaging.  
- **Innovative Technique:** The paper introduces CS-DART, an advanced algorithm that combines compressed sensing and discrete tomographic principles to enhance the reconstruction of colloidal particles from electron tomography data acquired in liquid cells.
- **Complex Structures Unveiled:** By applying this method, we successfully reveal the intricate 3D arrangements of gold nanoparticles assembled in various structures (N = 4, 5, 6 particles), including those resembling tetrahedral and other polyhedral geometries.
- **Quantitative Analysis:** The study goes beyond qualitative imaging, providing a quantitative framework to analyze the morphology and spatial relationships of the nanoparticles within the assemblies. This includes measurements of particle centroids, volumes, surface areas, and solidity, along with the computation of alpha shapes to describe the overall shape of the assemblies.
- **Experimental Validation:** The approach is validated against synthetic datasets and experimental data, demonstrating its effectiveness in accurately reconstructing and characterizing structures that are otherwise challenging to interpret due to the complexities introduced by the liquid environment.


## System Requirements

### Software Dependencies and Operating Systems
- **MATLAB**: The code has been tested with MATLAB R2023a.
- **Operating System**: Windows 10.
- **MATLAB Toolboxes**: This code uses functions from the following MATLAB toolboxes:
  - Image Processing Toolbox
  - Statistics and Machine Learning Toolbox
  - Computer Vision Toolbox (optional for some functions)
  
Ensure these toolboxes are installed and activated in your MATLAB environment.

### Versions Tested
The code has been tested on:
- MATLAB R2023a
- Windows 10

### Required Hardware
- A standard desktop computer with at least 32 GB of RAM.
- A modern CPU (tested on Intel(R) Core(TM) i7-8700 CPU @ 3.20GHz).
- A GPU with at least 8 GB of memory (tested with Nvidia RTX 2070).

## Installation Guide

1. **Download the Repository**: Clone or download this repository to your local machine.
   ```bash
   git clone https://github.com/ajinkyakadu/LiquidET_NatComm2024.git
   cd LiquidET_NatComm2024
   ```
2. **Run the Setup Script**: Navigate to the main directory and run the `setup.m` script in MATLAB to set up the necessary paths.
   ```matlab
   run('setup.m');
   ```
   
### Typical Install Time
The setup should take less than a minute on a normal desktop computer.

## Demo

### Instructions to Run the Demo
1. **Navigate to the Examples Directory**: Change directory to the `examples` folder.
   ```matlab
   cd examples
   ```
2. **Run the Reconstruction Script**: Execute the `ex01_step01_N4Liquid.m` script to perform CS-DART reconstruction.
   ```matlab
   ex01_step01_N4Liquid
   ```
3. **Run the Post-Processing Script**: Execute the `ex01_step02_N4Liquid.m` script to obtain quantitative indicators.
   ```matlab
   ex01_step02_N4Liquid
   ```

### Expected Output
- The first script (`ex01_step01_N4Liquid.m`) will output a CS-DART reconstructed volume saved as `csdart_reconstructed_volume.rec` in the `data` folder.
- The second script (`ex01_step02_N4Liquid.m`) will produce various quantitative descriptors saved as `quant_descriptors_NP.mat` in the `data` folder.

### Expected Run Time for Demo
- The demo is expected to run for approximately 30 minutes on a "normal" desktop computer.

## Instructions for Use

To run the software on your own data:

1. **Prepare Your Data**: Ensure your data is in the required format and place it in the `data` directory.
2. **Modify the Scripts**: 
   - If needed, modify `ex01_step01_N4Liquid.m` to point to your data file instead of the provided dataset.
   - Update parameters such as `cropRadius` and `minArea` in `ex01_step02_N4Liquid.m` based on your data characteristics.
3. **Run the Scripts**: Follow the demo instructions but use your data paths and names.
