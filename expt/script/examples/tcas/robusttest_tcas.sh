#!/bin/bash

BENCH=benchmark
PROGNAME=tcas
inputset=n10train
testset=n10test


if [ -z $BENCH ] || [ -z $PROGNAME ] || [ -z ${inputset} ] || [ -z ${testset} ]; then
    echo "Missing arguments."
    exit 1
fi

echo "Generate fuzzed inputs"
rdsfuzz_reliability_test_sirprog/create_fuzzed_testscript_main.sh $BENCH $PROGNAME ${inputset} 50 100 robust-testing &> /dev/null


echo "Test debloated program made by Chisel"
rdsfuzz_reliability_test_sirprog/run.sh $BENCH $PROGNAME ${inputset}_chisel ${inputset} robust-testing &> /dev/null

echo "Test debloated program made by Cov"
rdsfuzz_reliability_test_sirprog/run.sh $BENCH $PROGNAME ${inputset}_cov ${inputset} robust-testing &> /dev/null


echo "Test debloated program made by Debop"
rdsfuzz_reliability_test_sirprog/run.sh $BENCH $PROGNAME ${inputset}_debop ${inputset} robust-testing &> /dev/null

echo "Test debloated program made by CovA"
rdsfuzz_reliability_test_sirprog/run.sh $BENCH $PROGNAME ${inputset}_covfaugrutilfreqflexp20 ${inputset} robust-testing &> /dev/null

echo "Test debloated program made by CovF"
rdsfuzz_reliability_test_sirprog/run.sh $BENCH $PROGNAME ${inputset}_covrdsfuzzchn30 ${inputset} robust-testing &> /dev/null

echo "Test debloated program made by Razor"
rdsfuzz_reliability_test_sirprog/run_razor.sh $BENCH $PROGNAME ${inputset}_covaug4 ${inputset} robust-testing &> /dev/null

