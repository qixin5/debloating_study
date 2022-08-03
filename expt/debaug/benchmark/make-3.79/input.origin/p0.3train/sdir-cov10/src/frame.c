/* Generic frame functions.
   Copyright (C) 1993, 1994, 1995, 1997 Free Software Foundation.

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
#ifdef HAVE_STDLIB_H
#include <stdlib.h>
#endif
#include "lisp.h"
#include "charset.h"
#ifdef HAVE_X_WINDOWS
#include "xterm.h"
#endif
#include "frame.h"
#ifdef HAVE_WINDOW_SYSTEM
#include "fontset.h"
#endif
#include "termhooks.h"
#include "dispextern.h"
#include "window.h"
#ifdef MSDOS
#include "msdos.h"
#endif

/* Evaluate this expression to rebuild the section of syms_of_frame
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
Lisp_Object Qframep;
Lisp_Object Qframe_live_p;
Lisp_Object Qheight;
Lisp_Object Qicon;
Lisp_Object Qminibuffer;
Lisp_Object Qmodeline;
Lisp_Object Qname;
Lisp_Object Qonly;
Lisp_Object Qunsplittable;
Lisp_Object Qmenu_bar_lines;
Lisp_Object Qwidth;
Lisp_Object Qx;
Lisp_Object Qw32;
Lisp_Object Qpc;
Lisp_Object Qvisible;
Lisp_Object Qbuffer_predicate;
Lisp_Object Qbuffer_list;
Lisp_Object Qtitle;

Lisp_Object Vterminal_frame;
Lisp_Object Vdefault_frame_alist;

static void
syms_of_frame_1 ()
{
  /*&&& init symbols here &&&*/
  Qframep = intern ("framep");
  staticpro (&Qframep);
  Qframe_live_p = intern ("frame-live-p");
  staticpro (&Qframe_live_p);
  Qheight = intern ("height");
  staticpro (&Qheight);
  Qicon = intern ("icon");
  staticpro (&Qicon);
  Qminibuffer = intern ("minibuffer");
  staticpro (&Qminibuffer);
  Qmodeline = intern ("modeline");
  staticpro (&Qmodeline);
  Qname = intern ("name");
  staticpro (&Qname);
  Qonly = intern ("only");
  staticpro (&Qonly);
  Qunsplittable = intern ("unsplittable");
  staticpro (&Qunsplittable);
  Qmenu_bar_lines = intern ("menu-bar-lines");
  staticpro (&Qmenu_bar_lines);
  Qwidth = intern ("width");
  staticpro (&Qwidth);
  Qx = intern ("x");
  staticpro (&Qx);
  Qw32 = intern ("w32");
  staticpro (&Qw32);
  Qpc = intern ("pc");
  staticpro (&Qpc);
  Qvisible = intern ("visible");
  staticpro (&Qvisible);
  Qbuffer_predicate = intern ("buffer-predicate");
  staticpro (&Qbuffer_predicate);
  Qbuffer_list = intern ("buffer-list");
  staticpro (&Qbuffer_list);
  Qtitle = intern ("title");
  staticpro (&Qtitle);

  DEFVAR_LISP ("default-frame-alist", &Vdefault_frame_alist,
    "Alist of default values for frame creation.\n\
These may be set in your init file, like this:\n\
  (setq default-frame-alist '((width . 80) (height . 55) (menu-bar-lines . 1))\n\
These override values given in window system configuration data,\n\
 including X Windows' defaults database.\n\
For values specific to the first Emacs frame, see `initial-frame-alist'.\n\
For values specific to the separate minibuffer frame, see\n\
 `minibuffer-frame-alist'.\n\
The `menu-bar-lines' element of the list controls whether new frames\n\
 have menu bars; `menu-bar-mode' works by altering this element.");
  Vdefault_frame_alist = Qnil;
}

static void
set_menu_bar_lines_1 (window, n)
  Lisp_Object window;
  int n;
{
  struct window *w = XWINDOW (window);

  XSETFASTINT (w->last_modified, 0);
  XSETFASTINT (w->top, XFASTINT (w->top) + n);
  XSETFASTINT (w->height, XFASTINT (w->height) - n);

  /* Handle just the top child in a vertical split.  */
  if (!NILP (w->vchild))
    set_menu_bar_lines_1 (w->vchild, n);

  /* Adjust all children in a horizontal split.  */
  for (window = w->hchild; !NILP (window); window = w->next)
    {
      w = XWINDOW (window);
      set_menu_bar_lines_1 (window, n);
    }
}

void
set_menu_bar_lines (f, value, oldval)
     struct frame *f;
     Lisp_Object value, oldval;
{
  int nlines;
  int olines = FRAME_MENU_BAR_LINES (f);

  /* Right now, menu bars don't work properly in minibuf-only frames;
     most of the commands try to apply themselves to the minibuffer
     frame itself, and get an error because you can't switch buffers
     in or split the minibuffer window.  */
  if (FRAME_MINIBUF_ONLY_P (f))
    return;

  if (INTEGERP (value))
    nlines = XINT (value);
  else
    nlines = 0;

  if (nlines != olines)
    {
      windows_or_buffers_changed++;
      FRAME_WINDOW_SIZES_CHANGED (f) = 1;
      FRAME_MENU_BAR_LINES (f) = nlines;
      set_menu_bar_lines_1 (f->root_window, nlines - olines);
    }
}

#include "buffer.h"

/* These help us bind and responding to switch-frame events.  */
#include "commands.h"
#include "keyboard.h"

Lisp_Object Vemacs_iconified;
Lisp_Object Vframe_list;

extern Lisp_Object Vminibuffer_list;
extern Lisp_Object get_minibuffer ();
extern Lisp_Object Fhandle_switch_frame ();
extern Lisp_Object Fredirect_frame_focus ();
extern Lisp_Object x_get_focus_frame ();

DEFUN ("framep", Fframep, Sframep, 1, 1, 0,
  "Return non-nil if OBJECT is a frame.\n\
Value is t for a termcap frame (a character-only terminal),\n\
`x' for an Emacs frame that is really an X window,\n\
`pc' for a direct-write MS-DOS frame.\n\
See also `frame-live-p'.")
  (object)
     Lisp_Object object;
{
  if (!FRAMEP (object))
    return Qnil;
  switch (XFRAME (object)->output_method)
    {
    case output_termcap:
      return Qt;
    case output_x_window:
      return Qx;
    case output_w32:
      return Qw32;
    case output_msdos_raw:
      return Qpc;
    default:
      abort ();
    }
}

DEFUN ("frame-live-p", Fframe_live_p, Sframe_live_p, 1, 1, 0,
  "Return non-nil if OBJECT is a frame which has not been deleted.\n\
Value is nil if OBJECT is not a live frame.  If object is a live\n\
frame, the return value indicates what sort of output device it is\n\
displayed on.  Value is t for a termcap frame (a character-only\n\
terminal), `x' for an Emacs frame being displayed in an X window.")
  (object)
     Lisp_Object object;
{
  return ((FRAMEP (object)
	   && FRAME_LIVE_P (XFRAME (object)))
	  ? Fframep (object)
	  : Qnil);
}

struct frame *
make_frame (mini_p)
     int mini_p;
{
  Lisp_Object frame;
  register struct frame *f;
  register Lisp_Object root_window;
  register Lisp_Object mini_window;
  register struct Lisp_Vector *vec;
  int i;

  vec = allocate_vectorlike ((EMACS_INT) VECSIZE (struct frame));
  for (i = 0; i < VECSIZE (struct frame); i++)
    XSETFASTINT (vec->contents[i], 0);
  vec->size = VECSIZE (struct frame);
  f = (struct frame *)vec;
  XSETFRAME (frame, f);

  f->cursor_x = 0;
  f->cursor_y = 0;
  f->current_glyphs = 0;
  f->desired_glyphs = 0;
  f->visible = 0;
  f->async_visible = 0;
  f->output_data.nothing = 0;
  f->iconified = 0;
  f->async_iconified = 0;
  f->wants_modeline = 1;
  f->auto_raise = 0;
  f->auto_lower = 0;
  f->no_split = 0;
  f->garbaged = 0;
  f->has_minibuffer = mini_p;
  f->focus_frame = Qnil;
  f->explicit_name = 0;
  f->can_have_scroll_bars = 0;
  f->vertical_scroll_bar_type = vertical_scroll_bar_none;
  f->param_alist = Qnil;
  f->scroll_bars = Qnil;
  f->condemned_scroll_bars = Qnil;
  f->face_alist = Qnil;
  f->menu_bar_items = Qnil;
  f->menu_bar_vector = Qnil;
  f->menu_bar_items_used = 0;
  f->buffer_predicate = Qnil;
  f->buffer_list = Qnil;
#ifdef MULTI_KBOARD
  f->kboard = initial_kboard;
#endif
  f->namebuf = 0;
  f->title = Qnil;

  root_window = make_window ();
  if (mini_p)
    {
      mini_window = make_window ();
      XWINDOW (root_window)->next = mini_window;
      XWINDOW (mini_window)->prev = root_window;
      XWINDOW (mini_window)->mini_p = Qt;
      XWINDOW (mini_window)->frame = frame;
      f->minibuffer_window = mini_window;
    }
  else
    {
      mini_window = Qnil;
      XWINDOW (root_window)->next = Qnil;
      f->minibuffer_window = Qnil;
    }

  XWINDOW (root_window)->frame = frame;

  /* 10 is arbitrary,
     just so that there is "something there."
     Correct size will be set up later with change_frame_size.  */

  SET_FRAME_WIDTH (f, 10);
  f->height = 10;

  XSETFASTINT (XWINDOW (root_window)->width, 10);
  XSETFASTINT (XWINDOW (root_window)->height, (mini_p ? 9 : 10));

  if (mini_p)
    {
      XSETFASTINT (XWINDOW (mini_window)->width, 10);
      XSETFASTINT (XWINDOW (mini_window)->top, 9);
      XSETFASTINT (XWINDOW (mini_window)->height, 1);
    }

  /* Choose a buffer for the frame's root window.  */
  {
    Lisp_Object buf;

    XWINDOW (root_window)->buffer = Qt;
    buf = Fcurrent_buffer ();
    /* If buf is a 'hidden' buffer (i.e. one whose name starts with
       a space), try to find another one.  */
    if (XSTRING (Fbuffer_name (buf))->data[0] == ' ')
      buf = Fother_buffer (buf, Qnil, Qnil);
    Fset_window_buffer (root_window, buf);

    f->buffer_list = Fcons (buf, Qnil);
  }

  if (mini_p)
    {
      XWINDOW (mini_window)->buffer = Qt;
      Fset_window_buffer (mini_window,
			  (NILP (Vminibuffer_list)
			   ? get_minibuffer (0)
			   : Fcar (Vminibuffer_list)));
    }

  f->root_window = root_window;
  f->selected_window = root_window;
  /* Make sure this window seems more recently used than
     a newly-created, never-selected window.  */
  XSETFASTINT (XWINDOW (f->selected_window)->use_time, ++window_select_count);

#ifdef HAVE_WINDOW_SYSTEM
  f->fontset_data = alloc_fontset_data ();
#endif

  return f;
}

#ifdef HAVE_WINDOW_SYSTEM
/* Make a frame using a separate minibuffer window on another frame.
   MINI_WINDOW is the minibuffer window to use.  nil means use the
   default (the global minibuffer).  */

struct frame *
make_frame_without_minibuffer (mini_window, kb, display)
     register Lisp_Object mini_window;
     KBOARD *kb;
     Lisp_Object display;
{
  register struct frame *f;
  struct gcpro gcpro1;

  if (!NILP (mini_window))
    CHECK_LIVE_WINDOW (mini_window, 0);

#ifdef MULTI_KBOARD
  if (!NILP (mini_window)
      && XFRAME (XWINDOW (mini_window)->frame)->kboard != kb)
    error ("frame and minibuffer must be on the same display");
#endif

  /* Make a frame containing just a root window.  */
  f = make_frame (0);

  if (NILP (mini_window))
    {
      /* Use default-minibuffer-frame if possible.  */
      if (!FRAMEP (kb->Vdefault_minibuffer_frame)
	  || ! FRAME_LIVE_P (XFRAME (kb->Vdefault_minibuffer_frame)))
	{
          Lisp_Object frame_dummy;

          XSETFRAME (frame_dummy, f);
          GCPRO1 (frame_dummy);
	  /* If there's no minibuffer frame to use, create one.  */
	  kb->Vdefault_minibuffer_frame =
	    call1 (intern ("make-initial-minibuffer-frame"), display);
          UNGCPRO;
	}
   
      mini_window = XFRAME (kb->Vdefault_minibuffer_frame)->minibuffer_window;
    }

  f->minibuffer_window = mini_window;

  /* Make the chosen minibuffer window display the proper minibuffer,
     unless it is already showing a minibuffer.  */
  if (NILP (Fmemq (XWINDOW (mini_window)->buffer, Vminibuffer_list)))
    Fset_window_buffer (mini_window,
			(NILP (Vminibuffer_list)
			 ? get_minibuffer (0)
			 : Fcar (Vminibuffer_list)));
  return f;
}

/* Make a frame containing only a minibuffer window.  */

struct frame *
make_minibuffer_frame ()
{
  /* First make a frame containing just a root window, no minibuffer.  */

  register struct frame *f = make_frame (0);
  register Lisp_Object mini_window;
  register Lisp_Object frame;

  XSETFRAME (frame, f);

  f->auto_raise = 0;
  f->auto_lower = 0;
  f->no_split = 1;
  f->wants_modeline = 0;
  f->has_minibuffer = 1;

  /* Now label the root window as also being the minibuffer.
     Avoid infinite looping on the window chain by marking next pointer
     as nil. */

  mini_window = f->minibuffer_window = f->root_window;
  XWINDOW (mini_window)->mini_p = Qt;
  XWINDOW (mini_window)->next = Qnil;
  XWINDOW (mini_window)->prev = Qnil;
  XWINDOW (mini_window)->frame = frame;

  /* Put the proper buffer in that window.  */

  Fset_window_buffer (mini_window,
		      (NILP (Vminibuffer_list)
		       ? get_minibuffer (0)
		       : Fcar (Vminibuffer_list)));
  return f;
}
#endif /* HAVE_WINDOW_SYSTEM */

/* Construct a frame that refers to the terminal (stdin and stdout).  */

static int terminal_frame_count;

struct frame *
make_terminal_frame ()
{
  register struct frame *f;
  Lisp_Object frame;
  char name[20];

#ifdef MULTI_KBOARD
  if (!initial_kboard)
    {
      initial_kboard = (KBOARD *) xmalloc (sizeof (KBOARD));
      init_kboard (initial_kboard);
      initial_kboard->next_kboard = all_kboards;
      all_kboards = initial_kboard;
    }
#endif

  /* The first call must initialize Vframe_list.  */
  if (! (NILP (Vframe_list) || CONSP (Vframe_list)))
    Vframe_list = Qnil;

  f = make_frame (1);

  XSETFRAME (frame, f);
  Vframe_list = Fcons (frame, Vframe_list);

  terminal_frame_count++;
  sprintf (name, "F%d", terminal_frame_count);
  f->name = build_string (name);

  f->visible = 1;		/* FRAME_SET_VISIBLE wd set frame_garbaged. */
  f->async_visible = 1;		/* Don't let visible be cleared later. */
#ifdef MSDOS
  f->output_data.x = &the_only_x_display;
  f->output_method = output_msdos_raw;
  init_frame_faces (f);
#else /* not MSDOS */
  f->output_data.nothing = 1;	/* Nonzero means frame isn't deleted.  */
#endif
  return f;
}

DEFUN ("make-terminal-frame", Fmake_terminal_frame, Smake_terminal_frame,
       1, 1, 0, "Create an additional terminal frame.\n\
You can create multiple frames on a text-only terminal in this way.\n\
Only the selected terminal frame is actually displayed.\n\
This function takes one argument, an alist specifying frame parameters.\n\
In practice, generally you don't need to specify any parameters.\n\
Note that changing the size of one terminal frame automatically affects all.")
  (parms)
     Lisp_Object parms;
{
  struct frame *f;
  Lisp_Object frame;

#ifdef MSDOS
  if (selected_frame->output_method != output_msdos_raw)
    abort ();
#else
  if (selected_frame->output_method != output_termcap)
    error ("Not using an ASCII terminal now; cannot make a new ASCII frame");
#endif

  f = make_terminal_frame ();
  change_frame_size (f, FRAME_HEIGHT (selected_frame),
		     FRAME_WIDTH (selected_frame), 0, 0);
  remake_frame_glyphs (f);
  calculate_costs (f);
  XSETFRAME (frame, f);
  Fmodify_frame_parameters (frame, Vdefault_frame_alist);
  Fmodify_frame_parameters (frame, parms);
  f->face_alist = selected_frame->face_alist;
  return frame;
}

Lisp_Object
do_switch_frame (frame, no_enter, track)
     Lisp_Object frame, no_enter;
     int track;
{
  /* If FRAME is a switch-frame event, extract the frame we should
     switch to.  */
  if (CONSP (frame)
      && EQ (XCONS (frame)->car, Qswitch_frame)
      && CONSP (XCONS (frame)->cdr))
    frame = XCONS (XCONS (frame)->cdr)->car;

  /* This used to say CHECK_LIVE_FRAME, but apparently it's possible for
     a switch-frame event to arrive after a frame is no longer live,
     especially when deleting the initial frame during startup.  */
  CHECK_FRAME (frame, 0);
  if (! FRAME_LIVE_P (XFRAME (frame)))
    return Qnil;

  if (selected_frame == XFRAME (frame))
    return frame;

  /* This is too greedy; it causes inappropriate focus redirection
     that's hard to get rid of.  */
#if 0
  /* If a frame's focus has been redirected toward the currently
     selected frame, we should change the redirection to point to the
     newly selected frame.  This means that if the focus is redirected
     from a minibufferless frame to a surrogate minibuffer frame, we
     can use `other-window' to switch between all the frames using
     that minibuffer frame, and the focus redirection will follow us
     around.  */
  if (track)
    {
      Lisp_Object tail;

      for (tail = Vframe_list; CONSP (tail); tail = XCONS (tail)->cdr)
	{
	  Lisp_Object focus;

	  if (!FRAMEP (XCONS (tail)->car))
	    abort ();

	  focus = FRAME_FOCUS_FRAME (XFRAME (XCONS (tail)->car));

	  if (FRAMEP (focus) && XFRAME (focus) == selected_frame)
	    Fredirect_frame_focus (XCONS (tail)->car, frame);
	}
    }
#else /* ! 0 */
  /* Instead, apply it only to the frame we're pointing to.  */
#ifdef HAVE_WINDOW_SYSTEM
  if (track && (FRAME_WINDOW_P (XFRAME (frame))))
    {
      Lisp_Object focus, xfocus;

      xfocus = x_get_focus_frame (XFRAME (frame));
      if (FRAMEP (xfocus))
	{
	  focus = FRAME_FOCUS_FRAME (XFRAME (xfocus));
	  if (FRAMEP (focus) && XFRAME (focus) == selected_frame)
	    Fredirect_frame_focus (xfocus, frame);
	}
    }
#endif /* HAVE_X_WINDOWS */
#endif /* ! 0 */

  selected_frame = XFRAME (frame);
  if (! FRAME_MINIBUF_ONLY_P (selected_frame))
    last_nonminibuf_frame = selected_frame;

  Fselect_window (XFRAME (frame)->selected_window);

  /* We want to make sure that the next event generates a frame-switch
     event to the appropriate frame.  This seems kludgy to me, but
     before you take it out, make sure that evaluating something like
     (select-window (frame-root-window (new-frame))) doesn't end up
     with your typing being interpreted in the new frame instead of
     the one you're actually typing in.  */
  internal_last_event_frame = Qnil;

  return frame;
}

DEFUN ("select-frame", Fselect_frame, Sselect_frame, 1, 2, "e",
  "Select the frame FRAME.\n\
Subsequent editing commands apply to its selected window.\n\
The selection of FRAME lasts until the next time the user does\n\
something to select a different frame, or until the next time this\n\
function is called.")
  (frame, no_enter)
    Lisp_Object frame, no_enter;
{
  return do_switch_frame (frame, no_enter, 1);
}


DEFUN ("handle-switch-frame", Fhandle_switch_frame, Shandle_switch_frame, 1, 2, "e",
  "Handle a switch-frame event EVENT.\n\
Switch-frame events are usually bound to this function.\n\
A switch-frame event tells Emacs that the window manager has requested\n\
that the user's events be directed to the frame mentioned in the event.\n\
This function selects the selected window of the frame of EVENT.\n\
\n\
If EVENT is frame object, handle it as if it were a switch-frame event\n\
to that frame.")
  (event, no_enter)
     Lisp_Object event, no_enter;
{
  /* Preserve prefix arg that the command loop just cleared.  */
  current_kboard->Vprefix_arg = Vcurrent_prefix_arg;
  call1 (Vrun_hooks, Qmouse_leave_buffer_hook);
  return do_switch_frame (event, no_enter, 0);
}

DEFUN ("ignore-event", Fignore_event, Signore_event, 0, 0, "",
  "Do nothing, but preserve any prefix argument already specified.\n\
This is a suitable binding for iconify-frame and make-frame-visible.")
     ()
{
  current_kboard->Vprefix_arg = Vcurrent_prefix_arg;
  return Qnil;
}

DEFUN ("selected-frame", Fselected_frame, Sselected_frame, 0, 0, 0,
  "Return the frame that is now selected.")
  ()
{
  Lisp_Object tem;
  XSETFRAME (tem, selected_frame);
  return tem;
}

DEFUN ("window-frame", Fwindow_frame, Swindow_frame, 1, 1, 0,
  "Return the frame object that window WINDOW is on.")
  (window)
     Lisp_Object window;
{
  CHECK_LIVE_WINDOW (window, 0);
  return XWINDOW (window)->frame;
}

DEFUN ("frame-first-window", Fframe_first_window, Sframe_first_window, 0, 1, 0,
  "Returns the topmost, leftmost window of FRAME.\n\
If omitted, FRAME defaults to the currently selected frame.")
  (frame)
     Lisp_Object frame;
{
  Lisp_Object w;

  if (NILP (frame))
    w = selected_frame->root_window;
  else
    {
      CHECK_LIVE_FRAME (frame, 0);
      w = XFRAME (frame)->root_window;
    }
  while (NILP (XWINDOW (w)->buffer))
    {
      if (! NILP (XWINDOW (w)->hchild))
	w = XWINDOW (w)->hchild;
      else if (! NILP (XWINDOW (w)->vchild))
	w = XWINDOW (w)->vchild;
      else
	abort ();
    }
  return w;
}

DEFUN ("active-minibuffer-window", Factive_minibuffer_window,
       Sactive_minibuffer_window, 0, 0, 0,
       "Return the currently active minibuffer window, or nil if none.")
  ()
{
  return minibuf_level ? minibuf_window : Qnil;
}

DEFUN ("frame-root-window", Fframe_root_window, Sframe_root_window, 0, 1, 0,
       "Returns the root-window of FRAME.\n\
If omitted, FRAME defaults to the currently selected frame.")
  (frame)
     Lisp_Object frame;
{
  if (NILP (frame))
    XSETFRAME (frame, selected_frame);
  else
    CHECK_LIVE_FRAME (frame, 0);

  return XFRAME (frame)->root_window;
}

DEFUN ("frame-selected-window", Fframe_selected_window,
       Sframe_selected_window, 0, 1, 0,
  "Return the selected window of frame object FRAME.\n\
If omitted, FRAME defaults to the currently selected frame.")
  (frame)
     Lisp_Object frame;
{
  if (NILP (frame))
    XSETFRAME (frame, selected_frame);
  else
    CHECK_LIVE_FRAME (frame, 0);

  return XFRAME (frame)->selected_window;
}

DEFUN ("set-frame-selected-window", Fset_frame_selected_window,
       Sset_frame_selected_window, 2, 2, 0,
  "Set the selected window of frame object FRAME to WINDOW.\n\
If FRAME is nil, the selected frame is used.\n\
If FRAME is the selected frame, this makes WINDOW the selected window.")
  (frame, window)
     Lisp_Object frame, window;
{
  if (NILP (frame))
    XSETFRAME (frame, selected_frame);
  else
    CHECK_LIVE_FRAME (frame, 0);

  CHECK_LIVE_WINDOW (window, 1);

  if (! EQ (frame, WINDOW_FRAME (XWINDOW (window))))
    error ("In `set-frame-selected-window', WINDOW is not on FRAME");

  if (XFRAME (frame) == selected_frame)
    return Fselect_window (window);

  return XFRAME (frame)->selected_window = window;
}

DEFUN ("frame-list", Fframe_list, Sframe_list,
       0, 0, 0,
       "Return a list of all frames.")
  ()
{
  return Fcopy_sequence (Vframe_list);
}

/* Return the next frame in the frame list after FRAME.
   If MINIBUF is nil, exclude minibuffer-only frames.
   If MINIBUF is a window, include only its own frame
   and any frame now using that window as the minibuffer.
   If MINIBUF is `visible', include all visible frames.
   If MINIBUF is 0, include all visible and iconified frames.
   Otherwise, include all frames.  */

Lisp_Object
next_frame (frame, minibuf)
     Lisp_Object frame;
     Lisp_Object minibuf;
{
  Lisp_Object tail;
  int passed = 0;

  /* There must always be at least one frame in Vframe_list.  */
  if (! CONSP (Vframe_list))
    abort ();

  /* If this frame is dead, it won't be in Vframe_list, and we'll loop
     forever.  Forestall that.  */
  CHECK_LIVE_FRAME (frame, 0);

  while (1)
    for (tail = Vframe_list; CONSP (tail); tail = XCONS (tail)->cdr)
      {
	Lisp_Object f;

	f = XCONS (tail)->car;

	if (passed
	    && FRAME_KBOARD (XFRAME (f)) == FRAME_KBOARD (XFRAME (frame)))
	  {
	    /* Decide whether this frame is eligible to be returned.  */

	    /* If we've looped all the way around without finding any
	       eligible frames, return the original frame.  */
	    if (EQ (f, frame))
	      return f;

	    /* Let minibuf decide if this frame is acceptable.  */
	    if (NILP (minibuf))
	      {
		if (! FRAME_MINIBUF_ONLY_P (XFRAME (f)))
		  return f;
	      }
	    else if (EQ (minibuf, Qvisible))
	      {
		FRAME_SAMPLE_VISIBILITY (XFRAME (f));
		if (FRAME_VISIBLE_P (XFRAME (f)))
		  return f;
	      }
	    else if (XFASTINT (minibuf) == 0)
	      {
		FRAME_SAMPLE_VISIBILITY (XFRAME (f));
		if (FRAME_VISIBLE_P (XFRAME (f))
		    || FRAME_ICONIFIED_P (XFRAME (f)))
		  return f;
	      }
	    else if (WINDOWP (minibuf))
	      {
		if (EQ (FRAME_MINIBUF_WINDOW (XFRAME (f)), minibuf)
		    /* Check that F either is, or has forwarded its focus to,
		       MINIBUF's frame.  */
		    && (EQ (WINDOW_FRAME (XWINDOW (minibuf)), f)
			|| EQ (WINDOW_FRAME (XWINDOW (minibuf)),
			       FRAME_FOCUS_FRAME (XFRAME (f)))))
		  return f;
	      }
	    else
	      return f;
	  }

	if (EQ (frame, f))
	  passed++;
      }
}

/* Return the previous frame in the frame list before FRAME.
   If MINIBUF is nil, exclude minibuffer-only frames.
   If MINIBUF is a window, include only its own frame
   and any frame now using that window as the minibuffer.
   If MINIBUF is `visible', include all visible frames.
   If MINIBUF is 0, include all visible and iconified frames.
   Otherwise, include all frames.  */

Lisp_Object
prev_frame (frame, minibuf)
     Lisp_Object frame;
     Lisp_Object minibuf;
{
  Lisp_Object tail;
  Lisp_Object prev;

  /* There must always be at least one frame in Vframe_list.  */
  if (! CONSP (Vframe_list))
    abort ();

  prev = Qnil;
  for (tail = Vframe_list; CONSP (tail); tail = XCONS (tail)->cdr)
    {
      Lisp_Object f;

      f = XCONS (tail)->car;
      if (!FRAMEP (f))
	abort ();

      if (EQ (frame, f) && !NILP (prev))
	return prev;

      if (FRAME_KBOARD (XFRAME (f)) == FRAME_KBOARD (XFRAME (frame)))
	{
	  /* Decide whether this frame is eligible to be returned,
	     according to minibuf.  */
	  if (NILP (minibuf))
	    {
	      if (! FRAME_MINIBUF_ONLY_P (XFRAME (f)))
		prev = f;
	    }
	  else if (WINDOWP (minibuf))
	    {
	      if (EQ (FRAME_MINIBUF_WINDOW (XFRAME (f)), minibuf)
		  /* Check that F either is, or has forwarded its focus to,
		     MINIBUF's frame.  */
		  && (EQ (WINDOW_FRAME (XWINDOW (minibuf)), f)
		      || EQ (WINDOW_FRAME (XWINDOW (minibuf)),
			     FRAME_FOCUS_FRAME (XFRAME (f)))))
		prev = f;
	    }
	  else if (EQ (minibuf, Qvisible))
	    {
	      FRAME_SAMPLE_VISIBILITY (XFRAME (f));
	      if (FRAME_VISIBLE_P (XFRAME (f)))
		prev = f;
	    }
	  else if (XFASTINT (minibuf) == 0)
	    {
	      FRAME_SAMPLE_VISIBILITY (XFRAME (f));
	      if (FRAME_VISIBLE_P (XFRAME (f))
		  || FRAME_ICONIFIED_P (XFRAME (f)))
		prev = f;
	    }
	  else
	    prev = f;
	}
    }

  /* We've scanned the entire list.  */
  if (NILP (prev))
    /* We went through the whole frame list without finding a single
       acceptable frame.  Return the original frame.  */
    return frame;
  else
    /* There were no acceptable frames in the list before FRAME; otherwise,
       we would have returned directly from the loop.  Since PREV is the last
       acceptable frame in the list, return it.  */
    return prev;
}


DEFUN ("next-frame", Fnext_frame, Snext_frame, 0, 2, 0,
  "Return the next frame in the frame list after FRAME.\n\
It considers only frames on the same terminal as FRAME.\n\
By default, skip minibuffer-only frames.\n\
If omitted, FRAME defaults to the selected frame.\n\
If optional argument MINIFRAME is nil, exclude minibuffer-only frames.\n\
If MINIFRAME is a window, include only its own frame\n\
and any frame now using that window as the minibuffer.\n\
If MINIFRAME is `visible', include all visible frames.\n\
If MINIFRAME is 0, include all visible and iconified frames.\n\
Otherwise, include all frames.")
  (frame, miniframe)
     Lisp_Object frame, miniframe;
{
  Lisp_Object tail;

  if (NILP (frame))
    XSETFRAME (frame, selected_frame);
  else
    CHECK_LIVE_FRAME (frame, 0);

  return next_frame (frame, miniframe);
}

DEFUN ("previous-frame", Fprevious_frame, Sprevious_frame, 0, 2, 0,
  "Return the previous frame in the frame list before FRAME.\n\
It considers only frames on the same terminal as FRAME.\n\
By default, skip minibuffer-only frames.\n\
If omitted, FRAME defaults to the selected frame.\n\
If optional argument MINIFRAME is nil, exclude minibuffer-only frames.\n\
If MINIFRAME is a window, include only its own frame\n\
and any frame now using that window as the minibuffer.\n\
If MINIFRAME is `visible', include all visible frames.\n\
If MINIFRAME is 0, include all visible and iconified frames.\n\
Otherwise, include all frames.")
  (frame, miniframe)
     Lisp_Object frame, miniframe;
{
  Lisp_Object tail;

  if (NILP (frame))
    XSETFRAME (frame, selected_frame);
  else
    CHECK_LIVE_FRAME (frame, 0);

  return prev_frame (frame, miniframe);
}

/* Return 1 if it is ok to delete frame F;
   0 if all frames aside from F are invisible.
   (Exception: if F is the terminal frame, and we are using X, return 1.)  */

int
other_visible_frames (f)
     FRAME_PTR f;
{
  /* We know the selected frame is visible,
     so if F is some other frame, it can't be the sole visible one.  */
  if (f == selected_frame)
    {
      Lisp_Object frames;
      int count = 0;

      for (frames = Vframe_list;
	   CONSP (frames);
	   frames = XCONS (frames)->cdr)
	{
	  Lisp_Object this;

	  this = XCONS (frames)->car;
	  /* Verify that the frame's window still exists
	     and we can still talk to it.  And note any recent change
	     in visibility.  */
#ifdef HAVE_WINDOW_SYSTEM
	  if (FRAME_WINDOW_P (XFRAME (this)))
	    {
	      x_sync (XFRAME (this));
	      FRAME_SAMPLE_VISIBILITY (XFRAME (this));
	    }
#endif

	  if (FRAME_VISIBLE_P (XFRAME (this))
	      || FRAME_ICONIFIED_P (XFRAME (this))
	      /* Allow deleting the terminal frame when at least
		 one X frame exists!  */
	      || (FRAME_WINDOW_P (XFRAME (this)) && !FRAME_WINDOW_P (f)))
	    count++;
	}
      return count > 1;
    }
  return 1;
}

DEFUN ("delete-frame", Fdelete_frame, Sdelete_frame, 0, 2, "",
  "Delete FRAME, permanently eliminating it from use.\n\
If omitted, FRAME defaults to the selected frame.\n\
A frame may not be deleted if its minibuffer is used by other frames.\n\
Normally, you may not delete a frame if all other frames are invisible,\n\
but if the second optional argument FORCE is non-nil, you may do so.")
  (frame, force)
     Lisp_Object frame, force;
{
  struct frame *f;
  int minibuffer_selected;

  if (EQ (frame, Qnil))
    {
      f = selected_frame;
      XSETFRAME (frame, f);
    }
  else
    {
      CHECK_FRAME (frame, 0);
      f = XFRAME (frame);
    }

  if (! FRAME_LIVE_P (f))
    return Qnil;

  if (NILP (force) && !other_visible_frames (f))
    error ("Attempt to delete the sole visible or iconified frame");

#if 0
  /* This is a nice idea, but x_connection_closed needs to be able
     to delete the last frame, if it is gone.  */
  if (NILP (XCONS (Vframe_list)->cdr))
    error ("Attempt to delete the only frame");
#endif

  /* Does this frame have a minibuffer, and is it the surrogate
     minibuffer for any other frame?  */
  if (FRAME_HAS_MINIBUF_P (XFRAME (frame)))
    {
      Lisp_Object frames;

      for (frames = Vframe_list;
	   CONSP (frames);
	   frames = XCONS (frames)->cdr)
	{
	  Lisp_Object this;
	  this = XCONS (frames)->car;

	  if (! EQ (this, frame)
	      && EQ (frame,
		     WINDOW_FRAME (XWINDOW
				   (FRAME_MINIBUF_WINDOW (XFRAME (this))))))
	    error ("Attempt to delete a surrogate minibuffer frame");
	}
    }

  minibuffer_selected = EQ (minibuf_window, selected_window);

  /* Don't let the frame remain selected.  */
  if (f == selected_frame)
    {
      Lisp_Object tail, frame1;

      /* Look for another visible frame on the same terminal.  */
      frame1 = next_frame (frame, Qvisible);

      /* If there is none, find *some* other frame.  */
      if (NILP (frame1) || EQ (frame1, frame))
	{
	  FOR_EACH_FRAME (tail, frame1)
	    {
	      if (! EQ (frame, frame1))
		break;
	    }
	}

      do_switch_frame (frame1, Qnil, 0);
    }

  /* Don't allow minibuf_window to remain on a deleted frame.  */
  if (EQ (f->minibuffer_window, minibuf_window))
    {
      Fset_window_buffer (selected_frame->minibuffer_window,
			  XWINDOW (minibuf_window)->buffer);
      minibuf_window = selected_frame->minibuffer_window;

      /* If the dying minibuffer window was selected,
	 select the new one.  */
      if (minibuffer_selected)
	Fselect_window (minibuf_window);
    }

  /* Clear any X selections for this frame.  */
#ifdef HAVE_X_WINDOWS
  if (FRAME_X_P (f))
    x_clear_frame_selections (f);
#endif

  /* Mark all the windows that used to be on FRAME as deleted, and then
     remove the reference to them.  */
  delete_all_subwindows (XWINDOW (f->root_window));
  f->root_window = Qnil;

  Vframe_list = Fdelq (frame, Vframe_list);
  FRAME_SET_VISIBLE (f, 0);

  if (echo_area_glyphs == FRAME_MESSAGE_BUF (f))
    {
      echo_area_glyphs = 0;
      previous_echo_glyphs = 0;
    }

  if (f->namebuf)
    free (f->namebuf);
  if (FRAME_CURRENT_GLYPHS (f))
    free_frame_glyphs (f, FRAME_CURRENT_GLYPHS (f));
  if (FRAME_DESIRED_GLYPHS (f))
    free_frame_glyphs (f, FRAME_DESIRED_GLYPHS (f));
  if (FRAME_TEMP_GLYPHS (f))
    free_frame_glyphs (f, FRAME_TEMP_GLYPHS (f));
  if (FRAME_INSERT_COST (f))
    free (FRAME_INSERT_COST (f));
  if (FRAME_DELETEN_COST (f))
    free (FRAME_DELETEN_COST (f));
  if (FRAME_INSERTN_COST (f))
    free (FRAME_INSERTN_COST (f));
  if (FRAME_DELETE_COST (f))
    free (FRAME_DELETE_COST (f));
  if (FRAME_MESSAGE_BUF (f))
    free (FRAME_MESSAGE_BUF (f));

#ifdef HAVE_WINDOW_SYSTEM
  /* Free all fontset data.  */
  free_fontset_data (FRAME_FONTSET_DATA (f));
#endif

  /* Since some events are handled at the interrupt level, we may get
     an event for f at any time; if we zero out the frame's display
     now, then we may trip up the event-handling code.  Instead, we'll
     promise that the display of the frame must be valid until we have
     called the window-system-dependent frame destruction routine.  */

  /* I think this should be done with a hook.  */
#ifdef HAVE_WINDOW_SYSTEM
  if (FRAME_WINDOW_P (f))
    x_destroy_window (f);
#endif

  f->output_data.nothing = 0;

  /* If we've deleted the last_nonminibuf_frame, then try to find
     another one.  */
  if (f == last_nonminibuf_frame)
    {
      Lisp_Object frames;

      last_nonminibuf_frame = 0;

      for (frames = Vframe_list;
	   CONSP (frames);
	   frames = XCONS (frames)->cdr)
	{
	  f = XFRAME (XCONS (frames)->car);
	  if (!FRAME_MINIBUF_ONLY_P (f))
	    {
	      last_nonminibuf_frame = f;
	      break;
	    }
	}
    }

  /* If we've deleted this keyboard's default_minibuffer_frame, try to
     find another one.  Prefer minibuffer-only frames, but also notice
     frames with other windows.  */
  if (EQ (frame, FRAME_KBOARD (f)->Vdefault_minibuffer_frame))
    {
      Lisp_Object frames;

      /* The last frame we saw with a minibuffer, minibuffer-only or not.  */
      Lisp_Object frame_with_minibuf;
      /* Some frame we found on the same kboard, or nil if there are none.  */
      Lisp_Object frame_on_same_kboard;

      frame_on_same_kboard = Qnil;
      frame_with_minibuf = Qnil;

      for (frames = Vframe_list;
	   CONSP (frames);
	   frames = XCONS (frames)->cdr)
	{
	  Lisp_Object this;
	  struct frame *f1;

	  this = XCONS (frames)->car;
	  if (!FRAMEP (this))
	    abort ();
	  f1 = XFRAME (this);

	  /* Consider only frames on the same kboard
	     and only those with minibuffers.  */
	  if (FRAME_KBOARD (f) == FRAME_KBOARD (f1)
	      && FRAME_HAS_MINIBUF_P (f1))
	    {
	      frame_with_minibuf = this;
	      if (FRAME_MINIBUF_ONLY_P (f1))
		break;
	    }

	  if (FRAME_KBOARD (f) == FRAME_KBOARD (f1))
	    frame_on_same_kboard = this;
	}

      if (!NILP (frame_on_same_kboard))
	{
	  /* We know that there must be some frame with a minibuffer out
	     there.  If this were not true, all of the frames present
	     would have to be minibufferless, which implies that at some
	     point their minibuffer frames must have been deleted, but
	     that is prohibited at the top; you can't delete surrogate
	     minibuffer frames.  */
	  if (NILP (frame_with_minibuf))
	    abort ();

	  FRAME_KBOARD (f)->Vdefault_minibuffer_frame = frame_with_minibuf;
	}
      else
	/* No frames left on this kboard--say no minibuffer either.  */
	FRAME_KBOARD (f)->Vdefault_minibuffer_frame = Qnil;
    }

  /* Cause frame titles to update--necessary if we now have just one frame.  */
  update_mode_lines = 1;

  return Qnil;
}

/* Return mouse position in character cell units.  */

DEFUN ("mouse-position", Fmouse_position, Smouse_position, 0, 0, 0,
  "Return a list (FRAME X . Y) giving the current mouse frame and position.\n\
The position is given in character cells, where (0, 0) is the\n\
upper-left corner.\n\
If Emacs is running on a mouseless terminal or hasn't been programmed\n\
to read the mouse position, it returns the selected frame for FRAME\n\
and nil for X and Y.")
  ()
{
  FRAME_PTR f;
  Lisp_Object lispy_dummy;
  enum scroll_bar_part party_dummy;
  Lisp_Object x, y;
  int col, row;
  unsigned long long_dummy;

  f = selected_frame;
  x = y = Qnil;

#ifdef HAVE_MOUSE
  /* It's okay for the hook to refrain from storing anything.  */
  if (mouse_position_hook)
    (*mouse_position_hook) (&f, -1,
			    &lispy_dummy, &party_dummy,
			    &x, &y,
			    &long_dummy);
  if (! NILP (x))
    {
      col = XINT (x);
      row = XINT (y);
      pixel_to_glyph_coords (f, col, row, &col, &row, NULL, 1);
      XSETINT (x, col);
      XSETINT (y, row);
    }
#endif
  XSETFRAME (lispy_dummy, f);
  return Fcons (lispy_dummy, Fcons (x, y));
}

DEFUN ("mouse-pixel-position", Fmouse_pixel_position,
       Smouse_pixel_position, 0, 0, 0,
  "Return a list (FRAME X . Y) giving the current mouse frame and position.\n\
The position is given in pixel units, where (0, 0) is the\n\
upper-left corner.\n\
If Emacs is running on a mouseless terminal or hasn't been programmed\n\
to read the mouse position, it returns the selected frame for FRAME\n\
and nil for X and Y.")
  ()
{
  FRAME_PTR f;
  Lisp_Object lispy_dummy;
  enum scroll_bar_part party_dummy;
  Lisp_Object x, y;
  int col, row;
  unsigned long long_dummy;

  f = selected_frame;
  x = y = Qnil;

#ifdef HAVE_MOUSE
  /* It's okay for the hook to refrain from storing anything.  */
  if (mouse_position_hook)
    (*mouse_position_hook) (&f, -1,
			    &lispy_dummy, &party_dummy,
			    &x, &y,
			    &long_dummy);
#endif
  XSETFRAME (lispy_dummy, f);
  return Fcons (lispy_dummy, Fcons (x, y));
}

DEFUN ("set-mouse-position", Fset_mouse_position, Sset_mouse_position, 3, 3, 0,
  "Move the mouse pointer to the center of character cell (X,Y) in FRAME.\n\
Coordinates are relative to the frame, not a window,\n\
so the coordinates of the top left character in the frame\n\
may be nonzero due to left-hand scroll bars or the menu bar.\n\
\n\
This function is a no-op for an X frame that is not visible.\n\
If you have just created a frame, you must wait for it to become visible\n\
before calling this function on it, like this.\n\
  (while (not (frame-visible-p frame)) (sleep-for .5))")
  (frame, x, y)
     Lisp_Object frame, x, y;
{
  CHECK_LIVE_FRAME (frame, 0);
  CHECK_NUMBER (x, 2);
  CHECK_NUMBER (y, 1);

  /* I think this should be done with a hook.  */
#ifdef HAVE_WINDOW_SYSTEM
  if (FRAME_WINDOW_P (XFRAME (frame)))
    /* Warping the mouse will cause  enternotify and focus events. */
    x_set_mouse_position (XFRAME (frame), XINT (x), XINT (y));
#else
#if defined (MSDOS) && defined (HAVE_MOUSE)
  if (FRAME_MSDOS_P (XFRAME (frame)))
    {
      Fselect_frame (frame, Qnil);
      mouse_moveto (XINT (x), XINT (y));
    }
#endif
#endif

  return Qnil;
}

DEFUN ("set-mouse-pixel-position", Fset_mouse_pixel_position,
       Sset_mouse_pixel_position, 3, 3, 0,
  "Move the mouse pointer to pixel position (X,Y) in FRAME.\n\
Note, this is a no-op for an X frame that is not visible.\n\
If you have just created a frame, you must wait for it to become visible\n\
before calling this function on it, like this.\n\
  (while (not (frame-visible-p frame)) (sleep-for .5))")
  (frame, x, y)
     Lisp_Object frame, x, y;
{
  CHECK_LIVE_FRAME (frame, 0);
  CHECK_NUMBER (x, 2);
  CHECK_NUMBER (y, 1);

  /* I think this should be done with a hook.  */
#ifdef HAVE_WINDOW_SYSTEM
  if (FRAME_WINDOW_P (XFRAME (frame)))
    /* Warping the mouse will cause  enternotify and focus events. */
    x_set_mouse_pixel_position (XFRAME (frame), XINT (x), XINT (y));
#else
#if defined (MSDOS) && defined (HAVE_MOUSE)
  if (FRAME_MSDOS_P (XFRAME (frame)))
    {
      Fselect_frame (frame, Qnil);
      mouse_moveto (XINT (x), XINT (y));
    }
#endif
#endif

  return Qnil;
}

static void make_frame_visible_1 P_ ((Lisp_Object));

DEFUN ("make-frame-visible", Fmake_frame_visible, Smake_frame_visible,
       0, 1, "",
  "Make the frame FRAME visible (assuming it is an X-window).\n\
If omitted, FRAME defaults to the currently selected frame.")
  (frame)
     Lisp_Object frame;
{
  if (NILP (frame))
    XSETFRAME (frame, selected_frame);

  CHECK_LIVE_FRAME (frame, 0);

  /* I think this should be done with a hook.  */
#ifdef HAVE_WINDOW_SYSTEM
  if (FRAME_WINDOW_P (XFRAME (frame)))
    {
      FRAME_SAMPLE_VISIBILITY (XFRAME (frame));
      x_make_frame_visible (XFRAME (frame));
    }
#endif

  make_frame_visible_1 (XFRAME (frame)->root_window);

  /* Make menu bar update for the Buffers and Frams menus.  */
  windows_or_buffers_changed++;

  return frame;
}

/* Update the display_time slot of the buffers shown in WINDOW
   and all its descendents.  */

static void
make_frame_visible_1 (window)
     Lisp_Object window;
{
  struct window *w;

  for (;!NILP (window); window = w->next)
    {
      w = XWINDOW (window);

      if (!NILP (w->buffer))
	XBUFFER (w->buffer)->display_time = Fcurrent_time ();

      if (!NILP (w->vchild))
	make_frame_visible_1 (w->vchild);
      if (!NILP (w->hchild))
	make_frame_visible_1 (w->hchild);
    }
}

DEFUN ("make-frame-invisible", Fmake_frame_invisible, Smake_frame_invisible,
       0, 2, "",
  "Make the frame FRAME invisible (assuming it is an X-window).\n\
If omitted, FRAME defaults to the currently selected frame.\n\
Normally you may not make FRAME invisible if all other frames are invisible,\n\
but if the second optional argument FORCE is non-nil, you may do so.")
  (frame, force)
     Lisp_Object frame, force;
{
  if (NILP (frame))
    XSETFRAME (frame, selected_frame);

  CHECK_LIVE_FRAME (frame, 0);

  if (NILP (force) && !other_visible_frames (XFRAME (frame)))
    error ("Attempt to make invisible the sole visible or iconified frame");

#if 0 /* This isn't logically necessary, and it can do GC.  */
  /* Don't let the frame remain selected.  */
  if (XFRAME (frame) == selected_frame)
    do_switch_frame (next_frame (frame, Qt), Qnil, 0)
#endif

  /* Don't allow minibuf_window to remain on a deleted frame.  */
  if (EQ (XFRAME (frame)->minibuffer_window, minibuf_window))
    {
      Fset_window_buffer (selected_frame->minibuffer_window,
			  XWINDOW (minibuf_window)->buffer);
      minibuf_window = selected_frame->minibuffer_window;
    }

  /* I think this should be done with a hook.  */
#ifdef HAVE_WINDOW_SYSTEM
  if (FRAME_WINDOW_P (XFRAME (frame)))
    x_make_frame_invisible (XFRAME (frame));
#endif

  /* Make menu bar update for the Buffers and Frams menus.  */
  windows_or_buffers_changed++;

  return Qnil;
}

DEFUN ("iconify-frame", Ficonify_frame, Siconify_frame,
       0, 1, "",
  "Make the frame FRAME into an icon.\n\
If omitted, FRAME defaults to the currently selected frame.")
  (frame)
     Lisp_Object frame;
{
  if (NILP (frame))
    XSETFRAME (frame, selected_frame);
  
  CHECK_LIVE_FRAME (frame, 0);

#if 0 /* This isn't logically necessary, and it can do GC.  */
  /* Don't let the frame remain selected.  */
  if (XFRAME (frame) == selected_frame)
    Fhandle_switch_frame (next_frame (frame, Qt), Qnil);
#endif

  /* Don't allow minibuf_window to remain on a deleted frame.  */
  if (EQ (XFRAME (frame)->minibuffer_window, minibuf_window))
    {
      Fset_window_buffer (selected_frame->minibuffer_window,
			  XWINDOW (minibuf_window)->buffer);
      minibuf_window = selected_frame->minibuffer_window;
    }

  /* I think this should be done with a hook.  */
#ifdef HAVE_WINDOW_SYSTEM
  if (FRAME_WINDOW_P (XFRAME (frame)))
      x_iconify_frame (XFRAME (frame));
#endif

  /* Make menu bar update for the Buffers and Frams menus.  */
  windows_or_buffers_changed++;

  return Qnil;
}

DEFUN ("frame-visible-p", Fframe_visible_p, Sframe_visible_p,
       1, 1, 0,
       "Return t if FRAME is now \"visible\" (actually in use for display).\n\
A frame that is not \"visible\" is not updated and, if it works through\n\
a window system, it may not show at all.\n\
Return the symbol `icon' if frame is visible only as an icon.")
  (frame)
     Lisp_Object frame;
{
  CHECK_LIVE_FRAME (frame, 0);

  FRAME_SAMPLE_VISIBILITY (XFRAME (frame));

  if (FRAME_VISIBLE_P (XFRAME (frame)))
    return Qt;
  if (FRAME_ICONIFIED_P (XFRAME (frame)))
    return Qicon;
  return Qnil;
}

DEFUN ("visible-frame-list", Fvisible_frame_list, Svisible_frame_list,
       0, 0, 0,
       "Return a list of all frames now \"visible\" (being updated).")
  ()
{
  Lisp_Object tail, frame;
  struct frame *f;
  Lisp_Object value;

  value = Qnil;
  for (tail = Vframe_list; CONSP (tail); tail = XCONS (tail)->cdr)
    {
      frame = XCONS (tail)->car;
      if (!FRAMEP (frame))
	continue;
      f = XFRAME (frame);
      if (FRAME_VISIBLE_P (f))
	value = Fcons (frame, value);
    }
  return value;
}


DEFUN ("raise-frame", Fraise_frame, Sraise_frame, 0, 1, "",
  "Bring FRAME to the front, so it occludes any frames it overlaps.\n\
If FRAME is invisible, make it visible.\n\
If you don't specify a frame, the selected frame is used.\n\
If Emacs is displaying on an ordinary terminal or some other device which\n\
doesn't support multiple overlapping frames, this function does nothing.")
  (frame)
     Lisp_Object frame;
{
  if (NILP (frame))
    XSETFRAME (frame, selected_frame);

  CHECK_LIVE_FRAME (frame, 0);

  /* Do like the documentation says. */
  Fmake_frame_visible (frame);

  if (frame_raise_lower_hook)
    (*frame_raise_lower_hook) (XFRAME (frame), 1);

  return Qnil;
}

/* Should we have a corresponding function called Flower_Power?  */
DEFUN ("lower-frame", Flower_frame, Slower_frame, 0, 1, "",
  "Send FRAME to the back, so it is occluded by any frames that overlap it.\n\
If you don't specify a frame, the selected frame is used.\n\
If Emacs is displaying on an ordinary terminal or some other device which\n\
doesn't support multiple overlapping frames, this function does nothing.")
  (frame)
     Lisp_Object frame;
{
  if (NILP (frame))
    XSETFRAME (frame, selected_frame);

  CHECK_LIVE_FRAME (frame, 0);
  
  if (frame_raise_lower_hook)
    (*frame_raise_lower_hook) (XFRAME (frame), 0);

  return Qnil;
}


DEFUN ("redirect-frame-focus", Fredirect_frame_focus, Sredirect_frame_focus,
       1, 2, 0,
  "Arrange for keystrokes typed at FRAME to be sent to FOCUS-FRAME.\n\
In other words, switch-frame events caused by events in FRAME will\n\
request a switch to FOCUS-FRAME, and `last-event-frame' will be\n\
FOCUS-FRAME after reading an event typed at FRAME.\n\
\n\
If FOCUS-FRAME is omitted or nil, any existing redirection is\n\
cancelled, and the frame again receives its own keystrokes.\n\
\n\
Focus redirection is useful for temporarily redirecting keystrokes to\n\
a surrogate minibuffer frame when a frame doesn't have its own\n\
minibuffer window.\n\
\n\
A frame's focus redirection can be changed by select-frame.  If frame\n\
FOO is selected, and then a different frame BAR is selected, any\n\
frames redirecting their focus to FOO are shifted to redirect their\n\
focus to BAR.  This allows focus redirection to work properly when the\n\
user switches from one frame to another using `select-window'.\n\
\n\
This means that a frame whose focus is redirected to itself is treated\n\
differently from a frame whose focus is redirected to nil; the former\n\
is affected by select-frame, while the latter is not.\n\
\n\
The redirection lasts until `redirect-frame-focus' is called to change it.")
  (frame, focus_frame)
    Lisp_Object frame, focus_frame;
{
  /* Note that we don't check for a live frame here.  It's reasonable
     to redirect the focus of a frame you're about to delete, if you
     know what other frame should receive those keystrokes.  */
  CHECK_FRAME (frame, 0);

  if (! NILP (focus_frame))
    CHECK_LIVE_FRAME (focus_frame, 1);

  XFRAME (frame)->focus_frame = focus_frame;

  if (frame_rehighlight_hook)
    (*frame_rehighlight_hook) (XFRAME (frame));
  
  return Qnil;
}


DEFUN ("frame-focus", Fframe_focus, Sframe_focus, 1, 1, 0,
  "Return the frame to which FRAME's keystrokes are currently being sent.\n\
This returns nil if FRAME's focus is not redirected.\n\
See `redirect-frame-focus'.")
  (frame)
    Lisp_Object frame;
{
  CHECK_LIVE_FRAME (frame, 0);

  return FRAME_FOCUS_FRAME (XFRAME (frame));
}



/* Return the value of frame parameter PROP in frame FRAME.  */

Lisp_Object
get_frame_param (frame, prop)
     register struct frame *frame;
     Lisp_Object prop;
{
  register Lisp_Object tem;

  tem = Fassq (prop, frame->param_alist);
  if (EQ (tem, Qnil))
    return tem;
  return Fcdr (tem);
}

/* Return the buffer-predicate of the selected frame.  */

Lisp_Object
frame_buffer_predicate (frame)
     Lisp_Object frame;
{
  return XFRAME (frame)->buffer_predicate;
}

/* Return the buffer-list of the selected frame.  */

Lisp_Object
frame_buffer_list (frame)
     Lisp_Object frame;
{
  return XFRAME (frame)->buffer_list;
}

/* Set the buffer-list of the selected frame.  */

void
set_frame_buffer_list (frame, list)
     Lisp_Object frame, list;
{
  XFRAME (frame)->buffer_list = list;
}

/* Discard BUFFER from the buffer-list of each frame.  */

void
frames_discard_buffer (buffer)
     Lisp_Object buffer;
{
  Lisp_Object frame, tail;

  FOR_EACH_FRAME (tail, frame)
    {
      XFRAME (frame)->buffer_list
	= Fdelq (buffer, XFRAME (frame)->buffer_list);
    }
}

/* Move BUFFER to the end of the buffer-list of each frame.  */

void
frames_bury_buffer (buffer)
     Lisp_Object buffer;
{
  Lisp_Object frame, tail;

  FOR_EACH_FRAME (tail, frame)
    {
      struct frame *f = XFRAME (frame);
      Lisp_Object found;
      
      found = Fmemq (buffer, f->buffer_list);
      if (!NILP (found))
	f->buffer_list = nconc2 (Fdelq (buffer, f->buffer_list),
				 Fcons (buffer, Qnil));
    }
}

/* Modify the alist in *ALISTPTR to associate PROP with VAL.
   If the alist already has an element for PROP, we change it.  */

void
store_in_alist (alistptr, prop, val)
     Lisp_Object *alistptr, val;
     Lisp_Object prop;
{
  register Lisp_Object tem;

  tem = Fassq (prop, *alistptr);
  if (EQ (tem, Qnil))
    *alistptr = Fcons (Fcons (prop, val), *alistptr);
  else
    Fsetcdr (tem, val);
}

static int
frame_name_fnn_p (str, len)
     char *str;
     int len;
{
  if (len > 1 && str[0] == 'F')
    {
      char *end_ptr;
      long num = strtol (str + 1, &end_ptr, 10);

      if (end_ptr == str + len)
	return 1;
    }
  return 0;
}

/* Set the name of the terminal frame.  Also used by MSDOS frames.
   Modeled after x_set_name which is used for WINDOW frames.  */

void
set_term_frame_name (f, name)
     struct frame *f;
     Lisp_Object name;
{
  f->explicit_name = ! NILP (name);

  /* If NAME is nil, set the name to F<num>.  */
  if (NILP (name))
    {
      char namebuf[20];

      /* Check for no change needed in this very common case
	 before we do any consing.  */
      if (frame_name_fnn_p (XSTRING (f->name)->data,
			    STRING_BYTES (XSTRING (f->name))))
	return;

      terminal_frame_count++;
      sprintf (namebuf, "F%d", terminal_frame_count);
      name = build_string (namebuf);
    }
  else
    {
      CHECK_STRING (name, 0);

      /* Don't change the name if it's already NAME.  */
      if (! NILP (Fstring_equal (name, f->name)))
	return;

      /* Don't allow the user to set the frame name to F<num>, so it
	 doesn't clash with the names we generate for terminal frames.  */
      if (frame_name_fnn_p (XSTRING (name)->data, STRING_BYTES (XSTRING (name))))
	error ("Frame names of the form F<num> are usurped by Emacs");
    }

  f->name = name;
  update_mode_lines = 1;
}

void
store_frame_param (f, prop, val)
     struct frame *f;
     Lisp_Object prop, val;
{
  register Lisp_Object tem;

  if (EQ (prop, Qbuffer_list))
    {
      f->buffer_list = val;
      return;
    }

  tem = Fassq (prop, f->param_alist);
  if (EQ (tem, Qnil))
    f->param_alist = Fcons (Fcons (prop, val), f->param_alist);
  else
    Fsetcdr (tem, val);

  if (EQ (prop, Qbuffer_predicate))
    f->buffer_predicate = val;

  if (! FRAME_WINDOW_P (f))
    {
      if (EQ (prop, Qmenu_bar_lines))
	set_menu_bar_lines (f, val, make_number (FRAME_MENU_BAR_LINES (f)));
      else if (EQ (prop, Qname))
	set_term_frame_name (f, val);
    }

  if (EQ (prop, Qminibuffer) && WINDOWP (val))
    {
      if (! MINI_WINDOW_P (XWINDOW (val)))
	error ("Surrogate minibuffer windows must be minibuffer windows.");

      if (FRAME_HAS_MINIBUF_P (f) || FRAME_MINIBUF_ONLY_P (f)
	  && !EQ (val, f->minibuffer_window))
	error ("Can't change the surrogate minibuffer of a frame with its own minibuffer");

      /* Install the chosen minibuffer window, with proper buffer.  */
      f->minibuffer_window = val;
    }
}

DEFUN ("frame-parameters", Fframe_parameters, Sframe_parameters, 0, 1, 0,
  "Return the parameters-alist of frame FRAME.\n\
It is a list of elements of the form (PARM . VALUE), where PARM is a symbol.\n\
The meaningful PARMs depend on the kind of frame.\n\
If FRAME is omitted, return information on the currently selected frame.")
  (frame)
     Lisp_Object frame;
{
  Lisp_Object alist;
  FRAME_PTR f;
  int height, width;

  if (EQ (frame, Qnil))
    f = selected_frame;
  else
    {
      CHECK_FRAME (frame, 0);
      f = XFRAME (frame);
    }

  if (!FRAME_LIVE_P (f))
    return Qnil;

  alist = Fcopy_alist (f->param_alist);
#ifdef MSDOS
  if (FRAME_MSDOS_P (f))
    {
      static char *colornames[16] = 
	{
	  "black", "blue", "green", "cyan", "red", "magenta", "brown",
	  "lightgray", "darkgray", "lightblue", "lightgreen", "lightcyan",
	  "lightred", "lightmagenta", "yellow", "white"
	};
      store_in_alist (&alist, intern ("foreground-color"),
		      build_string (colornames[FRAME_FOREGROUND_PIXEL (f)]));
      store_in_alist (&alist, intern ("background-color"),
		      build_string (colornames[FRAME_BACKGROUND_PIXEL (f)]));
    }
  store_in_alist (&alist, intern ("font"), build_string ("default"));
#endif
  store_in_alist (&alist, Qname, f->name);
  height = (FRAME_NEW_HEIGHT (f) ? FRAME_NEW_HEIGHT (f) : FRAME_HEIGHT (f));
  store_in_alist (&alist, Qheight, make_number (height));
  width = (FRAME_NEW_WIDTH (f) ? FRAME_NEW_WIDTH (f) : FRAME_WIDTH (f));
  store_in_alist (&alist, Qwidth, make_number (width));
  store_in_alist (&alist, Qmodeline, (FRAME_WANTS_MODELINE_P (f) ? Qt : Qnil));
  store_in_alist (&alist, Qminibuffer,
		  (! FRAME_HAS_MINIBUF_P (f) ? Qnil
		   : FRAME_MINIBUF_ONLY_P (f) ? Qonly
		   : FRAME_MINIBUF_WINDOW (f)));
  store_in_alist (&alist, Qunsplittable, (FRAME_NO_SPLIT_P (f) ? Qt : Qnil));
  store_in_alist (&alist, Qbuffer_list,
		  frame_buffer_list (Fselected_frame ()));

  /* I think this should be done with a hook.  */
#ifdef HAVE_WINDOW_SYSTEM
  if (FRAME_WINDOW_P (f))
    x_report_frame_params (f, &alist);
  else
#endif
    {
      /* This ought to be correct in f->param_alist for an X frame.  */
      Lisp_Object lines;
      XSETFASTINT (lines, FRAME_MENU_BAR_LINES (f));
      store_in_alist (&alist, Qmenu_bar_lines, lines);
    }
  return alist;
}

DEFUN ("modify-frame-parameters", Fmodify_frame_parameters, 
       Smodify_frame_parameters, 2, 2, 0,
  "Modify the parameters of frame FRAME according to ALIST.\n\
ALIST is an alist of parameters to change and their new values.\n\
Each element of ALIST has the form (PARM . VALUE), where PARM is a symbol.\n\
The meaningful PARMs depend on the kind of frame.\n\
Undefined PARMs are ignored, but stored in the frame's parameter list\n\
so that `frame-parameters' will return them.")
  (frame, alist)
     Lisp_Object frame, alist;
{
  FRAME_PTR f;
  register Lisp_Object tail, elt, prop, val;

  if (EQ (frame, Qnil))
    f = selected_frame;
  else
    {
      CHECK_LIVE_FRAME (frame, 0);
      f = XFRAME (frame);
    }

  /* I think this should be done with a hook.  */
#ifdef HAVE_WINDOW_SYSTEM
  if (FRAME_WINDOW_P (f))
    x_set_frame_parameters (f, alist);
  else
#endif
#ifdef MSDOS
  if (FRAME_MSDOS_P (f))
    IT_set_frame_parameters (f, alist);
  else
#endif
    {
      int length = XINT (Flength (alist));
      int i;
      Lisp_Object *parms
	= (Lisp_Object *) alloca (length * sizeof (Lisp_Object));
      Lisp_Object *values
	= (Lisp_Object *) alloca (length * sizeof (Lisp_Object));

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

      /* Now process them in reverse of specified order.  */
      for (i--; i >= 0; i--)
	{
	  prop = parms[i];
	  val = values[i];
	  store_frame_param (f, prop, val);
	}
    }

  return Qnil;
}

DEFUN ("frame-char-height", Fframe_char_height, Sframe_char_height,
  0, 1, 0,
  "Height in pixels of a line in the font in frame FRAME.\n\
If FRAME is omitted, the selected frame is used.\n\
For a terminal frame, the value is always 1.")
  (frame)
     Lisp_Object frame;
{
  struct frame *f;

  if (NILP (frame))
    f = selected_frame;
  else
    {
      CHECK_FRAME (frame, 0);
      f = XFRAME (frame);
    }

#ifdef HAVE_WINDOW_SYSTEM
  if (FRAME_WINDOW_P (f))
    return make_number (x_char_height (f));
  else
#endif
    return make_number (1);
}


DEFUN ("frame-char-width", Fframe_char_width, Sframe_char_width,
  0, 1, 0,
  "Width in pixels of characters in the font in frame FRAME.\n\
If FRAME is omitted, the selected frame is used.\n\
The width is the same for all characters, because\n\
currently Emacs supports only fixed-width fonts.\n\
For a terminal screen, the value is always 1.")
  (frame)
     Lisp_Object frame;
{
  struct frame *f;

  if (NILP (frame))
    f = selected_frame;
  else
    {
      CHECK_FRAME (frame, 0);
      f = XFRAME (frame);
    }

#ifdef HAVE_WINDOW_SYSTEM
  if (FRAME_WINDOW_P (f))
    return make_number (x_char_width (f));
  else
#endif
    return make_number (1);
}

DEFUN ("frame-pixel-height", Fframe_pixel_height, 
       Sframe_pixel_height, 0, 1, 0,
  "Return a FRAME's height in pixels.\n\
This counts only the height available for text lines,\n\
not menu bars on window-system Emacs frames.\n\
For a terminal frame, the result really gives the height in characters.\n\
If FRAME is omitted, the selected frame is used.")
  (frame)
     Lisp_Object frame;
{
  struct frame *f;

  if (NILP (frame))
    f = selected_frame;
  else
    {
      CHECK_FRAME (frame, 0);
      f = XFRAME (frame);
    }

#ifdef HAVE_WINDOW_SYSTEM
  if (FRAME_WINDOW_P (f))
    return make_number (x_pixel_height (f));
  else
#endif
    return make_number (FRAME_HEIGHT (f));
}

DEFUN ("frame-pixel-width", Fframe_pixel_width, 
       Sframe_pixel_width, 0, 1, 0,
  "Return FRAME's width in pixels.\n\
For a terminal frame, the result really gives the width in characters.\n\
If FRAME is omitted, the selected frame is used.")
  (frame)
     Lisp_Object frame;
{
  struct frame *f;

  if (NILP (frame))
    f = selected_frame;
  else
    {
      CHECK_FRAME (frame, 0);
      f = XFRAME (frame);
    }

#ifdef HAVE_WINDOW_SYSTEM
  if (FRAME_WINDOW_P (f))
    return make_number (x_pixel_width (f));
  else
#endif
    return make_number (FRAME_WIDTH (f));
}

DEFUN ("set-frame-height", Fset_frame_height, Sset_frame_height, 2, 3, 0,
  "Specify that the frame FRAME has LINES lines.\n\
Optional third arg non-nil means that redisplay should use LINES lines\n\
but that the idea of the actual height of the frame should not be changed.")
  (frame, lines, pretend)
     Lisp_Object frame, lines, pretend;
{
  register struct frame *f;

  CHECK_NUMBER (lines, 0);
  if (NILP (frame))
    f = selected_frame;
  else
    {
      CHECK_LIVE_FRAME (frame, 0);
      f = XFRAME (frame);
    }

  /* I think this should be done with a hook.  */
#ifdef HAVE_WINDOW_SYSTEM
  if (FRAME_WINDOW_P (f))
    {
      if (XINT (lines) != f->height)
	x_set_window_size (f, 1, f->width, XINT (lines));
    }
  else
#endif
    change_frame_size (f, XINT (lines), 0, !NILP (pretend), 0);
  return Qnil;
}

DEFUN ("set-frame-width", Fset_frame_width, Sset_frame_width, 2, 3, 0,
  "Specify that the frame FRAME has COLS columns.\n\
Optional third arg non-nil means that redisplay should use COLS columns\n\
but that the idea of the actual width of the frame should not be changed.")
  (frame, cols, pretend)
     Lisp_Object frame, cols, pretend;
{
  register struct frame *f;
  CHECK_NUMBER (cols, 0);
  if (NILP (frame))
    f = selected_frame;
  else
    {
      CHECK_LIVE_FRAME (frame, 0);
      f = XFRAME (frame);
    }

  /* I think this should be done with a hook.  */
#ifdef HAVE_WINDOW_SYSTEM
  if (FRAME_WINDOW_P (f))
    {
      if (XINT (cols) != f->width)
	x_set_window_size (f, 1, XINT (cols), f->height);
    }
  else
#endif
    change_frame_size (f, 0, XINT (cols), !NILP (pretend), 0);
  return Qnil;
}

DEFUN ("set-frame-size", Fset_frame_size, Sset_frame_size, 3, 3, 0,
  "Sets size of FRAME to COLS by ROWS, measured in characters.")
  (frame, cols, rows)
     Lisp_Object frame, cols, rows;
{
  register struct frame *f;
  int mask;

  CHECK_LIVE_FRAME (frame, 0);
  CHECK_NUMBER (cols, 2);
  CHECK_NUMBER (rows, 1);
  f = XFRAME (frame);

  /* I think this should be done with a hook.  */
#ifdef HAVE_WINDOW_SYSTEM
  if (FRAME_WINDOW_P (f))
    {
      if (XINT (rows) != f->height || XINT (cols) != f->width
	  || FRAME_NEW_HEIGHT (f) || FRAME_NEW_WIDTH (f))
	x_set_window_size (f, 1, XINT (cols), XINT (rows));
    }
  else
#endif
    change_frame_size (f, XINT (rows), XINT (cols), 0, 0);

  return Qnil;
}

DEFUN ("set-frame-position", Fset_frame_position, 
       Sset_frame_position, 3, 3, 0,
  "Sets position of FRAME in pixels to XOFFSET by YOFFSET.\n\
This is actually the position of the upper left corner of the frame.\n\
Negative values for XOFFSET or YOFFSET are interpreted relative to\n\
the rightmost or bottommost possible position (that stays within the screen).")
  (frame, xoffset, yoffset)
     Lisp_Object frame, xoffset, yoffset;
{
  register struct frame *f;
  int mask;

  CHECK_LIVE_FRAME (frame, 0);
  CHECK_NUMBER (xoffset, 1);
  CHECK_NUMBER (yoffset, 2);
  f = XFRAME (frame);

  /* I think this should be done with a hook.  */
#ifdef HAVE_WINDOW_SYSTEM
  if (FRAME_WINDOW_P (f))
    x_set_offset (f, XINT (xoffset), XINT (yoffset), 1);
#endif

  return Qt;
}


void
syms_of_frame ()
{
  syms_of_frame_1 ();

  staticpro (&Vframe_list);

  DEFVAR_LISP ("terminal-frame", &Vterminal_frame,
    "The initial frame-object, which represents Emacs's stdout.");

  DEFVAR_LISP ("emacs-iconified", &Vemacs_iconified,
    "Non-nil if all of emacs is iconified and frame updates are not needed.");
  Vemacs_iconified = Qnil;

  DEFVAR_KBOARD ("default-minibuffer-frame", Vdefault_minibuffer_frame,
    "Minibufferless frames use this frame's minibuffer.\n\
\n\
Emacs cannot create minibufferless frames unless this is set to an\n\
appropriate surrogate.\n\
\n\
Emacs consults this variable only when creating minibufferless\n\
frames; once the frame is created, it sticks with its assigned\n\
minibuffer, no matter what this variable is set to.  This means that\n\
this variable doesn't necessarily say anything meaningful about the\n\
current set of frames, or where the minibuffer is currently being\n\
displayed.");

  defsubr (&Sactive_minibuffer_window);
  defsubr (&Sframep);
  defsubr (&Sframe_live_p);
  defsubr (&Smake_terminal_frame);
  defsubr (&Shandle_switch_frame);
  defsubr (&Signore_event);
  defsubr (&Sselect_frame);
  defsubr (&Sselected_frame);
  defsubr (&Swindow_frame);
  defsubr (&Sframe_root_window);
  defsubr (&Sframe_first_window);
  defsubr (&Sframe_selected_window);
  defsubr (&Sset_frame_selected_window);
  defsubr (&Sframe_list);
  defsubr (&Snext_frame);
  defsubr (&Sprevious_frame);
  defsubr (&Sdelete_frame);
  defsubr (&Smouse_position);
  defsubr (&Smouse_pixel_position);
  defsubr (&Sset_mouse_position);
  defsubr (&Sset_mouse_pixel_position);
#if 0
  defsubr (&Sframe_configuration);
  defsubr (&Srestore_frame_configuration);
#endif
  defsubr (&Smake_frame_visible);
  defsubr (&Smake_frame_invisible);
  defsubr (&Siconify_frame);
  defsubr (&Sframe_visible_p);
  defsubr (&Svisible_frame_list);
  defsubr (&Sraise_frame);
  defsubr (&Slower_frame);
  defsubr (&Sredirect_frame_focus);
  defsubr (&Sframe_focus);
  defsubr (&Sframe_parameters);
  defsubr (&Smodify_frame_parameters);
  defsubr (&Sframe_char_height);
  defsubr (&Sframe_char_width);
  defsubr (&Sframe_pixel_height);
  defsubr (&Sframe_pixel_width);
  defsubr (&Sset_frame_height);
  defsubr (&Sset_frame_width);
  defsubr (&Sset_frame_size);
  defsubr (&Sset_frame_position);
}

void
keys_of_frame ()
{
  initial_define_lispy_key (global_map, "switch-frame", "handle-switch-frame");
  initial_define_lispy_key (global_map, "delete-frame", "handle-delete-frame");
  initial_define_lispy_key (global_map, "iconify-frame", "ignore-event");
  initial_define_lispy_key (global_map, "make-frame-visible", "ignore-event");
}
