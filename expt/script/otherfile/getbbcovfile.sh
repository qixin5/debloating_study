#!/bin/bash

BENCH=$1
PROGNAME=$2

if [ -z $BENCH ] || [ -z $PROGNAME ]; then
    echo "Missing arguments."
    exit 1
fi

cd ../debaug/$BENCH/$PROGNAME || exit 1

CURRDIR=$(pwd)
if [ ! -d gcov/bb ]; then
    mkdir gcov/bb
fi
cd gcov/bb

#Produce .gcov with bb info
$CURRDIR/compile.sh $CURRDIR/src/origin/$PROGNAME.c ./$PROGNAME "-fprofile-arcs -ftest-coverage" gcc
./$PROGNAME --version
gcov -a $PROGNAME.c

