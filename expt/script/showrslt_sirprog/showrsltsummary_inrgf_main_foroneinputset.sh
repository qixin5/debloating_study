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
showinfo=$4         #stmt, byte0, gdt0, byte1, gdt1
beta=$5             #gen is beta times as important as reduction
inputset=$6


if [ -z $BENCH ] || [ -z $PROGNAME ] || [ -z ${progpath} ] || [ -z ${showinfo} ] || [ -z ${beta} ]
then
    echo "Missing arguments!"
    exit 1
fi

cd ../debaug/$BENCH/$PROGNAME || exit 1


origin_rsltfile=rslt/origin/I0/rslt.txt              #Only used for size comparison
if [ ! -f ${origin_rsltfile} ]; then
    origin_rsltfile=rslt/origin/n10test/rslt.txt
fi
if [ ! -f ${origin_rsltfile} ]; then
    origin_rsltfile=rslt/origin/p0.01test/rslt.txt
fi
if [ ! -f ${origin_rsltfile} ]; then
    origin_rsltfile=rslt/origin/p0.1test/rslt.txt
fi
if [ ! -f ${origin_rsltfile} ]; then
    echo "No origin result from rslt/origin/{I0|n10test|p0.01test|p0.1test}/rslt.txt."
    exit 1
fi

origin_stmtnum=`cat ${origin_rsltfile} | cut -d' ' -f1`
origin_bytenum0=`cat ${origin_rsltfile} | cut -d' ' -f2`
origin_gadgetnum0=`cat ${origin_rsltfile} | cut -d' ' -f3`
origin_bytenum1=`cat ${origin_rsltfile} | cut -d' ' -f4`
origin_gadgetnum1=`cat ${origin_rsltfile} | cut -d' ' -f5`


if [ ${progpath} == "origin" ]; then
    
    redstmt=`echo "scale=3; 0/1" | bc -l`
    redbyte0=`echo "scale=3; 0/1" | bc -l`
    redgdt0=`echo "scale=3; 0/1" | bc -l`
    redbyte1=`echo "scale=3; 0/1" | bc -l`
    redgdt1=`echo "scale=3; 0/1" | bc -l`

    gen=`echo "scale=3; 1/1" | bc -l`
    relgen=`echo "scale=3; 1/1" | bc -l`

    fstmt=`echo "scale=3; 0/1" | bc -l`
    relfstmt=`echo "scale=3; 0/1" | bc -l`
    fbyte0=`echo "scale=3; 0/1" | bc -l`
    relfbyte0=`echo "scale=3; 0/1" | bc -l`
    fgdt0=`echo "scale=3; 0/1" | bc -l`
    relfgdt0=`echo "scale=3; 0/1" | bc -l`
    fbyte1=`echo "scale=3; 0/1" | bc -l`
    relfbyte1=`echo "scale=3; 0/1" | bc -l`
    fgdt1=`echo "scale=3; 0/1" | bc -l`
    relfgdt1=`echo "scale=3; 0/1" | bc -l`


    if [ ${showinfo} == "stmt" ]; then
	echo "${progpath} ${redstmt} ${relgen} ${relfstmt} ${gen} ${fstmt}"

    elif [ ${showinfo} == "byte0" ]; then
	echo "${progpath} ${redbyte0} ${relgen} ${relfbyte0} ${gen} ${fbyte0}"
	
    elif [ ${showinfo} == "gdt0" ]; then
	echo "${progpath} ${redgdt0} ${relgen} ${relfgdt0} ${gen} ${fgdt0}"

    elif [ ${showinfo} == "byte1" ]; then
	echo "${progpath} ${redbyte1} ${relgen} ${relfbyte1} ${gen} ${fbyte1}"
	
    elif [ ${showinfo} == "gdt1" ]; then
	echo "${progpath} ${redgdt1} ${relgen} ${relfgdt1} ${gen} ${fgdt1}"
    fi

else

    stmtnum=0
    bytenum0=0
    gadgetnum0=0 #No optimization
    bytenum1=0
    gadgetnum1=0 #O3
    passrate=0
    relpassrate=0
#    evalsetnum=0
#    inputsetnum=$((inputsetnum + 1))
    
	
    if [[ ${progpath} == *randaug* ]]; then
	echo "TODO: Write code to get results for random augmentation."
	
    else
	#Handle non-random cases
	rsltdir=rslt/reduced/${progpath}
	
	rsltfile=${rsltdir}/${inputset}/rslt.txt
	if [ ! -f ${rsltfile} ]; then
	    echo "Result file not found: ${rsltfile}"
	    exit 1
	fi

	stmtnum=`cat ${rsltfile} | cut -d' ' -f1`
	bytenum0=`cat ${rsltfile} | cut -d' ' -f2`
	gadgetnum0=`cat ${rsltfile} | cut -d' ' -f3`
	bytenum1=`cat ${rsltfile} | cut -d' ' -f4`
	gadgetnum1=`cat ${rsltfile} | cut -d' ' -f5`
	passnum=`cat ${rsltfile} | cut -d' ' -f6`
	totalnum=`cat ${rsltfile} | cut -d' ' -f7`
	relpassnum=`cat ${rsltfile} | cut -d' ' -f8`
	reltotalnum=`cat ${rsltfile} | cut -d' ' -f9`
	passrate=`echo "scale=8; ${passrate} + (${passnum} / ${totalnum})" | bc -l`
	if [ ${reltotalnum} == "0" ]; then
	    relpassrate=`echo "scale=8; ${relpassrate} + 1" | bc -l`
        else
            relpassrate=`echo "scale=8; ${relpassrate} + (${relpassnum} / ${reltotalnum})" | bc -l`
	fi

	#echo "Stmtnum: ${stmtnum}"
	#echo "Bytenum0: ${bytenum0}"
	#echo "Gdtnum0: ${gadgetnum0}"
	#echo "Bytenum1: ${bytenum1}"
	#echo "gadgetnum1: ${gadgetnum1}"
	#echo "Passnum: ${passnum}"
	#echo "Totalnum: ${totalnum}"
	#echo "Relpassnum: ${relpassnum}"
	#echo "Reltotalnum: ${reltotalnum}"
	#echo "Passrate: ${passrate}"
	#echo "RelPassrate: ${relpassrate}"
    fi

    #Compute reduction and generality
    redstmt=`echo "scale=8; (${origin_stmtnum} - ${stmtnum}) / ${origin_stmtnum}" | bc -l`
    redbyte0=`echo "scale=8; (${origin_bytenum0} - ${bytenum0}) / ${origin_bytenum0}" | bc -l`
    redgdt0=`echo "scale=8; (${origin_gadgetnum0} - ${gadgetnum0}) / ${origin_gadgetnum0}" | bc -l`
    redbyte1=`echo "scale=8; (${origin_bytenum1} - ${bytenum1}) / ${origin_bytenum1}" | bc -l`
    redgdt1=`echo "scale=8; (${origin_gadgetnum1} - ${gadgetnum1}) / ${origin_gadgetnum1}" | bc -l`
    gen=${passrate}
    relgen=${relpassrate}


    #Compute f-scores
    fstmt=`echo "scale=3; (1 + ${beta}*${beta})*${redstmt}*${gen} / (${beta}*${beta}*${redstmt} + ${gen})" | bc -l`
    fbyte0=`echo "scale=3; (1 + ${beta}*${beta})*${redbyte0}*${gen} / (${beta}*${beta}*${redbyte0} + ${gen})" | bc -l`
    fgdt0=`echo "scale=3; (1 + ${beta}*${beta})*${redgdt0}*${gen} / (${beta}*${beta}*${redgdt0} + ${gen})" | bc -l`
    fbyte1=`echo "scale=3; (1 + ${beta}*${beta})*${redbyte1}*${gen} / (${beta}*${beta}*${redbyte1} + ${gen})" | bc -l`
    fgdt1=`echo "scale=3; (1 + ${beta}*${beta})*${redgdt1}*${gen} / (${beta}*${beta}*${redgdt1} + ${gen})" | bc -l`

    relfstmt=`echo "scale=3; (1 + ${beta}*${beta})*${redstmt}*${relgen} / (${beta}*${beta}*${redstmt} + ${relgen})" | bc -l`
    relfbyte0=`echo "scale=3; (1 + ${beta}*${beta})*${redbyte0}*${relgen} / (${beta}*${beta}*${redbyte0} + ${relgen})" | bc -l`
    relfgdt0=`echo "scale=3; (1 + ${beta}*${beta})*${redgdt0}*${relgen} / (${beta}*${beta}*${redgdt0} + ${relgen})" | bc -l`
    relfbyte1=`echo "scale=3; (1 + ${beta}*${beta})*${redbyte1}*${relgen} / (${beta}*${beta}*${redbyte1} + ${relgen})" | bc -l`
    relfgdt1=`echo "scale=3; (1 + ${beta}*${beta})*${redgdt1}*${relgen} / (${beta}*${beta}*${redgdt1} + ${relgen})" | bc -l`
    

    #Round
    redstmtshow=`echo "scale=3; ${redstmt} / 1" | bc -l`
    redbyte0show=`echo "scale=3; ${redbyte0} / 1" | bc -l`
    redgdt0show=`echo "scale=3; ${redgdt0} / 1" | bc -l`
    redbyte1show=`echo "scale=3; ${redbyte1} / 1" | bc -l`
    redgdt1show=`echo "scale=3; ${redgdt1} / 1" | bc -l`
    genshow=`echo "scale=3; ${gen} / 1" | bc -l`
    relgenshow=`echo "scale=3; ${relgen} / 1" | bc -l`


    #Print
    if [ ${showinfo} == "stmt" ]; then
	echo "$PROGNAME ${redstmtshow} ${relgenshow} ${relfstmt} ${genshow} ${fstmt}"

    elif [ ${showinfo} == "byte0" ]; then
	echo "$PROGNAME ${redbyte0show} ${relgenshow} ${relfbyte0} ${genshow} ${fbyte0}"
	
    elif [ ${showinfo} == "gdt0" ]; then
	echo "$PROGNAME ${redgdt0show} ${relgenshow} ${relfgdt0} ${genshow} ${fgdt0}"

    elif [ ${showinfo} == "byte1" ]; then
	echo "$PROGNAME ${redbyte1show} ${relgenshow} ${relfbyte1} ${genshow} ${fbyte1}"
	
    elif [ ${showinfo} == "gdt1" ]; then
	echo "$PROGNAME ${redgdt1show} ${relgenshow} ${relfgdt1} ${genshow} ${fgdt1}"
    fi
fi
