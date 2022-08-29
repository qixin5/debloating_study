#!/bin/bash

for progname in bzip2-1.0.5 chown-8.2 date-8.21 grep-2.19 gzip-1.2.4 mkdir-5.2.1 rm-8.4 sort-8.16 tar-1.14 uniq-8.16; do

    ./run_prog.sh ${progname} util
done

for progname in bash-2.05 flex-2.5.4 grep-2.4.2 gzip-1.3 make-3.79 printtokens2 printtokens replace schedule2 schedule sed-4.1.5 space tcas totinfo vim-5.8; do

    ./run_prog.sh ${progname} sir
done
