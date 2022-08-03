#!/bin/bash

BENCH=$1
PROGNAME=$2
inputset=$3

if [ -z $BENCH ] || [ -z $PROGNAME ] || [ -z ${inputset} ]; then
    echo "Missing arguments!"
    exit 1
fi

scriptdir=$(pwd)
logd=${scriptdir}/../debaug/log/$BENCH/$PROGNAME
if [ ! -d ${logd} ]; then
    mkdir -p ${logd}
fi
logf=${logd}/getprog_cov_${inputset}.txt
>${logf}

start_time=$(date +%s.%N)

getprog_utilprog/getprog_cov_main.sh $BENCH $PROGNAME ${inputset} &>>${logf}

end_time=$(date +%s.%N)

timedur=$(echo "${end_time} - ${start_time}" | bc)
echo "total time: ${timedur}s" &>>${logf}
echo "avg time: ${timedur}s" &>>${logf}

