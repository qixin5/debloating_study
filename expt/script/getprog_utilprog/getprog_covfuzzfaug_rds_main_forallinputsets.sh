#!/bin/bash

BENCH=$1
PROGNAME=$2
fuzznum=$3
selecthreshold=$4

if [ -z $BENCH ] || [ -z $PROGNAME ] || [ -z ${fuzznum} ] || [ -z ${selecthreshold} ]; then
    echo "Missing arguments!"
    exit 1
fi

fuzzid=rdsfuzzn${fuzznum}
buildupon=cov${fuzzid}
ranktype=rutilfreqflex
topselectby=percent

getprog_utilprog/getprog_faug_main_forallinputsets.sh $BENCH $PROGNAME ${buildupon} ${selecthreshold} ${ranktype} ${topselectby}
