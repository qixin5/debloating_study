#!/bin/bash

INDIR=$1
OUTFILE=$2

mv $INDIR/gzdir/file9 $OUTFILE

/home/qxin6/debaug_expt/debaug/benchmark/gzip-1.3_template/testscript/util/cleanup.sh $INDIR
