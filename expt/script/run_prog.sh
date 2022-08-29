#!/bin/bash

progname=$1
progtype=$2

if [ -z ${progname} ] || [ -z ${progtype} ]; then
    echo "Missing progname or progtype"
    exit 1
fi


if [ ${progtype} == "util" ]; then

    echo "Running debloating for ${progname}. Can take a few days to finish."

    for tool in chisel cov debop covf cova razor; do
	
	if [ ${tool} == "cova" ]; then

	    for thres in 1 2 3 4 5 10 15 20 25 30 35 40 45 50; do
		utilprog/main/run.sh ${progname} ${tool} ${thres}
	    done
	elif [ ${tool} == "razor" ]; then

	    for thres in 1 2 3 4; do
		utilprog/main/run.sh ${progname} ${tool} ${thres}
	    done
	else

	    utilprog/main/run.sh ${progname} ${tool} 
	fi
    done

elif [ ${progtype} == "sir" ]; then

    echo "Running debloating for ${progname}. Can take a few days to finish."
    
    for tool in chisel cov debop covf cova razor; do

	for inputset in n10train p0.1train p0.2train p0.3train; do

	    if [ ${inputset} == "n10train" ]; then
		testset=n10test

	    elif [ ${inputset} == "p0.1train" ]; then
		testset=p0.1test
		
	    elif [ ${inputset} == "p0.2train" ]; then
		testset=p0.2test		
		
	    elif [ ${inputset} == "p0.3train" ]; then
		testset=p0.3test
	    fi
	    

	    if [ ${tool} == "cova" ]; then
		
		for thres in 1 2 3 4 5 10 15 20 25 30 35 40 45 50; do
		    sirprog/main/run.sh ${progname} ${inputset} ${testset} ${tool} ${thres}
		done
	    elif [ ${tool} == "razor" ]; then
		
		for thres in 1 2 3 4; do
		    sirprog/main/run.sh ${progname} ${inputset} ${testset} ${tool} ${thres}
		done
	    else
		
		sirprog/main/run.sh ${progname} ${inputset} ${testset} ${tool}
	    fi
	done
    done
else

    echo "Unknown ${progtype}."
fi

    
#for progname in bzip2-1.0.5 chown-8.2 date-8.21 grep-2.19 gzip-1.2.4 mkdir-5.2.1 rm-8.4 sort-8.16 tar-1.14 uniq-8.16; do
