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

for aug in covaug1 covaug2 covaug3 covaug4; do

    logf=${logd}/evalprog_razor${aug}_${trainid}.txt
    >${logf}

    start_time=$(date +%s.%N)
    
    progpath=${trainid}_${aug}
    evalprog_sirprog/evalprog_razor.sh $BENCH $PROGNAME ${progpath} ${testid} &>>${logf}
    
    end_time=$(date +%s.%N)
    timedur=$(echo "${end_time} - ${start_time}" | bc)
    echo "total time: ${timedur}s" &>>${logf}
    avgtimedur=`echo "scale=0; ${timedur} / 1" | bc -l`
    echo "avg time: ${avgtimedur}s" &>>${logf}
    
done
