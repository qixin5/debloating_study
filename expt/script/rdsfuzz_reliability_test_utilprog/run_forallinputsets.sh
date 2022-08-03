#!/bin/bash

BENCH=$1
PROGNAME=$2
srcid=$3
forwhat=$4


for inputset in I0 I1 I2 I3 I4 I5 I6 I7 I8 I9; do

    progpath=${inputset}_${srcid}
    
    #Using *_sirprog/run.sh is NOT a mistake
    rdsfuzz_reliability_test_sirprog/run.sh $BENCH $PROGNAME ${progpath} ${inputset} ${forwhat}

done
