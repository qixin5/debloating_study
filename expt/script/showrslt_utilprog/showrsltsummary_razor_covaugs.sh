#!/bin/bash

BENCH=$1
PROGNAME=$2
showinfo=byte0
beta=1

showrslt_utilprog/showrsltsummary_inrgf_razor_main.sh $BENCH $PROGNAME covaug1 ${showinfo} ${beta}
showrslt_utilprog/showrsltsummary_inrgf_razor_main.sh $BENCH $PROGNAME covaug2 ${showinfo} ${beta}
showrslt_utilprog/showrsltsummary_inrgf_razor_main.sh $BENCH $PROGNAME covaug3 ${showinfo} ${beta}
showrslt_utilprog/showrsltsummary_inrgf_razor_main.sh $BENCH $PROGNAME covaug4 ${showinfo} ${beta}
