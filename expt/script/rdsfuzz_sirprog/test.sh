#!/bin/bash

#Currently only support BASH-2.05 and VIM-5.8

BENCH=$1
PROGNAME=$2
inputset=$3
fuzznum=2       #For every input
MAXINPUTNUM=2  #Select at most MAXINPUTNUM inputs for fuzzing

fuzzor=${DEBAUG_DIR}/bin/radamsafuzz.sh
bashfuzzscript=${DEBSTUDY_DIR}/expt/script/rdsfuzz_sirprog/fuzzscript_used_by_bash/fuzzscript.sh


if [ -z $BENCH ] || [ -z $PROGNAME ] || [ -z ${inputset} ] || [ -z ${fuzznum} ]; then
    echo "Missing arguments!"
    exit 1
fi

cd ../debaug/$BENCH/$PROGNAME || exit 1

if [ ! -d rdsfuzz ]; then
    mkdir rdsfuzz
fi
cd rdsfuzz


#Must use absolute paths
CURRDIR=$(pwd)
argsdir=$CURRDIR/args/${inputset}
origin_testscript_dir=../testscript/${inputset}


#Directory setup
if [ ! -d ${argsdir} ]; then
    mkdir -p ${argsdir}
else
    rm -fr ${argsdir}/*
fi

if [ ! -d ${origin_testscript_dir} ]; then
    echo "Test script directory does not exist: ${origin_testscript_dir}."
    exit 1
fi


#Select a number of tests to fuzz
> ${argsdir}/all_inputs.txt
for testf in ${origin_testscript_dir}/*; do
    testfname=$(basename ${testf})
    echo ${testfname} >>${argsdir}/all_inputs.txt
done
shuf ${argsdir}/all_inputs.txt | head -n ${MAXINPUTNUM} >${argsdir}/selected_inputs.txt


#Fuzz each input
while IFS= read -r line; do
    inputid=${line}
    
    mkdir ${argsdir}/${inputid}

    #origin_input_dir contains all files to be fuzzed
    if [ $PROGNAME == "bash-2.05" ]; then
	origin_input_dir=${DEBSTUDY_DIR}/expt/debaug/working/bash/testplans.alt/testplans.fine
    elif [ $PROGNAME == "vim-5.8" ]; then
	origin_input_dir=${DEBSTUDY_DIR}/expt/debaug/working/vim/testplans.alt/all_expect_files
    fi

    for (( i=1; i<=${fuzznum}; i++ )); do

	mkdir ${argsdir}/${inputid}/$i  #This dir contains the i-th fuzzed file

	target_line=`grep "$scriptName = " ${origin_testscript_dir}/${inputid}`
	script_name=`echo ${target_line} | cut -d'"' -f2`

	cp ${origin_input_dir}/${script_name} ${argsdir}/${inputid}/$i
	${fuzzor} ${argsdir}/${inputid}/$i

    done
    
done < ${argsdir}/selected_inputs.txt
