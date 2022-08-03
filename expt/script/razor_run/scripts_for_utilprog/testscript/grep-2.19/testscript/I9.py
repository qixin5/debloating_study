#!/usr/bin/python
from __future__ import print_function
import os, subprocess, sys

DRRUN = '../../../tracers/dynamorio/bin64/drrun'
CLIENT = './logs/libcbr_indcall.so'

def execute(cmd):
    print('running ', cmd)
    p = subprocess.Popen(cmd, shell=True)
    p.communicate()

def train_run(arg):
    BIN = './grep.orig'
    cmd = BIN + ' ' + arg
    cmd = DRRUN + ' -c ' + CLIENT + ' -- ' + cmd
    execute(cmd)

def test_run(arg):
    BIN = './grep.orig_temp/grep.orig.debloated'
    cmd = BIN + ' ' + arg
    execute(cmd)


def train():
    execute('rm -fr input')
    execute('cp -r input.origin/I9 input')
    indir = 'input/'

    #0
    train_run(""" qxin6 /etc/passwd """)

    #1
    execute('cp -r ' +indir+ 'geek-1.log ./')
    train_run(""" -i Average geek-1.log """)
    execute('rm -fr geek-1.log')

    #2
    execute('cp -r ' +indir+ 'geek-1.log ./')
    train_run(""" -v Mem geek-1.log """)
    execute('rm -fr geek-1.log')
    
    #3
    execute('cp -r ' +indir+ 'geek-1.log ./')
    train_run(""" -q average geek-1.log """)
    execute('rm -fr geek-1.log')
    
    #4
    execute('cp -r ' +indir+ 'geek-1.log ./')
    train_run(""" -q howtogeek geek-1.log """)
    execute('rm -fr geek-1.log')
    
    #5
    execute('cp -r ' +indir+ '* ./')
    train_run(""" -r -i memfree archive.log at.c date.c etcsudoers files.c floats.c for.c geek-1.log getval.c global.c goto.c if.c logs-folder """)
    execute('rm -fr archive.log at.c date.c etcsudoers files.c floats.c for.c geek-1.log getval.c global.c goto.c if.c logs-folder')
    
    #6
    execute('cp -r ' +indir+ '* ./')
    train_run(""" -R -i memfree archive.log at.c date.c etcsudoers files.c floats.c for.c geek-1.log getval.c global.c goto.c if.c logs-folder """)
    execute('rm -fr archive.log at.c date.c etcsudoers files.c floats.c for.c geek-1.log getval.c global.c goto.c if.c logs-folder')
    
    #7
    execute('cp -r ' +indir+ 'geek-1.log ./')
    train_run(""" -i free geek-1.log """)
    execute('rm -fr geek-1.log')
    
    #8
    execute('cp -r ' +indir+ 'geek-1.log ./')
    train_run(""" -w -i free geek-1.log """)
    execute('rm -fr geek-1.log')
    
    #9
    execute('cp -r ' +indir+ 'geek-1.log ./')
    train_run(""" -E -w -i "average|memfree" geek-1.log """)
    execute('rm -fr geek-1.log')
    
    #10
    execute('cp -r ' +indir+ 'geek-1.log ./')
    train_run(""" -e MemFree -e [kK]B geek-1.log """)
    execute('rm -fr geek-1.log')
    
    #11
    execute('cp -r ' +indir+ 'geek-1.log ./')
    train_run(""" -x "20-Jan-06 15:24:35" geek-1.log """)
    execute('rm -fr geek-1.log')
    
    #12
    execute('cp -r ' +indir+ 'etcsudoers ./')
    train_run(""" -v "#" etcsudoers """)
    execute('rm -fr etcsudoers')
    
    #13
    execute('cp -r ' +indir+ 'geek-1.log ./')
    train_run(""" -o MemFree geek-1.log """)
    execute('rm -fr geek-1.log')
    
    #14
    execute('cp -r ' +indir+ 'geek-1.log ./')
    train_run(""" -c average geek-1.log """)
    execute('rm -fr geek-1.log')
    
    #15
    execute('cp -r ' +indir+ 'geek-1.log ./')
    train_run(""" -n Jan geek-1.log """)
    execute('rm -fr geek-1.log')
    
    #16
    execute('cp -r ' +indir+ 'geek-1.log ./')
    train_run(""" -m5 -n Jan geek-1.log """)
    execute('rm -fr geek-1.log')
    
    #17
    execute('cp -r ' +indir+ 'geek-1.log ./')
    train_run(""" -A 3 -x "20-Jan-06 15:24:35" geek-1.log """)
    execute('rm -fr geek-1.log')
    
    #18
    execute('cp -r ' +indir+ 'geek-1.log ./')
    train_run(""" -B 3 -x "20-Jan-06 15:24:35" geek-1.log """)
    execute('rm -fr geek-1.log')
    
    #19
    execute('cp -r ' +indir+ 'geek-1.log ./')
    train_run(""" -C 3 -x "20-Jan-06 15:24:35" geek-1.log """)
    execute('rm -fr geek-1.log')
    
    #20
    execute('cp -r ' +indir+ '*.c ./')
    train_run(""" -l "sl.h" *.c """)
    execute('rm -fr at.c date.c files.c floats.c for.c getval.c global.c goto.c if.c')
    
    #21
    execute('cp -r ' +indir+ '*.c ./')
    train_run(""" -L "sl.h" *.c """)
    execute('rm -fr at.c date.c files.c floats.c for.c getval.c global.c goto.c if.c')
    
    #22
    execute('cp -r ' +indir+ 'geek-1.log ./')
    train_run(""" "^ " geek-1.log """)
    execute('rm -fr geek-1.log')
    
    #23
    execute('cp -r ' +indir+ 'geek-1.log ./')
    train_run(""" "00$" geek-1.log """)
    execute('rm -fr geek-1.log')
    
    #24
    execute('cp -r ' +indir+ '*.c ./')
    train_run(""" "ExtractParameters" *.c """)
    execute('rm -fr *.c')
    
    return

def test():
    #38
    test_run( """ "a" ./test1  > log1""")
    test_run( """ "a" ./test2  > log1""")
    test_run( """ -n "si" ./test1  > log1""")
    test_run( """ -n "si" ./test2  > log1""")
    test_run( """ -o [r][a][n][d]* ./test1  > log1""")
    test_run( """ -o [r][a][n][d]* ./test2  > log1""")
    test_run( """ -v "a" ./test1  > log1""")
    test_run( """ -v "a" ./test2  > log1""")
    test_run( """ -i "Si" ./test1  > log1""")
    test_run( """ -i "Si" ./test2  > log1""")
    test_run( """ -w "Si" ./test1  > log1""")
    test_run( """ -w "Si" ./test2  > log1""")
    test_run( """ -x "Don't" ./test1  > log1""")
    test_run( """ -x "Don't" ./test2  > log1""")
    test_run( """ -E "randomtext*" ./test1  > log1""")
    test_run( """ -E "randomtext*" ./test2  > log1""")
    test_run( """ "ye " ./test1  > log1""")
    test_run( """ "ye " ./test2  > log1""")
    test_run( """ "cold" ./test1  > log1""")
    test_run( """ "cold" ./test2  > log1""")
    test_run( """ "not exist" ./test1  > log1""")
    test_run( """ "not exist" ./test2  > log1""")
    test_run( """ ^D  ./test1  > log1""")
    test_run( """ ^D  ./test2  > log1""")
    test_run( """ .$  ./test1  > log1""")
    test_run( """ .$  ./test2  > log1""")
    test_run( """ \^  ./test1  > log1""")
    test_run( """ \^  ./test2  > log1""")
    test_run( """ \^$  ./test1  > log1""")
    test_run( """ \^$  ./test2  > log1""")
    test_run( """ ^[AEIOU]  ./test1  > log1""")
    test_run( """ ^[AEIOU]  ./test2  > log1""")
    test_run( """ ^[^AEIOU]  ./test1  > log1""")
    test_run( """ ^[^AEIOU]  ./test2  > log1""")
    test_run( """ -E "free[^[:space:]]+"  ./test1  > log1""")
    test_run( """ -E "free[^[:space:]]+"  ./test2  > log1""")
    test_run( """ -E '\b(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?\.)3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)'  ./test1  > log1""")
    test_run( """ -E '\b(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?\.)3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)'  ./test2  > log1""")
    return

def get_traces_for_test(logs_dir, prog_name):
    train_run( """ "a" ./test1  > log1""")
    train_run( """ "a" ./test2  > log1""")
    train_run( """ -n "si" ./test1  > log1""")
    train_run( """ -n "si" ./test2  > log1""")
    train_run( """ -o [r][a][n][d]* ./test1  > log1""")
    train_run( """ -o [r][a][n][d]* ./test2  > log1""")
    train_run( """ -v "a" ./test1  > log1""")
    train_run( """ -v "a" ./test2  > log1""")
    train_run( """ -i "Si" ./test1  > log1""")
    train_run( """ -i "Si" ./test2  > log1""")
    train_run( """ -w "Si" ./test1  > log1""")
    train_run( """ -w "Si" ./test2  > log1""")
    train_run( """ -x "Don't" ./test1  > log1""")
    train_run( """ -x "Don't" ./test2  > log1""")
    train_run( """ -E "randomtext*" ./test1  > log1""")
    train_run( """ -E "randomtext*" ./test2  > log1""")
    train_run( """ "ye " ./test1  > log1""")
    train_run( """ "ye " ./test2  > log1""")
    train_run( """ "cold" ./test1  > log1""")
    train_run( """ "cold" ./test2  > log1""")
    train_run( """ "not exist" ./test1  > log1""")
    train_run( """ "not exist" ./test2  > log1""")
    train_run( """ ^D  ./test1  > log1""")
    train_run( """ ^D  ./test2  > log1""")
    train_run( """ .$  ./test1  > log1""")
    train_run( """ .$  ./test2  > log1""")
    train_run( """ \^  ./test1  > log1""")
    train_run( """ \^  ./test2  > log1""")
    train_run( """ \^$  ./test1  > log1""")
    train_run( """ \^$  ./test2  > log1""")
    train_run( """ ^[AEIOU]  ./test1  > log1""")
    train_run( """ ^[AEIOU]  ./test2  > log1""")
    train_run( """ ^[^AEIOU]  ./test1  > log1""")
    train_run( """ ^[^AEIOU]  ./test2  > log1""")
    train_run( """ -E "free[^[:space:]]+"  ./test1  > log1""")
    train_run( """ -E "free[^[:space:]]+"  ./test2  > log1""")
    train_run( """ -E '\b(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?\.)3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)'  ./test1  > log1""")
    train_run( """ -E '\b(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?\.)3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)'  ./test2  > log1""")

    execute("""python ../../../stitcher/src/merge_log.py %s %s""" % (logs_dir, prog_name))
    execute("""mkdir -p ./backup""")
    execute("""mv %s/%s-trace.log ./backup/""" % (logs_dir, prog_name))

def debloat(logs_dir, prog_name):
    execute("""python ../../../stitcher/src/merge_log.py %s %s""" % (logs_dir, prog_name))
    execute("""mv %s/%s-trace.log ./""" % (logs_dir, prog_name))
    execute("""python ../../../stitcher/src/instr_dumper.py ./%s-trace.log ./%s.orig ./instr.s""" % (prog_name, prog_name))
    execute("""python ../../../stitcher/src/find_symbols.py ./%s.orig ./instr.s > ./callbacks.txt""" % (prog_name))
    execute("""python ../../../stitcher/src/stitcher.py ./%s-trace.log ./%s.orig ./%s.s ./callbacks.txt""" % (prog_name, prog_name, prog_name))
    execute("""python ../../../stitcher/src/merge_bin.py %s.orig %s.s""" % (prog_name, prog_name))

def extend_debloat(prog_name, heuristic_level):
    execute("""python ../../../stitcher/src/heuristic/disasm.py ./%s.orig ./%s.orig.asm """ % (prog_name, prog_name))
    execute("""python ../../../stitcher/src/heuristic/find_more_paths.py ./%s.orig.asm ./%s-trace.log ./%s-extended.log %d""" % (prog_name, prog_name, prog_name, heuristic_level))
    execute("""python ../../../stitcher/src/instr_dumper.py ./%s-extended.log ./%s.orig ./instr.s""" % (prog_name, prog_name))
    execute("""python ../../../stitcher/src/find_symbols.py ./%s.orig ./instr.s > ./callbacks.txt""" % (prog_name))
    execute("""python ../../../stitcher/src/stitcher.py ./%s-extended.log ./%s.orig ./%s.s ./callbacks.txt""" % (prog_name, prog_name, prog_name))
    execute("""python ../../../stitcher/src/merge_bin.py %s.orig %s.s""" % (prog_name, prog_name))

def clean():
    for fname in os.listdir('./'):
        if fname == "run_razor.py":
            continue
        
        if fname.startswith('test') or fname.startswith('train') or fname == "backup":
            continue
        
        if fname == "grep.orig" or fname == "grep-2.19.c.orig.c":
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
        debloat('logs', 'grep')

    elif sys.argv[1] == 'extend_debloat':
        if len(sys.argv) != 3:
            print("Please specify heuristic level (i.e., 1 ~ 4).")
            sys.exit(1)
        heuristic_level = int(sys.argv[2])
        extend_debloat('grep', heuristic_level)

    elif sys.argv[1] == "get_test_traces":
        get_traces_for_test("logs", "grep")

    elif sys.argv[1] == 'clean':
        clean()

    else:
        usage()

if __name__ == '__main__':
    main()
