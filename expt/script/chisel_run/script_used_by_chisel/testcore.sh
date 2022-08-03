#!/bin/bash

######
#NOTE: This script should be copied to Chisel's working dir to execute.
######

PROGNAME=$1
inputset=$2
sanitizer=$3
TIMEOUT=10

if [ -z ${PROGNAME} ] || [ -z ${inputset} ]; then  #sanitizer could be null
    echo "Missing arguments."
    exit 1
fi

CURRDIR=$(pwd)
SRC=$CURRDIR/$PROGNAME.c
ORIGIN_SRC=$CURRDIR/$PROGNAME.c.origin.c
BIN=$CURRDIR/$PROGNAME
OUTDIR=$CURRDIR/output/${inputset}
ORIGIN_OUTDIR=$CURRDIR/output.origin/${inputset}
INDIR=$CURRDIR/input
INDIR_ORIGIN=$CURRDIR/input.origin/${inputset}


### Generate Oracle Outputs
if [ ! -d ${ORIGIN_OUTDIR} ]; then
    mkdir -p ${ORIGIN_OUTDIR}
    ./compile.sh ${ORIGIN_SRC} ${BIN} ${sanitizer} || exit 1

    if [ ! -d $CURRDIR/tmp ]; then
	mkdir $CURRDIR/tmp
    else
	chmod 755 -R $CURRDIR/tmp
	rm -fr $CURRDIR/tmp/*
    fi

    #Prepare input dir
    if [ -d $INDIR ]; then
	rm -fr $INDIR
    fi
    if [ -d ${INDIR_ORIGIN} ]; then
	if [ $PROGNAME == "make-3.79" ]; then
	    cp -r -p ${INDIR_ORIGIN} $INDIR
	else
	    cp -r ${INDIR_ORIGIN} $INDIR
	fi
    fi
    
    cd $CURRDIR/tmp
    for testf in $CURRDIR/testscript/${inputset}/*; do
	${testf} $BIN ${ORIGIN_OUTDIR} $TIMEOUT $INDIR
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

    cd $CURRDIR
fi


### Generate Reduced Outputs
if [ -f $BIN ]; then
    rm $BIN
fi

if [ ! -d ${OUTDIR} ]; then
    mkdir -p ${OUTDIR}
else
    rm -fr ${OUTDIR}/*
fi

./compile.sh ${SRC} ${BIN} ${sanitizer} || exit 1

if [ ! -d $CURRDIR/tmp ]; then
    mkdir $CURRDIR/tmp
else
    chmod 755 -R $CURRDIR/tmp
    rm -fr $CURRDIR/tmp/*
fi

#Prepare input dir
if [ -d $INDIR ]; then
    rm -fr $INDIR
fi
if [ -d ${INDIR_ORIGIN} ]; then
    if [ $PROGNAME == "make-3.79" ]; then
	cp -r -p ${INDIR_ORIGIN} $INDIR
    else
	cp -r ${INDIR_ORIGIN} $INDIR
    fi
fi

exitval=0
cd $CURRDIR/tmp
for testf in $CURRDIR/testscript/${inputset}/*; do
    ${testf} $BIN $OUTDIR $TIMEOUT $INDIR
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

    #Compare outputs
    testid=$(basename ${testf})
    if [ -f $OUTDIR/o${testid} ] && [ -f ${ORIGIN_OUTDIR}/o${testid} ]; then
        if ! diff -q $OUTDIR/o${testid} ${ORIGIN_OUTDIR}/o${testid} &> /dev/null; then
            exitval=1
            break
        fi
    elif [ ! -f $OUTDIR/o${testid} ] && [ ! -f ${ORIGIN_OUTDIR}/o${testid} ]; then
        continue
    else
        #One exists, the other doesn't
        exitval=1
        break
    fi
done

exit ${exitval}
