#!/bin/bash

for progname in bzip2-1.0.5 chown-8.2 date-8.21 grep-2.19 gzip-1.2.4 mkdir-5.2.1 rm-8.4 sort-8.16 tar-1.14 uniq-8.16; do
    logdir=../log/benchmark/${progname}
    logf=${logdir}/getprog_covaug_h4.txt
    if [ ! -d ${logdir} ]; then
        mkdir -p ${logdir}
    fi
    
    echo "${progname}" &>${logf}
    ./getprog_covaug_and_copy_rslt_main_forallinputsets.sh benchmark ${progname} 4 &>>${logf}
done
