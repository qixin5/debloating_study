This folder contains the modifications needed to use Cov/CovA/CovF with Clang 15 (the original scripts are designed for Clang 9).

To achieve this, you need to follow these steps:

1. Follow `docker/Dockerfile` to initialize the environment. Change all version numbers from 9 to 15.
2. Apply the modifications in this folder by copying the files to the corresponding locations. Note that the modifications on `getcallgraph.sh` are only done for bash-2.05, make-3.79 and vim-5.8. If you need to run CovA on other programs, you will need to modify their `getcallgraph.sh` accordingly.
3. Follow the instructions in [INSTALL.md](../INSTALL.md) to install the tools and run the experiments.
