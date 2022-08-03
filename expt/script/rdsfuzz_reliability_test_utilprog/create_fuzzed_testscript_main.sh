#!/bin/bash

BENCH=$1
PROGNAME=$2
inputset=$3
fuzznum=$4       #Create how many fuzzed versions for each input?


if [ -z $BENCH ] || [ -z $PROGNAME ] || [ -z ${inputset} ] || [ -z ${fuzznum} ]; then
    echo "Missing arguments!"
    exit 1
fi

rdsfuzz_reliability_test_utilprog/create_fuzzed_testscript.sh $BENCH $PROGNAME ${inputset} ${fuzznum}
