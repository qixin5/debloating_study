#!/bin/bash

BENCH=$1
PROGNAME=$2
inputset=$3
fuzznum=$4 #For every input


if [ -z $BENCH ] || [ -z $PROGNAME ] || [ -z ${inputset} ] || [ -z ${fuzznum} ]; then
    echo "Missing arguments!"
    exit 1
fi


rdsfuzz_utilprog/create_fuzzed_testscript.sh $BENCH $PROGNAME ${inputset} ${fuzznum} 
