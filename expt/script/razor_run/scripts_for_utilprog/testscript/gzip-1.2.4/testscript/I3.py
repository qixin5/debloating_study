#!/usr/bin/python
from __future__ import print_function
import os, subprocess, sys

DRRUN = '../../../tracers/dynamorio/bin64/drrun'
CLIENT = './logs/libcbr_indcall.so'

def execute(cmd):
    print('running ', cmd)
    p = subprocess.Popen(cmd, shell=True)
    p.communicate()


def train_run(arg1, arg2):
    BIN = './gzip.orig'
    cmd = BIN + ' ' + arg1 + ' ' + arg2
    cmd = DRRUN + ' -c ' + CLIENT + ' -- ' + cmd
    execute(cmd)    
    
    
def train():
    execute('rm -fr input')
    execute('cp -r input.origin/I3 input')
    d = 'input/'

    #0
    execute('cp -r ' +d+ 'mydocument.odt ./')
    train_run("", 'mydocument.odt')
    execute('rm -fr mydocument.odt mydocument.odt.gz')

    #1
    execute('cp -r ' +d+ '"this is my file.png" ./')
    train_run("", '"this is my file.png"')
    execute('rm -fr "this is my file.png" "this is my file.png".gz')

    #2
    execute('cp -r ' +d+ 'mydocument.odt ./')
    execute('gzip mydocument.odt')
    train_run("-d", 'mydocument.odt.gz')
    execute('rm -fr mydocument.odt.gz mydocument.odt')

    #3
    execute('cp -r ' +d+ 'file ./')
    train_run("-f", 'file')
    execute('rm -fr file file.gz')

    #4
    execute('cp -r ' +d+ 'file ./')
    execute('gzip file')
    train_run("-l", 'file.gz')
    execute('rm -fr file file.gz')

    #5
    execute('cp -r ' +d+ 'dir ./')
    train_run("-r", 'dir')
    execute('rm -fr dir')

    #6
    execute('cp -r ' +d+ 'file ./')
    execute('cp -r ' +d+ 'mydocument.odt ./')
    execute('cp -r ' +d+ '"this is my file.png" ./')
    execute('gzip file')
    execute('gzip mydocument.odt')
    execute('gzip "this is my file.png"')
    train_run("-d", 'file.gz mydocument.odt.gz "this is my file.png".gz')
    execute('rm -fr file.gz mydocument.odt.gz "this is my file.png".gz file mydocument.odt "this is my file.png"')

    #7
    execute('cp -r ' +d+ 'file ./')
    execute('gzip file')
    train_run("-t", 'file.gz')
    execute('rm -fr file.gz file')

    #8
    execute('cp -r ' +d+ 'file ./')
    train_run("-1", 'file')
    execute('rm -fr file file.gz')

    #9
    execute('cp -r ' +d+ 'file ./')
    train_run("-9", 'file')
    execute('rm -fr file file.gz')
    

def test():
    BIN = './gzip.orig_temp/gzip.orig.debloated'

    for fname in os.listdir('test'):
        fpath = os.path.join('test', fname)
        # -c
        cmd = BIN + ' -c < ' + fpath + ' > tmp.log'
        execute(cmd)

def get_traces_for_test(logs_dir, prog_name):
    BIN = './gzip.orig'

    for fname in os.listdir('test'):
        fpath = os.path.join('test', fname)
        # -c
        cmd = BIN + ' -c < ' + fpath + ' > tmp.log'
        cmd = DRRUN + ' -c ' + CLIENT + ' -- ' + cmd
        execute(cmd)
    execute("""python ../../../stitcher/src/merge_log.py %s %s""" % (logs_dir, prog_name))
    execute("""mkdir -p ./backup""")
    execute("""mv %s/%s-trace.log ./backup/""" % (logs_dir, prog_name))


def debloat(logs_dir, prog_name):
    execute("""python ../../../stitcher/src/merge_log.py %s %s""" % (logs_dir, prog_name))
    execute("""mv %s/%s-trace.log ./""" % (logs_dir, prog_name))
    execute("""python ../../../stitcher/src/instr_dumper.py ./%s-trace.log ./%s.orig ./instr.s""" % (prog_name, prog_name))
    execute("""python ../../../stitcher/src/find_symbols.py ./%s.orig ./instr.s """ % (prog_name))
    execute("""python ../../../stitcher/src/stitcher.py ./%s-trace.log ./%s.orig ./%s.s ./callbacks.txt""" % (prog_name, prog_name, prog_name))
    execute("""python ../../../stitcher/src/merge_bin.py %s.orig %s.s""" % (prog_name, prog_name))

def extend_debloat(prog_name, heuristic_level):
    execute("""python ../../../stitcher/src/heuristic/disasm.py ./%s.orig ./%s.orig.asm """ % (prog_name, prog_name))
    execute("""python ../../../stitcher/src/heuristic/find_more_paths.py ./%s.orig.asm ./%s-trace.log ./%s-extended.log %d""" % (prog_name, prog_name, prog_name, heuristic_level))
    execute("""python ../../../stitcher/src/instr_dumper.py ./%s-extended.log ./%s.orig ./instr.s""" % (prog_name, prog_name))
    execute("""python ../../../stitcher/src/find_symbols.py ./%s.orig ./instr.s""" % (prog_name))
    execute("""python ../../../stitcher/src/stitcher.py ./%s-extended.log ./%s.orig ./%s.s ./callbacks.txt""" % (prog_name, prog_name, prog_name))
    execute("""python ../../../stitcher/src/merge_bin.py %s.orig %s.s""" % (prog_name, prog_name))

def clean():
    for fname in os.listdir('./'):
        if fname == "run_razor.py":
            continue
        
        if fname == 'test' or fname == 'train' or fname == "backup":
            continue

        if fname == "gzip.orig" or fname == "gzip-1.2.4.c.orig.c":
            continue

        execute('rm -rf ./' + fname)

def usage():
    print('python run_razor.py clean|train|test|debloat|extend_debloat|get_test_traces\n')
    sys.exit(1)

def main():
    if len(sys.argv) != 2 and len(sys.argv) != 3:
        usage()

    if not os.path.exists("./logs"):
        cmd = "mkdir -p ./logs"
        execute(cmd)

        cmd = "cp ../../../tracers/bin/libcbr_indcall.so ./logs/"
        execute(cmd)
    
    if sys.argv[1] == 'train':
        train()
    
    elif sys.argv[1] == 'test':
        test()

    elif sys.argv[1] == 'debloat':
        debloat('logs', 'gzip')

    elif sys.argv[1] == 'extend_debloat':
        if len(sys.argv) != 3:
            print("Please specify heuristic level (i.e., 1 ~ 4).")
            sys.exit(1)
        heuristic_level = int(sys.argv[2])
        extend_debloat('gzip', heuristic_level)

    elif sys.argv[1] == "get_test_traces":
        get_traces_for_test("logs", "gzip")

    elif sys.argv[1] == 'clean':
        clean()

    else:
        usage()

if __name__ == '__main__':
    main()
