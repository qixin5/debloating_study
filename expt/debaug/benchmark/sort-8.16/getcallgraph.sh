#!/bin/bash

SRC=$1

clang -S -emit-llvm $SRC -w -o - -lpthread | opt -analyze -dot-callgraph
