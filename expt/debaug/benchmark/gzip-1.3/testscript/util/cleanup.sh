#!/bin/bash

INDIR=$1

if [ -z $INDIR ]; then
    echo "Missing argument"
    exit 1
fi

rm -rf $INDIR
cp -r ~/debaug_expt/debaug/benchmark/gzip-1.3/input.origin/all $INDIR || { echo "$0: Cannot replenish inputs directory"; exit 1; }
chmod -R u+w $INDIR

chmod 000 $INDIR/testdir/nopermissionfile || { echo "$0: Cannot change permission for nopermissionfile"; exit 1; }
