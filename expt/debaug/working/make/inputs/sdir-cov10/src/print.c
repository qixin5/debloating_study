/* Lisp object printing and output streams.
   Copyright (C) 1985, 86, 88, 93, 94, 95, 97, 1998
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
#include "lisp.h"

#ifndef standalone
#include "buffer.h"
#include "charset.h"
#include "frame.h"
#include "window.h"
#include "process.h"
#include "dispextern.h"
#include "termchar.h"
#include "keyboard.h"
#endif /* not standalone */

#ifdef USE_TEXT_PROPERTIES
#include "intervals.h"
#endif

Lisp_Object Vstandard_output, Qstandard_output;

Lisp_Object Qtemp_buffer_setup_hook;

/* These are used to print like we read.  */
extern Lisp_Object Qbackquote, Qcomma, Qcomma_at, Qcomma_dot, Qfunction;

#ifdef LISP_FLOAT_TYPE
Lisp_Object Vfloat_output_format, Qfloat_output_format;

/* Work around a problem that happens because math.h on hpux 7
   defines two static variables--which, in Emacs, are not really static,
   because `static' is defined as nothing.  The problem is that they are
   defined both here and in lread.c.
   These macros prevent the name conflict.  */
#if defined (HPUX) && !defined (HPUX8)
#define _MAXLDBL print_maxldbl
#define _NMAXLDBL print_nmaxldbl
#endif

#include <math.h>

#if STDC_HEADERS
#include <float.h>
#include <stdlib.h>
#endif

/* Default to values appropriate for IEEE floating point.  */
#ifndef FLT_RADIX
#define FLT_RADIX 2
#endif
#ifndef DBL_MANT_DIG
#define DBL_MANT_DIG 53
#endif
#ifndef DBL_DIG
#define DBL_DIG 15
#endif
#ifndef DBL_MIN
#define DBL_MIN 2.2250738585072014e-308
#endif

#ifdef DBL_MIN_REPLACEMENT
#undef DBL_MIN
#define DBL_MIN DBL_MIN_REPLACEMENT
#endif

/* Define DOUBLE_DIGITS_BOUND, an upper bound on the number of decimal digits
   needed to express a float without losing information.
   The general-case formula is valid for the usual case, IEEE floating point,
   but many compilers can't optimize the formula to an integer constant,
   so make a special case for it.  */
#if FLT_RADIX == 2 && DBL_MANT_DIG == 53
#define DOUBLE_DIGITS_BOUND 17 /* IEEE floating point */
#else
#define DOUBLE_DIGITS_BOUND ((int) ceil (log10 (pow (FLT_RADIX, DBL_MANT_DIG))))
#endif

#endif /* LISP_FLOAT_TYPE */

/* Avoid actual stack overflow in print.  */
int print_depth;

/* Detect most circularities to print finite output.  */
#define PRINT_CIRCLE 200
Lisp_Object being_printed[PRINT_CIRCLE];

/* When printing into a buffer, first we put the text in this
   block, then insert it all at once.  */
char *print_buffer;

/* Size allocated in print_buffer.  */
int print_buffer_size;
/* Chars stored in print_buffer.  */
int print_buffer_pos;
/* Bytes stored in print_buffer.  */
int print_buffer_pos_byte;

/* Maximum length of list to print in full; noninteger means
   effectively infinity */

Lisp_Object Vprint_length;

/* Maximum depth of list to print in full; noninteger means
   effectively infinity.  */

Lisp_Object Vprint_level;

/* Nonzero means print newlines in strings as \n.  */

int print_escape_newlines;

/* Nonzero means to print single-byte non-ascii characters in strings as
   octal escapes.  */

int print_escape_nonascii;

/* Nonzero means to print multibyte characters in strings as hex escapes.  */

int print_escape_multibyte;

Lisp_Object Qprint_escape_newlines;
Lisp_Object Qprint_escape_multibyte, Qprint_escape_nonascii;

/* Nonzero means print (quote foo) forms as 'foo, etc.  */

int print_quoted;

/* Non-nil means print #: before uninterned symbols.
   Neither t nor nil means so that and don't clear Vprint_gensym_alist
   on entry to and exit from print functions.  */

Lisp_Object Vprint_gensym;

/* Association list of certain objects that are `eq' in the form being
   printed and which should be `eq' when read back in, using the #n=object
   and #n# reader forms.  Each element has the form (object . n).  */

Lisp_Object Vprint_gensym_alist;

/* Nonzero means print newline to stdout before next minibuffer message.
   Defined in xdisp.c */

extern int noninteractive_need_newline;

extern int minibuffer_auto_raise;

#ifdef MAX_PRINT_CHARS
static int print_chars;
static int max_print;
#endif /* MAX_PRINT_CHARS */

void print_interval ();

#if 0
/* Convert between chars and GLYPHs */

int
glyphlen (glyphs)
     register GLYPH *glyphs;
{
  register int i = 0;

  while (glyphs[i])
    i++;
  return i;
}

void
str_to_glyph_cpy (str, glyphs)
     char *str;
     GLYPH *glyphs;
{
  register GLYPH *gp = glyphs;
  register char *cp = str;

  while (*cp)
    *gp++ = *cp++;
}

void
str_to_glyph_ncpy (str, glyphs, n)
     char *str;
     GLYPH *glyphs;
     register int n;
{
  register GLYPH *gp = glyphs;
  register char *cp = str;

  while (n-- > 0)
    *gp++ = *cp++;
}

void
glyph_to_str_cpy (glyphs, str)
     GLYPH *glyphs;
     char *str;
{
  register GLYPH *gp = glyphs;
  register char *cp = str;

  while (*gp)
    *str++ = *gp++ & 0377;
}
#endif

/* Low level output routines for characters and strings */

/* Lisp functions to do output using a stream
   must have the stream in a variable called printcharfun
   and must start with PRINTPREPARE, end with PRINTFINISH,
   and use PRINTDECLARE to declare common variables.
   Use PRINTCHAR to output one character,
   or call strout to output a block of characters.
*/ 

#define PRINTDECLARE						\
   struct buffer *old = current_buffer;				\
   int old_point = -1, start_point;				\
   int old_point_byte, start_point_byte;			\
   int specpdl_count = specpdl_ptr - specpdl;			\
   int free_print_buffer = 0;					\
   Lisp_Object original

#define PRINTPREPARE						\
   original = printcharfun;					\
   if (NILP (printcharfun)) printcharfun = Qt;			\
   if (BUFFERP (printcharfun))					\
     {								\
       if (XBUFFER (printcharfun) != current_buffer)		\
	 Fset_buffer (printcharfun);				\
       printcharfun = Qnil;					\
     }								\
   if (MARKERP (printcharfun))					\
     {								\
       if (!(XMARKER (original)->buffer))			\
         error ("Marker does not point anywhere");		\
       if (XMARKER (original)->buffer != current_buffer)	\
         set_buffer_internal (XMARKER (original)->buffer);	\
       old_point = PT;						\
       old_point_byte = PT_BYTE;				\
       SET_PT_BOTH (marker_position (printcharfun),		\
		    marker_byte_position (printcharfun));	\
       start_point = PT;					\
       start_point_byte = PT_BYTE;				\
       printcharfun = Qnil;					\
     }								\
   if (NILP (printcharfun))					\
     {								\
       Lisp_Object string;					\
       if (NILP (current_buffer->enable_multibyte_characters)	\
	   && ! print_escape_multibyte)				\
         specbind (Qprint_escape_multibyte, Qt);		\
       if (! NILP (current_buffer->enable_multibyte_characters)	\
	   && ! print_escape_nonascii)				\
         specbind (Qprint_escape_nonascii, Qt);			\
       if (print_buffer != 0)					\
	 {							\
	   string = make_string_from_bytes (print_buffer,	\
					    print_buffer_pos,	\
					    print_buffer_pos_byte); \
	   record_unwind_protect (print_unwind, string);	\
	 }							\
       else							\
	 {							\
           print_buffer_size = 1000;				\
           print_buffer = (char *) xmalloc (print_buffer_size);	\
	   free_print_buffer = 1;				\
	 }							\
       print_buffer_pos = 0;					\
       print_buffer_pos_byte = 0;				\
     }								\
   if (!CONSP (Vprint_gensym))					\
     Vprint_gensym_alist = Qnil

#define PRINTFINISH							\
   if (NILP (printcharfun))						\
     {									\
       if (print_buffer_pos != print_buffer_pos_byte			\
	   && NILP (current_buffer->enable_multibyte_characters))	\
	 {								\
	   unsigned char *temp						\
	     = (unsigned char *) alloca (print_buffer_pos + 1);		\
	   copy_text (print_buffer, temp, print_buffer_pos_byte,	\
		      1, 0);						\
	   insert_1_both (temp, print_buffer_pos,			\
			  print_buffer_pos, 0, 1, 0);			\
	 }								\
       else								\
	 insert_1_both (print_buffer, print_buffer_pos,			\
			print_buffer_pos_byte, 0, 1, 0);		\
     }									\
   if (free_print_buffer)						\
     {									\
       xfree (print_buffer);						\
       print_buffer = 0;						\
     }									\
   unbind_to (specpdl_count, Qnil);					\
   if (MARKERP (original))						\
     set_marker_both (original, Qnil, PT, PT_BYTE);			\
   if (old_point >= 0)							\
     SET_PT_BOTH (old_point + (old_point >= start_point			\
			       ? PT - start_point : 0),			\
		  old_point_byte + (old_point_byte >= start_point_byte	\
			       ? PT_BYTE - start_point_byte : 0));	\
   if (old != current_buffer)						\
     set_buffer_internal (old);						\
   if (!CONSP (Vprint_gensym))						\
     Vprint_gensym_alist = Qnil

#define PRINTCHAR(ch) printchar (ch, printcharfun)

/* Nonzero if there is no room to print any more characters
   so print might as well return right away.  */

#define PRINTFULLP()					\
 (EQ (printcharfun, Qt) && !noninteractive		\
  && printbufidx >= FRAME_WIDTH (XFRAME (WINDOW_FRAME (XWINDOW (minibuf_window)))))

/* This is used to restore the saved contents of print_buffer
   when there is a recursive call to print.  */
static Lisp_Object
print_unwind (saved_text)
     Lisp_Object saved_text;
{
  bcopy (XSTRING (saved_text)->data, print_buffer, XSTRING (saved_text)->size);
}

/* Index of first unused element of FRAME_MESSAGE_BUF (mini_frame). */
static int printbufidx;

static void
printchar (ch, fun)
     unsigned int ch;
     Lisp_Object fun;
{
  Lisp_Object ch1;

#ifdef MAX_PRINT_CHARS
  if (max_print)
    print_chars++;
#endif /* MAX_PRINT_CHARS */
#ifndef standalone
  if (EQ (fun, Qnil))
    {
      int len;
      unsigned char work[4], *str;

      QUIT;
      len = CHAR_STRING (ch, work, str);
      if (print_buffer_pos_byte + len >= print_buffer_size)
	print_buffer = (char *) xrealloc (print_buffer,
					  print_buffer_size *= 2);
      bcopy (str, print_buffer + print_buffer_pos_byte, len);
      print_buffer_pos += 1;
      print_buffer_pos_byte += len;
      return;
    }

  if (EQ (fun, Qt))
    {
      FRAME_PTR mini_frame
	= XFRAME (WINDOW_FRAME (XWINDOW (minibuf_window)));
      unsigned char work[4], *str;
      int len = CHAR_STRING (ch, work, str);

      QUIT;

      if (noninteractive)
	{
	  while (len--)
	    putchar (*str), str++;
	  noninteractive_need_newline = 1;
	  return;
	}

      if (echo_area_glyphs != FRAME_MESSAGE_BUF (mini_frame)
	  || !message_buf_print)
	{
	  message_log_maybe_newline ();
	  echo_area_glyphs = FRAME_MESSAGE_BUF (mini_frame);
	  printbufidx = 0;
	  echo_area_glyphs_length = 0;
	  message_buf_print = 1;

	  if (minibuffer_auto_raise)
	    {
	      Lisp_Object mini_window;

	      /* Get the frame containing the minibuffer
		 that the selected frame is using.  */
	      mini_window = FRAME_MINIBUF_WINDOW (selected_frame);

	      Fraise_frame  (WINDOW_FRAME (XWINDOW (mini_window)));
	    }
	}

      if (len == 1
	  && ! NILP (current_buffer->enable_multibyte_characters)
	  && ! CHAR_HEAD_P (*str))
	{
	  /* Convert the unibyte character to multibyte.  */
	  unsigned char c = *str;

	  len = count_size_as_multibyte (&c, 1);
	  copy_text (&c, work, 1, 0, 1);
	  str = work;
	}

      message_dolog (str, len, 0, len > 1);

      if (! NILP (current_buffer->enable_multibyte_characters)
	  && ! message_enable_multibyte)
	{
	  /* Record that the message buffer is multibyte.  */
	  message_enable_multibyte = 1;

	  /* If we have already had some message text in the messsage
             buffer, we convert it to multibyte.  */
	  if (printbufidx > 0)
	    {
	      int size
		= count_size_as_multibyte (FRAME_MESSAGE_BUF (mini_frame),
					   printbufidx);
	      unsigned char *tembuf = (unsigned char *) alloca (size + 1);
	      copy_text (FRAME_MESSAGE_BUF (mini_frame), tembuf, printbufidx,
			 0, 1);
	      printbufidx = size;
	      if (printbufidx > FRAME_MESSAGE_BUF_SIZE (mini_frame))
		{
		  printbufidx = FRAME_MESSAGE_BUF_SIZE (mini_frame);
		  /* Rewind incomplete multi-byte form.  */
		  while (printbufidx > 0 && tembuf[printbufidx] >= 0xA0)
		    printbufidx--;
		}
	      bcopy (tembuf, FRAME_MESSAGE_BUF (mini_frame), printbufidx);
	    }
	}

      if (printbufidx < FRAME_MESSAGE_BUF_SIZE (mini_frame) - len)
	{
	  bcopy (str, &FRAME_MESSAGE_BUF (mini_frame)[printbufidx], len);
	  printbufidx += len;
	}
      FRAME_MESSAGE_BUF (mini_frame)[printbufidx] = 0;
      echo_area_glyphs_length = printbufidx;

      return;
    }
#endif /* not standalone */

  XSETFASTINT (ch1, ch);
  call1 (fun, ch1);
}

static void
strout (ptr, size, size_byte, printcharfun, multibyte)
     char *ptr;
     int size, size_byte;
     Lisp_Object printcharfun;
     int multibyte;
{
  int i = 0;

  if (size < 0)
    size_byte = size = strlen (ptr);

  if (EQ (printcharfun, Qnil))
    {
      if (print_buffer_pos_byte + size_byte > print_buffer_size)
	{
	  print_buffer_size = print_buffer_size * 2 + size_byte;
	  print_buffer = (char *) xrealloc (print_buffer,
					    print_buffer_size);
	}
      bcopy (ptr, print_buffer + print_buffer_pos_byte, size_byte);
      print_buffer_pos += size;
      print_buffer_pos_byte += size_byte;

#ifdef MAX_PRINT_CHARS
      if (max_print)
        print_chars += size;
#endif /* MAX_PRINT_CHARS */
      return;
    }
  if (EQ (printcharfun, Qt))
    {
      FRAME_PTR mini_frame
	= XFRAME (WINDOW_FRAME (XWINDOW (minibuf_window)));

      QUIT;

#ifdef MAX_PRINT_CHARS
      if (max_print)
        print_chars += size;
#endif /* MAX_PRINT_CHARS */

      if (noninteractive)
	{
	  fwrite (ptr, 1, size_byte, stdout);
	  noninteractive_need_newline = 1;
	  return;
	}

      if (echo_area_glyphs != FRAME_MESSAGE_BUF (mini_frame)
	  || !message_buf_print)
	{
	  message_log_maybe_newline ();
	  echo_area_glyphs = FRAME_MESSAGE_BUF (mini_frame);
	  printbufidx = 0;
	  echo_area_glyphs_length = 0;
	  message_buf_print = 1;

	  if (minibuffer_auto_raise)
	    {
	      Lisp_Object mini_window;

	      /* Get the frame containing the minibuffer
		 that the selected frame is using.  */
	      mini_window = FRAME_MINIBUF_WINDOW (selected_frame);

	      Fraise_frame  (WINDOW_FRAME (XWINDOW (mini_window)));
	    }
	}

      message_dolog (ptr, size_byte, 0, multibyte);

      /* Convert message to multibyte if we are now adding multibyte text.  */
      if (multibyte
	  && ! message_enable_multibyte
	  && printbufidx > 0)
	{
	  int size = count_size_as_multibyte (FRAME_MESSAGE_BUF (mini_frame),
					      printbufidx);
	  unsigned char *tembuf = (unsigned char *) alloca (size + 1);
	  copy_text (FRAME_MESSAGE_BUF (mini_frame), tembuf, printbufidx,
		     0, 1);
	  printbufidx = size;
	  if (printbufidx > FRAME_MESSAGE_BUF_SIZE (mini_frame))
	    {
	      printbufidx = FRAME_MESSAGE_BUF_SIZE (mini_frame);
	      /* Rewind incomplete multi-byte form.  */
	      while (printbufidx > 0 && tembuf[printbufidx] >= 0xA0)
		printbufidx--;
	    }

	  bcopy (tembuf, FRAME_MESSAGE_BUF (mini_frame), printbufidx);
	}

      if (multibyte)
	message_enable_multibyte = 1;

      /* Compute how much of the new text will fit there.  */
      if (size_byte > FRAME_MESSAGE_BUF_SIZE (mini_frame) - printbufidx - 1)
	{
	  size_byte = FRAME_MESSAGE_BUF_SIZE (mini_frame) - printbufidx - 1;
	  /* Rewind incomplete multi-byte form.  */
	  while (size_byte && (unsigned char) ptr[size_byte] >= 0xA0)
	    size_byte--;
	}

      /* Put that part of the new text in.  */
      bcopy (ptr, &FRAME_MESSAGE_BUF (mini_frame) [printbufidx], size_byte);
      printbufidx += size_byte;
      FRAME_MESSAGE_BUF (mini_frame) [printbufidx] = 0;
      echo_area_glyphs_length = printbufidx;

      return;
    }

  i = 0;
  if (size == size_byte)
    while (i < size_byte)
      {
	int ch = ptr[i++];

	PRINTCHAR (ch);
      }
  else
    while (i < size_byte)
      {
	/* Here, we must convert each multi-byte form to the
	   corresponding character code before handing it to PRINTCHAR.  */
	int len;
	int ch = STRING_CHAR_AND_LENGTH (ptr + i, size_byte - i, len);

	PRINTCHAR (ch);
	i += len;
      }
}

/* Print the contents of a string STRING using PRINTCHARFUN.
   It isn't safe to use strout in many cases,
   because printing one char can relocate.  */

static void
print_string (string, printcharfun)
     Lisp_Object string;
     Lisp_Object printcharfun;
{
  if (EQ (printcharfun, Qt) || NILP (printcharfun))
    {
      int chars;

      if (STRING_MULTIBYTE (string))
	chars = XSTRING (string)->size;
      else if (EQ (printcharfun, Qt)
	       ? ! NILP (buffer_defaults.enable_multibyte_characters)
	       : ! NILP (current_buffer->enable_multibyte_characters))
	chars = multibyte_chars_in_text (XSTRING (string)->data,
					 STRING_BYTES (XSTRING (string)));
      else
	chars = STRING_BYTES (XSTRING (string));

      /* strout is safe for output to a frame (echo area) or to print_buffer.  */
      strout (XSTRING (string)->data,
	      chars, STRING_BYTES (XSTRING (string)),
	      printcharfun, STRING_MULTIBYTE (string));
    }
  else
    {
      /* Otherwise, string may be relocated by printing one char.
	 So re-fetch the string address for each character.  */
      int i;
      int size = XSTRING (string)->size;
      int size_byte = STRING_BYTES (XSTRING (string));
      struct gcpro gcpro1;
      GCPRO1 (string);
      if (size == size_byte)
	for (i = 0; i < size; i++)
	  PRINTCHAR (XSTRING (string)->data[i]);
      else
	for (i = 0; i < size_byte; i++)
	  {
	    /* Here, we must convert each multi-byte form to the
	       corresponding character code before handing it to PRINTCHAR.  */
	    int len;
	    int ch = STRING_CHAR_AND_CHAR_LENGTH (XSTRING (string)->data + i,
						  size_byte - i, len);
	    if (!CHAR_VALID_P (ch, 0))
	      {
		ch = XSTRING (string)->data[i];
		len = 1;
	      }
	    PRINTCHAR (ch);
	    i += len;
	  }
      UNGCPRO;
    }
}

DEFUN ("write-char", Fwrite_char, Swrite_char, 1, 2, 0,
  "Output character CHARACTER to stream PRINTCHARFUN.\n\
PRINTCHARFUN defaults to the value of `standard-output' (which see).")
  (character, printcharfun)
     Lisp_Object character, printcharfun;
{
  PRINTDECLARE;

  if (NILP (printcharfun))
    printcharfun = Vstandard_output;
  CHECK_NUMBER (character, 0);
  PRINTPREPARE;
  PRINTCHAR (XINT (character));
  PRINTFINISH;
  return character;
}

/* Used from outside of print.c to print a block of SIZE
   single-byte chars at DATA on the default output stream.
   Do not use this on the contents of a Lisp string.  */

void
write_string (data, size)
     char *data;
     int size;
{
  PRINTDECLARE;
  Lisp_Object printcharfun;

  printcharfun = Vstandard_output;

  PRINTPREPARE;
  strout (data, size, size, printcharfun, 0);
  PRINTFINISH;
}

/* Used from outside of print.c to print a block of SIZE
   single-byte chars at DATA on a specified stream PRINTCHARFUN.
   Do not use this on the contents of a Lisp string.  */

void
write_string_1 (data, size, printcharfun)
     char *data;
     int size;
     Lisp_Object printcharfun;
{
  PRINTDECLARE;

  PRINTPREPARE;
  strout (data, size, size, printcharfun, 0);
  PRINTFINISH;
}


#ifndef standalone

void
temp_output_buffer_setup (bufname)
    char *bufname;
{
  int count = specpdl_ptr - specpdl;
  register struct buffer *old = current_buffer;
  register Lisp_Object buf;

  record_unwind_protect (set_buffer_if_live, Fcurrent_buffer ());

  Fset_buffer (Fget_buffer_create (build_string (bufname)));

  current_buffer->directory = old->directory;
  current_buffer->read_only = Qnil;
  current_buffer->filename = Qnil;
  current_buffer->undo_list = Qt;
  current_buffer->overlays_before = Qnil;
  current_buffer->overlays_after = Qnil;
  current_buffer->enable_multibyte_characters
    = buffer_defaults.enable_multibyte_characters;
  Ferase_buffer ();
  XSETBUFFER (buf, current_buffer);

  call1 (Vrun_hooks, Qtemp_buffer_setup_hook);

  unbind_to (count, Qnil);

  specbind (Qstandard_output, buf);
}

Lisp_Object
internal_with_output_to_temp_buffer (bufname, function, args)
     char *bufname;
     Lisp_Object (*function) P_ ((Lisp_Object));
     Lisp_Object args;
{
  int count = specpdl_ptr - specpdl;
  Lisp_Object buf, val;
  struct gcpro gcpro1;

  GCPRO1 (args);
  record_unwind_protect (Fset_buffer, Fcurrent_buffer ());
  temp_output_buffer_setup (bufname);
  buf = Vstandard_output;
  UNGCPRO;

  val = (*function) (args);

  GCPRO1 (val);
  temp_output_buffer_show (buf);
  UNGCPRO;

  return unbind_to (count, val);
}

DEFUN ("with-output-to-temp-buffer", Fwith_output_to_temp_buffer, Swith_output_to_temp_buffer,
       1, UNEVALLED, 0,
  "Bind `standard-output' to buffer BUFNAME, eval BODY, then show that buffer.\n\
The buffer is cleared out initially, and marked as unmodified when done.\n\
All output done by BODY is inserted in that buffer by default.\n\
The buffer is displayed in another window, but not selected.\n\
The value of the last form in BODY is returned.\n\
If BODY does not finish normally, the buffer BUFNAME is not displayed.\n\
\n\
The hook `temp-buffer-setup-hook' is run before BODY,\n\
with the buffer BUFNAME temporarily current.\n\
The hook `temp-buffer-show-hook' is run after the buffer is displayed,\n\
with the buffer temporarily current, and the window that was used\n\
to display it temporarily selected.\n\
\n\
If variable `temp-buffer-show-function' is non-nil, call it at the end\n\
to get the buffer displayed instead of just displaying the non-selected\n\
buffer and calling the hook.  It gets one argument, the buffer to display.")
  (args)
     Lisp_Object args;
{
  struct gcpro gcpro1;
  Lisp_Object name;
  int count = specpdl_ptr - specpdl;
  Lisp_Object buf, val;

  GCPRO1(args);
  name = Feval (Fcar (args));
  UNGCPRO;

  CHECK_STRING (name, 0);
  temp_output_buffer_setup (XSTRING (name)->data);
  buf = Vstandard_output;

  val = Fprogn (Fcdr (args));

  temp_output_buffer_show (buf);

  return unbind_to (count, val);
}
#endif /* not standalone */

static void print ();

DEFUN ("terpri", Fterpri, Sterpri, 0, 1, 0,
  "Output a newline to stream PRINTCHARFUN.\n\
If PRINTCHARFUN is omitted or nil, the value of `standard-output' is used.")
  (printcharfun)
     Lisp_Object printcharfun;
{
  PRINTDECLARE;

  if (NILP (printcharfun))
    printcharfun = Vstandard_output;
  PRINTPREPARE;
  PRINTCHAR ('\n');
  PRINTFINISH;
  return Qt;
}

DEFUN ("prin1", Fprin1, Sprin1, 1, 2, 0,
  "Output the printed representation of OBJECT, any Lisp object.\n\
Quoting characters are printed when needed to make output that `read'\n\
can handle, whenever this is possible.\n\
Output stream is PRINTCHARFUN, or value of `standard-output' (which see).")
  (object, printcharfun)
     Lisp_Object object, printcharfun;
{
  PRINTDECLARE;

#ifdef MAX_PRINT_CHARS
  max_print = 0;
#endif /* MAX_PRINT_CHARS */
  if (NILP (printcharfun))
    printcharfun = Vstandard_output;
  PRINTPREPARE;
  print_depth = 0;
  print (object, printcharfun, 1);
  PRINTFINISH;
  return object;
}

/* a buffer which is used to hold output being built by prin1-to-string */
Lisp_Object Vprin1_to_string_buffer;

DEFUN ("prin1-to-string", Fprin1_to_string, Sprin1_to_string, 1, 2, 0,
  "Return a string containing the printed representation of OBJECT,\n\
any Lisp object.  Quoting characters are used when needed to make output\n\
that `read' can handle, whenever this is possible, unless the optional\n\
second argument NOESCAPE is non-nil.")
  (object, noescape)
     Lisp_Object object, noescape;
{
  PRINTDECLARE;
  Lisp_Object printcharfun;
  struct gcpro gcpro1, gcpro2;
  Lisp_Object tem;

  /* Save and restore this--we are altering a buffer
     but we don't want to deactivate the mark just for that.
     No need for specbind, since errors deactivate the mark.  */
  tem = Vdeactivate_mark;
  GCPRO2 (object, tem);

  printcharfun = Vprin1_to_string_buffer;
  PRINTPREPARE;
  print_depth = 0;
  print (object, printcharfun, NILP (noescape));
  /* Make Vprin1_to_string_buffer be the default buffer after PRINTFINSH */
  PRINTFINISH;
  set_buffer_internal (XBUFFER (Vprin1_to_string_buffer));
  object = Fbuffer_string ();

  Ferase_buffer ();
  set_buffer_internal (old);

  Vdeactivate_mark = tem;
  UNGCPRO;

  return object;
}

DEFUN ("princ", Fprinc, Sprinc, 1, 2, 0,
  "Output the printed representation of OBJECT, any Lisp object.\n\
No quoting characters are used; no delimiters are printed around\n\
the contents of strings.\n\
Output stream is PRINTCHARFUN, or value of standard-output (which see).")
  (object, printcharfun)
     Lisp_Object object, printcharfun;
{
  PRINTDECLARE;

  if (NILP (printcharfun))
    printcharfun = Vstandard_output;
  PRINTPREPARE;
  print_depth = 0;
  print (object, printcharfun, 0);
  PRINTFINISH;
  return object;
}

DEFUN ("print", Fprint, Sprint, 1, 2, 0,
  "Output the printed representation of OBJECT, with newlines around it.\n\
Quoting characters are printed when needed to make output that `read'\n\
can handle, whenever this is possible.\n\
Output stream is PRINTCHARFUN, or value of `standard-output' (which see).")
  (object, printcharfun)
     Lisp_Object object, printcharfun;
{
  PRINTDECLARE;
  struct gcpro gcpro1;

#ifdef MAX_PRINT_CHARS
  print_chars = 0;
  max_print = MAX_PRINT_CHARS;
#endif /* MAX_PRINT_CHARS */
  if (NILP (printcharfun))
    printcharfun = Vstandard_output;
  GCPRO1 (object);
  PRINTPREPARE;
  print_depth = 0;
  PRINTCHAR ('\n');
  print (object, printcharfun, 1);
  PRINTCHAR ('\n');
  PRINTFINISH;
#ifdef MAX_PRINT_CHARS
  max_print = 0;
  print_chars = 0;
#endif /* MAX_PRINT_CHARS */
  UNGCPRO;
  return object;
}

/* The subroutine object for external-debugging-output is kept here
   for the convenience of the debugger.  */
Lisp_Object Qexternal_debugging_output;

DEFUN ("external-debugging-output", Fexternal_debugging_output, Sexternal_debugging_output, 1, 1, 0,
  "Write CHARACTER to stderr.\n\
You can call print while debugging emacs, and pass it this function\n\
to make it write to the debugging output.\n")
  (character)
     Lisp_Object character;
{
  CHECK_NUMBER (character, 0);
  putc (XINT (character), stderr);

#ifdef WINDOWSNT
  /* Send the output to a debugger (nothing happens if there isn't one).  */
  {
    char buf[2] = {(char) XINT (character), '\0'};
    OutputDebugString (buf);
  }
#endif

  return character;
}

/* This is the interface for debugging printing.  */

void
debug_print (arg)
     Lisp_Object arg;
{
  Fprin1 (arg, Qexternal_debugging_output);
  fprintf (stderr, "\r\n");
}

DEFUN ("error-message-string", Ferror_message_string, Serror_message_string,
       1, 1, 0,
  "Convert an error value (ERROR-SYMBOL . DATA) to an error message.")
  (obj)
     Lisp_Object obj;
{
  struct buffer *old = current_buffer;
  Lisp_Object original, printcharfun, value;
  struct gcpro gcpro1;

  /* If OBJ is (error STRING), just return STRING.
     That is not only faster, it also avoids the need to allocate
     space here when the error is due to memory full.  */
  if (CONSP (obj) && EQ (XCONS (obj)->car, Qerror)
      && CONSP (XCONS (obj)->cdr)
      && STRINGP (XCONS (XCONS (obj)->cdr)->car)
      && NILP (XCONS (XCONS (obj)->cdr)->cdr))
    return XCONS (XCONS (obj)->cdr)->car;

  print_error_message (obj, Vprin1_to_string_buffer);

  set_buffer_internal (XBUFFER (Vprin1_to_string_buffer));
  value = Fbuffer_string ();

  GCPRO1 (value);
  Ferase_buffer ();
  set_buffer_internal (old);
  UNGCPRO;

  return value;
}

/* Print an error message for the error DATA
   onto Lisp output stream STREAM (suitable for the print functions).  */

void
print_error_message (data, stream)
     Lisp_Object data, stream;
{
  Lisp_Object errname, errmsg, file_error, tail;
  struct gcpro gcpro1;
  int i;

  errname = Fcar (data);

  if (EQ (errname, Qerror))
    {
      data = Fcdr (data);
      if (!CONSP (data)) data = Qnil;
      errmsg = Fcar (data);
      file_error = Qnil;
    }
  else
    {
      errmsg = Fget (errname, Qerror_message);
      file_error = Fmemq (Qfile_error,
			  Fget (errname, Qerror_conditions));
    }

  /* Print an error message including the data items.  */

  tail = Fcdr_safe (data);
  GCPRO1 (tail);

  /* For file-error, make error message by concatenating
     all the data items.  They are all strings.  */
  if (!NILP (file_error) && CONSP (tail))
    errmsg = XCONS (tail)->car, tail = XCONS (tail)->cdr;

  if (STRINGP (errmsg))
    Fprinc (errmsg, stream);
  else
    write_string_1 ("peculiar error", -1, stream);

  for (i = 0; CONSP (tail); tail = Fcdr (tail), i++)
    {
      write_string_1 (i ? ", " : ": ", 2, stream);
      if (!NILP (file_error))
	Fprinc (Fcar (tail), stream);
      else
	Fprin1 (Fcar (tail), stream);
    }
  UNGCPRO;
}

#ifdef LISP_FLOAT_TYPE

/*
 * The buffer should be at least as large as the max string size of the
 * largest float, printed in the biggest notation.  This is undoubtedly
 * 20d float_output_format, with the negative of the C-constant "HUGE"
 * from <math.h>.
 * 
 * On the vax the worst case is -1e38 in 20d format which takes 61 bytes.
 * 
 * I assume that IEEE-754 format numbers can take 329 bytes for the worst
 * case of -1e307 in 20d float_output_format. What is one to do (short of
 * re-writing _doprnt to be more sane)?
 * 			-wsr
 */

void
float_to_string (buf, data)
     unsigned char *buf;
     double data;
{
  unsigned char *cp;
  int width;
      
  /* Check for plus infinity in a way that won't lose
     if there is no plus infinity.  */
  if (data == data / 2 && data > 1.0)
    {
      strcpy (buf, "1.0e+INF");
      return;
    }
  /* Likewise for minus infinity.  */
  if (data == data / 2 && data < -1.0)
    {
      strcpy (buf, "-1.0e+INF");
      return;
    }
  /* Check for NaN in a way that won't fail if there are no NaNs.  */
  if (! (data * 0.0 >= 0.0))
    {
      strcpy (buf, "0.0e+NaN");
      return;
    }

  if (NILP (Vfloat_output_format)
      || !STRINGP (Vfloat_output_format))
  lose:
    {
      /* Generate the fewest number of digits that represent the
	 floating point value without losing information.
	 The following method is simple but a bit slow.
	 For ideas about speeding things up, please see:

	 Guy L Steele Jr & Jon L White, How to print floating-point numbers
	 accurately.  SIGPLAN notices 25, 6 (June 1990), 112-126.

	 Robert G Burger & R Kent Dybvig, Printing floating point numbers
	 quickly and accurately, SIGPLAN notices 31, 5 (May 1996), 108-116.  */

      width = fabs (data) < DBL_MIN ? 1 : DBL_DIG;
      do
	sprintf (buf, "%.*g", width, data);
      while (width++ < DOUBLE_DIGITS_BOUND && atof (buf) != data);
    }
  else			/* oink oink */
    {
      /* Check that the spec we have is fully valid.
	 This means not only valid for printf,
	 but meant for floats, and reasonable.  */
      cp = XSTRING (Vfloat_output_format)->data;

      if (cp[0] != '%')
	goto lose;
      if (cp[1] != '.')
	goto lose;

      cp += 2;

      /* Check the width specification.  */
      width = -1;
      if ('0' <= *cp && *cp <= '9')
	{
	  width = 0;
	  do
	    width = (width * 10) + (*cp++ - '0');
	  while (*cp >= '0' && *cp <= '9');

	  /* A precision of zero is valid only for %f.  */
	  if (width > DBL_DIG
	      || (width == 0 && *cp != 'f'))
	    goto lose;
	}

      if (*cp != 'e' && *cp != 'f' && *cp != 'g')
	goto lose;

      if (cp[1] != 0)
	goto lose;

      sprintf (buf, XSTRING (Vfloat_output_format)->data, data);
    }

  /* Make sure there is a decimal point with digit after, or an
     exponent, so that the value is readable as a float.  But don't do
     this with "%.0f"; it's valid for that not to produce a decimal
     point.  Note that width can be 0 only for %.0f.  */
  if (width != 0)
    {
      for (cp = buf; *cp; cp++)
	if ((*cp < '0' || *cp > '9') && *cp != '-')
	  break;

      if (*cp == '.' && cp[1] == 0)
	{
	  cp[1] = '0';
	  cp[2] = 0;
	}

      if (*cp == 0)
	{
	  *cp++ = '.';
	  *cp++ = '0';
	  *cp++ = 0;
	}
    }
}
#endif /* LISP_FLOAT_TYPE */

static void
print (obj, printcharfun, escapeflag)
     Lisp_Object obj;
     register Lisp_Object printcharfun;
     int escapeflag;
{
  char buf[30];

  QUIT;

#if 1  /* I'm not sure this is really worth doing.  */
  /* Detect circularities and truncate them.
     No need to offer any alternative--this is better than an error.  */
  if (CONSP (obj) || VECTORP (obj) || COMPILEDP (obj))
    {
      int i;
      for (i = 0; i < print_depth; i++)
	if (EQ (obj, being_printed[i]))
	  {
	    sprintf (buf, "#%d", i);
	    strout (buf, -1, -1, printcharfun, 0);
	    return;
	  }
    }
#endif

  being_printed[print_depth] = obj;
  print_depth++;

  if (print_depth > PRINT_CIRCLE)
    error ("Apparently circular structure being printed");
#ifdef MAX_PRINT_CHARS
  if (max_print && print_chars > max_print)
    {
      PRINTCHAR ('\n');
      print_chars = 0;
    }
#endif /* MAX_PRINT_CHARS */

  switch (XGCTYPE (obj))
    {
    case Lisp_Int:
      if (sizeof (int) == sizeof (EMACS_INT))
	sprintf (buf, "%d", XINT (obj));
      else if (sizeof (long) == sizeof (EMACS_INT))
	sprintf (buf, "%ld", XINT (obj));
      else
	abort ();
      strout (buf, -1, -1, printcharfun, 0);
      break;

#ifdef LISP_FLOAT_TYPE
    case Lisp_Float:
      {
	char pigbuf[350];	/* see comments in float_to_string */

	float_to_string (pigbuf, XFLOAT(obj)->data);
	strout (pigbuf, -1, -1, printcharfun, 0);
      }
      break;
#endif

    case Lisp_String:
      if (!escapeflag)
	print_string (obj, printcharfun);
      else
	{
	  register int i, i_byte;
	  register unsigned char c;
	  struct gcpro gcpro1;
	  unsigned char *str;
	  int size_byte;
	  /* 1 means we must ensure that the next character we output
	     cannot be taken as part of a hex character escape.  */
	  int need_nonhex = 0;

	  GCPRO1 (obj);

#ifdef USE_TEXT_PROPERTIES
	  if (!NULL_INTERVAL_P (XSTRING (obj)->intervals))
	    {
	      PRINTCHAR ('#');
	      PRINTCHAR ('(');
	    }
#endif

	  PRINTCHAR ('\"');
	  str = XSTRING (obj)->data;
	  size_byte = STRING_BYTES (XSTRING (obj));

	  for (i = 0, i_byte = 0; i_byte < size_byte;)
	    {
	      /* Here, we must convert each multi-byte form to the
		 corresponding character code before handing it to PRINTCHAR.  */
	      int len;
	      int c;

	      if (STRING_MULTIBYTE (obj))
		{
		  c = STRING_CHAR_AND_CHAR_LENGTH (str + i_byte,
						   size_byte - i_byte, len);
		  if (CHAR_VALID_P (c, 0))
		    i_byte += len;
		  else
		    c = str[i_byte++];
		}
	      else
		c = str[i_byte++];

	      QUIT;

	      if (c == '\n' && print_escape_newlines)
		{
		  PRINTCHAR ('\\');
		  PRINTCHAR ('n');
		}
	      else if (c == '\f' && print_escape_newlines)
		{
		  PRINTCHAR ('\\');
		  PRINTCHAR ('f');
		}
	      else if (! SINGLE_BYTE_CHAR_P (c) && print_escape_multibyte)
		{
		  /* When multibyte is disabled,
		     print multibyte string chars using hex escapes.  */
		  unsigned char outbuf[50];
		  sprintf (outbuf, "\\x%x", c);
		  strout (outbuf, -1, -1, printcharfun, 0);
		  need_nonhex = 1;
		}
	      else if (SINGLE_BYTE_CHAR_P (c) && ! ASCII_BYTE_P (c)
		       && print_escape_nonascii)
		{
		  /* When printing in a multibyte buffer
		     or when explicitly requested,
		     print single-byte non-ASCII string chars
		     using octal escapes.  */
		  unsigned char outbuf[5];
		  sprintf (outbuf, "\\%03o", c);
		  strout (outbuf, -1, -1, printcharfun, 0);
		}
	      else
		{
		  /* If we just had a hex escape, and this character
		     could be taken as part of it,
		     output `\ ' to prevent that.  */
		  if (need_nonhex)
		    {
		      need_nonhex = 0;
		      if ((c >= 'a' && c <= 'f')
			  || (c >= 'A' && c <= 'F')
			  || (c >= '0' && c <= '9'))
			strout ("\\ ", -1, -1, printcharfun, 0);
		    }

		  if (c == '\"' || c == '\\')
		    PRINTCHAR ('\\');
		  PRINTCHAR (c);
		}
	    }
	  PRINTCHAR ('\"');

#ifdef USE_TEXT_PROPERTIES
	  if (!NULL_INTERVAL_P (XSTRING (obj)->intervals))
	    {
	      traverse_intervals (XSTRING (obj)->intervals,
				  0, 0, print_interval, printcharfun);
	      PRINTCHAR (')');
	    }
#endif

	  UNGCPRO;
	}
      break;

    case Lisp_Symbol:
      {
	register int confusing;
	register unsigned char *p = XSYMBOL (obj)->name->data;
	register unsigned char *end = p + STRING_BYTES (XSYMBOL (obj)->name);
	register int c;
	int i, i_byte, size_byte;
	Lisp_Object name;

	XSETSTRING (name, XSYMBOL (obj)->name);

	if (p != end && (*p == '-' || *p == '+')) p++;
	if (p == end)
	  confusing = 0;
	/* If symbol name begins with a digit, and ends with a digit,
	   and contains nothing but digits and `e', it could be treated
	   as a number.  So set CONFUSING.

	   Symbols that contain periods could also be taken as numbers,
	   but periods are always escaped, so we don't have to worry
	   about them here.  */
	else if (*p >= '0' && *p <= '9'
		 && end[-1] >= '0' && end[-1] <= '9')
	  {
	    while (p != end && ((*p >= '0' && *p <= '9')
				/* Needed for \2e10.  */
				|| *p == 'e'))
	      p++;
	    confusing = (end == p);
	  }
	else
	  confusing = 0;

	/* If we print an uninterned symbol as part of a complex object and
	   the flag print-gensym is non-nil, prefix it with #n= to read the
	   object back with the #n# reader syntax later if needed.  */
	if (! NILP (Vprint_gensym) && NILP (XSYMBOL (obj)->obarray))
	  {
	    if (print_depth > 1)
	      {
		Lisp_Object tem;
		tem = Fassq (obj, Vprint_gensym_alist);
		if (CONSP (tem))
		  {
		    PRINTCHAR ('#');
		    print (XCDR (tem), printcharfun, escapeflag);
		    PRINTCHAR ('#');
		    break;
		  }
		else
		  {
		    if (CONSP (Vprint_gensym_alist))
		      XSETFASTINT (tem, XFASTINT (XCDR (XCAR (Vprint_gensym_alist))) + 1);
		    else
		      XSETFASTINT (tem, 1);
		    Vprint_gensym_alist = Fcons (Fcons (obj, tem), Vprint_gensym_alist);

		    PRINTCHAR ('#');
		    print (tem, printcharfun, escapeflag);
		    PRINTCHAR ('=');
		  }
	      }
	    PRINTCHAR ('#');
	    PRINTCHAR (':');
	  }

	size_byte = STRING_BYTES (XSTRING (name));

	for (i = 0, i_byte = 0; i_byte < size_byte;)
	  {
	    /* Here, we must convert each multi-byte form to the
	       corresponding character code before handing it to PRINTCHAR.  */

	    if (STRING_MULTIBYTE (name))
	      FETCH_STRING_CHAR_ADVANCE (c, name, i, i_byte);
	    else
	      c = XSTRING (name)->data[i_byte++];

	    QUIT;

	    if (escapeflag)
	      {
		if (c == '\"' || c == '\\' || c == '\''
		    || c == ';' || c == '#' || c == '(' || c == ')'
		    || c == ',' || c =='.' || c == '`'
		    || c == '[' || c == ']' || c == '?' || c <= 040
		    || confusing)
		  PRINTCHAR ('\\'), confusing = 0;
	      }
	    PRINTCHAR (c);
	  }
      }
      break;

    case Lisp_Cons:
      /* If deeper than spec'd depth, print placeholder.  */
      if (INTEGERP (Vprint_level)
	  && print_depth > XINT (Vprint_level))
	strout ("...", -1, -1, printcharfun, 0);
      else if (print_quoted && CONSP (XCDR (obj)) && NILP (XCDR (XCDR (obj)))
	       && (EQ (XCAR (obj), Qquote)))
	{
	  PRINTCHAR ('\'');
	  print (XCAR (XCDR (obj)), printcharfun, escapeflag);
	}
      else if (print_quoted && CONSP (XCDR (obj)) && NILP (XCDR (XCDR (obj)))
	       && (EQ (XCAR (obj), Qfunction)))
	{
	  PRINTCHAR ('#');
	  PRINTCHAR ('\'');
	  print (XCAR (XCDR (obj)), printcharfun, escapeflag);
	}
      else if (print_quoted && CONSP (XCDR (obj)) && NILP (XCDR (XCDR (obj)))
	       && ((EQ (XCAR (obj), Qbackquote)
		    || EQ (XCAR (obj), Qcomma)
		    || EQ (XCAR (obj), Qcomma_at)
		    || EQ (XCAR (obj), Qcomma_dot))))
	{
	  print (XCAR (obj), printcharfun, 0);
	  print (XCAR (XCDR (obj)), printcharfun, escapeflag);
	}
      else
	{
	  PRINTCHAR ('(');
	  {
	    register int i = 0;
	    register int print_length = 0;
	    Lisp_Object halftail = obj;

	    if (INTEGERP (Vprint_length))
	      print_length = XINT (Vprint_length);
	    while (CONSP (obj))
	      {
		/* Detect circular list.  */
		if (i != 0 && EQ (obj, halftail))
		  {
		    sprintf (buf, " . #%d", i / 2);
		    strout (buf, -1, -1, printcharfun, 0);
		    obj = Qnil;
		    break;
		  }
		if (i++)
		  PRINTCHAR (' ');
		if (print_length && i > print_length)
		  {
		    strout ("...", 3, 3, printcharfun, 0);
		    break;
		  }
		print (XCAR (obj), printcharfun, escapeflag);
		obj = XCDR (obj);
		if (!(i & 1))
		  halftail = XCDR (halftail);
	      }
	  }
	  if (!NILP (obj))
	    {
	      strout (" . ", 3, 3, printcharfun, 0);
	      print (obj, printcharfun, escapeflag);
	    }
	  PRINTCHAR (')');
	}
      break;

    case Lisp_Vectorlike:
      if (PROCESSP (obj))
	{
	  if (escapeflag)
	    {
	      strout ("#<process ", -1, -1, printcharfun, 0);
	      print_string (XPROCESS (obj)->name, printcharfun);
	      PRINTCHAR ('>');
	    }
	  else
	    print_string (XPROCESS (obj)->name, printcharfun);
	}
      else if (BOOL_VECTOR_P (obj))
	{
	  register int i;
	  register unsigned char c;
	  struct gcpro gcpro1;
	  int size_in_chars
	    = (XBOOL_VECTOR (obj)->size + BITS_PER_CHAR - 1) / BITS_PER_CHAR;

	  GCPRO1 (obj);

	  PRINTCHAR ('#');
	  PRINTCHAR ('&');
	  sprintf (buf, "%d", XBOOL_VECTOR (obj)->size);
	  strout (buf, -1, -1, printcharfun, 0);
	  PRINTCHAR ('\"');

	  /* Don't print more characters than the specified maximum.  */
	  if (INTEGERP (Vprint_length)
	      && XINT (Vprint_length) < size_in_chars)
	    size_in_chars = XINT (Vprint_length);

	  for (i = 0; i < size_in_chars; i++)
	    {
	      QUIT;
	      c = XBOOL_VECTOR (obj)->data[i];
	      if (c == '\n' && print_escape_newlines)
		{
		  PRINTCHAR ('\\');
		  PRINTCHAR ('n');
		}
	      else if (c == '\f' && print_escape_newlines)
		{
		  PRINTCHAR ('\\');
		  PRINTCHAR ('f');
		}
	      else
		{
		  if (c == '\"' || c == '\\')
		    PRINTCHAR ('\\');
		  PRINTCHAR (c);
		}
	    }
	  PRINTCHAR ('\"');

	  UNGCPRO;
	}
      else if (SUBRP (obj))
	{
	  strout ("#<subr ", -1, -1, printcharfun, 0);
	  strout (XSUBR (obj)->symbol_name, -1, -1, printcharfun, 0);
	  PRINTCHAR ('>');
	}
#ifndef standalone
      else if (WINDOWP (obj))
	{
	  strout ("#<window ", -1, -1, printcharfun, 0);
	  sprintf (buf, "%d", XFASTINT (XWINDOW (obj)->sequence_number));
	  strout (buf, -1, -1, printcharfun, 0);
	  if (!NILP (XWINDOW (obj)->buffer))
	    {
	      strout (" on ", -1, -1, printcharfun, 0);
	      print_string (XBUFFER (XWINDOW (obj)->buffer)->name, printcharfun);
	    }
	  PRINTCHAR ('>');
	}
      else if (BUFFERP (obj))
	{
	  if (NILP (XBUFFER (obj)->name))
	    strout ("#<killed buffer>", -1, -1, printcharfun, 0);
	  else if (escapeflag)
	    {
	      strout ("#<buffer ", -1, -1, printcharfun, 0);
	      print_string (XBUFFER (obj)->name, printcharfun);
	      PRINTCHAR ('>');
	    }
	  else
	    print_string (XBUFFER (obj)->name, printcharfun);
	}
      else if (WINDOW_CONFIGURATIONP (obj))
	{
	  strout ("#<window-configuration>", -1, -1, printcharfun, 0);
	}
      else if (FRAMEP (obj))
	{
	  strout ((FRAME_LIVE_P (XFRAME (obj))
		   ? "#<frame " : "#<dead frame "),
		  -1, -1, printcharfun, 0);
	  print_string (XFRAME (obj)->name, printcharfun);
	  sprintf (buf, " 0x%lx\\ ", (unsigned long) (XFRAME (obj)));
	  strout (buf, -1, -1, printcharfun, 0);
	  PRINTCHAR ('>');
	}
#endif /* not standalone */
      else
	{
	  int size = XVECTOR (obj)->size;
	  if (COMPILEDP (obj))
	    {
	      PRINTCHAR ('#');
	      size &= PSEUDOVECTOR_SIZE_MASK;
	    }
	  if (CHAR_TABLE_P (obj))
	    {
	      /* We print a char-table as if it were a vector,
		 lumping the parent and default slots in with the
		 character slots.  But we add #^ as a prefix.  */
	      PRINTCHAR ('#');
	      PRINTCHAR ('^');
	      if (SUB_CHAR_TABLE_P (obj))
		PRINTCHAR ('^');
	      size &= PSEUDOVECTOR_SIZE_MASK;
	    }
	  if (size & PSEUDOVECTOR_FLAG)
	    goto badtype;

	  PRINTCHAR ('[');
	  {
	    register int i;
	    register Lisp_Object tem;

	    /* Don't print more elements than the specified maximum.  */
	    if (INTEGERP (Vprint_length)
		&& XINT (Vprint_length) < size)
	      size = XINT (Vprint_length);

	    for (i = 0; i < size; i++)
	      {
		if (i) PRINTCHAR (' ');
		tem = XVECTOR (obj)->contents[i];
		print (tem, printcharfun, escapeflag);
	      }
	  }
	  PRINTCHAR (']');
	}
      break;

#ifndef standalone
    case Lisp_Misc:
      switch (XMISCTYPE (obj))
	{
	case Lisp_Misc_Marker:
	  strout ("#<marker ", -1, -1, printcharfun, 0);
	  /* Do you think this is necessary?  */
	  if (XMARKER (obj)->insertion_type != 0)
	    strout ("(before-insertion) ", -1, -1, printcharfun, 0);
	  if (!(XMARKER (obj)->buffer))
	    strout ("in no buffer", -1, -1, printcharfun, 0);
	  else
	    {
	      sprintf (buf, "at %d", marker_position (obj));
	      strout (buf, -1, -1, printcharfun, 0);
	      strout (" in ", -1, -1, printcharfun, 0);
	      print_string (XMARKER (obj)->buffer->name, printcharfun);
	    }
	  PRINTCHAR ('>');
	  break;

	case Lisp_Misc_Overlay:
	  strout ("#<overlay ", -1, -1, printcharfun, 0);
	  if (!(XMARKER (OVERLAY_START (obj))->buffer))
	    strout ("in no buffer", -1, -1, printcharfun, 0);
	  else
	    {
	      sprintf (buf, "from %d to %d in ",
		       marker_position (OVERLAY_START (obj)),
		       marker_position (OVERLAY_END   (obj)));
	      strout (buf, -1, -1, printcharfun, 0);
	      print_string (XMARKER (OVERLAY_START (obj))->buffer->name,
			    printcharfun);
	    }
	  PRINTCHAR ('>');
	  break;

      /* Remaining cases shouldn't happen in normal usage, but let's print
	 them anyway for the benefit of the debugger.  */
	case Lisp_Misc_Free:
	  strout ("#<misc free cell>", -1, -1, printcharfun, 0);
	  break;

	case Lisp_Misc_Intfwd:
	  sprintf (buf, "#<intfwd to %d>", *XINTFWD (obj)->intvar);
	  strout (buf, -1, -1, printcharfun, 0);
	  break;

	case Lisp_Misc_Boolfwd:
	  sprintf (buf, "#<boolfwd to %s>",
		   (*XBOOLFWD (obj)->boolvar ? "t" : "nil"));
	  strout (buf, -1, -1, printcharfun, 0);
	  break;

	case Lisp_Misc_Objfwd:
	  strout ("#<objfwd to ", -1, -1, printcharfun, 0);
	  print (*XOBJFWD (obj)->objvar, printcharfun, escapeflag);
	  PRINTCHAR ('>');
	  break;

	case Lisp_Misc_Buffer_Objfwd:
	  strout ("#<buffer_objfwd to ", -1, -1, printcharfun, 0);
	  print (*(Lisp_Object *)((char *)current_buffer
				  + XBUFFER_OBJFWD (obj)->offset),
		 printcharfun, escapeflag);
	  PRINTCHAR ('>');
	  break;

	case Lisp_Misc_Kboard_Objfwd:
	  strout ("#<kboard_objfwd to ", -1, -1, printcharfun, 0);
	  print (*(Lisp_Object *)((char *) current_kboard
				  + XKBOARD_OBJFWD (obj)->offset),
		 printcharfun, escapeflag);
	  PRINTCHAR ('>');
	  break;

	case Lisp_Misc_Buffer_Local_Value:
	  strout ("#<buffer_local_value ", -1, -1, printcharfun, 0);
	  goto do_buffer_local;
	case Lisp_Misc_Some_Buffer_Local_Value:
	  strout ("#<some_buffer_local_value ", -1, -1, printcharfun, 0);
	do_buffer_local:
	  strout ("[realvalue] ", -1, -1, printcharfun, 0);
	  print (XBUFFER_LOCAL_VALUE (obj)->realvalue, printcharfun, escapeflag);
	  if (XBUFFER_LOCAL_VALUE (obj)->found_for_buffer)
	    strout ("[local in buffer] ", -1, -1, printcharfun, 0);
	  else
	    strout ("[buffer] ", -1, -1, printcharfun, 0);
	  print (XBUFFER_LOCAL_VALUE (obj)->buffer,
		 printcharfun, escapeflag);
	  if (XBUFFER_LOCAL_VALUE (obj)->check_frame)
	    {
	      if (XBUFFER_LOCAL_VALUE (obj)->found_for_frame)
		strout ("[local in frame] ", -1, -1, printcharfun, 0);
	      else
		strout ("[frame] ", -1, -1, printcharfun, 0);
	      print (XBUFFER_LOCAL_VALUE (obj)->frame,
		     printcharfun, escapeflag);
	    }
	  strout ("[alist-elt] ", -1, -1, printcharfun, 0);
	  print (XCONS (XBUFFER_LOCAL_VALUE (obj)->cdr)->car,
		 printcharfun, escapeflag);
	  strout ("[default-value] ", -1, -1, printcharfun, 0);
	  print (XCONS (XBUFFER_LOCAL_VALUE (obj)->cdr)->cdr,
		 printcharfun, escapeflag);
	  PRINTCHAR ('>');
	  break;

	default:
	  goto badtype;
	}
      break;
#endif /* standalone */

    default:
    badtype:
      {
	/* We're in trouble if this happens!
	   Probably should just abort () */
	strout ("#<EMACS BUG: INVALID DATATYPE ", -1, -1, printcharfun, 0);
	if (MISCP (obj))
	  sprintf (buf, "(MISC 0x%04x)", (int) XMISCTYPE (obj));
	else if (VECTORLIKEP (obj))
	  sprintf (buf, "(PVEC 0x%08x)", (int) XVECTOR (obj)->size);
	else
	  sprintf (buf, "(0x%02x)", (int) XTYPE (obj));
	strout (buf, -1, -1, printcharfun, 0);
	strout (" Save your buffers immediately and please report this bug>",
		-1, -1, printcharfun, 0);
      }
    }

  print_depth--;
}

#ifdef USE_TEXT_PROPERTIES

/* Print a description of INTERVAL using PRINTCHARFUN.
   This is part of printing a string that has text properties.  */

void
print_interval (interval, printcharfun)
     INTERVAL interval;
     Lisp_Object printcharfun;
{
  PRINTCHAR (' ');
  print (make_number (interval->position), printcharfun, 1);
  PRINTCHAR (' ');
  print (make_number (interval->position + LENGTH (interval)),
	 printcharfun, 1);
  PRINTCHAR (' ');
  print (interval->plist, printcharfun, 1);
}

#endif /* USE_TEXT_PROPERTIES */

void
syms_of_print ()
{
  Qtemp_buffer_setup_hook = intern ("temp-buffer-setup-hook");
  staticpro (&Qtemp_buffer_setup_hook);

  DEFVAR_LISP ("standard-output", &Vstandard_output,
    "Output stream `print' uses by default for outputting a character.\n\
This may be any function of one argument.\n\
It may also be a buffer (output is inserted before point)\n\
or a marker (output is inserted and the marker is advanced)\n\
or the symbol t (output appears in the echo area).");
  Vstandard_output = Qt;
  Qstandard_output = intern ("standard-output");
  staticpro (&Qstandard_output);

#ifdef LISP_FLOAT_TYPE
  DEFVAR_LISP ("float-output-format", &Vfloat_output_format,
    "The format descriptor string used to print floats.\n\
This is a %-spec like those accepted by `printf' in C,\n\
but with some restrictions.  It must start with the two characters `%.'.\n\
After that comes an integer precision specification,\n\
and then a letter which controls the format.\n\
The letters allowed are `e', `f' and `g'.\n\
Use `e' for exponential notation \"DIG.DIGITSeEXPT\"\n\
Use `f' for decimal point notation \"DIGITS.DIGITS\".\n\
Use `g' to choose the shorter of those two formats for the number at hand.\n\
The precision in any of these cases is the number of digits following\n\
the decimal point.  With `f', a precision of 0 means to omit the\n\
decimal point.  0 is not allowed with `e' or `g'.\n\n\
A value of nil means to use the shortest notation\n\
that represents the number without losing information.");
  Vfloat_output_format = Qnil;
  Qfloat_output_format = intern ("float-output-format");
  staticpro (&Qfloat_output_format);
#endif /* LISP_FLOAT_TYPE */

  DEFVAR_LISP ("print-length", &Vprint_length,
    "Maximum length of list to print before abbreviating.\n\
A value of nil means no limit.");
  Vprint_length = Qnil;

  DEFVAR_LISP ("print-level", &Vprint_level,
    "Maximum depth of list nesting to print before abbreviating.\n\
A value of nil means no limit.");
  Vprint_level = Qnil;

  DEFVAR_BOOL ("print-escape-newlines", &print_escape_newlines,
    "Non-nil means print newlines in strings as backslash-n.\n\
Also print formfeeds as backslash-f.");
  print_escape_newlines = 0;

  DEFVAR_BOOL ("print-escape-nonascii", &print_escape_nonascii,
    "Non-nil means print unibyte non-ASCII chars in strings as \\OOO.\n\
\(OOO is the octal representation of the character code.)\n\
Only single-byte characters are affected, and only in `prin1'.");
  print_escape_nonascii = 0;

  DEFVAR_BOOL ("print-escape-multibyte", &print_escape_multibyte,
    "Non-nil means print multibyte characters in strings as \\xXXXX.\n\
\(XXX is the hex representation of the character code.)\n\
This affects only `prin1'.");
  print_escape_multibyte = 0;

  DEFVAR_BOOL ("print-quoted", &print_quoted,
    "Non-nil means print quoted forms with reader syntax.\n\
I.e., (quote foo) prints as 'foo, (function foo) as #'foo, and, backquoted\n\
forms print in the new syntax.");
  print_quoted = 0;

  DEFVAR_LISP ("print-gensym", &Vprint_gensym,
    "Non-nil means print uninterned symbols so they will read as uninterned.\n\
I.e., the value of (make-symbol \"foobar\") prints as #:foobar.\n\
When the uninterned symbol appears within a larger data structure,\n\
in addition use the #...# and #...= constructs as needed,\n\
so that multiple references to the same symbol are shared once again\n\
when the text is read back.\n\
\n\
If the value of `print-gensym' is a cons cell, then in addition refrain from\n\
clearing `print-gensym-alist' on entry to and exit from printing functions,\n\
so that the use of #...# and #...= can carry over for several separately\n\
printed objects.");
  Vprint_gensym = Qnil;

  DEFVAR_LISP ("print-gensym-alist", &Vprint_gensym_alist,
    "Association list of elements (GENSYM . N) to guide use of #N# and #N=.\n\
In each element, GENSYM is an uninterned symbol that has been associated\n\
with #N= for the specified value of N.");
  Vprint_gensym_alist = Qnil;

  /* prin1_to_string_buffer initialized in init_buffer_once in buffer.c */
  staticpro (&Vprin1_to_string_buffer);

  defsubr (&Sprin1);
  defsubr (&Sprin1_to_string);
  defsubr (&Serror_message_string);
  defsubr (&Sprinc);
  defsubr (&Sprint);
  defsubr (&Sterpri);
  defsubr (&Swrite_char);
  defsubr (&Sexternal_debugging_output);

  Qexternal_debugging_output = intern ("external-debugging-output");
  staticpro (&Qexternal_debugging_output);

  Qprint_escape_newlines = intern ("print-escape-newlines");
  staticpro (&Qprint_escape_newlines);

  Qprint_escape_multibyte = intern ("print-escape-multibyte");
  staticpro (&Qprint_escape_multibyte);

  Qprint_escape_nonascii = intern ("print-escape-nonascii");
  staticpro (&Qprint_escape_nonascii);

#ifndef standalone
  defsubr (&Swith_output_to_temp_buffer);
#endif /* not standalone */
}
