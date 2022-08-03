#!/bin/bash

BENCH=$1
PROGNAME=$2
showinfo=byte0
beta=1

showrslt_utilprog/showrsltsummary_inrgf_razor_main.sh $BENCH $PROGNAME cov ${showinfo} ${beta}
