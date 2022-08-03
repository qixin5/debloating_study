#!/bin/bash

BENCH=$1
PROGNAME=$2
progpath=$3

if [ -z $BENCH ] || [ -z $PROGNAME ] || [ -z ${progpath} ]; then
    echo "Missing arguments!"
    exit 1
fi

for testid in I0 I1 I2 I3 I4 I5 I6 I7 I8 I9; do
    evalprog_utilprog/evalprog_razor.sh $BENCH $PROGNAME ${progpath} ${testid}
done
