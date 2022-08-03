#!/usr/bin/python
from __future__ import print_function
import os, subprocess, sys, pwd

DRRUN = '../../../tracers/dynamorio/bin64/drrun'
CLIENT = './logs/libcbr_indcall.so'

def execute(cmd):
    print('running ', cmd)
    p = subprocess.Popen(cmd, shell=True)
    p.communicate()

def train_run(arg1, arg2):
    BIN = './chown.orig'
    cmd = BIN + ' ' + arg1 + ' ' + arg2
    cmd = DRRUN + ' -c ' + CLIENT + ' -- ' + cmd
    execute(cmd)

def test_run(option, reduce_file):
    BIN = './chown.orig_temp/chown.orig.debloated'
    username = pwd.getpwuid(os.getuid())[0]
    cmd = BIN + ' ' + option + ' %s:%s ' % (username, username) + reduce_file
    execute(cmd)

def train():
    execute('rm -fr input')
    execute('cp -r input.origin/I8 input')
    indir = 'input/'

    #0
    execute('cp ' +indir+ 'myfile.txt ./')
    train_run('qxin6', 'myfile.txt')
    execute('rm -fr myfile.txt')

    #1
    execute('cp ' +indir+ 'myfile.txt ./')
    train_run('qxin6:sudo', 'myfile.txt')
    execute('rm -fr myfile.txt')

    #2
    execute('cp -r ' +indir+ 'otherfiles ./')
    train_run('-R qxin6:qxin6', 'otherfiles')
    execute('rm -fr otherfiles')

    #3
    execute('cp ' +indir+ 'file.txt ./')
    train_run('qxin6', 'file.txt')
    execute('rm -fr file.txt')

    #4
    execute('cp ' +indir+ 'file1 ./')
    execute('cp ' +indir+ 'file2 ./')
    execute('cp ' +indir+ 'file3 ./')
    train_run('qxin6', 'file1 file2 file3')
    execute('rm -fr file1')
    execute('rm -fr file2')
    execute('rm -fr file3')    

    #5
    execute('cp -r ' +indir+ 'myfiles ./')
    train_run('qxin6', 'myfiles')
    execute('rm -fr myfiles')

    #6
    execute('cp -r ' +indir+ 'myfiles ./')
    train_run('-R qxin6', 'myfiles')
    execute('rm -fr myfiles')

    #7
    execute('cp ' +indir+ 'file1 ./')
    execute('cp ' +indir+ 'file2 ./')    
    train_run('qxin6:sudo', 'file1 file2')
    execute('rm -fr file1')
    execute('rm -fr file2')
    
    #8
    execute('cp ' +indir+ 'file1 ./')
    train_run('qxin6:', 'file1')
    execute('rm -fr file1')
    
    #9
    execute('cp ' +indir+ 'file2 ./')
    train_run(':sudo', 'file2')
    execute('rm -fr file2')

    #10
    execute('cp ' +indir+ 'file1 ./')
    train_run('1002:1002', 'file1')
    execute('rm -fr file1')

    #11
    execute('cp ' +indir+ 'file1 ./')
    train_run('+1002:+1002', 'file1')
    execute('rm -fr file1')

    #12
    execute('cp -r ' +indir+ 'Documents ./')
    train_run('-R qxin6:qxin6', 'Documents')
    execute('rm -fr Documents')

    #13
    execute('cp -r ' +indir+ 'Documents ./')
    execute('cp -r ' +indir+ 'inbox ./')
    train_run('-Rc --reference inbox', 'Documents/work')
    execute('rm -fr Documents inbox')

    #14
    execute('cp -r ' +indir+ 'file1 ./')
    execute('cp -r ' +indir+ 'file2 ./')
    execute('cp -r ' +indir+ 'file3 ./')
    train_run('qxin6', 'file1 file2 file3')
    execute('rm -fr file1 file2 file3')


def test():
    execute('touch .file1')
    test_run('', '.file1')
    execute('rm -rf .file1')

    execute('mkdir -p d1/d1/d1/d1/d1/d1/d1/d1/d1')
    execute('touch    d1/d1/d1/d1/d1/d1/d1/d1/d1/file')
    execute('touch    d1/d1/d1/d1/d1/d1/d1/d1/d1/.file')
    test_run('', 'd1/d1/d1/d1/d1/d1/d1/d1/d1/file')
    test_run('', 'd1/d1/d1/d1/d1/d1/d1/d1/d1/.file')
    execute('rm -rf d1')

    execute('mkdir -p d1/d1/d1/d1/d1/d1/d1/d1/d1')
    execute('touch    d1/d1/d1/d1/d1/d1/d1/d1/d1/file')
    test_run('', 'd1')
    execute('rm -rf d1')

    execute('mkdir -p d1/d1/d1/d1/d1/d1/d1/d1/d1')
    execute('touch    d1/d1/d1/d1/d1/d1/d1/d1/d1/file')
    execute('touch    d1/d1/d1/d1/d1/d1/d1/d1/d1/.file')
    test_run('-R', 'd1')
    execute('rm -rf d1')

    execute('mkdir -p d1/d1/d1/d1/d1/d1/d1/d1/d1')
    execute('touch    d1/d1/d1/d1/d1/d1/d1/d1/d1/file')
    execute('touch    d1/d1/d1/d1/d1/d1/d1/d1/d1/.file')
    test_run('-R', 'd1/d1')
    execute('rm -rf d1')

    execute('mkdir -p d1/d1/d1/d1/d1/d1/d1/d1/d1')
    execute('touch    d1/d1/d1/d1/d1/d1/d1/d1/d1/file')
    execute('touch    d1/d1/d1/d1/d1/d1/d1/d1/d1/.file')
    test_run('-R', 'd1/d1/d1')
    execute('rm -rf d1')

    execute('mkdir -p d1/d1/d1/d1/d1/d1/d1/d1/d1')
    execute('touch    d1/d1/d1/d1/d1/d1/d1/d1/d1/file')
    execute('touch    d1/d1/d1/d1/d1/d1/d1/d1/d1/.file')
    test_run('-R', 'd1/d1/d1/d1')
    execute('rm -rf d1')

    execute('mkdir -p d1/d1/d1/d1/d1/d1/d1/d1/d1')
    execute('touch    d1/d1/d1/d1/d1/d1/d1/d1/d1/file')
    execute('touch    d1/d1/d1/d1/d1/d1/d1/d1/d1/.file')
    test_run('-R', 'd1/d1/d1/d1/d1')
    execute('rm -rf d1')

    execute('mkdir -p d1/d1/d1/d1/d1/d1/d1/d1/d1')
    execute('touch    d1/d1/d1/d1/d1/d1/d1/d1/d1/file')
    execute('touch    d1/d1/d1/d1/d1/d1/d1/d1/d1/.file')
    test_run('-R', 'd1/d1/d1/d1/d1/d1')
    execute('rm -rf d1')

    execute('mkdir -p d1/d1/d1/d1/d1/d1/d1/d1/d1')
    execute('touch    d1/d1/d1/d1/d1/d1/d1/d1/d1/file')
    execute('touch    d1/d1/d1/d1/d1/d1/d1/d1/d1/.file')
    test_run('-R', 'd1/d1/d1/d1/d1/d1/d1')
    execute('rm -rf d1')

    execute('mkdir -p d1/d1/d1/d1/d1/d1/d1/d1/d1')
    execute('touch    d1/d1/d1/d1/d1/d1/d1/d1/d1/file')
    execute('touch    d1/d1/d1/d1/d1/d1/d1/d1/d1/.file')
    test_run('-R', 'd1/d1/d1/d1/d1/d1/d1/d1')
    execute('rm -rf d1')

    execute('mkdir -p d1/d1/d1/d1/d1/d1/d1/d1/d1')
    execute('touch    d1/d1/d1/d1/d1/d1/d1/d1/d1/file')
    execute('touch    d1/d1/d1/d1/d1/d1/d1/d1/d1/.file')
    test_run('-R', 'd1/d1/d1/d1/d1/d1/d1/d1/d1')
    execute('rm -rf d1')


    execute('touch file1')
    execute('ln -s file1 symfile1')
    execute('ln -s file1 symfile2')
    test_run('-h', 'file1')
    execute('rm -rf file1 symfile*')

    execute('touch file1')
    execute('ln -s file1 symfile1')
    execute('ln -s file1 symfile2')
    test_run('-h', 'symfile1')
    execute('rm -rf file1 symfile*')

    execute('touch file1')
    execute('ln -s file1 symfile1')
    execute('ln -s file1 symfile2')
    test_run('-h', 'symfile2')
    execute('rm -rf file1 symfile*')

    execute('touch file1')
    execute('ln -s file1 symfile1')
    execute('ln -s file1 symfile2')
    test_run('-h', 'symfile*')
    execute('rm -rf file1 symfile*')

    return

def get_traces_for_test(logs_dir, prog_name):
    execute('touch .file1')
    train_run('', '.file1')
    execute('rm -rf .file1')

    execute('mkdir -p d1/d1/d1/d1/d1/d1/d1/d1/d1')
    execute('touch    d1/d1/d1/d1/d1/d1/d1/d1/d1/file')
    execute('touch    d1/d1/d1/d1/d1/d1/d1/d1/d1/.file')
    train_run('', 'd1/d1/d1/d1/d1/d1/d1/d1/d1/file')
    train_run('', 'd1/d1/d1/d1/d1/d1/d1/d1/d1/.file')
    execute('rm -rf d1')

    execute('mkdir -p d1/d1/d1/d1/d1/d1/d1/d1/d1')
    execute('touch    d1/d1/d1/d1/d1/d1/d1/d1/d1/file')
    train_run('', 'd1')
    execute('rm -rf d1')

    execute('mkdir -p d1/d1/d1/d1/d1/d1/d1/d1/d1')
    execute('touch    d1/d1/d1/d1/d1/d1/d1/d1/d1/file')
    execute('touch    d1/d1/d1/d1/d1/d1/d1/d1/d1/.file')
    train_run('-R', 'd1')
    execute('rm -rf d1')

    execute('mkdir -p d1/d1/d1/d1/d1/d1/d1/d1/d1')
    execute('touch    d1/d1/d1/d1/d1/d1/d1/d1/d1/file')
    execute('touch    d1/d1/d1/d1/d1/d1/d1/d1/d1/.file')
    train_run('-R', 'd1/d1')
    execute('rm -rf d1')

    execute('mkdir -p d1/d1/d1/d1/d1/d1/d1/d1/d1')
    execute('touch    d1/d1/d1/d1/d1/d1/d1/d1/d1/file')
    execute('touch    d1/d1/d1/d1/d1/d1/d1/d1/d1/.file')
    train_run('-R', 'd1/d1/d1')
    execute('rm -rf d1')

    execute('mkdir -p d1/d1/d1/d1/d1/d1/d1/d1/d1')
    execute('touch    d1/d1/d1/d1/d1/d1/d1/d1/d1/file')
    execute('touch    d1/d1/d1/d1/d1/d1/d1/d1/d1/.file')
    train_run('-R', 'd1/d1/d1/d1')
    execute('rm -rf d1')

    execute('mkdir -p d1/d1/d1/d1/d1/d1/d1/d1/d1')
    execute('touch    d1/d1/d1/d1/d1/d1/d1/d1/d1/file')
    execute('touch    d1/d1/d1/d1/d1/d1/d1/d1/d1/.file')
    train_run('-R', 'd1/d1/d1/d1/d1')
    execute('rm -rf d1')

    execute('mkdir -p d1/d1/d1/d1/d1/d1/d1/d1/d1')
    execute('touch    d1/d1/d1/d1/d1/d1/d1/d1/d1/file')
    execute('touch    d1/d1/d1/d1/d1/d1/d1/d1/d1/.file')
    train_run('-R', 'd1/d1/d1/d1/d1/d1')
    execute('rm -rf d1')

    execute('mkdir -p d1/d1/d1/d1/d1/d1/d1/d1/d1')
    execute('touch    d1/d1/d1/d1/d1/d1/d1/d1/d1/file')
    execute('touch    d1/d1/d1/d1/d1/d1/d1/d1/d1/.file')
    train_run('-R', 'd1/d1/d1/d1/d1/d1/d1')
    execute('rm -rf d1')

    execute('mkdir -p d1/d1/d1/d1/d1/d1/d1/d1/d1')
    execute('touch    d1/d1/d1/d1/d1/d1/d1/d1/d1/file')
    execute('touch    d1/d1/d1/d1/d1/d1/d1/d1/d1/.file')
    train_run('-R', 'd1/d1/d1/d1/d1/d1/d1/d1')
    execute('rm -rf d1')

    execute('mkdir -p d1/d1/d1/d1/d1/d1/d1/d1/d1')
    execute('touch    d1/d1/d1/d1/d1/d1/d1/d1/d1/file')
    execute('touch    d1/d1/d1/d1/d1/d1/d1/d1/d1/.file')
    train_run('-R', 'd1/d1/d1/d1/d1/d1/d1/d1/d1')
    execute('rm -rf d1')


    execute('touch file1')
    execute('ln -s file1 symfile1')
    execute('ln -s file1 symfile2')
    train_run('-h', 'file1')
    execute('rm -rf file1 symfile*')

    execute('touch file1')
    execute('ln -s file1 symfile1')
    execute('ln -s file1 symfile2')
    train_run('-h', 'symfile1')
    execute('rm -rf file1 symfile*')

    execute('touch file1')
    execute('ln -s file1 symfile1')
    execute('ln -s file1 symfile2')
    train_run('-h', 'symfile2')
    execute('rm -rf file1 symfile*')

    execute('touch file1')
    execute('ln -s file1 symfile1')
    execute('ln -s file1 symfile2')
    train_run('-h', 'symfile*')
    execute('rm -rf file1 symfile*')

    execute("""python ../../../stitcher/src/merge_log.py %s %s""" % (logs_dir, prog_name))
    execute("""mkdir -p ./backup""")
    execute("""mv %s/%s-trace.log ./backup/""" % (logs_dir, prog_name))

def debloat(logs_dir, prog_name):
    execute("""python ../../../stitcher/src/merge_log.py %s %s""" % (logs_dir, prog_name))
    execute("""mv %s/%s-trace.log ./""" % (logs_dir, prog_name))
    execute("""python ../../../stitcher/src/instr_dumper.py ./%s-trace.log ./%s.orig ./instr.s""" % (prog_name, prog_name))
    execute("""python ../../../stitcher/src/find_symbols.py ./%s.orig ./instr.s""" % (prog_name))
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

        if fname == "chown.orig" or fname == "chown-8.2.c.orig.c":
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
        debloat('logs', 'chown')

    elif sys.argv[1] == 'extend_debloat':
        if len(sys.argv) != 3:
            print("Please specify heuristic level (i.e., 1 ~ 4).")
            sys.exit(1)
        heuristic_level = int(sys.argv[2])
        extend_debloat('chown', heuristic_level)

    elif sys.argv[1] == "get_test_traces":
        get_traces_for_test('logs', 'chown')

    elif sys.argv[1] == 'clean':
        clean()

    else:
        usage()

if __name__ == '__main__':
    main()
