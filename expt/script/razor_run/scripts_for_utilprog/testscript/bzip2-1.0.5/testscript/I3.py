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
    execute('cp -r input.origin/I3 input')
    d = 'input/'
    
    #0
    execute('cp ' +d+ 'filename ./')
    train_run("", 'filename')
    execute('rm filename filename.bz2')

    #1
    execute('cp ' +d+ 'filename ./')
    train_run("-z", 'filename')
    execute('rm filename filename.bz2')

    #2
    execute('cp ' +d+ 'backup.tar ./')
    train_run("-z", 'backup.tar')
    execute('rm backup.tar backup.tar.bz2')

    #3
    execute('cp ' +d+ 'filename ./')
    train_run("-zk", 'filename')
    execute('rm filename filename.bz2')

    #4
    execute('cp ' +d+ 'backup.tar ./')
    train_run("-zk", 'backup.tar')
    execute('rm backup.tar backup.tar.bz2')

    #5
    execute('cp ' +d+ 'Etcher-linux-x64.AppImage ./')
    train_run("-k1", 'Etcher-linux-x64.AppImage')
    execute('rm Etcher-linux-x64.AppImage Etcher-linux-x64.AppImage.bz2')

    #6
    execute('cp ' +d+ 'Etcher-linux-x64.AppImage ./')
    train_run("-k9", 'Etcher-linux-x64.AppImage')
    execute('rm Etcher-linux-x64.AppImage Etcher-linux-x64.AppImage.bz2')
    
    #7
    execute('cp ' +d+ 'Etcher-linux-x64.AppImage ./')
    train_run("-kf9", 'Etcher-linux-x64.AppImage')
    execute('rm Etcher-linux-x64.AppImage Etcher-linux-x64.AppImage.bz2')

    #8
    execute('cp ' +d+ 'filename ./')
    execute('bzip2 filename')
    train_run("-d", 'filename.bz2')
    execute('rm filename filename.bz2')
    
    #9
    execute('cp ' +d+ 'Etcher-linux-x64.AppImage ./')
    execute('bzip2 Etcher-linux-x64.AppImage')
    train_run("-vd", 'Etcher-linux-x64.AppImage.bz2')
    execute('rm Etcher-linux-x64.AppImage Etcher-linux-x64.AppImage.bz2')

    #10
    train_run("-h", '')


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
