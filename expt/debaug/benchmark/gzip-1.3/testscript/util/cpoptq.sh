#!/bin/bash

INDIR=$1
OUTFILE=$2

if [ -f $INDIR/testdir/file32.gz ]
then
  cp $INDIR/testdir/file32.gz $OUTFILE || echo "$0: cp to op dir failed";
else
  cp $INDIR/testdir/file32.z $OUTFILE || echo "$0: cp to op dir failed";
fi

$DEBSTUDY_DIR/expt/debaug/benchmark/gzip-1.3/testscript/util/cleanup.sh $INDIR
