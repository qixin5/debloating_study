#!/bin/bash

for i in {1..7}; do
    for j in {1..20}; do
	if [ -d ${i}/${i}.${j} ]; then
	    cp ${i}/${i}.${j}/*.expect all_expect_files/
	fi
    done
done
