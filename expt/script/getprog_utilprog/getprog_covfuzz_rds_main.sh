#!/bin/bash

#NOTE: to force radamsa to run, pass true to force_radamsa_to_run.

BENCH=$1
PROGNAME=$2
inputset=$3
fuzznum=$4
ftype=$5                #ch or all
maxinputtofuzz=$6
force_radamsa_to_run=$7

if [ -z $BENCH ] || [ -z $PROGNAME ] || [ -z ${inputset} ] || [ -z ${fuzznum} ] || [ -z ${ftype} ]; then
    echo "Missing arguments!"
    exit 1
fi

if [ -z ${maxinputtofuzz} ]; then
    maxinputtofuzz=100
fi

if [ -z ${force_radamsa_to_run} ]; then
    force_radamsa_to_run=false
fi

fuzzid=rdsfuzz${ftype}n${fuzznum}

argsbackupdir=../debaug/$BENCH/$PROGNAME/rdsfuzz/augment/args.backup/${inputset}
fuzzedtestscriptdir=../debaug/$BENCH/$PROGNAME/rdsfuzz/augment/fuzzedtestscript/${inputset}


if [ ${force_radamsa_to_run} == "true" ]; then
    rm -fr ${argsbackupdir}
    rm -fr ${fuzzedtestscriptdir}
fi



#Generate fuzzed testscripts
if [ ! -d ${argsbackupdir} ] || [ ! -d ${fuzzedtestscriptdir} ]; then

    #Generate scripts from scratch
    rdsfuzz_utilprog/create_fuzzed_testscript.sh $BENCH $PROGNAME ${inputset} ${fuzznum} augment
    
else

    #Copy backup scripts
    argsdir=../debaug/$BENCH/$PROGNAME/rdsfuzz/augment/args/${inputset}
    if [ -d ${argsdir} ]; then
	rm -fr ${argsdir}
    fi
    cp -r ${argsbackupdir} ${argsdir}
fi

#Remove any old augment_cov_ch.txt, which keeps track of inputs leading to crash/hang
if [ -f ../debaug/$BENCH/$PROGNAME/rdsfuzz/augment/augment_cov_ch.txt ]; then
    rm ../debaug/$BENCH/$PROGNAME/rdsfuzz/augment/augment_cov_ch.txt
fi

#Run robust testing for program made by cov; obtain the specific inputs leading to crash/hang
if [ ${ftype} == "ch" ]; then

    rdsfuzz_reliability_test_utilprog/run.sh $BENCH $PROGNAME ${inputset}_cov ${inputset} augment
    SCRIPTDIR=$(pwd)
    cd ../debaug/$BENCH/$PROGNAME/rdsfuzz/augment/output/reduced/${inputset}_cov/${inputset}
    grep -r -l "Segmentation fault\|^124" &>../../../../augment_cov_ch.txt
    cd ${SCRIPTDIR}

fi


#Run llvm-cov instru (using *_sirprog/* is NOT a mistake)
echo "Instru run for llvm-cov"
instru_sirprog/run_instru_fuzz_rds.sh $BENCH $PROGNAME ${inputset} ${fuzznum} ${ftype}

#Run gcov instru (using *_sirprog/* is NOT a mistake) 
echo "Instru run for gcov"
instru_sirprog/run_instru_gccfuzz_rds.sh $BENCH $PROGNAME ${inputset} ${fuzznum} ${ftype}

#Fix instrumentation (using *_sirprog/* is NOT a mistake)
echo "Instru fix"
instru_sirprog/fix_llvmcov_result.sh $BENCH $PROGNAME ${inputset}_${fuzzid} ${inputset}_gcc${fuzzid}

#Get reduced prog (using *_sirprog/* is NOT a mistake)
getprog_sirprog/getprog_covfuzz_rds.sh $BENCH $PROGNAME ${inputset} ${fuzznum} ${ftype}
