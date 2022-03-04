[![DOI](https://zenodo.org/badge/292129110.svg)](https://zenodo.org/badge/latestdoi/292129110)

# Overview
This repository contains the source code for the experiments performed, and simulator software used, in the paper entitled "Gaining environments through shape change" submitted to Nature Machine Intelligence.

It consists of four main parts: 1. the [Voxelyze](https://github.com/jonhiller/Voxelyze) physics simulator. 2. A Julia wrapper made by one of the authors for the Voxelyze physics engine 3. The source code for creating the robot model. 4. The source code for running the experiments described in the paper.

# Dependencies
1. Supported operating systems: use a version of Linux or a version of macOS. We have fully tested the code on macOS Mojave, and partially on Ubuntu 18.04.

2. Make sure you have a C/C++ compiler and [make](https://www.gnu.org/software/make/) installed on your system. The authors used Apple clang version 11.0.3 and GNU Make 3.81. However, GCC should also work.

3. Install version v1.3.1 of the [Julia programming language](https://julialang.org/downloads/oldreleases/)

4. You will need to install several packages in Julia. First, user your terminal to open the interactive Julia read–eval–print loop (repl) and press ] to enter the command mode
```julia
julia> ]
```
Then, install the following packages with the add command:
```julia
add Cxx
add Libdl
add StatsBase
add Colors
add BSON
```

You should now have all of the tools required to run the code.

# Build Voxelyze

1. Download this NATURE_MI2020 repository

```bash
git clone https://github.com/jpp46/NATURE_MI2020
```

2. Make and build the voxelyze library

```bash
cd NATURE_MI2020
make
```

**CHANGE COMPILER**: On line 4 in the makefile (called "makefile", without an extension), you can define your compiler with CC=(gcc | g++ | etc). In the configuration outlined here, we used CC=clang++ 

**ENABLE MULTITHREADING**: On line 6 in the makefile, you can define "USE_OMP" by adding the flag -DUSE_OMP=1 to the FLAGS command.

# How to use

The files that describe the underlying physics engine can be found in the **src** directory. **Voxelyze.jl** contains the code to wrap the underlying physics engine, including producing visualizations. **pancakerobot.jl** contains the code to start a simulation environment and build the robot model, and also contains the code for measuring robot fitness.

The 3 files **worker.jl**, **worker_semi.jl**, and **worker_closed.jl** can be used to run the experiments:
- worker.jl runs the completely open experiment where the shape, orientation and control of the robot are all optimized by the algorithm.
- worker_semi.jl runs the experiment where only shape, and control undergo optimization, while orientation was set as a constant.
- worker_closed.jl runs the experiment where only control is optimized, with orientation and shape being set as constants.

All of these files can be run in the following manner:
```bash
julia file.jl ID ENV
```
Where **ID** is used for the random seed (for reproducibility) and **ENV** is the desired slope of the ground. In the experiments presented in the manuscript, **ENV** was either 0 for flat ground, or 15 for inclined ground. For example, to run a completely open experiment on flat ground, run the following command:
```bash
julia worker.jl 1 0
```

## Statistical Tests and Graphs

To run the file **t-test.jl**, you will need to install the HypothesisTests package for Julia.
```julia
julia> ]
add HypothosisTests
```
This file runs a Welsh's t-test on the treatments described in the simulation results section of the manuscript.

To run the file **make_graphs.jl**, you will need to install the latest version of gnuplot. On a mac, this can be done with brew.
```bash
brew install gnuplot
```
Sometimes **make_graphs.jl** fails to save the plot correctly. If that happens, you can run the script manually using gnuplot.
```bash
gnuplot
gnuplot> (paste lines 1-43 of **make_graphs.jl** here)
# save plot manually and close pop-up terminal
gnuplot> (paste lines 45-64 of **make_graphs.jl** here)
# save plot manually and exit
```

# Additional Details About Voxelyze.jl

**Voxelyze.jl** is a wrapper around [Voxelyze](https://github.com/jonhiller/Voxelyze):

>Voxelyze is a general purpose multi-material voxel simulation library for static and dynamic analysis. To quickly get a feel for its capabilities you can create and play with Voxelyze objects using [VoxCAD](https://www.creativemachineslab.com/voxcad.html) (Windows and Linux executables available). An paper describing the theory and capabilities of Voxelyze has been published in Soft Robotics journal: "[Dynamic Simulation of Soft Multimaterial 3D-Printed Objects](http://online.liebertpub.com/doi/pdfplus/10.1089/soro.2013.0010)" (2014). [Numerous](https://sites.google.com/site/jonhiller/hardware/soft-robots) [academic](http://creativemachines.cornell.edu/soft-robots), [corporate](http://www.fastcompany.com/3006259/stratasyss-programmable-materials-just-add-water), and [educational](http://www.sciencebuddies.org/science-fair-projects/project_ideas/Robotics_p016.shtml) projects make use of Voxelyze.


## Basic Usage of the Voxelyze.jl Library

Basic use of Voxelyze consists of five simple steps:

1. Create a Voxelyze instance
2. Create a material
3. Add voxels using this material
4. Specify voxels that should be fixed in place, and specify which will have force applied to them
5. Execute timesteps

```julia
include("Voxelyze.jl")

Vx = Voxelyze(0.005)                        # 5mm voxels
pMaterial = addMaterial(Vx, 1000000, 1000)  # A material with stiffness E=1MPa and density 1000Kg/m^3
Voxel1 = setVoxel(Vx, pMaterial, 0, 0, 0)   # Voxel at index x=0, y=0. z=0
Voxel2 = setVoxel(Vx, pMaterial, 1, 0, 0)
Voxel3 = setVoxel(Vx, pMaterial, 2, 0, 0)   # Beam extends in the +X direction

setFixedAll(Voxel1)                         # Fixes all 6 degrees of freedom with an external condition on Voxel 1
setForce(Voxel3, 0, 0, -1)                  # Pulls Voxel 3 downward with 1 Newton of force.

for i=1:100                                 # Simulate 100 timesteps
    doTimeStep(Vx)
end
```

This is the equivalent of doing the following in the original Voxelyze library (C++):

```c++
#include "Voxelyze.h"

int main()
{
    CVoxelyze Vx(0.005);                                      // 5mm voxels
    CVX_Material* pMaterial = Vx.addMaterial(1000000, 1000);  // A material with stiffness E=1MPa and density 1000Kg/m^3
    CVX_Voxel* Voxel1 = Vx.setVoxel(pMaterial, 0, 0, 0);      // Voxel at index x=0, y=0. z=0
    CVX_Voxel* Voxel2 = Vx.setVoxel(pMaterial, 1, 0, 0);
    CVX_Voxel* Voxel3 = Vx.setVoxel(pMaterial, 2, 0, 0);      // Beam extends in the +X direction

    Voxel1->external()->setFixedAll();                        // Fixes all 6 degrees of freedom with an external condition on Voxel 1
    Voxel3->external()->setForce(0, 0, -1);                   // pulls Voxel 3 downward with 1 Newton of force.

    for (int i=0; i<100; i++) Vx.doTimeStep();                // simulate  100 timesteps.

    return 0;
}
```