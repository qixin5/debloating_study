#!/bin/bash

BENCH=$1
PROGNAME=$2
buildupon=$3
selecthreshold=$4
ranktype=$5
topselectby=$6

logd=../debaug/log/$BENCH/$PROGNAME
if [ ! -d ${logd} ]; then
    mkdir -p ${logd}
fi

if [ ${topselectby} == "percent" ]; then
    logf=${logd}/getprog_${buildupon}faug${ranktype}p${selecthreshold}.txt

elif [ ${topselectby} == "score" ]; then
    logf=${logd}/getprog_${buildupon}faug${ranktype}s${selecthreshold}.txt

else
    logf=${logd}/getprog_${buildupon}faug${ranktype}${selecthreshold}.txt

fi

>${logf}
start_time=$(date +%s.%N)
last_time=${start_time}
inputsets=0

for inputset in I0 I1 I2 I3 I4 I5 I6 I7 I8 I9; do
    getprog_utilprog/getprog_faug_main.sh $BENCH $PROGNAME ${inputset} ${buildupon} ${selecthreshold} ${ranktype} ${topselectby}

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
