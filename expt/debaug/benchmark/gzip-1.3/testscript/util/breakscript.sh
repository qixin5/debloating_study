#!/bin/sh
#*********************************************#
# This is a test to kill a process            #
#*********************************************#

INDIR=$1
OUTFILE=$2

echo
echo "Run break control"
echo

currentdir=`pwd`
user=`whoami`
cd
echo "`ps -u ${user} | grep allfile | awk '{print $1}'`"
pskill=`ps -u ${user} | grep allfile* | awk '{print $1}'`
echo $pskill
sleep 3
kill -9 $pskill

cp $INDIR/testdir/binaryfile1* $OUTFILE
/home/qxin6/debaug_expt/debaug/benchmark/gzip-1.3_template/testscript/util/cleanup.sh $INDIR

cd $currentdir

echo
echo "Exit break control!"
echo

exit 0
