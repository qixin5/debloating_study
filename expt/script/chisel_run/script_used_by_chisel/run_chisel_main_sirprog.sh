#!/bin/bash

######
#NOTE: This script should be copied to Chisel's working dir to execute.
######

PROGNAME=$1
inputset=$2

if [ -z ${PROGNAME} ] || [ -z ${inputset} ]; then
    echo "Missing arguments."
    exit 1
fi

CHISEL_BIN=${CHISEL_DIR}/build/bin/chisel
TIMEOUT=6h

if [ -d output.origin/${inputset} ]; then
    rm -fr output.origin/${inputset}
fi

logf=log_${inputset}.txt
>${logf}
start_time=$(date +%s.%N)

cp $PROGNAME.c.origin.c $PROGNAME.c
echo "#!/bin/bash" >test.sh
echo "" >>test.sh
echo "./testcore.sh $PROGNAME ${inputset}" >>test.sh
chmod 700 test.sh

rsltdir=chisel_out/${inputset}
if [ ! -d ${rsltdir} ]; then
    mkdir -p ${rsltdir}
else
   rm -fr ${rsltdir}/*
fi

timeout -k 9 ${TIMEOUT} ${CHISEL_BIN} -t ${rsltdir} -s ./test.sh $PROGNAME.c #Save temp
if [ -f $PROGNAME.c.chisel.c ]; then
    mv $PROGNAME.c.chisel.c ${rsltdir}
fi

end_time=$(date +%s.%N)
timedur=$(echo "${end_time} - ${start_time}" | bc)
echo "total time: ${timedur}s" &>>${logf}
avgtimedur=`echo "scale=0; ${timedur} / 1" | bc -l`
echo "avg time: ${avgtimedur}s" &>>${logf}
