#!/bin/bash

SRC=$1

clang -S -emit-llvm -L/home/qxin6/debaug_expt/debaug/benchmark/bash-2.05_template/lib $SRC -w -o - -lbuiltins -lsh -lreadline -lhistory -ltermcap -lglob -ltilde -lmalloc  -ldl | opt -analyze -dot-callgraph
