#!/bin/bash

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
    OUTDIR=$CURRDIR/output_razor/origin/${testid}
else
    OUTDIR=$CURRDIR/output_razor/reduced/${progpath}/${testid}
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


#Copy binary
if [ ${progpath} == "origin" ]; then
    cp $CURRDIR/razor_code/origin/$PROGNAME $BIN
else
    cp $CURRDIR/razor_code/reduced/${progpath}/$PROGNAME $BIN
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

    echo "${testf}"

    if [ $PROGNAME == "bzip2-1.0.5" ] || [ $PROGNAME == "chown-8.2" ] || [ $PROGNAME == "date-8.21" ] || [ $PROGNAME == "grep-2.19" ] || [ $PROGNAME == "gzip-1.2.4" ] || [ $PROGNAME == "mkdir-5.2.1" ] || [ $PROGNAME == "rm-8.4" ] || [ $PROGNAME == "sort-8.16" ] || [ $PROGNAME == "tar-1.14" ] || [ $PROGNAME == "uniq-8.16" ]; then

	cp $BIN ./$PROGNAME
	${testf} "./$PROGNAME" $OUTDIR $TIMEOUT $INDIR    #Using $BIN (i.e., absolute path) here would be problematic (this is razor's problem)

    else

	${testf} $BIN $OUTDIR $TIMEOUT $INDIR
	
    fi

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
