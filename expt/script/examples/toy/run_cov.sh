#!/bin/bash

LINE_PRINTER_BIN=${DEBAUG_DIR}/bin/startandendlineprinter
REMOVER_BIN=${DEBAUG_DIR}/bin/gcovbasedcoderemover
MERGE_BIN=${DEBAUG_DIR}/bin/gcovbasedcoveragemerger
GCOV_ANAL_BIN=${DEBAUG_DIR}/bin/gcovanalyzer
LCOV2GCOV_BIN=${DEBAUG_DIR}/bin/lcov2gcov


${LINE_PRINTER_BIN} toy.c >line.txt


clang -fprofile-instr-generate -fcoverage-mapping -w -o toy toy.c


./toy 10
llvm-profdata merge -o toy.profdata default.profraw
llvm-cov export -format=lcov ./toy -instr-profile=toy.profdata ./toy.c >toy.lcov
${LCOV2GCOV_BIN} toy.lcov >toy.gcov
mkdir gcov
${GCOV_ANAL_BIN} toy.gcov getbcov >./gcov/0


${MERGE_BIN} binary gcov >gcov_merged


${REMOVER_BIN} ./toy.c line.txt gcov_merged >toy.reduced.c


rm -fr gcov gcov_merged line.txt toy toy.gcov toy.lcov \
   debop-out default.profraw toy.profdata
