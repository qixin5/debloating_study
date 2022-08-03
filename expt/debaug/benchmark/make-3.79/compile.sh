#!/bin/bash

SRC=$1
BIN=$2
flags=$3

if [ -z $4 ]; then
    COMPILER=clang #Default
else
    COMPILER=$4
fi

libglob_path=/home/qxin6/debaug_expt/debaug/benchmark/make-3.79_template/lib/libglob.a

$COMPILER ${flags} -w -o $BIN $SRC ${libglob_path} -lutil
