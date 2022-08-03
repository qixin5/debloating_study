#!/bin/bash

BENCH=$1
PROGNAME=$2
inputset=$3


if [ -z $BENCH ] || [ -z $PROGNAME ] || [ -z ${inputset} ]; then
    echo "Missing arguments!"
    exit 1
fi

debaug_dir=../debaug/$BENCH/$PROGNAME
chisel_dir=../chisel/$BENCH/$PROGNAME

chisel_out_dir=${chisel_dir}/chisel_out/${inputset}
if [ -f ${chisel_out_dir}/${PROGNAME}.c.chisel.c ]; then
    chisel_rsltfname=${PROGNAME}.c.chisel.c
else
    chisel_rsltfname=`ls -lt ${chisel_out_dir} | grep "success.c" | head -1 | tr -s ' ' | cut -d' ' -f9`
fi


rslt_dir=${debaug_dir}/src/reduced/${inputset}_chisel
if [ ! -d ${rslt_dir} ]; then
    mkdir -p ${rslt_dir}
else
    rm -fr ${rslt_dir}/*
fi

cp ${chisel_out_dir}/${chisel_rsltfname} ${rslt_dir}/$PROGNAME.c
