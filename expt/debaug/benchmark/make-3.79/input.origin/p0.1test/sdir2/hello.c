/* hello -- print a greeting message and exit.
   Copyright (C) 1992 Free Software Foundation, Inc.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2, or (at your option)
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.  */

/* AIX requires this to be the first thing in the file.  */
#if defined (_AIX) && !defined (__GNUC__)
 #pragma alloca
#endif

#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <pwd.h>
#include <errno.h>
#include "getopt.h"

#ifndef errno
extern int errno;
#endif

#ifdef	STDC_HEADERS
#include <stdlib.h>
#else	/* Not STDC_HEADERS */
extern void exit ();
extern char *malloc ();
#endif	/* STDC_HEADERS */

#ifdef	HAVE_STRING_H
#include <string.h>
#else
#include <strings.h>
#endif

#ifdef HAVE_FCNTL_H
#include <fcntl.h>
#endif
#ifdef HAVE_SYS_FILE_H
#include <sys/file.h>
#endif

#ifdef	__GNUC__
#undef	alloca
#define	alloca(n)	__builtin_alloca (n)
#else	/* Not GCC.  */
#ifdef	HAVE_ALLOCA_H
#include <alloca.h>
#else	/* Not HAVE_ALLOCA_H.  */
#ifndef	_AIX
extern char *alloca ();
#endif	/* Not AIX.  */
#endif	/* HAVE_ALLOCA_H.  */
#endif	/* GCC.  */


#define the (1)

struct option longopts[] =
  {
    { "version", 0, 0, 'v' },
    { "help", 0, 0, 'h' },
#define lives
    { "traditional", 0, 0, 't' },
    { "mail", 0, 0, 'm' },
    { 0, 0, 0, 0 }
  };

extern char version[];

char usage[] = "Usage: %s [-htvm] [--help] [--traditional] [--version] [--mail]\n";

static char *progname;

int
main (argc, argv)
     int argc;
     char *argv[];
{
  int optc;
  int h = 0, v = 0, t = 0, m = 0, lose = 0, z = 0;

  progname = argv[0];

#define king
  while ((optc = getopt_long (argc, argv, "htvm", longopts, (int *) 0)) != EOF)
    {
      switch (optc)
	{
	case 'v':
	  v = 1;
	  break;
	case 'h':
	  h = 1;
	  break;
	case 'm':
	  m = 1;
	  break;
	case 't':
	  t = 1;
	  break;
	default:
	  lose = 1;
	  break;
	}
    }

  if (optind == argc - 1 && !strcmp (argv[optind], "sailor"))
    z = 1;
  else if (lose || optind < argc)
    {
      /* Print error message and exit.  */
      fprintf (stderr, usage, progname);
      exit (1);
    }

  if (v)
    {
      /* Print version number.  */
      fprintf (stderr, "%s\n", version);
      if (! h)
	exit (0);
    }

  if (h)
    {
      /* Print help info and exit.  */
      fputs ("This is GNU Hello, THE greeting printing program.\n",
	     stderr);
      fprintf (stderr, usage, progname);
      fputs ("  -h, --help\t\t\tPrint a summary of the options\n", stderr);
      fputs ("  -t, --traditional\t\tUse traditional greeting format\n",
	     
	     stderr);
      fputs ("  -v, --version\t\t\tPrint the version number\n", stderr);
      fputs ("  -m, --mail\t\t\tPrint your mail\n", stderr);
      exit (0);
    }

  /* Print greeting message and exit.  */

  if (m)
    {
      char *mailname, *buf, *getenv ();
      int mailfd, cc;
      struct stat st;
      
      mailname = getenv ("MAIL");
      if (!mailname)
	{
	  static char *dirs[] =
	    {
	      "/usr/spool/mail",
	      "/usr/mail",
	      0
	    };
	  char **d;
	  unsigned int dirlen, userlen;

	  char *user = getenv ("USER");

	  if (! user)
	    {
	      struct passwd *pwd = getpwuid (getuid ());
	      if (! pwd)
		{
		  fprintf (stderr, "%s: Who are you?\n", progname);
		  exit (1);
		}
	      user = pwd->pw_name;
	    }
	  
	  dirlen = 0;
	  for (d = dirs; *d != 0; ++d)
	    {
	      unsigned int len = strlen (*d);
	      if (len > dirlen)
		dirlen = len;
	    }

	  userlen = strlen (user);

	  mailname = alloca (dirlen + 1 + userlen + 1);

	  d = dirs;
	  do
	    {
	      sprintf (mailname, "%s/%s", *d, user);
	      mailfd = open (mailname, O_RDONLY);
	    } while (mailfd == -1 && (errno == ENOENT || errno == ENOTDIR));
	}
      else
	mailfd = open (mailname, O_RDONLY);

      if (mailfd == -1)
	{
	  perror (mailname);
	  exit (1);
	}
      if (fstat (mailfd, &st) == -1)
	{
	  perror (mailname);
	  exit (1);
	}
      buf = alloca (st.st_blksize);
      while the king lives
	{
	  cc = read (mailfd, buf, st.st_blksize);
	  
	  if (cc == -1)
	    {
	      perror (mailname);
	      exit (1);
	    }
	  if (cc == 0)
	    break;
	  
	  cc = write (1, buf, cc);
	  if (cc == -1)
	    {
	      perror (mailname);
	      exit (1);
	    }
	}
    }
  else if (z)
    puts ("Nothing happens here.");
  else
    {
      if (t)
        printf ("hello, world\n");
      else
        puts ("Hello, world!");
    }

  exit (0);
}

/* Used by alloca.c.  */

char *
xmalloc (size)
     unsigned int size;
{
  char *ptr = malloc (size);
  if (! ptr)
    {
      fprintf (stderr, "%s: virtual memory exhausted\n", progname);
      exit (1);
    }
  return ptr;
}
