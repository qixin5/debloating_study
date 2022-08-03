#!/bin/bash

PROGNAME=$1

if [ -z $PROGNAME ]; then
    echo "Missing arguments."
    exit 1
fi

progabbr=`echo $PROGNAME | cut -d'-' -f1`
source_dir=/root/workspace/razor/benchmarks/core-utilities/$PROGNAME
target_dir=${DEBSTUDY_DIR}/expt/debaug/benchmark/$PROGNAME

target_dir0=${target_dir}/razor_code/origin
target_dir1=${target_dir}/razor_code/reduced/p0.1train_cov

if [ ! -d ${target_dir0} ]; then
    mkdir -p ${target_dir0}
fi
if [ ! -d ${target_dir1} ]; then
    mkdir -p ${target_dir1}
fi


#Copy original program
cp ${source_dir}/${progabbr}.orig ${target_dir0}/$PROGNAME

#Copy debloated program
cp ${source_dir}/${progabbr}.orig_temp/${progabbr}.orig.debloated ${target_dir1}/$PROGNAME
