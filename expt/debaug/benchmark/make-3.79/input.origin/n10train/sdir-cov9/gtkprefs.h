/*
 * gtkprefs.h
 *
 * by Gary Wong <gtw@gnu.org>, 2000.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of version 2 of the GNU General Public License as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 * $Id: gtkprefs.h,v 1.3 2001/01/16 18:38:53 gtw Exp $
 */

#ifndef _GTKPREFS_H_
#define _GTKPREFS_H_

#include "gtkboard.h"

extern void BoardPreferences( GtkWidget *pwBoard );
extern void BoardPreferencesParam( GtkWidget *pwBoard, char *szParam,
				   char *szValue );
extern char *BoardPreferencesCommand( GtkWidget *pwBoard, char *sz );
extern void BoardPreferencesStart( GtkWidget *pwBoard );
extern void BoardPreferencesDone( GtkWidget *pwBoard );

#endif
