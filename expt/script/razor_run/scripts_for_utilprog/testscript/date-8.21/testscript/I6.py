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
    BIN = './date.orig'
    cmd = BIN + ' ' + arg
    cmd = DRRUN + ' -c ' + CLIENT + ' -- ' + cmd
    execute(cmd)

def test_run(arg):
    BIN = './date.orig_temp/date.orig.debloated'
    cmd = BIN + ' ' + arg
    execute(cmd)


def train():
    execute('rm -fr input')
    execute('cp -r input.origin/I6 input')
    indir = 'input/'
    
    #0
    train_run(""" """)

    #1
    train_run(""" -u """)

    #2
    train_run(""" --date="02/02/2019" """)
    
    #3
    train_run(""" --date="2 years ago" """)

    #4
    train_run(""" --date="5 sec ago" """)

    #5
    train_run(""" --date="yesterday" """)
    
    #6
    train_run(""" --date="10 days ago" """)

    #7
    train_run(""" --date="tomorrow" """)

    #8
    train_run(""" --date="next day" """)
    
    #9
    train_run(""" --date="2 day" """)

    #10
    train_run(""" --date="1 year" """)

    #11
    execute('cp ' +indir+ 'file.txt ./')
    train_run(""" -r file.txt """)
    execute('rm -fr file.txt')

    #12
    train_run(""" "+%D" """)

    #13
    train_run(""" "+%a" """)

    #14
    train_run(""" "+%A" """)

    #15
    train_run(""" "+%h" """)

    #16
    train_run(""" "+%b" """)

    #17
    train_run(""" "+%B" """)

    #18
    train_run(""" "+%m" """)

    #19
    train_run(""" "+%y" """)

    #20
    train_run(""" "+%Y" """)

    return

def test():
    # 33
    test_run("""--date '02/29/1997 1 year' +%Y-%m-%d""")
    test_run("""--date '1995-1-7' +%U""")
    test_run("""--date '1995-1-8' +%U""")
    test_run("""--date '1992-1-1' +%U""")
    test_run("""--date '1992-1-4' +%U """)
    test_run(""" --date '1992-1-5' +%U """)
    test_run(""" --date '1992-1-5' +%V """)
    test_run(""" --date '1992-1-6' +%V """)
    test_run(""" --date '1992-1-5' +%W """)
    test_run(""" --date '1992-1-6' +%W """)
    test_run(""" --date '1999-1-1 4 years' +%Y """)
    test_run(""" -d 'TZ="America/New_York" 9:00 next Fri' """)
    test_run(""" -d "1990-11-08 08:17:48 +0 now" "+%Y-%m-%d %T" """)
    test_run(""" -d "1990-11-08 08:17:48 +0 yesterday" "+%Y-%m-%d %T" """)
    test_run(""" -d "1990-11-08 08:17:48 +0 tomorrow" "+%Y-%m-%d %T" """)
    test_run(""" -d "1990-11-08 08:17:48 +0 10 years ago" "+%Y-%m-%d %T"   """)
    test_run(""" -d "1990-11-08 08:17:48 +0 8 months ago" "+%Y-%m-%d %T" """)
    test_run(""" -d "1990-11-08 08:17:48 +0 80 weeks ago" "+%Y-%m-%d %T" """)
    test_run(""" -d '2005-03-27 +4 months' '+%Y' """)
    test_run(""" -d @-22 +%10s """)
    test_run(""" -d 1999-12-08 +%08d """)
    test_run(""" --rfc-3339=ns -d "1969-12-31 13:00:00.00000001-1100" """)
    test_run(""" --rfc-3339=sec -d @31536000 """)
    test_run(""" --utc -d '1970-01-01 00:00:00 UTC +961062237 sec' "+%Y-%m-%d %T" """)
    test_run(""" -d 'Nov 10 1996' "+%Y-%m-%d %T" """)
    test_run(""" -u -d '1996-11-10 0:00:00 +0' "+%Y-%m-%d %T" """)
    test_run(""" -d "1997-01-19 08:17:48 +0 4 seconds ago" "+%Y-%m-%d %T" """)
    test_run(""" -d '20050101  1 day' +%F """)
    test_run(""" -d '20050101 +1 day' +%F """)
    test_run(""" -d "1997-01-19 08:17:48 +0 next second" '+%Y-%m-%d %T' """)
    test_run(""" -d "1997-01-19 08:17:48 +0 next minute" '+%Y-%m-%d %T' """)
    test_run(""" -d "1997-01-19 08:17:48 +0 next hour" '+%Y-%m-%d %T' """)
    test_run(""" -d "1997-01-19 08:17:48 +0 next day" '+%Y-%m-%d %T' """)
    return

def get_traces_for_test(logs_dir, prog_name):
    train_run("""--date '02/29/1997 1 year' +%Y-%m-%d""")
    train_run("""--date '1995-1-7' +%U""")
    train_run("""--date '1995-1-8' +%U""")
    train_run("""--date '1992-1-1' +%U""")
    train_run("""--date '1992-1-4' +%U """)
    train_run(""" --date '1992-1-5' +%U """)
    train_run(""" --date '1992-1-5' +%V """)
    train_run(""" --date '1992-1-6' +%V """)
    train_run(""" --date '1992-1-5' +%W """)
    train_run(""" --date '1992-1-6' +%W """)
    train_run(""" --date '1999-1-1 4 years' +%Y """)
    train_run(""" -d 'TZ="America/New_York" 9:00 next Fri' """)
    train_run(""" -d "1990-11-08 08:17:48 +0 now" "+%Y-%m-%d %T" """)
    train_run(""" -d "1990-11-08 08:17:48 +0 yesterday" "+%Y-%m-%d %T" """)
    train_run(""" -d "1990-11-08 08:17:48 +0 tomorrow" "+%Y-%m-%d %T" """)
    train_run(""" -d "1990-11-08 08:17:48 +0 10 years ago" "+%Y-%m-%d %T"   """)
    train_run(""" -d "1990-11-08 08:17:48 +0 8 months ago" "+%Y-%m-%d %T" """)
    train_run(""" -d "1990-11-08 08:17:48 +0 80 weeks ago" "+%Y-%m-%d %T" """)
    train_run(""" -d '2005-03-27 +4 months' '+%Y' """)
    train_run(""" -d @-22 +%10s """)
    train_run(""" -d 1999-12-08 +%08d """)
    train_run(""" --rfc-3339=ns -d "1969-12-31 13:00:00.00000001-1100" """)
    train_run(""" --rfc-3339=sec -d @31536000 """)
    train_run(""" --utc -d '1970-01-01 00:00:00 UTC +961062237 sec' "+%Y-%m-%d %T" """)
    train_run(""" -d 'Nov 10 1996' "+%Y-%m-%d %T" """)
    train_run(""" -u -d '1996-11-10 0:00:00 +0' "+%Y-%m-%d %T" """)
    train_run(""" -d "1997-01-19 08:17:48 +0 4 seconds ago" "+%Y-%m-%d %T" """)
    train_run(""" -d '20050101  1 day' +%F """)
    train_run(""" -d '20050101 +1 day' +%F """)
    train_run(""" -d "1997-01-19 08:17:48 +0 next second" '+%Y-%m-%d %T' """)
    train_run(""" -d "1997-01-19 08:17:48 +0 next minute" '+%Y-%m-%d %T' """)
    train_run(""" -d "1997-01-19 08:17:48 +0 next hour" '+%Y-%m-%d %T' """)
    train_run(""" -d "1997-01-19 08:17:48 +0 next day" '+%Y-%m-%d %T' """)

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
        
        if fname == 'test' or fname == 'train' or fname == "backup":
            continue
        
        if fname == "date.orig" or fname == "date-8.21.c.orig.c":
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
        debloat('logs', 'date')

    elif sys.argv[1] == 'extend_debloat':
        if len(sys.argv) != 3:
            print("Please specify heuristic level (i.e., 1 ~ 4).")
            sys.exit(1)
        heuristic_level = int(sys.argv[2])
        extend_debloat('date', heuristic_level)

    elif sys.argv[1] == "get_test_traces":
        get_traces_for_test('logs', 'date')

    elif sys.argv[1] == 'clean':
        clean()

    else:
        usage()

if __name__ == '__main__':
    main()
