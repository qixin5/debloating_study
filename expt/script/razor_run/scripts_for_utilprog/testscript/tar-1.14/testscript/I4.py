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
    BIN = './tar.orig'
    cmd = BIN + ' ' + arg1 + ' ' + arg2
    cmd = DRRUN + ' -c ' + CLIENT + ' -- ' + cmd
    execute(cmd)

def train_run_for_i7():
    BIN = './tar.orig'
    cmd = 'echo y | ' + BIN + ' -cw -f hugefie.tar ./Videos/*'
    cmd = DRRUN + ' -c ' + CLIENT + ' -- ' + cmd
    execute(cmd)

    
def train():
    execute('rm -fr input')
    execute('cp -r input.origin/I4 input')
    indir = 'input/'
    currdir = os.getcwd()

    #0
    execute('cp -r ' +indir+ 'archive.tar ./')
    train_run("xfv", 'archive.tar')
    execute('rm -fr archive.tar file1 file2 file3')
    
    #1
    execute('cp -r ' +indir+ 'file1 ./')
    execute('cp -r ' +indir+ 'file2 ./')
    execute('cp -r ' +indir+ 'file3 ./')
    train_run("cfv archive.tar", 'file1 file2 file3')
    execute('rm -fr archive.tar file1 file2 file3')
    
    #2
    execute('cp -r ' +indir+ 'archive.tar ./')
    train_run("tvf", 'archive.tar')
    execute('rm -fr archive.tar')
    
    #3
    execute('cp -r ' +indir+ 'todo.txt ./')
    train_run("cfv archive.tar", 'todo.txt')
    execute('rm -fr archive.tar todo.txt')
    
    #4
    execute('cp -r ' +indir+ 'archive.tar ./')
    execute('cp -r ' +indir+ 'todo.txt ./')
    train_run("rvf", 'archive.tar todo.txt')
    execute('rm -fr archive.tar todo.txt')
    
    #5
    execute('cp -r ' +indir+ 'file.tar ./')
    train_run("tf", 'file.tar')
    execute('rm -fr file.tar')
    
    #6
    execute('cp -r ' +indir+ 'folder ./')
    execute('cp -r ' +indir+ 'upload ./')
    execute('cp -r ' +indir+ 'file ./')
    train_run("cfv archive.tar", 'folder upload file --exclude=\'./folder\' --exclude=\'./upload/folder2\'')
    execute('rm -fr archive.tar folder upload file')
    

def test():
    BIN = './tar.orig_temp/tar.orig.debloated'

    for fname in os.listdir('test'):
        fpath = os.path.join('test', fname)
        # -c
        cmd = BIN + ' cf tmp.tar ' + fpath
        execute(cmd)

def get_traces_for_test(logs_dir, prog_name):
    BIN = './tar.orig'

    for fname in os.listdir('test'):
        fpath = os.path.join('test', fname)
        # -c
        cmd = BIN + ' cf tmp.tar ' + fpath
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

        if fname == "tar.orig" or fname == "tar-1.14.c.orig.c":
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
        debloat('logs', 'tar')

    elif sys.argv[1] == 'extend_debloat':
        if len(sys.argv) != 3:
            print("Please specify heuristic level (i.e., 1 ~ 4).")
            sys.exit(1)
        heuristic_level = int(sys.argv[2])
        extend_debloat('tar', heuristic_level)
    
    elif sys.argv[1] == "get_test_traces":
        get_traces_for_test("logs", "tar")

    elif sys.argv[1] == 'debloat_patch':
        debloat_patch('tar')

    elif sys.argv[1] == 'clean':
        clean()

    else:
        usage()

if __name__ == '__main__':
    main()
