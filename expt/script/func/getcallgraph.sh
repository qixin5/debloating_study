#!/bin/bash

BENCH=$1
PROGNAME=$2

if [ -z $BENCH ] || [ -z $PROGNAME ]; then
    echo "Missing arguments."
    exit 1
fi

cd ../debaug/$BENCH/$PROGNAME || exit 1

if [ ! -d func/info ]; then
    mkdir -p func/info
fi

if [ ! -f func/info/callgraph.dot ]; then
    cd func/info
    ../../getcallgraph.sh ../../src/origin/$PROGNAME.c
fi

