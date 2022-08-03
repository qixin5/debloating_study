#!/bin/bash

SRC=$1

clang -S -emit-llvm $SRC -w -o - | opt -analyze -dot-callgraph
