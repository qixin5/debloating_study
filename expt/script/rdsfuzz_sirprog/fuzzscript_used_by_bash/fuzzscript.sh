#!/usr/bin/perl -w

use File::Basename;

$TEST_DIR = "${DEBSTUDY_DIR}/expt/debaug/working/bash/testplans.alt/testplans.fine";

$BIN = $ARGV[0];
$OUT_DIR = $ARGV[1];
$TIMEOUT = $ARGV[2];
$scriptPath = $ARGV[3];   #This is path to the fuzzed script
$OUT_ID = $ARGV[4];       #A number used as the output file's id

$scriptName = basename($scriptPath);
$SCRIPT_FILE = "testfile";
$ENV{BASH_SRC_DIR} = dirname($BIN);
$ENV{TESTS_SRC} = $TEST_DIR;
$ENV{SHLVL} = 4;

close(STDERR);

@fileParts = split(/\./, $scriptName);
`cd $TEST_DIR && cat setup$fileParts[1] $scriptPath cleanup$fileParts[2] > $TEST_DIR/$SCRIPT_FILE && chmod 700 $TEST_DIR/$SCRIPT_FILE`;

$outfile = "$OUT_DIR/$OUT_ID";

`cd $TEST_DIR`;
`timeout -k 9 ${TIMEOUT}s $BIN $TEST_DIR/$SCRIPT_FILE > $outfile 2>&1`;
