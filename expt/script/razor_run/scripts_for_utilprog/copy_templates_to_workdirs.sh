#!/bin/bash

BENCH=$1
PROGNAME=$2

if [ -z $BENCH ] || [ -z $PROGNAME ]; then
    echo "Missing arguments!"
    exit 1
fi


work_dir=../benchmarks/core-utilities/$PROGNAME
template_dir=../benchmarks/core-utilities/${PROGNAME}_template

if [ -d ${work_dir} ]; then
    rm -fr ${work_dir}
fi

cp -r ${template_dir} ${work_dir}
