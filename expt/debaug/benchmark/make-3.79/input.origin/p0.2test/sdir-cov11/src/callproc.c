/* Synchronous subprocess invocation for GNU Emacs.
   Copyright (C) 1985, 86, 87, 88, 93, 94, 95 Free Software Foundation, Inc.

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

extern int errno;
extern char *strerror ();

/* Define SIGCHLD as an alias for SIGCLD.  */

#if !defined (SIGCHLD) && defined (SIGCLD)
#define SIGCHLD SIGCLD
#endif /* SIGCLD */

#include <sys/types.h>

#include <sys/file.h>
#ifdef USG5
#define INCLUDED_FCNTL
#include <fcntl.h>
#endif

#ifdef WINDOWSNT
#define NOMINMAX
#include <windows.h>
#include <stdlib.h>	/* for proper declaration of environ */
#include <fcntl.h>
#include "w32.h"
#define _P_NOWAIT 1	/* from process.h */
#endif

#ifdef MSDOS	/* Demacs 1.1.1 91/10/16 HIRANO Satoshi */
#define INCLUDED_FCNTL
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/param.h>
#include <errno.h>
#endif /* MSDOS */

#ifndef O_RDONLY
#define O_RDONLY 0
#endif

#ifndef O_WRONLY
#define O_WRONLY 1
#endif

#include "lisp.h"
#include "commands.h"
#include "buffer.h"
#include "charset.h"
#include "ccl.h"
#include "coding.h"
#include <epaths.h>
#include "process.h"
#include "syssignal.h"
#include "systty.h"

#ifdef MSDOS
#include "msdos.h"
#endif

#ifdef VMS
extern noshare char **environ;
#else
extern char **environ;
#endif

#ifdef HAVE_SETPGID
#if !defined (USG) || defined (BSD_PGRPS)
#define setpgrp setpgid
#endif
#endif

#define max(a, b) ((a) > (b) ? (a) : (b))

Lisp_Object Vexec_path, Vexec_directory, Vdata_directory, Vdoc_directory;
Lisp_Object Vconfigure_info_directory;
Lisp_Object Vtemp_file_name_pattern;

Lisp_Object Vshell_file_name;

Lisp_Object Vprocess_environment;

#ifdef DOS_NT
Lisp_Object Qbuffer_file_type;
#endif /* DOS_NT */

/* True iff we are about to fork off a synchronous process or if we
   are waiting for it.  */
int synch_process_alive;

/* Nonzero => this is a string explaining death of synchronous subprocess.  */
char *synch_process_death;

/* If synch_process_death is zero,
   this is exit code of synchronous subprocess.  */
int synch_process_retcode;

extern Lisp_Object Vdoc_file_name;

extern Lisp_Object Vfile_name_coding_system, Vdefault_file_name_coding_system;

/* Clean up when exiting Fcall_process.
   On MSDOS, delete the temporary file on any kind of termination.
   On Unix, kill the process and any children on termination by signal.  */

/* Nonzero if this is termination due to exit.  */
static int call_process_exited;

#ifndef VMS  /* VMS version is in vmsproc.c.  */

static Lisp_Object
call_process_kill (fdpid)
     Lisp_Object fdpid;
{
  close (XFASTINT (Fcar (fdpid)));
  EMACS_KILLPG (XFASTINT (Fcdr (fdpid)), SIGKILL);
  synch_process_alive = 0;
  return Qnil;
}

Lisp_Object
call_process_cleanup (fdpid)
     Lisp_Object fdpid;
{
#ifdef MSDOS
  /* for MSDOS fdpid is really (fd . tempfile)  */
  register Lisp_Object file;
  file = Fcdr (fdpid);
  close (XFASTINT (Fcar (fdpid)));
  if (strcmp (XSTRING (file)-> data, NULL_DEVICE) != 0)
    unlink (XSTRING (file)->data);
#else /* not MSDOS */
  register int pid = XFASTINT (Fcdr (fdpid));


  if (call_process_exited)
    {
      close (XFASTINT (Fcar (fdpid)));
      return Qnil;
    }

  if (EMACS_KILLPG (pid, SIGINT) == 0)
    {
      int count = specpdl_ptr - specpdl;
      record_unwind_protect (call_process_kill, fdpid);
      message1 ("Waiting for process to die...(type C-g again to kill it instantly)");
      immediate_quit = 1;
      QUIT;
      wait_for_termination (pid);
      immediate_quit = 0;
      specpdl_ptr = specpdl + count; /* Discard the unwind protect.  */
      message1 ("Waiting for process to die...done");
    }
  synch_process_alive = 0;
  close (XFASTINT (Fcar (fdpid)));
#endif /* not MSDOS */
  return Qnil;
}

DEFUN ("call-process", Fcall_process, Scall_process, 1, MANY, 0,
  "Call PROGRAM synchronously in separate process.\n\
The remaining arguments are optional.\n\
The program's input comes from file INFILE (nil means `/dev/null').\n\
Insert output in BUFFER before point; t means current buffer;\n\
 nil for BUFFER means discard it; 0 means discard and don't wait.\n\
BUFFER can also have the form (REAL-BUFFER STDERR-FILE); in that case,\n\
REAL-BUFFER says what to do with standard output, as above,\n\
while STDERR-FILE says what to do with standard error in the child.\n\
STDERR-FILE may be nil (discard standard error output),\n\
t (mix it with ordinary output), or a file name string.\n\
\n\
Fourth arg DISPLAY non-nil means redisplay buffer as output is inserted.\n\
Remaining arguments are strings passed as command arguments to PROGRAM.\n\
\n\
If BUFFER is 0, `call-process' returns immediately with value nil.\n\
Otherwise it waits for PROGRAM to terminate\n\
and returns a numeric exit status or a signal description string.\n\
If you quit, the process is killed with SIGINT, or SIGKILL if you quit again.")
  (nargs, args)
     int nargs;
     register Lisp_Object *args;
{
  Lisp_Object infile, buffer, current_dir, display, path;
  int fd[2];
  int filefd;
  register int pid;
  char buf[16384];
  char *bufptr = buf;
  int bufsize = 16384;
  int count = specpdl_ptr - specpdl;

  register unsigned char **new_argv
    = (unsigned char **) alloca ((max (2, nargs - 2)) * sizeof (char *));
  struct buffer *old = current_buffer;
  /* File to use for stderr in the child.
     t means use same as standard output.  */
  Lisp_Object error_file;
#ifdef MSDOS	/* Demacs 1.1.1 91/10/16 HIRANO Satoshi */
  char *outf, *tempfile;
  int outfilefd;
#endif
#if 0
  int mask;
#endif
  struct coding_system process_coding; /* coding-system of process output */
  struct coding_system argument_coding;	/* coding-system of arguments */
  /* Set to the return value of Ffind_operation_coding_system.  */
  Lisp_Object coding_systems;

  /* Qt denotes that Ffind_operation_coding_system is not yet called.  */
  coding_systems = Qt;

  CHECK_STRING (args[0], 0);

  error_file = Qt;

#ifndef subprocesses
  /* Without asynchronous processes we cannot have BUFFER == 0.  */
  if (nargs >= 3 
      && (INTEGERP (CONSP (args[2]) ? XCAR (args[2]) : args[2])))
    error ("Operating system cannot handle asynchronous subprocesses");
#endif /* subprocesses */

  /* Decide the coding-system for giving arguments.  */
  {
    Lisp_Object val, *args2;
    int i;

    /* If arguments are supplied, we may have to encode them.  */
    if (nargs >= 5)
      {
	int must_encode = 0;

	for (i = 4; i < nargs; i++)
	  CHECK_STRING (args[i], i);

	for (i = 4; i < nargs; i++)
	  if (STRING_MULTIBYTE (args[i]))
	    must_encode = 1;

	if (!NILP (Vcoding_system_for_write))
	  val = Vcoding_system_for_write;
	else if (! must_encode)
	  val = Qnil;
	else
	  {
	    args2 = (Lisp_Object *) alloca ((nargs + 1) * sizeof *args2);
	    args2[0] = Qcall_process;
	    for (i = 0; i < nargs; i++) args2[i + 1] = args[i];
	    coding_systems = Ffind_operation_coding_system (nargs + 1, args2);
	    if (CONSP (coding_systems))
	      val = XCONS (coding_systems)->cdr;
	    else if (CONSP (Vdefault_process_coding_system))
	      val = XCONS (Vdefault_process_coding_system)->cdr;
	    else
	      val = Qnil;
	  }
	setup_coding_system (Fcheck_coding_system (val), &argument_coding);
      }
  }

  if (nargs >= 2 && ! NILP (args[1]))
    {
      infile = Fexpand_file_name (args[1], current_buffer->directory);
      CHECK_STRING (infile, 1);
    }
  else
    infile = build_string (NULL_DEVICE);

  if (nargs >= 3)
    {
      buffer = args[2];

      /* If BUFFER is a list, its meaning is
	 (BUFFER-FOR-STDOUT FILE-FOR-STDERR).  */
      if (CONSP (buffer))
	{
	  if (CONSP (XCONS (buffer)->cdr))
	    {
	      Lisp_Object stderr_file;
	      stderr_file = XCONS (XCONS (buffer)->cdr)->car;

	      if (NILP (stderr_file) || EQ (Qt, stderr_file))
		error_file = stderr_file;
	      else
		error_file = Fexpand_file_name (stderr_file, Qnil);
	    }

	  buffer = XCONS (buffer)->car;
	}

      if (!(EQ (buffer, Qnil)
	    || EQ (buffer, Qt)
	    || INTEGERP (buffer)))
	{
	  Lisp_Object spec_buffer;
	  spec_buffer = buffer;
	  buffer = Fget_buffer_create (buffer);
	  /* Mention the buffer name for a better error message.  */
	  if (NILP (buffer))
	    CHECK_BUFFER (spec_buffer, 2);
	  CHECK_BUFFER (buffer, 2);
	}
    }
  else 
    buffer = Qnil;

  /* Make sure that the child will be able to chdir to the current
     buffer's current directory, or its unhandled equivalent.  We
     can't just have the child check for an error when it does the
     chdir, since it's in a vfork.

     We have to GCPRO around this because Fexpand_file_name,
     Funhandled_file_name_directory, and Ffile_accessible_directory_p
     might call a file name handling function.  The argument list is
     protected by the caller, so all we really have to worry about is
     buffer.  */
  {
    struct gcpro gcpro1, gcpro2, gcpro3;

    current_dir = current_buffer->directory;

    GCPRO3 (infile, buffer, current_dir);

    current_dir
      = expand_and_dir_to_file (Funhandled_file_name_directory (current_dir),
				Qnil);
    if (NILP (Ffile_accessible_directory_p (current_dir)))
      report_file_error ("Setting current directory",
			 Fcons (current_buffer->directory, Qnil));

    UNGCPRO;
  }

  display = nargs >= 4 ? args[3] : Qnil;

  filefd = open (XSTRING (infile)->data, O_RDONLY, 0);
  if (filefd < 0)
    {
      report_file_error ("Opening process input file", Fcons (infile, Qnil));
    }
  /* Search for program; barf if not found.  */
  {
    struct gcpro gcpro1;

    GCPRO1 (current_dir);
    openp (Vexec_path, args[0], EXEC_SUFFIXES, &path, 1);
    UNGCPRO;
  }
  if (NILP (path))
    {
      close (filefd);
      report_file_error ("Searching for program", Fcons (args[0], Qnil));
    }
  new_argv[0] = XSTRING (path)->data;
  if (nargs > 4)
    {
      register int i;

      if (! CODING_REQUIRE_ENCODING (&argument_coding))
	{
	  for (i = 4; i < nargs; i++)
	    new_argv[i - 3] = XSTRING (args[i])->data;
	}
      else
	{
	  /* We must encode the arguments.  */
	  struct gcpro gcpro1, gcpro2, gcpro3;

	  GCPRO3 (infile, buffer, current_dir);
	  for (i = 4; i < nargs; i++)
	    {
	      int size = encoding_buffer_size (&argument_coding,
					       STRING_BYTES (XSTRING (args[i])));
	      unsigned char *dummy1 = (unsigned char *) alloca (size);
	      int dummy;

	      /* The Irix 4.0 compiler barfs if we eliminate dummy.  */
	      new_argv[i - 3] = dummy1;
	      argument_coding.mode |= CODING_MODE_LAST_BLOCK;
	      encode_coding (&argument_coding,
			     XSTRING (args[i])->data,
			     new_argv[i - 3],
			     STRING_BYTES (XSTRING (args[i])),
			     size);
	      new_argv[i - 3][argument_coding.produced] = 0;
	      /* We have to initialize CCL program status again.  */
	      if (argument_coding.type == coding_type_ccl)
		setup_ccl_program (&(argument_coding.spec.ccl.encoder), Qnil);
	    }
	  UNGCPRO;
	}
      new_argv[nargs - 3] = 0;
    }
  else
    new_argv[1] = 0;

#ifdef MSDOS /* MW, July 1993 */
  if ((outf = egetenv ("TMPDIR")))
    strcpy (tempfile = alloca (strlen (outf) + 20), outf);
  else
    {
      tempfile = alloca (20);
      *tempfile = '\0';
    }
  dostounix_filename (tempfile);
  if (*tempfile == '\0' || tempfile[strlen (tempfile) - 1] != '/') 
    strcat (tempfile, "/");
  strcat (tempfile, "detmp.XXX");
  mktemp (tempfile);

  outfilefd = creat (tempfile, S_IREAD | S_IWRITE);
  if (outfilefd < 0)
    {
      close (filefd);
      report_file_error ("Opening process output file",
			 Fcons (build_string (tempfile), Qnil));
    }
  fd[0] = filefd;
  fd[1] = outfilefd;
#endif /* MSDOS */

  if (INTEGERP (buffer))
    fd[1] = open (NULL_DEVICE, O_WRONLY), fd[0] = -1;
  else
    {
#ifndef MSDOS
      pipe (fd);
#endif
#if 0
      /* Replaced by close_process_descs */
      set_exclusive_use (fd[0]);
#endif
    }

  {
    /* child_setup must clobber environ in systems with true vfork.
       Protect it from permanent change.  */
    register char **save_environ = environ;
    register int fd1 = fd[1];
    int fd_error = fd1;

#if 0  /* Some systems don't have sigblock.  */
    mask = sigblock (sigmask (SIGCHLD));
#endif

    /* Record that we're about to create a synchronous process.  */
    synch_process_alive = 1;

    /* These vars record information from process termination.
       Clear them now before process can possibly terminate,
       to avoid timing error if process terminates soon.  */
    synch_process_death = 0;
    synch_process_retcode = 0;

    if (NILP (error_file))
      fd_error = open (NULL_DEVICE, O_WRONLY);
    else if (STRINGP (error_file))
      {
#ifdef DOS_NT
	fd_error = open (XSTRING (error_file)->data,
			 O_WRONLY | O_TRUNC | O_CREAT | O_TEXT,
			 S_IREAD | S_IWRITE);
#else  /* not DOS_NT */
	fd_error = creat (XSTRING (error_file)->data, 0666);
#endif /* not DOS_NT */
      }

    if (fd_error < 0)
      {
	close (filefd);
	if (fd[0] != filefd)
	  close (fd[0]);
	if (fd1 >= 0)
	  close (fd1);
#ifdef MSDOS
	unlink (tempfile);
#endif
	report_file_error ("Cannot redirect stderr",
			   Fcons ((NILP (error_file)
				   ? build_string (NULL_DEVICE) : error_file),
				  Qnil));
      }

    current_dir = ENCODE_FILE (current_dir);

#ifdef MSDOS /* MW, July 1993 */
    /* Note that on MSDOS `child_setup' actually returns the child process
       exit status, not its PID, so we assign it to `synch_process_retcode'
       below.  */
    pid = child_setup (filefd, outfilefd, fd_error, (char **) new_argv,
		       0, current_dir);

    /* Record that the synchronous process exited and note its
       termination status.  */
    synch_process_alive = 0;
    synch_process_retcode = pid;
    if (synch_process_retcode < 0)  /* means it couldn't be exec'ed */
      synch_process_death = strerror (errno);

    close (outfilefd);
    if (fd_error != outfilefd)
      close (fd_error);
    fd1 = -1; /* No harm in closing that one!  */
    /* Since CRLF is converted to LF within `decode_coding', we can
       always open a file with binary mode.  */
    fd[0] = open (tempfile, O_BINARY);
    if (fd[0] < 0)
      {
	unlink (tempfile);
	close (filefd);
	report_file_error ("Cannot re-open temporary file", Qnil);
      }
#else /* not MSDOS */
#ifdef WINDOWSNT
    pid = child_setup (filefd, fd1, fd_error, (char **) new_argv,
		       0, current_dir);
#else  /* not WINDOWSNT */
    pid = vfork ();

    if (pid == 0)
      {
	if (fd[0] >= 0)
	  close (fd[0]);
#ifdef HAVE_SETSID
        setsid ();
#endif
#if defined (USG) && !defined (BSD_PGRPS)
        setpgrp ();
#else
        setpgrp (pid, pid);
#endif /* USG */
	child_setup (filefd, fd1, fd_error, (char **) new_argv,
		     0, current_dir);
      }
#endif /* not WINDOWSNT */

    /* The MSDOS case did this already.  */
    if (fd_error >= 0)
      close (fd_error);
#endif /* not MSDOS */

    environ = save_environ;

    /* Close most of our fd's, but not fd[0]
       since we will use that to read input from.  */
    close (filefd);
    if (fd1 >= 0 && fd1 != fd_error)
      close (fd1);
  }

  if (pid < 0)
    {
      if (fd[0] >= 0)
	close (fd[0]);
      report_file_error ("Doing vfork", Qnil);
    }

  if (INTEGERP (buffer))
    {
      if (fd[0] >= 0)
	close (fd[0]);
#ifndef subprocesses
      /* If Emacs has been built with asynchronous subprocess support,
	 we don't need to do this, I think because it will then have
	 the facilities for handling SIGCHLD.  */
      wait_without_blocking ();
#endif /* subprocesses */
      return Qnil;
    }

  /* Enable sending signal if user quits below.  */
  call_process_exited = 0;

#ifdef MSDOS
  /* MSDOS needs different cleanup information.  */
  record_unwind_protect (call_process_cleanup,
			 Fcons (make_number (fd[0]), build_string (tempfile)));
#else
  record_unwind_protect (call_process_cleanup,
			 Fcons (make_number (fd[0]), make_number (pid)));
#endif /* not MSDOS */


  if (BUFFERP (buffer))
    Fset_buffer (buffer);

  if (NILP (buffer))
    {
      /* If BUFFER is nil, we must read process output once and then
	 discard it, so setup coding system but with nil.  */
      setup_coding_system (Qnil, &process_coding);
    }
  else
    {
      Lisp_Object val, *args2;

      val = Qnil;
      if (!NILP (Vcoding_system_for_read))
	val = Vcoding_system_for_read;
      else
	{
	  if (EQ (coding_systems, Qt))
	    {
	      int i;

	      args2 = (Lisp_Object *) alloca ((nargs + 1) * sizeof *args2);
	      args2[0] = Qcall_process;
	      for (i = 0; i < nargs; i++) args2[i + 1] = args[i];
	      coding_systems
		= Ffind_operation_coding_system (nargs + 1, args2);
	    }
	  if (CONSP (coding_systems))
	    val = XCONS (coding_systems)->car;
	  else if (CONSP (Vdefault_process_coding_system))
	    val = XCONS (Vdefault_process_coding_system)->car;
	  else
	    val = Qnil;
	}
      setup_coding_system (Fcheck_coding_system (val), &process_coding);
      /* In unibyte mode, character code conversion should not take
	 place but EOL conversion should.  So, setup raw-text or one
	 of the subsidiary according to the information just setup.  */
      if (NILP (current_buffer->enable_multibyte_characters)
	  && !NILP (val))
	setup_raw_text_coding_system (&process_coding);
    }

  immediate_quit = 1;
  QUIT;

  {
    register int nread;
    int first = 1;
    int total_read = 0;
    int carryover = 0;
    int display_on_the_fly = !NILP (display) && INTERACTIVE;
    struct coding_system saved_coding;

    saved_coding = process_coding;

    while (1)
      {
	/* Repeatedly read until we've filled as much as possible
	   of the buffer size we have.  But don't read
	   less than 1024--save that for the next bufferful.  */
	nread = carryover;
	while (nread < bufsize - 1024)
	  {
	    int this_read = read (fd[0], bufptr + nread, bufsize - nread);

	    if (this_read < 0)
	      goto give_up;

	    if (this_read == 0)
	      {
		process_coding.mode |= CODING_MODE_LAST_BLOCK;
		break;
	      }

	    nread += this_read;
	    total_read += this_read;

	    if (display_on_the_fly)
	      break;
	  }

	/* Now NREAD is the total amount of data in the buffer.  */
	immediate_quit = 0;
	
	if (!NILP (buffer))
	  {
	    if (process_coding.type == coding_type_no_conversion)
	      insert (bufptr, nread);
	    else
	      {			/* We have to decode the input.  */
		int size = decoding_buffer_size (&process_coding, nread);
		char *decoding_buf = (char *) xmalloc (size);

		decode_coding (&process_coding, bufptr, decoding_buf,
			       nread, size);
		if (display_on_the_fly
		    && saved_coding.type == coding_type_undecided
		    && process_coding.type != coding_type_undecided)
		  {
		    /* We have detected some coding system.  But,
		       there's a possibility that the detection was
		       done by insufficient data.  So, we give up
		       displaying on the fly.  */
		    xfree (decoding_buf);
		    display_on_the_fly = 0;
		    process_coding = saved_coding;
		    carryover = nread;
		    continue;
		  }
		if (process_coding.produced > 0)
		  insert (decoding_buf, process_coding.produced);
		xfree (decoding_buf);
		carryover = nread - process_coding.consumed;
		if (carryover > 0)
		  {
		    /* As CARRYOVER should not be that large, we had
		       better avoid overhead of bcopy.  */
		    char *p = bufptr + process_coding.consumed;
		    char *pend = p + carryover;
		    char *dst = bufptr;

		    while (p < pend) *dst++ = *p++;
		  }
	      }
	  }
	if (process_coding.mode & CODING_MODE_LAST_BLOCK)
	  {
	    if (carryover > 0)
	      insert (bufptr, carryover);
	    break;
	  }

	/* Make the buffer bigger as we continue to read more data,
	   but not past 64k.  */
	if (bufsize < 64 * 1024 && total_read > 32 * bufsize)
	  {
	    bufsize *= 2;
	    bufptr = (char *) alloca (bufsize);
	  }

	if (!NILP (display) && INTERACTIVE)
	  {
	    if (first)
	      prepare_menu_bars ();
	    first = 0;
	    redisplay_preserve_echo_area ();
	  }
	immediate_quit = 1;
	QUIT;
      }
  give_up: ;

  Vlast_coding_system_used = process_coding.symbol;

  /* If the caller required, let the buffer inherit the
     coding-system used to decode the process output.  */
  if (inherit_process_coding_system)
    call1 (intern ("after-insert-file-set-buffer-file-coding-system"),
	   make_number (total_read));
  }

  /* Wait for it to terminate, unless it already has.  */
  wait_for_termination (pid);

  immediate_quit = 0;

  set_buffer_internal (old);

  /* Don't kill any children that the subprocess may have left behind
     when exiting.  */
  call_process_exited = 1;

  unbind_to (count, Qnil);

  if (synch_process_death)
    return build_string (synch_process_death);
  return make_number (synch_process_retcode);
}
#endif

static Lisp_Object
delete_temp_file (name)
     Lisp_Object name;
{
  /* Use Fdelete_file (indirectly) because that runs a file name handler.
     We did that when writing the file, so we should do so when deleting.  */
  internal_delete_file (name);
}

DEFUN ("call-process-region", Fcall_process_region, Scall_process_region,
  3, MANY, 0,
  "Send text from START to END to a synchronous process running PROGRAM.\n\
The remaining arguments are optional.\n\
Delete the text if fourth arg DELETE is non-nil.\n\
\n\
Insert output in BUFFER before point; t means current buffer;\n\
 nil for BUFFER means discard it; 0 means discard and don't wait.\n\
BUFFER can also have the form (REAL-BUFFER STDERR-FILE); in that case,\n\
REAL-BUFFER says what to do with standard output, as above,\n\
while STDERR-FILE says what to do with standard error in the child.\n\
STDERR-FILE may be nil (discard standard error output),\n\
t (mix it with ordinary output), or a file name string.\n\
\n\
Sixth arg DISPLAY non-nil means redisplay buffer as output is inserted.\n\
Remaining args are passed to PROGRAM at startup as command args.\n\
\n\
If BUFFER is nil, `call-process-region' returns immediately with value nil.\n\
Otherwise it waits for PROGRAM to terminate\n\
and returns a numeric exit status or a signal description string.\n\
If you quit, the process is killed with SIGINT, or SIGKILL if you quit again.")
  (nargs, args)
     int nargs;
     register Lisp_Object *args;
{
  struct gcpro gcpro1;
  Lisp_Object filename_string;
  register Lisp_Object start, end;
  int count = specpdl_ptr - specpdl;
  /* Qt denotes we have not yet called Ffind_operation_coding_system.  */
  Lisp_Object coding_systems;
  Lisp_Object val, *args2;
  int i;
#ifdef DOS_NT
  char *tempfile;
  char *outf = '\0';

  if ((outf = egetenv ("TMPDIR"))
      || (outf = egetenv ("TMP"))
      || (outf = egetenv ("TEMP")))
    strcpy (tempfile = alloca (strlen (outf) + 20), outf);
  else
    {
      tempfile = alloca (20);
      *tempfile = '\0';
    }
  if (!IS_DIRECTORY_SEP (tempfile[strlen (tempfile) - 1]))
    strcat (tempfile, "/");
  if ('/' == DIRECTORY_SEP)
    dostounix_filename (tempfile);
  else
    unixtodos_filename (tempfile);
#ifdef WINDOWSNT
  strcat (tempfile, "emXXXXXX");
#else
  strcat (tempfile, "detmp.XXX");
#endif
#else /* not DOS_NT */
  char *tempfile = (char *) alloca (STRING_BYTES (XSTRING (Vtemp_file_name_pattern)) + 1);
  bcopy (XSTRING (Vtemp_file_name_pattern)->data, tempfile,
	 STRING_BYTES (XSTRING (Vtemp_file_name_pattern)) + 1);
#endif /* not DOS_NT */

  coding_systems = Qt;

  mktemp (tempfile);

  filename_string = build_string (tempfile);
  GCPRO1 (filename_string);
  start = args[0];
  end = args[1];
  /* Decide coding-system of the contents of the temporary file.  */
  if (!NILP (Vcoding_system_for_write))
    val = Vcoding_system_for_write;
  else if (NILP (current_buffer->enable_multibyte_characters))
    val = Qnil;
  else
    {
      args2 = (Lisp_Object *) alloca ((nargs + 1) * sizeof *args2);
      args2[0] = Qcall_process_region;
      for (i = 0; i < nargs; i++) args2[i + 1] = args[i];
      coding_systems = Ffind_operation_coding_system (nargs + 1, args2);
      if (CONSP (coding_systems))
	val = XCONS (coding_systems)->cdr;
      else if (CONSP (Vdefault_process_coding_system))
	val = XCONS (Vdefault_process_coding_system)->cdr;
      else
	val = Qnil;
    }

  {
    int count1 = specpdl_ptr - specpdl;

    specbind (intern ("coding-system-for-write"), val);
    Fwrite_region (start, end, filename_string, Qnil, Qlambda, Qnil, Qnil);

    unbind_to (count1, Qnil);
  }

  /* Note that Fcall_process takes care of binding 
     coding-system-for-read.  */

  record_unwind_protect (delete_temp_file, filename_string);

  if (nargs > 3 && !NILP (args[3]))
    Fdelete_region (start, end);

  if (nargs > 3)
    {
      args += 2;
      nargs -= 2;
    }
  else
    {
      args[0] = args[2];
      nargs = 2;
    }
  args[1] = filename_string;

  RETURN_UNGCPRO (unbind_to (count, Fcall_process (nargs, args)));
}

#ifndef VMS /* VMS version is in vmsproc.c.  */

static int relocate_fd ();

/* This is the last thing run in a newly forked inferior
   either synchronous or asynchronous.
   Copy descriptors IN, OUT and ERR as descriptors 0, 1 and 2.
   Initialize inferior's priority, pgrp, connected dir and environment.
   then exec another program based on new_argv.

   This function may change environ for the superior process.
   Therefore, the superior process must save and restore the value
   of environ around the vfork and the call to this function.

   SET_PGRP is nonzero if we should put the subprocess into a separate
   process group.  

   CURRENT_DIR is an elisp string giving the path of the current
   directory the subprocess should have.  Since we can't really signal
   a decent error from within the child, this should be verified as an
   executable directory by the parent.  */

int
child_setup (in, out, err, new_argv, set_pgrp, current_dir)
     int in, out, err;
     register char **new_argv;
     int set_pgrp;
     Lisp_Object current_dir;
{
  char **env;
  char *pwd_var;
#ifdef WINDOWSNT
  int cpid;
  HANDLE handles[3];
#endif /* WINDOWSNT */

  int pid = getpid ();

#ifdef SET_EMACS_PRIORITY
  {
    extern int emacs_priority;

    if (emacs_priority < 0)
      nice (- emacs_priority);
  }
#endif

#ifdef subprocesses
  /* Close Emacs's descriptors that this process should not have.  */
  close_process_descs ();
#endif
  /* DOS_NT isn't in a vfork, so if we are in the middle of load-file,
     we will lose if we call close_load_descs here.  */
#ifndef DOS_NT
  close_load_descs ();
#endif

  /* Note that use of alloca is always safe here.  It's obvious for systems
     that do not have true vfork or that have true (stack) alloca.
     If using vfork and C_ALLOCA it is safe because that changes
     the superior's static variables as if the superior had done alloca
     and will be cleaned up in the usual way.  */
  {
    register char *temp;
    register int i;

    i = STRING_BYTES (XSTRING (current_dir));
    pwd_var = (char *) alloca (i + 6);
    temp = pwd_var + 4;
    bcopy ("PWD=", pwd_var, 4);
    bcopy (XSTRING (current_dir)->data, temp, i);
    if (!IS_DIRECTORY_SEP (temp[i - 1])) temp[i++] = DIRECTORY_SEP;
    temp[i] = 0;

#ifndef DOS_NT
    /* We can't signal an Elisp error here; we're in a vfork.  Since
       the callers check the current directory before forking, this
       should only return an error if the directory's permissions
       are changed between the check and this chdir, but we should
       at least check.  */
    if (chdir (temp) < 0)
      _exit (errno);
#endif

#ifdef DOS_NT
    /* Get past the drive letter, so that d:/ is left alone.  */
    if (i > 2 && IS_DEVICE_SEP (temp[1]) && IS_DIRECTORY_SEP (temp[2]))
      {
	temp += 2;
	i -= 2;
      }
#endif

    /* Strip trailing slashes for PWD, but leave "/" and "//" alone.  */
    while (i > 2 && IS_DIRECTORY_SEP (temp[i - 1]))
      temp[--i] = 0;
  }

  /* Set `env' to a vector of the strings in Vprocess_environment.  */
  {
    register Lisp_Object tem;
    register char **new_env;
    register int new_length;

    new_length = 0;
    for (tem = Vprocess_environment;
	 CONSP (tem) && STRINGP (XCONS (tem)->car);
	 tem = XCONS (tem)->cdr)
      new_length++;

    /* new_length + 2 to include PWD and terminating 0.  */
    env = new_env = (char **) alloca ((new_length + 2) * sizeof (char *));

    /* If we have a PWD envvar, pass one down,
       but with corrected value.  */
    if (getenv ("PWD"))
      *new_env++ = pwd_var;

    /* Copy the Vprocess_environment strings into new_env.  */
    for (tem = Vprocess_environment;
	 CONSP (tem) && STRINGP (XCONS (tem)->car);
	 tem = XCONS (tem)->cdr)
      {
	char **ep = env;
	char *string = (char *) XSTRING (XCONS (tem)->car)->data;
	/* See if this string duplicates any string already in the env.
	   If so, don't put it in.
	   When an env var has multiple definitions,
	   we keep the definition that comes first in process-environment.  */
	for (; ep != new_env; ep++)
	  {
	    char *p = *ep, *q = string;
	    while (1)
	      {
		if (*q == 0)
		  /* The string is malformed; might as well drop it.  */
		  goto duplicate;
		if (*q != *p)
		  break;
		if (*q == '=')
		  goto duplicate;
		p++, q++;
	      }
	  }
	*new_env++ = string;
      duplicate: ;
      }
    *new_env = 0;
  }
#ifdef WINDOWSNT
  prepare_standard_handles (in, out, err, handles);
  set_process_dir (XSTRING (current_dir)->data);
#else  /* not WINDOWSNT */
  /* Make sure that in, out, and err are not actually already in
     descriptors zero, one, or two; this could happen if Emacs is
     started with its standard in, out, or error closed, as might
     happen under X.  */
  {
    int oin = in, oout = out;

    /* We have to avoid relocating the same descriptor twice!  */

    in = relocate_fd (in, 3);

    if (out == oin)
      out = in;
    else
      out = relocate_fd (out, 3);

    if (err == oin)
      err = in;
    else if (err == oout)
      err = out;
    else
      err = relocate_fd (err, 3);
  }

#ifndef MSDOS
  close (0);
  close (1);
  close (2);

  dup2 (in, 0);
  dup2 (out, 1);
  dup2 (err, 2);
  close (in);
  close (out);
  close (err);
#endif /* not MSDOS */
#endif /* not WINDOWSNT */

#if defined(USG) && !defined(BSD_PGRPS)
#ifndef SETPGRP_RELEASES_CTTY
  setpgrp ();			/* No arguments but equivalent in this case */
#endif
#else
  setpgrp (pid, pid);
#endif /* USG */
  /* setpgrp_of_tty is incorrect here; it uses input_fd.  */
  EMACS_SET_TTY_PGRP (0, &pid);

#ifdef vipc
  something missing here;
#endif /* vipc */

#ifdef MSDOS
  pid = run_msdos_command (new_argv, pwd_var + 4, in, out, err, env);
  if (pid == -1)
    /* An error occurred while trying to run the subprocess.  */
    report_file_error ("Spawning child process", Qnil);
  return pid;
#else  /* not MSDOS */
#ifdef WINDOWSNT
  /* Spawn the child.  (See ntproc.c:Spawnve).  */
  cpid = spawnve (_P_NOWAIT, new_argv[0], new_argv, env);
  reset_standard_handles (in, out, err, handles);
  if (cpid == -1)
    /* An error occurred while trying to spawn the process.  */
    report_file_error ("Spawning child process", Qnil);
  return cpid;
#else /* not WINDOWSNT */
  /* execvp does not accept an environment arg so the only way
     to pass this environment is to set environ.  Our caller
     is responsible for restoring the ambient value of environ.  */
  environ = env;
  execvp (new_argv[0], new_argv);

  write (1, "Can't exec program: ", 20);
  write (1, new_argv[0], strlen (new_argv[0]));
  write (1, "\n", 1);
  _exit (1);
#endif /* not WINDOWSNT */
#endif /* not MSDOS */
}

/* Move the file descriptor FD so that its number is not less than MINFD.
   If the file descriptor is moved at all, the original is freed.  */
static int
relocate_fd (fd, minfd)
     int fd, minfd;
{
  if (fd >= minfd)
    return fd;
  else
    {
      int new = dup (fd);
      if (new == -1)
	{
	  char *message1 = "Error while setting up child: ";
	  char *errmessage = strerror (errno);
	  char *message2 = "\n";
	  write (2, message1, strlen (message1));
	  write (2, errmessage, strlen (errmessage));
	  write (2, message2, strlen (message2));
	  _exit (1);
	}
      /* Note that we hold the original FD open while we recurse,
	 to guarantee we'll get a new FD if we need it.  */
      new = relocate_fd (new, minfd);
      close (fd);
      return new;
    }
}

static int
getenv_internal (var, varlen, value, valuelen)
     char *var;
     int varlen;
     char **value;
     int *valuelen;
{
  Lisp_Object scan;

  for (scan = Vprocess_environment; CONSP (scan); scan = XCONS (scan)->cdr)
    {
      Lisp_Object entry;

      entry = XCONS (scan)->car;
      if (STRINGP (entry)
	  && STRING_BYTES (XSTRING (entry)) > varlen
	  && XSTRING (entry)->data[varlen] == '='
#ifdef WINDOWSNT
	  /* NT environment variables are case insensitive.  */
	  && ! strnicmp (XSTRING (entry)->data, var, varlen)
#else  /* not WINDOWSNT */
	  && ! bcmp (XSTRING (entry)->data, var, varlen)
#endif /* not WINDOWSNT */
	  )
	{
	  *value    = (char *) XSTRING (entry)->data + (varlen + 1);
	  *valuelen = STRING_BYTES (XSTRING (entry)) - (varlen + 1);
	  return 1;
	}
    }

  return 0;
}

DEFUN ("getenv", Fgetenv, Sgetenv, 1, 1, 0,
  "Return the value of environment variable VAR, as a string.\n\
VAR should be a string.  Value is nil if VAR is undefined in the environment.\n\
This function consults the variable ``process-environment'' for its value.")
  (var)
     Lisp_Object var;
{
  char *value;
  int valuelen;

  CHECK_STRING (var, 0);
  if (getenv_internal (XSTRING (var)->data, STRING_BYTES (XSTRING (var)),
		       &value, &valuelen))
    return make_string (value, valuelen);
  else
    return Qnil;
}

/* A version of getenv that consults process_environment, easily
   callable from C.  */
char *
egetenv (var)
     char *var;
{
  char *value;
  int valuelen;

  if (getenv_internal (var, strlen (var), &value, &valuelen))
    return value;
  else
    return 0;
}

#endif /* not VMS */

/* This is run before init_cmdargs.  */
  
void
init_callproc_1 ()
{
  char *data_dir = egetenv ("EMACSDATA");
  char *doc_dir = egetenv ("EMACSDOC");

  Vdata_directory
    = Ffile_name_as_directory (build_string (data_dir ? data_dir 
					     : PATH_DATA));
  Vdoc_directory
    = Ffile_name_as_directory (build_string (doc_dir ? doc_dir
					     : PATH_DOC));

  /* Check the EMACSPATH environment variable, defaulting to the
     PATH_EXEC path from epaths.h.  */
  Vexec_path = decode_env_path ("EMACSPATH", PATH_EXEC);
  Vexec_directory = Ffile_name_as_directory (Fcar (Vexec_path));
  Vexec_path = nconc2 (decode_env_path ("PATH", ""), Vexec_path);
}

/* This is run after init_cmdargs, when Vinstallation_directory is valid.  */

void
init_callproc ()
{
  char *data_dir = egetenv ("EMACSDATA");
    
  register char * sh;
  Lisp_Object tempdir;

  if (!NILP (Vinstallation_directory))
    {
      /* Add to the path the lib-src subdir of the installation dir.  */
      Lisp_Object tem;
      tem = Fexpand_file_name (build_string ("lib-src"),
			       Vinstallation_directory);
#ifndef DOS_NT
	  /* MSDOS uses wrapped binaries, so don't do this.  */
      if (NILP (Fmember (tem, Vexec_path)))
	Vexec_path = nconc2 (Vexec_path, Fcons (tem, Qnil));
      
      Vexec_directory = Ffile_name_as_directory (tem);
#endif /* not DOS_NT */

      /* Maybe use ../etc as well as ../lib-src.  */
      if (data_dir == 0)
	{
	  tem = Fexpand_file_name (build_string ("etc"),
				   Vinstallation_directory);
	  Vdoc_directory = Ffile_name_as_directory (tem);
	}
    }

  /* Look for the files that should be in etc.  We don't use
     Vinstallation_directory, because these files are never installed
     near the executable, and they are never in the build
     directory when that's different from the source directory.

     Instead, if these files are not in the nominal place, we try the
     source directory.  */
  if (data_dir == 0)
    {
      Lisp_Object tem, tem1, newdir;

      tem = Fexpand_file_name (build_string ("GNU"), Vdata_directory);
      tem1 = Ffile_exists_p (tem);
      if (NILP (tem1))
	{
	  newdir = Fexpand_file_name (build_string ("../etc/"),
				      build_string (PATH_DUMPLOADSEARCH));
	  tem = Fexpand_file_name (build_string ("GNU"), newdir);
	  tem1 = Ffile_exists_p (tem);
	  if (!NILP (tem1))
	    Vdata_directory = newdir;
	}
    }

#ifndef CANNOT_DUMP
  if (initialized)
#endif
    {
      tempdir = Fdirectory_file_name (Vexec_directory);
      if (access (XSTRING (tempdir)->data, 0) < 0)
	dir_warning ("Warning: arch-dependent data dir (%s) does not exist.\n",
		     Vexec_directory);
    }

  tempdir = Fdirectory_file_name (Vdata_directory);
  if (access (XSTRING (tempdir)->data, 0) < 0)
    dir_warning ("Warning: arch-independent data dir (%s) does not exist.\n",
		 Vdata_directory);

#ifdef VMS
  Vshell_file_name = build_string ("*dcl*");
#else
  sh = (char *) getenv ("SHELL");
  Vshell_file_name = build_string (sh ? sh : "/bin/sh");
#endif

#ifdef VMS
  Vtemp_file_name_pattern = build_string ("tmp:emacsXXXXXX.");
#else
  if (getenv ("TMPDIR"))
    {
      char *dir = getenv ("TMPDIR");
      Vtemp_file_name_pattern
	= Fexpand_file_name (build_string ("emacsXXXXXX"),
			     build_string (dir));
    }
  else
    Vtemp_file_name_pattern = build_string ("/tmp/emacsXXXXXX");
#endif
}

void
set_process_environment ()
{
  register char **envp;

  Vprocess_environment = Qnil;
#ifndef CANNOT_DUMP
  if (initialized)
#endif
    for (envp = environ; *envp; envp++)
      Vprocess_environment = Fcons (build_string (*envp),
				    Vprocess_environment);
}

void
syms_of_callproc ()
{
#ifdef DOS_NT
  Qbuffer_file_type = intern ("buffer-file-type");
  staticpro (&Qbuffer_file_type);
#endif /* DOS_NT */

  DEFVAR_LISP ("shell-file-name", &Vshell_file_name,
    "*File name to load inferior shells from.\n\
Initialized from the SHELL environment variable.");

  DEFVAR_LISP ("exec-path", &Vexec_path,
    "*List of directories to search programs to run in subprocesses.\n\
Each element is a string (directory name) or nil (try default directory).");

  DEFVAR_LISP ("exec-directory", &Vexec_directory,
    "Directory for executables for Emacs to invoke.\n\
More generally, this includes any architecture-dependent files\n\
that are built and installed from the Emacs distribution.");

  DEFVAR_LISP ("data-directory", &Vdata_directory,
    "Directory of machine-independent files that come with GNU Emacs.\n\
These are files intended for Emacs to use while it runs.");

  DEFVAR_LISP ("doc-directory", &Vdoc_directory,
    "Directory containing the DOC file that comes with GNU Emacs.\n\
This is usually the same as data-directory.");

  DEFVAR_LISP ("configure-info-directory", &Vconfigure_info_directory,
    "For internal use by the build procedure only.\n\
This is the name of the directory in which the build procedure installed\n\
Emacs's info files; the default value for Info-default-directory-list\n\
includes this.");
  Vconfigure_info_directory = build_string (PATH_INFO);

  DEFVAR_LISP ("temp-file-name-pattern", &Vtemp_file_name_pattern,
    "Pattern for making names for temporary files.\n\
This is used by `call-process-region'.");
  /* This variable is initialized in init_callproc.  */

  DEFVAR_LISP ("process-environment", &Vprocess_environment,
    "List of environment variables for subprocesses to inherit.\n\
Each element should be a string of the form ENVVARNAME=VALUE.\n\
The environment which Emacs inherits is placed in this variable\n\
when Emacs starts.");

#ifndef VMS
  defsubr (&Scall_process);
  defsubr (&Sgetenv);
#endif
  defsubr (&Scall_process_region);
}
