#!/bin/bash

BENCH=$1
PROGNAME=$2
inputset=$3

if [ -z $BENCH ] || [ -z $PROGNAME ] || [ -z ${inputset} ]; then
    echo "Missing arguments!"
    exit 1
fi

#echo "Running run_instru_cov.sh"
instru_sirprog/run_instru_cov.sh $BENCH $PROGNAME ${inputset}

#echo "Running run_instru_gcccov.sh"
instru_sirprog/run_instru_gcccov.sh $BENCH $PROGNAME ${inputset}

#echo "Running fix_llvmcov_result.sh"
instru_sirprog/fix_llvmcov_result.sh $BENCH $PROGNAME ${inputset}_cov ${inputset}_gcccov

#echo "Running getprog_cov.sh"
getprog_sirprog/getprog_cov.sh $BENCH $PROGNAME ${inputset}
