# 1 "./make_comb.cil.c"
# 1 "<built-in>"
# 1 "<command-line>"
# 1 "/usr/include/stdc-predef.h" 1 3 4
# 1 "<command-line>" 2
# 1 "./make_comb.cil.c"
# 62 "/usr/include/x86_64-linux-gnu/bits/types.h"
typedef unsigned long __uintmax_t;
# 148 "/usr/include/x86_64-linux-gnu/bits/types.h"
typedef long __time_t;
# 7 "/usr/include/x86_64-linux-gnu/bits/types/time_t.h"
typedef __time_t time_t;
# 216 "/usr/lib/gcc/x86_64-linux-gnu/6/include/stddef.h"
typedef unsigned long size_t;
# 112 "/usr/include/stdint.h"
typedef __uintmax_t uintmax_t;
# 366 "make.h"
struct floc {
   char *filenm ;
   unsigned long lineno ;
};
# 25 "filedef.h"
struct dep;
# 25 "filedef.h"
struct dep;
# 25 "filedef.h"
struct commands;
# 25 "filedef.h"
struct commands;
# 25 "filedef.h"
struct variable_set_list;
# 25 "filedef.h"
struct variable_set_list;
# 25 "filedef.h"
enum __anonenum_command_state_55 {
    cs_not_started = 0,
    cs_deps_running = 1,
    cs_running = 2,
    cs_finished = 3
} ;
# 25 "filedef.h"
struct file {
   struct file *next ;
   char *name ;
   char *hname ;
   char *vpath ;
   struct dep *deps ;
   struct commands *cmds ;
   int command_flags ;
   char *stem ;
   struct dep *also_make ;
   uintmax_t last_mtime ;
   uintmax_t mtime_before_update ;
   struct file *prev ;
   struct file *renamed ;
   struct variable_set_list *variables ;
   struct variable_set_list *pat_variables ;
   struct file *parent ;
   struct file *double_colon ;
   short update_status ;
   enum __anonenum_command_state_55 command_state : 2 ;
   unsigned int precious : 1 ;
   unsigned int tried_implicit : 1 ;
   unsigned int updating : 1 ;
   unsigned int updated : 1 ;
   unsigned int is_target : 1 ;
   unsigned int cmd_target : 1 ;
   unsigned int phony : 1 ;
   unsigned int intermediate : 1 ;
   unsigned int secondary : 1 ;
   unsigned int dontcare : 1 ;
   unsigned int ignore_vpath : 1 ;
   unsigned int pat_searched : 1 ;
   unsigned int considered : 1 ;
};
# 36 "dep.h"
struct dep {
   struct dep *next ;
   char *name ;
   struct file *file ;
   int changed ;
};
# 47 "dep.h"
struct nameseq {
   struct nameseq *next ;
   char *name ;
};
# 203 "ar.c"
struct ar_glob_state {
   char *arname ;
   char *pattern ;
   unsigned int size ;
   struct nameseq *chain ;
   unsigned int n ;
};
# 133 "/usr/include/x86_64-linux-gnu/bits/types.h"
typedef unsigned long __dev_t;
# 134 "/usr/include/x86_64-linux-gnu/bits/types.h"
typedef unsigned int __uid_t;
# 135 "/usr/include/x86_64-linux-gnu/bits/types.h"
typedef unsigned int __gid_t;
# 136 "/usr/include/x86_64-linux-gnu/bits/types.h"
typedef unsigned long __ino_t;
# 138 "/usr/include/x86_64-linux-gnu/bits/types.h"
typedef unsigned int __mode_t;
# 139 "/usr/include/x86_64-linux-gnu/bits/types.h"
typedef unsigned long __nlink_t;
# 140 "/usr/include/x86_64-linux-gnu/bits/types.h"
typedef long __off_t;
# 162 "/usr/include/x86_64-linux-gnu/bits/types.h"
typedef long __blksize_t;
# 167 "/usr/include/x86_64-linux-gnu/bits/types.h"
typedef long __blkcnt_t;
# 181 "/usr/include/x86_64-linux-gnu/bits/types.h"
typedef long __ssize_t;
# 184 "/usr/include/x86_64-linux-gnu/bits/types.h"
typedef long __syscall_slong_t;
# 109 "/usr/include/x86_64-linux-gnu/sys/types.h"
typedef __ssize_t ssize_t;
# 9 "/usr/include/x86_64-linux-gnu/bits/types/struct_timespec.h"
struct timespec {
   __time_t tv_sec ;
   __syscall_slong_t tv_nsec ;
};
# 46 "/usr/include/x86_64-linux-gnu/bits/stat.h"
struct stat {
   __dev_t st_dev ;
   __ino_t st_ino ;
   __nlink_t st_nlink ;
   __mode_t st_mode ;
   __uid_t st_uid ;
   __gid_t st_gid ;
   int __pad0 ;
   __dev_t st_rdev ;
   __off_t st_size ;
   __blksize_t st_blksize ;
   __blkcnt_t st_blocks ;
   struct timespec st_atim ;
   struct timespec st_mtim ;
   struct timespec st_ctim ;
   __syscall_slong_t __glibc_reserved[3] ;
};
# 35 "/usr/include/ar.h"
struct ar_hdr {
   char ar_name[16] ;
   char ar_date[12] ;
   char ar_uid[6] ;
   char ar_gid[6] ;
   char ar_mode[8] ;
   char ar_size[10] ;
   char ar_fmag[2] ;
};
# 141 "/usr/include/x86_64-linux-gnu/bits/types.h"
typedef long __off64_t;
# 142 "/usr/include/x86_64-linux-gnu/bits/types.h"
typedef int __pid_t;
# 98 "/usr/include/x86_64-linux-gnu/sys/types.h"
typedef __pid_t pid_t;
# 72 "/usr/include/signal.h"
typedef void (*__sighandler_t)(int );
# 4 "/usr/include/x86_64-linux-gnu/bits/types/__FILE.h"
struct _IO_FILE;
# 4 "/usr/include/x86_64-linux-gnu/bits/types/__FILE.h"
struct _IO_FILE;
# 7 "/usr/include/x86_64-linux-gnu/bits/types/FILE.h"
typedef struct _IO_FILE FILE;
# 154 "/usr/include/x86_64-linux-gnu/bits/libio.h"
typedef void _IO_lock_t;
# 160 "/usr/include/x86_64-linux-gnu/bits/libio.h"
struct _IO_marker {
   struct _IO_marker *_next ;
   struct _IO_FILE *_sbuf ;
   int _pos ;
};
# 245 "/usr/include/x86_64-linux-gnu/bits/libio.h"
struct _IO_FILE {
   int _flags ;
   char *_IO_read_ptr ;
   char *_IO_read_end ;
   char *_IO_read_base ;
   char *_IO_write_base ;
   char *_IO_write_ptr ;
   char *_IO_write_end ;
   char *_IO_buf_base ;
   char *_IO_buf_end ;
   char *_IO_save_base ;
   char *_IO_backup_base ;
   char *_IO_save_end ;
   struct _IO_marker *_markers ;
   struct _IO_FILE *_chain ;
   int _fileno ;
   int _flags2 ;
   __off_t _old_offset ;
   unsigned short _cur_column ;
   signed char _vtable_offset ;
   char _shortbuf[1] ;
   _IO_lock_t *_lock ;
   __off64_t _offset ;
   void *__pad1 ;
   void *__pad2 ;
   void *__pad3 ;
   void *__pad4 ;
   size_t __pad5 ;
   int _mode ;
   char _unused2[(15UL * sizeof(int ) - 4UL * sizeof(void *)) - sizeof(size_t )] ;
};
# 22 "variable.h"
enum variable_origin {
    o_default = 0,
    o_env = 1,
    o_file = 2,
    o_env_override = 3,
    o_command = 4,
    o_override = 5,
    o_automatic = 6,
    o_invalid = 7
} ;
# 38 "variable.h"
enum variable_export {
    v_export = 0,
    v_noexport = 1,
    v_ifset = 2,
    v_default = 3
} ;
# 38 "variable.h"
struct variable {
   struct variable *next ;
   char *name ;
   char *value ;
   struct floc fileinfo ;
   enum variable_origin origin : 3 ;
   unsigned int recursive : 1 ;
   unsigned int expanding : 1 ;
   unsigned int per_target : 1 ;
   unsigned int append : 1 ;
   enum variable_export export : 2 ;
};
# 62 "variable.h"
struct variable_set {
   struct variable **table ;
   unsigned int buckets ;
};
# 70 "variable.h"
struct variable_set_list {
   struct variable_set_list *next ;
   struct variable_set *set ;
};
# 25 "job.h"
struct child {
   struct child *next ;
   struct file *file ;
   char **environment ;
   char **command_lines ;
   unsigned int command_line ;
   char *command_ptr ;
   pid_t pid ;
   char *sh_batch_file ;
   unsigned int remote : 1 ;
   unsigned int noerror : 1 ;
   unsigned int good_stdin : 1 ;
   unsigned int deleted : 1 ;
};
# 23 "commands.h"
struct commands {
   struct floc fileinfo ;
   char *commands ;
   unsigned int ncommand_lines ;
   char **command_lines ;
   char *lines_flags ;
   int any_recurse ;
};
# 48 "/usr/include/x86_64-linux-gnu/sys/types.h"
typedef __ino_t ino_t;
# 60 "/usr/include/x86_64-linux-gnu/sys/types.h"
typedef __dev_t dev_t;
# 22 "/usr/include/x86_64-linux-gnu/bits/dirent.h"
struct dirent {
   __ino_t d_ino ;
   __off_t d_off ;
   unsigned short d_reclen ;
   unsigned char d_type ;
   char d_name[256] ;
};
# 127 "/usr/include/dirent.h"
struct __dirstream;
# 127 "/usr/include/dirent.h"
struct __dirstream;
# 127 "/usr/include/dirent.h"
typedef struct __dirstream DIR;
# 217 "dir.c"
struct dirfile;
# 217 "dir.c"
struct dirfile;
# 217 "dir.c"
struct directory_contents {
   struct directory_contents *next ;
   dev_t dev ;
   ino_t ino ;
   struct dirfile **files ;
   DIR *dirstream ;
};
# 251 "dir.c"
struct directory {
   struct directory *next ;
   char *name ;
   struct directory_contents *contents ;
};
# 276 "dir.c"
struct dirfile {
   struct dirfile *next ;
   char *name ;
   char impossible ;
};
# 116 "./glob/glob.h"
struct __anonstruct_glob_t_56 {
   size_t gl_pathc ;
   char **gl_pathv ;
   size_t gl_offs ;
   int gl_flags ;
   void (*gl_closedir)(void * ) ;
   struct dirent *(*gl_readdir)(void * ) ;
   void *(*gl_opendir)(char const * ) ;
   int (*gl_lstat)(char const * , struct stat * ) ;
   int (*gl_stat)(char const * , struct stat * ) ;
};
# 116 "./glob/glob.h"
typedef struct __anonstruct_glob_t_56 glob_t;
# 991 "dir.c"
struct dirstream {
   struct directory_contents *contents ;
   unsigned int bucket ;
   struct dirfile *elt ;
};
# 156 "/usr/include/x86_64-linux-gnu/bits/types.h"
typedef int __clockid_t;
# 7 "/usr/include/x86_64-linux-gnu/bits/types/clockid_t.h"
typedef __clockid_t clockid_t;
# 7 "/usr/include/x86_64-linux-gnu/bits/types/struct_tm.h"
struct tm {
   int tm_sec ;
   int tm_min ;
   int tm_hour ;
   int tm_mday ;
   int tm_mon ;
   int tm_year ;
   int tm_wday ;
   int tm_yday ;
   int tm_isdst ;
   long tm_gmtoff ;
   char const *tm_zone ;
};
# 33 "function.c"
struct function_table_entry {
   char const *name ;
   unsigned char len ;
   unsigned char minimum_args ;
   unsigned char maximum_args ;
   char expand_args ;
   char *(*func_ptr)(char *output , char **argv , char const *fname ) ;
};
# 862 "function.c"
struct a_word {
   struct a_word *next ;
   char *str ;
   int matched ;
};
# 22 "rule.h"
struct rule {
   struct rule *next ;
   char **targets ;
   unsigned int *lens ;
   char **suffixes ;
   struct dep *deps ;
   struct commands *cmds ;
   char terminal ;
   char in_use ;
};
# 5 "/usr/include/x86_64-linux-gnu/bits/types/__sigset_t.h"
struct __anonstruct___sigset_t_2 {
   unsigned long __val[1024UL / (8UL * sizeof(unsigned long ))] ;
};
# 5 "/usr/include/x86_64-linux-gnu/bits/types/__sigset_t.h"
typedef struct __anonstruct___sigset_t_2 __sigset_t;
# 7 "/usr/include/x86_64-linux-gnu/bits/types/sigset_t.h"
typedef __sigset_t sigset_t;
# 41 "/usr/include/x86_64-linux-gnu/bits/types.h"
typedef unsigned int __uint32_t;
# 144 "/usr/include/x86_64-linux-gnu/bits/types.h"
typedef long __clock_t;
# 24 "/usr/include/x86_64-linux-gnu/bits/types/__sigval_t.h"
union sigval {
   int sival_int ;
   void *sival_ptr ;
};
# 30 "/usr/include/x86_64-linux-gnu/bits/types/__sigval_t.h"
typedef union sigval __sigval_t;
# 36 "/usr/include/x86_64-linux-gnu/bits/types/siginfo_t.h"
struct __anonstruct__kill_18 {
   __pid_t si_pid ;
   __uid_t si_uid ;
};
# 36 "/usr/include/x86_64-linux-gnu/bits/types/siginfo_t.h"
struct __anonstruct__timer_19 {
   int si_tid ;
   int si_overrun ;
   __sigval_t si_sigval ;
};
# 36 "/usr/include/x86_64-linux-gnu/bits/types/siginfo_t.h"
struct __anonstruct__rt_20 {
   __pid_t si_pid ;
   __uid_t si_uid ;
   __sigval_t si_sigval ;
};
# 36 "/usr/include/x86_64-linux-gnu/bits/types/siginfo_t.h"
struct __anonstruct__sigchld_21 {
   __pid_t si_pid ;
   __uid_t si_uid ;
   int si_status ;
   __clock_t si_utime ;
   __clock_t si_stime ;
};
# 36 "/usr/include/x86_64-linux-gnu/bits/types/siginfo_t.h"
struct __anonstruct__addr_bnd_24 {
   void *_lower ;
   void *_upper ;
};
# 36 "/usr/include/x86_64-linux-gnu/bits/types/siginfo_t.h"
union __anonunion__bounds_23 {
   struct __anonstruct__addr_bnd_24 _addr_bnd ;
   __uint32_t _pkey ;
};
# 36 "/usr/include/x86_64-linux-gnu/bits/types/siginfo_t.h"
struct __anonstruct__sigfault_22 {
   void *si_addr ;
   short si_addr_lsb ;
   union __anonunion__bounds_23 _bounds ;
};
# 36 "/usr/include/x86_64-linux-gnu/bits/types/siginfo_t.h"
struct __anonstruct__sigpoll_25 {
   long si_band ;
   int si_fd ;
};
# 36 "/usr/include/x86_64-linux-gnu/bits/types/siginfo_t.h"
struct __anonstruct__sigsys_26 {
   void *_call_addr ;
   int _syscall ;
   unsigned int _arch ;
};
# 36 "/usr/include/x86_64-linux-gnu/bits/types/siginfo_t.h"
union __anonunion__sifields_17 {
   int _pad[128UL / sizeof(int ) - 4UL] ;
   struct __anonstruct__kill_18 _kill ;
   struct __anonstruct__timer_19 _timer ;
   struct __anonstruct__rt_20 _rt ;
   struct __anonstruct__sigchld_21 _sigchld ;
   struct __anonstruct__sigfault_22 _sigfault ;
   struct __anonstruct__sigpoll_25 _sigpoll ;
   struct __anonstruct__sigsys_26 _sigsys ;
};
# 36 "/usr/include/x86_64-linux-gnu/bits/types/siginfo_t.h"
struct __anonstruct_siginfo_t_16 {
   int si_signo ;
   int si_errno ;
   int si_code ;
   int __pad0 ;
   union __anonunion__sifields_17 _sifields ;
};
# 36 "/usr/include/x86_64-linux-gnu/bits/types/siginfo_t.h"
typedef struct __anonstruct_siginfo_t_16 siginfo_t;
# 24 "/usr/include/x86_64-linux-gnu/bits/sigaction.h"
union __anonunion___sigaction_handler_37 {
   void (*sa_handler)(int ) ;
   void (*sa_sigaction)(int , siginfo_t * , void * ) ;
};
# 24 "/usr/include/x86_64-linux-gnu/bits/sigaction.h"
struct sigaction {
   union __anonunion___sigaction_handler_37 __sigaction_handler ;
   __sigset_t sa_mask ;
   int sa_flags ;
   void (*sa_restorer)(void) ;
};
# 81 "getopt.h"
struct option {
   char const *name ;
   int has_arg ;
   int *flag ;
   int val ;
};
# 81 "main.c"
enum __anonenum_type_56 {
    flag = 0,
    flag_off = 1,
    string = 2,
    positive_int = 3,
    floating = 4,
    ignore = 5
} ;
# 81 "main.c"
struct command_switch {
   int c ;
   enum __anonenum_type_56 type ;
   char *value_ptr ;
   unsigned int env : 1 ;
   unsigned int toenv : 1 ;
   unsigned int no_makefile : 1 ;
   char *noarg_value ;
   char *default_value ;
   char *long_name ;
   char *argdesc ;
   char *description ;
};
# 117 "main.c"
struct stringlist {
   char **list ;
   unsigned int idx ;
   unsigned int max ;
};
# 390 "main.c"
struct command_variable {
   struct command_variable *next ;
   struct variable *variable ;
};
# 2397 "main.c"
struct flag {
   struct flag *next ;
   struct command_switch const *cs ;
   char *arg ;
};
# 40 "/usr/lib/gcc/x86_64-linux-gnu/6/include/stdarg.h"
typedef __builtin_va_list __gnuc_va_list;
# 314 "/usr/include/x86_64-linux-gnu/bits/libio.h"
typedef struct _IO_FILE _IO_FILE;
# 46 "/usr/include/stdio.h"
typedef __gnuc_va_list va_list;
# 637 "misc.c"
enum __anonenum_current_access_55 {
    make = 0,
    user = 1
} ;
# 34 "rule.h"
struct pattern_var {
   struct pattern_var *next ;
   char *target ;
   unsigned int len ;
   char *suffix ;
   struct variable_set_list *vars ;
};
# 49 "/usr/include/pwd.h"
struct passwd {
   char *pw_name ;
   char *pw_passwd ;
   __uid_t pw_uid ;
   __gid_t pw_gid ;
   char *pw_gecos ;
   char *pw_dir ;
   char *pw_shell ;
};
# 49 "read.c"
struct linebuffer {
   unsigned int size ;
   char *buffer ;
};
# 63 "read.c"
enum make_word_type {
    w_bogus = 0,
    w_eol = 1,
    w_static = 2,
    w_variable = 3,
    w_colon = 4,
    w_dcolon = 5,
    w_semicolon = 6,
    w_comment = 7,
    w_varassign = 8
} ;
# 78 "read.c"
struct conditionals {
   unsigned int if_cmds ;
   unsigned int allocated ;
   char *ignoring ;
   char *seen_else ;
};
# 44 "rule.h"
struct pspec {
   char *target ;
   char *dep ;
   char *commands ;
};
# 60 "signame.c"
struct __anonstruct_num_abbrev_55 {
   int number ;
   char const *abbrev ;
};
# 60 "signame.c"
typedef struct __anonstruct_num_abbrev_55 num_abbrev;
# 588 "variable.c"
struct variable_bucket {
   struct variable_bucket *next ;
   struct variable *variable ;
};
# 792 "variable.c"
enum __anonenum_flavor_56 {
    f_bogus = 0,
    f_simple = 1,
    f_recursive = 2,
    f_append = 3,
    f_conditional = 4
} ;
# 30 "vpath.c"
struct vpath {
   struct vpath *next ;
   char *pattern ;
   char *percent ;
   unsigned int patlen ;
   char **searchpath ;
   unsigned int maxlen ;
};
# 111 "gettext.c"
struct loaded_l10nfile {
   char const *filename ;
   int decided ;
   void const *data ;
   struct loaded_l10nfile *next ;
   struct loaded_l10nfile *successor[1] ;
};
# 514 "gettext.c"
enum __anonenum_syntax_17 {
    undecided = 0,
    xpg = 1,
    cen = 2
} ;
# 713 "gettext.c"
typedef unsigned int nls_uint32;
# 729 "gettext.c"
struct mo_file_header {
   nls_uint32 magic ;
   nls_uint32 revision ;
   nls_uint32 nstrings ;
   nls_uint32 orig_tab_offset ;
   nls_uint32 trans_tab_offset ;
   nls_uint32 hash_tab_size ;
   nls_uint32 hash_tab_offset ;
};
# 747 "gettext.c"
struct string_desc {
   nls_uint32 length ;
   nls_uint32 offset ;
};
# 802 "gettext.c"
struct loaded_domain {
   char const *data ;
   int use_mmap ;
   size_t mmap_size ;
   int must_swap ;
   nls_uint32 nstrings ;
   struct string_desc *orig_tab ;
   struct string_desc *trans_tab ;
   nls_uint32 hash_size ;
   nls_uint32 *hash_tab ;
};
# 815 "gettext.c"
struct binding {
   struct binding *next ;
   char *domainname ;
   char *dirname ;
};
# 1099 "gettext.c"
struct alias_map {
   char const *alias ;
   char const *value ;
};
# 1 "ar.o"
#pragma merger("0","/tmp/cil-S4IQuXVr.i","-g,-O0")
# 101 "gettext.h"
char *dcgettext(char const *domainname , char const *msgid , int category ) ;
# 563 "/usr/include/stdlib.h"
extern __attribute__((__nothrow__)) void ( __attribute__((__leaf__)) free)(void *__ptr ) ;
# 827 "/usr/include/stdlib.h"
extern void ( __attribute__((__nonnull__(1,4))) qsort)(void *__base , size_t __nmemb ,
                                                       size_t __size , int (*__compar)(void const * ,
                                                                                       void const * ) ) ;
# 46 "/usr/include/string.h"
extern __attribute__((__nothrow__)) void *( __attribute__((__nonnull__(1,2), __leaf__)) memmove)(void *__dest ,
                                                                                                  void const *__src ,
                                                                                                  size_t __n ) ;
# 225 "/usr/include/string.h"
extern __attribute__((__nothrow__)) char *( __attribute__((__nonnull__(1), __leaf__)) strchr)(char const *__s ,
                                                                                               int __c ) __attribute__((__pure__)) ;
# 384 "/usr/include/string.h"
extern __attribute__((__nothrow__)) size_t ( __attribute__((__nonnull__(1), __leaf__)) strlen)(char const *__s ) __attribute__((__pure__)) ;
# 379 "make.h"
void error(struct floc const *flocp , char const *fmt , ...) ;
# 381 "make.h"
 __attribute__((__noreturn__)) void fatal(struct floc const *flocp , char const *fmt
                                          , ...) ;
# 392 "make.h"
void perror_with_name(char *str , char *name ) ;
# 393 "make.h"
char *savestring(char const *str , unsigned int length___0 ) ;
# 394 "make.h"
char *concat(char *s1 , char *s2 , char *s3 ) ;
# 395 "make.h"
char *xmalloc(unsigned int size ) ;
# 406 "make.h"
int alpha_compare(void const *v1 , void const *v2 ) ;
# 413 "make.h"
int ar_name(char *name ) ;
# 414 "make.h"
void ar_parse_name(char *name , char **arname_p , char **memname_p ) ;
# 415 "make.h"
int ar_touch(char *name ) ;
# 416 "make.h"
time_t ar_member_date(char *name ) ;
# 420 "make.h"
int file_exists_p(char *name ) ;
# 108 "filedef.h"
struct file *lookup_file(char *name ) ;
# 109 "filedef.h"
struct file *enter_file(char *name ) ;
# 173 "filedef.h"
uintmax_t f_mtime(struct file *file , int search ) ;
# 63 "dep.h"
struct nameseq *ar_glob(char *arname , char *member_pattern , unsigned int size ) ;
# 77 "./glob/fnmatch.h"
extern int fnmatch(char const *__pattern , char const *__name , int __flags ) ;
# 29 "ar.c"
long ar_scan(char *archive , long (*function)() , long arg ) ;
# 30 "ar.c"
int ar_name_equal(char *name , char *mem , int truncated ) ;
# 32 "ar.c"
int ar_member_touch(char *arname , char *memname ) ;
# 40 "ar.c"
int ar_name(char *name )
{
  char *p ;
  char *tmp ;
  char *end ;
  size_t tmp___0 ;
  char *tmp___1 ;

  {
  {
# 44 "ar.c"
  tmp = strchr((char const *)name, '(');
# 44 "ar.c"
  p = tmp;
# 44 "ar.c"
  tmp___0 = strlen((char const *)name);
# 44 "ar.c"
  end = (name + tmp___0) - 1;
  }
# 46 "ar.c"
  if ((unsigned long )p == (unsigned long )((char *)0)) {
# 47 "ar.c"
    return (0);
  } else
# 46 "ar.c"
  if ((unsigned long )p == (unsigned long )name) {
# 47 "ar.c"
    return (0);
  } else
# 46 "ar.c"
  if ((int )*end != 41) {
# 47 "ar.c"
    return (0);
  }
# 49 "ar.c"
  if ((int )*(p + 1) == 40) {
# 49 "ar.c"
    if ((int )*(end + -1) == 41) {
      {
# 50 "ar.c"
      tmp___1 = dcgettext((char const *)((void *)0), "attempt to use unsupported feature: `%s\'",
                          5);
# 50 "ar.c"
      fatal((struct floc const *)((struct floc *)0), (char const *)tmp___1, name);
      }
    }
  }
# 52 "ar.c"
  return (1);
}
}
# 60 "ar.c"
void ar_parse_name(char *name , char **arname_p , char **memname_p )
{
  char *p ;
  char *tmp ;
  char *end ;
  size_t tmp___0 ;

  {
  {
# 64 "ar.c"
  tmp = strchr((char const *)name, '(');
# 64 "ar.c"
  p = tmp;
# 64 "ar.c"
  tmp___0 = strlen((char const *)name);
# 64 "ar.c"
  end = (name + tmp___0) - 1;
  }
# 66 "ar.c"
  if ((unsigned long )arname_p != (unsigned long )((char **)0)) {
    {
# 67 "ar.c"
    *arname_p = savestring((char const *)name, (unsigned int )(p - name));
    }
  }
# 69 "ar.c"
  if ((unsigned long )memname_p != (unsigned long )((char **)0)) {
    {
# 70 "ar.c"
    *memname_p = savestring((char const *)(p + 1), (unsigned int )(end - (p + 1)));
    }
  }
# 71 "ar.c"
  return;
}
}
# 73 "ar.c"
static long ar_member_date_1(int desc , char *mem , int truncated , long hdrpos ,
                             long datapos , long size , long date , int uid , int gid ,
                             int mode , char *name ) ;
# 78 "ar.c"
time_t ar_member_date(char *name )
{
  char *arname ;
  int arname_used ;
  char *memname ;
  long val ;
  struct file *arfile ;
  int tmp ;
  time_t tmp___0 ;

  {
  {
# 83 "ar.c"
  arname_used = 0;
# 87 "ar.c"
  ar_parse_name(name, & arname, & memname);
# 98 "ar.c"
  arfile = lookup_file(arname);
  }
# 99 "ar.c"
  if ((unsigned long )arfile == (unsigned long )((struct file *)0)) {
    {
# 99 "ar.c"
    tmp = file_exists_p(arname);
    }
# 99 "ar.c"
    if (tmp) {
      {
# 101 "ar.c"
      arfile = enter_file(arname);
# 102 "ar.c"
      arname_used = 1;
      }
    }
  }
# 105 "ar.c"
  if ((unsigned long )arfile != (unsigned long )((struct file *)0)) {
    {
# 106 "ar.c"
    f_mtime(arfile, 0);
    }
  }
  {
# 109 "ar.c"
  val = ar_scan(arname, (long (*)())(& ar_member_date_1), (long )memname);
  }
# 111 "ar.c"
  if (! arname_used) {
    {
# 112 "ar.c"
    free((void *)arname);
    }
  }
  {
# 113 "ar.c"
  free((void *)memname);
  }
# 115 "ar.c"
  if (val <= 0L) {
# 115 "ar.c"
    tmp___0 = (time_t )-1;
  } else {
# 115 "ar.c"
    tmp___0 = val;
  }
# 115 "ar.c"
  return (tmp___0);
}
}
# 121 "ar.c"
static long ar_member_date_1(int desc , char *mem , int truncated , long hdrpos ,
                             long datapos , long size , long date , int uid , int gid ,
                             int mode , char *name )
{
  long tmp___0 ;
  int tmp___1 ;

  {
  {
# 131 "ar.c"
  tmp___1 = ar_name_equal(name, mem, truncated);
  }
# 131 "ar.c"
  if (tmp___1) {
# 131 "ar.c"
    tmp___0 = date;
  } else {
# 131 "ar.c"
    tmp___0 = 0L;
  }
# 131 "ar.c"
  return (tmp___0);
}
}
# 145 "ar.c"
int ar_touch(char *name )
{
  char *arname ;
  char *memname ;
  int arname_used ;
  register int val ;
  struct file *arfile ;
  int tmp ;
  char *tmp___0 ;
  char *tmp___1 ;
  char *tmp___2 ;
  char *tmp___3 ;

  {
  {
# 150 "ar.c"
  arname_used = 0;
# 153 "ar.c"
  ar_parse_name(name, & arname, & memname);
# 159 "ar.c"
  arfile = lookup_file(arname);
  }
# 160 "ar.c"
  if ((unsigned long )arfile == (unsigned long )((struct file *)0)) {
    {
# 162 "ar.c"
    arfile = enter_file(arname);
# 163 "ar.c"
    arname_used = 1;
    }
  }
  {
# 166 "ar.c"
  f_mtime(arfile, 0);
# 169 "ar.c"
  val = 1;
# 170 "ar.c"
  tmp = ar_member_touch(arname, memname);
  }
  {
# 171 "ar.c"
  if (tmp == -1) {
# 171 "ar.c"
    goto case_neg_1;
  }
# 175 "ar.c"
  if (tmp == -2) {
# 175 "ar.c"
    goto case_neg_2;
  }
# 178 "ar.c"
  if (tmp == -3) {
# 178 "ar.c"
    goto case_neg_3;
  }
# 181 "ar.c"
  if (tmp == 1) {
# 181 "ar.c"
    goto case_1;
  }
# 185 "ar.c"
  if (tmp == 0) {
# 185 "ar.c"
    goto case_0;
  }
# 188 "ar.c"
  goto switch_default;
  case_neg_1:
  {
# 173 "ar.c"
  tmp___0 = dcgettext((char const *)((void *)0), "touch: Archive `%s\' does not exist",
                      5);
# 173 "ar.c"
  error((struct floc const *)((struct floc *)0), (char const *)tmp___0, arname);
  }
# 174 "ar.c"
  goto switch_break;
  case_neg_2:
  {
# 176 "ar.c"
  tmp___1 = dcgettext((char const *)((void *)0), "touch: `%s\' is not a valid archive",
                      5);
# 176 "ar.c"
  error((struct floc const *)((struct floc *)0), (char const *)tmp___1, arname);
  }
# 177 "ar.c"
  goto switch_break;
  case_neg_3:
  {
# 179 "ar.c"
  perror_with_name((char *)"touch: ", arname);
  }
# 180 "ar.c"
  goto switch_break;
  case_1:
  {
# 182 "ar.c"
  tmp___2 = dcgettext((char const *)((void *)0), "touch: Member `%s\' does not exist in `%s\'",
                      5);
# 182 "ar.c"
  error((struct floc const *)((struct floc *)0), (char const *)tmp___2, memname,
        arname);
  }
# 184 "ar.c"
  goto switch_break;
  case_0:
# 186 "ar.c"
  val = 0;
# 187 "ar.c"
  goto switch_break;
  switch_default:
  {
# 189 "ar.c"
  tmp___3 = dcgettext((char const *)((void *)0), "touch: Bad return code from ar_member_touch on `%s\'",
                      5);
# 189 "ar.c"
  error((struct floc const *)((struct floc *)0), (char const *)tmp___3, name);
  }
  switch_break: ;
  }
# 193 "ar.c"
  if (! arname_used) {
    {
# 194 "ar.c"
    free((void *)arname);
    }
  }
  {
# 195 "ar.c"
  free((void *)memname);
  }
# 197 "ar.c"
  return (val);
}
}
# 215 "ar.c"
static long ar_glob_match(int desc , char *mem , int truncated , long hdrpos , long datapos ,
                          long size , long date , int uid , int gid , int mode , struct ar_glob_state *state )
{
  struct nameseq *new ;
  char *tmp ;
  int tmp___0 ;

  {
  {
# 226 "ar.c"
  tmp___0 = fnmatch((char const *)state->pattern, (char const *)mem, 1 | (1 << 2));
  }
# 226 "ar.c"
  if (tmp___0 == 0) {
    {
# 229 "ar.c"
    tmp = xmalloc(state->size);
# 229 "ar.c"
    new = (struct nameseq *)tmp;
# 230 "ar.c"
    new->name = concat(state->arname, mem, (char *)")");
# 231 "ar.c"
    new->next = state->chain;
# 232 "ar.c"
    state->chain = new;
# 233 "ar.c"
    (state->n) ++;
    }
  }
# 236 "ar.c"
  return (0L);
}
}
# 241 "ar.c"
static int glob_pattern_p(char const *pattern , int const quote )
{
  register char const *p ;
  int open___0 ;

  {
# 247 "ar.c"
  open___0 = 0;
# 249 "ar.c"
  p = pattern;
  {
# 249 "ar.c"
  while (1) {
    while_continue: ;
# 249 "ar.c"
    if (! ((int const )*p != 0)) {
# 249 "ar.c"
      goto while_break;
    }
    {
# 252 "ar.c"
    if ((int const )*p == 63) {
# 252 "ar.c"
      goto case_63;
    }
# 252 "ar.c"
    if ((int const )*p == 42) {
# 252 "ar.c"
      goto case_63;
    }
# 255 "ar.c"
    if ((int const )*p == 92) {
# 255 "ar.c"
      goto case_92;
    }
# 260 "ar.c"
    if ((int const )*p == 91) {
# 260 "ar.c"
      goto case_91;
    }
# 264 "ar.c"
    if ((int const )*p == 93) {
# 264 "ar.c"
      goto case_93;
    }
# 250 "ar.c"
    goto switch_break;
    case_63:
    case_42:
# 254 "ar.c"
    return (1);
    case_92:
# 257 "ar.c"
    if (quote) {
# 258 "ar.c"
      p ++;
    }
# 259 "ar.c"
    goto switch_break;
    case_91:
# 262 "ar.c"
    open___0 = 1;
# 263 "ar.c"
    goto switch_break;
    case_93:
# 266 "ar.c"
    if (open___0) {
# 267 "ar.c"
      return (1);
    }
# 268 "ar.c"
    goto switch_break;
    switch_break: ;
    }
# 249 "ar.c"
    p ++;
  }
  while_break: ;
  }
# 271 "ar.c"
  return (0);
}
}
# 277 "ar.c"
struct nameseq *ar_glob(char *arname , char *member_pattern , unsigned int size )
{
  struct ar_glob_state state ;
  char **names ;
  struct nameseq *n ;
  unsigned int i ;
  int tmp ;
  size_t tmp___0 ;
  void *tmp___1 ;
  void *tmp___2 ;
  unsigned int tmp___3 ;
  unsigned int tmp___4 ;

  {
  {
# 287 "ar.c"
  tmp = glob_pattern_p((char const *)member_pattern, (int const )1);
  }
# 287 "ar.c"
  if (! tmp) {
# 288 "ar.c"
    return ((struct nameseq *)0);
  }
  {
# 292 "ar.c"
  tmp___0 = strlen((char const *)arname);
# 292 "ar.c"
  i = (unsigned int )tmp___0;
# 293 "ar.c"
  tmp___1 = __builtin_alloca((unsigned long )(i + 2U));
# 293 "ar.c"
  state.arname = (char *)tmp___1;
# 294 "ar.c"
  memmove((void *)state.arname, (void const *)arname, (size_t )i);
# 295 "ar.c"
  *(state.arname + i) = (char )'(';
# 296 "ar.c"
  *(state.arname + (i + 1U)) = (char )'\000';
# 297 "ar.c"
  state.pattern = member_pattern;
# 298 "ar.c"
  state.size = size;
# 299 "ar.c"
  state.chain = (struct nameseq *)0;
# 300 "ar.c"
  state.n = 0U;
# 301 "ar.c"
  ar_scan(arname, (long (*)())(& ar_glob_match), (long )(& state));
  }
# 303 "ar.c"
  if ((unsigned long )state.chain == (unsigned long )((struct nameseq *)0)) {
# 304 "ar.c"
    return ((struct nameseq *)0);
  }
  {
# 307 "ar.c"
  tmp___2 = __builtin_alloca((unsigned long )state.n * sizeof(char *));
# 307 "ar.c"
  names = (char **)tmp___2;
# 308 "ar.c"
  i = 0U;
# 309 "ar.c"
  n = state.chain;
  }
  {
# 309 "ar.c"
  while (1) {
    while_continue: ;
# 309 "ar.c"
    if (! ((unsigned long )n != (unsigned long )((struct nameseq *)0))) {
# 309 "ar.c"
      goto while_break;
    }
# 310 "ar.c"
    tmp___3 = i;
# 310 "ar.c"
    i ++;
# 310 "ar.c"
    *(names + tmp___3) = n->name;
# 309 "ar.c"
    n = n->next;
  }
  while_break: ;
  }
  {
# 313 "ar.c"
  qsort((void *)((char *)names), (size_t )i, sizeof(*names), & alpha_compare);
# 316 "ar.c"
  i = 0U;
# 317 "ar.c"
  n = state.chain;
  }
  {
# 317 "ar.c"
  while (1) {
    while_continue___0: ;
# 317 "ar.c"
    if (! ((unsigned long )n != (unsigned long )((struct nameseq *)0))) {
# 317 "ar.c"
      goto while_break___0;
    }
# 318 "ar.c"
    tmp___4 = i;
# 318 "ar.c"
    i ++;
# 318 "ar.c"
    n->name = *(names + tmp___4);
# 317 "ar.c"
    n = n->next;
  }
  while_break___0: ;
  }
# 320 "ar.c"
  return (state.chain);
}
}
# 1 "arscan.o"
#pragma merger("0","/tmp/cil-M34r4uwp.i","-g,-O0")
# 210 "/usr/include/x86_64-linux-gnu/sys/stat.h"
extern __attribute__((__nothrow__)) int ( __attribute__((__nonnull__(2), __leaf__)) fstat)(int __fd ,
                                                                                            struct stat *__buf ) ;
# 320 "/usr/include/stdio.h"
extern __attribute__((__nothrow__)) int sprintf(char * __restrict __s , char const * __restrict __format
                                                 , ...) ;
# 385 "/usr/include/stdio.h"
extern __attribute__((__nothrow__)) int ( __attribute__((__leaf__)) sscanf)(char const * __restrict __s ,
                                                                             char const * __restrict __format
                                                                             , ...) __asm__("__isoc99_sscanf") ;
# 37 "/usr/include/errno.h"
extern __attribute__((__nothrow__)) int *( __attribute__((__leaf__)) __errno_location)(void) __attribute__((__const__)) ;
# 337 "/usr/include/unistd.h"
extern __attribute__((__nothrow__)) __off_t ( __attribute__((__leaf__)) lseek)(int __fd ,
                                                                                __off_t __offset ,
                                                                                int __whence ) ;
# 356 "/usr/include/unistd.h"
extern int close(int __fd ) ;
# 363 "/usr/include/unistd.h"
extern ssize_t read(int __fd , void *__buf , size_t __nbytes ) ;
# 369 "/usr/include/unistd.h"
extern ssize_t write(int __fd , void const *__buf , size_t __n ) ;
# 104 "/usr/include/stdlib.h"
extern __attribute__((__nothrow__)) int ( __attribute__((__nonnull__(1), __leaf__)) atoi)(char const *__nptr ) __attribute__((__pure__)) ;
# 107 "/usr/include/stdlib.h"
extern __attribute__((__nothrow__)) long ( __attribute__((__nonnull__(1), __leaf__)) atol)(char const *__nptr ) __attribute__((__pure__)) ;
# 63 "/usr/include/string.h"
extern __attribute__((__nothrow__)) int ( __attribute__((__nonnull__(1,2), __leaf__)) memcmp)(void const *__s1 ,
                                                                                               void const *__s2 ,
                                                                                               size_t __n ) __attribute__((__pure__)) ;
# 136 "/usr/include/string.h"
extern __attribute__((__nothrow__)) int ( __attribute__((__nonnull__(1,2), __leaf__)) strcmp)(char const *__s1 ,
                                                                                               char const *__s2 ) __attribute__((__pure__)) ;
# 139 "/usr/include/string.h"
extern __attribute__((__nothrow__)) int ( __attribute__((__nonnull__(1,2), __leaf__)) strncmp)(char const *__s1 ,
                                                                                                char const *__s2 ,
                                                                                                size_t __n ) __attribute__((__pure__)) ;
# 252 "/usr/include/string.h"
extern __attribute__((__nothrow__)) char *( __attribute__((__nonnull__(1), __leaf__)) strrchr)(char const *__s ,
                                                                                                int __c ) __attribute__((__pure__)) ;
# 157 "/usr/include/fcntl.h"
extern int ( __attribute__((__nonnull__(1))) open)(char const *__file , int __oflag
                                                   , ...) ;
# 286 "arscan.c"
long ar_scan(char *archive , long (*function)() , long arg )
{
  int long_name ;
  char *namemap ;
  register int desc ;
  int tmp ;
  char buf___1[8] ;
  register int nread ;
  ssize_t tmp___0 ;
  int tmp___1 ;
  register long member_offset ;
  register int nread___0 ;
  struct ar_hdr member_header ;
  char namebuf[sizeof(member_header.ar_name) + 1UL] ;
  char *name ;
  int is_namemap ;
  long eltsize ;
  int eltmode ;
  long fnval ;
  __off_t tmp___2 ;
  ssize_t tmp___3 ;
  int tmp___4 ;
  register char *p ;
  int tmp___5 ;
  int tmp___6 ;
  int tmp___7 ;
  int tmp___8 ;
  int namesize ;
  int tmp___9 ;
  void *tmp___10 ;
  ssize_t tmp___11 ;
  int tmp___12 ;
  int tmp___13 ;
  long tmp___14 ;
  char *clear ;
  char *limit ;
  void *tmp___15 ;
  ssize_t tmp___16 ;

  {
  {
# 299 "arscan.c"
  long_name = 0;
# 301 "arscan.c"
  namemap = (char *)0;
# 302 "arscan.c"
  tmp = open((char const *)archive, 0, 0);
# 302 "arscan.c"
  desc = tmp;
  }
# 303 "arscan.c"
  if (desc < 0) {
# 304 "arscan.c"
    return (-1L);
  }
  {
# 308 "arscan.c"
  tmp___0 = read(desc, (void *)(buf___1), (size_t )8);
# 308 "arscan.c"
  nread = (int )tmp___0;
  }
# 309 "arscan.c"
  if (nread != 8) {
    {
# 311 "arscan.c"
    close(desc);
    }
# 312 "arscan.c"
    return (-2L);
  } else {
    {
# 309 "arscan.c"
    tmp___1 = memcmp((void const *)(buf___1), (void const *)"!<arch>\n", (size_t )8);
    }
# 309 "arscan.c"
    if (tmp___1) {
      {
# 311 "arscan.c"
      close(desc);
      }
# 312 "arscan.c"
      return (-2L);
    }
  }
# 376 "arscan.c"
  member_offset = 8L;
  {
# 410 "arscan.c"
  while (1) {
    while_continue: ;
    {
# 432 "arscan.c"
    tmp___2 = lseek(desc, member_offset, 0);
    }
# 432 "arscan.c"
    if (tmp___2 < 0L) {
      {
# 434 "arscan.c"
      close(desc);
      }
# 435 "arscan.c"
      return (-2L);
    }
    {
# 514 "arscan.c"
    tmp___3 = read(desc, (void *)((char *)(& member_header)), sizeof(struct ar_hdr ));
# 514 "arscan.c"
    nread___0 = (int )tmp___3;
    }
# 515 "arscan.c"
    if (nread___0 == 0) {
# 517 "arscan.c"
      goto while_break;
    }
# 519 "arscan.c"
    if ((unsigned long )nread___0 != sizeof(struct ar_hdr )) {
      {
# 537 "arscan.c"
      close(desc);
      }
# 538 "arscan.c"
      return (-2L);
    } else {
      {
# 519 "arscan.c"
      tmp___4 = memcmp((void const *)(member_header.ar_fmag), (void const *)"`\n",
                       (size_t )2);
      }
# 519 "arscan.c"
      if (tmp___4) {
        {
# 537 "arscan.c"
        close(desc);
        }
# 538 "arscan.c"
        return (-2L);
      }
    }
    {
# 541 "arscan.c"
    name = namebuf;
# 542 "arscan.c"
    memmove((void *)name, (void const *)(member_header.ar_name), sizeof(member_header.ar_name));
# 544 "arscan.c"
    p = name + sizeof(member_header.ar_name);
    }
    {
# 545 "arscan.c"
    while (1) {
      while_continue___0: ;
# 546 "arscan.c"
      *p = (char )'\000';
# 545 "arscan.c"
      if ((unsigned long )p > (unsigned long )name) {
# 545 "arscan.c"
        p --;
# 545 "arscan.c"
        if (! ((int )*p == 32)) {
# 545 "arscan.c"
          goto while_break___0;
        }
      } else {
# 545 "arscan.c"
        goto while_break___0;
      }
    }
    while_break___0: ;
    }
    {
# 556 "arscan.c"
    tmp___5 = strcmp((char const *)name, "//");
    }
# 556 "arscan.c"
    if (tmp___5) {
      {
# 556 "arscan.c"
      tmp___6 = strcmp((char const *)name, "ARFILENAMES/");
      }
# 556 "arscan.c"
      if (tmp___6) {
# 556 "arscan.c"
        tmp___7 = 0;
      } else {
# 556 "arscan.c"
        tmp___7 = 1;
      }
    } else {
# 556 "arscan.c"
      tmp___7 = 1;
    }
# 556 "arscan.c"
    is_namemap = tmp___7;
# 560 "arscan.c"
    if ((int )*p == 47) {
# 561 "arscan.c"
      *p = (char )'\000';
    }
# 569 "arscan.c"
    if (! is_namemap) {
# 569 "arscan.c"
      if ((int )*(name + 0) == 32) {
# 569 "arscan.c"
        goto _L___1;
      } else
# 569 "arscan.c"
      if ((int )*(name + 0) == 47) {
        _L___1:
# 569 "arscan.c"
        if ((unsigned long )namemap != (unsigned long )((char *)0)) {
          {
# 573 "arscan.c"
          tmp___8 = atoi((char const *)(name + 1));
# 573 "arscan.c"
          name = namemap + tmp___8;
# 574 "arscan.c"
          long_name = 1;
          }
        } else {
# 569 "arscan.c"
          goto _L___0;
        }
      } else {
# 569 "arscan.c"
        goto _L___0;
      }
    } else
    _L___0:
# 576 "arscan.c"
    if ((int )*(name + 0) == 35) {
# 576 "arscan.c"
      if ((int )*(name + 1) == 49) {
# 576 "arscan.c"
        if ((int )*(name + 2) == 47) {
          {
# 580 "arscan.c"
          tmp___9 = atoi((char const *)(name + 3));
# 580 "arscan.c"
          namesize = tmp___9;
# 582 "arscan.c"
          tmp___10 = __builtin_alloca((unsigned long )(namesize + 1));
# 582 "arscan.c"
          name = (char *)tmp___10;
# 583 "arscan.c"
          tmp___11 = read(desc, (void *)name, (size_t )namesize);
# 583 "arscan.c"
          nread___0 = (int )tmp___11;
          }
# 584 "arscan.c"
          if (nread___0 != namesize) {
            {
# 586 "arscan.c"
            close(desc);
            }
# 587 "arscan.c"
            return (-2L);
          }
# 589 "arscan.c"
          *(name + namesize) = (char )'\000';
# 591 "arscan.c"
          long_name = 1;
        }
      }
    }
    {
# 597 "arscan.c"
    sscanf((char const * __restrict )(member_header.ar_mode), (char const * __restrict )"%o",
           & eltmode);
# 598 "arscan.c"
    eltsize = atol((char const *)(member_header.ar_size));
# 604 "arscan.c"
    tmp___12 = atoi((char const *)(member_header.ar_gid));
# 604 "arscan.c"
    tmp___13 = atoi((char const *)(member_header.ar_uid));
# 604 "arscan.c"
    tmp___14 = atol((char const *)(member_header.ar_date));
# 604 "arscan.c"
    fnval = (*function)(desc, name, ! long_name, member_offset, (unsigned long )member_offset + sizeof(struct ar_hdr ),
                        eltsize, tmp___14, tmp___13, tmp___12, eltmode, arg);
    }
# 620 "arscan.c"
    if (fnval) {
      {
# 622 "arscan.c"
      close(desc);
      }
# 623 "arscan.c"
      return (fnval);
    }
# 648 "arscan.c"
    if (is_namemap) {
      {
# 653 "arscan.c"
      tmp___15 = __builtin_alloca((unsigned long )eltsize);
# 653 "arscan.c"
      namemap = (char *)tmp___15;
# 654 "arscan.c"
      tmp___16 = read(desc, (void *)namemap, (size_t )eltsize);
# 654 "arscan.c"
      nread___0 = (int )tmp___16;
      }
# 655 "arscan.c"
      if ((long )nread___0 != eltsize) {
        {
# 657 "arscan.c"
        close(desc);
        }
# 658 "arscan.c"
        return (-2L);
      }
# 664 "arscan.c"
      limit = namemap + eltsize;
# 665 "arscan.c"
      clear = namemap;
      {
# 665 "arscan.c"
      while (1) {
        while_continue___1: ;
# 665 "arscan.c"
        if (! ((unsigned long )clear < (unsigned long )limit)) {
# 665 "arscan.c"
          goto while_break___1;
        }
# 667 "arscan.c"
        if ((int )*clear == 10) {
# 669 "arscan.c"
          *clear = (char )'\000';
# 670 "arscan.c"
          if ((int )*(clear + -1) == 47) {
# 671 "arscan.c"
            *(clear + -1) = (char )'\000';
          }
        }
# 665 "arscan.c"
        clear ++;
      }
      while_break___1: ;
      }
# 675 "arscan.c"
      is_namemap = 0;
    }
# 678 "arscan.c"
    member_offset = (long )((unsigned long )member_offset + (sizeof(struct ar_hdr ) + (unsigned long )eltsize));
# 679 "arscan.c"
    if (member_offset % 2L != 0L) {
# 680 "arscan.c"
      member_offset ++;
    }
  }
  while_break: ;
  }
  {
# 685 "arscan.c"
  close(desc);
  }
# 686 "arscan.c"
  return (0L);
}
}
# 694 "arscan.c"
int ar_name_equal(char *name , char *mem , int truncated )
{
  char *p ;
  struct ar_hdr hdr ;
  int tmp ;
  int tmp___0 ;
  int tmp___1 ;

  {
  {
# 701 "arscan.c"
  p = strrchr((char const *)name, '/');
  }
# 702 "arscan.c"
  if ((unsigned long )p != (unsigned long )((char *)0)) {
# 703 "arscan.c"
    name = p + 1;
  }
# 706 "arscan.c"
  if (truncated) {
    {
# 714 "arscan.c"
    tmp = strncmp((char const *)name, (char const *)mem, sizeof(hdr.ar_name) - 1UL);
    }
# 714 "arscan.c"
    return (tmp == 0);
  }
  {
# 722 "arscan.c"
  tmp___0 = strcmp((char const *)name, (char const *)mem);
  }
# 722 "arscan.c"
  if (tmp___0) {
# 722 "arscan.c"
    tmp___1 = 0;
  } else {
# 722 "arscan.c"
    tmp___1 = 1;
  }
# 722 "arscan.c"
  return (tmp___1);
}
}
# 727 "arscan.c"
static long ar_member_pos(int desc , char *mem , int truncated , long hdrpos , long datapos ,
                          long size , long date , int uid , int gid , int mode , char *name )
{
  int tmp ;

  {
  {
# 737 "arscan.c"
  tmp = ar_name_equal(name, mem, truncated);
  }
# 737 "arscan.c"
  if (! tmp) {
# 738 "arscan.c"
    return (0L);
  }
# 739 "arscan.c"
  return (hdrpos);
}
}
# 749 "arscan.c"
int ar_member_touch(char *arname , char *memname )
{
  register long pos ;
  long tmp ;
  register int fd ;
  struct ar_hdr ar_hdr ;
  register int i ;
  struct stat statbuf ;
  __off_t tmp___0 ;
  ssize_t tmp___1 ;
  __off_t tmp___2 ;
  ssize_t tmp___3 ;
  int tmp___4 ;
  int *tmp___5 ;
  __off_t tmp___6 ;
  ssize_t tmp___7 ;
  int *tmp___8 ;
  int *tmp___9 ;

  {
  {
# 753 "arscan.c"
  tmp = ar_scan(arname, (long (*)())(& ar_member_pos), (long )memname);
# 753 "arscan.c"
  pos = tmp;
  }
# 759 "arscan.c"
  if (pos < 0L) {
# 760 "arscan.c"
    return ((int )pos);
  }
# 761 "arscan.c"
  if (! pos) {
# 762 "arscan.c"
    return (1);
  }
  {
# 764 "arscan.c"
  fd = open((char const *)arname, 2, 438);
  }
# 765 "arscan.c"
  if (fd < 0) {
# 766 "arscan.c"
    return (-3);
  }
  {
# 768 "arscan.c"
  tmp___0 = lseek(fd, pos, 0);
  }
# 768 "arscan.c"
  if (tmp___0 < 0L) {
# 769 "arscan.c"
    goto lose;
  }
  {
# 770 "arscan.c"
  tmp___1 = read(fd, (void *)((char *)(& ar_hdr)), sizeof(struct ar_hdr ));
  }
# 770 "arscan.c"
  if (sizeof(struct ar_hdr ) != (unsigned long )tmp___1) {
# 771 "arscan.c"
    goto lose;
  }
  {
# 773 "arscan.c"
  tmp___2 = lseek(fd, pos, 0);
  }
# 773 "arscan.c"
  if (tmp___2 < 0L) {
# 774 "arscan.c"
    goto lose;
  }
  {
# 775 "arscan.c"
  tmp___3 = write(fd, (void const *)((char *)(& ar_hdr)), sizeof(struct ar_hdr ));
  }
# 775 "arscan.c"
  if (sizeof(struct ar_hdr ) != (unsigned long )tmp___3) {
# 776 "arscan.c"
    goto lose;
  }
  {
# 778 "arscan.c"
  while (1) {
    while_continue: ;
    {
# 778 "arscan.c"
    tmp___4 = fstat(fd, & statbuf);
    }
# 778 "arscan.c"
    if (tmp___4 < 0) {
      {
# 778 "arscan.c"
      tmp___5 = __errno_location();
      }
# 778 "arscan.c"
      if (! (*tmp___5 == 4)) {
# 778 "arscan.c"
        goto while_break;
      }
    } else {
# 778 "arscan.c"
      goto while_break;
    }
  }
  while_break: ;
  }
# 782 "arscan.c"
  i = 0;
  {
# 782 "arscan.c"
  while (1) {
    while_continue___0: ;
# 782 "arscan.c"
    if (! ((unsigned long )i < sizeof(ar_hdr.ar_date))) {
# 782 "arscan.c"
      goto while_break___0;
    }
# 783 "arscan.c"
    ar_hdr.ar_date[i] = (char )' ';
# 782 "arscan.c"
    i ++;
  }
  while_break___0: ;
  }
  {
# 784 "arscan.c"
  sprintf((char * __restrict )(ar_hdr.ar_date), (char const * __restrict )"%ld",
          statbuf.st_mtim.tv_sec);
# 792 "arscan.c"
  tmp___6 = lseek(fd, pos, 0);
  }
# 792 "arscan.c"
  if (tmp___6 < 0L) {
# 793 "arscan.c"
    goto lose;
  }
  {
# 794 "arscan.c"
  tmp___7 = write(fd, (void const *)((char *)(& ar_hdr)), sizeof(struct ar_hdr ));
  }
# 794 "arscan.c"
  if (sizeof(struct ar_hdr ) != (unsigned long )tmp___7) {
# 795 "arscan.c"
    goto lose;
  }
  {
# 796 "arscan.c"
  close(fd);
  }
# 797 "arscan.c"
  return (0);
  lose:
  {
# 800 "arscan.c"
  tmp___8 = __errno_location();
# 800 "arscan.c"
  i = *tmp___8;
# 801 "arscan.c"
  close(fd);
# 802 "arscan.c"
  tmp___9 = __errno_location();
# 802 "arscan.c"
  *tmp___9 = i;
  }
# 803 "arscan.c"
  return (-3);
}
}
# 1 "commands.o"
#pragma merger("0","/tmp/cil-0y88q6_t.i","-g,-O0")
# 205 "/usr/include/x86_64-linux-gnu/sys/stat.h"
extern __attribute__((__nothrow__)) int ( __attribute__((__nonnull__(1,2), __leaf__)) stat)(char const * __restrict __file ,
                                                                                             struct stat * __restrict __buf ) ;
# 88 "/usr/include/signal.h"
extern __attribute__((__nothrow__)) __sighandler_t ( __attribute__((__leaf__)) signal)(int __sig ,
                                                                                        void (*__handler)(int ) ) ;
# 112 "/usr/include/signal.h"
extern __attribute__((__nothrow__)) int ( __attribute__((__leaf__)) kill)(__pid_t __pid ,
                                                                           int __sig ) ;
# 136 "/usr/include/stdio.h"
extern struct _IO_FILE *stdout ;
# 318 "/usr/include/stdio.h"
extern int printf(char const * __restrict __format , ...) ;
# 626 "/usr/include/stdio.h"
extern int fputs(char const * __restrict __s , FILE * __restrict __stream ) ;
# 632 "/usr/include/stdio.h"
extern int puts(char const *__s ) ;
# 79 "/usr/include/ctype.h"
extern __attribute__((__nothrow__)) unsigned short const **( __attribute__((__leaf__)) __ctype_b_loc)(void) __attribute__((__const__)) ;
# 631 "/usr/include/unistd.h"
extern __attribute__((__nothrow__)) __pid_t ( __attribute__((__leaf__)) getpid)(void) ;
# 828 "/usr/include/unistd.h"
extern __attribute__((__nothrow__)) int ( __attribute__((__nonnull__(1), __leaf__)) unlink)(char const *__name ) ;
# 614 "/usr/include/stdlib.h"
extern __attribute__((__nothrow__, __noreturn__)) void ( __attribute__((__leaf__)) exit)(int __status ) ;
# 391 "make.h"
 __attribute__((__noreturn__)) void pfatal_with_name(char *name ) ;
# 396 "make.h"
char *xrealloc(char *ptr , unsigned int size ) ;
# 403 "make.h"
char *sindex(char const *big , unsigned int blen , char const *small , unsigned int slen ) ;
# 496 "make.h"
int handling_fatal_signal ;
# 76 "dep.h"
void uniquize_deps(struct dep *chain ) ;
# 105 "filedef.h"
struct file *default_file ;
# 110 "filedef.h"
void remove_intermediates(int sig ) ;
# 116 "filedef.h"
void set_command_state(struct file *file , int state ) ;
# 117 "filedef.h"
void notice_finished_file(struct file *file ) ;
# 105 "variable.h"
void initialize_file_variables(struct file *file , int reading ) ;
# 113 "variable.h"
struct variable *define_variable_in_set(char *name , unsigned int length___0 , char *value ,
                                        enum variable_origin origin , int recursive ,
                                        struct variable_set *set , struct floc const *flocp ) ;
# 51 "job.h"
struct child *children ;
# 53 "job.h"
void new_job(struct file *file ) ;
# 54 "job.h"
void reap_children(int block , int err ) ;
# 69 "job.h"
unsigned int job_slots_used ;
# 39 "commands.h"
void execute_file_commands(struct file *file ) ;
# 40 "commands.h"
void print_commands(struct commands *cmds ) ;
# 41 "commands.h"
void delete_child_targets(struct child *child ) ;
# 42 "commands.h"
void chop_commands(struct commands *cmds ) ;
# 27 "commands.c"
int remote_kill(int id , int sig ) ;
# 35 "commands.c"
static void set_file_variables(struct file *file )
{
  register char *p ;
  char *at ;
  char *percent ;
  char *star ;
  char *less ;
  unsigned int len ;
  void *tmp ;
  size_t tmp___0 ;
  void *tmp___1 ;
  int tmp___2 ;
  register struct dep *d ;
  char *name ;
  unsigned int len___0 ;
  char *tmp___3 ;
  size_t tmp___4 ;
  size_t tmp___5 ;
  int tmp___6 ;
  struct file *tmp___7 ;
  unsigned int slen ;
  char *tmp___8 ;
  size_t tmp___9 ;
  char *tmp___10 ;
  int tmp___11 ;
  char *tmp___12 ;
  register unsigned int qmark_len ;
  register unsigned int plus_len ;
  char *caret_value ;
  char *plus_value ;
  register char *cp ;
  char *qmark_value ;
  register char *qp ;
  register struct dep *d___0 ;
  unsigned int len___1 ;
  char *tmp___13 ;
  size_t tmp___14 ;
  void *tmp___15 ;
  char *c ;
  char *tmp___16 ;
  char *tmp___17 ;
  size_t tmp___18 ;
  size_t tmp___19 ;
  int tmp___20 ;
  char *tmp___21 ;
  int tmp___22 ;
  void *tmp___23 ;
  char *c___0 ;
  char *tmp___24 ;
  char *tmp___25 ;
  size_t tmp___26 ;
  size_t tmp___27 ;
  int tmp___28 ;
  char *tmp___29 ;
  char *tmp___30 ;
  int tmp___31 ;
  int tmp___32 ;

  {
  {
# 46 "commands.c"
  tmp___2 = ar_name(file->name);
  }
# 46 "commands.c"
  if (tmp___2) {
    {
# 49 "commands.c"
    p = strchr((char const *)file->name, '(');
# 50 "commands.c"
    tmp = __builtin_alloca((unsigned long )((p - file->name) + 1L));
# 50 "commands.c"
    at = (char *)tmp;
# 51 "commands.c"
    memmove((void *)at, (void const *)file->name, (size_t )(p - file->name));
# 52 "commands.c"
    *(at + (p - file->name)) = (char )'\000';
# 53 "commands.c"
    tmp___0 = strlen((char const *)(p + 1));
# 53 "commands.c"
    len = (unsigned int )tmp___0;
# 54 "commands.c"
    tmp___1 = __builtin_alloca((unsigned long )len);
# 54 "commands.c"
    percent = (char *)tmp___1;
# 55 "commands.c"
    memmove((void *)percent, (void const *)(p + 1), (size_t )(len - 1U));
# 56 "commands.c"
    *(percent + (len - 1U)) = (char )'\000';
    }
  } else {
# 61 "commands.c"
    at = file->name;
# 62 "commands.c"
    percent = (char *)"";
  }
# 66 "commands.c"
  if ((unsigned long )file->stem == (unsigned long )((char *)0)) {
    {
# 76 "commands.c"
    tmp___6 = ar_name(file->name);
    }
# 76 "commands.c"
    if (tmp___6) {
      {
# 78 "commands.c"
      tmp___3 = strchr((char const *)file->name, '(');
# 78 "commands.c"
      name = tmp___3 + 1;
# 79 "commands.c"
      tmp___4 = strlen((char const *)name);
# 79 "commands.c"
      len___0 = (unsigned int )(tmp___4 - 1UL);
      }
    } else {
      {
# 84 "commands.c"
      name = file->name;
# 85 "commands.c"
      tmp___5 = strlen((char const *)name);
# 85 "commands.c"
      len___0 = (unsigned int )tmp___5;
      }
    }
    {
# 88 "commands.c"
    tmp___7 = enter_file((char *)".SUFFIXES");
# 88 "commands.c"
    d = tmp___7->deps;
    }
    {
# 88 "commands.c"
    while (1) {
      while_continue: ;
# 88 "commands.c"
      if (! ((unsigned long )d != (unsigned long )((struct dep *)0))) {
# 88 "commands.c"
        goto while_break;
      }
# 90 "commands.c"
      if ((unsigned long )d->name == (unsigned long )((char *)0)) {
# 90 "commands.c"
        tmp___8 = (d->file)->name;
      } else {
# 90 "commands.c"
        tmp___8 = d->name;
      }
      {
# 90 "commands.c"
      tmp___9 = strlen((char const *)tmp___8);
# 90 "commands.c"
      slen = (unsigned int )tmp___9;
      }
# 91 "commands.c"
      if (len___0 > slen) {
# 91 "commands.c"
        if ((unsigned long )d->name == (unsigned long )((char *)0)) {
# 91 "commands.c"
          tmp___10 = (d->file)->name;
        } else {
# 91 "commands.c"
          tmp___10 = d->name;
        }
        {
# 91 "commands.c"
        tmp___11 = strncmp((char const *)tmp___10, (char const *)(name + (len___0 - slen)),
                           (size_t )slen);
        }
# 91 "commands.c"
        if (tmp___11 == 0) {
          {
# 93 "commands.c"
          file->stem = savestring((char const *)name, len___0 - slen);
          }
# 94 "commands.c"
          goto while_break;
        }
      }
# 88 "commands.c"
      d = d->next;
    }
    while_break: ;
    }
# 97 "commands.c"
    if ((unsigned long )d == (unsigned long )((struct dep *)0)) {
# 98 "commands.c"
      file->stem = (char *)"";
    }
  }
# 100 "commands.c"
  star = file->stem;
# 103 "commands.c"
  if ((unsigned long )file->deps != (unsigned long )((struct dep *)0)) {
# 103 "commands.c"
    if ((unsigned long )(file->deps)->name == (unsigned long )((char *)0)) {
# 103 "commands.c"
      tmp___12 = ((file->deps)->file)->name;
    } else {
# 103 "commands.c"
      tmp___12 = (file->deps)->name;
    }
# 103 "commands.c"
    less = tmp___12;
  } else {
# 103 "commands.c"
    less = (char *)"";
  }
# 105 "commands.c"
  if ((unsigned long )file->cmds == (unsigned long )default_file->cmds) {
# 108 "commands.c"
    less = at;
  }
  {
# 115 "commands.c"
  define_variable_in_set((char *)"<", 1U, less, (enum variable_origin )6, 0, (file->variables)->set,
                         (struct floc const *)((struct floc *)0));
# 116 "commands.c"
  define_variable_in_set((char *)"*", 1U, star, (enum variable_origin )6, 0, (file->variables)->set,
                         (struct floc const *)((struct floc *)0));
# 117 "commands.c"
  define_variable_in_set((char *)"@", 1U, at, (enum variable_origin )6, 0, (file->variables)->set,
                         (struct floc const *)((struct floc *)0));
# 118 "commands.c"
  define_variable_in_set((char *)"%", 1U, percent, (enum variable_origin )6, 0, (file->variables)->set,
                         (struct floc const *)((struct floc *)0));
# 134 "commands.c"
  plus_len = 0U;
# 135 "commands.c"
  d___0 = file->deps;
  }
  {
# 135 "commands.c"
  while (1) {
    while_continue___0: ;
# 135 "commands.c"
    if (! ((unsigned long )d___0 != (unsigned long )((struct dep *)0))) {
# 135 "commands.c"
      goto while_break___0;
    }
# 136 "commands.c"
    if ((unsigned long )d___0->name == (unsigned long )((char *)0)) {
# 136 "commands.c"
      tmp___13 = (d___0->file)->name;
    } else {
# 136 "commands.c"
      tmp___13 = d___0->name;
    }
    {
# 136 "commands.c"
    tmp___14 = strlen((char const *)tmp___13);
# 136 "commands.c"
    plus_len = (unsigned int )((size_t )plus_len + (tmp___14 + 1UL));
# 135 "commands.c"
    d___0 = d___0->next;
    }
  }
  while_break___0: ;
  }
# 138 "commands.c"
  if (plus_len == 0U) {
# 138 "commands.c"
    len___1 = 1U;
  } else {
# 138 "commands.c"
    len___1 = plus_len;
  }
  {
# 139 "commands.c"
  tmp___15 = __builtin_alloca((unsigned long )len___1);
# 139 "commands.c"
  plus_value = (char *)tmp___15;
# 139 "commands.c"
  cp = plus_value;
# 141 "commands.c"
  qmark_len = plus_len;
# 142 "commands.c"
  d___0 = file->deps;
  }
  {
# 142 "commands.c"
  while (1) {
    while_continue___1: ;
# 142 "commands.c"
    if (! ((unsigned long )d___0 != (unsigned long )((struct dep *)0))) {
# 142 "commands.c"
      goto while_break___1;
    }
# 144 "commands.c"
    if ((unsigned long )d___0->name == (unsigned long )((char *)0)) {
# 144 "commands.c"
      tmp___16 = (d___0->file)->name;
    } else {
# 144 "commands.c"
      tmp___16 = d___0->name;
    }
    {
# 144 "commands.c"
    c = tmp___16;
# 147 "commands.c"
    tmp___20 = ar_name(c);
    }
# 147 "commands.c"
    if (tmp___20) {
      {
# 149 "commands.c"
      tmp___17 = strchr((char const *)c, '(');
# 149 "commands.c"
      c = tmp___17 + 1;
# 150 "commands.c"
      tmp___18 = strlen((char const *)c);
# 150 "commands.c"
      len___1 = (unsigned int )(tmp___18 - 1UL);
      }
    } else {
      {
# 154 "commands.c"
      tmp___19 = strlen((char const *)c);
# 154 "commands.c"
      len___1 = (unsigned int )tmp___19;
      }
    }
    {
# 156 "commands.c"
    memmove((void *)cp, (void const *)c, (size_t )len___1);
# 157 "commands.c"
    cp += len___1;
# 161 "commands.c"
    tmp___21 = cp;
# 161 "commands.c"
    cp ++;
# 161 "commands.c"
    *tmp___21 = (char )' ';
    }
# 163 "commands.c"
    if (! d___0->changed) {
# 164 "commands.c"
      qmark_len -= len___1 + 1U;
    }
# 142 "commands.c"
    d___0 = d___0->next;
  }
  while_break___1: ;
  }
# 169 "commands.c"
  if ((unsigned long )cp > (unsigned long )plus_value) {
# 169 "commands.c"
    tmp___22 = -1;
  } else {
# 169 "commands.c"
    tmp___22 = 0;
  }
  {
# 169 "commands.c"
  *(cp + tmp___22) = (char )'\000';
# 170 "commands.c"
  define_variable_in_set((char *)"+", 1U, plus_value, (enum variable_origin )6, 0,
                         (file->variables)->set, (struct floc const *)((struct floc *)0));
# 176 "commands.c"
  uniquize_deps(file->deps);
# 180 "commands.c"
  caret_value = plus_value;
# 180 "commands.c"
  cp = caret_value;
  }
# 181 "commands.c"
  if (qmark_len == 0U) {
# 181 "commands.c"
    len___1 = 1U;
  } else {
# 181 "commands.c"
    len___1 = qmark_len;
  }
  {
# 182 "commands.c"
  tmp___23 = __builtin_alloca((unsigned long )len___1);
# 182 "commands.c"
  qmark_value = (char *)tmp___23;
# 182 "commands.c"
  qp = qmark_value;
# 184 "commands.c"
  d___0 = file->deps;
  }
  {
# 184 "commands.c"
  while (1) {
    while_continue___2: ;
# 184 "commands.c"
    if (! ((unsigned long )d___0 != (unsigned long )((struct dep *)0))) {
# 184 "commands.c"
      goto while_break___2;
    }
# 186 "commands.c"
    if ((unsigned long )d___0->name == (unsigned long )((char *)0)) {
# 186 "commands.c"
      tmp___24 = (d___0->file)->name;
    } else {
# 186 "commands.c"
      tmp___24 = d___0->name;
    }
    {
# 186 "commands.c"
    c___0 = tmp___24;
# 189 "commands.c"
    tmp___28 = ar_name(c___0);
    }
# 189 "commands.c"
    if (tmp___28) {
      {
# 191 "commands.c"
      tmp___25 = strchr((char const *)c___0, '(');
# 191 "commands.c"
      c___0 = tmp___25 + 1;
# 192 "commands.c"
      tmp___26 = strlen((char const *)c___0);
# 192 "commands.c"
      len___1 = (unsigned int )(tmp___26 - 1UL);
      }
    } else {
      {
# 196 "commands.c"
      tmp___27 = strlen((char const *)c___0);
# 196 "commands.c"
      len___1 = (unsigned int )tmp___27;
      }
    }
    {
# 198 "commands.c"
    memmove((void *)cp, (void const *)c___0, (size_t )len___1);
# 199 "commands.c"
    cp += len___1;
# 203 "commands.c"
    tmp___29 = cp;
# 203 "commands.c"
    cp ++;
# 203 "commands.c"
    *tmp___29 = (char )' ';
    }
# 205 "commands.c"
    if (d___0->changed) {
      {
# 207 "commands.c"
      memmove((void *)qp, (void const *)c___0, (size_t )len___1);
# 208 "commands.c"
      qp += len___1;
# 212 "commands.c"
      tmp___30 = qp;
# 212 "commands.c"
      qp ++;
# 212 "commands.c"
      *tmp___30 = (char )' ';
      }
    }
# 184 "commands.c"
    d___0 = d___0->next;
  }
  while_break___2: ;
  }
# 219 "commands.c"
  if ((unsigned long )cp > (unsigned long )caret_value) {
# 219 "commands.c"
    tmp___31 = -1;
  } else {
# 219 "commands.c"
    tmp___31 = 0;
  }
  {
# 219 "commands.c"
  *(cp + tmp___31) = (char )'\000';
# 220 "commands.c"
  define_variable_in_set((char *)"^", 1U, caret_value, (enum variable_origin )6, 0,
                         (file->variables)->set, (struct floc const *)((struct floc *)0));
  }
# 222 "commands.c"
  if ((unsigned long )qp > (unsigned long )qmark_value) {
# 222 "commands.c"
    tmp___32 = -1;
  } else {
# 222 "commands.c"
    tmp___32 = 0;
  }
  {
# 222 "commands.c"
  *(qp + tmp___32) = (char )'\000';
# 223 "commands.c"
  define_variable_in_set((char *)"?", 1U, qmark_value, (enum variable_origin )6, 0,
                         (file->variables)->set, (struct floc const *)((struct floc *)0));
  }
# 227 "commands.c"
  return;
}
}
# 232 "commands.c"
void chop_commands(struct commands *cmds )
{
  register char *p ;
  unsigned int nlines ;
  unsigned int idx ;
  char **lines ;
  char *tmp ;
  char *end ;
  size_t tmp___0 ;
  int backslash ;
  register char *b ;
  char *tmp___1 ;
  unsigned int tmp___2 ;
  char *tmp___3 ;
  char *tmp___4 ;
  int flags ;
  unsigned short const **tmp___5 ;
  unsigned int len ;
  size_t tmp___6 ;
  char *tmp___7 ;
  char *tmp___8 ;

  {
# 243 "commands.c"
  if (! cmds) {
# 244 "commands.c"
    return;
  } else
# 243 "commands.c"
  if ((unsigned long )cmds->command_lines != (unsigned long )((char **)0)) {
# 244 "commands.c"
    return;
  }
  {
# 250 "commands.c"
  nlines = 5U;
# 251 "commands.c"
  tmp = xmalloc((unsigned int )(5UL * sizeof(char *)));
# 251 "commands.c"
  lines = (char **)tmp;
# 252 "commands.c"
  idx = 0U;
# 253 "commands.c"
  p = cmds->commands;
  }
  {
# 254 "commands.c"
  while (1) {
    while_continue: ;
# 254 "commands.c"
    if (! ((int )*p != 0)) {
# 254 "commands.c"
      goto while_break;
    }
# 256 "commands.c"
    end = p;
    find_end:
    {
# 258 "commands.c"
    end = strchr((char const *)end, '\n');
    }
# 259 "commands.c"
    if ((unsigned long )end == (unsigned long )((char *)0)) {
      {
# 260 "commands.c"
      tmp___0 = strlen((char const *)p);
# 260 "commands.c"
      end = p + tmp___0;
      }
    } else
# 261 "commands.c"
    if ((unsigned long )end > (unsigned long )p) {
# 261 "commands.c"
      if ((int )*(end + -1) == 92) {
# 263 "commands.c"
        backslash = 1;
# 265 "commands.c"
        b = end - 2;
        {
# 265 "commands.c"
        while (1) {
          while_continue___0: ;
# 265 "commands.c"
          if ((unsigned long )b >= (unsigned long )p) {
# 265 "commands.c"
            if (! ((int )*b == 92)) {
# 265 "commands.c"
              goto while_break___0;
            }
          } else {
# 265 "commands.c"
            goto while_break___0;
          }
# 266 "commands.c"
          backslash = ! backslash;
# 265 "commands.c"
          b --;
        }
        while_break___0: ;
        }
# 267 "commands.c"
        if (backslash) {
# 269 "commands.c"
          end ++;
# 270 "commands.c"
          goto find_end;
        }
      }
    }
# 274 "commands.c"
    if (idx == nlines) {
      {
# 276 "commands.c"
      nlines += 2U;
# 277 "commands.c"
      tmp___1 = xrealloc((char *)lines, (unsigned int )((unsigned long )nlines * sizeof(char *)));
# 277 "commands.c"
      lines = (char **)tmp___1;
      }
    }
    {
# 280 "commands.c"
    tmp___2 = idx;
# 280 "commands.c"
    idx ++;
# 280 "commands.c"
    *(lines + tmp___2) = savestring((char const *)p, (unsigned int )(end - p));
# 281 "commands.c"
    p = end;
    }
# 282 "commands.c"
    if ((int )*p != 0) {
# 283 "commands.c"
      p ++;
    }
  }
  while_break: ;
  }
# 286 "commands.c"
  if (idx != nlines) {
    {
# 288 "commands.c"
    nlines = idx;
# 289 "commands.c"
    tmp___3 = xrealloc((char *)lines, (unsigned int )((unsigned long )nlines * sizeof(char *)));
# 289 "commands.c"
    lines = (char **)tmp___3;
    }
  }
  {
# 293 "commands.c"
  cmds->ncommand_lines = nlines;
# 294 "commands.c"
  cmds->command_lines = lines;
# 296 "commands.c"
  cmds->any_recurse = 0;
# 297 "commands.c"
  tmp___4 = xmalloc(nlines);
# 297 "commands.c"
  cmds->lines_flags = tmp___4;
# 298 "commands.c"
  idx = 0U;
  }
  {
# 298 "commands.c"
  while (1) {
    while_continue___1: ;
# 298 "commands.c"
    if (! (idx < nlines)) {
# 298 "commands.c"
      goto while_break___1;
    }
# 300 "commands.c"
    flags = 0;
# 302 "commands.c"
    p = *(lines + idx);
    {
# 302 "commands.c"
    while (1) {
      while_continue___2: ;
      {
# 302 "commands.c"
      tmp___5 = __ctype_b_loc();
      }
# 302 "commands.c"
      if (! ((int const )*(*tmp___5 + (int )*p) & 1)) {
# 302 "commands.c"
        if (! ((int )*p == 45)) {
# 302 "commands.c"
          if (! ((int )*p == 64)) {
# 302 "commands.c"
            if (! ((int )*p == 43)) {
# 302 "commands.c"
              goto while_break___2;
            }
          }
        }
      }
      {
# 306 "commands.c"
      if ((int )*p == 43) {
# 306 "commands.c"
        goto case_43;
      }
# 310 "commands.c"
      if ((int )*p == 64) {
# 310 "commands.c"
        goto case_64;
      }
# 313 "commands.c"
      if ((int )*p == 45) {
# 313 "commands.c"
        goto case_45;
      }
# 305 "commands.c"
      goto switch_break;
      case_43:
# 308 "commands.c"
      flags |= 1;
# 309 "commands.c"
      goto switch_break;
      case_64:
# 311 "commands.c"
      flags |= 2;
# 312 "commands.c"
      goto switch_break;
      case_45:
# 314 "commands.c"
      flags |= 4;
# 315 "commands.c"
      goto switch_break;
      switch_break: ;
      }
# 302 "commands.c"
      p ++;
    }
    while_break___2: ;
    }
# 317 "commands.c"
    if (! (flags & 1)) {
      {
# 319 "commands.c"
      tmp___6 = strlen((char const *)p);
# 319 "commands.c"
      len = (unsigned int )tmp___6;
# 320 "commands.c"
      tmp___7 = sindex((char const *)p, len, "$(MAKE)", 7U);
      }
# 320 "commands.c"
      if ((unsigned long )tmp___7 != (unsigned long )((char *)0)) {
# 322 "commands.c"
        flags |= 1;
      } else {
        {
# 320 "commands.c"
        tmp___8 = sindex((char const *)p, len, "${MAKE}", 7U);
        }
# 320 "commands.c"
        if ((unsigned long )tmp___8 != (unsigned long )((char *)0)) {
# 322 "commands.c"
          flags |= 1;
        }
      }
    }
# 325 "commands.c"
    *(cmds->lines_flags + idx) = (char )flags;
# 326 "commands.c"
    cmds->any_recurse |= flags & 1;
# 298 "commands.c"
    idx ++;
  }
  while_break___1: ;
  }
# 328 "commands.c"
  return;
}
}
# 334 "commands.c"
void execute_file_commands(struct file *file )
{
  register char *p ;
  unsigned short const **tmp ;

  {
# 343 "commands.c"
  p = (file->cmds)->commands;
  {
# 343 "commands.c"
  while (1) {
    while_continue: ;
# 343 "commands.c"
    if (! ((int )*p != 0)) {
# 343 "commands.c"
      goto while_break;
    }
    {
# 344 "commands.c"
    tmp = __ctype_b_loc();
    }
# 344 "commands.c"
    if (! ((int const )*(*tmp + (int )((unsigned char )*p)) & 8192)) {
# 344 "commands.c"
      if ((int )*p != 45) {
# 344 "commands.c"
        if ((int )*p != 64) {
# 345 "commands.c"
          goto while_break;
        }
      }
    }
# 343 "commands.c"
    p ++;
  }
  while_break: ;
  }
# 346 "commands.c"
  if ((int )*p == 0) {
    {
# 349 "commands.c"
    set_command_state(file, 2);
# 350 "commands.c"
    file->update_status = (short)0;
# 351 "commands.c"
    notice_finished_file(file);
    }
# 352 "commands.c"
    return;
  }
  {
# 357 "commands.c"
  initialize_file_variables(file, 0);
# 359 "commands.c"
  set_file_variables(file);
# 362 "commands.c"
  new_job(file);
  }
# 363 "commands.c"
  return;
}
}
# 368 "commands.c"
int handling_fatal_signal = 0;
# 372 "commands.c"
void fatal_error_signal(int sig )
{
  register struct child *c ;
  register struct child *c___0 ;
  __pid_t tmp ;
  int tmp___0 ;

  {
  {
# 395 "commands.c"
  handling_fatal_signal = 1;
# 399 "commands.c"
  signal(sig, (void (*)(int ))0);
  }
# 404 "commands.c"
  if (sig == 15) {
# 407 "commands.c"
    c = children;
    {
# 407 "commands.c"
    while (1) {
      while_continue: ;
# 407 "commands.c"
      if (! ((unsigned long )c != (unsigned long )((struct child *)0))) {
# 407 "commands.c"
        goto while_break;
      }
# 408 "commands.c"
      if (! c->remote) {
        {
# 409 "commands.c"
        kill(c->pid, 15);
        }
      }
# 407 "commands.c"
      c = c->next;
    }
    while_break: ;
    }
  }
# 415 "commands.c"
  if (sig == 15) {
# 415 "commands.c"
    goto _L;
  } else
# 415 "commands.c"
  if (sig == 2) {
# 415 "commands.c"
    goto _L;
  } else
# 415 "commands.c"
  if (sig == 1) {
# 415 "commands.c"
    goto _L;
  } else
# 415 "commands.c"
  if (sig == 3) {
    _L:
# 428 "commands.c"
    c___0 = children;
    {
# 428 "commands.c"
    while (1) {
      while_continue___0: ;
# 428 "commands.c"
      if (! ((unsigned long )c___0 != (unsigned long )((struct child *)0))) {
# 428 "commands.c"
        goto while_break___0;
      }
# 429 "commands.c"
      if (c___0->remote) {
        {
# 430 "commands.c"
        remote_kill(c___0->pid, sig);
        }
      }
# 428 "commands.c"
      c___0 = c___0->next;
    }
    while_break___0: ;
    }
# 432 "commands.c"
    c___0 = children;
    {
# 432 "commands.c"
    while (1) {
      while_continue___1: ;
# 432 "commands.c"
      if (! ((unsigned long )c___0 != (unsigned long )((struct child *)0))) {
# 432 "commands.c"
        goto while_break___1;
      }
      {
# 433 "commands.c"
      delete_child_targets(c___0);
# 432 "commands.c"
      c___0 = c___0->next;
      }
    }
    while_break___1: ;
    }
    {
# 437 "commands.c"
    while (1) {
      while_continue___2: ;
# 437 "commands.c"
      if (! (job_slots_used > 0U)) {
# 437 "commands.c"
        goto while_break___2;
      }
      {
# 438 "commands.c"
      reap_children(1, 0);
      }
    }
    while_break___2: ;
    }
  } else {
    {
# 442 "commands.c"
    while (1) {
      while_continue___3: ;
# 442 "commands.c"
      if (! (job_slots_used > 0U)) {
# 442 "commands.c"
        goto while_break___3;
      }
      {
# 443 "commands.c"
      reap_children(1, 1);
      }
    }
    while_break___3: ;
    }
  }
  {
# 447 "commands.c"
  remove_intermediates(1);
  }
# 450 "commands.c"
  if (sig == 3) {
    {
# 453 "commands.c"
    exit(1);
    }
  }
  {
# 458 "commands.c"
  tmp = getpid();
# 458 "commands.c"
  tmp___0 = kill(tmp, sig);
  }
# 458 "commands.c"
  if (tmp___0 < 0) {
    {
# 459 "commands.c"
    pfatal_with_name((char *)"kill");
    }
  }
# 462 "commands.c"
  return;
}
}
# 467 "commands.c"
static void delete_target(struct file *file , char *on_behalf_of )
{
  struct stat st ;
  char *tmp ;
  char *tmp___0 ;
  time_t tmp___1 ;
  uintmax_t tmp___2 ;
  uintmax_t tmp___3 ;
  int tmp___4 ;
  char *tmp___5 ;
  char *tmp___6 ;
  int tmp___7 ;
  int *tmp___8 ;
  int tmp___9 ;
  uintmax_t tmp___10 ;
  uintmax_t tmp___11 ;

  {
# 474 "commands.c"
  if (file->precious) {
# 475 "commands.c"
    return;
  } else
# 474 "commands.c"
  if (file->phony) {
# 475 "commands.c"
    return;
  }
  {
# 478 "commands.c"
  tmp___4 = ar_name(file->name);
  }
# 478 "commands.c"
  if (tmp___4) {
    {
# 480 "commands.c"
    tmp___1 = ar_member_date(file->name);
    }
# 480 "commands.c"
    if (1000000000UL < 0xffffffffffffffffUL / (uintmax_t )(-1L - (-1L << (sizeof(time_t ) * 8UL - 1UL)))) {
# 480 "commands.c"
      tmp___2 = (uintmax_t )1000000000;
    } else {
# 480 "commands.c"
      tmp___2 = 0xffffffffffffffffUL / (uintmax_t )(-1L - (-1L << (sizeof(time_t ) * 8UL - 1UL)));
    }
# 480 "commands.c"
    if (1000000000UL < 0xffffffffffffffffUL / (uintmax_t )(-1L - (-1L << (sizeof(time_t ) * 8UL - 1UL)))) {
# 480 "commands.c"
      tmp___3 = (uintmax_t )1000000000;
    } else {
# 480 "commands.c"
      tmp___3 = 0xffffffffffffffffUL / (uintmax_t )(-1L - (-1L << (sizeof(time_t ) * 8UL - 1UL)));
    }
# 480 "commands.c"
    if ((uintmax_t )tmp___1 != file->last_mtime / tmp___2 - (uintmax_t )(file->last_mtime % tmp___3 < 0UL)) {
# 482 "commands.c"
      if (on_behalf_of) {
        {
# 483 "commands.c"
        tmp = dcgettext((char const *)((void *)0), "*** [%s] Archive member `%s\' may be bogus; not deleted",
                        5);
# 483 "commands.c"
        error((struct floc const *)((struct floc *)0), (char const *)tmp, on_behalf_of,
              file->name);
        }
      } else {
        {
# 486 "commands.c"
        tmp___0 = dcgettext((char const *)((void *)0), "*** Archive member `%s\' may be bogus; not deleted",
                            5);
# 486 "commands.c"
        error((struct floc const *)((struct floc *)0), (char const *)tmp___0,
              file->name);
        }
      }
    }
# 489 "commands.c"
    return;
  }
  {
# 493 "commands.c"
  tmp___9 = stat((char const * __restrict )file->name, (struct stat * __restrict )(& st));
  }
# 493 "commands.c"
  if (tmp___9 == 0) {
# 493 "commands.c"
    if ((st.st_mode & 61440U) == 32768U) {
# 493 "commands.c"
      if (1000000000UL < 0xffffffffffffffffUL / (uintmax_t )(-1L - (-1L << (sizeof(time_t ) * 8UL - 1UL)))) {
# 493 "commands.c"
        tmp___10 = (uintmax_t )1000000000;
      } else {
# 493 "commands.c"
        tmp___10 = 0xffffffffffffffffUL / (uintmax_t )(-1L - (-1L << (sizeof(time_t ) * 8UL - 1UL)));
      }
# 493 "commands.c"
      if (1000000000UL < 0xffffffffffffffffUL / (uintmax_t )(-1L - (-1L << (sizeof(time_t ) * 8UL - 1UL)))) {
# 493 "commands.c"
        tmp___11 = (uintmax_t )1000000000;
      } else {
# 493 "commands.c"
        tmp___11 = 0xffffffffffffffffUL / (uintmax_t )(-1L - (-1L << (sizeof(time_t ) * 8UL - 1UL)));
      }
# 493 "commands.c"
      if ((uintmax_t )st.st_mtim.tv_sec * tmp___10 + ((uintmax_t )st.st_mtim.tv_nsec * tmp___11) / 1000000000UL != file->last_mtime) {
# 497 "commands.c"
        if (on_behalf_of) {
          {
# 498 "commands.c"
          tmp___5 = dcgettext((char const *)((void *)0), "*** [%s] Deleting file `%s\'",
                              5);
# 498 "commands.c"
          error((struct floc const *)((struct floc *)0), (char const *)tmp___5,
                on_behalf_of, file->name);
          }
        } else {
          {
# 500 "commands.c"
          tmp___6 = dcgettext((char const *)((void *)0), "*** Deleting file `%s\'",
                              5);
# 500 "commands.c"
          error((struct floc const *)((struct floc *)0), (char const *)tmp___6,
                file->name);
          }
        }
        {
# 501 "commands.c"
        tmp___7 = unlink((char const *)file->name);
        }
# 501 "commands.c"
        if (tmp___7 < 0) {
          {
# 501 "commands.c"
          tmp___8 = __errno_location();
          }
# 501 "commands.c"
          if (*tmp___8 != 2) {
            {
# 503 "commands.c"
            perror_with_name((char *)"unlink: ", file->name);
            }
          }
        }
      }
    }
  }
# 505 "commands.c"
  return;
}
}
# 511 "commands.c"
void delete_child_targets(struct child *child )
{
  struct dep *d ;

  {
# 517 "commands.c"
  if (child->deleted) {
# 518 "commands.c"
    return;
  }
  {
# 521 "commands.c"
  delete_target(child->file, (char *)0);
# 524 "commands.c"
  d = (child->file)->also_make;
  }
  {
# 524 "commands.c"
  while (1) {
    while_continue: ;
# 524 "commands.c"
    if (! ((unsigned long )d != (unsigned long )((struct dep *)0))) {
# 524 "commands.c"
      goto while_break;
    }
    {
# 525 "commands.c"
    delete_target(d->file, (child->file)->name);
# 524 "commands.c"
    d = d->next;
    }
  }
  while_break: ;
  }
# 527 "commands.c"
  child->deleted = 1U;
# 528 "commands.c"
  return;
}
}
# 532 "commands.c"
void print_commands(struct commands *cmds )
{
  register char *s ;
  char *tmp ;
  char *tmp___0 ;
  char *tmp___1 ;
  char *end ;
  unsigned short const **tmp___2 ;
  size_t tmp___3 ;

  {
  {
# 538 "commands.c"
  tmp = dcgettext((char const *)((void *)0), "#  commands to execute", 5);
# 538 "commands.c"
  fputs((char const * __restrict )tmp, (FILE * __restrict )stdout);
  }
# 540 "commands.c"
  if ((unsigned long )cmds->fileinfo.filenm == (unsigned long )((char *)0)) {
    {
# 541 "commands.c"
    tmp___0 = dcgettext((char const *)((void *)0), " (built-in):", 5);
# 541 "commands.c"
    puts((char const *)tmp___0);
    }
  } else {
    {
# 543 "commands.c"
    tmp___1 = dcgettext((char const *)((void *)0), " (from `%s\', line %lu):\n",
                        5);
# 543 "commands.c"
    printf((char const * __restrict )tmp___1, cmds->fileinfo.filenm, cmds->fileinfo.lineno);
    }
  }
# 546 "commands.c"
  s = cmds->commands;
  {
# 547 "commands.c"
  while (1) {
    while_continue: ;
# 547 "commands.c"
    if (! ((int )*s != 0)) {
# 547 "commands.c"
      goto while_break;
    }
    {
# 551 "commands.c"
    while (1) {
      while_continue___0: ;
      {
# 551 "commands.c"
      tmp___2 = __ctype_b_loc();
      }
# 551 "commands.c"
      if (! ((int const )*(*tmp___2 + (int )((unsigned char )*s)) & 8192)) {
# 551 "commands.c"
        goto while_break___0;
      }
# 552 "commands.c"
      s ++;
    }
    while_break___0: ;
    }
    {
# 554 "commands.c"
    end = strchr((char const *)s, '\n');
    }
# 555 "commands.c"
    if ((unsigned long )end == (unsigned long )((char *)0)) {
      {
# 556 "commands.c"
      tmp___3 = strlen((char const *)s);
# 556 "commands.c"
      end = s + tmp___3;
      }
    }
    {
# 558 "commands.c"
    printf((char const * __restrict )"\t%.*s\n", (int )(end - s), s);
# 560 "commands.c"
    s = end;
    }
  }
  while_break: ;
  }
# 562 "commands.c"
  return;
}
}
# 1 "dir.o"
#pragma merger("0","/tmp/cil-VKXtmFCh.i","-g,-O0")
# 42 "/usr/include/string.h"
extern __attribute__((__nothrow__)) void *( __attribute__((__nonnull__(1,2), __leaf__)) memcpy)(void * __restrict __dest ,
                                                                                                 void const * __restrict __src ,
                                                                                                 size_t __n ) ;
# 60 "/usr/include/string.h"
extern __attribute__((__nothrow__)) void *( __attribute__((__nonnull__(1), __leaf__)) memset)(void *__s ,
                                                                                               int __c ,
                                                                                               size_t __n ) ;
# 397 "make.h"
char *xstrdup(char const *ptr ) ;
# 419 "make.h"
int dir_file_exists_p(char *dirname , char *filename ) ;
# 421 "make.h"
int file_impossible_p(char *filename ) ;
# 422 "make.h"
void file_impossible(char *filename ) ;
# 423 "make.h"
char *dir_name(char *dir ) ;
# 134 "/usr/include/dirent.h"
extern DIR *( __attribute__((__nonnull__(1))) opendir)(char const *__name ) ;
# 149 "/usr/include/dirent.h"
extern int ( __attribute__((__nonnull__(1))) closedir)(DIR *__dirp ) ;
# 162 "/usr/include/dirent.h"
extern struct dirent *( __attribute__((__nonnull__(1))) readdir)(DIR *__dirp ) ;
# 249 "dir.c"
static struct directory_contents *directories_contents[199] ;
# 264 "dir.c"
static struct directory *directories[199] ;
# 271 "dir.c"
static unsigned int open_directories = 0U;
# 287 "dir.c"
static int dir_contents_file_exists_p(struct directory_contents *dir , char *filename ) ;
# 288 "dir.c"
static struct directory *find_directory(char *name ) ;
# 292 "dir.c"
static struct directory *find_directory(char *name )
{
  register unsigned int hash ;
  register char *p ;
  register struct directory *dir ;
  int tmp ;
  struct stat st ;
  char *tmp___0 ;
  struct directory_contents *dc ;
  char *tmp___1 ;
  char *tmp___2 ;
  int tmp___3 ;

  {
# 296 "dir.c"
  hash = 0U;
# 314 "dir.c"
  p = name;
  {
# 314 "dir.c"
  while (1) {
    while_continue: ;
# 314 "dir.c"
    if (! ((int )*p != 0)) {
# 314 "dir.c"
      goto while_break;
    }
# 315 "dir.c"
    hash += (unsigned int )*p;
# 315 "dir.c"
    hash = (hash << 7) + (hash >> 20);
# 314 "dir.c"
    p ++;
  }
  while_break: ;
  }
# 316 "dir.c"
  hash %= 199U;
# 318 "dir.c"
  dir = directories[hash];
  {
# 318 "dir.c"
  while (1) {
    while_continue___0: ;
# 318 "dir.c"
    if (! ((unsigned long )dir != (unsigned long )((struct directory *)0))) {
# 318 "dir.c"
      goto while_break___0;
    }
# 319 "dir.c"
    if ((unsigned long )dir->name == (unsigned long )name) {
# 320 "dir.c"
      goto while_break___0;
    } else
# 319 "dir.c"
    if ((int )*(dir->name) == (int )*name) {
# 319 "dir.c"
      if ((int )*(dir->name) == 0) {
# 320 "dir.c"
        goto while_break___0;
      } else {
        {
# 319 "dir.c"
        tmp = strcmp((char const *)(dir->name + 1), (char const *)(name + 1));
        }
# 319 "dir.c"
        if (! tmp) {
# 320 "dir.c"
          goto while_break___0;
        }
      }
    }
# 318 "dir.c"
    dir = dir->next;
  }
  while_break___0: ;
  }
# 322 "dir.c"
  if ((unsigned long )dir == (unsigned long )((struct directory *)0)) {
    {
# 328 "dir.c"
    tmp___0 = xmalloc((unsigned int )sizeof(struct directory ));
# 328 "dir.c"
    dir = (struct directory *)tmp___0;
# 329 "dir.c"
    dir->next = directories[hash];
# 330 "dir.c"
    directories[hash] = dir;
# 331 "dir.c"
    dir->name = savestring((char const *)name, (unsigned int )(p - name));
# 346 "dir.c"
    tmp___3 = stat((char const * __restrict )name, (struct stat * __restrict )(& st));
    }
# 346 "dir.c"
    if (tmp___3 < 0) {
# 351 "dir.c"
      dir->contents = (struct directory_contents *)0;
    } else {
# 369 "dir.c"
      hash = ((unsigned int )st.st_dev << 16) | (unsigned int )st.st_ino;
# 372 "dir.c"
      hash %= 199U;
# 374 "dir.c"
      dc = directories_contents[hash];
      {
# 374 "dir.c"
      while (1) {
        while_continue___1: ;
# 374 "dir.c"
        if (! ((unsigned long )dc != (unsigned long )((struct directory_contents *)0))) {
# 374 "dir.c"
          goto while_break___1;
        }
# 378 "dir.c"
        if (dc->dev == st.st_dev) {
# 378 "dir.c"
          if (dc->ino == st.st_ino) {
# 388 "dir.c"
            goto while_break___1;
          }
        }
# 374 "dir.c"
        dc = dc->next;
      }
      while_break___1: ;
      }
# 390 "dir.c"
      if ((unsigned long )dc == (unsigned long )((struct directory_contents *)0)) {
        {
# 394 "dir.c"
        tmp___1 = xmalloc((unsigned int )sizeof(struct directory_contents ));
# 394 "dir.c"
        dc = (struct directory_contents *)tmp___1;
# 398 "dir.c"
        dc->dev = st.st_dev;
# 426 "dir.c"
        dc->ino = st.st_ino;
# 429 "dir.c"
        dc->next = directories_contents[hash];
# 430 "dir.c"
        directories_contents[hash] = dc;
# 432 "dir.c"
        dc->dirstream = opendir((char const *)name);
        }
# 433 "dir.c"
        if ((unsigned long )dc->dirstream == (unsigned long )((DIR *)0)) {
# 436 "dir.c"
          dc->files = (struct dirfile **)0;
        } else {
          {
# 440 "dir.c"
          tmp___2 = xmalloc((unsigned int )(sizeof(struct dirfile *) * 107UL));
# 440 "dir.c"
          dc->files = (struct dirfile **)tmp___2;
# 442 "dir.c"
          memset((void *)((char *)dc->files), 0, sizeof(struct dirfile *) * 107UL);
# 446 "dir.c"
          open_directories ++;
          }
# 447 "dir.c"
          if (open_directories == 10U) {
            {
# 450 "dir.c"
            dir_contents_file_exists_p(dc, (char *)0);
            }
          }
        }
      }
# 455 "dir.c"
      dir->contents = dc;
    }
  }
# 459 "dir.c"
  return (dir);
}
}
# 465 "dir.c"
static int dir_contents_file_exists_p(struct directory_contents *dir , char *filename )
{
  register unsigned int hash ;
  register char *p ;
  register struct dirfile *df ;
  register struct dirent *d ;
  int tmp ;
  register unsigned int newhash ;
  unsigned int len ;
  register unsigned int i ;
  size_t tmp___0 ;
  char *tmp___1 ;
  int tmp___2 ;

  {
# 479 "dir.c"
  if ((unsigned long )dir == (unsigned long )((struct directory_contents *)0)) {
# 482 "dir.c"
    return (0);
  } else
# 479 "dir.c"
  if ((unsigned long )dir->files == (unsigned long )((struct dirfile **)0)) {
# 482 "dir.c"
    return (0);
  }
# 496 "dir.c"
  hash = 0U;
# 497 "dir.c"
  if ((unsigned long )filename != (unsigned long )((char *)0)) {
# 499 "dir.c"
    if ((int )*filename == 0) {
# 502 "dir.c"
      return (1);
    }
# 505 "dir.c"
    p = filename;
    {
# 505 "dir.c"
    while (1) {
      while_continue: ;
# 505 "dir.c"
      if (! ((int )*p != 0)) {
# 505 "dir.c"
        goto while_break;
      }
# 506 "dir.c"
      hash += (unsigned int )*p;
# 506 "dir.c"
      hash = (hash << 7) + (hash >> 20);
# 505 "dir.c"
      p ++;
    }
    while_break: ;
    }
# 507 "dir.c"
    hash %= 107U;
# 511 "dir.c"
    df = *(dir->files + hash);
    {
# 511 "dir.c"
    while (1) {
      while_continue___0: ;
# 511 "dir.c"
      if (! ((unsigned long )df != (unsigned long )((struct dirfile *)0))) {
# 511 "dir.c"
        goto while_break___0;
      }
# 513 "dir.c"
      if ((unsigned long )df->name == (unsigned long )filename) {
# 515 "dir.c"
        return (! df->impossible);
      } else
# 513 "dir.c"
      if ((int )*(df->name) == (int )*filename) {
# 513 "dir.c"
        if ((int )*(df->name) == 0) {
# 515 "dir.c"
          return (! df->impossible);
        } else {
          {
# 513 "dir.c"
          tmp = strcmp((char const *)(df->name + 1), (char const *)(filename + 1));
          }
# 513 "dir.c"
          if (! tmp) {
# 515 "dir.c"
            return (! df->impossible);
          }
        }
      }
# 511 "dir.c"
      df = df->next;
    }
    while_break___0: ;
    }
  }
# 523 "dir.c"
  if ((unsigned long )dir->dirstream == (unsigned long )((DIR *)0)) {
# 549 "dir.c"
    return (0);
  }
  {
# 552 "dir.c"
  while (1) {
    while_continue___1: ;
    {
# 552 "dir.c"
    d = readdir(dir->dirstream);
    }
# 552 "dir.c"
    if (! ((unsigned long )d != (unsigned long )((struct dirent *)0))) {
# 552 "dir.c"
      goto while_break___1;
    }
# 555 "dir.c"
    newhash = 0U;
# 567 "dir.c"
    if (! (d->d_ino != 0UL)) {
# 568 "dir.c"
      goto while_continue___1;
    }
    {
# 570 "dir.c"
    tmp___0 = strlen((char const *)(d->d_name));
# 570 "dir.c"
    len = (unsigned int )tmp___0;
# 571 "dir.c"
    i = 0U;
    }
    {
# 571 "dir.c"
    while (1) {
      while_continue___2: ;
# 571 "dir.c"
      if (! (i < len)) {
# 571 "dir.c"
        goto while_break___2;
      }
# 572 "dir.c"
      newhash += (unsigned int )d->d_name[i];
# 572 "dir.c"
      newhash = (newhash << 7) + (newhash >> 20);
# 571 "dir.c"
      i ++;
    }
    while_break___2: ;
    }
    {
# 573 "dir.c"
    newhash %= 107U;
# 593 "dir.c"
    tmp___1 = xmalloc((unsigned int )sizeof(struct dirfile ));
# 593 "dir.c"
    df = (struct dirfile *)tmp___1;
# 594 "dir.c"
    df->next = *(dir->files + newhash);
# 595 "dir.c"
    *(dir->files + newhash) = df;
# 596 "dir.c"
    df->name = savestring((char const *)(d->d_name), len);
# 597 "dir.c"
    df->impossible = (char)0;
    }
# 602 "dir.c"
    if ((unsigned long )filename != (unsigned long )((char *)0)) {
# 602 "dir.c"
      if (newhash == hash) {
# 602 "dir.c"
        if ((unsigned long )(d->d_name) == (unsigned long )filename) {
# 605 "dir.c"
          return (1);
        } else
# 602 "dir.c"
        if ((int )d->d_name[0] == (int )*filename) {
# 602 "dir.c"
          if ((int )d->d_name[0] == 0) {
# 605 "dir.c"
            return (1);
          } else {
            {
# 602 "dir.c"
            tmp___2 = strcmp((char const *)(d->d_name + 1), (char const *)(filename + 1));
            }
# 602 "dir.c"
            if (! tmp___2) {
# 605 "dir.c"
              return (1);
            }
          }
        }
      }
    }
  }
  while_break___1: ;
  }
# 611 "dir.c"
  if ((unsigned long )d == (unsigned long )((struct dirent *)0)) {
    {
# 613 "dir.c"
    open_directories --;
# 614 "dir.c"
    closedir(dir->dirstream);
# 615 "dir.c"
    dir->dirstream = (DIR *)0;
    }
  }
# 617 "dir.c"
  return (0);
}
}
# 624 "dir.c"
int dir_file_exists_p(char *dirname , char *filename )
{
  struct directory *tmp ;
  int tmp___0 ;

  {
  {
# 629 "dir.c"
  tmp = find_directory(dirname);
# 629 "dir.c"
  tmp___0 = dir_contents_file_exists_p(tmp->contents, filename);
  }
# 629 "dir.c"
  return (tmp___0);
}
}
# 635 "dir.c"
int file_exists_p(char *name )
{
  char *dirend ;
  char *dirname ;
  char *slash ;
  time_t tmp ;
  int tmp___0 ;
  int tmp___1 ;
  void *tmp___2 ;
  int tmp___3 ;

  {
  {
# 644 "dir.c"
  tmp___0 = ar_name(name);
  }
# 644 "dir.c"
  if (tmp___0) {
    {
# 645 "dir.c"
    tmp = ar_member_date(name);
    }
# 645 "dir.c"
    return (tmp != -1L);
  }
  {
# 656 "dir.c"
  dirend = strrchr((char const *)name, '/');
  }
# 668 "dir.c"
  if ((unsigned long )dirend == (unsigned long )((char *)0)) {
    {
# 670 "dir.c"
    tmp___1 = dir_file_exists_p((char *)".", name);
    }
# 670 "dir.c"
    return (tmp___1);
  }
# 676 "dir.c"
  slash = dirend;
# 677 "dir.c"
  if ((unsigned long )dirend == (unsigned long )name) {
# 678 "dir.c"
    dirname = (char *)"/";
  } else {
    {
# 687 "dir.c"
    tmp___2 = __builtin_alloca((unsigned long )((dirend - name) + 1L));
# 687 "dir.c"
    dirname = (char *)tmp___2;
# 688 "dir.c"
    memmove((void *)dirname, (void const *)name, (size_t )(dirend - name));
# 689 "dir.c"
    *(dirname + (dirend - name)) = (char )'\000';
    }
  }
  {
# 691 "dir.c"
  tmp___3 = dir_file_exists_p(dirname, slash + 1);
  }
# 691 "dir.c"
  return (tmp___3);
}
}
# 698 "dir.c"
void file_impossible(char *filename )
{
  char *dirend ;
  register char *p ;
  register unsigned int hash ;
  register struct directory *dir ;
  register struct dirfile *new ;
  char *dirname ;
  char *slash ;
  void *tmp ;
  char *tmp___0 ;
  ino_t tmp___1 ;
  char *tmp___2 ;
  char *tmp___3 ;

  {
  {
# 703 "dir.c"
  p = filename;
# 716 "dir.c"
  dirend = strrchr((char const *)p, '/');
  }
# 728 "dir.c"
  if ((unsigned long )dirend == (unsigned long )((char *)0)) {
    {
# 732 "dir.c"
    dir = find_directory((char *)".");
    }
  } else {
# 738 "dir.c"
    slash = dirend;
# 739 "dir.c"
    if ((unsigned long )dirend == (unsigned long )p) {
# 740 "dir.c"
      dirname = (char *)"/";
    } else {
      {
# 749 "dir.c"
      tmp = __builtin_alloca((unsigned long )((dirend - p) + 1L));
# 749 "dir.c"
      dirname = (char *)tmp;
# 750 "dir.c"
      memmove((void *)dirname, (void const *)p, (size_t )(dirend - p));
# 751 "dir.c"
      *(dirname + (dirend - p)) = (char )'\000';
      }
    }
    {
# 753 "dir.c"
    dir = find_directory(dirname);
# 754 "dir.c"
    p = slash + 1;
# 754 "dir.c"
    filename = p;
    }
  }
# 757 "dir.c"
  hash = 0U;
  {
# 757 "dir.c"
  while (1) {
    while_continue: ;
# 757 "dir.c"
    if (! ((int )*p != 0)) {
# 757 "dir.c"
      goto while_break;
    }
# 758 "dir.c"
    hash += (unsigned int )*p;
# 758 "dir.c"
    hash = (hash << 7) + (hash >> 20);
# 757 "dir.c"
    p ++;
  }
  while_break: ;
  }
# 759 "dir.c"
  hash %= 107U;
# 761 "dir.c"
  if ((unsigned long )dir->contents == (unsigned long )((struct directory_contents *)0)) {
    {
# 765 "dir.c"
    tmp___0 = xmalloc((unsigned int )sizeof(struct directory_contents ));
# 765 "dir.c"
    dir->contents = (struct directory_contents *)tmp___0;
# 776 "dir.c"
    tmp___1 = (ino_t )0;
# 776 "dir.c"
    (dir->contents)->ino = tmp___1;
# 776 "dir.c"
    (dir->contents)->dev = tmp___1;
# 779 "dir.c"
    (dir->contents)->files = (struct dirfile **)0;
# 780 "dir.c"
    (dir->contents)->dirstream = (DIR *)0;
    }
  }
# 783 "dir.c"
  if ((unsigned long )(dir->contents)->files == (unsigned long )((struct dirfile **)0)) {
    {
# 786 "dir.c"
    tmp___2 = xmalloc((unsigned int )(sizeof(struct dirfile ) * 107UL));
# 786 "dir.c"
    (dir->contents)->files = (struct dirfile **)tmp___2;
# 788 "dir.c"
    memset((void *)((char *)(dir->contents)->files), 0, sizeof(struct dirfile ) * 107UL);
    }
  }
  {
# 794 "dir.c"
  tmp___3 = xmalloc((unsigned int )sizeof(struct dirfile ));
# 794 "dir.c"
  new = (struct dirfile *)tmp___3;
# 795 "dir.c"
  new->next = *((dir->contents)->files + hash);
# 796 "dir.c"
  *((dir->contents)->files + hash) = new;
# 797 "dir.c"
  new->name = xstrdup((char const *)filename);
# 798 "dir.c"
  new->impossible = (char)1;
  }
# 799 "dir.c"
  return;
}
}
# 803 "dir.c"
int file_impossible_p(char *filename )
{
  char *dirend ;
  register char *p ;
  register unsigned int hash ;
  register struct directory_contents *dir ;
  register struct dirfile *next ;
  struct directory *tmp ;
  char *dirname ;
  char *slash ;
  void *tmp___0 ;
  struct directory *tmp___1 ;
  int tmp___2 ;

  {
  {
# 808 "dir.c"
  p = filename;
# 818 "dir.c"
  dirend = strrchr((char const *)filename, '/');
  }
# 830 "dir.c"
  if ((unsigned long )dirend == (unsigned long )((char *)0)) {
    {
# 834 "dir.c"
    tmp = find_directory((char *)".");
# 834 "dir.c"
    dir = tmp->contents;
    }
  } else {
# 840 "dir.c"
    slash = dirend;
# 841 "dir.c"
    if ((unsigned long )dirend == (unsigned long )filename) {
# 842 "dir.c"
      dirname = (char *)"/";
    } else {
      {
# 851 "dir.c"
      tmp___0 = __builtin_alloca((unsigned long )((dirend - filename) + 1L));
# 851 "dir.c"
      dirname = (char *)tmp___0;
# 852 "dir.c"
      memmove((void *)dirname, (void const *)p, (size_t )(dirend - p));
# 853 "dir.c"
      *(dirname + (dirend - p)) = (char )'\000';
      }
    }
    {
# 855 "dir.c"
    tmp___1 = find_directory(dirname);
# 855 "dir.c"
    dir = tmp___1->contents;
# 856 "dir.c"
    filename = slash + 1;
# 856 "dir.c"
    p = filename;
    }
  }
# 859 "dir.c"
  if ((unsigned long )dir == (unsigned long )((struct directory_contents *)0)) {
# 861 "dir.c"
    return (0);
  } else
# 859 "dir.c"
  if ((unsigned long )dir->files == (unsigned long )((struct dirfile **)0)) {
# 861 "dir.c"
    return (0);
  }
# 873 "dir.c"
  hash = 0U;
  {
# 873 "dir.c"
  while (1) {
    while_continue: ;
# 873 "dir.c"
    if (! ((int )*p != 0)) {
# 873 "dir.c"
      goto while_break;
    }
# 874 "dir.c"
    hash += (unsigned int )*p;
# 874 "dir.c"
    hash = (hash << 7) + (hash >> 20);
# 873 "dir.c"
    p ++;
  }
  while_break: ;
  }
# 875 "dir.c"
  hash %= 107U;
# 877 "dir.c"
  next = *(dir->files + hash);
  {
# 877 "dir.c"
  while (1) {
    while_continue___0: ;
# 877 "dir.c"
    if (! ((unsigned long )next != (unsigned long )((struct dirfile *)0))) {
# 877 "dir.c"
      goto while_break___0;
    }
# 878 "dir.c"
    if ((unsigned long )filename == (unsigned long )next->name) {
# 879 "dir.c"
      return ((int )next->impossible);
    } else
# 878 "dir.c"
    if ((int )*filename == (int )*(next->name)) {
# 878 "dir.c"
      if ((int )*filename == 0) {
# 879 "dir.c"
        return ((int )next->impossible);
      } else {
        {
# 878 "dir.c"
        tmp___2 = strcmp((char const *)(filename + 1), (char const *)(next->name + 1));
        }
# 878 "dir.c"
        if (! tmp___2) {
# 879 "dir.c"
          return ((int )next->impossible);
        }
      }
    }
# 877 "dir.c"
    next = next->next;
  }
  while_break___0: ;
  }
# 881 "dir.c"
  return (0);
}
}
# 887 "dir.c"
char *dir_name(char *dir )
{
  struct directory *tmp ;

  {
  {
# 891 "dir.c"
  tmp = find_directory(dir);
  }
# 891 "dir.c"
  return (tmp->name);
}
}
# 896 "dir.c"
void print_dir_data_base(void)
{
  register unsigned int i ;
  register unsigned int dirs___0 ;
  register unsigned int files___0 ;
  register unsigned int impossible ;
  register struct directory *dir ;
  char *tmp ;
  char *tmp___0 ;
  char *tmp___1 ;
  register unsigned int f ;
  register unsigned int im ;
  register unsigned int j ;
  register struct dirfile *df ;
  char *tmp___2 ;
  char *tmp___3 ;
  char *tmp___4 ;
  char *tmp___5 ;
  char *tmp___6 ;
  char *tmp___7 ;
  char *tmp___8 ;
  char *tmp___9 ;
  char *tmp___10 ;
  char *tmp___11 ;

  {
  {
# 902 "dir.c"
  tmp = dcgettext((char const *)((void *)0), "\n# Directories\n", 5);
# 902 "dir.c"
  puts((char const *)tmp);
# 904 "dir.c"
  impossible = 0U;
# 904 "dir.c"
  files___0 = impossible;
# 904 "dir.c"
  dirs___0 = files___0;
# 905 "dir.c"
  i = 0U;
  }
  {
# 905 "dir.c"
  while (1) {
    while_continue: ;
# 905 "dir.c"
    if (! (i < 199U)) {
# 905 "dir.c"
      goto while_break;
    }
# 906 "dir.c"
    dir = directories[i];
    {
# 906 "dir.c"
    while (1) {
      while_continue___0: ;
# 906 "dir.c"
      if (! ((unsigned long )dir != (unsigned long )((struct directory *)0))) {
# 906 "dir.c"
        goto while_break___0;
      }
# 908 "dir.c"
      dirs___0 ++;
# 909 "dir.c"
      if ((unsigned long )dir->contents == (unsigned long )((struct directory_contents *)0)) {
        {
# 910 "dir.c"
        tmp___0 = dcgettext((char const *)((void *)0), "# %s: could not be stat\'d.\n",
                            5);
# 910 "dir.c"
        printf((char const * __restrict )tmp___0, dir->name);
        }
      } else
# 911 "dir.c"
      if ((unsigned long )(dir->contents)->files == (unsigned long )((struct dirfile **)0)) {
        {
# 922 "dir.c"
        tmp___1 = dcgettext((char const *)((void *)0), "# %s (device %ld, inode %ld): could not be opened.\n",
                            5);
# 922 "dir.c"
        printf((char const * __restrict )tmp___1, dir->name, (long )(dir->contents)->dev,
               (long )(dir->contents)->ino);
        }
      } else {
# 929 "dir.c"
        f = 0U;
# 929 "dir.c"
        im = 0U;
# 932 "dir.c"
        j = 0U;
        {
# 932 "dir.c"
        while (1) {
          while_continue___1: ;
# 932 "dir.c"
          if (! (j < 107U)) {
# 932 "dir.c"
            goto while_break___1;
          }
# 933 "dir.c"
          df = *((dir->contents)->files + j);
          {
# 933 "dir.c"
          while (1) {
            while_continue___2: ;
# 933 "dir.c"
            if (! ((unsigned long )df != (unsigned long )((struct dirfile *)0))) {
# 933 "dir.c"
              goto while_break___2;
            }
# 934 "dir.c"
            if (df->impossible) {
# 935 "dir.c"
              im ++;
            } else {
# 937 "dir.c"
              f ++;
            }
# 933 "dir.c"
            df = df->next;
          }
          while_break___2: ;
          }
# 932 "dir.c"
          j ++;
        }
        while_break___1: ;
        }
        {
# 948 "dir.c"
        tmp___2 = dcgettext((char const *)((void *)0), "# %s (device %ld, inode %ld): ",
                            5);
# 948 "dir.c"
        printf((char const * __restrict )tmp___2, dir->name, (long )(dir->contents)->dev,
               (long )(dir->contents)->ino);
        }
# 953 "dir.c"
        if (f == 0U) {
          {
# 954 "dir.c"
          tmp___3 = dcgettext((char const *)((void *)0), "No", 5);
# 954 "dir.c"
          fputs((char const * __restrict )tmp___3, (FILE * __restrict )stdout);
          }
        } else {
          {
# 956 "dir.c"
          printf((char const * __restrict )"%u", f);
          }
        }
        {
# 957 "dir.c"
        tmp___4 = dcgettext((char const *)((void *)0), " files, ", 5);
# 957 "dir.c"
        fputs((char const * __restrict )tmp___4, (FILE * __restrict )stdout);
        }
# 958 "dir.c"
        if (im == 0U) {
          {
# 959 "dir.c"
          tmp___5 = dcgettext((char const *)((void *)0), "no", 5);
# 959 "dir.c"
          fputs((char const * __restrict )tmp___5, (FILE * __restrict )stdout);
          }
        } else {
          {
# 961 "dir.c"
          printf((char const * __restrict )"%u", im);
          }
        }
        {
# 962 "dir.c"
        tmp___6 = dcgettext((char const *)((void *)0), " impossibilities", 5);
# 962 "dir.c"
        fputs((char const * __restrict )tmp___6, (FILE * __restrict )stdout);
        }
# 963 "dir.c"
        if ((unsigned long )(dir->contents)->dirstream == (unsigned long )((DIR *)0)) {
          {
# 964 "dir.c"
          puts(".");
          }
        } else {
          {
# 966 "dir.c"
          tmp___7 = dcgettext((char const *)((void *)0), " so far.", 5);
# 966 "dir.c"
          puts((char const *)tmp___7);
          }
        }
# 967 "dir.c"
        files___0 += f;
# 968 "dir.c"
        impossible += im;
      }
# 906 "dir.c"
      dir = dir->next;
    }
    while_break___0: ;
    }
# 905 "dir.c"
    i ++;
  }
  while_break: ;
  }
  {
# 972 "dir.c"
  fputs((char const * __restrict )"\n# ", (FILE * __restrict )stdout);
  }
# 973 "dir.c"
  if (files___0 == 0U) {
    {
# 974 "dir.c"
    tmp___8 = dcgettext((char const *)((void *)0), "No", 5);
# 974 "dir.c"
    fputs((char const * __restrict )tmp___8, (FILE * __restrict )stdout);
    }
  } else {
    {
# 976 "dir.c"
    printf((char const * __restrict )"%u", files___0);
    }
  }
  {
# 977 "dir.c"
  tmp___9 = dcgettext((char const *)((void *)0), " files, ", 5);
# 977 "dir.c"
  fputs((char const * __restrict )tmp___9, (FILE * __restrict )stdout);
  }
# 978 "dir.c"
  if (impossible == 0U) {
    {
# 979 "dir.c"
    tmp___10 = dcgettext((char const *)((void *)0), "no", 5);
# 979 "dir.c"
    fputs((char const * __restrict )tmp___10, (FILE * __restrict )stdout);
    }
  } else {
    {
# 981 "dir.c"
    printf((char const * __restrict )"%u", impossible);
    }
  }
  {
# 982 "dir.c"
  tmp___11 = dcgettext((char const *)((void *)0), " impossibilities in %u directories.\n",
                       5);
# 982 "dir.c"
  printf((char const * __restrict )tmp___11, dirs___0);
  }
# 983 "dir.c"
  return;
}
}
# 1000 "dir.c"
static void *open_dirstream(char const *directory ) ;
# 1001 "dir.c"
static struct dirent *read_dirstream(void *stream ) ;
# 1003 "dir.c"
static void *open_dirstream(char const *directory )
{
  struct dirstream *new ;
  struct directory *dir ;
  struct directory *tmp ;
  char *tmp___0 ;

  {
  {
# 1008 "dir.c"
  tmp = find_directory((char *)directory);
# 1008 "dir.c"
  dir = tmp;
  }
# 1010 "dir.c"
  if ((unsigned long )dir->contents == (unsigned long )((struct directory_contents *)0)) {
# 1013 "dir.c"
    return ((void *)0);
  } else
# 1010 "dir.c"
  if ((unsigned long )(dir->contents)->files == (unsigned long )((struct dirfile **)0)) {
# 1013 "dir.c"
    return ((void *)0);
  }
  {
# 1018 "dir.c"
  dir_contents_file_exists_p(dir->contents, (char *)0);
# 1020 "dir.c"
  tmp___0 = xmalloc((unsigned int )sizeof(struct dirstream ));
# 1020 "dir.c"
  new = (struct dirstream *)tmp___0;
# 1021 "dir.c"
  new->contents = dir->contents;
# 1022 "dir.c"
  new->bucket = 0U;
# 1023 "dir.c"
  new->elt = *((new->contents)->files + 0);
  }
# 1025 "dir.c"
  return ((void *)new);
}
}
# 1034 "dir.c"
static char *buf ;
# 1035 "dir.c"
static unsigned int bufsz ;
# 1028 "dir.c"
static struct dirent *read_dirstream(void *stream )
{
  struct dirstream *ds ;
  register struct dirfile *df ;
  struct dirent *d ;
  unsigned int len ;
  size_t tmp ;

  {
# 1032 "dir.c"
  ds = (struct dirstream *)stream;
  {
# 1037 "dir.c"
  while (1) {
    while_continue: ;
# 1037 "dir.c"
    if (! (ds->bucket < 107U)) {
# 1037 "dir.c"
      goto while_break;
    }
    {
# 1039 "dir.c"
    while (1) {
      while_continue___0: ;
# 1039 "dir.c"
      df = ds->elt;
# 1039 "dir.c"
      if (! ((unsigned long )df != (unsigned long )((struct dirfile *)0))) {
# 1039 "dir.c"
        goto while_break___0;
      }
# 1041 "dir.c"
      ds->elt = df->next;
# 1042 "dir.c"
      if (! df->impossible) {
        {
# 1047 "dir.c"
        tmp = strlen((char const *)df->name);
# 1047 "dir.c"
        len = (unsigned int )(tmp + 1UL);
        }
# 1048 "dir.c"
        if ((sizeof(*d) - sizeof(d->d_name)) + (unsigned long )len > (unsigned long )bufsz) {
# 1050 "dir.c"
          if ((unsigned long )buf != (unsigned long )((char *)0)) {
            {
# 1051 "dir.c"
            free((void *)buf);
            }
          }
# 1052 "dir.c"
          bufsz *= 2U;
# 1053 "dir.c"
          if ((sizeof(*d) - sizeof(d->d_name)) + (unsigned long )len > (unsigned long )bufsz) {
# 1054 "dir.c"
            bufsz = (unsigned int )((sizeof(*d) - sizeof(d->d_name)) + (unsigned long )len);
          }
          {
# 1055 "dir.c"
          buf = xmalloc(bufsz);
          }
        }
        {
# 1057 "dir.c"
        d = (struct dirent *)buf;
# 1058 "dir.c"
        d->d_ino = (__ino_t )1;
# 1063 "dir.c"
        d->d_type = (unsigned char)0;
# 1065 "dir.c"
        memcpy((void * __restrict )(d->d_name), (void const * __restrict )df->name,
               (size_t )len);
        }
# 1066 "dir.c"
        return (d);
      }
    }
    while_break___0: ;
    }
# 1069 "dir.c"
    (ds->bucket) ++;
# 1069 "dir.c"
    if (ds->bucket == 107U) {
# 1070 "dir.c"
      goto while_break;
    }
# 1071 "dir.c"
    ds->elt = *((ds->contents)->files + ds->bucket);
  }
  while_break: ;
  }
# 1074 "dir.c"
  return ((struct dirent *)0);
}
}
# 1077 "dir.c"
static void ansi_free(void *p )
{


  {
# 1081 "dir.c"
  if (p) {
    {
# 1082 "dir.c"
    free(p);
    }
  }
# 1083 "dir.c"
  return;
}
}
# 1103 "dir.c"
void dir_setup_glob(glob_t *gl )
{


  {
# 1108 "dir.c"
  gl->gl_opendir = & open_dirstream;
# 1109 "dir.c"
  gl->gl_readdir = & read_dirstream;
# 1110 "dir.c"
  gl->gl_closedir = & ansi_free;
# 1111 "dir.c"
  gl->gl_stat = (int (*)(char const * , struct stat * ))(& stat);
# 1114 "dir.c"
  return;
}
}
# 1 "expand.o"
#pragma merger("0","/tmp/cil-3QgulJGN.i","-g,-O0")
# 69 "/usr/include/assert.h"
extern __attribute__((__nothrow__, __noreturn__)) void ( __attribute__((__leaf__)) __assert_fail)(char const *__assertion ,
                                                                                                   char const *__file ,
                                                                                                   unsigned int __line ,
                                                                                                   char const *__function ) ;
# 121 "/usr/include/string.h"
extern __attribute__((__nothrow__)) char *( __attribute__((__nonnull__(1,2), __leaf__)) strcpy)(char * __restrict __dest ,
                                                                                                 char const * __restrict __src ) ;
# 405 "make.h"
char *lindex(char const *s , char const *limit , int c ) ;
# 409 "make.h"
char *find_percent(char *pattern ) ;
# 466 "make.h"
struct floc const *reading_file ;
# 474 "make.h"
int warn_undefined_variables_flag ;
# 76 "variable.h"
char *variable_buffer ;
# 77 "variable.h"
struct variable_set_list *current_variable_set_list ;
# 80 "variable.h"
char *variable_buffer_output(char *ptr , char *string___0 , unsigned int length___0 ) ;
# 81 "variable.h"
char *variable_expand(char *line ) ;
# 82 "variable.h"
char *allocated_variable_expand_for_file(char *line , struct file *file ) ;
# 85 "variable.h"
char *expand_argument(char *str , char *end ) ;
# 86 "variable.h"
char *variable_expand_string(char *line , char *string___0 , long length___0 ) ;
# 90 "variable.h"
int handle_function(char **op , char **stringp ) ;
# 92 "variable.h"
char *subst_expand(char *o , char *text , char *subst , char *replace , unsigned int slen ,
                   unsigned int rlen , int by_word , int suffix_only ) ;
# 94 "variable.h"
char *patsubst_expand(char *o , char *text , char *pattern , char *replace , char *pattern_percent ,
                      char *replace_percent ) ;
# 98 "variable.h"
char *recursively_expand(struct variable *v ) ;
# 111 "variable.h"
struct variable *lookup_variable(char *name , unsigned int length___0 ) ;
# 43 "expand.c"
static unsigned int variable_buffer_length ;
# 53 "expand.c"
char *variable_buffer_output(char *ptr , char *string___0 , unsigned int length___0 )
{
  register unsigned int newlen ;
  unsigned int offset ;
  char *tmp ;

  {
# 58 "expand.c"
  newlen = (unsigned int )((long )length___0 + (ptr - variable_buffer));
# 60 "expand.c"
  if (newlen + 5U > variable_buffer_length) {
# 62 "expand.c"
    offset = (unsigned int )(ptr - variable_buffer);
# 63 "expand.c"
    if (newlen + 100U > 2U * variable_buffer_length) {
# 63 "expand.c"
      variable_buffer_length = newlen + 100U;
    } else {
# 63 "expand.c"
      variable_buffer_length = 2U * variable_buffer_length;
    }
    {
# 66 "expand.c"
    tmp = xrealloc(variable_buffer, variable_buffer_length);
# 66 "expand.c"
    variable_buffer = tmp;
# 68 "expand.c"
    ptr = variable_buffer + offset;
    }
  }
  {
# 71 "expand.c"
  memmove((void *)ptr, (void const *)string___0, (size_t )length___0);
  }
# 72 "expand.c"
  return (ptr + length___0);
}
}
# 77 "expand.c"
static char *initialize_variable_output(void)
{
  char *tmp ;

  {
# 82 "expand.c"
  if ((unsigned long )variable_buffer == (unsigned long )((char *)0)) {
    {
# 84 "expand.c"
    variable_buffer_length = 200U;
# 85 "expand.c"
    tmp = xmalloc(variable_buffer_length);
# 85 "expand.c"
    variable_buffer = tmp;
# 86 "expand.c"
    *(variable_buffer + 0) = (char )'\000';
    }
  }
# 89 "expand.c"
  return (variable_buffer);
}
}
# 94 "expand.c"
static char *allocated_variable_append(struct variable *v ) ;
# 96 "expand.c"
char *recursively_expand(struct variable *v )
{
  char *value ;
  char *tmp ;

  {
# 102 "expand.c"
  if (v->expanding) {
    {
# 104 "expand.c"
    tmp = dcgettext((char const *)((void *)0), "Recursive variable `%s\' references itself (eventually)",
                    5);
# 104 "expand.c"
    fatal(reading_file, (char const *)tmp, v->name);
    }
  }
# 108 "expand.c"
  v->expanding = 1U;
# 109 "expand.c"
  if (v->append) {
    {
# 110 "expand.c"
    value = allocated_variable_append(v);
    }
  } else {
    {
# 112 "expand.c"
    value = allocated_variable_expand_for_file(v->value, (struct file *)0);
    }
  }
# 113 "expand.c"
  v->expanding = 0U;
# 115 "expand.c"
  return (value);
}
}
# 121 "expand.c"
__inline static void warn_undefined(char *name , unsigned int length___0 )
{
  char *tmp ;

  {
# 128 "expand.c"
  if (warn_undefined_variables_flag) {
    {
# 129 "expand.c"
    tmp = dcgettext((char const *)((void *)0), "warning: undefined variable `%.*s\'",
                    5);
# 129 "expand.c"
    error(reading_file, (char const *)tmp, (int )length___0, name);
    }
  }
# 131 "expand.c"
  return;
}
}
# 136 "expand.c"
__inline static char *reference_variable(char *o , char *name , unsigned int length___0 )
{
  register struct variable *v ;
  char *value ;
  char *tmp ;
  size_t tmp___0 ;

  {
  {
# 147 "expand.c"
  v = lookup_variable(name, length___0);
  }
# 149 "expand.c"
  if ((unsigned long )v == (unsigned long )((struct variable *)0)) {
    {
# 150 "expand.c"
    warn_undefined(name, length___0);
    }
  }
# 152 "expand.c"
  if ((unsigned long )v == (unsigned long )((struct variable *)0)) {
# 153 "expand.c"
    return (o);
  } else
# 152 "expand.c"
  if ((int )*(v->value) == 0) {
# 153 "expand.c"
    return (o);
  }
# 155 "expand.c"
  if (v->recursive) {
    {
# 155 "expand.c"
    tmp = recursively_expand(v);
# 155 "expand.c"
    value = tmp;
    }
  } else {
# 155 "expand.c"
    value = v->value;
  }
  {
# 157 "expand.c"
  tmp___0 = strlen((char const *)value);
# 157 "expand.c"
  o = variable_buffer_output(o, value, (unsigned int )tmp___0);
  }
# 159 "expand.c"
  if (v->recursive) {
    {
# 160 "expand.c"
    free((void *)value);
    }
  }
# 162 "expand.c"
  return (o);
}
}
# 174 "expand.c"
char *variable_expand_string(char *line , char *string___0 , long length___0 )
{
  register struct variable *v ;
  register char *p ;
  register char *o ;
  register char *p1 ;
  char save_char ;
  unsigned int line_offset ;
  size_t tmp ;
  size_t tmp___0 ;
  char openparen ;
  char closeparen ;
  int tmp___1 ;
  register char *beg ;
  int free_beg ;
  char *op ;
  char *begp ;
  char *end ;
  char *colon ;
  int tmp___2 ;
  char *tmp___3 ;
  int count ;
  char *subst_beg ;
  char *subst_end ;
  char *replace_beg ;
  char *replace_end ;
  char *value ;
  char *tmp___4 ;
  char *tmp___5 ;
  char *pattern ;
  char *percent ;
  void *tmp___6 ;
  char *replace ;
  void *tmp___7 ;
  size_t tmp___8 ;
  unsigned short const **tmp___9 ;
  char name[5] ;
  size_t tmp___10 ;

  {
# 182 "expand.c"
  save_char = (char )'\000';
# 185 "expand.c"
  if (! line) {
    {
# 186 "expand.c"
    line = initialize_variable_output();
    }
  }
# 188 "expand.c"
  p = string___0;
# 189 "expand.c"
  o = line;
# 190 "expand.c"
  line_offset = (unsigned int )(line - variable_buffer);
# 192 "expand.c"
  if (length___0 >= 0L) {
# 194 "expand.c"
    save_char = *(string___0 + length___0);
# 195 "expand.c"
    *(string___0 + length___0) = (char )'\000';
  }
  {
# 198 "expand.c"
  while (1) {
    while_continue: ;
    {
# 204 "expand.c"
    p1 = strchr((char const *)p, '$');
    }
# 206 "expand.c"
    if ((unsigned long )p1 != (unsigned long )((char *)0)) {
# 206 "expand.c"
      tmp___0 = (size_t )(p1 - p);
    } else {
      {
# 206 "expand.c"
      tmp = strlen((char const *)p);
# 206 "expand.c"
      tmp___0 = tmp + 1UL;
      }
    }
    {
# 206 "expand.c"
    o = variable_buffer_output(o, p, (unsigned int )tmp___0);
    }
# 208 "expand.c"
    if ((unsigned long )p1 == (unsigned long )((char *)0)) {
# 209 "expand.c"
      goto while_break;
    }
# 210 "expand.c"
    p = p1 + 1;
    {
# 215 "expand.c"
    if ((int )*p == 36) {
# 215 "expand.c"
      goto case_36;
    }
# 221 "expand.c"
    if ((int )*p == 40) {
# 221 "expand.c"
      goto case_40;
    }
# 221 "expand.c"
    if ((int )*p == 123) {
# 221 "expand.c"
      goto case_40;
    }
# 365 "expand.c"
    if ((int )*p == 0) {
# 365 "expand.c"
      goto case_0;
    }
# 368 "expand.c"
    goto switch_default;
    case_36:
    {
# 218 "expand.c"
    o = variable_buffer_output(o, p, 1U);
    }
# 219 "expand.c"
    goto switch_break;
    case_40:
    case_123:
# 225 "expand.c"
    openparen = *p;
# 226 "expand.c"
    if ((int )openparen == 40) {
# 226 "expand.c"
      tmp___1 = ')';
    } else {
# 226 "expand.c"
      tmp___1 = '}';
    }
    {
# 226 "expand.c"
    closeparen = (char )tmp___1;
# 227 "expand.c"
    beg = p + 1;
# 228 "expand.c"
    free_beg = 0;
# 232 "expand.c"
    op = o;
# 233 "expand.c"
    begp = p;
# 234 "expand.c"
    tmp___2 = handle_function(& op, & begp);
    }
# 234 "expand.c"
    if (tmp___2) {
# 236 "expand.c"
      o = op;
# 237 "expand.c"
      p = begp;
# 238 "expand.c"
      goto switch_break;
    }
    {
# 244 "expand.c"
    end = strchr((char const *)beg, (int )closeparen);
    }
# 245 "expand.c"
    if ((unsigned long )end == (unsigned long )((char *)0)) {
      {
# 247 "expand.c"
      tmp___3 = dcgettext((char const *)((void *)0), "unterminated variable reference",
                          5);
# 247 "expand.c"
      fatal(reading_file, (char const *)tmp___3);
      }
    }
    {
# 248 "expand.c"
    p1 = lindex((char const *)beg, (char const *)end, '$');
    }
# 249 "expand.c"
    if ((unsigned long )p1 != (unsigned long )((char *)0)) {
# 253 "expand.c"
      count = 0;
# 254 "expand.c"
      p = beg;
      {
# 254 "expand.c"
      while (1) {
        while_continue___0: ;
# 254 "expand.c"
        if (! ((int )*p != 0)) {
# 254 "expand.c"
          goto while_break___0;
        }
# 256 "expand.c"
        if ((int )*p == (int )openparen) {
# 257 "expand.c"
          count ++;
        } else
# 258 "expand.c"
        if ((int )*p == (int )closeparen) {
# 258 "expand.c"
          count --;
# 258 "expand.c"
          if (count < 0) {
# 259 "expand.c"
            goto while_break___0;
          }
        }
# 254 "expand.c"
        p ++;
      }
      while_break___0: ;
      }
# 264 "expand.c"
      if (count < 0) {
        {
# 266 "expand.c"
        beg = expand_argument(beg, p);
# 267 "expand.c"
        free_beg = 1;
# 268 "expand.c"
        end = strchr((char const *)beg, '\000');
        }
      }
    } else {
# 275 "expand.c"
      p = end;
    }
    {
# 281 "expand.c"
    colon = lindex((char const *)beg, (char const *)end, ':');
    }
# 282 "expand.c"
    if ((unsigned long )colon != (unsigned long )((char *)0)) {
      {
# 287 "expand.c"
      subst_beg = colon + 1;
# 288 "expand.c"
      subst_end = strchr((char const *)subst_beg, '=');
      }
# 289 "expand.c"
      if ((unsigned long )subst_end == (unsigned long )((char *)0)) {
# 293 "expand.c"
        colon = (char *)0;
      } else {
        {
# 296 "expand.c"
        replace_beg = subst_end + 1;
# 297 "expand.c"
        replace_end = end;
# 301 "expand.c"
        v = lookup_variable(beg, (unsigned int )(colon - beg));
        }
# 302 "expand.c"
        if ((unsigned long )v == (unsigned long )((struct variable *)0)) {
          {
# 303 "expand.c"
          warn_undefined(beg, (unsigned int )(colon - beg));
          }
        }
# 305 "expand.c"
        if ((unsigned long )v != (unsigned long )((struct variable *)0)) {
# 305 "expand.c"
          if ((int )*(v->value) != 0) {
# 307 "expand.c"
            if (v->recursive) {
              {
# 307 "expand.c"
              tmp___4 = recursively_expand(v);
# 307 "expand.c"
              tmp___5 = tmp___4;
              }
            } else {
# 307 "expand.c"
              tmp___5 = v->value;
            }
# 307 "expand.c"
            value = tmp___5;
# 310 "expand.c"
            if (free_beg) {
# 312 "expand.c"
              *subst_end = (char )'\000';
# 313 "expand.c"
              pattern = subst_beg;
            } else {
              {
# 317 "expand.c"
              tmp___6 = __builtin_alloca((unsigned long )((subst_end - subst_beg) + 1L));
# 317 "expand.c"
              pattern = (char *)tmp___6;
# 319 "expand.c"
              memmove((void *)pattern, (void const *)subst_beg, (size_t )(subst_end - subst_beg));
# 320 "expand.c"
              *(pattern + (subst_end - subst_beg)) = (char )'\000';
              }
            }
            {
# 322 "expand.c"
            percent = find_percent(pattern);
            }
# 323 "expand.c"
            if ((unsigned long )percent != (unsigned long )((char *)0)) {
# 326 "expand.c"
              if (free_beg) {
# 328 "expand.c"
                *replace_end = (char )'\000';
# 329 "expand.c"
                replace = replace_beg;
              } else {
                {
# 333 "expand.c"
                tmp___7 = __builtin_alloca((unsigned long )((replace_end - replace_beg) + 1L));
# 333 "expand.c"
                replace = (char *)tmp___7;
# 336 "expand.c"
                memmove((void *)replace, (void const *)replace_beg, (size_t )(replace_end - replace_beg));
# 338 "expand.c"
                *(replace + (replace_end - replace_beg)) = (char )'\000';
                }
              }
              {
# 341 "expand.c"
              o = patsubst_expand(o, value, pattern, replace, percent, (char *)0);
              }
            } else {
              {
# 345 "expand.c"
              tmp___8 = strlen((char const *)pattern);
# 345 "expand.c"
              o = subst_expand(o, value, pattern, replace_beg, (unsigned int )tmp___8,
                               (unsigned int )(end - replace_beg), 0, 1);
              }
            }
# 350 "expand.c"
            if (v->recursive) {
              {
# 351 "expand.c"
              free((void *)value);
              }
            }
          }
        }
      }
    }
# 356 "expand.c"
    if ((unsigned long )colon == (unsigned long )((char *)0)) {
      {
# 359 "expand.c"
      o = reference_variable(o, beg, (unsigned int )(end - beg));
      }
    }
# 361 "expand.c"
    if (free_beg) {
      {
# 362 "expand.c"
      free((void *)beg);
      }
    }
# 364 "expand.c"
    goto switch_break;
    case_0:
# 367 "expand.c"
    goto switch_break;
    switch_default:
    {
# 370 "expand.c"
    tmp___9 = __ctype_b_loc();
    }
# 370 "expand.c"
    if ((int const )*(*tmp___9 + (int )*(p + -1)) & 1) {
# 371 "expand.c"
      goto switch_break;
    }
    {
# 379 "expand.c"
    name[0] = (char )'$';
# 380 "expand.c"
    name[1] = (char )'(';
# 381 "expand.c"
    name[2] = *p;
# 382 "expand.c"
    name[3] = (char )')';
# 383 "expand.c"
    name[4] = (char )'\000';
# 384 "expand.c"
    p1 = allocated_variable_expand_for_file(name, (struct file *)0);
# 385 "expand.c"
    tmp___10 = strlen((char const *)p1);
# 385 "expand.c"
    o = variable_buffer_output(o, p1, (unsigned int )tmp___10);
# 386 "expand.c"
    free((void *)p1);
    }
# 389 "expand.c"
    goto switch_break;
    switch_break: ;
    }
# 392 "expand.c"
    if ((int )*p == 0) {
# 393 "expand.c"
      goto while_break;
    } else {
# 395 "expand.c"
      p ++;
    }
  }
  while_break: ;
  }
# 398 "expand.c"
  if (save_char) {
# 399 "expand.c"
    *(string___0 + length___0) = save_char;
  }
  {
# 401 "expand.c"
  variable_buffer_output(o, (char *)"", 1U);
  }
# 402 "expand.c"
  return (variable_buffer + line_offset);
}
}
# 410 "expand.c"
char *variable_expand(char *line )
{
  char *tmp ;

  {
  {
# 414 "expand.c"
  tmp = variable_expand_string((char *)((void *)0), line, -1L);
  }
# 414 "expand.c"
  return (tmp);
}
}
# 423 "expand.c"
char *expand_argument(char *str , char *end )
{
  char *tmp ;
  void *tmp___0 ;
  char *tmp___1 ;

  {
# 429 "expand.c"
  if (! end) {
# 430 "expand.c"
    tmp = str;
  } else
# 429 "expand.c"
  if ((int )*end == 0) {
# 430 "expand.c"
    tmp = str;
  } else {
    {
# 433 "expand.c"
    tmp___0 = __builtin_alloca((unsigned long )((end - str) + 1L));
# 433 "expand.c"
    tmp = (char *)tmp___0;
# 434 "expand.c"
    memmove((void *)tmp, (void const *)str, (size_t )(end - str));
# 435 "expand.c"
    *(tmp + (end - str)) = (char )'\000';
    }
  }
  {
# 438 "expand.c"
  tmp___1 = allocated_variable_expand_for_file(tmp, (struct file *)0);
  }
# 438 "expand.c"
  return (tmp___1);
}
}
# 444 "expand.c"
static char *variable_expand_for_file(char *line , struct file *file )
{
  char *result___0 ;
  struct variable_set_list *save ;
  char *tmp ;

  {
# 452 "expand.c"
  if ((unsigned long )file == (unsigned long )((struct file *)0)) {
    {
# 453 "expand.c"
    tmp = variable_expand(line);
    }
# 453 "expand.c"
    return (tmp);
  }
# 455 "expand.c"
  save = current_variable_set_list;
# 456 "expand.c"
  current_variable_set_list = file->variables;
# 457 "expand.c"
  if (file->cmds) {
# 457 "expand.c"
    if ((file->cmds)->fileinfo.filenm) {
# 458 "expand.c"
      reading_file = (struct floc const *)(& (file->cmds)->fileinfo);
    } else {
# 460 "expand.c"
      reading_file = (struct floc const *)0;
    }
  } else {
# 460 "expand.c"
    reading_file = (struct floc const *)0;
  }
  {
# 461 "expand.c"
  result___0 = variable_expand(line);
# 462 "expand.c"
  current_variable_set_list = save;
# 463 "expand.c"
  reading_file = (struct floc const *)0;
  }
# 465 "expand.c"
  return (result___0);
}
}
# 471 "expand.c"
static char *allocated_variable_append(struct variable *v )
{
  struct variable_set_list *save ;
  int len ;
  size_t tmp ;
  char *var ;
  void *tmp___0 ;
  char *value ;
  char *obuf ;
  unsigned int olen ;
  size_t tmp___2 ;

  {
  {
# 476 "expand.c"
  tmp = strlen((char const *)v->name);
# 476 "expand.c"
  len = (int )tmp;
# 477 "expand.c"
  tmp___0 = __builtin_alloca((unsigned long )(len + 4));
# 477 "expand.c"
  var = (char *)tmp___0;
# 480 "expand.c"
  obuf = variable_buffer;
# 481 "expand.c"
  olen = variable_buffer_length;
# 483 "expand.c"
  variable_buffer = (char *)0;
  }
# 485 "expand.c"
  if (! ((unsigned long )current_variable_set_list->next != (unsigned long )((struct variable_set_list *)0))) {
    {
# 485 "expand.c"
    __assert_fail("current_variable_set_list->next != 0", "expand.c", 485U, "allocated_variable_append");
    }
  }
  {
# 486 "expand.c"
  save = current_variable_set_list;
# 487 "expand.c"
  current_variable_set_list = current_variable_set_list->next;
# 489 "expand.c"
  *(var + 0) = (char )'$';
# 490 "expand.c"
  *(var + 1) = (char )'(';
# 491 "expand.c"
  strcpy((char * __restrict )(var + 2), (char const * __restrict )v->name);
# 492 "expand.c"
  *(var + (len + 2)) = (char )')';
# 493 "expand.c"
  *(var + (len + 3)) = (char )'\000';
# 495 "expand.c"
  value = variable_expand_for_file(var, (struct file *)0);
# 497 "expand.c"
  current_variable_set_list = save;
# 499 "expand.c"
  tmp___2 = strlen((char const *)value);
# 499 "expand.c"
  value += tmp___2;
# 500 "expand.c"
  value = variable_buffer_output(value, (char *)" ", 1U);
# 501 "expand.c"
  value = variable_expand_string(value, v->value, -1L);
# 503 "expand.c"
  value = variable_buffer;
# 510 "expand.c"
  variable_buffer = obuf;
# 511 "expand.c"
  variable_buffer_length = olen;
  }
# 513 "expand.c"
  return (value);
}
}
# 519 "expand.c"
char *allocated_variable_expand_for_file(char *line , struct file *file )
{
  char *value ;
  char *obuf ;
  unsigned int olen ;

  {
  {
# 526 "expand.c"
  obuf = variable_buffer;
# 527 "expand.c"
  olen = variable_buffer_length;
# 529 "expand.c"
  variable_buffer = (char *)0;
# 531 "expand.c"
  value = variable_expand_for_file(line, file);
# 538 "expand.c"
  variable_buffer = obuf;
# 539 "expand.c"
  variable_buffer_length = olen;
  }
# 541 "expand.c"
  return (value);
}
}
# 1 "file.o"
#pragma merger("0","/tmp/cil-lFW07Sp1.i","-g,-O0")
# 137 "/usr/include/stdio.h"
extern struct _IO_FILE *stderr ;
# 204 "/usr/include/stdio.h"
extern int fflush(FILE *__stream ) ;
# 524 "/usr/include/stdio.h"
extern int putchar(int __c ) ;
# 75 "/usr/include/time.h"
extern __attribute__((__nothrow__)) time_t ( __attribute__((__leaf__)) time)(time_t *__timer ) ;
# 123 "/usr/include/time.h"
extern __attribute__((__nothrow__)) struct tm *( __attribute__((__leaf__)) localtime)(time_t const *__timer ) ;
# 219 "/usr/include/time.h"
extern __attribute__((__nothrow__)) int ( __attribute__((__leaf__)) clock_gettime)(clockid_t __clock_id ,
                                                                                    struct timespec *__tp ) ;
# 588 "/usr/include/stdlib.h"
extern __attribute__((__nothrow__, __noreturn__)) void ( __attribute__((__leaf__)) abort)(void) ;
# 470 "make.h"
int just_print_flag ;
# 470 "make.h"
int silent_flag ;
# 470 "make.h"
int ignore_errors_flag ;
# 471 "make.h"
int question_flag ;
# 471 "make.h"
int touch_flag ;
# 474 "make.h"
int posix_pedantic ;
# 474 "make.h"
int not_parallel ;
# 99 "filedef.h"
unsigned int num_intermediates ;
# 103 "filedef.h"
unsigned int considered ;
# 111 "filedef.h"
void snap_deps(void) ;
# 112 "filedef.h"
void rename_file(struct file *file , char *name ) ;
# 113 "filedef.h"
void rehash_file(struct file *file , char *name ) ;
# 114 "filedef.h"
void file_hash_enter(struct file *file , char *name , unsigned int oldhash , char *oldname ) ;
# 162 "filedef.h"
uintmax_t file_timestamp_now(void) ;
# 163 "filedef.h"
void file_timestamp_sprintf(char *p , uintmax_t ts ) ;
# 106 "variable.h"
void print_file_variables(struct file *file ) ;
# 108 "variable.h"
void merge_variable_set_lists(struct variable_set_list **setlist0 , struct variable_set_list *setlist1 ) ;
# 137 "variable.h"
int export_all_variables ;
# 35 "file.c"
static struct file *files[1007] ;
# 39 "file.c"
unsigned int num_intermediates = 0U;
# 43 "file.c"
unsigned int considered = 0U;
# 50 "file.c"
struct file *lookup_file(char *name )
{
  register struct file *f ;
  register char *n ;
  register unsigned int hashval ;
  int tmp___0 ;

  {
# 61 "file.c"
  if (! ((int )*name != 0)) {
    {
# 61 "file.c"
    __assert_fail("*name != \'\\0\'", "file.c", 61U, "lookup_file");
    }
  }
  {
# 78 "file.c"
  while (1) {
    while_continue: ;
# 78 "file.c"
    if ((int )*(name + 0) == 46) {
# 78 "file.c"
      if ((int )*(name + 1) == 47) {
# 78 "file.c"
        if (! ((int )*(name + 2) != 0)) {
# 78 "file.c"
          goto while_break;
        }
      } else {
# 78 "file.c"
        goto while_break;
      }
    } else {
# 78 "file.c"
      goto while_break;
    }
# 80 "file.c"
    name += 2;
    {
# 81 "file.c"
    while (1) {
      while_continue___0: ;
# 81 "file.c"
      if (! ((int )*name == 47)) {
# 81 "file.c"
        goto while_break___0;
      }
# 83 "file.c"
      name ++;
    }
    while_break___0: ;
    }
  }
  while_break: ;
  }
# 86 "file.c"
  if ((int )*name == 0) {
# 94 "file.c"
    name = (char *)"./";
  }
# 98 "file.c"
  hashval = 0U;
# 99 "file.c"
  n = name;
  {
# 99 "file.c"
  while (1) {
    while_continue___1: ;
# 99 "file.c"
    if (! ((int )*n != 0)) {
# 99 "file.c"
      goto while_break___1;
    }
# 100 "file.c"
    hashval += (unsigned int )*n;
# 100 "file.c"
    hashval = (hashval << 7) + (hashval >> 20);
# 99 "file.c"
    n ++;
  }
  while_break___1: ;
  }
# 101 "file.c"
  hashval %= 1007U;
# 103 "file.c"
  f = files[hashval];
  {
# 103 "file.c"
  while (1) {
    while_continue___2: ;
# 103 "file.c"
    if (! ((unsigned long )f != (unsigned long )((struct file *)0))) {
# 103 "file.c"
      goto while_break___2;
    }
# 105 "file.c"
    if ((unsigned long )f->hname == (unsigned long )name) {
# 110 "file.c"
      return (f);
    } else
# 105 "file.c"
    if ((int )*(f->hname) == (int )*name) {
# 105 "file.c"
      if ((int )*(f->hname) == 0) {
# 110 "file.c"
        return (f);
      } else {
        {
# 105 "file.c"
        tmp___0 = strcmp((char const *)(f->hname + 1), (char const *)(name + 1));
        }
# 105 "file.c"
        if (! tmp___0) {
# 110 "file.c"
          return (f);
        }
      }
    }
# 103 "file.c"
    f = f->next;
  }
  while_break___2: ;
  }
# 116 "file.c"
  return ((struct file *)0);
}
}
# 119 "file.c"
struct file *enter_file(char *name )
{
  register struct file *f ;
  register struct file *new ;
  register char *n ;
  register unsigned int hashval ;
  int tmp___0 ;
  char *tmp___1 ;
  char *tmp___2 ;

  {
# 130 "file.c"
  if (! ((int )*name != 0)) {
    {
# 130 "file.c"
    __assert_fail("*name != \'\\0\'", "file.c", 130U, "enter_file");
    }
  }
# 147 "file.c"
  hashval = 0U;
# 148 "file.c"
  n = name;
  {
# 148 "file.c"
  while (1) {
    while_continue: ;
# 148 "file.c"
    if (! ((int )*n != 0)) {
# 148 "file.c"
      goto while_break;
    }
# 149 "file.c"
    hashval += (unsigned int )*n;
# 149 "file.c"
    hashval = (hashval << 7) + (hashval >> 20);
# 148 "file.c"
    n ++;
  }
  while_break: ;
  }
# 150 "file.c"
  hashval %= 1007U;
# 152 "file.c"
  f = files[hashval];
  {
# 152 "file.c"
  while (1) {
    while_continue___0: ;
# 152 "file.c"
    if (! ((unsigned long )f != (unsigned long )((struct file *)0))) {
# 152 "file.c"
      goto while_break___0;
    }
# 153 "file.c"
    if ((unsigned long )f->hname == (unsigned long )name) {
# 154 "file.c"
      goto while_break___0;
    } else
# 153 "file.c"
    if ((int )*(f->hname) == (int )*name) {
# 153 "file.c"
      if ((int )*(f->hname) == 0) {
# 154 "file.c"
        goto while_break___0;
      } else {
        {
# 153 "file.c"
        tmp___0 = strcmp((char const *)(f->hname + 1), (char const *)(name + 1));
        }
# 153 "file.c"
        if (! tmp___0) {
# 154 "file.c"
          goto while_break___0;
        }
      }
    }
# 152 "file.c"
    f = f->next;
  }
  while_break___0: ;
  }
# 156 "file.c"
  if ((unsigned long )f != (unsigned long )((struct file *)0)) {
# 156 "file.c"
    if (! f->double_colon) {
# 161 "file.c"
      return (f);
    }
  }
  {
# 164 "file.c"
  tmp___1 = xmalloc((unsigned int )sizeof(struct file ));
# 164 "file.c"
  new = (struct file *)tmp___1;
# 165 "file.c"
  memset((void *)((char *)new), 0, sizeof(struct file ));
# 166 "file.c"
  tmp___2 = name;
# 166 "file.c"
  new->hname = tmp___2;
# 166 "file.c"
  new->name = tmp___2;
# 167 "file.c"
  new->update_status = (short)-1;
  }
# 169 "file.c"
  if ((unsigned long )f == (unsigned long )((struct file *)0)) {
# 172 "file.c"
    new->next = files[hashval];
# 173 "file.c"
    files[hashval] = new;
  } else {
# 178 "file.c"
    new->double_colon = f;
    {
# 179 "file.c"
    while (1) {
      while_continue___1: ;
# 179 "file.c"
      if (! ((unsigned long )f->prev != (unsigned long )((struct file *)0))) {
# 179 "file.c"
        goto while_break___1;
      }
# 180 "file.c"
      f = f->prev;
    }
    while_break___1: ;
    }
# 181 "file.c"
    f->prev = new;
  }
# 184 "file.c"
  return (new);
}
}
# 191 "file.c"
void rehash_file(struct file *file , char *name )
{
  char *oldname ;
  register unsigned int oldhash ;
  register char *n ;

  {
# 196 "file.c"
  oldname = file->hname;
  {
# 200 "file.c"
  while (1) {
    while_continue: ;
# 200 "file.c"
    if (! ((unsigned long )file->renamed != (unsigned long )((struct file *)0))) {
# 200 "file.c"
      goto while_break;
    }
# 201 "file.c"
    file = file->renamed;
  }
  while_break: ;
  }
# 205 "file.c"
  oldhash = 0U;
# 206 "file.c"
  n = oldname;
  {
# 206 "file.c"
  while (1) {
    while_continue___0: ;
# 206 "file.c"
    if (! ((int )*n != 0)) {
# 206 "file.c"
      goto while_break___0;
    }
# 207 "file.c"
    oldhash += (unsigned int )*n;
# 207 "file.c"
    oldhash = (oldhash << 7) + (oldhash >> 20);
# 206 "file.c"
    n ++;
  }
  while_break___0: ;
  }
  {
# 209 "file.c"
  file_hash_enter(file, name, oldhash, file->name);
  }
# 210 "file.c"
  return;
}
}
# 216 "file.c"
void rename_file(struct file *file , char *name )
{


  {
  {
# 221 "file.c"
  rehash_file(file, name);
  }
  {
# 222 "file.c"
  while (1) {
    while_continue: ;
# 222 "file.c"
    if (! file) {
# 222 "file.c"
      goto while_break;
    }
# 224 "file.c"
    file->name = file->hname;
# 225 "file.c"
    file = file->prev;
  }
  while_break: ;
  }
# 227 "file.c"
  return;
}
}
# 229 "file.c"
void file_hash_enter(struct file *file , char *name , unsigned int oldhash , char *oldname )
{
  unsigned int oldbucket ;
  register unsigned int newhash ;
  register unsigned int newbucket ;
  struct file *oldfile ;
  register char *n ;
  register struct file *f ;
  int tmp ;
  struct file *lastf ;
  register struct dep *d ;
  char *tmp___0 ;
  char *tmp___1 ;
  char *tmp___2 ;
  char *tmp___3 ;
  char *tmp___4 ;
  char *tmp___5 ;

  {
# 236 "file.c"
  oldbucket = oldhash % 1007U;
# 242 "file.c"
  newhash = 0U;
# 243 "file.c"
  n = name;
  {
# 243 "file.c"
  while (1) {
    while_continue: ;
# 243 "file.c"
    if (! ((int )*n != 0)) {
# 243 "file.c"
      goto while_break;
    }
# 244 "file.c"
    newhash += (unsigned int )*n;
# 244 "file.c"
    newhash = (newhash << 7) + (newhash >> 20);
# 243 "file.c"
    n ++;
  }
  while_break: ;
  }
# 245 "file.c"
  newbucket = newhash % 1007U;
# 249 "file.c"
  oldfile = files[newbucket];
  {
# 249 "file.c"
  while (1) {
    while_continue___0: ;
# 249 "file.c"
    if (! ((unsigned long )oldfile != (unsigned long )((struct file *)0))) {
# 249 "file.c"
      goto while_break___0;
    }
# 250 "file.c"
    if ((unsigned long )oldfile->hname == (unsigned long )name) {
# 251 "file.c"
      goto while_break___0;
    } else
# 250 "file.c"
    if ((int )*(oldfile->hname) == (int )*name) {
# 250 "file.c"
      if ((int )*(oldfile->hname) == 0) {
# 251 "file.c"
        goto while_break___0;
      } else {
        {
# 250 "file.c"
        tmp = strcmp((char const *)(oldfile->hname + 1), (char const *)(name + 1));
        }
# 250 "file.c"
        if (! tmp) {
# 251 "file.c"
          goto while_break___0;
        }
      }
    }
# 249 "file.c"
    oldfile = oldfile->next;
  }
  while_break___0: ;
  }
# 254 "file.c"
  if ((unsigned long )oldfile == (unsigned long )file) {
# 255 "file.c"
    return;
  }
# 257 "file.c"
  if (oldhash != 0U) {
# 257 "file.c"
    if (newbucket != oldbucket) {
# 257 "file.c"
      goto _L;
    } else
# 257 "file.c"
    if ((unsigned long )oldfile != (unsigned long )((struct file *)0)) {
      _L:
# 261 "file.c"
      lastf = (struct file *)0;
# 263 "file.c"
      f = files[oldbucket];
      {
# 263 "file.c"
      while (1) {
        while_continue___1: ;
# 263 "file.c"
        if (! ((unsigned long )f != (unsigned long )file)) {
# 263 "file.c"
          goto while_break___1;
        }
# 264 "file.c"
        lastf = f;
# 263 "file.c"
        f = f->next;
      }
      while_break___1: ;
      }
# 266 "file.c"
      if ((unsigned long )lastf == (unsigned long )((struct file *)0)) {
# 267 "file.c"
        files[oldbucket] = f->next;
      } else {
# 269 "file.c"
        lastf->next = f->next;
      }
    }
  }
# 274 "file.c"
  file->hname = name;
# 275 "file.c"
  f = file->double_colon;
  {
# 275 "file.c"
  while (1) {
    while_continue___2: ;
# 275 "file.c"
    if (! ((unsigned long )f != (unsigned long )((struct file *)0))) {
# 275 "file.c"
      goto while_break___2;
    }
# 276 "file.c"
    f->hname = name;
# 275 "file.c"
    f = f->prev;
  }
  while_break___2: ;
  }
# 278 "file.c"
  if ((unsigned long )oldfile == (unsigned long )((struct file *)0)) {
# 282 "file.c"
    if (newbucket != oldbucket) {
# 285 "file.c"
      file->next = files[newbucket];
# 286 "file.c"
      files[newbucket] = file;
    }
  } else {
# 296 "file.c"
    if ((unsigned long )file->cmds != (unsigned long )((struct commands *)0)) {
# 298 "file.c"
      if ((unsigned long )oldfile->cmds == (unsigned long )((struct commands *)0)) {
# 299 "file.c"
        oldfile->cmds = file->cmds;
      } else
# 300 "file.c"
      if ((unsigned long )file->cmds != (unsigned long )oldfile->cmds) {
# 305 "file.c"
        if ((unsigned long )(oldfile->cmds)->fileinfo.filenm != (unsigned long )((char *)0)) {
          {
# 306 "file.c"
          tmp___0 = dcgettext((char const *)((void *)0), "Commands were specified for file `%s\' at %s:%lu,",
                              5);
# 306 "file.c"
          error((struct floc const *)(& (file->cmds)->fileinfo), (char const *)tmp___0,
                oldname, (oldfile->cmds)->fileinfo.filenm, (oldfile->cmds)->fileinfo.lineno);
          }
        } else {
          {
# 312 "file.c"
          tmp___1 = dcgettext((char const *)((void *)0), "Commands for file `%s\' were found by implicit rule search,",
                              5);
# 312 "file.c"
          error((struct floc const *)(& (file->cmds)->fileinfo), (char const *)tmp___1,
                oldname);
          }
        }
        {
# 316 "file.c"
        tmp___2 = dcgettext((char const *)((void *)0), "but `%s\' is now considered the same file as `%s\'.",
                            5);
# 316 "file.c"
        error((struct floc const *)(& (file->cmds)->fileinfo), (char const *)tmp___2,
              oldname, name);
# 320 "file.c"
        tmp___3 = dcgettext((char const *)((void *)0), "Commands for `%s\' will be ignored in favor of those for `%s\'.",
                            5);
# 320 "file.c"
        error((struct floc const *)(& (file->cmds)->fileinfo), (char const *)tmp___3,
              name, oldname);
        }
      }
    }
# 329 "file.c"
    d = oldfile->deps;
# 330 "file.c"
    if ((unsigned long )d == (unsigned long )((struct dep *)0)) {
# 331 "file.c"
      oldfile->deps = file->deps;
    } else {
      {
# 334 "file.c"
      while (1) {
        while_continue___3: ;
# 334 "file.c"
        if (! ((unsigned long )d->next != (unsigned long )((struct dep *)0))) {
# 334 "file.c"
          goto while_break___3;
        }
# 335 "file.c"
        d = d->next;
      }
      while_break___3: ;
      }
# 336 "file.c"
      d->next = file->deps;
    }
    {
# 339 "file.c"
    merge_variable_set_lists(& oldfile->variables, file->variables);
    }
# 341 "file.c"
    if (oldfile->double_colon) {
# 341 "file.c"
      if (file->is_target) {
# 341 "file.c"
        if (! file->double_colon) {
          {
# 342 "file.c"
          tmp___4 = dcgettext((char const *)((void *)0), "can\'t rename single-colon `%s\' to double-colon `%s\'",
                              5);
# 342 "file.c"
          fatal((struct floc const *)((struct floc *)0), (char const *)tmp___4,
                oldname, name);
          }
        }
      }
    }
# 344 "file.c"
    if (! oldfile->double_colon) {
# 344 "file.c"
      if (file->double_colon) {
# 346 "file.c"
        if (oldfile->is_target) {
          {
# 347 "file.c"
          tmp___5 = dcgettext((char const *)((void *)0), "can\'t rename double-colon `%s\' to single-colon `%s\'",
                              5);
# 347 "file.c"
          fatal((struct floc const *)((struct floc *)0), (char const *)tmp___5,
                oldname, name);
          }
        } else {
# 350 "file.c"
          oldfile->double_colon = file->double_colon;
        }
      }
    }
# 353 "file.c"
    if (file->last_mtime > oldfile->last_mtime) {
# 355 "file.c"
      oldfile->last_mtime = file->last_mtime;
    }
# 357 "file.c"
    oldfile->mtime_before_update = file->mtime_before_update;
# 360 "file.c"
    oldfile->precious |= file->precious;
# 361 "file.c"
    oldfile->tried_implicit |= file->tried_implicit;
# 362 "file.c"
    oldfile->updating |= file->updating;
# 363 "file.c"
    oldfile->updated |= file->updated;
# 364 "file.c"
    oldfile->is_target |= file->is_target;
# 365 "file.c"
    oldfile->cmd_target |= file->cmd_target;
# 366 "file.c"
    oldfile->phony |= file->phony;
# 367 "file.c"
    oldfile->ignore_vpath |= file->ignore_vpath;
# 370 "file.c"
    file->renamed = oldfile;
  }
# 372 "file.c"
  return;
}
}
# 379 "file.c"
void remove_intermediates(int sig )
{
  register int i ;
  register struct file *f ;
  char doneany ;
  int status ;
  int *tmp ;
  char *tmp___0 ;

  {
# 387 "file.c"
  if (question_flag) {
# 388 "file.c"
    return;
  } else
# 387 "file.c"
  if (touch_flag) {
# 388 "file.c"
    return;
  }
# 389 "file.c"
  if (sig) {
# 389 "file.c"
    if (just_print_flag) {
# 390 "file.c"
      return;
    }
  }
# 392 "file.c"
  doneany = (char)0;
# 393 "file.c"
  i = 0;
  {
# 393 "file.c"
  while (1) {
    while_continue: ;
# 393 "file.c"
    if (! (i < 1007)) {
# 393 "file.c"
      goto while_break;
    }
# 394 "file.c"
    f = files[i];
    {
# 394 "file.c"
    while (1) {
      while_continue___0: ;
# 394 "file.c"
      if (! ((unsigned long )f != (unsigned long )((struct file *)0))) {
# 394 "file.c"
        goto while_break___0;
      }
# 395 "file.c"
      if (f->intermediate) {
# 395 "file.c"
        if (f->dontcare) {
# 395 "file.c"
          goto _L;
        } else
# 395 "file.c"
        if (! f->precious) {
          _L:
# 395 "file.c"
          if (! f->secondary) {
# 395 "file.c"
            if (! f->cmd_target) {
# 399 "file.c"
              if ((int )f->update_status == -1) {
# 402 "file.c"
                goto __Cont;
              } else
# 403 "file.c"
              if (just_print_flag) {
# 404 "file.c"
                status = 0;
              } else {
                {
# 407 "file.c"
                status = unlink((char const *)f->name);
                }
# 408 "file.c"
                if (status < 0) {
                  {
# 408 "file.c"
                  tmp = __errno_location();
                  }
# 408 "file.c"
                  if (*tmp == 2) {
# 409 "file.c"
                    goto __Cont;
                  }
                }
              }
# 411 "file.c"
              if (! f->dontcare) {
# 413 "file.c"
                if (sig) {
                  {
# 414 "file.c"
                  tmp___0 = dcgettext((char const *)((void *)0), "*** Deleting intermediate file `%s\'",
                                      5);
# 414 "file.c"
                  error((struct floc const *)((struct floc *)0), (char const *)tmp___0,
                        f->name);
                  }
                } else
# 415 "file.c"
                if (! silent_flag) {
# 417 "file.c"
                  if (! doneany) {
                    {
# 419 "file.c"
                    fputs((char const * __restrict )"rm ", (FILE * __restrict )stdout);
# 420 "file.c"
                    doneany = (char)1;
                    }
                  } else {
                    {
# 423 "file.c"
                    putchar(' ');
                    }
                  }
                  {
# 424 "file.c"
                  fputs((char const * __restrict )f->name, (FILE * __restrict )stdout);
# 425 "file.c"
                  fflush(stdout);
                  }
                }
# 427 "file.c"
                if (status < 0) {
                  {
# 428 "file.c"
                  perror_with_name((char *)"unlink: ", f->name);
                  }
                }
              }
            }
          }
        }
      }
      __Cont:
# 394 "file.c"
      f = f->next;
    }
    while_break___0: ;
    }
# 393 "file.c"
    i ++;
  }
  while_break: ;
  }
# 432 "file.c"
  if (doneany) {
# 432 "file.c"
    if (! sig) {
      {
# 434 "file.c"
      putchar('\n');
# 435 "file.c"
      fflush(stdout);
      }
    }
  }
# 437 "file.c"
  return;
}
}
# 445 "file.c"
void snap_deps(void)
{
  register struct file *f ;
  register struct file *f2 ;
  register struct dep *d ;
  register int i ;
  unsigned int tmp ;
  int i___0 ;
  unsigned int tmp___0 ;

  {
# 453 "file.c"
  i = 0;
  {
# 453 "file.c"
  while (1) {
    while_continue: ;
# 453 "file.c"
    if (! (i < 1007)) {
# 453 "file.c"
      goto while_break;
    }
# 454 "file.c"
    f = files[i];
    {
# 454 "file.c"
    while (1) {
      while_continue___0: ;
# 454 "file.c"
      if (! ((unsigned long )f != (unsigned long )((struct file *)0))) {
# 454 "file.c"
        goto while_break___0;
      }
# 455 "file.c"
      f2 = f;
      {
# 455 "file.c"
      while (1) {
        while_continue___1: ;
# 455 "file.c"
        if (! ((unsigned long )f2 != (unsigned long )((struct file *)0))) {
# 455 "file.c"
          goto while_break___1;
        }
# 456 "file.c"
        d = f2->deps;
        {
# 456 "file.c"
        while (1) {
          while_continue___2: ;
# 456 "file.c"
          if (! ((unsigned long )d != (unsigned long )((struct dep *)0))) {
# 456 "file.c"
            goto while_break___2;
          }
# 457 "file.c"
          if ((unsigned long )d->name != (unsigned long )((char *)0)) {
            {
# 459 "file.c"
            d->file = lookup_file(d->name);
            }
# 460 "file.c"
            if ((unsigned long )d->file == (unsigned long )((struct file *)0)) {
              {
# 461 "file.c"
              d->file = enter_file(d->name);
              }
            } else {
              {
# 463 "file.c"
              free((void *)d->name);
              }
            }
# 464 "file.c"
            d->name = (char *)0;
          }
# 456 "file.c"
          d = d->next;
        }
        while_break___2: ;
        }
# 455 "file.c"
        f2 = f2->prev;
      }
      while_break___1: ;
      }
# 454 "file.c"
      f = f->next;
    }
    while_break___0: ;
    }
# 453 "file.c"
    i ++;
  }
  while_break: ;
  }
  {
# 467 "file.c"
  f = lookup_file((char *)".PRECIOUS");
  }
  {
# 467 "file.c"
  while (1) {
    while_continue___3: ;
# 467 "file.c"
    if (! ((unsigned long )f != (unsigned long )((struct file *)0))) {
# 467 "file.c"
      goto while_break___3;
    }
# 468 "file.c"
    d = f->deps;
    {
# 468 "file.c"
    while (1) {
      while_continue___4: ;
# 468 "file.c"
      if (! ((unsigned long )d != (unsigned long )((struct dep *)0))) {
# 468 "file.c"
        goto while_break___4;
      }
# 469 "file.c"
      f2 = d->file;
      {
# 469 "file.c"
      while (1) {
        while_continue___5: ;
# 469 "file.c"
        if (! ((unsigned long )f2 != (unsigned long )((struct file *)0))) {
# 469 "file.c"
          goto while_break___5;
        }
# 470 "file.c"
        f2->precious = 1U;
# 469 "file.c"
        f2 = f2->prev;
      }
      while_break___5: ;
      }
# 468 "file.c"
      d = d->next;
    }
    while_break___4: ;
    }
# 467 "file.c"
    f = f->prev;
  }
  while_break___3: ;
  }
  {
# 472 "file.c"
  f = lookup_file((char *)".PHONY");
  }
  {
# 472 "file.c"
  while (1) {
    while_continue___6: ;
# 472 "file.c"
    if (! ((unsigned long )f != (unsigned long )((struct file *)0))) {
# 472 "file.c"
      goto while_break___6;
    }
# 473 "file.c"
    d = f->deps;
    {
# 473 "file.c"
    while (1) {
      while_continue___7: ;
# 473 "file.c"
      if (! ((unsigned long )d != (unsigned long )((struct dep *)0))) {
# 473 "file.c"
        goto while_break___7;
      }
# 474 "file.c"
      f2 = d->file;
      {
# 474 "file.c"
      while (1) {
        while_continue___8: ;
# 474 "file.c"
        if (! ((unsigned long )f2 != (unsigned long )((struct file *)0))) {
# 474 "file.c"
          goto while_break___8;
        }
# 477 "file.c"
        f2->phony = 1U;
# 478 "file.c"
        f2->last_mtime = (uintmax_t )-1;
# 479 "file.c"
        f2->mtime_before_update = (uintmax_t )-1;
# 474 "file.c"
        f2 = f2->prev;
      }
      while_break___8: ;
      }
# 473 "file.c"
      d = d->next;
    }
    while_break___7: ;
    }
# 472 "file.c"
    f = f->prev;
  }
  while_break___6: ;
  }
  {
# 482 "file.c"
  f = lookup_file((char *)".INTERMEDIATE");
  }
  {
# 482 "file.c"
  while (1) {
    while_continue___9: ;
# 482 "file.c"
    if (! ((unsigned long )f != (unsigned long )((struct file *)0))) {
# 482 "file.c"
      goto while_break___9;
    }
# 486 "file.c"
    d = f->deps;
    {
# 486 "file.c"
    while (1) {
      while_continue___10: ;
# 486 "file.c"
      if (! ((unsigned long )d != (unsigned long )((struct dep *)0))) {
# 486 "file.c"
        goto while_break___10;
      }
# 487 "file.c"
      f2 = d->file;
      {
# 487 "file.c"
      while (1) {
        while_continue___11: ;
# 487 "file.c"
        if (! ((unsigned long )f2 != (unsigned long )((struct file *)0))) {
# 487 "file.c"
          goto while_break___11;
        }
# 488 "file.c"
        f2->intermediate = 1U;
# 487 "file.c"
        f2 = f2->prev;
      }
      while_break___11: ;
      }
# 486 "file.c"
      d = d->next;
    }
    while_break___10: ;
    }
# 482 "file.c"
    f = f->prev;
  }
  while_break___9: ;
  }
  {
# 494 "file.c"
  f = lookup_file((char *)".SECONDARY");
  }
  {
# 494 "file.c"
  while (1) {
    while_continue___12: ;
# 494 "file.c"
    if (! ((unsigned long )f != (unsigned long )((struct file *)0))) {
# 494 "file.c"
      goto while_break___12;
    }
# 501 "file.c"
    if (f->deps) {
# 503 "file.c"
      d = f->deps;
      {
# 503 "file.c"
      while (1) {
        while_continue___13: ;
# 503 "file.c"
        if (! ((unsigned long )d != (unsigned long )((struct dep *)0))) {
# 503 "file.c"
          goto while_break___13;
        }
# 504 "file.c"
        f2 = d->file;
        {
# 504 "file.c"
        while (1) {
          while_continue___14: ;
# 504 "file.c"
          if (! ((unsigned long )f2 != (unsigned long )((struct file *)0))) {
# 504 "file.c"
            goto while_break___14;
          }
# 505 "file.c"
          tmp = 1U;
# 505 "file.c"
          f2->secondary = tmp;
# 505 "file.c"
          f2->intermediate = tmp;
# 504 "file.c"
          f2 = f2->prev;
        }
        while_break___14: ;
        }
# 503 "file.c"
        d = d->next;
      }
      while_break___13: ;
      }
    } else {
# 511 "file.c"
      i___0 = 0;
      {
# 511 "file.c"
      while (1) {
        while_continue___15: ;
# 511 "file.c"
        if (! (i___0 < 1007)) {
# 511 "file.c"
          goto while_break___15;
        }
# 512 "file.c"
        f2 = files[i___0];
        {
# 512 "file.c"
        while (1) {
          while_continue___16: ;
# 512 "file.c"
          if (! f2) {
# 512 "file.c"
            goto while_break___16;
          }
# 513 "file.c"
          tmp___0 = 1U;
# 513 "file.c"
          f2->secondary = tmp___0;
# 513 "file.c"
          f2->intermediate = tmp___0;
# 512 "file.c"
          f2 = f2->next;
        }
        while_break___16: ;
        }
# 511 "file.c"
        i___0 ++;
      }
      while_break___15: ;
      }
    }
# 494 "file.c"
    f = f->prev;
  }
  while_break___12: ;
  }
  {
# 517 "file.c"
  f = lookup_file((char *)".EXPORT_ALL_VARIABLES");
  }
# 518 "file.c"
  if ((unsigned long )f != (unsigned long )((struct file *)0)) {
# 518 "file.c"
    if (f->is_target) {
# 519 "file.c"
      export_all_variables = 1;
    }
  }
  {
# 521 "file.c"
  f = lookup_file((char *)".IGNORE");
  }
# 522 "file.c"
  if ((unsigned long )f != (unsigned long )((struct file *)0)) {
# 522 "file.c"
    if (f->is_target) {
# 524 "file.c"
      if ((unsigned long )f->deps == (unsigned long )((struct dep *)0)) {
# 525 "file.c"
        ignore_errors_flag = 1;
      } else {
# 527 "file.c"
        d = f->deps;
        {
# 527 "file.c"
        while (1) {
          while_continue___17: ;
# 527 "file.c"
          if (! ((unsigned long )d != (unsigned long )((struct dep *)0))) {
# 527 "file.c"
            goto while_break___17;
          }
# 528 "file.c"
          f2 = d->file;
          {
# 528 "file.c"
          while (1) {
            while_continue___18: ;
# 528 "file.c"
            if (! ((unsigned long )f2 != (unsigned long )((struct file *)0))) {
# 528 "file.c"
              goto while_break___18;
            }
# 529 "file.c"
            f2->command_flags |= 4;
# 528 "file.c"
            f2 = f2->prev;
          }
          while_break___18: ;
          }
# 527 "file.c"
          d = d->next;
        }
        while_break___17: ;
        }
      }
    }
  }
  {
# 532 "file.c"
  f = lookup_file((char *)".SILENT");
  }
# 533 "file.c"
  if ((unsigned long )f != (unsigned long )((struct file *)0)) {
# 533 "file.c"
    if (f->is_target) {
# 535 "file.c"
      if ((unsigned long )f->deps == (unsigned long )((struct dep *)0)) {
# 536 "file.c"
        silent_flag = 1;
      } else {
# 538 "file.c"
        d = f->deps;
        {
# 538 "file.c"
        while (1) {
          while_continue___19: ;
# 538 "file.c"
          if (! ((unsigned long )d != (unsigned long )((struct dep *)0))) {
# 538 "file.c"
            goto while_break___19;
          }
# 539 "file.c"
          f2 = d->file;
          {
# 539 "file.c"
          while (1) {
            while_continue___20: ;
# 539 "file.c"
            if (! ((unsigned long )f2 != (unsigned long )((struct file *)0))) {
# 539 "file.c"
              goto while_break___20;
            }
# 540 "file.c"
            f2->command_flags |= 2;
# 539 "file.c"
            f2 = f2->prev;
          }
          while_break___20: ;
          }
# 538 "file.c"
          d = d->next;
        }
        while_break___19: ;
        }
      }
    }
  }
  {
# 543 "file.c"
  f = lookup_file((char *)".POSIX");
  }
# 544 "file.c"
  if ((unsigned long )f != (unsigned long )((struct file *)0)) {
# 544 "file.c"
    if (f->is_target) {
# 545 "file.c"
      posix_pedantic = 1;
    }
  }
  {
# 547 "file.c"
  f = lookup_file((char *)".NOTPARALLEL");
  }
# 548 "file.c"
  if ((unsigned long )f != (unsigned long )((struct file *)0)) {
# 548 "file.c"
    if (f->is_target) {
# 549 "file.c"
      not_parallel = 1;
    }
  }
# 550 "file.c"
  return;
}
}
# 554 "file.c"
void set_command_state(struct file *file , int state )
{
  struct dep *d ;

  {
# 561 "file.c"
  file->command_state = (enum __anonenum_command_state_55 )state;
# 563 "file.c"
  d = file->also_make;
  {
# 563 "file.c"
  while (1) {
    while_continue: ;
# 563 "file.c"
    if (! ((unsigned long )d != (unsigned long )((struct dep *)0))) {
# 563 "file.c"
      goto while_break;
    }
# 564 "file.c"
    (d->file)->command_state = (enum __anonenum_command_state_55 )state;
# 563 "file.c"
    d = d->next;
  }
  while_break: ;
  }
# 565 "file.c"
  return;
}
}
# 569 "file.c"
uintmax_t file_timestamp_now(void)
{
  struct timespec timespec ;
  uintmax_t tmp ;
  uintmax_t tmp___0 ;
  int tmp___1 ;
  time_t tmp___2 ;
  uintmax_t tmp___3 ;
  uintmax_t tmp___4 ;

  {
  {
# 574 "file.c"
  tmp___1 = clock_gettime(0, & timespec);
  }
# 574 "file.c"
  if (tmp___1 == 0) {
# 575 "file.c"
    if (1000000000UL < 0xffffffffffffffffUL / (uintmax_t )(-1L - (-1L << (sizeof(time_t ) * 8UL - 1UL)))) {
# 575 "file.c"
      tmp = (uintmax_t )1000000000;
    } else {
# 575 "file.c"
      tmp = 0xffffffffffffffffUL / (uintmax_t )(-1L - (-1L << (sizeof(time_t ) * 8UL - 1UL)));
    }
# 575 "file.c"
    if (1000000000UL < 0xffffffffffffffffUL / (uintmax_t )(-1L - (-1L << (sizeof(time_t ) * 8UL - 1UL)))) {
# 575 "file.c"
      tmp___0 = (uintmax_t )1000000000;
    } else {
# 575 "file.c"
      tmp___0 = 0xffffffffffffffffUL / (uintmax_t )(-1L - (-1L << (sizeof(time_t ) * 8UL - 1UL)));
    }
# 575 "file.c"
    return ((uintmax_t )timespec.tv_sec * tmp + ((uintmax_t )timespec.tv_nsec * tmp___0) / 1000000000UL);
  }
  {
# 577 "file.c"
  tmp___2 = time((time_t *)0);
  }
# 577 "file.c"
  if (1000000000UL < 0xffffffffffffffffUL / (uintmax_t )(-1L - (-1L << (sizeof(time_t ) * 8UL - 1UL)))) {
# 577 "file.c"
    tmp___3 = (uintmax_t )1000000000;
  } else {
# 577 "file.c"
    tmp___3 = 0xffffffffffffffffUL / (uintmax_t )(-1L - (-1L << (sizeof(time_t ) * 8UL - 1UL)));
  }
# 577 "file.c"
  if (1000000000UL < 0xffffffffffffffffUL / (uintmax_t )(-1L - (-1L << (sizeof(time_t ) * 8UL - 1UL)))) {
# 577 "file.c"
    tmp___4 = (uintmax_t )1000000000;
  } else {
# 577 "file.c"
    tmp___4 = 0xffffffffffffffffUL / (uintmax_t )(-1L - (-1L << (sizeof(time_t ) * 8UL - 1UL)));
  }
# 577 "file.c"
  return ((uintmax_t )tmp___2 * tmp___3);
}
}
# 580 "file.c"
void file_timestamp_sprintf(char *p , uintmax_t ts )
{
  time_t t ;
  uintmax_t tmp ;
  uintmax_t tmp___0 ;
  struct tm *tm ;
  struct tm *tmp___1 ;
  size_t tmp___2 ;
  uintmax_t tmp___3 ;
  uintmax_t tmp___4 ;
  uintmax_t tmp___5 ;
  uintmax_t tmp___6 ;
  uintmax_t tmp___7 ;
  size_t tmp___8 ;

  {
# 585 "file.c"
  if (1000000000UL < 0xffffffffffffffffUL / (uintmax_t )(-1L - (-1L << (sizeof(time_t ) * 8UL - 1UL)))) {
# 585 "file.c"
    tmp = (uintmax_t )1000000000;
  } else {
# 585 "file.c"
    tmp = 0xffffffffffffffffUL / (uintmax_t )(-1L - (-1L << (sizeof(time_t ) * 8UL - 1UL)));
  }
# 585 "file.c"
  if (1000000000UL < 0xffffffffffffffffUL / (uintmax_t )(-1L - (-1L << (sizeof(time_t ) * 8UL - 1UL)))) {
# 585 "file.c"
    tmp___0 = (uintmax_t )1000000000;
  } else {
# 585 "file.c"
    tmp___0 = 0xffffffffffffffffUL / (uintmax_t )(-1L - (-1L << (sizeof(time_t ) * 8UL - 1UL)));
  }
  {
# 585 "file.c"
  t = (time_t )(ts / tmp - (uintmax_t )(ts % tmp___0 < 0UL));
# 586 "file.c"
  tmp___1 = localtime((time_t const *)(& t));
# 586 "file.c"
  tm = tmp___1;
  }
# 588 "file.c"
  if (tm) {
    {
# 589 "file.c"
    sprintf((char * __restrict )p, (char const * __restrict )"%04d-%02d-%02d %02d:%02d:%02d",
            tm->tm_year + 1900, tm->tm_mon + 1, tm->tm_mday, tm->tm_hour, tm->tm_min,
            tm->tm_sec);
    }
  } else
# 592 "file.c"
  if (t < 0L) {
    {
# 593 "file.c"
    sprintf((char * __restrict )p, (char const * __restrict )"%ld", t);
    }
  } else {
    {
# 595 "file.c"
    sprintf((char * __restrict )p, (char const * __restrict )"%lu", (unsigned long )t);
    }
  }
  {
# 596 "file.c"
  tmp___2 = strlen((char const *)p);
# 596 "file.c"
  p += tmp___2;
  }
# 603 "file.c"
  if (1000000000UL < 0xffffffffffffffffUL / (uintmax_t )(-1L - (-1L << (sizeof(time_t ) * 8UL - 1UL)))) {
# 603 "file.c"
    tmp___3 = (uintmax_t )1000000000;
  } else {
# 603 "file.c"
    tmp___3 = 0xffffffffffffffffUL / (uintmax_t )(-1L - (-1L << (sizeof(time_t ) * 8UL - 1UL)));
  }
# 603 "file.c"
  if (1000000000UL < 0xffffffffffffffffUL / (uintmax_t )(-1L - (-1L << (sizeof(time_t ) * 8UL - 1UL)))) {
# 603 "file.c"
    tmp___4 = (uintmax_t )1000000000;
  } else {
# 603 "file.c"
    tmp___4 = 0xffffffffffffffffUL / (uintmax_t )(-1L - (-1L << (sizeof(time_t ) * 8UL - 1UL)));
  }
# 603 "file.c"
  if (1000000000UL < 0xffffffffffffffffUL / (uintmax_t )(-1L - (-1L << (sizeof(time_t ) * 8UL - 1UL)))) {
# 603 "file.c"
    tmp___5 = (uintmax_t )1000000000;
  } else {
# 603 "file.c"
    tmp___5 = 0xffffffffffffffffUL / (uintmax_t )(-1L - (-1L << (sizeof(time_t ) * 8UL - 1UL)));
  }
# 603 "file.c"
  if (1000000000UL < 0xffffffffffffffffUL / (uintmax_t )(-1L - (-1L << (sizeof(time_t ) * 8UL - 1UL)))) {
# 603 "file.c"
    tmp___6 = (uintmax_t )1000000000;
  } else {
# 603 "file.c"
    tmp___6 = 0xffffffffffffffffUL / (uintmax_t )(-1L - (-1L << (sizeof(time_t ) * 8UL - 1UL)));
  }
# 603 "file.c"
  if (1000000000UL < 0xffffffffffffffffUL / (uintmax_t )(-1L - (-1L << (sizeof(time_t ) * 8UL - 1UL)))) {
# 603 "file.c"
    tmp___7 = (uintmax_t )1000000000;
  } else {
# 603 "file.c"
    tmp___7 = 0xffffffffffffffffUL / (uintmax_t )(-1L - (-1L << (sizeof(time_t ) * 8UL - 1UL)));
  }
  {
# 603 "file.c"
  sprintf((char * __restrict )p, (char const * __restrict )".%09ld", (long )(((ts % tmp___3 + (uintmax_t )(ts % tmp___4 < 0UL) * tmp___5) * 1000000000UL + (tmp___6 - 1UL)) / tmp___7));
# 604 "file.c"
  tmp___8 = strlen((char const *)p);
# 604 "file.c"
  p += tmp___8 - 1UL;
  }
  {
# 605 "file.c"
  while (1) {
    while_continue: ;
# 605 "file.c"
    if (! ((int )*p == 48)) {
# 605 "file.c"
      goto while_break;
    }
# 606 "file.c"
    p --;
  }
  while_break: ;
  }
# 607 "file.c"
  p += (int )*p != 46;
# 609 "file.c"
  *p = (char )'\000';
# 610 "file.c"
  return;
}
}
# 614 "file.c"
static void print_file(struct file *f )
{
  register struct dep *d ;
  char *tmp ;
  char const *tmp___0 ;
  char *tmp___1 ;
  char *tmp___2 ;
  char *tmp___3 ;
  char *tmp___4 ;
  char *tmp___5 ;
  char *tmp___6 ;
  char *tmp___7 ;
  char *tmp___8 ;
  char *tmp___9 ;
  char *tmp___10 ;
  char *tmp___11 ;
  char *tmp___12 ;
  char *tmp___13 ;
  char *tmp___14 ;
  char buf___1[(((((((sizeof(uintmax_t ) * 8UL - 1UL) - 24UL) * 302UL) / 1000UL + 1UL) + 1UL) + 4UL) + 25UL) + 1UL] ;
  char *tmp___15 ;
  char *tmp___16 ;
  char *tmp___17 ;
  char *tmp___18 ;
  char *tmp___19 ;
  char *tmp___20 ;
  char *tmp___21 ;
  char *tmp___23 ;
  char *tmp___24 ;
  char *tmp___25 ;
  char *tmp___26 ;

  {
  {
# 620 "file.c"
  putchar('\n');
  }
# 621 "file.c"
  if (! f->is_target) {
    {
# 622 "file.c"
    tmp = dcgettext((char const *)((void *)0), "# Not a target:", 5);
# 622 "file.c"
    puts((char const *)tmp);
    }
  }
# 623 "file.c"
  if (f->double_colon) {
# 623 "file.c"
    tmp___0 = ":";
  } else {
# 623 "file.c"
    tmp___0 = "";
  }
  {
# 623 "file.c"
  printf((char const * __restrict )"%s:%s", f->name, tmp___0);
# 625 "file.c"
  d = f->deps;
  }
  {
# 625 "file.c"
  while (1) {
    while_continue: ;
# 625 "file.c"
    if (! ((unsigned long )d != (unsigned long )((struct dep *)0))) {
# 625 "file.c"
      goto while_break;
    }
# 626 "file.c"
    if ((unsigned long )d->name == (unsigned long )((char *)0)) {
# 626 "file.c"
      tmp___1 = (d->file)->name;
    } else {
# 626 "file.c"
      tmp___1 = d->name;
    }
    {
# 626 "file.c"
    printf((char const * __restrict )" %s", tmp___1);
# 625 "file.c"
    d = d->next;
    }
  }
  while_break: ;
  }
  {
# 627 "file.c"
  putchar('\n');
  }
# 629 "file.c"
  if (f->precious) {
    {
# 630 "file.c"
    tmp___2 = dcgettext((char const *)((void *)0), "#  Precious file (prerequisite of .PRECIOUS).",
                        5);
# 630 "file.c"
    puts((char const *)tmp___2);
    }
  }
# 631 "file.c"
  if (f->phony) {
    {
# 632 "file.c"
    tmp___3 = dcgettext((char const *)((void *)0), "#  Phony target (prerequisite of .PHONY).",
                        5);
# 632 "file.c"
    puts((char const *)tmp___3);
    }
  }
# 633 "file.c"
  if (f->cmd_target) {
    {
# 634 "file.c"
    tmp___4 = dcgettext((char const *)((void *)0), "#  Command-line target.", 5);
# 634 "file.c"
    puts((char const *)tmp___4);
    }
  }
# 635 "file.c"
  if (f->dontcare) {
    {
# 636 "file.c"
    tmp___5 = dcgettext((char const *)((void *)0), "#  A default or MAKEFILES makefile.",
                        5);
# 636 "file.c"
    puts((char const *)tmp___5);
    }
  }
# 637 "file.c"
  if (f->tried_implicit) {
    {
# 637 "file.c"
    tmp___6 = dcgettext((char const *)((void *)0), "#  Implicit rule search has been done.",
                        5);
# 637 "file.c"
    tmp___8 = tmp___6;
    }
  } else {
    {
# 637 "file.c"
    tmp___7 = dcgettext((char const *)((void *)0), "#  Implicit rule search has not been done.",
                        5);
# 637 "file.c"
    tmp___8 = tmp___7;
    }
  }
  {
# 637 "file.c"
  puts((char const *)tmp___8);
  }
# 640 "file.c"
  if ((unsigned long )f->stem != (unsigned long )((char *)0)) {
    {
# 641 "file.c"
    tmp___9 = dcgettext((char const *)((void *)0), "#  Implicit/static pattern stem: `%s\'\n",
                        5);
# 641 "file.c"
    printf((char const * __restrict )tmp___9, f->stem);
    }
  }
# 642 "file.c"
  if (f->intermediate) {
    {
# 643 "file.c"
    tmp___10 = dcgettext((char const *)((void *)0), "#  File is an intermediate prerequisite.",
                         5);
# 643 "file.c"
    puts((char const *)tmp___10);
    }
  }
# 644 "file.c"
  if ((unsigned long )f->also_make != (unsigned long )((struct dep *)0)) {
    {
# 646 "file.c"
    tmp___11 = dcgettext((char const *)((void *)0), "#  Also makes:", 5);
# 646 "file.c"
    fputs((char const * __restrict )tmp___11, (FILE * __restrict )stdout);
# 647 "file.c"
    d = f->also_make;
    }
    {
# 647 "file.c"
    while (1) {
      while_continue___0: ;
# 647 "file.c"
      if (! ((unsigned long )d != (unsigned long )((struct dep *)0))) {
# 647 "file.c"
        goto while_break___0;
      }
# 648 "file.c"
      if ((unsigned long )d->name == (unsigned long )((char *)0)) {
# 648 "file.c"
        tmp___12 = (d->file)->name;
      } else {
# 648 "file.c"
        tmp___12 = d->name;
      }
      {
# 648 "file.c"
      printf((char const * __restrict )" %s", tmp___12);
# 647 "file.c"
      d = d->next;
      }
    }
    while_break___0: ;
    }
    {
# 649 "file.c"
    putchar('\n');
    }
  }
# 651 "file.c"
  if (f->last_mtime == 0UL) {
    {
# 652 "file.c"
    tmp___13 = dcgettext((char const *)((void *)0), "#  Modification time never checked.",
                         5);
# 652 "file.c"
    puts((char const *)tmp___13);
    }
  } else
# 653 "file.c"
  if (f->last_mtime == 0xffffffffffffffffUL) {
    {
# 654 "file.c"
    tmp___14 = dcgettext((char const *)((void *)0), "#  File does not exist.", 5);
# 654 "file.c"
    puts((char const *)tmp___14);
    }
  } else {
    {
# 658 "file.c"
    file_timestamp_sprintf(buf___1, f->last_mtime);
# 659 "file.c"
    tmp___15 = dcgettext((char const *)((void *)0), "#  Last modified %s\n", 5);
# 659 "file.c"
    printf((char const * __restrict )tmp___15, buf___1);
    }
  }
# 661 "file.c"
  if (f->updated) {
    {
# 661 "file.c"
    tmp___16 = dcgettext((char const *)((void *)0), "#  File has been updated.",
                         5);
# 661 "file.c"
    tmp___18 = tmp___16;
    }
  } else {
    {
# 661 "file.c"
    tmp___17 = dcgettext((char const *)((void *)0), "#  File has not been updated.",
                         5);
# 661 "file.c"
    tmp___18 = tmp___17;
    }
  }
  {
# 661 "file.c"
  puts((char const *)tmp___18);
  }
  {
# 664 "file.c"
  if ((unsigned int )f->command_state == 2U) {
# 664 "file.c"
    goto case_2;
  }
# 668 "file.c"
  if ((unsigned int )f->command_state == 1U) {
# 668 "file.c"
    goto case_1;
  }
# 672 "file.c"
  if ((unsigned int )f->command_state == 0U) {
# 672 "file.c"
    goto case_0;
  }
# 672 "file.c"
  if ((unsigned int )f->command_state == 3U) {
# 672 "file.c"
    goto case_0;
  }
# 694 "file.c"
  goto switch_default___0;
  case_2:
  {
# 666 "file.c"
  tmp___19 = dcgettext((char const *)((void *)0), "#  Commands currently running (THIS IS A BUG).",
                       5);
# 666 "file.c"
  puts((char const *)tmp___19);
  }
# 667 "file.c"
  goto switch_break;
  case_1:
  {
# 669 "file.c"
  tmp___20 = dcgettext((char const *)((void *)0), "#  Dependencies commands running (THIS IS A BUG).",
                       5);
# 669 "file.c"
  puts((char const *)tmp___20);
  }
# 670 "file.c"
  goto switch_break;
  case_0:
  case_3:
  {
# 674 "file.c"
  if ((int )f->update_status == -1) {
# 674 "file.c"
    goto case_neg_1;
  }
# 677 "file.c"
  if ((int )f->update_status == 0) {
# 677 "file.c"
    goto case_0___0;
  }
# 680 "file.c"
  if ((int )f->update_status == 1) {
# 680 "file.c"
    goto case_1___0;
  }
# 684 "file.c"
  if ((int )f->update_status == 2) {
# 684 "file.c"
    goto case_2___0;
  }
# 687 "file.c"
  goto switch_default;
  case_neg_1:
# 676 "file.c"
  goto switch_break___0;
  case_0___0:
  {
# 678 "file.c"
  tmp___21 = dcgettext((char const *)((void *)0), "#  Successfully updated.", 5);
# 678 "file.c"
  puts((char const *)tmp___21);
  }
# 679 "file.c"
  goto switch_break___0;
  case_1___0:
# 681 "file.c"
  if (! question_flag) {
    {
# 681 "file.c"
    __assert_fail("question_flag", "file.c", 681U, "print_file");
    }
  }
  {
# 682 "file.c"
  tmp___23 = dcgettext((char const *)((void *)0), "#  Needs to be updated (-q is set).",
                       5);
# 682 "file.c"
  puts((char const *)tmp___23);
  }
# 683 "file.c"
  goto switch_break___0;
  case_2___0:
  {
# 685 "file.c"
  tmp___24 = dcgettext((char const *)((void *)0), "#  Failed to be updated.", 5);
# 685 "file.c"
  puts((char const *)tmp___24);
  }
# 686 "file.c"
  goto switch_break___0;
  switch_default:
  {
# 688 "file.c"
  tmp___25 = dcgettext((char const *)((void *)0), "#  Invalid value in `update_status\' member!",
                       5);
# 688 "file.c"
  puts((char const *)tmp___25);
# 689 "file.c"
  fflush(stdout);
# 690 "file.c"
  fflush(stderr);
# 691 "file.c"
  abort();
  }
  switch_break___0: ;
  }
# 693 "file.c"
  goto switch_break;
  switch_default___0:
  {
# 695 "file.c"
  tmp___26 = dcgettext((char const *)((void *)0), "#  Invalid value in `command_state\' member!",
                       5);
# 695 "file.c"
  puts((char const *)tmp___26);
# 696 "file.c"
  fflush(stdout);
# 697 "file.c"
  fflush(stderr);
# 698 "file.c"
  abort();
  }
  switch_break: ;
  }
# 701 "file.c"
  if ((unsigned long )f->variables != (unsigned long )((struct variable_set_list *)0)) {
    {
# 702 "file.c"
    print_file_variables(f);
    }
  }
# 704 "file.c"
  if ((unsigned long )f->cmds != (unsigned long )((struct commands *)0)) {
    {
# 705 "file.c"
    print_commands(f->cmds);
    }
  }
# 706 "file.c"
  return;
}
}
# 708 "file.c"
void print_file_data_base(void)
{
  register unsigned int i ;
  register unsigned int nfiles ;
  register unsigned int per_bucket ;
  register struct file *file ;
  char *tmp ;
  register unsigned int this_bucket ;
  register struct file *f ;
  char *tmp___0 ;
  char *tmp___1 ;
  char *tmp___2 ;

  {
  {
# 714 "file.c"
  tmp = dcgettext((char const *)((void *)0), "\n# Files", 5);
# 714 "file.c"
  puts((char const *)tmp);
# 716 "file.c"
  nfiles = 0U;
# 716 "file.c"
  per_bucket = nfiles;
# 717 "file.c"
  i = 0U;
  }
  {
# 717 "file.c"
  while (1) {
    while_continue: ;
# 717 "file.c"
    if (! (i < 1007U)) {
# 717 "file.c"
      goto while_break;
    }
# 719 "file.c"
    this_bucket = 0U;
# 721 "file.c"
    file = files[i];
    {
# 721 "file.c"
    while (1) {
      while_continue___0: ;
# 721 "file.c"
      if (! ((unsigned long )file != (unsigned long )((struct file *)0))) {
# 721 "file.c"
        goto while_break___0;
      }
# 725 "file.c"
      this_bucket ++;
# 727 "file.c"
      f = file;
      {
# 727 "file.c"
      while (1) {
        while_continue___1: ;
# 727 "file.c"
        if (! ((unsigned long )f != (unsigned long )((struct file *)0))) {
# 727 "file.c"
          goto while_break___1;
        }
        {
# 728 "file.c"
        print_file(f);
# 727 "file.c"
        f = f->prev;
        }
      }
      while_break___1: ;
      }
# 721 "file.c"
      file = file->next;
    }
    while_break___0: ;
    }
# 731 "file.c"
    nfiles += this_bucket;
# 732 "file.c"
    if (this_bucket > per_bucket) {
# 733 "file.c"
      per_bucket = this_bucket;
    }
# 717 "file.c"
    i ++;
  }
  while_break: ;
  }
# 736 "file.c"
  if (nfiles == 0U) {
    {
# 737 "file.c"
    tmp___0 = dcgettext((char const *)((void *)0), "\n# No files.", 5);
# 737 "file.c"
    puts((char const *)tmp___0);
    }
  } else {
    {
# 740 "file.c"
    tmp___1 = dcgettext((char const *)((void *)0), "\n# %u files in %u hash buckets.\n",
                        5);
# 740 "file.c"
    printf((char const * __restrict )tmp___1, nfiles, 1007);
# 742 "file.c"
    tmp___2 = dcgettext((char const *)((void *)0), "# average %.3f files per bucket, max %u files in one bucket.\n",
                        5);
# 742 "file.c"
    printf((char const * __restrict )tmp___2, (double )nfiles / (double )1007,
           per_bucket);
    }
  }
# 746 "file.c"
  return;
}
}
# 1 "function.o"
#pragma merger("0","/tmp/cil-xaw3DgWu.i","-g,-O0")
# 144 "/usr/include/stdio.h"
extern __attribute__((__nothrow__)) int ( __attribute__((__leaf__)) remove)(char const *__filename ) ;
# 420 "/usr/include/unistd.h"
extern __attribute__((__nothrow__)) int ( __attribute__((__leaf__)) pipe)(int *__pipedes ) ;
# 767 "/usr/include/unistd.h"
extern __attribute__((__nothrow__)) __pid_t ( __attribute__((__leaf__)) vfork)(void) ;
# 398 "make.h"
char *find_next_token(char **ptr , unsigned int *lengthptr ) ;
# 399 "make.h"
char *next_token(char *s ) ;
# 400 "make.h"
char *end_of_token(char *s ) ;
# 468 "make.h"
extern char **environ ;
# 91 "variable.h"
int pattern_matches(char *pattern , char *percent , char *str ) ;
# 102 "variable.h"
struct variable_set_list *push_new_variable_scope(void) ;
# 103 "variable.h"
void pop_variable_scope(void) ;
# 54 "dep.h"
struct nameseq *multi_glob(struct nameseq *chain , unsigned int size ) ;
# 58 "dep.h"
struct nameseq *parse_file_seq(char **stringp , int stopchar , unsigned int size ,
                               int strip ) ;
# 57 "job.h"
char **construct_command_argv(char *line , char **restp , struct file *file , char **batch_filename_ptr ) ;
# 61 "job.h"
void child_execute_job(int stdin_fd , int stdout_fd , char **argv , char **envp ) ;
# 30 "debug.h"
int db_level ;
# 51 "function.c"
char *subst_expand(char *o , char *text , char *subst , char *replace , unsigned int slen ,
                   unsigned int rlen , int by_word , int suffix_only )
{
  register char *t ;
  register char *p ;
  size_t tmp ;
  char *tmp___0 ;
  size_t tmp___1 ;
  unsigned short const **tmp___2 ;
  unsigned short const **tmp___3 ;
  unsigned short const **tmp___4 ;

  {
# 59 "function.c"
  t = text;
# 62 "function.c"
  if (slen == 0U) {
# 62 "function.c"
    if (! by_word) {
# 62 "function.c"
      if (! suffix_only) {
        {
# 65 "function.c"
        tmp = strlen((char const *)t);
# 65 "function.c"
        o = variable_buffer_output(o, t, (unsigned int )tmp);
        }
# 66 "function.c"
        if (rlen > 0U) {
          {
# 67 "function.c"
          o = variable_buffer_output(o, replace, rlen);
          }
        }
# 68 "function.c"
        return (o);
      }
    }
  }
  {
# 71 "function.c"
  while (1) {
    while_continue: ;
# 73 "function.c"
    if (by_word | suffix_only) {
# 73 "function.c"
      if (slen == 0U) {
        {
# 76 "function.c"
        tmp___0 = next_token(t);
# 76 "function.c"
        p = end_of_token(tmp___0);
        }
      } else {
# 73 "function.c"
        goto _L;
      }
    } else {
      _L:
      {
# 79 "function.c"
      p = sindex((char const *)t, 0U, (char const *)subst, slen);
      }
# 80 "function.c"
      if ((unsigned long )p == (unsigned long )((char *)0)) {
        {
# 83 "function.c"
        tmp___1 = strlen((char const *)t);
# 83 "function.c"
        o = variable_buffer_output(o, t, (unsigned int )tmp___1);
        }
# 84 "function.c"
        return (o);
      }
    }
# 89 "function.c"
    if ((unsigned long )p > (unsigned long )t) {
      {
# 90 "function.c"
      o = variable_buffer_output(o, t, (unsigned int )(p - t));
      }
    }
# 94 "function.c"
    if (by_word) {
# 94 "function.c"
      if ((unsigned long )p > (unsigned long )t) {
        {
# 94 "function.c"
        tmp___2 = __ctype_b_loc();
        }
# 94 "function.c"
        if ((int const )*(*tmp___2 + (int )*(p + -1)) & 1) {
# 94 "function.c"
          goto _L___2;
        } else {
          {
# 101 "function.c"
          o = variable_buffer_output(o, subst, slen);
          }
        }
      } else
      _L___2:
# 94 "function.c"
      if ((int )*(p + slen) != 0) {
        {
# 94 "function.c"
        tmp___3 = __ctype_b_loc();
        }
# 94 "function.c"
        if ((int const )*(*tmp___3 + (int )*(p + slen)) & 1) {
# 94 "function.c"
          goto _L___1;
        } else {
          {
# 101 "function.c"
          o = variable_buffer_output(o, subst, slen);
          }
        }
      } else {
# 94 "function.c"
        goto _L___1;
      }
    } else
    _L___1:
# 94 "function.c"
    if (suffix_only) {
# 94 "function.c"
      if ((int )*(p + slen) != 0) {
        {
# 94 "function.c"
        tmp___4 = __ctype_b_loc();
        }
# 94 "function.c"
        if ((int const )*(*tmp___4 + (int )*(p + slen)) & 1) {
# 94 "function.c"
          goto _L___0;
        } else {
          {
# 101 "function.c"
          o = variable_buffer_output(o, subst, slen);
          }
        }
      } else {
# 94 "function.c"
        goto _L___0;
      }
    } else
    _L___0:
# 102 "function.c"
    if (rlen > 0U) {
      {
# 104 "function.c"
      o = variable_buffer_output(o, replace, rlen);
      }
    }
# 107 "function.c"
    t = p + slen;
# 71 "function.c"
    if (! ((int )*t != 0)) {
# 71 "function.c"
      goto while_break;
    }
  }
  while_break: ;
  }
# 110 "function.c"
  return (o);
}
}
# 121 "function.c"
char *patsubst_expand(char *o , char *text , char *pattern , char *replace , char *pattern_percent ,
                      char *replace_percent )
{
  unsigned int pattern_prepercent_len ;
  unsigned int pattern_postpercent_len ;
  unsigned int replace_prepercent_len ;
  unsigned int replace_postpercent_len ;
  char *t ;
  int len ;
  int doneany ;
  size_t tmp ;
  size_t tmp___0 ;
  size_t tmp___1 ;
  size_t tmp___2 ;
  char *tmp___3 ;
  size_t tmp___4 ;
  int fail ;
  int tmp___5 ;
  int tmp___6 ;

  {
# 129 "function.c"
  replace_postpercent_len = 0U;
# 132 "function.c"
  doneany = 0;
# 136 "function.c"
  if ((unsigned long )replace_percent == (unsigned long )((char *)0)) {
    {
# 137 "function.c"
    replace_percent = find_percent(replace);
    }
  }
# 138 "function.c"
  if ((unsigned long )replace_percent != (unsigned long )((char *)0)) {
    {
# 142 "function.c"
    replace_prepercent_len = (unsigned int )(replace_percent - replace);
# 143 "function.c"
    tmp = strlen((char const *)(replace_percent + 1));
# 143 "function.c"
    replace_postpercent_len = (unsigned int )tmp;
    }
  } else {
    {
# 148 "function.c"
    tmp___0 = strlen((char const *)replace);
# 148 "function.c"
    replace_prepercent_len = (unsigned int )tmp___0;
    }
  }
# 150 "function.c"
  if ((unsigned long )pattern_percent == (unsigned long )((char *)0)) {
    {
# 151 "function.c"
    pattern_percent = find_percent(pattern);
    }
  }
# 152 "function.c"
  if ((unsigned long )pattern_percent == (unsigned long )((char *)0)) {
    {
# 154 "function.c"
    tmp___1 = strlen((char const *)replace);
# 154 "function.c"
    tmp___2 = strlen((char const *)pattern);
# 154 "function.c"
    tmp___3 = subst_expand(o, text, pattern, replace, (unsigned int )tmp___2, (unsigned int )tmp___1,
                           1, 0);
    }
# 154 "function.c"
    return (tmp___3);
  }
  {
# 159 "function.c"
  pattern_prepercent_len = (unsigned int )(pattern_percent - pattern);
# 160 "function.c"
  tmp___4 = strlen((char const *)(pattern_percent + 1));
# 160 "function.c"
  pattern_postpercent_len = (unsigned int )tmp___4;
  }
  {
# 162 "function.c"
  while (1) {
    while_continue: ;
    {
# 162 "function.c"
    t = find_next_token(& text, (unsigned int *)(& len));
    }
# 162 "function.c"
    if (! ((unsigned long )t != (unsigned long )((char *)0))) {
# 162 "function.c"
      goto while_break;
    }
# 164 "function.c"
    fail = 0;
# 167 "function.c"
    if ((unsigned int )len < pattern_prepercent_len + pattern_postpercent_len) {
# 168 "function.c"
      fail = 1;
    }
# 171 "function.c"
    if (! fail) {
# 171 "function.c"
      if (pattern_prepercent_len > 0U) {
# 171 "function.c"
        if ((int )*t != (int )*pattern) {
# 175 "function.c"
          fail = 1;
        } else
# 171 "function.c"
        if ((int )*(t + (pattern_prepercent_len - 1U)) != (int )*(pattern_percent + -1)) {
# 175 "function.c"
          fail = 1;
        } else {
          {
# 171 "function.c"
          tmp___5 = strncmp((char const *)(t + 1), (char const *)(pattern + 1),
                            (size_t )(pattern_prepercent_len - 1U));
          }
# 171 "function.c"
          if (! (tmp___5 == 0)) {
# 175 "function.c"
            fail = 1;
          }
        }
      }
    }
# 178 "function.c"
    if (! fail) {
# 178 "function.c"
      if (pattern_postpercent_len > 0U) {
# 178 "function.c"
        if ((int )*(t + (len - 1)) != (int )*(pattern_percent + pattern_postpercent_len)) {
# 183 "function.c"
          fail = 1;
        } else
# 178 "function.c"
        if ((int )*(t + ((unsigned int )len - pattern_postpercent_len)) != (int )*(pattern_percent + 1)) {
# 183 "function.c"
          fail = 1;
        } else {
          {
# 178 "function.c"
          tmp___6 = strncmp((char const *)(t + ((unsigned int )len - pattern_postpercent_len)),
                            (char const *)(pattern_percent + 1), (size_t )(pattern_postpercent_len - 1U));
          }
# 178 "function.c"
          if (! (tmp___6 == 0)) {
# 183 "function.c"
            fail = 1;
          }
        }
      }
    }
# 185 "function.c"
    if (fail) {
      {
# 187 "function.c"
      o = variable_buffer_output(o, t, (unsigned int )len);
      }
    } else {
      {
# 193 "function.c"
      o = variable_buffer_output(o, replace, replace_prepercent_len);
      }
# 195 "function.c"
      if ((unsigned long )replace_percent != (unsigned long )((char *)0)) {
        {
# 199 "function.c"
        o = variable_buffer_output(o, t + pattern_prepercent_len, (unsigned int )len - (pattern_prepercent_len + pattern_postpercent_len));
# 203 "function.c"
        o = variable_buffer_output(o, replace_percent + 1, replace_postpercent_len);
        }
      }
    }
# 209 "function.c"
    if (fail) {
      {
# 212 "function.c"
      o = variable_buffer_output(o, (char *)" ", 1U);
# 213 "function.c"
      doneany = 1;
      }
    } else
# 209 "function.c"
    if (replace_prepercent_len > 0U) {
      {
# 212 "function.c"
      o = variable_buffer_output(o, (char *)" ", 1U);
# 213 "function.c"
      doneany = 1;
      }
    } else
# 209 "function.c"
    if ((unsigned long )replace_percent != (unsigned long )((char *)0)) {
# 209 "function.c"
      if ((unsigned int )len + replace_postpercent_len > 0U) {
        {
# 212 "function.c"
        o = variable_buffer_output(o, (char *)" ", 1U);
# 213 "function.c"
        doneany = 1;
        }
      }
    }
  }
  while_break: ;
  }
# 216 "function.c"
  if (doneany) {
# 218 "function.c"
    o --;
  }
# 220 "function.c"
  return (o);
}
}
# 229 "function.c"
static struct function_table_entry const *lookup_function(struct function_table_entry const *table ,
                                                            char const *s )
{
  int len ;
  size_t tmp ;
  unsigned short const **tmp___0 ;
  int tmp___1 ;

  {
  {
# 234 "function.c"
  tmp = strlen(s);
# 234 "function.c"
  len = (int )tmp;
  }
  {
# 236 "function.c"
  while (1) {
    while_continue: ;
# 236 "function.c"
    if (! ((unsigned long )table->name != (unsigned long )((void *)0))) {
# 236 "function.c"
      goto while_break;
    }
# 237 "function.c"
    if ((int const )table->len <= (int const )len) {
      {
# 237 "function.c"
      tmp___0 = __ctype_b_loc();
      }
# 237 "function.c"
      if ((int const )*(*tmp___0 + (int )*(s + (int const )table->len)) & 1) {
# 237 "function.c"
        goto _L;
      } else
# 237 "function.c"
      if ((int const )*(s + (int const )table->len) == 0) {
        _L:
        {
# 237 "function.c"
        tmp___1 = strncmp(s, (char const *)table->name, (size_t )table->len);
        }
# 237 "function.c"
        if (tmp___1 == 0) {
# 240 "function.c"
          return (table);
        }
      }
    }
# 236 "function.c"
    table ++;
  }
  while_break: ;
  }
# 242 "function.c"
  return ((struct function_table_entry const *)((void *)0));
}
}
# 248 "function.c"
int pattern_matches(char *pattern , char *percent , char *str )
{
  unsigned int sfxlen ;
  unsigned int strlength ;
  unsigned int len ;
  size_t tmp ;
  char *new_chars ;
  void *tmp___0 ;
  int tmp___1 ;
  int tmp___2 ;
  size_t tmp___3 ;
  size_t tmp___4 ;
  int tmp___5 ;
  int tmp___6 ;
  int tmp___7 ;

  {
# 254 "function.c"
  if ((unsigned long )percent == (unsigned long )((char *)0)) {
    {
# 256 "function.c"
    tmp = strlen((char const *)pattern);
# 256 "function.c"
    len = (unsigned int )(tmp + 1UL);
# 257 "function.c"
    tmp___0 = __builtin_alloca((unsigned long )len);
# 257 "function.c"
    new_chars = (char *)tmp___0;
# 258 "function.c"
    memmove((void *)new_chars, (void const *)pattern, (size_t )len);
# 259 "function.c"
    pattern = new_chars;
# 260 "function.c"
    percent = find_percent(pattern);
    }
# 261 "function.c"
    if ((unsigned long )percent == (unsigned long )((char *)0)) {
# 262 "function.c"
      if ((unsigned long )pattern == (unsigned long )str) {
# 262 "function.c"
        tmp___2 = 1;
      } else
# 262 "function.c"
      if ((int )*pattern == (int )*str) {
# 262 "function.c"
        if ((int )*pattern == 0) {
# 262 "function.c"
          tmp___2 = 1;
        } else {
          {
# 262 "function.c"
          tmp___1 = strcmp((char const *)(pattern + 1), (char const *)(str + 1));
          }
# 262 "function.c"
          if (tmp___1) {
# 262 "function.c"
            tmp___2 = 0;
          } else {
# 262 "function.c"
            tmp___2 = 1;
          }
        }
      } else {
# 262 "function.c"
        tmp___2 = 0;
      }
# 262 "function.c"
      return (tmp___2);
    }
  }
  {
# 265 "function.c"
  tmp___3 = strlen((char const *)(percent + 1));
# 265 "function.c"
  sfxlen = (unsigned int )tmp___3;
# 266 "function.c"
  tmp___4 = strlen((char const *)str);
# 266 "function.c"
  strlength = (unsigned int )tmp___4;
  }
# 268 "function.c"
  if ((long )strlength < (percent - pattern) + (long )sfxlen) {
# 270 "function.c"
    return (0);
  } else {
    {
# 268 "function.c"
    tmp___5 = strncmp((char const *)pattern, (char const *)str, (size_t )(percent - pattern));
    }
# 268 "function.c"
    if (! (tmp___5 == 0)) {
# 270 "function.c"
      return (0);
    }
  }
  {
# 272 "function.c"
  tmp___6 = strcmp((char const *)(percent + 1), (char const *)(str + (strlength - sfxlen)));
  }
# 272 "function.c"
  if (tmp___6) {
# 272 "function.c"
    tmp___7 = 0;
  } else {
# 272 "function.c"
    tmp___7 = 1;
  }
# 272 "function.c"
  return (tmp___7);
}
}
# 283 "function.c"
static char *find_next_argument(char startparen , char endparen , char const *ptr ,
                                char const *end )
{
  int count ;

  {
# 290 "function.c"
  count = 0;
  {
# 292 "function.c"
  while (1) {
    while_continue: ;
# 292 "function.c"
    if (! ((unsigned long )ptr < (unsigned long )end)) {
# 292 "function.c"
      goto while_break;
    }
# 293 "function.c"
    if ((int const )*ptr == (int const )startparen) {
# 294 "function.c"
      count ++;
    } else
# 296 "function.c"
    if ((int const )*ptr == (int const )endparen) {
# 298 "function.c"
      count --;
# 299 "function.c"
      if (count < 0) {
# 300 "function.c"
        return ((char *)((void *)0));
      }
    } else
# 303 "function.c"
    if ((int const )*ptr == 44) {
# 303 "function.c"
      if (! count) {
# 304 "function.c"
        return ((char *)ptr);
      }
    }
# 292 "function.c"
    ptr ++;
  }
  while_break: ;
  }
# 307 "function.c"
  return ((char *)((void *)0));
}
}
# 318 "function.c"
static char *string_glob(char *line ) ;
# 318 "function.c"
static char *result = (char *)0;
# 319 "function.c"
static unsigned int length ;
# 314 "function.c"
static char *string_glob(char *line )
{
  register struct nameseq *chain ;
  register unsigned int idx ;
  struct nameseq *tmp ;
  char *tmp___0 ;
  register char *name ;
  unsigned int len ;
  size_t tmp___1 ;
  struct nameseq *next ;
  char *tmp___2 ;
  unsigned int tmp___3 ;
  int tmp___4 ;

  {
  {
# 323 "function.c"
  tmp = parse_file_seq(& line, '\000', (unsigned int )sizeof(struct nameseq ), 0);
# 323 "function.c"
  chain = multi_glob(tmp, (unsigned int )sizeof(struct nameseq ));
  }
# 331 "function.c"
  if ((unsigned long )result == (unsigned long )((char *)0)) {
    {
# 333 "function.c"
    length = 100U;
# 334 "function.c"
    tmp___0 = xmalloc(100U);
# 334 "function.c"
    result = tmp___0;
    }
  }
# 337 "function.c"
  idx = 0U;
  {
# 338 "function.c"
  while (1) {
    while_continue: ;
# 338 "function.c"
    if (! ((unsigned long )chain != (unsigned long )((struct nameseq *)0))) {
# 338 "function.c"
      goto while_break;
    }
    {
# 340 "function.c"
    name = chain->name;
# 341 "function.c"
    tmp___1 = strlen((char const *)name);
# 341 "function.c"
    len = (unsigned int )tmp___1;
# 343 "function.c"
    next = chain->next;
# 344 "function.c"
    free((void *)((char *)chain));
# 345 "function.c"
    chain = next;
# 349 "function.c"
    tmp___4 = file_exists_p(name);
    }
# 349 "function.c"
    if (tmp___4) {
# 351 "function.c"
      if ((idx + len) + 1U > length) {
        {
# 353 "function.c"
        length += (len + 1U) * 2U;
# 354 "function.c"
        tmp___2 = xrealloc(result, length);
# 354 "function.c"
        result = tmp___2;
        }
      }
      {
# 356 "function.c"
      memmove((void *)(result + idx), (void const *)name, (size_t )len);
# 357 "function.c"
      idx += len;
# 358 "function.c"
      tmp___3 = idx;
# 358 "function.c"
      idx ++;
# 358 "function.c"
      *(result + tmp___3) = (char )' ';
      }
    }
    {
# 361 "function.c"
    free((void *)name);
    }
  }
  while_break: ;
  }
# 365 "function.c"
  if (idx == 0U) {
# 366 "function.c"
    *(result + 0) = (char )'\000';
  } else {
# 368 "function.c"
    *(result + (idx - 1U)) = (char )'\000';
  }
# 370 "function.c"
  return (result);
}
}
# 377 "function.c"
static char *func_patsubst(char *o , char **argv , char const *funcname )
{


  {
  {
# 383 "function.c"
  o = patsubst_expand(o, *(argv + 2), *(argv + 0), *(argv + 1), (char *)0, (char *)0);
  }
# 384 "function.c"
  return (o);
}
}
# 388 "function.c"
static char *func_join(char *o , char **argv , char const *funcname )
{
  int doneany ;
  register char *tp ;
  register char *pp ;
  char *list1_iterator ;
  char *list2_iterator ;
  unsigned int len1 ;
  unsigned int len2 ;

  {
# 394 "function.c"
  doneany = 0;
# 402 "function.c"
  list1_iterator = *(argv + 0);
# 403 "function.c"
  list2_iterator = *(argv + 1);
  {
# 404 "function.c"
  while (1) {
    while_continue: ;
    {
# 408 "function.c"
    tp = find_next_token(& list1_iterator, & len1);
    }
# 409 "function.c"
    if ((unsigned long )tp != (unsigned long )((char *)0)) {
      {
# 410 "function.c"
      o = variable_buffer_output(o, tp, len1);
      }
    }
    {
# 412 "function.c"
    pp = find_next_token(& list2_iterator, & len2);
    }
# 413 "function.c"
    if ((unsigned long )pp != (unsigned long )((char *)0)) {
      {
# 414 "function.c"
      o = variable_buffer_output(o, pp, len2);
      }
    }
# 416 "function.c"
    if ((unsigned long )tp != (unsigned long )((char *)0)) {
      {
# 418 "function.c"
      o = variable_buffer_output(o, (char *)" ", 1U);
# 419 "function.c"
      doneany = 1;
      }
    } else
# 416 "function.c"
    if ((unsigned long )pp != (unsigned long )((char *)0)) {
      {
# 418 "function.c"
      o = variable_buffer_output(o, (char *)" ", 1U);
# 419 "function.c"
      doneany = 1;
      }
    }
# 404 "function.c"
    if (! ((unsigned long )tp != (unsigned long )((char *)0))) {
# 404 "function.c"
      if (! ((unsigned long )pp != (unsigned long )((char *)0))) {
# 404 "function.c"
        goto while_break;
      }
    }
  }
  while_break: ;
  }
# 423 "function.c"
  if (doneany) {
# 425 "function.c"
    o --;
  }
# 427 "function.c"
  return (o);
}
}
# 431 "function.c"
static char *func_origin(char *o , char **argv , char const *funcname )
{
  register struct variable *v ;
  size_t tmp ;
  struct variable *tmp___0 ;

  {
  {
# 438 "function.c"
  tmp = strlen((char const *)*(argv + 0));
# 438 "function.c"
  tmp___0 = lookup_variable(*(argv + 0), (unsigned int )tmp);
# 438 "function.c"
  v = tmp___0;
  }
# 439 "function.c"
  if ((unsigned long )v == (unsigned long )((struct variable *)0)) {
    {
# 440 "function.c"
    o = variable_buffer_output(o, (char *)"undefined", 9U);
    }
  } else {
    {
# 448 "function.c"
    if ((unsigned int )v->origin == 0U) {
# 448 "function.c"
      goto case_0;
    }
# 451 "function.c"
    if ((unsigned int )v->origin == 1U) {
# 451 "function.c"
      goto case_1;
    }
# 454 "function.c"
    if ((unsigned int )v->origin == 2U) {
# 454 "function.c"
      goto case_2;
    }
# 457 "function.c"
    if ((unsigned int )v->origin == 3U) {
# 457 "function.c"
      goto case_3;
    }
# 460 "function.c"
    if ((unsigned int )v->origin == 4U) {
# 460 "function.c"
      goto case_4;
    }
# 463 "function.c"
    if ((unsigned int )v->origin == 5U) {
# 463 "function.c"
      goto case_5;
    }
# 466 "function.c"
    if ((unsigned int )v->origin == 6U) {
# 466 "function.c"
      goto case_6;
    }
# 443 "function.c"
    goto switch_default;
    switch_default:
    {
# 446 "function.c"
    abort();
    }
# 447 "function.c"
    goto switch_break;
    case_0:
    {
# 449 "function.c"
    o = variable_buffer_output(o, (char *)"default", 7U);
    }
# 450 "function.c"
    goto switch_break;
    case_1:
    {
# 452 "function.c"
    o = variable_buffer_output(o, (char *)"environment", 11U);
    }
# 453 "function.c"
    goto switch_break;
    case_2:
    {
# 455 "function.c"
    o = variable_buffer_output(o, (char *)"file", 4U);
    }
# 456 "function.c"
    goto switch_break;
    case_3:
    {
# 458 "function.c"
    o = variable_buffer_output(o, (char *)"environment override", 20U);
    }
# 459 "function.c"
    goto switch_break;
    case_4:
    {
# 461 "function.c"
    o = variable_buffer_output(o, (char *)"command line", 12U);
    }
# 462 "function.c"
    goto switch_break;
    case_5:
    {
# 464 "function.c"
    o = variable_buffer_output(o, (char *)"override", 8U);
    }
# 465 "function.c"
    goto switch_break;
    case_6:
    {
# 467 "function.c"
    o = variable_buffer_output(o, (char *)"automatic", 9U);
    }
# 468 "function.c"
    goto switch_break;
    switch_break: ;
    }
  }
# 471 "function.c"
  return (o);
}
}
# 485 "function.c"
static char *func_notdir_suffix(char *o , char **argv , char const *funcname )
{
  char *list_iterator ;
  char *p2 ;
  int doneany ;
  unsigned int len ;
  int is_suffix ;
  int tmp ;
  int tmp___0 ;
  int is_notdir ;
  char *p ;

  {
# 492 "function.c"
  list_iterator = *(argv + 0);
# 493 "function.c"
  p2 = (char *)0;
# 494 "function.c"
  doneany = 0;
# 495 "function.c"
  len = 0U;
# 497 "function.c"
  if ((unsigned long )funcname == (unsigned long )"suffix") {
# 497 "function.c"
    tmp___0 = 1;
  } else
# 497 "function.c"
  if ((int const )*funcname == (int const )*"suffix") {
# 497 "function.c"
    if ((int const )*funcname == 0) {
# 497 "function.c"
      tmp___0 = 1;
    } else {
      {
# 497 "function.c"
      tmp = strcmp(funcname + 1, "suffix" + 1);
      }
# 497 "function.c"
      if (tmp) {
# 497 "function.c"
        tmp___0 = 0;
      } else {
# 497 "function.c"
        tmp___0 = 1;
      }
    }
  } else {
# 497 "function.c"
    tmp___0 = 0;
  }
# 497 "function.c"
  is_suffix = tmp___0;
# 498 "function.c"
  is_notdir = ! is_suffix;
  {
# 499 "function.c"
  while (1) {
    while_continue: ;
    {
# 499 "function.c"
    p2 = find_next_token(& list_iterator, & len);
    }
# 499 "function.c"
    if (! ((unsigned long )p2 != (unsigned long )((char *)0))) {
# 499 "function.c"
      goto while_break;
    }
# 501 "function.c"
    p = p2 + len;
    {
# 504 "function.c"
    while (1) {
      while_continue___0: ;
# 504 "function.c"
      if ((unsigned long )p >= (unsigned long )p2) {
# 504 "function.c"
        if (! (! is_suffix)) {
# 504 "function.c"
          if (! ((int )*p != 46)) {
# 504 "function.c"
            goto while_break___0;
          }
        }
      } else {
# 504 "function.c"
        goto while_break___0;
      }
# 506 "function.c"
      if ((int )*p == 47) {
# 507 "function.c"
        goto while_break___0;
      }
# 508 "function.c"
      p --;
    }
    while_break___0: ;
    }
# 511 "function.c"
    if ((unsigned long )p >= (unsigned long )p2) {
# 513 "function.c"
      if (is_notdir) {
# 514 "function.c"
        p ++;
      } else
# 515 "function.c"
      if ((int )*p != 46) {
# 516 "function.c"
        goto while_continue;
      }
      {
# 517 "function.c"
      o = variable_buffer_output(o, p, (unsigned int )((long )len - (p - p2)));
      }
    } else
# 527 "function.c"
    if (is_notdir) {
      {
# 528 "function.c"
      o = variable_buffer_output(o, p2, len);
      }
    }
# 530 "function.c"
    if (is_notdir) {
      {
# 532 "function.c"
      o = variable_buffer_output(o, (char *)" ", 1U);
# 533 "function.c"
      doneany = 1;
      }
    } else
# 530 "function.c"
    if ((unsigned long )p >= (unsigned long )p2) {
      {
# 532 "function.c"
      o = variable_buffer_output(o, (char *)" ", 1U);
# 533 "function.c"
      doneany = 1;
      }
    }
  }
  while_break: ;
  }
# 536 "function.c"
  if (doneany) {
# 538 "function.c"
    o --;
  }
# 541 "function.c"
  return (o);
}
}
# 546 "function.c"
static char *func_basename_dir(char *o , char **argv , char const *funcname )
{
  char *p3 ;
  char *p2 ;
  int doneany ;
  unsigned int len ;
  char *p ;
  int is_basename ;
  int tmp ;
  int tmp___0 ;
  int is_dir ;

  {
# 553 "function.c"
  p3 = *(argv + 0);
# 554 "function.c"
  p2 = (char *)0;
# 555 "function.c"
  doneany = 0;
# 556 "function.c"
  len = 0U;
# 557 "function.c"
  p = (char *)0;
# 558 "function.c"
  if ((unsigned long )funcname == (unsigned long )"basename") {
# 558 "function.c"
    tmp___0 = 1;
  } else
# 558 "function.c"
  if ((int const )*funcname == (int const )*"basename") {
# 558 "function.c"
    if ((int const )*funcname == 0) {
# 558 "function.c"
      tmp___0 = 1;
    } else {
      {
# 558 "function.c"
      tmp = strcmp(funcname + 1, "basename" + 1);
      }
# 558 "function.c"
      if (tmp) {
# 558 "function.c"
        tmp___0 = 0;
      } else {
# 558 "function.c"
        tmp___0 = 1;
      }
    }
  } else {
# 558 "function.c"
    tmp___0 = 0;
  }
# 558 "function.c"
  is_basename = tmp___0;
# 559 "function.c"
  is_dir = ! is_basename;
  {
# 561 "function.c"
  while (1) {
    while_continue: ;
    {
# 561 "function.c"
    p2 = find_next_token(& p3, & len);
    }
# 561 "function.c"
    if (! ((unsigned long )p2 != (unsigned long )((char *)0))) {
# 561 "function.c"
      goto while_break;
    }
# 563 "function.c"
    p = p2 + len;
    {
# 564 "function.c"
    while (1) {
      while_continue___0: ;
# 564 "function.c"
      if ((unsigned long )p >= (unsigned long )p2) {
# 564 "function.c"
        if (! (! is_basename)) {
# 564 "function.c"
          if (! ((int )*p != 46)) {
# 564 "function.c"
            goto while_break___0;
          }
        }
      } else {
# 564 "function.c"
        goto while_break___0;
      }
# 566 "function.c"
      if ((int )*p == 47) {
# 567 "function.c"
        goto while_break___0;
      }
# 568 "function.c"
      p --;
    }
    while_break___0: ;
    }
# 571 "function.c"
    if ((unsigned long )p >= (unsigned long )p2) {
# 571 "function.c"
      if (is_dir) {
        {
# 572 "function.c"
        p ++;
# 572 "function.c"
        o = variable_buffer_output(o, p2, (unsigned int )(p - p2));
        }
      } else {
# 571 "function.c"
        goto _L___0;
      }
    } else
    _L___0:
# 573 "function.c"
    if ((unsigned long )p >= (unsigned long )p2) {
# 573 "function.c"
      if ((int )*p == 46) {
        {
# 574 "function.c"
        o = variable_buffer_output(o, p2, (unsigned int )(p - p2));
        }
      } else {
# 573 "function.c"
        goto _L;
      }
    } else
    _L:
# 580 "function.c"
    if (is_dir) {
      {
# 585 "function.c"
      o = variable_buffer_output(o, (char *)"./", 2U);
      }
    } else {
      {
# 592 "function.c"
      o = variable_buffer_output(o, p2, len);
      }
    }
    {
# 594 "function.c"
    o = variable_buffer_output(o, (char *)" ", 1U);
# 595 "function.c"
    doneany = 1;
    }
  }
  while_break: ;
  }
# 597 "function.c"
  if (doneany) {
# 599 "function.c"
    o --;
  }
# 602 "function.c"
  return (o);
}
}
# 605 "function.c"
static char *func_addsuffix_addprefix(char *o , char **argv , char const *funcname )
{
  int fixlen ;
  size_t tmp ;
  char *list_iterator ;
  int is_addprefix ;
  int tmp___0 ;
  int tmp___1 ;
  int is_addsuffix ;
  int doneany ;
  char *p ;
  unsigned int len ;

  {
  {
# 611 "function.c"
  tmp = strlen((char const *)*(argv + 0));
# 611 "function.c"
  fixlen = (int )tmp;
# 612 "function.c"
  list_iterator = *(argv + 1);
  }
# 613 "function.c"
  if ((unsigned long )funcname == (unsigned long )"addprefix") {
# 613 "function.c"
    tmp___1 = 1;
  } else
# 613 "function.c"
  if ((int const )*funcname == (int const )*"addprefix") {
# 613 "function.c"
    if ((int const )*funcname == 0) {
# 613 "function.c"
      tmp___1 = 1;
    } else {
      {
# 613 "function.c"
      tmp___0 = strcmp(funcname + 1, "addprefix" + 1);
      }
# 613 "function.c"
      if (tmp___0) {
# 613 "function.c"
        tmp___1 = 0;
      } else {
# 613 "function.c"
        tmp___1 = 1;
      }
    }
  } else {
# 613 "function.c"
    tmp___1 = 0;
  }
# 613 "function.c"
  is_addprefix = tmp___1;
# 614 "function.c"
  is_addsuffix = ! is_addprefix;
# 616 "function.c"
  doneany = 0;
  {
# 620 "function.c"
  while (1) {
    while_continue: ;
    {
# 620 "function.c"
    p = find_next_token(& list_iterator, & len);
    }
# 620 "function.c"
    if (! ((unsigned long )p != (unsigned long )((char *)0))) {
# 620 "function.c"
      goto while_break;
    }
# 622 "function.c"
    if (is_addprefix) {
      {
# 623 "function.c"
      o = variable_buffer_output(o, *(argv + 0), (unsigned int )fixlen);
      }
    }
    {
# 624 "function.c"
    o = variable_buffer_output(o, p, len);
    }
# 625 "function.c"
    if (is_addsuffix) {
      {
# 626 "function.c"
      o = variable_buffer_output(o, *(argv + 0), (unsigned int )fixlen);
      }
    }
    {
# 627 "function.c"
    o = variable_buffer_output(o, (char *)" ", 1U);
# 628 "function.c"
    doneany = 1;
    }
  }
  while_break: ;
  }
# 631 "function.c"
  if (doneany) {
# 633 "function.c"
    o --;
  }
# 635 "function.c"
  return (o);
}
}
# 638 "function.c"
static char *func_subst(char *o , char **argv , char const *funcname )
{
  size_t tmp ;
  size_t tmp___0 ;

  {
  {
# 644 "function.c"
  tmp = strlen((char const *)*(argv + 1));
# 644 "function.c"
  tmp___0 = strlen((char const *)*(argv + 0));
# 644 "function.c"
  o = subst_expand(o, *(argv + 2), *(argv + 0), *(argv + 1), (unsigned int )tmp___0,
                   (unsigned int )tmp, 0, 0);
  }
# 647 "function.c"
  return (o);
}
}
# 651 "function.c"
static char *func_firstword(char *o , char **argv , char const *funcname )
{
  unsigned int i ;
  char *words ;
  char *p ;
  char *tmp ;

  {
  {
# 658 "function.c"
  words = *(argv + 0);
# 659 "function.c"
  tmp = find_next_token(& words, & i);
# 659 "function.c"
  p = tmp;
  }
# 661 "function.c"
  if ((unsigned long )p != (unsigned long )((char *)0)) {
    {
# 662 "function.c"
    o = variable_buffer_output(o, p, i);
    }
  }
# 664 "function.c"
  return (o);
}
}
# 668 "function.c"
static char *func_words(char *o , char **argv , char const *funcname )
{
  int i ;
  char *word_iterator ;
  char buf___1[20] ;
  char *tmp ;
  size_t tmp___0 ;

  {
# 674 "function.c"
  i = 0;
# 675 "function.c"
  word_iterator = *(argv + 0);
  {
# 678 "function.c"
  while (1) {
    while_continue: ;
    {
# 678 "function.c"
    tmp = find_next_token(& word_iterator, (unsigned int *)0);
    }
# 678 "function.c"
    if (! ((unsigned long )tmp != (unsigned long )((char *)0))) {
# 678 "function.c"
      goto while_break;
    }
# 679 "function.c"
    i ++;
  }
  while_break: ;
  }
  {
# 681 "function.c"
  sprintf((char * __restrict )(buf___1), (char const * __restrict )"%d", i);
# 682 "function.c"
  tmp___0 = strlen((char const *)(buf___1));
# 682 "function.c"
  o = variable_buffer_output(o, buf___1, (unsigned int )tmp___0);
  }
# 685 "function.c"
  return (o);
}
}
# 688 "function.c"
char *strip_whitespace(char **begpp , char **endpp )
{
  unsigned short const **tmp ;
  unsigned short const **tmp___0 ;

  {
  {
# 693 "function.c"
  while (1) {
    while_continue: ;
    {
# 693 "function.c"
    tmp = __ctype_b_loc();
    }
# 693 "function.c"
    if ((int const )*(*tmp + (int )((unsigned char )*(*begpp))) & 8192) {
# 693 "function.c"
      if (! ((unsigned long )*begpp <= (unsigned long )*endpp)) {
# 693 "function.c"
        goto while_break;
      }
    } else {
# 693 "function.c"
      goto while_break;
    }
# 694 "function.c"
    (*begpp) ++;
  }
  while_break: ;
  }
  {
# 695 "function.c"
  while (1) {
    while_continue___0: ;
    {
# 695 "function.c"
    tmp___0 = __ctype_b_loc();
    }
# 695 "function.c"
    if ((int const )*(*tmp___0 + (int )((unsigned char )*(*endpp))) & 8192) {
# 695 "function.c"
      if (! ((unsigned long )*endpp >= (unsigned long )*begpp)) {
# 695 "function.c"
        goto while_break___0;
      }
    } else {
# 695 "function.c"
      goto while_break___0;
    }
# 696 "function.c"
    (*endpp) --;
  }
  while_break___0: ;
  }
# 697 "function.c"
  return (*begpp);
}
}
# 700 "function.c"
int is_numeric(char *p )
{
  char *end ;
  size_t tmp ;
  char *beg ;
  char *tmp___0 ;

  {
  {
# 704 "function.c"
  tmp = strlen((char const *)p);
# 704 "function.c"
  end = (p + tmp) - 1;
# 705 "function.c"
  beg = p;
# 706 "function.c"
  strip_whitespace(& p, & end);
  }
  {
# 708 "function.c"
  while (1) {
    while_continue: ;
# 708 "function.c"
    if (! ((unsigned long )p <= (unsigned long )end)) {
# 708 "function.c"
      goto while_break;
    }
# 709 "function.c"
    tmp___0 = p;
# 709 "function.c"
    p ++;
# 709 "function.c"
    if (! ((unsigned int )*tmp___0 - 48U <= 9U)) {
# 710 "function.c"
      return (0);
    }
  }
  while_break: ;
  }
# 712 "function.c"
  return (end - beg >= 0L);
}
}
# 715 "function.c"
void check_numeric(char *s , char *message___0 )
{
  int tmp ;

  {
  {
# 720 "function.c"
  tmp = is_numeric(s);
  }
# 720 "function.c"
  if (! tmp) {
    {
# 721 "function.c"
    fatal(reading_file, (char const *)message___0);
    }
  }
# 722 "function.c"
  return;
}
}
# 726 "function.c"
static char *func_word(char *o , char **argv , char const *funcname )
{
  char *end_p ;
  int i ;
  char *p ;
  char *tmp ;
  char *tmp___0 ;

  {
  {
# 732 "function.c"
  end_p = (char *)0;
# 733 "function.c"
  i = 0;
# 734 "function.c"
  p = (char *)0;
# 737 "function.c"
  tmp = dcgettext((char const *)((void *)0), "non-numeric first argument to `word\' function",
                  5);
# 737 "function.c"
  check_numeric(*(argv + 0), tmp);
# 738 "function.c"
  i = atoi((char const *)*(argv + 0));
  }
# 740 "function.c"
  if (i == 0) {
    {
# 741 "function.c"
    tmp___0 = dcgettext((char const *)((void *)0), "the `word\' function takes a positive index argument",
                        5);
# 741 "function.c"
    fatal(reading_file, (char const *)tmp___0);
    }
  }
# 744 "function.c"
  end_p = *(argv + 1);
  {
# 745 "function.c"
  while (1) {
    while_continue: ;
    {
# 745 "function.c"
    p = find_next_token(& end_p, (unsigned int *)0);
    }
# 745 "function.c"
    if (! ((unsigned long )p != (unsigned long )((char *)0))) {
# 745 "function.c"
      goto while_break;
    }
# 746 "function.c"
    i --;
# 746 "function.c"
    if (i == 0) {
# 747 "function.c"
      goto while_break;
    }
  }
  while_break: ;
  }
# 749 "function.c"
  if (i == 0) {
    {
# 750 "function.c"
    o = variable_buffer_output(o, p, (unsigned int )(end_p - p));
    }
  }
# 752 "function.c"
  return (o);
}
}
# 755 "function.c"
static char *func_wordlist(char *o , char **argv , char const *funcname )
{
  int start ;
  int count ;
  char *tmp ;
  char *tmp___0 ;
  int tmp___1 ;
  char *p ;
  char *end_p ;
  char *tmp___2 ;

  {
  {
# 764 "function.c"
  tmp = dcgettext((char const *)((void *)0), "non-numeric first argument to `wordlist\' function",
                  5);
# 764 "function.c"
  check_numeric(*(argv + 0), tmp);
# 766 "function.c"
  tmp___0 = dcgettext((char const *)((void *)0), "non-numeric second argument to `wordlist\' function",
                      5);
# 766 "function.c"
  check_numeric(*(argv + 1), tmp___0);
# 769 "function.c"
  start = atoi((char const *)*(argv + 0));
# 770 "function.c"
  tmp___1 = atoi((char const *)*(argv + 1));
# 770 "function.c"
  count = (tmp___1 - start) + 1;
  }
# 772 "function.c"
  if (count > 0) {
# 775 "function.c"
    end_p = *(argv + 2);
    {
# 778 "function.c"
    while (1) {
      while_continue: ;
      {
# 778 "function.c"
      p = find_next_token(& end_p, (unsigned int *)0);
      }
# 778 "function.c"
      if ((unsigned long )p != (unsigned long )((char *)0)) {
# 778 "function.c"
        start --;
# 778 "function.c"
        if (! start) {
# 778 "function.c"
          goto while_break;
        }
      } else {
# 778 "function.c"
        goto while_break;
      }
    }
    while_break: ;
    }
# 781 "function.c"
    if (p) {
      {
# 784 "function.c"
      while (1) {
        while_continue___0: ;
# 784 "function.c"
        count --;
# 784 "function.c"
        if (count) {
          {
# 784 "function.c"
          tmp___2 = find_next_token(& end_p, (unsigned int *)0);
          }
# 784 "function.c"
          if (! ((unsigned long )tmp___2 != (unsigned long )((char *)0))) {
# 784 "function.c"
            goto while_break___0;
          }
        } else {
# 784 "function.c"
          goto while_break___0;
        }
      }
      while_break___0: ;
      }
      {
# 788 "function.c"
      o = variable_buffer_output(o, p, (unsigned int )(end_p - p));
      }
    }
  }
# 792 "function.c"
  return (o);
}
}
# 795 "function.c"
static char *func_findstring(char *o , char **argv , char const *funcname )
{
  int i ;
  size_t tmp ;
  char *tmp___0 ;

  {
  {
# 802 "function.c"
  tmp = strlen((char const *)*(argv + 0));
# 802 "function.c"
  i = (int )tmp;
# 803 "function.c"
  tmp___0 = sindex((char const *)*(argv + 1), 0U, (char const *)*(argv + 0), (unsigned int )i);
  }
# 803 "function.c"
  if ((unsigned long )tmp___0 != (unsigned long )((char *)0)) {
    {
# 804 "function.c"
    o = variable_buffer_output(o, *(argv + 0), (unsigned int )i);
    }
  }
# 806 "function.c"
  return (o);
}
}
# 809 "function.c"
static char *func_foreach(char *o , char **argv , char const *funcname )
{
  char *varname ;
  char *tmp ;
  char *list ;
  char *tmp___0 ;
  char *body ;
  int doneany ;
  char *list_iterator ;
  char *p ;
  unsigned int len ;
  register struct variable *var ;
  size_t tmp___1 ;
  char *result___0 ;
  char save ;
  char *tmp___2 ;
  size_t tmp___3 ;

  {
  {
# 816 "function.c"
  tmp = expand_argument(*(argv + 0), (char *)((void *)0));
# 816 "function.c"
  varname = tmp;
# 817 "function.c"
  tmp___0 = expand_argument(*(argv + 1), (char *)((void *)0));
# 817 "function.c"
  list = tmp___0;
# 818 "function.c"
  body = *(argv + 2);
# 820 "function.c"
  doneany = 0;
# 821 "function.c"
  list_iterator = list;
# 826 "function.c"
  push_new_variable_scope();
# 827 "function.c"
  tmp___1 = strlen((char const *)varname);
# 827 "function.c"
  var = define_variable_in_set(varname, (unsigned int )tmp___1, (char *)"", (enum variable_origin )6,
                               0, current_variable_set_list->set, (struct floc const *)((struct floc *)0));
  }
  {
# 830 "function.c"
  while (1) {
    while_continue: ;
    {
# 830 "function.c"
    p = find_next_token(& list_iterator, & len);
    }
# 830 "function.c"
    if (! ((unsigned long )p != (unsigned long )((char *)0))) {
# 830 "function.c"
      goto while_break;
    }
    {
# 832 "function.c"
    result___0 = (char *)0;
# 835 "function.c"
    save = *(p + len);
# 837 "function.c"
    *(p + len) = (char )'\000';
# 838 "function.c"
    free((void *)var->value);
# 839 "function.c"
    tmp___2 = xstrdup((char const *)p);
# 839 "function.c"
    var->value = tmp___2;
# 840 "function.c"
    *(p + len) = save;
# 843 "function.c"
    result___0 = allocated_variable_expand_for_file(body, (struct file *)0);
# 845 "function.c"
    tmp___3 = strlen((char const *)result___0);
# 845 "function.c"
    o = variable_buffer_output(o, result___0, (unsigned int )tmp___3);
# 846 "function.c"
    o = variable_buffer_output(o, (char *)" ", 1U);
# 847 "function.c"
    doneany = 1;
# 848 "function.c"
    free((void *)result___0);
    }
  }
  while_break: ;
  }
# 851 "function.c"
  if (doneany) {
# 853 "function.c"
    o --;
  }
  {
# 855 "function.c"
  pop_variable_scope();
# 856 "function.c"
  free((void *)varname);
# 857 "function.c"
  free((void *)list);
  }
# 859 "function.c"
  return (o);
}
}
# 869 "function.c"
static char *func_filter_filterout(char *o , char **argv , char const *funcname )
{
  struct a_word *wordhead ;
  struct a_word *wordtail ;
  int is_filter ;
  int tmp ;
  int tmp___0 ;
  char *patterns ;
  char *word_iterator ;
  char *p ;
  unsigned int len ;
  struct a_word *w ;
  void *tmp___1 ;
  char *pat_iterator ;
  int doneany ;
  struct a_word *wp ;
  char *percent ;
  char save ;
  int tmp___2 ;
  int tmp___3 ;
  int tmp___4 ;
  int tmp___5 ;
  size_t tmp___6 ;
  int tmp___7 ;

  {
# 875 "function.c"
  wordhead = (struct a_word *)0;
# 876 "function.c"
  wordtail = (struct a_word *)0;
# 878 "function.c"
  if ((unsigned long )funcname == (unsigned long )"filter") {
# 878 "function.c"
    tmp___0 = 1;
  } else
# 878 "function.c"
  if ((int const )*funcname == (int const )*"filter") {
# 878 "function.c"
    if ((int const )*funcname == 0) {
# 878 "function.c"
      tmp___0 = 1;
    } else {
      {
# 878 "function.c"
      tmp = strcmp(funcname + 1, "filter" + 1);
      }
# 878 "function.c"
      if (tmp) {
# 878 "function.c"
        tmp___0 = 0;
      } else {
# 878 "function.c"
        tmp___0 = 1;
      }
    }
  } else {
# 878 "function.c"
    tmp___0 = 0;
  }
# 878 "function.c"
  is_filter = tmp___0;
# 879 "function.c"
  patterns = *(argv + 0);
# 880 "function.c"
  word_iterator = *(argv + 1);
  {
# 886 "function.c"
  while (1) {
    while_continue: ;
    {
# 886 "function.c"
    p = find_next_token(& word_iterator, & len);
    }
# 886 "function.c"
    if (! ((unsigned long )p != (unsigned long )((char *)0))) {
# 886 "function.c"
      goto while_break;
    }
    {
# 888 "function.c"
    tmp___1 = __builtin_alloca(sizeof(struct a_word ));
# 888 "function.c"
    w = (struct a_word *)tmp___1;
    }
# 889 "function.c"
    if ((unsigned long )wordhead == (unsigned long )((struct a_word *)0)) {
# 890 "function.c"
      wordhead = w;
    } else {
# 892 "function.c"
      wordtail->next = w;
    }
# 893 "function.c"
    wordtail = w;
# 895 "function.c"
    if ((int )*word_iterator != 0) {
# 896 "function.c"
      word_iterator ++;
    }
# 897 "function.c"
    *(p + len) = (char )'\000';
# 898 "function.c"
    w->str = p;
# 899 "function.c"
    w->matched = 0;
  }
  while_break: ;
  }
# 902 "function.c"
  if ((unsigned long )wordhead != (unsigned long )((struct a_word *)0)) {
# 904 "function.c"
    pat_iterator = patterns;
# 905 "function.c"
    doneany = 0;
# 908 "function.c"
    wordtail->next = (struct a_word *)0;
    {
# 911 "function.c"
    while (1) {
      while_continue___0: ;
      {
# 911 "function.c"
      p = find_next_token(& pat_iterator, & len);
      }
# 911 "function.c"
      if (! ((unsigned long )p != (unsigned long )((char *)0))) {
# 911 "function.c"
        goto while_break___0;
      }
      {
# 914 "function.c"
      save = *(p + len);
# 915 "function.c"
      *(p + len) = (char )'\000';
# 917 "function.c"
      percent = find_percent(p);
# 918 "function.c"
      wp = wordhead;
      }
      {
# 918 "function.c"
      while (1) {
        while_continue___1: ;
# 918 "function.c"
        if (! ((unsigned long )wp != (unsigned long )((struct a_word *)0))) {
# 918 "function.c"
          goto while_break___1;
        }
# 919 "function.c"
        if ((unsigned long )percent == (unsigned long )((char *)0)) {
# 919 "function.c"
          if ((unsigned long )p == (unsigned long )wp->str) {
# 919 "function.c"
            tmp___3 = 1;
          } else
# 919 "function.c"
          if ((int )*p == (int )*(wp->str)) {
# 919 "function.c"
            if ((int )*p == 0) {
# 919 "function.c"
              tmp___3 = 1;
            } else {
              {
# 919 "function.c"
              tmp___2 = strcmp((char const *)(p + 1), (char const *)(wp->str + 1));
              }
# 919 "function.c"
              if (tmp___2) {
# 919 "function.c"
                tmp___3 = 0;
              } else {
# 919 "function.c"
                tmp___3 = 1;
              }
            }
          } else {
# 919 "function.c"
            tmp___3 = 0;
          }
# 919 "function.c"
          tmp___5 = tmp___3;
        } else {
          {
# 919 "function.c"
          tmp___4 = pattern_matches(p, percent, wp->str);
# 919 "function.c"
          tmp___5 = tmp___4;
          }
        }
# 919 "function.c"
        wp->matched |= tmp___5;
# 918 "function.c"
        wp = wp->next;
      }
      while_break___1: ;
      }
# 922 "function.c"
      *(p + len) = save;
    }
    while_break___0: ;
    }
# 926 "function.c"
    wp = wordhead;
    {
# 926 "function.c"
    while (1) {
      while_continue___2: ;
# 926 "function.c"
      if (! ((unsigned long )wp != (unsigned long )((struct a_word *)0))) {
# 926 "function.c"
        goto while_break___2;
      }
# 927 "function.c"
      if (is_filter) {
# 927 "function.c"
        tmp___7 = wp->matched;
      } else {
# 927 "function.c"
        tmp___7 = ! wp->matched;
      }
# 927 "function.c"
      if (tmp___7) {
        {
# 929 "function.c"
        tmp___6 = strlen((char const *)wp->str);
# 929 "function.c"
        o = variable_buffer_output(o, wp->str, (unsigned int )tmp___6);
# 930 "function.c"
        o = variable_buffer_output(o, (char *)" ", 1U);
# 931 "function.c"
        doneany = 1;
        }
      }
# 926 "function.c"
      wp = wp->next;
    }
    while_break___2: ;
    }
# 934 "function.c"
    if (doneany) {
# 936 "function.c"
      o --;
    }
  }
# 939 "function.c"
  return (o);
}
}
# 943 "function.c"
static char *func_strip(char *o , char **argv , char const *funcname )
{
  char *p ;
  int doneany ;
  int i ;
  char *word_start ;
  unsigned short const **tmp ;
  unsigned short const **tmp___0 ;

  {
# 949 "function.c"
  p = *(argv + 0);
# 950 "function.c"
  doneany = 0;
  {
# 952 "function.c"
  while (1) {
    while_continue: ;
# 952 "function.c"
    if (! ((int )*p != 0)) {
# 952 "function.c"
      goto while_break;
    }
# 954 "function.c"
    i = 0;
# 955 "function.c"
    word_start = (char *)0;
    {
# 957 "function.c"
    while (1) {
      while_continue___0: ;
      {
# 957 "function.c"
      tmp = __ctype_b_loc();
      }
# 957 "function.c"
      if (! ((int const )*(*tmp + (int )((unsigned char )*p)) & 8192)) {
# 957 "function.c"
        goto while_break___0;
      }
# 958 "function.c"
      p ++;
    }
    while_break___0: ;
    }
# 959 "function.c"
    word_start = p;
# 960 "function.c"
    i = 0;
    {
# 960 "function.c"
    while (1) {
      while_continue___1: ;
# 960 "function.c"
      if ((int )*p != 0) {
        {
# 960 "function.c"
        tmp___0 = __ctype_b_loc();
        }
# 960 "function.c"
        if ((int const )*(*tmp___0 + (int )((unsigned char )*p)) & 8192) {
# 960 "function.c"
          goto while_break___1;
        }
      } else {
# 960 "function.c"
        goto while_break___1;
      }
# 960 "function.c"
      p ++;
# 960 "function.c"
      i ++;
    }
    while_break___1: ;
    }
# 962 "function.c"
    if (! i) {
# 963 "function.c"
      goto while_break;
    }
    {
# 964 "function.c"
    o = variable_buffer_output(o, word_start, (unsigned int )i);
# 965 "function.c"
    o = variable_buffer_output(o, (char *)" ", 1U);
# 966 "function.c"
    doneany = 1;
    }
  }
  while_break: ;
  }
# 969 "function.c"
  if (doneany) {
# 971 "function.c"
    o --;
  }
# 972 "function.c"
  return (o);
}
}
# 978 "function.c"
static char *func_error(char *o , char **argv , char const *funcname )
{
  char **argvp ;
  char *msg ;
  char *p ;
  int len ;
  size_t tmp ;
  void *tmp___0 ;
  size_t tmp___1 ;
  char *tmp___2 ;
  char *tmp___3 ;

  {
# 991 "function.c"
  len = 0;
# 991 "function.c"
  argvp = argv;
  {
# 991 "function.c"
  while (1) {
    while_continue: ;
# 991 "function.c"
    if (! ((unsigned long )*argvp != (unsigned long )((char *)0))) {
# 991 "function.c"
      goto while_break;
    }
    {
# 992 "function.c"
    tmp = strlen((char const *)*argvp);
# 992 "function.c"
    len = (int )((size_t )len + (tmp + 2UL));
# 991 "function.c"
    argvp ++;
    }
  }
  while_break: ;
  }
  {
# 994 "function.c"
  tmp___0 = __builtin_alloca((unsigned long )(len + 1));
# 994 "function.c"
  msg = (char *)tmp___0;
# 994 "function.c"
  p = msg;
# 996 "function.c"
  argvp = argv;
  }
  {
# 996 "function.c"
  while (1) {
    while_continue___0: ;
# 996 "function.c"
    if (! ((unsigned long )*(argvp + 1) != (unsigned long )((char *)0))) {
# 996 "function.c"
      goto while_break___0;
    }
    {
# 998 "function.c"
    strcpy((char * __restrict )p, (char const * __restrict )*argvp);
# 999 "function.c"
    tmp___1 = strlen((char const *)*argvp);
# 999 "function.c"
    p += tmp___1;
# 1000 "function.c"
    tmp___2 = p;
# 1000 "function.c"
    p ++;
# 1000 "function.c"
    *tmp___2 = (char )',';
# 1001 "function.c"
    tmp___3 = p;
# 1001 "function.c"
    p ++;
# 1001 "function.c"
    *tmp___3 = (char )' ';
# 996 "function.c"
    argvp ++;
    }
  }
  while_break___0: ;
  }
  {
# 1003 "function.c"
  strcpy((char * __restrict )p, (char const * __restrict )*argvp);
  }
# 1005 "function.c"
  if ((int const )*funcname == 101) {
    {
# 1006 "function.c"
    fatal(reading_file, "%s", msg);
    }
  }
  {
# 1009 "function.c"
  error(reading_file, "%s", msg);
  }
# 1011 "function.c"
  return (o);
}
}
# 1018 "function.c"
static char *func_sort(char *o , char **argv , char const *funcname )
{
  char **words ;
  int nwords ;
  register int wordi ;
  char *t ;
  char *p ;
  unsigned int len ;
  int i ;
  char *tmp ;
  int tmp___0 ;
  size_t tmp___1 ;
  size_t tmp___2 ;
  int tmp___3 ;

  {
# 1024 "function.c"
  words = (char **)0;
# 1025 "function.c"
  nwords = 0;
# 1026 "function.c"
  wordi = 0;
# 1029 "function.c"
  t = *(argv + 0);
  {
# 1034 "function.c"
  while (1) {
    while_continue: ;
    {
# 1034 "function.c"
    p = find_next_token(& t, & len);
    }
# 1034 "function.c"
    if (! ((unsigned long )p != (unsigned long )((char *)0))) {
# 1034 "function.c"
      goto while_break;
    }
# 1036 "function.c"
    if (wordi >= nwords - 1) {
      {
# 1038 "function.c"
      nwords = 2 * nwords + 5;
# 1039 "function.c"
      tmp = xrealloc((char *)words, (unsigned int )((unsigned long )nwords * sizeof(char *)));
# 1039 "function.c"
      words = (char **)tmp;
      }
    }
    {
# 1042 "function.c"
    tmp___0 = wordi;
# 1042 "function.c"
    wordi ++;
# 1042 "function.c"
    *(words + tmp___0) = savestring((char const *)p, len);
    }
  }
  while_break: ;
  }
# 1045 "function.c"
  if (! wordi) {
# 1046 "function.c"
    return (o);
  }
  {
# 1049 "function.c"
  qsort((void *)((char *)words), (size_t )wordi, sizeof(char *), & alpha_compare);
# 1052 "function.c"
  i = 0;
  }
  {
# 1052 "function.c"
  while (1) {
    while_continue___0: ;
# 1052 "function.c"
    if (! (i < wordi)) {
# 1052 "function.c"
      goto while_break___0;
    }
    {
# 1054 "function.c"
    tmp___1 = strlen((char const *)*(words + i));
# 1054 "function.c"
    len = (unsigned int )tmp___1;
    }
# 1055 "function.c"
    if (i == wordi - 1) {
      {
# 1058 "function.c"
      o = variable_buffer_output(o, *(words + i), len);
# 1059 "function.c"
      o = variable_buffer_output(o, (char *)" ", 1U);
      }
    } else {
      {
# 1055 "function.c"
      tmp___2 = strlen((char const *)*(words + (i + 1)));
      }
# 1055 "function.c"
      if (tmp___2 != (size_t )len) {
        {
# 1058 "function.c"
        o = variable_buffer_output(o, *(words + i), len);
# 1059 "function.c"
        o = variable_buffer_output(o, (char *)" ", 1U);
        }
      } else {
        {
# 1055 "function.c"
        tmp___3 = strcmp((char const *)*(words + i), (char const *)*(words + (i + 1)));
        }
# 1055 "function.c"
        if (tmp___3) {
          {
# 1058 "function.c"
          o = variable_buffer_output(o, *(words + i), len);
# 1059 "function.c"
          o = variable_buffer_output(o, (char *)" ", 1U);
          }
        }
      }
    }
    {
# 1061 "function.c"
    free((void *)*(words + i));
# 1052 "function.c"
    i ++;
    }
  }
  while_break___0: ;
  }
  {
# 1064 "function.c"
  o --;
# 1066 "function.c"
  free((void *)words);
  }
# 1068 "function.c"
  return (o);
}
}
# 1083 "function.c"
static char *func_if(char *o , char **argv , char const *funcname )
{
  char *begp ;
  char *endp ;
  size_t tmp ;
  int result___0 ;
  char *expansion ;
  char *tmp___0 ;
  size_t tmp___1 ;
  char *expansion___0 ;
  size_t tmp___2 ;

  {
  {
# 1089 "function.c"
  begp = *(argv + 0);
# 1090 "function.c"
  tmp = strlen((char const *)*(argv + 0));
# 1090 "function.c"
  endp = begp + tmp;
# 1091 "function.c"
  result___0 = 0;
# 1097 "function.c"
  strip_whitespace(& begp, & endp);
  }
# 1099 "function.c"
  if ((unsigned long )begp < (unsigned long )endp) {
    {
# 1101 "function.c"
    tmp___0 = expand_argument(begp, (char *)((void *)0));
# 1101 "function.c"
    expansion = tmp___0;
# 1103 "function.c"
    tmp___1 = strlen((char const *)expansion);
# 1103 "function.c"
    result___0 = (int )tmp___1;
# 1104 "function.c"
    free((void *)expansion);
    }
  }
# 1111 "function.c"
  argv += 1 + ! result___0;
# 1113 "function.c"
  if (*(argv + 0)) {
    {
# 1117 "function.c"
    expansion___0 = expand_argument(*(argv + 0), (char *)((void *)0));
# 1119 "function.c"
    tmp___2 = strlen((char const *)expansion___0);
# 1119 "function.c"
    o = variable_buffer_output(o, expansion___0, (unsigned int )tmp___2);
# 1121 "function.c"
    free((void *)expansion___0);
    }
  }
# 1124 "function.c"
  return (o);
}
}
# 1127 "function.c"
static char *func_wildcard(char *o , char **argv , char const *funcname )
{
  char *p ;
  char *tmp ;
  size_t tmp___0 ;

  {
  {
# 1137 "function.c"
  tmp = string_glob(*(argv + 0));
# 1137 "function.c"
  p = tmp;
# 1138 "function.c"
  tmp___0 = strlen((char const *)p);
# 1138 "function.c"
  o = variable_buffer_output(o, p, (unsigned int )tmp___0);
  }
# 1140 "function.c"
  return (o);
}
}
# 1146 "function.c"
void fold_newlines(char *buffer , int *length___0 )
{
  char *dst ;
  char *src ;
  char *last_nonnl ;
  char *tmp ;
  char *tmp___0 ;

  {
# 1151 "function.c"
  dst = buffer;
# 1152 "function.c"
  src = buffer;
# 1153 "function.c"
  last_nonnl = buffer - 1;
# 1154 "function.c"
  *(src + *length___0) = (char)0;
  {
# 1155 "function.c"
  while (1) {
    while_continue: ;
# 1155 "function.c"
    if (! ((int )*src != 0)) {
# 1155 "function.c"
      goto while_break;
    }
# 1157 "function.c"
    if ((int )*(src + 0) == 13) {
# 1157 "function.c"
      if ((int )*(src + 1) == 10) {
# 1158 "function.c"
        goto __Cont;
      }
    }
# 1159 "function.c"
    if ((int )*src == 10) {
# 1161 "function.c"
      tmp = dst;
# 1161 "function.c"
      dst ++;
# 1161 "function.c"
      *tmp = (char )' ';
    } else {
# 1165 "function.c"
      last_nonnl = dst;
# 1166 "function.c"
      tmp___0 = dst;
# 1166 "function.c"
      dst ++;
# 1166 "function.c"
      *tmp___0 = *src;
    }
    __Cont:
# 1155 "function.c"
    src ++;
  }
  while_break: ;
  }
# 1169 "function.c"
  last_nonnl ++;
# 1169 "function.c"
  *last_nonnl = (char )'\000';
# 1170 "function.c"
  *length___0 = (int )(last_nonnl - buffer);
# 1171 "function.c"
  return;
}
}
# 1175 "function.c"
int shell_function_pid = 0;
# 1175 "function.c"
int shell_function_completed ;
# 1332 "function.c"
static char *func_shell(char *o , char **argv , char const *funcname )
{
  char *batch_filename ;
  int i ;
  char **command_argv ;
  char *error_prefix ;
  char **envp ;
  int pipedes[2] ;
  int pid ;
  size_t tmp ;
  void *tmp___0 ;
  int tmp___1 ;
  char *buffer ;
  unsigned int maxlen ;
  int cc ;
  char *tmp___2 ;
  char *tmp___3 ;
  int *tmp___4 ;
  ssize_t tmp___5 ;
  int *tmp___6 ;
  char *tmp___7 ;

  {
  {
# 1338 "function.c"
  batch_filename = (char *)((void *)0);
# 1352 "function.c"
  command_argv = construct_command_argv(*(argv + 0), (char **)((void *)0), (struct file *)0,
                                        & batch_filename);
  }
# 1355 "function.c"
  if ((unsigned long )command_argv == (unsigned long )((char **)0)) {
# 1356 "function.c"
    return (o);
  }
# 1366 "function.c"
  envp = environ;
# 1369 "function.c"
  if ((unsigned long )reading_file != (unsigned long )((struct floc const *)0)) {
    {
# 1371 "function.c"
    tmp = strlen((char const *)reading_file->filenm);
# 1371 "function.c"
    tmp___0 = __builtin_alloca((tmp + 11UL) + 4UL);
# 1371 "function.c"
    error_prefix = (char *)tmp___0;
# 1372 "function.c"
    sprintf((char * __restrict )error_prefix, (char const * __restrict )"%s:%lu: ",
            reading_file->filenm, reading_file->lineno);
    }
  } else {
# 1376 "function.c"
    error_prefix = (char *)"";
  }
  {
# 1397 "function.c"
  tmp___1 = pipe(pipedes);
  }
# 1397 "function.c"
  if (tmp___1 < 0) {
    {
# 1399 "function.c"
    perror_with_name(error_prefix, (char *)"pipe");
    }
# 1400 "function.c"
    return (o);
  }
  {
# 1403 "function.c"
  pid = vfork();
  }
# 1404 "function.c"
  if (pid < 0) {
    {
# 1405 "function.c"
    perror_with_name(error_prefix, (char *)"fork");
    }
  } else
# 1406 "function.c"
  if (pid == 0) {
    {
# 1407 "function.c"
    child_execute_job(0, pipedes[1], command_argv, envp);
    }
  } else {
    {
# 1420 "function.c"
    shell_function_pid = pid;
# 1422 "function.c"
    shell_function_completed = 0;
# 1425 "function.c"
    free((void *)*(command_argv + 0));
# 1426 "function.c"
    free((void *)((char *)command_argv));
# 1429 "function.c"
    close(pipedes[1]);
# 1434 "function.c"
    maxlen = 200U;
# 1435 "function.c"
    tmp___2 = xmalloc(maxlen + 1U);
# 1435 "function.c"
    buffer = tmp___2;
# 1438 "function.c"
    i = 0;
    }
    {
# 1439 "function.c"
    while (1) {
      while_continue: ;
# 1441 "function.c"
      if ((unsigned int )i == maxlen) {
        {
# 1443 "function.c"
        maxlen += 512U;
# 1444 "function.c"
        tmp___3 = xrealloc(buffer, maxlen + 1U);
# 1444 "function.c"
        buffer = tmp___3;
        }
      }
      {
# 1447 "function.c"
      tmp___4 = __errno_location();
# 1447 "function.c"
      *tmp___4 = 0;
# 1448 "function.c"
      tmp___5 = read(pipedes[0], (void *)(buffer + i), (size_t )(maxlen - (unsigned int )i));
# 1448 "function.c"
      cc = (int )tmp___5;
      }
# 1449 "function.c"
      if (cc > 0) {
# 1450 "function.c"
        i += cc;
      }
# 1439 "function.c"
      if (! (cc > 0)) {
        {
# 1439 "function.c"
        tmp___6 = __errno_location();
        }
# 1439 "function.c"
        if (! (*tmp___6 == 4)) {
# 1439 "function.c"
          goto while_break;
        }
      }
    }
    while_break: ;
    }
    {
# 1459 "function.c"
    close(pipedes[0]);
    }
    {
# 1464 "function.c"
    while (1) {
      while_continue___0: ;
# 1464 "function.c"
      if (! (shell_function_completed == 0)) {
# 1464 "function.c"
        goto while_break___0;
      }
      {
# 1465 "function.c"
      reap_children(1, 0);
      }
    }
    while_break___0: ;
    }
# 1467 "function.c"
    if (batch_filename) {
      {
# 1468 "function.c"
      while (1) {
        while_continue___1: ;
# 1468 "function.c"
        if (2 & db_level) {
          {
# 1468 "function.c"
          tmp___7 = dcgettext((char const *)((void *)0), "Cleaning up temporary batch file %s\n",
                              5);
# 1468 "function.c"
          printf((char const * __restrict )tmp___7, batch_filename);
# 1468 "function.c"
          fflush(stdout);
          }
        }
# 1468 "function.c"
        goto while_break___1;
      }
      while_break___1: ;
      }
      {
# 1470 "function.c"
      remove((char const *)batch_filename);
# 1471 "function.c"
      free((void *)batch_filename);
      }
    }
# 1473 "function.c"
    shell_function_pid = 0;
# 1479 "function.c"
    if (shell_function_completed == -1) {
      {
# 1484 "function.c"
      fputs((char const * __restrict )buffer, (FILE * __restrict )stderr);
# 1485 "function.c"
      fflush(stderr);
      }
    } else {
      {
# 1492 "function.c"
      fold_newlines(buffer, & i);
# 1493 "function.c"
      o = variable_buffer_output(o, buffer, (unsigned int )i);
      }
    }
    {
# 1496 "function.c"
    free((void *)buffer);
    }
  }
# 1499 "function.c"
  return (o);
}
}
# 1637 "function.c"
static char *func_call(char *o , char **argv , char const *funcname ) ;
# 1640 "function.c"
static struct function_table_entry function_table[27] =
# 1640 "function.c"
  { {"addprefix", (unsigned char )(sizeof("addprefix") - 1UL), (unsigned char)2,
      (unsigned char)2, (char)1, & func_addsuffix_addprefix},
        {"addsuffix", (unsigned char )(sizeof("addsuffix") - 1UL), (unsigned char)2,
      (unsigned char)2, (char)1, & func_addsuffix_addprefix},
        {"basename", (unsigned char )(sizeof("basename") - 1UL), (unsigned char)1, (unsigned char)1,
      (char)1, & func_basename_dir},
        {"dir", (unsigned char )(sizeof("dir") - 1UL), (unsigned char)1, (unsigned char)1,
      (char)1, & func_basename_dir},
        {"notdir", (unsigned char )(sizeof("notdir") - 1UL), (unsigned char)1, (unsigned char)1,
      (char)1, & func_notdir_suffix},
        {"subst", (unsigned char )(sizeof("subst") - 1UL), (unsigned char)3, (unsigned char)3,
      (char)1, & func_subst},
        {"suffix", (unsigned char )(sizeof("suffix") - 1UL), (unsigned char)1, (unsigned char)1,
      (char)1, & func_notdir_suffix},
        {"filter", (unsigned char )(sizeof("filter") - 1UL), (unsigned char)2, (unsigned char)2,
      (char)1, & func_filter_filterout},
        {"filter-out", (unsigned char )(sizeof("filter-out") - 1UL), (unsigned char)2,
      (unsigned char)2, (char)1, & func_filter_filterout},
        {"findstring", (unsigned char )(sizeof("findstring") - 1UL), (unsigned char)2,
      (unsigned char)2, (char)1, & func_findstring},
        {"firstword", (unsigned char )(sizeof("firstword") - 1UL), (unsigned char)1,
      (unsigned char)1, (char)1, & func_firstword},
        {"join", (unsigned char )(sizeof("join") - 1UL), (unsigned char)2, (unsigned char)2,
      (char)1, & func_join},
        {"patsubst", (unsigned char )(sizeof("patsubst") - 1UL), (unsigned char)3, (unsigned char)3,
      (char)1, & func_patsubst},
        {"shell", (unsigned char )(sizeof("shell") - 1UL), (unsigned char)1, (unsigned char)1,
      (char)1, & func_shell},
        {"sort", (unsigned char )(sizeof("sort") - 1UL), (unsigned char)1, (unsigned char)1,
      (char)1, & func_sort},
        {"strip", (unsigned char )(sizeof("strip") - 1UL), (unsigned char)1, (unsigned char)1,
      (char)1, & func_strip},
        {"wildcard", (unsigned char )(sizeof("wildcard") - 1UL), (unsigned char)1, (unsigned char)1,
      (char)1, & func_wildcard},
        {"word", (unsigned char )(sizeof("word") - 1UL), (unsigned char)2, (unsigned char)2,
      (char)1, & func_word},
        {"wordlist", (unsigned char )(sizeof("wordlist") - 1UL), (unsigned char)3, (unsigned char)3,
      (char)1, & func_wordlist},
        {"words", (unsigned char )(sizeof("words") - 1UL), (unsigned char)1, (unsigned char)1,
      (char)1, & func_words},
        {"origin", (unsigned char )(sizeof("origin") - 1UL), (unsigned char)1, (unsigned char)1,
      (char)1, & func_origin},
        {"foreach", (unsigned char )(sizeof("foreach") - 1UL), (unsigned char)3, (unsigned char)3,
      (char)0, & func_foreach},
        {"call", (unsigned char )(sizeof("call") - 1UL), (unsigned char)1, (unsigned char)0,
      (char)1, & func_call},
        {"error", (unsigned char )(sizeof("error") - 1UL), (unsigned char)1, (unsigned char)1,
      (char)1, & func_error},
        {"warning", (unsigned char )(sizeof("warning") - 1UL), (unsigned char)1, (unsigned char)1,
      (char)1, & func_error},
        {"if", (unsigned char )(sizeof("if") - 1UL), (unsigned char)2, (unsigned char)3,
      (char)0, & func_if},
        {(char const *)0, (unsigned char)0, (unsigned char)0, (unsigned char)0, (char)0,
      (char *(*)(char *output , char **argv , char const *fname ))0}};
# 1679 "function.c"
static char *expand_builtin_function(char *o , int argc , char **argv , struct function_table_entry *entry_p )
{
  char *tmp ;
  char *tmp___0 ;
  char *tmp___1 ;

  {
# 1686 "function.c"
  if (argc < (int )entry_p->minimum_args) {
    {
# 1687 "function.c"
    tmp = dcgettext((char const *)((void *)0), "Insufficient number of arguments (%d) to function `%s\'",
                    5);
# 1687 "function.c"
    fatal(reading_file, (char const *)tmp, argc, entry_p->name);
    }
  }
# 1691 "function.c"
  if (! entry_p->func_ptr) {
    {
# 1692 "function.c"
    tmp___0 = dcgettext((char const *)((void *)0), "Unimplemented on this platform: function `%s\'",
                        5);
# 1692 "function.c"
    fatal(reading_file, (char const *)tmp___0, entry_p->name);
    }
  }
  {
# 1695 "function.c"
  tmp___1 = (*(entry_p->func_ptr))(o, argv, entry_p->name);
  }
# 1695 "function.c"
  return (tmp___1);
}
}
# 1703 "function.c"
int handle_function(char **op , char **stringp )
{
  struct function_table_entry const *entry_p ;
  char openparen ;
  char closeparen ;
  int tmp ;
  char *beg ;
  char *end ;
  int count ;
  register char *p ;
  char **argv ;
  char **argvp ;
  int nargs ;
  char *tmp___0 ;
  void *tmp___1 ;
  int len ;
  char *next ;

  {
# 1709 "function.c"
  openparen = *(*stringp + 0);
# 1710 "function.c"
  if ((int )openparen == 40) {
# 1710 "function.c"
    tmp = ')';
  } else {
# 1710 "function.c"
    tmp = '}';
  }
  {
# 1710 "function.c"
  closeparen = (char )tmp;
# 1713 "function.c"
  count = 0;
# 1718 "function.c"
  beg = *stringp + 1;
# 1720 "function.c"
  entry_p = lookup_function((struct function_table_entry const *)(function_table),
                            (char const *)beg);
  }
# 1722 "function.c"
  if (! entry_p) {
# 1723 "function.c"
    return (0);
  }
  {
# 1728 "function.c"
  beg = next_token(beg + (int const )entry_p->len);
# 1735 "function.c"
  nargs = 1;
# 1735 "function.c"
  end = beg;
  }
  {
# 1735 "function.c"
  while (1) {
    while_continue: ;
# 1735 "function.c"
    if (! ((int )*end != 0)) {
# 1735 "function.c"
      goto while_break;
    }
# 1736 "function.c"
    if ((int )*end == 44) {
# 1737 "function.c"
      nargs ++;
    } else
# 1738 "function.c"
    if ((int )*end == (int )openparen) {
# 1739 "function.c"
      count ++;
    } else
# 1740 "function.c"
    if ((int )*end == (int )closeparen) {
# 1740 "function.c"
      count --;
# 1740 "function.c"
      if (count < 0) {
# 1741 "function.c"
        goto while_break;
      }
    }
# 1735 "function.c"
    end ++;
  }
  while_break: ;
  }
# 1743 "function.c"
  if (count >= 0) {
    {
# 1744 "function.c"
    tmp___0 = dcgettext((char const *)((void *)0), "unterminated call to function `%s\': missing `%c\'",
                        5);
# 1744 "function.c"
    fatal(reading_file, (char const *)tmp___0, entry_p->name, (int )closeparen);
    }
  }
  {
# 1748 "function.c"
  *stringp = end;
# 1751 "function.c"
  tmp___1 = __builtin_alloca(sizeof(char *) * (unsigned long )(nargs + 2));
# 1751 "function.c"
  argv = (char **)tmp___1;
# 1751 "function.c"
  argvp = argv;
  }
# 1761 "function.c"
  if (! entry_p->expand_args) {
    {
# 1763 "function.c"
    len = (int )(end - beg);
# 1765 "function.c"
    p = xmalloc((unsigned int )(len + 1));
# 1766 "function.c"
    memcpy((void * __restrict )p, (void const * __restrict )beg, (size_t )len);
# 1767 "function.c"
    *(p + len) = (char )'\000';
# 1768 "function.c"
    beg = p;
# 1769 "function.c"
    end = beg + len;
    }
  }
# 1772 "function.c"
  p = beg;
# 1773 "function.c"
  nargs = 0;
# 1774 "function.c"
  p = beg;
# 1774 "function.c"
  nargs = 0;
  {
# 1774 "function.c"
  while (1) {
    while_continue___0: ;
# 1774 "function.c"
    if (! ((unsigned long )p < (unsigned long )end)) {
# 1774 "function.c"
      goto while_break___0;
    }
# 1778 "function.c"
    nargs ++;
# 1780 "function.c"
    if (nargs == (int )entry_p->maximum_args) {
# 1782 "function.c"
      next = end;
    } else {
      {
# 1780 "function.c"
      next = find_next_argument(openparen, closeparen, (char const *)p, (char const *)end);
      }
# 1780 "function.c"
      if (! next) {
# 1782 "function.c"
        next = end;
      }
    }
# 1784 "function.c"
    if (entry_p->expand_args) {
      {
# 1785 "function.c"
      *argvp = expand_argument(p, next);
      }
    } else {
# 1788 "function.c"
      *argvp = p;
# 1789 "function.c"
      *next = (char )'\000';
    }
# 1792 "function.c"
    p = next + 1;
# 1774 "function.c"
    argvp ++;
  }
  while_break___0: ;
  }
  {
# 1794 "function.c"
  *argvp = (char *)((void *)0);
# 1797 "function.c"
  *op = expand_builtin_function(*op, nargs, argv, (struct function_table_entry *)entry_p);
  }
# 1800 "function.c"
  if (entry_p->expand_args) {
# 1801 "function.c"
    argvp = argv;
    {
# 1801 "function.c"
    while (1) {
      while_continue___1: ;
# 1801 "function.c"
      if (! ((unsigned long )*argvp != (unsigned long )((char *)0))) {
# 1801 "function.c"
        goto while_break___1;
      }
      {
# 1802 "function.c"
      free((void *)*argvp);
# 1801 "function.c"
      argvp ++;
      }
    }
    while_break___1: ;
    }
  } else {
    {
# 1804 "function.c"
    free((void *)beg);
    }
  }
# 1806 "function.c"
  return (1);
}
}
# 1814 "function.c"
static char *func_call(char *o , char **argv , char const *funcname )
{
  char *fname ;
  char *cp ;
  int flen ;
  char *body ;
  int i ;
  struct function_table_entry const *entry_p ;
  unsigned short const **tmp ;
  size_t tmp___0 ;
  unsigned short const **tmp___1 ;
  char *tmp___2 ;
  size_t tmp___3 ;
  void *tmp___4 ;
  char num[11] ;
  size_t tmp___5 ;
  size_t tmp___6 ;

  {
# 1829 "function.c"
  fname = *(argv + 0);
  {
# 1830 "function.c"
  while (1) {
    while_continue: ;
# 1830 "function.c"
    if ((int )*fname != 0) {
      {
# 1830 "function.c"
      tmp = __ctype_b_loc();
      }
# 1830 "function.c"
      if (! ((int const )*(*tmp + (int )((unsigned char )*fname)) & 8192)) {
# 1830 "function.c"
        goto while_break;
      }
    } else {
# 1830 "function.c"
      goto while_break;
    }
# 1831 "function.c"
    fname ++;
  }
  while_break: ;
  }
  {
# 1833 "function.c"
  tmp___0 = strlen((char const *)fname);
# 1833 "function.c"
  cp = (fname + tmp___0) - 1;
  }
  {
# 1834 "function.c"
  while (1) {
    while_continue___0: ;
# 1834 "function.c"
    if ((unsigned long )cp > (unsigned long )fname) {
      {
# 1834 "function.c"
      tmp___1 = __ctype_b_loc();
      }
# 1834 "function.c"
      if (! ((int const )*(*tmp___1 + (int )((unsigned char )*cp)) & 8192)) {
# 1834 "function.c"
        goto while_break___0;
      }
    } else {
# 1834 "function.c"
      goto while_break___0;
    }
# 1835 "function.c"
    cp --;
  }
  while_break___0: ;
  }
# 1836 "function.c"
  *(cp + 1) = (char )'\000';
# 1839 "function.c"
  if ((int )*fname == 0) {
# 1840 "function.c"
    return (o);
  }
  {
# 1844 "function.c"
  entry_p = lookup_function((struct function_table_entry const *)(function_table),
                            (char const *)fname);
  }
# 1846 "function.c"
  if (entry_p) {
# 1849 "function.c"
    i = 0;
    {
# 1849 "function.c"
    while (1) {
      while_continue___1: ;
# 1849 "function.c"
      if (! *(argv + (i + 1))) {
# 1849 "function.c"
        goto while_break___1;
      }
# 1849 "function.c"
      i ++;
    }
    while_break___1: ;
    }
    {
# 1852 "function.c"
    tmp___2 = expand_builtin_function(o, i, argv + 1, (struct function_table_entry *)entry_p);
    }
# 1852 "function.c"
    return (tmp___2);
  }
  {
# 1858 "function.c"
  tmp___3 = strlen((char const *)fname);
# 1858 "function.c"
  flen = (int )tmp___3;
# 1860 "function.c"
  tmp___4 = __builtin_alloca((unsigned long )(flen + 4));
# 1860 "function.c"
  body = (char *)tmp___4;
# 1861 "function.c"
  *(body + 0) = (char )'$';
# 1862 "function.c"
  *(body + 1) = (char )'(';
# 1863 "function.c"
  memcpy((void * __restrict )(body + 2), (void const * __restrict )fname, (size_t )flen);
# 1864 "function.c"
  *(body + (flen + 2)) = (char )')';
# 1865 "function.c"
  *(body + (flen + 3)) = (char )'\000';
# 1869 "function.c"
  push_new_variable_scope();
# 1871 "function.c"
  i = 0;
  }
  {
# 1871 "function.c"
  while (1) {
    while_continue___2: ;
# 1871 "function.c"
    if (! *argv) {
# 1871 "function.c"
      goto while_break___2;
    }
    {
# 1875 "function.c"
    sprintf((char * __restrict )(num), (char const * __restrict )"%d", i);
# 1876 "function.c"
    tmp___5 = strlen((char const *)(num));
# 1876 "function.c"
    define_variable_in_set(num, (unsigned int )tmp___5, *argv, (enum variable_origin )6,
                           1, current_variable_set_list->set, (struct floc const *)((struct floc *)0));
# 1871 "function.c"
    i ++;
# 1871 "function.c"
    argv ++;
    }
  }
  while_break___2: ;
  }
  {
# 1882 "function.c"
  o = variable_expand_string(o, body, (long )(flen + 3));
# 1884 "function.c"
  pop_variable_scope();
# 1886 "function.c"
  tmp___6 = strlen((char const *)o);
  }
# 1886 "function.c"
  return (o + tmp___6);
}
}
# 1 "getopt.o"
#pragma merger("0","/tmp/cil-DQjlIciI.i","-g,-O0")
# 1 "implicit.o"
#pragma merger("0","/tmp/cil-ElSTEfZg.i","-g,-O0")
# 407 "make.h"
void print_spaces(unsigned int n ) ;
# 432 "make.h"
int vpath_search(char **file , uintmax_t *mtime_ptr ) ;
# 50 "rule.h"
struct rule *pattern_rules ;
# 52 "rule.h"
unsigned int num_pattern_rules ;
# 54 "rule.h"
unsigned int max_pattern_deps ;
# 55 "rule.h"
unsigned int max_pattern_targets ;
# 56 "rule.h"
unsigned int max_pattern_dep_length ;
# 26 "implicit.c"
static int pattern_search(struct file *file , int archive , unsigned int depth , unsigned int recursions ) ;
# 35 "implicit.c"
int try_implicit_rule(struct file *file , unsigned int depth )
{
  char *tmp ;
  int tmp___0 ;
  char *tmp___1 ;
  int tmp___2 ;
  int tmp___3 ;

  {
  {
# 40 "implicit.c"
  while (1) {
    while_continue: ;
# 40 "implicit.c"
    if (8 & db_level) {
      {
# 40 "implicit.c"
      print_spaces(depth);
# 40 "implicit.c"
      tmp = dcgettext((char const *)((void *)0), "Looking for an implicit rule for `%s\'.\n",
                      5);
# 40 "implicit.c"
      printf((char const * __restrict )tmp, file->name);
# 40 "implicit.c"
      fflush(stdout);
      }
    }
# 40 "implicit.c"
    goto while_break;
  }
  while_break: ;
  }
  {
# 47 "implicit.c"
  tmp___0 = pattern_search(file, 0, depth, 0U);
  }
# 47 "implicit.c"
  if (tmp___0) {
# 48 "implicit.c"
    return (1);
  }
  {
# 53 "implicit.c"
  tmp___3 = ar_name(file->name);
  }
# 53 "implicit.c"
  if (tmp___3) {
    {
# 55 "implicit.c"
    while (1) {
      while_continue___0: ;
# 55 "implicit.c"
      if (8 & db_level) {
        {
# 55 "implicit.c"
        print_spaces(depth);
# 55 "implicit.c"
        tmp___1 = dcgettext((char const *)((void *)0), "Looking for archive-member implicit rule for `%s\'.\n",
                            5);
# 55 "implicit.c"
        printf((char const * __restrict )tmp___1, file->name);
# 55 "implicit.c"
        fflush(stdout);
        }
      }
# 55 "implicit.c"
      goto while_break___0;
    }
    while_break___0: ;
    }
    {
# 57 "implicit.c"
    tmp___2 = pattern_search(file, 1, depth, 0U);
    }
# 57 "implicit.c"
    if (tmp___2) {
# 58 "implicit.c"
      return (1);
    }
  }
# 62 "implicit.c"
  return (0);
}
}
# 80 "implicit.c"
static int pattern_search(struct file *file , int archive , unsigned int depth , unsigned int recursions )
{
  char *filename ;
  char *tmp ;
  char *tmp___0 ;
  unsigned int namelen ;
  size_t tmp___1 ;
  char *lastslash ;
  struct file *intermediate_file ;
  struct file **intermediate_files ;
  void *tmp___2 ;
  char **intermediate_patterns ;
  void *tmp___3 ;
  char **found_files ;
  void *tmp___4 ;
  unsigned int deps_found ;
  register char *depname ;
  void *tmp___5 ;
  register char *stem ;
  register unsigned int stemlen ;
  struct rule **tryrules ;
  void *tmp___6 ;
  unsigned int nrules ;
  unsigned int *matches ;
  void *tmp___7 ;
  char *checked_lastslash ;
  void *tmp___8 ;
  unsigned int foundrule ;
  int intermed_ok ;
  int specific_rule_matched ;
  register unsigned int i ;
  register struct rule *rule ;
  register struct dep *dep ;
  char *p ;
  char *vp ;
  int tmp___9 ;
  char *tmp___10 ;
  char *target ;
  char *suffix ;
  int check_lastslash ;
  char *tmp___11 ;
  int tmp___12 ;
  unsigned int difference ;
  int tmp___13 ;
  int tmp___14 ;
  int tmp___15 ;
  register unsigned int j ;
  int check_lastslash___0 ;
  char *tmp___16 ;
  char *tmp___17 ;
  register unsigned int i___0 ;
  char *tmp___18 ;
  char *tmp___19 ;
  char *tmp___20 ;
  char *tmp___21 ;
  char *tmp___22 ;
  char *tmp___23 ;
  int tmp___24 ;
  char *tmp___25 ;
  char *tmp___26 ;
  char *tmp___27 ;
  unsigned int tmp___28 ;
  struct file *tmp___29 ;
  int tmp___30 ;
  char *tmp___31 ;
  unsigned int tmp___32 ;
  int tmp___33 ;
  void *tmp___34 ;
  char *tmp___35 ;
  int tmp___36 ;
  register struct file *f ;
  size_t tmp___37 ;
  unsigned int tmp___38 ;
  register char *s ;
  struct file *imf ;
  register struct file *f___0 ;
  struct file *tmp___39 ;
  char *tmp___40 ;
  unsigned int tmp___41 ;
  char *tmp___42 ;
  struct dep *new ;
  char *tmp___43 ;
  char *tmp___44 ;

  {
# 88 "implicit.c"
  if (archive) {
    {
# 88 "implicit.c"
    tmp = strchr((char const *)file->name, '(');
# 88 "implicit.c"
    tmp___0 = tmp;
    }
  } else {
# 88 "implicit.c"
    tmp___0 = file->name;
  }
  {
# 88 "implicit.c"
  filename = tmp___0;
# 91 "implicit.c"
  tmp___1 = strlen((char const *)filename);
# 91 "implicit.c"
  namelen = (unsigned int )tmp___1;
# 99 "implicit.c"
  intermediate_file = (struct file *)0;
# 102 "implicit.c"
  tmp___2 = __builtin_alloca((unsigned long )max_pattern_deps * sizeof(struct file *));
# 102 "implicit.c"
  intermediate_files = (struct file **)tmp___2;
# 106 "implicit.c"
  tmp___3 = __builtin_alloca((unsigned long )max_pattern_deps * sizeof(char *));
# 106 "implicit.c"
  intermediate_patterns = (char **)tmp___3;
# 110 "implicit.c"
  tmp___4 = __builtin_alloca((unsigned long )max_pattern_deps * sizeof(char *));
# 110 "implicit.c"
  found_files = (char **)tmp___4;
# 112 "implicit.c"
  deps_found = 0U;
# 115 "implicit.c"
  tmp___5 = __builtin_alloca((unsigned long )(namelen + max_pattern_dep_length));
# 115 "implicit.c"
  depname = (char *)tmp___5;
# 118 "implicit.c"
  stem = (char *)0;
# 119 "implicit.c"
  stemlen = 0U;
# 122 "implicit.c"
  tmp___6 = __builtin_alloca((unsigned long )(num_pattern_rules * max_pattern_targets) * sizeof(struct rule *));
# 122 "implicit.c"
  tryrules = (struct rule **)tmp___6;
# 131 "implicit.c"
  tmp___7 = __builtin_alloca((unsigned long )num_pattern_rules * sizeof(unsigned int ));
# 131 "implicit.c"
  matches = (unsigned int *)tmp___7;
# 136 "implicit.c"
  tmp___8 = __builtin_alloca((unsigned long )num_pattern_rules * sizeof(char ));
# 136 "implicit.c"
  checked_lastslash = (char *)tmp___8;
# 147 "implicit.c"
  specific_rule_matched = 0;
# 149 "implicit.c"
  i = 0U;
  }
# 156 "implicit.c"
  if (archive) {
# 157 "implicit.c"
    lastslash = (char *)0;
  } else {
    {
# 156 "implicit.c"
    tmp___9 = ar_name(filename);
    }
# 156 "implicit.c"
    if (tmp___9) {
# 157 "implicit.c"
      lastslash = (char *)0;
    } else {
      {
# 169 "implicit.c"
      lastslash = strrchr((char const *)filename, '/');
      }
# 182 "implicit.c"
      if ((unsigned long )lastslash != (unsigned long )((char *)0)) {
# 182 "implicit.c"
        if ((int )*(lastslash + 1) == 0) {
# 183 "implicit.c"
          lastslash = (char *)0;
        }
      }
    }
  }
# 189 "implicit.c"
  nrules = 0U;
# 190 "implicit.c"
  rule = pattern_rules;
  {
# 190 "implicit.c"
  while (1) {
    while_continue: ;
# 190 "implicit.c"
    if (! ((unsigned long )rule != (unsigned long )((struct rule *)0))) {
# 190 "implicit.c"
      goto while_break;
    }
# 194 "implicit.c"
    if ((unsigned long )rule->deps != (unsigned long )((struct dep *)0)) {
# 194 "implicit.c"
      if ((unsigned long )rule->cmds == (unsigned long )((struct commands *)0)) {
# 195 "implicit.c"
        goto __Cont;
      }
    }
# 199 "implicit.c"
    if (rule->in_use) {
      {
# 201 "implicit.c"
      while (1) {
        while_continue___0: ;
# 201 "implicit.c"
        if (8 & db_level) {
          {
# 201 "implicit.c"
          print_spaces(depth);
# 201 "implicit.c"
          tmp___10 = dcgettext((char const *)((void *)0), "Avoiding implicit rule recursion.\n",
                               5);
# 201 "implicit.c"
          printf((char const * __restrict )tmp___10);
# 201 "implicit.c"
          fflush(stdout);
          }
        }
# 201 "implicit.c"
        goto while_break___0;
      }
      while_break___0: ;
      }
# 202 "implicit.c"
      goto __Cont;
    }
# 205 "implicit.c"
    i = 0U;
    {
# 205 "implicit.c"
    while (1) {
      while_continue___1: ;
# 205 "implicit.c"
      if (! ((unsigned long )*(rule->targets + i) != (unsigned long )((char *)0))) {
# 205 "implicit.c"
        goto while_break___1;
      }
# 207 "implicit.c"
      target = *(rule->targets + i);
# 208 "implicit.c"
      suffix = *(rule->suffixes + i);
# 214 "implicit.c"
      if (recursions > 0U) {
# 214 "implicit.c"
        if ((int )*(target + 1) == 0) {
# 214 "implicit.c"
          if (! rule->terminal) {
# 215 "implicit.c"
            goto __Cont___0;
          }
        }
      }
# 217 "implicit.c"
      if (*(rule->lens + i) > namelen) {
# 219 "implicit.c"
        goto __Cont___0;
      }
# 223 "implicit.c"
      stem = filename + ((suffix - target) - 1L);
# 224 "implicit.c"
      stemlen = (namelen - *(rule->lens + i)) + 1U;
# 234 "implicit.c"
      if ((unsigned long )lastslash != (unsigned long )((char *)0)) {
        {
# 234 "implicit.c"
        tmp___11 = strchr((char const *)target, '/');
        }
# 234 "implicit.c"
        if ((unsigned long )tmp___11 == (unsigned long )((char *)0)) {
# 234 "implicit.c"
          tmp___12 = 1;
        } else {
# 234 "implicit.c"
          tmp___12 = 0;
        }
      } else {
# 234 "implicit.c"
        tmp___12 = 0;
      }
# 234 "implicit.c"
      check_lastslash = tmp___12;
# 236 "implicit.c"
      if (check_lastslash) {
# 240 "implicit.c"
        difference = (unsigned int )((lastslash - filename) + 1L);
# 241 "implicit.c"
        if (difference > stemlen) {
# 242 "implicit.c"
          goto __Cont___0;
        }
# 243 "implicit.c"
        stemlen -= difference;
# 244 "implicit.c"
        stem += difference;
      }
# 248 "implicit.c"
      if (check_lastslash) {
# 250 "implicit.c"
        if ((unsigned long )stem > (unsigned long )(lastslash + 1)) {
          {
# 250 "implicit.c"
          tmp___13 = strncmp((char const *)target, (char const *)(lastslash + 1),
                             (size_t )((stem - lastslash) - 1L));
          }
# 250 "implicit.c"
          if (! (tmp___13 == 0)) {
# 252 "implicit.c"
            goto __Cont___0;
          }
        }
      } else
# 254 "implicit.c"
      if ((unsigned long )stem > (unsigned long )filename) {
        {
# 254 "implicit.c"
        tmp___14 = strncmp((char const *)target, (char const *)filename, (size_t )(stem - filename));
        }
# 254 "implicit.c"
        if (! (tmp___14 == 0)) {
# 256 "implicit.c"
          goto __Cont___0;
        }
      }
# 263 "implicit.c"
      if ((int )*suffix != (int )*(stem + stemlen)) {
# 265 "implicit.c"
        goto __Cont___0;
      } else
# 263 "implicit.c"
      if ((int )*suffix != 0) {
# 263 "implicit.c"
        if (! ((unsigned long )(suffix + 1) == (unsigned long )(stem + (stemlen + 1U)))) {
# 263 "implicit.c"
          if ((int )*(suffix + 1) == (int )*(stem + (stemlen + 1U))) {
# 263 "implicit.c"
            if (! ((int )*(suffix + 1) == 0)) {
              {
# 263 "implicit.c"
              tmp___15 = strcmp((char const *)((suffix + 1) + 1), (char const *)((stem + (stemlen + 1U)) + 1));
              }
# 263 "implicit.c"
              if (tmp___15) {
# 265 "implicit.c"
                goto __Cont___0;
              }
            }
          } else {
# 265 "implicit.c"
            goto __Cont___0;
          }
        }
      }
# 268 "implicit.c"
      if ((int )*(target + 1) != 0) {
# 269 "implicit.c"
        specific_rule_matched = 1;
      }
# 273 "implicit.c"
      if ((unsigned long )rule->deps == (unsigned long )((struct dep *)0)) {
# 273 "implicit.c"
        if ((unsigned long )rule->cmds == (unsigned long )((struct commands *)0)) {
# 274 "implicit.c"
          goto __Cont___0;
        }
      }
# 279 "implicit.c"
      *(tryrules + nrules) = rule;
# 280 "implicit.c"
      *(matches + nrules) = i;
# 281 "implicit.c"
      *(checked_lastslash + nrules) = (char )check_lastslash;
# 282 "implicit.c"
      nrules ++;
      __Cont___0:
# 205 "implicit.c"
      i ++;
    }
    while_break___1: ;
    }
    __Cont:
# 190 "implicit.c"
    rule = rule->next;
  }
  while_break: ;
  }
# 288 "implicit.c"
  if (specific_rule_matched) {
# 289 "implicit.c"
    i = 0U;
    {
# 289 "implicit.c"
    while (1) {
      while_continue___2: ;
# 289 "implicit.c"
      if (! (i < nrules)) {
# 289 "implicit.c"
        goto while_break___2;
      }
# 290 "implicit.c"
      if (! (*(tryrules + i))->terminal) {
# 293 "implicit.c"
        j = 0U;
        {
# 293 "implicit.c"
        while (1) {
          while_continue___3: ;
# 293 "implicit.c"
          if (! ((unsigned long )*((*(tryrules + i))->targets + j) != (unsigned long )((char *)0))) {
# 293 "implicit.c"
            goto while_break___3;
          }
# 294 "implicit.c"
          if ((int )*(*((*(tryrules + i))->targets + j) + 1) == 0) {
# 295 "implicit.c"
            goto while_break___3;
          }
# 293 "implicit.c"
          j ++;
        }
        while_break___3: ;
        }
# 296 "implicit.c"
        if ((unsigned long )*((*(tryrules + i))->targets + j) != (unsigned long )((char *)0)) {
# 297 "implicit.c"
          *(tryrules + i) = (struct rule *)0;
        }
      }
# 289 "implicit.c"
      i ++;
    }
    while_break___2: ;
    }
  }
# 301 "implicit.c"
  intermed_ok = 0;
  {
# 301 "implicit.c"
  while (1) {
    while_continue___4: ;
# 301 "implicit.c"
    if (! (intermed_ok == ! (! intermed_ok))) {
# 301 "implicit.c"
      goto while_break___4;
    }
# 307 "implicit.c"
    i = 0U;
    {
# 307 "implicit.c"
    while (1) {
      while_continue___5: ;
# 307 "implicit.c"
      if (! (i < nrules)) {
# 307 "implicit.c"
        goto while_break___5;
      }
# 311 "implicit.c"
      rule = *(tryrules + i);
# 315 "implicit.c"
      if ((unsigned long )rule == (unsigned long )((struct rule *)0)) {
# 316 "implicit.c"
        goto __Cont___1;
      }
# 320 "implicit.c"
      if (intermed_ok) {
# 320 "implicit.c"
        if (rule->terminal) {
# 321 "implicit.c"
          goto __Cont___1;
        }
      }
# 325 "implicit.c"
      rule->in_use = (char)1;
# 329 "implicit.c"
      stem = (filename + (*(rule->suffixes + *(matches + i)) - *(rule->targets + *(matches + i)))) - 1;
# 331 "implicit.c"
      stemlen = (namelen - *(rule->lens + *(matches + i))) + 1U;
# 332 "implicit.c"
      check_lastslash___0 = (int )*(checked_lastslash + i);
# 333 "implicit.c"
      if (check_lastslash___0) {
# 335 "implicit.c"
        stem += (lastslash - filename) + 1L;
# 336 "implicit.c"
        stemlen = (unsigned int )((long )stemlen - ((lastslash - filename) + 1L));
      }
      {
# 339 "implicit.c"
      while (1) {
        while_continue___6: ;
# 339 "implicit.c"
        if (8 & db_level) {
          {
# 339 "implicit.c"
          print_spaces(depth);
# 339 "implicit.c"
          tmp___16 = dcgettext((char const *)((void *)0), "Trying pattern rule with stem `%.*s\'.\n",
                               5);
# 339 "implicit.c"
          printf((char const * __restrict )tmp___16, (int )stemlen, stem);
# 339 "implicit.c"
          fflush(stdout);
          }
        }
# 339 "implicit.c"
        goto while_break___6;
      }
      while_break___6: ;
      }
# 344 "implicit.c"
      deps_found = 0U;
# 345 "implicit.c"
      dep = rule->deps;
      {
# 345 "implicit.c"
      while (1) {
        while_continue___7: ;
# 345 "implicit.c"
        if (! ((unsigned long )dep != (unsigned long )((struct dep *)0))) {
# 345 "implicit.c"
          goto while_break___7;
        }
# 348 "implicit.c"
        if ((unsigned long )dep->name == (unsigned long )((char *)0)) {
# 348 "implicit.c"
          tmp___17 = (dep->file)->name;
        } else {
# 348 "implicit.c"
          tmp___17 = dep->name;
        }
        {
# 348 "implicit.c"
        p = strchr((char const *)tmp___17, '%');
        }
# 349 "implicit.c"
        if ((unsigned long )p != (unsigned long )((char *)0)) {
# 352 "implicit.c"
          if (check_lastslash___0) {
            {
# 355 "implicit.c"
            i___0 = (unsigned int )((lastslash - filename) + 1L);
# 356 "implicit.c"
            memmove((void *)depname, (void const *)filename, (size_t )i___0);
            }
          } else {
# 359 "implicit.c"
            i___0 = 0U;
          }
# 360 "implicit.c"
          if ((unsigned long )dep->name == (unsigned long )((char *)0)) {
# 360 "implicit.c"
            tmp___18 = (dep->file)->name;
          } else {
# 360 "implicit.c"
            tmp___18 = dep->name;
          }
# 360 "implicit.c"
          if ((unsigned long )dep->name == (unsigned long )((char *)0)) {
# 360 "implicit.c"
            tmp___19 = (dep->file)->name;
          } else {
# 360 "implicit.c"
            tmp___19 = dep->name;
          }
          {
# 360 "implicit.c"
          memmove((void *)(depname + i___0), (void const *)tmp___19, (size_t )(p - tmp___18));
          }
# 361 "implicit.c"
          if ((unsigned long )dep->name == (unsigned long )((char *)0)) {
# 361 "implicit.c"
            tmp___20 = (dep->file)->name;
          } else {
# 361 "implicit.c"
            tmp___20 = dep->name;
          }
          {
# 361 "implicit.c"
          i___0 = (unsigned int )((long )i___0 + (p - tmp___20));
# 362 "implicit.c"
          memmove((void *)(depname + i___0), (void const *)stem, (size_t )stemlen);
# 363 "implicit.c"
          i___0 += stemlen;
# 364 "implicit.c"
          strcpy((char * __restrict )(depname + i___0), (char const * __restrict )(p + 1));
# 365 "implicit.c"
          p = depname;
          }
        } else
# 368 "implicit.c"
        if ((unsigned long )dep->name == (unsigned long )((char *)0)) {
# 368 "implicit.c"
          p = (dep->file)->name;
        } else {
# 368 "implicit.c"
          p = dep->name;
        }
        {
# 372 "implicit.c"
        tmp___24 = file_impossible_p(p);
        }
# 372 "implicit.c"
        if (tmp___24) {
          {
# 378 "implicit.c"
          while (1) {
            while_continue___8: ;
# 378 "implicit.c"
            if (8 & db_level) {
              {
# 378 "implicit.c"
              print_spaces(depth);
              }
# 378 "implicit.c"
              if ((unsigned long )p == (unsigned long )depname) {
                {
# 378 "implicit.c"
                tmp___21 = dcgettext((char const *)((void *)0), "Rejecting impossible implicit prerequisite `%s\'.\n",
                                     5);
# 378 "implicit.c"
                tmp___23 = tmp___21;
                }
              } else {
                {
# 378 "implicit.c"
                tmp___22 = dcgettext((char const *)((void *)0), "Rejecting impossible rule prerequisite `%s\'.\n",
                                     5);
# 378 "implicit.c"
                tmp___23 = tmp___22;
                }
              }
              {
# 378 "implicit.c"
              printf((char const * __restrict )tmp___23, p);
# 378 "implicit.c"
              fflush(stdout);
              }
            }
# 378 "implicit.c"
            goto while_break___8;
          }
          while_break___8: ;
          }
# 383 "implicit.c"
          *(tryrules + i) = (struct rule *)0;
# 384 "implicit.c"
          goto while_break___7;
        }
# 387 "implicit.c"
        *(intermediate_files + deps_found) = (struct file *)0;
        {
# 389 "implicit.c"
        while (1) {
          while_continue___9: ;
# 389 "implicit.c"
          if (8 & db_level) {
            {
# 389 "implicit.c"
            print_spaces(depth);
            }
# 389 "implicit.c"
            if ((unsigned long )p == (unsigned long )depname) {
              {
# 389 "implicit.c"
              tmp___25 = dcgettext((char const *)((void *)0), "Trying implicit prerequisite `%s\'.\n",
                                   5);
# 389 "implicit.c"
              tmp___27 = tmp___25;
              }
            } else {
              {
# 389 "implicit.c"
              tmp___26 = dcgettext((char const *)((void *)0), "Trying rule prerequisite `%s\'.\n",
                                   5);
# 389 "implicit.c"
              tmp___27 = tmp___26;
              }
            }
            {
# 389 "implicit.c"
            printf((char const * __restrict )tmp___27, p);
# 389 "implicit.c"
            fflush(stdout);
            }
          }
# 389 "implicit.c"
          goto while_break___9;
        }
        while_break___9: ;
        }
# 401 "implicit.c"
        if (! dep->changed) {
# 401 "implicit.c"
          goto _L;
        } else
# 401 "implicit.c"
        if (check_lastslash___0) {
          _L:
          {
# 401 "implicit.c"
          tmp___29 = lookup_file(p);
          }
# 401 "implicit.c"
          if ((unsigned long )tmp___29 != (unsigned long )((struct file *)0)) {
            {
# 404 "implicit.c"
            tmp___28 = deps_found;
# 404 "implicit.c"
            deps_found ++;
# 404 "implicit.c"
            *(found_files + tmp___28) = xstrdup((char const *)p);
            }
# 405 "implicit.c"
            goto __Cont___2;
          } else {
            {
# 401 "implicit.c"
            tmp___30 = file_exists_p(p);
            }
# 401 "implicit.c"
            if (tmp___30) {
              {
# 404 "implicit.c"
              tmp___28 = deps_found;
# 404 "implicit.c"
              deps_found ++;
# 404 "implicit.c"
              *(found_files + tmp___28) = xstrdup((char const *)p);
              }
# 405 "implicit.c"
              goto __Cont___2;
            }
          }
        }
        {
# 409 "implicit.c"
        vp = p;
# 410 "implicit.c"
        tmp___33 = vpath_search(& vp, (uintmax_t *)0);
        }
# 410 "implicit.c"
        if (tmp___33) {
          {
# 412 "implicit.c"
          while (1) {
            while_continue___10: ;
# 412 "implicit.c"
            if (8 & db_level) {
              {
# 412 "implicit.c"
              print_spaces(depth);
# 412 "implicit.c"
              tmp___31 = dcgettext((char const *)((void *)0), "Found prerequisite `%s\' as VPATH `%s\'\n",
                                   5);
# 412 "implicit.c"
              printf((char const * __restrict )tmp___31, p, vp);
# 412 "implicit.c"
              fflush(stdout);
              }
            }
# 412 "implicit.c"
            goto while_break___10;
          }
          while_break___10: ;
          }
          {
# 414 "implicit.c"
          strcpy((char * __restrict )vp, (char const * __restrict )p);
# 415 "implicit.c"
          tmp___32 = deps_found;
# 415 "implicit.c"
          deps_found ++;
# 415 "implicit.c"
          *(found_files + tmp___32) = vp;
          }
# 416 "implicit.c"
          goto __Cont___2;
        }
# 423 "implicit.c"
        if (intermed_ok) {
# 425 "implicit.c"
          if ((unsigned long )intermediate_file == (unsigned long )((struct file *)0)) {
            {
# 426 "implicit.c"
            tmp___34 = __builtin_alloca(sizeof(struct file ));
# 426 "implicit.c"
            intermediate_file = (struct file *)tmp___34;
            }
          }
          {
# 429 "implicit.c"
          while (1) {
            while_continue___11: ;
# 429 "implicit.c"
            if (8 & db_level) {
              {
# 429 "implicit.c"
              print_spaces(depth);
# 429 "implicit.c"
              tmp___35 = dcgettext((char const *)((void *)0), "Looking for a rule with intermediate file `%s\'.\n",
                                   5);
# 429 "implicit.c"
              printf((char const * __restrict )tmp___35, p);
# 429 "implicit.c"
              fflush(stdout);
              }
            }
# 429 "implicit.c"
            goto while_break___11;
          }
          while_break___11: ;
          }
          {
# 433 "implicit.c"
          memset((void *)((char *)intermediate_file), 0, sizeof(struct file ));
# 434 "implicit.c"
          intermediate_file->name = p;
# 435 "implicit.c"
          tmp___36 = pattern_search(intermediate_file, 0, depth + 1U, recursions + 1U);
          }
# 435 "implicit.c"
          if (tmp___36) {
            {
# 438 "implicit.c"
            p = xstrdup((char const *)p);
# 439 "implicit.c"
            *(intermediate_patterns + deps_found) = intermediate_file->name;
# 441 "implicit.c"
            intermediate_file->name = p;
# 442 "implicit.c"
            *(intermediate_files + deps_found) = intermediate_file;
# 443 "implicit.c"
            intermediate_file = (struct file *)0;
# 447 "implicit.c"
            *(found_files + deps_found) = xstrdup((char const *)p);
# 448 "implicit.c"
            deps_found ++;
            }
# 449 "implicit.c"
            goto __Cont___2;
          }
          {
# 455 "implicit.c"
          file_impossible(p);
          }
        }
# 460 "implicit.c"
        goto while_break___7;
        __Cont___2:
# 345 "implicit.c"
        dep = dep->next;
      }
      while_break___7: ;
      }
# 464 "implicit.c"
      rule->in_use = (char)0;
# 466 "implicit.c"
      if ((unsigned long )dep != (unsigned long )((struct dep *)0)) {
        {
# 471 "implicit.c"
        while (1) {
          while_continue___12: ;
# 471 "implicit.c"
          tmp___38 = deps_found;
# 471 "implicit.c"
          deps_found --;
# 471 "implicit.c"
          if (! (tmp___38 > 0U)) {
# 471 "implicit.c"
            goto while_break___12;
          }
          {
# 473 "implicit.c"
          f = *(intermediate_files + deps_found);
# 474 "implicit.c"
          free((void *)*(found_files + deps_found));
          }
# 475 "implicit.c"
          if ((unsigned long )f != (unsigned long )((struct file *)0)) {
# 475 "implicit.c"
            if ((unsigned long )f->stem < (unsigned long )f->name) {
              {
# 478 "implicit.c"
              free((void *)f->stem);
              }
            } else {
              {
# 475 "implicit.c"
              tmp___37 = strlen((char const *)f->name);
              }
# 475 "implicit.c"
              if ((unsigned long )f->stem > (unsigned long )(f->name + tmp___37)) {
                {
# 478 "implicit.c"
                free((void *)f->stem);
                }
              }
            }
          }
        }
        while_break___12: ;
        }
      } else {
# 483 "implicit.c"
        goto while_break___5;
      }
      __Cont___1:
# 307 "implicit.c"
      i ++;
    }
    while_break___5: ;
    }
# 488 "implicit.c"
    if (i < nrules) {
# 489 "implicit.c"
      goto while_break___4;
    }
# 491 "implicit.c"
    rule = (struct rule *)0;
# 301 "implicit.c"
    intermed_ok ++;
  }
  while_break___4: ;
  }
# 496 "implicit.c"
  if ((unsigned long )rule == (unsigned long )((struct rule *)0)) {
# 497 "implicit.c"
    return (0);
  }
# 499 "implicit.c"
  foundrule = i;
# 504 "implicit.c"
  if (recursions > 0U) {
# 506 "implicit.c"
    file->name = *(rule->targets + *(matches + foundrule));
  }
  {
# 512 "implicit.c"
  while (1) {
    while_continue___13: ;
# 512 "implicit.c"
    tmp___41 = deps_found;
# 512 "implicit.c"
    deps_found --;
# 512 "implicit.c"
    if (! (tmp___41 > 0U)) {
# 512 "implicit.c"
      goto while_break___13;
    }
# 516 "implicit.c"
    if ((unsigned long )*(intermediate_files + deps_found) != (unsigned long )((struct file *)0)) {
      {
# 525 "implicit.c"
      imf = *(intermediate_files + deps_found);
# 526 "implicit.c"
      tmp___39 = enter_file(imf->name);
# 526 "implicit.c"
      f___0 = tmp___39;
# 527 "implicit.c"
      f___0->deps = imf->deps;
# 528 "implicit.c"
      f___0->cmds = imf->cmds;
# 529 "implicit.c"
      f___0->stem = imf->stem;
# 530 "implicit.c"
      f___0->also_make = imf->also_make;
# 531 "implicit.c"
      imf = lookup_file(*(intermediate_patterns + deps_found));
      }
# 532 "implicit.c"
      if ((unsigned long )imf != (unsigned long )((struct file *)0)) {
# 532 "implicit.c"
        if (imf->precious) {
# 533 "implicit.c"
          f___0->precious = 1U;
        }
      }
# 534 "implicit.c"
      f___0->intermediate = 1U;
# 535 "implicit.c"
      f___0->tried_implicit = 1U;
# 536 "implicit.c"
      dep = f___0->deps;
      {
# 536 "implicit.c"
      while (1) {
        while_continue___14: ;
# 536 "implicit.c"
        if (! ((unsigned long )dep != (unsigned long )((struct dep *)0))) {
# 536 "implicit.c"
          goto while_break___14;
        }
        {
# 538 "implicit.c"
        dep->file = enter_file(dep->name);
        }
# 540 "implicit.c"
        if ((unsigned long )dep->name != (unsigned long )(dep->file)->name) {
          {
# 541 "implicit.c"
          free((void *)dep->name);
          }
        }
# 542 "implicit.c"
        dep->name = (char *)0;
# 543 "implicit.c"
        (dep->file)->tried_implicit |= (unsigned int )dep->changed;
# 536 "implicit.c"
        dep = dep->next;
      }
      while_break___14: ;
      }
# 545 "implicit.c"
      num_intermediates ++;
    }
    {
# 548 "implicit.c"
    tmp___40 = xmalloc((unsigned int )sizeof(struct dep ));
# 548 "implicit.c"
    dep = (struct dep *)tmp___40;
# 549 "implicit.c"
    s = *(found_files + deps_found);
    }
# 550 "implicit.c"
    if (recursions == 0U) {
      {
# 552 "implicit.c"
      dep->name = (char *)0;
# 553 "implicit.c"
      dep->file = lookup_file(s);
      }
# 554 "implicit.c"
      if ((unsigned long )dep->file == (unsigned long )((struct file *)0)) {
        {
# 556 "implicit.c"
        dep->file = enter_file(s);
        }
      } else {
        {
# 560 "implicit.c"
        free((void *)s);
        }
      }
    } else {
# 564 "implicit.c"
      dep->name = s;
# 565 "implicit.c"
      dep->file = (struct file *)0;
# 566 "implicit.c"
      dep->changed = 0;
    }
# 568 "implicit.c"
    if ((unsigned long )*(intermediate_files + deps_found) == (unsigned long )((struct file *)0)) {
# 568 "implicit.c"
      if ((*(tryrules + foundrule))->terminal) {
# 575 "implicit.c"
        if ((unsigned long )dep->file == (unsigned long )((struct file *)0)) {
# 576 "implicit.c"
          dep->changed = 1;
        } else {
# 578 "implicit.c"
          (dep->file)->tried_implicit = 1U;
        }
      }
    }
# 580 "implicit.c"
    dep->next = file->deps;
# 581 "implicit.c"
    file->deps = dep;
  }
  while_break___13: ;
  }
# 584 "implicit.c"
  if (! *(checked_lastslash + foundrule)) {
    {
# 587 "implicit.c"
    file->stem = savestring((char const *)stem, stemlen);
    }
  } else {
    {
# 592 "implicit.c"
    tmp___42 = xmalloc((unsigned int )((((lastslash + 1) - filename) + (long )stemlen) + 1L));
# 592 "implicit.c"
    file->stem = tmp___42;
# 594 "implicit.c"
    memmove((void *)file->stem, (void const *)filename, (size_t )((lastslash + 1) - filename));
# 595 "implicit.c"
    memmove((void *)(file->stem + ((lastslash + 1) - filename)), (void const *)stem,
            (size_t )stemlen);
# 596 "implicit.c"
    *(file->stem + (((lastslash + 1) - filename) + (long )stemlen)) = (char )'\000';
    }
  }
# 599 "implicit.c"
  file->cmds = rule->cmds;
# 604 "implicit.c"
  if ((unsigned long )*(rule->targets + 1) != (unsigned long )((char *)0)) {
# 605 "implicit.c"
    i = 0U;
    {
# 605 "implicit.c"
    while (1) {
      while_continue___15: ;
# 605 "implicit.c"
      if (! ((unsigned long )*(rule->targets + i) != (unsigned long )((char *)0))) {
# 605 "implicit.c"
        goto while_break___15;
      }
# 606 "implicit.c"
      if (i != *(matches + foundrule)) {
        {
# 608 "implicit.c"
        tmp___43 = xmalloc((unsigned int )sizeof(struct dep ));
# 608 "implicit.c"
        new = (struct dep *)tmp___43;
# 609 "implicit.c"
        tmp___44 = xmalloc((*(rule->lens + i) + stemlen) + 1U);
# 609 "implicit.c"
        p = tmp___44;
# 609 "implicit.c"
        new->name = p;
# 610 "implicit.c"
        memmove((void *)p, (void const *)*(rule->targets + i), (size_t )((*(rule->suffixes + i) - *(rule->targets + i)) - 1L));
# 612 "implicit.c"
        p += (*(rule->suffixes + i) - *(rule->targets + i)) - 1L;
# 613 "implicit.c"
        memmove((void *)p, (void const *)stem, (size_t )stemlen);
# 614 "implicit.c"
        p += stemlen;
# 615 "implicit.c"
        memmove((void *)p, (void const *)*(rule->suffixes + i), (size_t )(((long )*(rule->lens + i) - (*(rule->suffixes + i) - *(rule->targets + i))) + 1L));
# 617 "implicit.c"
        new->file = enter_file(new->name);
# 618 "implicit.c"
        new->next = file->also_make;
# 619 "implicit.c"
        file->also_make = new;
        }
      }
# 605 "implicit.c"
      i ++;
    }
    while_break___15: ;
    }
  }
# 623 "implicit.c"
  return (1);
}
}
# 1 "job.o"
#pragma merger("0","/tmp/cil-2QdUWNY1.i","-g,-O0")
# 196 "/usr/include/signal.h"
extern __attribute__((__nothrow__)) int ( __attribute__((__nonnull__(1), __leaf__)) sigemptyset)(sigset_t *__set ) ;
# 229 "/usr/include/signal.h"
extern __attribute__((__nothrow__)) int ( __attribute__((__leaf__)) sigprocmask)(int __how ,
                                                                                  sigset_t const * __restrict __set ,
                                                                                  sigset_t * __restrict __oset ) ;
# 534 "/usr/include/unistd.h"
extern __attribute__((__nothrow__)) int ( __attribute__((__leaf__)) dup)(int __fd ) ;
# 537 "/usr/include/unistd.h"
extern __attribute__((__nothrow__)) int ( __attribute__((__leaf__)) dup2)(int __fd ,
                                                                           int __fd2 ) ;
# 581 "/usr/include/unistd.h"
extern __attribute__((__nothrow__)) int ( __attribute__((__nonnull__(1,2), __leaf__)) execvp)(char const *__file ,
                                                                                               char * const *__argv ) ;
# 606 "/usr/include/unistd.h"
extern __attribute__((__noreturn__)) void _exit(int __status ) ;
# 631 "/usr/include/stdlib.h"
extern __attribute__((__nothrow__)) char *( __attribute__((__nonnull__(1), __leaf__)) getenv)(char const *__name ) ;
# 1006 "/usr/include/stdlib.h"
extern __attribute__((__nothrow__)) int ( __attribute__((__nonnull__(1), __leaf__)) getloadavg)(double *loadavg ,
                                                                                                 int nelem ) ;
# 446 "/usr/include/string.h"
extern __attribute__((__nothrow__)) char *( __attribute__((__leaf__)) strsignal)(int __sig ) ;
# 377 "make.h"
void message(int prefix , char const *fmt , ...) ;
# 389 "make.h"
 __attribute__((__noreturn__)) void die(int status ) ;
# 437 "make.h"
void user_access(void) ;
# 438 "make.h"
void make_access(void) ;
# 439 "make.h"
void child_access(void) ;
# 470 "make.h"
int keep_going_flag ;
# 478 "make.h"
int batch_mode_shell ;
# 480 "make.h"
unsigned int job_slots ;
# 481 "make.h"
int job_fds[2] ;
# 482 "make.h"
int job_rfd ;
# 484 "make.h"
double max_load_average ;
# 494 "make.h"
unsigned int commands_started ;
# 55 "job.h"
void start_waiting_jobs(void) ;
# 66 "job.h"
void exec_command(char **argv , char **envp ) ;
# 71 "job.h"
void block_sigs(void) ;
# 73 "job.h"
void unblock_sigs(void) ;
# 135 "variable.h"
char **target_environment(struct file *file ) ;
# 53 "job.c"
char default_shell[8] =
# 53 "job.c"
  { (char )'/', (char )'b', (char )'i', (char )'n',
        (char )'/', (char )'s', (char )'h', (char )'\000'};
# 56 "job.c"
int batch_mode_shell = 0;
# 147 "/usr/include/fcntl.h"
extern int fcntl(int __fd , int __cmd , ...) ;
# 77 "/usr/include/x86_64-linux-gnu/sys/wait.h"
extern __pid_t wait(int *__stat_loc ) ;
# 100 "/usr/include/x86_64-linux-gnu/sys/wait.h"
extern __pid_t waitpid(__pid_t __pid , int *__stat_loc , int __options ) ;
# 190 "job.c"
int start_remote_job(char **argv , char **envp , int stdin_fd , int *is_remote , int *id_ptr ,
                     int *used_stdin ) ;
# 192 "job.c"
int start_remote_job_p(int first_p ) ;
# 193 "job.c"
int remote_status(int *exit_code_ptr , int *signal_ptr , int *coredump_ptr , int block ) ;
# 196 "job.c"
void child_handler(int sig ) ;
# 197 "job.c"
static void free_child(struct child *child ) ;
# 198 "job.c"
static void start_job_command(struct child *child ) ;
# 199 "job.c"
static int load_too_high(void) ;
# 200 "job.c"
static int job_next_command(struct child *child ) ;
# 201 "job.c"
static int start_waiting_job(struct child *c ) ;
# 208 "job.c"
struct child *children = (struct child *)0;
# 212 "job.c"
unsigned int job_slots_used = 0U;
# 216 "job.c"
static int good_stdin_used = 0;
# 220 "job.c"
static struct child *waiting_jobs = (struct child *)0;
# 224 "job.c"
int unixy_shell = 1;
# 241 "job.c"
static void child_error(char *target_name , int exit_code , int exit_sig , int coredump ,
                        int ignored )
{
  char *tmp ;
  char *tmp___0 ;
  char *tmp___1 ;
  char *tmp___2 ;
  char const *tmp___3 ;
  char *tmp___4 ;

  {
# 247 "job.c"
  if (ignored) {
# 247 "job.c"
    if (silent_flag) {
# 248 "job.c"
      return;
    }
  }
# 257 "job.c"
  if (exit_sig == 0) {
# 258 "job.c"
    if (ignored) {
      {
# 258 "job.c"
      tmp = dcgettext((char const *)((void *)0), "[%s] Error %d (ignored)", 5);
# 258 "job.c"
      tmp___1 = tmp;
      }
    } else {
      {
# 258 "job.c"
      tmp___0 = dcgettext((char const *)((void *)0), "*** [%s] Error %d", 5);
# 258 "job.c"
      tmp___1 = tmp___0;
      }
    }
    {
# 258 "job.c"
    error((struct floc const *)((struct floc *)0), (char const *)tmp___1, target_name,
          exit_code);
    }
  } else {
# 262 "job.c"
    if (coredump) {
      {
# 262 "job.c"
      tmp___2 = dcgettext((char const *)((void *)0), " (core dumped)", 5);
# 262 "job.c"
      tmp___3 = (char const *)tmp___2;
      }
    } else {
# 262 "job.c"
      tmp___3 = "";
    }
    {
# 262 "job.c"
    tmp___4 = strsignal(exit_sig);
# 262 "job.c"
    error((struct floc const *)((struct floc *)0), "*** [%s] %s%s", target_name,
          tmp___4, tmp___3);
    }
  }
# 266 "job.c"
  return;
}
}
# 390 "job.c"
static unsigned int dead_children = 0U;
# 392 "job.c"
void child_handler(int sig )
{
  char *tmp ;

  {
# 396 "job.c"
  dead_children ++;
# 398 "job.c"
  if (job_rfd >= 0) {
    {
# 400 "job.c"
    close(job_rfd);
# 401 "job.c"
    job_rfd = -1;
    }
  }
  {
# 404 "job.c"
  while (1) {
    while_continue: ;
# 404 "job.c"
    if (4 & db_level) {
      {
# 404 "job.c"
      tmp = dcgettext((char const *)((void *)0), "Got a SIGCHLD; %u unreaped children.\n",
                      5);
# 404 "job.c"
      printf((char const * __restrict )tmp, dead_children);
# 404 "job.c"
      fflush(stdout);
      }
    }
# 404 "job.c"
    goto while_break;
  }
  while_break: ;
  }
# 405 "job.c"
  return;
}
}
# 666 "job.c"
static int delete_on_error = -1;
# 417 "job.c"
void reap_children(int block , int err )
{
  int status ;
  int reap_more ;
  int remote ;
  register int pid ;
  int exit_code ;
  int exit_sig ;
  int coredump ;
  register struct child *lastc ;
  register struct child *c ;
  int child_failed ;
  int any_remote ;
  int any_local ;
  char *tmp ;
  char *tmp___0 ;
  char const *tmp___1 ;
  char *tmp___2 ;
  int *tmp___3 ;
  int *tmp___4 ;
  int tmp___5 ;
  char *tmp___6 ;
  char const *tmp___7 ;
  char *tmp___8 ;
  char *tmp___9 ;
  char *tmp___10 ;
  char *tmp___11 ;
  struct file *f ;
  struct file *tmp___12 ;
  int tmp___13 ;
  int tmp___14 ;
  int tmp___15 ;
  char *tmp___16 ;
  char const *tmp___17 ;
  char *tmp___18 ;

  {
# 423 "job.c"
  reap_more = 1;
  {
# 439 "job.c"
  while (1) {
    while_continue: ;
# 439 "job.c"
    if ((unsigned long )children != (unsigned long )((struct child *)0)) {
# 439 "job.c"
      goto _L___1;
    } else
# 439 "job.c"
    if (shell_function_pid != 0) {
      _L___1:
# 439 "job.c"
      if (! block) {
# 439 "job.c"
        if (! reap_more) {
# 439 "job.c"
          goto while_break;
        }
      }
    } else {
# 439 "job.c"
      goto while_break;
    }
# 442 "job.c"
    remote = 0;
# 449 "job.c"
    if (err) {
# 449 "job.c"
      if (block) {
        {
# 452 "job.c"
        fflush(stdout);
# 453 "job.c"
        tmp = dcgettext((char const *)((void *)0), "*** Waiting for unfinished jobs....",
                        5);
# 453 "job.c"
        error((struct floc const *)((struct floc *)0), (char const *)tmp);
        }
      }
    }
# 473 "job.c"
    if (dead_children > 0U) {
# 474 "job.c"
      dead_children --;
    }
# 476 "job.c"
    any_remote = 0;
# 477 "job.c"
    any_local = shell_function_pid != 0;
# 478 "job.c"
    c = children;
    {
# 478 "job.c"
    while (1) {
      while_continue___0: ;
# 478 "job.c"
      if (! ((unsigned long )c != (unsigned long )((struct child *)0))) {
# 478 "job.c"
        goto while_break___0;
      }
# 480 "job.c"
      any_remote = (int )((unsigned int )any_remote | c->remote);
# 481 "job.c"
      any_local |= ! c->remote;
      {
# 482 "job.c"
      while (1) {
        while_continue___1: ;
# 482 "job.c"
        if (4 & db_level) {
# 482 "job.c"
          if (c->remote) {
            {
# 482 "job.c"
            tmp___0 = dcgettext((char const *)((void *)0), " (remote)", 5);
# 482 "job.c"
            tmp___1 = (char const *)tmp___0;
            }
          } else {
# 482 "job.c"
            tmp___1 = "";
          }
          {
# 482 "job.c"
          tmp___2 = dcgettext((char const *)((void *)0), "Live child 0x%08lx (%s) PID %ld %s\n",
                              5);
# 482 "job.c"
          printf((char const * __restrict )tmp___2, (unsigned long )c, (c->file)->name,
                 (long )c->pid, tmp___1);
# 482 "job.c"
          fflush(stdout);
          }
        }
# 482 "job.c"
        goto while_break___1;
      }
      while_break___1: ;
      }
# 478 "job.c"
      c = c->next;
    }
    while_break___0: ;
    }
# 491 "job.c"
    if (any_remote) {
      {
# 492 "job.c"
      pid = remote_status(& exit_code, & exit_sig, & coredump, 0);
      }
    } else {
# 494 "job.c"
      pid = 0;
    }
# 496 "job.c"
    if (pid > 0) {
# 498 "job.c"
      remote = 1;
    } else
# 499 "job.c"
    if (pid < 0) {
      remote_status_lose:
      {
# 503 "job.c"
      tmp___3 = __errno_location();
      }
# 503 "job.c"
      if (*tmp___3 == 4) {
# 504 "job.c"
        goto while_continue;
      }
      {
# 506 "job.c"
      pfatal_with_name((char *)"remote_status");
      }
    } else {
# 512 "job.c"
      if (any_local) {
        local_wait:
# 520 "job.c"
        if (! block) {
          {
# 521 "job.c"
          pid = waitpid(-1, & status, 1);
          }
        } else {
          {
# 524 "job.c"
          pid = wait(& status);
          }
        }
      } else {
# 528 "job.c"
        pid = 0;
      }
# 530 "job.c"
      if (pid < 0) {
        {
# 533 "job.c"
        tmp___4 = __errno_location();
        }
# 533 "job.c"
        if (*tmp___4 == 4) {
# 534 "job.c"
          goto local_wait;
        }
        {
# 537 "job.c"
        pfatal_with_name((char *)"wait");
        }
      } else
# 539 "job.c"
      if (pid > 0) {
# 542 "job.c"
        exit_code = (status & 65280) >> 8;
# 543 "job.c"
        if ((int )((signed char )((status & 127) + 1)) >> 1 > 0) {
# 543 "job.c"
          exit_sig = status & 127;
        } else {
# 543 "job.c"
          exit_sig = 0;
        }
# 544 "job.c"
        coredump = status & 128;
      } else {
# 549 "job.c"
        reap_more = 0;
# 551 "job.c"
        if (! block) {
# 552 "job.c"
          goto while_break;
        } else
# 551 "job.c"
        if (! any_remote) {
# 552 "job.c"
          goto while_break;
        }
        {
# 555 "job.c"
        pid = remote_status(& exit_code, & exit_sig, & coredump, 1);
        }
# 556 "job.c"
        if (pid < 0) {
# 557 "job.c"
          goto remote_status_lose;
        } else
# 558 "job.c"
        if (pid == 0) {
# 560 "job.c"
          goto while_break;
        }
# 563 "job.c"
        remote = 1;
      }
    }
# 617 "job.c"
    if (! remote) {
# 617 "job.c"
      if (pid == shell_function_pid) {
# 620 "job.c"
        if (exit_sig == 0) {
# 620 "job.c"
          if (exit_code == 127) {
# 621 "job.c"
            shell_function_completed = -1;
          } else {
# 623 "job.c"
            shell_function_completed = 1;
          }
        } else {
# 623 "job.c"
          shell_function_completed = 1;
        }
# 624 "job.c"
        goto while_break;
      }
    }
# 627 "job.c"
    if (exit_sig != 0) {
# 627 "job.c"
      tmp___5 = 1;
    } else
# 627 "job.c"
    if (exit_code != 0) {
# 627 "job.c"
      tmp___5 = 1;
    } else {
# 627 "job.c"
      tmp___5 = 0;
    }
# 627 "job.c"
    child_failed = tmp___5;
# 630 "job.c"
    lastc = (struct child *)0;
# 631 "job.c"
    c = children;
    {
# 631 "job.c"
    while (1) {
      while_continue___2: ;
# 631 "job.c"
      if (! ((unsigned long )c != (unsigned long )((struct child *)0))) {
# 631 "job.c"
        goto while_break___2;
      }
# 632 "job.c"
      if (c->remote == (unsigned int )remote) {
# 632 "job.c"
        if (c->pid == pid) {
# 633 "job.c"
          goto while_break___2;
        }
      }
# 631 "job.c"
      lastc = c;
# 631 "job.c"
      c = c->next;
    }
    while_break___2: ;
    }
# 635 "job.c"
    if ((unsigned long )c == (unsigned long )((struct child *)0)) {
# 638 "job.c"
      goto while_continue;
    }
    {
# 640 "job.c"
    while (1) {
      while_continue___3: ;
# 640 "job.c"
      if (4 & db_level) {
# 640 "job.c"
        if (c->remote) {
          {
# 640 "job.c"
          tmp___6 = dcgettext((char const *)((void *)0), " (remote)", 5);
# 640 "job.c"
          tmp___7 = (char const *)tmp___6;
          }
        } else {
# 640 "job.c"
          tmp___7 = "";
        }
# 640 "job.c"
        if (child_failed) {
          {
# 640 "job.c"
          tmp___8 = dcgettext((char const *)((void *)0), "Reaping losing child 0x%08lx PID %ld %s\n",
                              5);
# 640 "job.c"
          tmp___10 = tmp___8;
          }
        } else {
          {
# 640 "job.c"
          tmp___9 = dcgettext((char const *)((void *)0), "Reaping winning child 0x%08lx PID %ld %s\n",
                              5);
# 640 "job.c"
          tmp___10 = tmp___9;
          }
        }
        {
# 640 "job.c"
        printf((char const * __restrict )tmp___10, (unsigned long )c, (long )c->pid,
               tmp___7);
# 640 "job.c"
        fflush(stdout);
        }
      }
# 640 "job.c"
      goto while_break___3;
    }
    while_break___3: ;
    }
# 646 "job.c"
    if (c->sh_batch_file) {
      {
# 647 "job.c"
      while (1) {
        while_continue___4: ;
# 647 "job.c"
        if (4 & db_level) {
          {
# 647 "job.c"
          tmp___11 = dcgettext((char const *)((void *)0), "Cleaning up temp batch file %s\n",
                               5);
# 647 "job.c"
          printf((char const * __restrict )tmp___11, c->sh_batch_file);
# 647 "job.c"
          fflush(stdout);
          }
        }
# 647 "job.c"
        goto while_break___4;
      }
      while_break___4: ;
      }
      {
# 651 "job.c"
      remove((char const *)c->sh_batch_file);
# 654 "job.c"
      free((void *)c->sh_batch_file);
# 655 "job.c"
      c->sh_batch_file = (char *)((void *)0);
      }
    }
# 659 "job.c"
    if (c->good_stdin) {
# 660 "job.c"
      good_stdin_used = 0;
    }
# 662 "job.c"
    if (child_failed) {
# 662 "job.c"
      if (! c->noerror) {
# 662 "job.c"
        if (! ignore_errors_flag) {
          {
# 667 "job.c"
          child_error((c->file)->name, exit_code, exit_sig, coredump, 0);
# 668 "job.c"
          (c->file)->update_status = (short)2;
          }
# 669 "job.c"
          if (delete_on_error == -1) {
            {
# 671 "job.c"
            tmp___12 = lookup_file((char *)".DELETE_ON_ERROR");
# 671 "job.c"
            f = tmp___12;
            }
# 672 "job.c"
            if ((unsigned long )f != (unsigned long )((struct file *)0)) {
# 672 "job.c"
              if (f->is_target) {
# 672 "job.c"
                tmp___13 = 1;
              } else {
# 672 "job.c"
                tmp___13 = 0;
              }
            } else {
# 672 "job.c"
              tmp___13 = 0;
            }
# 672 "job.c"
            delete_on_error = tmp___13;
          }
# 674 "job.c"
          if (exit_sig != 0) {
            {
# 675 "job.c"
            delete_child_targets(c);
            }
          } else
# 674 "job.c"
          if (delete_on_error) {
            {
# 675 "job.c"
            delete_child_targets(c);
            }
          }
        } else {
# 662 "job.c"
          goto _L___0;
        }
      } else {
# 662 "job.c"
        goto _L___0;
      }
    } else {
      _L___0:
# 679 "job.c"
      if (child_failed) {
        {
# 682 "job.c"
        child_error((c->file)->name, exit_code, exit_sig, coredump, 1);
# 684 "job.c"
        child_failed = 0;
        }
      }
      {
# 688 "job.c"
      tmp___15 = job_next_command(c);
      }
# 688 "job.c"
      if (tmp___15) {
# 690 "job.c"
        if (handling_fatal_signal) {
# 696 "job.c"
          (c->file)->update_status = (short)2;
        } else {
          {
# 704 "job.c"
          tmp___14 = start_remote_job_p(0);
# 704 "job.c"
          c->remote = (unsigned int )tmp___14;
# 705 "job.c"
          start_job_command(c);
# 710 "job.c"
          unblock_sigs();
          }
# 711 "job.c"
          if ((unsigned int )(c->file)->command_state == 2U) {
# 714 "job.c"
            goto while_continue;
          }
        }
# 717 "job.c"
        if ((int )(c->file)->update_status != 0) {
          {
# 719 "job.c"
          delete_child_targets(c);
          }
        }
      } else {
# 725 "job.c"
        (c->file)->update_status = (short)0;
      }
    }
# 734 "job.c"
    if (! handling_fatal_signal) {
      {
# 738 "job.c"
      notice_finished_file(c->file);
      }
    }
    {
# 740 "job.c"
    while (1) {
      while_continue___5: ;
# 740 "job.c"
      if (4 & db_level) {
# 740 "job.c"
        if (c->remote) {
          {
# 740 "job.c"
          tmp___16 = dcgettext((char const *)((void *)0), " (remote)", 5);
# 740 "job.c"
          tmp___17 = (char const *)tmp___16;
          }
        } else {
# 740 "job.c"
          tmp___17 = "";
        }
        {
# 740 "job.c"
        tmp___18 = dcgettext((char const *)((void *)0), "Removing child 0x%08lx PID %ld %s from chain.\n",
                             5);
# 740 "job.c"
        printf((char const * __restrict )tmp___18, (unsigned long )c, (long )c->pid,
               tmp___17);
# 740 "job.c"
        fflush(stdout);
        }
      }
# 740 "job.c"
      goto while_break___5;
    }
    while_break___5: ;
    }
    {
# 749 "job.c"
    block_sigs();
    }
# 752 "job.c"
    if (job_slots_used > 0U) {
# 753 "job.c"
      job_slots_used --;
    }
# 756 "job.c"
    if ((unsigned long )lastc == (unsigned long )((struct child *)0)) {
# 757 "job.c"
      children = c->next;
    } else {
# 759 "job.c"
      lastc->next = c->next;
    }
    {
# 761 "job.c"
    free_child(c);
# 763 "job.c"
    unblock_sigs();
    }
# 767 "job.c"
    if (! err) {
# 767 "job.c"
      if (child_failed) {
# 767 "job.c"
        if (! keep_going_flag) {
# 767 "job.c"
          if (! handling_fatal_signal) {
            {
# 770 "job.c"
            die(2);
            }
          }
        }
      }
    }
# 773 "job.c"
    block = 0;
  }
  while_break: ;
  }
# 776 "job.c"
  return;
}
}
# 781 "job.c"
static void free_child(struct child *child )
{
  char token ;
  char *tmp ;
  int *tmp___0 ;
  ssize_t tmp___1 ;
  char *tmp___2 ;
  register unsigned int i ;
  register char **ep ;
  char **tmp___3 ;

  {
# 789 "job.c"
  if (job_fds[1] >= 0) {
# 789 "job.c"
    if (children) {
# 791 "job.c"
      token = (char )'+';
      {
# 795 "job.c"
      while (1) {
        while_continue: ;
        {
# 795 "job.c"
        tmp___1 = write(job_fds[1], (void const *)(& token), (size_t )1);
        }
# 795 "job.c"
        if (! (tmp___1 != 1L)) {
# 795 "job.c"
          goto while_break;
        }
        {
# 796 "job.c"
        tmp___0 = __errno_location();
        }
# 796 "job.c"
        if (! (*tmp___0 == 4)) {
          {
# 797 "job.c"
          tmp = dcgettext((char const *)((void *)0), "write jobserver", 5);
# 797 "job.c"
          pfatal_with_name(tmp);
          }
        }
      }
      while_break: ;
      }
      {
# 799 "job.c"
      while (1) {
        while_continue___0: ;
# 799 "job.c"
        if (4 & db_level) {
          {
# 799 "job.c"
          tmp___2 = dcgettext((char const *)((void *)0), "Released token for child 0x%08lx (%s).\n",
                              5);
# 799 "job.c"
          printf((char const * __restrict )tmp___2, (unsigned long )child, (child->file)->name);
# 799 "job.c"
          fflush(stdout);
          }
        }
# 799 "job.c"
        goto while_break___0;
      }
      while_break___0: ;
      }
    }
  }
# 803 "job.c"
  if (handling_fatal_signal) {
# 804 "job.c"
    return;
  }
# 806 "job.c"
  if ((unsigned long )child->command_lines != (unsigned long )((char **)0)) {
# 809 "job.c"
    i = 0U;
    {
# 809 "job.c"
    while (1) {
      while_continue___1: ;
# 809 "job.c"
      if (! (i < ((child->file)->cmds)->ncommand_lines)) {
# 809 "job.c"
        goto while_break___1;
      }
      {
# 810 "job.c"
      free((void *)*(child->command_lines + i));
# 809 "job.c"
      i ++;
      }
    }
    while_break___1: ;
    }
    {
# 811 "job.c"
    free((void *)((char *)child->command_lines));
    }
  }
# 814 "job.c"
  if ((unsigned long )child->environment != (unsigned long )((char **)0)) {
# 816 "job.c"
    ep = child->environment;
    {
# 817 "job.c"
    while (1) {
      while_continue___2: ;
# 817 "job.c"
      if (! ((unsigned long )*ep != (unsigned long )((char *)0))) {
# 817 "job.c"
        goto while_break___2;
      }
      {
# 818 "job.c"
      tmp___3 = ep;
# 818 "job.c"
      ep ++;
# 818 "job.c"
      free((void *)*tmp___3);
      }
    }
    while_break___2: ;
    }
    {
# 819 "job.c"
    free((void *)((char *)child->environment));
    }
  }
  {
# 822 "job.c"
  free((void *)((char *)child));
  }
# 823 "job.c"
  return;
}
}
# 826 "job.c"
sigset_t fatal_signal_set ;
# 829 "job.c"
void block_sigs(void)
{


  {
  {
# 833 "job.c"
  sigprocmask(0, (sigset_t const * __restrict )(& fatal_signal_set), (sigset_t * __restrict )((sigset_t *)0));
  }
# 839 "job.c"
  return;
}
}
# 842 "job.c"
void unblock_sigs(void)
{
  sigset_t empty ;

  {
  {
# 846 "job.c"
  sigemptyset(& empty);
# 847 "job.c"
  sigprocmask(2, (sigset_t const * __restrict )(& empty), (sigset_t * __restrict )((sigset_t *)0));
  }
# 848 "job.c"
  return;
}
}
# 863 "job.c"
static int bad_stdin = -1;
# 858 "job.c"
static void start_job_command(struct child *child )
{
  register char *p ;
  int flags ;
  char **argv ;
  unsigned short const **tmp ;
  char *end ;
  char *tmp___0 ;
  int tmp___1 ;
  char const *tmp___2 ;
  int tmp___3 ;
  int pd[2] ;
  int tmp___4 ;
  int is_remote ;
  int id ;
  int used_stdin ;
  int tmp___5 ;
  int tmp___6 ;
  char **parent_environ ;
  int tmp___7 ;

  {
# 874 "job.c"
  if (! child->command_ptr) {
# 875 "job.c"
    goto next_command;
  }
# 879 "job.c"
  flags = (child->file)->command_flags | (int )*(((child->file)->cmds)->lines_flags + (child->command_line - 1U));
# 882 "job.c"
  p = child->command_ptr;
# 883 "job.c"
  child->noerror = (unsigned int )(flags & 4);
  {
# 885 "job.c"
  while (1) {
    while_continue: ;
# 885 "job.c"
    if (! ((int )*p != 0)) {
# 885 "job.c"
      goto while_break;
    }
# 887 "job.c"
    if ((int )*p == 64) {
# 888 "job.c"
      flags |= 2;
    } else
# 889 "job.c"
    if ((int )*p == 43) {
# 890 "job.c"
      flags |= 1;
    } else
# 891 "job.c"
    if ((int )*p == 45) {
# 892 "job.c"
      child->noerror = 1U;
    } else {
      {
# 893 "job.c"
      tmp = __ctype_b_loc();
      }
# 893 "job.c"
      if (! ((int const )*(*tmp + (int )*p) & 1)) {
# 894 "job.c"
        goto while_break;
      }
    }
# 895 "job.c"
    p ++;
  }
  while_break: ;
  }
# 899 "job.c"
  *(((child->file)->cmds)->lines_flags + (child->command_line - 1U)) = (char )((int )*(((child->file)->cmds)->lines_flags + (child->command_line - 1U)) | flags);
# 904 "job.c"
  if (question_flag) {
# 904 "job.c"
    if (! (flags & 1)) {
      {
# 906 "job.c"
      (child->file)->update_status = (short)1;
# 907 "job.c"
      notice_finished_file(child->file);
      }
# 908 "job.c"
      return;
    }
  }
  {
# 913 "job.c"
  p = next_token(p);
# 918 "job.c"
  end = (char *)0;
# 922 "job.c"
  argv = construct_command_argv(p, & end, child->file, & child->sh_batch_file);
  }
# 924 "job.c"
  if ((unsigned long )end == (unsigned long )((void *)0)) {
# 925 "job.c"
    child->command_ptr = (char *)((void *)0);
  } else {
# 928 "job.c"
    tmp___0 = end;
# 928 "job.c"
    end ++;
# 928 "job.c"
    *tmp___0 = (char )'\000';
# 929 "job.c"
    child->command_ptr = end;
  }
# 933 "job.c"
  if (touch_flag) {
# 933 "job.c"
    if (! (flags & 1)) {
      {
# 938 "job.c"
      free((void *)*(argv + 0));
# 939 "job.c"
      free((void *)((char *)argv));
# 941 "job.c"
      argv = (char **)0;
      }
    }
  }
# 944 "job.c"
  if ((unsigned long )argv == (unsigned long )((char **)0)) {
    next_command:
    {
# 951 "job.c"
    tmp___1 = job_next_command(child);
    }
# 951 "job.c"
    if (tmp___1) {
      {
# 952 "job.c"
      start_job_command(child);
      }
    } else {
      {
# 957 "job.c"
      set_command_state(child->file, 2);
# 958 "job.c"
      (child->file)->update_status = (short)0;
# 959 "job.c"
      notice_finished_file(child->file);
      }
    }
# 961 "job.c"
    return;
  }
# 968 "job.c"
  if (just_print_flag) {
# 968 "job.c"
    tmp___2 = "%s";
  } else
# 968 "job.c"
  if (! (flags & 2)) {
# 968 "job.c"
    if (! silent_flag) {
# 968 "job.c"
      tmp___2 = "%s";
    } else {
# 968 "job.c"
      tmp___2 = (char const *)((char *)0);
    }
  } else {
# 968 "job.c"
    tmp___2 = (char const *)((char *)0);
  }
  {
# 968 "job.c"
  message(0, tmp___2, p);
  }
# 975 "job.c"
  if (*(argv + 0)) {
    {
# 975 "job.c"
    tmp___3 = strcmp((char const *)*(argv + 0), "/bin/sh");
    }
# 975 "job.c"
    if (! tmp___3) {
# 975 "job.c"
      if (*(argv + 1)) {
# 975 "job.c"
        if ((int )*(*(argv + 1) + 0) == 45) {
# 975 "job.c"
          if ((int )*(*(argv + 1) + 1) == 99) {
# 975 "job.c"
            if ((int )*(*(argv + 1) + 2) == 0) {
# 975 "job.c"
              if (*(argv + 2)) {
# 975 "job.c"
                if ((int )*(*(argv + 2) + 0) == 58) {
# 975 "job.c"
                  if ((int )*(*(argv + 2) + 1) == 0) {
# 975 "job.c"
                    if ((unsigned long )*(argv + 3) == (unsigned long )((void *)0)) {
                      {
# 986 "job.c"
                      free((void *)*(argv + 0));
# 987 "job.c"
                      free((void *)((char *)argv));
                      }
# 988 "job.c"
                      goto next_command;
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
# 999 "job.c"
  commands_started ++;
# 1003 "job.c"
  if (just_print_flag) {
# 1003 "job.c"
    if (! (flags & 1)) {
      {
# 1006 "job.c"
      free((void *)*(argv + 0));
# 1007 "job.c"
      free((void *)((char *)argv));
      }
# 1009 "job.c"
      goto next_command;
    }
  }
  {
# 1014 "job.c"
  fflush(stdout);
# 1015 "job.c"
  fflush(stderr);
  }
# 1022 "job.c"
  if (bad_stdin == -1) {
    {
# 1027 "job.c"
    tmp___4 = pipe(pd);
    }
# 1027 "job.c"
    if (tmp___4 == 0) {
      {
# 1030 "job.c"
      close(pd[1]);
# 1032 "job.c"
      bad_stdin = pd[0];
# 1037 "job.c"
      fcntl(bad_stdin, 2, 1);
      }
    }
  }
# 1047 "job.c"
  child->good_stdin = (unsigned int )(! good_stdin_used);
# 1048 "job.c"
  if (child->good_stdin) {
# 1049 "job.c"
    good_stdin_used = 1;
  }
# 1053 "job.c"
  child->deleted = 0U;
# 1057 "job.c"
  if ((unsigned long )child->environment == (unsigned long )((char **)0)) {
    {
# 1058 "job.c"
    child->environment = target_environment(child->file);
    }
  }
# 1065 "job.c"
  if (child->remote) {
# 1068 "job.c"
    if (child->good_stdin) {
# 1068 "job.c"
      tmp___5 = 0;
    } else {
# 1068 "job.c"
      tmp___5 = bad_stdin;
    }
    {
# 1068 "job.c"
    tmp___6 = start_remote_job(argv, child->environment, tmp___5, & is_remote, & id,
                               & used_stdin);
    }
# 1068 "job.c"
    if (tmp___6) {
# 1073 "job.c"
      goto run_local;
    } else {
# 1076 "job.c"
      if (child->good_stdin) {
# 1076 "job.c"
        if (! used_stdin) {
# 1078 "job.c"
          child->good_stdin = 0U;
# 1079 "job.c"
          good_stdin_used = 0;
        }
      }
# 1081 "job.c"
      child->remote = (unsigned int )is_remote;
# 1082 "job.c"
      child->pid = id;
    }
  } else {
    run_local:
    {
# 1093 "job.c"
    block_sigs();
# 1095 "job.c"
    child->remote = 0U;
# 1107 "job.c"
    parent_environ = environ;
# 1108 "job.c"
    child->pid = vfork();
# 1109 "job.c"
    environ = parent_environ;
    }
# 1110 "job.c"
    if (child->pid == 0) {
      {
# 1113 "job.c"
      unblock_sigs();
      }
# 1117 "job.c"
      if (! (flags & 1)) {
# 1117 "job.c"
        if (job_fds[0] >= 0) {
          {
# 1119 "job.c"
          close(job_fds[0]);
# 1120 "job.c"
          close(job_fds[1]);
          }
        }
      }
# 1122 "job.c"
      if (job_rfd >= 0) {
        {
# 1123 "job.c"
        close(job_rfd);
        }
      }
# 1125 "job.c"
      if (child->good_stdin) {
# 1125 "job.c"
        tmp___7 = 0;
      } else {
# 1125 "job.c"
        tmp___7 = bad_stdin;
      }
      {
# 1125 "job.c"
      child_execute_job(tmp___7, 1, argv, child->environment);
      }
    } else
# 1128 "job.c"
    if (child->pid < 0) {
      {
# 1131 "job.c"
      unblock_sigs();
# 1132 "job.c"
      perror_with_name((char *)"vfork", (char *)"");
      }
# 1133 "job.c"
      goto error;
    }
  }
  {
# 1242 "job.c"
  set_command_state(child->file, 2);
# 1246 "job.c"
  free((void *)*(argv + 0));
# 1247 "job.c"
  free((void *)((char *)argv));
  }
# 1250 "job.c"
  return;
  error:
  {
# 1253 "job.c"
  (child->file)->update_status = (short)2;
# 1254 "job.c"
  notice_finished_file(child->file);
  }
# 1255 "job.c"
  return;
}
}
# 1262 "job.c"
static int start_waiting_job(struct child *c )
{
  struct file *f ;
  int tmp ;
  int tmp___0 ;
  char *tmp___1 ;
  char const *tmp___2 ;
  char *tmp___3 ;

  {
  {
# 1266 "job.c"
  f = c->file;
# 1272 "job.c"
  tmp = start_remote_job_p(1);
# 1272 "job.c"
  c->remote = (unsigned int )tmp;
  }
# 1276 "job.c"
  if (! c->remote) {
# 1276 "job.c"
    if (job_slots_used > 0U) {
      {
# 1276 "job.c"
      tmp___0 = load_too_high();
      }
# 1276 "job.c"
      if (tmp___0) {
        {
# 1280 "job.c"
        set_command_state(f, 2);
# 1281 "job.c"
        c->next = waiting_jobs;
# 1282 "job.c"
        waiting_jobs = c;
        }
# 1283 "job.c"
        return (0);
      }
    }
  }
  {
# 1287 "job.c"
  start_job_command(c);
  }
  {
# 1290 "job.c"
  if ((unsigned int )f->command_state == 2U) {
# 1290 "job.c"
    goto case_2;
  }
# 1301 "job.c"
  if ((unsigned int )f->command_state == 0U) {
# 1301 "job.c"
    goto case_0;
  }
# 1305 "job.c"
  if ((unsigned int )f->command_state == 3U) {
# 1305 "job.c"
    goto case_3;
  }
# 1311 "job.c"
  goto switch_default;
  case_2:
# 1292 "job.c"
  c->next = children;
  {
# 1293 "job.c"
  while (1) {
    while_continue: ;
# 1293 "job.c"
    if (4 & db_level) {
# 1293 "job.c"
      if (c->remote) {
        {
# 1293 "job.c"
        tmp___1 = dcgettext((char const *)((void *)0), " (remote)", 5);
# 1293 "job.c"
        tmp___2 = (char const *)tmp___1;
        }
      } else {
# 1293 "job.c"
        tmp___2 = "";
      }
      {
# 1293 "job.c"
      tmp___3 = dcgettext((char const *)((void *)0), "Putting child 0x%08lx (%s) PID %ld%s on the chain.\n",
                          5);
# 1293 "job.c"
      printf((char const * __restrict )tmp___3, (unsigned long )c, (c->file)->name,
             (long )c->pid, tmp___2);
# 1293 "job.c"
      fflush(stdout);
      }
    }
# 1293 "job.c"
    goto while_break;
  }
  while_break: ;
  }
  {
# 1296 "job.c"
  children = c;
# 1298 "job.c"
  job_slots_used ++;
# 1299 "job.c"
  unblock_sigs();
  }
# 1300 "job.c"
  goto switch_break;
  case_0:
# 1304 "job.c"
  f->update_status = (short)0;
  case_3:
  {
# 1308 "job.c"
  notice_finished_file(f);
# 1309 "job.c"
  free_child(c);
  }
# 1310 "job.c"
  goto switch_break;
  switch_default:
# 1313 "job.c"
  if (! ((unsigned int )f->command_state == 3U)) {
    {
# 1313 "job.c"
    __assert_fail("f->command_state == cs_finished", "job.c", 1313U, "start_waiting_job");
    }
  }
# 1314 "job.c"
  goto switch_break;
  switch_break: ;
  }
# 1317 "job.c"
  return (1);
}
}
# 1322 "job.c"
void new_job(struct file *file )
{
  register struct commands *cmds ;
  register struct child *c ;
  char **lines ;
  register unsigned int i ;
  char *tmp ;
  char *in ;
  char *out ;
  char *ref___0 ;
  char openparen ;
  char closeparen ;
  int tmp___0 ;
  int count ;
  char *p ;
  char *tmp___1 ;
  char *tmp___2 ;
  int quoted ;
  char *tmp___3 ;
  char *tmp___4 ;
  unsigned short const **tmp___5 ;
  char *tmp___6 ;
  char *tmp___7 ;
  char *tmp___8 ;
  char *tmp___9 ;
  char token ;
  char *tmp___10 ;
  ssize_t tmp___11 ;
  char *tmp___12 ;
  int *tmp___13 ;
  int *tmp___14 ;

  {
  {
# 1326 "job.c"
  cmds = file->cmds;
# 1333 "job.c"
  start_waiting_jobs();
# 1336 "job.c"
  reap_children(0, 0);
# 1339 "job.c"
  chop_commands(cmds);
# 1342 "job.c"
  tmp = xmalloc((unsigned int )((unsigned long )cmds->ncommand_lines * sizeof(char *)));
# 1342 "job.c"
  lines = (char **)tmp;
# 1343 "job.c"
  i = 0U;
  }
  {
# 1343 "job.c"
  while (1) {
    while_continue: ;
# 1343 "job.c"
    if (! (i < cmds->ncommand_lines)) {
# 1343 "job.c"
      goto while_break;
    }
# 1359 "job.c"
    out = *(cmds->command_lines + i);
# 1359 "job.c"
    in = out;
    {
# 1360 "job.c"
    while (1) {
      while_continue___0: ;
      {
# 1360 "job.c"
      ref___0 = strchr((char const *)in, '$');
      }
# 1360 "job.c"
      if (! ((unsigned long )ref___0 != (unsigned long )((char *)0))) {
# 1360 "job.c"
        goto while_break___0;
      }
# 1362 "job.c"
      ref___0 ++;
# 1364 "job.c"
      if ((unsigned long )out != (unsigned long )in) {
        {
# 1368 "job.c"
        memmove((void *)out, (void const *)in, (size_t )(ref___0 - in));
        }
      }
# 1371 "job.c"
      out += ref___0 - in;
# 1372 "job.c"
      in = ref___0;
# 1374 "job.c"
      if ((int )*ref___0 == 40) {
# 1374 "job.c"
        goto _L___1;
      } else
# 1374 "job.c"
      if ((int )*ref___0 == 123) {
        _L___1:
# 1376 "job.c"
        openparen = *ref___0;
# 1377 "job.c"
        if ((int )openparen == 40) {
# 1377 "job.c"
          tmp___0 = ')';
        } else {
# 1377 "job.c"
          tmp___0 = '}';
        }
# 1377 "job.c"
        closeparen = (char )tmp___0;
# 1381 "job.c"
        tmp___1 = out;
# 1381 "job.c"
        out ++;
# 1381 "job.c"
        tmp___2 = in;
# 1381 "job.c"
        in ++;
# 1381 "job.c"
        *tmp___1 = *tmp___2;
# 1384 "job.c"
        count = 0;
        {
# 1385 "job.c"
        while (1) {
          while_continue___1: ;
# 1385 "job.c"
          if (! ((int )*in != 0)) {
# 1385 "job.c"
            goto while_break___1;
          }
# 1387 "job.c"
          if ((int )*in == (int )closeparen) {
# 1387 "job.c"
            count --;
# 1387 "job.c"
            if (count < 0) {
# 1388 "job.c"
              goto while_break___1;
            } else {
# 1387 "job.c"
              goto _L___0;
            }
          } else
          _L___0:
# 1389 "job.c"
          if ((int )*in == 92) {
# 1389 "job.c"
            if ((int )*(in + 1) == 10) {
# 1395 "job.c"
              quoted = 0;
# 1396 "job.c"
              p = in - 1;
              {
# 1396 "job.c"
              while (1) {
                while_continue___2: ;
# 1396 "job.c"
                if ((unsigned long )p > (unsigned long )ref___0) {
# 1396 "job.c"
                  if (! ((int )*p == 92)) {
# 1396 "job.c"
                    goto while_break___2;
                  }
                } else {
# 1396 "job.c"
                  goto while_break___2;
                }
# 1397 "job.c"
                quoted = ! quoted;
# 1396 "job.c"
                p --;
              }
              while_break___2: ;
              }
# 1399 "job.c"
              if (quoted) {
# 1405 "job.c"
                tmp___3 = out;
# 1405 "job.c"
                out ++;
# 1405 "job.c"
                tmp___4 = in;
# 1405 "job.c"
                in ++;
# 1405 "job.c"
                *tmp___3 = *tmp___4;
              } else {
                {
# 1410 "job.c"
                in = next_token(in + 2);
                }
                {
# 1414 "job.c"
                while (1) {
                  while_continue___3: ;
# 1414 "job.c"
                  if ((unsigned long )out > (unsigned long )ref___0) {
                    {
# 1414 "job.c"
                    tmp___5 = __ctype_b_loc();
                    }
# 1414 "job.c"
                    if (! ((int const )*(*tmp___5 + (int )*(out + -1)) & 1)) {
# 1414 "job.c"
                      goto while_break___3;
                    }
                  } else {
# 1414 "job.c"
                    goto while_break___3;
                  }
# 1415 "job.c"
                  out --;
                }
                while_break___3: ;
                }
# 1418 "job.c"
                tmp___6 = out;
# 1418 "job.c"
                out ++;
# 1418 "job.c"
                *tmp___6 = (char )' ';
              }
            } else {
# 1389 "job.c"
              goto _L;
            }
          } else {
            _L:
# 1423 "job.c"
            if ((int )*in == (int )openparen) {
# 1424 "job.c"
              count ++;
            }
# 1426 "job.c"
            tmp___7 = out;
# 1426 "job.c"
            out ++;
# 1426 "job.c"
            tmp___8 = in;
# 1426 "job.c"
            in ++;
# 1426 "job.c"
            *tmp___7 = *tmp___8;
          }
        }
        while_break___1: ;
        }
      }
    }
    while_break___0: ;
    }
# 1434 "job.c"
    if ((unsigned long )out != (unsigned long )in) {
      {
# 1435 "job.c"
      strcpy((char * __restrict )out, (char const * __restrict )in);
      }
    }
    {
# 1438 "job.c"
    *(lines + i) = allocated_variable_expand_for_file(*(cmds->command_lines + i),
                                                      file);
# 1343 "job.c"
    i ++;
    }
  }
  while_break: ;
  }
  {
# 1445 "job.c"
  tmp___9 = xmalloc((unsigned int )sizeof(struct child ));
# 1445 "job.c"
  c = (struct child *)tmp___9;
# 1446 "job.c"
  memset((void *)((char *)c), 0, sizeof(struct child ));
# 1447 "job.c"
  c->file = file;
# 1448 "job.c"
  c->command_lines = lines;
# 1449 "job.c"
  c->sh_batch_file = (char *)((void *)0);
# 1452 "job.c"
  job_next_command(c);
  }
# 1457 "job.c"
  if (job_slots != 0U) {
    {
# 1458 "job.c"
    while (1) {
      while_continue___4: ;
# 1458 "job.c"
      if (! (job_slots_used == job_slots)) {
# 1458 "job.c"
        goto while_break___4;
      }
      {
# 1459 "job.c"
      reap_children(1, 0);
      }
    }
    while_break___4: ;
    }
  } else
# 1474 "job.c"
  if (job_fds[0] >= 0) {
    {
# 1475 "job.c"
    while (1) {
      while_continue___5: ;
# 1475 "job.c"
      if (! (! (! children))) {
# 1475 "job.c"
        goto while_break___5;
      }
      {
# 1488 "job.c"
      tmp___11 = read(job_rfd, (void *)(& token), (size_t )1);
      }
# 1488 "job.c"
      if (tmp___11 == 1L) {
        {
# 1490 "job.c"
        while (1) {
          while_continue___6: ;
# 1490 "job.c"
          if (4 & db_level) {
            {
# 1490 "job.c"
            tmp___10 = dcgettext((char const *)((void *)0), "Obtained token for child 0x%08lx (%s).\n",
                                 5);
# 1490 "job.c"
            printf((char const * __restrict )tmp___10, (unsigned long )c, (c->file)->name);
# 1490 "job.c"
            fflush(stdout);
            }
          }
# 1490 "job.c"
          goto while_break___6;
        }
        while_break___6: ;
        }
# 1492 "job.c"
        goto while_break___5;
      }
      {
# 1495 "job.c"
      tmp___13 = __errno_location();
      }
# 1495 "job.c"
      if (*tmp___13 != 4) {
        {
# 1495 "job.c"
        tmp___14 = __errno_location();
        }
# 1495 "job.c"
        if (*tmp___14 != 9) {
          {
# 1496 "job.c"
          tmp___12 = dcgettext((char const *)((void *)0), "read jobs pipe", 5);
# 1496 "job.c"
          pfatal_with_name(tmp___12);
          }
        }
      }
# 1500 "job.c"
      if (job_rfd < 0) {
        {
# 1501 "job.c"
        job_rfd = dup(job_fds[0]);
        }
      }
      {
# 1505 "job.c"
      reap_children(0, 0);
      }
    }
    while_break___5: ;
    }
  }
  {
# 1511 "job.c"
  start_waiting_job(c);
  }
# 1513 "job.c"
  if (job_slots == 1U) {
# 1513 "job.c"
    goto _L___2;
  } else
# 1513 "job.c"
  if (not_parallel) {
    _L___2:
    {
# 1516 "job.c"
    while (1) {
      while_continue___7: ;
# 1516 "job.c"
      if (! ((unsigned int )file->command_state == 2U)) {
# 1516 "job.c"
        goto while_break___7;
      }
      {
# 1517 "job.c"
      reap_children(1, 0);
      }
    }
    while_break___7: ;
    }
  }
# 1519 "job.c"
  return;
}
}
# 1525 "job.c"
static int job_next_command(struct child *child )
{
  unsigned int tmp ;

  {
  {
# 1529 "job.c"
  while (1) {
    while_continue: ;
# 1529 "job.c"
    if (! ((unsigned long )child->command_ptr == (unsigned long )((char *)0))) {
# 1529 "job.c"
      if (! ((int )*(child->command_ptr) == 0)) {
# 1529 "job.c"
        goto while_break;
      }
    }
# 1532 "job.c"
    if (child->command_line == ((child->file)->cmds)->ncommand_lines) {
# 1535 "job.c"
      child->command_ptr = (char *)0;
# 1536 "job.c"
      return (0);
    } else {
# 1540 "job.c"
      tmp = child->command_line;
# 1540 "job.c"
      (child->command_line) ++;
# 1540 "job.c"
      child->command_ptr = *(child->command_lines + tmp);
    }
  }
  while_break: ;
  }
# 1542 "job.c"
  return (1);
}
}
# 1559 "job.c"
static int lossage = -1;
# 1545 "job.c"
static int load_too_high(void)
{
  double load ;
  char *tmp ;
  char *tmp___0 ;
  int *tmp___1 ;
  int *tmp___2 ;
  int *tmp___3 ;
  int tmp___4 ;

  {
# 1553 "job.c"
  if (max_load_average < (double )0) {
# 1554 "job.c"
    return (0);
  }
  {
# 1556 "job.c"
  make_access();
# 1557 "job.c"
  tmp___4 = getloadavg(& load, 1);
  }
# 1557 "job.c"
  if (tmp___4 != 1) {
# 1561 "job.c"
    if (lossage == -1) {
# 1561 "job.c"
      goto _L;
    } else {
      {
# 1561 "job.c"
      tmp___2 = __errno_location();
      }
# 1561 "job.c"
      if (*tmp___2 != lossage) {
        _L:
        {
# 1563 "job.c"
        tmp___1 = __errno_location();
        }
# 1563 "job.c"
        if (*tmp___1 == 0) {
          {
# 1565 "job.c"
          tmp = dcgettext((char const *)((void *)0), "cannot enforce load limits on this operating system",
                          5);
# 1565 "job.c"
          error((struct floc const *)((struct floc *)0), (char const *)tmp);
          }
        } else {
          {
# 1568 "job.c"
          tmp___0 = dcgettext((char const *)((void *)0), "cannot enforce load limit: ",
                              5);
# 1568 "job.c"
          perror_with_name(tmp___0, (char *)"getloadavg");
          }
        }
      }
    }
    {
# 1570 "job.c"
    tmp___3 = __errno_location();
# 1570 "job.c"
    lossage = *tmp___3;
# 1571 "job.c"
    load = (double )0;
    }
  }
  {
# 1573 "job.c"
  user_access();
  }
# 1575 "job.c"
  return (load >= max_load_average);
}
}
# 1581 "job.c"
void start_waiting_jobs(void)
{
  struct child *job ;
  int tmp ;

  {
# 1586 "job.c"
  if ((unsigned long )waiting_jobs == (unsigned long )((struct child *)0)) {
# 1587 "job.c"
    return;
  }
  {
# 1589 "job.c"
  while (1) {
    while_continue: ;
    {
# 1592 "job.c"
    reap_children(0, 0);
# 1595 "job.c"
    job = waiting_jobs;
# 1596 "job.c"
    waiting_jobs = job->next;
# 1589 "job.c"
    tmp = start_waiting_job(job);
    }
# 1589 "job.c"
    if (tmp) {
# 1589 "job.c"
      if (! ((unsigned long )waiting_jobs != (unsigned long )((struct child *)0))) {
# 1589 "job.c"
        goto while_break;
      }
    } else {
# 1589 "job.c"
      goto while_break;
    }
  }
  while_break: ;
  }
# 1603 "job.c"
  return;
}
}
# 2162 "job.c"
void child_execute_job(int stdin_fd , int stdout_fd , char **argv , char **envp )
{


  {
# 2167 "job.c"
  if (stdin_fd != 0) {
    {
# 2168 "job.c"
    dup2(stdin_fd, 0);
    }
  }
# 2169 "job.c"
  if (stdout_fd != 1) {
    {
# 2170 "job.c"
    dup2(stdout_fd, 1);
    }
  }
# 2171 "job.c"
  if (stdin_fd != 0) {
    {
# 2172 "job.c"
    close(stdin_fd);
    }
  }
# 2173 "job.c"
  if (stdout_fd != 1) {
    {
# 2174 "job.c"
    close(stdout_fd);
    }
  }
  {
# 2177 "job.c"
  exec_command(argv, envp);
  }
# 2178 "job.c"
  return;
}
}
# 2187 "job.c"
void exec_command(char **argv , char **envp )
{
  int *tmp ;
  char *tmp___0 ;
  char *shell ;
  char **new_argv ;
  int argc ;
  void *tmp___1 ;
  char *tmp___2 ;
  int *tmp___3 ;

  {
  {
# 2257 "job.c"
  child_access();
# 2260 "job.c"
  environ = envp;
# 2261 "job.c"
  execvp((char const *)*(argv + 0), (char * const *)argv);
# 2263 "job.c"
  tmp = __errno_location();
  }
  {
# 2264 "job.c"
  if (*tmp == 2) {
# 2264 "job.c"
    goto case_2;
  }
# 2268 "job.c"
  if (*tmp == 8) {
# 2268 "job.c"
    goto case_8;
  }
# 2299 "job.c"
  goto switch_default;
  case_2:
  {
# 2266 "job.c"
  tmp___0 = dcgettext((char const *)((void *)0), "%s: Command not found", 5);
# 2266 "job.c"
  error((struct floc const *)((struct floc *)0), (char const *)tmp___0, *(argv + 0));
  }
# 2267 "job.c"
  goto switch_break;
  case_8:
  {
# 2276 "job.c"
  shell = getenv("SHELL");
  }
# 2277 "job.c"
  if ((unsigned long )shell == (unsigned long )((char *)0)) {
# 2278 "job.c"
    shell = default_shell;
  }
# 2280 "job.c"
  argc = 1;
  {
# 2281 "job.c"
  while (1) {
    while_continue: ;
# 2281 "job.c"
    if (! ((unsigned long )*(argv + argc) != (unsigned long )((char *)0))) {
# 2281 "job.c"
      goto while_break;
    }
# 2282 "job.c"
    argc ++;
  }
  while_break: ;
  }
  {
# 2284 "job.c"
  tmp___1 = __builtin_alloca((unsigned long )((1 + argc) + 1) * sizeof(char *));
# 2284 "job.c"
  new_argv = (char **)tmp___1;
# 2285 "job.c"
  *(new_argv + 0) = shell;
# 2286 "job.c"
  *(new_argv + 1) = *(argv + 0);
  }
  {
# 2287 "job.c"
  while (1) {
    while_continue___0: ;
# 2287 "job.c"
    if (! (argc > 0)) {
# 2287 "job.c"
      goto while_break___0;
    }
# 2289 "job.c"
    *(new_argv + (1 + argc)) = *(argv + argc);
# 2290 "job.c"
    argc --;
  }
  while_break___0: ;
  }
  {
# 2293 "job.c"
  execvp((char const *)shell, (char * const *)new_argv);
# 2294 "job.c"
  tmp___3 = __errno_location();
  }
# 2294 "job.c"
  if (*tmp___3 == 2) {
    {
# 2295 "job.c"
    tmp___2 = dcgettext((char const *)((void *)0), "%s: Shell program not found",
                        5);
# 2295 "job.c"
    error((struct floc const *)((struct floc *)0), (char const *)tmp___2, shell);
    }
  } else {
    {
# 2297 "job.c"
    perror_with_name((char *)"execvp: ", shell);
    }
  }
# 2298 "job.c"
  goto switch_break;
  switch_default:
  {
# 2302 "job.c"
  perror_with_name((char *)"execvp: ", *(argv + 0));
  }
# 2303 "job.c"
  goto switch_break;
  switch_break: ;
  }
  {
# 2306 "job.c"
  _exit(127);
  }
}
}
# 2416 "job.c"
static char **construct_command_argv_internal(char *line , char **restp , char *shell ,
                                              char *ifs , char **batch_filename_ptr ) ;
# 2416 "job.c"
static char sh_chars[19] =
# 2416 "job.c"
  { (char )'#', (char )';', (char )'\"', (char )'*',
        (char )'?', (char )'[', (char )']', (char )'&',
        (char )'|', (char )'<', (char )'>', (char )'(',
        (char )')', (char )'{', (char )'}', (char )'$',
        (char )'`', (char )'^', (char )'\000'};
# 2417 "job.c"
static char *sh_cmds[25] =
# 2417 "job.c"
  { (char *)"cd", (char *)"eval", (char *)"exec", (char *)"exit",
        (char *)"login", (char *)"logout", (char *)"set", (char *)"umask",
        (char *)"wait", (char *)"while", (char *)"for", (char *)"case",
        (char *)"if", (char *)":", (char *)".", (char *)"break",
        (char *)"continue", (char *)"export", (char *)"read", (char *)"readonly",
        (char *)"shift", (char *)"times", (char *)"trap", (char *)"switch",
        (char *)0};
# 2786 "job.c"
static char minus_c[5] = { (char )' ', (char )'-', (char )'c', (char )' ',
        (char )'\000'};
# 2338 "job.c"
static char **construct_command_argv_internal(char *line , char **restp , char *shell ,
                                              char *ifs , char **batch_filename_ptr )
{
  register int i ;
  register char *p ;
  register char *ap ;
  char *end ;
  int instring ;
  int word_has_equals ;
  int seen_nonequals ;
  int last_argument_was_empty ;
  char **new_argv ;
  unsigned short const **tmp ;
  int tmp___0 ;
  size_t tmp___1 ;
  char *tmp___2 ;
  char *tmp___3 ;
  char *tmp___4 ;
  char *tmp___5 ;
  char *tmp___6 ;
  char *tmp___7 ;
  size_t tmp___8 ;
  char *tmp___9 ;
  char *tmp___10 ;
  char *tmp___11 ;
  char *tmp___12 ;
  register int j ;
  int tmp___13 ;
  char *tmp___14 ;
  char *tmp___15 ;
  register int j___0 ;
  int tmp___16 ;
  unsigned int shell_len ;
  size_t tmp___17 ;
  unsigned int line_len ;
  size_t tmp___18 ;
  char *new_line ;
  void *tmp___19 ;
  char *command_ptr ;
  size_t tmp___20 ;
  char *tmp___21 ;
  char *tmp___22 ;
  char *tmp___23 ;
  unsigned short const **tmp___24 ;
  char *tmp___25 ;
  char *tmp___26 ;
  char *tmp___27 ;

  {
# 2430 "job.c"
  new_argv = (char **)0;
# 2443 "job.c"
  if ((unsigned long )restp != (unsigned long )((void *)0)) {
# 2444 "job.c"
    *restp = (char *)((void *)0);
  }
  {
# 2447 "job.c"
  while (1) {
    while_continue: ;
    {
# 2447 "job.c"
    tmp = __ctype_b_loc();
    }
# 2447 "job.c"
    if (! ((int const )*(*tmp + (int )*line) & 1)) {
# 2447 "job.c"
      goto while_break;
    }
# 2448 "job.c"
    line ++;
  }
  while_break: ;
  }
# 2449 "job.c"
  if ((int )*line == 0) {
# 2450 "job.c"
    return ((char **)0);
  }
# 2453 "job.c"
  if ((unsigned long )shell == (unsigned long )((char *)0)) {
# 2454 "job.c"
    shell = default_shell;
  } else {
    {
# 2491 "job.c"
    tmp___0 = strcmp((char const *)shell, (char const *)(default_shell));
    }
# 2491 "job.c"
    if (tmp___0) {
# 2492 "job.c"
      goto slow;
    }
  }
# 2496 "job.c"
  if ((unsigned long )ifs != (unsigned long )((char *)0)) {
# 2497 "job.c"
    ap = ifs;
    {
# 2497 "job.c"
    while (1) {
      while_continue___0: ;
# 2497 "job.c"
      if (! ((int )*ap != 0)) {
# 2497 "job.c"
        goto while_break___0;
      }
# 2498 "job.c"
      if ((int )*ap != 32) {
# 2498 "job.c"
        if ((int )*ap != 9) {
# 2498 "job.c"
          if ((int )*ap != 10) {
# 2499 "job.c"
            goto slow;
          }
        }
      }
# 2497 "job.c"
      ap ++;
    }
    while_break___0: ;
    }
  }
  {
# 2501 "job.c"
  tmp___1 = strlen((char const *)line);
# 2501 "job.c"
  i = (int )(tmp___1 + 1UL);
# 2504 "job.c"
  tmp___2 = xmalloc((unsigned int )((unsigned long )i * sizeof(char *)));
# 2504 "job.c"
  new_argv = (char **)tmp___2;
# 2507 "job.c"
  tmp___4 = xmalloc((unsigned int )i);
# 2507 "job.c"
  tmp___3 = tmp___4;
# 2507 "job.c"
  *(new_argv + 0) = tmp___3;
# 2507 "job.c"
  ap = tmp___3;
# 2508 "job.c"
  end = ap + i;
# 2511 "job.c"
  i = 0;
# 2512 "job.c"
  last_argument_was_empty = 0;
# 2512 "job.c"
  seen_nonequals = last_argument_was_empty;
# 2512 "job.c"
  word_has_equals = seen_nonequals;
# 2512 "job.c"
  instring = word_has_equals;
# 2513 "job.c"
  p = line;
  }
  {
# 2513 "job.c"
  while (1) {
    while_continue___1: ;
# 2513 "job.c"
    if (! ((int )*p != 0)) {
# 2513 "job.c"
      goto while_break___1;
    }
# 2515 "job.c"
    if ((unsigned long )ap > (unsigned long )end) {
      {
# 2516 "job.c"
      abort();
      }
    }
# 2518 "job.c"
    if (instring) {
      string_char:
# 2523 "job.c"
      if ((int )*p == instring) {
# 2525 "job.c"
        instring = 0;
# 2526 "job.c"
        if ((unsigned long )ap == (unsigned long )*(new_argv + 0)) {
# 2527 "job.c"
          last_argument_was_empty = 1;
        } else
# 2526 "job.c"
        if ((int )*(ap - 1) == 0) {
# 2527 "job.c"
          last_argument_was_empty = 1;
        }
      } else
# 2529 "job.c"
      if ((int )*p == 92) {
# 2529 "job.c"
        if ((int )*(p + 1) == 10) {
# 2530 "job.c"
          goto swallow_escaped_newline;
        } else {
# 2529 "job.c"
          goto _L___0;
        }
      } else
      _L___0:
# 2531 "job.c"
      if ((int )*p == 10) {
# 2531 "job.c"
        if ((unsigned long )restp != (unsigned long )((void *)0)) {
# 2534 "job.c"
          *restp = p;
# 2535 "job.c"
          goto end_of_line;
        } else {
# 2531 "job.c"
          goto _L;
        }
      } else
      _L:
# 2541 "job.c"
      if (instring == 34) {
        {
# 2541 "job.c"
        tmp___6 = strchr("\\$`", (int )*p);
        }
# 2541 "job.c"
        if ((unsigned long )tmp___6 != (unsigned long )((char *)0)) {
# 2541 "job.c"
          if (unixy_shell) {
# 2542 "job.c"
            goto slow;
          } else {
# 2544 "job.c"
            tmp___5 = ap;
# 2544 "job.c"
            ap ++;
# 2544 "job.c"
            *tmp___5 = *p;
          }
        } else {
# 2544 "job.c"
          tmp___5 = ap;
# 2544 "job.c"
          ap ++;
# 2544 "job.c"
          *tmp___5 = *p;
        }
      } else {
# 2544 "job.c"
        tmp___5 = ap;
# 2544 "job.c"
        ap ++;
# 2544 "job.c"
        *tmp___5 = *p;
      }
    } else {
      {
# 2546 "job.c"
      tmp___15 = strchr((char const *)(sh_chars), (int )*p);
      }
# 2546 "job.c"
      if ((unsigned long )tmp___15 != (unsigned long )((char *)0)) {
# 2548 "job.c"
        goto slow;
      } else {
        {
# 2557 "job.c"
        if ((int )*p == 61) {
# 2557 "job.c"
          goto case_61;
        }
# 2568 "job.c"
        if ((int )*p == 92) {
# 2568 "job.c"
          goto case_92;
        }
# 2635 "job.c"
        if ((int )*p == 39) {
# 2635 "job.c"
          goto case_39;
        }
# 2635 "job.c"
        if ((int )*p == 34) {
# 2635 "job.c"
          goto case_39;
        }
# 2639 "job.c"
        if ((int )*p == 10) {
# 2639 "job.c"
          goto case_10;
        }
# 2653 "job.c"
        if ((int )*p == 32) {
# 2653 "job.c"
          goto end_of_arg;
        }
# 2653 "job.c"
        if ((int )*p == 9) {
# 2653 "job.c"
          goto end_of_arg;
        }
# 2686 "job.c"
        goto switch_default;
        case_61:
# 2563 "job.c"
        if (! seen_nonequals) {
# 2563 "job.c"
          if (unixy_shell) {
# 2564 "job.c"
            goto slow;
          }
        }
# 2565 "job.c"
        word_has_equals = 1;
# 2566 "job.c"
        tmp___7 = ap;
# 2566 "job.c"
        ap ++;
# 2566 "job.c"
        *tmp___7 = (char )'=';
# 2567 "job.c"
        goto switch_break;
        case_92:
# 2571 "job.c"
        if ((int )*(p + 1) == 10) {
          swallow_escaped_newline:
# 2577 "job.c"
          p += 2;
# 2583 "job.c"
          if ((int )*p == 9) {
            {
# 2587 "job.c"
            tmp___8 = strlen((char const *)p);
# 2587 "job.c"
            memmove((void *)p, (void const *)(p + 1), tmp___8);
            }
          }
# 2589 "job.c"
          if (instring) {
# 2590 "job.c"
            goto string_char;
          } else
# 2593 "job.c"
          if ((unsigned long )ap != (unsigned long )*(new_argv + i)) {
# 2597 "job.c"
            goto end_of_arg;
          } else {
            {
# 2599 "job.c"
            tmp___9 = next_token(p);
# 2599 "job.c"
            p = tmp___9 - 1;
            }
          }
        } else
# 2602 "job.c"
        if ((int )*(p + 1) != 0) {
# 2631 "job.c"
          tmp___10 = ap;
# 2631 "job.c"
          ap ++;
# 2631 "job.c"
          p ++;
# 2631 "job.c"
          *tmp___10 = *p;
        }
# 2633 "job.c"
        goto switch_break;
        case_39:
        case_34:
# 2637 "job.c"
        instring = (int )*p;
# 2638 "job.c"
        goto switch_break;
        case_10:
# 2641 "job.c"
        if ((unsigned long )restp != (unsigned long )((void *)0)) {
# 2644 "job.c"
          *restp = p;
# 2645 "job.c"
          goto end_of_line;
        } else {
# 2649 "job.c"
          tmp___11 = ap;
# 2649 "job.c"
          ap ++;
# 2649 "job.c"
          *tmp___11 = (char )'\n';
        }
# 2650 "job.c"
        goto switch_break;
        end_of_arg:
        case_32:
        case_9:
# 2657 "job.c"
        tmp___12 = ap;
# 2657 "job.c"
        ap ++;
# 2657 "job.c"
        *tmp___12 = (char )'\000';
# 2658 "job.c"
        i ++;
# 2658 "job.c"
        *(new_argv + i) = ap;
# 2659 "job.c"
        last_argument_was_empty = 0;
# 2663 "job.c"
        seen_nonequals |= ! word_has_equals;
# 2664 "job.c"
        if (word_has_equals) {
# 2664 "job.c"
          if (! seen_nonequals) {
# 2667 "job.c"
            goto slow;
          }
        }
# 2668 "job.c"
        word_has_equals = 0;
# 2673 "job.c"
        if (i == 1) {
# 2676 "job.c"
          j = 0;
          {
# 2676 "job.c"
          while (1) {
            while_continue___2: ;
# 2676 "job.c"
            if (! ((unsigned long )sh_cmds[j] != (unsigned long )((char *)0))) {
# 2676 "job.c"
              goto while_break___2;
            }
# 2677 "job.c"
            if ((unsigned long )sh_cmds[j] == (unsigned long )*(new_argv + 0)) {
# 2678 "job.c"
              goto slow;
            } else
# 2677 "job.c"
            if ((int )*(sh_cmds[j]) == (int )*(*(new_argv + 0))) {
# 2677 "job.c"
              if ((int )*(sh_cmds[j]) == 0) {
# 2678 "job.c"
                goto slow;
              } else {
                {
# 2677 "job.c"
                tmp___13 = strcmp((char const *)(sh_cmds[j] + 1), (char const *)(*(new_argv + 0) + 1));
                }
# 2677 "job.c"
                if (! tmp___13) {
# 2678 "job.c"
                  goto slow;
                }
              }
            }
# 2676 "job.c"
            j ++;
          }
          while_break___2: ;
          }
        }
        {
# 2682 "job.c"
        p = next_token(p);
# 2684 "job.c"
        p --;
        }
# 2685 "job.c"
        goto switch_break;
        switch_default:
# 2688 "job.c"
        tmp___14 = ap;
# 2688 "job.c"
        ap ++;
# 2688 "job.c"
        *tmp___14 = *p;
# 2689 "job.c"
        goto switch_break;
        switch_break: ;
        }
      }
    }
# 2513 "job.c"
    p ++;
  }
  while_break___1: ;
  }
  end_of_line:
# 2694 "job.c"
  if (instring) {
# 2696 "job.c"
    goto slow;
  }
# 2700 "job.c"
  *ap = (char )'\000';
# 2701 "job.c"
  if ((int )*(*(new_argv + i) + 0) != 0) {
# 2702 "job.c"
    i ++;
  } else
# 2701 "job.c"
  if (last_argument_was_empty) {
# 2702 "job.c"
    i ++;
  }
# 2703 "job.c"
  *(new_argv + i) = (char *)0;
# 2705 "job.c"
  if (i == 1) {
# 2708 "job.c"
    j___0 = 0;
    {
# 2708 "job.c"
    while (1) {
      while_continue___3: ;
# 2708 "job.c"
      if (! ((unsigned long )sh_cmds[j___0] != (unsigned long )((char *)0))) {
# 2708 "job.c"
        goto while_break___3;
      }
# 2709 "job.c"
      if ((unsigned long )sh_cmds[j___0] == (unsigned long )*(new_argv + 0)) {
# 2710 "job.c"
        goto slow;
      } else
# 2709 "job.c"
      if ((int )*(sh_cmds[j___0]) == (int )*(*(new_argv + 0))) {
# 2709 "job.c"
        if ((int )*(sh_cmds[j___0]) == 0) {
# 2710 "job.c"
          goto slow;
        } else {
          {
# 2709 "job.c"
          tmp___16 = strcmp((char const *)(sh_cmds[j___0] + 1), (char const *)(*(new_argv + 0) + 1));
          }
# 2709 "job.c"
          if (! tmp___16) {
# 2710 "job.c"
            goto slow;
          }
        }
      }
# 2708 "job.c"
      j___0 ++;
    }
    while_break___3: ;
    }
  }
# 2713 "job.c"
  if ((unsigned long )*(new_argv + 0) == (unsigned long )((char *)0)) {
# 2715 "job.c"
    return ((char **)0);
  } else {
# 2717 "job.c"
    return (new_argv);
  }
  slow: ;
# 2722 "job.c"
  if ((unsigned long )new_argv != (unsigned long )((char **)0)) {
    {
# 2725 "job.c"
    free((void *)*(new_argv + 0));
# 2726 "job.c"
    free((void *)new_argv);
    }
  }
  {
# 2784 "job.c"
  tmp___17 = strlen((char const *)shell);
# 2784 "job.c"
  shell_len = (unsigned int )tmp___17;
# 2790 "job.c"
  tmp___18 = strlen((char const *)line);
# 2790 "job.c"
  line_len = (unsigned int )tmp___18;
# 2792 "job.c"
  tmp___19 = __builtin_alloca((((unsigned long )shell_len + (sizeof(minus_c) - 1UL)) + (unsigned long )(line_len * 2U)) + 1UL);
# 2792 "job.c"
  new_line = (char *)tmp___19;
# 2794 "job.c"
  command_ptr = (char *)((void *)0);
# 2796 "job.c"
  ap = new_line;
# 2797 "job.c"
  memmove((void *)ap, (void const *)shell, (size_t )shell_len);
# 2798 "job.c"
  ap += shell_len;
# 2799 "job.c"
  memmove((void *)ap, (void const *)(minus_c), sizeof(minus_c) - 1UL);
# 2800 "job.c"
  ap += sizeof(minus_c) - 1UL;
# 2801 "job.c"
  command_ptr = ap;
# 2802 "job.c"
  p = line;
  }
  {
# 2802 "job.c"
  while (1) {
    while_continue___4: ;
# 2802 "job.c"
    if (! ((int )*p != 0)) {
# 2802 "job.c"
      goto while_break___4;
    }
# 2804 "job.c"
    if ((unsigned long )restp != (unsigned long )((void *)0)) {
# 2804 "job.c"
      if ((int )*p == 10) {
# 2806 "job.c"
        *restp = p;
# 2807 "job.c"
        goto while_break___4;
      } else {
# 2804 "job.c"
        goto _L___1;
      }
    } else
    _L___1:
# 2809 "job.c"
    if ((int )*p == 92) {
# 2809 "job.c"
      if ((int )*(p + 1) == 10) {
# 2814 "job.c"
        p += 2;
# 2820 "job.c"
        if ((int )*p == 9) {
          {
# 2821 "job.c"
          tmp___20 = strlen((char const *)p);
# 2821 "job.c"
          memmove((void *)p, (void const *)(p + 1), tmp___20);
          }
        }
        {
# 2823 "job.c"
        p = next_token(p);
# 2824 "job.c"
        p --;
        }
# 2825 "job.c"
        if (unixy_shell) {
# 2825 "job.c"
          if (! batch_mode_shell) {
# 2826 "job.c"
            tmp___21 = ap;
# 2826 "job.c"
            ap ++;
# 2826 "job.c"
            *tmp___21 = (char )'\\';
          }
        }
# 2827 "job.c"
        tmp___22 = ap;
# 2827 "job.c"
        ap ++;
# 2827 "job.c"
        *tmp___22 = (char )' ';
# 2828 "job.c"
        goto __Cont;
      }
    }
# 2832 "job.c"
    if (unixy_shell) {
# 2832 "job.c"
      if (! batch_mode_shell) {
# 2832 "job.c"
        if ((int )*p == 92) {
# 2836 "job.c"
          tmp___23 = ap;
# 2836 "job.c"
          ap ++;
# 2836 "job.c"
          *tmp___23 = (char )'\\';
        } else
# 2832 "job.c"
        if ((int )*p == 39) {
# 2836 "job.c"
          tmp___23 = ap;
# 2836 "job.c"
          ap ++;
# 2836 "job.c"
          *tmp___23 = (char )'\\';
        } else
# 2832 "job.c"
        if ((int )*p == 34) {
# 2836 "job.c"
          tmp___23 = ap;
# 2836 "job.c"
          ap ++;
# 2836 "job.c"
          *tmp___23 = (char )'\\';
        } else {
          {
# 2832 "job.c"
          tmp___24 = __ctype_b_loc();
          }
# 2832 "job.c"
          if ((int const )*(*tmp___24 + (int )((unsigned char )*p)) & 8192) {
# 2836 "job.c"
            tmp___23 = ap;
# 2836 "job.c"
            ap ++;
# 2836 "job.c"
            *tmp___23 = (char )'\\';
          } else {
            {
# 2832 "job.c"
            tmp___25 = strchr((char const *)(sh_chars), (int )*p);
            }
# 2832 "job.c"
            if ((unsigned long )tmp___25 != (unsigned long )((char *)0)) {
# 2836 "job.c"
              tmp___23 = ap;
# 2836 "job.c"
              ap ++;
# 2836 "job.c"
              *tmp___23 = (char )'\\';
            }
          }
        }
      }
    }
# 2846 "job.c"
    tmp___26 = ap;
# 2846 "job.c"
    ap ++;
# 2846 "job.c"
    *tmp___26 = *p;
    __Cont:
# 2802 "job.c"
    p ++;
  }
  while_break___4: ;
  }
# 2848 "job.c"
  if ((unsigned long )ap == (unsigned long )(((new_line + shell_len) + sizeof(minus_c)) - 1)) {
# 2850 "job.c"
    return ((char **)0);
  }
# 2851 "job.c"
  *ap = (char )'\000';
# 2905 "job.c"
  if (unixy_shell) {
    {
# 2906 "job.c"
    new_argv = construct_command_argv_internal(new_line, (char **)((void *)0), (char *)0,
                                               (char *)0, (char **)0);
    }
  } else {
    {
# 2924 "job.c"
    tmp___27 = dcgettext((char const *)((void *)0), "%s (line %d) Bad shell context (!unixy && !batch_mode_shell)\n",
                         5);
# 2924 "job.c"
    fatal((struct floc const *)((struct floc *)0), (char const *)tmp___27, "job.c",
          2925);
    }
  }
# 2930 "job.c"
  return (new_argv);
}
}
# 2947 "job.c"
char **construct_command_argv(char *line , char **restp , struct file *file , char **batch_filename_ptr )
{
  char *shell ;
  char *ifs ;
  char **argv ;
  int save ;

  {
  {
# 2999 "job.c"
  save = warn_undefined_variables_flag;
# 3000 "job.c"
  warn_undefined_variables_flag = 0;
# 3002 "job.c"
  shell = allocated_variable_expand_for_file((char *)"$(SHELL)", file);
# 3013 "job.c"
  ifs = allocated_variable_expand_for_file((char *)"$(IFS)", file);
# 3015 "job.c"
  warn_undefined_variables_flag = save;
# 3018 "job.c"
  argv = construct_command_argv_internal(line, restp, shell, ifs, batch_filename_ptr);
# 3020 "job.c"
  free((void *)shell);
# 3021 "job.c"
  free((void *)ifs);
  }
# 3023 "job.c"
  return (argv);
}
}
# 1 "main.o"
#pragma merger("0","/tmp/cil-QjP850rb.i","-g,-O0")
# 122 "/usr/include/locale.h"
extern __attribute__((__nothrow__)) char *( __attribute__((__leaf__)) setlocale)(int __category ,
                                                                                  char const *__locale ) ;
# 109 "gettext.h"
char *textdomain(char const *domainname ) ;
# 114 "gettext.h"
char *bindtextdomain(char const *domainname , char const *dirname ) ;
# 202 "/usr/include/signal.h"
extern __attribute__((__nothrow__)) int ( __attribute__((__nonnull__(1), __leaf__)) sigaddset)(sigset_t *__set ,
                                                                                                int __signo ) ;
# 240 "/usr/include/signal.h"
extern __attribute__((__nothrow__)) int ( __attribute__((__leaf__)) sigaction)(int __sig ,
                                                                                struct sigaction const * __restrict __act ,
                                                                                struct sigaction * __restrict __oact ) ;
# 135 "/usr/include/stdio.h"
extern struct _IO_FILE *stdin ;
# 199 "/usr/include/stdio.h"
extern int fclose(FILE *__stream ) ;
# 265 "/usr/include/stdio.h"
extern __attribute__((__nothrow__)) FILE *( __attribute__((__leaf__)) fdopen)(int __fd ,
                                                                               char const *__modes ) ;
# 304 "/usr/include/stdio.h"
extern __attribute__((__nothrow__)) void ( __attribute__((__leaf__)) setlinebuf)(FILE *__stream ) ;
# 312 "/usr/include/stdio.h"
extern int fprintf(FILE * __restrict __stream , char const * __restrict __format
                   , ...) ;
# 646 "/usr/include/stdio.h"
extern size_t fread(void * __restrict __ptr , size_t __size , size_t __n , FILE * __restrict __stream ) ;
# 652 "/usr/include/stdio.h"
extern size_t fwrite(void const * __restrict __ptr , size_t __size , size_t __n ,
                     FILE * __restrict __s ) ;
# 759 "/usr/include/stdio.h"
extern __attribute__((__nothrow__)) int ( __attribute__((__leaf__)) feof)(FILE *__stream ) ;
# 122 "/usr/include/ctype.h"
extern __attribute__((__nothrow__)) int ( __attribute__((__leaf__)) tolower)(int __c ) ;
# 142 "/usr/include/time.h"
extern __attribute__((__nothrow__)) char *( __attribute__((__leaf__)) ctime)(time_t const *__timer ) ;
# 500 "/usr/include/unistd.h"
extern __attribute__((__nothrow__)) int ( __attribute__((__nonnull__(1), __leaf__)) chdir)(char const *__path ) ;
# 514 "/usr/include/unistd.h"
extern __attribute__((__nothrow__)) char *( __attribute__((__leaf__)) getcwd)(char *__buf ,
                                                                               size_t __size ) ;
# 36 "/usr/include/x86_64-linux-gnu/bits/getopt_core.h"
extern char *optarg ;
# 50 "/usr/include/x86_64-linux-gnu/bits/getopt_core.h"
extern int optind ;
# 55 "/usr/include/x86_64-linux-gnu/bits/getopt_core.h"
extern int opterr ;
# 101 "/usr/include/stdlib.h"
extern __attribute__((__nothrow__)) double ( __attribute__((__nonnull__(1), __leaf__)) atof)(char const *__nptr ) __attribute__((__pure__)) ;
# 685 "/usr/include/stdlib.h"
extern int ( __attribute__((__nonnull__(1))) mkstemp)(char *__template ) ;
# 390 "make.h"
void log_working_directory(int entering ) ;
# 410 "make.h"
FILE *open_tmpfile(char **name , char const *template ) ;
# 425 "make.h"
void define_default_variables(void) ;
# 426 "make.h"
void set_default_suffixes(void) ;
# 427 "make.h"
void install_default_suffix_rules(void) ;
# 428 "make.h"
void install_default_implicit_rules(void) ;
# 430 "make.h"
void build_vpath_lists(void) ;
# 435 "make.h"
void construct_include_path(char **arg_dirs ) ;
# 471 "make.h"
int print_data_base_flag ;
# 472 "make.h"
int env_overrides ;
# 472 "make.h"
int no_builtin_rules_flag ;
# 472 "make.h"
int no_builtin_variables_flag ;
# 473 "make.h"
int print_version_flag ;
# 473 "make.h"
int print_directory_flag ;
# 475 "make.h"
int clock_skew_detected ;
# 489 "make.h"
char *program ;
# 490 "make.h"
char *starting_directory ;
# 491 "make.h"
unsigned int makelevel ;
# 492 "make.h"
char *version_string ;
# 492 "make.h"
char *remote_description ;
# 60 "dep.h"
char *tilde_expand(char *name ) ;
# 74 "dep.h"
struct dep *read_all_makefiles(char **makefiles___0 ) ;
# 75 "dep.h"
int update_goal_chain(struct dep *goals___0 , int makefiles___0 ) ;
# 105 "filedef.h"
struct file *default_goal_file ;
# 104 "variable.h"
void define_automatic_variables(void) ;
# 109 "variable.h"
struct variable *try_variable_definition(struct floc const *flocp , char *line ,
                                         enum variable_origin origin , int target_var ) ;
# 66 "rule.h"
void count_implicit_rule_limits(void) ;
# 67 "rule.h"
void convert_to_pattern(void) ;
# 110 "getopt.h"
extern int getopt_long(int argc , char * const *argv , char const *shortopts ,
                       struct option const *longopts , int *longind ) ;
# 48 "main.c"
void remote_setup(void) ;
# 49 "main.c"
void remote_cleanup(void) ;
# 52 "main.c"
void print_variable_data_base(void) ;
# 54 "main.c"
void print_rule_data_base(void) ;
# 56 "main.c"
void print_vpath_data_base(void) ;
# 72 "main.c"
static void print_data_base(void) ;
# 73 "main.c"
static void print_version(void) ;
# 74 "main.c"
static void decode_switches(int argc , char **argv , int env ) ;
# 75 "main.c"
static void decode_env_switches(char *envar , unsigned int len ) ;
# 76 "main.c"
static void define_makeflags(int all , int makefile ) ;
# 77 "main.c"
static char *quote_for_env(char *out , char *in ) ;
# 143 "main.c"
static struct stringlist *db_flags ;
# 144 "main.c"
static int debug_flag = 0;
# 146 "main.c"
int db_level = 0;
# 156 "main.c"
int env_overrides = 0;
# 161 "main.c"
int ignore_errors_flag = 0;
# 166 "main.c"
int print_data_base_flag = 0;
# 171 "main.c"
int question_flag = 0;
# 175 "main.c"
int no_builtin_rules_flag = 0;
# 176 "main.c"
int no_builtin_variables_flag = 0;
# 181 "main.c"
int default_keep_going_flag = 0;
# 185 "main.c"
int print_directory_flag = 0;
# 190 "main.c"
int inhibit_print_directory_flag = 0;
# 194 "main.c"
int print_version_flag = 0;
# 198 "main.c"
static struct stringlist *makefiles = (struct stringlist *)0;
# 202 "main.c"
unsigned int job_slots = 1U;
# 203 "main.c"
unsigned int default_job_slots = 1U;
# 207 "main.c"
static unsigned int inf_jobs = 0U;
# 211 "main.c"
static struct stringlist *jobserver_fds = (struct stringlist *)0;
# 213 "main.c"
int job_fds[2] = { -1, -1};
# 214 "main.c"
int job_rfd = -1;
# 221 "main.c"
double max_load_average = - 1.0;
# 222 "main.c"
double default_load_average = - 1.0;
# 230 "main.c"
static struct stringlist *directories___0 = (struct stringlist *)0;
# 234 "main.c"
static struct stringlist *include_directories = (struct stringlist *)0;
# 238 "main.c"
static struct stringlist *old_files = (struct stringlist *)0;
# 242 "main.c"
static struct stringlist *new_files = (struct stringlist *)0;
# 246 "main.c"
static int print_usage_flag = 0;
# 255 "main.c"
static struct command_switch const switches[29] =
# 255 "main.c"
  { {'b', (enum __anonenum_type_56 )5, (char *)0, 0U, 0U, 0U, (char *)0, (char *)0,
      (char *)0, (char *)0, (char *)"Ignored for compatibility"},
        {'C', (enum __anonenum_type_56 )2, (char *)(& directories___0), 0U, 0U, 0U, (char *)0,
      (char *)0, (char *)"directory", (char *)"DIRECTORY", (char *)"Change to DIRECTORY before doing anything"},
        {'d',
      (enum __anonenum_type_56 )0, (char *)(& debug_flag), 1U, 1U, 0U, (char *)0,
      (char *)0, (char *)0, (char *)0, (char *)"Print lots of debugging information"},
        {128,
      (enum __anonenum_type_56 )2, (char *)(& db_flags), 1U, 1U, 0U, (char *)"basic",
      (char *)0, (char *)"debug", (char *)"FLAGS", (char *)"Print various types of debugging information"},
        {'e',
      (enum __anonenum_type_56 )0, (char *)(& env_overrides), 1U, 1U, 0U, (char *)0,
      (char *)0, (char *)"environment-overrides", (char *)0, (char *)"Environment variables override makefiles"},
        {'f',
      (enum __anonenum_type_56 )2, (char *)(& makefiles), 0U, 0U, 0U, (char *)0, (char *)0,
      (char *)"file", (char *)"FILE", (char *)"Read FILE as a makefile"},
        {'h', (enum __anonenum_type_56 )0, (char *)(& print_usage_flag), 0U, 0U, 0U,
      (char *)0, (char *)0, (char *)"help", (char *)0, (char *)"Print this message and exit"},
        {'i',
      (enum __anonenum_type_56 )0, (char *)(& ignore_errors_flag), 1U, 1U, 0U, (char *)0,
      (char *)0, (char *)"ignore-errors", (char *)0, (char *)"Ignore errors from commands"},
        {'I',
      (enum __anonenum_type_56 )2, (char *)(& include_directories), 1U, 1U, 0U, (char *)0,
      (char *)0, (char *)"include-dir", (char *)"DIRECTORY", (char *)"Search DIRECTORY for included makefiles"},
        {'j',
      (enum __anonenum_type_56 )3, (char *)(& job_slots), 1U, 1U, 0U, (char *)(& inf_jobs),
      (char *)(& default_job_slots), (char *)"jobs", (char *)"N", (char *)"Allow N jobs at once; infinite jobs with no arg"},
        {129,
      (enum __anonenum_type_56 )2, (char *)(& jobserver_fds), 1U, 1U, 0U, (char *)0,
      (char *)0, (char *)"jobserver-fds", (char *)0, (char *)0},
        {'k', (enum __anonenum_type_56 )0, (char *)(& keep_going_flag), 1U, 1U, 0U, (char *)0,
      (char *)(& default_keep_going_flag), (char *)"keep-going", (char *)0, (char *)"Keep going when some targets can\'t be made"},
        {'l',
      (enum __anonenum_type_56 )4, (char *)(& max_load_average), 1U, 1U, 0U, (char *)(& default_load_average),
      (char *)(& default_load_average), (char *)"load-average", (char *)"N", (char *)"Don\'t start multiple jobs unless load is below N"},
        {'m',
      (enum __anonenum_type_56 )5, (char *)0, 0U, 0U, 0U, (char *)0, (char *)0, (char *)0,
      (char *)0, (char *)"-b"},
        {'n', (enum __anonenum_type_56 )0, (char *)(& just_print_flag), 1U, 1U, 1U, (char *)0,
      (char *)0, (char *)"just-print", (char *)0, (char *)"Don\'t actually run any commands; just print them"},
        {'o',
      (enum __anonenum_type_56 )2, (char *)(& old_files), 0U, 0U, 0U, (char *)0, (char *)0,
      (char *)"old-file", (char *)"FILE", (char *)"Consider FILE to be very old and don\'t remake it"},
        {'p',
      (enum __anonenum_type_56 )0, (char *)(& print_data_base_flag), 1U, 1U, 0U, (char *)0,
      (char *)0, (char *)"print-data-base", (char *)0, (char *)"Print make\'s internal database"},
        {'q',
      (enum __anonenum_type_56 )0, (char *)(& question_flag), 1U, 1U, 1U, (char *)0,
      (char *)0, (char *)"question", (char *)0, (char *)"Run no commands; exit status says if up to date"},
        {'r',
      (enum __anonenum_type_56 )0, (char *)(& no_builtin_rules_flag), 1U, 1U, 0U,
      (char *)0, (char *)0, (char *)"no-builtin-rules", (char *)0, (char *)"Disable the built-in implicit rules"},
        {'R',
      (enum __anonenum_type_56 )0, (char *)(& no_builtin_variables_flag), 1U, 1U,
      0U, (char *)0, (char *)0, (char *)"no-builtin-variables", (char *)0, (char *)"Disable the built-in variable settings"},
        {'s',
      (enum __anonenum_type_56 )0, (char *)(& silent_flag), 1U, 1U, 0U, (char *)0,
      (char *)0, (char *)"silent", (char *)0, (char *)"Don\'t echo commands"},
        {'S', (enum __anonenum_type_56 )1, (char *)(& keep_going_flag), 1U, 1U, 0U, (char *)0,
      (char *)(& default_keep_going_flag), (char *)"no-keep-going", (char *)0, (char *)"Turns off -k"},
        {'t',
      (enum __anonenum_type_56 )0, (char *)(& touch_flag), 1U, 1U, 1U, (char *)0,
      (char *)0, (char *)"touch", (char *)0, (char *)"Touch targets instead of remaking them"},
        {'v',
      (enum __anonenum_type_56 )0, (char *)(& print_version_flag), 1U, 1U, 0U, (char *)0,
      (char *)0, (char *)"version", (char *)0, (char *)"Print the version number of make and exit"},
        {'w',
      (enum __anonenum_type_56 )0, (char *)(& print_directory_flag), 1U, 1U, 0U, (char *)0,
      (char *)0, (char *)"print-directory", (char *)0, (char *)"Print the current directory"},
        {130,
      (enum __anonenum_type_56 )0, (char *)(& inhibit_print_directory_flag), 1U, 1U,
      0U, (char *)0, (char *)0, (char *)"no-print-directory", (char *)0, (char *)"Turn off -w, even if it was turned on implicitly"},
        {'W',
      (enum __anonenum_type_56 )2, (char *)(& new_files), 0U, 0U, 0U, (char *)0, (char *)0,
      (char *)"what-if", (char *)"FILE", (char *)"Consider FILE to be infinitely new"},
        {131,
      (enum __anonenum_type_56 )0, (char *)(& warn_undefined_variables_flag), 1U,
      1U, 0U, (char *)0, (char *)0, (char *)"warn-undefined-variables", (char *)0,
      (char *)"Warn when an undefined variable is referenced"},
        {'\000', (enum __anonenum_type_56 )0U, (char *)0, 0U, 0U, 0U, (char *)0, (char *)0,
      (char *)0, (char *)0, (char *)0}};
# 364 "main.c"
static struct option long_option_aliases[9] =
# 364 "main.c"
  { {"quiet", 0, (int *)0, 's'},
        {"stop", 0, (int *)0, 'S'},
        {"new-file", 1, (int *)0, 'W'},
        {"assume-new", 1, (int *)0, 'W'},
        {"assume-old", 1, (int *)0, 'o'},
        {"max-load", 2, (int *)0, 'l'},
        {"dry-run", 0, (int *)0, 'n'},
        {"recon", 0, (int *)0, 'n'},
        {"makefile", 1, (int *)0, 'f'}};
# 385 "main.c"
static struct dep *goals ;
# 385 "main.c"
static struct dep *lastgoal ;
# 395 "main.c"
static struct command_variable *command_variables ;
# 403 "main.c"
char *directory_before_chdir ;
# 451 "main.c"
static struct file *enter_command_line_file(char *name )
{
  char *tmp ;
  char *expanded ;
  char *tmp___0 ;
  char *tmp___1 ;
  struct file *tmp___2 ;

  {
# 455 "main.c"
  if ((int )*(name + 0) == 0) {
    {
# 456 "main.c"
    tmp = dcgettext((char const *)((void *)0), "empty string invalid as file name",
                    5);
# 456 "main.c"
    fatal((struct floc const *)((struct floc *)0), (char const *)tmp);
    }
  }
# 458 "main.c"
  if ((int )*(name + 0) == 126) {
    {
# 460 "main.c"
    tmp___0 = tilde_expand(name);
# 460 "main.c"
    expanded = tmp___0;
    }
# 461 "main.c"
    if ((unsigned long )expanded != (unsigned long )((char *)0)) {
# 462 "main.c"
      name = expanded;
    }
  }
  {
# 468 "main.c"
  while (1) {
    while_continue: ;
# 468 "main.c"
    if ((int )*(name + 0) == 46) {
# 468 "main.c"
      if ((int )*(name + 1) == 47) {
# 468 "main.c"
        if (! ((int )*(name + 2) != 0)) {
# 468 "main.c"
          goto while_break;
        }
      } else {
# 468 "main.c"
        goto while_break;
      }
    } else {
# 468 "main.c"
      goto while_break;
    }
# 470 "main.c"
    name += 2;
    {
# 471 "main.c"
    while (1) {
      while_continue___0: ;
# 471 "main.c"
      if (! ((int )*name == 47)) {
# 471 "main.c"
        goto while_break___0;
      }
# 473 "main.c"
      name ++;
    }
    while_break___0: ;
    }
  }
  while_break: ;
  }
# 476 "main.c"
  if ((int )*name == 0) {
    {
# 480 "main.c"
    while (1) {
      while_continue___1: ;
# 481 "main.c"
      name --;
# 480 "main.c"
      if (! ((int )*(name + 0) != 46)) {
# 480 "main.c"
        goto while_break___1;
      }
    }
    while_break___1: ;
    }
# 483 "main.c"
    *(name + 2) = (char )'\000';
  }
  {
# 486 "main.c"
  tmp___1 = xstrdup((char const *)name);
# 486 "main.c"
  tmp___2 = enter_file(tmp___1);
  }
# 486 "main.c"
  return (tmp___2);
}
}
# 491 "main.c"
static void debug_signal_handler(int sig )
{


  {
# 495 "main.c"
  if (db_level) {
# 495 "main.c"
    db_level = 0;
  } else {
# 495 "main.c"
    db_level = 1;
  }
# 496 "main.c"
  return;
}
}
# 498 "main.c"
static void decode_debug_flags(void)
{
  char **pp ;
  char const *p ;
  int tmp ;
  char *tmp___0 ;

  {
# 503 "main.c"
  if (debug_flag) {
# 504 "main.c"
    db_level = 4095;
  }
# 506 "main.c"
  if (! db_flags) {
# 507 "main.c"
    return;
  }
# 509 "main.c"
  pp = db_flags->list;
  {
# 509 "main.c"
  while (1) {
    while_continue: ;
# 509 "main.c"
    if (! *pp) {
# 509 "main.c"
      goto while_break;
    }
# 511 "main.c"
    p = (char const *)*pp;
    {
# 513 "main.c"
    while (1) {
      while_continue___0: ;
      {
# 515 "main.c"
      tmp = tolower((int )*(p + 0));
      }
      {
# 516 "main.c"
      if (tmp == 97) {
# 516 "main.c"
        goto case_97;
      }
# 520 "main.c"
      if (tmp == 98) {
# 520 "main.c"
        goto case_98;
      }
# 523 "main.c"
      if (tmp == 105) {
# 523 "main.c"
        goto case_105;
      }
# 526 "main.c"
      if (tmp == 106) {
# 526 "main.c"
        goto case_106;
      }
# 529 "main.c"
      if (tmp == 109) {
# 529 "main.c"
        goto case_109;
      }
# 532 "main.c"
      if (tmp == 118) {
# 532 "main.c"
        goto case_118;
      }
# 535 "main.c"
      goto switch_default;
      case_97:
# 518 "main.c"
      db_level |= 4095;
# 519 "main.c"
      goto switch_break;
      case_98:
# 521 "main.c"
      db_level |= 1;
# 522 "main.c"
      goto switch_break;
      case_105:
# 524 "main.c"
      db_level |= 9;
# 525 "main.c"
      goto switch_break;
      case_106:
# 527 "main.c"
      db_level |= 4;
# 528 "main.c"
      goto switch_break;
      case_109:
# 530 "main.c"
      db_level |= 257;
# 531 "main.c"
      goto switch_break;
      case_118:
# 533 "main.c"
      db_level |= 3;
# 534 "main.c"
      goto switch_break;
      switch_default:
      {
# 536 "main.c"
      tmp___0 = dcgettext((char const *)((void *)0), "unknown debug level specification `%s\'",
                          5);
# 536 "main.c"
      fatal((struct floc const *)((struct floc *)0), (char const *)tmp___0, p);
      }
      switch_break: ;
      }
      {
# 539 "main.c"
      while (1) {
        while_continue___1: ;
# 539 "main.c"
        p ++;
# 539 "main.c"
        if (! ((int const )*p != 0)) {
# 539 "main.c"
          goto while_break___1;
        }
# 540 "main.c"
        if ((int const )*p == 44) {
# 541 "main.c"
          goto while_break___1;
        } else
# 540 "main.c"
        if ((int const )*p == 32) {
# 541 "main.c"
          goto while_break___1;
        }
      }
      while_break___1: ;
      }
# 543 "main.c"
      if ((int const )*p == 0) {
# 544 "main.c"
        goto while_break___0;
      }
# 546 "main.c"
      p ++;
    }
    while_break___0: ;
    }
# 509 "main.c"
    pp ++;
  }
  while_break: ;
  }
# 549 "main.c"
  return;
}
}
# 733 "main.c"
FILE *open_tmpfile(char **name , char const *template )
{
  int fd ;
  size_t tmp ;
  FILE *tmp___0 ;

  {
  {
# 745 "main.c"
  tmp = strlen(template);
# 745 "main.c"
  *name = xmalloc((unsigned int )(tmp + 1UL));
# 746 "main.c"
  strcpy((char * __restrict )*name, (char const * __restrict )template);
# 750 "main.c"
  fd = mkstemp(*name);
  }
# 751 "main.c"
  if (fd == -1) {
# 752 "main.c"
    return ((FILE *)0);
  }
  {
# 753 "main.c"
  tmp___0 = fdopen(fd, "w");
  }
# 753 "main.c"
  return (tmp___0);
}
}
# 785 "main.c"
int main(int argc , char **argv , char **envp ) ;
# 785 "main.c"
static char *stdin_nm = (char *)0;
# 776 "main.c"
int main(int argc , char **argv , char **envp )
{
  register struct file *f ;
  register unsigned int i ;
  char **p ;
  struct dep *read_makefiles___0 ;
  char current_directory[4096] ;
  void (*tmp)(int ) ;
  void (*tmp___0)(int ) ;
  void (*tmp___1)(int ) ;
  void (*tmp___2)(int ) ;
  void (*tmp___3)(int ) ;
  void (*tmp___4)(int ) ;
  char *tmp___5 ;
  int do_not_define ;
  register char *ep ;
  struct variable *tmp___6 ;
  char *tmp___7 ;
  struct command_variable *cv ;
  struct variable *v ;
  unsigned int len ;
  char *value ;
  char *p___0 ;
  size_t tmp___8 ;
  size_t tmp___9 ;
  void *tmp___10 ;
  char *tmp___11 ;
  char *tmp___12 ;
  char *tmp___13 ;
  char *dir ;
  char *expanded ;
  char *tmp___14 ;
  int tmp___15 ;
  struct variable *v___0 ;
  struct variable *tmp___16 ;
  int tmp___17 ;
  char **tmp___18 ;
  char *tmp___19 ;
  register unsigned int i___0 ;
  FILE *outfile ;
  char *tmp___20 ;
  char *tmp___21 ;
  char buf___1[2048] ;
  unsigned int n ;
  size_t tmp___22 ;
  char *tmp___23 ;
  size_t tmp___24 ;
  int tmp___25 ;
  struct sigaction sa ;
  char **tmp___26 ;
  char *cp ;
  char *tmp___27 ;
  int tmp___28 ;
  char *tmp___29 ;
  int tmp___30 ;
  char *tmp___31 ;
  char *tmp___32 ;
  int *tmp___33 ;
  char *tmp___34 ;
  char c ;
  char *tmp___35 ;
  int tmp___36 ;
  char *tmp___37 ;
  int *tmp___38 ;
  ssize_t tmp___39 ;
  char *tmp___40 ;
  char *tmp___41 ;
  uintmax_t tmp___42 ;
  uintmax_t tmp___43 ;
  uintmax_t *makefile_mtimes ;
  unsigned int mm_idx ;
  char **nargv ;
  int nargc ;
  int orig_db_level ;
  char *tmp___44 ;
  register struct dep *d ;
  register struct dep *last ;
  register struct file *f___0 ;
  char *tmp___45 ;
  char *tmp___46 ;
  unsigned int tmp___47 ;
  uintmax_t tmp___48 ;
  int tmp___49 ;
  int any_remade ;
  int any_failed ;
  register unsigned int i___1 ;
  struct dep *d___0 ;
  uintmax_t tmp___50 ;
  uintmax_t tmp___51 ;
  uintmax_t mtime ;
  char *tmp___52 ;
  uintmax_t tmp___53 ;
  int tmp___54 ;
  char *tmp___55 ;
  char *tmp___56 ;
  char *tmp___57 ;
  char *tmp___58 ;
  register unsigned int i___2 ;
  register unsigned int j ;
  char *p___1 ;
  int tmp___59 ;
  char *tmp___60 ;
  int tmp___61 ;
  char bad ;
  int tmp___62 ;
  char *tmp___63 ;
  char *sgi_loses ;
  void *tmp___64 ;
  int tmp___65 ;
  char **p___2 ;
  char *tmp___66 ;
  char *tmp___67 ;
  int tmp___68 ;
  int *tmp___69 ;
  int status ;
  char *tmp___70 ;
  char *tmp___71 ;
  char *tmp___72 ;
  char *tmp___73 ;
  int tmp___74 ;
  char *tmp___75 ;

  {
  {
# 802 "main.c"
  default_goal_file = (struct file *)0;
# 803 "main.c"
  reading_file = (struct floc const *)0;
# 818 "main.c"
  setlocale(6, "");
# 819 "main.c"
  bindtextdomain("make", "/usr/local/share/locale");
# 820 "main.c"
  textdomain("make");
# 830 "main.c"
  sigemptyset(& fatal_signal_set);
# 848 "main.c"
  tmp = signal(1, & fatal_error_signal);
  }
# 848 "main.c"
  if ((unsigned long )tmp == (unsigned long )((void (*)(int ))1)) {
    {
# 848 "main.c"
    signal(1, (void (*)(int ))1);
    }
  } else {
    {
# 848 "main.c"
    sigaddset(& fatal_signal_set, 1);
    }
  }
  {
# 851 "main.c"
  tmp___0 = signal(3, & fatal_error_signal);
  }
# 851 "main.c"
  if ((unsigned long )tmp___0 == (unsigned long )((void (*)(int ))1)) {
    {
# 851 "main.c"
    signal(3, (void (*)(int ))1);
    }
  } else {
    {
# 851 "main.c"
    sigaddset(& fatal_signal_set, 3);
    }
  }
  {
# 853 "main.c"
  tmp___1 = signal(2, & fatal_error_signal);
  }
# 853 "main.c"
  if ((unsigned long )tmp___1 == (unsigned long )((void (*)(int ))1)) {
    {
# 853 "main.c"
    signal(2, (void (*)(int ))1);
    }
  } else {
    {
# 853 "main.c"
    sigaddset(& fatal_signal_set, 2);
    }
  }
  {
# 854 "main.c"
  tmp___2 = signal(15, & fatal_error_signal);
  }
# 854 "main.c"
  if ((unsigned long )tmp___2 == (unsigned long )((void (*)(int ))1)) {
    {
# 854 "main.c"
    signal(15, (void (*)(int ))1);
    }
  } else {
    {
# 854 "main.c"
    sigaddset(& fatal_signal_set, 15);
    }
  }
  {
# 860 "main.c"
  tmp___3 = signal(24, & fatal_error_signal);
  }
# 860 "main.c"
  if ((unsigned long )tmp___3 == (unsigned long )((void (*)(int ))1)) {
    {
# 860 "main.c"
    signal(24, (void (*)(int ))1);
    }
  } else {
    {
# 860 "main.c"
    sigaddset(& fatal_signal_set, 24);
    }
  }
  {
# 863 "main.c"
  tmp___4 = signal(25, & fatal_error_signal);
  }
# 863 "main.c"
  if ((unsigned long )tmp___4 == (unsigned long )((void (*)(int ))1)) {
    {
# 863 "main.c"
    signal(25, (void (*)(int ))1);
    }
  } else {
    {
# 863 "main.c"
    sigaddset(& fatal_signal_set, 25);
    }
  }
  {
# 875 "main.c"
  signal(17, (void (*)(int ))0);
# 885 "main.c"
  setlinebuf(stdout);
  }
# 897 "main.c"
  if ((unsigned long )*(argv + 0) == (unsigned long )((char *)0)) {
# 898 "main.c"
    *(argv + 0) = (char *)"";
  }
# 899 "main.c"
  if ((int )*(*(argv + 0) + 0) == 0) {
# 900 "main.c"
    program = (char *)"make";
  } else {
    {
# 906 "main.c"
    program = strrchr((char const *)*(argv + 0), '/');
    }
# 922 "main.c"
    if ((unsigned long )program == (unsigned long )((char *)0)) {
# 923 "main.c"
      program = *(argv + 0);
    } else {
# 925 "main.c"
      program ++;
    }
  }
  {
# 929 "main.c"
  user_access();
# 936 "main.c"
  tmp___5 = getcwd(current_directory, (size_t )4096);
  }
# 936 "main.c"
  if ((unsigned long )tmp___5 == (unsigned long )((char *)0)) {
    {
# 940 "main.c"
    perror_with_name((char *)"getcwd: ", (char *)"");
# 944 "main.c"
    current_directory[0] = (char )'\000';
# 945 "main.c"
    directory_before_chdir = (char *)0;
    }
  } else {
    {
# 948 "main.c"
    directory_before_chdir = xstrdup((char const *)(current_directory));
    }
  }
# 959 "main.c"
  i = 0U;
  {
# 959 "main.c"
  while (1) {
    while_continue: ;
# 959 "main.c"
    if (! ((unsigned long )*(envp + i) != (unsigned long )((char *)0))) {
# 959 "main.c"
      goto while_break;
    }
# 962 "main.c"
    ep = *(envp + i);
# 965 "main.c"
    do_not_define = 0;
    {
# 967 "main.c"
    while (1) {
      while_continue___0: ;
# 967 "main.c"
      if (! ((int )*ep != 61)) {
# 967 "main.c"
        goto while_break___0;
      }
# 968 "main.c"
      ep ++;
    }
    while_break___0: ;
    }
# 980 "main.c"
    if (! do_not_define) {
      {
# 981 "main.c"
      tmp___6 = define_variable_in_set(*(envp + i), (unsigned int )(ep - *(envp + i)),
                                       ep + 1, (enum variable_origin )1, 1, current_variable_set_list->set,
                                       (struct floc const *)((struct floc *)0));
# 981 "main.c"
      tmp___6->export = (enum variable_export )0;
      }
    }
# 959 "main.c"
    i ++;
  }
  while_break: ;
  }
  {
# 1040 "main.c"
  decode_env_switches((char *)"MAKEFLAGS", 9U);
# 1047 "main.c"
  decode_switches(argc, argv, 0);
# 1057 "main.c"
  decode_debug_flags();
  }
# 1061 "main.c"
  if (print_version_flag) {
    {
# 1062 "main.c"
    print_version();
    }
  } else
# 1061 "main.c"
  if (print_data_base_flag) {
    {
# 1062 "main.c"
    print_version();
    }
  } else
# 1061 "main.c"
  if (db_level) {
    {
# 1062 "main.c"
    print_version();
    }
  }
# 1065 "main.c"
  if (print_version_flag) {
    {
# 1066 "main.c"
    die(0);
    }
  }
# 1104 "main.c"
  if ((int )current_directory[0] != 0) {
# 1104 "main.c"
    if ((unsigned long )*(argv + 0) != (unsigned long )((char *)0)) {
# 1104 "main.c"
      if ((int )*(*(argv + 0) + 0) != 47) {
        {
# 1104 "main.c"
        tmp___7 = strchr((char const *)*(argv + 0), '/');
        }
# 1104 "main.c"
        if ((unsigned long )tmp___7 != (unsigned long )((char *)0)) {
          {
# 1106 "main.c"
          *(argv + 0) = concat(current_directory, (char *)"/", *(argv + 0));
          }
        }
      }
    }
  }
  {
# 1113 "main.c"
  define_variable_in_set((char *)"MAKE_COMMAND", 12U, *(argv + 0), (enum variable_origin )0,
                         0, current_variable_set_list->set, (struct floc const *)((struct floc *)0));
# 1114 "main.c"
  define_variable_in_set((char *)"MAKE", 4U, (char *)"$(MAKE_COMMAND)", (enum variable_origin )0,
                         1, current_variable_set_list->set, (struct floc const *)((struct floc *)0));
  }
# 1116 "main.c"
  if ((unsigned long )command_variables != (unsigned long )((struct command_variable *)0)) {
# 1120 "main.c"
    len = 0U;
# 1125 "main.c"
    cv = command_variables;
    {
# 1125 "main.c"
    while (1) {
      while_continue___1: ;
# 1125 "main.c"
      if (! ((unsigned long )cv != (unsigned long )((struct command_variable *)0))) {
# 1125 "main.c"
        goto while_break___1;
      }
      {
# 1127 "main.c"
      v = cv->variable;
# 1128 "main.c"
      tmp___8 = strlen((char const *)v->name);
# 1128 "main.c"
      len = (unsigned int )((size_t )len + 2UL * tmp___8);
      }
# 1129 "main.c"
      if (! v->recursive) {
# 1130 "main.c"
        len ++;
      }
      {
# 1131 "main.c"
      len ++;
# 1132 "main.c"
      tmp___9 = strlen((char const *)v->value);
# 1132 "main.c"
      len = (unsigned int )((size_t )len + 2UL * tmp___9);
# 1133 "main.c"
      len ++;
# 1125 "main.c"
      cv = cv->next;
      }
    }
    while_break___1: ;
    }
    {
# 1137 "main.c"
    tmp___10 = __builtin_alloca((unsigned long )len);
# 1137 "main.c"
    value = (char *)tmp___10;
# 1137 "main.c"
    p___0 = value;
# 1138 "main.c"
    cv = command_variables;
    }
    {
# 1138 "main.c"
    while (1) {
      while_continue___2: ;
# 1138 "main.c"
      if (! ((unsigned long )cv != (unsigned long )((struct command_variable *)0))) {
# 1138 "main.c"
        goto while_break___2;
      }
      {
# 1140 "main.c"
      v = cv->variable;
# 1141 "main.c"
      p___0 = quote_for_env(p___0, v->name);
      }
# 1142 "main.c"
      if (! v->recursive) {
# 1143 "main.c"
        tmp___11 = p___0;
# 1143 "main.c"
        p___0 ++;
# 1143 "main.c"
        *tmp___11 = (char )':';
      }
      {
# 1144 "main.c"
      tmp___12 = p___0;
# 1144 "main.c"
      p___0 ++;
# 1144 "main.c"
      *tmp___12 = (char )'=';
# 1145 "main.c"
      p___0 = quote_for_env(p___0, v->value);
# 1146 "main.c"
      tmp___13 = p___0;
# 1146 "main.c"
      p___0 ++;
# 1146 "main.c"
      *tmp___13 = (char )' ';
# 1138 "main.c"
      cv = cv->next;
      }
    }
    while_break___2: ;
    }
    {
# 1148 "main.c"
    *(p___0 + -1) = (char )'\000';
# 1152 "main.c"
    define_variable_in_set((char *)"-*-command-variables-*-", 23U, value, (enum variable_origin )6,
                           0, current_variable_set_list->set, (struct floc const *)((struct floc *)0));
# 1161 "main.c"
    define_variable_in_set((char *)"MAKEOVERRIDES", 13U, (char *)"${-*-command-variables-*-}",
                           (enum variable_origin )1, 1, current_variable_set_list->set,
                           (struct floc const *)((struct floc *)0));
    }
  }
# 1166 "main.c"
  if ((unsigned long )directories___0 != (unsigned long )((struct stringlist *)0)) {
# 1167 "main.c"
    i = 0U;
    {
# 1167 "main.c"
    while (1) {
      while_continue___3: ;
# 1167 "main.c"
      if (! ((unsigned long )*(directories___0->list + i) != (unsigned long )((char *)0))) {
# 1167 "main.c"
        goto while_break___3;
      }
# 1169 "main.c"
      dir = *(directories___0->list + i);
# 1170 "main.c"
      if ((int )*(dir + 0) == 126) {
        {
# 1172 "main.c"
        tmp___14 = tilde_expand(dir);
# 1172 "main.c"
        expanded = tmp___14;
        }
# 1173 "main.c"
        if ((unsigned long )expanded != (unsigned long )((char *)0)) {
# 1174 "main.c"
          dir = expanded;
        }
      }
      {
# 1176 "main.c"
      tmp___15 = chdir((char const *)dir);
      }
# 1176 "main.c"
      if (tmp___15 < 0) {
        {
# 1177 "main.c"
        pfatal_with_name(dir);
        }
      }
# 1178 "main.c"
      if ((unsigned long )dir != (unsigned long )*(directories___0->list + i)) {
        {
# 1179 "main.c"
        free((void *)dir);
        }
      }
# 1167 "main.c"
      i ++;
    }
    while_break___3: ;
    }
  }
  {
# 1197 "main.c"
  tmp___16 = lookup_variable((char *)"MAKELEVEL", 9U);
# 1197 "main.c"
  v___0 = tmp___16;
  }
# 1198 "main.c"
  if ((unsigned long )v___0 != (unsigned long )((struct variable *)0)) {
# 1198 "main.c"
    if ((int )*(v___0->value) != 0) {
# 1198 "main.c"
      if ((int )*(v___0->value) != 45) {
        {
# 1199 "main.c"
        tmp___17 = atoi((char const *)v___0->value);
# 1199 "main.c"
        makelevel = (unsigned int )tmp___17;
        }
      } else {
# 1201 "main.c"
        makelevel = 0U;
      }
    } else {
# 1201 "main.c"
      makelevel = 0U;
    }
  } else {
# 1201 "main.c"
    makelevel = 0U;
  }
# 1205 "main.c"
  if (! silent_flag) {
# 1205 "main.c"
    if ((unsigned long )directories___0 != (unsigned long )((struct stringlist *)0)) {
# 1206 "main.c"
      print_directory_flag = 1;
    } else
# 1205 "main.c"
    if (makelevel > 0U) {
# 1206 "main.c"
      print_directory_flag = 1;
    }
  }
# 1209 "main.c"
  if (inhibit_print_directory_flag) {
# 1210 "main.c"
    print_directory_flag = 0;
  }
# 1213 "main.c"
  if (no_builtin_variables_flag) {
# 1214 "main.c"
    no_builtin_rules_flag = 1;
  }
# 1218 "main.c"
  if ((unsigned long )include_directories == (unsigned long )((struct stringlist *)0)) {
# 1218 "main.c"
    tmp___18 = (char **)0;
  } else {
# 1218 "main.c"
    tmp___18 = include_directories->list;
  }
  {
# 1218 "main.c"
  construct_include_path(tmp___18);
  }
# 1222 "main.c"
  if ((unsigned long )directories___0 == (unsigned long )((struct stringlist *)0)) {
# 1224 "main.c"
    starting_directory = current_directory;
  } else {
    {
# 1230 "main.c"
    tmp___19 = getcwd(current_directory, (size_t )4096);
    }
# 1230 "main.c"
    if ((unsigned long )tmp___19 == (unsigned long )((char *)0)) {
      {
# 1234 "main.c"
      perror_with_name((char *)"getcwd: ", (char *)"");
# 1238 "main.c"
      starting_directory = (char *)0;
      }
    } else {
# 1241 "main.c"
      starting_directory = current_directory;
    }
  }
  {
# 1244 "main.c"
  define_variable_in_set((char *)"CURDIR", 6U, current_directory, (enum variable_origin )0,
                         0, current_variable_set_list->set, (struct floc const *)((struct floc *)0));
  }
# 1248 "main.c"
  if ((unsigned long )makefiles != (unsigned long )((struct stringlist *)0)) {
# 1251 "main.c"
    i___0 = 0U;
    {
# 1251 "main.c"
    while (1) {
      while_continue___4: ;
# 1251 "main.c"
      if (! (i___0 < makefiles->idx)) {
# 1251 "main.c"
        goto while_break___4;
      }
# 1252 "main.c"
      if ((int )*(*(makefiles->list + i___0) + 0) == 45) {
# 1252 "main.c"
        if ((int )*(*(makefiles->list + i___0) + 1) == 0) {
# 1259 "main.c"
          if (stdin_nm) {
            {
# 1260 "main.c"
            tmp___20 = dcgettext((char const *)((void *)0), "Makefile from standard input specified twice.",
                                 5);
# 1260 "main.c"
            fatal((struct floc const *)((struct floc *)0), (char const *)tmp___20);
            }
          }
          {
# 1268 "main.c"
          outfile = open_tmpfile(& stdin_nm, "/tmp/GmXXXXXX");
          }
# 1269 "main.c"
          if ((unsigned long )outfile == (unsigned long )((FILE *)0)) {
            {
# 1270 "main.c"
            tmp___21 = dcgettext((char const *)((void *)0), "fopen (temporary file)",
                                 5);
# 1270 "main.c"
            pfatal_with_name(tmp___21);
            }
          }
          {
# 1271 "main.c"
          while (1) {
            while_continue___5: ;
            {
# 1271 "main.c"
            tmp___25 = feof(stdin);
            }
# 1271 "main.c"
            if (tmp___25) {
# 1271 "main.c"
              goto while_break___5;
            }
            {
# 1274 "main.c"
            tmp___22 = fread((void * __restrict )(buf___1), (size_t )1, sizeof(buf___1),
                             (FILE * __restrict )stdin);
# 1274 "main.c"
            n = (unsigned int )tmp___22;
            }
# 1275 "main.c"
            if (n > 0U) {
              {
# 1275 "main.c"
              tmp___24 = fwrite((void const * __restrict )(buf___1), (size_t )1,
                                (size_t )n, (FILE * __restrict )outfile);
              }
# 1275 "main.c"
              if (tmp___24 != (size_t )n) {
                {
# 1276 "main.c"
                tmp___23 = dcgettext((char const *)((void *)0), "fwrite (temporary file)",
                                     5);
# 1276 "main.c"
                pfatal_with_name(tmp___23);
                }
              }
            }
          }
          while_break___5: ;
          }
          {
# 1278 "main.c"
          fclose(outfile);
# 1282 "main.c"
          *(makefiles->list + i___0) = xstrdup((char const *)stdin_nm);
# 1285 "main.c"
          f = enter_file(stdin_nm);
# 1286 "main.c"
          f->updated = 1U;
# 1287 "main.c"
          f->update_status = (short)0;
# 1288 "main.c"
          f->command_state = (enum __anonenum_command_state_55 )3;
# 1291 "main.c"
          f->intermediate = 0U;
# 1292 "main.c"
          f->dontcare = 0U;
          }
        }
      }
# 1251 "main.c"
      i___0 ++;
    }
    while_break___4: ;
    }
  }
  {
# 1315 "main.c"
  memset((void *)((char *)(& sa)), 0, sizeof(struct sigaction ));
# 1316 "main.c"
  sa.__sigaction_handler.sa_handler = & child_handler;
# 1319 "main.c"
  sa.sa_flags = 536870912;
# 1328 "main.c"
  sigaction(17, (struct sigaction const * __restrict )(& sa), (struct sigaction * __restrict )((void *)0));
# 1338 "main.c"
  signal(10, & debug_signal_handler);
# 1343 "main.c"
  set_default_suffixes();
# 1351 "main.c"
  install_default_suffix_rules();
# 1355 "main.c"
  define_automatic_variables();
# 1360 "main.c"
  define_makeflags(0, 0);
# 1363 "main.c"
  define_default_variables();
# 1367 "main.c"
  default_file = enter_file((char *)".DEFAULT");
  }
# 1369 "main.c"
  if ((unsigned long )makefiles == (unsigned long )((struct stringlist *)0)) {
# 1369 "main.c"
    tmp___26 = (char **)0;
  } else {
# 1369 "main.c"
    tmp___26 = makefiles->list;
  }
  {
# 1369 "main.c"
  read_makefiles___0 = read_all_makefiles(tmp___26);
# 1407 "main.c"
  decode_env_switches((char *)"MAKEFLAGS", 9U);
  }
# 1425 "main.c"
  if (jobserver_fds) {
# 1429 "main.c"
    i = 1U;
    {
# 1429 "main.c"
    while (1) {
      while_continue___6: ;
# 1429 "main.c"
      if (! (i < jobserver_fds->idx)) {
# 1429 "main.c"
        goto while_break___6;
      }
# 1430 "main.c"
      if (! ((unsigned long )*(jobserver_fds->list + 0) == (unsigned long )*(jobserver_fds->list + i))) {
# 1430 "main.c"
        if ((int )*(*(jobserver_fds->list + 0)) == (int )*(*(jobserver_fds->list + i))) {
# 1430 "main.c"
          if (! ((int )*(*(jobserver_fds->list + 0)) == 0)) {
            {
# 1430 "main.c"
            tmp___28 = strcmp((char const *)(*(jobserver_fds->list + 0) + 1), (char const *)(*(jobserver_fds->list + i) + 1));
            }
# 1430 "main.c"
            if (tmp___28) {
              {
# 1431 "main.c"
              tmp___27 = dcgettext((char const *)((void *)0), "internal error: multiple --jobserver-fds options",
                                   5);
# 1431 "main.c"
              fatal((struct floc const *)((struct floc *)0), (char const *)tmp___27);
              }
            }
          }
        } else {
          {
# 1431 "main.c"
          tmp___27 = dcgettext((char const *)((void *)0), "internal error: multiple --jobserver-fds options",
                               5);
# 1431 "main.c"
          fatal((struct floc const *)((struct floc *)0), (char const *)tmp___27);
          }
        }
      }
# 1429 "main.c"
      i ++;
    }
    while_break___6: ;
    }
    {
# 1435 "main.c"
    cp = *(jobserver_fds->list + 0);
# 1437 "main.c"
    tmp___30 = sscanf((char const * __restrict )cp, (char const * __restrict )"%d,%d",
                      & job_fds[0], & job_fds[1]);
    }
# 1437 "main.c"
    if (tmp___30 != 2) {
      {
# 1438 "main.c"
      tmp___29 = dcgettext((char const *)((void *)0), "internal error: invalid --jobserver-fds string `%s\'",
                           5);
# 1438 "main.c"
      fatal((struct floc const *)((struct floc *)0), (char const *)tmp___29, cp);
      }
    }
# 1447 "main.c"
    if (job_slots > 0U) {
      {
# 1448 "main.c"
      tmp___31 = dcgettext((char const *)((void *)0), "warning: -jN forced in submake: disabling jobserver mode.",
                           5);
# 1448 "main.c"
      error((struct floc const *)((struct floc *)0), (char const *)tmp___31);
      }
    } else {
      {
# 1456 "main.c"
      job_rfd = dup(job_fds[0]);
      }
# 1456 "main.c"
      if (job_rfd < 0) {
        {
# 1458 "main.c"
        tmp___33 = __errno_location();
        }
# 1458 "main.c"
        if (*tmp___33 != 9) {
          {
# 1459 "main.c"
          tmp___32 = dcgettext((char const *)((void *)0), "dup jobserver", 5);
# 1459 "main.c"
          pfatal_with_name(tmp___32);
          }
        }
        {
# 1461 "main.c"
        tmp___34 = dcgettext((char const *)((void *)0), "warning: jobserver unavailable: using -j1.  Add `+\' to parent make rule.",
                             5);
# 1461 "main.c"
        error((struct floc const *)((struct floc *)0), (char const *)tmp___34);
# 1463 "main.c"
        job_slots = 1U;
        }
      }
    }
# 1466 "main.c"
    if (job_slots > 0U) {
      {
# 1468 "main.c"
      close(job_fds[0]);
# 1469 "main.c"
      close(job_fds[1]);
# 1470 "main.c"
      job_fds[1] = -1;
# 1470 "main.c"
      job_fds[0] = job_fds[1];
# 1471 "main.c"
      free((void *)jobserver_fds->list);
# 1472 "main.c"
      free((void *)jobserver_fds);
# 1473 "main.c"
      jobserver_fds = (struct stringlist *)0;
      }
    }
  }
# 1480 "main.c"
  if (job_slots > 1U) {
    {
# 1482 "main.c"
    c = (char )'+';
# 1484 "main.c"
    tmp___36 = pipe(job_fds);
    }
# 1484 "main.c"
    if (tmp___36 < 0) {
      {
# 1485 "main.c"
      tmp___35 = dcgettext((char const *)((void *)0), "creating jobs pipe", 5);
# 1485 "main.c"
      pfatal_with_name(tmp___35);
      }
    } else {
      {
# 1484 "main.c"
      job_rfd = dup(job_fds[0]);
      }
# 1484 "main.c"
      if (job_rfd < 0) {
        {
# 1485 "main.c"
        tmp___35 = dcgettext((char const *)((void *)0), "creating jobs pipe", 5);
# 1485 "main.c"
        pfatal_with_name(tmp___35);
        }
      }
    }
    {
# 1492 "main.c"
    while (1) {
      while_continue___7: ;
# 1492 "main.c"
      job_slots --;
# 1492 "main.c"
      if (! job_slots) {
# 1492 "main.c"
        goto while_break___7;
      }
      {
# 1493 "main.c"
      while (1) {
        while_continue___8: ;
        {
# 1493 "main.c"
        tmp___39 = write(job_fds[1], (void const *)(& c), (size_t )1);
        }
# 1493 "main.c"
        if (! (tmp___39 != 1L)) {
# 1493 "main.c"
          goto while_break___8;
        }
        {
# 1494 "main.c"
        tmp___38 = __errno_location();
        }
# 1494 "main.c"
        if (! (*tmp___38 == 4)) {
          {
# 1495 "main.c"
          tmp___37 = dcgettext((char const *)((void *)0), "init jobserver pipe",
                               5);
# 1495 "main.c"
          pfatal_with_name(tmp___37);
          }
        }
      }
      while_break___8: ;
      }
    }
    while_break___7: ;
    }
    {
# 1499 "main.c"
    tmp___40 = xmalloc((unsigned int )sizeof(struct stringlist ));
# 1499 "main.c"
    jobserver_fds = (struct stringlist *)tmp___40;
# 1501 "main.c"
    tmp___41 = xmalloc((unsigned int )sizeof(char *));
# 1501 "main.c"
    jobserver_fds->list = (char **)tmp___41;
# 1502 "main.c"
    *(jobserver_fds->list + 0) = xmalloc((unsigned int )(sizeof("1024") * 2UL + 1UL));
# 1504 "main.c"
    sprintf((char * __restrict )*(jobserver_fds->list + 0), (char const * __restrict )"%d,%d",
            job_fds[0], job_fds[1]);
# 1505 "main.c"
    jobserver_fds->idx = 1U;
# 1506 "main.c"
    jobserver_fds->max = 1U;
    }
  }
  {
# 1512 "main.c"
  define_makeflags(1, 0);
# 1517 "main.c"
  snap_deps();
# 1524 "main.c"
  convert_to_pattern();
# 1531 "main.c"
  install_default_implicit_rules();
# 1535 "main.c"
  count_implicit_rule_limits();
# 1539 "main.c"
  build_vpath_lists();
  }
# 1545 "main.c"
  if ((unsigned long )old_files != (unsigned long )((struct stringlist *)0)) {
# 1546 "main.c"
    p = old_files->list;
    {
# 1546 "main.c"
    while (1) {
      while_continue___9: ;
# 1546 "main.c"
      if (! ((unsigned long )*p != (unsigned long )((char *)0))) {
# 1546 "main.c"
        goto while_break___9;
      }
      {
# 1548 "main.c"
      f = enter_command_line_file(*p);
# 1549 "main.c"
      tmp___42 = (uintmax_t )1;
# 1549 "main.c"
      f->mtime_before_update = tmp___42;
# 1549 "main.c"
      f->last_mtime = tmp___42;
# 1550 "main.c"
      f->updated = 1U;
# 1551 "main.c"
      f->update_status = (short)0;
# 1552 "main.c"
      f->command_state = (enum __anonenum_command_state_55 )3;
# 1546 "main.c"
      p ++;
      }
    }
    while_break___9: ;
    }
  }
# 1555 "main.c"
  if ((unsigned long )new_files != (unsigned long )((struct stringlist *)0)) {
# 1557 "main.c"
    p = new_files->list;
    {
# 1557 "main.c"
    while (1) {
      while_continue___10: ;
# 1557 "main.c"
      if (! ((unsigned long )*p != (unsigned long )((char *)0))) {
# 1557 "main.c"
        goto while_break___10;
      }
      {
# 1559 "main.c"
      f = enter_command_line_file(*p);
# 1560 "main.c"
      tmp___43 = 0xfffffffffffffffeUL;
# 1560 "main.c"
      f->mtime_before_update = tmp___43;
# 1560 "main.c"
      f->last_mtime = tmp___43;
# 1557 "main.c"
      p ++;
      }
    }
    while_break___10: ;
    }
  }
  {
# 1565 "main.c"
  remote_setup();
  }
# 1567 "main.c"
  if ((unsigned long )read_makefiles___0 != (unsigned long )((struct dep *)0)) {
# 1571 "main.c"
    makefile_mtimes = (uintmax_t *)0;
# 1572 "main.c"
    mm_idx = 0U;
# 1573 "main.c"
    nargv = argv;
# 1574 "main.c"
    nargc = argc;
# 1575 "main.c"
    orig_db_level = db_level;
# 1577 "main.c"
    if (! (256 & db_level)) {
# 1578 "main.c"
      db_level = 0;
    }
    {
# 1580 "main.c"
    while (1) {
      while_continue___11: ;
# 1580 "main.c"
      if (1 & db_level) {
        {
# 1580 "main.c"
        tmp___44 = dcgettext((char const *)((void *)0), "Updating makefiles....\n",
                             5);
# 1580 "main.c"
        printf((char const * __restrict )tmp___44);
# 1580 "main.c"
        fflush(stdout);
        }
      }
# 1580 "main.c"
      goto while_break___11;
    }
    while_break___11: ;
    }
# 1586 "main.c"
    last = (struct dep *)0;
# 1587 "main.c"
    d = read_makefiles___0;
    {
# 1588 "main.c"
    while (1) {
      while_continue___12: ;
# 1588 "main.c"
      if (! ((unsigned long )d != (unsigned long )((struct dep *)0))) {
# 1588 "main.c"
        goto while_break___12;
      }
# 1590 "main.c"
      f___0 = d->file;
# 1591 "main.c"
      if (f___0->double_colon) {
# 1592 "main.c"
        f___0 = f___0->double_colon;
        {
# 1592 "main.c"
        while (1) {
          while_continue___13: ;
# 1592 "main.c"
          if (! ((unsigned long )f___0 != (unsigned long )((void *)0))) {
# 1592 "main.c"
            goto while_break___13;
          }
# 1594 "main.c"
          if ((unsigned long )f___0->deps == (unsigned long )((struct dep *)0)) {
# 1594 "main.c"
            if ((unsigned long )f___0->cmds != (unsigned long )((struct commands *)0)) {
              {
# 1604 "main.c"
              while (1) {
                while_continue___14: ;
# 1604 "main.c"
                if (2 & db_level) {
                  {
# 1604 "main.c"
                  tmp___45 = dcgettext((char const *)((void *)0), "Makefile `%s\' might loop; not remaking it.\n",
                                       5);
# 1604 "main.c"
                  printf((char const * __restrict )tmp___45, f___0->name);
# 1604 "main.c"
                  fflush(stdout);
                  }
                }
# 1604 "main.c"
                goto while_break___14;
              }
              while_break___14: ;
              }
# 1608 "main.c"
              if ((unsigned long )last == (unsigned long )((struct dep *)0)) {
# 1609 "main.c"
                read_makefiles___0 = d->next;
              } else {
# 1611 "main.c"
                last->next = d->next;
              }
              {
# 1614 "main.c"
              free((void *)((char *)d));
              }
# 1616 "main.c"
              if ((unsigned long )last == (unsigned long )((struct dep *)0)) {
# 1616 "main.c"
                d = read_makefiles___0;
              } else {
# 1616 "main.c"
                d = last->next;
              }
# 1618 "main.c"
              goto while_break___13;
            }
          }
# 1592 "main.c"
          f___0 = f___0->prev;
        }
        while_break___13: ;
        }
      }
# 1621 "main.c"
      if ((unsigned long )f___0 == (unsigned long )((void *)0)) {
# 1621 "main.c"
        goto _L;
      } else
# 1621 "main.c"
      if (! f___0->double_colon) {
        _L:
        {
# 1623 "main.c"
        tmp___46 = xrealloc((char *)makefile_mtimes, (unsigned int )((unsigned long )(mm_idx + 1U) * sizeof(uintmax_t )));
# 1623 "main.c"
        makefile_mtimes = (uintmax_t *)tmp___46;
# 1626 "main.c"
        tmp___47 = mm_idx;
# 1626 "main.c"
        mm_idx ++;
        }
# 1626 "main.c"
        if ((d->file)->last_mtime) {
# 1626 "main.c"
          *(makefile_mtimes + tmp___47) = (d->file)->last_mtime;
        } else {
          {
# 1626 "main.c"
          tmp___48 = f_mtime(d->file, 0);
# 1626 "main.c"
          *(makefile_mtimes + tmp___47) = tmp___48;
          }
        }
# 1627 "main.c"
        last = d;
# 1628 "main.c"
        d = d->next;
      }
    }
    while_break___12: ;
    }
    {
# 1634 "main.c"
    define_makeflags(1, 1);
# 1636 "main.c"
    tmp___49 = update_goal_chain(read_makefiles___0, 1);
    }
    {
# 1643 "main.c"
    if (tmp___49 == -1) {
# 1643 "main.c"
      goto case_neg_1;
    }
# 1647 "main.c"
    if (tmp___49 == 2) {
# 1647 "main.c"
      goto case_2;
    }
# 1715 "main.c"
    if (tmp___49 == 0) {
# 1715 "main.c"
      goto re_exec;
    }
# 1637 "main.c"
    goto switch_default;
    switch_default:
    {
# 1641 "main.c"
    __assert_fail("BOGUS_UPDATE_STATUS", "main.c", 1641U, "main");
    }
# 1642 "main.c"
    goto switch_break;
    case_neg_1:
# 1646 "main.c"
    goto switch_break;
    case_2:
# 1652 "main.c"
    any_remade = 0;
# 1655 "main.c"
    any_failed = 0;
# 1659 "main.c"
    i___1 = 0U;
# 1659 "main.c"
    d___0 = read_makefiles___0;
    {
# 1659 "main.c"
    while (1) {
      while_continue___15: ;
# 1659 "main.c"
      if (! ((unsigned long )d___0 != (unsigned long )((struct dep *)0))) {
# 1659 "main.c"
        goto while_break___15;
      }
# 1663 "main.c"
      (d___0->file)->considered = 0U;
# 1665 "main.c"
      if ((d___0->file)->updated) {
# 1668 "main.c"
        if ((int )(d___0->file)->update_status == 0) {
# 1671 "main.c"
          if ((d___0->file)->last_mtime) {
# 1671 "main.c"
            tmp___51 = (d___0->file)->last_mtime;
          } else {
            {
# 1671 "main.c"
            tmp___50 = f_mtime(d___0->file, 0);
# 1671 "main.c"
            tmp___51 = tmp___50;
            }
          }
# 1671 "main.c"
          any_remade |= tmp___51 != *(makefile_mtimes + i___1);
        } else
# 1674 "main.c"
        if (! (d___0->changed & (1 << 2))) {
          {
# 1679 "main.c"
          tmp___52 = dcgettext((char const *)((void *)0), "Failed to remake makefile `%s\'.",
                               5);
# 1679 "main.c"
          error((struct floc const *)((struct floc *)0), (char const *)tmp___52,
                (d___0->file)->name);
          }
# 1681 "main.c"
          if ((d___0->file)->last_mtime) {
# 1681 "main.c"
            mtime = (d___0->file)->last_mtime;
          } else {
            {
# 1681 "main.c"
            tmp___53 = f_mtime(d___0->file, 0);
# 1681 "main.c"
            mtime = tmp___53;
            }
          }
# 1682 "main.c"
          if (mtime != 0xffffffffffffffffUL) {
# 1682 "main.c"
            if (mtime != *(makefile_mtimes + i___1)) {
# 1682 "main.c"
              tmp___54 = 1;
            } else {
# 1682 "main.c"
              tmp___54 = 0;
            }
          } else {
# 1682 "main.c"
            tmp___54 = 0;
          }
# 1682 "main.c"
          any_remade |= tmp___54;
        }
      } else
# 1688 "main.c"
      if (! (d___0->changed & (1 << 2))) {
# 1691 "main.c"
        if (d___0->changed & (1 << 1)) {
# 1694 "main.c"
          if ((unsigned long )d___0->name == (unsigned long )((char *)0)) {
# 1694 "main.c"
            tmp___55 = (d___0->file)->name;
          } else {
# 1694 "main.c"
            tmp___55 = d___0->name;
          }
          {
# 1694 "main.c"
          tmp___56 = dcgettext((char const *)((void *)0), "Included makefile `%s\' was not found.",
                               5);
# 1694 "main.c"
          error((struct floc const *)((struct floc *)0), (char const *)tmp___56,
                tmp___55);
          }
        } else {
# 1700 "main.c"
          if ((unsigned long )d___0->name == (unsigned long )((char *)0)) {
# 1700 "main.c"
            tmp___57 = (d___0->file)->name;
          } else {
# 1700 "main.c"
            tmp___57 = d___0->name;
          }
          {
# 1700 "main.c"
          tmp___58 = dcgettext((char const *)((void *)0), "Makefile `%s\' was not found",
                               5);
# 1700 "main.c"
          error((struct floc const *)((struct floc *)0), (char const *)tmp___58,
                tmp___57);
# 1702 "main.c"
          any_failed = 1;
          }
        }
      }
# 1659 "main.c"
      i___1 ++;
# 1659 "main.c"
      d___0 = d___0->next;
    }
    while_break___15: ;
    }
# 1707 "main.c"
    read_makefiles___0 = (struct dep *)0;
# 1709 "main.c"
    if (any_remade) {
# 1710 "main.c"
      goto re_exec;
    }
# 1711 "main.c"
    if (any_failed) {
      {
# 1712 "main.c"
      die(2);
      }
    }
# 1713 "main.c"
    goto switch_break;
    re_exec:
    case_0:
    {
# 1720 "main.c"
    remove_intermediates(0);
    }
# 1722 "main.c"
    if (print_data_base_flag) {
      {
# 1723 "main.c"
      print_data_base();
      }
    }
    {
# 1725 "main.c"
    log_working_directory(0);
    }
# 1727 "main.c"
    if ((unsigned long )makefiles != (unsigned long )((struct stringlist *)0)) {
# 1730 "main.c"
      j = 0U;
# 1731 "main.c"
      i___2 = 1U;
      {
# 1731 "main.c"
      while (1) {
        while_continue___16: ;
# 1731 "main.c"
        if (! (i___2 < (unsigned int )argc)) {
# 1731 "main.c"
          goto while_break___16;
        }
        {
# 1732 "main.c"
        tmp___59 = strncmp((char const *)*(argv + i___2), "-f", (size_t )2);
        }
# 1732 "main.c"
        if (tmp___59 == 0) {
# 1734 "main.c"
          p___1 = *(argv + i___2) + 2;
# 1735 "main.c"
          if ((int )*p___1 == 0) {
# 1736 "main.c"
            i___2 ++;
# 1736 "main.c"
            *(argv + i___2) = *(makefiles->list + j);
          } else {
            {
# 1738 "main.c"
            *(argv + i___2) = concat((char *)"-f", *(makefiles->list + j), (char *)"");
            }
          }
# 1739 "main.c"
          j ++;
        }
# 1731 "main.c"
        i___2 ++;
      }
      while_break___16: ;
      }
    }
# 1744 "main.c"
    if (stdin_nm) {
      {
# 1746 "main.c"
      tmp___60 = xmalloc((unsigned int )((unsigned long )(nargc + 2) * sizeof(char *)));
# 1746 "main.c"
      nargv = (char **)tmp___60;
# 1747 "main.c"
      memmove((void *)((char *)nargv), (void const *)((char *)argv), (unsigned long )argc * sizeof(char *));
# 1748 "main.c"
      tmp___61 = nargc;
# 1748 "main.c"
      nargc ++;
# 1748 "main.c"
      *(nargv + tmp___61) = concat((char *)"-o", stdin_nm, (char *)"");
# 1749 "main.c"
      *(nargv + nargc) = (char *)0;
      }
    }
# 1752 "main.c"
    if ((unsigned long )directories___0 != (unsigned long )((struct stringlist *)0)) {
# 1752 "main.c"
      if (directories___0->idx > 0U) {
# 1755 "main.c"
        if ((unsigned long )directory_before_chdir != (unsigned long )((char *)0)) {
          {
# 1757 "main.c"
          tmp___62 = chdir((char const *)directory_before_chdir);
          }
# 1757 "main.c"
          if (tmp___62 < 0) {
            {
# 1759 "main.c"
            perror_with_name((char *)"chdir", (char *)"");
# 1760 "main.c"
            bad = (char)1;
            }
          } else {
# 1763 "main.c"
            bad = (char)0;
          }
        } else {
# 1766 "main.c"
          bad = (char)1;
        }
# 1767 "main.c"
        if (bad) {
          {
# 1768 "main.c"
          tmp___63 = dcgettext((char const *)((void *)0), "Couldn\'t change back to original directory.",
                               5);
# 1768 "main.c"
          fatal((struct floc const *)((struct floc *)0), (char const *)tmp___63);
          }
        }
      }
    }
# 1772 "main.c"
    p = environ;
    {
# 1772 "main.c"
    while (1) {
      while_continue___17: ;
# 1772 "main.c"
      if (! ((unsigned long )*p != (unsigned long )((char *)0))) {
# 1772 "main.c"
        goto while_break___17;
      }
      {
# 1773 "main.c"
      tmp___65 = strncmp((char const *)*p, "MAKELEVEL=", (size_t )10);
      }
# 1773 "main.c"
      if (tmp___65 == 0) {
        {
# 1779 "main.c"
        tmp___64 = __builtin_alloca(40UL);
# 1779 "main.c"
        sgi_loses = (char *)tmp___64;
# 1780 "main.c"
        *p = sgi_loses;
# 1781 "main.c"
        sprintf((char * __restrict )*p, (char const * __restrict )"MAKELEVEL=%u",
                makelevel);
        }
# 1782 "main.c"
        goto while_break___17;
      }
# 1772 "main.c"
      p ++;
    }
    while_break___17: ;
    }
# 1799 "main.c"
    if (1 & db_level) {
      {
# 1802 "main.c"
      tmp___66 = dcgettext((char const *)((void *)0), "Re-executing:", 5);
# 1802 "main.c"
      fputs((char const * __restrict )tmp___66, (FILE * __restrict )stdout);
# 1803 "main.c"
      p___2 = nargv;
      }
      {
# 1803 "main.c"
      while (1) {
        while_continue___18: ;
# 1803 "main.c"
        if (! ((unsigned long )*p___2 != (unsigned long )((char *)0))) {
# 1803 "main.c"
          goto while_break___18;
        }
        {
# 1804 "main.c"
        printf((char const * __restrict )" %s", *p___2);
# 1803 "main.c"
        p___2 ++;
        }
      }
      while_break___18: ;
      }
      {
# 1805 "main.c"
      putchar('\n');
      }
    }
    {
# 1808 "main.c"
    fflush(stdout);
# 1809 "main.c"
    fflush(stderr);
    }
# 1812 "main.c"
    if (job_rfd >= 0) {
      {
# 1813 "main.c"
      close(job_rfd);
      }
    }
    {
# 1816 "main.c"
    exec_command(nargv, environ);
    }
    switch_break: ;
    }
# 1824 "main.c"
    db_level = orig_db_level;
  }
  {
# 1828 "main.c"
  define_makeflags(1, 0);
  }
# 1832 "main.c"
  if (stdin_nm) {
    {
# 1832 "main.c"
    tmp___68 = unlink((char const *)stdin_nm);
    }
# 1832 "main.c"
    if (tmp___68 < 0) {
      {
# 1832 "main.c"
      tmp___69 = __errno_location();
      }
# 1832 "main.c"
      if (*tmp___69 != 2) {
        {
# 1833 "main.c"
        tmp___67 = dcgettext((char const *)((void *)0), "unlink (temporary file): ",
                             5);
# 1833 "main.c"
        perror_with_name(tmp___67, stdin_nm);
        }
      }
    }
  }
# 1839 "main.c"
  if ((unsigned long )goals == (unsigned long )((struct dep *)0)) {
# 1841 "main.c"
    if ((unsigned long )default_goal_file != (unsigned long )((struct file *)0)) {
      {
# 1843 "main.c"
      tmp___70 = xmalloc((unsigned int )sizeof(struct dep ));
# 1843 "main.c"
      goals = (struct dep *)tmp___70;
# 1844 "main.c"
      goals->next = (struct dep *)0;
# 1845 "main.c"
      goals->name = (char *)0;
# 1846 "main.c"
      goals->file = default_goal_file;
      }
    }
  } else {
# 1850 "main.c"
    lastgoal->next = (struct dep *)0;
  }
# 1852 "main.c"
  if (! goals) {
# 1854 "main.c"
    if ((unsigned long )read_makefiles___0 == (unsigned long )((struct dep *)0)) {
      {
# 1855 "main.c"
      tmp___71 = dcgettext((char const *)((void *)0), "No targets specified and no makefile found",
                           5);
# 1855 "main.c"
      fatal((struct floc const *)((struct floc *)0), (char const *)tmp___71);
      }
    }
    {
# 1857 "main.c"
    tmp___72 = dcgettext((char const *)((void *)0), "No targets", 5);
# 1857 "main.c"
    fatal((struct floc const *)((struct floc *)0), (char const *)tmp___72);
    }
  }
  {
# 1862 "main.c"
  while (1) {
    while_continue___19: ;
# 1862 "main.c"
    if (1 & db_level) {
      {
# 1862 "main.c"
      tmp___73 = dcgettext((char const *)((void *)0), "Updating goal targets....\n",
                           5);
# 1862 "main.c"
      printf((char const * __restrict )tmp___73);
# 1862 "main.c"
      fflush(stdout);
      }
    }
# 1862 "main.c"
    goto while_break___19;
  }
  while_break___19: ;
  }
  {
# 1864 "main.c"
  tmp___74 = update_goal_chain(goals, 0);
  }
  {
# 1866 "main.c"
  if (tmp___74 == -1) {
# 1866 "main.c"
    goto case_neg_1___0;
  }
# 1866 "main.c"
  if (tmp___74 == 0) {
# 1866 "main.c"
    goto case_neg_1___0;
  }
# 1872 "main.c"
  if (tmp___74 == 2) {
# 1872 "main.c"
    goto case_2___0;
  }
# 1877 "main.c"
  if (tmp___74 == 1) {
# 1877 "main.c"
    goto case_1;
  }
# 1881 "main.c"
  goto switch_default___0;
  case_neg_1___0:
  case_0___0:
# 1870 "main.c"
  status = 0;
# 1871 "main.c"
  goto switch_break___0;
  case_2___0:
# 1875 "main.c"
  status = 2;
# 1876 "main.c"
  goto switch_break___0;
  case_1:
# 1879 "main.c"
  status = 1;
# 1880 "main.c"
  goto switch_break___0;
  switch_default___0:
  {
# 1882 "main.c"
  abort();
  }
  switch_break___0: ;
  }
# 1886 "main.c"
  if (clock_skew_detected) {
    {
# 1887 "main.c"
    tmp___75 = dcgettext((char const *)((void *)0), "warning:  Clock skew detected.  Your build may be incomplete.",
                         5);
# 1887 "main.c"
    error((struct floc const *)((struct floc *)0), (char const *)tmp___75);
    }
  }
  {
# 1891 "main.c"
  die(status);
  }
# 1894 "main.c"
  return (0);
}
}
# 1899 "main.c"
static char options[1UL + (sizeof(switches) / sizeof(switches[0])) * 3UL] ;
# 1900 "main.c"
static struct option long_options[sizeof(switches) / sizeof(switches[0]) + sizeof(long_option_aliases) / sizeof(long_option_aliases[0])] ;
# 1905 "main.c"
static void init_switches(void)
{
  register char *p ;
  register int c ;
  register unsigned int i ;
  char *tmp ;
  char *tmp___0 ;
  char *tmp___1 ;
  char *tmp___2 ;
  unsigned int tmp___3 ;

  {
# 1912 "main.c"
  if ((int )options[0] != 0) {
# 1914 "main.c"
    return;
  }
# 1916 "main.c"
  p = options;
# 1920 "main.c"
  tmp = p;
# 1920 "main.c"
  p ++;
# 1920 "main.c"
  *tmp = (char )'-';
# 1922 "main.c"
  i = 0U;
  {
# 1922 "main.c"
  while (1) {
    while_continue: ;
# 1922 "main.c"
    if (! (switches[i].c != 0)) {
# 1922 "main.c"
      goto while_break;
    }
# 1924 "main.c"
    if ((unsigned long )switches[i].long_name == (unsigned long )((char * const )0)) {
# 1924 "main.c"
      long_options[i].name = "";
    } else {
# 1924 "main.c"
      long_options[i].name = (char const *)switches[i].long_name;
    }
# 1926 "main.c"
    long_options[i].flag = (int *)0;
# 1927 "main.c"
    long_options[i].val = (int )switches[i].c;
# 1928 "main.c"
    if (switches[i].c <= 127) {
# 1929 "main.c"
      tmp___0 = p;
# 1929 "main.c"
      p ++;
# 1929 "main.c"
      *tmp___0 = (char )switches[i].c;
    }
    {
# 1933 "main.c"
    if ((unsigned int const )switches[i].type == 0U) {
# 1933 "main.c"
      goto case_0;
    }
# 1933 "main.c"
    if ((unsigned int const )switches[i].type == 1U) {
# 1933 "main.c"
      goto case_0;
    }
# 1933 "main.c"
    if ((unsigned int const )switches[i].type == 5U) {
# 1933 "main.c"
      goto case_0;
    }
# 1939 "main.c"
    if ((unsigned int const )switches[i].type == 2U) {
# 1939 "main.c"
      goto case_2;
    }
# 1939 "main.c"
    if ((unsigned int const )switches[i].type == 3U) {
# 1939 "main.c"
      goto case_2;
    }
# 1939 "main.c"
    if ((unsigned int const )switches[i].type == 4U) {
# 1939 "main.c"
      goto case_2;
    }
# 1930 "main.c"
    goto switch_break;
    case_0:
    case_1:
    case_5:
# 1935 "main.c"
    long_options[i].has_arg = 0;
# 1936 "main.c"
    goto switch_break;
    case_2:
    case_3:
    case_4:
# 1941 "main.c"
    if (switches[i].c <= 127) {
# 1942 "main.c"
      tmp___1 = p;
# 1942 "main.c"
      p ++;
# 1942 "main.c"
      *tmp___1 = (char )':';
    }
# 1943 "main.c"
    if ((unsigned long )switches[i].noarg_value != (unsigned long )((char * const )0)) {
# 1945 "main.c"
      if (switches[i].c <= 127) {
# 1946 "main.c"
        tmp___2 = p;
# 1946 "main.c"
        p ++;
# 1946 "main.c"
        *tmp___2 = (char )':';
      }
# 1947 "main.c"
      long_options[i].has_arg = 2;
    } else {
# 1950 "main.c"
      long_options[i].has_arg = 1;
    }
# 1951 "main.c"
    goto switch_break;
    switch_break: ;
    }
# 1922 "main.c"
    i ++;
  }
  while_break: ;
  }
# 1954 "main.c"
  *p = (char )'\000';
# 1955 "main.c"
  c = 0;
  {
# 1955 "main.c"
  while (1) {
    while_continue___0: ;
# 1955 "main.c"
    if (! ((unsigned long )c < sizeof(long_option_aliases) / sizeof(long_option_aliases[0]))) {
# 1955 "main.c"
      goto while_break___0;
    }
# 1958 "main.c"
    tmp___3 = i;
# 1958 "main.c"
    i ++;
# 1958 "main.c"
    long_options[tmp___3] = long_option_aliases[c];
# 1955 "main.c"
    c ++;
  }
  while_break___0: ;
  }
# 1959 "main.c"
  long_options[i].name = (char const *)0;
# 1960 "main.c"
  return;
}
}
# 1962 "main.c"
static void handle_non_switch_argument(char *arg , int env )
{
  struct variable *v ;
  struct command_variable *cv ;
  char *tmp ;
  struct file *f ;
  struct file *tmp___0 ;
  char *tmp___1 ;
  char *tmp___2 ;
  struct variable *v___0 ;
  char *value ;
  unsigned int oldlen ;
  unsigned int newlen ;
  size_t tmp___3 ;
  size_t tmp___4 ;
  void *tmp___5 ;

  {
# 1969 "main.c"
  if ((int )*(arg + 0) == 45) {
# 1969 "main.c"
    if ((int )*(arg + 1) == 0) {
# 1971 "main.c"
      return;
    }
  }
  {
# 1972 "main.c"
  v = try_variable_definition((struct floc const *)0, arg, (enum variable_origin )4,
                              0);
  }
# 1973 "main.c"
  if ((unsigned long )v != (unsigned long )((struct variable *)0)) {
    {
# 1977 "main.c"
    tmp = xmalloc((unsigned int )sizeof(*cv));
# 1977 "main.c"
    cv = (struct command_variable *)tmp;
# 1979 "main.c"
    cv->variable = v;
# 1980 "main.c"
    cv->next = command_variables;
# 1981 "main.c"
    command_variables = cv;
    }
  } else
# 1983 "main.c"
  if (! env) {
    {
# 1988 "main.c"
    tmp___0 = enter_command_line_file(arg);
# 1988 "main.c"
    f = tmp___0;
# 1989 "main.c"
    f->cmd_target = 1U;
    }
# 1991 "main.c"
    if ((unsigned long )goals == (unsigned long )((struct dep *)0)) {
      {
# 1993 "main.c"
      tmp___1 = xmalloc((unsigned int )sizeof(struct dep ));
# 1993 "main.c"
      goals = (struct dep *)tmp___1;
# 1994 "main.c"
      lastgoal = goals;
      }
    } else {
      {
# 1998 "main.c"
      tmp___2 = xmalloc((unsigned int )sizeof(struct dep ));
# 1998 "main.c"
      lastgoal->next = (struct dep *)tmp___2;
# 1999 "main.c"
      lastgoal = lastgoal->next;
      }
    }
    {
# 2001 "main.c"
    lastgoal->name = (char *)0;
# 2002 "main.c"
    lastgoal->file = f;
# 2009 "main.c"
    v___0 = lookup_variable((char *)"MAKECMDGOALS", 12U);
    }
# 2010 "main.c"
    if ((unsigned long )v___0 == (unsigned long )((struct variable *)0)) {
# 2011 "main.c"
      value = f->name;
    } else {
      {
# 2017 "main.c"
      tmp___3 = strlen((char const *)v___0->value);
# 2017 "main.c"
      oldlen = (unsigned int )tmp___3;
# 2018 "main.c"
      tmp___4 = strlen((char const *)f->name);
# 2018 "main.c"
      newlen = (unsigned int )tmp___4;
# 2019 "main.c"
      tmp___5 = __builtin_alloca((unsigned long )(((oldlen + 1U) + newlen) + 1U));
# 2019 "main.c"
      value = (char *)tmp___5;
# 2020 "main.c"
      memmove((void *)value, (void const *)v___0->value, (size_t )oldlen);
# 2021 "main.c"
      *(value + oldlen) = (char )' ';
# 2022 "main.c"
      memmove((void *)(value + (oldlen + 1U)), (void const *)f->name, (size_t )(newlen + 1U));
      }
    }
    {
# 2024 "main.c"
    define_variable_in_set((char *)"MAKECMDGOALS", 12U, value, (enum variable_origin )0,
                           0, current_variable_set_list->set, (struct floc const *)((struct floc *)0));
    }
  }
# 2027 "main.c"
  return;
}
}
# 2031 "main.c"
static void print_usage(int bad )
{
  register struct command_switch const *cs ;
  FILE *usageto ;
  char *tmp ;
  char *tmp___0 ;
  char buf___1[1024] ;
  char shortarg[50] ;
  char longarg[50] ;
  char *p ;
  char *tmp___1 ;
  char *tmp___2 ;
  char *tmp___3 ;
  char *tmp___4 ;
  size_t tmp___5 ;
  unsigned int i ;
  char const *tmp___6 ;
  size_t tmp___7 ;
  size_t tmp___8 ;
  struct command_switch const *ncs ;
  size_t tmp___9 ;
  size_t tmp___10 ;
  char *tmp___11 ;
  char *tmp___12 ;

  {
# 2038 "main.c"
  if (print_version_flag) {
    {
# 2039 "main.c"
    print_version();
    }
  }
# 2041 "main.c"
  if (bad) {
# 2041 "main.c"
    usageto = stderr;
  } else {
# 2041 "main.c"
    usageto = stdout;
  }
  {
# 2043 "main.c"
  tmp = dcgettext((char const *)((void *)0), "Usage: %s [options] [target] ...\n",
                  5);
# 2043 "main.c"
  fprintf((FILE * __restrict )usageto, (char const * __restrict )tmp, program);
# 2045 "main.c"
  tmp___0 = dcgettext((char const *)((void *)0), "Options:\n", 5);
# 2045 "main.c"
  fputs((char const * __restrict )tmp___0, (FILE * __restrict )usageto);
# 2046 "main.c"
  cs = switches;
  }
  {
# 2046 "main.c"
  while (1) {
    while_continue: ;
# 2046 "main.c"
    if (! (cs->c != 0)) {
# 2046 "main.c"
      goto while_break;
    }
# 2050 "main.c"
    if (! cs->description) {
# 2051 "main.c"
      goto __Cont;
    } else
# 2050 "main.c"
    if ((int )*(cs->description + 0) == 45) {
# 2051 "main.c"
      goto __Cont;
    }
    {
# 2054 "main.c"
    if (long_options[cs - switches].has_arg == 0) {
# 2054 "main.c"
      goto case_0;
    }
# 2058 "main.c"
    if (long_options[cs - switches].has_arg == 1) {
# 2058 "main.c"
      goto case_1;
    }
# 2062 "main.c"
    if (long_options[cs - switches].has_arg == 2) {
# 2062 "main.c"
      goto case_2;
    }
# 2053 "main.c"
    goto switch_break;
    case_0:
# 2056 "main.c"
    longarg[0] = (char )'\000';
# 2056 "main.c"
    shortarg[0] = longarg[0];
# 2057 "main.c"
    goto switch_break;
    case_1:
    {
# 2059 "main.c"
    tmp___1 = dcgettext((char const *)((void *)0), (char const *)cs->argdesc,
                        5);
# 2059 "main.c"
    sprintf((char * __restrict )(longarg), (char const * __restrict )"=%s", tmp___1);
# 2060 "main.c"
    tmp___2 = dcgettext((char const *)((void *)0), (char const *)cs->argdesc,
                        5);
# 2060 "main.c"
    sprintf((char * __restrict )(shortarg), (char const * __restrict )" %s", tmp___2);
    }
# 2061 "main.c"
    goto switch_break;
    case_2:
    {
# 2063 "main.c"
    tmp___3 = dcgettext((char const *)((void *)0), (char const *)cs->argdesc,
                        5);
# 2063 "main.c"
    sprintf((char * __restrict )(longarg), (char const * __restrict )"[=%s]",
            tmp___3);
# 2064 "main.c"
    tmp___4 = dcgettext((char const *)((void *)0), (char const *)cs->argdesc,
                        5);
# 2064 "main.c"
    sprintf((char * __restrict )(shortarg), (char const * __restrict )" [%s]",
            tmp___4);
    }
# 2065 "main.c"
    goto switch_break;
    switch_break: ;
    }
# 2068 "main.c"
    p = buf___1;
# 2070 "main.c"
    if (cs->c <= 127) {
      {
# 2072 "main.c"
      sprintf((char * __restrict )(buf___1), (char const * __restrict )"  -%c%s",
              cs->c, shortarg);
# 2073 "main.c"
      tmp___5 = strlen((char const *)p);
# 2073 "main.c"
      p += tmp___5;
      }
    }
# 2075 "main.c"
    if ((unsigned long )cs->long_name != (unsigned long )((char * const )0)) {
# 2078 "main.c"
      if (! (cs->c <= 127)) {
# 2078 "main.c"
        tmp___6 = "  ";
      } else {
# 2078 "main.c"
        tmp___6 = ", ";
      }
      {
# 2078 "main.c"
      sprintf((char * __restrict )p, (char const * __restrict )"%s--%s%s", tmp___6,
              cs->long_name, longarg);
# 2081 "main.c"
      tmp___7 = strlen((char const *)p);
# 2081 "main.c"
      p += tmp___7;
# 2082 "main.c"
      i = 0U;
      }
      {
# 2082 "main.c"
      while (1) {
        while_continue___0: ;
# 2082 "main.c"
        if (! ((unsigned long )i < sizeof(long_option_aliases) / sizeof(long_option_aliases[0]))) {
# 2082 "main.c"
          goto while_break___0;
        }
# 2085 "main.c"
        if (long_option_aliases[i].val == (int )cs->c) {
          {
# 2087 "main.c"
          sprintf((char * __restrict )p, (char const * __restrict )", --%s%s",
                  long_option_aliases[i].name, longarg);
# 2089 "main.c"
          tmp___8 = strlen((char const *)p);
# 2089 "main.c"
          p += tmp___8;
          }
        }
# 2082 "main.c"
        i ++;
      }
      while_break___0: ;
      }
    }
# 2093 "main.c"
    ncs = cs;
    {
# 2094 "main.c"
    while (1) {
      while_continue___1: ;
# 2094 "main.c"
      ncs ++;
# 2094 "main.c"
      if (! (ncs->c != 0)) {
# 2094 "main.c"
        goto while_break___1;
      }
# 2095 "main.c"
      if (ncs->description) {
# 2095 "main.c"
        if ((int )*(ncs->description + 0) == 45) {
# 2095 "main.c"
          if ((int )*(ncs->description + 1) == (int )cs->c) {
            {
# 2102 "main.c"
            sprintf((char * __restrict )p, (char const * __restrict )", -%c%s",
                    ncs->c, shortarg);
# 2103 "main.c"
            tmp___9 = strlen((char const *)p);
# 2103 "main.c"
            p += tmp___9;
            }
# 2104 "main.c"
            if ((unsigned long )ncs->long_name != (unsigned long )((char * const )0)) {
              {
# 2106 "main.c"
              sprintf((char * __restrict )p, (char const * __restrict )", --%s%s",
                      ncs->long_name, longarg);
# 2107 "main.c"
              tmp___10 = strlen((char const *)p);
# 2107 "main.c"
              p += tmp___10;
              }
            }
          }
        }
      }
    }
    while_break___1: ;
    }
# 2112 "main.c"
    if (p - buf___1 > 28L) {
      {
# 2117 "main.c"
      fprintf((FILE * __restrict )usageto, (char const * __restrict )"%s\n", buf___1);
# 2118 "main.c"
      buf___1[0] = (char )'\000';
      }
    }
    {
# 2121 "main.c"
    tmp___11 = dcgettext((char const *)((void *)0), (char const *)cs->description,
                         5);
# 2121 "main.c"
    fprintf((FILE * __restrict )usageto, (char const * __restrict )"%*s%s.\n",
            -30, buf___1, tmp___11);
    }
    __Cont:
# 2046 "main.c"
    cs ++;
  }
  while_break: ;
  }
  {
# 2126 "main.c"
  tmp___12 = dcgettext((char const *)((void *)0), "\nReport bugs to <bug-make@gnu.org>.\n",
                       5);
# 2126 "main.c"
  fprintf((FILE * __restrict )usageto, (char const * __restrict )tmp___12);
  }
# 2127 "main.c"
  return;
}
}
# 2132 "main.c"
static void decode_switches(int argc , char **argv , int env )
{
  int bad ;
  register struct command_switch const *cs ;
  register struct stringlist *sl ;
  register int c ;
  int doit ;
  int tmp ;
  char *tmp___0 ;
  char *tmp___1 ;
  char *tmp___2 ;
  unsigned int tmp___3 ;
  int tmp___4 ;
  int i ;
  int tmp___5 ;
  char *tmp___6 ;
  int tmp___7 ;
  double tmp___8 ;
  int tmp___9 ;
  int tmp___10 ;

  {
  {
# 2138 "main.c"
  bad = 0;
# 2146 "main.c"
  init_switches();
# 2150 "main.c"
  opterr = ! env;
# 2152 "main.c"
  optind = 0;
  }
  {
# 2154 "main.c"
  while (1) {
    while_continue: ;
# 2154 "main.c"
    if (! (optind < argc)) {
# 2154 "main.c"
      goto while_break;
    }
    {
# 2157 "main.c"
    c = getopt_long(argc, (char * const *)argv, (char const *)(options), (struct option const *)(long_options),
                    (int *)0);
    }
# 2158 "main.c"
    if (c == -1) {
# 2160 "main.c"
      goto while_break;
    } else
# 2161 "main.c"
    if (c == 1) {
      {
# 2163 "main.c"
      handle_non_switch_argument(optarg, env);
      }
    } else
# 2164 "main.c"
    if (c == 63) {
# 2168 "main.c"
      bad = 1;
    } else {
# 2170 "main.c"
      cs = switches;
      {
# 2170 "main.c"
      while (1) {
        while_continue___0: ;
# 2170 "main.c"
        if (! (cs->c != 0)) {
# 2170 "main.c"
          goto while_break___0;
        }
# 2171 "main.c"
        if (cs->c == (int const )c) {
# 2177 "main.c"
          if (! env) {
# 2177 "main.c"
            tmp = 1;
          } else
# 2177 "main.c"
          if (cs->env) {
# 2177 "main.c"
            tmp = 1;
          } else {
# 2177 "main.c"
            tmp = 0;
          }
# 2177 "main.c"
          doit = tmp;
          {
# 2183 "main.c"
          if ((unsigned int const )cs->type == 5U) {
# 2183 "main.c"
            goto case_5;
          }
# 2187 "main.c"
          if ((unsigned int const )cs->type == 0U) {
# 2187 "main.c"
            goto case_0;
          }
# 2187 "main.c"
          if ((unsigned int const )cs->type == 1U) {
# 2187 "main.c"
            goto case_0;
          }
# 2192 "main.c"
          if ((unsigned int const )cs->type == 2U) {
# 2192 "main.c"
            goto case_2;
          }
# 2220 "main.c"
          if ((unsigned int const )cs->type == 3U) {
# 2220 "main.c"
            goto case_3;
          }
# 2246 "main.c"
          if ((unsigned int const )cs->type == 4U) {
# 2246 "main.c"
            goto case_4;
          }
# 2180 "main.c"
          goto switch_default;
          switch_default:
          {
# 2182 "main.c"
          abort();
          }
          case_5:
# 2185 "main.c"
          goto switch_break;
          case_0:
          case_1:
# 2189 "main.c"
          if (doit) {
# 2190 "main.c"
            *((int *)cs->value_ptr) = (unsigned int const )cs->type == 0U;
          }
# 2191 "main.c"
          goto switch_break;
          case_2:
# 2194 "main.c"
          if (! doit) {
# 2195 "main.c"
            goto switch_break;
          }
# 2197 "main.c"
          if ((unsigned long )optarg == (unsigned long )((char *)0)) {
# 2198 "main.c"
            optarg = (char *)cs->noarg_value;
          }
# 2200 "main.c"
          sl = *((struct stringlist **)cs->value_ptr);
# 2201 "main.c"
          if ((unsigned long )sl == (unsigned long )((struct stringlist *)0)) {
            {
# 2203 "main.c"
            tmp___0 = xmalloc((unsigned int )sizeof(struct stringlist ));
# 2203 "main.c"
            sl = (struct stringlist *)tmp___0;
# 2205 "main.c"
            sl->max = 5U;
# 2206 "main.c"
            sl->idx = 0U;
# 2207 "main.c"
            tmp___1 = xmalloc((unsigned int )(5UL * sizeof(char *)));
# 2207 "main.c"
            sl->list = (char **)tmp___1;
# 2208 "main.c"
            *((struct stringlist **)cs->value_ptr) = sl;
            }
          } else
# 2210 "main.c"
          if (sl->idx == sl->max - 1U) {
            {
# 2212 "main.c"
            sl->max += 5U;
# 2213 "main.c"
            tmp___2 = xrealloc((char *)sl->list, (unsigned int )((unsigned long )sl->max * sizeof(char *)));
# 2213 "main.c"
            sl->list = (char **)tmp___2;
            }
          }
# 2217 "main.c"
          tmp___3 = sl->idx;
# 2217 "main.c"
          (sl->idx) ++;
# 2217 "main.c"
          *(sl->list + tmp___3) = optarg;
# 2218 "main.c"
          *(sl->list + sl->idx) = (char *)0;
# 2219 "main.c"
          goto switch_break;
          case_3:
# 2222 "main.c"
          if ((unsigned long )optarg == (unsigned long )((char *)0)) {
# 2222 "main.c"
            if (argc > optind) {
# 2222 "main.c"
              if ((unsigned int )*(*(argv + optind) + 0) - 48U <= 9U) {
# 2224 "main.c"
                tmp___4 = optind;
# 2224 "main.c"
                optind ++;
# 2224 "main.c"
                optarg = *(argv + tmp___4);
              }
            }
          }
# 2226 "main.c"
          if (! doit) {
# 2227 "main.c"
            goto switch_break;
          }
# 2229 "main.c"
          if ((unsigned long )optarg != (unsigned long )((char *)0)) {
            {
# 2231 "main.c"
            tmp___5 = atoi((char const *)optarg);
# 2231 "main.c"
            i = tmp___5;
            }
# 2232 "main.c"
            if (i < 1) {
# 2234 "main.c"
              if (doit) {
                {
# 2235 "main.c"
                tmp___6 = dcgettext((char const *)((void *)0), "the `-%c\' option requires a positive integral argument",
                                    5);
# 2235 "main.c"
                error((struct floc const *)((struct floc *)0), (char const *)tmp___6,
                      cs->c);
                }
              }
# 2237 "main.c"
              bad = 1;
            } else {
# 2240 "main.c"
              *((unsigned int *)cs->value_ptr) = (unsigned int )i;
            }
          } else {
# 2243 "main.c"
            *((unsigned int *)cs->value_ptr) = *((unsigned int *)cs->noarg_value);
          }
# 2245 "main.c"
          goto switch_break;
          case_4:
# 2249 "main.c"
          if ((unsigned long )optarg == (unsigned long )((char *)0)) {
# 2249 "main.c"
            if (optind < argc) {
# 2249 "main.c"
              if ((unsigned int )*(*(argv + optind) + 0) - 48U <= 9U) {
# 2251 "main.c"
                tmp___7 = optind;
# 2251 "main.c"
                optind ++;
# 2251 "main.c"
                optarg = *(argv + tmp___7);
              } else
# 2249 "main.c"
              if ((int )*(*(argv + optind) + 0) == 46) {
# 2251 "main.c"
                tmp___7 = optind;
# 2251 "main.c"
                optind ++;
# 2251 "main.c"
                optarg = *(argv + tmp___7);
              }
            }
          }
# 2253 "main.c"
          if (doit) {
# 2254 "main.c"
            if ((unsigned long )optarg != (unsigned long )((char *)0)) {
              {
# 2254 "main.c"
              tmp___8 = atof((char const *)optarg);
# 2254 "main.c"
              *((double *)cs->value_ptr) = tmp___8;
              }
            } else {
# 2254 "main.c"
              *((double *)cs->value_ptr) = *((double *)cs->noarg_value);
            }
          }
# 2258 "main.c"
          goto switch_break;
          switch_break: ;
          }
# 2263 "main.c"
          goto while_break___0;
        }
# 2170 "main.c"
        cs ++;
      }
      while_break___0: ;
      }
    }
  }
  while_break: ;
  }
  {
# 2271 "main.c"
  while (1) {
    while_continue___1: ;
# 2271 "main.c"
    if (! (optind < argc)) {
# 2271 "main.c"
      goto while_break___1;
    }
    {
# 2272 "main.c"
    tmp___9 = optind;
# 2272 "main.c"
    optind ++;
# 2272 "main.c"
    handle_non_switch_argument(*(argv + tmp___9), env);
    }
  }
  while_break___1: ;
  }
# 2275 "main.c"
  if (! env) {
# 2275 "main.c"
    if (bad) {
# 2275 "main.c"
      goto _L;
    } else
# 2275 "main.c"
    if (print_usage_flag) {
      _L:
      {
# 2277 "main.c"
      print_usage(bad);
      }
# 2278 "main.c"
      if (bad) {
# 2278 "main.c"
        tmp___10 = 2;
      } else {
# 2278 "main.c"
        tmp___10 = 0;
      }
      {
# 2278 "main.c"
      die(tmp___10);
      }
    }
  }
# 2280 "main.c"
  return;
}
}
# 2287 "main.c"
static void decode_env_switches(char *envar , unsigned int len )
{
  char *varref ;
  void *tmp ;
  char *value ;
  char *p ;
  int argc ;
  char **argv ;
  size_t tmp___0 ;
  void *tmp___1 ;
  char *tmp___2 ;
  char *tmp___3 ;
  unsigned short const **tmp___4 ;
  unsigned short const **tmp___5 ;
  char *tmp___6 ;
  char *tmp___7 ;
  char *tmp___8 ;

  {
  {
# 2292 "main.c"
  tmp = __builtin_alloca((unsigned long )((2U + len) + 2U));
# 2292 "main.c"
  varref = (char *)tmp;
# 2298 "main.c"
  *(varref + 0) = (char )'$';
# 2299 "main.c"
  *(varref + 1) = (char )'(';
# 2300 "main.c"
  memmove((void *)(varref + 2), (void const *)envar, (size_t )len);
# 2301 "main.c"
  *(varref + (2U + len)) = (char )')';
# 2302 "main.c"
  *(varref + ((2U + len) + 1U)) = (char )'\000';
# 2303 "main.c"
  value = variable_expand(varref);
# 2306 "main.c"
  value = next_token(value);
# 2307 "main.c"
  tmp___0 = strlen((char const *)value);
# 2307 "main.c"
  len = (unsigned int )tmp___0;
  }
# 2308 "main.c"
  if (len == 0U) {
# 2309 "main.c"
    return;
  }
  {
# 2312 "main.c"
  tmp___1 = __builtin_alloca((unsigned long )((1U + len) + 1U) * sizeof(char *));
# 2312 "main.c"
  argv = (char **)tmp___1;
# 2317 "main.c"
  tmp___2 = xmalloc(2U * len);
# 2317 "main.c"
  p = tmp___2;
# 2321 "main.c"
  *(argv + 0) = (char *)0;
# 2322 "main.c"
  argc = 1;
# 2323 "main.c"
  *(argv + argc) = p;
  }
  {
# 2324 "main.c"
  while (1) {
    while_continue: ;
# 2324 "main.c"
    if (! ((int )*value != 0)) {
# 2324 "main.c"
      goto while_break;
    }
# 2326 "main.c"
    if ((int )*value == 92) {
# 2326 "main.c"
      if ((int )*(value + 1) != 0) {
# 2327 "main.c"
        value ++;
      } else {
# 2326 "main.c"
        goto _L;
      }
    } else {
      _L:
      {
# 2328 "main.c"
      tmp___5 = __ctype_b_loc();
      }
# 2328 "main.c"
      if ((int const )*(*tmp___5 + (int )*value) & 1) {
# 2331 "main.c"
        tmp___3 = p;
# 2331 "main.c"
        p ++;
# 2331 "main.c"
        *tmp___3 = (char )'\000';
# 2332 "main.c"
        argc ++;
# 2332 "main.c"
        *(argv + argc) = p;
        {
# 2333 "main.c"
        while (1) {
          while_continue___0: ;
          {
# 2334 "main.c"
          value ++;
# 2333 "main.c"
          tmp___4 = __ctype_b_loc();
          }
# 2333 "main.c"
          if (! ((int const )*(*tmp___4 + (int )*value) & 1)) {
# 2333 "main.c"
            goto while_break___0;
          }
        }
        while_break___0: ;
        }
# 2336 "main.c"
        goto while_continue;
      }
    }
# 2338 "main.c"
    tmp___6 = p;
# 2338 "main.c"
    p ++;
# 2338 "main.c"
    tmp___7 = value;
# 2338 "main.c"
    value ++;
# 2338 "main.c"
    *tmp___6 = *tmp___7;
  }
  while_break: ;
  }
# 2340 "main.c"
  *p = (char )'\000';
# 2341 "main.c"
  argc ++;
# 2341 "main.c"
  *(argv + argc) = (char *)0;
# 2343 "main.c"
  if ((int )*(*(argv + 1) + 0) != 45) {
    {
# 2343 "main.c"
    tmp___8 = strchr((char const *)*(argv + 1), '=');
    }
# 2343 "main.c"
    if ((unsigned long )tmp___8 == (unsigned long )((char *)0)) {
      {
# 2348 "main.c"
      *(argv + 1) = concat((char *)"-", *(argv + 1), (char *)"");
      }
    }
  }
  {
# 2351 "main.c"
  decode_switches(argc, argv, 1);
  }
# 2352 "main.c"
  return;
}
}
# 2360 "main.c"
static char *quote_for_env(char *out , char *in )
{
  char *tmp ;
  char *tmp___0 ;
  unsigned short const **tmp___1 ;
  char *tmp___2 ;
  char *tmp___3 ;

  {
  {
# 2364 "main.c"
  while (1) {
    while_continue: ;
# 2364 "main.c"
    if (! ((int )*in != 0)) {
# 2364 "main.c"
      goto while_break;
    }
# 2366 "main.c"
    if ((int )*in == 36) {
# 2367 "main.c"
      tmp = out;
# 2367 "main.c"
      out ++;
# 2367 "main.c"
      *tmp = (char )'$';
    } else {
      {
# 2368 "main.c"
      tmp___1 = __ctype_b_loc();
      }
# 2368 "main.c"
      if ((int const )*(*tmp___1 + (int )*in) & 1) {
# 2369 "main.c"
        tmp___0 = out;
# 2369 "main.c"
        out ++;
# 2369 "main.c"
        *tmp___0 = (char )'\\';
      } else
# 2368 "main.c"
      if ((int )*in == 92) {
# 2369 "main.c"
        tmp___0 = out;
# 2369 "main.c"
        out ++;
# 2369 "main.c"
        *tmp___0 = (char )'\\';
      }
    }
# 2370 "main.c"
    tmp___2 = out;
# 2370 "main.c"
    out ++;
# 2370 "main.c"
    tmp___3 = in;
# 2370 "main.c"
    in ++;
# 2370 "main.c"
    *tmp___2 = *tmp___3;
  }
  while_break: ;
  }
# 2373 "main.c"
  return (out);
}
}
# 2384 "main.c"
static char const ref[17] =
# 2384 "main.c"
  { (char const )'$', (char const )'(', (char const )'M', (char const )'A',
        (char const )'K', (char const )'E', (char const )'O', (char const )'V',
        (char const )'E', (char const )'R', (char const )'R', (char const )'I',
        (char const )'D', (char const )'E', (char const )'S', (char const )')',
        (char const )'\000'};
# 2385 "main.c"
static char const posixref[27] =
# 2385 "main.c"
  { (char const )'$', (char const )'(', (char const )'-', (char const )'*',
        (char const )'-', (char const )'c', (char const )'o', (char const )'m',
        (char const )'m', (char const )'a', (char const )'n', (char const )'d',
        (char const )'-', (char const )'v', (char const )'a', (char const )'r',
        (char const )'i', (char const )'a', (char const )'b', (char const )'l',
        (char const )'e', (char const )'s', (char const )'-', (char const )'*',
        (char const )'-', (char const )')', (char const )'\000'};
# 2380 "main.c"
static void define_makeflags(int all , int makefile )
{
  register struct command_switch const *cs ;
  char *flagstring ;
  register char *p ;
  unsigned int words ;
  struct variable *v ;
  struct flag *flags ;
  unsigned int flagslen ;
  struct flag *new ;
  void *tmp ;
  size_t tmp___0 ;
  struct flag *new___0 ;
  void *tmp___1 ;
  size_t tmp___2 ;
  struct flag *new___1 ;
  void *tmp___3 ;
  size_t tmp___4 ;
  char *buf___1 ;
  void *tmp___5 ;
  struct flag *new___2 ;
  void *tmp___6 ;
  size_t tmp___7 ;
  size_t tmp___8 ;
  struct flag *new___3 ;
  void *tmp___9 ;
  size_t tmp___10 ;
  char *buf___2 ;
  void *tmp___11 ;
  struct flag *new___4 ;
  void *tmp___12 ;
  size_t tmp___13 ;
  size_t tmp___14 ;
  struct stringlist *sl ;
  register unsigned int i ;
  struct flag *new___5 ;
  void *tmp___15 ;
  size_t tmp___16 ;
  size_t tmp___17 ;
  unsigned int tmp___18 ;
  void *tmp___19 ;
  char *tmp___20 ;
  char *tmp___21 ;
  char *tmp___22 ;
  char *tmp___23 ;
  char *tmp___24 ;
  size_t tmp___25 ;
  char *tmp___26 ;
  char *tmp___27 ;
  char *tmp___28 ;
  char *tmp___29 ;
  char *tmp___30 ;
  char *tmp___31 ;
  char *tmp___32 ;
  char *tmp___33 ;
  char *tmp___34 ;
  int tmp___35 ;

  {
# 2403 "main.c"
  flags = (struct flag *)0;
# 2404 "main.c"
  flagslen = 0U;
# 2421 "main.c"
  cs = switches;
  {
# 2421 "main.c"
  while (1) {
    while_continue: ;
# 2421 "main.c"
    if (! (cs->c != 0)) {
# 2421 "main.c"
      goto while_break;
    }
# 2422 "main.c"
    if (cs->toenv) {
# 2422 "main.c"
      if (! makefile) {
# 2422 "main.c"
        goto _L___4;
      } else
# 2422 "main.c"
      if (! cs->no_makefile) {
        _L___4:
        {
# 2427 "main.c"
        if ((unsigned int const )cs->type == 5U) {
# 2427 "main.c"
          goto case_5;
        }
# 2431 "main.c"
        if ((unsigned int const )cs->type == 0U) {
# 2431 "main.c"
          goto case_0;
        }
# 2431 "main.c"
        if ((unsigned int const )cs->type == 1U) {
# 2431 "main.c"
          goto case_0;
        }
# 2438 "main.c"
        if ((unsigned int const )cs->type == 3U) {
# 2438 "main.c"
          goto case_3;
        }
# 2461 "main.c"
        if ((unsigned int const )cs->type == 4U) {
# 2461 "main.c"
          goto case_4;
        }
# 2482 "main.c"
        if ((unsigned int const )cs->type == 2U) {
# 2482 "main.c"
          goto case_2;
        }
# 2424 "main.c"
        goto switch_default;
        switch_default:
        {
# 2426 "main.c"
        abort();
        }
        case_5:
# 2429 "main.c"
        goto switch_break;
        case_0:
        case_1:
# 2433 "main.c"
        if (! *((int *)cs->value_ptr) == ((unsigned int const )cs->type == 1U)) {
# 2433 "main.c"
          if ((unsigned long )cs->default_value == (unsigned long )((char * const )0)) {
# 2433 "main.c"
            goto _L;
          } else
# 2433 "main.c"
          if (*((int *)cs->value_ptr) != *((int *)cs->default_value)) {
            _L:
            {
# 2436 "main.c"
            while (1) {
              while_continue___0: ;
              {
# 2436 "main.c"
              tmp = __builtin_alloca(sizeof(struct flag ));
# 2436 "main.c"
              new = (struct flag *)tmp;
# 2436 "main.c"
              new->cs = cs;
# 2436 "main.c"
              new->arg = (char *)0;
# 2436 "main.c"
              new->next = flags;
# 2436 "main.c"
              flags = new;
              }
# 2436 "main.c"
              if ((unsigned long )new->arg == (unsigned long )((char *)0)) {
# 2436 "main.c"
                flagslen ++;
              } else {
# 2436 "main.c"
                flagslen += 4U;
              }
# 2436 "main.c"
              if (! (cs->c <= 127)) {
                {
# 2436 "main.c"
                tmp___0 = strlen((char const *)cs->long_name);
# 2436 "main.c"
                flagslen = (unsigned int )((size_t )flagslen + (2UL + tmp___0));
                }
              }
# 2436 "main.c"
              goto while_break___0;
            }
            while_break___0: ;
            }
          }
        }
# 2437 "main.c"
        goto switch_break;
        case_3:
# 2440 "main.c"
        if (all) {
# 2442 "main.c"
          if ((unsigned long )cs->default_value != (unsigned long )((char * const )0)) {
# 2442 "main.c"
            if (*((unsigned int *)cs->value_ptr) == *((unsigned int *)cs->default_value)) {
# 2445 "main.c"
              goto switch_break;
            } else {
# 2442 "main.c"
              goto _L___1;
            }
          } else
          _L___1:
# 2446 "main.c"
          if ((unsigned long )cs->noarg_value != (unsigned long )((char * const )0)) {
# 2446 "main.c"
            if (*((unsigned int *)cs->value_ptr) == *((unsigned int *)cs->noarg_value)) {
              {
# 2449 "main.c"
              while (1) {
                while_continue___1: ;
                {
# 2449 "main.c"
                tmp___1 = __builtin_alloca(sizeof(struct flag ));
# 2449 "main.c"
                new___0 = (struct flag *)tmp___1;
# 2449 "main.c"
                new___0->cs = cs;
# 2449 "main.c"
                new___0->arg = (char *)"";
# 2449 "main.c"
                new___0->next = flags;
# 2449 "main.c"
                flags = new___0;
                }
# 2449 "main.c"
                if ((unsigned long )new___0->arg == (unsigned long )((char *)0)) {
# 2449 "main.c"
                  flagslen ++;
                } else {
# 2449 "main.c"
                  flagslen += 4U;
                }
# 2449 "main.c"
                if (! (cs->c <= 127)) {
                  {
# 2449 "main.c"
                  tmp___2 = strlen((char const *)cs->long_name);
# 2449 "main.c"
                  flagslen = (unsigned int )((size_t )flagslen + (2UL + tmp___2));
                  }
                }
# 2449 "main.c"
                goto while_break___1;
              }
              while_break___1: ;
              }
            } else {
# 2446 "main.c"
              goto _L___0;
            }
          } else
          _L___0:
# 2450 "main.c"
          if (cs->c == 106) {
            {
# 2452 "main.c"
            while (1) {
              while_continue___2: ;
              {
# 2452 "main.c"
              tmp___3 = __builtin_alloca(sizeof(struct flag ));
# 2452 "main.c"
              new___1 = (struct flag *)tmp___3;
# 2452 "main.c"
              new___1->cs = cs;
# 2452 "main.c"
              new___1->arg = (char *)"1";
# 2452 "main.c"
              new___1->next = flags;
# 2452 "main.c"
              flags = new___1;
              }
# 2452 "main.c"
              if ((unsigned long )new___1->arg == (unsigned long )((char *)0)) {
# 2452 "main.c"
                flagslen ++;
              } else {
# 2452 "main.c"
                flagslen += 7U;
              }
# 2452 "main.c"
              if (! (cs->c <= 127)) {
                {
# 2452 "main.c"
                tmp___4 = strlen((char const *)cs->long_name);
# 2452 "main.c"
                flagslen = (unsigned int )((size_t )flagslen + (2UL + tmp___4));
                }
              }
# 2452 "main.c"
              goto while_break___2;
            }
            while_break___2: ;
            }
          } else {
            {
# 2455 "main.c"
            tmp___5 = __builtin_alloca(30UL);
# 2455 "main.c"
            buf___1 = (char *)tmp___5;
# 2456 "main.c"
            sprintf((char * __restrict )buf___1, (char const * __restrict )"%u",
                    *((unsigned int *)cs->value_ptr));
            }
            {
# 2457 "main.c"
            while (1) {
              while_continue___3: ;
              {
# 2457 "main.c"
              tmp___6 = __builtin_alloca(sizeof(struct flag ));
# 2457 "main.c"
              new___2 = (struct flag *)tmp___6;
# 2457 "main.c"
              new___2->cs = cs;
# 2457 "main.c"
              new___2->arg = buf___1;
# 2457 "main.c"
              new___2->next = flags;
# 2457 "main.c"
              flags = new___2;
              }
# 2457 "main.c"
              if ((unsigned long )new___2->arg == (unsigned long )((char *)0)) {
# 2457 "main.c"
                flagslen ++;
              } else {
                {
# 2457 "main.c"
                tmp___7 = strlen((char const *)buf___1);
# 2457 "main.c"
                flagslen = (unsigned int )((size_t )flagslen + (4UL + 3UL * tmp___7));
                }
              }
# 2457 "main.c"
              if (! (cs->c <= 127)) {
                {
# 2457 "main.c"
                tmp___8 = strlen((char const *)cs->long_name);
# 2457 "main.c"
                flagslen = (unsigned int )((size_t )flagslen + (2UL + tmp___8));
                }
              }
# 2457 "main.c"
              goto while_break___3;
            }
            while_break___3: ;
            }
          }
        }
# 2460 "main.c"
        goto switch_break;
        case_4:
# 2464 "main.c"
        if (all) {
# 2466 "main.c"
          if ((unsigned long )cs->default_value != (unsigned long )((char * const )0)) {
# 2466 "main.c"
            if (*((double *)cs->value_ptr) == *((double *)cs->default_value)) {
# 2469 "main.c"
              goto switch_break;
            } else {
# 2466 "main.c"
              goto _L___3;
            }
          } else
          _L___3:
# 2470 "main.c"
          if ((unsigned long )cs->noarg_value != (unsigned long )((char * const )0)) {
# 2470 "main.c"
            if (*((double *)cs->value_ptr) == *((double *)cs->noarg_value)) {
              {
# 2473 "main.c"
              while (1) {
                while_continue___4: ;
                {
# 2473 "main.c"
                tmp___9 = __builtin_alloca(sizeof(struct flag ));
# 2473 "main.c"
                new___3 = (struct flag *)tmp___9;
# 2473 "main.c"
                new___3->cs = cs;
# 2473 "main.c"
                new___3->arg = (char *)"";
# 2473 "main.c"
                new___3->next = flags;
# 2473 "main.c"
                flags = new___3;
                }
# 2473 "main.c"
                if ((unsigned long )new___3->arg == (unsigned long )((char *)0)) {
# 2473 "main.c"
                  flagslen ++;
                } else {
# 2473 "main.c"
                  flagslen += 4U;
                }
# 2473 "main.c"
                if (! (cs->c <= 127)) {
                  {
# 2473 "main.c"
                  tmp___10 = strlen((char const *)cs->long_name);
# 2473 "main.c"
                  flagslen = (unsigned int )((size_t )flagslen + (2UL + tmp___10));
                  }
                }
# 2473 "main.c"
                goto while_break___4;
              }
              while_break___4: ;
              }
            } else {
# 2470 "main.c"
              goto _L___2;
            }
          } else {
            _L___2:
            {
# 2476 "main.c"
            tmp___11 = __builtin_alloca(100UL);
# 2476 "main.c"
            buf___2 = (char *)tmp___11;
# 2477 "main.c"
            sprintf((char * __restrict )buf___2, (char const * __restrict )"%g",
                    *((double *)cs->value_ptr));
            }
            {
# 2478 "main.c"
            while (1) {
              while_continue___5: ;
              {
# 2478 "main.c"
              tmp___12 = __builtin_alloca(sizeof(struct flag ));
# 2478 "main.c"
              new___4 = (struct flag *)tmp___12;
# 2478 "main.c"
              new___4->cs = cs;
# 2478 "main.c"
              new___4->arg = buf___2;
# 2478 "main.c"
              new___4->next = flags;
# 2478 "main.c"
              flags = new___4;
              }
# 2478 "main.c"
              if ((unsigned long )new___4->arg == (unsigned long )((char *)0)) {
# 2478 "main.c"
                flagslen ++;
              } else {
                {
# 2478 "main.c"
                tmp___13 = strlen((char const *)buf___2);
# 2478 "main.c"
                flagslen = (unsigned int )((size_t )flagslen + (4UL + 3UL * tmp___13));
                }
              }
# 2478 "main.c"
              if (! (cs->c <= 127)) {
                {
# 2478 "main.c"
                tmp___14 = strlen((char const *)cs->long_name);
# 2478 "main.c"
                flagslen = (unsigned int )((size_t )flagslen + (2UL + tmp___14));
                }
              }
# 2478 "main.c"
              goto while_break___5;
            }
            while_break___5: ;
            }
          }
        }
# 2481 "main.c"
        goto switch_break;
        case_2:
# 2485 "main.c"
        if (all) {
# 2487 "main.c"
          sl = *((struct stringlist **)cs->value_ptr);
# 2488 "main.c"
          if ((unsigned long )sl != (unsigned long )((struct stringlist *)0)) {
# 2493 "main.c"
            i = sl->idx;
            {
# 2494 "main.c"
            while (1) {
              while_continue___6: ;
# 2494 "main.c"
              tmp___18 = i;
# 2494 "main.c"
              i --;
# 2494 "main.c"
              if (! (tmp___18 > 0U)) {
# 2494 "main.c"
                goto while_break___6;
              }
              {
# 2495 "main.c"
              while (1) {
                while_continue___7: ;
                {
# 2495 "main.c"
                tmp___15 = __builtin_alloca(sizeof(struct flag ));
# 2495 "main.c"
                new___5 = (struct flag *)tmp___15;
# 2495 "main.c"
                new___5->cs = cs;
# 2495 "main.c"
                new___5->arg = *(sl->list + i);
# 2495 "main.c"
                new___5->next = flags;
# 2495 "main.c"
                flags = new___5;
                }
# 2495 "main.c"
                if ((unsigned long )new___5->arg == (unsigned long )((char *)0)) {
# 2495 "main.c"
                  flagslen ++;
                } else {
                  {
# 2495 "main.c"
                  tmp___16 = strlen((char const *)*(sl->list + i));
# 2495 "main.c"
                  flagslen = (unsigned int )((size_t )flagslen + (4UL + 3UL * tmp___16));
                  }
                }
# 2495 "main.c"
                if (! (cs->c <= 127)) {
                  {
# 2495 "main.c"
                  tmp___17 = strlen((char const *)cs->long_name);
# 2495 "main.c"
                  flagslen = (unsigned int )((size_t )flagslen + (2UL + tmp___17));
                  }
                }
# 2495 "main.c"
                goto while_break___7;
              }
              while_break___7: ;
              }
            }
            while_break___6: ;
            }
          }
        }
# 2498 "main.c"
        goto switch_break;
        switch_break: ;
        }
      }
    }
# 2421 "main.c"
    cs ++;
  }
  while_break: ;
  }
  {
# 2501 "main.c"
  flagslen = (unsigned int )((unsigned long )flagslen + (4UL + sizeof(posixref)));
# 2507 "main.c"
  tmp___19 = __builtin_alloca((unsigned long )((1U + flagslen) + 1U));
# 2507 "main.c"
  flagstring = (char *)tmp___19;
# 2508 "main.c"
  memset((void *)flagstring, 0, (size_t )((1U + flagslen) + 1U));
# 2509 "main.c"
  p = flagstring;
# 2510 "main.c"
  words = 1U;
# 2511 "main.c"
  tmp___20 = p;
# 2511 "main.c"
  p ++;
# 2511 "main.c"
  *tmp___20 = (char )'-';
  }
  {
# 2512 "main.c"
  while (1) {
    while_continue___8: ;
# 2512 "main.c"
    if (! ((unsigned long )flags != (unsigned long )((struct flag *)0))) {
# 2512 "main.c"
      goto while_break___8;
    }
# 2515 "main.c"
    if ((flags->cs)->c <= 127) {
# 2516 "main.c"
      tmp___21 = p;
# 2516 "main.c"
      p ++;
# 2516 "main.c"
      *tmp___21 = (char )(flags->cs)->c;
    } else {
# 2519 "main.c"
      if ((int )*p != 45) {
# 2521 "main.c"
        tmp___22 = p;
# 2521 "main.c"
        p ++;
# 2521 "main.c"
        *tmp___22 = (char )' ';
# 2522 "main.c"
        tmp___23 = p;
# 2522 "main.c"
        p ++;
# 2522 "main.c"
        *tmp___23 = (char )'-';
      }
      {
# 2524 "main.c"
      tmp___24 = p;
# 2524 "main.c"
      p ++;
# 2524 "main.c"
      *tmp___24 = (char )'-';
# 2525 "main.c"
      strcpy((char * __restrict )p, (char const * __restrict )(flags->cs)->long_name);
# 2526 "main.c"
      tmp___25 = strlen((char const *)p);
# 2526 "main.c"
      p += tmp___25;
      }
    }
# 2528 "main.c"
    if ((unsigned long )flags->arg != (unsigned long )((char *)0)) {
# 2534 "main.c"
      if ((int )*(flags->arg + 0) != 0) {
# 2537 "main.c"
        tmp___26 = p;
# 2537 "main.c"
        p ++;
# 2537 "main.c"
        if (! ((flags->cs)->c <= 127)) {
# 2537 "main.c"
          *tmp___26 = (char )'=';
        } else {
# 2537 "main.c"
          *tmp___26 = (char )' ';
        }
        {
# 2538 "main.c"
        p = quote_for_env(p, flags->arg);
        }
      }
# 2540 "main.c"
      words ++;
# 2542 "main.c"
      tmp___27 = p;
# 2542 "main.c"
      p ++;
# 2542 "main.c"
      *tmp___27 = (char )' ';
# 2543 "main.c"
      tmp___28 = p;
# 2543 "main.c"
      p ++;
# 2543 "main.c"
      *tmp___28 = (char )'-';
    } else
# 2545 "main.c"
    if (! ((flags->cs)->c <= 127)) {
# 2547 "main.c"
      words ++;
# 2550 "main.c"
      tmp___29 = p;
# 2550 "main.c"
      p ++;
# 2550 "main.c"
      *tmp___29 = (char )' ';
# 2551 "main.c"
      tmp___30 = p;
# 2551 "main.c"
      p ++;
# 2551 "main.c"
      *tmp___30 = (char )'-';
    }
# 2553 "main.c"
    flags = flags->next;
  }
  while_break___8: ;
  }
# 2558 "main.c"
  if ((unsigned long )p == (unsigned long )(flagstring + 1)) {
# 2560 "main.c"
    *(flagstring + 0) = (char )'\000';
  } else
# 2561 "main.c"
  if ((int )*(p + -1) == 45) {
# 2564 "main.c"
    p -= 2;
# 2565 "main.c"
    *p = (char )'\000';
  } else {
# 2569 "main.c"
    *p = (char )'\000';
  }
  {
# 2573 "main.c"
  define_variable_in_set((char *)"MFLAGS", 6U, flagstring, (enum variable_origin )1,
                         1, current_variable_set_list->set, (struct floc const *)((struct floc *)0));
  }
# 2575 "main.c"
  if (all) {
# 2575 "main.c"
    if ((unsigned long )command_variables != (unsigned long )((struct command_variable *)0)) {
# 2580 "main.c"
      if ((unsigned long )p == (unsigned long )(flagstring + 1)) {
# 2582 "main.c"
        p = flagstring;
      } else {
# 2586 "main.c"
        if ((int )*(p + -1) != 45) {
# 2589 "main.c"
          tmp___31 = p;
# 2589 "main.c"
          p ++;
# 2589 "main.c"
          *tmp___31 = (char )' ';
# 2590 "main.c"
          tmp___32 = p;
# 2590 "main.c"
          p ++;
# 2590 "main.c"
          *tmp___32 = (char )'-';
        }
# 2593 "main.c"
        tmp___33 = p;
# 2593 "main.c"
        p ++;
# 2593 "main.c"
        *tmp___33 = (char )'-';
# 2594 "main.c"
        tmp___34 = p;
# 2594 "main.c"
        p ++;
# 2594 "main.c"
        *tmp___34 = (char )' ';
      }
# 2598 "main.c"
      if (posix_pedantic) {
        {
# 2600 "main.c"
        memmove((void *)p, (void const *)(posixref), sizeof(posixref) - 1UL);
# 2601 "main.c"
        p += sizeof(posixref) - 1UL;
        }
      } else {
        {
# 2605 "main.c"
        memmove((void *)p, (void const *)(ref), sizeof(ref) - 1UL);
# 2606 "main.c"
        p += sizeof(ref) - 1UL;
        }
      }
    } else {
# 2575 "main.c"
      goto _L___5;
    }
  } else
  _L___5:
# 2609 "main.c"
  if ((unsigned long )p == (unsigned long )(flagstring + 1)) {
# 2611 "main.c"
    words = 0U;
# 2612 "main.c"
    p --;
  } else
# 2614 "main.c"
  if ((int )*(p + -1) == 45) {
# 2616 "main.c"
    p -= 2;
  }
# 2618 "main.c"
  *p = (char )'\000';
# 2620 "main.c"
  if ((int )*(flagstring + 0) == 45) {
# 2620 "main.c"
    if ((int )*(flagstring + 1) != 45) {
# 2620 "main.c"
      tmp___35 = 1;
    } else {
# 2620 "main.c"
      tmp___35 = 0;
    }
  } else {
# 2620 "main.c"
    tmp___35 = 0;
  }
  {
# 2620 "main.c"
  v = define_variable_in_set((char *)"MAKEFLAGS", 9U, flagstring + tmp___35, (enum variable_origin )2,
                             1, current_variable_set_list->set, (struct floc const *)((struct floc *)0));
  }
# 2634 "main.c"
  if (! all) {
# 2638 "main.c"
    v->export = (enum variable_export )0;
  }
# 2639 "main.c"
  return;
}
}
# 2646 "main.c"
char *make_host ;
# 2647 "main.c"
static int printed_version = 0;
# 2643 "main.c"
static void print_version(void)
{
  char *precede ;
  char const *tmp ;
  char *tmp___0 ;

  {
# 2649 "main.c"
  if (print_data_base_flag) {
# 2649 "main.c"
    tmp = "# ";
  } else {
# 2649 "main.c"
    tmp = "";
  }
# 2649 "main.c"
  precede = (char *)tmp;
# 2651 "main.c"
  if (printed_version) {
# 2653 "main.c"
    return;
  }
  {
# 2655 "main.c"
  printf((char const * __restrict )"%sGNU Make version %s", precede, version_string);
  }
# 2656 "main.c"
  if ((unsigned long )remote_description != (unsigned long )((char *)0)) {
# 2656 "main.c"
    if ((int )*remote_description != 0) {
      {
# 2657 "main.c"
      printf((char const * __restrict )"-%s", remote_description);
      }
    }
  }
  {
# 2659 "main.c"
  tmp___0 = dcgettext((char const *)((void *)0), ", by Richard Stallman and Roland McGrath.\n%sBuilt for %s\n%sCopyright (C) 1988, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99\n%s\tFree Software Foundation, Inc.\n%sThis is free software; see the source for copying conditions.\n%sThere is NO warranty; not even for MERCHANTABILITY or FITNESS FOR A\n%sPARTICULAR PURPOSE.\n\n%sReport bugs to <bug-make@gnu.org>.\n\n",
                      5);
# 2659 "main.c"
  printf((char const * __restrict )tmp___0, precede, make_host, precede, precede,
         precede, precede, precede, precede);
# 2670 "main.c"
  printed_version = 1;
# 2674 "main.c"
  fflush(stdout);
  }
# 2675 "main.c"
  return;
}
}
# 2679 "main.c"
static void print_data_base(void)
{
  time_t when ;
  char *tmp ;
  char *tmp___0 ;
  char *tmp___1 ;
  char *tmp___2 ;

  {
  {
# 2684 "main.c"
  when = time((time_t *)0);
# 2685 "main.c"
  tmp = ctime((time_t const *)(& when));
# 2685 "main.c"
  tmp___0 = dcgettext((char const *)((void *)0), "\n# Make data base, printed on %s",
                      5);
# 2685 "main.c"
  printf((char const * __restrict )tmp___0, tmp);
# 2687 "main.c"
  print_variable_data_base();
# 2688 "main.c"
  print_dir_data_base();
# 2689 "main.c"
  print_rule_data_base();
# 2690 "main.c"
  print_file_data_base();
# 2691 "main.c"
  print_vpath_data_base();
# 2693 "main.c"
  when = time((time_t *)0);
# 2694 "main.c"
  tmp___1 = ctime((time_t const *)(& when));
# 2694 "main.c"
  tmp___2 = dcgettext((char const *)((void *)0), "\n# Finished Make data base on %s\n",
                      5);
# 2694 "main.c"
  printf((char const * __restrict )tmp___2, tmp___1);
  }
# 2695 "main.c"
  return;
}
}
# 2703 "main.c"
static char dying = (char)0;
# 2699 "main.c"
 __attribute__((__noreturn__)) void die(int status ) ;
# 2699 "main.c"
void die(int status )
{
  int err ;

  {
# 2705 "main.c"
  if (! dying) {
# 2709 "main.c"
    dying = (char)1;
# 2711 "main.c"
    if (print_version_flag) {
      {
# 2712 "main.c"
      print_version();
      }
    }
# 2715 "main.c"
    err = status != 0;
    {
# 2715 "main.c"
    while (1) {
      while_continue: ;
# 2715 "main.c"
      if (! (job_slots_used > 0U)) {
# 2715 "main.c"
        goto while_break;
      }
      {
# 2716 "main.c"
      reap_children(1, err);
# 2715 "main.c"
      err = 0;
      }
    }
    while_break: ;
    }
    {
# 2719 "main.c"
    remote_cleanup();
# 2722 "main.c"
    remove_intermediates(0);
    }
# 2724 "main.c"
    if (print_data_base_flag) {
      {
# 2725 "main.c"
      print_data_base();
      }
    }
# 2732 "main.c"
    if ((unsigned long )directory_before_chdir != (unsigned long )((char *)0)) {
      {
# 2733 "main.c"
      chdir((char const *)directory_before_chdir);
      }
    }
    {
# 2735 "main.c"
    log_working_directory(0);
    }
  }
  {
# 2738 "main.c"
  exit(status);
  }
}
}
# 2748 "main.c"
static int entered = 0;
# 2744 "main.c"
void log_working_directory(int entering )
{
  char *msg ;
  char *tmp ;
  char *tmp___0 ;
  char *tmp___1 ;
  char *tmp___2 ;
  char *tmp___3 ;

  {
# 2749 "main.c"
  if (entering) {
    {
# 2749 "main.c"
    tmp = dcgettext((char const *)((void *)0), "Entering", 5);
# 2749 "main.c"
    tmp___1 = tmp;
    }
  } else {
    {
# 2749 "main.c"
    tmp___0 = dcgettext((char const *)((void *)0), "Leaving", 5);
# 2749 "main.c"
    tmp___1 = tmp___0;
    }
  }
# 2749 "main.c"
  msg = tmp___1;
# 2754 "main.c"
  if (! print_directory_flag) {
# 2755 "main.c"
    return;
  } else
# 2754 "main.c"
  if (entering == entered) {
# 2755 "main.c"
    return;
  }
# 2757 "main.c"
  entered = entering;
# 2759 "main.c"
  if (print_data_base_flag) {
    {
# 2760 "main.c"
    fputs((char const * __restrict )"# ", (FILE * __restrict )stdout);
    }
  }
# 2762 "main.c"
  if (makelevel == 0U) {
    {
# 2763 "main.c"
    printf((char const * __restrict )"%s: %s ", program, msg);
    }
  } else {
    {
# 2765 "main.c"
    printf((char const * __restrict )"%s[%u]: %s ", program, makelevel, msg);
    }
  }
# 2767 "main.c"
  if ((unsigned long )starting_directory == (unsigned long )((char *)0)) {
    {
# 2768 "main.c"
    tmp___2 = dcgettext((char const *)((void *)0), "an unknown directory", 5);
# 2768 "main.c"
    puts((char const *)tmp___2);
    }
  } else {
    {
# 2770 "main.c"
    tmp___3 = dcgettext((char const *)((void *)0), "directory `%s\'\n", 5);
# 2770 "main.c"
    printf((char const * __restrict )tmp___3, starting_directory);
    }
  }
# 2771 "main.c"
  return;
}
}
# 1 "misc.o"
#pragma merger("0","/tmp/cil-jXxeXTt3.i","-g,-O0")
# 434 "/usr/include/x86_64-linux-gnu/bits/libio.h"
extern int _IO_putc(int __c , _IO_FILE *__fp ) ;
# 327 "/usr/include/stdio.h"
extern int vfprintf(FILE * __restrict __s , char const * __restrict __format ,
                    __gnuc_va_list __arg ) ;
# 678 "/usr/include/unistd.h"
extern __attribute__((__nothrow__)) __uid_t ( __attribute__((__leaf__)) getuid)(void) ;
# 681 "/usr/include/unistd.h"
extern __attribute__((__nothrow__)) __uid_t ( __attribute__((__leaf__)) geteuid)(void) ;
# 684 "/usr/include/unistd.h"
extern __attribute__((__nothrow__)) __gid_t ( __attribute__((__leaf__)) getgid)(void) ;
# 687 "/usr/include/unistd.h"
extern __attribute__((__nothrow__)) __gid_t ( __attribute__((__leaf__)) getegid)(void) ;
# 703 "/usr/include/unistd.h"
extern __attribute__((__nothrow__)) int ( __attribute__((__leaf__)) setuid)(__uid_t __uid ) ;
# 713 "/usr/include/unistd.h"
extern __attribute__((__nothrow__)) int ( __attribute__((__leaf__)) seteuid)(__uid_t __uid ) ;
# 720 "/usr/include/unistd.h"
extern __attribute__((__nothrow__)) int ( __attribute__((__leaf__)) setgid)(__gid_t __gid ) ;
# 730 "/usr/include/unistd.h"
extern __attribute__((__nothrow__)) int ( __attribute__((__leaf__)) setegid)(__gid_t __gid ) ;
# 539 "/usr/include/stdlib.h"
extern __attribute__((__nothrow__)) void *( __attribute__((__leaf__)) malloc)(size_t __size ) __attribute__((__malloc__)) ;
# 549 "/usr/include/stdlib.h"
extern __attribute__((__nothrow__)) void *( __attribute__((__warn_unused_result__,
__leaf__)) realloc)(void *__ptr , size_t __size ) ;
# 166 "/usr/include/string.h"
extern __attribute__((__nothrow__)) char *( __attribute__((__nonnull__(1), __leaf__)) strdup)(char const *__s ) __attribute__((__malloc__)) ;
# 396 "/usr/include/string.h"
extern __attribute__((__nothrow__)) char *( __attribute__((__leaf__)) strerror)(int errnum ) ;
# 401 "make.h"
void collapse_continuations(char *line ) ;
# 402 "make.h"
void remove_comments(char *line ) ;
# 408 "make.h"
char *find_char_unquote(char *string___0 , char *stopchars , int blank ) ;
# 73 "dep.h"
struct dep *copy_dep_chain(struct dep *d ) ;
# 60 "misc.c"
int alpha_compare(void const *v1 , void const *v2 )
{
  char const *s1 ;
  char const *s2 ;
  int tmp ;

  {
# 64 "misc.c"
  s1 = (char const *)*((char **)v1);
# 65 "misc.c"
  s2 = (char const *)*((char **)v2);
# 67 "misc.c"
  if ((int const )*s1 != (int const )*s2) {
# 68 "misc.c"
    return ((int )((int const )*s1 - (int const )*s2));
  }
  {
# 69 "misc.c"
  tmp = strcmp(s1, s2);
  }
# 69 "misc.c"
  return (tmp);
}
}
# 76 "misc.c"
void collapse_continuations(char *line )
{
  register char *in ;
  register char *out ;
  register char *p ;
  register int backslash ;
  register unsigned int bs_write ;
  char *tmp ;
  unsigned int tmp___0 ;
  unsigned short const **tmp___1 ;
  char *tmp___2 ;
  char *tmp___3 ;
  char *tmp___4 ;
  char *tmp___5 ;
  char *tmp___6 ;
  char *tmp___7 ;

  {
  {
# 84 "misc.c"
  in = strchr((char const *)line, '\n');
  }
# 85 "misc.c"
  if ((unsigned long )in == (unsigned long )((char *)0)) {
# 86 "misc.c"
    return;
  }
# 88 "misc.c"
  out = in;
  {
# 89 "misc.c"
  while (1) {
    while_continue: ;
# 89 "misc.c"
    if ((unsigned long )out > (unsigned long )line) {
# 89 "misc.c"
      if (! ((int )*(out + -1) == 92)) {
# 89 "misc.c"
        goto while_break;
      }
    } else {
# 89 "misc.c"
      goto while_break;
    }
# 90 "misc.c"
    out --;
  }
  while_break: ;
  }
  {
# 92 "misc.c"
  while (1) {
    while_continue___0: ;
# 92 "misc.c"
    if (! ((int )*in != 0)) {
# 92 "misc.c"
      goto while_break___0;
    }
# 97 "misc.c"
    backslash = 0;
# 98 "misc.c"
    bs_write = 0U;
# 99 "misc.c"
    p = in - 1;
    {
# 99 "misc.c"
    while (1) {
      while_continue___1: ;
# 99 "misc.c"
      if ((unsigned long )p >= (unsigned long )line) {
# 99 "misc.c"
        if (! ((int )*p == 92)) {
# 99 "misc.c"
          goto while_break___1;
        }
      } else {
# 99 "misc.c"
        goto while_break___1;
      }
# 101 "misc.c"
      if (backslash) {
# 102 "misc.c"
        bs_write ++;
      }
# 103 "misc.c"
      backslash = ! backslash;
# 107 "misc.c"
      if ((unsigned long )in == (unsigned long )(out - 1)) {
        {
# 108 "misc.c"
        abort();
        }
      }
# 99 "misc.c"
      p --;
    }
    while_break___1: ;
    }
    {
# 112 "misc.c"
    while (1) {
      while_continue___2: ;
# 112 "misc.c"
      tmp___0 = bs_write;
# 112 "misc.c"
      bs_write --;
# 112 "misc.c"
      if (! (tmp___0 > 0U)) {
# 112 "misc.c"
        goto while_break___2;
      }
# 113 "misc.c"
      tmp = out;
# 113 "misc.c"
      out ++;
# 113 "misc.c"
      *tmp = (char )'\\';
    }
    while_break___2: ;
    }
# 116 "misc.c"
    in ++;
# 120 "misc.c"
    if (backslash) {
      {
# 122 "misc.c"
      in = next_token(in);
      }
      {
# 123 "misc.c"
      while (1) {
        while_continue___3: ;
# 123 "misc.c"
        if ((unsigned long )out > (unsigned long )line) {
          {
# 123 "misc.c"
          tmp___1 = __ctype_b_loc();
          }
# 123 "misc.c"
          if (! ((int const )*(*tmp___1 + (int )*(out + -1)) & 1)) {
# 123 "misc.c"
            goto while_break___3;
          }
        } else {
# 123 "misc.c"
          goto while_break___3;
        }
# 124 "misc.c"
        out --;
      }
      while_break___3: ;
      }
# 125 "misc.c"
      tmp___2 = out;
# 125 "misc.c"
      out ++;
# 125 "misc.c"
      *tmp___2 = (char )' ';
    } else {
# 129 "misc.c"
      tmp___3 = out;
# 129 "misc.c"
      out ++;
# 129 "misc.c"
      *tmp___3 = (char )'\n';
    }
    {
# 133 "misc.c"
    while (1) {
      while_continue___4: ;
# 133 "misc.c"
      if (! ((int )*in != 0)) {
# 133 "misc.c"
        goto while_break___4;
      }
# 134 "misc.c"
      if ((int )*in == 92) {
# 136 "misc.c"
        p = in + 1;
        {
# 137 "misc.c"
        while (1) {
          while_continue___5: ;
# 137 "misc.c"
          if (! ((int )*p == 92)) {
# 137 "misc.c"
            goto while_break___5;
          }
# 138 "misc.c"
          p ++;
        }
        while_break___5: ;
        }
# 139 "misc.c"
        if ((int )*p == 10) {
# 141 "misc.c"
          in = p;
# 142 "misc.c"
          goto while_break___4;
        }
        {
# 144 "misc.c"
        while (1) {
          while_continue___6: ;
# 144 "misc.c"
          if (! ((unsigned long )in < (unsigned long )p)) {
# 144 "misc.c"
            goto while_break___6;
          }
# 145 "misc.c"
          tmp___4 = out;
# 145 "misc.c"
          out ++;
# 145 "misc.c"
          tmp___5 = in;
# 145 "misc.c"
          in ++;
# 145 "misc.c"
          *tmp___4 = *tmp___5;
        }
        while_break___6: ;
        }
      } else {
# 148 "misc.c"
        tmp___6 = out;
# 148 "misc.c"
        out ++;
# 148 "misc.c"
        tmp___7 = in;
# 148 "misc.c"
        in ++;
# 148 "misc.c"
        *tmp___6 = *tmp___7;
      }
    }
    while_break___4: ;
    }
  }
  while_break___0: ;
  }
# 151 "misc.c"
  *out = (char )'\000';
# 152 "misc.c"
  return;
}
}
# 158 "misc.c"
void remove_comments(char *line )
{
  char *comment ;

  {
  {
# 164 "misc.c"
  comment = find_char_unquote(line, (char *)"#", 0);
  }
# 166 "misc.c"
  if ((unsigned long )comment != (unsigned long )((char *)0)) {
# 168 "misc.c"
    *comment = (char )'\000';
  }
# 169 "misc.c"
  return;
}
}
# 173 "misc.c"
void print_spaces(unsigned int n )
{
  unsigned int tmp ;

  {
  {
# 177 "misc.c"
  while (1) {
    while_continue: ;
# 177 "misc.c"
    tmp = n;
# 177 "misc.c"
    n --;
# 177 "misc.c"
    if (! (tmp > 0U)) {
# 177 "misc.c"
      goto while_break;
    }
    {
# 178 "misc.c"
    putchar(' ');
    }
  }
  while_break: ;
  }
# 179 "misc.c"
  return;
}
}
# 185 "misc.c"
char *concat(char *s1 , char *s2 , char *s3 )
{
  register unsigned int len1 ;
  register unsigned int len2 ;
  register unsigned int len3 ;
  register char *result___0 ;
  size_t tmp ;
  size_t tmp___0 ;
  size_t tmp___1 ;
  char *tmp___2 ;

  {
# 192 "misc.c"
  if ((int )*s1 != 0) {
    {
# 192 "misc.c"
    tmp = strlen((char const *)s1);
# 192 "misc.c"
    len1 = (unsigned int )tmp;
    }
  } else {
# 192 "misc.c"
    len1 = 0U;
  }
# 193 "misc.c"
  if ((int )*s2 != 0) {
    {
# 193 "misc.c"
    tmp___0 = strlen((char const *)s2);
# 193 "misc.c"
    len2 = (unsigned int )tmp___0;
    }
  } else {
# 193 "misc.c"
    len2 = 0U;
  }
# 194 "misc.c"
  if ((int )*s3 != 0) {
    {
# 194 "misc.c"
    tmp___1 = strlen((char const *)s3);
# 194 "misc.c"
    len3 = (unsigned int )tmp___1;
    }
  } else {
# 194 "misc.c"
    len3 = 0U;
  }
  {
# 196 "misc.c"
  tmp___2 = xmalloc(((len1 + len2) + len3) + 1U);
# 196 "misc.c"
  result___0 = tmp___2;
  }
# 198 "misc.c"
  if ((int )*s1 != 0) {
    {
# 199 "misc.c"
    memmove((void *)result___0, (void const *)s1, (size_t )len1);
    }
  }
# 200 "misc.c"
  if ((int )*s2 != 0) {
    {
# 201 "misc.c"
    memmove((void *)(result___0 + len1), (void const *)s2, (size_t )len2);
    }
  }
# 202 "misc.c"
  if ((int )*s3 != 0) {
    {
# 203 "misc.c"
    memmove((void *)((result___0 + len1) + len2), (void const *)s3, (size_t )len3);
    }
  }
# 204 "misc.c"
  *(((result___0 + len1) + len2) + len3) = (char )'\000';
# 206 "misc.c"
  return (result___0);
}
}
# 211 "misc.c"
void message(int prefix , char const *fmt , ...)
{
  va_list args ;

  {
  {
# 225 "misc.c"
  log_working_directory(1);
  }
# 227 "misc.c"
  if ((unsigned long )fmt != (unsigned long )((char const *)0)) {
# 229 "misc.c"
    if (prefix) {
# 231 "misc.c"
      if (makelevel == 0U) {
        {
# 232 "misc.c"
        printf((char const * __restrict )"%s: ", program);
        }
      } else {
        {
# 234 "misc.c"
        printf((char const * __restrict )"%s[%u]: ", program, makelevel);
        }
      }
    }
    {
# 236 "misc.c"
    __builtin_va_start(args, fmt);
# 237 "misc.c"
    vfprintf((FILE * __restrict )stdout, (char const * __restrict )fmt, args);
# 238 "misc.c"
    __builtin_va_end(args);
# 239 "misc.c"
    putchar('\n');
    }
  }
  {
# 242 "misc.c"
  fflush(stdout);
  }
# 243 "misc.c"
  return;
}
}
# 247 "misc.c"
void error(struct floc const *flocp , char const *fmt , ...)
{
  va_list args ;

  {
  {
# 261 "misc.c"
  log_working_directory(1);
  }
# 263 "misc.c"
  if (flocp) {
# 263 "misc.c"
    if (flocp->filenm) {
      {
# 264 "misc.c"
      fprintf((FILE * __restrict )stderr, (char const * __restrict )"%s:%lu: ",
              flocp->filenm, flocp->lineno);
      }
    } else {
# 263 "misc.c"
      goto _L;
    }
  } else
  _L:
# 265 "misc.c"
  if (makelevel == 0U) {
    {
# 266 "misc.c"
    fprintf((FILE * __restrict )stderr, (char const * __restrict )"%s: ", program);
    }
  } else {
    {
# 268 "misc.c"
    fprintf((FILE * __restrict )stderr, (char const * __restrict )"%s[%u]: ",
            program, makelevel);
    }
  }
  {
# 270 "misc.c"
  __builtin_va_start(args, fmt);
# 271 "misc.c"
  vfprintf((FILE * __restrict )stderr, (char const * __restrict )fmt, args);
# 272 "misc.c"
  __builtin_va_end(args);
# 274 "misc.c"
  _IO_putc('\n', stderr);
# 275 "misc.c"
  fflush(stderr);
  }
# 276 "misc.c"
  return;
}
}
# 280 "misc.c"
 __attribute__((__noreturn__)) void fatal(struct floc const *flocp , char const *fmt
                                          , ...) ;
# 280 "misc.c"
void fatal(struct floc const *flocp , char const *fmt , ...)
{
  va_list args ;
  char *tmp ;

  {
  {
# 294 "misc.c"
  log_working_directory(1);
  }
# 296 "misc.c"
  if (flocp) {
# 296 "misc.c"
    if (flocp->filenm) {
      {
# 297 "misc.c"
      fprintf((FILE * __restrict )stderr, (char const * __restrict )"%s:%lu: *** ",
              flocp->filenm, flocp->lineno);
      }
    } else {
# 296 "misc.c"
      goto _L;
    }
  } else
  _L:
# 298 "misc.c"
  if (makelevel == 0U) {
    {
# 299 "misc.c"
    fprintf((FILE * __restrict )stderr, (char const * __restrict )"%s: *** ",
            program);
    }
  } else {
    {
# 301 "misc.c"
    fprintf((FILE * __restrict )stderr, (char const * __restrict )"%s[%u]: *** ",
            program, makelevel);
    }
  }
  {
# 303 "misc.c"
  __builtin_va_start(args, fmt);
# 304 "misc.c"
  vfprintf((FILE * __restrict )stderr, (char const * __restrict )fmt, args);
# 305 "misc.c"
  __builtin_va_end(args);
# 307 "misc.c"
  tmp = dcgettext((char const *)((void *)0), ".  Stop.\n", 5);
# 307 "misc.c"
  fputs((char const * __restrict )tmp, (FILE * __restrict )stderr);
# 309 "misc.c"
  die(2);
  }
}
}
# 336 "misc.c"
void perror_with_name(char *str , char *name )
{
  int *tmp ;
  char *tmp___0 ;

  {
  {
# 340 "misc.c"
  tmp = __errno_location();
# 340 "misc.c"
  tmp___0 = strerror(*tmp);
# 340 "misc.c"
  error((struct floc const *)((struct floc *)0), "%s%s: %s", str, name, tmp___0);
  }
# 341 "misc.c"
  return;
}
}
# 345 "misc.c"
 __attribute__((__noreturn__)) void pfatal_with_name(char *name ) ;
# 345 "misc.c"
void pfatal_with_name(char *name )
{
  int *tmp ;
  char *tmp___0 ;

  {
  {
# 349 "misc.c"
  tmp = __errno_location();
# 349 "misc.c"
  tmp___0 = strerror(*tmp);
# 349 "misc.c"
  fatal((struct floc const *)((struct floc *)0), "%s: %s", name, tmp___0);
  }
}
}
# 363 "misc.c"
char *xmalloc(unsigned int size )
{
  char *result___0 ;
  void *tmp ;
  char *tmp___0 ;

  {
  {
# 367 "misc.c"
  tmp = malloc((size_t )size);
# 367 "misc.c"
  result___0 = (char *)tmp;
  }
# 368 "misc.c"
  if ((unsigned long )result___0 == (unsigned long )((char *)0)) {
    {
# 369 "misc.c"
    tmp___0 = dcgettext((char const *)((void *)0), "virtual memory exhausted", 5);
# 369 "misc.c"
    fatal((struct floc const *)((struct floc *)0), (char const *)tmp___0);
    }
  }
# 370 "misc.c"
  return (result___0);
}
}
# 374 "misc.c"
char *xrealloc(char *ptr , unsigned int size )
{
  char *result___0 ;
  void *tmp ;
  void *tmp___0 ;
  char *tmp___1 ;

  {
# 382 "misc.c"
  if (ptr) {
    {
# 382 "misc.c"
    tmp = realloc((void *)ptr, (size_t )size);
# 382 "misc.c"
    result___0 = (char *)tmp;
    }
  } else {
    {
# 382 "misc.c"
    tmp___0 = malloc((size_t )size);
# 382 "misc.c"
    result___0 = (char *)tmp___0;
    }
  }
# 383 "misc.c"
  if ((unsigned long )result___0 == (unsigned long )((char *)0)) {
    {
# 384 "misc.c"
    tmp___1 = dcgettext((char const *)((void *)0), "virtual memory exhausted", 5);
# 384 "misc.c"
    fatal((struct floc const *)((struct floc *)0), (char const *)tmp___1);
    }
  }
# 385 "misc.c"
  return (result___0);
}
}
# 389 "misc.c"
char *xstrdup(char const *ptr )
{
  char *result___0 ;
  char *tmp ;

  {
  {
# 396 "misc.c"
  result___0 = strdup(ptr);
  }
# 401 "misc.c"
  if ((unsigned long )result___0 == (unsigned long )((char *)0)) {
    {
# 402 "misc.c"
    tmp = dcgettext((char const *)((void *)0), "virtual memory exhausted", 5);
# 402 "misc.c"
    fatal((struct floc const *)((struct floc *)0), (char const *)tmp);
    }
  }
# 405 "misc.c"
  return (result___0);
}
}
# 413 "misc.c"
char *savestring(char const *str , unsigned int length___0 )
{
  register char *out ;
  char *tmp ;

  {
  {
# 418 "misc.c"
  tmp = xmalloc(length___0 + 1U);
# 418 "misc.c"
  out = tmp;
  }
# 419 "misc.c"
  if (length___0 > 0U) {
    {
# 420 "misc.c"
    memmove((void *)out, (void const *)str, (size_t )length___0);
    }
  }
# 421 "misc.c"
  *(out + length___0) = (char )'\000';
# 422 "misc.c"
  return (out);
}
}
# 429 "misc.c"
char *sindex(char const *big , unsigned int blen , char const *small , unsigned int slen )
{
  size_t tmp ;
  size_t tmp___0 ;
  register unsigned int b ;
  int tmp___1 ;

  {
# 436 "misc.c"
  if (! blen) {
    {
# 437 "misc.c"
    tmp = strlen(big);
# 437 "misc.c"
    blen = (unsigned int )tmp;
    }
  }
# 438 "misc.c"
  if (! slen) {
    {
# 439 "misc.c"
    tmp___0 = strlen(small);
# 439 "misc.c"
    slen = (unsigned int )tmp___0;
    }
  }
# 441 "misc.c"
  if (slen) {
# 441 "misc.c"
    if (blen >= slen) {
# 446 "misc.c"
      slen --;
# 447 "misc.c"
      blen -= slen;
# 449 "misc.c"
      b = 0U;
      {
# 449 "misc.c"
      while (1) {
        while_continue: ;
# 449 "misc.c"
        if (! (b < blen)) {
# 449 "misc.c"
          goto while_break;
        }
# 450 "misc.c"
        if ((int const )*big == (int const )*small) {
          {
# 450 "misc.c"
          tmp___1 = strncmp(big + 1, small + 1, (size_t )slen);
          }
# 450 "misc.c"
          if (tmp___1 == 0) {
# 451 "misc.c"
            return ((char *)big);
          }
        }
# 449 "misc.c"
        b ++;
# 449 "misc.c"
        big ++;
      }
      while_break: ;
      }
    }
  }
# 454 "misc.c"
  return ((char *)0);
}
}
# 463 "misc.c"
char *lindex(char const *s , char const *limit , int c )
{
  char const *tmp ;

  {
  {
# 468 "misc.c"
  while (1) {
    while_continue: ;
# 468 "misc.c"
    if (! ((unsigned long )s < (unsigned long )limit)) {
# 468 "misc.c"
      goto while_break;
    }
# 469 "misc.c"
    tmp = s;
# 469 "misc.c"
    s ++;
# 469 "misc.c"
    if ((int const )*tmp == (int const )c) {
# 470 "misc.c"
      return ((char *)(s - 1));
    }
  }
  while_break: ;
  }
# 472 "misc.c"
  return ((char *)0);
}
}
# 477 "misc.c"
char *end_of_token(char *s )
{
  unsigned short const **tmp ;

  {
  {
# 481 "misc.c"
  while (1) {
    while_continue: ;
# 481 "misc.c"
    if ((int )*s != 0) {
      {
# 481 "misc.c"
      tmp = __ctype_b_loc();
      }
# 481 "misc.c"
      if ((int const )*(*tmp + (int )*s) & 1) {
# 481 "misc.c"
        goto while_break;
      }
    } else {
# 481 "misc.c"
      goto while_break;
    }
# 482 "misc.c"
    s ++;
  }
  while_break: ;
  }
# 483 "misc.c"
  return (s);
}
}
# 519 "misc.c"
char *next_token(char *s )
{
  register char *p ;
  unsigned short const **tmp ;

  {
# 523 "misc.c"
  p = s;
  {
# 525 "misc.c"
  while (1) {
    while_continue: ;
    {
# 525 "misc.c"
    tmp = __ctype_b_loc();
    }
# 525 "misc.c"
    if (! ((int const )*(*tmp + (int )*p) & 1)) {
# 525 "misc.c"
      goto while_break;
    }
# 526 "misc.c"
    p ++;
  }
  while_break: ;
  }
# 527 "misc.c"
  return (p);
}
}
# 533 "misc.c"
char *find_next_token(char **ptr , unsigned int *lengthptr )
{
  char *p ;
  char *tmp ;
  char *end ;

  {
  {
# 538 "misc.c"
  tmp = next_token(*ptr);
# 538 "misc.c"
  p = tmp;
  }
# 541 "misc.c"
  if ((int )*p == 0) {
# 542 "misc.c"
    return ((char *)0);
  }
  {
# 544 "misc.c"
  end = end_of_token(p);
# 544 "misc.c"
  *ptr = end;
  }
# 545 "misc.c"
  if ((unsigned long )lengthptr != (unsigned long )((unsigned int *)0)) {
# 546 "misc.c"
    *lengthptr = (unsigned int )(end - p);
  }
# 547 "misc.c"
  return (p);
}
}
# 553 "misc.c"
struct dep *copy_dep_chain(struct dep *d )
{
  register struct dep *c ;
  struct dep *firstnew ;
  struct dep *lastnew ;
  char *tmp ;
  struct dep *tmp___0 ;

  {
# 558 "misc.c"
  firstnew = (struct dep *)0;
# 559 "misc.c"
  lastnew = (struct dep *)0;
  {
# 561 "misc.c"
  while (1) {
    while_continue: ;
# 561 "misc.c"
    if (! ((unsigned long )d != (unsigned long )((struct dep *)0))) {
# 561 "misc.c"
      goto while_break;
    }
    {
# 563 "misc.c"
    tmp = xmalloc((unsigned int )sizeof(struct dep ));
# 563 "misc.c"
    c = (struct dep *)tmp;
# 564 "misc.c"
    memmove((void *)((char *)c), (void const *)((char *)d), sizeof(struct dep ));
    }
# 565 "misc.c"
    if ((unsigned long )c->name != (unsigned long )((char *)0)) {
      {
# 566 "misc.c"
      c->name = xstrdup((char const *)c->name);
      }
    }
# 567 "misc.c"
    c->next = (struct dep *)0;
# 568 "misc.c"
    if ((unsigned long )firstnew == (unsigned long )((struct dep *)0)) {
# 569 "misc.c"
      lastnew = c;
# 569 "misc.c"
      firstnew = lastnew;
    } else {
# 571 "misc.c"
      tmp___0 = c;
# 571 "misc.c"
      lastnew->next = tmp___0;
# 571 "misc.c"
      lastnew = tmp___0;
    }
# 573 "misc.c"
    d = d->next;
  }
  while_break: ;
  }
# 576 "misc.c"
  return (firstnew);
}
}
# 635 "misc.c"
static int user_uid = -1;
# 635 "misc.c"
static int user_gid = -1;
# 635 "misc.c"
static int make_uid = -1;
# 635 "misc.c"
static int make_gid = -1;
# 637 "misc.c"
static enum __anonenum_current_access_55 current_access ;
# 642 "misc.c"
static void log_access(char *flavor )
{
  __gid_t tmp ;
  __gid_t tmp___0 ;
  __uid_t tmp___1 ;
  __uid_t tmp___2 ;
  char *tmp___3 ;

  {
# 646 "misc.c"
  if (! (4 & db_level)) {
# 647 "misc.c"
    return;
  }
  {
# 653 "misc.c"
  tmp = getgid();
# 653 "misc.c"
  tmp___0 = getegid();
# 653 "misc.c"
  tmp___1 = getuid();
# 653 "misc.c"
  tmp___2 = geteuid();
# 653 "misc.c"
  tmp___3 = dcgettext((char const *)((void *)0), "%s access: user %lu (real %lu), group %lu (real %lu)\n",
                      5);
# 653 "misc.c"
  fprintf((FILE * __restrict )stderr, (char const * __restrict )tmp___3, flavor,
          (unsigned long )tmp___2, (unsigned long )tmp___1, (unsigned long )tmp___0,
          (unsigned long )tmp);
# 656 "misc.c"
  fflush(stderr);
  }
# 657 "misc.c"
  return;
}
}
# 660 "misc.c"
static void init_access(void)
{
  __uid_t tmp ;
  __gid_t tmp___0 ;
  __uid_t tmp___1 ;
  __gid_t tmp___2 ;
  char *tmp___3 ;

  {
  {
# 664 "misc.c"
  tmp = getuid();
# 664 "misc.c"
  user_uid = (int )tmp;
# 665 "misc.c"
  tmp___0 = getgid();
# 665 "misc.c"
  user_gid = (int )tmp___0;
# 667 "misc.c"
  tmp___1 = geteuid();
# 667 "misc.c"
  make_uid = (int )tmp___1;
# 668 "misc.c"
  tmp___2 = getegid();
# 668 "misc.c"
  make_gid = (int )tmp___2;
  }
# 671 "misc.c"
  if (user_uid == -1) {
    {
# 672 "misc.c"
    pfatal_with_name((char *)"get{e}[gu]id");
    }
  } else
# 671 "misc.c"
  if (user_gid == -1) {
    {
# 672 "misc.c"
    pfatal_with_name((char *)"get{e}[gu]id");
    }
  } else
# 671 "misc.c"
  if (make_uid == -1) {
    {
# 672 "misc.c"
    pfatal_with_name((char *)"get{e}[gu]id");
    }
  } else
# 671 "misc.c"
  if (make_gid == -1) {
    {
# 672 "misc.c"
    pfatal_with_name((char *)"get{e}[gu]id");
    }
  }
  {
# 674 "misc.c"
  tmp___3 = dcgettext((char const *)((void *)0), "Initialized", 5);
# 674 "misc.c"
  log_access(tmp___3);
# 676 "misc.c"
  current_access = (enum __anonenum_current_access_55 )0;
  }
# 678 "misc.c"
  return;
}
}
# 684 "misc.c"
void user_access(void)
{
  int tmp ;
  int tmp___0 ;

  {
# 689 "misc.c"
  if (! (user_uid != -1)) {
    {
# 690 "misc.c"
    init_access();
    }
  }
# 692 "misc.c"
  if ((unsigned int )current_access == 1U) {
# 693 "misc.c"
    return;
  }
  {
# 705 "misc.c"
  tmp = seteuid((__uid_t )user_uid);
  }
# 705 "misc.c"
  if (tmp < 0) {
    {
# 706 "misc.c"
    pfatal_with_name((char *)"user_access: seteuid");
    }
  }
  {
# 739 "misc.c"
  tmp___0 = setegid((__gid_t )user_gid);
  }
# 739 "misc.c"
  if (tmp___0 < 0) {
    {
# 740 "misc.c"
    pfatal_with_name((char *)"user_access: setegid");
    }
  }
  {
# 751 "misc.c"
  current_access = (enum __anonenum_current_access_55 )1;
# 753 "misc.c"
  log_access((char *)"User");
  }
# 756 "misc.c"
  return;
}
}
# 760 "misc.c"
void make_access(void)
{
  int tmp ;
  int tmp___0 ;

  {
# 765 "misc.c"
  if (! (user_uid != -1)) {
    {
# 766 "misc.c"
    init_access();
    }
  }
# 768 "misc.c"
  if ((unsigned int )current_access == 0U) {
# 769 "misc.c"
    return;
  }
  {
# 774 "misc.c"
  tmp = seteuid((__uid_t )make_uid);
  }
# 774 "misc.c"
  if (tmp < 0) {
    {
# 775 "misc.c"
    pfatal_with_name((char *)"make_access: seteuid");
    }
  }
  {
# 787 "misc.c"
  tmp___0 = setegid((__gid_t )make_gid);
  }
# 787 "misc.c"
  if (tmp___0 < 0) {
    {
# 788 "misc.c"
    pfatal_with_name((char *)"make_access: setegid");
    }
  }
  {
# 799 "misc.c"
  current_access = (enum __anonenum_current_access_55 )0;
# 801 "misc.c"
  log_access((char *)"Make");
  }
# 804 "misc.c"
  return;
}
}
# 808 "misc.c"
void child_access(void)
{
  int tmp ;
  int tmp___0 ;

  {
# 813 "misc.c"
  if (! (user_uid != -1)) {
    {
# 814 "misc.c"
    abort();
    }
  }
  {
# 820 "misc.c"
  tmp = setuid((__uid_t )user_uid);
  }
# 820 "misc.c"
  if (tmp < 0) {
    {
# 821 "misc.c"
    pfatal_with_name((char *)"child_access: setuid");
    }
  }
  {
# 828 "misc.c"
  tmp___0 = setgid((__gid_t )user_gid);
  }
# 828 "misc.c"
  if (tmp___0 < 0) {
    {
# 829 "misc.c"
    pfatal_with_name((char *)"child_access: setgid");
    }
  }
  {
# 835 "misc.c"
  log_access((char *)"Child");
  }
# 838 "misc.c"
  return;
}
}
# 1 "read.o"
#pragma merger("0","/tmp/cil-EmMgOVB_.i","-g,-O0")
# 232 "/usr/include/stdio.h"
extern FILE *fopen(char const * __restrict __filename , char const * __restrict __modes ) ;
# 564 "/usr/include/stdio.h"
extern char *fgets(char * __restrict __s , int __n , FILE * __restrict __stream ) ;
# 761 "/usr/include/stdio.h"
extern __attribute__((__nothrow__)) int ( __attribute__((__leaf__)) ferror)(FILE *__stream ) ;
# 851 "/usr/include/unistd.h"
extern char *getlogin(void) ;
# 431 "make.h"
void construct_vpath_list(char *pattern , char *dirpath ) ;
# 177 "./glob/glob.h"
extern int glob(char const *__pattern , int __flags , int (*__errfunc)(char const * ,
                                                                         int ) ,
                glob_t *__pglob ) ;
# 182 "./glob/glob.h"
extern void globfree(glob_t *__pglob ) ;
# 105 "filedef.h"
struct file *suffix_file ;
# 64 "rule.h"
struct pattern_var *create_pattern_var(char *target , char *suffix ) ;
# 68 "rule.h"
void create_pattern_rule(char **targets , char **target_percents , int terminal ,
                         struct dep *deps , struct commands *commands , int override ) ;
# 115 "/usr/include/pwd.h"
extern struct passwd *( __attribute__((__nonnull__(1))) getpwnam)(char const *__name ) ;
# 86 "read.c"
static struct conditionals toplevel_conditionals ;
# 87 "read.c"
static struct conditionals *conditionals = & toplevel_conditionals;
# 92 "read.c"
static char *default_include_directories[5] = { (char *)"/usr/local/include", (char *)"/usr/gnu/include", (char *)"/usr/local/include", (char *)"/usr/include",
        (char *)0};
# 112 "read.c"
static char **include_directories___0 ;
# 116 "read.c"
static unsigned int max_incl_len ;
# 125 "read.c"
static struct dep *read_makefiles = (struct dep *)0;
# 127 "read.c"
static int read_makefile(char *filename , int flags ) ;
# 128 "read.c"
static unsigned long readline(struct linebuffer *linebuffer , FILE *stream , struct floc const *flocp ) ;
# 130 "read.c"
static void do_define(char *name , unsigned int namelen , enum variable_origin origin ,
                      FILE *infile , struct floc *flocp ) ;
# 133 "read.c"
static int conditional_line(char *line , struct floc const *flocp ) ;
# 134 "read.c"
static void record_files(struct nameseq *filenames , char *pattern , char *pattern_percent ,
                         struct dep *deps , unsigned int cmds_started , char *commands ,
                         unsigned int commands_idx , int two_colon , struct floc const *flocp ,
                         int set_default ) ;
# 138 "read.c"
static void record_target_var(struct nameseq *filenames , char *defn , int two_colon ,
                              enum variable_origin origin , struct floc const *flocp ) ;
# 142 "read.c"
static enum make_word_type get_next_mword(char *buffer , char *delim , char **startp ,
                                          unsigned int *length___0 ) ;
# 217 "read.c"
static char *default_makefiles[4] = { (char *)"GNUmakefile", (char *)"makefile", (char *)"Makefile", (char *)0};
# 147 "read.c"
struct dep *read_all_makefiles(char **makefiles___0 )
{
  unsigned int num_makefiles ;
  char *tmp ;
  char *value ;
  char *name ;
  char *p ;
  unsigned int length___0 ;
  int save ;
  char *tmp___0 ;
  int tmp___1 ;
  struct dep *tail ;
  register struct dep *d ;
  int tmp___2 ;
  register char **p___0 ;
  int tmp___3 ;
  int tmp___4 ;
  struct dep *tail___0 ;
  struct dep *d___0 ;
  char *tmp___5 ;

  {
# 151 "read.c"
  num_makefiles = 0U;
  {
# 153 "read.c"
  while (1) {
    while_continue: ;
# 153 "read.c"
    if (1 & db_level) {
      {
# 153 "read.c"
      tmp = dcgettext((char const *)((void *)0), "Reading makefiles...\n", 5);
# 153 "read.c"
      printf((char const * __restrict )tmp);
# 153 "read.c"
      fflush(stdout);
      }
    }
# 153 "read.c"
    goto while_break;
  }
  while_break: ;
  }
  {
# 166 "read.c"
  save = warn_undefined_variables_flag;
# 167 "read.c"
  warn_undefined_variables_flag = 0;
# 169 "read.c"
  value = allocated_variable_expand_for_file((char *)"$(MAKEFILES)", (struct file *)0);
# 171 "read.c"
  warn_undefined_variables_flag = save;
# 176 "read.c"
  p = value;
  }
  {
# 178 "read.c"
  while (1) {
    while_continue___0: ;
    {
# 178 "read.c"
    name = find_next_token(& p, & length___0);
    }
# 178 "read.c"
    if (! ((unsigned long )name != (unsigned long )((char *)0))) {
# 178 "read.c"
      goto while_break___0;
    }
# 180 "read.c"
    if ((int )*p != 0) {
# 181 "read.c"
      tmp___0 = p;
# 181 "read.c"
      p ++;
# 181 "read.c"
      *tmp___0 = (char )'\000';
    }
    {
# 182 "read.c"
    name = xstrdup((char const *)name);
# 183 "read.c"
    tmp___1 = read_makefile(name, (1 | (1 << 1)) | (1 << 2));
    }
# 183 "read.c"
    if (tmp___1 < 2) {
      {
# 185 "read.c"
      free((void *)name);
      }
    }
  }
  while_break___0: ;
  }
  {
# 188 "read.c"
  free((void *)value);
  }
# 193 "read.c"
  if ((unsigned long )makefiles___0 != (unsigned long )((char **)0)) {
    {
# 194 "read.c"
    while (1) {
      while_continue___1: ;
# 194 "read.c"
      if (! ((unsigned long )*makefiles___0 != (unsigned long )((char *)0))) {
# 194 "read.c"
        goto while_break___1;
      }
      {
# 196 "read.c"
      tail = read_makefiles;
# 199 "read.c"
      tmp___2 = read_makefile(*makefiles___0, 0);
      }
# 199 "read.c"
      if (! tmp___2) {
        {
# 200 "read.c"
        perror_with_name((char *)"", *makefiles___0);
        }
      }
# 203 "read.c"
      d = read_makefiles;
      {
# 204 "read.c"
      while (1) {
        while_continue___2: ;
# 204 "read.c"
        if (! ((unsigned long )d->next != (unsigned long )tail)) {
# 204 "read.c"
          goto while_break___2;
        }
# 205 "read.c"
        d = d->next;
      }
      while_break___2: ;
      }
# 208 "read.c"
      if ((unsigned long )d->name == (unsigned long )((char *)0)) {
# 208 "read.c"
        *makefiles___0 = (d->file)->name;
      } else {
# 208 "read.c"
        *makefiles___0 = d->name;
      }
# 209 "read.c"
      num_makefiles ++;
# 210 "read.c"
      makefiles___0 ++;
    }
    while_break___1: ;
    }
  }
# 215 "read.c"
  if (num_makefiles == 0U) {
# 228 "read.c"
    p___0 = default_makefiles;
    {
# 229 "read.c"
    while (1) {
      while_continue___3: ;
# 229 "read.c"
      if ((unsigned long )*p___0 != (unsigned long )((char *)0)) {
        {
# 229 "read.c"
        tmp___3 = file_exists_p(*p___0);
        }
# 229 "read.c"
        if (tmp___3) {
# 229 "read.c"
          goto while_break___3;
        }
      } else {
# 229 "read.c"
        goto while_break___3;
      }
# 230 "read.c"
      p___0 ++;
    }
    while_break___3: ;
    }
# 232 "read.c"
    if ((unsigned long )*p___0 != (unsigned long )((char *)0)) {
      {
# 234 "read.c"
      tmp___4 = read_makefile(*p___0, 0);
      }
# 234 "read.c"
      if (! tmp___4) {
        {
# 235 "read.c"
        perror_with_name((char *)"", *p___0);
        }
      }
    } else {
# 241 "read.c"
      tail___0 = read_makefiles;
      {
# 243 "read.c"
      while (1) {
        while_continue___4: ;
# 243 "read.c"
        if ((unsigned long )tail___0 != (unsigned long )((struct dep *)0)) {
# 243 "read.c"
          if (! ((unsigned long )tail___0->next != (unsigned long )((struct dep *)0))) {
# 243 "read.c"
            goto while_break___4;
          }
        } else {
# 243 "read.c"
          goto while_break___4;
        }
# 244 "read.c"
        tail___0 = tail___0->next;
      }
      while_break___4: ;
      }
# 245 "read.c"
      p___0 = default_makefiles;
      {
# 245 "read.c"
      while (1) {
        while_continue___5: ;
# 245 "read.c"
        if (! ((unsigned long )*p___0 != (unsigned long )((char *)0))) {
# 245 "read.c"
          goto while_break___5;
        }
        {
# 247 "read.c"
        tmp___5 = xmalloc((unsigned int )sizeof(struct dep ));
# 247 "read.c"
        d___0 = (struct dep *)tmp___5;
# 248 "read.c"
        d___0->name = (char *)0;
# 249 "read.c"
        d___0->file = enter_file(*p___0);
# 250 "read.c"
        (d___0->file)->dontcare = 1U;
# 253 "read.c"
        d___0->changed = 1 << 2;
        }
# 254 "read.c"
        if ((unsigned long )tail___0 == (unsigned long )((struct dep *)0)) {
# 255 "read.c"
          read_makefiles = d___0;
        } else {
# 257 "read.c"
          tail___0->next = d___0;
        }
# 258 "read.c"
        tail___0 = d___0;
# 245 "read.c"
        p___0 ++;
      }
      while_break___5: ;
      }
# 260 "read.c"
      if ((unsigned long )tail___0 != (unsigned long )((struct dep *)0)) {
# 261 "read.c"
        tail___0->next = (struct dep *)0;
      }
    }
  }
# 265 "read.c"
  return (read_makefiles);
}
}
# 283 "read.c"
static char *collapsed = (char *)0;
# 284 "read.c"
static unsigned int collapsed_length = 0U;
# 278 "read.c"
static int read_makefile(char *filename , int flags )
{
  register FILE *infile ;
  struct linebuffer lb ;
  unsigned int commands_len ;
  char *commands ;
  unsigned int commands_idx ;
  unsigned int cmds_started ;
  unsigned int tgts_started ;
  char *p ;
  char *p2 ;
  int len ;
  int reading_target ;
  int ignoring ;
  int in_ignored_define ;
  int no_targets ;
  int using_filename ;
  struct floc fileinfo ;
  char *passed_filename ;
  struct nameseq *filenames ;
  struct dep *deps ;
  unsigned int nlines ;
  int two_colon ;
  char *pattern ;
  char *pattern_percent ;
  int makefile_errno ;
  char *tmp ;
  char *tmp___0 ;
  char *tmp___1 ;
  char *tmp___2 ;
  char *tmp___3 ;
  char *expanded ;
  char *tmp___4 ;
  int *tmp___5 ;
  register unsigned int i ;
  char *name ;
  char *tmp___6 ;
  char *tmp___7 ;
  char *tmp___8 ;
  int *tmp___9 ;
  char *tmp___10 ;
  unsigned long tmp___11 ;
  unsigned int len___0 ;
  size_t tmp___12 ;
  char *tmp___13 ;
  unsigned int tmp___14 ;
  char *tmp___15 ;
  unsigned short const **tmp___16 ;
  unsigned short const **tmp___17 ;
  unsigned short const **tmp___18 ;
  int i___0 ;
  int tmp___19 ;
  char *tmp___20 ;
  int tmp___21 ;
  int tmp___22 ;
  int tmp___23 ;
  int tmp___24 ;
  int tmp___25 ;
  int tmp___26 ;
  char *tmp___27 ;
  int tmp___28 ;
  char *tmp___29 ;
  unsigned short const **tmp___30 ;
  int tmp___31 ;
  char *tmp___32 ;
  char *tmp___33 ;
  unsigned short const **tmp___34 ;
  char *tmp___35 ;
  struct variable *tmp___36 ;
  int tmp___37 ;
  unsigned short const **tmp___38 ;
  int tmp___39 ;
  struct variable *v ;
  unsigned int len___1 ;
  unsigned int len___2 ;
  struct variable *v___0 ;
  char *pattern___0 ;
  unsigned int len___3 ;
  struct conditionals *save ;
  struct conditionals new_conditionals ;
  struct nameseq *files___0 ;
  int noerror ;
  int tmp___40 ;
  char *tmp___41 ;
  char const *tmp___42 ;
  char *tmp___43 ;
  struct nameseq *tmp___44 ;
  struct floc fi ;
  struct nameseq *next ;
  char *name___0 ;
  int r ;
  int tmp___45 ;
  int *tmp___46 ;
  char *tmp___47 ;
  unsigned short const **tmp___48 ;
  char *tmp___49 ;
  enum make_word_type wtype ;
  enum variable_origin v_origin ;
  char *cmdleft ;
  char *lb_next ;
  unsigned int len___4 ;
  unsigned int plen ;
  char *colonp ;
  struct floc fi___0 ;
  char *tmp___50 ;
  char *tmp___51 ;
  unsigned long p2_off ;
  unsigned long cmd_off ;
  char *pend ;
  size_t tmp___52 ;
  size_t tmp___53 ;
  size_t tmp___54 ;
  char *tmp___55 ;
  char *tmp___57 ;
  char const *tmp___58 ;
  int tmp___59 ;
  char *tmp___60 ;
  struct nameseq *tmp___61 ;
  unsigned int l ;
  size_t tmp___63 ;
  size_t tmp___64 ;
  int tmp___65 ;
  unsigned int l___0 ;
  char *tmp___66 ;
  register char *q ;
  register int backslash ;
  char *tmp___67 ;
  struct nameseq *target ;
  char *tmp___68 ;
  char *tmp___69 ;
  char *tmp___70 ;
  struct nameseq *tmp___71 ;
  struct nameseq *tmp___72 ;
  unsigned int len___5 ;
  size_t tmp___73 ;
  char *tmp___74 ;
  unsigned int tmp___75 ;
  struct variable *tmp___76 ;
  int tmp___77 ;
  int tmp___78 ;
  int tmp___79 ;
  int tmp___80 ;
  int tmp___81 ;
  int tmp___82 ;
  struct floc fi___1 ;
  int tmp___83 ;
  char *tmp___84 ;
  struct floc fi___2 ;

  {
# 287 "read.c"
  commands_len = 200U;
# 289 "read.c"
  commands_idx = 0U;
# 294 "read.c"
  ignoring = 0;
# 294 "read.c"
  in_ignored_define = 0;
# 295 "read.c"
  no_targets = 0;
# 296 "read.c"
  using_filename = 0;
# 298 "read.c"
  passed_filename = filename;
# 300 "read.c"
  filenames = (struct nameseq *)0;
# 302 "read.c"
  nlines = 0U;
# 303 "read.c"
  two_colon = 0;
# 304 "read.c"
  pattern = (char *)0;
# 329 "read.c"
  fileinfo.filenm = filename;
# 330 "read.c"
  fileinfo.lineno = 1UL;
# 332 "read.c"
  pattern_percent = (char *)0;
# 333 "read.c"
  tgts_started = (unsigned int )fileinfo.lineno;
# 333 "read.c"
  cmds_started = tgts_started;
# 335 "read.c"
  if (2 & db_level) {
    {
# 337 "read.c"
    tmp = dcgettext((char const *)((void *)0), "Reading makefile `%s\'", 5);
# 337 "read.c"
    printf((char const * __restrict )tmp, fileinfo.filenm);
    }
# 338 "read.c"
    if (flags & 1) {
      {
# 339 "read.c"
      tmp___0 = dcgettext((char const *)((void *)0), " (no default goal)", 5);
# 339 "read.c"
      printf((char const * __restrict )tmp___0);
      }
    }
# 340 "read.c"
    if (flags & (1 << 1)) {
      {
# 341 "read.c"
      tmp___1 = dcgettext((char const *)((void *)0), " (search path)", 5);
# 341 "read.c"
      printf((char const * __restrict )tmp___1);
      }
    }
# 342 "read.c"
    if (flags & (1 << 2)) {
      {
# 343 "read.c"
      tmp___2 = dcgettext((char const *)((void *)0), " (don\'t care)", 5);
# 343 "read.c"
      printf((char const * __restrict )tmp___2);
      }
    }
# 344 "read.c"
    if (flags & (1 << 3)) {
      {
# 345 "read.c"
      tmp___3 = dcgettext((char const *)((void *)0), " (no ~ expansion)", 5);
# 345 "read.c"
      printf((char const * __restrict )tmp___3);
      }
    }
    {
# 346 "read.c"
    puts("...");
    }
  }
# 353 "read.c"
  if (! (flags & (1 << 3))) {
# 353 "read.c"
    if ((int )*(filename + 0) == 126) {
      {
# 355 "read.c"
      tmp___4 = tilde_expand(filename);
# 355 "read.c"
      expanded = tmp___4;
      }
# 356 "read.c"
      if ((unsigned long )expanded != (unsigned long )((char *)0)) {
# 357 "read.c"
        filename = expanded;
      }
    }
  }
  {
# 360 "read.c"
  infile = fopen((char const * __restrict )filename, (char const * __restrict )"r");
# 362 "read.c"
  tmp___5 = __errno_location();
# 362 "read.c"
  makefile_errno = *tmp___5;
  }
# 367 "read.c"
  if ((unsigned long )infile == (unsigned long )((FILE *)0)) {
# 367 "read.c"
    if (flags & (1 << 1)) {
# 367 "read.c"
      if ((int )*filename != 47) {
# 370 "read.c"
        i = 0U;
        {
# 370 "read.c"
        while (1) {
          while_continue: ;
# 370 "read.c"
          if (! ((unsigned long )*(include_directories___0 + i) != (unsigned long )((char *)0))) {
# 370 "read.c"
            goto while_break;
          }
          {
# 372 "read.c"
          tmp___6 = concat(*(include_directories___0 + i), (char *)"/", filename);
# 372 "read.c"
          name = tmp___6;
# 373 "read.c"
          infile = fopen((char const * __restrict )name, (char const * __restrict )"r");
          }
# 374 "read.c"
          if ((unsigned long )infile == (unsigned long )((FILE *)0)) {
            {
# 375 "read.c"
            free((void *)name);
            }
          } else {
# 378 "read.c"
            filename = name;
# 379 "read.c"
            goto while_break;
          }
# 370 "read.c"
          i ++;
        }
        while_break: ;
        }
      }
    }
  }
  {
# 385 "read.c"
  tmp___7 = xmalloc((unsigned int )sizeof(struct dep ));
# 385 "read.c"
  deps = (struct dep *)tmp___7;
# 386 "read.c"
  deps->next = read_makefiles;
# 387 "read.c"
  read_makefiles = deps;
# 388 "read.c"
  deps->name = (char *)0;
# 389 "read.c"
  deps->file = lookup_file(filename);
  }
# 390 "read.c"
  if ((unsigned long )deps->file == (unsigned long )((struct file *)0)) {
    {
# 392 "read.c"
    tmp___8 = xstrdup((char const *)filename);
# 392 "read.c"
    deps->file = enter_file(tmp___8);
    }
# 393 "read.c"
    if (flags & (1 << 2)) {
# 394 "read.c"
      (deps->file)->dontcare = 1U;
    }
  }
# 396 "read.c"
  if ((unsigned long )filename != (unsigned long )passed_filename) {
    {
# 397 "read.c"
    free((void *)filename);
    }
  }
# 398 "read.c"
  filename = (deps->file)->name;
# 399 "read.c"
  deps->changed = flags;
# 400 "read.c"
  deps = (struct dep *)0;
# 404 "read.c"
  if ((unsigned long )infile == (unsigned long )((FILE *)0)) {
    {
# 409 "read.c"
    tmp___9 = __errno_location();
# 409 "read.c"
    *tmp___9 = makefile_errno;
    }
# 410 "read.c"
    return (0);
  }
  {
# 413 "read.c"
  reading_file = (struct floc const *)(& fileinfo);
# 420 "read.c"
  lb.size = 200U;
# 420 "read.c"
  tmp___10 = xmalloc(lb.size);
# 420 "read.c"
  lb.buffer = tmp___10;
# 421 "read.c"
  commands = xmalloc(200U);
  }
  {
# 423 "read.c"
  while (1) {
    while_continue___0: ;
    {
# 423 "read.c"
    tmp___83 = feof(infile);
    }
# 423 "read.c"
    if (tmp___83) {
# 423 "read.c"
      goto while_break___0;
    }
    {
# 425 "read.c"
    fileinfo.lineno += (unsigned long )nlines;
# 426 "read.c"
    tmp___11 = readline(& lb, infile, (struct floc const *)(& fileinfo));
# 426 "read.c"
    nlines = (unsigned int )tmp___11;
    }
# 430 "read.c"
    if ((int )*(lb.buffer + 0) == 9) {
# 435 "read.c"
      if (no_targets) {
# 437 "read.c"
        goto while_continue___0;
      }
# 443 "read.c"
      if ((unsigned long )filenames != (unsigned long )((struct nameseq *)0)) {
# 445 "read.c"
        if (ignoring) {
# 447 "read.c"
          goto while_continue___0;
        }
# 450 "read.c"
        p = lb.buffer;
# 451 "read.c"
        if (commands_idx == 0U) {
# 452 "read.c"
          cmds_started = (unsigned int )fileinfo.lineno;
        }
        {
# 453 "read.c"
        tmp___12 = strlen((char const *)p);
# 453 "read.c"
        len___0 = (unsigned int )tmp___12;
        }
# 454 "read.c"
        if ((len___0 + 1U) + commands_idx > commands_len) {
          {
# 456 "read.c"
          commands_len = ((len___0 + 1U) + commands_idx) * 2U;
# 457 "read.c"
          tmp___13 = xrealloc(commands, commands_len);
# 457 "read.c"
          commands = tmp___13;
          }
        }
        {
# 459 "read.c"
        memmove((void *)(commands + commands_idx), (void const *)p, (size_t )len___0);
# 460 "read.c"
        commands_idx += len___0;
# 461 "read.c"
        tmp___14 = commands_idx;
# 461 "read.c"
        commands_idx ++;
# 461 "read.c"
        *(commands + tmp___14) = (char )'\n';
        }
# 463 "read.c"
        goto while_continue___0;
      }
    }
# 469 "read.c"
    if (collapsed_length < lb.size) {
# 471 "read.c"
      collapsed_length = lb.size;
# 472 "read.c"
      if ((unsigned long )collapsed != (unsigned long )((char *)0)) {
        {
# 473 "read.c"
        free((void *)collapsed);
        }
      }
      {
# 474 "read.c"
      tmp___15 = xmalloc(collapsed_length);
# 474 "read.c"
      collapsed = tmp___15;
      }
    }
    {
# 476 "read.c"
    strcpy((char * __restrict )collapsed, (char const * __restrict )lb.buffer);
# 478 "read.c"
    collapse_continuations(collapsed);
# 479 "read.c"
    remove_comments(collapsed);
# 483 "read.c"
    p = collapsed;
    }
    {
# 484 "read.c"
    while (1) {
      while_continue___1: ;
      {
# 484 "read.c"
      tmp___16 = __ctype_b_loc();
      }
# 484 "read.c"
      if (! ((int const )*(*tmp___16 + (int )((unsigned char )*p)) & 8192)) {
# 484 "read.c"
        goto while_break___1;
      }
# 485 "read.c"
      p ++;
    }
    while_break___1: ;
    }
# 486 "read.c"
    if ((int )*p == 0) {
# 488 "read.c"
      goto while_continue___0;
    }
# 494 "read.c"
    p2 = p + 1;
    {
# 494 "read.c"
    while (1) {
      while_continue___2: ;
# 494 "read.c"
      if ((int )*p2 != 0) {
        {
# 494 "read.c"
        tmp___17 = __ctype_b_loc();
        }
# 494 "read.c"
        if ((int const )*(*tmp___17 + (int )((unsigned char )*p2)) & 8192) {
# 494 "read.c"
          goto while_break___2;
        }
      } else {
# 494 "read.c"
        goto while_break___2;
      }
# 494 "read.c"
      p2 ++;
    }
    while_break___2: ;
    }
# 496 "read.c"
    len = (int )(p2 - p);
# 501 "read.c"
    reading_target = 0;
    {
# 502 "read.c"
    while (1) {
      while_continue___3: ;
      {
# 502 "read.c"
      tmp___18 = __ctype_b_loc();
      }
# 502 "read.c"
      if (! ((int const )*(*tmp___18 + (int )((unsigned char )*p2)) & 8192)) {
# 502 "read.c"
        goto while_break___3;
      }
# 503 "read.c"
      p2 ++;
    }
    while_break___3: ;
    }
# 504 "read.c"
    if ((int )*p2 == 0) {
# 505 "read.c"
      p2 = (char *)((void *)0);
    } else
# 506 "read.c"
    if ((int )*(p2 + 0) == 58) {
# 506 "read.c"
      if ((int )*(p2 + 1) == 0) {
# 508 "read.c"
        reading_target = 1;
# 509 "read.c"
        goto skip_conditionals;
      }
    }
# 516 "read.c"
    if (! in_ignored_define) {
# 516 "read.c"
      if (len == 5) {
        {
# 516 "read.c"
        tmp___21 = strncmp("ifdef", (char const *)p, (size_t )5);
        }
# 516 "read.c"
        if (tmp___21 == 0) {
# 516 "read.c"
          goto _L;
        } else {
# 516 "read.c"
          goto _L___4;
        }
      } else
      _L___4:
# 516 "read.c"
      if (len == 6) {
        {
# 516 "read.c"
        tmp___22 = strncmp("ifndef", (char const *)p, (size_t )6);
        }
# 516 "read.c"
        if (tmp___22 == 0) {
# 516 "read.c"
          goto _L;
        } else {
# 516 "read.c"
          goto _L___3;
        }
      } else
      _L___3:
# 516 "read.c"
      if (len == 4) {
        {
# 516 "read.c"
        tmp___23 = strncmp("ifeq", (char const *)p, (size_t )4);
        }
# 516 "read.c"
        if (tmp___23 == 0) {
# 516 "read.c"
          goto _L;
        } else {
# 516 "read.c"
          goto _L___2;
        }
      } else
      _L___2:
# 516 "read.c"
      if (len == 5) {
        {
# 516 "read.c"
        tmp___24 = strncmp("ifneq", (char const *)p, (size_t )5);
        }
# 516 "read.c"
        if (tmp___24 == 0) {
# 516 "read.c"
          goto _L;
        } else {
# 516 "read.c"
          goto _L___1;
        }
      } else
      _L___1:
# 516 "read.c"
      if (len == 4) {
        {
# 516 "read.c"
        tmp___25 = strncmp("else", (char const *)p, (size_t )4);
        }
# 516 "read.c"
        if (tmp___25 == 0) {
# 516 "read.c"
          goto _L;
        } else {
# 516 "read.c"
          goto _L___0;
        }
      } else
      _L___0:
# 516 "read.c"
      if (len == 5) {
        {
# 516 "read.c"
        tmp___26 = strncmp("endif", (char const *)p, (size_t )5);
        }
# 516 "read.c"
        if (tmp___26 == 0) {
          _L:
          {
# 521 "read.c"
          tmp___19 = conditional_line(p, (struct floc const *)(& fileinfo));
# 521 "read.c"
          i___0 = tmp___19;
          }
# 522 "read.c"
          if (i___0 >= 0) {
# 523 "read.c"
            ignoring = i___0;
          } else {
            {
# 525 "read.c"
            tmp___20 = dcgettext((char const *)((void *)0), "invalid syntax in conditional",
                                 5);
# 525 "read.c"
            fatal((struct floc const *)(& fileinfo), (char const *)tmp___20);
            }
          }
# 526 "read.c"
          goto while_continue___0;
        }
      }
    }
# 529 "read.c"
    if (len == 5) {
      {
# 529 "read.c"
      tmp___28 = strncmp("endef", (char const *)p, (size_t )5);
      }
# 529 "read.c"
      if (tmp___28 == 0) {
# 531 "read.c"
        if (in_ignored_define) {
# 532 "read.c"
          in_ignored_define = 0;
        } else {
          {
# 534 "read.c"
          tmp___27 = dcgettext((char const *)((void *)0), "extraneous `endef\'",
                               5);
# 534 "read.c"
          fatal((struct floc const *)(& fileinfo), (char const *)tmp___27);
          }
        }
# 535 "read.c"
        goto while_continue___0;
      }
    }
# 538 "read.c"
    if (len == 6) {
      {
# 538 "read.c"
      tmp___31 = strncmp("define", (char const *)p, (size_t )6);
      }
# 538 "read.c"
      if (tmp___31 == 0) {
# 540 "read.c"
        if (ignoring) {
# 541 "read.c"
          in_ignored_define = 1;
        } else {
          {
# 544 "read.c"
          p2 = next_token(p + 6);
          }
# 545 "read.c"
          if ((int )*p2 == 0) {
            {
# 546 "read.c"
            tmp___29 = dcgettext((char const *)((void *)0), "empty variable name",
                                 5);
# 546 "read.c"
            fatal((struct floc const *)(& fileinfo), (char const *)tmp___29);
            }
          }
          {
# 552 "read.c"
          p = strchr((char const *)p2, '\000');
          }
          {
# 553 "read.c"
          while (1) {
            while_continue___4: ;
            {
# 553 "read.c"
            tmp___30 = __ctype_b_loc();
            }
# 553 "read.c"
            if (! ((int const )*(*tmp___30 + (int )*(p + -1)) & 1)) {
# 553 "read.c"
              goto while_break___4;
            }
# 554 "read.c"
            p --;
          }
          while_break___4: ;
          }
          {
# 555 "read.c"
          do_define(p2, (unsigned int )(p - p2), (enum variable_origin )2, infile,
                    & fileinfo);
          }
        }
# 557 "read.c"
        goto while_continue___0;
      }
    }
# 560 "read.c"
    if (len == 8) {
      {
# 560 "read.c"
      tmp___39 = strncmp("override", (char const *)p, (size_t )8);
      }
# 560 "read.c"
      if (tmp___39 == 0) {
        {
# 562 "read.c"
        p2 = next_token(p + 8);
        }
# 563 "read.c"
        if ((int )*p2 == 0) {
          {
# 564 "read.c"
          tmp___32 = dcgettext((char const *)((void *)0), "empty `override\' directive",
                               5);
# 564 "read.c"
          error((struct floc const *)(& fileinfo), (char const *)tmp___32);
          }
        }
        {
# 565 "read.c"
        tmp___37 = strncmp((char const *)p2, "define", (size_t )6);
        }
# 565 "read.c"
        if (tmp___37 == 0) {
          {
# 565 "read.c"
          tmp___38 = __ctype_b_loc();
          }
# 565 "read.c"
          if ((int const )*(*tmp___38 + (int )*(p2 + 6)) & 1) {
# 565 "read.c"
            goto _L___6;
          } else
# 565 "read.c"
          if ((int )*(p2 + 6) == 0) {
            _L___6:
# 567 "read.c"
            if (ignoring) {
# 568 "read.c"
              in_ignored_define = 1;
            } else {
              {
# 571 "read.c"
              p2 = next_token(p2 + 6);
              }
# 572 "read.c"
              if ((int )*p2 == 0) {
                {
# 573 "read.c"
                tmp___33 = dcgettext((char const *)((void *)0), "empty variable name",
                                     5);
# 573 "read.c"
                fatal((struct floc const *)(& fileinfo), (char const *)tmp___33);
                }
              }
              {
# 579 "read.c"
              p = strchr((char const *)p2, '\000');
              }
              {
# 580 "read.c"
              while (1) {
                while_continue___5: ;
                {
# 580 "read.c"
                tmp___34 = __ctype_b_loc();
                }
# 580 "read.c"
                if (! ((int const )*(*tmp___34 + (int )*(p + -1)) & 1)) {
# 580 "read.c"
                  goto while_break___5;
                }
# 581 "read.c"
                p --;
              }
              while_break___5: ;
              }
              {
# 582 "read.c"
              do_define(p2, (unsigned int )(p - p2), (enum variable_origin )5, infile,
                        & fileinfo);
              }
            }
          } else {
# 565 "read.c"
            goto _L___5;
          }
        } else
        _L___5:
# 585 "read.c"
        if (! ignoring) {
          {
# 585 "read.c"
          tmp___36 = try_variable_definition((struct floc const *)(& fileinfo),
                                             p2, (enum variable_origin )5, 0);
          }
# 585 "read.c"
          if (! tmp___36) {
            {
# 587 "read.c"
            tmp___35 = dcgettext((char const *)((void *)0), "invalid `override\' directive",
                                 5);
# 587 "read.c"
            error((struct floc const *)(& fileinfo), (char const *)tmp___35);
            }
          }
        }
# 589 "read.c"
        goto while_continue___0;
      }
    }
    skip_conditionals:
# 593 "read.c"
    if (ignoring) {
# 596 "read.c"
      goto while_continue___0;
    }
# 598 "read.c"
    if (! reading_target) {
# 598 "read.c"
      if (len == 6) {
        {
# 598 "read.c"
        tmp___82 = strncmp("export", (char const *)p, (size_t )6);
        }
# 598 "read.c"
        if (tmp___82 == 0) {
          {
# 601 "read.c"
          p2 = next_token(p + 6);
          }
# 602 "read.c"
          if ((int )*p2 == 0) {
# 603 "read.c"
            export_all_variables = 1;
          }
          {
# 604 "read.c"
          v = try_variable_definition((struct floc const *)(& fileinfo), p2, (enum variable_origin )2,
                                      0);
          }
# 605 "read.c"
          if ((unsigned long )v != (unsigned long )((struct variable *)0)) {
# 606 "read.c"
            v->export = (enum variable_export )0;
          } else {
            {
# 610 "read.c"
            p = find_next_token(& p2, & len___1);
            }
            {
# 610 "read.c"
            while (1) {
              while_continue___6: ;
# 610 "read.c"
              if (! ((unsigned long )p != (unsigned long )((char *)0))) {
# 610 "read.c"
                goto while_break___6;
              }
              {
# 613 "read.c"
              v = lookup_variable(p, len___1);
              }
# 614 "read.c"
              if ((unsigned long )v == (unsigned long )((struct variable *)0)) {
                {
# 615 "read.c"
                v = define_variable_in_set(p, len___1, (char *)"", (enum variable_origin )2,
                                           0, current_variable_set_list->set, (struct floc const *)(& fileinfo));
                }
              }
              {
# 616 "read.c"
              v->export = (enum variable_export )0;
# 610 "read.c"
              p = find_next_token(& p2, & len___1);
              }
            }
            while_break___6: ;
            }
          }
        } else {
# 598 "read.c"
          goto _L___14;
        }
      } else {
# 598 "read.c"
        goto _L___14;
      }
    } else
    _L___14:
# 620 "read.c"
    if (! reading_target) {
# 620 "read.c"
      if (len == 8) {
        {
# 620 "read.c"
        tmp___81 = strncmp("unexport", (char const *)p, (size_t )8);
        }
# 620 "read.c"
        if (tmp___81 == 0) {
          {
# 624 "read.c"
          p2 = next_token(p + 8);
          }
# 625 "read.c"
          if ((int )*p2 == 0) {
# 626 "read.c"
            export_all_variables = 0;
          }
          {
# 627 "read.c"
          p = find_next_token(& p2, & len___2);
          }
          {
# 627 "read.c"
          while (1) {
            while_continue___7: ;
# 627 "read.c"
            if (! ((unsigned long )p != (unsigned long )((char *)0))) {
# 627 "read.c"
              goto while_break___7;
            }
            {
# 630 "read.c"
            v___0 = lookup_variable(p, len___2);
            }
# 631 "read.c"
            if ((unsigned long )v___0 == (unsigned long )((struct variable *)0)) {
              {
# 632 "read.c"
              v___0 = define_variable_in_set(p, len___2, (char *)"", (enum variable_origin )2,
                                             0, current_variable_set_list->set, (struct floc const *)(& fileinfo));
              }
            }
            {
# 633 "read.c"
            v___0->export = (enum variable_export )1;
# 627 "read.c"
            p = find_next_token(& p2, & len___2);
            }
          }
          while_break___7: ;
          }
        } else {
# 620 "read.c"
          goto _L___13;
        }
      } else {
# 620 "read.c"
        goto _L___13;
      }
    } else
    _L___13:
# 636 "read.c"
    if (len == 5) {
      {
# 636 "read.c"
      tmp___80 = strncmp("vpath", (char const *)p, (size_t )5);
      }
# 636 "read.c"
      if (tmp___80 == 0) {
        {
# 640 "read.c"
        p2 = variable_expand(p + 5);
# 641 "read.c"
        p = find_next_token(& p2, & len___3);
        }
# 642 "read.c"
        if ((unsigned long )p != (unsigned long )((char *)0)) {
          {
# 644 "read.c"
          pattern___0 = savestring((char const *)p, len___3);
# 645 "read.c"
          p = find_next_token(& p2, & len___3);
          }
        } else {
# 651 "read.c"
          pattern___0 = (char *)0;
        }
        {
# 652 "read.c"
        construct_vpath_list(pattern___0, p);
        }
# 653 "read.c"
        if ((unsigned long )pattern___0 != (unsigned long )((char *)0)) {
          {
# 654 "read.c"
          free((void *)pattern___0);
          }
        }
      } else {
# 636 "read.c"
        goto _L___12;
      }
    } else
    _L___12:
# 656 "read.c"
    if (len == 7) {
      {
# 656 "read.c"
      tmp___77 = strncmp("include", (char const *)p, (size_t )7);
      }
# 656 "read.c"
      if (tmp___77 == 0) {
# 656 "read.c"
        goto _L___8;
      } else {
# 656 "read.c"
        goto _L___11;
      }
    } else
    _L___11:
# 656 "read.c"
    if (len == 8) {
      {
# 656 "read.c"
      tmp___78 = strncmp("-include", (char const *)p, (size_t )8);
      }
# 656 "read.c"
      if (tmp___78 == 0) {
# 656 "read.c"
        goto _L___8;
      } else {
# 656 "read.c"
        goto _L___10;
      }
    } else
    _L___10:
# 656 "read.c"
    if (len == 8) {
      {
# 656 "read.c"
      tmp___79 = strncmp("sinclude", (char const *)p, (size_t )8);
      }
# 656 "read.c"
      if (tmp___79 == 0) {
        _L___8:
# 665 "read.c"
        noerror = (int )*(p + 0) != 105;
# 667 "read.c"
        if (noerror) {
# 667 "read.c"
          tmp___40 = 8;
        } else {
# 667 "read.c"
          tmp___40 = 7;
        }
        {
# 667 "read.c"
        tmp___41 = next_token(p + tmp___40);
# 667 "read.c"
        p = allocated_variable_expand_for_file(tmp___41, (struct file *)0);
        }
# 668 "read.c"
        if ((int )*p == 0) {
# 670 "read.c"
          if (noerror) {
# 670 "read.c"
            tmp___42 = "-";
          } else {
# 670 "read.c"
            tmp___42 = "";
          }
          {
# 670 "read.c"
          tmp___43 = dcgettext((char const *)((void *)0), "no file name for `%sinclude\'",
                               5);
# 670 "read.c"
          error((struct floc const *)(& fileinfo), (char const *)tmp___43, tmp___42);
          }
# 672 "read.c"
          goto while_continue___0;
        }
        {
# 676 "read.c"
        p2 = p;
# 677 "read.c"
        tmp___44 = parse_file_seq(& p2, '\000', (unsigned int )sizeof(struct nameseq ),
                                  1);
# 677 "read.c"
        files___0 = multi_glob(tmp___44, (unsigned int )sizeof(struct nameseq ));
# 681 "read.c"
        free((void *)p);
# 685 "read.c"
        save = conditionals;
# 686 "read.c"
        memset((void *)((char *)(& new_conditionals)), 0, sizeof(new_conditionals));
# 687 "read.c"
        conditionals = & new_conditionals;
        }
        {
# 691 "read.c"
        while (1) {
          while_continue___8: ;
# 691 "read.c"
          if ((unsigned long )filenames != (unsigned long )((struct nameseq *)0)) {
            {
# 691 "read.c"
            fi.filenm = fileinfo.filenm;
# 691 "read.c"
            fi.lineno = (unsigned long )tgts_started;
# 691 "read.c"
            record_files(filenames, pattern, pattern_percent, deps, cmds_started,
                         commands, commands_idx, two_colon, (struct floc const *)(& fi),
                         ! (flags & 1));
# 691 "read.c"
            using_filename |= commands_idx > 0U;
            }
          }
# 691 "read.c"
          filenames = (struct nameseq *)0;
# 691 "read.c"
          commands_idx = 0U;
# 691 "read.c"
          if (pattern) {
            {
# 691 "read.c"
            free((void *)pattern);
# 691 "read.c"
            pattern = (char *)0;
            }
          }
# 691 "read.c"
          goto while_break___8;
        }
        while_break___8: ;
        }
        {
# 694 "read.c"
        while (1) {
          while_continue___9: ;
# 694 "read.c"
          if (! ((unsigned long )files___0 != (unsigned long )((struct nameseq *)0))) {
# 694 "read.c"
            goto while_break___9;
          }
          {
# 696 "read.c"
          next = files___0->next;
# 697 "read.c"
          name___0 = files___0->name;
# 700 "read.c"
          free((void *)((char *)files___0));
# 701 "read.c"
          files___0 = next;
          }
# 703 "read.c"
          if (noerror) {
# 703 "read.c"
            tmp___45 = 1 << 2;
          } else {
# 703 "read.c"
            tmp___45 = 0;
          }
          {
# 703 "read.c"
          r = read_makefile(name___0, ((1 << 1) | (1 << 3)) | tmp___45);
          }
# 705 "read.c"
          if (! r) {
# 705 "read.c"
            if (! noerror) {
              {
# 706 "read.c"
              tmp___46 = __errno_location();
# 706 "read.c"
              tmp___47 = strerror(*tmp___46);
# 706 "read.c"
              error((struct floc const *)(& fileinfo), "%s: %s", name___0, tmp___47);
              }
            }
          }
# 708 "read.c"
          if (r < 2) {
            {
# 709 "read.c"
            free((void *)name___0);
            }
          }
        }
        while_break___9: ;
        }
# 713 "read.c"
        if (conditionals->ignoring) {
          {
# 714 "read.c"
          free((void *)conditionals->ignoring);
          }
        }
# 715 "read.c"
        if (conditionals->seen_else) {
          {
# 716 "read.c"
          free((void *)conditionals->seen_else);
          }
        }
# 719 "read.c"
        conditionals = save;
# 720 "read.c"
        reading_file = (struct floc const *)(& fileinfo);
      } else {
# 656 "read.c"
        goto _L___9;
      }
    } else {
      _L___9:
      {
# 723 "read.c"
      tmp___76 = try_variable_definition((struct floc const *)(& fileinfo), p, (enum variable_origin )2,
                                         0);
      }
# 723 "read.c"
      if (! tmp___76) {
# 726 "read.c"
        if ((int )*(lb.buffer + 0) == 9) {
# 728 "read.c"
          p = collapsed;
          {
# 729 "read.c"
          while (1) {
            while_continue___10: ;
            {
# 729 "read.c"
            tmp___48 = __ctype_b_loc();
            }
# 729 "read.c"
            if (! ((int const )*(*tmp___48 + (int )*p) & 1)) {
# 729 "read.c"
              goto while_break___10;
            }
# 730 "read.c"
            p ++;
          }
          while_break___10: ;
          }
# 731 "read.c"
          if ((int )*p == 0) {
# 733 "read.c"
            goto while_continue___0;
          }
          {
# 738 "read.c"
          tmp___49 = dcgettext((char const *)((void *)0), "commands commence before first target",
                               5);
# 738 "read.c"
          fatal((struct floc const *)(& fileinfo), (char const *)tmp___49);
          }
        } else {
# 755 "read.c"
          plen = 0U;
          {
# 760 "read.c"
          while (1) {
            while_continue___11: ;
# 760 "read.c"
            if ((unsigned long )filenames != (unsigned long )((struct nameseq *)0)) {
              {
# 760 "read.c"
              fi___0.filenm = fileinfo.filenm;
# 760 "read.c"
              fi___0.lineno = (unsigned long )tgts_started;
# 760 "read.c"
              record_files(filenames, pattern, pattern_percent, deps, cmds_started,
                           commands, commands_idx, two_colon, (struct floc const *)(& fi___0),
                           ! (flags & 1));
# 760 "read.c"
              using_filename |= commands_idx > 0U;
              }
            }
# 760 "read.c"
            filenames = (struct nameseq *)0;
# 760 "read.c"
            commands_idx = 0U;
# 760 "read.c"
            if (pattern) {
              {
# 760 "read.c"
              free((void *)pattern);
# 760 "read.c"
              pattern = (char *)0;
              }
            }
# 760 "read.c"
            goto while_break___11;
          }
          while_break___11: ;
          }
          {
# 761 "read.c"
          tgts_started = (unsigned int )fileinfo.lineno;
# 765 "read.c"
          cmdleft = find_char_unquote(lb.buffer, (char *)";#", 0);
          }
# 766 "read.c"
          if ((unsigned long )cmdleft != (unsigned long )((char *)0)) {
# 766 "read.c"
            if ((int )*cmdleft == 35) {
# 769 "read.c"
              *cmdleft = (char )'\000';
# 770 "read.c"
              cmdleft = (char *)0;
            } else {
# 766 "read.c"
              goto _L___7;
            }
          } else
          _L___7:
# 772 "read.c"
          if ((unsigned long )cmdleft != (unsigned long )((char *)0)) {
# 774 "read.c"
            tmp___50 = cmdleft;
# 774 "read.c"
            cmdleft ++;
# 774 "read.c"
            *tmp___50 = (char )'\000';
          }
          {
# 776 "read.c"
          collapse_continuations(lb.buffer);
# 782 "read.c"
          wtype = get_next_mword(lb.buffer, (char *)((void *)0), & lb_next, & len___4);
          }
          {
# 784 "read.c"
          if ((unsigned int )wtype == 1U) {
# 784 "read.c"
            goto case_1;
          }
# 792 "read.c"
          if ((unsigned int )wtype == 4U) {
# 792 "read.c"
            goto case_4;
          }
# 792 "read.c"
          if ((unsigned int )wtype == 5U) {
# 792 "read.c"
            goto case_4;
          }
# 798 "read.c"
          goto switch_default;
          case_1:
# 786 "read.c"
          if ((unsigned long )cmdleft != (unsigned long )((char *)0)) {
            {
# 787 "read.c"
            tmp___51 = dcgettext((char const *)((void *)0), "missing rule before commands",
                                 5);
# 787 "read.c"
            fatal((struct floc const *)(& fileinfo), (char const *)tmp___51);
            }
          }
# 790 "read.c"
          goto while_continue___0;
          case_4:
          case_5:
# 796 "read.c"
          no_targets = 1;
# 797 "read.c"
          goto while_continue___0;
          switch_default:
# 800 "read.c"
          goto switch_break;
          switch_break: ;
          }
          {
# 803 "read.c"
          p2 = variable_expand_string((char *)((void *)0), lb_next, (long )len___4);
          }
          {
# 804 "read.c"
          while (1) {
            while_continue___12: ;
# 806 "read.c"
            lb_next += len___4;
# 807 "read.c"
            if ((unsigned long )cmdleft == (unsigned long )((char *)0)) {
              {
# 810 "read.c"
              cmdleft = find_char_unquote(p2, (char *)";", 0);
              }
# 812 "read.c"
              if ((unsigned long )cmdleft != (unsigned long )((char *)0)) {
                {
# 814 "read.c"
                p2_off = (unsigned long )(p2 - variable_buffer);
# 815 "read.c"
                cmd_off = (unsigned long )(cmdleft - variable_buffer);
# 816 "read.c"
                tmp___52 = strlen((char const *)p2);
# 816 "read.c"
                pend = p2 + tmp___52;
# 820 "read.c"
                *cmdleft = (char )'\000';
# 830 "read.c"
                variable_expand_string(pend, lb_next, -1L);
# 831 "read.c"
                tmp___53 = strlen((char const *)lb_next);
# 831 "read.c"
                lb_next += tmp___53;
# 832 "read.c"
                p2 = variable_buffer + p2_off;
# 833 "read.c"
                cmdleft = (variable_buffer + cmd_off) + 1;
                }
              }
            }
            {
# 837 "read.c"
            colonp = find_char_unquote(p2, (char *)":", 0);
            }
# 848 "read.c"
            if ((unsigned long )colonp != (unsigned long )((char *)0)) {
# 849 "read.c"
              goto while_break___12;
            }
            {
# 851 "read.c"
            wtype = get_next_mword(lb_next, (char *)((void *)0), & lb_next, & len___4);
            }
# 852 "read.c"
            if ((unsigned int )wtype == 1U) {
# 853 "read.c"
              goto while_break___12;
            }
            {
# 855 "read.c"
            tmp___54 = strlen((char const *)p2);
# 855 "read.c"
            p2 += tmp___54;
# 856 "read.c"
            tmp___55 = p2;
# 856 "read.c"
            p2 ++;
# 856 "read.c"
            *tmp___55 = (char )' ';
# 857 "read.c"
            p2 = variable_expand_string(p2, lb_next, (long )len___4);
            }
          }
          while_break___12: ;
          }
          {
# 863 "read.c"
          p2 = next_token(variable_buffer);
          }
# 868 "read.c"
          if ((unsigned int )wtype == 1U) {
# 870 "read.c"
            if ((int )*p2 != 0) {
              {
# 873 "read.c"
              tmp___59 = strncmp((char const *)lb.buffer, "        ", (size_t )8);
              }
# 873 "read.c"
              if (tmp___59 == 0) {
                {
# 873 "read.c"
                tmp___57 = dcgettext((char const *)((void *)0), " (did you mean TAB instead of 8 spaces?)",
                                     5);
# 873 "read.c"
                tmp___58 = (char const *)tmp___57;
                }
              } else {
# 873 "read.c"
                tmp___58 = "";
              }
              {
# 873 "read.c"
              tmp___60 = dcgettext((char const *)((void *)0), "missing separator%s",
                                   5);
# 873 "read.c"
              fatal((struct floc const *)(& fileinfo), (char const *)tmp___60,
                    tmp___58);
              }
            }
# 876 "read.c"
            goto while_continue___0;
          }
          {
# 881 "read.c"
          *colonp = (char )'\000';
# 882 "read.c"
          tmp___61 = parse_file_seq(& p2, '\000', (unsigned int )sizeof(struct nameseq ),
                                    1);
# 882 "read.c"
          filenames = multi_glob(tmp___61, (unsigned int )sizeof(struct nameseq ));
# 886 "read.c"
          *p2 = (char )':';
          }
# 888 "read.c"
          if (! filenames) {
# 892 "read.c"
            no_targets = 1;
# 893 "read.c"
            goto while_continue___0;
          }
# 896 "read.c"
          if (! ((int )*p2 != 0)) {
            {
# 896 "read.c"
            __assert_fail("*p2 != \'\\0\'", "read.c", 896U, "read_makefile");
            }
          }
# 897 "read.c"
          p2 ++;
# 900 "read.c"
          two_colon = (int )*p2 == 58;
# 901 "read.c"
          if (two_colon) {
# 902 "read.c"
            p2 ++;
          }
# 908 "read.c"
          if ((int )*lb_next != 0) {
            {
# 910 "read.c"
            l = (unsigned int )(p2 - variable_buffer);
# 911 "read.c"
            tmp___63 = strlen((char const *)p2);
# 911 "read.c"
            plen = (unsigned int )tmp___63;
# 912 "read.c"
            tmp___64 = strlen((char const *)lb_next);
# 912 "read.c"
            variable_buffer_output(p2 + plen, lb_next, (unsigned int )(tmp___64 + 1UL));
# 914 "read.c"
            p2 = variable_buffer + l;
            }
          }
          {
# 920 "read.c"
          wtype = get_next_mword(p2, (char *)((void *)0), & p, & len___4);
# 922 "read.c"
          v_origin = (enum variable_origin )2;
          }
# 923 "read.c"
          if ((unsigned int )wtype == 2U) {
# 923 "read.c"
            if ((unsigned long )len___4 == sizeof("override") - 1UL) {
              {
# 923 "read.c"
              tmp___65 = strncmp((char const *)p, "override", (size_t )len___4);
              }
# 923 "read.c"
              if (tmp___65 == 0) {
                {
# 926 "read.c"
                v_origin = (enum variable_origin )5;
# 927 "read.c"
                wtype = get_next_mword(p + len___4, (char *)((void *)0), & p, & len___4);
                }
              }
            }
          }
# 930 "read.c"
          if ((unsigned int )wtype != 1U) {
            {
# 931 "read.c"
            wtype = get_next_mword(p + len___4, (char *)((void *)0), (char **)((void *)0),
                                   (unsigned int *)((void *)0));
            }
          }
# 933 "read.c"
          if ((unsigned int )wtype == 8U) {
            {
# 935 "read.c"
            record_target_var(filenames, p, two_colon, v_origin, (struct floc const *)(& fileinfo));
# 936 "read.c"
            filenames = (struct nameseq *)0;
            }
# 937 "read.c"
            goto while_continue___0;
          }
          {
# 942 "read.c"
          find_char_unquote(lb_next, (char *)"=", 0);
# 945 "read.c"
          no_targets = 0;
          }
# 948 "read.c"
          if ((int )*lb_next != 0) {
            {
# 950 "read.c"
            l___0 = (unsigned int )(p2 - variable_buffer);
# 951 "read.c"
            variable_expand_string(p2 + plen, lb_next, -1L);
# 952 "read.c"
            p2 = variable_buffer + l___0;
            }
# 955 "read.c"
            if ((unsigned long )cmdleft == (unsigned long )((char *)0)) {
              {
# 957 "read.c"
              cmdleft = find_char_unquote(p2, (char *)";", 0);
              }
# 958 "read.c"
              if ((unsigned long )cmdleft != (unsigned long )((char *)0)) {
# 959 "read.c"
                tmp___66 = cmdleft;
# 959 "read.c"
                cmdleft ++;
# 959 "read.c"
                *tmp___66 = (char )'\000';
              }
            }
          }
          {
# 964 "read.c"
          p = strchr((char const *)p2, ':');
          }
          {
# 965 "read.c"
          while (1) {
            while_continue___13: ;
# 965 "read.c"
            if ((unsigned long )p != (unsigned long )((char *)0)) {
# 965 "read.c"
              if (! ((int )*(p + -1) == 92)) {
# 965 "read.c"
                goto while_break___13;
              }
            } else {
# 965 "read.c"
              goto while_break___13;
            }
# 967 "read.c"
            q = p + -1;
# 968 "read.c"
            backslash = 0;
            {
# 969 "read.c"
            while (1) {
              while_continue___14: ;
# 969 "read.c"
              tmp___67 = q;
# 969 "read.c"
              q --;
# 969 "read.c"
              if (! ((int )*tmp___67 == 92)) {
# 969 "read.c"
                goto while_break___14;
              }
# 970 "read.c"
              backslash = ! backslash;
            }
            while_break___14: ;
            }
# 971 "read.c"
            if (backslash) {
              {
# 972 "read.c"
              p = strchr((char const *)(p + 1), ':');
              }
            } else {
# 974 "read.c"
              goto while_break___13;
            }
          }
          while_break___13: ;
          }
# 1005 "read.c"
          if ((unsigned long )p != (unsigned long )((char *)0)) {
            {
# 1008 "read.c"
            target = parse_file_seq(& p2, ':', (unsigned int )sizeof(struct nameseq ),
                                    1);
# 1009 "read.c"
            p2 ++;
            }
# 1010 "read.c"
            if ((unsigned long )target == (unsigned long )((struct nameseq *)0)) {
              {
# 1011 "read.c"
              tmp___68 = dcgettext((char const *)((void *)0), "missing target pattern",
                                   5);
# 1011 "read.c"
              fatal((struct floc const *)(& fileinfo), (char const *)tmp___68);
              }
            } else
# 1012 "read.c"
            if ((unsigned long )target->next != (unsigned long )((struct nameseq *)0)) {
              {
# 1013 "read.c"
              tmp___69 = dcgettext((char const *)((void *)0), "multiple target patterns",
                                   5);
# 1013 "read.c"
              fatal((struct floc const *)(& fileinfo), (char const *)tmp___69);
              }
            }
            {
# 1014 "read.c"
            pattern = target->name;
# 1015 "read.c"
            pattern_percent = find_percent(pattern);
            }
# 1016 "read.c"
            if ((unsigned long )pattern_percent == (unsigned long )((char *)0)) {
              {
# 1017 "read.c"
              tmp___70 = dcgettext((char const *)((void *)0), "target pattern contains no `%%\'",
                                   5);
# 1017 "read.c"
              fatal((struct floc const *)(& fileinfo), (char const *)tmp___70);
              }
            }
            {
# 1018 "read.c"
            free((void *)((char *)target));
            }
          } else {
# 1021 "read.c"
            pattern = (char *)0;
          }
          {
# 1024 "read.c"
          tmp___71 = parse_file_seq(& p2, '\000', (unsigned int )sizeof(struct dep ),
                                    1);
# 1024 "read.c"
          tmp___72 = multi_glob(tmp___71, (unsigned int )sizeof(struct dep ));
# 1024 "read.c"
          deps = (struct dep *)tmp___72;
# 1028 "read.c"
          commands_idx = 0U;
          }
# 1029 "read.c"
          if ((unsigned long )cmdleft != (unsigned long )((char *)0)) {
            {
# 1032 "read.c"
            tmp___73 = strlen((char const *)cmdleft);
# 1032 "read.c"
            len___5 = (unsigned int )tmp___73;
# 1034 "read.c"
            cmds_started = (unsigned int )fileinfo.lineno;
            }
# 1037 "read.c"
            if (len___5 + 2U > commands_len) {
              {
# 1039 "read.c"
              commands_len = (len___5 + 2U) * 2U;
# 1040 "read.c"
              tmp___74 = xrealloc(commands, commands_len);
# 1040 "read.c"
              commands = tmp___74;
              }
            }
            {
# 1042 "read.c"
            memmove((void *)commands, (void const *)cmdleft, (size_t )len___5);
# 1043 "read.c"
            commands_idx += len___5;
# 1044 "read.c"
            tmp___75 = commands_idx;
# 1044 "read.c"
            commands_idx ++;
# 1044 "read.c"
            *(commands + tmp___75) = (char )'\n';
            }
          }
# 1047 "read.c"
          goto while_continue___0;
        }
      }
    }
    {
# 1053 "read.c"
    while (1) {
      while_continue___15: ;
# 1053 "read.c"
      if ((unsigned long )filenames != (unsigned long )((struct nameseq *)0)) {
        {
# 1053 "read.c"
        fi___1.filenm = fileinfo.filenm;
# 1053 "read.c"
        fi___1.lineno = (unsigned long )tgts_started;
# 1053 "read.c"
        record_files(filenames, pattern, pattern_percent, deps, cmds_started, commands,
                     commands_idx, two_colon, (struct floc const *)(& fi___1), ! (flags & 1));
# 1053 "read.c"
        using_filename |= commands_idx > 0U;
        }
      }
# 1053 "read.c"
      filenames = (struct nameseq *)0;
# 1053 "read.c"
      commands_idx = 0U;
# 1053 "read.c"
      if (pattern) {
        {
# 1053 "read.c"
        free((void *)pattern);
# 1053 "read.c"
        pattern = (char *)0;
        }
      }
# 1053 "read.c"
      goto while_break___15;
    }
    while_break___15: ;
    }
# 1054 "read.c"
    no_targets = 0;
  }
  while_break___0: ;
  }
# 1057 "read.c"
  if (conditionals->if_cmds) {
    {
# 1058 "read.c"
    tmp___84 = dcgettext((char const *)((void *)0), "missing `endif\'", 5);
# 1058 "read.c"
    fatal((struct floc const *)(& fileinfo), (char const *)tmp___84);
    }
  }
  {
# 1061 "read.c"
  while (1) {
    while_continue___16: ;
# 1061 "read.c"
    if ((unsigned long )filenames != (unsigned long )((struct nameseq *)0)) {
      {
# 1061 "read.c"
      fi___2.filenm = fileinfo.filenm;
# 1061 "read.c"
      fi___2.lineno = (unsigned long )tgts_started;
# 1061 "read.c"
      record_files(filenames, pattern, pattern_percent, deps, cmds_started, commands,
                   commands_idx, two_colon, (struct floc const *)(& fi___2), ! (flags & 1));
# 1061 "read.c"
      using_filename |= commands_idx > 0U;
      }
    }
# 1061 "read.c"
    filenames = (struct nameseq *)0;
# 1061 "read.c"
    commands_idx = 0U;
# 1061 "read.c"
    if (pattern) {
      {
# 1061 "read.c"
      free((void *)pattern);
# 1061 "read.c"
      pattern = (char *)0;
      }
    }
# 1061 "read.c"
    goto while_break___16;
  }
  while_break___16: ;
  }
  {
# 1063 "read.c"
  free((void *)lb.buffer);
# 1064 "read.c"
  free((void *)commands);
# 1065 "read.c"
  fclose(infile);
# 1067 "read.c"
  reading_file = (struct floc const *)0;
  }
# 1069 "read.c"
  return (1 + using_filename);
}
}
# 1078 "read.c"
static void do_define(char *name , unsigned int namelen , enum variable_origin origin ,
                      FILE *infile , struct floc *flocp )
{
  struct linebuffer lb ;
  unsigned int nlines ;
  unsigned int length___0 ;
  char *definition ;
  char *tmp ;
  register unsigned int idx ;
  register char *p ;
  char *var ;
  void *tmp___0 ;
  char *tmp___1 ;
  unsigned int len ;
  unsigned long tmp___2 ;
  size_t tmp___3 ;
  char *tmp___4 ;
  char *tmp___5 ;
  size_t tmp___6 ;
  size_t tmp___7 ;
  char *tmp___8 ;
  unsigned int tmp___9 ;
  unsigned short const **tmp___10 ;
  int tmp___11 ;
  int tmp___12 ;
  char *tmp___13 ;

  {
  {
# 1087 "read.c"
  nlines = 0U;
# 1088 "read.c"
  length___0 = 100U;
# 1089 "read.c"
  tmp = xmalloc(100U);
# 1089 "read.c"
  definition = tmp;
# 1090 "read.c"
  idx = 0U;
# 1094 "read.c"
  tmp___0 = __builtin_alloca((unsigned long )(namelen + 1U));
# 1094 "read.c"
  var = (char *)tmp___0;
# 1095 "read.c"
  memmove((void *)var, (void const *)name, (size_t )namelen);
# 1096 "read.c"
  *(var + namelen) = (char )'\000';
# 1097 "read.c"
  var = variable_expand(var);
# 1099 "read.c"
  lb.size = 200U;
# 1099 "read.c"
  tmp___1 = xmalloc(lb.size);
# 1099 "read.c"
  lb.buffer = tmp___1;
  }
  {
# 1100 "read.c"
  while (1) {
    while_continue: ;
    {
# 1100 "read.c"
    tmp___12 = feof(infile);
    }
# 1100 "read.c"
    if (tmp___12) {
# 1100 "read.c"
      goto while_break;
    }
    {
# 1104 "read.c"
    flocp->lineno += (unsigned long )nlines;
# 1105 "read.c"
    tmp___2 = readline(& lb, infile, (struct floc const *)flocp);
# 1105 "read.c"
    nlines = (unsigned int )tmp___2;
# 1107 "read.c"
    collapse_continuations(lb.buffer);
# 1109 "read.c"
    p = next_token(lb.buffer);
# 1110 "read.c"
    tmp___3 = strlen((char const *)p);
# 1110 "read.c"
    len = (unsigned int )tmp___3;
    }
# 1111 "read.c"
    if (len == 5U) {
# 1111 "read.c"
      goto _L___0;
    } else
# 1111 "read.c"
    if (len > 5U) {
      {
# 1111 "read.c"
      tmp___10 = __ctype_b_loc();
      }
# 1111 "read.c"
      if ((int const )*(*tmp___10 + (int )*(p + 5)) & 1) {
        _L___0:
        {
# 1111 "read.c"
        tmp___11 = strncmp((char const *)p, "endef", (size_t )5);
        }
# 1111 "read.c"
        if (tmp___11 == 0) {
          {
# 1114 "read.c"
          p += 5;
# 1115 "read.c"
          remove_comments(p);
# 1116 "read.c"
          tmp___5 = next_token(p);
          }
# 1116 "read.c"
          if ((int )*tmp___5 != 0) {
            {
# 1117 "read.c"
            tmp___4 = dcgettext((char const *)((void *)0), "Extraneous text after `endef\' directive",
                                5);
# 1117 "read.c"
            error((struct floc const *)flocp, (char const *)tmp___4);
            }
          }
# 1119 "read.c"
          if (idx == 0U) {
# 1120 "read.c"
            *(definition + 0) = (char )'\000';
          } else {
# 1122 "read.c"
            *(definition + (idx - 1U)) = (char )'\000';
          }
          {
# 1123 "read.c"
          tmp___6 = strlen((char const *)var);
# 1123 "read.c"
          define_variable_in_set(var, (unsigned int )tmp___6, definition, origin,
                                 1, current_variable_set_list->set, (struct floc const *)flocp);
# 1125 "read.c"
          free((void *)definition);
# 1126 "read.c"
          free((void *)lb.buffer);
          }
# 1127 "read.c"
          return;
        } else {
# 1111 "read.c"
          goto _L___1;
        }
      } else {
# 1111 "read.c"
        goto _L___1;
      }
    } else {
      _L___1:
      {
# 1131 "read.c"
      tmp___7 = strlen((char const *)lb.buffer);
# 1131 "read.c"
      len = (unsigned int )tmp___7;
      }
# 1133 "read.c"
      if ((idx + len) + 1U > length___0) {
        {
# 1135 "read.c"
        length___0 = (idx + len) * 2U;
# 1136 "read.c"
        tmp___8 = xrealloc(definition, length___0 + 1U);
# 1136 "read.c"
        definition = tmp___8;
        }
      }
      {
# 1139 "read.c"
      memmove((void *)(definition + idx), (void const *)lb.buffer, (size_t )len);
# 1140 "read.c"
      idx += len;
# 1142 "read.c"
      tmp___9 = idx;
# 1142 "read.c"
      idx ++;
# 1142 "read.c"
      *(definition + tmp___9) = (char )'\n';
      }
    }
  }
  while_break: ;
  }
  {
# 1147 "read.c"
  tmp___13 = dcgettext((char const *)((void *)0), "missing `endef\', unterminated `define\'",
                       5);
# 1147 "read.c"
  fatal((struct floc const *)flocp, (char const *)tmp___13);
  }
# 1150 "read.c"
  return;
}
}
# 1164 "read.c"
static int conditional_line(char *line , struct floc const *flocp )
{
  int notdef ;
  char *cmdname ;
  register unsigned int i ;
  int tmp ;
  int tmp___0 ;
  int tmp___1 ;
  char *tmp___2 ;
  char *tmp___3 ;
  char *tmp___4 ;
  char *tmp___5 ;
  char *tmp___6 ;
  char *tmp___7 ;
  char *tmp___8 ;
  struct variable *v ;
  register char *p ;
  char *tmp___9 ;
  int tmp___10 ;
  char *s1 ;
  char *s2 ;
  unsigned int len ;
  char termin ;
  int tmp___11 ;
  register int count ;
  char *p___0 ;
  char *tmp___12 ;
  unsigned short const **tmp___13 ;
  char *tmp___14 ;
  size_t tmp___15 ;
  void *tmp___16 ;
  register int count___0 ;
  char *tmp___17 ;
  int tmp___18 ;
  int tmp___19 ;
  int tmp___20 ;

  {
# 1173 "read.c"
  if ((int )*line == 105) {
# 1176 "read.c"
    notdef = (int )*(line + 2) == 110;
# 1177 "read.c"
    if (notdef) {
# 1179 "read.c"
      if ((int )*(line + 3) == 100) {
# 1179 "read.c"
        cmdname = (char *)"ifndef";
      } else {
# 1179 "read.c"
        cmdname = (char *)"ifneq";
      }
# 1180 "read.c"
      if ((int )*(cmdname + 3) == 100) {
# 1180 "read.c"
        tmp = 7;
      } else {
# 1180 "read.c"
        tmp = 6;
      }
# 1180 "read.c"
      line += tmp;
    } else {
# 1184 "read.c"
      if ((int )*(line + 2) == 100) {
# 1184 "read.c"
        cmdname = (char *)"ifdef";
      } else {
# 1184 "read.c"
        cmdname = (char *)"ifeq";
      }
# 1185 "read.c"
      if ((int )*(cmdname + 2) == 100) {
# 1185 "read.c"
        tmp___0 = 6;
      } else {
# 1185 "read.c"
        tmp___0 = 5;
      }
# 1185 "read.c"
      line += tmp___0;
    }
  } else {
# 1191 "read.c"
    notdef = (int )*(line + 1) == 110;
# 1192 "read.c"
    if (notdef) {
# 1192 "read.c"
      cmdname = (char *)"endif";
    } else {
# 1192 "read.c"
      cmdname = (char *)"else";
    }
# 1193 "read.c"
    if (notdef) {
# 1193 "read.c"
      tmp___1 = 5;
    } else {
# 1193 "read.c"
      tmp___1 = 4;
    }
# 1193 "read.c"
    line += tmp___1;
  }
  {
# 1196 "read.c"
  line = next_token(line);
  }
# 1198 "read.c"
  if ((int )*cmdname == 101) {
# 1200 "read.c"
    if ((int )*line != 0) {
      {
# 1201 "read.c"
      tmp___2 = dcgettext((char const *)((void *)0), "Extraneous text after `%s\' directive",
                          5);
# 1201 "read.c"
      error(flocp, (char const *)tmp___2, cmdname);
      }
    }
# 1203 "read.c"
    if (conditionals->if_cmds == 0U) {
      {
# 1204 "read.c"
      tmp___3 = dcgettext((char const *)((void *)0), "extraneous `%s\'", 5);
# 1204 "read.c"
      fatal(flocp, (char const *)tmp___3, cmdname);
      }
    }
# 1206 "read.c"
    if (notdef) {
# 1207 "read.c"
      (conditionals->if_cmds) --;
    } else
# 1208 "read.c"
    if (*(conditionals->seen_else + (conditionals->if_cmds - 1U))) {
      {
# 1209 "read.c"
      tmp___4 = dcgettext((char const *)((void *)0), "only one `else\' per conditional",
                          5);
# 1209 "read.c"
      fatal(flocp, (char const *)tmp___4);
      }
    } else {
# 1213 "read.c"
      *(conditionals->ignoring + (conditionals->if_cmds - 1U)) = (char )(! *(conditionals->ignoring + (conditionals->if_cmds - 1U)));
# 1217 "read.c"
      *(conditionals->seen_else + (conditionals->if_cmds - 1U)) = (char)1;
    }
# 1219 "read.c"
    i = 0U;
    {
# 1219 "read.c"
    while (1) {
      while_continue: ;
# 1219 "read.c"
      if (! (i < conditionals->if_cmds)) {
# 1219 "read.c"
        goto while_break;
      }
# 1220 "read.c"
      if (*(conditionals->ignoring + i)) {
# 1221 "read.c"
        return (1);
      }
# 1219 "read.c"
      i ++;
    }
    while_break: ;
    }
# 1222 "read.c"
    return (0);
  }
# 1225 "read.c"
  if (conditionals->allocated == 0U) {
    {
# 1227 "read.c"
    conditionals->allocated = 5U;
# 1228 "read.c"
    tmp___5 = xmalloc(conditionals->allocated);
# 1228 "read.c"
    conditionals->ignoring = tmp___5;
# 1229 "read.c"
    tmp___6 = xmalloc(conditionals->allocated);
# 1229 "read.c"
    conditionals->seen_else = tmp___6;
    }
  }
# 1232 "read.c"
  (conditionals->if_cmds) ++;
# 1233 "read.c"
  if (conditionals->if_cmds > conditionals->allocated) {
    {
# 1235 "read.c"
    conditionals->allocated += 5U;
# 1236 "read.c"
    tmp___7 = xrealloc(conditionals->ignoring, conditionals->allocated);
# 1236 "read.c"
    conditionals->ignoring = tmp___7;
# 1238 "read.c"
    tmp___8 = xrealloc(conditionals->seen_else, conditionals->allocated);
# 1238 "read.c"
    conditionals->seen_else = tmp___8;
    }
  }
# 1243 "read.c"
  *(conditionals->seen_else + (conditionals->if_cmds - 1U)) = (char)0;
# 1246 "read.c"
  i = 0U;
  {
# 1246 "read.c"
  while (1) {
    while_continue___0: ;
# 1246 "read.c"
    if (! (i < conditionals->if_cmds - 1U)) {
# 1246 "read.c"
      goto while_break___0;
    }
# 1247 "read.c"
    if (*(conditionals->ignoring + i)) {
# 1252 "read.c"
      *(conditionals->ignoring + (conditionals->if_cmds - 1U)) = (char)1;
# 1253 "read.c"
      return (1);
    }
# 1246 "read.c"
    i ++;
  }
  while_break___0: ;
  }
# 1256 "read.c"
  if (notdef) {
# 1256 "read.c"
    tmp___20 = 3;
  } else {
# 1256 "read.c"
    tmp___20 = 2;
  }
# 1256 "read.c"
  if ((int )*(cmdname + tmp___20) == 100) {
    {
# 1260 "read.c"
    tmp___9 = end_of_token(line);
# 1260 "read.c"
    p = tmp___9;
# 1261 "read.c"
    i = (unsigned int )(p - line);
# 1262 "read.c"
    p = next_token(p);
    }
# 1263 "read.c"
    if ((int )*p != 0) {
# 1264 "read.c"
      return (-1);
    }
    {
# 1265 "read.c"
    v = lookup_variable(line, i);
    }
# 1266 "read.c"
    if ((unsigned long )v != (unsigned long )((struct variable *)0)) {
# 1266 "read.c"
      if ((int )*(v->value) != 0) {
# 1266 "read.c"
        tmp___10 = 1;
      } else {
# 1266 "read.c"
        tmp___10 = 0;
      }
    } else {
# 1266 "read.c"
      tmp___10 = 0;
    }
# 1266 "read.c"
    *(conditionals->ignoring + (conditionals->if_cmds - 1U)) = (char )(tmp___10 == notdef);
  } else {
# 1274 "read.c"
    if ((int )*line == 40) {
# 1274 "read.c"
      tmp___11 = ',';
    } else {
# 1274 "read.c"
      tmp___11 = (int )*line;
    }
# 1274 "read.c"
    termin = (char )tmp___11;
# 1276 "read.c"
    if ((int )termin != 44) {
# 1276 "read.c"
      if ((int )termin != 34) {
# 1276 "read.c"
        if ((int )termin != 39) {
# 1277 "read.c"
          return (-1);
        }
      }
    }
# 1279 "read.c"
    line ++;
# 1279 "read.c"
    s1 = line;
# 1281 "read.c"
    if ((int )termin == 44) {
# 1283 "read.c"
      count = 0;
      {
# 1284 "read.c"
      while (1) {
        while_continue___1: ;
# 1284 "read.c"
        if (! ((int )*line != 0)) {
# 1284 "read.c"
          goto while_break___1;
        }
# 1285 "read.c"
        if ((int )*line == 40) {
# 1286 "read.c"
          count ++;
        } else
# 1287 "read.c"
        if ((int )*line == 41) {
# 1288 "read.c"
          count --;
        } else
# 1289 "read.c"
        if ((int )*line == 44) {
# 1289 "read.c"
          if (count <= 0) {
# 1290 "read.c"
            goto while_break___1;
          }
        }
# 1284 "read.c"
        line ++;
      }
      while_break___1: ;
      }
    } else {
      {
# 1293 "read.c"
      while (1) {
        while_continue___2: ;
# 1293 "read.c"
        if ((int )*line != 0) {
# 1293 "read.c"
          if (! ((int )*line != (int )termin)) {
# 1293 "read.c"
            goto while_break___2;
          }
        } else {
# 1293 "read.c"
          goto while_break___2;
        }
# 1294 "read.c"
        line ++;
      }
      while_break___2: ;
      }
    }
# 1296 "read.c"
    if ((int )*line == 0) {
# 1297 "read.c"
      return (-1);
    }
# 1299 "read.c"
    if ((int )termin == 44) {
# 1302 "read.c"
      tmp___12 = line;
# 1302 "read.c"
      line ++;
# 1302 "read.c"
      p___0 = tmp___12;
      {
# 1303 "read.c"
      while (1) {
        while_continue___3: ;
        {
# 1303 "read.c"
        tmp___13 = __ctype_b_loc();
        }
# 1303 "read.c"
        if (! ((int const )*(*tmp___13 + (int )*(p___0 + -1)) & 1)) {
# 1303 "read.c"
          goto while_break___3;
        }
# 1304 "read.c"
        p___0 --;
      }
      while_break___3: ;
      }
# 1305 "read.c"
      *p___0 = (char )'\000';
    } else {
# 1308 "read.c"
      tmp___14 = line;
# 1308 "read.c"
      line ++;
# 1308 "read.c"
      *tmp___14 = (char )'\000';
    }
    {
# 1310 "read.c"
    s2 = variable_expand(s1);
# 1313 "read.c"
    tmp___15 = strlen((char const *)s2);
# 1313 "read.c"
    len = (unsigned int )tmp___15;
# 1314 "read.c"
    tmp___16 = __builtin_alloca((unsigned long )(len + 1U));
# 1314 "read.c"
    s1 = (char *)tmp___16;
# 1315 "read.c"
    memmove((void *)s1, (void const *)s2, (size_t )(len + 1U));
    }
# 1317 "read.c"
    if ((int )termin != 44) {
      {
# 1319 "read.c"
      line = next_token(line);
      }
    }
# 1321 "read.c"
    if ((int )termin == 44) {
# 1321 "read.c"
      termin = (char )')';
    } else {
# 1321 "read.c"
      termin = *line;
    }
# 1322 "read.c"
    if ((int )termin != 41) {
# 1322 "read.c"
      if ((int )termin != 34) {
# 1322 "read.c"
        if ((int )termin != 39) {
# 1323 "read.c"
          return (-1);
        }
      }
    }
# 1326 "read.c"
    if ((int )termin == 41) {
      {
# 1328 "read.c"
      count___0 = 0;
# 1329 "read.c"
      s2 = next_token(line);
# 1330 "read.c"
      line = s2;
      }
      {
# 1330 "read.c"
      while (1) {
        while_continue___4: ;
# 1330 "read.c"
        if (! ((int )*line != 0)) {
# 1330 "read.c"
          goto while_break___4;
        }
# 1332 "read.c"
        if ((int )*line == 40) {
# 1333 "read.c"
          count___0 ++;
        } else
# 1334 "read.c"
        if ((int )*line == 41) {
# 1336 "read.c"
          if (count___0 <= 0) {
# 1337 "read.c"
            goto while_break___4;
          } else {
# 1339 "read.c"
            count___0 --;
          }
        }
# 1330 "read.c"
        line ++;
      }
      while_break___4: ;
      }
    } else {
# 1345 "read.c"
      line ++;
# 1346 "read.c"
      s2 = line;
      {
# 1347 "read.c"
      while (1) {
        while_continue___5: ;
# 1347 "read.c"
        if ((int )*line != 0) {
# 1347 "read.c"
          if (! ((int )*line != (int )termin)) {
# 1347 "read.c"
            goto while_break___5;
          }
        } else {
# 1347 "read.c"
          goto while_break___5;
        }
# 1348 "read.c"
        line ++;
      }
      while_break___5: ;
      }
    }
# 1351 "read.c"
    if ((int )*line == 0) {
# 1352 "read.c"
      return (-1);
    }
    {
# 1354 "read.c"
    *line = (char )'\000';
# 1355 "read.c"
    line ++;
# 1355 "read.c"
    line = next_token(line);
    }
# 1356 "read.c"
    if ((int )*line != 0) {
      {
# 1357 "read.c"
      tmp___17 = dcgettext((char const *)((void *)0), "Extraneous text after `%s\' directive",
                           5);
# 1357 "read.c"
      error(flocp, (char const *)tmp___17, cmdname);
      }
    }
    {
# 1359 "read.c"
    s2 = variable_expand(s2);
    }
# 1360 "read.c"
    if ((unsigned long )s1 == (unsigned long )s2) {
# 1360 "read.c"
      tmp___19 = 1;
    } else
# 1360 "read.c"
    if ((int )*s1 == (int )*s2) {
# 1360 "read.c"
      if ((int )*s1 == 0) {
# 1360 "read.c"
        tmp___19 = 1;
      } else {
        {
# 1360 "read.c"
        tmp___18 = strcmp((char const *)(s1 + 1), (char const *)(s2 + 1));
        }
# 1360 "read.c"
        if (tmp___18) {
# 1360 "read.c"
          tmp___19 = 0;
        } else {
# 1360 "read.c"
          tmp___19 = 1;
        }
      }
    } else {
# 1360 "read.c"
      tmp___19 = 0;
    }
# 1360 "read.c"
    *(conditionals->ignoring + (conditionals->if_cmds - 1U)) = (char )(tmp___19 == notdef);
  }
# 1365 "read.c"
  i = 0U;
  {
# 1365 "read.c"
  while (1) {
    while_continue___6: ;
# 1365 "read.c"
    if (! (i < conditionals->if_cmds)) {
# 1365 "read.c"
      goto while_break___6;
    }
# 1366 "read.c"
    if (*(conditionals->ignoring + i)) {
# 1367 "read.c"
      return (1);
    }
# 1365 "read.c"
    i ++;
  }
  while_break___6: ;
  }
# 1368 "read.c"
  return (0);
}
}
# 1373 "read.c"
void uniquize_deps(struct dep *chain )
{
  register struct dep *d ;
  struct dep *last ;
  struct dep *next ;
  struct dep *n ;
  char *tmp ;
  char *tmp___0 ;
  char *tmp___1 ;
  char *tmp___2 ;
  char *tmp___3 ;
  char *tmp___4 ;
  char *tmp___5 ;
  int tmp___6 ;

  {
# 1383 "read.c"
  d = chain;
  {
# 1383 "read.c"
  while (1) {
    while_continue: ;
# 1383 "read.c"
    if (! ((unsigned long )d != (unsigned long )((struct dep *)0))) {
# 1383 "read.c"
      goto while_break;
    }
# 1387 "read.c"
    last = d;
# 1388 "read.c"
    next = d->next;
    {
# 1389 "read.c"
    while (1) {
      while_continue___0: ;
# 1389 "read.c"
      if (! ((unsigned long )next != (unsigned long )((struct dep *)0))) {
# 1389 "read.c"
        goto while_break___0;
      }
# 1390 "read.c"
      if ((unsigned long )d->name == (unsigned long )((char *)0)) {
# 1390 "read.c"
        tmp = (d->file)->name;
      } else {
# 1390 "read.c"
        tmp = d->name;
      }
# 1390 "read.c"
      if ((unsigned long )next->name == (unsigned long )((char *)0)) {
# 1390 "read.c"
        tmp___0 = (next->file)->name;
      } else {
# 1390 "read.c"
        tmp___0 = next->name;
      }
# 1390 "read.c"
      if ((unsigned long )tmp == (unsigned long )tmp___0) {
# 1390 "read.c"
        goto _L___0;
      } else {
# 1390 "read.c"
        if ((unsigned long )d->name == (unsigned long )((char *)0)) {
# 1390 "read.c"
          tmp___1 = (d->file)->name;
        } else {
# 1390 "read.c"
          tmp___1 = d->name;
        }
# 1390 "read.c"
        if ((unsigned long )next->name == (unsigned long )((char *)0)) {
# 1390 "read.c"
          tmp___2 = (next->file)->name;
        } else {
# 1390 "read.c"
          tmp___2 = next->name;
        }
# 1390 "read.c"
        if ((int )*tmp___1 == (int )*tmp___2) {
# 1390 "read.c"
          if ((unsigned long )d->name == (unsigned long )((char *)0)) {
# 1390 "read.c"
            tmp___3 = (d->file)->name;
          } else {
# 1390 "read.c"
            tmp___3 = d->name;
          }
# 1390 "read.c"
          if ((int )*tmp___3 == 0) {
# 1390 "read.c"
            goto _L___0;
          } else {
# 1390 "read.c"
            if ((unsigned long )next->name == (unsigned long )((char *)0)) {
# 1390 "read.c"
              tmp___4 = (next->file)->name;
            } else {
# 1390 "read.c"
              tmp___4 = next->name;
            }
# 1390 "read.c"
            if ((unsigned long )d->name == (unsigned long )((char *)0)) {
# 1390 "read.c"
              tmp___5 = (d->file)->name;
            } else {
# 1390 "read.c"
              tmp___5 = d->name;
            }
            {
# 1390 "read.c"
            tmp___6 = strcmp((char const *)(tmp___5 + 1), (char const *)(tmp___4 + 1));
            }
# 1390 "read.c"
            if (tmp___6) {
# 1402 "read.c"
              last = next;
# 1403 "read.c"
              next = next->next;
            } else {
              _L___0:
# 1392 "read.c"
              n = next->next;
# 1393 "read.c"
              last->next = n;
# 1394 "read.c"
              if ((unsigned long )next->name != (unsigned long )((char *)0)) {
# 1394 "read.c"
                if ((unsigned long )next->name != (unsigned long )d->name) {
                  {
# 1395 "read.c"
                  free((void *)next->name);
                  }
                }
              }
# 1396 "read.c"
              if ((unsigned long )next != (unsigned long )d) {
                {
# 1397 "read.c"
                free((void *)((char *)next));
                }
              }
# 1398 "read.c"
              next = n;
            }
          }
        } else {
# 1402 "read.c"
          last = next;
# 1403 "read.c"
          next = next->next;
        }
      }
    }
    while_break___0: ;
    }
# 1383 "read.c"
    d = d->next;
  }
  while_break: ;
  }
# 1406 "read.c"
  return;
}
}
# 1417 "read.c"
static void record_target_var(struct nameseq *filenames , char *defn , int two_colon ,
                              enum variable_origin origin , struct floc const *flocp )
{
  struct nameseq *nextf ;
  struct variable_set_list *global ;
  struct variable *v ;
  register char *name ;
  struct variable_set_list *vlist ;
  char *fname ;
  char *percent ;
  struct pattern_var *p ;
  struct file *f ;
  char *tmp ;
  struct variable *gv ;
  int len ;
  size_t tmp___0 ;
  size_t tmp___1 ;

  {
# 1428 "read.c"
  global = current_variable_set_list;
  {
# 1433 "read.c"
  while (1) {
    while_continue: ;
# 1433 "read.c"
    if (! ((unsigned long )filenames != (unsigned long )((struct nameseq *)0))) {
# 1433 "read.c"
      goto while_break;
    }
    {
# 1436 "read.c"
    name = filenames->name;
# 1441 "read.c"
    nextf = filenames->next;
# 1442 "read.c"
    free((void *)((char *)filenames));
# 1446 "read.c"
    percent = find_percent(name);
    }
# 1447 "read.c"
    if (percent) {
      {
# 1452 "read.c"
      p = create_pattern_var(name, percent);
# 1453 "read.c"
      vlist = p->vars;
# 1454 "read.c"
      fname = p->target;
      }
    } else {
      {
# 1461 "read.c"
      f = enter_file(name);
# 1462 "read.c"
      initialize_file_variables(f, 1);
# 1463 "read.c"
      vlist = f->variables;
# 1464 "read.c"
      fname = f->name;
      }
    }
    {
# 1468 "read.c"
    current_variable_set_list = vlist;
# 1469 "read.c"
    v = try_variable_definition(flocp, defn, origin, 1);
    }
# 1470 "read.c"
    if (! v) {
      {
# 1471 "read.c"
      tmp = dcgettext((char const *)((void *)0), "Malformed per-target variable definition",
                      5);
# 1471 "read.c"
      error(flocp, (char const *)tmp);
      }
    }
# 1472 "read.c"
    v->per_target = 1U;
# 1476 "read.c"
    if ((unsigned int )origin != 5U) {
      {
# 1479 "read.c"
      tmp___0 = strlen((char const *)v->name);
# 1479 "read.c"
      len = (int )tmp___0;
# 1481 "read.c"
      current_variable_set_list = global;
# 1482 "read.c"
      gv = lookup_variable(v->name, (unsigned int )len);
      }
# 1483 "read.c"
      if (gv) {
# 1483 "read.c"
        if ((unsigned int )gv->origin == 3U) {
          {
# 1484 "read.c"
          define_variable_in_set(v->name, (unsigned int )len, gv->value, gv->origin,
                                 (int )gv->recursive, vlist->set, flocp);
          }
        } else
# 1483 "read.c"
        if ((unsigned int )gv->origin == 4U) {
          {
# 1484 "read.c"
          define_variable_in_set(v->name, (unsigned int )len, gv->value, gv->origin,
                                 (int )gv->recursive, vlist->set, flocp);
          }
        }
      }
    }
# 1489 "read.c"
    if ((unsigned long )name != (unsigned long )fname) {
# 1489 "read.c"
      if ((unsigned long )name < (unsigned long )fname) {
        {
# 1490 "read.c"
        free((void *)name);
        }
      } else {
        {
# 1489 "read.c"
        tmp___1 = strlen((char const *)fname);
        }
# 1489 "read.c"
        if ((unsigned long )name > (unsigned long )(fname + tmp___1)) {
          {
# 1490 "read.c"
          free((void *)name);
          }
        }
      }
    }
# 1433 "read.c"
    filenames = nextf;
  }
  while_break: ;
  }
# 1493 "read.c"
  current_variable_set_list = global;
# 1494 "read.c"
  return;
}
}
# 1719 "read.c"
static char *percent___0 = (char *)"%";
# 1507 "read.c"
static void record_files(struct nameseq *filenames , char *pattern , char *pattern_percent ,
                         struct dep *deps , unsigned int cmds_started , char *commands ,
                         unsigned int commands_idx , int two_colon , struct floc const *flocp ,
                         int set_default )
{
  struct nameseq *nextf ;
  int implicit ;
  unsigned int max_targets ;
  unsigned int target_idx ;
  char **targets ;
  char **target_percents ;
  struct commands *cmds ;
  char *tmp ;
  register char *name ;
  register struct file *f ;
  register struct dep *d ;
  struct dep *this ;
  char *implicit_percent ;
  char *tmp___0 ;
  char *tmp___1 ;
  char *tmp___2 ;
  char *tmp___3 ;
  char *tmp___4 ;
  char *tmp___5 ;
  struct dep *tmp___6 ;
  char *tmp___7 ;
  char *buffer ;
  char *tmp___8 ;
  char *o ;
  char *percent ;
  char *tmp___9 ;
  char *tmp___10 ;
  int tmp___11 ;
  char *tmp___12 ;
  char *tmp___13 ;
  char *tmp___14 ;
  char *tmp___15 ;
  struct dep *nextd ;
  struct dep *firstdeps ;
  struct dep *moredeps ;
  char *buffer___0 ;
  char *tmp___16 ;
  char *o___0 ;
  char *tmp___17 ;
  char *tmp___18 ;
  size_t tmp___19 ;
  int reject ;
  register struct dep *d2 ;
  char *tmp___20 ;
  char *tmp___21 ;
  char *tmp___22 ;
  char *tmp___23 ;
  int tmp___24 ;
  register unsigned int len ;
  char *tmp___25 ;
  size_t tmp___26 ;
  char *tmp___27 ;
  int tmp___28 ;
  char *tmp___29 ;
  char *tmp___30 ;
  char *tmp___31 ;
  int tmp___32 ;
  char *tmp___33 ;

  {
# 1521 "read.c"
  implicit = 0;
# 1522 "read.c"
  max_targets = 0U;
# 1522 "read.c"
  target_idx = 0U;
# 1523 "read.c"
  targets = (char **)0;
# 1523 "read.c"
  target_percents = (char **)0;
# 1526 "read.c"
  if (commands_idx > 0U) {
    {
# 1528 "read.c"
    tmp = xmalloc((unsigned int )sizeof(struct commands ));
# 1528 "read.c"
    cmds = (struct commands *)tmp;
# 1529 "read.c"
    cmds->fileinfo.filenm = (char *)flocp->filenm;
# 1530 "read.c"
    cmds->fileinfo.lineno = (unsigned long )cmds_started;
# 1531 "read.c"
    cmds->commands = savestring((char const *)commands, commands_idx);
# 1532 "read.c"
    cmds->command_lines = (char **)0;
    }
  } else {
# 1535 "read.c"
    cmds = (struct commands *)0;
  }
  {
# 1537 "read.c"
  while (1) {
    while_continue: ;
# 1537 "read.c"
    if (! ((unsigned long )filenames != (unsigned long )((struct nameseq *)0))) {
# 1537 "read.c"
      goto while_break;
    }
    {
# 1540 "read.c"
    name = filenames->name;
# 1546 "read.c"
    nextf = filenames->next;
# 1547 "read.c"
    free((void *)filenames);
# 1549 "read.c"
    implicit_percent = find_percent(name);
# 1550 "read.c"
    implicit |= (unsigned long )implicit_percent != (unsigned long )((char *)0);
    }
# 1552 "read.c"
    if (implicit) {
# 1552 "read.c"
      if ((unsigned long )pattern != (unsigned long )((char *)0)) {
        {
# 1553 "read.c"
        tmp___0 = dcgettext((char const *)((void *)0), "mixed implicit and static pattern rules",
                            5);
# 1553 "read.c"
        fatal(flocp, (char const *)tmp___0);
        }
      }
    }
# 1555 "read.c"
    if (implicit) {
# 1555 "read.c"
      if ((unsigned long )implicit_percent == (unsigned long )((char *)0)) {
        {
# 1556 "read.c"
        tmp___1 = dcgettext((char const *)((void *)0), "mixed implicit and normal rules",
                            5);
# 1556 "read.c"
        fatal(flocp, (char const *)tmp___1);
        }
      }
    }
# 1558 "read.c"
    if (implicit) {
# 1560 "read.c"
      if ((unsigned long )targets == (unsigned long )((char **)0)) {
        {
# 1562 "read.c"
        max_targets = 5U;
# 1563 "read.c"
        tmp___2 = xmalloc((unsigned int )(5UL * sizeof(char *)));
# 1563 "read.c"
        targets = (char **)tmp___2;
# 1564 "read.c"
        tmp___3 = xmalloc((unsigned int )(5UL * sizeof(char *)));
# 1564 "read.c"
        target_percents = (char **)tmp___3;
# 1565 "read.c"
        target_idx = 0U;
        }
      } else
# 1567 "read.c"
      if (target_idx == max_targets - 1U) {
        {
# 1569 "read.c"
        max_targets += 5U;
# 1570 "read.c"
        tmp___4 = xrealloc((char *)targets, (unsigned int )((unsigned long )max_targets * sizeof(char *)));
# 1570 "read.c"
        targets = (char **)tmp___4;
# 1572 "read.c"
        tmp___5 = xrealloc((char *)target_percents, (unsigned int )((unsigned long )max_targets * sizeof(char *)));
# 1572 "read.c"
        target_percents = (char **)tmp___5;
        }
      }
# 1576 "read.c"
      *(targets + target_idx) = name;
# 1577 "read.c"
      *(target_percents + target_idx) = implicit_percent;
# 1578 "read.c"
      target_idx ++;
# 1579 "read.c"
      goto __Cont;
    }
# 1585 "read.c"
    if ((unsigned long )nextf != (unsigned long )((struct nameseq *)0)) {
      {
# 1585 "read.c"
      tmp___6 = copy_dep_chain(deps);
# 1585 "read.c"
      this = tmp___6;
      }
    } else {
# 1585 "read.c"
      this = deps;
    }
# 1587 "read.c"
    if ((unsigned long )pattern != (unsigned long )((char *)0)) {
      {
# 1593 "read.c"
      tmp___11 = pattern_matches(pattern, pattern_percent, name);
      }
# 1593 "read.c"
      if (tmp___11) {
        {
# 1605 "read.c"
        tmp___8 = variable_expand((char *)"");
# 1605 "read.c"
        buffer = tmp___8;
# 1607 "read.c"
        d = this;
        }
        {
# 1607 "read.c"
        while (1) {
          while_continue___0: ;
# 1607 "read.c"
          if (! ((unsigned long )d != (unsigned long )((struct dep *)0))) {
# 1607 "read.c"
            goto while_break___0;
          }
          {
# 1610 "read.c"
          tmp___9 = find_percent(d->name);
# 1610 "read.c"
          percent = tmp___9;
          }
# 1611 "read.c"
          if ((unsigned long )percent == (unsigned long )((char *)0)) {
# 1612 "read.c"
            goto __Cont___0;
          }
          {
# 1613 "read.c"
          o = patsubst_expand(buffer, name, pattern, d->name, pattern_percent, percent);
          }
# 1617 "read.c"
          if ((unsigned long )o == (unsigned long )buffer) {
            {
# 1618 "read.c"
            tmp___10 = dcgettext((char const *)((void *)0), "target `%s\' leaves prerequisite pattern empty",
                                 5);
# 1618 "read.c"
            fatal(flocp, (char const *)tmp___10, name);
            }
          }
          {
# 1621 "read.c"
          free((void *)d->name);
# 1622 "read.c"
          d->name = savestring((char const *)buffer, (unsigned int )(o - buffer));
          }
          __Cont___0:
# 1607 "read.c"
          d = d->next;
        }
        while_break___0: ;
        }
      } else {
        {
# 1596 "read.c"
        tmp___7 = dcgettext((char const *)((void *)0), "target `%s\' doesn\'t match the target pattern",
                            5);
# 1596 "read.c"
        error(flocp, (char const *)tmp___7, name);
# 1598 "read.c"
        this = (struct dep *)0;
        }
      }
    }
# 1627 "read.c"
    if (! two_colon) {
      {
# 1631 "read.c"
      f = enter_file(name);
      }
# 1633 "read.c"
      if (f->double_colon) {
        {
# 1634 "read.c"
        tmp___12 = dcgettext((char const *)((void *)0), "target file `%s\' has both : and :: entries",
                             5);
# 1634 "read.c"
        fatal(flocp, (char const *)tmp___12, f->name);
        }
      }
# 1639 "read.c"
      if ((unsigned long )cmds != (unsigned long )((struct commands *)0)) {
# 1639 "read.c"
        if ((unsigned long )cmds == (unsigned long )f->cmds) {
          {
# 1640 "read.c"
          tmp___13 = dcgettext((char const *)((void *)0), "target `%s\' given more than once in the same rule.",
                               5);
# 1640 "read.c"
          error(flocp, (char const *)tmp___13, f->name);
          }
        } else {
# 1639 "read.c"
          goto _L;
        }
      } else
      _L:
# 1647 "read.c"
      if ((unsigned long )cmds != (unsigned long )((struct commands *)0)) {
# 1647 "read.c"
        if ((unsigned long )f->cmds != (unsigned long )((struct commands *)0)) {
# 1647 "read.c"
          if (f->is_target) {
            {
# 1649 "read.c"
            tmp___14 = dcgettext((char const *)((void *)0), "warning: overriding commands for target `%s\'",
                                 5);
# 1649 "read.c"
            error((struct floc const *)(& cmds->fileinfo), (char const *)tmp___14,
                  f->name);
# 1652 "read.c"
            tmp___15 = dcgettext((char const *)((void *)0), "warning: ignoring old commands for target `%s\'",
                                 5);
# 1652 "read.c"
            error((struct floc const *)(& (f->cmds)->fileinfo), (char const *)tmp___15,
                  f->name);
            }
          }
        }
      }
# 1657 "read.c"
      f->is_target = 1U;
# 1660 "read.c"
      if ((unsigned long )f == (unsigned long )default_file) {
# 1660 "read.c"
        if ((unsigned long )this == (unsigned long )((struct dep *)0)) {
# 1660 "read.c"
          if ((unsigned long )cmds == (unsigned long )((struct commands *)0)) {
# 1661 "read.c"
            f->cmds = (struct commands *)0;
          }
        }
      }
# 1662 "read.c"
      if ((unsigned long )cmds != (unsigned long )((struct commands *)0)) {
# 1663 "read.c"
        f->cmds = cmds;
      }
# 1666 "read.c"
      if ((unsigned long )f == (unsigned long )suffix_file) {
# 1666 "read.c"
        if ((unsigned long )this == (unsigned long )((struct dep *)0)) {
# 1668 "read.c"
          d = f->deps;
          {
# 1669 "read.c"
          while (1) {
            while_continue___1: ;
# 1669 "read.c"
            if (! ((unsigned long )d != (unsigned long )((struct dep *)0))) {
# 1669 "read.c"
              goto while_break___1;
            }
            {
# 1671 "read.c"
            nextd = d->next;
# 1672 "read.c"
            free((void *)d->name);
# 1673 "read.c"
            free((void *)((char *)d));
# 1674 "read.c"
            d = nextd;
            }
          }
          while_break___1: ;
          }
# 1676 "read.c"
          f->deps = (struct dep *)0;
        } else {
# 1666 "read.c"
          goto _L___0;
        }
      } else
      _L___0:
# 1678 "read.c"
      if ((unsigned long )f->deps != (unsigned long )((struct dep *)0)) {
# 1683 "read.c"
        if ((unsigned long )cmds != (unsigned long )((struct commands *)0)) {
# 1689 "read.c"
          firstdeps = this;
# 1690 "read.c"
          moredeps = f->deps;
        } else {
# 1695 "read.c"
          firstdeps = f->deps;
# 1696 "read.c"
          moredeps = this;
        }
# 1699 "read.c"
        if ((unsigned long )firstdeps == (unsigned long )((struct dep *)0)) {
# 1700 "read.c"
          firstdeps = moredeps;
        } else {
# 1703 "read.c"
          d = firstdeps;
          {
# 1704 "read.c"
          while (1) {
            while_continue___2: ;
# 1704 "read.c"
            if (! ((unsigned long )d->next != (unsigned long )((struct dep *)0))) {
# 1704 "read.c"
              goto while_break___2;
            }
# 1705 "read.c"
            d = d->next;
          }
          while_break___2: ;
          }
# 1706 "read.c"
          d->next = moredeps;
        }
# 1709 "read.c"
        f->deps = firstdeps;
      } else {
# 1712 "read.c"
        f->deps = this;
      }
# 1717 "read.c"
      if ((unsigned long )pattern != (unsigned long )((char *)0)) {
        {
# 1720 "read.c"
        tmp___16 = variable_expand((char *)"");
# 1720 "read.c"
        buffer___0 = tmp___16;
# 1721 "read.c"
        tmp___17 = patsubst_expand(buffer___0, name, pattern, percent___0, pattern_percent,
                                   percent___0);
# 1721 "read.c"
        o___0 = tmp___17;
# 1723 "read.c"
        f->stem = savestring((char const *)buffer___0, (unsigned int )(o___0 - buffer___0));
        }
      }
    } else {
      {
# 1730 "read.c"
      f = lookup_file(name);
      }
# 1733 "read.c"
      if ((unsigned long )f != (unsigned long )((struct file *)0)) {
# 1733 "read.c"
        if (f->is_target) {
# 1733 "read.c"
          if (! f->double_colon) {
            {
# 1734 "read.c"
            tmp___18 = dcgettext((char const *)((void *)0), "target file `%s\' has both : and :: entries",
                                 5);
# 1734 "read.c"
            fatal(flocp, (char const *)tmp___18, f->name);
            }
          }
        }
      }
      {
# 1736 "read.c"
      f = enter_file(name);
      }
# 1741 "read.c"
      if ((unsigned long )f->double_colon == (unsigned long )((struct file *)0)) {
# 1744 "read.c"
        f->double_colon = f;
      }
# 1745 "read.c"
      f->is_target = 1U;
# 1746 "read.c"
      f->deps = this;
# 1747 "read.c"
      f->cmds = cmds;
    }
# 1751 "read.c"
    if ((unsigned long )f != (unsigned long )((struct file *)0)) {
# 1751 "read.c"
      if ((unsigned long )name != (unsigned long )f->name) {
# 1751 "read.c"
        if ((unsigned long )name < (unsigned long )f->name) {
          {
# 1754 "read.c"
          free((void *)name);
# 1755 "read.c"
          name = f->name;
          }
        } else {
          {
# 1751 "read.c"
          tmp___19 = strlen((char const *)f->name);
          }
# 1751 "read.c"
          if ((unsigned long )name > (unsigned long )(f->name + tmp___19)) {
            {
# 1754 "read.c"
            free((void *)name);
# 1755 "read.c"
            name = f->name;
            }
          }
        }
      }
    }
# 1760 "read.c"
    if ((unsigned long )default_goal_file == (unsigned long )((struct file *)0)) {
# 1760 "read.c"
      if (set_default) {
# 1760 "read.c"
        if ((int )*name != 46) {
# 1760 "read.c"
          goto _L___1;
        } else {
          {
# 1760 "read.c"
          tmp___33 = strchr((char const *)name, '/');
          }
# 1760 "read.c"
          if ((unsigned long )tmp___33 != (unsigned long )((char *)0)) {
            _L___1:
# 1767 "read.c"
            reject = 0;
# 1772 "read.c"
            d = suffix_file->deps;
            {
# 1772 "read.c"
            while (1) {
              while_continue___3: ;
# 1772 "read.c"
              if (! ((unsigned long )d != (unsigned long )((struct dep *)0))) {
# 1772 "read.c"
                goto while_break___3;
              }
# 1775 "read.c"
              if ((unsigned long )d->name == (unsigned long )((char *)0)) {
# 1775 "read.c"
                tmp___20 = (d->file)->name;
              } else {
# 1775 "read.c"
                tmp___20 = d->name;
              }
# 1775 "read.c"
              if ((int )*tmp___20 != 46) {
# 1775 "read.c"
                if ((unsigned long )d->name == (unsigned long )((char *)0)) {
# 1775 "read.c"
                  tmp___21 = (d->file)->name;
                } else {
# 1775 "read.c"
                  tmp___21 = d->name;
                }
# 1775 "read.c"
                if ((unsigned long )name == (unsigned long )tmp___21) {
# 1777 "read.c"
                  reject = 1;
# 1778 "read.c"
                  goto while_break___3;
                } else {
# 1775 "read.c"
                  if ((unsigned long )d->name == (unsigned long )((char *)0)) {
# 1775 "read.c"
                    tmp___22 = (d->file)->name;
                  } else {
# 1775 "read.c"
                    tmp___22 = d->name;
                  }
# 1775 "read.c"
                  if ((int )*name == (int )*tmp___22) {
# 1775 "read.c"
                    if ((int )*name == 0) {
# 1777 "read.c"
                      reject = 1;
# 1778 "read.c"
                      goto while_break___3;
                    } else {
# 1775 "read.c"
                      if ((unsigned long )d->name == (unsigned long )((char *)0)) {
# 1775 "read.c"
                        tmp___23 = (d->file)->name;
                      } else {
# 1775 "read.c"
                        tmp___23 = d->name;
                      }
                      {
# 1775 "read.c"
                      tmp___24 = strcmp((char const *)(name + 1), (char const *)(tmp___23 + 1));
                      }
# 1775 "read.c"
                      if (! tmp___24) {
# 1777 "read.c"
                        reject = 1;
# 1778 "read.c"
                        goto while_break___3;
                      }
                    }
                  }
                }
              }
# 1780 "read.c"
              d2 = suffix_file->deps;
              {
# 1780 "read.c"
              while (1) {
                while_continue___4: ;
# 1780 "read.c"
                if (! ((unsigned long )d2 != (unsigned long )((struct dep *)0))) {
# 1780 "read.c"
                  goto while_break___4;
                }
# 1782 "read.c"
                if ((unsigned long )d2->name == (unsigned long )((char *)0)) {
# 1782 "read.c"
                  tmp___25 = (d2->file)->name;
                } else {
# 1782 "read.c"
                  tmp___25 = d2->name;
                }
                {
# 1782 "read.c"
                tmp___26 = strlen((char const *)tmp___25);
# 1782 "read.c"
                len = (unsigned int )tmp___26;
                }
# 1783 "read.c"
                if ((unsigned long )d2->name == (unsigned long )((char *)0)) {
# 1783 "read.c"
                  tmp___27 = (d2->file)->name;
                } else {
# 1783 "read.c"
                  tmp___27 = d2->name;
                }
                {
# 1783 "read.c"
                tmp___28 = strncmp((char const *)name, (char const *)tmp___27,
                                   (size_t )len);
                }
# 1783 "read.c"
                if (! (tmp___28 == 0)) {
# 1784 "read.c"
                  goto __Cont___1;
                }
# 1785 "read.c"
                if ((unsigned long )d->name == (unsigned long )((char *)0)) {
# 1785 "read.c"
                  tmp___29 = (d->file)->name;
                } else {
# 1785 "read.c"
                  tmp___29 = d->name;
                }
# 1785 "read.c"
                if ((unsigned long )(name + len) == (unsigned long )tmp___29) {
# 1787 "read.c"
                  reject = 1;
# 1788 "read.c"
                  goto while_break___4;
                } else {
# 1785 "read.c"
                  if ((unsigned long )d->name == (unsigned long )((char *)0)) {
# 1785 "read.c"
                    tmp___30 = (d->file)->name;
                  } else {
# 1785 "read.c"
                    tmp___30 = d->name;
                  }
# 1785 "read.c"
                  if ((int )*(name + len) == (int )*tmp___30) {
# 1785 "read.c"
                    if ((int )*(name + len) == 0) {
# 1787 "read.c"
                      reject = 1;
# 1788 "read.c"
                      goto while_break___4;
                    } else {
# 1785 "read.c"
                      if ((unsigned long )d->name == (unsigned long )((char *)0)) {
# 1785 "read.c"
                        tmp___31 = (d->file)->name;
                      } else {
# 1785 "read.c"
                        tmp___31 = d->name;
                      }
                      {
# 1785 "read.c"
                      tmp___32 = strcmp((char const *)((name + len) + 1), (char const *)(tmp___31 + 1));
                      }
# 1785 "read.c"
                      if (! tmp___32) {
# 1787 "read.c"
                        reject = 1;
# 1788 "read.c"
                        goto while_break___4;
                      }
                    }
                  }
                }
                __Cont___1:
# 1780 "read.c"
                d2 = d2->next;
              }
              while_break___4: ;
              }
# 1791 "read.c"
              if (reject) {
# 1792 "read.c"
                goto while_break___3;
              }
# 1772 "read.c"
              d = d->next;
            }
            while_break___3: ;
            }
# 1795 "read.c"
            if (! reject) {
# 1796 "read.c"
              default_goal_file = f;
            }
          }
        }
      }
    }
    __Cont:
# 1537 "read.c"
    filenames = nextf;
  }
  while_break: ;
  }
# 1800 "read.c"
  if (implicit) {
    {
# 1802 "read.c"
    *(targets + target_idx) = (char *)0;
# 1803 "read.c"
    *(target_percents + target_idx) = (char *)0;
# 1804 "read.c"
    create_pattern_rule(targets, target_percents, two_colon, deps, cmds, 1);
# 1805 "read.c"
    free((void *)((char *)target_percents));
    }
  }
# 1807 "read.c"
  return;
}
}
# 1815 "read.c"
char *find_char_unquote(char *string___0 , char *stopchars , int blank )
{
  unsigned int string_len ;
  register char *p ;
  char *tmp ;
  unsigned short const **tmp___0 ;
  register int i ;
  size_t tmp___1 ;

  {
# 1821 "read.c"
  string_len = 0U;
# 1822 "read.c"
  p = string___0;
  {
# 1824 "read.c"
  while (1) {
    while_continue: ;
    {
# 1826 "read.c"
    while (1) {
      while_continue___0: ;
# 1826 "read.c"
      if ((int )*p != 0) {
        {
# 1826 "read.c"
        tmp = strchr((char const *)stopchars, (int )*p);
        }
# 1826 "read.c"
        if ((unsigned long )tmp == (unsigned long )((char *)0)) {
# 1826 "read.c"
          if (! (! blank)) {
            {
# 1826 "read.c"
            tmp___0 = __ctype_b_loc();
            }
# 1826 "read.c"
            if ((int const )*(*tmp___0 + (int )*p) & 1) {
# 1826 "read.c"
              goto while_break___0;
            }
          }
        } else {
# 1826 "read.c"
          goto while_break___0;
        }
      } else {
# 1826 "read.c"
        goto while_break___0;
      }
# 1828 "read.c"
      p ++;
    }
    while_break___0: ;
    }
# 1829 "read.c"
    if ((int )*p == 0) {
# 1830 "read.c"
      goto while_break;
    }
# 1832 "read.c"
    if ((unsigned long )p > (unsigned long )string___0) {
# 1832 "read.c"
      if ((int )*(p + -1) == 92) {
# 1835 "read.c"
        i = -2;
        {
# 1836 "read.c"
        while (1) {
          while_continue___1: ;
# 1836 "read.c"
          if ((unsigned long )(p + i) >= (unsigned long )string___0) {
# 1836 "read.c"
            if (! ((int )*(p + i) == 92)) {
# 1836 "read.c"
              goto while_break___1;
            }
          } else {
# 1836 "read.c"
            goto while_break___1;
          }
# 1837 "read.c"
          i --;
        }
        while_break___1: ;
        }
# 1838 "read.c"
        i ++;
# 1840 "read.c"
        if (string_len == 0U) {
          {
# 1841 "read.c"
          tmp___1 = strlen((char const *)string___0);
# 1841 "read.c"
          string_len = (unsigned int )tmp___1;
          }
        }
        {
# 1844 "read.c"
        memmove((void *)(p + i), (void const *)(p + i / 2), (size_t )((((long )string_len - (p - string___0)) - (long )(i / 2)) + 1L));
# 1845 "read.c"
        p += i / 2;
        }
# 1846 "read.c"
        if (i % 2 == 0) {
# 1849 "read.c"
          return (p);
        }
      } else {
# 1855 "read.c"
        return (p);
      }
    } else {
# 1855 "read.c"
      return (p);
    }
  }
  while_break: ;
  }
# 1859 "read.c"
  return ((char *)0);
}
}
# 1864 "read.c"
char *find_percent(char *pattern )
{
  char *tmp ;

  {
  {
# 1868 "read.c"
  tmp = find_char_unquote(pattern, (char *)"%", 0);
  }
# 1868 "read.c"
  return (tmp);
}
}
# 1884 "read.c"
struct nameseq *parse_file_seq(char **stringp , int stopchar , unsigned int size ,
                               int strip )
{
  register struct nameseq *new ;
  register struct nameseq *new1 ;
  register struct nameseq *lastnew1 ;
  register char *p ;
  char *q ;
  char *name ;
  char stopchars[3] ;
  size_t tmp ;
  char *tmp___0 ;
  struct nameseq *n ;
  struct nameseq *lastn ;
  char *paren ;
  char *libname ;
  void *tmp___1 ;
  size_t tmp___2 ;
  char *tmp___3 ;

  {
# 1891 "read.c"
  new = (struct nameseq *)0;
# 1893 "read.c"
  p = *stringp;
# 1903 "read.c"
  stopchars[0] = (char )stopchar;
# 1904 "read.c"
  stopchars[1] = (char )'\000';
  {
# 1907 "read.c"
  while (1) {
    while_continue: ;
    {
# 1910 "read.c"
    p = next_token(p);
    }
# 1911 "read.c"
    if ((int )*p == 0) {
# 1912 "read.c"
      goto while_break;
    }
# 1913 "read.c"
    if ((int )*p == stopchar) {
# 1914 "read.c"
      goto while_break;
    }
    {
# 1917 "read.c"
    q = p;
# 1918 "read.c"
    p = find_char_unquote(q, stopchars, 1);
    }
# 1942 "read.c"
    if ((unsigned long )p == (unsigned long )((char *)0)) {
      {
# 1943 "read.c"
      tmp = strlen((char const *)q);
# 1943 "read.c"
      p = q + tmp;
      }
    }
# 1945 "read.c"
    if (strip) {
      {
# 1951 "read.c"
      while (1) {
        while_continue___0: ;
# 1951 "read.c"
        if (p - q > 2L) {
# 1951 "read.c"
          if ((int )*(q + 0) == 46) {
# 1951 "read.c"
            if (! ((int )*(q + 1) == 47)) {
# 1951 "read.c"
              goto while_break___0;
            }
          } else {
# 1951 "read.c"
            goto while_break___0;
          }
        } else {
# 1951 "read.c"
          goto while_break___0;
        }
# 1954 "read.c"
        q += 2;
        {
# 1955 "read.c"
        while (1) {
          while_continue___1: ;
# 1955 "read.c"
          if ((unsigned long )q < (unsigned long )p) {
# 1955 "read.c"
            if (! ((int )*q == 47)) {
# 1955 "read.c"
              goto while_break___1;
            }
          } else {
# 1955 "read.c"
            goto while_break___1;
          }
# 1957 "read.c"
          q ++;
        }
        while_break___1: ;
        }
      }
      while_break___0: ;
      }
    }
# 1962 "read.c"
    if ((unsigned long )q == (unsigned long )p) {
      {
# 1970 "read.c"
      name = savestring("./", 2U);
      }
    } else {
      {
# 1999 "read.c"
      name = savestring((char const *)q, (unsigned int )(p - q));
      }
    }
    {
# 2003 "read.c"
    tmp___0 = xmalloc(size);
# 2003 "read.c"
    new1 = (struct nameseq *)tmp___0;
# 2004 "read.c"
    new1->name = name;
# 2005 "read.c"
    new1->next = new;
# 2006 "read.c"
    new = new1;
    }
  }
  while_break: ;
  }
# 2016 "read.c"
  new1 = new;
# 2017 "read.c"
  lastnew1 = (struct nameseq *)0;
  {
# 2018 "read.c"
  while (1) {
    while_continue___2: ;
# 2018 "read.c"
    if (! ((unsigned long )new1 != (unsigned long )((struct nameseq *)0))) {
# 2018 "read.c"
      goto while_break___2;
    }
# 2019 "read.c"
    if ((int )*(new1->name + 0) != 40) {
      {
# 2019 "read.c"
      tmp___2 = strlen((char const *)new1->name);
      }
# 2019 "read.c"
      if ((int )*(new1->name + (tmp___2 - 1UL)) == 41) {
        {
# 2019 "read.c"
        tmp___3 = strchr((char const *)new1->name, '(');
        }
# 2019 "read.c"
        if ((unsigned long )tmp___3 == (unsigned long )((char *)0)) {
# 2026 "read.c"
          n = new1->next;
# 2026 "read.c"
          lastn = new1;
# 2027 "read.c"
          paren = (char *)0;
          {
# 2028 "read.c"
          while (1) {
            while_continue___3: ;
# 2028 "read.c"
            if ((unsigned long )n != (unsigned long )((struct nameseq *)0)) {
              {
# 2028 "read.c"
              paren = strchr((char const *)n->name, '(');
              }
# 2028 "read.c"
              if (! ((unsigned long )paren == (unsigned long )((char *)0))) {
# 2028 "read.c"
                goto while_break___3;
              }
            } else {
# 2028 "read.c"
              goto while_break___3;
            }
# 2030 "read.c"
            lastn = n;
# 2031 "read.c"
            n = n->next;
          }
          while_break___3: ;
          }
# 2033 "read.c"
          if ((unsigned long )n != (unsigned long )((struct nameseq *)0)) {
# 2033 "read.c"
            if ((int )*(n->name + 0) != 40) {
              {
# 2045 "read.c"
              paren ++;
# 2046 "read.c"
              tmp___1 = __builtin_alloca((unsigned long )((paren - n->name) + 1L));
# 2046 "read.c"
              libname = (char *)tmp___1;
# 2047 "read.c"
              memmove((void *)libname, (void const *)n->name, (size_t )(paren - n->name));
# 2048 "read.c"
              *(libname + (paren - n->name)) = (char )'\000';
              }
# 2050 "read.c"
              if ((int )*paren == 0) {
                {
# 2054 "read.c"
                lastn->next = n->next;
# 2055 "read.c"
                free((void *)n->name);
# 2056 "read.c"
                free((void *)((char *)n));
# 2058 "read.c"
                n = lastn->next;
                }
              } else {
                {
# 2063 "read.c"
                name = concat(libname, paren, (char *)")");
# 2064 "read.c"
                free((void *)n->name);
# 2065 "read.c"
                n->name = name;
                }
              }
# 2068 "read.c"
              if ((int )*(new1->name + 1) == 0) {
# 2072 "read.c"
                if ((unsigned long )lastnew1 == (unsigned long )((struct nameseq *)0)) {
# 2073 "read.c"
                  new = new1->next;
                } else {
# 2075 "read.c"
                  lastnew1->next = new1->next;
                }
                {
# 2076 "read.c"
                lastn = new1;
# 2077 "read.c"
                new1 = new1->next;
# 2078 "read.c"
                free((void *)lastn->name);
# 2079 "read.c"
                free((void *)((char *)lastn));
                }
              } else {
                {
# 2084 "read.c"
                name = concat(libname, new1->name, (char *)"");
# 2085 "read.c"
                free((void *)new1->name);
# 2086 "read.c"
                new1->name = name;
# 2087 "read.c"
                new1 = new1->next;
                }
              }
              {
# 2094 "read.c"
              while (1) {
                while_continue___4: ;
# 2094 "read.c"
                if (! ((unsigned long )new1 != (unsigned long )n)) {
# 2094 "read.c"
                  goto while_break___4;
                }
                {
# 2096 "read.c"
                name = concat(libname, new1->name, (char *)")");
# 2097 "read.c"
                free((void *)new1->name);
# 2098 "read.c"
                new1->name = name;
# 2099 "read.c"
                lastnew1 = new1;
# 2100 "read.c"
                new1 = new1->next;
                }
              }
              while_break___4: ;
              }
            } else {
# 2106 "read.c"
              lastnew1 = new1;
# 2107 "read.c"
              new1 = new1->next;
            }
          } else {
# 2106 "read.c"
            lastnew1 = new1;
# 2107 "read.c"
            new1 = new1->next;
          }
        } else {
# 2112 "read.c"
          lastnew1 = new1;
# 2113 "read.c"
          new1 = new1->next;
        }
      } else {
# 2112 "read.c"
        lastnew1 = new1;
# 2113 "read.c"
        new1 = new1->next;
      }
    } else {
# 2112 "read.c"
      lastnew1 = new1;
# 2113 "read.c"
      new1 = new1->next;
    }
  }
  while_break___2: ;
  }
# 2118 "read.c"
  *stringp = p;
# 2119 "read.c"
  return (new);
}
}
# 2127 "read.c"
static unsigned long readline(struct linebuffer *linebuffer , FILE *stream , struct floc const *flocp )
{
  char *buffer ;
  register char *p ;
  register char *end ;
  register int len ;
  register int lastlen ;
  register char *p2 ;
  register unsigned int nlines ;
  register int backslash ;
  size_t tmp ;
  char *tmp___0 ;
  register unsigned int p_off ;
  char *tmp___1 ;
  register unsigned int p_off___0 ;
  char *tmp___2 ;
  char *tmp___3 ;
  int tmp___4 ;

  {
# 2133 "read.c"
  buffer = linebuffer->buffer;
# 2134 "read.c"
  p = linebuffer->buffer;
# 2135 "read.c"
  end = p + linebuffer->size;
# 2136 "read.c"
  lastlen = 0;
# 2138 "read.c"
  nlines = 0U;
# 2141 "read.c"
  *p = (char )'\000';
  {
# 2143 "read.c"
  while (1) {
    while_continue: ;
    {
# 2143 "read.c"
    tmp___3 = fgets((char * __restrict )p, (int )(end - p), (FILE * __restrict )stream);
    }
# 2143 "read.c"
    if (! ((unsigned long )tmp___3 != (unsigned long )((char *)0))) {
# 2143 "read.c"
      goto while_break;
    }
    {
# 2145 "read.c"
    tmp = strlen((char const *)p);
# 2145 "read.c"
    len = (int )tmp;
    }
# 2146 "read.c"
    if (len == 0) {
      {
# 2153 "read.c"
      tmp___0 = dcgettext((char const *)((void *)0), "warning: NUL character seen; rest of line ignored",
                          5);
# 2153 "read.c"
      error(flocp, (char const *)tmp___0);
# 2154 "read.c"
      *(p + 0) = (char )'\n';
# 2155 "read.c"
      len = 1;
      }
    }
# 2158 "read.c"
    p += len;
# 2159 "read.c"
    if ((int )*(p + -1) != 10) {
      {
# 2162 "read.c"
      p_off = (unsigned int )(p - buffer);
# 2163 "read.c"
      linebuffer->size *= 2U;
# 2164 "read.c"
      tmp___1 = xrealloc(buffer, linebuffer->size);
# 2164 "read.c"
      buffer = tmp___1;
# 2165 "read.c"
      p = buffer + p_off;
# 2166 "read.c"
      end = buffer + linebuffer->size;
# 2167 "read.c"
      linebuffer->buffer = buffer;
# 2168 "read.c"
      *p = (char )'\000';
# 2169 "read.c"
      lastlen = len;
      }
# 2170 "read.c"
      goto while_continue;
    }
# 2173 "read.c"
    nlines ++;
# 2178 "read.c"
    if (len > 1) {
# 2178 "read.c"
      if ((int )*(p + -2) == 13) {
# 2180 "read.c"
        len --;
# 2181 "read.c"
        p --;
# 2182 "read.c"
        *(p + -1) = (char )'\n';
      }
    }
# 2186 "read.c"
    if (len == 1) {
# 2186 "read.c"
      if ((unsigned long )p > (unsigned long )buffer) {
# 2194 "read.c"
        len += lastlen;
      }
    }
# 2195 "read.c"
    lastlen = len;
# 2196 "read.c"
    backslash = 0;
# 2197 "read.c"
    p2 = p - 2;
    {
# 2197 "read.c"
    while (1) {
      while_continue___0: ;
# 2197 "read.c"
      len --;
# 2197 "read.c"
      if (! (len > 0)) {
# 2197 "read.c"
        goto while_break___0;
      }
# 2199 "read.c"
      if ((int )*p2 == 92) {
# 2200 "read.c"
        backslash = ! backslash;
      } else {
# 2202 "read.c"
        goto while_break___0;
      }
# 2197 "read.c"
      p2 --;
    }
    while_break___0: ;
    }
# 2205 "read.c"
    if (! backslash) {
# 2207 "read.c"
      *(p + -1) = (char )'\000';
# 2208 "read.c"
      goto while_break;
    }
# 2211 "read.c"
    if (end - p <= 1L) {
      {
# 2214 "read.c"
      p_off___0 = (unsigned int )(p - buffer);
# 2215 "read.c"
      linebuffer->size *= 2U;
# 2216 "read.c"
      tmp___2 = xrealloc(buffer, linebuffer->size);
# 2216 "read.c"
      buffer = tmp___2;
# 2217 "read.c"
      p = buffer + p_off___0;
# 2218 "read.c"
      end = buffer + linebuffer->size;
# 2219 "read.c"
      linebuffer->buffer = buffer;
      }
    }
  }
  while_break: ;
  }
  {
# 2223 "read.c"
  tmp___4 = ferror(stream);
  }
# 2223 "read.c"
  if (tmp___4) {
    {
# 2224 "read.c"
    pfatal_with_name((char *)flocp->filenm);
    }
  }
# 2226 "read.c"
  return ((unsigned long )nlines);
}
}
# 2248 "read.c"
static enum make_word_type get_next_mword(char *buffer , char *delim , char **startp ,
                                          unsigned int *length___0 )
{
  enum make_word_type wtype ;
  char *p ;
  char *beg ;
  char c ;
  unsigned short const **tmp ;
  char *tmp___0 ;
  char *tmp___1 ;
  char closeparen ;
  int count ;
  char *tmp___2 ;
  char *tmp___3 ;
  char *tmp___4 ;

  {
# 2255 "read.c"
  wtype = (enum make_word_type )0;
# 2256 "read.c"
  p = buffer;
  {
# 2260 "read.c"
  while (1) {
    while_continue: ;
    {
# 2260 "read.c"
    tmp = __ctype_b_loc();
    }
# 2260 "read.c"
    if (! ((int const )*(*tmp + (int )*p) & 1)) {
# 2260 "read.c"
      goto while_break;
    }
# 2261 "read.c"
    p ++;
  }
  while_break: ;
  }
# 2263 "read.c"
  beg = p;
# 2264 "read.c"
  tmp___0 = p;
# 2264 "read.c"
  p ++;
# 2264 "read.c"
  c = *tmp___0;
  {
# 2266 "read.c"
  if ((int )c == 0) {
# 2266 "read.c"
    goto case_0;
  }
# 2270 "read.c"
  if ((int )c == 35) {
# 2270 "read.c"
    goto case_35;
  }
# 2274 "read.c"
  if ((int )c == 59) {
# 2274 "read.c"
    goto case_59;
  }
# 2278 "read.c"
  if ((int )c == 61) {
# 2278 "read.c"
    goto case_61;
  }
# 2282 "read.c"
  if ((int )c == 58) {
# 2282 "read.c"
    goto case_58;
  }
# 2299 "read.c"
  if ((int )c == 43) {
# 2299 "read.c"
    goto case_43;
  }
# 2299 "read.c"
  if ((int )c == 63) {
# 2299 "read.c"
    goto case_43;
  }
# 2307 "read.c"
  goto switch_default;
  case_0:
# 2268 "read.c"
  wtype = (enum make_word_type )1;
# 2269 "read.c"
  goto switch_break;
  case_35:
# 2272 "read.c"
  wtype = (enum make_word_type )7;
# 2273 "read.c"
  goto switch_break;
  case_59:
# 2276 "read.c"
  wtype = (enum make_word_type )6;
# 2277 "read.c"
  goto switch_break;
  case_61:
# 2280 "read.c"
  wtype = (enum make_word_type )8;
# 2281 "read.c"
  goto switch_break;
  case_58:
# 2284 "read.c"
  wtype = (enum make_word_type )4;
  {
# 2286 "read.c"
  if ((int )*p == 58) {
# 2286 "read.c"
    goto case_58___0;
  }
# 2291 "read.c"
  if ((int )*p == 61) {
# 2291 "read.c"
    goto case_61___0;
  }
# 2285 "read.c"
  goto switch_break___0;
  case_58___0:
# 2288 "read.c"
  p ++;
# 2289 "read.c"
  wtype = (enum make_word_type )5;
# 2290 "read.c"
  goto switch_break___0;
  case_61___0:
# 2293 "read.c"
  p ++;
# 2294 "read.c"
  wtype = (enum make_word_type )8;
# 2295 "read.c"
  goto switch_break___0;
  switch_break___0: ;
  }
# 2297 "read.c"
  goto switch_break;
  case_43:
  case_63:
# 2301 "read.c"
  if ((int )*p == 61) {
# 2303 "read.c"
    p ++;
# 2304 "read.c"
    wtype = (enum make_word_type )8;
# 2305 "read.c"
    goto switch_break;
  }
  switch_default:
# 2309 "read.c"
  if (delim) {
    {
# 2309 "read.c"
    tmp___1 = strchr((char const *)delim, (int )c);
    }
# 2309 "read.c"
    if (tmp___1) {
# 2310 "read.c"
      wtype = (enum make_word_type )2;
    }
  }
# 2311 "read.c"
  goto switch_break;
  switch_break: ;
  }
# 2315 "read.c"
  if ((unsigned int )wtype != 0U) {
# 2316 "read.c"
    goto done;
  }
# 2324 "read.c"
  wtype = (enum make_word_type )2;
  {
# 2327 "read.c"
  while (1) {
    while_continue___0: ;
    {
# 2337 "read.c"
    if ((int )c == 0) {
# 2337 "read.c"
      goto case_0___0;
    }
# 2337 "read.c"
    if ((int )c == 32) {
# 2337 "read.c"
      goto case_0___0;
    }
# 2337 "read.c"
    if ((int )c == 9) {
# 2337 "read.c"
      goto case_0___0;
    }
# 2337 "read.c"
    if ((int )c == 61) {
# 2337 "read.c"
      goto case_0___0;
    }
# 2337 "read.c"
    if ((int )c == 35) {
# 2337 "read.c"
      goto case_0___0;
    }
# 2340 "read.c"
    if ((int )c == 58) {
# 2340 "read.c"
      goto case_58___1;
    }
# 2351 "read.c"
    if ((int )c == 36) {
# 2351 "read.c"
      goto case_36;
    }
# 2381 "read.c"
    if ((int )c == 63) {
# 2381 "read.c"
      goto case_63___0;
    }
# 2381 "read.c"
    if ((int )c == 43) {
# 2381 "read.c"
      goto case_63___0;
    }
# 2386 "read.c"
    if ((int )c == 92) {
# 2386 "read.c"
      goto case_92;
    }
# 2398 "read.c"
    goto switch_default___0;
    case_0___0:
    case_32:
    case_9:
    case_61___1:
    case_35___0:
# 2339 "read.c"
    goto done_word;
    case_58___1:
# 2350 "read.c"
    goto done_word;
    case_36:
# 2353 "read.c"
    tmp___2 = p;
# 2353 "read.c"
    p ++;
# 2353 "read.c"
    c = *tmp___2;
# 2354 "read.c"
    if ((int )c == 36) {
# 2355 "read.c"
      goto switch_break___1;
    }
# 2359 "read.c"
    wtype = (enum make_word_type )3;
# 2361 "read.c"
    if ((int )c == 40) {
# 2362 "read.c"
      closeparen = (char )')';
    } else
# 2363 "read.c"
    if ((int )c == 123) {
# 2364 "read.c"
      closeparen = (char )'}';
    } else {
# 2367 "read.c"
      goto switch_break___1;
    }
# 2369 "read.c"
    count = 0;
    {
# 2369 "read.c"
    while (1) {
      while_continue___1: ;
# 2369 "read.c"
      if (! ((int )*p != 0)) {
# 2369 "read.c"
        goto while_break___1;
      }
# 2371 "read.c"
      if ((int )*p == (int )c) {
# 2372 "read.c"
        count ++;
      } else
# 2373 "read.c"
      if ((int )*p == (int )closeparen) {
# 2373 "read.c"
        count --;
# 2373 "read.c"
        if (count < 0) {
# 2375 "read.c"
          p ++;
# 2376 "read.c"
          goto while_break___1;
        }
      }
# 2369 "read.c"
      p ++;
    }
    while_break___1: ;
    }
# 2379 "read.c"
    goto switch_break___1;
    case_63___0:
    case_43___0:
# 2383 "read.c"
    if ((int )*p == 61) {
# 2384 "read.c"
      goto done_word;
    }
# 2385 "read.c"
    goto switch_break___1;
    case_92:
    {
# 2392 "read.c"
    if ((int )*p == 58) {
# 2392 "read.c"
      goto case_58___2;
    }
# 2392 "read.c"
    if ((int )*p == 59) {
# 2392 "read.c"
      goto case_58___2;
    }
# 2392 "read.c"
    if ((int )*p == 61) {
# 2392 "read.c"
      goto case_58___2;
    }
# 2392 "read.c"
    if ((int )*p == 92) {
# 2392 "read.c"
      goto case_58___2;
    }
# 2388 "read.c"
    goto switch_break___2;
    case_58___2:
    case_59___0:
    case_61___2:
    case_92___0:
# 2394 "read.c"
    p ++;
# 2395 "read.c"
    goto switch_break___2;
    switch_break___2: ;
    }
# 2397 "read.c"
    goto switch_break___1;
    switch_default___0:
# 2400 "read.c"
    if (delim) {
      {
# 2400 "read.c"
      tmp___3 = strchr((char const *)delim, (int )c);
      }
# 2400 "read.c"
      if (tmp___3) {
# 2401 "read.c"
        goto done_word;
      }
    }
# 2402 "read.c"
    goto switch_break___1;
    switch_break___1: ;
    }
# 2405 "read.c"
    tmp___4 = p;
# 2405 "read.c"
    p ++;
# 2405 "read.c"
    c = *tmp___4;
  }
  while_break___0: ;
  }
  done_word:
# 2408 "read.c"
  p --;
  done:
# 2411 "read.c"
  if (startp) {
# 2412 "read.c"
    *startp = beg;
  }
# 2413 "read.c"
  if (length___0) {
# 2414 "read.c"
    *length___0 = (unsigned int )(p - beg);
  }
# 2415 "read.c"
  return (wtype);
}
}
# 2421 "read.c"
void construct_include_path(char **arg_dirs )
{
  register unsigned int i ;
  struct stat stbuf ;
  register unsigned int defsize ;
  register unsigned int max ;
  register char **dirs___0 ;
  char *tmp ;
  register unsigned int idx ;
  char *dir ;
  char **tmp___0 ;
  char *expanded ;
  char *tmp___1 ;
  char *tmp___2 ;
  unsigned int tmp___3 ;
  int tmp___4 ;
  unsigned int tmp___5 ;
  int tmp___6 ;
  unsigned int len ;
  size_t tmp___7 ;

  {
  {
# 2433 "read.c"
  defsize = (unsigned int )(sizeof(default_include_directories) / sizeof(default_include_directories[0]));
# 2435 "read.c"
  max = 5U;
# 2436 "read.c"
  tmp = xmalloc((unsigned int )((unsigned long )(5U + defsize) * sizeof(char *)));
# 2436 "read.c"
  dirs___0 = (char **)tmp;
# 2437 "read.c"
  idx = 0U;
  }
# 2446 "read.c"
  if ((unsigned long )arg_dirs != (unsigned long )((char **)0)) {
    {
# 2447 "read.c"
    while (1) {
      while_continue: ;
# 2447 "read.c"
      if (! ((unsigned long )*arg_dirs != (unsigned long )((char *)0))) {
# 2447 "read.c"
        goto while_break;
      }
# 2449 "read.c"
      tmp___0 = arg_dirs;
# 2449 "read.c"
      arg_dirs ++;
# 2449 "read.c"
      dir = *tmp___0;
# 2451 "read.c"
      if ((int )*(dir + 0) == 126) {
        {
# 2453 "read.c"
        tmp___1 = tilde_expand(dir);
# 2453 "read.c"
        expanded = tmp___1;
        }
# 2454 "read.c"
        if ((unsigned long )expanded != (unsigned long )((char *)0)) {
# 2455 "read.c"
          dir = expanded;
        }
      }
      {
# 2458 "read.c"
      tmp___4 = stat((char const * __restrict )dir, (struct stat * __restrict )(& stbuf));
      }
# 2458 "read.c"
      if (tmp___4 == 0) {
# 2458 "read.c"
        if ((stbuf.st_mode & 61440U) == 16384U) {
# 2460 "read.c"
          if (idx == max - 1U) {
            {
# 2462 "read.c"
            max += 5U;
# 2463 "read.c"
            tmp___2 = xrealloc((char *)dirs___0, (unsigned int )((unsigned long )(max + defsize) * sizeof(char *)));
# 2463 "read.c"
            dirs___0 = (char **)tmp___2;
            }
          }
# 2466 "read.c"
          tmp___3 = idx;
# 2466 "read.c"
          idx ++;
# 2466 "read.c"
          *(dirs___0 + tmp___3) = dir;
        } else {
# 2458 "read.c"
          goto _L;
        }
      } else
      _L:
# 2468 "read.c"
      if ((unsigned long )dir != (unsigned long )*(arg_dirs + -1)) {
        {
# 2469 "read.c"
        free((void *)dir);
        }
      }
    }
    while_break: ;
    }
  }
# 2490 "read.c"
  i = 0U;
  {
# 2490 "read.c"
  while (1) {
    while_continue___0: ;
# 2490 "read.c"
    if (! ((unsigned long )default_include_directories[i] != (unsigned long )((char *)0))) {
# 2490 "read.c"
      goto while_break___0;
    }
    {
# 2491 "read.c"
    tmp___6 = stat((char const * __restrict )default_include_directories[i], (struct stat * __restrict )(& stbuf));
    }
# 2491 "read.c"
    if (tmp___6 == 0) {
# 2491 "read.c"
      if ((stbuf.st_mode & 61440U) == 16384U) {
# 2493 "read.c"
        tmp___5 = idx;
# 2493 "read.c"
        idx ++;
# 2493 "read.c"
        *(dirs___0 + tmp___5) = default_include_directories[i];
      }
    }
# 2490 "read.c"
    i ++;
  }
  while_break___0: ;
  }
# 2495 "read.c"
  *(dirs___0 + idx) = (char *)0;
# 2499 "read.c"
  max_incl_len = 0U;
# 2500 "read.c"
  i = 0U;
  {
# 2500 "read.c"
  while (1) {
    while_continue___1: ;
# 2500 "read.c"
    if (! (i < idx)) {
# 2500 "read.c"
      goto while_break___1;
    }
    {
# 2502 "read.c"
    tmp___7 = strlen((char const *)*(dirs___0 + i));
# 2502 "read.c"
    len = (unsigned int )tmp___7;
    }
# 2504 "read.c"
    if ((int )*(*(dirs___0 + i) + (len - 1U)) == 47) {
      {
# 2507 "read.c"
      *(dirs___0 + i) = savestring((char const *)*(dirs___0 + i), len - 1U);
      }
    }
# 2508 "read.c"
    if (len > max_incl_len) {
# 2509 "read.c"
      max_incl_len = len;
    }
# 2500 "read.c"
    i ++;
  }
  while_break___1: ;
  }
# 2512 "read.c"
  include_directories___0 = dirs___0;
# 2513 "read.c"
  return;
}
}
# 2518 "read.c"
char *tilde_expand(char *name )
{
  char *home_dir ;
  int is_variable ;
  int save ;
  char *logname ;
  char *tmp ;
  struct passwd *p ;
  struct passwd *tmp___0 ;
  char *new ;
  char *tmp___1 ;
  struct passwd *pwent ;
  char *userend ;
  char *tmp___2 ;
  char *tmp___3 ;
  char *tmp___4 ;

  {
# 2523 "read.c"
  if ((int )*(name + 1) == 47) {
# 2523 "read.c"
    goto _L___0;
  } else
# 2523 "read.c"
  if ((int )*(name + 1) == 0) {
    _L___0:
    {
# 2531 "read.c"
    save = warn_undefined_variables_flag;
# 2532 "read.c"
    warn_undefined_variables_flag = 0;
# 2534 "read.c"
    home_dir = allocated_variable_expand_for_file((char *)"$(HOME)", (struct file *)0);
# 2536 "read.c"
    warn_undefined_variables_flag = save;
# 2539 "read.c"
    is_variable = (int )*(home_dir + 0) != 0;
    }
# 2540 "read.c"
    if (! is_variable) {
      {
# 2542 "read.c"
      free((void *)home_dir);
# 2543 "read.c"
      home_dir = getenv("HOME");
      }
    }
# 2546 "read.c"
    if ((unsigned long )home_dir == (unsigned long )((char *)0)) {
# 2546 "read.c"
      goto _L;
    } else
# 2546 "read.c"
    if ((int )*(home_dir + 0) == 0) {
      _L:
      {
# 2549 "read.c"
      tmp = getlogin();
# 2549 "read.c"
      logname = tmp;
# 2550 "read.c"
      home_dir = (char *)0;
      }
# 2551 "read.c"
      if ((unsigned long )logname != (unsigned long )((char *)0)) {
        {
# 2553 "read.c"
        tmp___0 = getpwnam((char const *)logname);
# 2553 "read.c"
        p = tmp___0;
        }
# 2554 "read.c"
        if ((unsigned long )p != (unsigned long )((struct passwd *)0)) {
# 2555 "read.c"
          home_dir = p->pw_dir;
        }
      }
    }
# 2559 "read.c"
    if ((unsigned long )home_dir != (unsigned long )((char *)0)) {
      {
# 2561 "read.c"
      tmp___1 = concat(home_dir, (char *)"", name + 1);
# 2561 "read.c"
      new = tmp___1;
      }
# 2562 "read.c"
      if (is_variable) {
        {
# 2563 "read.c"
        free((void *)home_dir);
        }
      }
# 2564 "read.c"
      return (new);
    }
  } else {
    {
# 2571 "read.c"
    tmp___2 = strchr((char const *)(name + 1), '/');
# 2571 "read.c"
    userend = tmp___2;
    }
# 2572 "read.c"
    if ((unsigned long )userend != (unsigned long )((char *)0)) {
# 2573 "read.c"
      *userend = (char )'\000';
    }
    {
# 2574 "read.c"
    pwent = getpwnam((char const *)(name + 1));
    }
# 2575 "read.c"
    if ((unsigned long )pwent != (unsigned long )((struct passwd *)0)) {
# 2577 "read.c"
      if ((unsigned long )userend == (unsigned long )((char *)0)) {
        {
# 2578 "read.c"
        tmp___3 = xstrdup((char const *)pwent->pw_dir);
        }
# 2578 "read.c"
        return (tmp___3);
      } else {
        {
# 2580 "read.c"
        tmp___4 = concat(pwent->pw_dir, (char *)"/", userend + 1);
        }
# 2580 "read.c"
        return (tmp___4);
      }
    } else
# 2582 "read.c"
    if ((unsigned long )userend != (unsigned long )((char *)0)) {
# 2583 "read.c"
      *userend = (char )'/';
    }
  }
# 2587 "read.c"
  return ((char *)0);
}
}
# 2600 "read.c"
struct nameseq *multi_glob(struct nameseq *chain , unsigned int size )
{
  register struct nameseq *new ;
  register struct nameseq *old ;
  struct nameseq *nexto ;
  glob_t gl ;
  char *memname ;
  char *newname ;
  char *tmp ;
  char *arname ;
  int tmp___0 ;
  int tmp___1 ;
  register int i ;
  struct nameseq *found ;
  struct nameseq *tmp___2 ;
  struct nameseq *elt ;
  char *tmp___3 ;
  unsigned int alen ;
  size_t tmp___4 ;
  unsigned int mlen ;
  size_t tmp___5 ;
  char *tmp___6 ;
  struct nameseq *f ;
  struct nameseq *elt___0 ;
  char *tmp___7 ;
  int tmp___8 ;
  char *tmp___9 ;

  {
  {
# 2606 "read.c"
  new = (struct nameseq *)0;
# 2611 "read.c"
  dir_setup_glob(& gl);
# 2613 "read.c"
  old = chain;
  }
  {
# 2613 "read.c"
  while (1) {
    while_continue: ;
# 2613 "read.c"
    if (! ((unsigned long )old != (unsigned long )((struct nameseq *)0))) {
# 2613 "read.c"
      goto while_break;
    }
# 2619 "read.c"
    nexto = old->next;
# 2621 "read.c"
    if ((int )*(old->name + 0) == 126) {
      {
# 2623 "read.c"
      tmp = tilde_expand(old->name);
# 2623 "read.c"
      newname = tmp;
      }
# 2624 "read.c"
      if ((unsigned long )newname != (unsigned long )((char *)0)) {
        {
# 2626 "read.c"
        free((void *)old->name);
# 2627 "read.c"
        old->name = newname;
        }
      }
    }
    {
# 2632 "read.c"
    tmp___0 = ar_name(old->name);
    }
# 2632 "read.c"
    if (tmp___0) {
      {
# 2640 "read.c"
      ar_parse_name(old->name, & arname, & memname);
# 2641 "read.c"
      free((void *)old->name);
# 2642 "read.c"
      old->name = arname;
      }
    } else {
# 2645 "read.c"
      memname = (char *)0;
    }
    {
# 2648 "read.c"
    tmp___1 = glob((char const *)old->name, (1 << 4) | (1 << 9), (int (*)(char const * ,
                                                                            int ))((void *)0),
                   & gl);
    }
    {
# 2649 "read.c"
    if (tmp___1 == 0) {
# 2649 "read.c"
      goto case_0;
    }
# 2705 "read.c"
    if (tmp___1 == 1) {
# 2705 "read.c"
      goto case_1;
    }
# 2710 "read.c"
    goto switch_default;
    case_0:
# 2652 "read.c"
    i = (int )gl.gl_pathc;
    {
# 2653 "read.c"
    while (1) {
      while_continue___0: ;
# 2653 "read.c"
      tmp___8 = i;
# 2653 "read.c"
      i --;
# 2653 "read.c"
      if (! (tmp___8 > 0)) {
# 2653 "read.c"
        goto while_break___0;
      }
# 2656 "read.c"
      if ((unsigned long )memname != (unsigned long )((char *)0)) {
        {
# 2659 "read.c"
        tmp___2 = ar_glob(*(gl.gl_pathv + i), memname, size);
# 2659 "read.c"
        found = tmp___2;
        }
# 2661 "read.c"
        if ((unsigned long )found == (unsigned long )((struct nameseq *)0)) {
          {
# 2664 "read.c"
          tmp___3 = xmalloc(size);
# 2664 "read.c"
          elt = (struct nameseq *)tmp___3;
# 2666 "read.c"
          tmp___4 = strlen((char const *)*(gl.gl_pathv + i));
# 2666 "read.c"
          alen = (unsigned int )tmp___4;
# 2667 "read.c"
          tmp___5 = strlen((char const *)memname);
# 2667 "read.c"
          mlen = (unsigned int )tmp___5;
# 2668 "read.c"
          tmp___6 = xmalloc(((alen + 1U) + mlen) + 2U);
# 2668 "read.c"
          elt->name = tmp___6;
# 2669 "read.c"
          memmove((void *)elt->name, (void const *)*(gl.gl_pathv + i), (size_t )alen);
# 2670 "read.c"
          *(elt->name + alen) = (char )'(';
# 2671 "read.c"
          memmove((void *)(elt->name + (alen + 1U)), (void const *)memname, (size_t )mlen);
# 2672 "read.c"
          *(elt->name + ((alen + 1U) + mlen)) = (char )')';
# 2673 "read.c"
          *(elt->name + (((alen + 1U) + mlen) + 1U)) = (char )'\000';
# 2674 "read.c"
          elt->next = new;
# 2675 "read.c"
          new = elt;
          }
        } else {
# 2680 "read.c"
          f = found;
          {
# 2681 "read.c"
          while (1) {
            while_continue___1: ;
# 2681 "read.c"
            if (! ((unsigned long )f->next != (unsigned long )((struct nameseq *)0))) {
# 2681 "read.c"
              goto while_break___1;
            }
# 2682 "read.c"
            f = f->next;
          }
          while_break___1: ;
          }
# 2686 "read.c"
          f->next = new;
# 2687 "read.c"
          new = found;
        }
        {
# 2690 "read.c"
        free((void *)memname);
        }
      } else {
        {
# 2695 "read.c"
        tmp___7 = xmalloc(size);
# 2695 "read.c"
        elt___0 = (struct nameseq *)tmp___7;
# 2696 "read.c"
        elt___0->name = xstrdup((char const *)*(gl.gl_pathv + i));
# 2697 "read.c"
        elt___0->next = new;
# 2698 "read.c"
        new = elt___0;
        }
      }
    }
    while_break___0: ;
    }
    {
# 2701 "read.c"
    globfree(& gl);
# 2702 "read.c"
    free((void *)old->name);
# 2703 "read.c"
    free((void *)((char *)old));
    }
# 2704 "read.c"
    goto switch_break;
    case_1:
    {
# 2708 "read.c"
    tmp___9 = dcgettext((char const *)((void *)0), "virtual memory exhausted", 5);
# 2708 "read.c"
    fatal((struct floc const *)((struct floc *)0), (char const *)tmp___9);
    }
# 2709 "read.c"
    goto switch_break;
    switch_default:
# 2712 "read.c"
    old->next = new;
# 2713 "read.c"
    new = old;
# 2714 "read.c"
    goto switch_break;
    switch_break: ;
    }
# 2613 "read.c"
    old = nexto;
  }
  while_break: ;
  }
# 2718 "read.c"
  return (new);
}
}
# 1 "remake.o"
#pragma merger("0","/tmp/cil-iRzmYf7g.i","-g,-O0")
# 433 "make.h"
int gpath_search(char *file , int len ) ;
# 59 "remake.c"
unsigned int commands_started = 0U;
# 61 "remake.c"
static int update_file(struct file *file , unsigned int depth ) ;
# 62 "remake.c"
static int update_file_1(struct file *file , unsigned int depth ) ;
# 63 "remake.c"
static int check_dep(struct file *file , unsigned int depth , uintmax_t this_mtime ,
                     int *must_make_ptr ) ;
# 64 "remake.c"
static int touch_file(struct file *file ) ;
# 65 "remake.c"
static void remake_file(struct file *file ) ;
# 66 "remake.c"
static uintmax_t name_mtime(char *name ) ;
# 67 "remake.c"
static int library_search(char **lib , uintmax_t *mtime_ptr ) ;
# 77 "remake.c"
int update_goal_chain(struct dep *goals___0 , int makefiles___0 )
{
  int t ;
  int q ;
  int n ;
  unsigned int j ;
  int status ;
  struct dep *g ;
  register struct dep *g___0 ;
  register struct dep *lastgoal___0 ;
  struct file *file ;
  int stop ;
  int any_not_updated ;
  unsigned int ocommands_started ;
  int x ;
  int tmp ;
  int tmp___0 ;
  uintmax_t mtime ;
  uintmax_t tmp___1 ;
  uintmax_t tmp___2 ;
  uintmax_t tmp___3 ;
  uintmax_t tmp___4 ;
  uintmax_t tmp___5 ;
  char *tmp___6 ;
  char *tmp___7 ;
  char *tmp___8 ;

  {
  {
# 82 "remake.c"
  t = touch_flag;
# 82 "remake.c"
  q = question_flag;
# 82 "remake.c"
  n = just_print_flag;
# 83 "remake.c"
  j = job_slots;
# 84 "remake.c"
  status = -1;
# 91 "remake.c"
  goals___0 = copy_dep_chain(goals___0);
# 100 "remake.c"
  g = goals___0;
  }
  {
# 100 "remake.c"
  while (1) {
    while_continue: ;
# 100 "remake.c"
    if (! ((unsigned long )g != (unsigned long )((struct dep *)0))) {
# 100 "remake.c"
      goto while_break;
    }
# 101 "remake.c"
    g->changed = 0;
# 100 "remake.c"
    g = g->next;
  }
  while_break: ;
  }
# 105 "remake.c"
  considered = 1U;
  {
# 109 "remake.c"
  while (1) {
    while_continue___0: ;
# 109 "remake.c"
    if (! ((unsigned long )goals___0 != (unsigned long )((struct dep *)0))) {
# 109 "remake.c"
      goto while_break___0;
    }
    {
# 115 "remake.c"
    start_waiting_jobs();
# 119 "remake.c"
    reap_children(1, 0);
# 121 "remake.c"
    lastgoal___0 = (struct dep *)0;
# 122 "remake.c"
    g___0 = goals___0;
    }
    {
# 123 "remake.c"
    while (1) {
      while_continue___1: ;
# 123 "remake.c"
      if (! ((unsigned long )g___0 != (unsigned long )((struct dep *)0))) {
# 123 "remake.c"
        goto while_break___1;
      }
# 127 "remake.c"
      stop = 0;
# 127 "remake.c"
      any_not_updated = 0;
# 129 "remake.c"
      if ((g___0->file)->double_colon) {
# 129 "remake.c"
        file = (g___0->file)->double_colon;
      } else {
# 129 "remake.c"
        file = g___0->file;
      }
      {
# 129 "remake.c"
      while (1) {
        while_continue___2: ;
# 129 "remake.c"
        if (! ((unsigned long )file != (unsigned long )((void *)0))) {
# 129 "remake.c"
          goto while_break___2;
        }
        {
# 135 "remake.c"
        while (1) {
          while_continue___3: ;
# 135 "remake.c"
          if (! ((unsigned long )file->renamed != (unsigned long )((struct file *)0))) {
# 135 "remake.c"
            goto while_break___3;
          }
# 135 "remake.c"
          file = file->renamed;
        }
        while_break___3: ;
        }
# 136 "remake.c"
        if (makefiles___0) {
# 138 "remake.c"
          if (file->cmd_target) {
# 140 "remake.c"
            touch_flag = t;
# 141 "remake.c"
            question_flag = q;
# 142 "remake.c"
            just_print_flag = n;
          } else {
# 145 "remake.c"
            just_print_flag = 0;
# 145 "remake.c"
            question_flag = just_print_flag;
# 145 "remake.c"
            touch_flag = question_flag;
          }
        }
# 151 "remake.c"
        ocommands_started = commands_started;
# 153 "remake.c"
        if (makefiles___0) {
# 153 "remake.c"
          tmp = 1;
        } else {
# 153 "remake.c"
          tmp = 0;
        }
        {
# 153 "remake.c"
        x = update_file(file, (unsigned int )tmp);
        }
        {
# 154 "remake.c"
        while (1) {
          while_continue___4: ;
# 154 "remake.c"
          if (! ((unsigned long )file->renamed != (unsigned long )((struct file *)0))) {
# 154 "remake.c"
            goto while_break___4;
          }
# 154 "remake.c"
          file = file->renamed;
        }
        while_break___4: ;
        }
# 159 "remake.c"
        g___0->changed = (int )((unsigned int )g___0->changed + (commands_started - ocommands_started));
# 165 "remake.c"
        stop = 0;
# 166 "remake.c"
        if (x != 0) {
# 166 "remake.c"
          goto _L;
        } else
# 166 "remake.c"
        if (file->updated) {
          _L:
# 166 "remake.c"
          if (status < 1) {
# 168 "remake.c"
            if ((int )file->update_status != 0) {
# 172 "remake.c"
              status = (int )file->update_status;
# 176 "remake.c"
              if (! keep_going_flag) {
# 176 "remake.c"
                if (! question_flag) {
# 176 "remake.c"
                  if (! makefiles___0) {
# 176 "remake.c"
                    tmp___0 = 1;
                  } else {
# 176 "remake.c"
                    tmp___0 = 0;
                  }
                } else {
# 176 "remake.c"
                  tmp___0 = 0;
                }
              } else {
# 176 "remake.c"
                tmp___0 = 0;
              }
# 176 "remake.c"
              stop = tmp___0;
            } else {
# 181 "remake.c"
              if (makefiles___0) {
# 181 "remake.c"
                if (file->last_mtime) {
# 181 "remake.c"
                  tmp___2 = file->last_mtime;
                } else {
                  {
# 181 "remake.c"
                  tmp___1 = f_mtime(file, 0);
# 181 "remake.c"
                  tmp___2 = tmp___1;
                  }
                }
# 181 "remake.c"
                tmp___5 = tmp___2;
              } else {
# 181 "remake.c"
                if (file->last_mtime) {
# 181 "remake.c"
                  tmp___4 = file->last_mtime;
                } else {
                  {
# 181 "remake.c"
                  tmp___3 = f_mtime(file, 1);
# 181 "remake.c"
                  tmp___4 = tmp___3;
                  }
                }
# 181 "remake.c"
                tmp___5 = tmp___4;
              }
# 181 "remake.c"
              mtime = tmp___5;
              {
# 182 "remake.c"
              while (1) {
                while_continue___5: ;
# 182 "remake.c"
                if (! ((unsigned long )file->renamed != (unsigned long )((struct file *)0))) {
# 182 "remake.c"
                  goto while_break___5;
                }
# 182 "remake.c"
                file = file->renamed;
              }
              while_break___5: ;
              }
# 184 "remake.c"
              if (file->updated) {
# 184 "remake.c"
                if (g___0->changed) {
# 184 "remake.c"
                  if (mtime != file->mtime_before_update) {
# 193 "remake.c"
                    if (! makefiles___0) {
# 195 "remake.c"
                      status = 0;
                    } else
# 193 "remake.c"
                    if (! just_print_flag) {
# 193 "remake.c"
                      if (! question_flag) {
# 195 "remake.c"
                        status = 0;
                      }
                    }
# 196 "remake.c"
                    if (makefiles___0) {
# 196 "remake.c"
                      if (file->dontcare) {
# 198 "remake.c"
                        stop = 1;
                      }
                    }
                  }
                }
              }
            }
          }
        }
# 205 "remake.c"
        any_not_updated |= ! file->updated;
# 207 "remake.c"
        if (stop) {
# 208 "remake.c"
          goto while_break___2;
        }
# 129 "remake.c"
        file = file->prev;
      }
      while_break___2: ;
      }
# 212 "remake.c"
      file = g___0->file;
# 214 "remake.c"
      if (stop) {
# 214 "remake.c"
        goto _L___0;
      } else
# 214 "remake.c"
      if (! any_not_updated) {
        _L___0:
# 219 "remake.c"
        if (! makefiles___0) {
# 219 "remake.c"
          if ((int )file->update_status == 0) {
# 219 "remake.c"
            if (! g___0->changed) {
# 219 "remake.c"
              if (! silent_flag) {
# 219 "remake.c"
                if (! question_flag) {
# 226 "remake.c"
                  if (file->phony) {
                    {
# 226 "remake.c"
                    tmp___6 = dcgettext((char const *)((void *)0), "Nothing to be done for `%s\'.",
                                        5);
# 226 "remake.c"
                    tmp___8 = tmp___6;
                    }
                  } else
# 226 "remake.c"
                  if ((unsigned long )file->cmds == (unsigned long )((struct commands *)0)) {
                    {
# 226 "remake.c"
                    tmp___6 = dcgettext((char const *)((void *)0), "Nothing to be done for `%s\'.",
                                        5);
# 226 "remake.c"
                    tmp___8 = tmp___6;
                    }
                  } else {
                    {
# 226 "remake.c"
                    tmp___7 = dcgettext((char const *)((void *)0), "`%s\' is up to date.",
                                        5);
# 226 "remake.c"
                    tmp___8 = tmp___7;
                    }
                  }
                  {
# 226 "remake.c"
                  message(1, (char const *)tmp___8, file->name);
                  }
                }
              }
            }
          }
        }
# 232 "remake.c"
        if ((unsigned long )lastgoal___0 == (unsigned long )((struct dep *)0)) {
# 233 "remake.c"
          goals___0 = g___0->next;
        } else {
# 235 "remake.c"
          lastgoal___0->next = g___0->next;
        }
        {
# 238 "remake.c"
        free((void *)((char *)g___0));
        }
# 240 "remake.c"
        if ((unsigned long )lastgoal___0 == (unsigned long )((struct dep *)0)) {
# 240 "remake.c"
          g___0 = goals___0;
        } else {
# 240 "remake.c"
          g___0 = lastgoal___0->next;
        }
# 242 "remake.c"
        if (stop) {
# 243 "remake.c"
          goto while_break___1;
        }
      } else {
# 247 "remake.c"
        lastgoal___0 = g___0;
# 248 "remake.c"
        g___0 = g___0->next;
      }
    }
    while_break___1: ;
    }
# 254 "remake.c"
    if ((unsigned long )g___0 == (unsigned long )((struct dep *)0)) {
# 255 "remake.c"
      considered = (unsigned int )(! considered);
    }
  }
  while_break___0: ;
  }
# 258 "remake.c"
  if (makefiles___0) {
# 260 "remake.c"
    touch_flag = t;
# 261 "remake.c"
    question_flag = q;
# 262 "remake.c"
    just_print_flag = n;
# 263 "remake.c"
    job_slots = j;
  }
# 265 "remake.c"
  return (status);
}
}
# 280 "remake.c"
static int update_file(struct file *file , unsigned int depth )
{
  register int status ;
  register struct file *f ;
  char *tmp ;
  int tmp___0 ;
  int tmp___1 ;
  struct dep *d ;
  int tmp___2 ;

  {
# 285 "remake.c"
  status = 0;
# 288 "remake.c"
  if (file->double_colon) {
# 288 "remake.c"
    f = file->double_colon;
  } else {
# 288 "remake.c"
    f = file;
  }
# 294 "remake.c"
  if (f->considered == considered) {
    {
# 296 "remake.c"
    while (1) {
      while_continue: ;
# 296 "remake.c"
      if (2 & db_level) {
        {
# 296 "remake.c"
        print_spaces(depth);
# 296 "remake.c"
        tmp = dcgettext((char const *)((void *)0), "Pruning file `%s\'.\n", 5);
# 296 "remake.c"
        printf((char const * __restrict )tmp, file->name);
# 296 "remake.c"
        fflush(stdout);
        }
      }
# 296 "remake.c"
      goto while_break;
    }
    while_break: ;
    }
# 297 "remake.c"
    if ((unsigned int )f->command_state == 3U) {
# 297 "remake.c"
      tmp___0 = (int )f->update_status;
    } else {
# 297 "remake.c"
      tmp___0 = 0;
    }
# 297 "remake.c"
    return (tmp___0);
  }
  {
# 302 "remake.c"
  while (1) {
    while_continue___0: ;
# 302 "remake.c"
    if (! ((unsigned long )f != (unsigned long )((struct file *)0))) {
# 302 "remake.c"
      goto while_break___0;
    }
    {
# 304 "remake.c"
    f->considered = considered;
# 306 "remake.c"
    tmp___1 = update_file_1(f, depth);
# 306 "remake.c"
    status |= tmp___1;
    }
    {
# 307 "remake.c"
    while (1) {
      while_continue___1: ;
# 307 "remake.c"
      if (! ((unsigned long )f->renamed != (unsigned long )((struct file *)0))) {
# 307 "remake.c"
        goto while_break___1;
      }
# 307 "remake.c"
      f = f->renamed;
    }
    while_break___1: ;
    }
# 309 "remake.c"
    if (status != 0) {
# 309 "remake.c"
      if (! keep_going_flag) {
# 310 "remake.c"
        goto while_break___0;
      }
    }
# 312 "remake.c"
    if ((unsigned int )f->command_state == 2U) {
# 317 "remake.c"
      status = 0;
# 318 "remake.c"
      goto while_break___0;
    } else
# 312 "remake.c"
    if ((unsigned int )f->command_state == 1U) {
# 317 "remake.c"
      status = 0;
# 318 "remake.c"
      goto while_break___0;
    }
# 302 "remake.c"
    f = f->prev;
  }
  while_break___0: ;
  }
  {
# 324 "remake.c"
  while (1) {
    while_continue___2: ;
# 324 "remake.c"
    if (! ((unsigned long )f != (unsigned long )((struct file *)0))) {
# 324 "remake.c"
      goto while_break___2;
    }
# 328 "remake.c"
    f->considered = considered;
# 330 "remake.c"
    d = f->deps;
    {
# 330 "remake.c"
    while (1) {
      while_continue___3: ;
# 330 "remake.c"
      if (! ((unsigned long )d != (unsigned long )((struct dep *)0))) {
# 330 "remake.c"
        goto while_break___3;
      }
      {
# 331 "remake.c"
      tmp___2 = update_file(d->file, depth + 1U);
# 331 "remake.c"
      status |= tmp___2;
# 330 "remake.c"
      d = d->next;
      }
    }
    while_break___3: ;
    }
# 324 "remake.c"
    f = f->prev;
  }
  while_break___2: ;
  }
# 334 "remake.c"
  return (status);
}
}
# 339 "remake.c"
static int update_file_1(struct file *file , unsigned int depth )
{
  register uintmax_t this_mtime ;
  int noexist ;
  int must_make ;
  int deps_changed ;
  int dep_status ;
  register struct dep *d ;
  register struct dep *lastd ;
  int running ;
  char *tmp ;
  char *tmp___0 ;
  char *tmp___1 ;
  char *tmp___2 ;
  char *tmp___3 ;
  struct file *tmp___4 ;
  uintmax_t tmp___5 ;
  char *tmp___6 ;
  char *tmp___7 ;
  char *tmp___8 ;
  int tmp___9 ;
  char *tmp___10 ;
  uintmax_t mtime ;
  uintmax_t tmp___11 ;
  char *tmp___12 ;
  struct file *tmp___13 ;
  int tmp___14 ;
  register struct file *f ;
  int tmp___15 ;
  uintmax_t tmp___16 ;
  uintmax_t tmp___17 ;
  uintmax_t mtime___0 ;
  uintmax_t tmp___18 ;
  uintmax_t tmp___19 ;
  int tmp___20 ;
  register struct file *f___0 ;
  int tmp___21 ;
  uintmax_t tmp___22 ;
  uintmax_t tmp___23 ;
  int tmp___24 ;
  struct file *tmp___25 ;
  char *tmp___26 ;
  char *tmp___27 ;
  char *tmp___28 ;
  char *tmp___29 ;
  uintmax_t d_mtime ;
  uintmax_t tmp___30 ;
  uintmax_t tmp___31 ;
  int tmp___32 ;
  char const *fmt ;
  char *tmp___33 ;
  char *tmp___34 ;
  char *tmp___35 ;
  char *tmp___36 ;
  char *tmp___37 ;
  char *tmp___38 ;
  char *tmp___39 ;
  char *tmp___40 ;
  int tmp___41 ;
  char *tmp___42 ;
  char *tmp___43 ;
  int tmp___44 ;
  char *tmp___45 ;
  char *tmp___46 ;
  char *tmp___47 ;
  char *tmp___48 ;

  {
# 346 "remake.c"
  dep_status = 0;
# 348 "remake.c"
  running = 0;
  {
# 350 "remake.c"
  while (1) {
    while_continue: ;
# 350 "remake.c"
    if (2 & db_level) {
      {
# 350 "remake.c"
      print_spaces(depth);
# 350 "remake.c"
      tmp = dcgettext((char const *)((void *)0), "Considering target file `%s\'.\n",
                      5);
# 350 "remake.c"
      printf((char const * __restrict )tmp, file->name);
# 350 "remake.c"
      fflush(stdout);
      }
    }
# 350 "remake.c"
    goto while_break;
  }
  while_break: ;
  }
# 352 "remake.c"
  if (file->updated) {
# 354 "remake.c"
    if ((int )file->update_status > 0) {
      {
# 356 "remake.c"
      while (1) {
        while_continue___0: ;
# 356 "remake.c"
        if (2 & db_level) {
          {
# 356 "remake.c"
          print_spaces(depth);
# 356 "remake.c"
          tmp___0 = dcgettext((char const *)((void *)0), "Recently tried and failed to update file `%s\'.\n",
                              5);
# 356 "remake.c"
          printf((char const * __restrict )tmp___0, file->name);
# 356 "remake.c"
          fflush(stdout);
          }
        }
# 356 "remake.c"
        goto while_break___0;
      }
      while_break___0: ;
      }
# 358 "remake.c"
      return ((int )file->update_status);
    }
    {
# 361 "remake.c"
    while (1) {
      while_continue___1: ;
# 361 "remake.c"
      if (2 & db_level) {
        {
# 361 "remake.c"
        print_spaces(depth);
# 361 "remake.c"
        tmp___1 = dcgettext((char const *)((void *)0), "File `%s\' was considered already.\n",
                            5);
# 361 "remake.c"
        printf((char const * __restrict )tmp___1, file->name);
# 361 "remake.c"
        fflush(stdout);
        }
      }
# 361 "remake.c"
      goto while_break___1;
    }
    while_break___1: ;
    }
# 362 "remake.c"
    return (0);
  }
  {
# 367 "remake.c"
  if ((unsigned int )file->command_state == 0U) {
# 367 "remake.c"
    goto case_0;
  }
# 367 "remake.c"
  if ((unsigned int )file->command_state == 1U) {
# 367 "remake.c"
    goto case_0;
  }
# 370 "remake.c"
  if ((unsigned int )file->command_state == 2U) {
# 370 "remake.c"
    goto case_2;
  }
# 373 "remake.c"
  if ((unsigned int )file->command_state == 3U) {
# 373 "remake.c"
    goto case_3;
  }
# 376 "remake.c"
  goto switch_default;
  case_0:
  case_1:
# 369 "remake.c"
  goto switch_break;
  case_2:
  {
# 371 "remake.c"
  while (1) {
    while_continue___2: ;
# 371 "remake.c"
    if (2 & db_level) {
      {
# 371 "remake.c"
      print_spaces(depth);
# 371 "remake.c"
      tmp___2 = dcgettext((char const *)((void *)0), "Still updating file `%s\'.\n",
                          5);
# 371 "remake.c"
      printf((char const * __restrict )tmp___2, file->name);
# 371 "remake.c"
      fflush(stdout);
      }
    }
# 371 "remake.c"
    goto while_break___2;
  }
  while_break___2: ;
  }
# 372 "remake.c"
  return (0);
  case_3:
  {
# 374 "remake.c"
  while (1) {
    while_continue___3: ;
# 374 "remake.c"
    if (2 & db_level) {
      {
# 374 "remake.c"
      print_spaces(depth);
# 374 "remake.c"
      tmp___3 = dcgettext((char const *)((void *)0), "Finished updating file `%s\'.\n",
                          5);
# 374 "remake.c"
      printf((char const * __restrict )tmp___3, file->name);
# 374 "remake.c"
      fflush(stdout);
      }
    }
# 374 "remake.c"
    goto while_break___3;
  }
  while_break___3: ;
  }
# 375 "remake.c"
  return ((int )file->update_status);
  switch_default:
  {
# 377 "remake.c"
  abort();
  }
  switch_break: ;
  }
# 380 "remake.c"
  depth ++;
# 383 "remake.c"
  if (file->double_colon) {
# 383 "remake.c"
    tmp___4 = file->double_colon;
  } else {
# 383 "remake.c"
    tmp___4 = file;
  }
# 383 "remake.c"
  tmp___4->updating = 1U;
# 391 "remake.c"
  if (file->last_mtime) {
# 391 "remake.c"
    this_mtime = file->last_mtime;
  } else {
    {
# 391 "remake.c"
    tmp___5 = f_mtime(file, 1);
# 391 "remake.c"
    this_mtime = tmp___5;
    }
  }
  {
# 392 "remake.c"
  while (1) {
    while_continue___4: ;
# 392 "remake.c"
    if (! ((unsigned long )file->renamed != (unsigned long )((struct file *)0))) {
# 392 "remake.c"
      goto while_break___4;
    }
# 392 "remake.c"
    file = file->renamed;
  }
  while_break___4: ;
  }
# 393 "remake.c"
  noexist = this_mtime == 0xffffffffffffffffUL;
# 394 "remake.c"
  if (noexist) {
    {
# 395 "remake.c"
    while (1) {
      while_continue___5: ;
# 395 "remake.c"
      if (1 & db_level) {
        {
# 395 "remake.c"
        print_spaces(depth);
# 395 "remake.c"
        tmp___6 = dcgettext((char const *)((void *)0), "File `%s\' does not exist.\n",
                            5);
# 395 "remake.c"
        printf((char const * __restrict )tmp___6, file->name);
# 395 "remake.c"
        fflush(stdout);
        }
      }
# 395 "remake.c"
      goto while_break___5;
    }
    while_break___5: ;
    }
  }
# 397 "remake.c"
  must_make = noexist;
# 402 "remake.c"
  if (! file->phony) {
# 402 "remake.c"
    if ((unsigned long )file->cmds == (unsigned long )((struct commands *)0)) {
# 402 "remake.c"
      if (! file->tried_implicit) {
        {
# 404 "remake.c"
        tmp___9 = try_implicit_rule(file, depth);
        }
# 404 "remake.c"
        if (tmp___9) {
          {
# 405 "remake.c"
          while (1) {
            while_continue___6: ;
# 405 "remake.c"
            if (8 & db_level) {
              {
# 405 "remake.c"
              print_spaces(depth);
# 405 "remake.c"
              tmp___7 = dcgettext((char const *)((void *)0), "Found an implicit rule for `%s\'.\n",
                                  5);
# 405 "remake.c"
              printf((char const * __restrict )tmp___7, file->name);
# 405 "remake.c"
              fflush(stdout);
              }
            }
# 405 "remake.c"
            goto while_break___6;
          }
          while_break___6: ;
          }
        } else {
          {
# 407 "remake.c"
          while (1) {
            while_continue___7: ;
# 407 "remake.c"
            if (8 & db_level) {
              {
# 407 "remake.c"
              print_spaces(depth);
# 407 "remake.c"
              tmp___8 = dcgettext((char const *)((void *)0), "No implicit rule found for `%s\'.\n",
                                  5);
# 407 "remake.c"
              printf((char const * __restrict )tmp___8, file->name);
# 407 "remake.c"
              fflush(stdout);
              }
            }
# 407 "remake.c"
            goto while_break___7;
          }
          while_break___7: ;
          }
        }
# 408 "remake.c"
        file->tried_implicit = 1U;
      }
    }
  }
# 410 "remake.c"
  if ((unsigned long )file->cmds == (unsigned long )((struct commands *)0)) {
# 410 "remake.c"
    if (! file->is_target) {
# 410 "remake.c"
      if ((unsigned long )default_file != (unsigned long )((struct file *)0)) {
# 410 "remake.c"
        if ((unsigned long )default_file->cmds != (unsigned long )((struct commands *)0)) {
          {
# 413 "remake.c"
          while (1) {
            while_continue___8: ;
# 413 "remake.c"
            if (8 & db_level) {
              {
# 413 "remake.c"
              print_spaces(depth);
# 413 "remake.c"
              tmp___10 = dcgettext((char const *)((void *)0), "Using default commands for `%s\'.\n",
                                   5);
# 413 "remake.c"
              printf((char const * __restrict )tmp___10, file->name);
# 413 "remake.c"
              fflush(stdout);
              }
            }
# 413 "remake.c"
            goto while_break___8;
          }
          while_break___8: ;
          }
# 414 "remake.c"
          file->cmds = default_file->cmds;
        }
      }
    }
  }
# 420 "remake.c"
  lastd = (struct dep *)0;
# 421 "remake.c"
  d = file->deps;
  {
# 422 "remake.c"
  while (1) {
    while_continue___9: ;
# 422 "remake.c"
    if (! ((unsigned long )d != (unsigned long )((struct dep *)0))) {
# 422 "remake.c"
      goto while_break___9;
    }
    {
# 426 "remake.c"
    while (1) {
      while_continue___10: ;
# 426 "remake.c"
      if (! ((unsigned long )(d->file)->renamed != (unsigned long )((struct file *)0))) {
# 426 "remake.c"
        goto while_break___10;
      }
# 426 "remake.c"
      d->file = (d->file)->renamed;
    }
    while_break___10: ;
    }
# 428 "remake.c"
    if ((d->file)->last_mtime) {
# 428 "remake.c"
      mtime = (d->file)->last_mtime;
    } else {
      {
# 428 "remake.c"
      tmp___11 = f_mtime(d->file, 1);
# 428 "remake.c"
      mtime = tmp___11;
      }
    }
    {
# 429 "remake.c"
    while (1) {
      while_continue___11: ;
# 429 "remake.c"
      if (! ((unsigned long )(d->file)->renamed != (unsigned long )((struct file *)0))) {
# 429 "remake.c"
        goto while_break___11;
      }
# 429 "remake.c"
      d->file = (d->file)->renamed;
    }
    while_break___11: ;
    }
# 431 "remake.c"
    if ((d->file)->double_colon) {
# 431 "remake.c"
      tmp___13 = (d->file)->double_colon;
    } else {
# 431 "remake.c"
      tmp___13 = d->file;
    }
# 431 "remake.c"
    if (tmp___13->updating) {
      {
# 433 "remake.c"
      tmp___12 = dcgettext((char const *)((void *)0), "Circular %s <- %s dependency dropped.",
                           5);
# 433 "remake.c"
      error((struct floc const *)((struct floc *)0), (char const *)tmp___12, file->name,
            (d->file)->name);
      }
# 438 "remake.c"
      if ((unsigned long )lastd == (unsigned long )((struct dep *)0)) {
# 439 "remake.c"
        file->deps = d->next;
      } else {
# 441 "remake.c"
        lastd->next = d->next;
      }
# 442 "remake.c"
      d = d->next;
# 443 "remake.c"
      goto while_continue___9;
    }
    {
# 446 "remake.c"
    (d->file)->parent = file;
# 447 "remake.c"
    tmp___14 = check_dep(d->file, depth, this_mtime, & must_make);
# 447 "remake.c"
    dep_status |= tmp___14;
    }
    {
# 448 "remake.c"
    while (1) {
      while_continue___12: ;
# 448 "remake.c"
      if (! ((unsigned long )(d->file)->renamed != (unsigned long )((struct file *)0))) {
# 448 "remake.c"
        goto while_break___12;
      }
# 448 "remake.c"
      d->file = (d->file)->renamed;
    }
    while_break___12: ;
    }
# 451 "remake.c"
    f = d->file;
# 452 "remake.c"
    if (f->double_colon) {
# 453 "remake.c"
      f = f->double_colon;
    }
    {
# 454 "remake.c"
    while (1) {
      while_continue___13: ;
# 456 "remake.c"
      if ((unsigned int )f->command_state == 2U) {
# 456 "remake.c"
        tmp___15 = 1;
      } else
# 456 "remake.c"
      if ((unsigned int )f->command_state == 1U) {
# 456 "remake.c"
        tmp___15 = 1;
      } else {
# 456 "remake.c"
        tmp___15 = 0;
      }
# 456 "remake.c"
      running |= tmp___15;
# 458 "remake.c"
      f = f->prev;
# 454 "remake.c"
      if (! ((unsigned long )f != (unsigned long )((struct file *)0))) {
# 454 "remake.c"
        goto while_break___13;
      }
    }
    while_break___13: ;
    }
# 463 "remake.c"
    if (dep_status != 0) {
# 463 "remake.c"
      if (! keep_going_flag) {
# 464 "remake.c"
        goto while_break___9;
      }
    }
# 466 "remake.c"
    if (! running) {
# 467 "remake.c"
      if ((d->file)->last_mtime) {
# 467 "remake.c"
        tmp___17 = (d->file)->last_mtime;
      } else {
        {
# 467 "remake.c"
        tmp___16 = f_mtime(d->file, 1);
# 467 "remake.c"
        tmp___17 = tmp___16;
        }
      }
# 467 "remake.c"
      d->changed = tmp___17 != mtime;
    }
# 469 "remake.c"
    lastd = d;
# 470 "remake.c"
    d = d->next;
  }
  while_break___9: ;
  }
# 476 "remake.c"
  if (must_make) {
# 478 "remake.c"
    d = file->deps;
    {
# 478 "remake.c"
    while (1) {
      while_continue___14: ;
# 478 "remake.c"
      if (! ((unsigned long )d != (unsigned long )((struct dep *)0))) {
# 478 "remake.c"
        goto while_break___14;
      }
# 479 "remake.c"
      if ((d->file)->intermediate) {
# 481 "remake.c"
        if ((d->file)->last_mtime) {
# 481 "remake.c"
          tmp___19 = (d->file)->last_mtime;
        } else {
          {
# 481 "remake.c"
          tmp___18 = f_mtime(d->file, 1);
# 481 "remake.c"
          tmp___19 = tmp___18;
          }
        }
# 481 "remake.c"
        mtime___0 = tmp___19;
        {
# 482 "remake.c"
        while (1) {
          while_continue___15: ;
# 482 "remake.c"
          if (! ((unsigned long )(d->file)->renamed != (unsigned long )((struct file *)0))) {
# 482 "remake.c"
            goto while_break___15;
          }
# 482 "remake.c"
          d->file = (d->file)->renamed;
        }
        while_break___15: ;
        }
        {
# 483 "remake.c"
        (d->file)->parent = file;
# 484 "remake.c"
        tmp___20 = update_file(d->file, depth);
# 484 "remake.c"
        dep_status |= tmp___20;
        }
        {
# 485 "remake.c"
        while (1) {
          while_continue___16: ;
# 485 "remake.c"
          if (! ((unsigned long )(d->file)->renamed != (unsigned long )((struct file *)0))) {
# 485 "remake.c"
            goto while_break___16;
          }
# 485 "remake.c"
          d->file = (d->file)->renamed;
        }
        while_break___16: ;
        }
# 488 "remake.c"
        f___0 = d->file;
# 489 "remake.c"
        if (f___0->double_colon) {
# 490 "remake.c"
          f___0 = f___0->double_colon;
        }
        {
# 491 "remake.c"
        while (1) {
          while_continue___17: ;
# 493 "remake.c"
          if ((unsigned int )f___0->command_state == 2U) {
# 493 "remake.c"
            tmp___21 = 1;
          } else
# 493 "remake.c"
          if ((unsigned int )f___0->command_state == 1U) {
# 493 "remake.c"
            tmp___21 = 1;
          } else {
# 493 "remake.c"
            tmp___21 = 0;
          }
# 493 "remake.c"
          running |= tmp___21;
# 495 "remake.c"
          f___0 = f___0->prev;
# 491 "remake.c"
          if (! ((unsigned long )f___0 != (unsigned long )((struct file *)0))) {
# 491 "remake.c"
            goto while_break___17;
          }
        }
        while_break___17: ;
        }
# 500 "remake.c"
        if (dep_status != 0) {
# 500 "remake.c"
          if (! keep_going_flag) {
# 501 "remake.c"
            goto while_break___14;
          }
        }
# 503 "remake.c"
        if (! running) {
# 504 "remake.c"
          if (file->phony) {
# 504 "remake.c"
            if ((unsigned long )file->cmds != (unsigned long )((struct commands *)0)) {
# 504 "remake.c"
              tmp___24 = 1;
            } else {
# 504 "remake.c"
              goto _L;
            }
          } else {
            _L:
# 504 "remake.c"
            if ((d->file)->last_mtime) {
# 504 "remake.c"
              tmp___23 = (d->file)->last_mtime;
            } else {
              {
# 504 "remake.c"
              tmp___22 = f_mtime(d->file, 1);
# 504 "remake.c"
              tmp___23 = tmp___22;
              }
            }
# 504 "remake.c"
            if (tmp___23 != mtime___0) {
# 504 "remake.c"
              tmp___24 = 1;
            } else {
# 504 "remake.c"
              tmp___24 = 0;
            }
          }
# 504 "remake.c"
          d->changed = tmp___24;
        }
      }
# 478 "remake.c"
      d = d->next;
    }
    while_break___14: ;
    }
  }
# 509 "remake.c"
  if (file->double_colon) {
# 509 "remake.c"
    tmp___25 = file->double_colon;
  } else {
# 509 "remake.c"
    tmp___25 = file;
  }
# 509 "remake.c"
  tmp___25->updating = 0U;
  {
# 511 "remake.c"
  while (1) {
    while_continue___18: ;
# 511 "remake.c"
    if (2 & db_level) {
      {
# 511 "remake.c"
      print_spaces(depth);
# 511 "remake.c"
      tmp___26 = dcgettext((char const *)((void *)0), "Finished prerequisites of target file `%s\'.\n",
                           5);
# 511 "remake.c"
      printf((char const * __restrict )tmp___26, file->name);
# 511 "remake.c"
      fflush(stdout);
      }
    }
# 511 "remake.c"
    goto while_break___18;
  }
  while_break___18: ;
  }
# 513 "remake.c"
  if (running) {
    {
# 515 "remake.c"
    set_command_state(file, 1);
# 516 "remake.c"
    depth --;
    }
    {
# 517 "remake.c"
    while (1) {
      while_continue___19: ;
# 517 "remake.c"
      if (2 & db_level) {
        {
# 517 "remake.c"
        print_spaces(depth);
# 517 "remake.c"
        tmp___27 = dcgettext((char const *)((void *)0), "The prerequisites of `%s\' are being made.\n",
                             5);
# 517 "remake.c"
        printf((char const * __restrict )tmp___27, file->name);
# 517 "remake.c"
        fflush(stdout);
        }
      }
# 517 "remake.c"
      goto while_break___19;
    }
    while_break___19: ;
    }
# 518 "remake.c"
    return (0);
  }
# 523 "remake.c"
  if (dep_status != 0) {
    {
# 525 "remake.c"
    file->update_status = (short )dep_status;
# 526 "remake.c"
    notice_finished_file(file);
# 528 "remake.c"
    depth --;
    }
    {
# 530 "remake.c"
    while (1) {
      while_continue___20: ;
# 530 "remake.c"
      if (2 & db_level) {
        {
# 530 "remake.c"
        print_spaces(depth);
# 530 "remake.c"
        tmp___28 = dcgettext((char const *)((void *)0), "Giving up on target file `%s\'.\n",
                             5);
# 530 "remake.c"
        printf((char const * __restrict )tmp___28, file->name);
# 530 "remake.c"
        fflush(stdout);
        }
      }
# 530 "remake.c"
      goto while_break___20;
    }
    while_break___20: ;
    }
# 532 "remake.c"
    if (depth == 0U) {
# 532 "remake.c"
      if (keep_going_flag) {
# 532 "remake.c"
        if (! just_print_flag) {
# 532 "remake.c"
          if (! question_flag) {
            {
# 534 "remake.c"
            tmp___29 = dcgettext((char const *)((void *)0), "Target `%s\' not remade because of errors.",
                                 5);
# 534 "remake.c"
            error((struct floc const *)((struct floc *)0), (char const *)tmp___29,
                  file->name);
            }
          }
        }
      }
    }
# 537 "remake.c"
    return (dep_status);
  }
# 540 "remake.c"
  if ((unsigned int )file->command_state == 1U) {
    {
# 549 "remake.c"
    set_command_state(file, 0);
    }
  }
# 554 "remake.c"
  deps_changed = 0;
# 555 "remake.c"
  d = file->deps;
  {
# 555 "remake.c"
  while (1) {
    while_continue___21: ;
# 555 "remake.c"
    if (! ((unsigned long )d != (unsigned long )((struct dep *)0))) {
# 555 "remake.c"
      goto while_break___21;
    }
# 557 "remake.c"
    if ((d->file)->last_mtime) {
# 557 "remake.c"
      tmp___31 = (d->file)->last_mtime;
    } else {
      {
# 557 "remake.c"
      tmp___30 = f_mtime(d->file, 1);
# 557 "remake.c"
      tmp___31 = tmp___30;
      }
    }
# 557 "remake.c"
    d_mtime = tmp___31;
    {
# 558 "remake.c"
    while (1) {
      while_continue___22: ;
# 558 "remake.c"
      if (! ((unsigned long )(d->file)->renamed != (unsigned long )((struct file *)0))) {
# 558 "remake.c"
        goto while_break___22;
      }
# 558 "remake.c"
      d->file = (d->file)->renamed;
    }
    while_break___22: ;
    }
# 563 "remake.c"
    if (d_mtime == 0xffffffffffffffffUL) {
# 563 "remake.c"
      if (! (d->file)->intermediate) {
# 566 "remake.c"
        must_make = 1;
      }
    }
# 570 "remake.c"
    deps_changed |= d->changed;
# 574 "remake.c"
    if (noexist) {
# 574 "remake.c"
      tmp___32 = 1;
    } else
# 574 "remake.c"
    if (d_mtime > this_mtime) {
# 574 "remake.c"
      tmp___32 = 1;
    } else {
# 574 "remake.c"
      tmp___32 = 0;
    }
# 574 "remake.c"
    d->changed |= tmp___32;
# 576 "remake.c"
    if (! noexist) {
# 576 "remake.c"
      if (3 & db_level) {
# 578 "remake.c"
        fmt = (char const *)0;
# 580 "remake.c"
        if (d_mtime == 0xffffffffffffffffUL) {
# 582 "remake.c"
          if (1 & db_level) {
            {
# 583 "remake.c"
            tmp___33 = dcgettext((char const *)((void *)0), "Prerequisite `%s\' of target `%s\' does not exist.\n",
                                 5);
# 583 "remake.c"
            fmt = (char const *)tmp___33;
            }
          }
        } else
# 585 "remake.c"
        if (d->changed) {
# 587 "remake.c"
          if (1 & db_level) {
            {
# 588 "remake.c"
            tmp___34 = dcgettext((char const *)((void *)0), "Prerequisite `%s\' is newer than target `%s\'.\n",
                                 5);
# 588 "remake.c"
            fmt = (char const *)tmp___34;
            }
          }
        } else
# 590 "remake.c"
        if (2 & db_level) {
          {
# 591 "remake.c"
          tmp___35 = dcgettext((char const *)((void *)0), "Prerequisite `%s\' is older than target `%s\'.\n",
                               5);
# 591 "remake.c"
          fmt = (char const *)tmp___35;
          }
        }
# 593 "remake.c"
        if (fmt) {
          {
# 595 "remake.c"
          print_spaces(depth);
          }
# 596 "remake.c"
          if ((unsigned long )d->name == (unsigned long )((char *)0)) {
# 596 "remake.c"
            tmp___36 = (d->file)->name;
          } else {
# 596 "remake.c"
            tmp___36 = d->name;
          }
          {
# 596 "remake.c"
          printf((char const * __restrict )fmt, tmp___36, file->name);
# 597 "remake.c"
          fflush(stdout);
          }
        }
      }
    }
# 555 "remake.c"
    d = d->next;
  }
  while_break___21: ;
  }
# 603 "remake.c"
  depth --;
# 605 "remake.c"
  if (file->double_colon) {
# 605 "remake.c"
    if ((unsigned long )file->deps == (unsigned long )((struct dep *)0)) {
# 607 "remake.c"
      must_make = 1;
      {
# 608 "remake.c"
      while (1) {
        while_continue___23: ;
# 608 "remake.c"
        if (1 & db_level) {
          {
# 608 "remake.c"
          print_spaces(depth);
# 608 "remake.c"
          tmp___37 = dcgettext((char const *)((void *)0), "Target `%s\' is double-colon and has no prerequisites.\n",
                               5);
# 608 "remake.c"
          printf((char const * __restrict )tmp___37, file->name);
# 608 "remake.c"
          fflush(stdout);
          }
        }
# 608 "remake.c"
        goto while_break___23;
      }
      while_break___23: ;
      }
    } else {
# 605 "remake.c"
      goto _L___0;
    }
  } else
  _L___0:
# 611 "remake.c"
  if (! noexist) {
# 611 "remake.c"
    if (file->is_target) {
# 611 "remake.c"
      if (! deps_changed) {
# 611 "remake.c"
        if ((unsigned long )file->cmds == (unsigned long )((struct commands *)0)) {
# 613 "remake.c"
          must_make = 0;
          {
# 614 "remake.c"
          while (1) {
            while_continue___24: ;
# 614 "remake.c"
            if (2 & db_level) {
              {
# 614 "remake.c"
              print_spaces(depth);
# 614 "remake.c"
              tmp___38 = dcgettext((char const *)((void *)0), "No commands for `%s\' and no prerequisites actually changed.\n",
                                   5);
# 614 "remake.c"
              printf((char const * __restrict )tmp___38, file->name);
# 614 "remake.c"
              fflush(stdout);
              }
            }
# 614 "remake.c"
            goto while_break___24;
          }
          while_break___24: ;
          }
        }
      }
    }
  }
# 618 "remake.c"
  if (! must_make) {
# 620 "remake.c"
    if (2 & db_level) {
      {
# 622 "remake.c"
      print_spaces(depth);
# 623 "remake.c"
      tmp___39 = dcgettext((char const *)((void *)0), "No need to remake target `%s\'",
                           5);
# 623 "remake.c"
      printf((char const * __restrict )tmp___39, file->name);
      }
# 624 "remake.c"
      if (! ((unsigned long )file->name == (unsigned long )file->hname)) {
# 624 "remake.c"
        if ((int )*(file->name) == (int )*(file->hname)) {
# 624 "remake.c"
          if (! ((int )*(file->name) == 0)) {
            {
# 624 "remake.c"
            tmp___41 = strcmp((char const *)(file->name + 1), (char const *)(file->hname + 1));
            }
# 624 "remake.c"
            if (tmp___41) {
              {
# 625 "remake.c"
              tmp___40 = dcgettext((char const *)((void *)0), "; using VPATH name `%s\'",
                                   5);
# 625 "remake.c"
              printf((char const * __restrict )tmp___40, file->hname);
              }
            }
          }
        } else {
          {
# 625 "remake.c"
          tmp___40 = dcgettext((char const *)((void *)0), "; using VPATH name `%s\'",
                               5);
# 625 "remake.c"
          printf((char const * __restrict )tmp___40, file->hname);
          }
        }
      }
      {
# 626 "remake.c"
      puts(".");
# 627 "remake.c"
      fflush(stdout);
      }
    }
    {
# 630 "remake.c"
    notice_finished_file(file);
    }
    {
# 636 "remake.c"
    while (1) {
      while_continue___25: ;
# 636 "remake.c"
      if (! file) {
# 636 "remake.c"
        goto while_break___25;
      }
# 638 "remake.c"
      file->name = file->hname;
# 639 "remake.c"
      file = file->prev;
    }
    while_break___25: ;
    }
# 642 "remake.c"
    return (0);
  }
  {
# 645 "remake.c"
  while (1) {
    while_continue___26: ;
# 645 "remake.c"
    if (1 & db_level) {
      {
# 645 "remake.c"
      print_spaces(depth);
# 645 "remake.c"
      tmp___42 = dcgettext((char const *)((void *)0), "Must remake target `%s\'.\n",
                           5);
# 645 "remake.c"
      printf((char const * __restrict )tmp___42, file->name);
# 645 "remake.c"
      fflush(stdout);
      }
    }
# 645 "remake.c"
    goto while_break___26;
  }
  while_break___26: ;
  }
# 649 "remake.c"
  if (! ((unsigned long )file->name == (unsigned long )file->hname)) {
# 649 "remake.c"
    if ((int )*(file->name) == (int )*(file->hname)) {
# 649 "remake.c"
      if (! ((int )*(file->name) == 0)) {
        {
# 649 "remake.c"
        tmp___44 = strcmp((char const *)(file->name + 1), (char const *)(file->hname + 1));
        }
# 649 "remake.c"
        if (tmp___44) {
# 649 "remake.c"
          goto _L___1;
        }
      }
    } else {
      _L___1:
      {
# 651 "remake.c"
      while (1) {
        while_continue___27: ;
# 651 "remake.c"
        if (1 & db_level) {
          {
# 651 "remake.c"
          tmp___43 = dcgettext((char const *)((void *)0), "  Ignoring VPATH name `%s\'.\n",
                               5);
# 651 "remake.c"
          printf((char const * __restrict )tmp___43, file->hname);
# 651 "remake.c"
          fflush(stdout);
          }
        }
# 651 "remake.c"
        goto while_break___27;
      }
      while_break___27: ;
      }
# 652 "remake.c"
      file->ignore_vpath = 1U;
    }
  }
  {
# 656 "remake.c"
  remake_file(file);
  }
# 658 "remake.c"
  if ((unsigned int )file->command_state != 3U) {
    {
# 660 "remake.c"
    while (1) {
      while_continue___28: ;
# 660 "remake.c"
      if (2 & db_level) {
        {
# 660 "remake.c"
        print_spaces(depth);
# 660 "remake.c"
        tmp___45 = dcgettext((char const *)((void *)0), "Commands of `%s\' are being run.\n",
                             5);
# 660 "remake.c"
        printf((char const * __restrict )tmp___45, file->name);
# 660 "remake.c"
        fflush(stdout);
        }
      }
# 660 "remake.c"
      goto while_break___28;
    }
    while_break___28: ;
    }
# 661 "remake.c"
    return (0);
  }
  {
# 665 "remake.c"
  if ((int )file->update_status == 2) {
# 665 "remake.c"
    goto case_2___0;
  }
# 669 "remake.c"
  if ((int )file->update_status == 0) {
# 669 "remake.c"
    goto case_0___0;
  }
# 672 "remake.c"
  if ((int )file->update_status == 1) {
# 672 "remake.c"
    goto case_1___0;
  }
# 675 "remake.c"
  goto switch_default___0;
  case_2___0:
  {
# 667 "remake.c"
  while (1) {
    while_continue___29: ;
# 667 "remake.c"
    if (1 & db_level) {
      {
# 667 "remake.c"
      print_spaces(depth);
# 667 "remake.c"
      tmp___46 = dcgettext((char const *)((void *)0), "Failed to remake target file `%s\'.\n",
                           5);
# 667 "remake.c"
      printf((char const * __restrict )tmp___46, file->name);
# 667 "remake.c"
      fflush(stdout);
      }
    }
# 667 "remake.c"
    goto while_break___29;
  }
  while_break___29: ;
  }
# 668 "remake.c"
  goto switch_break___0;
  case_0___0:
  {
# 670 "remake.c"
  while (1) {
    while_continue___30: ;
# 670 "remake.c"
    if (1 & db_level) {
      {
# 670 "remake.c"
      print_spaces(depth);
# 670 "remake.c"
      tmp___47 = dcgettext((char const *)((void *)0), "Successfully remade target file `%s\'.\n",
                           5);
# 670 "remake.c"
      printf((char const * __restrict )tmp___47, file->name);
# 670 "remake.c"
      fflush(stdout);
      }
    }
# 670 "remake.c"
    goto while_break___30;
  }
  while_break___30: ;
  }
# 671 "remake.c"
  goto switch_break___0;
  case_1___0:
  {
# 673 "remake.c"
  while (1) {
    while_continue___31: ;
# 673 "remake.c"
    if (1 & db_level) {
      {
# 673 "remake.c"
      print_spaces(depth);
# 673 "remake.c"
      tmp___48 = dcgettext((char const *)((void *)0), "Target file `%s\' needs remade under -q.\n",
                           5);
# 673 "remake.c"
      printf((char const * __restrict )tmp___48, file->name);
# 673 "remake.c"
      fflush(stdout);
      }
    }
# 673 "remake.c"
    goto while_break___31;
  }
  while_break___31: ;
  }
# 674 "remake.c"
  goto switch_break___0;
  switch_default___0:
# 676 "remake.c"
  if ((int )file->update_status >= 0) {
# 676 "remake.c"
    if (! ((int )file->update_status <= 2)) {
      {
# 676 "remake.c"
      __assert_fail("file->update_status >= 0 && file->update_status <= 2", "remake.c",
                    676U, "update_file_1");
      }
    }
  } else {
    {
# 676 "remake.c"
    __assert_fail("file->update_status >= 0 && file->update_status <= 2", "remake.c",
                  676U, "update_file_1");
    }
  }
# 677 "remake.c"
  goto switch_break___0;
  switch_break___0: ;
  }
# 680 "remake.c"
  file->updated = 1U;
# 681 "remake.c"
  return ((int )file->update_status);
}
}
# 690 "remake.c"
void notice_finished_file(struct file *file )
{
  struct dep *d ;
  int ran ;
  unsigned int i ;
  int tmp ;
  struct file *f ;
  int i___0 ;

  {
# 695 "remake.c"
  ran = (unsigned int )file->command_state == 2U;
# 697 "remake.c"
  file->command_state = (enum __anonenum_command_state_55 )3;
# 698 "remake.c"
  file->updated = 1U;
# 700 "remake.c"
  if (touch_flag) {
# 700 "remake.c"
    if ((int )file->update_status == 0) {
# 709 "remake.c"
      if ((unsigned long )file->cmds != (unsigned long )((struct commands *)0)) {
# 709 "remake.c"
        if ((file->cmds)->any_recurse) {
# 714 "remake.c"
          i = 0U;
          {
# 714 "remake.c"
          while (1) {
            while_continue: ;
# 714 "remake.c"
            if (! (i < (file->cmds)->ncommand_lines)) {
# 714 "remake.c"
              goto while_break;
            }
# 715 "remake.c"
            if (! ((int )*((file->cmds)->lines_flags + i) & 1)) {
# 716 "remake.c"
              goto have_nonrecursing;
            }
# 714 "remake.c"
            i ++;
          }
          while_break: ;
          }
        } else {
# 709 "remake.c"
          goto have_nonrecursing;
        }
      } else
      have_nonrecursing:
# 721 "remake.c"
      if (file->phony) {
# 722 "remake.c"
        file->update_status = (short)0;
      } else {
        {
# 725 "remake.c"
        tmp = touch_file(file);
# 725 "remake.c"
        file->update_status = (short )tmp;
        }
      }
    }
  }
# 729 "remake.c"
  if (file->mtime_before_update == 0UL) {
# 730 "remake.c"
    file->mtime_before_update = file->last_mtime;
  }
# 732 "remake.c"
  if (ran) {
# 732 "remake.c"
    if (! file->phony) {
# 735 "remake.c"
      i___0 = 0;
# 741 "remake.c"
      if (question_flag) {
# 741 "remake.c"
        goto _L___0;
      } else
# 741 "remake.c"
      if (just_print_flag) {
        _L___0:
# 743 "remake.c"
        i___0 = (int )(file->cmds)->ncommand_lines;
        {
# 743 "remake.c"
        while (1) {
          while_continue___0: ;
# 743 "remake.c"
          if (! (i___0 > 0)) {
# 743 "remake.c"
            goto while_break___0;
          }
# 744 "remake.c"
          if (! ((int )*((file->cmds)->lines_flags + (i___0 - 1)) & 1)) {
# 745 "remake.c"
            goto while_break___0;
          }
# 743 "remake.c"
          i___0 --;
        }
        while_break___0: ;
        }
      } else
# 750 "remake.c"
      if (file->is_target) {
# 750 "remake.c"
        if ((unsigned long )file->cmds == (unsigned long )((struct commands *)0)) {
# 751 "remake.c"
          i___0 = 1;
        }
      }
# 753 "remake.c"
      if (i___0 == 0) {
# 753 "remake.c"
        file->last_mtime = (uintmax_t )0;
      } else {
# 753 "remake.c"
        file->last_mtime = 0xfffffffffffffffeUL;
      }
# 757 "remake.c"
      f = file->double_colon;
      {
# 757 "remake.c"
      while (1) {
        while_continue___1: ;
# 757 "remake.c"
        if (! ((unsigned long )f != (unsigned long )((struct file *)0))) {
# 757 "remake.c"
          goto while_break___1;
        }
# 758 "remake.c"
        f->last_mtime = file->last_mtime;
# 757 "remake.c"
        f = f->next;
      }
      while_break___1: ;
      }
    }
  }
# 761 "remake.c"
  if (ran) {
# 761 "remake.c"
    if ((int )file->update_status != -1) {
# 766 "remake.c"
      d = file->also_make;
      {
# 766 "remake.c"
      while (1) {
        while_continue___2: ;
# 766 "remake.c"
        if (! ((unsigned long )d != (unsigned long )((struct dep *)0))) {
# 766 "remake.c"
          goto while_break___2;
        }
# 768 "remake.c"
        (d->file)->command_state = (enum __anonenum_command_state_55 )3;
# 769 "remake.c"
        (d->file)->updated = 1U;
# 770 "remake.c"
        (d->file)->update_status = file->update_status;
# 772 "remake.c"
        if (ran) {
# 772 "remake.c"
          if (! (d->file)->phony) {
            {
# 777 "remake.c"
            f_mtime(d->file, 0);
            }
          }
        }
# 766 "remake.c"
        d = d->next;
      }
      while_break___2: ;
      }
    } else {
# 761 "remake.c"
      goto _L___1;
    }
  } else
  _L___1:
# 779 "remake.c"
  if ((int )file->update_status == -1) {
# 782 "remake.c"
    file->update_status = (short)0;
  }
# 783 "remake.c"
  return;
}
}
# 792 "remake.c"
static int check_dep(struct file *file , unsigned int depth , uintmax_t this_mtime ,
                     int *must_make_ptr )
{
  register struct dep *d ;
  int dep_status ;
  struct file *tmp ;
  uintmax_t mtime ;
  uintmax_t tmp___0 ;
  uintmax_t mtime___0 ;
  char *tmp___1 ;
  char *tmp___2 ;
  int tmp___3 ;
  char *tmp___4 ;
  uintmax_t tmp___5 ;
  register struct dep *lastd ;
  char *tmp___6 ;
  struct file *tmp___7 ;
  int tmp___8 ;
  struct file *tmp___9 ;

  {
# 800 "remake.c"
  dep_status = 0;
# 802 "remake.c"
  depth ++;
# 803 "remake.c"
  if (file->double_colon) {
# 803 "remake.c"
    tmp = file->double_colon;
  } else {
# 803 "remake.c"
    tmp = file;
  }
# 803 "remake.c"
  tmp->updating = 1U;
# 805 "remake.c"
  if (! file->intermediate) {
    {
# 810 "remake.c"
    dep_status = update_file(file, depth);
    }
    {
# 811 "remake.c"
    while (1) {
      while_continue: ;
# 811 "remake.c"
      if (! ((unsigned long )file->renamed != (unsigned long )((struct file *)0))) {
# 811 "remake.c"
        goto while_break;
      }
# 811 "remake.c"
      file = file->renamed;
    }
    while_break: ;
    }
# 812 "remake.c"
    if (file->last_mtime) {
# 812 "remake.c"
      mtime = file->last_mtime;
    } else {
      {
# 812 "remake.c"
      tmp___0 = f_mtime(file, 1);
# 812 "remake.c"
      mtime = tmp___0;
      }
    }
    {
# 813 "remake.c"
    while (1) {
      while_continue___0: ;
# 813 "remake.c"
      if (! ((unsigned long )file->renamed != (unsigned long )((struct file *)0))) {
# 813 "remake.c"
        goto while_break___0;
      }
# 813 "remake.c"
      file = file->renamed;
    }
    while_break___0: ;
    }
# 814 "remake.c"
    if (mtime == 0xffffffffffffffffUL) {
# 815 "remake.c"
      *must_make_ptr = 1;
    } else
# 814 "remake.c"
    if (mtime > this_mtime) {
# 815 "remake.c"
      *must_make_ptr = 1;
    }
  } else {
# 822 "remake.c"
    if (! file->phony) {
# 822 "remake.c"
      if ((unsigned long )file->cmds == (unsigned long )((struct commands *)0)) {
# 822 "remake.c"
        if (! file->tried_implicit) {
          {
# 824 "remake.c"
          tmp___3 = try_implicit_rule(file, depth);
          }
# 824 "remake.c"
          if (tmp___3) {
            {
# 825 "remake.c"
            while (1) {
              while_continue___1: ;
# 825 "remake.c"
              if (8 & db_level) {
                {
# 825 "remake.c"
                print_spaces(depth);
# 825 "remake.c"
                tmp___1 = dcgettext((char const *)((void *)0), "Found an implicit rule for `%s\'.\n",
                                    5);
# 825 "remake.c"
                printf((char const * __restrict )tmp___1, file->name);
# 825 "remake.c"
                fflush(stdout);
                }
              }
# 825 "remake.c"
              goto while_break___1;
            }
            while_break___1: ;
            }
          } else {
            {
# 827 "remake.c"
            while (1) {
              while_continue___2: ;
# 827 "remake.c"
              if (8 & db_level) {
                {
# 827 "remake.c"
                print_spaces(depth);
# 827 "remake.c"
                tmp___2 = dcgettext((char const *)((void *)0), "No implicit rule found for `%s\'.\n",
                                    5);
# 827 "remake.c"
                printf((char const * __restrict )tmp___2, file->name);
# 827 "remake.c"
                fflush(stdout);
                }
              }
# 827 "remake.c"
              goto while_break___2;
            }
            while_break___2: ;
            }
          }
# 828 "remake.c"
          file->tried_implicit = 1U;
        }
      }
    }
# 830 "remake.c"
    if ((unsigned long )file->cmds == (unsigned long )((struct commands *)0)) {
# 830 "remake.c"
      if (! file->is_target) {
# 830 "remake.c"
        if ((unsigned long )default_file != (unsigned long )((struct file *)0)) {
# 830 "remake.c"
          if ((unsigned long )default_file->cmds != (unsigned long )((struct commands *)0)) {
            {
# 833 "remake.c"
            while (1) {
              while_continue___3: ;
# 833 "remake.c"
              if (8 & db_level) {
                {
# 833 "remake.c"
                print_spaces(depth);
# 833 "remake.c"
                tmp___4 = dcgettext((char const *)((void *)0), "Using default commands for `%s\'.\n",
                                    5);
# 833 "remake.c"
                printf((char const * __restrict )tmp___4, file->name);
# 833 "remake.c"
                fflush(stdout);
                }
              }
# 833 "remake.c"
              goto while_break___3;
            }
            while_break___3: ;
            }
# 834 "remake.c"
            file->cmds = default_file->cmds;
          }
        }
      }
    }
    {
# 839 "remake.c"
    while (1) {
      while_continue___4: ;
# 839 "remake.c"
      if (! ((unsigned long )file->renamed != (unsigned long )((struct file *)0))) {
# 839 "remake.c"
        goto while_break___4;
      }
# 839 "remake.c"
      file = file->renamed;
    }
    while_break___4: ;
    }
# 840 "remake.c"
    if (file->last_mtime) {
# 840 "remake.c"
      mtime___0 = file->last_mtime;
    } else {
      {
# 840 "remake.c"
      tmp___5 = f_mtime(file, 1);
# 840 "remake.c"
      mtime___0 = tmp___5;
      }
    }
    {
# 841 "remake.c"
    while (1) {
      while_continue___5: ;
# 841 "remake.c"
      if (! ((unsigned long )file->renamed != (unsigned long )((struct file *)0))) {
# 841 "remake.c"
        goto while_break___5;
      }
# 841 "remake.c"
      file = file->renamed;
    }
    while_break___5: ;
    }
# 842 "remake.c"
    if (mtime___0 != 0xffffffffffffffffUL) {
# 842 "remake.c"
      if (mtime___0 > this_mtime) {
# 843 "remake.c"
        *must_make_ptr = 1;
      } else {
# 842 "remake.c"
        goto _L;
      }
    } else {
      _L:
# 851 "remake.c"
      lastd = (struct dep *)0;
# 852 "remake.c"
      d = file->deps;
      {
# 853 "remake.c"
      while (1) {
        while_continue___6: ;
# 853 "remake.c"
        if (! ((unsigned long )d != (unsigned long )((struct dep *)0))) {
# 853 "remake.c"
          goto while_break___6;
        }
# 855 "remake.c"
        if ((d->file)->double_colon) {
# 855 "remake.c"
          tmp___7 = (d->file)->double_colon;
        } else {
# 855 "remake.c"
          tmp___7 = d->file;
        }
# 855 "remake.c"
        if (tmp___7->updating) {
          {
# 857 "remake.c"
          tmp___6 = dcgettext((char const *)((void *)0), "Circular %s <- %s dependency dropped.",
                              5);
# 857 "remake.c"
          error((struct floc const *)((struct floc *)0), (char const *)tmp___6,
                file->name, (d->file)->name);
          }
# 859 "remake.c"
          if ((unsigned long )lastd == (unsigned long )((struct dep *)0)) {
            {
# 861 "remake.c"
            file->deps = d->next;
# 862 "remake.c"
            free((void *)((char *)d));
# 863 "remake.c"
            d = file->deps;
            }
          } else {
            {
# 867 "remake.c"
            lastd->next = d->next;
# 868 "remake.c"
            free((void *)((char *)d));
# 869 "remake.c"
            d = lastd->next;
            }
          }
# 871 "remake.c"
          goto while_continue___6;
        }
        {
# 874 "remake.c"
        (d->file)->parent = file;
# 875 "remake.c"
        tmp___8 = check_dep(d->file, depth, this_mtime, must_make_ptr);
# 875 "remake.c"
        dep_status |= tmp___8;
        }
        {
# 877 "remake.c"
        while (1) {
          while_continue___7: ;
# 877 "remake.c"
          if (! ((unsigned long )(d->file)->renamed != (unsigned long )((struct file *)0))) {
# 877 "remake.c"
            goto while_break___7;
          }
# 877 "remake.c"
          d->file = (d->file)->renamed;
        }
        while_break___7: ;
        }
# 878 "remake.c"
        if (dep_status != 0) {
# 878 "remake.c"
          if (! keep_going_flag) {
# 879 "remake.c"
            goto while_break___6;
          }
        }
# 881 "remake.c"
        if ((unsigned int )(d->file)->command_state == 2U) {
          {
# 886 "remake.c"
          set_command_state(file, 1);
          }
        } else
# 881 "remake.c"
        if ((unsigned int )(d->file)->command_state == 1U) {
          {
# 886 "remake.c"
          set_command_state(file, 1);
          }
        }
# 888 "remake.c"
        lastd = d;
# 889 "remake.c"
        d = d->next;
      }
      while_break___6: ;
      }
    }
  }
# 894 "remake.c"
  if (file->double_colon) {
# 894 "remake.c"
    tmp___9 = file->double_colon;
  } else {
# 894 "remake.c"
    tmp___9 = file;
  }
# 894 "remake.c"
  tmp___9->updating = 0U;
# 895 "remake.c"
  return (dep_status);
}
}
# 902 "remake.c"
static int touch_file(struct file *file )
{
  int tmp ;
  int fd ;
  int tmp___0 ;
  struct stat statbuf ;
  char buf___1 ;
  int status ;
  int *tmp___1 ;
  ssize_t tmp___2 ;
  __off_t tmp___3 ;
  ssize_t tmp___4 ;
  int tmp___5 ;

  {
# 906 "remake.c"
  if (! silent_flag) {
    {
# 907 "remake.c"
    message(0, "touch %s", file->name);
    }
  }
  {
# 910 "remake.c"
  tmp___5 = ar_name(file->name);
  }
# 910 "remake.c"
  if (tmp___5) {
    {
# 911 "remake.c"
    tmp = ar_touch(file->name);
    }
# 911 "remake.c"
    return (tmp);
  } else {
    {
# 915 "remake.c"
    tmp___0 = open((char const *)file->name, 66, 438);
# 915 "remake.c"
    fd = tmp___0;
    }
# 917 "remake.c"
    if (fd < 0) {
      {
# 918 "remake.c"
      perror_with_name((char *)"touch: open: ", file->name);
      }
# 918 "remake.c"
      return (1);
    } else {
      {
# 925 "remake.c"
      while (1) {
        while_continue: ;
        {
# 926 "remake.c"
        status = fstat(fd, & statbuf);
        }
# 925 "remake.c"
        if (status < 0) {
          {
# 925 "remake.c"
          tmp___1 = __errno_location();
          }
# 925 "remake.c"
          if (! (*tmp___1 == 4)) {
# 925 "remake.c"
            goto while_break;
          }
        } else {
# 925 "remake.c"
          goto while_break;
        }
      }
      while_break: ;
      }
# 929 "remake.c"
      if (status < 0) {
        {
# 930 "remake.c"
        perror_with_name((char *)"touch: fstat: ", file->name);
        }
# 930 "remake.c"
        return (1);
      }
      {
# 932 "remake.c"
      tmp___2 = read(fd, (void *)(& buf___1), (size_t )1);
      }
# 932 "remake.c"
      if (tmp___2 < 0L) {
        {
# 933 "remake.c"
        perror_with_name((char *)"touch: read: ", file->name);
        }
# 933 "remake.c"
        return (1);
      }
      {
# 934 "remake.c"
      tmp___3 = lseek(fd, 0L, 0);
      }
# 934 "remake.c"
      if (tmp___3 < 0L) {
        {
# 935 "remake.c"
        perror_with_name((char *)"touch: lseek: ", file->name);
        }
# 935 "remake.c"
        return (1);
      }
      {
# 936 "remake.c"
      tmp___4 = write(fd, (void const *)(& buf___1), (size_t )1);
      }
# 936 "remake.c"
      if (tmp___4 < 0L) {
        {
# 937 "remake.c"
        perror_with_name((char *)"touch: write: ", file->name);
        }
# 937 "remake.c"
        return (1);
      }
# 940 "remake.c"
      if (statbuf.st_size == 0L) {
        {
# 942 "remake.c"
        close(fd);
# 943 "remake.c"
        fd = open((char const *)file->name, 514, 438);
        }
# 944 "remake.c"
        if (fd < 0) {
          {
# 945 "remake.c"
          perror_with_name((char *)"touch: open: ", file->name);
          }
# 945 "remake.c"
          return (1);
        }
      }
      {
# 947 "remake.c"
      close(fd);
      }
    }
  }
# 951 "remake.c"
  return (0);
}
}
# 958 "remake.c"
static void remake_file(struct file *file )
{
  char const *msg_noparent ;
  char *tmp ;
  char const *msg_parent ;
  char *tmp___0 ;

  {
# 962 "remake.c"
  if ((unsigned long )file->cmds == (unsigned long )((struct commands *)0)) {
# 964 "remake.c"
    if (file->phony) {
# 966 "remake.c"
      file->update_status = (short)0;
    } else
# 967 "remake.c"
    if (file->is_target) {
# 970 "remake.c"
      file->update_status = (short)0;
    } else {
      {
# 973 "remake.c"
      tmp = dcgettext((char const *)((void *)0), "%sNo rule to make target `%s\'%s",
                      5);
# 973 "remake.c"
      msg_noparent = (char const *)tmp;
# 975 "remake.c"
      tmp___0 = dcgettext((char const *)((void *)0), "%sNo rule to make target `%s\', needed by `%s\'%s",
                          5);
# 975 "remake.c"
      msg_parent = (char const *)tmp___0;
      }
# 979 "remake.c"
      if (! keep_going_flag) {
# 979 "remake.c"
        if (! file->dontcare) {
# 981 "remake.c"
          if ((unsigned long )file->parent == (unsigned long )((struct file *)0)) {
            {
# 982 "remake.c"
            fatal((struct floc const *)((struct floc *)0), msg_noparent, "", file->name,
                  "");
            }
          }
          {
# 984 "remake.c"
          fatal((struct floc const *)((struct floc *)0), msg_parent, "", file->name,
                (file->parent)->name, "");
          }
        }
      }
# 987 "remake.c"
      if (! file->dontcare) {
# 989 "remake.c"
        if ((unsigned long )file->parent == (unsigned long )((struct file *)0)) {
          {
# 990 "remake.c"
          error((struct floc const *)((struct floc *)0), msg_noparent, "*** ", file->name,
                ".");
          }
        } else {
          {
# 992 "remake.c"
          error((struct floc const *)((struct floc *)0), msg_parent, "*** ", file->name,
                (file->parent)->name, ".");
          }
        }
      }
# 995 "remake.c"
      file->update_status = (short)2;
    }
  } else {
    {
# 1000 "remake.c"
    chop_commands(file->cmds);
    }
# 1003 "remake.c"
    if (! touch_flag) {
      {
# 1005 "remake.c"
      execute_file_commands(file);
      }
# 1006 "remake.c"
      return;
    } else
# 1003 "remake.c"
    if ((file->cmds)->any_recurse) {
      {
# 1005 "remake.c"
      execute_file_commands(file);
      }
# 1006 "remake.c"
      return;
    }
# 1010 "remake.c"
    file->update_status = (short)0;
  }
  {
# 1014 "remake.c"
  notice_finished_file(file);
  }
# 1015 "remake.c"
  return;
}
}
# 1145 "remake.c"
static uintmax_t now = (uintmax_t )0;
# 1025 "remake.c"
uintmax_t f_mtime(struct file *file , int search )
{
  uintmax_t mtime ;
  char *arname ;
  char *memname ;
  struct file *arfile ;
  int arname_used ;
  char *name ;
  unsigned int arlen ;
  unsigned int memlen ;
  size_t tmp ;
  size_t tmp___0 ;
  char *tmp___1 ;
  int tmp___2 ;
  time_t tmp___3 ;
  uintmax_t tmp___4 ;
  uintmax_t tmp___5 ;
  char *name___0 ;
  uintmax_t tmp___6 ;
  uintmax_t tmp___7 ;
  size_t tmp___8 ;
  size_t tmp___9 ;
  int tmp___10 ;
  int tmp___11 ;
  int tmp___12 ;
  int tmp___13 ;
  char mtimebuf[(((((((sizeof(uintmax_t ) * 8UL - 1UL) - 24UL) * 302UL) / 1000UL + 1UL) + 1UL) + 4UL) + 25UL) + 1UL] ;
  char nowbuf[(((((((sizeof(uintmax_t ) * 8UL - 1UL) - 24UL) * 302UL) / 1000UL + 1UL) + 1UL) + 4UL) + 25UL) + 1UL] ;
  char *tmp___14 ;

  {
  {
# 1035 "remake.c"
  tmp___13 = ar_name(file->name);
  }
# 1035 "remake.c"
  if (tmp___13) {
    {
# 1041 "remake.c"
    arname_used = 0;
# 1044 "remake.c"
    ar_parse_name(file->name, & arname, & memname);
# 1048 "remake.c"
    arfile = lookup_file(arname);
    }
# 1049 "remake.c"
    if ((unsigned long )arfile == (unsigned long )((struct file *)0)) {
      {
# 1051 "remake.c"
      arfile = enter_file(arname);
# 1052 "remake.c"
      arname_used = 1;
      }
    }
    {
# 1054 "remake.c"
    mtime = f_mtime(arfile, search);
    }
    {
# 1055 "remake.c"
    while (1) {
      while_continue: ;
# 1055 "remake.c"
      if (! ((unsigned long )arfile->renamed != (unsigned long )((struct file *)0))) {
# 1055 "remake.c"
        goto while_break;
      }
# 1055 "remake.c"
      arfile = arfile->renamed;
    }
    while_break: ;
    }
# 1056 "remake.c"
    if (search) {
      {
# 1056 "remake.c"
      tmp___2 = strcmp((char const *)arfile->hname, (char const *)arname);
      }
# 1056 "remake.c"
      if (tmp___2) {
# 1064 "remake.c"
        if (! arname_used) {
          {
# 1066 "remake.c"
          free((void *)arname);
# 1067 "remake.c"
          arname_used = 1;
          }
        }
        {
# 1070 "remake.c"
        arname = arfile->hname;
# 1071 "remake.c"
        tmp = strlen((char const *)arname);
# 1071 "remake.c"
        arlen = (unsigned int )tmp;
# 1072 "remake.c"
        tmp___0 = strlen((char const *)memname);
# 1072 "remake.c"
        memlen = (unsigned int )tmp___0;
# 1076 "remake.c"
        tmp___1 = xmalloc(((arlen + 1U) + memlen) + 2U);
# 1076 "remake.c"
        name = tmp___1;
# 1077 "remake.c"
        memmove((void *)name, (void const *)arname, (size_t )arlen);
# 1078 "remake.c"
        *(name + arlen) = (char )'(';
# 1079 "remake.c"
        memmove((void *)((name + arlen) + 1), (void const *)memname, (size_t )memlen);
# 1080 "remake.c"
        *(name + ((arlen + 1U) + memlen)) = (char )')';
# 1081 "remake.c"
        *(name + (((arlen + 1U) + memlen) + 1U)) = (char )'\000';
        }
# 1085 "remake.c"
        if ((unsigned long )arfile->name == (unsigned long )arfile->hname) {
          {
# 1086 "remake.c"
          rename_file(file, name);
          }
        } else {
          {
# 1088 "remake.c"
          rehash_file(file, name);
          }
        }
        {
# 1089 "remake.c"
        while (1) {
          while_continue___0: ;
# 1089 "remake.c"
          if (! ((unsigned long )file->renamed != (unsigned long )((struct file *)0))) {
# 1089 "remake.c"
            goto while_break___0;
          }
# 1089 "remake.c"
          file = file->renamed;
        }
        while_break___0: ;
        }
      }
    }
# 1092 "remake.c"
    if (! arname_used) {
      {
# 1093 "remake.c"
      free((void *)arname);
      }
    }
    {
# 1094 "remake.c"
    free((void *)memname);
    }
# 1096 "remake.c"
    if (mtime == 0xffffffffffffffffUL) {
# 1098 "remake.c"
      return ((uintmax_t )-1);
    }
    {
# 1100 "remake.c"
    tmp___3 = ar_member_date(file->hname);
    }
# 1100 "remake.c"
    if (1000000000UL < 0xffffffffffffffffUL / (uintmax_t )(-1L - (-1L << (sizeof(time_t ) * 8UL - 1UL)))) {
# 1100 "remake.c"
      tmp___4 = (uintmax_t )1000000000;
    } else {
# 1100 "remake.c"
      tmp___4 = 0xffffffffffffffffUL / (uintmax_t )(-1L - (-1L << (sizeof(time_t ) * 8UL - 1UL)));
    }
# 1100 "remake.c"
    if (1000000000UL < 0xffffffffffffffffUL / (uintmax_t )(-1L - (-1L << (sizeof(time_t ) * 8UL - 1UL)))) {
# 1100 "remake.c"
      tmp___5 = (uintmax_t )1000000000;
    } else {
# 1100 "remake.c"
      tmp___5 = 0xffffffffffffffffUL / (uintmax_t )(-1L - (-1L << (sizeof(time_t ) * 8UL - 1UL)));
    }
# 1100 "remake.c"
    mtime = (uintmax_t )tmp___3 * tmp___4;
  } else {
    {
# 1105 "remake.c"
    mtime = name_mtime(file->name);
    }
# 1107 "remake.c"
    if (mtime == 0xffffffffffffffffUL) {
# 1107 "remake.c"
      if (search) {
# 1107 "remake.c"
        if (! file->ignore_vpath) {
          {
# 1110 "remake.c"
          name___0 = file->name;
# 1111 "remake.c"
          tmp___11 = vpath_search(& name___0, & mtime);
          }
# 1111 "remake.c"
          if (tmp___11) {
# 1111 "remake.c"
            goto _L;
          } else
# 1111 "remake.c"
          if ((int )*(name___0 + 0) == 45) {
# 1111 "remake.c"
            if ((int )*(name___0 + 1) == 108) {
              {
# 1111 "remake.c"
              tmp___12 = library_search(& name___0, & mtime);
              }
# 1111 "remake.c"
              if (tmp___12) {
                _L:
# 1116 "remake.c"
                if (mtime != 0UL) {
# 1119 "remake.c"
                  file->last_mtime = mtime;
                }
                {
# 1124 "remake.c"
                tmp___8 = strlen((char const *)name___0);
# 1124 "remake.c"
                tmp___9 = strlen((char const *)file->name);
# 1124 "remake.c"
                tmp___10 = gpath_search(name___0, (int )((tmp___8 - tmp___9) - 1UL));
                }
# 1124 "remake.c"
                if (tmp___10) {
                  {
# 1126 "remake.c"
                  rename_file(file, name___0);
                  }
                  {
# 1127 "remake.c"
                  while (1) {
                    while_continue___1: ;
# 1127 "remake.c"
                    if (! ((unsigned long )file->renamed != (unsigned long )((struct file *)0))) {
# 1127 "remake.c"
                      goto while_break___1;
                    }
# 1127 "remake.c"
                    file = file->renamed;
                  }
                  while_break___1: ;
                  }
# 1128 "remake.c"
                  if (file->last_mtime) {
# 1128 "remake.c"
                    tmp___7 = file->last_mtime;
                  } else {
                    {
# 1128 "remake.c"
                    tmp___6 = f_mtime(file, 1);
# 1128 "remake.c"
                    tmp___7 = tmp___6;
                    }
                  }
# 1128 "remake.c"
                  return (tmp___7);
                }
                {
# 1131 "remake.c"
                rehash_file(file, name___0);
                }
                {
# 1132 "remake.c"
                while (1) {
                  while_continue___2: ;
# 1132 "remake.c"
                  if (! ((unsigned long )file->renamed != (unsigned long )((struct file *)0))) {
# 1132 "remake.c"
                    goto while_break___2;
                  }
# 1132 "remake.c"
                  file = file->renamed;
                }
                while_break___2: ;
                }
                {
# 1133 "remake.c"
                mtime = name_mtime(name___0);
                }
              }
            }
          }
        }
      }
    }
  }
# 1146 "remake.c"
  if (! clock_skew_detected) {
# 1146 "remake.c"
    if (mtime != 0xffffffffffffffffUL) {
# 1146 "remake.c"
      if (mtime > now) {
# 1146 "remake.c"
        if (! file->updated) {
          {
# 1153 "remake.c"
          now = file_timestamp_now();
          }
# 1168 "remake.c"
          if (mtime > now) {
            {
# 1175 "remake.c"
            file_timestamp_sprintf(mtimebuf, mtime);
# 1176 "remake.c"
            file_timestamp_sprintf(nowbuf, now);
# 1177 "remake.c"
            tmp___14 = dcgettext((char const *)((void *)0), "*** Warning: File `%s\' has modification time in the future (%s > %s)",
                                 5);
# 1177 "remake.c"
            error((struct floc const *)((struct floc *)0), (char const *)tmp___14,
                  file->name, mtimebuf, nowbuf);
# 1179 "remake.c"
            clock_skew_detected = 1;
            }
          }
        }
      }
    }
  }
# 1185 "remake.c"
  if (file->double_colon) {
# 1186 "remake.c"
    file = file->double_colon;
  }
  {
# 1188 "remake.c"
  while (1) {
    while_continue___3: ;
# 1195 "remake.c"
    if (mtime != 0xffffffffffffffffUL) {
# 1195 "remake.c"
      if ((unsigned int )file->command_state == 0U) {
# 1195 "remake.c"
        if (! file->tried_implicit) {
# 1195 "remake.c"
          if (file->intermediate) {
# 1197 "remake.c"
            file->intermediate = 0U;
          }
        }
      }
    }
# 1199 "remake.c"
    file->last_mtime = mtime;
# 1200 "remake.c"
    file = file->prev;
# 1188 "remake.c"
    if (! ((unsigned long )file != (unsigned long )((struct file *)0))) {
# 1188 "remake.c"
      goto while_break___3;
    }
  }
  while_break___3: ;
  }
# 1204 "remake.c"
  return (mtime);
}
}
# 1210 "remake.c"
static uintmax_t name_mtime(char *name )
{
  struct stat st ;
  int tmp ;
  uintmax_t tmp___0 ;
  uintmax_t tmp___1 ;

  {
  {
# 1216 "remake.c"
  tmp = stat((char const * __restrict )name, (struct stat * __restrict )(& st));
  }
# 1216 "remake.c"
  if (tmp < 0) {
# 1217 "remake.c"
    return ((uintmax_t )-1);
  }
# 1219 "remake.c"
  if (1000000000UL < 0xffffffffffffffffUL / (uintmax_t )(-1L - (-1L << (sizeof(time_t ) * 8UL - 1UL)))) {
# 1219 "remake.c"
    tmp___0 = (uintmax_t )1000000000;
  } else {
# 1219 "remake.c"
    tmp___0 = 0xffffffffffffffffUL / (uintmax_t )(-1L - (-1L << (sizeof(time_t ) * 8UL - 1UL)));
  }
# 1219 "remake.c"
  if (1000000000UL < 0xffffffffffffffffUL / (uintmax_t )(-1L - (-1L << (sizeof(time_t ) * 8UL - 1UL)))) {
# 1219 "remake.c"
    tmp___1 = (uintmax_t )1000000000;
  } else {
# 1219 "remake.c"
    tmp___1 = 0xffffffffffffffffUL / (uintmax_t )(-1L - (-1L << (sizeof(time_t ) * 8UL - 1UL)));
  }
# 1219 "remake.c"
  return ((uintmax_t )st.st_mtim.tv_sec * tmp___0 + ((uintmax_t )st.st_mtim.tv_nsec * tmp___1) / 1000000000UL);
}
}
# 1232 "remake.c"
static char *dirs[4] = { (char *)"/lib", (char *)"/usr/lib", (char *)"/usr/local/lib", (char *)0};
# 1249 "remake.c"
static char *libpatterns = (char *)((void *)0);
# 1275 "remake.c"
static char *buf___0 = (char *)((void *)0);
# 1276 "remake.c"
static int buflen = 0;
# 1277 "remake.c"
static int libdir_maxlen = -1;
# 1227 "remake.c"
static int library_search(char **lib , uintmax_t *mtime_ptr )
{
  char *libname ;
  uintmax_t mtime ;
  char *p ;
  char *p2 ;
  unsigned int len ;
  char *file ;
  char **dp ;
  int save ;
  char *tmp ;
  char *libbuf ;
  char *tmp___0 ;
  char c ;
  char *p3 ;
  char *p4 ;
  char *tmp___1 ;
  size_t tmp___2 ;
  int tmp___3 ;
  int l ;
  size_t tmp___4 ;
  size_t tmp___5 ;
  size_t tmp___6 ;
  size_t tmp___7 ;

  {
# 1251 "remake.c"
  libname = *lib + 2;
# 1261 "remake.c"
  if (! libpatterns) {
    {
# 1263 "remake.c"
    save = warn_undefined_variables_flag;
# 1264 "remake.c"
    warn_undefined_variables_flag = 0;
# 1266 "remake.c"
    tmp = variable_expand((char *)"$(strip $(.LIBPATTERNS))");
# 1266 "remake.c"
    libpatterns = xstrdup((char const *)tmp);
# 1268 "remake.c"
    warn_undefined_variables_flag = save;
    }
  }
# 1272 "remake.c"
  p2 = libpatterns;
  {
# 1273 "remake.c"
  while (1) {
    while_continue: ;
    {
# 1273 "remake.c"
    p = find_next_token(& p2, & len);
    }
# 1273 "remake.c"
    if (! ((unsigned long )p != (unsigned long )((char *)0))) {
# 1273 "remake.c"
      goto while_break;
    }
    {
# 1278 "remake.c"
    tmp___0 = variable_expand((char *)"");
# 1278 "remake.c"
    libbuf = tmp___0;
# 1282 "remake.c"
    c = *(p + len);
# 1285 "remake.c"
    *(p + len) = (char )'\000';
# 1286 "remake.c"
    p3 = find_percent(p);
    }
# 1287 "remake.c"
    if (! p3) {
      {
# 1291 "remake.c"
      tmp___1 = dcgettext((char const *)((void *)0), ".LIBPATTERNS element `%s\' is not a pattern",
                          5);
# 1291 "remake.c"
      error((struct floc const *)((struct floc *)0), (char const *)tmp___1, p);
      }
      {
# 1292 "remake.c"
      while (1) {
        while_continue___0: ;
# 1292 "remake.c"
        if (! len) {
# 1292 "remake.c"
          goto while_break___0;
        }
# 1293 "remake.c"
        *p = (char )' ';
# 1292 "remake.c"
        len --;
# 1292 "remake.c"
        p ++;
      }
      while_break___0: ;
      }
# 1294 "remake.c"
      *p = c;
# 1295 "remake.c"
      goto while_continue;
    }
    {
# 1297 "remake.c"
    p4 = variable_buffer_output(libbuf, p, (unsigned int )(p3 - p));
# 1298 "remake.c"
    tmp___2 = strlen((char const *)libname);
# 1298 "remake.c"
    p4 = variable_buffer_output(p4, libname, (unsigned int )tmp___2);
# 1299 "remake.c"
    p4 = variable_buffer_output(p4, p3 + 1, (unsigned int )((long )len - (p3 - p)));
# 1300 "remake.c"
    *(p + len) = c;
# 1304 "remake.c"
    mtime = name_mtime(libbuf);
    }
# 1305 "remake.c"
    if (mtime != 0xffffffffffffffffUL) {
      {
# 1307 "remake.c"
      *lib = xstrdup((char const *)libbuf);
      }
# 1308 "remake.c"
      if ((unsigned long )mtime_ptr != (unsigned long )((uintmax_t *)0)) {
# 1309 "remake.c"
        *mtime_ptr = mtime;
      }
# 1310 "remake.c"
      return (1);
    }
    {
# 1315 "remake.c"
    file = libbuf;
# 1316 "remake.c"
    tmp___3 = vpath_search(& file, mtime_ptr);
    }
# 1316 "remake.c"
    if (tmp___3) {
# 1318 "remake.c"
      *lib = file;
# 1319 "remake.c"
      return (1);
    }
# 1324 "remake.c"
    if (! buflen) {
# 1326 "remake.c"
      dp = dirs;
      {
# 1326 "remake.c"
      while (1) {
        while_continue___1: ;
# 1326 "remake.c"
        if (! ((unsigned long )*dp != (unsigned long )((char *)0))) {
# 1326 "remake.c"
          goto while_break___1;
        }
        {
# 1328 "remake.c"
        tmp___4 = strlen((char const *)*dp);
# 1328 "remake.c"
        l = (int )tmp___4;
        }
# 1329 "remake.c"
        if (l > libdir_maxlen) {
# 1330 "remake.c"
          libdir_maxlen = l;
        }
# 1326 "remake.c"
        dp ++;
      }
      while_break___1: ;
      }
      {
# 1332 "remake.c"
      tmp___5 = strlen((char const *)libbuf);
# 1332 "remake.c"
      buflen = (int )tmp___5;
# 1333 "remake.c"
      buf___0 = xmalloc((unsigned int )((libdir_maxlen + buflen) + 2));
      }
    } else {
      {
# 1335 "remake.c"
      tmp___7 = strlen((char const *)libbuf);
      }
# 1335 "remake.c"
      if ((size_t )buflen < tmp___7) {
        {
# 1337 "remake.c"
        tmp___6 = strlen((char const *)libbuf);
# 1337 "remake.c"
        buflen = (int )tmp___6;
# 1338 "remake.c"
        buf___0 = xrealloc(buf___0, (unsigned int )((libdir_maxlen + buflen) + 2));
        }
      }
    }
# 1341 "remake.c"
    dp = dirs;
    {
# 1341 "remake.c"
    while (1) {
      while_continue___2: ;
# 1341 "remake.c"
      if (! ((unsigned long )*dp != (unsigned long )((char *)0))) {
# 1341 "remake.c"
        goto while_break___2;
      }
      {
# 1343 "remake.c"
      sprintf((char * __restrict )buf___0, (char const * __restrict )"%s/%s",
              *dp, libbuf);
# 1344 "remake.c"
      mtime = name_mtime(buf___0);
      }
# 1345 "remake.c"
      if (mtime != 0xffffffffffffffffUL) {
        {
# 1347 "remake.c"
        *lib = xstrdup((char const *)buf___0);
        }
# 1348 "remake.c"
        if ((unsigned long )mtime_ptr != (unsigned long )((uintmax_t *)0)) {
# 1349 "remake.c"
          *mtime_ptr = mtime;
        }
# 1350 "remake.c"
        return (1);
      }
# 1341 "remake.c"
      dp ++;
    }
    while_break___2: ;
    }
  }
  while_break: ;
  }
# 1355 "remake.c"
  return (0);
}
}
# 1 "rule.o"
#pragma merger("0","/tmp/cil-ku_yXt8Q.i","-g,-O0")
# 101 "variable.h"
struct variable_set_list *create_new_variable_set(void) ;
# 107 "variable.h"
void print_variable_set(struct variable_set *set , char *prefix ) ;
# 51 "rule.h"
struct rule *last_pattern_rule ;
# 59 "rule.h"
unsigned int maxsuffix ;
# 62 "rule.h"
void install_pattern_rule(struct pspec *p , int terminal ) ;
# 63 "rule.h"
int new_pattern_rule(struct rule *rule , int override ) ;
# 65 "rule.h"
struct pattern_var *lookup_pattern_var(char *target ) ;
# 28 "rule.c"
static void freerule(struct rule *rule , struct rule *lastrule ) ;
# 56 "rule.c"
static struct pattern_var *pattern_vars ;
# 60 "rule.c"
static struct pattern_var *last_pattern_var ;
# 76 "rule.c"
void count_implicit_rule_limits(void)
{
  char *name ;
  unsigned int namelen ;
  register struct rule *rule ;
  register struct rule *lastrule ;
  unsigned int ndeps ;
  register struct dep *dep ;
  struct rule *next ;
  unsigned int ntargets ;
  unsigned int len ;
  size_t tmp ;
  char *p ;
  char *tmp___0 ;
  char *p2 ;
  char *tmp___1 ;
  char *tmp___2 ;
  char *tmp___3 ;
  int tmp___4 ;
  int tmp___5 ;

  {
# 83 "rule.c"
  max_pattern_deps = 0U;
# 83 "rule.c"
  max_pattern_targets = max_pattern_deps;
# 83 "rule.c"
  num_pattern_rules = max_pattern_targets;
# 84 "rule.c"
  max_pattern_dep_length = 0U;
# 86 "rule.c"
  name = (char *)0;
# 87 "rule.c"
  namelen = 0U;
# 88 "rule.c"
  rule = pattern_rules;
# 89 "rule.c"
  lastrule = (struct rule *)0;
  {
# 90 "rule.c"
  while (1) {
    while_continue: ;
# 90 "rule.c"
    if (! ((unsigned long )rule != (unsigned long )((struct rule *)0))) {
# 90 "rule.c"
      goto while_break;
    }
# 92 "rule.c"
    ndeps = 0U;
# 94 "rule.c"
    next = rule->next;
# 97 "rule.c"
    num_pattern_rules ++;
# 99 "rule.c"
    ntargets = 0U;
    {
# 100 "rule.c"
    while (1) {
      while_continue___0: ;
# 100 "rule.c"
      if (! ((unsigned long )*(rule->targets + ntargets) != (unsigned long )((char *)0))) {
# 100 "rule.c"
        goto while_break___0;
      }
# 101 "rule.c"
      ntargets ++;
    }
    while_break___0: ;
    }
# 103 "rule.c"
    if (ntargets > max_pattern_targets) {
# 104 "rule.c"
      max_pattern_targets = ntargets;
    }
# 106 "rule.c"
    dep = rule->deps;
    {
# 106 "rule.c"
    while (1) {
      while_continue___1: ;
# 106 "rule.c"
      if (! ((unsigned long )dep != (unsigned long )((struct dep *)0))) {
# 106 "rule.c"
        goto while_break___1;
      }
      {
# 108 "rule.c"
      tmp = strlen((char const *)dep->name);
# 108 "rule.c"
      len = (unsigned int )tmp;
# 117 "rule.c"
      tmp___0 = strrchr((char const *)dep->name, '/');
# 117 "rule.c"
      p = tmp___0;
      }
# 118 "rule.c"
      if ((unsigned long )p != (unsigned long )((char *)0)) {
        {
# 118 "rule.c"
        tmp___1 = strchr((char const *)dep->name, '%');
# 118 "rule.c"
        tmp___2 = tmp___1;
        }
      } else {
# 118 "rule.c"
        tmp___2 = (char *)0;
      }
# 118 "rule.c"
      p2 = tmp___2;
# 120 "rule.c"
      ndeps ++;
# 122 "rule.c"
      if (len > max_pattern_dep_length) {
# 123 "rule.c"
        max_pattern_dep_length = len;
      }
# 125 "rule.c"
      if ((unsigned long )p != (unsigned long )((char *)0)) {
# 125 "rule.c"
        if ((unsigned long )p2 > (unsigned long )p) {
# 129 "rule.c"
          if ((unsigned long )p == (unsigned long )dep->name) {
# 130 "rule.c"
            p ++;
          }
# 131 "rule.c"
          if (p - dep->name > (long )namelen) {
# 133 "rule.c"
            if ((unsigned long )name != (unsigned long )((char *)0)) {
              {
# 134 "rule.c"
              free((void *)name);
              }
            }
            {
# 135 "rule.c"
            namelen = (unsigned int )(p - dep->name);
# 136 "rule.c"
            tmp___3 = xmalloc(namelen + 1U);
# 136 "rule.c"
            name = tmp___3;
            }
          }
          {
# 138 "rule.c"
          memmove((void *)name, (void const *)dep->name, (size_t )(p - dep->name));
# 139 "rule.c"
          *(name + (p - dep->name)) = (char )'\000';
# 145 "rule.c"
          tmp___4 = dir_file_exists_p(name, (char *)"");
          }
# 145 "rule.c"
          if (tmp___4) {
# 145 "rule.c"
            tmp___5 = 0;
          } else {
# 145 "rule.c"
            tmp___5 = 1;
          }
# 145 "rule.c"
          dep->changed = tmp___5;
# 149 "rule.c"
          if (dep->changed) {
# 149 "rule.c"
            if ((int )*name == 47) {
              {
# 156 "rule.c"
              freerule(rule, lastrule);
# 157 "rule.c"
              num_pattern_rules --;
              }
# 158 "rule.c"
              goto end_main_loop;
            }
          }
        } else {
# 163 "rule.c"
          dep->changed = 0;
        }
      } else {
# 163 "rule.c"
        dep->changed = 0;
      }
# 106 "rule.c"
      dep = dep->next;
    }
    while_break___1: ;
    }
# 166 "rule.c"
    if (ndeps > max_pattern_deps) {
# 167 "rule.c"
      max_pattern_deps = ndeps;
    }
# 169 "rule.c"
    lastrule = rule;
    end_main_loop:
# 171 "rule.c"
    rule = next;
  }
  while_break: ;
  }
# 174 "rule.c"
  if ((unsigned long )name != (unsigned long )((char *)0)) {
    {
# 175 "rule.c"
    free((void *)name);
    }
  }
# 176 "rule.c"
  return;
}
}
# 184 "rule.c"
static void convert_suffix_rule(char *target , char *source , struct commands *cmds )
{
  char *targname ;
  char *targpercent ;
  char *depname ;
  char **names ;
  char **percents ;
  struct dep *deps ;
  unsigned int len ;
  size_t tmp ;
  char *tmp___0 ;
  void *tmp___1 ;
  char *tmp___2 ;
  size_t tmp___3 ;
  char *tmp___4 ;

  {
# 194 "rule.c"
  if ((unsigned long )target == (unsigned long )((char *)0)) {
    {
# 201 "rule.c"
    targname = savestring("(%.o)", 5U);
# 203 "rule.c"
    targpercent = targname + 1;
    }
  } else {
    {
# 208 "rule.c"
    tmp = strlen((char const *)target);
# 208 "rule.c"
    len = (unsigned int )tmp;
# 209 "rule.c"
    targname = xmalloc((1U + len) + 1U);
# 210 "rule.c"
    *(targname + 0) = (char )'%';
# 211 "rule.c"
    memmove((void *)(targname + 1), (void const *)target, (size_t )(len + 1U));
# 212 "rule.c"
    targpercent = targname;
    }
  }
  {
# 215 "rule.c"
  tmp___0 = xmalloc((unsigned int )(2UL * sizeof(char *)));
# 215 "rule.c"
  names = (char **)tmp___0;
# 216 "rule.c"
  tmp___1 = __builtin_alloca(2UL * sizeof(char *));
# 216 "rule.c"
  percents = (char **)tmp___1;
# 217 "rule.c"
  *(names + 0) = targname;
# 218 "rule.c"
  *(percents + 0) = targpercent;
# 219 "rule.c"
  tmp___2 = (char *)0;
# 219 "rule.c"
  *(percents + 1) = tmp___2;
# 219 "rule.c"
  *(names + 1) = tmp___2;
  }
# 221 "rule.c"
  if ((unsigned long )source == (unsigned long )((char *)0)) {
# 222 "rule.c"
    deps = (struct dep *)0;
  } else {
    {
# 226 "rule.c"
    tmp___3 = strlen((char const *)source);
# 226 "rule.c"
    len = (unsigned int )tmp___3;
# 227 "rule.c"
    depname = xmalloc((1U + len) + 1U);
# 228 "rule.c"
    *(depname + 0) = (char )'%';
# 229 "rule.c"
    memmove((void *)(depname + 1), (void const *)source, (size_t )(len + 1U));
# 230 "rule.c"
    tmp___4 = xmalloc((unsigned int )sizeof(struct dep ));
# 230 "rule.c"
    deps = (struct dep *)tmp___4;
# 231 "rule.c"
    deps->next = (struct dep *)0;
# 232 "rule.c"
    deps->name = depname;
    }
  }
  {
# 235 "rule.c"
  create_pattern_rule(names, percents, 0, deps, cmds, 0);
  }
# 236 "rule.c"
  return;
}
}
# 242 "rule.c"
void convert_to_pattern(void)
{
  register struct dep *d ;
  register struct dep *d2 ;
  register struct file *f ;
  register char *rulename ;
  register unsigned int slen ;
  register unsigned int s2len ;
  register unsigned int namelen ;
  char *tmp ;
  size_t tmp___0 ;
  void *tmp___1 ;
  char *tmp___2 ;
  char *tmp___3 ;
  char *tmp___4 ;
  size_t tmp___5 ;
  char *tmp___6 ;
  char *tmp___7 ;
  size_t tmp___8 ;
  char *tmp___9 ;
  char *tmp___10 ;
  char *tmp___11 ;
  char *tmp___12 ;
  char *tmp___13 ;
  char *tmp___14 ;
  char *tmp___15 ;
  int tmp___16 ;
  char *tmp___17 ;
  char *tmp___18 ;
  char *tmp___19 ;
  char *tmp___20 ;

  {
# 252 "rule.c"
  maxsuffix = 0U;
# 253 "rule.c"
  d = suffix_file->deps;
  {
# 253 "rule.c"
  while (1) {
    while_continue: ;
# 253 "rule.c"
    if (! ((unsigned long )d != (unsigned long )((struct dep *)0))) {
# 253 "rule.c"
      goto while_break;
    }
# 255 "rule.c"
    if ((unsigned long )d->name == (unsigned long )((char *)0)) {
# 255 "rule.c"
      tmp = (d->file)->name;
    } else {
# 255 "rule.c"
      tmp = d->name;
    }
    {
# 255 "rule.c"
    tmp___0 = strlen((char const *)tmp);
# 255 "rule.c"
    namelen = (unsigned int )tmp___0;
    }
# 256 "rule.c"
    if (namelen > maxsuffix) {
# 257 "rule.c"
      maxsuffix = namelen;
    }
# 253 "rule.c"
    d = d->next;
  }
  while_break: ;
  }
  {
# 260 "rule.c"
  tmp___1 = __builtin_alloca((unsigned long )(maxsuffix * 2U + 1U));
# 260 "rule.c"
  rulename = (char *)tmp___1;
# 262 "rule.c"
  d = suffix_file->deps;
  }
  {
# 262 "rule.c"
  while (1) {
    while_continue___0: ;
# 262 "rule.c"
    if (! ((unsigned long )d != (unsigned long )((struct dep *)0))) {
# 262 "rule.c"
      goto while_break___0;
    }
# 266 "rule.c"
    if ((unsigned long )d->name == (unsigned long )((char *)0)) {
# 266 "rule.c"
      tmp___2 = (d->file)->name;
    } else {
# 266 "rule.c"
      tmp___2 = d->name;
    }
    {
# 266 "rule.c"
    convert_suffix_rule(tmp___2, (char *)0, (struct commands *)0);
# 268 "rule.c"
    f = d->file;
    }
# 269 "rule.c"
    if ((unsigned long )f->cmds != (unsigned long )((struct commands *)0)) {
# 271 "rule.c"
      if ((unsigned long )d->name == (unsigned long )((char *)0)) {
# 271 "rule.c"
        tmp___3 = (d->file)->name;
      } else {
# 271 "rule.c"
        tmp___3 = d->name;
      }
      {
# 271 "rule.c"
      convert_suffix_rule((char *)"", tmp___3, f->cmds);
      }
    }
# 274 "rule.c"
    if ((unsigned long )d->name == (unsigned long )((char *)0)) {
# 274 "rule.c"
      tmp___4 = (d->file)->name;
    } else {
# 274 "rule.c"
      tmp___4 = d->name;
    }
    {
# 274 "rule.c"
    tmp___5 = strlen((char const *)tmp___4);
# 274 "rule.c"
    slen = (unsigned int )tmp___5;
    }
# 275 "rule.c"
    if ((unsigned long )d->name == (unsigned long )((char *)0)) {
# 275 "rule.c"
      tmp___6 = (d->file)->name;
    } else {
# 275 "rule.c"
      tmp___6 = d->name;
    }
    {
# 275 "rule.c"
    memmove((void *)rulename, (void const *)tmp___6, (size_t )slen);
# 276 "rule.c"
    d2 = suffix_file->deps;
    }
    {
# 276 "rule.c"
    while (1) {
      while_continue___1: ;
# 276 "rule.c"
      if (! ((unsigned long )d2 != (unsigned long )((struct dep *)0))) {
# 276 "rule.c"
        goto while_break___1;
      }
# 278 "rule.c"
      if ((unsigned long )d2->name == (unsigned long )((char *)0)) {
# 278 "rule.c"
        tmp___7 = (d2->file)->name;
      } else {
# 278 "rule.c"
        tmp___7 = d2->name;
      }
      {
# 278 "rule.c"
      tmp___8 = strlen((char const *)tmp___7);
# 278 "rule.c"
      s2len = (unsigned int )tmp___8;
      }
# 280 "rule.c"
      if (slen == s2len) {
# 280 "rule.c"
        if ((unsigned long )d->name == (unsigned long )((char *)0)) {
# 280 "rule.c"
          tmp___9 = (d->file)->name;
        } else {
# 280 "rule.c"
          tmp___9 = d->name;
        }
# 280 "rule.c"
        if ((unsigned long )d2->name == (unsigned long )((char *)0)) {
# 280 "rule.c"
          tmp___10 = (d2->file)->name;
        } else {
# 280 "rule.c"
          tmp___10 = d2->name;
        }
# 280 "rule.c"
        if ((unsigned long )tmp___9 == (unsigned long )tmp___10) {
# 281 "rule.c"
          goto __Cont;
        } else {
# 280 "rule.c"
          if ((unsigned long )d->name == (unsigned long )((char *)0)) {
# 280 "rule.c"
            tmp___11 = (d->file)->name;
          } else {
# 280 "rule.c"
            tmp___11 = d->name;
          }
# 280 "rule.c"
          if ((unsigned long )d2->name == (unsigned long )((char *)0)) {
# 280 "rule.c"
            tmp___12 = (d2->file)->name;
          } else {
# 280 "rule.c"
            tmp___12 = d2->name;
          }
# 280 "rule.c"
          if ((int )*tmp___11 == (int )*tmp___12) {
# 280 "rule.c"
            if ((unsigned long )d->name == (unsigned long )((char *)0)) {
# 280 "rule.c"
              tmp___13 = (d->file)->name;
            } else {
# 280 "rule.c"
              tmp___13 = d->name;
            }
# 280 "rule.c"
            if ((int )*tmp___13 == 0) {
# 281 "rule.c"
              goto __Cont;
            } else {
# 280 "rule.c"
              if ((unsigned long )d2->name == (unsigned long )((char *)0)) {
# 280 "rule.c"
                tmp___14 = (d2->file)->name;
              } else {
# 280 "rule.c"
                tmp___14 = d2->name;
              }
# 280 "rule.c"
              if ((unsigned long )d->name == (unsigned long )((char *)0)) {
# 280 "rule.c"
                tmp___15 = (d->file)->name;
              } else {
# 280 "rule.c"
                tmp___15 = d->name;
              }
              {
# 280 "rule.c"
              tmp___16 = strcmp((char const *)(tmp___15 + 1), (char const *)(tmp___14 + 1));
              }
# 280 "rule.c"
              if (! tmp___16) {
# 281 "rule.c"
                goto __Cont;
              }
            }
          }
        }
      }
# 283 "rule.c"
      if ((unsigned long )d2->name == (unsigned long )((char *)0)) {
# 283 "rule.c"
        tmp___17 = (d2->file)->name;
      } else {
# 283 "rule.c"
        tmp___17 = d2->name;
      }
      {
# 283 "rule.c"
      memmove((void *)(rulename + slen), (void const *)tmp___17, (size_t )(s2len + 1U));
# 284 "rule.c"
      f = lookup_file(rulename);
      }
# 285 "rule.c"
      if ((unsigned long )f == (unsigned long )((struct file *)0)) {
# 286 "rule.c"
        goto __Cont;
      } else
# 285 "rule.c"
      if ((unsigned long )f->cmds == (unsigned long )((struct commands *)0)) {
# 286 "rule.c"
        goto __Cont;
      }
# 288 "rule.c"
      if (s2len == 2U) {
# 288 "rule.c"
        if ((int )*(rulename + slen) == 46) {
# 288 "rule.c"
          if ((int )*(rulename + (slen + 1U)) == 97) {
# 291 "rule.c"
            if ((unsigned long )d->name == (unsigned long )((char *)0)) {
# 291 "rule.c"
              tmp___18 = (d->file)->name;
            } else {
# 291 "rule.c"
              tmp___18 = d->name;
            }
            {
# 291 "rule.c"
            convert_suffix_rule((char *)0, tmp___18, f->cmds);
            }
          }
        }
      }
# 297 "rule.c"
      if ((unsigned long )d->name == (unsigned long )((char *)0)) {
# 297 "rule.c"
        tmp___19 = (d->file)->name;
      } else {
# 297 "rule.c"
        tmp___19 = d->name;
      }
# 297 "rule.c"
      if ((unsigned long )d2->name == (unsigned long )((char *)0)) {
# 297 "rule.c"
        tmp___20 = (d2->file)->name;
      } else {
# 297 "rule.c"
        tmp___20 = d2->name;
      }
      {
# 297 "rule.c"
      convert_suffix_rule(tmp___20, tmp___19, f->cmds);
      }
      __Cont:
# 276 "rule.c"
      d2 = d2->next;
    }
    while_break___1: ;
    }
# 262 "rule.c"
    d = d->next;
  }
  while_break___0: ;
  }
# 300 "rule.c"
  return;
}
}
# 311 "rule.c"
int new_pattern_rule(struct rule *rule , int override )
{
  register struct rule *r ;
  register struct rule *lastrule ;
  register unsigned int i ;
  register unsigned int j ;
  int tmp ;
  register struct dep *d ;
  register struct dep *d2 ;
  char *tmp___0 ;
  char *tmp___1 ;
  char *tmp___2 ;
  char *tmp___3 ;
  char *tmp___4 ;
  char *tmp___5 ;
  char *tmp___6 ;
  int tmp___7 ;

  {
# 319 "rule.c"
  rule->in_use = (char)0;
# 320 "rule.c"
  rule->terminal = (char)0;
# 322 "rule.c"
  rule->next = (struct rule *)0;
# 325 "rule.c"
  lastrule = (struct rule *)0;
# 326 "rule.c"
  r = pattern_rules;
  {
# 326 "rule.c"
  while (1) {
    while_continue: ;
# 326 "rule.c"
    if (! ((unsigned long )r != (unsigned long )((struct rule *)0))) {
# 326 "rule.c"
      goto while_break;
    }
# 327 "rule.c"
    i = 0U;
    {
# 327 "rule.c"
    while (1) {
      while_continue___0: ;
# 327 "rule.c"
      if (! ((unsigned long )*(rule->targets + i) != (unsigned long )((char *)0))) {
# 327 "rule.c"
        goto while_break___0;
      }
# 329 "rule.c"
      j = 0U;
      {
# 329 "rule.c"
      while (1) {
        while_continue___1: ;
# 329 "rule.c"
        if (! ((unsigned long )*(r->targets + j) != (unsigned long )((char *)0))) {
# 329 "rule.c"
          goto while_break___1;
        }
# 330 "rule.c"
        if (! ((unsigned long )*(rule->targets + i) == (unsigned long )*(r->targets + j))) {
# 330 "rule.c"
          if ((int )*(*(rule->targets + i)) == (int )*(*(r->targets + j))) {
# 330 "rule.c"
            if (! ((int )*(*(rule->targets + i)) == 0)) {
              {
# 330 "rule.c"
              tmp = strcmp((char const *)(*(rule->targets + i) + 1), (char const *)(*(r->targets + j) + 1));
              }
# 330 "rule.c"
              if (tmp) {
# 331 "rule.c"
                goto while_break___1;
              }
            }
          } else {
# 331 "rule.c"
            goto while_break___1;
          }
        }
# 329 "rule.c"
        j ++;
      }
      while_break___1: ;
      }
# 332 "rule.c"
      if ((unsigned long )*(r->targets + j) == (unsigned long )((char *)0)) {
# 336 "rule.c"
        d = rule->deps;
# 336 "rule.c"
        d2 = r->deps;
        {
# 336 "rule.c"
        while (1) {
          while_continue___2: ;
# 336 "rule.c"
          if ((unsigned long )d != (unsigned long )((struct dep *)0)) {
# 336 "rule.c"
            if (! ((unsigned long )d2 != (unsigned long )((struct dep *)0))) {
# 336 "rule.c"
              goto while_break___2;
            }
          } else {
# 336 "rule.c"
            goto while_break___2;
          }
# 338 "rule.c"
          if ((unsigned long )d->name == (unsigned long )((char *)0)) {
# 338 "rule.c"
            tmp___0 = (d->file)->name;
          } else {
# 338 "rule.c"
            tmp___0 = d->name;
          }
# 338 "rule.c"
          if ((unsigned long )d2->name == (unsigned long )((char *)0)) {
# 338 "rule.c"
            tmp___1 = (d2->file)->name;
          } else {
# 338 "rule.c"
            tmp___1 = d2->name;
          }
# 338 "rule.c"
          if (! ((unsigned long )tmp___0 == (unsigned long )tmp___1)) {
# 338 "rule.c"
            if ((unsigned long )d->name == (unsigned long )((char *)0)) {
# 338 "rule.c"
              tmp___2 = (d->file)->name;
            } else {
# 338 "rule.c"
              tmp___2 = d->name;
            }
# 338 "rule.c"
            if ((unsigned long )d2->name == (unsigned long )((char *)0)) {
# 338 "rule.c"
              tmp___3 = (d2->file)->name;
            } else {
# 338 "rule.c"
              tmp___3 = d2->name;
            }
# 338 "rule.c"
            if ((int )*tmp___2 == (int )*tmp___3) {
# 338 "rule.c"
              if ((unsigned long )d->name == (unsigned long )((char *)0)) {
# 338 "rule.c"
                tmp___4 = (d->file)->name;
              } else {
# 338 "rule.c"
                tmp___4 = d->name;
              }
# 338 "rule.c"
              if (! ((int )*tmp___4 == 0)) {
# 338 "rule.c"
                if ((unsigned long )d2->name == (unsigned long )((char *)0)) {
# 338 "rule.c"
                  tmp___5 = (d2->file)->name;
                } else {
# 338 "rule.c"
                  tmp___5 = d2->name;
                }
# 338 "rule.c"
                if ((unsigned long )d->name == (unsigned long )((char *)0)) {
# 338 "rule.c"
                  tmp___6 = (d->file)->name;
                } else {
# 338 "rule.c"
                  tmp___6 = d->name;
                }
                {
# 338 "rule.c"
                tmp___7 = strcmp((char const *)(tmp___6 + 1), (char const *)(tmp___5 + 1));
                }
# 338 "rule.c"
                if (tmp___7) {
# 339 "rule.c"
                  goto while_break___2;
                }
              }
            } else {
# 339 "rule.c"
              goto while_break___2;
            }
          }
# 336 "rule.c"
          d = d->next;
# 336 "rule.c"
          d2 = d2->next;
        }
        while_break___2: ;
        }
# 340 "rule.c"
        if ((unsigned long )d == (unsigned long )((struct dep *)0)) {
# 340 "rule.c"
          if ((unsigned long )d2 == (unsigned long )((struct dep *)0)) {
# 343 "rule.c"
            if (override) {
              {
# 346 "rule.c"
              freerule(r, lastrule);
              }
# 348 "rule.c"
              if ((unsigned long )pattern_rules == (unsigned long )((struct rule *)0)) {
# 349 "rule.c"
                pattern_rules = rule;
              } else {
# 351 "rule.c"
                last_pattern_rule->next = rule;
              }
# 352 "rule.c"
              last_pattern_rule = rule;
# 355 "rule.c"
              goto matched;
            } else {
              {
# 360 "rule.c"
              freerule(rule, (struct rule *)0);
              }
# 361 "rule.c"
              return (0);
            }
          }
        }
      }
# 327 "rule.c"
      i ++;
    }
    while_break___0: ;
    }
# 326 "rule.c"
    lastrule = r;
# 326 "rule.c"
    r = r->next;
  }
  while_break: ;
  }
  matched: ;
# 369 "rule.c"
  if ((unsigned long )r == (unsigned long )((struct rule *)0)) {
# 372 "rule.c"
    if ((unsigned long )pattern_rules == (unsigned long )((struct rule *)0)) {
# 373 "rule.c"
      pattern_rules = rule;
    } else {
# 375 "rule.c"
      last_pattern_rule->next = rule;
    }
# 376 "rule.c"
    last_pattern_rule = rule;
  }
# 379 "rule.c"
  return (1);
}
}
# 388 "rule.c"
void install_pattern_rule(struct pspec *p , int terminal )
{
  register struct rule *r ;
  char *ptr ;
  char *tmp ;
  char *tmp___0 ;
  char *tmp___1 ;
  char *tmp___2 ;
  size_t tmp___3 ;
  struct nameseq *tmp___4 ;
  struct nameseq *tmp___5 ;
  char *tmp___6 ;
  int tmp___7 ;

  {
  {
# 396 "rule.c"
  tmp = xmalloc((unsigned int )sizeof(struct rule ));
# 396 "rule.c"
  r = (struct rule *)tmp;
# 398 "rule.c"
  tmp___0 = xmalloc((unsigned int )(2UL * sizeof(char *)));
# 398 "rule.c"
  r->targets = (char **)tmp___0;
# 399 "rule.c"
  tmp___1 = xmalloc((unsigned int )(2UL * sizeof(char *)));
# 399 "rule.c"
  r->suffixes = (char **)tmp___1;
# 400 "rule.c"
  tmp___2 = xmalloc((unsigned int )(2UL * sizeof(unsigned int )));
# 400 "rule.c"
  r->lens = (unsigned int *)tmp___2;
# 402 "rule.c"
  *(r->targets + 1) = (char *)0;
# 403 "rule.c"
  *(r->suffixes + 1) = (char *)0;
# 404 "rule.c"
  *(r->lens + 1) = 0U;
# 406 "rule.c"
  tmp___3 = strlen((char const *)p->target);
# 406 "rule.c"
  *(r->lens + 0) = (unsigned int )tmp___3;
# 409 "rule.c"
  *(r->targets + 0) = savestring((char const *)p->target, *(r->lens + 0));
# 410 "rule.c"
  *(r->suffixes + 0) = find_percent(*(r->targets + 0));
  }
# 411 "rule.c"
  if ((unsigned long )*(r->suffixes + 0) == (unsigned long )((char *)0)) {
    {
# 413 "rule.c"
    abort();
    }
  } else {
# 415 "rule.c"
    (*(r->suffixes + 0)) ++;
  }
  {
# 417 "rule.c"
  ptr = p->dep;
# 418 "rule.c"
  tmp___4 = parse_file_seq(& ptr, '\000', (unsigned int )sizeof(struct dep ), 1);
# 418 "rule.c"
  tmp___5 = multi_glob(tmp___4, (unsigned int )sizeof(struct dep ));
# 418 "rule.c"
  r->deps = (struct dep *)tmp___5;
# 422 "rule.c"
  tmp___7 = new_pattern_rule(r, 0);
  }
# 422 "rule.c"
  if (tmp___7) {
    {
# 424 "rule.c"
    r->terminal = (char )terminal;
# 425 "rule.c"
    tmp___6 = xmalloc((unsigned int )sizeof(struct commands ));
# 425 "rule.c"
    r->cmds = (struct commands *)tmp___6;
# 426 "rule.c"
    (r->cmds)->fileinfo.filenm = (char *)0;
# 427 "rule.c"
    (r->cmds)->fileinfo.lineno = 0UL;
# 430 "rule.c"
    (r->cmds)->commands = xstrdup((char const *)p->commands);
# 431 "rule.c"
    (r->cmds)->command_lines = (char **)0;
    }
  }
# 433 "rule.c"
  return;
}
}
# 440 "rule.c"
static void freerule(struct rule *rule , struct rule *lastrule )
{
  struct rule *next ;
  register unsigned int i ;
  register struct dep *dep ;
  struct dep *t ;

  {
# 444 "rule.c"
  next = rule->next;
# 448 "rule.c"
  i = 0U;
  {
# 448 "rule.c"
  while (1) {
    while_continue: ;
# 448 "rule.c"
    if (! ((unsigned long )*(rule->targets + i) != (unsigned long )((char *)0))) {
# 448 "rule.c"
      goto while_break;
    }
    {
# 449 "rule.c"
    free((void *)*(rule->targets + i));
# 448 "rule.c"
    i ++;
    }
  }
  while_break: ;
  }
# 451 "rule.c"
  dep = rule->deps;
  {
# 452 "rule.c"
  while (1) {
    while_continue___0: ;
# 452 "rule.c"
    if (! dep) {
# 452 "rule.c"
      goto while_break___0;
    }
    {
# 456 "rule.c"
    t = dep->next;
# 459 "rule.c"
    free((void *)((char *)dep));
# 460 "rule.c"
    dep = t;
    }
  }
  while_break___0: ;
  }
  {
# 463 "rule.c"
  free((void *)((char *)rule->targets));
# 464 "rule.c"
  free((void *)((char *)rule->suffixes));
# 465 "rule.c"
  free((void *)((char *)rule->lens));
# 478 "rule.c"
  free((void *)((char *)rule));
  }
# 480 "rule.c"
  if ((unsigned long )pattern_rules == (unsigned long )rule) {
# 481 "rule.c"
    if ((unsigned long )lastrule != (unsigned long )((struct rule *)0)) {
      {
# 482 "rule.c"
      abort();
      }
    } else {
# 484 "rule.c"
      pattern_rules = next;
    }
  } else
# 485 "rule.c"
  if ((unsigned long )lastrule != (unsigned long )((struct rule *)0)) {
# 486 "rule.c"
    lastrule->next = next;
  }
# 487 "rule.c"
  if ((unsigned long )last_pattern_rule == (unsigned long )rule) {
# 488 "rule.c"
    last_pattern_rule = lastrule;
  }
# 489 "rule.c"
  return;
}
}
# 502 "rule.c"
void create_pattern_rule(char **targets , char **target_percents , int terminal ,
                         struct dep *deps , struct commands *commands , int override )
{
  register struct rule *r ;
  char *tmp ;
  register unsigned int max_targets ;
  register unsigned int i ;
  char *tmp___0 ;
  char *tmp___1 ;
  char *tmp___2 ;
  char *tmp___3 ;
  size_t tmp___4 ;
  char *tmp___5 ;
  char *tmp___6 ;
  char *tmp___7 ;
  char *tmp___8 ;
  int tmp___9 ;

  {
  {
# 511 "rule.c"
  tmp = xmalloc((unsigned int )sizeof(struct rule ));
# 511 "rule.c"
  r = (struct rule *)tmp;
# 514 "rule.c"
  r->cmds = commands;
# 515 "rule.c"
  r->deps = deps;
# 516 "rule.c"
  r->targets = targets;
# 518 "rule.c"
  max_targets = 2U;
# 519 "rule.c"
  tmp___0 = xmalloc((unsigned int )(2UL * sizeof(unsigned int )));
# 519 "rule.c"
  r->lens = (unsigned int *)tmp___0;
# 520 "rule.c"
  tmp___1 = xmalloc((unsigned int )(2UL * sizeof(char *)));
# 520 "rule.c"
  r->suffixes = (char **)tmp___1;
# 521 "rule.c"
  i = 0U;
  }
  {
# 521 "rule.c"
  while (1) {
    while_continue: ;
# 521 "rule.c"
    if (! ((unsigned long )*(targets + i) != (unsigned long )((char *)0))) {
# 521 "rule.c"
      goto while_break;
    }
# 523 "rule.c"
    if (i == max_targets - 1U) {
      {
# 525 "rule.c"
      max_targets += 5U;
# 526 "rule.c"
      tmp___2 = xrealloc((char *)r->lens, (unsigned int )((unsigned long )max_targets * sizeof(unsigned int )));
# 526 "rule.c"
      r->lens = (unsigned int *)tmp___2;
# 528 "rule.c"
      tmp___3 = xrealloc((char *)r->suffixes, (unsigned int )((unsigned long )max_targets * sizeof(char *)));
# 528 "rule.c"
      r->suffixes = (char **)tmp___3;
      }
    }
    {
# 531 "rule.c"
    tmp___4 = strlen((char const *)*(targets + i));
# 531 "rule.c"
    *(r->lens + i) = (unsigned int )tmp___4;
    }
# 532 "rule.c"
    if ((unsigned long )target_percents == (unsigned long )((char **)0)) {
      {
# 532 "rule.c"
      tmp___5 = find_percent(*(targets + i));
# 532 "rule.c"
      tmp___6 = tmp___5;
      }
    } else {
# 532 "rule.c"
      tmp___6 = *(target_percents + i);
    }
# 532 "rule.c"
    *(r->suffixes + i) = tmp___6 + 1;
# 534 "rule.c"
    if ((unsigned long )*(r->suffixes + i) == (unsigned long )((char *)0)) {
      {
# 535 "rule.c"
      abort();
      }
    }
# 521 "rule.c"
    i ++;
  }
  while_break: ;
  }
# 538 "rule.c"
  if (i < max_targets - 1U) {
    {
# 540 "rule.c"
    tmp___7 = xrealloc((char *)r->lens, (unsigned int )((unsigned long )(i + 1U) * sizeof(unsigned int )));
# 540 "rule.c"
    r->lens = (unsigned int *)tmp___7;
# 542 "rule.c"
    tmp___8 = xrealloc((char *)r->suffixes, (unsigned int )((unsigned long )(i + 1U) * sizeof(char *)));
# 542 "rule.c"
    r->suffixes = (char **)tmp___8;
    }
  }
  {
# 546 "rule.c"
  tmp___9 = new_pattern_rule(r, override);
  }
# 546 "rule.c"
  if (tmp___9) {
# 547 "rule.c"
    r->terminal = (char )terminal;
  }
# 548 "rule.c"
  return;
}
}
# 552 "rule.c"
struct pattern_var *create_pattern_var(char *target , char *suffix )
{
  register struct pattern_var *p ;
  unsigned int len ;
  size_t tmp ;
  int tmp___0 ;
  char *tmp___1 ;

  {
  {
# 556 "rule.c"
  p = (struct pattern_var *)0;
# 557 "rule.c"
  tmp = strlen((char const *)target);
# 557 "rule.c"
  len = (unsigned int )tmp;
# 560 "rule.c"
  p = pattern_vars;
  }
  {
# 560 "rule.c"
  while (1) {
    while_continue: ;
# 560 "rule.c"
    if (! ((unsigned long )p != (unsigned long )((void *)0))) {
# 560 "rule.c"
      goto while_break;
    }
# 561 "rule.c"
    if (p->len == len) {
      {
# 561 "rule.c"
      tmp___0 = strcmp((char const *)p->target, (char const *)target);
      }
# 561 "rule.c"
      if (! tmp___0) {
# 562 "rule.c"
        goto while_break;
      }
    }
# 560 "rule.c"
    p = p->next;
  }
  while_break: ;
  }
# 564 "rule.c"
  if ((unsigned long )p == (unsigned long )((struct pattern_var *)0)) {
    {
# 566 "rule.c"
    tmp___1 = xmalloc((unsigned int )sizeof(struct pattern_var ));
# 566 "rule.c"
    p = (struct pattern_var *)tmp___1;
    }
# 567 "rule.c"
    if ((unsigned long )last_pattern_var != (unsigned long )((struct pattern_var *)0)) {
# 568 "rule.c"
      last_pattern_var->next = p;
    } else {
# 570 "rule.c"
      pattern_vars = p;
    }
    {
# 571 "rule.c"
    last_pattern_var = p;
# 572 "rule.c"
    p->next = (struct pattern_var *)0;
# 573 "rule.c"
    p->target = target;
# 574 "rule.c"
    p->len = len;
# 575 "rule.c"
    p->suffix = suffix + 1;
# 576 "rule.c"
    p->vars = create_new_variable_set();
    }
  }
# 579 "rule.c"
  return (p);
}
}
# 584 "rule.c"
struct pattern_var *lookup_pattern_var(char *target )
{
  struct pattern_var *p ;
  unsigned int targlen ;
  size_t tmp ;
  char *stem ;
  unsigned int stemlen ;
  int tmp___0 ;
  int tmp___1 ;

  {
  {
# 589 "rule.c"
  tmp = strlen((char const *)target);
# 589 "rule.c"
  targlen = (unsigned int )tmp;
# 591 "rule.c"
  p = pattern_vars;
  }
  {
# 591 "rule.c"
  while (1) {
    while_continue: ;
# 591 "rule.c"
    if (! ((unsigned long )p != (unsigned long )((struct pattern_var *)0))) {
# 591 "rule.c"
      goto while_break;
    }
# 596 "rule.c"
    if (p->len > targlen) {
# 598 "rule.c"
      goto __Cont;
    }
# 602 "rule.c"
    stem = target + ((p->suffix - p->target) - 1L);
# 603 "rule.c"
    stemlen = (targlen - p->len) + 1U;
# 606 "rule.c"
    if ((unsigned long )stem > (unsigned long )target) {
      {
# 606 "rule.c"
      tmp___0 = strncmp((char const *)p->target, (char const *)target, (size_t )(stem - target));
      }
# 606 "rule.c"
      if (! (tmp___0 == 0)) {
# 607 "rule.c"
        goto __Cont;
      }
    }
# 614 "rule.c"
    if ((int )*(p->suffix) == (int )*(stem + stemlen)) {
# 614 "rule.c"
      if ((int )*(p->suffix) == 0) {
# 616 "rule.c"
        goto while_break;
      } else
# 614 "rule.c"
      if ((unsigned long )(p->suffix + 1) == (unsigned long )(stem + (stemlen + 1U))) {
# 616 "rule.c"
        goto while_break;
      } else
# 614 "rule.c"
      if ((int )*(p->suffix + 1) == (int )*(stem + (stemlen + 1U))) {
# 614 "rule.c"
        if ((int )*(p->suffix + 1) == 0) {
# 616 "rule.c"
          goto while_break;
        } else {
          {
# 614 "rule.c"
          tmp___1 = strcmp((char const *)((p->suffix + 1) + 1), (char const *)((stem + (stemlen + 1U)) + 1));
          }
# 614 "rule.c"
          if (! tmp___1) {
# 616 "rule.c"
            goto while_break;
          }
        }
      }
    }
    __Cont:
# 591 "rule.c"
    p = p->next;
  }
  while_break: ;
  }
# 619 "rule.c"
  return (p);
}
}
# 624 "rule.c"
static void print_rule(struct rule *r )
{
  register unsigned int i ;
  register struct dep *d ;
  char *tmp ;

  {
# 631 "rule.c"
  i = 0U;
  {
# 631 "rule.c"
  while (1) {
    while_continue: ;
# 631 "rule.c"
    if (! ((unsigned long )*(r->targets + i) != (unsigned long )((char *)0))) {
# 631 "rule.c"
      goto while_break;
    }
    {
# 633 "rule.c"
    fputs((char const * __restrict )*(r->targets + i), (FILE * __restrict )stdout);
    }
# 634 "rule.c"
    if ((unsigned long )*(r->targets + (i + 1U)) != (unsigned long )((char *)0)) {
      {
# 635 "rule.c"
      putchar(' ');
      }
    } else {
      {
# 637 "rule.c"
      putchar(':');
      }
    }
# 631 "rule.c"
    i ++;
  }
  while_break: ;
  }
# 639 "rule.c"
  if (r->terminal) {
    {
# 640 "rule.c"
    putchar(':');
    }
  }
# 642 "rule.c"
  d = r->deps;
  {
# 642 "rule.c"
  while (1) {
    while_continue___0: ;
# 642 "rule.c"
    if (! ((unsigned long )d != (unsigned long )((struct dep *)0))) {
# 642 "rule.c"
      goto while_break___0;
    }
# 643 "rule.c"
    if ((unsigned long )d->name == (unsigned long )((char *)0)) {
# 643 "rule.c"
      tmp = (d->file)->name;
    } else {
# 643 "rule.c"
      tmp = d->name;
    }
    {
# 643 "rule.c"
    printf((char const * __restrict )" %s", tmp);
# 642 "rule.c"
    d = d->next;
    }
  }
  while_break___0: ;
  }
  {
# 644 "rule.c"
  putchar('\n');
  }
# 646 "rule.c"
  if ((unsigned long )r->cmds != (unsigned long )((struct commands *)0)) {
    {
# 647 "rule.c"
    print_commands(r->cmds);
    }
  }
# 648 "rule.c"
  return;
}
}
# 650 "rule.c"
void print_rule_data_base(void)
{
  register unsigned int rules ;
  register unsigned int terminal ;
  register struct rule *r ;
  char *tmp ;
  char *tmp___0 ;
  char *tmp___1 ;
  char *tmp___2 ;
  char *tmp___3 ;
  struct pattern_var *p ;
  char *tmp___4 ;
  char *tmp___5 ;

  {
  {
# 656 "rule.c"
  puts("\n# Implicit Rules");
# 658 "rule.c"
  terminal = 0U;
# 658 "rule.c"
  rules = terminal;
# 659 "rule.c"
  r = pattern_rules;
  }
  {
# 659 "rule.c"
  while (1) {
    while_continue: ;
# 659 "rule.c"
    if (! ((unsigned long )r != (unsigned long )((struct rule *)0))) {
# 659 "rule.c"
      goto while_break;
    }
    {
# 661 "rule.c"
    rules ++;
# 663 "rule.c"
    putchar('\n');
# 664 "rule.c"
    print_rule(r);
    }
# 666 "rule.c"
    if (r->terminal) {
# 667 "rule.c"
      terminal ++;
    }
# 659 "rule.c"
    r = r->next;
  }
  while_break: ;
  }
# 670 "rule.c"
  if (rules == 0U) {
    {
# 671 "rule.c"
    tmp = dcgettext((char const *)((void *)0), "\n# No implicit rules.", 5);
# 671 "rule.c"
    puts((char const *)tmp);
    }
  } else {
    {
# 674 "rule.c"
    tmp___0 = dcgettext((char const *)((void *)0), "\n# %u implicit rules, %u",
                        5);
# 674 "rule.c"
    printf((char const * __restrict )tmp___0, rules, terminal);
# 676 "rule.c"
    printf((char const * __restrict )" (%.1f%%)", ((double )terminal / (double )rules) * 100.0);
# 683 "rule.c"
    tmp___1 = dcgettext((char const *)((void *)0), " terminal.", 5);
# 683 "rule.c"
    puts((char const *)tmp___1);
    }
  }
# 686 "rule.c"
  if (num_pattern_rules != rules) {
# 690 "rule.c"
    if (num_pattern_rules != 0U) {
      {
# 691 "rule.c"
      tmp___2 = dcgettext((char const *)((void *)0), "BUG: num_pattern_rules wrong!  %u != %u",
                          5);
# 691 "rule.c"
      fatal((struct floc const *)((struct floc *)0), (char const *)tmp___2, num_pattern_rules,
            rules);
      }
    }
  }
  {
# 695 "rule.c"
  tmp___3 = dcgettext((char const *)((void *)0), "\n# Pattern-specific variable values",
                      5);
# 695 "rule.c"
  puts((char const *)tmp___3);
# 700 "rule.c"
  rules = 0U;
# 701 "rule.c"
  p = pattern_vars;
  }
  {
# 701 "rule.c"
  while (1) {
    while_continue___0: ;
# 701 "rule.c"
    if (! ((unsigned long )p != (unsigned long )((struct pattern_var *)0))) {
# 701 "rule.c"
      goto while_break___0;
    }
    {
# 703 "rule.c"
    rules ++;
# 705 "rule.c"
    printf((char const * __restrict )"\n%s :\n", p->target);
# 706 "rule.c"
    print_variable_set((p->vars)->set, (char *)"# ");
# 701 "rule.c"
    p = p->next;
    }
  }
  while_break___0: ;
  }
# 709 "rule.c"
  if (rules == 0U) {
    {
# 710 "rule.c"
    tmp___4 = dcgettext((char const *)((void *)0), "\n# No pattern-specific variable values.",
                        5);
# 710 "rule.c"
    puts((char const *)tmp___4);
    }
  } else {
    {
# 713 "rule.c"
    tmp___5 = dcgettext((char const *)((void *)0), "\n# %u pattern-specific variable values",
                        5);
# 713 "rule.c"
    printf((char const * __restrict )tmp___5, rules);
    }
  }
# 716 "rule.c"
  return;
}
}
# 1 "signame.o"
#pragma merger("0","/tmp/cil-aO4sE5WY.i","-g,-O0")
# 23 "signame.h"
void signame_init(void) ;
# 28 "signame.h"
char *sig_abbrev(int number ) ;
# 32 "signame.h"
int sig_number(char const *abbrev ) ;
# 65 "signame.c"
static num_abbrev sig_table[130] ;
# 67 "signame.c"
static int sig_table_nelts = 0;
# 71 "signame.c"
static void init_sig(int number , char const *abbrev , char const *name )
{
  int tmp ;

  {
# 85 "signame.c"
  if (sig_table_nelts < 130) {
# 87 "signame.c"
    sig_table[sig_table_nelts].number = number;
# 88 "signame.c"
    tmp = sig_table_nelts;
# 88 "signame.c"
    sig_table_nelts ++;
# 88 "signame.c"
    sig_table[tmp].abbrev = abbrev;
  }
# 90 "signame.c"
  return;
}
}
# 92 "signame.c"
void signame_init(void)
{
  char *tmp ;
  char *tmp___0 ;
  char *tmp___1 ;
  char *tmp___2 ;
  char *tmp___3 ;
  char *tmp___4 ;
  char *tmp___5 ;
  char *tmp___6 ;
  char *tmp___7 ;
  char *tmp___8 ;
  char *tmp___9 ;
  char *tmp___10 ;
  char *tmp___11 ;
  char *tmp___12 ;
  char *tmp___13 ;
  char *tmp___14 ;
  char *tmp___15 ;
  char *tmp___16 ;
  char *tmp___17 ;
  char *tmp___18 ;
  char *tmp___19 ;
  char *tmp___20 ;
  char *tmp___21 ;
  char *tmp___22 ;
  char *tmp___23 ;
  char *tmp___24 ;
  char *tmp___25 ;
  char *tmp___26 ;
  char *tmp___27 ;
  char *tmp___28 ;
  char *tmp___29 ;
  char *tmp___30 ;
  char *tmp___31 ;

  {
  {
# 108 "signame.c"
  tmp = dcgettext((char const *)((void *)0), "Hangup", 5);
# 108 "signame.c"
  init_sig(1, "HUP", (char const *)tmp);
# 111 "signame.c"
  tmp___0 = dcgettext((char const *)((void *)0), "Interrupt", 5);
# 111 "signame.c"
  init_sig(2, "INT", (char const *)tmp___0);
# 114 "signame.c"
  tmp___1 = dcgettext((char const *)((void *)0), "Quit", 5);
# 114 "signame.c"
  init_sig(3, "QUIT", (char const *)tmp___1);
# 117 "signame.c"
  tmp___2 = dcgettext((char const *)((void *)0), "Illegal Instruction", 5);
# 117 "signame.c"
  init_sig(4, "ILL", (char const *)tmp___2);
# 120 "signame.c"
  tmp___3 = dcgettext((char const *)((void *)0), "Trace/breakpoint trap", 5);
# 120 "signame.c"
  init_sig(5, "TRAP", (char const *)tmp___3);
# 125 "signame.c"
  tmp___4 = dcgettext((char const *)((void *)0), "Aborted", 5);
# 125 "signame.c"
  init_sig(6, "ABRT", (char const *)tmp___4);
# 128 "signame.c"
  tmp___5 = dcgettext((char const *)((void *)0), "IOT trap", 5);
# 128 "signame.c"
  init_sig(6, "IOT", (char const *)tmp___5);
# 134 "signame.c"
  tmp___6 = dcgettext((char const *)((void *)0), "Floating point exception", 5);
# 134 "signame.c"
  init_sig(8, "FPE", (char const *)tmp___6);
# 137 "signame.c"
  tmp___7 = dcgettext((char const *)((void *)0), "Killed", 5);
# 137 "signame.c"
  init_sig(9, "KILL", (char const *)tmp___7);
# 140 "signame.c"
  tmp___8 = dcgettext((char const *)((void *)0), "Bus error", 5);
# 140 "signame.c"
  init_sig(7, "BUS", (char const *)tmp___8);
# 143 "signame.c"
  tmp___9 = dcgettext((char const *)((void *)0), "Segmentation fault", 5);
# 143 "signame.c"
  init_sig(11, "SEGV", (char const *)tmp___9);
# 146 "signame.c"
  tmp___10 = dcgettext((char const *)((void *)0), "Bad system call", 5);
# 146 "signame.c"
  init_sig(31, "SYS", (char const *)tmp___10);
# 149 "signame.c"
  tmp___11 = dcgettext((char const *)((void *)0), "Broken pipe", 5);
# 149 "signame.c"
  init_sig(13, "PIPE", (char const *)tmp___11);
# 152 "signame.c"
  tmp___12 = dcgettext((char const *)((void *)0), "Alarm clock", 5);
# 152 "signame.c"
  init_sig(14, "ALRM", (char const *)tmp___12);
# 155 "signame.c"
  tmp___13 = dcgettext((char const *)((void *)0), "Terminated", 5);
# 155 "signame.c"
  init_sig(15, "TERM", (char const *)tmp___13);
# 158 "signame.c"
  tmp___14 = dcgettext((char const *)((void *)0), "User defined signal 1", 5);
# 158 "signame.c"
  init_sig(10, "USR1", (char const *)tmp___14);
# 161 "signame.c"
  tmp___15 = dcgettext((char const *)((void *)0), "User defined signal 2", 5);
# 161 "signame.c"
  init_sig(12, "USR2", (char const *)tmp___15);
# 166 "signame.c"
  tmp___16 = dcgettext((char const *)((void *)0), "Child exited", 5);
# 166 "signame.c"
  init_sig(17, "CHLD", (char const *)tmp___16);
# 169 "signame.c"
  tmp___17 = dcgettext((char const *)((void *)0), "Child exited", 5);
# 169 "signame.c"
  init_sig(17, "CLD", (char const *)tmp___17);
# 172 "signame.c"
  tmp___18 = dcgettext((char const *)((void *)0), "Power failure", 5);
# 172 "signame.c"
  init_sig(30, "PWR", (char const *)tmp___18);
# 175 "signame.c"
  tmp___19 = dcgettext((char const *)((void *)0), "Stopped", 5);
# 175 "signame.c"
  init_sig(20, "TSTP", (char const *)tmp___19);
# 178 "signame.c"
  tmp___20 = dcgettext((char const *)((void *)0), "Stopped (tty input)", 5);
# 178 "signame.c"
  init_sig(21, "TTIN", (char const *)tmp___20);
# 181 "signame.c"
  tmp___21 = dcgettext((char const *)((void *)0), "Stopped (tty output)", 5);
# 181 "signame.c"
  init_sig(22, "TTOU", (char const *)tmp___21);
# 184 "signame.c"
  tmp___22 = dcgettext((char const *)((void *)0), "Stopped (signal)", 5);
# 184 "signame.c"
  init_sig(19, "STOP", (char const *)tmp___22);
# 187 "signame.c"
  tmp___23 = dcgettext((char const *)((void *)0), "CPU time limit exceeded", 5);
# 187 "signame.c"
  init_sig(24, "XCPU", (char const *)tmp___23);
# 190 "signame.c"
  tmp___24 = dcgettext((char const *)((void *)0), "File size limit exceeded", 5);
# 190 "signame.c"
  init_sig(25, "XFSZ", (char const *)tmp___24);
# 193 "signame.c"
  tmp___25 = dcgettext((char const *)((void *)0), "Virtual timer expired", 5);
# 193 "signame.c"
  init_sig(26, "VTALRM", (char const *)tmp___25);
# 196 "signame.c"
  tmp___26 = dcgettext((char const *)((void *)0), "Profiling timer expired", 5);
# 196 "signame.c"
  init_sig(27, "PROF", (char const *)tmp___26);
# 202 "signame.c"
  tmp___27 = dcgettext((char const *)((void *)0), "Window changed", 5);
# 202 "signame.c"
  init_sig(28, "WINCH", (char const *)tmp___27);
# 205 "signame.c"
  tmp___28 = dcgettext((char const *)((void *)0), "Continued", 5);
# 205 "signame.c"
  init_sig(18, "CONT", (char const *)tmp___28);
# 208 "signame.c"
  tmp___29 = dcgettext((char const *)((void *)0), "Urgent I/O condition", 5);
# 208 "signame.c"
  init_sig(23, "URG", (char const *)tmp___29);
# 215 "signame.c"
  tmp___30 = dcgettext((char const *)((void *)0), "I/O possible", 5);
# 215 "signame.c"
  init_sig(29, "IO", (char const *)tmp___30);
# 224 "signame.c"
  tmp___31 = dcgettext((char const *)((void *)0), "I/O possible", 5);
# 224 "signame.c"
  init_sig(29, "POLL", (char const *)tmp___31);
  }
# 238 "signame.c"
  return;
}
}
# 242 "signame.c"
char *sig_abbrev(int number )
{
  int i ;

  {
# 248 "signame.c"
  if (sig_table_nelts == 0) {
    {
# 249 "signame.c"
    signame_init();
    }
  }
# 251 "signame.c"
  i = 0;
  {
# 251 "signame.c"
  while (1) {
    while_continue: ;
# 251 "signame.c"
    if (! (i < sig_table_nelts)) {
# 251 "signame.c"
      goto while_break;
    }
# 252 "signame.c"
    if (sig_table[i].number == number) {
# 253 "signame.c"
      return ((char *)sig_table[i].abbrev);
    }
# 251 "signame.c"
    i ++;
  }
  while_break: ;
  }
# 254 "signame.c"
  return ((char *)((void *)0));
}
}
# 260 "signame.c"
int sig_number(char const *abbrev )
{
  int i ;
  int tmp ;

  {
# 266 "signame.c"
  if (sig_table_nelts == 0) {
    {
# 267 "signame.c"
    signame_init();
    }
  }
# 270 "signame.c"
  if ((int const )*(abbrev + 0) == 83) {
# 270 "signame.c"
    if ((int const )*(abbrev + 1) == 73) {
# 270 "signame.c"
      if ((int const )*(abbrev + 2) == 71) {
# 271 "signame.c"
        abbrev += 3;
      }
    }
  }
# 273 "signame.c"
  i = 0;
  {
# 273 "signame.c"
  while (1) {
    while_continue: ;
# 273 "signame.c"
    if (! (i < sig_table_nelts)) {
# 273 "signame.c"
      goto while_break;
    }
# 274 "signame.c"
    if ((int const )*(abbrev + 0) == (int const )*(sig_table[i].abbrev + 0)) {
      {
# 274 "signame.c"
      tmp = strcmp(abbrev, sig_table[i].abbrev);
      }
# 274 "signame.c"
      if (tmp == 0) {
# 276 "signame.c"
        return (sig_table[i].number);
      }
    }
# 273 "signame.c"
    i ++;
  }
  while_break: ;
  }
# 277 "signame.c"
  return (-1);
}
}
# 1 "variable.o"
#pragma merger("0","/tmp/cil-3nJ90Uj5.i","-g,-O0")
# 42 "variable.c"
static struct variable *variable_table[523] ;
# 43 "variable.c"
static struct variable_set global_variable_set = {variable_table, 523U};
# 45 "variable.c"
static struct variable_set_list global_setlist = {(struct variable_set_list *)0, & global_variable_set};
# 47 "variable.c"
struct variable_set_list *current_variable_set_list = & global_setlist;
# 49 "variable.c"
static struct variable *lookup_variable_in_set(char *name , unsigned int length___0 ,
                                               struct variable_set *set ) ;
# 61 "variable.c"
struct variable *define_variable_in_set(char *name , unsigned int length___0 , char *value ,
                                        enum variable_origin origin , int recursive ,
                                        struct variable_set *set , struct floc const *flocp )
{
  register unsigned int i ;
  register unsigned int hashval ;
  register struct variable *v ;
  int tmp ;
  char *tmp___0 ;

  {
# 75 "variable.c"
  hashval = 0U;
# 76 "variable.c"
  i = 0U;
  {
# 76 "variable.c"
  while (1) {
    while_continue: ;
# 76 "variable.c"
    if (! (i < length___0)) {
# 76 "variable.c"
      goto while_break;
    }
# 77 "variable.c"
    hashval += (unsigned int )*(name + i);
# 77 "variable.c"
    hashval = (hashval << 7) + (hashval >> 20);
# 76 "variable.c"
    i ++;
  }
  while_break: ;
  }
# 78 "variable.c"
  hashval %= set->buckets;
# 80 "variable.c"
  v = *(set->table + hashval);
  {
# 80 "variable.c"
  while (1) {
    while_continue___0: ;
# 80 "variable.c"
    if (! ((unsigned long )v != (unsigned long )((struct variable *)0))) {
# 80 "variable.c"
      goto while_break___0;
    }
# 81 "variable.c"
    if ((int )*(v->name) == (int )*name) {
      {
# 81 "variable.c"
      tmp = strncmp((char const *)(v->name + 1), (char const *)(name + 1), (size_t )(length___0 - 1U));
      }
# 81 "variable.c"
      if (tmp == 0) {
# 81 "variable.c"
        if ((int )*(v->name + length___0) == 0) {
# 84 "variable.c"
          goto while_break___0;
        }
      }
    }
# 80 "variable.c"
    v = v->next;
  }
  while_break___0: ;
  }
# 86 "variable.c"
  if (env_overrides) {
# 86 "variable.c"
    if ((unsigned int )origin == 1U) {
# 87 "variable.c"
      origin = (enum variable_origin )3;
    }
  }
# 89 "variable.c"
  if ((unsigned long )v != (unsigned long )((struct variable *)0)) {
# 91 "variable.c"
    if (env_overrides) {
# 91 "variable.c"
      if ((unsigned int )v->origin == 1U) {
# 94 "variable.c"
        v->origin = (enum variable_origin )3;
      }
    }
# 99 "variable.c"
    if ((int )origin >= (int )v->origin) {
# 101 "variable.c"
      if ((unsigned long )v->value != (unsigned long )((char *)0)) {
        {
# 102 "variable.c"
        free((void *)v->value);
        }
      }
      {
# 103 "variable.c"
      v->value = xstrdup((char const *)value);
      }
# 104 "variable.c"
      if ((unsigned long )flocp != (unsigned long )((struct floc const *)0)) {
# 105 "variable.c"
        v->fileinfo = (struct floc )*flocp;
      } else {
# 107 "variable.c"
        v->fileinfo.filenm = (char *)0;
      }
# 108 "variable.c"
      v->origin = origin;
# 109 "variable.c"
      v->recursive = (unsigned int )recursive;
    }
# 111 "variable.c"
    return (v);
  }
  {
# 116 "variable.c"
  tmp___0 = xmalloc((unsigned int )sizeof(struct variable ));
# 116 "variable.c"
  v = (struct variable *)tmp___0;
# 117 "variable.c"
  v->name = savestring((char const *)name, length___0);
# 118 "variable.c"
  v->value = xstrdup((char const *)value);
  }
# 119 "variable.c"
  if ((unsigned long )flocp != (unsigned long )((struct floc const *)0)) {
# 120 "variable.c"
    v->fileinfo = (struct floc )*flocp;
  } else {
# 122 "variable.c"
    v->fileinfo.filenm = (char *)0;
  }
# 123 "variable.c"
  v->origin = origin;
# 124 "variable.c"
  v->recursive = (unsigned int )recursive;
# 125 "variable.c"
  v->expanding = 0U;
# 126 "variable.c"
  v->per_target = 0U;
# 127 "variable.c"
  v->append = 0U;
# 128 "variable.c"
  v->export = (enum variable_export )3;
# 129 "variable.c"
  v->next = *(set->table + hashval);
# 130 "variable.c"
  *(set->table + hashval) = v;
# 131 "variable.c"
  return (v);
}
}
# 144 "variable.c"
struct variable *lookup_variable(char *name , unsigned int length___0 )
{
  register struct variable_set_list *setlist ;
  struct variable *firstv ;
  register unsigned int i ;
  register unsigned int rawhash ;
  register struct variable_set *set ;
  register unsigned int hashval ;
  register struct variable *v ;
  int tmp ;

  {
# 150 "variable.c"
  firstv = (struct variable *)0;
# 153 "variable.c"
  rawhash = 0U;
# 155 "variable.c"
  i = 0U;
  {
# 155 "variable.c"
  while (1) {
    while_continue: ;
# 155 "variable.c"
    if (! (i < length___0)) {
# 155 "variable.c"
      goto while_break;
    }
# 156 "variable.c"
    rawhash += (unsigned int )*(name + i);
# 156 "variable.c"
    rawhash = (rawhash << 7) + (rawhash >> 20);
# 155 "variable.c"
    i ++;
  }
  while_break: ;
  }
# 158 "variable.c"
  setlist = current_variable_set_list;
  {
# 158 "variable.c"
  while (1) {
    while_continue___0: ;
# 158 "variable.c"
    if (! ((unsigned long )setlist != (unsigned long )((struct variable_set_list *)0))) {
# 158 "variable.c"
      goto while_break___0;
    }
# 161 "variable.c"
    set = setlist->set;
# 162 "variable.c"
    hashval = rawhash % set->buckets;
# 166 "variable.c"
    v = *(set->table + hashval);
    {
# 166 "variable.c"
    while (1) {
      while_continue___1: ;
# 166 "variable.c"
      if (! ((unsigned long )v != (unsigned long )((struct variable *)0))) {
# 166 "variable.c"
        goto while_break___1;
      }
# 167 "variable.c"
      if ((int )*(v->name) == (int )*name) {
        {
# 167 "variable.c"
        tmp = strncmp((char const *)(v->name + 1), (char const *)(name + 1), (size_t )(length___0 - 1U));
        }
# 167 "variable.c"
        if (tmp == 0) {
# 167 "variable.c"
          if ((int )*(v->name + length___0) == 0) {
# 170 "variable.c"
            goto while_break___1;
          }
        }
      }
# 166 "variable.c"
      v = v->next;
    }
    while_break___1: ;
    }
# 173 "variable.c"
    if (! v) {
# 174 "variable.c"
      goto __Cont;
    }
# 177 "variable.c"
    if (! v->expanding) {
# 178 "variable.c"
      return (v);
    }
# 182 "variable.c"
    if (! firstv) {
# 183 "variable.c"
      firstv = v;
    }
    __Cont:
# 158 "variable.c"
    setlist = setlist->next;
  }
  while_break___0: ;
  }
# 245 "variable.c"
  return (firstv);
}
}
# 253 "variable.c"
static struct variable *lookup_variable_in_set(char *name , unsigned int length___0 ,
                                               struct variable_set *set )
{
  register unsigned int i ;
  register unsigned int hash ;
  register struct variable *v ;
  int tmp ;

  {
# 260 "variable.c"
  hash = 0U;
# 263 "variable.c"
  i = 0U;
  {
# 263 "variable.c"
  while (1) {
    while_continue: ;
# 263 "variable.c"
    if (! (i < length___0)) {
# 263 "variable.c"
      goto while_break;
    }
# 264 "variable.c"
    hash += (unsigned int )*(name + i);
# 264 "variable.c"
    hash = (hash << 7) + (hash >> 20);
# 263 "variable.c"
    i ++;
  }
  while_break: ;
  }
# 265 "variable.c"
  hash %= set->buckets;
# 267 "variable.c"
  v = *(set->table + hash);
  {
# 267 "variable.c"
  while (1) {
    while_continue___0: ;
# 267 "variable.c"
    if (! ((unsigned long )v != (unsigned long )((struct variable *)0))) {
# 267 "variable.c"
      goto while_break___0;
    }
# 268 "variable.c"
    if ((int )*(v->name) == (int )*name) {
      {
# 268 "variable.c"
      tmp = strncmp((char const *)(v->name + 1), (char const *)(name + 1), (size_t )(length___0 - 1U));
      }
# 268 "variable.c"
      if (tmp == 0) {
# 268 "variable.c"
        if ((int )*(v->name + length___0) == 0) {
# 271 "variable.c"
          return (v);
        }
      }
    }
# 267 "variable.c"
    v = v->next;
  }
  while_break___0: ;
  }
# 273 "variable.c"
  return ((struct variable *)0);
}
}
# 282 "variable.c"
void initialize_file_variables(struct file *file , int reading )
{
  register struct variable_set_list *l ;
  char *tmp ;
  char *tmp___0 ;
  char *tmp___1 ;
  struct pattern_var *p ;
  struct pattern_var *tmp___2 ;
  char *tmp___3 ;

  {
# 287 "variable.c"
  l = file->variables;
# 289 "variable.c"
  if ((unsigned long )l == (unsigned long )((struct variable_set_list *)0)) {
    {
# 291 "variable.c"
    tmp = xmalloc((unsigned int )sizeof(struct variable_set_list ));
# 291 "variable.c"
    l = (struct variable_set_list *)tmp;
# 293 "variable.c"
    tmp___0 = xmalloc((unsigned int )sizeof(struct variable_set ));
# 293 "variable.c"
    l->set = (struct variable_set *)tmp___0;
# 294 "variable.c"
    (l->set)->buckets = 23U;
# 295 "variable.c"
    tmp___1 = xmalloc((unsigned int )((unsigned long )(l->set)->buckets * sizeof(struct variable *)));
# 295 "variable.c"
    (l->set)->table = (struct variable **)tmp___1;
# 297 "variable.c"
    memset((void *)((char *)(l->set)->table), 0, (unsigned long )(l->set)->buckets * sizeof(struct variable *));
# 299 "variable.c"
    file->variables = l;
    }
  }
# 302 "variable.c"
  if ((unsigned long )file->parent == (unsigned long )((struct file *)0)) {
# 303 "variable.c"
    l->next = & global_setlist;
  } else {
    {
# 306 "variable.c"
    initialize_file_variables(file->parent, reading);
# 307 "variable.c"
    l->next = (file->parent)->variables;
    }
  }
# 313 "variable.c"
  if (! reading) {
# 313 "variable.c"
    if (! file->pat_searched) {
      {
# 315 "variable.c"
      tmp___2 = lookup_pattern_var(file->name);
# 315 "variable.c"
      p = tmp___2;
# 317 "variable.c"
      file->pat_searched = 1U;
      }
# 318 "variable.c"
      if ((unsigned long )p != (unsigned long )((struct pattern_var *)0)) {
        {
# 322 "variable.c"
        tmp___3 = xmalloc((unsigned int )sizeof(struct variable_set_list ));
# 322 "variable.c"
        file->pat_variables = (struct variable_set_list *)tmp___3;
# 324 "variable.c"
        (file->pat_variables)->set = (p->vars)->set;
        }
      }
    }
  }
# 330 "variable.c"
  if ((unsigned long )file->pat_variables != (unsigned long )((struct variable_set_list *)0)) {
# 332 "variable.c"
    (file->pat_variables)->next = l->next;
# 333 "variable.c"
    l->next = file->pat_variables;
  }
# 335 "variable.c"
  return;
}
}
# 340 "variable.c"
void pop_variable_scope(void)
{
  register struct variable_set_list *setlist ;
  register struct variable_set *set ;
  register unsigned int i ;
  register struct variable *next ;
  register struct variable *v ;

  {
  {
# 343 "variable.c"
  setlist = current_variable_set_list;
# 344 "variable.c"
  set = setlist->set;
# 347 "variable.c"
  current_variable_set_list = setlist->next;
# 348 "variable.c"
  free((void *)((char *)setlist));
# 350 "variable.c"
  i = 0U;
  }
  {
# 350 "variable.c"
  while (1) {
    while_continue: ;
# 350 "variable.c"
    if (! (i < set->buckets)) {
# 350 "variable.c"
      goto while_break;
    }
# 352 "variable.c"
    next = *(set->table + i);
    {
# 353 "variable.c"
    while (1) {
      while_continue___0: ;
# 353 "variable.c"
      if (! ((unsigned long )next != (unsigned long )((struct variable *)0))) {
# 353 "variable.c"
        goto while_break___0;
      }
      {
# 355 "variable.c"
      v = next;
# 356 "variable.c"
      next = v->next;
# 358 "variable.c"
      free((void *)v->name);
      }
# 359 "variable.c"
      if (v->value) {
        {
# 360 "variable.c"
        free((void *)v->value);
        }
      }
      {
# 361 "variable.c"
      free((void *)((char *)v));
      }
    }
    while_break___0: ;
    }
# 350 "variable.c"
    i ++;
  }
  while_break: ;
  }
  {
# 364 "variable.c"
  free((void *)((char *)set->table));
# 365 "variable.c"
  free((void *)((char *)set));
  }
# 366 "variable.c"
  return;
}
}
# 368 "variable.c"
struct variable_set_list *create_new_variable_set(void)
{
  register struct variable_set_list *setlist ;
  register struct variable_set *set ;
  char *tmp ;
  char *tmp___0 ;
  char *tmp___1 ;

  {
  {
# 374 "variable.c"
  tmp = xmalloc((unsigned int )sizeof(struct variable_set ));
# 374 "variable.c"
  set = (struct variable_set *)tmp;
# 375 "variable.c"
  set->buckets = 13U;
# 376 "variable.c"
  tmp___0 = xmalloc((unsigned int )((unsigned long )set->buckets * sizeof(struct variable *)));
# 376 "variable.c"
  set->table = (struct variable **)tmp___0;
# 378 "variable.c"
  memset((void *)((char *)set->table), 0, (unsigned long )set->buckets * sizeof(struct variable *));
# 380 "variable.c"
  tmp___1 = xmalloc((unsigned int )sizeof(struct variable_set_list ));
# 380 "variable.c"
  setlist = (struct variable_set_list *)tmp___1;
# 382 "variable.c"
  setlist->set = set;
# 383 "variable.c"
  setlist->next = current_variable_set_list;
  }
# 385 "variable.c"
  return (setlist);
}
}
# 390 "variable.c"
struct variable_set_list *push_new_variable_scope(void)
{


  {
  {
# 393 "variable.c"
  current_variable_set_list = create_new_variable_set();
  }
# 393 "variable.c"
  return (current_variable_set_list);
}
}
# 398 "variable.c"
static void merge_variable_sets(struct variable_set *set0 , struct variable_set *set1 )
{
  register unsigned int bucket1 ;
  register struct variable *v1 ;
  struct variable *next ;
  unsigned int bucket0 ;
  register struct variable *v0 ;
  register char *n ;
  int tmp ;

  {
# 404 "variable.c"
  bucket1 = 0U;
  {
# 404 "variable.c"
  while (1) {
    while_continue: ;
# 404 "variable.c"
    if (! (bucket1 < set1->buckets)) {
# 404 "variable.c"
      goto while_break;
    }
# 406 "variable.c"
    v1 = *(set1->table + bucket1);
    {
# 407 "variable.c"
    while (1) {
      while_continue___0: ;
# 407 "variable.c"
      if (! ((unsigned long )v1 != (unsigned long )((struct variable *)0))) {
# 407 "variable.c"
        goto while_break___0;
      }
# 409 "variable.c"
      next = v1->next;
# 413 "variable.c"
      if (set1->buckets >= set0->buckets) {
# 414 "variable.c"
        bucket0 = bucket1;
      } else {
# 418 "variable.c"
        bucket0 = 0U;
# 419 "variable.c"
        n = v1->name;
        {
# 419 "variable.c"
        while (1) {
          while_continue___1: ;
# 419 "variable.c"
          if (! ((int )*n != 0)) {
# 419 "variable.c"
            goto while_break___1;
          }
# 420 "variable.c"
          bucket0 += (unsigned int )*n;
# 420 "variable.c"
          bucket0 = (bucket0 << 7) + (bucket0 >> 20);
# 419 "variable.c"
          n ++;
        }
        while_break___1: ;
        }
      }
# 422 "variable.c"
      bucket0 %= set0->buckets;
# 424 "variable.c"
      v0 = *(set0->table + bucket0);
      {
# 424 "variable.c"
      while (1) {
        while_continue___2: ;
# 424 "variable.c"
        if (! ((unsigned long )v0 != (unsigned long )((struct variable *)0))) {
# 424 "variable.c"
          goto while_break___2;
        }
# 425 "variable.c"
        if ((unsigned long )v0->name == (unsigned long )v1->name) {
# 426 "variable.c"
          goto while_break___2;
        } else
# 425 "variable.c"
        if ((int )*(v0->name) == (int )*(v1->name)) {
# 425 "variable.c"
          if ((int )*(v0->name) == 0) {
# 426 "variable.c"
            goto while_break___2;
          } else {
            {
# 425 "variable.c"
            tmp = strcmp((char const *)(v0->name + 1), (char const *)(v1->name + 1));
            }
# 425 "variable.c"
            if (! tmp) {
# 426 "variable.c"
              goto while_break___2;
            }
          }
        }
# 424 "variable.c"
        v0 = v0->next;
      }
      while_break___2: ;
      }
# 428 "variable.c"
      if ((unsigned long )v0 == (unsigned long )((struct variable *)0)) {
# 431 "variable.c"
        v1->next = *(set0->table + bucket0);
# 432 "variable.c"
        *(set0->table + bucket0) = v1;
      } else {
        {
# 438 "variable.c"
        free((void *)v1->value);
# 439 "variable.c"
        free((void *)((char *)v1));
        }
      }
# 442 "variable.c"
      v1 = next;
    }
    while_break___0: ;
    }
# 404 "variable.c"
    bucket1 ++;
  }
  while_break: ;
  }
# 445 "variable.c"
  return;
}
}
# 449 "variable.c"
void merge_variable_set_lists(struct variable_set_list **setlist0 , struct variable_set_list *setlist1 )
{
  register struct variable_set_list *list0 ;
  struct variable_set_list *last0 ;
  struct variable_set_list *next ;

  {
# 453 "variable.c"
  list0 = *setlist0;
# 454 "variable.c"
  last0 = (struct variable_set_list *)0;
  {
# 456 "variable.c"
  while (1) {
    while_continue: ;
# 456 "variable.c"
    if ((unsigned long )setlist1 != (unsigned long )((struct variable_set_list *)0)) {
# 456 "variable.c"
      if (! ((unsigned long )list0 != (unsigned long )((struct variable_set_list *)0))) {
# 456 "variable.c"
        goto while_break;
      }
    } else {
# 456 "variable.c"
      goto while_break;
    }
    {
# 458 "variable.c"
    next = setlist1;
# 459 "variable.c"
    setlist1 = setlist1->next;
# 461 "variable.c"
    merge_variable_sets(list0->set, next->set);
# 463 "variable.c"
    last0 = list0;
# 464 "variable.c"
    list0 = list0->next;
    }
  }
  while_break: ;
  }
# 467 "variable.c"
  if ((unsigned long )setlist1 != (unsigned long )((struct variable_set_list *)0)) {
# 469 "variable.c"
    if ((unsigned long )last0 == (unsigned long )((struct variable_set_list *)0)) {
# 470 "variable.c"
      *setlist0 = setlist1;
    } else {
# 472 "variable.c"
      last0->next = setlist1;
    }
  }
# 474 "variable.c"
  return;
}
}
# 479 "variable.c"
void define_automatic_variables(void)
{
  register struct variable *v ;
  char buf___1[200] ;
  char const *tmp ;
  char const *tmp___0 ;

  {
  {
# 490 "variable.c"
  sprintf((char * __restrict )(buf___1), (char const * __restrict )"%u", makelevel);
# 491 "variable.c"
  define_variable_in_set((char *)"MAKELEVEL", 9U, buf___1, (enum variable_origin )1,
                         0, current_variable_set_list->set, (struct floc const *)((struct floc *)0));
  }
# 493 "variable.c"
  if ((unsigned long )remote_description == (unsigned long )((char *)0)) {
# 493 "variable.c"
    tmp = "";
  } else
# 493 "variable.c"
  if ((int )*(remote_description + 0) == 0) {
# 493 "variable.c"
    tmp = "";
  } else {
# 493 "variable.c"
    tmp = (char const *)remote_description;
  }
# 493 "variable.c"
  if ((unsigned long )remote_description == (unsigned long )((char *)0)) {
# 493 "variable.c"
    tmp___0 = "";
  } else
# 493 "variable.c"
  if ((int )*(remote_description + 0) == 0) {
# 493 "variable.c"
    tmp___0 = "";
  } else {
# 493 "variable.c"
    tmp___0 = "-";
  }
  {
# 493 "variable.c"
  sprintf((char * __restrict )(buf___1), (char const * __restrict )"%s%s%s", version_string,
          tmp___0, tmp);
# 499 "variable.c"
  define_variable_in_set((char *)"MAKE_VERSION", 12U, buf___1, (enum variable_origin )0,
                         0, current_variable_set_list->set, (struct floc const *)((struct floc *)0));
# 527 "variable.c"
  v = define_variable_in_set((char *)"SHELL", 5U, default_shell, (enum variable_origin )0,
                             0, current_variable_set_list->set, (struct floc const *)((struct floc *)0));
# 528 "variable.c"
  v->export = (enum variable_export )0;
  }
# 535 "variable.c"
  if ((int )*(v->value) == 0) {
    {
# 537 "variable.c"
    free((void *)v->value);
# 538 "variable.c"
    v->origin = (enum variable_origin )2;
# 539 "variable.c"
    v->value = xstrdup((char const *)(default_shell));
    }
  } else
# 535 "variable.c"
  if ((unsigned int )v->origin == 1U) {
    {
# 537 "variable.c"
    free((void *)v->value);
# 538 "variable.c"
    v->origin = (enum variable_origin )2;
# 539 "variable.c"
    v->value = xstrdup((char const *)(default_shell));
    }
  } else
# 535 "variable.c"
  if ((unsigned int )v->origin == 3U) {
    {
# 537 "variable.c"
    free((void *)v->value);
# 538 "variable.c"
    v->origin = (enum variable_origin )2;
# 539 "variable.c"
    v->value = xstrdup((char const *)(default_shell));
    }
  }
  {
# 544 "variable.c"
  v = define_variable_in_set((char *)"MAKEFILES", 9U, (char *)"", (enum variable_origin )0,
                             0, current_variable_set_list->set, (struct floc const *)((struct floc *)0));
# 545 "variable.c"
  v->export = (enum variable_export )2;
# 559 "variable.c"
  define_variable_in_set((char *)"@D", 2U, (char *)"$(patsubst %/,%,$(dir $@))", (enum variable_origin )6,
                         1, current_variable_set_list->set, (struct floc const *)((struct floc *)0));
# 560 "variable.c"
  define_variable_in_set((char *)"%D", 2U, (char *)"$(patsubst %/,%,$(dir $%))", (enum variable_origin )6,
                         1, current_variable_set_list->set, (struct floc const *)((struct floc *)0));
# 561 "variable.c"
  define_variable_in_set((char *)"*D", 2U, (char *)"$(patsubst %/,%,$(dir $*))", (enum variable_origin )6,
                         1, current_variable_set_list->set, (struct floc const *)((struct floc *)0));
# 562 "variable.c"
  define_variable_in_set((char *)"<D", 2U, (char *)"$(patsubst %/,%,$(dir $<))", (enum variable_origin )6,
                         1, current_variable_set_list->set, (struct floc const *)((struct floc *)0));
# 563 "variable.c"
  define_variable_in_set((char *)"?D", 2U, (char *)"$(patsubst %/,%,$(dir $?))", (enum variable_origin )6,
                         1, current_variable_set_list->set, (struct floc const *)((struct floc *)0));
# 564 "variable.c"
  define_variable_in_set((char *)"^D", 2U, (char *)"$(patsubst %/,%,$(dir $^))", (enum variable_origin )6,
                         1, current_variable_set_list->set, (struct floc const *)((struct floc *)0));
# 565 "variable.c"
  define_variable_in_set((char *)"+D", 2U, (char *)"$(patsubst %/,%,$(dir $+))", (enum variable_origin )6,
                         1, current_variable_set_list->set, (struct floc const *)((struct floc *)0));
# 567 "variable.c"
  define_variable_in_set((char *)"@F", 2U, (char *)"$(notdir $@)", (enum variable_origin )6,
                         1, current_variable_set_list->set, (struct floc const *)((struct floc *)0));
# 568 "variable.c"
  define_variable_in_set((char *)"%F", 2U, (char *)"$(notdir $%)", (enum variable_origin )6,
                         1, current_variable_set_list->set, (struct floc const *)((struct floc *)0));
# 569 "variable.c"
  define_variable_in_set((char *)"*F", 2U, (char *)"$(notdir $*)", (enum variable_origin )6,
                         1, current_variable_set_list->set, (struct floc const *)((struct floc *)0));
# 570 "variable.c"
  define_variable_in_set((char *)"<F", 2U, (char *)"$(notdir $<)", (enum variable_origin )6,
                         1, current_variable_set_list->set, (struct floc const *)((struct floc *)0));
# 571 "variable.c"
  define_variable_in_set((char *)"?F", 2U, (char *)"$(notdir $?)", (enum variable_origin )6,
                         1, current_variable_set_list->set, (struct floc const *)((struct floc *)0));
# 572 "variable.c"
  define_variable_in_set((char *)"^F", 2U, (char *)"$(notdir $^)", (enum variable_origin )6,
                         1, current_variable_set_list->set, (struct floc const *)((struct floc *)0));
# 573 "variable.c"
  define_variable_in_set((char *)"+F", 2U, (char *)"$(notdir $+)", (enum variable_origin )6,
                         1, current_variable_set_list->set, (struct floc const *)((struct floc *)0));
  }
# 574 "variable.c"
  return;
}
}
# 582 "variable.c"
char **target_environment(struct file *file )
{
  struct variable_set_list *set_list ;
  register struct variable_set_list *s ;
  struct variable_bucket **table ;
  unsigned int buckets ;
  register unsigned int i ;
  register unsigned int nvariables ;
  char **result___0 ;
  unsigned int mklev_hash ;
  char *p ;
  char *tmp ;
  void *tmp___0 ;
  register struct variable_set *set ;
  register struct variable *v ;
  unsigned int j ;
  register struct variable_bucket *ov ;
  register char *p___0 ;
  int tmp___1 ;
  struct variable *gv ;
  size_t tmp___2 ;
  register char *np ;
  int tmp___3 ;
  register struct variable_bucket *entry ;
  void *tmp___4 ;
  char *tmp___5 ;
  register struct variable_bucket *b ;
  register struct variable *v___0 ;
  char *value ;
  char *tmp___6 ;
  unsigned int tmp___7 ;
  unsigned int tmp___8 ;
  char *tmp___9 ;

  {
# 600 "variable.c"
  if ((unsigned long )file == (unsigned long )((struct file *)0)) {
# 601 "variable.c"
    set_list = current_variable_set_list;
  } else {
# 603 "variable.c"
    set_list = file->variables;
  }
# 606 "variable.c"
  s = set_list;
# 607 "variable.c"
  buckets = (s->set)->buckets;
# 608 "variable.c"
  s = s->next;
  {
# 608 "variable.c"
  while (1) {
    while_continue: ;
# 608 "variable.c"
    if (! ((unsigned long )s != (unsigned long )((struct variable_set_list *)0))) {
# 608 "variable.c"
      goto while_break;
    }
# 609 "variable.c"
    if ((s->set)->buckets < buckets) {
# 610 "variable.c"
      buckets = (s->set)->buckets;
    }
# 608 "variable.c"
    s = s->next;
  }
  while_break: ;
  }
# 614 "variable.c"
  p = (char *)"MAKELEVEL";
# 615 "variable.c"
  mklev_hash = 0U;
  {
# 616 "variable.c"
  while (1) {
    while_continue___0: ;
# 616 "variable.c"
    if (! ((int )*p != 0)) {
# 616 "variable.c"
      goto while_break___0;
    }
# 617 "variable.c"
    tmp = p;
# 617 "variable.c"
    p ++;
# 617 "variable.c"
    mklev_hash += (unsigned int )*tmp;
# 617 "variable.c"
    mklev_hash = (mklev_hash << 7) + (mklev_hash >> 20);
  }
  while_break___0: ;
  }
  {
# 621 "variable.c"
  tmp___0 = __builtin_alloca((unsigned long )buckets * sizeof(struct variable_bucket *));
# 621 "variable.c"
  table = (struct variable_bucket **)tmp___0;
# 623 "variable.c"
  memset((void *)((char *)table), 0, (unsigned long )buckets * sizeof(struct variable_bucket *));
# 627 "variable.c"
  nvariables = 0U;
# 628 "variable.c"
  s = set_list;
  }
  {
# 628 "variable.c"
  while (1) {
    while_continue___1: ;
# 628 "variable.c"
    if (! ((unsigned long )s != (unsigned long )((struct variable_set_list *)0))) {
# 628 "variable.c"
      goto while_break___1;
    }
# 630 "variable.c"
    set = s->set;
# 631 "variable.c"
    i = 0U;
    {
# 631 "variable.c"
    while (1) {
      while_continue___2: ;
# 631 "variable.c"
      if (! (i < set->buckets)) {
# 631 "variable.c"
        goto while_break___2;
      }
# 634 "variable.c"
      v = *(set->table + i);
      {
# 634 "variable.c"
      while (1) {
        while_continue___3: ;
# 634 "variable.c"
        if (! ((unsigned long )v != (unsigned long )((struct variable *)0))) {
# 634 "variable.c"
          goto while_break___3;
        }
# 636 "variable.c"
        j = i % buckets;
# 638 "variable.c"
        p___0 = v->name;
# 640 "variable.c"
        if (i == mklev_hash % set->buckets) {
# 640 "variable.c"
          if ((unsigned long )v->name == (unsigned long )"MAKELEVEL") {
# 644 "variable.c"
            goto __Cont;
          } else
# 640 "variable.c"
          if ((int )*(v->name) == (int )*"MAKELEVEL") {
# 640 "variable.c"
            if ((int )*(v->name) == 0) {
# 644 "variable.c"
              goto __Cont;
            } else {
              {
# 640 "variable.c"
              tmp___1 = strcmp((char const *)(v->name + 1), "MAKELEVEL" + 1);
              }
# 640 "variable.c"
              if (! tmp___1) {
# 644 "variable.c"
                goto __Cont;
              }
            }
          }
        }
# 649 "variable.c"
        if (v->per_target) {
# 649 "variable.c"
          if ((unsigned int )v->export == 3U) {
            {
# 653 "variable.c"
            tmp___2 = strlen((char const *)v->name);
# 653 "variable.c"
            gv = lookup_variable_in_set(v->name, (unsigned int )tmp___2, & global_variable_set);
            }
# 655 "variable.c"
            if (gv) {
# 656 "variable.c"
              v->export = gv->export;
            }
          }
        }
        {
# 660 "variable.c"
        if ((unsigned int )v->export == 3U) {
# 660 "variable.c"
          goto case_3;
        }
# 681 "variable.c"
        if ((unsigned int )v->export == 0U) {
# 681 "variable.c"
          goto case_0;
        }
# 684 "variable.c"
        if ((unsigned int )v->export == 1U) {
# 684 "variable.c"
          goto case_1;
        }
# 687 "variable.c"
        if ((unsigned int )v->export == 2U) {
# 687 "variable.c"
          goto case_2;
        }
# 659 "variable.c"
        goto switch_break;
        case_3:
# 662 "variable.c"
        if ((unsigned int )v->origin == 0U) {
# 664 "variable.c"
          goto __Cont;
        } else
# 662 "variable.c"
        if ((unsigned int )v->origin == 6U) {
# 664 "variable.c"
          goto __Cont;
        }
# 666 "variable.c"
        if (! export_all_variables) {
# 666 "variable.c"
          if ((unsigned int )v->origin != 4U) {
# 666 "variable.c"
            if ((unsigned int )v->origin != 1U) {
# 666 "variable.c"
              if ((unsigned int )v->origin != 3U) {
# 669 "variable.c"
                goto __Cont;
              }
            }
          }
        }
# 671 "variable.c"
        if ((int )*p___0 != 95) {
# 671 "variable.c"
          if ((int )*p___0 < 65) {
# 671 "variable.c"
            goto _L;
          } else
# 671 "variable.c"
          if ((int )*p___0 > 90) {
            _L:
# 671 "variable.c"
            if ((int )*p___0 < 97) {
# 673 "variable.c"
              goto __Cont;
            } else
# 671 "variable.c"
            if ((int )*p___0 > 122) {
# 673 "variable.c"
              goto __Cont;
            }
          }
        }
# 674 "variable.c"
        p___0 ++;
        {
# 674 "variable.c"
        while (1) {
          while_continue___4: ;
# 674 "variable.c"
          if (! ((int )*p___0 != 0)) {
# 674 "variable.c"
            goto while_break___4;
          }
# 675 "variable.c"
          if ((int )*p___0 != 95) {
# 675 "variable.c"
            if ((int )*p___0 < 97) {
# 675 "variable.c"
              goto _L___1;
            } else
# 675 "variable.c"
            if ((int )*p___0 > 122) {
              _L___1:
# 675 "variable.c"
              if ((int )*p___0 < 65) {
# 675 "variable.c"
                goto _L___0;
              } else
# 675 "variable.c"
              if ((int )*p___0 > 90) {
                _L___0:
# 675 "variable.c"
                if ((int )*p___0 < 48) {
# 677 "variable.c"
                  goto __Cont___0;
                } else
# 675 "variable.c"
                if ((int )*p___0 > 57) {
# 677 "variable.c"
                  goto __Cont___0;
                }
              }
            }
          }
          __Cont___0:
# 674 "variable.c"
          p___0 ++;
        }
        while_break___4: ;
        }
# 678 "variable.c"
        if ((int )*p___0 != 0) {
# 679 "variable.c"
          goto __Cont;
        }
# 680 "variable.c"
        goto switch_break;
        case_0:
# 683 "variable.c"
        goto switch_break;
        case_1:
# 686 "variable.c"
        goto __Cont;
        case_2:
# 689 "variable.c"
        if ((unsigned int )v->origin == 0U) {
# 690 "variable.c"
          goto __Cont;
        }
# 691 "variable.c"
        goto switch_break;
        switch_break: ;
        }
# 696 "variable.c"
        if (set->buckets != buckets) {
# 700 "variable.c"
          j = 0U;
# 701 "variable.c"
          np = v->name;
          {
# 701 "variable.c"
          while (1) {
            while_continue___5: ;
# 701 "variable.c"
            if (! ((int )*np != 0)) {
# 701 "variable.c"
              goto while_break___5;
            }
# 702 "variable.c"
            j += (unsigned int )*np;
# 702 "variable.c"
            j = (j << 7) + (j >> 20);
# 701 "variable.c"
            np ++;
          }
          while_break___5: ;
          }
# 703 "variable.c"
          j %= buckets;
        }
# 706 "variable.c"
        ov = *(table + j);
        {
# 706 "variable.c"
        while (1) {
          while_continue___6: ;
# 706 "variable.c"
          if (! ((unsigned long )ov != (unsigned long )((struct variable_bucket *)0))) {
# 706 "variable.c"
            goto while_break___6;
          }
# 707 "variable.c"
          if ((unsigned long )v->name == (unsigned long )(ov->variable)->name) {
# 708 "variable.c"
            goto while_break___6;
          } else
# 707 "variable.c"
          if ((int )*(v->name) == (int )*((ov->variable)->name)) {
# 707 "variable.c"
            if ((int )*(v->name) == 0) {
# 708 "variable.c"
              goto while_break___6;
            } else {
              {
# 707 "variable.c"
              tmp___3 = strcmp((char const *)(v->name + 1), (char const *)((ov->variable)->name + 1));
              }
# 707 "variable.c"
              if (! tmp___3) {
# 708 "variable.c"
                goto while_break___6;
              }
            }
          }
# 706 "variable.c"
          ov = ov->next;
        }
        while_break___6: ;
        }
# 710 "variable.c"
        if ((unsigned long )ov == (unsigned long )((struct variable_bucket *)0)) {
          {
# 713 "variable.c"
          tmp___4 = __builtin_alloca(sizeof(struct variable_bucket ));
# 713 "variable.c"
          entry = (struct variable_bucket *)tmp___4;
# 715 "variable.c"
          entry->next = *(table + j);
# 716 "variable.c"
          entry->variable = v;
# 717 "variable.c"
          *(table + j) = entry;
# 718 "variable.c"
          nvariables ++;
          }
        }
        __Cont:
# 634 "variable.c"
        v = v->next;
      }
      while_break___3: ;
      }
# 631 "variable.c"
      i ++;
    }
    while_break___2: ;
    }
# 628 "variable.c"
    s = s->next;
  }
  while_break___1: ;
  }
  {
# 724 "variable.c"
  tmp___5 = xmalloc((unsigned int )((unsigned long )(nvariables + 2U) * sizeof(char *)));
# 724 "variable.c"
  result___0 = (char **)tmp___5;
# 725 "variable.c"
  nvariables = 0U;
# 726 "variable.c"
  i = 0U;
  }
  {
# 726 "variable.c"
  while (1) {
    while_continue___7: ;
# 726 "variable.c"
    if (! (i < buckets)) {
# 726 "variable.c"
      goto while_break___7;
    }
# 729 "variable.c"
    b = *(table + i);
    {
# 729 "variable.c"
    while (1) {
      while_continue___8: ;
# 729 "variable.c"
      if (! ((unsigned long )b != (unsigned long )((struct variable_bucket *)0))) {
# 729 "variable.c"
        goto while_break___8;
      }
# 731 "variable.c"
      v___0 = b->variable;
# 736 "variable.c"
      if (v___0->recursive) {
# 736 "variable.c"
        if ((unsigned int )v___0->origin != 1U) {
# 736 "variable.c"
          if ((unsigned int )v___0->origin != 3U) {
            {
# 739 "variable.c"
            tmp___6 = recursively_expand(v___0);
# 739 "variable.c"
            value = tmp___6;
# 745 "variable.c"
            tmp___7 = nvariables;
# 745 "variable.c"
            nvariables ++;
# 745 "variable.c"
            *(result___0 + tmp___7) = concat(v___0->name, (char *)"=", value);
# 746 "variable.c"
            free((void *)value);
            }
          } else {
            {
# 757 "variable.c"
            tmp___8 = nvariables;
# 757 "variable.c"
            nvariables ++;
# 757 "variable.c"
            *(result___0 + tmp___8) = concat(v___0->name, (char *)"=", v___0->value);
            }
          }
        } else {
          {
# 757 "variable.c"
          tmp___8 = nvariables;
# 757 "variable.c"
          nvariables ++;
# 757 "variable.c"
          *(result___0 + tmp___8) = concat(v___0->name, (char *)"=", v___0->value);
          }
        }
      } else {
        {
# 757 "variable.c"
        tmp___8 = nvariables;
# 757 "variable.c"
        nvariables ++;
# 757 "variable.c"
        *(result___0 + tmp___8) = concat(v___0->name, (char *)"=", v___0->value);
        }
      }
# 729 "variable.c"
      b = b->next;
    }
    while_break___8: ;
    }
# 726 "variable.c"
    i ++;
  }
  while_break___7: ;
  }
  {
# 761 "variable.c"
  tmp___9 = xmalloc(100U);
# 761 "variable.c"
  *(result___0 + nvariables) = tmp___9;
# 762 "variable.c"
  sprintf((char * __restrict )*(result___0 + nvariables), (char const * __restrict )"MAKELEVEL=%u",
          makelevel + 1U);
# 763 "variable.c"
  nvariables ++;
# 763 "variable.c"
  *(result___0 + nvariables) = (char *)0;
  }
# 765 "variable.c"
  return (result___0);
}
}
# 781 "variable.c"
struct variable *try_variable_definition(struct floc const *flocp , char *line ,
                                         enum variable_origin origin , int target_var )
{
  register int c ;
  register char *p ;
  register char *beg ;
  register char *end ;
  enum __anonenum_flavor_56 flavor ;
  char *name ;
  char *expanded_name ;
  char *value ;
  char *alloc_value ;
  struct variable *v ;
  int append ;
  char *tmp ;
  char *tmp___0 ;
  char *tmp___1 ;
  char *tmp___2 ;
  char closeparen ;
  int count ;
  char *tmp___3 ;
  unsigned short const **tmp___4 ;
  void *tmp___5 ;
  char *tmp___6 ;
  size_t tmp___7 ;
  size_t tmp___8 ;
  unsigned int oldlen ;
  unsigned int newlen ;
  size_t tmp___9 ;
  size_t tmp___10 ;
  void *tmp___11 ;
  size_t tmp___12 ;

  {
# 789 "variable.c"
  p = line;
# 792 "variable.c"
  flavor = (enum __anonenum_flavor_56 )0;
# 794 "variable.c"
  alloc_value = (char *)((void *)0);
# 796 "variable.c"
  append = 0;
  {
# 798 "variable.c"
  while (1) {
    while_continue: ;
# 800 "variable.c"
    tmp = p;
# 800 "variable.c"
    p ++;
# 800 "variable.c"
    c = (int )*tmp;
# 801 "variable.c"
    if (c == 0) {
# 802 "variable.c"
      return ((struct variable *)0);
    } else
# 801 "variable.c"
    if (c == 35) {
# 802 "variable.c"
      return ((struct variable *)0);
    }
# 803 "variable.c"
    if (c == 61) {
# 805 "variable.c"
      end = p - 1;
# 806 "variable.c"
      flavor = (enum __anonenum_flavor_56 )2;
# 807 "variable.c"
      goto while_break;
    } else
# 809 "variable.c"
    if (c == 58) {
# 810 "variable.c"
      if ((int )*p == 61) {
# 812 "variable.c"
        tmp___0 = p;
# 812 "variable.c"
        p ++;
# 812 "variable.c"
        end = tmp___0 - 1;
# 813 "variable.c"
        flavor = (enum __anonenum_flavor_56 )1;
# 814 "variable.c"
        goto while_break;
      } else {
# 818 "variable.c"
        return ((struct variable *)0);
      }
    } else
# 819 "variable.c"
    if (c == 43) {
# 819 "variable.c"
      if ((int )*p == 61) {
# 821 "variable.c"
        tmp___1 = p;
# 821 "variable.c"
        p ++;
# 821 "variable.c"
        end = tmp___1 - 1;
# 822 "variable.c"
        flavor = (enum __anonenum_flavor_56 )3;
# 823 "variable.c"
        goto while_break;
      } else {
# 819 "variable.c"
        goto _L___0;
      }
    } else
    _L___0:
# 825 "variable.c"
    if (c == 63) {
# 825 "variable.c"
      if ((int )*p == 61) {
# 827 "variable.c"
        tmp___2 = p;
# 827 "variable.c"
        p ++;
# 827 "variable.c"
        end = tmp___2 - 1;
# 828 "variable.c"
        flavor = (enum __anonenum_flavor_56 )4;
# 829 "variable.c"
        goto while_break;
      } else {
# 825 "variable.c"
        goto _L;
      }
    } else
    _L:
# 831 "variable.c"
    if (c == 36) {
# 837 "variable.c"
      tmp___3 = p;
# 837 "variable.c"
      p ++;
# 837 "variable.c"
      c = (int )*tmp___3;
# 838 "variable.c"
      if (c == 40) {
# 839 "variable.c"
        closeparen = (char )')';
      } else
# 840 "variable.c"
      if (c == 123) {
# 841 "variable.c"
        closeparen = (char )'}';
      } else {
# 843 "variable.c"
        goto while_continue;
      }
# 847 "variable.c"
      count = 0;
      {
# 848 "variable.c"
      while (1) {
        while_continue___0: ;
# 848 "variable.c"
        if (! ((int )*p != 0)) {
# 848 "variable.c"
          goto while_break___0;
        }
# 850 "variable.c"
        if ((int )*p == c) {
# 851 "variable.c"
          count ++;
        } else
# 852 "variable.c"
        if ((int )*p == (int )closeparen) {
# 852 "variable.c"
          count --;
# 852 "variable.c"
          if (count < 0) {
# 854 "variable.c"
            p ++;
# 855 "variable.c"
            goto while_break___0;
          }
        }
# 848 "variable.c"
        p ++;
      }
      while_break___0: ;
      }
    }
  }
  while_break: ;
  }
  {
# 861 "variable.c"
  beg = next_token(line);
  }
  {
# 862 "variable.c"
  while (1) {
    while_continue___1: ;
# 862 "variable.c"
    if ((unsigned long )end > (unsigned long )beg) {
      {
# 862 "variable.c"
      tmp___4 = __ctype_b_loc();
      }
# 862 "variable.c"
      if (! ((int const )*(*tmp___4 + (int )*(end + -1)) & 1)) {
# 862 "variable.c"
        goto while_break___1;
      }
    } else {
# 862 "variable.c"
      goto while_break___1;
    }
# 863 "variable.c"
    end --;
  }
  while_break___1: ;
  }
  {
# 864 "variable.c"
  p = next_token(p);
# 867 "variable.c"
  tmp___5 = __builtin_alloca((unsigned long )((end - beg) + 1L));
# 867 "variable.c"
  name = (char *)tmp___5;
# 868 "variable.c"
  memmove((void *)name, (void const *)beg, (size_t )(end - beg));
# 869 "variable.c"
  *(name + (end - beg)) = (char )'\000';
# 870 "variable.c"
  expanded_name = allocated_variable_expand_for_file(name, (struct file *)0);
  }
# 872 "variable.c"
  if ((int )*(expanded_name + 0) == 0) {
    {
# 873 "variable.c"
    tmp___6 = dcgettext((char const *)((void *)0), "empty variable name", 5);
# 873 "variable.c"
    fatal(flocp, (char const *)tmp___6);
    }
  }
  {
# 878 "variable.c"
  if ((unsigned int )flavor == 0U) {
# 878 "variable.c"
    goto case_0;
  }
# 882 "variable.c"
  if ((unsigned int )flavor == 1U) {
# 882 "variable.c"
    goto case_1;
  }
# 889 "variable.c"
  if ((unsigned int )flavor == 4U) {
# 889 "variable.c"
    goto case_4;
  }
# 899 "variable.c"
  if ((unsigned int )flavor == 2U) {
# 899 "variable.c"
    goto case_2;
  }
# 905 "variable.c"
  if ((unsigned int )flavor == 3U) {
# 905 "variable.c"
    goto case_3;
  }
# 877 "variable.c"
  goto switch_break;
  case_0:
  {
# 881 "variable.c"
  abort();
  }
  case_1:
  {
# 887 "variable.c"
  alloc_value = allocated_variable_expand_for_file(p, (struct file *)0);
# 887 "variable.c"
  value = alloc_value;
  }
# 888 "variable.c"
  goto switch_break;
  case_4:
  {
# 892 "variable.c"
  tmp___7 = strlen((char const *)expanded_name);
# 892 "variable.c"
  v = lookup_variable(expanded_name, (unsigned int )tmp___7);
  }
# 893 "variable.c"
  if (v) {
    {
# 895 "variable.c"
    free((void *)expanded_name);
    }
# 896 "variable.c"
    return (v);
  }
# 898 "variable.c"
  flavor = (enum __anonenum_flavor_56 )2;
  case_2:
# 903 "variable.c"
  value = p;
# 904 "variable.c"
  goto switch_break;
  case_3:
# 908 "variable.c"
  if (target_var) {
# 910 "variable.c"
    append = 1;
# 911 "variable.c"
    flavor = (enum __anonenum_flavor_56 )2;
# 912 "variable.c"
    value = p;
# 913 "variable.c"
    goto switch_break;
  }
  {
# 918 "variable.c"
  tmp___8 = strlen((char const *)expanded_name);
# 918 "variable.c"
  v = lookup_variable(expanded_name, (unsigned int )tmp___8);
  }
# 919 "variable.c"
  if ((unsigned long )v == (unsigned long )((struct variable *)0)) {
# 923 "variable.c"
    value = p;
# 924 "variable.c"
    flavor = (enum __anonenum_flavor_56 )2;
  } else {
# 932 "variable.c"
    if (v->recursive) {
# 935 "variable.c"
      flavor = (enum __anonenum_flavor_56 )2;
    } else {
      {
# 942 "variable.c"
      alloc_value = allocated_variable_expand_for_file(p, (struct file *)0);
# 942 "variable.c"
      p = alloc_value;
      }
    }
    {
# 944 "variable.c"
    tmp___9 = strlen((char const *)v->value);
# 944 "variable.c"
    oldlen = (unsigned int )tmp___9;
# 945 "variable.c"
    tmp___10 = strlen((char const *)p);
# 945 "variable.c"
    newlen = (unsigned int )tmp___10;
# 946 "variable.c"
    tmp___11 = __builtin_alloca((unsigned long )(((oldlen + 1U) + newlen) + 1U));
# 946 "variable.c"
    value = (char *)tmp___11;
# 947 "variable.c"
    memmove((void *)value, (void const *)v->value, (size_t )oldlen);
# 948 "variable.c"
    *(value + oldlen) = (char )' ';
# 949 "variable.c"
    memmove((void *)(value + (oldlen + 1U)), (void const *)p, (size_t )(newlen + 1U));
    }
  }
  switch_break: ;
  }
  {
# 1055 "variable.c"
  tmp___12 = strlen((char const *)expanded_name);
# 1055 "variable.c"
  v = define_variable_in_set(expanded_name, (unsigned int )tmp___12, value, origin,
                             (unsigned int )flavor == 2U, current_variable_set_list->set,
                             flocp);
# 1058 "variable.c"
  v->append = (unsigned int )append;
  }
# 1060 "variable.c"
  if (alloc_value) {
    {
# 1061 "variable.c"
    free((void *)alloc_value);
    }
  }
  {
# 1062 "variable.c"
  free((void *)expanded_name);
  }
# 1064 "variable.c"
  return (v);
}
}
# 1069 "variable.c"
static void print_variable(struct variable *v , char *prefix )
{
  char const *origin ;
  char *tmp ;
  char *tmp___0 ;
  char *tmp___1 ;
  char *tmp___2 ;
  char *tmp___3 ;
  char *tmp___4 ;
  char *tmp___5 ;
  register char *p ;
  char const *tmp___6 ;
  char const *tmp___7 ;
  char *tmp___8 ;

  {
  {
# 1077 "variable.c"
  if ((unsigned int )v->origin == 0U) {
# 1077 "variable.c"
    goto case_0;
  }
# 1081 "variable.c"
  if ((unsigned int )v->origin == 1U) {
# 1081 "variable.c"
    goto case_1;
  }
# 1084 "variable.c"
  if ((unsigned int )v->origin == 2U) {
# 1084 "variable.c"
    goto case_2;
  }
# 1087 "variable.c"
  if ((unsigned int )v->origin == 3U) {
# 1087 "variable.c"
    goto case_3;
  }
# 1090 "variable.c"
  if ((unsigned int )v->origin == 4U) {
# 1090 "variable.c"
    goto case_4;
  }
# 1093 "variable.c"
  if ((unsigned int )v->origin == 5U) {
# 1093 "variable.c"
    goto case_5;
  }
# 1096 "variable.c"
  if ((unsigned int )v->origin == 6U) {
# 1096 "variable.c"
    goto case_6;
  }
# 1099 "variable.c"
  goto switch_default;
  case_0:
  {
# 1079 "variable.c"
  tmp = dcgettext((char const *)((void *)0), "default", 5);
# 1079 "variable.c"
  origin = (char const *)tmp;
  }
# 1080 "variable.c"
  goto switch_break;
  case_1:
  {
# 1082 "variable.c"
  tmp___0 = dcgettext((char const *)((void *)0), "environment", 5);
# 1082 "variable.c"
  origin = (char const *)tmp___0;
  }
# 1083 "variable.c"
  goto switch_break;
  case_2:
  {
# 1085 "variable.c"
  tmp___1 = dcgettext((char const *)((void *)0), "makefile", 5);
# 1085 "variable.c"
  origin = (char const *)tmp___1;
  }
# 1086 "variable.c"
  goto switch_break;
  case_3:
  {
# 1088 "variable.c"
  tmp___2 = dcgettext((char const *)((void *)0), "environment under -e", 5);
# 1088 "variable.c"
  origin = (char const *)tmp___2;
  }
# 1089 "variable.c"
  goto switch_break;
  case_4:
  {
# 1091 "variable.c"
  tmp___3 = dcgettext((char const *)((void *)0), "command line", 5);
# 1091 "variable.c"
  origin = (char const *)tmp___3;
  }
# 1092 "variable.c"
  goto switch_break;
  case_5:
  {
# 1094 "variable.c"
  tmp___4 = dcgettext((char const *)((void *)0), "`override\' directive", 5);
# 1094 "variable.c"
  origin = (char const *)tmp___4;
  }
# 1095 "variable.c"
  goto switch_break;
  case_6:
  {
# 1097 "variable.c"
  tmp___5 = dcgettext((char const *)((void *)0), "automatic", 5);
# 1097 "variable.c"
  origin = (char const *)tmp___5;
  }
# 1098 "variable.c"
  goto switch_break;
  switch_default:
  {
# 1101 "variable.c"
  abort();
  }
  switch_break: ;
  }
  {
# 1103 "variable.c"
  fputs((char const * __restrict )"# ", (FILE * __restrict )stdout);
# 1104 "variable.c"
  fputs((char const * __restrict )origin, (FILE * __restrict )stdout);
  }
# 1105 "variable.c"
  if (v->fileinfo.filenm) {
    {
# 1106 "variable.c"
    printf((char const * __restrict )" (from `%s\', line %lu)", v->fileinfo.filenm,
           v->fileinfo.lineno);
    }
  }
  {
# 1107 "variable.c"
  putchar('\n');
# 1108 "variable.c"
  fputs((char const * __restrict )prefix, (FILE * __restrict )stdout);
  }
# 1111 "variable.c"
  if (v->recursive) {
    {
# 1111 "variable.c"
    tmp___8 = strchr((char const *)v->value, '\n');
    }
# 1111 "variable.c"
    if ((unsigned long )tmp___8 != (unsigned long )((char *)0)) {
      {
# 1112 "variable.c"
      printf((char const * __restrict )"define %s\n%s\nendef\n", v->name, v->value);
      }
    } else {
# 1111 "variable.c"
      goto _L___0;
    }
  } else {
    _L___0:
# 1117 "variable.c"
    if (v->recursive) {
# 1117 "variable.c"
      if (v->append) {
# 1117 "variable.c"
        tmp___6 = "+";
      } else {
# 1117 "variable.c"
        tmp___6 = "";
      }
# 1117 "variable.c"
      tmp___7 = tmp___6;
    } else {
# 1117 "variable.c"
      tmp___7 = ":";
    }
    {
# 1117 "variable.c"
    printf((char const * __restrict )"%s %s= ", v->name, tmp___7);
# 1120 "variable.c"
    p = next_token(v->value);
    }
# 1121 "variable.c"
    if ((unsigned long )p != (unsigned long )v->value) {
# 1121 "variable.c"
      if ((int )*p == 0) {
        {
# 1123 "variable.c"
        printf((char const * __restrict )"$(subst ,,%s)", v->value);
        }
      } else {
# 1121 "variable.c"
        goto _L;
      }
    } else
    _L:
# 1124 "variable.c"
    if (v->recursive) {
      {
# 1125 "variable.c"
      fputs((char const * __restrict )v->value, (FILE * __restrict )stdout);
      }
    } else {
# 1128 "variable.c"
      p = v->value;
      {
# 1128 "variable.c"
      while (1) {
        while_continue: ;
# 1128 "variable.c"
        if (! ((int )*p != 0)) {
# 1128 "variable.c"
          goto while_break;
        }
# 1130 "variable.c"
        if ((int )*p == 36) {
          {
# 1131 "variable.c"
          putchar('$');
          }
        }
        {
# 1132 "variable.c"
        putchar((int )*p);
# 1128 "variable.c"
        p ++;
        }
      }
      while_break: ;
      }
    }
    {
# 1134 "variable.c"
    putchar('\n');
    }
  }
# 1136 "variable.c"
  return;
}
}
# 1142 "variable.c"
void print_variable_set(struct variable_set *set , char *prefix )
{
  register unsigned int i ;
  register unsigned int nvariables ;
  register unsigned int per_bucket ;
  register struct variable *v ;
  register unsigned int this_bucket ;
  char *tmp ;
  char *tmp___0 ;
  char *tmp___1 ;

  {
# 1150 "variable.c"
  nvariables = 0U;
# 1150 "variable.c"
  per_bucket = nvariables;
# 1151 "variable.c"
  i = 0U;
  {
# 1151 "variable.c"
  while (1) {
    while_continue: ;
# 1151 "variable.c"
    if (! (i < set->buckets)) {
# 1151 "variable.c"
      goto while_break;
    }
# 1153 "variable.c"
    this_bucket = 0U;
# 1155 "variable.c"
    v = *(set->table + i);
    {
# 1155 "variable.c"
    while (1) {
      while_continue___0: ;
# 1155 "variable.c"
      if (! ((unsigned long )v != (unsigned long )((struct variable *)0))) {
# 1155 "variable.c"
        goto while_break___0;
      }
      {
# 1157 "variable.c"
      this_bucket ++;
# 1158 "variable.c"
      print_variable(v, prefix);
# 1155 "variable.c"
      v = v->next;
      }
    }
    while_break___0: ;
    }
# 1161 "variable.c"
    nvariables += this_bucket;
# 1162 "variable.c"
    if (this_bucket > per_bucket) {
# 1163 "variable.c"
      per_bucket = this_bucket;
    }
# 1151 "variable.c"
    i ++;
  }
  while_break: ;
  }
# 1166 "variable.c"
  if (nvariables == 0U) {
    {
# 1167 "variable.c"
    tmp = dcgettext((char const *)((void *)0), "# No variables.", 5);
# 1167 "variable.c"
    puts((char const *)tmp);
    }
  } else {
    {
# 1170 "variable.c"
    tmp___0 = dcgettext((char const *)((void *)0), "# %u variables in %u hash buckets.\n",
                        5);
# 1170 "variable.c"
    printf((char const * __restrict )tmp___0, nvariables, set->buckets);
# 1173 "variable.c"
    tmp___1 = dcgettext((char const *)((void *)0), "# average of %.1f variables per bucket, max %u in one bucket.\n",
                        5);
# 1173 "variable.c"
    printf((char const * __restrict )tmp___1, (double )nvariables / (double )set->buckets,
           per_bucket);
    }
  }
# 1187 "variable.c"
  return;
}
}
# 1192 "variable.c"
void print_variable_data_base(void)
{
  char *tmp ;

  {
  {
# 1195 "variable.c"
  tmp = dcgettext((char const *)((void *)0), "\n# Variables\n", 5);
# 1195 "variable.c"
  puts((char const *)tmp);
# 1197 "variable.c"
  print_variable_set(& global_variable_set, (char *)"");
  }
# 1198 "variable.c"
  return;
}
}
# 1203 "variable.c"
void print_file_variables(struct file *file )
{


  {
# 1207 "variable.c"
  if ((unsigned long )file->variables != (unsigned long )((struct variable_set_list *)0)) {
    {
# 1208 "variable.c"
    print_variable_set((file->variables)->set, (char *)"# ");
    }
  }
# 1209 "variable.c"
  return;
}
}
# 1 "vpath.o"
#pragma merger("0","/tmp/cil-lr0nQLdA.i","-g,-O0")
# 42 "vpath.c"
static struct vpath *vpaths ;
# 46 "vpath.c"
static struct vpath *general_vpath ;
# 50 "vpath.c"
static struct vpath *gpaths ;
# 52 "vpath.c"
static int selective_vpath_search(struct vpath *path , char **file , uintmax_t *mtime_ptr ) ;
# 58 "vpath.c"
void build_vpath_lists(void)
{
  register struct vpath *new ;
  register struct vpath *old ;
  register struct vpath *nexto ;
  register char *p ;
  int save ;
  struct vpath *save_vpaths ;
  int save___0 ;
  struct vpath *save_vpaths___0 ;

  {
# 61 "vpath.c"
  new = (struct vpath *)0;
# 66 "vpath.c"
  old = vpaths;
  {
# 66 "vpath.c"
  while (1) {
    while_continue: ;
# 66 "vpath.c"
    if (! ((unsigned long )old != (unsigned long )((struct vpath *)0))) {
# 66 "vpath.c"
      goto while_break;
    }
# 68 "vpath.c"
    nexto = old->next;
# 69 "vpath.c"
    old->next = new;
# 70 "vpath.c"
    new = old;
# 66 "vpath.c"
    old = nexto;
  }
  while_break: ;
  }
  {
# 73 "vpath.c"
  vpaths = new;
# 81 "vpath.c"
  save = warn_undefined_variables_flag;
# 82 "vpath.c"
  warn_undefined_variables_flag = 0;
# 84 "vpath.c"
  p = variable_expand((char *)"$(strip $(VPATH))");
# 86 "vpath.c"
  warn_undefined_variables_flag = save;
  }
# 89 "vpath.c"
  if ((int )*p != 0) {
    {
# 92 "vpath.c"
    save_vpaths = vpaths;
# 96 "vpath.c"
    vpaths = (struct vpath *)0;
# 99 "vpath.c"
    construct_vpath_list((char *)"%", p);
# 103 "vpath.c"
    general_vpath = vpaths;
# 104 "vpath.c"
    vpaths = save_vpaths;
    }
  }
  {
# 113 "vpath.c"
  save___0 = warn_undefined_variables_flag;
# 114 "vpath.c"
  warn_undefined_variables_flag = 0;
# 116 "vpath.c"
  p = variable_expand((char *)"$(strip $(GPATH))");
# 118 "vpath.c"
  warn_undefined_variables_flag = save___0;
  }
# 121 "vpath.c"
  if ((int )*p != 0) {
    {
# 124 "vpath.c"
    save_vpaths___0 = vpaths;
# 128 "vpath.c"
    vpaths = (struct vpath *)0;
# 131 "vpath.c"
    construct_vpath_list((char *)"%", p);
# 135 "vpath.c"
    gpaths = vpaths;
# 136 "vpath.c"
    vpaths = save_vpaths___0;
    }
  }
# 138 "vpath.c"
  return;
}
}
# 159 "vpath.c"
void construct_vpath_list(char *pattern , char *dirpath )
{
  register unsigned int elem ;
  register char *p ;
  register char **vpath ;
  register unsigned int maxvpath ;
  unsigned int maxelem ;
  char *percent ;
  register struct vpath *path ;
  register struct vpath *lastpath ;
  struct vpath *next ;
  int tmp ;
  char *tmp___0 ;
  unsigned short const **tmp___1 ;
  char *tmp___2 ;
  unsigned short const **tmp___3 ;
  char *v ;
  unsigned int len ;
  unsigned short const **tmp___4 ;
  unsigned int tmp___5 ;
  int tmp___6 ;
  unsigned short const **tmp___7 ;
  struct vpath *path___0 ;
  char *tmp___8 ;
  char *tmp___9 ;
  size_t tmp___10 ;

  {
# 168 "vpath.c"
  percent = (char *)((void *)0);
# 170 "vpath.c"
  if ((unsigned long )pattern != (unsigned long )((char *)0)) {
    {
# 172 "vpath.c"
    pattern = xstrdup((char const *)pattern);
# 173 "vpath.c"
    percent = find_percent(pattern);
    }
  }
# 176 "vpath.c"
  if ((unsigned long )dirpath == (unsigned long )((char *)0)) {
# 181 "vpath.c"
    lastpath = (struct vpath *)0;
# 182 "vpath.c"
    path = vpaths;
    {
# 183 "vpath.c"
    while (1) {
      while_continue: ;
# 183 "vpath.c"
      if (! ((unsigned long )path != (unsigned long )((struct vpath *)0))) {
# 183 "vpath.c"
        goto while_break;
      }
# 185 "vpath.c"
      next = path->next;
# 187 "vpath.c"
      if ((unsigned long )pattern == (unsigned long )((char *)0)) {
# 187 "vpath.c"
        goto _L___1;
      } else
# 187 "vpath.c"
      if ((unsigned long )percent == (unsigned long )((char *)0)) {
# 187 "vpath.c"
        if ((unsigned long )path->percent == (unsigned long )((char *)0)) {
# 187 "vpath.c"
          goto _L___2;
        } else {
# 187 "vpath.c"
          goto _L___3;
        }
      } else
      _L___3:
# 187 "vpath.c"
      if (percent - pattern == path->percent - path->pattern) {
        _L___2:
# 187 "vpath.c"
        if ((unsigned long )pattern == (unsigned long )path->pattern) {
# 187 "vpath.c"
          goto _L___1;
        } else
# 187 "vpath.c"
        if ((int )*pattern == (int )*(path->pattern)) {
# 187 "vpath.c"
          if ((int )*pattern == 0) {
# 187 "vpath.c"
            goto _L___1;
          } else {
            {
# 187 "vpath.c"
            tmp = strcmp((char const *)(pattern + 1), (char const *)(path->pattern + 1));
            }
# 187 "vpath.c"
            if (tmp) {
# 204 "vpath.c"
              lastpath = path;
            } else {
              _L___1:
# 193 "vpath.c"
              if ((unsigned long )lastpath == (unsigned long )((struct vpath *)0)) {
# 194 "vpath.c"
                vpaths = path->next;
              } else {
# 196 "vpath.c"
                lastpath->next = next;
              }
              {
# 199 "vpath.c"
              free((void *)path->pattern);
# 200 "vpath.c"
              free((void *)((char *)path->searchpath));
# 201 "vpath.c"
              free((void *)((char *)path));
              }
            }
          }
        } else {
# 204 "vpath.c"
          lastpath = path;
        }
      } else {
# 204 "vpath.c"
        lastpath = path;
      }
# 206 "vpath.c"
      path = next;
    }
    while_break: ;
    }
# 209 "vpath.c"
    if ((unsigned long )pattern != (unsigned long )((char *)0)) {
      {
# 210 "vpath.c"
      free((void *)pattern);
      }
    }
# 211 "vpath.c"
    return;
  }
# 222 "vpath.c"
  maxelem = 2U;
# 223 "vpath.c"
  p = dirpath;
  {
# 224 "vpath.c"
  while (1) {
    while_continue___0: ;
# 224 "vpath.c"
    if (! ((int )*p != 0)) {
# 224 "vpath.c"
      goto while_break___0;
    }
# 225 "vpath.c"
    tmp___0 = p;
# 225 "vpath.c"
    p ++;
# 225 "vpath.c"
    if ((int )*tmp___0 == 58) {
# 226 "vpath.c"
      maxelem ++;
    } else {
      {
# 225 "vpath.c"
      tmp___1 = __ctype_b_loc();
      }
# 225 "vpath.c"
      if ((int const )*(*tmp___1 + (int )*p) & 1) {
# 226 "vpath.c"
        maxelem ++;
      }
    }
  }
  while_break___0: ;
  }
  {
# 228 "vpath.c"
  tmp___2 = xmalloc((unsigned int )((unsigned long )maxelem * sizeof(char *)));
# 228 "vpath.c"
  vpath = (char **)tmp___2;
# 229 "vpath.c"
  maxvpath = 0U;
# 232 "vpath.c"
  p = dirpath;
  }
  {
# 233 "vpath.c"
  while (1) {
    while_continue___1: ;
# 233 "vpath.c"
    if (! ((int )*p == 58)) {
      {
# 233 "vpath.c"
      tmp___3 = __ctype_b_loc();
      }
# 233 "vpath.c"
      if (! ((int const )*(*tmp___3 + (int )*p) & 1)) {
# 233 "vpath.c"
        goto while_break___1;
      }
    }
# 234 "vpath.c"
    p ++;
  }
  while_break___1: ;
  }
# 236 "vpath.c"
  elem = 0U;
  {
# 237 "vpath.c"
  while (1) {
    while_continue___2: ;
# 237 "vpath.c"
    if (! ((int )*p != 0)) {
# 237 "vpath.c"
      goto while_break___2;
    }
# 243 "vpath.c"
    v = p;
    {
# 244 "vpath.c"
    while (1) {
      while_continue___3: ;
# 244 "vpath.c"
      if ((int )*p != 0) {
# 244 "vpath.c"
        if ((int )*p != 58) {
          {
# 244 "vpath.c"
          tmp___4 = __ctype_b_loc();
          }
# 244 "vpath.c"
          if ((int const )*(*tmp___4 + (int )*p) & 1) {
# 244 "vpath.c"
            goto while_break___3;
          }
        } else {
# 244 "vpath.c"
          goto while_break___3;
        }
      } else {
# 244 "vpath.c"
        goto while_break___3;
      }
# 245 "vpath.c"
      p ++;
    }
    while_break___3: ;
    }
# 247 "vpath.c"
    len = (unsigned int )(p - v);
# 254 "vpath.c"
    if (len > 1U) {
# 254 "vpath.c"
      if ((int )*(p + -1) == 47) {
# 255 "vpath.c"
        len --;
      }
    }
# 257 "vpath.c"
    if (len > 1U) {
# 257 "vpath.c"
      goto _L___4;
    } else
# 257 "vpath.c"
    if ((int )*v != 46) {
      _L___4:
      {
# 259 "vpath.c"
      v = savestring((char const *)v, len);
# 263 "vpath.c"
      tmp___6 = dir_file_exists_p(v, (char *)"");
      }
# 263 "vpath.c"
      if (tmp___6) {
        {
# 266 "vpath.c"
        tmp___5 = elem;
# 266 "vpath.c"
        elem ++;
# 266 "vpath.c"
        *(vpath + tmp___5) = dir_name(v);
# 267 "vpath.c"
        free((void *)v);
        }
# 268 "vpath.c"
        if (len > maxvpath) {
# 269 "vpath.c"
          maxvpath = len;
        }
      } else {
        {
# 273 "vpath.c"
        free((void *)v);
        }
      }
    }
    {
# 277 "vpath.c"
    while (1) {
      while_continue___4: ;
# 277 "vpath.c"
      if (! ((int )*p == 58)) {
        {
# 277 "vpath.c"
        tmp___7 = __ctype_b_loc();
        }
# 277 "vpath.c"
        if (! ((int const )*(*tmp___7 + (int )*p) & 1)) {
# 277 "vpath.c"
          goto while_break___4;
        }
      }
# 278 "vpath.c"
      p ++;
    }
    while_break___4: ;
    }
  }
  while_break___2: ;
  }
# 281 "vpath.c"
  if (elem > 0U) {
# 287 "vpath.c"
    if (elem < maxelem - 1U) {
      {
# 288 "vpath.c"
      tmp___8 = xrealloc((char *)vpath, (unsigned int )((unsigned long )(elem + 1U) * sizeof(char *)));
# 288 "vpath.c"
      vpath = (char **)tmp___8;
      }
    }
    {
# 292 "vpath.c"
    *(vpath + elem) = (char *)0;
# 295 "vpath.c"
    tmp___9 = xmalloc((unsigned int )sizeof(struct vpath ));
# 295 "vpath.c"
    path___0 = (struct vpath *)tmp___9;
# 296 "vpath.c"
    path___0->searchpath = vpath;
# 297 "vpath.c"
    path___0->maxlen = maxvpath;
# 298 "vpath.c"
    path___0->next = vpaths;
# 299 "vpath.c"
    vpaths = path___0;
# 302 "vpath.c"
    path___0->pattern = pattern;
# 303 "vpath.c"
    path___0->percent = percent;
# 304 "vpath.c"
    tmp___10 = strlen((char const *)pattern);
# 304 "vpath.c"
    path___0->patlen = (unsigned int )tmp___10;
    }
  } else {
    {
# 309 "vpath.c"
    free((void *)((char *)vpath));
    }
# 310 "vpath.c"
    if ((unsigned long )pattern != (unsigned long )((char *)0)) {
      {
# 311 "vpath.c"
      free((void *)pattern);
      }
    }
  }
# 313 "vpath.c"
  return;
}
}
# 318 "vpath.c"
int gpath_search(char *file , int len )
{
  register char **gp ;
  int tmp ;

  {
# 325 "vpath.c"
  if (gpaths) {
# 325 "vpath.c"
    if ((unsigned int )len <= gpaths->maxlen) {
# 326 "vpath.c"
      gp = gpaths->searchpath;
      {
# 326 "vpath.c"
      while (1) {
        while_continue: ;
# 326 "vpath.c"
        if (! ((unsigned long )*gp != (unsigned long )((void *)0))) {
# 326 "vpath.c"
          goto while_break;
        }
        {
# 327 "vpath.c"
        tmp = strncmp((char const *)*gp, (char const *)file, (size_t )len);
        }
# 327 "vpath.c"
        if (tmp == 0) {
# 327 "vpath.c"
          if ((int )*(*gp + len) == 0) {
# 328 "vpath.c"
            return (1);
          }
        }
# 326 "vpath.c"
        gp ++;
      }
      while_break: ;
      }
    }
  }
# 330 "vpath.c"
  return (0);
}
}
# 339 "vpath.c"
int vpath_search(char **file , uintmax_t *mtime_ptr )
{
  register struct vpath *v ;
  int tmp ;
  int tmp___0 ;
  int tmp___1 ;

  {
# 349 "vpath.c"
  if ((int )*(*file) == 47) {
# 355 "vpath.c"
    return (0);
  } else
# 349 "vpath.c"
  if ((unsigned long )vpaths == (unsigned long )((struct vpath *)0)) {
# 349 "vpath.c"
    if ((unsigned long )general_vpath == (unsigned long )((struct vpath *)0)) {
# 355 "vpath.c"
      return (0);
    }
  }
# 357 "vpath.c"
  v = vpaths;
  {
# 357 "vpath.c"
  while (1) {
    while_continue: ;
# 357 "vpath.c"
    if (! ((unsigned long )v != (unsigned long )((struct vpath *)0))) {
# 357 "vpath.c"
      goto while_break;
    }
    {
# 358 "vpath.c"
    tmp___0 = pattern_matches(v->pattern, v->percent, *file);
    }
# 358 "vpath.c"
    if (tmp___0) {
      {
# 359 "vpath.c"
      tmp = selective_vpath_search(v, file, mtime_ptr);
      }
# 359 "vpath.c"
      if (tmp) {
# 360 "vpath.c"
        return (1);
      }
    }
# 357 "vpath.c"
    v = v->next;
  }
  while_break: ;
  }
# 362 "vpath.c"
  if ((unsigned long )general_vpath != (unsigned long )((struct vpath *)0)) {
    {
# 362 "vpath.c"
    tmp___1 = selective_vpath_search(general_vpath, file, mtime_ptr);
    }
# 362 "vpath.c"
    if (tmp___1) {
# 364 "vpath.c"
      return (1);
    }
  }
# 366 "vpath.c"
  return (0);
}
}
# 376 "vpath.c"
static int selective_vpath_search(struct vpath *path , char **file , uintmax_t *mtime_ptr )
{
  int not_target ;
  char *name ;
  char *n ;
  char *filename ;
  register char **vpath ;
  unsigned int maxvpath ;
  register unsigned int i ;
  unsigned int flen ;
  unsigned int vlen ;
  unsigned int name_dplen ;
  int exists ;
  struct file *f ;
  struct file *tmp ;
  int tmp___0 ;
  size_t tmp___1 ;
  char *tmp___2 ;
  int exists_in_cache ;
  size_t tmp___3 ;
  char *tmp___4 ;
  struct file *f___0 ;
  struct file *tmp___5 ;
  int tmp___6 ;
  struct stat st ;
  uintmax_t tmp___7 ;
  uintmax_t tmp___8 ;
  int tmp___9 ;

  {
  {
# 385 "vpath.c"
  vpath = path->searchpath;
# 386 "vpath.c"
  maxvpath = path->maxlen;
# 389 "vpath.c"
  exists = 0;
# 395 "vpath.c"
  tmp = lookup_file(*file);
# 395 "vpath.c"
  f = tmp;
  }
# 396 "vpath.c"
  if ((unsigned long )f == (unsigned long )((struct file *)0)) {
# 396 "vpath.c"
    tmp___0 = 1;
  } else
# 396 "vpath.c"
  if (! f->is_target) {
# 396 "vpath.c"
    tmp___0 = 1;
  } else {
# 396 "vpath.c"
    tmp___0 = 0;
  }
  {
# 396 "vpath.c"
  not_target = tmp___0;
# 399 "vpath.c"
  tmp___1 = strlen((char const *)*file);
# 399 "vpath.c"
  flen = (unsigned int )tmp___1;
# 405 "vpath.c"
  n = strrchr((char const *)*file, '/');
  }
# 414 "vpath.c"
  if ((unsigned long )n != (unsigned long )((char *)0)) {
# 414 "vpath.c"
    name_dplen = (unsigned int )(n - *file);
  } else {
# 414 "vpath.c"
    name_dplen = 0U;
  }
# 415 "vpath.c"
  if (name_dplen > 0U) {
# 415 "vpath.c"
    filename = n + 1;
  } else {
# 415 "vpath.c"
    filename = *file;
  }
# 416 "vpath.c"
  if (name_dplen > 0U) {
# 417 "vpath.c"
    flen -= name_dplen + 1U;
  }
  {
# 423 "vpath.c"
  tmp___2 = xmalloc(((((maxvpath + 1U) + name_dplen) + 1U) + flen) + 1U);
# 423 "vpath.c"
  name = tmp___2;
# 426 "vpath.c"
  i = 0U;
  }
  {
# 426 "vpath.c"
  while (1) {
    while_continue: ;
# 426 "vpath.c"
    if (! ((unsigned long )*(vpath + i) != (unsigned long )((char *)0))) {
# 426 "vpath.c"
      goto while_break;
    }
    {
# 428 "vpath.c"
    exists_in_cache = 0;
# 430 "vpath.c"
    n = name;
# 433 "vpath.c"
    tmp___3 = strlen((char const *)*(vpath + i));
# 433 "vpath.c"
    vlen = (unsigned int )tmp___3;
# 434 "vpath.c"
    memmove((void *)n, (void const *)*(vpath + i), (size_t )vlen);
# 435 "vpath.c"
    n += vlen;
    }
# 438 "vpath.c"
    if (name_dplen > 0U) {
      {
# 441 "vpath.c"
      tmp___4 = n;
# 441 "vpath.c"
      n ++;
# 441 "vpath.c"
      *tmp___4 = (char )'/';
# 443 "vpath.c"
      memmove((void *)n, (void const *)*file, (size_t )name_dplen);
# 444 "vpath.c"
      n += name_dplen;
      }
    }
# 454 "vpath.c"
    if ((unsigned long )n != (unsigned long )name) {
# 454 "vpath.c"
      if ((int )*(n + -1) != 47) {
        {
# 456 "vpath.c"
        *n = (char )'/';
# 457 "vpath.c"
        memmove((void *)(n + 1), (void const *)filename, (size_t )(flen + 1U));
        }
      } else {
        {
# 461 "vpath.c"
        memmove((void *)n, (void const *)filename, (size_t )(flen + 1U));
        }
      }
    } else {
      {
# 461 "vpath.c"
      memmove((void *)n, (void const *)filename, (size_t )(flen + 1U));
      }
    }
    {
# 477 "vpath.c"
    tmp___5 = lookup_file(name);
# 477 "vpath.c"
    f___0 = tmp___5;
    }
# 478 "vpath.c"
    if ((unsigned long )f___0 != (unsigned long )((struct file *)0)) {
# 479 "vpath.c"
      if (not_target) {
# 479 "vpath.c"
        tmp___6 = 1;
      } else
# 479 "vpath.c"
      if (f___0->is_target) {
# 479 "vpath.c"
        tmp___6 = 1;
      } else {
# 479 "vpath.c"
        tmp___6 = 0;
      }
# 479 "vpath.c"
      exists = tmp___6;
    }
# 482 "vpath.c"
    if (! exists) {
      {
# 492 "vpath.c"
      *n = (char )'\000';
# 497 "vpath.c"
      exists = dir_file_exists_p(name, filename);
# 497 "vpath.c"
      exists_in_cache = exists;
      }
    }
# 501 "vpath.c"
    if (exists) {
# 513 "vpath.c"
      *n = (char )'/';
# 516 "vpath.c"
      if (! exists_in_cache) {
# 516 "vpath.c"
        goto _L;
      } else {
        {
# 516 "vpath.c"
        tmp___9 = stat((char const * __restrict )name, (struct stat * __restrict )(& st));
        }
# 516 "vpath.c"
        if (tmp___9 == 0) {
          _L:
          {
# 522 "vpath.c"
          *file = savestring((char const *)name, (unsigned int )(((n + 1) - name) + (long )flen));
          }
# 524 "vpath.c"
          if ((unsigned long )mtime_ptr != (unsigned long )((uintmax_t *)0)) {
# 528 "vpath.c"
            if (exists_in_cache) {
# 528 "vpath.c"
              if (1000000000UL < 0xffffffffffffffffUL / (uintmax_t )(-1L - (-1L << (sizeof(time_t ) * 8UL - 1UL)))) {
# 528 "vpath.c"
                tmp___7 = (uintmax_t )1000000000;
              } else {
# 528 "vpath.c"
                tmp___7 = 0xffffffffffffffffUL / (uintmax_t )(-1L - (-1L << (sizeof(time_t ) * 8UL - 1UL)));
              }
# 528 "vpath.c"
              if (1000000000UL < 0xffffffffffffffffUL / (uintmax_t )(-1L - (-1L << (sizeof(time_t ) * 8UL - 1UL)))) {
# 528 "vpath.c"
                tmp___8 = (uintmax_t )1000000000;
              } else {
# 528 "vpath.c"
                tmp___8 = 0xffffffffffffffffUL / (uintmax_t )(-1L - (-1L << (sizeof(time_t ) * 8UL - 1UL)));
              }
# 528 "vpath.c"
              *mtime_ptr = (uintmax_t )st.st_mtim.tv_sec * tmp___7 + ((uintmax_t )st.st_mtim.tv_nsec * tmp___8) / 1000000000UL;
            } else {
# 528 "vpath.c"
              *mtime_ptr = (uintmax_t )0;
            }
          }
          {
# 532 "vpath.c"
          free((void *)name);
          }
# 533 "vpath.c"
          return (1);
        } else {
# 536 "vpath.c"
          exists = 0;
        }
      }
    }
# 426 "vpath.c"
    i ++;
  }
  while_break: ;
  }
  {
# 540 "vpath.c"
  free((void *)name);
  }
# 541 "vpath.c"
  return (0);
}
}
# 546 "vpath.c"
void print_vpath_data_base(void)
{
  register unsigned int nvpaths ;
  register struct vpath *v ;
  char *tmp ;
  register unsigned int i ;
  int tmp___0 ;
  char *tmp___1 ;
  char *tmp___2 ;
  char *tmp___3 ;
  register char **path ;
  register unsigned int i___0 ;
  char *tmp___4 ;
  int tmp___5 ;

  {
  {
# 552 "vpath.c"
  tmp = dcgettext((char const *)((void *)0), "\n# VPATH Search Paths\n", 5);
# 552 "vpath.c"
  puts((char const *)tmp);
# 554 "vpath.c"
  nvpaths = 0U;
# 555 "vpath.c"
  v = vpaths;
  }
  {
# 555 "vpath.c"
  while (1) {
    while_continue: ;
# 555 "vpath.c"
    if (! ((unsigned long )v != (unsigned long )((struct vpath *)0))) {
# 555 "vpath.c"
      goto while_break;
    }
    {
# 559 "vpath.c"
    nvpaths ++;
# 561 "vpath.c"
    printf((char const * __restrict )"vpath %s ", v->pattern);
# 563 "vpath.c"
    i = 0U;
    }
    {
# 563 "vpath.c"
    while (1) {
      while_continue___0: ;
# 563 "vpath.c"
      if (! ((unsigned long )*(v->searchpath + i) != (unsigned long )((char *)0))) {
# 563 "vpath.c"
        goto while_break___0;
      }
# 564 "vpath.c"
      if ((unsigned long )*(v->searchpath + (i + 1U)) == (unsigned long )((char *)0)) {
# 564 "vpath.c"
        tmp___0 = '\n';
      } else {
# 564 "vpath.c"
        tmp___0 = ':';
      }
      {
# 564 "vpath.c"
      printf((char const * __restrict )"%s%c", *(v->searchpath + i), tmp___0);
# 563 "vpath.c"
      i ++;
      }
    }
    while_break___0: ;
    }
# 555 "vpath.c"
    v = v->next;
  }
  while_break: ;
  }
# 568 "vpath.c"
  if ((unsigned long )vpaths == (unsigned long )((struct vpath *)0)) {
    {
# 569 "vpath.c"
    tmp___1 = dcgettext((char const *)((void *)0), "# No `vpath\' search paths.",
                        5);
# 569 "vpath.c"
    puts((char const *)tmp___1);
    }
  } else {
    {
# 571 "vpath.c"
    tmp___2 = dcgettext((char const *)((void *)0), "\n# %u `vpath\' search paths.\n",
                        5);
# 571 "vpath.c"
    printf((char const * __restrict )tmp___2, nvpaths);
    }
  }
# 573 "vpath.c"
  if ((unsigned long )general_vpath == (unsigned long )((struct vpath *)0)) {
    {
# 574 "vpath.c"
    tmp___3 = dcgettext((char const *)((void *)0), "\n# No general (`VPATH\' variable) search path.",
                        5);
# 574 "vpath.c"
    puts((char const *)tmp___3);
    }
  } else {
    {
# 577 "vpath.c"
    path = general_vpath->searchpath;
# 580 "vpath.c"
    tmp___4 = dcgettext((char const *)((void *)0), "\n# General (`VPATH\' variable) search path:\n# ",
                        5);
# 580 "vpath.c"
    fputs((char const * __restrict )tmp___4, (FILE * __restrict )stdout);
# 582 "vpath.c"
    i___0 = 0U;
    }
    {
# 582 "vpath.c"
    while (1) {
      while_continue___1: ;
# 582 "vpath.c"
      if (! ((unsigned long )*(path + i___0) != (unsigned long )((char *)0))) {
# 582 "vpath.c"
        goto while_break___1;
      }
# 583 "vpath.c"
      if ((unsigned long )*(path + (i___0 + 1U)) == (unsigned long )((char *)0)) {
# 583 "vpath.c"
        tmp___5 = '\n';
      } else {
# 583 "vpath.c"
        tmp___5 = ':';
      }
      {
# 583 "vpath.c"
      printf((char const * __restrict )"%s%c", *(path + i___0), tmp___5);
# 582 "vpath.c"
      i___0 ++;
      }
    }
    while_break___1: ;
    }
  }
# 586 "vpath.c"
  return;
}
}
# 1 "default.o"
#pragma merger("0","/tmp/cil-IL2nT0BF.i","-g,-O0")
# 39 "default.c"
static char default_suffixes[136] =
# 39 "default.c"
  { (char )'.', (char )'o', (char )'u', (char )'t',
        (char )' ', (char )'.', (char )'a', (char )' ',
        (char )'.', (char )'l', (char )'n', (char )' ',
        (char )'.', (char )'o', (char )' ', (char )'.',
        (char )'c', (char )' ', (char )'.', (char )'c',
        (char )'c', (char )' ', (char )'.', (char )'C',
        (char )' ', (char )'.', (char )'c', (char )'p',
        (char )'p', (char )' ', (char )'.', (char )'p',
        (char )' ', (char )'.', (char )'f', (char )' ',
        (char )'.', (char )'F', (char )' ', (char )'.',
        (char )'r', (char )' ', (char )'.', (char )'y',
        (char )' ', (char )'.', (char )'l', (char )' ',
        (char )'.', (char )'s', (char )' ', (char )'.',
        (char )'S', (char )' ', (char )'.', (char )'m',
        (char )'o', (char )'d', (char )' ', (char )'.',
        (char )'s', (char )'y', (char )'m', (char )' ',
        (char )'.', (char )'d', (char )'e', (char )'f',
        (char )' ', (char )'.', (char )'h', (char )' ',
        (char )'.', (char )'i', (char )'n', (char )'f',
        (char )'o', (char )' ', (char )'.', (char )'d',
        (char )'v', (char )'i', (char )' ', (char )'.',
        (char )'t', (char )'e', (char )'x', (char )' ',
        (char )'.', (char )'t', (char )'e', (char )'x',
        (char )'i', (char )'n', (char )'f', (char )'o',
        (char )' ', (char )'.', (char )'t', (char )'e',
        (char )'x', (char )'i', (char )' ', (char )'.',
        (char )'t', (char )'x', (char )'i', (char )'n',
        (char )'f', (char )'o', (char )' ', (char )'.',
        (char )'w', (char )' ', (char )'.', (char )'c',
        (char )'h', (char )' ', (char )'.', (char )'w',
        (char )'e', (char )'b', (char )' ', (char )'.',
        (char )'s', (char )'h', (char )' ', (char )'.',
        (char )'e', (char )'l', (char )'c', (char )' ',
        (char )'.', (char )'e', (char )'l', (char )'\000'};
# 50 "default.c"
static struct pspec default_pattern_rules[5] = { {(char *)"(%)", (char *)"%", (char *)"$(AR) $(ARFLAGS) $@ $<"},
        {(char *)"%.out", (char *)"%", (char *)"@rm -f $@ \n cp $< $@"},
        {(char *)"%.c", (char *)"%.w %.ch", (char *)"$(CTANGLE) $^ $@"},
        {(char *)"%.tex", (char *)"%.w %.ch", (char *)"$(CWEAVE) $^ $@"},
        {(char *)0, (char *)0, (char *)0}};
# 74 "default.c"
static struct pspec default_terminal_rules[6] = { {(char *)"%", (char *)"%,v", (char *)"$(CHECKOUT,v)"},
        {(char *)"%", (char *)"RCS/%,v", (char *)"$(CHECKOUT,v)"},
        {(char *)"%", (char *)"RCS/%", (char *)"$(CHECKOUT,v)"},
        {(char *)"%", (char *)"s.%", (char *)"$(GET) $(GFLAGS) $(SCCS_OUTPUT_OPTION) $<"},
        {(char *)"%",
      (char *)"SCCS/s.%", (char *)"$(GET) $(GFLAGS) $(SCCS_OUTPUT_OPTION) $<"},
        {(char *)0, (char *)0, (char *)0}};
# 107 "default.c"
static char *default_suffix_rules[92] =
# 107 "default.c"
  { (char *)".o", (char *)"$(LINK.o) $^ $(LOADLIBES) $(LDLIBS) -o $@", (char *)".s", (char *)"$(LINK.s) $^ $(LOADLIBES) $(LDLIBS) -o $@",
        (char *)".S", (char *)"$(LINK.S) $^ $(LOADLIBES) $(LDLIBS) -o $@", (char *)".c", (char *)"$(LINK.c) $^ $(LOADLIBES) $(LDLIBS) -o $@",
        (char *)".cc", (char *)"$(LINK.cc) $^ $(LOADLIBES) $(LDLIBS) -o $@", (char *)".C", (char *)"$(LINK.C) $^ $(LOADLIBES) $(LDLIBS) -o $@",
        (char *)".cpp", (char *)"$(LINK.cpp) $^ $(LOADLIBES) $(LDLIBS) -o $@", (char *)".f", (char *)"$(LINK.f) $^ $(LOADLIBES) $(LDLIBS) -o $@",
        (char *)".p", (char *)"$(LINK.p) $^ $(LOADLIBES) $(LDLIBS) -o $@", (char *)".F", (char *)"$(LINK.F) $^ $(LOADLIBES) $(LDLIBS) -o $@",
        (char *)".r", (char *)"$(LINK.r) $^ $(LOADLIBES) $(LDLIBS) -o $@", (char *)".mod", (char *)"$(COMPILE.mod) -o $@ -e $@ $^",
        (char *)".def.sym", (char *)"$(COMPILE.def) -o $@ $<", (char *)".sh", (char *)"cat $< >$@ \n chmod a+x $@",
        (char *)".s.o", (char *)"$(COMPILE.s) -o $@ $<", (char *)".S.o", (char *)"$(COMPILE.S) -o $@ $<",
        (char *)".c.o", (char *)"$(COMPILE.c) $(OUTPUT_OPTION) $<", (char *)".cc.o", (char *)"$(COMPILE.cc) $(OUTPUT_OPTION) $<",
        (char *)".C.o", (char *)"$(COMPILE.C) $(OUTPUT_OPTION) $<", (char *)".cpp.o", (char *)"$(COMPILE.cpp) $(OUTPUT_OPTION) $<",
        (char *)".f.o", (char *)"$(COMPILE.f) $(OUTPUT_OPTION) $<", (char *)".p.o", (char *)"$(COMPILE.p) $(OUTPUT_OPTION) $<",
        (char *)".F.o", (char *)"$(COMPILE.F) $(OUTPUT_OPTION) $<", (char *)".r.o", (char *)"$(COMPILE.r) $(OUTPUT_OPTION) $<",
        (char *)".mod.o", (char *)"$(COMPILE.mod) -o $@ $<", (char *)".c.ln", (char *)"$(LINT.c) -C$* $<",
        (char *)".y.ln", (char *)"$(YACC.y) $< \n $(LINT.c) -C$* y.tab.c \n $(RM) y.tab.c", (char *)".l.ln", (char *)"@$(RM) $*.c\n $(LEX.l) $< > $*.c\n$(LINT.c) -i $*.c -o $@\n $(RM) $*.c",
        (char *)".y.c", (char *)"$(YACC.y) $< \n mv -f y.tab.c $@", (char *)".l.c", (char *)"@$(RM) $@ \n $(LEX.l) $< > $@",
        (char *)".F.f", (char *)"$(PREPROCESS.F) $(OUTPUT_OPTION) $<", (char *)".r.f", (char *)"$(PREPROCESS.r) $(OUTPUT_OPTION) $<",
        (char *)".l.r", (char *)"$(LEX.l) $< > $@ \n mv -f lex.yy.r $@", (char *)".S.s", (char *)"$(PREPROCESS.S) $< > $@",
        (char *)".texinfo.info", (char *)"$(MAKEINFO) $(MAKEINFO_FLAGS) $< -o $@", (char *)".texi.info", (char *)"$(MAKEINFO) $(MAKEINFO_FLAGS) $< -o $@",
        (char *)".txinfo.info", (char *)"$(MAKEINFO) $(MAKEINFO_FLAGS) $< -o $@", (char *)".tex.dvi", (char *)"$(TEX) $<",
        (char *)".texinfo.dvi", (char *)"$(TEXI2DVI) $(TEXI2DVI_FLAGS) $<", (char *)".texi.dvi", (char *)"$(TEXI2DVI) $(TEXI2DVI_FLAGS) $<",
        (char *)".txinfo.dvi", (char *)"$(TEXI2DVI) $(TEXI2DVI_FLAGS) $<", (char *)".w.c", (char *)"$(CTANGLE) $< - $@",
        (char *)".web.p", (char *)"$(TANGLE) $<", (char *)".w.tex", (char *)"$(CWEAVE) $< - $@",
        (char *)".web.tex", (char *)"$(WEAVE) $<", (char *)0, (char *)0};
# 300 "default.c"
static char *default_variables[118] =
# 300 "default.c"
  { (char *)"AR", (char *)"ar", (char *)"ARFLAGS", (char *)"rv",
        (char *)"AS", (char *)"as", (char *)"CC", (char *)"cc",
        (char *)"CXX", (char *)"g++", (char *)"CHECKOUT,v", (char *)"+$(if $(wildcard $@),,$(CO) $(COFLAGS) $< $@)",
        (char *)"CO", (char *)"co", (char *)"COFLAGS", (char *)"",
        (char *)"CPP", (char *)"$(CC) -E", (char *)"FC", (char *)"f77",
        (char *)"F77", (char *)"$(FC)", (char *)"F77FLAGS", (char *)"$(FFLAGS)",
        (char *)"GET", (char *)"get", (char *)"LD", (char *)"ld",
        (char *)"LEX", (char *)"lex", (char *)"LINT", (char *)"lint",
        (char *)"M2C", (char *)"m2c", (char *)"PC", (char *)"pc",
        (char *)"YACC", (char *)"yacc", (char *)"MAKEINFO", (char *)"makeinfo",
        (char *)"TEX", (char *)"tex", (char *)"TEXI2DVI", (char *)"texi2dvi",
        (char *)"WEAVE", (char *)"weave", (char *)"CWEAVE", (char *)"cweave",
        (char *)"TANGLE", (char *)"tangle", (char *)"CTANGLE", (char *)"ctangle",
        (char *)"RM", (char *)"rm -f", (char *)"LINK.o", (char *)"$(CC) $(LDFLAGS) $(TARGET_ARCH)",
        (char *)"COMPILE.c", (char *)"$(CC) $(CFLAGS) $(CPPFLAGS) $(TARGET_ARCH) -c", (char *)"LINK.c", (char *)"$(CC) $(CFLAGS) $(CPPFLAGS) $(LDFLAGS) $(TARGET_ARCH)",
        (char *)"COMPILE.cc", (char *)"$(CXX) $(CXXFLAGS) $(CPPFLAGS) $(TARGET_ARCH) -c", (char *)"COMPILE.C", (char *)"$(COMPILE.cc)",
        (char *)"COMPILE.cpp", (char *)"$(COMPILE.cc)", (char *)"LINK.cc", (char *)"$(CXX) $(CXXFLAGS) $(CPPFLAGS) $(LDFLAGS) $(TARGET_ARCH)",
        (char *)"LINK.C", (char *)"$(LINK.cc)", (char *)"LINK.cpp", (char *)"$(LINK.cc)",
        (char *)"YACC.y", (char *)"$(YACC) $(YFLAGS)", (char *)"LEX.l", (char *)"$(LEX) $(LFLAGS) -t",
        (char *)"COMPILE.f", (char *)"$(FC) $(FFLAGS) $(TARGET_ARCH) -c", (char *)"LINK.f", (char *)"$(FC) $(FFLAGS) $(LDFLAGS) $(TARGET_ARCH)",
        (char *)"COMPILE.F", (char *)"$(FC) $(FFLAGS) $(CPPFLAGS) $(TARGET_ARCH) -c", (char *)"LINK.F", (char *)"$(FC) $(FFLAGS) $(CPPFLAGS) $(LDFLAGS) $(TARGET_ARCH)",
        (char *)"COMPILE.r", (char *)"$(FC) $(FFLAGS) $(RFLAGS) $(TARGET_ARCH) -c", (char *)"LINK.r", (char *)"$(FC) $(FFLAGS) $(RFLAGS) $(LDFLAGS) $(TARGET_ARCH)",
        (char *)"COMPILE.def", (char *)"$(M2C) $(M2FLAGS) $(DEFFLAGS) $(TARGET_ARCH)", (char *)"COMPILE.mod", (char *)"$(M2C) $(M2FLAGS) $(MODFLAGS) $(TARGET_ARCH)",
        (char *)"COMPILE.p", (char *)"$(PC) $(PFLAGS) $(CPPFLAGS) $(TARGET_ARCH) -c", (char *)"LINK.p", (char *)"$(PC) $(PFLAGS) $(CPPFLAGS) $(LDFLAGS) $(TARGET_ARCH)",
        (char *)"LINK.s", (char *)"$(CC) $(ASFLAGS) $(LDFLAGS) $(TARGET_MACH)", (char *)"COMPILE.s", (char *)"$(AS) $(ASFLAGS) $(TARGET_MACH)",
        (char *)"LINK.S", (char *)"$(CC) $(ASFLAGS) $(CPPFLAGS) $(LDFLAGS) $(TARGET_MACH)", (char *)"COMPILE.S", (char *)"$(CC) $(ASFLAGS) $(CPPFLAGS) $(TARGET_MACH) -c",
        (char *)"PREPROCESS.S", (char *)"$(CC) -E $(CPPFLAGS)", (char *)"PREPROCESS.F", (char *)"$(FC) $(FFLAGS) $(CPPFLAGS) $(TARGET_ARCH) -F",
        (char *)"PREPROCESS.r", (char *)"$(FC) $(FFLAGS) $(RFLAGS) $(TARGET_ARCH) -F", (char *)"LINT.c", (char *)"$(LINT) $(LINTFLAGS) $(CPPFLAGS) $(TARGET_ARCH)",
        (char *)"OUTPUT_OPTION", (char *)"-o $@", (char *)".LIBPATTERNS", (char *)"lib%.so lib%.a",
        (char *)0, (char *)0};
# 513 "default.c"
void set_default_suffixes(void)
{
  char *p ;
  struct nameseq *tmp ;
  struct nameseq *tmp___0 ;

  {
  {
# 516 "default.c"
  suffix_file = enter_file((char *)".SUFFIXES");
  }
# 518 "default.c"
  if (no_builtin_rules_flag) {
    {
# 519 "default.c"
    define_variable_in_set((char *)"SUFFIXES", 8U, (char *)"", (enum variable_origin )0,
                           0, current_variable_set_list->set, (struct floc const *)((struct floc *)0));
    }
  } else {
    {
# 522 "default.c"
    p = default_suffixes;
# 523 "default.c"
    tmp = parse_file_seq(& p, '\000', (unsigned int )sizeof(struct dep ), 1);
# 523 "default.c"
    tmp___0 = multi_glob(tmp, (unsigned int )sizeof(struct dep ));
# 523 "default.c"
    suffix_file->deps = (struct dep *)tmp___0;
# 526 "default.c"
    define_variable_in_set((char *)"SUFFIXES", 8U, default_suffixes, (enum variable_origin )0,
                           0, current_variable_set_list->set, (struct floc const *)((struct floc *)0));
    }
  }
# 528 "default.c"
  return;
}
}
# 535 "default.c"
void install_default_suffix_rules(void)
{
  register char **s ;
  register struct file *f ;
  struct file *tmp ;
  char *tmp___0 ;

  {
# 540 "default.c"
  if (no_builtin_rules_flag) {
# 541 "default.c"
    return;
  }
# 543 "default.c"
  s = default_suffix_rules;
  {
# 543 "default.c"
  while (1) {
    while_continue: ;
# 543 "default.c"
    if (! ((unsigned long )*s != (unsigned long )((char *)0))) {
# 543 "default.c"
      goto while_break;
    }
    {
# 545 "default.c"
    tmp = enter_file(*(s + 0));
# 545 "default.c"
    f = tmp;
    }
# 547 "default.c"
    if ((unsigned long )f->cmds == (unsigned long )((struct commands *)0)) {
      {
# 549 "default.c"
      tmp___0 = xmalloc((unsigned int )sizeof(struct commands ));
# 549 "default.c"
      f->cmds = (struct commands *)tmp___0;
# 550 "default.c"
      (f->cmds)->fileinfo.filenm = (char *)0;
# 551 "default.c"
      (f->cmds)->commands = *(s + 1);
# 552 "default.c"
      (f->cmds)->command_lines = (char **)0;
      }
    }
# 543 "default.c"
    s += 2;
  }
  while_break: ;
  }
# 555 "default.c"
  return;
}
}
# 560 "default.c"
void install_default_implicit_rules(void)
{
  register struct pspec *p ;

  {
# 565 "default.c"
  if (no_builtin_rules_flag) {
# 566 "default.c"
    return;
  }
# 568 "default.c"
  p = default_pattern_rules;
  {
# 568 "default.c"
  while (1) {
    while_continue: ;
# 568 "default.c"
    if (! ((unsigned long )p->target != (unsigned long )((char *)0))) {
# 568 "default.c"
      goto while_break;
    }
    {
# 569 "default.c"
    install_pattern_rule(p, 0);
# 568 "default.c"
    p ++;
    }
  }
  while_break: ;
  }
# 571 "default.c"
  p = default_terminal_rules;
  {
# 571 "default.c"
  while (1) {
    while_continue___0: ;
# 571 "default.c"
    if (! ((unsigned long )p->target != (unsigned long )((char *)0))) {
# 571 "default.c"
      goto while_break___0;
    }
    {
# 572 "default.c"
    install_pattern_rule(p, 1);
# 571 "default.c"
    p ++;
    }
  }
  while_break___0: ;
  }
# 573 "default.c"
  return;
}
}
# 575 "default.c"
void define_default_variables(void)
{
  register char **s ;
  size_t tmp ;

  {
# 580 "default.c"
  if (no_builtin_variables_flag) {
# 581 "default.c"
    return;
  }
# 583 "default.c"
  s = default_variables;
  {
# 583 "default.c"
  while (1) {
    while_continue: ;
# 583 "default.c"
    if (! ((unsigned long )*s != (unsigned long )((char *)0))) {
# 583 "default.c"
      goto while_break;
    }
    {
# 584 "default.c"
    tmp = strlen((char const *)*(s + 0));
# 584 "default.c"
    define_variable_in_set(*(s + 0), (unsigned int )tmp, *(s + 1), (enum variable_origin )0,
                           1, current_variable_set_list->set, (struct floc const *)((struct floc *)0));
# 583 "default.c"
    s += 2;
    }
  }
  while_break: ;
  }
# 585 "default.c"
  return;
}
}
# 1 "remote-stub.o"
#pragma merger("0","/tmp/cil-lUReg5Kq.i","-g,-O0")
# 26 "remote-stub.c"
char *remote_description = (char *)0;
# 30 "remote-stub.c"
void remote_setup(void)
{


  {
# 33 "remote-stub.c"
  return;
}
}
# 37 "remote-stub.c"
void remote_cleanup(void)
{


  {
# 40 "remote-stub.c"
  return;
}
}
# 44 "remote-stub.c"
int start_remote_job_p(int first_p )
{


  {
# 48 "remote-stub.c"
  return (0);
}
}
# 58 "remote-stub.c"
int start_remote_job(char **argv , char **envp , int stdin_fd , int *is_remote , int *id_ptr ,
                     int *used_stdin )
{


  {
# 66 "remote-stub.c"
  return (-1);
}
}
# 75 "remote-stub.c"
int remote_status(int *exit_code_ptr , int *signal_ptr , int *coredump_ptr , int block )
{
  int *tmp ;

  {
  {
# 80 "remote-stub.c"
  tmp = __errno_location();
# 80 "remote-stub.c"
  *tmp = 10;
  }
# 81 "remote-stub.c"
  return (-1);
}
}
# 87 "remote-stub.c"
void block_remote_children(void)
{


  {
# 90 "remote-stub.c"
  return;
}
}
# 96 "remote-stub.c"
void unblock_remote_children(void)
{


  {
# 99 "remote-stub.c"
  return;
}
}
# 103 "remote-stub.c"
int remote_kill(int id , int sig )
{


  {
# 108 "remote-stub.c"
  return (-1);
}
}
# 1 "version.o"
#pragma merger("0","/tmp/cil-1mks5shs.i","-g,-O0")
# 10 "version.c"
char *version_string = (char *)"3.79";
# 11 "version.c"
char *make_host = (char *)"";
# 1 "getopt1.o"
#pragma merger("0","/tmp/cil-wnI9fUGf.i","-g,-O0")
# 1 "gettext.o"
#pragma merger("0","/tmp/cil-cDTpBoNV.i","-g,-O0")
# 451 "/usr/include/string.h"
extern __attribute__((__nothrow__)) char *( __attribute__((__nonnull__(1,2), __leaf__)) stpcpy)(char * __restrict __dest ,
                                                                                                 char const * __restrict __src ) ;
# 122 "gettext.c"
static char const *_nl_normalize_codeset(unsigned char const *codeset , size_t name_len ) ;
# 125 "gettext.c"
static struct loaded_l10nfile *_nl_make_l10nflist(struct loaded_l10nfile **l10nfile_list ,
                                                  char const *dirlist , size_t dirlist_len ,
                                                  int mask , char const *language ,
                                                  char const *territory , char const *codeset ,
                                                  char const *normalized_codeset ,
                                                  char const *modifier , char const *special ,
                                                  char const *sponsor , char const *revision ,
                                                  char const *filename , int do_allocate ) ;
# 135 "gettext.c"
static char const *_nl_expand_alias(char const *name ) ;
# 137 "gettext.c"
static int _nl_explode_name(char *name , char const **language , char const **modifier ,
                            char const **territory , char const **codeset , char const **normalized_codeset ,
                            char const **special , char const **sponsor , char const **revision ) ;
# 176 "gettext.c"
static size_t argz_count__(char const *argz , size_t len ) ;
# 178 "gettext.c"
static size_t argz_count__(char const *argz , size_t len )
{
  size_t count ;
  size_t part_len ;
  size_t tmp ;

  {
# 183 "gettext.c"
  count = (size_t )0;
  {
# 184 "gettext.c"
  while (1) {
    while_continue: ;
# 184 "gettext.c"
    if (! (len > 0UL)) {
# 184 "gettext.c"
      goto while_break;
    }
    {
# 186 "gettext.c"
    tmp = strlen(argz);
# 186 "gettext.c"
    part_len = tmp;
# 187 "gettext.c"
    argz += part_len + 1UL;
# 188 "gettext.c"
    len -= part_len + 1UL;
# 189 "gettext.c"
    count ++;
    }
  }
  while_break: ;
  }
# 191 "gettext.c"
  return (count);
}
}
# 200 "gettext.c"
static void argz_stringify__(char *argz , size_t len , int sep ) ;
# 202 "gettext.c"
static void argz_stringify__(char *argz , size_t len , int sep )
{
  size_t part_len ;
  size_t tmp ;
  char *tmp___0 ;

  {
  {
# 208 "gettext.c"
  while (1) {
    while_continue: ;
# 208 "gettext.c"
    if (! (len > 0UL)) {
# 208 "gettext.c"
      goto while_break;
    }
    {
# 210 "gettext.c"
    tmp = strlen((char const *)argz);
# 210 "gettext.c"
    part_len = tmp;
# 211 "gettext.c"
    argz += part_len;
# 212 "gettext.c"
    len -= part_len + 1UL;
    }
# 213 "gettext.c"
    if (len > 0UL) {
# 214 "gettext.c"
      tmp___0 = argz;
# 214 "gettext.c"
      argz ++;
# 214 "gettext.c"
      *tmp___0 = (char )sep;
    }
  }
  while_break: ;
  }
# 216 "gettext.c"
  return;
}
}
# 222 "gettext.c"
static char *argz_next__(char *argz , size_t argz_len , char const *entry ) ;
# 225 "gettext.c"
static char *argz_next__(char *argz , size_t argz_len , char const *entry )
{
  char *tmp ;
  char *tmp___0 ;

  {
# 231 "gettext.c"
  if (entry) {
# 233 "gettext.c"
    if ((unsigned long )entry < (unsigned long )(argz + argz_len)) {
      {
# 234 "gettext.c"
      tmp = strchr(entry, '\000');
# 234 "gettext.c"
      entry = (char const *)(tmp + 1);
      }
    }
# 236 "gettext.c"
    if ((unsigned long )entry >= (unsigned long )(argz + argz_len)) {
# 236 "gettext.c"
      tmp___0 = (char *)((void *)0);
    } else {
# 236 "gettext.c"
      tmp___0 = (char *)entry;
    }
# 236 "gettext.c"
    return (tmp___0);
  } else
# 239 "gettext.c"
  if (argz_len > 0UL) {
# 240 "gettext.c"
    return (argz);
  } else {
# 242 "gettext.c"
    return ((char *)0);
  }
}
}
# 249 "gettext.c"
__inline static int pop(int x ) ;
# 251 "gettext.c"
__inline static int pop(int x )
{


  {
# 256 "gettext.c"
  x = ((x & -21846) >> 1) + (x & 21845);
# 257 "gettext.c"
  x = ((x & -13108) >> 2) + (x & 13107);
# 258 "gettext.c"
  x = ((x >> 4) + x) & 3855;
# 259 "gettext.c"
  x = ((x >> 8) + x) & 255;
# 261 "gettext.c"
  return (x);
}
}
# 264 "gettext.c"
static struct loaded_l10nfile *_nl_make_l10nflist(struct loaded_l10nfile **l10nfile_list ,
                                                  char const *dirlist , size_t dirlist_len ,
                                                  int mask , char const *language ,
                                                  char const *territory , char const *codeset ,
                                                  char const *normalized_codeset ,
                                                  char const *modifier , char const *special ,
                                                  char const *sponsor , char const *revision ,
                                                  char const *filename , int do_allocate )
{
  char *abs_filename ;
  struct loaded_l10nfile *last ;
  struct loaded_l10nfile *retval ;
  char *cp ;
  size_t entries ;
  int cnt ;
  size_t tmp ;
  size_t tmp___0 ;
  size_t tmp___1 ;
  size_t tmp___2 ;
  size_t tmp___3 ;
  size_t tmp___4 ;
  size_t tmp___5 ;
  size_t tmp___6 ;
  size_t tmp___7 ;
  size_t tmp___8 ;
  size_t tmp___9 ;
  size_t tmp___10 ;
  size_t tmp___11 ;
  size_t tmp___12 ;
  size_t tmp___13 ;
  size_t tmp___14 ;
  size_t tmp___15 ;
  int tmp___16 ;
  char *tmp___17 ;
  char *tmp___18 ;
  char *tmp___19 ;
  char *tmp___20 ;
  char *tmp___21 ;
  char *tmp___22 ;
  char *tmp___23 ;
  char *tmp___24 ;
  char *tmp___25 ;
  int compare ;
  int tmp___26 ;
  size_t tmp___27 ;
  int tmp___28 ;
  int tmp___29 ;
  size_t tmp___30 ;
  int tmp___31 ;
  size_t tmp___33 ;
  char *dir ;
  size_t tmp___34 ;
  size_t tmp___35 ;
  void *tmp___36 ;
  void *tmp___37 ;

  {
  {
# 284 "gettext.c"
  last = (struct loaded_l10nfile *)((void *)0);
# 291 "gettext.c"
  tmp = strlen(language);
  }
# 291 "gettext.c"
  if ((mask & 32) != 0) {
    {
# 291 "gettext.c"
    tmp___0 = strlen(territory);
# 291 "gettext.c"
    tmp___1 = tmp___0 + 1UL;
    }
  } else {
# 291 "gettext.c"
    tmp___1 = (size_t )0;
  }
# 291 "gettext.c"
  if ((mask & 16) != 0) {
    {
# 291 "gettext.c"
    tmp___2 = strlen(codeset);
# 291 "gettext.c"
    tmp___3 = tmp___2 + 1UL;
    }
  } else {
# 291 "gettext.c"
    tmp___3 = (size_t )0;
  }
# 291 "gettext.c"
  if ((mask & 8) != 0) {
    {
# 291 "gettext.c"
    tmp___4 = strlen(normalized_codeset);
# 291 "gettext.c"
    tmp___5 = tmp___4 + 1UL;
    }
  } else {
# 291 "gettext.c"
    tmp___5 = (size_t )0;
  }
# 291 "gettext.c"
  if ((mask & 128) != 0) {
    {
# 291 "gettext.c"
    tmp___6 = strlen(modifier);
# 291 "gettext.c"
    tmp___7 = tmp___6 + 1UL;
    }
  } else
# 291 "gettext.c"
  if ((mask & 64) != 0) {
    {
# 291 "gettext.c"
    tmp___6 = strlen(modifier);
# 291 "gettext.c"
    tmp___7 = tmp___6 + 1UL;
    }
  } else {
# 291 "gettext.c"
    tmp___7 = (size_t )0;
  }
# 291 "gettext.c"
  if ((mask & 4) != 0) {
    {
# 291 "gettext.c"
    tmp___8 = strlen(special);
# 291 "gettext.c"
    tmp___9 = tmp___8 + 1UL;
    }
  } else {
# 291 "gettext.c"
    tmp___9 = (size_t )0;
  }
# 291 "gettext.c"
  if ((mask & 2) != 0) {
# 291 "gettext.c"
    goto _L;
  } else
# 291 "gettext.c"
  if ((mask & 1) != 0) {
    _L:
# 291 "gettext.c"
    if ((mask & 2) != 0) {
      {
# 291 "gettext.c"
      tmp___10 = strlen(sponsor);
# 291 "gettext.c"
      tmp___11 = tmp___10 + 1UL;
      }
    } else {
# 291 "gettext.c"
      tmp___11 = (size_t )0;
    }
# 291 "gettext.c"
    if ((mask & 1) != 0) {
      {
# 291 "gettext.c"
      tmp___12 = strlen(revision);
# 291 "gettext.c"
      tmp___13 = tmp___12 + 1UL;
      }
    } else {
# 291 "gettext.c"
      tmp___13 = (size_t )0;
    }
# 291 "gettext.c"
    tmp___14 = (1UL + tmp___11) + tmp___13;
  } else {
# 291 "gettext.c"
    tmp___14 = (size_t )0;
  }
  {
# 291 "gettext.c"
  tmp___15 = strlen(filename);
# 291 "gettext.c"
  tmp___36 = malloc((((((((((dirlist_len + tmp) + tmp___1) + tmp___3) + tmp___5) + tmp___7) + tmp___9) + tmp___14) + 1UL) + tmp___15) + 1UL);
# 291 "gettext.c"
  tmp___16 = (int )tmp___36;
# 291 "gettext.c"
  abs_filename = (char *)tmp___16;
  }
# 312 "gettext.c"
  if ((unsigned long )abs_filename == (unsigned long )((void *)0)) {
# 313 "gettext.c"
    return ((struct loaded_l10nfile *)((void *)0));
  }
  {
# 315 "gettext.c"
  retval = (struct loaded_l10nfile *)((void *)0);
# 316 "gettext.c"
  last = (struct loaded_l10nfile *)((void *)0);
# 319 "gettext.c"
  memcpy((void * __restrict )abs_filename, (void const * __restrict )dirlist,
         dirlist_len);
# 320 "gettext.c"
  argz_stringify__(abs_filename, dirlist_len, ':');
# 321 "gettext.c"
  cp = abs_filename + (dirlist_len - 1UL);
# 322 "gettext.c"
  tmp___17 = cp;
# 322 "gettext.c"
  cp ++;
# 322 "gettext.c"
  *tmp___17 = (char )'/';
# 323 "gettext.c"
  cp = stpcpy((char * __restrict )cp, (char const * __restrict )language);
  }
# 325 "gettext.c"
  if ((mask & 32) != 0) {
    {
# 327 "gettext.c"
    tmp___18 = cp;
# 327 "gettext.c"
    cp ++;
# 327 "gettext.c"
    *tmp___18 = (char )'_';
# 328 "gettext.c"
    cp = stpcpy((char * __restrict )cp, (char const * __restrict )territory);
    }
  }
# 330 "gettext.c"
  if ((mask & 16) != 0) {
    {
# 332 "gettext.c"
    tmp___19 = cp;
# 332 "gettext.c"
    cp ++;
# 332 "gettext.c"
    *tmp___19 = (char )'.';
# 333 "gettext.c"
    cp = stpcpy((char * __restrict )cp, (char const * __restrict )codeset);
    }
  }
# 335 "gettext.c"
  if ((mask & 8) != 0) {
    {
# 337 "gettext.c"
    tmp___20 = cp;
# 337 "gettext.c"
    cp ++;
# 337 "gettext.c"
    *tmp___20 = (char )'.';
# 338 "gettext.c"
    cp = stpcpy((char * __restrict )cp, (char const * __restrict )normalized_codeset);
    }
  }
# 340 "gettext.c"
  if ((mask & 192) != 0) {
# 344 "gettext.c"
    tmp___21 = cp;
# 344 "gettext.c"
    cp ++;
# 344 "gettext.c"
    if ((mask & 64) != 0) {
# 344 "gettext.c"
      *tmp___21 = (char )'+';
    } else {
# 344 "gettext.c"
      *tmp___21 = (char )'@';
    }
    {
# 345 "gettext.c"
    cp = stpcpy((char * __restrict )cp, (char const * __restrict )modifier);
    }
  }
# 347 "gettext.c"
  if ((mask & 4) != 0) {
    {
# 349 "gettext.c"
    tmp___22 = cp;
# 349 "gettext.c"
    cp ++;
# 349 "gettext.c"
    *tmp___22 = (char )'+';
# 350 "gettext.c"
    cp = stpcpy((char * __restrict )cp, (char const * __restrict )special);
    }
  }
# 352 "gettext.c"
  if ((mask & 3) != 0) {
# 354 "gettext.c"
    tmp___23 = cp;
# 354 "gettext.c"
    cp ++;
# 354 "gettext.c"
    *tmp___23 = (char )',';
# 355 "gettext.c"
    if ((mask & 2) != 0) {
      {
# 356 "gettext.c"
      cp = stpcpy((char * __restrict )cp, (char const * __restrict )sponsor);
      }
    }
# 357 "gettext.c"
    if ((mask & 1) != 0) {
      {
# 359 "gettext.c"
      tmp___24 = cp;
# 359 "gettext.c"
      cp ++;
# 359 "gettext.c"
      *tmp___24 = (char )'_';
# 360 "gettext.c"
      cp = stpcpy((char * __restrict )cp, (char const * __restrict )revision);
      }
    }
  }
  {
# 364 "gettext.c"
  tmp___25 = cp;
# 364 "gettext.c"
  cp ++;
# 364 "gettext.c"
  *tmp___25 = (char )'/';
# 365 "gettext.c"
  stpcpy((char * __restrict )cp, (char const * __restrict )filename);
# 369 "gettext.c"
  last = (struct loaded_l10nfile *)((void *)0);
# 370 "gettext.c"
  retval = *l10nfile_list;
  }
  {
# 370 "gettext.c"
  while (1) {
    while_continue: ;
# 370 "gettext.c"
    if (! ((unsigned long )retval != (unsigned long )((void *)0))) {
# 370 "gettext.c"
      goto while_break;
    }
# 371 "gettext.c"
    if ((unsigned long )retval->filename != (unsigned long )((void *)0)) {
      {
# 373 "gettext.c"
      tmp___26 = strcmp(retval->filename, (char const *)abs_filename);
# 373 "gettext.c"
      compare = tmp___26;
      }
# 374 "gettext.c"
      if (compare == 0) {
# 376 "gettext.c"
        goto while_break;
      }
# 377 "gettext.c"
      if (compare < 0) {
# 380 "gettext.c"
        retval = (struct loaded_l10nfile *)((void *)0);
# 381 "gettext.c"
        goto while_break;
      }
# 384 "gettext.c"
      last = retval;
    }
# 370 "gettext.c"
    retval = retval->next;
  }
  while_break: ;
  }
# 387 "gettext.c"
  if ((unsigned long )retval != (unsigned long )((void *)0)) {
    {
# 389 "gettext.c"
    free((void *)abs_filename);
    }
# 390 "gettext.c"
    return (retval);
  } else
# 387 "gettext.c"
  if (do_allocate == 0) {
    {
# 389 "gettext.c"
    free((void *)abs_filename);
    }
# 390 "gettext.c"
    return (retval);
  }
  {
# 393 "gettext.c"
  tmp___27 = argz_count__(dirlist, dirlist_len);
# 393 "gettext.c"
  tmp___28 = pop(mask);
# 393 "gettext.c"
  tmp___37 = malloc(sizeof(*retval) + (tmp___27 * (size_t )(1 << tmp___28)) * sizeof(struct loaded_l10nfile *));
# 393 "gettext.c"
  tmp___29 = (int )tmp___37;
# 393 "gettext.c"
  retval = (struct loaded_l10nfile *)tmp___29;
  }
# 397 "gettext.c"
  if ((unsigned long )retval == (unsigned long )((void *)0)) {
# 398 "gettext.c"
    return ((struct loaded_l10nfile *)((void *)0));
  }
  {
# 400 "gettext.c"
  retval->filename = (char const *)abs_filename;
# 401 "gettext.c"
  tmp___30 = argz_count__(dirlist, dirlist_len);
  }
# 401 "gettext.c"
  if (tmp___30 != 1UL) {
# 401 "gettext.c"
    tmp___31 = 1;
  } else
# 401 "gettext.c"
  if ((mask & 16) != 0) {
# 401 "gettext.c"
    if ((mask & 8) != 0) {
# 401 "gettext.c"
      tmp___31 = 1;
    } else {
# 401 "gettext.c"
      tmp___31 = 0;
    }
  } else {
# 401 "gettext.c"
    tmp___31 = 0;
  }
# 401 "gettext.c"
  retval->decided = tmp___31;
# 404 "gettext.c"
  retval->data = (void const *)((void *)0);
# 406 "gettext.c"
  if ((unsigned long )last == (unsigned long )((void *)0)) {
# 408 "gettext.c"
    retval->next = *l10nfile_list;
# 409 "gettext.c"
    *l10nfile_list = retval;
  } else {
# 413 "gettext.c"
    retval->next = last->next;
# 414 "gettext.c"
    last->next = retval;
  }
  {
# 417 "gettext.c"
  entries = (size_t )0;
# 421 "gettext.c"
  tmp___33 = argz_count__(dirlist, dirlist_len);
  }
# 421 "gettext.c"
  if (tmp___33 == 1UL) {
# 421 "gettext.c"
    cnt = mask - 1;
  } else {
# 421 "gettext.c"
    cnt = mask;
  }
  {
# 422 "gettext.c"
  while (1) {
    while_continue___0: ;
# 422 "gettext.c"
    if (! (cnt >= 0)) {
# 422 "gettext.c"
      goto while_break___0;
    }
# 423 "gettext.c"
    if ((cnt & ~ mask) == 0) {
# 423 "gettext.c"
      if ((cnt & 71) == 0) {
# 423 "gettext.c"
        goto _L___1;
      } else
# 423 "gettext.c"
      if ((cnt & 152) == 0) {
        _L___1:
# 423 "gettext.c"
        if ((cnt & 16) == 0) {
# 423 "gettext.c"
          goto _L___0;
        } else
# 423 "gettext.c"
        if ((cnt & 8) == 0) {
          _L___0:
# 428 "gettext.c"
          dir = (char *)((void *)0);
          {
# 430 "gettext.c"
          while (1) {
            while_continue___1: ;
            {
# 430 "gettext.c"
            dir = argz_next__((char *)dirlist, dirlist_len, (char const *)dir);
            }
# 430 "gettext.c"
            if (! ((unsigned long )dir != (unsigned long )((void *)0))) {
# 430 "gettext.c"
              goto while_break___1;
            }
            {
# 432 "gettext.c"
            tmp___34 = entries;
# 432 "gettext.c"
            entries ++;
# 432 "gettext.c"
            tmp___35 = strlen((char const *)dir);
# 432 "gettext.c"
            retval->successor[tmp___34] = _nl_make_l10nflist(l10nfile_list, (char const *)dir,
                                                             tmp___35 + 1UL, cnt,
                                                             language, territory,
                                                             codeset, normalized_codeset,
                                                             modifier, special, sponsor,
                                                             revision, filename, 1);
            }
          }
          while_break___1: ;
          }
        }
      }
    }
# 422 "gettext.c"
    cnt --;
  }
  while_break___0: ;
  }
# 438 "gettext.c"
  retval->successor[entries] = (struct loaded_l10nfile *)((void *)0);
# 440 "gettext.c"
  return (retval);
}
}
# 446 "gettext.c"
static char const *_nl_normalize_codeset(unsigned char const *codeset , size_t name_len )
{
  int len ;
  int only_digit ;
  char *retval ;
  char *wp ;
  size_t cnt ;
  unsigned short const **tmp ;
  unsigned short const **tmp___0 ;
  int tmp___1 ;
  int tmp___2 ;
  char *tmp___3 ;
  int tmp___4 ;
  char *tmp___5 ;
  unsigned short const **tmp___6 ;
  unsigned short const **tmp___7 ;
  void *tmp___8 ;

  {
# 451 "gettext.c"
  len = 0;
# 452 "gettext.c"
  only_digit = 1;
# 457 "gettext.c"
  cnt = (size_t )0;
  {
# 457 "gettext.c"
  while (1) {
    while_continue: ;
# 457 "gettext.c"
    if (! (cnt < name_len)) {
# 457 "gettext.c"
      goto while_break;
    }
    {
# 458 "gettext.c"
    tmp___0 = __ctype_b_loc();
    }
# 458 "gettext.c"
    if ((int const )*(*tmp___0 + (int )*(codeset + cnt)) & 8) {
      {
# 460 "gettext.c"
      len ++;
# 462 "gettext.c"
      tmp = __ctype_b_loc();
      }
# 462 "gettext.c"
      if ((int const )*(*tmp + (int )*(codeset + cnt)) & 1024) {
# 463 "gettext.c"
        only_digit = 0;
      }
    }
# 457 "gettext.c"
    cnt ++;
  }
  while_break: ;
  }
# 466 "gettext.c"
  if (only_digit) {
# 466 "gettext.c"
    tmp___1 = 3;
  } else {
# 466 "gettext.c"
    tmp___1 = 0;
  }
  {
# 466 "gettext.c"
  tmp___8 = malloc((size_t )((tmp___1 + len) + 1));
# 466 "gettext.c"
  tmp___2 = (int )tmp___8;
# 466 "gettext.c"
  retval = (char *)tmp___2;
  }
# 468 "gettext.c"
  if ((unsigned long )retval != (unsigned long )((void *)0)) {
# 470 "gettext.c"
    if (only_digit) {
      {
# 471 "gettext.c"
      wp = stpcpy((char * __restrict )retval, (char const * __restrict )"iso");
      }
    } else {
# 473 "gettext.c"
      wp = retval;
    }
# 475 "gettext.c"
    cnt = (size_t )0;
    {
# 475 "gettext.c"
    while (1) {
      while_continue___0: ;
# 475 "gettext.c"
      if (! (cnt < name_len)) {
# 475 "gettext.c"
        goto while_break___0;
      }
      {
# 476 "gettext.c"
      tmp___7 = __ctype_b_loc();
      }
# 476 "gettext.c"
      if ((int const )*(*tmp___7 + (int )*(codeset + cnt)) & 1024) {
        {
# 477 "gettext.c"
        tmp___3 = wp;
# 477 "gettext.c"
        wp ++;
# 477 "gettext.c"
        tmp___4 = tolower((int )*(codeset + cnt));
# 477 "gettext.c"
        *tmp___3 = (char )tmp___4;
        }
      } else {
        {
# 478 "gettext.c"
        tmp___6 = __ctype_b_loc();
        }
# 478 "gettext.c"
        if ((int const )*(*tmp___6 + (int )*(codeset + cnt)) & 2048) {
# 479 "gettext.c"
          tmp___5 = wp;
# 479 "gettext.c"
          wp ++;
# 479 "gettext.c"
          *tmp___5 = (char )*(codeset + cnt);
        }
      }
# 475 "gettext.c"
      cnt ++;
    }
    while_break___0: ;
    }
# 481 "gettext.c"
    *wp = (char )'\000';
  }
# 484 "gettext.c"
  return ((char const *)retval);
}
}
# 501 "gettext.c"
static int _nl_explode_name(char *name , char const **language , char const **modifier ,
                            char const **territory , char const **codeset , char const **normalized_codeset ,
                            char const **special , char const **sponsor , char const **revision )
{
  enum __anonenum_syntax_17 syntax ;
  char *cp ;
  int mask ;
  int tmp ;

  {
# 518 "gettext.c"
  *modifier = (char const *)((void *)0);
# 519 "gettext.c"
  *territory = (char const *)((void *)0);
# 520 "gettext.c"
  *codeset = (char const *)((void *)0);
# 521 "gettext.c"
  *normalized_codeset = (char const *)((void *)0);
# 522 "gettext.c"
  *special = (char const *)((void *)0);
# 523 "gettext.c"
  *sponsor = (char const *)((void *)0);
# 524 "gettext.c"
  *revision = (char const *)((void *)0);
# 529 "gettext.c"
  mask = 0;
# 530 "gettext.c"
  syntax = (enum __anonenum_syntax_17 )0;
# 531 "gettext.c"
  cp = name;
# 531 "gettext.c"
  *language = (char const *)cp;
  {
# 532 "gettext.c"
  while (1) {
    while_continue: ;
# 532 "gettext.c"
    if ((int )*(cp + 0) != 0) {
# 532 "gettext.c"
      if ((int )*(cp + 0) != 95) {
# 532 "gettext.c"
        if ((int )*(cp + 0) != 64) {
# 532 "gettext.c"
          if ((int )*(cp + 0) != 43) {
# 532 "gettext.c"
            if (! ((int )*(cp + 0) != 44)) {
# 532 "gettext.c"
              goto while_break;
            }
          } else {
# 532 "gettext.c"
            goto while_break;
          }
        } else {
# 532 "gettext.c"
          goto while_break;
        }
      } else {
# 532 "gettext.c"
        goto while_break;
      }
    } else {
# 532 "gettext.c"
      goto while_break;
    }
# 534 "gettext.c"
    cp ++;
  }
  while_break: ;
  }
# 536 "gettext.c"
  if ((unsigned long )*language == (unsigned long )cp) {
    {
# 539 "gettext.c"
    cp = strchr(*language, '\000');
    }
  } else
# 540 "gettext.c"
  if ((int )*(cp + 0) == 95) {
# 543 "gettext.c"
    *(cp + 0) = (char )'\000';
# 544 "gettext.c"
    cp ++;
# 544 "gettext.c"
    *territory = (char const *)cp;
    {
# 546 "gettext.c"
    while (1) {
      while_continue___0: ;
# 546 "gettext.c"
      if ((int )*(cp + 0) != 0) {
# 546 "gettext.c"
        if ((int )*(cp + 0) != 46) {
# 546 "gettext.c"
          if ((int )*(cp + 0) != 64) {
# 546 "gettext.c"
            if ((int )*(cp + 0) != 43) {
# 546 "gettext.c"
              if ((int )*(cp + 0) != 44) {
# 546 "gettext.c"
                if (! ((int )*(cp + 0) != 95)) {
# 546 "gettext.c"
                  goto while_break___0;
                }
              } else {
# 546 "gettext.c"
                goto while_break___0;
              }
            } else {
# 546 "gettext.c"
              goto while_break___0;
            }
          } else {
# 546 "gettext.c"
            goto while_break___0;
          }
        } else {
# 546 "gettext.c"
          goto while_break___0;
        }
      } else {
# 546 "gettext.c"
        goto while_break___0;
      }
# 548 "gettext.c"
      cp ++;
    }
    while_break___0: ;
    }
# 550 "gettext.c"
    mask |= 32;
# 552 "gettext.c"
    if ((int )*(cp + 0) == 46) {
# 555 "gettext.c"
      syntax = (enum __anonenum_syntax_17 )1;
# 556 "gettext.c"
      *(cp + 0) = (char )'\000';
# 557 "gettext.c"
      cp ++;
# 557 "gettext.c"
      *codeset = (char const *)cp;
      {
# 559 "gettext.c"
      while (1) {
        while_continue___1: ;
# 559 "gettext.c"
        if ((int )*(cp + 0) != 0) {
# 559 "gettext.c"
          if (! ((int )*(cp + 0) != 64)) {
# 559 "gettext.c"
            goto while_break___1;
          }
        } else {
# 559 "gettext.c"
          goto while_break___1;
        }
# 560 "gettext.c"
        cp ++;
      }
      while_break___1: ;
      }
# 562 "gettext.c"
      mask |= 16;
# 564 "gettext.c"
      if ((unsigned long )*codeset != (unsigned long )cp) {
# 564 "gettext.c"
        if ((int const )*(*codeset + 0) != 0) {
          {
# 566 "gettext.c"
          *normalized_codeset = _nl_normalize_codeset((unsigned char const *)*codeset,
                                                      (size_t )(cp - (char *)*codeset));
# 569 "gettext.c"
          tmp = strcmp(*codeset, *normalized_codeset);
          }
# 569 "gettext.c"
          if (tmp == 0) {
            {
# 570 "gettext.c"
            free((void *)((char *)*normalized_codeset));
            }
          } else {
# 572 "gettext.c"
            mask |= 8;
          }
        }
      }
    }
  }
# 577 "gettext.c"
  if ((int )*(cp + 0) == 64) {
# 577 "gettext.c"
    goto _L;
  } else
# 577 "gettext.c"
  if ((unsigned int )syntax != 1U) {
# 577 "gettext.c"
    if ((int )*(cp + 0) == 43) {
      _L:
# 580 "gettext.c"
      if ((int )*(cp + 0) == 64) {
# 580 "gettext.c"
        syntax = (enum __anonenum_syntax_17 )1;
      } else {
# 580 "gettext.c"
        syntax = (enum __anonenum_syntax_17 )2;
      }
# 581 "gettext.c"
      *(cp + 0) = (char )'\000';
# 582 "gettext.c"
      cp ++;
# 582 "gettext.c"
      *modifier = (char const *)cp;
      {
# 584 "gettext.c"
      while (1) {
        while_continue___2: ;
# 584 "gettext.c"
        if ((unsigned int )syntax == 2U) {
# 584 "gettext.c"
          if ((int )*(cp + 0) != 0) {
# 584 "gettext.c"
            if ((int )*(cp + 0) != 43) {
# 584 "gettext.c"
              if ((int )*(cp + 0) != 44) {
# 584 "gettext.c"
                if (! ((int )*(cp + 0) != 95)) {
# 584 "gettext.c"
                  goto while_break___2;
                }
              } else {
# 584 "gettext.c"
                goto while_break___2;
              }
            } else {
# 584 "gettext.c"
              goto while_break___2;
            }
          } else {
# 584 "gettext.c"
            goto while_break___2;
          }
        } else {
# 584 "gettext.c"
          goto while_break___2;
        }
# 586 "gettext.c"
        cp ++;
      }
      while_break___2: ;
      }
# 588 "gettext.c"
      mask |= 192;
    }
  }
# 591 "gettext.c"
  if ((unsigned int )syntax != 1U) {
# 591 "gettext.c"
    if ((int )*(cp + 0) == 43) {
# 591 "gettext.c"
      goto _L___0;
    } else
# 591 "gettext.c"
    if ((int )*(cp + 0) == 44) {
# 591 "gettext.c"
      goto _L___0;
    } else
# 591 "gettext.c"
    if ((int )*(cp + 0) == 95) {
      _L___0:
# 593 "gettext.c"
      syntax = (enum __anonenum_syntax_17 )2;
# 595 "gettext.c"
      if ((int )*(cp + 0) == 43) {
# 598 "gettext.c"
        *(cp + 0) = (char )'\000';
# 599 "gettext.c"
        cp ++;
# 599 "gettext.c"
        *special = (char const *)cp;
        {
# 601 "gettext.c"
        while (1) {
          while_continue___3: ;
# 601 "gettext.c"
          if ((int )*(cp + 0) != 0) {
# 601 "gettext.c"
            if ((int )*(cp + 0) != 44) {
# 601 "gettext.c"
              if (! ((int )*(cp + 0) != 95)) {
# 601 "gettext.c"
                goto while_break___3;
              }
            } else {
# 601 "gettext.c"
              goto while_break___3;
            }
          } else {
# 601 "gettext.c"
            goto while_break___3;
          }
# 602 "gettext.c"
          cp ++;
        }
        while_break___3: ;
        }
# 604 "gettext.c"
        mask |= 4;
      }
# 607 "gettext.c"
      if ((int )*(cp + 0) == 44) {
# 610 "gettext.c"
        *(cp + 0) = (char )'\000';
# 611 "gettext.c"
        cp ++;
# 611 "gettext.c"
        *sponsor = (char const *)cp;
        {
# 613 "gettext.c"
        while (1) {
          while_continue___4: ;
# 613 "gettext.c"
          if ((int )*(cp + 0) != 0) {
# 613 "gettext.c"
            if (! ((int )*(cp + 0) != 95)) {
# 613 "gettext.c"
              goto while_break___4;
            }
          } else {
# 613 "gettext.c"
            goto while_break___4;
          }
# 614 "gettext.c"
          cp ++;
        }
        while_break___4: ;
        }
# 616 "gettext.c"
        mask |= 2;
      }
# 619 "gettext.c"
      if ((int )*(cp + 0) == 95) {
# 622 "gettext.c"
        *(cp + 0) = (char )'\000';
# 623 "gettext.c"
        cp ++;
# 623 "gettext.c"
        *revision = (char const *)cp;
# 625 "gettext.c"
        mask |= 1;
      }
    }
  }
# 631 "gettext.c"
  if ((unsigned int )syntax == 1U) {
# 633 "gettext.c"
    if ((unsigned long )*territory != (unsigned long )((void *)0)) {
# 633 "gettext.c"
      if ((int const )*(*territory + 0) == 0) {
# 634 "gettext.c"
        mask &= -33;
      }
    }
# 636 "gettext.c"
    if ((unsigned long )*codeset != (unsigned long )((void *)0)) {
# 636 "gettext.c"
      if ((int const )*(*codeset + 0) == 0) {
# 637 "gettext.c"
        mask &= -17;
      }
    }
# 639 "gettext.c"
    if ((unsigned long )*modifier != (unsigned long )((void *)0)) {
# 639 "gettext.c"
      if ((int const )*(*modifier + 0) == 0) {
# 640 "gettext.c"
        mask &= -129;
      }
    }
  }
# 643 "gettext.c"
  return (mask);
}
}
# 792 "gettext.c"
__inline static nls_uint32 SWAP(nls_uint32 i ) ;
# 794 "gettext.c"
__inline static nls_uint32 SWAP(nls_uint32 i )
{


  {
# 798 "gettext.c"
  return ((((i << 24) | ((i & 65280U) << 8)) | ((i >> 8) & 65280U)) | (i >> 24));
}
}
# 851 "gettext.c"
int _nl_msg_cat_cntr = 0;
# 855 "gettext.c"
static void _nl_load_domain(struct loaded_l10nfile *domain_file )
{
  int fd ;
  size_t size ;
  struct stat st ;
  struct mo_file_header *data ;
  struct loaded_domain *domain ;
  int tmp ;
  size_t to_read ;
  char *read_ptr ;
  int tmp___0 ;
  long nb ;
  ssize_t tmp___1 ;
  int tmp___2 ;
  nls_uint32 tmp___3 ;
  nls_uint32 tmp___4 ;
  nls_uint32 tmp___5 ;
  nls_uint32 tmp___6 ;
  nls_uint32 tmp___7 ;
  nls_uint32 tmp___8 ;
  nls_uint32 tmp___9 ;
  nls_uint32 tmp___10 ;
  nls_uint32 tmp___11 ;
  nls_uint32 tmp___12 ;
  void *tmp___13 ;
  void *tmp___14 ;

  {
# 863 "gettext.c"
  data = (struct mo_file_header *)-1;
# 870 "gettext.c"
  domain_file->decided = 1;
# 871 "gettext.c"
  domain_file->data = (void const *)((void *)0);
# 877 "gettext.c"
  if ((unsigned long )domain_file->filename == (unsigned long )((void *)0)) {
# 878 "gettext.c"
    return;
  }
  {
# 881 "gettext.c"
  fd = open(domain_file->filename, 0);
  }
# 882 "gettext.c"
  if (fd == -1) {
# 883 "gettext.c"
    return;
  }
  {
# 886 "gettext.c"
  tmp = fstat(fd, & st);
  }
# 886 "gettext.c"
  if (tmp != 0) {
    {
# 891 "gettext.c"
    close(fd);
    }
# 892 "gettext.c"
    return;
  } else {
# 886 "gettext.c"
    size = (size_t )st.st_size;
# 886 "gettext.c"
    if (size != (size_t )st.st_size) {
      {
# 891 "gettext.c"
      close(fd);
      }
# 892 "gettext.c"
      return;
    } else
# 886 "gettext.c"
    if (size < sizeof(struct mo_file_header )) {
      {
# 891 "gettext.c"
      close(fd);
      }
# 892 "gettext.c"
      return;
    }
  }
# 912 "gettext.c"
  if ((unsigned long )data == (unsigned long )((struct mo_file_header *)-1)) {
    {
# 917 "gettext.c"
    tmp___13 = malloc(size);
# 917 "gettext.c"
    tmp___0 = (int )tmp___13;
# 917 "gettext.c"
    data = (struct mo_file_header *)tmp___0;
    }
# 918 "gettext.c"
    if ((unsigned long )data == (unsigned long )((void *)0)) {
# 919 "gettext.c"
      return;
    }
# 921 "gettext.c"
    to_read = size;
# 922 "gettext.c"
    read_ptr = (char *)data;
    {
# 923 "gettext.c"
    while (1) {
      while_continue: ;
      {
# 925 "gettext.c"
      tmp___1 = read(fd, (void *)read_ptr, to_read);
# 925 "gettext.c"
      nb = tmp___1;
      }
# 926 "gettext.c"
      if (nb == -1L) {
        {
# 928 "gettext.c"
        close(fd);
        }
# 929 "gettext.c"
        return;
      }
# 932 "gettext.c"
      read_ptr += nb;
# 933 "gettext.c"
      to_read -= (size_t )nb;
# 923 "gettext.c"
      if (! (to_read > 0UL)) {
# 923 "gettext.c"
        goto while_break;
      }
    }
    while_break: ;
    }
    {
# 937 "gettext.c"
    close(fd);
    }
  }
# 942 "gettext.c"
  if (data->magic != 2500072158U) {
# 942 "gettext.c"
    if (data->magic != 3725722773U) {
      {
# 951 "gettext.c"
      free((void *)data);
      }
# 952 "gettext.c"
      return;
    }
  }
  {
# 955 "gettext.c"
  tmp___14 = malloc(sizeof(struct loaded_domain ));
# 955 "gettext.c"
  tmp___2 = (int )tmp___14;
# 955 "gettext.c"
  domain_file->data = (void const *)((struct loaded_domain *)tmp___2);
  }
# 957 "gettext.c"
  if ((unsigned long )domain_file->data == (unsigned long )((void *)0)) {
# 958 "gettext.c"
    return;
  }
# 960 "gettext.c"
  domain = (struct loaded_domain *)domain_file->data;
# 961 "gettext.c"
  domain->data = (char const *)((char *)data);
# 966 "gettext.c"
  domain->mmap_size = size;
# 967 "gettext.c"
  domain->must_swap = data->magic != 2500072158U;
# 970 "gettext.c"
  if (domain->must_swap) {
    {
# 970 "gettext.c"
    tmp___3 = SWAP(data->revision);
# 970 "gettext.c"
    tmp___4 = tmp___3;
    }
  } else {
# 970 "gettext.c"
    tmp___4 = data->revision;
  }
  {
# 971 "gettext.c"
  if (tmp___4 == 0U) {
# 971 "gettext.c"
    goto case_0;
  }
# 982 "gettext.c"
  goto switch_default;
  case_0:
# 973 "gettext.c"
  if (domain->must_swap) {
    {
# 973 "gettext.c"
    tmp___5 = SWAP(data->nstrings);
# 973 "gettext.c"
    domain->nstrings = tmp___5;
    }
  } else {
# 973 "gettext.c"
    domain->nstrings = data->nstrings;
  }
# 974 "gettext.c"
  if (domain->must_swap) {
    {
# 974 "gettext.c"
    tmp___6 = SWAP(data->orig_tab_offset);
# 974 "gettext.c"
    tmp___7 = tmp___6;
    }
  } else {
# 974 "gettext.c"
    tmp___7 = data->orig_tab_offset;
  }
# 974 "gettext.c"
  domain->orig_tab = (struct string_desc *)((char *)data + tmp___7);
# 976 "gettext.c"
  if (domain->must_swap) {
    {
# 976 "gettext.c"
    tmp___8 = SWAP(data->trans_tab_offset);
# 976 "gettext.c"
    tmp___9 = tmp___8;
    }
  } else {
# 976 "gettext.c"
    tmp___9 = data->trans_tab_offset;
  }
# 976 "gettext.c"
  domain->trans_tab = (struct string_desc *)((char *)data + tmp___9);
# 978 "gettext.c"
  if (domain->must_swap) {
    {
# 978 "gettext.c"
    tmp___10 = SWAP(data->hash_tab_size);
# 978 "gettext.c"
    domain->hash_size = tmp___10;
    }
  } else {
# 978 "gettext.c"
    domain->hash_size = data->hash_tab_size;
  }
# 979 "gettext.c"
  if (domain->must_swap) {
    {
# 979 "gettext.c"
    tmp___11 = SWAP(data->hash_tab_offset);
# 979 "gettext.c"
    tmp___12 = tmp___11;
    }
  } else {
# 979 "gettext.c"
    tmp___12 = data->hash_tab_offset;
  }
# 979 "gettext.c"
  domain->hash_tab = (nls_uint32 *)((char *)data + tmp___12);
# 981 "gettext.c"
  goto switch_break;
  switch_default:
  {
# 990 "gettext.c"
  free((void *)data);
# 991 "gettext.c"
  free((void *)domain);
# 992 "gettext.c"
  domain_file->data = (void const *)((void *)0);
  }
# 993 "gettext.c"
  return;
  switch_break: ;
  }
# 998 "gettext.c"
  _nl_msg_cat_cntr ++;
# 999 "gettext.c"
  return;
}
}
# 1105 "gettext.c"
static char *string_space = (char *)((void *)0);
# 1106 "gettext.c"
static size_t string_space_act = (size_t )0;
# 1107 "gettext.c"
static size_t string_space_max = (size_t )0;
# 1108 "gettext.c"
static struct alias_map *map ;
# 1109 "gettext.c"
static size_t nmap = (size_t )0;
# 1110 "gettext.c"
static size_t maxmap = (size_t )0;
# 1113 "gettext.c"
static size_t read_alias_file(char const *fname , int fname_len ) ;
# 1115 "gettext.c"
static void extend_alias_table(void) ;
# 1116 "gettext.c"
static int alias_compare(struct alias_map const *map1 , struct alias_map const *map2 ) ;
# 1123 "gettext.c"
static char const *locale_alias_path = "/usr/local/share/locale:.";
# 1139 "gettext.c"
extern int bsearch() ;
# 1119 "gettext.c"
static char const *_nl_expand_alias(char const *name )
{
  struct alias_map *retval ;
  char const *result___0 ;
  size_t added ;
  struct alias_map item ;
  int tmp ;
  char const *start ;

  {
# 1125 "gettext.c"
  result___0 = (char const *)((void *)0);
  {
# 1132 "gettext.c"
  while (1) {
    while_continue: ;
# 1136 "gettext.c"
    item.alias = name;
# 1138 "gettext.c"
    if (nmap > 0UL) {
      {
# 1139 "gettext.c"
      tmp = bsearch(& item, map, nmap, sizeof(struct alias_map ), (int (*)(void const * ,
                                                                           void const * ))(& alias_compare));
# 1139 "gettext.c"
      retval = (struct alias_map *)tmp;
      }
    } else {
# 1145 "gettext.c"
      retval = (struct alias_map *)((void *)0);
    }
# 1148 "gettext.c"
    if ((unsigned long )retval != (unsigned long )((void *)0)) {
# 1150 "gettext.c"
      result___0 = retval->value;
# 1151 "gettext.c"
      goto while_break;
    }
# 1155 "gettext.c"
    added = (size_t )0;
    {
# 1156 "gettext.c"
    while (1) {
      while_continue___0: ;
# 1156 "gettext.c"
      if (added == 0UL) {
# 1156 "gettext.c"
        if (! ((int const )*(locale_alias_path + 0) != 0)) {
# 1156 "gettext.c"
          goto while_break___0;
        }
      } else {
# 1156 "gettext.c"
        goto while_break___0;
      }
      {
# 1160 "gettext.c"
      while (1) {
        while_continue___1: ;
# 1160 "gettext.c"
        if (! ((int const )*(locale_alias_path + 0) == 58)) {
# 1160 "gettext.c"
          goto while_break___1;
        }
# 1161 "gettext.c"
        locale_alias_path ++;
      }
      while_break___1: ;
      }
# 1162 "gettext.c"
      start = locale_alias_path;
      {
# 1164 "gettext.c"
      while (1) {
        while_continue___2: ;
# 1164 "gettext.c"
        if ((int const )*(locale_alias_path + 0) != 0) {
# 1164 "gettext.c"
          if (! ((int const )*(locale_alias_path + 0) != 58)) {
# 1164 "gettext.c"
            goto while_break___2;
          }
        } else {
# 1164 "gettext.c"
          goto while_break___2;
        }
# 1165 "gettext.c"
        locale_alias_path ++;
      }
      while_break___2: ;
      }
# 1167 "gettext.c"
      if ((unsigned long )start < (unsigned long )locale_alias_path) {
        {
# 1168 "gettext.c"
        added = read_alias_file(start, (int )(locale_alias_path - start));
        }
      }
    }
    while_break___0: ;
    }
# 1132 "gettext.c"
    if (! (added != 0UL)) {
# 1132 "gettext.c"
      goto while_break;
    }
  }
  while_break: ;
  }
# 1177 "gettext.c"
  return (result___0);
}
}
# 1192 "gettext.c"
static char const aliasfile[14] =
# 1192 "gettext.c"
  { (char const )'/', (char const )'l', (char const )'o', (char const )'c',
        (char const )'a', (char const )'l', (char const )'e', (char const )'.',
        (char const )'a', (char const )'l', (char const )'i', (char const )'a',
        (char const )'s', (char const )'\000'};
# 1180 "gettext.c"
static size_t read_alias_file(char const *fname , int fname_len )
{
  FILE *fp ;
  char *full_fname ;
  size_t added ;
  void *tmp ;
  unsigned char buf___1[8192] ;
  unsigned char *alias ;
  unsigned char *value ;
  unsigned char *cp ;
  char *tmp___0 ;
  char altbuf[8192] ;
  char *tmp___1 ;
  char *tmp___2 ;
  char *tmp___3 ;
  unsigned short const **tmp___4 ;
  unsigned char *tmp___5 ;
  unsigned short const **tmp___6 ;
  unsigned char *tmp___7 ;
  unsigned short const **tmp___8 ;
  size_t alias_len ;
  size_t value_len ;
  unsigned char *tmp___9 ;
  unsigned short const **tmp___10 ;
  unsigned char *tmp___11 ;
  unsigned char *tmp___12 ;
  size_t tmp___13 ;
  size_t tmp___14 ;
  size_t new_size ;
  size_t tmp___15 ;
  char *new_pool ;
  int tmp___16 ;
  void *tmp___17 ;
  void *tmp___18 ;
  int tmp___19 ;
  void *tmp___20 ;

  {
  {
# 1194 "gettext.c"
  tmp = __builtin_alloca((unsigned long )fname_len + sizeof(aliasfile));
# 1194 "gettext.c"
  full_fname = (char *)tmp;
# 1200 "gettext.c"
  memcpy((void * __restrict )full_fname, (void const * __restrict )fname, (size_t )fname_len);
# 1201 "gettext.c"
  memcpy((void * __restrict )(full_fname + fname_len), (void const * __restrict )(aliasfile),
         sizeof(aliasfile));
# 1204 "gettext.c"
  fp = fopen((char const * __restrict )full_fname, (char const * __restrict )"r");
  }
# 1205 "gettext.c"
  if ((unsigned long )fp == (unsigned long )((void *)0)) {
# 1208 "gettext.c"
    return ((size_t )0);
  }
# 1211 "gettext.c"
  added = (size_t )0;
  {
# 1212 "gettext.c"
  while (1) {
    while_continue: ;
    {
# 1212 "gettext.c"
    tmp___19 = feof(fp);
    }
# 1212 "gettext.c"
    if (tmp___19) {
# 1212 "gettext.c"
      goto while_break;
    }
    {
# 1224 "gettext.c"
    tmp___0 = fgets((char * __restrict )((char *)(buf___1)), (int )sizeof(buf___1),
                    (FILE * __restrict )fp);
    }
# 1224 "gettext.c"
    if ((unsigned long )tmp___0 == (unsigned long )((void *)0)) {
# 1226 "gettext.c"
      goto while_break;
    }
    {
# 1230 "gettext.c"
    tmp___3 = strchr((char const *)((char *)(buf___1)), '\n');
    }
# 1230 "gettext.c"
    if ((unsigned long )tmp___3 == (unsigned long )((void *)0)) {
      {
# 1233 "gettext.c"
      while (1) {
        while_continue___0: ;
        {
# 1234 "gettext.c"
        tmp___1 = fgets((char * __restrict )(altbuf), (int )sizeof(altbuf), (FILE * __restrict )fp);
        }
# 1234 "gettext.c"
        if ((unsigned long )tmp___1 == (unsigned long )((void *)0)) {
# 1237 "gettext.c"
          goto while_break___0;
        }
        {
# 1233 "gettext.c"
        tmp___2 = strchr((char const *)(altbuf), '\n');
        }
# 1233 "gettext.c"
        if (! ((unsigned long )tmp___2 == (unsigned long )((void *)0))) {
# 1233 "gettext.c"
          goto while_break___0;
        }
      }
      while_break___0: ;
      }
    }
# 1241 "gettext.c"
    cp = buf___1;
    {
# 1243 "gettext.c"
    while (1) {
      while_continue___1: ;
      {
# 1243 "gettext.c"
      tmp___4 = __ctype_b_loc();
      }
# 1243 "gettext.c"
      if (! ((int const )*(*tmp___4 + (int )*(cp + 0)) & 8192)) {
# 1243 "gettext.c"
        goto while_break___1;
      }
# 1244 "gettext.c"
      cp ++;
    }
    while_break___1: ;
    }
# 1247 "gettext.c"
    if ((int )*(cp + 0) != 0) {
# 1247 "gettext.c"
      if ((int )*(cp + 0) != 35) {
# 1249 "gettext.c"
        tmp___5 = cp;
# 1249 "gettext.c"
        cp ++;
# 1249 "gettext.c"
        alias = tmp___5;
        {
# 1250 "gettext.c"
        while (1) {
          while_continue___2: ;
# 1250 "gettext.c"
          if ((int )*(cp + 0) != 0) {
            {
# 1250 "gettext.c"
            tmp___6 = __ctype_b_loc();
            }
# 1250 "gettext.c"
            if ((int const )*(*tmp___6 + (int )*(cp + 0)) & 8192) {
# 1250 "gettext.c"
              goto while_break___2;
            }
          } else {
# 1250 "gettext.c"
            goto while_break___2;
          }
# 1251 "gettext.c"
          cp ++;
        }
        while_break___2: ;
        }
# 1253 "gettext.c"
        if ((int )*(cp + 0) != 0) {
# 1254 "gettext.c"
          tmp___7 = cp;
# 1254 "gettext.c"
          cp ++;
# 1254 "gettext.c"
          *tmp___7 = (unsigned char )'\000';
        }
        {
# 1257 "gettext.c"
        while (1) {
          while_continue___3: ;
          {
# 1257 "gettext.c"
          tmp___8 = __ctype_b_loc();
          }
# 1257 "gettext.c"
          if (! ((int const )*(*tmp___8 + (int )*(cp + 0)) & 8192)) {
# 1257 "gettext.c"
            goto while_break___3;
          }
# 1258 "gettext.c"
          cp ++;
        }
        while_break___3: ;
        }
# 1260 "gettext.c"
        if ((int )*(cp + 0) != 0) {
# 1265 "gettext.c"
          tmp___9 = cp;
# 1265 "gettext.c"
          cp ++;
# 1265 "gettext.c"
          value = tmp___9;
          {
# 1266 "gettext.c"
          while (1) {
            while_continue___4: ;
# 1266 "gettext.c"
            if ((int )*(cp + 0) != 0) {
              {
# 1266 "gettext.c"
              tmp___10 = __ctype_b_loc();
              }
# 1266 "gettext.c"
              if ((int const )*(*tmp___10 + (int )*(cp + 0)) & 8192) {
# 1266 "gettext.c"
                goto while_break___4;
              }
            } else {
# 1266 "gettext.c"
              goto while_break___4;
            }
# 1267 "gettext.c"
            cp ++;
          }
          while_break___4: ;
          }
# 1269 "gettext.c"
          if ((int )*(cp + 0) == 10) {
# 1274 "gettext.c"
            tmp___11 = cp;
# 1274 "gettext.c"
            cp ++;
# 1274 "gettext.c"
            *tmp___11 = (unsigned char )'\000';
# 1275 "gettext.c"
            *cp = (unsigned char )'\n';
          } else
# 1277 "gettext.c"
          if ((int )*(cp + 0) != 0) {
# 1278 "gettext.c"
            tmp___12 = cp;
# 1278 "gettext.c"
            cp ++;
# 1278 "gettext.c"
            *tmp___12 = (unsigned char )'\000';
          }
# 1280 "gettext.c"
          if (nmap >= maxmap) {
            {
# 1281 "gettext.c"
            extend_alias_table();
            }
          }
          {
# 1283 "gettext.c"
          tmp___13 = strlen((char const *)((char *)alias));
# 1283 "gettext.c"
          alias_len = tmp___13 + 1UL;
# 1284 "gettext.c"
          tmp___14 = strlen((char const *)((char *)value));
# 1284 "gettext.c"
          value_len = tmp___14 + 1UL;
          }
# 1286 "gettext.c"
          if ((string_space_act + alias_len) + value_len > string_space_max) {
# 1289 "gettext.c"
            if (alias_len + value_len > 1024UL) {
# 1289 "gettext.c"
              tmp___15 = alias_len + value_len;
            } else {
# 1289 "gettext.c"
              tmp___15 = (size_t )1024;
            }
            {
# 1289 "gettext.c"
            new_size = string_space_max + tmp___15;
# 1292 "gettext.c"
            tmp___20 = realloc((void *)string_space, new_size);
# 1292 "gettext.c"
            tmp___16 = (int )tmp___20;
# 1292 "gettext.c"
            new_pool = (char *)tmp___16;
            }
# 1293 "gettext.c"
            if ((unsigned long )new_pool == (unsigned long )((void *)0)) {
# 1296 "gettext.c"
              return (added);
            }
# 1298 "gettext.c"
            string_space = new_pool;
# 1299 "gettext.c"
            string_space_max = new_size;
          }
          {
# 1302 "gettext.c"
          tmp___17 = memcpy((void * __restrict )(string_space + string_space_act),
                            (void const * __restrict )alias, alias_len);
# 1302 "gettext.c"
          (map + nmap)->alias = (char const *)tmp___17;
# 1304 "gettext.c"
          string_space_act += alias_len;
# 1306 "gettext.c"
          tmp___18 = memcpy((void * __restrict )(string_space + string_space_act),
                            (void const * __restrict )value, value_len);
# 1306 "gettext.c"
          (map + nmap)->value = (char const *)tmp___18;
# 1308 "gettext.c"
          string_space_act += value_len;
# 1310 "gettext.c"
          nmap ++;
# 1311 "gettext.c"
          added ++;
          }
        }
      }
    }
  }
  while_break: ;
  }
  {
# 1318 "gettext.c"
  fclose(fp);
  }
# 1320 "gettext.c"
  if (added > 0UL) {
    {
# 1321 "gettext.c"
    qsort((void *)map, nmap, sizeof(struct alias_map ), (int (*)(void const * ,
                                                                 void const * ))(& alias_compare));
    }
  }
# 1325 "gettext.c"
  return (added);
}
}
# 1328 "gettext.c"
static void extend_alias_table(void)
{
  size_t new_size ;
  struct alias_map *new_map ;
  int tmp ;
  void *tmp___0 ;

  {
# 1334 "gettext.c"
  if (maxmap == 0UL) {
# 1334 "gettext.c"
    new_size = (size_t )100;
  } else {
# 1334 "gettext.c"
    new_size = 2UL * maxmap;
  }
  {
# 1335 "gettext.c"
  tmp___0 = realloc((void *)map, new_size * sizeof(struct alias_map ));
# 1335 "gettext.c"
  tmp = (int )tmp___0;
# 1335 "gettext.c"
  new_map = (struct alias_map *)tmp;
  }
# 1337 "gettext.c"
  if ((unsigned long )new_map == (unsigned long )((void *)0)) {
# 1339 "gettext.c"
    return;
  }
# 1341 "gettext.c"
  map = new_map;
# 1342 "gettext.c"
  maxmap = new_size;
# 1343 "gettext.c"
  return;
}
}
# 1357 "gettext.c"
static int alias_compare(struct alias_map const *map1 , struct alias_map const *map2 )
{
  unsigned char const *p1 ;
  unsigned char const *p2 ;
  unsigned char c1 ;
  unsigned char c2 ;
  int tmp___0 ;
  unsigned short const **tmp___1 ;
  int tmp___3 ;
  unsigned short const **tmp___4 ;

  {
# 1365 "gettext.c"
  p1 = (unsigned char const *)map1->alias;
# 1366 "gettext.c"
  p2 = (unsigned char const *)map2->alias;
# 1369 "gettext.c"
  if ((unsigned long )p1 == (unsigned long )p2) {
# 1370 "gettext.c"
    return (0);
  }
  {
# 1372 "gettext.c"
  while (1) {
    while_continue: ;
    {
# 1376 "gettext.c"
    tmp___1 = __ctype_b_loc();
    }
# 1376 "gettext.c"
    if ((int const )*(*tmp___1 + (int )*p1) & 256) {
      {
# 1376 "gettext.c"
      tmp___0 = tolower((int )*p1);
# 1376 "gettext.c"
      c1 = (unsigned char )tmp___0;
      }
    } else {
# 1376 "gettext.c"
      c1 = (unsigned char )*p1;
    }
    {
# 1377 "gettext.c"
    tmp___4 = __ctype_b_loc();
    }
# 1377 "gettext.c"
    if ((int const )*(*tmp___4 + (int )*p2) & 256) {
      {
# 1377 "gettext.c"
      tmp___3 = tolower((int )*p2);
# 1377 "gettext.c"
      c2 = (unsigned char )tmp___3;
      }
    } else {
# 1377 "gettext.c"
      c2 = (unsigned char )*p2;
    }
# 1378 "gettext.c"
    if ((int )c1 == 0) {
# 1379 "gettext.c"
      goto while_break;
    }
# 1380 "gettext.c"
    p1 ++;
# 1381 "gettext.c"
    p2 ++;
# 1372 "gettext.c"
    if (! ((int )c1 == (int )c2)) {
# 1372 "gettext.c"
      goto while_break;
    }
  }
  while_break: ;
  }
# 1385 "gettext.c"
  return ((int )c1 - (int )c2);
}
}
# 90 "gettext.h"
char *gettext(char const *msgid ) ;
# 95 "gettext.h"
char *dgettext(char const *domainname , char const *msgid ) ;
# 103 "gettext.h"
char *dcgettext__(char const *domainname , char const *msgid , int category ) ;
# 1429 "gettext.c"
static struct loaded_l10nfile *_nl_loaded_domains ;
# 1434 "gettext.c"
static struct loaded_l10nfile *_nl_find_domain(char const *dirname , char *locale ,
                                               char const *domainname )
{
  struct loaded_l10nfile *retval ;
  char const *language ;
  char const *modifier ;
  char const *territory ;
  char const *codeset ;
  char const *normalized_codeset ;
  char const *special ;
  char const *sponsor ;
  char const *revision ;
  char const *alias_value ;
  int mask ;
  size_t tmp ;
  int cnt ;
  struct loaded_l10nfile *tmp___0 ;
  size_t tmp___1 ;
  int cnt___0 ;

  {
  {
# 1476 "gettext.c"
  tmp = strlen(dirname);
# 1476 "gettext.c"
  retval = _nl_make_l10nflist(& _nl_loaded_domains, dirname, tmp + 1UL, 0, (char const *)locale,
                              (char const *)((void *)0), (char const *)((void *)0),
                              (char const *)((void *)0), (char const *)((void *)0),
                              (char const *)((void *)0), (char const *)((void *)0),
                              (char const *)((void *)0), domainname, 0);
  }
# 1479 "gettext.c"
  if ((unsigned long )retval != (unsigned long )((void *)0)) {
# 1484 "gettext.c"
    if (retval->decided == 0) {
      {
# 1485 "gettext.c"
      _nl_load_domain(retval);
      }
    }
# 1487 "gettext.c"
    if ((unsigned long )retval->data != (unsigned long )((void *)0)) {
# 1488 "gettext.c"
      return (retval);
    }
# 1490 "gettext.c"
    cnt = 0;
    {
# 1490 "gettext.c"
    while (1) {
      while_continue: ;
# 1490 "gettext.c"
      if (! ((unsigned long )retval->successor[cnt] != (unsigned long )((void *)0))) {
# 1490 "gettext.c"
        goto while_break;
      }
# 1492 "gettext.c"
      if ((retval->successor[cnt])->decided == 0) {
        {
# 1493 "gettext.c"
        _nl_load_domain(retval->successor[cnt]);
        }
      }
# 1495 "gettext.c"
      if ((unsigned long )(retval->successor[cnt])->data != (unsigned long )((void *)0)) {
# 1496 "gettext.c"
        goto while_break;
      }
# 1490 "gettext.c"
      cnt ++;
    }
    while_break: ;
    }
# 1498 "gettext.c"
    if (cnt >= 0) {
# 1498 "gettext.c"
      tmp___0 = retval;
    } else {
# 1498 "gettext.c"
      tmp___0 = (struct loaded_l10nfile *)((void *)0);
    }
# 1498 "gettext.c"
    return (tmp___0);
  }
  {
# 1505 "gettext.c"
  alias_value = _nl_expand_alias((char const *)locale);
  }
# 1506 "gettext.c"
  if ((unsigned long )alias_value != (unsigned long )((void *)0)) {
    {
# 1509 "gettext.c"
    locale = strdup(alias_value);
    }
# 1510 "gettext.c"
    if ((unsigned long )locale == (unsigned long )((void *)0)) {
# 1511 "gettext.c"
      return ((struct loaded_l10nfile *)((void *)0));
    }
  }
  {
# 1525 "gettext.c"
  mask = _nl_explode_name(locale, & language, & modifier, & territory, & codeset,
                          & normalized_codeset, & special, & sponsor, & revision);
# 1531 "gettext.c"
  tmp___1 = strlen(dirname);
# 1531 "gettext.c"
  retval = _nl_make_l10nflist(& _nl_loaded_domains, dirname, tmp___1 + 1UL, mask,
                              language, territory, codeset, normalized_codeset, modifier,
                              special, sponsor, revision, domainname, 1);
  }
# 1535 "gettext.c"
  if ((unsigned long )retval == (unsigned long )((void *)0)) {
# 1537 "gettext.c"
    return ((struct loaded_l10nfile *)((void *)0));
  }
# 1539 "gettext.c"
  if (retval->decided == 0) {
    {
# 1540 "gettext.c"
    _nl_load_domain(retval);
    }
  }
# 1541 "gettext.c"
  if ((unsigned long )retval->data == (unsigned long )((void *)0)) {
# 1544 "gettext.c"
    cnt___0 = 0;
    {
# 1544 "gettext.c"
    while (1) {
      while_continue___0: ;
# 1544 "gettext.c"
      if (! ((unsigned long )retval->successor[cnt___0] != (unsigned long )((void *)0))) {
# 1544 "gettext.c"
        goto while_break___0;
      }
# 1546 "gettext.c"
      if ((retval->successor[cnt___0])->decided == 0) {
        {
# 1547 "gettext.c"
        _nl_load_domain(retval->successor[cnt___0]);
        }
      }
# 1548 "gettext.c"
      if ((unsigned long )(retval->successor[cnt___0])->data != (unsigned long )((void *)0)) {
# 1549 "gettext.c"
        goto while_break___0;
      }
# 1544 "gettext.c"
      cnt___0 ++;
    }
    while_break___0: ;
    }
  }
# 1554 "gettext.c"
  if ((unsigned long )alias_value != (unsigned long )((void *)0)) {
    {
# 1555 "gettext.c"
    free((void *)locale);
    }
  }
# 1557 "gettext.c"
  return (retval);
}
}
# 1642 "gettext.c"
__inline static unsigned long hash_string(char const *str_param ) ;
# 1644 "gettext.c"
__inline static unsigned long hash_string(char const *str_param )
{
  unsigned long hval ;
  unsigned long g ;
  char const *str ;
  char const *tmp ;

  {
# 1649 "gettext.c"
  str = str_param;
# 1652 "gettext.c"
  hval = 0UL;
  {
# 1653 "gettext.c"
  while (1) {
    while_continue: ;
# 1653 "gettext.c"
    if (! ((int const )*str != 0)) {
# 1653 "gettext.c"
      goto while_break;
    }
# 1655 "gettext.c"
    hval <<= 4;
# 1656 "gettext.c"
    tmp = str;
# 1656 "gettext.c"
    str ++;
# 1656 "gettext.c"
    hval += (unsigned long )*tmp;
# 1657 "gettext.c"
    g = hval & (15UL << 28);
# 1658 "gettext.c"
    if (g != 0UL) {
# 1660 "gettext.c"
      hval ^= g >> 24;
# 1661 "gettext.c"
      hval ^= g;
    }
  }
  while_break: ;
  }
# 1664 "gettext.c"
  return (hval);
}
}
# 1734 "gettext.c"
static char const _nl_default_default_domain[9] =
# 1734 "gettext.c"
  { (char const )'m', (char const )'e', (char const )'s', (char const )'s',
        (char const )'a', (char const )'g', (char const )'e', (char const )'s',
        (char const )'\000'};
# 1737 "gettext.c"
static char const *_nl_current_default_domain = _nl_default_default_domain;
# 1740 "gettext.c"
static char const _nl_default_dirname[24] =
# 1740 "gettext.c"
  { (char const )'/', (char const )'u', (char const )'s', (char const )'r',
        (char const )'/', (char const )'l', (char const )'o', (char const )'c',
        (char const )'a', (char const )'l', (char const )'/', (char const )'s',
        (char const )'h', (char const )'a', (char const )'r', (char const )'e',
        (char const )'/', (char const )'l', (char const )'o', (char const )'c',
        (char const )'a', (char const )'l', (char const )'e', (char const )'\000'};
# 1744 "gettext.c"
static struct binding *_nl_domain_bindings ;
# 1747 "gettext.c"
static char *find_msg(struct loaded_l10nfile *domain_file , char const *msgid ) ;
# 1749 "gettext.c"
static char const *category_to_name(int category ) ;
# 1750 "gettext.c"
static char const *guess_category_value(int category , char const *categoryname ) ;
# 1766 "gettext.c"
char *dcgettext__(char const *domainname , char const *msgid , int category )
{
  struct loaded_l10nfile *domain ;
  struct binding *binding ;
  char const *categoryname ;
  char const *categoryvalue ;
  char *dirname ;
  char *xdomainname ;
  char *single_locale ;
  char *retval ;
  int saved_errno ;
  int *tmp ;
  int compare ;
  int tmp___0 ;
  size_t dirname_len ;
  size_t tmp___1 ;
  size_t path_max ;
  char *ret ;
  void *tmp___2 ;
  int *tmp___3 ;
  void *tmp___4 ;
  int *tmp___5 ;
  int *tmp___6 ;
  int *tmp___7 ;
  char *tmp___8 ;
  char *tmp___9 ;
  size_t tmp___10 ;
  size_t tmp___11 ;
  void *tmp___12 ;
  char *tmp___13 ;
  char *tmp___14 ;
  char *tmp___15 ;
  size_t tmp___16 ;
  void *tmp___17 ;
  char *cp ;
  char *tmp___18 ;
  char const *tmp___19 ;
  int *tmp___20 ;
  int tmp___21 ;
  int tmp___22 ;
  int cnt ;
  int *tmp___23 ;

  {
  {
# 1782 "gettext.c"
  tmp = __errno_location();
# 1782 "gettext.c"
  saved_errno = *tmp;
  }
# 1785 "gettext.c"
  if ((unsigned long )msgid == (unsigned long )((void *)0)) {
# 1786 "gettext.c"
    return ((char *)((void *)0));
  }
# 1791 "gettext.c"
  if ((unsigned long )domainname == (unsigned long )((void *)0)) {
# 1792 "gettext.c"
    domainname = _nl_current_default_domain;
  }
# 1795 "gettext.c"
  binding = _nl_domain_bindings;
  {
# 1795 "gettext.c"
  while (1) {
    while_continue: ;
# 1795 "gettext.c"
    if (! ((unsigned long )binding != (unsigned long )((void *)0))) {
# 1795 "gettext.c"
      goto while_break;
    }
    {
# 1797 "gettext.c"
    tmp___0 = strcmp(domainname, (char const *)binding->domainname);
# 1797 "gettext.c"
    compare = tmp___0;
    }
# 1798 "gettext.c"
    if (compare == 0) {
# 1800 "gettext.c"
      goto while_break;
    }
# 1801 "gettext.c"
    if (compare < 0) {
# 1804 "gettext.c"
      binding = (struct binding *)((void *)0);
# 1805 "gettext.c"
      goto while_break;
    }
# 1795 "gettext.c"
    binding = binding->next;
  }
  while_break: ;
  }
# 1809 "gettext.c"
  if ((unsigned long )binding == (unsigned long )((void *)0)) {
# 1810 "gettext.c"
    dirname = (char *)(_nl_default_dirname);
  } else
# 1811 "gettext.c"
  if ((int )*(binding->dirname + 0) == 47) {
# 1812 "gettext.c"
    dirname = binding->dirname;
  } else {
    {
# 1816 "gettext.c"
    tmp___1 = strlen((char const *)binding->dirname);
# 1816 "gettext.c"
    dirname_len = tmp___1 + 1UL;
# 1820 "gettext.c"
    path_max = (size_t )4096U;
# 1821 "gettext.c"
    path_max += 2UL;
# 1823 "gettext.c"
    tmp___2 = __builtin_alloca(path_max + dirname_len);
# 1823 "gettext.c"
    dirname = (char *)tmp___2;
# 1826 "gettext.c"
    tmp___3 = __errno_location();
# 1826 "gettext.c"
    *tmp___3 = 0;
    }
    {
# 1827 "gettext.c"
    while (1) {
      while_continue___0: ;
      {
# 1827 "gettext.c"
      ret = getcwd(dirname, path_max);
      }
# 1827 "gettext.c"
      if ((unsigned long )ret == (unsigned long )((void *)0)) {
        {
# 1827 "gettext.c"
        tmp___6 = __errno_location();
        }
# 1827 "gettext.c"
        if (! (*tmp___6 == 34)) {
# 1827 "gettext.c"
          goto while_break___0;
        }
      } else {
# 1827 "gettext.c"
        goto while_break___0;
      }
      {
# 1829 "gettext.c"
      path_max += 32UL;
# 1830 "gettext.c"
      tmp___4 = __builtin_alloca(path_max + dirname_len);
# 1830 "gettext.c"
      dirname = (char *)tmp___4;
# 1832 "gettext.c"
      tmp___5 = __errno_location();
# 1832 "gettext.c"
      *tmp___5 = 0;
      }
    }
    while_break___0: ;
    }
# 1835 "gettext.c"
    if ((unsigned long )ret == (unsigned long )((void *)0)) {
      {
# 1840 "gettext.c"
      tmp___7 = __errno_location();
# 1840 "gettext.c"
      *tmp___7 = saved_errno;
      }
# 1841 "gettext.c"
      return ((char *)msgid);
    }
    {
# 1844 "gettext.c"
    tmp___8 = strchr((char const *)dirname, '\000');
# 1844 "gettext.c"
    tmp___9 = stpcpy((char * __restrict )tmp___8, (char const * __restrict )"/");
# 1844 "gettext.c"
    stpcpy((char * __restrict )tmp___9, (char const * __restrict )binding->dirname);
    }
  }
  {
# 1848 "gettext.c"
  categoryname = category_to_name(category);
# 1849 "gettext.c"
  categoryvalue = guess_category_value(category, categoryname);
# 1851 "gettext.c"
  tmp___10 = strlen(categoryname);
# 1851 "gettext.c"
  tmp___11 = strlen(domainname);
# 1851 "gettext.c"
  tmp___12 = __builtin_alloca((tmp___10 + tmp___11) + 5UL);
# 1851 "gettext.c"
  xdomainname = (char *)tmp___12;
# 1855 "gettext.c"
  tmp___13 = stpcpy((char * __restrict )xdomainname, (char const * __restrict )categoryname);
# 1855 "gettext.c"
  tmp___14 = stpcpy((char * __restrict )tmp___13, (char const * __restrict )"/");
# 1855 "gettext.c"
  tmp___15 = stpcpy((char * __restrict )tmp___14, (char const * __restrict )domainname);
# 1855 "gettext.c"
  stpcpy((char * __restrict )tmp___15, (char const * __restrict )".mo");
# 1860 "gettext.c"
  tmp___16 = strlen(categoryvalue);
# 1860 "gettext.c"
  tmp___17 = __builtin_alloca(tmp___16 + 1UL);
# 1860 "gettext.c"
  single_locale = (char *)tmp___17;
  }
  {
# 1865 "gettext.c"
  while (1) {
    while_continue___1: ;
    {
# 1868 "gettext.c"
    while (1) {
      while_continue___2: ;
# 1868 "gettext.c"
      if ((int const )*(categoryvalue + 0) != 0) {
# 1868 "gettext.c"
        if (! ((int const )*(categoryvalue + 0) == 58)) {
# 1868 "gettext.c"
          goto while_break___2;
        }
      } else {
# 1868 "gettext.c"
        goto while_break___2;
      }
# 1869 "gettext.c"
      categoryvalue ++;
    }
    while_break___2: ;
    }
# 1870 "gettext.c"
    if ((int const )*(categoryvalue + 0) == 0) {
# 1876 "gettext.c"
      *(single_locale + 0) = (char )'C';
# 1877 "gettext.c"
      *(single_locale + 1) = (char )'\000';
    } else {
# 1881 "gettext.c"
      cp = single_locale;
      {
# 1882 "gettext.c"
      while (1) {
        while_continue___3: ;
# 1882 "gettext.c"
        if ((int const )*(categoryvalue + 0) != 0) {
# 1882 "gettext.c"
          if (! ((int const )*(categoryvalue + 0) != 58)) {
# 1882 "gettext.c"
            goto while_break___3;
          }
        } else {
# 1882 "gettext.c"
          goto while_break___3;
        }
# 1883 "gettext.c"
        tmp___18 = cp;
# 1883 "gettext.c"
        cp ++;
# 1883 "gettext.c"
        tmp___19 = categoryvalue;
# 1883 "gettext.c"
        categoryvalue ++;
# 1883 "gettext.c"
        *tmp___18 = (char )*tmp___19;
      }
      while_break___3: ;
      }
# 1884 "gettext.c"
      *cp = (char )'\000';
    }
    {
# 1889 "gettext.c"
    tmp___21 = strcmp((char const *)single_locale, "C");
    }
# 1889 "gettext.c"
    if (tmp___21 == 0) {
      {
# 1893 "gettext.c"
      tmp___20 = __errno_location();
# 1893 "gettext.c"
      *tmp___20 = saved_errno;
      }
# 1894 "gettext.c"
      return ((char *)msgid);
    } else {
      {
# 1889 "gettext.c"
      tmp___22 = strcmp((char const *)single_locale, "POSIX");
      }
# 1889 "gettext.c"
      if (tmp___22 == 0) {
        {
# 1893 "gettext.c"
        tmp___20 = __errno_location();
# 1893 "gettext.c"
        *tmp___20 = saved_errno;
        }
# 1894 "gettext.c"
        return ((char *)msgid);
      }
    }
    {
# 1899 "gettext.c"
    domain = _nl_find_domain((char const *)dirname, single_locale, (char const *)xdomainname);
    }
# 1901 "gettext.c"
    if ((unsigned long )domain != (unsigned long )((void *)0)) {
      {
# 1903 "gettext.c"
      retval = find_msg(domain, msgid);
      }
# 1905 "gettext.c"
      if ((unsigned long )retval == (unsigned long )((void *)0)) {
# 1909 "gettext.c"
        cnt = 0;
        {
# 1909 "gettext.c"
        while (1) {
          while_continue___4: ;
# 1909 "gettext.c"
          if (! ((unsigned long )domain->successor[cnt] != (unsigned long )((void *)0))) {
# 1909 "gettext.c"
            goto while_break___4;
          }
          {
# 1911 "gettext.c"
          retval = find_msg(domain->successor[cnt], msgid);
          }
# 1913 "gettext.c"
          if ((unsigned long )retval != (unsigned long )((void *)0)) {
# 1914 "gettext.c"
            goto while_break___4;
          }
# 1909 "gettext.c"
          cnt ++;
        }
        while_break___4: ;
        }
      }
# 1918 "gettext.c"
      if ((unsigned long )retval != (unsigned long )((void *)0)) {
        {
# 1921 "gettext.c"
        tmp___23 = __errno_location();
# 1921 "gettext.c"
        *tmp___23 = saved_errno;
        }
# 1922 "gettext.c"
        return (retval);
      }
    }
  }
  while_break___1: ;
  }
}
}
# 1933 "gettext.c"
static char *find_msg(struct loaded_l10nfile *domain_file , char const *msgid )
{
  size_t top ;
  size_t act ;
  size_t bottom ;
  struct loaded_domain *domain ;
  nls_uint32 len ;
  size_t tmp ;
  nls_uint32 hash_val ;
  unsigned long tmp___0 ;
  nls_uint32 idx ;
  nls_uint32 incr ;
  nls_uint32 nstr ;
  nls_uint32 tmp___1 ;
  nls_uint32 tmp___2 ;
  nls_uint32 tmp___3 ;
  nls_uint32 tmp___4 ;
  nls_uint32 tmp___5 ;
  nls_uint32 tmp___6 ;
  nls_uint32 tmp___7 ;
  nls_uint32 tmp___8 ;
  int tmp___9 ;
  nls_uint32 tmp___10 ;
  nls_uint32 tmp___11 ;
  nls_uint32 tmp___12 ;
  nls_uint32 tmp___13 ;
  nls_uint32 tmp___14 ;
  nls_uint32 tmp___15 ;
  nls_uint32 tmp___16 ;
  int tmp___17 ;
  int cmp_val ;
  nls_uint32 tmp___18 ;
  nls_uint32 tmp___19 ;
  nls_uint32 tmp___20 ;
  nls_uint32 tmp___21 ;
  char *tmp___22 ;

  {
# 1942 "gettext.c"
  if (domain_file->decided == 0) {
    {
# 1943 "gettext.c"
    _nl_load_domain(domain_file);
    }
  }
# 1945 "gettext.c"
  if ((unsigned long )domain_file->data == (unsigned long )((void *)0)) {
# 1946 "gettext.c"
    return ((char *)((void *)0));
  }
# 1948 "gettext.c"
  domain = (struct loaded_domain *)domain_file->data;
# 1951 "gettext.c"
  if (domain->hash_size > 2U) {
# 1951 "gettext.c"
    if ((unsigned long )domain->hash_tab != (unsigned long )((void *)0)) {
      {
# 1954 "gettext.c"
      tmp = strlen(msgid);
# 1954 "gettext.c"
      len = (nls_uint32 )tmp;
# 1955 "gettext.c"
      tmp___0 = hash_string(msgid);
# 1955 "gettext.c"
      hash_val = (nls_uint32 )tmp___0;
# 1956 "gettext.c"
      idx = hash_val % domain->hash_size;
# 1957 "gettext.c"
      incr = 1U + hash_val % (domain->hash_size - 2U);
      }
# 1958 "gettext.c"
      if (domain->must_swap) {
        {
# 1958 "gettext.c"
        tmp___1 = SWAP(*(domain->hash_tab + idx));
# 1958 "gettext.c"
        tmp___2 = tmp___1;
        }
      } else {
# 1958 "gettext.c"
        tmp___2 = *(domain->hash_tab + idx);
      }
# 1958 "gettext.c"
      nstr = tmp___2;
# 1960 "gettext.c"
      if (nstr == 0U) {
# 1962 "gettext.c"
        return ((char *)((void *)0));
      }
# 1964 "gettext.c"
      if (domain->must_swap) {
        {
# 1964 "gettext.c"
        tmp___5 = SWAP((domain->orig_tab + (nstr - 1U))->length);
# 1964 "gettext.c"
        tmp___6 = tmp___5;
        }
      } else {
# 1964 "gettext.c"
        tmp___6 = (domain->orig_tab + (nstr - 1U))->length;
      }
# 1964 "gettext.c"
      if (tmp___6 == len) {
# 1964 "gettext.c"
        if (domain->must_swap) {
          {
# 1964 "gettext.c"
          tmp___7 = SWAP((domain->orig_tab + (nstr - 1U))->offset);
# 1964 "gettext.c"
          tmp___8 = tmp___7;
          }
        } else {
# 1964 "gettext.c"
          tmp___8 = (domain->orig_tab + (nstr - 1U))->offset;
        }
        {
# 1964 "gettext.c"
        tmp___9 = strcmp(msgid, domain->data + tmp___8);
        }
# 1964 "gettext.c"
        if (tmp___9 == 0) {
# 1968 "gettext.c"
          if (domain->must_swap) {
            {
# 1968 "gettext.c"
            tmp___3 = SWAP((domain->trans_tab + (nstr - 1U))->offset);
# 1968 "gettext.c"
            tmp___4 = tmp___3;
            }
          } else {
# 1968 "gettext.c"
            tmp___4 = (domain->trans_tab + (nstr - 1U))->offset;
          }
# 1968 "gettext.c"
          return ((char *)domain->data + tmp___4);
        }
      }
      {
# 1971 "gettext.c"
      while (1) {
        while_continue: ;
# 1973 "gettext.c"
        if (idx >= domain->hash_size - incr) {
# 1974 "gettext.c"
          idx -= domain->hash_size - incr;
        } else {
# 1976 "gettext.c"
          idx += incr;
        }
# 1978 "gettext.c"
        if (domain->must_swap) {
          {
# 1978 "gettext.c"
          tmp___10 = SWAP(*(domain->hash_tab + idx));
# 1978 "gettext.c"
          nstr = tmp___10;
          }
        } else {
# 1978 "gettext.c"
          nstr = *(domain->hash_tab + idx);
        }
# 1979 "gettext.c"
        if (nstr == 0U) {
# 1981 "gettext.c"
          return ((char *)((void *)0));
        }
# 1983 "gettext.c"
        if (domain->must_swap) {
          {
# 1983 "gettext.c"
          tmp___13 = SWAP((domain->orig_tab + (nstr - 1U))->length);
# 1983 "gettext.c"
          tmp___14 = tmp___13;
          }
        } else {
# 1983 "gettext.c"
          tmp___14 = (domain->orig_tab + (nstr - 1U))->length;
        }
# 1983 "gettext.c"
        if (tmp___14 == len) {
# 1983 "gettext.c"
          if (domain->must_swap) {
            {
# 1983 "gettext.c"
            tmp___15 = SWAP((domain->orig_tab + (nstr - 1U))->offset);
# 1983 "gettext.c"
            tmp___16 = tmp___15;
            }
          } else {
# 1983 "gettext.c"
            tmp___16 = (domain->orig_tab + (nstr - 1U))->offset;
          }
          {
# 1983 "gettext.c"
          tmp___17 = strcmp(msgid, domain->data + tmp___16);
          }
# 1983 "gettext.c"
          if (tmp___17 == 0) {
# 1988 "gettext.c"
            if (domain->must_swap) {
              {
# 1988 "gettext.c"
              tmp___11 = SWAP((domain->trans_tab + (nstr - 1U))->offset);
# 1988 "gettext.c"
              tmp___12 = tmp___11;
              }
            } else {
# 1988 "gettext.c"
              tmp___12 = (domain->trans_tab + (nstr - 1U))->offset;
            }
# 1988 "gettext.c"
            return ((char *)domain->data + tmp___12);
          }
        }
      }
      while_break: ;
      }
    }
  }
# 1996 "gettext.c"
  bottom = (size_t )0;
# 1997 "gettext.c"
  top = (size_t )domain->nstrings;
  {
# 1998 "gettext.c"
  while (1) {
    while_continue___0: ;
# 1998 "gettext.c"
    if (! (bottom < top)) {
# 1998 "gettext.c"
      goto while_break___0;
    }
# 2002 "gettext.c"
    act = (bottom + top) / 2UL;
# 2003 "gettext.c"
    if (domain->must_swap) {
      {
# 2003 "gettext.c"
      tmp___18 = SWAP((domain->orig_tab + act)->offset);
# 2003 "gettext.c"
      tmp___19 = tmp___18;
      }
    } else {
# 2003 "gettext.c"
      tmp___19 = (domain->orig_tab + act)->offset;
    }
    {
# 2003 "gettext.c"
    cmp_val = strcmp(msgid, domain->data + tmp___19);
    }
# 2006 "gettext.c"
    if (cmp_val < 0) {
# 2007 "gettext.c"
      top = act;
    } else
# 2008 "gettext.c"
    if (cmp_val > 0) {
# 2009 "gettext.c"
      bottom = act + 1UL;
    } else {
# 2011 "gettext.c"
      goto while_break___0;
    }
  }
  while_break___0: ;
  }
# 2015 "gettext.c"
  if (bottom >= top) {
# 2015 "gettext.c"
    tmp___22 = (char *)((void *)0);
  } else {
# 2015 "gettext.c"
    if (domain->must_swap) {
      {
# 2015 "gettext.c"
      tmp___20 = SWAP((domain->trans_tab + act)->offset);
# 2015 "gettext.c"
      tmp___21 = tmp___20;
      }
    } else {
# 2015 "gettext.c"
      tmp___21 = (domain->trans_tab + act)->offset;
    }
# 2015 "gettext.c"
    tmp___22 = (char *)domain->data + tmp___21;
  }
# 2015 "gettext.c"
  return (tmp___22);
}
}
# 2021 "gettext.c"
static char const *category_to_name(int category )
{
  char const *retval ;

  {
  {
# 2029 "gettext.c"
  if (category == 3) {
# 2029 "gettext.c"
    goto case_3;
  }
# 2034 "gettext.c"
  if (category == 0) {
# 2034 "gettext.c"
    goto case_0;
  }
# 2039 "gettext.c"
  if (category == 4) {
# 2039 "gettext.c"
    goto case_4;
  }
# 2044 "gettext.c"
  if (category == 1) {
# 2044 "gettext.c"
    goto case_1;
  }
# 2049 "gettext.c"
  if (category == 2) {
# 2049 "gettext.c"
    goto case_2;
  }
# 2054 "gettext.c"
  if (category == 5) {
# 2054 "gettext.c"
    goto case_5;
  }
# 2059 "gettext.c"
  if (category == 6) {
# 2059 "gettext.c"
    goto case_6;
  }
# 2071 "gettext.c"
  goto switch_default;
  case_3:
# 2032 "gettext.c"
  retval = "LC_COLLATE";
# 2033 "gettext.c"
  goto switch_break;
  case_0:
# 2037 "gettext.c"
  retval = "LC_CTYPE";
# 2038 "gettext.c"
  goto switch_break;
  case_4:
# 2042 "gettext.c"
  retval = "LC_MONETARY";
# 2043 "gettext.c"
  goto switch_break;
  case_1:
# 2047 "gettext.c"
  retval = "LC_NUMERIC";
# 2048 "gettext.c"
  goto switch_break;
  case_2:
# 2052 "gettext.c"
  retval = "LC_TIME";
# 2053 "gettext.c"
  goto switch_break;
  case_5:
# 2057 "gettext.c"
  retval = "LC_MESSAGES";
# 2058 "gettext.c"
  goto switch_break;
  case_6:
# 2069 "gettext.c"
  retval = "LC_ALL";
# 2070 "gettext.c"
  goto switch_break;
  switch_default:
# 2074 "gettext.c"
  retval = "LC_XXX";
  switch_break: ;
  }
# 2077 "gettext.c"
  return (retval);
}
}
# 2081 "gettext.c"
static char const *guess_category_value(int category , char const *categoryname )
{
  char const *retval ;
  int tmp ;
  int tmp___0 ;
  int tmp___1 ;
  int tmp___2 ;
  char *tmp___3 ;
  char *tmp___4 ;
  char *tmp___5 ;
  char *tmp___6 ;

  {
  {
# 2091 "gettext.c"
  tmp___3 = getenv("LANGUAGE");
# 2091 "gettext.c"
  tmp = (int )tmp___3;
# 2091 "gettext.c"
  retval = (char const *)tmp;
  }
# 2092 "gettext.c"
  if ((unsigned long )retval != (unsigned long )((void *)0)) {
# 2092 "gettext.c"
    if ((int const )*(retval + 0) != 0) {
# 2093 "gettext.c"
      return (retval);
    }
  }
  {
# 2102 "gettext.c"
  tmp___4 = getenv("LC_ALL");
# 2102 "gettext.c"
  tmp___0 = (int )tmp___4;
# 2102 "gettext.c"
  retval = (char const *)tmp___0;
  }
# 2103 "gettext.c"
  if ((unsigned long )retval != (unsigned long )((void *)0)) {
# 2103 "gettext.c"
    if ((int const )*(retval + 0) != 0) {
# 2104 "gettext.c"
      return (retval);
    }
  }
  {
# 2107 "gettext.c"
  tmp___5 = getenv(categoryname);
# 2107 "gettext.c"
  tmp___1 = (int )tmp___5;
# 2107 "gettext.c"
  retval = (char const *)tmp___1;
  }
# 2108 "gettext.c"
  if ((unsigned long )retval != (unsigned long )((void *)0)) {
# 2108 "gettext.c"
    if ((int const )*(retval + 0) != 0) {
# 2109 "gettext.c"
      return (retval);
    }
  }
  {
# 2112 "gettext.c"
  tmp___6 = getenv("LANG");
# 2112 "gettext.c"
  tmp___2 = (int )tmp___6;
# 2112 "gettext.c"
  retval = (char const *)tmp___2;
  }
# 2113 "gettext.c"
  if ((unsigned long )retval != (unsigned long )((void *)0)) {
# 2113 "gettext.c"
    if ((int const )*(retval + 0) != 0) {
# 2114 "gettext.c"
      return (retval);
    }
  }
# 2118 "gettext.c"
  return ("C");
}
}
# 2209 "gettext.c"
static char *bindtextdomain__(char const *domainname , char const *dirname )
{
  struct binding *binding ;
  int compare ;
  int tmp ;
  char *tmp___0 ;
  char *new_dirname ;
  int tmp___1 ;
  int tmp___2 ;
  struct binding *new_binding ;
  int tmp___3 ;
  int tmp___4 ;
  int tmp___5 ;
  int tmp___6 ;
  void *tmp___7 ;

  {
# 2217 "gettext.c"
  if ((unsigned long )domainname == (unsigned long )((void *)0)) {
# 2218 "gettext.c"
    return ((char *)((void *)0));
  } else
# 2217 "gettext.c"
  if ((int const )*(domainname + 0) == 0) {
# 2218 "gettext.c"
    return ((char *)((void *)0));
  }
# 2220 "gettext.c"
  binding = _nl_domain_bindings;
  {
# 2220 "gettext.c"
  while (1) {
    while_continue: ;
# 2220 "gettext.c"
    if (! ((unsigned long )binding != (unsigned long )((void *)0))) {
# 2220 "gettext.c"
      goto while_break;
    }
    {
# 2222 "gettext.c"
    tmp = strcmp(domainname, (char const *)binding->domainname);
# 2222 "gettext.c"
    compare = tmp;
    }
# 2223 "gettext.c"
    if (compare == 0) {
# 2225 "gettext.c"
      goto while_break;
    }
# 2226 "gettext.c"
    if (compare < 0) {
# 2229 "gettext.c"
      binding = (struct binding *)((void *)0);
# 2230 "gettext.c"
      goto while_break;
    }
# 2220 "gettext.c"
    binding = binding->next;
  }
  while_break: ;
  }
# 2234 "gettext.c"
  if ((unsigned long )dirname == (unsigned long )((void *)0)) {
# 2236 "gettext.c"
    if ((unsigned long )binding == (unsigned long )((void *)0)) {
# 2236 "gettext.c"
      tmp___0 = (char *)(_nl_default_dirname);
    } else {
# 2236 "gettext.c"
      tmp___0 = binding->dirname;
    }
# 2236 "gettext.c"
    return (tmp___0);
  }
# 2238 "gettext.c"
  if ((unsigned long )binding != (unsigned long )((void *)0)) {
    {
# 2243 "gettext.c"
    tmp___2 = strcmp(dirname, (char const *)binding->dirname);
    }
# 2243 "gettext.c"
    if (tmp___2 != 0) {
      {
# 2247 "gettext.c"
      tmp___1 = strcmp(dirname, _nl_default_dirname);
      }
# 2247 "gettext.c"
      if (tmp___1 == 0) {
# 2248 "gettext.c"
        new_dirname = (char *)(_nl_default_dirname);
      } else {
        {
# 2252 "gettext.c"
        new_dirname = strdup(dirname);
        }
# 2253 "gettext.c"
        if ((unsigned long )new_dirname == (unsigned long )((void *)0)) {
# 2254 "gettext.c"
          return ((char *)((void *)0));
        }
      }
# 2265 "gettext.c"
      if ((unsigned long )binding->dirname != (unsigned long )(_nl_default_dirname)) {
        {
# 2266 "gettext.c"
        free((void *)binding->dirname);
        }
      }
# 2268 "gettext.c"
      binding->dirname = new_dirname;
    }
  } else {
    {
# 2277 "gettext.c"
    tmp___7 = malloc(sizeof(*new_binding));
# 2277 "gettext.c"
    tmp___3 = (int )tmp___7;
# 2277 "gettext.c"
    new_binding = (struct binding *)tmp___3;
    }
# 2280 "gettext.c"
    if ((unsigned long )new_binding == (unsigned long )((void *)0)) {
# 2281 "gettext.c"
      return ((char *)((void *)0));
    }
    {
# 2284 "gettext.c"
    new_binding->domainname = strdup(domainname);
    }
# 2285 "gettext.c"
    if ((unsigned long )new_binding->domainname == (unsigned long )((void *)0)) {
# 2286 "gettext.c"
      return ((char *)((void *)0));
    }
    {
# 2295 "gettext.c"
    tmp___4 = strcmp(dirname, _nl_default_dirname);
    }
# 2295 "gettext.c"
    if (tmp___4 == 0) {
# 2296 "gettext.c"
      new_binding->dirname = (char *)(_nl_default_dirname);
    } else {
      {
# 2300 "gettext.c"
      new_binding->dirname = strdup(dirname);
      }
# 2301 "gettext.c"
      if ((unsigned long )new_binding->dirname == (unsigned long )((void *)0)) {
# 2302 "gettext.c"
        return ((char *)((void *)0));
      }
    }
# 2313 "gettext.c"
    if ((unsigned long )_nl_domain_bindings == (unsigned long )((void *)0)) {
# 2316 "gettext.c"
      new_binding->next = _nl_domain_bindings;
# 2317 "gettext.c"
      _nl_domain_bindings = new_binding;
    } else {
      {
# 2313 "gettext.c"
      tmp___6 = strcmp(domainname, (char const *)_nl_domain_bindings->domainname);
      }
# 2313 "gettext.c"
      if (tmp___6 < 0) {
# 2316 "gettext.c"
        new_binding->next = _nl_domain_bindings;
# 2317 "gettext.c"
        _nl_domain_bindings = new_binding;
      } else {
# 2321 "gettext.c"
        binding = _nl_domain_bindings;
        {
# 2322 "gettext.c"
        while (1) {
          while_continue___0: ;
# 2322 "gettext.c"
          if ((unsigned long )binding->next != (unsigned long )((void *)0)) {
            {
# 2322 "gettext.c"
            tmp___5 = strcmp(domainname, (char const *)(binding->next)->domainname);
            }
# 2322 "gettext.c"
            if (! (tmp___5 > 0)) {
# 2322 "gettext.c"
              goto while_break___0;
            }
          } else {
# 2322 "gettext.c"
            goto while_break___0;
          }
# 2324 "gettext.c"
          binding = binding->next;
        }
        while_break___0: ;
        }
# 2326 "gettext.c"
        new_binding->next = binding->next;
# 2327 "gettext.c"
        binding->next = new_binding;
      }
    }
# 2330 "gettext.c"
    binding = new_binding;
  }
# 2333 "gettext.c"
  return (binding->dirname);
}
}
# 2369 "gettext.c"
static char *dgettext__(char const *domainname , char const *msgid )
{
  char *tmp ;

  {
  {
# 2374 "gettext.c"
  tmp = dcgettext__(domainname, msgid, 5);
  }
# 2374 "gettext.c"
  return (tmp);
}
}
# 2421 "gettext.c"
static char *gettext__(char const *msgid )
{
  char *tmp ;

  {
  {
# 2425 "gettext.c"
  tmp = dgettext__((char const *)((void *)0), msgid);
  }
# 2425 "gettext.c"
  return (tmp);
}
}
# 2476 "gettext.c"
static char *textdomain__(char const *domainname )
{
  char *old ;
  char *tmp ;
  int tmp___0 ;

  {
# 2483 "gettext.c"
  if ((unsigned long )domainname == (unsigned long )((void *)0)) {
# 2484 "gettext.c"
    return ((char *)_nl_current_default_domain);
  }
# 2486 "gettext.c"
  old = (char *)_nl_current_default_domain;
# 2489 "gettext.c"
  if ((int const )*(domainname + 0) == 0) {
# 2491 "gettext.c"
    _nl_current_default_domain = _nl_default_default_domain;
  } else {
    {
# 2489 "gettext.c"
    tmp___0 = strcmp(domainname, _nl_default_default_domain);
    }
# 2489 "gettext.c"
    if (tmp___0 == 0) {
# 2491 "gettext.c"
      _nl_current_default_domain = _nl_default_default_domain;
    } else {
      {
# 2498 "gettext.c"
      tmp = strdup(domainname);
# 2498 "gettext.c"
      _nl_current_default_domain = (char const *)tmp;
      }
    }
  }
# 2508 "gettext.c"
  if ((unsigned long )old != (unsigned long )(_nl_default_default_domain)) {
    {
# 2509 "gettext.c"
    free((void *)old);
    }
  }
# 2511 "gettext.c"
  return ((char *)_nl_current_default_domain);
}
}
# 2532 "gettext.c"
char *bindtextdomain(char const *domainname , char const *dirname )
{
  char *tmp ;

  {
  {
# 2537 "gettext.c"
  tmp = bindtextdomain__(domainname, dirname);
  }
# 2537 "gettext.c"
  return (tmp);
}
}
# 2540 "gettext.c"
char *dcgettext(char const *domainname , char const *msgid , int category )
{
  char *tmp ;

  {
  {
# 2546 "gettext.c"
  tmp = dcgettext__(domainname, msgid, category);
  }
# 2546 "gettext.c"
  return (tmp);
}
}
# 2549 "gettext.c"
char *dgettext(char const *domainname , char const *msgid )
{
  char *tmp ;

  {
  {
# 2554 "gettext.c"
  tmp = dgettext__(domainname, msgid);
  }
# 2554 "gettext.c"
  return (tmp);
}
}
# 2557 "gettext.c"
char *gettext(char const *msgid )
{
  char *tmp ;

  {
  {
# 2561 "gettext.c"
  tmp = gettext__(msgid);
  }
# 2561 "gettext.c"
  return (tmp);
}
}
# 2564 "gettext.c"
char *textdomain(char const *domainname )
{
  char *tmp ;

  {
  {
# 2568 "gettext.c"
  tmp = textdomain__(domainname);
  }
# 2568 "gettext.c"
  return (tmp);
}
}
