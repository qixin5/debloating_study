#!/bin/bash

SRC=$1

clang -S -emit-llvm $SRC -w -o - -lXt -lX11 -lXdmcp -lncurses | opt -analyze -dot-callgraph
