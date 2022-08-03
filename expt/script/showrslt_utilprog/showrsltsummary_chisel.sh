#!/bin/bash

BENCH=$1
PROGNAME=$2
showinfo=stmt
beta=1

if [ -z $BENCH ] || [ -z $PROGNAME ]; then
    echo "Missing arguments!"
    exit 1
fi

showrslt_utilprog/showrsltsummary_inrgf_main.sh $BENCH $PROGNAME chiselnosan ${showinfo} ${beta}
