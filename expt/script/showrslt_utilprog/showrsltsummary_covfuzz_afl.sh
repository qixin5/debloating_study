#!/bin/bash

BENCH=$1
PROGNAME=$2
showinfo=stmt
beta=1
ftype=all

for fuzztimeout in 1; do #In 1 minute
    ftype2=byfile
    if [ $PROGNAME == "mkdir-5.2.1" ] || [ $PROGNAME == "date-8.21" ]; then
	ftype2=bycmd
    fi

    fuzzid=aflfuzz${ftype}${fuzztimeout}m${ftype2}
    progid=cov${fuzzid}

    showrslt_utilprog/showrsltsummary_inrgf_main.sh $BENCH $PROGNAME ${progid} ${showinfo} ${beta}
done
