#!/bin/bash

BENCH=$1
PROGNAME=$2
showinfo=stmt
beta=1

for fuzznum in 5 10 15 20 25 30 35 40 45 50; do
    fuzzid=covrdsfuzzn${fuzznum}
    showrslt_utilprog/showrsltsummary_inrgf_main.sh $BENCH $PROGNAME ${fuzzid} ${showinfo} ${beta}
done
