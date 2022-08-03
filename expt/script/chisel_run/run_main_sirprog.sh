#!/bin/bash

BENCH=$1
PROGNAME=$2
inputset=$3

SCRIPTDIR=$(pwd)

if [ -z $BENCH ] || [ -z $PROGNAME ] || [ -z ${inputset} ]; then
    echo "Missing arguments!"
    exit 1
fi

#Get into the working dir
cd $SCRIPTDIR/../chisel/$BENCH/$PROGNAME || exit 1

while true; do

    #Cleanup
    rm -fr chisel_out/${inputset}
    rm -fr $PROGNAME
    rm -fr ${PROGNAME}.c
    rm -fr input
    rm -fr log_${inputset}.txt
    rm -fr output/${inputset}
    rm -fr output.origin/${inputset}
    rm -fr test*.sh
    rm -fr run_chisel_*.sh
    rm -fr tmp/*


    #Copy scripts
    cp $SCRIPTDIR/chisel_run/script_used_by_chisel/run_chisel_main_sirprog.sh ./run_chisel_main.sh
    cp $SCRIPTDIR/chisel_run/script_used_by_chisel/testcore.sh ./


    #Run Chisel
    ./run_chisel_main.sh $PROGNAME ${inputset}


    #Keep runnning if failed
    if [ -f chisel_out/${inputset}/log.txt ]; then
	break
    fi
done
