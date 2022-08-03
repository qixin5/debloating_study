#!/bin/bash

BENCH=$1
PROGNAME=$2
LINEGEN_BIN=${DEBAUG_DIR}/bin/startandendlineprinter

if [ -z $BENCH ] || [ -z $PROGNAME ]; then
    echo "Missing arguments."
    exit 1
fi

cd ../debaug/$BENCH/$PROGNAME || exit 1

if [ ! -f line.txt ]; then
    ${LINEGEN_BIN} src/origin/$PROGNAME.c >line.txt
    if [ -d debop-out ]; then
	rm -fr debop-out
    fi
fi
