#!/bin/bash

BENCH=$1
PROGNAME=$2


if [ -z $BENCH ] || [ -z $PROGNAME ]; then
    echo "Missing arguments!"
    exit 1
fi

if [ $PROGNAME == "bzip2-1.0.5" ]; then
    progabbr=bzip2
elif [ $PROGNAME == "chown-8.2" ]; then
    progabbr=chown
elif [ $PROGNAME == "date-8.21" ]; then
    progabbr=date
elif [ $PROGNAME == "grep-2.19" ]; then
    progabbr=grep
elif [ $PROGNAME == "gzip-1.2.4" ]; then
    progabbr=gzip
elif [ $PROGNAME == "mkdir-5.2.1" ]; then
    progabbr=mkdir
elif [ $PROGNAME == "rm-8.4" ]; then
    progabbr=rm
elif [ $PROGNAME == "sort-8.16" ]; then
    progabbr=sort
elif [ $PROGNAME == "tar-1.14" ]; then
    progabbr=tar
elif [ $PROGNAME == "uniq-8.16" ]; then
    progabbr=uniq
else
    echo "Unknown $PROGNAME."
    exit 1
fi


cd ../benchmarks/core-utilities/$PROGNAME || exit 1



rm -fr *.txt
rm -fr *.log
rm -fr *.s
rm -fr *.asm
rm -fr logs
rm -fr *.c
rm -fr train
rm -fr test
rm -fr ${progabbr}.orig_temp
