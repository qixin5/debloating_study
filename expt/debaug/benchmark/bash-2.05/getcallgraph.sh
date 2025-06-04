#!/bin/bash

SRC=$1

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
clang -S -emit-llvm -L $SCRIPT_DIR/lib $SRC -w -o - -lbuiltins -lsh -lreadline -lhistory -ltermcap -lglob -ltilde -lmalloc  -ldl | opt -analyze -dot-callgraph
