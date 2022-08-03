#!/bin/bash

BENCH=$1
PROGNAME=$2
showinfo=stmt
beta=1

showrslt_utilprog/showrsltsummary_inrgf_main.sh $BENCH $PROGNAME cov ${showinfo} ${beta}
