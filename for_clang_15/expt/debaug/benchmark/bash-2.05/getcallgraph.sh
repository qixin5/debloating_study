#!/bin/bash

SRC=$1

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
# clang -S -emit-llvm -L/home/qxin6/debaug_expt/debaug/benchmark/bash-2.05_template/lib $SRC -w -o - -lbuiltins -lsh -lreadline -lhistory -ltermcap -lglob -ltilde -lmalloc  -ldl | opt -analyze -dot-callgraph
clang -S -emit-llvm -L $SCRIPT_DIR/lib $SRC -w -o - -lbuiltins -lsh -lreadline -lhistory -ltermcap -lglob -ltilde -lmalloc  -ldl | opt -passes=dot-callgraph
mv \<stdin\>.callgraph.dot callgraph.dot
