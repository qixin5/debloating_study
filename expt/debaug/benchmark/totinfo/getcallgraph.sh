#!/bin/bash

SRC=$1

clang -S -emit-llvm $SRC -w -o - -lm | opt -analyze -dot-callgraph
