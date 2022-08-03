#!/bin/bash

BENCH=benchmark
PROGNAME=tcas
inputset=n10train
testset=n10test


CURRDIR=$(pwd)


echo "Produce debloated program by Razor (estimated time: less than 1 minute)"
cd ../../tools/razor/scripts_for_sirprog
./prepare_sirprog.sh $PROGNAME
./train_and_debloat.sh $PROGNAME ${inputset}
cd $CURRDIR


echo "Test debloated program made by Razor"
evalprog_sirprog/evalprog_razor.sh $BENCH $PROGNAME origin ${testset}
evalprog_sirprog/evalprog_razor.sh $BENCH $PROGNAME ${inputset}_covaug2 ${testset}



showrslt_sirprog/showrsltsummary_inrgf_razor_main_foroneinputset.sh $BENCH $PROGNAME ${inputset}_covaug2 byte0 1 ${testset}
