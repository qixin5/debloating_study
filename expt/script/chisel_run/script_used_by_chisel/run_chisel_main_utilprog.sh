#!/bin/bash

######
#NOTE: This script should be copied to Chisel's working dir to execute.
######

PROGNAME=$1

if [ -z ${PROGNAME} ]; then
    echo "Missing arguments."
    exit 1
fi


CHISEL_BIN=${CHISEL_DIR}/build/bin/chisel
TIMEOUT=6h

if [ -d output.origin ]; then
    rm -fr output.origin
fi

logf=log.txt
>${logf}
start_time=$(date +%s.%N)
last_time=${start_time}
inputsets=0

for inputset in I0 I1 I2 I3 I4 I5 I6 I7 I8 I9; do
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
    timedur=$(echo "${end_time} - ${last_time}" | bc)
    echo "${inputset} time: ${timedur}s" &>>${logf}
    last_time=${end_time}
    inputsets=$((inputsets + 1))
done

end_time=$(date +%s.%N)
timedur=$(echo "${end_time} - ${start_time}" | bc)
echo "total time: ${timedur}s" &>>${logf}
avgtimedur=`echo "scale=0; ${timedur} / ${inputsets}" | bc -l`
echo "avg time: ${avgtimedur}s" &>>${logf}
