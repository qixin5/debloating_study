#!/bin/bash

######
#NOTE: This script should be copied to Debop's working dir to execute.
######

PROGNAME=$1
inputset=$2
TIMEOUT=10

if [ -z ${PROGNAME} ] || [ -z ${inputset} ]; then
    echo "Missing arguments."
    exit 1
fi

GDTBIN="python ${ROPGDT_DIR}/ROPgadget.py"
CHISELBIN="${CHISEL_DIR}/build/bin/chisel"
DEBDCEBIN="${DEBAUG_DIR}/bin/debdce"  #Do NOT use ${DEBAUG_DIR}/build/bin/debde!

CURRDIR=$(pwd)
SRC=$CURRDIR/$PROGNAME.c
BIN=$CURRDIR/$PROGNAME
OUTDIR=$CURRDIR/output/${inputset}
ORIGIN_SRC=$CURRDIR/$PROGNAME.c.real.origin.c
ORIGIN_BIN=$CURRDIR/$PROGNAME.real.origin
ORIGIN_OUTDIR=$CURRDIR/output.origin/${inputset}
DCESRC=$CURRDIR/$PROGNAME.dce.c


#Reset file content (original #stmts; reduced #stmts; original gadgets; reduced gadgets; total tests; passed tests)
echo "-1" > eval_rslt.txt
echo "-1" >> eval_rslt.txt
echo "-1" >> eval_rslt.txt
echo "-1" >> eval_rslt.txt
echo "-1" >> eval_rslt.txt
echo "-1" >> eval_rslt.txt


#Generate Oracle Bin
if [ ! -f ${ORIGIN_BIN} ]; then
    ./compile ${ORIGIN_SRC} ${ORIGIN_BIN}
fi
#Generate Oracle Outputs
if [ ! -d ${ORIGIN_OUTDIR} ]; then
    mkdir -p ${ORIGIN_OUTDIR}
    ./compile ${ORIGIN_SRC} ${BIN}    #NOTE: Do NOT use ORIGIN_BIN for this line and next line!
    ./run_test.sh ${BIN} ${ORIGIN_OUTDIR} $TIMEOUT ${inputset} $PROGNAME
    rm ${BIN}
fi 


#Get Program with DCE (dead code eliminated)
if [ -f ${DCESRC} ]; then
    rm ${DCESRC}
fi
${DEBDCEBIN} $SRC ${DCESRC}

#Compile Reduced Program
./compile ${DCESRC} $BIN || exit 1


#Get sizes
original_size=-1
if [ -f ${CURRDIR}/original_stmt_num.txt ]; then
    original_size=`head -n 1 ${CURRDIR}/original_stmt_num.txt`
else
    original_size=`${CHISELBIN} -S ${ORIGIN_SRC} | tail -1 | cut -d' ' -f4`
    echo ${original_size} >${CURRDIR}/original_stmt_num.txt
fi
reduced_size=`${CHISELBIN} -S ${DCESRC} | tail -1 | cut -d' ' -f4`


#Get gadgets
original_gdt=`${GDTBIN} --binary ${ORIGIN_BIN} | grep 'Unique gadgets' | cut -d' ' -f4`
reduced_gdt=`${GDTBIN} --binary ${BIN} | grep 'Unique gadgets' | cut -d' ' -f4`


#Get generality
./run_test.sh $BIN $OUTDIR $TIMEOUT ${inputset} $PROGNAME
> $CURRDIR/compare.txt
for output_f1 in ${ORIGIN_OUTDIR}/*; do
    fname=$(basename ${output_f1})
    if diff -q ${output_f1} ${OUTDIR}/${fname} &> ./difftmp; then
        echo "pass-${fname}" >> $CURRDIR/compare.txt
    else
        echo "fail-${fname}" >> $CURRDIR/compare.txt
    fi
done
rm difftmp
pass_all=`grep 'pass-' $CURRDIR/compare.txt | wc -l`
total_all=$(ls $CURRDIR/testscript/${inputset} | wc -l) #total kn inputs
rm $CURRDIR/compare.txt


#Output to file
echo "${original_size}" > eval_rslt.txt
echo "${reduced_size}" >> eval_rslt.txt
echo "${original_gdt}" >> eval_rslt.txt
echo "${reduced_gdt}" >> eval_rslt.txt
echo "${total_all}" >> eval_rslt.txt
echo "${pass_all}" >> eval_rslt.txt
