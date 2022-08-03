#!/bin/bash

SRC=$1
BIN=$2
flags=$3

if [ -z $4 ]; then
    COMPILER=clang #Default
else
    COMPILER=$4
fi

$COMPILER ${flags} -w -D '__msan_unpoison(s,z)' -o $BIN $SRC -lpcre
