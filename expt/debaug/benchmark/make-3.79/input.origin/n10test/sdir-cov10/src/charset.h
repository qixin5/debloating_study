/* Header for multilingual character handler.
   Copyright (C) 1995, 1997, 1998 Electrotechnical Laboratory, JAPAN.
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

#ifndef _CHARSET_H
#define _CHARSET_H

/*** GENERAL NOTE on CHARACTER SET (CHARSET) ***

  A character set ("charset" hereafter) is a meaningful collection
  (i.e. language, culture, functionality, etc) of characters.  Emacs
  handles multiple charsets at once.  Each charset corresponds to one
  of ISO charsets (except for a special charset for composition
  characters).  Emacs identifies a charset by a unique identification
  number, whereas ISO identifies a charset by a triplet of DIMENSION,
  CHARS and FINAL-CHAR.  So, hereafter, just saying "charset" means an
  identification number (integer value).

  The value range of charset is 0x00, 0x80..0xFE.  There are four
  kinds of charset depending on DIMENSION (1 or 2) and CHARS (94 or
  96).  For instance, a charset of DIMENSION2_CHARS94 contains 94x94


  Within Emacs Lisp, a charset is treated as a symbol which has a
  property `charset'.  The property value is a vector containing
  various information about the charset.  For readability of C codes,
  we use the following convention on C variable names:
	charset_symbol: Emacs Lisp symbol of a charset
	charset_id: Emacs Lisp integer of an identification number of a charset
	charset: C integer of an identification number of a charset

  Each charset (except for ASCII) is assigned a base leading-code
  (range 0x80..0x9D).  In addition, a charset of greater than 0xA0
  (whose base leading-code is 0x9A..0x9D) is assigned an extended
  leading-code (range 0xA0..0xFE).  In this case, each base
  leading-code specify the allowable range of extended leading-code as
  shown in the table below.  A leading-code is used to represent a
  character in Emacs' buffer and string.

  We call a charset which has extended leading-code as "private
  charset" because those are mainly for a charset which is not
  registered by ISO.  On the contrary, we call a charset which does
  not have extended leading-code as "official charset".

  ---------------------------------------------------------------------------
  charset	dimension	 base leading-code	extended leading-code
  ---------------------------------------------------------------------------
  0x00		official dim1    -- none --		-- none --
		(ASCII)
  0x01..0x7F	--never used--
  0x80		COMPOSITION	 same as charset	-- none --
  0x81..0x8F	official dim1    same as charset	-- none --
  0x90..0x99	official dim2	 same as charset	-- none --
  0x9A..0x9F	--never used--
  0xA0..0xDF	private dim1	    0x9A		same as charset
		of 1-column width
  0xE0..0xEF	private dim1	    0x9B		same as charset
		of 2-column width
  0xF0..0xF4	private dim2	    0x9C		same as charset
		of 1-column width
  0xF5..0xFE	private dim2	    0x9D		same as charset
		of 2-column width
  0xFF		--never used--
  ---------------------------------------------------------------------------

  In the table, "COMPOSITION" means a charset for a composite
  character which is a character composed from several (up to 16)
  non-composite characters (components).  Although a composite
  character can contain components of many charsets, a composite
  character itself belongs to the charset CHARSET-COMPOSITION.  See
  the document "GENERAL NOTE on COMPOSITE CHARACTER" below for more
  detail.

*/

/* Definition of special leading-codes.  */
/* Base leading-code.  */
/* Special leading-code followed by components of a composite character.  */
#define LEADING_CODE_COMPOSITION	0x80
/* Leading-code followed by extended leading-code.  */
#define LEADING_CODE_PRIVATE_11	0x9A /* for private DIMENSION1 of 1-column */
#define LEADING_CODE_PRIVATE_12	0x9B /* for private DIMENSION1 of 2-column */
#define LEADING_CODE_PRIVATE_21	0x9C /* for private DIMENSION2 of 1-column */
#define LEADING_CODE_PRIVATE_22	0x9D /* for private DIMENSION2 of 2-column */

/* Extended leading-code.  */
/* Start of each extended leading-codes.  */
#define LEADING_CODE_EXT_11 0xA0 /* follows LEADING_CODE_PRIVATE_11 */
#define LEADING_CODE_EXT_12 0xE0 /* follows LEADING_CODE_PRIVATE_12 */
#define LEADING_CODE_EXT_21 0xF0 /* follows LEADING_CODE_PRIVATE_21 */
#define LEADING_CODE_EXT_22 0xF5 /* follows LEADING_CODE_PRIVATE_22 */
/* Maximum value of extended leading-codes.  */
#define LEADING_CODE_EXT_MAX 0xFE

/* Definition of minimum/maximum charset of each DIMENSION.  */
#define MIN_CHARSET_OFFICIAL_DIMENSION1	0x81
#define MAX_CHARSET_OFFICIAL_DIMENSION1	0x8F
#define MIN_CHARSET_OFFICIAL_DIMENSION2	0x90
#define MAX_CHARSET_OFFICIAL_DIMENSION2 0x99
#define MIN_CHARSET_PRIVATE_DIMENSION1	LEADING_CODE_EXT_11
#define MIN_CHARSET_PRIVATE_DIMENSION2	LEADING_CODE_EXT_21

/* Maximum value of overall charset identification number.  */
#define MAX_CHARSET 0xFE

/* Definition of special charsets.  */
#define CHARSET_ASCII		0
#define CHARSET_COMPOSITION	0x80

extern int charset_ascii;	/* ASCII */
extern int charset_composition;	/* for a composite character */
extern int charset_latin_iso8859_1; /* ISO8859-1 (Latin-1) */
extern int charset_jisx0208_1978; /* JISX0208.1978 (Japanese Kanji old set) */
extern int charset_jisx0208;	/* JISX0208.1983 (Japanese Kanji) */
extern int charset_katakana_jisx0201; /* JISX0201.Kana (Japanese Katakana) */
extern int charset_latin_jisx0201; /* JISX0201.Roman (Japanese Roman) */
extern int charset_big5_1;	/* Big5 Level 1 (Chinese Traditional) */
extern int charset_big5_2;	/* Big5 Level 2 (Chinese Traditional) */

/* Check if CH is the head of multi-byte form, i.e.,
   an ASCII character or a base leading-code.  */
#define CHAR_HEAD_P(ch) ((unsigned char) (ch) < 0xA0)

/*** GENERAL NOTE on CHARACTER REPRESENTATION ***

  At first, the term "character" or "char" is used for a multilingual
  character (of course, including ASCII character), not for a byte in
  computer memory.  We use the term "code" or "byte" for the latter
  case.

  A character is identified by charset and one or two POSITION-CODEs.
  POSITION-CODE is the position of the character in the charset.  A
  character of DIMENSION1 charset has one POSITION-CODE: POSITION-CODE-1.
  A character of DIMENSION2 charset has two POSITION-CODE:
  POSITION-CODE-1 and POSITION-CODE-2.  The code range of
  POSITION-CODE is 0x20..0x7F.

  Emacs has two kinds of representation of a character: multi-byte
  form (for buffer and string) and single-word form (for character
  object in Emacs Lisp).  The latter is called "character code" here
  after.  Both representations encode the information of charset and
  POSITION-CODE but in a different way (for instance, MSB of
  POSITION-CODE is set in multi-byte form).

  For details of multi-byte form, see the section "2. Emacs internal
  format handlers" of `coding.c'.

  Emacs uses 19 bits for a character code.  The bits are divided into
  3 fields: FIELD1(5bits):FIELD2(7bits):FIELD3(7bits).

  A character code of DIMENSION1 character uses FIELD2 to hold charset
  and FIELD3 to hold POSITION-CODE-1.  A character code of DIMENSION2
  character uses FIELD1 to hold charset, FIELD2 and FIELD3 to hold
  POSITION-CODE-1 and POSITION-CODE-2 respectively.

  More precisely...

  FIELD2 of DIMENSION1 character (except for ASCII) is "charset - 0x70".
  This is to make all character codes except for ASCII greater than
  256 (ASCII's FIELD2 is 0).  So, the range of FIELD2 of DIMENSION1
  character is 0 or 0x11..0x7F.

  FIELD1 of DIMENSION2 character is "charset - 0x8F" for official
  charset and "charset - 0xE0" for private charset.  So, the range of
  FIELD1 of DIMENSION2 character is 0x01..0x1E.

  -----------------------------------------------------------------------
  charset	FIELD1 (5-bit)	    FIELD2 (7-bit)	FIELD3 (7-bit)
  -----------------------------------------------------------------------
  ASCII		0		    0			POSITION-CODE-1
  DIMENSION1	0		    charset - 0x70	POSITION-CODE-1
  DIMENSION2(o)	charset - 0x8F	    POSITION-CODE-1	POSITION-CODE-2
  DIMENSION2(p)	charset - 0xE0	    POSITION-CODE-1	POSITION-CODE-2
  -----------------------------------------------------------------------
  "(o)": official, "(p)": private
  -----------------------------------------------------------------------

*/

/*** GENERAL NOTE on COMPOSITE CHARACTER ***

  A composite character is a character composed from several (up to
  16) non-composite characters (components).  Although each component
  can belong to any charset, a composite character itself belongs to
  the charset `charset-composition' and is assigned a special
  leading-code `LEADING_CODE_COMPOSITION' for multi-byte form.  See
  the document "2. Emacs internal format handlers" in `coding.c' for
  more detail about multi-byte form.

  A character code of composite character has special format.  In the
  above document, FIELD1 of a composite character is 0x1F.  Each
  composite character is assigned a sequential number CMPCHAR-ID.
  FIELD2 and FIELD3 are combined to make 14bits field for holding
  CMPCHAR-ID, which means that Emacs can handle at most 2^14 (= 16384)
  composite characters at once.

  -----------------------------------------------------------------------
  charset		FIELD1 (5-bit)	    FIELD2&3 (14-bit)
  -----------------------------------------------------------------------
  CHARSET-COMPOSITION	0x1F		    CMPCHAR-ID
  -----------------------------------------------------------------------  

  Emacs assigns CMPCHAR-ID to a composite character only when it
  requires the character code of the composite character (e.g. while
  displaying the composite character).

*/

/* Masks of each field of character code.  */
#define CHAR_FIELD1_MASK (0x1F << 14)
#define CHAR_FIELD2_MASK (0x7F << 7)
#define CHAR_FIELD3_MASK 0x7F

/* Macros to access each field of character C.  */
#define CHAR_FIELD1(c) (((c) & CHAR_FIELD1_MASK) >> 14)
#define CHAR_FIELD2(c) (((c) & CHAR_FIELD2_MASK) >> 7)
#define CHAR_FIELD3(c) ((c) & CHAR_FIELD3_MASK)

/* Minimum character code of character of each DIMENSION.  */
#define MIN_CHAR_OFFICIAL_DIMENSION1 \
  ((MIN_CHARSET_OFFICIAL_DIMENSION1 - 0x70) << 7)
#define MIN_CHAR_PRIVATE_DIMENSION1 \
  ((MIN_CHARSET_PRIVATE_DIMENSION1 - 0x70) << 7)
#define MIN_CHAR_OFFICIAL_DIMENSION2 \
  ((MIN_CHARSET_OFFICIAL_DIMENSION2 - 0x8F) << 14)
#define MIN_CHAR_PRIVATE_DIMENSION2 \
  ((MIN_CHARSET_PRIVATE_DIMENSION2 - 0xE0) << 14)
#define MIN_CHAR_COMPOSITION \
  (0x1F << 14)
#define MAX_CHAR_COMPOSITION (GLYPH_MASK_CHAR - 1)

/* A generic character for composition characters.  */
#define GENERIC_COMPOSITION_CHAR (GLYPH_MASK_CHAR)

/* 1 if C is an ASCII character, else 0.  */
#define SINGLE_BYTE_CHAR_P(c) ((c) >= 0 && (c) < 0x100)
/* 1 if C is an composite character, else 0.  */
#define COMPOSITE_CHAR_P(c) ((c) >= MIN_CHAR_COMPOSITION)

/* 1 if BYTE is a character in itself, in multibyte mode.  */
#define ASCII_BYTE_P(byte) ((byte) < 0x80)

/* A char-table containing information of each character set.

   Unlike ordinary char-tables, this doesn't contain any nested table.
   Only the top level elements are used.  Each element is a vector of
   the following information:
	CHARSET-ID, BYTES, DIMENSION, CHARS, WIDTH, DIRECTION,
	LEADING-CODE-BASE, LEADING-CODE-EXT,
	ISO-FINAL-CHAR, ISO-GRAPHIC-PLANE,
	REVERSE-CHARSET, SHORT-NAME, LONG-NAME,	DESCRIPTION,
	PLIST.

   CHARSET-ID (integer) is the identification number of the charset.

   BYTES (integer) is the length of multi-byte form of a character in
   the charset: one of 1, 2, 3, and 4.

   DIMENSION (integer) is the number of bytes to represent a character: 1 or 2.

   CHARS (integer) is the number of characters in a dimension: 94 or 96.

   WIDTH (integer) is the number of columns a character in the charset
   occupies on the screen: one of 0, 1, and 2.

   DIRECTION (integer) is the rendering direction of characters in the
   charset when rendering.  If 0, render from left to right, else
   render from right to left.

   LEADING-CODE-BASE (integer) is the base leading-code for the
   charset.

   LEADING-CODE-EXT (integer) is the extended leading-code for the
   charset.  All charsets of less than 0xA0 has the value 0.

   ISO-FINAL-CHAR (character) is the final character of the
   corresponding ISO 2022 charset.

   ISO-GRAPHIC-PLANE (integer) is the graphic plane to be invoked
   while encoding to variants of ISO 2022 coding system, one of the
   following: 0/graphic-plane-left(GL), 1/graphic-plane-right(GR).

   REVERSE-CHARSET (integer) is the charset which differs only in
   LEFT-TO-RIGHT value from the charset.  If there's no such a
   charset, the value is -1.
   
   SHORT-NAME (string) is the short name to refer to the charset.

   LONG-NAME (string) is the long name to refer to the charset.

   DESCRIPTION (string) is the description string of the charset.

   PLIST (property list) may contain any type of information a user
   want to put and get by functions `put-charset-property' and
   `get-charset-property' respectively.  */
extern Lisp_Object Vcharset_table;

/* Macros to access various information of CHARSET in Vcharset_table.
   We provide these macros for efficiency.  No range check of CHARSET.  */

/* Return entry of CHARSET (lisp integer) in Vcharset_table.  */
#define CHARSET_TABLE_ENTRY(charset)					\
  XCHAR_TABLE (Vcharset_table)->contents[((charset) == CHARSET_ASCII	\
					  ? 0 : (charset) + 128)]

/* Return information INFO-IDX of CHARSET.  */
#define CHARSET_TABLE_INFO(charset, info_idx) \
  XVECTOR (CHARSET_TABLE_ENTRY (charset))->contents[info_idx]

#define CHARSET_ID_IDX (0)
#define CHARSET_BYTES_IDX (1)
#define CHARSET_DIMENSION_IDX (2)
#define CHARSET_CHARS_IDX (3)
#define CHARSET_WIDTH_IDX (4)
#define CHARSET_DIRECTION_IDX (5)
#define CHARSET_LEADING_CODE_BASE_IDX (6)
#define CHARSET_LEADING_CODE_EXT_IDX (7)
#define CHARSET_ISO_FINAL_CHAR_IDX (8)
#define CHARSET_ISO_GRAPHIC_PLANE_IDX (9)
#define CHARSET_REVERSE_CHARSET_IDX (10)
#define CHARSET_SHORT_NAME_IDX (11)
#define CHARSET_LONG_NAME_IDX (12)
#define CHARSET_DESCRIPTION_IDX (13)
#define CHARSET_PLIST_IDX (14)
/* Size of a vector of each entry of Vcharset_table.  */
#define CHARSET_MAX_IDX (15)

/* And several more macros to be used frequently.  */
#define CHARSET_BYTES(charset) \
  XFASTINT (CHARSET_TABLE_INFO (charset, CHARSET_BYTES_IDX))
#define CHARSET_DIMENSION(charset) \
  XFASTINT (CHARSET_TABLE_INFO (charset, CHARSET_DIMENSION_IDX))
#define CHARSET_CHARS(charset) \
  XFASTINT (CHARSET_TABLE_INFO (charset, CHARSET_CHARS_IDX))
#define CHARSET_WIDTH(charset) \
  XFASTINT (CHARSET_TABLE_INFO (charset, CHARSET_WIDTH_IDX))
#define CHARSET_DIRECTION(charset) \
  XFASTINT (CHARSET_TABLE_INFO (charset, CHARSET_DIRECTION_IDX))
#define CHARSET_LEADING_CODE_BASE(charset) \
  XFASTINT (CHARSET_TABLE_INFO (charset, CHARSET_LEADING_CODE_BASE_IDX))
#define CHARSET_LEADING_CODE_EXT(charset) \
  XFASTINT (CHARSET_TABLE_INFO (charset, CHARSET_LEADING_CODE_EXT_IDX))
#define CHARSET_ISO_FINAL_CHAR(charset) \
  XFASTINT (CHARSET_TABLE_INFO (charset, CHARSET_ISO_FINAL_CHAR_IDX))
#define CHARSET_ISO_GRAPHIC_PLANE(charset) \
  XFASTINT (CHARSET_TABLE_INFO (charset, CHARSET_ISO_GRAPHIC_PLANE_IDX))
#define CHARSET_REVERSE_CHARSET(charset) \
  XINT (CHARSET_TABLE_INFO (charset, CHARSET_REVERSE_CHARSET_IDX))

/* Macros to specify direction of a charset.  */
#define CHARSET_DIRECTION_LEFT_TO_RIGHT 0
#define CHARSET_DIRECTION_RIGHT_TO_LEFT 1

/* A vector of charset symbol indexed by charset-id.  This is used
   only for returning charset symbol from C functions.  */
extern Lisp_Object Vcharset_symbol_table;

/* Return symbol of CHARSET.  */
#define CHARSET_SYMBOL(charset) \
  XVECTOR (Vcharset_symbol_table)->contents[charset]

/* 1 if CHARSET is valid, else 0.  */
#define CHARSET_VALID_P(charset)					 \
  ((charset) == 0							 \
   || ((charset) >= 0x80 && (charset) <= MAX_CHARSET_OFFICIAL_DIMENSION2) \
   || ((charset) >= MIN_CHARSET_PRIVATE_DIMENSION1 && (charset) <= MAX_CHARSET))

/* 1 if CHARSET is already defined, else 0.  */
#define CHARSET_DEFINED_P(charset)			\
  (((charset) >= 0) && ((charset) <= MAX_CHARSET)	\
   && !NILP (CHARSET_TABLE_ENTRY (charset)))

/* Since the information CHARSET-BYTES and CHARSET-WIDTH of
   Vcharset_table can be retrieved only from the first byte of
   multi-byte form (an ASCII code or a base leading-code), we provide
   here tables to be used by macros BYTES_BY_CHAR_HEAD and
   WIDTH_BY_CHAR_HEAD for faster information retrieval.  */
extern int bytes_by_char_head[256];
extern int width_by_char_head[256];

#define BYTES_BY_CHAR_HEAD(char_head) bytes_by_char_head[char_head]
#define WIDTH_BY_CHAR_HEAD(char_head) width_by_char_head[char_head]

/* Charset of the character C.  */
#define CHAR_CHARSET(c)			 	\
  (SINGLE_BYTE_CHAR_P (c)		 	\
   ? CHARSET_ASCII			 	\
   : ((c) < MIN_CHAR_OFFICIAL_DIMENSION2 	\
      ? CHAR_FIELD2 (c) + 0x70		 	\
      : ((c) < MIN_CHAR_PRIVATE_DIMENSION2	\
	 ? CHAR_FIELD1 (c) + 0x8F	 	\
	 : ((c) < MIN_CHAR_COMPOSITION	 	\
	    ? CHAR_FIELD1 (c) + 0xE0	 	\
	    : ((c) <= MAX_CHAR_COMPOSITION	\
	       ? CHARSET_COMPOSITION		\
	       : CHARSET_ASCII)))))

/* Return charset at the place pointed by P.  */
#define CHARSET_AT(p)			   	\
  (*(p) < 0x80				   	\
   ? CHARSET_ASCII			   	\
   : (*(p) == LEADING_CODE_COMPOSITION	   	\
      ? CHARSET_COMPOSITION		   	\
      : (*(p) < LEADING_CODE_PRIVATE_11	   	\
	 ? (int)*(p)			   	\
	 : (*(p) <= LEADING_CODE_PRIVATE_22	\
	    ? (int)*((p) + 1)		   	\
	    : -1))))

/* Same as `CHARSET_AT ()' but perhaps runs faster because of an
   additional argument C which is the code (byte) at P.  */
#define FIRST_CHARSET_AT(p, c)		  	\
  ((c) < 0x80				  	\
   ? CHARSET_ASCII			  	\
   : ((c) == LEADING_CODE_COMPOSITION	  	\
      ? CHARSET_COMPOSITION		  	\
      : ((c) < LEADING_CODE_PRIVATE_11	  	\
	 ? (int)(c)			  	\
	 : ((c) <= LEADING_CODE_PRIVATE_22	\
	    ? (int)*((p) + 1)		  	\
	    : -1))))

/* Check if two characters C1 and C2 belong to the same charset.
   Always return 0 for composite characters.  */
#define SAME_CHARSET_P(c1, c2)				     	\
  (c1 < MIN_CHAR_COMPOSITION				     	\
   && (SINGLE_BYTE_CHAR_P (c1)				     	\
       ? SINGLE_BYTE_CHAR_P (c2)			     	\
       : (c1 < MIN_CHAR_OFFICIAL_DIMENSION2		     	\
	  ? (c1 & CHAR_FIELD2_MASK) == (c2 & CHAR_FIELD2_MASK)  \
	  : (c1 & CHAR_FIELD1_MASK) == (c2 & CHAR_FIELD1_MASK))))

/* Return a non-ASCII character of which charset is CHARSET and
   position-codes are C1 and C2.  DIMENSION1 character ignores C2.  */
#define MAKE_NON_ASCII_CHAR(charset, c1, c2)				\
  ((charset) == CHARSET_COMPOSITION					\
   ? MAKE_COMPOSITE_CHAR (((c1) << 7) + (c2))				\
   : (! CHARSET_DEFINED_P (charset) || CHARSET_DIMENSION (charset) == 1	\
      ? (((charset) - 0x70) << 7) | (c1)				\
      : ((charset) < MIN_CHARSET_PRIVATE_DIMENSION2			\
	 ? (((charset) - 0x8F) << 14) | ((c1) << 7) | (c2)		\
	 : (((charset) - 0xE0) << 14) | ((c1) << 7) | (c2))))

/* Return a composite character of which CMPCHAR-ID is ID.  */
#define MAKE_COMPOSITE_CHAR(id) (MIN_CHAR_COMPOSITION + (id))

/* Return CMPCHAR-ID of a composite character C.  */
#define COMPOSITE_CHAR_ID(c) ((c) - MIN_CHAR_COMPOSITION)

/* Return a character of which charset is CHARSET and position-codes
   are C1 and C2.  DIMENSION1 character ignores C2.  */
#define MAKE_CHAR(charset, c1, c2)		 	\
  ((charset) == CHARSET_ASCII			 	\
   ? (c1)					 	\
   : MAKE_NON_ASCII_CHAR ((charset), (c1) & 0x7F, (c2) & 0x7F))

/* If GENERICP is nonzero, return nonzero iff C is a valid normal or
   generic character.  If GENERICP is zero, return nonzero iff C is a
   valid normal character.  */
#define CHAR_VALID_P(c, genericp)	\
  ((c) >= 0				\
   && (SINGLE_BYTE_CHAR_P (c) || char_valid_p (c, genericp)))

/* This default value is used when nonascii-translation-table or
   nonascii-insert-offset fail to convert unibyte character to a valid
   multibyte character.  This makes a Latin-1 character.  */

#define DEFAULT_NONASCII_INSERT_OFFSET 0x800

/* Check if the character C is valid as a multibyte character.  */

#define VALID_MULTIBYTE_CHAR_P(c)					  \
  ((c) < MIN_CHAR_OFFICIAL_DIMENSION2					  \
   ? (!NILP (XCHAR_TABLE (Vcharset_table)->contents[CHAR_FIELD2 (c)	  \
						   + 0xF0])		  \
      && CHAR_FIELD3 (c) >= 32)						  \
   : ((c) < MIN_CHAR_PRIVATE_DIMENSION2					  \
      ? (!NILP (XCHAR_TABLE (Vcharset_table)->contents[CHAR_FIELD1 (c)	  \
						      + 0x10F])		  \
	 && CHAR_FIELD2 (c) >= 32 && CHAR_FIELD3 (c) >= 32)		  \
      : ((c) < MIN_CHAR_COMPOSITION					  \
	 ? (!NILP (XCHAR_TABLE (Vcharset_table)->contents[CHAR_FIELD1 (c) \
							 + 0x160])	  \
	    && CHAR_FIELD2 (c) >= 32 && CHAR_FIELD3 (c) >= 32)		  \
	 : (c) < MIN_CHAR_COMPOSITION + n_cmpchars)))

/* The charset of non-ASCII character C is stored in CHARSET, and the
   position-codes of C are stored in C1 and C2.
   We store -1 in C2 if the character is just 2 bytes.

   Do not use this macro for an ASCII character.  */

#define SPLIT_NON_ASCII_CHAR(c, charset, c1, c2)			 \
  ((c) & CHAR_FIELD1_MASK						 \
   ? (charset = ((c) < MIN_CHAR_COMPOSITION				 \
		 ? (CHAR_FIELD1 (c)					 \
		    + ((c) < MIN_CHAR_PRIVATE_DIMENSION2 ? 0x8F : 0xE0)) \
		 : CHARSET_COMPOSITION),				 \
      c1 = CHAR_FIELD2 (c),						 \
      c2 = CHAR_FIELD3 (c))						 \
   : (charset = CHAR_FIELD2 (c) + 0x70,					 \
      c1 = CHAR_FIELD3 (c),						 \
      c2 = -1))

/* The charset of character C is stored in CHARSET, and the
   position-codes of C are stored in C1 and C2.
   We store -1 in C2 if the character is just 2 bytes.  */

#define SPLIT_CHAR(c, charset, c1, c2)		 	\
  (SINGLE_BYTE_CHAR_P (c)			 	\
   ? charset = CHARSET_ASCII, c1 = (c), c2 = -1	 	\
   : SPLIT_NON_ASCII_CHAR (c, charset, c1, c2))

/* The charset of the character at STR is stored in CHARSET, and the
   position-codes are stored in C1 and C2.
   We store -1 in C2 if the character is just 2 bytes.

   If the character is a composite character, the upper 7-bit and
   lower 7-bit of CMPCHAR-ID are set in C1 and C2 respectively.  No
   range checking.  */

#define SPLIT_STRING(str, len, charset, c1, c2)			      	\
  ((BYTES_BY_CHAR_HEAD ((unsigned char) *(str)) < 2		      	\
    || BYTES_BY_CHAR_HEAD ((unsigned char) *(str)) > len	      	\
    || split_non_ascii_string (str, len, &charset, &c1, &c2) < 0)	\
   ? c1 = *(str), charset = CHARSET_ASCII			      	\
   : charset)

/* Mapping table from ISO2022's charset (specified by DIMENSION,
   CHARS, and FINAL_CHAR) to Emacs' charset.  Should be accessed by
   macro ISO_CHARSET_TABLE (DIMENSION, CHARS, FINAL_CHAR).  */
extern int iso_charset_table[2][2][128];

#define ISO_CHARSET_TABLE(dimension, chars, final_char) \
  iso_charset_table[XINT (dimension) - 1][XINT (chars) > 94][XINT (final_char)]

#define BASE_LEADING_CODE_P(c) (BYTES_BY_CHAR_HEAD ((unsigned char) (c)) > 1)

/* Return how many bytes C will occupy in a multibyte buffer.  */
#define CHAR_BYTES(c) \
  ((SINGLE_BYTE_CHAR_P ((c)) || ((c) & ~GLYPH_MASK_CHAR)) ? 1 : char_bytes (c))

/* The following two macros CHAR_STRING and STRING_CHAR are the main
   entry points to convert between Emacs two types of character
   representations: multi-byte form and single-word form (character
   code).  */

/* Set STR a pointer to the multi-byte form of the character C.  If C
   is not a composite character, the multi-byte form is set in WORKBUF
   and STR points WORKBUF.  The caller should allocate at least 4-byte
   area at WORKBUF in advance.  Returns the length of the multi-byte
   form.  If C is an invalid character code, signal an error.  */

#define CHAR_STRING(c, workbuf, str)		 	\
  (SINGLE_BYTE_CHAR_P (c)			 	\
   ? *(str = workbuf) = (unsigned char)(c), 1	 	\
   : non_ascii_char_to_string (c, workbuf, (unsigned char **)&str))

/* Return a character code of the character of which multi-byte form
   is at STR and the length is LEN.  If STR doesn't contain valid
   multi-byte form, only the first byte in STR is returned.  */

#define STRING_CHAR(str, len)				\
  (BYTES_BY_CHAR_HEAD ((unsigned char) *(str)) == 1	\
   ? (unsigned char) *(str)				\
   : string_to_non_ascii_char (str, len, 0, 0))

/* This is like STRING_CHAR but the third arg ACTUAL_LEN is set to
   the length of the multi-byte form.  Just to know the length, use
   MULTIBYTE_FORM_LENGTH.  */

#define STRING_CHAR_AND_LENGTH(str, len, actual_len)	    	\
  (BYTES_BY_CHAR_HEAD ((unsigned char) *(str)) == 1		\
   ? (actual_len = 1), (unsigned char) *(str)		    	\
   : string_to_non_ascii_char (str, len, &actual_len, 0))

/* This is like STRING_CHAR_AND_LENGTH but the third arg ACTUAL_LEN
   does not include garbage bytes following the multibyte character.  */
#define STRING_CHAR_AND_CHAR_LENGTH(str, len, actual_len)    	\
  (BYTES_BY_CHAR_HEAD ((unsigned char) *(str)) == 1		\
   ? (actual_len = 1), (unsigned char) *(str)		    	\
   : string_to_non_ascii_char (str, len, &actual_len, 1))

/* Fetch the "next" multibyte character from Lisp string STRING
   at byte position BYTEIDX, character position CHARIDX.
   Store it into OUTPUT.

   All the args must be side-effect-free.
   BYTEIDX and CHARIDX must be lvalues;
   we increment them past the character fetched.  */

#define FETCH_STRING_CHAR_ADVANCE(OUTPUT, STRING, CHARIDX, BYTEIDX)	      \
if (1)									      \
  {									      \
    unsigned char *fetch_string_char_ptr = &XSTRING (STRING)->data[BYTEIDX];  \
    int fetch_string_char_space_left = XSTRING (STRING)->size_byte - BYTEIDX; \
    int actual_len;							      \
    									      \
    OUTPUT								      \
      = STRING_CHAR_AND_LENGTH (fetch_string_char_ptr,			      \
			        fetch_string_char_space_left, actual_len);    \
									      \
    BYTEIDX += actual_len;						      \
    CHARIDX++;								      \
  }									      \
else

/* Return the length of the multi-byte form at string STR of length LEN.  */

#define MULTIBYTE_FORM_LENGTH(str, len)			\
  (BYTES_BY_CHAR_HEAD (*(unsigned char *)(str)) == 1	\
   ? 1							\
   : multibyte_form_length (str, len))

/* Set C a (possibly multibyte) character at P.  P points into a
   string which is the virtual concatenation of STR1 (which ends at
   END1) or STR2 (which ends at END2).  */

#define GET_CHAR_AFTER_2(c, p, str1, end1, str2, end2)			    \
  do {									    \
    const char *dtemp = (p) == (end1) ? (str2) : (p);			    \
    const char *dlimit = ((p) >= (str1) && (p) < (end1)) ? (end1) : (end2); \
    c = STRING_CHAR (dtemp, dlimit - dtemp);				    \
  } while (0)

/* Set C a (possibly multibyte) character before P.  P points into a
   string which is the virtual concatenation of STR1 (which ends at
   END1) or STR2 (which ends at END2).  */

#define GET_CHAR_BEFORE_2(c, p, str1, end1, str2, end2)			    \
  do {									    \
    const char *dtemp = (p);						    \
    const char *dlimit = ((p) > (str2) && (p) <= (end2)) ? (str2) : (str1); \
    while (dtemp-- > dlimit && (unsigned char) *dtemp >= 0xA0);		    \
    c = STRING_CHAR (dtemp, p - dtemp);					    \
  } while (0)

#ifdef emacs

/* Increase the buffer point POS of the current buffer to the next
   character boundary.  This macro relies on the fact that *GPT_ADDR
   and *Z_ADDR are always accessible and the values are '\0'.  No
   range checking of POS.  */
#define INC_POS(pos)				\
  do {						\
    unsigned char *p = BYTE_POS_ADDR (pos);	\
    pos++;					\
    if (BASE_LEADING_CODE_P (*p++))		\
      while (!CHAR_HEAD_P (*p)) p++, pos++;	\
  } while (0)

/* Decrease the buffer point POS of the current buffer to the previous
   character boundary.  No range checking of POS.  */
#define DEC_POS(pos)						\
  do {								\
    unsigned char *p, *p_min;					\
    								\
    pos--;							\
    if (pos < GPT_BYTE)						\
      p = BEG_ADDR + pos - 1, p_min = BEG_ADDR;			\
    else							\
      p = BEG_ADDR + GAP_SIZE + pos - 1, p_min = GAP_END_ADDR;	\
    if (p > p_min && !CHAR_HEAD_P (*p))				\
      {								\
	int pos_saved = pos--;					\
	p--;							\
	while (p > p_min && !CHAR_HEAD_P (*p)) p--, pos--;	\
	if (!BASE_LEADING_CODE_P (*p)) pos = pos_saved;		\
      }								\
  } while (0)

/* Increment both CHARPOS and BYTEPOS, each in the appropriate way.  */

#define INC_BOTH(charpos, bytepos)				\
do								\
  {								\
    (charpos)++;						\
    if (NILP (current_buffer->enable_multibyte_characters))	\
      (bytepos)++;						\
    else							\
      INC_POS ((bytepos));					\
  }								\
while (0)

/* Decrement both CHARPOS and BYTEPOS, each in the appropriate way.  */

#define DEC_BOTH(charpos, bytepos)				\
do								\
  {								\
    (charpos)--;						\
    if (NILP (current_buffer->enable_multibyte_characters))	\
      (bytepos)--;						\
    else							\
      DEC_POS ((bytepos));					\
  }								\
while (0)

/* Increase the buffer point POS of the current buffer to the next
   character boundary.  This macro relies on the fact that *GPT_ADDR
   and *Z_ADDR are always accessible and the values are '\0'.  No
   range checking of POS.  */
#define BUF_INC_POS(buf, pos)				\
  do {							\
    unsigned char *p = BUF_BYTE_ADDRESS (buf, pos);	\
    pos++;						\
    if (BASE_LEADING_CODE_P (*p++))			\
      while (!CHAR_HEAD_P (*p)) p++, pos++;		\
  } while (0)

/* Decrease the buffer point POS of the current buffer to the previous
   character boundary.  No range checking of POS.  */
#define BUF_DEC_POS(buf, pos)				      	\
  do {							      	\
    unsigned char *p, *p_min;				      	\
    int pos_saved = --pos;				      	\
    if (pos < BUF_GPT_BYTE (buf))			      	\
      {								\
	p = BUF_BEG_ADDR (buf) + pos - 1;			\
	p_min = BUF_BEG_ADDR (buf);				\
      }								\
    else						      	\
      {								\
	p = BUF_BEG_ADDR (buf) + BUF_GAP_SIZE (buf) + pos - 1;	\
	p_min = BUF_GAP_END_ADDR (buf);				\
      }								\
    if (p > p_min && !CHAR_HEAD_P (*p))				\
      {								\
	int pos_saved = pos--;					\
	p--;							\
	while (p > p_min && !CHAR_HEAD_P (*p)) p--, pos--;	\
	if (!BASE_LEADING_CODE_P (*p)) pos = pos_saved;		\
      }								\
  } while (0)

#endif /* emacs */

/* Maximum counts of components in one composite character.  */
#define MAX_COMPONENT_COUNT 16

/* Structure to hold information of a composite character.  */
struct cmpchar_info {
  /* Byte length of the composite character.  */
  int len;

  /* Multi-byte form of the composite character.  */
  unsigned char *data;

  /* Length of glyph codes.  */
  int glyph_len;

  /* Width of the overall glyph of the composite character.  */
  int width;

  /* Pointer to an array of glyph codes of the composite character.
     This actually contains only character code, no face.  */
  GLYPH *glyph;

  /* Pointer to an array of composition rules.  The value has the form:
	(0xA0 + ((GLOBAL-REF-POINT << 2) | NEW-REF-POINT))
     where each XXX-REF-POINT is 0..8.  */
  unsigned char *cmp_rule;

  /* Pointer to an array of x-axis offset of left edge of glyphs
     relative to the left of of glyph[0] except for the first element
     which is the absolute offset from the left edge of overall glyph.
     The actual pixel offset should be calculated by multiplying each
     frame's one column width by this value:
	(i.e. FONT_WIDTH (f->output_data.x->font) * col_offset[N]).  */
  float *col_offset;

  /* Work slot used by `dumpglyphs' (xterm.c).  */
  int face_work;
};

/* Table of pointers to the structure `cmpchar_info' indexed by
   CMPCHAR-ID.  */
extern struct cmpchar_info **cmpchar_table;
/* Number of the current composite characters.  */
extern int n_cmpchars;

/* This is the maximum length of multi-byte form.  */
#define MAX_LENGTH_OF_MULTI_BYTE_FORM (MAX_COMPONENT_COUNT * 6)

/* Maximum character code currently used.  */
#define MAX_CHAR (MIN_CHAR_COMPOSITION + n_cmpchars)

extern void invalid_character P_ ((int));

extern int translate_char P_ ((Lisp_Object, int, int, int, int));
extern int split_non_ascii_string P_ ((const unsigned char *, int, int *,
				       unsigned char *, unsigned char *));
extern int string_to_non_ascii_char P_ ((const unsigned char *, int, int *,
					 int));
extern int non_ascii_char_to_string P_ ((int, unsigned char *, unsigned char **));
extern int multibyte_form_length P_ ((const unsigned char *, int));
extern int str_cmpchar_id P_ ((const unsigned char *, int, int));
extern void register_composite_chars_region P_ ((int, int, int, int));
extern void register_composite_chars_string P_ ((Lisp_Object));
extern int get_charset_id P_ ((Lisp_Object));
extern int cmpchar_component P_ ((int, int, int));
extern int find_charset_in_str P_ ((unsigned char *, int, int *,
				    Lisp_Object, int, int));
extern int strwidth P_ ((unsigned char *, int));
extern int char_bytes P_ ((int));
extern int char_valid_p P_ ((int, int));

extern Lisp_Object Vtranslation_table_vector;

/* Return a translation table of id number ID.  */
#define GET_TRANSLATION_TABLE(id) \
  (XCONS(XVECTOR(Vtranslation_table_vector)->contents[(id)])->cdr)

/* A char-table for characters which may invoke auto-filling.  */
extern Lisp_Object Vauto_fill_chars;

/* Copy LEN bytes from FROM to TO.  This macro should be used only
   when a caller knows that LEN is short and the obvious copy loop is
   faster than calling bcopy which has some overhead.  */

#define BCOPY_SHORT(from, to, len)		\
  do {						\
    int i = len;				\
    unsigned char *from_p = from, *to_p = to;	\
    while (i--) *from_p++ = *to_p++;		\
  } while (0)

#endif /* _CHARSET_H */
