#!/bin/bash

BENCH=$1
PROGNAME=$2
progpath=$3
inputset=$4
forwhat=$5
TIMEOUT=10
#TIMEOUT=3

#Will do copy from this directory
make_input_dir=${DEBSTUDY_DIR}/expt/debaug/benchmark/make-3.79/input.origin/all

if [ -z $BENCH ] || [ -z $PROGNAME ] || [ -z ${progpath} ] || [ -z ${inputset} ]; then
    echo "Missing arguments."
    exit 1
fi

if [ -z ${forwhat} ]; then
    forwhat=robust-testing
fi

if [ ${forwhat} == "augment" ]; then
    cd ../debaug/$BENCH/$PROGNAME/rdsfuzz/augment || exit 1

elif [ ${forwhat} == "robust-testing" ]; then
    cd ../debaug/$BENCH/$PROGNAME/rdsfuzz/robust_testing || exit 1

else
    echo "Unknown forwhat: ${forwhat}."
    exit 1
fi

CURRDIR=$(pwd)


#Prepare bin
BIN=$CURRDIR/$PROGNAME

if [ -f $BIN ]; then
    rm -fr $BIN
fi

cp ../../compile.sh ./
if [ ${progpath} == "origin" ]; then
    ./compile.sh ../../src/origin/${PROGNAME}.c ./${PROGNAME}
else
    ./compile.sh ../../src/reduced/${progpath}/${PROGNAME}.c ./${PROGNAME}
fi

if [ ! -f $BIN ]; then
    echo "Missing BIN: $BIN"
    exit 1
fi


#Prepare the argument inputs used by fuzzedscript
argsdir=$CURRDIR/args/${inputset}
argsbackupdir=$CURRDIR/args.backup/${inputset}

if [ -d ${argsbackupdir} ]; then
    if [ -d ${argsdir} ]; then
	rm -fr ${argsdir}
    fi
    cp -r ${argsbackupdir} ${argsdir}

else
    echo "Missing ${argsbackupdir}"
fi


#Prepare output directory
if [ ${progpath} == "origin" ]; then
    OUTROOTDIR=$CURRDIR/output/origin/${inputset}
else
    OUTROOTDIR=$CURRDIR/output/reduced/${progpath}/${inputset}
fi

if [ ! -d $OUTROOTDIR ]; then
    mkdir -p $OUTROOTDIR
else
    rm -fr $OUTROOTDIR/*
fi


#Use a tmp directory for running
if [ ! -d $CURRDIR/tmp ]; then
    mkdir $CURRDIR/tmp
else
    chmod 755 -R $CURRDIR/tmp
    rm -fr $CURRDIR/tmp/*
fi
cd $CURRDIR/tmp



for inputdir in $CURRDIR/fuzzedtestscript/${inputset}/*; do  #This is an input dir

    inputid=$(basename ${inputdir})

    #Prepare an output dir for this input
    outdir=$OUTROOTDIR/${inputid}
    if [ -d ${outdir} ]; then
	rm -fr ${outdir}/*
    else
	mkdir ${outdir}
    fi

    #Run test
    for testf in ${inputdir}/*; do          #This is a fuzzed version for the input

	cd $CURRDIR/tmp       #Make sure we're always in the right dir to run tests!

	echo "${testf}"
	inputfid=$(basename ${testf})

	#Set up the testing environment for make-3.79	
	if [ ${PROGNAME} == "make-3.79" ]; then
	    basef=$CURRDIR/basetestscript/${inputset}/${inputid}
	    target_cp_line=`grep 'cp -r -p' ${basef}`
	    target_cp_dir=`echo ${target_cp_line} | tr -s ' ' | cut -d' ' -f4 | cut -d'/' -f2`
	    if [ -d ${make_input_dir}/${target_cp_dir} ]; then
		cp -r -p ${make_input_dir}/${target_cp_dir} ./sdir
		cd sdir
	    fi
	fi

	#Execute the fuzz test
	${testf} $BIN $TIMEOUT &> ${outdir}/${inputfid}
	echo "$?" &>> ${outdir}/${inputfid}


	cd $CURRDIR/tmp
	chmod 755 -R $CURRDIR/tmp
	rm -fr $CURRDIR/tmp/*

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
done
