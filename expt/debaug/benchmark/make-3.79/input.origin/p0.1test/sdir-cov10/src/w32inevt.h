/* Input routines for GNU Emacs on the Microsoft W32 API.
   Copyright (C) 1995 Free Software Foundation, Inc.

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

#ifndef __NTINEVT_H__
#define __NTINEVT_H__

extern int w32_console_read_socket (int sd, struct input_event *bufp, 
				    int numchars, int expected);
extern void w32_console_mouse_position (FRAME_PTR *f, int insist, 
					Lisp_Object *bar_window, 
					enum scroll_bar_part *part, 
					Lisp_Object *x, Lisp_Object *y, 
					unsigned long *time);

#endif
