#!/bin/bash

BENCH=$1
PROGNAME=$2

if [ -z $BENCH ] || [ -z $PROGNAME ]; then
    echo "Missing arguments."
    exit 1
fi

for inputset in I0 I1 I2 I3 I4 I5 I6 I7 I8 I9; do
    for scoretype in prflex rprflex prfreqflex rprfreqflex; do
	func/getfuncscore_main.sh $BENCH $PROGNAME ${inputset} ${scoretype}
    done
done
