#!/bin/bash

BENCH=benchmark
PROGNAME=tcas
inputset=n10train
testset=n10test


CURRDIR=$(pwd)


echo "Produce debloated program by Chisel (estimated time: less than 2 minutes)"
chisel_run/prepare_for_sirprog.sh $BENCH $PROGNAME &> /dev/null
chisel_run/run_main_sirprog.sh $BENCH $PROGNAME ${inputset} &> /dev/null
chisel_run/cp_chisel_prog_to_debaug.sh $BENCH $PROGNAME ${inputset} &> /dev/null


echo "Produce debloated program by Cov (estimated time: less than 1 minute)"
getprog_sirprog/getprog_cov_main.sh $BENCH $PROGNAME ${inputset} &> /dev/null


echo "Produce debloated program by Debop (estimated time: less than 1 minute for demo only)"
debop_run/prepare_for_sirprog.sh $BENCH $PROGNAME &> /dev/null
debop_run/run_main_sirprog_short.sh $BENCH $PROGNAME ${inputset} &> /dev/null
debop_run/cp_debop_prog_to_debaug_with_dce.sh $BENCH $PROGNAME ${inputset} &> /dev/null


echo "Produce debloted program by CovA (estimated time: a few seconds)"
getprog_sirprog/getprog_faug_main_targettrain.sh $BENCH $PROGNAME cov 20 rutilfreqflex percent ${inputset} &> /dev/null


echo "Produce debloated program by CovF (estimated time: about 3 minute)"
getprog_sirprog/getprog_covfuzz_rds_main_targettrain.sh $BENCH $PROGNAME ${inputset} 30 ch 100 true &> /dev/null


echo "Produce debloated program by Razor (estimated time: less than 1 minute)"
cd ../../tools/razor/scripts_for_sirprog
./prepare_sirprog.sh $PROGNAME &> /dev/null
./train_and_debloat.sh $PROGNAME ${inputset} &> /dev/null
cd $CURRDIR

