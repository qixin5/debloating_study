/*
 * mt19937int.h
 *
 * by Takuji Nishimura, 1997-1999
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
 * $Id: mt19937int.h,v 1.1 2000/11/10 18:50:43 gtw Exp $
 */

#ifndef _MT19937INT_H_
#define _MT19937INT_H_

extern void sgenrand( unsigned long seed );
extern void lsgenrand( unsigned long seed_array[] );
extern unsigned long genrand( void );

#endif
