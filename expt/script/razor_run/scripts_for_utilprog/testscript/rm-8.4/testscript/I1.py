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
    execute('cp -r input.origin/I1 input')
    indir = 'input/'    

    #0
    train_run("""--help""")

    #1
    train_run("""--version""")

    #2
    execute('cp -r ' +indir+ '-file.txt ./')
    train_run("""-- -file.txt""")
    execute('rm -fr ./-file.txt')

    #3
    execute('cp -r ' +indir+ '-file.txt ./')
    execute('mkdir -p ./home/hope/')
    execute('mv ./-file.txt ./home/hope/')
    train_run("""./home/hope/-file.txt""")
    execute('rm -fr ./home ./-file.txt')

    #4
    execute('cp -r ' +indir+ '-file.txt ./')
    train_run("""./-file.txt""")
    execute('rm -fr ./-file.txt')

    #5
    execute('cp -r ' +indir+ 'myfile.txt ./')
    train_run("""myfile.txt""")
    execute('rm -fr myfile.txt')

    #6
    execute('cp -r ' +indir+ 'myfile.txt ./')
    train_run("""-f myfile.txt""")
    execute('rm -fr myfile.txt')

    #7
    execute('cp -r ' +indir+ 'myfile.txt ./')
    train_run("""myfile.txt""")
    execute('rm -fr myfile.txt')

    #8
    execute('cp -r ' +indir+ 'myfile.txt ./')
    train_run("""-f myfile.txt""")
    execute('rm -fr myfile.txt')

    #9
    execute('cp -r ' +indir+ 'myfile.txt ./')
    train_run_with_echo("""-i myfile.txt""", 'y')
    execute('rm -fr myfile.txt')

    #10
    execute('cp -r ' +indir+ 'myfile.txt ./')
    train_run_with_echo("""-I myfile.txt""", 'y')
    execute('rm -fr myfile.txt')

    #11
    execute('cp -r ' +indir+ 'mydirectory ./')
    train_run("""-r mydirectory""")
    execute('rm -fr mydirectory')

    #12
    execute('cp -r ' +indir+ 'mydirectory ./')
    train_run("""-rf mydirectory""")
    execute('rm -fr mydirectory')

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
