/* Functions for the X window system.
   Copyright (C) 1989, 92, 93, 94, 95, 96, 1997 Free Software Foundation.

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

/* Completely rewritten by Richard Stallman.  */

/* Rewritten for X11 by Joseph Arceneaux */

#include <signal.h>
#include <config.h>

/* This makes the fields of a Display accessible, in Xlib header files.  */
#define XLIB_ILLEGAL_ACCESS

#include "lisp.h"
#include "xterm.h"
#include "frame.h"
#include "window.h"
#include "buffer.h"
#include "dispextern.h"
#include "keyboard.h"
#include "blockinput.h"
#include <epaths.h>
#include "charset.h"
#include "fontset.h"

#ifdef HAVE_X_WINDOWS
extern void abort ();

/* On some systems, the character-composition stuff is broken in X11R5.  */
#if defined (HAVE_X11R5) && ! defined (HAVE_X11R6)
#ifdef X11R5_INHIBIT_I18N
#define X_I18N_INHIBITED
#endif
#endif

#ifndef VMS
#if 1 /* Used to be #ifdef EMACS_BITMAP_FILES, but this should always work.  */
#include "bitmaps/gray.xbm"
#else
#include <X11/bitmaps/gray>
#endif
#else
#include "[.bitmaps]gray.xbm"
#endif

#ifdef USE_X_TOOLKIT
#include <X11/Shell.h>

#ifndef USE_MOTIF
#include <X11/Xaw/Paned.h>
#include <X11/Xaw/Label.h>
#endif /* USE_MOTIF */

#ifdef USG
#undef USG	/* ####KLUDGE for Solaris 2.2 and up */
#include <X11/Xos.h>
#define USG
#else
#include <X11/Xos.h>
#endif

#include "widget.h"

#include "../lwlib/lwlib.h"

/* Do the EDITRES protocol if running X11R5
   Exception: HP-UX (at least version A.09.05) has X11R5 without EditRes */
#if (XtSpecificationRelease >= 5) && !defined(NO_EDITRES)
#define HACK_EDITRES
extern void _XEditResCheckMessages ();
#endif /* R5 + Athena */

/* Unique id counter for widgets created by the Lucid Widget
   Library.  */
extern LWLIB_ID widget_id_tick;

#ifdef USE_LUCID
/* This is part of a kludge--see lwlib/xlwmenu.c.  */
extern XFontStruct *xlwmenu_default_font;
#endif

extern void free_frame_menubar ();
#endif /* USE_X_TOOLKIT */

#define min(a,b) ((a) < (b) ? (a) : (b))
#define max(a,b) ((a) > (b) ? (a) : (b))

#ifdef HAVE_X11R4
#define MAXREQUEST(dpy) (XMaxRequestSize (dpy))
#else
#define MAXREQUEST(dpy) ((dpy)->max_request_size)
#endif

/* The name we're using in resource queries.  Most often "emacs".  */
Lisp_Object Vx_resource_name;

/* The application class we're using in resource queries.
   Normally "Emacs".  */
Lisp_Object Vx_resource_class;

/* The background and shape of the mouse pointer, and shape when not
   over text or in the modeline.  */
Lisp_Object Vx_pointer_shape, Vx_nontext_pointer_shape, Vx_mode_pointer_shape;
/* The shape when over mouse-sensitive text.  */
Lisp_Object Vx_sensitive_text_pointer_shape;

/* Color of chars displayed in cursor box.  */
Lisp_Object Vx_cursor_fore_pixel;

/* Nonzero if using X.  */
static int x_in_use;

/* Non nil if no window manager is in use.  */
Lisp_Object Vx_no_window_manager;

/* Search path for bitmap files.  */
Lisp_Object Vx_bitmap_file_path;

/* Regexp matching a font name whose width is the same as `PIXEL_SIZE'.  */
Lisp_Object Vx_pixel_size_width_font_regexp;

/* Evaluate this expression to rebuild the section of syms_of_xfns
   that initializes and staticpros the symbols declared below.  Note
   that Emacs 18 has a bug that keeps C-x C-e from being able to
   evaluate this expression.

(progn
  ;; Accumulate a list of the symbols we want to initialize from the
  ;; declarations at the top of the file.
  (goto-char (point-min))
  (search-forward "/\*&&& symbols declared here &&&*\/\n")
  (let (symbol-list)
    (while (looking-at "Lisp_Object \\(Q[a-z_]+\\)")
      (setq symbol-list
	    (cons (buffer-substring (match-beginning 1) (match-end 1))
		  symbol-list))
      (forward-line 1))
    (setq symbol-list (nreverse symbol-list))
    ;; Delete the section of syms_of_... where we initialize the symbols.
    (search-forward "\n  /\*&&& init symbols here &&&*\/\n")
    (let ((start (point)))
      (while (looking-at "^  Q")
	(forward-line 2))
      (kill-region start (point)))
    ;; Write a new symbol initialization section.
    (while symbol-list
      (insert (format "  %s = intern (\"" (car symbol-list)))
      (let ((start (point)))
	(insert (substring (car symbol-list) 1))
	(subst-char-in-region start (point) ?_ ?-))
      (insert (format "\");\n  staticpro (&%s);\n" (car symbol-list)))
      (setq symbol-list (cdr symbol-list)))))

  */        

/*&&& symbols declared here &&&*/
Lisp_Object Qauto_raise;
Lisp_Object Qauto_lower;
Lisp_Object Qbackground_color;
Lisp_Object Qbar;
Lisp_Object Qborder_color;
Lisp_Object Qborder_width;
Lisp_Object Qbox;
Lisp_Object Qcursor_color;
Lisp_Object Qcursor_type;
Lisp_Object Qforeground_color;
Lisp_Object Qgeometry;
Lisp_Object Qicon_left;
Lisp_Object Qicon_top;
Lisp_Object Qicon_type;
Lisp_Object Qicon_name;
Lisp_Object Qinternal_border_width;
Lisp_Object Qleft;
Lisp_Object Qright;
Lisp_Object Qmouse_color;
Lisp_Object Qnone;
Lisp_Object Qouter_window_id;
Lisp_Object Qparent_id;
Lisp_Object Qscroll_bar_width;
Lisp_Object Qsuppress_icon;
Lisp_Object Qtop;
Lisp_Object Qundefined_color;
Lisp_Object Qvertical_scroll_bars;
Lisp_Object Qvisibility;
Lisp_Object Qwindow_id;
Lisp_Object Qx_frame_parameter;
Lisp_Object Qx_resource_name;
Lisp_Object Quser_position;
Lisp_Object Quser_size;
Lisp_Object Qdisplay;

/* The below are defined in frame.c.  */
extern Lisp_Object Qheight, Qminibuffer, Qname, Qonly, Qwidth;
extern Lisp_Object Qunsplittable, Qmenu_bar_lines, Qbuffer_predicate, Qtitle;

extern Lisp_Object Vwindow_system_version;

Lisp_Object Qface_set_after_frame_default;

/* Error if we are not connected to X.  */
void
check_x ()
{
  if (! x_in_use)
    error ("X windows are not in use or not initialized");
}

/* Nonzero if we can use mouse menus.
   You should not call this unless HAVE_MENUS is defined.  */

int
have_menus_p ()
{
  return x_in_use;
}

/* Extract a frame as a FRAME_PTR, defaulting to the selected frame
   and checking validity for X.  */

FRAME_PTR
check_x_frame (frame)
     Lisp_Object frame;
{
  FRAME_PTR f;

  if (NILP (frame))
    f = selected_frame;
  else
    {
      CHECK_LIVE_FRAME (frame, 0);
      f = XFRAME (frame);
    }
  if (! FRAME_X_P (f))
    error ("Non-X frame used");
  return f;
}

/* Let the user specify an X display with a frame.
   nil stands for the selected frame--or, if that is not an X frame,
   the first X display on the list.  */

static struct x_display_info *
check_x_display_info (frame)
     Lisp_Object frame;
{
  if (NILP (frame))
    {
      if (FRAME_X_P (selected_frame)
	  && FRAME_LIVE_P (selected_frame))
	return FRAME_X_DISPLAY_INFO (selected_frame);
      else if (x_display_list != 0)
	return x_display_list;
      else
	error ("X windows are not in use or not initialized");
    }
  else if (STRINGP (frame))
    return x_display_info_for_name (frame);
  else
    {
      FRAME_PTR f;

      CHECK_LIVE_FRAME (frame, 0);
      f = XFRAME (frame);
      if (! FRAME_X_P (f))
	error ("Non-X frame used");
      return FRAME_X_DISPLAY_INFO (f);
    }
}

/* Return the Emacs frame-object corresponding to an X window.
   It could be the frame's main window or an icon window.  */

/* This function can be called during GC, so use GC_xxx type test macros.  */

struct frame *
x_window_to_frame (dpyinfo, wdesc)
     struct x_display_info *dpyinfo;
     int wdesc;
{
  Lisp_Object tail, frame;
  struct frame *f;

  for (tail = Vframe_list; GC_CONSP (tail); tail = XCONS (tail)->cdr)
    {
      frame = XCONS (tail)->car;
      if (!GC_FRAMEP (frame))
        continue;
      f = XFRAME (frame);
      if (f->output_data.nothing == 1 || FRAME_X_DISPLAY_INFO (f) != dpyinfo)
	continue;
#ifdef USE_X_TOOLKIT
      if ((f->output_data.x->edit_widget 
	   && XtWindow (f->output_data.x->edit_widget) == wdesc)
          || f->output_data.x->icon_desc == wdesc)
        return f;
#else /* not USE_X_TOOLKIT */
      if (FRAME_X_WINDOW (f) == wdesc
          || f->output_data.x->icon_desc == wdesc)
        return f;
#endif /* not USE_X_TOOLKIT */
    }
  return 0;
}

#ifdef USE_X_TOOLKIT
/* Like x_window_to_frame but also compares the window with the widget's
   windows.  */

struct frame *
x_any_window_to_frame (dpyinfo, wdesc)
     struct x_display_info *dpyinfo;
     int wdesc;
{
  Lisp_Object tail, frame;
  struct frame *f;
  struct x_output *x;

  for (tail = Vframe_list; GC_CONSP (tail); tail = XCONS (tail)->cdr)
    {
      frame = XCONS (tail)->car;
      if (!GC_FRAMEP (frame))
        continue;
      f = XFRAME (frame);
      if (f->output_data.nothing == 1 || FRAME_X_DISPLAY_INFO (f) != dpyinfo)
	continue;
      x = f->output_data.x;
      /* This frame matches if the window is any of its widgets.  */
      if (wdesc == XtWindow (x->widget) 
	  || wdesc == XtWindow (x->column_widget) 
	  || wdesc == XtWindow (x->edit_widget))
	return f;
      /* Match if the window is this frame's menubar.  */
      if (lw_window_is_in_menubar (wdesc, x->menubar_widget))
	return f;
    }
  return 0;
}

/* Likewise, but exclude the menu bar widget.  */

struct frame *
x_non_menubar_window_to_frame (dpyinfo, wdesc)
     struct x_display_info *dpyinfo;
     int wdesc;
{
  Lisp_Object tail, frame;
  struct frame *f;
  struct x_output *x;

  for (tail = Vframe_list; GC_CONSP (tail); tail = XCONS (tail)->cdr)
    {
      frame = XCONS (tail)->car;
      if (!GC_FRAMEP (frame))
        continue;
      f = XFRAME (frame);
      if (f->output_data.nothing == 1 || FRAME_X_DISPLAY_INFO (f) != dpyinfo)
	continue;
      x = f->output_data.x;
      /* This frame matches if the window is any of its widgets.  */
      if (wdesc == XtWindow (x->widget) 
	  || wdesc == XtWindow (x->column_widget) 
	  || wdesc == XtWindow (x->edit_widget))
	return f;
    }
  return 0;
}

/* Likewise, but consider only the menu bar widget.  */

struct frame *
x_menubar_window_to_frame (dpyinfo, wdesc)
     struct x_display_info *dpyinfo;
     int wdesc;
{
  Lisp_Object tail, frame;
  struct frame *f;
  struct x_output *x;

  for (tail = Vframe_list; GC_CONSP (tail); tail = XCONS (tail)->cdr)
    {
      frame = XCONS (tail)->car;
      if (!GC_FRAMEP (frame))
        continue;
      f = XFRAME (frame);
      if (f->output_data.nothing == 1 || FRAME_X_DISPLAY_INFO (f) != dpyinfo)
	continue;
      x = f->output_data.x;
      /* Match if the window is this frame's menubar.  */
      if (lw_window_is_in_menubar (wdesc, x->menubar_widget))
	return f;
    }
  return 0;
}

/* Return the frame whose principal (outermost) window is WDESC.
   If WDESC is some other (smaller) window, we return 0.  */

struct frame *
x_top_window_to_frame (dpyinfo, wdesc)
     struct x_display_info *dpyinfo;
     int wdesc;
{
  Lisp_Object tail, frame;
  struct frame *f;
  struct x_output *x;

  for (tail = Vframe_list; GC_CONSP (tail); tail = XCONS (tail)->cdr)
    {
      frame = XCONS (tail)->car;
      if (!GC_FRAMEP (frame))
        continue;
      f = XFRAME (frame);
      if (f->output_data.nothing == 1 || FRAME_X_DISPLAY_INFO (f) != dpyinfo)
	continue;
      x = f->output_data.x;
      /* This frame matches if the window is its topmost widget.  */
      if (wdesc == XtWindow (x->widget))
	return f;
#if 0 /* I don't know why it did this,
	 but it seems logically wrong,
	 and it causes trouble for MapNotify events.  */
      /* Match if the window is this frame's menubar.  */
      if (x->menubar_widget 
	  && wdesc == XtWindow (x->menubar_widget))
	return f;
#endif
    }
  return 0;
}
#endif /* USE_X_TOOLKIT */



/* Code to deal with bitmaps.  Bitmaps are referenced by their bitmap
   id, which is just an int that this section returns.  Bitmaps are
   reference counted so they can be shared among frames.

   Bitmap indices are guaranteed to be > 0, so a negative number can
   be used to indicate no bitmap.

   If you use x_create_bitmap_from_data, then you must keep track of
   the bitmaps yourself.  That is, creating a bitmap from the same
   data more than once will not be caught.  */


/* Functions to access the contents of a bitmap, given an id.  */

int
x_bitmap_height (f, id)
     FRAME_PTR f;
     int id;
{
  return FRAME_X_DISPLAY_INFO (f)->bitmaps[id - 1].height;
}

int
x_bitmap_width (f, id)
     FRAME_PTR f;
     int id;
{
  return FRAME_X_DISPLAY_INFO (f)->bitmaps[id - 1].width;
}

int
x_bitmap_pixmap (f, id)
     FRAME_PTR f;
     int id;
{
  return FRAME_X_DISPLAY_INFO (f)->bitmaps[id - 1].pixmap;
}


/* Allocate a new bitmap record.  Returns index of new record.  */

static int
x_allocate_bitmap_record (f)
     FRAME_PTR f;
{
  struct x_display_info *dpyinfo = FRAME_X_DISPLAY_INFO (f);
  int i;

  if (dpyinfo->bitmaps == NULL)
    {
      dpyinfo->bitmaps_size = 10;
      dpyinfo->bitmaps
	= (struct x_bitmap_record *) xmalloc (dpyinfo->bitmaps_size * sizeof (struct x_bitmap_record));
      dpyinfo->bitmaps_last = 1;
      return 1;
    }

  if (dpyinfo->bitmaps_last < dpyinfo->bitmaps_size)
    return ++dpyinfo->bitmaps_last;

  for (i = 0; i < dpyinfo->bitmaps_size; ++i)
    if (dpyinfo->bitmaps[i].refcount == 0)
      return i + 1;

  dpyinfo->bitmaps_size *= 2;
  dpyinfo->bitmaps
    = (struct x_bitmap_record *) xrealloc (dpyinfo->bitmaps,
					   dpyinfo->bitmaps_size * sizeof (struct x_bitmap_record));
  return ++dpyinfo->bitmaps_last;
}

/* Add one reference to the reference count of the bitmap with id ID.  */

void
x_reference_bitmap (f, id)
     FRAME_PTR f;
     int id;
{
  ++FRAME_X_DISPLAY_INFO (f)->bitmaps[id - 1].refcount;
}

/* Create a bitmap for frame F from a HEIGHT x WIDTH array of bits at BITS.  */

int
x_create_bitmap_from_data (f, bits, width, height)
     struct frame *f;
     char *bits;
     unsigned int width, height;
{
  struct x_display_info *dpyinfo = FRAME_X_DISPLAY_INFO (f);
  Pixmap bitmap;
  int id;

  bitmap = XCreateBitmapFromData (FRAME_X_DISPLAY (f), FRAME_X_WINDOW (f),
				  bits, width, height);

  if (! bitmap)
    return -1;

  id = x_allocate_bitmap_record (f);
  dpyinfo->bitmaps[id - 1].pixmap = bitmap;
  dpyinfo->bitmaps[id - 1].file = NULL;
  dpyinfo->bitmaps[id - 1].refcount = 1;
  dpyinfo->bitmaps[id - 1].depth = 1;
  dpyinfo->bitmaps[id - 1].height = height;
  dpyinfo->bitmaps[id - 1].width = width;

  return id;
}

/* Create bitmap from file FILE for frame F.  */

int
x_create_bitmap_from_file (f, file)
     struct frame *f;
     Lisp_Object file;
{
  struct x_display_info *dpyinfo = FRAME_X_DISPLAY_INFO (f);
  unsigned int width, height;
  Pixmap bitmap;
  int xhot, yhot, result, id;
  Lisp_Object found;
  int fd;
  char *filename;

  /* Look for an existing bitmap with the same name.  */
  for (id = 0; id < dpyinfo->bitmaps_last; ++id)
    {
      if (dpyinfo->bitmaps[id].refcount
	  && dpyinfo->bitmaps[id].file
	  && !strcmp (dpyinfo->bitmaps[id].file, (char *) XSTRING (file)->data))
	{
	  ++dpyinfo->bitmaps[id].refcount;
	  return id + 1;
	}
    }

  /* Search bitmap-file-path for the file, if appropriate.  */
  fd = openp (Vx_bitmap_file_path, file, "", &found, 0);
  if (fd < 0)
    return -1;
  /* XReadBitmapFile won't handle magic file names.  */
  if (fd == 0)
    return -1;
  close (fd);

  filename = (char *) XSTRING (found)->data;

  result = XReadBitmapFile (FRAME_X_DISPLAY (f), FRAME_X_WINDOW (f),
			    filename, &width, &height, &bitmap, &xhot, &yhot);
  if (result != BitmapSuccess)
    return -1;

  id = x_allocate_bitmap_record (f);
  dpyinfo->bitmaps[id - 1].pixmap = bitmap;
  dpyinfo->bitmaps[id - 1].refcount = 1;
  dpyinfo->bitmaps[id - 1].file
    = (char *) xmalloc (STRING_BYTES (XSTRING (file)) + 1);
  dpyinfo->bitmaps[id - 1].depth = 1;
  dpyinfo->bitmaps[id - 1].height = height;
  dpyinfo->bitmaps[id - 1].width = width;
  strcpy (dpyinfo->bitmaps[id - 1].file, XSTRING (file)->data);

  return id;
}

/* Remove reference to bitmap with id number ID.  */

void
x_destroy_bitmap (f, id)
     FRAME_PTR f;
     int id;
{
  struct x_display_info *dpyinfo = FRAME_X_DISPLAY_INFO (f);

  if (id > 0)
    {
      --dpyinfo->bitmaps[id - 1].refcount;
      if (dpyinfo->bitmaps[id - 1].refcount == 0)
	{
	  BLOCK_INPUT;
	  XFreePixmap (FRAME_X_DISPLAY (f), dpyinfo->bitmaps[id - 1].pixmap);
	  if (dpyinfo->bitmaps[id - 1].file)
	    {
	      free (dpyinfo->bitmaps[id - 1].file);
	      dpyinfo->bitmaps[id - 1].file = NULL;
	    }
	  UNBLOCK_INPUT;
	}
    }
}

/* Free all the bitmaps for the display specified by DPYINFO.  */

static void
x_destroy_all_bitmaps (dpyinfo)
     struct x_display_info *dpyinfo;
{
  int i;
  for (i = 0; i < dpyinfo->bitmaps_last; i++)
    if (dpyinfo->bitmaps[i].refcount > 0)
      {
	XFreePixmap (dpyinfo->display, dpyinfo->bitmaps[i].pixmap);
	if (dpyinfo->bitmaps[i].file)
	  free (dpyinfo->bitmaps[i].file);
      }
  dpyinfo->bitmaps_last = 0;
}

/* Connect the frame-parameter names for X frames
   to the ways of passing the parameter values to the window system.

   The name of a parameter, as a Lisp symbol,
   has an `x-frame-parameter' property which is an integer in Lisp
   that is an index in this table.  */

struct x_frame_parm_table
{
  char *name;
  void (*setter)( /* struct frame *frame, Lisp_Object val, oldval */ );
};

void x_set_foreground_color ();
void x_set_background_color ();
void x_set_mouse_color ();
void x_set_cursor_color ();
void x_set_border_color ();
void x_set_cursor_type ();
void x_set_icon_type ();
void x_set_icon_name ();
void x_set_font ();
void x_set_border_width ();
void x_set_internal_border_width ();
void x_explicitly_set_name ();
void x_set_autoraise ();
void x_set_autolower ();
void x_set_vertical_scroll_bars ();
void x_set_visibility ();
void x_set_menu_bar_lines ();
void x_set_scroll_bar_width ();
void x_set_title ();
void x_set_unsplittable ();

static struct x_frame_parm_table x_frame_parms[] =
{
  "auto-raise", x_set_autoraise,
  "auto-lower", x_set_autolower,
  "background-color", x_set_background_color,
  "border-color", x_set_border_color,
  "border-width", x_set_border_width,
  "cursor-color", x_set_cursor_color,
  "cursor-type", x_set_cursor_type,
  "font", x_set_font,
  "foreground-color", x_set_foreground_color,
  "icon-name", x_set_icon_name,
  "icon-type", x_set_icon_type,
  "internal-border-width", x_set_internal_border_width,
  "menu-bar-lines", x_set_menu_bar_lines,
  "mouse-color", x_set_mouse_color,
  "name", x_explicitly_set_name,
  "scroll-bar-width", x_set_scroll_bar_width,
  "title", x_set_title,
  "unsplittable", x_set_unsplittable,
  "vertical-scroll-bars", x_set_vertical_scroll_bars,
  "visibility", x_set_visibility,
};

/* Attach the `x-frame-parameter' properties to
   the Lisp symbol names of parameters relevant to X.  */

void
init_x_parm_symbols ()
{
  int i;

  for (i = 0; i < sizeof (x_frame_parms) / sizeof (x_frame_parms[0]); i++)
    Fput (intern (x_frame_parms[i].name), Qx_frame_parameter,
	  make_number (i));
}

/* Change the parameters of frame F as specified by ALIST.
   If a parameter is not specially recognized, do nothing;
   otherwise call the `x_set_...' function for that parameter.  */

void
x_set_frame_parameters (f, alist)
     FRAME_PTR f;
     Lisp_Object alist;
{
  Lisp_Object tail;

  /* If both of these parameters are present, it's more efficient to
     set them both at once.  So we wait until we've looked at the
     entire list before we set them.  */
  int width, height;

  /* Same here.  */
  Lisp_Object left, top;

  /* Same with these.  */
  Lisp_Object icon_left, icon_top;

  /* Record in these vectors all the parms specified.  */
  Lisp_Object *parms;
  Lisp_Object *values;
  int i;
  int left_no_change = 0, top_no_change = 0;
  int icon_left_no_change = 0, icon_top_no_change = 0;

  struct gcpro gcpro1, gcpro2;

  i = 0;
  for (tail = alist; CONSP (tail); tail = Fcdr (tail))
    i++;

  parms = (Lisp_Object *) alloca (i * sizeof (Lisp_Object));
  values = (Lisp_Object *) alloca (i * sizeof (Lisp_Object));

  /* Extract parm names and values into those vectors.  */

  i = 0;
  for (tail = alist; CONSP (tail); tail = Fcdr (tail))
    {
      Lisp_Object elt, prop, val;

      elt = Fcar (tail);
      parms[i] = Fcar (elt);
      values[i] = Fcdr (elt);
      i++;
    }
  /* TAIL and ALIST are not used again below here.  */
  alist = tail = Qnil;

  GCPRO2 (*parms, *values);
  gcpro1.nvars = i;
  gcpro2.nvars = i;

  /* There is no need to gcpro LEFT, TOP, ICON_LEFT, or ICON_TOP,
     because their values appear in VALUES and strings are not valid.  */
  top = left = Qunbound;
  icon_left = icon_top = Qunbound;

  /* Provide default values for HEIGHT and WIDTH.  */
  if (FRAME_NEW_WIDTH (f))
    width = FRAME_NEW_WIDTH (f);
  else
    width = FRAME_WIDTH (f);

  if (FRAME_NEW_HEIGHT (f))
    height = FRAME_NEW_HEIGHT (f);
  else
    height = FRAME_HEIGHT (f);

  /* Now process them in reverse of specified order.  */
  for (i--; i >= 0; i--)
    {
      Lisp_Object prop, val;

      prop = parms[i];
      val = values[i];

      if (EQ (prop, Qwidth) && NUMBERP (val))
	width = XFASTINT (val);
      else if (EQ (prop, Qheight) && NUMBERP (val))
	height = XFASTINT (val);
      else if (EQ (prop, Qtop))
	top = val;
      else if (EQ (prop, Qleft))
	left = val;
      else if (EQ (prop, Qicon_top))
	icon_top = val;
      else if (EQ (prop, Qicon_left))
	icon_left = val;
      else
	{
	  register Lisp_Object param_index, old_value;

	  param_index = Fget (prop, Qx_frame_parameter);
	  old_value = get_frame_param (f, prop);
	  store_frame_param (f, prop, val);
 	  if (NATNUMP (param_index)
	      && (XFASTINT (param_index)
		  < sizeof (x_frame_parms)/sizeof (x_frame_parms[0])))
	    (*x_frame_parms[XINT (param_index)].setter)(f, val, old_value);
	}
    }

  /* Don't die if just one of these was set.  */
  if (EQ (left, Qunbound))
    {
      left_no_change = 1;
      if (f->output_data.x->left_pos < 0)
	left = Fcons (Qplus, Fcons (make_number (f->output_data.x->left_pos), Qnil));
      else
	XSETINT (left, f->output_data.x->left_pos);
    }
  if (EQ (top, Qunbound))
    {
      top_no_change = 1;
      if (f->output_data.x->top_pos < 0)
	top = Fcons (Qplus, Fcons (make_number (f->output_data.x->top_pos), Qnil));
      else
	XSETINT (top, f->output_data.x->top_pos);
    }

  /* If one of the icon positions was not set, preserve or default it.  */
  if (EQ (icon_left, Qunbound) || ! INTEGERP (icon_left))
    {
      icon_left_no_change = 1;
      icon_left = Fcdr (Fassq (Qicon_left, f->param_alist));
      if (NILP (icon_left))
	XSETINT (icon_left, 0);
    }
  if (EQ (icon_top, Qunbound) || ! INTEGERP (icon_top))
    {
      icon_top_no_change = 1;
      icon_top = Fcdr (Fassq (Qicon_top, f->param_alist));
      if (NILP (icon_top))
	XSETINT (icon_top, 0);
    }

  /* Don't set these parameters unless they've been explicitly
     specified.  The window might be mapped or resized while we're in
     this function, and we don't want to override that unless the lisp
     code has asked for it.

     Don't set these parameters unless they actually differ from the
     window's current parameters; the window may not actually exist
     yet.  */
  {
    Lisp_Object frame;

    check_frame_size (f, &height, &width);

    XSETFRAME (frame, f);

    if (width != FRAME_WIDTH (f)
	|| height != FRAME_HEIGHT (f)
	|| FRAME_NEW_HEIGHT (f) || FRAME_NEW_WIDTH (f))
      Fset_frame_size (frame, make_number (width), make_number (height));

    if ((!NILP (left) || !NILP (top))
	&& ! (left_no_change && top_no_change)
	&& ! (NUMBERP (left) && XINT (left) == f->output_data.x->left_pos
	      && NUMBERP (top) && XINT (top) == f->output_data.x->top_pos))
      {
	int leftpos = 0;
	int toppos = 0;

	/* Record the signs.  */
	f->output_data.x->size_hint_flags &= ~ (XNegative | YNegative);
	if (EQ (left, Qminus))
	  f->output_data.x->size_hint_flags |= XNegative;
	else if (INTEGERP (left))
	  {
	    leftpos = XINT (left);
	    if (leftpos < 0)
	      f->output_data.x->size_hint_flags |= XNegative;
	  }
	else if (CONSP (left) && EQ (XCONS (left)->car, Qminus)
		 && CONSP (XCONS (left)->cdr)
		 && INTEGERP (XCONS (XCONS (left)->cdr)->car))
	  {
	    leftpos = - XINT (XCONS (XCONS (left)->cdr)->car);
	    f->output_data.x->size_hint_flags |= XNegative;
	  }
	else if (CONSP (left) && EQ (XCONS (left)->car, Qplus)
		 && CONSP (XCONS (left)->cdr)
		 && INTEGERP (XCONS (XCONS (left)->cdr)->car))
	  {
	    leftpos = XINT (XCONS (XCONS (left)->cdr)->car);
	  }

	if (EQ (top, Qminus))
	  f->output_data.x->size_hint_flags |= YNegative;
	else if (INTEGERP (top))
	  {
	    toppos = XINT (top);
	    if (toppos < 0)
	      f->output_data.x->size_hint_flags |= YNegative;
	  }
	else if (CONSP (top) && EQ (XCONS (top)->car, Qminus)
		 && CONSP (XCONS (top)->cdr)
		 && INTEGERP (XCONS (XCONS (top)->cdr)->car))
	  {
	    toppos = - XINT (XCONS (XCONS (top)->cdr)->car);
	    f->output_data.x->size_hint_flags |= YNegative;
	  }
	else if (CONSP (top) && EQ (XCONS (top)->car, Qplus)
		 && CONSP (XCONS (top)->cdr)
		 && INTEGERP (XCONS (XCONS (top)->cdr)->car))
	  {
	    toppos = XINT (XCONS (XCONS (top)->cdr)->car);
	  }


	/* Store the numeric value of the position.  */
	f->output_data.x->top_pos = toppos;
	f->output_data.x->left_pos = leftpos;

	f->output_data.x->win_gravity = NorthWestGravity;

	/* Actually set that position, and convert to absolute.  */
	x_set_offset (f, leftpos, toppos, -1);
      }

    if ((!NILP (icon_left) || !NILP (icon_top))
	&& ! (icon_left_no_change && icon_top_no_change))
      x_wm_set_icon_position (f, XINT (icon_left), XINT (icon_top));
  }

  UNGCPRO;
}

/* Store the screen positions of frame F into XPTR and YPTR.
   These are the positions of the containing window manager window,
   not Emacs's own window.  */

void
x_real_positions (f, xptr, yptr)
     FRAME_PTR f;
     int *xptr, *yptr;
{
  int win_x, win_y;
  Window child;

  /* This is pretty gross, but seems to be the easiest way out of
     the problem that arises when restarting window-managers.  */

#ifdef USE_X_TOOLKIT
  Window outer = XtWindow (f->output_data.x->widget);
#else
  Window outer = f->output_data.x->window_desc;
#endif
  Window tmp_root_window;
  Window *tmp_children;
  int tmp_nchildren;

  while (1)
    {
      int count = x_catch_errors (FRAME_X_DISPLAY (f));
      Window outer_window;

      XQueryTree (FRAME_X_DISPLAY (f), outer, &tmp_root_window,
		  &f->output_data.x->parent_desc,
		  &tmp_children, &tmp_nchildren);
      XFree ((char *) tmp_children);

      win_x = win_y = 0;

      /* Find the position of the outside upper-left corner of
	 the inner window, with respect to the outer window.  */
      if (f->output_data.x->parent_desc != FRAME_X_DISPLAY_INFO (f)->root_window)
	outer_window = f->output_data.x->parent_desc;
      else
	outer_window = outer;

      XTranslateCoordinates (FRAME_X_DISPLAY (f),

			     /* From-window, to-window.  */
			     outer_window,
			     FRAME_X_DISPLAY_INFO (f)->root_window,

			     /* From-position, to-position.  */
			     0, 0, &win_x, &win_y,

			     /* Child of win.  */
			     &child);

      /* It is possible for the window returned by the XQueryNotify
	 to become invalid by the time we call XTranslateCoordinates.
	 That can happen when you restart some window managers.
	 If so, we get an error in XTranslateCoordinates.
	 Detect that and try the whole thing over.  */
      if (! x_had_errors_p (FRAME_X_DISPLAY (f)))
	{
	  x_uncatch_errors (FRAME_X_DISPLAY (f), count);
	  break;
	}

      x_uncatch_errors (FRAME_X_DISPLAY (f), count);
    }

  *xptr = win_x - f->output_data.x->border_width;
  *yptr = win_y - f->output_data.x->border_width;
}

/* Insert a description of internally-recorded parameters of frame X
   into the parameter alist *ALISTPTR that is to be given to the user.
   Only parameters that are specific to the X window system
   and whose values are not correctly recorded in the frame's
   param_alist need to be considered here.  */

void
x_report_frame_params (f, alistptr)
     struct frame *f;
     Lisp_Object *alistptr;
{
  char buf[16];
  Lisp_Object tem;

  /* Represent negative positions (off the top or left screen edge)
     in a way that Fmodify_frame_parameters will understand correctly.  */
  XSETINT (tem, f->output_data.x->left_pos);
  if (f->output_data.x->left_pos >= 0)
    store_in_alist (alistptr, Qleft, tem);
  else
    store_in_alist (alistptr, Qleft, Fcons (Qplus, Fcons (tem, Qnil)));

  XSETINT (tem, f->output_data.x->top_pos);
  if (f->output_data.x->top_pos >= 0)
    store_in_alist (alistptr, Qtop, tem);
  else
    store_in_alist (alistptr, Qtop, Fcons (Qplus, Fcons (tem, Qnil)));

  store_in_alist (alistptr, Qborder_width,
       	   make_number (f->output_data.x->border_width));
  store_in_alist (alistptr, Qinternal_border_width,
       	   make_number (f->output_data.x->internal_border_width));
  sprintf (buf, "%ld", (long) FRAME_X_WINDOW (f));
  store_in_alist (alistptr, Qwindow_id,
       	   build_string (buf));
  sprintf (buf, "%ld", (long) FRAME_OUTER_WINDOW (f));
  store_in_alist (alistptr, Qouter_window_id,
       	   build_string (buf));
  store_in_alist (alistptr, Qicon_name, f->icon_name);
  FRAME_SAMPLE_VISIBILITY (f);
  store_in_alist (alistptr, Qvisibility,
		  (FRAME_VISIBLE_P (f) ? Qt
		   : FRAME_ICONIFIED_P (f) ? Qicon : Qnil));
  store_in_alist (alistptr, Qdisplay,
		  XCONS (FRAME_X_DISPLAY_INFO (f)->name_list_element)->car);

  if (f->output_data.x->parent_desc == FRAME_X_DISPLAY_INFO (f)->root_window)
    tem = Qnil;
  else
    XSETFASTINT (tem, f->output_data.x->parent_desc);
  store_in_alist (alistptr, Qparent_id, tem);
}


/* Decide if color named COLOR is valid for the display associated with
   the selected frame; if so, return the rgb values in COLOR_DEF.
   If ALLOC is nonzero, allocate a new colormap cell.  */

int
defined_color (f, color, color_def, alloc)
     FRAME_PTR f;
     char *color;
     XColor *color_def;
     int alloc;
{
  register int status;
  Colormap screen_colormap;
  Display *display = FRAME_X_DISPLAY (f);

  BLOCK_INPUT;
  screen_colormap = DefaultColormap (display, XDefaultScreen (display));

  status = XParseColor (display, screen_colormap, color, color_def);
  if (status && alloc) 
    {
      status = XAllocColor (display, screen_colormap, color_def);
      if (!status)
	{
	  /* If we got to this point, the colormap is full, so we're 
	     going to try and get the next closest color.
	     The algorithm used is a least-squares matching, which is
	     what X uses for closest color matching with StaticColor visuals.  */

	  XColor *cells;
	  int no_cells;
	  int nearest;
	  long nearest_delta, trial_delta;
	  int x;

	  no_cells = XDisplayCells (display, XDefaultScreen (display));
	  cells = (XColor *) alloca (sizeof (XColor) * no_cells);

	  for (x = 0; x < no_cells; x++) 
	    cells[x].pixel = x;

	  XQueryColors (display, screen_colormap, cells, no_cells);
	  nearest = 0;
	  /* I'm assuming CSE so I'm not going to condense this. */
	  nearest_delta = ((((color_def->red >> 8) - (cells[0].red >> 8))
			    * ((color_def->red >> 8) - (cells[0].red >> 8)))
			   +
			   (((color_def->green >> 8) - (cells[0].green >> 8))
			    * ((color_def->green >> 8) - (cells[0].green >> 8)))
			   +
			   (((color_def->blue >> 8) - (cells[0].blue >> 8))
			    * ((color_def->blue >> 8) - (cells[0].blue >> 8))));
	  for (x = 1; x < no_cells; x++) 
	    {
	      trial_delta = ((((color_def->red >> 8) - (cells[x].red >> 8))
			      * ((color_def->red >> 8) - (cells[x].red >> 8)))
			     +
			     (((color_def->green >> 8) - (cells[x].green >> 8))
			      * ((color_def->green >> 8) - (cells[x].green >> 8)))
			     +
			     (((color_def->blue >> 8) - (cells[x].blue >> 8))
			      * ((color_def->blue >> 8) - (cells[x].blue >> 8))));
	      if (trial_delta < nearest_delta) 
		{
		  XColor temp;
		  temp.red = cells[x].red;
		  temp.green = cells[x].green;
		  temp.blue = cells[x].blue;
		  status = XAllocColor (display, screen_colormap, &temp);
		  if (status)
		    {
		      nearest = x;
		      nearest_delta = trial_delta;
		    }
		}
	    }
	  color_def->red = cells[nearest].red;
	  color_def->green = cells[nearest].green;
	  color_def->blue = cells[nearest].blue;
	  status = XAllocColor (display, screen_colormap, color_def);
	}
    }
  UNBLOCK_INPUT;

  if (status)
    return 1;
  else
    return 0;
}

/* Given a string ARG naming a color, compute a pixel value from it
   suitable for screen F.
   If F is not a color screen, return DEF (default) regardless of what
   ARG says.  */

int
x_decode_color (f, arg, def)
     FRAME_PTR f;
     Lisp_Object arg;
     int def;
{
  XColor cdef;

  CHECK_STRING (arg, 0);

  if (strcmp (XSTRING (arg)->data, "black") == 0)
    return BLACK_PIX_DEFAULT (f);
  else if (strcmp (XSTRING (arg)->data, "white") == 0)
    return WHITE_PIX_DEFAULT (f);

  if (FRAME_X_DISPLAY_INFO (f)->n_planes == 1)
    return def;

  /* defined_color is responsible for coping with failures
     by looking for a near-miss.  */
  if (defined_color (f, XSTRING (arg)->data, &cdef, 1))
    return cdef.pixel;

  Fsignal (Qerror, Fcons (build_string ("undefined color"),
			  Fcons (arg, Qnil)));
}

/* Functions called only from `x_set_frame_param'
   to set individual parameters.

   If FRAME_X_WINDOW (f) is 0,
   the frame is being created and its X-window does not exist yet.
   In that case, just record the parameter's new value
   in the standard place; do not attempt to change the window.  */

void
x_set_foreground_color (f, arg, oldval)
     struct frame *f;
     Lisp_Object arg, oldval;
{
  unsigned long pixel
    = x_decode_color (f, arg, BLACK_PIX_DEFAULT (f));

  if (f->output_data.x->foreground_pixel != f->output_data.x->mouse_pixel
      && f->output_data.x->foreground_pixel != f->output_data.x->cursor_pixel
      && f->output_data.x->foreground_pixel != f->output_data.x->cursor_foreground_pixel)
    unload_color (f, f->output_data.x->foreground_pixel);
  f->output_data.x->foreground_pixel = pixel;

  if (FRAME_X_WINDOW (f) != 0)
    {
      BLOCK_INPUT;
      XSetForeground (FRAME_X_DISPLAY (f), f->output_data.x->normal_gc,
		      f->output_data.x->foreground_pixel);
      XSetBackground (FRAME_X_DISPLAY (f), f->output_data.x->reverse_gc,
		      f->output_data.x->foreground_pixel);
      UNBLOCK_INPUT;
      recompute_basic_faces (f);
      if (FRAME_VISIBLE_P (f))
        redraw_frame (f);
    }
}

void
x_set_background_color (f, arg, oldval)
     struct frame *f;
     Lisp_Object arg, oldval;
{
  Pixmap temp;
  int mask;

  unsigned long pixel
    = x_decode_color (f, arg, WHITE_PIX_DEFAULT (f));

  if (f->output_data.x->background_pixel != f->output_data.x->mouse_pixel
      && f->output_data.x->background_pixel != f->output_data.x->cursor_pixel
      && f->output_data.x->background_pixel != f->output_data.x->cursor_foreground_pixel)
    unload_color (f, f->output_data.x->background_pixel);
  f->output_data.x->background_pixel = pixel;

  if (FRAME_X_WINDOW (f) != 0)
    {
      BLOCK_INPUT;
      /* The main frame area.  */
      XSetBackground (FRAME_X_DISPLAY (f), f->output_data.x->normal_gc,
		      f->output_data.x->background_pixel);
      XSetForeground (FRAME_X_DISPLAY (f), f->output_data.x->reverse_gc,
		      f->output_data.x->background_pixel);
      XSetForeground (FRAME_X_DISPLAY (f), f->output_data.x->cursor_gc,
		      f->output_data.x->background_pixel);
      XSetWindowBackground (FRAME_X_DISPLAY (f), FRAME_X_WINDOW (f),
			    f->output_data.x->background_pixel);
      {
	Lisp_Object bar;
	for (bar = FRAME_SCROLL_BARS (f); !NILP (bar);
	     bar = XSCROLL_BAR (bar)->next)
	  XSetWindowBackground (FRAME_X_DISPLAY (f),
				SCROLL_BAR_X_WINDOW (XSCROLL_BAR (bar)),
				f->output_data.x->background_pixel);
      }
      UNBLOCK_INPUT;

      recompute_basic_faces (f);

      if (FRAME_VISIBLE_P (f))
        redraw_frame (f);
    }
}

void
x_set_mouse_color (f, arg, oldval)
     struct frame *f;
     Lisp_Object arg, oldval;
{
  Cursor cursor, nontext_cursor, mode_cursor, cross_cursor;
  int count;
  int mask_color;
  unsigned long pixel = f->output_data.x->mouse_pixel;
  
  if (!EQ (Qnil, arg))
    pixel = x_decode_color (f, arg, BLACK_PIX_DEFAULT (f));

  mask_color = f->output_data.x->background_pixel;
				/* No invisible pointers.  */
  if (mask_color == pixel
      && mask_color == f->output_data.x->background_pixel)
    pixel = f->output_data.x->foreground_pixel;

  if (f->output_data.x->background_pixel != f->output_data.x->mouse_pixel
      && f->output_data.x->foreground_pixel != f->output_data.x->mouse_pixel
      && f->output_data.x->cursor_pixel != f->output_data.x->mouse_pixel
      && f->output_data.x->cursor_foreground_pixel != f->output_data.x->mouse_pixel)
    unload_color (f, f->output_data.x->mouse_pixel);
  f->output_data.x->mouse_pixel = pixel;

  BLOCK_INPUT;

  /* It's not okay to crash if the user selects a screwy cursor.  */
  count = x_catch_errors (FRAME_X_DISPLAY (f));

  if (!EQ (Qnil, Vx_pointer_shape))
    {
      CHECK_NUMBER (Vx_pointer_shape, 0);
      cursor = XCreateFontCursor (FRAME_X_DISPLAY (f), XINT (Vx_pointer_shape));
    }
  else
    cursor = XCreateFontCursor (FRAME_X_DISPLAY (f), XC_xterm);
  x_check_errors (FRAME_X_DISPLAY (f), "bad text pointer cursor: %s");

  if (!EQ (Qnil, Vx_nontext_pointer_shape))
    {
      CHECK_NUMBER (Vx_nontext_pointer_shape, 0);
      nontext_cursor = XCreateFontCursor (FRAME_X_DISPLAY (f),
					  XINT (Vx_nontext_pointer_shape));
    }
  else
    nontext_cursor = XCreateFontCursor (FRAME_X_DISPLAY (f), XC_left_ptr);
  x_check_errors (FRAME_X_DISPLAY (f), "bad nontext pointer cursor: %s");

  if (!EQ (Qnil, Vx_mode_pointer_shape))
    {
      CHECK_NUMBER (Vx_mode_pointer_shape, 0);
      mode_cursor = XCreateFontCursor (FRAME_X_DISPLAY (f),
				       XINT (Vx_mode_pointer_shape));
    }
  else
    mode_cursor = XCreateFontCursor (FRAME_X_DISPLAY (f), XC_xterm);
  x_check_errors (FRAME_X_DISPLAY (f), "bad modeline pointer cursor: %s");

  if (!EQ (Qnil, Vx_sensitive_text_pointer_shape))
    {
      CHECK_NUMBER (Vx_sensitive_text_pointer_shape, 0);
      cross_cursor
	= XCreateFontCursor (FRAME_X_DISPLAY (f),
			     XINT (Vx_sensitive_text_pointer_shape));
    }
  else
    cross_cursor = XCreateFontCursor (FRAME_X_DISPLAY (f), XC_crosshair);

  /* Check and report errors with the above calls.  */
  x_check_errors (FRAME_X_DISPLAY (f), "can't set cursor shape: %s");
  x_uncatch_errors (FRAME_X_DISPLAY (f), count);

  {
    XColor fore_color, back_color;

    fore_color.pixel = f->output_data.x->mouse_pixel;
    back_color.pixel = mask_color;
    XQueryColor (FRAME_X_DISPLAY (f),
		 DefaultColormap (FRAME_X_DISPLAY (f),
				  DefaultScreen (FRAME_X_DISPLAY (f))),
		 &fore_color);
    XQueryColor (FRAME_X_DISPLAY (f),
		 DefaultColormap (FRAME_X_DISPLAY (f),
				  DefaultScreen (FRAME_X_DISPLAY (f))),
		 &back_color);
    XRecolorCursor (FRAME_X_DISPLAY (f), cursor,
		    &fore_color, &back_color);
    XRecolorCursor (FRAME_X_DISPLAY (f), nontext_cursor,
		    &fore_color, &back_color);
    XRecolorCursor (FRAME_X_DISPLAY (f), mode_cursor,
		    &fore_color, &back_color);
    XRecolorCursor (FRAME_X_DISPLAY (f), cross_cursor,
                    &fore_color, &back_color);
  }

  if (FRAME_X_WINDOW (f) != 0)
    {
      XDefineCursor (FRAME_X_DISPLAY (f), FRAME_X_WINDOW (f), cursor);
    }

  if (cursor != f->output_data.x->text_cursor && f->output_data.x->text_cursor != 0)
    XFreeCursor (FRAME_X_DISPLAY (f), f->output_data.x->text_cursor);
  f->output_data.x->text_cursor = cursor;

  if (nontext_cursor != f->output_data.x->nontext_cursor
      && f->output_data.x->nontext_cursor != 0)
    XFreeCursor (FRAME_X_DISPLAY (f), f->output_data.x->nontext_cursor);
  f->output_data.x->nontext_cursor = nontext_cursor;

  if (mode_cursor != f->output_data.x->modeline_cursor
      && f->output_data.x->modeline_cursor != 0)
    XFreeCursor (FRAME_X_DISPLAY (f), f->output_data.x->modeline_cursor);
  f->output_data.x->modeline_cursor = mode_cursor;
  if (cross_cursor != f->output_data.x->cross_cursor
      && f->output_data.x->cross_cursor != 0)
    XFreeCursor (FRAME_X_DISPLAY (f), f->output_data.x->cross_cursor);
  f->output_data.x->cross_cursor = cross_cursor;

  XFlush (FRAME_X_DISPLAY (f));
  UNBLOCK_INPUT;
}

void
x_set_cursor_color (f, arg, oldval)
     struct frame *f;
     Lisp_Object arg, oldval;
{
  unsigned long fore_pixel, pixel;

  if (!EQ (Vx_cursor_fore_pixel, Qnil))
    fore_pixel = x_decode_color (f, Vx_cursor_fore_pixel,
				 WHITE_PIX_DEFAULT (f));
  else
    fore_pixel = f->output_data.x->background_pixel;
  pixel = x_decode_color (f, arg, BLACK_PIX_DEFAULT (f));

  /* Make sure that the cursor color differs from the background color.  */
  if (pixel == f->output_data.x->background_pixel)
    {
      pixel = f->output_data.x->mouse_pixel;
      if (pixel == fore_pixel)
	fore_pixel = f->output_data.x->background_pixel;
    }

  if (f->output_data.x->background_pixel != f->output_data.x->cursor_foreground_pixel
      && f->output_data.x->foreground_pixel != f->output_data.x->cursor_foreground_pixel
      && f->output_data.x->mouse_pixel != f->output_data.x->cursor_foreground_pixel
      && f->output_data.x->cursor_pixel != f->output_data.x->cursor_foreground_pixel)
    unload_color (f, f->output_data.x->cursor_foreground_pixel);
  f->output_data.x->cursor_foreground_pixel = fore_pixel;

  if (f->output_data.x->background_pixel != f->output_data.x->cursor_pixel
      && f->output_data.x->foreground_pixel != f->output_data.x->cursor_pixel
      && f->output_data.x->mouse_pixel != f->output_data.x->cursor_pixel
      && f->output_data.x->cursor_foreground_pixel != f->output_data.x->cursor_pixel)
    unload_color (f, f->output_data.x->cursor_pixel);
  f->output_data.x->cursor_pixel = pixel;

  if (FRAME_X_WINDOW (f) != 0)
    {
      BLOCK_INPUT;
      XSetBackground (FRAME_X_DISPLAY (f), f->output_data.x->cursor_gc,
		      f->output_data.x->cursor_pixel);
      XSetForeground (FRAME_X_DISPLAY (f), f->output_data.x->cursor_gc,
		      fore_pixel);
      UNBLOCK_INPUT;

      if (FRAME_VISIBLE_P (f))
	{
	  x_update_cursor (f, 0);
	  x_update_cursor (f, 1);
	}
    }
}

/* Set the border-color of frame F to value described by ARG.
   ARG can be a string naming a color.
   The border-color is used for the border that is drawn by the X server.
   Note that this does not fully take effect if done before
   F has an x-window; it must be redone when the window is created.

   Note: this is done in two routines because of the way X10 works.

   Note: under X11, this is normally the province of the window manager,
   and so emacs' border colors may be overridden.  */

void
x_set_border_color (f, arg, oldval)
     struct frame *f;
     Lisp_Object arg, oldval;
{
  unsigned char *str;
  int pix;

  CHECK_STRING (arg, 0);
  str = XSTRING (arg)->data;

  pix = x_decode_color (f, arg, BLACK_PIX_DEFAULT (f));

  x_set_border_pixel (f, pix);
}

/* Set the border-color of frame F to pixel value PIX.
   Note that this does not fully take effect if done before
   F has an x-window.  */

void
x_set_border_pixel (f, pix)
     struct frame *f;
     int pix;
{
  unload_color (f, f->output_data.x->border_pixel);
  f->output_data.x->border_pixel = pix;

  if (FRAME_X_WINDOW (f) != 0 && f->output_data.x->border_width > 0)
    {
      Pixmap temp;
      int mask;

      BLOCK_INPUT;
      XSetWindowBorder (FRAME_X_DISPLAY (f), FRAME_X_WINDOW (f),
			(unsigned long)pix);
      UNBLOCK_INPUT;

      if (FRAME_VISIBLE_P (f))
        redraw_frame (f);
    }
}

void
x_set_cursor_type (f, arg, oldval)
     FRAME_PTR f;
     Lisp_Object arg, oldval;
{
  if (EQ (arg, Qbar))
    {
      FRAME_DESIRED_CURSOR (f) = bar_cursor;
      f->output_data.x->cursor_width = 2;
    }
  else if (CONSP (arg) && EQ (XCONS (arg)->car, Qbar)
	   && INTEGERP (XCONS (arg)->cdr))
    {
      FRAME_DESIRED_CURSOR (f) = bar_cursor;
      f->output_data.x->cursor_width = XINT (XCONS (arg)->cdr);
    }
  else
    /* Treat anything unknown as "box cursor".
       It was bad to signal an error; people have trouble fixing
       .Xdefaults with Emacs, when it has something bad in it.  */
    FRAME_DESIRED_CURSOR (f) = filled_box_cursor;

  /* Make sure the cursor gets redrawn.  This is overkill, but how
     often do people change cursor types?  */
  update_mode_lines++;
}

void
x_set_icon_type (f, arg, oldval)
     struct frame *f;
     Lisp_Object arg, oldval;
{
  Lisp_Object tem;
  int result;

  if (STRINGP (arg))
    {
      if (STRINGP (oldval) && EQ (Fstring_equal (oldval, arg), Qt))
	return;
    }
  else if (!STRINGP (oldval) && EQ (oldval, Qnil) == EQ (arg, Qnil))
    return;

  BLOCK_INPUT;
  if (NILP (arg))
    result = x_text_icon (f,
			  (char *) XSTRING ((!NILP (f->icon_name)
					     ? f->icon_name
					     : f->name))->data);
  else
    result = x_bitmap_icon (f, arg);

  if (result)
    {
      UNBLOCK_INPUT;
      error ("No icon window available");
    }

  XFlush (FRAME_X_DISPLAY (f));
  UNBLOCK_INPUT;
}

/* Return non-nil if frame F wants a bitmap icon.  */

Lisp_Object
x_icon_type (f)
     FRAME_PTR f;
{
  Lisp_Object tem;

  tem = assq_no_quit (Qicon_type, f->param_alist);
  if (CONSP (tem))
    return XCONS (tem)->cdr;
  else
    return Qnil;
}

void
x_set_icon_name (f, arg, oldval)
     struct frame *f;
     Lisp_Object arg, oldval;
{
  Lisp_Object tem;
  int result;

  if (STRINGP (arg))
    {
      if (STRINGP (oldval) && EQ (Fstring_equal (oldval, arg), Qt))
	return;
    }
  else if (!STRINGP (oldval) && EQ (oldval, Qnil) == EQ (arg, Qnil))
    return;

  f->icon_name = arg;

  if (f->output_data.x->icon_bitmap != 0)
    return;

  BLOCK_INPUT;

  result = x_text_icon (f,
			(char *) XSTRING ((!NILP (f->icon_name)
					   ? f->icon_name
					   : !NILP (f->title)
					   ? f->title
					   : f->name))->data);

  if (result)
    {
      UNBLOCK_INPUT;
      error ("No icon window available");
    }

  XFlush (FRAME_X_DISPLAY (f));
  UNBLOCK_INPUT;
}

void
x_set_font (f, arg, oldval)
     struct frame *f;
     Lisp_Object arg, oldval;
{
  Lisp_Object result;
  Lisp_Object fontset_name;
  Lisp_Object frame;

  CHECK_STRING (arg, 1);

  fontset_name = Fquery_fontset (arg, Qnil);

  BLOCK_INPUT;
  result = (STRINGP (fontset_name)
	    ? x_new_fontset (f, XSTRING (fontset_name)->data)
	    : x_new_font (f, XSTRING (arg)->data));
  UNBLOCK_INPUT;
  
  if (EQ (result, Qnil))
    error ("Font `%s' is not defined", XSTRING (arg)->data);
  else if (EQ (result, Qt))
    error ("The characters of the given font have varying widths");
  else if (STRINGP (result))
    {
      recompute_basic_faces (f);
      store_frame_param (f, Qfont, result);
    }
  else
    abort ();

  XSETFRAME (frame, f);
  call1 (Qface_set_after_frame_default, frame);
}

void
x_set_border_width (f, arg, oldval)
     struct frame *f;
     Lisp_Object arg, oldval;
{
  CHECK_NUMBER (arg, 0);

  if (XINT (arg) == f->output_data.x->border_width)
    return;

  if (FRAME_X_WINDOW (f) != 0)
    error ("Cannot change the border width of a window");

  f->output_data.x->border_width = XINT (arg);
}

void
x_set_internal_border_width (f, arg, oldval)
     struct frame *f;
     Lisp_Object arg, oldval;
{
  int mask;
  int old = f->output_data.x->internal_border_width;

  CHECK_NUMBER (arg, 0);
  f->output_data.x->internal_border_width = XINT (arg);
  if (f->output_data.x->internal_border_width < 0)
    f->output_data.x->internal_border_width = 0;

#ifdef USE_X_TOOLKIT
  if (f->output_data.x->edit_widget)
    widget_store_internal_border (f->output_data.x->edit_widget);
#endif

  if (f->output_data.x->internal_border_width == old)
    return;

  if (FRAME_X_WINDOW (f) != 0)
    {
      BLOCK_INPUT;
      x_set_window_size (f, 0, f->width, f->height);
#if 0
      x_set_resize_hint (f);
#endif
      XFlush (FRAME_X_DISPLAY (f));
      UNBLOCK_INPUT;
      SET_FRAME_GARBAGED (f);
    }
}

void
x_set_visibility (f, value, oldval)
     struct frame *f;
     Lisp_Object value, oldval;
{
  Lisp_Object frame;
  XSETFRAME (frame, f);

  if (NILP (value))
    Fmake_frame_invisible (frame, Qt);
  else if (EQ (value, Qicon))
    Ficonify_frame (frame);
  else
    Fmake_frame_visible (frame);
}

static void
x_set_menu_bar_lines_1 (window, n)
  Lisp_Object window;
  int n;
{
  struct window *w = XWINDOW (window);

  XSETFASTINT (w->top, XFASTINT (w->top) + n);
  XSETFASTINT (w->height, XFASTINT (w->height) - n);

  /* Handle just the top child in a vertical split.  */
  if (!NILP (w->vchild))
    x_set_menu_bar_lines_1 (w->vchild, n);

  /* Adjust all children in a horizontal split.  */
  for (window = w->hchild; !NILP (window); window = w->next)
    {
      w = XWINDOW (window);
      x_set_menu_bar_lines_1 (window, n);
    }
}

void
x_set_menu_bar_lines (f, value, oldval)
     struct frame *f;
     Lisp_Object value, oldval;
{
  int nlines;
  int olines = FRAME_MENU_BAR_LINES (f);

  /* Right now, menu bars don't work properly in minibuf-only frames;
     most of the commands try to apply themselves to the minibuffer
     frame itslef, and get an error because you can't switch buffers
     in or split the minibuffer window.  */
  if (FRAME_MINIBUF_ONLY_P (f))
    return;

  if (INTEGERP (value))
    nlines = XINT (value);
  else
    nlines = 0;

  /* Make sure we redisplay all windows in this frame.  */
  windows_or_buffers_changed++;

#ifdef USE_X_TOOLKIT
  FRAME_MENU_BAR_LINES (f) = 0;
  if (nlines)
    {
      FRAME_EXTERNAL_MENU_BAR (f) = 1;
      if (FRAME_X_P (f) && f->output_data.x->menubar_widget == 0)
	/* Make sure next redisplay shows the menu bar.  */
	XWINDOW (FRAME_SELECTED_WINDOW (f))->update_mode_line = Qt;
    }
  else
    {
      if (FRAME_EXTERNAL_MENU_BAR (f) == 1)
	free_frame_menubar (f);
      FRAME_EXTERNAL_MENU_BAR (f) = 0;
      if (FRAME_X_P (f))
	f->output_data.x->menubar_widget = 0;
    }
#else /* not USE_X_TOOLKIT */
  FRAME_MENU_BAR_LINES (f) = nlines;
  x_set_menu_bar_lines_1 (f->root_window, nlines - olines);
#endif /* not USE_X_TOOLKIT */
}

/* Change the name of frame F to NAME.  If NAME is nil, set F's name to
       x_id_name.

   If EXPLICIT is non-zero, that indicates that lisp code is setting the
       name; if NAME is a string, set F's name to NAME and set
       F->explicit_name; if NAME is Qnil, then clear F->explicit_name.

   If EXPLICIT is zero, that indicates that Emacs redisplay code is
       suggesting a new name, which lisp code should override; if
       F->explicit_name is set, ignore the new name; otherwise, set it.  */

void
x_set_name (f, name, explicit)
     struct frame *f;
     Lisp_Object name;
     int explicit;
{
  /* Make sure that requests from lisp code override requests from 
     Emacs redisplay code.  */
  if (explicit)
    {
      /* If we're switching from explicit to implicit, we had better
	 update the mode lines and thereby update the title.  */
      if (f->explicit_name && NILP (name))
	update_mode_lines = 1;

      f->explicit_name = ! NILP (name);
    }
  else if (f->explicit_name)
    return;

  /* If NAME is nil, set the name to the x_id_name.  */
  if (NILP (name))
    {
      /* Check for no change needed in this very common case
	 before we do any consing.  */
      if (!strcmp (FRAME_X_DISPLAY_INFO (f)->x_id_name,
		   XSTRING (f->name)->data))
	return;
      name = build_string (FRAME_X_DISPLAY_INFO (f)->x_id_name);
    }
  else
    CHECK_STRING (name, 0);

  /* Don't change the name if it's already NAME.  */
  if (! NILP (Fstring_equal (name, f->name)))
    return;

  f->name = name;

  /* For setting the frame title, the title parameter should override
     the name parameter.  */
  if (! NILP (f->title))
    name = f->title;

  if (FRAME_X_WINDOW (f))
    {
      BLOCK_INPUT;
#ifdef HAVE_X11R4
      {
	XTextProperty text, icon;
	Lisp_Object icon_name;

	text.value = XSTRING (name)->data;
	text.encoding = XA_STRING;
	text.format = 8;
	text.nitems = STRING_BYTES (XSTRING (name));

	icon_name = (!NILP (f->icon_name) ? f->icon_name : name);

	icon.value = XSTRING (icon_name)->data;
	icon.encoding = XA_STRING;
	icon.format = 8;
	icon.nitems = STRING_BYTES (XSTRING (icon_name));
#ifdef USE_X_TOOLKIT
	XSetWMName (FRAME_X_DISPLAY (f),
		    XtWindow (f->output_data.x->widget), &text);
	XSetWMIconName (FRAME_X_DISPLAY (f), XtWindow (f->output_data.x->widget),
			&icon);
#else /* not USE_X_TOOLKIT */
	XSetWMName (FRAME_X_DISPLAY (f), FRAME_X_WINDOW (f), &text);
	XSetWMIconName (FRAME_X_DISPLAY (f), FRAME_X_WINDOW (f), &icon);
#endif /* not USE_X_TOOLKIT */
      }
#else /* not HAVE_X11R4 */
      XSetIconName (FRAME_X_DISPLAY (f), FRAME_X_WINDOW (f),
		    XSTRING (name)->data);
      XStoreName (FRAME_X_DISPLAY (f), FRAME_X_WINDOW (f),
		  XSTRING (name)->data);
#endif /* not HAVE_X11R4 */
      UNBLOCK_INPUT;
    }
}

/* This function should be called when the user's lisp code has
   specified a name for the frame; the name will override any set by the
   redisplay code.  */
void
x_explicitly_set_name (f, arg, oldval)
     FRAME_PTR f;
     Lisp_Object arg, oldval;
{
  x_set_name (f, arg, 1);
}

/* This function should be called by Emacs redisplay code to set the
   name; names set this way will never override names set by the user's
   lisp code.  */
void
x_implicitly_set_name (f, arg, oldval)
     FRAME_PTR f;
     Lisp_Object arg, oldval;
{
  x_set_name (f, arg, 0);
}

/* Change the title of frame F to NAME.
   If NAME is nil, use the frame name as the title.

   If EXPLICIT is non-zero, that indicates that lisp code is setting the
       name; if NAME is a string, set F's name to NAME and set
       F->explicit_name; if NAME is Qnil, then clear F->explicit_name.

   If EXPLICIT is zero, that indicates that Emacs redisplay code is
       suggesting a new name, which lisp code should override; if
       F->explicit_name is set, ignore the new name; otherwise, set it.  */

void
x_set_title (f, name)
     struct frame *f;
     Lisp_Object name;
{
  /* Don't change the title if it's already NAME.  */
  if (EQ (name, f->title))
    return;

  update_mode_lines = 1;

  f->title = name;

  if (NILP (name))
    name = f->name;
  else
    CHECK_STRING (name, 0);

  if (FRAME_X_WINDOW (f))
    {
      BLOCK_INPUT;
#ifdef HAVE_X11R4
      {
	XTextProperty text, icon;
	Lisp_Object icon_name;

	text.value = XSTRING (name)->data;
	text.encoding = XA_STRING;
	text.format = 8;
	text.nitems = STRING_BYTES (XSTRING (name));

	icon_name = (!NILP (f->icon_name) ? f->icon_name : name);

	icon.value = XSTRING (icon_name)->data;
	icon.encoding = XA_STRING;
	icon.format = 8;
	icon.nitems = STRING_BYTES (XSTRING (icon_name));
#ifdef USE_X_TOOLKIT
	XSetWMName (FRAME_X_DISPLAY (f),
		    XtWindow (f->output_data.x->widget), &text);
	XSetWMIconName (FRAME_X_DISPLAY (f), XtWindow (f->output_data.x->widget),
			&icon);
#else /* not USE_X_TOOLKIT */
	XSetWMName (FRAME_X_DISPLAY (f), FRAME_X_WINDOW (f), &text);
	XSetWMIconName (FRAME_X_DISPLAY (f), FRAME_X_WINDOW (f), &icon);
#endif /* not USE_X_TOOLKIT */
      }
#else /* not HAVE_X11R4 */
      XSetIconName (FRAME_X_DISPLAY (f), FRAME_X_WINDOW (f),
		    XSTRING (name)->data);
      XStoreName (FRAME_X_DISPLAY (f), FRAME_X_WINDOW (f),
		  XSTRING (name)->data);
#endif /* not HAVE_X11R4 */
      UNBLOCK_INPUT;
    }
}

void
x_set_autoraise (f, arg, oldval)
     struct frame *f;
     Lisp_Object arg, oldval;
{
  f->auto_raise = !EQ (Qnil, arg);
}

void
x_set_autolower (f, arg, oldval)
     struct frame *f;
     Lisp_Object arg, oldval;
{
  f->auto_lower = !EQ (Qnil, arg);
}

void
x_set_unsplittable (f, arg, oldval)
     struct frame *f;
     Lisp_Object arg, oldval;
{
  f->no_split = !NILP (arg);
}

void
x_set_vertical_scroll_bars (f, arg, oldval)
     struct frame *f;
     Lisp_Object arg, oldval;
{
  if ((EQ (arg, Qleft) && FRAME_HAS_VERTICAL_SCROLL_BARS_ON_RIGHT (f))
      || (EQ (arg, Qright) && FRAME_HAS_VERTICAL_SCROLL_BARS_ON_LEFT (f))
      || (NILP (arg) && FRAME_HAS_VERTICAL_SCROLL_BARS (f))
      || (!NILP (arg) && ! FRAME_HAS_VERTICAL_SCROLL_BARS (f)))
    {
      FRAME_VERTICAL_SCROLL_BAR_TYPE (f)
	= (NILP (arg)
	   ? vertical_scroll_bar_none
	   : EQ (Qright, arg)
	   ? vertical_scroll_bar_right 
	   : vertical_scroll_bar_left);

      /* We set this parameter before creating the X window for the
	 frame, so we can get the geometry right from the start.
	 However, if the window hasn't been created yet, we shouldn't
	 call x_set_window_size.  */
      if (FRAME_X_WINDOW (f))
	x_set_window_size (f, 0, FRAME_WIDTH (f), FRAME_HEIGHT (f));
    }
}

void
x_set_scroll_bar_width (f, arg, oldval)
     struct frame *f;
     Lisp_Object arg, oldval;
{
  int wid = FONT_WIDTH (f->output_data.x->font);

  if (NILP (arg))
    {
      /* Make the actual width at least 14 pixels
	 and a multiple of a character width.  */
      FRAME_SCROLL_BAR_COLS (f) = (14 + wid - 1) / wid;
      /* Use all of that space (aside from required margins)
	 for the scroll bar.  */
      FRAME_SCROLL_BAR_PIXEL_WIDTH (f) = 0;

      if (FRAME_X_WINDOW (f))
        x_set_window_size (f, 0, FRAME_WIDTH (f), FRAME_HEIGHT (f));
    }
  else if (INTEGERP (arg) && XINT (arg) > 0
	   && XFASTINT (arg) != FRAME_SCROLL_BAR_PIXEL_WIDTH (f))
    {
      if (XFASTINT (arg) <= 2 * VERTICAL_SCROLL_BAR_WIDTH_TRIM)
	XSETINT (arg, 2 * VERTICAL_SCROLL_BAR_WIDTH_TRIM + 1);

      FRAME_SCROLL_BAR_PIXEL_WIDTH (f) = XFASTINT (arg);
      FRAME_SCROLL_BAR_COLS (f) = (XFASTINT (arg) + wid-1) / wid;
      if (FRAME_X_WINDOW (f))
	x_set_window_size (f, 0, FRAME_WIDTH (f), FRAME_HEIGHT (f));
    }

  change_frame_size (f, 0, FRAME_WIDTH (f), 0, 0);
  FRAME_CURSOR_X (f) =  FRAME_LEFT_SCROLL_BAR_WIDTH (f);
}

/* Subroutines of creating an X frame.  */

/* Make sure that Vx_resource_name is set to a reasonable value.
   Fix it up, or set it to `emacs' if it is too hopeless.  */

static void
validate_x_resource_name ()
{
  int len;
  /* Number of valid characters in the resource name.  */
  int good_count = 0;
  /* Number of invalid characters in the resource name.  */
  int bad_count = 0;
  Lisp_Object new;
  int i;

  if (!STRINGP (Vx_resource_class))
    Vx_resource_class = build_string (EMACS_CLASS);

  if (STRINGP (Vx_resource_name))
    {
      unsigned char *p = XSTRING (Vx_resource_name)->data;
      int i;

      len = STRING_BYTES (XSTRING (Vx_resource_name));

      /* Only letters, digits, - and _ are valid in resource names.
	 Count the valid characters and count the invalid ones.  */
      for (i = 0; i < len; i++)
	{
	  int c = p[i];
	  if (! ((c >= 'a' && c <= 'z')
		 || (c >= 'A' && c <= 'Z')
		 || (c >= '0' && c <= '9')
		 || c == '-' || c == '_'))
	    bad_count++;
	  else
	    good_count++;
	}
    }
  else
    /* Not a string => completely invalid.  */
    bad_count = 5, good_count = 0;

  /* If name is valid already, return.  */
  if (bad_count == 0)
    return;

  /* If name is entirely invalid, or nearly so, use `emacs'.  */
  if (good_count == 0
      || (good_count == 1 && bad_count > 0))
    {
      Vx_resource_name = build_string ("emacs");
      return;
    }

  /* Name is partly valid.  Copy it and replace the invalid characters
     with underscores.  */

  Vx_resource_name = new = Fcopy_sequence (Vx_resource_name);

  for (i = 0; i < len; i++)
    {
      int c = XSTRING (new)->data[i];
      if (! ((c >= 'a' && c <= 'z')
	     || (c >= 'A' && c <= 'Z')
	     || (c >= '0' && c <= '9')
	     || c == '-' || c == '_'))
	XSTRING (new)->data[i] = '_';
    }
}


extern char *x_get_string_resource ();

DEFUN ("x-get-resource", Fx_get_resource, Sx_get_resource, 2, 4, 0,
  "Return the value of ATTRIBUTE, of class CLASS, from the X defaults database.\n\
This uses `INSTANCE.ATTRIBUTE' as the key and `Emacs.CLASS' as the\n\
class, where INSTANCE is the name under which Emacs was invoked, or\n\
the name specified by the `-name' or `-rn' command-line arguments.\n\
\n\
The optional arguments COMPONENT and SUBCLASS add to the key and the\n\
class, respectively.  You must specify both of them or neither.\n\
If you specify them, the key is `INSTANCE.COMPONENT.ATTRIBUTE'\n\
and the class is `Emacs.CLASS.SUBCLASS'.")
  (attribute, class, component, subclass)
     Lisp_Object attribute, class, component, subclass;
{
  register char *value;
  char *name_key;
  char *class_key;

  check_x ();

  CHECK_STRING (attribute, 0);
  CHECK_STRING (class, 0);

  if (!NILP (component))
    CHECK_STRING (component, 1);
  if (!NILP (subclass))
    CHECK_STRING (subclass, 2);
  if (NILP (component) != NILP (subclass))
    error ("x-get-resource: must specify both COMPONENT and SUBCLASS or neither");

  validate_x_resource_name ();

  /* Allocate space for the components, the dots which separate them,
     and the final '\0'.  Make them big enough for the worst case.  */
  name_key = (char *) alloca (STRING_BYTES (XSTRING (Vx_resource_name))
			      + (STRINGP (component)
				 ? STRING_BYTES (XSTRING (component)) : 0)
			      + STRING_BYTES (XSTRING (attribute))
			      + 3);

  class_key = (char *) alloca (STRING_BYTES (XSTRING (Vx_resource_class))
			       + STRING_BYTES (XSTRING (class))
			       + (STRINGP (subclass)
				  ? STRING_BYTES (XSTRING (subclass)) : 0)
			       + 3);

  /* Start with emacs.FRAMENAME for the name (the specific one)
     and with `Emacs' for the class key (the general one).  */
  strcpy (name_key, XSTRING (Vx_resource_name)->data);
  strcpy (class_key, XSTRING (Vx_resource_class)->data);

  strcat (class_key, ".");
  strcat (class_key, XSTRING (class)->data);

  if (!NILP (component))
    {
      strcat (class_key, ".");
      strcat (class_key, XSTRING (subclass)->data);

      strcat (name_key, ".");
      strcat (name_key, XSTRING (component)->data);
    }

  strcat (name_key, ".");
  strcat (name_key, XSTRING (attribute)->data);

  value = x_get_string_resource (check_x_display_info (Qnil)->xrdb,
				 name_key, class_key);

  if (value != (char *) 0)
    return build_string (value);
  else
    return Qnil;
}

/* Get an X resource, like Fx_get_resource, but for display DPYINFO.  */

static Lisp_Object
display_x_get_resource (dpyinfo, attribute, class, component, subclass)
     struct x_display_info *dpyinfo;
     Lisp_Object attribute, class, component, subclass;
{
  register char *value;
  char *name_key;
  char *class_key;

  check_x ();

  CHECK_STRING (attribute, 0);
  CHECK_STRING (class, 0);

  if (!NILP (component))
    CHECK_STRING (component, 1);
  if (!NILP (subclass))
    CHECK_STRING (subclass, 2);
  if (NILP (component) != NILP (subclass))
    error ("x-get-resource: must specify both COMPONENT and SUBCLASS or neither");

  validate_x_resource_name ();

  /* Allocate space for the components, the dots which separate them,
     and the final '\0'.  Make them big enough for the worst case.  */
  name_key = (char *) alloca (STRING_BYTES (XSTRING (Vx_resource_name))
			      + (STRINGP (component)
				 ? STRING_BYTES (XSTRING (component)) : 0)
			      + STRING_BYTES (XSTRING (attribute))
			      + 3);

  class_key = (char *) alloca (STRING_BYTES (XSTRING (Vx_resource_class))
			       + STRING_BYTES (XSTRING (class))
			       + (STRINGP (subclass)
				  ? STRING_BYTES (XSTRING (subclass)) : 0)
			       + 3);

  /* Start with emacs.FRAMENAME for the name (the specific one)
     and with `Emacs' for the class key (the general one).  */
  strcpy (name_key, XSTRING (Vx_resource_name)->data);
  strcpy (class_key, XSTRING (Vx_resource_class)->data);

  strcat (class_key, ".");
  strcat (class_key, XSTRING (class)->data);

  if (!NILP (component))
    {
      strcat (class_key, ".");
      strcat (class_key, XSTRING (subclass)->data);

      strcat (name_key, ".");
      strcat (name_key, XSTRING (component)->data);
    }

  strcat (name_key, ".");
  strcat (name_key, XSTRING (attribute)->data);

  value = x_get_string_resource (dpyinfo->xrdb, name_key, class_key);

  if (value != (char *) 0)
    return build_string (value);
  else
    return Qnil;
}

/* Used when C code wants a resource value.  */

char *
x_get_resource_string (attribute, class)
     char *attribute, *class;
{
  register char *value;
  char *name_key;
  char *class_key;

  /* Allocate space for the components, the dots which separate them,
     and the final '\0'.  */
  name_key = (char *) alloca (STRING_BYTES (XSTRING (Vinvocation_name))
			      + strlen (attribute) + 2);
  class_key = (char *) alloca ((sizeof (EMACS_CLASS) - 1)
			       + strlen (class) + 2);

  sprintf (name_key, "%s.%s",
	   XSTRING (Vinvocation_name)->data,
	   attribute);
  sprintf (class_key, "%s.%s", EMACS_CLASS, class);

  return x_get_string_resource (FRAME_X_DISPLAY_INFO (selected_frame)->xrdb,
				name_key, class_key);
}

/* Types we might convert a resource string into.  */
enum resource_types
  {
    number, boolean, string, symbol
  };

/* Return the value of parameter PARAM.

   First search ALIST, then Vdefault_frame_alist, then the X defaults
   database, using ATTRIBUTE as the attribute name and CLASS as its class.

   Convert the resource to the type specified by desired_type.

   If no default is specified, return Qunbound.  If you call
   x_get_arg, make sure you deal with Qunbound in a reasonable way,
   and don't let it get stored in any Lisp-visible variables!  */

static Lisp_Object
x_get_arg (dpyinfo, alist, param, attribute, class, type)
     struct x_display_info *dpyinfo;
     Lisp_Object alist, param;
     char *attribute;
     char *class;
     enum resource_types type;
{
  register Lisp_Object tem;

  tem = Fassq (param, alist);
  if (EQ (tem, Qnil))
    tem = Fassq (param, Vdefault_frame_alist);
  if (EQ (tem, Qnil))
    {

      if (attribute)
	{
	  tem = display_x_get_resource (dpyinfo,
					build_string (attribute),
					build_string (class),
					Qnil, Qnil);

	  if (NILP (tem))
	    return Qunbound;

	  switch (type)
	    {
	    case number:
	      return make_number (atoi (XSTRING (tem)->data));

	    case boolean:
	      tem = Fdowncase (tem);
	      if (!strcmp (XSTRING (tem)->data, "on")
		  || !strcmp (XSTRING (tem)->data, "true"))
		return Qt;
	      else 
		return Qnil;

	    case string:
	      return tem;

	    case symbol:
	      /* As a special case, we map the values `true' and `on'
		 to Qt, and `false' and `off' to Qnil.  */
	      {
		Lisp_Object lower;
		lower = Fdowncase (tem);
		if (!strcmp (XSTRING (lower)->data, "on")
		    || !strcmp (XSTRING (lower)->data, "true"))
		  return Qt;
		else if (!strcmp (XSTRING (lower)->data, "off")
		      || !strcmp (XSTRING (lower)->data, "false"))
		  return Qnil;
		else
		  return Fintern (tem, Qnil);
	      }

	    default:
	      abort ();
	    }
	}
      else
	return Qunbound;
    }
  return Fcdr (tem);
}

/* Like x_get_arg, but also record the value in f->param_alist.  */

static Lisp_Object
x_get_and_record_arg (f, alist, param, attribute, class, type)
     struct frame *f;
     Lisp_Object alist, param;
     char *attribute;
     char *class;
     enum resource_types type;
{
  Lisp_Object value;

  value = x_get_arg (FRAME_X_DISPLAY_INFO (f), alist, param,
		     attribute, class, type);
  if (! NILP (value))
    store_frame_param (f, param, value);

  return value;
}

/* Record in frame F the specified or default value according to ALIST
   of the parameter named PROP (a Lisp symbol).
   If no value is specified for PROP, look for an X default for XPROP
   on the frame named NAME.
   If that is not found either, use the value DEFLT.  */

static Lisp_Object
x_default_parameter (f, alist, prop, deflt, xprop, xclass, type)
     struct frame *f;
     Lisp_Object alist;
     Lisp_Object prop;
     Lisp_Object deflt;
     char *xprop;
     char *xclass;
     enum resource_types type;
{
  Lisp_Object tem;

  tem = x_get_arg (FRAME_X_DISPLAY_INFO (f), alist, prop, xprop, xclass, type);
  if (EQ (tem, Qunbound))
    tem = deflt;
  x_set_frame_parameters (f, Fcons (Fcons (prop, tem), Qnil));
  return tem;
}

DEFUN ("x-parse-geometry", Fx_parse_geometry, Sx_parse_geometry, 1, 1, 0,
       "Parse an X-style geometry string STRING.\n\
Returns an alist of the form ((top . TOP), (left . LEFT) ... ).\n\
The properties returned may include `top', `left', `height', and `width'.\n\
The value of `left' or `top' may be an integer,\n\
or a list (+ N) meaning N pixels relative to top/left corner,\n\
or a list (- N) meaning -N pixels relative to bottom/right corner.")
     (string)
     Lisp_Object string;
{
  int geometry, x, y;
  unsigned int width, height;
  Lisp_Object result;

  CHECK_STRING (string, 0);

  geometry = XParseGeometry ((char *) XSTRING (string)->data,
			     &x, &y, &width, &height);

#if 0
  if (!!(geometry & XValue) != !!(geometry & YValue))
    error ("Must specify both x and y position, or neither");
#endif

  result = Qnil;
  if (geometry & XValue)
    {
      Lisp_Object element;

      if (x >= 0 && (geometry & XNegative))
	element = Fcons (Qleft, Fcons (Qminus, Fcons (make_number (-x), Qnil)));
      else if (x < 0 && ! (geometry & XNegative))
	element = Fcons (Qleft, Fcons (Qplus, Fcons (make_number (x), Qnil)));
      else
	element = Fcons (Qleft, make_number (x));
      result = Fcons (element, result);
    }

  if (geometry & YValue)
    {
      Lisp_Object element;

      if (y >= 0 && (geometry & YNegative))
	element = Fcons (Qtop, Fcons (Qminus, Fcons (make_number (-y), Qnil)));
      else if (y < 0 && ! (geometry & YNegative))
	element = Fcons (Qtop, Fcons (Qplus, Fcons (make_number (y), Qnil)));
      else
	element = Fcons (Qtop, make_number (y));
      result = Fcons (element, result);
    }

  if (geometry & WidthValue)
    result = Fcons (Fcons (Qwidth, make_number (width)), result);
  if (geometry & HeightValue)
    result = Fcons (Fcons (Qheight, make_number (height)), result);

  return result;
}

/* Calculate the desired size and position of this window,
   and return the flags saying which aspects were specified.

   This function does not make the coordinates positive.  */

#define DEFAULT_ROWS 40
#define DEFAULT_COLS 80

static int
x_figure_window_size (f, parms)
     struct frame *f;
     Lisp_Object parms;
{
  register Lisp_Object tem0, tem1, tem2;
  int height, width, left, top;
  register int geometry;
  long window_prompting = 0;
  struct x_display_info *dpyinfo = FRAME_X_DISPLAY_INFO (f);

  /* Default values if we fall through.
     Actually, if that happens we should get
     window manager prompting.  */
  SET_FRAME_WIDTH (f, DEFAULT_COLS);
  f->height = DEFAULT_ROWS;
  /* Window managers expect that if program-specified
     positions are not (0,0), they're intentional, not defaults.  */
  f->output_data.x->top_pos = 0;
  f->output_data.x->left_pos = 0;

  tem0 = x_get_arg (dpyinfo, parms, Qheight, 0, 0, number);
  tem1 = x_get_arg (dpyinfo, parms, Qwidth, 0, 0, number);
  tem2 = x_get_arg (dpyinfo, parms, Quser_size, 0, 0, number);
  if (! EQ (tem0, Qunbound) || ! EQ (tem1, Qunbound))
    {
      if (!EQ (tem0, Qunbound))
	{
	  CHECK_NUMBER (tem0, 0);
	  f->height = XINT (tem0);
	}
      if (!EQ (tem1, Qunbound))
	{
	  CHECK_NUMBER (tem1, 0);
	  SET_FRAME_WIDTH (f, XINT (tem1));
	}
      if (!NILP (tem2) && !EQ (tem2, Qunbound))
	window_prompting |= USSize;
      else
	window_prompting |= PSize;
    }

  f->output_data.x->vertical_scroll_bar_extra
    = (!FRAME_HAS_VERTICAL_SCROLL_BARS (f)
       ? 0
       : FRAME_SCROLL_BAR_PIXEL_WIDTH (f) > 0
       ? FRAME_SCROLL_BAR_PIXEL_WIDTH (f)
       : (FRAME_SCROLL_BAR_COLS (f) * FONT_WIDTH (f->output_data.x->font)));
  f->output_data.x->pixel_width = CHAR_TO_PIXEL_WIDTH (f, f->width);
  f->output_data.x->pixel_height = CHAR_TO_PIXEL_HEIGHT (f, f->height);

  tem0 = x_get_arg (dpyinfo, parms, Qtop, 0, 0, number);
  tem1 = x_get_arg (dpyinfo, parms, Qleft, 0, 0, number);
  tem2 = x_get_arg (dpyinfo, parms, Quser_position, 0, 0, number);
  if (! EQ (tem0, Qunbound) || ! EQ (tem1, Qunbound))
    {
      if (EQ (tem0, Qminus))
	{
	  f->output_data.x->top_pos = 0;
	  window_prompting |= YNegative;
	}
      else if (CONSP (tem0) && EQ (XCONS (tem0)->car, Qminus)
	       && CONSP (XCONS (tem0)->cdr)
	       && INTEGERP (XCONS (XCONS (tem0)->cdr)->car))
	{
	  f->output_data.x->top_pos = - XINT (XCONS (XCONS (tem0)->cdr)->car);
	  window_prompting |= YNegative;
	}
      else if (CONSP (tem0) && EQ (XCONS (tem0)->car, Qplus)
	       && CONSP (XCONS (tem0)->cdr)
	       && INTEGERP (XCONS (XCONS (tem0)->cdr)->car))
	{
	  f->output_data.x->top_pos = XINT (XCONS (XCONS (tem0)->cdr)->car);
	}
      else if (EQ (tem0, Qunbound))
	f->output_data.x->top_pos = 0;
      else
	{
	  CHECK_NUMBER (tem0, 0);
	  f->output_data.x->top_pos = XINT (tem0);
	  if (f->output_data.x->top_pos < 0)
	    window_prompting |= YNegative;
	}

      if (EQ (tem1, Qminus))
	{
	  f->output_data.x->left_pos = 0;
	  window_prompting |= XNegative;
	}
      else if (CONSP (tem1) && EQ (XCONS (tem1)->car, Qminus)
	       && CONSP (XCONS (tem1)->cdr)
	       && INTEGERP (XCONS (XCONS (tem1)->cdr)->car))
	{
	  f->output_data.x->left_pos = - XINT (XCONS (XCONS (tem1)->cdr)->car);
	  window_prompting |= XNegative;
	}
      else if (CONSP (tem1) && EQ (XCONS (tem1)->car, Qplus)
	       && CONSP (XCONS (tem1)->cdr)
	       && INTEGERP (XCONS (XCONS (tem1)->cdr)->car))
	{
	  f->output_data.x->left_pos = XINT (XCONS (XCONS (tem1)->cdr)->car);
	}
      else if (EQ (tem1, Qunbound))
	f->output_data.x->left_pos = 0;
      else
	{
	  CHECK_NUMBER (tem1, 0);
	  f->output_data.x->left_pos = XINT (tem1);
	  if (f->output_data.x->left_pos < 0)
	    window_prompting |= XNegative;
	}

      if (!NILP (tem2) && ! EQ (tem2, Qunbound))
	window_prompting |= USPosition;
      else
	window_prompting |= PPosition;
    }

  return window_prompting;
}

#if !defined (HAVE_X11R4) && !defined (HAVE_XSETWMPROTOCOLS)

Status
XSetWMProtocols (dpy, w, protocols, count)
     Display *dpy;
     Window w;
     Atom *protocols;
     int count;
{
  Atom prop;
  prop = XInternAtom (dpy, "WM_PROTOCOLS", False);
  if (prop == None) return False;
  XChangeProperty (dpy, w, prop, XA_ATOM, 32, PropModeReplace,
		   (unsigned char *) protocols, count);
  return True;
}
#endif /* not HAVE_X11R4 && not HAVE_XSETWMPROTOCOLS */

#ifdef USE_X_TOOLKIT

/* If the WM_PROTOCOLS property does not already contain WM_TAKE_FOCUS,
   WM_DELETE_WINDOW, and WM_SAVE_YOURSELF, then add them.  (They may
   already be present because of the toolkit (Motif adds some of them,
   for example, but Xt doesn't).  */

static void
hack_wm_protocols (f, widget)
     FRAME_PTR f;
     Widget widget;
{
  Display *dpy = XtDisplay (widget);
  Window w = XtWindow (widget);
  int need_delete = 1;
  int need_focus = 1;
  int need_save = 1;

  BLOCK_INPUT;
  {
    Atom type, *atoms = 0;
    int format = 0;
    unsigned long nitems = 0;
    unsigned long bytes_after;

    if ((XGetWindowProperty (dpy, w,
			     FRAME_X_DISPLAY_INFO (f)->Xatom_wm_protocols,
			     (long)0, (long)100, False, XA_ATOM,
			     &type, &format, &nitems, &bytes_after,
			     (unsigned char **) &atoms)
	 == Success)
	&& format == 32 && type == XA_ATOM)
      while (nitems > 0)
	{
	  nitems--;
 	  if (atoms[nitems] == FRAME_X_DISPLAY_INFO (f)->Xatom_wm_delete_window)
	    need_delete = 0;
	  else if (atoms[nitems] == FRAME_X_DISPLAY_INFO (f)->Xatom_wm_take_focus)
	    need_focus = 0;
	  else if (atoms[nitems] == FRAME_X_DISPLAY_INFO (f)->Xatom_wm_save_yourself)
	    need_save = 0;
	}
    if (atoms) XFree ((char *) atoms);
  }
  {
    Atom props [10];
    int count = 0;
    if (need_delete)
      props[count++] = FRAME_X_DISPLAY_INFO (f)->Xatom_wm_delete_window;
    if (need_focus)
      props[count++] = FRAME_X_DISPLAY_INFO (f)->Xatom_wm_take_focus;
    if (need_save)
      props[count++] = FRAME_X_DISPLAY_INFO (f)->Xatom_wm_save_yourself;
    if (count)
      XChangeProperty (dpy, w, FRAME_X_DISPLAY_INFO (f)->Xatom_wm_protocols,
		       XA_ATOM, 32, PropModeAppend,
		       (unsigned char *) props, count);
  }
  UNBLOCK_INPUT;
}
#endif

#ifdef USE_X_TOOLKIT

/* Create and set up the X widget for frame F.  */

static void
x_window (f, window_prompting, minibuffer_only)
     struct frame *f;
     long window_prompting;
     int minibuffer_only;
{
  XClassHint class_hints;
  XSetWindowAttributes attributes;
  unsigned long attribute_mask;

  Widget shell_widget;
  Widget pane_widget;
  Widget frame_widget;
  Arg al [25];
  int ac;

  BLOCK_INPUT;

  /* Use the resource name as the top-level widget name
     for looking up resources.  Make a non-Lisp copy
     for the window manager, so GC relocation won't bother it.

     Elsewhere we specify the window name for the window manager.  */
     
  {
    char *str = (char *) XSTRING (Vx_resource_name)->data;
    f->namebuf = (char *) xmalloc (strlen (str) + 1);
    strcpy (f->namebuf, str);
  }

  ac = 0;
  XtSetArg (al[ac], XtNallowShellResize, 1); ac++;
  XtSetArg (al[ac], XtNinput, 1); ac++;
  XtSetArg (al[ac], XtNmappedWhenManaged, 0); ac++;
  XtSetArg (al[ac], XtNborderWidth, f->output_data.x->border_width); ac++;
  shell_widget = XtAppCreateShell (f->namebuf, EMACS_CLASS,
				   applicationShellWidgetClass,
				   FRAME_X_DISPLAY (f), al, ac);

  f->output_data.x->widget = shell_widget;
  /* maybe_set_screen_title_format (shell_widget); */

  pane_widget = lw_create_widget ("main", "pane", widget_id_tick++,
				  (widget_value *) NULL,
				  shell_widget, False,
				  (lw_callback) NULL,
				  (lw_callback) NULL,
				  (lw_callback) NULL);

  f->output_data.x->column_widget = pane_widget;

  /* mappedWhenManaged to false tells to the paned window to not map/unmap 
     the emacs screen when changing menubar.  This reduces flickering.  */

  ac = 0;
  XtSetArg (al[ac], XtNmappedWhenManaged, 0); ac++;
  XtSetArg (al[ac], XtNshowGrip, 0); ac++;
  XtSetArg (al[ac], XtNallowResize, 1); ac++;
  XtSetArg (al[ac], XtNresizeToPreferred, 1); ac++;
  XtSetArg (al[ac], XtNemacsFrame, f); ac++;
  frame_widget = XtCreateWidget (f->namebuf,
				  emacsFrameClass,
				  pane_widget, al, ac);
 
  f->output_data.x->edit_widget = frame_widget;
 
  XtManageChild (frame_widget); 

  /* Do some needed geometry management.  */
  {
    int len;
    char *tem, shell_position[32];
    Arg al[2];
    int ac = 0;
    int extra_borders = 0;
    int menubar_size 
      = (f->output_data.x->menubar_widget
	 ? (f->output_data.x->menubar_widget->core.height
	    + f->output_data.x->menubar_widget->core.border_width)
	 : 0);
    extern char *lwlib_toolkit_type;

#if 0 /* Experimentally, we now get the right results
	 for -geometry -0-0 without this.  24 Aug 96, rms.  */
    if (FRAME_EXTERNAL_MENU_BAR (f))
      {
        Dimension ibw = 0;
        XtVaGetValues (pane_widget, XtNinternalBorderWidth, &ibw, NULL);
        menubar_size += ibw;
      }
#endif

    f->output_data.x->menubar_height = menubar_size;

#ifndef USE_LUCID
    /* Motif seems to need this amount added to the sizes
       specified for the shell widget.  The Athena/Lucid widgets don't.
       Both conclusions reached experimentally.  -- rms.  */
    XtVaGetValues (f->output_data.x->edit_widget, XtNinternalBorderWidth,
		   &extra_borders, NULL);
    extra_borders *= 2;
#endif

    /* Convert our geometry parameters into a geometry string
       and specify it.
       Note that we do not specify here whether the position
       is a user-specified or program-specified one.
       We pass that information later, in x_wm_set_size_hints.  */
    {
      int left = f->output_data.x->left_pos;
      int xneg = window_prompting & XNegative;
      int top = f->output_data.x->top_pos;
      int yneg = window_prompting & YNegative;
      if (xneg)
	left = -left;
      if (yneg)
	top = -top;

      if (window_prompting & USPosition)
	sprintf (shell_position, "=%dx%d%c%d%c%d",
		 PIXEL_WIDTH (f) + extra_borders, 
		 PIXEL_HEIGHT (f) + menubar_size + extra_borders,
		 (xneg ? '-' : '+'), left,
		 (yneg ? '-' : '+'), top);
      else
	sprintf (shell_position, "=%dx%d",
		 PIXEL_WIDTH (f) + extra_borders, 
		 PIXEL_HEIGHT (f) + menubar_size + extra_borders);
    }

    len = strlen (shell_position) + 1;
    /* We don't free this because we don't know whether
       it is safe to free it while the frame exists.
       It isn't worth the trouble of arranging to free it
       when the frame is deleted.  */
    tem = (char *) xmalloc (len);
    strncpy (tem, shell_position, len);
    XtSetArg (al[ac], XtNgeometry, tem); ac++;
    XtSetValues (shell_widget, al, ac);
  }

  XtManageChild (pane_widget);
  XtRealizeWidget (shell_widget);

  FRAME_X_WINDOW (f) = XtWindow (frame_widget); 

  validate_x_resource_name ();

  class_hints.res_name = (char *) XSTRING (Vx_resource_name)->data;
  class_hints.res_class = (char *) XSTRING (Vx_resource_class)->data;
  XSetClassHint (FRAME_X_DISPLAY (f), XtWindow (shell_widget), &class_hints);

#ifdef HAVE_X_I18N
#ifndef X_I18N_INHIBITED
  { 
    XIM xim;
    XIC xic = NULL;

    xim = XOpenIM (FRAME_X_DISPLAY (f), NULL, NULL, NULL);

    if (xim)
      {
	xic = XCreateIC (xim,  
			 XNInputStyle,   XIMPreeditNothing | XIMStatusNothing,
			 XNClientWindow, FRAME_X_WINDOW(f),
			 XNFocusWindow,  FRAME_X_WINDOW(f),
			 NULL);

	if (xic == 0)
	  {
	    XCloseIM (xim);
	    xim = NULL;
	  }
      }
    FRAME_XIM (f) = xim;
    FRAME_XIC (f) = xic;
  }
#else /* X_I18N_INHIBITED */
  FRAME_XIM (f) = 0;
  FRAME_XIC (f) = 0;
#endif /* X_I18N_INHIBITED */
#endif /* HAVE_X_I18N */

  f->output_data.x->wm_hints.input = True;
  f->output_data.x->wm_hints.flags |= InputHint;
  XSetWMHints (FRAME_X_DISPLAY (f), FRAME_X_WINDOW (f),
	       &f->output_data.x->wm_hints);

  hack_wm_protocols (f, shell_widget);

#ifdef HACK_EDITRES
  XtAddEventHandler (shell_widget, 0, True, _XEditResCheckMessages, 0);
#endif

  /* Do a stupid property change to force the server to generate a
     propertyNotify event so that the event_stream server timestamp will
     be initialized to something relevant to the time we created the window.
     */
  XChangeProperty (XtDisplay (frame_widget), XtWindow (frame_widget),
		   FRAME_X_DISPLAY_INFO (f)->Xatom_wm_protocols,
		   XA_ATOM, 32, PropModeAppend,
		   (unsigned char*) NULL, 0);

 /* Make all the standard events reach the Emacs frame.  */
  attributes.event_mask = STANDARD_EVENT_SET;
  attribute_mask = CWEventMask;
  XChangeWindowAttributes (XtDisplay (shell_widget), XtWindow (shell_widget),
			   attribute_mask, &attributes);

  XtMapWidget (frame_widget);

  /* x_set_name normally ignores requests to set the name if the
     requested name is the same as the current name.  This is the one
     place where that assumption isn't correct; f->name is set, but
     the X server hasn't been told.  */
  {
    Lisp_Object name;
    int explicit = f->explicit_name;

    f->explicit_name = 0;
    name = f->name;
    f->name = Qnil;
    x_set_name (f, name, explicit);
  }

  XDefineCursor (FRAME_X_DISPLAY (f), FRAME_X_WINDOW (f),
		 f->output_data.x->text_cursor);

  UNBLOCK_INPUT;

  if (!minibuffer_only && FRAME_EXTERNAL_MENU_BAR (f))
    initialize_frame_menubar (f);
  lw_set_main_areas (pane_widget, f->output_data.x->menubar_widget, frame_widget);

  if (FRAME_X_WINDOW (f) == 0)
    error ("Unable to create window");
}

#else /* not USE_X_TOOLKIT */

/* Create and set up the X window for frame F.  */

void
x_window (f)
     struct frame *f;

{
  XClassHint class_hints;
  XSetWindowAttributes attributes;
  unsigned long attribute_mask;

  attributes.background_pixel = f->output_data.x->background_pixel;
  attributes.border_pixel = f->output_data.x->border_pixel;
  attributes.bit_gravity = StaticGravity;
  attributes.backing_store = NotUseful;
  attributes.save_under = True;
  attributes.event_mask = STANDARD_EVENT_SET;
  attribute_mask = (CWBackPixel | CWBorderPixel | CWBitGravity
#if 0
		    | CWBackingStore | CWSaveUnder
#endif
		    | CWEventMask);

  BLOCK_INPUT;
  FRAME_X_WINDOW (f)
    = XCreateWindow (FRAME_X_DISPLAY (f),
		     f->output_data.x->parent_desc,
		     f->output_data.x->left_pos,
		     f->output_data.x->top_pos,
		     PIXEL_WIDTH (f), PIXEL_HEIGHT (f),
		     f->output_data.x->border_width,
		     CopyFromParent, /* depth */
		     InputOutput, /* class */
		     FRAME_X_DISPLAY_INFO (f)->visual,
		     attribute_mask, &attributes);
#ifdef HAVE_X_I18N
#ifndef X_I18N_INHIBITED
  { 
    XIM xim;
    XIC xic = NULL;

    xim = XOpenIM (FRAME_X_DISPLAY(f), NULL, NULL, NULL);

    if (xim)
      {
	xic = XCreateIC (xim,  
			 XNInputStyle,   XIMPreeditNothing | XIMStatusNothing,
			 XNClientWindow, FRAME_X_WINDOW(f),
			 XNFocusWindow,  FRAME_X_WINDOW(f),
			 NULL);

	if (!xic)
	  {
	    XCloseIM (xim);
	    xim = NULL;
	  }
      }

    FRAME_XIM (f) = xim;
    FRAME_XIC (f) = xic;
  }
#else /* X_I18N_INHIBITED */
  FRAME_XIM (f) = 0;
  FRAME_XIC (f) = 0;
#endif /* X_I18N_INHIBITED */
#endif /* HAVE_X_I18N */

  validate_x_resource_name ();

  class_hints.res_name = (char *) XSTRING (Vx_resource_name)->data;
  class_hints.res_class = (char *) XSTRING (Vx_resource_class)->data;
  XSetClassHint (FRAME_X_DISPLAY (f), FRAME_X_WINDOW (f), &class_hints);

  /* The menubar is part of the ordinary display;
     it does not count in addition to the height of the window.  */
  f->output_data.x->menubar_height = 0;

  /* This indicates that we use the "Passive Input" input model.
     Unless we do this, we don't get the Focus{In,Out} events that we
     need to draw the cursor correctly.  Accursed bureaucrats.
   XWhipsAndChains (FRAME_X_DISPLAY (f), IronMaiden, &TheRack);  */

  f->output_data.x->wm_hints.input = True;
  f->output_data.x->wm_hints.flags |= InputHint;
  XSetWMHints (FRAME_X_DISPLAY (f), FRAME_X_WINDOW (f),
	       &f->output_data.x->wm_hints);
  f->output_data.x->wm_hints.icon_pixmap = None;

  /* Request "save yourself" and "delete window" commands from wm.  */
  {
    Atom protocols[2];
    protocols[0] = FRAME_X_DISPLAY_INFO (f)->Xatom_wm_delete_window;
    protocols[1] = FRAME_X_DISPLAY_INFO (f)->Xatom_wm_save_yourself;
    XSetWMProtocols (FRAME_X_DISPLAY (f), FRAME_X_WINDOW (f), protocols, 2);
  }

  /* x_set_name normally ignores requests to set the name if the
     requested name is the same as the current name.  This is the one
     place where that assumption isn't correct; f->name is set, but
     the X server hasn't been told.  */
  {
    Lisp_Object name;
    int explicit = f->explicit_name;

    f->explicit_name = 0;
    name = f->name;
    f->name = Qnil;
    x_set_name (f, name, explicit);
  }

  XDefineCursor (FRAME_X_DISPLAY (f), FRAME_X_WINDOW (f),
		 f->output_data.x->text_cursor);

  UNBLOCK_INPUT;

  if (FRAME_X_WINDOW (f) == 0)
    error ("Unable to create window");
}

#endif /* not USE_X_TOOLKIT */

/* Handle the icon stuff for this window.  Perhaps later we might
   want an x_set_icon_position which can be called interactively as
   well.  */

static void
x_icon (f, parms)
     struct frame *f;
     Lisp_Object parms;
{
  Lisp_Object icon_x, icon_y;
  struct x_display_info *dpyinfo = FRAME_X_DISPLAY_INFO (f);

  /* Set the position of the icon.  Note that twm groups all
     icons in an icon window.  */
  icon_x = x_get_and_record_arg (f, parms, Qicon_left, 0, 0, number);
  icon_y = x_get_and_record_arg (f, parms, Qicon_top, 0, 0, number);
  if (!EQ (icon_x, Qunbound) && !EQ (icon_y, Qunbound))
    {
      CHECK_NUMBER (icon_x, 0);
      CHECK_NUMBER (icon_y, 0);
    }
  else if (!EQ (icon_x, Qunbound) || !EQ (icon_y, Qunbound))
    error ("Both left and top icon corners of icon must be specified");

  BLOCK_INPUT;

  if (! EQ (icon_x, Qunbound))
    x_wm_set_icon_position (f, XINT (icon_x), XINT (icon_y));

  /* Start up iconic or window? */
  x_wm_set_window_state
    (f, (EQ (x_get_arg (dpyinfo, parms, Qvisibility, 0, 0, symbol), Qicon)
	 ? IconicState
	 : NormalState));

  x_text_icon (f, (char *) XSTRING ((!NILP (f->icon_name)
				     ? f->icon_name
				     : f->name))->data);

  UNBLOCK_INPUT;
}

/* Make the GC's needed for this window, setting the
   background, border and mouse colors; also create the
   mouse cursor and the gray border tile.  */

static char cursor_bits[] =
  {
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
  };

static void
x_make_gc (f)
     struct frame *f;
{
  XGCValues gc_values;
  GC temp_gc;
  XImage tileimage;

  BLOCK_INPUT;

  /* Create the GC's of this frame.
     Note that many default values are used.  */

  /* Normal video */
  gc_values.font = f->output_data.x->font->fid;
  gc_values.foreground = f->output_data.x->foreground_pixel;
  gc_values.background = f->output_data.x->background_pixel;
  gc_values.line_width = 0;	/* Means 1 using fast algorithm.  */
  f->output_data.x->normal_gc = XCreateGC (FRAME_X_DISPLAY (f),
				       FRAME_X_WINDOW (f),
				       GCLineWidth | GCFont
				       | GCForeground | GCBackground,
				       &gc_values);

  /* Reverse video style.  */
  gc_values.foreground = f->output_data.x->background_pixel;
  gc_values.background = f->output_data.x->foreground_pixel;
  f->output_data.x->reverse_gc = XCreateGC (FRAME_X_DISPLAY (f),
					FRAME_X_WINDOW (f),
					GCFont | GCForeground | GCBackground
					| GCLineWidth,
					&gc_values);

  /* Cursor has cursor-color background, background-color foreground.  */
  gc_values.foreground = f->output_data.x->background_pixel;
  gc_values.background = f->output_data.x->cursor_pixel;
  gc_values.fill_style = FillOpaqueStippled;
  gc_values.stipple
    = XCreateBitmapFromData (FRAME_X_DISPLAY (f),
			     FRAME_X_DISPLAY_INFO (f)->root_window,
			     cursor_bits, 16, 16);
  f->output_data.x->cursor_gc
    = XCreateGC (FRAME_X_DISPLAY (f), FRAME_X_WINDOW (f),
		 (GCFont | GCForeground | GCBackground
		  | GCFillStyle /* | GCStipple */ | GCLineWidth),
		 &gc_values);

  /* Create the gray border tile used when the pointer is not in
     the frame.  Since this depends on the frame's pixel values,
     this must be done on a per-frame basis.  */
  f->output_data.x->border_tile
    = (XCreatePixmapFromBitmapData
       (FRAME_X_DISPLAY (f), FRAME_X_DISPLAY_INFO (f)->root_window, 
	gray_bits, gray_width, gray_height,
	f->output_data.x->foreground_pixel,
	f->output_data.x->background_pixel,
	DefaultDepth (FRAME_X_DISPLAY (f),
		      XScreenNumberOfScreen (FRAME_X_SCREEN (f)))));

  UNBLOCK_INPUT;
}

DEFUN ("x-create-frame", Fx_create_frame, Sx_create_frame,
       1, 1, 0,
  "Make a new X window, which is called a \"frame\" in Emacs terms.\n\
Returns an Emacs frame object.\n\
ALIST is an alist of frame parameters.\n\
If the parameters specify that the frame should not have a minibuffer,\n\
and do not specify a specific minibuffer window to use,\n\
then `default-minibuffer-frame' must be a frame whose minibuffer can\n\
be shared by the new frame.\n\
\n\
This function is an internal primitive--use `make-frame' instead.")
  (parms)
     Lisp_Object parms;
{
  struct frame *f;
  Lisp_Object frame, tem;
  Lisp_Object name;
  int minibuffer_only = 0;
  long window_prompting = 0;
  int width, height;
  int count = specpdl_ptr - specpdl;
  struct gcpro gcpro1, gcpro2, gcpro3, gcpro4;
  Lisp_Object display;
  struct x_display_info *dpyinfo;
  Lisp_Object parent;
  struct kboard *kb;

  check_x ();

  /* Use this general default value to start with
     until we know if this frame has a specified name.  */
  Vx_resource_name = Vinvocation_name;

  display = x_get_arg (dpyinfo, parms, Qdisplay, 0, 0, string);
  if (EQ (display, Qunbound))
    display = Qnil;
  dpyinfo = check_x_display_info (display);
#ifdef MULTI_KBOARD
  kb = dpyinfo->kboard;
#else
  kb = &the_only_kboard;
#endif

  name = x_get_arg (dpyinfo, parms, Qname, "name", "Name", string);
  if (!STRINGP (name)
      && ! EQ (name, Qunbound)
      && ! NILP (name))
    error ("Invalid frame name--not a string or nil");

  if (STRINGP (name))
    Vx_resource_name = name;

  /* See if parent window is specified.  */
  parent = x_get_arg (dpyinfo, parms, Qparent_id, NULL, NULL, number);
  if (EQ (parent, Qunbound))
    parent = Qnil;
  if (! NILP (parent))
    CHECK_NUMBER (parent, 0);

  /* make_frame_without_minibuffer can run Lisp code and garbage collect.  */
  /* No need to protect DISPLAY because that's not used after passing
     it to make_frame_without_minibuffer.  */
  frame = Qnil;
  GCPRO4 (parms, parent, name, frame);
  tem = x_get_arg (dpyinfo, parms, Qminibuffer, "minibuffer", "Minibuffer", symbol);
  if (EQ (tem, Qnone) || NILP (tem))
    f = make_frame_without_minibuffer (Qnil, kb, display);
  else if (EQ (tem, Qonly))
    {
      f = make_minibuffer_frame ();
      minibuffer_only = 1;
    }
  else if (WINDOWP (tem))
    f = make_frame_without_minibuffer (tem, kb, display);
  else
    f = make_frame (1);

  XSETFRAME (frame, f);

  /* Note that X Windows does support scroll bars.  */
  FRAME_CAN_HAVE_SCROLL_BARS (f) = 1;

  f->output_method = output_x_window;
  f->output_data.x = (struct x_output *) xmalloc (sizeof (struct x_output));
  bzero (f->output_data.x, sizeof (struct x_output));
  f->output_data.x->icon_bitmap = -1;
  f->output_data.x->fontset = -1;

  f->icon_name
    = x_get_arg (dpyinfo, parms, Qicon_name, "iconName", "Title", string);
  if (! STRINGP (f->icon_name))
    f->icon_name = Qnil;

  FRAME_X_DISPLAY_INFO (f) = dpyinfo;
#ifdef MULTI_KBOARD
  FRAME_KBOARD (f) = kb;
#endif

  /* Specify the parent under which to make this X window.  */

  if (!NILP (parent))
    {
      f->output_data.x->parent_desc = (Window) XFASTINT (parent);
      f->output_data.x->explicit_parent = 1;
    }
  else
    {
      f->output_data.x->parent_desc = FRAME_X_DISPLAY_INFO (f)->root_window;
      f->output_data.x->explicit_parent = 0;
    }

  /* Note that the frame has no physical cursor right now.  */
  f->phys_cursor_x = -1;

  /* Set the name; the functions to which we pass f expect the name to
     be set.  */
  if (EQ (name, Qunbound) || NILP (name))
    {
      f->name = build_string (dpyinfo->x_id_name);
      f->explicit_name = 0;
    }
  else
    {
      f->name = name;
      f->explicit_name = 1;
      /* use the frame's title when getting resources for this frame.  */
      specbind (Qx_resource_name, name);
    }

  /* Create fontsets from `global_fontset_alist' before handling fonts.  */
  for (tem = Vglobal_fontset_alist; CONSP (tem); tem = XCONS (tem)->cdr)
    fs_register_fontset (f, XCONS (tem)->car);

  /* Extract the window parameters from the supplied values
     that are needed to determine window geometry.  */
  {
    Lisp_Object font;

    font = x_get_arg (dpyinfo, parms, Qfont, "font", "Font", string);

    BLOCK_INPUT;
    /* First, try whatever font the caller has specified.  */
    if (STRINGP (font))
      {
	tem = Fquery_fontset (font, Qnil);
	if (STRINGP (tem))
	  font = x_new_fontset (f, XSTRING (tem)->data);
	else
	  font = x_new_font (f, XSTRING (font)->data);
      }
    /* Try out a font which we hope has bold and italic variations.  */
    if (!STRINGP (font))
      font = x_new_font (f, "-misc-fixed-medium-r-normal-*-*-140-*-*-c-*-iso8859-1");
    if (! STRINGP (font))
      font = x_new_font (f, "-*-*-medium-r-normal-*-*-140-*-*-c-*-iso8859-1");
    if (! STRINGP (font))
      /* This was formerly the first thing tried, but it finds too many fonts
	 and takes too long.  */
      font = x_new_font (f, "-*-*-medium-r-*-*-*-*-*-*-c-*-iso8859-1");
    /* If those didn't work, look for something which will at least work.  */
    if (! STRINGP (font))
      font = x_new_font (f, "-*-fixed-*-*-*-*-*-140-*-*-c-*-iso8859-1");
    UNBLOCK_INPUT;
    if (! STRINGP (font))
      font = build_string ("fixed");

    x_default_parameter (f, parms, Qfont, font,
			 "font", "Font", string);
  }

#ifdef USE_LUCID
  /* Prevent lwlib/xlwmenu.c from crashing because of a bug
     whereby it fails to get any font.  */
  xlwmenu_default_font = f->output_data.x->font;
#endif

  x_default_parameter (f, parms, Qborder_width, make_number (2),
		       "borderWidth", "BorderWidth", number);
  /* This defaults to 2 in order to match xterm.  We recognize either
     internalBorderWidth or internalBorder (which is what xterm calls
     it).  */
  if (NILP (Fassq (Qinternal_border_width, parms)))
    {
      Lisp_Object value;

      value = x_get_arg (dpyinfo, parms, Qinternal_border_width,
			 "internalBorder", "internalBorder", number);
      if (! EQ (value, Qunbound))
	parms = Fcons (Fcons (Qinternal_border_width, value),
		       parms);
    }
  x_default_parameter (f, parms, Qinternal_border_width, make_number (1),
		       "internalBorderWidth", "internalBorderWidth", number);
  x_default_parameter (f, parms, Qvertical_scroll_bars, Qleft,
		       "verticalScrollBars", "ScrollBars", symbol);

  /* Also do the stuff which must be set before the window exists.  */
  x_default_parameter (f, parms, Qforeground_color, build_string ("black"),
		       "foreground", "Foreground", string);
  x_default_parameter (f, parms, Qbackground_color, build_string ("white"),
		       "background", "Background", string);
  x_default_parameter (f, parms, Qmouse_color, build_string ("black"),
		       "pointerColor", "Foreground", string);
  x_default_parameter (f, parms, Qcursor_color, build_string ("black"),
		       "cursorColor", "Foreground", string);
  x_default_parameter (f, parms, Qborder_color, build_string ("black"),
		       "borderColor", "BorderColor", string);

  x_default_parameter (f, parms, Qmenu_bar_lines, make_number (1),
		       "menuBar", "MenuBar", number);
  x_default_parameter (f, parms, Qscroll_bar_width, Qnil,
		       "scrollBarWidth", "ScrollBarWidth", number);
  x_default_parameter (f, parms, Qbuffer_predicate, Qnil,
		       "bufferPredicate", "BufferPredicate", symbol);
  x_default_parameter (f, parms, Qtitle, Qnil,
		       "title", "Title", string);

  f->output_data.x->parent_desc = FRAME_X_DISPLAY_INFO (f)->root_window;
  window_prompting = x_figure_window_size (f, parms);

  if (window_prompting & XNegative)
    {
      if (window_prompting & YNegative)
	f->output_data.x->win_gravity = SouthEastGravity;
      else
	f->output_data.x->win_gravity = NorthEastGravity;
    }
  else
    {
      if (window_prompting & YNegative)
	f->output_data.x->win_gravity = SouthWestGravity;
      else
	f->output_data.x->win_gravity = NorthWestGravity;
    }

  f->output_data.x->size_hint_flags = window_prompting;

#ifdef USE_X_TOOLKIT
  x_window (f, window_prompting, minibuffer_only);
#else
  x_window (f);
#endif
  x_icon (f, parms);
  x_make_gc (f);
  init_frame_faces (f);

  /* We need to do this after creating the X window, so that the
     icon-creation functions can say whose icon they're describing.  */
  x_default_parameter (f, parms, Qicon_type, Qnil,
		       "bitmapIcon", "BitmapIcon", symbol);

  x_default_parameter (f, parms, Qauto_raise, Qnil,
		       "autoRaise", "AutoRaiseLower", boolean);
  x_default_parameter (f, parms, Qauto_lower, Qnil,
		       "autoLower", "AutoRaiseLower", boolean);
  x_default_parameter (f, parms, Qcursor_type, Qbox,
		       "cursorType", "CursorType", symbol);

  /* Dimensions, especially f->height, must be done via change_frame_size.
     Change will not be effected unless different from the current
     f->height.  */
  width = f->width;
  height = f->height;
  f->height = 0;
  SET_FRAME_WIDTH (f, 0);
  change_frame_size (f, height, width, 1, 0);

  /* Tell the server what size and position, etc, we want,
     and how badly we want them.  */
  BLOCK_INPUT;
  x_wm_set_size_hint (f, window_prompting, 0);
  UNBLOCK_INPUT;

  tem = x_get_arg (dpyinfo, parms, Qunsplittable, 0, 0, boolean);
  f->no_split = minibuffer_only || EQ (tem, Qt);

  UNGCPRO;

  /* It is now ok to make the frame official
     even if we get an error below.
     And the frame needs to be on Vframe_list
     or making it visible won't work.  */
  Vframe_list = Fcons (frame, Vframe_list);

  /* Now that the frame is official, it counts as a reference to
     its display.  */
  FRAME_X_DISPLAY_INFO (f)->reference_count++;

  /* Make the window appear on the frame and enable display,
     unless the caller says not to.  However, with explicit parent,
     Emacs cannot control visibility, so don't try.  */
  if (! f->output_data.x->explicit_parent)
    {
      Lisp_Object visibility;

      visibility = x_get_arg (dpyinfo, parms, Qvisibility, 0, 0, symbol);
      if (EQ (visibility, Qunbound))
	visibility = Qt;

      if (EQ (visibility, Qicon))
	x_iconify_frame (f);
      else if (! NILP (visibility))
	x_make_frame_visible (f);
      else
	/* Must have been Qnil.  */
	;
    }

  return unbind_to (count, frame);
}

/* FRAME is used only to get a handle on the X display.  We don't pass the
   display info directly because we're called from frame.c, which doesn't
   know about that structure.  */

Lisp_Object
x_get_focus_frame (frame)
     struct frame *frame;
{
  struct x_display_info *dpyinfo = FRAME_X_DISPLAY_INFO (frame);
  Lisp_Object xfocus;
  if (! dpyinfo->x_focus_frame)
    return Qnil;

  XSETFRAME (xfocus, dpyinfo->x_focus_frame);
  return xfocus;
}

#if 1
#include "x-list-font.c"
#else
DEFUN ("x-list-fonts", Fx_list_fonts, Sx_list_fonts, 1, 4, 0,
  "Return a list of the names of available fonts matching PATTERN.\n\
If optional arguments FACE and FRAME are specified, return only fonts\n\
the same size as FACE on FRAME.\n\
\n\
PATTERN is a string, perhaps with wildcard characters;\n\
  the * character matches any substring, and\n\
  the ? character matches any single character.\n\
  PATTERN is case-insensitive.\n\
FACE is a face name--a symbol.\n\
\n\
The return value is a list of strings, suitable as arguments to\n\
set-face-font.\n\
\n\
Fonts Emacs can't use (i.e. proportional fonts) may or may not be excluded\n\
even if they match PATTERN and FACE.\n\
\n\
The optional fourth argument MAXIMUM sets a limit on how many\n\
fonts to match.  The first MAXIMUM fonts are reported.")
  (pattern, face, frame, maximum)
    Lisp_Object pattern, face, frame, maximum;
{
  int num_fonts;
  char **names;
#ifndef BROKEN_XLISTFONTSWITHINFO
  XFontStruct *info;
#endif
  XFontStruct *size_ref;
  Lisp_Object list;
  FRAME_PTR f;
  Lisp_Object key;
  int maxnames;
  int count;

  check_x ();
  CHECK_STRING (pattern, 0);
  if (!NILP (face))
    CHECK_SYMBOL (face, 1);

  if (NILP (maximum))
    maxnames = 2000;
  else
    {
      CHECK_NATNUM (maximum, 0);
      maxnames = XINT (maximum);
    }

  f = check_x_frame (frame);

  /* Determine the width standard for comparison with the fonts we find.  */

  if (NILP (face))
    size_ref = 0;
  else
    {
      int face_id;

      /* Don't die if we get called with a terminal frame.  */
      if (! FRAME_X_P (f))
	error ("Non-X frame used in `x-list-fonts'");

      face_id = face_name_id_number (f, face);

      if (face_id < 0 || face_id >= FRAME_N_PARAM_FACES (f)
	  || FRAME_PARAM_FACES (f) [face_id] == 0)
	size_ref = f->output_data.x->font;
      else
	{
	  size_ref = FRAME_PARAM_FACES (f) [face_id]->font;
	  if (size_ref == (XFontStruct *) (~0))
	    size_ref = f->output_data.x->font;
	}
    }

  /* See if we cached the result for this particular query.  */
  key = Fcons (pattern, maximum);
  list = Fassoc (key,
		 XCONS (FRAME_X_DISPLAY_INFO (f)->name_list_element)->cdr);

  /* We have info in the cache for this PATTERN.  */
  if (!NILP (list))
    {
      Lisp_Object tem, newlist;

      /* We have info about this pattern.  */
      list = XCONS (list)->cdr;

      if (size_ref == 0)
	return list;

      BLOCK_INPUT;

      /* Filter the cached info and return just the fonts that match FACE.  */
      newlist = Qnil;
      for (tem = list; CONSP (tem); tem = XCONS (tem)->cdr)
	{
	  XFontStruct *thisinfo;

	  count = x_catch_errors (FRAME_X_DISPLAY (f));

	  thisinfo = XLoadQueryFont (FRAME_X_DISPLAY (f),
				     XSTRING (XCONS (tem)->car)->data);

	  x_check_errors (FRAME_X_DISPLAY (f), "XLoadQueryFont failure: %s");
	  x_uncatch_errors (FRAME_X_DISPLAY (f), count);

	  if (thisinfo && same_size_fonts (thisinfo, size_ref))
	    newlist = Fcons (XCONS (tem)->car, newlist);

	  if (thisinfo != 0)
	    XFreeFont (FRAME_X_DISPLAY (f), thisinfo);
        }

      UNBLOCK_INPUT;

      return newlist;
    }

  BLOCK_INPUT;

  count = x_catch_errors (FRAME_X_DISPLAY (f));

  /* Solaris 2.3 has a bug in XListFontsWithInfo.  */
#ifndef BROKEN_XLISTFONTSWITHINFO
  if (size_ref)
    names = XListFontsWithInfo (FRAME_X_DISPLAY (f),
				XSTRING (pattern)->data,
				maxnames, 
				&num_fonts, /* count_return */
				&info); /* info_return */
  else
#endif
    names = XListFonts (FRAME_X_DISPLAY (f),
			XSTRING (pattern)->data,
			maxnames,
			&num_fonts); /* count_return */

  x_check_errors (FRAME_X_DISPLAY (f), "XListFonts failure: %s");
  x_uncatch_errors (FRAME_X_DISPLAY (f), count);

  UNBLOCK_INPUT;

  list = Qnil;

  if (names)
    {
      int i;
      Lisp_Object full_list;

      /* Make a list of all the fonts we got back.
	 Store that in the font cache for the display.  */
      full_list = Qnil;
      for (i = 0; i < num_fonts; i++)
	full_list = Fcons (build_string (names[i]), full_list);
      XCONS (FRAME_X_DISPLAY_INFO (f)->name_list_element)->cdr
	= Fcons (Fcons (key, full_list),
		 XCONS (FRAME_X_DISPLAY_INFO (f)->name_list_element)->cdr);

      /* Make a list of the fonts that have the right width.  */
      list = Qnil;
      for (i = 0; i < num_fonts; i++)
        {
	  int keeper;

	  if (!size_ref)
	    keeper = 1;
	  else
	    {
#ifdef BROKEN_XLISTFONTSWITHINFO
	      XFontStruct *thisinfo;

	      BLOCK_INPUT;

	      count = x_catch_errors (FRAME_X_DISPLAY (f));
	      thisinfo = XLoadQueryFont (FRAME_X_DISPLAY (f), names[i]);
	      x_check_errors (FRAME_X_DISPLAY (f),
			      "XLoadQueryFont failure: %s");
	      x_uncatch_errors (FRAME_X_DISPLAY (f), count);

	      UNBLOCK_INPUT;

	      keeper = thisinfo && same_size_fonts (thisinfo, size_ref);
	      BLOCK_INPUT;
	      if (thisinfo && ! keeper)
		XFreeFont (FRAME_X_DISPLAY (f), thisinfo);
	      else if (thisinfo)
		XFreeFontInfo (NULL, thisinfo, 1);
	      UNBLOCK_INPUT;
#else
	      keeper = same_size_fonts (&info[i], size_ref);
#endif
	    }
          if (keeper)
	    list = Fcons (build_string (names[i]), list);
        }
      list = Fnreverse (list);

      BLOCK_INPUT;
#ifndef BROKEN_XLISTFONTSWITHINFO
      if (size_ref)
	XFreeFontInfo (names, info, num_fonts);
      else
#endif
	XFreeFontNames (names);
      UNBLOCK_INPUT;
    }

  return list;
}
#endif


DEFUN ("x-color-defined-p", Fx_color_defined_p, Sx_color_defined_p, 1, 2, 0,
       "Return non-nil if color COLOR is supported on frame FRAME.\n\
If FRAME is omitted or nil, use the selected frame.")
  (color, frame)
     Lisp_Object color, frame;
{
  XColor foo;
  FRAME_PTR f = check_x_frame (frame);

  CHECK_STRING (color, 1);

  if (defined_color (f, XSTRING (color)->data, &foo, 0))
    return Qt;
  else
    return Qnil;
}

DEFUN ("x-color-values", Fx_color_values, Sx_color_values, 1, 2, 0,
  "Return a description of the color named COLOR on frame FRAME.\n\
The value is a list of integer RGB values--(RED GREEN BLUE).\n\
These values appear to range from 0 to 65280 or 65535, depending\n\
on the system; white is (65280 65280 65280) or (65535 65535 65535).\n\
If FRAME is omitted or nil, use the selected frame.")
  (color, frame)
     Lisp_Object color, frame;
{
  XColor foo;
  FRAME_PTR f = check_x_frame (frame);

  CHECK_STRING (color, 1);

  if (defined_color (f, XSTRING (color)->data, &foo, 0))
    {
      Lisp_Object rgb[3];

      rgb[0] = make_number (foo.red);
      rgb[1] = make_number (foo.green);
      rgb[2] = make_number (foo.blue);
      return Flist (3, rgb);
    }
  else
    return Qnil;
}

DEFUN ("x-display-color-p", Fx_display_color_p, Sx_display_color_p, 0, 1, 0,
  "Return t if the X display supports color.\n\
The optional argument DISPLAY specifies which display to ask about.\n\
DISPLAY should be either a frame or a display name (a string).\n\
If omitted or nil, that stands for the selected frame's display.")
  (display)
     Lisp_Object display;
{
  struct x_display_info *dpyinfo = check_x_display_info (display);

  if (dpyinfo->n_planes <= 2)
    return Qnil;

  switch (dpyinfo->visual->class)
    {
    case StaticColor:
    case PseudoColor:
    case TrueColor:
    case DirectColor:
      return Qt;

    default:
      return Qnil;
    }
}

DEFUN ("x-display-grayscale-p", Fx_display_grayscale_p, Sx_display_grayscale_p,
  0, 1, 0,
  "Return t if the X display supports shades of gray.\n\
Note that color displays do support shades of gray.\n\
The optional argument DISPLAY specifies which display to ask about.\n\
DISPLAY should be either a frame or a display name (a string).\n\
If omitted or nil, that stands for the selected frame's display.")
  (display)
     Lisp_Object display;
{
  struct x_display_info *dpyinfo = check_x_display_info (display);

  if (dpyinfo->n_planes <= 1)
    return Qnil;

  switch (dpyinfo->visual->class)
    {
    case StaticColor:
    case PseudoColor:
    case TrueColor:
    case DirectColor:
    case StaticGray:
    case GrayScale:
      return Qt;

    default:
      return Qnil;
    }
}

DEFUN ("x-display-pixel-width", Fx_display_pixel_width, Sx_display_pixel_width,
  0, 1, 0,
  "Returns the width in pixels of the X display DISPLAY.\n\
The optional argument DISPLAY specifies which display to ask about.\n\
DISPLAY should be either a frame or a display name (a string).\n\
If omitted or nil, that stands for the selected frame's display.")
  (display)
     Lisp_Object display;
{
  struct x_display_info *dpyinfo = check_x_display_info (display);

  return make_number (dpyinfo->width);
}

DEFUN ("x-display-pixel-height", Fx_display_pixel_height,
  Sx_display_pixel_height, 0, 1, 0,
  "Returns the height in pixels of the X display DISPLAY.\n\
The optional argument DISPLAY specifies which display to ask about.\n\
DISPLAY should be either a frame or a display name (a string).\n\
If omitted or nil, that stands for the selected frame's display.")
  (display)
     Lisp_Object display;
{
  struct x_display_info *dpyinfo = check_x_display_info (display);

  return make_number (dpyinfo->height);
}

DEFUN ("x-display-planes", Fx_display_planes, Sx_display_planes,
  0, 1, 0,
  "Returns the number of bitplanes of the X display DISPLAY.\n\
The optional argument DISPLAY specifies which display to ask about.\n\
DISPLAY should be either a frame or a display name (a string).\n\
If omitted or nil, that stands for the selected frame's display.")
  (display)
     Lisp_Object display;
{
  struct x_display_info *dpyinfo = check_x_display_info (display);

  return make_number (dpyinfo->n_planes);
}

DEFUN ("x-display-color-cells", Fx_display_color_cells, Sx_display_color_cells,
  0, 1, 0,
  "Returns the number of color cells of the X display DISPLAY.\n\
The optional argument DISPLAY specifies which display to ask about.\n\
DISPLAY should be either a frame or a display name (a string).\n\
If omitted or nil, that stands for the selected frame's display.")
  (display)
     Lisp_Object display;
{
  struct x_display_info *dpyinfo = check_x_display_info (display);

  return make_number (DisplayCells (dpyinfo->display,
				    XScreenNumberOfScreen (dpyinfo->screen)));
}

DEFUN ("x-server-max-request-size", Fx_server_max_request_size,
       Sx_server_max_request_size,
  0, 1, 0,
  "Returns the maximum request size of the X server of display DISPLAY.\n\
The optional argument DISPLAY specifies which display to ask about.\n\
DISPLAY should be either a frame or a display name (a string).\n\
If omitted or nil, that stands for the selected frame's display.")
  (display)
     Lisp_Object display;
{
  struct x_display_info *dpyinfo = check_x_display_info (display);

  return make_number (MAXREQUEST (dpyinfo->display));
}

DEFUN ("x-server-vendor", Fx_server_vendor, Sx_server_vendor, 0, 1, 0,
  "Returns the vendor ID string of the X server of display DISPLAY.\n\
The optional argument DISPLAY specifies which display to ask about.\n\
DISPLAY should be either a frame or a display name (a string).\n\
If omitted or nil, that stands for the selected frame's display.")
  (display)
     Lisp_Object display;
{
  struct x_display_info *dpyinfo = check_x_display_info (display);
  char *vendor = ServerVendor (dpyinfo->display);

  if (! vendor) vendor = "";
  return build_string (vendor);
}

DEFUN ("x-server-version", Fx_server_version, Sx_server_version, 0, 1, 0,
  "Returns the version numbers of the X server of display DISPLAY.\n\
The value is a list of three integers: the major and minor\n\
version numbers of the X Protocol in use, and the vendor-specific release\n\
number.  See also the function `x-server-vendor'.\n\n\
The optional argument DISPLAY specifies which display to ask about.\n\
DISPLAY should be either a frame or a display name (a string).\n\
If omitted or nil, that stands for the selected frame's display.")
  (display)
     Lisp_Object display;
{
  struct x_display_info *dpyinfo = check_x_display_info (display);
  Display *dpy = dpyinfo->display;

  return Fcons (make_number (ProtocolVersion (dpy)),
		Fcons (make_number (ProtocolRevision (dpy)),
		       Fcons (make_number (VendorRelease (dpy)), Qnil)));
}

DEFUN ("x-display-screens", Fx_display_screens, Sx_display_screens, 0, 1, 0,
  "Returns the number of screens on the X server of display DISPLAY.\n\
The optional argument DISPLAY specifies which display to ask about.\n\
DISPLAY should be either a frame or a display name (a string).\n\
If omitted or nil, that stands for the selected frame's display.")
  (display)
     Lisp_Object display;
{
  struct x_display_info *dpyinfo = check_x_display_info (display);

  return make_number (ScreenCount (dpyinfo->display));
}

DEFUN ("x-display-mm-height", Fx_display_mm_height, Sx_display_mm_height, 0, 1, 0,
  "Returns the height in millimeters of the X display DISPLAY.\n\
The optional argument DISPLAY specifies which display to ask about.\n\
DISPLAY should be either a frame or a display name (a string).\n\
If omitted or nil, that stands for the selected frame's display.")
  (display)
     Lisp_Object display;
{
  struct x_display_info *dpyinfo = check_x_display_info (display);

  return make_number (HeightMMOfScreen (dpyinfo->screen));
}

DEFUN ("x-display-mm-width", Fx_display_mm_width, Sx_display_mm_width, 0, 1, 0,
  "Returns the width in millimeters of the X display DISPLAY.\n\
The optional argument DISPLAY specifies which display to ask about.\n\
DISPLAY should be either a frame or a display name (a string).\n\
If omitted or nil, that stands for the selected frame's display.")
  (display)
     Lisp_Object display;
{
  struct x_display_info *dpyinfo = check_x_display_info (display);

  return make_number (WidthMMOfScreen (dpyinfo->screen));
}

DEFUN ("x-display-backing-store", Fx_display_backing_store,
  Sx_display_backing_store, 0, 1, 0,
  "Returns an indication of whether X display DISPLAY does backing store.\n\
The value may be `always', `when-mapped', or `not-useful'.\n\
The optional argument DISPLAY specifies which display to ask about.\n\
DISPLAY should be either a frame or a display name (a string).\n\
If omitted or nil, that stands for the selected frame's display.")
  (display)
     Lisp_Object display;
{
  struct x_display_info *dpyinfo = check_x_display_info (display);

  switch (DoesBackingStore (dpyinfo->screen))
    {
    case Always:
      return intern ("always");

    case WhenMapped:
      return intern ("when-mapped");

    case NotUseful:
      return intern ("not-useful");

    default:
      error ("Strange value for BackingStore parameter of screen");
    }
}

DEFUN ("x-display-visual-class", Fx_display_visual_class,
  Sx_display_visual_class, 0, 1, 0,
  "Returns the visual class of the X display DISPLAY.\n\
The value is one of the symbols `static-gray', `gray-scale',\n\
`static-color', `pseudo-color', `true-color', or `direct-color'.\n\n\
The optional argument DISPLAY specifies which display to ask about.\n\
DISPLAY should be either a frame or a display name (a string).\n\
If omitted or nil, that stands for the selected frame's display.")
	(display)
     Lisp_Object display;
{
  struct x_display_info *dpyinfo = check_x_display_info (display);

  switch (dpyinfo->visual->class)
    {
    case StaticGray:  return (intern ("static-gray"));
    case GrayScale:   return (intern ("gray-scale"));
    case StaticColor: return (intern ("static-color"));
    case PseudoColor: return (intern ("pseudo-color"));
    case TrueColor:   return (intern ("true-color"));
    case DirectColor: return (intern ("direct-color"));
    default:
      error ("Display has an unknown visual class");
    }
}

DEFUN ("x-display-save-under", Fx_display_save_under,
  Sx_display_save_under, 0, 1, 0,
  "Returns t if the X display DISPLAY supports the save-under feature.\n\
The optional argument DISPLAY specifies which display to ask about.\n\
DISPLAY should be either a frame or a display name (a string).\n\
If omitted or nil, that stands for the selected frame's display.")
  (display)
     Lisp_Object display;
{
  struct x_display_info *dpyinfo = check_x_display_info (display);

  if (DoesSaveUnders (dpyinfo->screen) == True)
    return Qt;
  else
    return Qnil;
}

int
x_pixel_width (f)
     register struct frame *f;
{
  return PIXEL_WIDTH (f);
}

int
x_pixel_height (f)
     register struct frame *f;
{
  return PIXEL_HEIGHT (f);
}

int
x_char_width (f)
     register struct frame *f;
{
  return FONT_WIDTH (f->output_data.x->font);
}

int
x_char_height (f)
     register struct frame *f;
{
  return f->output_data.x->line_height;
}

int
x_screen_planes (f)
     register struct frame *f;
{
  return FRAME_X_DISPLAY_INFO (f)->n_planes;
}

#if 0  /* These no longer seem like the right way to do things.  */

/* Draw a rectangle on the frame with left top corner including
   the character specified by LEFT_CHAR and TOP_CHAR.  The rectangle is
   CHARS by LINES wide and long and is the color of the cursor.  */

void
x_rectangle (f, gc, left_char, top_char, chars, lines)
     register struct frame *f;
     GC gc;
     register int top_char, left_char, chars, lines;
{
  int width;
  int height;
  int left = (left_char * FONT_WIDTH (f->output_data.x->font)
		    + f->output_data.x->internal_border_width);
  int top = (top_char * f->output_data.x->line_height
		   + f->output_data.x->internal_border_width);

  if (chars < 0)
    width = FONT_WIDTH (f->output_data.x->font) / 2;
  else
    width = FONT_WIDTH (f->output_data.x->font) * chars;
  if (lines < 0)
    height = f->output_data.x->line_height / 2;
  else
    height = f->output_data.x->line_height * lines;

  XDrawRectangle (FRAME_X_DISPLAY (f), FRAME_X_WINDOW (f),
		  gc, left, top, width, height);
}

DEFUN ("x-draw-rectangle", Fx_draw_rectangle, Sx_draw_rectangle, 5, 5, 0,
  "Draw a rectangle on FRAME between coordinates specified by\n\
numbers X0, Y0, X1, Y1 in the cursor pixel.")
  (frame, X0, Y0, X1, Y1)
     register Lisp_Object frame, X0, X1, Y0, Y1;
{
  register int x0, y0, x1, y1, top, left, n_chars, n_lines;

  CHECK_LIVE_FRAME (frame, 0);
  CHECK_NUMBER (X0, 0);
  CHECK_NUMBER (Y0, 1);
  CHECK_NUMBER (X1, 2);
  CHECK_NUMBER (Y1, 3);

  x0 = XINT (X0);
  x1 = XINT (X1);
  y0 = XINT (Y0);
  y1 = XINT (Y1);

  if (y1 > y0)
    {
      top = y0;
      n_lines = y1 - y0 + 1;
    }
  else
    {
      top = y1;
      n_lines = y0 - y1 + 1;
    }

  if (x1 > x0)
    {
      left = x0;
      n_chars = x1 - x0 + 1;
    }
  else
    {
      left = x1;
      n_chars = x0 - x1 + 1;
    }

  BLOCK_INPUT;
  x_rectangle (XFRAME (frame), XFRAME (frame)->output_data.x->cursor_gc,
	       left, top, n_chars, n_lines);
  UNBLOCK_INPUT;

  return Qt;
}

DEFUN ("x-erase-rectangle", Fx_erase_rectangle, Sx_erase_rectangle, 5, 5, 0,
  "Draw a rectangle drawn on FRAME between coordinates\n\
X0, Y0, X1, Y1 in the regular background-pixel.")
  (frame, X0, Y0, X1, Y1)
  register Lisp_Object frame, X0, Y0, X1, Y1;
{
  register int x0, y0, x1, y1, top, left, n_chars, n_lines;

  CHECK_LIVE_FRAME (frame, 0);
  CHECK_NUMBER (X0, 0);
  CHECK_NUMBER (Y0, 1);
  CHECK_NUMBER (X1, 2);
  CHECK_NUMBER (Y1, 3);

  x0 = XINT (X0);
  x1 = XINT (X1);
  y0 = XINT (Y0);
  y1 = XINT (Y1);

  if (y1 > y0)
    {
      top = y0;
      n_lines = y1 - y0 + 1;
    }
  else
    {
      top = y1;
      n_lines = y0 - y1 + 1;
    }

  if (x1 > x0)
    {
      left = x0;
      n_chars = x1 - x0 + 1;
    }
  else
    {
      left = x1;
      n_chars = x0 - x1 + 1;
    }

  BLOCK_INPUT;
  x_rectangle (XFRAME (frame), XFRAME (frame)->output_data.x->reverse_gc,
	       left, top, n_chars, n_lines);
  UNBLOCK_INPUT;

  return Qt;
}

/* Draw lines around the text region beginning at the character position
   TOP_X, TOP_Y and ending at BOTTOM_X and BOTTOM_Y.  GC specifies the
   pixel and line characteristics.  */

#define line_len(line) (FRAME_CURRENT_GLYPHS (f)->used[(line)])

static void
outline_region (f, gc, top_x, top_y, bottom_x, bottom_y)
     register struct frame *f;
     GC gc;
     int  top_x, top_y, bottom_x, bottom_y;
{
  register int ibw = f->output_data.x->internal_border_width;
  register int font_w = FONT_WIDTH (f->output_data.x->font);
  register int font_h = f->output_data.x->line_height;
  int y = top_y;
  int x = line_len (y);
  XPoint *pixel_points
    = (XPoint *) alloca (((bottom_y - top_y + 2) * 4) * sizeof (XPoint));
  register XPoint *this_point = pixel_points;

  /* Do the horizontal top line/lines */
  if (top_x == 0)
    {
      this_point->x = ibw;
      this_point->y = ibw + (font_h * top_y);
      this_point++;
      if (x == 0)
	this_point->x = ibw + (font_w / 2); /* Half-size for newline chars.  */
      else
	this_point->x = ibw + (font_w * x);
      this_point->y = (this_point - 1)->y;
    }
  else
    {
      this_point->x = ibw;
      this_point->y = ibw + (font_h * (top_y + 1));
      this_point++;
      this_point->x = ibw + (font_w * top_x);
      this_point->y = (this_point - 1)->y;
      this_point++;
      this_point->x = (this_point - 1)->x;
      this_point->y = ibw + (font_h * top_y);
      this_point++;
      this_point->x = ibw + (font_w * x);
      this_point->y = (this_point - 1)->y;
    }

  /* Now do the right side.  */
  while (y < bottom_y)
    {				/* Right vertical edge */
      this_point++;
      this_point->x = (this_point - 1)->x;
      this_point->y = ibw + (font_h * (y + 1));
      this_point++;

      y++;			/* Horizontal connection to next line */
      x = line_len (y);
      if (x == 0)
	this_point->x = ibw + (font_w / 2);
      else
	this_point->x = ibw + (font_w * x);

      this_point->y = (this_point - 1)->y;
    }

  /* Now do the bottom and connect to the top left point.  */
  this_point->x = ibw + (font_w * (bottom_x + 1));

  this_point++;
  this_point->x = (this_point - 1)->x;
  this_point->y = ibw + (font_h * (bottom_y + 1));
  this_point++;
  this_point->x = ibw;
  this_point->y = (this_point - 1)->y;
  this_point++;
  this_point->x = pixel_points->x;
  this_point->y = pixel_points->y;

  XDrawLines (FRAME_X_DISPLAY (f), FRAME_X_WINDOW (f),
	      gc, pixel_points,
	      (this_point - pixel_points + 1), CoordModeOrigin);
}

DEFUN ("x-contour-region", Fx_contour_region, Sx_contour_region, 1, 1, 0,
  "Highlight the region between point and the character under the mouse\n\
selected frame.")
  (event)
     register Lisp_Object event;
{
  register int x0, y0, x1, y1;
  register struct frame *f = selected_frame;
  register int p1, p2;

  CHECK_CONS (event, 0);

  BLOCK_INPUT;
  x0 = XINT (Fcar (Fcar (event)));
  y0 = XINT (Fcar (Fcdr (Fcar (event))));

  /* If the mouse is past the end of the line, don't that area.  */
  /* ReWrite this...  */

  x1 = f->cursor_x;
  y1 = f->cursor_y;

  if (y1 > y0)			/* point below mouse */
    outline_region (f, f->output_data.x->cursor_gc,
		    x0, y0, x1, y1);
  else if (y1 < y0)		/* point above mouse */
    outline_region (f, f->output_data.x->cursor_gc,
		    x1, y1, x0, y0);
  else				/* same line: draw horizontal rectangle */
    {
      if (x1 > x0)
	x_rectangle (f, f->output_data.x->cursor_gc,
		     x0, y0, (x1 - x0 + 1), 1);
      else if (x1 < x0)
	  x_rectangle (f, f->output_data.x->cursor_gc,
		       x1, y1, (x0 - x1 + 1), 1);
    }

  XFlush (FRAME_X_DISPLAY (f));
  UNBLOCK_INPUT;

  return Qnil;
}

DEFUN ("x-uncontour-region", Fx_uncontour_region, Sx_uncontour_region, 1, 1, 0,
  "Erase any highlighting of the region between point and the character\n\
at X, Y on the selected frame.")
  (event)
     register Lisp_Object event;
{
  register int x0, y0, x1, y1;
  register struct frame *f = selected_frame;

  BLOCK_INPUT;
  x0 = XINT (Fcar (Fcar (event)));
  y0 = XINT (Fcar (Fcdr (Fcar (event))));
  x1 = f->cursor_x;
  y1 = f->cursor_y;

  if (y1 > y0)			/* point below mouse */
    outline_region (f, f->output_data.x->reverse_gc,
		      x0, y0, x1, y1);
  else if (y1 < y0)		/* point above mouse */
    outline_region (f, f->output_data.x->reverse_gc,
		      x1, y1, x0, y0);
  else				/* same line: draw horizontal rectangle */
    {
      if (x1 > x0)
	x_rectangle (f, f->output_data.x->reverse_gc,
		     x0, y0, (x1 - x0 + 1), 1);
      else if (x1 < x0)
	x_rectangle (f, f->output_data.x->reverse_gc,
		     x1, y1, (x0 - x1 + 1), 1);
    }
  UNBLOCK_INPUT;

  return Qnil;
}

#if 0
int contour_begin_x, contour_begin_y;
int contour_end_x, contour_end_y;
int contour_npoints;

/* Clip the top part of the contour lines down (and including) line Y_POS.
   If X_POS is in the middle (rather than at the end) of the line, drop
   down a line at that character.  */

static void
clip_contour_top (y_pos, x_pos)
{
  register XPoint *begin = contour_lines[y_pos].top_left;
  register XPoint *end;
  register int npoints;
  register struct display_line *line = selected_frame->phys_lines[y_pos + 1];

  if (x_pos >= line->len - 1)	/* Draw one, straight horizontal line.  */
    {
      end = contour_lines[y_pos].top_right;
      npoints = (end - begin + 1);
      XDrawLines (x_current_display, contour_window,
		  contour_erase_gc, begin_erase, npoints, CoordModeOrigin);

      bcopy (end, begin + 1, contour_last_point - end + 1);
      contour_last_point -= (npoints - 2);
      XDrawLines (x_current_display, contour_window,
		  contour_erase_gc, begin, 2, CoordModeOrigin);
      XFlush (x_current_display);

      /* Now, update contour_lines structure.  */
    }
				/* ______.         */
  else				/*       |________*/
    {
      register XPoint *p = begin + 1;
      end = contour_lines[y_pos].bottom_right;
      npoints = (end - begin + 1);
      XDrawLines (x_current_display, contour_window,
		  contour_erase_gc, begin_erase, npoints, CoordModeOrigin);

      p->y = begin->y;
      p->x = ibw + (font_w * (x_pos + 1));
      p++;
      p->y = begin->y + font_h;
      p->x = (p - 1)->x;
      bcopy (end, begin + 3, contour_last_point - end + 1);
      contour_last_point -= (npoints - 5);
      XDrawLines (x_current_display, contour_window,
		  contour_erase_gc, begin, 4, CoordModeOrigin);
      XFlush (x_current_display);

      /* Now, update contour_lines structure.  */
    }
}

/* Erase the top horizontal lines of the contour, and then extend
   the contour upwards.  */

static void
extend_contour_top (line)
{
}

static void
clip_contour_bottom (x_pos, y_pos)
     int x_pos, y_pos;
{
}

static void
extend_contour_bottom (x_pos, y_pos)
{
}

DEFUN ("x-select-region", Fx_select_region, Sx_select_region, 1, 1, "e",
  "")
  (event)
     Lisp_Object event;
{
 register struct frame *f = selected_frame;
 register int point_x = f->cursor_x;
 register int point_y = f->cursor_y;
 register int mouse_below_point;
 register Lisp_Object obj;
 register int x_contour_x, x_contour_y;

 x_contour_x = x_mouse_x;
 x_contour_y = x_mouse_y;
 if (x_contour_y > point_y || (x_contour_y == point_y
			       && x_contour_x > point_x))
   {
     mouse_below_point = 1;
     outline_region (f, f->output_data.x->cursor_gc, point_x, point_y,
		     x_contour_x, x_contour_y);
   }
 else
   {
     mouse_below_point = 0;
     outline_region (f, f->output_data.x->cursor_gc, x_contour_x, x_contour_y,
		     point_x, point_y);
   }

 while (1)
   {
     obj = read_char (-1, 0, 0, Qnil, 0);
     if (!CONSP (obj))
       break;

     if (mouse_below_point)
       {
	 if (x_mouse_y <= point_y)                /* Flipped.  */
	   {
	     mouse_below_point = 0;

	     outline_region (f, f->output_data.x->reverse_gc, point_x, point_y,
			     x_contour_x, x_contour_y);
	     outline_region (f, f->output_data.x->cursor_gc, x_mouse_x, x_mouse_y,
			     point_x, point_y);
	   }
	 else if (x_mouse_y < x_contour_y)	  /* Bottom clipped.  */
	   {
	     clip_contour_bottom (x_mouse_y);
	   }
	 else if (x_mouse_y > x_contour_y)	  /* Bottom extended.  */
	   {
	     extend_bottom_contour (x_mouse_y);
	   }

	 x_contour_x = x_mouse_x;
	 x_contour_y = x_mouse_y;
       }
     else  /* mouse above or same line as point */
       {
	 if (x_mouse_y >= point_y)		  /* Flipped.  */
	   {
	     mouse_below_point = 1;

	     outline_region (f, f->output_data.x->reverse_gc,
			     x_contour_x, x_contour_y, point_x, point_y);
	     outline_region (f, f->output_data.x->cursor_gc, point_x, point_y,
			     x_mouse_x, x_mouse_y);
	   }
	 else if (x_mouse_y > x_contour_y)	  /* Top clipped.  */
	   {
	     clip_contour_top (x_mouse_y);
	   }
	 else if (x_mouse_y < x_contour_y)	  /* Top extended.  */
	   {
	     extend_contour_top (x_mouse_y);
	   }
       }
   }

 unread_command_event = obj;
 if (mouse_below_point)
   {
     contour_begin_x = point_x;
     contour_begin_y = point_y;
     contour_end_x = x_contour_x;
     contour_end_y = x_contour_y;
   }
 else
   {
     contour_begin_x = x_contour_x;
     contour_begin_y = x_contour_y;
     contour_end_x = point_x;
     contour_end_y = point_y;
   }
}
#endif

DEFUN ("x-horizontal-line", Fx_horizontal_line, Sx_horizontal_line, 1, 1, "e",
  "")
  (event)
     Lisp_Object event;
{
  register Lisp_Object obj;
  struct frame *f = selected_frame;
  register struct window *w = XWINDOW (selected_window);
  register GC line_gc = f->output_data.x->cursor_gc;
  register GC erase_gc = f->output_data.x->reverse_gc;
#if 0
  char dash_list[] = {6, 4, 6, 4};
  int dashes = 4;
  XGCValues gc_values;
#endif
  register int previous_y;
  register int line = (x_mouse_y + 1) * f->output_data.x->line_height
    + f->output_data.x->internal_border_width;
  register int left = f->output_data.x->internal_border_width
    + (WINDOW_LEFT_MARGIN (w)
       * FONT_WIDTH (f->output_data.x->font));
  register int right = left + (w->width
			       * FONT_WIDTH (f->output_data.x->font))
    - f->output_data.x->internal_border_width;

#if 0
  BLOCK_INPUT;
  gc_values.foreground = f->output_data.x->cursor_pixel;
  gc_values.background = f->output_data.x->background_pixel;
  gc_values.line_width = 1;
  gc_values.line_style = LineOnOffDash;
  gc_values.cap_style = CapRound;
  gc_values.join_style = JoinRound;

  line_gc = XCreateGC (FRAME_X_DISPLAY (f), FRAME_X_WINDOW (f),
		       GCLineStyle | GCJoinStyle | GCCapStyle
		       | GCLineWidth | GCForeground | GCBackground,
		       &gc_values);
  XSetDashes (FRAME_X_DISPLAY (f), line_gc, 0, dash_list, dashes);
  gc_values.foreground = f->output_data.x->background_pixel;
  gc_values.background = f->output_data.x->foreground_pixel;
  erase_gc = XCreateGC (FRAME_X_DISPLAY (f), FRAME_X_WINDOW (f),
		       GCLineStyle | GCJoinStyle | GCCapStyle
		       | GCLineWidth | GCForeground | GCBackground,
		       &gc_values);
  XSetDashes (FRAME_X_DISPLAY (f), erase_gc, 0, dash_list, dashes);
  UNBLOCK_INPUT;
#endif

  while (1)
    {
      BLOCK_INPUT;
      if (x_mouse_y >= XINT (w->top)
	  && x_mouse_y < XINT (w->top) + XINT (w->height) - 1)
	{
	  previous_y = x_mouse_y;
	  line = (x_mouse_y + 1) * f->output_data.x->line_height
	    + f->output_data.x->internal_border_width;
	  XDrawLine (FRAME_X_DISPLAY (f), FRAME_X_WINDOW (f),
		     line_gc, left, line, right, line);
	}
      XFlush (FRAME_X_DISPLAY (f));
      UNBLOCK_INPUT;

      do
	{
	  obj = read_char (-1, 0, 0, Qnil, 0);
	  if (!CONSP (obj)
	      || (! EQ (Fcar (Fcdr (Fcdr (obj))),
			Qvertical_scroll_bar))
	      || x_mouse_grabbed)
	    {
	      BLOCK_INPUT;
	      XDrawLine (FRAME_X_DISPLAY (f), FRAME_X_WINDOW (f),
			 erase_gc, left, line, right, line);
	      unread_command_event = obj;
#if 0
	      XFreeGC (FRAME_X_DISPLAY (f), line_gc);
	      XFreeGC (FRAME_X_DISPLAY (f), erase_gc);
#endif 
	      UNBLOCK_INPUT;
	      return Qnil;
	    }
	}
      while (x_mouse_y == previous_y);

      BLOCK_INPUT;
      XDrawLine (FRAME_X_DISPLAY (f), FRAME_X_WINDOW (f),
		 erase_gc, left, line, right, line);
      UNBLOCK_INPUT;
    }
}
#endif

#if 0
/* These keep track of the rectangle following the pointer.  */
int mouse_track_top, mouse_track_left, mouse_track_width;

/* Offset in buffer of character under the pointer, or 0.  */
int mouse_buffer_offset;

DEFUN ("x-track-pointer", Fx_track_pointer, Sx_track_pointer, 0, 0, 0,
  "Track the pointer.")
  ()
{
  static Cursor current_pointer_shape;
  FRAME_PTR f = x_mouse_frame;

  BLOCK_INPUT;
  if (EQ (Vmouse_frame_part, Qtext_part)
      && (current_pointer_shape != f->output_data.x->nontext_cursor))
    {
      unsigned char c;
      struct buffer *buf;

      current_pointer_shape = f->output_data.x->nontext_cursor;
      XDefineCursor (FRAME_X_DISPLAY (f),
		     FRAME_X_WINDOW (f),
		     current_pointer_shape);

      buf = XBUFFER (XWINDOW (Vmouse_window)->buffer);
      c = *(BUF_CHAR_ADDRESS (buf, mouse_buffer_offset));
    }
  else if (EQ (Vmouse_frame_part, Qmodeline_part)
	   && (current_pointer_shape != f->output_data.x->modeline_cursor))
    {
      current_pointer_shape = f->output_data.x->modeline_cursor;
      XDefineCursor (FRAME_X_DISPLAY (f),
		     FRAME_X_WINDOW (f),
		     current_pointer_shape);
    }

  XFlush (FRAME_X_DISPLAY (f));
  UNBLOCK_INPUT;
}
#endif

#if 0
DEFUN ("x-track-pointer", Fx_track_pointer, Sx_track_pointer, 1, 1, "e",
  "Draw rectangle around character under mouse pointer, if there is one.")
  (event)
     Lisp_Object event;
{
  struct window *w = XWINDOW (Vmouse_window);
  struct frame *f = XFRAME (WINDOW_FRAME (w));
  struct buffer *b = XBUFFER (w->buffer);
  Lisp_Object obj;

  if (! EQ (Vmouse_window, selected_window))
      return Qnil;

  if (EQ (event, Qnil))
    {
      int x, y;

      x_read_mouse_position (selected_frame, &x, &y);
    }

  BLOCK_INPUT;
  mouse_track_width = 0;
  mouse_track_left = mouse_track_top = -1;

  do
    {
      if ((x_mouse_x != mouse_track_left
	   && (x_mouse_x < mouse_track_left
	       || x_mouse_x > (mouse_track_left + mouse_track_width)))
	  || x_mouse_y != mouse_track_top)
	{
	  int hp = 0;		/* Horizontal position */
	  int len = FRAME_CURRENT_GLYPHS (f)->used[x_mouse_y];
	  int p = FRAME_CURRENT_GLYPHS (f)->bufp[x_mouse_y];
	  int tab_width = XINT (b->tab_width);
	  int ctl_arrow_p = !NILP (b->ctl_arrow);
	  unsigned char c;
	  int mode_line_vpos = XFASTINT (w->height) + XFASTINT (w->top) - 1;
	  int in_mode_line = 0;

	  if (! FRAME_CURRENT_GLYPHS (f)->enable[x_mouse_y])
	    break;

	  /* Erase previous rectangle.  */
	  if (mouse_track_width)
	    {
	      x_rectangle (f, f->output_data.x->reverse_gc,
			   mouse_track_left, mouse_track_top,
			   mouse_track_width, 1);

	      if ((mouse_track_left == f->phys_cursor_x
		   || mouse_track_left == f->phys_cursor_x - 1)
		  && mouse_track_top == f->phys_cursor_y)
		{
		  x_display_cursor (f, 1);
		}
	    }

	  mouse_track_left = x_mouse_x;
	  mouse_track_top = x_mouse_y;
	  mouse_track_width = 0;

	  if (mouse_track_left > len) /* Past the end of line.  */
	    goto draw_or_not;

	  if (mouse_track_top == mode_line_vpos)
	    {
	      in_mode_line = 1;
	      goto draw_or_not;
	    }

	  if (tab_width <= 0 || tab_width > 20) tab_width = 8;
	  do
	    {
	      c = FETCH_BYTE (p);
	      if (len == f->width && hp == len - 1 && c != '\n')
		goto draw_or_not;

	      switch (c)
		{
		case '\t':
		  mouse_track_width = tab_width - (hp % tab_width);
		  p++;
		  hp += mouse_track_width;
		  if (hp > x_mouse_x)
		    {
		      mouse_track_left = hp - mouse_track_width;
		      goto draw_or_not;
		    }
		  continue;

		case '\n':
		  mouse_track_width = -1;
		  goto draw_or_not;

		default:
		  if (ctl_arrow_p && (c < 040 || c == 0177))
		    {
		      if (p > ZV)
			goto draw_or_not;

		      mouse_track_width = 2;
		      p++;
		      hp +=2;
		      if (hp > x_mouse_x)
			{
			  mouse_track_left = hp - mouse_track_width;
			  goto draw_or_not;
			}
		    }
		  else
		    {
		      mouse_track_width = 1;
		      p++;
		      hp++;
		    }
		  continue;
		}
	    }
	  while (hp <= x_mouse_x);

	draw_or_not:
	  if (mouse_track_width) /* Over text; use text pointer shape.  */
	    {
	      XDefineCursor (FRAME_X_DISPLAY (f),
			     FRAME_X_WINDOW (f),
			     f->output_data.x->text_cursor);
	      x_rectangle (f, f->output_data.x->cursor_gc,
			   mouse_track_left, mouse_track_top,
			   mouse_track_width, 1);
	    }
	  else if (in_mode_line)
	    XDefineCursor (FRAME_X_DISPLAY (f),
			   FRAME_X_WINDOW (f),
			   f->output_data.x->modeline_cursor);
	  else
	    XDefineCursor (FRAME_X_DISPLAY (f),
			   FRAME_X_WINDOW (f),
			   f->output_data.x->nontext_cursor);
	}

      XFlush (FRAME_X_DISPLAY (f));
      UNBLOCK_INPUT;

      obj = read_char (-1, 0, 0, Qnil, 0);
      BLOCK_INPUT;
    }
  while (CONSP (obj)		   /* Mouse event */
	 && EQ (Fcar (Fcdr (Fcdr (obj))), Qnil)	   /* Not scroll bar */
	 && EQ (Vmouse_depressed, Qnil)              /* Only motion events */
	 && EQ (Vmouse_window, selected_window)	   /* In this window */
	 && x_mouse_frame);

  unread_command_event = obj;

  if (mouse_track_width)
    {
      x_rectangle (f, f->output_data.x->reverse_gc,
		   mouse_track_left, mouse_track_top,
		   mouse_track_width, 1);
      mouse_track_width = 0;
      if ((mouse_track_left == f->phys_cursor_x
	   || mouse_track_left - 1 == f->phys_cursor_x)
	  && mouse_track_top == f->phys_cursor_y)
	{
	  x_display_cursor (f, 1);
	}
    }
  XDefineCursor (FRAME_X_DISPLAY (f),
		 FRAME_X_WINDOW (f),
		 f->output_data.x->nontext_cursor);
  XFlush (FRAME_X_DISPLAY (f));
  UNBLOCK_INPUT;

  return Qnil;
}
#endif

#if 0
#include "glyphs.h"

/* Draw a pixmap specified by IMAGE_DATA of dimensions WIDTH and HEIGHT
   on the frame F at position X, Y.  */

x_draw_pixmap (f, x, y, image_data, width, height)
     struct frame *f;
     int x, y, width, height;
     char *image_data;
{
  Pixmap image;

  image = XCreateBitmapFromData (FRAME_X_DISPLAY (f),
				 FRAME_X_WINDOW (f), image_data,
				 width, height);
  XCopyPlane (FRAME_X_DISPLAY (f), image, FRAME_X_WINDOW (f),
	      f->output_data.x->normal_gc, 0, 0, width, height, x, y);
}
#endif

#if 0 /* I'm told these functions are superfluous
	 given the ability to bind function keys.  */

#ifdef HAVE_X11
DEFUN ("x-rebind-key", Fx_rebind_key, Sx_rebind_key, 3, 3, 0,
"Rebind X keysym KEYSYM, with MODIFIERS, to generate NEWSTRING.\n\
KEYSYM is a string which conforms to the X keysym definitions found\n\
in X11/keysymdef.h, sans the initial XK_. MODIFIERS is nil or a\n\
list of strings specifying modifier keys such as Control_L, which must\n\
also be depressed for NEWSTRING to appear.")
  (x_keysym, modifiers, newstring)
     register Lisp_Object x_keysym;
     register Lisp_Object modifiers;
     register Lisp_Object newstring;
{
  char *rawstring;
  register KeySym keysym;
  KeySym modifier_list[16];

  check_x ();
  CHECK_STRING (x_keysym, 1);
  CHECK_STRING (newstring, 3);

  keysym = XStringToKeysym ((char *) XSTRING (x_keysym)->data);
  if (keysym == NoSymbol)
    error ("Keysym does not exist");

  if (NILP (modifiers))
    XRebindKeysym (x_current_display, keysym, modifier_list, 0,
		   XSTRING (newstring)->data,
		   STRING_BYTES (XSTRING (newstring)));
  else
    {
      register Lisp_Object rest, mod;
      register int i = 0;

      for (rest = modifiers; !NILP (rest); rest = Fcdr (rest))
	{
	  if (i == 16)
	    error ("Can't have more than 16 modifiers");

	  mod = Fcar (rest);
	  CHECK_STRING (mod, 3);
	  modifier_list[i] = XStringToKeysym ((char *) XSTRING (mod)->data);
#ifndef HAVE_X11R5
	  if (modifier_list[i] == NoSymbol
	      || !(IsModifierKey (modifier_list[i]) 
                   || ((unsigned)(modifier_list[i]) == XK_Mode_switch)
                   || ((unsigned)(modifier_list[i]) == XK_Num_Lock)))
#else
	  if (modifier_list[i] == NoSymbol
	      || !IsModifierKey (modifier_list[i]))
#endif
	    error ("Element is not a modifier keysym");
	  i++;
	}

      XRebindKeysym (x_current_display, keysym, modifier_list, i,
		     XSTRING (newstring)->data,
		     STRING_BYTES (XSTRING (newstring)));
    }

  return Qnil;
}
  
DEFUN ("x-rebind-keys", Fx_rebind_keys, Sx_rebind_keys, 2, 2, 0,
  "Rebind KEYCODE to list of strings STRINGS.\n\
STRINGS should be a list of 16 elements, one for each shift combination.\n\
nil as element means don't change.\n\
See the documentation of `x-rebind-key' for more information.")
  (keycode, strings)
     register Lisp_Object keycode;
     register Lisp_Object strings;
{
  register Lisp_Object item;
  register unsigned char *rawstring;
  KeySym rawkey, modifier[1];
  int strsize;
  register unsigned i;

  check_x ();
  CHECK_NUMBER (keycode, 1);
  CHECK_CONS (strings, 2);
  rawkey = (KeySym) ((unsigned) (XINT (keycode))) & 255;
  for (i = 0; i <= 15; strings = Fcdr (strings), i++)
    {
      item = Fcar (strings);
      if (!NILP (item))
	{
	  CHECK_STRING (item, 2);
	  strsize = STRING_BYTES (XSTRING (item));
	  rawstring = (unsigned char *) xmalloc (strsize);
	  bcopy (XSTRING (item)->data, rawstring, strsize);
	  modifier[1] = 1 << i;
	  XRebindKeysym (x_current_display, rawkey, modifier, 1,
			 rawstring, strsize);
	}
    }
  return Qnil;
}
#endif /* HAVE_X11 */
#endif /* 0 */

#ifndef HAVE_XSCREENNUMBEROFSCREEN
int
XScreenNumberOfScreen (scr)
    register Screen *scr;
{
  register Display *dpy;
  register Screen *dpyscr;
  register int i;

  dpy = scr->display;
  dpyscr = dpy->screens;

  for (i = 0; i < dpy->nscreens; i++, dpyscr++)
    if (scr == dpyscr)
      return i;

  return -1;
}
#endif /* not HAVE_XSCREENNUMBEROFSCREEN */

Visual *
select_visual (dpy, screen, depth)
     Display *dpy;
     Screen *screen;
     unsigned int *depth;
{
  Visual *v;
  XVisualInfo *vinfo, vinfo_template;
  int n_visuals;

  v = DefaultVisualOfScreen (screen);

#ifdef HAVE_X11R4
  vinfo_template.visualid = XVisualIDFromVisual (v);
#else
  vinfo_template.visualid = v->visualid;
#endif

  vinfo_template.screen = XScreenNumberOfScreen (screen);

  vinfo = XGetVisualInfo (dpy,
			  VisualIDMask | VisualScreenMask, &vinfo_template,
			  &n_visuals);
  if (n_visuals != 1)
    fatal ("Can't get proper X visual info");

  if ((1 << vinfo->depth) == vinfo->colormap_size)
    *depth = vinfo->depth;
  else
    {
      int i = 0;
      int n = vinfo->colormap_size - 1;
      while (n)
	{
	  n = n >> 1;
	  i++;
	}
      *depth = i;
    }

  XFree ((char *) vinfo);
  return v;
}

/* Return the X display structure for the display named NAME.
   Open a new connection if necessary.  */

struct x_display_info *
x_display_info_for_name (name)
     Lisp_Object name;
{
  Lisp_Object names;
  struct x_display_info *dpyinfo;

  CHECK_STRING (name, 0);

  if (! EQ (Vwindow_system, intern ("x")))
    error ("Not using X Windows");

  for (dpyinfo = x_display_list, names = x_display_name_list;
       dpyinfo;
       dpyinfo = dpyinfo->next, names = XCONS (names)->cdr)
    {
      Lisp_Object tem;
      tem = Fstring_equal (XCONS (XCONS (names)->car)->car, name);
      if (!NILP (tem))
	return dpyinfo;
    }

  /* Use this general default value to start with.  */
  Vx_resource_name = Vinvocation_name;

  validate_x_resource_name ();

  dpyinfo = x_term_init (name, (unsigned char *)0,
			 (char *) XSTRING (Vx_resource_name)->data);

  if (dpyinfo == 0)
    error ("Cannot connect to X server %s", XSTRING (name)->data);

  x_in_use = 1;
  XSETFASTINT (Vwindow_system_version, 11);

  return dpyinfo;
}

DEFUN ("x-open-connection", Fx_open_connection, Sx_open_connection,
       1, 3, 0, "Open a connection to an X server.\n\
DISPLAY is the name of the display to connect to.\n\
Optional second arg XRM-STRING is a string of resources in xrdb format.\n\
If the optional third arg MUST-SUCCEED is non-nil,\n\
terminate Emacs if we can't open the connection.")
  (display, xrm_string, must_succeed)
     Lisp_Object display, xrm_string, must_succeed;
{
  unsigned int n_planes;
  unsigned char *xrm_option;
  struct x_display_info *dpyinfo;

  CHECK_STRING (display, 0);
  if (! NILP (xrm_string))
    CHECK_STRING (xrm_string, 1);

  if (! EQ (Vwindow_system, intern ("x")))
    error ("Not using X Windows");

  if (! NILP (xrm_string))
    xrm_option = (unsigned char *) XSTRING (xrm_string)->data;
  else
    xrm_option = (unsigned char *) 0;

  validate_x_resource_name ();

  /* This is what opens the connection and sets x_current_display.
     This also initializes many symbols, such as those used for input.  */
  dpyinfo = x_term_init (display, xrm_option,
			 (char *) XSTRING (Vx_resource_name)->data);

  if (dpyinfo == 0)
    {
      if (!NILP (must_succeed))
	fatal ("Cannot connect to X server %s.\n\
Check the DISPLAY environment variable or use `-d'.\n\
Also use the `xhost' program to verify that it is set to permit\n\
connections from your machine.\n",
	       XSTRING (display)->data);
      else
	error ("Cannot connect to X server %s", XSTRING (display)->data);
    }

  x_in_use = 1;

  XSETFASTINT (Vwindow_system_version, 11);
  return Qnil;
}

DEFUN ("x-close-connection", Fx_close_connection,
       Sx_close_connection, 1, 1, 0,
   "Close the connection to DISPLAY's X server.\n\
For DISPLAY, specify either a frame or a display name (a string).\n\
If DISPLAY is nil, that stands for the selected frame's display.")
  (display)
  Lisp_Object display;
{
  struct x_display_info *dpyinfo = check_x_display_info (display);
  struct x_display_info *tail;
  int i;

  if (dpyinfo->reference_count > 0)
    error ("Display still has frames on it");

  BLOCK_INPUT;
  /* Free the fonts in the font table.  */
  for (i = 0; i < dpyinfo->n_fonts; i++)
    {
      if (dpyinfo->font_table[i].name)
	free (dpyinfo->font_table[i].name);
      /* Don't free the full_name string;
	 it is always shared with something else.  */
      XFreeFont (dpyinfo->display, dpyinfo->font_table[i].font);
    }
  x_destroy_all_bitmaps (dpyinfo);
  XSetCloseDownMode (dpyinfo->display, DestroyAll);

#ifdef USE_X_TOOLKIT
  XtCloseDisplay (dpyinfo->display);
#else
  XCloseDisplay (dpyinfo->display);
#endif

  x_delete_display (dpyinfo);
  UNBLOCK_INPUT;

  return Qnil;
}

DEFUN ("x-display-list", Fx_display_list, Sx_display_list, 0, 0, 0,
  "Return the list of display names that Emacs has connections to.")
  ()
{
  Lisp_Object tail, result;

  result = Qnil;
  for (tail = x_display_name_list; ! NILP (tail); tail = XCONS (tail)->cdr)
    result = Fcons (XCONS (XCONS (tail)->car)->car, result);

  return result;
}

DEFUN ("x-synchronize", Fx_synchronize, Sx_synchronize, 1, 2, 0,
   "If ON is non-nil, report X errors as soon as the erring request is made.\n\
If ON is nil, allow buffering of requests.\n\
Turning on synchronization prohibits the Xlib routines from buffering\n\
requests and seriously degrades performance, but makes debugging much\n\
easier.\n\
The optional second argument DISPLAY specifies which display to act on.\n\
DISPLAY should be either a frame or a display name (a string).\n\
If DISPLAY is omitted or nil, that stands for the selected frame's display.")
  (on, display)
    Lisp_Object display, on;
{
  struct x_display_info *dpyinfo = check_x_display_info (display);

  XSynchronize (dpyinfo->display, !EQ (on, Qnil));

  return Qnil;
}

/* Wait for responses to all X commands issued so far for frame F.  */

void
x_sync (f)
     FRAME_PTR f;
{
  BLOCK_INPUT;
  XSync (FRAME_X_DISPLAY (f), False);
  UNBLOCK_INPUT;
}

void
syms_of_xfns ()
{
  /* This is zero if not using X windows.  */
  x_in_use = 0;

  /* The section below is built by the lisp expression at the top of the file,
     just above where these variables are declared.  */
  /*&&& init symbols here &&&*/
  Qauto_raise = intern ("auto-raise");
  staticpro (&Qauto_raise);
  Qauto_lower = intern ("auto-lower");
  staticpro (&Qauto_lower);
  Qbackground_color = intern ("background-color");
  staticpro (&Qbackground_color);
  Qbar = intern ("bar");
  staticpro (&Qbar);
  Qborder_color = intern ("border-color");
  staticpro (&Qborder_color);
  Qborder_width = intern ("border-width");
  staticpro (&Qborder_width);
  Qbox = intern ("box");
  staticpro (&Qbox);
  Qcursor_color = intern ("cursor-color");
  staticpro (&Qcursor_color);
  Qcursor_type = intern ("cursor-type");
  staticpro (&Qcursor_type);
  Qforeground_color = intern ("foreground-color");
  staticpro (&Qforeground_color);
  Qgeometry = intern ("geometry");
  staticpro (&Qgeometry);
  Qicon_left = intern ("icon-left");
  staticpro (&Qicon_left);
  Qicon_top = intern ("icon-top");
  staticpro (&Qicon_top);
  Qicon_type = intern ("icon-type");
  staticpro (&Qicon_type);
  Qicon_name = intern ("icon-name");
  staticpro (&Qicon_name);
  Qinternal_border_width = intern ("internal-border-width");
  staticpro (&Qinternal_border_width);
  Qleft = intern ("left");
  staticpro (&Qleft);
  Qright = intern ("right");
  staticpro (&Qright);
  Qmouse_color = intern ("mouse-color");
  staticpro (&Qmouse_color);
  Qnone = intern ("none");
  staticpro (&Qnone);
  Qparent_id = intern ("parent-id");
  staticpro (&Qparent_id);
  Qscroll_bar_width = intern ("scroll-bar-width");
  staticpro (&Qscroll_bar_width);
  Qsuppress_icon = intern ("suppress-icon");
  staticpro (&Qsuppress_icon);
  Qtop = intern ("top");
  staticpro (&Qtop);
  Qundefined_color = intern ("undefined-color");
  staticpro (&Qundefined_color);
  Qvertical_scroll_bars = intern ("vertical-scroll-bars");
  staticpro (&Qvertical_scroll_bars);
  Qvisibility = intern ("visibility");
  staticpro (&Qvisibility);
  Qwindow_id = intern ("window-id");
  staticpro (&Qwindow_id);
  Qouter_window_id = intern ("outer-window-id");
  staticpro (&Qouter_window_id);
  Qx_frame_parameter = intern ("x-frame-parameter");
  staticpro (&Qx_frame_parameter);
  Qx_resource_name = intern ("x-resource-name");
  staticpro (&Qx_resource_name);
  Quser_position = intern ("user-position");
  staticpro (&Quser_position);
  Quser_size = intern ("user-size");
  staticpro (&Quser_size);
  Qdisplay = intern ("display");
  staticpro (&Qdisplay);
  /* This is the end of symbol initialization.  */

  Qface_set_after_frame_default = intern ("face-set-after-frame-default");
  staticpro (&Qface_set_after_frame_default);

  Fput (Qundefined_color, Qerror_conditions,
	Fcons (Qundefined_color, Fcons (Qerror, Qnil)));
  Fput (Qundefined_color, Qerror_message,
	build_string ("Undefined color"));

  init_x_parm_symbols ();

  DEFVAR_LISP ("x-bitmap-file-path", &Vx_bitmap_file_path,
    "List of directories to search for bitmap files for X.");
  Vx_bitmap_file_path = decode_env_path ((char *) 0, PATH_BITMAPS);

  DEFVAR_LISP ("x-pointer-shape", &Vx_pointer_shape,
    "The shape of the pointer when over text.\n\
Changing the value does not affect existing frames\n\
unless you set the mouse color.");
  Vx_pointer_shape = Qnil;

  DEFVAR_LISP ("x-resource-name", &Vx_resource_name,
    "The name Emacs uses to look up X resources.\n\
`x-get-resource' uses this as the first component of the instance name\n\
when requesting resource values.\n\
Emacs initially sets `x-resource-name' to the name under which Emacs\n\
was invoked, or to the value specified with the `-name' or `-rn'\n\
switches, if present.\n\
\n\
It may be useful to bind this variable locally around a call\n\
to `x-get-resource'.  See also the variable `x-resource-class'.");
  Vx_resource_name = Qnil;

  DEFVAR_LISP ("x-resource-class", &Vx_resource_class,
    "The class Emacs uses to look up X resources.\n\
`x-get-resource' uses this as the first component of the instance class\n\
when requesting resource values.\n\
Emacs initially sets `x-resource-class' to \"Emacs\".\n\
\n\
Setting this variable permanently is not a reasonable thing to do,\n\
but binding this variable locally around a call to `x-get-resource'\n\
is a reasonabvle practice.  See also the variable `x-resource-name'.");
  Vx_resource_class = build_string (EMACS_CLASS);

#if 0 /* This doesn't really do anything.  */
  DEFVAR_LISP ("x-nontext-pointer-shape", &Vx_nontext_pointer_shape,
	      "The shape of the pointer when not over text.\n\
This variable takes effect when you create a new frame\n\
or when you set the mouse color.");
#endif
  Vx_nontext_pointer_shape = Qnil;

#if 0 /* This doesn't really do anything.  */
  DEFVAR_LISP ("x-mode-pointer-shape", &Vx_mode_pointer_shape,
	      "The shape of the pointer when over the mode line.\n\
This variable takes effect when you create a new frame\n\
or when you set the mouse color.");
#endif
  Vx_mode_pointer_shape = Qnil;

  DEFVAR_LISP ("x-sensitive-text-pointer-shape",
	      &Vx_sensitive_text_pointer_shape,
	      "The shape of the pointer when over mouse-sensitive text.\n\
This variable takes effect when you create a new frame\n\
or when you set the mouse color.");
  Vx_sensitive_text_pointer_shape = Qnil;

  DEFVAR_LISP ("x-cursor-fore-pixel", &Vx_cursor_fore_pixel,
	       "A string indicating the foreground color of the cursor box.");
  Vx_cursor_fore_pixel = Qnil;

  DEFVAR_LISP ("x-no-window-manager", &Vx_no_window_manager,
	       "Non-nil if no X window manager is in use.\n\
Emacs doesn't try to figure this out; this is always nil\n\
unless you set it to something else.");
  /* We don't have any way to find this out, so set it to nil
     and maybe the user would like to set it to t.  */
  Vx_no_window_manager = Qnil;

  DEFVAR_LISP ("x-pixel-size-width-font-regexp",
	       &Vx_pixel_size_width_font_regexp,
     "Regexp matching a font name whose width is the same as `PIXEL_SIZE'.\n\
\n\
Since Emacs gets width of a font matching with this regexp from\n\
PIXEL_SIZE field of the name, font finding mechanism gets faster for\n\
such a font.  This is especially effective for such large fonts as\n\
Chinese, Japanese, and Korean.");
  Vx_pixel_size_width_font_regexp = Qnil;

#ifdef USE_X_TOOLKIT
  Fprovide (intern ("x-toolkit"));
#endif
#ifdef USE_MOTIF
  Fprovide (intern ("motif"));
#endif

  defsubr (&Sx_get_resource);
#if 0
  defsubr (&Sx_draw_rectangle);
  defsubr (&Sx_erase_rectangle);
  defsubr (&Sx_contour_region);
  defsubr (&Sx_uncontour_region);
#endif
  defsubr (&Sx_list_fonts);
  defsubr (&Sx_display_color_p);
  defsubr (&Sx_display_grayscale_p);
  defsubr (&Sx_color_defined_p);
  defsubr (&Sx_color_values);
  defsubr (&Sx_server_max_request_size);
  defsubr (&Sx_server_vendor);
  defsubr (&Sx_server_version);
  defsubr (&Sx_display_pixel_width);
  defsubr (&Sx_display_pixel_height);
  defsubr (&Sx_display_mm_width);
  defsubr (&Sx_display_mm_height);
  defsubr (&Sx_display_screens);
  defsubr (&Sx_display_planes);
  defsubr (&Sx_display_color_cells);
  defsubr (&Sx_display_visual_class);
  defsubr (&Sx_display_backing_store);
  defsubr (&Sx_display_save_under);
#if 0
  defsubr (&Sx_rebind_key);
  defsubr (&Sx_rebind_keys);
  defsubr (&Sx_track_pointer);
  defsubr (&Sx_grab_pointer);
  defsubr (&Sx_ungrab_pointer);
#endif
  defsubr (&Sx_parse_geometry);
  defsubr (&Sx_create_frame);
#if 0
  defsubr (&Sx_horizontal_line);
#endif
  defsubr (&Sx_open_connection);
  defsubr (&Sx_close_connection);
  defsubr (&Sx_display_list);
  defsubr (&Sx_synchronize);

  /* Setting callback functions for fontset handler.  */
  get_font_info_func = x_get_font_info;
  list_fonts_func = x_list_fonts;
  load_font_func = x_load_font;
  find_ccl_program_func = x_find_ccl_program;
  query_font_func = x_query_font;
  set_frame_fontset_func = x_set_font;
  check_window_system_func = check_x;
}

#endif /* HAVE_X_WINDOWS */
