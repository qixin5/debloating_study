#!/bin/bash

BENCH=$1
PROGNAME=$2
progpath=$3
testid=$4

if [ -z $BENCH ] || [ -z $PROGNAME ] || [ -z ${progpath} ] || [ -z ${testid} ]; then
    echo "Missing arguments!"
    exit 1
fi

scriptdir=$(pwd)
cd ../debaug/$BENCH/$PROGNAME || exit 1


CURRDIR=$(pwd)
GDTBIN="python3 ${ROPGDT_DIR}/ROPgadget.py"
MEMSIZEBIN="python ${RAZOR_DIR}/bin/simple_code_size.py"


if [ ${progpath} == "origin" ]; then
    codef=$CURRDIR/razor_code/origin/$PROGNAME
    rsltdir=$CURRDIR/razor_rslt/origin/${testid}
else
    codef=$CURRDIR/razor_code/reduced/${progpath}/$PROGNAME
    rsltdir=$CURRDIR/razor_rslt/reduced/${progpath}/${testid}
fi

if [ ! -f ${codef} ]; then
    echo "Code file not found: ${codef}"
    exit 1
fi


#Get number of mem-bytes
bytenum=`${MEMSIZEBIN} ${codef} | grep "size: " | cut -d' ' -f2`

#Get number of gadgets
gadgetnum=`${GDTBIN} --binary ${codef} | grep 'Unique gadgets' | cut -d' ' -f4`


#Run tests
cd ${scriptdir}
test/run_test_and_compare_output_razor.sh $BENCH $PROGNAME ${progpath} ${testid}


#Get nums to compute all-input generality
cd ${CURRDIR}
passnum=`grep "pass-" compare_rslt.txt | wc -l`
failnum=`grep "fail-" compare_rslt.txt | wc -l`
totalnum=$((passnum + failnum))

#Get nums to compute related-input generality
trainid=`echo ${progpath} | cut -d'_' -f1`
relfile=reltest/${testid}_${trainid}.txt
totalrelnum="-1"
passrelnum="0"
if [ -f ${relfile} ]; then
    totalrelnum=`wc -l <${relfile}`
    passrelnum=0
    while IFS= read -r line; do
        relid=`echo ${line} | cut -d',' -f1`
        if `grep -q "pass-o${relid}$" compare_rslt.txt`; then  #NOTE: Need to end with the query!
            passrelnum=$((passrelnum+1))
        fi
    done < ${relfile}
else
    echo "Missing ${relfile}."
fi


#Print result
if [ ! -d ${rsltdir} ]; then
    mkdir -p ${rsltdir}
else
    rm -fr ${rsltdir}/*
fi

#Save the numbers
echo "${bytenum} ${gadgetnum} ${passnum} ${totalnum} ${passrelnum} ${totalrelnum}" >${rsltdir}/rslt.txt


#Save the output comparison result
mv compare_rslt.txt ${rsltdir}/
