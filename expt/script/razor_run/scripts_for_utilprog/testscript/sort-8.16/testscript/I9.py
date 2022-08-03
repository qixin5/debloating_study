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
    BIN = './sort.orig'
    cmd = BIN + ' ' + arg1 + ' ' + arg2
    cmd = DRRUN + ' -c ' + CLIENT + ' -- ' + cmd
    execute(cmd)

def test_run(arg1, arg2):
    BIN = './sort.orig_temp/sort.orig.debloated'
    cmd = BIN + ' ' + arg1 + ' ' + arg2 + ' > tmp.out'
    print(cmd)
    execute(cmd)


def train():
    execute('rm -fr input')
    execute('cp -r input.origin/I9 input')
    indir = 'input/'
    
    #0
    execute('cp -r ' +indir+ 'file1 ./')
    train_run('', 'file1')
    execute('rm -fr file1')

    #1
    execute('cp -r ' +indir+ 'file2 ./')
    train_run('', 'file2')
    execute('rm -fr file2')

    #2
    execute('cp -r ' +indir+ 'file7 ./')
    train_run('', 'file7 -h')
    execute('rm -fr file7')

    #3
    execute('cp -r ' +indir+ 'order.txt ./')
    train_run('', 'order.txt')
    execute('rm -fr order.txt')

    #4
    execute('cp -r ' +indir+ 'order.txt ./')
    train_run('', 'order.txt -n')
    execute('rm -fr order.txt')

    #5
    execute('cp -r ' +indir+ 'file2 ./')
    train_run('', 'file2 -r')
    execute('rm -fr file2')

    #6
    execute('cp -r ' +indir+ 'file3 ./')
    train_run('', 'file3 -M')
    execute('rm -fr file3')

    #7
    execute('cp -r ' +indir+ 'file2 ./')
    train_run('', 'file2 -n')
    execute('rm -fr file2')

    #8
    execute('cp -r ' +indir+ 'file4 ./')
    train_run('', 'file4 -k 2')
    execute('rm -fr file4')

    #9
    execute('cp -r ' +indir+ 'file4 ./')
    train_run('', 'file4 -k 3n')
    execute('rm -fr file4')

    #10
    execute('cp -r ' +indir+ 'file4 ./')
    train_run('', 'file4 -k 3nr')
    execute('rm -fr file4')

    #11
    execute('cp -r ' +indir+ 'file5 ./')
    train_run('', 'file5 -u')
    execute('rm -fr file5')

    #12
    execute('cp -r ' +indir+ 'file6 ./')
    train_run('', 'file6 -f')
    execute('rm -fr file6')

    #13
    execute('cp -r ' +indir+ 'file7 ./')
    train_run('', 'file7 -h')
    execute('rm -fr file7')

    return

def test():
    d = 'test/'
    for fname in os.listdir(d):
        test_run("-r", d + fname)
        test_run("-s", d + fname)
        test_run("-u", d + fname)
        test_run("-z", d + fname)
    return

def get_traces_for_test(logs_dir, prog_name):
    d = 'test/'
    for fname in os.listdir(d):
        train_run("-r", d + fname)
        train_run("-s", d + fname)
        train_run("-u", d + fname)
        train_run("-z", d + fname)

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
        
        if fname.startswith('test') or fname.startswith('train') or fname == "backup":
            continue
        
        if fname == "sort.orig" or fname == "sort-8.16.c.orig.c":
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
        debloat('logs', 'sort')

    elif sys.argv[1] == 'extend_debloat':
        if len(sys.argv) != 3:
            print("Please specify heuristic level (i.e., 1 ~ 4).")
            sys.exit(1)
        heuristic_level = int(sys.argv[2])
        extend_debloat('sort', heuristic_level)

    elif sys.argv[1] == "get_test_traces":
        get_traces_for_test("logs", "sort")

    elif sys.argv[1] == 'clean':
        clean()

    else:
        usage()

if __name__ == '__main__':
    main()
