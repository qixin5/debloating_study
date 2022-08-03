#!/bin/bash

INDIR=$1
OUTFILE=$2

if [ -f $INDIR/testdir/file3.gz ]
then
  cp $INDIR/testdir/file3.gz $OUTFILE || echo "$0:cp to output dir failed";
else
  cp $INDIR/testdir/file3.z $OUTFILE || echo "$0: cp to output dir failed";
fi

/home/qxin6/debaug_expt/debaug/benchmark/gzip-1.3_template/testscript/util/cleanup.sh $INDIR

