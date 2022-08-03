#!/bin/bash

BENCH=$1
PROGNAME=$2
progpath=$3
inputset=$4

if [ -z $BENCH ] || [ -z $PROGNAME ] || [ -z ${progpath} ] || [ -z ${inputset} ]; then
    echo "Missing arguments."
    exit 1
fi


#NOT a mistake
rdsfuzz_reliability_test_sirprog/check_rslt_razor.sh $BENCH $PROGNAME ${progpath} ${inputset}
