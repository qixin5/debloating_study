#!/bin/bash

for progname in bash-2.05 flex-2.5.4 grep-2.4.2 gzip-1.3 make-3.79 printtokens2 printtokens replace schedule2 schedule sed-4.1.5 space tcas totinfo vim-5.8; do

    ./clean_sirprog.sh ${progname}
    
done
