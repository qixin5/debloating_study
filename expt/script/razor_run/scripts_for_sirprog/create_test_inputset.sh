#!/bin/bash

progname=$1

if [ -z ${progname} ]; then
    echo "Missing arguments."
    exit 1
fi

cd ../benchmarks/core-utilities/${progname} || exit 1

if [ -d testscript/test ]; then
    rm -fr testscript/test/*
else
    mkdir testscript/test
fi

cp testscript/all/0 testscript/test/
