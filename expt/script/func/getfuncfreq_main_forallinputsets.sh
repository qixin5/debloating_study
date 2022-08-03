#!/bin/bash

BENCH=$1
PROGNAME=$2

if [ -z $BENCH ] || [ -z $PROGNAME ]; then
    echo "Missing arguments."
    exit 1
fi

for inputset in I0 I1 I2 I3 I4 I5 I6 I7 I8 I9; do
    func/getfuncfreq_main.sh $BENCH $PROGNAME ${inputset}
done
