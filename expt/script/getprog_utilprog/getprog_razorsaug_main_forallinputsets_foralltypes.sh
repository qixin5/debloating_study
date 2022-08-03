#!/bin/bash

BENCH=$1
PROGNAME=$2

if [ -z $BENCH ] || [ -z $PROGNAME ]; then
    echo "Missing arguments."
    exit 1
fi

for augtype in zcall zlib; do
    getprog_utilprog/getprog_razorsaug_main_forallinputsets.sh $BENCH $PROGNAME ${augtype}
done

