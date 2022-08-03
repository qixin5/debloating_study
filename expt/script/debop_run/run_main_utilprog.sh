#!/bin/bash

BENCH=$1
PROGNAME=$2 #No inputset is needed, as it will iterate from I0 to I9

SCRIPTDIR=$(pwd)


if [ -z $BENCH ] || [ -z $PROGNAME ]; then
    echo "Missing arguments!"
    exit 1
fi


cd $SCRIPTDIR/../debop/$BENCH/$PROGNAME || exit 1


#Copy scripts
cp $SCRIPTDIR/debop_run/script_used_by_debop/clean_utilprog.sh ./clean.sh
cp $SCRIPTDIR/debop_run/script_used_by_debop/run_debop_main_utilprog.sh ./run_debop_main.sh
cp $SCRIPTDIR/debop_run/script_used_by_debop/run_debop.sh ./
cp $SCRIPTDIR/debop_run/script_used_by_debop/testcore.sh ./
cp $SCRIPTDIR/debop_run/script_used_by_debop/run_test.sh ./


#Run debop
./run_debop_main.sh $PROGNAME
