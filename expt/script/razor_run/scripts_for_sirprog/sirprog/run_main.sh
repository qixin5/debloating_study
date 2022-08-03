#!/bin/bash

#inputset=n10train
inputset=p0.3train

for progname in flex-2.5.4 grep-2.4.2 gzip-1.3 printtokens2 printtokens replace schedule2 schedule sed-4.1.5 space tcas totinfo; do

    echo ${progname}
    ./clean_sirprog.sh ${progname}
    screen ./train_and_debloat.sh ${progname} ${inputset}
    
done
