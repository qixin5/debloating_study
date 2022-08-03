#!/bin/bash

BENCH=$1
PROGNAME=$2
chiselruntype=$3

if [ -z $BENCH ] || [ -z $PROGNAME ] || [ -z ${chiselruntype} ]; then
    echo "Missing arguments!"
    exit 1
fi


debaug_log_dir=../debaug/log/$BENCH/$PROGNAME
debaug_log_f=${debaug_log_dir}/getprog_chisel${chiselruntype}_time.txt
chisel_dir=../chisel/${chiselruntype}/$BENCH/$PROGNAME


if [ ! -d ${debaug_log_dir} ]; then
    mkdir -p ${debaug_log_dir}
fi

cp ${chisel_dir}/log.txt ${debaug_log_f}
