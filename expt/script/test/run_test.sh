#!/bin/bash

### PROGPATH ###
# origin, I0_cov, I0_covfuzzch, I0_covfuzzall, I0_covfaugprflex5, I0_covrandaugcovfuzzch/0

### TESTID ###
# I0, I1

BENCH=$1
PROGNAME=$2
progpath=$3
testid=$4
inputset=${testid}

if [ -z $BENCH ] || [ -z $PROGNAME ] || [ -z ${progpath} ] || [ -z ${testid} ]; then
    echo "Missing arguments!"
    exit 1
fi

cd ../debaug/$BENCH/$PROGNAME || exit 1


CURRDIR=$(pwd)
BIN=$CURRDIR/$PROGNAME
if [ ${progpath} == "origin" ]; then
    OUTDIR=$CURRDIR/output/origin/${testid}
else
    OUTDIR=$CURRDIR/output/reduced/${progpath}/${testid}
fi
TIMEOUT=10
INDIR=$CURRDIR/input


#Prepare input files
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


#Compile
if [ ${progpath} == "origin" ]; then
    ./compile.sh src/origin/$PROGNAME.c $BIN
else
    ./compile.sh src/reduced/${progpath}/$PROGNAME.c $BIN
fi

#Clean old output files
if [ ! -d $OUTDIR ]; then
    mkdir -p $OUTDIR
else
    rm -fr $OUTDIR/*
fi

#Use a tmp directory for running
if [ ! -d $CURRDIR/tmp ]; then
    mkdir $CURRDIR/tmp
else
    chmod 755 -R $CURRDIR/tmp
    rm -fr $CURRDIR/tmp/*
fi
cd $CURRDIR/tmp

#Run tests
for testf in $CURRDIR/testscript/${inputset}/*; do
    #echo "${testf} $BIN $OUTDIR $TIMEOUT $INDIR"
    echo "${testf}"
    ${testf} $BIN $OUTDIR $TIMEOUT $INDIR
    chmod 755 -R $CURRDIR/tmp
    rm -fr $CURRDIR/tmp/*

    #Kill the non-terminated ones
    if [ ! -z $BIN ]; then
	#Look for commands that start with $BIN ($11 is the start of command)
	procs=`ps aux | awk -v var="$BIN" '($11 == var)' | sed 's/\s\s*/ /g' | cut -d' ' -f2`
	if [ ! -z "${procs}" ]; then
	    echo ${procs} >mykills.sh
	    sed -e 's|^|kill -9 |g' -i mykills.sh
	    chmod 700 mykills.sh
	    ./mykills.sh
	    rm mykills.sh
	fi
    fi
done

