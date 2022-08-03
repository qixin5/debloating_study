#!/bin/bash

BENCH=$1
PROGNAME=$2
fuzznum=$3
forwhat=$4

if [ -z $BENCH ] || [ -z $PROGNAME ] || [ -z ${fuzznum} ] || [ -z ${forwhat} ]; then
    echo "Missing arguments!"
    exit 1
fi


scriptdir=$(pwd)
logd=${scriptdir}/../debaug/log/$BENCH/$PROGNAME
if [ ! -d ${logd} ]; then
    mkdir -p ${logd}
fi
logf=${logd}/create_fuzzed_testscript_rds.txt
>${logf}
start_time=$(date +%s.%N)
last_time=${start_time}
inputsets=0


for inputset in I0 I1 I2 I3 I4 I5 I6 I7 I8 I9; do

    rdsfuzz_utilprog/create_fuzzed_testscript.sh $BENCH $PROGNAME ${inputset} ${fuzznum} ${forwhat} &>>${logf}

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
