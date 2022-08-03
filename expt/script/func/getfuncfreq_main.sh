#!/bin/bash

BENCH=$1
PROGNAME=$2
inputset=$3
FREQCALBIN=${DEBAUG_DIR}/bin/functionfrequencycalculator

if [ -z $BENCH ] || [ -z $PROGNAME ] || [ -z ${inputset} ]; then
    echo "Missing arguments."
    exit 1
fi

progdir=../debaug/$BENCH/$PROGNAME
if [ ! -d ${progdir} ]; then
    echo "Directory does not exist: ${progdir}."
    exit 1
fi

if [ ! -f ${progdir}/line.txt ]; then
    otherfile/getlinefile.sh $BENCH $PROGNAME
fi

if [ ! -d ${progdir}/gcov/${inputset}_cov ]; then
    echo "Missing coverage files for ${progdir}/gcov/${inputset}_cov."
    exit 1
fi

rsltdir=${progdir}/func/info/freq/${inputset}_cov
if [ ! -d ${rsltdir} ]; then
    mkdir -p ${rsltdir}
else
    rm -fr ${rsltdir}/*
fi

$FREQCALBIN ${progdir}/line.txt ${progdir}/gcov/${inputset}_cov >${rsltdir}/rslt.txt
