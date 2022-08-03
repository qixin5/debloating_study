#!/bin/bash

BENCH=$1
PROGNAME=$2

if [ -z $BENCH ] || [ -z $PROGNAME ]; then
    echo "Missing arguments!"
    exit 1
fi

for progtype in origin cov covaug; do
    evalprog_utilprog/evalprog_razor_main_forallinputsets.sh $BENCH $PROGNAME ${progtype}
done
