/* Code for doing intervals.
   Copyright (C) 1993, 1994, 1995, 1997, 1998 Free Software Foundation, Inc.

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


/* NOTES:

   Have to ensure that we can't put symbol nil on a plist, or some
   functions may work incorrectly.

   An idea:  Have the owner of the tree keep count of splits and/or
   insertion lengths (in intervals), and balance after every N.

   Need to call *_left_hook when buffer is killed.

   Scan for zero-length, or 0-length to see notes about handling
   zero length interval-markers.

   There are comments around about freeing intervals.  It might be
   faster to explicitly free them (put them on the free list) than
   to GC them.

*/


#include <config.h>
#include "lisp.h"
#include "intervals.h"
#include "buffer.h"
#include "puresize.h"
#include "keyboard.h"

/* The rest of the file is within this conditional.  */
#ifdef USE_TEXT_PROPERTIES

/* Test for membership, allowing for t (actually any non-cons) to mean the
   universal set.  */

#define TMEM(sym, set) (CONSP (set) ? ! NILP (Fmemq (sym, set)) : ! NILP (set))

#define min(x, y) ((x) < (y) ? (x) : (y))

Lisp_Object merge_properties_sticky ();

/* Utility functions for intervals.  */


/* Create the root interval of some object, a buffer or string.  */

INTERVAL
create_root_interval (parent)
     Lisp_Object parent;
{
  INTERVAL new;

  CHECK_IMPURE (parent);

  new = make_interval ();

  if (BUFFERP (parent))
    {
      new->total_length = (BUF_Z (XBUFFER (parent))
			   - BUF_BEG (XBUFFER (parent)));
      BUF_INTERVALS (XBUFFER (parent)) = new;
      new->position = 1;
    }
  else if (STRINGP (parent))
    {
      new->total_length = XSTRING (parent)->size;
      XSTRING (parent)->intervals = new;
      new->position = 0;
    }

  new->parent = (INTERVAL) XFASTINT (parent);

  return new;
}

/* Make the interval TARGET have exactly the properties of SOURCE */

void
copy_properties (source, target)
     register INTERVAL source, target;
{
  if (DEFAULT_INTERVAL_P (source) && DEFAULT_INTERVAL_P (target))
    return;

  COPY_INTERVAL_CACHE (source, target);
  target->plist = Fcopy_sequence (source->plist);
}

/* Merge the properties of interval SOURCE into the properties
   of interval TARGET.  That is to say, each property in SOURCE
   is added to TARGET if TARGET has no such property as yet.  */

static void
merge_properties (source, target)
     register INTERVAL source, target;
{
  register Lisp_Object o, sym, val;

  if (DEFAULT_INTERVAL_P (source) && DEFAULT_INTERVAL_P (target))
    return;

  MERGE_INTERVAL_CACHE (source, target);

  o = source->plist;
  while (! EQ (o, Qnil))
    {
      sym = Fcar (o);
      val = Fmemq (sym, target->plist);

      if (NILP (val))
	{
	  o = Fcdr (o);
	  val = Fcar (o);
	  target->plist = Fcons (sym, Fcons (val, target->plist));
	  o = Fcdr (o);
	}
      else
	o = Fcdr (Fcdr (o));
    }
}

/* Return 1 if the two intervals have the same properties,
   0 otherwise.  */

int
intervals_equal (i0, i1)
     INTERVAL i0, i1;
{
  register Lisp_Object i0_cdr, i0_sym, i1_val;
  register int i1_len;

  if (DEFAULT_INTERVAL_P (i0) && DEFAULT_INTERVAL_P (i1))
    return 1;

  if (DEFAULT_INTERVAL_P (i0) || DEFAULT_INTERVAL_P (i1))
    return 0;

  i1_len = XFASTINT (Flength (i1->plist));
  if (i1_len & 0x1)		/* Paranoia -- plists are always even */
    abort ();
  i1_len /= 2;
  i0_cdr = i0->plist;
  while (!NILP (i0_cdr))
    {
      /* Lengths of the two plists were unequal.  */
      if (i1_len == 0)
	return 0;

      i0_sym = Fcar (i0_cdr);
      i1_val = Fmemq (i0_sym, i1->plist);

      /* i0 has something i1 doesn't.  */
      if (EQ (i1_val, Qnil))
	return 0;

      /* i0 and i1 both have sym, but it has different values in each.  */
      i0_cdr = Fcdr (i0_cdr);
      if (! EQ (Fcar (Fcdr (i1_val)), Fcar (i0_cdr)))
	return 0;

      i0_cdr = Fcdr (i0_cdr);
      i1_len--;
    }

  /* Lengths of the two plists were unequal.  */
  if (i1_len > 0)
    return 0;

  return 1;
}

static int icount;
static int idepth;
static int zero_length;

/* Traverse an interval tree TREE, performing FUNCTION on each node.
   Pass FUNCTION two args: an interval, and ARG.  */

void
traverse_intervals (tree, position, depth, function, arg)
     INTERVAL tree;
     int position, depth;
     void (* function) P_ ((INTERVAL, Lisp_Object));
     Lisp_Object arg;
{
  if (NULL_INTERVAL_P (tree))
    return;

  traverse_intervals (tree->left, position, depth + 1, function, arg);
  position += LEFT_TOTAL_LENGTH (tree);
  tree->position = position;
  (*function) (tree, arg);
  position += LENGTH (tree);
  traverse_intervals (tree->right, position, depth + 1,  function, arg);
}

#if 0
/* These functions are temporary, for debugging purposes only.  */

INTERVAL search_interval, found_interval;

void
check_for_interval (i)
     register INTERVAL i;
{
  if (i == search_interval)
    {
      found_interval = i;
      icount++;
    }
}

INTERVAL
search_for_interval (i, tree)
     register INTERVAL i, tree;
{
  icount = 0;
  search_interval = i;
  found_interval = NULL_INTERVAL;
  traverse_intervals (tree, 1, 0, &check_for_interval, Qnil);
  return found_interval;
}

static void
inc_interval_count (i)
     INTERVAL i;
{
  icount++;
  if (LENGTH (i) == 0)
    zero_length++;
  if (depth > idepth)
    idepth = depth;
}

int
count_intervals (i)
     register INTERVAL i;
{
  icount = 0;
  idepth = 0;
  zero_length = 0;
  traverse_intervals (i, 1, 0, &inc_interval_count, Qnil);

  return icount;
}

static INTERVAL
root_interval (interval)
     INTERVAL interval;
{
  register INTERVAL i = interval;

  while (! ROOT_INTERVAL_P (i))
    i = i->parent;

  return i;
}
#endif

/* Assuming that a left child exists, perform the following operation:

     A		  B
    / \		 / \
   B       =>       A
  / \		   / \
     c		  c
*/

static INTERVAL
rotate_right (interval)
     INTERVAL interval;
{
  INTERVAL i;
  INTERVAL B = interval->left;
  int old_total = interval->total_length;

  /* Deal with any Parent of A;  make it point to B.  */
  if (! ROOT_INTERVAL_P (interval))
    if (AM_LEFT_CHILD (interval))
      interval->parent->left = B;
    else
      interval->parent->right = B;
  B->parent = interval->parent;

  /* Make B the parent of A */
  i = B->right;
  B->right = interval;
  interval->parent = B;

  /* Make A point to c */
  interval->left = i;
  if (! NULL_INTERVAL_P (i))
    i->parent = interval;

  /* A's total length is decreased by the length of B and its left child.  */
  interval->total_length -= B->total_length - LEFT_TOTAL_LENGTH (interval);

  /* B must have the same total length of A.  */
  B->total_length = old_total;

  return B;
}

/* Assuming that a right child exists, perform the following operation:

    A               B   
   / \	           / \  
      B	   =>     A
     / \         / \    
    c               c
*/

static INTERVAL
rotate_left (interval)
     INTERVAL interval;
{
  INTERVAL i;
  INTERVAL B = interval->right;
  int old_total = interval->total_length;

  /* Deal with any parent of A;  make it point to B.  */
  if (! ROOT_INTERVAL_P (interval))
    if (AM_LEFT_CHILD (interval))
      interval->parent->left = B;
    else
      interval->parent->right = B;
  B->parent = interval->parent;

  /* Make B the parent of A */
  i = B->left;
  B->left = interval;
  interval->parent = B;

  /* Make A point to c */
  interval->right = i;
  if (! NULL_INTERVAL_P (i))
    i->parent = interval;

  /* A's total length is decreased by the length of B and its right child.  */
  interval->total_length -= B->total_length - RIGHT_TOTAL_LENGTH (interval);

  /* B must have the same total length of A.  */
  B->total_length = old_total;

  return B;
}

/* Balance an interval tree with the assumption that the subtrees
   themselves are already balanced.  */

static INTERVAL
balance_an_interval (i)
     INTERVAL i;
{
  register int old_diff, new_diff;

  while (1)
    {
      old_diff = LEFT_TOTAL_LENGTH (i) - RIGHT_TOTAL_LENGTH (i);
      if (old_diff > 0)
	{
	  new_diff = i->total_length - i->left->total_length
	    + RIGHT_TOTAL_LENGTH (i->left) - LEFT_TOTAL_LENGTH (i->left);
	  if (abs (new_diff) >= old_diff)
	    break;
	  i = rotate_right (i);
	  balance_an_interval (i->right);
	}
      else if (old_diff < 0)
	{
	  new_diff = i->total_length - i->right->total_length
	    + LEFT_TOTAL_LENGTH (i->right) - RIGHT_TOTAL_LENGTH (i->right);
	  if (abs (new_diff) >= -old_diff)
	    break;
	  i = rotate_left (i);
	  balance_an_interval (i->left);
	}
      else
	break;
    }
  return i;
}

/* Balance INTERVAL, potentially stuffing it back into its parent
   Lisp Object.  */

static INLINE INTERVAL
balance_possible_root_interval (interval)
     register INTERVAL interval;
{
  Lisp_Object parent;

  if (interval->parent == NULL_INTERVAL)
    return interval;

  XSETFASTINT (parent, (EMACS_INT) interval->parent);
  interval = balance_an_interval (interval);

  if (BUFFERP (parent))
    BUF_INTERVALS (XBUFFER (parent)) = interval;
  else if (STRINGP (parent))
    XSTRING (parent)->intervals = interval;

  return interval;
}

/* Balance the interval tree TREE.  Balancing is by weight
   (the amount of text).  */

static INTERVAL
balance_intervals_internal (tree)
     register INTERVAL tree;
{
  /* Balance within each side.  */
  if (tree->left)
    balance_intervals_internal (tree->left);
  if (tree->right)
    balance_intervals_internal (tree->right);
  return balance_an_interval (tree);
}

/* Advertised interface to balance intervals.  */

INTERVAL
balance_intervals (tree)
     INTERVAL tree;
{
  if (tree == NULL_INTERVAL)
    return NULL_INTERVAL;

  return balance_intervals_internal (tree);
}

/* Split INTERVAL into two pieces, starting the second piece at
   character position OFFSET (counting from 0), relative to INTERVAL.
   INTERVAL becomes the left-hand piece, and the right-hand piece
   (second, lexicographically) is returned.

   The size and position fields of the two intervals are set based upon
   those of the original interval.  The property list of the new interval
   is reset, thus it is up to the caller to do the right thing with the
   result.

   Note that this does not change the position of INTERVAL;  if it is a root,
   it is still a root after this operation.  */

INTERVAL
split_interval_right (interval, offset)
     INTERVAL interval;
     int offset;
{
  INTERVAL new = make_interval ();
  int position = interval->position;
  int new_length = LENGTH (interval) - offset;

  new->position = position + offset;
  new->parent = interval;

  if (NULL_RIGHT_CHILD (interval))
    {
      interval->right = new;
      new->total_length = new_length;
    }
  else
    {
      /* Insert the new node between INTERVAL and its right child.  */
      new->right = interval->right;
      interval->right->parent = new;
      interval->right = new;
      new->total_length = new_length + new->right->total_length;
      balance_an_interval (new);
    }
  
  balance_possible_root_interval (interval);

  return new;
}

/* Split INTERVAL into two pieces, starting the second piece at
   character position OFFSET (counting from 0), relative to INTERVAL.
   INTERVAL becomes the right-hand piece, and the left-hand piece
   (first, lexicographically) is returned.

   The size and position fields of the two intervals are set based upon
   those of the original interval.  The property list of the new interval
   is reset, thus it is up to the caller to do the right thing with the
   result.

   Note that this does not change the position of INTERVAL;  if it is a root,
   it is still a root after this operation.  */

INTERVAL
split_interval_left (interval, offset)
     INTERVAL interval;
     int offset;
{
  INTERVAL new = make_interval ();
  int position = interval->position;
  int new_length = offset;

  new->position = interval->position;
  interval->position = interval->position + offset;
  new->parent = interval;

  if (NULL_LEFT_CHILD (interval))
    {
      interval->left = new;
      new->total_length = new_length;
    }
  else
    {
      /* Insert the new node between INTERVAL and its left child.  */
      new->left = interval->left;
      new->left->parent = new;
      interval->left = new;
      new->total_length = new_length + new->left->total_length;
      balance_an_interval (new);
    }
  
  balance_possible_root_interval (interval);

  return new;
}

/* Return the proper position for the first character
   described by the interval tree SOURCE.
   This is 1 if the parent is a buffer,
   0 if the parent is a string or if there is no parent.

   Don't use this function on an interval which is the child
   of another interval!  */

int
interval_start_pos (source)
     INTERVAL source;
{
  Lisp_Object parent;

  if (NULL_INTERVAL_P (source))
    return 0;

  XSETFASTINT (parent, (EMACS_INT) source->parent);
  if (BUFFERP (parent))
    return BUF_BEG (XBUFFER (parent));
  return 0;
}

/* Find the interval containing text position POSITION in the text
   represented by the interval tree TREE.  POSITION is a buffer
   position (starting from 1) or a string index (starting from 0).
   If POSITION is at the end of the buffer or string,
   return the interval containing the last character.

   The `position' field, which is a cache of an interval's position,
   is updated in the interval found.  Other functions (e.g., next_interval)
   will update this cache based on the result of find_interval.  */

INTERVAL
find_interval (tree, position)
     register INTERVAL tree;
     register int position;
{
  /* The distance from the left edge of the subtree at TREE
                    to POSITION.  */
  register int relative_position;
  Lisp_Object parent;

  if (NULL_INTERVAL_P (tree))
    return NULL_INTERVAL;

  XSETFASTINT (parent, (EMACS_INT) tree->parent);
  relative_position = position;
  if (BUFFERP (parent))
    relative_position -= BUF_BEG (XBUFFER (parent));

  if (relative_position > TOTAL_LENGTH (tree))
    abort ();			/* Paranoia */

  tree = balance_possible_root_interval (tree);

  while (1)
    {
      if (relative_position < LEFT_TOTAL_LENGTH (tree))
	{
	  tree = tree->left;
	}
      else if (! NULL_RIGHT_CHILD (tree)
	       && relative_position >= (TOTAL_LENGTH (tree)
					- RIGHT_TOTAL_LENGTH (tree)))
	{
	  relative_position -= (TOTAL_LENGTH (tree)
				- RIGHT_TOTAL_LENGTH (tree));
	  tree = tree->right;
	}
      else
	{
	  tree->position
	    = (position - relative_position /* the left edge of *tree */
	       + LEFT_TOTAL_LENGTH (tree)); /* the left edge of this interval */

	  return tree;
	}
    }
}

/* Find the succeeding interval (lexicographically) to INTERVAL.
   Sets the `position' field based on that of INTERVAL (see
   find_interval).  */

INTERVAL
next_interval (interval)
     register INTERVAL interval;
{
  register INTERVAL i = interval;
  register int next_position;

  if (NULL_INTERVAL_P (i))
    return NULL_INTERVAL;
  next_position = interval->position + LENGTH (interval);

  if (! NULL_RIGHT_CHILD (i))
    {
      i = i->right;
      while (! NULL_LEFT_CHILD (i))
	i = i->left;

      i->position = next_position;
      return i;
    }

  while (! NULL_PARENT (i))
    {
      if (AM_LEFT_CHILD (i))
	{
	  i = i->parent;
	  i->position = next_position;
	  return i;
	}

      i = i->parent;
    }

  return NULL_INTERVAL;
}

/* Find the preceding interval (lexicographically) to INTERVAL.
   Sets the `position' field based on that of INTERVAL (see
   find_interval).  */

INTERVAL
previous_interval (interval)
     register INTERVAL interval;
{
  register INTERVAL i;
  register int position_of_previous;

  if (NULL_INTERVAL_P (interval))
    return NULL_INTERVAL;

  if (! NULL_LEFT_CHILD (interval))
    {
      i = interval->left;
      while (! NULL_RIGHT_CHILD (i))
	i = i->right;

      i->position = interval->position - LENGTH (i);
      return i;
    }

  i = interval;
  while (! NULL_PARENT (i))
    {
      if (AM_RIGHT_CHILD (i))
	{
	  i = i->parent;

	  i->position = interval->position - LENGTH (i);
	  return i;
	}
      i = i->parent;
    }

  return NULL_INTERVAL;
}

/* Find the interval containing POS given some non-NULL INTERVAL
   in the same tree.  Note that we need to update interval->position
   if we go down the tree.  */
INTERVAL
update_interval (i, pos)
     register INTERVAL i;
     int pos;
{
  if (NULL_INTERVAL_P (i))
    return NULL_INTERVAL;

  while (1) 
    {
      if (pos < i->position) 
	{
	  /* Move left. */
	  if (pos >= i->position - TOTAL_LENGTH (i->left)) 
	    {
	      i->left->position = i->position - TOTAL_LENGTH (i->left)
		+ LEFT_TOTAL_LENGTH (i->left);
	      i = i->left;		/* Move to the left child */
	    }
	  else if (NULL_PARENT (i)) 
	    error ("Point before start of properties");
	  else  
	      i = i->parent;
	  continue;
	}
      else if (pos >= INTERVAL_LAST_POS (i))
	{
	  /* Move right. */
	  if (pos < INTERVAL_LAST_POS (i) + TOTAL_LENGTH (i->right)) 
	    {
	      i->right->position = INTERVAL_LAST_POS (i) +
		LEFT_TOTAL_LENGTH (i->right);
	      i = i->right;		/* Move to the right child */
	    }
	  else if (NULL_PARENT (i)) 
	    error ("Point after end of properties");
	  else 
	      i = i->parent;
	  continue;
	}
      else 
	return i;
    }
}


#if 0
/* Traverse a path down the interval tree TREE to the interval
   containing POSITION, adjusting all nodes on the path for
   an addition of LENGTH characters.  Insertion between two intervals
   (i.e., point == i->position, where i is second interval) means
   text goes into second interval.

   Modifications are needed to handle the hungry bits -- after simply
   finding the interval at position (don't add length going down),
   if it's the beginning of the interval, get the previous interval
   and check the hungry bits of both.  Then add the length going back up
   to the root.  */

static INTERVAL
adjust_intervals_for_insertion (tree, position, length)
     INTERVAL tree;
     int position, length;
{
  register int relative_position;
  register INTERVAL this;

  if (TOTAL_LENGTH (tree) == 0)	/* Paranoia */
    abort ();

  /* If inserting at point-max of a buffer, that position
     will be out of range */
  if (position > TOTAL_LENGTH (tree))
    position = TOTAL_LENGTH (tree);
  relative_position = position;
  this = tree;

  while (1)
    {
      if (relative_position <= LEFT_TOTAL_LENGTH (this))
	{
	  this->total_length += length;
	  this = this->left;
	}
      else if (relative_position > (TOTAL_LENGTH (this)
				    - RIGHT_TOTAL_LENGTH (this)))
	{
	  relative_position -= (TOTAL_LENGTH (this)
				- RIGHT_TOTAL_LENGTH (this));
	  this->total_length += length;
	  this = this->right;
	}
      else
	{
	  /* If we are to use zero-length intervals as buffer pointers,
	     then this code will have to change.  */
	  this->total_length += length;
	  this->position = LEFT_TOTAL_LENGTH (this)
	                   + position - relative_position + 1;
	  return tree;
	}
    }
}
#endif

/* Effect an adjustment corresponding to the addition of LENGTH characters
   of text.  Do this by finding the interval containing POSITION in the
   interval tree TREE, and then adjusting all of its ancestors by adding
   LENGTH to them.

   If POSITION is the first character of an interval, meaning that point
   is actually between the two intervals, make the new text belong to
   the interval which is "sticky".

   If both intervals are "sticky", then make them belong to the left-most
   interval.  Another possibility would be to create a new interval for
   this text, and make it have the merged properties of both ends.  */

static INTERVAL
adjust_intervals_for_insertion (tree, position, length)
     INTERVAL tree;
     int position, length;
{
  register INTERVAL i;
  register INTERVAL temp;
  int eobp = 0;
  Lisp_Object parent;
  int offset;
  
  if (TOTAL_LENGTH (tree) == 0)	/* Paranoia */
    abort ();

  XSETFASTINT (parent, (EMACS_INT) tree->parent);
  offset = (BUFFERP (parent) ? BUF_BEG (XBUFFER (parent)) : 0);

  /* If inserting at point-max of a buffer, that position will be out
     of range.  Remember that buffer positions are 1-based.  */
  if (position >= TOTAL_LENGTH (tree) + offset)
    {
      position = TOTAL_LENGTH (tree) + offset;
      eobp = 1;
    }

  i = find_interval (tree, position);

  /* If in middle of an interval which is not sticky either way,
     we must not just give its properties to the insertion.
     So split this interval at the insertion point.  */
  if (! (position == i->position || eobp)
      && END_NONSTICKY_P (i)
      && FRONT_NONSTICKY_P (i))
    {
      Lisp_Object tail;
      Lisp_Object front, rear;

      front = textget (i->plist, Qfront_sticky);
      rear  = textget (i->plist, Qrear_nonsticky);

      /* Does any actual property pose an actual problem?  */
      for (tail = i->plist; ! NILP (tail); tail = Fcdr (Fcdr (tail)))
	{
	  Lisp_Object prop;
	  prop = XCONS (tail)->car;

	  /* Is this particular property rear-sticky?
	     Note, if REAR isn't a cons, it must be non-nil,
	     which means that all properties are rear-nonsticky.  */
	  if (CONSP (rear) && NILP (Fmemq (prop, rear)))
	    continue;

	  /* Is this particular property front-sticky?
	     Note, if FRONT isn't a cons, it must be nil,
	     which means that all properties are front-nonsticky.  */
	  if (CONSP (front) && ! NILP (Fmemq (prop, front)))
	    continue;

	  /* PROP isn't sticky on either side => it is a real problem.  */
	  break;
	}

      /* If any property is a real problem, split the interval.  */
      if (! NILP (tail))
	{
	  temp = split_interval_right (i, position - i->position);
	  copy_properties (i, temp);
	  i = temp;
	}
    }

  /* If we are positioned between intervals, check the stickiness of
     both of them.  We have to do this too, if we are at BEG or Z.  */
  if (position == i->position || eobp)
    {
      register INTERVAL prev;

      if (position == BEG)
	prev = 0;
      else if (eobp)
	{
	  prev = i;
	  i = 0;
	}
      else
	prev = previous_interval (i);

      /* Even if we are positioned between intervals, we default
	 to the left one if it exists.  We extend it now and split
	 off a part later, if stickiness demands it.  */
      for (temp = prev ? prev : i;! NULL_INTERVAL_P (temp); temp = temp->parent)
	{
	  temp->total_length += length;
	  temp = balance_possible_root_interval (temp);
	}
      
      /* If at least one interval has sticky properties,
	 we check the stickiness property by property.  */
      if (END_NONSTICKY_P (prev) || FRONT_STICKY_P (i))
	{
	  Lisp_Object pleft, pright;
	  struct interval newi;

	  pleft = NULL_INTERVAL_P (prev) ? Qnil : prev->plist;
	  pright = NULL_INTERVAL_P (i) ? Qnil : i->plist;
	  newi.plist = merge_properties_sticky (pleft, pright);

	  if (! prev) /* i.e. position == BEG */
	    {
	      if (! intervals_equal (i, &newi))
		{
		  i = split_interval_left (i, length);
		  i->plist = newi.plist;
		}
	    }
	  else if (! intervals_equal (prev, &newi))
	    {
	      prev = split_interval_right (prev,
					   position - prev->position);
	      prev->plist = newi.plist;
	      if (! NULL_INTERVAL_P (i)
		  && intervals_equal (prev, i))
		merge_interval_right (prev);
	    }

	  /* We will need to update the cache here later.  */
	}
      else if (! prev && ! NILP (i->plist))
        {
	  /* Just split off a new interval at the left.
	     Since I wasn't front-sticky, the empty plist is ok.  */
	  i = split_interval_left (i, length);
        }
    }

  /* Otherwise just extend the interval.  */
  else
    {
      for (temp = i; ! NULL_INTERVAL_P (temp); temp = temp->parent)
	{
	  temp->total_length += length;
	  temp = balance_possible_root_interval (temp);
	}
    }
      
  return tree;
}

/* Any property might be front-sticky on the left, rear-sticky on the left,
   front-sticky on the right, or rear-sticky on the right; the 16 combinations
   can be arranged in a matrix with rows denoting the left conditions and
   columns denoting the right conditions:
      _  __  _
_     FR FR FR FR
FR__   0  1  2  3
 _FR   4  5  6  7
FR     8  9  A  B
  FR   C  D  E  F

   left-props  = '(front-sticky (p8 p9 pa pb pc pd pe pf)
		   rear-nonsticky (p4 p5 p6 p7 p8 p9 pa pb)
		   p0 L p1 L p2 L p3 L p4 L p5 L p6 L p7 L
		   p8 L p9 L pa L pb L pc L pd L pe L pf L)
   right-props = '(front-sticky (p2 p3 p6 p7 pa pb pe pf)
		   rear-nonsticky (p1 p2 p5 p6 p9 pa pd pe)
		   p0 R p1 R p2 R p3 R p4 R p5 R p6 R p7 R
		   p8 R p9 R pa R pb R pc R pd R pe R pf R)

   We inherit from whoever has a sticky side facing us.  If both sides
   do (cases 2, 3, E, and F), then we inherit from whichever side has a
   non-nil value for the current property.  If both sides do, then we take
   from the left.

   When we inherit a property, we get its stickiness as well as its value.
   So, when we merge the above two lists, we expect to get this:

   result      = '(front-sticky (p6 p7 pa pb pc pd pe pf)
		   rear-nonsticky (p6 pa)
		   p0 L p1 L p2 L p3 L p6 R p7 R
		   pa R pb R pc L pd L pe L pf L)

   The optimizable special cases are:
       left rear-nonsticky = nil, right front-sticky = nil (inherit left)
       left rear-nonsticky = t,   right front-sticky = t   (inherit right)
       left rear-nonsticky = t,   right front-sticky = nil (inherit none)
*/

Lisp_Object
merge_properties_sticky (pleft, pright)
     Lisp_Object pleft, pright;
{
  register Lisp_Object props, front, rear;
  Lisp_Object lfront, lrear, rfront, rrear;
  register Lisp_Object tail1, tail2, sym, lval, rval, cat;
  int use_left, use_right;
  int lpresent;

  props = Qnil;
  front = Qnil;
  rear  = Qnil;
  lfront = textget (pleft, Qfront_sticky);
  lrear  = textget (pleft, Qrear_nonsticky);
  rfront = textget (pright, Qfront_sticky);
  rrear  = textget (pright, Qrear_nonsticky);

  /* Go through each element of PRIGHT.  */
  for (tail1 = pright; ! NILP (tail1); tail1 = Fcdr (Fcdr (tail1)))
    {
      sym = Fcar (tail1);

      /* Sticky properties get special treatment.  */
      if (EQ (sym, Qrear_nonsticky) || EQ (sym, Qfront_sticky))
	continue;

      rval = Fcar (Fcdr (tail1));
      for (tail2 = pleft; ! NILP (tail2); tail2 = Fcdr (Fcdr (tail2)))
	if (EQ (sym, Fcar (tail2)))
	  break;

      /* Indicate whether the property is explicitly defined on the left.
	 (We know it is defined explicitly on the right
	 because otherwise we don't get here.)  */
      lpresent = ! NILP (tail2);
      lval = (NILP (tail2) ? Qnil : Fcar (Fcdr (tail2)));

      use_left = ! TMEM (sym, lrear) && lpresent;
      use_right = TMEM (sym, rfront);
      if (use_left && use_right)
	{
	  if (NILP (lval))
	    use_left = 0;
	  else if (NILP (rval))
	    use_right = 0;
	}
      if (use_left)
	{
	  /* We build props as (value sym ...) rather than (sym value ...)
	     because we plan to nreverse it when we're done.  */
	  props = Fcons (lval, Fcons (sym, props));
	  if (TMEM (sym, lfront))
	    front = Fcons (sym, front);
	  if (TMEM (sym, lrear))
	    rear = Fcons (sym, rear);
	}
      else if (use_right)
	{
	  props = Fcons (rval, Fcons (sym, props));
	  if (TMEM (sym, rfront))
	    front = Fcons (sym, front);
	  if (TMEM (sym, rrear))
	    rear = Fcons (sym, rear);
	}
    }

  /* Now go through each element of PLEFT.  */
  for (tail2 = pleft; ! NILP (tail2); tail2 = Fcdr (Fcdr (tail2)))
    {
      sym = Fcar (tail2);

      /* Sticky properties get special treatment.  */
      if (EQ (sym, Qrear_nonsticky) || EQ (sym, Qfront_sticky))
	continue;

      /* If sym is in PRIGHT, we've already considered it.  */
      for (tail1 = pright; ! NILP (tail1); tail1 = Fcdr (Fcdr (tail1)))
	if (EQ (sym, Fcar (tail1)))
	  break;
      if (! NILP (tail1))
	continue;

      lval = Fcar (Fcdr (tail2));

      /* Since rval is known to be nil in this loop, the test simplifies.  */
      if (! TMEM (sym, lrear))
	{
	  props = Fcons (lval, Fcons (sym, props));
	  if (TMEM (sym, lfront))
	    front = Fcons (sym, front);
	}
      else if (TMEM (sym, rfront))
	{
	  /* The value is nil, but we still inherit the stickiness
	     from the right.  */
	  front = Fcons (sym, front);
	  if (TMEM (sym, rrear))
	    rear = Fcons (sym, rear);
	}
    }
  props = Fnreverse (props);
  if (! NILP (rear))
    props = Fcons (Qrear_nonsticky, Fcons (Fnreverse (rear), props));

  cat = textget (props, Qcategory);
  if (! NILP (front)
      && 
      /* If we have inherited a front-stick category property that is t,
	 we don't need to set up a detailed one.  */
      ! (! NILP (cat) && SYMBOLP (cat)
	 && EQ (Fget (cat, Qfront_sticky), Qt)))
    props = Fcons (Qfront_sticky, Fcons (Fnreverse (front), props));
  return props;
}


/* Delete an node I from its interval tree by merging its subtrees
   into one subtree which is then returned.  Caller is responsible for
   storing the resulting subtree into its parent.  */

static INTERVAL
delete_node (i)
     register INTERVAL i;
{
  register INTERVAL migrate, this;
  register int migrate_amt;

  if (NULL_INTERVAL_P (i->left))
    return i->right;
  if (NULL_INTERVAL_P (i->right))
    return i->left;

  migrate = i->left;
  migrate_amt = i->left->total_length;
  this = i->right;
  this->total_length += migrate_amt;
  while (! NULL_INTERVAL_P (this->left))
    {
      this = this->left;
      this->total_length += migrate_amt;
    }
  this->left = migrate;
  migrate->parent = this;

  return i->right;
}

/* Delete interval I from its tree by calling `delete_node'
   and properly connecting the resultant subtree.

   I is presumed to be empty; that is, no adjustments are made
   for the length of I.  */

void
delete_interval (i)
     register INTERVAL i;
{
  register INTERVAL parent;
  int amt = LENGTH (i);

  if (amt > 0)			/* Only used on zero-length intervals now.  */
    abort ();

  if (ROOT_INTERVAL_P (i))
    {
      Lisp_Object owner;
      XSETFASTINT (owner, (EMACS_INT) i->parent);
      parent = delete_node (i);
      if (! NULL_INTERVAL_P (parent))
	parent->parent = (INTERVAL) XFASTINT (owner);

      if (BUFFERP (owner))
	BUF_INTERVALS (XBUFFER (owner)) = parent;
      else if (STRINGP (owner))
	XSTRING (owner)->intervals = parent;
      else
	abort ();

      return;
    }

  parent = i->parent;
  if (AM_LEFT_CHILD (i))
    {
      parent->left = delete_node (i);
      if (! NULL_INTERVAL_P (parent->left))
	parent->left->parent = parent;
    }
  else
    {
      parent->right = delete_node (i);
      if (! NULL_INTERVAL_P (parent->right))
	parent->right->parent = parent;
    }
}

/* Find the interval in TREE corresponding to the relative position
   FROM and delete as much as possible of AMOUNT from that interval.
   Return the amount actually deleted, and if the interval was
   zeroed-out, delete that interval node from the tree.

   Note that FROM is actually origin zero, aka relative to the
   leftmost edge of tree.  This is appropriate since we call ourselves
   recursively on subtrees.

   Do this by recursing down TREE to the interval in question, and
   deleting the appropriate amount of text.  */

static int
interval_deletion_adjustment (tree, from, amount)
     register INTERVAL tree;
     register int from, amount;
{
  register int relative_position = from;

  if (NULL_INTERVAL_P (tree))
    return 0;

  /* Left branch */
  if (relative_position < LEFT_TOTAL_LENGTH (tree))
    {
      int subtract = interval_deletion_adjustment (tree->left,
						   relative_position,
						   amount);
      tree->total_length -= subtract;
      return subtract;
    }
  /* Right branch */
  else if (relative_position >= (TOTAL_LENGTH (tree)
				 - RIGHT_TOTAL_LENGTH (tree)))
    {
      int subtract;

      relative_position -= (tree->total_length
			    - RIGHT_TOTAL_LENGTH (tree));
      subtract = interval_deletion_adjustment (tree->right,
					       relative_position,
					       amount);
      tree->total_length -= subtract;
      return subtract;
    }
  /* Here -- this node.  */
  else
    {
      /* How much can we delete from this interval?  */
      int my_amount = ((tree->total_length 
			- RIGHT_TOTAL_LENGTH (tree))
		       - relative_position);

      if (amount > my_amount)
	amount = my_amount;

      tree->total_length -= amount;
      if (LENGTH (tree) == 0)
	delete_interval (tree);
      
      return amount;
    }

  /* Never reach here.  */
}

/* Effect the adjustments necessary to the interval tree of BUFFER to
   correspond to the deletion of LENGTH characters from that buffer
   text.  The deletion is effected at position START (which is a
   buffer position, i.e. origin 1).  */

static void
adjust_intervals_for_deletion (buffer, start, length)
     struct buffer *buffer;
     int start, length;
{
  register int left_to_delete = length;
  register INTERVAL tree = BUF_INTERVALS (buffer);
  register int deleted;
  Lisp_Object parent;
  int offset;

  XSETFASTINT (parent, (EMACS_INT) tree->parent);
  offset = (BUFFERP (parent) ? BUF_BEG (XBUFFER (parent)) : 0);

  if (NULL_INTERVAL_P (tree))
    return;

  if (start > offset + TOTAL_LENGTH (tree)
      || start + length > offset + TOTAL_LENGTH (tree))
    abort ();

  if (length == TOTAL_LENGTH (tree))
    {
      BUF_INTERVALS (buffer) = NULL_INTERVAL;
      return;
    }

  if (ONLY_INTERVAL_P (tree))
    {
      tree->total_length -= length;
      return;
    }

  if (start > offset + TOTAL_LENGTH (tree))
    start = offset + TOTAL_LENGTH (tree);
  while (left_to_delete > 0)
    {
      left_to_delete -= interval_deletion_adjustment (tree, start - offset,
						      left_to_delete);
      tree = BUF_INTERVALS (buffer);
      if (left_to_delete == tree->total_length)
	{
	  BUF_INTERVALS (buffer) = NULL_INTERVAL;
	  return;
	}
    }
}

/* Make the adjustments necessary to the interval tree of BUFFER to
   represent an addition or deletion of LENGTH characters starting
   at position START.  Addition or deletion is indicated by the sign
   of LENGTH.  */

INLINE void
offset_intervals (buffer, start, length)
     struct buffer *buffer;
     int start, length;
{
  if (NULL_INTERVAL_P (BUF_INTERVALS (buffer)) || length == 0)
    return;

  if (length > 0)
    adjust_intervals_for_insertion (BUF_INTERVALS (buffer), start, length);
  else
    adjust_intervals_for_deletion (buffer, start, -length);
}

/* Merge interval I with its lexicographic successor. The resulting
   interval is returned, and has the properties of the original
   successor.  The properties of I are lost.  I is removed from the
   interval tree.

   IMPORTANT:
   The caller must verify that this is not the last (rightmost)
   interval.  */

INTERVAL
merge_interval_right (i)
     register INTERVAL i;
{
  register int absorb = LENGTH (i);
  register INTERVAL successor;

  /* Zero out this interval.  */
  i->total_length -= absorb;

  /* Find the succeeding interval.  */
  if (! NULL_RIGHT_CHILD (i))      /* It's below us.  Add absorb
				      as we descend.  */
    {
      successor = i->right;
      while (! NULL_LEFT_CHILD (successor))
	{
	  successor->total_length += absorb;
	  successor = successor->left;
	}

      successor->total_length += absorb;
      delete_interval (i);
      return successor;
    }

  successor = i;
  while (! NULL_PARENT (successor))	   /* It's above us.  Subtract as
					      we ascend.  */
    {
      if (AM_LEFT_CHILD (successor))
	{
	  successor = successor->parent;
	  delete_interval (i);
	  return successor;
	}

      successor = successor->parent;
      successor->total_length -= absorb;
    }

  /* This must be the rightmost or last interval and cannot
     be merged right.  The caller should have known.  */
  abort ();
}

/* Merge interval I with its lexicographic predecessor. The resulting
   interval is returned, and has the properties of the original predecessor.
   The properties of I are lost.  Interval node I is removed from the tree.

   IMPORTANT:
   The caller must verify that this is not the first (leftmost) interval.  */

INTERVAL
merge_interval_left (i)
     register INTERVAL i;
{
  register int absorb = LENGTH (i);
  register INTERVAL predecessor;

  /* Zero out this interval.  */
  i->total_length -= absorb;

  /* Find the preceding interval.  */
  if (! NULL_LEFT_CHILD (i))	/* It's below us. Go down,
				   adding ABSORB as we go.  */
    {
      predecessor = i->left;
      while (! NULL_RIGHT_CHILD (predecessor))
	{
	  predecessor->total_length += absorb;
	  predecessor = predecessor->right;
	}

      predecessor->total_length += absorb;
      delete_interval (i);
      return predecessor;
    }

  predecessor = i;
  while (! NULL_PARENT (predecessor))	/* It's above us.  Go up,
				   subtracting ABSORB.  */
    {
      if (AM_RIGHT_CHILD (predecessor))
	{
	  predecessor = predecessor->parent;
	  delete_interval (i);
	  return predecessor;
	}

      predecessor = predecessor->parent;
      predecessor->total_length -= absorb;
    }

  /* This must be the leftmost or first interval and cannot
     be merged left.  The caller should have known.  */
  abort ();
}

/* Make an exact copy of interval tree SOURCE which descends from
   PARENT.  This is done by recursing through SOURCE, copying
   the current interval and its properties, and then adjusting
   the pointers of the copy.  */

static INTERVAL
reproduce_tree (source, parent)
     INTERVAL source, parent;
{
  register INTERVAL t = make_interval ();

  bcopy (source, t, INTERVAL_SIZE);
  copy_properties (source, t);
  t->parent = parent;
  if (! NULL_LEFT_CHILD (source))
    t->left = reproduce_tree (source->left, t);
  if (! NULL_RIGHT_CHILD (source))
    t->right = reproduce_tree (source->right, t);

  return t;
}

#if 0
/* Nobody calls this.  Perhaps it's a vestige of an earlier design.  */

/* Make a new interval of length LENGTH starting at START in the
   group of intervals INTERVALS, which is actually an interval tree.
   Returns the new interval.

   Generate an error if the new positions would overlap an existing
   interval.  */

static INTERVAL
make_new_interval (intervals, start, length)
     INTERVAL intervals;
     int start, length;
{
  INTERVAL slot;

  slot = find_interval (intervals, start);
  if (start + length > slot->position + LENGTH (slot))
    error ("Interval would overlap");

  if (start == slot->position && length == LENGTH (slot))
    return slot;

  if (slot->position == start)
    {
      /* New right node.  */
      split_interval_right (slot, length);
      return slot;
    }

  if (slot->position + LENGTH (slot) == start + length)
    {
      /* New left node.  */
      split_interval_left (slot, LENGTH (slot) - length);
      return slot;
    }

  /* Convert interval SLOT into three intervals.  */
  split_interval_left (slot, start - slot->position);
  split_interval_right (slot, length);
  return slot;
}
#endif

/* Insert the intervals of SOURCE into BUFFER at POSITION.
   LENGTH is the length of the text in SOURCE.

   The `position' field of the SOURCE intervals is assumed to be
   consistent with its parent; therefore, SOURCE must be an
   interval tree made with copy_interval or must be the whole
   tree of a buffer or a string.

   This is used in insdel.c when inserting Lisp_Strings into the
   buffer.  The text corresponding to SOURCE is already in the buffer
   when this is called.  The intervals of new tree are a copy of those
   belonging to the string being inserted; intervals are never
   shared.

   If the inserted text had no intervals associated, and we don't
   want to inherit the surrounding text's properties, this function
   simply returns -- offset_intervals should handle placing the
   text in the correct interval, depending on the sticky bits.

   If the inserted text had properties (intervals), then there are two
   cases -- either insertion happened in the middle of some interval,
   or between two intervals.

   If the text goes into the middle of an interval, then new
   intervals are created in the middle with only the properties of
   the new text, *unless* the macro MERGE_INSERTIONS is true, in
   which case the new text has the union of its properties and those
   of the text into which it was inserted.

   If the text goes between two intervals, then if neither interval
   had its appropriate sticky property set (front_sticky, rear_sticky),
   the new text has only its properties.  If one of the sticky properties
   is set, then the new text "sticks" to that region and its properties
   depend on merging as above.  If both the preceding and succeeding
   intervals to the new text are "sticky", then the new text retains
   only its properties, as if neither sticky property were set.  Perhaps
   we should consider merging all three sets of properties onto the new
   text...  */

void
graft_intervals_into_buffer (source, position, length, buffer, inherit)
     INTERVAL source;
     int position, length;
     struct buffer *buffer;
     int inherit;
{
  register INTERVAL under, over, this, prev;
  register INTERVAL tree;
  int middle;

  tree = BUF_INTERVALS (buffer);

  /* If the new text has no properties, it becomes part of whatever
     interval it was inserted into.  */
  if (NULL_INTERVAL_P (source))
    {
      Lisp_Object buf;
      if (!inherit && ! NULL_INTERVAL_P (tree))
	{
	  int saved_inhibit_modification_hooks = inhibit_modification_hooks;
	  XSETBUFFER (buf, buffer);
	  inhibit_modification_hooks = 1;
	  Fset_text_properties (make_number (position),
				make_number (position + length),
				Qnil, buf);
	  inhibit_modification_hooks = saved_inhibit_modification_hooks;
	}
      if (! NULL_INTERVAL_P (BUF_INTERVALS (buffer)))
	BUF_INTERVALS (buffer) = balance_an_interval (BUF_INTERVALS (buffer));
      return;
    }

  if (NULL_INTERVAL_P (tree))
    {
      /* The inserted text constitutes the whole buffer, so
	 simply copy over the interval structure.  */
      if ((BUF_Z (buffer) - BUF_BEG (buffer)) == TOTAL_LENGTH (source))
	{
	  Lisp_Object buf;
	  XSETBUFFER (buf, buffer);
	  BUF_INTERVALS (buffer) = reproduce_tree (source, buf);
	  BUF_INTERVALS (buffer)->position = 1;

	  /* Explicitly free the old tree here?  */

	  return;
	}

      /* Create an interval tree in which to place a copy
	 of the intervals of the inserted string.  */
      {
	Lisp_Object buf;
	XSETBUFFER (buf, buffer);
	tree = create_root_interval (buf);
      }
    }
  else if (TOTAL_LENGTH (tree) == TOTAL_LENGTH (source))
    /* If the buffer contains only the new string, but
       there was already some interval tree there, then it may be
       some zero length intervals.  Eventually, do something clever
       about inserting properly.  For now, just waste the old intervals.  */
    {
      BUF_INTERVALS (buffer) = reproduce_tree (source, tree->parent);
      BUF_INTERVALS (buffer)->position = 1;
      /* Explicitly free the old tree here.  */

      return;
    }
  /* Paranoia -- the text has already been added, so this buffer
     should be of non-zero length.  */
  else if (TOTAL_LENGTH (tree) == 0)
    abort ();

  this = under = find_interval (tree, position);
  if (NULL_INTERVAL_P (under))	/* Paranoia */
    abort ();
  over = find_interval (source, interval_start_pos (source));

  /* Here for insertion in the middle of an interval.
     Split off an equivalent interval to the right,
     then don't bother with it any more.  */

  if (position > under->position)
    {
      INTERVAL end_unchanged
	= split_interval_left (this, position - under->position);
      copy_properties (under, end_unchanged);
      under->position = position;
      prev = 0;
      middle = 1;
    }
  else
    {
      prev = previous_interval (under);
      if (prev && !END_NONSTICKY_P (prev))
	prev = 0;
    }

  /* Insertion is now at beginning of UNDER.  */

  /* The inserted text "sticks" to the interval `under',
     which means it gets those properties.
     The properties of under are the result of
     adjust_intervals_for_insertion, so stickiness has
     already been taken care of.  */
     
  while (! NULL_INTERVAL_P (over))
    {
      if (LENGTH (over) < LENGTH (under))
	{
	  this = split_interval_left (under, LENGTH (over));
	  copy_properties (under, this);
	}
      else
	this = under;
      copy_properties (over, this);
      if (inherit)
	merge_properties (over, this);
      else
	copy_properties (over, this);
      over = next_interval (over);
    }

  if (! NULL_INTERVAL_P (BUF_INTERVALS (buffer)))
    BUF_INTERVALS (buffer) = balance_an_interval (BUF_INTERVALS (buffer));
  return;
}

/* Get the value of property PROP from PLIST,
   which is the plist of an interval.
   We check for direct properties, for categories with property PROP, 
   and for PROP appearing on the default-text-properties list.  */

Lisp_Object
textget (plist, prop)
     Lisp_Object plist;
     register Lisp_Object prop;
{
  register Lisp_Object tail, fallback;
  fallback = Qnil;

  for (tail = plist; !NILP (tail); tail = Fcdr (Fcdr (tail)))
    {
      register Lisp_Object tem;
      tem = Fcar (tail);
      if (EQ (prop, tem))
	return Fcar (Fcdr (tail));
      if (EQ (tem, Qcategory))
	{
	  tem = Fcar (Fcdr (tail));
	  if (SYMBOLP (tem))
	    fallback = Fget (tem, prop);
	}
    }

  if (! NILP (fallback))
    return fallback;
  if (CONSP (Vdefault_text_properties))
    return Fplist_get (Vdefault_text_properties, prop);
  return Qnil;
}


/* Set point "temporarily", without checking any text properties.  */

INLINE void
temp_set_point (buffer, charpos)
     struct buffer *buffer;
     int charpos;
{
  temp_set_point_both (buffer, charpos,
		       buf_charpos_to_bytepos (buffer, charpos));
}

/* Set point in BUFFER "temporarily" to CHARPOS, which corresponds to
   byte position BYTEPOS.  */

INLINE void
temp_set_point_both (buffer, charpos, bytepos)
     int charpos, bytepos;
     struct buffer *buffer;
{
  /* In a single-byte buffer, the two positions must be equal.  */
  if (BUF_ZV (buffer) == BUF_ZV_BYTE (buffer)
      && charpos != bytepos)
    abort ();

  if (charpos > bytepos)
    abort ();

  if (charpos > BUF_ZV (buffer) || charpos < BUF_BEGV (buffer))
    abort ();

  BUF_PT_BYTE (buffer) = bytepos;
  BUF_PT (buffer) = charpos;
}

/* Set point in BUFFER to CHARPOS.  If the target position is 
   before an intangible character, move to an ok place.  */

void
set_point (buffer, charpos)
     register struct buffer *buffer;
     register int charpos;
{
  set_point_both (buffer, charpos, buf_charpos_to_bytepos (buffer, charpos));
}

/* Set point in BUFFER to CHARPOS, which corresponds to byte
   position BYTEPOS.  If the target position is 
   before an intangible character, move to an ok place.  */

void
set_point_both (buffer, charpos, bytepos)
     register struct buffer *buffer;
     register int charpos, bytepos;
{
  register INTERVAL to, from, toprev, fromprev, target;
  int buffer_point;
  register Lisp_Object obj;
  int old_position = BUF_PT (buffer);
  int backwards = (charpos < old_position ? 1 : 0);
  int have_overlays;
  int original_position;

  buffer->point_before_scroll = Qnil;

  if (charpos == BUF_PT (buffer))
    return;

  /* In a single-byte buffer, the two positions must be equal.  */
  if (BUF_ZV (buffer) == BUF_ZV_BYTE (buffer)
      && charpos != bytepos)
    abort ();

  /* Check this now, before checking if the buffer has any intervals.
     That way, we can catch conditions which break this sanity check
     whether or not there are intervals in the buffer.  */
  if (charpos > BUF_ZV (buffer) || charpos < BUF_BEGV (buffer))
    abort ();

  have_overlays = (! NILP (buffer->overlays_before)
		   || ! NILP (buffer->overlays_after));

  /* If we have no text properties and overlays,
     then we can do it quickly.  */
  if (NULL_INTERVAL_P (BUF_INTERVALS (buffer)) && ! have_overlays)
    {
      temp_set_point_both (buffer, charpos, bytepos);
      return;
    }

  /* Set TO to the interval containing the char after CHARPOS,
     and TOPREV to the interval containing the char before CHARPOS.
     Either one may be null.  They may be equal.  */
  to = find_interval (BUF_INTERVALS (buffer), charpos);
  if (charpos == BUF_BEGV (buffer))
    toprev = 0;
  else if (to && to->position == charpos)
    toprev = previous_interval (to);
  else
    toprev = to;

  buffer_point = (BUF_PT (buffer) == BUF_ZV (buffer)
		  ? BUF_ZV (buffer) - 1
		  : BUF_PT (buffer));

  /* Set FROM to the interval containing the char after PT,
     and FROMPREV to the interval containing the char before PT.
     Either one may be null.  They may be equal.  */
  /* We could cache this and save time.  */
  from = find_interval (BUF_INTERVALS (buffer), buffer_point);
  if (buffer_point == BUF_BEGV (buffer))
    fromprev = 0;
  else if (from && from->position == BUF_PT (buffer))
    fromprev = previous_interval (from);
  else if (buffer_point != BUF_PT (buffer))
    fromprev = from, from = 0;
  else
    fromprev = from;

  /* Moving within an interval.  */
  if (to == from && toprev == fromprev && INTERVAL_VISIBLE_P (to)
      && ! have_overlays)
    {
      temp_set_point_both (buffer, charpos, bytepos);
      return;
    }

  original_position = charpos;

  /* If the new position is between two intangible characters
     with the same intangible property value,
     move forward or backward until a change in that property.  */
  if (NILP (Vinhibit_point_motion_hooks)
      && ((! NULL_INTERVAL_P (to) && ! NULL_INTERVAL_P (toprev))
	  || have_overlays)
      /* Intangibility never stops us from positioning at the beginning
	 or end of the buffer, so don't bother checking in that case.  */
      && charpos != BEGV && charpos != ZV)
    {
      Lisp_Object intangible_propval;
      Lisp_Object pos;

      XSETINT (pos, charpos);

      if (backwards)
	{
	  intangible_propval = Fget_char_property (make_number (charpos),
						   Qintangible, Qnil);

	  /* If following char is intangible,
	     skip back over all chars with matching intangible property.  */
	  if (! NILP (intangible_propval))
	    while (XINT (pos) > BUF_BEGV (buffer)
		   && EQ (Fget_char_property (make_number (XINT (pos) - 1),
					      Qintangible, Qnil),
			  intangible_propval))
	      pos = Fprevious_char_property_change (pos, Qnil);
	}
      else
	{
	  intangible_propval = Fget_char_property (make_number (charpos - 1),
						   Qintangible, Qnil);

	  /* If following char is intangible,
	     skip forward over all chars with matching intangible property.  */
	  if (! NILP (intangible_propval))
	    while (XINT (pos) < BUF_ZV (buffer)
		   && EQ (Fget_char_property (pos, Qintangible, Qnil),
			  intangible_propval))
	      pos = Fnext_char_property_change (pos, Qnil);

	}

      charpos = XINT (pos);
      bytepos = buf_charpos_to_bytepos (buffer, charpos);
    }

  if (charpos != original_position)
    {
      /* Set TO to the interval containing the char after CHARPOS,
	 and TOPREV to the interval containing the char before CHARPOS.
	 Either one may be null.  They may be equal.  */
      to = find_interval (BUF_INTERVALS (buffer), charpos);
      if (charpos == BUF_BEGV (buffer))
	toprev = 0;
      else if (to && to->position == charpos)
	toprev = previous_interval (to);
      else
	toprev = to;
    }

  /* Here TO is the interval after the stopping point
     and TOPREV is the interval before the stopping point.
     One or the other may be null.  */

  temp_set_point_both (buffer, charpos, bytepos);

  /* We run point-left and point-entered hooks here, iff the
     two intervals are not equivalent.  These hooks take
     (old_point, new_point) as arguments.  */
  if (NILP (Vinhibit_point_motion_hooks)
      && (! intervals_equal (from, to)
	  || ! intervals_equal (fromprev, toprev)))
    {
      Lisp_Object leave_after, leave_before, enter_after, enter_before;

      if (fromprev)
	leave_after = textget (fromprev->plist, Qpoint_left);
      else
	leave_after = Qnil;
      if (from)
	leave_before = textget (from->plist, Qpoint_left);
      else
	leave_before = Qnil;

      if (toprev)
	enter_after = textget (toprev->plist, Qpoint_entered);
      else
	enter_after = Qnil;
      if (to)
	enter_before = textget (to->plist, Qpoint_entered);
      else
	enter_before = Qnil;

      if (! EQ (leave_before, enter_before) && !NILP (leave_before))
	call2 (leave_before, make_number (old_position),
	       make_number (charpos));
      if (! EQ (leave_after, enter_after) && !NILP (leave_after))
	call2 (leave_after, make_number (old_position),
	       make_number (charpos));

      if (! EQ (enter_before, leave_before) && !NILP (enter_before))
	call2 (enter_before, make_number (old_position),
	       make_number (charpos));
      if (! EQ (enter_after, leave_after) && !NILP (enter_after))
	call2 (enter_after, make_number (old_position),
	       make_number (charpos));
    }
}

/* Move point to POSITION, unless POSITION is inside an intangible
   segment that reaches all the way to point.  */

void
move_if_not_intangible (position)
     int position;
{
  Lisp_Object pos;
  Lisp_Object intangible_propval;

  XSETINT (pos, position);

  if (! NILP (Vinhibit_point_motion_hooks))
    /* If intangible is inhibited, always move point to POSITION.  */
    ;
  else if (PT < position && XINT (pos) < ZV)
    {
      /* We want to move forward, so check the text before POSITION.  */

      intangible_propval = Fget_char_property (pos,
					       Qintangible, Qnil);

      /* If following char is intangible,
	 skip back over all chars with matching intangible property.  */
      if (! NILP (intangible_propval))
	while (XINT (pos) > BEGV
	       && EQ (Fget_char_property (make_number (XINT (pos) - 1),
					  Qintangible, Qnil),
		      intangible_propval))
	  pos = Fprevious_char_property_change (pos, Qnil);
    }
  else if (XINT (pos) > BEGV)
    {
      /* We want to move backward, so check the text after POSITION.  */

      intangible_propval = Fget_char_property (make_number (XINT (pos) - 1),
					       Qintangible, Qnil);

      /* If following char is intangible,
	 skip forward over all chars with matching intangible property.  */
      if (! NILP (intangible_propval))
	while (XINT (pos) < ZV
	       && EQ (Fget_char_property (pos, Qintangible, Qnil),
		      intangible_propval))
	  pos = Fnext_char_property_change (pos, Qnil);

    }

  /* If the whole stretch between PT and POSITION isn't intangible, 
     try moving to POSITION (which means we actually move farther
     if POSITION is inside of intangible text).  */

  if (XINT (pos) != PT)
    SET_PT (position);
}

/* Return the proper local map for position POSITION in BUFFER.
   Use the map specified by the local-map property, if any.
   Otherwise, use BUFFER's local map.  */

Lisp_Object
get_local_map (position, buffer)
     register int position;
     register struct buffer *buffer;
{
  Lisp_Object prop, tem, lispy_position, lispy_buffer;
  int old_begv, old_zv, old_begv_byte, old_zv_byte;

  /* Perhaps we should just change `position' to the limit.  */
  if (position > BUF_Z (buffer) || position < BUF_BEG (buffer))
    abort ();

  /* Ignore narrowing, so that a local map continues to be valid even if
     the visible region contains no characters and hence no properties.  */
  old_begv = BUF_BEGV (buffer);
  old_zv = BUF_ZV (buffer);
  old_begv_byte = BUF_BEGV_BYTE (buffer);
  old_zv_byte = BUF_ZV_BYTE (buffer);
  BUF_BEGV (buffer) = BUF_BEG (buffer);
  BUF_ZV (buffer) = BUF_Z (buffer);
  BUF_BEGV_BYTE (buffer) = BUF_BEG_BYTE (buffer);
  BUF_ZV_BYTE (buffer) = BUF_Z_BYTE (buffer);

  /* There are no properties at the end of the buffer, so in that case
     check for a local map on the last character of the buffer instead.  */
  if (position == BUF_Z (buffer) && BUF_Z (buffer) > BUF_BEG (buffer))
    --position;
  XSETFASTINT (lispy_position, position);
  XSETBUFFER (lispy_buffer, buffer);
  prop = Fget_char_property (lispy_position, Qlocal_map, lispy_buffer);

  BUF_BEGV (buffer) = old_begv;
  BUF_ZV (buffer) = old_zv;
  BUF_BEGV_BYTE (buffer) = old_begv_byte;
  BUF_ZV_BYTE (buffer) = old_zv_byte;

  /* Use the local map only if it is valid.  */
  /* Do allow symbols that are defined as keymaps.  */
  if (SYMBOLP (prop) && !NILP (prop))
    prop = Findirect_function (prop);
  if (!NILP (prop)
      && (tem = Fkeymapp (prop), !NILP (tem)))
    return prop;

  return buffer->keymap;
}

/* Produce an interval tree reflecting the intervals in
   TREE from START to START + LENGTH.
   The new interval tree has no parent and has a starting-position of 0.  */

INTERVAL
copy_intervals (tree, start, length)
     INTERVAL tree;
     int start, length;
{
  register INTERVAL i, new, t;
  register int got, prevlen;

  if (NULL_INTERVAL_P (tree) || length <= 0)
    return NULL_INTERVAL;

  i = find_interval (tree, start);
  if (NULL_INTERVAL_P (i) || LENGTH (i) == 0)
    abort ();

  /* If there is only one interval and it's the default, return nil.  */
  if ((start - i->position + 1 + length) < LENGTH (i)
      && DEFAULT_INTERVAL_P (i))
    return NULL_INTERVAL;

  new = make_interval ();
  new->position = 0;
  got = (LENGTH (i) - (start - i->position));
  new->total_length = length;
  copy_properties (i, new);

  t = new;
  prevlen = got;
  while (got < length)
    {
      i = next_interval (i);
      t = split_interval_right (t, prevlen);
      copy_properties (i, t);
      prevlen = LENGTH (i);
      got += prevlen;
    }

  return balance_an_interval (new);
}

/* Give STRING the properties of BUFFER from POSITION to LENGTH.  */

INLINE void
copy_intervals_to_string (string, buffer, position, length)
     Lisp_Object string;
     struct buffer *buffer;
     int position, length;
{
  INTERVAL interval_copy = copy_intervals (BUF_INTERVALS (buffer),
					   position, length);
  if (NULL_INTERVAL_P (interval_copy))
    return;

  interval_copy->parent = (INTERVAL) XFASTINT (string);
  XSTRING (string)->intervals = interval_copy;
}

/* Return 1 if strings S1 and S2 have identical properties; 0 otherwise.
   Assume they have identical characters.  */

int
compare_string_intervals (s1, s2)
     Lisp_Object s1, s2;
{
  INTERVAL i1, i2;
  int pos = 0;
  int end = XSTRING (s1)->size;

  i1 = find_interval (XSTRING (s1)->intervals, 0);
  i2 = find_interval (XSTRING (s2)->intervals, 0);

  while (pos < end)
    {
      /* Determine how far we can go before we reach the end of I1 or I2.  */
      int len1 = (i1 != 0 ? INTERVAL_LAST_POS (i1) : end) - pos;
      int len2 = (i2 != 0 ? INTERVAL_LAST_POS (i2) : end) - pos;
      int distance = min (len1, len2);

      /* If we ever find a mismatch between the strings,
	 they differ.  */
      if (! intervals_equal (i1, i2))
	return 0;

      /* Advance POS till the end of the shorter interval,
	 and advance one or both interval pointers for the new position.  */
      pos += distance;
      if (len1 == distance)
	i1 = next_interval (i1);
      if (len2 == distance)
	i2 = next_interval (i2);
    }
  return 1;
}

/* Recursively adjust interval I in the current buffer
   for setting enable_multibyte_characters to MULTI_FLAG.
   The range of interval I is START ... END in characters,
   START_BYTE ... END_BYTE in bytes.  */

static void
set_intervals_multibyte_1 (i, multi_flag, start, start_byte, end, end_byte)
     INTERVAL i;
     int multi_flag;
     int start, start_byte, end, end_byte;
{
  INTERVAL left, right;

  /* Fix the length of this interval.  */
  if (multi_flag)
    i->total_length = end - start;
  else
    i->total_length = end_byte - start_byte;

  /* Recursively fix the length of the subintervals.  */
  if (i->left)
    {
      int left_end, left_end_byte;

      if (multi_flag)
	{
	  left_end_byte = start_byte + LEFT_TOTAL_LENGTH (i);
	  left_end = BYTE_TO_CHAR (left_end_byte);
	}
      else
	{
	  left_end = start + LEFT_TOTAL_LENGTH (i);
	  left_end_byte = CHAR_TO_BYTE (left_end);
	}

      set_intervals_multibyte_1 (i->left, multi_flag, start, start_byte,
				 left_end, left_end_byte);
    }
  if (i->right)
    {
      int right_start_byte, right_start;

      if (multi_flag)
	{
	  right_start_byte = end_byte - RIGHT_TOTAL_LENGTH (i);
	  right_start = BYTE_TO_CHAR (right_start_byte);
	}
      else
	{
	  right_start = end - RIGHT_TOTAL_LENGTH (i);
	  right_start_byte = CHAR_TO_BYTE (right_start);
	}

      set_intervals_multibyte_1 (i->right, multi_flag,
				 right_start, right_start_byte,
				 end, end_byte);
    }
}

/* Update the intervals of the current buffer
   to fit the contents as multibyte (if MULTI_FLAG is 1)
   or to fit them as non-multibyte (if MULTI_FLAG is 0).  */

void
set_intervals_multibyte (multi_flag)
     int multi_flag;
{
  if (BUF_INTERVALS (current_buffer))
    set_intervals_multibyte_1 (BUF_INTERVALS (current_buffer), multi_flag,
			       BEG, BEG_BYTE, Z, Z_BYTE);
}

#endif /* USE_TEXT_PROPERTIES */
