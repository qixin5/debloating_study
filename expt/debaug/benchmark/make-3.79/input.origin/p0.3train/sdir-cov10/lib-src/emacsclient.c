/* Client process that communicates with GNU Emacs acting as server.
   Copyright (C) 1986, 1987, 1994 Free Software Foundation, Inc.

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


#define NO_SHORTNAMES
#include <../src/config.h>
#undef read
#undef write
#undef open
#undef close
#undef signal

#include <stdio.h>
#include <getopt.h>
#ifdef STDC_HEADERS
#include <stdlib.h>
#endif
#ifdef HAVE_UNISTD_H
#include <unistd.h>
#endif

char *getenv (), *getwd ();
char *getcwd ();

/* This is defined with -D from the compilation command,
   which extracts it from ../lisp/version.el.  */

#ifndef VERSION
#define VERSION "unspecified"
#endif

/* Name used to invoke this program.  */
char *progname;

/* Nonzero means don't wait for a response from Emacs.  --no-wait.  */
int nowait = 0;

void print_help_and_exit ();

struct option longopts[] =
{
  { "no-wait",	no_argument,	   NULL, 'n' },
  { "help",	no_argument,	   NULL, 'H' },
  { "version",	no_argument,	   NULL, 'V' },
  { 0 }
};

/* Decode the options from argv and argc.
   The global variable `optind' will say how many arguments we used up.  */

void
decode_options (argc, argv)
     int argc;
     char **argv;
{
  while (1)
    {
      int opt = getopt_long (argc, argv,
			     "VHn", longopts, 0);

      if (opt == EOF)
	break;

      switch (opt)
	{
	case 0:
	  /* If getopt returns 0, then it has already processed a
	     long-named option.  We should do nothing.  */
	  break;

	case 'n':
	  nowait = 1;
	  break;

	case 'V':
	  fprintf (stderr, "Version %s\n", VERSION);
	  exit (1);
	  break;

	case 'H':
	default:
	  print_help_and_exit ();
	}
    }
}

void
print_help_and_exit ()
{
  fprintf (stderr,
	   "Usage: %s [-n] [--no-wait] [+LINENUMBER] FILENAME\n",
	   progname);
  fprintf (stderr,
	   "Report bugs to bug-gnu-emacs@gnu.org.\n");
  exit (1);
}

/* Return a copy of NAME, inserting a &
   before each &, each space, and any initial -.
   Change spaces to underscores, too, so that the
   return value never contains a space.  */

char *
quote_file_name (name)
     char *name;
{
  char *copy = (char *) malloc (strlen (name) * 2 + 1);
  char *p, *q;

  p = name;
  q = copy;
  while (*p)
    {
      if (*p == ' ')
	{
	  *q++ = '&';
	  *q++ = '_';
	  p++;
	}
      else
	{
	  if (*p == '&' || (*p == '-' && p == name))
	    *q++ = '&';
	  *q++ = *p++;
	}
    }
  *q++ = 0;

  return copy;
}

/* Like malloc but get fatal error if memory is exhausted.  */

long *
xmalloc (size)
     unsigned int size;
{
  long *result = (long *) malloc (size);
  if (result == NULL)
  {
    perror ("malloc");
    exit (1);
  }
  return result;
}

#if !defined (HAVE_SOCKETS) && !defined (HAVE_SYSVIPC)

main (argc, argv)
     int argc;
     char **argv;
{
  fprintf (stderr, "%s: Sorry, the Emacs server is supported only\n",
	   argv[0]);
  fprintf (stderr, "on systems with Berkeley sockets or System V IPC.\n");
  exit (1);
}

#else /* HAVE_SOCKETS or HAVE_SYSVIPC */

#if defined (HAVE_SOCKETS) && ! defined (NO_SOCKETS_IN_FILE_SYSTEM)
/* BSD code is very different from SYSV IPC code */

#include <sys/types.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <sys/stat.h>
#include <errno.h>

extern char *strerror ();
extern int errno;

int
main (argc, argv)
     int argc;
     char **argv;
{
  char *system_name;
  int system_name_length;
  int s, i;
  FILE *out, *in;
  struct sockaddr_un server;
  char *homedir, *cwd, *str;
  char string[BUFSIZ];

  progname = argv[0];

  /* Process options.  */
  decode_options (argc, argv);

  if (argc - optind < 1)
    print_help_and_exit ();

  /* 
   * Open up an AF_UNIX socket in this person's home directory
   */

  if ((s = socket (AF_UNIX, SOCK_STREAM, 0)) < 0)
    {
      fprintf (stderr, "%s: ", argv[0]);
      perror ("socket");
      exit (1);
    }
  server.sun_family = AF_UNIX;
#ifndef SERVER_HOME_DIR
  {
    struct stat statbfr;
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

    if (stat (server.sun_path, &statbfr) == -1)
      {
	if (errno == ENOENT)
	  fprintf (stderr,
		   "%s: can't find socket; have you started the server?\n",
		   argv[0]);
	else
	  fprintf (stderr, "%s: can't stat %s: %s\n",
		   argv[0], server.sun_path, strerror (errno));
	exit (1);
      }
    if (statbfr.st_uid != geteuid ())
      {
	fprintf (stderr, "%s: Invalid socket owner\n", argv[0]);
	exit (1);
      }
  }
#else
  if ((homedir = getenv ("HOME")) == NULL)
    {
      fprintf (stderr, "%s: No home directory\n", argv[0]);
      exit (1);
    }
  strcpy (server.sun_path, homedir);
  strcat (server.sun_path, "/.emacs-server-");
  gethostname (system_name, sizeof (system_name));
  strcat (server.sun_path, system_name);
#endif

  if (connect (s, (struct sockaddr *) &server, strlen (server.sun_path) + 2)
      < 0)
    {
      fprintf (stderr, "%s: ", argv[0]);
      perror ("connect");
      exit (1);
    }

  /* We use the stream OUT to send our command to the server.  */
  if ((out = fdopen (s, "r+")) == NULL)
    {
      fprintf (stderr, "%s: ", argv[0]);
      perror ("fdopen");
      exit (1);
    }

  /* We use the stream IN to read the response.
     We used to use just one stream for both output and input
     on the socket, but reversing direction works nonportably:
     on some systems, the output appears as the first input;
     on other systems it does not.  */
  if ((in = fdopen (s, "r+")) == NULL)
    {
      fprintf (stderr, "%s: ", argv[0]);
      perror ("fdopen");
      exit (1);
    }

#ifdef BSD_SYSTEM
  cwd = getwd (string);
#else
  cwd = getcwd (string, sizeof string);
#endif
  if (cwd == 0)
    {
      /* getwd puts message in STRING if it fails.  */
      fprintf (stderr, "%s: %s (%s)\n", argv[0],
#ifdef BSD_SYSTEM
	       string,
#else
	       "Cannot get current working directory",
#endif
	       strerror (errno));
      exit (1);
    }

  if (nowait)
    fprintf (out, "-nowait ");

  for (i = optind; i < argc; i++)
    {
      if (*argv[i] == '+')
	{
	  char *p = argv[i] + 1;
	  while (*p >= '0' && *p <= '9') p++;
	  if (*p != 0)
	    fprintf (out, "%s/", quote_file_name (cwd));
	}
      else if (*argv[i] != '/')
	fprintf (out, "%s/", quote_file_name (cwd));

      fprintf (out, "%s ", quote_file_name (argv[i]));
    }
  fprintf (out, "\n");
  fflush (out);

  /* Maybe wait for an answer.   */
  if (nowait)
    return 0;

  printf ("Waiting for Emacs...");
  fflush (stdout);

  /* Now, wait for an answer and print any messages.  On some systems,
     the first line we read will actually be the output we just sent.
     We can't predict whether that will happen, so if it does, we
     detect it by recognizing `Client: ' at the beginning.  */
  
  while (str = fgets (string, BUFSIZ, in))
    printf ("%s", str);

  return 0;
}

#else /* This is the SYSV IPC section */

#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/msg.h>
#include <sys/utsname.h>
#include <stdio.h>
#include <errno.h>
extern int errno;

char *getwd (), *getcwd (), *getenv ();
struct utsname system_name;

main (argc, argv)
     int argc;
     char **argv;
{
  int s;
  key_t key;
  /* Size of text allocated in MSGP.  */
  int size_allocated = BUFSIZ;
  /* Amount of text used in MSGP.  */
  int used;
  struct msgbuf *msgp
    = (struct msgbuf *) malloc (sizeof (struct msgbuf) + size_allocated);
  struct msqid_ds * msg_st;
  char *homedir, buf[BUFSIZ];
  char gwdirb[BUFSIZ];
  char *cwd;
  char *temp;

  progname = argv[0];

  /* Process options.  */
  decode_options (argc, argv);

  if (argc - optind < 1)
    print_help_and_exit ();

  /*
   * Create a message queue using ~/.emacs-server as the path for ftok
   */
  if ((homedir = getenv ("HOME")) == NULL)
    {
      fprintf (stderr, "%s: No home directory\n", argv[0]);
      exit (1);
    }
  strcpy (buf, homedir);
#ifndef HAVE_LONG_FILE_NAMES
  /* If file names are short, we can't fit the host name.  */
  strcat (buf, "/.emacs-server");
#else
  strcat (buf, "/.emacs-server-");
  uname (&system_name);
  strcat (buf, system_name.nodename);
#endif
  creat (buf, 0600);
  key = ftok (buf, 1);	/* unlikely to be anyone else using it */
  s = msgget (key, 0600 | IPC_CREAT);
  if (s == -1)
    {
      fprintf (stderr, "%s: ", argv[0]);
      perror ("msgget");
      exit (1);
    }

  /* Determine working dir, so we can prefix it to all the arguments.  */
#ifdef BSD_SYSTEM
  temp = getwd (gwdirb);
#else
  temp = getcwd (gwdirb, sizeof gwdirb);
#endif

  cwd = gwdirb;
  if (temp != 0)
    {
      /* On some systems, cwd can look like `@machine/...';
	 ignore everything before the first slash in such a case.  */
      while (*cwd && *cwd != '/')
	cwd++;
      strcat (cwd, "/");
    }
  else
    {
#ifdef BSD_SYSTEM
      fprintf (stderr, "%s: %s\n", argv[0], cwd);
#else
      fprintf (stderr, "%s: Cannot get current working directory: %s\n",
	       argv[0], strerror (errno));
#endif
      exit (1);
    }

  msgp->mtext[0] = 0;
  used = 0;

  if (nowait)
    {
      strcat (msgp->mtext, "-nowait ");
      used += 8;
    }

  argc -= optind;
  argv += optind;

  while (argc)
    {
      int need_cwd = 0;
      char *modified_arg = argv[0];

      if (*modified_arg == '+')
	{
	  char *p = modified_arg + 1;
	  while (*p >= '0' && *p <= '9') p++;
	  if (*p != 0)
	    need_cwd = 1;
	}
      else if (*modified_arg != '/')
	need_cwd = 1;

      modified_arg = quote_file_name (modified_arg);

      if (need_cwd)
	/* Overestimate in case we have to quote something in CWD.  */
	used += 2 * strlen (cwd);
      used += strlen (modified_arg) + 1;
      while (used + 2 > size_allocated)
	{
	  size_allocated *= 2;
	  msgp = (struct msgbuf *) realloc (msgp,
					    (sizeof (struct msgbuf)
					     + size_allocated));
	}

      if (need_cwd)
	strcat (msgp->mtext, quote_file_name (cwd));

      strcat (msgp->mtext, modified_arg);
      strcat (msgp->mtext, " ");
      argv++; argc--;
    }
  strcat (msgp->mtext, "\n");
#ifdef HPUX /* HPUX has a bug.  */
  if (strlen (msgp->mtext) >= 512)
    {
      fprintf (stderr, "%s: args too long for msgsnd\n", progname);
      exit (1);
    }
#endif
  msgp->mtype = 1;
  if (msgsnd (s, msgp, strlen (msgp->mtext)+1, 0) < 0)
    {
      fprintf (stderr, "%s: ", progname);
      perror ("msgsnd");
      exit (1);
    }

  /* Maybe wait for an answer.   */
  if (nowait)
    return 0;

  printf ("Waiting for Emacs...");
  fflush (stdout);

  msgrcv (s, msgp, BUFSIZ, getpid (), 0);	/* wait for anything back */
  strcpy (buf, msgp->mtext);

  printf ("\n");
  if (*buf)
    printf ("%s\n", buf);
  exit (0);
}

#endif /* HAVE_SYSVIPC */

#endif /* HAVE_SOCKETS or HAVE_SYSVIPC */

#ifndef HAVE_STRERROR
char *
strerror (errnum)
     int errnum;
{
  extern char *sys_errlist[];
  extern int sys_nerr;

  if (errnum >= 0 && errnum < sys_nerr)
    return sys_errlist[errnum];
  return (char *) "Unknown error";
}

#endif /* ! HAVE_STRERROR */
