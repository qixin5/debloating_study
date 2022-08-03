#!/bin/bash

BENCH=$1
PROGNAME=$2
debopruntype=$3

if [ -z $BENCH ] || [ -z $PROGNAME ] || [ -z ${debopruntype} ]; then
    echo "Missing arguments!"
    exit 1
fi

for inputset in I0 I1 I2 I3 I4 I5 I6 I7 I8 I9; do
    copy/cp_debop_prog_to_debaug_with_dce.sh $BENCH $PROGNAME ${inputset} ${debopruntype}
done
