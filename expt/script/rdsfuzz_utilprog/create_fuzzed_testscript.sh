#!/bin/bash

BENCH=$1
PROGNAME=$2
inputset=$3
fuzznum=$4    #For every input
forwhat=$5    #augment or robust-testing

compilescriptgenbin=${DEBAUG_DIR}/bin/compilescriptgeneratorforfuzzedtestscriptgenerator
fuzztestscriptgensrcf=${DEBAUG_DIR}/src/c/FuzzedTestScriptGenerator.c


if [ -z $BENCH ] || [ -z $PROGNAME ] || [ -z ${inputset} ] || [ -z ${fuzznum} ] || [ -z ${forwhat} ]; then
    echo "Missing arguments!"
    exit 1
fi

cd ../debaug/$BENCH/$PROGNAME/rdsfuzz || exit 1

if [ ${forwhat} == "augment" ]; then
    if [ ! -d augment ]; then
	mkdir augment
    fi
    cd augment
    
elif [ ${forwhat} == "robust-testing" ]; then
    if [ ! -d robust_testing ]; then
	mkdir robust_testing
    fi
    cd robust_testing
    
else
    echo "Unknown forwhat: ${forwhat}"
    exit 1
fi

CURRDIR=$(pwd)

#Prepare basetestscript dir
if [ ! -d basetestscript ]; then
    if [ -d ../basetestscript ]; then
	cp -r ../basetestscript ./
    else
	echo "Missing ${CURRDIR}/../basetestscript"
	exit 1
    fi
fi



#Must use absolute paths
argsdir=$CURRDIR/args/${inputset}
argsbackupdir=$CURRDIR/args.backup/${inputset}
fuzzedtestscriptdir=$CURRDIR/fuzzedtestscript/${inputset}
basetestscriptdir=$CURRDIR/basetestscript/${inputset}
inorigindir=$CURRDIR/../../input.origin
indir=$CURRDIR/input


if [ ! -d ${basetestscriptdir} ]; then
    echo "Missing ${basetestscriptdir}"
    exit 1
fi



#Directory setup
if [ ! -d ${argsdir} ]; then
    mkdir -p ${argsdir}
else
    rm -fr ${argsdir}/*
fi

if [ ! -d args.backup ]; then
    mkdir args.backup
fi

if [ ! -d ${fuzzedtestscriptdir} ]; then
    mkdir -p ${fuzzedtestscriptdir}
else
    rm -fr ${fuzzedtestscriptdir}/*
fi

if [ -d ${indir} ]; then
    rm -fr ${indir}
fi

if [ -d ${inorigindir} ]; then
    cp -r ${inorigindir}/${inputset} ${indir}
else
    mkdir ${indir}
fi


if [ ! -d $CURRDIR/tmp ]; then
    mkdir $CURRDIR/tmp
else
    chmod 755 -R $CURRDIR/tmp
    rm -fr $CURRDIR/tmp/*
fi



#Execute every base test script to generate fuzzed test script
for testf in ${basetestscriptdir}/*; do

    cd ${CURRDIR}                                 #i.e., rdsfuzz/{augment|robust_testing}
    testid=$(basename ${testf})
    mkdir ${argsdir}/${testid}                    #Fuzzed args are saved here
    mkdir ${fuzzedtestscriptdir}/${testid}        #Fuzzed test scripts are saved here
    

    ### Generate the fuzz wrapper
    #The fuzz wrapper, upon execution, parses arguments and generates fuzzed test script.
    cd ${CURRDIR}
    if [ -f $PROGNAME ]; then
	rm $PROGNAME #Remove any previous binary
    fi
    if [ -f compilescript.sh ]; then
	rm compilescript.sh #Remove any previous script
    fi

    ${compilescriptgenbin} ${argsdir}/${testid} ${fuzzedtestscriptdir}/${testid} ${fuzznum} $PROGNAME ${fuzztestscriptgensrcf} >compilescript.sh
    chmod 700 compilescript.sh
    #============
    #cat compilescript.sh
    #============    
    ./compilescript.sh   #This generates the wrapper program named $PROGNAME
    rm compilescript.sh


    ### Execute the wrapper against test inputs（to generate fuzzed testscripts)
    BIN=${CURRDIR}/$PROGNAME
    cd $CURRDIR/tmp
    echo "${testf} $BIN $CURRDIR/tmp 10 ${indir}"
    ${testf} $BIN $CURRDIR/tmp 10 ${indir}
    chmod 755 -R $CURRDIR/tmp
    rm -fr $CURRDIR/tmp/*


#    ### Set up extra testing environment for make-3.79
#    CANCELED: Will handle this in upper layer
#    if [ $PROGNAME == "make-3.79" ]; then
#	target_cp_line=`grep 'cp -r -p' ${testf}`
#	target_cp_dir=`echo ${target_cp_line} | tr -s ' ' | cut -d' ' -f4 | cut -d'/' -f2`
#	sed -i "s|TIMEOUT=\$2|TIMEOUT=\$2\nOUTFILE=\$3\nCURRDIR=\$(pwd)\n\ncp -r -p ${DEBAUG_DIR}_expt/debaug/benchmark/make-3.79_template/input.origin/all/${target_cp_dir} ./sdir\ncd sdir|g" ${fuzzedtestscriptdir}/${testid}/*
#
#	for fuzzedfile in ${fuzzedtestscriptdir}/${testid}/*; do
#	    echo " &>\$OUTFILE" >>${fuzzedfile}
#	    echo "echo \$? >>\$OUTFILE" >>${fuzzedfile}
#	    echo "" >>${fuzzedfile}
#	    echo "if [ -f default.profraw ]; then" >>${fuzzedfile}
#	    echo "    mv default.profraw \${CURRDIR}/" >>${fuzzedfile}
#	    echo "fi" >>${fuzzedfile}
#	done
#    fi
    
done


cd ${CURRDIR}
#Backup newly generated args
if [ -d ${argsbackupdir} ]; then
    rm -fr ${argsbackupdir}
fi
cp -r ${argsdir} ${argsbackupdir}

#Chmod for newly generated test scripts
chmod -R 700 ${fuzzedtestscriptdir}
