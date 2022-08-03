#!/bin/bash

BENCH=$1
PROGNAME=$2
inputset=$3 #E.g., I0 (inputs used for debloating)
buildupon=$4 #E.g., cov, covfuzzch, covfuzzall
selecthreshold=$5 #Integer between 1 and 100 (either as 100*score_threshold or percent_threshold)
ranktype=$6 #prflex, rprflex, rprfreqflex, etc.
topselectby=$7 #score or percent

AUGBIN=${DEBAUG_DIR}/bin/functionaugmenter
SELECTBIN=${DEBAUG_DIR}/bin/functionselecter
DEBDCE_BIN=${DEBAUG_DIR}/bin/debdce

if [ -z $BENCH ] || [ -z $PROGNAME ] || [ -z ${inputset} ] || \
   [ -z ${buildupon} ] || [ -z ${selecthreshold} ] || [ -z ${ranktype} ] || \
   [ -z ${topselectby} ]; then
    echo "Missing arguments."
    exit 1
fi


#Make line.txt (if needed)
otherfile/getlinefile.sh $BENCH $PROGNAME

scriptdir=$(pwd)
progdir=${scriptdir}/../debaug/$BENCH/$PROGNAME
cd ${progdir} || exit 1


builduponsrc=./src/reduced/${inputset}_${buildupon}/$PROGNAME.nodce.c #Must be nodce.c!
if [ ! -f ${builduponsrc} ]; then
    echo "Missing build-upon source: ${builduponsrc}."
    exit 1
fi

funcfile=./func/rank/${ranktype}/${inputset}_cov/rslt.txt
if [ ! -f ${funcfile} ]; then
    cd ${scriptdir}
    func/getfuncscore_main.sh $BENCH $PROGNAME ${inputset} ${ranktype}
    cd ${progdir}
fi

cd ${progdir}
if [ ${topselectby} == "percent" ]; then
    rsltdir=./src/reduced/${inputset}_${buildupon}faug${ranktype}p${selecthreshold}
elif [ ${topselectby} == "score" ]; then
    rsltdir=./src/reduced/${inputset}_${buildupon}faug${ranktype}s${selecthreshold}
else
    echo "Unknown ${topselectby}."
    exit 1
fi

if [ ! -d ${rsltdir} ]; then
    mkdir -p ${rsltdir}
else
    rm -fr ${rsltdir}/*
fi

if [ ! -d tmp ]; then
    mkdir tmp
fi

#Produce augmented program
$SELECTBIN ${funcfile} ${topselectby} ${selecthreshold} >tmp/funcs.txt
$AUGBIN tmp/funcs.txt ${builduponsrc} line.txt ./src/origin/$PROGNAME.c >${rsltdir}/$PROGNAME.nodce.c

#Remove dead code
${DEBDCE_BIN} ${rsltdir}/$PROGNAME.nodce.c ${rsltdir}/$PROGNAME.c
