#!/bin/bash

INDIR=$1
OUTFILE=$2

mv $INDIR/gzdir/file9 $OUTFILE

$DEBSTUDY_DIR/expt/debaug/benchmark/gzip-1.3/testscript/util/cleanup.sh $INDIR
