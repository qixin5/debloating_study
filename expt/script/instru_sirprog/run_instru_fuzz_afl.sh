#!/bin/bash

BENCH=$1
PROGNAME=$2
inputset=$3     #E.g., I0
ftype=$4        #Either "ch" (inputs from crash and hang) or "all" (inputs from crash, hang, and queue)
ftype2=$5       #bycmd or byfile
fuzztimeout=$6  #Provide a number (no "m" in the end)
TIMEOUT=30


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
aflfuzzedscriptgen=${DEBAUG_DIR}/bin/aflfuzzedscriptgen
CURRDIR=$(pwd)


BIN=$CURRDIR/$PROGNAME
fuzzid=aflfuzz${ftype}${fuzztimeout}m${ftype2}
OUTDIR=$CURRDIR/output.instru/${inputset}_${fuzzid}
GCOVDIR=$CURRDIR/gcov/${inputset}_${fuzzid}



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



produce_gcov_file () {
    llvm-profdata merge -o $PROGNAME.profdata default.profraw
    llvm-cov export -format=lcov $BIN -instr-profile=$PROGNAME.profdata $CURRDIR/src/origin/$PROGNAME.c >$PROGNAME.lcov
    ${LCOV2GCOV_BIN} $PROGNAME.lcov >$PROGNAME.gcov
    ${GCOV_ANAL_BIN} $PROGNAME.gcov getbcov >$1
}




#Run tests
for inputdir in $CURRDIR/aflfuzz/fuzz_${ftype2}/${fuzztimeout}m/${inputset}/*; do
    if [ ! -d ${inputdir} ]; then #There are all_inputs.txt & selected_inputs.txt
	continue
    fi

    inputid=$(basename ${inputdir})

    origin_testf=$CURRDIR/testscript/${inputset}/${inputid}

    for dtype in crashes hangs queue; do
	if [ ${dtype} == "queue" ] && [ ${ftype} == "ch" ]; then
	    continue
	fi

	if [ ! -z "$(ls -A ${inputdir}/afl-out/${dtype})" ]; then
            for inputf in ${inputdir}/afl-out/${dtype}/*; do
		inputfname=$(basename ${inputf})
                if [ ! -f ${inputf} ] || [ ${inputfname} == "README.txt" ]; then
                    continue
	        fi
		
		#Get the original input fname
		cpinputfname=unknown
		for aflinf in ${inputdir}/afl-in/*; do
		    cpinputfname=$(basename ${aflinf})
		    break
		done

		#Produce a script running against fuzzed input file
		${aflfuzzedscriptgen} ${origin_testf} $PROGNAME ${inputf} ${cpinputfname} ${inputid}_${dtype}_${inputfname} ./run.sh
		chmod 700 ./run.sh
		#===============
		#cat run.sh
		#echo ""
		#===============		


		#Execute the script (make sure we're in $CURRDIR/tmp)
		#===============
		#echo "./run.sh $BIN $OUTDIR $TIMEOUT"
		#===============		
		./run.sh $BIN $OUTDIR $TIMEOUT
		

		#Produce gcov file
		gcovfname=$GCOVDIR/${inputid}_${dtype}_${inputfname}
		if [ -f default.profraw ]; then
		    produce_gcov_file ${gcovfname}
		    #Sometimes, producing a valid gcov would fail.
		    #When this happens, try running the test again.
		    if [ ! -f ${gcovfname} ] || ! grep -q '[^[:space:]]' ${gcovfname}; then
			./run.sh $BIN $OUTDIR $TIMEOUT
			produce_gcov_file ${gcovfname}
		    fi
		else
		    echo "No profraw file generated for input ${inputid}_${dtype}_${inputfname} by llvm-cov."
		fi

		if [ ! -f ${gcovfname} ] || ! grep -q '[^[:space:]]' ${gcovfname}; then
		    echo "No gcov file generated for input ${inputid}_${dtype}_${inputfname} by llvm-cov."
		fi

		#Clean
                chmod 755 -R $CURRDIR/tmp
                rm -fr $CURRDIR/tmp/*

	    done
	fi
    done
done


