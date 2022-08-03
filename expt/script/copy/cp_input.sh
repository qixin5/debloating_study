#!/bin/bash

BENCH=$1
PROGNAME=$2
src_inputset=$3
target_inputset=$4

if [ -z $BENCH ] || [ -z $PROGNAME ] || [ -z ${src_inputset} ] || [ -z ${target_inputset} ]; then
    echo "Missing arguments!"
    exit 1
fi

cd ../$BENCH/${PROGNAME} || exit 1

if [ -d input.origin ]; then

    if [ -d input.origin/${target_inputset} ]; then
	rm -fr input.origin/${target_inputset}
    fi

    if [ $PROGNAME == "make-3.79" ]; then
	cp -r -p input.origin/${src_inputset} input.origin/${target_inputset}
    else
	cp -r input.origin/${src_inputset} input.origin/${target_inputset}
    fi
fi
