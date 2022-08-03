#!/bin/bash

### PROGID ###
# origin, chisel, cov, covfuzzch, covfuzzall
# covfaugprflexp5/10/20/50
# covfuzzchfaugprflexp5/10/20/50
# covfuzzallfaugprflexp5/10/20/50
# covrandaugcovfuzzch, covrandaugcovfuzzall
# covrandaugcovfaugprflexp5/10/20/50


BENCH=$1
PROGNAME=$2
progpath_without_trial=$3

if [ -z $BENCH ] || [ -z $PROGNAME ] || [ -z ${progpath_without_trial} ]; then
    echo "Missing arguments!"
    exit 1
fi

if [[ ${progpath_without_trial} != *randaug* ]]; then
    echo "Progpath doesn't seem to be random-based: ${progpath_without_trial}."
    exit 1
fi

scriptdir=$(pwd)
logd=${scriptdir}/../debaug/log/$BENCH/$PROGNAME
if [ ! -d ${logd} ]; then
    mkdir -p ${logd}
fi
logf=${logd}/evalprog_${progpath_without_trial}.txt
>${logf}
start_time=$(date +%s.%N)


for trial in {0..2}; do
    progpath=${progpath_without_trial}/${trial}
    evalprog_utilprog/evalprog_main.sh $BENCH $PROGNAME ${progpath} &>>${logf}
done


end_time=$(date +%s.%N)
timedur=$(echo "${end_time} - ${start_time}" | bc)
echo "total time: ${timedur}s" &>>${logf}
avgtimedur=`echo "scale=0; ${timedur}" | bc -l`
echo "avg time: ${avgtimedur}s" &>>${logf}
