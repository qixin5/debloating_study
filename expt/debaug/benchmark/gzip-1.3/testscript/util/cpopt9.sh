#!/bin/bash

INDIR=$1
OUTFILE=$2

if [ -f $INDIR/testdir/file22.gz ]
then
  cp $INDIR/testdir/file22.gz $OUTFILE
else
  cp $INDIR/testdir/file22.z $OUTFILE
fi

$DEBSTUDY_DIR/expt/debaug/benchmark/gzip-1.3/testscript/util/cleanup.sh $INDIR
