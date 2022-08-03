#!/bin/bash

BENCH=$1
PROGNAME=$2

for fuzznum in 5 10 15 20 25 30 35 40 45 50; do
    fuzzid=rdsfuzzn${fuzznum}
    progid=cov${fuzzid}

    evalprog_utilprog/evalprog_main_forallinputsets.sh $BENCH $PROGNAME ${progid}
done
