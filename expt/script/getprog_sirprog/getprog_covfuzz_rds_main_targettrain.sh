#!/bin/bash

BENCH=$1
PROGNAME=$2
inputset=$3
fuzznum=$4
ftype=$5
maxinputtofuzz=$6
force_radamsa_to_run=$7

#It's fine maxinputtofuzz and force_radamsa_to_run are empty.
#They will be assigned as default values: 100 and false.
if [ -z $BENCH ] || [ -z $PROGNAME ] || [ -z ${inputset} ] || [ -z ${fuzznum} ] || [ -z ${ftype} ]; then
    echo "Missing arguments!"
    exit 1
fi

fuzzid=rdsfuzz${ftype}n${fuzznum}
scriptdir=$(pwd)
logd=${scriptdir}/../debaug/log/$BENCH/$PROGNAME
if [ ! -d ${logd} ]; then
    mkdir -p ${logd}
fi
logf=${logd}/getprog_cov${fuzzid}_${inputset}.txt
>${logf}

start_time=$(date +%s.%N)

getprog_sirprog/getprog_covfuzz_rds_main.sh $BENCH $PROGNAME ${inputset} ${fuzznum} ${ftype} ${maxinputtofuzz} ${force_radamsa_to_run} &>>${logf}

end_time=$(date +%s.%N)

timedur=$(echo "${end_time} - ${start_time}" | bc)
echo "total time: ${timedur}s" &>>${logf}
echo "avg time: ${timedur}s" &>>${logf}

