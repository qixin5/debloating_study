#!/bin/bash

progname=$1
inputset=$2
testset=$3
tool=$4
thres=$5   #COVA: [1,100]; RAZOR: [1,4]

echo "Program: ${progname}"
echo "Inputs used for debloating: ${inputset}"
echo "Inputs used for testing debloated program: ${testset}"
echo "Debloating tool: ${tool}"
if [ ! -z ${thres} ]; then
    echo "Augmentation threshold: ${thres}"
fi
echo ""

if [ -z ${progname} ] || [ -z ${inputset} ] || [ -z ${testset} ] || [ -z ${tool} ]; then
    echo "Missing arguments"
    exit 1
fi

if [ ${tool} == "cova" ] || [ ${tool} == "razor" ]; then
    if [ -z ${thres} ]; then
	echo "Missing a threshold value for ${tool}"
	exit 1
    fi
fi

if [ ${tool} == "cova" ]; then
    if [ ${thres} -gt 100 ] || [ ${thres} -lt 1 ]; then
	echo "Invalid ${thres} for ${tool}"
	exit 1
    fi
    
elif [ ${tool} == "razor" ]; then
    if [ ${thres} -gt 4 ] || [ ${thres} -lt 1 ]; then
        echo "Invalid ${thres} for ${tool}"
	exit 1
    fi
fi

if [ ${progname} == "bash-2.05" ] || [ ${progname} == "vim-5.8" ] || [ ${progname} == "make-3.79" ]; then
    if [ ${tool} == "razor" ]; then
	echo "Cannot handle ${progname} with Razor"
	exit 1
    fi
fi


if [ ${tool} == "chisel" ]; then
    progpath=${inputset}_chisel
    
elif [ ${tool} == "debop" ]; then
    progpath=${inputset}_debop
    
elif [ ${tool} == "cov" ]; then
    progpath=${inputset}_cov
    
elif [ ${tool} == "cova" ]; then
    progpath=${inputset}_covfaugrutilfreqflexp${thres}
    
elif [ ${tool} == "covf" ]; then
    progpath=${inputset}_covrdsfuzzchn10
    
elif [ ${tool} == "razor" ]; then
    progpath=${inputset}_covaug${thres}

else
    echo "Unknown tool: ${tool}"
    exit 1
fi


CURRDIR=$(pwd)
covsrcdir=$CURRDIR/../debaug/benchmark/${progname}/src/reduced/${inputset}_cov

echo "Produce debloated program"
if [ ${tool} == "chisel" ]; then

    echo "Note this can take up to 6 hours"
    chisel_run/prepare_for_sirprog.sh benchmark ${progname}
    chisel_run/run_main_sirprog.sh benchmark ${progname} ${inputset}
    chisel_run/cp_chisel_prog_to_debaug.sh benchmark ${progname} ${inputset}

elif [ ${tool} == "debop" ]; then

    echo "Note this can take up to 6 hours"
    if [ ! -f ${covsrcdir}/${progname}.c ]; then
	getprog_sirprog/getprog_cov_main_targettrain.sh benchmark ${progname} ${inputset}
    fi
    debop_run/prepare_for_sirprog.sh benchmark ${progname}
    debop_run/run_main_sirprog.sh benchmark ${progname} ${inputset}
    debop_run/cp_debop_prog_to_debaug_with_dce.sh benchmark ${progname} ${inputset}

elif [ ${tool} == "cov" ]; then

    getprog_sirprog/getprog_cov_main_targettrain.sh benchmark ${progname} ${inputset}

elif [ ${tool} == "cova" ]; then

    if [ ! -f ${covsrcdir}/${progname}.c ]; then
	getprog_sirprog/getprog_cov_main_targettrain.sh benchmark ${progname} ${inputset}
    fi
    getprog_sirprog/getprog_faug_main_targettrain.sh benchmark ${progname} cov ${thres} rutilfreqflex percent ${inputset}

elif [ ${tool} == "covf" ]; then

    if [ ! -f ${covsrcdir}/${progname}.c ]; then
	getprog_sirprog/getprog_cov_main_targettrain.sh benchmark ${progname} ${inputset}
    fi
    getprog_sirprog/getprog_covfuzz_rds_main_targettrain.sh benchmark ${progname} ${inputset} 10 ch 100 true

elif [ ${tool} == "razor" ]; then

    cd ../../tools/razor/scripts_for_sirprog || exit 1
    ./prepare_sirprog.sh ${progname}
    ./train_and_debloat.sh ${progname} ${inputset}
    cd $CURRDIR
fi





echo "Evaluate debloated program in terms of correctness-based generality"
if [ ${tool} == "razor" ]; then

    evalprog_sirprog/evalprog_razor.sh benchmark ${progname} origin ${testset} &> /dev/null
    evalprog_sirprog/evalprog_razor.sh benchmark ${progname} ${progpath} ${testset} &> /dev/null

else
    evalprog_sirprog/evalprog.sh benchmark ${progname} origin ${testset} &> /dev/null
    evalprog_sirprog/evalprog.sh benchmark ${progname} ${progpath} ${testset} &> /dev/null
fi




echo "Evaluate debloated program in terms of robustness-based generality"
if [ ! -d $CURRDIR/../debaug/benchmark/${progname}/rdsfuzz/robust_testing/fuzzedtestscript/${inputset} ]; then

    if [ ${progname} == "bash-2.05" ] || [ ${progname} == "vim-5.8" ]; then
	rdsfuzz_sirprog/create_fuzzed_testscript_for_bash_vim.sh benchmark ${progname} ${inputset} 100 robust-testing 50 &> /dev/null
    else
       rdsfuzz_reliability_test_sirprog/create_fuzzed_testscript_main.sh benchmark ${progname} ${inputset} 50 100 robust-testing &> /dev/null
    fi
fi

ROBUST_TEST_SCRIPT=rdsfuzz_reliability_test_sirprog/run.sh
if [ ${progname} == "bash-2.05" ] || [ ${progname} == "vim-5.8" ]; then
    ROBUST_TEST_SCRIPT=rdsfuzz_reliability_test_sirprog/run_for_bash_vim.sh
fi
if [ ${tool} == "razor" ]; then
    ROBUST_TEST_SCRIPT=rdsfuzz_reliability_test_sirprog/run_razor.sh
fi

${ROBUST_TEST_SCRIPT} benchmark ${progname} ${progpath} ${inputset} robust-testing &> /dev/null



echo ""
echo "CGen-Related Scores"
echo "Tool RelCGen AllCGen SRed MRed ARed RelSF RelMF RelAF AllSF AllMF AllAF"
if [ ${tool} == "razor" ]; then

    line=`showrslt_sirprog/showrsltsummary_inrgf_razor_main_foroneinputset.sh benchmark ${progname} ${progpath} byte0 1 ${testset}`
    mred=`echo ${line} | cut -d' ' -f2`
    relcgen=`echo ${line} | cut -d' ' -f3`
    relmf=`echo ${line} | cut -d' ' -f4`
    allcgen=`echo ${line} | cut -d' ' -f5`
    allmf=`echo ${line} | cut -d' ' -f6`

    line=`showrslt_sirprog/showrsltsummary_inrgf_razor_main_foroneinputset.sh benchmark ${progname} ${progpath} gdt0 1 ${testset}`
    ared=`echo ${line} | cut -d' ' -f2`
    relaf=`echo ${line} | cut -d' ' -f4`
    allaf=`echo ${line} | cut -d' ' -f6`

    sred="-"
    relsf="-"
    allsf="-"
    
else

    line=`showrslt_sirprog/showrsltsummary_inrgf_main_foroneinputset.sh benchmark ${progname} ${progpath} stmt 1 ${testset}`
    sred=`echo ${line} | cut -d' ' -f2`
    relcgen=`echo ${line} | cut -d' ' -f3`
    relsf=`echo ${line} | cut -d' ' -f4`
    allcgen=`echo ${line} | cut -d' ' -f5`
    allsf=`echo ${line} | cut -d' ' -f6`

    line=`showrslt_sirprog/showrsltsummary_inrgf_main_foroneinputset.sh benchmark ${progname} ${progpath} byte0 1 ${testset}`
    mred=`echo ${line} | cut -d' ' -f2`
    relmf=`echo ${line} | cut -d' ' -f4`
    allmf=`echo ${line} | cut -d' ' -f6`

    line=`showrslt_sirprog/showrsltsummary_inrgf_main_foroneinputset.sh benchmark ${progname} ${progpath} gdt0 1 ${testset}`
    ared=`echo ${line} | cut -d' ' -f2`
    relaf=`echo ${line} | cut -d' ' -f4`
    allaf=`echo ${line} | cut -d' ' -f6`

fi

echo "${tool} ${relcgen} ${allcgen} ${sred} ${mred} ${ared} ${relsf} ${relmf} ${relaf} ${allsf} ${allmf} ${allaf}"

echo ""
echo "RGen-Related Scores"
echo "Tool RGen SRed MRed ARed RelSF SF MF AF"
if [ ${tool} == "razor" ]; then

    line=`rdsfuzz_reliability_test_sirprog/check_rslt.sh benchmark ${progname} ${progpath} ${inputset} true`
    rgen=`echo ${line} | cut -d' ' -f2`
    sf="-"
    mf=`echo "scale=3; 2*${mred}*${rgen} / (${mred} + ${rgen})" | bc -l`
    af=`echo "scale=3; 2*${ared}*${rgen} / (${ared} + ${rgen})" | bc -l`    
    
else

    line=`rdsfuzz_reliability_test_sirprog/check_rslt.sh benchmark ${progname} ${progpath} ${inputset}`
    rgen=`echo ${line} | cut -d' ' -f2`
    sf=`echo "scale=3; 2*${sred}*${rgen} / (${sred} + ${rgen})" | bc -l`
    mf=`echo "scale=3; 2*${mred}*${rgen} / (${mred} + ${rgen})" | bc -l`
    af=`echo "scale=3; 2*${ared}*${rgen} / (${ared} + ${rgen})" | bc -l`
    
fi

echo "${tool} ${rgen} ${sred} ${mred} ${ared} ${sf} ${mf} ${af}"
