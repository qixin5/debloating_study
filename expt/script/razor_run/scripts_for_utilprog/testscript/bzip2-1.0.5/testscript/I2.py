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
    BIN = './bzip2.orig'
    cmd = BIN + ' ' + arg1 + ' ' + arg2
    cmd = DRRUN + ' -c ' + CLIENT + ' -- ' + cmd
    execute(cmd)
    
def train():
    execute('rm -fr input')
    execute('cp -r input.origin/I2 input')
    d = 'input/'
    
    #0
    execute('cp ' +d+ 'file.txt ./')
    train_run("", 'file.txt')
    execute('rm file.txt file.txt.bz2')    

    #1
    execute('cp ' +d+ 'file1.txt ./')
    execute('cp ' +d+ 'file2.txt ./')
    execute('cp ' +d+ 'file3.txt ./')
    train_run("", 'file1.txt file2.txt file3.txt')
    execute('rm file1.txt file2.txt file3.txt')
    execute('rm file1.txt.bz2 file2.txt.bz2 file3.txt.bz2')

    #2
    execute('cp ' +d+ 'file.txt ./')
    train_run("-c", 'file.txt >file.txt.bz2')
    execute('rm file.txt file.txt.bz2')

    #3
    execute('cp ' +d+ 'file.txt ./')
    train_run("-k", 'file.txt')
    execute('rm file.txt file.txt.bz2')

    #4
    execute('cp ' +d+ 'file.txt ./')
    execute('bzip2 file.txt')
    train_run("-d", 'file.txt.bz2')
    execute('rm file.txt file.txt.bz2')

    #5
    execute('cp ' +d+ 'file.txt ./')
    execute('bzip2 file.txt')
    train_run("-c", 'file.txt.bz2 >file.txt')
    execute('rm file.txt file.txt.bz2')

    #6
    execute('cp ' +d+ 'linux-3.18.19.tar ./')
    train_run("-v", 'linux-3.18.19.tar')
    execute('rm linux-3.18.19.tar linux-3.18.19.tar.bz2')
    
    #7
    execute('cp ' +d+ 'linux-3.18.19.tar ./')
    train_run("-v -1", 'linux-3.18.19.tar')
    execute('rm linux-3.18.19.tar linux-3.18.19.tar.bz2')

    #8
    execute('cp ' +d+ 'linux-3.18.19.tar ./')
    train_run("-v -9", 'linux-3.18.19.tar')
    execute('rm linux-3.18.19.tar linux-3.18.19.tar.bz2')
    
    #9
    execute('cp ' +d+ 'linux-3.18.19.tar ./')
    execute('bzip2 linux-3.18.19.tar')
    train_run("-tv", 'linux-3.18.19.tar.bz2')
    execute('rm linux-3.18.19.tar linux-3.18.19.tar.bz2')

    #10
    execute('cp ' +d+ 'linux-3.18.19.corrupt.tar.bz2 ./')
    train_run("-tv", 'linux-3.18.19.corrupt.tar.bz2')
    execute('rm linux-3.18.19.corrupt.tar.bz2 linux-3.18.19.corrupt.tar')

    #11
    execute('cp ' +d+ 'file.txt ./')
    train_run("-vv", 'file.txt')
    execute('rm file.txt file.txt.bz2')

    #12
    execute('cp ' +d+ 'file1.txt ./')
    execute('cp ' +d+ 'file2.txt ./')
    train_run("-c", 'file1.txt >file.bz2')
    train_run("-c", 'file2.txt >>file.bz2')
    execute('rm file1.txt file2.txt file.bz2')


def test():
    BIN = './bzip2.orig_temp/bzip2.orig.debloated'

    for fname in os.listdir('test'):
        fpath = os.path.join('test', fname)
        # -c
        cmd = BIN + ' -c < ' + fpath + ' > tmp.log'
        execute(cmd)

def get_traces_for_test(logs_dir, prog_name):
    BIN = './bzip2.orig'

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

        if fname == "bzip2.orig" or fname == "bzip2-1.0.5.c.orig.c":
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
        debloat('logs', 'bzip2')

    elif sys.argv[1] == 'extend_debloat':
        if len(sys.argv) != 3:
            print("Please specify heuristic level (i.e., 1 ~ 4).")
            sys.exit(1)
        heuristic_level = int(sys.argv[2])
        extend_debloat('bzip2', heuristic_level)
    
    elif sys.argv[1] == "get_test_traces":
        get_traces_for_test('logs', 'bzip2')

    elif sys.argv[1] == 'clean':
        clean()

    else:
        usage()

if __name__ == '__main__':
    main()
