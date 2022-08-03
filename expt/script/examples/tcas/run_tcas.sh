#!/bin/bash


echo "Clean up the working directory"
clean/clean.sh benchmark tcas


echo "Perform debloating (estimated time: 5 min)"
examples/tcas/debloat_tcas.sh


echo "Evaluate debloated programs (estimated time: 10 min)"
examples/tcas/evalprogs_tcas.sh


echo "Test robustness of debloated programs (estimated time: 15 min)"
examples/tcas/robusttest_tcas.sh


echo "Get result (estimated time: 1 min)"
examples/tcas/getstatistics_tcas.sh

