/* Menu support for GNU Emacs on the Microsoft W32 API.
   Copyright (C) 1986, 1988, 1993, 1994, 1996, 1998 Free Software Foundation, Inc.

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

#include <signal.h>
#include <config.h>

#include <stdio.h>
#include "lisp.h"
#include "termhooks.h"
#include "frame.h"
#include "window.h"
#include "keyboard.h"
#include "blockinput.h"
#include "buffer.h"
#include "charset.h"
#include "coding.h"

/* This may include sys/types.h, and that somehow loses
   if this is not done before the other system files.  */
#include "w32term.h"

/* Load sys/types.h if not already loaded.
   In some systems loading it twice is suicidal.  */
#ifndef makedev
#include <sys/types.h>
#endif

#include "dispextern.h"

#undef HAVE_MULTILINGUAL_MENU

/******************************************************************/
/* Definitions copied from lwlib.h */

typedef void * XtPointer;
typedef char Boolean;

#define True 1
#define False 0

typedef enum _change_type
{
  NO_CHANGE = 0,
  INVISIBLE_CHANGE = 1,
  VISIBLE_CHANGE = 2,
  STRUCTURAL_CHANGE = 3
} change_type;

typedef struct _widget_value
{
  /* name of widget */
  char*		name;
  /* value (meaning depend on widget type) */
  char*		value;
  /* keyboard equivalent. no implications for XtTranslations */ 
  char*		key;
  /* true if enabled */
  Boolean	enabled;
  /* true if selected */
  Boolean	selected;
  /* true if menu title */
  Boolean       title;
#if 0
  /* true if was edited (maintained by get_value) */
  Boolean	edited;
  /* true if has changed (maintained by lw library) */
  change_type	change;
  /* true if this widget itself has changed,
     but not counting the other widgets found in the `next' field.  */
  change_type   this_one_change;
#endif
  /* Contents of the sub-widgets, also selected slot for checkbox */
  struct _widget_value*	contents;
  /* data passed to callback */
  XtPointer	call_data;
  /* next one in the list */
  struct _widget_value*	next;
#if 0
  /* slot for the toolkit dependent part.  Always initialize to NULL. */
  void* toolkit_data;
  /* tell us if we should free the toolkit data slot when freeing the
     widget_value itself. */
  Boolean free_toolkit_data;

  /* we resource the widget_value structures; this points to the next
     one on the free list if this one has been deallocated.
   */
  struct _widget_value *free_list;
#endif
} widget_value;

/* LocalAlloc/Free is a reasonably good allocator.  */
#define malloc_widget_value() (void*)LocalAlloc (LMEM_ZEROINIT, sizeof (widget_value))
#define free_widget_value(wv) LocalFree (wv)

/******************************************************************/

#define min(x,y) (((x) < (y)) ? (x) : (y))
#define max(x,y) (((x) > (y)) ? (x) : (y))

#ifndef TRUE
#define TRUE 1
#define FALSE 0
#endif /* no TRUE */

Lisp_Object Vmenu_updating_frame;

Lisp_Object Qdebug_on_next_call;

extern Lisp_Object Qmenu_bar;
extern Lisp_Object Qmouse_click, Qevent_kind;

extern Lisp_Object QCtoggle, QCradio;

extern Lisp_Object Voverriding_local_map;
extern Lisp_Object Voverriding_local_map_menu_flag;

extern Lisp_Object Qoverriding_local_map, Qoverriding_terminal_local_map;

extern Lisp_Object Qmenu_bar_update_hook;

void set_frame_menubar ();

static Lisp_Object w32_menu_show ();
static Lisp_Object w32_dialog_show ();

static void keymap_panes ();
static void single_keymap_panes ();
static void single_menu_item ();
static void list_of_panes ();
static void list_of_items ();

/* This holds a Lisp vector that holds the results of decoding
   the keymaps or alist-of-alists that specify a menu.

   It describes the panes and items within the panes.

   Each pane is described by 3 elements in the vector:
   t, the pane name, the pane's prefix key.
   Then follow the pane's items, with 5 elements per item:
   the item string, the enable flag, the item's value,
   the definition, and the equivalent keyboard key's description string.

   In some cases, multiple levels of menus may be described.
   A single vector slot containing nil indicates the start of a submenu.
   A single vector slot containing lambda indicates the end of a submenu.
   The submenu follows a menu item which is the way to reach the submenu.

   A single vector slot containing quote indicates that the
   following items should appear on the right of a dialog box.

   Using a Lisp vector to hold this information while we decode it
   takes care of protecting all the data from GC.  */

#define MENU_ITEMS_PANE_NAME 1
#define MENU_ITEMS_PANE_PREFIX 2
#define MENU_ITEMS_PANE_LENGTH 3

#define MENU_ITEMS_ITEM_NAME 0
#define MENU_ITEMS_ITEM_ENABLE 1
#define MENU_ITEMS_ITEM_VALUE 2
#define MENU_ITEMS_ITEM_EQUIV_KEY 3
#define MENU_ITEMS_ITEM_DEFINITION 4
#define MENU_ITEMS_ITEM_LENGTH 5

static Lisp_Object menu_items;

/* Number of slots currently allocated in menu_items.  */
static int menu_items_allocated;

/* This is the index in menu_items of the first empty slot.  */
static int menu_items_used;

/* The number of panes currently recorded in menu_items,
   excluding those within submenus.  */
static int menu_items_n_panes;

/* Current depth within submenus.  */
static int menu_items_submenu_depth;

/* Flag which when set indicates a dialog or menu has been posted by
   Xt on behalf of one of the widget sets.  */
static int popup_activated_flag;

/* This is set nonzero after the user activates the menu bar, and set
   to zero again after the menu bars are redisplayed by prepare_menu_bar.
   While it is nonzero, all calls to set_frame_menubar go deep.

   I don't understand why this is needed, but it does seem to be
   needed on Motif, according to Marcus Daniels <marcus@sysc.pdx.edu>.  */

int pending_menu_activation;


/* Return the frame whose ->output_data.w32->menubar_widget equals
   MENU, or 0 if none.  */

static struct frame *
menubar_id_to_frame (HMENU menu)
{
  Lisp_Object tail, frame;
  FRAME_PTR f;

  for (tail = Vframe_list; GC_CONSP (tail); tail = XCONS (tail)->cdr)
    {
      frame = XCONS (tail)->car;
      if (!GC_FRAMEP (frame))
        continue;
      f = XFRAME (frame);
      if (f->output_data.nothing == 1)
	continue;
      if (f->output_data.w32->menubar_widget == menu)
	return f;
    }
  return 0;
}

/* Initialize the menu_items structure if we haven't already done so.
   Also mark it as currently empty.  */

static void
init_menu_items ()
{
  if (NILP (menu_items))
    {
      menu_items_allocated = 60;
      menu_items = Fmake_vector (make_number (menu_items_allocated), Qnil);
    }

  menu_items_used = 0;
  menu_items_n_panes = 0;
  menu_items_submenu_depth = 0;
}

/* Call at the end of generating the data in menu_items.
   This fills in the number of items in the last pane.  */

static void
finish_menu_items ()
{
}

/* Call when finished using the data for the current menu
   in menu_items.  */

static void
discard_menu_items ()
{
  /* Free the structure if it is especially large.
     Otherwise, hold on to it, to save time.  */
  if (menu_items_allocated > 200)
    {
      menu_items = Qnil;
      menu_items_allocated = 0;
    }
}

/* Make the menu_items vector twice as large.  */

static void
grow_menu_items ()
{
  Lisp_Object old;
  int old_size = menu_items_allocated;
  old = menu_items;

  menu_items_allocated *= 2;
  menu_items = Fmake_vector (make_number (menu_items_allocated), Qnil);
  bcopy (XVECTOR (old)->contents, XVECTOR (menu_items)->contents,
	 old_size * sizeof (Lisp_Object));
}

/* Begin a submenu.  */

static void
push_submenu_start ()
{
  if (menu_items_used + 1 > menu_items_allocated)
    grow_menu_items ();

  XVECTOR (menu_items)->contents[menu_items_used++] = Qnil;
  menu_items_submenu_depth++;
}

/* End a submenu.  */

static void
push_submenu_end ()
{
  if (menu_items_used + 1 > menu_items_allocated)
    grow_menu_items ();

  XVECTOR (menu_items)->contents[menu_items_used++] = Qlambda;
  menu_items_submenu_depth--;
}

/* Indicate boundary between left and right.  */

static void
push_left_right_boundary ()
{
  if (menu_items_used + 1 > menu_items_allocated)
    grow_menu_items ();

  XVECTOR (menu_items)->contents[menu_items_used++] = Qquote;
}

/* Start a new menu pane in menu_items..
   NAME is the pane name.  PREFIX_VEC is a prefix key for this pane.  */

static void
push_menu_pane (name, prefix_vec)
     Lisp_Object name, prefix_vec;
{
  if (menu_items_used + MENU_ITEMS_PANE_LENGTH > menu_items_allocated)
    grow_menu_items ();

  if (menu_items_submenu_depth == 0)
    menu_items_n_panes++;
  XVECTOR (menu_items)->contents[menu_items_used++] = Qt;
  XVECTOR (menu_items)->contents[menu_items_used++] = name;
  XVECTOR (menu_items)->contents[menu_items_used++] = prefix_vec;
}

/* Push one menu item into the current pane.
   NAME is the string to display.  ENABLE if non-nil means
   this item can be selected.  KEY is the key generated by
   choosing this item, or nil if this item doesn't really have a definition.
   DEF is the definition of this item.
   EQUIV is the textual description of the keyboard equivalent for
   this item (or nil if none).  */

static void
push_menu_item (name, enable, key, def, equiv)
     Lisp_Object name, enable, key, def, equiv;
{
  if (menu_items_used + MENU_ITEMS_ITEM_LENGTH > menu_items_allocated)
    grow_menu_items ();

  XVECTOR (menu_items)->contents[menu_items_used++] = name;
  XVECTOR (menu_items)->contents[menu_items_used++] = enable;
  XVECTOR (menu_items)->contents[menu_items_used++] = key;
  XVECTOR (menu_items)->contents[menu_items_used++] = equiv;
  XVECTOR (menu_items)->contents[menu_items_used++] = def;
}

/* Look through KEYMAPS, a vector of keymaps that is NMAPS long,
   and generate menu panes for them in menu_items.
   If NOTREAL is nonzero,
   don't bother really computing whether an item is enabled.  */

static void
keymap_panes (keymaps, nmaps, notreal)
     Lisp_Object *keymaps;
     int nmaps;
     int notreal;
{
  int mapno;

  init_menu_items ();

  /* Loop over the given keymaps, making a pane for each map.
     But don't make a pane that is empty--ignore that map instead.
     P is the number of panes we have made so far.  */
  for (mapno = 0; mapno < nmaps; mapno++)
    single_keymap_panes (keymaps[mapno], Qnil, Qnil, notreal, 10);

  finish_menu_items ();
}

/* This is a recursive subroutine of keymap_panes.
   It handles one keymap, KEYMAP.
   The other arguments are passed along
   or point to local variables of the previous function.
   If NOTREAL is nonzero, only check for equivalent key bindings, don't
   evaluate expressions in menu items and don't make any menu.

   If we encounter submenus deeper than MAXDEPTH levels, ignore them.  */

static void
single_keymap_panes (keymap, pane_name, prefix, notreal, maxdepth)
     Lisp_Object keymap;
     Lisp_Object pane_name;
     Lisp_Object prefix;
     int notreal;
     int maxdepth;
{
  Lisp_Object pending_maps = Qnil;
  Lisp_Object tail, item;
  struct gcpro gcpro1, gcpro2;
  int notbuttons = 0;

  if (maxdepth <= 0)
    return;

  push_menu_pane (pane_name, prefix);

#ifndef HAVE_BOXES
  /* Remember index for first item in this pane so we can go back and
     add a prefix when (if) we see the first button.  After that, notbuttons
     is set to 0, to mark that we have seen a button and all non button
     items need a prefix.  */
  notbuttons = menu_items_used;
#endif

  for (tail = keymap; CONSP (tail); tail = XCONS (tail)->cdr)
    {
      GCPRO2 (keymap, pending_maps);
      /* Look at each key binding, and if it is a menu item add it
	 to this menu.  */
      item = XCONS (tail)->car;
      if (CONSP (item))
	single_menu_item (XCONS (item)->car, XCONS (item)->cdr,
			  &pending_maps, notreal, maxdepth, &notbuttons);
      else if (VECTORP (item))
	{
	  /* Loop over the char values represented in the vector.  */
	  int len = XVECTOR (item)->size;
	  int c;
	  for (c = 0; c < len; c++)
	    {
	      Lisp_Object character;
	      XSETFASTINT (character, c);
	      single_menu_item (character, XVECTOR (item)->contents[c],
				&pending_maps, notreal, maxdepth, &notbuttons);
	    }
	}
      UNGCPRO;
    }

  /* Process now any submenus which want to be panes at this level.  */
  while (!NILP (pending_maps))
    {
      Lisp_Object elt, eltcdr, string;
      elt = Fcar (pending_maps);
      eltcdr = XCONS (elt)->cdr;
      string = XCONS (eltcdr)->car;
      /* We no longer discard the @ from the beginning of the string here.
	 Instead, we do this in w32_menu_show.  */
      single_keymap_panes (Fcar (elt), string,
			   XCONS (eltcdr)->cdr, notreal, maxdepth - 1);
      pending_maps = Fcdr (pending_maps);
    }
}

/* This is a subroutine of single_keymap_panes that handles one
   keymap entry.
   KEY is a key in a keymap and ITEM is its binding. 
   PENDING_MAPS_PTR points to a list of keymaps waiting to be made into
   separate panes.
   If NOTREAL is nonzero, only check for equivalent key bindings, don't
   evaluate expressions in menu items and don't make any menu.
   If we encounter submenus deeper than MAXDEPTH levels, ignore them.
   NOTBUTTONS_PTR is only used when simulating toggle boxes and radio
   buttons.  It points to variable notbuttons in single_keymap_panes,
   which keeps track of if we have seen a button in this menu or not.  */

static void
single_menu_item (key, item, pending_maps_ptr, notreal, maxdepth,
		  notbuttons_ptr)
     Lisp_Object key, item;
     Lisp_Object *pending_maps_ptr;
     int maxdepth, notreal;
     int *notbuttons_ptr;
{
  Lisp_Object def, map, item_string, enabled;
  struct gcpro gcpro1, gcpro2;
  int res;
  
  /* Parse the menu item and leave the result in item_properties.  */
  GCPRO2 (key, item);
  res = parse_menu_item (item, notreal, 0);
  UNGCPRO;
  if (!res)
    return;			/* Not a menu item.  */

  map = XVECTOR (item_properties)->contents[ITEM_PROPERTY_MAP];
  
  if (notreal)
    {
      /* We don't want to make a menu, just traverse the keymaps to
	 precompute equivalent key bindings.  */
      if (!NILP (map))
	single_keymap_panes (map, Qnil, key, 1, maxdepth - 1);
      return;
    }

  enabled = XVECTOR (item_properties)->contents[ITEM_PROPERTY_ENABLE];
  item_string = XVECTOR (item_properties)->contents[ITEM_PROPERTY_NAME]; 

  if (!NILP (map) && XSTRING (item_string)->data[0] == '@')
    {
      if (!NILP (enabled))
	/* An enabled separate pane. Remember this to handle it later.  */
	*pending_maps_ptr = Fcons (Fcons (map, Fcons (item_string, key)),
				   *pending_maps_ptr);
      return;
    }

#ifndef HAVE_BOXES
  /* Simulate radio buttons and toggle boxes by putting a prefix in
     front of them.  */
  {
    Lisp_Object prefix = Qnil;
    Lisp_Object type = XVECTOR (item_properties)->contents[ITEM_PROPERTY_TYPE];
    if (!NILP (type))
      {
	Lisp_Object selected
	  = XVECTOR (item_properties)->contents[ITEM_PROPERTY_SELECTED];

	if (*notbuttons_ptr)
	  /* The first button. Line up previous items in this menu.  */
	  {
	    int index = *notbuttons_ptr; /* Index for first item this menu.  */
	    int submenu = 0;
	    Lisp_Object tem;
	    while (index < menu_items_used)
	      {
		tem
		  = XVECTOR (menu_items)->contents[index + MENU_ITEMS_ITEM_NAME];
		if (NILP (tem))
		  {
		    index++;
		    submenu++;		/* Skip sub menu.  */
		  }
		else if (EQ (tem, Qlambda))
		  {
		    index++;
		    submenu--;		/* End sub menu.  */
		  }
		else if (EQ (tem, Qt))
		  index += 3;		/* Skip new pane marker. */
		else if (EQ (tem, Qquote))
		  index++;		/* Skip a left, right divider. */
		else
		  {
		    if (!submenu && XSTRING (tem)->data[0] != '\0'
			&& XSTRING (tem)->data[0] != '-')
		      XVECTOR (menu_items)->contents[index + MENU_ITEMS_ITEM_NAME]
			= concat2 (build_string ("    "), tem);
		    index += MENU_ITEMS_ITEM_LENGTH;
		  }
	      }
	    *notbuttons_ptr = 0;
	  }

	/* Calculate prefix, if any, for this item.  */
	if (EQ (type, QCtoggle))
	  prefix = build_string (NILP (selected) ? "[ ] " : "[X] ");
	else if (EQ (type, QCradio))
	  prefix = build_string (NILP (selected) ? "( ) " : "(*) ");
      }
    /* Not a button. If we have earlier buttons, then we need a prefix.  */
    else if (!*notbuttons_ptr && XSTRING (item_string)->data[0] != '\0'
	     && XSTRING (item_string)->data[0] != '-')
      prefix = build_string ("    ");

    if (!NILP (prefix))
      item_string = concat2 (prefix, item_string);
  }
#endif /* not HAVE_BOXES */
 
#if 0
  if (!NILP(map))
    /* Indicate visually that this is a submenu.  */
    item_string = concat2 (item_string, build_string (" >"));
#endif

  push_menu_item (item_string, enabled, key,
		  XVECTOR (item_properties)->contents[ITEM_PROPERTY_DEF],
		  XVECTOR (item_properties)->contents[ITEM_PROPERTY_KEYEQ]);

#if 1
  /* Display a submenu using the toolkit.  */
  if (! (NILP (map) || NILP (enabled)))
    {
      push_submenu_start ();
      single_keymap_panes (map, Qnil, key, 0, maxdepth - 1);
      push_submenu_end ();
    }
#endif
}

/* Push all the panes and items of a menu described by the
   alist-of-alists MENU.
   This handles old-fashioned calls to x-popup-menu.  */

static void
list_of_panes (menu)
     Lisp_Object menu;
{
  Lisp_Object tail;

  init_menu_items ();

  for (tail = menu; !NILP (tail); tail = Fcdr (tail))
    {
      Lisp_Object elt, pane_name, pane_data;
      elt = Fcar (tail);
      pane_name = Fcar (elt);
      CHECK_STRING (pane_name, 0);
      push_menu_pane (pane_name, Qnil);
      pane_data = Fcdr (elt);
      CHECK_CONS (pane_data, 0);
      list_of_items (pane_data);
    }

  finish_menu_items ();
}

/* Push the items in a single pane defined by the alist PANE.  */

static void
list_of_items (pane)
     Lisp_Object pane;
{
  Lisp_Object tail, item, item1;

  for (tail = pane; !NILP (tail); tail = Fcdr (tail))
    {
      item = Fcar (tail);
      if (STRINGP (item))
	push_menu_item (item, Qnil, Qnil, Qt, Qnil);
      else if (NILP (item))
	push_left_right_boundary ();
      else
	{
	  CHECK_CONS (item, 0);
	  item1 = Fcar (item);
	  CHECK_STRING (item1, 1);
	  push_menu_item (item1, Qt, Fcdr (item), Qt, Qnil);
	}
    }
}

DEFUN ("x-popup-menu", Fx_popup_menu, Sx_popup_menu, 2, 2, 0,
  "Pop up a deck-of-cards menu and return user's selection.\n\
POSITION is a position specification.  This is either a mouse button event\n\
or a list ((XOFFSET YOFFSET) WINDOW)\n\
where XOFFSET and YOFFSET are positions in pixels from the top left\n\
corner of WINDOW's frame.  (WINDOW may be a frame object instead of a window.)\n\
This controls the position of the center of the first line\n\
in the first pane of the menu, not the top left of the menu as a whole.\n\
If POSITION is t, it means to use the current mouse position.\n\
\n\
MENU is a specifier for a menu.  For the simplest case, MENU is a keymap.\n\
The menu items come from key bindings that have a menu string as well as\n\
a definition; actually, the \"definition\" in such a key binding looks like\n\
\(STRING . REAL-DEFINITION).  To give the menu a title, put a string into\n\
the keymap as a top-level element.\n\n\
If REAL-DEFINITION is nil, that puts a nonselectable string in the menu.\n\
Otherwise, REAL-DEFINITION should be a valid key binding definition.\n\
\n\
You can also use a list of keymaps as MENU.\n\
  Then each keymap makes a separate pane.\n\
When MENU is a keymap or a list of keymaps, the return value\n\
is a list of events.\n\n\
\n\
Alternatively, you can specify a menu of multiple panes\n\
  with a list of the form (TITLE PANE1 PANE2...),\n\
where each pane is a list of form (TITLE ITEM1 ITEM2...).\n\
Each ITEM is normally a cons cell (STRING . VALUE);\n\
but a string can appear as an item--that makes a nonselectable line\n\
in the menu.\n\
With this form of menu, the return value is VALUE from the chosen item.\n\
\n\
If POSITION is nil, don't display the menu at all, just precalculate the\n\
cached information about equivalent key sequences.")
  (position, menu)
     Lisp_Object position, menu;
{
  int number_of_panes, panes;
  Lisp_Object keymap, tem;
  int xpos, ypos;
  Lisp_Object title;
  char *error_name;
  Lisp_Object selection;
  int i, j;
  FRAME_PTR f;
  Lisp_Object x, y, window;
  int keymaps = 0;
  int for_click = 0;
  struct gcpro gcpro1;

#ifdef HAVE_MENUS
  if (! NILP (position))
    {
      check_w32 ();

      /* Decode the first argument: find the window and the coordinates.  */
      if (EQ (position, Qt)
	  || (CONSP (position) && EQ (XCONS (position)->car, Qmenu_bar)))
	{
	  /* Use the mouse's current position.  */
	  FRAME_PTR new_f = selected_frame;
	  Lisp_Object bar_window;
	  int part;
	  unsigned long time;

	  if (mouse_position_hook)
	    (*mouse_position_hook) (&new_f, 1, &bar_window,
				    &part, &x, &y, &time);
	  if (new_f != 0)
	    XSETFRAME (window, new_f);
	  else
	    {
	      window = selected_window;
	      XSETFASTINT (x, 0);
	      XSETFASTINT (y, 0);
	    }
	}
      else
	{
	  tem = Fcar (position);
	  if (CONSP (tem))
	    {
	      window = Fcar (Fcdr (position));
	      x = Fcar (tem);
	      y = Fcar (Fcdr (tem));
	    }
	  else
	    {
	      for_click = 1;
	      tem = Fcar (Fcdr (position));  /* EVENT_START (position) */
	      window = Fcar (tem);	     /* POSN_WINDOW (tem) */
	      tem = Fcar (Fcdr (Fcdr (tem))); /* POSN_WINDOW_POSN (tem) */
	      x = Fcar (tem);
	      y = Fcdr (tem);
	    }
	}

      CHECK_NUMBER (x, 0);
      CHECK_NUMBER (y, 0);

      /* Decode where to put the menu.  */

      if (FRAMEP (window))
	{
	  f = XFRAME (window);
	  xpos = 0;
	  ypos = 0;
	}
      else if (WINDOWP (window))
	{
	  CHECK_LIVE_WINDOW (window, 0);
	  f = XFRAME (WINDOW_FRAME (XWINDOW (window)));

	  xpos = (FONT_WIDTH (f->output_data.w32->font)
		  * XFASTINT (XWINDOW (window)->left));
	  ypos = (f->output_data.w32->line_height
		  * XFASTINT (XWINDOW (window)->top));
	}
      else
	/* ??? Not really clean; should be CHECK_WINDOW_OR_FRAME,
	   but I don't want to make one now.  */
	CHECK_WINDOW (window, 0);

      xpos += XINT (x);
      ypos += XINT (y);

      XSETFRAME (Vmenu_updating_frame, f);
    }
  Vmenu_updating_frame = Qnil;
#endif /* HAVE_MENUS */

  title = Qnil;
  GCPRO1 (title);

  /* Decode the menu items from what was specified.  */

  keymap = Fkeymapp (menu);
  tem = Qnil;
  if (CONSP (menu))
    tem = Fkeymapp (Fcar (menu));
  if (!NILP (keymap))
    {
      /* We were given a keymap.  Extract menu info from the keymap.  */
      Lisp_Object prompt;
      keymap = get_keymap (menu);

      /* Extract the detailed info to make one pane.  */
      keymap_panes (&menu, 1, NILP (position));

      /* Search for a string appearing directly as an element of the keymap.
	 That string is the title of the menu.  */
      prompt = map_prompt (keymap);
      if (NILP (title) && !NILP (prompt))
	title = prompt;

      /* Make that be the pane title of the first pane.  */
      if (!NILP (prompt) && menu_items_n_panes >= 0)
	XVECTOR (menu_items)->contents[MENU_ITEMS_PANE_NAME] = prompt;

      keymaps = 1;
    }
  else if (!NILP (tem))
    {
      /* We were given a list of keymaps.  */
      int nmaps = XFASTINT (Flength (menu));
      Lisp_Object *maps
	= (Lisp_Object *) alloca (nmaps * sizeof (Lisp_Object));
      int i;

      title = Qnil;

      /* The first keymap that has a prompt string
	 supplies the menu title.  */
      for (tem = menu, i = 0; CONSP (tem); tem = Fcdr (tem))
	{
	  Lisp_Object prompt;

	  maps[i++] = keymap = get_keymap (Fcar (tem));

	  prompt = map_prompt (keymap);
	  if (NILP (title) && !NILP (prompt))
	    title = prompt;
	}

      /* Extract the detailed info to make one pane.  */
      keymap_panes (maps, nmaps, NILP (position));

      /* Make the title be the pane title of the first pane.  */
      if (!NILP (title) && menu_items_n_panes >= 0)
	XVECTOR (menu_items)->contents[MENU_ITEMS_PANE_NAME] = title;

      keymaps = 1;
    }
  else
    {
      /* We were given an old-fashioned menu.  */
      title = Fcar (menu);
      CHECK_STRING (title, 1);

      list_of_panes (Fcdr (menu));

      keymaps = 0;
    }
  
  if (NILP (position))
    {
      discard_menu_items ();
      UNGCPRO;
      return Qnil;
    }

#ifdef HAVE_MENUS
  /* Display them in a menu.  */
  BLOCK_INPUT;

  selection = w32_menu_show (f, xpos, ypos, for_click,
			     keymaps, title, &error_name);
  UNBLOCK_INPUT;

  discard_menu_items ();

  UNGCPRO;
#endif /* HAVE_MENUS */

  if (error_name) error (error_name);
  return selection;
}

#ifdef HAVE_MENUS

DEFUN ("x-popup-dialog", Fx_popup_dialog, Sx_popup_dialog, 2, 2, 0,
  "Pop up a dialog box and return user's selection.\n\
POSITION specifies which frame to use.\n\
This is normally a mouse button event or a window or frame.\n\
If POSITION is t, it means to use the frame the mouse is on.\n\
The dialog box appears in the middle of the specified frame.\n\
\n\
CONTENTS specifies the alternatives to display in the dialog box.\n\
It is a list of the form (TITLE ITEM1 ITEM2...).\n\
Each ITEM is a cons cell (STRING . VALUE).\n\
The return value is VALUE from the chosen item.\n\n\
An ITEM may also be just a string--that makes a nonselectable item.\n\
An ITEM may also be nil--that means to put all preceding items\n\
on the left of the dialog box and all following items on the right.\n\
\(By default, approximately half appear on each side.)")
  (position, contents)
     Lisp_Object position, contents;
{
  FRAME_PTR f;
  Lisp_Object window;

  check_w32 ();

  /* Decode the first argument: find the window or frame to use.  */
  if (EQ (position, Qt)
      || (CONSP (position) && EQ (XCONS (position)->car, Qmenu_bar)))
    {
#if 0 /* Using the frame the mouse is on may not be right.  */
      /* Use the mouse's current position.  */
      FRAME_PTR new_f = selected_frame;
      Lisp_Object bar_window;
      int part;
      unsigned long time;
      Lisp_Object x, y;

      (*mouse_position_hook) (&new_f, 1, &bar_window, &part, &x, &y, &time);

      if (new_f != 0)
	XSETFRAME (window, new_f);
      else
	window = selected_window;
#endif
      window = selected_window;
    }
  else if (CONSP (position))
    {
      Lisp_Object tem;
      tem = Fcar (position);
      if (CONSP (tem))
	window = Fcar (Fcdr (position));
      else
	{
	  tem = Fcar (Fcdr (position));  /* EVENT_START (position) */
	  window = Fcar (tem);	     /* POSN_WINDOW (tem) */
	}
    }
  else if (WINDOWP (position) || FRAMEP (position))
    window = position;
  else
    window = Qnil;

  /* Decode where to put the menu.  */

  if (FRAMEP (window))
    f = XFRAME (window);
  else if (WINDOWP (window))
    {
      CHECK_LIVE_WINDOW (window, 0);
      f = XFRAME (WINDOW_FRAME (XWINDOW (window)));
    }
  else
    /* ??? Not really clean; should be CHECK_WINDOW_OR_FRAME,
       but I don't want to make one now.  */
    CHECK_WINDOW (window, 0);

#if 1
  /* Display a menu with these alternatives
     in the middle of frame F.  */
  {
    Lisp_Object x, y, frame, newpos;
    XSETFRAME (frame, f);
    XSETINT (x, x_pixel_width (f) / 2);
    XSETINT (y, x_pixel_height (f) / 2);
    newpos = Fcons (Fcons (x, Fcons (y, Qnil)), Fcons (frame, Qnil));

    return Fx_popup_menu (newpos,
			  Fcons (Fcar (contents), Fcons (contents, Qnil)));
  }
#else
  {
    Lisp_Object title;
    char *error_name;
    Lisp_Object selection;

    /* Decode the dialog items from what was specified.  */
    title = Fcar (contents);
    CHECK_STRING (title, 1);

    list_of_panes (Fcons (contents, Qnil));

    /* Display them in a dialog box.  */
    BLOCK_INPUT;
    selection = w32_dialog_show (f, 0, title, &error_name);
    UNBLOCK_INPUT;

    discard_menu_items ();

    if (error_name) error (error_name);
    return selection;
  }
#endif
}

/* Activate the menu bar of frame F.
   This is called from keyboard.c when it gets the
   menu_bar_activate_event out of the Emacs event queue.

   To activate the menu bar, we signal to the input thread that it can
   return from the WM_INITMENU message, allowing the normal Windows
   processing of the menus.

   But first we recompute the menu bar contents (the whole tree).

   This way we can safely execute Lisp code.  */
   
x_activate_menubar (f)
     FRAME_PTR f;
{
  set_frame_menubar (f, 0, 1);

  /* Lock out further menubar changes while active.  */
  f->output_data.w32->menubar_active = 1;

  /* Signal input thread to return from WM_INITMENU.  */
  complete_deferred_msg (FRAME_W32_WINDOW (f), WM_INITMENU, 0);
}

/* This callback is called from the menu bar pulldown menu
   when the user makes a selection.
   Figure out what the user chose
   and put the appropriate events into the keyboard buffer.  */

void
menubar_selection_callback (FRAME_PTR f, void * client_data)
{
  Lisp_Object prefix, entry;
  Lisp_Object vector;
  Lisp_Object *subprefix_stack;
  int submenu_depth = 0;
  int i;

  if (!f)
    return;
  subprefix_stack = (Lisp_Object *) alloca (f->menu_bar_items_used * sizeof (Lisp_Object));
  vector = f->menu_bar_vector;
  prefix = Qnil;
  i = 0;
  while (i < f->menu_bar_items_used)
    {
      if (EQ (XVECTOR (vector)->contents[i], Qnil))
	{
	  subprefix_stack[submenu_depth++] = prefix;
	  prefix = entry;
	  i++;
	}
      else if (EQ (XVECTOR (vector)->contents[i], Qlambda))
	{
	  prefix = subprefix_stack[--submenu_depth];
	  i++;
	}
      else if (EQ (XVECTOR (vector)->contents[i], Qt))
	{
	  prefix = XVECTOR (vector)->contents[i + MENU_ITEMS_PANE_PREFIX];
	  i += MENU_ITEMS_PANE_LENGTH;
	}
      else
	{
	  entry = XVECTOR (vector)->contents[i + MENU_ITEMS_ITEM_VALUE];
	  /* The EMACS_INT cast avoids a warning.  There's no problem
	     as long as pointers have enough bits to hold small integers.  */
	  if ((int) (EMACS_INT) client_data == i)
	    {
	      int j;
	      struct input_event buf;
	      Lisp_Object frame;

	      XSETFRAME (frame, f);
	      buf.kind = menu_bar_event;
	      buf.frame_or_window = Fcons (frame, Fcons (Qmenu_bar, Qnil));
	      kbd_buffer_store_event (&buf);

	      for (j = 0; j < submenu_depth; j++)
		if (!NILP (subprefix_stack[j]))
		  {
		    buf.kind = menu_bar_event;
		    buf.frame_or_window = Fcons (frame, subprefix_stack[j]);
		    kbd_buffer_store_event (&buf);
		  }

	      if (!NILP (prefix))
		{
		  buf.kind = menu_bar_event;
		  buf.frame_or_window = Fcons (frame, prefix);
		  kbd_buffer_store_event (&buf);
		}

	      buf.kind = menu_bar_event;
	      buf.frame_or_window = Fcons (frame, entry);
	      kbd_buffer_store_event (&buf);

	      return;
	    }
	  i += MENU_ITEMS_ITEM_LENGTH;
	}
    }
}

/* Allocate a widget_value, blocking input.  */

widget_value *
xmalloc_widget_value ()
{
  widget_value *value;

  BLOCK_INPUT;
  value = malloc_widget_value ();
  UNBLOCK_INPUT;

  return value;
}

/* This recursively calls free_widget_value on the tree of widgets.
   It must free all data that was malloc'ed for these widget_values.
   In Emacs, many slots are pointers into the data of Lisp_Strings, and
   must be left alone.  */

void
free_menubar_widget_value_tree (wv)
     widget_value *wv;
{
  if (! wv) return;

  wv->name = wv->value = wv->key = (char *) 0xDEADBEEF;

  if (wv->contents && (wv->contents != (widget_value*)1))
    {
      free_menubar_widget_value_tree (wv->contents);
      wv->contents = (widget_value *) 0xDEADBEEF;
    }
  if (wv->next)
    {
      free_menubar_widget_value_tree (wv->next);
      wv->next = (widget_value *) 0xDEADBEEF;
    }
  BLOCK_INPUT;
  free_widget_value (wv);
  UNBLOCK_INPUT;
}

/* Return a tree of widget_value structures for a menu bar item
   whose event type is ITEM_KEY (with string ITEM_NAME)
   and whose contents come from the list of keymaps MAPS.  */

static widget_value *
single_submenu (item_key, item_name, maps)
     Lisp_Object item_key, item_name, maps;
{
  widget_value *wv, *prev_wv, *save_wv, *first_wv;
  int i;
  int submenu_depth = 0;
  Lisp_Object length;
  int len;
  Lisp_Object *mapvec;
  widget_value **submenu_stack;
  int mapno;
  int previous_items = menu_items_used;
  int top_level_items = 0;

  length = Flength (maps);
  len = XINT (length);

  /* Convert the list MAPS into a vector MAPVEC.  */
  mapvec = (Lisp_Object *) alloca (len * sizeof (Lisp_Object));
  for (i = 0; i < len; i++)
    {
      mapvec[i] = Fcar (maps);
      maps = Fcdr (maps);
    }

  menu_items_n_panes = 0;

  /* Loop over the given keymaps, making a pane for each map.
     But don't make a pane that is empty--ignore that map instead.  */
  for (i = 0; i < len; i++)
    {
      if (SYMBOLP (mapvec[i])
	  || (CONSP (mapvec[i])
	      && NILP (Fkeymapp (mapvec[i]))))
	{
	  /* Here we have a command at top level in the menu bar
	     as opposed to a submenu.  */
	  top_level_items = 1;
	  push_menu_pane (Qnil, Qnil);
	  push_menu_item (item_name, Qt, item_key, mapvec[i], Qnil);
	}
      else
	single_keymap_panes (mapvec[i], item_name, item_key, 0, 10);
    }

  /* Create a tree of widget_value objects
     representing the panes and their items.  */

  submenu_stack
    = (widget_value **) alloca (menu_items_used * sizeof (widget_value *));
  wv = xmalloc_widget_value ();
  wv->name = "menu";
  wv->value = 0;
  wv->enabled = 1;
  first_wv = wv;
  save_wv = 0;
  prev_wv = 0;
 
  /* Loop over all panes and items made during this call
     and construct a tree of widget_value objects.
     Ignore the panes and items made by previous calls to
     single_submenu, even though those are also in menu_items.  */
  i = previous_items;
  while (i < menu_items_used)
    {
      if (EQ (XVECTOR (menu_items)->contents[i], Qnil))
	{
	  submenu_stack[submenu_depth++] = save_wv;
	  save_wv = prev_wv;
	  prev_wv = 0;
	  i++;
	}
      else if (EQ (XVECTOR (menu_items)->contents[i], Qlambda))
	{
	  prev_wv = save_wv;
	  save_wv = submenu_stack[--submenu_depth];
	  i++;
	}
      else if (EQ (XVECTOR (menu_items)->contents[i], Qt)
	       && submenu_depth != 0)
	i += MENU_ITEMS_PANE_LENGTH;
      /* Ignore a nil in the item list.
	 It's meaningful only for dialog boxes.  */
      else if (EQ (XVECTOR (menu_items)->contents[i], Qquote))
	i += 1;
      else if (EQ (XVECTOR (menu_items)->contents[i], Qt))
	{
	  /* Create a new pane.  */
	  Lisp_Object pane_name, prefix;
	  char *pane_string;
	  pane_name = XVECTOR (menu_items)->contents[i + MENU_ITEMS_PANE_NAME];
	  prefix = XVECTOR (menu_items)->contents[i + MENU_ITEMS_PANE_PREFIX];
#ifndef HAVE_MULTILINGUAL_MENU
	  if (STRINGP (pane_name) && STRING_MULTIBYTE (pane_name))
	    pane_name = ENCODE_SYSTEM (pane_name);
#endif
	  pane_string = (NILP (pane_name)
			 ? "" : (char *) XSTRING (pane_name)->data);
	  /* If there is just one top-level pane, put all its items directly
	     under the top-level menu.  */
	  if (menu_items_n_panes == 1)
	    pane_string = "";

	  /* If the pane has a meaningful name,
	     make the pane a top-level menu item
	     with its items as a submenu beneath it.  */
	  if (strcmp (pane_string, ""))
	    {
	      wv = xmalloc_widget_value ();
	      if (save_wv)
		save_wv->next = wv;
	      else
		first_wv->contents = wv;
	      wv->name = pane_string;
	      /* Ignore the @ that means "separate pane".
		 This is a kludge, but this isn't worth more time.  */
	      if (!NILP (prefix) && wv->name[0] == '@')
		wv->name++;
	      wv->value = 0;
	      wv->enabled = 1;
	    }
	  save_wv = wv;
	  prev_wv = 0;
	  i += MENU_ITEMS_PANE_LENGTH;
	}
      else
	{
	  /* Create a new item within current pane.  */
	  Lisp_Object item_name, enable, descrip, def;
	  item_name = XVECTOR (menu_items)->contents[i + MENU_ITEMS_ITEM_NAME];
	  enable = XVECTOR (menu_items)->contents[i + MENU_ITEMS_ITEM_ENABLE];
	  descrip
	    = XVECTOR (menu_items)->contents[i + MENU_ITEMS_ITEM_EQUIV_KEY];
	  def = XVECTOR (menu_items)->contents[i + MENU_ITEMS_ITEM_DEFINITION];
#ifndef HAVE_MULTILINGUAL_MENU
	  if (STRING_MULTIBYTE (item_name))
	    item_name = ENCODE_SYSTEM (item_name);
	  if (STRINGP (descrip) && STRING_MULTIBYTE (descrip))
	    descrip = ENCODE_SYSTEM (descrip);
#endif
	  wv = xmalloc_widget_value ();
	  if (prev_wv) 
	    prev_wv->next = wv;
	  else
	    save_wv->contents = wv;

	  wv->name = (char *) XSTRING (item_name)->data;
	  if (!NILP (descrip))
	    wv->key = (char *) XSTRING (descrip)->data;
	  wv->value = 0;
	  /* The EMACS_INT cast avoids a warning.  There's no problem
	     as long as pointers have enough bits to hold small integers.  */
	  wv->call_data = (!NILP (def) ? (void *) (EMACS_INT) i : 0);
	  wv->enabled = !NILP (enable);
	  prev_wv = wv;

	  i += MENU_ITEMS_ITEM_LENGTH;
	}
    }

  /* If we have just one "menu item"
     that was originally a button, return it by itself.  */
  if (top_level_items && first_wv->contents && first_wv->contents->next == 0)
    {
      wv = first_wv->contents;
      free_widget_value (first_wv);
      return wv;
    }

  return first_wv;
}

/* Set the contents of the menubar widgets of frame F.
   The argument FIRST_TIME is currently ignored;
   it is set the first time this is called, from initialize_frame_menubar.  */

void
set_frame_menubar (f, first_time, deep_p)
     FRAME_PTR f;
     int first_time;
     int deep_p;
{
  HMENU menubar_widget = f->output_data.w32->menubar_widget;
  Lisp_Object tail, items, frame;
  widget_value *wv, *first_wv, *prev_wv = 0;
  int i;

  /* We must not change the menubar when actually in use.  */
  if (f->output_data.w32->menubar_active)
    return;

  XSETFRAME (Vmenu_updating_frame, f);

  if (! menubar_widget)
    deep_p = 1;
  else if (pending_menu_activation && !deep_p)
    deep_p = 1;

  wv = xmalloc_widget_value ();
  wv->name = "menubar";
  wv->value = 0;
  wv->enabled = 1;
  first_wv = wv;

  if (deep_p)
    {
      /* Make a widget-value tree representing the entire menu trees.  */

      struct buffer *prev = current_buffer;
      Lisp_Object buffer;
      int specpdl_count = specpdl_ptr - specpdl;
      int previous_menu_items_used = f->menu_bar_items_used;
      Lisp_Object *previous_items
	= (Lisp_Object *) alloca (previous_menu_items_used
				  * sizeof (Lisp_Object));

      /* If we are making a new widget, its contents are empty,
	 do always reinitialize them.  */
      if (! menubar_widget)
	previous_menu_items_used = 0;

      buffer = XWINDOW (FRAME_SELECTED_WINDOW (f))->buffer;
      specbind (Qinhibit_quit, Qt);
      /* Don't let the debugger step into this code
	 because it is not reentrant.  */
      specbind (Qdebug_on_next_call, Qnil);

      record_unwind_protect (Fset_match_data, Fmatch_data (Qnil, Qnil));
      if (NILP (Voverriding_local_map_menu_flag))
	{
	  specbind (Qoverriding_terminal_local_map, Qnil);
	  specbind (Qoverriding_local_map, Qnil);
	}

      set_buffer_internal_1 (XBUFFER (buffer));

      /* Run the Lucid hook.  */
      call1 (Vrun_hooks, Qactivate_menubar_hook);
      /* If it has changed current-menubar from previous value,
	 really recompute the menubar from the value.  */
      if (! NILP (Vlucid_menu_bar_dirty_flag))
	call0 (Qrecompute_lucid_menubar);
      safe_run_hooks (Qmenu_bar_update_hook);
      FRAME_MENU_BAR_ITEMS (f) = menu_bar_items (FRAME_MENU_BAR_ITEMS (f));

      items = FRAME_MENU_BAR_ITEMS (f);

      inhibit_garbage_collection ();

      /* Save the frame's previous menu bar contents data.  */
      bcopy (XVECTOR (f->menu_bar_vector)->contents, previous_items,
	     previous_menu_items_used * sizeof (Lisp_Object));

      /* Fill in the current menu bar contents.  */
      menu_items = f->menu_bar_vector;
      menu_items_allocated = XVECTOR (menu_items)->size;
      init_menu_items ();
      for (i = 0; i < XVECTOR (items)->size; i += 4)
	{
	  Lisp_Object key, string, maps;

	  key = XVECTOR (items)->contents[i];
	  string = XVECTOR (items)->contents[i + 1];
	  maps = XVECTOR (items)->contents[i + 2];
	  if (NILP (string))
	    break;

	  wv = single_submenu (key, string, maps);
	  if (prev_wv) 
	    prev_wv->next = wv;
	  else
	    first_wv->contents = wv;
	  /* Don't set wv->name here; GC during the loop might relocate it.  */
	  wv->enabled = 1;
	  prev_wv = wv;
	}

      finish_menu_items ();

      set_buffer_internal_1 (prev);
      unbind_to (specpdl_count, Qnil);

      /* If there has been no change in the Lisp-level contents
	 of the menu bar, skip redisplaying it.  Just exit.  */

      for (i = 0; i < previous_menu_items_used; i++)
	if (menu_items_used == i
	    || (!EQ (previous_items[i], XVECTOR (menu_items)->contents[i])))
	  break;
      if (i == menu_items_used && i == previous_menu_items_used && i != 0)
	{
	  free_menubar_widget_value_tree (first_wv);
	  menu_items = Qnil;

	  return;
	}

      /* Now GC cannot happen during the lifetime of the widget_value,
	 so it's safe to store data from a Lisp_String.  */
      wv = first_wv->contents;
      for (i = 0; i < XVECTOR (items)->size; i += 4)
	{
	  Lisp_Object string;
	  string = XVECTOR (items)->contents[i + 1];
	  if (NILP (string))
	    break;
	  wv->name = (char *) XSTRING (string)->data;
	  wv = wv->next;
	}

      f->menu_bar_vector = menu_items;
      f->menu_bar_items_used = menu_items_used;
      menu_items = Qnil;
    }
  else
    {
      /* Make a widget-value tree containing
	 just the top level menu bar strings.

	 It turns out to be worth comparing the new contents with the
	 previous contents to avoid unnecessary rebuilding even of just
	 the top-level menu bar, which turns out to be fairly slow.  We
	 co-opt f->menu_bar_vector for this purpose, since its contents
	 are effectively discarded at this point anyway.

	 Note that the lisp-level hooks have already been run by
	 update_menu_bar - it's kinda a shame the code is duplicated
	 above as well for deep_p, but there we are.  */

      items = FRAME_MENU_BAR_ITEMS (f);

      /* If there has been no change in the Lisp-level contents of just
	 the menu bar itself, skip redisplaying it.  Just exit.  */
      for (i = 0; i < f->menu_bar_items_used; i += 4)
	if (i == XVECTOR (items)->size
	    || (XVECTOR (f->menu_bar_vector)->contents[i]
		!= XVECTOR (items)->contents[i]))
	  break;
      if (i == XVECTOR (items)->size && i == f->menu_bar_items_used && i != 0)
	  return;

      for (i = 0; i < XVECTOR (items)->size; i += 4)
	{
	  Lisp_Object string;

	  string = XVECTOR (items)->contents[i + 1];
	  if (NILP (string))
	    break;

	  wv = xmalloc_widget_value ();
	  wv->name = (char *) XSTRING (string)->data;
	  wv->value = 0;
	  wv->enabled = 1;
	  /* This prevents lwlib from assuming this
	     menu item is really supposed to be empty.  */
	  /* The EMACS_INT cast avoids a warning.
	     This value just has to be different from small integers.  */
	  wv->call_data = (void *) (EMACS_INT) (-1);

	  if (prev_wv) 
	    prev_wv->next = wv;
	  else
	    first_wv->contents = wv;
	  prev_wv = wv;
	}

      /* Remember the contents of FRAME_MENU_BAR_ITEMS (f) in
	 f->menu_bar_vector, so we can check whether the top-level
	 menubar contents have changed next time.  */
      if (XVECTOR (f->menu_bar_vector)->size < XVECTOR (items)->size)
	f->menu_bar_vector
	  = Fmake_vector (make_number (XVECTOR (items)->size), Qnil);
      bcopy (XVECTOR (items)->contents,
	     XVECTOR (f->menu_bar_vector)->contents,
	     XVECTOR (items)->size * sizeof (Lisp_Object));
      f->menu_bar_items_used = XVECTOR (items)->size;
    }

  /* Create or update the menu bar widget.  */

  BLOCK_INPUT;

  if (menubar_widget)
    {
      /* Empty current menubar, rather than creating a fresh one.  */
      while (DeleteMenu (menubar_widget, 0, MF_BYPOSITION))
	;
    }
  else
    {
      menubar_widget = CreateMenu ();
    }
  fill_in_menu (menubar_widget, first_wv->contents);

  free_menubar_widget_value_tree (first_wv);

  {
    HMENU old_widget = f->output_data.w32->menubar_widget;

    f->output_data.w32->menubar_widget = menubar_widget;
    SetMenu (FRAME_W32_WINDOW (f), f->output_data.w32->menubar_widget);
    /* Causes flicker when menu bar is updated 
    DrawMenuBar (FRAME_W32_WINDOW (f)); */

    /* Force the window size to be recomputed so that the frame's text
       area remains the same, if menubar has just been created.  */
    if (old_widget == NULL)
      x_set_window_size (f, 0, FRAME_WIDTH (f), FRAME_HEIGHT (f));
  }

  UNBLOCK_INPUT;
}

/* Called from Fx_create_frame to create the initial menubar of a frame
   before it is mapped, so that the window is mapped with the menubar already
   there instead of us tacking it on later and thrashing the window after it
   is visible.  */

void
initialize_frame_menubar (f)
     FRAME_PTR f;
{
  /* This function is called before the first chance to redisplay
     the frame.  It has to be, so the frame will have the right size.  */
  FRAME_MENU_BAR_ITEMS (f) = menu_bar_items (FRAME_MENU_BAR_ITEMS (f));
  set_frame_menubar (f, 1, 1);
}

/* Get rid of the menu bar of frame F, and free its storage.
   This is used when deleting a frame, and when turning off the menu bar.  */

void
free_frame_menubar (f)
     FRAME_PTR f;
{
  BLOCK_INPUT;

  {
    HMENU old = GetMenu (FRAME_W32_WINDOW (f));
    SetMenu (FRAME_W32_WINDOW (f), NULL);
    f->output_data.w32->menubar_widget = NULL;
    DestroyMenu (old);
  }
    
  UNBLOCK_INPUT;
}


/* w32_menu_show actually displays a menu using the panes and items in
   menu_items and returns the value selected from it; we assume input
   is blocked by the caller.  */

/* F is the frame the menu is for.
   X and Y are the frame-relative specified position,
   relative to the inside upper left corner of the frame F.
   FOR_CLICK is nonzero if this menu was invoked for a mouse click.
   KEYMAPS is 1 if this menu was specified with keymaps;
    in that case, we return a list containing the chosen item's value
    and perhaps also the pane's prefix.
   TITLE is the specified menu title.
   ERROR is a place to store an error message string in case of failure.
   (We return nil on failure, but the value doesn't actually matter.)  */

static Lisp_Object
w32_menu_show (f, x, y, for_click, keymaps, title, error)
     FRAME_PTR f;
     int x;
     int y;
     int for_click;
     int keymaps;
     Lisp_Object title;
     char **error;
{
  int i;
  int menu_item_selection;
  HMENU menu;
  POINT pos;
  widget_value *wv, *save_wv = 0, *first_wv = 0, *prev_wv = 0;
  widget_value **submenu_stack
    = (widget_value **) alloca (menu_items_used * sizeof (widget_value *));
  Lisp_Object *subprefix_stack
    = (Lisp_Object *) alloca (menu_items_used * sizeof (Lisp_Object));
  int submenu_depth = 0;

  int first_pane;
  int next_release_must_exit = 0;

  *error = NULL;

  if (menu_items_used <= MENU_ITEMS_PANE_LENGTH)
    {
      *error = "Empty menu";
      return Qnil;
    }

  /* Create a tree of widget_value objects
     representing the panes and their items.  */
  wv = xmalloc_widget_value ();
  wv->name = "menu";
  wv->value = 0;
  wv->enabled = 1;
  first_wv = wv;
  first_pane = 1;
 
  /* Loop over all panes and items, filling in the tree.  */
  i = 0;
  while (i < menu_items_used)
    {
      if (EQ (XVECTOR (menu_items)->contents[i], Qnil))
	{
	  submenu_stack[submenu_depth++] = save_wv;
	  save_wv = prev_wv;
	  prev_wv = 0;
	  first_pane = 1;
	  i++;
	}
      else if (EQ (XVECTOR (menu_items)->contents[i], Qlambda))
	{
	  prev_wv = save_wv;
	  save_wv = submenu_stack[--submenu_depth];
	  first_pane = 0;
	  i++;
	}
      else if (EQ (XVECTOR (menu_items)->contents[i], Qt)
	       && submenu_depth != 0)
	i += MENU_ITEMS_PANE_LENGTH;
      /* Ignore a nil in the item list.
	 It's meaningful only for dialog boxes.  */
      else if (EQ (XVECTOR (menu_items)->contents[i], Qquote))
	i += 1;
      else if (EQ (XVECTOR (menu_items)->contents[i], Qt))
	{
	  /* Create a new pane.  */
	  Lisp_Object pane_name, prefix;
	  char *pane_string;
	  pane_name = XVECTOR (menu_items)->contents[i + MENU_ITEMS_PANE_NAME];
	  prefix = XVECTOR (menu_items)->contents[i + MENU_ITEMS_PANE_PREFIX];
#ifndef HAVE_MULTILINGUAL_MENU
	  if (!NILP (pane_name) && STRING_MULTIBYTE (pane_name))
	    pane_name = ENCODE_SYSTEM (pane_name);
#endif
	  pane_string = (NILP (pane_name)
			 ? "" : (char *) XSTRING (pane_name)->data);
	  /* If there is just one top-level pane, put all its items directly
	     under the top-level menu.  */
	  if (menu_items_n_panes == 1)
	    pane_string = "";

	  /* If the pane has a meaningful name,
	     make the pane a top-level menu item
	     with its items as a submenu beneath it.  */
	  if (!keymaps && strcmp (pane_string, ""))
	    {
	      wv = xmalloc_widget_value ();
	      if (save_wv)
		save_wv->next = wv;
	      else
		first_wv->contents = wv;
	      wv->name = pane_string;
	      if (keymaps && !NILP (prefix))
		wv->name++;
	      wv->value = 0;
	      wv->enabled = 1;
	      save_wv = wv;
	      prev_wv = 0;
	    }
	  else if (first_pane)
	    {
	      save_wv = wv;
	      prev_wv = 0;
	    }
	  first_pane = 0;
	  i += MENU_ITEMS_PANE_LENGTH;
	}
      else
	{
	  /* Create a new item within current pane.  */
	  Lisp_Object item_name, enable, descrip, def;
	  item_name = XVECTOR (menu_items)->contents[i + MENU_ITEMS_ITEM_NAME];
	  enable = XVECTOR (menu_items)->contents[i + MENU_ITEMS_ITEM_ENABLE];
	  descrip
	    = XVECTOR (menu_items)->contents[i + MENU_ITEMS_ITEM_EQUIV_KEY];
	  def = XVECTOR (menu_items)->contents[i + MENU_ITEMS_ITEM_DEFINITION];

#ifndef HAVE_MULTILINGUAL_MENU
	  if (STRING_MULTIBYTE (item_name))
	    item_name = ENCODE_SYSTEM (item_name);
	  if (STRINGP (descrip) && STRING_MULTIBYTE (descrip))
	    descrip = ENCODE_SYSTEM (descrip);
#endif

	  wv = xmalloc_widget_value ();
	  if (prev_wv) 
	    prev_wv->next = wv;
	  else 
	    save_wv->contents = wv;
	  wv->name = (char *) XSTRING (item_name)->data;
	  if (!NILP (descrip))
	    wv->key = (char *) XSTRING (descrip)->data;
	  wv->value = 0;
	  /* Use the contents index as call_data, since we are
             restricted to 16-bits..  */
	  wv->call_data = !NILP (def) ? (void *) (EMACS_INT) i : 0;
	  wv->enabled = !NILP (enable);
	  prev_wv = wv;

	  i += MENU_ITEMS_ITEM_LENGTH;
	}
    }

  /* Deal with the title, if it is non-nil.  */
  if (!NILP (title))
    {
      widget_value *wv_title = xmalloc_widget_value ();
      widget_value *wv_sep = xmalloc_widget_value ();

      /* Maybe replace this separator with a bitmap or owner-draw item
	 so that it looks better.  Having two separators looks odd.  */
      wv_sep->name = "--";
      wv_sep->next = first_wv->contents;

#ifndef HAVE_MULTILINGUAL_MENU
      if (STRING_MULTIBYTE (title))
	title = ENCODE_SYSTEM (title);
#endif
      wv_title->name = (char *) XSTRING (title)->data;
      /* Handle title specially, so it looks better.  */
      wv_title->title = True;
      wv_title->next = wv_sep;
      first_wv->contents = wv_title;
    }

  /* Actually create the menu.  */
  menu = CreatePopupMenu ();
  fill_in_menu (menu, first_wv->contents);
    
  /* Adjust coordinates to be root-window-relative.  */
  pos.x = x;
  pos.y = y;
  ClientToScreen (FRAME_W32_WINDOW (f), &pos);

  /* Free the widget_value objects we used to specify the contents.  */
  free_menubar_widget_value_tree (first_wv);

  /* No selection has been chosen yet.  */
  menu_item_selection = 0;

  /* Display the menu.  */
  menu_item_selection = SendMessage (FRAME_W32_WINDOW (f), 
				     WM_EMACS_TRACKPOPUPMENU,
				     (WPARAM)menu, (LPARAM)&pos);

  /* Clean up extraneous mouse events which might have been generated
     during the call. */
  discard_mouse_events ();

  DestroyMenu (menu);

  /* Find the selected item, and its pane, to return
     the proper value.  */
  if (menu_item_selection != 0)
    {
      Lisp_Object prefix, entry;

      prefix = Qnil;
      i = 0;
      while (i < menu_items_used)
	{
	  if (EQ (XVECTOR (menu_items)->contents[i], Qnil))
	    {
	      subprefix_stack[submenu_depth++] = prefix;
	      prefix = entry;
	      i++;
	    }
	  else if (EQ (XVECTOR (menu_items)->contents[i], Qlambda))
	    {
	      prefix = subprefix_stack[--submenu_depth];
	      i++;
	    }
	  else if (EQ (XVECTOR (menu_items)->contents[i], Qt))
	    {
	      prefix
		= XVECTOR (menu_items)->contents[i + MENU_ITEMS_PANE_PREFIX];
	      i += MENU_ITEMS_PANE_LENGTH;
	    }
	  /* Ignore a nil in the item list.
	     It's meaningful only for dialog boxes.  */
	  else if (EQ (XVECTOR (menu_items)->contents[i], Qquote))
	    i += 1;
	  else
	    {
	      entry
		= XVECTOR (menu_items)->contents[i + MENU_ITEMS_ITEM_VALUE];
	      if (menu_item_selection == i)
		{
		  if (keymaps != 0)
		    {
		      int j;

		      entry = Fcons (entry, Qnil);
		      if (!NILP (prefix))
			entry = Fcons (prefix, entry);
		      for (j = submenu_depth - 1; j >= 0; j--)
			if (!NILP (subprefix_stack[j]))
			  entry = Fcons (subprefix_stack[j], entry);
		    }
		  return entry;
		}
	      i += MENU_ITEMS_ITEM_LENGTH;
	    }
	}
    }

  return Qnil;
}


static char * button_names [] = {
  "button1", "button2", "button3", "button4", "button5",
  "button6", "button7", "button8", "button9", "button10" };

static Lisp_Object
w32_dialog_show (f, keymaps, title, error)
     FRAME_PTR f;
     int keymaps;
     Lisp_Object title;
     char **error;
{
  int i, nb_buttons=0;
  char dialog_name[6];
  int menu_item_selection;

  widget_value *wv, *save_wv = 0, *first_wv = 0, *prev_wv = 0;

  /* Number of elements seen so far, before boundary.  */
  int left_count = 0;
  /* 1 means we've seen the boundary between left-hand elts and right-hand.  */
  int boundary_seen = 0;

  *error = NULL;

  if (menu_items_n_panes > 1)
    {
      *error = "Multiple panes in dialog box";
      return Qnil;
    }

  /* Create a tree of widget_value objects
     representing the text label and buttons.  */
  {
    Lisp_Object pane_name, prefix;
    char *pane_string;
    pane_name = XVECTOR (menu_items)->contents[MENU_ITEMS_PANE_NAME];
    prefix = XVECTOR (menu_items)->contents[MENU_ITEMS_PANE_PREFIX];
    pane_string = (NILP (pane_name)
		   ? "" : (char *) XSTRING (pane_name)->data);  
    prev_wv = xmalloc_widget_value ();
    prev_wv->value = pane_string;
    if (keymaps && !NILP (prefix))
      prev_wv->name++;
    prev_wv->enabled = 1;
    prev_wv->name = "message";
    first_wv = prev_wv;
 
    /* Loop over all panes and items, filling in the tree.  */
    i = MENU_ITEMS_PANE_LENGTH;
    while (i < menu_items_used)
      {
	
	/* Create a new item within current pane.  */
	Lisp_Object item_name, enable, descrip;
	item_name = XVECTOR (menu_items)->contents[i + MENU_ITEMS_ITEM_NAME];
	enable = XVECTOR (menu_items)->contents[i + MENU_ITEMS_ITEM_ENABLE];
	descrip
	  = XVECTOR (menu_items)->contents[i + MENU_ITEMS_ITEM_EQUIV_KEY];
	
	if (NILP (item_name))
	  {
	    free_menubar_widget_value_tree (first_wv);
	    *error = "Submenu in dialog items";
	    return Qnil;
	  }
	if (EQ (item_name, Qquote))
	  {
	    /* This is the boundary between left-side elts
	       and right-side elts.  Stop incrementing right_count.  */
	    boundary_seen = 1;
	    i++;
	    continue;
	  }
	if (nb_buttons >= 9)
	  {
	    free_menubar_widget_value_tree (first_wv);
	    *error = "Too many dialog items";
	    return Qnil;
	  }

	wv = xmalloc_widget_value ();
	prev_wv->next = wv;
	wv->name = (char *) button_names[nb_buttons];
	if (!NILP (descrip))
	  wv->key = (char *) XSTRING (descrip)->data;
	wv->value = (char *) XSTRING (item_name)->data;
	wv->call_data = (void *) &XVECTOR (menu_items)->contents[i];
	wv->enabled = !NILP (enable);
	prev_wv = wv;

	if (! boundary_seen)
	  left_count++;

	nb_buttons++;
	i += MENU_ITEMS_ITEM_LENGTH;
      }

    /* If the boundary was not specified,
       by default put half on the left and half on the right.  */
    if (! boundary_seen)
      left_count = nb_buttons - nb_buttons / 2;

    wv = xmalloc_widget_value ();
    wv->name = dialog_name;

    /* Dialog boxes use a really stupid name encoding
       which specifies how many buttons to use
       and how many buttons are on the right.
       The Q means something also.  */
    dialog_name[0] = 'Q';
    dialog_name[1] = '0' + nb_buttons;
    dialog_name[2] = 'B';
    dialog_name[3] = 'R';
    /* Number of buttons to put on the right.  */
    dialog_name[4] = '0' + nb_buttons - left_count;
    dialog_name[5] = 0;
    wv->contents = first_wv;
    first_wv = wv;
  }

  /* Actually create the dialog.  */
#if 0
  dialog_id = widget_id_tick++;
  menu = lw_create_widget (first_wv->name, "dialog", dialog_id, first_wv,
			   f->output_data.w32->widget, 1, 0,
			   dialog_selection_callback, 0);
  lw_modify_all_widgets (dialog_id, first_wv->contents, True);
#endif

  /* Free the widget_value objects we used to specify the contents.  */
  free_menubar_widget_value_tree (first_wv);

  /* No selection has been chosen yet.  */
  menu_item_selection = 0;

  /* Display the menu.  */
#if 0
  lw_pop_up_all_widgets (dialog_id);
  popup_activated_flag = 1;

  /* Process events that apply to the menu.  */
  popup_get_selection ((XEvent *) 0, FRAME_X_DISPLAY_INFO (f), dialog_id);

  lw_destroy_all_widgets (dialog_id); 
#endif

  /* Find the selected item, and its pane, to return
     the proper value.  */
  if (menu_item_selection != 0)
    {
      Lisp_Object prefix;

      prefix = Qnil;
      i = 0;
      while (i < menu_items_used)
	{
	  Lisp_Object entry;

	  if (EQ (XVECTOR (menu_items)->contents[i], Qt))
	    {
	      prefix
		= XVECTOR (menu_items)->contents[i + MENU_ITEMS_PANE_PREFIX];
	      i += MENU_ITEMS_PANE_LENGTH;
	    }
	  else
	    {
	      entry
		= XVECTOR (menu_items)->contents[i + MENU_ITEMS_ITEM_VALUE];
	      if (menu_item_selection == i)
		{
		  if (keymaps != 0)
		    {
		      entry = Fcons (entry, Qnil);
		      if (!NILP (prefix))
			entry = Fcons (prefix, entry);
		    }
		  return entry;
		}
	      i += MENU_ITEMS_ITEM_LENGTH;
	    }
	}
    }

  return Qnil;
}


/* Is this item a separator? */
static int
name_is_separator (name)
     char *name;
{
  /* Check if name string consists of only dashes ('-') */
  while (*name == '-') name++;
  return (*name == '\0');
}


/* Indicate boundary between left and right.  */
static int
add_left_right_boundary (HMENU menu)
{
  return AppendMenu (menu, MF_MENUBARBREAK, 0, NULL);
}

static int
add_menu_item (HMENU menu, widget_value *wv, HMENU item)
{
  UINT fuFlags;
  char *out_string;

  if (name_is_separator (wv->name))
    fuFlags = MF_SEPARATOR;
  else 
    {
      if (wv->enabled)
	fuFlags = MF_STRING;
      else
	fuFlags = MF_STRING | MF_GRAYED;

      if (wv->key != NULL)
	{
	  out_string = alloca (strlen (wv->name) + strlen (wv->key) + 2);
	  strcpy (out_string, wv->name);
	  strcat (out_string, "\t");
	  strcat (out_string, wv->key);
	}
      else
	out_string = wv->name;

      if (wv->title || wv->call_data == 0)
	{
#if 0  /* no GC while popup menu is active */
	  out_string = LocalAlloc (0, strlen (wv->name) + 1);
	  strcpy (out_string, wv->name);
#endif
	  fuFlags = MF_OWNERDRAW | MF_DISABLED;
	}
    }

  if (item != NULL)
    fuFlags = MF_POPUP;

  return AppendMenu (menu,
		     fuFlags,
		     item != NULL ? (UINT) item : (UINT) wv->call_data,
		     (fuFlags == MF_SEPARATOR) ? NULL: out_string );
}

/* Construct native Windows menu(bar) based on widget_value tree.  */
static int
fill_in_menu (HMENU menu, widget_value *wv)
{
  int items_added = 0;

  for ( ; wv != NULL; wv = wv->next)
    {
      if (wv->contents)
	{
	  HMENU sub_menu = CreatePopupMenu ();

	  if (sub_menu == NULL)
	    return 0;

	  if (!fill_in_menu (sub_menu, wv->contents) ||
	      !add_menu_item (menu, wv, sub_menu))
	    {
	      DestroyMenu (sub_menu);
	      return 0;
	    }
	}
      else
	{
	  if (!add_menu_item (menu, wv, NULL))
	    return 0;
	}
    }
  return 1;
}

#endif /* HAVE_MENUS */

syms_of_w32menu ()
{
  staticpro (&menu_items);
  menu_items = Qnil;

  Qdebug_on_next_call = intern ("debug-on-next-call");
  staticpro (&Qdebug_on_next_call);

  DEFVAR_LISP ("menu-updating-frame", &Vmenu_updating_frame,
    "Frame for which we are updating a menu.\n\
The enable predicate for a menu command should check this variable.");
  Vmenu_updating_frame = Qnil;

  defsubr (&Sx_popup_menu);
#ifdef HAVE_MENUS
  defsubr (&Sx_popup_dialog);
#endif
}
