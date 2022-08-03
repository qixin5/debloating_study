#!/bin/bash

BENCH=$1
PROGNAME=$2

if [ -z $BENCH ] || [ -z $PROGNAME ]; then
    echo "Missing arguments!"
    exit 1
fi


src_progdir=${DEBSTUDY_DIR}/expt/debaug/$BENCH/${PROGNAME}
target_progdir=${DEBSTUDY_DIR}/expt/chisel/$BENCH/${PROGNAME}

if [ -d ${target_progdir} ]; then
    rm -fr ${target_progdir}
fi

mkdir -p ${target_progdir}


#Copy src
cp ${src_progdir}/src/origin/${PROGNAME}.c ${target_progdir}/${PROGNAME}.c.origin.c


#Copy testscript
if [ -d ${target_progdir}/testscript ]; then
    rm -fr ${target_progdir}/testscript
fi
cp -r ${src_progdir}/testscript ${target_progdir}/



#Copy compile
cp ${src_progdir}/compile.sh ${target_progdir}/


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

