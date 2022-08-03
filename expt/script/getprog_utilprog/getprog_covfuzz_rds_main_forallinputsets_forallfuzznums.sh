#!/bin/bash

BENCH=$1
PROGNAME=$2
fuzznum=$3
ftype=$4
maxinputtofuzz=$5
force_radamsa_to_run=$6

getprog_utilprog/getprog_covfuzz_rds_main_forallinputsets.sh $BENCH $PROGNAME ${fuzznum} ${ftype} ${maxinputtofuzz} ${force_radamsa_to_run}
