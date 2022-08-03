#!/bin/bash

BENCH=benchmark
PROGNAME=tcas
inputset=n10train
testset=n10test


CURRDIR=$(pwd)


echo "Produce debloated program by Debop (estimated time: 2 minutes, only for demo)"
debop_run/prepare_for_sirprog.sh $BENCH $PROGNAME
debop_run/run_main_sirprog_short.sh $BENCH $PROGNAME ${inputset}
debop_run/cp_debop_prog_to_debaug_with_dce.sh $BENCH $PROGNAME ${inputset}


#echo "Test original program"
#evalprog_sirprog/evalprog.sh $BENCH $PROGNAME origin ${testset} &> /dev/null

echo "Test debloated program made by Debop"
evalprog_sirprog/evalprog.sh $BENCH $PROGNAME ${inputset}_debop ${testset} &> /dev/null



showrslt_sirprog/showrsltsummary_inrgf_main_foroneinputset.sh $BENCH $PROGNAME ${inputset}_debop stmt 1 ${testset}
