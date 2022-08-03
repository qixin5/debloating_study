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
    execute('cp -r input.origin/I1 input')
    indir = 'input/'
    
    #0
    execute('cp -r ' +indir+ 'file.txt ./')
    train_run('', 'file.txt')
    execute('rm -fr file.txt')
    
    #1
    execute('cp -r ' +indir+ 'mix.txt ./')
    train_run('', 'mix.txt')
    execute('rm -fr mix.txt')
    
    #2
    execute('cp -r ' +indir+ 'file.txt ./')
    train_run('', 'file.txt')
    execute('rm -fr file.txt')
    
    #3
    execute('cp -r ' +indir+ 'file.txt ./')
    train_run('-o output.txt', 'file.txt')
    execute('rm -fr file.txt output.txt')
    
    #4
    execute('cp -r ' +indir+ 'file.txt ./')
    train_run('-r', 'file.txt')
    execute('rm -fr file.txt')
    
    #5
    execute('cp -r ' +indir+ 'file1.txt ./')
    train_run('-n', 'file1.txt')
    execute('rm -fr file1.txt')
    
    #6
    execute('cp -r ' +indir+ 'file1.txt ./')
    train_run('-nr', 'file1.txt')
    execute('rm -fr file1.txt')
    
    #7
    execute('cp -r ' +indir+ 'employee.txt ./')
    train_run('-k 2n', 'employee.txt')
    execute('rm -fr employee.txt')
    
    #8
    execute('cp -r ' +indir+ 'cars.txt ./')
    train_run('-c', 'cars.txt')
    execute('rm -fr cars.txt')
    
    #9
    execute('cp -r ' +indir+ 'cars2.txt ./')
    train_run('-u', 'cars2.txt')
    execute('rm -fr cars2.txt')
    
    #10
    execute('cp -r ' +indir+ 'months.txt ./')
    train_run('-M', 'months.txt')
    execute('rm -fr months.txt')
    
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
