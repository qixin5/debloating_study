#!/bin/bash

INDIR=$1
OUTFILE=$2

cp $INDIR/testdir/subdir2/file $OUTFILE

$DEBSTUDY_DIR/expt/debaug/benchmark/gzip-1.3/testscript/util/cleanup.sh $INDIR
