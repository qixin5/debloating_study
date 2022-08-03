/* Lisp parsing and input streams.
   Copyright (C) 1985, 86, 87, 88, 89, 93, 94, 95, 97, 1998
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


#include <config.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/file.h>
#include <errno.h>
#include "lisp.h"

#ifndef standalone
#include "buffer.h"
#include "charset.h"
#include <epaths.h>
#include "commands.h"
#include "keyboard.h"
#include "termhooks.h"
#endif

#ifdef lint
#include <sys/inode.h>
#endif /* lint */

#ifdef MSDOS
#if __DJGPP__ < 2
#include <unistd.h>	/* to get X_OK */
#endif
#include "msdos.h"
#endif

#ifdef HAVE_UNISTD_H
#include <unistd.h>
#endif

#ifndef X_OK
#define X_OK 01
#endif

#ifdef LISP_FLOAT_TYPE
#ifdef STDC_HEADERS
#include <stdlib.h>
#endif

#include <math.h>
#endif /* LISP_FLOAT_TYPE */

#ifdef HAVE_SETLOCALE
#include <locale.h>
#endif /* HAVE_SETLOCALE */

#ifndef O_RDONLY
#define O_RDONLY 0
#endif

extern int errno;

Lisp_Object Qread_char, Qget_file_char, Qstandard_input, Qcurrent_load_list;
Lisp_Object Qvariable_documentation, Vvalues, Vstandard_input, Vafter_load_alist;
Lisp_Object Qascii_character, Qload, Qload_file_name;
Lisp_Object Qbackquote, Qcomma, Qcomma_at, Qcomma_dot, Qfunction;
Lisp_Object Qinhibit_file_name_operation;

extern Lisp_Object Qevent_symbol_element_mask;
extern Lisp_Object Qfile_exists_p;

/* non-zero if inside `load' */
int load_in_progress;

/* Directory in which the sources were found.  */
Lisp_Object Vsource_directory;

/* Search path for files to be loaded. */
Lisp_Object Vload_path;

/* File name of user's init file.  */
Lisp_Object Vuser_init_file;

/* This is the user-visible association list that maps features to
   lists of defs in their load files. */
Lisp_Object Vload_history;

/* This is used to build the load history. */
Lisp_Object Vcurrent_load_list;

/* List of files that were preloaded.  */
Lisp_Object Vpreloaded_file_list;

/* Name of file actually being read by `load'.  */
Lisp_Object Vload_file_name;

/* Function to use for reading, in `load' and friends.  */
Lisp_Object Vload_read_function;

/* The association list of objects read with the #n=object form.
   Each member of the list has the form (n . object), and is used to
   look up the object for the corresponding #n# construct.
   It must be set to nil before all top-level calls to read0.  */
Lisp_Object read_objects;

/* Nonzero means load should forcibly load all dynamic doc strings.  */
static int load_force_doc_strings;

/* Nonzero means read should convert strings to unibyte.  */
static int load_convert_to_unibyte;

/* Function to use for loading an Emacs lisp source file (not
   compiled) instead of readevalloop.  */
Lisp_Object Vload_source_file_function;

/* List of descriptors now open for Fload.  */
static Lisp_Object load_descriptor_list;

/* File for get_file_char to read from.  Use by load.  */
static FILE *instream;

/* When nonzero, read conses in pure space */
static int read_pure;

/* For use within read-from-string (this reader is non-reentrant!!)  */
static int read_from_string_index;
static int read_from_string_index_byte;
static int read_from_string_limit;

/* Number of bytes left to read in the buffer character
   that `readchar' has already advanced over.  */
static int readchar_backlog;

/* This contains the last string skipped with #@.  */
static char *saved_doc_string;
/* Length of buffer allocated in saved_doc_string.  */
static int saved_doc_string_size;
/* Length of actual data in saved_doc_string.  */
static int saved_doc_string_length;
/* This is the file position that string came from.  */
static int saved_doc_string_position;

/* This contains the previous string skipped with #@.
   We copy it from saved_doc_string when a new string
   is put in saved_doc_string.  */
static char *prev_saved_doc_string;
/* Length of buffer allocated in prev_saved_doc_string.  */
static int prev_saved_doc_string_size;
/* Length of actual data in prev_saved_doc_string.  */
static int prev_saved_doc_string_length;
/* This is the file position that string came from.  */
static int prev_saved_doc_string_position;

/* Nonzero means inside a new-style backquote
   with no surrounding parentheses.
   Fread initializes this to zero, so we need not specbind it
   or worry about what happens to it when there is an error.  */
static int new_backquote_flag;

/* Handle unreading and rereading of characters.
   Write READCHAR to read a character,
   UNREAD(c) to unread c to be read again.

   These macros actually read/unread a byte code, multibyte characters
   are not handled here.  The caller should manage them if necessary.
 */

#define READCHAR readchar (readcharfun)
#define UNREAD(c) unreadchar (readcharfun, c)

static int
readchar (readcharfun)
     Lisp_Object readcharfun;
{
  Lisp_Object tem;
  register int c, mpos;

  if (BUFFERP (readcharfun))
    {
      register struct buffer *inbuffer = XBUFFER (readcharfun);

      int pt_byte = BUF_PT_BYTE (inbuffer);
      int orig_pt_byte = pt_byte;

      if (readchar_backlog > 0)
	/* We get the address of the byte just passed,
	   which is the last byte of the character.
	   The other bytes in this character are consecutive with it,
	   because the gap can't be in the middle of a character.  */
	return *(BUF_BYTE_ADDRESS (inbuffer, BUF_PT_BYTE (inbuffer) - 1)
		 - --readchar_backlog);

      if (pt_byte >= BUF_ZV_BYTE (inbuffer))
	return -1;

      readchar_backlog = -1;

      if (! NILP (inbuffer->enable_multibyte_characters))
	{
	  unsigned char workbuf[4];
	  unsigned char *str = workbuf;
	  int length;

	  /* Fetch the character code from the buffer.  */
	  unsigned char *p = BUF_BYTE_ADDRESS (inbuffer, pt_byte);
	  BUF_INC_POS (inbuffer, pt_byte);
	  c = STRING_CHAR (p, pt_byte - orig_pt_byte);

	  /* Find the byte-sequence representation of that character.  */
	  if (SINGLE_BYTE_CHAR_P (c))
	    length = 1, workbuf[0] = c;
	  else
	    length = non_ascii_char_to_string (c, workbuf, &str);

	  /* If the bytes for this character in the buffer
	     are not identical with what the character code implies,
	     read the bytes one by one from the buffer.  */
	  if (length != pt_byte - orig_pt_byte
	      || (length == 1 ? *str != *p : bcmp (str, p, length)))
	    {
	      readchar_backlog = pt_byte - orig_pt_byte;
	      c = BUF_FETCH_BYTE (inbuffer, orig_pt_byte);
	      readchar_backlog--;
	    }
	}
      else
	{
	  c = BUF_FETCH_BYTE (inbuffer, pt_byte);
	  pt_byte++;
	}
      SET_BUF_PT_BOTH (inbuffer, BUF_PT (inbuffer) + 1, pt_byte);

      return c;
    }
  if (MARKERP (readcharfun))
    {
      register struct buffer *inbuffer = XMARKER (readcharfun)->buffer;

      int bytepos = marker_byte_position (readcharfun);
      int orig_bytepos = bytepos;

      if (readchar_backlog > 0)
	/* We get the address of the byte just passed,
	   which is the last byte of the character.
	   The other bytes in this character are consecutive with it,
	   because the gap can't be in the middle of a character.  */
	return *(BUF_BYTE_ADDRESS (inbuffer, XMARKER (readcharfun)->bytepos - 1)
		 - --readchar_backlog);

      if (bytepos >= BUF_ZV_BYTE (inbuffer))
	return -1;

      readchar_backlog = -1;

      if (! NILP (inbuffer->enable_multibyte_characters))
	{
	  unsigned char workbuf[4];
	  unsigned char *str = workbuf;
	  int length;

	  /* Fetch the character code from the buffer.  */
	  unsigned char *p = BUF_BYTE_ADDRESS (inbuffer, bytepos);
	  BUF_INC_POS (inbuffer, bytepos);
	  c = STRING_CHAR (p, bytepos - orig_bytepos);

	  /* Find the byte-sequence representation of that character.  */
	  if (SINGLE_BYTE_CHAR_P (c))
	    length = 1, workbuf[0] = c;
	  else
	    length = non_ascii_char_to_string (c, workbuf, &str);

	  /* If the bytes for this character in the buffer
	     are not identical with what the character code implies,
	     read the bytes one by one from the buffer.  */
	  if (length != bytepos - orig_bytepos
	      || (length == 1 ? *str != *p : bcmp (str, p, length)))
	    {
	      readchar_backlog = bytepos - orig_bytepos;
	      c = BUF_FETCH_BYTE (inbuffer, orig_bytepos);
	      readchar_backlog--;
	    }
	}
      else
	{
	  c = BUF_FETCH_BYTE (inbuffer, bytepos);
	  bytepos++;
	}

      XMARKER (readcharfun)->bytepos = bytepos;
      XMARKER (readcharfun)->charpos++;

      return c;
    }

  if (EQ (readcharfun, Qlambda))
    return read_bytecode_char (0);

  if (EQ (readcharfun, Qget_file_char))
    {
      c = getc (instream);
#ifdef EINTR
      /* Interrupted reads have been observed while reading over the network */
      while (c == EOF && ferror (instream) && errno == EINTR)
	{
	  clearerr (instream);
	  c = getc (instream);
	}
#endif
      return c;
    }

  if (STRINGP (readcharfun))
    {
      if (read_from_string_index >= read_from_string_limit)
	c = -1;
      else if (STRING_MULTIBYTE (readcharfun))
	FETCH_STRING_CHAR_ADVANCE (c, readcharfun,
				   read_from_string_index,
				   read_from_string_index_byte);
      else
	c = XSTRING (readcharfun)->data[read_from_string_index++];

      return c;
    }

  tem = call0 (readcharfun);

  if (NILP (tem))
    return -1;
  return XINT (tem);
}

/* Unread the character C in the way appropriate for the stream READCHARFUN.
   If the stream is a user function, call it with the char as argument.  */

static void
unreadchar (readcharfun, c)
     Lisp_Object readcharfun;
     int c;
{
  if (c == -1)
    /* Don't back up the pointer if we're unreading the end-of-input mark,
       since readchar didn't advance it when we read it.  */
    ;
  else if (BUFFERP (readcharfun))
    {
      struct buffer *b = XBUFFER (readcharfun);
      int bytepos = BUF_PT_BYTE (b);

      if (readchar_backlog >= 0)
	readchar_backlog++;
      else
	{
	  BUF_PT (b)--;
	  if (! NILP (b->enable_multibyte_characters))
	    BUF_DEC_POS (b, bytepos);
	  else
	    bytepos--;

	  BUF_PT_BYTE (b) = bytepos;
	}
    }
  else if (MARKERP (readcharfun))
    {
      struct buffer *b = XMARKER (readcharfun)->buffer;
      int bytepos = XMARKER (readcharfun)->bytepos;

      if (readchar_backlog >= 0)
	readchar_backlog++;
      else
	{
	  XMARKER (readcharfun)->charpos--;
	  if (! NILP (b->enable_multibyte_characters))
	    BUF_DEC_POS (b, bytepos);
	  else
	    bytepos--;

	  XMARKER (readcharfun)->bytepos = bytepos;
	}
    }
  else if (STRINGP (readcharfun))
    {
      read_from_string_index--;
      read_from_string_index_byte
	= string_char_to_byte (readcharfun, read_from_string_index);
    }
  else if (EQ (readcharfun, Qlambda))
    read_bytecode_char (1);
  else if (EQ (readcharfun, Qget_file_char))
    ungetc (c, instream);
  else
    call1 (readcharfun, make_number (c));
}

static Lisp_Object read0 (), read1 (), read_list (), read_vector ();
static int read_multibyte ();

/* Get a character from the tty.  */

extern Lisp_Object read_char ();

/* Read input events until we get one that's acceptable for our purposes.

   If NO_SWITCH_FRAME is non-zero, switch-frame events are stashed
   until we get a character we like, and then stuffed into
   unread_switch_frame.

   If ASCII_REQUIRED is non-zero, we check function key events to see
   if the unmodified version of the symbol has a Qascii_character
   property, and use that character, if present.

   If ERROR_NONASCII is non-zero, we signal an error if the input we
   get isn't an ASCII character with modifiers.  If it's zero but
   ASCII_REQUIRED is non-zero, we just re-read until we get an ASCII
   character.

   If INPUT_METHOD is nonzero, we invoke the current input method
   if the character warrants that.  */

Lisp_Object
read_filtered_event (no_switch_frame, ascii_required, error_nonascii,
		     input_method)
     int no_switch_frame, ascii_required, error_nonascii, input_method;
{
#ifdef standalone
  return make_number (getchar ());
#else
  register Lisp_Object val, delayed_switch_frame;

  delayed_switch_frame = Qnil;

  /* Read until we get an acceptable event.  */
 retry:
  val = read_char (0, 0, 0,
		   (input_method ? Qnil : Qt),
		   0);

  if (BUFFERP (val))
    goto retry;

  /* switch-frame events are put off until after the next ASCII
     character.  This is better than signaling an error just because
     the last characters were typed to a separate minibuffer frame,
     for example.  Eventually, some code which can deal with
     switch-frame events will read it and process it.  */
  if (no_switch_frame
      && EVENT_HAS_PARAMETERS (val)
      && EQ (EVENT_HEAD (val), Qswitch_frame))
    {
      delayed_switch_frame = val;
      goto retry;
    }

  if (ascii_required)
    {
      /* Convert certain symbols to their ASCII equivalents.  */
      if (SYMBOLP (val))
	{
	  Lisp_Object tem, tem1, tem2;
	  tem = Fget (val, Qevent_symbol_element_mask);
	  if (!NILP (tem))
	    {
	      tem1 = Fget (Fcar (tem), Qascii_character);
	      /* Merge this symbol's modifier bits
		 with the ASCII equivalent of its basic code.  */
	      if (!NILP (tem1))
		XSETFASTINT (val, XINT (tem1) | XINT (Fcar (Fcdr (tem))));
	    }
	}
	  
      /* If we don't have a character now, deal with it appropriately.  */
      if (!INTEGERP (val))
	{
	  if (error_nonascii)
	    {
	      Vunread_command_events = Fcons (val, Qnil);
	      error ("Non-character input-event");
	    }
	  else
	    goto retry;
	}
    }

  if (! NILP (delayed_switch_frame))
    unread_switch_frame = delayed_switch_frame;

  return val;
#endif
}

DEFUN ("read-char", Fread_char, Sread_char, 0, 2, 0,
  "Read a character from the command input (keyboard or macro).\n\
It is returned as a number.\n\
If the user generates an event which is not a character (i.e. a mouse\n\
click or function key event), `read-char' signals an error.  As an\n\
exception, switch-frame events are put off until non-ASCII events can\n\
be read.\n\
If you want to read non-character events, or ignore them, call\n\
`read-event' or `read-char-exclusive' instead.\n\
\n\
If the optional argument PROMPT is non-nil, display that as a prompt.\n\
If the optional argument INHERIT-INPUT-METHOD is non-nil and some\n\
input method is turned on in the current buffer, that input method\n\
is used for reading a character.")
  (prompt, inherit_input_method)
     Lisp_Object prompt, inherit_input_method;
{
  if (! NILP (prompt))
    message_with_string ("%s", prompt, 0);
  return read_filtered_event (1, 1, 1, ! NILP (inherit_input_method));
}

DEFUN ("read-event", Fread_event, Sread_event, 0, 2, 0,
  "Read an event object from the input stream.\n\
If the optional argument PROMPT is non-nil, display that as a prompt.\n\
If the optional argument INHERIT-INPUT-METHOD is non-nil and some\n\
input method is turned on in the current buffer, that input method\n\
is used for reading a character.")
  (prompt, inherit_input_method)
     Lisp_Object prompt, inherit_input_method;
{
  if (! NILP (prompt))
    message_with_string ("%s", prompt, 0);
  return read_filtered_event (0, 0, 0, ! NILP (inherit_input_method));
}

DEFUN ("read-char-exclusive", Fread_char_exclusive, Sread_char_exclusive, 0, 2, 0,
  "Read a character from the command input (keyboard or macro).\n\
It is returned as a number.  Non-character events are ignored.\n\
\n\
If the optional argument PROMPT is non-nil, display that as a prompt.\n\
If the optional argument INHERIT-INPUT-METHOD is non-nil and some\n\
input method is turned on in the current buffer, that input method\n\
is used for reading a character.")
  (prompt, inherit_input_method)
     Lisp_Object prompt, inherit_input_method;
{
  if (! NILP (prompt))
    message_with_string ("%s", prompt, 0);
  return read_filtered_event (1, 1, 0, ! NILP (inherit_input_method));
}

DEFUN ("get-file-char", Fget_file_char, Sget_file_char, 0, 0, 0,
  "Don't use this yourself.")
  ()
{
  register Lisp_Object val;
  XSETINT (val, getc (instream));
  return val;
}

static void readevalloop ();
static Lisp_Object load_unwind ();
static Lisp_Object load_descriptor_unwind ();

DEFUN ("load", Fload, Sload, 1, 5, 0,
  "Execute a file of Lisp code named FILE.\n\
First try FILE with `.elc' appended, then try with `.el',\n\
 then try FILE unmodified.\n\
This function searches the directories in `load-path'.\n\
If optional second arg NOERROR is non-nil,\n\
 report no error if FILE doesn't exist.\n\
Print messages at start and end of loading unless\n\
 optional third arg NOMESSAGE is non-nil.\n\
If optional fourth arg NOSUFFIX is non-nil, don't try adding\n\
 suffixes `.elc' or `.el' to the specified name FILE.\n\
If optional fifth arg MUST-SUFFIX is non-nil, insist on\n\
 the suffix `.elc' or `.el'; don't accept just FILE unless\n\
 it ends in one of those suffixes or includes a directory name.\n\
Return t if file exists.")
  (file, noerror, nomessage, nosuffix, must_suffix)
     Lisp_Object file, noerror, nomessage, nosuffix, must_suffix;
{
  register FILE *stream;
  register int fd = -1;
  register Lisp_Object lispstream;
  int count = specpdl_ptr - specpdl;
  Lisp_Object temp;
  struct gcpro gcpro1;
  Lisp_Object found;
  /* 1 means we printed the ".el is newer" message.  */
  int newer = 0;
  /* 1 means we are loading a compiled file.  */
  int compiled = 0;
  Lisp_Object handler;
  char *fmode = "r";
#ifdef DOS_NT
  fmode = "rt";
#endif /* DOS_NT */

  CHECK_STRING (file, 0);

  /* If file name is magic, call the handler.  */
  handler = Ffind_file_name_handler (file, Qload);
  if (!NILP (handler))
    return call5 (handler, Qload, file, noerror, nomessage, nosuffix);

  /* Do this after the handler to avoid
     the need to gcpro noerror, nomessage and nosuffix.
     (Below here, we care only whether they are nil or not.)  */
  file = Fsubstitute_in_file_name (file);

  /* Avoid weird lossage with null string as arg,
     since it would try to load a directory as a Lisp file */
  if (XSTRING (file)->size > 0)
    {
      int size = STRING_BYTES (XSTRING (file));

      GCPRO1 (file);

      if (! NILP (must_suffix))
	{
	  /* Don't insist on adding a suffix if FILE already ends with one.  */
	  if (size > 3
	      && !strcmp (XSTRING (file)->data + size - 3, ".el"))
	    must_suffix = Qnil;
	  else if (size > 4
		   && !strcmp (XSTRING (file)->data + size - 4, ".elc"))
	    must_suffix = Qnil;
	  /* Don't insist on adding a suffix
	     if the argument includes a directory name.  */
	  else if (! NILP (Ffile_name_directory (file)))
	    must_suffix = Qnil;
	}

      fd = openp (Vload_path, file,
		  (!NILP (nosuffix) ? ""
		   : ! NILP (must_suffix) ? ".elc:.el"
		   : ".elc:.el:"),
		  &found, 0);
      UNGCPRO;
    }

  if (fd < 0)
    {
      if (NILP (noerror))
	while (1)
	  Fsignal (Qfile_error, Fcons (build_string ("Cannot open load file"),
				       Fcons (file, Qnil)));
      else
	return Qnil;
    }

  if (EQ (Qt, Vuser_init_file))
    Vuser_init_file = found;

  /* If FD is 0, that means openp found a magic file.  */
  if (fd == 0)
    {
      if (NILP (Fequal (found, file)))
	/* If FOUND is a different file name from FILE,
	   find its handler even if we have already inhibited
	   the `load' operation on FILE.  */
	handler = Ffind_file_name_handler (found, Qt);
      else
	handler = Ffind_file_name_handler (found, Qload);
      if (! NILP (handler))
	return call5 (handler, Qload, found, noerror, nomessage, Qt);
    }

  /* Load .elc files directly, but not when they are
     remote and have no handler!  */
  if (!bcmp (&(XSTRING (found)->data[STRING_BYTES (XSTRING (found)) - 4]),
	     ".elc", 4)
      && fd != 0)
    {
      struct stat s1, s2;
      int result;

      compiled = 1;

#ifdef DOS_NT
      fmode = "rb";
#endif /* DOS_NT */
      stat ((char *)XSTRING (found)->data, &s1);
      XSTRING (found)->data[STRING_BYTES (XSTRING (found)) - 1] = 0;
      result = stat ((char *)XSTRING (found)->data, &s2);
      if (result >= 0 && (unsigned) s1.st_mtime < (unsigned) s2.st_mtime)
	{
	  /* Make the progress messages mention that source is newer.  */
	  newer = 1;

	  /* If we won't print another message, mention this anyway.  */
	  if (! NILP (nomessage))
	    message_with_string ("Source file `%s' newer than byte-compiled file",
				 found, 1);
	}
      XSTRING (found)->data[STRING_BYTES (XSTRING (found)) - 1] = 'c';
    }
  else
    {
      /* We are loading a source file (*.el).  */
      if (!NILP (Vload_source_file_function))
	{
	  if (fd != 0)
	    close (fd);
	  return call4 (Vload_source_file_function, found, file,
			NILP (noerror) ? Qnil : Qt,
			NILP (nomessage) ? Qnil : Qt);
	}
    }

#ifdef WINDOWSNT
  close (fd);
  stream = fopen ((char *) XSTRING (found)->data, fmode);
#else  /* not WINDOWSNT */
  stream = fdopen (fd, fmode);
#endif /* not WINDOWSNT */
  if (stream == 0)
    {
      close (fd);
      error ("Failure to create stdio stream for %s", XSTRING (file)->data);
    }

  if (! NILP (Vpurify_flag))
    Vpreloaded_file_list = Fcons (file, Vpreloaded_file_list);

  if (NILP (nomessage))
    {
      if (!compiled)
	message_with_string ("Loading %s (source)...", file, 1);
      else if (newer)
	message_with_string ("Loading %s (compiled; note, source file is newer)...",
		 file, 1);
      else /* The typical case; compiled file newer than source file.  */
	message_with_string ("Loading %s...", file, 1);
    }

  GCPRO1 (file);
  lispstream = Fcons (Qnil, Qnil);
  XSETFASTINT (XCONS (lispstream)->car, (EMACS_UINT)stream >> 16);
  XSETFASTINT (XCONS (lispstream)->cdr, (EMACS_UINT)stream & 0xffff);
  record_unwind_protect (load_unwind, lispstream);
  record_unwind_protect (load_descriptor_unwind, load_descriptor_list);
  specbind (Qload_file_name, found);
  specbind (Qinhibit_file_name_operation, Qnil);
  load_descriptor_list
    = Fcons (make_number (fileno (stream)), load_descriptor_list);
  load_in_progress++;
  readevalloop (Qget_file_char, stream, file, Feval, 0, Qnil, Qnil);
  unbind_to (count, Qnil);

  /* Run any load-hooks for this file.  */
  temp = Fassoc (file, Vafter_load_alist);
  if (!NILP (temp))
    Fprogn (Fcdr (temp));
  UNGCPRO;

  if (saved_doc_string)
    free (saved_doc_string);
  saved_doc_string = 0;
  saved_doc_string_size = 0;

  if (prev_saved_doc_string)
    free (prev_saved_doc_string);
  prev_saved_doc_string = 0;
  prev_saved_doc_string_size = 0;

  if (!noninteractive && NILP (nomessage))
    {
      if (!compiled)
	message_with_string ("Loading %s (source)...done", file, 1);
      else if (newer)
	message_with_string ("Loading %s (compiled; note, source file is newer)...done",
		 file, 1);
      else /* The typical case; compiled file newer than source file.  */
	message_with_string ("Loading %s...done", file, 1);
    }
  return Qt;
}

static Lisp_Object
load_unwind (stream)  /* used as unwind-protect function in load */
     Lisp_Object stream;
{
  fclose ((FILE *) (XFASTINT (XCONS (stream)->car) << 16
		    | XFASTINT (XCONS (stream)->cdr)));
  if (--load_in_progress < 0) load_in_progress = 0;
  return Qnil;
}

static Lisp_Object
load_descriptor_unwind (oldlist)
     Lisp_Object oldlist;
{
  load_descriptor_list = oldlist;
  return Qnil;
}

/* Close all descriptors in use for Floads.
   This is used when starting a subprocess.  */

void
close_load_descs ()
{
#ifndef WINDOWSNT
  Lisp_Object tail;
  for (tail = load_descriptor_list; !NILP (tail); tail = XCONS (tail)->cdr)
    close (XFASTINT (XCONS (tail)->car));
#endif
}

static int
complete_filename_p (pathname)
     Lisp_Object pathname;
{
  register unsigned char *s = XSTRING (pathname)->data;
  return (IS_DIRECTORY_SEP (s[0])
	  || (XSTRING (pathname)->size > 2
	      && IS_DEVICE_SEP (s[1]) && IS_DIRECTORY_SEP (s[2]))
#ifdef ALTOS
	  || *s == '@'
#endif
#ifdef VMS
	  || index (s, ':')
#endif /* VMS */
	  );
}

/* Search for a file whose name is STR, looking in directories
   in the Lisp list PATH, and trying suffixes from SUFFIX.
   SUFFIX is a string containing possible suffixes separated by colons.
   On success, returns a file descriptor.  On failure, returns -1.

   EXEC_ONLY nonzero means don't open the files,
   just look for one that is executable.  In this case,
   returns 1 on success.

   If STOREPTR is nonzero, it points to a slot where the name of
   the file actually found should be stored as a Lisp string.
   nil is stored there on failure.

   If the file we find is remote, return 0
   but store the found remote file name in *STOREPTR.
   We do not check for remote files if EXEC_ONLY is nonzero.  */

int
openp (path, str, suffix, storeptr, exec_only)
     Lisp_Object path, str;
     char *suffix;
     Lisp_Object *storeptr;
     int exec_only;
{
  register int fd;
  int fn_size = 100;
  char buf[100];
  register char *fn = buf;
  int absolute = 0;
  int want_size;
  Lisp_Object filename;
  struct stat st;
  struct gcpro gcpro1;

  GCPRO1 (str);
  if (storeptr)
    *storeptr = Qnil;

  if (complete_filename_p (str))
    absolute = 1;

  for (; !NILP (path); path = Fcdr (path))
    {
      char *nsuffix;

      filename = Fexpand_file_name (str, Fcar (path));
      if (!complete_filename_p (filename))
	/* If there are non-absolute elts in PATH (eg ".") */
	/* Of course, this could conceivably lose if luser sets
	   default-directory to be something non-absolute... */
	{
	  filename = Fexpand_file_name (filename, current_buffer->directory);
	  if (!complete_filename_p (filename))
	    /* Give up on this path element! */
	    continue;
	}

      /* Calculate maximum size of any filename made from
	 this path element/specified file name and any possible suffix.  */
      want_size = strlen (suffix) + STRING_BYTES (XSTRING (filename)) + 1;
      if (fn_size < want_size)
	fn = (char *) alloca (fn_size = 100 + want_size);

      nsuffix = suffix;

      /* Loop over suffixes.  */
      while (1)
	{
	  char *esuffix = (char *) index (nsuffix, ':');
	  int lsuffix = esuffix ? esuffix - nsuffix : strlen (nsuffix);
	  Lisp_Object handler;

	  /* Concatenate path element/specified name with the suffix.
	     If the directory starts with /:, remove that.  */
	  if (XSTRING (filename)->size > 2
	      && XSTRING (filename)->data[0] == '/'
	      && XSTRING (filename)->data[1] == ':')
	    {
	      strncpy (fn, XSTRING (filename)->data + 2,
		       STRING_BYTES (XSTRING (filename)) - 2);
	      fn[STRING_BYTES (XSTRING (filename)) - 2] = 0;
	    }
	  else
	    {
	      strncpy (fn, XSTRING (filename)->data,
		       STRING_BYTES (XSTRING (filename)));
	      fn[STRING_BYTES (XSTRING (filename))] = 0;
	    }

	  if (lsuffix != 0)  /* Bug happens on CCI if lsuffix is 0.  */
	    strncat (fn, nsuffix, lsuffix);

	  /* Check that the file exists and is not a directory.  */
	  if (absolute)
	    handler = Qnil;
	  else
	    handler = Ffind_file_name_handler (filename, Qfile_exists_p);
	  if (! NILP (handler) && ! exec_only)
	    {
	      Lisp_Object string;
	      int exists;

	      string = build_string (fn);
	      exists = ! NILP (exec_only ? Ffile_executable_p (string)
			       : Ffile_readable_p (string));
	      if (exists
		  && ! NILP (Ffile_directory_p (build_string (fn))))
		exists = 0;

	      if (exists)
		{
		  /* We succeeded; return this descriptor and filename.  */
		  if (storeptr)
		    *storeptr = build_string (fn);
		  UNGCPRO;
		  return 0;
		}
	    }
	  else
	    {
	      int exists = (stat (fn, &st) >= 0
			    && (st.st_mode & S_IFMT) != S_IFDIR);
	      if (exists)
		{
		  /* Check that we can access or open it.  */
		  if (exec_only)
		    fd = (access (fn, X_OK) == 0) ? 1 : -1;
		  else
		    fd = open (fn, O_RDONLY, 0);

		  if (fd >= 0)
		    {
		      /* We succeeded; return this descriptor and filename.  */
		      if (storeptr)
			*storeptr = build_string (fn);
		      UNGCPRO;
		      return fd;
		    }
		}
	    }

	  /* Advance to next suffix.  */
	  if (esuffix == 0)
	    break;
	  nsuffix += lsuffix + 1;
	}
      if (absolute)
	break;
    }

  UNGCPRO;
  return -1;
}


/* Merge the list we've accumulated of globals from the current input source
   into the load_history variable.  The details depend on whether
   the source has an associated file name or not. */

static void
build_load_history (stream, source)
     FILE *stream;
     Lisp_Object source;
{
  register Lisp_Object tail, prev, newelt;
  register Lisp_Object tem, tem2;
  register int foundit, loading;

  loading = stream || !NARROWED;

  tail = Vload_history;
  prev = Qnil;
  foundit = 0;
  while (!NILP (tail))
    {
      tem = Fcar (tail);

      /* Find the feature's previous assoc list... */
      if (!NILP (Fequal (source, Fcar (tem))))
	{
	  foundit = 1;

	  /*  If we're loading, remove it. */
	  if (loading)
	    {	  
	      if (NILP (prev))
		Vload_history = Fcdr (tail);
	      else
		Fsetcdr (prev, Fcdr (tail));
	    }

	  /*  Otherwise, cons on new symbols that are not already members.  */
	  else
	    {
	      tem2 = Vcurrent_load_list;

	      while (CONSP (tem2))
		{
		  newelt = Fcar (tem2);

		  if (NILP (Fmemq (newelt, tem)))
		    Fsetcar (tail, Fcons (Fcar (tem),
					  Fcons (newelt, Fcdr (tem))));

		  tem2 = Fcdr (tem2);
		  QUIT;
		}
	    }
	}
      else
	prev = tail;
      tail = Fcdr (tail);
      QUIT;
    }

  /* If we're loading, cons the new assoc onto the front of load-history,
     the most-recently-loaded position.  Also do this if we didn't find
     an existing member for the current source.  */
  if (loading || !foundit)
    Vload_history = Fcons (Fnreverse (Vcurrent_load_list),
			   Vload_history);
}

Lisp_Object
unreadpure ()	/* Used as unwind-protect function in readevalloop */
{
  read_pure = 0;
  return Qnil;
}

static Lisp_Object
readevalloop_1 (old)
     Lisp_Object old;
{
  load_convert_to_unibyte = ! NILP (old);
  return Qnil;
}

/* UNIBYTE specifies how to set load_convert_to_unibyte
   for this invocation.
   READFUN, if non-nil, is used instead of `read'.  */

static void
readevalloop (readcharfun, stream, sourcename, evalfun, printflag, unibyte, readfun)
     Lisp_Object readcharfun;
     FILE *stream;
     Lisp_Object sourcename;
     Lisp_Object (*evalfun) ();
     int printflag;
     Lisp_Object unibyte, readfun;
{
  register int c;
  register Lisp_Object val;
  int count = specpdl_ptr - specpdl;
  struct gcpro gcpro1;
  struct buffer *b = 0;

  if (BUFFERP (readcharfun))
    b = XBUFFER (readcharfun);
  else if (MARKERP (readcharfun))
    b = XMARKER (readcharfun)->buffer;

  specbind (Qstandard_input, readcharfun);
  specbind (Qcurrent_load_list, Qnil);
  record_unwind_protect (readevalloop_1, load_convert_to_unibyte ? Qt : Qnil);
  load_convert_to_unibyte = !NILP (unibyte);

  readchar_backlog = -1;

  GCPRO1 (sourcename);

  LOADHIST_ATTACH (sourcename);

  while (1)
    {
      if (b != 0 && NILP (b->name))
	error ("Reading from killed buffer");

      instream = stream;
      c = READCHAR;
      if (c == ';')
	{
	  while ((c = READCHAR) != '\n' && c != -1);
	  continue;
	}
      if (c < 0) break;

      /* Ignore whitespace here, so we can detect eof.  */
      if (c == ' ' || c == '\t' || c == '\n' || c == '\f' || c == '\r')
	continue;

      if (!NILP (Vpurify_flag) && c == '(')
	{
	  int count1 = specpdl_ptr - specpdl;
	  record_unwind_protect (unreadpure, Qnil);
	  val = read_list (-1, readcharfun);
	  unbind_to (count1, Qnil);
	}
      else
	{
	  UNREAD (c);
	  read_objects = Qnil;
	  if (! NILP (readfun))
	    val = call1 (readfun, readcharfun);
	  else if (! NILP (Vload_read_function))
	    val = call1 (Vload_read_function, readcharfun);
	  else
	    val = read0 (readcharfun);
	}

      val = (*evalfun) (val);
      if (printflag)
	{
	  Vvalues = Fcons (val, Vvalues);
	  if (EQ (Vstandard_output, Qt))
	    Fprin1 (val, Qnil);
	  else
	    Fprint (val, Qnil);
	}
    }

  build_load_history (stream, sourcename);
  UNGCPRO;

  unbind_to (count, Qnil);
}

#ifndef standalone

DEFUN ("eval-buffer", Feval_buffer, Seval_buffer, 0, 4, "",
  "Execute the current buffer as Lisp code.\n\
Programs can pass two arguments, BUFFER and PRINTFLAG.\n\
BUFFER is the buffer to evaluate (nil means use current buffer).\n\
PRINTFLAG controls printing of output:\n\
nil means discard it; anything else is stream for print.\n\
\n\
If the optional third argument FILENAME is non-nil,\n\
it specifies the file name to use for `load-history'.\n\
\n\
This function preserves the position of point.")
  (buffer, printflag, filename, unibyte)
     Lisp_Object buffer, printflag, filename, unibyte;
{
  int count = specpdl_ptr - specpdl;
  Lisp_Object tem, buf;

  if (NILP (buffer))
    buf = Fcurrent_buffer ();
  else
    buf = Fget_buffer (buffer);
  if (NILP (buf))
    error ("No such buffer");

  if (NILP (printflag))
    tem = Qsymbolp;
  else
    tem = printflag;

  if (NILP (filename))
    filename = XBUFFER (buf)->filename;

  specbind (Qstandard_output, tem);
  record_unwind_protect (save_excursion_restore, save_excursion_save ());
  BUF_SET_PT (XBUFFER (buf), BUF_BEGV (XBUFFER (buf)));
  readevalloop (buf, 0, filename, Feval, !NILP (printflag), unibyte, Qnil);
  unbind_to (count, Qnil);

  return Qnil;
}

#if 0
XDEFUN ("eval-current-buffer", Feval_current_buffer, Seval_current_buffer, 0, 1, "",
  "Execute the current buffer as Lisp code.\n\
Programs can pass argument PRINTFLAG which controls printing of output:\n\
nil means discard it; anything else is stream for print.\n\
\n\
If there is no error, point does not move.  If there is an error,\n\
point remains at the end of the last character read from the buffer.")
  (printflag)
     Lisp_Object printflag;
{
  int count = specpdl_ptr - specpdl;
  Lisp_Object tem, cbuf;

  cbuf = Fcurrent_buffer ()

  if (NILP (printflag))
    tem = Qsymbolp;
  else
    tem = printflag;
  specbind (Qstandard_output, tem);
  record_unwind_protect (save_excursion_restore, save_excursion_save ());
  SET_PT (BEGV);
  readevalloop (cbuf, 0, XBUFFER (cbuf)->filename, Feval,
		!NILP (printflag), Qnil, Qnil);
  return unbind_to (count, Qnil);
}
#endif

DEFUN ("eval-region", Feval_region, Seval_region, 2, 4, "r",
  "Execute the region as Lisp code.\n\
When called from programs, expects two arguments,\n\
giving starting and ending indices in the current buffer\n\
of the text to be executed.\n\
Programs can pass third argument PRINTFLAG which controls output:\n\
nil means discard it; anything else is stream for printing it.\n\
Also the fourth argument READ-FUNCTION, if non-nil, is used\n\
instead of `read' to read each expression.  It gets one argument\n\
which is the input stream for reading characters.\n\
\n\
This function does not move point.")
  (start, end, printflag, read_function)
     Lisp_Object start, end, printflag, read_function;
{
  int count = specpdl_ptr - specpdl;
  Lisp_Object tem, cbuf;

  cbuf = Fcurrent_buffer ();

  if (NILP (printflag))
    tem = Qsymbolp;
  else
    tem = printflag;
  specbind (Qstandard_output, tem);

  if (NILP (printflag))
    record_unwind_protect (save_excursion_restore, save_excursion_save ());
  record_unwind_protect (save_restriction_restore, save_restriction_save ());

  /* This both uses start and checks its type.  */
  Fgoto_char (start);
  Fnarrow_to_region (make_number (BEGV), end);
  readevalloop (cbuf, 0, XBUFFER (cbuf)->filename, Feval,
		!NILP (printflag), Qnil, read_function);

  return unbind_to (count, Qnil);
}

#endif /* standalone */

DEFUN ("read", Fread, Sread, 0, 1, 0,
  "Read one Lisp expression as text from STREAM, return as Lisp object.\n\
If STREAM is nil, use the value of `standard-input' (which see).\n\
STREAM or the value of `standard-input' may be:\n\
 a buffer (read from point and advance it)\n\
 a marker (read from where it points and advance it)\n\
 a function (call it with no arguments for each character,\n\
     call it with a char as argument to push a char back)\n\
 a string (takes text from string, starting at the beginning)\n\
 t (read text line using minibuffer and use it).")
  (stream)
     Lisp_Object stream;
{
  extern Lisp_Object Fread_minibuffer ();

  if (NILP (stream))
    stream = Vstandard_input;
  if (EQ (stream, Qt))
    stream = Qread_char;

  readchar_backlog = -1;
  new_backquote_flag = 0;
  read_objects = Qnil;

#ifndef standalone
  if (EQ (stream, Qread_char))
    return Fread_minibuffer (build_string ("Lisp expression: "), Qnil);
#endif

  if (STRINGP (stream))
    return Fcar (Fread_from_string (stream, Qnil, Qnil));

  return read0 (stream);
}

DEFUN ("read-from-string", Fread_from_string, Sread_from_string, 1, 3, 0,
  "Read one Lisp expression which is represented as text by STRING.\n\
Returns a cons: (OBJECT-READ . FINAL-STRING-INDEX).\n\
START and END optionally delimit a substring of STRING from which to read;\n\
 they default to 0 and (length STRING) respectively.")
  (string, start, end)
     Lisp_Object string, start, end;
{
  int startval, endval;
  Lisp_Object tem;

  CHECK_STRING (string,0);

  if (NILP (end))
    endval = XSTRING (string)->size;
  else
    {
      CHECK_NUMBER (end, 2);
      endval = XINT (end);
      if (endval < 0 || endval > XSTRING (string)->size)
	args_out_of_range (string, end);
    }

  if (NILP (start))
    startval = 0;
  else
    {
      CHECK_NUMBER (start, 1);
      startval = XINT (start);
      if (startval < 0 || startval > endval)
	args_out_of_range (string, start);
    }

  read_from_string_index = startval;
  read_from_string_index_byte = string_char_to_byte (string, startval);
  read_from_string_limit = endval;

  new_backquote_flag = 0;
  read_objects = Qnil;

  tem = read0 (string);
  return Fcons (tem, make_number (read_from_string_index));
}

/* Use this for recursive reads, in contexts where internal tokens
   are not allowed. */

static Lisp_Object
read0 (readcharfun)
     Lisp_Object readcharfun;
{
  register Lisp_Object val;
  int c;

  val = read1 (readcharfun, &c, 0);
  if (c)
    Fsignal (Qinvalid_read_syntax, Fcons (Fmake_string (make_number (1),
							make_number (c)),
					  Qnil));

  return val;
}

static int read_buffer_size;
static char *read_buffer;

/* Read multibyte form and return it as a character.  C is a first
   byte of multibyte form, and rest of them are read from
   READCHARFUN.  */

static int
read_multibyte (c, readcharfun)
     register int c;
     Lisp_Object readcharfun;
{
  /* We need the actual character code of this multibyte
     characters.  */
  unsigned char str[MAX_LENGTH_OF_MULTI_BYTE_FORM];
  int len = 0;

  str[len++] = c;
  while ((c = READCHAR) >= 0xA0
	 && len < MAX_LENGTH_OF_MULTI_BYTE_FORM)
    str[len++] = c;
  UNREAD (c);
  return STRING_CHAR (str, len);
}

/* Read a \-escape sequence, assuming we already read the `\'.  */

static int
read_escape (readcharfun, stringp)
     Lisp_Object readcharfun;
     int stringp;
{
  register int c = READCHAR;
  switch (c)
    {
    case -1:
      error ("End of file");

    case 'a':
      return '\007';
    case 'b':
      return '\b';
    case 'd':
      return 0177;
    case 'e':
      return 033;
    case 'f':
      return '\f';
    case 'n':
      return '\n';
    case 'r':
      return '\r';
    case 't':
      return '\t';
    case 'v':
      return '\v';
    case '\n':
      return -1;
    case ' ':
      if (stringp)
	return -1;
      return ' ';

    case 'M':
      c = READCHAR;
      if (c != '-')
	error ("Invalid escape character syntax");
      c = READCHAR;
      if (c == '\\')
	c = read_escape (readcharfun, 0);
      return c | meta_modifier;

    case 'S':
      c = READCHAR;
      if (c != '-')
	error ("Invalid escape character syntax");
      c = READCHAR;
      if (c == '\\')
	c = read_escape (readcharfun, 0);
      return c | shift_modifier;

    case 'H':
      c = READCHAR;
      if (c != '-')
	error ("Invalid escape character syntax");
      c = READCHAR;
      if (c == '\\')
	c = read_escape (readcharfun, 0);
      return c | hyper_modifier;

    case 'A':
      c = READCHAR;
      if (c != '-')
	error ("Invalid escape character syntax");
      c = READCHAR;
      if (c == '\\')
	c = read_escape (readcharfun, 0);
      return c | alt_modifier;

    case 's':
      c = READCHAR;
      if (c != '-')
	error ("Invalid escape character syntax");
      c = READCHAR;
      if (c == '\\')
	c = read_escape (readcharfun, 0);
      return c | super_modifier;

    case 'C':
      c = READCHAR;
      if (c != '-')
	error ("Invalid escape character syntax");
    case '^':
      c = READCHAR;
      if (c == '\\')
	c = read_escape (readcharfun, 0);
      if ((c & 0177) == '?')
	return 0177 | c;
      /* ASCII control chars are made from letters (both cases),
	 as well as the non-letters within 0100...0137.  */
      else if ((c & 0137) >= 0101 && (c & 0137) <= 0132)
	return (c & (037 | ~0177));
      else if ((c & 0177) >= 0100 && (c & 0177) <= 0137)
	return (c & (037 | ~0177));
      else
	return c | ctrl_modifier;

    case '0':
    case '1':
    case '2':
    case '3':
    case '4':
    case '5':
    case '6':
    case '7':
      /* An octal escape, as in ANSI C.  */
      {
	register int i = c - '0';
	register int count = 0;
	while (++count < 3)
	  {
	    if ((c = READCHAR) >= '0' && c <= '7')
	      {
		i *= 8;
		i += c - '0';
	      }
	    else
	      {
		UNREAD (c);
		break;
	      }
	  }
	return i;
      }

    case 'x':
      /* A hex escape, as in ANSI C.  */
      {
	int i = 0;
	while (1)
	  {
	    c = READCHAR;
	    if (c >= '0' && c <= '9')
	      {
		i *= 16;
		i += c - '0';
	      }
	    else if ((c >= 'a' && c <= 'f')
		     || (c >= 'A' && c <= 'F'))
	      {
		i *= 16;
		if (c >= 'a' && c <= 'f')
		  i += c - 'a' + 10;
		else
		  i += c - 'A' + 10;
	      }
	    else
	      {
		UNREAD (c);
		break;
	      }
	  }
	return i;
      }

    default:
      if (BASE_LEADING_CODE_P (c))
	c = read_multibyte (c, readcharfun);
      return c;
    }
}

/* If the next token is ')' or ']' or '.', we store that character
   in *PCH and the return value is not interesting.  Else, we store
   zero in *PCH and we read and return one lisp object.

   FIRST_IN_LIST is nonzero if this is the first element of a list.  */

static Lisp_Object
read1 (readcharfun, pch, first_in_list)
     register Lisp_Object readcharfun;
     int *pch;
     int first_in_list;
{
  register int c;
  int uninterned_symbol = 0;

  *pch = 0;

 retry:

  c = READCHAR;
  if (c < 0) return Fsignal (Qend_of_file, Qnil);

  switch (c)
    {
    case '(':
      return read_list (0, readcharfun);

    case '[':
      return read_vector (readcharfun, 0);

    case ')':
    case ']':
      {
	*pch = c;
	return Qnil;
      }

    case '#':
      c = READCHAR;
      if (c == '^')
	{
	  c = READCHAR;
	  if (c == '[')
	    {
	      Lisp_Object tmp;
	      tmp = read_vector (readcharfun, 0);
	      if (XVECTOR (tmp)->size < CHAR_TABLE_STANDARD_SLOTS
		  || XVECTOR (tmp)->size > CHAR_TABLE_STANDARD_SLOTS + 10)
		error ("Invalid size char-table");
	      XSETCHAR_TABLE (tmp, XCHAR_TABLE (tmp));
	      XCHAR_TABLE (tmp)->top = Qt;
	      return tmp;
	    }
	  else if (c == '^')
	    {
	      c = READCHAR;
	      if (c == '[')
		{
		  Lisp_Object tmp;
		  tmp = read_vector (readcharfun, 0);
		  if (XVECTOR (tmp)->size != SUB_CHAR_TABLE_STANDARD_SLOTS)
		    error ("Invalid size char-table");
		  XSETCHAR_TABLE (tmp, XCHAR_TABLE (tmp));
		  XCHAR_TABLE (tmp)->top = Qnil;
		  return tmp;
		}
	      Fsignal (Qinvalid_read_syntax,
		       Fcons (make_string ("#^^", 3), Qnil));
	    }
	  Fsignal (Qinvalid_read_syntax, Fcons (make_string ("#^", 2), Qnil));
	}
      if (c == '&')
	{
	  Lisp_Object length;
	  length = read1 (readcharfun, pch, first_in_list);
	  c = READCHAR;
	  if (c == '"')
	    {
	      Lisp_Object tmp, val;
	      int size_in_chars = ((XFASTINT (length) + BITS_PER_CHAR - 1)
				   / BITS_PER_CHAR);

	      UNREAD (c);
	      tmp = read1 (readcharfun, pch, first_in_list);
	      if (size_in_chars != XSTRING (tmp)->size
		  /* We used to print 1 char too many
		     when the number of bits was a multiple of 8.
		     Accept such input in case it came from an old version.  */
		  && ! (XFASTINT (length)
			== (XSTRING (tmp)->size - 1) * BITS_PER_CHAR))
		Fsignal (Qinvalid_read_syntax,
			 Fcons (make_string ("#&...", 5), Qnil));
		
	      val = Fmake_bool_vector (length, Qnil);
	      bcopy (XSTRING (tmp)->data, XBOOL_VECTOR (val)->data,
		     size_in_chars);
	      /* Clear the extraneous bits in the last byte.  */
	      if (XINT (length) != size_in_chars * BITS_PER_CHAR)
		XBOOL_VECTOR (val)->data[size_in_chars - 1]
		  &= (1 << (XINT (length) % BITS_PER_CHAR)) - 1;
	      return val;
	    }
	  Fsignal (Qinvalid_read_syntax, Fcons (make_string ("#&...", 5),
						Qnil));
	}
      if (c == '[')
	{
	  /* Accept compiled functions at read-time so that we don't have to
	     build them using function calls.  */
	  Lisp_Object tmp;
	  tmp = read_vector (readcharfun, 1);
	  return Fmake_byte_code (XVECTOR (tmp)->size,
				  XVECTOR (tmp)->contents);
	}
#ifdef USE_TEXT_PROPERTIES
      if (c == '(')
	{
	  Lisp_Object tmp;
	  struct gcpro gcpro1;
	  int ch;

	  /* Read the string itself.  */
	  tmp = read1 (readcharfun, &ch, 0);
	  if (ch != 0 || !STRINGP (tmp))
	    Fsignal (Qinvalid_read_syntax, Fcons (make_string ("#", 1), Qnil));
	  GCPRO1 (tmp);
	  /* Read the intervals and their properties.  */
	  while (1)
	    {
	      Lisp_Object beg, end, plist;

	      beg = read1 (readcharfun, &ch, 0);
	      if (ch == ')')
		break;
	      if (ch == 0)
		end = read1 (readcharfun, &ch, 0);
	      if (ch == 0)
		plist = read1 (readcharfun, &ch, 0);
	      if (ch)
		Fsignal (Qinvalid_read_syntax,
			 Fcons (build_string ("invalid string property list"),
				Qnil));
	      Fset_text_properties (beg, end, plist, tmp);
	    }
	  UNGCPRO;
	  return tmp;
	}
#endif
      /* #@NUMBER is used to skip NUMBER following characters.
	 That's used in .elc files to skip over doc strings
	 and function definitions.  */
      if (c == '@')
	{
	  int i, nskip = 0;

	  /* Read a decimal integer.  */
	  while ((c = READCHAR) >= 0
		 && c >= '0' && c <= '9')
	    {
	      nskip *= 10;
	      nskip += c - '0';
	    }
	  if (c >= 0)
	    UNREAD (c);
	  
	  if (load_force_doc_strings && EQ (readcharfun, Qget_file_char))
	    {
	      /* If we are supposed to force doc strings into core right now,
		 record the last string that we skipped,
		 and record where in the file it comes from.  */

	      /* But first exchange saved_doc_string
		 with prev_saved_doc_string, so we save two strings.  */
	      {
		char *temp = saved_doc_string;
		int temp_size = saved_doc_string_size;
		int temp_pos = saved_doc_string_position;
		int temp_len = saved_doc_string_length;

		saved_doc_string = prev_saved_doc_string;
		saved_doc_string_size = prev_saved_doc_string_size;
		saved_doc_string_position = prev_saved_doc_string_position;
		saved_doc_string_length = prev_saved_doc_string_length;

		prev_saved_doc_string = temp;
		prev_saved_doc_string_size = temp_size;
		prev_saved_doc_string_position = temp_pos;
		prev_saved_doc_string_length = temp_len;
	      }

	      if (saved_doc_string_size == 0)
		{
		  saved_doc_string_size = nskip + 100;
		  saved_doc_string = (char *) xmalloc (saved_doc_string_size);
		}
	      if (nskip > saved_doc_string_size)
		{
		  saved_doc_string_size = nskip + 100;
		  saved_doc_string = (char *) xrealloc (saved_doc_string,
							saved_doc_string_size);
		}

	      saved_doc_string_position = ftell (instream);

	      /* Copy that many characters into saved_doc_string.  */
	      for (i = 0; i < nskip && c >= 0; i++)
		saved_doc_string[i] = c = READCHAR;

	      saved_doc_string_length = i;
	    }
	  else
	    {
	      /* Skip that many characters.  */
	      for (i = 0; i < nskip && c >= 0; i++)
		c = READCHAR;
	    }

	  goto retry;
	}
      if (c == '$')
	return Vload_file_name;
      if (c == '\'')
	return Fcons (Qfunction, Fcons (read0 (readcharfun), Qnil));
      /* #:foo is the uninterned symbol named foo.  */
      if (c == ':')
	{
	  uninterned_symbol = 1;
	  c = READCHAR;
	  goto default_label;
	}
      /* Reader forms that can reuse previously read objects.  */
      if (c >= '0' && c <= '9')
	{
	  int n = 0;
	  Lisp_Object tem;

	  /* Read a non-negative integer.  */
	  while (c >= '0' && c <= '9')
	    {
	      n *= 10;
	      n += c - '0';
	      c = READCHAR;
	    }
	  /* #n=object returns object, but associates it with n for #n#.  */
	  if (c == '=')
	    {
	      tem = read0 (readcharfun);
	      read_objects = Fcons (Fcons (make_number (n), tem), read_objects);
	      return tem;
	    }
	  /* #n# returns a previously read object.  */
	  if (c == '#')
	    {
	      tem = Fassq (make_number (n), read_objects);
	      if (CONSP (tem))
		return XCDR (tem);
	      /* Fall through to error message.  */
	    }
	  /* Fall through to error message.  */
	}

      UNREAD (c);
      Fsignal (Qinvalid_read_syntax, Fcons (make_string ("#", 1), Qnil));

    case ';':
      while ((c = READCHAR) >= 0 && c != '\n');
      goto retry;

    case '\'':
      {
	return Fcons (Qquote, Fcons (read0 (readcharfun), Qnil));
      }

    case '`':
      if (first_in_list)
	goto default_label;
      else
	{
	  Lisp_Object value;

	  new_backquote_flag = 1;
	  value = read0 (readcharfun);
	  new_backquote_flag = 0;

	  return Fcons (Qbackquote, Fcons (value, Qnil));
	}

    case ',':
      if (new_backquote_flag)
	{
	  Lisp_Object comma_type = Qnil;
	  Lisp_Object value;
	  int ch = READCHAR;

	  if (ch == '@')
	    comma_type = Qcomma_at;
	  else if (ch == '.')
	    comma_type = Qcomma_dot;
	  else
	    {
	      if (ch >= 0) UNREAD (ch);
	      comma_type = Qcomma;
	    }

	  new_backquote_flag = 0;
	  value = read0 (readcharfun);
	  new_backquote_flag = 1;
	  return Fcons (comma_type, Fcons (value, Qnil));
	}
      else
	goto default_label;

    case '?':
      {
	register Lisp_Object val;

	c = READCHAR;
	if (c < 0) return Fsignal (Qend_of_file, Qnil);

	if (c == '\\')
	  c = read_escape (readcharfun, 0);
	else if (BASE_LEADING_CODE_P (c))
	  c = read_multibyte (c, readcharfun);

	return make_number (c);
      }

    case '"':
      {
	register char *p = read_buffer;
	register char *end = read_buffer + read_buffer_size;
	register int c;
	/* Nonzero if we saw an escape sequence specifying
	   a multibyte character.  */
	int force_multibyte = 0;
	/* Nonzero if we saw an escape sequence specifying
	   a single-byte character.  */
	int force_singlebyte = 0;
	int cancel = 0;
	int nchars;

	while ((c = READCHAR) >= 0
	       && c != '\"')
	  {
	    if (end - p < MAX_LENGTH_OF_MULTI_BYTE_FORM)
	      {
		char *new = (char *) xrealloc (read_buffer, read_buffer_size *= 2);
		p += new - read_buffer;
		read_buffer += new - read_buffer;
		end = read_buffer + read_buffer_size;
	      }

	    if (c == '\\')
	      {
		c = read_escape (readcharfun, 1);

		/* C is -1 if \ newline has just been seen */
		if (c == -1)
		  {
		    if (p == read_buffer)
		      cancel = 1;
		    continue;
		  }

		/* If an escape specifies a non-ASCII single-byte character,
		   this must be a unibyte string.  */
		if (SINGLE_BYTE_CHAR_P ((c & ~CHAR_META))
		    && ! ASCII_BYTE_P (c))
		  force_singlebyte = 1;
	      }

	    if (! SINGLE_BYTE_CHAR_P ((c & ~CHAR_META)))
	      {
		unsigned char workbuf[4];
		unsigned char *str = workbuf;
		int length;

		length = non_ascii_char_to_string (c, workbuf, &str);
		if (length > 1)
		  force_multibyte = 1;

		bcopy (str, p, length);
		p += length;
	      }
	    else
	      {
		/* Allow `\C- ' and `\C-?'.  */
		if (c == (CHAR_CTL | ' '))
		  c = 0;
		else if (c == (CHAR_CTL | '?'))
		  c = 127;

		if (c & CHAR_META)
		  /* Move the meta bit to the right place for a string.  */
		  c = (c & ~CHAR_META) | 0x80;
		if (c & ~0xff)
		  error ("Invalid modifier in string");
		*p++ = c;
	      }
	  }
	if (c < 0)
	  return Fsignal (Qend_of_file, Qnil);

	/* If purifying, and string starts with \ newline,
	   return zero instead.  This is for doc strings
	   that we are really going to find in etc/DOC.nn.nn  */
	if (!NILP (Vpurify_flag) && NILP (Vdoc_file_name) && cancel)
	  return make_number (0);

	if (force_multibyte)
	  nchars = multibyte_chars_in_text (read_buffer, p - read_buffer);
	else if (force_singlebyte)
	  nchars = p - read_buffer;
	else if (load_convert_to_unibyte)
	  {
	    Lisp_Object string;
	    nchars = multibyte_chars_in_text (read_buffer, p - read_buffer);
	    if (p - read_buffer != nchars)
	      {
		string = make_multibyte_string (read_buffer, nchars,
						p - read_buffer);
		return Fstring_make_unibyte (string);
	      }
	  }
	else if (EQ (readcharfun, Qget_file_char)
		 || EQ (readcharfun, Qlambda))
	  /* Nowadays, reading directly from a file
	     is used only for compiled Emacs Lisp files,
	     and those always use the Emacs internal encoding.
	     Meanwhile, Qlambda is used for reading dynamic byte code
	     (compiled with byte-compile-dynamic = t).  */
	  nchars = multibyte_chars_in_text (read_buffer, p - read_buffer);
	else
	  /* In all other cases, if we read these bytes as
	     separate characters, treat them as separate characters now.  */
	  nchars = p - read_buffer;

	if (read_pure)
	  return make_pure_string (read_buffer, nchars, p - read_buffer,
				   (force_multibyte
				    || (p - read_buffer != nchars)));
	return make_specified_string (read_buffer, nchars, p - read_buffer,
				      (force_multibyte
				       || (p - read_buffer != nchars)));
      }

    case '.':
      {
#ifdef LISP_FLOAT_TYPE
	/* If a period is followed by a number, then we should read it
	   as a floating point number.  Otherwise, it denotes a dotted
	   pair.  */
	int next_char = READCHAR;
	UNREAD (next_char);

	if (! (next_char >= '0' && next_char <= '9'))
#endif
	  {
	    *pch = c;
	    return Qnil;
	  }

	/* Otherwise, we fall through!  Note that the atom-reading loop
	   below will now loop at least once, assuring that we will not
	   try to UNREAD two characters in a row.  */
      }
    default:
    default_label:
      if (c <= 040) goto retry;
      {
	register char *p = read_buffer;
	int quoted = 0;

	{
	  register char *end = read_buffer + read_buffer_size;

	  while (c > 040
		 && !(c == '\"' || c == '\'' || c == ';' || c == '?'
		      || c == '(' || c == ')'
#ifndef LISP_FLOAT_TYPE
		      /* If we have floating-point support, then we need
			 to allow <digits><dot><digits>.  */
		      || c =='.'
#endif /* not LISP_FLOAT_TYPE */
		      || c == '[' || c == ']' || c == '#'
		      ))
	    {
	      if (end - p < MAX_LENGTH_OF_MULTI_BYTE_FORM)
		{
		  register char *new = (char *) xrealloc (read_buffer, read_buffer_size *= 2);
		  p += new - read_buffer;
		  read_buffer += new - read_buffer;
		  end = read_buffer + read_buffer_size;
		}
	      if (c == '\\')
		{
		  c = READCHAR;
		  quoted = 1;
		}

	      if (! SINGLE_BYTE_CHAR_P (c))
		{
		  unsigned char workbuf[4];
		  unsigned char *str = workbuf;
		  int length;

		  length = non_ascii_char_to_string (c, workbuf, &str);

		  bcopy (str, p, length);
		  p += length;
		}
	      else
		*p++ = c;

	      c = READCHAR;
	    }

	  if (p == end)
	    {
	      char *new = (char *) xrealloc (read_buffer, read_buffer_size *= 2);
	      p += new - read_buffer;
	      read_buffer += new - read_buffer;
/*	      end = read_buffer + read_buffer_size;  */
	    }
	  *p = 0;
	  if (c >= 0)
	    UNREAD (c);
	}

	if (!quoted && !uninterned_symbol)
	  {
	    register char *p1;
	    register Lisp_Object val;
	    p1 = read_buffer;
	    if (*p1 == '+' || *p1 == '-') p1++;
	    /* Is it an integer? */
	    if (p1 != p)
	      {
		while (p1 != p && (c = *p1) >= '0' && c <= '9') p1++;
#ifdef LISP_FLOAT_TYPE
		/* Integers can have trailing decimal points.  */
		if (p1 > read_buffer && p1 < p && *p1 == '.') p1++;
#endif
		if (p1 == p)
		  /* It is an integer. */
		  {
#ifdef LISP_FLOAT_TYPE
		    if (p1[-1] == '.')
		      p1[-1] = '\0';
#endif
		    if (sizeof (int) == sizeof (EMACS_INT))
		      XSETINT (val, atoi (read_buffer));
		    else if (sizeof (long) == sizeof (EMACS_INT))
		      XSETINT (val, atol (read_buffer));
		    else
		      abort ();
		    return val;
		  }
	      }
#ifdef LISP_FLOAT_TYPE
	    if (isfloat_string (read_buffer))
	      {
		/* Compute NaN and infinities using 0.0 in a variable,
		   to cope with compilers that think they are smarter
		   than we are.  */
		double zero = 0.0;

		double value;

		/* Negate the value ourselves.  This treats 0, NaNs,
		   and infinity properly on IEEE floating point hosts,
		   and works around a common bug where atof ("-0.0")
		   drops the sign.  */
		int negative = read_buffer[0] == '-';

		/* The only way p[-1] can be 'F' or 'N', after isfloat_string
		   returns 1, is if the input ends in e+INF or e+NaN.  */
		switch (p[-1])
		  {
		  case 'F':
		    value = 1.0 / zero;
		    break;
		  case 'N':
		    value = zero / zero;
		    break;
		  default:
		    value = atof (read_buffer + negative);
		    break;
		  }

		return make_float (negative ? - value : value);
	      }
#endif
	  }

	if (uninterned_symbol)
	  return make_symbol (read_buffer);
	else
	  return intern (read_buffer);
      }
    }
}

#ifdef LISP_FLOAT_TYPE

#define LEAD_INT 1
#define DOT_CHAR 2
#define TRAIL_INT 4
#define E_CHAR 8
#define EXP_INT 16

int
isfloat_string (cp)
     register char *cp;
{
  register int state;
  
  char *start = cp;

  state = 0;
  if (*cp == '+' || *cp == '-')
    cp++;

  if (*cp >= '0' && *cp <= '9')
    {
      state |= LEAD_INT;
      while (*cp >= '0' && *cp <= '9')
	cp++;
    }
  if (*cp == '.')
    {
      state |= DOT_CHAR;
      cp++;
    }
  if (*cp >= '0' && *cp <= '9')
    {
      state |= TRAIL_INT;
      while (*cp >= '0' && *cp <= '9')
	cp++;
    }
  if (*cp == 'e' || *cp == 'E')
    {
      state |= E_CHAR;
      cp++;
      if (*cp == '+' || *cp == '-')
	cp++;
    }

  if (*cp >= '0' && *cp <= '9')
    {
      state |= EXP_INT;
      while (*cp >= '0' && *cp <= '9')
	cp++;
    }
  else if (cp == start)
    ;
  else if (cp[-1] == '+' && cp[0] == 'I' && cp[1] == 'N' && cp[2] == 'F')
    {
      state |= EXP_INT;
      cp += 3;
    }
  else if (cp[-1] == '+' && cp[0] == 'N' && cp[1] == 'a' && cp[2] == 'N')
    {
      state |= EXP_INT;
      cp += 3;
    }

  return (((*cp == 0) || (*cp == ' ') || (*cp == '\t') || (*cp == '\n') || (*cp == '\r') || (*cp == '\f'))
	  && (state == (LEAD_INT|DOT_CHAR|TRAIL_INT)
	      || state == (DOT_CHAR|TRAIL_INT)
	      || state == (LEAD_INT|E_CHAR|EXP_INT)
	      || state == (LEAD_INT|DOT_CHAR|TRAIL_INT|E_CHAR|EXP_INT)
	      || state == (DOT_CHAR|TRAIL_INT|E_CHAR|EXP_INT)));
}
#endif /* LISP_FLOAT_TYPE */

static Lisp_Object
read_vector (readcharfun, bytecodeflag)
     Lisp_Object readcharfun;
     int bytecodeflag;
{
  register int i;
  register int size;
  register Lisp_Object *ptr;
  register Lisp_Object tem, item, vector;
  register struct Lisp_Cons *otem;
  Lisp_Object len;

  tem = read_list (1, readcharfun);
  len = Flength (tem);
  vector = (read_pure ? make_pure_vector (XINT (len)) : Fmake_vector (len, Qnil));

  size = XVECTOR (vector)->size;
  ptr = XVECTOR (vector)->contents;
  for (i = 0; i < size; i++)
    {
      item = Fcar (tem);
      /* If `load-force-doc-strings' is t when reading a lazily-loaded
	 bytecode object, the docstring containing the bytecode and
	 constants values must be treated as unibyte and passed to
	 Fread, to get the actual bytecode string and constants vector.  */
      if (bytecodeflag && load_force_doc_strings)
	{
	  if (i == COMPILED_BYTECODE)
	    {
	      if (!STRINGP (item))
		error ("invalid byte code");

	      /* Delay handling the bytecode slot until we know whether
		 it is lazily-loaded (we can tell by whether the
		 constants slot is nil).  */
	      ptr[COMPILED_CONSTANTS] = item;
	      item = Qnil;
	    }
	  else if (i == COMPILED_CONSTANTS)
	    {
	      Lisp_Object bytestr = ptr[COMPILED_CONSTANTS];

	      if (NILP (item))
		{
		  /* Coerce string to unibyte (like string-as-unibyte,
		     but without generating extra garbage and
		     guaranteeing no change in the contents).  */
		  XSTRING (bytestr)->size = STRING_BYTES (XSTRING (bytestr));
		  SET_STRING_BYTES (XSTRING (bytestr), -1);

		  item = Fread (bytestr);
		  if (!CONSP (item))
		    error ("invalid byte code");

		  otem = XCONS (item);
		  bytestr = XCONS (item)->car;
		  item = XCONS (item)->cdr;
		  free_cons (otem);
		}

	      /* Now handle the bytecode slot.  */
	      ptr[COMPILED_BYTECODE] = read_pure ? Fpurecopy (bytestr) : bytestr;
	    }
	}
      ptr[i] = read_pure ? Fpurecopy (item) : item;
      otem = XCONS (tem);
      tem = Fcdr (tem);
      free_cons (otem);
    }
  return vector;
}
  
/* FLAG = 1 means check for ] to terminate rather than ) and .
   FLAG = -1 means check for starting with defun
    and make structure pure.  */

static Lisp_Object
read_list (flag, readcharfun)
     int flag;
     register Lisp_Object readcharfun;
{
  /* -1 means check next element for defun,
     0 means don't check,
     1 means already checked and found defun. */
  int defunflag = flag < 0 ? -1 : 0;
  Lisp_Object val, tail;
  register Lisp_Object elt, tem;
  struct gcpro gcpro1, gcpro2;
  /* 0 is the normal case.
     1 means this list is a doc reference; replace it with the number 0.
     2 means this list is a doc reference; replace it with the doc string.  */ 
  int doc_reference = 0;

  /* Initialize this to 1 if we are reading a list.  */
  int first_in_list = flag <= 0;

  val = Qnil;
  tail = Qnil;

  while (1)
    {
      int ch;
      GCPRO2 (val, tail);
      elt = read1 (readcharfun, &ch, first_in_list);
      UNGCPRO;

      first_in_list = 0;

      /* While building, if the list starts with #$, treat it specially.  */
      if (EQ (elt, Vload_file_name)
	  && ! NILP (elt)
	  && !NILP (Vpurify_flag))
	{
	  if (NILP (Vdoc_file_name))
	    /* We have not yet called Snarf-documentation, so assume
	       this file is described in the DOC-MM.NN file
	       and Snarf-documentation will fill in the right value later.
	       For now, replace the whole list with 0.  */
	    doc_reference = 1;
	  else
	    /* We have already called Snarf-documentation, so make a relative
	       file name for this file, so it can be found properly
	       in the installed Lisp directory.
	       We don't use Fexpand_file_name because that would make
	       the directory absolute now.  */
	    elt = concat2 (build_string ("../lisp/"),
			   Ffile_name_nondirectory (elt));
	}
      else if (EQ (elt, Vload_file_name)
	       && ! NILP (elt)
	       && load_force_doc_strings)
	doc_reference = 2;

      if (ch)
	{
	  if (flag > 0)
	    {
	      if (ch == ']')
		return val;
	      Fsignal (Qinvalid_read_syntax,
		       Fcons (make_string (") or . in a vector", 18), Qnil));
	    }
	  if (ch == ')')
	    return val;
	  if (ch == '.')
	    {
	      GCPRO2 (val, tail);
	      if (!NILP (tail))
		XCONS (tail)->cdr = read0 (readcharfun);
	      else
		val = read0 (readcharfun);
	      read1 (readcharfun, &ch, 0);
	      UNGCPRO;
	      if (ch == ')')
		{
		  if (doc_reference == 1)
		    return make_number (0);
		  if (doc_reference == 2)
		    {
		      /* Get a doc string from the file we are loading.
			 If it's in saved_doc_string, get it from there.  */
		      int pos = XINT (XCONS (val)->cdr);
		      /* Position is negative for user variables.  */
		      if (pos < 0) pos = -pos;
		      if (pos >= saved_doc_string_position
			  && pos < (saved_doc_string_position
				    + saved_doc_string_length))
			{
			  int start = pos - saved_doc_string_position;
			  int from, to;

			  /* Process quoting with ^A,
			     and find the end of the string,
			     which is marked with ^_ (037).  */
			  for (from = start, to = start;
			       saved_doc_string[from] != 037;)
			    {
			      int c = saved_doc_string[from++];
			      if (c == 1)
				{
				  c = saved_doc_string[from++];
				  if (c == 1)
				    saved_doc_string[to++] = c;
				  else if (c == '0')
				    saved_doc_string[to++] = 0;
				  else if (c == '_')
				    saved_doc_string[to++] = 037;
				}
			      else
				saved_doc_string[to++] = c;
			    }

			  return make_string (saved_doc_string + start,
					      to - start);
			}
		      /* Look in prev_saved_doc_string the same way.  */
		      else if (pos >= prev_saved_doc_string_position
			       && pos < (prev_saved_doc_string_position
					 + prev_saved_doc_string_length))
			{
			  int start = pos - prev_saved_doc_string_position;
			  int from, to;

			  /* Process quoting with ^A,
			     and find the end of the string,
			     which is marked with ^_ (037).  */
			  for (from = start, to = start;
			       prev_saved_doc_string[from] != 037;)
			    {
			      int c = prev_saved_doc_string[from++];
			      if (c == 1)
				{
				  c = prev_saved_doc_string[from++];
				  if (c == 1)
				    prev_saved_doc_string[to++] = c;
				  else if (c == '0')
				    prev_saved_doc_string[to++] = 0;
				  else if (c == '_')
				    prev_saved_doc_string[to++] = 037;
				}
			      else
				prev_saved_doc_string[to++] = c;
			    }

			  return make_string (prev_saved_doc_string + start,
					      to - start);
			}
		      else
			return get_doc_string (val, 0, 0);
		    }

		  return val;
		}
	      return Fsignal (Qinvalid_read_syntax, Fcons (make_string (". in wrong context", 18), Qnil));
	    }
	  return Fsignal (Qinvalid_read_syntax, Fcons (make_string ("] in a list", 11), Qnil));
	}
      tem = (read_pure && flag <= 0
	     ? pure_cons (elt, Qnil)
	     : Fcons (elt, Qnil));
      if (!NILP (tail))
	XCONS (tail)->cdr = tem;
      else
	val = tem;
      tail = tem;
      if (defunflag < 0)
	defunflag = EQ (elt, Qdefun);
      else if (defunflag > 0)
	read_pure = 1;
    }
}

Lisp_Object Vobarray;
Lisp_Object initial_obarray;

/* oblookup stores the bucket number here, for the sake of Funintern.  */

int oblookup_last_bucket_number;

static int hash_string ();
Lisp_Object oblookup ();

/* Get an error if OBARRAY is not an obarray.
   If it is one, return it.  */

Lisp_Object
check_obarray (obarray)
     Lisp_Object obarray;
{
  while (!VECTORP (obarray) || XVECTOR (obarray)->size == 0)
    {
      /* If Vobarray is now invalid, force it to be valid.  */
      if (EQ (Vobarray, obarray)) Vobarray = initial_obarray;

      obarray = wrong_type_argument (Qvectorp, obarray);
    }
  return obarray;
}

/* Intern the C string STR: return a symbol with that name,
   interned in the current obarray.  */

Lisp_Object
intern (str)
     char *str;
{
  Lisp_Object tem;
  int len = strlen (str);
  Lisp_Object obarray;

  obarray = Vobarray;
  if (!VECTORP (obarray) || XVECTOR (obarray)->size == 0)
    obarray = check_obarray (obarray);
  tem = oblookup (obarray, str, len, len);
  if (SYMBOLP (tem))
    return tem;
  return Fintern (make_string (str, len), obarray);
}

/* Create an uninterned symbol with name STR.  */

Lisp_Object
make_symbol (str)
     char *str;
{
  int len = strlen (str);

  return Fmake_symbol ((!NILP (Vpurify_flag)
			? make_pure_string (str, len, len, 0)
			: make_string (str, len)));
}

DEFUN ("intern", Fintern, Sintern, 1, 2, 0,
  "Return the canonical symbol whose name is STRING.\n\
If there is none, one is created by this function and returned.\n\
A second optional argument specifies the obarray to use;\n\
it defaults to the value of `obarray'.")
  (string, obarray)
     Lisp_Object string, obarray;
{
  register Lisp_Object tem, sym, *ptr;

  if (NILP (obarray)) obarray = Vobarray;
  obarray = check_obarray (obarray);

  CHECK_STRING (string, 0);

  tem = oblookup (obarray, XSTRING (string)->data,
		  XSTRING (string)->size,
		  STRING_BYTES (XSTRING (string)));
  if (!INTEGERP (tem))
    return tem;

  if (!NILP (Vpurify_flag))
    string = Fpurecopy (string);
  sym = Fmake_symbol (string);
  XSYMBOL (sym)->obarray = obarray;

  if ((XSTRING (string)->data[0] == ':')
      && EQ (obarray, initial_obarray))
    XSYMBOL (sym)->value = sym;

  ptr = &XVECTOR (obarray)->contents[XINT (tem)];
  if (SYMBOLP (*ptr))
    XSYMBOL (sym)->next = XSYMBOL (*ptr);
  else
    XSYMBOL (sym)->next = 0;
  *ptr = sym;
  return sym;
}

DEFUN ("intern-soft", Fintern_soft, Sintern_soft, 1, 2, 0,
  "Return the canonical symbol whose name is STRING, or nil if none exists.\n\
A second optional argument specifies the obarray to use;\n\
it defaults to the value of `obarray'.")
  (string, obarray)
     Lisp_Object string, obarray;
{
  register Lisp_Object tem;

  if (NILP (obarray)) obarray = Vobarray;
  obarray = check_obarray (obarray);

  CHECK_STRING (string, 0);

  tem = oblookup (obarray, XSTRING (string)->data,
		  XSTRING (string)->size,
		  STRING_BYTES (XSTRING (string)));
  if (!INTEGERP (tem))
    return tem;
  return Qnil;
}

DEFUN ("unintern", Funintern, Sunintern, 1, 2, 0,
  "Delete the symbol named NAME, if any, from OBARRAY.\n\
The value is t if a symbol was found and deleted, nil otherwise.\n\
NAME may be a string or a symbol.  If it is a symbol, that symbol\n\
is deleted, if it belongs to OBARRAY--no other symbol is deleted.\n\
OBARRAY defaults to the value of the variable `obarray'.")
  (name, obarray)
     Lisp_Object name, obarray;
{
  register Lisp_Object string, tem;
  int hash;

  if (NILP (obarray)) obarray = Vobarray;
  obarray = check_obarray (obarray);

  if (SYMBOLP (name))
    XSETSTRING (string, XSYMBOL (name)->name);
  else
    {
      CHECK_STRING (name, 0);
      string = name;
    }

  tem = oblookup (obarray, XSTRING (string)->data,
		  XSTRING (string)->size,
		  STRING_BYTES (XSTRING (string)));
  if (INTEGERP (tem))
    return Qnil;
  /* If arg was a symbol, don't delete anything but that symbol itself.  */
  if (SYMBOLP (name) && !EQ (name, tem))
    return Qnil;

  XSYMBOL (tem)->obarray = Qnil;

  hash = oblookup_last_bucket_number;

  if (EQ (XVECTOR (obarray)->contents[hash], tem))
    {
      if (XSYMBOL (tem)->next)
	XSETSYMBOL (XVECTOR (obarray)->contents[hash], XSYMBOL (tem)->next);
      else
	XSETINT (XVECTOR (obarray)->contents[hash], 0);
    }
  else
    {
      Lisp_Object tail, following;

      for (tail = XVECTOR (obarray)->contents[hash];
	   XSYMBOL (tail)->next;
	   tail = following)
	{
	  XSETSYMBOL (following, XSYMBOL (tail)->next);
	  if (EQ (following, tem))
	    {
	      XSYMBOL (tail)->next = XSYMBOL (following)->next;
	      break;
	    }
	}
    }

  return Qt;
}

/* Return the symbol in OBARRAY whose names matches the string
   of SIZE characters (SIZE_BYTE bytes) at PTR.
   If there is no such symbol in OBARRAY, return nil.

   Also store the bucket number in oblookup_last_bucket_number.  */

Lisp_Object
oblookup (obarray, ptr, size, size_byte)
     Lisp_Object obarray;
     register char *ptr;
     int size, size_byte;
{
  int hash;
  int obsize;
  register Lisp_Object tail;
  Lisp_Object bucket, tem;

  if (!VECTORP (obarray)
      || (obsize = XVECTOR (obarray)->size) == 0)
    {
      obarray = check_obarray (obarray);
      obsize = XVECTOR (obarray)->size;
    }
  /* This is sometimes needed in the middle of GC.  */
  obsize &= ~ARRAY_MARK_FLAG;
  /* Combining next two lines breaks VMS C 2.3.  */
  hash = hash_string (ptr, size_byte);
  hash %= obsize;
  bucket = XVECTOR (obarray)->contents[hash];
  oblookup_last_bucket_number = hash;
  if (XFASTINT (bucket) == 0)
    ;
  else if (!SYMBOLP (bucket))
    error ("Bad data in guts of obarray"); /* Like CADR error message */
  else
    for (tail = bucket; ; XSETSYMBOL (tail, XSYMBOL (tail)->next))
      {
	if (STRING_BYTES (XSYMBOL (tail)->name) == size_byte
	    && XSYMBOL (tail)->name->size == size
	    && !bcmp (XSYMBOL (tail)->name->data, ptr, size_byte))
	  return tail;
	else if (XSYMBOL (tail)->next == 0)
	  break;
      }
  XSETINT (tem, hash);
  return tem;
}

static int
hash_string (ptr, len)
     unsigned char *ptr;
     int len;
{
  register unsigned char *p = ptr;
  register unsigned char *end = p + len;
  register unsigned char c;
  register int hash = 0;

  while (p != end)
    {
      c = *p++;
      if (c >= 0140) c -= 40;
      hash = ((hash<<3) + (hash>>28) + c);
    }
  return hash & 07777777777;
}

void
map_obarray (obarray, fn, arg)
     Lisp_Object obarray;
     void (*fn) P_ ((Lisp_Object, Lisp_Object));
     Lisp_Object arg;
{
  register int i;
  register Lisp_Object tail;
  CHECK_VECTOR (obarray, 1);
  for (i = XVECTOR (obarray)->size - 1; i >= 0; i--)
    {
      tail = XVECTOR (obarray)->contents[i];
      if (SYMBOLP (tail))
	while (1)
	  {
	    (*fn) (tail, arg);
	    if (XSYMBOL (tail)->next == 0)
	      break;
	    XSETSYMBOL (tail, XSYMBOL (tail)->next);
	  }
    }
}

void
mapatoms_1 (sym, function)
     Lisp_Object sym, function;
{
  call1 (function, sym);
}

DEFUN ("mapatoms", Fmapatoms, Smapatoms, 1, 2, 0,
  "Call FUNCTION on every symbol in OBARRAY.\n\
OBARRAY defaults to the value of `obarray'.")
  (function, obarray)
     Lisp_Object function, obarray;
{
  Lisp_Object tem;

  if (NILP (obarray)) obarray = Vobarray;
  obarray = check_obarray (obarray);

  map_obarray (obarray, mapatoms_1, function);
  return Qnil;
}

#define OBARRAY_SIZE 1511

void
init_obarray ()
{
  Lisp_Object oblength;
  int hash;
  Lisp_Object *tem;

  XSETFASTINT (oblength, OBARRAY_SIZE);

  Qnil = Fmake_symbol (make_pure_string ("nil", 3, 3, 0));
  Vobarray = Fmake_vector (oblength, make_number (0));
  initial_obarray = Vobarray;
  staticpro (&initial_obarray);
  /* Intern nil in the obarray */
  XSYMBOL (Qnil)->obarray = Vobarray;
  /* These locals are to kludge around a pyramid compiler bug. */
  hash = hash_string ("nil", 3);
  /* Separate statement here to avoid VAXC bug. */
  hash %= OBARRAY_SIZE;
  tem = &XVECTOR (Vobarray)->contents[hash];
  *tem = Qnil;

  Qunbound = Fmake_symbol (make_pure_string ("unbound", 7, 7, 0));
  XSYMBOL (Qnil)->function = Qunbound;
  XSYMBOL (Qunbound)->value = Qunbound;
  XSYMBOL (Qunbound)->function = Qunbound;

  Qt = intern ("t");
  XSYMBOL (Qnil)->value = Qnil;
  XSYMBOL (Qnil)->plist = Qnil;
  XSYMBOL (Qt)->value = Qt;

  /* Qt is correct even if CANNOT_DUMP.  loadup.el will set to nil at end.  */
  Vpurify_flag = Qt;

  Qvariable_documentation = intern ("variable-documentation");
  staticpro (&Qvariable_documentation);

  read_buffer_size = 100 + MAX_LENGTH_OF_MULTI_BYTE_FORM;
  read_buffer = (char *) malloc (read_buffer_size);
}

void
defsubr (sname)
     struct Lisp_Subr *sname;
{
  Lisp_Object sym;
  sym = intern (sname->symbol_name);
  XSETSUBR (XSYMBOL (sym)->function, sname);
}

#ifdef NOTDEF /* use fset in subr.el now */
void
defalias (sname, string)
     struct Lisp_Subr *sname;
     char *string;
{
  Lisp_Object sym;
  sym = intern (string);
  XSETSUBR (XSYMBOL (sym)->function, sname);
}
#endif /* NOTDEF */

/* Define an "integer variable"; a symbol whose value is forwarded
   to a C variable of type int.  Sample call: */
  /* DEFVAR_INT ("indent-tabs-mode", &indent_tabs_mode, "Documentation");  */
void
defvar_int (namestring, address)
     char *namestring;
     int *address;
{
  Lisp_Object sym, val;
  sym = intern (namestring);
  val = allocate_misc ();
  XMISCTYPE (val) = Lisp_Misc_Intfwd;
  XINTFWD (val)->intvar = address;
  XSYMBOL (sym)->value = val;
}

/* Similar but define a variable whose value is T if address contains 1,
   NIL if address contains 0 */
void
defvar_bool (namestring, address)
     char *namestring;
     int *address;
{
  Lisp_Object sym, val;
  sym = intern (namestring);
  val = allocate_misc ();
  XMISCTYPE (val) = Lisp_Misc_Boolfwd;
  XBOOLFWD (val)->boolvar = address;
  XSYMBOL (sym)->value = val;
}

/* Similar but define a variable whose value is the Lisp Object stored
   at address.  Two versions: with and without gc-marking of the C
   variable.  The nopro version is used when that variable will be
   gc-marked for some other reason, since marking the same slot twice
   can cause trouble with strings.  */
void
defvar_lisp_nopro (namestring, address)
     char *namestring;
     Lisp_Object *address;
{
  Lisp_Object sym, val;
  sym = intern (namestring);
  val = allocate_misc ();
  XMISCTYPE (val) = Lisp_Misc_Objfwd;
  XOBJFWD (val)->objvar = address;
  XSYMBOL (sym)->value = val;
}

void
defvar_lisp (namestring, address)
     char *namestring;
     Lisp_Object *address;
{
  defvar_lisp_nopro (namestring, address);
  staticpro (address);
}

#ifndef standalone

/* Similar but define a variable whose value is the Lisp Object stored in
   the current buffer.  address is the address of the slot in the buffer
   that is current now. */

void
defvar_per_buffer (namestring, address, type, doc)
     char *namestring;
     Lisp_Object *address;
     Lisp_Object type;
     char *doc;
{
  Lisp_Object sym, val;
  int offset;
  extern struct buffer buffer_local_symbols;

  sym = intern (namestring);
  val = allocate_misc ();
  offset = (char *)address - (char *)current_buffer;

  XMISCTYPE (val) = Lisp_Misc_Buffer_Objfwd;
  XBUFFER_OBJFWD (val)->offset = offset;
  XSYMBOL (sym)->value = val;
  *(Lisp_Object *)(offset + (char *)&buffer_local_symbols) = sym;
  *(Lisp_Object *)(offset + (char *)&buffer_local_types) = type;
  if (XINT (*(Lisp_Object *)(offset + (char *)&buffer_local_flags)) == 0)
    /* Did a DEFVAR_PER_BUFFER without initializing the corresponding
       slot of buffer_local_flags */
    abort ();
}

#endif /* standalone */

/* Similar but define a variable whose value is the Lisp Object stored
   at a particular offset in the current kboard object.  */

void
defvar_kboard (namestring, offset)
     char *namestring;
     int offset;
{
  Lisp_Object sym, val;
  sym = intern (namestring);
  val = allocate_misc ();
  XMISCTYPE (val) = Lisp_Misc_Kboard_Objfwd;
  XKBOARD_OBJFWD (val)->offset = offset;
  XSYMBOL (sym)->value = val;
}

/* Record the value of load-path used at the start of dumping
   so we can see if the site changed it later during dumping.  */
static Lisp_Object dump_path;

void
init_lread ()
{
  char *normal;
  int turn_off_warning = 0;

#ifdef HAVE_SETLOCALE
  /* Make sure numbers are parsed as we expect.  */
  setlocale (LC_NUMERIC, "C");
#endif /* HAVE_SETLOCALE */

  /* Compute the default load-path.  */
#ifdef CANNOT_DUMP
  normal = PATH_LOADSEARCH;
  Vload_path = decode_env_path (0, normal);
#else
  if (NILP (Vpurify_flag))
    normal = PATH_LOADSEARCH;
  else
    normal = PATH_DUMPLOADSEARCH;

  /* In a dumped Emacs, we normally have to reset the value of
     Vload_path from PATH_LOADSEARCH, since the value that was dumped
     uses ../lisp, instead of the path of the installed elisp
     libraries.  However, if it appears that Vload_path was changed
     from the default before dumping, don't override that value.  */
  if (initialized)
    {
      if (! NILP (Fequal (dump_path, Vload_path)))
	{
	  Vload_path = decode_env_path (0, normal);
	  if (!NILP (Vinstallation_directory))
	    {
	      /* Add to the path the lisp subdir of the
		 installation dir, if it exists.  */
	      Lisp_Object tem, tem1;
	      tem = Fexpand_file_name (build_string ("lisp"),
				       Vinstallation_directory);
	      tem1 = Ffile_exists_p (tem);
	      if (!NILP (tem1))
		{
		  if (NILP (Fmember (tem, Vload_path)))
		    {
		      turn_off_warning = 1;
		      Vload_path = nconc2 (Vload_path, Fcons (tem, Qnil));
		    }
		}
	      else
		/* That dir doesn't exist, so add the build-time
		   Lisp dirs instead.  */
		Vload_path = nconc2 (Vload_path, dump_path);

	      /* Add leim under the installation dir, if it exists.  */
	      tem = Fexpand_file_name (build_string ("leim"),
				       Vinstallation_directory);
	      tem1 = Ffile_exists_p (tem);
	      if (!NILP (tem1))
		{
		  if (NILP (Fmember (tem, Vload_path)))
		    Vload_path = nconc2 (Vload_path, Fcons (tem, Qnil));
		}

	      /* Add site-list under the installation dir, if it exists.  */
	      tem = Fexpand_file_name (build_string ("site-lisp"),
				       Vinstallation_directory);
	      tem1 = Ffile_exists_p (tem);
	      if (!NILP (tem1))
		{
		  if (NILP (Fmember (tem, Vload_path)))
		    Vload_path = nconc2 (Vload_path, Fcons (tem, Qnil));
		}

	      /* If Emacs was not built in the source directory,
		 and it is run from where it was built, add to load-path
		 the lisp, leim and site-lisp dirs under that directory.  */

	      if (NILP (Fequal (Vinstallation_directory, Vsource_directory)))
		{
		  Lisp_Object tem2;

		  tem = Fexpand_file_name (build_string ("src/Makefile"),
					   Vinstallation_directory);
		  tem1 = Ffile_exists_p (tem);

		  /* Don't be fooled if they moved the entire source tree
		     AFTER dumping Emacs.  If the build directory is indeed
		     different from the source dir, src/Makefile.in and
		     src/Makefile will not be found together.  */
		  tem = Fexpand_file_name (build_string ("src/Makefile.in"),
					   Vinstallation_directory);
		  tem2 = Ffile_exists_p (tem);
		  if (!NILP (tem1) && NILP (tem2))
		    {
		      tem = Fexpand_file_name (build_string ("lisp"),
					       Vsource_directory);

		      if (NILP (Fmember (tem, Vload_path)))
			Vload_path = nconc2 (Vload_path, Fcons (tem, Qnil));

		      tem = Fexpand_file_name (build_string ("leim"),
					       Vsource_directory);

		      if (NILP (Fmember (tem, Vload_path)))
			Vload_path = nconc2 (Vload_path, Fcons (tem, Qnil));

		      tem = Fexpand_file_name (build_string ("site-lisp"),
					       Vsource_directory);

		      if (NILP (Fmember (tem, Vload_path)))
			Vload_path = nconc2 (Vload_path, Fcons (tem, Qnil));
		    }
		}
	    }
	}
    }
  else
    {
      /* NORMAL refers to the lisp dir in the source directory.  */
      /* We used to add ../lisp at the front here, but
	 that caused trouble because it was copied from dump_path
	 into Vload_path, aboe, when Vinstallation_directory was non-nil.
	 It should be unnecessary.  */
      Vload_path = decode_env_path (0, normal);
      dump_path = Vload_path;
    }
#endif

#ifndef WINDOWSNT
  /* When Emacs is invoked over network shares on NT, PATH_LOADSEARCH is 
     almost never correct, thereby causing a warning to be printed out that 
     confuses users.  Since PATH_LOADSEARCH is always overridden by the
     EMACSLOADPATH environment variable below, disable the warning on NT.  */

  /* Warn if dirs in the *standard* path don't exist.  */
  if (!turn_off_warning)
    {
      Lisp_Object path_tail;

      for (path_tail = Vload_path;
	   !NILP (path_tail);
	   path_tail = XCONS (path_tail)->cdr)
	{
	  Lisp_Object dirfile;
	  dirfile = Fcar (path_tail);
	  if (STRINGP (dirfile))
	    {
	      dirfile = Fdirectory_file_name (dirfile);
	      if (access (XSTRING (dirfile)->data, 0) < 0)
		dir_warning ("Warning: Lisp directory `%s' does not exist.\n",
			     XCONS (path_tail)->car);
	    }
	}
    }
#endif /* WINDOWSNT */

  /* If the EMACSLOADPATH environment variable is set, use its value.
     This doesn't apply if we're dumping.  */
#ifndef CANNOT_DUMP
  if (NILP (Vpurify_flag)
      && egetenv ("EMACSLOADPATH"))
#endif
    Vload_path = decode_env_path ("EMACSLOADPATH", normal);

  Vvalues = Qnil;

  load_in_progress = 0;
  Vload_file_name = Qnil;

  load_descriptor_list = Qnil;

  Vstandard_input = Qt;
}

/* Print a warning, using format string FORMAT, that directory DIRNAME
   does not exist.  Print it on stderr and put it in *Message*.  */

void
dir_warning (format, dirname)
     char *format;
     Lisp_Object dirname;
{
  char *buffer
    = (char *) alloca (XSTRING (dirname)->size + strlen (format) + 5);

  fprintf (stderr, format, XSTRING (dirname)->data);
  sprintf (buffer, format, XSTRING (dirname)->data);
  /* Don't log the warning before we've initialized!! */
  if (initialized)
    message_dolog (buffer, strlen (buffer), 0, STRING_MULTIBYTE (dirname));
}

void
syms_of_lread ()
{
  defsubr (&Sread);
  defsubr (&Sread_from_string);
  defsubr (&Sintern);
  defsubr (&Sintern_soft);
  defsubr (&Sunintern);
  defsubr (&Sload);
  defsubr (&Seval_buffer);
  defsubr (&Seval_region);
  defsubr (&Sread_char);
  defsubr (&Sread_char_exclusive);
  defsubr (&Sread_event);
  defsubr (&Sget_file_char);
  defsubr (&Smapatoms);

  DEFVAR_LISP ("obarray", &Vobarray,
    "Symbol table for use by `intern' and `read'.\n\
It is a vector whose length ought to be prime for best results.\n\
The vector's contents don't make sense if examined from Lisp programs;\n\
to find all the symbols in an obarray, use `mapatoms'.");

  DEFVAR_LISP ("values", &Vvalues,
    "List of values of all expressions which were read, evaluated and printed.\n\
Order is reverse chronological.");

  DEFVAR_LISP ("standard-input", &Vstandard_input,
    "Stream for read to get input from.\n\
See documentation of `read' for possible values.");
  Vstandard_input = Qt;

  DEFVAR_LISP ("load-path", &Vload_path,
    "*List of directories to search for files to load.\n\
Each element is a string (directory name) or nil (try default directory).\n\
Initialized based on EMACSLOADPATH environment variable, if any,\n\
otherwise to default specified by file `epaths.h' when Emacs was built.");

  DEFVAR_BOOL ("load-in-progress", &load_in_progress,
    "Non-nil iff inside of `load'.");

  DEFVAR_LISP ("after-load-alist", &Vafter_load_alist,
    "An alist of expressions to be evalled when particular files are loaded.\n\
Each element looks like (FILENAME FORMS...).\n\
When `load' is run and the file-name argument is FILENAME,\n\
the FORMS in the corresponding element are executed at the end of loading.\n\n\
FILENAME must match exactly!  Normally FILENAME is the name of a library,\n\
with no directory specified, since that is how `load' is normally called.\n\
An error in FORMS does not undo the load,\n\
but does prevent execution of the rest of the FORMS.");
  Vafter_load_alist = Qnil;

  DEFVAR_LISP ("load-history", &Vload_history,
    "Alist mapping source file names to symbols and features.\n\
Each alist element is a list that starts with a file name,\n\
except for one element (optional) that starts with nil and describes\n\
definitions evaluated from buffers not visiting files.\n\
The remaining elements of each list are symbols defined as functions\n\
or variables, and cons cells `(provide . FEATURE)' and `(require . FEATURE)'.");
  Vload_history = Qnil;

  DEFVAR_LISP ("load-file-name", &Vload_file_name,
    "Full name of file being loaded by `load'.");
  Vload_file_name = Qnil;

  DEFVAR_LISP ("user-init-file", &Vuser_init_file,
    "File name, including directory, of user's initialization file.");
  Vuser_init_file = Qnil;

  DEFVAR_LISP ("current-load-list", &Vcurrent_load_list,
    "Used for internal purposes by `load'.");
  Vcurrent_load_list = Qnil;

  DEFVAR_LISP ("load-read-function", &Vload_read_function,
    "Function used by `load' and `eval-region' for reading expressions.\n\
The default is nil, which means use the function `read'.");
  Vload_read_function = Qnil;

  DEFVAR_LISP ("load-source-file-function", &Vload_source_file_function,
    "Function called in `load' for loading an Emacs lisp source file.\n\
This function is for doing code conversion before reading the source file.\n\
If nil, loading is done without any code conversion.\n\
Arguments are FULLNAME, FILE, NOERROR, NOMESSAGE, where\n\
 FULLNAME is the full name of FILE.\n\
See `load' for the meaning of the remaining arguments.");
  Vload_source_file_function = Qnil;

  DEFVAR_BOOL ("load-force-doc-strings", &load_force_doc_strings,
     "Non-nil means `load' should force-load all dynamic doc strings.\n\
This is useful when the file being loaded is a temporary copy.");
  load_force_doc_strings = 0;

  DEFVAR_BOOL ("load-convert-to-unibyte", &load_convert_to_unibyte,
     "Non-nil means `load' converts strings to unibyte whenever possible.\n\
This is normally used in `load-with-code-conversion'\n\
for loading non-compiled files.");
  load_convert_to_unibyte = 0;

  DEFVAR_LISP ("source-directory", &Vsource_directory,
     "Directory in which Emacs sources were found when Emacs was built.\n\
You cannot count on them to still be there!");
  Vsource_directory
    = Fexpand_file_name (build_string ("../"),
			 Fcar (decode_env_path (0, PATH_DUMPLOADSEARCH)));

  DEFVAR_LISP ("preloaded-file-list", &Vpreloaded_file_list,
     "List of files that were preloaded (when dumping Emacs).");
  Vpreloaded_file_list = Qnil;

  /* Vsource_directory was initialized in init_lread.  */

  load_descriptor_list = Qnil;
  staticpro (&load_descriptor_list);

  Qcurrent_load_list = intern ("current-load-list");
  staticpro (&Qcurrent_load_list);

  Qstandard_input = intern ("standard-input");
  staticpro (&Qstandard_input);

  Qread_char = intern ("read-char");
  staticpro (&Qread_char);

  Qget_file_char = intern ("get-file-char");
  staticpro (&Qget_file_char);

  Qbackquote = intern ("`");
  staticpro (&Qbackquote);
  Qcomma = intern (",");
  staticpro (&Qcomma);
  Qcomma_at = intern (",@");
  staticpro (&Qcomma_at);
  Qcomma_dot = intern (",.");
  staticpro (&Qcomma_dot);

  Qinhibit_file_name_operation = intern ("inhibit-file-name-operation");
  staticpro (&Qinhibit_file_name_operation);

  Qascii_character = intern ("ascii-character");
  staticpro (&Qascii_character);

  Qfunction = intern ("function");
  staticpro (&Qfunction);

  Qload = intern ("load");
  staticpro (&Qload);

  Qload_file_name = intern ("load-file-name");
  staticpro (&Qload_file_name);

  staticpro (&dump_path);

  staticpro (&read_objects);
  read_objects = Qnil;
}
