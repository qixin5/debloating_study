#!/bin/bash

SRC=$1

# clang -S -emit-llvm $SRC -w -o - -lXt -lX11 -lXdmcp -lncurses | opt -analyze -dot-callgraph
clang -S -emit-llvm $SRC -w -o - -lXt -lX11 -lXdmcp -lncurses | opt -passes=dot-callgraph
mv \<stdin\>.callgraph.dot callgraph.dot
