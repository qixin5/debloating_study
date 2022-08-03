#!/bin/bash

BENCH=$1
PROGNAME=$2

SCRIPTDIR=$(pwd)


if [ -z $BENCH ] || [ -z $PROGNAME ]; then
    echo "Missing arguments!"
    exit 1
fi

cd $SCRIPTDIR/../chisel/$BENCH/$PROGNAME || exit 1

rm -fr chisel_out
rm -fr $PROGNAME
rm -fr ${PROGNAME}.c
rm -fr input
rm -fr *.txt
rm -fr output
rm -fr output.origin
rm -fr test*.sh
rm -fr run_chisel_*.sh
rm -fr tmp/*
