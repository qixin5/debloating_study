#!/bin/bash

BENCH=$1
PROGNAME=$2
inputset=$3
DEBDCE_BIN=${DEBAUG_DIR}/bin/debdce

if [ -z $BENCH ] || [ -z $PROGNAME ] || [ -z ${inputset} ]; then
    echo "Missing arguments!"
    exit 1
fi


debaug_dir=../debaug/$BENCH/$PROGNAME
debop_dir=../debop/$BENCH/$PROGNAME
outdir_suffix=cov.s1000.a0.5.b0.5.k50.gf1.v0
debop_out_dir=${debop_dir}/debop-out.${inputset}.${outdir_suffix}


bestsid=`grep "Current Best Sample Id:" ${debop_out_dir}/log.txt | tail -1 | cut -d' ' -f9`

if [ -z ${bestsid} ]; then
    echo "Failed to get the best sample id from ${debop_out_dir}."
    exit 1
fi


if [ ${bestsid} == "-1" ]; then
    debop_rsltf=${debop_dir}/cov/${inputset}.c #Change if cov is not used (as initial program)
else
    debop_rsltf=${debop_out_dir}/$PROGNAME.c.sample${bestsid}.c
fi

if [ -f ${debop_rsltf} ]; then
    rslt_dir=${debaug_dir}/src/reduced/${inputset}_debop

    if [ ! -d ${rslt_dir} ]; then
	mkdir -p ${rslt_dir}
    else
	rm -fr ${rslt_dir}/*
    fi

    #Copy result code
    cp ${debop_rsltf} ${rslt_dir}/$PROGNAME.nodce.c

    #Remove dead code
    ${DEBDCE_BIN} ${rslt_dir}/$PROGNAME.nodce.c ${rslt_dir}/$PROGNAME.c

else
    echo "Missing ${debop_rsltf}."
fi
