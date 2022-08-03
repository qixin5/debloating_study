#!/bin/bash

progname=$1

if [ -z ${progname} ]; then
    echo "Missing arguments."
    exit 1
fi

target_dir=../benchmarks/core-utilities/${progname}


for fd in ${target_dir}/*; do
    fdname=$(basename ${fd})
    if [ ${fdname} == "compile.sh" ] || [ ${fdname} == "${progname}.c" ] || [ ${fdname} == "testscript" ]; then
	continue
    else
	rm -fr ${fd}
    fi
done
