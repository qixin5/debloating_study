#!/bin/bash

BENCH=$1
PROGNAME=$2
inputset=$3    #E.g., I0
fuzznum=$4
ftype=$5       #ch or all


#Will do input-copy from this directory
make_input_dir=${DEBSTUDY_DIR}/expt/debaug/benchmark/make-3.79_template/input.origin/all

if [ -z $BENCH ] || [ -z $PROGNAME ] || [ -z ${inputset} ] || [ -z ${fuzznum} ] || [ -z ${ftype} ]; then
    echo "Missing arguments!"
    exit 1
fi


cd ../debaug/$BENCH/$PROGNAME || exit 1


GCOV_ANAL_BIN=${DEBAUG_DIR}/bin/gcovanalyzer
LCOV2GCOV_BIN=${DEBAUG_DIR}/bin/lcov2gcov
bash_test_script=${DEBSTUDY_DIR}/script/rdsfuzz_sirprog/fuzzscript_used_by_bash/fuzzscript.sh
vim_test_script=${DEBSTUDY_DIR}/script/rdsfuzz_sirprog/fuzzscript_used_by_vim/fuzzscript.sh

CURRDIR=$(pwd) #Program's working dir


BIN=$CURRDIR/$PROGNAME
fuzzid=rdsfuzz${ftype}n${fuzznum}
OUTDIR=$CURRDIR/output.instru/${inputset}_${fuzzid}
INDIR=$CURRDIR/input
GCOVDIR=$CURRDIR/gcov/${inputset}_${fuzzid}
fuzzdir=$CURRDIR/rdsfuzz/augment    #augment is the relevant sub-directory
TIMEOUT=30


#Copy input.origin/${inputset} to input
if [ -d $INDIR ]; then
    rm -fr $INDIR
fi

if [ -d ${INDIR}.origin/${inputset} ]; then
    if [ $PROGNAME == "make-3.79" ]; then
	cp -r -p ${INDIR}.origin/${inputset} $INDIR
    else
	cp -r ${INDIR}.origin/${inputset} $INDIR 
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


#Run test
if [ $PROGNAME == "bash-2.05" ] || [ $PROGNAME == "vim-5.8" ]; then

    augment_cov_ch_file=$CURRDIR/rdsfuzz/augment/augment_cov_ch.txt
    
    if [ ${ftype} == "ch" ] && [ ! -f ${augment_cov_ch_file} ]; then
        echo "File is not found: ${augment_cov_ch_file}! Check if rdsfuzz_reliability_test_sirprog/run_for_bash_vim.sh was executed with no problem."
    fi
    
    argsdir=$CURRDIR/rdsfuzz/augment/args/${inputset}

    for inputdir in ${argsdir}/*; do
	if [ ! -d ${inputdir} ]; then
	    continue
	fi
	inputid=$(basename ${inputdir})
	
	for fuzzvdir in ${inputdir}/*; do  #Fuzzed version of the input
	    if [ ! -d ${fuzzvdir} ]; then
		continue
	    fi
	    fuzzvid=$(basename ${fuzzvdir})

	    #See if the test led to crash/hang.
	    if [ ${ftype} == "ch" ] && [ -f ${augment_cov_ch_file} ]; then
		if ! grep -q "${inputid}/${fuzzvid}" ${augment_cov_ch_file}; then
                    continue
                fi
            fi
	    
	    for fuzzinputf in ${fuzzvdir}/*; do  #Fuzzed file
		if [ -f ${fuzzinputf} ]; then
		    
		    #Copy the test script
		    if [ $PROGNAME == "bash-2.05" ]; then
			cp ${bash_test_script} ./   #File named fuzzscript.sh
			
		    elif [ $PROGNAME == "vim-5.8" ]; then
			cp ${vim_test_script} ./    #File named fuzzscript.sh
			
		    fi
		    
		    #Execute it with the fuzzed input
		    ./fuzzscript.sh $BIN $OUTDIR $TIMEOUT ${fuzzinputf} ${inputid}_${fuzzvid}
		    
		    
		    #Produce gcov file
		    gcovfname=$GCOVDIR/${inputid}_${fuzzvid}
		    if [ -f default.profraw ]; then
			produce_gcov_file ${gcovfname}
			
			#Sometimes, producing a valid gcov would fail.
			#When this happens, try running the test again.
			if [ ! -f ${gcovfname} ] || ! grep -q '[^[:space:]]' ${gcovfname}; then
			    ./fuzzscript.sh $BIN $OUTDIR $TIMEOUT ${fuzzinputf} ${inputid}_${fuzzvid}
			    produce_gcov_file ${gcovfname}
			fi
		    else
			echo "No profraw file generated for fuzzed input ${fuzzinputf} by llvm-cov."
		    fi
		    
		    if [ ! -f ${gcovfname} ] || ! grep -q '[^[:space:]]' ${gcovfname}; then
			echo "No gcov file generated for fuzzed input ${fuzzinputf} by llvm-cov."
		    fi
		    
		    #Clean                     
		    chmod 755 -R $CURRDIR/tmp
		    rm -fr $CURRDIR/tmp/*
		
		fi
	    done
	done
    done
    
else

    fuzzed_testscript_dir=$CURRDIR/rdsfuzz/augment/fuzzedtestscript/${inputset}
    augment_cov_ch_file=$CURRDIR/rdsfuzz/augment/augment_cov_ch.txt

    if [ ${ftype} == "ch" ] && [ ! -f ${augment_cov_ch_file} ]; then
	echo "File is not found: ${augment_cov_ch_file}! Check if rdsfuzz_reliability_test_sirprog/run.sh was executed with no problem."
    fi

    for inputdir in ${fuzzed_testscript_dir}/*; do
	if [ ! -d ${inputdir} ]; then
	    continue
	fi
	inputid=$(basename ${inputdir})

	for fuzzed_testscript in ${inputdir}/*; do
	    fuzzvid=$(basename ${fuzzed_testscript})
	    
	    if [ ${ftype} == "ch" ] && [ -f ${augment_cov_ch_file} ]; then
		if ! grep -q "${inputid}/${fuzzvid}" ${augment_cov_ch_file}; then
		    continue
		fi
	    fi

	    cd $CURRDIR/tmp  #Make sure we're always in the right dir to run tests!
	    
	    #Run instrumented program against fuzzed input
	    if [ ${PROGNAME} == "make-3.79" ]; then

		#Set up the testing environment
		basef=$CURRDIR/rdsfuzz/augment/basetestscript/${inputset}/${inputid}
		target_cp_line=`grep 'cp -r -p' ${basef}`
		target_cp_dir=`echo ${target_cp_line} | tr -s ' ' | cut -d' ' -f4 | cut -d'/' -f2`
		if [ -d ${make_input_dir}/${target_cp_dir} ]; then
                    cp -r -p ${make_input_dir}/${target_cp_dir} ./sdir
                    cd sdir
		fi

		#Run test
		${fuzzed_testscript} $BIN $TIMEOUT &> $OUTDIR/${inputid}_${fuzzvid}

		#Move the intru file
		if [ -f default.profraw ]; then
		    mv default.profraw ${CURRDIR}/tmp
		fi
		
	    else
		${fuzzed_testscript} $BIN $TIMEOUT &> $OUTDIR/${inputid}_${fuzzvid}
	    fi

	    cd $CURRDIR/tmp
	    
	    #Produce gcov file
	    gcovfname=$GCOVDIR/${inputid}_${fuzzvid}
	    if [ -f default.profraw ]; then
		produce_gcov_file ${gcovfname}

		#Sometimes, producing a valid gcov would fail.
                #When this happens, try running the test again.
                if [ ! -f ${gcovfname} ] || ! grep -q '[^[:space:]]' ${gcovfname}; then
		    ${fuzzed_testscript} $BIN $TIMEOUT
                    produce_gcov_file ${gcovfname}
                fi
	    else
		echo "No profraw file generated for fuzzed input ${fuzzed_testscript} by llvm-cov."
	    fi

	    if [ ! -f ${gcovfname} ] || ! grep -q '[^[:space:]]' ${gcovfname}; then
                echo "No gcov file generated for fuzzed input ${fuzzed_testscript} by llvm-cov."
            fi

	    #Clean                                                                          
            chmod 755 -R $CURRDIR/tmp
            rm -fr $CURRDIR/tmp/*
	    
	done
	
    done
    
fi
