#!/bin/bash

progname=$1

if [ -z ${progname} ]; then
    echo "Missing arguments."
    exit 1
fi

source_dir0=${DEBSTUDY_DIR}/expt/debaug/benchmark/${progname}
target_dir=../benchmarks/core-utilities/${progname}

if [ ! -d ${source_dir0} ]; then
    echo "Directory doesn't exist: ${source_dir0}"
    exit 1
fi

if [ -d ${target_dir} ]; then
    rm -fr ${target_dir}
fi

mkdir ${target_dir} || exit 1



cp ${source_dir0}/src/origin/${progname}.c ${target_dir}/

cp ${source_dir0}/compile.sh ${target_dir}/

if [ -d ${target_dir}/testscript ]; then
    rm -fr ${target_dir}/testscript
fi

cp -r ${source_dir0}/testscript ${target_dir}/

