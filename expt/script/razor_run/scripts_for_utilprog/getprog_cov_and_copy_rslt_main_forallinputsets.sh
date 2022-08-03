#!/bin/bash

BENCH=$1
PROGNAME=$2
rootcodedir=${DEBSTUDY_DIR}/expt/debaug/$BENCH/$PROGNAME/razor_code #Result code saved here
logd=${DEBSTUDY_DIR}/expt/debaug/log/$BENCH/$PROGNAME


if [ -z $BENCH ] || [ -z $PROGNAME ]; then
    echo "Missing arguments!"
    exit 1
fi

if [ $PROGNAME == "bzip2-1.0.5" ]; then
    progabbr=bzip2
elif [ $PROGNAME == "chown-8.2" ]; then
    progabbr=chown
elif [ $PROGNAME == "date-8.21" ]; then
    progabbr=date
elif [ $PROGNAME == "grep-2.19" ]; then
    progabbr=grep
elif [ $PROGNAME == "gzip-1.2.4" ]; then
    progabbr=gzip
elif [ $PROGNAME == "mkdir-5.2.1" ]; then
    progabbr=mkdir
elif [ $PROGNAME == "rm-8.4" ]; then
    progabbr=rm
elif [ $PROGNAME == "sort-8.16" ]; then
    progabbr=sort
elif [ $PROGNAME == "tar-1.14" ]; then
    progabbr=tar
elif [ $PROGNAME == "uniq-8.16" ]; then
    progabbr=uniq
else
    echo "Unknown $PROGNAME."
    exit 1
fi



cd ../benchmarks/core-utilities/$PROGNAME || exit 1


if [ ! -d ${logd} ]; then
    mkdir -p ${logd}
fi
logf=${logd}/getprog_razor_cov.txt
>${logf}
start_time=$(date +%s.%N)
last_time=${start_time}
inputsets=0


#Generate and copy reduced programs
for inputset in I0 I1 I2 I3 I4 I5 I6 I7 I8 I9; do

    if [ ! -f testscript/${inputset}.py ]; then
	echo "Missing testscript/${inputset}.py."
	continue
    fi

    #Clean
    rm -fr *.txt
    rm -fr *.log
    rm -fr *.s
    rm -fr *.asm
    rm -fr logs
    rm -fr *.c
    rm -fr train
    rm -fr test
    rm -fr ${progabbr}.orig_temp


    #Copy the script
    cp testscript/${inputset}.py run_razor.py

    #Train
    python run_razor.py train


    #Produce cov program
    codedir=${rootcodedir}/reduced/${inputset}_cov
    python run_razor.py debloat
    if [ ! -d ${codedir} ]; then
	mkdir -p ${codedir}
    else
	rm -fr ${codedir}/*
    fi
    cp ${progabbr}.orig_temp/${progabbr}.orig.debloated ${codedir}/$PROGNAME


    #Record time
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
