#!/bin/bash

BENCH=$1
PROGNAME=$2
debopruntype=$3

if [ -z $BENCH ] || [ -z $PROGNAME ] || [ -z ${debopruntype} ]; then
    echo "Missing arguments!"
    exit 1
fi


debaug_log_dir=../debaug/log/$BENCH/$PROGNAME
debaug_log_f=${debaug_log_dir}/getprog_debop${debopruntype}_time.txt
debop_dir=../debop/${debopruntype}/$BENCH/$PROGNAME


if [ ! -d ${debaug_log_dir} ]; then
    mkdir -p ${debaug_log_dir}
fi

cp ${debop_dir}/log/time.txt ${debaug_log_f}
