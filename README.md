# Artifact for studying and understanding the tradeoffs between generality and reduction in software debloating

## About

This is the artifact associated with the paper "Studying and Understanding the Tradeoffs between Generality and Reduction in Software Debloating", which has been accepted by ASE'22. This repo contains the following files and directories:

- **README.md**: This file.
- **LICENSE.md**: The license file.
- **INSTALL.md**: The file containing information regarding installation and reproduction and examples.
- **docker**: This directory contains the docker file for building a docker image of the testing environment.
- **expt**: This directory contains testing data and scripts used for debloating.
- **setup.sh**: This file contains code needed for experimental setup.
- **build_chisel_debop_from_source.sh**: The script used to build Chisel and Debop from source.

## Installation

Please refer to [INSTALL.md](INSTALL.md).

If you want to use clang-15 instead of clang-9, please refer to the instructions in [for_clang_15/README.md](for_clang_15/README.md).

## Tools

Please refer to [here](https://github.com/qixin5/debaug) for the debloating tools we developed (i.e., Cov, CovA, and CovF). Please follow [INSTALL.md](INSTALL.md) to install and test the tools.

## Data repository

Please refer to [here](https://gitlab.com/anony22/debaug_release) to access data (including the debloated programs, the testing outputs, etc.) generated in our experiment.

