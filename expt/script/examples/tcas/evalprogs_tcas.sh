#!/bin/bash

BENCH=benchmark
PROGNAME=tcas
inputset=n10train
testset=n10test


echo "Test original program"
evalprog_sirprog/evalprog.sh $BENCH $PROGNAME origin ${testset} &> /dev/null

echo "Test debloated program made by Chisel"
evalprog_sirprog/evalprog.sh $BENCH $PROGNAME ${inputset}_chisel ${testset} &> /dev/null

echo "Test debloated program made by Cov"
evalprog_sirprog/evalprog.sh $BENCH $PROGNAME ${inputset}_cov ${testset} &> /dev/null

echo "Test debloated program made by Debop"
evalprog_sirprog/evalprog.sh $BENCH $PROGNAME ${inputset}_debop ${testset} &> /dev/null

echo "Test debloated program made by CovA"
evalprog_sirprog/evalprog.sh $BENCH $PROGNAME ${inputset}_covfaugrutilfreqflexp20 ${testset} &> /dev/null

echo "Test debloated program made by CovF"
evalprog_sirprog/evalprog.sh $BENCH $PROGNAME ${inputset}_covrdsfuzzchn30 ${testset} &> /dev/null

echo "Test debloated program made by Razor"
evalprog_sirprog/evalprog_razor.sh $BENCH $PROGNAME origin ${testset} &> /dev/null
evalprog_sirprog/evalprog_razor.sh $BENCH $PROGNAME ${inputset}_covaug4 ${testset} &> /dev/null
