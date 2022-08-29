/* builtext.h - The list of builtins found in libbuiltins.a. */
#if defined (ALIAS)
extern int alias_builtin ();
extern char *alias_doc[];
#endif /* ALIAS */
#if defined (ALIAS)
extern int unalias_builtin ();
extern char *unalias_doc[];
#endif /* ALIAS */
#if defined (READLINE)
extern int bind_builtin ();
extern char *bind_doc[];
#endif /* READLINE */
extern int break_builtin ();
extern char *break_doc[];
extern int continue_builtin ();
extern char *continue_doc[];
extern int builtin_builtin ();
extern char *builtin_doc[];
extern int cd_builtin ();
extern char *cd_doc[];
extern int pwd_builtin ();
extern char *pwd_doc[];
extern int colon_builtin ();
extern char *colon_builtin_doc[];
extern int colon_builtin ();
extern char *true_builtin_doc[];
extern int false_builtin ();
extern char *false_builtin_doc[];
extern int command_builtin ();
extern char *command_doc[];
extern int declare_builtin ();
extern char *declare_doc[];
extern int declare_builtin ();
extern char *typeset_doc[];
extern int local_builtin ();
extern char *local_doc[];
#if defined (V9_ECHO)
extern int echo_builtin ();
extern char *echo_doc[];
#endif /* V9_ECHO */
#if !defined (V9_ECHO)
extern int echo_builtin ();
extern char *echo_doc[];
#endif /* !V9_ECHO */
extern int enable_builtin ();
extern char *enable_doc[];
extern int eval_builtin ();
extern char *eval_doc[];
extern int getopts_builtin ();
extern char *getopts_doc[];
extern int exec_builtin ();
extern char *exec_doc[];
extern int exit_builtin ();
extern char *exit_doc[];
extern int logout_builtin ();
extern char *logout_doc[];
#if defined (HISTORY)
extern int fc_builtin ();
extern char *fc_doc[];
#endif /* HISTORY */
#if defined (JOB_CONTROL)
extern int fg_builtin ();
extern char *fg_doc[];
#endif /* JOB_CONTROL */
#if defined (JOB_CONTROL)
extern int bg_builtin ();
extern char *bg_doc[];
#endif /* JOB_CONTROL */
extern int hash_builtin ();
extern char *hash_doc[];
#if defined (HELP_BUILTIN)
extern int help_builtin ();
extern char *help_doc[];
#endif /* HELP_BUILTIN */
#if defined (HISTORY)
extern int history_builtin ();
extern char *history_doc[];
#endif /* HISTORY */
#if defined (JOB_CONTROL)
extern int jobs_builtin ();
extern char *jobs_doc[];
#endif /* JOB_CONTROL */
#if defined (JOB_CONTROL)
extern int disown_builtin ();
extern char *disown_doc[];
#endif /* JOB_CONTROL */
#if defined (JOB_CONTROL)
extern int kill_builtin ();
extern char *kill_doc[];
#endif /* JOB_CONTROL */
extern int let_builtin ();
extern char *let_doc[];
extern int read_builtin ();
extern char *read_doc[];
extern int return_builtin ();
extern char *return_doc[];
extern int set_builtin ();
extern char *set_doc[];
extern int unset_builtin ();
extern char *unset_doc[];
extern int export_builtin ();
extern char *export_doc[];
extern int readonly_builtin ();
extern char *readonly_doc[];
extern int shift_builtin ();
extern char *shift_doc[];
extern int source_builtin ();
extern char *source_doc[];
extern int source_builtin ();
extern char *dot_doc[];
#if defined (JOB_CONTROL)
extern int suspend_builtin ();
extern char *suspend_doc[];
#endif /* JOB_CONTROL */
extern int test_builtin ();
extern char *test_doc[];
extern int test_builtin ();
extern char *test_bracket_doc[];
extern int times_builtin ();
extern char *times_doc[];
extern int trap_builtin ();
extern char *trap_doc[];
extern int type_builtin ();
extern char *type_doc[];
#if !defined (_MINIX)
extern int ulimit_builtin ();
extern char *ulimit_doc[];
#endif /* !_MINIX */
extern int umask_builtin ();
extern char *umask_doc[];
#if defined (JOB_CONTROL)
extern int wait_builtin ();
extern char *wait_doc[];
#endif /* JOB_CONTROL */
#if !defined (JOB_CONTROL)
extern int wait_builtin ();
extern char *wait_doc[];
#endif /* !JOB_CONTROL */
extern char *for_doc[];
extern char *select_doc[];
extern char *time_doc[];
extern char *case_doc[];
extern char *if_doc[];
extern char *while_doc[];
extern char *until_doc[];
extern char *function_doc[];
extern char *grouping_braces_doc[];
extern char *fg_percent_doc[];
extern char *variable_help_doc[];
#if defined (PUSHD_AND_POPD)
extern int pushd_builtin ();
extern char *pushd_doc[];
#endif /* PUSHD_AND_POPD */
#if defined (PUSHD_AND_POPD)
extern int popd_builtin ();
extern char *popd_doc[];
#endif /* PUSHD_AND_POPD */
#if defined (PUSHD_AND_POPD)
extern int dirs_builtin ();
extern char *dirs_doc[];
#endif /* PUSHD_AND_POPD */
extern int shopt_builtin ();
extern char *shopt_builtin_doc[];
extern int printf_builtin ();
extern char *printf_doc[];
#if defined (PROGRAMMABLE_COMPLETION)
extern int complete_builtin ();
extern char *complete_doc[];
#endif /* PROGRAMMABLE_COMPLETION */
#if defined (PROGRAMMABLE_COMPLETION)
extern int compgen_builtin ();
extern char *compgen_doc[];
#endif /* PROGRAMMABLE_COMPLETION */
