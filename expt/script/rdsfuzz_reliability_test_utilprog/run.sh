#!/bin/bash

BENCH=$1
PROGNAME=$2
progpath=$3
inputset=$4
forwhat=$5


#Using *_sirprog/run.sh is NOT a mistake
rdsfuzz_reliability_test_sirprog/run.sh $BENCH $PROGNAME ${progpath} ${inputset} ${forwhat}
