#!/bin/bash

BENCH=$1
PROGNAME=$2
inputset=$3 #E.g., I0

if [ -z $BENCH ] || [ -z $PROGNAME ] || [ -z ${inputset} ]; then
    echo "Missing arguments!"
    exit 1
fi

cd ../debaug/$BENCH/$PROGNAME || exit 1


GCOV_ANAL_BIN=${DEBAUG_DIR}/bin/gcovanalyzer
LCOV2GCOV_BIN=${DEBAUG_DIR}/bin/lcov2gcov
CURRDIR=$(pwd)

BIN=$CURRDIR/$PROGNAME
OUTDIR=$CURRDIR/output.instru/${inputset}_cov
TIMEOUT=30
INDIR=$CURRDIR/input
GCOVDIR=$CURRDIR/gcov/${inputset}_cov


#Copy input.origin/I${inputset} to input
if [ -d $INDIR ]; then
    rm -fr $INDIR
fi

if [ -d $INDIR.origin/${inputset} ]; then
    if [ $PROGNAME == "make-3.79" ]; then
        cp -r -p $INDIR.origin/${inputset} $INDIR
    else
        cp -r $INDIR.origin/${inputset} $INDIR
    fi
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
if [ ! -d $GCOVDIR ]; then
    mkdir -p $GCOVDIR
else
    rm -fr $GCOVDIR/*
fi

#Use a tmp directory for running
if [ ! -d $CURRDIR/tmp ]; then
    mkdir $CURRDIR/tmp
else
    chmod 755 -R $CURRDIR/tmp
    rm -fr $CURRDIR/tmp/*
fi
cd $CURRDIR/tmp


produce_gcov_file () {
    llvm-profdata merge -o $PROGNAME.profdata default.profraw
    llvm-cov export -format=lcov $BIN -instr-profile=$PROGNAME.profdata $CURRDIR/src/origin/$PROGNAME.c >$PROGNAME.lcov
    ${LCOV2GCOV_BIN} $PROGNAME.lcov >$PROGNAME.gcov
    ${GCOV_ANAL_BIN} $PROGNAME.gcov getbcov >$1
}

#Run tests
INSTRU=true
for testf in $CURRDIR/testscript/${inputset}/*; do
    testfname=$(basename ${testf})
    gcovfname=$GCOVDIR/${testfname}

    ###########
    #echo "${testf} $BIN $OUTDIR $TIMEOUT $INDIR $INSTRU"
    ###########
    ${testf} $BIN $OUTDIR $TIMEOUT $INDIR $INSTRU

    #Create gcov report
    if [ -f default.profraw ]; then
	produce_gcov_file ${gcovfname}

	#Sometimes, producing a valid gcov would fail.
	#When this happens, try running the test again.
	if [ ! -f ${gcovfname} ] || ! grep -q '[^[:space:]]' ${gcovfname}; then
	    ${testf} $BIN $OUTDIR $TIMEOUT $INDIR $INSTRU
	    produce_gcov_file ${gcovfname}
	fi
    else
	echo "No profraw file generated for ${inputset}/${testfname} by llvm-cov."
    fi

    #Report failure (if any)
    if [ ! -f ${gcovfname} ] || ! grep -q '[^[:space:]]' ${gcovfname}; then
	echo "No .gcov file generated for ${inputset}/${testfname} by llvm-cov."
    fi
    
    #Clean
    chmod 755 -R $CURRDIR/tmp
    rm -fr $CURRDIR/tmp/*
done
