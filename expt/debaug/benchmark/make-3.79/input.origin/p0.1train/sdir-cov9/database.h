/*
 * database.h
 *
 * by Gary Wong <gary@cs.arizona.edu>, 1999.
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
 * $Id: database.h,v 1.1.1.1 1999/12/15 01:17:34 gtw Exp $
 */

#ifndef _DATABASE_H_
#define _DATABASE_H_

#if HAVE_LIBGDBM
#include <time.h>

/* Evaluation structure of database positions */
typedef struct _dbevaluation {
    time_t t;
    unsigned short asEq[ NUM_OUTPUTS ];
    short c; /* Number of rollouts */
} dbevaluation;
#endif

#endif
