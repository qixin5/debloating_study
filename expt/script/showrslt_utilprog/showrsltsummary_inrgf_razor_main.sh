#!/bin/bash

BENCH=$1
PROGNAME=$2
progid=$3
showinfo=$4
beta=$5

if [ -z $BENCH ] || [ -z $PROGNAME ] || [ -z ${progid} ] || [ -z ${showinfo} ] || [ -z ${beta} ]; then
    echo "Missing arguments!"
    exit 1
fi

cd ../debaug/$BENCH/$PROGNAME || exit 1


origin_rsltfile=razor_rslt/origin/I0/rslt.txt #Only I0 is enough
if [ ! -f ${origin_rsltfile} ]; then
    echo "Missing the origin result file: ${origin_rsltfile}."
    exit 1
fi

origin_bytenum=`cat ${origin_rsltfile} | cut -d' ' -f1`
origin_gadgetnum=`cat ${origin_rsltfile} | cut -d' ' -f2`


if [ ${progid} == "origin" ]; then

    redbyte0=`echo "scale=3; 0/1" | bc -l`
    redgdt0=`echo "scale=3; 0/1" | bc -l`

    gen=`echo "scale=3; 1/1" | bc -l`
    relgen=`echo "scale=3; 1/1" | bc -l`
    
    fbyte0=`echo "scale=3; 0/1" | bc -l`
    relfbyte0=`echo "scale=3; 0/1" | bc -l`
    fgdt0=`echo "scale=3; 0/1" | bc -l`
    relfgdt0=`echo "scale=3; 0/1" | bc -l`
    

    if [ ${showinfo} == "byte0" ]; then
	echo "razor_${progid} ${redbyte0} ${relgen} ${relfbyte0} ${gen} ${fbyte0}"

    elif [ ${showinfo} == "gdt0" ]; then
	echo "razor_${progid} ${redgdt0} ${relgen} ${relfgdt0} ${gen} ${fgdt0}"
	
    fi

else

    totalbytenum=0
    totalgadgetnum=0
    totalpassrate=0
    totalrelpassrate=0
    inputsetnum=0

    for inputid in I0 I1 I2 I3 I4 I5 I6 I7 I8 I9; do
	bytenum=0
	gadgetnum=0
	passrate=0
	relpassrate=0
	evalsetnum=0
	inputsetnum=$((inputsetnum + 1))

	rsltdir=razor_rslt/reduced/${inputid}_${progid}
	first_eval=true
	
	for testid in I0 I1 I2 I3 I4 I5 I6 I7 I8 I9; do
	    if [ ${inputid} == ${testid} ]; then  #Cross-validation Only
		continue
	    fi

	    evalsetnum=$((evalsetnum + 1))
	    rsltfile=${rsltdir}/${testid}/rslt.txt
	    
	    if [ ${first_eval} == "true" ]; then
		bytenum=`cat ${rsltfile} | cut -d' ' -f1`
		gadgetnum=`cat ${rsltfile} | cut -d' ' -f2`
		first_eval=false
	    fi
	    
	    passnum=`cat ${rsltfile} | cut -d' ' -f3`
	    totalnum=`cat ${rsltfile} | cut -d' ' -f4`
	    relpassnum=`cat ${rsltfile} | cut -d' ' -f5`
            reltotalnum=`cat ${rsltfile} | cut -d' ' -f6`
	    passrate=`echo "scale=8; ${passrate} + (${passnum} / ${totalnum})" | bc -l`
	    if [ ${reltotalnum} == "0" ]; then
		relpassrate=`echo "scale=8; ${relpassrate} + 1" | bc -l`
            else
                relpassrate=`echo "scale=8; ${relpassrate} + (${relpassnum} / ${reltotalnum})" | bc -l`
            fi
	done
	
	#Average
	passrate=`echo "scale=8; ${passrate} / ${evalsetnum}" | bc -l` #Over evalsetnum
	relpassrate=`echo "scale=8; ${relpassrate} / ${evalsetnum}" | bc -l` #Over evalsetnum

	#Sum over individual input sets
	totalbytenum=`echo "scale=8; ${totalbytenum} + ${bytenum}" | bc -l`
	totalgadgetnum=`echo "scale=8; ${totalgadgetnum} + ${gadgetnum}" | bc -l`
	totalpassrate=`echo "scale=8; ${totalpassrate} + ${passrate}" | bc -l`
	totalrelpassrate=`echo "scale=8; ${totalrelpassrate} + ${relpassrate}" | bc -l`
    done

    avgbytenum=`echo "scale=8; ${totalbytenum} / ${inputsetnum}" | bc -l`
    avggadgetnum=`echo "scale=8; ${totalgadgetnum} / ${inputsetnum}" | bc -l`
    avgpassrate=`echo "scale=8; ${totalpassrate} / ${inputsetnum}" | bc -l`
    avgrelpassrate=`echo "scale=8; ${totalrelpassrate} / ${inputsetnum}" | bc -l`


    #Compute reduction, generality, and fscores
    redbyte0=`echo "scale=8; (${origin_bytenum} - ${avgbytenum}) / ${origin_bytenum}" | bc -l`
    redgdt0=`echo "scale=8; (${origin_gadgetnum} - ${avggadgetnum}) / ${origin_gadgetnum}" | bc -l`

    gen=${avgpassrate}
    relgen=${avgrelpassrate}

    fbyte0=`echo "scale=3; (1 + ${beta}*${beta})*${redbyte0}*${gen} / (${beta}*${beta}*${redbyte0} + ${gen})" | bc -l`
    fgdt0=`echo "scale=3; (1 + ${beta}*${beta})*${redgdt0}*${gen} / (${beta}*${beta}*${redgdt0} + ${gen})" | bc -l`

    relfbyte0=`echo "scale=3; (1 + ${beta}*${beta})*${redbyte0}*${relgen} / (${beta}*${beta}*${redbyte0} + ${relgen})" | bc -l`
    relfgdt0=`echo "scale=3; (1 + ${beta}*${beta})*${redgdt0}*${relgen} / (${beta}*${beta}*${redgdt0} + ${relgen})" | bc -l`


    redbyte0show=`echo "scale=3; ${redbyte0} / 1" | bc -l`
    redgdt0show=`echo "scale=3; ${redgdt0} / 1" | bc -l`
    genshow=`echo "scale=3; ${gen} / 1" | bc -l`
    relgenshow=`echo "scale=3; ${relgen} / 1" | bc -l`
    
    
    if [ ${showinfo} == "byte0" ]; then
        echo "$PROGNAME ${redbyte0show} ${relgenshow} ${relfbyte0} ${genshow} ${fbyte0}"

    elif [ ${showinfo} == "gdt0" ]; then
        echo "$PROGNAME ${redgdt0show} ${relgenshow} ${relfgdt0} ${genshow} ${fgdt0}"
	
    fi
    
fi
