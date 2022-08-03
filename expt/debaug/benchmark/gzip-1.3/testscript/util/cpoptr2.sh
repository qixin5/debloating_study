#!/bin/bash

INDIR=$1
OUTFILE=$2

cp $INDIR/testdir/subdir3/file $OUTFILE

/home/qxin6/debaug_expt/debaug/benchmark/gzip-1.3_template/testscript/util/cleanup.sh $INDIR
