/* builtins.c -- the built in shell commands. */

/* This file is manufactured by ./mkbuiltins, and should not be
   edited by hand.  See the source to mkbuiltins for details. */

/* Copyright (C) 1987, 1991, 1992 Free Software Foundation, Inc.

   This file is part of GNU Bash, the Bourne Again SHell.

   Bash is free software; you can redistribute it and/or modify it
   under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2, or (at your option)
   any later version.

   Bash is distributed in the hope that it will be useful, but WITHOUT
   ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
   or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public
   License for more details.

   You should have received a copy of the GNU General Public License
   along with Bash; see the file COPYING.  If not, write to the Free
   Software Foundation, 59 Temple Place, Suite 330, Boston, MA 02111 USA. */

/* The list of shell builtins.  Each element is name, function, flags,
   long-doc, short-doc.  The long-doc field contains a pointer to an array
   of help lines.  The function takes a WORD_LIST *; the first word in the
   list is the first arg to the command.  The list has already had word
   expansion performed.

   Functions which need to look at only the simple commands (e.g.
   the enable_builtin ()), should ignore entries where
   (array[i].function == (Function *)NULL).  Such entries are for
   the list of shell reserved control structures, like `if' and `while'.
   The end of the list is denoted with a NULL name field. */

#include "../builtins.h"
#include "builtext.h"

struct builtin static_shell_builtins[] = {
#if defined (ALIAS)
  { "alias", alias_builtin, BUILTIN_ENABLED | STATIC_BUILTIN | ASSIGNMENT_BUILTIN, alias_doc,
     "alias [-p] [name[=value] ... ]", (char *)NULL },
#endif /* ALIAS */
#if defined (ALIAS)
  { "unalias", unalias_builtin, BUILTIN_ENABLED | STATIC_BUILTIN, unalias_doc,
     "unalias [-a] [name ...]", (char *)NULL },
#endif /* ALIAS */
#if defined (READLINE)
  { "bind", bind_builtin, BUILTIN_ENABLED | STATIC_BUILTIN, bind_doc,
     "bind [-lpvsPVS] [-m keymap] [-f filename] [-q name] [-u name] [-r keyseq] [-x keyseq:shell-command] [keyseq:readline-function]", (char *)NULL },
#endif /* READLINE */
  { "break", break_builtin, BUILTIN_ENABLED | STATIC_BUILTIN | SPECIAL_BUILTIN, break_doc,
     "break [n]", (char *)NULL },
  { "continue", continue_builtin, BUILTIN_ENABLED | STATIC_BUILTIN | SPECIAL_BUILTIN, continue_doc,
     "continue [n]", (char *)NULL },
  { "builtin", builtin_builtin, BUILTIN_ENABLED | STATIC_BUILTIN, builtin_doc,
     "builtin [shell-builtin [arg ...]]", (char *)NULL },
  { "cd", cd_builtin, BUILTIN_ENABLED | STATIC_BUILTIN, cd_doc,
     "cd [-PL] [dir]", (char *)NULL },
  { "pwd", pwd_builtin, BUILTIN_ENABLED | STATIC_BUILTIN, pwd_doc,
     "pwd [-PL]", (char *)NULL },
  { ":", colon_builtin, BUILTIN_ENABLED | STATIC_BUILTIN | SPECIAL_BUILTIN, colon_builtin_doc,
     ":", (char *)NULL },
  { "true", colon_builtin, BUILTIN_ENABLED | STATIC_BUILTIN, true_builtin_doc,
     "true", (char *)NULL },
  { "false", false_builtin, BUILTIN_ENABLED | STATIC_BUILTIN, false_builtin_doc,
     "false", (char *)NULL },
  { "command", command_builtin, BUILTIN_ENABLED | STATIC_BUILTIN, command_doc,
     "command [-pVv] command [arg ...]", (char *)NULL },
  { "declare", declare_builtin, BUILTIN_ENABLED | STATIC_BUILTIN | ASSIGNMENT_BUILTIN, declare_doc,
     "declare [-afFrxi] [-p] name[=value] ...", (char *)NULL },
  { "typeset", declare_builtin, BUILTIN_ENABLED | STATIC_BUILTIN | ASSIGNMENT_BUILTIN, typeset_doc,
     "typeset [-afFrxi] [-p] name[=value] ...", (char *)NULL },
  { "local", local_builtin, BUILTIN_ENABLED | STATIC_BUILTIN | ASSIGNMENT_BUILTIN, local_doc,
     "local name[=value] ...", (char *)NULL },
#if defined (V9_ECHO)
  { "echo", echo_builtin, BUILTIN_ENABLED | STATIC_BUILTIN, echo_doc,
     "echo [-neE] [arg ...]", (char *)NULL },
#endif /* V9_ECHO */
#if !defined (V9_ECHO)
  { "echo", echo_builtin, BUILTIN_ENABLED | STATIC_BUILTIN, echo_doc,
     "echo [-n] [arg ...]", (char *)NULL },
#endif /* !V9_ECHO */
  { "enable", enable_builtin, BUILTIN_ENABLED | STATIC_BUILTIN, enable_doc,
     "enable [-pnds] [-a] [-f filename] [name ...]", (char *)NULL },
  { "eval", eval_builtin, BUILTIN_ENABLED | STATIC_BUILTIN | SPECIAL_BUILTIN, eval_doc,
     "eval [arg ...]", (char *)NULL },
  { "getopts", getopts_builtin, BUILTIN_ENABLED | STATIC_BUILTIN, getopts_doc,
     "getopts optstring name [arg]", (char *)NULL },
  { "exec", exec_builtin, BUILTIN_ENABLED | STATIC_BUILTIN | SPECIAL_BUILTIN, exec_doc,
     "exec [-cl] [-a name] file [redirection ...]", (char *)NULL },
  { "exit", exit_builtin, BUILTIN_ENABLED | STATIC_BUILTIN | SPECIAL_BUILTIN, exit_doc,
     "exit [n]", (char *)NULL },
  { "logout", logout_builtin, BUILTIN_ENABLED | STATIC_BUILTIN, logout_doc,
     "logout", (char *)NULL },
#if defined (HISTORY)
  { "fc", fc_builtin, BUILTIN_ENABLED | STATIC_BUILTIN, fc_doc,
     "fc [-e ename] [-nlr] [first] [last] or fc -s [pat=rep] [cmd]", (char *)NULL },
#endif /* HISTORY */
#if defined (JOB_CONTROL)
  { "fg", fg_builtin, BUILTIN_ENABLED | STATIC_BUILTIN, fg_doc,
     "fg [job_spec]", (char *)NULL },
#endif /* JOB_CONTROL */
#if defined (JOB_CONTROL)
  { "bg", bg_builtin, BUILTIN_ENABLED | STATIC_BUILTIN, bg_doc,
     "bg [job_spec]", (char *)NULL },
#endif /* JOB_CONTROL */
  { "hash", hash_builtin, BUILTIN_ENABLED | STATIC_BUILTIN, hash_doc,
     "hash [-r] [-p pathname] [name ...]", (char *)NULL },
#if defined (HELP_BUILTIN)
  { "help", help_builtin, BUILTIN_ENABLED | STATIC_BUILTIN, help_doc,
     "help [-s] [pattern ...]", (char *)NULL },
#endif /* HELP_BUILTIN */
#if defined (HISTORY)
  { "history", history_builtin, BUILTIN_ENABLED | STATIC_BUILTIN, history_doc,
     "history [-c] [-d offset] [n] or history -awrn [filename] or history -ps arg [arg...]", (char *)NULL },
#endif /* HISTORY */
#if defined (JOB_CONTROL)
  { "jobs", jobs_builtin, BUILTIN_ENABLED | STATIC_BUILTIN, jobs_doc,
     "jobs [-lnprs] [jobspec ...] or jobs -x command [args]", (char *)NULL },
#endif /* JOB_CONTROL */
#if defined (JOB_CONTROL)
  { "disown", disown_builtin, BUILTIN_ENABLED | STATIC_BUILTIN, disown_doc,
     "disown [-h] [-ar] [jobspec ...]", (char *)NULL },
#endif /* JOB_CONTROL */
#if defined (JOB_CONTROL)
  { "kill", kill_builtin, BUILTIN_ENABLED | STATIC_BUILTIN, kill_doc,
     "kill [-s sigspec | -n signum | -sigspec] [pid | job]... or kill -l [sigspec]", (char *)NULL },
#endif /* JOB_CONTROL */
  { "let", let_builtin, BUILTIN_ENABLED | STATIC_BUILTIN, let_doc,
     "let arg [arg ...]", (char *)NULL },
  { "read", read_builtin, BUILTIN_ENABLED | STATIC_BUILTIN, read_doc,
     "read [-ers] [-t timeout] [-p prompt] [-a array] [-n nchars] [-d delim] [name ...]", (char *)NULL },
  { "return", return_builtin, BUILTIN_ENABLED | STATIC_BUILTIN | SPECIAL_BUILTIN, return_doc,
     "return [n]", (char *)NULL },
  { "set", set_builtin, BUILTIN_ENABLED | STATIC_BUILTIN | SPECIAL_BUILTIN, set_doc,
     "set [--abefhkmnptuvxBCHP] [-o option] [arg ...]", (char *)NULL },
  { "unset", unset_builtin, BUILTIN_ENABLED | STATIC_BUILTIN | SPECIAL_BUILTIN, unset_doc,
     "unset [-f] [-v] [name ...]", (char *)NULL },
  { "export", export_builtin, BUILTIN_ENABLED | STATIC_BUILTIN | SPECIAL_BUILTIN | ASSIGNMENT_BUILTIN, export_doc,
     "export [-nf] [name ...] or export -p", (char *)NULL },
  { "readonly", readonly_builtin, BUILTIN_ENABLED | STATIC_BUILTIN | SPECIAL_BUILTIN | ASSIGNMENT_BUILTIN, readonly_doc,
     "readonly [-anf] [name ...] or readonly -p", (char *)NULL },
  { "shift", shift_builtin, BUILTIN_ENABLED | STATIC_BUILTIN | SPECIAL_BUILTIN, shift_doc,
     "shift [n]", (char *)NULL },
  { "source", source_builtin, BUILTIN_ENABLED | STATIC_BUILTIN | SPECIAL_BUILTIN, source_doc,
     "source filename", (char *)NULL },
  { ".", source_builtin, BUILTIN_ENABLED | STATIC_BUILTIN | SPECIAL_BUILTIN, dot_doc,
     ". filename", (char *)NULL },
#if defined (JOB_CONTROL)
  { "suspend", suspend_builtin, BUILTIN_ENABLED | STATIC_BUILTIN, suspend_doc,
     "suspend [-f]", (char *)NULL },
#endif /* JOB_CONTROL */
  { "test", test_builtin, BUILTIN_ENABLED | STATIC_BUILTIN, test_doc,
     "test [expr]", (char *)NULL },
  { "[", test_builtin, BUILTIN_ENABLED | STATIC_BUILTIN, test_bracket_doc,
     "[ arg... ]", (char *)NULL },
  { "times", times_builtin, BUILTIN_ENABLED | STATIC_BUILTIN, times_doc,
     "times", (char *)NULL },
  { "trap", trap_builtin, BUILTIN_ENABLED | STATIC_BUILTIN | SPECIAL_BUILTIN, trap_doc,
     "trap [arg] [signal_spec ...] or trap -l", (char *)NULL },
  { "type", type_builtin, BUILTIN_ENABLED | STATIC_BUILTIN, type_doc,
     "type [-apt] name [name ...]", (char *)NULL },
#if !defined (_MINIX)
  { "ulimit", ulimit_builtin, BUILTIN_ENABLED | STATIC_BUILTIN, ulimit_doc,
     "ulimit [-SHacdflmnpstuv] [limit]", (char *)NULL },
#endif /* !_MINIX */
  { "umask", umask_builtin, BUILTIN_ENABLED | STATIC_BUILTIN, umask_doc,
     "umask [-p] [-S] [mode]", (char *)NULL },
#if defined (JOB_CONTROL)
  { "wait", wait_builtin, BUILTIN_ENABLED | STATIC_BUILTIN, wait_doc,
     "wait [n]", (char *)NULL },
#endif /* JOB_CONTROL */
#if !defined (JOB_CONTROL)
  { "wait", wait_builtin, BUILTIN_ENABLED | STATIC_BUILTIN, wait_doc,
     "wait [n]", (char *)NULL },
#endif /* !JOB_CONTROL */
  { "for", (Function *)0x0, BUILTIN_ENABLED | STATIC_BUILTIN, for_doc,
     "for NAME [in WORDS ... ;] do COMMANDS; done", (char *)NULL },
  { "select", (Function *)0x0, BUILTIN_ENABLED | STATIC_BUILTIN, select_doc,
     "select NAME [in WORDS ... ;] do COMMANDS; done", (char *)NULL },
  { "time", (Function *)0x0, BUILTIN_ENABLED | STATIC_BUILTIN, time_doc,
     "time [-p] PIPELINE", (char *)NULL },
  { "case", (Function *)0x0, BUILTIN_ENABLED | STATIC_BUILTIN, case_doc,
     "case WORD in [PATTERN [| PATTERN]...) COMMANDS ;;]... esac", (char *)NULL },
  { "if", (Function *)0x0, BUILTIN_ENABLED | STATIC_BUILTIN, if_doc,
     "if COMMANDS; then COMMANDS; [ elif COMMANDS; then COMMANDS; ]... [ else COMMANDS; ] fi", (char *)NULL },
  { "while", (Function *)0x0, BUILTIN_ENABLED | STATIC_BUILTIN, while_doc,
     "while COMMANDS; do COMMANDS; done", (char *)NULL },
  { "until", (Function *)0x0, BUILTIN_ENABLED | STATIC_BUILTIN, until_doc,
     "until COMMANDS; do COMMANDS; done", (char *)NULL },
  { "function", (Function *)0x0, BUILTIN_ENABLED | STATIC_BUILTIN, function_doc,
     "function NAME { COMMANDS ; } or NAME () { COMMANDS ; }", (char *)NULL },
  { "{ ... }", (Function *)0x0, BUILTIN_ENABLED | STATIC_BUILTIN, grouping_braces_doc,
     "{ COMMANDS ; }", (char *)NULL },
  { "%", (Function *)0x0, BUILTIN_ENABLED | STATIC_BUILTIN, fg_percent_doc,
     "%[DIGITS | WORD] [&]", (char *)NULL },
  { "variables", (Function *)0x0, BUILTIN_ENABLED | STATIC_BUILTIN, variable_help_doc,
     "variables - Some variable names and meanings", (char *)NULL },
#if defined (PUSHD_AND_POPD)
  { "pushd", pushd_builtin, BUILTIN_ENABLED | STATIC_BUILTIN, pushd_doc,
     "pushd [dir | +N | -N] [-n]", (char *)NULL },
#endif /* PUSHD_AND_POPD */
#if defined (PUSHD_AND_POPD)
  { "popd", popd_builtin, BUILTIN_ENABLED | STATIC_BUILTIN, popd_doc,
     "popd [+N | -N] [-n]", (char *)NULL },
#endif /* PUSHD_AND_POPD */
#if defined (PUSHD_AND_POPD)
  { "dirs", dirs_builtin, BUILTIN_ENABLED | STATIC_BUILTIN, dirs_doc,
     "dirs [-clpv] [+N] [-N]", (char *)NULL },
#endif /* PUSHD_AND_POPD */
  { "shopt", shopt_builtin, BUILTIN_ENABLED | STATIC_BUILTIN, shopt_builtin_doc,
     "shopt [-pqsu] [-o long-option] optname [optname...]", (char *)NULL },
  { "printf", printf_builtin, BUILTIN_ENABLED | STATIC_BUILTIN, printf_doc,
     "printf format [arguments]", (char *)NULL },
#if defined (PROGRAMMABLE_COMPLETION)
  { "complete", complete_builtin, BUILTIN_ENABLED | STATIC_BUILTIN, complete_doc,
     "complete [-abcdefjkvu] [-pr] [-o option] [-A action] [-G globpat] [-W wordlist] [-P prefix] [-S suffix] [-X filterpat] [-F function] [-C command] [name ...]", (char *)NULL },
#endif /* PROGRAMMABLE_COMPLETION */
#if defined (PROGRAMMABLE_COMPLETION)
  { "compgen", compgen_builtin, BUILTIN_ENABLED | STATIC_BUILTIN, compgen_doc,
     "compgen [-abcdefjkvu] [-o option] [-A action] [-G globpat] [-W wordlist] [-P prefix] [-S suffix] [-X filterpat] [-F function] [-C command] [word]", (char *)NULL },
#endif /* PROGRAMMABLE_COMPLETION */
  { (char *)0x0, (Function *)0x0, 0, (char **)0x0, (char *)0x0 }
};

struct builtin *shell_builtins = static_shell_builtins;
struct builtin *current_builtin;

int num_shell_builtins =
	sizeof (static_shell_builtins) / sizeof (struct builtin) - 1;
#if defined (ALIAS)
char *alias_doc[] = {
#if defined (HELP_BUILTIN)
  "`alias' with no arguments or with the -p option prints the list",
  "of aliases in the form alias NAME=VALUE on standard output.",
  "Otherwise, an alias is defined for each NAME whose VALUE is given.",
  "A trailing space in VALUE causes the next word to be checked for",
  "alias substitution when the alias is expanded.  Alias returns",
  "true unless a NAME is given for which no alias has been defined.",
#endif /* HELP_BUILTIN */
  (char *)NULL
};
#endif /* ALIAS */
#if defined (ALIAS)
char *unalias_doc[] = {
#if defined (HELP_BUILTIN)
  "Remove NAMEs from the list of defined aliases.  If the -a option is given,",
  "then remove all alias definitions.",
#endif /* HELP_BUILTIN */
  (char *)NULL
};
#endif /* ALIAS */
#if defined (READLINE)
char *bind_doc[] = {
#if defined (HELP_BUILTIN)
  "Bind a key sequence to a Readline function, or to a macro.  The",
  "syntax is equivalent to that found in ~/.inputrc, but must be",
  "passed as a single argument: bind '\"\\C-x\\C-r\": re-read-init-file'.",
  "Arguments we accept:",
  "  -m  keymap         Use `keymap' as the keymap for the duration of this",
  "                     command.  Acceptable keymap names are emacs,",
  "                     emacs-standard, emacs-meta, emacs-ctlx, vi, vi-move,",
  "                     vi-command, and vi-insert.",
  "  -l                 List names of functions.",
  "  -P                 List function names and bindings.",
  "  -p                 List functions and bindings in a form that can be",
  "                     reused as input.",
  "  -r  keyseq         Remove the binding for KEYSEQ.",
  "  -x  keyseq:shell-command	Cause SHELL-COMMAND to be executed when KEYSEQ",
  "				is entered.",
  "  -f  filename       Read key bindings from FILENAME.",
  "  -q  function-name  Query about which keys invoke the named function.",
  "  -u  function-name  Unbind all keys which are bound to the named function.",
  "  -V                 List variable names and values",
  "  -v                 List variable names and values in a form that can",
  "                     be reused as input.",
  "  -S                 List key sequences that invoke macros and their values",
  "  -s                 List key sequences that invoke macros and their values in",
  "                     a form that can be reused as input.",
#endif /* HELP_BUILTIN */
  (char *)NULL
};
#endif /* READLINE */
char *break_doc[] = {
#if defined (HELP_BUILTIN)
  "Exit from within a FOR, WHILE or UNTIL loop.  If N is specified,",
  "break N levels.",
#endif /* HELP_BUILTIN */
  (char *)NULL
};
char *continue_doc[] = {
#if defined (HELP_BUILTIN)
  "Resume the next iteration of the enclosing FOR, WHILE or UNTIL loop.",
  "If N is specified, resume at the N-th enclosing loop.",
#endif /* HELP_BUILTIN */
  (char *)NULL
};
char *builtin_doc[] = {
#if defined (HELP_BUILTIN)
  "Run a shell builtin.  This is useful when you wish to rename a",
  "shell builtin to be a function, but need the functionality of the",
  "builtin within the function itself.",
#endif /* HELP_BUILTIN */
  (char *)NULL
};
char *cd_doc[] = {
#if defined (HELP_BUILTIN)
  "Change the current directory to DIR.  The variable $HOME is the",
  "default DIR.  The variable CDPATH defines the search path for",
  "the directory containing DIR.  Alternative directory names in CDPATH",
  "are separated by a colon (:).  A null directory name is the same as",
  "the current directory, i.e. `.'.  If DIR begins with a slash (/),",
  "then CDPATH is not used.  If the directory is not found, and the",
  "shell option `cdable_vars' is set, then try the word as a variable",
  "name.  If that variable has a value, then cd to the value of that",
  "variable.  The -P option says to use the physical directory structure",
  "instead of following symbolic links; the -L option forces symbolic links",
  "to be followed.",
#endif /* HELP_BUILTIN */
  (char *)NULL
};
char *pwd_doc[] = {
#if defined (HELP_BUILTIN)
  "Print the current working directory.  With the -P option, pwd prints",
  "the physical directory, without any symbolic links; the -L option",
  "makes pwd follow symbolic links.",
#endif /* HELP_BUILTIN */
  (char *)NULL
};
char *colon_builtin_doc[] = {
#if defined (HELP_BUILTIN)
  "No effect; the command does nothing.  A zero exit code is returned.",
#endif /* HELP_BUILTIN */
  (char *)NULL
};
char *true_builtin_doc[] = {
#if defined (HELP_BUILTIN)
  "Return a successful result.",
#endif /* HELP_BUILTIN */
  (char *)NULL
};
char *false_builtin_doc[] = {
#if defined (HELP_BUILTIN)
  "Return an unsuccessful result.",
#endif /* HELP_BUILTIN */
  (char *)NULL
};
char *command_doc[] = {
#if defined (HELP_BUILTIN)
  "Runs COMMAND with ARGS ignoring shell functions.  If you have a shell",
  "function called `ls', and you wish to call the command `ls', you can",
  "say \"command ls\".  If the -p option is given, a default value is used",
  "for PATH that is guaranteed to find all of the standard utilities.  If",
  "the -V or -v option is given, a string is printed describing COMMAND.",
  "The -V option produces a more verbose description.",
#endif /* HELP_BUILTIN */
  (char *)NULL
};
char *declare_doc[] = {
#if defined (HELP_BUILTIN)
  "Declare variables and/or give them attributes.  If no NAMEs are",
  "given, then display the values of variables instead.  The -p option",
  "will display the attributes and values of each NAME.",
  "",
  "The flags are:",
  "",
  "  -a	to make NAMEs arrays (if supported)",
  "  -f	to select from among function names only",
  "  -F	to display function names without definitions",
  "  -r	to make NAMEs readonly",
  "  -x	to make NAMEs export",
  "  -i	to make NAMEs have the `integer' attribute set",
  "",
  "Variables with the integer attribute have arithmetic evaluation (see",
  "`let') done when the variable is assigned to.",
  "",
  "When displaying values of variables, -f displays a function's name",
  "and definition.  The -F option restricts the display to function",
  "name only.",
  "",
  "Using `+' instead of `-' turns off the given attribute instead.  When",
  "used in a function, makes NAMEs local, as with the `local' command.",
#endif /* HELP_BUILTIN */
  (char *)NULL
};
char *typeset_doc[] = {
#if defined (HELP_BUILTIN)
  "Obsolete.  See `declare'.",
#endif /* HELP_BUILTIN */
  (char *)NULL
};
char *local_doc[] = {
#if defined (HELP_BUILTIN)
  "Create a local variable called NAME, and give it VALUE.  LOCAL",
  "can only be used within a function; it makes the variable NAME",
  "have a visible scope restricted to that function and its children.",
#endif /* HELP_BUILTIN */
  (char *)NULL
};
#if defined (V9_ECHO)
char *echo_doc[] = {
#if defined (HELP_BUILTIN)
  "Output the ARGs.  If -n is specified, the trailing newline is",
  "suppressed.  If the -e option is given, interpretation of the",
  "following backslash-escaped characters is turned on:",
  "	\\a	alert (bell)",
  "	\\b	backspace",
  "	\\c	suppress trailing newline",
  "	\\E	escape character",
  "	\\f	form feed",
  "	\\n	new line",
  "	\\r	carriage return",
  "	\\t	horizontal tab",
  "	\\v	vertical tab",
  "	\\\\	backslash",
  "	\\num	the character whose ASCII code is NUM (octal).",
  "",
  "You can explicitly turn off the interpretation of the above characters",
  "with the -E option.",
#endif /* HELP_BUILTIN */
  (char *)NULL
};
#endif /* V9_ECHO */
#if !defined (V9_ECHO)
char *echo_doc[] = {
#if defined (HELP_BUILTIN)
  "Output the ARGs.  If -n is specified, the trailing newline is suppressed.",
#endif /* HELP_BUILTIN */
  (char *)NULL
};
#endif /* !V9_ECHO */
char *enable_doc[] = {
#if defined (HELP_BUILTIN)
  "Enable and disable builtin shell commands.  This allows",
  "you to use a disk command which has the same name as a shell",
  "builtin without specifying a full pathname.  If -n is used, the",
  "NAMEs become disabled; otherwise NAMEs are enabled.  For example,",
  "to use the `test' found in $PATH instead of the shell builtin",
  "version, type `enable -n test'.  On systems supporting dynamic",
  "loading, the -f option may be used to load new builtins from the",
  "shared object FILENAME.  The -d option will delete a builtin",
  "previously loaded with -f.  If no non-option names are given, or",
  "the -p option is supplied, a list of builtins is printed.  The",
  "-a option means to print every builtin with an indication of whether",
  "or not it is enabled.  The -s option restricts the output to the POSIX.2",
  "`special' builtins.  The -n option displays a list of all disabled builtins.",
#endif /* HELP_BUILTIN */
  (char *)NULL
};
char *eval_doc[] = {
#if defined (HELP_BUILTIN)
  "Read ARGs as input to the shell and execute the resulting command(s).",
#endif /* HELP_BUILTIN */
  (char *)NULL
};
char *getopts_doc[] = {
#if defined (HELP_BUILTIN)
  "Getopts is used by shell procedures to parse positional parameters.",
  "",
  "OPTSTRING contains the option letters to be recognized; if a letter",
  "is followed by a colon, the option is expected to have an argument,",
  "which should be separated from it by white space.",
  "",
  "Each time it is invoked, getopts will place the next option in the",
  "shell variable $name, initializing name if it does not exist, and",
  "the index of the next argument to be processed into the shell",
  "variable OPTIND.  OPTIND is initialized to 1 each time the shell or",
  "a shell script is invoked.  When an option requires an argument,",
  "getopts places that argument into the shell variable OPTARG.",
  "",
  "getopts reports errors in one of two ways.  If the first character",
  "of OPTSTRING is a colon, getopts uses silent error reporting.  In",
  "this mode, no error messages are printed.  If an illegal option is",
  "seen, getopts places the option character found into OPTARG.  If a",
  "required argument is not found, getopts places a ':' into NAME and",
  "sets OPTARG to the option character found.  If getopts is not in",
  "silent mode, and an illegal option is seen, getopts places '?' into",
  "NAME and unsets OPTARG.  If a required option is not found, a '?'",
  "is placed in NAME, OPTARG is unset, and a diagnostic message is",
  "printed.",
  "",
  "If the shell variable OPTERR has the value 0, getopts disables the",
  "printing of error messages, even if the first character of",
  "OPTSTRING is not a colon.  OPTERR has the value 1 by default.",
  "",
  "Getopts normally parses the positional parameters ($0 - $9), but if",
  "more arguments are given, they are parsed instead.",
#endif /* HELP_BUILTIN */
  (char *)NULL
};
char *exec_doc[] = {
#if defined (HELP_BUILTIN)
  "Exec FILE, replacing this shell with the specified program.",
  "If FILE is not specified, the redirections take effect in this",
  "shell.  If the first argument is `-l', then place a dash in the",
  "zeroth arg passed to FILE, as login does.  If the `-c' option",
  "is supplied, FILE is executed with a null environment.  The `-a'",
  "option means to make set argv[0] of the executed process to NAME.",
  "If the file cannot be executed and the shell is not interactive,",
  "then the shell exits, unless the shell option `execfail' is set.",
#endif /* HELP_BUILTIN */
  (char *)NULL
};
char *exit_doc[] = {
#if defined (HELP_BUILTIN)
  "Exit the shell with a status of N.  If N is omitted, the exit status",
  "is that of the last command executed.",
#endif /* HELP_BUILTIN */
  (char *)NULL
};
char *logout_doc[] = {
#if defined (HELP_BUILTIN)
  "Logout of a login shell.",
#endif /* HELP_BUILTIN */
  (char *)NULL
};
#if defined (HISTORY)
char *fc_doc[] = {
#if defined (HELP_BUILTIN)
  "fc is used to list or edit and re-execute commands from the history list.",
  "FIRST and LAST can be numbers specifying the range, or FIRST can be a",
  "string, which means the most recent command beginning with that",
  "string.",
  "",
  "   -e ENAME selects which editor to use.  Default is FCEDIT, then EDITOR,",
  "      then vi.",
  "",
  "   -l means list lines instead of editing.",
  "   -n means no line numbers listed.",
  "   -r means reverse the order of the lines (making it newest listed first).",
  "",
  "With the `fc -s [pat=rep ...] [command]' format, the command is",
  "re-executed after the substitution OLD=NEW is performed.",
  "",
  "A useful alias to use with this is r='fc -s', so that typing `r cc'",
  "runs the last command beginning with `cc' and typing `r' re-executes",
  "the last command.",
#endif /* HELP_BUILTIN */
  (char *)NULL
};
#endif /* HISTORY */
#if defined (JOB_CONTROL)
char *fg_doc[] = {
#if defined (HELP_BUILTIN)
  "Place JOB_SPEC in the foreground, and make it the current job.  If",
  "JOB_SPEC is not present, the shell's notion of the current job is",
  "used.",
#endif /* HELP_BUILTIN */
  (char *)NULL
};
#endif /* JOB_CONTROL */
#if defined (JOB_CONTROL)
char *bg_doc[] = {
#if defined (HELP_BUILTIN)
  "Place JOB_SPEC in the background, as if it had been started with",
  "`&'.  If JOB_SPEC is not present, the shell's notion of the current",
  "job is used.",
#endif /* HELP_BUILTIN */
  (char *)NULL
};
#endif /* JOB_CONTROL */
char *hash_doc[] = {
#if defined (HELP_BUILTIN)
  "For each NAME, the full pathname of the command is determined and",
  "remembered.  If the -p option is supplied, PATHNAME is used as the",
  "full pathname of NAME, and no path search is performed.  The -r",
  "option causes the shell to forget all remembered locations.  If no",
  "arguments are given, information about remembered commands is displayed.",
#endif /* HELP_BUILTIN */
  (char *)NULL
};
#if defined (HELP_BUILTIN)
char *help_doc[] = {
#if defined (HELP_BUILTIN)
  "Display helpful information about builtin commands.  If PATTERN is",
  "specified, gives detailed help on all commands matching PATTERN,",
  "otherwise a list of the builtins is printed.  The -s option",
  "restricts the output for each builtin command matching PATTERN to",
  "a short usage synopsis.",
#endif /* HELP_BUILTIN */
  (char *)NULL
};
#endif /* HELP_BUILTIN */
#if defined (HISTORY)
char *history_doc[] = {
#if defined (HELP_BUILTIN)
  "Display the history list with line numbers.  Lines listed with",
  "with a `*' have been modified.  Argument of N says to list only",
  "the last N lines.  The `-c' option causes the history list to be",
  "cleared by deleting all of the entries.  The `-d' option deletes",
  "the history entry at offset OFFSET.  The `-w' option writes out the",
  "current history to the history file;  `-r' means to read the file and",
  "append the contents to the history list instead.  `-a' means",
  "to append history lines from this session to the history file.",
  "Argument `-n' means to read all history lines not already read",
  "from the history file and append them to the history list.  If",
  "FILENAME is given, then that is used as the history file else",
  "if $HISTFILE has a value, that is used, else ~/.bash_history.",
  "If the -s option is supplied, the non-option ARGs are appended to",
  "the history list as a single entry.  The -p option means to perform",
  "history expansion on each ARG and display the result, without storing",
  "anything in the history list.",
#endif /* HELP_BUILTIN */
  (char *)NULL
};
#endif /* HISTORY */
#if defined (JOB_CONTROL)
char *jobs_doc[] = {
#if defined (HELP_BUILTIN)
  "Lists the active jobs.  The -l option lists process id's in addition",
  "to the normal information; the -p option lists process id's only.",
  "If -n is given, only processes that have changed status since the last",
  "notification are printed.  JOBSPEC restricts output to that job.  The",
  "-r and -s options restrict output to running and stopped jobs only,",
  "respectively.  Without options, the status of all active jobs is",
  "printed.  If -x is given, COMMAND is run after all job specifications",
  "that appear in ARGS have been replaced with the process ID of that job's",
  "process group leader.",
#endif /* HELP_BUILTIN */
  (char *)NULL
};
#endif /* JOB_CONTROL */
#if defined (JOB_CONTROL)
char *disown_doc[] = {
#if defined (HELP_BUILTIN)
  "By default, removes each JOBSPEC argument from the table of active jobs.",
  "If the -h option is given, the job is not removed from the table, but is",
  "marked so that SIGHUP is not sent to the job if the shell receives a",
  "SIGHUP.  The -a option, when JOBSPEC is not supplied, means to remove all",
  "jobs from the job table; the -r option means to remove only running jobs.",
#endif /* HELP_BUILTIN */
  (char *)NULL
};
#endif /* JOB_CONTROL */
#if defined (JOB_CONTROL)
char *kill_doc[] = {
#if defined (HELP_BUILTIN)
  "Send the processes named by PID (or JOB) the signal SIGSPEC.  If",
  "SIGSPEC is not present, then SIGTERM is assumed.  An argument of `-l'",
  "lists the signal names; if arguments follow `-l' they are assumed to",
  "be signal numbers for which names should be listed.  Kill is a shell",
  "builtin for two reasons: it allows job IDs to be used instead of",
  "process IDs, and, if you have reached the limit on processes that",
  "you can create, you don't have to start a process to kill another one.",
#endif /* HELP_BUILTIN */
  (char *)NULL
};
#endif /* JOB_CONTROL */
char *let_doc[] = {
#if defined (HELP_BUILTIN)
  "Each ARG is an arithmetic expression to be evaluated.  Evaluation",
  "is done in long integers with no check for overflow, though division",
  "by 0 is trapped and flagged as an error.  The following list of",
  "operators is grouped into levels of equal-precedence operators.",
  "The levels are listed in order of decreasing precedence.",
  "",
  "	-, +		unary minus, plus",
  "	!, ~		logical and bitwise negation",
  "	*, /, %		multiplication, division, remainder",
  "	+, -		addition, subtraction",
  "	<<, >>		left and right bitwise shifts",
  "	<=, >=, <, >	comparison",
  "	==, !=		equality, inequality",
  "	&		bitwise AND",
  "	^		bitwise XOR",
  "	|		bitwise OR",
  "	&&		logical AND",
  "	||		logical OR",
  "	expr ? expr : expr",
  "			conditional expression",
  "	=, *=, /=, %=,",
  "	+=, -=, <<=, >>=,",
  "	&=, ^=, |=	assignment",
  "",
  "Shell variables are allowed as operands.  The name of the variable",
  "is replaced by its value (coerced to a long integer) within",
  "an expression.  The variable need not have its integer attribute",
  "turned on to be used in an expression.",
  "",
  "Operators are evaluated in order of precedence.  Sub-expressions in",
  "parentheses are evaluated first and may override the precedence",
  "rules above.",
  "",
  "If the last ARG evaluates to 0, let returns 1; 0 is returned",
  "otherwise.",
#endif /* HELP_BUILTIN */
  (char *)NULL
};
char *read_doc[] = {
#if defined (HELP_BUILTIN)
  "One line is read from the standard input, and the first word is",
  "assigned to the first NAME, the second word to the second NAME, and so",
  "on, with leftover words assigned to the last NAME.  Only the characters",
  "found in $IFS are recognized as word delimiters.  If no NAMEs are supplied,",
  "the line read is stored in the REPLY variable.  If the -r option is given,",
  "this signifies `raw' input, and backslash escaping is disabled.  The",
  "-d option causes read to continue until the first character of DELIM is",
  "read, rather than newline.  If the `-p' option is supplied, the string",
  "PROMPT is output without a trailing newline before attempting to read.",
  "If -a is supplied, the words read are assigned to sequential indices of",
  "ARRAY, starting at zero.  If -e is supplied and the shell is interactive,",
  "readline is used to obtain the line.  If -n is supplied with a non-zero",
  "NCHARS argument, read returns after NCHARS characters have been read.",
  "The -s option causes input coming from a terminal to not be echoed.",
  "",
  "The -t option causes read to time out and return failure if a complete line",
  "of input is not read within TIMEOUT seconds.  The return code is zero,",
  "unless end-of-file is encountered or read times out.",
#endif /* HELP_BUILTIN */
  (char *)NULL
};
char *return_doc[] = {
#if defined (HELP_BUILTIN)
  "Causes a function to exit with the return value specified by N.  If N",
  "is omitted, the return status is that of the last command.",
#endif /* HELP_BUILTIN */
  (char *)NULL
};
char *set_doc[] = {
#if defined (HELP_BUILTIN)
  "    -a  Mark variables which are modified or created for export.",
  "    -b  Notify of job termination immediately.",
  "    -e  Exit immediately if a command exits with a non-zero status.",
  "    -f  Disable file name generation (globbing).",
  "    -h  Remember the location of commands as they are looked up.",
  "    -i  Force the shell to be an \"interactive\" one.  Interactive shells",
  "        always read `~/.bashrc' on startup.",
  "    -k  All assignment arguments are placed in the environment for a",
  "        command, not just those that precede the command name.",
  "    -m  Job control is enabled.",
  "    -n  Read commands but do not execute them.",
  "    -o option-name",
  "        Set the variable corresponding to option-name:",
  "            allexport    same as -a",
  "            braceexpand  same as -B",
#if defined (READLINE)
  "            emacs        use an emacs-style line editing interface",
#endif /* READLINE */
  "            errexit      same as -e",
  "            hashall      same as -h",
#if defined (BANG_HISTORY)
  "            histexpand   same as -H",
#endif /* BANG_HISTORY */
#if defined (HISTORY)
  "            history      enable command history",
#endif
  "            ignoreeof    the shell will not exit upon reading EOF",
  "            interactive-comments",
  "                         allow comments to appear in interactive commands",
  "            keyword      same as -k",
  "            monitor      same as -m",
  "            noclobber    same as -C",
  "            noexec       same as -n",
  "            noglob       same as -f",
  "            notify       same as -b",
  "            nounset      same as -u",
  "            onecmd       same as -t",
  "            physical     same as -P",
  "            posix        change the behavior of bash where the default",
  "                         operation differs from the 1003.2 standard to",
  "                         match the standard",
  "            privileged   same as -p",
  "            verbose      same as -v",
#if defined (READLINE)
  "            vi           use a vi-style line editing interface",
#endif /* READLINE */
  "            xtrace       same as -x",
  "    -p  Turned on whenever the real and effective user ids do not match.",
  "        Disables processing of the $ENV file and importing of shell",
  "        functions.  Turning this option off causes the effective uid and",
  "        gid to be set to the real uid and gid.",
  "    -t  Exit after reading and executing one command.",
  "    -u  Treat unset variables as an error when substituting.",
  "    -v  Print shell input lines as they are read.",
  "    -x  Print commands and their arguments as they are executed.",
#if defined (BRACE_EXPANSION)
  "    -B  the shell will perform brace expansion",
#endif /* BRACE_EXPANSION */
  "    -C  If set, disallow existing regular files to be overwritten",
  "        by redirection of output.",
#if defined (BANG_HISTORY)
  "    -H  Enable ! style history substitution.  This flag is on",
  "        by default.",
#endif /* BANG_HISTORY */
  "    -P  If set, do not follow symbolic links when executing commands",
  "        such as cd which change the current directory.",
  "",
  "Using + rather than - causes these flags to be turned off.  The",
  "flags can also be used upon invocation of the shell.  The current",
  "set of flags may be found in $-.  The remaining n ARGs are positional",
  "parameters and are assigned, in order, to $1, $2, .. $n.  If no",
  "ARGs are given, all shell variables are printed.",
#endif /* HELP_BUILTIN */
  (char *)NULL
};
char *unset_doc[] = {
#if defined (HELP_BUILTIN)
  "For each NAME, remove the corresponding variable or function.  Given",
  "the `-v', unset will only act on variables.  Given the `-f' flag,",
  "unset will only act on functions.  With neither flag, unset first",
  "tries to unset a variable, and if that fails, then tries to unset a",
  "function.  Some variables cannot be unset; also see readonly.",
#endif /* HELP_BUILTIN */
  (char *)NULL
};
char *export_doc[] = {
#if defined (HELP_BUILTIN)
  "NAMEs are marked for automatic export to the environment of",
  "subsequently executed commands.  If the -f option is given,",
  "the NAMEs refer to functions.  If no NAMEs are given, or if `-p'",
  "is given, a list of all names that are exported in this shell is",
  "printed.  An argument of `-n' says to remove the export property",
  "from subsequent NAMEs.  An argument of `--' disables further option",
  "processing.",
#endif /* HELP_BUILTIN */
  (char *)NULL
};
char *readonly_doc[] = {
#if defined (HELP_BUILTIN)
  "The given NAMEs are marked readonly and the values of these NAMEs may",
  "not be changed by subsequent assignment.  If the -f option is given,",
  "then functions corresponding to the NAMEs are so marked.  If no",
  "arguments are given, or if `-p' is given, a list of all readonly names",
  "is printed.  An argument of `-n' says to remove the readonly property",
  "from subsequent NAMEs.  The `-a' option means to treat each NAME as",
  "an array variable.  An argument of `--' disables further option",
  "processing.",
#endif /* HELP_BUILTIN */
  (char *)NULL
};
char *shift_doc[] = {
#if defined (HELP_BUILTIN)
  "The positional parameters from $N+1 ... are renamed to $1 ...  If N is",
  "not given, it is assumed to be 1.",
#endif /* HELP_BUILTIN */
  (char *)NULL
};
char *source_doc[] = {
#if defined (HELP_BUILTIN)
  "Read and execute commands from FILENAME and return.  The pathnames",
  "in $PATH are used to find the directory containing FILENAME.",
#endif /* HELP_BUILTIN */
  (char *)NULL
};
char *dot_doc[] = {
#if defined (HELP_BUILTIN)
  "Read and execute commands from FILENAME and return.  The pathnames",
  "in $PATH are used to find the directory containing FILENAME.",
#endif /* HELP_BUILTIN */
  (char *)NULL
};
#if defined (JOB_CONTROL)
char *suspend_doc[] = {
#if defined (HELP_BUILTIN)
  "Suspend the execution of this shell until it receives a SIGCONT",
  "signal.  The `-f' if specified says not to complain about this",
  "being a login shell if it is; just suspend anyway.",
#endif /* HELP_BUILTIN */
  (char *)NULL
};
#endif /* JOB_CONTROL */
char *test_doc[] = {
#if defined (HELP_BUILTIN)
  "Exits with a status of 0 (trueness) or 1 (falseness) depending on",
  "the evaluation of EXPR.  Expressions may be unary or binary.  Unary",
  "expressions are often used to examine the status of a file.  There",
  "are string operators as well, and numeric comparison operators.",
  "",
  "File operators:",
  "",
  "    -b FILE        True if file is block special.",
  "    -c FILE        True if file is character special.",
  "    -d FILE        True if file is a directory.",
  "    -e FILE        True if file exists.",
  "    -f FILE        True if file exists and is a regular file.",
  "    -g FILE        True if file is set-group-id.",
  "    -h FILE        True if file is a symbolic link.",
  "    -L FILE        True if file is a symbolic link.",
  "    -k FILE        True if file has its `sticky' bit set.",
  "    -p FILE        True if file is a named pipe.",
  "    -r FILE        True if file is readable by you.",
  "    -s FILE        True if file exists and is not empty.",
  "    -S FILE        True if file is a socket.",
  "    -t FD          True if FD is opened on a terminal.",
  "    -u FILE        True if the file is set-user-id.",
  "    -w FILE        True if the file is writable by you.",
  "    -x FILE        True if the file is executable by you.",
  "    -O FILE        True if the file is effectively owned by you.",
  "    -G FILE        True if the file is effectively owned by your group.",
  "    -N FILE        True if the file has been modified since it was last read.",
  "",
  "  FILE1 -nt FILE2  True if file1 is newer than file2 (according to",
  "                   modification date).",
  "",
  "  FILE1 -ot FILE2  True if file1 is older than file2.",
  "",
  "  FILE1 -ef FILE2  True if file1 is a hard link to file2.",
  "",
  "String operators:",
  "",
  "    -z STRING      True if string is empty.",
  "",
  "    -n STRING",
  "    STRING         True if string is not empty.",
  "",
  "    STRING1 = STRING2",
  "                   True if the strings are equal.",
  "    STRING1 != STRING2",
  "                   True if the strings are not equal.",
  "    STRING1 < STRING2",
  "                   True if STRING1 sorts before STRING2 lexicographically.",
  "    STRING1 > STRING2",
  "                   True if STRING1 sorts after STRING2 lexicographically.",
  "",
  "Other operators:",
  "",
  "    -o OPTION      True if the shell option OPTION is enabled.",
  "    ! EXPR         True if expr is false.",
  "    EXPR1 -a EXPR2 True if both expr1 AND expr2 are true.",
  "    EXPR1 -o EXPR2 True if either expr1 OR expr2 is true.",
  "",
  "    arg1 OP arg2   Arithmetic tests.  OP is one of -eq, -ne,",
  "                   -lt, -le, -gt, or -ge.",
  "",
  "Arithmetic binary operators return true if ARG1 is equal, not-equal,",
  "less-than, less-than-or-equal, greater-than, or greater-than-or-equal",
  "than ARG2.",
#endif /* HELP_BUILTIN */
  (char *)NULL
};
char *test_bracket_doc[] = {
#if defined (HELP_BUILTIN)
  "This is a synonym for the \"test\" builtin, but the last",
  "argument must be a literal `]', to match the opening `['.",
#endif /* HELP_BUILTIN */
  (char *)NULL
};
char *times_doc[] = {
#if defined (HELP_BUILTIN)
  "Print the accumulated user and system times for processes run from",
  "the shell.",
#endif /* HELP_BUILTIN */
  (char *)NULL
};
char *trap_doc[] = {
#if defined (HELP_BUILTIN)
  "The command ARG is to be read and executed when the shell receives",
  "signal(s) SIGNAL_SPEC.  If ARG is absent all specified signals are",
  "reset to their original values.  If ARG is the null string each",
  "SIGNAL_SPEC is ignored by the shell and by the commands it invokes.",
  "If a SIGNAL_SPEC is EXIT (0) the command ARG is executed on exit from",
  "the shell.  If a SIGNAL_SPEC is DEBUG, ARG is executed after every",
  "command.  If ARG is `-p' then the trap commands associated with",
  "each SIGNAL_SPEC are displayed.  If no arguments are supplied or if",
  "only `-p' is given, trap prints the list of commands associated with",
  "each signal number.  Each SIGNAL_SPEC is either a signal name in <signal.h>",
  "or a signal number.  `trap -l' prints a list of signal names and their",
  "corresponding numbers.  Note that a signal can be sent to the shell",
  "with \"kill -signal $$\".",
#endif /* HELP_BUILTIN */
  (char *)NULL
};
char *type_doc[] = {
#if defined (HELP_BUILTIN)
  "For each NAME, indicate how it would be interpreted if used as a",
  "command name.",
  "",
  "If the -t option is used, `type' outputs a single word which is one of",
  "`alias', `keyword', `function', `builtin', `file' or `', if NAME is an",
  "alias, shell reserved word, shell function, shell builtin, disk file,",
  "or unfound, respectively.",
  "",
  "If the -p flag is used, `type' either returns the name of the disk",
  "file that would be executed, or nothing if `type -t NAME' would not",
  "return `file'.",
  "",
  "If the -a flag is used, `type' displays all of the places that contain",
  "an executable named `file'.  This includes aliases and functions, if",
  "and only if the -p flag is not also used.",
#endif /* HELP_BUILTIN */
  (char *)NULL
};
#if !defined (_MINIX)
char *ulimit_doc[] = {
#if defined (HELP_BUILTIN)
  "Ulimit provides control over the resources available to processes",
  "started by the shell, on systems that allow such control.  If an",
  "option is given, it is interpreted as follows:",
  "",
  "    -S	use the `soft' resource limit",
  "    -H	use the `hard' resource limit",
  "    -a	all current limits are reported",
  "    -c	the maximum size of core files created",
  "    -d	the maximum size of a process's data segment",
  "    -f	the maximum size of files created by the shell",
  "    -l	the maximum size a process may lock into memory",
  "    -m	the maximum resident set size",
  "    -n	the maximum number of open file descriptors",
  "    -p	the pipe buffer size",
  "    -s	the maximum stack size",
  "    -t	the maximum amount of cpu time in seconds",
  "    -u	the maximum number of user processes",
  "    -v	the size of virtual memory",
  "",
  "If LIMIT is given, it is the new value of the specified resource.",
  "Otherwise, the current value of the specified resource is printed.",
  "If no option is given, then -f is assumed.  Values are in 1024-byte",
  "increments, except for -t, which is in seconds, -p, which is in",
  "increments of 512 bytes, and -u, which is an unscaled number of",
  "processes.",
#endif /* HELP_BUILTIN */
  (char *)NULL
};
#endif /* !_MINIX */
char *umask_doc[] = {
#if defined (HELP_BUILTIN)
  "The user file-creation mask is set to MODE.  If MODE is omitted, or if",
  "`-S' is supplied, the current value of the mask is printed.  The `-S'",
  "option makes the output symbolic; otherwise an octal number is output.",
  "If `-p' is supplied, and MODE is omitted, the output is in a form",
  "that may be used as input.  If MODE begins with a digit, it is",
  "interpreted as an octal number, otherwise it is a symbolic mode string",
  "like that accepted by chmod(1).",
#endif /* HELP_BUILTIN */
  (char *)NULL
};
#if defined (JOB_CONTROL)
char *wait_doc[] = {
#if defined (HELP_BUILTIN)
  "Wait for the specified process and report its termination status.  If",
  "N is not given, all currently active child processes are waited for,",
  "and the return code is zero.  N may be a process ID or a job",
  "specification; if a job spec is given, all processes in the job's",
  "pipeline are waited for.",
#endif /* HELP_BUILTIN */
  (char *)NULL
};
#endif /* JOB_CONTROL */
#if !defined (JOB_CONTROL)
char *wait_doc[] = {
#if defined (HELP_BUILTIN)
  "Wait for the specified process and report its termination status.  If",
  "N is not given, all currently active child processes are waited for,",
  "and the return code is zero.  N is a process ID; if it is not given,",
  "all child processes of the shell are waited for.",
#endif /* HELP_BUILTIN */
  (char *)NULL
};
#endif /* !JOB_CONTROL */
char *for_doc[] = {
#if defined (HELP_BUILTIN)
  "The `for' loop executes a sequence of commands for each member in a",
  "list of items.  If `in WORDS ...;' is not present, then `in \"$@\"' is",
  "assumed.  For each element in WORDS, NAME is set to that element, and",
  "the COMMANDS are executed.",
#endif /* HELP_BUILTIN */
  (char *)NULL
};
char *select_doc[] = {
#if defined (HELP_BUILTIN)
  "The WORDS are expanded, generating a list of words.  The",
  "set of expanded words is printed on the standard error, each",
  "preceded by a number.  If `in WORDS' is not present, `in \"$@\"'",
  "is assumed.  The PS3 prompt is then displayed and a line read",
  "from the standard input.  If the line consists of the number",
  "corresponding to one of the displayed words, then NAME is set",
  "to that word.  If the line is empty, WORDS and the prompt are",
  "redisplayed.  If EOF is read, the command completes.  Any other",
  "value read causes NAME to be set to null.  The line read is saved",
  "in the variable REPLY.  COMMANDS are executed after each selection",
  "until a break or return command is executed.",
#endif /* HELP_BUILTIN */
  (char *)NULL
};
char *time_doc[] = {
#if defined (HELP_BUILTIN)
  "Execute PIPELINE and print a summary of the real time, user CPU time,",
  "and system CPU time spent executing PIPELINE when it terminates.",
  "The return status is the return status of PIPELINE.  The `-p' option",
  "prints the timing summary in a slightly different format.  This uses",
  "the value of the TIMEFORMAT variable as the output format.",
#endif /* HELP_BUILTIN */
  (char *)NULL
};
char *case_doc[] = {
#if defined (HELP_BUILTIN)
  "Selectively execute COMMANDS based upon WORD matching PATTERN.  The",
  "`|' is used to separate multiple patterns.",
#endif /* HELP_BUILTIN */
  (char *)NULL
};
char *if_doc[] = {
#if defined (HELP_BUILTIN)
  "The if COMMANDS are executed.  If the exit status is zero, then the then",
  "COMMANDS are executed.  Otherwise, each of the elif COMMANDS are executed",
  "in turn, and if the exit status is zero, the corresponding then COMMANDS",
  "are executed and the if command completes.  Otherwise, the else COMMANDS",
  "are executed, if present.  The exit status is the exit status of the last",
  "command executed, or zero if no condition tested true.",
#endif /* HELP_BUILTIN */
  (char *)NULL
};
char *while_doc[] = {
#if defined (HELP_BUILTIN)
  "Expand and execute COMMANDS as long as the final command in the",
  "`while' COMMANDS has an exit status of zero.",
#endif /* HELP_BUILTIN */
  (char *)NULL
};
char *until_doc[] = {
#if defined (HELP_BUILTIN)
  "Expand and execute COMMANDS as long as the final command in the",
  "`until' COMMANDS has an exit status which is not zero.",
#endif /* HELP_BUILTIN */
  (char *)NULL
};
char *function_doc[] = {
#if defined (HELP_BUILTIN)
  "Create a simple command invoked by NAME which runs COMMANDS.",
  "Arguments on the command line along with NAME are passed to the",
  "function as $0 .. $n.",
#endif /* HELP_BUILTIN */
  (char *)NULL
};
char *grouping_braces_doc[] = {
#if defined (HELP_BUILTIN)
  "Run a set of commands in a group.  This is one way to redirect an",
  "entire set of commands.",
#endif /* HELP_BUILTIN */
  (char *)NULL
};
char *fg_percent_doc[] = {
#if defined (HELP_BUILTIN)
  "This is similar to the `fg' command.  Resume a stopped or background",
  "job.  If you specifiy DIGITS, then that job is used.  If you specify",
  "WORD, then the job whose name begins with WORD is used.  Following the",
  "job specification with a `&' places the job in the background.",
#endif /* HELP_BUILTIN */
  (char *)NULL
};
char *variable_help_doc[] = {
#if defined (HELP_BUILTIN)
  "BASH_VERSION    Version information for this Bash.",
  "CDPATH          A colon separated list of directories to search",
  "		when the argument to `cd' is not found in the current",
  "		directory.",
  "GLOBIGNORE	A colon-separated list of patterns describing filenames to",
  "		be ignored by pathname expansion.",
#if defined (HISTORY)
  "HISTFILE        The name of the file where your command history is stored.",
  "HISTFILESIZE    The maximum number of lines this file can contain.",
  "HISTSIZE        The maximum number of history lines that a running",
  "		shell can access.",
#endif /* HISTORY */
  "HOME            The complete pathname to your login directory.",
  "HOSTNAME	The name of the current host.",
  "HOSTTYPE        The type of CPU this version of Bash is running under.",
  "IGNOREEOF       Controls the action of the shell on receipt of an EOF",
  "		character as the sole input.  If set, then the value",
  "		of it is the number of EOF characters that can be seen",
  "		in a row on an empty line before the shell will exit",
  "		(default 10).  When unset, EOF signifies the end of input.",
  "MACHTYPE	A string describing the current system Bash is running on.",
  "MAILCHECK	How often, in seconds, Bash checks for new mail.",
  "MAILPATH	A colon-separated list of filenames which Bash checks",
  "		for new mail.",
  "OSTYPE		The version of Unix this version of Bash is running on.",
  "PATH            A colon-separated list of directories to search when",
  "		looking for commands.",
  "PROMPT_COMMAND  A command to be executed before the printing of each",
  "		primary prompt.",
  "PS1             The primary prompt string.",
  "PS2             The secondary prompt string.",
  "PWD		The full pathname of the current directory.",
  "SHELLOPTS	A colon-separated list of enabled shell options.",
  "TERM            The name of the current terminal type.",
  "TIMEFORMAT	The output format for timing statistics displayed by the",
  "		`time' reserved word.",
  "auto_resume     Non-null means a command word appearing on a line by",
  "		itself is first looked for in the list of currently",
  "		stopped jobs.  If found there, that job is foregrounded.",
  "		A value of `exact' means that the command word must",
  "		exactly match a command in the list of stopped jobs.  A",
  "		value of `substring' means that the command word must",
  "		match a substring of the job.  Any other value means that",
  "		the command must be a prefix of a stopped job.",
#if defined (HISTORY)
#  if defined (BANG_HISTORY)
  "histchars       Characters controlling history expansion and quick",
  "		substitution.  The first character is the history",
  "		substitution character, usually `!'.  The second is",
  "		the `quick substitution' character, usually `^'.  The",
  "		third is the `history comment' character, usually `#'.",
#  endif /* BANG_HISTORY */
  "HISTIGNORE	A colon-separated list of patterns used to decide which",
  "		command should be saved on the history list.",
#endif /* HISTORY */
#endif /* HELP_BUILTIN */
  (char *)NULL
};
#if defined (PUSHD_AND_POPD)
char *pushd_doc[] = {
#if defined (HELP_BUILTIN)
  "Adds a directory to the top of the directory stack, or rotates",
  "the stack, making the new top of the stack the current working",
  "directory.  With no arguments, exchanges the top two directories.",
  "",
  "+N	Rotates the stack so that the Nth directory (counting",
  "	from the left of the list shown by `dirs', starting with",
  "	zero) is at the top.",
  "",
  "-N	Rotates the stack so that the Nth directory (counting",
  "	from the right of the list shown by `dirs', starting with",
  "	zero) is at the top.",
  "",
  "-n	suppress the normal change of directory when adding directories",
  "	to the stack, so only the stack is manipulated.",
  "",
  "dir	adds DIR to the directory stack at the top, making it the",
  "	new current working directory.",
  "",
  "You can see the directory stack with the `dirs' command.",
#endif /* HELP_BUILTIN */
  (char *)NULL
};
#endif /* PUSHD_AND_POPD */
#if defined (PUSHD_AND_POPD)
char *popd_doc[] = {
#if defined (HELP_BUILTIN)
  "Removes entries from the directory stack.  With no arguments,",
  "removes the top directory from the stack, and cd's to the new",
  "top directory.",
  "",
  "+N	removes the Nth entry counting from the left of the list",
  "	shown by `dirs', starting with zero.  For example: `popd +0'",
  "	removes the first directory, `popd +1' the second.",
  "",
  "-N	removes the Nth entry counting from the right of the list",
  "	shown by `dirs', starting with zero.  For example: `popd -0'",
  "	removes the last directory, `popd -1' the next to last.",
  "",
  "-n	suppress the normal change of directory when removing directories",
  "	from the stack, so only the stack is manipulated.",
  "",
  "You can see the directory stack with the `dirs' command.",
#endif /* HELP_BUILTIN */
  (char *)NULL
};
#endif /* PUSHD_AND_POPD */
#if defined (PUSHD_AND_POPD)
char *dirs_doc[] = {
#if defined (HELP_BUILTIN)
  "Display the list of currently remembered directories.  Directories",
  "find their way onto the list with the `pushd' command; you can get",
  "back up through the list with the `popd' command.",
  "",
  "The -l flag specifies that `dirs' should not print shorthand versions",
  "of directories which are relative to your home directory.  This means",
  "that `~/bin' might be displayed as `/homes/bfox/bin'.  The -v flag",
  "causes `dirs' to print the directory stack with one entry per line,",
  "prepending the directory name with its position in the stack.  The -p",
  "flag does the same thing, but the stack position is not prepended.",
  "The -c flag clears the directory stack by deleting all of the elements.",
  "",
  "+N	displays the Nth entry counting from the left of the list shown by",
  "	dirs when invoked without options, starting with zero.",
  "",
  "-N	displays the Nth entry counting from the right of the list shown by",
  "	dirs when invoked without options, starting with zero.",
#endif /* HELP_BUILTIN */
  (char *)NULL
};
#endif /* PUSHD_AND_POPD */
char *shopt_builtin_doc[] = {
#if defined (HELP_BUILTIN)
  "Toggle the values of variables controlling optional behavior.",
  "The -s flag means to enable (set) each OPTNAME; the -u flag",
  "unsets each OPTNAME.  The -q flag suppresses output; the exit",
  "status indicates whether each OPTNAME is set or unset.  The -o",
  "option restricts the OPTNAMEs to those defined for use with",
  "`set -o'.  With no options, or with the -p option, a list of all",
  "settable options is displayed, with an indication of whether or",
  "not each is set.",
#endif /* HELP_BUILTIN */
  (char *)NULL
};
char *printf_doc[] = {
#if defined (HELP_BUILTIN)
  "printf formats and prints ARGUMENTS under control of the FORMAT. FORMAT",
  "is a character string which contains three types of objects: plain",
  "characters, which are simply copied to standard output, character escape",
  "sequences which are converted and copied to the standard output, and",
  "format specifications, each of which causes printing of the next successive",
  "argument.  In addition to the standard printf(1) formats, %b means to",
  "expand backslash escape sequences in the corresponding argument, and %q",
  "means to quote the argument in a way that can be reused as shell input.",
#endif /* HELP_BUILTIN */
  (char *)NULL
};
#if defined (PROGRAMMABLE_COMPLETION)
char *complete_doc[] = {
#if defined (HELP_BUILTIN)
  "For each NAME, specify how arguments are to be completed.",
  "If the -p option is supplied, or if no options are supplied, existing",
  "completion specifications are printed in a way that allows them to be",
  "reused as input.  The -r option removes a completion specification for",
  "each NAME, or, if no NAMEs are supplied, all completion specifications.",
#endif /* HELP_BUILTIN */
  (char *)NULL
};
#endif /* PROGRAMMABLE_COMPLETION */
#if defined (PROGRAMMABLE_COMPLETION)
char *compgen_doc[] = {
#if defined (HELP_BUILTIN)
  "Display the possible completions depending on the options.  Intended",
  "to be used from within a shell function generating possible completions.",
  "If the optional WORD argument is supplied, matches against WORD are",
  "generated.",
#endif /* HELP_BUILTIN */
  (char *)NULL
};
#endif /* PROGRAMMABLE_COMPLETION */
