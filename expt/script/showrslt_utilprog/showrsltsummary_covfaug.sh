#!/bin/bash

BENCH=$1
PROGNAME=$2
showinfo=$3
beta=$4

for topk in 5 10 15 20 25 30 35 40 45 50; do
    progid=covfaugrutilfreqflexp${topk}
    showrslt_utilprog/showrsltsummary_inrgf_main.sh $BENCH $PROGNAME ${progid} ${showinfo} ${beta}
done
