#!/bin/bash

BENCH=$1
PROGNAME=$2
inputset=$3
MAXINPUTNUM=$4   #Select at most MAXINPUTNUM inputs for fuzzing
fuzznum=$5       #Create how many fuzzed versions for each input?
forwhat=$6       #augment or robust-testing


if [ -z $BENCH ] || [ -z $PROGNAME ] || [ -z ${inputset} ] || [ -z $MAXINPUTNUM ] || [ -z ${fuzznum} ] || [ -z ${forwhat} ]; then
    echo "Missing arguments!"
    exit 1
fi


rdsfuzz_reliability_test_sirprog/prepare_basescript.sh $BENCH $PROGNAME ${inputset} ${forwhat} $MAXINPUTNUM

rdsfuzz_reliability_test_sirprog/create_fuzzed_testscript.sh $BENCH $PROGNAME ${inputset} ${fuzznum} ${forwhat}
