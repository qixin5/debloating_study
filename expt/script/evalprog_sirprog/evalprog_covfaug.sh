#!/bin/bash

BENCH=$1
PROGNAME=$2
trainid=$3
testid=$4

if [ -z $BENCH ] || [ -z $PROGNAME ]; then
    echo "Missing arguments!"
    exit 1
fi

scriptdir=$(pwd)
logd=${scriptdir}/../debaug/log/$BENCH/$PROGNAME
if [ ! -d ${logd} ]; then
    mkdir -p ${logd}
fi

for selecthreshold in 1 2 3 4 5 10 15 20 25 30 35 40 45 50; do

    logf=${logd}/evalprog_covfaugrutilfreqflexp${selecthreshold}_${trainid}.txt
    >${logf}

    start_time=$(date +%s.%N)
    
    progpath=${trainid}_covfaugrutilfreqflexp${selecthreshold}
    evalprog_sirprog/evalprog.sh $BENCH $PROGNAME ${progpath} ${testid} &>>${logf}

    end_time=$(date +%s.%N)
    timedur=$(echo "${end_time} - ${start_time}" | bc)
    echo "total time: ${timedur}s" &>>${logf}
    avgtimedur=`echo "scale=0; ${timedur} / 1" | bc -l`
    echo "avg time: ${avgtimedur}s" &>>${logf}
done
