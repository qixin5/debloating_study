#!/bin/bash

progname=$1
tool=$2
thres=$3   #COVA: [1,100]; RAZOR: [1,4]

echo "Program: ${progname}"
echo "Debloating tool: ${tool}"
if [ ! -z ${thres} ]; then
    echo "Augmentation threshold: ${thres}"
fi
echo ""

if [ -z ${progname} ] || [ -z ${tool} ]; then
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


if [ ${tool} == "chisel" ]; then
    progid=chisel
    
elif [ ${tool} == "debop" ]; then
    progid=debop
    
elif [ ${tool} == "cov" ]; then
    progid=cov
    
elif [ ${tool} == "cova" ]; then
    progid=covfaugrutilfreqflexp${thres}
    
elif [ ${tool} == "covf" ]; then
    progid=covrdsfuzzchn10
    
elif [ ${tool} == "razor" ]; then
    progid=covaug${thres}

else
    echo "Unknown tool: ${tool}"
    exit 1
fi


CURRDIR=$(pwd)
covsrcdir=$CURRDIR/../debaug/benchmark/${progname}/src/reduced/I0_cov

echo "Produce debloated program"
if [ ${tool} == "chisel" ]; then

    echo "Note this can take up to 60 hours (6 hours for each set of inputs)"
    chisel_run/prepare_for_utilprog.sh benchmark ${progname}
    chisel_run/run_main_utilprog.sh benchmark ${progname}
    chisel_run/cp_chisel_prog_to_debaug_forallinputsets.sh benchmark ${progname}

elif [ ${tool} == "debop" ]; then

    echo "Note this can take up to 60 hours (6 hours for each set of inputs)"

    if [ ! -f ${covsrcdir}/${progname}.c ]; then
	getprog_utilprog/getprog_cov_main_forallinputsets.sh benchmark ${progname}
    fi
    
    debop_run/prepare_for_utilprog.sh benchmark ${progname}
    debop_run/run_main_utilprog.sh benchmark ${progname}
    debop_run/cp_debop_prog_to_debaug_with_dce_forallinputsets.sh benchmark ${progname}

elif [ ${tool} == "cov" ]; then

    getprog_utilprog/getprog_cov_main_forallinputsets.sh benchmark ${progname}

elif [ ${tool} == "cova" ]; then
    
    if [ ! -f ${covsrcdir}/${progname}.c ]; then
        getprog_utilprog/getprog_cov_main_forallinputsets.sh benchmark ${progname}
    fi
    
    getprog_faug_main_forallinputsets.sh benchmark ${progname} cov ${thres} rutilfreqflex percent

elif [ ${tool} == "covf" ]; then

    if [ ! -f ${covsrcdir}/${progname}.c ]; then
        getprog_utilprog/getprog_cov_main_forallinputsets.sh benchmark ${progname}
    fi

    getprog_utilprog/getprog_covfuzz_rds_main_forallinputsets.sh benchmark ${progname} 10 ch 100 true

elif [ ${tool} == "razor" ]; then

    cd ../../tools/razor/scripts_for_utilprog || exit 1
    ./clean.sh benchmark ${progname}

    #Copy testscript/I[0-9].py    
    if [ ! -d ../benchmarks/core-utilities/${progname}/testscript ]; then
	cp -r testscript/${progname}/testscript ../benchmarks/core-utilities/${progname}/
    fi

    #Copy input.origin
    if [ ! -d ../benchmarks/core-utilities/${progname}/input.origin ]; then
	if [ -d ${DEBSTUDY_DIR}/expt/debaug/benchmark/${progname}/input.origin ]; then
	    cp -r ${DEBSTUDY_DIR}/expt/debaug/benchmark/${progname}/input.origin ../benchmarks/core-utilities/${progname}/
	fi
    fi
    
    ./getprog_covaug_and_copy_rslt_main_forallinputsets.sh benchmark ${progname} ${thres}

    if [ ! -f ../debaug/benchmark/${progname}/razor_code/origin/${progname} ]; then
	./copy_origin_prog.sh benchmark ${progname}
    fi
    
    cd $CURRDIR
fi




echo "Evaluate debloated program in terms of correctness-based generality"
if [ ${tool} == "razor" ]; then

    evalprog_utilprog/evalprog_razor_main_forallinputsets.sh benchmark ${progname} origin
    evalprog_utilprog/evalprog_razor_main_forallinputsets.sh benchmark ${progname} ${progid}

else

    evalprog_utilprog/evalprog_main_forallinputsets.sh benchmark ${progname} origin
    evalprog_utilprog/evalprog_main_forallinputsets.sh benchmark ${progname} ${progid}

fi




echo "Evaluate debloated program in terms of robustness-based generality"
if [ ! -d $CURRDIR/../debaug/benchmark/${progname}/rdsfuzz/robust_testing/fuzzedtestscript ]; then
    rdsfuzz_utilprog/create_fuzzed_testscript_forallinputsets.sh benchmark ${progname} 100 robust-testing
fi

#The inputset used in our experiment for robustness testing
if [ ${progname} == "bzip2-1.0.5" ]; then
    selected_inputset=I9
    
elif [ ${progname} == "chown-8.2" ]; then
    selected_inputset=I5
    
elif [ ${progname} == "date-8.21" ]; then
    selected_inputset=I6
    
elif [ ${progname} == "grep-2.19" ]; then
    selected_inputset=I4
    
elif [ ${progname} == "gzip-1.2.4" ]; then
    selected_inputset=I7
    
elif [ ${progname} == "mkdir-5.2.1" ]; then
    selected_inputset=I8
    
elif [ ${progname} == "rm-8.4" ]; then
    selected_inputset=I0
    
elif [ ${progname} == "sort-8.16" ]; then
    selected_inputset=I6
    
elif [ ${progname} == "tar-1.14" ]; then
    selected_inputset=I4
    
elif [ ${progname} == "uniq-8.16" ]; then
    selected_inputset=I5
fi

ROBUST_TEST_SCRIPT=rdsfuzz_reliability_test_utilprog/run.sh
if [ ${tool} == "razor" ]; then
    ROBUST_TEST_SCRIPT=rdsfuzz_reliability_test_utilprog/run_razor.sh
fi

${ROBUST_TEST_SCRIPT} benchmark ${progname} ${selected_inputset}_${progid} ${selected_inputset} robust-testing &> /dev/null



echo ""
echo "CGen-Related Scores"
echo "Tool RelCGen AllCGen SRed MRed ARed RelSF RelMF RelAF AllSF AllMF AllAF"
if [ ${tool} == "razor" ]; then

    line=`showrslt_utilprog/showrsltsummary_inrgf_razor_main.sh benchmark ${progname} ${progid} byte0 1`
    mred=`echo ${line} | cut -d' ' -f2`
    relcgen=`echo ${line} | cut -d' ' -f3`
    relmf=`echo ${line} | cut -d' ' -f4`
    allcgen=`echo ${line} | cut -d' ' -f5`
    allmf=`echo ${line} | cut -d' ' -f6`

    line=`showrslt_utilprog/showrsltsummary_inrgf_razor_main.sh benchmark ${progname} ${progid} byte0 1`
    ared=`echo ${line} | cut -d' ' -f2`
    relaf=`echo ${line} | cut -d' ' -f4`
    allaf=`echo ${line} | cut -d' ' -f6`

    sred="-"
    relsf="-"
    allsf="-"
    
else

    line=`showrslt_utilprog/showrsltsummary_inrgf_main.sh benchmark ${progname} ${progid} stmt 1`
    sred=`echo ${line} | cut -d' ' -f2`
    relcgen=`echo ${line} | cut -d' ' -f3`
    relsf=`echo ${line} | cut -d' ' -f4`
    allcgen=`echo ${line} | cut -d' ' -f5`
    allsf=`echo ${line} | cut -d' ' -f6`

    line=`showrslt_utilprog/showrsltsummary_inrgf_main.sh benchmark ${progname} ${progid} byte0 1`
    mred=`echo ${line} | cut -d' ' -f2`
    relmf=`echo ${line} | cut -d' ' -f4`
    allmf=`echo ${line} | cut -d' ' -f6`

    line=`showrslt_utilprog/showrsltsummary_inrgf_main.sh benchmark ${progname} ${progid} gdt0 1`
    ared=`echo ${line} | cut -d' ' -f2`
    relaf=`echo ${line} | cut -d' ' -f4`
    allaf=`echo ${line} | cut -d' ' -f6`

fi

echo "${tool} ${relcgen} ${allcgen} ${sred} ${mred} ${ared} ${relsf} ${relmf} ${relaf} ${allsf} ${allmf} ${allaf}"

echo ""
echo "RGen-Related Scores"
echo "Tool RGen SRed MRed ARed RelSF SF MF AF"
if [ ${tool} == "razor" ]; then

    line=`rdsfuzz_reliability_test_utilprog/check_rslt.sh benchmark ${progname} ${selected_inputset}_${progid} ${selected_inputset} true`
    rgen=`echo ${line} | cut -d' ' -f2`
    sf="-"
    mf=`echo "scale=3; 2*${mred}*${rgen} / (${mred} + ${rgen})" | bc -l`
    af=`echo "scale=3; 2*${ared}*${rgen} / (${ared} + ${rgen})" | bc -l`    
    
else

    line=`rdsfuzz_reliability_test_utilprog/check_rslt.sh benchmark ${progname} ${selected_inputset}_${progid} ${selected_inputset}`
    rgen=`echo ${line} | cut -d' ' -f2`
    sf=`echo "scale=3; 2*${sred}*${rgen} / (${sred} + ${rgen})" | bc -l`
    mf=`echo "scale=3; 2*${mred}*${rgen} / (${mred} + ${rgen})" | bc -l`
    af=`echo "scale=3; 2*${ared}*${rgen} / (${ared} + ${rgen})" | bc -l`
    
fi

echo "${tool} ${rgen} ${sred} ${mred} ${ared} ${sf} ${mf} ${af}"
