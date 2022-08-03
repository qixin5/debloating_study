#!/bin/bash

### PROGPATH ###
# origin, I0_chisel, I0_cov, I0_covfuzzch, I0_covfuzzall, I0_covfaugprflex5, I0_covfaugrandombyfunc5/0, I0_covrandaugcovfuzzch/0, I0_covrandaugcovfuzzall/0, I0_razorsaugzcall, I0_razorsaugzlib

### TESTID ###
# I0, I1

BENCH=$1
PROGNAME=$2
progpath=$3

if [ -z $BENCH ] || [ -z $PROGNAME ] || [ -z ${progpath} ]; then
    echo "Missing arguments!"
    exit 1
fi

for testid in I0 I1 I2 I3 I4 I5 I6 I7 I8 I9; do
    evalprog_utilprog/evalprog.sh $BENCH $PROGNAME ${progpath} ${testid}
done
