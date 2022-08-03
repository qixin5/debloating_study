#!/bin/bash

SRC=$1
BIN=$2
flags=$3

if [ -z $4 ]; then
    COMPILER=clang #Default
else
    COMPILER=$4
fi

$COMPILER ${flags} -w -o $BIN $SRC
