/* Communication subprocess for GNU Emacs acting as server.
   Copyright (C) 1986, 1987, 1992, 1994 Free Software Foundation, Inc.

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


/* The GNU Emacs edit server process is run as a subprocess of Emacs
   under control of the file lisp/server.el.
   This program accepts communication from client (program emacsclient.c)
   and passes their commands (consisting of keyboard characters)
   up to the Emacs which then executes them.  */

#define NO_SHORTNAMES
#include <signal.h>
#include <../src/config.h>
#undef read
#undef write
#undef open
#undef close
#undef signal

#if !defined (HAVE_SOCKETS) && !defined (HAVE_SYSVIPC)
#include <stdio.h>

int
main ()
{
  fprintf (stderr, "Sorry, the Emacs server is supported only on systems\n");
  fprintf (stderr, "with Berkeley sockets or System V IPC.\n");
  exit (1);
}

#else /* HAVE_SOCKETS or HAVE_SYSVIPC */

void perror_1 ();
void fatal_error ();

#if defined (HAVE_SOCKETS) && ! defined (NO_SOCKETS_IN_FILE_SYSTEM)
/* BSD code is very different from SYSV IPC code */

#include <sys/types.h>
#include <sys/file.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <stdio.h>
#include <errno.h>
#include <sys/stat.h>

#ifdef HAVE_UNISTD_H
#include <unistd.h>
#endif

extern int errno;

/* Copied from src/process.c */
#ifdef FD_SET
/* We could get this from param.h, but better not to depend on finding that.
   And better not to risk that it might define other symbols used in this
   file.  */
#ifdef FD_SETSIZE
#define MAXDESC FD_SETSIZE
#else
#define MAXDESC 64
#endif
#define SELECT_TYPE fd_set
#else /* no FD_SET */
#define MAXDESC 32
#define SELECT_TYPE int

/* Define the macros to access a single-int bitmap of descriptors.  */
#define FD_SET(n, p) (*(p) |= (1 << (n)))
#define FD_CLR(n, p) (*(p) &= ~(1 << (n)))
#define FD_ISSET(n, p) (*(p) & (1 << (n)))
#define FD_ZERO(p) (*(p) = 0)
#endif /* no FD_SET */

/* This is the file name of the socket that we made.  */

char *socket_name;

/* Name of this program.  */

char *progname;

/* Handle fatal signals.  */

/* This is the handler.  */

SIGTYPE
delete_socket (sig)
     int sig;
{
  signal (sig, SIG_DFL);
  unlink (socket_name);
  kill (getpid (), sig);
}

/* Set up to handle all the signals.  */

void
handle_signals ()
{
  signal (SIGHUP, delete_socket);
  signal (SIGINT, delete_socket);
  signal (SIGQUIT, delete_socket);
  signal (SIGILL, delete_socket);
  signal (SIGTRAP, delete_socket);
#ifdef SIGABRT
  signal (SIGABRT, delete_socket);
#endif
#ifdef SIGHWE
  signal (SIGHWE, delete_socket);
#endif
#ifdef SIGPRE
  signal (SIGPRE, delete_socket);
#endif
#ifdef SIGORE
  signal (SIGORE, delete_socket);
#endif
#ifdef SIGUME
  signal (SIGUME, delete_socket);
#endif
#ifdef SIGDLK
  signal (SIGDLK, delete_socket);
#endif
#ifdef SIGCPULIM
  signal (SIGCPULIM, delete_socket);
#endif
#ifdef SIGIOT
  /* This is missing on some systems - OS/2, for example.  */
  signal (SIGIOT, delete_socket);
#endif
#ifdef SIGEMT
  signal (SIGEMT, delete_socket);
#endif
  signal (SIGFPE, delete_socket);
#ifdef SIGBUS
  signal (SIGBUS, delete_socket);
#endif
  signal (SIGSEGV, delete_socket);
#ifdef SIGSYS
  signal (SIGSYS, delete_socket);
#endif
  signal (SIGTERM, delete_socket);
#ifdef SIGXCPU
  signal (SIGXCPU, delete_socket);
#endif
#ifdef SIGXFSZ
  signal (SIGXFSZ, delete_socket);
#endif /* SIGXFSZ */

#ifdef AIX
/* 20 is SIGCHLD, 21 is SIGTTIN, 22 is SIGTTOU.  */
  signal (SIGXCPU, delete_socket);
#ifndef _I386
  signal (SIGIOINT, delete_socket);
#endif
  signal (SIGGRANT, delete_socket);
  signal (SIGRETRACT, delete_socket);
  signal (SIGSOUND, delete_socket);
  signal (SIGMSG, delete_socket);
#endif /* AIX */
}

/* Print error message.  `s1' is printf control string, `s2' is arg for it. */
void
error (s1, s2)
     char *s1, *s2;
{
  fprintf (stderr, "%s: ", progname);
  fprintf (stderr, s1, s2);
  fprintf (stderr, "\n");
}

/* Print error message and exit.  */
void
fatal (s1, s2)
     char *s1, *s2;
{
  error (s1, s2);
  exit (1);
}

/* Like malloc but get fatal error if memory is exhausted.  */

long *
xmalloc (size)
     unsigned int size;
{
  long *result = (long *) malloc (size);
  if (result == NULL)
    fatal ("virtual memory exhausted", 0);
  return result;
}

int
main (argc, argv)
     int argc;
     char **argv;
{
  char *system_name;
  int system_name_length;
  int s, infd;
#ifdef SOCKLEN_TYPE
  SOCKLEN_TYPE fromlen;
#else
  size_t fromlen;
#endif
  struct sockaddr_un server, fromunix;
  char *homedir;
  char *str, string[BUFSIZ], code[BUFSIZ];
  FILE *infile;
  FILE **openfiles;
  int openfiles_size;
  struct stat statbuf;

#ifndef convex
  char *getenv ();
#endif

  progname = argv[0];

  openfiles_size = 20;
  openfiles = (FILE **) malloc (openfiles_size * sizeof (FILE *));
  if (openfiles == 0)
    abort ();

  /* 
   * Open up an AF_UNIX socket in this person's home directory
   */

  if ((s = socket (AF_UNIX, SOCK_STREAM, 0)) < 0)
    {
      perror_1 ("socket");
      exit (1);
    }
  server.sun_family = AF_UNIX;
#ifndef SERVER_HOME_DIR
  system_name_length = 32;

  while (1)
    {
      system_name = (char *) xmalloc (system_name_length + 1);

      /* system_name must be null-terminated string.  */
      system_name[system_name_length] = '\0';

      if (gethostname (system_name, system_name_length) == 0)
	break;

      free (system_name);
      system_name_length *= 2;
    }

  sprintf (server.sun_path, "/tmp/esrv%d-%s", geteuid (), system_name);

  if (unlink (server.sun_path) == -1 && errno != ENOENT)
    {
      perror_1 ("unlink");
      exit (1);
    }
#else  
  if ((homedir = getenv ("HOME")) == NULL)
    fatal_error ("No home directory\n");

  strcpy (server.sun_path, homedir);
  strcat (server.sun_path, "/.emacs-server-");
  gethostname (system_name, sizeof (system_name));
  strcat (server.sun_path, system_name);
  /* Delete anyone else's old server.  */
  unlink (server.sun_path);
#endif

  /* Save the socket name so we can delete it.  */
  socket_name = (char *) xmalloc (strlen (server.sun_path) + 1);
  strcpy (socket_name, server.sun_path);

  handle_signals ();

  if (bind (s, (struct sockaddr *) &server, strlen (server.sun_path) + 2) < 0)
    {
      perror_1 ("bind");
      exit (1);
    }
  /* Only this user can send commands to this Emacs.  */
  if (stat (server.sun_path, &statbuf) < 0)
    {
      perror_1 ("bind");
      exit (1);
    }

  chmod (server.sun_path, statbuf.st_mode & 0600);
  /*
   * Now, just wait for everything to come in..
   */
  if (listen (s, 5) < 0)
    {
      perror_1 ("listen");
      exit (1);
    }

  /* Disable sigpipes in case luser kills client... */
  signal (SIGPIPE, SIG_IGN);
  for (;;)
    {
      SELECT_TYPE rmask;
      FD_ZERO (&rmask);
      FD_SET (0, &rmask);
      FD_SET (s, &rmask);
      if (select (s + 1, &rmask, 0, 0, 0) < 0)
	perror_1 ("select");
      if (FD_ISSET (s, &rmask))	/* client sends list of filenames */
	{
	  fromlen = sizeof (fromunix);
	  fromunix.sun_family = AF_UNIX;
	  infd = accept (s, (struct sockaddr *) &fromunix, &fromlen);
	  if (infd < 0)
	    {
	      if (errno == EMFILE || errno == ENFILE)
		fprintf (stderr, "Error: too many clients.\n");
	      else
		perror_1 ("accept");
	      continue;
	    }

	  if (infd >= openfiles_size)
	    {
	      openfiles_size *= 2;
	      openfiles = (FILE **) realloc (openfiles,
					     openfiles_size * sizeof (FILE *));
	      if (openfiles == 0)
		abort ();
	    }

	  infile = fdopen (infd, "r+"); /* open stream */
	  if (infile == NULL)
	    {
	      fprintf (stderr, "Error: too many clients.\n");
	      write (infd, "Too many clients.\n", 18);
	      close (infd);		/* Prevent descriptor leak.. */
	      continue;
	    }
	  str = fgets (string, BUFSIZ, infile);
	  if (str == NULL)
	    {
	      perror_1 ("fgets");
	      close (infd);		/* Prevent descriptor leak.. */
	      continue;
	    }
	  openfiles[infd] = infile;
	  printf ("Client: %d %s", infd, string);
	  /* If what we read did not end in a newline,
	     it means there is more.  Keep reading from the socket
	     and outputting to Emacs, until we get the newline.  */
	  while (string[strlen (string) - 1] != '\n')
	    {
	      if (fgets (string, BUFSIZ, infile) == 0)
		break;
	      printf ("%s", string);
	    }
	  fflush (stdout);
	  fflush (infile);
	  continue;
	}
      else if (FD_ISSET (0, &rmask)) /* emacs sends codeword, fd, and string message */
	{
	  /* Read command codeword and fd */
	  clearerr (stdin);
	  scanf ("%s %d%*c", code, &infd);
	  if (ferror (stdin) || feof (stdin))
	    fatal_error ("server: error reading from standard input\n");

	  /* Transfer text from Emacs to the client, up to a newline.  */
	  infile = openfiles[infd];
	  rewind (infile);
	  while (1)
	    {
	      if (fgets (string, BUFSIZ, stdin) == 0)
		break;
	      fprintf (infile, "%s", string);
	      if (string[strlen (string) - 1] == '\n')
		break;
	    }
	  fflush (infile);

	  /* If command is close, close connection to client.  */
	  if (strncmp (code, "Close:", 6) == 0) 
	    if (infd > 2) 
	      {
		fclose (infile);
		close (infd);
	      }
	  continue;
	} 
    }
}

#else  /* This is the SYSV IPC section */

#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/msg.h>
#include <setjmp.h>
#include <errno.h>
#include <sys/utsname.h>

struct utsname system_name;

#ifndef errno
extern int errno;
#endif

jmp_buf msgenv;

SIGTYPE
msgcatch ()
{
  longjmp (msgenv, 1);
}


/* "THIS has to be fixed.  Remember, stderr may not exist...-rlk."
   Incorrect.  This program runs as an inferior of Emacs.
   Its stderr always exists--rms.  */
#include <stdio.h>

int
main ()
{
  int s, infd, fromlen, ioproc;
  key_t key;
  struct msgbuf * msgp =
    (struct msgbuf *) malloc (sizeof *msgp + BUFSIZ);
  struct msqid_ds msg_st;
  int p;
  char *homedir, *getenv ();
  char string[BUFSIZ];
  FILE *infile;

  /*
   * Create a message queue using ~/.emacs-server as the path for ftok
   */
  if ((homedir = getenv ("HOME")) == NULL)
    fatal_error ("No home directory\n");

  strcpy (string, homedir);
#ifndef HAVE_LONG_FILE_NAMES
  /* If file names are short, we can't fit the host name.  */
  strcat (string, "/.emacs-server");
#else
  strcat (string, "/.emacs-server-");
  uname (&system_name);
  strcat (string, system_name.nodename);
#endif
  creat (string, 0600);
  key = ftok (string, 1);	/* unlikely to be anyone else using it */
  s = msgget (key, 0600 | IPC_CREAT);
  if (s == -1)
    {
      perror_1 ("msgget");
      exit (1);
    }

  /* Fork so we can close connection even if parent dies */
  p = fork ();
  if (setjmp (msgenv))
    {
      msgctl (s, IPC_RMID, 0);
      if (p > 0)
	kill (p, SIGKILL);
      exit (0);
    }
  signal (SIGTERM, msgcatch);
  signal (SIGINT, msgcatch);
  signal (SIGHUP, msgcatch);
  if (p > 0)
    {
      /* This is executed in the original process that did the fork above.  */
      /* Get pid of Emacs itself.  */
      p = getppid ();
      setpgrp ();		/* Gnu kills process group on exit */
      while (1)
	{
	  /* Is Emacs still alive?  */
	  if (kill (p, 0) < 0)
	    {
	      msgctl (s, IPC_RMID, 0);
	      exit (0);
	    }
	  sleep (10);
	}
    }

  /* This is executed in the child made by forking above.
     Call it c1.  Make another process, ioproc.  */

  ioproc = fork ();
  if (ioproc == 0)
    {
      /* In process ioproc, wait for text from Emacs,
	 and send it to the process c1.
	 This way, c1 only has to wait for one source of input.  */
      while (fgets (msgp->mtext, BUFSIZ, stdin))
	{
	  msgp->mtype = 1;
	  msgsnd (s, msgp, strlen (msgp->mtext) + 1, 0);
	}
      exit (1);
    }

  /* In the process c1,
     listen for messages from clients and pass them to Emacs.  */
  while (1)
    {
      if ((fromlen = msgrcv (s, msgp, BUFSIZ - 1, 1, 0)) < 0)
        {
#ifdef EINTR
	  if (errno == EINTR)
	    continue;
#endif
	  perror_1 ("msgrcv");
	  exit (1);
        }
      else
        {
	  msgctl (s, IPC_STAT, &msg_st);

	  /* Distinguish whether the message came from a client, or from
	     ioproc.  */
	  if (msg_st.msg_lspid == ioproc)
	    {
	      char code[BUFSIZ];
	      int inproc;

	      /* Message from ioproc: tell a client we are done.  */
	      msgp->mtext[strlen (msgp->mtext)-1] = 0;
	      sscanf (msgp->mtext, "%s %d", code, &inproc);
	      msgp->mtype = inproc;
	      msgsnd (s, msgp, strlen (msgp->mtext) + 1, 0);
	      continue;
	    }

	  /* This is a request from a client: copy to stdout
	     so that Emacs will get it.  Include msg_lspid
	     so server.el can tell us where to send the reply.  */
	  strncpy (string, msgp->mtext, fromlen);
	  string[fromlen] = 0;	/* make sure */
	  /* Newline is part of string.. */
	  printf ("Client: %d %s", msg_st.msg_lspid, string);
	  fflush (stdout);
	}
    }
}

#endif /* HAVE_SYSVIPC */


/* This is like perror but puts `Error: ' at the beginning.  */

void
perror_1 (string)
     char *string;
{
  char *copy = (char *) malloc (strlen (string) + 8);
  if (copy == 0)
    fatal_error ("Virtual memory exhausted");

  strcpy (copy, "Error: ");
  strcat (copy, string);
  perror (copy);
}

void
fatal_error (string)
     char *string;
{
  fprintf (stderr, "%s", "Error: ");
  fprintf (stderr, string);
  exit (1);
}
#endif /* HAVE_SOCKETS or HAVE_SYSVIPC */
