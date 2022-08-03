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

def train_run_for_i23():
    BIN = './grep.orig'
    cmd = 'GREP_COLOR=\'1;35\' ' + BIN + ' --color=always qxin6 /etc/passwd'
    cmd = DRRUN + ' -c ' + CLIENT + ' -- ' + cmd
    execute(cmd)

def train_run_for_i24():
    BIN = './grep.orig'
    cmd = 'GREP_COLOR=\'1;32\' ' + BIN + ' --color=always qxin6 /etc/passwd'
    cmd = DRRUN + ' -c ' + CLIENT + ' -- ' + cmd
    execute(cmd)

def train_run_for_i25():
    BIN = './grep.orig'
    cmd = 'GREP_COLOR=\'1;37\' ' + BIN + ' --color=always root /etc/passwd'
    cmd = DRRUN + ' -c ' + CLIENT + ' -- ' + cmd
    execute(cmd)

def train_run_for_i26():
    BIN = './grep.orig'
    cmd = 'GREP_COLOR=\'1;36\' ' + BIN + ' --color=always nobody /etc/passwd'
    cmd = DRRUN + ' -c ' + CLIENT + ' -- ' + cmd
    execute(cmd)
    
    
def test_run(arg):
    BIN = './grep.orig_temp/grep.orig.debloated'
    cmd = BIN + ' ' + arg
    execute(cmd)


def train():
    execute('rm -fr input')
    execute('cp -r input.origin/I0 input')
    indir = 'input/'

    #0
    train_run(""" qxin6 /etc/passwd """)

    #1
    train_run(""" -i "qxin6" /etc/passwd """)

    #2
    train_run(""" -i qxin6 /etc/passwd """)
    
    #3
    train_run(""" "^qxin6" /etc/passwd """)

    #4
    train_run(""" 127.0.0.13 /etc/hosts """)

    #5
    train_run(""" 127.0.0.1 /etc/hosts """)

    #6
    execute('dpkg --list >dpkg_list')
    train_run(""" htop dpkg_list """)
    execute('rm -fr dpkg_list')

    #7
    execute('dpkg --list >dpkg_list')
    train_run(""" nginx dpkg_list """)
    execute('rm -fr dpkg_list')
    
    #8
    train_run(""" -r "127.0.0.1" /etc/ """)

    #9
    train_run(""" -h -R "127.0.0.1" /etc/ """)

    #10
    execute('cp ' +indir+ 'file ./')
    train_run(""" -w "boo" file """)
    execute('rm -fr file')

    #11
    execute('cp -r ' +indir+ 'projects ./')
    train_run(""" -r -i 'main' projects """)
    execute('rm -fr projects')

    #12
    execute('cp ' +indir+ 'file1 ./')
    train_run(""" -i 'bar' file1 """)
    execute('rm -fr file1')

    #13
    execute('cp ' +indir+ 'file2 ./')
    train_run(""" -c 'word' file2 """)
    execute('rm -fr file2')

    #14
    train_run(""" -n 'root' /etc/passwd """)

    #15
    train_run(""" -v '^root' /etc/passwd """)

    #16
    execute('cp ' +indir+ 'file3 ./')
    train_run(""" -B 3 "foo" file3 """)
    execute('rm -fr file3')

    #17
    execute('cp ' +indir+ 'file4 ./')
    train_run(""" -A 4 "dropped" file4 """)
    execute('rm -fr file4')

    #18
    execute('cp ' +indir+ 'file5 ./')
    train_run(""" -C 4 -B 5 -A 6 --color 'error-code' file5 """)
    execute('rm -fr file5')

    #19
    train_run(""" -i 'Model' /proc/cpuinfo """)

    #20
    execute('dpkg --list >dpkg_list')
    train_run(""" linux-image dpkg_list """)
    execute('rm -fr dpkg_list')

    #21
    execute('cp -r ' +indir+ 'projects2 ./')
    train_run(""" -Rl 'main' projects2 """)
    execute('rm -fr projects2')

    #22
    train_run(""" --color qxin6 /etc/passwd """)

    #23
    train_run_for_i23()

    #24
    train_run_for_i24()

    #25
    train_run_for_i25()

    #26
    train_run_for_i26()

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
