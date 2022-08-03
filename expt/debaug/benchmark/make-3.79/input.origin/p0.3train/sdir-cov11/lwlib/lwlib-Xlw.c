/* The lwlib interface to "xlwmenu" menus.
   Copyright (C) 1992 Lucid, Inc.

This file is part of the Lucid Widget Library.

The Lucid Widget Library is free software; you can redistribute it and/or 
modify it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 1, or (at your option)
any later version.

The Lucid Widget Library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of 
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with GNU Emacs; see the file COPYING.  If not, write to
the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
Boston, MA 02111-1307, USA.  */

#include "lwlib-Xlw.h"
#include <X11/StringDefs.h>
#include <X11/IntrinsicP.h>
#include <X11/ObjectP.h>
#include <X11/CompositeP.h>
#include <X11/Shell.h>
#include "xlwmenu.h"

/* Menu callbacks */
static void
pre_hook (w, client_data, call_data)
     Widget w;
     XtPointer client_data;
     XtPointer call_data;
{
  widget_instance* instance = (widget_instance*)client_data;
  widget_value* val;

  if (w->core.being_destroyed)
    return;

  val = lw_get_widget_value_for_widget (instance, w);
  if (instance->info->pre_activate_cb)
    instance->info->pre_activate_cb (w, instance->info->id,
				     val ? val->call_data : NULL);
}

static void
pick_hook (w, client_data, call_data)
     Widget w;
     XtPointer client_data;
     XtPointer call_data;
{
  widget_instance* instance = (widget_instance*)client_data;
  widget_value* contents_val = (widget_value*)call_data;
  widget_value* widget_val;
  XtPointer widget_arg;

  if (w->core.being_destroyed)
    return;

  if (instance->info->selection_cb && contents_val && contents_val->enabled
      && !contents_val->contents)
    instance->info->selection_cb (w, instance->info->id,
				  contents_val->call_data);

  widget_val = lw_get_widget_value_for_widget (instance, w);
  widget_arg = widget_val ? widget_val->call_data : NULL;
  if (instance->info->post_activate_cb)
    instance->info->post_activate_cb (w, instance->info->id, widget_arg);

}

/* creation functions */

static Widget
xlw_create_menubar (instance)
     widget_instance* instance;
{
  Widget widget;
  Arg al[5];
  int ac = 0;

  XtSetArg (al[ac], XtNmenu, instance->info->val); ac++;
#ifdef emacs
  XtSetArg (al[ac], XtNshowGrip, 0); ac++;
  XtSetArg (al[ac], XtNresizeToPreferred, 1); ac++;
  XtSetArg (al[ac], XtNallowResize, 1); ac++;
#endif

  /* This used to use XtVaCreateWidget, but an old Xt version
     has a bug in XtVaCreateWidget that frees instance->info->name.  */
  widget
    = XtCreateWidget (instance->info->name, xlwMenuWidgetClass,
		      instance->parent, al, ac);

  XtAddCallback (widget, XtNopen, pre_hook, (XtPointer)instance);
  XtAddCallback (widget, XtNselect, pick_hook, (XtPointer)instance);
  return widget;
}

static Widget
xlw_create_popup_menu (instance)
     widget_instance* instance;
{
  Widget popup_shell
    = XtCreatePopupShell (instance->info->name, overrideShellWidgetClass,
			  instance->parent, NULL, 0);
  
  Widget widget;
  Arg al[2];
  int ac = 0;

  XtSetArg (al[ac], XtNmenu, instance->info->val); ac++;
  XtSetArg (al[ac], XtNhorizontal, False); ac++;

  /* This used to use XtVaManagedCreateWidget, but an old Xt version
     has a bug in XtVaManagedCreateWidget that frees instance->info->name.  */
  widget
    = XtCreateManagedWidget ("popup", xlwMenuWidgetClass,
			     popup_shell, al, ac);

  XtAddCallback (widget, XtNselect, pick_hook, (XtPointer)instance);

  return popup_shell;
}

widget_creation_entry 
xlw_creation_table [] =
{
  {"menubar", xlw_create_menubar},
  {"popup", xlw_create_popup_menu},
  {NULL, NULL}
};

Boolean
lw_lucid_widget_p (widget)
     Widget widget;
{
  WidgetClass the_class = XtClass (widget);

  if (the_class == xlwMenuWidgetClass)
    return True;
  if (the_class == overrideShellWidgetClass)
    return (XtClass (((CompositeWidget)widget)->composite.children [0])
	    == xlwMenuWidgetClass);
  return False;
}

void
xlw_update_one_widget (instance, widget, val, deep_p)
     widget_instance* instance;
     Widget widget;
     widget_value* val;
     Boolean deep_p;
{
  XlwMenuWidget mw;
  Arg al[1];

  if (XtIsShell (widget))
    mw = (XlwMenuWidget)((CompositeWidget)widget)->composite.children [0];
  else
    mw = (XlwMenuWidget)widget;

  /* This used to use XtVaSetValues, but some old Xt versions
     that have a bug in XtVaCreateWidget might have it here too.  */
  XtSetArg (al[0], XtNmenu, instance->info->val);

  XtSetValues (widget, al, 1);
}

void
xlw_update_one_value (instance, widget, val)
     widget_instance* instance;
     Widget widget;
     widget_value* val;
{
  return;
}

void
xlw_pop_instance (instance, up)
     widget_instance* instance;
     Boolean up;
{
}

void
xlw_popup_menu (widget, event)
     Widget widget;
     XEvent *event;
{
  XButtonPressedEvent dummy;
  XlwMenuWidget mw;

  if (!XtIsShell (widget))
    return;

  mw = (XlwMenuWidget)((CompositeWidget)widget)->composite.children [0];

  if (event)
    pop_up_menu (mw, event);
  else
    {
      dummy.type = ButtonPress;
      dummy.serial = 0;
      dummy.send_event = 0;
      dummy.display = XtDisplay (widget);
      dummy.window = XtWindow (XtParent (widget));
      dummy.time = CurrentTime;
      dummy.button = 0;
      XQueryPointer (dummy.display, dummy.window, &dummy.root,
		     &dummy.subwindow, &dummy.x_root, &dummy.y_root,
		     &dummy.x, &dummy.y, &dummy.state);

      pop_up_menu (mw, &dummy);
    }
}

/* Destruction of instances */
void
xlw_destroy_instance (instance)
     widget_instance* instance;
{
  if (instance->widget)
    XtDestroyWidget (instance->widget);
}

