#!/bin/bash

BENCH=$1
PROGNAME=$2
progpath=$3
inputset=$4
forwhat=$5


#Using *_sirprog* is NOT a mistake
rdsfuzz_reliability_test_sirprog/run_razor.sh $BENCH $PROGNAME ${progpath} ${inputset} ${forwhat}
