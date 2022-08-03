#!/bin/bash

BENCH=$1
PROGNAME=$2
scoretype=$3
SCORECALBIN=${DEBAUG_DIR}/bin/functionstaticscorecalculator

if [ -z $BENCH ] || [ -z $PROGNAME ] || [ -z ${scoretype} ]; then
    echo "Missing arguments."
    exit 1
fi

#Make callgraph.dot if it doesn't exist
func/getcallgraph.sh $BENCH $PROGNAME

#Make line.txt if it doesn't exist
otherfile/getlinefile.sh $BENCH $PROGNAME 



cd ../debaug/$BENCH/$PROGNAME || exit 1

rsltdir=func/info/${scoretype}
if [ ! -d ${rsltdir} ]; then
    mkdir -p ${rsltdir}
else
    rm -fr ${rsltdir}/*
fi

${SCORECALBIN} func/info/callgraph.dot line.txt ${scoretype} >${rsltdir}/rslt.txt

