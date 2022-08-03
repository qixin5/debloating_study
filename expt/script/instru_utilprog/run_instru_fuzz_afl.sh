#!/bin/bash

BENCH=$1
PROGNAME=$2
inputset=$3 #E.g., I0
ftype=$4 #Either "ch" (inputs from crash and hang) or "all" (inputs from crash, hang, and queue)
ftype2=$5 #bycmd or byfile
fuzztimeout=$6


if [ -z $BENCH ] || [ -z $PROGNAME ] || [ -z ${inputset} ] || \
   [ -z ${ftype} ] || [ -z ${ftype2} ] || [ -z ${fuzztimeout} ]; then
    echo "Missing arguments!"
    exit 1
fi

if [ ${ftype} != "ch" ] && [ ${ftype} != "all" ]; then
    echo "Unknown ftype: ${ftype}."
    exit 1
fi

if [ ${ftype2} != "bycmd" ] && [ ${ftype2} != "byfile" ]; then
    echo "Unknown ftype2: ${ftype2}."
    exit 1
fi


cd ../debaug/$BENCH/$PROGNAME || exit 1


GCOV_ANAL_BIN=${DEBAUG_DIR}/bin/gcovanalyzer
LCOV2GCOV_BIN=${DEBAUG_DIR}/bin/lcov2gcov
CURRDIR=$(pwd)


BIN=$CURRDIR/$PROGNAME
fuzzid=aflfuzz${ftype}${fuzztimeout}m${ftype2}
OUTDIR=$CURRDIR/output.instru/${inputset}_${fuzzid}
INDIR=$CURRDIR/input
GCOVDIR=$CURRDIR/gcov/${inputset}_${fuzzid}
fuzzdir=$CURRDIR/aflfuzz


#Copy input.origin/I${inputset} to input
if [ -d $INDIR ]; then
    rm -fr $INDIR
fi

if [ -d aflfuzz${INDIR}.origin/${inputset} ]; then
    cp -r aflfuzz${INDIR}.origin/${inputset} $INDIR
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
cd $CURRDIR/tmp


#Define three functions
run_instru_bycmd () {
    inputf=$1
    argf=$2
    filef=$3
    
    ln=`wc -l ${inputf} | cut -d' ' -f1`
    if [ ${ln} -gt 1 ]; then
	echo "Ignore ${inputf} because it contains more than one line."
	return 1
    fi
    
    cmdstr=`head -n 1 ${inputf}`
    echo "timeout -k 9 30s ${BIN} ${cmdstr}" >run.sh
    echo "Command of instru based on fuzzed input:"
    cat run.sh
    
    #Copy input files to the running dir
    if [ -f ${filef} ]; then
	while IFS= read -r fname || [[ -n "${fname}" ]]; do
	    cp -r $INDIR/${fname} ./
	done <"${filef}"
    fi
    
    #Run the script
    chmod 700 run.sh && ./run.sh
}

run_instru_byfile () {
    inputf=$1
    argf=$2
    filef=$3

    if [ ! -f ${argf} ]; then #It must exist, although could be empty
	echo "Missing ${argf}. Ignore ${inputf}."
	return 1
    fi
    
    if [ ! -f ${filef} ]; then #It may not exist, in which case, no fuzzing is needed.
	echo "Missing ${filef}. Ignore ${inputf}."
	return 1
    fi
    
    argstr=`head -n 1 ${argf}` #argstr could be empty.
    fname=`head -n 1 ${filef}`
    cmdstr="${argstr} ${fname}"
    echo "timeout -k 9 30s ${BIN} ${cmdstr}" >run.sh
    echo "Command of instru based on fuzzed input:"
    cat run.sh
    
    #Copy the fuzzed file as fname
    cp ${inputf} ./${fname}
    
    #Run the script
    chmod 700 run.sh && ./run.sh
}

make_gcov_report () {
    rsltfname=$1
    
    llvm-profdata merge -o $PROGNAME.profdata default.profraw
    llvm-cov export -format=lcov $BIN -instr-profile=$PROGNAME.profdata $CURRDIR/src/origin/$PROGNAME.c >$PROGNAME.lcov
    ${LCOV2GCOV_BIN} $PROGNAME.lcov >$PROGNAME.gcov
    ${GCOV_ANAL_BIN} $PROGNAME.gcov getbcov >$GCOVDIR/${rsltfname}
    #${GCOV_ANAL_BIN} $PROGNAME.gcov getbcov >$GCOVDIR/${inputid}_c${cid}
}

#Run tests
for inputdir in $CURRDIR/aflfuzz/fuzz_${ftype2}/${fuzztimeout}m/${inputset}/*; do
    inputid=$(basename ${inputdir})
    argf=${fuzzdir}/args/${inputset}/${inputid}
    filef=${fuzzdir}/files/${inputset}/${inputid}
    cid=0
    hid=0
    qid=0

    #Run crash inputs
    if [ ${ftype} == "ch" ] || [ ${ftype} == "all" ]; then
	if [ ! -z "$(ls -A ${inputdir}/afl-out/crashes)" ]; then
	    for inputf in ${inputdir}/afl-out/crashes/*; do
		inputfname=$(basename ${inputf})
		if [ ! -f ${inputf} ] || [ ${inputfname} == "README.txt" ]; then
		    continue
		fi
		
		if [ ${ftype2} == "bycmd" ]; then
		    run_instru_bycmd ${inputf} ${argf} ${filef}
		else
		    run_instru_byfile ${inputf} ${argf} ${filef}
		fi
		
		#Create gcov report
		if [ -f default.profraw ]; then
		    make_gcov_report ${inputid}_c${cid}
		    cid=$((cid+1))
		else
		    echo "No profraw file generated for ${inputf}."
		fi
		
		#Clean
		chmod 755 -R $CURRDIR/tmp
		rm -fr $CURRDIR/tmp/*
	    done
	fi
    fi
    
    #Run hang inputs
    if [ ${ftype} == "ch" ] || [ ${ftype} == "all" ]; then
	if [ ! -z "$(ls -A ${inputdir}/afl-out/hangs)" ]; then
	    for inputf in ${inputdir}/afl-out/hangs/*; do
		inputfname=$(basename ${inputf})
		if [ ! -f ${inputf} ] || [ ${inputfname} == "README.txt" ]; then
		    continue
		fi
		
		if [ ${ftype2} == "bycmd" ]; then
		    run_instru_bycmd ${inputf} ${argf} ${filef}
		else
		    run_instru_byfile ${inputf} ${argf} ${filef}
		fi
		
		#Create gcov report
		if [ -f default.profraw ]; then
		    make_gcov_report ${inputid}_h${hid}
		    hid=$((hid+1))
		else
		    echo "No profraw file generated for ${inputf}."
		fi
		
		#Clean
		chmod 755 -R $CURRDIR/tmp
		rm -fr $CURRDIR/tmp/*
	    done
	fi
    fi
    
    #Run queue inputs
    if [ ${ftype} == "all" ]; then
	if [ ! -z "$(ls -A ${inputdir}/afl-out/queue)" ]; then
	    for inputf in ${inputdir}/afl-out/queue/*; do
		inputfname=$(basename ${inputf})
		if [ ! -f ${inputf} ] || [ ${inputfname} == "README.txt" ]; then
		    continue
		fi
		
		if [ ${ftype2} == "bycmd" ]; then
		    run_instru_bycmd ${inputf} ${argf} ${filef}
		else
		    run_instru_byfile ${inputf} ${argf} ${filef}
		fi
		
		#Create gcov report
		if [ -f default.profraw ]; then
		    make_gcov_report ${inputid}_q${qid}
		    qid=$((qid+1))
		else
		    echo "No profraw file generated for ${inputf}."
		fi
		
		#Clean
		chmod 755 -R $CURRDIR/tmp
		rm -fr $CURRDIR/tmp/*
	    done
	fi
    fi
done
