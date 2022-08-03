#!/bin/bash

progname=$1

if [ -z ${progname} ]; then
    echo "Missing arguments."
    exit 1
fi

source_dir=/home/qxin6/debaug_expt_razor/benchmark/${progname}_template
target_dir=../benchmarks/core-utilities/${progname}

if [ -d ${target_dir} ]; then
    rm -fr ${target_dir}
fi

cp -r ${source_dir} ${target_dir}
