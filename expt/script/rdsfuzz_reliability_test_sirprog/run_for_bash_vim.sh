#!/bin/bash

BENCH=$1
PROGNAME=$2
progpath=$3
inputset=$4
forwhat=$5
TIMEOUT=10
#TIMEOUT=3

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
bash_test_script=${DEBAUG_DIR}_expt/script/rdsfuzz_sirprog/fuzzscript_used_by_bash/fuzzscript.sh
vim_test_script=${DEBAUG_DIR}_expt/script/rdsfuzz_sirprog/fuzzscript_used_by_vim/fuzzscript.sh


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



#Run tests
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
	
        for fuzzinputf in ${fuzzvdir}/*; do  #Fuzzed file
            if [ -f ${fuzzinputf} ]; then
		
                #Copy the test script
                if [ $PROGNAME == "bash-2.05" ]; then
                    cp ${bash_test_script} ./   #File named fuzzscript.sh
		    
		elif [ $PROGNAME == "vim-5.8" ]; then
                    cp ${vim_test_script} ./    #File named fuzzscript.sh
		    
                fi
		
		#Execute it with the fuzzed input 
		./fuzzscript.sh $BIN $OUTROOTDIR $TIMEOUT ${fuzzinputf} ${inputid}_${fuzzvid}

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
	    fi
	done
    done
done
