#!/bin/bash

######
# NOTE: This script has to be run within the program's working dir.
######

progname=$1
inputset=$2

if [ -z ${progname} ] || [ -z ${inputset} ]; then
    echo "Missing arguments."
fi

progabbr=`echo ${progname} | cut -d'-' -f1`
CURRDIR=$(pwd)
BIN=$CURRDIR/${progabbr}.orig
DRRUN=${RAZOR_DIR}/tracers/dynamorio/bin64/drrun
CLIENT=$CURRDIR/logs/libcbr_indcall.so
TIMEOUT=30


#Prepare logs dir
if [ -d logs ]; then
    rm -fr logs/*
else
    mkdir -p ./logs
fi
cp ../../../tracers/bin/libcbr_indcall.so ./logs/


#Compile
if [ ! -f $BIN ]; then
    ./compile.sh ${progname}.c $BIN "-g -Wl,--build-id"
fi


#Prepare input dir
if [ -d input ]; then
    rm -fr input
fi

input_origin_dir=${DEBSTUDY_DIR}/expt/debaug/benchmark/${progname}/input.origin
if [ -d ${input_origin_dir}/${inputset} ]; then
    if [ ${progname} == "make-3.79" ]; then
	cp -r -p ${input_origin_dir}/${inputset} ./input       #Use -p to keep the time stamps
    else
	cp -r ${input_origin_dir}/${inputset} ./input
    fi
fi


#Prepare output dir
if [ -d output ]; then
    rm -fr output/*
else
    mkdir output
fi


#Prepare a tmp dir for execution
if [ ! -d $CURRDIR/tmp ]; then
    mkdir $CURRDIR/tmp
else
    chmod 755 -R $CURRDIR/tmp
    rm -fr $CURRDIR/tmp/*
fi
cd $CURRDIR/tmp


#Run tests
for testf in $CURRDIR/testscript/${inputset}/*; do

    if [ ${progname} == "bash-2.05" ] || [ ${progname} == "vim-5.8" ]; then
	timeout -k 9 ${TIMEOUT}s ${DRRUN} -c ${CLIENT} -- /usr/bin/perl ${testf} $BIN ${CURRDIR}/output $TIMEOUT ${CURRDIR}/input
    else
	timeout -k 9 ${TIMEOUT}s ${DRRUN} -c ${CLIENT} -- /bin/bash ${testf} $BIN ${CURRDIR}/output $TIMEOUT ${CURRDIR}/input
    fi

    chmod 755 -R $CURRDIR/tmp
    rm -fr $CURRDIR/tmp/*
    
    #Kill the non-terminated ones
    if [ ! -z $BIN ]; then
        #Look for commands that start with $BIN ($11 is the start of command)
        procs=`ps aux | awk -v var="$BIN" '($11 == var)' | sed 's/\s\s*/ /g' | cut -d' ' -f2`
        if [ ! -z "${procs}" ]; then
            echo ${procs} >mykills.sh
            sed -e 's|^|kill -9 |g' -i mykills.sh
            chmod 700 mykills.sh
            ./mykills.sh
            rm mykills.sh
        fi
    fi    
    
done
