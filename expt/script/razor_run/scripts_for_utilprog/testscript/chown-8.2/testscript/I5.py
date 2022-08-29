#!/usr/bin/python
from __future__ import print_function
import os, subprocess, sys, pwd, getpass

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
    uname = getpass.getuser()
    uname_colon_uname = uname+":"+uname
    
    execute('rm -fr input')
    execute('cp -r input.origin/I5 input')
    indir = 'input/'

    #0
    train_run('--version', '')

    #1
    execute('cp ' +indir+ 'sample ./')
    train_run(uname, 'sample')
    execute('rm -fr sample')

    #2
    execute('cp ' +indir+ 'sample2 ./')
    train_run('1002', 'sample2')
    execute('rm -fr sample2')

    #3
    execute('cp ' +indir+ 'sample2 ./')
    execute('cp ' +indir+ 'sample3 ./')
    train_run('root', 'sample2 sample3')
    execute('chown -R '+uname_colon_uname+' sample2')
    execute('chown -R '+uname_colon_uname+' sample3')
    execute('rm -fr sample2 sample3')

    #4
    execute('cp ' +indir+ 'sample3 ./')
    execute('cp -r ' +indir+ 'Dir1 ./')
    train_run('root', 'sample3 Dir1')
    execute('chown -R '+uname_colon_uname+' sample3')
    execute('chown -R '+uname_colon_uname+' Dir1')
    execute('rm -fr sample3 Dir1')

    #5
    execute('cp ' +indir+ 'sample3 ./')
    train_run(':sudo', 'sample3')
    execute('rm -fr sample3')

    #6
    execute('cp ' +indir+ 'sample ./')
    train_run(':1002', 'sample')
    execute('rm -fr sample')

    #7
    execute('cp ' +indir+ 'sample3 ./')
    train_run(uname+':sudo', 'sample3')
    execute('rm -fr sample3')
    
    #8
    execute('cp ' +indir+ 'sample3 ./')
    train_run(uname+':', 'sample3')
    execute('rm -fr sample3')

    #9
    execute('cp ' +indir+ 'testfile1 ./')
    execute('cp ' +indir+ 'testfile2 ./')
    execute('chown :sudo testfile1')
    train_run('--reference=testfile1', 'testfile2')
    execute('rm -fr testfile1')
    execute('rm -fr testfile2')

    #10
    execute('cp ' +indir+ 'sample3 ./')
    train_run('--from=root:'+uname+' '+uname+':sudo', 'sample3')
    execute('chown -R '+uname_colon_uname+' sample3')
    execute('rm -fr sample3')

    #11
    execute('cp ' +indir+ 'sample3 ./')
    train_run('--from=root '+uname, 'sample3')
    execute('chown -R '+uname_colon_uname+' sample3')
    execute('rm -fr sample3')

    #12
    execute('cp ' +indir+ 'sample3 ./')
    train_run('--from=:'+uname+' :sudo', 'sample3')
    execute('chown -R '+uname_colon_uname+' sample3')
    execute('rm -fr sample3')

    #13
    execute('cp -r ' +indir+ 'Dir1 ./')
    train_run('-R '+uname+':sudo', 'Dir1')
    execute('rm -fr Dir1')

    #14
    execute('cp ' +indir+ 'textfile ./')
    execute('ln -s textfile symblink')
    train_run(uname+':', 'symblink')
    execute('unlink symblink')
    execute('rm -fr textfile')

    #15
    execute('cp ' +indir+ 'textfile ./')
    execute('ln -s textfile symblink')
    train_run('-h '+uname+':', 'symblink')
    execute('unlink symblink')
    execute('rm -fr textfile')

    #16
    execute('cp ' +indir+ 'sample2 ./')
    train_run('-v '+uname, 'sample2')
    execute('rm -fr sample2')

    #17
    execute('cp ' +indir+ 'sample* ./')
    train_run('-v -R '+uname, 'sample*')
    execute('rm -fr sample*')

    #18 (intended failure)
    train_run('-f '+uname, 'symblinks')
    
    #19 (intended failure)
    train_run('-f linuxusers', 'symblinks')


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
