#!/bin/bash

INDIR=$1
OUTFILE=$2

if [ -f $INDIR/testdir/file11.gz ]
then
  cp $INDIR/testdir/file11.gz $OUTFILE
else
  cp $INDIR/testdir/file11.z $OUTFILE
fi

/home/qxin6/debaug_expt/debaug/benchmark/gzip-1.3_template/testscript/util/cleanup.sh $INDIR
