# Comparison of 32-bit CORDIC Algorithm Implementations

This repository contains three hardware implementations of the **CORDIC (COordinate Rotation DIgital Computer)** algorithm, designed using SystemVerilog. The project demonstrates and compares the efficiency of each implementation in terms of logic utilization, operating frequency, and hardware area.

## Project Overview

The CORDIC algorithm is widely used for calculating trigonometric, hyperbolic, and logarithmic functions. In this project, I have implemented three versions of a 32-bit CORDIC design:

1. **13 Combinational Stage CORDIC**
2. **13 Pipelined Stage CORDIC**
3. **Single Stage CORDIC**

MATLAB is used to generate testbench input data and to compare the hardware results with a golden reference. The comparison results are detailed in the [Comparison of 32-bit CORDIC Implementations.pdf](./Comparison%20of%2032-bit%20CORDIC%20Implementations.pdf).

## Features

- RTL design in SystemVerilog for each implementation.
- MATLAB scripts for generating testbench inputs and verifying hardware results.
- A comprehensive PDF comparing the three CORDIC implementations.

## File Structure

- **RTL Designs**
  - [cordic.sv ](./RTL_SystemVerilog/cordic.sv): 13 combinational stage CORDIC design.
  - [cordic_pipeline.sv ](./RTL_SystemVerilog/cordic_pipeline.sv): 13 pipelined stage CORDIC design.
  - [cordic_singleStage.sv ](./RTL_SystemVerilog/cordic_singleStage.sv): Single stage CORDIC design.
  
- **Testbench**
  - [top.sv ](./testBench_SystemVerilog/top.sv): Top module for the testbench. This file instantiates the CORDIC algorithm and the testbench logic. You need to edit the `define` and parameters to run the desired test.

- **MATLAB Files**
  - [generate_data_for_rtl.mlx ](./matlab_files/generate_data_for_rtl.mlx): Script for generating input data for the RTL testbench.
  - [represent_rtl_results.mlx ](./matlab_files/represent_rtl_results.mlx): Script for comparing RTL results with the MATLAB-generated golden reference data.

- **Comparison Document**
  - [Comparison of 32-bit CORDIC Implementations.pdf ](./Comparison%20of%2032-bit%20CORDIC%20Implementations.pdf): This document provides a detailed comparison of the three CORDIC implementations, including design analysis and performance metrics.

## Requirements

- **MATLAB**
- **ModelSim/QuestaSim** for running the SystemVerilog simulations.

## Installation and Usage

### Step 1: Generate Input Data
1. Open [generate_data_for_rtl.mlx ](./matlab_files/generate_data_for_rtl.mlx).
2. Set your desired configuration (such as input range, number of test points, etc.).
3. Run the script to generate the input data for the RTL testbench.

### Step 2: Run the SystemVerilog Testbench
1. Open [top.sv ](./testBench_SystemVerilog/top.sv).
2. Edit the parameters and `define` statements to match the desired CORDIC implementation.
3. Run the simulation in ModelSim or QuestaSim.

### Step 3: Compare Results
1. Open [represent_rtl_results.mlx ](./matlab_files/represent_rtl_results.mlx).
2. Set the same configurations used in the RTL testbench.
3. Run the script to compare the RTL results with the golden reference data generated in MATLAB.

## Documentation

For a detailed explanation of the CORDIC algorithm and a comparison of the three implementations, refer to [Comparison of 32-bit CORDIC Implementations.pdf](./Comparison%20of%2032-bit%20CORDIC%20Implementations.pdf).

## Reference

This work references concepts from the book **"From Algorithms to Hardware Architectures Using Digital Radios as a Design Example"** written by Prof. Karim Abbas.
