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

def train():
    execute('rm -fr input')
    execute('cp -r input.origin/I0 input')
    indir = 'input/'

    #0
    execute('cp -r ' +indir+ 'tecmint ./')
    train_run("-cvf tecmint-14-09-12.tar", './tecmint')
    execute('rm -fr tecmint tecmint-14-09-12.tar')

    #1
    execute('cp -r ' +indir+ 'public_html-14-09-12.tar ./')
    train_run("-xvf", 'public_html-14-09-12.tar')
    execute('rm -fr public_html-14-09-12.tar public_html')
    
    #2
    execute('cp -r ' +indir+ 'public_html-14-09-12.tar ./')
    execute('mkdir tmp')
    train_run("-xvf", 'public_html-14-09-12.tar -C tmp')
    execute('rm -fr public_html-14-09-12.tar tmp public_html')
    
    #3
    execute('cp -r ' +indir+ 'uploadprogress.tar ./')
    train_run("-tvf", 'uploadprogress.tar')
    execute('rm -fr uploadprogress.tar')
    
    #4
    execute('cp -r ' +indir+ 'cleanfiles.sh.tar ./')
    train_run("-xvf", 'cleanfiles.sh.tar cleanfiles.sh')
    execute('rm -fr cleanfiles.sh cleanfiles.sh.tar')
    
    #5
    execute('cp -r ' +indir+ 'cleanfiles.sh.tar ./')
    train_run("--extract --file=cleanfiles.sh.tar", 'cleanfiles.sh')
    execute('rm -fr cleanfiles.sh.tar cleanfiles.sh')
    
    #6
    execute('cp -r ' +indir+ 'tecmint-14-09-12.tar ./')
    train_run("-xvf tecmint-14-09-12.tar", 'tecmint/rpmforge-release-0.5.2-2.el5.rf.i386.rpm tecmint/phpmyadmin-2.11.11.3-1.el5.rf.noarch.rpm')
    execute('rm -fr tecmint-14-09-12.tar tecmint')
    
    #7
    execute('cp -r ' +indir+ 'Phpfiles-org.tar ./')
    train_run("-xvf", 'Phpfiles-org.tar --wildcards \'*.php\'')
    execute('rm -fr Phpfiles-org.tar php')
    
    #8
    execute('cp -r ' +indir+ 'tecmint-14-09-12.tar ./')
    execute('cp -r ' +indir+ 'xyz.txt ./')
    train_run("-rvf", 'tecmint-14-09-12.tar xyz.txt')
    execute('rm -fr xyz.txt tecmint-14-09-12.tar')
    
    #9
    execute('cp -r ' +indir+ 'tecmint-14-09-12.tar ./')
    execute('cp -r ' +indir+ 'php ./')    
    train_run("-rvf", 'tecmint-14-09-12.tar php')
    execute('rm -fr tecmint-14-09-12.tar php')


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
