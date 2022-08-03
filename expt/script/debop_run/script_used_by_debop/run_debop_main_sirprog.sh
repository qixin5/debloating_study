#!/bin/bash

PROGNAME=$1
inputset=$2

if [ -z ${PROGNAME} ] || [ -z ${inputset} ]; then
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

#Remove old results
./clean.sh $PROGNAME ${inputset}


timelogf=log/${inputset}_time.txt
>${timelogf}
start_time=$(date +%s.%N)

timeout -k 9 ${TIMEOUT} ./run_debop.sh $PROGNAME ${realorcov} ${samplenum} ${iternum} ${alpha} ${beta} $k ${version} ${genfactor} ${inputset}

end_time=$(date +%s.%N)
timedur=$(echo "${end_time} - ${start_time}" | bc)
echo "total time: ${timedur}s" &>>${timelogf}
avgtimedur=`echo "scale=0; ${timedur} / 1" | bc -l`
echo "avg time: ${avgtimedur}s" &>>${timelogf}

