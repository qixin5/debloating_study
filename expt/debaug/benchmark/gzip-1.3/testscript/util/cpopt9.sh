#!/bin/bash

INDIR=$1
OUTFILE=$2

if [ -f $INDIR/testdir/file22.gz ]
then
  cp $INDIR/testdir/file22.gz $OUTFILE
else
  cp $INDIR/testdir/file22.z $OUTFILE
fi

/home/qxin6/debaug_expt/debaug/benchmark/gzip-1.3_template/testscript/util/cleanup.sh $INDIR
