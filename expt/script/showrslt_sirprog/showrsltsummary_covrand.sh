#!/bin/bash

#Show result in reduction, generality, and f-score

BENCH=$1
PROGNAME=$2
progid=$3
inputid=$4
testid=$5
showinfo=$6
beta=$7      #gen is beta times as important as reduction


if [ -z $BENCH ] || [ -z $PROGNAME ] || [ -z ${progid} ] || [ -z ${inputid} ] || [ -z ${testid} ] || [ -z ${showinfo} ] || [ -z ${beta} ]; then
    echo "Missing arguments!"
    exit 1
fi

cd ../debaug/$BENCH/$PROGNAME || exit 1


origin_rsltfile=rslt/origin/p0.1test/rslt.txt  #Not a mistake
if [ ! -f ${origin_rsltfile} ]; then
    echo "Origin result file not found: ${rsltfile}"
    exit 1
fi

origin_stmtnum=`cat ${origin_rsltfile} | cut -d' ' -f1`
origin_bytenum0=`cat ${origin_rsltfile} | cut -d' ' -f2`
origin_gadgetnum0=`cat ${origin_rsltfile} | cut -d' ' -f3`
origin_bytenum1=`cat ${origin_rsltfile} | cut -d' ' -f4`
origin_gadgetnum1=`cat ${origin_rsltfile} | cut -d' ' -f5`


stmtnum=0
bytenum0=0
gadgetnum0=0 #No optimization
bytenum1=0
gadgetnum1=0 #O3
passrate=0
relpassrate=0
evalsetnum=0
inputsetnum=1


if [[ ${progid} == *randaug* ]]; then    #Handle random case

    trialnum=0
    for trial in {0..2}; do
	trialnum=$((trialnum + 1))
	rsltdir=rslt/reduced/${inputid}_${progid}/${trial}
	first_eval_of_trial=true

	evalsetnum=$((evalsetnum + 1))
	rsltfile=${rsltdir}/${testid}/rslt.txt
	if [ ! -f ${rsltfile} ]; then
	    echo "Result file not found: ${rsltfile}"
	    exit 1
	fi
	
	if [ ${first_eval_of_trial} == "true" ]; then
	    stmtnum_tmp=`cat ${rsltfile} | cut -d' ' -f1`
	    bytenum0_tmp=`cat ${rsltfile} | cut -d' ' -f2`
	    gadgetnum0_tmp=`cat ${rsltfile} | cut -d' ' -f3`
	    bytenum1_tmp=`cat ${rsltfile} | cut -d' ' -f4`
	    gadgetnum1_tmp=`cat ${rsltfile} | cut -d' ' -f5`
	    
	    stmtnum=$((stmtnum + stmtnum_tmp))
	    bytenum0=$((bytenum0 + bytenum0_tmp))
	    gadgetnum0=$((gadgetnum0 + gadgetnum0_tmp))
	    bytenum1=$((bytenum1 + bytenum1_tmp))
	    gadgetnum1=$((gadgetnum1 + gadgetnum1_tmp))
	    
	    first_eval_of_trial=false
	fi
	
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
    done
    
    #Average
    stmtnum=`echo "scale=8; ${stmtnum} / ${trialnum}" | bc -l` #Over trialnum
    bytenum0=`echo "scale=8; ${bytenum0} / ${trialnum}" | bc -l`
    gadgetnum0=`echo "scale=8; ${gadgetnum0} / ${trialnum}" | bc -l`
    bytenum1=`echo "scale=8; ${bytenum1} / ${trialnum}" | bc -l`
    gadgetnum1=`echo "scale=8; ${gadgetnum1} / ${trialnum}" | bc -l`
    passrate=`echo "scale=8; ${passrate} / ${evalsetnum}" | bc -l` #Over evalsetnum
    relpassrate=`echo "scale=8; ${relpassrate} / ${evalsetnum}" | bc -l` #Over evalsetnum

else

    echo "${progid} doesn't seem to be covrand."
    exit 1

fi


avgstmtnum=${stmtnum}
avgbytenum0=${bytenum0}
avggadgetnum0=${gadgetnum0}
avgbytenum1=${bytenum1}
avggadgetnum1=${gadgetnum1}
avgpassrate=${passrate}
avgrelpassrate=${relpassrate}


#Compute reduction, generality, and fscores
redstmt=`echo "scale=8; (${origin_stmtnum} - ${avgstmtnum}) / ${origin_stmtnum}" | bc -l`
redbyte0=`echo "scale=8; (${origin_bytenum0} - ${avgbytenum0}) / ${origin_bytenum0}" | bc -l`
redgdt0=`echo "scale=8; (${origin_gadgetnum0} - ${avggadgetnum0}) / ${origin_gadgetnum0}" | bc -l`
redbyte1=`echo "scale=8; (${origin_bytenum1} - ${avgbytenum1}) / ${origin_bytenum1}" | bc -l`
redgdt1=`echo "scale=8; (${origin_gadgetnum1} - ${avggadgetnum1}) / ${origin_gadgetnum1}" | bc -l`
gen=${avgpassrate}
relgen=${avgrelpassrate}

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


redstmtshow=`echo "scale=3; ${redstmt} / 1" | bc -l`
redbyte0show=`echo "scale=3; ${redbyte0} / 1" | bc -l`
redgdt0show=`echo "scale=3; ${redgdt0} / 1" | bc -l`
redbyte1show=`echo "scale=3; ${redbyte1} / 1" | bc -l`
redgdt1show=`echo "scale=3; ${redgdt1} / 1" | bc -l`
genshow=`echo "scale=3; ${gen} / 1" | bc -l`
relgenshow=`echo "scale=3; ${relgen} / 1" | bc -l`


if [ ${showinfo} == "stmt" ]; then
    echo "${PROGNAME} ${redstmtshow} ${relgenshow} ${relfstmt} ${genshow} ${fstmt}"
    
elif [ ${showinfo} == "byte0" ]; then #Binary no-optimization
    echo "${PROGNAME} ${redbyte0show} ${relgenshow} ${relfbyte0} ${genshow} ${fbyte0}"
    
elif [ ${showinfo} == "gdt0" ]; then
    echo "${PROGNAME} ${redgdt0show} ${relgenshow} ${relfgdt0} ${genshow} ${fgdt0}"	
    
elif [ ${showinfo} == "byte1" ]; then #Binary O3
    echo "${PROGNAME} ${redbyte1show} ${relgenshow} ${relfbyte1} ${genshow} ${fbyte1}"	
    
elif [ ${showinfo} == "gdt1" ]; then
    echo "${PROGNAME} ${redgdt1show} ${relgenshow} ${relfgdt1} ${genshow} ${fgdt1}"
    
fi
