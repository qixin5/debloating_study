/* Window definitions for GNU Emacs.
   Copyright (C) 1985, 1986, 1993, 1995 Free Software Foundation, Inc.

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


/* Windows are allocated as if they were vectors, but then the
Lisp data type is changed to Lisp_Window.  They are garbage
collected along with the vectors.

All windows in use are arranged into a tree, with pointers up and down.

Windows that are leaves of the tree are actually displayed
and show the contents of buffers.  Windows that are not leaves
are used for representing the way groups of leaf windows are
arranged on the frame.  Leaf windows never become non-leaves.
They are deleted only by calling delete-window on them (but
this can be done implicitly).  Combination windows can be created
and deleted at any time.

A leaf window has a non-nil buffer field, and also
 has markers in its start and pointm fields.  Non-leaf windows
 have nil in these fields.

Non-leaf windows are either vertical or horizontal combinations.

A vertical combination window has children that are arranged on the frame
one above the next.  Its vchild field points to the uppermost child.
The parent field of each of the children points to the vertical
combination window.  The next field of each child points to the
child below it, or is nil for the lowest child.  The prev field
of each child points to the child above it, or is nil for the
highest child.

A horizontal combination window has children that are side by side.
Its hchild field points to the leftmost child.  In each child
the next field points to the child to the right and the prev field
points to the child to the left.

The children of a vertical combination window may be leaf windows
or horizontal combination windows.  The children of a horizontal
combination window may be leaf windows or vertical combination windows.

At the top of the tree are two windows which have nil as parent.
The second of these is minibuf_window.  The first one manages all
the frame area that is not minibuffer, and is called the root window.
Different windows can be the root at different times;
initially the root window is a leaf window, but if more windows
are created then that leaf window ceases to be root and a newly
made combination window becomes root instead.

In any case, on screens which have an ordinary window and a
minibuffer, prev of the minibuf window is the root window and next of
the root window is the minibuf window.  On minibufferless screens or
minibuffer-only screens, the root window and the minibuffer window are
one and the same, so its prev and next members are nil.

A dead window has its buffer, hchild, and vchild windows all nil.  */

struct window
  {
    /* The first two fields are really the header of a vector */
    /* The window code does not refer to them.  */
    EMACS_INT size;
    struct Lisp_Vector *vec_next;
    /* The frame this window is on.  */
    Lisp_Object frame;
    /* t if this window is a minibuffer window.  */
    Lisp_Object mini_p;
    /* Following child (to right or down) at same level of tree */
    Lisp_Object next;
    /* Preceding child (to left or up) at same level of tree */
    Lisp_Object prev;
    /* First child of this window. */
    /* vchild is used if this is a vertical combination,
       hchild if this is a horizontal combination. */
    Lisp_Object hchild, vchild;
    /* The window this one is a child of. */
    Lisp_Object parent;
    /* The upper left corner coordinates of this window,
       as integers relative to upper left corner of frame = 0, 0 */
    Lisp_Object left;
    Lisp_Object top;
    /* The size of the window */
    Lisp_Object height;
    Lisp_Object width;
    /* The buffer displayed in this window */
    /* Of the fields vchild, hchild and buffer, only one is non-nil.  */
    Lisp_Object buffer;
    /* A marker pointing to where in the text to start displaying */
    Lisp_Object start;
    /* A marker pointing to where in the text point is in this window,
       used only when the window is not selected.
       This exists so that when multiple windows show one buffer
       each one can have its own value of point.  */
    Lisp_Object pointm;
    /* Non-nil means next redisplay must use the value of start
       set up for it in advance.  Set by scrolling commands.  */
    Lisp_Object force_start;
    /* Non-nil means we have explicitly changed the value of start,
       but that the next redisplay is not obliged to use the new value.  */
    Lisp_Object optional_new_start;
    /* Number of columns display within the window is scrolled to the left.  */
    Lisp_Object hscroll;
    /* Number saying how recently window was selected */
    Lisp_Object use_time;
    /* Unique number of window assigned when it was created */
    Lisp_Object sequence_number;
    /* No permanent meaning; used by save-window-excursion's bookkeeping */
    Lisp_Object temslot;
    /* text.modified of displayed buffer as of last time display completed */
    Lisp_Object last_modified;
    /* BUF_OVERLAY_MODIFIED of displayed buffer as of last complete update.  */
    Lisp_Object last_overlay_modified;
    /* Value of point at that time */
    Lisp_Object last_point;
    /* Non-nil if the buffer was "modified" when the window
       was last updated.  */
    Lisp_Object last_had_star;
    /* This window's vertical scroll bar.  This field is only for use
       by the window-system-dependent code which implements the
       scroll bars; it can store anything it likes here.  If this
       window is newly created and we haven't displayed a scroll bar in
       it yet, or if the frame doesn't have any scroll bars, this is nil.  */
    Lisp_Object vertical_scroll_bar;

    /* Some of these are currently not used or only half used */
    /* Frame coords of point at that time */
    Lisp_Object last_point_x;
    Lisp_Object last_point_y;
    /* Frame coords of mark as of last time display completed */
    /* May be nil if mark does not exist or was not on frame */
    Lisp_Object last_mark_x;
    Lisp_Object last_mark_y;

    /* Number of characters in buffer past bottom of window,
       as of last redisplay that finished. */
    Lisp_Object window_end_pos;
    /* t if window_end_pos is truly valid.
       This is nil if nontrivial redisplay is preempted
       since in that case the frame image that window_end_pos
       did not get onto the frame.  */
    Lisp_Object window_end_valid;
    /* Vertical position (relative to window top) of that buffer position
       of the first of those characters */
    Lisp_Object window_end_vpos;
    /* Non-nil means must regenerate mode line of this window */
    Lisp_Object update_mode_line;
    /* Non-nil means current value of `start'
       was the beginning of a line when it was chosen.  */
    Lisp_Object start_at_line_beg;
    /* Display-table to use for displaying chars in this window.
       Nil means use the buffer's own display-table.  */
    Lisp_Object display_table;
    /* Non-nil means window is marked as dedicated.  */
    Lisp_Object dedicated;
    /* Line number and position of a line somewhere above the
       top of the screen.  */
    /* If this field is nil, it means we don't have a base line.  */
    Lisp_Object base_line_number;
    /* If this field is nil, it means we don't have a base line.
       If it is a buffer, it means don't display the line number
       as long as the window shows that buffer.  */
    Lisp_Object base_line_pos;
    /* If we have highlighted the region (or any part of it),
       this is the mark position that we used, as an integer.  */
    Lisp_Object region_showing;
    /* The column number currently displayed in this window's mode line,
       or nil if column numbers are not being displayed.  */
    Lisp_Object column_number_displayed;
    /* If redisplay in this window goes beyond this buffer position,
       must run the redisplay-end-trigger-hook.  */
    Lisp_Object redisplay_end_trigger;
    /* Non-nil means don't delete this window for becoming "too small".  */
    Lisp_Object too_small_ok;
  };

/* 1 if W is a minibuffer window.  */

#define MINI_WINDOW_P(W)  (!EQ ((W)->mini_p, Qnil))

/* Return the frame column at which the text in window W starts.
   This is different from the `left' field because it does not include
   a left-hand scroll bar if any.  */
   
#define WINDOW_LEFT_MARGIN(W) \
     (XFASTINT ((W)->left) \
      + FRAME_LEFT_SCROLL_BAR_WIDTH (XFRAME (WINDOW_FRAME (W))))

/* Return the frame column before window W ends.
   This includes a right-hand scroll bar, if any.  */

#define WINDOW_RIGHT_EDGE(W) \
     (XFASTINT ((W)->left) + XFASTINT ((W)->width))

/* Return the frame column before which the text in window W ends.
   This is different from WINDOW_RIGHT_EDGE because it does not include
   a scroll bar or window-separating line on the right edge.  */

#define WINDOW_RIGHT_MARGIN(W)						    \
  (WINDOW_RIGHT_EDGE (W)						    \
   - (! FRAME_HAS_VERTICAL_SCROLL_BARS (XFRAME (WINDOW_FRAME (W)))	    \
      ? ((WINDOW_RIGHTMOST_P (W)) ? 0 : 1)			    	    \
      : FRAME_HAS_VERTICAL_SCROLL_BARS_ON_RIGHT (XFRAME (WINDOW_FRAME (W))) \
      ? FRAME_SCROLL_BAR_COLS (XFRAME (WINDOW_FRAME (W)))		    \
      : 0))

/* 1 if window W takes up the full width of its frame.  */ 

#define WINDOW_FULL_WIDTH_P(W) \
     (XFASTINT ((W)->width) == FRAME_WINDOW_WIDTH (XFRAME (WINDOW_FRAME (W))))

/* 1 if window W's has no other windows to its right in its frame.  */ 

#define WINDOW_RIGHTMOST_P(W) \
     (WINDOW_RIGHT_EDGE (W) == FRAME_WINDOW_WIDTH (XFRAME (WINDOW_FRAME (W))))
     
/* This is the window in which the terminal's cursor should
   be left when nothing is being done with it.  This must
   always be a leaf window, and its buffer is selected by
   the top level editing loop at the end of each command.

   This value is always the same as
    FRAME_SELECTED_WINDOW (selected_frame).  */

extern Lisp_Object selected_window;

/* This is a time stamp for window selection, so we can find the least
   recently used window.  Its only users are Fselect_window,
   init_window_once, and make_frame.  */

extern int window_select_count;

/* The minibuffer window of the selected frame.
   Note that you cannot test for minibufferness of an arbitrary window
   by comparing against this; use the MINI_WINDOW_P macro instead.  */

extern Lisp_Object minibuf_window;

/* Non-nil => window to for C-M-v to scroll
   when the minibuffer is selected.  */
extern Lisp_Object Vminibuf_scroll_window;

/* nil or a symbol naming the window system
   under which emacs is running
   ('x is the only current possibility) */
extern Lisp_Object Vwindow_system;

/* Version number of X windows: 10, 11 or nil.  */
extern Lisp_Object Vwindow_system_version;

/* Window that the mouse is over (nil if no mouse support).  */
extern Lisp_Object Vmouse_window;

/* Last mouse-click event (nil if no mouse support).  */
extern Lisp_Object Vmouse_event;

EXFUN (Fnext_window, 3);
EXFUN (Fselect_window, 1);
EXFUN (Fdisplay_buffer, 3);
EXFUN (Fset_window_buffer, 2);
extern Lisp_Object make_window P_ ((void));
extern void delete_window P_ ((Lisp_Object));
extern Lisp_Object window_from_coordinates P_ ((struct frame *, int, int, int *));
EXFUN (Fwindow_dedicated_p, 1);
extern int window_height P_ ((Lisp_Object));
extern int window_width P_ ((Lisp_Object));
extern void set_window_height P_ ((Lisp_Object, int, int));
extern void set_window_width P_ ((Lisp_Object, int, int));
extern void change_window_height P_ ((int, int));
extern void delete_all_subwindows P_ ((struct window *));

/* Prompt to display in front of the minibuffer contents.  */
extern Lisp_Object minibuf_prompt;

/* The visual width of the above.  */
extern int minibuf_prompt_width;

/* Message to display instead of minibuffer contents. 
   This is what the functions error and message make,
   and command echoing uses it as well. It overrides the
   minibuf_prompt as well as the buffer.  */
extern char *echo_area_glyphs;

/* This is the length of the message in echo_area_glyphs.  */
extern int echo_area_glyphs_length;

/* Value of echo_area_glyphs when it was last acted on.
  If this is nonzero, there is a message on the frame
  in the minibuffer and it should be erased as soon
  as it is no longer requested to appear. */
extern char *previous_echo_glyphs;

/* This is the window where the echo area message was displayed.
   It is always a minibuffer window, but it may not be the
   same window currently active as a minibuffer.  */
extern Lisp_Object echo_area_window;

/* Depth in recursive edits.  */
extern int command_loop_level;

/* Depth in minibuffer invocations.  */
extern int minibuf_level;

/* true iff we should redraw the mode lines on the next redisplay.  */
extern int update_mode_lines;

/* Minimum value of GPT - BEG since last redisplay that finished.  */

extern int beg_unchanged;

/* Minimum value of Z - GPT since last redisplay that finished.  */

extern int end_unchanged;

/* MODIFF as of last redisplay that finished;
   if it matches MODIFF, beg_unchanged and end_unchanged
   contain no useful information.  */
extern int unchanged_modified;

/* BUF_OVERLAY_MODIFF of current buffer, as of last redisplay that finished;
   if it matches BUF_OVERLAY_MODIFF, beg_unchanged and end_unchanged
   contain no useful information.  */
extern int overlay_unchanged_modified;

/* Nonzero if BEGV - BEG or Z - ZV of current buffer has changed
   since last redisplay that finished.  */
extern int clip_changed;

/* Nonzero if window sizes or contents have changed
 since last redisplay that finished */
extern int windows_or_buffers_changed;

/* Number of windows displaying the selected buffer.
   Normally this is 1, but it can be more.  */
extern int buffer_shared;

/* If *ROWS or *COLS are too small a size for FRAME, set them to the
   minimum allowable size.  */
extern void check_frame_size P_ ((struct frame *frame, int *rows, int *cols));
