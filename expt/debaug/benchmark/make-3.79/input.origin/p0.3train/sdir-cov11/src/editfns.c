/* Lisp functions pertaining to editing.
   Copyright (C) 1985,86,87,89,93,94,95,96,97,98 Free Software Foundation, Inc.

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


#include <sys/types.h>

#include <config.h>

#ifdef VMS
#include "vms-pwd.h"
#else
#include <pwd.h>
#endif

#ifdef STDC_HEADERS
#include <stdlib.h>
#endif

#ifdef HAVE_UNISTD_H
#include <unistd.h>
#endif

#include "lisp.h"
#include "intervals.h"
#include "buffer.h"
#include "charset.h"
#include "window.h"

#include "systime.h"

#define min(a, b) ((a) < (b) ? (a) : (b))
#define max(a, b) ((a) > (b) ? (a) : (b))

#ifndef NULL
#define NULL 0
#endif

extern char **environ;
extern Lisp_Object make_time ();
extern void insert_from_buffer ();
static int tm_diff ();
static void update_buffer_properties ();
size_t emacs_strftime ();
void set_time_zone_rule ();

Lisp_Object Vbuffer_access_fontify_functions;
Lisp_Object Qbuffer_access_fontify_functions;
Lisp_Object Vbuffer_access_fontified_property;

Lisp_Object Fuser_full_name ();

/* Some static data, and a function to initialize it for each run */

Lisp_Object Vsystem_name;
Lisp_Object Vuser_real_login_name;	/* login name of current user ID */
Lisp_Object Vuser_full_name;		/* full name of current user */
Lisp_Object Vuser_login_name;		/* user name from LOGNAME or USER */

void
init_editfns ()
{
  char *user_name;
  register unsigned char *p, *q, *r;
  struct passwd *pw;	/* password entry for the current user */
  Lisp_Object tem;

  /* Set up system_name even when dumping.  */
  init_system_name ();

#ifndef CANNOT_DUMP
  /* Don't bother with this on initial start when just dumping out */
  if (!initialized)
    return;
#endif /* not CANNOT_DUMP */

  pw = (struct passwd *) getpwuid (getuid ());
#ifdef MSDOS
  /* We let the real user name default to "root" because that's quite
     accurate on MSDOG and because it lets Emacs find the init file.
     (The DVX libraries override the Djgpp libraries here.)  */
  Vuser_real_login_name = build_string (pw ? pw->pw_name : "root");
#else
  Vuser_real_login_name = build_string (pw ? pw->pw_name : "unknown");
#endif

  /* Get the effective user name, by consulting environment variables,
     or the effective uid if those are unset.  */
  user_name = (char *) getenv ("LOGNAME");
  if (!user_name)
#ifdef WINDOWSNT
    user_name = (char *) getenv ("USERNAME");	/* it's USERNAME on NT */
#else  /* WINDOWSNT */
    user_name = (char *) getenv ("USER");
#endif /* WINDOWSNT */
  if (!user_name)
    {
      pw = (struct passwd *) getpwuid (geteuid ());
      user_name = (char *) (pw ? pw->pw_name : "unknown");
    }
  Vuser_login_name = build_string (user_name);

  /* If the user name claimed in the environment vars differs from
     the real uid, use the claimed name to find the full name.  */
  tem = Fstring_equal (Vuser_login_name, Vuser_real_login_name);
  Vuser_full_name = Fuser_full_name (NILP (tem)? make_number (geteuid())
				     : Vuser_login_name);
  
  p = (unsigned char *) getenv ("NAME");
  if (p)
    Vuser_full_name = build_string (p);
  else if (NILP (Vuser_full_name))
    Vuser_full_name = build_string ("unknown");
}

DEFUN ("char-to-string", Fchar_to_string, Schar_to_string, 1, 1, 0,
  "Convert arg CHAR to a string containing that character.")
  (character)
     Lisp_Object character;
{
  int len;
  unsigned char workbuf[4], *str;

  CHECK_NUMBER (character, 0);

  len = CHAR_STRING (XFASTINT (character), workbuf, str);
  return make_string_from_bytes (str, 1, len);
}

DEFUN ("string-to-char", Fstring_to_char, Sstring_to_char, 1, 1, 0,
  "Convert arg STRING to a character, the first character of that string.\n\
A multibyte character is handled correctly.")
  (string)
     register Lisp_Object string;
{
  register Lisp_Object val;
  register struct Lisp_String *p;
  CHECK_STRING (string, 0);
  p = XSTRING (string);
  if (p->size)
    {
      if (STRING_MULTIBYTE (string))
	XSETFASTINT (val, STRING_CHAR (p->data, STRING_BYTES (p)));
      else
	XSETFASTINT (val, p->data[0]);
    }
  else
    XSETFASTINT (val, 0);
  return val;
}

static Lisp_Object
buildmark (charpos, bytepos)
     int charpos, bytepos;
{
  register Lisp_Object mark;
  mark = Fmake_marker ();
  set_marker_both (mark, Qnil, charpos, bytepos);
  return mark;
}

DEFUN ("point", Fpoint, Spoint, 0, 0, 0,
  "Return value of point, as an integer.\n\
Beginning of buffer is position (point-min)")
  ()
{
  Lisp_Object temp;
  XSETFASTINT (temp, PT);
  return temp;
}

DEFUN ("point-marker", Fpoint_marker, Spoint_marker, 0, 0, 0,
   "Return value of point, as a marker object.")
  ()
{
  return buildmark (PT, PT_BYTE);
}

int
clip_to_bounds (lower, num, upper)
     int lower, num, upper;
{
  if (num < lower)
    return lower;
  else if (num > upper)
    return upper;
  else
    return num;
}

DEFUN ("goto-char", Fgoto_char, Sgoto_char, 1, 1, "NGoto char: ",
  "Set point to POSITION, a number or marker.\n\
Beginning of buffer is position (point-min), end is (point-max).\n\
If the position is in the middle of a multibyte form,\n\
the actual point is set at the head of the multibyte form\n\
except in the case that `enable-multibyte-characters' is nil.")
  (position)
     register Lisp_Object position;
{
  int pos;
  unsigned char *p;

  if (MARKERP (position)
      && current_buffer == XMARKER (position)->buffer)
    {
      pos = marker_position (position);
      if (pos < BEGV)
	SET_PT_BOTH (BEGV, BEGV_BYTE);
      else if (pos > ZV)
	SET_PT_BOTH (ZV, ZV_BYTE);
      else
	SET_PT_BOTH (pos, marker_byte_position (position));

      return position;
    }

  CHECK_NUMBER_COERCE_MARKER (position, 0);

  pos = clip_to_bounds (BEGV, XINT (position), ZV);
  SET_PT (pos);
  return position;
}

static Lisp_Object
region_limit (beginningp)
     int beginningp;
{
  extern Lisp_Object Vmark_even_if_inactive; /* Defined in callint.c. */
  register Lisp_Object m;
  if (!NILP (Vtransient_mark_mode) && NILP (Vmark_even_if_inactive)
      && NILP (current_buffer->mark_active))
    Fsignal (Qmark_inactive, Qnil);
  m = Fmarker_position (current_buffer->mark);
  if (NILP (m)) error ("There is no region now");
  if ((PT < XFASTINT (m)) == beginningp)
    return (make_number (PT));
  else
    return (m);
}

DEFUN ("region-beginning", Fregion_beginning, Sregion_beginning, 0, 0, 0,
  "Return position of beginning of region, as an integer.")
  ()
{
  return (region_limit (1));
}

DEFUN ("region-end", Fregion_end, Sregion_end, 0, 0, 0,
  "Return position of end of region, as an integer.")
  ()
{
  return (region_limit (0));
}

DEFUN ("mark-marker", Fmark_marker, Smark_marker, 0, 0, 0,
  "Return this buffer's mark, as a marker object.\n\
Watch out!  Moving this marker changes the mark position.\n\
If you set the marker not to point anywhere, the buffer will have no mark.")
  ()
{
  return current_buffer->mark;
}

DEFUN ("line-beginning-position", Fline_beginning_position, Sline_beginning_position,
  0, 1, 0,
  "Return the character position of the first character on the current line.\n\
With argument N not nil or 1, move forward N - 1 lines first.\n\
If scan reaches end of buffer, return that position.\n\
This function does not move point.")
  (n)
     Lisp_Object n;
{
  register int orig, orig_byte, end;

  if (NILP (n))
    XSETFASTINT (n, 1);
  else
    CHECK_NUMBER (n, 0);

  orig = PT;
  orig_byte = PT_BYTE;
  Fforward_line (make_number (XINT (n) - 1));
  end = PT;
  SET_PT_BOTH (orig, orig_byte);

  return make_number (end);
}

DEFUN ("line-end-position", Fline_end_position, Sline_end_position,
  0, 1, 0,
  "Return the character position of the last character on the current line.\n\
With argument N not nil or 1, move forward N - 1 lines first.\n\
If scan reaches end of buffer, return that position.\n\
This function does not move point.")
  (n)
     Lisp_Object n;
{
  if (NILP (n))
    XSETFASTINT (n, 1);
  else
    CHECK_NUMBER (n, 0);

  return make_number (find_before_next_newline 
		      (PT, 0, XINT (n) - (XINT (n) <= 0)));
}

Lisp_Object
save_excursion_save ()
{
  register int visible = (XBUFFER (XWINDOW (selected_window)->buffer)
			  == current_buffer);

  return Fcons (Fpoint_marker (),
		Fcons (Fcopy_marker (current_buffer->mark, Qnil),
		       Fcons (visible ? Qt : Qnil,
			      current_buffer->mark_active)));		       
}

Lisp_Object
save_excursion_restore (info)
     Lisp_Object info;
{
  Lisp_Object tem, tem1, omark, nmark;
  struct gcpro gcpro1, gcpro2, gcpro3;

  tem = Fmarker_buffer (Fcar (info));
  /* If buffer being returned to is now deleted, avoid error */
  /* Otherwise could get error here while unwinding to top level
     and crash */
  /* In that case, Fmarker_buffer returns nil now.  */
  if (NILP (tem))
    return Qnil;

  omark = nmark = Qnil;
  GCPRO3 (info, omark, nmark);

  Fset_buffer (tem);
  tem = Fcar (info);
  Fgoto_char (tem);
  unchain_marker (tem);
  tem = Fcar (Fcdr (info));
  omark = Fmarker_position (current_buffer->mark);
  Fset_marker (current_buffer->mark, tem, Fcurrent_buffer ());
  nmark = Fmarker_position (tem);
  unchain_marker (tem);
  tem = Fcdr (Fcdr (info));
#if 0 /* We used to make the current buffer visible in the selected window
	 if that was true previously.  That avoids some anomalies.
	 But it creates others, and it wasn't documented, and it is simpler
	 and cleaner never to alter the window/buffer connections.  */
  tem1 = Fcar (tem);
  if (!NILP (tem1)
      && current_buffer != XBUFFER (XWINDOW (selected_window)->buffer))
    Fswitch_to_buffer (Fcurrent_buffer (), Qnil);
#endif /* 0 */

  tem1 = current_buffer->mark_active;
  current_buffer->mark_active = Fcdr (tem);
  if (!NILP (Vrun_hooks))
    {
      /* If mark is active now, and either was not active
	 or was at a different place, run the activate hook.  */
      if (! NILP (current_buffer->mark_active))
	{
	  if (! EQ (omark, nmark))
	    call1 (Vrun_hooks, intern ("activate-mark-hook"));
	}
      /* If mark has ceased to be active, run deactivate hook.  */
      else if (! NILP (tem1))
	call1 (Vrun_hooks, intern ("deactivate-mark-hook"));
    }
  UNGCPRO;
  return Qnil;
}

DEFUN ("save-excursion", Fsave_excursion, Ssave_excursion, 0, UNEVALLED, 0,
  "Save point, mark, and current buffer; execute BODY; restore those things.\n\
Executes BODY just like `progn'.\n\
The values of point, mark and the current buffer are restored\n\
even in case of abnormal exit (throw or error).\n\
The state of activation of the mark is also restored.\n\
\n\
This construct does not save `deactivate-mark', and therefore\n\
functions that change the buffer will still cause deactivation\n\
of the mark at the end of the command.  To prevent that, bind\n\
`deactivate-mark' with `let'.")
  (args)
     Lisp_Object args;
{
  register Lisp_Object val;
  int count = specpdl_ptr - specpdl;

  record_unwind_protect (save_excursion_restore, save_excursion_save ());

  val = Fprogn (args);
  return unbind_to (count, val);
}

DEFUN ("save-current-buffer", Fsave_current_buffer, Ssave_current_buffer, 0, UNEVALLED, 0,
  "Save the current buffer; execute BODY; restore the current buffer.\n\
Executes BODY just like `progn'.")
  (args)
     Lisp_Object args;
{
  register Lisp_Object val;
  int count = specpdl_ptr - specpdl;

  record_unwind_protect (set_buffer_if_live, Fcurrent_buffer ());

  val = Fprogn (args);
  return unbind_to (count, val);
}

DEFUN ("buffer-size", Fbufsize, Sbufsize, 0, 0, 0,
  "Return the number of characters in the current buffer.")
  ()
{
  Lisp_Object temp;
  XSETFASTINT (temp, Z - BEG);
  return temp;
}

DEFUN ("point-min", Fpoint_min, Spoint_min, 0, 0, 0,
  "Return the minimum permissible value of point in the current buffer.\n\
This is 1, unless narrowing (a buffer restriction) is in effect.")
  ()
{
  Lisp_Object temp;
  XSETFASTINT (temp, BEGV);
  return temp;
}

DEFUN ("point-min-marker", Fpoint_min_marker, Spoint_min_marker, 0, 0, 0,
  "Return a marker to the minimum permissible value of point in this buffer.\n\
This is the beginning, unless narrowing (a buffer restriction) is in effect.")
  ()
{
  return buildmark (BEGV, BEGV_BYTE);
}

DEFUN ("point-max", Fpoint_max, Spoint_max, 0, 0, 0,
  "Return the maximum permissible value of point in the current buffer.\n\
This is (1+ (buffer-size)), unless narrowing (a buffer restriction)\n\
is in effect, in which case it is less.")
  ()
{
  Lisp_Object temp;
  XSETFASTINT (temp, ZV);
  return temp;
}

DEFUN ("point-max-marker", Fpoint_max_marker, Spoint_max_marker, 0, 0, 0,
  "Return a marker to the maximum permissible value of point in this buffer.\n\
This is (1+ (buffer-size)), unless narrowing (a buffer restriction)\n\
is in effect, in which case it is less.")
  ()
{
  return buildmark (ZV, ZV_BYTE);
}

DEFUN ("gap-position", Fgap_position, Sgap_position, 0, 0, 0,
  "Return the position of the gap, in the current buffer.\n\
See also `gap-size'.")
  ()
{
  Lisp_Object temp;
  XSETFASTINT (temp, GPT);
  return temp;
}

DEFUN ("gap-size", Fgap_size, Sgap_size, 0, 0, 0,
  "Return the size of the current buffer's gap.\n\
See also `gap-position'.")
  ()
{
  Lisp_Object temp;
  XSETFASTINT (temp, GAP_SIZE);
  return temp;
}

DEFUN ("position-bytes", Fposition_bytes, Sposition_bytes, 1, 1, 0,
  "Return the byte position for character position POSITION.\n\
If POSITION is out of range, the value is nil.")
  (position)
     Lisp_Object position;
{
  CHECK_NUMBER_COERCE_MARKER (position, 1);
  if (XINT (position) < BEG || XINT (position) > Z)
    return Qnil;
  return make_number (CHAR_TO_BYTE (XINT (position)));
}

DEFUN ("byte-to-position", Fbyte_to_position, Sbyte_to_position, 1, 1, 0,
  "Return the character position for byte position BYTEPOS.\n\
If BYTEPOS is out of range, the value is nil.")
  (bytepos)
     Lisp_Object bytepos;
{
  CHECK_NUMBER (bytepos, 1);
  if (XINT (bytepos) < BEG_BYTE || XINT (bytepos) > Z_BYTE)
    return Qnil;
  return make_number (BYTE_TO_CHAR (XINT (bytepos)));
}

DEFUN ("following-char", Ffollowing_char, Sfollowing_char, 0, 0, 0,
  "Return the character following point, as a number.\n\
At the end of the buffer or accessible region, return 0.\n\
If `enable-multibyte-characters' is nil or point is not\n\
 at character boundary,  multibyte form is ignored,\n\
 and only one byte following point is returned as a character.")
  ()
{
  Lisp_Object temp;
  if (PT >= ZV)
    XSETFASTINT (temp, 0);
  else
    XSETFASTINT (temp, FETCH_CHAR (PT_BYTE));
  return temp;
}

DEFUN ("preceding-char", Fprevious_char, Sprevious_char, 0, 0, 0,
  "Return the character preceding point, as a number.\n\
At the beginning of the buffer or accessible region, return 0.\n\
If `enable-multibyte-characters' is nil or point is not\n\
 at character boundary, multi-byte form is ignored,\n\
 and only one byte preceding point is returned as a character.")
  ()
{
  Lisp_Object temp;
  if (PT <= BEGV)
    XSETFASTINT (temp, 0);
  else if (!NILP (current_buffer->enable_multibyte_characters))
    {
      int pos = PT_BYTE;
      DEC_POS (pos);
      XSETFASTINT (temp, FETCH_CHAR (pos));
    }
  else
    XSETFASTINT (temp, FETCH_BYTE (PT_BYTE - 1));
  return temp;
}

DEFUN ("bobp", Fbobp, Sbobp, 0, 0, 0,
  "Return t if point is at the beginning of the buffer.\n\
If the buffer is narrowed, this means the beginning of the narrowed part.")
  ()
{
  if (PT == BEGV)
    return Qt;
  return Qnil;
}

DEFUN ("eobp", Feobp, Seobp, 0, 0, 0,
  "Return t if point is at the end of the buffer.\n\
If the buffer is narrowed, this means the end of the narrowed part.")
  ()
{
  if (PT == ZV)
    return Qt;
  return Qnil;
}

DEFUN ("bolp", Fbolp, Sbolp, 0, 0, 0,
  "Return t if point is at the beginning of a line.")
  ()
{
  if (PT == BEGV || FETCH_BYTE (PT_BYTE - 1) == '\n')
    return Qt;
  return Qnil;
}

DEFUN ("eolp", Feolp, Seolp, 0, 0, 0,
  "Return t if point is at the end of a line.\n\
`End of a line' includes point being at the end of the buffer.")
  ()
{
  if (PT == ZV || FETCH_BYTE (PT_BYTE) == '\n')
    return Qt;
  return Qnil;
}

DEFUN ("char-after", Fchar_after, Schar_after, 0, 1, 0,
  "Return character in current buffer at position POS.\n\
POS is an integer or a buffer pointer.\n\
If POS is out of range, the value is nil.")
  (pos)
     Lisp_Object pos;
{
  register int pos_byte;
  register Lisp_Object val;

  if (NILP (pos))
    {
      pos_byte = PT_BYTE;
      XSETFASTINT (pos, PT);
    }

  if (MARKERP (pos))
    {
      pos_byte = marker_byte_position (pos);
      if (pos_byte < BEGV_BYTE || pos_byte >= ZV_BYTE)
	return Qnil;
    }
  else
    {
      CHECK_NUMBER_COERCE_MARKER (pos, 0);
      if (XINT (pos) < BEGV || XINT (pos) >= ZV)
	return Qnil;
      
      pos_byte = CHAR_TO_BYTE (XINT (pos));
    }

  return make_number (FETCH_CHAR (pos_byte));
}

DEFUN ("char-before", Fchar_before, Schar_before, 0, 1, 0,
  "Return character in current buffer preceding position POS.\n\
POS is an integer or a buffer pointer.\n\
If POS is out of range, the value is nil.")
  (pos)
     Lisp_Object pos;
{
  register Lisp_Object val;
  register int pos_byte;

  if (NILP (pos))
    {
      pos_byte = PT_BYTE;
      XSETFASTINT (pos, PT);
    }

  if (MARKERP (pos))
    {
      pos_byte = marker_byte_position (pos);

      if (pos_byte <= BEGV_BYTE || pos_byte > ZV_BYTE)
	return Qnil;
    }
  else
    {
      CHECK_NUMBER_COERCE_MARKER (pos, 0);

      if (XINT (pos) <= BEGV || XINT (pos) > ZV)
	return Qnil;

      pos_byte = CHAR_TO_BYTE (XINT (pos));
    }

  if (!NILP (current_buffer->enable_multibyte_characters))
    {
      DEC_POS (pos_byte);
      XSETFASTINT (val, FETCH_CHAR (pos_byte));
    }
  else
    {
      pos_byte--;
      XSETFASTINT (val, FETCH_BYTE (pos_byte));
    }
   return val;
}

DEFUN ("user-login-name", Fuser_login_name, Suser_login_name, 0, 1, 0,
  "Return the name under which the user logged in, as a string.\n\
This is based on the effective uid, not the real uid.\n\
Also, if the environment variable LOGNAME or USER is set,\n\
that determines the value of this function.\n\n\
If optional argument UID is an integer, return the login name of the user\n\
with that uid, or nil if there is no such user.")
  (uid)
     Lisp_Object uid;
{
  struct passwd *pw;

  /* Set up the user name info if we didn't do it before.
     (That can happen if Emacs is dumpable
     but you decide to run `temacs -l loadup' and not dump.  */
  if (INTEGERP (Vuser_login_name))
    init_editfns ();

  if (NILP (uid))
    return Vuser_login_name;

  CHECK_NUMBER (uid, 0);
  pw = (struct passwd *) getpwuid (XINT (uid));
  return (pw ? build_string (pw->pw_name) : Qnil);
}

DEFUN ("user-real-login-name", Fuser_real_login_name, Suser_real_login_name,
  0, 0, 0,
  "Return the name of the user's real uid, as a string.\n\
This ignores the environment variables LOGNAME and USER, so it differs from\n\
`user-login-name' when running under `su'.")
  ()
{
  /* Set up the user name info if we didn't do it before.
     (That can happen if Emacs is dumpable
     but you decide to run `temacs -l loadup' and not dump.  */
  if (INTEGERP (Vuser_login_name))
    init_editfns ();
  return Vuser_real_login_name;
}

DEFUN ("user-uid", Fuser_uid, Suser_uid, 0, 0, 0,
  "Return the effective uid of Emacs, as an integer.")
  ()
{
  return make_number (geteuid ());
}

DEFUN ("user-real-uid", Fuser_real_uid, Suser_real_uid, 0, 0, 0,
  "Return the real uid of Emacs, as an integer.")
  ()
{
  return make_number (getuid ());
}

DEFUN ("user-full-name", Fuser_full_name, Suser_full_name, 0, 1, 0,
  "Return the full name of the user logged in, as a string.\n\
If the full name corresponding to Emacs's userid is not known,\n\
return \"unknown\".\n\
\n\
If optional argument UID is an integer, return the full name of the user\n\
with that uid, or nil if there is no such user.\n\
If UID is a string, return the full name of the user with that login\n\
name, or nil if there is no such user.")
  (uid)
     Lisp_Object uid;
{
  struct passwd *pw;
  register unsigned char *p, *q;
  extern char *index ();
  Lisp_Object full;

  if (NILP (uid))
    return Vuser_full_name; 
  else if (NUMBERP (uid))
    pw = (struct passwd *) getpwuid (XINT (uid));
  else if (STRINGP (uid)) 
    pw = (struct passwd *) getpwnam (XSTRING (uid)->data);
  else
    error ("Invalid UID specification");

  if (!pw)
    return Qnil;
  
  p = (unsigned char *) USER_FULL_NAME;
  /* Chop off everything after the first comma. */
  q = (unsigned char *) index (p, ',');
  full = make_string (p, q ? q - p : strlen (p));
  
#ifdef AMPERSAND_FULL_NAME
  p = XSTRING (full)->data;
  q = (unsigned char *) index (p, '&');
  /* Substitute the login name for the &, upcasing the first character.  */
  if (q)
    {
      register unsigned char *r;
      Lisp_Object login;

      login = Fuser_login_name (make_number (pw->pw_uid));
      r = (unsigned char *) alloca (strlen (p) + XSTRING (login)->size + 1);
      bcopy (p, r, q - p);
      r[q - p] = 0;
      strcat (r, XSTRING (login)->data);
      r[q - p] = UPCASE (r[q - p]);
      strcat (r, q + 1);
      full = build_string (r);
    }
#endif /* AMPERSAND_FULL_NAME */

  return full;
}

DEFUN ("system-name", Fsystem_name, Ssystem_name, 0, 0, 0,
  "Return the name of the machine you are running on, as a string.")
  ()
{
  return Vsystem_name;
}

/* For the benefit of callers who don't want to include lisp.h */
char *
get_system_name ()
{
  if (STRINGP (Vsystem_name))
    return (char *) XSTRING (Vsystem_name)->data;
  else
    return "";
}

DEFUN ("emacs-pid", Femacs_pid, Semacs_pid, 0, 0, 0,
  "Return the process ID of Emacs, as an integer.")
  ()
{
  return make_number (getpid ());
}

DEFUN ("current-time", Fcurrent_time, Scurrent_time, 0, 0, 0,
  "Return the current time, as the number of seconds since 1970-01-01 00:00:00.\n\
The time is returned as a list of three integers.  The first has the\n\
most significant 16 bits of the seconds, while the second has the\n\
least significant 16 bits.  The third integer gives the microsecond\n\
count.\n\
\n\
The microsecond count is zero on systems that do not provide\n\
resolution finer than a second.")
  ()
{
  EMACS_TIME t;
  Lisp_Object result[3];

  EMACS_GET_TIME (t);
  XSETINT (result[0], (EMACS_SECS (t) >> 16) & 0xffff);
  XSETINT (result[1], (EMACS_SECS (t) >> 0)  & 0xffff);
  XSETINT (result[2], EMACS_USECS (t));

  return Flist (3, result);
}


static int
lisp_time_argument (specified_time, result)
     Lisp_Object specified_time;
     time_t *result;
{
  if (NILP (specified_time))
    return time (result) != -1;
  else
    {
      Lisp_Object high, low;
      high = Fcar (specified_time);
      CHECK_NUMBER (high, 0);
      low = Fcdr (specified_time);
      if (CONSP (low))
	low = Fcar (low);
      CHECK_NUMBER (low, 0);
      *result = (XINT (high) << 16) + (XINT (low) & 0xffff);
      return *result >> 16 == XINT (high);
    }
}

/* Write information into buffer S of size MAXSIZE, according to the
   FORMAT of length FORMAT_LEN, using time information taken from *TP.
   Return the number of bytes written, not including the terminating
   '\0'.  If S is NULL, nothing will be written anywhere; so to
   determine how many bytes would be written, use NULL for S and
   ((size_t) -1) for MAXSIZE.

   This function behaves like emacs_strftime, except it allows null
   bytes in FORMAT.  */
static size_t
emacs_memftime (s, maxsize, format, format_len, tp)
      char *s;
      size_t maxsize;
      const char *format;
      size_t format_len;
      const struct tm *tp;
{
  size_t total = 0;

  /* Loop through all the null-terminated strings in the format
     argument.  Normally there's just one null-terminated string, but
     there can be arbitrarily many, concatenated together, if the
     format contains '\0' bytes.  emacs_strftime stops at the first
     '\0' byte so we must invoke it separately for each such string.  */
  for (;;)
    {
      size_t len;
      size_t result;

      if (s)
	s[0] = '\1';

      result = emacs_strftime (s, maxsize, format, tp);

      if (s)
	{
	  if (result == 0 && s[0] != '\0')
	    return 0;
	  s += result + 1;
	}

      maxsize -= result + 1;
      total += result;
      len = strlen (format);
      if (len == format_len)
	return total;
      total++;
      format += len + 1;
      format_len -= len + 1;
    }
}

/*
DEFUN ("format-time-string", Fformat_time_string, Sformat_time_string, 1, 3, 0,
  "Use FORMAT-STRING to format the time TIME, or now if omitted.\n\
TIME is specified as (HIGH LOW . IGNORED) or (HIGH . LOW), as returned by\n\
`current-time' or `file-attributes'.\n\
The third, optional, argument UNIVERSAL, if non-nil, means describe TIME\n\
as Universal Time; nil means describe TIME in the local time zone.\n\
The value is a copy of FORMAT-STRING, but with certain constructs replaced\n\
by text that describes the specified date and time in TIME:\n\
\n\
%Y is the year, %y within the century, %C the century.\n\
%G is the year corresponding to the ISO week, %g within the century.\n\
%m is the numeric month.\n\
%b and %h are the locale's abbreviated month name, %B the full name.\n\
%d is the day of the month, zero-padded, %e is blank-padded.\n\
%u is the numeric day of week from 1 (Monday) to 7, %w from 0 (Sunday) to 6.\n\
%a is the locale's abbreviated name of the day of week, %A the full name.\n\
%U is the week number starting on Sunday, %W starting on Monday,\n\
 %V according to ISO 8601.\n\
%j is the day of the year.\n\
\n\
%H is the hour on a 24-hour clock, %I is on a 12-hour clock, %k is like %H\n\
 only blank-padded, %l is like %I blank-padded.\n\
%p is the locale's equivalent of either AM or PM.\n\
%M is the minute.\n\
%S is the second.\n\
%Z is the time zone name, %z is the numeric form.\n\
%s is the number of seconds since 1970-01-01 00:00:00 +0000.\n\
\n\
%c is the locale's date and time format.\n\
%x is the locale's \"preferred\" date format.\n\
%D is like \"%m/%d/%y\".\n\
\n\
%R is like \"%H:%M\", %T is like \"%H:%M:%S\", %r is like \"%I:%M:%S %p\".\n\
%X is the locale's \"preferred\" time format.\n\
\n\
Finally, %n is a newline, %t is a tab, %% is a literal %.\n\
\n\
Certain flags and modifiers are available with some format controls.\n\
The flags are `_' and `-'.  For certain characters X, %_X is like %X,\n\
but padded with blanks; %-X is like %X, but without padding.\n\
%NX (where N stands for an integer) is like %X,\n\
but takes up at least N (a number) positions.\n\
The modifiers are `E' and `O'.  For certain characters X,\n\
%EX is a locale's alternative version of %X;\n\
%OX is like %X, but uses the locale's number symbols.\n\
\n\
For example, to produce full ISO 8601 format, use \"%Y-%m-%dT%T%z\".")
  (format_string, time, universal)
*/

DEFUN ("format-time-string", Fformat_time_string, Sformat_time_string, 1, 3, 0,
  0 /* See immediately above */)
  (format_string, time, universal)
     Lisp_Object format_string, time, universal;
{
  time_t value;
  int size;
  struct tm *tm;

  CHECK_STRING (format_string, 1);

  if (! lisp_time_argument (time, &value))
    error ("Invalid time specification");

  /* This is probably enough.  */
  size = STRING_BYTES (XSTRING (format_string)) * 6 + 50;

  tm = NILP (universal) ? localtime (&value) : gmtime (&value);
  if (! tm)
    error ("Specified time is not representable");

  while (1)
    {
      char *buf = (char *) alloca (size + 1);
      int result;

      buf[0] = '\1';
      result = emacs_memftime (buf, size, XSTRING (format_string)->data,
			       STRING_BYTES (XSTRING (format_string)),
			       tm);
      if ((result > 0 && result < size) || (result == 0 && buf[0] == '\0'))
	return make_string (buf, result);

      /* If buffer was too small, make it bigger and try again.  */
      result = emacs_memftime (NULL, (size_t) -1,
			       XSTRING (format_string)->data,
			       STRING_BYTES (XSTRING (format_string)),
			       tm);
      size = result + 1;
    }
}

DEFUN ("decode-time", Fdecode_time, Sdecode_time, 0, 1, 0,
  "Decode a time value as (SEC MINUTE HOUR DAY MONTH YEAR DOW DST ZONE).\n\
The optional SPECIFIED-TIME should be a list of (HIGH LOW . IGNORED)\n\
or (HIGH . LOW), as from `current-time' and `file-attributes', or `nil'\n\
to use the current time.  The list has the following nine members:\n\
SEC is an integer between 0 and 60; SEC is 60 for a leap second, which\n\
only some operating systems support.  MINUTE is an integer between 0 and 59.\n\
HOUR is an integer between 0 and 23.  DAY is an integer between 1 and 31.\n\
MONTH is an integer between 1 and 12.  YEAR is an integer indicating the\n\
four-digit year.  DOW is the day of week, an integer between 0 and 6, where\n\
0 is Sunday.  DST is t if daylight savings time is effect, otherwise nil.\n\
ZONE is an integer indicating the number of seconds east of Greenwich.\n\
\(Note that Common Lisp has different meanings for DOW and ZONE.)")
  (specified_time)
     Lisp_Object specified_time;
{
  time_t time_spec;
  struct tm save_tm;
  struct tm *decoded_time;
  Lisp_Object list_args[9];
  
  if (! lisp_time_argument (specified_time, &time_spec))
    error ("Invalid time specification");

  decoded_time = localtime (&time_spec);
  if (! decoded_time)
    error ("Specified time is not representable");
  XSETFASTINT (list_args[0], decoded_time->tm_sec);
  XSETFASTINT (list_args[1], decoded_time->tm_min);
  XSETFASTINT (list_args[2], decoded_time->tm_hour);
  XSETFASTINT (list_args[3], decoded_time->tm_mday);
  XSETFASTINT (list_args[4], decoded_time->tm_mon + 1);
  XSETINT (list_args[5], decoded_time->tm_year + 1900);
  XSETFASTINT (list_args[6], decoded_time->tm_wday);
  list_args[7] = (decoded_time->tm_isdst)? Qt : Qnil;

  /* Make a copy, in case gmtime modifies the struct.  */
  save_tm = *decoded_time;
  decoded_time = gmtime (&time_spec);
  if (decoded_time == 0)
    list_args[8] = Qnil;
  else
    XSETINT (list_args[8], tm_diff (&save_tm, decoded_time));
  return Flist (9, list_args);
}

DEFUN ("encode-time", Fencode_time, Sencode_time, 6, MANY, 0,
  "Convert SECOND, MINUTE, HOUR, DAY, MONTH, YEAR and ZONE to internal time.\n\
This is the reverse operation of `decode-time', which see.\n\
ZONE defaults to the current time zone rule.  This can\n\
be a string or t (as from `set-time-zone-rule'), or it can be a list\n\
\(as from `current-time-zone') or an integer (as from `decode-time')\n\
applied without consideration for daylight savings time.\n\
\n\
You can pass more than 7 arguments; then the first six arguments\n\
are used as SECOND through YEAR, and the *last* argument is used as ZONE.\n\
The intervening arguments are ignored.\n\
This feature lets (apply 'encode-time (decode-time ...)) work.\n\
\n\
Out-of-range values for SEC, MINUTE, HOUR, DAY, or MONTH are allowed;\n\
for example, a DAY of 0 means the day preceding the given month.\n\
Year numbers less than 100 are treated just like other year numbers.\n\
If you want them to stand for years in this century, you must do that yourself.")
  (nargs, args)
     int nargs;
     register Lisp_Object *args;
{
  time_t time;
  struct tm tm;
  Lisp_Object zone = (nargs > 6 ? args[nargs - 1] : Qnil);

  CHECK_NUMBER (args[0], 0);	/* second */
  CHECK_NUMBER (args[1], 1);	/* minute */
  CHECK_NUMBER (args[2], 2);	/* hour */
  CHECK_NUMBER (args[3], 3);	/* day */
  CHECK_NUMBER (args[4], 4);	/* month */
  CHECK_NUMBER (args[5], 5);	/* year */

  tm.tm_sec = XINT (args[0]);
  tm.tm_min = XINT (args[1]);
  tm.tm_hour = XINT (args[2]);
  tm.tm_mday = XINT (args[3]);
  tm.tm_mon = XINT (args[4]) - 1;
  tm.tm_year = XINT (args[5]) - 1900;
  tm.tm_isdst = -1;

  if (CONSP (zone))
    zone = Fcar (zone);
  if (NILP (zone))
    time = mktime (&tm);
  else
    {
      char tzbuf[100];
      char *tzstring;
      char **oldenv = environ, **newenv;
      
      if (EQ (zone, Qt))
	tzstring = "UTC0";
      else if (STRINGP (zone))
	tzstring = (char *) XSTRING (zone)->data;
      else if (INTEGERP (zone))
	{
	  int abszone = abs (XINT (zone));
	  sprintf (tzbuf, "XXX%s%d:%02d:%02d", "-" + (XINT (zone) < 0),
		   abszone / (60*60), (abszone/60) % 60, abszone % 60);
	  tzstring = tzbuf;
	}
      else
	error ("Invalid time zone specification");

      /* Set TZ before calling mktime; merely adjusting mktime's returned 
	 value doesn't suffice, since that would mishandle leap seconds.  */
      set_time_zone_rule (tzstring);

      time = mktime (&tm);

      /* Restore TZ to previous value.  */
      newenv = environ;
      environ = oldenv;
      xfree (newenv);
#ifdef LOCALTIME_CACHE
      tzset ();
#endif
    }

  if (time == (time_t) -1)
    error ("Specified time is not representable");

  return make_time (time);
}

DEFUN ("current-time-string", Fcurrent_time_string, Scurrent_time_string, 0, 1, 0,
  "Return the current time, as a human-readable string.\n\
Programs can use this function to decode a time,\n\
since the number of columns in each field is fixed.\n\
The format is `Sun Sep 16 01:03:52 1973'.\n\
However, see also the functions `decode-time' and `format-time-string'\n\
which provide a much more powerful and general facility.\n\
\n\
If an argument is given, it specifies a time to format\n\
instead of the current time.  The argument should have the form:\n\
  (HIGH . LOW)\n\
or the form:\n\
  (HIGH LOW . IGNORED).\n\
Thus, you can use times obtained from `current-time'\n\
and from `file-attributes'.")
  (specified_time)
     Lisp_Object specified_time;
{
  time_t value;
  char buf[30];
  register char *tem;

  if (! lisp_time_argument (specified_time, &value))
    value = -1;
  tem = (char *) ctime (&value);

  strncpy (buf, tem, 24);
  buf[24] = 0;

  return build_string (buf);
}

#define TM_YEAR_BASE 1900

/* Yield A - B, measured in seconds.
   This function is copied from the GNU C Library.  */
static int
tm_diff (a, b)
     struct tm *a, *b;
{
  /* Compute intervening leap days correctly even if year is negative.
     Take care to avoid int overflow in leap day calculations,
     but it's OK to assume that A and B are close to each other.  */
  int a4 = (a->tm_year >> 2) + (TM_YEAR_BASE >> 2) - ! (a->tm_year & 3);
  int b4 = (b->tm_year >> 2) + (TM_YEAR_BASE >> 2) - ! (b->tm_year & 3);
  int a100 = a4 / 25 - (a4 % 25 < 0);
  int b100 = b4 / 25 - (b4 % 25 < 0);
  int a400 = a100 >> 2;
  int b400 = b100 >> 2;
  int intervening_leap_days = (a4 - b4) - (a100 - b100) + (a400 - b400);
  int years = a->tm_year - b->tm_year;
  int days = (365 * years + intervening_leap_days
	      + (a->tm_yday - b->tm_yday));
  return (60 * (60 * (24 * days + (a->tm_hour - b->tm_hour))
		+ (a->tm_min - b->tm_min))
	  + (a->tm_sec - b->tm_sec));
}

DEFUN ("current-time-zone", Fcurrent_time_zone, Scurrent_time_zone, 0, 1, 0,
  "Return the offset and name for the local time zone.\n\
This returns a list of the form (OFFSET NAME).\n\
OFFSET is an integer number of seconds ahead of UTC (east of Greenwich).\n\
    A negative value means west of Greenwich.\n\
NAME is a string giving the name of the time zone.\n\
If an argument is given, it specifies when the time zone offset is determined\n\
instead of using the current time.  The argument should have the form:\n\
  (HIGH . LOW)\n\
or the form:\n\
  (HIGH LOW . IGNORED).\n\
Thus, you can use times obtained from `current-time'\n\
and from `file-attributes'.\n\
\n\
Some operating systems cannot provide all this information to Emacs;\n\
in this case, `current-time-zone' returns a list containing nil for\n\
the data it can't find.")
  (specified_time)
     Lisp_Object specified_time;
{
  time_t value;
  struct tm *t;
  struct tm gmt;

  if (lisp_time_argument (specified_time, &value)
      && (t = gmtime (&value)) != 0
      && (gmt = *t, t = localtime (&value)) != 0)
    {
      int offset = tm_diff (t, &gmt);
      char *s = 0;
      char buf[6];
#ifdef HAVE_TM_ZONE
      if (t->tm_zone)
	s = (char *)t->tm_zone;
#else /* not HAVE_TM_ZONE */
#ifdef HAVE_TZNAME
      if (t->tm_isdst == 0 || t->tm_isdst == 1)
	s = tzname[t->tm_isdst];
#endif
#endif /* not HAVE_TM_ZONE */
      if (!s)
	{
	  /* No local time zone name is available; use "+-NNNN" instead.  */
	  int am = (offset < 0 ? -offset : offset) / 60;
	  sprintf (buf, "%c%02d%02d", (offset < 0 ? '-' : '+'), am/60, am%60);
	  s = buf;
	}
      return Fcons (make_number (offset), Fcons (build_string (s), Qnil));
    }
  else
    return Fmake_list (make_number (2), Qnil);
}

/* This holds the value of `environ' produced by the previous
   call to Fset_time_zone_rule, or 0 if Fset_time_zone_rule
   has never been called.  */
static char **environbuf;

DEFUN ("set-time-zone-rule", Fset_time_zone_rule, Sset_time_zone_rule, 1, 1, 0,
  "Set the local time zone using TZ, a string specifying a time zone rule.\n\
If TZ is nil, use implementation-defined default time zone information.\n\
If TZ is t, use Universal Time.")
  (tz)
     Lisp_Object tz;
{
  char *tzstring;

  if (NILP (tz))
    tzstring = 0;
  else if (EQ (tz, Qt))
    tzstring = "UTC0";
  else
    {
      CHECK_STRING (tz, 0);
      tzstring = (char *) XSTRING (tz)->data;
    }

  set_time_zone_rule (tzstring);
  if (environbuf)
    free (environbuf);
  environbuf = environ;

  return Qnil;
}

#ifdef LOCALTIME_CACHE

/* These two values are known to load tz files in buggy implementations,
   i.e. Solaris 1 executables running under either Solaris 1 or Solaris 2.
   Their values shouldn't matter in non-buggy implementations.
   We don't use string literals for these strings, 
   since if a string in the environment is in readonly
   storage, it runs afoul of bugs in SVR4 and Solaris 2.3.
   See Sun bugs 1113095 and 1114114, ``Timezone routines
   improperly modify environment''.  */

static char set_time_zone_rule_tz1[] = "TZ=GMT+0";
static char set_time_zone_rule_tz2[] = "TZ=GMT+1";

#endif

/* Set the local time zone rule to TZSTRING.
   This allocates memory into `environ', which it is the caller's
   responsibility to free.  */
void
set_time_zone_rule (tzstring)
     char *tzstring;
{
  int envptrs;
  char **from, **to, **newenv;

  /* Make the ENVIRON vector longer with room for TZSTRING.  */
  for (from = environ; *from; from++)
    continue;
  envptrs = from - environ + 2;
  newenv = to = (char **) xmalloc (envptrs * sizeof (char *)
				   + (tzstring ? strlen (tzstring) + 4 : 0));

  /* Add TZSTRING to the end of environ, as a value for TZ.  */
  if (tzstring)
    {
      char *t = (char *) (to + envptrs);
      strcpy (t, "TZ=");
      strcat (t, tzstring);
      *to++ = t;
    }

  /* Copy the old environ vector elements into NEWENV,
     but don't copy the TZ variable.
     So we have only one definition of TZ, which came from TZSTRING.  */
  for (from = environ; *from; from++)
    if (strncmp (*from, "TZ=", 3) != 0)
      *to++ = *from;
  *to = 0;

  environ = newenv;

  /* If we do have a TZSTRING, NEWENV points to the vector slot where
     the TZ variable is stored.  If we do not have a TZSTRING,
     TO points to the vector slot which has the terminating null.  */

#ifdef LOCALTIME_CACHE
  {
    /* In SunOS 4.1.3_U1 and 4.1.4, if TZ has a value like
       "US/Pacific" that loads a tz file, then changes to a value like
       "XXX0" that does not load a tz file, and then changes back to
       its original value, the last change is (incorrectly) ignored.
       Also, if TZ changes twice in succession to values that do
       not load a tz file, tzset can dump core (see Sun bug#1225179).
       The following code works around these bugs.  */

    if (tzstring)
      {
	/* Temporarily set TZ to a value that loads a tz file
	   and that differs from tzstring.  */
	char *tz = *newenv;
	*newenv = (strcmp (tzstring, set_time_zone_rule_tz1 + 3) == 0
		   ? set_time_zone_rule_tz2 : set_time_zone_rule_tz1);
	tzset ();
	*newenv = tz;
      }
    else
      {
	/* The implied tzstring is unknown, so temporarily set TZ to
	   two different values that each load a tz file.  */
	*to = set_time_zone_rule_tz1;
	to[1] = 0;
	tzset ();
	*to = set_time_zone_rule_tz2;
	tzset ();
	*to = 0;
      }

    /* Now TZ has the desired value, and tzset can be invoked safely.  */
  }

  tzset ();
#endif
}

/* Insert NARGS Lisp objects in the array ARGS by calling INSERT_FUNC
   (if a type of object is Lisp_Int) or INSERT_FROM_STRING_FUNC (if a
   type of object is Lisp_String).  INHERIT is passed to
   INSERT_FROM_STRING_FUNC as the last argument.  */

void
general_insert_function (insert_func, insert_from_string_func,
			 inherit, nargs, args)
     void (*insert_func) P_ ((unsigned char *, int));
     void (*insert_from_string_func) P_ ((Lisp_Object, int, int, int, int, int));
     int inherit, nargs;
     register Lisp_Object *args;
{
  register int argnum;
  register Lisp_Object val;

  for (argnum = 0; argnum < nargs; argnum++)
    {
      val = args[argnum];
    retry:
      if (INTEGERP (val))
	{
	  unsigned char workbuf[4], *str;
	  int len;

	  if (!NILP (current_buffer->enable_multibyte_characters))
	    len = CHAR_STRING (XFASTINT (val), workbuf, str);
	  else
	    {
	      workbuf[0] = (SINGLE_BYTE_CHAR_P (XINT (val))
			    ? XINT (val)
			    : multibyte_char_to_unibyte (XINT (val), Qnil));
	      str = workbuf;
	      len = 1;
	    }
	  (*insert_func) (str, len);
	}
      else if (STRINGP (val))
	{
	  (*insert_from_string_func) (val, 0, 0,
				      XSTRING (val)->size,
				      STRING_BYTES (XSTRING (val)),
				      inherit);
	}
      else
	{
	  val = wrong_type_argument (Qchar_or_string_p, val);
	  goto retry;
	}
    }
}

void
insert1 (arg)
     Lisp_Object arg;
{
  Finsert (1, &arg);
}


/* Callers passing one argument to Finsert need not gcpro the
   argument "array", since the only element of the array will
   not be used after calling insert or insert_from_string, so
   we don't care if it gets trashed.  */

DEFUN ("insert", Finsert, Sinsert, 0, MANY, 0,
  "Insert the arguments, either strings or characters, at point.\n\
Point and before-insertion markers move forward to end up\n\
 after the inserted text.\n\
Any other markers at the point of insertion remain before the text.\n\
\n\
If the current buffer is multibyte, unibyte strings are converted\n\
to multibyte for insertion (see `unibyte-char-to-multibyte').\n\
If the current buffer is unibyte, multibyte strings are converted\n\
to unibyte for insertion.")
  (nargs, args)
     int nargs;
     register Lisp_Object *args;
{
  general_insert_function (insert, insert_from_string, 0, nargs, args);
  return Qnil;
}

DEFUN ("insert-and-inherit", Finsert_and_inherit, Sinsert_and_inherit,
   0, MANY, 0,
  "Insert the arguments at point, inheriting properties from adjoining text.\n\
Point and before-insertion markers move forward to end up\n\
 after the inserted text.\n\
Any other markers at the point of insertion remain before the text.\n\
\n\
If the current buffer is multibyte, unibyte strings are converted\n\
to multibyte for insertion (see `unibyte-char-to-multibyte').\n\
If the current buffer is unibyte, multibyte strings are converted\n\
to unibyte for insertion.")
  (nargs, args)
     int nargs;
     register Lisp_Object *args;
{
  general_insert_function (insert_and_inherit, insert_from_string, 1,
			   nargs, args);
  return Qnil;
}

DEFUN ("insert-before-markers", Finsert_before_markers, Sinsert_before_markers, 0, MANY, 0,
  "Insert strings or characters at point, relocating markers after the text.\n\
Point and markers move forward to end up after the inserted text.\n\
\n\
If the current buffer is multibyte, unibyte strings are converted\n\
to multibyte for insertion (see `unibyte-char-to-multibyte').\n\
If the current buffer is unibyte, multibyte strings are converted\n\
to unibyte for insertion.")
  (nargs, args)
     int nargs;
     register Lisp_Object *args;
{
  general_insert_function (insert_before_markers,
			   insert_from_string_before_markers, 0,
			   nargs, args);
  return Qnil;
}

DEFUN ("insert-before-markers-and-inherit", Finsert_and_inherit_before_markers,
  Sinsert_and_inherit_before_markers, 0, MANY, 0,
  "Insert text at point, relocating markers and inheriting properties.\n\
Point and markers move forward to end up after the inserted text.\n\
\n\
If the current buffer is multibyte, unibyte strings are converted\n\
to multibyte for insertion (see `unibyte-char-to-multibyte').\n\
If the current buffer is unibyte, multibyte strings are converted\n\
to unibyte for insertion.")
  (nargs, args)
     int nargs;
     register Lisp_Object *args;
{
  general_insert_function (insert_before_markers_and_inherit,
			   insert_from_string_before_markers, 1,
			   nargs, args);
  return Qnil;
}

DEFUN ("insert-char", Finsert_char, Sinsert_char, 2, 3, 0,
  "Insert COUNT (second arg) copies of CHARACTER (first arg).\n\
Both arguments are required.\n\
Point, and before-insertion markers, are relocated as in the function `insert'.\n\
The optional third arg INHERIT, if non-nil, says to inherit text properties\n\
from adjoining text, if those properties are sticky.")
  (character, count, inherit)
       Lisp_Object character, count, inherit;
{
  register unsigned char *string;
  register int strlen;
  register int i, n;
  int len;
  unsigned char workbuf[4], *str;

  CHECK_NUMBER (character, 0);
  CHECK_NUMBER (count, 1);

  if (!NILP (current_buffer->enable_multibyte_characters))
    len = CHAR_STRING (XFASTINT (character), workbuf, str);
  else
    workbuf[0] = XFASTINT (character), str = workbuf, len = 1;
  n = XINT (count) * len;
  if (n <= 0)
    return Qnil;
  strlen = min (n, 256 * len);
  string = (unsigned char *) alloca (strlen);
  for (i = 0; i < strlen; i++)
    string[i] = str[i % len];
  while (n >= strlen)
    {
      QUIT;
      if (!NILP (inherit))
	insert_and_inherit (string, strlen);
      else
	insert (string, strlen);
      n -= strlen;
    }
  if (n > 0)
    {
      if (!NILP (inherit))
	insert_and_inherit (string, n);
      else
	insert (string, n);
    }
  return Qnil;
}


/* Making strings from buffer contents.  */

/* Return a Lisp_String containing the text of the current buffer from
   START to END.  If text properties are in use and the current buffer
   has properties in the range specified, the resulting string will also
   have them, if PROPS is nonzero.

   We don't want to use plain old make_string here, because it calls
   make_uninit_string, which can cause the buffer arena to be
   compacted.  make_string has no way of knowing that the data has
   been moved, and thus copies the wrong data into the string.  This
   doesn't effect most of the other users of make_string, so it should
   be left as is.  But we should use this function when conjuring
   buffer substrings.  */

Lisp_Object
make_buffer_string (start, end, props)
     int start, end;
     int props;
{
  int start_byte = CHAR_TO_BYTE (start);
  int end_byte = CHAR_TO_BYTE (end);

  return make_buffer_string_both (start, start_byte, end, end_byte, props);
}

/* Return a Lisp_String containing the text of the current buffer from
   START / START_BYTE to END / END_BYTE.

   If text properties are in use and the current buffer
   has properties in the range specified, the resulting string will also
   have them, if PROPS is nonzero.

   We don't want to use plain old make_string here, because it calls
   make_uninit_string, which can cause the buffer arena to be
   compacted.  make_string has no way of knowing that the data has
   been moved, and thus copies the wrong data into the string.  This
   doesn't effect most of the other users of make_string, so it should
   be left as is.  But we should use this function when conjuring
   buffer substrings.  */

Lisp_Object
make_buffer_string_both (start, start_byte, end, end_byte, props)
     int start, start_byte, end, end_byte;
     int props;
{
  Lisp_Object result, tem, tem1;

  if (start < GPT && GPT < end)
    move_gap (start);

  if (! NILP (current_buffer->enable_multibyte_characters))
    result = make_uninit_multibyte_string (end - start, end_byte - start_byte);
  else
    result = make_uninit_string (end - start);
  bcopy (BYTE_POS_ADDR (start_byte), XSTRING (result)->data,
	 end_byte - start_byte);

  /* If desired, update and copy the text properties.  */
#ifdef USE_TEXT_PROPERTIES
  if (props)
    {
      update_buffer_properties (start, end);

      tem = Fnext_property_change (make_number (start), Qnil, make_number (end));
      tem1 = Ftext_properties_at (make_number (start), Qnil);

      if (XINT (tem) != end || !NILP (tem1))
	copy_intervals_to_string (result, current_buffer, start,
				  end - start);
    }
#endif

  return result;
}

/* Call Vbuffer_access_fontify_functions for the range START ... END
   in the current buffer, if necessary.  */

static void
update_buffer_properties (start, end)
     int start, end;
{
#ifdef USE_TEXT_PROPERTIES
  /* If this buffer has some access functions,
     call them, specifying the range of the buffer being accessed.  */
  if (!NILP (Vbuffer_access_fontify_functions))
    {
      Lisp_Object args[3];
      Lisp_Object tem;

      args[0] = Qbuffer_access_fontify_functions;
      XSETINT (args[1], start);
      XSETINT (args[2], end);

      /* But don't call them if we can tell that the work
	 has already been done.  */
      if (!NILP (Vbuffer_access_fontified_property))
	{
	  tem = Ftext_property_any (args[1], args[2],
				    Vbuffer_access_fontified_property,
				    Qnil, Qnil);
	  if (! NILP (tem))
	    Frun_hook_with_args (3, args);
	}
      else
	Frun_hook_with_args (3, args);
    }
#endif
}

DEFUN ("buffer-substring", Fbuffer_substring, Sbuffer_substring, 2, 2, 0,
  "Return the contents of part of the current buffer as a string.\n\
The two arguments START and END are character positions;\n\
they can be in either order.\n\
The string returned is multibyte if the buffer is multibyte.")
  (start, end)
     Lisp_Object start, end;
{
  register int b, e;

  validate_region (&start, &end);
  b = XINT (start);
  e = XINT (end);

  return make_buffer_string (b, e, 1);
}

DEFUN ("buffer-substring-no-properties", Fbuffer_substring_no_properties,
       Sbuffer_substring_no_properties, 2, 2, 0,
  "Return the characters of part of the buffer, without the text properties.\n\
The two arguments START and END are character positions;\n\
they can be in either order.")
  (start, end)
     Lisp_Object start, end;
{
  register int b, e;

  validate_region (&start, &end);
  b = XINT (start);
  e = XINT (end);

  return make_buffer_string (b, e, 0);
}

DEFUN ("buffer-string", Fbuffer_string, Sbuffer_string, 0, 0, 0,
  "Return the contents of the current buffer as a string.\n\
If narrowing is in effect, this function returns only the visible part\n\
of the buffer.")
  ()
{
  return make_buffer_string (BEGV, ZV, 1);
}

DEFUN ("insert-buffer-substring", Finsert_buffer_substring, Sinsert_buffer_substring,
  1, 3, 0,
  "Insert before point a substring of the contents of buffer BUFFER.\n\
BUFFER may be a buffer or a buffer name.\n\
Arguments START and END are character numbers specifying the substring.\n\
They default to the beginning and the end of BUFFER.")
  (buf, start, end)
     Lisp_Object buf, start, end;
{
  register int b, e, temp;
  register struct buffer *bp, *obuf;
  Lisp_Object buffer;

  buffer = Fget_buffer (buf);
  if (NILP (buffer))
    nsberror (buf);
  bp = XBUFFER (buffer);
  if (NILP (bp->name))
    error ("Selecting deleted buffer");

  if (NILP (start))
    b = BUF_BEGV (bp);
  else
    {
      CHECK_NUMBER_COERCE_MARKER (start, 0);
      b = XINT (start);
    }
  if (NILP (end))
    e = BUF_ZV (bp);
  else
    {
      CHECK_NUMBER_COERCE_MARKER (end, 1);
      e = XINT (end);
    }

  if (b > e)
    temp = b, b = e, e = temp;

  if (!(BUF_BEGV (bp) <= b && e <= BUF_ZV (bp)))
    args_out_of_range (start, end);

  obuf = current_buffer;
  set_buffer_internal_1 (bp);
  update_buffer_properties (b, e);
  set_buffer_internal_1 (obuf);

  insert_from_buffer (bp, b, e - b, 0);
  return Qnil;
}

DEFUN ("compare-buffer-substrings", Fcompare_buffer_substrings, Scompare_buffer_substrings,
  6, 6, 0,
  "Compare two substrings of two buffers; return result as number.\n\
the value is -N if first string is less after N-1 chars,\n\
+N if first string is greater after N-1 chars, or 0 if strings match.\n\
Each substring is represented as three arguments: BUFFER, START and END.\n\
That makes six args in all, three for each substring.\n\n\
The value of `case-fold-search' in the current buffer\n\
determines whether case is significant or ignored.")
  (buffer1, start1, end1, buffer2, start2, end2)
     Lisp_Object buffer1, start1, end1, buffer2, start2, end2;
{
  register int begp1, endp1, begp2, endp2, temp;
  register struct buffer *bp1, *bp2;
  register Lisp_Object *trt
    = (!NILP (current_buffer->case_fold_search)
       ? XCHAR_TABLE (current_buffer->case_canon_table)->contents : 0);
  int chars = 0;
  int i1, i2, i1_byte, i2_byte;

  /* Find the first buffer and its substring.  */

  if (NILP (buffer1))
    bp1 = current_buffer;
  else
    {
      Lisp_Object buf1;
      buf1 = Fget_buffer (buffer1);
      if (NILP (buf1))
	nsberror (buffer1);
      bp1 = XBUFFER (buf1);
      if (NILP (bp1->name))
	error ("Selecting deleted buffer");
    }

  if (NILP (start1))
    begp1 = BUF_BEGV (bp1);
  else
    {
      CHECK_NUMBER_COERCE_MARKER (start1, 1);
      begp1 = XINT (start1);
    }
  if (NILP (end1))
    endp1 = BUF_ZV (bp1);
  else
    {
      CHECK_NUMBER_COERCE_MARKER (end1, 2);
      endp1 = XINT (end1);
    }

  if (begp1 > endp1)
    temp = begp1, begp1 = endp1, endp1 = temp;

  if (!(BUF_BEGV (bp1) <= begp1
	&& begp1 <= endp1
        && endp1 <= BUF_ZV (bp1)))
    args_out_of_range (start1, end1);

  /* Likewise for second substring.  */

  if (NILP (buffer2))
    bp2 = current_buffer;
  else
    {
      Lisp_Object buf2;
      buf2 = Fget_buffer (buffer2);
      if (NILP (buf2))
	nsberror (buffer2);
      bp2 = XBUFFER (buf2);
      if (NILP (bp2->name))
	error ("Selecting deleted buffer");
    }

  if (NILP (start2))
    begp2 = BUF_BEGV (bp2);
  else
    {
      CHECK_NUMBER_COERCE_MARKER (start2, 4);
      begp2 = XINT (start2);
    }
  if (NILP (end2))
    endp2 = BUF_ZV (bp2);
  else
    {
      CHECK_NUMBER_COERCE_MARKER (end2, 5);
      endp2 = XINT (end2);
    }

  if (begp2 > endp2)
    temp = begp2, begp2 = endp2, endp2 = temp;

  if (!(BUF_BEGV (bp2) <= begp2
	&& begp2 <= endp2
        && endp2 <= BUF_ZV (bp2)))
    args_out_of_range (start2, end2);

  i1 = begp1;
  i2 = begp2;
  i1_byte = buf_charpos_to_bytepos (bp1, i1);
  i2_byte = buf_charpos_to_bytepos (bp2, i2);

  while (i1 < endp1 && i2 < endp2)
    {
      /* When we find a mismatch, we must compare the
	 characters, not just the bytes.  */
      int c1, c2;

      if (! NILP (bp1->enable_multibyte_characters))
	{
	  c1 = BUF_FETCH_MULTIBYTE_CHAR (bp1, i1_byte);
	  BUF_INC_POS (bp1, i1_byte);
	  i1++;
	}
      else
	{
	  c1 = BUF_FETCH_BYTE (bp1, i1);
	  c1 = unibyte_char_to_multibyte (c1);
	  i1++;
	}

      if (! NILP (bp2->enable_multibyte_characters))
	{
	  c2 = BUF_FETCH_MULTIBYTE_CHAR (bp2, i2_byte);
	  BUF_INC_POS (bp2, i2_byte);
	  i2++;
	}
      else
	{
	  c2 = BUF_FETCH_BYTE (bp2, i2);
	  c2 = unibyte_char_to_multibyte (c2);
	  i2++;
	}

      if (trt)
	{
	  c1 = XINT (trt[c1]);
	  c2 = XINT (trt[c2]);
	}
      if (c1 < c2)
	return make_number (- 1 - chars);
      if (c1 > c2)
	return make_number (chars + 1);

      chars++;
    }

  /* The strings match as far as they go.
     If one is shorter, that one is less.  */
  if (chars < endp1 - begp1)
    return make_number (chars + 1);
  else if (chars < endp2 - begp2)
    return make_number (- chars - 1);

  /* Same length too => they are equal.  */
  return make_number (0);
}

static Lisp_Object
subst_char_in_region_unwind (arg)
     Lisp_Object arg;
{
  return current_buffer->undo_list = arg;
}

static Lisp_Object
subst_char_in_region_unwind_1 (arg)
     Lisp_Object arg;
{
  return current_buffer->filename = arg;
}

DEFUN ("subst-char-in-region", Fsubst_char_in_region,
  Ssubst_char_in_region, 4, 5, 0,
  "From START to END, replace FROMCHAR with TOCHAR each time it occurs.\n\
If optional arg NOUNDO is non-nil, don't record this change for undo\n\
and don't mark the buffer as really changed.\n\
Both characters must have the same length of multi-byte form.")
  (start, end, fromchar, tochar, noundo)
     Lisp_Object start, end, fromchar, tochar, noundo;
{
  register int pos, pos_byte, stop, i, len, end_byte;
  int changed = 0;
  unsigned char fromwork[4], *fromstr, towork[4], *tostr, *p;
  int count = specpdl_ptr - specpdl;
  int maybe_byte_combining = 0;

  validate_region (&start, &end);
  CHECK_NUMBER (fromchar, 2);
  CHECK_NUMBER (tochar, 3);

  if (! NILP (current_buffer->enable_multibyte_characters))
    {
      len = CHAR_STRING (XFASTINT (fromchar), fromwork, fromstr);
      if (CHAR_STRING (XFASTINT (tochar), towork, tostr) != len)
	error ("Characters in subst-char-in-region have different byte-lengths");
      if (len == 1)
	/* If *TOSTR is in the range 0x80..0x9F, it may be combined
           with the after bytes.  If it is in the range 0xA0..0xFF, it
           may be combined with the before bytes.  */
	maybe_byte_combining = !ASCII_BYTE_P (*tostr);
    }
  else
    {
      len = 1;
      fromwork[0] = XFASTINT (fromchar), fromstr = fromwork;
      towork[0] = XFASTINT (tochar), tostr = towork;
    }

  pos = XINT (start);
  pos_byte = CHAR_TO_BYTE (pos);
  stop = CHAR_TO_BYTE (XINT (end));
  end_byte = stop;

  /* If we don't want undo, turn off putting stuff on the list.
     That's faster than getting rid of things,
     and it prevents even the entry for a first change.
     Also inhibit locking the file.  */
  if (!NILP (noundo))
    {
      record_unwind_protect (subst_char_in_region_unwind,
			     current_buffer->undo_list);
      current_buffer->undo_list = Qt;
      /* Don't do file-locking.  */
      record_unwind_protect (subst_char_in_region_unwind_1,
			     current_buffer->filename);
      current_buffer->filename = Qnil;
    }

  if (pos_byte < GPT_BYTE)
    stop = min (stop, GPT_BYTE);
  while (1)
    {
      int pos_byte_next = pos_byte;

      if (pos_byte >= stop)
	{
	  if (pos_byte >= end_byte) break;
	  stop = end_byte;
	}
      p = BYTE_POS_ADDR (pos_byte);
      INC_POS (pos_byte_next);
      if (pos_byte_next - pos_byte == len
	  && p[0] == fromstr[0]
	  && (len == 1
	      || (p[1] == fromstr[1]
		  && (len == 2 || (p[2] == fromstr[2]
				 && (len == 3 || p[3] == fromstr[3]))))))
	{
	  if (! changed)
	    {
	      modify_region (current_buffer, XINT (start), XINT (end));

	      if (! NILP (noundo))
		{
		  if (MODIFF - 1 == SAVE_MODIFF)
		    SAVE_MODIFF++;
		  if (MODIFF - 1 == current_buffer->auto_save_modified)
		    current_buffer->auto_save_modified++;
		}

	      changed = 1;
	    }

	  /* Take care of the case where the new character
	     combines with neighboring bytes.  */ 
	  if (maybe_byte_combining
	      && (CHAR_HEAD_P (*tostr)
		  ? ! CHAR_HEAD_P (FETCH_BYTE (pos_byte + 1))
		  : (pos_byte > BEG_BYTE
		     && ! ASCII_BYTE_P (FETCH_BYTE (pos_byte - 1)))))
	    {
	      Lisp_Object tem, string;

	      struct gcpro gcpro1;

	      tem = current_buffer->undo_list;
	      GCPRO1 (tem);

	      /* Make a multibyte string containing this single-byte
		  character.  */
	      string = make_multibyte_string (tostr, 1, 1);
	      /* replace_range is less efficient, because it moves the gap,
		 but it handles combining correctly.  */
	      replace_range (pos, pos + 1, string,
			     0, 0, 1);
	      pos_byte_next = CHAR_TO_BYTE (pos);
	      if (pos_byte_next > pos_byte)
		/* Before combining happened.  We should not increment
		   POS.  So, to cancel the later increment of POS,
		   decrease it now.  */
		pos--;
	      else
		INC_POS (pos_byte_next);
		
	      if (! NILP (noundo))
		current_buffer->undo_list = tem;

	      UNGCPRO;
	    }
	  else
	    {
	      if (NILP (noundo))
		record_change (pos, 1);
	      for (i = 0; i < len; i++) *p++ = tostr[i];
	    }
	}
      pos_byte = pos_byte_next;
      pos++;
    }

  if (changed)
    signal_after_change (XINT (start),
			 XINT (end) - XINT (start), XINT (end) - XINT (start));

  unbind_to (count, Qnil);
  return Qnil;
}

DEFUN ("translate-region", Ftranslate_region, Stranslate_region, 3, 3, 0,
  "From START to END, translate characters according to TABLE.\n\
TABLE is a string; the Nth character in it is the mapping\n\
for the character with code N.\n\
This function does not alter multibyte characters.\n\
It returns the number of characters changed.")
  (start, end, table)
     Lisp_Object start;
     Lisp_Object end;
     register Lisp_Object table;
{
  register int pos_byte, stop;	/* Limits of the region. */
  register unsigned char *tt;	/* Trans table. */
  register int nc;		/* New character. */
  int cnt;			/* Number of changes made. */
  int size;			/* Size of translate table. */
  int pos;
  int multibyte = !NILP (current_buffer->enable_multibyte_characters);

  validate_region (&start, &end);
  CHECK_STRING (table, 2);

  size = STRING_BYTES (XSTRING (table));
  tt = XSTRING (table)->data;

  pos_byte = CHAR_TO_BYTE (XINT (start));
  stop = CHAR_TO_BYTE (XINT (end));
  modify_region (current_buffer, XINT (start), XINT (end));
  pos = XINT (start);

  cnt = 0;
  for (; pos_byte < stop; )
    {
      register unsigned char *p = BYTE_POS_ADDR (pos_byte);
      int len;
      int oc;
      int pos_byte_next;

      if (multibyte)
	oc = STRING_CHAR_AND_LENGTH (p, stop - pos_byte, len);
      else
	oc = *p, len = 1;
      pos_byte_next = pos_byte + len;
      if (oc < size && len == 1)
	{
	  nc = tt[oc];
	  if (nc != oc)
	    {
	      /* Take care of the case where the new character
		 combines with neighboring bytes.  */ 
	      if (multibyte
		  && !ASCII_BYTE_P (nc)
		  && (CHAR_HEAD_P (nc)
		      ? ! CHAR_HEAD_P (FETCH_BYTE (pos_byte + 1))
		      : (pos_byte > BEG_BYTE
			 && ! ASCII_BYTE_P (FETCH_BYTE (pos_byte - 1)))))
		{
		  Lisp_Object string;

		  string = make_multibyte_string (tt + oc, 1, 1);
		  /* This is less efficient, because it moves the gap,
		     but it handles combining correctly.  */
		  replace_range (pos, pos + 1, string,
				 1, 0, 1);
		  pos_byte_next = CHAR_TO_BYTE (pos);
		  if (pos_byte_next > pos_byte)
		    /* Before combining happened.  We should not
		       increment POS.  So, to cancel the later
		       increment of POS, we decrease it now.  */
		    pos--;
		  else
		    INC_POS (pos_byte_next);
		}
	      else
		{
		  record_change (pos, 1);
		  *p = nc;
		  signal_after_change (pos, 1, 1);
		}
	      ++cnt;
	    }
	}
      pos_byte = pos_byte_next;
      pos++;
    }

  return make_number (cnt);
}

DEFUN ("delete-region", Fdelete_region, Sdelete_region, 2, 2, "r",
  "Delete the text between point and mark.\n\
When called from a program, expects two arguments,\n\
positions (integers or markers) specifying the stretch to be deleted.")
  (start, end)
     Lisp_Object start, end;
{
  validate_region (&start, &end);
  del_range (XINT (start), XINT (end));
  return Qnil;
}

DEFUN ("widen", Fwiden, Swiden, 0, 0, "",
  "Remove restrictions (narrowing) from current buffer.\n\
This allows the buffer's full text to be seen and edited.")
  ()
{
  if (BEG != BEGV || Z != ZV)
    current_buffer->clip_changed = 1;
  BEGV = BEG;
  BEGV_BYTE = BEG_BYTE;
  SET_BUF_ZV_BOTH (current_buffer, Z, Z_BYTE);
  /* Changing the buffer bounds invalidates any recorded current column.  */
  invalidate_current_column ();
  return Qnil;
}

DEFUN ("narrow-to-region", Fnarrow_to_region, Snarrow_to_region, 2, 2, "r",
  "Restrict editing in this buffer to the current region.\n\
The rest of the text becomes temporarily invisible and untouchable\n\
but is not deleted; if you save the buffer in a file, the invisible\n\
text is included in the file.  \\[widen] makes all visible again.\n\
See also `save-restriction'.\n\
\n\
When calling from a program, pass two arguments; positions (integers\n\
or markers) bounding the text that should remain visible.")
  (start, end)
     register Lisp_Object start, end;
{
  CHECK_NUMBER_COERCE_MARKER (start, 0);
  CHECK_NUMBER_COERCE_MARKER (end, 1);

  if (XINT (start) > XINT (end))
    {
      Lisp_Object tem;
      tem = start; start = end; end = tem;
    }

  if (!(BEG <= XINT (start) && XINT (start) <= XINT (end) && XINT (end) <= Z))
    args_out_of_range (start, end);

  if (BEGV != XFASTINT (start) || ZV != XFASTINT (end))
    current_buffer->clip_changed = 1;

  SET_BUF_BEGV (current_buffer, XFASTINT (start));
  SET_BUF_ZV (current_buffer, XFASTINT (end));
  if (PT < XFASTINT (start))
    SET_PT (XFASTINT (start));
  if (PT > XFASTINT (end))
    SET_PT (XFASTINT (end));
  /* Changing the buffer bounds invalidates any recorded current column.  */
  invalidate_current_column ();
  return Qnil;
}

Lisp_Object
save_restriction_save ()
{
  register Lisp_Object bottom, top;
  /* Note: I tried using markers here, but it does not win
     because insertion at the end of the saved region
     does not advance mh and is considered "outside" the saved region. */
  XSETFASTINT (bottom, BEGV - BEG);
  XSETFASTINT (top, Z - ZV);

  return Fcons (Fcurrent_buffer (), Fcons (bottom, top));
}

Lisp_Object
save_restriction_restore (data)
     Lisp_Object data;
{
  register struct buffer *buf;
  register int newhead, newtail;
  register Lisp_Object tem;
  int obegv, ozv;

  buf = XBUFFER (XCONS (data)->car);

  data = XCONS (data)->cdr;

  tem = XCONS (data)->car;
  newhead = XINT (tem);
  tem = XCONS (data)->cdr;
  newtail = XINT (tem);
  if (newhead + newtail > BUF_Z (buf) - BUF_BEG (buf))
    {
      newhead = 0;
      newtail = 0;
    }

  obegv = BUF_BEGV (buf);
  ozv = BUF_ZV (buf);

  SET_BUF_BEGV (buf, BUF_BEG (buf) + newhead);
  SET_BUF_ZV (buf, BUF_Z (buf) - newtail);

  if (obegv != BUF_BEGV (buf) || ozv != BUF_ZV (buf))
    current_buffer->clip_changed = 1;

  /* If point is outside the new visible range, move it inside. */
  SET_BUF_PT_BOTH (buf,
		   clip_to_bounds (BUF_BEGV (buf), BUF_PT (buf), BUF_ZV (buf)),
		   clip_to_bounds (BUF_BEGV_BYTE (buf), BUF_PT_BYTE (buf),
				   BUF_ZV_BYTE (buf)));

  return Qnil;
}

DEFUN ("save-restriction", Fsave_restriction, Ssave_restriction, 0, UNEVALLED, 0,
  "Execute BODY, saving and restoring current buffer's restrictions.\n\
The buffer's restrictions make parts of the beginning and end invisible.\n\
\(They are set up with `narrow-to-region' and eliminated with `widen'.)\n\
This special form, `save-restriction', saves the current buffer's restrictions\n\
when it is entered, and restores them when it is exited.\n\
So any `narrow-to-region' within BODY lasts only until the end of the form.\n\
The old restrictions settings are restored\n\
even in case of abnormal exit (throw or error).\n\
\n\
The value returned is the value of the last form in BODY.\n\
\n\
`save-restriction' can get confused if, within the BODY, you widen\n\
and then make changes outside the area within the saved restrictions.\n\
See Info node `(elisp)Narrowing' for details and an appropriate technique.\n\
\n\
Note: if you are using both `save-excursion' and `save-restriction',\n\
use `save-excursion' outermost:\n\
    (save-excursion (save-restriction ...))")
  (body)
     Lisp_Object body;
{
  register Lisp_Object val;
  int count = specpdl_ptr - specpdl;

  record_unwind_protect (save_restriction_restore, save_restriction_save ());
  val = Fprogn (body);
  return unbind_to (count, val);
}

/* Buffer for the most recent text displayed by Fmessage.  */
static char *message_text;

/* Allocated length of that buffer.  */
static int message_length;

DEFUN ("message", Fmessage, Smessage, 1, MANY, 0,
  "Print a one-line message at the bottom of the screen.\n\
The first argument is a format control string, and the rest are data\n\
to be formatted under control of the string.  See `format' for details.\n\
\n\
If the first argument is nil, clear any existing message; let the\n\
minibuffer contents show.")
  (nargs, args)
     int nargs;
     Lisp_Object *args;
{
  if (NILP (args[0]))
    {
      message (0);
      return Qnil;
    }
  else
    {
      register Lisp_Object val;
      val = Fformat (nargs, args);
      /* Copy the data so that it won't move when we GC.  */
      if (! message_text)
	{
	  message_text = (char *)xmalloc (80);
	  message_length = 80;
	}
      if (STRING_BYTES (XSTRING (val)) > message_length)
	{
	  message_length = STRING_BYTES (XSTRING (val));
	  message_text = (char *)xrealloc (message_text, message_length);
	}
      bcopy (XSTRING (val)->data, message_text, STRING_BYTES (XSTRING (val)));
      message2 (message_text, STRING_BYTES (XSTRING (val)),
		STRING_MULTIBYTE (val));
      return val;
    }
}

DEFUN ("message-box", Fmessage_box, Smessage_box, 1, MANY, 0,
  "Display a message, in a dialog box if possible.\n\
If a dialog box is not available, use the echo area.\n\
The first argument is a format control string, and the rest are data\n\
to be formatted under control of the string.  See `format' for details.\n\
\n\
If the first argument is nil, clear any existing message; let the\n\
minibuffer contents show.")
  (nargs, args)
     int nargs;
     Lisp_Object *args;
{
  if (NILP (args[0]))
    {
      message (0);
      return Qnil;
    }
  else
    {
      register Lisp_Object val;
      val = Fformat (nargs, args);
#ifdef HAVE_MENUS
      {
	Lisp_Object pane, menu, obj;
	struct gcpro gcpro1;
	pane = Fcons (Fcons (build_string ("OK"), Qt), Qnil);
	GCPRO1 (pane);
	menu = Fcons (val, pane);
	obj = Fx_popup_dialog (Qt, menu);
	UNGCPRO;
	return val;
      }
#else /* not HAVE_MENUS */
      /* Copy the data so that it won't move when we GC.  */
      if (! message_text)
	{
	  message_text = (char *)xmalloc (80);
	  message_length = 80;
	}
      if (STRING_BYTES (XSTRING (val)) > message_length)
	{
	  message_length = STRING_BYTES (XSTRING (val));
	  message_text = (char *)xrealloc (message_text, message_length);
	}
      bcopy (XSTRING (val)->data, message_text, STRING_BYTES (XSTRING (val)));
      message2 (message_text, STRING_BYTES (XSTRING (val)),
		STRING_MULTIBYTE (val));
      return val;
#endif /* not HAVE_MENUS */
    }
}
#ifdef HAVE_MENUS
extern Lisp_Object last_nonmenu_event;
#endif

DEFUN ("message-or-box", Fmessage_or_box, Smessage_or_box, 1, MANY, 0,
  "Display a message in a dialog box or in the echo area.\n\
If this command was invoked with the mouse, use a dialog box.\n\
Otherwise, use the echo area.\n\
The first argument is a format control string, and the rest are data\n\
to be formatted under control of the string.  See `format' for details.\n\
\n\
If the first argument is nil, clear any existing message; let the\n\
minibuffer contents show.")
  (nargs, args)
     int nargs;
     Lisp_Object *args;
{
#ifdef HAVE_MENUS
  if (NILP (last_nonmenu_event) || CONSP (last_nonmenu_event))
    return Fmessage_box (nargs, args);
#endif
  return Fmessage (nargs, args);
}

DEFUN ("current-message", Fcurrent_message, Scurrent_message, 0, 0, 0,
  "Return the string currently displayed in the echo area, or nil if none.")
  ()
{
  return (echo_area_glyphs
	  ? make_string (echo_area_glyphs, echo_area_glyphs_length)
	  : Qnil);
}

/* Number of bytes that STRING will occupy when put into the result.
   MULTIBYTE is nonzero if the result should be multibyte.  */

#define CONVERTED_BYTE_SIZE(MULTIBYTE, STRING)				\
  (((MULTIBYTE) && ! STRING_MULTIBYTE (STRING))				\
   ? count_size_as_multibyte (XSTRING (STRING)->data,			\
			      STRING_BYTES (XSTRING (STRING)))		\
   : STRING_BYTES (XSTRING (STRING)))

DEFUN ("format", Fformat, Sformat, 1, MANY, 0,
  "Format a string out of a control-string and arguments.\n\
The first argument is a control string.\n\
The other arguments are substituted into it to make the result, a string.\n\
It may contain %-sequences meaning to substitute the next argument.\n\
%s means print a string argument.  Actually, prints any object, with `princ'.\n\
%d means print as number in decimal (%o octal, %x hex).\n\
%e means print a number in exponential notation.\n\
%f means print a number in decimal-point notation.\n\
%g means print a number in exponential notation\n\
  or decimal-point notation, whichever uses fewer characters.\n\
%c means print a number as a single character.\n\
%S means print any object as an s-expression (using `prin1').\n\
  The argument used for %d, %o, %x, %e, %f, %g or %c must be a number.\n\
Use %% to put a single % into the output.")
  (nargs, args)
     int nargs;
     register Lisp_Object *args;
{
  register int n;		/* The number of the next arg to substitute */
  register int total;		/* An estimate of the final length */
  char *buf, *p;
  register unsigned char *format, *end;
  int length, nchars;
  /* Nonzero if the output should be a multibyte string,
     which is true if any of the inputs is one.  */
  int multibyte = 0;
  /* When we make a multibyte string, we must pay attention to the
     byte combining problem, i.e., a byte may be combined with a
     multibyte charcter of the previous string.  This flag tells if we
     must consider such a situation or not.  */
  int maybe_combine_byte;
  unsigned char *this_format;
  int longest_format;
  Lisp_Object val;

  extern char *index ();

  /* It should not be necessary to GCPRO ARGS, because
     the caller in the interpreter should take care of that.  */

  /* Try to determine whether the result should be multibyte.
     This is not always right; sometimes the result needs to be multibyte
     because of an object that we will pass through prin1,
     and in that case, we won't know it here.  */
  for (n = 0; n < nargs; n++)
    if (STRINGP (args[n]) && STRING_MULTIBYTE (args[n]))
      multibyte = 1;

  CHECK_STRING (args[0], 0);

  /* If we start out planning a unibyte result,
     and later find it has to be multibyte, we jump back to retry.  */
 retry:

  format = XSTRING (args[0])->data;
  end = format + STRING_BYTES (XSTRING (args[0]));
  longest_format = 0;

  /* Make room in result for all the non-%-codes in the control string.  */
  total = 5 + CONVERTED_BYTE_SIZE (multibyte, args[0]);

  /* Add to TOTAL enough space to hold the converted arguments.  */

  n = 0;
  while (format != end)
    if (*format++ == '%')
      {
	int minlen, thissize = 0;
	unsigned char *this_format_start = format - 1;

	/* Process a numeric arg and skip it.  */
	minlen = atoi (format);
	if (minlen < 0)
	  minlen = - minlen;

	while ((*format >= '0' && *format <= '9')
	       || *format == '-' || *format == ' ' || *format == '.')
	  format++;

	if (format - this_format_start + 1 > longest_format)
	  longest_format = format - this_format_start + 1;

	if (format == end)
	  error ("Format string ends in middle of format specifier");
	if (*format == '%')
	  format++;
	else if (++n >= nargs)
	  error ("Not enough arguments for format string");
	else if (*format == 'S')
	  {
	    /* For `S', prin1 the argument and then treat like a string.  */
	    register Lisp_Object tem;
	    tem = Fprin1_to_string (args[n], Qnil);
	    if (STRING_MULTIBYTE (tem) && ! multibyte)
	      {
		multibyte = 1;
		goto retry;
	      }
	    args[n] = tem;
	    goto string;
	  }
	else if (SYMBOLP (args[n]))
	  {
	    XSETSTRING (args[n], XSYMBOL (args[n])->name);
	    if (STRING_MULTIBYTE (args[n]) && ! multibyte)
	      {
		multibyte = 1;
		goto retry;
	      }
	    goto string;
	  }
	else if (STRINGP (args[n]))
	  {
	  string:
	    if (*format != 's' && *format != 'S')
	      error ("Format specifier doesn't match argument type");
	    thissize = CONVERTED_BYTE_SIZE (multibyte, args[n]);
	  }
	/* Would get MPV otherwise, since Lisp_Int's `point' to low memory.  */
	else if (INTEGERP (args[n]) && *format != 's')
	  {
#ifdef LISP_FLOAT_TYPE
	    /* The following loop assumes the Lisp type indicates
	       the proper way to pass the argument.
	       So make sure we have a flonum if the argument should
	       be a double.  */
	    if (*format == 'e' || *format == 'f' || *format == 'g')
	      args[n] = Ffloat (args[n]);
	    else
#endif
	      if (*format != 'd' && *format != 'o' && *format != 'x'
		  && *format != 'i' && *format != 'X' && *format != 'c')
		error ("Invalid format operation %%%c", *format);

	    thissize = 30;	
	    if (*format == 'c'
		&& (! SINGLE_BYTE_CHAR_P (XINT (args[n]))
		    || XINT (args[n]) == 0))
	      {
		if (! multibyte)
		  {
		    multibyte = 1;
		    goto retry;
		  }
		args[n] = Fchar_to_string (args[n]);
		thissize = STRING_BYTES (XSTRING (args[n]));
	      }
	  }
#ifdef LISP_FLOAT_TYPE
	else if (FLOATP (args[n]) && *format != 's')
	  {
	    if (! (*format == 'e' || *format == 'f' || *format == 'g'))
	      args[n] = Ftruncate (args[n], Qnil);
	    thissize = 200;
	  }
#endif
	else
	  {
	    /* Anything but a string, convert to a string using princ.  */
	    register Lisp_Object tem;
	    tem = Fprin1_to_string (args[n], Qt);
	    if (STRING_MULTIBYTE (tem) & ! multibyte)
	      {
		multibyte = 1;
		goto retry;
	      }
	    args[n] = tem;
	    goto string;
	  }
	
	if (thissize < minlen)
	  thissize = minlen;

	total += thissize + 4;
      }

  /* Now we can no longer jump to retry.
     TOTAL and LONGEST_FORMAT are known for certain.  */

  this_format = (unsigned char *) alloca (longest_format + 1);

  /* Allocate the space for the result.
     Note that TOTAL is an overestimate.  */
  if (total < 1000)
    buf = (char *) alloca (total + 1);
  else
    buf = (char *) xmalloc (total + 1);

  p = buf;
  nchars = 0;
  n = 0;

  /* Scan the format and store result in BUF.  */
  format = XSTRING (args[0])->data;
  maybe_combine_byte = 0;
  while (format != end)
    {
      if (*format == '%')
	{
	  int minlen;
	  int negative = 0;
	  unsigned char *this_format_start = format;

	  format++;

	  /* Process a numeric arg and skip it.  */
	  minlen = atoi (format);
	  if (minlen < 0)
	    minlen = - minlen, negative = 1;

	  while ((*format >= '0' && *format <= '9')
		 || *format == '-' || *format == ' ' || *format == '.')
	    format++;

	  if (*format++ == '%')
	    {
	      *p++ = '%';
	      nchars++;
	      continue;
	    }

	  ++n;

	  if (STRINGP (args[n]))
	    {
	      int padding, nbytes;
	      int width = strwidth (XSTRING (args[n])->data,
				    STRING_BYTES (XSTRING (args[n])));

	      /* If spec requires it, pad on right with spaces.  */
	      padding = minlen - width;
	      if (! negative)
		while (padding-- > 0)
		  {
		    *p++ = ' ';
		    nchars++;
		  }

	      if (p > buf
		  && multibyte
		  && !ASCII_BYTE_P (*((unsigned char *) p - 1))
		  && STRING_MULTIBYTE (args[n])
		  && !CHAR_HEAD_P (XSTRING (args[n])->data[0]))
		maybe_combine_byte = 1;
	      nbytes = copy_text (XSTRING (args[n])->data, p,
				  STRING_BYTES (XSTRING (args[n])),
				  STRING_MULTIBYTE (args[n]), multibyte);
	      p += nbytes;
	      nchars += XSTRING (args[n])->size;

	      if (negative)
		while (padding-- > 0)
		  {
		    *p++ = ' ';
		    nchars++;
		  }
	    }
	  else if (INTEGERP (args[n]) || FLOATP (args[n]))
	    {
	      int this_nchars;

	      bcopy (this_format_start, this_format,
		     format - this_format_start);
	      this_format[format - this_format_start] = 0;

	      if (INTEGERP (args[n]))
		sprintf (p, this_format, XINT (args[n]));
	      else
		sprintf (p, this_format, XFLOAT (args[n])->data);

	      if (p > buf
		  && multibyte
		  && !ASCII_BYTE_P (*((unsigned char *) p - 1))
		  && !CHAR_HEAD_P (*((unsigned char *) p)))
		maybe_combine_byte = 1;
	      this_nchars = strlen (p);
	      p += this_nchars;
	      nchars += this_nchars;
	    }
	}
      else if (STRING_MULTIBYTE (args[0]))
	{
	  /* Copy a whole multibyte character.  */
	  if (p > buf
	      && multibyte
	      && !ASCII_BYTE_P (*((unsigned char *) p - 1))
	      && !CHAR_HEAD_P (*format))
	    maybe_combine_byte = 1;
	  *p++ = *format++;
	  while (! CHAR_HEAD_P (*format)) *p++ = *format++;
	  nchars++;
	}
      else if (multibyte)
	{
	  /* Convert a single-byte character to multibyte.  */
	  int len = copy_text (format, p, 1, 0, 1);

	  p += len;
	  format++;
	  nchars++;
	}
      else
	*p++ = *format++, nchars++;
    }

  if (maybe_combine_byte)
    nchars = multibyte_chars_in_text (buf, p - buf);
  val = make_specified_string (buf, nchars, p - buf, multibyte);

  /* If we allocated BUF with malloc, free it too.  */
  if (total >= 1000)
    xfree (buf);

  return val;
}

/* VARARGS 1 */
Lisp_Object
#ifdef NO_ARG_ARRAY
format1 (string1, arg0, arg1, arg2, arg3, arg4)
     EMACS_INT arg0, arg1, arg2, arg3, arg4;
#else
format1 (string1)
#endif
     char *string1;
{
  char buf[100];
#ifdef NO_ARG_ARRAY
  EMACS_INT args[5];
  args[0] = arg0;
  args[1] = arg1;
  args[2] = arg2;
  args[3] = arg3;
  args[4] = arg4;
  doprnt (buf, sizeof buf, string1, (char *)0, 5, (char **) args);
#else
  doprnt (buf, sizeof buf, string1, (char *)0, 5, &string1 + 1);
#endif
  return build_string (buf);
}

DEFUN ("char-equal", Fchar_equal, Schar_equal, 2, 2, 0,
  "Return t if two characters match, optionally ignoring case.\n\
Both arguments must be characters (i.e. integers).\n\
Case is ignored if `case-fold-search' is non-nil in the current buffer.")
  (c1, c2)
     register Lisp_Object c1, c2;
{
  int i1, i2;
  CHECK_NUMBER (c1, 0);
  CHECK_NUMBER (c2, 1);

  if (XINT (c1) == XINT (c2))
    return Qt;
  if (NILP (current_buffer->case_fold_search))
    return Qnil;

  /* Do these in separate statements,
     then compare the variables.
     because of the way DOWNCASE uses temp variables.  */
  i1 = DOWNCASE (XFASTINT (c1));
  i2 = DOWNCASE (XFASTINT (c2));
  return (i1 == i2 ? Qt :  Qnil);
}

/* Transpose the markers in two regions of the current buffer, and
   adjust the ones between them if necessary (i.e.: if the regions
   differ in size).

   START1, END1 are the character positions of the first region.
   START1_BYTE, END1_BYTE are the byte positions.
   START2, END2 are the character positions of the second region.
   START2_BYTE, END2_BYTE are the byte positions.

   Traverses the entire marker list of the buffer to do so, adding an
   appropriate amount to some, subtracting from some, and leaving the
   rest untouched.  Most of this is copied from adjust_markers in insdel.c.
  
   It's the caller's job to ensure that START1 <= END1 <= START2 <= END2.  */

void
transpose_markers (start1, end1, start2, end2,
		   start1_byte, end1_byte, start2_byte, end2_byte)
     register int start1, end1, start2, end2;
     register int start1_byte, end1_byte, start2_byte, end2_byte;
{
  register int amt1, amt1_byte, amt2, amt2_byte, diff, diff_byte, mpos;
  register Lisp_Object marker;

  /* Update point as if it were a marker.  */
  if (PT < start1)
    ;
  else if (PT < end1)
    TEMP_SET_PT_BOTH (PT + (end2 - end1),
		      PT_BYTE + (end2_byte - end1_byte));
  else if (PT < start2)
    TEMP_SET_PT_BOTH (PT + (end2 - start2) - (end1 - start1),
		      (PT_BYTE + (end2_byte - start2_byte)
		       - (end1_byte - start1_byte)));
  else if (PT < end2)
    TEMP_SET_PT_BOTH (PT - (start2 - start1),
		      PT_BYTE - (start2_byte - start1_byte));

  /* We used to adjust the endpoints here to account for the gap, but that
     isn't good enough.  Even if we assume the caller has tried to move the
     gap out of our way, it might still be at start1 exactly, for example;
     and that places it `inside' the interval, for our purposes.  The amount
     of adjustment is nontrivial if there's a `denormalized' marker whose
     position is between GPT and GPT + GAP_SIZE, so it's simpler to leave
     the dirty work to Fmarker_position, below.  */

  /* The difference between the region's lengths */
  diff = (end2 - start2) - (end1 - start1);
  diff_byte = (end2_byte - start2_byte) - (end1_byte - start1_byte);
  
  /* For shifting each marker in a region by the length of the other
     region plus the distance between the regions.  */
  amt1 = (end2 - start2) + (start2 - end1);
  amt2 = (end1 - start1) + (start2 - end1);
  amt1_byte = (end2_byte - start2_byte) + (start2_byte - end1_byte);
  amt2_byte = (end1_byte - start1_byte) + (start2_byte - end1_byte);

  for (marker = BUF_MARKERS (current_buffer); !NILP (marker);
       marker = XMARKER (marker)->chain)
    {
      mpos = marker_byte_position (marker);
      if (mpos >= start1_byte && mpos < end2_byte)
	{
	  if (mpos < end1_byte)
	    mpos += amt1_byte;
	  else if (mpos < start2_byte)
	    mpos += diff_byte;
	  else
	    mpos -= amt2_byte;
	  XMARKER (marker)->bytepos = mpos;
	}
      mpos = XMARKER (marker)->charpos;
      if (mpos >= start1 && mpos < end2)
	{
	  if (mpos < end1)
	    mpos += amt1;
	  else if (mpos < start2)
	    mpos += diff;
	  else
	    mpos -= amt2;
	}
      XMARKER (marker)->charpos = mpos;
    }
}

DEFUN ("transpose-regions", Ftranspose_regions, Stranspose_regions, 4, 5, 0,
       "Transpose region START1 to END1 with START2 to END2.\n\
The regions may not be overlapping, because the size of the buffer is\n\
never changed in a transposition.\n\
\n\
Optional fifth arg LEAVE_MARKERS, if non-nil, means don't update\n\
any markers that happen to be located in the regions.\n\
\n\
Transposing beyond buffer boundaries is an error.")
  (startr1, endr1, startr2, endr2, leave_markers)
     Lisp_Object startr1, endr1, startr2, endr2, leave_markers;
{
  register int start1, end1, start2, end2;
  int start1_byte, start2_byte, len1_byte, len2_byte;
  int gap, len1, len_mid, len2;
  unsigned char *start1_addr, *start2_addr, *temp;
  int combined_before_bytes_1, combined_after_bytes_1;
  int combined_before_bytes_2, combined_after_bytes_2;
  struct gcpro gcpro1, gcpro2;

#ifdef USE_TEXT_PROPERTIES
  INTERVAL cur_intv, tmp_interval1, tmp_interval_mid, tmp_interval2;
  cur_intv = BUF_INTERVALS (current_buffer);
#endif /* USE_TEXT_PROPERTIES */

  validate_region (&startr1, &endr1);
  validate_region (&startr2, &endr2);

  start1 = XFASTINT (startr1);
  end1 = XFASTINT (endr1);
  start2 = XFASTINT (startr2);
  end2 = XFASTINT (endr2);
  gap = GPT;

  /* Swap the regions if they're reversed.  */
  if (start2 < end1)
    {
      register int glumph = start1;
      start1 = start2;
      start2 = glumph;
      glumph = end1;
      end1 = end2;
      end2 = glumph;
    }

  len1 = end1 - start1;
  len2 = end2 - start2;

  if (start2 < end1)
    error ("Transposed regions overlap");
  else if (start1 == end1 || start2 == end2)
    error ("Transposed region has length 0");

  /* The possibilities are:
     1. Adjacent (contiguous) regions, or separate but equal regions
     (no, really equal, in this case!), or
     2. Separate regions of unequal size.
     
     The worst case is usually No. 2.  It means that (aside from
     potential need for getting the gap out of the way), there also
     needs to be a shifting of the text between the two regions.  So
     if they are spread far apart, we are that much slower... sigh.  */

  /* It must be pointed out that the really studly thing to do would
     be not to move the gap at all, but to leave it in place and work
     around it if necessary.  This would be extremely efficient,
     especially considering that people are likely to do
     transpositions near where they are working interactively, which
     is exactly where the gap would be found.  However, such code
     would be much harder to write and to read.  So, if you are
     reading this comment and are feeling squirrely, by all means have
     a go!  I just didn't feel like doing it, so I will simply move
     the gap the minimum distance to get it out of the way, and then
     deal with an unbroken array.  */

  /* Make sure the gap won't interfere, by moving it out of the text
     we will operate on.  */
  if (start1 < gap && gap < end2)
    {
      if (gap - start1 < end2 - gap)
	move_gap (start1);
      else
	move_gap (end2);
    }

  start1_byte = CHAR_TO_BYTE (start1);
  start2_byte = CHAR_TO_BYTE (start2);
  len1_byte = CHAR_TO_BYTE (end1) - start1_byte;
  len2_byte = CHAR_TO_BYTE (end2) - start2_byte;

  if (end1 == start2)
    {
      combined_before_bytes_2
	= count_combining_before (BYTE_POS_ADDR (start2_byte),
				  len2_byte, start1, start1_byte);
      combined_before_bytes_1
	= count_combining_before (BYTE_POS_ADDR (start1_byte),
				  len1_byte, end2, start2_byte + len2_byte);
      combined_after_bytes_1
	= count_combining_after (BYTE_POS_ADDR (start1_byte),
				 len1_byte, end2, start2_byte + len2_byte);
      combined_after_bytes_2 = 0;
    }
  else
    {
      combined_before_bytes_2
	= count_combining_before (BYTE_POS_ADDR (start2_byte),
				  len2_byte, start1, start1_byte);
      combined_before_bytes_1
	= count_combining_before (BYTE_POS_ADDR (start1_byte),
				  len1_byte, start2, start2_byte);
      combined_after_bytes_2
	= count_combining_after (BYTE_POS_ADDR (start2_byte),
				 len2_byte, end1, start1_byte + len1_byte);
      combined_after_bytes_1
	= count_combining_after (BYTE_POS_ADDR (start1_byte),
				 len1_byte, end2, start2_byte + len2_byte);
    }

  /* If any combining is going to happen, do this the stupid way,
     because replace handles combining properly.  */
  if (combined_before_bytes_1 || combined_before_bytes_2
      || combined_after_bytes_1 || combined_after_bytes_2)
    {
      Lisp_Object text1, text2;

      text1 = text2 = Qnil;
      GCPRO2 (text1, text2);

      text1 = make_buffer_string_both (start1, start1_byte,
				       end1, start1_byte + len1_byte, 1);
      text2 = make_buffer_string_both (start2, start2_byte,
				       end2, start2_byte + len2_byte, 1);

      transpose_markers (start1, end1, start2, end2,
			 start1_byte, start1_byte + len1_byte,
			 start2_byte, start2_byte + len2_byte);

      replace_range (start2, end2, text1, 1, 0, 0);
      replace_range (start1, end1, text2, 1, 0, 0);

      UNGCPRO;
      return Qnil;
    }
      
  /* Hmmm... how about checking to see if the gap is large
     enough to use as the temporary storage?  That would avoid an
     allocation... interesting.  Later, don't fool with it now.  */

  /* Working without memmove, for portability (sigh), so must be
     careful of overlapping subsections of the array...  */

  if (end1 == start2)		/* adjacent regions */
    {
      modify_region (current_buffer, start1, end2);
      record_change (start1, len1 + len2);

#ifdef USE_TEXT_PROPERTIES
      tmp_interval1 = copy_intervals (cur_intv, start1, len1);
      tmp_interval2 = copy_intervals (cur_intv, start2, len2);
      Fset_text_properties (make_number (start1), make_number (end2),
			    Qnil, Qnil);
#endif /* USE_TEXT_PROPERTIES */

      /* First region smaller than second.  */
      if (len1_byte < len2_byte)
        {
	  /* We use alloca only if it is small,
	     because we want to avoid stack overflow.  */
	  if (len2_byte > 20000)
	    temp = (unsigned char *) xmalloc (len2_byte);
	  else
	    temp = (unsigned char *) alloca (len2_byte);

	  /* Don't precompute these addresses.  We have to compute them
	     at the last minute, because the relocating allocator might
	     have moved the buffer around during the xmalloc.  */
	  start1_addr = BYTE_POS_ADDR (start1_byte);
	  start2_addr = BYTE_POS_ADDR (start2_byte);

          bcopy (start2_addr, temp, len2_byte);
          bcopy (start1_addr, start1_addr + len2_byte, len1_byte);
          bcopy (temp, start1_addr, len2_byte);
	  if (len2_byte > 20000)
	    free (temp);
        }
      else
	/* First region not smaller than second.  */
        {
	  if (len1_byte > 20000)
	    temp = (unsigned char *) xmalloc (len1_byte);
	  else
	    temp = (unsigned char *) alloca (len1_byte);
	  start1_addr = BYTE_POS_ADDR (start1_byte);
	  start2_addr = BYTE_POS_ADDR (start2_byte);
          bcopy (start1_addr, temp, len1_byte);
          bcopy (start2_addr, start1_addr, len2_byte);
          bcopy (temp, start1_addr + len2_byte, len1_byte);
	  if (len1_byte > 20000)
	    free (temp);
        }
#ifdef USE_TEXT_PROPERTIES
      graft_intervals_into_buffer (tmp_interval1, start1 + len2,
                                   len1, current_buffer, 0);
      graft_intervals_into_buffer (tmp_interval2, start1,
                                   len2, current_buffer, 0);
#endif /* USE_TEXT_PROPERTIES */
    }
  /* Non-adjacent regions, because end1 != start2, bleagh...  */
  else
    {
      len_mid = start2_byte - (start1_byte + len1_byte);

      if (len1_byte == len2_byte)
	/* Regions are same size, though, how nice.  */
        {
          modify_region (current_buffer, start1, end1);
          modify_region (current_buffer, start2, end2);
          record_change (start1, len1);
          record_change (start2, len2);
#ifdef USE_TEXT_PROPERTIES
          tmp_interval1 = copy_intervals (cur_intv, start1, len1);
          tmp_interval2 = copy_intervals (cur_intv, start2, len2);
          Fset_text_properties (make_number (start1), make_number (end1),
				Qnil, Qnil);
          Fset_text_properties (make_number (start2), make_number (end2),
				Qnil, Qnil);
#endif /* USE_TEXT_PROPERTIES */

	  if (len1_byte > 20000)
	    temp = (unsigned char *) xmalloc (len1_byte);
	  else
	    temp = (unsigned char *) alloca (len1_byte);
	  start1_addr = BYTE_POS_ADDR (start1_byte);
	  start2_addr = BYTE_POS_ADDR (start2_byte);
          bcopy (start1_addr, temp, len1_byte);
          bcopy (start2_addr, start1_addr, len2_byte);
          bcopy (temp, start2_addr, len1_byte);
	  if (len1_byte > 20000)
	    free (temp);
#ifdef USE_TEXT_PROPERTIES
          graft_intervals_into_buffer (tmp_interval1, start2,
                                       len1, current_buffer, 0);
          graft_intervals_into_buffer (tmp_interval2, start1,
                                       len2, current_buffer, 0);
#endif /* USE_TEXT_PROPERTIES */
        }

      else if (len1_byte < len2_byte)	/* Second region larger than first */
        /* Non-adjacent & unequal size, area between must also be shifted.  */
        {
          modify_region (current_buffer, start1, end2);
          record_change (start1, (end2 - start1));
#ifdef USE_TEXT_PROPERTIES
          tmp_interval1 = copy_intervals (cur_intv, start1, len1);
          tmp_interval_mid = copy_intervals (cur_intv, end1, len_mid);
          tmp_interval2 = copy_intervals (cur_intv, start2, len2);
          Fset_text_properties (make_number (start1), make_number (end2),
				Qnil, Qnil);
#endif /* USE_TEXT_PROPERTIES */

	  /* holds region 2 */
	  if (len2_byte > 20000)
	    temp = (unsigned char *) xmalloc (len2_byte);
	  else
	    temp = (unsigned char *) alloca (len2_byte);
	  start1_addr = BYTE_POS_ADDR (start1_byte);
	  start2_addr = BYTE_POS_ADDR (start2_byte);
          bcopy (start2_addr, temp, len2_byte);
          bcopy (start1_addr, start1_addr + len_mid + len2_byte, len1_byte);
          safe_bcopy (start1_addr + len1_byte, start1_addr + len2_byte, len_mid);
          bcopy (temp, start1_addr, len2_byte);
	  if (len2_byte > 20000)
	    free (temp);
#ifdef USE_TEXT_PROPERTIES
          graft_intervals_into_buffer (tmp_interval1, end2 - len1,
                                       len1, current_buffer, 0);
          graft_intervals_into_buffer (tmp_interval_mid, start1 + len2,
                                       len_mid, current_buffer, 0);
          graft_intervals_into_buffer (tmp_interval2, start1,
                                       len2, current_buffer, 0);
#endif /* USE_TEXT_PROPERTIES */
        }
      else
	/* Second region smaller than first.  */
        {
          record_change (start1, (end2 - start1));
          modify_region (current_buffer, start1, end2);

#ifdef USE_TEXT_PROPERTIES
          tmp_interval1 = copy_intervals (cur_intv, start1, len1);
          tmp_interval_mid = copy_intervals (cur_intv, end1, len_mid);
          tmp_interval2 = copy_intervals (cur_intv, start2, len2);
          Fset_text_properties (make_number (start1), make_number (end2),
				Qnil, Qnil);
#endif /* USE_TEXT_PROPERTIES */

	  /* holds region 1 */
	  if (len1_byte > 20000)
	    temp = (unsigned char *) xmalloc (len1_byte);
	  else
	    temp = (unsigned char *) alloca (len1_byte);
	  start1_addr = BYTE_POS_ADDR (start1_byte);
	  start2_addr = BYTE_POS_ADDR (start2_byte);
          bcopy (start1_addr, temp, len1_byte);
          bcopy (start2_addr, start1_addr, len2_byte);
          bcopy (start1_addr + len1_byte, start1_addr + len2_byte, len_mid);
          bcopy (temp, start1_addr + len2_byte + len_mid, len1_byte);
	  if (len1_byte > 20000)
	    free (temp);
#ifdef USE_TEXT_PROPERTIES
          graft_intervals_into_buffer (tmp_interval1, end2 - len1,
                                       len1, current_buffer, 0);
          graft_intervals_into_buffer (tmp_interval_mid, start1 + len2,
                                       len_mid, current_buffer, 0);
          graft_intervals_into_buffer (tmp_interval2, start1,
                                       len2, current_buffer, 0);
#endif /* USE_TEXT_PROPERTIES */
        }
    }

  /* When doing multiple transpositions, it might be nice
     to optimize this.  Perhaps the markers in any one buffer
     should be organized in some sorted data tree.  */
  if (NILP (leave_markers))
    {
      transpose_markers (start1, end1, start2, end2,
			 start1_byte, start1_byte + len1_byte,
			 start2_byte, start2_byte + len2_byte);
      fix_overlays_in_range (start1, end2);
    }

  return Qnil;
}


void
syms_of_editfns ()
{
  environbuf = 0;

  Qbuffer_access_fontify_functions
    = intern ("buffer-access-fontify-functions");
  staticpro (&Qbuffer_access_fontify_functions);

  DEFVAR_LISP ("buffer-access-fontify-functions",
	       &Vbuffer_access_fontify_functions,
	       "List of functions called by `buffer-substring' to fontify if necessary.\n\
Each function is called with two arguments which specify the range\n\
of the buffer being accessed.");
  Vbuffer_access_fontify_functions = Qnil;

  {
    Lisp_Object obuf;
    extern Lisp_Object Vprin1_to_string_buffer;
    obuf = Fcurrent_buffer ();
    /* Do this here, because init_buffer_once is too early--it won't work.  */
    Fset_buffer (Vprin1_to_string_buffer);
    /* Make sure buffer-access-fontify-functions is nil in this buffer.  */
    Fset (Fmake_local_variable (intern ("buffer-access-fontify-functions")),
	  Qnil);
    Fset_buffer (obuf);
  }

  DEFVAR_LISP ("buffer-access-fontified-property",
	       &Vbuffer_access_fontified_property,
       "Property which (if non-nil) indicates text has been fontified.\n\
`buffer-substring' need not call the `buffer-access-fontify-functions'\n\
functions if all the text being accessed has this property.");
  Vbuffer_access_fontified_property = Qnil;

  DEFVAR_LISP ("system-name", &Vsystem_name,
	       "The name of the machine Emacs is running on.");
  
  DEFVAR_LISP ("user-full-name", &Vuser_full_name,
	       "The full name of the user logged in.");

  DEFVAR_LISP ("user-login-name", &Vuser_login_name,
	       "The user's name, taken from environment variables if possible.");

  DEFVAR_LISP ("user-real-login-name", &Vuser_real_login_name,
	       "The user's name, based upon the real uid only.");

  defsubr (&Schar_equal);
  defsubr (&Sgoto_char);
  defsubr (&Sstring_to_char);
  defsubr (&Schar_to_string);
  defsubr (&Sbuffer_substring);
  defsubr (&Sbuffer_substring_no_properties);
  defsubr (&Sbuffer_string);

  defsubr (&Spoint_marker);
  defsubr (&Smark_marker);
  defsubr (&Spoint);
  defsubr (&Sregion_beginning);
  defsubr (&Sregion_end);

  defsubr (&Sline_beginning_position);
  defsubr (&Sline_end_position);

/*  defsubr (&Smark); */
/*  defsubr (&Sset_mark); */
  defsubr (&Ssave_excursion);
  defsubr (&Ssave_current_buffer);

  defsubr (&Sbufsize);
  defsubr (&Spoint_max);
  defsubr (&Spoint_min);
  defsubr (&Spoint_min_marker);
  defsubr (&Spoint_max_marker);
  defsubr (&Sgap_position);
  defsubr (&Sgap_size);
  defsubr (&Sposition_bytes);
  defsubr (&Sbyte_to_position);

  defsubr (&Sbobp);
  defsubr (&Seobp);
  defsubr (&Sbolp);
  defsubr (&Seolp);
  defsubr (&Sfollowing_char);
  defsubr (&Sprevious_char);
  defsubr (&Schar_after);
  defsubr (&Schar_before);
  defsubr (&Sinsert);
  defsubr (&Sinsert_before_markers);
  defsubr (&Sinsert_and_inherit);
  defsubr (&Sinsert_and_inherit_before_markers);
  defsubr (&Sinsert_char);

  defsubr (&Suser_login_name);
  defsubr (&Suser_real_login_name);
  defsubr (&Suser_uid);
  defsubr (&Suser_real_uid);
  defsubr (&Suser_full_name);
  defsubr (&Semacs_pid);
  defsubr (&Scurrent_time);
  defsubr (&Sformat_time_string);
  defsubr (&Sdecode_time);
  defsubr (&Sencode_time);
  defsubr (&Scurrent_time_string);
  defsubr (&Scurrent_time_zone);
  defsubr (&Sset_time_zone_rule);
  defsubr (&Ssystem_name);
  defsubr (&Smessage);
  defsubr (&Smessage_box);
  defsubr (&Smessage_or_box);
  defsubr (&Scurrent_message);
  defsubr (&Sformat);

  defsubr (&Sinsert_buffer_substring);
  defsubr (&Scompare_buffer_substrings);
  defsubr (&Ssubst_char_in_region);
  defsubr (&Stranslate_region);
  defsubr (&Sdelete_region);
  defsubr (&Swiden);
  defsubr (&Snarrow_to_region);
  defsubr (&Ssave_restriction);
  defsubr (&Stranspose_regions);
}
