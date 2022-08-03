#!/bin/bash

BENCH=$1
PROGNAME=$2

if [ -z $BENCH ] || [ -z $PROGNAME ]; then
    echo "Missing arguments!"
    exit 1
fi

cd ../debaug/$BENCH/$PROGNAME || exit 1

if [ -d gcov ]; then
    rm -fr gcov
fi

rm -fr src/reduced/*

if [ -d func ]; then
    rm -fr func
fi

rm -fr $PROGNAME

rm -fr compare_rslt.txt

rm -fr chisel-out

rm -fr debop-out

rm -fr line.txt

rm -fr output

rm -fr output.instru

rm -fr input

rm -fr default.profraw

if [ -d rdsfuzz ]; then
    rm -fr rdsfuzz
fi

if [ -d rslt ]; then
    rm -fr rslt
fi

if [ -d tmp ]; then
    rm -fr tmp
fi

if [ -d razor_code ]; then
    rm -fr razor_code
fi

if [ -d razor_rslt ]; then
    rm -fr razor_rslt
fi

if [ -d output_razor ]; then
    rm -fr output_razor
fi
