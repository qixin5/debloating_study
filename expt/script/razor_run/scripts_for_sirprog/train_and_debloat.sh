#!/bin/bash

progname=$1
inputset=$2

if [ -z ${progname} ] || [ -z ${inputset} ]; then
    echo "Missing arguments."
    exit 1
fi

progabbr=`echo ${progname} | cut -d'-' -f1`
SCRIPTDIR=$(pwd)

cd ../benchmarks/core-utilities/${progname} || exit 1



#Set up the working dirs for bash and vim
if [ ${progname} == "bash-2.05" ]; then

    workdir=${DEBSTUDY_DIR}/expt/debaug/working/bash
    razor_workdir=${DEBSTUDY_DIR}/expt/debaug/working/bash_for_razor
    if [ -d ${razor_workdir} ]; then
	rm -fr ${workdir}
	cp -r ${razor_workdir} ${workdir}
    else
	echo "Missing ${razor_workdir}."
	exit 1
    fi

elif [ ${progname} == "vim-5.8" ]; then

    workdir=${DEBSTUDY_DIR}/expt/debaug/working/vim
    razor_workdir=${DEBSTUDY_DIR}/expt/debaug/working/vim_for_razor
    if [ -d ${razor_workdir} ]; then
	rm -fr ${workdir}
	cp -r ${razor_workdir} ${workdir}
    else
        echo "Missing ${razor_workdir}."
        exit 1
    fi
fi



#Copy scripts
cp $SCRIPTDIR/script_used_by_razor/train.sh ./
cp $SCRIPTDIR/script_used_by_razor/run_razor.py ./


#Target dir to save original and debloated code
target_dir=${DEBSTUDY_DIR}/expt/debaug/benchmark/${progname}
target_dir0=${target_dir}/razor_code/origin
target_dir1=${target_dir}/razor_code/reduced/${inputset}_cov
target_dir2=${target_dir}/razor_code/reduced/${inputset}_covaug1
target_dir3=${target_dir}/razor_code/reduced/${inputset}_covaug2
target_dir4=${target_dir}/razor_code/reduced/${inputset}_covaug3
target_dir5=${target_dir}/razor_code/reduced/${inputset}_covaug4


if [ ! -d ${target_dir0} ]; then
    mkdir -p ${target_dir0}
fi
if [ ! -d ${target_dir1} ]; then
    mkdir -p ${target_dir1}
fi
if [ ! -d ${target_dir2} ]; then
    mkdir -p ${target_dir2}
fi
if [ ! -d ${target_dir3} ]; then
    mkdir -p ${target_dir3}
fi
if [ ! -d ${target_dir4} ]; then
    mkdir -p ${target_dir4}
fi
if [ ! -d ${target_dir5} ]; then
    mkdir -p ${target_dir5}
fi


#Log
logd=${DEBSTUDY_DIR}/expt/debaug/log/benchmark/${progname}
if [ ! -d ${logd} ]; then
    mkdir -p ${logd}
fi
#We use one log file because we run Razor's training once to produce all debloated programs
logf=${logd}/getprog_razor_cov_and_covaugs_${inputset}.txt


#Training
start_time=$(date +%s.%N)
./train.sh ${progname} ${inputset} &> ${logf}
end_time=$(date +%s.%N)
timedur=$(echo "${end_time} - ${start_time}" | bc)
echo "training time: ${timedur}s" &>>${logf}

cp ${progabbr}.orig ${target_dir0}/${progname}


#Cov
start_time=$(date +%s.%N)
python run_razor.py ${progname} debloat &>> ${logf}
end_time=$(date +%s.%N)
timedur=$(echo "${end_time} - ${start_time}" | bc)
echo "debloat time: ${timedur}s" &>>${logf}

cp ${progabbr}.orig_temp/${progabbr}.orig.debloated ${target_dir1}/${progname}


#Level1
start_time=$(date +%s.%N)
python run_razor.py ${progname} extend_debloat 1 &>> ${logf}
end_time=$(date +%s.%N)
timedur=$(echo "${end_time} - ${start_time}" | bc)
echo "extend-debloat-1 time: ${timedur}s" &>>${logf}

cp ${progabbr}.orig_temp/${progabbr}.orig.debloated ${target_dir2}/${progname}


#Level2
start_time=$(date +%s.%N)
python run_razor.py ${progname} extend_debloat 2 &>> ${logf}
end_time=$(date +%s.%N)
timedur=$(echo "${end_time} - ${start_time}" | bc)
echo "extend-debloat-2 time: ${timedur}s" &>>${logf}

cp ${progabbr}.orig_temp/${progabbr}.orig.debloated ${target_dir3}/${progname}


#Level3
start_time=$(date +%s.%N)
python run_razor.py ${progname} extend_debloat 3 &>> ${logf}
end_time=$(date +%s.%N)
timedur=$(echo "${end_time} - ${start_time}" | bc)
echo "extend-debloat-3 time: ${timedur}s" &>>${logf}

cp ${progabbr}.orig_temp/${progabbr}.orig.debloated ${target_dir4}/${progname}


#Level4
start_time=$(date +%s.%N)
python run_razor.py ${progname} extend_debloat 4 &>> ${logf}
end_time=$(date +%s.%N)
timedur=$(echo "${end_time} - ${start_time}" | bc)
echo "extend-debloat-4 time: ${timedur}s" &>>${logf}

cp ${progabbr}.orig_temp/${progabbr}.orig.debloated ${target_dir5}/${progname}





#Restore the working dirs for bash and vim
if [ ${progname} == "bash-2.05" ]; then

    workdir=${DEBSTUDY_DIR}/expt/debaug/working/bash
    origin_workdir=${DEBSTUDY_DIR}/expt/debaug/working/bash_origin
    if [ -d ${origin_workdir} ]; then
	rm -fr ${workdir}
	cp -r ${origin_workdir} ${workdir}
    else
	echo "Missing ${origin_workdir}. Please manually restore ${workdir} to its original."
    fi

elif [ ${progname} == "vim-5.8" ]; then

    workdir=${DEBSTUDY_DIR}/expt/debaug/working/vim
    origin_workdir=${DEBSTUDY_DIR}/expt/debaug/working/vim_origin
    if [ -d ${origin_workdir} ]; then
	rm -fr ${workdir}
	cp -r ${origin_workdir} ${workdir}
    else
	echo "Missing ${origin_workdir}. Please manually restore ${workdir} to its original."
    fi
fi
