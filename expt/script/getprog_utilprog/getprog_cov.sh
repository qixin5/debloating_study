#!/bin/bash

BENCH=$1
PROGNAME=$2
inputset=$3


if [ -z $BENCH ] || [ -z $PROGNAME ] || [ -z ${inputset} ]; then
    echo "Missing arguments!"
    exit 1
fi

cd ../debaug/$BENCH/$PROGNAME || exit 1


LINE_PRINTER_BIN=${DEBAUG_DIR}/bin/startandendlineprinter
REMOVER_BIN=${DEBAUG_DIR}/bin/gcovbasedcoderemover
MERGE_BIN=${DEBAUG_DIR}/bin/gcovbasedcoveragemerger

#Generate line file
if [ ! -f line.txt ]; then
    ${LINE_PRINTER_BIN} src/origin/$PROGNAME.c >line.txt
fi

#Merge all coverage files into one
if [ ! -d gcov/${inputset}_cov ]; then
    echo "Missing gcov/${inputset}_cov."
    exit 1
fi
${MERGE_BIN} binary gcov/${inputset}_cov >gcov/${inputset}_cov_merged


#Remove old result
if [ ! -d src/reduced/${inputset}_cov ]; then
    mkdir -p src/reduced/${inputset}_cov
else
    rm src/reduced/${inputset}_cov/*
fi


#Generate cov-based code
${REMOVER_BIN} src/origin/$PROGNAME.c line.txt gcov/${inputset}_cov_merged >src/reduced/${inputset}_cov/$PROGNAME.nodce.c


#Remove dead code
${DEBAUG_DIR}/bin/debdce src/reduced/${inputset}_cov/$PROGNAME.nodce.c src/reduced/${inputset}_cov/$PROGNAME.c
