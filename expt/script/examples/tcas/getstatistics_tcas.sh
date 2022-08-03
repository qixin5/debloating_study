#!/bin/bash

BENCH=benchmark
PROGNAME=tcas
inputset=n10train
testset=n10test

SHOWRSLT_SCRIPT=showrslt_sirprog/showrsltsummary_inrgf_main_foroneinputset.sh
SHOWRSLT_RAZOR_SCRIPT=showrslt_sirprog/showrsltsummary_inrgf_razor_main_foroneinputset.sh
SHOWRSLT_RGEN_SCRIPT=rdsfuzz_reliability_test_sirprog/check_rslt.sh


showrslt () {
    SHOWRSLT_BIN=${SHOWRSLT_SCRIPT}
    
    line=`${SHOWRSLT_BIN} $BENCH $PROGNAME ${inputset}_$1 stmt 1 ${testset}`
    sred=`echo ${line} | cut -d' ' -f2`
    relcgen=`echo ${line} | cut -d' ' -f3`
    relsf=`echo ${line} | cut -d' ' -f4`    
    allcgen=`echo ${line} | cut -d' ' -f5`
    allsf=`echo ${line} | cut -d' ' -f6`

    line=`${SHOWRSLT_BIN} $BENCH $PROGNAME ${inputset}_$1 byte0 1 ${testset}`
    mred=`echo ${line} | cut -d' ' -f2`
    relmf=`echo ${line} | cut -d' ' -f4`
    allmf=`echo ${line} | cut -d' ' -f6`

    line=`${SHOWRSLT_BIN} $BENCH $PROGNAME ${inputset}_$1 gdt0 1 ${testset}`
    ared=`echo ${line} | cut -d' ' -f2`
    relaf=`echo ${line} | cut -d' ' -f4`
    allaf=`echo ${line} | cut -d' ' -f6`

    echo "$2 ${relcgen} ${allcgen} ${sred} ${mred} ${ared} ${relsf} ${relmf} ${relaf} ${allsf} ${allmf} ${allaf}"
}

showrsltrazor () {
    SHOWRSLT_BIN=${SHOWRSLT_RAZOR_SCRIPT}
    
    line=`${SHOWRSLT_BIN} $BENCH $PROGNAME ${inputset}_$1 byte0 1 ${testset}`
    mred=`echo ${line} | cut -d' ' -f2`
    relcgen=`echo ${line} | cut -d' ' -f3`    
    relmf=`echo ${line} | cut -d' ' -f4`
    allcgen=`echo ${line} | cut -d' ' -f5`
    allmf=`echo ${line} | cut -d' ' -f6`

    line=`${SHOWRSLT_BIN} $BENCH $PROGNAME ${inputset}_$1 gdt0 1 ${testset}`
    ared=`echo ${line} | cut -d' ' -f2`
    relaf=`echo ${line} | cut -d' ' -f4`
    allaf=`echo ${line} | cut -d' ' -f6`

    echo "razor ${relcgen} ${allcgen} - ${mred} ${ared} - ${relmf} ${relaf} - ${allmf} ${allaf}"
}

showrslt2 () {
    SHOWRSLT_BIN=${SHOWRSLT_SCRIPT}
    SHOWRSLT_BIN2=${SHOWRSLT_RGEN_SCRIPT}

    line=`${SHOWRSLT_BIN2} $BENCH $PROGNAME ${inputset}_$1 ${inputset}`
    rgen=`echo ${line} | cut -d' ' -f2`
    
    line=`${SHOWRSLT_BIN} $BENCH $PROGNAME ${inputset}_$1 stmt 1 ${testset}`
    sred=`echo ${line} | cut -d' ' -f2`

    line=`${SHOWRSLT_BIN} $BENCH $PROGNAME ${inputset}_$1 byte0 1 ${testset}`
    mred=`echo ${line} | cut -d' ' -f2`

    line=`${SHOWRSLT_BIN} $BENCH $PROGNAME ${inputset}_$1 gdt0 1 ${testset}`
    ared=`echo ${line} | cut -d' ' -f2`

    sf=`echo "scale=3; 2*${sred}*${rgen} / (${sred} + ${rgen})" | bc -l`
    mf=`echo "scale=3; 2*${mred}*${rgen} / (${mred} + ${rgen})" | bc -l`
    af=`echo "scale=3; 2*${ared}*${rgen} / (${ared} + ${rgen})" | bc -l`
    
    echo "$2 ${rgen} ${sred} ${mred} ${ared} ${sf} ${mf} ${af}"
}


showrslt2razor () {
    SHOWRSLT_BIN=${SHOWRSLT_RAZOR_SCRIPT}
    SHOWRSLT_BIN2=${SHOWRSLT_RGEN_SCRIPT}

    line=`${SHOWRSLT_BIN2} $BENCH $PROGNAME ${inputset}_$1 ${inputset} true`
    rgen=`echo ${line} | cut -d' ' -f2`
    
    line=`${SHOWRSLT_BIN} $BENCH $PROGNAME ${inputset}_$1 byte0 1 ${testset}`
    mred=`echo ${line} | cut -d' ' -f2`

    line=`${SHOWRSLT_BIN} $BENCH $PROGNAME ${inputset}_$1 gdt0 1 ${testset}`
    ared=`echo ${line} | cut -d' ' -f2`

    mf=`echo "scale=3; 2*${mred}*${rgen} / (${mred} + ${rgen})" | bc -l`
    af=`echo "scale=3; 2*${ared}*${rgen} / (${ared} + ${rgen})" | bc -l`
    
    echo "razor ${rgen} - ${mred} ${ared} - ${mf} ${af}"
}

echo "Result 1 (CGen-Related Scores)"
echo "Tool RelCGen AllCGen SRed MRed ARed RelSF RelMF RelAF AllSF AllMF AllAF"
showrslt chisel chisel
showrslt debop debop
showrslt cov cov
showrslt covrdsfuzzchn30 covf
showrslt covfaugrutilfreqflexp20 cova
showrsltrazor covaug4


echo ""
echo "Result 2 (RGen-Related Scores)"
echo "Tool RGen SRed MRed ARed RelSF SF MF AF"
showrslt2 chisel chisel
showrslt2 debop debop
showrslt2 cov cov
showrslt2 covrdsfuzzchn30 covf
showrslt2 covfaugrutilfreqflexp20 cova
showrslt2razor covaug4
