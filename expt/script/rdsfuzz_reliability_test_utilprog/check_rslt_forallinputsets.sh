#!/bin/bash

BENCH=$1
PROGNAME=$2
srcid=$3
forrazor=$4


if [ -z $BENCH ] || [ -z $PROGNAME ] || [ -z ${srcid} ]; then
    echo "Missing arguments."
    exit 1
fi

if [ -z ${forrazor} ]; then
    forrazor=false
fi

cd ../debaug/$BENCH/$PROGNAME/rdsfuzz/robust_testing || exit 1

CURRDIR=$(pwd)

crash_inputs=0
hang_inputs=0
crash_or_hang_inputs=0
total_inputs=0

crash_execs=0
hang_execs=0
crash_or_hang_execs=0
total_execs=0


for inputset in I0 I1 I2 I3 I4 I5 I6 I7 I8 I9; do

if [ ${srcid} == "origin" ]; then
    if [ ${forrazor} == "true" ]; then
	outrootdir=output_razor/origin/${inputset}
    else
	outrootdir=output/origin/${inputset}
    fi

else
    progpath=${inputset}_${srcid}
    if [ ${forrazor} == "true" ]; then
	outrootdir=output_razor/reduced/${progpath}/${inputset}
    else
	outrootdir=output/reduced/${progpath}/${inputset}
    fi
fi


for inputdir in ${outrootdir}/*; do

    total_inputs=$((total_inputs+1))
    input_crash=false
    input_hang=false
    input_crash_or_hang=false

    for fuzzfile in ${inputdir}/*; do
	total_execs=$((total_execs+1))
	exec_crash_or_hang=false

	exit_code=`tail -1 ${fuzzfile}`
	#=========
	#echo ${exit_code}
	#=========

#	if `grep -q "Floating point exception" ${fuzzfile}`; then
#	    input_crash=true
#	    input_crash_or_hang=true
#	    exec_crash_or_hang=true
#	    crash_execs=$((crash_execs+1))
#	    
#	elif `grep -q "Segmentation fault" ${fuzzfile}`; then
#	    input_crash=true
#	    input_crash_or_hang=true
#	    exec_crash_or_hang=true
#	    crash_execs=$((crash_execs+1))
#	fi

	if [ "${exit_code}" == "131" ] || [ "${exit_code}" == "132" ] || [ "${exit_code}" == "133" ] || [ "${exit_code}" == "134" ] || [ "${exit_code}" == "135" ] || [ "${exit_code}" == "136" ] || [ "${exit_code}" == "139" ]; then
	    input_crash=true
            input_crash_or_hang=true
            exec_crash_or_hang=true
            crash_execs=$((crash_execs+1))
	fi	

	if [ "${exit_code}" == "124" ]; then
	    input_hang=true
	    input_crash_or_hang=true
	    exec_crash_or_hang=true
	    hang_execs=$((hang_execs+1))
	fi

	if [ ${exec_crash_or_hang} == "true" ]; then
	    crash_or_hang_execs=$((crash_or_hang_execs+1))
	fi
    done

    if [ ${input_crash} == "true" ]; then
	crash_inputs=$((crash_inputs+1))
    fi
    if [ ${input_hang} == "true" ]; then
	hang_inputs=$((hang_inputs+1))
    fi
    if [ ${input_crash_or_hang} == "true" ]; then
	crash_or_hang_inputs=$((crash_or_hang_inputs+1))
    fi
    
done

done

echo $PROGNAME ${crash_inputs} ${hang_inputs} ${crash_or_hang_inputs} ${total_inputs} ${crash_execs} ${hang_execs} ${crash_or_hang_execs} ${total_execs}

input_crash_rate=`echo "scale=3; ${crash_inputs} / ${total_inputs}" | bc -l`
input_hang_rate=`echo "scale=3; ${hang_inputs} / ${total_inputs}" | bc -l`
input_crash_or_hang_rate=`echo "scale=3; ${crash_or_hang_inputs} / ${total_inputs}" | bc -l`

exec_crash_rate=`echo "scale=3; ${crash_execs} / ${total_execs}" | bc -l`
exec_hang_rate=`echo "scale=3; ${hang_execs} / ${total_execs}" | bc -l`
exec_crash_or_hang_rate=`echo "scale=3; ${crash_or_hang_execs} / ${total_execs}" | bc -l`

echo $PROGNAME ${input_crash_rate} ${input_hang_rate} ${input_crash_or_hang_rate} ${exec_crash_rate} ${exec_hang_rate} ${exec_crash_or_hang_rate}


