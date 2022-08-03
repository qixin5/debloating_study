/* Fully extensible Emacs, running on Unix, intended for GNU.
   Copyright (C) 1985,86,87,93,94,95,97,1998 Free Software Foundation, Inc.

This file is part of GNU Emacs.

GNU Emacs is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2, or (at your option)
any later version.

GNU Emacs is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with GNU Emacs; see the file COPYING.  If not, write to
the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
Boston, MA 02111-1307, USA.  */


#include <signal.h>
#include <errno.h>

#include <config.h>
#include <stdio.h>

#include <sys/types.h>
#include <sys/file.h>

#ifdef VMS
#include <ssdef.h>
#endif

#ifdef BSD_SYSTEM
#include <sys/ioctl.h>
#endif

#include "lisp.h"
#include "commands.h"
#include "intervals.h"
#include "buffer.h"

#include "systty.h"
#include "blockinput.h"
#include "syssignal.h"
#include "process.h"
#include "termhooks.h"
#include "keyboard.h"

#ifdef HAVE_SETRLIMIT
#include <sys/time.h>
#include <sys/resource.h>
#endif

#ifdef HAVE_SETPGID
#if !defined (USG) || defined (BSD_PGRPS)
#define setpgrp setpgid
#endif
#endif

#ifndef O_RDWR
#define O_RDWR 2
#endif

extern void malloc_warning ();
extern void set_time_zone_rule ();
extern char *index ();
extern char *strerror ();

/* Command line args from shell, as list of strings */
Lisp_Object Vcommand_line_args;

/* The name under which Emacs was invoked, with any leading directory
   names discarded.  */
Lisp_Object Vinvocation_name;

/* The directory name from which Emacs was invoked.  */
Lisp_Object Vinvocation_directory;

/* The directory name in which to find subdirs such as lisp and etc.
   nil means get them only from PATH_LOADSEARCH.  */
Lisp_Object Vinstallation_directory;

/* Hook run by `kill-emacs' before it does really anything.  */
Lisp_Object Vkill_emacs_hook;

#ifdef SIGUSR1
/* Hooks for signal USR1 and USR2 handing */
Lisp_Object Vsignal_USR1_hook;
#ifdef SIGUSR2
Lisp_Object Vsignal_USR2_hook;
#endif 
#endif

/* Search path separator.  */
Lisp_Object Vpath_separator;

/* Set nonzero after Emacs has started up the first time.
  Prevents reinitialization of the Lisp world and keymaps
  on subsequent starts.  */
int initialized;

#ifdef DOUG_LEA_MALLOC
/* Preserves a pointer to the memory allocated that copies that
   static data inside glibc's malloc.  */
void *malloc_state_ptr;
/* From glibc, a routine that returns a copy of the malloc internal state.  */
extern void *malloc_get_state ();
/* From glibc, a routine that overwrites the malloc internal state.  */
extern void malloc_set_state ();
/* Non-zero if the MALLOC_CHECK_ enviroment variable was set while
   dumping.  Used to work around a bug in glibc's malloc.  */
int malloc_using_checking;
#endif

/* Variable whose value is symbol giving operating system type.  */
Lisp_Object Vsystem_type;

/* Variable whose value is string giving configuration built for.  */
Lisp_Object Vsystem_configuration;

/* Variable whose value is string giving configuration options,
   for use when reporting bugs.  */
Lisp_Object Vsystem_configuration_options;

Lisp_Object Qfile_name_handler_alist;

/* If non-zero, emacs should not attempt to use an window-specific code,
   but instead should use the virtual terminal under which it was started */
int inhibit_window_system;

/* If nonzero, set Emacs to run at this priority.  This is also used
   in child_setup and sys_suspend to make sure subshells run at normal
   priority; Those functions have their own extern declaration.  */
int emacs_priority;

/* If non-zero a filter or a sentinel is running.  Tested to save the match
   data on the first attempt to change it inside asynchronous code. */
int running_asynch_code;

#ifdef BSD_PGRPS
/* See sysdep.c.  */
extern int inherited_pgroup;
#endif

#ifdef HAVE_X_WINDOWS
/* If non-zero, -d was specified, meaning we're using some window system. */
int display_arg;
#endif

/* An address near the bottom of the stack.
   Tells GC how to save a copy of the stack.  */
char *stack_bottom;

#ifdef HAVE_WINDOW_SYSTEM
extern Lisp_Object Vwindow_system;
#endif /* HAVE_WINDOW_SYSTEM */

extern Lisp_Object Vauto_save_list_file_name;

#ifdef USG_SHARED_LIBRARIES
/* If nonzero, this is the place to put the end of the writable segment
   at startup.  */

unsigned int bss_end = 0;
#endif

/* Nonzero means running Emacs without interactive terminal.  */

int noninteractive;

/* Value of Lisp variable `noninteractive'.
   Normally same as C variable `noninteractive'
   but nothing terrible happens if user sets this one.  */

int noninteractive1;

/* Save argv and argc.  */
char **initial_argv;
int initial_argc;

static void sort_args ();
void syms_of_emacs ();

/* Signal code for the fatal signal that was received */
int fatal_error_code;

/* Nonzero if handling a fatal error already */
int fatal_error_in_progress;

#ifdef SIGUSR1
SIGTYPE
handle_USR1_signal (sig)
     int sig;
{
  struct input_event buf;

  buf.kind = user_signal;
  buf.code = 0;
  buf.frame_or_window = Fselected_frame ();
  buf.modifiers = 0;
  buf.timestamp = 0;

  kbd_buffer_store_event (&buf);
}
#endif /* SIGUSR1 */

#ifdef SIGUSR2
SIGTYPE
handle_USR2_signal (sig)
     int sig;
{
  struct input_event buf;

  buf.kind = user_signal;
  buf.code = 1;
  buf.frame_or_window = Fselected_frame ();
  buf.modifiers = 0;
  buf.timestamp = 0;

  kbd_buffer_store_event (&buf);
}
#endif /* SIGUSR2 */

/* Handle bus errors, illegal instruction, etc. */
SIGTYPE
fatal_error_signal (sig)
     int sig;
{
  fatal_error_code = sig;
  signal (sig, SIG_DFL);

  TOTALLY_UNBLOCK_INPUT;

  /* If fatal error occurs in code below, avoid infinite recursion.  */
  if (! fatal_error_in_progress)
    {
      fatal_error_in_progress = 1;

      shut_down_emacs (sig, 0, Qnil);
    }

#ifdef VMS
  LIB$STOP (SS$_ABORT);
#else
  /* Signal the same code; this time it will really be fatal.
     Remember that since we're in a signal handler, the signal we're
     going to send is probably blocked, so we have to unblock it if we
     want to really receive it.  */
#ifndef MSDOS
  sigunblock (sigmask (fatal_error_code));
#endif
  kill (getpid (), fatal_error_code);
#endif /* not VMS */
}

#ifdef SIGDANGER

/* Handler for SIGDANGER.  */
SIGTYPE
memory_warning_signal (sig)
     int sig;
{
  signal (sig, memory_warning_signal);

  malloc_warning ("Operating system warns that virtual memory is running low.\n");

  /* It might be unsafe to call do_auto_save now.  */
  force_auto_save_soon ();
}
#endif

/* We define abort, rather than using it from the library,
   so that GDB can return from a breakpoint here.
   MSDOS has its own definition on msdos.c  */

#if ! defined (DOS_NT) && ! defined (NO_ABORT)
void
abort ()
{
  kill (getpid (), SIGABRT);
  /* This shouldn't be executed, but it prevents a warning.  */
  exit (1);
}
#endif


/* Code for dealing with Lisp access to the Unix command line */

static void
init_cmdargs (argc, argv, skip_args)
     int argc;
     char **argv;
     int skip_args;
{
  register int i;
  Lisp_Object name, dir, tem;
  int count = specpdl_ptr - specpdl;
  Lisp_Object raw_name;

  initial_argv = argv;
  initial_argc = argc;

  raw_name = build_string (argv[0]);

  /* Add /: to the front of the name
     if it would otherwise be treated as magic.  */
  tem = Ffind_file_name_handler (raw_name, Qt);
  if (! NILP (tem))
    raw_name = concat2 (build_string ("/:"), raw_name);

  Vinvocation_name = Ffile_name_nondirectory (raw_name);
  Vinvocation_directory = Ffile_name_directory (raw_name);

  /* If we got no directory in argv[0], search PATH to find where
     Emacs actually came from.  */
  if (NILP (Vinvocation_directory))
    {
      Lisp_Object found;
      int yes = openp (Vexec_path, Vinvocation_name,
		       EXEC_SUFFIXES, &found, 1);
      if (yes == 1)
	{
	  /* Add /: to the front of the name
	     if it would otherwise be treated as magic.  */
	  tem = Ffind_file_name_handler (found, Qt);
	  if (! NILP (tem))
	    found = concat2 (build_string ("/:"), found);
	  Vinvocation_directory = Ffile_name_directory (found);
	}
    }

  if (!NILP (Vinvocation_directory)
      && NILP (Ffile_name_absolute_p (Vinvocation_directory)))
    /* Emacs was started with relative path, like ./emacs.
       Make it absolute.  */
    Vinvocation_directory = Fexpand_file_name (Vinvocation_directory, Qnil);

  Vinstallation_directory = Qnil;

  if (!NILP (Vinvocation_directory))
    {
      dir = Vinvocation_directory;
      name = Fexpand_file_name (Vinvocation_name, dir);
      while (1)
	{
	  Lisp_Object tem, lib_src_exists;
	  Lisp_Object etc_exists, info_exists;

	  /* See if dir contains subdirs for use by Emacs.
	     Check for the ones that would exist in a build directory,
	     not including lisp and info.  */
	  tem = Fexpand_file_name (build_string ("lib-src"), dir);
	  lib_src_exists = Ffile_exists_p (tem);

#ifdef MSDOS
	  /* MSDOS installations frequently remove lib-src, but we still
	     must set installation-directory, or else info won't find
	     its files (it uses the value of installation-directory).  */
	  tem = Fexpand_file_name (build_string ("info"), dir);
	  info_exists = Ffile_exists_p (tem);
#else
	  info_exists = Qnil;
#endif

	  if (!NILP (lib_src_exists) || !NILP (info_exists))
	    {
	      tem = Fexpand_file_name (build_string ("etc"), dir);
	      etc_exists = Ffile_exists_p (tem);
	      if (!NILP (etc_exists))
		{
		  Vinstallation_directory
		    = Ffile_name_as_directory (dir);
		  break;
		}
	    }

	  /* See if dir's parent contains those subdirs.  */
	  tem = Fexpand_file_name (build_string ("../lib-src"), dir);
	  lib_src_exists = Ffile_exists_p (tem);


#ifdef MSDOS
	  /* See the MSDOS commentary above.  */
	  tem = Fexpand_file_name (build_string ("../info"), dir);
	  info_exists = Ffile_exists_p (tem);
#else
	  info_exists = Qnil;
#endif

	  if (!NILP (lib_src_exists) || !NILP (info_exists))
	    {
	      tem = Fexpand_file_name (build_string ("../etc"), dir);
	      etc_exists = Ffile_exists_p (tem);
	      if (!NILP (etc_exists))
		{
		  tem = Fexpand_file_name (build_string (".."), dir);
		  Vinstallation_directory
		    = Ffile_name_as_directory (tem);
		  break;
		}
	    }

	  /* If the Emacs executable is actually a link,
	     next try the dir that the link points into.  */
	  tem = Ffile_symlink_p (name);
	  if (!NILP (tem))
	    {
	      name = Fexpand_file_name (tem, dir);
	      dir = Ffile_name_directory (name);
	    }
	  else
	    break;
	}
    }

  Vcommand_line_args = Qnil;

  for (i = argc - 1; i >= 0; i--)
    {
      if (i == 0 || i > skip_args)
	Vcommand_line_args
	  = Fcons (build_string (argv[i]), Vcommand_line_args);
    }

  unbind_to (count, Qnil);
}

DEFUN ("invocation-name", Finvocation_name, Sinvocation_name, 0, 0, 0,
  "Return the program name that was used to run Emacs.\n\
Any directory names are omitted.")
  ()
{
  return Fcopy_sequence (Vinvocation_name);
}

DEFUN ("invocation-directory", Finvocation_directory, Sinvocation_directory,
  0, 0, 0,
  "Return the directory name in which the Emacs executable was located")
  ()
{
  return Fcopy_sequence (Vinvocation_directory);
}


#ifdef VMS
#ifdef LINK_CRTL_SHARE
#ifdef SHARABLE_LIB_BUG
extern noshare char **environ;
#endif /* SHARABLE_LIB_BUG */
#endif /* LINK_CRTL_SHARE */
#endif /* VMS */

#ifdef HAVE_TZSET
/* A valid but unlikely value for the TZ environment value.
   It is OK (though a bit slower) if the user actually chooses this value.  */
static char dump_tz[] = "UtC0";
#endif

#ifndef ORDINARY_LINK
/* We don't include crtbegin.o and crtend.o in the link,
   so these functions and variables might be missed.
   Provide dummy definitions to avoid error.
   (We don't have any real constructors or destructors.)  */
#ifdef __GNUC__
#ifndef GCC_CTORS_IN_LIBC
void __do_global_ctors ()
{}
void __do_global_ctors_aux ()
{}
void __do_global_dtors ()
{}
/* Linux has a bug in its library; avoid an error.  */
#ifndef LINUX
char * __CTOR_LIST__[2] = { (char *) (-1), 0 };
#endif
char * __DTOR_LIST__[2] = { (char *) (-1), 0 };
#endif /* GCC_CTORS_IN_LIBC */
void __main ()
{}
#endif /* __GNUC__ */
#endif /* ORDINARY_LINK */

/* Test whether the next argument in ARGV matches SSTR or a prefix of
   LSTR (at least MINLEN characters).  If so, then if VALPTR is non-null
   (the argument is supposed to have a value) store in *VALPTR either
   the next argument or the portion of this one after the equal sign.
   ARGV is read starting at position *SKIPPTR; this index is advanced
   by the number of arguments used.

   Too bad we can't just use getopt for all of this, but we don't have
   enough information to do it right.  */

static int
argmatch (argv, argc, sstr, lstr, minlen, valptr, skipptr)
     char **argv;
     int argc;
     char *sstr;
     char *lstr;
     int minlen;
     char **valptr;
     int *skipptr;
{
  char *p;
  int arglen;
  char *arg;

  /* Don't access argv[argc]; give up in advance.  */
  if (argc <= *skipptr + 1)
    return 0;

  arg = argv[*skipptr+1];
  if (arg == NULL)
    return 0;
  if (strcmp (arg, sstr) == 0)
    {
      if (valptr != NULL)
	{
	  *valptr = argv[*skipptr+2];
	  *skipptr += 2;
	}
      else
	*skipptr += 1;
      return 1;
    }
  arglen = (valptr != NULL && (p = index (arg, '=')) != NULL
	    ? p - arg : strlen (arg));
  if (lstr == 0 || arglen < minlen || strncmp (arg, lstr, arglen) != 0)
    return 0;
  else if (valptr == NULL)
    {
      *skipptr += 1;
      return 1;
    }
  else if (p != NULL)
    {
      *valptr = p+1;
      *skipptr += 1;
      return 1;
    }
  else if (argv[*skipptr+2] != NULL)
    {
      *valptr = argv[*skipptr+2];
      *skipptr += 2;
      return 1;
    }
  else
    {
      return 0;
    }
}

#ifdef DOUG_LEA_MALLOC

/* malloc can be invoked even before main (e.g. by the dynamic
   linker), so the dumped malloc state must be restored as early as
   possible using this special hook.  */

static void
malloc_initialize_hook ()
{
  extern char **environ;

  if (initialized)
    {
      if (!malloc_using_checking)
	/* Work around a bug in glibc's malloc.  MALLOC_CHECK_ must be
	   ignored if the heap to be restored was constructed without
	   malloc checking.  Can't use unsetenv, since that calls malloc.  */
	{
	  char **p;

	  for (p = environ; *p; p++)
	    if (strncmp (*p, "MALLOC_CHECK_=", 14) == 0)
	      {
		do
		  *p = p[1];
		while (*++p);
		break;
	      }
	}

      malloc_set_state (malloc_state_ptr);
      free (malloc_state_ptr);
    }
  else
    malloc_using_checking = getenv ("MALLOC_CHECK_") != NULL;
}

void (*__malloc_initialize_hook) () = malloc_initialize_hook;

#endif /* DOUG_LEA_MALLOC */

/* ARGSUSED */
int
main (argc, argv, envp)
     int argc;
     char **argv;
     char **envp;
{
  char stack_bottom_variable;
  int skip_args = 0;
  extern int errno;
  extern int sys_nerr;
#ifdef HAVE_SETRLIMIT
  struct rlimit rlim;
#endif
  int no_loadup = 0;

#ifdef LINUX_SBRK_BUG
  __sbrk (1);
#endif

#ifdef RUN_TIME_REMAP
  if (initialized)
    run_time_remap (argv[0]);
#endif

  sort_args (argc, argv);
  argc = 0;
  while (argv[argc]) argc++;

  if (argmatch (argv, argc, "-version", "--version", 3, NULL, &skip_args)
      /* We don't know the version number unless this is a dumped Emacs.
         So ignore --version otherwise.  */
      && initialized)
    {
      Lisp_Object tem;
      tem = Fsymbol_value (intern ("emacs-version"));
      if (!STRINGP (tem))
	{
	  fprintf (stderr, "Invalid value of `emacs-version'\n");
	  exit (1);
	}
      else
	{
	  printf ("GNU Emacs %s\n", XSTRING (tem)->data);
	  printf ("Copyright (C) 1999 Free Software Foundation, Inc.\n");
	  printf ("GNU Emacs comes with ABSOLUTELY NO WARRANTY.\n");
	  printf ("You may redistribute copies of Emacs\n");
	  printf ("under the terms of the GNU General Public License.\n");
	  printf ("For more information about these matters, ");
	  printf ("see the file named COPYING.\n");
	  exit (0);
	}
    }

/* Map in shared memory, if we are using that.  */
#ifdef HAVE_SHM
  if (argmatch (argv, argc, "-nl", "--no-shared-memory", 6, NULL, &skip_args))
    {
      map_in_data (0);
      /* The shared memory was just restored, which clobbered this.  */
      skip_args = 1;
    }
  else
    {
      map_in_data (1);
      /* The shared memory was just restored, which clobbered this.  */
      skip_args = 0;
    }
#endif

#ifdef NeXT
  {
    extern int malloc_cookie;
    /* This helps out unexnext.c.  */
    if (initialized)
      if (malloc_jumpstart (malloc_cookie) != 0)
	printf ("malloc jumpstart failed!\n");
  }
#endif /* NeXT */

#ifdef VMS
  /* If -map specified, map the data file in */
  {
    char *file;
    if (argmatch (argv, argc, "-map", "--map-data", 3, &mapin_file, &skip_args))
      mapin_data (file);
  }

#ifdef LINK_CRTL_SHARE
#ifdef SHARABLE_LIB_BUG
  /* Bletcherous shared libraries! */
  if (!stdin)
    stdin = fdopen (0, "r");
  if (!stdout)
    stdout = fdopen (1, "w");
  if (!stderr)
    stderr = fdopen (2, "w");
  if (!environ)
    environ = envp;
#endif /* SHARABLE_LIB_BUG */
#endif /* LINK_CRTL_SHARE */
#endif /* VMS */

#if defined (HAVE_SETRLIMIT) && defined (RLIMIT_STACK)
  /* Extend the stack space available.
     Don't do that if dumping, since some systems (e.g. DJGPP)
     might define a smaller stack limit at that time.  */
  if (1
#ifndef CANNOT_DUMP
      && (!noninteractive || initialized)
#endif
      && !getrlimit (RLIMIT_STACK, &rlim))
    {
      long newlim;
      extern int re_max_failures;
      /* Approximate the amount regex.c needs per unit of re_max_failures.  */
      int ratio = 20 * sizeof (char *);
      /* Then add 33% to cover the size of the smaller stacks that regex.c
	 successively allocates and discards, on its way to the maximum.  */
      ratio += ratio / 3;
      /* Add in some extra to cover
	 what we're likely to use for other reasons.  */
      newlim = re_max_failures * ratio + 200000;
#ifdef __NetBSD__
      /* NetBSD (at least NetBSD 1.2G and former) has a bug in its
       stack allocation routine for new process that the allocation
       fails if stack limit is not on page boundary.  So, round up the
       new limit to page boundary.  */
      newlim = (newlim + getpagesize () - 1) / getpagesize () * getpagesize();
#endif
      if (newlim > rlim.rlim_max)
	{
	  newlim = rlim.rlim_max;
	  /* Don't let regex.c overflow the stack we have.  */
	  re_max_failures = (newlim - 200000) / ratio;
	}
      if (rlim.rlim_cur < newlim)
	rlim.rlim_cur = newlim;

      setrlimit (RLIMIT_STACK, &rlim);
    }
#endif /* HAVE_SETRLIMIT and RLIMIT_STACK */

  /* Record (approximately) where the stack begins.  */
  stack_bottom = &stack_bottom_variable;

#ifdef USG_SHARED_LIBRARIES
  if (bss_end)
    brk ((void *)bss_end);
#endif

  clearerr (stdin);

#ifndef SYSTEM_MALLOC
  /* Arrange to get warning messages as memory fills up.  */
  memory_warnings (0, malloc_warning);

  /* Call malloc at least once, to run the initial __malloc_hook.
     Also call realloc and free for consistency.  */
  free (realloc (malloc (4), 4));

  /* Arrange to disable interrupt input inside malloc etc.  */
  uninterrupt_malloc ();
#endif	/* not SYSTEM_MALLOC */

#ifdef MSDOS
  /* We do all file input/output as binary files.  When we need to translate
     newlines, we do that manually.  */
  _fmode = O_BINARY;

#if __DJGPP__ >= 2
  if (!isatty (fileno (stdin)))
    setmode (fileno (stdin), O_BINARY);
  if (!isatty (fileno (stdout)))
    {
      fflush (stdout);
      setmode (fileno (stdout), O_BINARY);
    }
#else  /* not __DJGPP__ >= 2 */
  (stdin)->_flag &= ~_IOTEXT;
  (stdout)->_flag &= ~_IOTEXT;
  (stderr)->_flag &= ~_IOTEXT;
#endif /* not __DJGPP__ >= 2 */
#endif /* MSDOS */

#ifdef SET_EMACS_PRIORITY
  if (emacs_priority)
    nice (emacs_priority);
  setuid (getuid ());
#endif /* SET_EMACS_PRIORITY */

#ifdef EXTRA_INITIALIZE
  EXTRA_INITIALIZE;
#endif

  inhibit_window_system = 0;

  /* Handle the -t switch, which specifies filename to use as terminal */
  while (1)
    {
      char *term;
      if (argmatch (argv, argc, "-t", "--terminal", 4, &term, &skip_args))
	{
	  int result;
	  close (0);
	  close (1);
	  result = open (term, O_RDWR, 2 );
	  if (result < 0)
	    {
	      char *errstring = strerror (errno);
	      fprintf (stderr, "emacs: %s: %s\n", term, errstring);
	      exit (1);
	    }
	  dup (0);
	  if (! isatty (0))
	    {
	      fprintf (stderr, "emacs: %s: not a tty\n", term);
	      exit (1);
	    }
	  fprintf (stderr, "Using %s\n", term);
#ifdef HAVE_WINDOW_SYSTEM
	  inhibit_window_system = 1; /* -t => -nw */
#endif
	}
      else
	break;
    }

  if (argmatch (argv, argc, "-nw", "--no-windows", 6, NULL, &skip_args))
    inhibit_window_system = 1;

  /* Handle the -batch switch, which means don't do interactive display.  */
  noninteractive = 0;
  if (argmatch (argv, argc, "-batch", "--batch", 5, NULL, &skip_args))
    noninteractive = 1;

  /* Handle the --help option, which gives a usage message..  */
  if (argmatch (argv, argc, "-help", "--help", 3, NULL, &skip_args))
    {
      printf ("\
Usage: %s [--batch]  [-t term] [--terminal term]\n\
      [-d display] [--display display]  [-nw] [--no-windows]\n\
      [-q] [--no-init-file]  [-u user] [--user user]  [--debug-init]\n\
      [--unibyte] [--multibyte] [--version] [--no-site-file]\n\
      [-f func] [--funcall func]  [-l file] [--load file]  [--eval expr]\n\
      [--insert file] [+linenum] file-to-visit  [--kill]\n\
Report bugs to bug-gnu-emacs@gnu.org.  First, please see\n\
the Bugs section of the Emacs manual or the file BUGS.\n", argv[0]);
      exit (0);
    }

  if (! noninteractive)
    {
#ifdef BSD_PGRPS
      if (initialized)
	{
	  inherited_pgroup = EMACS_GETPGRP (0);
	  setpgrp (0, getpid ());
	}
#else
#if defined (USG5) && defined (INTERRUPT_INPUT)
      setpgrp ();
#endif
#endif
    }

#ifdef POSIX_SIGNALS
  init_signals ();
#endif

  /* Don't catch SIGHUP if dumping.  */
  if (1
#ifndef CANNOT_DUMP
      && initialized
#endif
      )
    {
      sigblock (sigmask (SIGHUP));
      /* In --batch mode, don't catch SIGHUP if already ignored.
	 That makes nohup work.  */
      if (! noninteractive
	  || signal (SIGHUP, SIG_IGN) != SIG_IGN)
	signal (SIGHUP, fatal_error_signal);
      sigunblock (sigmask (SIGHUP));
    }

  if (
#ifndef CANNOT_DUMP
      ! noninteractive || initialized
#else
      1
#endif
      )
    {
      /* Don't catch these signals in batch mode if dumping.
	 On some machines, this sets static data that would make
	 signal fail to work right when the dumped Emacs is run.  */
      signal (SIGQUIT, fatal_error_signal);
      signal (SIGILL, fatal_error_signal);
      signal (SIGTRAP, fatal_error_signal);
#ifdef SIGUSR1
      signal (SIGUSR1, handle_USR1_signal);
#ifdef SIGUSR2
      signal (SIGUSR2, handle_USR2_signal);
#endif
#endif
#ifdef SIGABRT
      signal (SIGABRT, fatal_error_signal);
#endif
#ifdef SIGHWE
      signal (SIGHWE, fatal_error_signal);
#endif
#ifdef SIGPRE
      signal (SIGPRE, fatal_error_signal);
#endif
#ifdef SIGORE
      signal (SIGORE, fatal_error_signal);
#endif
#ifdef SIGUME
      signal (SIGUME, fatal_error_signal);
#endif
#ifdef SIGDLK
      signal (SIGDLK, fatal_error_signal);
#endif
#ifdef SIGCPULIM
      signal (SIGCPULIM, fatal_error_signal);
#endif
#ifdef SIGIOT
      /* This is missing on some systems - OS/2, for example.  */
      signal (SIGIOT, fatal_error_signal);
#endif
#ifdef SIGEMT
      signal (SIGEMT, fatal_error_signal);
#endif
      signal (SIGFPE, fatal_error_signal);
#ifdef SIGBUS
      signal (SIGBUS, fatal_error_signal);
#endif
      signal (SIGSEGV, fatal_error_signal);
#ifdef SIGSYS
      signal (SIGSYS, fatal_error_signal);
#endif
      signal (SIGTERM, fatal_error_signal);
#ifdef SIGXCPU
      signal (SIGXCPU, fatal_error_signal);
#endif
#ifdef SIGXFSZ
      signal (SIGXFSZ, fatal_error_signal);
#endif /* SIGXFSZ */

#ifdef SIGDANGER
      /* This just means available memory is getting low.  */
      signal (SIGDANGER, memory_warning_signal);
#endif

#ifdef AIX
/* 20 is SIGCHLD, 21 is SIGTTIN, 22 is SIGTTOU.  */
      signal (SIGXCPU, fatal_error_signal);
#ifndef _I386
      signal (SIGIOINT, fatal_error_signal);
#endif
      signal (SIGGRANT, fatal_error_signal);
      signal (SIGRETRACT, fatal_error_signal);
      signal (SIGSOUND, fatal_error_signal);
      signal (SIGMSG, fatal_error_signal);
#endif /* AIX */
    }

  noninteractive1 = noninteractive;

/* Perform basic initializations (not merely interning symbols) */

  if (!initialized)
    {
      init_alloc_once ();
      init_obarray ();
      init_eval_once ();
      init_charset_once ();
      init_coding_once ();
      init_syntax_once ();	/* Create standard syntax table.  */
      init_category_once ();	/* Create standard category table.  */
		      /* Must be done before init_buffer */
      init_casetab_once ();
      init_buffer_once ();	/* Create buffer table and some buffers */
      init_minibuf_once ();	/* Create list of minibuffers */
			      /* Must precede init_window_once */
      init_window_once ();	/* Init the window system */
      init_fileio_once ();	/* Must precede any path manipulation.  */
    }

  init_alloc ();
  init_eval ();
  init_coding ();
  init_data ();
#ifdef CLASH_DETECTION
  init_filelock ();;
#endif
  running_asynch_code = 0;

  /* Handle --unibyte and the EMACS_UNIBYTE envvar,
     but not while dumping.  */
  if (
#ifndef CANNOT_DUMP
      ! noninteractive || initialized
#else
      1
#endif
      )
    {
      int inhibit_unibyte = 0;

      /* --multibyte overrides EMACS_UNIBYTE.  */
      if (argmatch (argv, argc, "-no-unibyte", "--no-unibyte", 4, NULL, &skip_args)
	  || argmatch (argv, argc, "-multibyte", "--multibyte", 4, NULL, &skip_args))
	inhibit_unibyte = 1;

      /* --unibyte requests that we set up to do everything with single-byte
	 buffers and strings.  We need to handle this before calling
	 init_lread, init_editfns and other places that generate Lisp strings
	 from text in the environment.  */
      /* Actually this shouldn't be needed as of 20.4 in a generally
	 unibyte environment.  As handa says, environment values
	 aren't now decoded; also existing buffers are now made
	 unibyte during startup if .emacs sets unibyte.  Tested with
	 8-bit data in environment variables and /etc/passwd, setting
	 unibyte and Latin-1 in .emacs. -- Dave Love */
      if (argmatch (argv, argc, "-unibyte", "--unibyte", 4, NULL, &skip_args)
	  || argmatch (argv, argc, "-no-multibyte", "--no-multibyte", 4, NULL, &skip_args)
	  || (getenv ("EMACS_UNIBYTE") && !inhibit_unibyte))
	{
	  Lisp_Object old_log_max;
	  Lisp_Object symbol, tail;

	  symbol = intern ("default-enable-multibyte-characters");
	  Fset (symbol, Qnil);

	  if (initialized)
	    {
	      /* Erase pre-dump messages in *Messages* now so no abort.  */
	      old_log_max = Vmessage_log_max;
	      XSETFASTINT (Vmessage_log_max, 0);
	      message_dolog ("", 0, 1, 0);
	      Vmessage_log_max = old_log_max;
	    }

	  for (tail = Vbuffer_alist; CONSP (tail);
	       tail = XCONS (tail)->cdr)
	    {
	      Lisp_Object buffer;

	      buffer = Fcdr (XCONS (tail)->car);
	      /* Verify that all buffers are empty now, as they
		 ought to be.  */
	      if (BUF_Z (XBUFFER (buffer)) > BUF_BEG (XBUFFER (buffer)))
		abort ();
	      /* It is safe to do this crudely in an empty buffer.  */
	      XBUFFER (buffer)->enable_multibyte_characters = Qnil;
	    }
	}
    }

  no_loadup
    = !argmatch (argv, argc, "-nl", "--no-loadup", 6, NULL, &skip_args);


#ifdef HAVE_X_WINDOWS
  /* Stupid kludge to catch command-line display spec.  We can't
     handle this argument entirely in window system dependent code
     because we don't even know which window system dependent code
     to run until we've recognized this argument.  */
  {
    char *displayname = 0;
    int i;
    int count_before = skip_args;

    /* Skip any number of -d options, but only use the last one.  */
    while (1)
      {
	int count_before_this = skip_args;

	if (argmatch (argv, argc, "-d", "--display", 3, &displayname, &skip_args))
	  display_arg = 1;
	else if (argmatch (argv, argc, "-display", 0, 3, &displayname, &skip_args))
	  display_arg = 1;
	else
	  break;

	count_before = count_before_this;
      }

    /* If we have the form --display=NAME,
       convert it into  -d name.
       This requires inserting a new element into argv.  */
    if (displayname != 0 && skip_args - count_before == 1)
      {
	char **new = (char **) xmalloc (sizeof (char *) * (argc + 2));
	int j;

	for (j = 0; j < count_before + 1; j++)
	  new[j] = argv[j];
	new[count_before + 1] = "-d";
	new[count_before + 2] = displayname;
	for (j = count_before + 2; j <argc; j++)
	  new[j + 1] = argv[j];
	argv = new;
	argc++;
      }
    /* Change --display to -d, when its arg is separate.  */
    else if (displayname != 0 && skip_args > count_before
	     && argv[count_before + 1][1] == '-')
      argv[count_before + 1] = "-d";

    /* Don't actually discard this arg.  */
    skip_args = count_before;
  }
#endif

  /* argmatch must not be used after here,
     except when bulding temacs
     because the -d argument has not been skipped in skip_args.  */

#ifdef MSDOS
  /* Call early 'cause init_environment needs it.  */
  init_dosfns ();
  /* Set defaults for several environment variables.  */
  if (initialized)
    init_environment (argc, argv, skip_args);
  else
    tzset ();
#endif /* MSDOS */

#ifdef WINDOWSNT
  /* Initialize environment from registry settings.  */
  init_environment (argv);
  init_ntproc ();	/* must precede init_editfns */
#endif

  /* egetenv is a pretty low-level facility, which may get called in
     many circumstances; it seems flimsy to put off initializing it
     until calling init_callproc.  */
  set_process_environment ();
  /* AIX crashes are reported in system versions 3.2.3 and 3.2.4
     if this is not done.  Do it after set_process_environment so that we
     don't pollute Vprocess_environment.  */
  /* Setting LANG here will defeat the startup locale processing...  */
#ifdef AIX3_2
  putenv ("LANG=C");
#endif

  init_buffer ();	/* Init default directory of main buffer */

  init_callproc_1 ();	/* Must precede init_cmdargs and init_sys_modes.  */
  init_cmdargs (argc, argv, skip_args);	/* Must precede init_lread.  */

  if (initialized)
    {
      /* Erase any pre-dump messages in the message log, to avoid confusion */
      Lisp_Object old_log_max;
      old_log_max = Vmessage_log_max;
      XSETFASTINT (Vmessage_log_max, 0);
      message_dolog ("", 0, 1, 0);
      Vmessage_log_max = old_log_max;
    }

  init_callproc ();	/* Must follow init_cmdargs but not init_sys_modes.  */
  init_lread ();

  /* Intern the names of all standard functions and variables;
     define standard keys.  */

  if (!initialized)
    {
      /* The basic levels of Lisp must come first */
      /* And data must come first of all
	 for the sake of symbols like error-message */
      syms_of_data ();
      syms_of_alloc ();
      syms_of_lread ();
      syms_of_print ();
      syms_of_eval ();
      syms_of_fns ();
      syms_of_floatfns ();

      syms_of_abbrev ();
      syms_of_buffer ();
      syms_of_bytecode ();
      syms_of_callint ();
      syms_of_casefiddle ();
      syms_of_casetab ();
      syms_of_callproc ();
      syms_of_category ();
      syms_of_ccl ();
      syms_of_charset ();
      syms_of_cmds ();
#ifndef NO_DIR_LIBRARY
      syms_of_dired ();
#endif /* not NO_DIR_LIBRARY */
      syms_of_display ();
      syms_of_doc ();
      syms_of_editfns ();
      syms_of_emacs ();
      syms_of_fileio ();
      syms_of_coding ();	/* This should be after syms_of_fileio.  */
#ifdef CLASH_DETECTION
      syms_of_filelock ();
#endif /* CLASH_DETECTION */
      syms_of_indent ();
      syms_of_insdel ();
      syms_of_keyboard ();
      syms_of_keymap ();
      syms_of_macros ();
      syms_of_marker ();
      syms_of_minibuf ();
      syms_of_mocklisp ();
      syms_of_process ();
      syms_of_search ();
      syms_of_frame ();
      syms_of_syntax ();
      syms_of_term ();
      syms_of_undo ();

      /* Only defined if Emacs is compiled with USE_TEXT_PROPERTIES */
      syms_of_textprop ();
#ifdef VMS
      syms_of_vmsproc ();
#endif /* VMS */
#ifdef WINDOWSNT
      syms_of_ntproc ();
#endif /* WINDOWSNT */
      syms_of_window ();
      syms_of_xdisp ();
#ifdef HAVE_X_WINDOWS
      syms_of_xterm ();
      syms_of_xfns ();
      syms_of_fontset ();
#ifdef HAVE_X11
      syms_of_xselect ();
#endif
#endif /* HAVE_X_WINDOWS */

#ifndef HAVE_NTGUI
      syms_of_xfaces ();
      syms_of_xmenu ();
#endif

#ifdef HAVE_NTGUI
      syms_of_w32term ();
      syms_of_w32fns ();
      syms_of_w32faces ();
      syms_of_w32select ();
      syms_of_w32menu ();
      syms_of_fontset ();
#endif /* HAVE_NTGUI */

#ifdef SYMS_SYSTEM
      SYMS_SYSTEM;
#endif

#ifdef SYMS_MACHINE
      SYMS_MACHINE;
#endif

      keys_of_casefiddle ();
      keys_of_cmds ();
      keys_of_buffer ();
      keys_of_keyboard ();
      keys_of_keymap ();
      keys_of_macros ();
      keys_of_minibuf ();
      keys_of_window ();
      keys_of_frame ();
    }

  if (!noninteractive)
    {
#ifdef VMS
      init_vms_input ();/* init_display calls get_frame_size, that needs this */
#endif /* VMS */
      init_display ();	/* Determine terminal type.  init_sys_modes uses results */
    }
  init_keyboard ();	/* This too must precede init_sys_modes */
#ifdef VMS
  init_vmsproc ();	/* And this too. */
#endif /* VMS */
  init_sys_modes ();	/* Init system terminal modes (RAW or CBREAK, etc.) */
  init_xdisp ();
  init_macros ();
  init_editfns ();
#ifdef LISP_FLOAT_TYPE
  init_floatfns ();
#endif
#ifdef VMS
  init_vmsfns ();
#endif /* VMS */
  init_process ();

  if (!initialized)
    {
      char *file;
      /* Handle -l loadup, args passed by Makefile. */
      if (argmatch (argv, argc, "-l", "--load", 3, &file, &skip_args))
	Vtop_level = Fcons (intern ("load"),
			    Fcons (build_string (file), Qnil));
#ifdef CANNOT_DUMP
      /* Unless next switch is -nl, load "loadup.el" first thing.  */
      if (! no_loadup)
	Vtop_level = Fcons (intern ("load"),
			    Fcons (build_string ("loadup.el"), Qnil));
#endif /* CANNOT_DUMP */
    }

  if (initialized)
    {
#ifdef HAVE_TZSET
      {
	/* If the execution TZ happens to be the same as the dump TZ,
	   change it to some other value and then change it back,
	   to force the underlying implementation to reload the TZ info.
	   This is needed on implementations that load TZ info from files,
	   since the TZ file contents may differ between dump and execution.  */
	char *tz = getenv ("TZ");
	if (tz && !strcmp (tz, dump_tz))
	  {
	    ++*tz;
	    tzset ();
	    --*tz;
	  }
      }
#endif
    }

  /* Gerd Moellmann <gerd@acm.org> says this makes profiling work on
     FreeBSD.  It might work on some other systems too.
     Give it a try and tell me if it works on your system.  */
#ifdef __FreeBSD__
#ifdef PROFILING
  if (initialized)
    {
      extern void _mcleanup ();       
      extern char etext;
      extern Lisp_Object Fredraw_frame ();
      atexit (_mcleanup);
      /* This uses Fredraw_frame because that function
	 comes first in the Emacs executable.
	 It might be better to use something that gives
	 the start of the text segment, but start_of_text
	 is not defined on all systems now.  */
      monstartup (Fredraw_frame, &etext);
    }
  else
    moncontrol (0);
#endif
#endif

  initialized = 1;

#ifdef LOCALTIME_CACHE
  /* Some versions of localtime have a bug.  They cache the value of the time
     zone rather than looking it up every time.  Since localtime() is
     called to bolt the undumping time into the undumped emacs, this
     results in localtime ignoring the TZ environment variable.
     This flushes the new TZ value into localtime. */
  tzset ();
#endif /* defined (LOCALTIME_CACHE) */

  /* Enter editor command loop.  This never returns.  */
  Frecursive_edit ();
  /* NOTREACHED */
}

/* Sort the args so we can find the most important ones
   at the beginning of argv.  */

/* First, here's a table of all the standard options.  */

struct standard_args
{
  char *name;
  char *longname;
  int priority;
  int nargs;
};

struct standard_args standard_args[] =
{
  { "-version", "--version", 150, 0 },
#ifdef HAVE_SHM
  { "-nl", "--no-shared-memory", 140, 0 },
#endif
#ifdef VMS
  { "-map", "--map-data", 130, 0 },
#endif
  { "-t", "--terminal", 120, 1 },
  { "-nw", "--no-windows", 110, 0 },
  { "-batch", "--batch", 100, 0 },
  { "-help", "--help", 90, 0 },
  { "-no-unibyte", "--no-unibyte", 83, 0 },
  { "-multibyte", "--multibyte", 82, 0 },
  { "-unibyte", "--unibyte", 81, 0 },
  { "-no-multibyte", "--no-multibyte", 80, 0 },
#ifdef CANNOT_DUMP
  { "-nl", "--no-loadup", 70, 0 },
#endif
  /* -d must come last before the options handled in startup.el.  */
  { "-d", "--display", 60, 1 },
  { "-display", 0, 60, 1 },
  /* Now for the options handled in startup.el.  */
  { "-q", "--no-init-file", 50, 0 },
  { "-no-init-file", 0, 50, 0 },
  { "-no-site-file", "--no-site-file", 40, 0 },
  { "-u", "--user", 30, 1 },
  { "-user", 0, 30, 1 },
  { "-debug-init", "--debug-init", 20, 0 },
  { "-i", "--icon-type", 15, 0 },
  { "-itype", 0, 15, 0 },
  { "-iconic", "--iconic", 15, 0 },
  { "-bg", "--background-color", 10, 1 },
  { "-background", 0, 10, 1 },
  { "-fg", "--foreground-color", 10, 1 },
  { "-foreground", 0, 10, 1 },
  { "-bd", "--border-color", 10, 1 },
  { "-bw", "--border-width", 10, 1 },
  { "-ib", "--internal-border", 10, 1 },
  { "-ms", "--mouse-color", 10, 1 },
  { "-cr", "--cursor-color", 10, 1 },
  { "-fn", "--font", 10, 1 },
  { "-font", 0, 10, 1 },
  { "-g", "--geometry", 10, 1 },
  { "-geometry", 0, 10, 1 },
  { "-T", "--title", 10, 1 },
  { "-title", 0, 10, 1 },
  { "-name", "--name", 10, 1 },
  { "-xrm", "--xrm", 10, 1 },
  { "-r", "--reverse-video", 5, 0 },
  { "-rv", 0, 5, 0 },
  { "-reverse", 0, 5, 0 },
  { "-hb", "--horizontal-scroll-bars", 5, 0 },
  { "-vb", "--vertical-scroll-bars", 5, 0 },
  /* These have the same priority as ordinary file name args,
     so they are not reordered with respect to those.  */
  { "-L", "--directory", 0, 1 },
  { "-directory", 0, 0, 1 },
  { "-l", "--load", 0, 1 },
  { "-load", 0, 0, 1 },
  { "-f", "--funcall", 0, 1 },
  { "-funcall", 0, 0, 1 },
  { "-eval", "--eval", 0, 1 },
  { "-find-file", "--find-file", 0, 1 },
  { "-visit", "--visit", 0, 1 },
  { "-insert", "--insert", 0, 1 },
  /* This should be processed after ordinary file name args and the like.  */
  { "-kill", "--kill", -10, 0 },
};

/* Reorder the elements of ARGV (assumed to have ARGC elements)
   so that the highest priority ones come first.
   Do not change the order of elements of equal priority.
   If an option takes an argument, keep it and its argument together.

   If an option that takes no argument appears more
   than once, eliminate all but one copy of it.  */

static void
sort_args (argc, argv)
     int argc;
     char **argv;
{
  char **new = (char **) xmalloc (sizeof (char *) * argc);
  /* For each element of argv,
     the corresponding element of options is:
     0 for an option that takes no arguments,
     1 for an option that takes one argument, etc.
     -1 for an ordinary non-option argument.  */
  int *options = (int *) xmalloc (sizeof (int) * argc);
  int *priority = (int *) xmalloc (sizeof (int) * argc);
  int to = 1;
  int incoming_used = 1;
  int from;
  int i;
  int end_of_options = argc;

  /* Categorize all the options,
     and figure out which argv elts are option arguments.  */
  for (from = 1; from < argc; from++)
    {
      options[from] = -1;
      priority[from] = 0;
      if (argv[from][0] == '-')
	{
	  int match, thislen;
	  char *equals;

	  /* If we have found "--", don't consider
	     any more arguments as options.  */
	  if (argv[from][1] == '-' && argv[from][2] == 0)
	    {
	      /* Leave the "--", and everything following it, at the end.  */
	      for (; from < argc; from++)
		{
		  priority[from] = -100;
		  options[from] = -1;
		}
	      break;
	    }

	  /* Look for a match with a known old-fashioned option.  */
	  for (i = 0; i < sizeof (standard_args) / sizeof (standard_args[0]); i++)
	    if (!strcmp (argv[from], standard_args[i].name))
	      {
		options[from] = standard_args[i].nargs;
		priority[from] = standard_args[i].priority;
		if (from + standard_args[i].nargs >= argc)
		  fatal ("Option `%s' requires an argument\n", argv[from]);
		from += standard_args[i].nargs;
		goto done;
	      }

	  /* Look for a match with a known long option.
	     MATCH is -1 if no match so far, -2 if two or more matches so far,
	     >= 0 (the table index of the match) if just one match so far.  */
	  if (argv[from][1] == '-')
	    {
	      match = -1;
	      thislen = strlen (argv[from]);
	      equals = index (argv[from], '=');
	      if (equals != 0)
		thislen = equals - argv[from];

	      for (i = 0;
		   i < sizeof (standard_args) / sizeof (standard_args[0]); i++)
		if (standard_args[i].longname
		    && !strncmp (argv[from], standard_args[i].longname,
				 thislen))
		  {
		    if (match == -1)
		      match = i;
		    else
		      match = -2;
		  }

	      /* If we found exactly one match, use that.  */
	      if (match >= 0)
		{
		  options[from] = standard_args[match].nargs;
		  priority[from] = standard_args[match].priority;
		  /* If --OPTION=VALUE syntax is used,
		     this option uses just one argv element.  */
		  if (equals != 0)
		    options[from] = 0;
		  if (from + options[from] >= argc)
		    fatal ("Option `%s' requires an argument\n", argv[from]);
		  from += options[from];
		}
	    }
	done: ;
	}
    }

  /* Copy the arguments, in order of decreasing priority, to NEW.  */
  new[0] = argv[0];
  while (incoming_used < argc)
    {
      int best = -1;
      int best_priority = -9999;

      /* Find the highest priority remaining option.
	 If several have equal priority, take the first of them.  */
      for (from = 1; from < argc; from++)
	{
	  if (argv[from] != 0 && priority[from] > best_priority)
	    {
	      best_priority = priority[from];
	      best = from;
	    }
	  /* Skip option arguments--they are tied to the options.  */
	  if (options[from] > 0)
	    from += options[from];
	}
	    
      if (best < 0)
	abort ();

      /* Copy the highest priority remaining option, with its args, to NEW.
         Unless it is a duplicate of the previous one.  */
      if (! (options[best] == 0
	     && ! strcmp (new[to - 1], argv[best])))
	{
	  new[to++] = argv[best];
	  for (i = 0; i < options[best]; i++)
	    new[to++] = argv[best + i + 1];
	}

      incoming_used += 1 + (options[best] > 0 ? options[best] : 0);

      /* Clear out this option in ARGV.  */
      argv[best] = 0;
      for (i = 0; i < options[best]; i++)
	argv[best + i + 1] = 0;
    }

  /* If duplicate options were deleted, fill up extra space with null ptrs.  */
  while (to < argc)
    new[to++] = 0;

  bcopy (new, argv, sizeof (char *) * argc);

  free (options);
  free (new);
  free (priority);
}

DEFUN ("kill-emacs", Fkill_emacs, Skill_emacs, 0, 1, "P",
  "Exit the Emacs job and kill it.\n\
If ARG is an integer, return ARG as the exit program code.\n\
If ARG is a  string, stuff it as keyboard input.\n\n\
The value of `kill-emacs-hook', if not void,\n\
is a list of functions (of no args),\n\
all of which are called before Emacs is actually killed.")
  (arg)
     Lisp_Object arg;
{
  Lisp_Object hook, hook1;
  int i;
  struct gcpro gcpro1;

  GCPRO1 (arg);

  if (feof (stdin))
    arg = Qt;

  if (!NILP (Vrun_hooks) && !noninteractive)
    call1 (Vrun_hooks, intern ("kill-emacs-hook"));

  UNGCPRO;

/* Is it really necessary to do this deassign
   when we are going to exit anyway?  */
/* #ifdef VMS
  stop_vms_input ();
 #endif  */

  shut_down_emacs (0, 0, STRINGP (arg) ? arg : Qnil);

  /* If we have an auto-save list file,
     kill it because we are exiting Emacs deliberately (not crashing).
     Do it after shut_down_emacs, which does an auto-save.  */
  if (STRINGP (Vauto_save_list_file_name))
    unlink (XSTRING (Vauto_save_list_file_name)->data);

  exit (INTEGERP (arg) ? XINT (arg)
#ifdef VMS
	: 1
#else
	: 0
#endif
	);
  /* NOTREACHED */
}


/* Perform an orderly shutdown of Emacs.  Autosave any modified
   buffers, kill any child processes, clean up the terminal modes (if
   we're in the foreground), and other stuff like that.  Don't perform
   any redisplay; this may be called when Emacs is shutting down in
   the background, or after its X connection has died.

   If SIG is a signal number, print a message for it.

   This is called by fatal signal handlers, X protocol error handlers,
   and Fkill_emacs.  */

void
shut_down_emacs (sig, no_x, stuff)
     int sig, no_x;
     Lisp_Object stuff;
{
  /* Prevent running of hooks from now on.  */
  Vrun_hooks = Qnil;

  /* If we are controlling the terminal, reset terminal modes */
#ifdef EMACS_HAVE_TTY_PGRP
  {
    int pgrp = EMACS_GETPGRP (0);

    int tpgrp;
    if (EMACS_GET_TTY_PGRP (0, &tpgrp) != -1
	&& tpgrp == pgrp)
      {
	fflush (stdout);
	reset_sys_modes ();
	if (sig && sig != SIGTERM)
	  fprintf (stderr, "Fatal error (%d).", sig);
      }
  }
#else
  fflush (stdout);
  reset_sys_modes ();
#endif

  stuff_buffered_input (stuff);

  kill_buffer_processes (Qnil);
  Fdo_auto_save (Qt, Qnil);

#ifdef CLASH_DETECTION
  unlock_all_files ();
#endif

#ifdef VMS
  kill_vms_processes ();
#endif

#if 0 /* This triggers a bug in XCloseDisplay and is not needed.  */
#ifdef HAVE_X_WINDOWS
  /* It's not safe to call intern here.  Maybe we are crashing.  */
  if (!noninteractive && SYMBOLP (Vwindow_system)
      && XSYMBOL (Vwindow_system)->name->size == 1
      && XSYMBOL (Vwindow_system)->name->data[0] == 'x'
      && ! no_x)
    Fx_close_current_connection ();
#endif /* HAVE_X_WINDOWS */
#endif

#ifdef SIGIO
  /* There is a tendency for a SIGIO signal to arrive within exit,
     and cause a SIGHUP because the input descriptor is already closed.  */
  unrequest_sigio ();
  signal (SIGIO, SIG_IGN);
#endif

#ifdef WINDOWSNT
  term_ntproc ();
#endif

#ifdef MSDOS
  dos_cleanup ();
#endif
}



#ifndef CANNOT_DUMP

#ifdef HAVE_SHM

DEFUN ("dump-emacs-data", Fdump_emacs_data, Sdump_emacs_data, 1, 1, 0,
  "Dump current state of Emacs into data file FILENAME.\n\
This function exists on systems that use HAVE_SHM.")
  (filename)
     Lisp_Object filename;
{
  extern char my_edata[];
  Lisp_Object tem;

  CHECK_STRING (filename, 0);
  filename = Fexpand_file_name (filename, Qnil);

  tem = Vpurify_flag;
  Vpurify_flag = Qnil;

  fflush (stdout);
  /* Tell malloc where start of impure now is */
  /* Also arrange for warnings when nearly out of space.  */
#ifndef SYSTEM_MALLOC
  memory_warnings (my_edata, malloc_warning);
#endif
  map_out_data (XSTRING (filename)->data);

  Vpurify_flag = tem;

  return Qnil;
}

#else /* not HAVE_SHM */

DEFUN ("dump-emacs", Fdump_emacs, Sdump_emacs, 2, 2, 0,
  "Dump current state of Emacs into executable file FILENAME.\n\
Take symbols from SYMFILE (presumably the file you executed to run Emacs).\n\
This is used in the file `loadup.el' when building Emacs.\n\
\n\
You must run Emacs in batch mode in order to dump it.")
  (filename, symfile)
     Lisp_Object filename, symfile;
{
  extern char my_edata[];
  Lisp_Object tem;
  Lisp_Object symbol;
  int count = specpdl_ptr - specpdl;

  if (! noninteractive)
    error ("Dumping Emacs works only in batch mode");

  /* Bind `command-line-processed' to nil before dumping,
     so that the dumped Emacs will process its command line
     and set up to work with X windows if appropriate.  */
  symbol = intern ("command-line-process");
  specbind (symbol, Qnil);

  CHECK_STRING (filename, 0);
  filename = Fexpand_file_name (filename, Qnil);
  if (!NILP (symfile))
    {
      CHECK_STRING (symfile, 0);
      if (XSTRING (symfile)->size)
	symfile = Fexpand_file_name (symfile, Qnil);
    }

  tem = Vpurify_flag;
  Vpurify_flag = Qnil;

#ifdef HAVE_TZSET
  set_time_zone_rule (dump_tz);
#ifndef LOCALTIME_CACHE
  /* Force a tz reload, since set_time_zone_rule doesn't.  */
  tzset ();
#endif
#endif

  fflush (stdout);
#ifdef VMS
  mapout_data (XSTRING (filename)->data);
#else
  /* Tell malloc where start of impure now is */
  /* Also arrange for warnings when nearly out of space.  */
#ifndef SYSTEM_MALLOC
#ifndef WINDOWSNT
  /* On Windows, this was done before dumping, and that once suffices.
     Meanwhile, my_edata is not valid on Windows.  */
  memory_warnings (my_edata, malloc_warning);
#endif /* not WINDOWSNT */
#endif
#ifdef DOUG_LEA_MALLOC
  malloc_state_ptr = malloc_get_state ();
#endif
  unexec (XSTRING (filename)->data,
	  !NILP (symfile) ? XSTRING (symfile)->data : 0, my_edata, 0, 0);
#ifdef DOUG_LEA_MALLOC
  free (malloc_state_ptr);
#endif
#endif /* not VMS */

  Vpurify_flag = tem;

  return unbind_to (count, Qnil);
}

#endif /* not HAVE_SHM */

#endif /* not CANNOT_DUMP */

#ifndef SEPCHAR
#define SEPCHAR ':'
#endif

Lisp_Object
decode_env_path (evarname, defalt)
     char *evarname, *defalt;
{
  register char *path, *p;
  Lisp_Object lpath, element, tem;

  /* It's okay to use getenv here, because this function is only used
     to initialize variables when Emacs starts up, and isn't called
     after that.  */
  if (evarname != 0)
    path = (char *) getenv (evarname);
  else
    path = 0;
  if (!path)
    path = defalt;
#ifdef DOS_NT
  /* Ensure values from the environment use the proper directory separator.  */
  if (path)
    {
      p = alloca (strlen (path) + 1);
      strcpy (p, path);
      path = p;

      if ('/' == DIRECTORY_SEP)
	dostounix_filename (path);
      else
	unixtodos_filename (path);
    }
#endif
  lpath = Qnil;
  while (1)
    {
      p = index (path, SEPCHAR);
      if (!p) p = path + strlen (path);
      element = (p - path ? make_string (path, p - path)
		 : build_string ("."));

      /* Add /: to the front of the name
	 if it would otherwise be treated as magic.  */
      tem = Ffind_file_name_handler (element, Qt);
      if (! NILP (tem))
	element = concat2 (build_string ("/:"), element);

      lpath = Fcons (element, lpath);
      if (*p)
	path = p + 1;
      else
	break;
    }
  return Fnreverse (lpath);
}

void
syms_of_emacs ()
{
  Qfile_name_handler_alist = intern ("file-name-handler-alist");
  staticpro (&Qfile_name_handler_alist);

#ifndef CANNOT_DUMP
#ifdef HAVE_SHM
  defsubr (&Sdump_emacs_data);
#else
  defsubr (&Sdump_emacs);
#endif
#endif

  defsubr (&Skill_emacs);

  defsubr (&Sinvocation_name);
  defsubr (&Sinvocation_directory);

  DEFVAR_LISP ("command-line-args", &Vcommand_line_args,
    "Args passed by shell to Emacs, as a list of strings.");

  DEFVAR_LISP ("system-type", &Vsystem_type,
    "Value is symbol indicating type of operating system you are using.");
  Vsystem_type = intern (SYSTEM_TYPE);

  DEFVAR_LISP ("system-configuration", &Vsystem_configuration,
    "Value is string indicating configuration Emacs was built for.");
  Vsystem_configuration = build_string (EMACS_CONFIGURATION);

  DEFVAR_LISP ("system-configuration-options", &Vsystem_configuration_options,
    "String containing the configuration options Emacs was built with.");
  Vsystem_configuration_options = build_string (EMACS_CONFIG_OPTIONS);

  DEFVAR_BOOL ("noninteractive", &noninteractive1,
    "Non-nil means Emacs is running without interactive terminal.");

  DEFVAR_LISP ("kill-emacs-hook", &Vkill_emacs_hook,
    "Hook to be run whenever kill-emacs is called.\n\
Since kill-emacs may be invoked when the terminal is disconnected (or\n\
in other similar situations), functions placed on this hook should not\n\
expect to be able to interact with the user.  To ask for confirmation,\n\
see `kill-emacs-query-functions' instead.");
  Vkill_emacs_hook = Qnil;

#ifdef SIGUSR1
  DEFVAR_LISP ("signal-USR1-hook", &Vsignal_USR1_hook,
    "Hook to be run whenever emacs receives a USR1 signal");
  Vsignal_USR1_hook = Qnil;
#ifdef SIGUSR2
  DEFVAR_LISP ("signal-USR2-hook", &Vsignal_USR2_hook,
    "Hook to be run whenever emacs receives a USR2 signal");
  Vsignal_USR2_hook = Qnil;
#endif
#endif


  DEFVAR_INT ("emacs-priority", &emacs_priority,
    "Priority for Emacs to run at.\n\
This value is effective only if set before Emacs is dumped,\n\
and only if the Emacs executable is installed with setuid to permit\n\
it to change priority.  (Emacs sets its uid back to the real uid.)\n\
Currently, you need to define SET_EMACS_PRIORITY in `config.h'\n\
before you compile Emacs, to enable the code for this feature.");
  emacs_priority = 0;

  DEFVAR_LISP ("path-separator", &Vpath_separator,
    "The directory separator in search paths, as a string.");
  {
    char c = SEPCHAR;
    Vpath_separator = make_string (&c, 1);
  }

  DEFVAR_LISP ("invocation-name", &Vinvocation_name,
    "The program name that was used to run Emacs.\n\
Any directory names are omitted.");

  DEFVAR_LISP ("invocation-directory", &Vinvocation_directory,
    "The directory in which the Emacs executable was found, to run it.\n\
The value is nil if that directory's name is not known.");

  DEFVAR_LISP ("installation-directory", &Vinstallation_directory,
    "A directory within which to look for the `lib-src' and `etc' directories.\n\
This is non-nil when we can't find those directories in their standard\n\
installed locations, but we can find them\n\
near where the Emacs executable was found.");
  Vinstallation_directory = Qnil;
}
