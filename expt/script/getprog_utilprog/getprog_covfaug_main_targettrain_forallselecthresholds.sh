#!/bin/bash

BENCH=$1
PROGNAME=$2
inputset=$3

buildupon=cov
ranktype=rutilfreqflex
topselectby=percent

for selecthreshold in 5 10 15 20 25 30 35 40 45 50; do
    getprog_utilprog/getprog_faug_main_targettrain.sh $BENCH $PROGNAME ${buildupon} ${selecthreshold} ${ranktype} ${topselectby} ${inputset}
done
