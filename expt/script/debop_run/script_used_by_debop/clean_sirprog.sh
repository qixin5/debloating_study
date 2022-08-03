#!/bin/bash

PROGNAME=$1
inputset=$2

if [ -z ${PROGNAME} ] || [ -z ${inputset} ]; then
    echo "Missing arguments."
    exit 1
fi

rm -fr output/${inputset}
rm -fr output.origin/${inputset}
rm -fr input
rm -fr tmp
rm -fr $PROGNAME
rm -fr $PROGNAME.real.origin
rm -fr $PROGNAME.c
rm -fr $PROGNAME.c.origin.c
rm -fr $PROGNAME.c.real.origin.c.origin.c 
rm -fr debop-out.${inputset}.*
rm -fr chisel-out*
rm -fr debdcetmp
rm -fr log/${inputset}.*
rm -fr log/${inputset}_time.txt
rm -fr *.txt
rm -fr progcounter-out*
rm -fr testscript/*~
rm -fr *.dce.*
rm -fr test.sh

#Note: do NOT remove $PROGNAME.c.real.origin.c
#Note: do NOT remove cov/*.c
