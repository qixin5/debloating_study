#!/bin/bash

BENCH=$1
PROGNAME=$2
cov_dir=$3       #Directory containing llvm-cov coverage files (transformed into gcc format)
gcc_cov_dir=$4   #Directory containing gcc coverage files


if [ -z $BENCH ] || [ -z $PROGNAME ] || [ -z ${cov_dir} ] || [ -z ${gcc_cov_dir} ]; then
    echo "Missing arguments!"
    exit 1
fi

cd ../debaug/$BENCH/$PROGNAME || exit 1


FIXER_BIN=${DEBAUG_DIR}/bin/llvmgcovfixer

cd gcov

if [ ! -d ${gcc_cov_dir} ]; then
    echo "No gcc cov results available."
    exit 1
fi

for covf in ${cov_dir}/*; do
    covfname=$(basename ${covf})
    
    if [ -f ${gcc_cov_dir}/${covfname} ]; then
	${FIXER_BIN} ${covf} ${gcc_cov_dir}/${covfname}
    fi
done



