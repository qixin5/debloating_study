#!/bin/bash

for progname in bzip2-1.0.5 chown-8.2 date-8.21 grep-2.19 gzip-1.2.4 mkdir-5.2.1 rm-8.4 sort-8.16 tar-1.14 uniq-8.16; do
    ./copy_templates_to_workdirs.sh benchmark ${progname}
done
