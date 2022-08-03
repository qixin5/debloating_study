#!/bin/bash

BENCH=$1
PROGNAME=$2
buildupon=$3
selecthreshold=$4
ranktype=$5
topselectby=$6
inputset=$7

logd=../debaug/log/$BENCH/$PROGNAME
if [ ! -d ${logd} ]; then
    mkdir -p ${logd}
fi

if [ ${topselectby} == "percent" ]; then
    logf=${logd}/getprog_${buildupon}faug${ranktype}p${selecthreshold}_${inputset}.txt

elif [ ${topselectby} == "score" ]; then
    logf=${logd}/getprog_${buildupon}faug${ranktype}s${selecthreshold}_${inputset}.txt

else
    logf=${logd}/getprog_${buildupon}faug${ranktype}${selecthreshold}_${inputset}.txt

fi

>${logf}
start_time=$(date +%s.%N)

getprog_sirprog/getprog_faug_main.sh $BENCH $PROGNAME ${inputset} ${buildupon} ${selecthreshold} ${ranktype} ${topselectby}

end_time=$(date +%s.%N)
timedur=$(echo "${end_time} - ${start_time}" | bc)
echo "total time: ${timedur}s" &>>${logf}
avgtimedur=`echo "scale=0; ${timedur} / 1" | bc -l`
echo "avg time: ${avgtimedur}s" &>>${logf}
