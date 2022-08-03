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
progid=$3

if [ -z $BENCH ] || [ -z $PROGNAME ] || [ -z ${progid} ]; then
    echo "Missing arguments!"
    exit 1
fi

scriptdir=$(pwd)
logd=${scriptdir}/../debaug/log/$BENCH/$PROGNAME
if [ ! -d ${logd} ]; then
    mkdir -p ${logd}
fi
logf=${logd}/evalprog_${progid}.txt
>${logf}
start_time=$(date +%s.%N)
last_time=${start_time}
inputsets=0

if [ ${progid} == "origin" ]; then

    evalprog_utilprog/evalprog_main.sh $BENCH $PROGNAME origin &>>${logf}

    end_time=$(date +%s.%N)
    timedur=$(echo "${end_time} - ${last_time}" | bc)
    echo "${inputset} time: ${timedur}s" &>>${logf}
    last_time=${end_time}
    inputsets=$((inputsets + 1))

else

    for inputset in I0 I1 I2 I3 I4 I5 I6 I7 I8 I9; do

	if [[ ${progid} == *randaug* ]]; then
	    for trial in {0..2}; do
                progpath=${inputset}_${progid}/${trial}
                evalprog_utilprog/evalprog_main.sh $BENCH $PROGNAME ${progpath} &>>${logf}
	    done

	else
	    progpath=${inputset}_${progid}
	    evalprog_utilprog/evalprog_main.sh $BENCH $PROGNAME ${progpath} &>>${logf}
	fi

	end_time=$(date +%s.%N)
	timedur=$(echo "${end_time} - ${last_time}" | bc)
	echo "${inputset} time: ${timedur}s" &>>${logf}
	last_time=${end_time}
	inputsets=$((inputsets + 1))
    done
fi

end_time=$(date +%s.%N)
timedur=$(echo "${end_time} - ${start_time}" | bc)
echo "total time: ${timedur}s" &>>${logf}
avgtimedur=`echo "scale=0; ${timedur} / ${inputsets}" | bc -l`
echo "avg time: ${avgtimedur}s" &>>${logf}
