#!/bin/bash

### PROGPATH ###
# origin, I0_chisel, I0_cov, I0_covfuzzch, I0_covfuzzall, I0_covfaugprflex5, I0_covfaugrandombyfunc5/0, I0_covrandaugcovfuzzch/0, I0_covrandaugcovfuzzall/0

### TESTID ###
# I0, I1

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
CHISELBIN=${CHISEL_DIR}/build/bin/chisel
GDTBIN="python ${ROPGDT_DIR}/ROPgadget.py"
MEMSIZEBIN="python ${RAZOR_DIR}/bin/simple_code_size.py"


if [ ${progpath} == "origin" ]; then
    srcf=$CURRDIR/src/origin/$PROGNAME.c
    rsltdir=$CURRDIR/rslt/origin/${testid}
else
    srcf=$CURRDIR/src/reduced/${progpath}/$PROGNAME.c
    rsltdir=$CURRDIR/rslt/reduced/${progpath}/${testid}
fi

if [ ! -f ${srcf} ]; then
    echo "Source file not found: ${srcf}"
    exit 1
fi


#Get number of statements
stmtnum=`${CHISELBIN} -S ${srcf} | tail -1 | cut -d' ' -f4`

if [ ! -d $CURRDIR/tmp ]; then
    mkdir -p $CURRDIR/tmp
fi

#Get number of bytes (no optimization)
./compile.sh ${srcf} $CURRDIR/tmp/$PROGNAME
bytenum0=`${MEMSIZEBIN} $CURRDIR/tmp/$PROGNAME | grep "size: " | cut -d' ' -f2`


#Get number of gadgets (no optimization)
gadgetnum0=`${GDTBIN} --binary $CURRDIR/tmp/$PROGNAME | grep 'Unique gadgets' | cut -d' ' -f4`

#Get number of bytes (-O3)
./compile.sh ${srcf} $CURRDIR/tmp/$PROGNAME.o3 "-O3"
bytenum1=`${MEMSIZEBIN} $CURRDIR/tmp/$PROGNAME.o3 | grep "size: " | cut -d' ' -f2`


#Get number of gadgets (-O3)
gadgetnum1=`${GDTBIN} --binary $CURRDIR/tmp/$PROGNAME.o3 | grep 'Unique gadgets' | cut -d' ' -f4`

#Run tests
cd ${scriptdir}
test/run_test_and_compare_output.sh $BENCH $PROGNAME ${progpath} ${testid}

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
echo "${stmtnum} ${bytenum0} ${gadgetnum0} ${bytenum1} ${gadgetnum1} ${passnum} ${totalnum} ${passrelnum} ${totalrelnum}" >${rsltdir}/rslt.txt


#Save the output comparison result
mv compare_rslt.txt ${rsltdir}/
