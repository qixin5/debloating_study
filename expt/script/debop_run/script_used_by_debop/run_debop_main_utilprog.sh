#!/bin/bash

PROGNAME=$1  #No need to provide inputset, as it will iterate from I0 to I9.

if [ -z ${PROGNAME} ]; then
    echo "Missing arguments."
    exit 1
fi

iternum=100000000

realorcov=0 #1 means real, others mean cov
alpha=0.5
beta=0.5
k=50
samplenum=1000
version=0
genfactor=1
TIMEOUT=6h

if [ ! -d log ]; then
    mkdir log
fi

./clean.sh $PROGNAME

timelogf=log/time.txt
>${timelogf}
start_time=$(date +%s.%N)
last_time=${start_time}
inputsets=0

for i in {0..9}; do
    timeout -k 9 ${TIMEOUT} ./run_debop.sh $PROGNAME ${realorcov} ${samplenum} ${iternum} ${alpha} ${beta} $k ${version} ${genfactor} I${i}

    end_time=$(date +%s.%N)
    timedur=$(echo "${end_time} - ${last_time}" | bc)
    echo "I${i} time: ${timedur}s" &>>${timelogf}
    last_time=${end_time}
    inputsets=$((inputsets + 1))
done

end_time=$(date +%s.%N)
timedur=$(echo "${end_time} - ${start_time}" | bc)
echo "total time: ${timedur}s" &>>${timelogf}
avgtimedur=`echo "scale=0; ${timedur} / ${inputsets}" | bc -l`
echo "avg time: ${avgtimedur}s" &>>${timelogf}

