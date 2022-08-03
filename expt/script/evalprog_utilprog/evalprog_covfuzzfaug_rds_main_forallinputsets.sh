#!/bin/bash

BENCH=$1
PROGNAME=$2
fuzznum=$3
selecthreshold=$4

fuzzid=rdsfuzzn${fuzznum}
progid=cov${fuzzid}faugrutilfreqflexp${selecthreshold}

evalprog_utilprog/evalprog_main_forallinputsets.sh $BENCH $PROGNAME ${progid}
