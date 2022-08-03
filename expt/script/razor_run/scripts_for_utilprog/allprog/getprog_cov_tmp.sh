#!/bin/bash

#for progname in uniq-8.16; do
for progname in rm-8.4; do

    echo "${progname}"
    ./getprog_cov_and_copy_rslt_main_forallinputsets_tmp.sh benchmark.test2 ${progname}
    
done
