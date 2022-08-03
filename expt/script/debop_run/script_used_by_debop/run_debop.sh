#!/bin/bash

PROGNAME=$1

if [ -z $PROGNAME ]; then
    echo "Missing arguments!"
    exit 1
fi



DEBOP_BIN=${DEBOP_DIR}/build/bin/reducer
realorcov=$2
samplenum=$3
iternum=$4
alpha=$5
beta=$6
k=$7
version=$8
genfactor=$9
inputset=${10}

label=real
if [ "${realorcov}" -eq "1" ]; then
    label=real
    cp $PROGNAME.c.real.origin.c $PROGNAME.c.origin.c
else
    label=cov
    cp cov/${inputset}.c $PROGNAME.c.origin.c
fi
cp $PROGNAME.c.origin.c $PROGNAME.c


#Clean any previous origin's outputs
if [ -d output.origin/${inputset} ]; then
    rm -fr output.origin/${inputset}
fi


echo '#!/bin/bash' >test.sh
echo "" >>test.sh
echo "./testcore.sh $PROGNAME ${inputset}" >>test.sh
chmod 700 test.sh

rid=${inputset}.${label}.s${samplenum}.a${alpha}.b${beta}.k${k}.gf${genfactor}.v${version}
${DEBOP_BIN} -m ${samplenum} -i ${iternum} -t debop-out.${rid} -a ${alpha} -e ${beta} -k $k -z ${genfactor} -s ./test.sh ${PROGNAME}.c > log/${rid}.txt

rm test.sh
