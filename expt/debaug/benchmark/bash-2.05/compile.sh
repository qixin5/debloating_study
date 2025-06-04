#!/bin/bash

SRC=$1
BIN=$2
flags=$3

flags="${flags} -L $DEBSTUDY_DIR/expt/debaug/benchmark/bash-2.05/lib"

if [ -z $4 ]; then
    COMPILER=clang #Default
else
    COMPILER=$4
fi


$COMPILER ${flags} -w -o $BIN $SRC -lbuiltins -lsh -lreadline -lhistory -ltermcap -lglob -ltilde -lmalloc  -ldl
