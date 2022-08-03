#!/bin/bash

BENCH=$1
PROGNAME=$2
inputset=$3
testset=$4

if [ -z $BENCH ] || [ -z $PROGNAME ] || [ -z ${inputset} ] || [ -z ${testset} ]; then
    echo "Missing arguments."
    exit 1
fi


echo "Produce debloated program by Razor"
cd ../../tools/razor/scripts_for_sirprog

./prepare_sirprog.sh $PROGNAME

./train_and_debloat.sh $PROGNAME ${inputset}



