#!/bin/bash

SRC=$1
BIN=$2
flags=$3

flags="${flags} -L/home/qxin6/debaug_expt/debaug/benchmark/bash-2.05_template/lib"

if [ -z $4 ]; then
    COMPILER=clang #Default
else
    COMPILER=$4
fi


$COMPILER ${flags} -w -o $BIN $SRC -lbuiltins -lsh -lreadline -lhistory -ltermcap -lglob -ltilde -lmalloc  -ldl
