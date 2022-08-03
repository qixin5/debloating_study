#!/bin/bash

BENCH=$1
PROGNAME=$2
progpath=$3
inputset=$4
forrazor=$5


#Using *_sirprog* is NOT a mistake
rdsfuzz_reliability_test_sirprog/check_rslt.sh $BENCH $PROGNAME ${progpath} ${inputset} ${forrazor}
