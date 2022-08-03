/*
 * guile.h
 *
 * by Gary Wong <gtw@gnu.org>, 2000
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
 * $Id: guile.h,v 1.3 2001/02/13 18:21:20 gtw Exp $
 */

#if USE_GUILE

#ifndef _GUILE_H_
#define _GUILE_H_

#define GNUBG_SCM "gnubg.scm"

extern int GuileInitialise( char *szDir );
extern int GuileStartIntHandler( void );
extern int GuileEndIntHandler( void );

#endif

#endif
