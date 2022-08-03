#!/bin/bash

BENCH=$1
PROGNAME=$2

if [ -z $BENCH ] || [ -z $PROGNAME ]; then
    echo "Missing arguments!"
    exit 1
fi


src_progdir=${DEBSTUDY_DIR}/expt/debaug/$BENCH/${PROGNAME}
reduced_src_dir=${DEBSTUDY_DIR}/expt/debaug/$BENCH/${PROGNAME}/src/reduced
target_progdir=${DEBSTUDY_DIR}/expt/debop/$BENCH/${PROGNAME}


#Initialize the target directory
if [ ! -d ${target_progdir} ]; then
    mkdir -p ${target_progdir}
else
    rm -fr ${target_progdir}/*
fi

#Copy original src
cp ${src_progdir}/src/origin/${PROGNAME}.c ${target_progdir}/${PROGNAME}.c.real.origin.c


#Copy cov src
if [ -d ${target_progdir}/cov ]; then
    rm -fr ${target_progdir}/cov/*
else
    mkdir ${target_progdir}/cov
fi

for covdir in ${reduced_src_dir}/*; do
    covdirname=$(basename ${covdir})
    if [[ ${covdirname} == *_cov ]]; then
	inputset=`echo ${covdirname} | cut -d'_' -f1`
	cp ${covdir}/${PROGNAME}.c ${target_progdir}/cov/${inputset}.c
    fi
done


#Copy testscript
if [ -d ${target_progdir}/testscript ]; then
    rm -fr ${target_progdir}/testscript
fi
cp -r ${src_progdir}/testscript ${target_progdir}/



#Copy compile
cp ${src_progdir}/compile.sh ${target_progdir}/compile


#Copy input.origin
if [ -d ${target_progdir}/input.origin ]; then
    rm -fr ${target_progdir}/input.origin
fi

if [ -d ${src_progdir}/input.origin ]; then
    if [ $PROGNAME == "make-3.79" ]; then
	cp -r -p ${src_progdir}/input.origin ${target_progdir}/
    else
	cp -r ${src_progdir}/input.origin ${target_progdir}/
    fi
fi

