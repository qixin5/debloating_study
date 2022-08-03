#!/bin/bash

BENCH=$1
PROGNAME=$2
inputset=$3 #E.g., I0
fuzznum=$4


if [ -z $BENCH ] || [ -z $PROGNAME ] || [ -z ${inputset} ] || [ -z ${fuzznum} ]; then
    echo "Missing arguments!"
    exit 1
fi


cd ../debaug/$BENCH/$PROGNAME || exit 1


GCOV_ANAL_BIN=${DEBAUG_DIR}/bin/gcovanalyzer
LCOV2GCOV_BIN=${DEBAUG_DIR}/bin/lcov2gcov
CURRDIR=$(pwd)


BIN=$CURRDIR/$PROGNAME
fuzzid=rdsfuzzn${fuzznum}
OUTDIR=$CURRDIR/output.instru/${inputset}_${fuzzid}
INDIR=$CURRDIR/input
GCOVDIR=$CURRDIR/gcov/${inputset}_${fuzzid}
fuzzdir=$CURRDIR/rdsfuzz


#Copy input.origin/I${inputset} to input
if [ -d $INDIR ]; then
    rm -fr $INDIR
fi

if [ -d ${INDIR}.origin/${inputset} ]; then        #Deprecated and unused!
    cp -r ${INDIR}.origin/${inputset} $INDIR       #Deprecated and unused!
else
    mkdir $INDIR
fi


#Compile with instrumentation
./compile.sh $CURRDIR/src/origin/$PROGNAME.c $BIN "-fprofile-instr-generate -fcoverage-mapping"


#Clean old output files
if [ ! -d $OUTDIR ]; then
    mkdir -p $OUTDIR
else
    rm -fr $OUTDIR/*
fi

#Clean old gcov files
if [ ! -d ${GCOVDIR} ]; then
    mkdir -p ${GCOVDIR}
else
    rm -fr ${GCOVDIR}/*
fi

#Use a tmp directory for running
if [ ! -d $CURRDIR/tmp ]; then
    mkdir $CURRDIR/tmp
else
    chmod 755 -R $CURRDIR/tmp
    rm -fr $CURRDIR/tmp/*
fi


#Move to tmp
cd $CURRDIR/tmp


#Run tests
for inputdir in $CURRDIR/rdsfuzz/fuzzedtestscript/${inputset}/*; do
    inputid=$(basename ${inputdir})

    testnum=0
    for testf in ${inputdir}/*; do
	testnum=$((testnum + 1))
	if (( testnum > fuzznum )); then
            break
	fi
	
	testid=$(basename ${testf})


	#Run instru
	${testf} $BIN 30  #Currently only need BIN and TIMEOUT


	#Create gcov report
	if [ -f default.profraw ]; then
	    llvm-profdata merge -o $PROGNAME.profdata default.profraw
	    llvm-cov export -format=lcov $BIN -instr-profile=$PROGNAME.profdata $CURRDIR/src/origin/$PROGNAME.c >$PROGNAME.lcov
	    ${LCOV2GCOV_BIN} $PROGNAME.lcov >$PROGNAME.gcov
	    ${GCOV_ANAL_BIN} $PROGNAME.gcov getbcov >$GCOVDIR/${inputid}_${testid}
        else
            echo "No profraw file generated for ${testf}."
        fi
	

        #Clean
        chmod 755 -R $CURRDIR/tmp
	rm -fr $CURRDIR/tmp/*
    done
    
done
