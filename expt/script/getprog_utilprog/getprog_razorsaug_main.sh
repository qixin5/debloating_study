#!/bin/bash

BENCH=$1
PROGNAME=$2
inputset=$3 #E.g., I0 (inputs used for debloating)
augtype=$4 #zcall or zlib


if [ -z $BENCH ] || [ -z $PROGNAME ] || [ -z ${inputset} ] || [ -z ${augtype} ]; then
    echo "Missing arguments."
    exit 1
fi

cd ../debaug/$BENCH/$PROGNAME || exit 1


CURRDIR=$(pwd)
AUGBIN=${DEBAUG_DIR}/bin/razoraugmenter
DEBDCE_BIN=${DEBAUG_DIR}/bin/debdce
EXPTSCRIPTDIR=${DEBAUG_DIR}_expt/script


bbgcovf=gcov/bb/$PROGNAME.c.gcov
if [ ! -f ${bbgcovf} ]; then
    cd ${EXPTSCRIPTDIR}
    otherfile/getbbcovfile.sh $BENCH $PROGNAME
    cd $CURRDIR
    
    if [ ! -f ${bbgcovf} ]; then
	echo "Failed to generate ${bbgcovf}"
	exit 1
    fi
fi

inputsetgcovf=gcov/${inputset}_cov_merged
if [ ! -f ${inputsetgcovf} ]; then
    echo "Missing ${inputsetgcovf}"
    exit 1
fi

linef=line.txt
if [ ! -f ${linef} ]; then
    cd ${EXPTSCRIPTDIR}
    otherfile/getlinefile.sh $BENCH $PROGNAME
    cd $CURRDIR

    if [ ! -f ${linef} ]; then
        echo "Failed to generate ${linef}"
        exit 1
    fi
fi

cgf=func/info/callgraph.dot
if [ ! -f ${cgf} ]; then
    cd ${EXPTSCRIPTDIR}
    func/getcallgraph.sh $BENCH $PROGNAME
    cd $CURRDIR

    if [ ! -f ${cgf} ]; then
	echo "Failed to generate ${cgf}"
	exit 1
    fi
fi

rsltdir=src/reduced/${inputset}_razorsaug${augtype}
if [ ! -d ${rsltdir} ]; then
    mkdir -p ${rsltdir}
else
    rm -fr ${rsltdir}/*
fi

#Generate augmented code
$AUGBIN ${bbgcovf} ${inputsetgcovf} ${linef} src/origin/$PROGNAME.c ${cgf} ${augtype} >${rsltdir}/$PROGNAME.nodce.c

#Remove dead code
${DEBDCE_BIN} ${rsltdir}/$PROGNAME.nodce.c ${rsltdir}/$PROGNAME.c
