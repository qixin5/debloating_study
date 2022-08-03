#!/usr/bin/python
from __future__ import print_function
import os, subprocess, sys

DRRUN = '../../../tracers/dynamorio/bin64/drrun'
CLIENT = './logs/libcbr_indcall.so'

def execute(cmd):
    print('running ', cmd)
    p = subprocess.Popen(cmd, shell=True)
    p.communicate()

def train_run(arg1):
    BIN = './rm.orig'
    cmd = BIN + ' ' + arg1
    cmd = DRRUN + ' -c ' + CLIENT + ' -- ' + cmd
    execute(cmd)

def train_run_with_echo(arg1, echo_ctnt):
    BIN = './rm.orig'
    cmd = 'echo ' + echo_ctnt + ' | ' + BIN + ' ' + arg1
    cmd = DRRUN + ' -c ' + CLIENT + ' -- ' + cmd
    execute(cmd)
    
def test_run(arg1):
    BIN = './rm.orig_temp/rm.orig.debloated'
    cmd = BIN + ' ' + arg1
    execute(cmd)


def train():
    execute('rm -fr input')
    execute('cp -r input.origin/I2 input')
    indir = 'input/'    

    #0
    execute('cp -r ' +indir+ 'linuxstufff.log ./')
    train_run("""linuxstufff.log""")
    execute('rm -fr linuxstufff.log')

    #1
    execute('cp -r ' +indir+ 'file*.txt ./')
    train_run("""file1.txt file2.txt file3.txt file4.txt""")
    execute('rm -fr file1.txt file2.txt file3.txt file4.txt')

    #2
    execute('cp -r ' +indir+ 'linuxstufff.log ./')
    train_run_with_echo("""-i linuxstufff.log""", 'y')
    execute('rm -fr linuxstufff.log')

    #3
    execute('mkdir appdata')
    train_run("""-d appdata""")
    execute('rm -fr appdata')

    #4
    execute('cp -r ' +indir+ 'dbstore ./')
    train_run("""-r dbstore/""")
    execute('rm -fr dbstore')

    #5
    execute('cp -r ' +indir+ 'dbstore ./')
    train_run_with_echo("""-ri dbstore/""", 'y')
    execute('rm -fr dbstore')

    #6
    execute('cp -r ' +indir+ 'tech.txt ./')
    train_run_with_echo("""tech.txt""", 'y')
    execute('chmod 755 tech.txt')
    execute('rm -fr tech.txt')

    #7
    execute('cp -r ' +indir+ 'tech.txt ./')
    train_run("""-f tech.txt""")
    execute('rm -fr tech.txt')

    #8
    train_run("""-f nonexist.txt""")
    execute('rm -fr nonexist.txt')

    #9
    train_run("""-f /mytest/myfile""")

    #10
    execute('cp -r ' +indir+ 'linux_store ./')
    train_run_with_echo("""-I linux_store/app*""", 'y')
    execute('rm -fr linux_store')

    #11
    execute('cp -r ' +indir+ 'linux_store2/* ./')
    train_run("""-f log{1..5}.txt""")
    execute('rm -fr log1.txt log2.txt log3.txt log4.txt log5.txt log6.txt')

    #12
    execute('cp -r ' +indir+ 'file1.txt file2.txt file3.txt file4.txt ./')
    train_run("""-f file1.txt file2.txt file3.txt file4.txt""")
    execute('rm -fr file1.txt file2.txt file3.txt file4.txt')

    #13
    execute('cp -r ' +indir+ 'file1.txt file2.txt file3.txt file4.txt linuxstufff.log./')
    train_run("""-f file1.txt file2.txt file3.txt file4.txt linuxstufff.log""")
    execute('rm -fr file1.txt file2.txt file3.txt file4.txt linuxstufff.log')

    #14
    execute('cp -r ' +indir+ '-store ./')
    train_run("""-store""")
    execute('rm -fr ./-store')

    #15
    execute('cp -r ' +indir+ '-store ./')
    train_run("""-- \-store""")
    execute('rm -fr ./-store')

    return

def test():
    # 20
    execute("""touch file1""")
    test_run("""file*""")
    execute(""" rm -rf file*""")

    execute("""touch .file1""")
    test_run(""".file1""")
    execute(""" rm -rf file*""")

    execute("""touch file file1 file2 file3""")
    test_run("""file1 file2 file3""")
    execute(""" rm -rf file*""")

    execute("""touch file file1 file2 file3""")
    test_run("""file*""")
    execute(""" rm -rf file*""")

    execute("""mkdir -p d1/d2""")
    test_run("""d1""")
    test_run("""d1/d2""")
    test_run("""-rf d1""")
    execute(""" rm -rf d1""")

    execute("""mkdir -p d1/d2""")
    execute("""mkdir -p d1/d3""")
    test_run("""-rf d1""")
    execute(""" rm -rf d1""")

    execute("""mkdir -p d1/d2""")
    execute("""mkdir -p d1/d3""")
    test_run("""-rf d1/*""")
    test_run("""-rf d1""")
    execute(""" rm -rf d1""")
    
    execute("""mkdir d1""")
    execute("""touch d1/file1""")
    execute("""touch d1/file2""")
    execute("""touch d1/file3""")
    test_run("""d1/file*""")
    test_run("""-rf d1""")
    execute(""" rm -rf d1""")

    execute("""mkdir -p d1/d2/d3""")
    execute("""touch d1/file1""")
    execute("""touch d1/d2/file2""")
    execute("""touch d1/d2/d3/file3""")
    test_run("""d1/file*""")
    test_run("""d1/d2/file*""")
    test_run("""d1/d2/d3/file*""")
    test_run("""-rf d1""")
    execute(""" rm -rf d1""")

    execute("""mkdir -p d1/d2/d3""")
    execute("""touch d1/file1""")
    execute("""touch d1/d2/file2""")
    execute("""touch d1/d2/d3/file3""")
    test_run("""-rf d1""")
    execute(""" rm -rf d1""")

    execute("""mkdir d1""")
    execute("""touch d1/file d1/file2""")
    test_run("""-i d1/file*""")
    execute(""" rm -rf d1""")

    execute("""mkdir d1""")
    execute("""touch d1/file d1/file2""")
    test_run("""-i d1""")
    test_run("""-rf d1""")
    execute(""" rm -rf d1""")
    return

def get_traces_for_test(logs_dir, prog_name):
    execute("""touch file1""")
    train_run("""file*""")
    execute(""" rm -rf file*""")

    execute("""touch .file1""")
    train_run(""".file1""")
    execute(""" rm -rf file*""")

    execute("""touch file file1 file2 file3""")
    train_run("""file1 file2 file3""")
    execute(""" rm -rf file*""")

    execute("""touch file file1 file2 file3""")
    train_run("""file*""")
    execute(""" rm -rf file*""")

    execute("""mkdir -p d1/d2""")
    train_run("""d1""")
    train_run("""d1/d2""")
    train_run("""-rf d1""")
    execute(""" rm -rf d1""")

    execute("""mkdir -p d1/d2""")
    execute("""mkdir -p d1/d3""")
    train_run("""-rf d1""")
    execute(""" rm -rf d1""")

    execute("""mkdir -p d1/d2""")
    execute("""mkdir -p d1/d3""")
    train_run("""-rf d1/*""")
    train_run("""-rf d1""")
    execute(""" rm -rf d1""")
    
    execute("""mkdir d1""")
    execute("""touch d1/file1""")
    execute("""touch d1/file2""")
    execute("""touch d1/file3""")
    train_run("""d1/file*""")
    train_run("""-rf d1""")
    execute(""" rm -rf d1""")

    execute("""mkdir -p d1/d2/d3""")
    execute("""touch d1/file1""")
    execute("""touch d1/d2/file2""")
    execute("""touch d1/d2/d3/file3""")
    train_run("""d1/file*""")
    train_run("""d1/d2/file*""")
    train_run("""d1/d2/d3/file*""")
    train_run("""-rf d1""")
    execute(""" rm -rf d1""")

    execute("""mkdir -p d1/d2/d3""")
    execute("""touch d1/file1""")
    execute("""touch d1/d2/file2""")
    execute("""touch d1/d2/d3/file3""")
    train_run("""-rf d1""")
    execute(""" rm -rf d1""")

    execute("""mkdir d1""")
    execute("""touch d1/file d1/file2""")
    train_run("""-i d1/file*""")
    execute(""" rm -rf d1""")

    execute("""mkdir d1""")
    execute("""touch d1/file d1/file2""")
    train_run("""-i d1""")
    train_run("""-rf d1""")
    execute(""" rm -rf d1""")

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
        
        if fname == "rm.orig":
            continue

        if fname == "README.md" or fname == "rm-8.4.c.orig.c":
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
        debloat('logs', 'rm')

    elif sys.argv[1] == 'extend_debloat':
        if len(sys.argv) != 3:
            print("Please specify heuristic level (i.e., 1 ~ 4).")
            sys.exit(1)
        heuristic_level = int(sys.argv[2])
        extend_debloat('rm', heuristic_level)

    elif sys.argv[1] == "get_test_traces":
        get_traces_for_test("logs", "rm")

    elif sys.argv[1] == 'clean':
        clean()

    else:
        usage()

if __name__ == '__main__':
    main()
