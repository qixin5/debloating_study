#!/bin/bash

BIN=$1
OUTDIR=$2
TIMEOUT=$3
inputset=$4
PROGNAME=$5

if [ -z $BIN ] || [ -z $OUTDIR ] || [ -z $TIMEOUT ] || [ -z ${inputset} ] || [ -z $PROGNAME ]; then
    echo "Missing argument for run_test!"
    exit 1
fi

CURRDIR=$(pwd)

#Copy input
INPUTORIG=./input.origin
if [ -d input ]; then
    rm -fr input
fi
if [ -d $INPUTORIG/${inputset} ]; then
    if [ $PROGNAME == "make-3.79" ]; then
        cp -r -p $INPUTORIG/${inputset} ./input
    else
        cp -r $INPUTORIG/${inputset} ./input
    fi
fi


#Clean earlier output
if [ -d $OUTDIR ]; then
    rm -fr $OUTDIR/*
else
    mkdir -p $OUTDIR
fi


#Use a tmp directory for execution
if [ ! -d $CURRDIR/tmp ]; then
    mkdir $CURRDIR/tmp
else
    chmod 755 -R $CURRDIR/tmp
    rm -fr $CURRDIR/tmp/*
fi
cd $CURRDIR/tmp


#Execute every testscript
for testf in $CURRDIR/testscript/${inputset}/*; do
    ${testf} $BIN $OUTDIR $TIMEOUT $CURRDIR/input
    chmod 755 -R $CURRDIR/tmp
    rm -fr $CURRDIR/tmp/*

    #Kill unterminated procs
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

