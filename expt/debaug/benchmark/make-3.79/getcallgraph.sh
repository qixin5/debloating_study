#!/bin/bash

SRC=$1

libglob_path=/home/qxin6/debaug_expt/debaug/benchmark/make-3.79_template/lib/libglob.a

clang -S -emit-llvm $SRC -w -o - ${libglob_path} -lutil | opt -analyze -dot-callgraph
