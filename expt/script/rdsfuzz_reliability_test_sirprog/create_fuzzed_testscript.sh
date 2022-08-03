#!/bin/bash

BENCH=$1
PROGNAME=$2
inputset=$3
fuzznum=$4   #For every input
forwhat=$5   #augment or robust-testing


if [ -z $BENCH ] || [ -z $PROGNAME ] || [ -z ${inputset} ] || [ -z ${fuzznum} ] || [ -z ${forwhat} ]; then
    echo "Missing arguments!"
    exit 1
fi


#Using the script from *_utilprog is NOT a mistake!
rdsfuzz_utilprog/create_fuzzed_testscript.sh $BENCH $PROGNAME ${inputset} ${fuzznum} ${forwhat}
