#!/bin/bash

BENCH=$1
PROGNAME=$2

SCRIPTDIR=$(pwd)


if [ -z $BENCH ] || [ -z $PROGNAME ]; then
    echo "Missing arguments!"
    exit 1
fi

#Get into the working dir
cd $SCRIPTDIR/../chisel/$BENCH/$PROGNAME || exit 1


#Cleanup
rm -fr chisel_out
rm -fr $PROGNAME
rm -fr ${PROGNAME}.c
rm -fr input
rm -fr *.txt
rm -fr output
rm -fr output.origin
rm -fr test*.sh
rm -fr run_chisel_*.sh
rm -fr tmp/*


#Copy scripts
cp $SCRIPTDIR/chisel_run/script_used_by_chisel/run_chisel_main_utilprog.sh ./run_chisel_main.sh
cp $SCRIPTDIR/chisel_run/script_used_by_chisel/testcore.sh ./


#Run Chisel
./run_chisel_main.sh $PROGNAME

