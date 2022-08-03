#!/bin/bash

BENCH=benchmark
PROGNAME=tcas
inputset=n10train
testset=n10test


echo "Tool Program RGen"

rsltline=`rdsfuzz_reliability_test_sirprog/check_rslt.sh $BENCH $PROGNAME ${inputset}_chisel ${inputset}`
echo "chisel ${rsltline}"

rsltline=`rdsfuzz_reliability_test_sirprog/check_rslt.sh $BENCH $PROGNAME ${inputset}_cov ${inputset}`
echo "cov ${rsltline}"


rsltline=`rdsfuzz_reliability_test_sirprog/check_rslt.sh $BENCH $PROGNAME ${inputset}_debop ${inputset}`
echo "debop ${rsltline}"

rsltline=`rdsfuzz_reliability_test_sirprog/check_rslt.sh $BENCH $PROGNAME ${inputset}_covfaugrutilfreqflexp20 ${inputset}`
echo "cova ${rsltline}"

rsltline=`rdsfuzz_reliability_test_sirprog/check_rslt.sh $BENCH $PROGNAME ${inputset}_covrdsfuzzchn30 ${inputset}`
echo "covf ${rsltline}"

rsltline=`rdsfuzz_reliability_test_sirprog/check_rslt.sh $BENCH $PROGNAME ${inputset}_covaug4 ${inputset} true`
echo "razor ${rsltline}"
