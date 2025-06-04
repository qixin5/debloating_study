#!/bin/bash

SRC=$1
BIN=$2
flags=$3

if [ -z $4 ]; then
    COMPILER=clang #Default
else
    COMPILER=$4
fi

# libglob_path=/home/qxin6/debaug_expt/debaug/benchmark/make-3.79_template/lib/libglob.a
# libglob_path=lib/libglob.a

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
$COMPILER ${flags} -w -o $BIN $SRC -L $SCRIPT_DIR/lib -lutil
