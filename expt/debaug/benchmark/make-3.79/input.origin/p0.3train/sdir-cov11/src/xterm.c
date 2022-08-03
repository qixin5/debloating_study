/* X Communication module for terminals which understand the X protocol.
   Copyright (C) 1989, 93, 94, 95, 96, 1997 Free Software Foundation, Inc.

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

/* Xt features made by Fred Pierresteguy.  */

/* On 4.3 these lose if they come after xterm.h.  */
/* On HP-UX 8.0 signal.h loses if it comes after config.h.  */
/* Putting these at the beginning seems to be standard for other .c files.  */
#include <signal.h>

#include <config.h>

#include <stdio.h>

#ifdef HAVE_X_WINDOWS

#include "lisp.h"
#include "blockinput.h"

/* Need syssignal.h for various externs and definitions that may be required
   by some configurations for calls to signal later in this source file.  */
#include "syssignal.h"

/* This may include sys/types.h, and that somehow loses
   if this is not done before the other system files.  */
#include "xterm.h"
#include <X11/cursorfont.h>

#ifndef USG
/* Load sys/types.h if not already loaded.
   In some systems loading it twice is suicidal.  */
#ifndef makedev
#include <sys/types.h>
#endif /* makedev */
#endif /* USG */

#ifdef BSD_SYSTEM
#include <sys/ioctl.h>
#endif /* ! defined (BSD_SYSTEM) */

#include "systty.h"
#include "systime.h"

#ifndef INCLUDED_FCNTL
#include <fcntl.h>
#endif
#include <ctype.h>
#include <errno.h>
#include <setjmp.h>
#include <sys/stat.h>
/* Caused redefinition of DBL_DIG on Netbsd; seems not to be needed.  */
/* #include <sys/param.h>  */

#include "charset.h"
#include "ccl.h"
#include "frame.h"
#include "fontset.h"
#include "dispextern.h"
#include "termhooks.h"
#include "termopts.h"
#include "termchar.h"
#if 0
#include "sink.h"
#include "sinkmask.h"
#endif /* ! 0 */
#include "gnu.h"
#include "disptab.h"
#include "buffer.h"
#include "window.h"
#include "keyboard.h"
#include "intervals.h"
#include "process.h"

#ifdef USE_X_TOOLKIT
#include <X11/Shell.h>
#endif

#ifdef USE_X_TOOLKIT
extern void free_frame_menubar ();
extern FRAME_PTR x_menubar_window_to_frame ();
#if (XtSpecificationRelease >= 5) && !defined(NO_EDITRES)
#define HACK_EDITRES
extern void _XEditResCheckMessages ();
#endif /* not NO_EDITRES */
#endif /* USE_X_TOOLKIT */

#ifndef USE_X_TOOLKIT
#define x_any_window_to_frame x_window_to_frame
#define x_top_window_to_frame x_window_to_frame
#endif

#ifdef USE_X_TOOLKIT
#include "widget.h"
#ifndef XtNinitialState
#define XtNinitialState "initialState"
#endif
#endif

#ifdef HAVE_SETLOCALE
/* So we can do setlocale.  */
#include <locale.h>
#endif

#ifdef SOLARIS2
/* memmove will be defined as a macro in Xfuncs.h unless
   <string.h> is included beforehand.  The declaration for memmove in
   <string.h> will cause a syntax error when Xfuncs.h later includes it.  */
#include <string.h>
#endif

#ifndef min
#define min(a,b) ((a)<(b) ? (a) : (b))
#endif
#ifndef max
#define max(a,b) ((a)>(b) ? (a) : (b))
#endif

/* This is a chain of structures for all the X displays currently in use.  */
struct x_display_info *x_display_list;

/* This is a list of cons cells, each of the form (NAME . FONT-LIST-CACHE),
   one for each element of x_display_list and in the same order.
   NAME is the name of the frame.
   FONT-LIST-CACHE records previous values returned by x-list-fonts.  */
Lisp_Object x_display_name_list;

/* Frame being updated by update_frame.  This is declared in term.c.
   This is set by update_begin and looked at by all the
   XT functions.  It is zero while not inside an update.
   In that case, the XT functions assume that `selected_frame'
   is the frame to apply to.  */
extern struct frame *updating_frame;

extern int waiting_for_input;

/* This is a frame waiting to be autoraised, within XTread_socket.  */
struct frame *pending_autoraise_frame;

#ifdef USE_X_TOOLKIT
/* The application context for Xt use.  */
XtAppContext Xt_app_con;

static String Xt_default_resources[] =
{
  0
};
#endif

/* During an update, maximum vpos for ins/del line operations to affect.  */

static int flexlines;

/* During an update, nonzero if chars output now should be highlighted.  */

static int highlight;

/* Nominal cursor position -- where to draw output.
   During an update, these are different from the cursor-box position.  */

static int curs_x;
static int curs_y;

/* Mouse movement.

   Formerly, we used PointerMotionHintMask (in STANDARD_EVENT_MASK)
   so that we would have to call XQueryPointer after each MotionNotify
   event to ask for another such event.  However, this made mouse tracking
   slow, and there was a bug that made it eventually stop.

   Simply asking for MotionNotify all the time seems to work better.

   In order to avoid asking for motion events and then throwing most
   of them away or busy-polling the server for mouse positions, we ask
   the server for pointer motion hints.  This means that we get only
   one event per group of mouse movements.  "Groups" are delimited by
   other kinds of events (focus changes and button clicks, for
   example), or by XQueryPointer calls; when one of these happens, we
   get another MotionNotify event the next time the mouse moves.  This
   is at least as efficient as getting motion events when mouse
   tracking is on, and I suspect only negligibly worse when tracking
   is off.  */

/* Where the mouse was last time we reported a mouse event.  */
static FRAME_PTR last_mouse_frame;
static XRectangle last_mouse_glyph;

static Lisp_Object last_mouse_press_frame;

/* The scroll bar in which the last X motion event occurred.

   If the last X motion event occurred in a scroll bar, we set this
   so XTmouse_position can know whether to report a scroll bar motion or
   an ordinary motion.

   If the last X motion event didn't occur in a scroll bar, we set this
   to Qnil, to tell XTmouse_position to return an ordinary motion event.  */
static Lisp_Object last_mouse_scroll_bar;

/* This is a hack.  We would really prefer that XTmouse_position would
   return the time associated with the position it returns, but there
   doesn't seem to be any way to wrest the timestamp from the server
   along with the position query.  So, we just keep track of the time
   of the last movement we received, and return that in hopes that
   it's somewhat accurate.  */
static Time last_mouse_movement_time;

/* Incremented by XTread_socket whenever it really tries to read events.  */
#ifdef __STDC__
static int volatile input_signal_count;
#else
static int input_signal_count;
#endif

/* Used locally within XTread_socket.  */
static int x_noop_count;

/* Initial values of argv and argc.  */
extern char **initial_argv;
extern int initial_argc;

extern Lisp_Object Vcommand_line_args, Vsystem_name;

/* Tells if a window manager is present or not. */

extern Lisp_Object Vx_no_window_manager;

extern Lisp_Object Qface, Qmouse_face;

extern int errno;

/* A mask of extra modifier bits to put into every keyboard char.  */
extern int extra_keyboard_modifiers;

static Lisp_Object Qvendor_specific_keysyms;

extern XrmDatabase x_load_resources ();

extern Lisp_Object x_icon_type ();

void x_delete_display ();

static void redraw_previous_char ();
static void redraw_following_char ();
static unsigned int x_x_to_emacs_modifiers ();

static int fast_find_position ();
static void note_mouse_highlight ();
static void clear_mouse_face ();
static void show_mouse_face ();
static void do_line_dance ();

static void XTcursor_to ();
static void XTclear_end_of_line ();
static int x_io_error_quitter ();
int x_catch_errors ();
void x_uncatch_errors ();

#if 0
/* This is a function useful for recording debugging information
   about the sequence of occurrences in this file.  */

struct record 
{
  char *locus;
  int type;
};

struct record event_record[100];

int event_record_index;

record_event (locus, type)
     char *locus;
     int type;
{
  if (event_record_index == sizeof (event_record) / sizeof (struct record))
    event_record_index = 0;

  event_record[event_record_index].locus = locus;
  event_record[event_record_index].type = type;
  event_record_index++;
}

#endif /* 0 */

/* Return the struct x_display_info corresponding to DPY.  */

struct x_display_info *
x_display_info_for_display (dpy)
     Display *dpy;
{
  struct x_display_info *dpyinfo;

  for (dpyinfo = x_display_list; dpyinfo; dpyinfo = dpyinfo->next)
    if (dpyinfo->display == dpy)
      return dpyinfo;

  return 0;
}

/* Starting and ending updates.

   These hooks are called by update_frame at the beginning and end
   of a frame update.  We record in `updating_frame' the identity
   of the frame being updated, so that the XT... functions do not
   need to take a frame as argument.  Most of the XT... functions
   should never be called except during an update, the only exceptions
   being XTcursor_to, XTwrite_glyphs and XTreassert_line_highlight.  */

static void
XTupdate_begin (f)
     struct frame *f;
{
  int mask;

  if (f == 0)
    abort ();

  flexlines = f->height;
  highlight = 0;

  BLOCK_INPUT;

  curs_x = FRAME_CURSOR_X (f);
  curs_y = FRAME_CURSOR_Y (f);

  if (f == FRAME_X_DISPLAY_INFO (f)->mouse_face_mouse_frame)
    {
      /* Don't do highlighting for mouse motion during the update.  */
      FRAME_X_DISPLAY_INFO (f)->mouse_face_defer = 1;

      /* If the frame needs to be redrawn,
	 simply forget about any prior mouse highlighting.  */
      if (FRAME_GARBAGED_P (f))
	FRAME_X_DISPLAY_INFO (f)->mouse_face_window = Qnil;

      if (!NILP (FRAME_X_DISPLAY_INFO (f)->mouse_face_window))
	{
	  int firstline, lastline, i;
	  struct window *w = XWINDOW (FRAME_X_DISPLAY_INFO (f)->mouse_face_window);

	  /* Find the first, and the last+1, lines affected by redisplay.  */
	  for (firstline = 0; firstline < f->height; firstline++)
	    if (FRAME_DESIRED_GLYPHS (f)->enable[firstline])
	      break;

	  lastline = f->height;
	  for (i = f->height - 1; i >= 0; i--)
	    {
	      if (FRAME_DESIRED_GLYPHS (f)->enable[i])
		break;
	      else
		lastline = i;
	    }

	  /* Can we tell that this update does not affect the window
	     where the mouse highlight is?  If so, no need to turn off.
	     Likewise, don't do anything if the frame is garbaged;
	     in that case, the FRAME_CURRENT_GLYPHS that we would use
	     are all wrong, and we will redisplay that line anyway.  */
	  if (! (firstline > (XFASTINT (w->top) + window_internal_height (w))
		 || lastline < XFASTINT (w->top)))
	    clear_mouse_face (FRAME_X_DISPLAY_INFO (f));
	}
    }

  UNBLOCK_INPUT;
}

static void
XTupdate_end (f)
     struct frame *f;
{
  int mask;

  BLOCK_INPUT;

  do_line_dance ();
  x_display_cursor (f, 1, curs_x, curs_y);

  FRAME_X_DISPLAY_INFO (f)->mouse_face_defer = 0;
#if 0
  /* This fails in the case of having updated only the echo area
     if we have switched buffers.  In that case, FRAME_CURRENT_GLYPHS
     has no relation to the current contents, and its charstarts
     have no relation to the contents of the window-buffer.
  I don't know a clean way to check
     for that case.  window_end_valid isn't set up yet.  */
  if (f == FRAME_X_DISPLAY_INFO (f)->mouse_face_mouse_frame)
    note_mouse_highlight (f, FRAME_X_DISPLAY_INFO (f)->mouse_face_mouse_x,
			  FRAME_X_DISPLAY_INFO (f)->mouse_face_mouse_y);
#endif

  XFlush (FRAME_X_DISPLAY (f));
  UNBLOCK_INPUT;
}

/* This is called after a redisplay on frame F.  */

static void
XTframe_up_to_date (f)
     FRAME_PTR f;
{
  BLOCK_INPUT;
  if (FRAME_X_DISPLAY_INFO (f)->mouse_face_deferred_gc
      || f == FRAME_X_DISPLAY_INFO (f)->mouse_face_mouse_frame)
    {
      if (FRAME_X_DISPLAY_INFO (f)->mouse_face_mouse_frame)
	note_mouse_highlight (FRAME_X_DISPLAY_INFO (f)->mouse_face_mouse_frame,
			      FRAME_X_DISPLAY_INFO (f)->mouse_face_mouse_x,
			      FRAME_X_DISPLAY_INFO (f)->mouse_face_mouse_y);
      FRAME_X_DISPLAY_INFO (f)->mouse_face_deferred_gc = 0;
    }
  UNBLOCK_INPUT;
}

/* External interface to control of standout mode.
   Call this when about to modify line at position VPOS
   and not change whether it is highlighted.  */

void
XTreassert_line_highlight (new, vpos)
     int new, vpos;
{
  highlight = new;
}

/* Call this when about to modify line at position VPOS
   and change whether it is highlighted.  */

static void
XTchange_line_highlight (new_highlight, vpos, first_unused_hpos)
     int new_highlight, vpos, first_unused_hpos;
{
  highlight = new_highlight;
  XTcursor_to (vpos, 0);
  XTclear_end_of_line (FRAME_WINDOW_WIDTH (updating_frame));
}

/* This is used when starting Emacs and when restarting after suspend.
   When starting Emacs, no X window is mapped.  And nothing must be done
   to Emacs's own window if it is suspended (though that rarely happens).  */

static void
XTset_terminal_modes ()
{
}

/* This is called when exiting or suspending Emacs.
   Exiting will make the X-windows go away, and suspending
   requires no action.  */

static void
XTreset_terminal_modes ()
{
/*  XTclear_frame ();  */
}

/* Set the nominal cursor position of the frame.
   This is where display update commands will take effect.
   This does not affect the place where the cursor-box is displayed.  */

static void
XTcursor_to (row, col)
     register int row, col;
{
  int mask;
  int orow = row;
  struct frame *f;
  
  f = updating_frame;
  if (f == 0)
    f = selected_frame;

  curs_x = col;
  if (curs_x >= FRAME_CURSOR_X_LIMIT (f))
    curs_x = FRAME_CURSOR_X_LIMIT (f) - 1;

  curs_y = row;

  if (updating_frame == 0)
    {
      BLOCK_INPUT;
      x_display_cursor (selected_frame, 1, curs_x, curs_y);
      XFlush (FRAME_X_DISPLAY (selected_frame));
      UNBLOCK_INPUT;
    }
}


/* Return a pointer to per char metric information in FONT of a
   character pointed by B (*XChar2b).  */

#define PER_CHAR_METRIC(font, b)					   \
  ((font)->per_char							   \
   ? ((font)->per_char + (b)->byte2 - (font)->min_char_or_byte2		   \
      + (((font)->min_byte1 || (font)->max_byte1)			   \
	 ? (((b)->byte1 - (font)->min_byte1)				   \
	    * ((font)->max_char_or_byte2 - (font)->min_char_or_byte2 + 1)) \
	 : 0))								   \
   : &((font)->max_bounds))

/* Display a sequence of N glyphs found at GP.
   WINDOW is the x-window to output to.  LEFT and TOP are starting coords.
   HL is 1 if this text is highlighted, 2 if the cursor is on it,
   3 if should appear in its mouse-face.
   JUST_FOREGROUND if 1 means draw only the foreground;
   don't alter the background.

   CMPCHARP if non NULL is a pointer to the struct cmpchar_info, which
   means drawing glyphs on the same column.  This is set to non NULL
   only when recursively called within dumpglyphs to draw a composite
   character specified by CMPCHAR.

   FONT is the default font to use (for glyphs whose font-code is 0).

   Since the display generation code is responsible for calling
   compute_char_face and compute_glyph_face on everything it puts in
   the display structure, we can assume that the face code on each
   glyph is a valid index into FRAME_COMPUTED_FACES (f), and the one
   to which we can actually apply intern_face.
   Call this function with input blocked.

   Return overall pixel width of the drawn glyphs.  */

#if 1
/* This is the multi-face code.  */

static int
dumpglyphs (f, left, top, gp, n, hl, just_foreground, cmpcharp)
     struct frame *f;
     int left, top;
     register GLYPH *gp; /* Points to first GLYPH. */
     register int n;  /* Number of glyphs to display. */
     int hl;
     int just_foreground;
     struct cmpchar_info *cmpcharp;
{
  /* Holds characters to be displayed. */
  XChar2b *x_2byte_buffer
    = (XChar2b *) alloca (FRAME_WINDOW_WIDTH (f) * sizeof (*x_2byte_buffer));
  register XChar2b *cp;		/* Steps through x_2byte_buffer[]. */
  char *x_1byte_buffer
    = (char *) alloca (FRAME_WINDOW_WIDTH (f) * sizeof (*x_1byte_buffer));
  register int tlen = GLYPH_TABLE_LENGTH;
  register Lisp_Object *tbase = GLYPH_TABLE_BASE;
  Window window = FRAME_X_WINDOW (f);
  int orig_left = left;
  int gidx = 0;
  int i;

  while (n > 0)
    {
      /* Get the face-code of the next GLYPH.  */
      int cf, len;
      GLYPH g = *gp;
      int ch, charset;
      Lisp_Object first_ch;
      /* HIGHEST and LOWEST are used while drawing a composite
         character.  The meanings are described later.  */
      int highest, lowest;

      GLYPH_FOLLOW_ALIASES (tbase, tlen, g);
      cf = (cmpcharp ? cmpcharp->face_work : FAST_GLYPH_FACE (g));
      ch = FAST_GLYPH_CHAR (g);
      if (unibyte_display_via_language_environment
	  && SINGLE_BYTE_CHAR_P (ch)
	  && (ch >= 0240
	      || (ch >= 0200 && !NILP (Vnonascii_translation_table))))
	ch = unibyte_char_to_multibyte (ch);
      if (gidx == 0) XSETFASTINT (first_ch, ch);
      charset = CHAR_CHARSET (ch);
      if (charset == CHARSET_COMPOSITION)
	{
	  /* We must draw components of the composite character on the
             same column.  */
	  cmpcharp = cmpchar_table[COMPOSITE_CHAR_ID (ch)];

	  /* Set the face in the slot for work.  */
	  cmpcharp->face_work = cf;

	  /* We don't need the return value ... */
	  dumpglyphs (f, left, top, cmpcharp->glyph, cmpcharp->glyph_len,
		      hl, just_foreground, cmpcharp);
	  /* ... because the width of just drawn text can be
             calculated as follows.  */
	  left += FONT_WIDTH (f->output_data.x->font) * cmpcharp->width;

	  ++gp, --n;
	  while (gp && (*gp & GLYPH_MASK_PADDING)) ++gp, --n;
	  cmpcharp = NULL;
	  continue;
	}

      /* Find the run of consecutive glyphs which can be drawn with
	 the same GC (i.e. the same charset and the same face-code).
	 Extract their character codes into X_2BYTE_BUFFER.
	 If CMPCHARP is not NULL, face-code is not checked because we
	 use only the face specified in `cmpcharp->face_work'.  */
      cp = x_2byte_buffer;
      while (n > 0)
	{
	  int this_charset, c1, c2;

	  g = *gp;
	  GLYPH_FOLLOW_ALIASES (tbase, tlen, g);
	  ch = FAST_GLYPH_CHAR (g);
	  if (unibyte_display_via_language_environment
	      && SINGLE_BYTE_CHAR_P (ch)
	      && (ch >= 0240
		  || (ch >= 0200 && !NILP (Vnonascii_translation_table))))
	    ch = unibyte_char_to_multibyte (ch);
	  SPLIT_CHAR (ch, this_charset, c1, c2);
	  if (this_charset != charset
	      || (cmpcharp == NULL && FAST_GLYPH_FACE (g) != cf))
	    break;

	  if (c2 > 0)
	    cp->byte1 = c1, cp->byte2 = c2;
	  else
	    cp->byte1 = 0, cp->byte2 = c1;
	  ++cp;
	  ++gp, --n;
	  while (gp && (*gp & GLYPH_MASK_PADDING))
	    ++gp, --n;
	}

      /* LEN gets the length of the run.  */
      len = cp - x_2byte_buffer;
      /* Now output this run of chars, with the font and pixel values
	 determined by the face code CF.  */
      {
	struct face *face = FRAME_DEFAULT_FACE (f);
	XFontStruct *font = NULL;
	GC gc;
	int stippled = 0;
	int line_height = f->output_data.x->line_height;
	/* Pixel width of each glyph in this run.  */
	int glyph_width
	  = (FONT_WIDTH (f->output_data.x->font)
	     * (cmpcharp ? cmpcharp->width : CHARSET_WIDTH (charset)));
	/* Overall pixel width of this run.  */
	int run_width
	  = (FONT_WIDTH (f->output_data.x->font)
	     * (cmpcharp ? cmpcharp->width : len * CHARSET_WIDTH (charset)));
	/* A flag to tell if we have already filled background.  We
	   fill background in advance in the following cases:
	   1) A face has stipple.
	   2) A height of font is shorter than LINE_HEIGHT.
	   3) Drawing a composite character.
	   4) Font has non-zero _MULE_BASELINE_OFFSET property.
	   After filling background, we draw glyphs by XDrawString16.  */
	int background_filled;
	/* Baseline position of a character, offset from TOP.  */
	int baseline;
	/* The property value of `_MULE_RELATIVE_COMPOSE' and
           `_MULE_DEFAULT_ASCENT'.  */
	int relative_compose = 0, default_ascent = 0;
	/* 1 if we find no font or a font of inappropriate size.  */
	int require_clipping;

	/* HL = 3 means use a mouse face previously chosen.  */
	if (hl == 3)
	  cf = FRAME_X_DISPLAY_INFO (f)->mouse_face_face_id;

	/* First look at the face of the text itself.  */
	if (cf != 0)
	  {
	    /* It's possible for the display table to specify
	       a face code that is out of range.  Use 0 in that case.  */
	    if (cf < 0 || cf >= FRAME_N_COMPUTED_FACES (f)
		|| FRAME_COMPUTED_FACES (f) [cf] == 0)
	      cf = 0;

	    if (cf == 1)
	      face = FRAME_MODE_LINE_FACE (f);
	    else
	      face = intern_face (f, FRAME_COMPUTED_FACES (f) [cf]);
	    if (FACE_STIPPLE (face))
	      stippled = 1;
	  }

	/* Then comes the distinction between modeline and normal text.  */
	else if (hl == 0)
	  ;
	else if (hl == 1)
	  {
	    face = FRAME_MODE_LINE_FACE (f);
	    if (FACE_STIPPLE (face))
	      stippled = 1;
	  }

#define FACE_DEFAULT (~0)

	/* Setting appropriate font and gc for this charset.  */
	if (charset != CHARSET_ASCII)
	  {
	    int font_id;
	    int fontset = FACE_FONTSET (face);
	    struct font_info *fontp;

	    if ((fontset < 0 && (fontset = FRAME_FONTSET (f)) < 0)
		|| !(fontp = FS_LOAD_FONT (f, FRAME_X_FONT_TABLE (f),
					   charset, NULL, fontset)))
	      goto font_not_found;

	    font = (XFontStruct *) (fontp->font);
	    gc = FACE_NON_ASCII_GC (face);
	    XSetFont (FRAME_X_DISPLAY (f), gc, font->fid);
	    baseline
	      = (font->max_byte1 != 0
		 ? (line_height + font->ascent - font->descent) / 2
		 : f->output_data.x->font_baseline - fontp->baseline_offset);
	    if (FONT_HEIGHT (font) <= line_height
		&& (font->ascent > baseline
		    || font->descent > line_height - baseline))
	      /* Adjust baseline for this font to show the whole
                 glyphs in a line.  */
	      baseline = line_height - font->descent;
	      
	    if (cmpcharp && cmpcharp->cmp_rule == NULL)
	      {
		relative_compose = fontp->relative_compose;
		default_ascent = fontp->default_ascent;
	      }

	    /* We have to change code points in the following cases.  */
	    if (fontp->font_encoder)
	      {
		/* This font requires CCL program to calculate code
                   point of characters.  */
		struct ccl_program *ccl = fontp->font_encoder;

		if (CHARSET_DIMENSION (charset) == 1)
		  for (cp = x_2byte_buffer; cp < x_2byte_buffer + len; cp++)
		    {
		      ccl->reg[0] = charset;
		      ccl->reg[1] = cp->byte2;
		      ccl_driver (ccl, NULL, NULL, 0, 0, NULL);
		      /* We assume that MSBs are appropriately
                         set/reset by CCL program.  */
		      if (font->max_byte1 == 0)	/* 1-byte font */
			cp->byte1 = 0, cp->byte2 = ccl->reg[1];
		      else
			cp->byte1 = ccl->reg[1], cp->byte2 = ccl->reg[2];
		    }
		else
		  for (cp = x_2byte_buffer; cp < x_2byte_buffer + len; cp++)
		    {
		      ccl->reg[0] = charset;
		      ccl->reg[1] = cp->byte1, ccl->reg[2] = cp->byte2;
		      ccl_driver (ccl, NULL, NULL, 0, 0, NULL);
		      /* We assume that MSBs are appropriately
                         set/reset by CCL program.  */
		      if (font->max_byte1 == 0)	/* 1-byte font */
			cp->byte1 = 0, cp->byte2 = ccl->reg[1];
		      else
			cp->byte1 = ccl->reg[1], cp->byte2 = ccl->reg[2];
		    }
	      }
	    else if (fontp->encoding[charset])
	      {
		int enc = fontp->encoding[charset];

		if ((enc == 1 || enc == 2) && CHARSET_DIMENSION (charset) == 2)
		  for (cp = x_2byte_buffer; cp < x_2byte_buffer + len; cp++)
		    cp->byte1 |= 0x80;
		if (enc == 1 || enc == 3)
		  for (cp = x_2byte_buffer; cp < x_2byte_buffer + len; cp++)
		    cp->byte2 |= 0x80;
	      }
	  }
	else
	  {
	  font_not_found:
	    if (charset == CHARSET_ASCII || charset == charset_latin_iso8859_1)
	      {
		font = FACE_FONT (face);
		if (!font || font == (XFontStruct *) FACE_DEFAULT)
		  font = f->output_data.x->font;
		baseline = FONT_BASE (f->output_data.x->font);
		if (charset == charset_latin_iso8859_1)
		  {
		    if (font->max_char_or_byte2 < 0x80)
		      /* This font can't display Latin1 characters.  */
		      font = NULL;
		    else
		      {
			for (cp = x_2byte_buffer; cp < x_2byte_buffer + len; cp++)
			  cp->byte2 |= 0x80;
		      }
		  }
	      }
	    gc = FACE_GC (face);
	  }

	/* Now override that if the cursor's on this character.  */
	if (hl == 2)
	  {
	    /* The cursor overrides stippling.  */
	    stippled = 0;

	    if (font == f->output_data.x->font
		&& face->background == f->output_data.x->background_pixel
		&& face->foreground == f->output_data.x->foreground_pixel
		&& !cmpcharp)
	      {
		gc = f->output_data.x->cursor_gc;
	      }
	    /* Cursor on non-default face: must merge.  */
	    else
	      {
		XGCValues xgcv;
		unsigned long mask;

		xgcv.background = f->output_data.x->cursor_pixel;
		xgcv.foreground = face->background;
		/* If the glyph would be invisible,
		   try a different foreground.  */
		if (xgcv.foreground == xgcv.background)
		  xgcv.foreground = face->foreground;
		if (xgcv.foreground == xgcv.background)
		  xgcv.foreground = f->output_data.x->cursor_foreground_pixel;
		if (xgcv.foreground == xgcv.background)
		  xgcv.foreground = face->foreground;
		/* Make sure the cursor is distinct from text in this face.  */
		if (xgcv.background == face->background
		    && xgcv.foreground == face->foreground)
		  {
		    xgcv.background = face->foreground;
		    xgcv.foreground = face->background;
		  }
		xgcv.graphics_exposures = 0;
		mask = GCForeground | GCBackground | GCGraphicsExposures;
		if (font)
		  {
		    xgcv.font = font->fid;
		    mask |= GCFont;
		  }

		if (FRAME_X_DISPLAY_INFO (f)->scratch_cursor_gc)
		  XChangeGC (FRAME_X_DISPLAY (f),
			     FRAME_X_DISPLAY_INFO (f)->scratch_cursor_gc,
			     mask, &xgcv);
		else
		  FRAME_X_DISPLAY_INFO (f)->scratch_cursor_gc
		    = XCreateGC (FRAME_X_DISPLAY (f), window, mask, &xgcv);
		gc = FRAME_X_DISPLAY_INFO (f)->scratch_cursor_gc;
#if 0
/* If this code is restored, it must also reset to the default stipple
   if necessary. */
		if (face->stipple && face->stipple != FACE_DEFAULT)
		  XSetStipple (FRAME_X_DISPLAY (f), gc, face->stipple);
#endif
	      }
	  }

	if (font)
	  require_clipping = (!NILP (Vclip_large_size_font)
			      && (font->ascent > baseline
				  || font->descent > line_height - baseline
				  || (!cmpcharp
				      && FONT_WIDTH (font) > glyph_width)));

	if (font && (just_foreground || (cmpcharp && gidx > 0)))
	  background_filled = 1;
	else if (stippled)
	  {
	    /* Turn stipple on.  */
	    XSetFillStyle (FRAME_X_DISPLAY (f), gc, FillOpaqueStippled);

	    /* Draw stipple or background color on background.  */
	    XFillRectangle (FRAME_X_DISPLAY (f), window, gc,
			    left, top, run_width, line_height);

	    /* Turn stipple off.  */
	    XSetFillStyle (FRAME_X_DISPLAY (f), gc, FillSolid);

	    background_filled = 1;
	  }
	else if (!font
		 || FONT_BASE (font) < baseline
		 || (FONT_HEIGHT (font) - FONT_BASE (font)
		     < line_height - baseline)
		 || FONT_WIDTH (font) < glyph_width
		 || cmpcharp)
	  {
	    /* Fill a area for the current run in background pixle of GC.  */
	    XGCValues xgcv;
	    unsigned long mask = GCForeground | GCBackground | GCFillStyle;

	    /* The current code at first set foreground to background,
	      fill the area, then recover the original foreground.
	      Aren't there any smarter ways?  */

	    XGetGCValues (FRAME_X_DISPLAY (f), gc, mask, &xgcv);
	    XSetForeground (FRAME_X_DISPLAY (f), gc, xgcv.background);
	    XSetFillStyle (FRAME_X_DISPLAY (f), gc, FillSolid);
	    XFillRectangle (FRAME_X_DISPLAY (f), window, gc,
			    left, top, run_width, line_height);
	    XSetForeground (FRAME_X_DISPLAY (f), gc, xgcv.foreground);

	    background_filled = 1;
	    if (cmpcharp)
	      /* To assure not to fill background while drawing
		 remaining components.  */
	      just_foreground = 1;
	  }
	else
	  background_filled = 0;

	if (font)
	  {
	    if (require_clipping)
	      {
		Region region;	/* Region used for setting clip mask to GC.  */
		XPoint x[4];	/* Data used for creating REGION.  */

		x[0].x = x[3].x = left, x[1].x = x[2].x = left + glyph_width;
		x[0].y = x[1].y = top,  x[2].y = x[3].y = top + line_height;
		region = XPolygonRegion (x, 4, EvenOddRule);
		XSetRegion (FRAME_X_DISPLAY (f), gc, region);
		XDestroyRegion (region);
	      }

	    if (!cmpcharp)
	      {
		if (require_clipping || FONT_WIDTH (font) != glyph_width)
		  for (i = 0; i < len; i++)
		    {
		      if (require_clipping && i > 0) 
			XSetClipOrigin (FRAME_X_DISPLAY (f), gc,
					glyph_width * i, 0);
		      if (background_filled)
			XDrawString16 (FRAME_X_DISPLAY (f), window, gc,
				       left + glyph_width * i,
				       top + baseline, x_2byte_buffer + i, 1);
		      else
			XDrawImageString16 (FRAME_X_DISPLAY (f), window, gc,
					    left + glyph_width * i,
					    top + baseline, x_2byte_buffer + i, 1);
		    }
		else
		  {
		    /* See if this whole buffer can be output as 8-bit chars.
		       If so, copy x_2byte_buffer to x_1byte_buffer
		       and do it as 8-bit chars.  */
		    for (i = 0; i < len; i++)
		      {
			if (x_2byte_buffer[i].byte1 != 0)
			  break;
			x_1byte_buffer[i] = x_2byte_buffer[i].byte2;
		      }

		    if (i == len)
		      {
			if (background_filled)
			  XDrawString (FRAME_X_DISPLAY (f), window, gc,
				       left, top + baseline, x_1byte_buffer, len);
			else
			  XDrawImageString (FRAME_X_DISPLAY (f), window, gc,
					    left, top + baseline, x_1byte_buffer, len);
		      }
		    else
		      {
			/* We can't output them as 8-bit chars,
			   so do it as 16-bit chars.  */

			if (background_filled)
			  XDrawString16 (FRAME_X_DISPLAY (f), window, gc,
					 left, top + baseline, x_2byte_buffer, len);
			else
			  XDrawImageString16 (FRAME_X_DISPLAY (f), window, gc,
					      left, top + baseline, x_2byte_buffer, len);
		      }
		  }
	      }
	    else
	      {
		/* Handle composite characters.  */
		XCharStruct *pcm; /* Pointer to per char metric info.  */

		if ((cmpcharp->cmp_rule || relative_compose)
		    && gidx == 0)
		  {
		    /* This is the first character.  Initialize variables.
		       HIGHEST is the highest position of glyphs ever
		       written, LOWEST the lowest position.  */
		    int x_offset = 0;

		    if (default_ascent
			&& CHAR_TABLE_P (Vuse_default_ascent)
			&& !NILP (Faref (Vuse_default_ascent, first_ch)))
		      {
			highest = default_ascent;
			lowest = 0;
		      }
		    else
		      {
			pcm = PER_CHAR_METRIC (font, x_2byte_buffer);
			highest = pcm->ascent + 1;
			lowest = - pcm->descent;
		      }

		    if (cmpcharp->cmp_rule)
		      x_offset = (cmpcharp->col_offset[0]
				  * FONT_WIDTH (f->output_data.x->font));
		    /* Draw the first character at the normal position.  */
		    XDrawString16 (FRAME_X_DISPLAY (f), window, gc,
				   left + x_offset, top + baseline, x_2byte_buffer, 1);
		    i = 1;
		    gidx++;
		  }
		else
		  i = 0;

		for (; i < len; i++, gidx++)
		  {
		    int x_offset = 0, y_offset = 0;

		    if (relative_compose)
		      {
			pcm = PER_CHAR_METRIC (font, x_2byte_buffer + i);
			if (NILP (Vignore_relative_composition)
			    || NILP (Faref (Vignore_relative_composition,
					    make_number (cmpcharp->glyph[gidx]))))
			  {
			    if (- pcm->descent >= relative_compose)
			      {
				/* Draw above the current glyphs.  */
				y_offset = highest + pcm->descent;
				highest += pcm->ascent + pcm->descent;
			      }
			    else if (pcm->ascent <= 0)
			      {
				/* Draw beneath the current glyphs.  */
				y_offset = lowest - pcm->ascent;
				lowest -= pcm->ascent + pcm->descent;
			      }
			  }
			else
			  {
			    /* Draw the glyph at normal position.  If
                               it sticks out of HIGHEST or LOWEST,
                               update them appropriately.  */
			    if (pcm->ascent > highest)
			      highest = pcm->ascent;
			    else if (- pcm->descent < lowest)
			      lowest = - pcm->descent;
			  }
		      }
		    else if (cmpcharp->cmp_rule)
		      {
			int gref = (cmpcharp->cmp_rule[gidx] - 0xA0) / 9;
			int nref = (cmpcharp->cmp_rule[gidx] - 0xA0) % 9;
			int bottom, top;

			/* Re-encode GREF and NREF so that they specify
			   only Y-axis information:
			   0:top, 1:base, 2:bottom, 3:center  */
			gref = gref / 3 + (gref == 4) * 2;
			nref = nref / 3 + (nref == 4) * 2;

			pcm = PER_CHAR_METRIC (font, x_2byte_buffer + i);
			bottom = ((gref == 0 ? highest : gref == 1 ? 0
				   : gref == 2 ? lowest
				   : (highest + lowest) / 2)
				  - (nref == 0 ? pcm->ascent + pcm->descent
				     : nref == 1 ? pcm->descent : nref == 2 ? 0
				     : (pcm->ascent + pcm->descent) / 2));
			top = bottom + (pcm->ascent + pcm->descent);
			if (top > highest)
			  highest = top;
			if (bottom < lowest)
			  lowest = bottom;
			y_offset = bottom + pcm->descent;
			x_offset = (cmpcharp->col_offset[gidx]
				    * FONT_WIDTH (f->output_data.x->font));
		      }
		    XDrawString16 (FRAME_X_DISPLAY (f), window, gc,
				   left + x_offset, top + baseline - y_offset,
				   x_2byte_buffer + i, 1);
		  }
	      }
	    if (require_clipping)
	      XSetClipMask (FRAME_X_DISPLAY (f), gc, None);

#if 0 /* Doesn't work, because it uses FRAME_CURRENT_GLYPHS,
	 which often is not up to date yet.  */
	    if (!just_foreground)
	      {
		if (left == orig_left)
		  redraw_previous_char (f, PIXEL_TO_CHAR_COL (f, left),
					PIXEL_TO_CHAR_ROW (f, top), hl == 1);
		if (n == 0)
		  redraw_following_char (f, PIXEL_TO_CHAR_COL (f, left + len * FONT_WIDTH (font)),
					 PIXEL_TO_CHAR_ROW (f, top), hl == 1);
	      }
#endif
	  }
	if (!font)
	  {
	    /* Show rectangles to indicate that we found no font.  */
	    int limit = cmpcharp ? 1 : len;

	    for (i = 0; i < limit; i++)
	      XDrawRectangle (FRAME_X_DISPLAY (f), FRAME_X_WINDOW (f), gc,
			      left + glyph_width * i, top,
			      glyph_width - 1, line_height - 1);
	  }
	else if (require_clipping && !NILP (Vhighlight_wrong_size_font))
	  {
	    /* Show ??? to indicate that we found a font of
               inappropriate size.  */
	    int limit = cmpcharp ? 1 : len;

	    for (i = 0; i < limit; i++)
	      {
		XDrawLine (FRAME_X_DISPLAY (f), FRAME_X_WINDOW (f), gc,
			   left + glyph_width * i, top + line_height - 1,
			   left + glyph_width * i + 1, top + line_height - 1);
		XDrawLine (FRAME_X_DISPLAY (f), FRAME_X_WINDOW (f), gc,
			   left + glyph_width * i, top + line_height - 3,
			   left + glyph_width * i, top + line_height - 1);
	      }
	  }

	/* We should probably check for XA_UNDERLINE_POSITION and
	   XA_UNDERLINE_THICKNESS properties on the font, but let's
	   just get the thing working, and come back to that.  */
	{
	  /* Setting underline position based on the metric of the
	     current font results in shaky underline if it strides
	     over different fonts.  So, we set the position based only
	     on the default font of this frame.  */
	  int underline_position = f->output_data.x->font_baseline + 1;

	  if (underline_position >= line_height)
	    underline_position = line_height - 1;

	  if (face->underline)
	    XFillRectangle (FRAME_X_DISPLAY (f), FRAME_X_WINDOW (f),
			    FACE_GC (face),
			    left, top + underline_position, run_width, 1);
	}

	if (!cmpcharp)
	  left += run_width;
      }
    }

  return (left - orig_left);
}
#endif /* 1 */

#if 0
/* This is the old single-face code.  */

static void
dumpglyphs (f, left, top, gp, n, hl, font)
     struct frame *f;
     int left, top;
     register GLYPH *gp; /* Points to first GLYPH. */
     register int n;  /* Number of glyphs to display. */
     int hl;
     XFontStruct *font;
{
  register int len;
  Window window = FRAME_X_WINDOW (f);
  GC drawing_gc =   (hl == 2 ? f->output_data.x->cursor_gc
		             : (hl ? f->output_data.x->reverse_gc
				   : f->output_data.x->normal_gc));

  if (sizeof (GLYPH) == sizeof (XChar2b))
    XDrawImageString16 (FRAME_X_DISPLAY (f), window, drawing_gc,
			left, top + FONT_BASE (font), (XChar2b *) gp, n);
  else if (sizeof (GLYPH) == sizeof (unsigned char))
    XDrawImageString (FRAME_X_DISPLAY (f), window, drawing_gc,
		      left, top + FONT_BASE (font), (char *) gp, n);
  else
    /* What size of glyph ARE you using?  And does X have a function to
       draw them?  */
    abort ();
}
#endif

/* Output some text at the nominal frame cursor position.
   Advance the cursor over the text.
   Output LEN glyphs at START.

   `highlight', set up by XTreassert_line_highlight or XTchange_line_highlight,
   controls the pixel values used for foreground and background.  */

static void
XTwrite_glyphs (start, len)
     register GLYPH *start;
     int len;
{
  register int temp_length;
  int mask;
  struct frame *f;

  BLOCK_INPUT;

  do_line_dance ();
  f = updating_frame;
  if (f == 0)
    {
      f = selected_frame;
      /* If not within an update,
	 output at the frame's visible cursor.  */
      curs_x = FRAME_CURSOR_X (f);
      curs_y = FRAME_CURSOR_Y (f);
    }

  dumpglyphs (f,
	      CHAR_TO_PIXEL_COL (f, curs_x),
	      CHAR_TO_PIXEL_ROW (f, curs_y),
	      start, len, highlight, 0, NULL);

  /* If we drew on top of the cursor, note that it is turned off.  */
  if (curs_y == f->phys_cursor_y
      && curs_x <= f->phys_cursor_x
      && curs_x + len > f->phys_cursor_x)
    f->phys_cursor_on = 0;

  curs_x += len;
  if (curs_x >= FRAME_CURSOR_X_LIMIT (f))
    curs_x = FRAME_CURSOR_X_LIMIT (f) - 1;

  if (updating_frame == 0)
    x_display_cursor (f, 1, curs_x, FRAME_CURSOR_Y (f));
      

  UNBLOCK_INPUT;
}

/* Clear to the end of the line.
   Erase the current text line from the nominal cursor position (inclusive)
   to column FIRST_UNUSED (exclusive).  The idea is that everything
   from FIRST_UNUSED onward is already erased.  */

static void
XTclear_end_of_line (first_unused)
     register int first_unused;
{
  struct frame *f = updating_frame;
  int mask;

  if (f == 0)
    abort ();

  if (curs_y < 0 || curs_y >= f->height)
    return;
  if (first_unused <= 0)
    return;

  if (first_unused >= FRAME_WINDOW_WIDTH (f))
    first_unused = FRAME_WINDOW_WIDTH (f);

  first_unused += FRAME_LEFT_SCROLL_BAR_WIDTH (f);

  BLOCK_INPUT;

  do_line_dance ();

  /* Notice if the cursor will be cleared by this operation.  */
  if (curs_y == f->phys_cursor_y
      && curs_x <= f->phys_cursor_x
      && f->phys_cursor_x < first_unused)
    f->phys_cursor_on = 0;

  XClearArea (FRAME_X_DISPLAY (f), FRAME_X_WINDOW (f),
	      CHAR_TO_PIXEL_COL (f, curs_x),
	      CHAR_TO_PIXEL_ROW (f, curs_y),
	      FONT_WIDTH (f->output_data.x->font) * (first_unused - curs_x),
	      f->output_data.x->line_height, False);
#if 0
  redraw_previous_char (f, curs_x, curs_y, highlight);
#endif

  UNBLOCK_INPUT;
}

static void
XTclear_frame ()
{
  int mask;
  struct frame *f = updating_frame;

  if (f == 0)
    f = selected_frame;

  f->phys_cursor_on = 0;	/* Cursor not visible.  */
  curs_x = 0;			/* Nominal cursor position is top left.  */
  curs_y = 0;

  BLOCK_INPUT;

  XClearWindow (FRAME_X_DISPLAY (f), FRAME_X_WINDOW (f));

  /* We have to clear the scroll bars, too.  If we have changed
     colors or something like that, then they should be notified.  */
  x_scroll_bar_clear (f);

  XFlush (FRAME_X_DISPLAY (f));
  UNBLOCK_INPUT;
}

#if 0
/* This currently does not work because FRAME_CURRENT_GLYPHS doesn't
   always contain the right glyphs to use.

   It also needs to be changed to look at the details of the font and
   see whether there is really overlap, and do nothing when there is
   not.  This can use font_char_overlap_left and font_char_overlap_right,
   but just how to use them is not clear.  */

/* Erase the character (if any) at the position just before X, Y in frame F,
   then redraw it and the character before it.
   This is necessary when we erase starting at X,
   in case the character after X overlaps into the one before X.
   Call this function with input blocked.  */

static void
redraw_previous_char (f, x, y, highlight_flag)
     FRAME_PTR f;
     int x, y;
     int highlight_flag;
{
  /* Erase the character before the new ones, in case
     what was here before overlaps it.
     Reoutput that character, and the previous character
     (in case the previous character overlaps it).  */
  if (x > 0)
    {
      int start_x = x - 2;
      if (start_x < 0)
	start_x = 0;
      XClearArea (FRAME_X_DISPLAY (f), FRAME_X_WINDOW (f),
		  CHAR_TO_PIXEL_COL (f, x - 1),
		  CHAR_TO_PIXEL_ROW (f, y),
		  FONT_WIDTH (f->output_data.x->font),
		  f->output_data.x->line_height, False);

      dumpglyphs (f, CHAR_TO_PIXEL_COL (f, start_x),
		  CHAR_TO_PIXEL_ROW (f, y),
		  &FRAME_CURRENT_GLYPHS (f)->glyphs[y][start_x],
		  x - start_x, highlight_flag, 1, NULL);
    }
}

/* Erase the character (if any) at the position X, Y in frame F,
   then redraw it and the character after it.
   This is necessary when we erase endng at X,
   in case the character after X overlaps into the one before X.
   Call this function with input blocked.  */

static void
redraw_following_char (f, x, y, highlight_flag)
     FRAME_PTR f;
     int x, y;
     int highlight_flag;
{
  int limit = FRAME_CURRENT_GLYPHS (f)->used[y];
  /* Erase the character after the new ones, in case
     what was here before overlaps it.
     Reoutput that character, and the following character
     (in case the following character overlaps it).  */
  if (x < limit
      && FRAME_CURRENT_GLYPHS (f)->glyphs[y][x] != SPACEGLYPH)
    {
      int end_x = x + 2;
      if (end_x > limit)
	end_x = limit;
      XClearArea (FRAME_X_DISPLAY (f), FRAME_X_WINDOW (f),
		  CHAR_TO_PIXEL_COL (f, x),
		  CHAR_TO_PIXEL_ROW (f, y),
		  FONT_WIDTH (f->output_data.x->font),
		  f->output_data.x->line_height, False);

      dumpglyphs (f, CHAR_TO_PIXEL_COL (f, x),
		  CHAR_TO_PIXEL_ROW (f, y),
		  &FRAME_CURRENT_GLYPHS (f)->glyphs[y][x],
		  end_x - x, highlight_flag, 1, NULL);
    }
}
#endif /* 0 */

#if 0 /* Not in use yet */

/* Return 1 if character C in font F extends past its left edge.  */

static int
font_char_overlap_left (font, c)
     XFontStruct *font;
     int c;
{
  XCharStruct *s;

  /* Find the bounding-box info for C.  */
  if (font->per_char == 0)
    s = &font->max_bounds;
  else
    {
      int rowlen = font->max_char_or_byte2 - font->min_char_or_byte2 + 1;
      int row, within;

      /* Decode char into row number (byte 1) and code within row (byte 2).  */
      row = c >> 8;
      within = c & 0177;
      if (!(within >= font->min_char_or_byte2
	    && within <= font->max_char_or_byte2
	    && row >= font->min_byte1
	    && row <= font->max_byte1))
	{
	  /* If char is out of range, try the font's default char instead.  */
	  c = font->default_char;
	  row = c >> (BITS_PER_INT - 8);
	  within = c & 0177;
	}
      if (!(within >= font->min_char_or_byte2
	    && within <= font->max_char_or_byte2
	    && row >= font->min_byte1
	    && row <= font->max_byte1))
	/* Still out of range means this char does not overlap.  */
	return 0;
      else
	/* We found the info for this char.  */
	s = (font->per_char + (within - font->min_char_or_byte2)
	     + row * rowlen);
    }

  return (s && s->lbearing < 0);
}

/* Return 1 if character C in font F extends past its right edge.  */

static int
font_char_overlap_right (font, c)
     XFontStruct *font;
     int c;
{
  XCharStruct *s;

  /* Find the bounding-box info for C.  */
  if (font->per_char == 0)
    s = &font->max_bounds;
  else
    {
      int rowlen = font->max_char_or_byte2 - font->min_char_or_byte2 + 1;
      int row, within;

      /* Decode char into row number (byte 1) and code within row (byte 2).  */
      row = c >> 8;
      within = c & 0177;
      if (!(within >= font->min_char_or_byte2
	    && within <= font->max_char_or_byte2
	    && row >= font->min_byte1
	    && row <= font->max_byte1))
	{
	  /* If char is out of range, try the font's default char instead.  */
	  c = font->default_char;
	  row = c >> (BITS_PER_INT - 8);
	  within = c & 0177;
	}
      if (!(within >= font->min_char_or_byte2
	    && within <= font->max_char_or_byte2
	    && row >= font->min_byte1
	    && row <= font->max_byte1))
	/* Still out of range means this char does not overlap.  */
	return 0;
      else
	/* We found the info for this char.  */
	s = (font->per_char + (within - font->min_char_or_byte2)
	     + row * rowlen);
    }

  return (s && s->rbearing >= s->width);
}
#endif /* 0 */

/* Invert the middle quarter of the frame for .15 sec.  */

/* We use the select system call to do the waiting, so we have to make sure
   it's available.  If it isn't, we just won't do visual bells.  */
#if defined (HAVE_TIMEVAL) && defined (HAVE_SELECT)

/* Subtract the `struct timeval' values X and Y,
   storing the result in RESULT.
   Return 1 if the difference is negative, otherwise 0.  */

static int
timeval_subtract (result, x, y)
     struct timeval *result, x, y;
{
  /* Perform the carry for the later subtraction by updating y.
     This is safer because on some systems
     the tv_sec member is unsigned.  */
  if (x.tv_usec < y.tv_usec)
    {
      int nsec = (y.tv_usec - x.tv_usec) / 1000000 + 1;
      y.tv_usec -= 1000000 * nsec;
      y.tv_sec += nsec;
    }
  if (x.tv_usec - y.tv_usec > 1000000)
    {
      int nsec = (y.tv_usec - x.tv_usec) / 1000000;
      y.tv_usec += 1000000 * nsec;
      y.tv_sec -= nsec;
    }

  /* Compute the time remaining to wait.  tv_usec is certainly positive.  */
  result->tv_sec = x.tv_sec - y.tv_sec;
  result->tv_usec = x.tv_usec - y.tv_usec;

  /* Return indication of whether the result should be considered negative.  */
  return x.tv_sec < y.tv_sec;
}

void
XTflash (f)
     struct frame *f;
{
  BLOCK_INPUT;

  {
    GC gc;

    /* Create a GC that will use the GXxor function to flip foreground pixels
       into background pixels.  */
    {
      XGCValues values;

      values.function = GXxor;
      values.foreground = (f->output_data.x->foreground_pixel
			   ^ f->output_data.x->background_pixel);

      gc = XCreateGC (FRAME_X_DISPLAY (f), FRAME_X_WINDOW (f),
		      GCFunction | GCForeground, &values);
    }

    {
      /* Get the height not including a menu bar widget.  */
      int height = CHAR_TO_PIXEL_HEIGHT (f, FRAME_HEIGHT (f));
      /* Height of each line to flash.  */
      int flash_height = FRAME_LINE_HEIGHT (f);
      /* These will be the left and right margins of the rectangles.  */
      int flash_left = FRAME_INTERNAL_BORDER_WIDTH (f);
      int flash_right = PIXEL_WIDTH (f) - FRAME_INTERNAL_BORDER_WIDTH (f);

      int width;

      /* Don't flash the area between a scroll bar and the frame
	 edge it is next to.  */
      switch (FRAME_VERTICAL_SCROLL_BAR_TYPE (f))
	{
	case vertical_scroll_bar_left:
	  flash_left += VERTICAL_SCROLL_BAR_WIDTH_TRIM;
	  break;

	case vertical_scroll_bar_right:
	  flash_right -= VERTICAL_SCROLL_BAR_WIDTH_TRIM;
	  break;
	}

      width = flash_right - flash_left;

      /* If window is tall, flash top and bottom line.  */
      if (height > 3 * FRAME_LINE_HEIGHT (f))
	{
	  XFillRectangle (FRAME_X_DISPLAY (f), FRAME_X_WINDOW (f), gc,
			  flash_left, FRAME_INTERNAL_BORDER_WIDTH (f),
			  width, flash_height);
	  XFillRectangle (FRAME_X_DISPLAY (f), FRAME_X_WINDOW (f), gc,
			  flash_left,
			  (height - flash_height
			   - FRAME_INTERNAL_BORDER_WIDTH (f)),
			  width, flash_height);
	}
      else
	/* If it is short, flash it all.  */ 
	XFillRectangle (FRAME_X_DISPLAY (f), FRAME_X_WINDOW (f), gc,
			flash_left, FRAME_INTERNAL_BORDER_WIDTH (f),
			width, height - 2 * FRAME_INTERNAL_BORDER_WIDTH (f));

      XFlush (FRAME_X_DISPLAY (f));

      {
	struct timeval wakeup, now;

	EMACS_GET_TIME (wakeup);

	/* Compute time to wait until, propagating carry from usecs.  */
	wakeup.tv_usec += 150000;
	wakeup.tv_sec += (wakeup.tv_usec / 1000000);
	wakeup.tv_usec %= 1000000;

	/* Keep waiting until past the time wakeup.  */
	while (1)
	  {
	    struct timeval timeout;

	    EMACS_GET_TIME (timeout);

	    /* In effect, timeout = wakeup - timeout.
	       Break if result would be negative.  */
	    if (timeval_subtract (&timeout, wakeup, timeout))
	      break;

	    /* Try to wait that long--but we might wake up sooner.  */
	    select (0, NULL, NULL, NULL, &timeout);
	  }
      }

      /* If window is tall, flash top and bottom line.  */
      if (height > 3 * FRAME_LINE_HEIGHT (f))
	{
	  XFillRectangle (FRAME_X_DISPLAY (f), FRAME_X_WINDOW (f), gc,
			  flash_left, FRAME_INTERNAL_BORDER_WIDTH (f),
			  width, flash_height);
	  XFillRectangle (FRAME_X_DISPLAY (f), FRAME_X_WINDOW (f), gc,
			  flash_left,
			  (height - flash_height
			   - FRAME_INTERNAL_BORDER_WIDTH (f)),
			  width, flash_height);
	}
      else
	/* If it is short, flash it all.  */ 
	XFillRectangle (FRAME_X_DISPLAY (f), FRAME_X_WINDOW (f), gc,
			flash_left, FRAME_INTERNAL_BORDER_WIDTH (f),
			width, height - 2 * FRAME_INTERNAL_BORDER_WIDTH (f));

      XFreeGC (FRAME_X_DISPLAY (f), gc);
      XFlush (FRAME_X_DISPLAY (f));
    }
  }

  UNBLOCK_INPUT;
}

#endif


/* Make audible bell.  */

#define XRINGBELL XBell (FRAME_X_DISPLAY (selected_frame), 0)

void
XTring_bell ()
{
  if (FRAME_X_DISPLAY (selected_frame) == 0)
    return;

#if defined (HAVE_TIMEVAL) && defined (HAVE_SELECT)
  if (visible_bell)
    XTflash (selected_frame);
  else
#endif
    {
      BLOCK_INPUT;
      XRINGBELL;
      XFlush (FRAME_X_DISPLAY (selected_frame));
      UNBLOCK_INPUT;
    }
}

/* Insert and delete character.
   These are not supposed to be used because we are supposed to turn
   off the feature of using them.  */

static void
XTinsert_glyphs (start, len)
     register char *start;
     register int len;
{
  abort ();
}

static void
XTdelete_glyphs (n)
     register int n;
{
  abort ();
}

/* Specify how many text lines, from the top of the window,
   should be affected by insert-lines and delete-lines operations.
   This, and those operations, are used only within an update
   that is bounded by calls to XTupdate_begin and XTupdate_end.  */

static void
XTset_terminal_window (n)
     register int n;
{
  if (updating_frame == 0)
    abort ();

  if ((n <= 0) || (n > updating_frame->height))
    flexlines = updating_frame->height;
  else
    flexlines = n;
}

/* These variables need not be per frame
   because redisplay is done on a frame-by-frame basis
   and the line dance for one frame is finished before
   anything is done for anoter frame.  */

/* Array of line numbers from cached insert/delete operations.
   line_dance[i] is the old position of the line that we want
   to move to line i, or -1 if we want a blank line there.  */
static int *line_dance;

/* Allocated length of that array.  */
static int line_dance_len;

/* Flag indicating whether we've done any work.  */
static int line_dance_in_progress;

/* Perform an insert-lines or delete-lines operation,
   inserting N lines or deleting -N lines at vertical position VPOS.  */
void
XTins_del_lines (vpos, n)
     int vpos, n;
{
  register int fence, i;

  if (vpos >= flexlines)
    return;

  if (!line_dance_in_progress)
    {
      int ht = updating_frame->height;
      if (ht > line_dance_len)
	{
	  line_dance = (int *)xrealloc (line_dance, ht * sizeof (int));
	  line_dance_len = ht;
	}
      for (i = 0; i < ht; ++i) line_dance[i] = i;
      line_dance_in_progress = 1;
    }
  if (n >= 0)
    {
      if (n > flexlines - vpos)
	n = flexlines - vpos;
      fence = vpos + n;
      for (i = flexlines; --i >= fence;)
	line_dance[i] = line_dance[i-n];
      for (i = fence; --i >= vpos;)
	line_dance[i] = -1;
    }
  else
    {
      n = -n;
      if (n > flexlines - vpos)
	n = flexlines - vpos;
      fence = flexlines - n;
      for (i = vpos; i < fence; ++i)
	line_dance[i] = line_dance[i + n];
      for (i = fence; i < flexlines; ++i)
	line_dance[i] = -1;
    }
}

/* Here's where we actually move the pixels around.
   Must be called with input blocked.  */
static void
do_line_dance ()
{
  register int i, j, distance;
  register struct frame *f;
  int ht;
  int intborder;

  /* Must check this flag first.  If it's not set, then not only is the
     array uninitialized, but we might not even have a frame.  */
  if (!line_dance_in_progress)
    return;

  f = updating_frame;
  if (f == 0)
    abort ();

  ht = f->height;
  intborder = CHAR_TO_PIXEL_COL (f, FRAME_LEFT_SCROLL_BAR_WIDTH (f));

  x_update_cursor (updating_frame, 0);

  for (i = 0; i < ht; ++i)
    if (line_dance[i] != -1 && (distance = line_dance[i]-i) > 0)
      {
	for (j = i; (j < ht && line_dance[j] != -1
		     && line_dance[j]-j == distance); ++j);
	/* Copy [i,j) upward from [i+distance,j+distance) */
	XCopyArea (FRAME_X_DISPLAY (f), FRAME_X_WINDOW (f),
		   FRAME_X_WINDOW (f), f->output_data.x->normal_gc,
		   intborder, CHAR_TO_PIXEL_ROW (f, i+distance),
		   FRAME_WINDOW_WIDTH (f) * FONT_WIDTH (f->output_data.x->font),
		   (j-i) * f->output_data.x->line_height,
		   intborder, CHAR_TO_PIXEL_ROW (f, i));
	i = j-1;
      }

  for (i = ht; --i >=0; )
    if (line_dance[i] != -1 && (distance = line_dance[i]-i) < 0)
      {
	for (j = i; (--j >= 0 && line_dance[j] != -1
		     && line_dance[j]-j == distance););
	/* Copy (j,i] downward from (j+distance, i+distance] */
	XCopyArea (FRAME_X_DISPLAY (f), FRAME_X_WINDOW (f),
		   FRAME_X_WINDOW (f), f->output_data.x->normal_gc,
		   intborder, CHAR_TO_PIXEL_ROW (f, j+1+distance),
		   FRAME_WINDOW_WIDTH (f) * FONT_WIDTH (f->output_data.x->font),
		   (i-j) * f->output_data.x->line_height,
		   intborder, CHAR_TO_PIXEL_ROW (f, j+1));
	i = j+1;
      }

  for (i = 0; i < ht; ++i)
    if (line_dance[i] == -1)
      {
	for (j = i; j < ht && line_dance[j] == -1; ++j);
	/* Clear [i,j) */
	XClearArea (FRAME_X_DISPLAY (f), FRAME_X_WINDOW (f),
		    intborder, CHAR_TO_PIXEL_ROW (f, i),
		    FRAME_WINDOW_WIDTH (f) * FONT_WIDTH (f->output_data.x->font),
		    (j-i) * f->output_data.x->line_height, False);
	i = j-1;
      }
  line_dance_in_progress = 0;
}

/* Support routines for exposure events.  */
static void clear_cursor ();

/* Output into a rectangle of an X-window (for frame F)
   the characters in f->phys_lines that overlap that rectangle.
   TOP and LEFT are the position of the upper left corner of the rectangle.
   ROWS and COLS are the size of the rectangle.
   Call this function with input blocked.  */

static void
dumprectangle (f, left, top, cols, rows)
     struct frame *f;
     register int left, top, cols, rows;
{
  register struct frame_glyphs *active_frame = FRAME_CURRENT_GLYPHS (f);
  int cursor_cleared = 0;
  int bottom, right;
  register int y;

  if (FRAME_GARBAGED_P (f))
    return;

  /* Express rectangle as four edges, instead of position-and-size.  */
  bottom = top + rows;
  right = left + cols;

  /* Convert rectangle edges in pixels to edges in chars.
     Round down for left and top, up for right and bottom.  */
  top  = PIXEL_TO_CHAR_ROW (f, top);
  left = PIXEL_TO_CHAR_COL (f, left);
  bottom += (f->output_data.x->line_height - 1);
  right += (FONT_WIDTH (f->output_data.x->font) - 1);
  bottom = PIXEL_TO_CHAR_ROW (f, bottom);
  right = PIXEL_TO_CHAR_COL (f, right);

  /* Clip the rectangle to what can be visible.  */
  if (left < 0)
    left = 0;
  if (top < 0)
    top = 0;
  if (right > FRAME_WINDOW_WIDTH (f))
    right = FRAME_WINDOW_WIDTH (f);
  if (bottom > f->height)
    bottom = f->height;

  /* Get size in chars of the rectangle.  */
  cols = right - left;
  rows = bottom - top;

  /* If rectangle has zero area, return.  */
  if (rows <= 0) return;
  if (cols <= 0) return;

  /* Turn off the cursor if it is in the rectangle.
     We will turn it back on afterward.  */
  if ((f->phys_cursor_x >= left) && (f->phys_cursor_x < right)
      && (f->phys_cursor_y >= top) && (f->phys_cursor_y < bottom))
    {
      clear_cursor (f);
      cursor_cleared = 1;
    }

  /* Display the text in the rectangle, one text line at a time.  */

  for (y = top; y < bottom; y++)
    {
      GLYPH *line = &active_frame->glyphs[y][left];

      if (! active_frame->enable[y] || left > active_frame->used[y])
	continue;

      while (*line & GLYPH_MASK_PADDING)
	{
	  /* We must display the whole glyph of a wide-column
             character.  */
	  left--;
	  line--;
	  cols++;
	}
      dumpglyphs (f,
		  CHAR_TO_PIXEL_COL (f, left),
		  CHAR_TO_PIXEL_ROW (f, y),
		  line, min (cols, active_frame->used[y] - left),
		  active_frame->highlight[y], 0, NULL);
    }

  /* Turn the cursor on if we turned it off.  */

  if (cursor_cleared)
    x_update_cursor (f, 1);
}

static void
frame_highlight (f)
     struct frame *f;
{
  /* We used to only do this if Vx_no_window_manager was non-nil, but
     the ICCCM (section 4.1.6) says that the window's border pixmap
     and border pixel are window attributes which are "private to the
     client", so we can always change it to whatever we want.  */
  BLOCK_INPUT;
  XSetWindowBorder (FRAME_X_DISPLAY (f), FRAME_X_WINDOW (f),
		    f->output_data.x->border_pixel);
  UNBLOCK_INPUT;
  x_update_cursor (f, 1);
}

static void
frame_unhighlight (f)
     struct frame *f;
{
  /* We used to only do this if Vx_no_window_manager was non-nil, but
     the ICCCM (section 4.1.6) says that the window's border pixmap
     and border pixel are window attributes which are "private to the
     client", so we can always change it to whatever we want.  */
  BLOCK_INPUT;
  XSetWindowBorderPixmap (FRAME_X_DISPLAY (f), FRAME_X_WINDOW (f),
			  f->output_data.x->border_tile);
  UNBLOCK_INPUT;
  x_update_cursor (f, 1);
}

static void XTframe_rehighlight ();
static void x_frame_rehighlight ();

/* The focus has changed.  Update the frames as necessary to reflect
   the new situation.  Note that we can't change the selected frame
   here, because the Lisp code we are interrupting might become confused.
   Each event gets marked with the frame in which it occurred, so the
   Lisp code can tell when the switch took place by examining the events.  */

static void
x_new_focus_frame (dpyinfo, frame)
     struct x_display_info *dpyinfo;
     struct frame *frame;
{
  struct frame *old_focus = dpyinfo->x_focus_frame;
  int events_enqueued = 0;

  if (frame != dpyinfo->x_focus_frame)
    {
      /* Set this before calling other routines, so that they see
	 the correct value of x_focus_frame.  */
      dpyinfo->x_focus_frame = frame;

      if (old_focus && old_focus->auto_lower)
	x_lower_frame (old_focus);

#if 0
      selected_frame = frame;
      XSETFRAME (XWINDOW (selected_frame->selected_window)->frame,
		 selected_frame);
      Fselect_window (selected_frame->selected_window);
      choose_minibuf_frame ();
#endif /* ! 0 */

      if (dpyinfo->x_focus_frame && dpyinfo->x_focus_frame->auto_raise)
	pending_autoraise_frame = dpyinfo->x_focus_frame;
      else
	pending_autoraise_frame = 0;
    }

  x_frame_rehighlight (dpyinfo);
}

/* Handle an event saying the mouse has moved out of an Emacs frame.  */

void
x_mouse_leave (dpyinfo)
     struct x_display_info *dpyinfo;
{
  x_new_focus_frame (dpyinfo, dpyinfo->x_focus_event_frame);
}

/* The focus has changed, or we have redirected a frame's focus to
   another frame (this happens when a frame uses a surrogate
   minibuffer frame).  Shift the highlight as appropriate.

   The FRAME argument doesn't necessarily have anything to do with which
   frame is being highlighted or unhighlighted; we only use it to find
   the appropriate X display info.  */
static void
XTframe_rehighlight (frame)
     struct frame *frame;
{
  x_frame_rehighlight (FRAME_X_DISPLAY_INFO (frame));
}

static void
x_frame_rehighlight (dpyinfo)
     struct x_display_info *dpyinfo;
{
  struct frame *old_highlight = dpyinfo->x_highlight_frame;

  if (dpyinfo->x_focus_frame)
    {
      dpyinfo->x_highlight_frame
	= ((GC_FRAMEP (FRAME_FOCUS_FRAME (dpyinfo->x_focus_frame)))
	   ? XFRAME (FRAME_FOCUS_FRAME (dpyinfo->x_focus_frame))
	   : dpyinfo->x_focus_frame);
      if (! FRAME_LIVE_P (dpyinfo->x_highlight_frame))
	{
	  FRAME_FOCUS_FRAME (dpyinfo->x_focus_frame) = Qnil;
	  dpyinfo->x_highlight_frame = dpyinfo->x_focus_frame;
	}
    }
  else
    dpyinfo->x_highlight_frame = 0;

  if (dpyinfo->x_highlight_frame != old_highlight)
    {
      if (old_highlight)
	frame_unhighlight (old_highlight);
      if (dpyinfo->x_highlight_frame)
	frame_highlight (dpyinfo->x_highlight_frame);
    }
}

/* Keyboard processing - modifier keys, vendor-specific keysyms, etc. */

/* Initialize mode_switch_bit and modifier_meaning.  */
static void
x_find_modifier_meanings (dpyinfo)
     struct x_display_info *dpyinfo;
{
  int min_code, max_code;
  KeySym *syms;
  int syms_per_code;
  XModifierKeymap *mods;

  dpyinfo->meta_mod_mask = 0;
  dpyinfo->shift_lock_mask = 0;
  dpyinfo->alt_mod_mask = 0;
  dpyinfo->super_mod_mask = 0;
  dpyinfo->hyper_mod_mask = 0;

#ifdef HAVE_X11R4
  XDisplayKeycodes (dpyinfo->display, &min_code, &max_code);
#else
  min_code = dpyinfo->display->min_keycode;
  max_code = dpyinfo->display->max_keycode;
#endif

  syms = XGetKeyboardMapping (dpyinfo->display,
			      min_code, max_code - min_code + 1,
			      &syms_per_code);
  mods = XGetModifierMapping (dpyinfo->display);

  /* Scan the modifier table to see which modifier bits the Meta and
     Alt keysyms are on.  */
  {
    int row, col;	/* The row and column in the modifier table. */

    for (row = 3; row < 8; row++)
      for (col = 0; col < mods->max_keypermod; col++)
	{
	  KeyCode code
	    = mods->modifiermap[(row * mods->max_keypermod) + col];

	  /* Zeroes are used for filler.  Skip them.  */
	  if (code == 0)
	    continue;

	  /* Are any of this keycode's keysyms a meta key?  */
	  {
	    int code_col;

	    for (code_col = 0; code_col < syms_per_code; code_col++)
	      {
		int sym = syms[((code - min_code) * syms_per_code) + code_col];

		switch (sym)
		  {
		  case XK_Meta_L:
		  case XK_Meta_R:
		    dpyinfo->meta_mod_mask |= (1 << row);
		    break;

		  case XK_Alt_L:
		  case XK_Alt_R:
		    dpyinfo->alt_mod_mask |= (1 << row);
		    break;

		  case XK_Hyper_L:
		  case XK_Hyper_R:
		    dpyinfo->hyper_mod_mask |= (1 << row);
		    break;

		  case XK_Super_L:
		  case XK_Super_R:
		    dpyinfo->super_mod_mask |= (1 << row);
		    break;

		  case XK_Shift_Lock:
		    /* Ignore this if it's not on the lock modifier.  */
		    if ((1 << row) == LockMask)
		      dpyinfo->shift_lock_mask = LockMask;
		    break;
		  }
	      }
	  }
	}
  }

  /* If we couldn't find any meta keys, accept any alt keys as meta keys.  */
  if (! dpyinfo->meta_mod_mask)
    {
      dpyinfo->meta_mod_mask = dpyinfo->alt_mod_mask;
      dpyinfo->alt_mod_mask = 0;
    }

  /* If some keys are both alt and meta,
     make them just meta, not alt.  */
  if (dpyinfo->alt_mod_mask & dpyinfo->meta_mod_mask)
    {
      dpyinfo->alt_mod_mask &= ~dpyinfo->meta_mod_mask;
    }

  XFree ((char *) syms);
  XFreeModifiermap (mods);
}

/* Convert between the modifier bits X uses and the modifier bits
   Emacs uses.  */
static unsigned int
x_x_to_emacs_modifiers (dpyinfo, state)
     struct x_display_info *dpyinfo;
     unsigned int state;
{
  return (  ((state & (ShiftMask | dpyinfo->shift_lock_mask)) ? shift_modifier : 0)
	  | ((state & ControlMask)	       ? ctrl_modifier  : 0)
	  | ((state & dpyinfo->meta_mod_mask)  ? meta_modifier  : 0)
	  | ((state & dpyinfo->alt_mod_mask)   ? alt_modifier  : 0)
	  | ((state & dpyinfo->super_mod_mask) ? super_modifier  : 0)
	  | ((state & dpyinfo->hyper_mod_mask) ? hyper_modifier  : 0));
}

static unsigned int
x_emacs_to_x_modifiers (dpyinfo, state)
     struct x_display_info *dpyinfo;
     unsigned int state;
{
  return (  ((state & alt_modifier)	? dpyinfo->alt_mod_mask   : 0)
	  | ((state & super_modifier)	? dpyinfo->super_mod_mask : 0)
	  | ((state & hyper_modifier)	? dpyinfo->hyper_mod_mask : 0)
	  | ((state & shift_modifier)	? ShiftMask        : 0)
	  | ((state & ctrl_modifier)	? ControlMask      : 0)
	  | ((state & meta_modifier)	? dpyinfo->meta_mod_mask  : 0));
}

/* Convert a keysym to its name.  */

char *
x_get_keysym_name (keysym)
     KeySym keysym;
{
  char *value;

  BLOCK_INPUT;
  value = XKeysymToString (keysym);
  UNBLOCK_INPUT;

  return value;
}

/* Mouse clicks and mouse movement.  Rah.  */

/* Given a pixel position (PIX_X, PIX_Y) on the frame F, return
   glyph co-ordinates in (*X, *Y).  Set *BOUNDS to the rectangle
   that the glyph at X, Y occupies, if BOUNDS != 0.
   If NOCLIP is nonzero, do not force the value into range.  */

void
pixel_to_glyph_coords (f, pix_x, pix_y, x, y, bounds, noclip)
     FRAME_PTR f;
     register int pix_x, pix_y;
     register int *x, *y;
     XRectangle *bounds;
     int noclip;
{
  /* Arrange for the division in PIXEL_TO_CHAR_COL etc. to round down
     even for negative values.  */
  if (pix_x < 0)
    pix_x -= FONT_WIDTH ((f)->output_data.x->font) - 1;
  if (pix_y < 0)
    pix_y -= (f)->output_data.x->line_height - 1;

  pix_x = PIXEL_TO_CHAR_COL (f, pix_x);
  pix_y = PIXEL_TO_CHAR_ROW (f, pix_y);

  if (bounds)
    {
      bounds->width  = FONT_WIDTH  (f->output_data.x->font);
      bounds->height = f->output_data.x->line_height;
      bounds->x = CHAR_TO_PIXEL_COL (f, pix_x);
      bounds->y = CHAR_TO_PIXEL_ROW (f, pix_y);
    }

  if (!noclip)
    {
      if (pix_x < 0)
	pix_x = 0;
      else if (pix_x > FRAME_WINDOW_WIDTH (f))
	pix_x = FRAME_WINDOW_WIDTH (f);

      if (pix_y < 0)
	pix_y = 0;
      else if (pix_y > f->height)
	pix_y = f->height;
    }

  *x = pix_x;
  *y = pix_y;
}

void
glyph_to_pixel_coords (f, x, y, pix_x, pix_y)
     FRAME_PTR f;
     register int x, y;
     register int *pix_x, *pix_y;
{
  *pix_x = CHAR_TO_PIXEL_COL (f, x);
  *pix_y = CHAR_TO_PIXEL_ROW (f, y);
}

/* Prepare a mouse-event in *RESULT for placement in the input queue.

   If the event is a button press, then note that we have grabbed
   the mouse.  */

static Lisp_Object
construct_mouse_click (result, event, f)
     struct input_event *result;
     XButtonEvent *event;
     struct frame *f;
{
  /* Make the event type no_event; we'll change that when we decide
     otherwise.  */
  result->kind = mouse_click;
  result->code = event->button - Button1;
  result->timestamp = event->time;
  result->modifiers = (x_x_to_emacs_modifiers (FRAME_X_DISPLAY_INFO (f),
					       event->state)
		       | (event->type == ButtonRelease
			  ? up_modifier
			  : down_modifier));

  {
    int row, column;

#if 0
    pixel_to_glyph_coords (f, event->x, event->y, &column, &row, NULL, 0);
    XSETFASTINT (result->x, column);
    XSETFASTINT (result->y, row);
#endif
    XSETINT (result->x, event->x);
    XSETINT (result->y, event->y);
    XSETFRAME (result->frame_or_window, f);
  }
}

/* Prepare a menu-event in *RESULT for placement in the input queue.  */

static Lisp_Object
construct_menu_click (result, event, f)
     struct input_event *result;
     XButtonEvent *event;
     struct frame *f;
{
  /* Make the event type no_event; we'll change that when we decide
     otherwise.  */
  result->kind = mouse_click;
  result->code = event->button - Button1;
  result->timestamp = event->time;
  result->modifiers = (x_x_to_emacs_modifiers (FRAME_X_DISPLAY_INFO (f),
					       event->state)
		       | (event->type == ButtonRelease
			  ? up_modifier
			  : down_modifier));

  XSETINT (result->x, event->x);
  XSETINT (result->y, -1);
  XSETFRAME (result->frame_or_window, f);
}

/* Function to report a mouse movement to the mainstream Emacs code.
   The input handler calls this.

   We have received a mouse movement event, which is given in *event.
   If the mouse is over a different glyph than it was last time, tell
   the mainstream emacs code by setting mouse_moved.  If not, ask for
   another motion event, so we can check again the next time it moves.  */

static void
note_mouse_movement (frame, event)
     FRAME_PTR frame;
     XMotionEvent *event;
{
  last_mouse_movement_time = event->time;

  if (event->window != FRAME_X_WINDOW (frame))
    {
      frame->mouse_moved = 1;
      last_mouse_scroll_bar = Qnil;

      note_mouse_highlight (frame, -1, -1);
    }

  /* Has the mouse moved off the glyph it was on at the last sighting?  */
  else if (event->x < last_mouse_glyph.x
	   || event->x >= last_mouse_glyph.x + last_mouse_glyph.width
	   || event->y < last_mouse_glyph.y
	   || event->y >= last_mouse_glyph.y + last_mouse_glyph.height)
    {
      frame->mouse_moved = 1;
      last_mouse_scroll_bar = Qnil;

      note_mouse_highlight (frame, event->x, event->y);
    }
}

/* This is used for debugging, to turn off note_mouse_highlight.  */
static int disable_mouse_highlight;

/* Take proper action when the mouse has moved to position X, Y on frame F
   as regards highlighting characters that have mouse-face properties.
   Also dehighlighting chars where the mouse was before.
   X and Y can be negative or out of range.  */

static void
note_mouse_highlight (f, x, y)
     FRAME_PTR f;
     int x, y;
{
  int row, column, portion;
  XRectangle new_glyph;
  Lisp_Object window;
  struct window *w;

  if (disable_mouse_highlight)
    return;

  FRAME_X_DISPLAY_INFO (f)->mouse_face_mouse_x = x;
  FRAME_X_DISPLAY_INFO (f)->mouse_face_mouse_y = y;
  FRAME_X_DISPLAY_INFO (f)->mouse_face_mouse_frame = f;

  if (FRAME_X_DISPLAY_INFO (f)->mouse_face_defer)
    return;

  if (gc_in_progress)
    {
      FRAME_X_DISPLAY_INFO (f)->mouse_face_deferred_gc = 1;
      return;
    }

  /* Find out which glyph the mouse is on.  */
  pixel_to_glyph_coords (f, x, y, &column, &row,
			 &new_glyph, FRAME_X_DISPLAY_INFO (f)->grabbed);

  /* Which window is that in?  */
  window = window_from_coordinates (f, column, row, &portion);
  w = XWINDOW (window);

  /* If we were displaying active text in another window, clear that.  */
  if (! EQ (window, FRAME_X_DISPLAY_INFO (f)->mouse_face_window))
    clear_mouse_face (FRAME_X_DISPLAY_INFO (f));

  /* Are we in a window whose display is up to date?
     And verify the buffer's text has not changed.  */
  if (WINDOWP (window) && portion == 0 && row >= 0 && column >= 0
      && row < FRAME_HEIGHT (f) && column < FRAME_WIDTH (f)
      && EQ (w->window_end_valid, w->buffer)
      && XFASTINT (w->last_modified) == BUF_MODIFF (XBUFFER (w->buffer))
      && (XFASTINT (w->last_overlay_modified)
	  == BUF_OVERLAY_MODIFF (XBUFFER (w->buffer))))
    {
      int *ptr = FRAME_CURRENT_GLYPHS (f)->charstarts[row];
      int i, pos;

      /* Find which buffer position the mouse corresponds to.  */
      for (i = column; i >= 0; i--)
	if (ptr[i] > 0)
	  break;
      pos = ptr[i];
      /* Is it outside the displayed active region (if any)?  */
      if (pos <= 0)
	clear_mouse_face (FRAME_X_DISPLAY_INFO (f));
      else if (! (EQ (window, FRAME_X_DISPLAY_INFO (f)->mouse_face_window)
		  && row >= FRAME_X_DISPLAY_INFO (f)->mouse_face_beg_row
		  && row <= FRAME_X_DISPLAY_INFO (f)->mouse_face_end_row
		  && (row > FRAME_X_DISPLAY_INFO (f)->mouse_face_beg_row
		      || column >= FRAME_X_DISPLAY_INFO (f)->mouse_face_beg_col)
		  && (row < FRAME_X_DISPLAY_INFO (f)->mouse_face_end_row
		      || column < FRAME_X_DISPLAY_INFO (f)->mouse_face_end_col
		      || FRAME_X_DISPLAY_INFO (f)->mouse_face_past_end)))
	{
	  Lisp_Object mouse_face, overlay, position;
	  Lisp_Object *overlay_vec;
	  int len, noverlays, ignor1;
	  struct buffer *obuf;
	  int obegv, ozv;

	  /* If we get an out-of-range value, return now; avoid an error.  */
	  if (pos > BUF_Z (XBUFFER (w->buffer)))
	    return;

	  /* Make the window's buffer temporarily current for
	     overlays_at and compute_char_face.  */
	  obuf = current_buffer;
	  current_buffer = XBUFFER (w->buffer);
	  obegv = BEGV;
	  ozv = ZV;
	  BEGV = BEG;
	  ZV = Z;

	  /* Yes.  Clear the display of the old active region, if any.  */
	  clear_mouse_face (FRAME_X_DISPLAY_INFO (f));

	  /* Is this char mouse-active?  */
	  XSETINT (position, pos);

	  len = 10;
	  overlay_vec = (Lisp_Object *) xmalloc (len * sizeof (Lisp_Object));

	  /* Put all the overlays we want in a vector in overlay_vec.
	     Store the length in len.  */
	  noverlays = overlays_at (pos, 1, &overlay_vec, &len,
				   NULL, NULL);
	  noverlays = sort_overlays (overlay_vec, noverlays, w);

	  /* Find the highest priority overlay that has a mouse-face prop.  */
	  overlay = Qnil;
	  for (i = 0; i < noverlays; i++)
	    {
	      mouse_face = Foverlay_get (overlay_vec[i], Qmouse_face);
	      if (!NILP (mouse_face))
		{
		  overlay = overlay_vec[i];
		  break;
		}
	    }
	  free (overlay_vec);
	  /* If no overlay applies, get a text property.  */
	  if (NILP (overlay))
	    mouse_face = Fget_text_property (position, Qmouse_face, w->buffer);

	  /* Handle the overlay case.  */
	  if (! NILP (overlay))
	    {
	      /* Find the range of text around this char that
		 should be active.  */
	      Lisp_Object before, after;
	      int ignore;

	      before = Foverlay_start (overlay);
	      after = Foverlay_end (overlay);
	      /* Record this as the current active region.  */
	      fast_find_position (window, XFASTINT (before),
				  &FRAME_X_DISPLAY_INFO (f)->mouse_face_beg_col,
				  &FRAME_X_DISPLAY_INFO (f)->mouse_face_beg_row);
	      FRAME_X_DISPLAY_INFO (f)->mouse_face_past_end
		= !fast_find_position (window, XFASTINT (after),
				       &FRAME_X_DISPLAY_INFO (f)->mouse_face_end_col,
				       &FRAME_X_DISPLAY_INFO (f)->mouse_face_end_row);
	      FRAME_X_DISPLAY_INFO (f)->mouse_face_window = window;
	      FRAME_X_DISPLAY_INFO (f)->mouse_face_face_id
		= compute_char_face (f, w, pos, 0, 0,
				     &ignore, pos + 1, 1);

	      /* Display it as active.  */
	      show_mouse_face (FRAME_X_DISPLAY_INFO (f), 1);
	    }
	  /* Handle the text property case.  */
	  else if (! NILP (mouse_face))
	    {
	      /* Find the range of text around this char that
		 should be active.  */
	      Lisp_Object before, after, beginning, end;
	      int ignore;

	      beginning = Fmarker_position (w->start);
	      XSETINT (end, (BUF_Z (XBUFFER (w->buffer))
			     - XFASTINT (w->window_end_pos)));
	      before
		= Fprevious_single_property_change (make_number (pos + 1),
						    Qmouse_face,
						    w->buffer, beginning);
	      after
		= Fnext_single_property_change (position, Qmouse_face,
						w->buffer, end);
	      /* Record this as the current active region.  */
	      fast_find_position (window, XFASTINT (before),
				  &FRAME_X_DISPLAY_INFO (f)->mouse_face_beg_col,
				  &FRAME_X_DISPLAY_INFO (f)->mouse_face_beg_row);
	      FRAME_X_DISPLAY_INFO (f)->mouse_face_past_end
		= !fast_find_position (window, XFASTINT (after),
				       &FRAME_X_DISPLAY_INFO (f)->mouse_face_end_col,
				       &FRAME_X_DISPLAY_INFO (f)->mouse_face_end_row);
	      FRAME_X_DISPLAY_INFO (f)->mouse_face_window = window;
	      FRAME_X_DISPLAY_INFO (f)->mouse_face_face_id
		= compute_char_face (f, w, pos, 0, 0,
				     &ignore, pos + 1, 1);

	      /* Display it as active.  */
	      show_mouse_face (FRAME_X_DISPLAY_INFO (f), 1);
	    }
	  BEGV = obegv;
	  ZV = ozv;
	  current_buffer = obuf;
	}
    }
}

/* Find the row and column of position POS in window WINDOW.
   Store them in *COLUMNP and *ROWP.
   This assumes display in WINDOW is up to date.
   If POS is above start of WINDOW, return coords
   of start of first screen line.
   If POS is after end of WINDOW, return coords of end of last screen line.

   Value is 1 if POS is in range, 0 if it was off screen.  */

static int
fast_find_position (window, pos, columnp, rowp)
     Lisp_Object window;
     int pos;
     int *columnp, *rowp;
{
  struct window *w = XWINDOW (window);
  FRAME_PTR f = XFRAME (WINDOW_FRAME (w));
  int i;
  int row = 0;
  int left = WINDOW_LEFT_MARGIN (w);
  int top = XFASTINT (w->top);
  int height = XFASTINT (w->height) - ! MINI_WINDOW_P (w);
  int width = window_internal_width (w);
  int *charstarts;
  int lastcol;
  int maybe_next_line = 0;

  /* Find the right row.  */
  for (i = 0;
       i < height;
       i++)
    {
      int linestart = FRAME_CURRENT_GLYPHS (f)->charstarts[top + i][left];
      if (linestart > pos)
	break;
      /* If the position sought is the end of the buffer,
	 don't include the blank lines at the bottom of the window.  */
      if (linestart == pos && pos == BUF_ZV (XBUFFER (w->buffer)))
	{
	  maybe_next_line = 1;
	  break;
	}
      if (linestart > 0)
	row = i;
    }

  /* Find the right column with in it.  */
  charstarts = FRAME_CURRENT_GLYPHS (f)->charstarts[top + row];
  lastcol = left;
  for (i = 0; i < width; i++)
    {
      if (charstarts[left + i] == pos)
	{
	  *rowp = row + top;
	  *columnp = i + left;
	  return 1;
	}
      else if (charstarts[left + i] > pos)
	break;
      else if (charstarts[left + i] > 0)
	lastcol = left + i + 1;
    }

  /* If we're looking for the end of the buffer,
     and we didn't find it in the line we scanned,
     use the start of the following line.  */
  if (maybe_next_line)
    {
      row++;
      lastcol = left;
    }

  *rowp = row + top;
  *columnp = lastcol;
  return 0;
}

/* Display the active region described by mouse_face_*
   in its mouse-face if HL > 0, in its normal face if HL = 0.  */

static void
show_mouse_face (dpyinfo, hl)
     struct x_display_info *dpyinfo;
     int hl;
{
  struct window *w = XWINDOW (dpyinfo->mouse_face_window);
  int width = window_internal_width (w);
  FRAME_PTR f = XFRAME (WINDOW_FRAME (w));
  int i;
  int cursor_off = 0;
  int old_curs_x = curs_x;
  int old_curs_y = curs_y;

  /* Set these variables temporarily
     so that if we have to turn the cursor off and on again
     we will put it back at the same place.  */
  curs_x = f->phys_cursor_x;
  curs_y = f->phys_cursor_y;  
  for (i = FRAME_X_DISPLAY_INFO (f)->mouse_face_beg_row;
       i <= FRAME_X_DISPLAY_INFO (f)->mouse_face_end_row; i++)
    {
      int column = (i == FRAME_X_DISPLAY_INFO (f)->mouse_face_beg_row
		    ? FRAME_X_DISPLAY_INFO (f)->mouse_face_beg_col
		    : WINDOW_LEFT_MARGIN (w));
      int endcolumn = (i == FRAME_X_DISPLAY_INFO (f)->mouse_face_end_row
		       ? FRAME_X_DISPLAY_INFO (f)->mouse_face_end_col
		       : WINDOW_LEFT_MARGIN (w) + width);
      endcolumn = min (endcolumn, FRAME_CURRENT_GLYPHS (f)->used[i]);

      /* If the cursor's in the text we are about to rewrite,
	 turn the cursor off.  */
      if (i == curs_y
	  && curs_x >= column - 1
	  && curs_x <= endcolumn)
	{
	  x_update_cursor (f, 0);
	  cursor_off = 1;
	}

      dumpglyphs (f,
		  CHAR_TO_PIXEL_COL (f, column),
		  CHAR_TO_PIXEL_ROW (f, i),
		  FRAME_CURRENT_GLYPHS (f)->glyphs[i] + column,
		  endcolumn - column,
		  /* Highlight with mouse face if hl > 0.  */
		  hl > 0 ? 3 : 0, 0, NULL);
    }

  /* If we turned the cursor off, turn it back on.  */
  if (cursor_off)
    x_display_cursor (f, 1, curs_x, curs_y);

  curs_x = old_curs_x;
  curs_y = old_curs_y;

  /* Change the mouse cursor according to the value of HL.  */
  if (hl > 0)
    XDefineCursor (FRAME_X_DISPLAY (f), FRAME_X_WINDOW (f),
		   f->output_data.x->cross_cursor);
  else
    XDefineCursor (FRAME_X_DISPLAY (f), FRAME_X_WINDOW (f),
		   f->output_data.x->text_cursor);
}

/* Clear out the mouse-highlighted active region.
   Redraw it unhighlighted first.  */

static void
clear_mouse_face (dpyinfo)
     struct x_display_info *dpyinfo;
{
  if (! NILP (dpyinfo->mouse_face_window))
    show_mouse_face (dpyinfo, 0);

  dpyinfo->mouse_face_beg_row = dpyinfo->mouse_face_beg_col = -1;
  dpyinfo->mouse_face_end_row = dpyinfo->mouse_face_end_col = -1;
  dpyinfo->mouse_face_window = Qnil;
}

/* Just discard the mouse face information for frame F, if any.
   This is used when the size of F is changed.  */

void
cancel_mouse_face (f)
     FRAME_PTR f;
{
  Lisp_Object window;
  struct x_display_info *dpyinfo = FRAME_X_DISPLAY_INFO (f);

  window = dpyinfo->mouse_face_window;
  if (! NILP (window) && XFRAME (XWINDOW (window)->frame) == f)
    {
      dpyinfo->mouse_face_beg_row = dpyinfo->mouse_face_beg_col = -1;
      dpyinfo->mouse_face_end_row = dpyinfo->mouse_face_end_col = -1;
      dpyinfo->mouse_face_window = Qnil;
    }
}

static struct scroll_bar *x_window_to_scroll_bar ();
static void x_scroll_bar_report_motion ();

/* Return the current position of the mouse.
   *fp should be a frame which indicates which display to ask about.

   If the mouse movement started in a scroll bar, set *fp, *bar_window,
   and *part to the frame, window, and scroll bar part that the mouse
   is over.  Set *x and *y to the portion and whole of the mouse's
   position on the scroll bar.

   If the mouse movement started elsewhere, set *fp to the frame the
   mouse is on, *bar_window to nil, and *x and *y to the character cell
   the mouse is over.

   Set *time to the server timestamp for the time at which the mouse
   was at this position.

   Don't store anything if we don't have a valid set of values to report.

   This clears the mouse_moved flag, so we can wait for the next mouse
   movement.  */

static void
XTmouse_position (fp, insist, bar_window, part, x, y, time)
     FRAME_PTR *fp;
     int insist;
     Lisp_Object *bar_window;
     enum scroll_bar_part *part;
     Lisp_Object *x, *y;
     unsigned long *time;
{
  FRAME_PTR f1;

  BLOCK_INPUT;

  if (! NILP (last_mouse_scroll_bar) && insist == 0)
    x_scroll_bar_report_motion (fp, bar_window, part, x, y, time);
  else
    {
      Window root;
      int root_x, root_y;

      Window dummy_window;
      int dummy;

      Lisp_Object frame, tail;

      /* Clear the mouse-moved flag for every frame on this display.  */
      FOR_EACH_FRAME (tail, frame)
	if (FRAME_X_DISPLAY (XFRAME (frame)) == FRAME_X_DISPLAY (*fp))
	  XFRAME (frame)->mouse_moved = 0;

      last_mouse_scroll_bar = Qnil;

      /* Figure out which root window we're on.  */
      XQueryPointer (FRAME_X_DISPLAY (*fp),
		     DefaultRootWindow (FRAME_X_DISPLAY (*fp)),

		     /* The root window which contains the pointer.  */
		     &root,

		     /* Trash which we can't trust if the pointer is on
			a different screen.  */
		     &dummy_window,

		     /* The position on that root window.  */
		     &root_x, &root_y,

		     /* More trash we can't trust.  */
		     &dummy, &dummy,

		     /* Modifier keys and pointer buttons, about which
			we don't care.  */
		     (unsigned int *) &dummy);

      /* Now we have a position on the root; find the innermost window
	 containing the pointer.  */
      {
	Window win, child;
	int win_x, win_y;
	int parent_x, parent_y;
	int count;

	win = root;

	/* XTranslateCoordinates can get errors if the window
	   structure is changing at the same time this function
	   is running.  So at least we must not crash from them.  */

	count = x_catch_errors (FRAME_X_DISPLAY (*fp));

	if (FRAME_X_DISPLAY_INFO (*fp)->grabbed && last_mouse_frame
	    && FRAME_LIVE_P (last_mouse_frame))
	  {
	    /* If mouse was grabbed on a frame, give coords for that frame
	       even if the mouse is now outside it.  */
	    XTranslateCoordinates (FRAME_X_DISPLAY (*fp),

				   /* From-window, to-window.  */
				   root, FRAME_X_WINDOW (last_mouse_frame),

				   /* From-position, to-position.  */
				   root_x, root_y, &win_x, &win_y,

				   /* Child of win.  */
				   &child);
	    f1 = last_mouse_frame;
	  }
	else
	  {
	    while (1)
	      {
		XTranslateCoordinates (FRAME_X_DISPLAY (*fp),

				       /* From-window, to-window.  */
				       root, win,

				       /* From-position, to-position.  */
				       root_x, root_y, &win_x, &win_y,

				       /* Child of win.  */
				       &child);

		if (child == None || child == win)
		  break;

		win = child;
		parent_x = win_x;
		parent_y = win_y;
	      }

	    /* Now we know that:
	       win is the innermost window containing the pointer
	       (XTC says it has no child containing the pointer),
	       win_x and win_y are the pointer's position in it
	       (XTC did this the last time through), and
	       parent_x and parent_y are the pointer's position in win's parent.
	       (They are what win_x and win_y were when win was child.
	       If win is the root window, it has no parent, and
	       parent_{x,y} are invalid, but that's okay, because we'll
	       never use them in that case.)  */

	    /* Is win one of our frames?  */
	    f1 = x_any_window_to_frame (FRAME_X_DISPLAY_INFO (*fp), win);
	  }

	if (x_had_errors_p (FRAME_X_DISPLAY (*fp)))
	  f1 = 0;

	x_uncatch_errors (FRAME_X_DISPLAY (*fp), count);

	/* If not, is it one of our scroll bars?  */
	if (! f1)
	  {
	    struct scroll_bar *bar = x_window_to_scroll_bar (win);

	    if (bar)
	      {
		f1 = XFRAME (WINDOW_FRAME (XWINDOW (bar->window)));
		win_x = parent_x;
		win_y = parent_y;
	      }
	  }

	if (f1 == 0 && insist > 0)
	  f1 = selected_frame;

	if (f1)
	  {
	    int ignore1, ignore2;

	    /* Ok, we found a frame.  Store all the values.  */

	    pixel_to_glyph_coords (f1, win_x, win_y, &ignore1, &ignore2,
				   &last_mouse_glyph,
				   FRAME_X_DISPLAY_INFO (f1)->grabbed
				   || insist);

	    *bar_window = Qnil;
	    *part = 0;
	    *fp = f1;
	    XSETINT (*x, win_x);
	    XSETINT (*y, win_y);
	    *time = last_mouse_movement_time;
	  }
      }
    }

  UNBLOCK_INPUT;
}

/* Scroll bar support.  */

/* Given an X window ID, find the struct scroll_bar which manages it.
   This can be called in GC, so we have to make sure to strip off mark
   bits.  */
static struct scroll_bar *
x_window_to_scroll_bar (window_id)
     Window window_id;
{
  Lisp_Object tail, frame;

  for (tail = Vframe_list;
       XGCTYPE (tail) == Lisp_Cons;
       tail = XCONS (tail)->cdr)
    {
      Lisp_Object frame, bar, condemned;

      frame = XCONS (tail)->car;
      /* All elements of Vframe_list should be frames.  */
      if (! GC_FRAMEP (frame))
	abort ();

      /* Scan this frame's scroll bar list for a scroll bar with the
         right window ID.  */
      condemned = FRAME_CONDEMNED_SCROLL_BARS (XFRAME (frame));
      for (bar = FRAME_SCROLL_BARS (XFRAME (frame));
	   /* This trick allows us to search both the ordinary and
              condemned scroll bar lists with one loop.  */
	   ! GC_NILP (bar) || (bar = condemned,
			       condemned = Qnil,
			       ! GC_NILP (bar));
	   bar = XSCROLL_BAR (bar)->next)
	if (SCROLL_BAR_X_WINDOW (XSCROLL_BAR (bar)) == window_id)
	  return XSCROLL_BAR (bar);
    }

  return 0;
}

/* Open a new X window to serve as a scroll bar, and return the
   scroll bar vector for it.  */
static struct scroll_bar *
x_scroll_bar_create (window, top, left, width, height)
     struct window *window;
     int top, left, width, height;
{
  FRAME_PTR f = XFRAME (WINDOW_FRAME (window));
  struct scroll_bar *bar
    = XSCROLL_BAR (Fmake_vector (make_number (SCROLL_BAR_VEC_SIZE), Qnil));

  BLOCK_INPUT;

  {
    XSetWindowAttributes a;
    unsigned long mask;
    a.background_pixel = f->output_data.x->background_pixel;
    a.event_mask = (ButtonPressMask | ButtonReleaseMask
		    | ButtonMotionMask | PointerMotionHintMask
		    | ExposureMask);
    a.cursor = FRAME_X_DISPLAY_INFO (f)->vertical_scroll_bar_cursor;

    mask = (CWBackPixel | CWEventMask | CWCursor);

#if 0

    ac = 0;
    XtSetArg (al[ac], XtNx, left); ac++;
    XtSetArg (al[ac], XtNy, top); ac++;
    XtSetArg (al[ac], XtNwidth, width); ac++;
    XtSetArg (al[ac], XtNheight, height); ac++;
    XtSetArg (al[ac], XtNborderWidth, 0); ac++;
    sb_widget = XtCreateManagedWidget ("box",
				       boxWidgetClass,
				       f->output_data.x->edit_widget, al, ac);
    SET_SCROLL_BAR_X_WINDOW
      (bar, sb_widget->core.window);
#endif
    SET_SCROLL_BAR_X_WINDOW
      (bar,
       XCreateWindow (FRAME_X_DISPLAY (f), FRAME_X_WINDOW (f),

		      /* Position and size of scroll bar.  */
		      left + VERTICAL_SCROLL_BAR_WIDTH_TRIM, top,
		      width - VERTICAL_SCROLL_BAR_WIDTH_TRIM * 2, height,

		      /* Border width, depth, class, and visual.  */
		      0, CopyFromParent, CopyFromParent, CopyFromParent,

		      /* Attributes.  */
		      mask, &a));
  }

  XSETWINDOW (bar->window, window);
  XSETINT (bar->top, top);
  XSETINT (bar->left, left);
  XSETINT (bar->width, width);
  XSETINT (bar->height, height);
  XSETINT (bar->start, 0);
  XSETINT (bar->end, 0);
  bar->dragging = Qnil;

  /* Add bar to its frame's list of scroll bars.  */
  bar->next = FRAME_SCROLL_BARS (f);
  bar->prev = Qnil;
  XSETVECTOR (FRAME_SCROLL_BARS (f), bar);
  if (! NILP (bar->next))
    XSETVECTOR (XSCROLL_BAR (bar->next)->prev, bar);

  XMapRaised (FRAME_X_DISPLAY (f), SCROLL_BAR_X_WINDOW (bar));

  UNBLOCK_INPUT;

  return bar;
}

/* Draw BAR's handle in the proper position.
   If the handle is already drawn from START to END, don't bother
   redrawing it, unless REBUILD is non-zero; in that case, always
   redraw it.  (REBUILD is handy for drawing the handle after expose
   events.)

   Normally, we want to constrain the start and end of the handle to
   fit inside its rectangle, but if the user is dragging the scroll bar
   handle, we want to let them drag it down all the way, so that the
   bar's top is as far down as it goes; otherwise, there's no way to
   move to the very end of the buffer.  */
static void
x_scroll_bar_set_handle (bar, start, end, rebuild)
     struct scroll_bar *bar;
     int start, end;
     int rebuild;
{
  int dragging = ! NILP (bar->dragging);
  Window w = SCROLL_BAR_X_WINDOW (bar);
  FRAME_PTR f = XFRAME (WINDOW_FRAME (XWINDOW (bar->window)));
  GC gc = f->output_data.x->normal_gc;

  /* If the display is already accurate, do nothing.  */
  if (! rebuild
      && start == XINT (bar->start)
      && end == XINT (bar->end))
    return;

  BLOCK_INPUT;

  {
    int inside_width = VERTICAL_SCROLL_BAR_INSIDE_WIDTH (f, XINT (bar->width));
    int inside_height = VERTICAL_SCROLL_BAR_INSIDE_HEIGHT (f, XINT (bar->height));
    int top_range = VERTICAL_SCROLL_BAR_TOP_RANGE (f, XINT (bar->height));

    /* Make sure the values are reasonable, and try to preserve
       the distance between start and end.  */
    {
      int length = end - start;

      if (start < 0)
	start = 0;
      else if (start > top_range)
	start = top_range;
      end = start + length;

      if (end < start)
	end = start;
      else if (end > top_range && ! dragging)
	end = top_range;
    }

    /* Store the adjusted setting in the scroll bar.  */
    XSETINT (bar->start, start);
    XSETINT (bar->end, end);

    /* Clip the end position, just for display.  */
    if (end > top_range)
      end = top_range;

    /* Draw bottom positions VERTICAL_SCROLL_BAR_MIN_HANDLE pixels
       below top positions, to make sure the handle is always at least
       that many pixels tall.  */
    end += VERTICAL_SCROLL_BAR_MIN_HANDLE;

    /* Draw the empty space above the handle.  Note that we can't clear
       zero-height areas; that means "clear to end of window."  */
    if (0 < start)
      XClearArea (FRAME_X_DISPLAY (f), w,

		  /* x, y, width, height, and exposures.  */
		  VERTICAL_SCROLL_BAR_LEFT_BORDER,
		  VERTICAL_SCROLL_BAR_TOP_BORDER,
		  inside_width, start,
		  False);

    /* Draw the handle itself.  */
    XFillRectangle (FRAME_X_DISPLAY (f), w, gc,

		    /* x, y, width, height */
		    VERTICAL_SCROLL_BAR_LEFT_BORDER,
		    VERTICAL_SCROLL_BAR_TOP_BORDER + start,
		    inside_width, end - start);


    /* Draw the empty space below the handle.  Note that we can't
       clear zero-height areas; that means "clear to end of window." */
    if (end < inside_height)
      XClearArea (FRAME_X_DISPLAY (f), w,

		  /* x, y, width, height, and exposures.  */
		  VERTICAL_SCROLL_BAR_LEFT_BORDER,
		  VERTICAL_SCROLL_BAR_TOP_BORDER + end,
		  inside_width, inside_height - end,
		  False);

  }

  UNBLOCK_INPUT;
}

/* Move a scroll bar around on the screen, to accommodate changing
   window configurations.  */
static void
x_scroll_bar_move (bar, top, left, width, height)
     struct scroll_bar *bar;
     int top, left, width, height;
{
  Window w = SCROLL_BAR_X_WINDOW (bar);
  FRAME_PTR f = XFRAME (WINDOW_FRAME (XWINDOW (bar->window)));

  BLOCK_INPUT;

  {
    XWindowChanges wc;
    unsigned int mask = 0;

    wc.x = left + VERTICAL_SCROLL_BAR_WIDTH_TRIM;
    wc.y = top;

    wc.width = width - VERTICAL_SCROLL_BAR_WIDTH_TRIM * 2;
    wc.height = height;

    if (left != XINT (bar->left))	mask |= CWX;
    if (top != XINT (bar->top))		mask |= CWY;
    if (width != XINT (bar->width))	mask |= CWWidth;
    if (height != XINT (bar->height))	mask |= CWHeight;

    if (mask)
      XConfigureWindow (FRAME_X_DISPLAY (f), SCROLL_BAR_X_WINDOW (bar),
			mask, &wc);
  }

  XSETINT (bar->left, left);
  XSETINT (bar->top, top);
  XSETINT (bar->width, width);
  XSETINT (bar->height, height);

  UNBLOCK_INPUT;
}

/* Destroy the X window for BAR, and set its Emacs window's scroll bar
   to nil.  */
static void
x_scroll_bar_remove (bar)
     struct scroll_bar *bar;
{
  FRAME_PTR f = XFRAME (WINDOW_FRAME (XWINDOW (bar->window)));

  BLOCK_INPUT;

  /* Destroy the window.  */
  XDestroyWindow (FRAME_X_DISPLAY (f), SCROLL_BAR_X_WINDOW (bar));

  /* Disassociate this scroll bar from its window.  */
  XWINDOW (bar->window)->vertical_scroll_bar = Qnil;

  UNBLOCK_INPUT;
}

/* Set the handle of the vertical scroll bar for WINDOW to indicate
   that we are displaying PORTION characters out of a total of WHOLE
   characters, starting at POSITION.  If WINDOW has no scroll bar,
   create one.  */
static void
XTset_vertical_scroll_bar (window, portion, whole, position)
     struct window *window;
     int portion, whole, position;
{
  FRAME_PTR f = XFRAME (WINDOW_FRAME (window));
  int top = XINT (window->top);
  int left = WINDOW_VERTICAL_SCROLL_BAR_COLUMN (window);
  int height = WINDOW_VERTICAL_SCROLL_BAR_HEIGHT (window);

  /* Where should this scroll bar be, pixelwise?  */
  int pixel_top  = CHAR_TO_PIXEL_ROW (f, top);
  int pixel_left = CHAR_TO_PIXEL_COL (f, left);
  int pixel_width
    = (FRAME_SCROLL_BAR_PIXEL_WIDTH (f) > 0
       ? FRAME_SCROLL_BAR_PIXEL_WIDTH (f)
       : (FRAME_SCROLL_BAR_COLS (f) * FONT_WIDTH (f->output_data.x->font)));
  int pixel_height = VERTICAL_SCROLL_BAR_PIXEL_HEIGHT (f, height);

  struct scroll_bar *bar;

  /* Does the scroll bar exist yet?  */
  if (NILP (window->vertical_scroll_bar))
    bar = x_scroll_bar_create (window,
			      pixel_top, pixel_left,
			      pixel_width, pixel_height);
  else
    {
      /* It may just need to be moved and resized.  */
      bar = XSCROLL_BAR (window->vertical_scroll_bar);
      x_scroll_bar_move (bar, pixel_top, pixel_left, pixel_width, pixel_height);
    }

  /* Set the scroll bar's current state, unless we're currently being
     dragged.  */
  if (NILP (bar->dragging))
    {
      int top_range = VERTICAL_SCROLL_BAR_TOP_RANGE (f, pixel_height);

      if (whole == 0)
	x_scroll_bar_set_handle (bar, 0, top_range, 0);
      else
	{
	  int start = ((double) position * top_range) / whole;
	  int end = ((double) (position + portion) * top_range) / whole;

	  x_scroll_bar_set_handle (bar, start, end, 0);
	}
    }

  XSETVECTOR (window->vertical_scroll_bar, bar);
}


/* The following three hooks are used when we're doing a thorough
   redisplay of the frame.  We don't explicitly know which scroll bars
   are going to be deleted, because keeping track of when windows go
   away is a real pain - "Can you say set-window-configuration, boys
   and girls?"  Instead, we just assert at the beginning of redisplay
   that *all* scroll bars are to be removed, and then save a scroll bar
   from the fiery pit when we actually redisplay its window.  */

/* Arrange for all scroll bars on FRAME to be removed at the next call
   to `*judge_scroll_bars_hook'.  A scroll bar may be spared if
   `*redeem_scroll_bar_hook' is applied to its window before the judgement.  */
static void
XTcondemn_scroll_bars (frame)
     FRAME_PTR frame;
{
  /* Transfer all the scroll bars to FRAME_CONDEMNED_SCROLL_BARS.  */
  while (! NILP (FRAME_SCROLL_BARS (frame)))
    {
      Lisp_Object bar;
      bar = FRAME_SCROLL_BARS (frame);
      FRAME_SCROLL_BARS (frame) = XSCROLL_BAR (bar)->next;
      XSCROLL_BAR (bar)->next = FRAME_CONDEMNED_SCROLL_BARS (frame);
      XSCROLL_BAR (bar)->prev = Qnil;
      if (! NILP (FRAME_CONDEMNED_SCROLL_BARS (frame)))
	XSCROLL_BAR (FRAME_CONDEMNED_SCROLL_BARS (frame))->prev = bar;
      FRAME_CONDEMNED_SCROLL_BARS (frame) = bar;
    }
}

/* Unmark WINDOW's scroll bar for deletion in this judgement cycle.
   Note that WINDOW isn't necessarily condemned at all.  */
static void
XTredeem_scroll_bar (window)
     struct window *window;
{
  struct scroll_bar *bar;

  /* We can't redeem this window's scroll bar if it doesn't have one.  */
  if (NILP (window->vertical_scroll_bar))
    abort ();

  bar = XSCROLL_BAR (window->vertical_scroll_bar);

  /* Unlink it from the condemned list.  */
  {
    FRAME_PTR f = XFRAME (WINDOW_FRAME (window));

    if (NILP (bar->prev))
      {
	/* If the prev pointer is nil, it must be the first in one of
           the lists.  */
	if (EQ (FRAME_SCROLL_BARS (f), window->vertical_scroll_bar))
	  /* It's not condemned.  Everything's fine.  */
	  return;
	else if (EQ (FRAME_CONDEMNED_SCROLL_BARS (f),
		     window->vertical_scroll_bar))
	  FRAME_CONDEMNED_SCROLL_BARS (f) = bar->next;
	else
	  /* If its prev pointer is nil, it must be at the front of
             one or the other!  */
	  abort ();
      }
    else
      XSCROLL_BAR (bar->prev)->next = bar->next;

    if (! NILP (bar->next))
      XSCROLL_BAR (bar->next)->prev = bar->prev;

    bar->next = FRAME_SCROLL_BARS (f);
    bar->prev = Qnil;
    XSETVECTOR (FRAME_SCROLL_BARS (f), bar);
    if (! NILP (bar->next))
      XSETVECTOR (XSCROLL_BAR (bar->next)->prev, bar);
  }
}

/* Remove all scroll bars on FRAME that haven't been saved since the
   last call to `*condemn_scroll_bars_hook'.  */
static void
XTjudge_scroll_bars (f)
     FRAME_PTR f;
{
  Lisp_Object bar, next;

  bar = FRAME_CONDEMNED_SCROLL_BARS (f);

  /* Clear out the condemned list now so we won't try to process any
     more events on the hapless scroll bars.  */
  FRAME_CONDEMNED_SCROLL_BARS (f) = Qnil;

  for (; ! NILP (bar); bar = next)
    {
      struct scroll_bar *b = XSCROLL_BAR (bar);

      x_scroll_bar_remove (b);

      next = b->next;
      b->next = b->prev = Qnil;
    }

  /* Now there should be no references to the condemned scroll bars,
     and they should get garbage-collected.  */
}


/* Handle an Expose or GraphicsExpose event on a scroll bar.

   This may be called from a signal handler, so we have to ignore GC
   mark bits.  */
static void
x_scroll_bar_expose (bar, event)
     struct scroll_bar *bar;
     XEvent *event;
{
  Window w = SCROLL_BAR_X_WINDOW (bar);
  FRAME_PTR f = XFRAME (WINDOW_FRAME (XWINDOW (bar->window)));
  GC gc = f->output_data.x->normal_gc;
  int width_trim = VERTICAL_SCROLL_BAR_WIDTH_TRIM;

  BLOCK_INPUT;

  x_scroll_bar_set_handle (bar, XINT (bar->start), XINT (bar->end), 1);

  /* Draw a one-pixel border just inside the edges of the scroll bar. */
  XDrawRectangle (FRAME_X_DISPLAY (f), w, gc,

		  /* x, y, width, height */
		  0, 0,
		  XINT (bar->width) - 1 - width_trim - width_trim,
		  XINT (bar->height) - 1);
    
  UNBLOCK_INPUT;
}

/* Handle a mouse click on the scroll bar BAR.  If *EMACS_EVENT's kind
   is set to something other than no_event, it is enqueued.

   This may be called from a signal handler, so we have to ignore GC
   mark bits.  */
static void
x_scroll_bar_handle_click (bar, event, emacs_event)
     struct scroll_bar *bar;
     XEvent *event;
     struct input_event *emacs_event;
{
  if (! GC_WINDOWP (bar->window))
    abort ();

  emacs_event->kind = scroll_bar_click;
  emacs_event->code = event->xbutton.button - Button1;
  emacs_event->modifiers
    = (x_x_to_emacs_modifiers (FRAME_X_DISPLAY_INFO 
			       (XFRAME (WINDOW_FRAME (XWINDOW (bar->window)))),
			       event->xbutton.state)
       | (event->type == ButtonRelease
	  ? up_modifier
	  : down_modifier));
  emacs_event->frame_or_window = bar->window;
  emacs_event->timestamp = event->xbutton.time;
  {
    FRAME_PTR f = XFRAME (WINDOW_FRAME (XWINDOW (bar->window)));
    int internal_height
      = VERTICAL_SCROLL_BAR_INSIDE_HEIGHT (f, XINT (bar->height));
    int top_range
      = VERTICAL_SCROLL_BAR_TOP_RANGE (f, XINT (bar->height));
    int y = event->xbutton.y - VERTICAL_SCROLL_BAR_TOP_BORDER;

    if (y < 0) y = 0;
    if (y > top_range) y = top_range;

    if (y < XINT (bar->start))
      emacs_event->part = scroll_bar_above_handle;
    else if (y < XINT (bar->end) + VERTICAL_SCROLL_BAR_MIN_HANDLE)
      emacs_event->part = scroll_bar_handle;
    else
      emacs_event->part = scroll_bar_below_handle;

    /* Just because the user has clicked on the handle doesn't mean
       they want to drag it.  Lisp code needs to be able to decide
       whether or not we're dragging.  */
#if 0
    /* If the user has just clicked on the handle, record where they're
       holding it.  */
    if (event->type == ButtonPress
	&& emacs_event->part == scroll_bar_handle)
      XSETINT (bar->dragging, y - XINT (bar->start));
#endif

    /* If the user has released the handle, set it to its final position.  */
    if (event->type == ButtonRelease
	&& ! NILP (bar->dragging))
      {
	int new_start = y - XINT (bar->dragging);
	int new_end = new_start + (XINT (bar->end) - XINT (bar->start));

	x_scroll_bar_set_handle (bar, new_start, new_end, 0);
	bar->dragging = Qnil;
      }

    /* Same deal here as the other #if 0.  */
#if 0
    /* Clicks on the handle are always reported as occurring at the top of
       the handle.  */
    if (emacs_event->part == scroll_bar_handle)
      emacs_event->x = bar->start;
    else
      XSETINT (emacs_event->x, y);
#else
    XSETINT (emacs_event->x, y);
#endif

    XSETINT (emacs_event->y, top_range);
  }
}

/* Handle some mouse motion while someone is dragging the scroll bar.

   This may be called from a signal handler, so we have to ignore GC
   mark bits.  */
static void
x_scroll_bar_note_movement (bar, event)
     struct scroll_bar *bar;
     XEvent *event;
{
  FRAME_PTR f = XFRAME (XWINDOW (bar->window)->frame);

  last_mouse_movement_time = event->xmotion.time;

  f->mouse_moved = 1;
  XSETVECTOR (last_mouse_scroll_bar, bar);

  /* If we're dragging the bar, display it.  */
  if (! GC_NILP (bar->dragging))
    {
      /* Where should the handle be now?  */
      int new_start = event->xmotion.y - XINT (bar->dragging);

      if (new_start != XINT (bar->start))
	{
	  int new_end = new_start + (XINT (bar->end) - XINT (bar->start));

	  x_scroll_bar_set_handle (bar, new_start, new_end, 0);
	}
    }
}

/* Return information to the user about the current position of the mouse
   on the scroll bar.  */
static void
x_scroll_bar_report_motion (fp, bar_window, part, x, y, time)
     FRAME_PTR *fp;
     Lisp_Object *bar_window;
     enum scroll_bar_part *part;
     Lisp_Object *x, *y;
     unsigned long *time;
{
  struct scroll_bar *bar = XSCROLL_BAR (last_mouse_scroll_bar);
  Window w = SCROLL_BAR_X_WINDOW (bar);
  FRAME_PTR f = XFRAME (WINDOW_FRAME (XWINDOW (bar->window)));
  int win_x, win_y;
  Window dummy_window;
  int dummy_coord;
  unsigned int dummy_mask;

  BLOCK_INPUT;

  /* Get the mouse's position relative to the scroll bar window, and
     report that.  */
  if (! XQueryPointer (FRAME_X_DISPLAY (f), w,

		       /* Root, child, root x and root y.  */
		       &dummy_window, &dummy_window,
		       &dummy_coord, &dummy_coord,

		       /* Position relative to scroll bar.  */
		       &win_x, &win_y,

		       /* Mouse buttons and modifier keys.  */
		       &dummy_mask))
    ;
  else
    {
      int inside_height
	= VERTICAL_SCROLL_BAR_INSIDE_HEIGHT (f, XINT (bar->height));
      int top_range
	= VERTICAL_SCROLL_BAR_TOP_RANGE     (f, XINT (bar->height));

      win_y -= VERTICAL_SCROLL_BAR_TOP_BORDER;

      if (! NILP (bar->dragging))
	win_y -= XINT (bar->dragging);

      if (win_y < 0)
	win_y = 0;
      if (win_y > top_range)
	win_y = top_range;

      *fp = f;
      *bar_window = bar->window;

      if (! NILP (bar->dragging))
	*part = scroll_bar_handle;
      else if (win_y < XINT (bar->start))
	*part = scroll_bar_above_handle;
      else if (win_y < XINT (bar->end) + VERTICAL_SCROLL_BAR_MIN_HANDLE)
	*part = scroll_bar_handle;
      else
	*part = scroll_bar_below_handle;

      XSETINT (*x, win_y);
      XSETINT (*y, top_range);

      f->mouse_moved = 0;
      last_mouse_scroll_bar = Qnil;
    }

  *time = last_mouse_movement_time;

  UNBLOCK_INPUT;
}


/* The screen has been cleared so we may have changed foreground or
   background colors, and the scroll bars may need to be redrawn.
   Clear out the scroll bars, and ask for expose events, so we can
   redraw them.  */

void
x_scroll_bar_clear (f)
     FRAME_PTR f;
{
  Lisp_Object bar;

  /* We can have scroll bars even if this is 0,
     if we just turned off scroll bar mode.
     But in that case we should not clear them.  */
  if (FRAME_HAS_VERTICAL_SCROLL_BARS (f))
    for (bar = FRAME_SCROLL_BARS (f); VECTORP (bar);
	 bar = XSCROLL_BAR (bar)->next)
      XClearArea (FRAME_X_DISPLAY (f), SCROLL_BAR_X_WINDOW (XSCROLL_BAR (bar)),
		  0, 0, 0, 0, True);
}

/* This processes Expose events from the menubar specific X event
   loop in xmenu.c.  This allows to redisplay the frame if necessary
   when handling menubar or popup items.  */

void
process_expose_from_menu (event)
     XEvent event;
{
  FRAME_PTR f;
  struct x_display_info *dpyinfo;

  BLOCK_INPUT;

  dpyinfo = x_display_info_for_display (event.xexpose.display);
  f = x_window_to_frame (dpyinfo, event.xexpose.window);
  if (f)
    {
      if (f->async_visible == 0)
	{
	  f->async_visible = 1;
	  f->async_iconified = 0;
	  f->output_data.x->has_been_visible = 1;
	  SET_FRAME_GARBAGED (f);
	}
      else
	{
	  dumprectangle (x_window_to_frame (dpyinfo, event.xexpose.window),
			 event.xexpose.x, event.xexpose.y,
			 event.xexpose.width, event.xexpose.height);
	}
    }
  else
    {
      struct scroll_bar *bar
	= x_window_to_scroll_bar (event.xexpose.window);

      if (bar)
	x_scroll_bar_expose (bar, &event);
    }

  UNBLOCK_INPUT;
}

/* Define a queue to save up SelectionRequest events for later handling.  */

struct selection_event_queue
  {
    XEvent event;
    struct selection_event_queue *next;
  };

static struct selection_event_queue *queue;

/* Nonzero means queue up certain events--don't process them yet.  */
static int x_queue_selection_requests;

/* Queue up an X event *EVENT, to be processed later.  */

static void
x_queue_event (f, event)
     FRAME_PTR f;
     XEvent *event;
{
  struct selection_event_queue *queue_tmp
    = (struct selection_event_queue *) malloc (sizeof (struct selection_event_queue));

  if (queue_tmp != NULL)
    {
      queue_tmp->event = *event;
      queue_tmp->next = queue;
      queue = queue_tmp;
    }
}

/* Take all the queued events and put them back
   so that they get processed afresh.  */

static void
x_unqueue_events (display)
     Display *display;
{
  while (queue != NULL)
    {
      struct selection_event_queue *queue_tmp = queue;
      XPutBackEvent (display, &queue_tmp->event);
      queue = queue_tmp->next;
      free ((char *)queue_tmp);
    }
}

/* Start queuing SelectionRequest events.  */

void
x_start_queuing_selection_requests (display)
     Display *display;
{
  x_queue_selection_requests++;
}

/* Stop queuing SelectionRequest events.  */

void
x_stop_queuing_selection_requests (display)
     Display *display;
{
  x_queue_selection_requests--;
  x_unqueue_events (display);
}

/* The main X event-reading loop - XTread_socket.  */

/* Timestamp of enter window event.  This is only used by XTread_socket,
   but we have to put it out here, since static variables within functions
   sometimes don't work.  */
static Time enter_timestamp;

/* This holds the state XLookupString needs to implement dead keys
   and other tricks known as "compose processing".  _X Window System_
   says that a portable program can't use this, but Stephen Gildea assures
   me that letting the compiler initialize it to zeros will work okay.

   This must be defined outside of XTread_socket, for the same reasons
   given for enter_timestamp, above.  */
static XComposeStatus compose_status;

/* Record the last 100 characters stored
   to help debug the loss-of-chars-during-GC problem.  */
static int temp_index;
static short temp_buffer[100];

/* Set this to nonzero to fake an "X I/O error"
   on a particular display.  */
struct x_display_info *XTread_socket_fake_io_error;

/* When we find no input here, we occasionally do a no-op command
   to verify that the X server is still running and we can still talk with it.
   We try all the open displays, one by one.
   This variable is used for cycling thru the displays.  */
static struct x_display_info *next_noop_dpyinfo;

#define SET_SAVED_MENU_EVENT(size) { \
  if (f->output_data.x->saved_menu_event == 0) \
    f->output_data.x->saved_menu_event = (XEvent*)xmalloc (sizeof (XEvent)); \
  bcopy (&event, f->output_data.x->saved_menu_event, size); \
  if (numchars >= 1) \
    { \
      bufp->kind = menu_bar_activate_event; \
      XSETFRAME (bufp->frame_or_window, f); \
      bufp++; \
      count++; \
      numchars--; \
    } \
  }
#define SET_SAVED_BUTTON_EVENT SET_SAVED_MENU_EVENT (sizeof (XButtonEvent))
#define SET_SAVED_KEY_EVENT SET_SAVED_MENU_EVENT (sizeof (XKeyEvent))

/* Read events coming from the X server.
   This routine is called by the SIGIO handler.
   We return as soon as there are no more events to be read.

   Events representing keys are stored in buffer BUFP,
   which can hold up to NUMCHARS characters.
   We return the number of characters stored into the buffer,
   thus pretending to be `read'.

   EXPECTED is nonzero if the caller knows input is available.  */

int
XTread_socket (sd, bufp, numchars, expected)
     register int sd;
     /* register */ struct input_event *bufp;
     /* register */ int numchars;
     int expected;
{
  int count = 0;
  int nbytes = 0;
  int mask;
  int items_pending;		/* How many items are in the X queue. */
  XEvent event;
  struct frame *f;
  int event_found = 0;
  int prefix;
  Lisp_Object part;
  struct x_display_info *dpyinfo;
#ifdef HAVE_X_I18N
  Status status_return;
#endif

  if (interrupt_input_blocked)
    {
      interrupt_input_pending = 1;
      return -1;
    }

  interrupt_input_pending = 0;
  BLOCK_INPUT;

  /* So people can tell when we have read the available input.  */
  input_signal_count++;

  if (numchars <= 0)
    abort ();			/* Don't think this happens. */

  /* Find the display we are supposed to read input for.
     It's the one communicating on descriptor SD.  */
  for (dpyinfo = x_display_list; dpyinfo; dpyinfo = dpyinfo->next)
    {
#if 0 /* This ought to be unnecessary; let's verify it.  */
#ifdef FIOSNBIO
      /* If available, Xlib uses FIOSNBIO to make the socket
	 non-blocking, and then looks for EWOULDBLOCK.  If O_NDELAY is set,
	 FIOSNBIO is ignored, and instead of signaling EWOULDBLOCK,
	 a read returns 0, which Xlib interprets as equivalent to EPIPE. */
      fcntl (dpyinfo->connection, F_SETFL, 0);
#endif /* ! defined (FIOSNBIO) */
#endif

#if 0 /* This code can't be made to work, with multiple displays,
	 and appears not to be used on any system any more.
	 Also keyboard.c doesn't turn O_NDELAY on and off
	 for X connections.  */
#ifndef SIGIO
#ifndef HAVE_SELECT
      if (! (fcntl (dpyinfo->connection, F_GETFL, 0) & O_NDELAY))
	{
	  extern int read_alarm_should_throw;
	  read_alarm_should_throw = 1;
	  XPeekEvent (dpyinfo->display, &event);
	  read_alarm_should_throw = 0;
	}
#endif /* HAVE_SELECT */
#endif /* SIGIO */
#endif

      /* For debugging, this gives a way to fake an I/O error.  */
      if (dpyinfo == XTread_socket_fake_io_error)
	{
	  XTread_socket_fake_io_error = 0;
	  x_io_error_quitter (dpyinfo->display);
	}

      while (XPending (dpyinfo->display) != 0)
	{
#ifdef USE_X_TOOLKIT
          /* needed to raise Motif submenus */
	  XtAppNextEvent (Xt_app_con, &event);
#else
	  XNextEvent (dpyinfo->display, &event);
#endif
#ifdef HAVE_X_I18N
	  {
	    struct frame *f1 = x_any_window_to_frame (dpyinfo,
						      event.xclient.window);
	    /* The necessity of the following line took me
	       a full work-day to decipher from the docs!!  */
	    if (f1 != 0 && FRAME_XIC (f1) && XFilterEvent (&event, None))
	      break;
	  }
#endif
	  event_found = 1;

	  switch (event.type)
	    {
	    case ClientMessage:
	      {
		if (event.xclient.message_type
		    == dpyinfo->Xatom_wm_protocols
		    && event.xclient.format == 32)
		  {
		    if (event.xclient.data.l[0]
			== dpyinfo->Xatom_wm_take_focus)
		      {
			/* Use x_any_window_to_frame because this
			   could be the shell widget window
			   if the frame has no title bar.  */
			f = x_any_window_to_frame (dpyinfo, event.xclient.window);
#ifdef HAVE_X_I18N
			/* Not quite sure this is needed -pd */
			if (f && FRAME_XIC (f))
			  XSetICFocus (FRAME_XIC (f));
#endif
			/* Since we set WM_TAKE_FOCUS, we must call
			   XSetInputFocus explicitly.  But not if f is null,
			   since that might be an event for a deleted frame.  */
			if (f)
			  {
			    Display *d = event.xclient.display;
			    /* Catch and ignore errors, in case window has been
			       iconified by a window manager such as GWM.  */
			    int count = x_catch_errors (d);
			    XSetInputFocus (d, event.xclient.window,
					    RevertToPointerRoot,
					    event.xclient.data.l[1]);
			    /* This is needed to detect the error
			       if there is an error.  */
			    XSync (d, False);
			    x_uncatch_errors (d, count);
			  }  
			/* Not certain about handling scroll bars here */
		      }
		    else if (event.xclient.data.l[0]
			     == dpyinfo->Xatom_wm_save_yourself)
		      {
			/* Save state modify the WM_COMMAND property to
			   something which can reinstate us. This notifies
			   the session manager, who's looking for such a
			   PropertyNotify.  Can restart processing when
			   a keyboard or mouse event arrives. */
			if (numchars > 0)
			  {
			    f = x_top_window_to_frame (dpyinfo,
						       event.xclient.window);

			    /* This is just so we only give real data once
			       for a single Emacs process.  */
			    if (f == selected_frame)
			      XSetCommand (FRAME_X_DISPLAY (f),
					   event.xclient.window,
					   initial_argv, initial_argc);
			    else if (f)
			      XSetCommand (FRAME_X_DISPLAY (f),
					   event.xclient.window,
					   0, 0);
			  }
		      }
		    else if (event.xclient.data.l[0]
			     == dpyinfo->Xatom_wm_delete_window)
		      {
			struct frame *f
			  = x_any_window_to_frame (dpyinfo,
						   event.xclient.window);

			if (f)
			  {
			    if (numchars == 0)
			      abort ();

			    bufp->kind = delete_window_event;
			    XSETFRAME (bufp->frame_or_window, f);
			    bufp++;

			    count += 1;
			    numchars -= 1;
			  }
		      }
		  }
		else if (event.xclient.message_type
			 == dpyinfo->Xatom_wm_configure_denied)
		  {
		  }
		else if (event.xclient.message_type
			 == dpyinfo->Xatom_wm_window_moved)
		  {
		    int new_x, new_y;
		    struct frame *f
		      = x_window_to_frame (dpyinfo, event.xclient.window);

		    new_x = event.xclient.data.s[0];
		    new_y = event.xclient.data.s[1];

		    if (f)
		      {
			f->output_data.x->left_pos = new_x;
			f->output_data.x->top_pos = new_y;
		      }
		  }
#ifdef HACK_EDITRES
		else if (event.xclient.message_type
			 == dpyinfo->Xatom_editres)
		  {
		    struct frame *f
		      = x_any_window_to_frame (dpyinfo, event.xclient.window);
		    _XEditResCheckMessages (f->output_data.x->widget, NULL,
					    &event, NULL);
		  }
#endif /* HACK_EDITRES */
	      }
	      break;

	    case SelectionNotify:
#ifdef USE_X_TOOLKIT
	      if (! x_window_to_frame (dpyinfo, event.xselection.requestor))
		goto OTHER;
#endif /* not USE_X_TOOLKIT */
	      x_handle_selection_notify (&event.xselection);
	      break;

	    case SelectionClear:	/* Someone has grabbed ownership. */
#ifdef USE_X_TOOLKIT
	      if (! x_window_to_frame (dpyinfo, event.xselectionclear.window))
		goto OTHER;
#endif /* USE_X_TOOLKIT */
	      {
		XSelectionClearEvent *eventp = (XSelectionClearEvent *) &event;

		if (numchars == 0)
		  abort ();

		bufp->kind = selection_clear_event;
		SELECTION_EVENT_DISPLAY (bufp) = eventp->display;
		SELECTION_EVENT_SELECTION (bufp) = eventp->selection;
		SELECTION_EVENT_TIME (bufp) = eventp->time;
		bufp->frame_or_window = Qnil;
		bufp++;

		count += 1;
		numchars -= 1;
	      }
	      break;

	    case SelectionRequest:	/* Someone wants our selection. */
#ifdef USE_X_TOOLKIT
	      if (!x_window_to_frame (dpyinfo, event.xselectionrequest.owner))
		goto OTHER;
#endif /* USE_X_TOOLKIT */
	      if (x_queue_selection_requests)
		x_queue_event (x_window_to_frame (dpyinfo, event.xselectionrequest.owner),
			       &event);
	      else
		{
		  XSelectionRequestEvent *eventp = (XSelectionRequestEvent *) &event;

		  if (numchars == 0)
		    abort ();

		  bufp->kind = selection_request_event;
		  SELECTION_EVENT_DISPLAY (bufp) = eventp->display;
		  SELECTION_EVENT_REQUESTOR (bufp) = eventp->requestor;
		  SELECTION_EVENT_SELECTION (bufp) = eventp->selection;
		  SELECTION_EVENT_TARGET (bufp) = eventp->target;
		  SELECTION_EVENT_PROPERTY (bufp) = eventp->property;
		  SELECTION_EVENT_TIME (bufp) = eventp->time;
		  bufp->frame_or_window = Qnil;
		  bufp++;

		  count += 1;
		  numchars -= 1;
		}
	      break;

	    case PropertyNotify:
#ifdef USE_X_TOOLKIT
	      if (!x_any_window_to_frame (dpyinfo, event.xproperty.window))
		goto OTHER;
#endif /* not USE_X_TOOLKIT */
	      x_handle_property_notify (&event.xproperty);
	      break;

	    case ReparentNotify:
	      f = x_top_window_to_frame (dpyinfo, event.xreparent.window);
	      if (f)
		{
		  int x, y;
		  f->output_data.x->parent_desc = event.xreparent.parent;
		  x_real_positions (f, &x, &y);
		  f->output_data.x->left_pos = x;
		  f->output_data.x->top_pos = y;
		}
	      break;

	    case Expose:
	      f = x_window_to_frame (dpyinfo, event.xexpose.window);
	      if (f)
		{
		  if (f->async_visible == 0)
		    {
		      f->async_visible = 1;
		      f->async_iconified = 0;
		      f->output_data.x->has_been_visible = 1;
		      SET_FRAME_GARBAGED (f);
		    }
		  else
		    dumprectangle (x_window_to_frame (dpyinfo,
						      event.xexpose.window),
				   event.xexpose.x, event.xexpose.y,
				   event.xexpose.width, event.xexpose.height);
		}
	      else
		{
		  struct scroll_bar *bar
		    = x_window_to_scroll_bar (event.xexpose.window);

		  if (bar)
		    x_scroll_bar_expose (bar, &event);
#ifdef USE_X_TOOLKIT
		  else
		    goto OTHER;
#endif /* USE_X_TOOLKIT */
		}
	      break;

	    case GraphicsExpose:	/* This occurs when an XCopyArea's
				      source area was obscured or not
				      available.*/
	      f = x_window_to_frame (dpyinfo, event.xgraphicsexpose.drawable);
	      if (f)
		{
		  dumprectangle (f,
				 event.xgraphicsexpose.x, event.xgraphicsexpose.y,
				 event.xgraphicsexpose.width,
				 event.xgraphicsexpose.height);
		}
#ifdef USE_X_TOOLKIT
	      else
		goto OTHER;
#endif /* USE_X_TOOLKIT */
	      break;

	    case NoExpose:		/* This occurs when an XCopyArea's
				      source area was completely
				      available */
	      break;

	    case UnmapNotify:
	      f = x_top_window_to_frame (dpyinfo, event.xunmap.window);
	      if (f)		/* F may no longer exist if
				       the frame was deleted.  */
		{
		  /* While a frame is unmapped, display generation is
		     disabled; you don't want to spend time updating a
		     display that won't ever be seen.  */
		  f->async_visible = 0;
		  /* We can't distinguish, from the event, whether the window
		     has become iconified or invisible.  So assume, if it
		     was previously visible, than now it is iconified.
		     But x_make_frame_invisible clears both
		     the visible flag and the iconified flag;
		     and that way, we know the window is not iconified now.  */
		  if (FRAME_VISIBLE_P (f) || FRAME_ICONIFIED_P (f))
		    {
		      f->async_iconified = 1;

		      bufp->kind = iconify_event;
		      XSETFRAME (bufp->frame_or_window, f);
		      bufp++;
		      count++;
		      numchars--;
		    }
		}
	      goto OTHER;

	    case MapNotify:
	      /* We use x_top_window_to_frame because map events can come
		 for subwindows and they don't mean that the frame is visible.  */
	      f = x_top_window_to_frame (dpyinfo, event.xmap.window);
	      if (f)
		{
		  f->async_visible = 1;
		  f->async_iconified = 0;
		  f->output_data.x->has_been_visible = 1;

		  /* wait_reading_process_input will notice this and update
		     the frame's display structures.  */
		  SET_FRAME_GARBAGED (f);

		  if (f->iconified)
		    {
		      bufp->kind = deiconify_event;
		      XSETFRAME (bufp->frame_or_window, f);
		      bufp++;
		      count++;
		      numchars--;
		    }
		  else if (! NILP (Vframe_list)
			   && ! NILP (XCONS (Vframe_list)->cdr))
		    /* Force a redisplay sooner or later
		       to update the frame titles
		       in case this is the second frame.  */
		    record_asynch_buffer_change ();
		}
	      goto OTHER;

	      /* Turn off processing if we become fully obscured. */
	    case VisibilityNotify:
	      break;

	    case KeyPress:
	      f = x_any_window_to_frame (dpyinfo, event.xkey.window);

	      if (f != 0)
		{
		  KeySym keysym, orig_keysym;
		  /* al%imercury@uunet.uu.net says that making this 81 instead of
		     80 fixed a bug whereby meta chars made his Emacs hang.  */
		  unsigned char copy_buffer[81];
		  int modifiers;

#if 0 /* This was how we made f10 work in Motif.
	 The drawback is, you can't type at Emacs when the
	 the mouse is in the menu bar.  So it is better to
	 turn off f10 in Motif and let Emacs handle it.  */
#ifdef USE_MOTIF
                  if (lw_window_is_in_menubar (event.xkey.window,
                                               f->output_data.x->menubar_widget
                                               ))
                    {
                      SET_SAVED_KEY_EVENT;
                      break;
                    }
#endif /* USE_MOTIF */
#endif /* 0 */

		  event.xkey.state
		    |= x_emacs_to_x_modifiers (FRAME_X_DISPLAY_INFO (f),
					       extra_keyboard_modifiers);
		  modifiers = event.xkey.state;

		  /* This will have to go some day...  */

		  /* make_lispy_event turns chars into control chars.
		     Don't do it here because XLookupString is too eager.  */
		  event.xkey.state &= ~ControlMask;
		  event.xkey.state &= ~(dpyinfo->meta_mod_mask
					| dpyinfo->super_mod_mask
					| dpyinfo->hyper_mod_mask
					| dpyinfo->alt_mod_mask);

		  /* In case Meta is ComposeCharacter,
		     clear its status.  According to Markus Ehrnsperger
		     Markus.Ehrnsperger@lehrstuhl-bross.physik.uni-muenchen.de
		     this enables ComposeCharacter to work whether or
		     not it is combined with Meta.  */
		  if (modifiers & dpyinfo->meta_mod_mask)
		    bzero (&compose_status, sizeof (compose_status));

#ifdef HAVE_X_I18N
		  if (FRAME_XIC (f))
		    {
		      /* The necessity of the following line took me
			 a full work-day to decipher from the docs!!  */
		      if (XFilterEvent (&event, None))
			break;
		      nbytes = XmbLookupString (FRAME_XIC (f),
						&event.xkey, copy_buffer,
						80, &keysym,
						&status_return);
		      if (status_return == XLookupNone)
			break;
		      else if (status_return == XLookupChars)
			keysym = NoSymbol;
		      else if (status_return != XLookupKeySym
			       && status_return != XLookupBoth)
			abort ();
		    }
		  else
		    nbytes = XLookupString (&event.xkey, copy_buffer,
					    80, &keysym, &compose_status);
#else
		  nbytes = XLookupString (&event.xkey, copy_buffer,
					  80, &keysym, &compose_status);
#endif

		  orig_keysym = keysym;

		  if (numchars > 1)
		    {
		      if (((keysym >= XK_BackSpace && keysym <= XK_Escape)
			   || keysym == XK_Delete
#ifdef XK_ISO_Left_Tab
			   || (keysym >= XK_ISO_Left_Tab && keysym <= XK_ISO_Enter)
#endif
			   || (keysym >= XK_Kanji && keysym <= XK_Eisu_toggle)
			   || IsCursorKey (keysym) /* 0xff50 <= x < 0xff60 */
			   || IsMiscFunctionKey (keysym) /* 0xff60 <= x < VARIES */
#ifdef HPUX
			   /* This recognizes the "extended function keys".
			      It seems there's no cleaner way.
			      Test IsModifierKey to avoid handling mode_switch
			      incorrectly.  */
			   || ((unsigned) (keysym) >= XK_Select
			       && (unsigned)(keysym) < XK_KP_Space)
#endif
#ifdef XK_dead_circumflex
			   || orig_keysym == XK_dead_circumflex
#endif
#ifdef XK_dead_grave
			   || orig_keysym == XK_dead_grave
#endif
#ifdef XK_dead_tilde
			   || orig_keysym == XK_dead_tilde
#endif
#ifdef XK_dead_diaeresis
			   || orig_keysym == XK_dead_diaeresis
#endif
#ifdef XK_dead_macron
			   || orig_keysym == XK_dead_macron
#endif
#ifdef XK_dead_degree
			   || orig_keysym == XK_dead_degree
#endif
#ifdef XK_dead_acute
			   || orig_keysym == XK_dead_acute
#endif
#ifdef XK_dead_cedilla
			   || orig_keysym == XK_dead_cedilla
#endif
#ifdef XK_dead_breve
			   || orig_keysym == XK_dead_breve
#endif
#ifdef XK_dead_ogonek
			   || orig_keysym == XK_dead_ogonek
#endif
#ifdef XK_dead_caron
			   || orig_keysym == XK_dead_caron
#endif
#ifdef XK_dead_doubleacute
			   || orig_keysym == XK_dead_doubleacute
#endif
#ifdef XK_dead_abovedot
			   || orig_keysym == XK_dead_abovedot
#endif
			   || IsKeypadKey (keysym) /* 0xff80 <= x < 0xffbe */
			   || IsFunctionKey (keysym) /* 0xffbe <= x < 0xffe1 */
			   /* Any "vendor-specific" key is ok.  */
			   || (orig_keysym & (1 << 28)))
			  && ! (IsModifierKey (orig_keysym)
#ifndef HAVE_X11R5
#ifdef XK_Mode_switch
				|| ((unsigned)(orig_keysym) == XK_Mode_switch)
#endif
#ifdef XK_Num_Lock
				|| ((unsigned)(orig_keysym) == XK_Num_Lock)
#endif
#endif /* not HAVE_X11R5 */
				))
			{
			  if (temp_index == sizeof temp_buffer / sizeof (short))
			    temp_index = 0;
			  temp_buffer[temp_index++] = keysym;
			  bufp->kind = non_ascii_keystroke;
			  bufp->code = keysym;
			  XSETFRAME (bufp->frame_or_window, f);
			  bufp->modifiers
			    = x_x_to_emacs_modifiers (FRAME_X_DISPLAY_INFO (f),
						      modifiers);
			  bufp->timestamp = event.xkey.time;
			  bufp++;
			  count++;
			  numchars--;
			}
		      else if (numchars > nbytes)
			{
			  register int i;

			  for (i = 0; i < nbytes; i++)
			    {
			      if (temp_index == sizeof temp_buffer / sizeof (short))
				temp_index = 0;
			      temp_buffer[temp_index++] = copy_buffer[i];
			      bufp->kind = ascii_keystroke;
			      bufp->code = copy_buffer[i];
			      XSETFRAME (bufp->frame_or_window, f);
			      bufp->modifiers
				= x_x_to_emacs_modifiers (FRAME_X_DISPLAY_INFO (f),
							  modifiers);
			      bufp->timestamp = event.xkey.time;
			      bufp++;
			    }

			  count += nbytes;
			  numchars -= nbytes;

			  if (keysym == NoSymbol)
			    break;
			}
		      else
			abort ();
		    }
		  else
		    abort ();
		}
	      goto OTHER;

	      /* Here's a possible interpretation of the whole
		 FocusIn-EnterNotify FocusOut-LeaveNotify mess.  If you get a
		 FocusIn event, you have to get a FocusOut event before you
		 relinquish the focus.  If you haven't received a FocusIn event,
		 then a mere LeaveNotify is enough to free you.  */

	    case EnterNotify:
	      f = x_any_window_to_frame (dpyinfo, event.xcrossing.window);

	      if (event.xcrossing.focus)		/* Entered Window */
		{
		  /* Avoid nasty pop/raise loops. */
		  if (f && (!(f->auto_raise)
			    || !(f->auto_lower)
			    || (event.xcrossing.time - enter_timestamp) > 500))
		    {
		      x_new_focus_frame (dpyinfo, f);
		      enter_timestamp = event.xcrossing.time;
		    }
		}
	      else if (f == dpyinfo->x_focus_frame)
		x_new_focus_frame (dpyinfo, 0);
	      /* EnterNotify counts as mouse movement,
		 so update things that depend on mouse position.  */
	      if (f)
		note_mouse_movement (f, &event.xmotion);
	      goto OTHER;

	    case FocusIn:
	      f = x_any_window_to_frame (dpyinfo, event.xfocus.window);
	      if (event.xfocus.detail != NotifyPointer)
		dpyinfo->x_focus_event_frame = f;
	      if (f)
		x_new_focus_frame (dpyinfo, f);

#ifdef HAVE_X_I18N
	      if (f && FRAME_XIC (f))
		XSetICFocus (FRAME_XIC (f));
#endif

	      goto OTHER;

	    case LeaveNotify:
	      f = x_top_window_to_frame (dpyinfo, event.xcrossing.window);
	      if (f)
		{
		  if (f == dpyinfo->mouse_face_mouse_frame)
		    /* If we move outside the frame,
		       then we're certainly no longer on any text in the frame.  */
		    clear_mouse_face (dpyinfo);

		  if (event.xcrossing.focus)
		    x_mouse_leave (dpyinfo);
		  else
		    {
		      if (f == dpyinfo->x_focus_event_frame)
			dpyinfo->x_focus_event_frame = 0;
		      if (f == dpyinfo->x_focus_frame)
			x_new_focus_frame (dpyinfo, 0);
		    }
		}
	      goto OTHER;

	    case FocusOut:
	      f = x_any_window_to_frame (dpyinfo, event.xfocus.window);
	      if (event.xfocus.detail != NotifyPointer
		  && f == dpyinfo->x_focus_event_frame)
		dpyinfo->x_focus_event_frame = 0;
	      if (f && f == dpyinfo->x_focus_frame)
		x_new_focus_frame (dpyinfo, 0);

#ifdef HAVE_X_I18N
	      if (f && FRAME_XIC (f))
		XUnsetICFocus (FRAME_XIC (f));
#endif

	      goto OTHER;

	    case MotionNotify:
	      {
		if (dpyinfo->grabbed && last_mouse_frame
		    && FRAME_LIVE_P (last_mouse_frame))
		  f = last_mouse_frame;
		else
		  f = x_window_to_frame (dpyinfo, event.xmotion.window);
		if (f)
		  note_mouse_movement (f, &event.xmotion);
		else
		  {
		    struct scroll_bar *bar
		      = x_window_to_scroll_bar (event.xmotion.window);

		    if (bar)
		      x_scroll_bar_note_movement (bar, &event);

		    /* If we move outside the frame,
		       then we're certainly no longer on any text in the frame.  */
		    clear_mouse_face (dpyinfo);
		  }
	      }
	      goto OTHER;

	    case ConfigureNotify:
	      f = x_top_window_to_frame (dpyinfo, event.xconfigure.window);
	      if (f)
		{
		  int rows = PIXEL_TO_CHAR_HEIGHT (f, event.xconfigure.height);
		  int columns = PIXEL_TO_CHAR_WIDTH (f, event.xconfigure.width);
#ifndef USE_X_TOOLKIT
		  /* In the toolkit version, change_frame_size
		     is called by the code that handles resizing
		     of the EmacsFrame widget.  */

		  /* Even if the number of character rows and columns has
		     not changed, the font size may have changed, so we need
		     to check the pixel dimensions as well.  */
		  if (columns != f->width
		      || rows != f->height
		      || event.xconfigure.width != f->output_data.x->pixel_width
		      || event.xconfigure.height != f->output_data.x->pixel_height)
		    {
		      change_frame_size (f, rows, columns, 0, 1);
		      SET_FRAME_GARBAGED (f);
		      cancel_mouse_face (f);
		    }
#endif

		  f->output_data.x->pixel_width = event.xconfigure.width;
		  f->output_data.x->pixel_height = event.xconfigure.height;

		  /* What we have now is the position of Emacs's own window.
		     Convert that to the position of the window manager window.  */
		  x_real_positions (f, &f->output_data.x->left_pos,
				    &f->output_data.x->top_pos);

		  if (f->output_data.x->parent_desc != FRAME_X_DISPLAY_INFO (f)->root_window)
		    {
		      /* Since the WM decorations come below top_pos now,
			 we must put them below top_pos in the future.  */
		      f->output_data.x->win_gravity = NorthWestGravity;
		      x_wm_set_size_hint (f, (long) 0, 0);
		    }
#ifdef USE_MOTIF
		  /* Some window managers pass (0,0) as the location of
		     the window, and the Motif event handler stores it
		     in the emacs widget, which messes up Motif menus.  */
		  if (event.xconfigure.x == 0 && event.xconfigure.y == 0)
		    {
		      event.xconfigure.x = f->output_data.x->widget->core.x;
		      event.xconfigure.y = f->output_data.x->widget->core.y;
		    }
#endif
		  /* If cursor was outside the new size, mark it as off.  */
		  if (f->phys_cursor_y >= rows
		      || f->phys_cursor_x >= columns)
		    {
		      f->phys_cursor_x = 0;
		      f->phys_cursor_y = 0;
		      f->phys_cursor_on = 0;
		    }
		}

	      goto OTHER;

	    case ButtonPress:
	    case ButtonRelease:
	      {
		/* If we decide we want to generate an event to be seen
		   by the rest of Emacs, we put it here.  */
		struct input_event emacs_event;
		emacs_event.kind = no_event;

		bzero (&compose_status, sizeof (compose_status));

		if (dpyinfo->grabbed && last_mouse_frame
		    && FRAME_LIVE_P (last_mouse_frame))
		  f = last_mouse_frame;
		else
		  f = x_window_to_frame (dpyinfo, event.xbutton.window);

		if (f)
		  {
		    if (!dpyinfo->x_focus_frame || f == dpyinfo->x_focus_frame)
		      construct_mouse_click (&emacs_event, &event, f);
		  }
		else
		  {
		    struct scroll_bar *bar
		      = x_window_to_scroll_bar (event.xbutton.window);

		    if (bar)
		      x_scroll_bar_handle_click (bar, &event, &emacs_event);
		  }

		if (event.type == ButtonPress)
		  {
		    dpyinfo->grabbed |= (1 << event.xbutton.button);
		    last_mouse_frame = f;
		    /* Ignore any mouse motion that happened
		       before this event; any subsequent mouse-movement
		       Emacs events should reflect only motion after
		       the ButtonPress.  */
		    if (f != 0)
		      f->mouse_moved = 0;
		  }
		else
		  {
		    dpyinfo->grabbed &= ~(1 << event.xbutton.button);
		  }

		if (numchars >= 1 && emacs_event.kind != no_event)
		  {
		    bcopy (&emacs_event, bufp, sizeof (struct input_event));
		    bufp++;
		    count++;
		    numchars--;
		  }

#ifdef USE_X_TOOLKIT
		f = x_menubar_window_to_frame (dpyinfo, event.xbutton.window);
		/* For a down-event in the menu bar,
		   don't pass it to Xt right now.
		   Instead, save it away
		   and we will pass it to Xt from kbd_buffer_get_event.
		   That way, we can run some Lisp code first.  */
		if (f && event.type == ButtonPress
		    /* Verify the event is really within the menu bar
		       and not just sent to it due to grabbing.  */
		    && event.xbutton.x >= 0
		    && event.xbutton.x < f->output_data.x->pixel_width
		    && event.xbutton.y >= 0
		    && event.xbutton.y < f->output_data.x->menubar_height
		    && event.xbutton.same_screen)
		  {
		    SET_SAVED_BUTTON_EVENT;
		    XSETFRAME (last_mouse_press_frame, f);
		  }
		else if (event.type == ButtonPress)
		  {
		    last_mouse_press_frame = Qnil;
		    goto OTHER;
		  }
#ifdef USE_MOTIF /* This should do not harm for Lucid,
		    but I am trying to be cautious.  */
		else if (event.type == ButtonRelease)
		  {
		    if (!NILP (last_mouse_press_frame))
		      {
			f = XFRAME (last_mouse_press_frame);
			if (f->output_data.x)
			  {
			    SET_SAVED_BUTTON_EVENT;
			  }
		      }
		    else 
		      goto OTHER;
		  }
#endif /* USE_MOTIF */
		else
		  goto OTHER;
#endif /* USE_X_TOOLKIT */
	      }
	      break;

	    case CirculateNotify:
	      break;
	    case CirculateRequest:
	      break;

	    case MappingNotify:
	      /* Someone has changed the keyboard mapping - update the
		 local cache.  */
	      switch (event.xmapping.request)
		{
		case MappingModifier:
		  x_find_modifier_meanings (dpyinfo);
		  /* This is meant to fall through.  */
		case MappingKeyboard:
		  XRefreshKeyboardMapping (&event.xmapping);
		}
	      goto OTHER;

	    default:
	    OTHER:
#ifdef USE_X_TOOLKIT
	      BLOCK_INPUT;
	      XtDispatchEvent (&event);
	      UNBLOCK_INPUT;
#endif /* USE_X_TOOLKIT */
	      break;
	    }
	}
    }

  /* On some systems, an X bug causes Emacs to get no more events
     when the window is destroyed.  Detect that.  (1994.)  */
  if (! event_found)
    {
      /* Emacs and the X Server eats up CPU time if XNoOp is done every time.
	 One XNOOP in 100 loops will make Emacs terminate.
	 B. Bretthauer, 1994 */
      x_noop_count++;
      if (x_noop_count >= 100)
	{
	  x_noop_count=0;

	  if (next_noop_dpyinfo == 0)
	    next_noop_dpyinfo = x_display_list;

	  XNoOp (next_noop_dpyinfo->display);

	  /* Each time we get here, cycle through the displays now open.  */
	  next_noop_dpyinfo = next_noop_dpyinfo->next;
	}
    }

  /* If the focus was just given to an autoraising frame,
     raise it now.  */
  /* ??? This ought to be able to handle more than one such frame.  */
  if (pending_autoraise_frame)
    {
      x_raise_frame (pending_autoraise_frame);
      pending_autoraise_frame = 0;
    }

  UNBLOCK_INPUT;
  return count;
}

/* Drawing the cursor.  */


/* Draw a hollow box cursor on frame F at X, Y.
   Don't change the inside of the box.  */

static void
x_draw_box (f, x, y)
     struct frame *f;
     int x, y;
{
  int left = CHAR_TO_PIXEL_COL (f, x);
  int top  = CHAR_TO_PIXEL_ROW (f, y);
  int width = FONT_WIDTH (f->output_data.x->font);
  int height = f->output_data.x->line_height;
  int c = FAST_GLYPH_CHAR (f->phys_cursor_glyph);
  int charset = CHAR_CHARSET (c);

  XGCValues xgcv;
  unsigned long mask = GCForeground;

  xgcv.foreground = f->output_data.x->cursor_pixel;

  /* cursor_gc's foreground color is typically the same as the normal
     background color, which can cause the cursor box to be invisible.  */
  if (FRAME_X_DISPLAY_INFO (f)->scratch_cursor_gc)
    XChangeGC (FRAME_X_DISPLAY (f),
               FRAME_X_DISPLAY_INFO (f)->scratch_cursor_gc,
               mask, &xgcv);
  else
    FRAME_X_DISPLAY_INFO (f)->scratch_cursor_gc
      = XCreateGC (FRAME_X_DISPLAY (f), FRAME_X_WINDOW (f), mask, &xgcv);

  /* If cursor is on a multi-column character, multiply WIDTH by columns.  */
  width *= (charset == CHARSET_COMPOSITION
	    ? cmpchar_table[COMPOSITE_CHAR_ID (c)]->width
	    : CHARSET_WIDTH (charset));
  XDrawRectangle (FRAME_X_DISPLAY (f), FRAME_X_WINDOW (f),
                  FRAME_X_DISPLAY_INFO (f)->scratch_cursor_gc,
		  left, top, width - 1, height - 1);
}

/* Clear the cursor of frame F to background color,
   and mark the cursor as not shown.
   This is used when the text where the cursor is
   is about to be rewritten.  */

static void
clear_cursor (f)
     struct frame *f;
{
  int mask;

  if (! FRAME_VISIBLE_P (f)
      || ! f->phys_cursor_on)
    return;

  x_update_cursor (f, 0);
  f->phys_cursor_on = 0;
}

/* Redraw the glyph at ROW, COLUMN on frame F, in the style
   HIGHLIGHT.  HIGHLIGHT is as defined for dumpglyphs.  Return the
   glyph drawn.  */

static void
x_draw_single_glyph (f, row, column, glyph, highlight)
     struct frame *f;
     int row, column;
     GLYPH glyph;
     int highlight;
{
  dumpglyphs (f,
	      CHAR_TO_PIXEL_COL (f, column),
	      CHAR_TO_PIXEL_ROW (f, row),
	      &glyph, 1, highlight, 0, NULL);
}

static void
x_display_bar_cursor (f, on, x, y)
     struct frame *f;
     int on;
     int x, y;
{
  struct frame_glyphs *current_glyphs = FRAME_CURRENT_GLYPHS (f);

  /* This is pointless on invisible frames, and dangerous on garbaged
     frames; in the latter case, the frame may be in the midst of
     changing its size, and x and y may be off the frame.  */
  if (! FRAME_VISIBLE_P (f) || FRAME_GARBAGED_P (f))
    return;

  if (! on && ! f->phys_cursor_on)
    return;

  /* If there is anything wrong with the current cursor state, remove it.  */
  if (f->phys_cursor_on
      && (!on
	  || f->phys_cursor_x != x
	  || f->phys_cursor_y != y
	  || f->output_data.x->current_cursor != bar_cursor))
    {
      /* Erase the cursor by redrawing the character underneath it.  */
      x_draw_single_glyph (f, f->phys_cursor_y, f->phys_cursor_x,
			   f->phys_cursor_glyph,
			   current_glyphs->highlight[f->phys_cursor_y]);
      f->phys_cursor_on = 0;
    }

  /* If we now need a cursor in the new place or in the new form, do it so.  */
  if (on
      && (! f->phys_cursor_on
	  || (f->output_data.x->current_cursor != bar_cursor)))
    {
      f->phys_cursor_glyph
	= ((current_glyphs->enable[y]
	    && x < current_glyphs->used[y])
	   ? current_glyphs->glyphs[y][x]
	   : SPACEGLYPH);

      {
	XGCValues xgcv;
	unsigned long mask;

	xgcv.background = f->output_data.x->cursor_pixel;
	xgcv.foreground = f->output_data.x->cursor_pixel;
	xgcv.graphics_exposures = 0;
	mask = GCForeground | GCBackground | GCGraphicsExposures;

	if (FRAME_X_DISPLAY_INFO (f)->scratch_cursor_gc)
	  XChangeGC (FRAME_X_DISPLAY (f),
		     FRAME_X_DISPLAY_INFO (f)->scratch_cursor_gc,
		     mask, &xgcv);
	else
	  FRAME_X_DISPLAY_INFO (f)->scratch_cursor_gc
	    = XCreateGC (FRAME_X_DISPLAY (f), FRAME_X_WINDOW (f), mask, &xgcv);
      }

      XFillRectangle (FRAME_X_DISPLAY (f), FRAME_X_WINDOW (f),
		      FRAME_X_DISPLAY_INFO (f)->scratch_cursor_gc,
		      CHAR_TO_PIXEL_COL (f, x),
		      CHAR_TO_PIXEL_ROW (f, y),
		      max (f->output_data.x->cursor_width, 1),
		      f->output_data.x->line_height);

      f->phys_cursor_x = x;
      f->phys_cursor_y = y;
      f->phys_cursor_on = 1;

      f->output_data.x->current_cursor = bar_cursor;
    }

  if (updating_frame != f)
    XFlush (FRAME_X_DISPLAY (f));
}


/* Turn the displayed cursor of frame F on or off according to ON.
   If ON is nonzero, where to put the cursor is specified by X and Y.  */

static void
x_display_box_cursor (f, on, x, y)
     struct frame *f;
     int on;
     int x, y;
{
  struct frame_glyphs *current_glyphs = FRAME_CURRENT_GLYPHS (f);

  /* This is pointless on invisible frames, and dangerous on garbaged
     frames; in the latter case, the frame may be in the midst of
     changing its size, and x and y may be off the frame.  */
  if (! FRAME_VISIBLE_P (f) || FRAME_GARBAGED_P (f))
    return;

  /* If cursor is off and we want it off, return quickly.  */
  if (!on && ! f->phys_cursor_on)
    return;

  /* If cursor is currently being shown and we don't want it to be
     or it is in the wrong place,
     or we want a hollow box and it's not so, (pout!)
     erase it.  */
  if (f->phys_cursor_on
      && (!on
	  || f->phys_cursor_x != x
	  || f->phys_cursor_y != y
	  || (f->output_data.x->current_cursor != hollow_box_cursor
	      && (f != FRAME_X_DISPLAY_INFO (f)->x_highlight_frame))))
    {
      int mouse_face_here = 0;
      struct frame_glyphs *active_glyphs = FRAME_CURRENT_GLYPHS (f);

      /* If the cursor is in the mouse face area, redisplay that when
	 we clear the cursor.  */
      if (f == FRAME_X_DISPLAY_INFO (f)->mouse_face_mouse_frame
	  &&
	  (f->phys_cursor_y > FRAME_X_DISPLAY_INFO (f)->mouse_face_beg_row
	   || (f->phys_cursor_y == FRAME_X_DISPLAY_INFO (f)->mouse_face_beg_row
	       && f->phys_cursor_x >= FRAME_X_DISPLAY_INFO (f)->mouse_face_beg_col))
	  &&
	  (f->phys_cursor_y < FRAME_X_DISPLAY_INFO (f)->mouse_face_end_row
	   || (f->phys_cursor_y == FRAME_X_DISPLAY_INFO (f)->mouse_face_end_row
	       && f->phys_cursor_x < FRAME_X_DISPLAY_INFO (f)->mouse_face_end_col))
	  /* Don't redraw the cursor's spot in mouse face
	     if it is at the end of a line (on a newline).
	     The cursor appears there, but mouse highlighting does not.  */
	  && active_glyphs->used[f->phys_cursor_y] > f->phys_cursor_x)
	mouse_face_here = 1;

      /* If the font is not as tall as a whole line,
	 we must explicitly clear the line's whole height.  */
      if (FONT_HEIGHT (f->output_data.x->font) != f->output_data.x->line_height)
	XClearArea (FRAME_X_DISPLAY (f), FRAME_X_WINDOW (f),
		    CHAR_TO_PIXEL_COL (f, f->phys_cursor_x),
		    CHAR_TO_PIXEL_ROW (f, f->phys_cursor_y),
		    FONT_WIDTH (f->output_data.x->font),
		    f->output_data.x->line_height, False);
      /* Erase the cursor by redrawing the character underneath it.  */
      x_draw_single_glyph (f, f->phys_cursor_y, f->phys_cursor_x,
			   f->phys_cursor_glyph,
			   (mouse_face_here
			    ? 3
			    : current_glyphs->highlight[f->phys_cursor_y]));
      f->phys_cursor_on = 0;
    }

  /* If we want to show a cursor,
     or we want a box cursor and it's not so,
     write it in the right place.  */
  if (on
      && (! f->phys_cursor_on
	  || (f->output_data.x->current_cursor != filled_box_cursor
	      && f == FRAME_X_DISPLAY_INFO (f)->x_highlight_frame)))
    {
      f->phys_cursor_glyph
	= ((current_glyphs->enable[y]
	    && x < current_glyphs->used[y])
	   ? current_glyphs->glyphs[y][x]
	   : SPACEGLYPH);
      if (f != FRAME_X_DISPLAY_INFO (f)->x_highlight_frame)
	{
	  x_draw_box (f, x, y);
	  f->output_data.x->current_cursor = hollow_box_cursor;
	}
      else
	{
	  x_draw_single_glyph (f, y, x,
			       f->phys_cursor_glyph, 2);
	  f->output_data.x->current_cursor = filled_box_cursor;
	}

      f->phys_cursor_x = x;
      f->phys_cursor_y = y;
      f->phys_cursor_on = 1;
    }

  if (updating_frame != f)
    XFlush (FRAME_X_DISPLAY (f));
}

/* Display the cursor on frame F, or clear it, according to ON.
   Also set the frame's cursor position to X and Y.  */

void
x_display_cursor (f, on, x, y)
     struct frame *f;
     int on;
     int x, y;
{
  BLOCK_INPUT;

 if ((unsigned) x >= FRAME_CURSOR_X_LIMIT (f)
      || (unsigned) y >= FRAME_HEIGHT (f))
    abort ();

  if (FRAME_DESIRED_CURSOR (f) == filled_box_cursor)
    x_display_box_cursor (f, on, x, y);
  else if (FRAME_DESIRED_CURSOR (f) == bar_cursor)
    x_display_bar_cursor (f, on, x, y);
  else
    /* Those are the only two we have implemented!  */
    abort ();

  UNBLOCK_INPUT;
}

/* Display the cursor on frame F, or clear it, according to ON.
   Don't change the cursor's position.  */

void
x_update_cursor (f, on)
     struct frame *f;
     int on;
{
  BLOCK_INPUT;

  if (FRAME_DESIRED_CURSOR (f) == filled_box_cursor)
    x_display_box_cursor (f, on, f->phys_cursor_x, f->phys_cursor_y);
  else if (FRAME_DESIRED_CURSOR (f) == bar_cursor)
    x_display_bar_cursor (f, on, f->phys_cursor_x, f->phys_cursor_y);
  else
    /* Those are the only two we have implemented!  */
    abort ();

  UNBLOCK_INPUT;
}

/* Icons.  */

/* Refresh bitmap kitchen sink icon for frame F
   when we get an expose event for it. */

void
refreshicon (f)
     struct frame *f;
{
  /* Normally, the window manager handles this function. */
}

/* Make the x-window of frame F use the gnu icon bitmap.  */

int
x_bitmap_icon (f, file)
     struct frame *f;
     Lisp_Object file;
{
  int mask, bitmap_id;
  Window icon_window;

  if (FRAME_X_WINDOW (f) == 0)
    return 1;

  /* Free up our existing icon bitmap if any.  */
  if (f->output_data.x->icon_bitmap > 0)
    x_destroy_bitmap (f, f->output_data.x->icon_bitmap);
  f->output_data.x->icon_bitmap = 0;

  if (STRINGP (file))
    bitmap_id = x_create_bitmap_from_file (f, file);
  else
    {
      /* Create the GNU bitmap if necessary.  */
      if (FRAME_X_DISPLAY_INFO (f)->icon_bitmap_id < 0)
	FRAME_X_DISPLAY_INFO (f)->icon_bitmap_id
	  = x_create_bitmap_from_data (f, gnu_bits,
				       gnu_width, gnu_height);

      /* The first time we create the GNU bitmap,
	 this increments the refcount one extra time.
	 As a result, the GNU bitmap is never freed.
	 That way, we don't have to worry about allocating it again.  */
      x_reference_bitmap (f, FRAME_X_DISPLAY_INFO (f)->icon_bitmap_id);

      bitmap_id = FRAME_X_DISPLAY_INFO (f)->icon_bitmap_id;
    }

  x_wm_set_icon_pixmap (f, bitmap_id);
  f->output_data.x->icon_bitmap = bitmap_id;

  return 0;
}


/* Make the x-window of frame F use a rectangle with text.
   Use ICON_NAME as the text.  */

int
x_text_icon (f, icon_name)
     struct frame *f;
     char *icon_name;
{
  if (FRAME_X_WINDOW (f) == 0)
    return 1;

#ifdef HAVE_X11R4
  {
    XTextProperty text;
    text.value = (unsigned char *) icon_name;
    text.encoding = XA_STRING;
    text.format = 8;
    text.nitems = strlen (icon_name);
#ifdef USE_X_TOOLKIT
    XSetWMIconName (FRAME_X_DISPLAY (f), XtWindow (f->output_data.x->widget),
		    &text);
#else /* not USE_X_TOOLKIT */
    XSetWMIconName (FRAME_X_DISPLAY (f), FRAME_X_WINDOW (f), &text);
#endif /* not USE_X_TOOLKIT */
  }
#else /* not HAVE_X11R4 */
  XSetIconName (FRAME_X_DISPLAY (f), FRAME_X_WINDOW (f), icon_name);
#endif /* not HAVE_X11R4 */

  if (f->output_data.x->icon_bitmap > 0)
    x_destroy_bitmap (f, f->output_data.x->icon_bitmap);
  f->output_data.x->icon_bitmap = 0;
  x_wm_set_icon_pixmap (f, 0);

  return 0;
}

#define X_ERROR_MESSAGE_SIZE 200

/* If non-nil, this should be a string.
   It means catch X errors  and store the error message in this string.  */

static Lisp_Object x_error_message_string;

/* An X error handler which stores the error message in
   x_error_message_string.  This is called from x_error_handler if
   x_catch_errors is in effect.  */

static int
x_error_catcher (display, error)
     Display *display;
     XErrorEvent *error;
{
  XGetErrorText (display, error->error_code,
		 XSTRING (x_error_message_string)->data,
		 X_ERROR_MESSAGE_SIZE);
}

/* Begin trapping X errors for display DPY.  Actually we trap X errors
   for all displays, but DPY should be the display you are actually
   operating on.

   After calling this function, X protocol errors no longer cause
   Emacs to exit; instead, they are recorded in the string
   stored in x_error_message_string.

   Calling x_check_errors signals an Emacs error if an X error has
   occurred since the last call to x_catch_errors or x_check_errors.

   Calling x_uncatch_errors resumes the normal error handling.  */

void x_check_errors ();
static Lisp_Object x_catch_errors_unwind ();

int
x_catch_errors (dpy)
     Display *dpy;
{
  int count = specpdl_ptr - specpdl;

  /* Make sure any errors from previous requests have been dealt with.  */
  XSync (dpy, False);

  record_unwind_protect (x_catch_errors_unwind, x_error_message_string);

  x_error_message_string = make_uninit_string (X_ERROR_MESSAGE_SIZE);
  XSTRING (x_error_message_string)->data[0] = 0;

  return count;
}

/* Unbind the binding that we made to check for X errors.  */

static Lisp_Object
x_catch_errors_unwind (old_val)
     Lisp_Object old_val;
{
  x_error_message_string = old_val;
  return Qnil;
}

/* If any X protocol errors have arrived since the last call to
   x_catch_errors or x_check_errors, signal an Emacs error using
   sprintf (a buffer, FORMAT, the x error message text) as the text.  */

void
x_check_errors (dpy, format)
     Display *dpy;
     char *format;
{
  /* Make sure to catch any errors incurred so far.  */
  XSync (dpy, False);

  if (XSTRING (x_error_message_string)->data[0])
    error (format, XSTRING (x_error_message_string)->data);
}

/* Nonzero if we had any X protocol errors
   since we did x_catch_errors on DPY.  */

int
x_had_errors_p (dpy)
     Display *dpy;
{
  /* Make sure to catch any errors incurred so far.  */
  XSync (dpy, False);

  return XSTRING (x_error_message_string)->data[0] != 0;
}

/* Forget about any errors we have had, since we did x_catch_errors on DPY.  */

int
x_clear_errors (dpy)
     Display *dpy;
{
  XSTRING (x_error_message_string)->data[0] = 0;
}

/* Stop catching X protocol errors and let them make Emacs die.
   DPY should be the display that was passed to x_catch_errors.
   COUNT should be the value that was returned by
   the corresponding call to x_catch_errors.  */

void
x_uncatch_errors (dpy, count)
     Display *dpy;
     int count;
{
  unbind_to (count, Qnil);
}

#if 0
static unsigned int x_wire_count;
x_trace_wire ()
{
  fprintf (stderr, "Lib call: %d\n", ++x_wire_count);
}
#endif /* ! 0 */


/* Handle SIGPIPE, which can happen when the connection to a server
   simply goes away.  SIGPIPE is handled by x_connection_signal.
   Don't need to do anything, because the write which caused the 
   SIGPIPE will fail, causing Xlib to invoke the X IO error handler,
   which will do the appropriate cleanup for us. */
   
static SIGTYPE
x_connection_signal (signalnum)	/* If we don't have an argument, */
     int signalnum;		/* some compilers complain in signal calls. */
{
#ifdef USG
  /* USG systems forget handlers when they are used;
     must reestablish each time */
  signal (signalnum, x_connection_signal);
#endif /* USG */
}

/* Handling X errors.  */

/* Handle the loss of connection to display DISPLAY.  */

static SIGTYPE
x_connection_closed (display, error_message)
     Display *display;
     char *error_message;
{
  struct x_display_info *dpyinfo = x_display_info_for_display (display);
  Lisp_Object frame, tail;

  /* Indicate that this display is dead.  */

#ifdef USE_X_TOOLKIT
  XtCloseDisplay (display);
#endif

  dpyinfo->display = 0;

  /* First delete frames whose minibuffers are on frames
     that are on the dead display.  */
  FOR_EACH_FRAME (tail, frame)
    {
      Lisp_Object minibuf_frame;
      minibuf_frame
	= WINDOW_FRAME (XWINDOW (FRAME_MINIBUF_WINDOW (XFRAME (frame))));
      if (FRAME_X_P (XFRAME (frame))
	  && FRAME_X_P (XFRAME (minibuf_frame))
	  && ! EQ (frame, minibuf_frame)
	  && FRAME_X_DISPLAY_INFO (XFRAME (minibuf_frame)) == dpyinfo)
	Fdelete_frame (frame, Qt);
    }

  /* Now delete all remaining frames on the dead display.
     We are now sure none of these is used as the minibuffer
     for another frame that we need to delete.  */
  FOR_EACH_FRAME (tail, frame)
    if (FRAME_X_P (XFRAME (frame))
	&& FRAME_X_DISPLAY_INFO (XFRAME (frame)) == dpyinfo)
      {
	/* Set this to t so that Fdelete_frame won't get confused
	   trying to find a replacement.  */
	FRAME_KBOARD (XFRAME (frame))->Vdefault_minibuffer_frame = Qt;
	Fdelete_frame (frame, Qt);
      }

  if (dpyinfo)
    x_delete_display (dpyinfo);

  if (x_display_list == 0)
    {
      fprintf (stderr, "%s\n", error_message);
      shut_down_emacs (0, 0, Qnil);
      exit (70);
    }

  /* Ordinary stack unwind doesn't deal with these.  */
#ifdef SIGIO
  sigunblock (sigmask (SIGIO));
#endif
  sigunblock (sigmask (SIGALRM));
  TOTALLY_UNBLOCK_INPUT;

  clear_waiting_for_input ();
  error ("%s", error_message);
}

/* This is the usual handler for X protocol errors.
   It kills all frames on the display that we got the error for.
   If that was the only one, it prints an error message and kills Emacs.  */

static int
x_error_quitter (display, error)
     Display *display;
     XErrorEvent *error;
{
  char buf[256], buf1[356];

  /* Note that there is no real way portable across R3/R4 to get the
     original error handler.  */

  XGetErrorText (display, error->error_code, buf, sizeof (buf));
  sprintf (buf1, "X protocol error: %s on protocol request %d",
	   buf, error->request_code);
  x_connection_closed (display, buf1);
}

/* This is the first-level handler for X protocol errors.
   It calls x_error_quitter or x_error_catcher.  */

static int
x_error_handler (display, error)
     Display *display;
     XErrorEvent *error;
{
  char buf[256], buf1[356];

  if (! NILP (x_error_message_string))
    x_error_catcher (display, error);
  else
    x_error_quitter (display, error);
}

/* This is the handler for X IO errors, always.
   It kills all frames on the display that we lost touch with.
   If that was the only one, it prints an error message and kills Emacs.  */

static int
x_io_error_quitter (display)
     Display *display;
{
  char buf[256];

  sprintf (buf, "Connection lost to X server `%s'", DisplayString (display));
  x_connection_closed (display, buf);
}

/* Changing the font of the frame.  */

/* Give frame F the font named FONTNAME as its default font, and
   return the full name of that font.  FONTNAME may be a wildcard
   pattern; in that case, we choose some font that fits the pattern.
   The return value shows which font we chose.  */

Lisp_Object
x_new_font (f, fontname)
     struct frame *f;
     register char *fontname;
{
  struct font_info *fontp
    = fs_load_font (f, FRAME_X_FONT_TABLE (f), CHARSET_ASCII, fontname, -1);

  if (!fontp)
    return Qnil;

  f->output_data.x->font = (XFontStruct *) (fontp->font);
  f->output_data.x->font_baseline
    = (f->output_data.x->font->ascent + fontp->baseline_offset);
  f->output_data.x->fontset = -1;
  
  /* Compute the scroll bar width in character columns.  */
  if (f->scroll_bar_pixel_width > 0)
    {
      int wid = FONT_WIDTH (f->output_data.x->font);
      f->scroll_bar_cols = (f->scroll_bar_pixel_width + wid-1) / wid;
    }
  else
    {
      int wid = FONT_WIDTH (f->output_data.x->font);
      f->scroll_bar_cols = (14 + wid - 1) / wid;
    }

  /* Now make the frame display the given font.  */
  if (FRAME_X_WINDOW (f) != 0)
    {
      XSetFont (FRAME_X_DISPLAY (f), f->output_data.x->normal_gc,
		f->output_data.x->font->fid);
      XSetFont (FRAME_X_DISPLAY (f), f->output_data.x->reverse_gc,
		f->output_data.x->font->fid);
      XSetFont (FRAME_X_DISPLAY (f), f->output_data.x->cursor_gc,
		f->output_data.x->font->fid);

      frame_update_line_height (f);
      x_set_window_size (f, 0, f->width, f->height);
    }
  else
    /* If we are setting a new frame's font for the first time,
       there are no faces yet, so this font's height is the line height.  */
    f->output_data.x->line_height = FONT_HEIGHT (f->output_data.x->font);

  return build_string (fontp->full_name);
}

/* Give frame F the fontset named FONTSETNAME as its default font, and
   return the full name of that fontset.  FONTSETNAME may be a wildcard
   pattern; in that case, we choose some fontset that fits the pattern.
   The return value shows which fontset we chose.  */

Lisp_Object
x_new_fontset (f, fontsetname)
     struct frame *f;
     char *fontsetname;
{
  int fontset = fs_query_fontset (f, fontsetname);
  struct fontset_info *fontsetp;
  Lisp_Object result;

  if (fontset < 0)
    return Qnil;

  if (f->output_data.x->fontset == fontset)
    /* This fontset is already set in frame F.  There's nothing more
       to do.  */
    return build_string (fontsetname);

  fontsetp = FRAME_FONTSET_DATA (f)->fontset_table[fontset];

  if (!fontsetp->fontname[CHARSET_ASCII])
    /* This fontset doesn't contain ASCII font.  */
    return Qnil;

  result = x_new_font (f, fontsetp->fontname[CHARSET_ASCII]);

  if (!STRINGP (result))
    /* Can't load ASCII font.  */
    return Qnil;

  /* Since x_new_font doesn't update any fontset information, do it now.  */
  f->output_data.x->fontset = fontset;
  FS_LOAD_FONT (f, FRAME_X_FONT_TABLE (f),
		CHARSET_ASCII, fontsetp->fontname[CHARSET_ASCII], fontset);

  return build_string (fontsetname);
}

/* Calculate the absolute position in frame F
   from its current recorded position values and gravity.  */

void
x_calc_absolute_position (f)
     struct frame *f;
{
  Window win, child;
  int win_x = 0, win_y = 0;
  int flags = f->output_data.x->size_hint_flags;
  int this_window;

  /* We have nothing to do if the current position
     is already for the top-left corner.  */
  if (! ((flags & XNegative) || (flags & YNegative)))
    return;

#ifdef USE_X_TOOLKIT
  this_window = XtWindow (f->output_data.x->widget);
#else
  this_window = FRAME_X_WINDOW (f);
#endif

  /* Find the position of the outside upper-left corner of
     the inner window, with respect to the outer window.
     But do this only if we will need the results.  */
  if (f->output_data.x->parent_desc != FRAME_X_DISPLAY_INFO (f)->root_window)
    {
      int count;

      BLOCK_INPUT;
      count = x_catch_errors (FRAME_X_DISPLAY (f));
      while (1)
	{
	  x_clear_errors (FRAME_X_DISPLAY (f));
	  XTranslateCoordinates (FRAME_X_DISPLAY (f),

				 /* From-window, to-window.  */
				 this_window,
				 f->output_data.x->parent_desc,

				 /* From-position, to-position.  */
				 0, 0, &win_x, &win_y,

				 /* Child of win.  */
				 &child);
	  if (x_had_errors_p (FRAME_X_DISPLAY (f)))
	    {
	      Window newroot, newparent = 0xdeadbeef;
	      Window *newchildren;
	      int nchildren;

	      if (! XQueryTree (FRAME_X_DISPLAY (f), this_window, &newroot,
				&newparent, &newchildren, &nchildren))
		break;

	      XFree ((char *) newchildren);

	      f->output_data.x->parent_desc = newparent;
	    }
	  else
	    break;
	}

      x_uncatch_errors (FRAME_X_DISPLAY (f), count);
      UNBLOCK_INPUT;
    }

  /* Treat negative positions as relative to the leftmost bottommost
     position that fits on the screen.  */
  if (flags & XNegative)
    f->output_data.x->left_pos = (FRAME_X_DISPLAY_INFO (f)->width
				  - 2 * f->output_data.x->border_width - win_x
				  - PIXEL_WIDTH (f)
				  + f->output_data.x->left_pos);

  if (flags & YNegative)
    /* We used to subtract f->output_data.x->menubar_height here
       in the toolkit case, but PIXEL_HEIGHT already includes that.  */
    f->output_data.x->top_pos = (FRAME_X_DISPLAY_INFO (f)->height
				 - 2 * f->output_data.x->border_width - win_y
				 - PIXEL_HEIGHT (f)
				 + f->output_data.x->top_pos);

  /* The left_pos and top_pos
     are now relative to the top and left screen edges,
     so the flags should correspond.  */
  f->output_data.x->size_hint_flags &= ~ (XNegative | YNegative);
}

/* CHANGE_GRAVITY is 1 when calling from Fset_frame_position,
   to really change the position, and 0 when calling from
   x_make_frame_visible (in that case, XOFF and YOFF are the current
   position values).  It is -1 when calling from x_set_frame_parameters,
   which means, do adjust for borders but don't change the gravity.  */

void
x_set_offset (f, xoff, yoff, change_gravity)
     struct frame *f;
     register int xoff, yoff;
     int change_gravity;
{
  int modified_top, modified_left;

  if (change_gravity > 0)
    {
      f->output_data.x->top_pos = yoff;
      f->output_data.x->left_pos = xoff;
      f->output_data.x->size_hint_flags &= ~ (XNegative | YNegative);
      if (xoff < 0)
	f->output_data.x->size_hint_flags |= XNegative;
      if (yoff < 0)
	f->output_data.x->size_hint_flags |= YNegative;
      f->output_data.x->win_gravity = NorthWestGravity;
    }
  x_calc_absolute_position (f);

  BLOCK_INPUT;
  x_wm_set_size_hint (f, (long) 0, 0);

  modified_left = f->output_data.x->left_pos;
  modified_top = f->output_data.x->top_pos;
#if 0 /* Running on psilocin (Debian), and displaying on the NCD X-terminal,
	 this seems to be unnecessary and incorrect.  rms, 4/17/97.  */
  /* It is a mystery why we need to add the border_width here
     when the frame is already visible, but experiment says we do.  */
  if (change_gravity != 0)
    {
      modified_left += f->output_data.x->border_width;
      modified_top += f->output_data.x->border_width;
    }
#endif

#ifdef USE_X_TOOLKIT
  XMoveWindow (FRAME_X_DISPLAY (f), XtWindow (f->output_data.x->widget),
	       modified_left, modified_top);
#else /* not USE_X_TOOLKIT */
  XMoveWindow (FRAME_X_DISPLAY (f), FRAME_X_WINDOW (f),
	       modified_left, modified_top);
#endif /* not USE_X_TOOLKIT */
  UNBLOCK_INPUT;
}

/* Call this to change the size of frame F's x-window.
   If CHANGE_GRAVITY is 1, we change to top-left-corner window gravity
   for this size change and subsequent size changes.
   Otherwise we leave the window gravity unchanged.  */

void
x_set_window_size (f, change_gravity, cols, rows)
     struct frame *f;
     int change_gravity;
     int cols, rows;
{
  int pixelwidth, pixelheight;
  int mask;
  struct x_display_info *dpyinfo = FRAME_X_DISPLAY_INFO (f);

  BLOCK_INPUT;

#ifdef USE_X_TOOLKIT
  {
    /* The x and y position of the widget is clobbered by the
       call to XtSetValues within EmacsFrameSetCharSize.
       This is a real kludge, but I don't understand Xt so I can't
       figure out a correct fix.  Can anyone else tell me? -- rms.  */
    int xpos = f->output_data.x->widget->core.x;
    int ypos = f->output_data.x->widget->core.y;
    EmacsFrameSetCharSize (f->output_data.x->edit_widget, cols, rows);
    f->output_data.x->widget->core.x = xpos;
    f->output_data.x->widget->core.y = ypos;
  }

#else /* not USE_X_TOOLKIT */

  check_frame_size (f, &rows, &cols);
  f->output_data.x->vertical_scroll_bar_extra
    = (!FRAME_HAS_VERTICAL_SCROLL_BARS (f)
       ? 0
       : FRAME_SCROLL_BAR_PIXEL_WIDTH (f) > 0
       ? FRAME_SCROLL_BAR_PIXEL_WIDTH (f)
       : (FRAME_SCROLL_BAR_COLS (f) * FONT_WIDTH (f->output_data.x->font)));
  pixelwidth = CHAR_TO_PIXEL_WIDTH (f, cols);
  pixelheight = CHAR_TO_PIXEL_HEIGHT (f, rows);

  f->output_data.x->win_gravity = NorthWestGravity;
  x_wm_set_size_hint (f, (long) 0, 0);

  XSync (FRAME_X_DISPLAY (f), False);
  XResizeWindow (FRAME_X_DISPLAY (f), FRAME_X_WINDOW (f),
		 pixelwidth, pixelheight);

  /* Now, strictly speaking, we can't be sure that this is accurate,
     but the window manager will get around to dealing with the size
     change request eventually, and we'll hear how it went when the
     ConfigureNotify event gets here.

     We could just not bother storing any of this information here,
     and let the ConfigureNotify event set everything up, but that
     might be kind of confusing to the lisp code, since size changes
     wouldn't be reported in the frame parameters until some random
     point in the future when the ConfigureNotify event arrives.  */
  change_frame_size (f, rows, cols, 0, 0);
  PIXEL_WIDTH (f) = pixelwidth;
  PIXEL_HEIGHT (f) = pixelheight;

  /* We've set {FRAME,PIXEL}_{WIDTH,HEIGHT} to the values we hope to
     receive in the ConfigureNotify event; if we get what we asked
     for, then the event won't cause the screen to become garbaged, so
     we have to make sure to do it here.  */
  SET_FRAME_GARBAGED (f);

  XFlush (FRAME_X_DISPLAY (f));

#endif /* not USE_X_TOOLKIT */

  /* If cursor was outside the new size, mark it as off.  */
  if (f->phys_cursor_y >= rows
      || f->phys_cursor_x >= cols)
    {
      f->phys_cursor_x = 0;
      f->phys_cursor_y = 0;
      f->phys_cursor_on = 0;
    }

  /* Clear out any recollection of where the mouse highlighting was,
     since it might be in a place that's outside the new frame size. 
     Actually checking whether it is outside is a pain in the neck,
     so don't try--just let the highlighting be done afresh with new size.  */
  cancel_mouse_face (f);

  UNBLOCK_INPUT;
}

/* Mouse warping.  */

void
x_set_mouse_position (f, x, y)
     struct frame *f;
     int x, y;
{
  int pix_x, pix_y;

  pix_x = CHAR_TO_PIXEL_COL (f, x) + FONT_WIDTH  (f->output_data.x->font) / 2;
  pix_y = CHAR_TO_PIXEL_ROW (f, y) + f->output_data.x->line_height / 2;

  if (pix_x < 0) pix_x = 0;
  if (pix_x > PIXEL_WIDTH (f)) pix_x = PIXEL_WIDTH (f);

  if (pix_y < 0) pix_y = 0;
  if (pix_y > PIXEL_HEIGHT (f)) pix_y = PIXEL_HEIGHT (f);

  BLOCK_INPUT;

  XWarpPointer (FRAME_X_DISPLAY (f), None, FRAME_X_WINDOW (f),
		0, 0, 0, 0, pix_x, pix_y);
  UNBLOCK_INPUT;
}

/* Move the mouse to position pixel PIX_X, PIX_Y relative to frame F.  */

void
x_set_mouse_pixel_position (f, pix_x, pix_y)
     struct frame *f;
     int pix_x, pix_y;
{
  BLOCK_INPUT;

  XWarpPointer (FRAME_X_DISPLAY (f), None, FRAME_X_WINDOW (f),
		0, 0, 0, 0, pix_x, pix_y);
  UNBLOCK_INPUT;
}

/* focus shifting, raising and lowering.  */

void
x_focus_on_frame (f)
     struct frame *f;
{
#if 0  /* This proves to be unpleasant.  */
  x_raise_frame (f);
#endif
#if 0
  /* I don't think that the ICCCM allows programs to do things like this
     without the interaction of the window manager.  Whatever you end up
     doing with this code, do it to x_unfocus_frame too.  */
  XSetInputFocus (FRAME_X_DISPLAY (f), FRAME_X_WINDOW (f),
		  RevertToPointerRoot, CurrentTime);
#endif /* ! 0 */
}

void
x_unfocus_frame (f)
     struct frame *f;
{
#if 0
  /* Look at the remarks in x_focus_on_frame.  */
  if (FRAME_X_DISPLAY_INFO (f)->x_focus_frame == f)
    XSetInputFocus (FRAME_X_DISPLAY (f), PointerRoot,
		    RevertToPointerRoot, CurrentTime);
#endif /* ! 0 */
}

/* Raise frame F.  */

void
x_raise_frame (f)
     struct frame *f;
{
  if (f->async_visible)
    {
      BLOCK_INPUT;
#ifdef USE_X_TOOLKIT
      XRaiseWindow (FRAME_X_DISPLAY (f), XtWindow (f->output_data.x->widget));
#else /* not USE_X_TOOLKIT */
      XRaiseWindow (FRAME_X_DISPLAY (f), FRAME_X_WINDOW (f));
#endif /* not USE_X_TOOLKIT */
      XFlush (FRAME_X_DISPLAY (f));
      UNBLOCK_INPUT;
    }
}

/* Lower frame F.  */

void
x_lower_frame (f)
     struct frame *f;
{
  if (f->async_visible)
    {
      BLOCK_INPUT;
#ifdef USE_X_TOOLKIT
      XLowerWindow (FRAME_X_DISPLAY (f), XtWindow (f->output_data.x->widget));
#else /* not USE_X_TOOLKIT */
      XLowerWindow (FRAME_X_DISPLAY (f), FRAME_X_WINDOW (f));
#endif /* not USE_X_TOOLKIT */
      XFlush (FRAME_X_DISPLAY (f));
      UNBLOCK_INPUT;
    }
}

static void
XTframe_raise_lower (f, raise_flag)
     FRAME_PTR f;
     int raise_flag;
{
  if (raise_flag)
    x_raise_frame (f);
  else
    x_lower_frame (f);
}

/* Change of visibility.  */

/* This tries to wait until the frame is really visible.
   However, if the window manager asks the user where to position
   the frame, this will return before the user finishes doing that.
   The frame will not actually be visible at that time,
   but it will become visible later when the window manager
   finishes with it.  */

void
x_make_frame_visible (f)
     struct frame *f;
{
  int mask;
  Lisp_Object type;
  int starting_flags = f->output_data.x->size_hint_flags;
  int original_top, original_left;

  BLOCK_INPUT;

  type = x_icon_type (f);
  if (!NILP (type))
    x_bitmap_icon (f, type);

  if (! FRAME_VISIBLE_P (f))
    {
      /* We test FRAME_GARBAGED_P here to make sure we don't
	 call x_set_offset a second time
	 if we get to x_make_frame_visible a second time
	 before the window gets really visible.  */
      if (! FRAME_ICONIFIED_P (f)
	  && ! f->output_data.x->asked_for_visible)
	x_set_offset (f, f->output_data.x->left_pos, f->output_data.x->top_pos, 0);

      f->output_data.x->asked_for_visible = 1;

      if (! EQ (Vx_no_window_manager, Qt))
	x_wm_set_window_state (f, NormalState);
#ifdef USE_X_TOOLKIT
      /* This was XtPopup, but that did nothing for an iconified frame.  */
      XtMapWidget (f->output_data.x->widget);
#else /* not USE_X_TOOLKIT */
      XMapRaised (FRAME_X_DISPLAY (f), FRAME_X_WINDOW (f));
#endif /* not USE_X_TOOLKIT */
#if 0 /* This seems to bring back scroll bars in the wrong places
	 if the window configuration has changed.  They seem
	 to come back ok without this.  */
      if (FRAME_HAS_VERTICAL_SCROLL_BARS (f))
	XMapSubwindows (FRAME_X_DISPLAY (f), FRAME_X_WINDOW (f));
#endif
    }

  XFlush (FRAME_X_DISPLAY (f));

  /* Synchronize to ensure Emacs knows the frame is visible
     before we do anything else.  We do this loop with input not blocked
     so that incoming events are handled.  */
  {
    Lisp_Object frame;
    int count = input_signal_count;
    /* This must be before UNBLOCK_INPUT
       since events that arrive in response to the actions above
       will set it when they are handled.  */
    int previously_visible = f->output_data.x->has_been_visible;

    original_left = f->output_data.x->left_pos;
    original_top = f->output_data.x->top_pos;

    /* This must come after we set COUNT.  */
    UNBLOCK_INPUT;

    /* We unblock here so that arriving X events are processed.  */

    /* Now move the window back to where it was "supposed to be".
       But don't do it if the gravity is negative.
       When the gravity is negative, this uses a position
       that is 3 pixels too low.  Perhaps that's really the border width.

       Don't do this if the window has never been visible before,
       because the window manager may choose the position
       and we don't want to override it.  */

    if (! FRAME_VISIBLE_P (f) && ! FRAME_ICONIFIED_P (f)
	&& f->output_data.x->win_gravity == NorthWestGravity
	&& previously_visible)
      {
	Drawable rootw;
	int x, y;
	unsigned int width, height, border, depth;

	BLOCK_INPUT;

	/* On some window managers (Such as FVWM) moving an existing window,
	   even to the same place, causes the window manager to introduce
	   an offset.  This can cause the window to move to an unexpected
	   location.  Check the geometry (A little slow here) and then verify
	   that the window is in the right place.  If the window is not in
	   the right place, move it there, and take the potential window
	   manager hit. */

	XGetGeometry (FRAME_X_DISPLAY (f), FRAME_OUTER_WINDOW (f),
		      &rootw, &x, &y, &width, &height, &border, &depth);

	if (original_left != x || original_top != y)
	  XMoveWindow (FRAME_X_DISPLAY (f), FRAME_OUTER_WINDOW (f),
		       original_left, original_top);

	UNBLOCK_INPUT;
      }

    XSETFRAME (frame, f);

    while (1)
      {
	x_sync (f);
	/* Once we have handled input events,
	   we should have received the MapNotify if one is coming.
	   So if we have not got it yet, stop looping.
	   Some window managers make their own decisions
	   about visibility.  */
	if (input_signal_count != count)
	  break;
	/* Machines that do polling rather than SIGIO have been observed
	   to go into a busy-wait here.  So we'll fake an alarm signal
	   to let the handler know that there's something to be read.
	   We used to raise a real alarm, but it seems that the handler
	   isn't always enabled here.  This is probably a bug.  */
	if (input_polling_used ())
	  {
	    /* It could be confusing if a real alarm arrives while processing
	       the fake one.  Turn it off and let the handler reset it.  */
	    alarm (0);
	    input_poll_signal (0);
	  }
	/* Once we have handled input events,
	   we should have received the MapNotify if one is coming.
	   So if we have not got it yet, stop looping.
	   Some window managers make their own decisions
	   about visibility.  */
	if (input_signal_count != count)
	  break;
      }
    FRAME_SAMPLE_VISIBILITY (f);
  }
}

/* Change from mapped state to withdrawn state. */

/* Make the frame visible (mapped and not iconified).  */

void
x_make_frame_invisible (f)
     struct frame *f;
{
  int mask;
  Window window;

#ifdef USE_X_TOOLKIT
  /* Use the frame's outermost window, not the one we normally draw on.  */
  window = XtWindow (f->output_data.x->widget);
#else /* not USE_X_TOOLKIT */
  window = FRAME_X_WINDOW (f);
#endif /* not USE_X_TOOLKIT */

  /* Don't keep the highlight on an invisible frame.  */
  if (FRAME_X_DISPLAY_INFO (f)->x_highlight_frame == f)
    FRAME_X_DISPLAY_INFO (f)->x_highlight_frame = 0;

#if 0/* This might add unreliability; I don't trust it -- rms.  */
  if (! f->async_visible && ! f->async_iconified)
    return;
#endif

  BLOCK_INPUT;

  /* Before unmapping the window, update the WM_SIZE_HINTS property to claim
     that the current position of the window is user-specified, rather than
     program-specified, so that when the window is mapped again, it will be
     placed at the same location, without forcing the user to position it
     by hand again (they have already done that once for this window.)  */
  x_wm_set_size_hint (f, (long) 0, 1);

#ifdef HAVE_X11R4

  if (! XWithdrawWindow (FRAME_X_DISPLAY (f), window,
			 DefaultScreen (FRAME_X_DISPLAY (f))))
    {
      UNBLOCK_INPUT_RESIGNAL;
      error ("Can't notify window manager of window withdrawal");
    }
#else /* ! defined (HAVE_X11R4) */

  /*  Tell the window manager what we're going to do.  */
  if (! EQ (Vx_no_window_manager, Qt))
    {
      XEvent unmap;

      unmap.xunmap.type = UnmapNotify;
      unmap.xunmap.window = window;
      unmap.xunmap.event = DefaultRootWindow (FRAME_X_DISPLAY (f));
      unmap.xunmap.from_configure = False;
      if (! XSendEvent (FRAME_X_DISPLAY (f),
			DefaultRootWindow (FRAME_X_DISPLAY (f)),
			False,
			SubstructureRedirectMask|SubstructureNotifyMask,
			&unmap))
	{
	  UNBLOCK_INPUT_RESIGNAL;
	  error ("Can't notify window manager of withdrawal");
	}
    }

  /* Unmap the window ourselves.  Cheeky!  */
  XUnmapWindow (FRAME_X_DISPLAY (f), window);
#endif /* ! defined (HAVE_X11R4) */

  /* We can't distinguish this from iconification
     just by the event that we get from the server.
     So we can't win using the usual strategy of letting
     FRAME_SAMPLE_VISIBILITY set this.  So do it by hand,
     and synchronize with the server to make sure we agree.  */
  f->visible = 0;
  FRAME_ICONIFIED_P (f) = 0;
  f->async_visible = 0;
  f->async_iconified = 0;

  x_sync (f);

  UNBLOCK_INPUT;
}

/* Change window state from mapped to iconified. */

void
x_iconify_frame (f)
     struct frame *f;
{
  int mask;
  int result;
  Lisp_Object type;

  /* Don't keep the highlight on an invisible frame.  */
  if (FRAME_X_DISPLAY_INFO (f)->x_highlight_frame == f)
    FRAME_X_DISPLAY_INFO (f)->x_highlight_frame = 0;

  if (f->async_iconified)
    return;

  BLOCK_INPUT;

  FRAME_SAMPLE_VISIBILITY (f);

  type = x_icon_type (f);
  if (!NILP (type))
    x_bitmap_icon (f, type);

#ifdef USE_X_TOOLKIT

  if (! FRAME_VISIBLE_P (f))
    {
      if (! EQ (Vx_no_window_manager, Qt))
	x_wm_set_window_state (f, IconicState);
      /* This was XtPopup, but that did nothing for an iconified frame.  */
      XtMapWidget (f->output_data.x->widget);
      /* The server won't give us any event to indicate
	 that an invisible frame was changed to an icon,
	 so we have to record it here.  */
      f->iconified = 1;
      f->visible = 1;
      f->async_iconified = 1;
      f->async_visible = 0;
      UNBLOCK_INPUT;
      return;
    }

  result = XIconifyWindow (FRAME_X_DISPLAY (f),
			   XtWindow (f->output_data.x->widget),
			   DefaultScreen (FRAME_X_DISPLAY (f)));
  UNBLOCK_INPUT;

  if (!result)
    error ("Can't notify window manager of iconification");

  f->async_iconified = 1;
  f->async_visible = 0;


  BLOCK_INPUT;
  XFlush (FRAME_X_DISPLAY (f));
  UNBLOCK_INPUT;
#else /* not USE_X_TOOLKIT */

  /* Make sure the X server knows where the window should be positioned,
     in case the user deiconifies with the window manager.  */
  if (! FRAME_VISIBLE_P (f) && !FRAME_ICONIFIED_P (f))
    x_set_offset (f, f->output_data.x->left_pos, f->output_data.x->top_pos, 0);

  /* Since we don't know which revision of X we're running, we'll use both
     the X11R3 and X11R4 techniques.  I don't know if this is a good idea.  */

  /* X11R4: send a ClientMessage to the window manager using the
     WM_CHANGE_STATE type.  */
  {
    XEvent message;

    message.xclient.window = FRAME_X_WINDOW (f);
    message.xclient.type = ClientMessage;
    message.xclient.message_type = FRAME_X_DISPLAY_INFO (f)->Xatom_wm_change_state;
    message.xclient.format = 32;
    message.xclient.data.l[0] = IconicState;

    if (! XSendEvent (FRAME_X_DISPLAY (f),
		      DefaultRootWindow (FRAME_X_DISPLAY (f)),
		      False,
		      SubstructureRedirectMask | SubstructureNotifyMask,
		      &message))
      {
	UNBLOCK_INPUT_RESIGNAL;
	error ("Can't notify window manager of iconification");
      }
  }

  /* X11R3: set the initial_state field of the window manager hints to
     IconicState.  */
  x_wm_set_window_state (f, IconicState);

  if (!FRAME_VISIBLE_P (f))
    {
      /* If the frame was withdrawn, before, we must map it.  */
      XMapRaised (FRAME_X_DISPLAY (f), FRAME_X_WINDOW (f));
    }

  f->async_iconified = 1;
  f->async_visible = 0;

  XFlush (FRAME_X_DISPLAY (f));
  UNBLOCK_INPUT;
#endif /* not USE_X_TOOLKIT */
}

/* Destroy the X window of frame F.  */

void
x_destroy_window (f)
     struct frame *f;
{
  struct x_display_info *dpyinfo = FRAME_X_DISPLAY_INFO (f);

  BLOCK_INPUT;

  /* If a display connection is dead, don't try sending more
     commands to the X server.  */
  if (dpyinfo->display != 0)
    {
      if (f->output_data.x->icon_desc != 0)
	XDestroyWindow (FRAME_X_DISPLAY (f), f->output_data.x->icon_desc);
#ifdef HAVE_X_I18N
      if (FRAME_XIM (f))
	{
	  XDestroyIC (FRAME_XIC (f));
#if ! defined (SOLARIS2) || defined (HAVE_X11R6)
	  /* This line causes crashes on Solaris with Openwin,
	     due to an apparent bug in XCloseIM.
	     X11R6 seems not to have the bug.  */
	  XCloseIM (FRAME_XIM (f));
#endif
	}
#endif
      XDestroyWindow (FRAME_X_DISPLAY (f), f->output_data.x->window_desc);
#ifdef USE_X_TOOLKIT
      XtDestroyWidget (f->output_data.x->widget);
      free_frame_menubar (f);
#endif /* USE_X_TOOLKIT */

      free_frame_faces (f);
      XFlush (FRAME_X_DISPLAY (f));
    }

  if (f->output_data.x->saved_menu_event)
    free (f->output_data.x->saved_menu_event);

  xfree (f->output_data.x);
  f->output_data.x = 0;
  if (f == dpyinfo->x_focus_frame)
    dpyinfo->x_focus_frame = 0;
  if (f == dpyinfo->x_focus_event_frame)
    dpyinfo->x_focus_event_frame = 0;
  if (f == dpyinfo->x_highlight_frame)
    dpyinfo->x_highlight_frame = 0;

  dpyinfo->reference_count--;

  if (f == dpyinfo->mouse_face_mouse_frame)
    {
      dpyinfo->mouse_face_beg_row
	= dpyinfo->mouse_face_beg_col = -1;
      dpyinfo->mouse_face_end_row
	= dpyinfo->mouse_face_end_col = -1;
      dpyinfo->mouse_face_window = Qnil;
      dpyinfo->mouse_face_deferred_gc = 0;
      dpyinfo->mouse_face_mouse_frame = 0;
    }

  UNBLOCK_INPUT;
}

/* Setting window manager hints.  */

/* Set the normal size hints for the window manager, for frame F.
   FLAGS is the flags word to use--or 0 meaning preserve the flags
   that the window now has.
   If USER_POSITION is nonzero, we set the USPosition
   flag (this is useful when FLAGS is 0).  */

void
x_wm_set_size_hint (f, flags, user_position)
     struct frame *f;
     long flags;
     int user_position;
{
  XSizeHints size_hints;

#ifdef USE_X_TOOLKIT
  Arg al[2];
  int ac = 0;
  Dimension widget_width, widget_height;
  Window window = XtWindow (f->output_data.x->widget);
#else /* not USE_X_TOOLKIT */
  Window window = FRAME_X_WINDOW (f);
#endif /* not USE_X_TOOLKIT */

  /* Setting PMaxSize caused various problems.  */
  size_hints.flags = PResizeInc | PMinSize /* | PMaxSize */;

  flexlines = f->height;

  size_hints.x = f->output_data.x->left_pos;
  size_hints.y = f->output_data.x->top_pos;

#ifdef USE_X_TOOLKIT
  XtSetArg (al[ac], XtNwidth, &widget_width); ac++;
  XtSetArg (al[ac], XtNheight, &widget_height); ac++;
  XtGetValues (f->output_data.x->widget, al, ac);
  size_hints.height = widget_height;
  size_hints.width = widget_width;
#else /* not USE_X_TOOLKIT */
  size_hints.height = PIXEL_HEIGHT (f);
  size_hints.width = PIXEL_WIDTH (f);
#endif /* not USE_X_TOOLKIT */

  size_hints.width_inc = FONT_WIDTH (f->output_data.x->font);
  size_hints.height_inc = f->output_data.x->line_height;
  size_hints.max_width
    = FRAME_X_DISPLAY_INFO (f)->width - CHAR_TO_PIXEL_WIDTH (f, 0);
  size_hints.max_height
    = FRAME_X_DISPLAY_INFO (f)->height - CHAR_TO_PIXEL_HEIGHT (f, 0);

  /* Calculate the base and minimum sizes.

     (When we use the X toolkit, we don't do it here.
     Instead we copy the values that the widgets are using, below.)  */
#ifndef USE_X_TOOLKIT
  {
    int base_width, base_height;
    int min_rows = 0, min_cols = 0;

    base_width = CHAR_TO_PIXEL_WIDTH (f, 0);
    base_height = CHAR_TO_PIXEL_HEIGHT (f, 0);

    check_frame_size (f, &min_rows, &min_cols);

    /* The window manager uses the base width hints to calculate the
       current number of rows and columns in the frame while
       resizing; min_width and min_height aren't useful for this
       purpose, since they might not give the dimensions for a
       zero-row, zero-column frame.

       We use the base_width and base_height members if we have
       them; otherwise, we set the min_width and min_height members
       to the size for a zero x zero frame.  */

#ifdef HAVE_X11R4
    size_hints.flags |= PBaseSize;
    size_hints.base_width = base_width;
    size_hints.base_height = base_height;
    size_hints.min_width  = base_width + min_cols * size_hints.width_inc;
    size_hints.min_height = base_height + min_rows * size_hints.height_inc;
#else
    size_hints.min_width = base_width;
    size_hints.min_height = base_height;
#endif
  }

  /* If we don't need the old flags, we don't need the old hint at all.  */
  if (flags)
    {
      size_hints.flags |= flags;
      goto no_read;
    }
#endif /* not USE_X_TOOLKIT */

  {
    XSizeHints hints;		/* Sometimes I hate X Windows... */
    long supplied_return;
    int value;

#ifdef HAVE_X11R4
    value = XGetWMNormalHints (FRAME_X_DISPLAY (f), window, &hints,
			       &supplied_return);
#else
    value = XGetNormalHints (FRAME_X_DISPLAY (f), window, &hints);
#endif

#ifdef USE_X_TOOLKIT
    size_hints.base_height = hints.base_height;
    size_hints.base_width = hints.base_width;
    size_hints.min_height = hints.min_height;
    size_hints.min_width = hints.min_width;
#endif

    if (flags)
      size_hints.flags |= flags;
    else
      {
	if (value == 0)
	  hints.flags = 0;
	if (hints.flags & PSize)
	  size_hints.flags |= PSize;
	if (hints.flags & PPosition)
	  size_hints.flags |= PPosition;
	if (hints.flags & USPosition)
	  size_hints.flags |= USPosition;
	if (hints.flags & USSize)
	  size_hints.flags |= USSize;
      }
  }

 no_read:

#ifdef PWinGravity
  size_hints.win_gravity = f->output_data.x->win_gravity;
  size_hints.flags |= PWinGravity;

  if (user_position)
    {
      size_hints.flags &= ~ PPosition;
      size_hints.flags |= USPosition;
    }
#endif /* PWinGravity */

#ifdef HAVE_X11R4
  XSetWMNormalHints (FRAME_X_DISPLAY (f), window, &size_hints);
#else
  XSetNormalHints (FRAME_X_DISPLAY (f), window, &size_hints);
#endif
}

/* Used for IconicState or NormalState */
void
x_wm_set_window_state (f, state)
     struct frame *f;
     int state;
{
#ifdef USE_X_TOOLKIT
  Arg al[1];

  XtSetArg (al[0], XtNinitialState, state);
  XtSetValues (f->output_data.x->widget, al, 1);
#else /* not USE_X_TOOLKIT */
  Window window = FRAME_X_WINDOW (f);

  f->output_data.x->wm_hints.flags |= StateHint;
  f->output_data.x->wm_hints.initial_state = state;

  XSetWMHints (FRAME_X_DISPLAY (f), window, &f->output_data.x->wm_hints);
#endif /* not USE_X_TOOLKIT */
}

void
x_wm_set_icon_pixmap (f, pixmap_id)
     struct frame *f;
     int pixmap_id;
{
  Pixmap icon_pixmap;

#ifdef USE_X_TOOLKIT
  Window window = XtWindow (f->output_data.x->widget);
#else
  Window window = FRAME_X_WINDOW (f);
#endif

  if (pixmap_id > 0)
    {
      icon_pixmap = x_bitmap_pixmap (f, pixmap_id);
      f->output_data.x->wm_hints.icon_pixmap = icon_pixmap;
    }
  else
    {
      /* It seems there is no way to turn off use of an icon pixmap.
	 The following line does it, only if no icon has yet been created,
	 for some window managers.  But with mwm it crashes.
	 Some people say it should clear the IconPixmapHint bit in this case,
	 but that doesn't work, and the X consortium said it isn't the
	 right thing at all.  Since there is no way to win,
	 best to explicitly give up.  */
#if 0
      f->output_data.x->wm_hints.icon_pixmap = None;
#else
      return;
#endif
    }

#ifdef USE_X_TOOLKIT /* same as in x_wm_set_window_state.  */

  {
    Arg al[1];
    XtSetArg (al[0], XtNiconPixmap, icon_pixmap);
    XtSetValues (f->output_data.x->widget, al, 1);
  }

#else /* not USE_X_TOOLKIT */
  
  f->output_data.x->wm_hints.flags |= IconPixmapHint;
  XSetWMHints (FRAME_X_DISPLAY (f), window, &f->output_data.x->wm_hints);

#endif /* not USE_X_TOOLKIT */
}

void
x_wm_set_icon_position (f, icon_x, icon_y)
     struct frame *f;
     int icon_x, icon_y;
{
#ifdef USE_X_TOOLKIT
  Window window = XtWindow (f->output_data.x->widget);
#else
  Window window = FRAME_X_WINDOW (f);
#endif

  f->output_data.x->wm_hints.flags |= IconPositionHint;
  f->output_data.x->wm_hints.icon_x = icon_x;
  f->output_data.x->wm_hints.icon_y = icon_y;

  XSetWMHints (FRAME_X_DISPLAY (f), window, &f->output_data.x->wm_hints);
}


/* Interface to fontset handler.  */

/* Return a pointer to struct font_info of font FONT_IDX of frame F.  */
struct font_info *
x_get_font_info (f, font_idx)
     FRAME_PTR f;
     int font_idx;
{
  return (FRAME_X_FONT_TABLE (f) + font_idx);
}


/* Return a list of names of available fonts matching PATTERN on frame
   F.  If SIZE is not 0, it is the size (maximum bound width) of fonts
   to be listed.  Frame F NULL means we have not yet created any
   frame on X, and consult the first display in x_display_list.
   MAXNAMES sets a limit on how many fonts to match.  */

Lisp_Object
x_list_fonts (f, pattern, size, maxnames)
     FRAME_PTR f;
     Lisp_Object pattern;
     int size;
     int maxnames;
{
  Lisp_Object list = Qnil, patterns, newlist = Qnil, key, tem, second_best;
  Display *dpy = f != NULL ? FRAME_X_DISPLAY (f) : x_display_list->display;
  int try_XLoadQueryFont = 0;
  int count;

  patterns = Fassoc (pattern, Valternate_fontname_alist);
  if (NILP (patterns))
    patterns = Fcons (pattern, Qnil);

  if (maxnames == 1 && !size)
    /* We can return any single font matching PATTERN.  */
    try_XLoadQueryFont = 1;

  for (; CONSP (patterns); patterns = XCONS (patterns)->cdr)
    {
      int num_fonts;
      char **names;

      pattern = XCONS (patterns)->car;
      /* See if we cached the result for this particular query.
         The cache is an alist of the form:
	   (((PATTERN . MAXNAMES) (FONTNAME . WIDTH) ...) ...)
      */
      if (f && (tem = XCONS (FRAME_X_DISPLAY_INFO (f)->name_list_element)->cdr,
		key = Fcons (pattern, make_number (maxnames)),
		!NILP (list = Fassoc (key, tem))))
	{
	  list = Fcdr_safe (list);
	  /* We have a cashed list.  Don't have to get the list again.  */
	  goto label_cached;
	}

      /* At first, put PATTERN in the cache.  */

      BLOCK_INPUT;
      count = x_catch_errors (dpy);

      if (try_XLoadQueryFont)
	{
	  XFontStruct *font;
	  unsigned long value;

	  font = XLoadQueryFont (dpy, XSTRING (pattern)->data);
	  if (x_had_errors_p (dpy))
	    {
	      /* This error is perhaps due to insufficient memory on X
                 server.  Let's just ignore it.  */
	      font = NULL;
	      x_clear_errors (dpy);
	    }

	  if (font
	      && XGetFontProperty (font, XA_FONT, &value))
	    {
	      char *name = (char *) XGetAtomName (dpy, (Atom) value);
	      int len = strlen (name);
	      char *tmp;

	      /* If DXPC (a Differential X Protocol Compressor)
                 Ver.3.7 is running, XGetAtomName will return null
                 string.  We must avoid such a name.  */
	      if (len == 0)
		try_XLoadQueryFont = 0;
	      else
		{
		  num_fonts = 1;
		  names = (char **) alloca (sizeof (char *));
		  /* Some systems only allow alloca assigned to a
                     simple var.  */
		  tmp = (char *) alloca (len + 1);  names[0] = tmp;
		  bcopy (name, names[0], len + 1);
		  XFree (name);
		}
	    }
	  else
	    try_XLoadQueryFont = 0;

	  if (font)
	    XFreeFont (dpy, font);
	}

      if (!try_XLoadQueryFont)
	{
	  /* We try at least 10 fonts because XListFonts will return
	     auto-scaled fonts at the head.  */
	  names = XListFonts (dpy, XSTRING (pattern)->data, max (maxnames, 10),
			      &num_fonts);
	  if (x_had_errors_p (dpy))
	    {
	      /* This error is perhaps due to insufficient memory on X
                 server.  Let's just ignore it.  */
	      names = NULL;
	      x_clear_errors (dpy);
	    }
	}

      x_uncatch_errors (dpy, count);
      UNBLOCK_INPUT;

      if (names)
	{
	  int i;

	  /* Make a list of all the fonts we got back.
	     Store that in the font cache for the display.  */
	  for (i = 0; i < num_fonts; i++)
	    {
	      char *p = names[i];
	      int average_width = -1, dashes = 0, width = 0;

	      /* Count the number of dashes in NAMES[I].  If there are
		14 dashes, and the field value following 12th dash
		(AVERAGE_WIDTH) is 0, this is a auto-scaled font which
		is usually too ugly to be used for editing.  Let's
		ignore it.  */
	      while (*p)
		if (*p++ == '-')
		  {
		    dashes++;
		    if (dashes == 7) /* PIXEL_SIZE field */
		      width = atoi (p);
		    else if (dashes == 12) /* AVERAGE_WIDTH field */
		      average_width = atoi (p);
		  }
	      if (dashes < 14 || average_width != 0)
		{
		  tem = build_string (names[i]);
		  if (NILP (Fassoc (tem, list)))
		    {
		      if (STRINGP (Vx_pixel_size_width_font_regexp)
			  && ((fast_c_string_match_ignore_case
			       (Vx_pixel_size_width_font_regexp, names[i]))
			      >= 0))
			/* We can set the value of PIXEL_SIZE to the
			  width of this font.  */
			list = Fcons (Fcons (tem, make_number (width)), list);
		      else
			/* For the moment, width is not known.  */
			list = Fcons (Fcons (tem, Qnil), list);
		    }
		}
	    }
	  if (!try_XLoadQueryFont)
	    XFreeFontNames (names);
	}

      /* Now store the result in the cache.  */
      if (f != NULL)
	XCONS (FRAME_X_DISPLAY_INFO (f)->name_list_element)->cdr
	  = Fcons (Fcons (key, list),
		   XCONS (FRAME_X_DISPLAY_INFO (f)->name_list_element)->cdr);

    label_cached:
      if (NILP (list)) continue; /* Try the remaining alternatives.  */

      newlist = second_best = Qnil;
      /* Make a list of the fonts that have the right width.  */
      for (; CONSP (list); list = XCONS (list)->cdr)
	{
	  int found_size;

	  tem = XCONS (list)->car;

	  if (!CONSP (tem) || NILP (XCONS (tem)->car))
	    continue;
	  if (!size)
	    {
	      newlist = Fcons (XCONS (tem)->car, newlist);
	      continue;
	    }

	  if (!INTEGERP (XCONS (tem)->cdr))
	    {
	      /* Since we have not yet known the size of this font, we
		must try slow function call XLoadQueryFont.  */
	      XFontStruct *thisinfo;

	      BLOCK_INPUT;
	      count = x_catch_errors (dpy);
	      thisinfo = XLoadQueryFont (dpy,
					 XSTRING (XCONS (tem)->car)->data);
	      if (x_had_errors_p (dpy))
		{
		  /* This error is perhaps due to insufficient memory on X
		     server.  Let's just ignore it.  */
		  thisinfo = NULL;
		  x_clear_errors (dpy);
		}
	      x_uncatch_errors (dpy, count);
	      UNBLOCK_INPUT;

	      if (thisinfo)
		{
		  XCONS (tem)->cdr
		    = (thisinfo->min_bounds.width == 0
		       ? make_number (0)
		       : make_number (thisinfo->max_bounds.width));
		  XFreeFont (dpy, thisinfo);
		}
	      else
		/* For unknown reason, the previous call of XListFont had
		  retruned a font which can't be opened.  Record the size
		  as 0 not to try to open it again.  */
		XCONS (tem)->cdr = make_number (0);
	    }

	  found_size = XINT (XCONS (tem)->cdr);
	  if (found_size == size)
	    newlist = Fcons (XCONS (tem)->car, newlist);
	  else if (found_size > 0)
	    {
	      if (NILP (second_best))
		second_best = tem;
	      else if (found_size < size)
		{
		  if (XINT (XCONS (second_best)->cdr) > size
		      || XINT (XCONS (second_best)->cdr) < found_size)
		    second_best = tem;
		}
	      else
		{
		  if (XINT (XCONS (second_best)->cdr) > size
		      && XINT (XCONS (second_best)->cdr) > found_size)
		    second_best = tem;
		}
	    }
	}
      if (!NILP (newlist))
	break;
      else if (!NILP (second_best))
	{
	  newlist = Fcons (XCONS (second_best)->car, Qnil);
	  break;
	}
    }

  return newlist;
}  

/* Load font named FONTNAME of the size SIZE for frame F, and return a
   pointer to the structure font_info while allocating it dynamically.
   If SIZE is 0, load any size of font.
   If loading is failed, return NULL.  */

struct font_info *
x_load_font (f, fontname, size)
     struct frame *f;
     register char *fontname;
     int size;
{
  struct x_display_info *dpyinfo = FRAME_X_DISPLAY_INFO (f);
  Lisp_Object font_names;
  int count;

  /* Get a list of all the fonts that match this name.  Once we
     have a list of matching fonts, we compare them against the fonts
     we already have by comparing names.  */
  font_names = x_list_fonts (f, build_string (fontname), size, 1);

  if (!NILP (font_names))
    {
      Lisp_Object tail;
      int i;

      for (i = 0; i < dpyinfo->n_fonts; i++)
	for (tail = font_names; CONSP (tail); tail = XCONS (tail)->cdr)
	  if (!strcmp (dpyinfo->font_table[i].name,
		       XSTRING (XCONS (tail)->car)->data)
	      || !strcmp (dpyinfo->font_table[i].full_name,
			  XSTRING (XCONS (tail)->car)->data))
	    return (dpyinfo->font_table + i);
    }

  /* Load the font and add it to the table.  */
  {
    char *full_name;
    XFontStruct *font;
    struct font_info *fontp;
    unsigned long value;

    /* If we have found fonts by x_list_font, load one of them.  If
       not, we still try to load a font by the name given as FONTNAME
       because XListFonts (called in x_list_font) of some X server has
       a bug of not finding a font even if the font surely exists and
       is loadable by XLoadQueryFont.  */
    if (size > 0 && !NILP (font_names))
      fontname = (char *) XSTRING (XCONS (font_names)->car)->data;

    BLOCK_INPUT;
    count = x_catch_errors (FRAME_X_DISPLAY (f));
    font = (XFontStruct *) XLoadQueryFont (FRAME_X_DISPLAY (f), fontname);
    if (x_had_errors_p (FRAME_X_DISPLAY (f)))
      {
	/* This error is perhaps due to insufficient memory on X
	   server.  Let's just ignore it.  */
	font = NULL;
	x_clear_errors (FRAME_X_DISPLAY (f));
      }
    x_uncatch_errors (FRAME_X_DISPLAY (f), count);
    UNBLOCK_INPUT;
    if (!font)
      return NULL;

    /* Do we need to create the table?  */
    if (dpyinfo->font_table_size == 0)
      {
	dpyinfo->font_table_size = 16;
	dpyinfo->font_table
	  = (struct font_info *) xmalloc (dpyinfo->font_table_size
					  * sizeof (struct font_info));
      }
    /* Do we need to grow the table?  */
    else if (dpyinfo->n_fonts
	     >= dpyinfo->font_table_size)
      {
	dpyinfo->font_table_size *= 2;
	dpyinfo->font_table
	  = (struct font_info *) xrealloc (dpyinfo->font_table,
					   (dpyinfo->font_table_size
					    * sizeof (struct font_info)));
      }

    fontp = dpyinfo->font_table + dpyinfo->n_fonts;

    /* Now fill in the slots of *FONTP.  */
    BLOCK_INPUT;
    fontp->font = font;
    fontp->font_idx = dpyinfo->n_fonts;
    fontp->name = (char *) xmalloc (strlen (fontname) + 1);
    bcopy (fontname, fontp->name, strlen (fontname) + 1);

    /* Try to get the full name of FONT.  Put it in FULL_NAME.  */
    full_name = 0;
    if (XGetFontProperty (font, XA_FONT, &value))
      {
	char *name = (char *) XGetAtomName (FRAME_X_DISPLAY (f), (Atom) value);
	char *p = name;
	int dashes = 0;

	/* Count the number of dashes in the "full name".
	   If it is too few, this isn't really the font's full name,
	   so don't use it.
	   In X11R4, the fonts did not come with their canonical names
	   stored in them.  */
	while (*p)
	  {
	    if (*p == '-')
	      dashes++;
	    p++;
	  }

	if (dashes >= 13)
	  {
	    full_name = (char *) xmalloc (p - name + 1);
	    bcopy (name, full_name, p - name + 1);
	  }

	XFree (name);
      }
    
    if (full_name != 0)
      fontp->full_name = full_name;
    else
      fontp->full_name = fontp->name;

    fontp->size = font->max_bounds.width;
    fontp->height = FONT_HEIGHT (font);
    {
      /* For some font, ascent and descent in max_bounds field is
	 larger than the above value.  */
      int max_height = font->max_bounds.ascent + font->max_bounds.descent;
      if (max_height > fontp->height)
	fontp->height = max_height;
    }

    if (NILP (font_names))
      {
	/* We come here because of a bug of XListFonts mentioned at
	   the head of this block.  Let's store this information in
	   the cache for x_list_fonts.  */
	Lisp_Object lispy_name = build_string (fontname);
	Lisp_Object lispy_full_name = build_string (fontp->full_name);

	XCONS (dpyinfo->name_list_element)->cdr
	  = Fcons (Fcons (Fcons (lispy_name, make_number (256)),
			  Fcons (Fcons (lispy_full_name,
					make_number (fontp->size)),
				 Qnil)),
		   XCONS (dpyinfo->name_list_element)->cdr);
	if (full_name)
	  XCONS (dpyinfo->name_list_element)->cdr
	    = Fcons (Fcons (Fcons (lispy_full_name, make_number (256)),
			    Fcons (Fcons (lispy_full_name,
					  make_number (fontp->size)),
				   Qnil)),
		     XCONS (dpyinfo->name_list_element)->cdr);
      }

    /* The slot `encoding' specifies how to map a character
       code-points (0x20..0x7F or 0x2020..0x7F7F) of each charset to
       the font code-points (0:0x20..0x7F, 1:0xA0..0xFF, 0:0x2020..0x7F7F,
       the font code-points (0:0x20..0x7F, 1:0xA0..0xFF,
       0:0x2020..0x7F7F, 1:0xA0A0..0xFFFF, 3:0x20A0..0x7FFF, or
       2:0xA020..0xFF7F).  For the moment, we don't know which charset
       uses this font.  So, we set informatoin in fontp->encoding[1]
       which is never used by any charset.  If mapping can't be
       decided, set FONT_ENCODING_NOT_DECIDED.  */
    fontp->encoding[1]
      = (font->max_byte1 == 0
	 /* 1-byte font */
	 ? (font->min_char_or_byte2 < 0x80
	    ? (font->max_char_or_byte2 < 0x80
	       ? 0		/* 0x20..0x7F */
	       : FONT_ENCODING_NOT_DECIDED) /* 0x20..0xFF */
	    : 1)		/* 0xA0..0xFF */
	 /* 2-byte font */
	 : (font->min_byte1 < 0x80
	    ? (font->max_byte1 < 0x80
	       ? (font->min_char_or_byte2 < 0x80
		  ? (font->max_char_or_byte2 < 0x80
		     ? 0		/* 0x2020..0x7F7F */
		     : FONT_ENCODING_NOT_DECIDED) /* 0x2020..0x7FFF */
		  : 3)		/* 0x20A0..0x7FFF */
	       : FONT_ENCODING_NOT_DECIDED) /* 0x20??..0xA0?? */
	    : (font->min_char_or_byte2 < 0x80
	       ? (font->max_char_or_byte2 < 0x80
		  ? 2		/* 0xA020..0xFF7F */
		  : FONT_ENCODING_NOT_DECIDED) /* 0xA020..0xFFFF */
	       : 1)));		/* 0xA0A0..0xFFFF */

    fontp->baseline_offset
      = (XGetFontProperty (font, dpyinfo->Xatom_MULE_BASELINE_OFFSET, &value)
	 ? (long) value : 0);
    fontp->relative_compose
      = (XGetFontProperty (font, dpyinfo->Xatom_MULE_RELATIVE_COMPOSE, &value)
	 ? (long) value : 0);
    fontp->default_ascent
      = (XGetFontProperty (font, dpyinfo->Xatom_MULE_DEFAULT_ASCENT, &value)
	 ? (long) value : 0);

    UNBLOCK_INPUT;
    dpyinfo->n_fonts++;

    return fontp;
  }
}

/* Return a pointer to struct font_info of a font named FONTNAME for frame F.
   If no such font is loaded, return NULL.  */
struct font_info *
x_query_font (f, fontname)
     struct frame *f;
     register char *fontname;
{
  struct x_display_info *dpyinfo = FRAME_X_DISPLAY_INFO (f);
  int i;

  for (i = 0; i < dpyinfo->n_fonts; i++)
    if (!strcmp (dpyinfo->font_table[i].name, fontname)
	|| !strcmp (dpyinfo->font_table[i].full_name, fontname))
      return (dpyinfo->font_table + i);
  return NULL;
}

/* Find a CCL program for a font specified by FONTP, and set the memer
 `encoder' of the structure.  */

void
x_find_ccl_program (fontp)
     struct font_info *fontp;
{
  extern Lisp_Object Vfont_ccl_encoder_alist, Vccl_program_table;
  extern Lisp_Object Qccl_program_idx;
  extern Lisp_Object resolve_symbol_ccl_program ();
  Lisp_Object list, elt, ccl_prog, ccl_id;

  for (list = Vfont_ccl_encoder_alist; CONSP (list); list = XCONS (list)->cdr)
    {
      elt = XCONS (list)->car;
      if (CONSP (elt)
	  && STRINGP (XCONS (elt)->car)
	  && (fast_c_string_match_ignore_case (XCONS (elt)->car, fontp->name)
	      >= 0))
	{
	  if (SYMBOLP (XCONS (elt)->cdr) &&
	      (!NILP (ccl_id = Fget (XCONS (elt)->cdr, Qccl_program_idx))))
	    {
	      ccl_prog = XVECTOR (Vccl_program_table)->contents[XUINT (ccl_id)];
	      if (!CONSP (ccl_prog)) continue;
	      ccl_prog = XCONS (ccl_prog)->cdr;
	    }
	  else
	    {
	      ccl_prog = XCONS (elt)->cdr;
	      if (!VECTORP (ccl_prog)) continue;
	    }
	    
	  fontp->font_encoder
	    = (struct ccl_program *) xmalloc (sizeof (struct ccl_program));
	  setup_ccl_program (fontp->font_encoder,
			     resolve_symbol_ccl_program (ccl_prog));
	  break;
	}
    }
}


/* Initialization.  */

#ifdef USE_X_TOOLKIT
static XrmOptionDescRec emacs_options[] = {
  {"-geometry",	".geometry", XrmoptionSepArg, NULL},
  {"-iconic",	".iconic", XrmoptionNoArg, (XtPointer) "yes"},

  {"-internal-border-width", "*EmacsScreen.internalBorderWidth",
     XrmoptionSepArg, NULL},
  {"-ib",	"*EmacsScreen.internalBorderWidth", XrmoptionSepArg, NULL},

  {"-T",	"*EmacsShell.title", XrmoptionSepArg, (XtPointer) NULL},
  {"-wn",	"*EmacsShell.title", XrmoptionSepArg, (XtPointer) NULL},
  {"-title",	"*EmacsShell.title", XrmoptionSepArg, (XtPointer) NULL},
  {"-iconname",	"*EmacsShell.iconName", XrmoptionSepArg, (XtPointer) NULL},
  {"-in",	"*EmacsShell.iconName", XrmoptionSepArg, (XtPointer) NULL},
  {"-mc",	"*pointerColor", XrmoptionSepArg, (XtPointer) NULL},
  {"-cr",	"*cursorColor", XrmoptionSepArg, (XtPointer) NULL}
};
#endif /* USE_X_TOOLKIT */

static int x_initialized;

#ifdef MULTI_KBOARD
/* Test whether two display-name strings agree up to the dot that separates
   the screen number from the server number.  */
static int
same_x_server (name1, name2)
     char *name1, *name2;
{
  int seen_colon = 0;
  unsigned char *system_name = XSTRING (Vsystem_name)->data;
  int system_name_length = strlen (system_name);
  int length_until_period = 0;

  while (system_name[length_until_period] != 0
	 && system_name[length_until_period] != '.')
    length_until_period++;

  /* Treat `unix' like an empty host name.  */
  if (! strncmp (name1, "unix:", 5))
    name1 += 4;
  if (! strncmp (name2, "unix:", 5))
    name2 += 4;
  /* Treat this host's name like an empty host name.  */
  if (! strncmp (name1, system_name, system_name_length)
      && name1[system_name_length] == ':')
    name1 += system_name_length;
  if (! strncmp (name2, system_name, system_name_length)
      && name2[system_name_length] == ':')
    name2 += system_name_length;
  /* Treat this host's domainless name like an empty host name.  */
  if (! strncmp (name1, system_name, length_until_period)
      && name1[length_until_period] == ':')
    name1 += length_until_period;
  if (! strncmp (name2, system_name, length_until_period)
      && name2[length_until_period] == ':')
    name2 += length_until_period;

  for (; *name1 != '\0' && *name1 == *name2; name1++, name2++)
    {
      if (*name1 == ':')
	seen_colon++;
      if (seen_colon && *name1 == '.')
	return 1;
    }
  return (seen_colon
	  && (*name1 == '.' || *name1 == '\0')
	  && (*name2 == '.' || *name2 == '\0'));
}
#endif

#if defined (HAVE_X_I18N) || (defined (USE_X_TOOLKIT) && defined (HAVE_X11XTR6))
/* Recover from setlocale (LC_ALL, "").  */
static void
fixup_locale ()
{
  /* Currently we require strerror to use the "C" locale,
     since we don't yet support decoding its string result.  */
#ifdef LC_MESSAGES
  setlocale (LC_MESSAGES, "C");
#endif

  /* The Emacs Lisp reader needs LC_NUMERIC to be "C",
     so that numbers are read and printed properly for Emacs Lisp.  */
  setlocale (LC_NUMERIC, "C");

  /* Currently we require strftime to use the "C" locale,
     since we don't yet support encoding its format argument,
     or decoding its string result.  */
  setlocale (LC_TIME, "C");
}
#endif

struct x_display_info *
x_term_init (display_name, xrm_option, resource_name)
     Lisp_Object display_name;
     char *xrm_option;
     char *resource_name;
{
  Lisp_Object frame;
  char *defaultvalue;
  int connection;
  Display *dpy;
  struct x_display_info *dpyinfo;
  XrmDatabase xrdb;

  BLOCK_INPUT;

  if (!x_initialized)
    {
      x_initialize ();
      x_initialized = 1;
    }

#ifdef HAVE_X_I18N
  setlocale (LC_ALL, "");
  fixup_locale ();
#endif

#ifdef USE_X_TOOLKIT
  /* weiner@footloose.sps.mot.com reports that this causes
     errors with X11R5:
	   X protocol error: BadAtom (invalid Atom parameter)
	   on protocol request 18skiloaf.
     So let's not use it until R6.  */
#ifdef HAVE_X11XTR6
  XtSetLanguageProc (NULL, NULL, NULL);
#endif

  {
    int argc = 0;
    char *argv[3];

    argv[0] = "";
    argc = 1;
    if (xrm_option)
      {
	argv[argc++] = "-xrm";
	argv[argc++] = xrm_option;
      }
    dpy = XtOpenDisplay (Xt_app_con, XSTRING (display_name)->data,
			 resource_name, EMACS_CLASS,
			 emacs_options, XtNumber (emacs_options),
			 &argc, argv);

#ifdef HAVE_X11XTR6
    /* I think this is to compensate for XtSetLanguageProc.  */
    fixup_locale ();
#endif
  }

#else /* not USE_X_TOOLKIT */
#ifdef HAVE_X11R5
  XSetLocaleModifiers ("");
#endif
  dpy = XOpenDisplay (XSTRING (display_name)->data);
#endif /* not USE_X_TOOLKIT */

  /* Detect failure.  */
  if (dpy == 0)
    {
      UNBLOCK_INPUT;
      return 0;
    }

  /* We have definitely succeeded.  Record the new connection.  */

  dpyinfo = (struct x_display_info *) xmalloc (sizeof (struct x_display_info));

#ifdef MULTI_KBOARD
  {
    struct x_display_info *share;
    Lisp_Object tail;

    for (share = x_display_list, tail = x_display_name_list; share;
	 share = share->next, tail = XCONS (tail)->cdr)
      if (same_x_server (XSTRING (XCONS (XCONS (tail)->car)->car)->data,
			 XSTRING (display_name)->data))
	break;
    if (share)
      dpyinfo->kboard = share->kboard;
    else
      {
	dpyinfo->kboard = (KBOARD *) xmalloc (sizeof (KBOARD));
	init_kboard (dpyinfo->kboard);
	if (!EQ (XSYMBOL (Qvendor_specific_keysyms)->function, Qunbound))
	  {
	    char *vendor = ServerVendor (dpy);
	    dpyinfo->kboard->Vsystem_key_alist
	      = call1 (Qvendor_specific_keysyms,
		       build_string (vendor ? vendor : ""));
	  }

	dpyinfo->kboard->next_kboard = all_kboards;
	all_kboards = dpyinfo->kboard;
	/* Don't let the initial kboard remain current longer than necessary.
	   That would cause problems if a file loaded on startup tries to
	   prompt in the minibuffer.  */
	if (current_kboard == initial_kboard)
	  current_kboard = dpyinfo->kboard;
      }
    dpyinfo->kboard->reference_count++;
  }
#endif

  /* Put this display on the chain.  */
  dpyinfo->next = x_display_list;
  x_display_list = dpyinfo;

  /* Put it on x_display_name_list as well, to keep them parallel.  */ 
  x_display_name_list = Fcons (Fcons (display_name, Qnil),
			       x_display_name_list);
  dpyinfo->name_list_element = XCONS (x_display_name_list)->car;

  dpyinfo->display = dpy;

#if 0
  XSetAfterFunction (x_current_display, x_trace_wire);
#endif /* ! 0 */

  dpyinfo->x_id_name
    = (char *) xmalloc (STRING_BYTES (XSTRING (Vinvocation_name))
			+ STRING_BYTES (XSTRING (Vsystem_name))
			+ 2);
  sprintf (dpyinfo->x_id_name, "%s@%s",
	   XSTRING (Vinvocation_name)->data, XSTRING (Vsystem_name)->data);

  /* Figure out which modifier bits mean what.  */
  x_find_modifier_meanings (dpyinfo);

  /* Get the scroll bar cursor.  */
  dpyinfo->vertical_scroll_bar_cursor
    = XCreateFontCursor (dpyinfo->display, XC_sb_v_double_arrow);

  xrdb = x_load_resources (dpyinfo->display, xrm_option,
			   resource_name, EMACS_CLASS);
#ifdef HAVE_XRMSETDATABASE
  XrmSetDatabase (dpyinfo->display, xrdb);
#else
  dpyinfo->display->db = xrdb;
#endif
  /* Put the rdb where we can find it in a way that works on
     all versions.  */
  dpyinfo->xrdb = xrdb;

  dpyinfo->screen = ScreenOfDisplay (dpyinfo->display,
				     DefaultScreen (dpyinfo->display));
  dpyinfo->visual = select_visual (dpyinfo->display, dpyinfo->screen,
				   &dpyinfo->n_planes);
  dpyinfo->height = HeightOfScreen (dpyinfo->screen);
  dpyinfo->width = WidthOfScreen (dpyinfo->screen);
  dpyinfo->root_window = RootWindowOfScreen (dpyinfo->screen);
  dpyinfo->grabbed = 0;
  dpyinfo->reference_count = 0;
  dpyinfo->icon_bitmap_id = -1;
  dpyinfo->n_fonts = 0;
  dpyinfo->font_table_size = 0;
  dpyinfo->bitmaps = 0;
  dpyinfo->bitmaps_size = 0;
  dpyinfo->bitmaps_last = 0;
  dpyinfo->scratch_cursor_gc = 0;
  dpyinfo->mouse_face_mouse_frame = 0;
  dpyinfo->mouse_face_deferred_gc = 0;
  dpyinfo->mouse_face_beg_row = dpyinfo->mouse_face_beg_col = -1;
  dpyinfo->mouse_face_end_row = dpyinfo->mouse_face_end_col = -1;
  dpyinfo->mouse_face_face_id = 0;
  dpyinfo->mouse_face_window = Qnil;
  dpyinfo->mouse_face_mouse_x = dpyinfo->mouse_face_mouse_y = 0;
  dpyinfo->mouse_face_defer = 0;
  dpyinfo->x_focus_frame = 0;
  dpyinfo->x_focus_event_frame = 0;
  dpyinfo->x_highlight_frame = 0;

  dpyinfo->Xatom_wm_protocols
    = XInternAtom (dpyinfo->display, "WM_PROTOCOLS", False);
  dpyinfo->Xatom_wm_take_focus
    = XInternAtom (dpyinfo->display, "WM_TAKE_FOCUS", False);
  dpyinfo->Xatom_wm_save_yourself
    = XInternAtom (dpyinfo->display, "WM_SAVE_YOURSELF", False);
  dpyinfo->Xatom_wm_delete_window
    = XInternAtom (dpyinfo->display, "WM_DELETE_WINDOW", False);
  dpyinfo->Xatom_wm_change_state
    = XInternAtom (dpyinfo->display, "WM_CHANGE_STATE", False);
  dpyinfo->Xatom_wm_configure_denied
    = XInternAtom (dpyinfo->display, "WM_CONFIGURE_DENIED", False);
  dpyinfo->Xatom_wm_window_moved
    = XInternAtom (dpyinfo->display, "WM_MOVED", False);
  dpyinfo->Xatom_editres
    = XInternAtom (dpyinfo->display, "Editres", False);
  dpyinfo->Xatom_CLIPBOARD
    = XInternAtom (dpyinfo->display, "CLIPBOARD", False);
  dpyinfo->Xatom_TIMESTAMP
    = XInternAtom (dpyinfo->display, "TIMESTAMP", False);
  dpyinfo->Xatom_TEXT
    = XInternAtom (dpyinfo->display, "TEXT", False);
  dpyinfo->Xatom_COMPOUND_TEXT
    = XInternAtom (dpyinfo->display, "COMPOUND_TEXT", False);
  dpyinfo->Xatom_DELETE
    = XInternAtom (dpyinfo->display, "DELETE", False);
  dpyinfo->Xatom_MULTIPLE
    = XInternAtom (dpyinfo->display, "MULTIPLE", False);
  dpyinfo->Xatom_INCR
    = XInternAtom (dpyinfo->display, "INCR", False);
  dpyinfo->Xatom_EMACS_TMP
    = XInternAtom (dpyinfo->display, "_EMACS_TMP_", False);
  dpyinfo->Xatom_TARGETS
    = XInternAtom (dpyinfo->display, "TARGETS", False);
  dpyinfo->Xatom_NULL
    = XInternAtom (dpyinfo->display, "NULL", False);
  dpyinfo->Xatom_ATOM_PAIR
    = XInternAtom (dpyinfo->display, "ATOM_PAIR", False);
  /* For properties of font.  */
  dpyinfo->Xatom_PIXEL_SIZE
    = XInternAtom (dpyinfo->display, "PIXEL_SIZE", False);
  dpyinfo->Xatom_MULE_BASELINE_OFFSET
    = XInternAtom (dpyinfo->display, "_MULE_BASELINE_OFFSET", False);
  dpyinfo->Xatom_MULE_RELATIVE_COMPOSE
    = XInternAtom (dpyinfo->display, "_MULE_RELATIVE_COMPOSE", False);
  dpyinfo->Xatom_MULE_DEFAULT_ASCENT
    = XInternAtom (dpyinfo->display, "_MULE_DEFAULT_ASCENT", False);

  dpyinfo->cut_buffers_initialized = 0;

  connection = ConnectionNumber (dpyinfo->display);
  dpyinfo->connection = connection;

  {
    char null_bits[1];

    null_bits[0] = 0x00;

    dpyinfo->null_pixel
      = XCreatePixmapFromBitmapData (dpyinfo->display, dpyinfo->root_window, 
				     null_bits, 1, 1, (long) 0, (long) 0,
				     1);
  }

#ifdef subprocesses
  /* This is only needed for distinguishing keyboard and process input.  */
  if (connection != 0)
    add_keyboard_wait_descriptor (connection);
#endif

#ifndef F_SETOWN_BUG
#ifdef F_SETOWN
#ifdef F_SETOWN_SOCK_NEG
  /* stdin is a socket here */
  fcntl (connection, F_SETOWN, -getpid ());
#else /* ! defined (F_SETOWN_SOCK_NEG) */
  fcntl (connection, F_SETOWN, getpid ());
#endif /* ! defined (F_SETOWN_SOCK_NEG) */
#endif /* ! defined (F_SETOWN) */
#endif /* F_SETOWN_BUG */

#ifdef SIGIO
  if (interrupt_input)
    init_sigio (connection);
#endif /* ! defined (SIGIO) */

#ifdef USE_LUCID
#ifdef HAVE_X11R5 /* It seems X11R4 lacks XtCvtStringToFont, and XPointer.  */
  /* Make sure that we have a valid font for dialog boxes
     so that Xt does not crash.  */
  {
    Display *dpy = dpyinfo->display;
    XrmValue d, fr, to;
    Font font;
    int count;
    
    d.addr = (XPointer)&dpy;
    d.size = sizeof (Display *);
    fr.addr = XtDefaultFont;
    fr.size = sizeof (XtDefaultFont);
    to.size = sizeof (Font *);
    to.addr = (XPointer)&font;
    count = x_catch_errors (dpy);
    if (!XtCallConverter (dpy, XtCvtStringToFont, &d, 1, &fr, &to, NULL))
      abort ();
    if (x_had_errors_p (dpy) || !XQueryFont (dpy, font))
      XrmPutLineResource (&xrdb, "Emacs.dialog.*.font: 9x15");
    x_uncatch_errors (dpy, count);
  }
#endif
#endif


  UNBLOCK_INPUT;

  return dpyinfo;
}

/* Get rid of display DPYINFO, assuming all frames are already gone,
   and without sending any more commands to the X server.  */

void
x_delete_display (dpyinfo)
     struct x_display_info *dpyinfo;
{
  delete_keyboard_wait_descriptor (dpyinfo->connection);

  /* Discard this display from x_display_name_list and x_display_list.
     We can't use Fdelq because that can quit.  */
  if (! NILP (x_display_name_list)
      && EQ (XCONS (x_display_name_list)->car, dpyinfo->name_list_element))
    x_display_name_list = XCONS (x_display_name_list)->cdr;
  else
    {
      Lisp_Object tail;

      tail = x_display_name_list;
      while (CONSP (tail) && CONSP (XCONS (tail)->cdr))
	{
	  if (EQ (XCONS (XCONS (tail)->cdr)->car,
		  dpyinfo->name_list_element))
	    {
	      XCONS (tail)->cdr = XCONS (XCONS (tail)->cdr)->cdr;
	      break;
	    }
	  tail = XCONS (tail)->cdr;
	}
    }

  if (x_display_list == dpyinfo)
    x_display_list = dpyinfo->next;
  else
    {
      struct x_display_info *tail;

      for (tail = x_display_list; tail; tail = tail->next)
	if (tail->next == dpyinfo)
	  tail->next = tail->next->next;
    }

#ifndef USE_X_TOOLKIT   /* I'm told Xt does this itself.  */
#ifndef AIX		/* On AIX, XCloseDisplay calls this.  */
  XrmDestroyDatabase (dpyinfo->xrdb);
#endif
#endif
#ifdef MULTI_KBOARD
  if (--dpyinfo->kboard->reference_count == 0)
    delete_kboard (dpyinfo->kboard);
#endif
  xfree (dpyinfo->font_table);
  xfree (dpyinfo->x_id_name);
  xfree (dpyinfo);
}

/* Set up use of X before we make the first connection.  */

void
x_initialize ()
{
  clear_frame_hook = XTclear_frame;
  clear_end_of_line_hook = XTclear_end_of_line;
  ins_del_lines_hook = XTins_del_lines;
  change_line_highlight_hook = XTchange_line_highlight;
  insert_glyphs_hook = XTinsert_glyphs;
  write_glyphs_hook = XTwrite_glyphs;
  delete_glyphs_hook = XTdelete_glyphs;
  ring_bell_hook = XTring_bell;
  reset_terminal_modes_hook = XTreset_terminal_modes;
  set_terminal_modes_hook = XTset_terminal_modes;
  update_begin_hook = XTupdate_begin;
  update_end_hook = XTupdate_end;
  set_terminal_window_hook = XTset_terminal_window;
  read_socket_hook = XTread_socket;
  frame_up_to_date_hook = XTframe_up_to_date;
  cursor_to_hook = XTcursor_to;
  reassert_line_highlight_hook = XTreassert_line_highlight;
  mouse_position_hook = XTmouse_position;
  frame_rehighlight_hook = XTframe_rehighlight;
  frame_raise_lower_hook = XTframe_raise_lower;
  set_vertical_scroll_bar_hook = XTset_vertical_scroll_bar;
  condemn_scroll_bars_hook = XTcondemn_scroll_bars;
  redeem_scroll_bar_hook = XTredeem_scroll_bar;
  judge_scroll_bars_hook = XTjudge_scroll_bars;

  scroll_region_ok = 1;		/* we'll scroll partial frames */
  char_ins_del_ok = 0;		/* just as fast to write the line */
  line_ins_del_ok = 1;		/* we'll just blt 'em */
  fast_clear_end_of_line = 1;	/* X does this well */
  memory_below_frame = 0;	/* we don't remember what scrolls
				   off the bottom */
  baud_rate = 19200;

  x_noop_count = 0;

  /* Try to use interrupt input; if we can't, then start polling.  */
  Fset_input_mode (Qt, Qnil, Qt, Qnil);

#ifdef USE_X_TOOLKIT
  XtToolkitInitialize ();
  Xt_app_con = XtCreateApplicationContext ();
  XtAppSetFallbackResources (Xt_app_con, Xt_default_resources);
#endif

  /* Note that there is no real way portable across R3/R4 to get the
     original error handler.  */
  XSetErrorHandler (x_error_handler);
  XSetIOErrorHandler (x_io_error_quitter);

  /* Disable Window Change signals;  they are handled by X events. */
#ifdef SIGWINCH
  signal (SIGWINCH, SIG_DFL);
#endif /* ! defined (SIGWINCH) */

  signal (SIGPIPE, x_connection_signal);
}

void
syms_of_xterm ()
{
  staticpro (&x_error_message_string);
  x_error_message_string = Qnil;

  staticpro (&x_display_name_list);
  x_display_name_list = Qnil;

  staticpro (&last_mouse_scroll_bar);
  last_mouse_scroll_bar = Qnil;

  staticpro (&Qvendor_specific_keysyms);
  Qvendor_specific_keysyms = intern ("vendor-specific-keysyms");

  staticpro (&last_mouse_press_frame);
  last_mouse_press_frame = Qnil;
}

#endif /* not HAVE_X_WINDOWS */
