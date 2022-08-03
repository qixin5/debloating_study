#!/bin/bash

BENCH=$1
PROGNAME=$2
inputset=$3
scoretype=$4
SCORECALBIN=${DEBAUG_DIR}/bin/functionscorecalculator
SCOREFILTERBIN=${DEBAUG_DIR}/bin/functionfilter


if [ -z $BENCH ] || [ -z $PROGNAME ] || [ -z ${inputset} ] || [ -z ${scoretype} ]; then
    echo "Missing arguments."
    exit 1
fi

if [[ ${scoretype} == pr* ]]; then
    statictype=pr
elif [[ ${scoretype} == rpr* ]]; then
    statictype=rpr
elif [[ ${scoretype} == util* ]]; then
    statictype=util
elif [[ ${scoretype} == rutil* ]]; then
    statictype=rutil
else
    statictype=ukn
fi

progdir=../debaug/$BENCH/$PROGNAME
if [ ! -d ${progdir} ]; then
    echo "Directory does not exist: ${progdir}"
    exit 1
fi

scf=${progdir}/func/info/${statictype}/rslt.txt          #Static score file
flexf=${progdir}/func/info/flex/${inputset}_cov/rslt.txt
freqf=${progdir}/func/info/freq/${inputset}_cov/rslt.txt
gcovmergedf=${progdir}/gcov/${inputset}_cov_merged       #Used to identify inconsistent funcs

func/getfuncstaticscore_main.sh $BENCH $PROGNAME ${statictype}

func/getfuncflex_main.sh $BENCH $PROGNAME ${inputset} || exit 1

func/getfuncfreq_main.sh $BENCH $PROGNAME ${inputset} || exit 1

if [ ! -f ${gcovmergedf} ]; then
    echo "No merged cov file: ${gcovmergedf}."
    exit 1
fi

rsltdir=${progdir}/func/rank/${scoretype}/${inputset}_cov
if [ ! -d ${rsltdir} ]; then
    mkdir -p ${rsltdir}
else
    rm -fr ${rsltdir}/*
fi

if [ ${scoretype} == "prflex" ] || [ ${scoretype} == "rprflex" ] || \
   [ ${scoretype} == "utilflex" ] || [ ${scoretype} == "rutilflex" ]; then

    $SCORECALBIN ${scoretype} ${scf} ${flexf} >${rsltdir}/rslt.nofilter.txt
    $SCOREFILTERBIN ${rsltdir}/rslt.nofilter.txt ${gcovmergedf} >${rsltdir}/rslt.txt

elif [ ${scoretype} == "prfreq" ] || [ ${scoretype} == "rprfreq" ] || \
     [ ${scoretype} == "utilfreq" ] || [ ${scoretype} == "rutilfreq" ]; then

    $SCORECALBIN ${scoretype} ${scf} ${freqf} >${rsltdir}/rslt.nofilter.txt
    $SCOREFILTERBIN ${rsltdir}/rslt.nofilter.txt ${gcovmergedf} >${rsltdir}/rslt.txt    

elif [ ${scoretype} == "prfreqflex" ] || [ ${scoretype} == "rprfreqflex" ] || \
     [ ${scoretype} == "utilfreqflex" ] || [ ${scoretype} == "rutilfreqflex" ]; then

    $SCORECALBIN ${scoretype} ${scf} ${freqf} ${flexf} >${rsltdir}/rslt.nofilter.txt
    $SCOREFILTERBIN ${rsltdir}/rslt.nofilter.txt ${gcovmergedf} >${rsltdir}/rslt.txt

else
    #TODO: Handle pr, rpr, util, rutil, flex, & freq.
    echo "Unrecognized score type: ${scoretype}."
fi
