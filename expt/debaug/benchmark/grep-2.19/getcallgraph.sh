#!/bin/bash

SRC=$1

clang -S -emit-llvm $SRC -w -D '__msan_unpoison(s,z)' -o - -lpcre | opt -analyze -dot-callgraph
