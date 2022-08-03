#!/bin/bash

BENCH=$1
PROGNAME=$2
progpath=$3
testid=$4
force_to_run_origin=false

if [ -z $BENCH ] || [ -z $PROGNAME ] || [ -z ${progpath} ] || [ -z ${testid} ]; then
    echo "Missing arguments!"
    exit 1
fi

#Check if we need to run the original program on the tests
need_to_run_origin=false
if [ ${force_to_run_origin} == "true" ]; then
    need_to_run_origin=true
else
    origin_output_dir=../debaug/$BENCH/$PROGNAME/output_razor/origin/${testid}
    if [ ! -d ${origin_output_dir} ]; then
        need_to_run_origin=true
    elif [ -z "$(ls ${origin_output_dir})" ]; then
        need_to_run_origin=true
    fi
fi
if [ $PROGNAME == "date-8.21" ] || [ $PROGNAME == "mkdir-5.2.1" ]; then
    need_to_run_origin=true
fi





#Run tests
if [ ${need_to_run_origin} == "true" ]; then
    test/run_test_razor.sh $BENCH $PROGNAME origin ${testid}
fi
test/run_test_razor.sh $BENCH $PROGNAME ${progpath} ${testid}


cd ../debaug/$BENCH/$PROGNAME || exit 1

#Compare outputs
>compare_rslt.txt

for output_f1 in ./output_razor/origin/${testid}/*; do
    fname=$(basename ${output_f1})
    if [ ${progpath} == "origin" ]; then
	echo "pass-${fname}" >>compare_rslt.txt
    else
	if diff -q ${output_f1} ./output_razor/reduced/${progpath}/${testid}/${fname} &>/dev/null; then
            echo "pass-${fname}" >>compare_rslt.txt
	else
            echo "fail-${fname}" >>compare_rslt.txt
	fi
    fi
done


