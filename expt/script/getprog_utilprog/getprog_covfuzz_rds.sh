#!/bin/bash

BENCH=$1
PROGNAME=$2
inputset=$3
fuzznum=$4
ftype=$5      #ch or all

if [ -z $BENCH ] || [ -z $PROGNAME ] || [ -z ${inputset} ] || [ -z ${fuzznum} ]; then
    echo "Missing arguments!"
    exit 1
fi

cd ../debaug/$BENCH/$PROGNAME || exit 1


LINE_PRINTER_BIN=${DEBAUG_DIR}/bin/startandendlineprinter
REMOVER_BIN=${DEBAUG_DIR}/bin/gcovbasedcoderemover
MERGE_BIN=${DEBAUG_DIR}/bin/gcovbasedcoveragemerger
DEBDCE_BIN=${DEBAUG_DIR}/bin/debdce
fuzzid=rdsfuzz${ftype}n${fuzznum}

#Generate line file
if [ ! -f line.txt ]; then
    ${LINE_PRINTER_BIN} src/origin/$PROGNAME.c >line.txt
fi


#Merge all coverage files into one
if [ ! -d gcov/${inputset}_cov ]; then
    echo "Missing gcov/${inputset}_cov."
    exit 1
fi
if [ ! -d gcov/${inputset}_${fuzzid} ]; then
    echo "Missing gcov/${inputset}_${fuzzid}."
    exit 1
fi

gcovf=gcov/${inputset}_cov${fuzzid}_merged
${MERGE_BIN} binary gcov/${inputset}_cov gcov/${inputset}_${fuzzid} >${gcovf}


#Remove old code
rsltdir=src/reduced/${inputset}_cov${fuzzid}
if [ ! -d ${rsltdir} ]; then
    mkdir -p ${rsltdir}
else
    rm ${rsltdir}/*
fi

#Generate covfuzz-based code
${REMOVER_BIN} src/origin/$PROGNAME.c line.txt ${gcovf} >${rsltdir}/$PROGNAME.nodce.c

#Remove dead code
${DEBDCE_BIN} ${rsltdir}/$PROGNAME.nodce.c ${rsltdir}/$PROGNAME.c
