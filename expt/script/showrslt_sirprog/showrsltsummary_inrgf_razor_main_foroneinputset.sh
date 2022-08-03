#!/bin/bash

#Show result in reduction, generality, and f-score

### PROGPATH ###
# origin, chisel, cov, covfuzzch, covfuzzall
# covfaugprflex5/10/20/50, covfaugrandombyfunc5/10/20/50
# covfuzzchfaugprflex5/10/20/50, covfuzzchfaugrandombyfunc5/10/20/50
# covfuzzallfaugprflex5/10/20/50, covfuzzallfaugrandombyfunc5/10/20/50
# covrandaugcovfuzzch, covrandaugcovfuzzall
# covrandaugcovfuzzchfaugprflex5/10/20/50, covrandaugcovfuzzallfaugprflex5/10/20/50


BENCH=$1
PROGNAME=$2
progpath=$3
showinfo=$4         #byte or gdt
beta=$5             #gen is beta times as important as reduction
inputset=$6


if [ -z $BENCH ] || [ -z $PROGNAME ] || [ -z ${progpath} ] || [ -z ${showinfo} ] || [ -z ${beta} ] || [ -z ${inputset} ]; then
    echo "Missing arguments!"
    exit 1
fi

cd ../debaug/$BENCH/$PROGNAME || exit 1


origin_rsltfile=razor_rslt/origin/I0/rslt.txt              #Only used for size comparison
if [ ! -f ${origin_rsltfile} ]; then
    origin_rsltfile=razor_rslt/origin/n10test/rslt.txt
fi
if [ ! -f ${origin_rsltfile} ]; then
    origin_rsltfile=razor_rslt/origin/p0.01test/rslt.txt
fi
if [ ! -f ${origin_rsltfile} ]; then
    origin_rsltfile=razor_rslt/origin/p0.1test/rslt.txt
fi
if [ ! -f ${origin_rsltfile} ]; then
    echo "No origin result from razor_rslt/origin/{I0|n10test|p0.01test|p0.1test}/rslt.txt."
    exit 1
fi


origin_bytenum0=`cat ${origin_rsltfile} | cut -d' ' -f1`
origin_gadgetnum0=`cat ${origin_rsltfile} | cut -d' ' -f2`


if [ ${progpath} == "origin" ]; then
    
    redbyte0=`echo "scale=3; 0/1" | bc -l`
    redgdt0=`echo "scale=3; 0/1" | bc -l`

    gen=`echo "scale=3; 1/1" | bc -l`
    relgen=`echo "scale=3; 1/1" | bc -l`

    fbyte0=`echo "scale=3; 0/1" | bc -l`
    relfbyte0=`echo "scale=3; 0/1" | bc -l`
    fgdt0=`echo "scale=3; 0/1" | bc -l`
    relfgdt0=`echo "scale=3; 0/1" | bc -l`


    if [ ${showinfo} == "byte0" ]; then
	echo "${progpath} ${redbyte0} ${relgen} ${relfbyte0} ${gen} ${fbyte0}"
	
    elif [ ${showinfo} == "gdt0" ]; then
	echo "${progpath} ${redgdt0} ${relgen} ${relfgdt0} ${gen} ${fgdt0}"

    fi

else

    bytenum0=0
    gadgetnum0=0 #No optimization
    passrate=0
    relpassrate=0
#    evalsetnum=0
#    inputsetnum=$((inputsetnum + 1))
    
	
    if [[ ${progpath} == *randaug* ]]; then
	echo "TODO: Write code to get results for random augmentation."
	
    else
	#Handle non-random cases
	rsltdir=razor_rslt/reduced/${progpath}
	
	rsltfile=${rsltdir}/${inputset}/rslt.txt
	if [ ! -f ${rsltfile} ]; then
	    echo "Result file not found: ${rsltfile} from debaug/$BENCH/$PROGNAME"
	    exit 1
	fi
	
	bytenum0=`cat ${rsltfile} | cut -d' ' -f1`
	gadgetnum0=`cat ${rsltfile} | cut -d' ' -f2`
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

    fi

    #Compute reduction and generality
    redbyte0=`echo "scale=8; (${origin_bytenum0} - ${bytenum0}) / ${origin_bytenum0}" | bc -l`
    redgdt0=`echo "scale=8; (${origin_gadgetnum0} - ${gadgetnum0}) / ${origin_gadgetnum0}" | bc -l`
    gen=${passrate}
    relgen=${relpassrate}

    #Compute f-scores
    fbyte0=`echo "scale=3; (1 + ${beta}*${beta})*${redbyte0}*${gen} / (${beta}*${beta}*${redbyte0} + ${gen})" | bc -l`
    fgdt0=`echo "scale=3; (1 + ${beta}*${beta})*${redgdt0}*${gen} / (${beta}*${beta}*${redgdt0} + ${gen})" | bc -l`

    relfbyte0=`echo "scale=3; (1 + ${beta}*${beta})*${redbyte0}*${relgen} / (${beta}*${beta}*${redbyte0} + ${relgen})" | bc -l`
    relfgdt0=`echo "scale=3; (1 + ${beta}*${beta})*${redgdt0}*${relgen} / (${beta}*${beta}*${redgdt0} + ${relgen})" | bc -l`
    

    #Round
    redbyte0show=`echo "scale=3; ${redbyte0} / 1" | bc -l`
    redgdt0show=`echo "scale=3; ${redgdt0} / 1" | bc -l`
    genshow=`echo "scale=3; ${gen} / 1" | bc -l`
    relgenshow=`echo "scale=3; ${relgen} / 1" | bc -l`


    #Print
    if [ ${showinfo} == "byte0" ]; then
	echo "$PROGNAME ${redbyte0show} ${relgenshow} ${relfbyte0} ${genshow} ${fbyte0}"
	
    elif [ ${showinfo} == "gdt0" ]; then
	echo "$PROGNAME ${redgdt0show} ${relgenshow} ${relfgdt0} ${genshow} ${fgdt0}"
    fi
fi
