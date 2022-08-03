/* Record indices of function doc strings stored in a file.
   Copyright (C) 1985, 86, 93, 94, 95, 97, 1998 Free Software Foundation, Inc.

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

#include <sys/types.h>
#include <sys/file.h>	/* Must be after sys/types.h for USG and BSD4_1*/

#ifdef USG5
#include <fcntl.h>
#endif

#ifdef HAVE_UNISTD_H
#include <unistd.h>
#endif

#ifndef O_RDONLY
#define O_RDONLY 0
#endif

#include "lisp.h"
#include "buffer.h"
#include "keyboard.h"
#include "charset.h"

Lisp_Object Vdoc_file_name;

extern char *index ();

extern Lisp_Object Voverriding_local_map;

/* For VMS versions with limited file name syntax,
   convert the name to something VMS will allow. */
static void
munge_doc_file_name (name)
     char *name;
{
#ifdef VMS
#ifndef VMS4_4
  /* For VMS versions with limited file name syntax,
     convert the name to something VMS will allow.  */
  p = name;
  while (*p)
    {
      if (*p == '-')
	*p = '_';
      p++;
    }
#endif /* not VMS4_4 */
#ifdef VMS4_4
  strcpy (name, sys_translate_unix (name));
#endif /* VMS4_4 */
#endif /* VMS */
}

/* Buffer used for reading from documentation file.  */
static char *get_doc_string_buffer;
static int get_doc_string_buffer_size;

static unsigned char *read_bytecode_pointer;

/* readchar in lread.c calls back here to fetch the next byte.
   If UNREADFLAG is 1, we unread a byte.  */

int
read_bytecode_char (unreadflag)
{
  if (unreadflag)
    {
      read_bytecode_pointer--;
      return 0;
    }
  return *read_bytecode_pointer++;
}

/* Extract a doc string from a file.  FILEPOS says where to get it.
   If it is an integer, use that position in the standard DOC-... file.
   If it is (FILE . INTEGER), use FILE as the file name
   and INTEGER as the position in that file.
   But if INTEGER is negative, make it positive.
   (A negative integer is used for user variables, so we can distinguish
   them without actually fetching the doc string.)

   If UNIBYTE is nonzero, always make a unibyte string.

   If DEFINITION is nonzero, assume this is for reading
   a dynamic function definition; convert the bytestring
   and the constants vector with appropriate byte handling,
   and return a cons cell.  */

Lisp_Object
get_doc_string (filepos, unibyte, definition)
     Lisp_Object filepos;
     int unibyte, definition;
{
  char *from, *to;
  register int fd;
  register char *name;
  register char *p, *p1;
  int minsize;
  int offset, position;
  Lisp_Object file, tem;

  if (INTEGERP (filepos))
    {
      file = Vdoc_file_name;
      position = XINT (filepos);
    }
  else if (CONSP (filepos))
    {
      file = XCONS (filepos)->car;
      position = XINT (XCONS (filepos)->cdr);
      if (position < 0)
	position = - position;
    }
  else
    return Qnil;

  if (!STRINGP (Vdoc_directory))
    return Qnil;

  if (!STRINGP (file))
    return Qnil;
    
  /* Put the file name in NAME as a C string.
     If it is relative, combine it with Vdoc_directory.  */

  tem = Ffile_name_absolute_p (file);
  if (NILP (tem))
    {
      minsize = XSTRING (Vdoc_directory)->size;
      /* sizeof ("../etc/") == 8 */
      if (minsize < 8)
	minsize = 8;
      name = (char *) alloca (minsize + XSTRING (file)->size + 8);
      strcpy (name, XSTRING (Vdoc_directory)->data);
      strcat (name, XSTRING (file)->data);
      munge_doc_file_name (name);
    }
  else
    {
      name = (char *) XSTRING (file)->data;
    }

  fd = open (name, O_RDONLY, 0);
  if (fd < 0)
    {
#ifndef CANNOT_DUMP
      if (!NILP (Vpurify_flag))
	{
	  /* Preparing to dump; DOC file is probably not installed.
	     So check in ../etc. */
	  strcpy (name, "../etc/");
	  strcat (name, XSTRING (file)->data);
	  munge_doc_file_name (name);

	  fd = open (name, O_RDONLY, 0);
	}
#endif
      if (fd < 0)
	error ("Cannot open doc string file \"%s\"", name);
    }

  /* Seek only to beginning of disk block.  */
  offset = position % (8 * 1024);
  if (0 > lseek (fd, position - offset, 0))
    {
      close (fd);
      error ("Position %ld out of range in doc string file \"%s\"",
	     position, name);
    }

  /* Read the doc string into get_doc_string_buffer.
     P points beyond the data just read.  */

  p = get_doc_string_buffer;
  while (1)
    {
      int space_left = (get_doc_string_buffer_size
			- (p - get_doc_string_buffer));
      int nread;

      /* Allocate or grow the buffer if we need to.  */
      if (space_left == 0)
	{
	  int in_buffer = p - get_doc_string_buffer;
	  get_doc_string_buffer_size += 16 * 1024;
	  get_doc_string_buffer
	    = (char *) xrealloc (get_doc_string_buffer,
				 get_doc_string_buffer_size + 1);
	  p = get_doc_string_buffer + in_buffer;
	  space_left = (get_doc_string_buffer_size
			- (p - get_doc_string_buffer));
	}

      /* Read a disk block at a time.
         If we read the same block last time, maybe skip this?  */
      if (space_left > 1024 * 8)
	space_left = 1024 * 8;
      nread = read (fd, p, space_left);
      if (nread < 0)
	{
	  close (fd);
	  error ("Read error on documentation file");
	}
      p[nread] = 0;
      if (!nread)
	break;
      if (p == get_doc_string_buffer)
	p1 = index (p + offset, '\037');
      else
	p1 = index (p, '\037');
      if (p1)
	{
	  *p1 = 0;
	  p = p1;
	  break;
	}
      p += nread;
    }
  close (fd);

  /* Scan the text and perform quoting with ^A (char code 1).
     ^A^A becomes ^A, ^A0 becomes a null char, and ^A_ becomes a ^_.  */
  from = get_doc_string_buffer + offset;
  to = get_doc_string_buffer + offset;
  while (from != p)
    {
      if (*from == 1)
	{
	  int c;

	  from++;
	  c = *from++;
	  if (c == 1)
	    *to++ = c;
	  else if (c == '0')
	    *to++ = 0;
	  else if (c == '_')
	    *to++ = 037;
	  else
	    error ("Invalid data in documentation file -- ^A followed by code 0%o", c);
	}
      else
	*to++ = *from++;
    }

  /* If DEFINITION, read from this buffer
     the same way we would read bytes from a file.  */
  if (definition)
    {
      read_bytecode_pointer = get_doc_string_buffer + offset;
      return Fread (Qlambda);
    }

  if (unibyte)
    return make_unibyte_string (get_doc_string_buffer + offset,
				to - (get_doc_string_buffer + offset));
  else
    {
      /* Let the data determine whether the string is multibyte,
	 even if Emacs is running in --unibyte mode.  */
      int nchars = multibyte_chars_in_text (get_doc_string_buffer + offset,
					    to - (get_doc_string_buffer + offset));
      return make_string_from_bytes (get_doc_string_buffer + offset,
				     nchars,
				     to - (get_doc_string_buffer + offset));
    }
}

/* Get a string from position FILEPOS and pass it through the Lisp reader.
   We use this for fetching the bytecode string and constants vector
   of a compiled function from the .elc file.  */

Lisp_Object
read_doc_string (filepos)
     Lisp_Object filepos;
{
  return get_doc_string (filepos, 0, 1);
}

DEFUN ("documentation", Fdocumentation, Sdocumentation, 1, 2, 0,
  "Return the documentation string of FUNCTION.\n\
Unless a non-nil second argument RAW is given, the\n\
string is passed through `substitute-command-keys'.")
  (function, raw)
     Lisp_Object function, raw;
{
  Lisp_Object fun;
  Lisp_Object funcar;
  Lisp_Object tem, doc;

  fun = Findirect_function (function);

  if (SUBRP (fun))
    {
      if (XSUBR (fun)->doc == 0) return Qnil;
      if ((EMACS_INT) XSUBR (fun)->doc >= 0)
	doc = build_string (XSUBR (fun)->doc);
      else
	doc = get_doc_string (make_number (- (EMACS_INT) XSUBR (fun)->doc),
			      0, 0);
    }
  else if (COMPILEDP (fun))
    {
      if ((XVECTOR (fun)->size & PSEUDOVECTOR_SIZE_MASK) <= COMPILED_DOC_STRING)
	return Qnil;
      tem = XVECTOR (fun)->contents[COMPILED_DOC_STRING];
      if (STRINGP (tem))
	doc = tem;
      else if (NATNUMP (tem) || CONSP (tem))
	doc = get_doc_string (tem, 0, 0);
      else
	return Qnil;
    }
  else if (STRINGP (fun) || VECTORP (fun))
    {
      return build_string ("Keyboard macro.");
    }
  else if (CONSP (fun))
    {
      funcar = Fcar (fun);
      if (!SYMBOLP (funcar))
	return Fsignal (Qinvalid_function, Fcons (fun, Qnil));
      else if (EQ (funcar, Qkeymap))
	return build_string ("Prefix command (definition is a keymap associating keystrokes with commands).");
      else if (EQ (funcar, Qlambda)
	       || EQ (funcar, Qautoload))
	{
	  Lisp_Object tem1;
	  tem1 = Fcdr (Fcdr (fun));
	  tem = Fcar (tem1);
	  if (STRINGP (tem))
	    doc = tem;
	  /* Handle a doc reference--but these never come last
	     in the function body, so reject them if they are last.  */
	  else if ((NATNUMP (tem) || CONSP (tem))
		   && ! NILP (XCONS (tem1)->cdr))
	    doc = get_doc_string (tem, 0, 0);
	  else
	    return Qnil;
	}
      else if (EQ (funcar, Qmocklisp))
	return Qnil;
      else if (EQ (funcar, Qmacro))
	return Fdocumentation (Fcdr (fun), raw);
      else
	goto oops;
    }
  else
    {
    oops:
      Fsignal (Qinvalid_function, Fcons (fun, Qnil));
    }

  if (NILP (raw))
    doc = Fsubstitute_command_keys (doc);
  return doc;
}

DEFUN ("documentation-property", Fdocumentation_property, Sdocumentation_property, 2, 3, 0,
  "Return the documentation string that is SYMBOL's PROP property.\n\
This is like `get', but it can refer to strings stored in the\n\
`etc/DOC' file; and if the value is a string, it is passed through\n\
`substitute-command-keys'.  A non-nil third argument RAW avoids this\n\
translation.")
  (symbol, prop, raw)
     Lisp_Object symbol, prop, raw;
{
  Lisp_Object tem;

  tem = Fget (symbol, prop);
  if (INTEGERP (tem))
    tem = get_doc_string (XINT (tem) > 0 ? tem : make_number (- XINT (tem)), 0, 0);
  else if (CONSP (tem))
    tem = get_doc_string (tem, 0, 0);
  if (NILP (raw) && STRINGP (tem))
    tem = Fsubstitute_command_keys (tem);

  return tem;
}

/* Scanning the DOC files and placing docstring offsets into functions.  */

static void
store_function_docstring (fun, offset)
     Lisp_Object fun;
     /* Use EMACS_INT because we get this from pointer subtraction.  */
     EMACS_INT offset;
{
  fun = indirect_function (fun);

  /* The type determines where the docstring is stored.  */

  /* Lisp_Subrs have a slot for it.  */
  if (SUBRP (fun))
    XSUBR (fun)->doc = (char *) - offset;

  /* If it's a lisp form, stick it in the form.  */
  else if (CONSP (fun))
    {
      Lisp_Object tem;

      tem = XCONS (fun)->car;
      if (EQ (tem, Qlambda) || EQ (tem, Qautoload))
	{
	  tem = Fcdr (Fcdr (fun));
	  if (CONSP (tem) && INTEGERP (XCONS (tem)->car))
	    XSETFASTINT (XCONS (tem)->car, offset);
	}
      else if (EQ (tem, Qmacro))
	store_function_docstring (XCONS (fun)->cdr, offset);
    }

  /* Bytecode objects sometimes have slots for it.  */
  else if (COMPILEDP (fun))
    {
      /* This bytecode object must have a slot for the
	 docstring, since we've found a docstring for it.  */
      if ((XVECTOR (fun)->size & PSEUDOVECTOR_SIZE_MASK) > COMPILED_DOC_STRING)
	XSETFASTINT (XVECTOR (fun)->contents[COMPILED_DOC_STRING], offset);
    }
}


DEFUN ("Snarf-documentation", Fsnarf_documentation, Ssnarf_documentation,
  1, 1, 0,
  "Used during Emacs initialization, before dumping runnable Emacs,\n\
to find pointers to doc strings stored in `etc/DOC...' and\n\
record them in function definitions.\n\
One arg, FILENAME, a string which does not include a directory.\n\
The file is found in `../etc' now; found in the `data-directory'\n\
when doc strings are referred to later in the dumped Emacs.")
  (filename)
     Lisp_Object filename;
{
  int fd;
  char buf[1024 + 1];
  register int filled;
  register int pos;
  register char *p, *end;
  Lisp_Object sym, fun, tem;
  char *name;
  extern char *index ();

#ifndef CANNOT_DUMP
  if (NILP (Vpurify_flag))
    error ("Snarf-documentation can only be called in an undumped Emacs");
#endif

  CHECK_STRING (filename, 0);

#ifndef CANNOT_DUMP
  name = (char *) alloca (XSTRING (filename)->size + 14);
  strcpy (name, "../etc/");
#else /* CANNOT_DUMP */
  CHECK_STRING (Vdoc_directory, 0);
  name = (char *) alloca (XSTRING (filename)->size +
			  XSTRING (Vdoc_directory)->size + 1);
  strcpy (name, XSTRING (Vdoc_directory)->data);
#endif /* CANNOT_DUMP */
  strcat (name, XSTRING (filename)->data); 	/*** Add this line ***/
#ifdef VMS
#ifndef VMS4_4
  /* For VMS versions with limited file name syntax,
     convert the name to something VMS will allow.  */
  p = name;
  while (*p)
    {
      if (*p == '-')
	*p = '_';
      p++;
    }
#endif /* not VMS4_4 */
#ifdef VMS4_4
  strcpy (name, sys_translate_unix (name));
#endif /* VMS4_4 */
#endif /* VMS */

  fd = open (name, O_RDONLY, 0);
  if (fd < 0)
    report_file_error ("Opening doc string file",
		       Fcons (build_string (name), Qnil));
  Vdoc_file_name = filename;
  filled = 0;
  pos = 0;
  while (1)
    {
      if (filled < 512)
	filled += read (fd, &buf[filled], sizeof buf - 1 - filled);
      if (!filled)
	break;

      buf[filled] = 0;
      p = buf;
      end = buf + (filled < 512 ? filled : filled - 128);
      while (p != end && *p != '\037') p++;
      /* p points to ^_Ffunctionname\n or ^_Vvarname\n.  */
      if (p != end)
	{
	  end = index (p, '\n');
	  sym = oblookup (Vobarray, p + 2,
			  multibyte_chars_in_text (p + 2, end - p - 2),
			  end - p - 2);
	  if (SYMBOLP (sym))
	    {
	      /* Attach a docstring to a variable?  */
	      if (p[1] == 'V')
		{
		  /* Install file-position as variable-documentation property
		     and make it negative for a user-variable
		     (doc starts with a `*').  */
		  Fput (sym, Qvariable_documentation,
			make_number ((pos + end + 1 - buf)
				     * (end[1] == '*' ? -1 : 1)));
		}

	      /* Attach a docstring to a function?  */
	      else if (p[1] == 'F')
		store_function_docstring (sym, pos + end + 1 - buf);

	      else
		error ("DOC file invalid at position %d", pos);
	    }
	}
      pos += end - buf;
      filled -= end - buf;
      bcopy (end, buf, filled);
    }
  close (fd);
  return Qnil;
}

DEFUN ("substitute-command-keys", Fsubstitute_command_keys,
  Ssubstitute_command_keys, 1, 1, 0,
  "Substitute key descriptions for command names in STRING.\n\
Return a new string which is STRING with substrings of the form \\=\\[COMMAND]\n\
replaced by either:  a keystroke sequence that will invoke COMMAND,\n\
or \"M-x COMMAND\" if COMMAND is not on any keys.\n\
Substrings of the form \\=\\{MAPVAR} are replaced by summaries\n\
\(made by describe-bindings) of the value of MAPVAR, taken as a keymap.\n\
Substrings of the form \\=\\<MAPVAR> specify to use the value of MAPVAR\n\
as the keymap for future \\=\\[COMMAND] substrings.\n\
\\=\\= quotes the following character and is discarded;\n\
thus, \\=\\=\\=\\= puts \\=\\= into the output, and \\=\\=\\=\\[ puts \\=\\[ into the output.")
  (string)
     Lisp_Object string;
{
  unsigned char *buf;
  int changed = 0;
  register unsigned char *strp;
  register unsigned char *bufp;
  int idx;
  int bsize;
  unsigned char *new;
  Lisp_Object tem;
  Lisp_Object keymap;
  unsigned char *start;
  int length, length_byte;
  Lisp_Object name;
  struct gcpro gcpro1, gcpro2, gcpro3, gcpro4;
  int multibyte;
  int nchars;

  if (NILP (string))
    return Qnil;

  CHECK_STRING (string, 0);
  tem = Qnil;
  keymap = Qnil;
  name = Qnil;
  GCPRO4 (string, tem, keymap, name);

  multibyte = STRING_MULTIBYTE (string);
  nchars = 0;

  /* KEYMAP is either nil (which means search all the active keymaps)
     or a specified local map (which means search just that and the
     global map).  If non-nil, it might come from Voverriding_local_map,
     or from a \\<mapname> construct in STRING itself..  */
  keymap = current_kboard->Voverriding_terminal_local_map;
  if (NILP (keymap))
    keymap = Voverriding_local_map;

  bsize = STRING_BYTES (XSTRING (string));
  bufp = buf = (unsigned char *) xmalloc (bsize);

  strp = (unsigned char *) XSTRING (string)->data;
  while (strp < XSTRING (string)->data + STRING_BYTES (XSTRING (string)))
    {
      if (strp[0] == '\\' && strp[1] == '=')
	{
	  /* \= quotes the next character;
	     thus, to put in \[ without its special meaning, use \=\[.  */
	  changed = 1;
	  strp += 2;
	  if (multibyte)
	    {
	      int len;
	      int maxlen = XSTRING (string)->data + STRING_BYTES (XSTRING (string)) - strp;

	      STRING_CHAR_AND_LENGTH (strp, maxlen, len);
	      if (len == 1)
		*bufp = *strp;
	      else
		bcopy (strp, bufp, len);
	      strp += len;
	      bufp += len;
	      nchars++;
	    }
	  else
	    *bufp++ = *strp++, nchars++;
	}
      else if (strp[0] == '\\' && strp[1] == '[')
	{
	  Lisp_Object firstkey;

	  changed = 1;
	  strp += 2;		/* skip \[ */
	  start = strp;

	  while ((strp - (unsigned char *) XSTRING (string)->data
		  < STRING_BYTES (XSTRING (string)))
		 && *strp != ']')
	    strp++;
	  length_byte = strp - start;

	  strp++;		/* skip ] */

	  /* Save STRP in IDX.  */
	  idx = strp - (unsigned char *) XSTRING (string)->data;
	  tem = Fintern (make_string (start, length_byte), Qnil);
	  tem = Fwhere_is_internal (tem, keymap, Qt, Qnil);

	  /* Disregard menu bar bindings; it is positively annoying to
	     mention them when there's no menu bar, and it isn't terribly
	     useful even when there is a menu bar.  */
	  if (!NILP (tem))
	    {
	      firstkey = Faref (tem, make_number (0));
	      if (EQ (firstkey, Qmenu_bar))
		tem = Qnil;
	    }

	  if (NILP (tem))	/* but not on any keys */
	    {
	      new = (unsigned char *) xrealloc (buf, bsize += 4);
	      bufp += new - buf;
	      buf = new;
	      bcopy ("M-x ", bufp, 4);
	      bufp += 4;
	      nchars += 4;
	      if (multibyte)
		length = multibyte_chars_in_text (start, length_byte);
	      else
		length = length_byte;
	      goto subst;
	    }
	  else
	    {			/* function is on a key */
	      tem = Fkey_description (tem);
	      goto subst_string;
	    }
	}
      /* \{foo} is replaced with a summary of the keymap (symbol-value foo).
	 \<foo> just sets the keymap used for \[cmd].  */
      else if (strp[0] == '\\' && (strp[1] == '{' || strp[1] == '<'))
	{
	  struct buffer *oldbuf;

	  changed = 1;
	  strp += 2;		/* skip \{ or \< */
	  start = strp;

	  while ((strp - (unsigned char *) XSTRING (string)->data
		  < XSTRING (string)->size)
		 && *strp != '}' && *strp != '>')
	    strp++;

	  length_byte = strp - start;
	  strp++;			/* skip } or > */

	  /* Save STRP in IDX.  */
	  idx = strp - (unsigned char *) XSTRING (string)->data;

	  /* Get the value of the keymap in TEM, or nil if undefined.
	     Do this while still in the user's current buffer
	     in case it is a local variable.  */
	  name = Fintern (make_string (start, length_byte), Qnil);
	  tem = Fboundp (name);
	  if (! NILP (tem))
	    {
	      tem = Fsymbol_value (name);
	      if (! NILP (tem))
		tem = get_keymap_1 (tem, 0, 1);
	    }

	  /* Now switch to a temp buffer.  */
	  oldbuf = current_buffer;
	  set_buffer_internal (XBUFFER (Vprin1_to_string_buffer));

	  if (NILP (tem))
	    {
	      name = Fsymbol_name (name);
	      insert_string ("\nUses keymap \"");
	      insert_from_string (name, 0, 0,
				  XSTRING (name)->size,
				  STRING_BYTES (XSTRING (name)), 1);
	      insert_string ("\", which is not currently defined.\n");
	      if (start[-1] == '<') keymap = Qnil;
	    }
	  else if (start[-1] == '<')
	    keymap = tem;
	  else
	    describe_map_tree (tem, 1, Qnil, Qnil, (char *)0, 1, 0, 0);
	  tem = Fbuffer_string ();
	  Ferase_buffer ();
	  set_buffer_internal (oldbuf);

	subst_string:
	  start = XSTRING (tem)->data;
	  length = XSTRING (tem)->size;
	  length_byte = STRING_BYTES (XSTRING (tem));
	subst:
	  new = (unsigned char *) xrealloc (buf, bsize += length_byte);
	  bufp += new - buf;
	  buf = new;
	  bcopy (start, bufp, length_byte);
	  bufp += length_byte;
	  nchars += length;
	  /* Check STRING again in case gc relocated it.  */
	  strp = (unsigned char *) XSTRING (string)->data + idx;
	}
      else if (! multibyte)		/* just copy other chars */
	*bufp++ = *strp++, nchars++;
      else
	{
	  int len;
	  int maxlen = XSTRING (string)->data + STRING_BYTES (XSTRING (string)) - strp;

	  STRING_CHAR_AND_LENGTH (strp, maxlen, len);
	  if (len == 1)
	    *bufp = *strp;
	  else
	    bcopy (strp, bufp, len);
	  strp += len;
	  bufp += len;
	  nchars++;
	}
    }

  if (changed)			/* don't bother if nothing substituted */
    tem = make_string_from_bytes (buf, nchars, bufp - buf);
  else
    tem = string;
  xfree (buf);
  RETURN_UNGCPRO (tem);
}

void
syms_of_doc ()
{
  DEFVAR_LISP ("internal-doc-file-name", &Vdoc_file_name,
    "Name of file containing documentation strings of built-in symbols.");
  Vdoc_file_name = Qnil;

  defsubr (&Sdocumentation);
  defsubr (&Sdocumentation_property);
  defsubr (&Ssnarf_documentation);
  defsubr (&Ssubstitute_command_keys);
}
