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

def train_run_for_i1():
    BIN = './sort.orig'
    cmd = 'LC_ALL=C ' + BIN + ' basic.txt'
    cmd = DRRUN + ' -c ' + CLIENT + ' -- ' + cmd
    execute(cmd)
    
def test_run(arg1, arg2):
    BIN = './sort.orig_temp/sort.orig.debloated'
    cmd = BIN + ' ' + arg1 + ' ' + arg2 + ' > tmp.out'
    print(cmd)
    execute(cmd)


def train():
    execute('rm -fr input')
    execute('cp -r input.origin/I2 input')
    indir = 'input/'
    
    #0
    execute('cp -r ' +indir+ 'basic.txt ./')
    train_run('', 'basic.txt')
    execute('rm -fr basic.txt')
    
    #1
    execute('cp -r ' +indir+ 'basic.txt ./')
    train_run_for_i1()
    execute('rm -fr basic.txt')
    
    #2
    execute('cp -r ' +indir+ 'super.txt ./')
    train_run('-t, -k2,2', 'super.txt')
    execute('rm -fr super.txt')
    
    #3
    execute('cp -r ' +indir+ 'super.txt ./')
    train_run('-t, -k2,2 -n', 'super.txt')
    execute('rm -fr super.txt')
    
    #4
    execute('cp -r ' +indir+ 'multi.txt ./')
    train_run('-t, -k1,1', 'multi.txt')
    execute('rm -fr multi.txt')
    
    #5
    execute('cp -r ' +indir+ 'multi.txt ./')
    train_run('-t, -k1,1 -k3,3n', 'multi.txt')
    execute('rm -fr multi.txt')
    
    #6
    execute('cp -r ' +indir+ 'number.txt ./')
    train_run('', 'number.txt')
    execute('rm -fr number.txt')
    
    #7
    execute('cp -r ' +indir+ 'number.txt ./')
    train_run('-n', 'number.txt')
    execute('rm -fr number.txt')
    
    #8
    execute('cp -r ' +indir+ 'scientific.txt ./')
    train_run('-n', 'scientific.txt')
    execute('rm -fr scientific.txt')
    
    #9
    execute('cp -r ' +indir+ 'scientific.txt ./')
    train_run('-g', 'scientific.txt')
    execute('rm -fr scientific.txt')
    
    #10
    execute('cp -r ' +indir+ 'super.txt ./')
    train_run('', 'super.txt')
    execute('rm -fr super.txt')
    
    #11
    execute('cp -r ' +indir+ 'super.txt ./')
    train_run('-r', 'super.txt')
    execute('rm -fr super.txt')
    
    #12
    execute('cp -r ' +indir+ 'heroes.txt ./')
    train_run('', 'heroes.txt')
    execute('rm -fr heroes.txt')
    
    #13
    execute('cp -r ' +indir+ 'heroes.txt ./')
    train_run('-u', 'heroes.txt')
    execute('rm -fr heroes.txt')
    
    #14
    execute('cp -r ' +indir+ 'specialChar.txt ./')
    train_run('', 'specialChar.txt')
    execute('rm -fr specialChar.txt')
    
    #15
    execute('cp -r ' +indir+ 'specialChar.txt ./')
    train_run('-d', 'specialChar.txt')
    execute('rm -fr specialChar.txt')
    
    #16
    execute('cp -r ' +indir+ 'blank.txt ./')
    train_run('', 'blank.txt')
    execute('rm -fr blank.txt')
    
    #17
    execute('cp -r ' +indir+ 'blank.txt ./')
    train_run('-b', 'blank.txt')
    execute('rm -fr blank.txt')
    
    #18
    execute('cp -r ' +indir+ 'perfect.txt ./')
    train_run('-c', 'perfect.txt')
    execute('rm -fr perfect.txt')
    
    #19
    execute('cp -r ' +indir+ 'super.txt ./')
    train_run('-c', 'super.txt')
    execute('rm -fr super.txt')
    
    #20
    execute('cp -r ' +indir+ 'years.txt ./')
    train_run('-c', 'years.txt')
    execute('rm -fr years.txt')
    
    #21
    execute('cp -r ' +indir+ 'years.txt ./')
    train_run('-c -u', 'years.txt')
    execute('rm -fr years.txt')
    
    #22
    execute('cp -r ' +indir+ 'perfect.txt ./')
    execute('cp -r ' +indir+ 'perfect2.txt ./')
    train_run('-m', 'perfect.txt perfect2.txt')
    execute('rm -fr perfect.txt perfect2.txt')
    
    #23
    execute('cp -r ' +indir+ 'months.txt ./')
    train_run('-M', 'months.txt')
    execute('rm -fr months.txt')
    
    #24
    execute('cp -r ' +indir+ 'monthsFull.txt ./')
    train_run('-M', 'monthsFull.txt')
    execute('rm -fr monthsFull.txt')
    
    #25
    execute('cp -r ' +indir+ 'super.txt ./')
    train_run('-o orderedSuper.txt -t, -k2,2nr', 'super.txt')
    execute('rm -fr super.txt orderedSuper.txt')
    
    #26
    execute('cp -r ' +indir+ 'dbDump.txt ./')
    train_run('-S100b', 'dbDump.txt >/dev/null')
    execute('rm -fr dbDump.txt')
    
    #27
    execute('cp -r ' +indir+ 'dbDump.txt ./')
    train_run('-S500K', 'dbDump.txt >/dev/null')
    execute('rm -fr dbDump.txt')
    
    #28
    execute('cp -r ' +indir+ 'dbDump.txt ./')
    train_run('-S50M', 'dbDump.txt >/dev/null')
    execute('rm -fr dbDump.txt')
    
    #29
    execute('cp -r ' +indir+ 'dbDump.txt ./')
    train_run('-S2G', 'dbDump.txt >/dev/null')
    execute('rm -fr dbDump.txt')
    
    #30
    execute('cp -r ' +indir+ 'dbDump.txt ./')
    train_run('-S10%', 'dbDump.txt >/dev/null')
    execute('rm -fr dbDump.txt')
    
    #31
    execute('cp -r ' +indir+ 'dbDump.txt ./')
    execute('mkdir tmp')
    train_run('-S10% -T./tmp', 'dbDump.txt >/dev/null')
    execute('rm -fr tmp dbDump.txt')

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
