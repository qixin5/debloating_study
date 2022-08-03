#!/bin/bash

BENCH=$1
PROGNAME=$2

if [ -z $BENCH ] || [ -z $PROGNAME ]; then
    echo "Missing arguments!"
    exit 1
fi

for selecthreshold in 1 2 3 4 5 10 15 20 25 30 35 40 45 50; do

    progid=covfaugrutilfreqflexp${selecthreshold}
    evalprog_utilprog/evalprog_main_forallinputsets.sh $BENCH $PROGNAME ${progid}
    
done
