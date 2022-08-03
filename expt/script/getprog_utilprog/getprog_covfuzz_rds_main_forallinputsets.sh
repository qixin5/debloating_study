#!/bin/bash

BENCH=$1
PROGNAME=$2
fuzznum=$3
ftype=$4
maxinputtofuzz=$5
force_radamsa_to_run=$6


if [ -z $BENCH ] || [ -z $PROGNAME ] || [ -z ${fuzznum} ] || [ -z ${ftype} ]; then
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
scriptdir=$(pwd)
logd=${scriptdir}/../debaug/log/$BENCH/$PROGNAME
if [ ! -d ${logd} ]; then
    mkdir -p ${logd}
fi
logf=${logd}/getprog_cov${fuzzid}.txt
>${logf}
start_time=$(date +%s.%N)
last_time=${start_time}
inputsets=0

for inputset in I0 I1 I2 I3 I4 I5 I6 I7 I8 I9; do
    getprog_utilprog/getprog_covfuzz_rds_main.sh $BENCH $PROGNAME ${inputset} ${fuzznum} ${ftype} ${maxinputtofuzz} ${force_radamsa_to_run} &>>${logf}

    end_time=$(date +%s.%N)
    timedur=$(echo "${end_time} - ${last_time}" | bc)
    echo "${inputset} time: ${timedur}s" &>>${logf}
    last_time=${end_time}
    inputsets=$((inputsets + 1))
done

end_time=$(date +%s.%N)
timedur=$(echo "${end_time} - ${start_time}" | bc)
echo "total time: ${timedur}s" &>>${logf}
avgtimedur=`echo "scale=0; ${timedur} / ${inputsets}" | bc -l`
echo "avg time: ${avgtimedur}s" &>>${logf}

