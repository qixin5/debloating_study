#!/bin/bash

SRC=$1

# libglob_path=/home/qxin6/debaug_expt/debaug/benchmark/make-3.79_template/lib/libglob.a
# libglob_path=lib/libglob.a

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
clang -S -emit-llvm $SRC -w -o - -L $SCRIPT_DIR/lib -lutil | opt -analyze -dot-callgraph
