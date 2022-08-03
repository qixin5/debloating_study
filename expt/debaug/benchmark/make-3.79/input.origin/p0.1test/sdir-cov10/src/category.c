/* GNU Emacs routines to deal with category tables.
   Copyright (C) 1995, 1997 Electrotechnical Laboratory, JAPAN.
   Licensed to the Free Software Foundation.

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


/* Here we handle three objects: category, category set, and category
   table.  Read comments in the file category.h to understand them.  */

#include <config.h>
#include <ctype.h>
#include "lisp.h"
#include "buffer.h"
#include "charset.h"
#include "category.h"

/* The version number of the latest category table.  Each category
   table has a unique version number.  It is assigned a new number
   also when it is modified.  When a regular expression is compiled
   into the struct re_pattern_buffer, the version number of the
   category table (of the current buffer) at that moment is also
   embedded in the structure.

   For the moment, we are not using this feature.  */
static int category_table_version;

Lisp_Object Qcategory_table, Qcategoryp, Qcategorysetp, Qcategory_table_p;

/* Variables to determine word boundary.  */
Lisp_Object Vword_combining_categories, Vword_separating_categories;

/* Temporary internal variable used in macro CHAR_HAS_CATEGORY.  */
Lisp_Object _temp_category_set;


/* Category set staff.  */

DEFUN ("make-category-set", Fmake_category_set, Smake_category_set, 1, 1, 0,
  "Return a newly created category-set which contains CATEGORIES.\n\
CATEGORIES is a string of category mnemonics.\n\
The value is a bool-vector which has t at the indices corresponding to\n\
those categories.")
  (categories)
     Lisp_Object categories;
{
  Lisp_Object val;
  int len;

  CHECK_STRING (categories, 0);
  val = MAKE_CATEGORY_SET;

  if (STRING_MULTIBYTE (categories))
    error ("Multibyte string in make-category-set");

  len = XSTRING (categories)->size;
  while (--len >= 0)
    {
      Lisp_Object category;

      XSETFASTINT (category, XSTRING (categories)->data[len]);
      CHECK_CATEGORY (category, 0);
      SET_CATEGORY_SET (val, category, Qt);
    }
  return val;
}


/* Category staff.  */

Lisp_Object check_category_table ();

DEFUN ("define-category", Fdefine_category, Sdefine_category, 2, 3, 0,
  "Define CHAR as a category which is described by DOCSTRING.\n\
CHAR should be an ASCII printing character in the range ` ' to `~'.\n\
DOCSTRING is a documentation string of the category.\n\
The category is defined only in category table TABLE, which defaults to\n\
 the current buffer's category table.")
  (category, docstring, table)
     Lisp_Object category, docstring, table;
{
  CHECK_CATEGORY (category, 0);
  CHECK_STRING (docstring, 1);
  table = check_category_table (table);

  if (!NILP (CATEGORY_DOCSTRING (table, XFASTINT (category))))
    error ("Category `%c' is already defined", XFASTINT (category));
  CATEGORY_DOCSTRING (table, XFASTINT (category)) = docstring;

  return Qnil;
}

DEFUN ("category-docstring", Fcategory_docstring, Scategory_docstring, 1, 2, 0,
  "Return the documentation string of CATEGORY, as defined in CATEGORY-TABLE.")
  (category, table)
     Lisp_Object category, table;
{
  Lisp_Object doc;

  CHECK_CATEGORY (category, 0);
  table = check_category_table (table);

  return CATEGORY_DOCSTRING (table, XFASTINT (category));
}

DEFUN ("get-unused-category", Fget_unused_category, Sget_unused_category,
       0, 1, 0,
  "Return a category which is not yet defined in CATEGORY-TABLE.\n\
If no category remains available, return nil.\n\
The optional argument CATEGORY-TABLE specifies which category table\n\
to modify; it defaults to the current buffer's category table.")
  (table)
     Lisp_Object table;
{
  int i;
  Lisp_Object docstring_vector;

  table = check_category_table (table);

  for (i = ' '; i <= '~'; i++)
    if (NILP (CATEGORY_DOCSTRING (table, i)))
      return make_number (i);

  return Qnil;
}


/* Category-table staff.  */

DEFUN ("category-table-p", Fcategory_table_p, Scategory_table_p, 1, 1, 0,
  "Return t if ARG is a category table.")
  (arg)
     Lisp_Object arg;
{
  if (CHAR_TABLE_P (arg)
      && EQ (XCHAR_TABLE (arg)->purpose, Qcategory_table))
    return Qt;
  return Qnil;
}

/* If TABLE is nil, return the current category table.  If TABLE is
   not nil, check the validity of TABLE as a category table.  If
   valid, return TABLE itself, but if not valid, signal an error of
   wrong-type-argument.  */

Lisp_Object
check_category_table (table)
     Lisp_Object table;
{
  register Lisp_Object tem;
  if (NILP (table))
    return current_buffer->category_table;
  while (tem = Fcategory_table_p (table), NILP (tem))
    table = wrong_type_argument (Qcategory_table_p, table);
  return table;
}   

DEFUN ("category-table", Fcategory_table, Scategory_table, 0, 0, 0,
  "Return the current category table.\n\
This is the one specified by the current buffer.")
  ()
{
  return current_buffer->category_table;
}

DEFUN ("standard-category-table", Fstandard_category_table,
   Sstandard_category_table, 0, 0, 0,
  "Return the standard category table.\n\
This is the one used for new buffers.")
  ()
{
  return Vstandard_category_table;
}

/* Return a copy of category table TABLE.  We can't simply use the
   function copy-sequence because no contents should be shared between
   the original and the copy.  This function is called recursively by
   binding TABLE to a sub char table.  */

Lisp_Object
copy_category_table (table)
     Lisp_Object table;
{
  Lisp_Object tmp;
  int i, to;

  if (!NILP (XCHAR_TABLE (table)->top))
    {
      /* TABLE is a top level char table.
	 At first, make a copy of tree structure of the table.  */
      table = Fcopy_sequence (table);

      /* Then, copy elements for single byte characters one by one.  */
      for (i = 0; i < CHAR_TABLE_SINGLE_BYTE_SLOTS; i++)
	if (!NILP (tmp = XCHAR_TABLE (table)->contents[i]))
	  XCHAR_TABLE (table)->contents[i] = Fcopy_sequence (tmp);
      to = CHAR_TABLE_ORDINARY_SLOTS;

      /* Also copy the first (and sole) extra slot.  It is a vector
         containing docstring of each category.  */
      Fset_char_table_extra_slot
	(table, make_number (0),
	 Fcopy_sequence (Fchar_table_extra_slot (table, make_number (0))));
    }
  else
    {
      i  = 32;
      to = SUB_CHAR_TABLE_ORDINARY_SLOTS;
    }

  /* If the table has non-nil default value, copy it.  */
  if (!NILP (tmp = XCHAR_TABLE (table)->defalt))
    XCHAR_TABLE (table)->defalt = Fcopy_sequence (tmp);

  /* At last, copy the remaining elements while paying attention to a
     sub char table.  */
  for (; i < to; i++)
    if (!NILP (tmp = XCHAR_TABLE (table)->contents[i]))
      XCHAR_TABLE (table)->contents[i]
	= (SUB_CHAR_TABLE_P (tmp)
	   ? copy_category_table (tmp) : Fcopy_sequence (tmp));

  return table;
}

DEFUN ("copy-category-table", Fcopy_category_table, Scopy_category_table,
       0, 1, 0,
  "Construct a new category table and return it.\n\
It is a copy of the TABLE, which defaults to the standard category table.")
  (table)
     Lisp_Object table;
{
  if (!NILP (table))
    check_category_table (table);
  else
    table = Vstandard_category_table;

  return copy_category_table (table);
}

DEFUN ("set-category-table", Fset_category_table, Sset_category_table, 1, 1, 0,
  "Specify TABLE as the category table for the current buffer.")
  (table)
     Lisp_Object table;
{
  table = check_category_table (table);
  current_buffer->category_table = table;
  /* Indicate that this buffer now has a specified category table.  */
  current_buffer->local_var_flags
    |= XFASTINT (buffer_local_flags.category_table);
  return table;
}


DEFUN ("char-category-set", Fchar_category_set, Schar_category_set, 1, 1, 0,
  "Return the category set of CHAR.")
  (ch)
     Lisp_Object ch;
{
  Lisp_Object val;
  int charset;
  unsigned char c1, c2;

  CHECK_NUMBER (ch, 0);
  return CATEGORY_SET (XFASTINT (ch));
}

DEFUN ("category-set-mnemonics", Fcategory_set_mnemonics,
       Scategory_set_mnemonics, 1, 1, 0,
  "Return a string containing mnemonics of the categories in CATEGORY-SET.\n\
CATEGORY-SET is a bool-vector, and the categories \"in\" it are those\n\
that are indexes where t occurs the bool-vector.\n\
The return value is a string containing those same categories.")
  (category_set)
     Lisp_Object category_set;
{
  int i, j;
  char str[96];

  CHECK_CATEGORY_SET (category_set, 0);

  j = 0;
  for (i = 32; i < 127; i++)
    if (CATEGORY_MEMBER (i, category_set))
      str[j++] = i;
  str[j] = '\0';

  return build_string (str);
}

/* Modify all category sets stored under sub char-table TABLE so that
   they contain (SET_VALUE is t) or don't contain (SET_VALUE is nil)
   CATEGORY.  */

void
modify_lower_category_set (table, category, set_value)
     Lisp_Object table, category, set_value;
{
  Lisp_Object val;
  int i;

  val = XCHAR_TABLE (table)->defalt;
  if (!CATEGORY_SET_P (val))
    val = MAKE_CATEGORY_SET;
  SET_CATEGORY_SET (val, category, set_value);
  XCHAR_TABLE (table)->defalt = val;

  for (i = 32; i < SUB_CHAR_TABLE_ORDINARY_SLOTS; i++)
    {
      val = XCHAR_TABLE (table)->contents[i];

      if (CATEGORY_SET_P (val))
	SET_CATEGORY_SET (val, category, set_value);
      else if (SUB_CHAR_TABLE_P (val))
	modify_lower_category_set (val, category, set_value);
    }
}

void
set_category_set (category_set, category, val)
     Lisp_Object category_set, category, val;
{
  do {
    int idx = XINT (category) / 8;
    unsigned char bits = 1 << (XINT (category) % 8);

    if (NILP (val))
      XCATEGORY_SET (category_set)->data[idx] &= ~bits;
    else
      XCATEGORY_SET (category_set)->data[idx] |= bits;
  } while (0);
}

DEFUN ("modify-category-entry", Fmodify_category_entry,
       Smodify_category_entry, 2, 4, 0,
  "Modify the category set of CHARACTER by adding CATEGORY to it.\n\
The category is changed only for table TABLE, which defaults to\n\
 the current buffer's category table.\n\
If optional fourth argument RESET is non-nil,\n\
 then delete CATEGORY from the category set instead of adding it.")
  (character, category, table, reset)
     Lisp_Object character, category, table, reset;
{
  int c, charset, c1, c2;
  Lisp_Object set_value;	/* Actual value to be set in category sets.  */
  Lisp_Object val, category_set;

  CHECK_NUMBER (character, 0);
  c = XINT (character);
  CHECK_CATEGORY (category, 1);
  table = check_category_table (table);

  if (NILP (CATEGORY_DOCSTRING (table, XFASTINT (category))))
    error ("Undefined category: %c", XFASTINT (category));
  
  set_value = NILP (reset) ? Qt : Qnil;

  if (c < CHAR_TABLE_SINGLE_BYTE_SLOTS)
    {
      val = XCHAR_TABLE (table)->contents[c];
      if (!CATEGORY_SET_P (val))
	XCHAR_TABLE (table)->contents[c] = (val = MAKE_CATEGORY_SET);
      SET_CATEGORY_SET (val, category, set_value);
      return Qnil;
    }

  SPLIT_NON_ASCII_CHAR (c, charset, c1, c2);

  /* The top level table.  */
  val = XCHAR_TABLE (table)->contents[charset + 128];
  if (CATEGORY_SET_P (val))
    category_set = val;
  else if (!SUB_CHAR_TABLE_P (val))
    {
      category_set = val = MAKE_CATEGORY_SET;
      XCHAR_TABLE (table)->contents[charset + 128] = category_set;
    }

  if (c1 <= 0)
    {
      /* Only a charset is specified.  */
      if (SUB_CHAR_TABLE_P (val))
	/* All characters in CHARSET should be the same as for having
           CATEGORY or not.  */
	modify_lower_category_set (val, category, set_value);
      else
	SET_CATEGORY_SET (category_set, category, set_value);
      return Qnil;
    }

  /* The second level table.  */
  if (!SUB_CHAR_TABLE_P (val))
    {
      val = make_sub_char_table (Qnil);
      XCHAR_TABLE (table)->contents[charset + 128] = val;
      /* We must set default category set of CHARSET in `defalt' slot.  */
      XCHAR_TABLE (val)->defalt = category_set;
    }
  table = val;

  val = XCHAR_TABLE (table)->contents[c1];
  if (CATEGORY_SET_P (val))
    category_set = val;
  else if (!SUB_CHAR_TABLE_P (val))
    {
      category_set = val = Fcopy_sequence (XCHAR_TABLE (table)->defalt);
      XCHAR_TABLE (table)->contents[c1] = category_set;
    }

  if (c2 <= 0)
    {
      if (SUB_CHAR_TABLE_P (val))
	/* All characters in C1 group of CHARSET should be the same as
           for CATEGORY.  */
	modify_lower_category_set (val, category, set_value);
      else
	SET_CATEGORY_SET (category_set, category, set_value);
      return Qnil;
    }

  /* The third (bottom) level table.  */
  if (!SUB_CHAR_TABLE_P (val))
    {
      val = make_sub_char_table (Qnil);
      XCHAR_TABLE (table)->contents[c1] = val;
      /* We must set default category set of CHARSET and C1 in
         `defalt' slot.  */
      XCHAR_TABLE (val)->defalt = category_set;
    }
  table = val;

  val = XCHAR_TABLE (table)->contents[c2];
  if (CATEGORY_SET_P (val))
    category_set = val;
  else if (!SUB_CHAR_TABLE_P (val))
    {
      category_set = Fcopy_sequence (XCHAR_TABLE (table)->defalt);
      XCHAR_TABLE (table)->contents[c2] = category_set;
    }
  else
    /* This should never happen.  */
    error ("Invalid category table");

  SET_CATEGORY_SET (category_set, category, set_value);

  return Qnil;
}

/* Dump category table to buffer in human-readable format */

static void
describe_category (value)
    Lisp_Object value;
{
  Lisp_Object mnemonics;

  Findent_to (make_number (16), make_number (1));

  if (NILP (value))
    {
      insert_string ("default\n");
      return;
    }

  if (CHAR_TABLE_P (value))
    {
      insert_string ("deeper char-table ...\n");
      return;
    }

  if (!CATEGORY_SET_P (value))
    {
      insert_string ("invalid\n");
      return;
    }

  mnemonics = Fcategory_set_mnemonics (value);
  insert_from_string (mnemonics, 0, 0, XSTRING (mnemonics)->size,
		      STRING_BYTES (XSTRING (mnemonics)), 0);
  insert_string ("\n");
  return;
}

static Lisp_Object
describe_category_1 (vector)
     Lisp_Object vector;
{
  struct buffer *old = current_buffer;
  set_buffer_internal (XBUFFER (Vstandard_output));
  describe_vector (vector, Qnil, describe_category, 0, Qnil, Qnil,
		   (int *)0, 0);
  {
    int i;
    Lisp_Object docs = XCHAR_TABLE (vector)->extras[0];
    Lisp_Object elt;

    if (!VECTORP (docs) || XVECTOR (docs)->size != 95)
      {
	insert_string ("Invalid first extra slot in this char table\n");
	return Qnil;
      }
      
    insert_string ("Meanings of mnemonice characters are:\n");
    for (i = 0; i < 95; i++)
      {
	elt = XVECTOR (docs)->contents[i];
	if (NILP (elt))
	  continue;

	insert_char (i + 32);
	insert (": ", 2);
	insert_from_string (elt, 0, 0, XSTRING (elt)->size,
			    STRING_BYTES (XSTRING (elt)), 0);
	insert ("\n", 1);
      }
  }

  while (! NILP (XCHAR_TABLE (vector)->parent))
    {
      vector = XCHAR_TABLE (vector)->parent;
      insert_string ("\nThe parent category table is:");
      describe_vector (vector, Qnil, describe_category, 0, Qnil, Qnil,
		       (int *) 0, 0);
    }

  call0 (intern ("help-mode"));
  set_buffer_internal (old);
  return Qnil;
}

DEFUN ("describe-categories", Fdescribe_categories, Sdescribe_categories, 0, 0, "",
  "Describe the category specifications in the current category table.\n\
The descriptions are inserted in a buffer, which is then displayed.")
  ()
{
  internal_with_output_to_temp_buffer
     ("*Help*", describe_category_1, current_buffer->category_table);

  return Qnil;
}

/* Return 1 if there is a word boundary between two word-constituent
   characters C1 and C2 if they appear in this order, else return 0.
   Use the macro WORD_BOUNDARY_P instead of calling this function
   directly.  */

int
word_boundary_p (c1, c2)
     int c1, c2;
{
  Lisp_Object category_set1, category_set2;
  Lisp_Object tail;
  int default_result;

  if (COMPOSITE_CHAR_P (c1))
    c1 = cmpchar_component (c1, 0, 1);
  if (COMPOSITE_CHAR_P (c2))
    c2 = cmpchar_component (c2, 0, 1);

  if (CHAR_CHARSET (c1) == CHAR_CHARSET (c2))
    {
      tail = Vword_separating_categories;
      default_result = 0;
    }
  else
    {
      tail = Vword_combining_categories;
      default_result = 1;
    }

  category_set1 = CATEGORY_SET (c1);
  if (NILP (category_set1))
    return default_result;
  category_set2 = CATEGORY_SET (c2);
  if (NILP (category_set2))
    return default_result;

  for (; CONSP (tail); tail = XCONS (tail)->cdr)
    {
      Lisp_Object elt = XCONS(tail)->car;

      if (CONSP (elt)
	  && CATEGORYP (XCONS (elt)->car)
	  && CATEGORYP (XCONS (elt)->cdr)
	  && CATEGORY_MEMBER (XFASTINT (XCONS (elt)->car), category_set1)
	  && CATEGORY_MEMBER (XFASTINT (XCONS (elt)->cdr), category_set2))
	return !default_result;
    }
  return default_result;
}


void
init_category_once ()
{
  /* This has to be done here, before we call Fmake_char_table.  */
  Qcategory_table = intern ("category-table");
  staticpro (&Qcategory_table);

  /* Intern this now in case it isn't already done.
     Setting this variable twice is harmless.
     But don't staticpro it here--that is done in alloc.c.  */
  Qchar_table_extra_slots = intern ("char-table-extra-slots");

  /* Now we are ready to set up this property, so we can
     create category tables.  */
  Fput (Qcategory_table, Qchar_table_extra_slots, make_number (2));

  Vstandard_category_table = Fmake_char_table (Qcategory_table, Qnil);
  /* Set a category set which contains nothing to the default.  */ 
  XCHAR_TABLE (Vstandard_category_table)->defalt = MAKE_CATEGORY_SET;
  Fset_char_table_extra_slot (Vstandard_category_table, make_number (0),
			      Fmake_vector (make_number (95), Qnil));
}

void
syms_of_category ()
{
  Qcategoryp = intern ("categoryp");
  staticpro (&Qcategoryp);
  Qcategorysetp = intern ("categorysetp");
  staticpro (&Qcategorysetp);
  Qcategory_table_p = intern ("category-table-p");
  staticpro (&Qcategory_table_p);

  DEFVAR_LISP ("word-combining-categories", &Vword_combining_categories,
    "List of pair (cons) of categories to determine word boundary.\n\
\n\
Emacs treats a sequence of word constituent characters as a single\n\
word (i.e. finds no word boundary between them) iff they belongs to\n\
the same charset.  But, exceptions are allowed in the following cases.\n\
\n\
\(1) The case that characters are in different charsets is controlled\n\
by the variable `word-combining-categories'.\n\
\n\
Emacs finds no word boundary between characters of different charsets\n\
if they have categories matching some element of this list.\n\
\n\
More precisely, if an element of this list is a cons of category CAT1\n\
and CAT2, and a multibyte character C1 which has CAT1 is followed by\n\
C2 which has CAT2, there's no word boundary between C1 and C2.\n\
\n\
For instance, to tell that ASCII characters and Latin-1 characters can\n\
form a single word, the element `(?l . ?l)' should be in this list\n\
because both characters have the category `l' (Latin characters).\n\
\n\
\(2) The case that character are in the same charset is controlled by\n\
the variable `word-separating-categories'.\n\
\n\
Emacs find a word boundary between characters of the same charset\n\
if they have categories matching some element of this list.\n\
\n\
More precisely, if an element of this list is a cons of category CAT1\n\
and CAT2, and a multibyte character C1 which has CAT1 is followed by\n\
C2 which has CAT2, there's a word boundary between C1 and C2.\n\
\n\
For instance, to tell that there's a word boundary between Japanese\n\
Hiragana and Japanese Kanji (both are in the same charset), the\n\
element `(?H . ?C) should be in this list.");

  Vword_combining_categories = Qnil;

  DEFVAR_LISP ("word-separating-categories", &Vword_separating_categories,
    "List of pair (cons) of categories to determine word boundary.\n\
See the documentation of the variable `word-combining-categories'.");

  Vword_separating_categories = Qnil;

  defsubr (&Smake_category_set);
  defsubr (&Sdefine_category);
  defsubr (&Scategory_docstring);
  defsubr (&Sget_unused_category);
  defsubr (&Scategory_table_p);
  defsubr (&Scategory_table);
  defsubr (&Sstandard_category_table);
  defsubr (&Scopy_category_table);
  defsubr (&Sset_category_table);
  defsubr (&Schar_category_set);
  defsubr (&Scategory_set_mnemonics);
  defsubr (&Smodify_category_entry);
  defsubr (&Sdescribe_categories);

  category_table_version = 0;
}
