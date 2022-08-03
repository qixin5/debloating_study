/* Definitions for interface to indent.c
   Copyright (C) 1985, 1986 Free Software Foundation, Inc.

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

/* We introduce new member `tab_offset'.  We need it because of the
   existence of wide-column characters.  There is a case that the
   line-break occurs at a wide-column character and the number of
   colums of the line gets less than width.

   Example (where W_ stands for a wide-column character):
	     ----------
	     abcdefgh\\
	     W_      
	     ----------

   To handle this case, we should not calculate the tab offset by 
  	tab_offset += width;

   Instead, we must remember tab_offset of the line. 

 */

struct position
  {
    int bufpos;
    int bytepos;
    int hpos;
    int vpos;
    int prevhpos;
    int contin;
    /* Number of characters we have already handled
       from the before and after strings at this position.  */
    int ovstring_chars_done;
    int tab_offset;
  };

struct position *compute_motion ();
struct position *vmotion ();

/* Value of point when current_column was called */
extern int last_known_column_point;

/* Functions for dealing with the column cache.  */

/* Return true iff the display table DISPTAB specifies the same widths
   for characters as WIDTHTAB.  We use this to decide when to
   invalidate the buffer's column_cache.  */
extern int disptab_matches_widthtab ( /* struct Lisp_Vector *disptab,
                                         struct Lisp_Vector *widthtab */ );

/* Recompute BUF's width table, using the display table DISPTAB.  */
extern void recompute_width_table ( /* struct buffer *buf,
                                       struct Lisp_Vector *disptab */ );
