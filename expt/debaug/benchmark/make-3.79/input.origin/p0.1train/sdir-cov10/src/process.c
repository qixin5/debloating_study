/* Asynchronous subprocess control for GNU Emacs.
   Copyright (C) 1985, 86, 87, 88, 93, 94, 95, 96, 1998
      Free Software Foundation, Inc.

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

#include <config.h>

/* This file is split into two parts by the following preprocessor
   conditional.  The 'then' clause contains all of the support for
   asynchronous subprocesses.  The 'else' clause contains stub
   versions of some of the asynchronous subprocess routines that are
   often called elsewhere in Emacs, so we don't have to #ifdef the
   sections that call them.  */


#ifdef subprocesses

#include <stdio.h>
#include <errno.h>
#include <setjmp.h>
#include <sys/types.h>		/* some typedefs are used in sys/file.h */
#include <sys/file.h>
#include <sys/stat.h>
#ifdef HAVE_UNISTD_H
#include <unistd.h>
#endif

#ifdef HAVE_SETPGID
#define setpgrp setpgid
#endif

#if defined(WINDOWSNT) || defined(UNIX98_PTYS)
#include <stdlib.h>
#include <fcntl.h>
#endif /* not WINDOWSNT */

#ifdef HAVE_SOCKETS	/* TCP connection support, if kernel can do it */
#include <sys/socket.h>
#include <netdb.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#ifdef NEED_NET_ERRNO_H
#include <net/errno.h>
#endif /* NEED_NET_ERRNO_H */
#endif /* HAVE_SOCKETS */

/* TERM is a poor-man's SLIP, used on Linux.  */
#ifdef TERM
#include <client.h>
#endif

/* On some systems, e.g. DGUX, inet_addr returns a 'struct in_addr'. */
#ifdef HAVE_BROKEN_INET_ADDR
#define IN_ADDR struct in_addr
#define NUMERIC_ADDR_ERROR (numeric_addr.s_addr == -1)
#else
#define IN_ADDR unsigned long
#define NUMERIC_ADDR_ERROR (numeric_addr == -1)
#endif

#if defined(BSD_SYSTEM) || defined(STRIDE)
#include <sys/ioctl.h>
#if !defined (O_NDELAY) && defined (HAVE_PTYS) && !defined(USG5)
#include <fcntl.h>
#endif /* HAVE_PTYS and no O_NDELAY */
#endif /* BSD_SYSTEM || STRIDE */

#ifdef BROKEN_O_NONBLOCK
#undef O_NONBLOCK
#endif /* BROKEN_O_NONBLOCK */

#ifdef NEED_BSDTTY
#include <bsdtty.h>
#endif

#ifdef IRIS
#include <sys/sysmacros.h>	/* for "minor" */
#endif /* not IRIS */

#include "systime.h"
#include "systty.h"

#include "lisp.h"
#include "window.h"
#include "buffer.h"
#include "charset.h"
#include "coding.h"
#include "process.h"
#include "termhooks.h"
#include "termopts.h"
#include "commands.h"
#include "frame.h"
#include "blockinput.h"
#include "keyboard.h"
#include "dispextern.h"

#define max(a, b) ((a) > (b) ? (a) : (b))

Lisp_Object Qprocessp;
Lisp_Object Qrun, Qstop, Qsignal, Qopen, Qclosed;
Lisp_Object Qlast_nonmenu_event;
/* Qexit is declared and initialized in eval.c.  */

/* a process object is a network connection when its childp field is neither
   Qt nor Qnil but is instead a cons cell (HOSTNAME PORTNUM).  */

#ifdef HAVE_SOCKETS
#define NETCONN_P(p) (GC_CONSP (XPROCESS (p)->childp))
#else
#define NETCONN_P(p) 0
#endif /* HAVE_SOCKETS */

/* Define first descriptor number available for subprocesses.  */
#ifdef VMS
#define FIRST_PROC_DESC 1
#else /* Not VMS */
#define FIRST_PROC_DESC 3
#endif

/* Define SIGCHLD as an alias for SIGCLD.  There are many conditionals
   testing SIGCHLD.  */

#if !defined (SIGCHLD) && defined (SIGCLD)
#define SIGCHLD SIGCLD
#endif /* SIGCLD */

#include "syssignal.h"

#include "syswait.h"

extern int errno;
extern char *strerror ();
#ifdef VMS
extern char *sys_errlist[];
#endif

#ifndef HAVE_H_ERRNO
extern int h_errno;
#endif

#ifndef SYS_SIGLIST_DECLARED
#ifndef VMS
#ifndef BSD4_1
#ifndef WINDOWSNT
#ifndef LINUX
extern char *sys_siglist[];
#endif /* not LINUX */
#else /* BSD4_1 */
char *sys_siglist[] =
  {
    "bum signal!!",
    "hangup",
    "interrupt",
    "quit",
    "illegal instruction",
    "trace trap",
    "iot instruction",
    "emt instruction",
    "floating point exception",
    "kill",
    "bus error",
    "segmentation violation",
    "bad argument to system call",
    "write on a pipe with no one to read it",
    "alarm clock",
    "software termination signal from kill",
    "status signal",
    "sendable stop signal not from tty",
    "stop signal from tty",
    "continue a stopped process",
    "child status has changed",
    "background read attempted from control tty",
    "background write attempted from control tty",
    "input record available at control tty",
    "exceeded CPU time limit",
    "exceeded file size limit"
    };
#endif /* not WINDOWSNT */
#endif
#endif /* VMS */
#endif /* ! SYS_SIGLIST_DECLARED */

/* t means use pty, nil means use a pipe,
   maybe other values to come.  */
static Lisp_Object Vprocess_connection_type;

#ifdef SKTPAIR
#ifndef HAVE_SOCKETS
#include <sys/socket.h>
#endif
#endif /* SKTPAIR */

/* These next two vars are non-static since sysdep.c uses them in the
   emulation of `select'.  */
/* Number of events of change of status of a process.  */
int process_tick;
/* Number of events for which the user or sentinel has been notified.  */
int update_tick;

#include "sysselect.h"

/* If we support a window system, turn on the code to poll periodically
   to detect C-g.  It isn't actually used when doing interrupt input.  */
#ifdef HAVE_WINDOW_SYSTEM
#define POLL_FOR_INPUT
#endif

/* Mask of bits indicating the descriptors that we wait for input on.  */

static SELECT_TYPE input_wait_mask;

/* Mask that excludes keyboard input descriptor (s).  */

static SELECT_TYPE non_keyboard_wait_mask;

/* Mask that excludes process input descriptor (s).  */

static SELECT_TYPE non_process_wait_mask;

/* The largest descriptor currently in use for a process object.  */
static int max_process_desc;

/* The largest descriptor currently in use for keyboard input.  */
static int max_keyboard_desc;

/* Nonzero means delete a process right away if it exits.  */
static int delete_exited_processes;

/* Indexed by descriptor, gives the process (if any) for that descriptor */
Lisp_Object chan_process[MAXDESC];

/* Alist of elements (NAME . PROCESS) */
Lisp_Object Vprocess_alist;

/* Buffered-ahead input char from process, indexed by channel.
   -1 means empty (no char is buffered).
   Used on sys V where the only way to tell if there is any
   output from the process is to read at least one char.
   Always -1 on systems that support FIONREAD.  */

/* Don't make static; need to access externally.  */
int proc_buffered_char[MAXDESC];

/* Table of `struct coding-system' for each process.  */
static struct coding_system *proc_decode_coding_system[MAXDESC];
static struct coding_system *proc_encode_coding_system[MAXDESC];

static Lisp_Object get_process ();

extern EMACS_TIME timer_check ();
extern int timers_run;

/* Maximum number of bytes to send to a pty without an eof.  */
static int pty_max_bytes;

extern Lisp_Object Vfile_name_coding_system, Vdefault_file_name_coding_system;

#ifdef HAVE_PTYS
/* The file name of the pty opened by allocate_pty.  */

static char pty_name[24];
#endif

/* Compute the Lisp form of the process status, p->status, from
   the numeric status that was returned by `wait'.  */

Lisp_Object status_convert ();

void
update_status (p)
     struct Lisp_Process *p;
{
  union { int i; WAITTYPE wt; } u;
  u.i = XFASTINT (p->raw_status_low) + (XFASTINT (p->raw_status_high) << 16);
  p->status = status_convert (u.wt);
  p->raw_status_low = Qnil;
  p->raw_status_high = Qnil;
}

/*  Convert a process status word in Unix format to 
    the list that we use internally.  */

Lisp_Object
status_convert (w)
     WAITTYPE w;
{
  if (WIFSTOPPED (w))
    return Fcons (Qstop, Fcons (make_number (WSTOPSIG (w)), Qnil));
  else if (WIFEXITED (w))
    return Fcons (Qexit, Fcons (make_number (WRETCODE (w)),
				WCOREDUMP (w) ? Qt : Qnil));
  else if (WIFSIGNALED (w))
    return Fcons (Qsignal, Fcons (make_number (WTERMSIG (w)),
				  WCOREDUMP (w) ? Qt : Qnil));
  else
    return Qrun;
}

/* Given a status-list, extract the three pieces of information
   and store them individually through the three pointers.  */

void
decode_status (l, symbol, code, coredump)
     Lisp_Object l;
     Lisp_Object *symbol;
     int *code;
     int *coredump;
{
  Lisp_Object tem;

  if (SYMBOLP (l))
    {
      *symbol = l;
      *code = 0;
      *coredump = 0;
    }
  else
    {
      *symbol = XCONS (l)->car;
      tem = XCONS (l)->cdr;
      *code = XFASTINT (XCONS (tem)->car);
      tem = XCONS (tem)->cdr;
      *coredump = !NILP (tem);
    }
}

/* Return a string describing a process status list.  */

Lisp_Object 
status_message (status)
     Lisp_Object status;
{
  Lisp_Object symbol;
  int code, coredump;
  Lisp_Object string, string2;

  decode_status (status, &symbol, &code, &coredump);

  if (EQ (symbol, Qsignal) || EQ (symbol, Qstop))
    {
      char *signame = 0;
      if (code < NSIG)
	{
#ifndef VMS
	  /* Cast to suppress warning if the table has const char *.  */
	  signame = (char *) sys_siglist[code];
#else
	  signame = sys_errlist[code];
#endif
	}
      if (signame == 0)
	signame = "unknown";
      string = build_string (signame);
      string2 = build_string (coredump ? " (core dumped)\n" : "\n");
      XSTRING (string)->data[0] = DOWNCASE (XSTRING (string)->data[0]);
      return concat2 (string, string2);
    }
  else if (EQ (symbol, Qexit))
    {
      if (code == 0)
	return build_string ("finished\n");
      string = Fnumber_to_string (make_number (code));
      string2 = build_string (coredump ? " (core dumped)\n" : "\n");
      return concat2 (build_string ("exited abnormally with code "),
		      concat2 (string, string2));
    }
  else
    return Fcopy_sequence (Fsymbol_name (symbol));
}

#ifdef HAVE_PTYS

/* Open an available pty, returning a file descriptor.
   Return -1 on failure.
   The file name of the terminal corresponding to the pty
   is left in the variable pty_name.  */

int
allocate_pty ()
{
  struct stat stb;
  register int c, i;
  int fd;

  /* Some systems name their pseudoterminals so that there are gaps in
     the usual sequence - for example, on HP9000/S700 systems, there
     are no pseudoterminals with names ending in 'f'.  So we wait for
     three failures in a row before deciding that we've reached the
     end of the ptys.  */
  int failed_count = 0;

#ifdef PTY_ITERATION
  PTY_ITERATION
#else
  for (c = FIRST_PTY_LETTER; c <= 'z'; c++)
    for (i = 0; i < 16; i++)
#endif
      {
#ifdef PTY_NAME_SPRINTF
	PTY_NAME_SPRINTF
#else
	sprintf (pty_name, "/dev/pty%c%x", c, i);
#endif /* no PTY_NAME_SPRINTF */

#ifdef PTY_OPEN
	PTY_OPEN;
#else /* no PTY_OPEN */
#ifdef IRIS
	/* Unusual IRIS code */
 	*ptyv = open ("/dev/ptc", O_RDWR | O_NDELAY, 0);
 	if (fd < 0)
 	  return -1;
	if (fstat (fd, &stb) < 0)
	  return -1;
#else /* not IRIS */
	if (stat (pty_name, &stb) < 0)
	  {
	    failed_count++;
	    if (failed_count >= 3)
	      return -1;
	  }
	else
	  failed_count = 0;
#ifdef O_NONBLOCK
	fd = open (pty_name, O_RDWR | O_NONBLOCK, 0);
#else
	fd = open (pty_name, O_RDWR | O_NDELAY, 0);
#endif
#endif /* not IRIS */
#endif /* no PTY_OPEN */

	if (fd >= 0)
	  {
	    /* check to make certain that both sides are available
	       this avoids a nasty yet stupid bug in rlogins */
#ifdef PTY_TTY_NAME_SPRINTF
	    PTY_TTY_NAME_SPRINTF
#else
            sprintf (pty_name, "/dev/tty%c%x", c, i);
#endif /* no PTY_TTY_NAME_SPRINTF */
#ifndef UNIPLUS
	    if (access (pty_name, 6) != 0)
	      {
		close (fd);
#if !defined(IRIS) && !defined(__sgi)
		continue;
#else
		return -1;
#endif /* IRIS */
	      }
#endif /* not UNIPLUS */
	    setup_pty (fd);
	    return fd;
	  }
      }
  return -1;
}
#endif /* HAVE_PTYS */

Lisp_Object
make_process (name)
     Lisp_Object name;
{
  struct Lisp_Vector *vec;
  register Lisp_Object val, tem, name1;
  register struct Lisp_Process *p;
  char suffix[10];
  register int i;

  vec = allocate_vectorlike ((EMACS_INT) VECSIZE (struct Lisp_Process));
  for (i = 0; i < VECSIZE (struct Lisp_Process); i++)
    vec->contents[i] = Qnil;
  vec->size = VECSIZE (struct Lisp_Process);
  p = (struct Lisp_Process *)vec;

  XSETINT (p->infd, -1);
  XSETINT (p->outfd, -1);
  XSETFASTINT (p->pid, 0);
  XSETFASTINT (p->tick, 0);
  XSETFASTINT (p->update_tick, 0);
  p->raw_status_low = Qnil;
  p->raw_status_high = Qnil;
  p->status = Qrun;
  p->mark = Fmake_marker ();

  /* If name is already in use, modify it until it is unused.  */

  name1 = name;
  for (i = 1; ; i++)
    {
      tem = Fget_process (name1);
      if (NILP (tem)) break;
      sprintf (suffix, "<%d>", i);
      name1 = concat2 (name, build_string (suffix));
    }
  name = name1;
  p->name = name;
  XSETPROCESS (val, p);
  Vprocess_alist = Fcons (Fcons (name, val), Vprocess_alist);
  return val;
}

void
remove_process (proc)
     register Lisp_Object proc;
{
  register Lisp_Object pair;

  pair = Frassq (proc, Vprocess_alist);
  Vprocess_alist = Fdelq (pair, Vprocess_alist);

  deactivate_process (proc);
}

DEFUN ("processp", Fprocessp, Sprocessp, 1, 1, 0,
  "Return t if OBJECT is a process.")
  (object)
     Lisp_Object object;
{
  return PROCESSP (object) ? Qt : Qnil;
}

DEFUN ("get-process", Fget_process, Sget_process, 1, 1, 0,
  "Return the process named NAME, or nil if there is none.")
  (name)
     register Lisp_Object name;
{
  if (PROCESSP (name))
    return name;
  CHECK_STRING (name, 0);
  return Fcdr (Fassoc (name, Vprocess_alist));
}

DEFUN ("get-buffer-process", Fget_buffer_process, Sget_buffer_process, 1, 1, 0,
  "Return the (or a) process associated with BUFFER.\n\
BUFFER may be a buffer or the name of one.")
  (buffer)
     register Lisp_Object buffer;
{
  register Lisp_Object buf, tail, proc;

  if (NILP (buffer)) return Qnil;
  buf = Fget_buffer (buffer);
  if (NILP (buf)) return Qnil;

  for (tail = Vprocess_alist; !NILP (tail); tail = Fcdr (tail))
    {
      proc = Fcdr (Fcar (tail));
      if (PROCESSP (proc) && EQ (XPROCESS (proc)->buffer, buf))
	return proc;
    }
  return Qnil;
}

/* This is how commands for the user decode process arguments.  It
   accepts a process, a process name, a buffer, a buffer name, or nil.
   Buffers denote the first process in the buffer, and nil denotes the
   current buffer.  */

static Lisp_Object
get_process (name)
     register Lisp_Object name;
{
  register Lisp_Object proc, obj;
  if (STRINGP (name))
    {
      obj = Fget_process (name);
      if (NILP (obj))
	obj = Fget_buffer (name);
      if (NILP (obj))
	error ("Process %s does not exist", XSTRING (name)->data);
    }
  else if (NILP (name))
    obj = Fcurrent_buffer ();
  else
    obj = name;

  /* Now obj should be either a buffer object or a process object.
   */
  if (BUFFERP (obj))
    {
      proc = Fget_buffer_process (obj);
      if (NILP (proc))
	error ("Buffer %s has no process", XSTRING (XBUFFER (obj)->name)->data);
    }
  else
    {
      CHECK_PROCESS (obj, 0);
      proc = obj;
    }
  return proc;
}

DEFUN ("delete-process", Fdelete_process, Sdelete_process, 1, 1, 0,
  "Delete PROCESS: kill it and forget about it immediately.\n\
PROCESS may be a process, a buffer, the name of a process or buffer, or\n\
nil, indicating the current buffer's process.")
  (process)
     register Lisp_Object process;
{
  process = get_process (process);
  XPROCESS (process)->raw_status_low = Qnil;
  XPROCESS (process)->raw_status_high = Qnil;
  if (NETCONN_P (process))
    {
      XPROCESS (process)->status = Fcons (Qexit, Fcons (make_number (0), Qnil));
      XSETINT (XPROCESS (process)->tick, ++process_tick);
    }
  else if (XINT (XPROCESS (process)->infd) >= 0)
    {
      Fkill_process (process, Qnil);
      /* Do this now, since remove_process will make sigchld_handler do nothing.  */
      XPROCESS (process)->status 
	= Fcons (Qsignal, Fcons (make_number (SIGKILL), Qnil));
      XSETINT (XPROCESS (process)->tick, ++process_tick);
      status_notify ();
    }
  remove_process (process);
  return Qnil;
}

DEFUN ("process-status", Fprocess_status, Sprocess_status, 1, 1, 0,
  "Return the status of PROCESS.\n\
The returned value is one of the following symbols:\n\
run  -- for a process that is running.\n\
stop -- for a process stopped but continuable.\n\
exit -- for a process that has exited.\n\
signal -- for a process that has got a fatal signal.\n\
open -- for a network stream connection that is open.\n\
closed -- for a network stream connection that is closed.\n\
nil -- if arg is a process name and no such process exists.\n\
PROCESS may be a process, a buffer, the name of a process, or\n\
nil, indicating the current buffer's process.")
  (process)
     register Lisp_Object process;
{
  register struct Lisp_Process *p;
  register Lisp_Object status;

  if (STRINGP (process))
    process = Fget_process (process);
  else
    process = get_process (process);

  if (NILP (process))
    return process;

  p = XPROCESS (process);
  if (!NILP (p->raw_status_low))
    update_status (p);
  status = p->status;
  if (CONSP (status))
    status = XCONS (status)->car;
  if (NETCONN_P (process))
    {
      if (EQ (status, Qrun))
	status = Qopen;
      else if (EQ (status, Qexit))
	status = Qclosed;
    }
  return status;
}

DEFUN ("process-exit-status", Fprocess_exit_status, Sprocess_exit_status,
       1, 1, 0,
  "Return the exit status of PROCESS or the signal number that killed it.\n\
If PROCESS has not yet exited or died, return 0.")
  (process)
     register Lisp_Object process;
{
  CHECK_PROCESS (process, 0);
  if (!NILP (XPROCESS (process)->raw_status_low))
    update_status (XPROCESS (process));
  if (CONSP (XPROCESS (process)->status))
    return XCONS (XCONS (XPROCESS (process)->status)->cdr)->car;
  return make_number (0);
}

DEFUN ("process-id", Fprocess_id, Sprocess_id, 1, 1, 0,
  "Return the process id of PROCESS.\n\
This is the pid of the Unix process which PROCESS uses or talks to.\n\
For a network connection, this value is nil.")
  (process)
     register Lisp_Object process;
{
  CHECK_PROCESS (process, 0);
  return XPROCESS (process)->pid;
}

DEFUN ("process-name", Fprocess_name, Sprocess_name, 1, 1, 0,
  "Return the name of PROCESS, as a string.\n\
This is the name of the program invoked in PROCESS,\n\
possibly modified to make it unique among process names.")
  (process)
     register Lisp_Object process;
{
  CHECK_PROCESS (process, 0);
  return XPROCESS (process)->name;
}

DEFUN ("process-command", Fprocess_command, Sprocess_command, 1, 1, 0,
  "Return the command that was executed to start PROCESS.\n\
This is a list of strings, the first string being the program executed\n\
and the rest of the strings being the arguments given to it.\n\
For a non-child channel, this is nil.")
  (process)
     register Lisp_Object process;
{
  CHECK_PROCESS (process, 0);
  return XPROCESS (process)->command;
}

DEFUN ("process-tty-name", Fprocess_tty_name, Sprocess_tty_name, 1, 1, 0,
  "Return the name of the terminal PROCESS uses, or nil if none.\n\
This is the terminal that the process itself reads and writes on,\n\
not the name of the pty that Emacs uses to talk with that terminal.")
  (process)
     register Lisp_Object process;
{
  CHECK_PROCESS (process, 0);
  return XPROCESS (process)->tty_name;
}

DEFUN ("set-process-buffer", Fset_process_buffer, Sset_process_buffer,
  2, 2, 0,
  "Set buffer associated with PROCESS to BUFFER (a buffer, or nil).")
  (process, buffer)
     register Lisp_Object process, buffer;
{
  CHECK_PROCESS (process, 0);
  if (!NILP (buffer))
    CHECK_BUFFER (buffer, 1);
  XPROCESS (process)->buffer = buffer;
  return buffer;
}

DEFUN ("process-buffer", Fprocess_buffer, Sprocess_buffer,
  1, 1, 0,
  "Return the buffer PROCESS is associated with.\n\
Output from PROCESS is inserted in this buffer unless PROCESS has a filter.")
  (process)
     register Lisp_Object process;
{
  CHECK_PROCESS (process, 0);
  return XPROCESS (process)->buffer;
}

DEFUN ("process-mark", Fprocess_mark, Sprocess_mark,
  1, 1, 0,
  "Return the marker for the end of the last output from PROCESS.")
  (process)
     register Lisp_Object process;
{
  CHECK_PROCESS (process, 0);
  return XPROCESS (process)->mark;
}

DEFUN ("set-process-filter", Fset_process_filter, Sset_process_filter,
  2, 2, 0,
  "Give PROCESS the filter function FILTER; nil means no filter.\n\
t means stop accepting output from the process.\n\
When a process has a filter, each time it does output\n\
the entire string of output is passed to the filter.\n\
The filter gets two arguments: the process and the string of output.\n\
If the process has a filter, its buffer is not used for output.")
  (process, filter)
     register Lisp_Object process, filter;
{
  CHECK_PROCESS (process, 0);
  if (EQ (filter, Qt))
    {
      FD_CLR (XINT (XPROCESS (process)->infd), &input_wait_mask);
      FD_CLR (XINT (XPROCESS (process)->infd), &non_keyboard_wait_mask);
    }
  else if (EQ (XPROCESS (process)->filter, Qt))
    {
      FD_SET (XINT (XPROCESS (process)->infd), &input_wait_mask);
      FD_SET (XINT (XPROCESS (process)->infd), &non_keyboard_wait_mask);
    }
  XPROCESS (process)->filter = filter;
  return filter;
}

DEFUN ("process-filter", Fprocess_filter, Sprocess_filter,
  1, 1, 0,
  "Returns the filter function of PROCESS; nil if none.\n\
See `set-process-filter' for more info on filter functions.")
  (process)
     register Lisp_Object process;
{
  CHECK_PROCESS (process, 0);
  return XPROCESS (process)->filter;
}

DEFUN ("set-process-sentinel", Fset_process_sentinel, Sset_process_sentinel,
  2, 2, 0,
  "Give PROCESS the sentinel SENTINEL; nil for none.\n\
The sentinel is called as a function when the process changes state.\n\
It gets two arguments: the process, and a string describing the change.")
  (process, sentinel)
     register Lisp_Object process, sentinel;
{
  CHECK_PROCESS (process, 0);
  XPROCESS (process)->sentinel = sentinel;
  return sentinel;
}

DEFUN ("process-sentinel", Fprocess_sentinel, Sprocess_sentinel,
  1, 1, 0,
  "Return the sentinel of PROCESS; nil if none.\n\
See `set-process-sentinel' for more info on sentinels.")
  (process)
     register Lisp_Object process;
{
  CHECK_PROCESS (process, 0);
  return XPROCESS (process)->sentinel;
}

DEFUN ("set-process-window-size", Fset_process_window_size,
  Sset_process_window_size, 3, 3, 0,
  "Tell PROCESS that it has logical window size HEIGHT and WIDTH.")
  (process, height, width)
     register Lisp_Object process, height, width;
{
  CHECK_PROCESS (process, 0);
  CHECK_NATNUM (height, 0);
  CHECK_NATNUM (width, 0);
  if (set_window_size (XINT (XPROCESS (process)->infd),
		       XINT (height), XINT(width)) <= 0)
    return Qnil;
  else
    return Qt;
}

DEFUN ("set-process-inherit-coding-system-flag",
  Fset_process_inherit_coding_system_flag,
  Sset_process_inherit_coding_system_flag, 2, 2, 0,
  "Determine whether buffer of PROCESS will inherit coding-system.\n\
If the second argument FLAG is non-nil, then the variable\n\
`buffer-file-coding-system' of the buffer associated with PROCESS\n\
will be bound to the value of the coding system used to decode\n\
the process output.\n\
\n\
This is useful when the coding system specified for the process buffer\n\
leaves either the character code conversion or the end-of-line conversion\n\
unspecified, or if the coding system used to decode the process output\n\
is more appropriate for saving the process buffer.\n\
\n\
Binding the variable `inherit-process-coding-system' to non-nil before\n\
starting the process is an alternative way of setting the inherit flag\n\
for the process which will run.")
  (process, flag)
     register Lisp_Object process, flag;
{
  CHECK_PROCESS (process, 0);
  XPROCESS (process)->inherit_coding_system_flag = flag;
  return flag;
}

DEFUN ("process-inherit-coding-system-flag",
  Fprocess_inherit_coding_system_flag, Sprocess_inherit_coding_system_flag,
  1, 1, 0,
  "Return the value of inherit-coding-system flag for PROCESS.\n\
If this flag is t, `buffer-file-coding-system' of the buffer\n\
associated with PROCESS will inherit the coding system used to decode\n\
the process output.")
  (process)
     register Lisp_Object process;
{
  CHECK_PROCESS (process, 0);
  return XPROCESS (process)->inherit_coding_system_flag;
}

DEFUN ("process-kill-without-query", Fprocess_kill_without_query,
  Sprocess_kill_without_query, 1, 2, 0,
  "Say no query needed if PROCESS is running when Emacs is exited.\n\
Optional second argument if non-nil says to require a query.\n\
Value is t if a query was formerly required.")
  (process, value)
     register Lisp_Object process, value;
{
  Lisp_Object tem;

  CHECK_PROCESS (process, 0);
  tem = XPROCESS (process)->kill_without_query;
  XPROCESS (process)->kill_without_query = Fnull (value);

  return Fnull (tem);
}

DEFUN ("process-contact", Fprocess_contact, Sprocess_contact,
  1, 1, 0,
  "Return the contact info of PROCESS; t for a real child.\n\
For a net connection, the value is a cons cell of the form (HOST SERVICE).")
  (process)
     register Lisp_Object process;
{
  CHECK_PROCESS (process, 0);
  return XPROCESS (process)->childp;
}

#if 0 /* Turned off because we don't currently record this info
	 in the process.  Perhaps add it.  */
DEFUN ("process-connection", Fprocess_connection, Sprocess_connection, 1, 1, 0,
 "Return the connection type of PROCESS.\n\
The value is nil for a pipe, t or `pty' for a pty, or `stream' for\n\
a socket connection.")
  (process)
     Lisp_Object process;
{
  return XPROCESS (process)->type;
}
#endif

Lisp_Object
list_processes_1 ()
{
  register Lisp_Object tail, tem;
  Lisp_Object proc, minspace, tem1;
  register struct buffer *old = current_buffer;
  register struct Lisp_Process *p;
  register int state;
  char tembuf[80];

  XSETFASTINT (minspace, 1);

  set_buffer_internal (XBUFFER (Vstandard_output));
  Fbuffer_disable_undo (Vstandard_output);

  current_buffer->truncate_lines = Qt;

  write_string ("\
Proc         Status   Buffer         Tty         Command\n\
----         ------   ------         ---         -------\n", -1);

  for (tail = Vprocess_alist; !NILP (tail); tail = Fcdr (tail))
    {
      Lisp_Object symbol;

      proc = Fcdr (Fcar (tail));
      p = XPROCESS (proc);
      if (NILP (p->childp))
	continue;

      Finsert (1, &p->name);
      Findent_to (make_number (13), minspace);

      if (!NILP (p->raw_status_low))
	update_status (p);
      symbol = p->status;
      if (CONSP (p->status))
	symbol = XCONS (p->status)->car;

      
      if (EQ (symbol, Qsignal))
	{
	  Lisp_Object tem;
	  tem = Fcar (Fcdr (p->status));
#ifdef VMS
	  if (XINT (tem) < NSIG)
	    write_string (sys_errlist [XINT (tem)], -1);
	  else
#endif
	    Fprinc (symbol, Qnil);
	}
      else if (NETCONN_P (proc))
	{
	  if (EQ (symbol, Qrun))
	    write_string ("open", -1);
	  else if (EQ (symbol, Qexit))
	    write_string ("closed", -1);
	  else
	    Fprinc (symbol, Qnil);
	}
      else
	Fprinc (symbol, Qnil);

      if (EQ (symbol, Qexit))
	{
	  Lisp_Object tem;
	  tem = Fcar (Fcdr (p->status));
	  if (XFASTINT (tem))
	    {
	      sprintf (tembuf, " %d", (int) XFASTINT (tem));
	      write_string (tembuf, -1);
	    }
	}

      if (EQ (symbol, Qsignal) || EQ (symbol, Qexit))
	remove_process (proc);

      Findent_to (make_number (22), minspace);
      if (NILP (p->buffer))
	insert_string ("(none)");
      else if (NILP (XBUFFER (p->buffer)->name))
	insert_string ("(Killed)");
      else
	Finsert (1, &XBUFFER (p->buffer)->name);

      Findent_to (make_number (37), minspace);

      if (STRINGP (p->tty_name))
	Finsert (1, &p->tty_name);
      else
	insert_string ("(none)");

      Findent_to (make_number (49), minspace);

      if (NETCONN_P (proc))
        {
	  sprintf (tembuf, "(network stream connection to %s)\n",
		   XSTRING (XCONS (p->childp)->car)->data);
	  insert_string (tembuf);
        }
      else 
	{
	  tem = p->command;
	  while (1)
	    {
	      tem1 = Fcar (tem);
	      Finsert (1, &tem1);
	      tem = Fcdr (tem);
	      if (NILP (tem))
		break;
	      insert_string (" ");
	    }
	  insert_string ("\n");
       }
    }
  return Qnil;
}

DEFUN ("list-processes", Flist_processes, Slist_processes, 0, 0, "",
  "Display a list of all processes.\n\
Any process listed as exited or signaled is actually eliminated\n\
after the listing is made.")
  ()
{
  internal_with_output_to_temp_buffer ("*Process List*",
				       list_processes_1, Qnil);
  return Qnil;
}

DEFUN ("process-list", Fprocess_list, Sprocess_list, 0, 0, 0,
  "Return a list of all processes.")
  ()
{
  return Fmapcar (Qcdr, Vprocess_alist);
}

/* Starting asynchronous inferior processes.  */

static Lisp_Object start_process_unwind ();

DEFUN ("start-process", Fstart_process, Sstart_process, 3, MANY, 0,
  "Start a program in a subprocess.  Return the process object for it.\n\
Args are NAME BUFFER PROGRAM &rest PROGRAM-ARGS\n\
NAME is name for process.  It is modified if necessary to make it unique.\n\
BUFFER is the buffer or (buffer-name) to associate with the process.\n\
 Process output goes at end of that buffer, unless you specify\n\
 an output stream or filter function to handle the output.\n\
 BUFFER may be also nil, meaning that this process is not associated\n\
 with any buffer.\n\
Third arg is program file name.  It is searched for in PATH.\n\
Remaining arguments are strings to give program as arguments.")
  (nargs, args)
     int nargs;
     register Lisp_Object *args;
{
  Lisp_Object buffer, name, program, proc, current_dir, tem;
#ifdef VMS
  register unsigned char *new_argv;
  int len;
#else
  register unsigned char **new_argv;
#endif
  register int i;
  int count = specpdl_ptr - specpdl;

  buffer = args[1];
  if (!NILP (buffer))
    buffer = Fget_buffer_create (buffer);

  /* Make sure that the child will be able to chdir to the current
     buffer's current directory, or its unhandled equivalent.  We
     can't just have the child check for an error when it does the
     chdir, since it's in a vfork.

     We have to GCPRO around this because Fexpand_file_name and
     Funhandled_file_name_directory might call a file name handling
     function.  The argument list is protected by the caller, so all
     we really have to worry about is buffer.  */
  {
    struct gcpro gcpro1, gcpro2;

    current_dir = current_buffer->directory;

    GCPRO2 (buffer, current_dir);

    current_dir 
      = expand_and_dir_to_file (Funhandled_file_name_directory (current_dir),
				Qnil);
    if (NILP (Ffile_accessible_directory_p (current_dir)))
      report_file_error ("Setting current directory",
			 Fcons (current_buffer->directory, Qnil));

    UNGCPRO;
  }

  name = args[0];
  CHECK_STRING (name, 0);

  program = args[2];

  CHECK_STRING (program, 2);

#ifdef VMS
  /* Make a one member argv with all args concatenated
     together separated by a blank.  */
  len = STRING_BYTES (XSTRING (program)) + 2;
  for (i = 3; i < nargs; i++)
    {
      tem = args[i];
      CHECK_STRING (tem, i);
      len += STRING_BYTES (XSTRING (tem)) + 1;	/* count the blank */
    }
  new_argv = (unsigned char *) alloca (len);
  strcpy (new_argv, XSTRING (program)->data);
  for (i = 3; i < nargs; i++)
    {
      tem = args[i];
      CHECK_STRING (tem, i);
      strcat (new_argv, " ");
      strcat (new_argv, XSTRING (tem)->data);
    }
  /* Need to add code here to check for program existence on VMS */
  
#else /* not VMS */
  new_argv = (unsigned char **) alloca ((nargs - 1) * sizeof (char *));

  /* If program file name is not absolute, search our path for it */
  if (!IS_DIRECTORY_SEP (XSTRING (program)->data[0])
      && !(XSTRING (program)->size > 1
	   && IS_DEVICE_SEP (XSTRING (program)->data[1])))
    {
      struct gcpro gcpro1, gcpro2, gcpro3, gcpro4;

      tem = Qnil;
      GCPRO4 (name, program, buffer, current_dir);
      openp (Vexec_path, program, EXEC_SUFFIXES, &tem, 1);
      UNGCPRO;
      if (NILP (tem))
	report_file_error ("Searching for program", Fcons (program, Qnil));
      tem = Fexpand_file_name (tem, Qnil);
      new_argv[0] = XSTRING (tem)->data;
    }
  else
    {
      if (!NILP (Ffile_directory_p (program)))
	error ("Specified program for new process is a directory");

      new_argv[0] = XSTRING (program)->data;
    }

  for (i = 3; i < nargs; i++)
    {
      tem = args[i];
      CHECK_STRING (tem, i);
      new_argv[i - 2] = XSTRING (tem)->data;
    }
  new_argv[i - 2] = 0;
#endif /* not VMS */

  proc = make_process (name);
  /* If an error occurs and we can't start the process, we want to
     remove it from the process list.  This means that each error
     check in create_process doesn't need to call remove_process
     itself; it's all taken care of here.  */
  record_unwind_protect (start_process_unwind, proc);

  XPROCESS (proc)->childp = Qt;
  XPROCESS (proc)->command_channel_p = Qnil;
  XPROCESS (proc)->buffer = buffer;
  XPROCESS (proc)->sentinel = Qnil;
  XPROCESS (proc)->filter = Qnil;
  XPROCESS (proc)->command = Flist (nargs - 2, args + 2);

  /* Make the process marker point into the process buffer (if any).  */
  if (!NILP (buffer))
    set_marker_both (XPROCESS (proc)->mark, buffer,
		     BUF_ZV (XBUFFER (buffer)),
		     BUF_ZV_BYTE (XBUFFER (buffer)));

  {
    /* Decide coding systems for communicating with the process.  Here
       we don't setup the structure coding_system nor pay attention to
       unibyte mode.  They are done in create_process.  */

    /* Qt denotes we have not yet called Ffind_operation_coding_system.  */
    Lisp_Object coding_systems = Qt;
    Lisp_Object val, *args2;
    struct gcpro gcpro1;

    val = Vcoding_system_for_read;
    if (NILP (val))
      {
	args2 = (Lisp_Object *) alloca ((nargs + 1) * sizeof *args2);
	args2[0] = Qstart_process;
	for (i = 0; i < nargs; i++) args2[i + 1] = args[i];
	GCPRO1 (proc);
	coding_systems = Ffind_operation_coding_system (nargs + 1, args2);
	UNGCPRO;
	if (CONSP (coding_systems))
	  val = XCONS (coding_systems)->car;
	else if (CONSP (Vdefault_process_coding_system))
	  val = XCONS (Vdefault_process_coding_system)->car;
      }
    XPROCESS (proc)->decode_coding_system = val;

    val = Vcoding_system_for_write;
    if (NILP (val))
      {
	if (EQ (coding_systems, Qt))
	  {
	    args2 = (Lisp_Object *) alloca ((nargs + 1) * sizeof args2);
	    args2[0] = Qstart_process;
	    for (i = 0; i < nargs; i++) args2[i + 1] = args[i];
	    GCPRO1 (proc);
	    coding_systems = Ffind_operation_coding_system (nargs + 1, args2);
	    UNGCPRO;
	  }
	if (CONSP (coding_systems))
	  val = XCONS (coding_systems)->cdr;
	else if (CONSP (Vdefault_process_coding_system))
	  val = XCONS (Vdefault_process_coding_system)->cdr;
      }
    XPROCESS (proc)->encode_coding_system = val;
  }

  XPROCESS (proc)->decoding_buf = make_uninit_string (0);
  XPROCESS (proc)->decoding_carryover = make_number (0);
  XPROCESS (proc)->encoding_buf = make_uninit_string (0);
  XPROCESS (proc)->encoding_carryover = make_number (0);

  XPROCESS (proc)->inherit_coding_system_flag
    = (NILP (buffer) || !inherit_process_coding_system
       ? Qnil : Qt);

  create_process (proc, (char **) new_argv, current_dir);

  return unbind_to (count, proc);
}

/* This function is the unwind_protect form for Fstart_process.  If
   PROC doesn't have its pid set, then we know someone has signaled
   an error and the process wasn't started successfully, so we should
   remove it from the process list.  */
static Lisp_Object
start_process_unwind (proc)
     Lisp_Object proc;
{
  if (!PROCESSP (proc))
    abort ();

  /* Was PROC started successfully?  */
  if (XINT (XPROCESS (proc)->pid) <= 0)
    remove_process (proc);

  return Qnil;
}


SIGTYPE
create_process_1 (signo)
     int signo;
{
#if defined (USG) && !defined (POSIX_SIGNALS)
  /* USG systems forget handlers when they are used;
     must reestablish each time */
  signal (signo, create_process_1);
#endif /* USG */
}

#if 0  /* This doesn't work; see the note before sigchld_handler.  */
#ifdef USG
#ifdef SIGCHLD
/* Mimic blocking of signals on system V, which doesn't really have it.  */

/* Nonzero means we got a SIGCHLD when it was supposed to be blocked.  */
int sigchld_deferred;

SIGTYPE
create_process_sigchld ()
{
  signal (SIGCHLD, create_process_sigchld);

  sigchld_deferred = 1;
}
#endif
#endif
#endif

#ifndef VMS /* VMS version of this function is in vmsproc.c.  */
void
create_process (process, new_argv, current_dir)
     Lisp_Object process;
     char **new_argv;
     Lisp_Object current_dir;
{
  int pid, inchannel, outchannel;
  int sv[2];
#ifdef POSIX_SIGNALS
  sigset_t procmask;
  sigset_t blocked;
  struct sigaction sigint_action;
  struct sigaction sigquit_action;
#ifdef AIX
  struct sigaction sighup_action;
#endif
#else /* !POSIX_SIGNALS */
#ifdef SIGCHLD
  SIGTYPE (*sigchld)();
#endif
#endif /* !POSIX_SIGNALS */
  /* Use volatile to protect variables from being clobbered by longjmp.  */
  volatile int forkin, forkout;
  volatile int pty_flag = 0;
  extern char **environ;
  Lisp_Object buffer = XPROCESS (process)->buffer;

  inchannel = outchannel = -1;

#ifdef HAVE_PTYS
  if (!NILP (Vprocess_connection_type))
    outchannel = inchannel = allocate_pty ();

  if (inchannel >= 0)
    {
#ifndef USG 
      /* On USG systems it does not work to open the pty's tty here
	       and then close and reopen it in the child.  */
#ifdef O_NOCTTY
      /* Don't let this terminal become our controlling terminal
	 (in case we don't have one).  */
      forkout = forkin = open (pty_name, O_RDWR | O_NOCTTY, 0);
#else
      forkout = forkin = open (pty_name, O_RDWR, 0);
#endif
      if (forkin < 0)
	report_file_error ("Opening pty", Qnil);
#else
      forkin = forkout = -1;
#endif /* not USG */
      pty_flag = 1;
    }
  else
#endif /* HAVE_PTYS */
#ifdef SKTPAIR
    {
      if (socketpair (AF_UNIX, SOCK_STREAM, 0, sv) < 0)
	report_file_error ("Opening socketpair", Qnil);
      outchannel = inchannel = sv[0];
      forkout = forkin = sv[1];
    }
#else /* not SKTPAIR */
    {
      pipe (sv);
      inchannel = sv[0];
      forkout = sv[1];
      pipe (sv);
      outchannel = sv[1];
      forkin = sv[0];
    }
#endif /* not SKTPAIR */

#if 0
  /* Replaced by close_process_descs */
  set_exclusive_use (inchannel);
  set_exclusive_use (outchannel);
#endif

/* Stride people say it's a mystery why this is needed
   as well as the O_NDELAY, but that it fails without this.  */
#if defined (STRIDE) || (defined (pfa) && defined (HAVE_PTYS))
  {
    int one = 1;
    ioctl (inchannel, FIONBIO, &one);
  }
#endif

#ifdef O_NONBLOCK
  fcntl (inchannel, F_SETFL, O_NONBLOCK);
  fcntl (outchannel, F_SETFL, O_NONBLOCK);
#else
#ifdef O_NDELAY
  fcntl (inchannel, F_SETFL, O_NDELAY);
  fcntl (outchannel, F_SETFL, O_NDELAY);
#endif
#endif

  /* Record this as an active process, with its channels.
     As a result, child_setup will close Emacs's side of the pipes.  */
  chan_process[inchannel] = process;
  XSETINT (XPROCESS (process)->infd, inchannel);
  XSETINT (XPROCESS (process)->outfd, outchannel);
  /* Record the tty descriptor used in the subprocess.  */
  if (forkin < 0)
    XPROCESS (process)->subtty = Qnil;
  else
    XSETFASTINT (XPROCESS (process)->subtty, forkin);
  XPROCESS (process)->pty_flag = (pty_flag ? Qt : Qnil);
  XPROCESS (process)->status = Qrun;
  if (!proc_decode_coding_system[inchannel])
    proc_decode_coding_system[inchannel]
      = (struct coding_system *) xmalloc (sizeof (struct coding_system));
  setup_coding_system (XPROCESS (process)->decode_coding_system,
		       proc_decode_coding_system[inchannel]);
  if (!proc_encode_coding_system[outchannel])
    proc_encode_coding_system[outchannel]
      = (struct coding_system *) xmalloc (sizeof (struct coding_system));
  setup_coding_system (XPROCESS (process)->encode_coding_system,
		       proc_encode_coding_system[outchannel]);

  if (!NILP (buffer) && NILP (XBUFFER (buffer)->enable_multibyte_characters)
      || (NILP (buffer) && NILP (buffer_defaults.enable_multibyte_characters)))
    {
      /* In unibyte mode, character code conversion should not take
	 place but EOL conversion should.  So, setup raw-text or one
	 of the subsidiary according to the information just setup.  */
      if (!NILP (XPROCESS (process)->decode_coding_system))
	setup_raw_text_coding_system (proc_decode_coding_system[inchannel]);
      if (!NILP (XPROCESS (process)->encode_coding_system))
	setup_raw_text_coding_system (proc_encode_coding_system[outchannel]);
    }

  if (CODING_REQUIRE_ENCODING (proc_encode_coding_system[outchannel]))
    {
      /* Here we encode arguments by the coding system used for
	 sending data to the process.  We don't support using
	 different coding systems for encoding arguments and for
	 encoding data sent to the process.  */
      struct gcpro gcpro1;
      int i = 1;
      struct coding_system *coding = proc_encode_coding_system[outchannel];

      coding->mode |= CODING_MODE_LAST_BLOCK;
      GCPRO1 (process);
      while (new_argv[i] != 0)
	{
	  int len = strlen (new_argv[i]);
	  int size = encoding_buffer_size (coding, len);
	  unsigned char *buf = (unsigned char *) alloca (size);

	  encode_coding (coding, (unsigned char *)new_argv[i], buf, len, size);
	  buf[coding->produced] = 0;
	  /* We don't have to free new_argv[i] because it points to a
             Lisp string given as an argument to `start-process'.  */
	  new_argv[i++] = (char *) buf;
	}
      UNGCPRO;
      coding->mode &= ~CODING_MODE_LAST_BLOCK;
    }

  /* Delay interrupts until we have a chance to store
     the new fork's pid in its process structure */
#ifdef POSIX_SIGNALS
  sigemptyset (&blocked);
#ifdef SIGCHLD
  sigaddset (&blocked, SIGCHLD);
#endif
#ifdef HAVE_VFORK
  /* On many hosts (e.g. Solaris 2.4), if a vforked child calls `signal',
     this sets the parent's signal handlers as well as the child's.
     So delay all interrupts whose handlers the child might munge,
     and record the current handlers so they can be restored later.  */
  sigaddset (&blocked, SIGINT );  sigaction (SIGINT , 0, &sigint_action );
  sigaddset (&blocked, SIGQUIT);  sigaction (SIGQUIT, 0, &sigquit_action);
#ifdef AIX
  sigaddset (&blocked, SIGHUP );  sigaction (SIGHUP , 0, &sighup_action );
#endif
#endif /* HAVE_VFORK */
  sigprocmask (SIG_BLOCK, &blocked, &procmask);
#else /* !POSIX_SIGNALS */
#ifdef SIGCHLD
#ifdef BSD4_1
  sighold (SIGCHLD);
#else /* not BSD4_1 */
#if defined (BSD_SYSTEM) || defined (UNIPLUS) || defined (HPUX)
  sigsetmask (sigmask (SIGCHLD));
#else /* ordinary USG */
#if 0
  sigchld_deferred = 0;
  sigchld = signal (SIGCHLD, create_process_sigchld);
#endif
#endif /* ordinary USG */
#endif /* not BSD4_1 */
#endif /* SIGCHLD */
#endif /* !POSIX_SIGNALS */

  FD_SET (inchannel, &input_wait_mask);
  FD_SET (inchannel, &non_keyboard_wait_mask);
  if (inchannel > max_process_desc)
    max_process_desc = inchannel;

  /* Until we store the proper pid, enable sigchld_handler
     to recognize an unknown pid as standing for this process.
     It is very important not to let this `marker' value stay
     in the table after this function has returned; if it does
     it might cause call-process to hang and subsequent asynchronous
     processes to get their return values scrambled.  */
  XSETINT (XPROCESS (process)->pid, -1);

  BLOCK_INPUT;
  
  {
    /* child_setup must clobber environ on systems with true vfork.
       Protect it from permanent change.  */
    char **save_environ = environ;

    current_dir = ENCODE_FILE (current_dir);

#ifndef WINDOWSNT
    pid = vfork ();
    if (pid == 0)
#endif /* not WINDOWSNT */
      {
	int xforkin = forkin;
	int xforkout = forkout;

#if 0 /* This was probably a mistake--it duplicates code later on,
	 but fails to handle all the cases.  */
	/* Make sure SIGCHLD is not blocked in the child.  */
	sigsetmask (SIGEMPTYMASK);
#endif

	/* Make the pty be the controlling terminal of the process.  */
#ifdef HAVE_PTYS
	/* First, disconnect its current controlling terminal.  */
#ifdef HAVE_SETSID
	/* We tried doing setsid only if pty_flag, but it caused
	   process_set_signal to fail on SGI when using a pipe.  */
	setsid ();
	/* Make the pty's terminal the controlling terminal.  */
	if (pty_flag)
	  {
#ifdef TIOCSCTTY
	    /* We ignore the return value
	       because faith@cs.unc.edu says that is necessary on Linux.  */
	    ioctl (xforkin, TIOCSCTTY, 0);
#endif
	  }
#else /* not HAVE_SETSID */
#ifdef USG
	/* It's very important to call setpgrp here and no time
	   afterwards.  Otherwise, we lose our controlling tty which
	   is set when we open the pty. */
	setpgrp ();
#endif /* USG */
#endif /* not HAVE_SETSID */
#if defined (HAVE_TERMIOS) && defined (LDISC1)
	if (pty_flag && xforkin >= 0)
	  {
	    struct termios t;
	    tcgetattr (xforkin, &t);
	    t.c_lflag = LDISC1;
	    if (tcsetattr (xforkin, TCSANOW, &t) < 0)
	      write (1, "create_process/tcsetattr LDISC1 failed\n", 39);
	  }
#else
#if defined (NTTYDISC) && defined (TIOCSETD)
	if (pty_flag && xforkin >= 0)
	  {
	    /* Use new line discipline.  */
	    int ldisc = NTTYDISC;
	    ioctl (xforkin, TIOCSETD, &ldisc);
	  }
#endif
#endif
#ifdef TIOCNOTTY 
	/* In 4.3BSD, the TIOCSPGRP bug has been fixed, and now you
	   can do TIOCSPGRP only to the process's controlling tty.  */
	if (pty_flag)
	  {
	    /* I wonder: would just ioctl (0, TIOCNOTTY, 0) work here? 
	       I can't test it since I don't have 4.3.  */
	    int j = open ("/dev/tty", O_RDWR, 0);
	    ioctl (j, TIOCNOTTY, 0);
	    close (j);
#ifndef USG
	    /* In order to get a controlling terminal on some versions
	       of BSD, it is necessary to put the process in pgrp 0
	       before it opens the terminal.  */
#ifdef HAVE_SETPGID
	    setpgid (0, 0);
#else
	    setpgrp (0, 0);
#endif
#endif
	  }
#endif /* TIOCNOTTY */

#if !defined (RTU) && !defined (UNIPLUS) && !defined (DONT_REOPEN_PTY)
/*** There is a suggestion that this ought to be a
     conditional on TIOCSPGRP,
     or !(defined (HAVE_SETSID) && defined (TIOCSCTTY)).
     Trying the latter gave the wrong results on Debian GNU/Linux 1.1;
     that system does seem to need this code, even though
     both HAVE_SETSID and TIOCSCTTY are defined.  */
	/* Now close the pty (if we had it open) and reopen it.
	   This makes the pty the controlling terminal of the subprocess.  */
	if (pty_flag)
	  {
#ifdef SET_CHILD_PTY_PGRP
	    int pgrp = getpid ();
#endif

	    /* I wonder if close (open (pty_name, ...)) would work?  */
	    if (xforkin >= 0)
	      close (xforkin);
	    xforkout = xforkin = open (pty_name, O_RDWR, 0);

	    if (xforkin < 0)
	      {
		write (1, "Couldn't open the pty terminal ", 31);
		write (1, pty_name, strlen (pty_name));
		write (1, "\n", 1);
		_exit (1);
	      }

#ifdef SET_CHILD_PTY_PGRP
	    ioctl (xforkin, TIOCSPGRP, &pgrp);
	    ioctl (xforkout, TIOCSPGRP, &pgrp);
#endif
	  }
#endif /* not UNIPLUS and not RTU and not DONT_REOPEN_PTY */

#ifdef SETUP_SLAVE_PTY
	if (pty_flag)
	  {
	    SETUP_SLAVE_PTY;
	  }
#endif /* SETUP_SLAVE_PTY */
#ifdef AIX
	/* On AIX, we've disabled SIGHUP above once we start a child on a pty.
	   Now reenable it in the child, so it will die when we want it to.  */
	if (pty_flag)
	  signal (SIGHUP, SIG_DFL);
#endif
#endif /* HAVE_PTYS */

	signal (SIGINT, SIG_DFL);
	signal (SIGQUIT, SIG_DFL);

	/* Stop blocking signals in the child.  */
#ifdef POSIX_SIGNALS
	sigprocmask (SIG_SETMASK, &procmask, 0);
#else /* !POSIX_SIGNALS */
#ifdef SIGCHLD
#ifdef BSD4_1
	sigrelse (SIGCHLD);
#else /* not BSD4_1 */
#if defined (BSD_SYSTEM) || defined (UNIPLUS) || defined (HPUX)
	sigsetmask (SIGEMPTYMASK);
#else /* ordinary USG */
#if 0
	signal (SIGCHLD, sigchld);
#endif
#endif /* ordinary USG */
#endif /* not BSD4_1 */
#endif /* SIGCHLD */
#endif /* !POSIX_SIGNALS */

	if (pty_flag)
	  child_setup_tty (xforkout);
#ifdef WINDOWSNT
	pid = child_setup (xforkin, xforkout, xforkout,
			   new_argv, 1, current_dir);
#else  /* not WINDOWSNT */	
	child_setup (xforkin, xforkout, xforkout,
		     new_argv, 1, current_dir);
#endif /* not WINDOWSNT */
      }
    environ = save_environ;
  }

  UNBLOCK_INPUT;

  /* This runs in the Emacs process.  */
  if (pid < 0)
    {
      if (forkin >= 0)
	close (forkin);
      if (forkin != forkout && forkout >= 0)
	close (forkout);
    }
  else
    {
      /* vfork succeeded.  */
      XSETFASTINT (XPROCESS (process)->pid, pid);

#ifdef WINDOWSNT
      register_child (pid, inchannel);
#endif /* WINDOWSNT */

      /* If the subfork execv fails, and it exits,
	 this close hangs.  I don't know why.
	 So have an interrupt jar it loose.  */
      stop_polling ();
      signal (SIGALRM, create_process_1);
      alarm (1);
      XPROCESS (process)->subtty = Qnil;
      if (forkin >= 0)
	close (forkin);
      alarm (0);
      start_polling ();
      if (forkin != forkout && forkout >= 0)
	close (forkout);

#ifdef HAVE_PTYS
      if (pty_flag)
	XPROCESS (process)->tty_name = build_string (pty_name);
      else
#endif
	XPROCESS (process)->tty_name = Qnil;
    }

  /* Restore the signal state whether vfork succeeded or not.
     (We will signal an error, below, if it failed.)  */
#ifdef POSIX_SIGNALS
#ifdef HAVE_VFORK
  /* Restore the parent's signal handlers.  */
  sigaction (SIGINT, &sigint_action, 0);
  sigaction (SIGQUIT, &sigquit_action, 0);
#ifdef AIX
  sigaction (SIGHUP, &sighup_action, 0);
#endif
#endif /* HAVE_VFORK */
  /* Stop blocking signals in the parent.  */
  sigprocmask (SIG_SETMASK, &procmask, 0);
#else /* !POSIX_SIGNALS */
#ifdef SIGCHLD
#ifdef BSD4_1
  sigrelse (SIGCHLD);
#else /* not BSD4_1 */
#if defined (BSD_SYSTEM) || defined (UNIPLUS) || defined (HPUX)
  sigsetmask (SIGEMPTYMASK);
#else /* ordinary USG */
#if 0
  signal (SIGCHLD, sigchld);
  /* Now really handle any of these signals
     that came in during this function.  */
  if (sigchld_deferred)
    kill (getpid (), SIGCHLD);
#endif
#endif /* ordinary USG */
#endif /* not BSD4_1 */
#endif /* SIGCHLD */
#endif /* !POSIX_SIGNALS */

  /* Now generate the error if vfork failed.  */
  if (pid < 0)
    report_file_error ("Doing vfork", Qnil);
}
#endif /* not VMS */

#ifdef HAVE_SOCKETS

/* open a TCP network connection to a given HOST/SERVICE.  Treated
   exactly like a normal process when reading and writing.  Only
   differences are in status display and process deletion.  A network
   connection has no PID; you cannot signal it.  All you can do is
   deactivate and close it via delete-process */

DEFUN ("open-network-stream", Fopen_network_stream, Sopen_network_stream, 
       4, 4, 0, 
  "Open a TCP connection for a service to a host.\n\
Returns a subprocess-object to represent the connection.\n\
Input and output work as for subprocesses; `delete-process' closes it.\n\
Args are NAME BUFFER HOST SERVICE.\n\
NAME is name for process.  It is modified if necessary to make it unique.\n\
BUFFER is the buffer (or buffer-name) to associate with the process.\n\
 Process output goes at end of that buffer, unless you specify\n\
 an output stream or filter function to handle the output.\n\
 BUFFER may be also nil, meaning that this process is not associated\n\
 with any buffer\n\
Third arg is name of the host to connect to, or its IP address.\n\
Fourth arg SERVICE is name of the service desired, or an integer\n\
 specifying a port number to connect to.")
   (name, buffer, host, service)
      Lisp_Object name, buffer, host, service;
{
  Lisp_Object proc;
  register int i;
  struct sockaddr_in address;
  struct servent *svc_info;
  struct hostent *host_info_ptr, host_info;
  char *(addr_list[2]);
  IN_ADDR numeric_addr;
  int s, outch, inch;
  char errstring[80];
  int port;
  struct hostent host_info_fixed;
  struct gcpro gcpro1, gcpro2, gcpro3, gcpro4;
  int retry = 0;
  int count = specpdl_ptr - specpdl;

#ifdef WINDOWSNT
  /* Ensure socket support is loaded if available. */
  init_winsock (TRUE);
#endif

  GCPRO4 (name, buffer, host, service);
  CHECK_STRING (name, 0);
  CHECK_STRING (host, 0);
  if (INTEGERP (service))
    port = htons ((unsigned short) XINT (service));
  else
    {
      CHECK_STRING (service, 0);
      svc_info = getservbyname (XSTRING (service)->data, "tcp");
      if (svc_info == 0)
	error ("Unknown service \"%s\"", XSTRING (service)->data);
      port = svc_info->s_port;
    }

  /* Slow down polling to every ten seconds.
     Some kernels have a bug which causes retrying connect to fail
     after a connect.  Polling can interfere with gethostbyname too.  */
#ifdef POLL_FOR_INPUT
  bind_polling_period (10);
#endif

#ifndef TERM
  while (1)
    {
#ifdef TRY_AGAIN
      h_errno = 0;
#endif
      immediate_quit = 1;
      QUIT;
      host_info_ptr = gethostbyname (XSTRING (host)->data);
      immediate_quit = 0;
#ifdef TRY_AGAIN
      if (! (host_info_ptr == 0 && h_errno == TRY_AGAIN))
#endif
	break;
      Fsleep_for (make_number (1), Qnil);
    }
  if (host_info_ptr == 0)
    /* Attempt to interpret host as numeric inet address */
    {
      numeric_addr = inet_addr ((char *) XSTRING (host)->data);
      if (NUMERIC_ADDR_ERROR)
	error ("Unknown host \"%s\"", XSTRING (host)->data);

      host_info_ptr = &host_info;
      host_info.h_name = 0;
      host_info.h_aliases = 0;
      host_info.h_addrtype = AF_INET;
#ifdef h_addr
      /* Older machines have only one address slot called h_addr.
	 Newer machines have h_addr_list, but #define h_addr to
	 be its first element.  */
      host_info.h_addr_list = &(addr_list[0]);
#endif
      host_info.h_addr = (char*)(&numeric_addr);
      addr_list[1] = 0;
      /* numeric_addr isn't null-terminated; it has fixed length.  */
      host_info.h_length = sizeof (numeric_addr);
    }

  bzero (&address, sizeof address);
  bcopy (host_info_ptr->h_addr, (char *) &address.sin_addr,
	 host_info_ptr->h_length);
  address.sin_family = host_info_ptr->h_addrtype;
  address.sin_port = port;

  s = socket (host_info_ptr->h_addrtype, SOCK_STREAM, 0);
  if (s < 0) 
    report_file_error ("error creating socket", Fcons (name, Qnil));

  /* Kernel bugs (on Ultrix at least) cause lossage (not just EINTR)
     when connect is interrupted.  So let's not let it get interrupted.
     Note we do not turn off polling, because polling is only used
     when not interrupt_input, and thus not normally used on the systems
     which have this bug.  On systems which use polling, there's no way
     to quit if polling is turned off.  */
  if (interrupt_input)
    unrequest_sigio ();

 loop:

  immediate_quit = 1;
  QUIT;

  if (connect (s, (struct sockaddr *) &address, sizeof address) == -1
      && errno != EISCONN)
    {
      int xerrno = errno;

      immediate_quit = 0;

      if (errno == EINTR)
	goto loop;
      if (errno == EADDRINUSE && retry < 20)
	{
	  /* A delay here is needed on some FreeBSD systems,
	     and it is harmless, since this retrying takes time anyway
	     and should be infrequent.  */
	  Fsleep_for (make_number (1), Qnil);
	  retry++;
	  goto loop;
	}

      close (s);

      if (interrupt_input)
	request_sigio ();

      errno = xerrno;
      report_file_error ("connection failed",
			 Fcons (host, Fcons (name, Qnil)));
    }

  immediate_quit = 0;

#ifdef POLL_FOR_INPUT
  unbind_to (count, Qnil);
#endif

  if (interrupt_input)
    request_sigio ();

#else /* TERM */
  s = connect_server (0);
  if (s < 0)
    report_file_error ("error creating socket", Fcons (name, Qnil));
  send_command (s, C_PORT, 0, "%s:%d", XSTRING (host)->data, ntohs (port));
  send_command (s, C_DUMB, 1, 0);
#endif /* TERM */

  inch = s;
  outch = s;

  if (!NILP (buffer))
    buffer = Fget_buffer_create (buffer);
  proc = make_process (name);

  chan_process[inch] = proc;

#ifdef O_NONBLOCK
  fcntl (inch, F_SETFL, O_NONBLOCK);
#else
#ifdef O_NDELAY
  fcntl (inch, F_SETFL, O_NDELAY);
#endif
#endif

  XPROCESS (proc)->childp = Fcons (host, Fcons (service, Qnil));
  XPROCESS (proc)->command_channel_p = Qnil;
  XPROCESS (proc)->buffer = buffer;
  XPROCESS (proc)->sentinel = Qnil;
  XPROCESS (proc)->filter = Qnil;
  XPROCESS (proc)->command = Qnil;
  XPROCESS (proc)->pid = Qnil;
  XSETINT (XPROCESS (proc)->infd, inch);
  XSETINT (XPROCESS (proc)->outfd, outch);
  XPROCESS (proc)->status = Qrun;
  FD_SET (inch, &input_wait_mask);
  FD_SET (inch, &non_keyboard_wait_mask);
  if (inch > max_process_desc)
    max_process_desc = inch;

  {
    /* Setup coding systems for communicating with the network stream.  */
    struct gcpro gcpro1;
    /* Qt denotes we have not yet called Ffind_operation_coding_system.  */
    Lisp_Object coding_systems = Qt;
    Lisp_Object args[5], val;

    if (!NILP (Vcoding_system_for_read))
      val = Vcoding_system_for_read;
    else if (!NILP (buffer) && NILP (XBUFFER (buffer)->enable_multibyte_characters)
	     || NILP (buffer) && NILP (buffer_defaults.enable_multibyte_characters))
      /* We dare not decode end-of-line format by setting VAL to
	 Qraw_text, because the existing Emacs Lisp libraries
	 assume that they receive bare code including a sequene of
	 CR LF.  */
      val = Qnil;
    else
      {
	args[0] = Qopen_network_stream, args[1] = name,
	  args[2] = buffer, args[3] = host, args[4] = service;
	GCPRO1 (proc);
	coding_systems = Ffind_operation_coding_system (5, args);
	UNGCPRO;
	if (CONSP (coding_systems))
	  val = XCONS (coding_systems)->car;
	else if (CONSP (Vdefault_process_coding_system))
	  val = XCONS (Vdefault_process_coding_system)->car;
	else
	  val = Qnil;
      }
    XPROCESS (proc)->decode_coding_system = val;

    if (!NILP (Vcoding_system_for_write))
      val = Vcoding_system_for_write;
    else if (NILP (current_buffer->enable_multibyte_characters))
      val = Qnil;
    else
      {
	if (EQ (coding_systems, Qt))
	  {
	    args[0] = Qopen_network_stream, args[1] = name,
	      args[2] = buffer, args[3] = host, args[4] = service;
	    GCPRO1 (proc);
	    coding_systems = Ffind_operation_coding_system (5, args);
	    UNGCPRO;
	  }
	if (CONSP (coding_systems))
	  val = XCONS (coding_systems)->cdr;
	else if (CONSP (Vdefault_process_coding_system))
	  val = XCONS (Vdefault_process_coding_system)->cdr;
	else
	  val = Qnil;
      }
    XPROCESS (proc)->encode_coding_system = val;
  }

  if (!proc_decode_coding_system[inch])
    proc_decode_coding_system[inch]
      = (struct coding_system *) xmalloc (sizeof (struct coding_system));
  setup_coding_system (XPROCESS (proc)->decode_coding_system,
		       proc_decode_coding_system[inch]);
  if (!proc_encode_coding_system[outch])
    proc_encode_coding_system[outch]
      = (struct coding_system *) xmalloc (sizeof (struct coding_system));
  setup_coding_system (XPROCESS (proc)->encode_coding_system,
		       proc_encode_coding_system[outch]);

  XPROCESS (proc)->decoding_buf = make_uninit_string (0);
  XPROCESS (proc)->decoding_carryover = make_number (0);
  XPROCESS (proc)->encoding_buf = make_uninit_string (0);
  XPROCESS (proc)->encoding_carryover = make_number (0);

  XPROCESS (proc)->inherit_coding_system_flag
    = (NILP (buffer) || !inherit_process_coding_system
       ? Qnil : Qt);

  UNGCPRO;
  return proc;
}
#endif	/* HAVE_SOCKETS */

void
deactivate_process (proc)
     Lisp_Object proc;
{
  register int inchannel, outchannel;
  register struct Lisp_Process *p = XPROCESS (proc);

  inchannel = XINT (p->infd);
  outchannel = XINT (p->outfd);

  if (inchannel >= 0)
    {
      /* Beware SIGCHLD hereabouts. */
      flush_pending_output (inchannel);
#ifdef VMS
      {
	VMS_PROC_STUFF *get_vms_process_pointer (), *vs;
	sys$dassgn (outchannel);
	vs = get_vms_process_pointer (p->pid);
	if (vs)
	  give_back_vms_process_stuff (vs);
      }
#else
      close (inchannel);
      if (outchannel >= 0 && outchannel != inchannel)
 	close (outchannel);
#endif

      XSETINT (p->infd, -1);
      XSETINT (p->outfd, -1);
      chan_process[inchannel] = Qnil;
      FD_CLR (inchannel, &input_wait_mask);
      FD_CLR (inchannel, &non_keyboard_wait_mask);
      if (inchannel == max_process_desc)
	{
	  int i;
	  /* We just closed the highest-numbered process input descriptor,
	     so recompute the highest-numbered one now.  */
	  max_process_desc = 0;
	  for (i = 0; i < MAXDESC; i++)
	    if (!NILP (chan_process[i]))
	      max_process_desc = i;
	}
    }
}

/* Close all descriptors currently in use for communication
   with subprocess.  This is used in a newly-forked subprocess
   to get rid of irrelevant descriptors.  */

void
close_process_descs ()
{
#ifndef WINDOWSNT
  int i;
  for (i = 0; i < MAXDESC; i++)
    {
      Lisp_Object process;
      process = chan_process[i];
      if (!NILP (process))
	{
	  int in = XINT (XPROCESS (process)->infd);
	  int out = XINT (XPROCESS (process)->outfd);
	  if (in >= 0)
	    close (in);
	  if (out >= 0 && in != out)
	    close (out);
	}
    }
#endif
}

DEFUN ("accept-process-output", Faccept_process_output, Saccept_process_output,
  0, 3, 0,
  "Allow any pending output from subprocesses to be read by Emacs.\n\
It is read into the process' buffers or given to their filter functions.\n\
Non-nil arg PROCESS means do not return until some output has been received\n\
from PROCESS.\n\
Non-nil second arg TIMEOUT and third arg TIMEOUT-MSECS are number of\n\
seconds and microseconds to wait; return after that much time whether\n\
or not there is input.\n\
Return non-nil iff we received any output before the timeout expired.")
  (process, timeout, timeout_msecs)
     register Lisp_Object process, timeout, timeout_msecs;
{
  int seconds;
  int useconds;

  if (! NILP (process))
    CHECK_PROCESS (process, 0);

  if (! NILP (timeout_msecs))
    {
      CHECK_NUMBER (timeout_msecs, 2);
      useconds = XINT (timeout_msecs);
      if (!INTEGERP (timeout))
	XSETINT (timeout, 0);

      {
	int carry = useconds / 1000000;

	XSETINT (timeout, XINT (timeout) + carry);
	useconds -= carry * 1000000;

	/* I think this clause is necessary because C doesn't
	   guarantee a particular rounding direction for negative
	   integers.  */
	if (useconds < 0)
	  {
	    XSETINT (timeout, XINT (timeout) - 1);
	    useconds += 1000000;
	  }
      }
    }
  else
    useconds = 0;

  if (! NILP (timeout))
    {
      CHECK_NUMBER (timeout, 1);
      seconds = XINT (timeout);
      if (seconds < 0 || (seconds == 0 && useconds == 0))
	seconds = -1;
    }
  else
    {
      if (NILP (process))
	seconds = -1;
      else
	seconds = 0;
    }

  if (NILP (process))
    XSETFASTINT (process, 0);

  return
    (wait_reading_process_input (seconds, useconds, process, 0)
     ? Qt : Qnil);
}

/* This variable is different from waiting_for_input in keyboard.c.
   It is used to communicate to a lisp process-filter/sentinel (via the
   function Fwaiting_for_user_input_p below) whether emacs was waiting
   for user-input when that process-filter was called.
   waiting_for_input cannot be used as that is by definition 0 when
   lisp code is being evalled.
   This is also used in record_asynch_buffer_change.
   For that purpose, this must be 0
   when not inside wait_reading_process_input.  */
static int waiting_for_user_input_p;

/* This is here so breakpoints can be put on it.  */
static void
wait_reading_process_input_1 ()
{
}

/* Read and dispose of subprocess output while waiting for timeout to
   elapse and/or keyboard input to be available.

   TIME_LIMIT is:
     timeout in seconds, or
     zero for no limit, or
     -1 means gobble data immediately available but don't wait for any.

   MICROSECS is:
     an additional duration to wait, measured in microseconds.
     If this is nonzero and time_limit is 0, then the timeout
     consists of MICROSECS only.

   READ_KBD is a lisp value:
     0 to ignore keyboard input, or
     1 to return when input is available, or
     -1 meaning caller will actually read the input, so don't throw to
       the quit handler, or
     a cons cell, meaning wait until its car is non-nil
       (and gobble terminal input into the buffer if any arrives), or
     a process object, meaning wait until something arrives from that
       process.  The return value is true iff we read some input from
       that process.

   DO_DISPLAY != 0 means redisplay should be done to show subprocess
   output that arrives.

   If READ_KBD is a pointer to a struct Lisp_Process, then the
     function returns true iff we received input from that process
     before the timeout elapsed.
   Otherwise, return true iff we received input from any process.  */

int
wait_reading_process_input (time_limit, microsecs, read_kbd, do_display)
     int time_limit, microsecs;
     Lisp_Object read_kbd;
     int do_display;
{
  register int channel, nfds, m;
  static SELECT_TYPE Available;
  int xerrno;
  Lisp_Object proc;
  EMACS_TIME timeout, end_time, garbage;
  SELECT_TYPE Atemp;
  int wait_channel = -1;
  struct Lisp_Process *wait_proc = 0;
  int got_some_input = 0;
  Lisp_Object *wait_for_cell = 0;

  FD_ZERO (&Available);

  /* If read_kbd is a process to watch, set wait_proc and wait_channel
     accordingly.  */
  if (PROCESSP (read_kbd))
    {
      wait_proc = XPROCESS (read_kbd);
      wait_channel = XINT (wait_proc->infd);
      XSETFASTINT (read_kbd, 0);
    }

  /* If waiting for non-nil in a cell, record where.  */
  if (CONSP (read_kbd))
    {
      wait_for_cell = &XCONS (read_kbd)->car;
      XSETFASTINT (read_kbd, 0);
    }

  waiting_for_user_input_p = XINT (read_kbd);

  /* Since we may need to wait several times,
     compute the absolute time to return at.  */
  if (time_limit || microsecs)
    {
      EMACS_GET_TIME (end_time);
      EMACS_SET_SECS_USECS (timeout, time_limit, microsecs);
      EMACS_ADD_TIME (end_time, end_time, timeout);
    }
#ifdef hpux
  /* AlainF 5-Jul-1996
     HP-UX 10.10 seem to have problems with signals coming in
     Causes "poll: interrupted system call" messages when Emacs is run
     in an X window
     Turn off periodic alarms (in case they are in use) */
  stop_polling ();
#endif

  while (1)
    {
      int timeout_reduced_for_timers = 0;

      /* If calling from keyboard input, do not quit
	 since we want to return C-g as an input character.
	 Otherwise, do pending quit if requested.  */
      if (XINT (read_kbd) >= 0)
	QUIT;

      /* Exit now if the cell we're waiting for became non-nil.  */
      if (wait_for_cell && ! NILP (*wait_for_cell))
	break;

      /* Compute time from now till when time limit is up */
      /* Exit if already run out */
      if (time_limit == -1)
	{
	  /* -1 specified for timeout means
	     gobble output available now
	     but don't wait at all. */

	  EMACS_SET_SECS_USECS (timeout, 0, 0);
	}
      else if (time_limit || microsecs)
	{
	  EMACS_GET_TIME (timeout);
	  EMACS_SUB_TIME (timeout, end_time, timeout);
	  if (EMACS_TIME_NEG_P (timeout))
	    break;
	}
      else
	{
	  EMACS_SET_SECS_USECS (timeout, 100000, 0);
	}

      /* Normally we run timers here.
	 But not if wait_for_cell; in those cases,
	 the wait is supposed to be short,
	 and those callers cannot handle running arbitrary Lisp code here.  */
      if (! wait_for_cell)
	{
	  EMACS_TIME timer_delay;
	  int old_timers_run;

	retry:
	  old_timers_run = timers_run;
	  timer_delay = timer_check (1);
	  if (timers_run != old_timers_run && do_display)
	    {
	      redisplay_preserve_echo_area ();
	      /* We must retry, since a timer may have requeued itself
		 and that could alter the time_delay.  */
	      goto retry;
	    }

	  /* If there is unread keyboard input, also return.  */
	  if (XINT (read_kbd) != 0
	      && requeued_events_pending_p ())
	    break;

	  if (! EMACS_TIME_NEG_P (timer_delay) && time_limit != -1)
	    {
	      EMACS_TIME difference;
	      EMACS_SUB_TIME (difference, timer_delay, timeout);
	      if (EMACS_TIME_NEG_P (difference))
		{
		  timeout = timer_delay;
		  timeout_reduced_for_timers = 1;
		}
	    }
	  /* If time_limit is -1, we are not going to wait at all.  */
	  else if (time_limit != -1)
	    {
	      /* This is so a breakpoint can be put here.  */
	      wait_reading_process_input_1 ();
	    }
	}

      /* Cause C-g and alarm signals to take immediate action,
	 and cause input available signals to zero out timeout.

	 It is important that we do this before checking for process
	 activity.  If we get a SIGCHLD after the explicit checks for
	 process activity, timeout is the only way we will know.  */
      if (XINT (read_kbd) < 0)
	set_waiting_for_input (&timeout);

      /* If status of something has changed, and no input is
	 available, notify the user of the change right away.  After
	 this explicit check, we'll let the SIGCHLD handler zap
	 timeout to get our attention.  */
      if (update_tick != process_tick && do_display)
	{
	  Atemp = input_wait_mask;
	  EMACS_SET_SECS_USECS (timeout, 0, 0);
	  if ((select (max (max_process_desc, max_keyboard_desc) + 1,
		       &Atemp, (SELECT_TYPE *)0, (SELECT_TYPE *)0,
		       &timeout)
	       <= 0))
	    {
	      /* It's okay for us to do this and then continue with
		 the loop, since timeout has already been zeroed out.  */
	      clear_waiting_for_input ();
	      status_notify ();
	    }
	}

      /* Don't wait for output from a non-running process.  */
      if (wait_proc != 0 && !NILP (wait_proc->raw_status_low))
	update_status (wait_proc);
      if (wait_proc != 0
	  && ! EQ (wait_proc->status, Qrun))
	{
	  int nread, total_nread = 0;

	  clear_waiting_for_input ();
	  XSETPROCESS (proc, wait_proc);

	  /* Read data from the process, until we exhaust it.  */
	  while (XINT (wait_proc->infd) >= 0
		 && (nread
		     = read_process_output (proc, XINT (wait_proc->infd))))
	    {
              if (0 < nread) 
                total_nread += nread;
#ifdef EIO
	      else if (nread == -1 && EIO == errno)
                break;
#endif
	    }
	  if (total_nread > 0 && do_display)
	    redisplay_preserve_echo_area ();

	  break;
	}

      /* Wait till there is something to do */

      if (wait_for_cell)
	Available = non_process_wait_mask;
      else if (! XINT (read_kbd))
	Available = non_keyboard_wait_mask;
      else
	Available = input_wait_mask;

      /* If frame size has changed or the window is newly mapped,
	 redisplay now, before we start to wait.  There is a race
	 condition here; if a SIGIO arrives between now and the select
	 and indicates that a frame is trashed, the select may block
	 displaying a trashed screen.  */
      if (frame_garbaged && do_display)
	{
	  clear_waiting_for_input ();
	  redisplay_preserve_echo_area ();
	  if (XINT (read_kbd) < 0)
	    set_waiting_for_input (&timeout);
	}

      if (XINT (read_kbd) && detect_input_pending ())
	{
	  nfds = 0;
	  FD_ZERO (&Available);
	}
      else
	nfds = select (max (max_process_desc, max_keyboard_desc) + 1,
		       &Available, (SELECT_TYPE *)0, (SELECT_TYPE *)0,
		       &timeout);

      xerrno = errno;

      /* Make C-g and alarm signals set flags again */
      clear_waiting_for_input ();

      /*  If we woke up due to SIGWINCH, actually change size now.  */
      do_pending_window_change ();

      if (time_limit && nfds == 0 && ! timeout_reduced_for_timers)
	/* We wanted the full specified time, so return now.  */
	break;
      if (nfds < 0)
	{
	  if (xerrno == EINTR)
	    FD_ZERO (&Available);
#ifdef ultrix
	  /* Ultrix select seems to return ENOMEM when it is
	     interrupted.  Treat it just like EINTR.  Bleah.  Note
	     that we want to test for the "ultrix" CPP symbol, not
	     "__ultrix__"; the latter is only defined under GCC, but
	     not by DEC's bundled CC.  -JimB  */
	  else if (xerrno == ENOMEM)
	    FD_ZERO (&Available);
#endif
#ifdef ALLIANT
	  /* This happens for no known reason on ALLIANT.
	     I am guessing that this is the right response. -- RMS.  */
	  else if (xerrno == EFAULT)
	    FD_ZERO (&Available);
#endif
	  else if (xerrno == EBADF)
	    {
#ifdef AIX
	      /* AIX doesn't handle PTY closure the same way BSD does.  On AIX,
		 the child's closure of the pts gives the parent a SIGHUP, and
		 the ptc file descriptor is automatically closed,
		 yielding EBADF here or at select() call above.
		 So, SIGHUP is ignored (see def of PTY_TTY_NAME_SPRINTF
		 in m/ibmrt-aix.h), and here we just ignore the select error.
		 Cleanup occurs c/o status_notify after SIGCLD. */
	      FD_ZERO (&Available); /* Cannot depend on values returned */
#else
	      abort ();
#endif
	    }
	  else
	    error ("select error: %s", strerror (xerrno));
	}
#if defined(sun) && !defined(USG5_4)
      else if (nfds > 0 && keyboard_bit_set (&Available)
	       && interrupt_input)
	/* System sometimes fails to deliver SIGIO.

	   David J. Mackenzie says that Emacs doesn't compile under
	   Solaris if this code is enabled, thus the USG5_4 in the CPP
	   conditional.  "I haven't noticed any ill effects so far.
	   If you find a Solaris expert somewhere, they might know
	   better." */
	kill (getpid (), SIGIO);
#endif

#if 0 /* When polling is used, interrupt_input is 0,
	 so get_input_pending should read the input.
	 So this should not be needed.  */
      /* If we are using polling for input,
	 and we see input available, make it get read now.
	 Otherwise it might not actually get read for a second.
	 And on hpux, since we turn off polling in wait_reading_process_input,
	 it might never get read at all if we don't spend much time
	 outside of wait_reading_process_input.  */
      if (XINT (read_kbd) && interrupt_input
	  && keyboard_bit_set (&Available)
	  && input_polling_used ())
	kill (getpid (), SIGALRM);
#endif

      /* Check for keyboard input */
      /* If there is any, return immediately
	 to give it higher priority than subprocesses */

      if (XINT (read_kbd) != 0
	  && detect_input_pending_run_timers (do_display))
	{
	  swallow_events (do_display);
	  if (detect_input_pending_run_timers (do_display))
	    break;
	}

      /* If there is unread keyboard input, also return.  */
      if (XINT (read_kbd) != 0
	  && requeued_events_pending_p ())
	break;

      /* If we are not checking for keyboard input now,
	 do process events (but don't run any timers).
	 This is so that X events will be processed.
	 Otherwise they may have to wait until polling takes place.
	 That would causes delays in pasting selections, for example.

	 (We used to do this only if wait_for_cell.)  */
      if (XINT (read_kbd) == 0 && detect_input_pending ())
	{
	  swallow_events (do_display);
#if 0  /* Exiting when read_kbd doesn't request that seems wrong, though.  */
	  if (detect_input_pending ())
	    break;
#endif
	}

      /* Exit now if the cell we're waiting for became non-nil.  */
      if (wait_for_cell && ! NILP (*wait_for_cell))
	break;

#ifdef SIGIO
      /* If we think we have keyboard input waiting, but didn't get SIGIO,
	 go read it.  This can happen with X on BSD after logging out.
	 In that case, there really is no input and no SIGIO,
	 but select says there is input.  */

      if (XINT (read_kbd) && interrupt_input
	  && keyboard_bit_set (&Available))
	kill (getpid (), SIGIO);
#endif

      if (! wait_proc)
	got_some_input |= nfds > 0;

      /* If checking input just got us a size-change event from X,
	 obey it now if we should.  */
      if (XINT (read_kbd) || wait_for_cell)
	do_pending_window_change ();

      /* Check for data from a process.  */
      /* Really FIRST_PROC_DESC should be 0 on Unix,
	 but this is safer in the short run.  */
      for (channel = 0; channel <= max_process_desc; channel++)
	{
	  if (FD_ISSET (channel, &Available)
	      && FD_ISSET (channel, &non_keyboard_wait_mask))
	    {
	      int nread;

	      /* If waiting for this channel, arrange to return as
		 soon as no more input to be processed.  No more
		 waiting.  */
	      if (wait_channel == channel)
		{
		  wait_channel = -1;
		  time_limit = -1;
		  got_some_input = 1;
		}
	      proc = chan_process[channel];
	      if (NILP (proc))
		continue;

	      /* Read data from the process, starting with our
		 buffered-ahead character if we have one.  */

	      nread = read_process_output (proc, channel);
	      if (nread > 0)
		{
		  /* Since read_process_output can run a filter,
		     which can call accept-process-output,
		     don't try to read from any other processes
		     before doing the select again.  */
		  FD_ZERO (&Available);

		  if (do_display)
		    redisplay_preserve_echo_area ();
		}
#ifdef EWOULDBLOCK
	      else if (nread == -1 && errno == EWOULDBLOCK)
		;
#endif
	      /* ISC 4.1 defines both EWOULDBLOCK and O_NONBLOCK,
		 and Emacs uses O_NONBLOCK, so what we get is EAGAIN.  */
#ifdef O_NONBLOCK
	      else if (nread == -1 && errno == EAGAIN)
		;
#else
#ifdef O_NDELAY
	      else if (nread == -1 && errno == EAGAIN)
		;
	      /* Note that we cannot distinguish between no input
		 available now and a closed pipe.
		 With luck, a closed pipe will be accompanied by
		 subprocess termination and SIGCHLD.  */
	      else if (nread == 0 && !NETCONN_P (proc))
		;
#endif				/* O_NDELAY */
#endif				/* O_NONBLOCK */
#ifdef HAVE_PTYS
	      /* On some OSs with ptys, when the process on one end of
		 a pty exits, the other end gets an error reading with
		 errno = EIO instead of getting an EOF (0 bytes read).
		 Therefore, if we get an error reading and errno =
		 EIO, just continue, because the child process has
		 exited and should clean itself up soon (e.g. when we
		 get a SIGCHLD).

		 However, it has been known to happen that the SIGCHLD
		 got lost.  So raise the signl again just in case.
		 It can't hurt.  */
	      else if (nread == -1 && errno == EIO)
		kill (getpid (), SIGCHLD);
#endif				/* HAVE_PTYS */
	      /* If we can detect process termination, don't consider the process
		 gone just because its pipe is closed.  */
#ifdef SIGCHLD
	      else if (nread == 0 && !NETCONN_P (proc))
		;
#endif
	      else
		{
		  /* Preserve status of processes already terminated.  */
		  XSETINT (XPROCESS (proc)->tick, ++process_tick);
		  deactivate_process (proc);
		  if (!NILP (XPROCESS (proc)->raw_status_low))
		    update_status (XPROCESS (proc));
		  if (EQ (XPROCESS (proc)->status, Qrun))
		    XPROCESS (proc)->status
		      = Fcons (Qexit, Fcons (make_number (256), Qnil));
		}
	    }
	}			/* end for each file descriptor */
    }				/* end while exit conditions not met */

  waiting_for_user_input_p = 0;

  /* If calling from keyboard input, do not quit
     since we want to return C-g as an input character.
     Otherwise, do pending quit if requested.  */
  if (XINT (read_kbd) >= 0)
    {
      /* Prevent input_pending from remaining set if we quit.  */
      clear_input_pending ();
      QUIT;
    }
#ifdef hpux
  /* AlainF 5-Jul-1996
     HP-UX 10.10 seems to have problems with signals coming in
     Causes "poll: interrupted system call" messages when Emacs is run
     in an X window
     Turn periodic alarms back on */
  start_polling ();
#endif
   
  return got_some_input;
}

/* Given a list (FUNCTION ARGS...), apply FUNCTION to the ARGS.  */

static Lisp_Object
read_process_output_call (fun_and_args)
     Lisp_Object fun_and_args;
{
  return apply1 (XCONS (fun_and_args)->car, XCONS (fun_and_args)->cdr);
}

static Lisp_Object
read_process_output_error_handler (error)
     Lisp_Object error;
{
  cmd_error_internal (error, "error in process filter: ");
  Vinhibit_quit = Qt;
  update_echo_area ();
  Fsleep_for (make_number (2), Qnil);
}

/* Read pending output from the process channel,
   starting with our buffered-ahead character if we have one.
   Yield number of decoded characters read.

   This function reads at most 1024 characters.
   If you want to read all available subprocess output,
   you must call it repeatedly until it returns zero.

   The characters read are decoded according to PROC's coding-system
   for decoding.  */

int
read_process_output (proc, channel)
     Lisp_Object proc;
     register int channel;
{
  register int nchars, nbytes;
  char *chars;
#ifdef VMS
  int chars_allocated = 0;	/* If 1, `chars' should be freed later.  */
#else
  char buf[1024];
#endif
  register Lisp_Object outstream;
  register struct buffer *old = current_buffer;
  register struct Lisp_Process *p = XPROCESS (proc);
  register int opoint;
  struct coding_system *coding = proc_decode_coding_system[channel];
  int chars_in_decoding_buf = 0; /* If 1, `chars' points
				    XSTRING (p->decoding_buf)->data.  */
  int carryover = XINT (p->decoding_carryover);

#ifdef VMS
  VMS_PROC_STUFF *vs, *get_vms_process_pointer();

  vs = get_vms_process_pointer (p->pid);
  if (vs)
    {
      if (!vs->iosb[0])
	return(0);		/* Really weird if it does this */
      if (!(vs->iosb[0] & 1))
	return -1;		/* I/O error */
    }
  else
    error ("Could not get VMS process pointer");
  chars = vs->inputBuffer;
  nbytes = clean_vms_buffer (chars, vs->iosb[1]);
  if (nbytes <= 0)
    {
      start_vms_process_read (vs); /* Crank up the next read on the process */
      return 1;			/* Nothing worth printing, say we got 1 */
    }
  if (carryover > 0)
    {
      /* The data carried over in the previous decoding (which are at
         the tail of decoding buffer) should be prepended to the new
         data read to decode all together.  */
      char *buf = (char *) xmalloc (nbytes + carryover);

      bcopy (XSTRING (p->decoding_buf)->data
	     + STRING_BYTES (XSTRING (p->decoding_buf)) - carryover,
	     buf, carryover);
      bcopy (chars, buf + carryover, nbytes);
      chars = buf;
      chars_allocated = 1;
    }
#else /* not VMS */

  if (carryover)
    /* See the comment above.  */
    bcopy (XSTRING (p->decoding_buf)->data
	   + STRING_BYTES (XSTRING (p->decoding_buf)) - carryover,
	   buf, carryover);

  if (proc_buffered_char[channel] < 0)
    nbytes = read (channel, buf + carryover, (sizeof buf) - carryover);
  else
    {
      buf[carryover] = proc_buffered_char[channel];
      proc_buffered_char[channel] = -1;
      nbytes = read (channel, buf + carryover + 1,
		     (sizeof buf) - carryover - 1);
      if (nbytes < 0)
	nbytes = 1;
      else
	nbytes = nbytes + 1;
    }
  chars = buf;
#endif /* not VMS */

  XSETINT (p->decoding_carryover, 0);

  /* At this point, NBYTES holds number of characters just received
     (including the one in proc_buffered_char[channel]).  */
  if (nbytes <= 0)
    {
      if (nbytes < 0 || coding->mode & CODING_MODE_LAST_BLOCK)
	return nbytes;
      coding->mode |= CODING_MODE_LAST_BLOCK;
    }

  /* Now set NBYTES how many bytes we must decode.  */
  nbytes += carryover;
  nchars = nbytes;

  if (CODING_MAY_REQUIRE_DECODING (coding))
    {
      int require = decoding_buffer_size (coding, nbytes);
      int result;
      
      if (STRING_BYTES (XSTRING (p->decoding_buf)) < require)
	p->decoding_buf = make_uninit_string (require);
      result = decode_coding (coding, chars, XSTRING (p->decoding_buf)->data,
			      nbytes, STRING_BYTES (XSTRING (p->decoding_buf)));
      carryover = nbytes - coding->consumed;
      if (carryover > 0)
	{
	  /* Copy the carryover bytes to the end of p->decoding_buf, to
	     be processed on the next read.  Since decoding_buffer_size
	     asks for an extra amount of space beyond the maximum
	     expected for the output, there should always be sufficient
	     space for the carryover (which is by definition a sequence
	     of bytes that was not long enough to be decoded, and thus
	     has a bounded length).  */
	  if (STRING_BYTES (XSTRING (p->decoding_buf))
	      < coding->produced + carryover)
	    abort ();
	  bcopy (chars + coding->consumed,
		 XSTRING (p->decoding_buf)->data
		 + STRING_BYTES (XSTRING (p->decoding_buf)) - carryover,
		 carryover);
	  XSETINT (p->decoding_carryover, carryover);
	}

      /* A new coding system might be found by `decode_coding'.  */
      if (!EQ (p->decode_coding_system, coding->symbol))
	{
	  p->decode_coding_system = coding->symbol;

	  /* Don't call setup_coding_system for
             proc_decode_coding_system[channel] here.  It is done in
             detect_coding called via decode_coding above.  */

	  /* If a coding system for encoding is not yet decided, we set
	     it as the same as coding-system for decoding.

	     But, before doing that we must check if
	     proc_encode_coding_system[p->outfd] surely points to a
	     valid memory because p->outfd will be changed once EOF is
	     sent to the process.  */
	  if (NILP (p->encode_coding_system)
	      && proc_encode_coding_system[XINT (p->outfd)])
	    {
	      p->encode_coding_system = coding->symbol;
	      setup_coding_system (coding->symbol,
				   proc_encode_coding_system[XINT (p->outfd)]);
	    }
	}

#ifdef VMS
      /*  Now we don't need the contents of `chars'.  */
      if (chars_allocated)
	free (chars);
#endif
      if (coding->produced == 0)
	return 0;
      chars = (char *) XSTRING (p->decoding_buf)->data;
      nbytes = coding->produced;
      nchars = (coding->fake_multibyte
		? multibyte_chars_in_text (chars, nbytes)
		: coding->produced_char);
      chars_in_decoding_buf = 1;
    }
  else
    {
#ifdef VMS
      if (chars_allocated)
	{
	  /* Although we don't have to decode the received data, we
	     must move it to an area which we don't have to free.  */
	  if (! STRINGP (p->decoding_buf)
	      || STRING_BYTES (XSTRING (p->decoding_buf)) < nbytes)
	    p->decoding_buf = make_uninit_string (nbytes);
	  bcopy (chars, XSTRING (p->decoding_buf)->data, nbytes);
	  free (chars);
	  chars = XSTRING (p->decoding_buf)->data;
	  chars_in_decoding_buf = 1;
	}
#endif
      nchars = multibyte_chars_in_text (chars, nbytes);
    }

  Vlast_coding_system_used = coding->symbol;

  /* If the caller required, let the process associated buffer
     inherit the coding-system used to decode the process output.  */
  if (! NILP (p->inherit_coding_system_flag)
      && !NILP (p->buffer) && !NILP (XBUFFER (p->buffer)->name))
    {
      struct buffer *prev_buf = current_buffer;

      Fset_buffer (p->buffer);
      call1 (intern ("after-insert-file-set-buffer-file-coding-system"),
	     make_number (nbytes));
      set_buffer_internal (prev_buf);
    }

  /* Read and dispose of the process output.  */
  outstream = p->filter;
  if (!NILP (outstream))
    {
      /* We inhibit quit here instead of just catching it so that 
	 hitting ^G when a filter happens to be running won't screw
	 it up.  */
      int count = specpdl_ptr - specpdl;
      Lisp_Object odeactivate;
      Lisp_Object obuffer, okeymap;
      Lisp_Object text;
      int outer_running_asynch_code = running_asynch_code;
      int waiting = waiting_for_user_input_p;

      /* No need to gcpro these, because all we do with them later
	 is test them for EQness, and none of them should be a string.  */
      odeactivate = Vdeactivate_mark;
      XSETBUFFER (obuffer, current_buffer);
      okeymap = current_buffer->keymap;

      specbind (Qinhibit_quit, Qt);
      specbind (Qlast_nonmenu_event, Qt);

      /* In case we get recursively called,
	 and we already saved the match data nonrecursively,
	 save the same match data in safely recursive fashion.  */
      if (outer_running_asynch_code)
	{
	  Lisp_Object tem;
	  /* Don't clobber the CURRENT match data, either!  */
	  tem = Fmatch_data (Qnil, Qnil);
	  restore_match_data ();
	  record_unwind_protect (Fset_match_data, Fmatch_data (Qnil, Qnil));
	  Fset_match_data (tem);
	}

      /* For speed, if a search happens within this code,
	 save the match data in a special nonrecursive fashion.  */
      running_asynch_code = 1;

      /* The multibyteness of a string given to the filter is decided
         by which coding system we used for decoding.  */
      if (coding->type == coding_type_no_conversion
	  || coding->type == coding_type_raw_text)
	text = make_unibyte_string (chars, nbytes);
      else
	text = make_multibyte_string (chars, nchars, nbytes);

      internal_condition_case_1 (read_process_output_call,
				 Fcons (outstream,
					Fcons (proc, Fcons (text, Qnil))),
				 !NILP (Vdebug_on_error) ? Qnil : Qerror,
				 read_process_output_error_handler);

      /* If we saved the match data nonrecursively, restore it now.  */
      restore_match_data ();
      running_asynch_code = outer_running_asynch_code;

      /* Handling the process output should not deactivate the mark.  */
      Vdeactivate_mark = odeactivate;

      /* Restore waiting_for_user_input_p as it was
	 when we were called, in case the filter clobbered it.  */
      waiting_for_user_input_p = waiting;

#if 0 /* Call record_asynch_buffer_change unconditionally,
	 because we might have changed minor modes or other things
	 that affect key bindings.  */
      if (! EQ (Fcurrent_buffer (), obuffer)
	  || ! EQ (current_buffer->keymap, okeymap))
#endif
	/* But do it only if the caller is actually going to read events.
	   Otherwise there's no need to make him wake up, and it could
	   cause trouble (for example it would make Fsit_for return).  */
	if (waiting_for_user_input_p == -1)
	  record_asynch_buffer_change ();

#ifdef VMS
      start_vms_process_read (vs);
#endif
      unbind_to (count, Qnil);
      return nchars;
    }

  /* If no filter, write into buffer if it isn't dead.  */
  if (!NILP (p->buffer) && !NILP (XBUFFER (p->buffer)->name))
    {
      Lisp_Object old_read_only;
      int old_begv, old_zv;
      int old_begv_byte, old_zv_byte;
      Lisp_Object odeactivate;
      int before, before_byte;
      int opoint_byte;

      odeactivate = Vdeactivate_mark;

      Fset_buffer (p->buffer);
      opoint = PT;
      opoint_byte = PT_BYTE;
      old_read_only = current_buffer->read_only;
      old_begv = BEGV;
      old_zv = ZV;
      old_begv_byte = BEGV_BYTE;
      old_zv_byte = ZV_BYTE;

      current_buffer->read_only = Qnil;

      /* Insert new output into buffer
	 at the current end-of-output marker,
	 thus preserving logical ordering of input and output.  */
      if (XMARKER (p->mark)->buffer)
	SET_PT_BOTH (clip_to_bounds (BEGV, marker_position (p->mark), ZV),
		     clip_to_bounds (BEGV_BYTE, marker_byte_position (p->mark),
				     ZV_BYTE));
      else
	SET_PT_BOTH (ZV, ZV_BYTE);
      before = PT;
      before_byte = PT_BYTE;

      /* If the output marker is outside of the visible region, save
	 the restriction and widen.  */
      if (! (BEGV <= PT && PT <= ZV))
	Fwiden ();

      if (NILP (current_buffer->enable_multibyte_characters))
	nchars = nbytes;

      /* Insert before markers in case we are inserting where
	 the buffer's mark is, and the user's next command is Meta-y.  */
      if (chars_in_decoding_buf)
	{
	  /* Since multibyteness of p->docoding_buf is corrupted, we
             can't use insert_from_string_before_markers.  */
	  char *temp_buf;

	  temp_buf = (char *) alloca (nbytes);
	  bcopy (XSTRING (p->decoding_buf)->data, temp_buf, nbytes);
	  insert_before_markers (temp_buf, nbytes);
	}
      else
	{
	  insert_1_both (chars, nchars, nbytes, 0, 1, 1);
	  signal_after_change (opoint, 0, PT - opoint);
	}
      set_marker_both (p->mark, p->buffer, PT, PT_BYTE);

      update_mode_lines++;

      /* Make sure opoint and the old restrictions
	 float ahead of any new text just as point would.  */
      if (opoint >= before)
	{
	  opoint += PT - before;
	  opoint_byte += PT_BYTE - before_byte;
	}
      if (old_begv > before)
	{
	  old_begv += PT - before;
	  old_begv_byte += PT_BYTE - before_byte;
	}
      if (old_zv >= before)
	{
	  old_zv += PT - before;
	  old_zv_byte += PT_BYTE - before_byte;
	}

      /* If the restriction isn't what it should be, set it.  */
      if (old_begv != BEGV || old_zv != ZV)
	Fnarrow_to_region (make_number (old_begv), make_number (old_zv));

      /* Handling the process output should not deactivate the mark.  */
      Vdeactivate_mark = odeactivate;

      current_buffer->read_only = old_read_only;
      SET_PT_BOTH (opoint, opoint_byte);
      set_buffer_internal (old);
    }
#ifdef VMS
  start_vms_process_read (vs);
#endif
  return nbytes;
}

DEFUN ("waiting-for-user-input-p", Fwaiting_for_user_input_p, Swaiting_for_user_input_p,
       0, 0, 0,
  "Returns non-nil if emacs is waiting for input from the user.\n\
This is intended for use by asynchronous process output filters and sentinels.")
       ()
{
  return (waiting_for_user_input_p ? Qt : Qnil);
}

/* Sending data to subprocess */

jmp_buf send_process_frame;

SIGTYPE
send_process_trap ()
{
#ifdef BSD4_1
  sigrelse (SIGPIPE);
  sigrelse (SIGALRM);
#endif /* BSD4_1 */
  longjmp (send_process_frame, 1);
}

/* Send some data to process PROC.
   BUF is the beginning of the data; LEN is the number of characters.
   OBJECT is the Lisp object that the data comes from.

   The data is encoded by PROC's coding-system for encoding before it
   is sent.  But if the data ends at the middle of multi-byte
   representation, that incomplete sequence of bytes are sent without
   being encoded.  Should we store them in a buffer to prepend them to
   the data send later?  */

void
send_process (proc, buf, len, object)
     volatile Lisp_Object proc;
     unsigned char *buf;
     int len;
     Lisp_Object object;
{
  /* Use volatile to protect variables from being clobbered by longjmp.  */
  int rv;
  struct coding_system *coding;
  struct gcpro gcpro1;
  int carryover = XINT (XPROCESS (proc)->encoding_carryover);

  GCPRO1 (object);

#ifdef VMS
  struct Lisp_Process *p = XPROCESS (proc);
  VMS_PROC_STUFF *vs, *get_vms_process_pointer();
#endif /* VMS */

  if (! NILP (XPROCESS (proc)->raw_status_low))
    update_status (XPROCESS (proc));
  if (! EQ (XPROCESS (proc)->status, Qrun))
    error ("Process %s not running",
	   XSTRING (XPROCESS (proc)->name)->data);
  if (XINT (XPROCESS (proc)->outfd) < 0)
    error ("Output file descriptor of %s is closed",
	   XSTRING (XPROCESS (proc)->name)->data);

  coding = proc_encode_coding_system[XINT (XPROCESS (proc)->outfd)];
  Vlast_coding_system_used = coding->symbol;

  if (CODING_REQUIRE_ENCODING (coding))
    {
      int require = encoding_buffer_size (coding, len);
      int offset, dummy;
      unsigned char *temp_buf = NULL;

      /* Remember the offset of data because a string or a buffer may
         be relocated.  Setting OFFSET to -1 means we don't have to
         care about relocation.  */
      offset = (BUFFERP (object)
		? BUF_PTR_BYTE_POS (XBUFFER (object), buf)
		: (STRINGP (object)
		   ? buf - XSTRING (object)->data
		   : -1));

      if (carryover > 0)
	{
	  temp_buf = (unsigned char *) xmalloc (len + carryover);

	  if (offset >= 0)
	    {
	      if (BUFFERP (object))
		buf = BUF_BYTE_ADDRESS (XBUFFER (object), offset);
	      else if (STRINGP (object))
		buf = offset + XSTRING (object)->data;
	      /* Now we don't have to care about relocation.  */
	      offset = -1;
	    }
	  bcopy ((XSTRING (XPROCESS (proc)->encoding_buf)->data
		  + STRING_BYTES (XSTRING (XPROCESS (proc)->encoding_buf))
		  - carryover),
		 temp_buf,
		 carryover);
	  bcopy (buf, temp_buf + carryover, len);
	  buf = temp_buf;
	}

      if (STRING_BYTES (XSTRING (XPROCESS (proc)->encoding_buf)) < require)
	{
	  XPROCESS (proc)->encoding_buf = make_uninit_string (require);

	  if (offset >= 0)
	    {
	      if (BUFFERP (object))
		buf = BUF_BYTE_ADDRESS (XBUFFER (object), offset);
	      else if (STRINGP (object))
		buf = offset + XSTRING (object)->data;
	    }
	}
      object = XPROCESS (proc)->encoding_buf;
      encode_coding (coding, buf, XSTRING (object)->data,
		     len, STRING_BYTES (XSTRING (object)));
      len = coding->produced;
      buf = XSTRING (object)->data;
      if (temp_buf)
	xfree (temp_buf);
    }

#ifdef VMS
  vs = get_vms_process_pointer (p->pid);
  if (vs == 0)
    error ("Could not find this process: %x", p->pid);
  else if (write_to_vms_process (vs, buf, len))
    ;
#else

  if (pty_max_bytes == 0)
    {
#if defined (HAVE_FPATHCONF) && defined (_PC_MAX_CANON)
      pty_max_bytes = fpathconf (XFASTINT (XPROCESS (proc)->outfd),
				 _PC_MAX_CANON);
      if (pty_max_bytes < 0)
	pty_max_bytes = 250;
#else
      pty_max_bytes = 250;
#endif
      /* Deduct one, to leave space for the eof.  */
      pty_max_bytes--;
    }

  if (!setjmp (send_process_frame))
    while (len > 0)
      {
	int this = len;
	SIGTYPE (*old_sigpipe)();
	int flush_pty = 0;

	/* Decide how much data we can send in one batch.
	   Long lines need to be split into multiple batches.  */
	if (!NILP (XPROCESS (proc)->pty_flag))
	  {
	    /* Starting this at zero is always correct when not the first iteration
	       because the previous iteration ended by sending C-d.
	       It may not be correct for the first iteration
	       if a partial line was sent in a separate send_process call.
	       If that proves worth handling, we need to save linepos
	       in the process object.  */
	    int linepos = 0;
	    unsigned char *ptr = buf;
	    unsigned char *end = buf + len;

	    /* Scan through this text for a line that is too long.  */
	    while (ptr != end && linepos < pty_max_bytes)
	      {
		if (*ptr == '\n')
		  linepos = 0;
		else
		  linepos++;
		ptr++;
	      }
	    /* If we found one, break the line there
	       and put in a C-d to force the buffer through.  */
	    this = ptr - buf;
	  }

	/* Send this batch, using one or more write calls.  */
	while (this > 0)
	  {
	    old_sigpipe = (SIGTYPE (*) ()) signal (SIGPIPE, send_process_trap);
	    rv = write (XINT (XPROCESS (proc)->outfd), buf, this);
	    signal (SIGPIPE, old_sigpipe);

	    if (rv < 0)
	      {
		if (0
#ifdef EWOULDBLOCK
		    || errno == EWOULDBLOCK
#endif
#ifdef EAGAIN
		    || errno == EAGAIN
#endif
		    )
		  /* Buffer is full.  Wait, accepting input; 
		     that may allow the program
		     to finish doing output and read more.  */
		  {
		    Lisp_Object zero;
		    int offset;

#ifdef BROKEN_PTY_READ_AFTER_EAGAIN
		    /* A gross hack to work around a bug in FreeBSD.
		       In the following sequence, read(2) returns
		       bogus data:

		       write(2)	 1022 bytes
		       write(2)   954 bytes, get EAGAIN
		       read(2)   1024 bytes in process_read_output
		       read(2)     11 bytes in process_read_output

		       That is, read(2) returns more bytes than have
		       ever been written successfully.  The 1033 bytes
		       read are the 1022 bytes written successfully
		       after processing (for example with CRs added if
		       the terminal is set up that way which it is
		       here).  The same bytes will be seen again in a
		       later read(2), without the CRs.  */
		    
		    if (errno == EAGAIN)
		      {
			int flags = FWRITE;
			ioctl (XINT (XPROCESS (proc)->outfd), TIOCFLUSH,
			       &flags);
		      }
#endif /* BROKEN_PTY_READ_AFTER_EAGAIN */
		    
		    /* Running filters might relocate buffers or strings.
		       Arrange to relocate BUF.  */
		    if (BUFFERP (object))
		      offset = BUF_PTR_BYTE_POS (XBUFFER (object), buf);
		    else if (STRINGP (object))
		      offset = buf - XSTRING (object)->data;

		    XSETFASTINT (zero, 0);
#ifdef EMACS_HAS_USECS
		    wait_reading_process_input (0, 20000, zero, 0);
#else
		    wait_reading_process_input (1, 0, zero, 0);
#endif

		    if (BUFFERP (object))
		      buf = BUF_BYTE_ADDRESS (XBUFFER (object), offset);
		    else if (STRINGP (object))
		      buf = offset + XSTRING (object)->data;

		    rv = 0;
		  }
		else
		  /* This is a real error.  */
		  report_file_error ("writing to process", Fcons (proc, Qnil));
	      }
	    buf += rv;
	    len -= rv;
	    this -= rv;
	  }

	/* If we sent just part of the string, put in an EOF
	   to force it through, before we send the rest.  */
	if (len > 0)
	  Fprocess_send_eof (proc);
      }
#endif
  else
    {
      XPROCESS (proc)->raw_status_low = Qnil;
      XPROCESS (proc)->raw_status_high = Qnil;
      XPROCESS (proc)->status = Fcons (Qexit, Fcons (make_number (256), Qnil));
      XSETINT (XPROCESS (proc)->tick, ++process_tick);
      deactivate_process (proc);
#ifdef VMS
      error ("Error writing to process %s; closed it", 
	     XSTRING (XPROCESS (proc)->name)->data);
#else
      error ("SIGPIPE raised on process %s; closed it",
	     XSTRING (XPROCESS (proc)->name)->data);
#endif
    }

  UNGCPRO;
}

DEFUN ("process-send-region", Fprocess_send_region, Sprocess_send_region,
  3, 3, 0,
  "Send current contents of region as input to PROCESS.\n\
PROCESS may be a process, a buffer, the name of a process or buffer, or\n\
nil, indicating the current buffer's process.\n\
Called from program, takes three arguments, PROCESS, START and END.\n\
If the region is more than 500 characters long,\n\
it is sent in several bunches.  This may happen even for shorter regions.\n\
Output from processes can arrive in between bunches.")
  (process, start, end)
     Lisp_Object process, start, end;
{
  Lisp_Object proc;
  int start1, end1;

  proc = get_process (process);
  validate_region (&start, &end);

  if (XINT (start) < GPT && XINT (end) > GPT)
    move_gap (XINT (start));

  start1 = CHAR_TO_BYTE (XINT (start));
  end1 = CHAR_TO_BYTE (XINT (end));
  send_process (proc, BYTE_POS_ADDR (start1), end1 - start1,
		Fcurrent_buffer ());

  return Qnil;
}

DEFUN ("process-send-string", Fprocess_send_string, Sprocess_send_string,
  2, 2, 0,
  "Send PROCESS the contents of STRING as input.\n\
PROCESS may be a process, a buffer, the name of a process or buffer, or\n\
nil, indicating the current buffer's process.\n\
If STRING is more than 500 characters long,\n\
it is sent in several bunches.  This may happen even for shorter strings.\n\
Output from processes can arrive in between bunches.")
  (process, string)
     Lisp_Object process, string;
{
  Lisp_Object proc;
  CHECK_STRING (string, 1);
  proc = get_process (process);
  send_process (proc, XSTRING (string)->data,
		STRING_BYTES (XSTRING (string)), string);
  return Qnil;
}

DEFUN ("process-running-child-p", Fprocess_running_child_p,
       Sprocess_running_child_p, 0, 1, 0,
  "Return t if PROCESS has given the terminal to a child.\n\
If the operating system does not make it possible to find out,\n\
return t unconditionally.")
  (process)
     Lisp_Object process;
{
  /* Initialize in case ioctl doesn't exist or gives an error,
     in a way that will cause returning t.  */
  int gid = 0;
  Lisp_Object proc;
  struct Lisp_Process *p;

  proc = get_process (process);
  p = XPROCESS (proc);

  if (!EQ (p->childp, Qt))
    error ("Process %s is not a subprocess",
	   XSTRING (p->name)->data);
  if (XINT (p->infd) < 0)
    error ("Process %s is not active",
	   XSTRING (p->name)->data);

#ifdef TIOCGPGRP 
  if (!NILP (p->subtty))
    ioctl (XFASTINT (p->subtty), TIOCGPGRP, &gid);
  else
    ioctl (XINT (p->infd), TIOCGPGRP, &gid);
#endif /* defined (TIOCGPGRP ) */

  if (gid == XFASTINT (p->pid))
    return Qnil;
  return Qt;
}

/* send a signal number SIGNO to PROCESS.
   If CURRENT_GROUP is t, that means send to the process group
   that currently owns the terminal being used to communicate with PROCESS.
   This is used for various commands in shell mode.
   If CURRENT_GROUP is lambda, that means send to the process group
   that currently owns the terminal, but only if it is NOT the shell itself.

   If NOMSG is zero, insert signal-announcements into process's buffers
   right away.

   If we can, we try to signal PROCESS by sending control characters
   down the pty.  This allows us to signal inferiors who have changed
   their uid, for which killpg would return an EPERM error.  */

static void
process_send_signal (process, signo, current_group, nomsg)
     Lisp_Object process;
     int signo;
     Lisp_Object current_group;
     int nomsg;
{
  Lisp_Object proc;
  register struct Lisp_Process *p;
  int gid;
  int no_pgrp = 0;

  proc = get_process (process);
  p = XPROCESS (proc);

  if (!EQ (p->childp, Qt))
    error ("Process %s is not a subprocess",
	   XSTRING (p->name)->data);
  if (XINT (p->infd) < 0)
    error ("Process %s is not active",
	   XSTRING (p->name)->data);

  if (NILP (p->pty_flag))
    current_group = Qnil;

  /* If we are using pgrps, get a pgrp number and make it negative.  */
  if (!NILP (current_group))
    {
#ifdef SIGNALS_VIA_CHARACTERS
      /* If possible, send signals to the entire pgrp
	 by sending an input character to it.  */

      /* TERMIOS is the latest and bestest, and seems most likely to
         work.  If the system has it, use it.  */
#ifdef HAVE_TERMIOS
      struct termios t;

      switch (signo)
	{
	case SIGINT:
	  tcgetattr (XINT (p->infd), &t);
	  send_process (proc, &t.c_cc[VINTR], 1, Qnil);
	  return;

	case SIGQUIT:
	  tcgetattr (XINT (p->infd), &t);
  	  send_process (proc, &t.c_cc[VQUIT], 1, Qnil);
  	  return;

  	case SIGTSTP:
	  tcgetattr (XINT (p->infd), &t);
#if defined (VSWTCH) && !defined (PREFER_VSUSP)
  	  send_process (proc, &t.c_cc[VSWTCH], 1, Qnil);
#else
	  send_process (proc, &t.c_cc[VSUSP], 1, Qnil);
#endif
  	  return;
	}

#else /* ! HAVE_TERMIOS */

      /* On Berkeley descendants, the following IOCTL's retrieve the
	 current control characters.  */
#if defined (TIOCGLTC) && defined (TIOCGETC)

      struct tchars c;
      struct ltchars lc;

      switch (signo)
	{
	case SIGINT:
	  ioctl (XINT (p->infd), TIOCGETC, &c);
	  send_process (proc, &c.t_intrc, 1, Qnil);
	  return;
	case SIGQUIT:
	  ioctl (XINT (p->infd), TIOCGETC, &c);
	  send_process (proc, &c.t_quitc, 1, Qnil);
	  return;
#ifdef SIGTSTP
	case SIGTSTP:
	  ioctl (XINT (p->infd), TIOCGLTC, &lc);
	  send_process (proc, &lc.t_suspc, 1, Qnil);
	  return;
#endif /* ! defined (SIGTSTP) */
	}

#else /* ! defined (TIOCGLTC) && defined (TIOCGETC) */

      /* On SYSV descendants, the TCGETA ioctl retrieves the current control
	 characters.  */
#ifdef TCGETA
      struct termio t;
      switch (signo)
	{
	case SIGINT:
	  ioctl (XINT (p->infd), TCGETA, &t);
	  send_process (proc, &t.c_cc[VINTR], 1, Qnil);
	  return;
	case SIGQUIT:
	  ioctl (XINT (p->infd), TCGETA, &t);
	  send_process (proc, &t.c_cc[VQUIT], 1, Qnil);
	  return;
#ifdef SIGTSTP
	case SIGTSTP:
	  ioctl (XINT (p->infd), TCGETA, &t);
	  send_process (proc, &t.c_cc[VSWTCH], 1, Qnil);
	  return;
#endif /* ! defined (SIGTSTP) */
	}
#else /* ! defined (TCGETA) */
      Your configuration files are messed up.
      /* If your system configuration files define SIGNALS_VIA_CHARACTERS,
	 you'd better be using one of the alternatives above!  */
#endif /* ! defined (TCGETA) */
#endif /* ! defined (TIOCGLTC) && defined (TIOCGETC) */
#endif /* ! defined HAVE_TERMIOS */
#endif /* ! defined (SIGNALS_VIA_CHARACTERS) */

#ifdef TIOCGPGRP 
      /* Get the pgrp using the tty itself, if we have that.
	 Otherwise, use the pty to get the pgrp.
	 On pfa systems, saka@pfu.fujitsu.co.JP writes:
	 "TIOCGPGRP symbol defined in sys/ioctl.h at E50.
	 But, TIOCGPGRP does not work on E50 ;-P works fine on E60"
	 His patch indicates that if TIOCGPGRP returns an error, then
	 we should just assume that p->pid is also the process group id.  */
      {
	int err;

	if (!NILP (p->subtty))
	  err = ioctl (XFASTINT (p->subtty), TIOCGPGRP, &gid);
	else
	  err = ioctl (XINT (p->infd), TIOCGPGRP, &gid);

#ifdef pfa
	if (err == -1)
	  gid = - XFASTINT (p->pid);
#endif /* ! defined (pfa) */
      }
      if (gid == -1)
	no_pgrp = 1;
      else
	gid = - gid;
#else  /* ! defined (TIOCGPGRP ) */
      /* Can't select pgrps on this system, so we know that
	 the child itself heads the pgrp.  */
      gid = - XFASTINT (p->pid);
#endif /* ! defined (TIOCGPGRP ) */

      /* If current_group is lambda, and the shell owns the terminal,
	 don't send any signal.  */
      if (EQ (current_group, Qlambda) && gid == - XFASTINT (p->pid))
	return;
    }
  else
    gid = - XFASTINT (p->pid);

  switch (signo)
    {
#ifdef SIGCONT
    case SIGCONT:
      p->raw_status_low = Qnil;
      p->raw_status_high = Qnil;
      p->status = Qrun;
      XSETINT (p->tick, ++process_tick);
      if (!nomsg)
	status_notify ();
      break;
#endif /* ! defined (SIGCONT) */
    case SIGINT:
#ifdef VMS
      send_process (proc, "\003", 1, Qnil);	/* ^C */
      goto whoosh;
#endif
    case SIGQUIT:
#ifdef VMS
      send_process (proc, "\031", 1, Qnil);	/* ^Y */
      goto whoosh;
#endif
    case SIGKILL:
#ifdef VMS
      sys$forcex (&(XFASTINT (p->pid)), 0, 1);
      whoosh:
#endif
      flush_pending_output (XINT (p->infd));
      break;
    }

  /* If we don't have process groups, send the signal to the immediate
     subprocess.  That isn't really right, but it's better than any
     obvious alternative.  */
  if (no_pgrp)
    {
      kill (XFASTINT (p->pid), signo);
      return;
    }

  /* gid may be a pid, or minus a pgrp's number */
#ifdef TIOCSIGSEND
  if (!NILP (current_group))
    ioctl (XINT (p->infd), TIOCSIGSEND, signo);
  else
    {
      gid = - XFASTINT (p->pid);
      kill (gid, signo);
    }
#else /* ! defined (TIOCSIGSEND) */
  EMACS_KILLPG (-gid, signo);
#endif /* ! defined (TIOCSIGSEND) */
}

DEFUN ("interrupt-process", Finterrupt_process, Sinterrupt_process, 0, 2, 0,
  "Interrupt process PROCESS.\n\
PROCESS may be a process, a buffer, or the name of a process or buffer.\n\
nil or no arg means current buffer's process.\n\
Second arg CURRENT-GROUP non-nil means send signal to\n\
the current process-group of the process's controlling terminal\n\
rather than to the process's own process group.\n\
If the process is a shell, this means interrupt current subjob\n\
rather than the shell.\n\
\n\
If CURRENT-GROUP is `lambda', and if the shell owns the terminal,\n\
don't send the signal.")
  (process, current_group)
     Lisp_Object process, current_group;
{
  process_send_signal (process, SIGINT, current_group, 0);
  return process;
}

DEFUN ("kill-process", Fkill_process, Skill_process, 0, 2, 0,
  "Kill process PROCESS.  May be process or name of one.\n\
See function `interrupt-process' for more details on usage.")
  (process, current_group)
     Lisp_Object process, current_group;
{
  process_send_signal (process, SIGKILL, current_group, 0);
  return process;
}

DEFUN ("quit-process", Fquit_process, Squit_process, 0, 2, 0,
  "Send QUIT signal to process PROCESS.  May be process or name of one.\n\
See function `interrupt-process' for more details on usage.")
  (process, current_group)
     Lisp_Object process, current_group;
{
  process_send_signal (process, SIGQUIT, current_group, 0);
  return process;
}

DEFUN ("stop-process", Fstop_process, Sstop_process, 0, 2, 0,
  "Stop process PROCESS.  May be process or name of one.\n\
See function `interrupt-process' for more details on usage.")
  (process, current_group)
     Lisp_Object process, current_group;
{
#ifndef SIGTSTP
  error ("no SIGTSTP support");
#else
  process_send_signal (process, SIGTSTP, current_group, 0);
#endif
  return process;
}

DEFUN ("continue-process", Fcontinue_process, Scontinue_process, 0, 2, 0,
  "Continue process PROCESS.  May be process or name of one.\n\
See function `interrupt-process' for more details on usage.")
  (process, current_group)
     Lisp_Object process, current_group;
{
#ifdef SIGCONT
    process_send_signal (process, SIGCONT, current_group, 0);
#else
    error ("no SIGCONT support");
#endif
  return process;
}

DEFUN ("signal-process", Fsignal_process, Ssignal_process,
  2, 2, "nProcess number: \nnSignal code: ",
  "Send the process with process id PID the signal with code SIGCODE.\n\
PID must be an integer.  The process need not be a child of this Emacs.\n\
SIGCODE may be an integer, or a symbol whose name is a signal name.")
  (pid, sigcode)
     Lisp_Object pid, sigcode;
{
  CHECK_NUMBER (pid, 0);

#define handle_signal(NAME, VALUE)		\
  else if (!strcmp (name, NAME))		\
    XSETINT (sigcode, VALUE)

  if (INTEGERP (sigcode))
    ;
  else
    {
      unsigned char *name;

      CHECK_SYMBOL (sigcode, 1);
      name = XSYMBOL (sigcode)->name->data;

      if (0)
	;
#ifdef SIGHUP
      handle_signal ("SIGHUP", SIGHUP);
#endif
#ifdef SIGINT
      handle_signal ("SIGINT", SIGINT);
#endif
#ifdef SIGQUIT
      handle_signal ("SIGQUIT", SIGQUIT);
#endif
#ifdef SIGILL
      handle_signal ("SIGILL", SIGILL);
#endif
#ifdef SIGABRT
      handle_signal ("SIGABRT", SIGABRT);
#endif
#ifdef SIGEMT
      handle_signal ("SIGEMT", SIGEMT);
#endif
#ifdef SIGKILL
      handle_signal ("SIGKILL", SIGKILL);
#endif
#ifdef SIGFPE
      handle_signal ("SIGFPE", SIGFPE);
#endif
#ifdef SIGBUS
      handle_signal ("SIGBUS", SIGBUS);
#endif
#ifdef SIGSEGV
      handle_signal ("SIGSEGV", SIGSEGV);
#endif
#ifdef SIGSYS
      handle_signal ("SIGSYS", SIGSYS);
#endif
#ifdef SIGPIPE
      handle_signal ("SIGPIPE", SIGPIPE);
#endif
#ifdef SIGALRM
      handle_signal ("SIGALRM", SIGALRM);
#endif
#ifdef SIGTERM
      handle_signal ("SIGTERM", SIGTERM);
#endif
#ifdef SIGURG
      handle_signal ("SIGURG", SIGURG);
#endif
#ifdef SIGSTOP
      handle_signal ("SIGSTOP", SIGSTOP);
#endif
#ifdef SIGTSTP
      handle_signal ("SIGTSTP", SIGTSTP);
#endif
#ifdef SIGCONT
      handle_signal ("SIGCONT", SIGCONT);
#endif
#ifdef SIGCHLD
      handle_signal ("SIGCHLD", SIGCHLD);
#endif
#ifdef SIGTTIN
      handle_signal ("SIGTTIN", SIGTTIN);
#endif
#ifdef SIGTTOU
      handle_signal ("SIGTTOU", SIGTTOU);
#endif
#ifdef SIGIO
      handle_signal ("SIGIO", SIGIO);
#endif
#ifdef SIGXCPU
      handle_signal ("SIGXCPU", SIGXCPU);
#endif
#ifdef SIGXFSZ
      handle_signal ("SIGXFSZ", SIGXFSZ);
#endif
#ifdef SIGVTALRM
      handle_signal ("SIGVTALRM", SIGVTALRM);
#endif
#ifdef SIGPROF
      handle_signal ("SIGPROF", SIGPROF);
#endif
#ifdef SIGWINCH
      handle_signal ("SIGWINCH", SIGWINCH);
#endif
#ifdef SIGINFO
      handle_signal ("SIGINFO", SIGINFO);
#endif
#ifdef SIGUSR1
      handle_signal ("SIGUSR1", SIGUSR1);
#endif
#ifdef SIGUSR2
      handle_signal ("SIGUSR2", SIGUSR2);
#endif
      else
	error ("Undefined signal name %s", name);
    }

#undef handle_signal

  return make_number (kill (XINT (pid), XINT (sigcode)));
}

DEFUN ("process-send-eof", Fprocess_send_eof, Sprocess_send_eof, 0, 1, 0,
  "Make PROCESS see end-of-file in its input.\n\
EOF comes after any text already sent to it.\n\
PROCESS may be a process, a buffer, the name of a process or buffer, or\n\
nil, indicating the current buffer's process.\n\
If PROCESS is a network connection, or is a process communicating\n\
through a pipe (as opposed to a pty), then you cannot send any more\n\
text to PROCESS after you call this function.")
  (process)
     Lisp_Object process;
{
  Lisp_Object proc;
  struct coding_system *coding;

  proc = get_process (process);
  coding = proc_encode_coding_system[XINT (XPROCESS (proc)->outfd)];

  /* Make sure the process is really alive.  */
  if (! NILP (XPROCESS (proc)->raw_status_low))
    update_status (XPROCESS (proc));
  if (! EQ (XPROCESS (proc)->status, Qrun))
    error ("Process %s not running", XSTRING (XPROCESS (proc)->name)->data);

  if (CODING_REQUIRE_FLUSHING (coding))
    {
      coding->mode |= CODING_MODE_LAST_BLOCK;
      send_process (proc, "", 0, Qnil);
    }

#ifdef VMS
  send_process (proc, "\032", 1, Qnil); 	/* ^z */
#else
  if (!NILP (XPROCESS (proc)->pty_flag))
    send_process (proc, "\004", 1, Qnil);
  else
    {
      int old_outfd, new_outfd;

#ifdef HAVE_SHUTDOWN
      /* If this is a network connection, or socketpair is used
	 for communication with the subprocess, call shutdown to cause EOF.
	 (In some old system, shutdown to socketpair doesn't work.
	 Then we just can't win.)  */
      if (NILP (XPROCESS (proc)->pid)
	  || XINT (XPROCESS (proc)->outfd) == XINT (XPROCESS (proc)->infd))
	shutdown (XINT (XPROCESS (proc)->outfd), 1);
      /* In case of socketpair, outfd == infd, so don't close it.  */
      if (XINT (XPROCESS (proc)->outfd) != XINT (XPROCESS (proc)->infd))
	close (XINT (XPROCESS (proc)->outfd));
#else /* not HAVE_SHUTDOWN */
      close (XINT (XPROCESS (proc)->outfd));
#endif /* not HAVE_SHUTDOWN */
      new_outfd = open (NULL_DEVICE, O_WRONLY);
      old_outfd = XINT (XPROCESS (proc)->outfd);

      if (!proc_encode_coding_system[new_outfd])
	proc_encode_coding_system[new_outfd]
	  = (struct coding_system *) xmalloc (sizeof (struct coding_system));
      bcopy (proc_encode_coding_system[old_outfd],
	     proc_encode_coding_system[new_outfd],
	     sizeof (struct coding_system));
      bzero (proc_encode_coding_system[old_outfd],
	     sizeof (struct coding_system));

      XSETINT (XPROCESS (proc)->outfd, new_outfd);
    }
#endif /* VMS */
  return process;
}

/* Kill all processes associated with `buffer'.
 If `buffer' is nil, kill all processes  */

void
kill_buffer_processes (buffer)
     Lisp_Object buffer;
{
  Lisp_Object tail, proc;

  for (tail = Vprocess_alist; GC_CONSP (tail); tail = XCONS (tail)->cdr)
    {
      proc = XCONS (XCONS (tail)->car)->cdr;
      if (GC_PROCESSP (proc)
	  && (NILP (buffer) || EQ (XPROCESS (proc)->buffer, buffer)))
	{
	  if (NETCONN_P (proc))
	    Fdelete_process (proc);
	  else if (XINT (XPROCESS (proc)->infd) >= 0)
	    process_send_signal (proc, SIGHUP, Qnil, 1);
	}
    }
}

/* On receipt of a signal that a child status has changed,
 loop asking about children with changed statuses until
 the system says there are no more.
   All we do is change the status;
 we do not run sentinels or print notifications.
 That is saved for the next time keyboard input is done,
 in order to avoid timing errors.  */

/** WARNING: this can be called during garbage collection.
 Therefore, it must not be fooled by the presence of mark bits in
 Lisp objects.  */

/** USG WARNING:  Although it is not obvious from the documentation
 in signal(2), on a USG system the SIGCLD handler MUST NOT call
 signal() before executing at least one wait(), otherwise the handler
 will be called again, resulting in an infinite loop.  The relevant
 portion of the documentation reads "SIGCLD signals will be queued
 and the signal-catching function will be continually reentered until
 the queue is empty".  Invoking signal() causes the kernel to reexamine
 the SIGCLD queue.   Fred Fish, UniSoft Systems Inc. */

SIGTYPE
sigchld_handler (signo)
     int signo;
{
  int old_errno = errno;
  Lisp_Object proc;
  register struct Lisp_Process *p;
  extern EMACS_TIME *input_available_clear_time;

#ifdef BSD4_1
  extern int sigheld;
  sigheld |= sigbit (SIGCHLD);
#endif

  while (1)
    {
      register int pid;
      WAITTYPE w;
      Lisp_Object tail;

#ifdef WNOHANG
#ifndef WUNTRACED
#define WUNTRACED 0
#endif /* no WUNTRACED */
      /* Keep trying to get a status until we get a definitive result.  */
      do 
	{
	  errno = 0;
	  pid = wait3 (&w, WNOHANG | WUNTRACED, 0);
	}
      while (pid <= 0 && errno == EINTR);

      if (pid <= 0)
	{
	  /* A real failure.  We have done all our job, so return.  */

	  /* USG systems forget handlers when they are used;
	     must reestablish each time */
#if defined (USG) && !defined (POSIX_SIGNALS)
	  signal (signo, sigchld_handler);   /* WARNING - must come after wait3() */
#endif
#ifdef  BSD4_1
	  sigheld &= ~sigbit (SIGCHLD);
	  sigrelse (SIGCHLD);
#endif
	  errno = old_errno;
	  return;
	}
#else
      pid = wait (&w);
#endif /* no WNOHANG */

      /* Find the process that signaled us, and record its status.  */

      p = 0;
      for (tail = Vprocess_alist; CONSP (tail); tail = XCONS (tail)->cdr)
	{
	  proc = XCONS (XCONS (tail)->car)->cdr;
	  p = XPROCESS (proc);
	  if (EQ (p->childp, Qt) && XFASTINT (p->pid) == pid)
	    break;
	  p = 0;
	}

      /* Look for an asynchronous process whose pid hasn't been filled
	 in yet.  */
      if (p == 0)
	for (tail = Vprocess_alist; CONSP (tail); tail = XCONS (tail)->cdr)
	  {
	    proc = XCONS (XCONS (tail)->car)->cdr;
	    p = XPROCESS (proc);
	    if (INTEGERP (p->pid) && XINT (p->pid) == -1)
	      break;
	    p = 0;
	  }
      
      /* Change the status of the process that was found.  */
      if (p != 0)
	{
	  union { int i; WAITTYPE wt; } u;
	  int clear_desc_flag = 0;
	  
	  XSETINT (p->tick, ++process_tick);
	  u.wt = w;
	  XSETINT (p->raw_status_low, u.i & 0xffff);
	  XSETINT (p->raw_status_high, u.i >> 16);
	  
	  /* If process has terminated, stop waiting for its output.  */
	  if ((WIFSIGNALED (w) || WIFEXITED (w))
	      && XINT (p->infd) >= 0)
	    clear_desc_flag = 1;

	  /* We use clear_desc_flag to avoid a compiler bug in Microsoft C.  */
	  if (clear_desc_flag)
	    {
	      FD_CLR (XINT (p->infd), &input_wait_mask);
	      FD_CLR (XINT (p->infd), &non_keyboard_wait_mask);
	    }

	  /* Tell wait_reading_process_input that it needs to wake up and
	     look around.  */
	  if (input_available_clear_time)
	    EMACS_SET_SECS_USECS (*input_available_clear_time, 0, 0);
	}

	/* There was no asynchronous process found for that id.  Check
	   if we have a synchronous process.  */
      else
	{
	  synch_process_alive = 0;

	  /* Report the status of the synchronous process.  */
	  if (WIFEXITED (w))
	    synch_process_retcode = WRETCODE (w);
	  else if (WIFSIGNALED (w))
	    {
	      int code = WTERMSIG (w);
	      char *signame = 0;

	      if (code < NSIG)
		{
#ifndef VMS
		  /* Suppress warning if the table has const char *.  */
		  signame = (char *) sys_siglist[code];
#else
		  signame = sys_errlist[code];
#endif
		}
	      if (signame == 0)
		signame = "unknown";

	      synch_process_death = signame;
	    }

	  /* Tell wait_reading_process_input that it needs to wake up and
	     look around.  */
	  if (input_available_clear_time)
	    EMACS_SET_SECS_USECS (*input_available_clear_time, 0, 0);
	}

      /* On some systems, we must return right away.
	 If any more processes want to signal us, we will
	 get another signal.
	 Otherwise (on systems that have WNOHANG), loop around
	 to use up all the processes that have something to tell us.  */
#if defined (USG) && ! (defined (HPUX) && defined (WNOHANG)) || defined (WINDOWSNT)
#if defined (USG) && ! defined (POSIX_SIGNALS)
      signal (signo, sigchld_handler);
#endif
      errno = old_errno;
      return;
#endif /* USG, but not HPUX with WNOHANG */
    }
}


static Lisp_Object
exec_sentinel_unwind (data)
     Lisp_Object data;
{
  XPROCESS (XCONS (data)->car)->sentinel = XCONS (data)->cdr;
  return Qnil;
}

static Lisp_Object
exec_sentinel_error_handler (error)
     Lisp_Object error;
{
  cmd_error_internal (error, "error in process sentinel: ");
  Vinhibit_quit = Qt;
  update_echo_area ();
  Fsleep_for (make_number (2), Qnil);
}

static void
exec_sentinel (proc, reason)
     Lisp_Object proc, reason;
{
  Lisp_Object sentinel, obuffer, odeactivate, okeymap;
  register struct Lisp_Process *p = XPROCESS (proc);
  int count = specpdl_ptr - specpdl;
  int outer_running_asynch_code = running_asynch_code;
  int waiting = waiting_for_user_input_p;

  /* No need to gcpro these, because all we do with them later
     is test them for EQness, and none of them should be a string.  */
  odeactivate = Vdeactivate_mark;
  XSETBUFFER (obuffer, current_buffer);
  okeymap = current_buffer->keymap;

  sentinel = p->sentinel;
  if (NILP (sentinel))
    return;

  /* Zilch the sentinel while it's running, to avoid recursive invocations;
     assure that it gets restored no matter how the sentinel exits.  */
  p->sentinel = Qnil;
  record_unwind_protect (exec_sentinel_unwind, Fcons (proc, sentinel));
  /* Inhibit quit so that random quits don't screw up a running filter.  */
  specbind (Qinhibit_quit, Qt);
  specbind (Qlast_nonmenu_event, Qt);

  /* In case we get recursively called,
     and we already saved the match data nonrecursively,
     save the same match data in safely recursive fashion.  */
  if (outer_running_asynch_code)
    {
      Lisp_Object tem;
      tem = Fmatch_data (Qnil, Qnil);
      restore_match_data ();
      record_unwind_protect (Fset_match_data, Fmatch_data (Qnil, Qnil));
      Fset_match_data (tem);
    }

  /* For speed, if a search happens within this code,
     save the match data in a special nonrecursive fashion.  */
  running_asynch_code = 1;

  internal_condition_case_1 (read_process_output_call,
			     Fcons (sentinel,
				    Fcons (proc, Fcons (reason, Qnil))),
			     !NILP (Vdebug_on_error) ? Qnil : Qerror,
			     exec_sentinel_error_handler);

  /* If we saved the match data nonrecursively, restore it now.  */
  restore_match_data ();
  running_asynch_code = outer_running_asynch_code;

  Vdeactivate_mark = odeactivate;

  /* Restore waiting_for_user_input_p as it was
     when we were called, in case the filter clobbered it.  */
  waiting_for_user_input_p = waiting;

#if 0
  if (! EQ (Fcurrent_buffer (), obuffer)
      || ! EQ (current_buffer->keymap, okeymap))
#endif
    /* But do it only if the caller is actually going to read events.
       Otherwise there's no need to make him wake up, and it could
       cause trouble (for example it would make Fsit_for return).  */
    if (waiting_for_user_input_p == -1)
      record_asynch_buffer_change ();

  unbind_to (count, Qnil);
}

/* Report all recent events of a change in process status
   (either run the sentinel or output a message).
   This is done while Emacs is waiting for keyboard input.  */

void
status_notify ()
{
  register Lisp_Object proc, buffer;
  Lisp_Object tail, msg;
  struct gcpro gcpro1, gcpro2;

  tail = Qnil;
  msg = Qnil;
  /* We need to gcpro tail; if read_process_output calls a filter
     which deletes a process and removes the cons to which tail points
     from Vprocess_alist, and then causes a GC, tail is an unprotected
     reference.  */
  GCPRO2 (tail, msg);

  /* Set this now, so that if new processes are created by sentinels
     that we run, we get called again to handle their status changes.  */
  update_tick = process_tick;

  for (tail = Vprocess_alist; !NILP (tail); tail = Fcdr (tail))
    {
      Lisp_Object symbol;
      register struct Lisp_Process *p;

      proc = Fcdr (Fcar (tail));
      p = XPROCESS (proc);

      if (XINT (p->tick) != XINT (p->update_tick))
	{
	  XSETINT (p->update_tick, XINT (p->tick));

	  /* If process is still active, read any output that remains.  */
	  while (! EQ (p->filter, Qt)
		 && XINT (p->infd) >= 0
		 && read_process_output (proc, XINT (p->infd)) > 0);

	  buffer = p->buffer;

	  /* Get the text to use for the message.  */
	  if (!NILP (p->raw_status_low))
	    update_status (p);
	  msg = status_message (p->status);

	  /* If process is terminated, deactivate it or delete it.  */
	  symbol = p->status;
	  if (CONSP (p->status))
	    symbol = XCONS (p->status)->car;

	  if (EQ (symbol, Qsignal) || EQ (symbol, Qexit)
	      || EQ (symbol, Qclosed))
	    {
	      if (delete_exited_processes)
		remove_process (proc);
	      else
		deactivate_process (proc);
	    }

	  /* The actions above may have further incremented p->tick.
	     So set p->update_tick again
	     so that an error in the sentinel will not cause
	     this code to be run again.  */
	  XSETINT (p->update_tick, XINT (p->tick));
	  /* Now output the message suitably.  */
	  if (!NILP (p->sentinel))
	    exec_sentinel (proc, msg);
	  /* Don't bother with a message in the buffer
	     when a process becomes runnable.  */
	  else if (!EQ (symbol, Qrun) && !NILP (buffer))
	    {
	      Lisp_Object ro, tem;
	      struct buffer *old = current_buffer;
	      int opoint, opoint_byte;
	      int before, before_byte;

	      ro = XBUFFER (buffer)->read_only;

	      /* Avoid error if buffer is deleted
		 (probably that's why the process is dead, too) */
	      if (NILP (XBUFFER (buffer)->name))
		continue;
	      Fset_buffer (buffer);

	      opoint = PT;
	      opoint_byte = PT_BYTE;
	      /* Insert new output into buffer
		 at the current end-of-output marker,
		 thus preserving logical ordering of input and output.  */
	      if (XMARKER (p->mark)->buffer)
		Fgoto_char (p->mark);
	      else
		SET_PT_BOTH (ZV, ZV_BYTE);

	      before = PT;
	      before_byte = PT_BYTE;

	      tem = current_buffer->read_only;
	      current_buffer->read_only = Qnil;
	      insert_string ("\nProcess ");
	      Finsert (1, &p->name);
	      insert_string (" ");
	      Finsert (1, &msg);
	      current_buffer->read_only = tem;
	      set_marker_both (p->mark, p->buffer, PT, PT_BYTE);

	      if (opoint >= before)
		SET_PT_BOTH (opoint + (PT - before),
			     opoint_byte + (PT_BYTE - before_byte));
	      else
		SET_PT_BOTH (opoint, opoint_byte);

	      set_buffer_internal (old);
	    }
	}
    } /* end for */

  update_mode_lines++;  /* in case buffers use %s in mode-line-format */
  redisplay_preserve_echo_area ();

  UNGCPRO;
}


DEFUN ("set-process-coding-system", Fset_process_coding_system,
       Sset_process_coding_system, 1, 3, 0,
  "Set coding systems of PROCESS to DECODING and ENCODING.\n\
DECODING will be used to decode subprocess output and ENCODING to\n\
encode subprocess input.")
  (proc, decoding, encoding)
     register Lisp_Object proc, decoding, encoding;
{
  register struct Lisp_Process *p;

  CHECK_PROCESS (proc, 0);
  p = XPROCESS (proc);
  if (XINT (p->infd) < 0)
    error ("Input file descriptor of %s closed", XSTRING (p->name)->data);
  if (XINT (p->outfd) < 0)
    error ("Output file descriptor of %s closed", XSTRING (p->name)->data);

  p->decode_coding_system = Fcheck_coding_system (decoding);
  p->encode_coding_system = Fcheck_coding_system (encoding);
  setup_coding_system (decoding,
		       proc_decode_coding_system[XINT (p->infd)]);
  setup_coding_system (encoding,
		       proc_encode_coding_system[XINT (p->outfd)]);

  return Qnil;
}

DEFUN ("process-coding-system",
       Fprocess_coding_system, Sprocess_coding_system, 1, 1, 0,
  "Return a cons of coding systems for decoding and encoding of PROCESS.")
  (proc)
     register Lisp_Object proc;
{
  CHECK_PROCESS (proc, 0);
  return Fcons (XPROCESS (proc)->decode_coding_system,
		XPROCESS (proc)->encode_coding_system);
}

/* The first time this is called, assume keyboard input comes from DESC
   instead of from where we used to expect it.
   Subsequent calls mean assume input keyboard can come from DESC
   in addition to other places.  */

static int add_keyboard_wait_descriptor_called_flag;

void
add_keyboard_wait_descriptor (desc)
     int desc;
{
  if (! add_keyboard_wait_descriptor_called_flag)
    FD_CLR (0, &input_wait_mask);
  add_keyboard_wait_descriptor_called_flag = 1;
  FD_SET (desc, &input_wait_mask);
  FD_SET (desc, &non_process_wait_mask);
  if (desc > max_keyboard_desc)
    max_keyboard_desc = desc;
}

/* From now on, do not expect DESC to give keyboard input.  */

void
delete_keyboard_wait_descriptor (desc)
     int desc;
{
  int fd;
  int lim = max_keyboard_desc;

  FD_CLR (desc, &input_wait_mask);
  FD_CLR (desc, &non_process_wait_mask);

  if (desc == max_keyboard_desc)
    for (fd = 0; fd < lim; fd++)
      if (FD_ISSET (fd, &input_wait_mask)
	  && !FD_ISSET (fd, &non_keyboard_wait_mask))
	max_keyboard_desc = fd;
}

/* Return nonzero if *MASK has a bit set
   that corresponds to one of the keyboard input descriptors.  */

int
keyboard_bit_set (mask)
     SELECT_TYPE *mask;
{
  int fd;

  for (fd = 0; fd <= max_keyboard_desc; fd++)
    if (FD_ISSET (fd, mask) && FD_ISSET (fd, &input_wait_mask)
	&& !FD_ISSET (fd, &non_keyboard_wait_mask))
      return 1;

  return 0;
}

void
init_process ()
{
  register int i;

#ifdef SIGCHLD
#ifndef CANNOT_DUMP
  if (! noninteractive || initialized)
#endif
    signal (SIGCHLD, sigchld_handler);
#endif

  FD_ZERO (&input_wait_mask);
  FD_ZERO (&non_keyboard_wait_mask);
  FD_ZERO (&non_process_wait_mask);
  max_process_desc = 0;

  FD_SET (0, &input_wait_mask);

  Vprocess_alist = Qnil;
  for (i = 0; i < MAXDESC; i++)
    {
      chan_process[i] = Qnil;
      proc_buffered_char[i] = -1;
    }
  bzero (proc_decode_coding_system, sizeof proc_decode_coding_system);
  bzero (proc_encode_coding_system, sizeof proc_encode_coding_system);

  Vdefault_process_coding_system
    = (NILP (buffer_defaults.enable_multibyte_characters)
       ? Fcons (Qraw_text, Qnil)
       : Fcons (Qemacs_mule, Qnil));
}

void
syms_of_process ()
{
  Qprocessp = intern ("processp");
  staticpro (&Qprocessp);
  Qrun = intern ("run");
  staticpro (&Qrun);
  Qstop = intern ("stop");
  staticpro (&Qstop);
  Qsignal = intern ("signal");
  staticpro (&Qsignal);

  /* Qexit is already staticpro'd by syms_of_eval; don't staticpro it
     here again.

     Qexit = intern ("exit");
     staticpro (&Qexit); */

  Qopen = intern ("open");
  staticpro (&Qopen);
  Qclosed = intern ("closed");
  staticpro (&Qclosed);

  Qlast_nonmenu_event = intern ("last-nonmenu-event");
  staticpro (&Qlast_nonmenu_event);

  staticpro (&Vprocess_alist);

  DEFVAR_BOOL ("delete-exited-processes", &delete_exited_processes,
    "*Non-nil means delete processes immediately when they exit.\n\
nil means don't delete them until `list-processes' is run.");

  delete_exited_processes = 1;

  DEFVAR_LISP ("process-connection-type", &Vprocess_connection_type,
    "Control type of device used to communicate with subprocesses.\n\
Values are nil to use a pipe, or t or `pty' to use a pty.\n\
The value has no effect if the system has no ptys or if all ptys are busy:\n\
then a pipe is used in any case.\n\
The value takes effect when `start-process' is called.");
  Vprocess_connection_type = Qt;

  defsubr (&Sprocessp);
  defsubr (&Sget_process);
  defsubr (&Sget_buffer_process);
  defsubr (&Sdelete_process);
  defsubr (&Sprocess_status);
  defsubr (&Sprocess_exit_status);
  defsubr (&Sprocess_id);
  defsubr (&Sprocess_name);
  defsubr (&Sprocess_tty_name);
  defsubr (&Sprocess_command);
  defsubr (&Sset_process_buffer);
  defsubr (&Sprocess_buffer);
  defsubr (&Sprocess_mark);
  defsubr (&Sset_process_filter);
  defsubr (&Sprocess_filter);
  defsubr (&Sset_process_sentinel);
  defsubr (&Sprocess_sentinel);
  defsubr (&Sset_process_window_size);
  defsubr (&Sset_process_inherit_coding_system_flag);
  defsubr (&Sprocess_inherit_coding_system_flag);
  defsubr (&Sprocess_kill_without_query);
  defsubr (&Sprocess_contact);
  defsubr (&Slist_processes);
  defsubr (&Sprocess_list);
  defsubr (&Sstart_process);
#ifdef HAVE_SOCKETS
  defsubr (&Sopen_network_stream);
#endif /* HAVE_SOCKETS */
  defsubr (&Saccept_process_output);
  defsubr (&Sprocess_send_region);
  defsubr (&Sprocess_send_string);
  defsubr (&Sinterrupt_process);
  defsubr (&Skill_process);
  defsubr (&Squit_process);
  defsubr (&Sstop_process);
  defsubr (&Scontinue_process);
  defsubr (&Sprocess_running_child_p);
  defsubr (&Sprocess_send_eof);
  defsubr (&Ssignal_process);
  defsubr (&Swaiting_for_user_input_p);
/*  defsubr (&Sprocess_connection); */
  defsubr (&Sset_process_coding_system);
  defsubr (&Sprocess_coding_system);
}


#else /* not subprocesses */

#include <sys/types.h>
#include <errno.h>

#include "lisp.h"
#include "systime.h"
#include "charset.h"
#include "coding.h"
#include "termopts.h"
#include "sysselect.h"

extern int frame_garbaged;

extern EMACS_TIME timer_check ();
extern int timers_run;

/* As described above, except assuming that there are no subprocesses:

   Wait for timeout to elapse and/or keyboard input to be available.

   time_limit is:
     timeout in seconds, or
     zero for no limit, or
     -1 means gobble data immediately available but don't wait for any.

   read_kbd is a Lisp_Object:
     0 to ignore keyboard input, or
     1 to return when input is available, or
     -1 means caller will actually read the input, so don't throw to
       the quit handler.
     a cons cell, meaning wait until its car is non-nil
       (and gobble terminal input into the buffer if any arrives), or
     We know that read_kbd will never be a Lisp_Process, since
     `subprocesses' isn't defined.

   do_display != 0 means redisplay should be done to show subprocess
   output that arrives.

   Return true iff we received input from any process.  */

int
wait_reading_process_input (time_limit, microsecs, read_kbd, do_display)
     int time_limit, microsecs;
     Lisp_Object read_kbd;
     int do_display;
{
  register int nfds;
  EMACS_TIME end_time, timeout;
  SELECT_TYPE waitchannels;
  int xerrno;
  Lisp_Object *wait_for_cell = 0;

  /* If waiting for non-nil in a cell, record where.  */
  if (CONSP (read_kbd))
    {
      wait_for_cell = &XCONS (read_kbd)->car;
      XSETFASTINT (read_kbd, 0);
    }

  /* What does time_limit really mean?  */
  if (time_limit || microsecs)
    {
      EMACS_GET_TIME (end_time);
      EMACS_SET_SECS_USECS (timeout, time_limit, microsecs);
      EMACS_ADD_TIME (end_time, end_time, timeout);
    }

  /* Turn off periodic alarms (in case they are in use)
     because the select emulator uses alarms.  */
  stop_polling ();

  while (1)
    {
      int timeout_reduced_for_timers = 0;

      /* If calling from keyboard input, do not quit
	 since we want to return C-g as an input character.
	 Otherwise, do pending quit if requested.  */
      if (XINT (read_kbd) >= 0)
	QUIT;

      /* Exit now if the cell we're waiting for became non-nil.  */
      if (wait_for_cell && ! NILP (*wait_for_cell))
	break;

      /* Compute time from now till when time limit is up */
      /* Exit if already run out */
      if (time_limit == -1)
	{
	  /* -1 specified for timeout means
	     gobble output available now
	     but don't wait at all. */

	  EMACS_SET_SECS_USECS (timeout, 0, 0);
	}
      else if (time_limit || microsecs)
	{
	  EMACS_GET_TIME (timeout);
	  EMACS_SUB_TIME (timeout, end_time, timeout);
	  if (EMACS_TIME_NEG_P (timeout))
	    break;
	}
      else
	{
	  EMACS_SET_SECS_USECS (timeout, 100000, 0);
	}

      /* If our caller will not immediately handle keyboard events,
	 run timer events directly.
	 (Callers that will immediately read keyboard events
	 call timer_delay on their own.)  */
      if (! wait_for_cell)
	{
	  EMACS_TIME timer_delay;
	  int old_timers_run;

	retry:
	  old_timers_run = timers_run;
	  timer_delay = timer_check (1);
	  if (timers_run != old_timers_run && do_display)
	    {
	      redisplay_preserve_echo_area ();
	      /* We must retry, since a timer may have requeued itself
		 and that could alter the time delay.  */
	      goto retry;
	    }

	  /* If there is unread keyboard input, also return.  */
	  if (XINT (read_kbd) != 0
	      && requeued_events_pending_p ())
	    break;

	  if (! EMACS_TIME_NEG_P (timer_delay) && time_limit != -1)
	    {
	      EMACS_TIME difference;
	      EMACS_SUB_TIME (difference, timer_delay, timeout);
	      if (EMACS_TIME_NEG_P (difference))
		{
		  timeout = timer_delay;
		  timeout_reduced_for_timers = 1;
		}
	    }
	}

      /* Cause C-g and alarm signals to take immediate action,
	 and cause input available signals to zero out timeout.  */
      if (XINT (read_kbd) < 0)
	set_waiting_for_input (&timeout);

      /* Wait till there is something to do.  */

      if (! XINT (read_kbd) && wait_for_cell == 0)
	FD_ZERO (&waitchannels);
      else
	FD_SET (0, &waitchannels);

      /* If a frame has been newly mapped and needs updating,
	 reprocess its display stuff.  */
      if (frame_garbaged && do_display)
	{
	  clear_waiting_for_input ();
	  redisplay_preserve_echo_area ();
	  if (XINT (read_kbd) < 0)
	    set_waiting_for_input (&timeout);
	}

      if (XINT (read_kbd) && detect_input_pending ())
	{
	  nfds = 0;
	  FD_ZERO (&waitchannels);
	}
      else
	nfds = select (1, &waitchannels, (SELECT_TYPE *)0, (SELECT_TYPE *)0,
		       &timeout);

      xerrno = errno;

      /* Make C-g and alarm signals set flags again */
      clear_waiting_for_input ();

      /*  If we woke up due to SIGWINCH, actually change size now.  */
      do_pending_window_change ();

      if (time_limit && nfds == 0 && ! timeout_reduced_for_timers)
	/* We waited the full specified time, so return now.  */
	break;

      if (nfds == -1)
	{
	  /* If the system call was interrupted, then go around the
	     loop again.  */
	  if (xerrno == EINTR)
	    FD_ZERO (&waitchannels);
	  else
	    error ("select error: %s", strerror (xerrno));
	}
#ifdef sun
      else if (nfds > 0 && (waitchannels & 1)  && interrupt_input)
	/* System sometimes fails to deliver SIGIO.  */
	kill (getpid (), SIGIO);
#endif
#ifdef SIGIO
      if (XINT (read_kbd) && interrupt_input && (waitchannels & 1))
	kill (getpid (), SIGIO);
#endif

      /* Check for keyboard input */

      if ((XINT (read_kbd) != 0)
	  && detect_input_pending_run_timers (do_display))
	{
	  swallow_events (do_display);
	  if (detect_input_pending_run_timers (do_display))
	    break;
	}

      /* If there is unread keyboard input, also return.  */
      if (XINT (read_kbd) != 0
	  && requeued_events_pending_p ())
	break;

      /* If wait_for_cell. check for keyboard input
	 but don't run any timers.
	 ??? (It seems wrong to me to check for keyboard
	 input at all when wait_for_cell, but the code
	 has been this way since July 1994.
	 Try changing this after version 19.31.)  */
      if (wait_for_cell
	  && detect_input_pending ())
	{
	  swallow_events (do_display);
	  if (detect_input_pending ())
	    break;
	}

      /* Exit now if the cell we're waiting for became non-nil.  */
      if (wait_for_cell && ! NILP (*wait_for_cell))
	break;
    }

  start_polling ();

  return 0;
}


DEFUN ("get-buffer-process", Fget_buffer_process, Sget_buffer_process, 1, 1, 0,
  /* Don't confuse make-docfile by having two doc strings for this function.
     make-docfile does not pay attention to #if, for good reason!  */
  0)
  (name)
     register Lisp_Object name;
{
  return Qnil;
}

DEFUN ("process-inherit-coding-system-flag",
  Fprocess_inherit_coding_system_flag, Sprocess_inherit_coding_system_flag,
  1, 1, 0,
  /* Don't confuse make-docfile by having two doc strings for this function.
     make-docfile does not pay attention to #if, for good reason!  */
  0)
  (process)
     register Lisp_Object process;
{
  /* Ignore the argument and return the value of
     inherit-process-coding-system.  */
  return inherit_process_coding_system ? Qt : Qnil;
}

/* Kill all processes associated with `buffer'.
   If `buffer' is nil, kill all processes.
   Since we have no subprocesses, this does nothing.  */

void
kill_buffer_processes (buffer)
     Lisp_Object buffer;
{
}

void
init_process ()
{
}

void
syms_of_process ()
{
  defsubr (&Sget_buffer_process);
  defsubr (&Sprocess_inherit_coding_system_flag);
}


#endif /* not subprocesses */
