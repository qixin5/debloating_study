/* Coding system handler (conversion, detection, and etc).
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

/*** TABLE OF CONTENTS ***

  1. Preamble
  2. Emacs' internal format (emacs-mule) handlers
  3. ISO2022 handlers
  4. Shift-JIS and BIG5 handlers
  5. CCL handlers
  6. End-of-line handlers
  7. C library functions
  8. Emacs Lisp library functions
  9. Post-amble

*/

/*** GENERAL NOTE on CODING SYSTEM ***

  Coding system is an encoding mechanism of one or more character
  sets.  Here's a list of coding systems which Emacs can handle.  When
  we say "decode", it means converting some other coding system to
  Emacs' internal format (emacs-internal), and when we say "encode",
  it means converting the coding system emacs-mule to some other
  coding system.

  0. Emacs' internal format (emacs-mule)

  Emacs itself holds a multi-lingual character in a buffer and a string
  in a special format.  Details are described in section 2.

  1. ISO2022

  The most famous coding system for multiple character sets.  X's
  Compound Text, various EUCs (Extended Unix Code), and coding
  systems used in Internet communication such as ISO-2022-JP are
  all variants of ISO2022.  Details are described in section 3.

  2. SJIS (or Shift-JIS or MS-Kanji-Code)
   
  A coding system to encode character sets: ASCII, JISX0201, and
  JISX0208.  Widely used for PC's in Japan.  Details are described in
  section 4.

  3. BIG5

  A coding system to encode character sets: ASCII and Big5.  Widely
  used by Chinese (mainly in Taiwan and Hong Kong).  Details are
  described in section 4.  In this file, when we write "BIG5"
  (all uppercase), we mean the coding system, and when we write
  "Big5" (capitalized), we mean the character set.

  4. Raw text

  A coding system for a text containing random 8-bit code.  Emacs does
  no code conversion on such a text except for end-of-line format.

  5. Other

  If a user wants to read/write a text encoded in a coding system not
  listed above, he can supply a decoder and an encoder for it in CCL
  (Code Conversion Language) programs.  Emacs executes the CCL program
  while reading/writing.

  Emacs represents a coding system by a Lisp symbol that has a property
  `coding-system'.  But, before actually using the coding system, the
  information about it is set in a structure of type `struct
  coding_system' for rapid processing.  See section 6 for more details.

*/

/*** GENERAL NOTES on END-OF-LINE FORMAT ***

  How end-of-line of a text is encoded depends on a system.  For
  instance, Unix's format is just one byte of `line-feed' code,
  whereas DOS's format is two-byte sequence of `carriage-return' and
  `line-feed' codes.  MacOS's format is usually one byte of
  `carriage-return'.

  Since text characters encoding and end-of-line encoding are
  independent, any coding system described above can take
  any format of end-of-line.  So, Emacs has information of format of
  end-of-line in each coding-system.  See section 6 for more details.

*/

/*** GENERAL NOTES on `detect_coding_XXX ()' functions ***

  These functions check if a text between SRC and SRC_END is encoded
  in the coding system category XXX.  Each returns an integer value in
  which appropriate flag bits for the category XXX is set.  The flag
  bits are defined in macros CODING_CATEGORY_MASK_XXX.  Below is the
  template of these functions.  */
#if 0
int
detect_coding_emacs_mule (src, src_end)
     unsigned char *src, *src_end;
{
  ...
}
#endif

/*** GENERAL NOTES on `decode_coding_XXX ()' functions ***

  These functions decode SRC_BYTES length text at SOURCE encoded in
  CODING to Emacs' internal format (emacs-mule).  The resulting text
  goes to a place pointed to by DESTINATION, the length of which
  should not exceed DST_BYTES.  These functions set the information of
  original and decoded texts in the members produced, produced_char,
  consumed, and consumed_char of the structure *CODING.

  The return value is an integer (CODING_FINISH_XXX) indicating how
  the decoding finished.

  DST_BYTES zero means that source area and destination area are
  overlapped, which means that we can produce a decoded text until it
  reaches at the head of not-yet-decoded source text.

  Below is a template of these functions.  */
#if 0
decode_coding_XXX (coding, source, destination, src_bytes, dst_bytes)
     struct coding_system *coding;
     unsigned char *source, *destination;
     int src_bytes, dst_bytes;
{
  ...
}
#endif

/*** GENERAL NOTES on `encode_coding_XXX ()' functions ***

  These functions encode SRC_BYTES length text at SOURCE of Emacs'
  internal format (emacs-mule) to CODING.  The resulting text goes to
  a place pointed to by DESTINATION, the length of which should not
  exceed DST_BYTES.  These functions set the information of
  original and encoded texts in the members produced, produced_char,
  consumed, and consumed_char of the structure *CODING.

  The return value is an integer (CODING_FINISH_XXX) indicating how
  the encoding finished.

  DST_BYTES zero means that source area and destination area are
  overlapped, which means that we can produce a decoded text until it
  reaches at the head of not-yet-decoded source text.

  Below is a template of these functions.  */
#if 0
encode_coding_XXX (coding, source, destination, src_bytes, dst_bytes)
     struct coding_system *coding;
     unsigned char *source, *destination;
     int src_bytes, dst_bytes;
{
  ...
}
#endif

/*** COMMONLY USED MACROS ***/

/* The following three macros ONE_MORE_BYTE, TWO_MORE_BYTES, and
   THREE_MORE_BYTES safely get one, two, and three bytes from the
   source text respectively.  If there are not enough bytes in the
   source, they jump to `label_end_of_loop'.  The caller should set
   variables `src' and `src_end' to appropriate areas in advance.  */

#define ONE_MORE_BYTE(c1)   	\
  do {			     	\
    if (src < src_end)	     	\
      c1 = *src++;	     	\
    else		     	\
      goto label_end_of_loop;	\
  } while (0)

#define TWO_MORE_BYTES(c1, c2) 	\
  do {			       	\
    if (src + 1 < src_end)     	\
      c1 = *src++, c2 = *src++;	\
    else		       	\
      goto label_end_of_loop;  	\
  } while (0)

#define THREE_MORE_BYTES(c1, c2, c3)	    	\
  do {					    	\
    if (src + 2 < src_end)		    	\
      c1 = *src++, c2 = *src++, c3 = *src++;	\
    else				    	\
      goto label_end_of_loop;		    	\
  } while (0)

/* The following three macros DECODE_CHARACTER_ASCII,
   DECODE_CHARACTER_DIMENSION1, and DECODE_CHARACTER_DIMENSION2 put
   the multi-byte form of a character of each class at the place
   pointed by `dst'.  The caller should set the variable `dst' to
   point to an appropriate area and the variable `coding' to point to
   the coding-system of the currently decoding text in advance.  */

/* Decode one ASCII character C.  */

#define DECODE_CHARACTER_ASCII(c)		\
  do {						\
    if (COMPOSING_P (coding->composing))	\
      {						\
	*dst++ = 0xA0, *dst++ = (c) | 0x80;	\
	coding->composed_chars++;		\
	if (((c) | 0x80) < 0xA0)		\
	  coding->fake_multibyte = 1;		\
      }						\
    else					\
      {						\
	/* If ASCII charset is invoked to GR,	\
	   we must reset MSB now.  */		\
	*dst++ = (c) & 0x7F;			\
	coding->produced_char++;		\
      }						\
  } while (0)

/* Decode one DIMENSION1 character whose charset is CHARSET and whose
   position-code is C.  */

#define DECODE_CHARACTER_DIMENSION1(charset, c)				\
  do {									\
    unsigned char leading_code = CHARSET_LEADING_CODE_BASE (charset);	\
    if (COMPOSING_P (coding->composing))				\
      {									\
	*dst++ = leading_code + 0x20;					\
	coding->composed_chars++;					\
      }									\
    else								\
      {									\
	*dst++ = leading_code;						\
	coding->produced_char++;					\
      }									\
    if (leading_code = CHARSET_LEADING_CODE_EXT (charset))		\
      *dst++ = leading_code;						\
    *dst++ = (c) | 0x80;						\
    if (((c) | 0x80)  < 0xA0)						\
      coding->fake_multibyte = 1; 					\
  } while (0)

/* Decode one DIMENSION2 character whose charset is CHARSET and whose
   position-codes are C1 and C2.  */

#define DECODE_CHARACTER_DIMENSION2(charset, c1, c2)	\
  do {							\
    DECODE_CHARACTER_DIMENSION1 (charset, c1);		\
    *dst++ = (c2) | 0x80;				\
    if (((c2) | 0x80) < 0xA0)				\
      coding->fake_multibyte = 1;			\
  } while (0)


/*** 1. Preamble ***/

#include <stdio.h>

#ifdef emacs

#include <config.h>
#include "lisp.h"
#include "buffer.h"
#include "charset.h"
#include "ccl.h"
#include "coding.h"
#include "window.h"

#else  /* not emacs */

#include "mulelib.h"

#endif /* not emacs */

Lisp_Object Qcoding_system, Qeol_type;
Lisp_Object Qbuffer_file_coding_system;
Lisp_Object Qpost_read_conversion, Qpre_write_conversion;
Lisp_Object Qno_conversion, Qundecided;
Lisp_Object Qcoding_system_history;
Lisp_Object Qsafe_charsets;
Lisp_Object Qvalid_codes;

extern Lisp_Object Qinsert_file_contents, Qwrite_region;
Lisp_Object Qcall_process, Qcall_process_region, Qprocess_argument;
Lisp_Object Qstart_process, Qopen_network_stream;
Lisp_Object Qtarget_idx;

Lisp_Object Vselect_safe_coding_system_function;

/* Mnemonic string for each format of end-of-line.  */
Lisp_Object eol_mnemonic_unix, eol_mnemonic_dos, eol_mnemonic_mac;
/* Mnemonic string to indicate format of end-of-line is not yet
   decided.  */
Lisp_Object eol_mnemonic_undecided;

/* Format of end-of-line decided by system.  This is CODING_EOL_LF on
   Unix, CODING_EOL_CRLF on DOS/Windows, and CODING_EOL_CR on Mac.  */
int system_eol_type;

#ifdef emacs

Lisp_Object Vcoding_system_list, Vcoding_system_alist;

Lisp_Object Qcoding_system_p, Qcoding_system_error;

/* Coding system emacs-mule and raw-text are for converting only
   end-of-line format.  */
Lisp_Object Qemacs_mule, Qraw_text;

/* Coding-systems are handed between Emacs Lisp programs and C internal
   routines by the following three variables.  */
/* Coding-system for reading files and receiving data from process.  */
Lisp_Object Vcoding_system_for_read;
/* Coding-system for writing files and sending data to process.  */
Lisp_Object Vcoding_system_for_write;
/* Coding-system actually used in the latest I/O.  */
Lisp_Object Vlast_coding_system_used;

/* A vector of length 256 which contains information about special
   Latin codes (especially for dealing with Microsoft codes).  */
Lisp_Object Vlatin_extra_code_table;

/* Flag to inhibit code conversion of end-of-line format.  */
int inhibit_eol_conversion;

/* Flag to make buffer-file-coding-system inherit from process-coding.  */
int inherit_process_coding_system;

/* Coding system to be used to encode text for terminal display.  */
struct coding_system terminal_coding;

/* Coding system to be used to encode text for terminal display when
   terminal coding system is nil.  */
struct coding_system safe_terminal_coding;

/* Coding system of what is sent from terminal keyboard.  */
struct coding_system keyboard_coding;

/* Default coding system to be used to write a file.  */
struct coding_system default_buffer_file_coding;

Lisp_Object Vfile_coding_system_alist;
Lisp_Object Vprocess_coding_system_alist;
Lisp_Object Vnetwork_coding_system_alist;

#endif /* emacs */

Lisp_Object Qcoding_category, Qcoding_category_index;

/* List of symbols `coding-category-xxx' ordered by priority.  */
Lisp_Object Vcoding_category_list;

/* Table of coding categories (Lisp symbols).  */
Lisp_Object Vcoding_category_table;

/* Table of names of symbol for each coding-category.  */
char *coding_category_name[CODING_CATEGORY_IDX_MAX] = {
  "coding-category-emacs-mule",
  "coding-category-sjis",
  "coding-category-iso-7",
  "coding-category-iso-7-tight",
  "coding-category-iso-8-1",
  "coding-category-iso-8-2",
  "coding-category-iso-7-else",
  "coding-category-iso-8-else",
  "coding-category-ccl",
  "coding-category-big5",
  "coding-category-raw-text",
  "coding-category-binary"
};

/* Table of pointers to coding systems corresponding to each coding
   categories.  */
struct coding_system *coding_system_table[CODING_CATEGORY_IDX_MAX];

/* Table of coding category masks.  Nth element is a mask for a coding
   cateogry of which priority is Nth.  */
static
int coding_priorities[CODING_CATEGORY_IDX_MAX];

/* Flag to tell if we look up translation table on character code
   conversion.  */
Lisp_Object Venable_character_translation;
/* Standard translation table to look up on decoding (reading).  */
Lisp_Object Vstandard_translation_table_for_decode;
/* Standard translation table to look up on encoding (writing).  */
Lisp_Object Vstandard_translation_table_for_encode;

Lisp_Object Qtranslation_table;
Lisp_Object Qtranslation_table_id;
Lisp_Object Qtranslation_table_for_decode;
Lisp_Object Qtranslation_table_for_encode;

/* Alist of charsets vs revision number.  */
Lisp_Object Vcharset_revision_alist;

/* Default coding systems used for process I/O.  */
Lisp_Object Vdefault_process_coding_system;


/*** 2. Emacs internal format (emacs-mule) handlers ***/

/* Emacs' internal format for encoding multiple character sets is a
   kind of multi-byte encoding, i.e. characters are encoded by
   variable-length sequences of one-byte codes.  ASCII characters
   and control characters (e.g. `tab', `newline') are represented by
   one-byte sequences which are their ASCII codes, in the range 0x00
   through 0x7F.  The other characters are represented by a sequence
   of `base leading-code', optional `extended leading-code', and one
   or two `position-code's.  The length of the sequence is determined
   by the base leading-code.  Leading-code takes the range 0x80
   through 0x9F, whereas extended leading-code and position-code take
   the range 0xA0 through 0xFF.  See `charset.h' for more details
   about leading-code and position-code.

   There's one exception to this rule.  Special leading-code
   `leading-code-composition' denotes that the following several
   characters should be composed into one character.  Leading-codes of
   components (except for ASCII) are added 0x20.  An ASCII character
   component is represented by a 2-byte sequence of `0xA0' and
   `ASCII-code + 0x80'.  See also the comments in `charset.h' for the
   details of composite character.  Hence, we can summarize the code
   range as follows:

   --- CODE RANGE of Emacs' internal format ---
   (character set)	(range)
   ASCII		0x00 .. 0x7F
   ELSE (1st byte)	0x80 .. 0x9F
	(rest bytes)	0xA0 .. 0xFF
   ---------------------------------------------

  */

enum emacs_code_class_type emacs_code_class[256];

/* Go to the next statement only if *SRC is accessible and the code is
   greater than 0xA0.  */
#define CHECK_CODE_RANGE_A0_FF 	\
  do {			       	\
    if (src >= src_end)	       	\
      goto label_end_of_switch;	\
    else if (*src++ < 0xA0)    	\
      return 0;		       	\
  } while (0)

/* See the above "GENERAL NOTES on `detect_coding_XXX ()' functions".
   Check if a text is encoded in Emacs' internal format.  If it is,
   return CODING_CATEGORY_MASK_EMACS_MULE, else return 0.  */

int
detect_coding_emacs_mule (src, src_end)
     unsigned char *src, *src_end;
{
  unsigned char c;
  int composing = 0;

  while (src < src_end)
    {
      c = *src++;

      if (composing)
	{
	  if (c < 0xA0)
	    composing = 0;
	  else
	    c -= 0x20;
	}

      switch (emacs_code_class[c])
	{
	case EMACS_ascii_code:
	case EMACS_linefeed_code:
	  break;

	case EMACS_control_code:
	  if (c == ISO_CODE_ESC || c == ISO_CODE_SI || c == ISO_CODE_SO)
	    return 0;
	  break;

	case EMACS_invalid_code:
	  return 0;

	case EMACS_leading_code_composition: /* c == 0x80 */
	  if (composing)
	    CHECK_CODE_RANGE_A0_FF;
	  else
	    composing = 1;
	  break;

	case EMACS_leading_code_4:
	  CHECK_CODE_RANGE_A0_FF;
	  /* fall down to check it two more times ...  */

	case EMACS_leading_code_3:
	  CHECK_CODE_RANGE_A0_FF;
	  /* fall down to check it one more time ...  */

	case EMACS_leading_code_2:
	  CHECK_CODE_RANGE_A0_FF;
	  break;

	default:
	label_end_of_switch:
	  break;
	}
    }
  return CODING_CATEGORY_MASK_EMACS_MULE;
}


/*** 3. ISO2022 handlers ***/

/* The following note describes the coding system ISO2022 briefly.
   Since the intention of this note is to help understand the
   functions in this file, some parts are NOT ACCURATE or OVERLY
   SIMPLIFIED.  For thorough understanding, please refer to the
   original document of ISO2022.

   ISO2022 provides many mechanisms to encode several character sets
   in 7-bit and 8-bit environments.  For 7-bite environments, all text
   is encoded using bytes less than 128.  This may make the encoded
   text a little bit longer, but the text passes more easily through
   several gateways, some of which strip off MSB (Most Signigant Bit).
 
   There are two kinds of character sets: control character set and
   graphic character set.  The former contains control characters such
   as `newline' and `escape' to provide control functions (control
   functions are also provided by escape sequences).  The latter
   contains graphic characters such as 'A' and '-'.  Emacs recognizes
   two control character sets and many graphic character sets.

   Graphic character sets are classified into one of the following
   four classes, according to the number of bytes (DIMENSION) and
   number of characters in one dimension (CHARS) of the set:
   - DIMENSION1_CHARS94
   - DIMENSION1_CHARS96
   - DIMENSION2_CHARS94
   - DIMENSION2_CHARS96

   In addition, each character set is assigned an identification tag,
   unique for each set, called "final character" (denoted as <F>
   hereafter).  The <F> of each character set is decided by ECMA(*)
   when it is registered in ISO.  The code range of <F> is 0x30..0x7F
   (0x30..0x3F are for private use only).

   Note (*): ECMA = European Computer Manufacturers Association

   Here are examples of graphic character set [NAME(<F>)]:
	o DIMENSION1_CHARS94 -- ASCII('B'), right-half-of-JISX0201('I'), ...
	o DIMENSION1_CHARS96 -- right-half-of-ISO8859-1('A'), ...
	o DIMENSION2_CHARS94 -- GB2312('A'), JISX0208('B'), ...
	o DIMENSION2_CHARS96 -- none for the moment

   A code area (1 byte=8 bits) is divided into 4 areas, C0, GL, C1, and GR.
	C0 [0x00..0x1F] -- control character plane 0
	GL [0x20..0x7F] -- graphic character plane 0
	C1 [0x80..0x9F] -- control character plane 1
	GR [0xA0..0xFF] -- graphic character plane 1

   A control character set is directly designated and invoked to C0 or
   C1 by an escape sequence.  The most common case is that:
   - ISO646's  control character set is designated/invoked to C0, and
   - ISO6429's control character set is designated/invoked to C1,
   and usually these designations/invocations are omitted in encoded
   text.  In a 7-bit environment, only C0 can be used, and a control
   character for C1 is encoded by an appropriate escape sequence to
   fit into the environment.  All control characters for C1 are
   defined to have corresponding escape sequences.

   A graphic character set is at first designated to one of four
   graphic registers (G0 through G3), then these graphic registers are
   invoked to GL or GR.  These designations and invocations can be
   done independently.  The most common case is that G0 is invoked to
   GL, G1 is invoked to GR, and ASCII is designated to G0.  Usually
   these invocations and designations are omitted in encoded text.
   In a 7-bit environment, only GL can be used.

   When a graphic character set of CHARS94 is invoked to GL, codes
   0x20 and 0x7F of the GL area work as control characters SPACE and
   DEL respectively, and codes 0xA0 and 0xFF of the GR area should not
   be used.

   There are two ways of invocation: locking-shift and single-shift.
   With locking-shift, the invocation lasts until the next different
   invocation, whereas with single-shift, the invocation affects the
   following character only and doesn't affect the locking-shift
   state.  Invocations are done by the following control characters or
   escape sequences:

   ----------------------------------------------------------------------
   abbrev  function	             cntrl escape seq	description
   ----------------------------------------------------------------------
   SI/LS0  (shift-in)		     0x0F  none		invoke G0 into GL
   SO/LS1  (shift-out)		     0x0E  none		invoke G1 into GL
   LS2     (locking-shift-2)	     none  ESC 'n'	invoke G2 into GL
   LS3     (locking-shift-3)	     none  ESC 'o'	invoke G3 into GL
   LS1R    (locking-shift-1 right)   none  ESC '~'      invoke G1 into GR (*)
   LS2R    (locking-shift-2 right)   none  ESC '}'      invoke G2 into GR (*)
   LS3R    (locking-shift 3 right)   none  ESC '|'      invoke G3 into GR (*)
   SS2     (single-shift-2)	     0x8E  ESC 'N'	invoke G2 for one char
   SS3     (single-shift-3)	     0x8F  ESC 'O'	invoke G3 for one char
   ----------------------------------------------------------------------
   (*) These are not used by any known coding system.

   Control characters for these functions are defined by macros
   ISO_CODE_XXX in `coding.h'.

   Designations are done by the following escape sequences:
   ----------------------------------------------------------------------
   escape sequence	description
   ----------------------------------------------------------------------
   ESC '(' <F>		designate DIMENSION1_CHARS94<F> to G0
   ESC ')' <F>		designate DIMENSION1_CHARS94<F> to G1
   ESC '*' <F>		designate DIMENSION1_CHARS94<F> to G2
   ESC '+' <F>		designate DIMENSION1_CHARS94<F> to G3
   ESC ',' <F>		designate DIMENSION1_CHARS96<F> to G0 (*)
   ESC '-' <F>		designate DIMENSION1_CHARS96<F> to G1
   ESC '.' <F>		designate DIMENSION1_CHARS96<F> to G2
   ESC '/' <F>		designate DIMENSION1_CHARS96<F> to G3
   ESC '$' '(' <F>	designate DIMENSION2_CHARS94<F> to G0 (**)
   ESC '$' ')' <F>	designate DIMENSION2_CHARS94<F> to G1
   ESC '$' '*' <F>	designate DIMENSION2_CHARS94<F> to G2
   ESC '$' '+' <F>	designate DIMENSION2_CHARS94<F> to G3
   ESC '$' ',' <F>	designate DIMENSION2_CHARS96<F> to G0 (*)
   ESC '$' '-' <F>	designate DIMENSION2_CHARS96<F> to G1
   ESC '$' '.' <F>	designate DIMENSION2_CHARS96<F> to G2
   ESC '$' '/' <F>	designate DIMENSION2_CHARS96<F> to G3
   ----------------------------------------------------------------------

   In this list, "DIMENSION1_CHARS94<F>" means a graphic character set
   of dimension 1, chars 94, and final character <F>, etc...

   Note (*): Although these designations are not allowed in ISO2022,
   Emacs accepts them on decoding, and produces them on encoding
   CHARS96 character sets in a coding system which is characterized as
   7-bit environment, non-locking-shift, and non-single-shift.

   Note (**): If <F> is '@', 'A', or 'B', the intermediate character
   '(' can be omitted.  We refer to this as "short-form" hereafter.

   Now you may notice that there are a lot of ways for encoding the
   same multilingual text in ISO2022.  Actually, there exist many
   coding systems such as Compound Text (used in X11's inter client
   communication, ISO-2022-JP (used in Japanese internet), ISO-2022-KR
   (used in Korean internet), EUC (Extended UNIX Code, used in Asian
   localized platforms), and all of these are variants of ISO2022.

   In addition to the above, Emacs handles two more kinds of escape
   sequences: ISO6429's direction specification and Emacs' private
   sequence for specifying character composition.

   ISO6429's direction specification takes the following form:
	o CSI ']'      -- end of the current direction
	o CSI '0' ']'  -- end of the current direction
	o CSI '1' ']'  -- start of left-to-right text
	o CSI '2' ']'  -- start of right-to-left text
   The control character CSI (0x9B: control sequence introducer) is
   abbreviated to the escape sequence ESC '[' in a 7-bit environment.

   Character composition specification takes the following form:
	o ESC '0' -- start character composition
	o ESC '1' -- end character composition
   Since these are not standard escape sequences of any ISO standard,
   the use of them for these meaning is restricted to Emacs only.  */

enum iso_code_class_type iso_code_class[256];

#define CHARSET_OK(idx, charset)				\
  (coding_system_table[idx]					\
   && (coding_system_table[idx]->safe_charsets[charset]		\
       || (CODING_SPEC_ISO_REQUESTED_DESIGNATION		\
            (coding_system_table[idx], charset)			\
           != CODING_SPEC_ISO_NO_REQUESTED_DESIGNATION)))

#define SHIFT_OUT_OK(idx) \
  (CODING_SPEC_ISO_INITIAL_DESIGNATION (coding_system_table[idx], 1) >= 0)

/* See the above "GENERAL NOTES on `detect_coding_XXX ()' functions".
   Check if a text is encoded in ISO2022.  If it is, returns an
   integer in which appropriate flag bits any of:
	CODING_CATEGORY_MASK_ISO_7
	CODING_CATEGORY_MASK_ISO_7_TIGHT
	CODING_CATEGORY_MASK_ISO_8_1
	CODING_CATEGORY_MASK_ISO_8_2
	CODING_CATEGORY_MASK_ISO_7_ELSE
	CODING_CATEGORY_MASK_ISO_8_ELSE
   are set.  If a code which should never appear in ISO2022 is found,
   returns 0.  */

int
detect_coding_iso2022 (src, src_end)
     unsigned char *src, *src_end;
{
  int mask = CODING_CATEGORY_MASK_ISO;
  int mask_found = 0;
  int reg[4], shift_out = 0, single_shifting = 0;
  int c, c1, i, charset;

  reg[0] = CHARSET_ASCII, reg[1] = reg[2] = reg[3] = -1;
  while (mask && src < src_end)
    {
      c = *src++;
      switch (c)
	{
	case ISO_CODE_ESC:
	  single_shifting = 0;
	  if (src >= src_end)
	    break;
	  c = *src++;
	  if (c >= '(' && c <= '/')
	    {
	      /* Designation sequence for a charset of dimension 1.  */
	      if (src >= src_end)
		break;
	      c1 = *src++;
	      if (c1 < ' ' || c1 >= 0x80
		  || (charset = iso_charset_table[0][c >= ','][c1]) < 0)
		/* Invalid designation sequence.  Just ignore.  */
		break;
	      reg[(c - '(') % 4] = charset;
	    }
	  else if (c == '$')
	    {
	      /* Designation sequence for a charset of dimension 2.  */
	      if (src >= src_end)
		break;
	      c = *src++;
	      if (c >= '@' && c <= 'B')
		/* Designation for JISX0208.1978, GB2312, or JISX0208.  */
		reg[0] = charset = iso_charset_table[1][0][c];
	      else if (c >= '(' && c <= '/')
		{
		  if (src >= src_end)
		    break;
		  c1 = *src++;
		  if (c1 < ' ' || c1 >= 0x80
		      || (charset = iso_charset_table[1][c >= ','][c1]) < 0)
		    /* Invalid designation sequence.  Just ignore.  */
		    break;
		  reg[(c - '(') % 4] = charset;
		}
	      else
		/* Invalid designation sequence.  Just ignore.  */
		break;
	    }
	  else if (c == 'N' || c == 'O')
	    {
	      /* ESC <Fe> for SS2 or SS3.  */
	      mask &= CODING_CATEGORY_MASK_ISO_7_ELSE;
	      break;
	    }
	  else if (c == '0' || c == '1' || c == '2')
	    /* ESC <Fp> for start/end composition.  Just ignore.  */
	    break;
	  else
	    /* Invalid escape sequence.  Just ignore.  */
	    break;

	  /* We found a valid designation sequence for CHARSET.  */
	  mask &= ~CODING_CATEGORY_MASK_ISO_8BIT;
	  if (CHARSET_OK (CODING_CATEGORY_IDX_ISO_7, charset))
	    mask_found |= CODING_CATEGORY_MASK_ISO_7;
	  else
	    mask &= ~CODING_CATEGORY_MASK_ISO_7;
	  if (CHARSET_OK (CODING_CATEGORY_IDX_ISO_7_TIGHT, charset))
	    mask_found |= CODING_CATEGORY_MASK_ISO_7_TIGHT;
	  else
	    mask &= ~CODING_CATEGORY_MASK_ISO_7_TIGHT;
	  if (CHARSET_OK (CODING_CATEGORY_IDX_ISO_7_ELSE, charset))
	    mask_found |= CODING_CATEGORY_MASK_ISO_7_ELSE;
	  else
	    mask &= ~CODING_CATEGORY_MASK_ISO_7_ELSE;
	  if (CHARSET_OK (CODING_CATEGORY_IDX_ISO_8_ELSE, charset))
	    mask_found |= CODING_CATEGORY_MASK_ISO_8_ELSE;
	  else
	    mask &= ~CODING_CATEGORY_MASK_ISO_8_ELSE;
	  break;

	case ISO_CODE_SO:
	  single_shifting = 0;
	  if (shift_out == 0
	      && (reg[1] >= 0
		  || SHIFT_OUT_OK (CODING_CATEGORY_IDX_ISO_7_ELSE)
		  || SHIFT_OUT_OK (CODING_CATEGORY_IDX_ISO_8_ELSE)))
	    {
	      /* Locking shift out.  */
	      mask &= ~CODING_CATEGORY_MASK_ISO_7BIT;
	      mask_found |= CODING_CATEGORY_MASK_ISO_SHIFT;
	    }
	  break;
	  
	case ISO_CODE_SI:
	  single_shifting = 0;
	  if (shift_out == 1)
	    {
	      /* Locking shift in.  */
	      mask &= ~CODING_CATEGORY_MASK_ISO_7BIT;
	      mask_found |= CODING_CATEGORY_MASK_ISO_SHIFT;
	    }
	  break;

	case ISO_CODE_CSI:
	  single_shifting = 0;
	case ISO_CODE_SS2:
	case ISO_CODE_SS3:
	  {
	    int newmask = CODING_CATEGORY_MASK_ISO_8_ELSE;

	    if (c != ISO_CODE_CSI)
	      {
		if (coding_system_table[CODING_CATEGORY_IDX_ISO_8_1]->flags
		    & CODING_FLAG_ISO_SINGLE_SHIFT)
		  newmask |= CODING_CATEGORY_MASK_ISO_8_1;
		if (coding_system_table[CODING_CATEGORY_IDX_ISO_8_2]->flags
		    & CODING_FLAG_ISO_SINGLE_SHIFT)
		  newmask |= CODING_CATEGORY_MASK_ISO_8_2;
		single_shifting = 1;
	      }
	    if (VECTORP (Vlatin_extra_code_table)
		&& !NILP (XVECTOR (Vlatin_extra_code_table)->contents[c]))
	      {
		if (coding_system_table[CODING_CATEGORY_IDX_ISO_8_1]->flags
		    & CODING_FLAG_ISO_LATIN_EXTRA)
		  newmask |= CODING_CATEGORY_MASK_ISO_8_1;
		if (coding_system_table[CODING_CATEGORY_IDX_ISO_8_2]->flags
		    & CODING_FLAG_ISO_LATIN_EXTRA)
		  newmask |= CODING_CATEGORY_MASK_ISO_8_2;
	      }
	    mask &= newmask;
	    mask_found |= newmask;
	  }
	  break;

	default:
	  if (c < 0x80)
	    {
	      single_shifting = 0;
	      break;
	    }
	  else if (c < 0xA0)
	    {
	      single_shifting = 0;
	      if (VECTORP (Vlatin_extra_code_table)
		  && !NILP (XVECTOR (Vlatin_extra_code_table)->contents[c]))
		{
		  int newmask = 0;

		  if (coding_system_table[CODING_CATEGORY_IDX_ISO_8_1]->flags
		      & CODING_FLAG_ISO_LATIN_EXTRA)
		    newmask |= CODING_CATEGORY_MASK_ISO_8_1;
		  if (coding_system_table[CODING_CATEGORY_IDX_ISO_8_2]->flags
		      & CODING_FLAG_ISO_LATIN_EXTRA)
		    newmask |= CODING_CATEGORY_MASK_ISO_8_2;
		  mask &= newmask;
		  mask_found |= newmask;
		}
	      else
		return 0;
	    }
	  else
	    {
	      unsigned char *src_begin = src;

	      mask &= ~(CODING_CATEGORY_MASK_ISO_7BIT
			| CODING_CATEGORY_MASK_ISO_7_ELSE);
	      mask_found |= CODING_CATEGORY_MASK_ISO_8_1;
	      /* Check the length of succeeding codes of the range
                 0xA0..0FF.  If the byte length is odd, we exclude
                 CODING_CATEGORY_MASK_ISO_8_2.  We can check this only
                 when we are not single shifting.  */
	      if (!single_shifting)
		{
		  while (src < src_end && *src >= 0xA0)
		    src++;
		  if ((src - src_begin - 1) & 1 && src < src_end)
		    mask &= ~CODING_CATEGORY_MASK_ISO_8_2;
		  else
		    mask_found |= CODING_CATEGORY_MASK_ISO_8_2;
		}
	    }
	  break;
	}
    }

  return (mask & mask_found);
}

/* Decode a character of which charset is CHARSET and the 1st position
   code is C1.  If dimension of CHARSET is 2, the 2nd position code is
   fetched from SRC and set to C2.  If CHARSET is negative, it means
   that we are decoding ill formed text, and what we can do is just to
   read C1 as is.  */

#define DECODE_ISO_CHARACTER(charset, c1)				\
  do {									\
    int c_alt, charset_alt = (charset);					\
    if (COMPOSING_HEAD_P (coding->composing))				\
      {									\
	*dst++ = LEADING_CODE_COMPOSITION;				\
	if (COMPOSING_WITH_RULE_P (coding->composing))			\
	  /* To tell composition rules are embeded.  */			\
	  *dst++ = 0xFF;						\
	coding->composing += 2;						\
      }									\
    if (charset_alt >= 0)						\
      {									\
	if (CHARSET_DIMENSION (charset_alt) == 2)			\
	  {								\
	    ONE_MORE_BYTE (c2);						\
	    if (iso_code_class[(c2) & 0x7F] != ISO_0x20_or_0x7F		\
		&& iso_code_class[(c2) & 0x7F] != ISO_graphic_plane_0)	\
	      {								\
		src--;							\
		charset_alt = CHARSET_ASCII;				\
	      }								\
	  }								\
	if (!NILP (translation_table)					\
	    && ((c_alt = translate_char (translation_table,		\
					 -1, charset_alt, c1, c2)) >= 0)) \
	  SPLIT_CHAR (c_alt, charset_alt, c1, c2);			\
      }									\
    if (charset_alt == CHARSET_ASCII || charset_alt < 0)		\
      DECODE_CHARACTER_ASCII (c1);					\
    else if (CHARSET_DIMENSION (charset_alt) == 1)			\
      DECODE_CHARACTER_DIMENSION1 (charset_alt, c1);			\
    else								\
      DECODE_CHARACTER_DIMENSION2 (charset_alt, c1, c2);		\
    if (COMPOSING_WITH_RULE_P (coding->composing))			\
      /* To tell a composition rule follows.  */			\
      coding->composing = COMPOSING_WITH_RULE_RULE;			\
  } while (0)

/* Set designation state into CODING.  */
#define DECODE_DESIGNATION(reg, dimension, chars, final_char)		   \
  do {									   \
    int charset;							   \
    									   \
    if (final_char < '0' || final_char >= 128)				   \
      goto label_invalid_code;						   \
    charset = ISO_CHARSET_TABLE (make_number (dimension),		   \
				 make_number (chars),			   \
				 make_number (final_char));		   \
    if (charset >= 0							   \
	&& (CODING_SPEC_ISO_REQUESTED_DESIGNATION (coding, charset) == reg \
	    || coding->safe_charsets[charset]))				   \
      {									   \
	if (coding->spec.iso2022.last_invalid_designation_register == 0	   \
	    && reg == 0							   \
	    && charset == CHARSET_ASCII)				   \
	  {								   \
	    /* We should insert this designation sequence as is so	   \
               that it is surely written back to a file.  */		   \
	    coding->spec.iso2022.last_invalid_designation_register = -1;   \
	    goto label_invalid_code;					   \
	  }								   \
	coding->spec.iso2022.last_invalid_designation_register = -1;	   \
        if ((coding->mode & CODING_MODE_DIRECTION)			   \
	    && CHARSET_REVERSE_CHARSET (charset) >= 0)			   \
          charset = CHARSET_REVERSE_CHARSET (charset);			   \
        CODING_SPEC_ISO_DESIGNATION (coding, reg) = charset;		   \
      }									   \
    else								   \
      {									   \
	coding->spec.iso2022.last_invalid_designation_register = reg;	   \
	goto label_invalid_code;					   \
      }									   \
  } while (0)

/* Return 0 if there's a valid composing sequence starting at SRC and
   ending before SRC_END, else return -1.  */

int
check_composing_code (coding, src, src_end)
     struct coding_system *coding;
     unsigned char *src, *src_end;
{
  int charset, c, c1, dim;

  while (src < src_end)
    {
      c = *src++;
      if (c >= 0x20)
	continue;
      if (c != ISO_CODE_ESC || src >= src_end)
	return -1;
      c = *src++;
      if (c == '1') /* end of compsition */
	return 0;
      if (src + 2 >= src_end
	  || !coding->flags & CODING_FLAG_ISO_DESIGNATION)
	return -1;

      dim = (c == '$');
      if (dim == 1)
	c = (*src >= '@' && *src <= 'B') ? '(' : *src++;
      if (c >= '(' && c <= '/')
	{
	  c1 = *src++;
	  if ((c1 < ' ' || c1 >= 0x80)
	      || (charset = iso_charset_table[dim][c >= ','][c1]) < 0
	      || ! coding->safe_charsets[charset]
	      || (CODING_SPEC_ISO_REQUESTED_DESIGNATION (coding, charset)
		  == CODING_SPEC_ISO_NO_REQUESTED_DESIGNATION))
	    return -1;
	}
      else
	return -1;
    }

  /* We have not found the sequence "ESC 1".  */
  return -1;
}

/* See the above "GENERAL NOTES on `decode_coding_XXX ()' functions".  */

int
decode_coding_iso2022 (coding, source, destination, src_bytes, dst_bytes)
     struct coding_system *coding;
     unsigned char *source, *destination;
     int src_bytes, dst_bytes;
{
  unsigned char *src = source;
  unsigned char *src_end = source + src_bytes;
  unsigned char *dst = destination;
  unsigned char *dst_end = destination + dst_bytes;
  /* Since the maximum bytes produced by each loop is 7, we subtract 6
     from DST_END to assure that overflow checking is necessary only
     at the head of loop.  */
  unsigned char *adjusted_dst_end = dst_end - 6;
  int charset;
  /* Charsets invoked to graphic plane 0 and 1 respectively.  */
  int charset0 = CODING_SPEC_ISO_PLANE_CHARSET (coding, 0);
  int charset1 = CODING_SPEC_ISO_PLANE_CHARSET (coding, 1);
  Lisp_Object translation_table
    = coding->translation_table_for_decode;
  int result = CODING_FINISH_NORMAL;

  if (!NILP (Venable_character_translation) && NILP (translation_table))
    translation_table = Vstandard_translation_table_for_decode;

  coding->produced_char = 0;
  coding->fake_multibyte = 0;
  while (src < src_end && (dst_bytes
			   ? (dst < adjusted_dst_end)
			   : (dst < src - 6)))
    {
      /* SRC_BASE remembers the start position in source in each loop.
	 The loop will be exited when there's not enough source text
	 to analyze long escape sequence or 2-byte code (within macros
	 ONE_MORE_BYTE or TWO_MORE_BYTES).  In that case, SRC is reset
	 to SRC_BASE before exiting.  */
      unsigned char *src_base = src;
      int c1 = *src++, c2;

      switch (iso_code_class [c1])
	{
	case ISO_0x20_or_0x7F:
	  if (!coding->composing
	      && (charset0 < 0 || CHARSET_CHARS (charset0) == 94))
	    {
	      /* This is SPACE or DEL.  */
	      *dst++ = c1;
	      coding->produced_char++;
	      break;
	    }
	  /* This is a graphic character, we fall down ...  */

	case ISO_graphic_plane_0:
	  if (coding->composing == COMPOSING_WITH_RULE_RULE)
	    {
	      /* This is a composition rule.  */
	      *dst++ = c1 | 0x80;
	      coding->composing = COMPOSING_WITH_RULE_TAIL;
	    }
	  else
	    DECODE_ISO_CHARACTER (charset0, c1);
	  break;

	case ISO_0xA0_or_0xFF:
	  if (charset1 < 0 || CHARSET_CHARS (charset1) == 94
	      || coding->flags & CODING_FLAG_ISO_SEVEN_BITS)
	    goto label_invalid_code;
	  /* This is a graphic character, we fall down ... */

	case ISO_graphic_plane_1:
	  if (coding->flags & CODING_FLAG_ISO_SEVEN_BITS)
	    goto label_invalid_code;
	  else
	    DECODE_ISO_CHARACTER (charset1, c1);
	  break;

	case ISO_control_code:
	  /* All ISO2022 control characters in this class have the
             same representation in Emacs internal format.  */
	  if (c1 == '\n'
	      && (coding->mode & CODING_MODE_INHIBIT_INCONSISTENT_EOL)
	      && (coding->eol_type == CODING_EOL_CR
		  || coding->eol_type == CODING_EOL_CRLF))
	    {
	      result = CODING_FINISH_INCONSISTENT_EOL;
	      goto label_end_of_loop_2;
	    }
	  *dst++ = c1;
	  coding->produced_char++;
	  if (c1 >= 0x80)
	    coding->fake_multibyte = 1;
	  break;

	case ISO_carriage_return:
	  if (coding->eol_type == CODING_EOL_CR)
	    *dst++ = '\n';
	  else if (coding->eol_type == CODING_EOL_CRLF)
	    {
	      ONE_MORE_BYTE (c1);
	      if (c1 == ISO_CODE_LF)
		*dst++ = '\n';
	      else
		{
		  if (coding->mode & CODING_MODE_INHIBIT_INCONSISTENT_EOL)
		    {
		      result = CODING_FINISH_INCONSISTENT_EOL;
		      goto label_end_of_loop_2;
		    }
		  src--;
		  *dst++ = '\r';
		}
	    }
	  else
	    *dst++ = c1;
	  coding->produced_char++;
	  break;

	case ISO_shift_out:
	  if (! (coding->flags & CODING_FLAG_ISO_LOCKING_SHIFT)
	      || CODING_SPEC_ISO_DESIGNATION (coding, 1) < 0)
	    goto label_invalid_code;
	  CODING_SPEC_ISO_INVOCATION (coding, 0) = 1;
	  charset0 = CODING_SPEC_ISO_PLANE_CHARSET (coding, 0);
	  break;

	case ISO_shift_in:
	  if (! (coding->flags & CODING_FLAG_ISO_LOCKING_SHIFT))
	    goto label_invalid_code;
	  CODING_SPEC_ISO_INVOCATION (coding, 0) = 0;
	  charset0 = CODING_SPEC_ISO_PLANE_CHARSET (coding, 0);
	  break;

	case ISO_single_shift_2_7:
	case ISO_single_shift_2:
	  if (! (coding->flags & CODING_FLAG_ISO_SINGLE_SHIFT))
	    goto label_invalid_code;
	  /* SS2 is handled as an escape sequence of ESC 'N' */
	  c1 = 'N';
	  goto label_escape_sequence;

	case ISO_single_shift_3:
	  if (! (coding->flags & CODING_FLAG_ISO_SINGLE_SHIFT))
	    goto label_invalid_code;
	  /* SS2 is handled as an escape sequence of ESC 'O' */
	  c1 = 'O';
	  goto label_escape_sequence;

	case ISO_control_sequence_introducer:
	  /* CSI is handled as an escape sequence of ESC '[' ...  */
	  c1 = '[';
	  goto label_escape_sequence;

	case ISO_escape:
	  ONE_MORE_BYTE (c1);
	label_escape_sequence:
	  /* Escape sequences handled by Emacs are invocation,
	     designation, direction specification, and character
	     composition specification.  */
	  switch (c1)
	    {
	    case '&':		/* revision of following character set */
	      ONE_MORE_BYTE (c1);
	      if (!(c1 >= '@' && c1 <= '~'))
		goto label_invalid_code;
	      ONE_MORE_BYTE (c1);
	      if (c1 != ISO_CODE_ESC)
		goto label_invalid_code;
	      ONE_MORE_BYTE (c1);
	      goto label_escape_sequence;

	    case '$':		/* designation of 2-byte character set */
	      if (! (coding->flags & CODING_FLAG_ISO_DESIGNATION))
		goto label_invalid_code;
	      ONE_MORE_BYTE (c1);
	      if (c1 >= '@' && c1 <= 'B')
		{	/* designation of JISX0208.1978, GB2312.1980,
			   or JISX0208.1980 */
		  DECODE_DESIGNATION (0, 2, 94, c1);
		}
	      else if (c1 >= 0x28 && c1 <= 0x2B)
		{	/* designation of DIMENSION2_CHARS94 character set */
		  ONE_MORE_BYTE (c2);
		  DECODE_DESIGNATION (c1 - 0x28, 2, 94, c2);
		}
	      else if (c1 >= 0x2C && c1 <= 0x2F)
		{	/* designation of DIMENSION2_CHARS96 character set */
		  ONE_MORE_BYTE (c2);
		  DECODE_DESIGNATION (c1 - 0x2C, 2, 96, c2);
		}
	      else
		goto label_invalid_code;
	      break;

	    case 'n':		/* invocation of locking-shift-2 */
	      if (! (coding->flags & CODING_FLAG_ISO_LOCKING_SHIFT)
		  || CODING_SPEC_ISO_DESIGNATION (coding, 2) < 0)
		goto label_invalid_code;
	      CODING_SPEC_ISO_INVOCATION (coding, 0) = 2;
	      charset0 = CODING_SPEC_ISO_PLANE_CHARSET (coding, 0);
	      break;

	    case 'o':		/* invocation of locking-shift-3 */
	      if (! (coding->flags & CODING_FLAG_ISO_LOCKING_SHIFT)
		  || CODING_SPEC_ISO_DESIGNATION (coding, 3) < 0)
		goto label_invalid_code;
	      CODING_SPEC_ISO_INVOCATION (coding, 0) = 3;
	      charset0 = CODING_SPEC_ISO_PLANE_CHARSET (coding, 0);
	      break;

	    case 'N':		/* invocation of single-shift-2 */
	      if (! (coding->flags & CODING_FLAG_ISO_SINGLE_SHIFT)
		  || CODING_SPEC_ISO_DESIGNATION (coding, 2) < 0)
		goto label_invalid_code;
	      ONE_MORE_BYTE (c1);
	      charset = CODING_SPEC_ISO_DESIGNATION (coding, 2);
	      DECODE_ISO_CHARACTER (charset, c1);
	      break;

	    case 'O':		/* invocation of single-shift-3 */
	      if (! (coding->flags & CODING_FLAG_ISO_SINGLE_SHIFT)
		  || CODING_SPEC_ISO_DESIGNATION (coding, 3) < 0)
		goto label_invalid_code;
	      ONE_MORE_BYTE (c1);
	      charset = CODING_SPEC_ISO_DESIGNATION (coding, 3);
	      DECODE_ISO_CHARACTER (charset, c1);
	      break;

	    case '0': case '2':	/* start composing */
	      /* Before processing composing, we must be sure that all
		 characters being composed are supported by CODING.
		 If not, we must give up composing.  */
	      if (check_composing_code (coding, src, src_end) == 0)
		{
		  /* We are looking at a valid composition sequence.  */
		  coding->composing = (c1 == '0'
				       ? COMPOSING_NO_RULE_HEAD
				       : COMPOSING_WITH_RULE_HEAD);
		  coding->composed_chars = 0;
		}
	      else
		{
		  *dst++ = ISO_CODE_ESC;
		  *dst++ = c1;
		  coding->produced_char += 2;
		}
	      break;

	    case '1':		/* end composing */
	      if (!coding->composing)
		{
		  *dst++ = ISO_CODE_ESC;
		  *dst++ = c1;
		  coding->produced_char += 2;
		  break;
		}

	      if (coding->composed_chars > 0)
		{
		  if (coding->composed_chars == 1)
		    {
		      unsigned char *this_char_start = dst;
		      int this_bytes;

		      /* Only one character is in the composing
			 sequence.  Make it a normal character.  */
		      while (*--this_char_start != LEADING_CODE_COMPOSITION);
		      dst = (this_char_start
			     + (coding->composing == COMPOSING_NO_RULE_TAIL
				? 1 : 2));
		      *dst -= 0x20;
		      if (*dst == 0x80)
			*++dst &= 0x7F;
		      this_bytes = BYTES_BY_CHAR_HEAD (*dst);
		      while (this_bytes--) *this_char_start++ = *dst++;
		      dst = this_char_start;
		    }
		  coding->produced_char++;
		}
	      coding->composing = COMPOSING_NO;
	      break;

	    case '[':		/* specification of direction */
	      if (coding->flags & CODING_FLAG_ISO_NO_DIRECTION)
		goto label_invalid_code;
	      /* For the moment, nested direction is not supported.
		 So, `coding->mode & CODING_MODE_DIRECTION' zero means
		 left-to-right, and nozero means right-to-left.  */
	      ONE_MORE_BYTE (c1);
	      switch (c1)
		{
		case ']':	/* end of the current direction */
		  coding->mode &= ~CODING_MODE_DIRECTION;

		case '0':	/* end of the current direction */
		case '1':	/* start of left-to-right direction */
		  ONE_MORE_BYTE (c1);
		  if (c1 == ']')
		    coding->mode &= ~CODING_MODE_DIRECTION;
		  else
		    goto label_invalid_code;
		  break;

		case '2':	/* start of right-to-left direction */
		  ONE_MORE_BYTE (c1);
		  if (c1 == ']')
		    coding->mode |= CODING_MODE_DIRECTION;
		  else
		    goto label_invalid_code;
		  break;

		default:
		  goto label_invalid_code;
		}
	      break;

	    default:
	      if (! (coding->flags & CODING_FLAG_ISO_DESIGNATION))
		goto label_invalid_code;
	      if (c1 >= 0x28 && c1 <= 0x2B)
		{	/* designation of DIMENSION1_CHARS94 character set */
		  ONE_MORE_BYTE (c2);
		  DECODE_DESIGNATION (c1 - 0x28, 1, 94, c2);
		}
	      else if (c1 >= 0x2C && c1 <= 0x2F)
		{	/* designation of DIMENSION1_CHARS96 character set */
		  ONE_MORE_BYTE (c2);
		  DECODE_DESIGNATION (c1 - 0x2C, 1, 96, c2);
		}
	      else
		{
		  goto label_invalid_code;
		}
	    }
	  /* We must update these variables now.  */
	  charset0 = CODING_SPEC_ISO_PLANE_CHARSET (coding, 0);
	  charset1 = CODING_SPEC_ISO_PLANE_CHARSET (coding, 1);
	  break;

	label_invalid_code:
	  while (src_base < src)
	    *dst++ = *src_base++;
	  coding->fake_multibyte = 1;
	}
      continue;

    label_end_of_loop:
      result = CODING_FINISH_INSUFFICIENT_SRC;
    label_end_of_loop_2:
      src = src_base;
      break;
    }

  if (src < src_end)
    {
      if (result == CODING_FINISH_NORMAL)
	result = CODING_FINISH_INSUFFICIENT_DST;
      else if (result != CODING_FINISH_INCONSISTENT_EOL
	       && coding->mode & CODING_MODE_LAST_BLOCK)
	{
	  /* This is the last block of the text to be decoded.  We had
	     better just flush out all remaining codes in the text
	     although they are not valid characters.  */
	  src_bytes = src_end - src;
	  if (dst_bytes && (dst_end - dst < src_bytes))
	    src_bytes = dst_end - dst;
	  bcopy (src, dst, src_bytes);
	  dst += src_bytes;
	  src += src_bytes;
	  coding->fake_multibyte = 1;
	}
    }

  coding->consumed = coding->consumed_char = src - source;
  coding->produced = dst - destination;
  return result;
}

/* ISO2022 encoding stuff.  */

/*
   It is not enough to say just "ISO2022" on encoding, we have to
   specify more details.  In Emacs, each coding system of ISO2022
   variant has the following specifications:
	1. Initial designation to G0 thru G3.
	2. Allows short-form designation?
	3. ASCII should be designated to G0 before control characters?
	4. ASCII should be designated to G0 at end of line?
	5. 7-bit environment or 8-bit environment?
	6. Use locking-shift?
	7. Use Single-shift?
   And the following two are only for Japanese:
	8. Use ASCII in place of JIS0201-1976-Roman?
	9. Use JISX0208-1983 in place of JISX0208-1978?
   These specifications are encoded in `coding->flags' as flag bits
   defined by macros CODING_FLAG_ISO_XXX.  See `coding.h' for more
   details.
*/

/* Produce codes (escape sequence) for designating CHARSET to graphic
   register REG.  If <final-char> of CHARSET is '@', 'A', or 'B' and
   the coding system CODING allows, produce designation sequence of
   short-form.  */

#define ENCODE_DESIGNATION(charset, reg, coding)			\
  do {									\
    unsigned char final_char = CHARSET_ISO_FINAL_CHAR (charset);	\
    char *intermediate_char_94 = "()*+";				\
    char *intermediate_char_96 = ",-./";				\
    int revision = CODING_SPEC_ISO_REVISION_NUMBER(coding, charset);	\
    if (revision < 255)							\
      {									\
	*dst++ = ISO_CODE_ESC;						\
	*dst++ = '&';							\
	*dst++ = '@' + revision;					\
      }									\
    *dst++ = ISO_CODE_ESC;				       		\
    if (CHARSET_DIMENSION (charset) == 1)				\
      {									\
	if (CHARSET_CHARS (charset) == 94)				\
	  *dst++ = (unsigned char) (intermediate_char_94[reg]);		\
	else								\
	  *dst++ = (unsigned char) (intermediate_char_96[reg]);		\
      }									\
    else								\
      {									\
	*dst++ = '$';							\
	if (CHARSET_CHARS (charset) == 94)				\
	  {								\
	    if (! (coding->flags & CODING_FLAG_ISO_SHORT_FORM)     	\
		|| reg != 0					       	\
		|| final_char < '@' || final_char > 'B')	       	\
	      *dst++ = (unsigned char) (intermediate_char_94[reg]);	\
	  }								\
	else								\
	  *dst++ = (unsigned char) (intermediate_char_96[reg]);  	\
      }									\
    *dst++ = final_char;				       		\
    CODING_SPEC_ISO_DESIGNATION (coding, reg) = charset;		\
  } while (0)

/* The following two macros produce codes (control character or escape
   sequence) for ISO2022 single-shift functions (single-shift-2 and
   single-shift-3).  */

#define ENCODE_SINGLE_SHIFT_2				\
  do {							\
    if (coding->flags & CODING_FLAG_ISO_SEVEN_BITS)	\
      *dst++ = ISO_CODE_ESC, *dst++ = 'N';		\
    else						\
      {							\
	*dst++ = ISO_CODE_SS2;				\
	coding->fake_multibyte = 1;			\
      }							\
    CODING_SPEC_ISO_SINGLE_SHIFTING (coding) = 1;	\
  } while (0)

#define ENCODE_SINGLE_SHIFT_3				\
  do {							\
    if (coding->flags & CODING_FLAG_ISO_SEVEN_BITS)	\
      *dst++ = ISO_CODE_ESC, *dst++ = 'O';		\
    else						\
      {							\
	*dst++ = ISO_CODE_SS3;				\
	coding->fake_multibyte = 1;			\
      }							\
    CODING_SPEC_ISO_SINGLE_SHIFTING (coding) = 1;	\
  } while (0)

/* The following four macros produce codes (control character or
   escape sequence) for ISO2022 locking-shift functions (shift-in,
   shift-out, locking-shift-2, and locking-shift-3).  */

#define ENCODE_SHIFT_IN			  	\
  do {					  	\
    *dst++ = ISO_CODE_SI;		  	\
    CODING_SPEC_ISO_INVOCATION (coding, 0) = 0;	\
  } while (0)

#define ENCODE_SHIFT_OUT		  	\
  do {					  	\
    *dst++ = ISO_CODE_SO;		  	\
    CODING_SPEC_ISO_INVOCATION (coding, 0) = 1;	\
  } while (0)

#define ENCODE_LOCKING_SHIFT_2			\
  do {						\
    *dst++ = ISO_CODE_ESC, *dst++ = 'n';	\
    CODING_SPEC_ISO_INVOCATION (coding, 0) = 2;	\
  } while (0)

#define ENCODE_LOCKING_SHIFT_3		  	\
  do {					  	\
    *dst++ = ISO_CODE_ESC, *dst++ = 'o';  	\
    CODING_SPEC_ISO_INVOCATION (coding, 0) = 3;	\
  } while (0)

/* Produce codes for a DIMENSION1 character whose character set is
   CHARSET and whose position-code is C1.  Designation and invocation
   sequences are also produced in advance if necessary.  */


#define ENCODE_ISO_CHARACTER_DIMENSION1(charset, c1)			\
  do {									\
    if (CODING_SPEC_ISO_SINGLE_SHIFTING (coding))			\
      {									\
	if (coding->flags & CODING_FLAG_ISO_SEVEN_BITS)			\
	  *dst++ = c1 & 0x7F;						\
	else								\
	  *dst++ = c1 | 0x80;						\
	CODING_SPEC_ISO_SINGLE_SHIFTING (coding) = 0;			\
	break;								\
      }									\
    else if (charset == CODING_SPEC_ISO_PLANE_CHARSET (coding, 0))	\
      {									\
	*dst++ = c1 & 0x7F;						\
	break;								\
      }									\
    else if (charset == CODING_SPEC_ISO_PLANE_CHARSET (coding, 1))	\
      {									\
	*dst++ = c1 | 0x80;						\
	break;								\
      }									\
    else if (coding->flags & CODING_FLAG_ISO_SAFE			\
	     && !coding->safe_charsets[charset])			\
      {									\
	/* We should not encode this character, instead produce one or	\
	   two `?'s.  */						\
	*dst++ = CODING_INHIBIT_CHARACTER_SUBSTITUTION;			\
	if (CHARSET_WIDTH (charset) == 2)				\
	  *dst++ = CODING_INHIBIT_CHARACTER_SUBSTITUTION;		\
	break;								\
      }									\
    else								\
      /* Since CHARSET is not yet invoked to any graphic planes, we	\
	 must invoke it, or, at first, designate it to some graphic	\
	 register.  Then repeat the loop to actually produce the	\
	 character.  */							\
      dst = encode_invocation_designation (charset, coding, dst);	\
  } while (1)

/* Produce codes for a DIMENSION2 character whose character set is
   CHARSET and whose position-codes are C1 and C2.  Designation and
   invocation codes are also produced in advance if necessary.  */

#define ENCODE_ISO_CHARACTER_DIMENSION2(charset, c1, c2)		\
  do {									\
    if (CODING_SPEC_ISO_SINGLE_SHIFTING (coding))			\
      {									\
	if (coding->flags & CODING_FLAG_ISO_SEVEN_BITS)			\
	  *dst++ = c1 & 0x7F, *dst++ = c2 & 0x7F;			\
	else								\
	  *dst++ = c1 | 0x80, *dst++ = c2 | 0x80;			\
	CODING_SPEC_ISO_SINGLE_SHIFTING (coding) = 0;			\
	break;								\
      }									\
    else if (charset == CODING_SPEC_ISO_PLANE_CHARSET (coding, 0))	\
      {									\
	*dst++ = c1 & 0x7F, *dst++= c2 & 0x7F;				\
	break;								\
      }									\
    else if (charset == CODING_SPEC_ISO_PLANE_CHARSET (coding, 1))	\
      {									\
	*dst++ = c1 | 0x80, *dst++= c2 | 0x80;				\
	break;								\
      }									\
    else if (coding->flags & CODING_FLAG_ISO_SAFE			\
	     && !coding->safe_charsets[charset])			\
      {									\
	/* We should not encode this character, instead produce one or	\
	   two `?'s.  */						\
	*dst++ = CODING_INHIBIT_CHARACTER_SUBSTITUTION;			\
	if (CHARSET_WIDTH (charset) == 2)				\
	  *dst++ = CODING_INHIBIT_CHARACTER_SUBSTITUTION;		\
	break;								\
      }									\
    else								\
      /* Since CHARSET is not yet invoked to any graphic planes, we	\
	 must invoke it, or, at first, designate it to some graphic	\
	 register.  Then repeat the loop to actually produce the	\
	 character.  */							\
      dst = encode_invocation_designation (charset, coding, dst);	\
  } while (1)

#define ENCODE_ISO_CHARACTER(charset, c1, c2)				\
  do {									\
    int c_alt, charset_alt;						\
    if (!NILP (translation_table)					\
	&& ((c_alt = translate_char (translation_table, -1,		\
				     charset, c1, c2))			\
	    >= 0))							\
      SPLIT_CHAR (c_alt, charset_alt, c1, c2);				\
    else								\
      charset_alt = charset;						\
    if (CHARSET_DEFINED_P (charset_alt))				\
      {									\
	if (CHARSET_DIMENSION (charset_alt) == 1)			\
	  {								\
	    if (charset == CHARSET_ASCII				\
		&& coding->flags & CODING_FLAG_ISO_USE_ROMAN)		\
	      charset_alt = charset_latin_jisx0201;			\
	    ENCODE_ISO_CHARACTER_DIMENSION1 (charset_alt, c1);		\
	  }								\
	else								\
	  {								\
	    if (charset == charset_jisx0208				\
		&& coding->flags & CODING_FLAG_ISO_USE_OLDJIS)		\
	      charset_alt = charset_jisx0208_1978;			\
	    ENCODE_ISO_CHARACTER_DIMENSION2 (charset_alt, c1, c2);	\
	  }								\
      }									\
    else								\
      {									\
	if (coding->flags & CODING_FLAG_ISO_SEVEN_BITS)			\
	  {								\
	    *dst++ = charset & 0x7f;					\
	    *dst++ = c1 & 0x7f;						\
	    if (c2)							\
	      *dst++ = c2 & 0x7f;					\
	  }								\
	else								\
	  {								\
	    *dst++ = charset;						\
	    *dst++ = c1;						\
	    if (c2)							\
	      *dst++ = c2;						\
	  }								\
      }									\
    if (! COMPOSING_P (coding->composing))				\
      coding->consumed_char++;						\
  } while (0)

/* Produce designation and invocation codes at a place pointed by DST
   to use CHARSET.  The element `spec.iso2022' of *CODING is updated.
   Return new DST.  */

unsigned char *
encode_invocation_designation (charset, coding, dst)
     int charset;
     struct coding_system *coding;
     unsigned char *dst;
{
  int reg;			/* graphic register number */

  /* At first, check designations.  */
  for (reg = 0; reg < 4; reg++)
    if (charset == CODING_SPEC_ISO_DESIGNATION (coding, reg))
      break;

  if (reg >= 4)
    {
      /* CHARSET is not yet designated to any graphic registers.  */
      /* At first check the requested designation.  */
      reg = CODING_SPEC_ISO_REQUESTED_DESIGNATION (coding, charset);
      if (reg == CODING_SPEC_ISO_NO_REQUESTED_DESIGNATION)
	/* Since CHARSET requests no special designation, designate it
	   to graphic register 0.  */
	reg = 0;

      ENCODE_DESIGNATION (charset, reg, coding);
    }

  if (CODING_SPEC_ISO_INVOCATION (coding, 0) != reg
      && CODING_SPEC_ISO_INVOCATION (coding, 1) != reg)
    {
      /* Since the graphic register REG is not invoked to any graphic
	 planes, invoke it to graphic plane 0.  */
      switch (reg)
	{
	case 0:			/* graphic register 0 */
	  ENCODE_SHIFT_IN;
	  break;

	case 1:			/* graphic register 1 */
	  ENCODE_SHIFT_OUT;
	  break;

	case 2:			/* graphic register 2 */
	  if (coding->flags & CODING_FLAG_ISO_SINGLE_SHIFT)
	    ENCODE_SINGLE_SHIFT_2;
	  else
	    ENCODE_LOCKING_SHIFT_2;
	  break;

	case 3:			/* graphic register 3 */
	  if (coding->flags & CODING_FLAG_ISO_SINGLE_SHIFT)
	    ENCODE_SINGLE_SHIFT_3;
	  else
	    ENCODE_LOCKING_SHIFT_3;
	  break;
	}
    }
  return dst;
}

/* The following two macros produce codes for indicating composition.  */
#define ENCODE_COMPOSITION_NO_RULE_START  *dst++ = ISO_CODE_ESC, *dst++ = '0'
#define ENCODE_COMPOSITION_WITH_RULE_START  *dst++ = ISO_CODE_ESC, *dst++ = '2'
#define ENCODE_COMPOSITION_END    *dst++ = ISO_CODE_ESC, *dst++ = '1'

/* The following three macros produce codes for indicating direction
   of text.  */
#define ENCODE_CONTROL_SEQUENCE_INTRODUCER	    	\
  do {						    	\
    if (coding->flags == CODING_FLAG_ISO_SEVEN_BITS)	\
      *dst++ = ISO_CODE_ESC, *dst++ = '[';	    	\
    else					    	\
      *dst++ = ISO_CODE_CSI;			    	\
  } while (0)

#define ENCODE_DIRECTION_R2L	\
  ENCODE_CONTROL_SEQUENCE_INTRODUCER, *dst++ = '2', *dst++ = ']'

#define ENCODE_DIRECTION_L2R	\
  ENCODE_CONTROL_SEQUENCE_INTRODUCER, *dst++ = '0', *dst++ = ']'

/* Produce codes for designation and invocation to reset the graphic
   planes and registers to initial state.  */
#define ENCODE_RESET_PLANE_AND_REGISTER					    \
  do {									    \
    int reg;								    \
    if (CODING_SPEC_ISO_INVOCATION (coding, 0) != 0)			    \
      ENCODE_SHIFT_IN;							    \
    for (reg = 0; reg < 4; reg++)					    \
      if (CODING_SPEC_ISO_INITIAL_DESIGNATION (coding, reg) >= 0	    \
	  && (CODING_SPEC_ISO_DESIGNATION (coding, reg)			    \
	      != CODING_SPEC_ISO_INITIAL_DESIGNATION (coding, reg)))	    \
	ENCODE_DESIGNATION						    \
	  (CODING_SPEC_ISO_INITIAL_DESIGNATION (coding, reg), reg, coding); \
  } while (0)

/* Produce designation sequences of charsets in the line started from
   SRC to a place pointed by *DSTP, and update DSTP.

   If the current block ends before any end-of-line, we may fail to
   find all the necessary designations.  */

void
encode_designation_at_bol (coding, table, src, src_end, dstp)
     struct coding_system *coding;
     Lisp_Object table;
     unsigned char *src, *src_end, **dstp;
{
  int charset, c, found = 0, reg;
  /* Table of charsets to be designated to each graphic register.  */
  int r[4];
  unsigned char *dst = *dstp;

  for (reg = 0; reg < 4; reg++)
    r[reg] = -1;

  while (src < src_end && *src != '\n' && found < 4)
    {
      int bytes = BYTES_BY_CHAR_HEAD (*src);
      
      if (NILP (table))
	charset = CHARSET_AT (src);
      else
	{
	  int c_alt;
	  unsigned char c1, c2;

	  SPLIT_STRING(src, bytes, charset, c1, c2);
	  if ((c_alt = translate_char (table, -1, charset, c1, c2)) >= 0)
	    charset = CHAR_CHARSET (c_alt);
	}

      reg = CODING_SPEC_ISO_REQUESTED_DESIGNATION (coding, charset);
      if (reg != CODING_SPEC_ISO_NO_REQUESTED_DESIGNATION && r[reg] < 0)
	{
	  found++;
	  r[reg] = charset;
	}

      src += bytes;
    }

  if (found)
    {
      for (reg = 0; reg < 4; reg++)
	if (r[reg] >= 0
	    && CODING_SPEC_ISO_DESIGNATION (coding, reg) != r[reg])
	  ENCODE_DESIGNATION (r[reg], reg, coding);
      *dstp = dst;
    }
}

/* See the above "GENERAL NOTES on `encode_coding_XXX ()' functions".  */

int
encode_coding_iso2022 (coding, source, destination, src_bytes, dst_bytes)
     struct coding_system *coding;
     unsigned char *source, *destination;
     int src_bytes, dst_bytes;
{
  unsigned char *src = source;
  unsigned char *src_end = source + src_bytes;
  unsigned char *dst = destination;
  unsigned char *dst_end = destination + dst_bytes;
  /* Since the maximum bytes produced by each loop is 20, we subtract 19
     from DST_END to assure overflow checking is necessary only at the
     head of loop.  */
  unsigned char *adjusted_dst_end = dst_end - 19;
  Lisp_Object translation_table
      = coding->translation_table_for_encode;
  int result = CODING_FINISH_NORMAL;

  if (!NILP (Venable_character_translation) && NILP (translation_table))
    translation_table = Vstandard_translation_table_for_encode;

  coding->consumed_char = 0;
  coding->fake_multibyte = 0;
  while (src < src_end && (dst_bytes
			   ? (dst < adjusted_dst_end)
			   : (dst < src - 19)))
    {
      /* SRC_BASE remembers the start position in source in each loop.
	 The loop will be exited when there's not enough source text
	 to analyze multi-byte codes (within macros ONE_MORE_BYTE,
	 TWO_MORE_BYTES, and THREE_MORE_BYTES).  In that case, SRC is
	 reset to SRC_BASE before exiting.  */
      unsigned char *src_base = src;
      int charset, c1, c2, c3, c4;

      if (coding->flags & CODING_FLAG_ISO_DESIGNATE_AT_BOL
	  && CODING_SPEC_ISO_BOL (coding))
	{
	  /* We have to produce designation sequences if any now.  */
	  encode_designation_at_bol (coding, translation_table,
				     src, src_end, &dst);
	  CODING_SPEC_ISO_BOL (coding) = 0;
	}

      c1 = *src++;
      /* If we are seeing a component of a composite character, we are
	 seeing a leading-code encoded irregularly for composition, or
	 a composition rule if composing with rule.  We must set C1 to
	 a normal leading-code or an ASCII code.  If we are not seeing
	 a composite character, we must reset composition,
	 designation, and invocation states.  */
      if (COMPOSING_P (coding->composing))
	{
	  if (c1 < 0xA0)
	    {
	      /* We are not in a composite character any longer.  */
	      coding->composing = COMPOSING_NO;
	      ENCODE_RESET_PLANE_AND_REGISTER;
	      ENCODE_COMPOSITION_END;
	    }
	  else
	    {
	      if (coding->composing == COMPOSING_WITH_RULE_RULE)
		{
		  *dst++ = c1 & 0x7F;
		  coding->composing = COMPOSING_WITH_RULE_HEAD;
		  continue;
		}
	      else if (coding->composing == COMPOSING_WITH_RULE_HEAD)
		coding->composing = COMPOSING_WITH_RULE_RULE;
	      if (c1 == 0xA0)
		{
		  /* This is an ASCII component.  */
		  ONE_MORE_BYTE (c1);
		  c1 &= 0x7F;
		}
	      else
		/* This is a leading-code of non ASCII component.  */
		c1 -= 0x20;
	    }
	}
	
      /* Now encode one character.  C1 is a control character, an
         ASCII character, or a leading-code of multi-byte character.  */
      switch (emacs_code_class[c1])
	{
	case EMACS_ascii_code:
	  c2 = 0;
	  ENCODE_ISO_CHARACTER (CHARSET_ASCII, c1, /* dummy */ c2);
	  break;

	case EMACS_control_code:
	  if (coding->flags & CODING_FLAG_ISO_RESET_AT_CNTL)
	    ENCODE_RESET_PLANE_AND_REGISTER;
	  *dst++ = c1;
	  coding->consumed_char++;
	  break;

	case EMACS_carriage_return_code:
	  if (! (coding->mode & CODING_MODE_SELECTIVE_DISPLAY))
	    {
	      if (coding->flags & CODING_FLAG_ISO_RESET_AT_CNTL)
		ENCODE_RESET_PLANE_AND_REGISTER;
	      *dst++ = c1;
	      coding->consumed_char++;
	      break;
	    }
	  /* fall down to treat '\r' as '\n' ...  */

	case EMACS_linefeed_code:
	  if (coding->flags & CODING_FLAG_ISO_RESET_AT_EOL)
	    ENCODE_RESET_PLANE_AND_REGISTER;
	  if (coding->flags & CODING_FLAG_ISO_INIT_AT_BOL)
	    bcopy (coding->spec.iso2022.initial_designation,
		   coding->spec.iso2022.current_designation,
		   sizeof coding->spec.iso2022.initial_designation);
	  if (coding->eol_type == CODING_EOL_LF
	      || coding->eol_type == CODING_EOL_UNDECIDED)
	    *dst++ = ISO_CODE_LF;
	  else if (coding->eol_type == CODING_EOL_CRLF)
	    *dst++ = ISO_CODE_CR, *dst++ = ISO_CODE_LF;
	  else
	    *dst++ = ISO_CODE_CR;
	  CODING_SPEC_ISO_BOL (coding) = 1;
	  coding->consumed_char++;
	  break;

	case EMACS_leading_code_2:
	  ONE_MORE_BYTE (c2);
	  c3 = 0;
	  if (c2 < 0xA0)
	    {
	      /* invalid sequence */
	      *dst++ = c1;
	      src--;
	      coding->consumed_char++;
	    }
	  else
	    ENCODE_ISO_CHARACTER (c1, c2, /* dummy */ c3);
	  break;

	case EMACS_leading_code_3:
	  TWO_MORE_BYTES (c2, c3);
	  c4 = 0;
	  if (c2 < 0xA0 || c3 < 0xA0)
	    {
	      /* invalid sequence */
	      *dst++ = c1;
	      src -= 2;
	      coding->consumed_char++;
	    }
	  else if (c1 < LEADING_CODE_PRIVATE_11)
	    ENCODE_ISO_CHARACTER (c1, c2, c3);
	  else
	    ENCODE_ISO_CHARACTER (c2, c3, /* dummy */ c4);
	  break;

	case EMACS_leading_code_4:
	  THREE_MORE_BYTES (c2, c3, c4);
	  if (c2 < 0xA0 || c3 < 0xA0 || c4 < 0xA0)
	    {
	      /* invalid sequence */
	      *dst++ = c1;
	      src -= 3;
	      coding->consumed_char++;
	    }
	  else
	    ENCODE_ISO_CHARACTER (c2, c3, c4);
	  break;

	case EMACS_leading_code_composition:
	  ONE_MORE_BYTE (c2);
	  if (c2 < 0xA0)
	    {
	      /* invalid sequence */
	      *dst++ = c1;
	      src--;
	      coding->consumed_char++;
	    }
	  else if (c2 == 0xFF)
	    {
	      ENCODE_RESET_PLANE_AND_REGISTER;
	      coding->composing = COMPOSING_WITH_RULE_HEAD;
	      ENCODE_COMPOSITION_WITH_RULE_START;
	      coding->consumed_char++;
	    }
	  else
	    {
	      ENCODE_RESET_PLANE_AND_REGISTER;
	      /* Rewind one byte because it is a character code of
                 composition elements.  */
	      src--;
	      coding->composing = COMPOSING_NO_RULE_HEAD;
	      ENCODE_COMPOSITION_NO_RULE_START;
	      coding->consumed_char++;
	    }
	  break;

	case EMACS_invalid_code:
	  if (coding->flags & CODING_FLAG_ISO_RESET_AT_CNTL)
	    ENCODE_RESET_PLANE_AND_REGISTER;
	  *dst++ = c1;
	  coding->consumed_char++;
	  break;
	}
      continue;
    label_end_of_loop:
      result = CODING_FINISH_INSUFFICIENT_SRC;
      src = src_base;
      break;
    }

  if (src < src_end && result == CODING_FINISH_NORMAL)
    result = CODING_FINISH_INSUFFICIENT_DST;

  /* If this is the last block of the text to be encoded, we must
     reset graphic planes and registers to the initial state, and
     flush out the carryover if any.  */
  if (coding->mode & CODING_MODE_LAST_BLOCK)
    {
      ENCODE_RESET_PLANE_AND_REGISTER;
      if (COMPOSING_P (coding->composing))
	ENCODE_COMPOSITION_END;
      if (result == CODING_FINISH_INSUFFICIENT_SRC)
	{
	  while (src < src_end && dst < dst_end)
	    *dst++ = *src++;
	}
    }
  coding->consumed = src - source;
  coding->produced = coding->produced_char = dst - destination;
  return result;
}


/*** 4. SJIS and BIG5 handlers ***/

/* Although SJIS and BIG5 are not ISO's coding system, they are used
   quite widely.  So, for the moment, Emacs supports them in the bare
   C code.  But, in the future, they may be supported only by CCL.  */

/* SJIS is a coding system encoding three character sets: ASCII, right
   half of JISX0201-Kana, and JISX0208.  An ASCII character is encoded
   as is.  A character of charset katakana-jisx0201 is encoded by
   "position-code + 0x80".  A character of charset japanese-jisx0208
   is encoded in 2-byte but two position-codes are divided and shifted
   so that it fit in the range below.

   --- CODE RANGE of SJIS ---
   (character set)	(range)
   ASCII		0x00 .. 0x7F
   KATAKANA-JISX0201	0xA0 .. 0xDF
   JISX0208 (1st byte)	0x81 .. 0x9F and 0xE0 .. 0xEF
	    (2nd byte)	0x40 .. 0x7E and 0x80 .. 0xFC
   -------------------------------

*/

/* BIG5 is a coding system encoding two character sets: ASCII and
   Big5.  An ASCII character is encoded as is.  Big5 is a two-byte
   character set and is encoded in two-byte.

   --- CODE RANGE of BIG5 ---
   (character set)	(range)
   ASCII		0x00 .. 0x7F
   Big5 (1st byte)	0xA1 .. 0xFE
	(2nd byte)	0x40 .. 0x7E and 0xA1 .. 0xFE
   --------------------------

   Since the number of characters in Big5 is larger than maximum
   characters in Emacs' charset (96x96), it can't be handled as one
   charset.  So, in Emacs, Big5 is divided into two: `charset-big5-1'
   and `charset-big5-2'.  Both are DIMENSION2 and CHARS94.  The former
   contains frequently used characters and the latter contains less
   frequently used characters.  */

/* Macros to decode or encode a character of Big5 in BIG5.  B1 and B2
   are the 1st and 2nd position-codes of Big5 in BIG5 coding system.
   C1 and C2 are the 1st and 2nd position-codes of of Emacs' internal
   format.  CHARSET is `charset_big5_1' or `charset_big5_2'.  */

/* Number of Big5 characters which have the same code in 1st byte.  */
#define BIG5_SAME_ROW (0xFF - 0xA1 + 0x7F - 0x40)

#define DECODE_BIG5(b1, b2, charset, c1, c2)			     	\
  do {								     	\
    unsigned int temp						     	\
      = (b1 - 0xA1) * BIG5_SAME_ROW + b2 - (b2 < 0x7F ? 0x40 : 0x62);	\
    if (b1 < 0xC9)						     	\
      charset = charset_big5_1;					     	\
    else							     	\
      {								     	\
	charset = charset_big5_2;				     	\
	temp -= (0xC9 - 0xA1) * BIG5_SAME_ROW;			     	\
      }								     	\
    c1 = temp / (0xFF - 0xA1) + 0x21;				     	\
    c2 = temp % (0xFF - 0xA1) + 0x21;				     	\
  } while (0)

#define ENCODE_BIG5(charset, c1, c2, b1, b2)			  	\
  do {								  	\
    unsigned int temp = (c1 - 0x21) * (0xFF - 0xA1) + (c2 - 0x21);	\
    if (charset == charset_big5_2)				  	\
      temp += BIG5_SAME_ROW * (0xC9 - 0xA1);			  	\
    b1 = temp / BIG5_SAME_ROW + 0xA1;				  	\
    b2 = temp % BIG5_SAME_ROW;					  	\
    b2 += b2 < 0x3F ? 0x40 : 0x62;				  	\
  } while (0)

#define DECODE_SJIS_BIG5_CHARACTER(charset, c1, c2)			\
  do {									\
    int c_alt, charset_alt = (charset);					\
    if (!NILP (translation_table)					\
	&& ((c_alt = translate_char (translation_table,			\
				     -1, (charset), c1, c2)) >= 0))	\
      SPLIT_CHAR (c_alt, charset_alt, c1, c2);				\
    if (charset_alt == CHARSET_ASCII || charset_alt < 0)		\
      DECODE_CHARACTER_ASCII (c1);					\
    else if (CHARSET_DIMENSION (charset_alt) == 1)			\
      DECODE_CHARACTER_DIMENSION1 (charset_alt, c1);			\
    else								\
      DECODE_CHARACTER_DIMENSION2 (charset_alt, c1, c2);		\
  } while (0)

#define ENCODE_SJIS_BIG5_CHARACTER(charset, c1, c2)		\
  do {								\
    int c_alt, charset_alt;					\
    if (!NILP (translation_table)				\
	&& ((c_alt = translate_char (translation_table, -1,	\
				     charset, c1, c2))		\
	    >= 0))						\
      SPLIT_CHAR (c_alt, charset_alt, c1, c2);			\
    else							\
      charset_alt = charset;					\
    if (charset_alt == charset_ascii)				\
      *dst++ = c1;						\
    else if (CHARSET_DIMENSION (charset_alt) == 1)		\
      {								\
	if (sjis_p && charset_alt == charset_katakana_jisx0201)	\
	  *dst++ = c1;						\
	else if (sjis_p && charset_alt == charset_latin_jisx0201) \
	  *dst++ = c1 & 0x7F;					\
	else							\
	  {							\
	    *dst++ = charset_alt, *dst++ = c1;			\
	    coding->fake_multibyte = 1;				\
	  }							\
      }								\
    else							\
      {								\
	c1 &= 0x7F, c2 &= 0x7F;					\
	if (sjis_p && (charset_alt == charset_jisx0208		\
		       || charset_alt == charset_jisx0208_1978))\
	  {							\
	    unsigned char s1, s2;				\
	    							\
	    ENCODE_SJIS (c1, c2, s1, s2);			\
	    *dst++ = s1, *dst++ = s2;				\
	    coding->fake_multibyte = 1;				\
	  }							\
	else if (!sjis_p					\
		 && (charset_alt == charset_big5_1		\
		     || charset_alt == charset_big5_2))		\
	  {							\
	    unsigned char b1, b2;				\
	    							\
	    ENCODE_BIG5 (charset_alt, c1, c2, b1, b2);		\
	    *dst++ = b1, *dst++ = b2;				\
	  }							\
	else							\
	  {							\
	    *dst++ = charset_alt, *dst++ = c1, *dst++ = c2;	\
	    coding->fake_multibyte = 1;				\
	  }							\
      }								\
    coding->consumed_char++;					\
  } while (0);

/* See the above "GENERAL NOTES on `detect_coding_XXX ()' functions".
   Check if a text is encoded in SJIS.  If it is, return
   CODING_CATEGORY_MASK_SJIS, else return 0.  */

int
detect_coding_sjis (src, src_end)
     unsigned char *src, *src_end;
{
  unsigned char c;

  while (src < src_end)
    {
      c = *src++;
      if ((c >= 0x80 && c < 0xA0) || c >= 0xE0)
	{
	  if (src < src_end && *src++ < 0x40)
	    return 0;
	}
    }
  return CODING_CATEGORY_MASK_SJIS;
}

/* See the above "GENERAL NOTES on `detect_coding_XXX ()' functions".
   Check if a text is encoded in BIG5.  If it is, return
   CODING_CATEGORY_MASK_BIG5, else return 0.  */

int
detect_coding_big5 (src, src_end)
     unsigned char *src, *src_end;
{
  unsigned char c;

  while (src < src_end)
    {
      c = *src++;
      if (c >= 0xA1)
	{
	  if (src >= src_end)
	    break;
	  c = *src++;
	  if (c < 0x40 || (c >= 0x7F && c <= 0xA0))
	    return 0;
	}
    }
  return CODING_CATEGORY_MASK_BIG5;
}

/* See the above "GENERAL NOTES on `decode_coding_XXX ()' functions".
   If SJIS_P is 1, decode SJIS text, else decode BIG5 test.  */

int
decode_coding_sjis_big5 (coding, source, destination,
			 src_bytes, dst_bytes, sjis_p)
     struct coding_system *coding;
     unsigned char *source, *destination;
     int src_bytes, dst_bytes;
     int sjis_p;
{
  unsigned char *src = source;
  unsigned char *src_end = source + src_bytes;
  unsigned char *dst = destination;
  unsigned char *dst_end = destination + dst_bytes;
  /* Since the maximum bytes produced by each loop is 4, we subtract 3
     from DST_END to assure overflow checking is necessary only at the
     head of loop.  */
  unsigned char *adjusted_dst_end = dst_end - 3;
  Lisp_Object translation_table
      = coding->translation_table_for_decode;
  int result = CODING_FINISH_NORMAL;

  if (!NILP (Venable_character_translation) && NILP (translation_table))
    translation_table = Vstandard_translation_table_for_decode;

  coding->produced_char = 0;
  coding->fake_multibyte = 0;
  while (src < src_end && (dst_bytes
			   ? (dst < adjusted_dst_end)
			   : (dst < src - 3)))
    {
      /* SRC_BASE remembers the start position in source in each loop.
	 The loop will be exited when there's not enough source text
	 to analyze two-byte character (within macro ONE_MORE_BYTE).
	 In that case, SRC is reset to SRC_BASE before exiting.  */
      unsigned char *src_base = src;
      unsigned char c1 = *src++, c2, c3, c4;

      if (c1 < 0x20)
	{
	  if (c1 == '\r')
	    {
	      if (coding->eol_type == CODING_EOL_CRLF)
		{
		  ONE_MORE_BYTE (c2);
		  if (c2 == '\n')
		    *dst++ = c2;
		  else if (coding->mode & CODING_MODE_INHIBIT_INCONSISTENT_EOL)
		    {
		      result = CODING_FINISH_INCONSISTENT_EOL;
		      goto label_end_of_loop_2;
		    }
		  else
		    /* To process C2 again, SRC is subtracted by 1.  */
		    *dst++ = c1, src--;
		}
	      else if (coding->eol_type == CODING_EOL_CR)
		*dst++ = '\n';
	      else
		*dst++ = c1;
	    }
	  else if (c1 == '\n'
		   && (coding->mode & CODING_MODE_INHIBIT_INCONSISTENT_EOL)
		   && (coding->eol_type == CODING_EOL_CR
		       || coding->eol_type == CODING_EOL_CRLF))
	    {
	      result = CODING_FINISH_INCONSISTENT_EOL;
	      goto label_end_of_loop_2;
	    }
	  else
	    *dst++ = c1;
	  coding->produced_char++;
	}
      else if (c1 < 0x80)
        {
          c2 = 0;               /* avoid warning */
          DECODE_SJIS_BIG5_CHARACTER (charset_ascii, c1, /* dummy */ c2);
        }
      else
	{
	  if (sjis_p)
	    {
	      if (c1 < 0xA0 || (c1 >= 0xE0 && c1 < 0xF0))
		{
		  /* SJIS -> JISX0208 */
		  ONE_MORE_BYTE (c2);
		  if (c2 >= 0x40 && c2 != 0x7F && c2 <= 0xFC)
		    {
		      DECODE_SJIS (c1, c2, c3, c4);
		      DECODE_SJIS_BIG5_CHARACTER (charset_jisx0208, c3, c4);
		    }
		  else
		    goto label_invalid_code_2;
		}
	      else if (c1 < 0xE0)
		/* SJIS -> JISX0201-Kana */
		{
		  c2 = 0;	/* avoid warning */
		  DECODE_SJIS_BIG5_CHARACTER (charset_katakana_jisx0201, c1,
					      /* dummy */ c2);
		}
	      else
		goto label_invalid_code_1;
	    }
	  else
	    {
	      /* BIG5 -> Big5 */
	      if (c1 >= 0xA1 && c1 <= 0xFE)
		{
		  ONE_MORE_BYTE (c2);
		  if ((c2 >= 0x40 && c2 <= 0x7E) || (c2 >= 0xA1 && c2 <= 0xFE))
		    {
		      int charset;

		      DECODE_BIG5 (c1, c2, charset, c3, c4);
		      DECODE_SJIS_BIG5_CHARACTER (charset, c3, c4);
		    }
		  else
		    goto label_invalid_code_2;
		}
	      else
		goto label_invalid_code_1;
	    }
	}
      continue;

    label_invalid_code_1:
      *dst++ = c1;
      coding->produced_char++;
      coding->fake_multibyte = 1;
      continue;

    label_invalid_code_2:
      *dst++ = c1; *dst++= c2;
      coding->produced_char += 2;
      coding->fake_multibyte = 1;
      continue;

    label_end_of_loop:
      result = CODING_FINISH_INSUFFICIENT_SRC;
    label_end_of_loop_2:
      src = src_base;
      break;
    }

  if (src < src_end)
    {
      if (result == CODING_FINISH_NORMAL)
	result = CODING_FINISH_INSUFFICIENT_DST;
      else if (result != CODING_FINISH_INCONSISTENT_EOL
	       && coding->mode & CODING_MODE_LAST_BLOCK)
	{
	  src_bytes = src_end - src;
	  if (dst_bytes && (dst_end - dst < src_bytes))
	    src_bytes = dst_end - dst;
	  bcopy (dst, src, src_bytes);
	  src += src_bytes;
	  dst += src_bytes;
	  coding->fake_multibyte = 1;
	}
    }

  coding->consumed = coding->consumed_char = src - source;
  coding->produced = dst - destination;
  return result;
}

/* See the above "GENERAL NOTES on `encode_coding_XXX ()' functions".
   This function can encode `charset_ascii', `charset_katakana_jisx0201',
   `charset_jisx0208', `charset_big5_1', and `charset_big5-2'.  We are
   sure that all these charsets are registered as official charset
   (i.e. do not have extended leading-codes).  Characters of other
   charsets are produced without any encoding.  If SJIS_P is 1, encode
   SJIS text, else encode BIG5 text.  */

int
encode_coding_sjis_big5 (coding, source, destination,
			 src_bytes, dst_bytes, sjis_p)
     struct coding_system *coding;
     unsigned char *source, *destination;
     int src_bytes, dst_bytes;
     int sjis_p;
{
  unsigned char *src = source;
  unsigned char *src_end = source + src_bytes;
  unsigned char *dst = destination;
  unsigned char *dst_end = destination + dst_bytes;
  /* Since the maximum bytes produced by each loop is 2, we subtract 1
     from DST_END to assure overflow checking is necessary only at the
     head of loop.  */
  unsigned char *adjusted_dst_end = dst_end - 1;
  Lisp_Object translation_table
      = coding->translation_table_for_encode;
  int result = CODING_FINISH_NORMAL;

  if (!NILP (Venable_character_translation) && NILP (translation_table))
    translation_table = Vstandard_translation_table_for_encode;

  coding->consumed_char = 0;
  coding->fake_multibyte = 0;
  while (src < src_end && (dst_bytes
			   ? (dst < adjusted_dst_end)
			   : (dst < src - 1)))
    {
      /* SRC_BASE remembers the start position in source in each loop.
	 The loop will be exited when there's not enough source text
	 to analyze multi-byte codes (within macros ONE_MORE_BYTE and
	 TWO_MORE_BYTES).  In that case, SRC is reset to SRC_BASE
	 before exiting.  */
      unsigned char *src_base = src;
      unsigned char c1 = *src++, c2, c3, c4;

      if (coding->composing)
	{
	  if (c1 == 0xA0)
	    {
	      ONE_MORE_BYTE (c1);
	      c1 &= 0x7F;
	    }
	  else if (c1 >= 0xA0)
	    c1 -= 0x20;
	  else
	    coding->composing = 0;
	}

      switch (emacs_code_class[c1])
	{
	case EMACS_ascii_code:
	  ENCODE_SJIS_BIG5_CHARACTER (charset_ascii, c1, /* dummy */ c2);
	  break;

	case EMACS_control_code:
	  *dst++ = c1;
	  coding->consumed_char++;
	  break;

	case EMACS_carriage_return_code:
	  if (! (coding->mode & CODING_MODE_SELECTIVE_DISPLAY))
	    {
	      *dst++ = c1;
	      coding->consumed_char++;
	      break;
	    }
	  /* fall down to treat '\r' as '\n' ...  */

	case EMACS_linefeed_code:
	  if (coding->eol_type == CODING_EOL_LF
	      || coding->eol_type == CODING_EOL_UNDECIDED)
	    *dst++ = '\n';
	  else if (coding->eol_type == CODING_EOL_CRLF)
	    *dst++ = '\r', *dst++ = '\n';
	  else
	    *dst++ = '\r';
	  coding->consumed_char++;
	  break;

	case EMACS_leading_code_2:
	  ONE_MORE_BYTE (c2);
	  ENCODE_SJIS_BIG5_CHARACTER (c1, c2, /* dummy */ c3);
	  break;

	case EMACS_leading_code_3:
	  TWO_MORE_BYTES (c2, c3);
	  ENCODE_SJIS_BIG5_CHARACTER (c1, c2, c3);
	  break;

	case EMACS_leading_code_4:
	  THREE_MORE_BYTES (c2, c3, c4);
	  ENCODE_SJIS_BIG5_CHARACTER (c2, c3, c4);
	  break;

	case EMACS_leading_code_composition:
	  coding->composing = 1;
	  break;

	default:		/* i.e. case EMACS_invalid_code: */
	  *dst++ = c1;
	  coding->consumed_char++;
	}
      continue;

    label_end_of_loop:
      result = CODING_FINISH_INSUFFICIENT_SRC;
      src = src_base;
      break;
    }

  if (result == CODING_FINISH_NORMAL
      && src < src_end)
    result = CODING_FINISH_INSUFFICIENT_DST;
  coding->consumed = src - source;
  coding->produced = coding->produced_char = dst - destination;
  return result;
}


/*** 5. CCL handlers ***/

/* See the above "GENERAL NOTES on `detect_coding_XXX ()' functions".
   Check if a text is encoded in a coding system of which
   encoder/decoder are written in CCL program.  If it is, return
   CODING_CATEGORY_MASK_CCL, else return 0.  */

int
detect_coding_ccl (src, src_end)
     unsigned char *src, *src_end;
{
  unsigned char *valid;

  /* No coding system is assigned to coding-category-ccl.  */
  if (!coding_system_table[CODING_CATEGORY_IDX_CCL])
    return 0;

  valid = coding_system_table[CODING_CATEGORY_IDX_CCL]->spec.ccl.valid_codes;
  while (src < src_end)
    {
      if (! valid[*src]) return 0;
      src++;
    }
  return CODING_CATEGORY_MASK_CCL;
}


/*** 6. End-of-line handlers ***/

/* See the above "GENERAL NOTES on `decode_coding_XXX ()' functions".
   This function is called only when `coding->eol_type' is
   CODING_EOL_CRLF or CODING_EOL_CR.  */

int
decode_eol (coding, source, destination, src_bytes, dst_bytes)
     struct coding_system *coding;
     unsigned char *source, *destination;
     int src_bytes, dst_bytes;
{
  unsigned char *src = source;
  unsigned char *src_end = source + src_bytes;
  unsigned char *dst = destination;
  unsigned char *dst_end = destination + dst_bytes;
  unsigned char c;
  int result = CODING_FINISH_NORMAL;

  coding->fake_multibyte = 0;

  if (src_bytes <= 0)
    {
      coding->produced = coding->produced_char = 0;
      coding->consumed = coding->consumed_char = 0;
      return result;
    }

  switch (coding->eol_type)
    {
    case CODING_EOL_CRLF:
      {
	/* Since the maximum bytes produced by each loop is 2, we
	   subtract 1 from DST_END to assure overflow checking is
	   necessary only at the head of loop.  */
	unsigned char *adjusted_dst_end = dst_end - 1;

	while (src < src_end && (dst_bytes
				 ? (dst < adjusted_dst_end)
				 : (dst < src - 1)))
	  {
	    unsigned char *src_base = src;

	    c = *src++;
	    if (c == '\r')
	      {
		ONE_MORE_BYTE (c);
		if (c == '\n')
		  *dst++ = c;
		else
		  {
		    if (coding->mode & CODING_MODE_INHIBIT_INCONSISTENT_EOL)
		      {
			result = CODING_FINISH_INCONSISTENT_EOL;
			goto label_end_of_loop_2;
		      }
		    src--;
		    *dst++ = '\r';
		    if (BASE_LEADING_CODE_P (c))
		      coding->fake_multibyte = 1;
		  }
	      }
	    else if (c == '\n'
		     && (coding->mode & CODING_MODE_INHIBIT_INCONSISTENT_EOL))
	      {
		result = CODING_FINISH_INCONSISTENT_EOL;
		goto label_end_of_loop_2;
	      }
	    else
	      {
		*dst++ = c;
		if (BASE_LEADING_CODE_P (c))
		  coding->fake_multibyte = 1;
	      }
	    continue;

	  label_end_of_loop:
	    result = CODING_FINISH_INSUFFICIENT_SRC;
	  label_end_of_loop_2:
	    src = src_base;
	    break;
	  }
	if (src < src_end)
	  {
	    if (result == CODING_FINISH_NORMAL)
	      result = CODING_FINISH_INSUFFICIENT_DST;
	    else if (result != CODING_FINISH_INCONSISTENT_EOL
		     && coding->mode & CODING_MODE_LAST_BLOCK)
	      {
		/* This is the last block of the text to be decoded.
		   We flush out all remaining codes.  */
		src_bytes = src_end - src;
		if (dst_bytes && (dst_end - dst < src_bytes))
		  src_bytes = dst_end - dst;
		bcopy (src, dst, src_bytes);
		dst += src_bytes;
		src += src_bytes;
	      }
	  }
      }
      break;

    case CODING_EOL_CR:
      if (coding->mode & CODING_MODE_INHIBIT_INCONSISTENT_EOL)
	{
	  while (src < src_end)
	    {
	      if ((c = *src++) == '\n')
		break;
	      if (BASE_LEADING_CODE_P (c))
		coding->fake_multibyte = 1;
	    }
	  if (*--src == '\n')
	    {
	      src_bytes = src - source;
	      result = CODING_FINISH_INCONSISTENT_EOL;
	    }
	}
      if (dst_bytes && src_bytes > dst_bytes)
	{
	  result = CODING_FINISH_INSUFFICIENT_DST;
	  src_bytes = dst_bytes;
	}
      if (dst_bytes)
	bcopy (source, destination, src_bytes);
      else
	safe_bcopy (source, destination, src_bytes);
      src = source + src_bytes;
      while (src_bytes--) if (*dst++ == '\r') dst[-1] = '\n';
      break;

    default:			/* i.e. case: CODING_EOL_LF */
      if (dst_bytes && src_bytes > dst_bytes)
	{
	  result = CODING_FINISH_INSUFFICIENT_DST;
	  src_bytes = dst_bytes;
	}
      if (dst_bytes)
	bcopy (source, destination, src_bytes);
      else
	safe_bcopy (source, destination, src_bytes);
      src += src_bytes;
      dst += src_bytes;
      coding->fake_multibyte = 1;
      break;
    }

  coding->consumed = coding->consumed_char = src - source;
  coding->produced = coding->produced_char = dst - destination;
  return result;
}

/* See "GENERAL NOTES about `encode_coding_XXX ()' functions".  Encode
   format of end-of-line according to `coding->eol_type'.  If
   `coding->mode & CODING_MODE_SELECTIVE_DISPLAY' is nonzero, code
   '\r' in source text also means end-of-line.  */

int
encode_eol (coding, source, destination, src_bytes, dst_bytes)
     struct coding_system *coding;
     unsigned char *source, *destination;
     int src_bytes, dst_bytes;
{
  unsigned char *src = source;
  unsigned char *dst = destination;
  int result = CODING_FINISH_NORMAL;

  coding->fake_multibyte = 0;

  if (coding->eol_type == CODING_EOL_CRLF)
    {
      unsigned char c;
      unsigned char *src_end = source + src_bytes;
      unsigned char *dst_end = destination + dst_bytes;
      /* Since the maximum bytes produced by each loop is 2, we
	 subtract 1 from DST_END to assure overflow checking is
	 necessary only at the head of loop.  */
      unsigned char *adjusted_dst_end = dst_end - 1;

      while (src < src_end && (dst_bytes
			       ? (dst < adjusted_dst_end)
			       : (dst < src - 1)))
	{
	  c = *src++;
	  if (c == '\n'
	      || (c == '\r' && (coding->mode & CODING_MODE_SELECTIVE_DISPLAY)))
	    *dst++ = '\r', *dst++ = '\n';
	  else
	    {
	      *dst++ = c;
	      if (BASE_LEADING_CODE_P (c))
		coding->fake_multibyte = 1;
	    }
	}
      if (src < src_end)
	result = CODING_FINISH_INSUFFICIENT_DST;
    }
  else
    {
      unsigned char c;

      if (dst_bytes && src_bytes > dst_bytes)
	{
	  src_bytes = dst_bytes;
	  result = CODING_FINISH_INSUFFICIENT_DST;
	}
      if (dst_bytes)
	bcopy (source, destination, src_bytes);
      else
	safe_bcopy (source, destination, src_bytes);
      dst_bytes = src_bytes;
      if (coding->eol_type == CODING_EOL_CR)
	{
	  while (src_bytes--)
	    {
	      if ((c = *dst++) == '\n')
		dst[-1] = '\r';
	      else if (BASE_LEADING_CODE_P (c))
		coding->fake_multibyte = 1;
	    }
	}
      else
	{
	  if (coding->mode & CODING_MODE_SELECTIVE_DISPLAY)
	    {
	      while (src_bytes--)
		if (*dst++ == '\r') dst[-1] = '\n';
	    }
	  coding->fake_multibyte = 1;
	}
      src = source + dst_bytes;
      dst = destination + dst_bytes;
    }

  coding->consumed = coding->consumed_char = src - source;
  coding->produced = coding->produced_char = dst - destination;
  return result;
}


/*** 7. C library functions ***/

/* In Emacs Lisp, coding system is represented by a Lisp symbol which
   has a property `coding-system'.  The value of this property is a
   vector of length 5 (called as coding-vector).  Among elements of
   this vector, the first (element[0]) and the fifth (element[4])
   carry important information for decoding/encoding.  Before
   decoding/encoding, this information should be set in fields of a
   structure of type `coding_system'.

   A value of property `coding-system' can be a symbol of another
   subsidiary coding-system.  In that case, Emacs gets coding-vector
   from that symbol.

   `element[0]' contains information to be set in `coding->type'.  The
   value and its meaning is as follows:

   0 -- coding_type_emacs_mule
   1 -- coding_type_sjis
   2 -- coding_type_iso2022
   3 -- coding_type_big5
   4 -- coding_type_ccl encoder/decoder written in CCL
   nil -- coding_type_no_conversion
   t -- coding_type_undecided (automatic conversion on decoding,
   			       no-conversion on encoding)

   `element[4]' contains information to be set in `coding->flags' and
   `coding->spec'.  The meaning varies by `coding->type'.

   If `coding->type' is `coding_type_iso2022', element[4] is a vector
   of length 32 (of which the first 13 sub-elements are used now).
   Meanings of these sub-elements are:

   sub-element[N] where N is 0 through 3: to be set in `coding->spec.iso2022'
   	If the value is an integer of valid charset, the charset is
	assumed to be designated to graphic register N initially.

	If the value is minus, it is a minus value of charset which
	reserves graphic register N, which means that the charset is
	not designated initially but should be designated to graphic
	register N just before encoding a character in that charset.

	If the value is nil, graphic register N is never used on
	encoding.
   
   sub-element[N] where N is 4 through 11: to be set in `coding->flags'
   	Each value takes t or nil.  See the section ISO2022 of
	`coding.h' for more information.

   If `coding->type' is `coding_type_big5', element[4] is t to denote
   BIG5-ETen or nil to denote BIG5-HKU.

   If `coding->type' takes the other value, element[4] is ignored.

   Emacs Lisp's coding system also carries information about format of
   end-of-line in a value of property `eol-type'.  If the value is
   integer, 0 means CODING_EOL_LF, 1 means CODING_EOL_CRLF, and 2
   means CODING_EOL_CR.  If it is not integer, it should be a vector
   of subsidiary coding systems of which property `eol-type' has one
   of above values.

*/

/* Extract information for decoding/encoding from CODING_SYSTEM_SYMBOL
   and set it in CODING.  If CODING_SYSTEM_SYMBOL is invalid, CODING
   is setup so that no conversion is necessary and return -1, else
   return 0.  */

int
setup_coding_system (coding_system, coding)
     Lisp_Object coding_system;
     struct coding_system *coding;
{
  Lisp_Object coding_spec, coding_type, eol_type, plist;
  Lisp_Object val;
  int i;

  /* Initialize some fields required for all kinds of coding systems.  */
  coding->symbol = coding_system;
  coding->common_flags = 0;
  coding->mode = 0;
  coding->heading_ascii = -1;
  coding->post_read_conversion = coding->pre_write_conversion = Qnil;

  if (NILP (coding_system))
    goto label_invalid_coding_system;

  coding_spec = Fget (coding_system, Qcoding_system);

  if (!VECTORP (coding_spec)
      || XVECTOR (coding_spec)->size != 5
      || !CONSP (XVECTOR (coding_spec)->contents[3]))
    goto label_invalid_coding_system;

  eol_type = inhibit_eol_conversion ? Qnil : Fget (coding_system, Qeol_type);
  if (VECTORP (eol_type))
    {
      coding->eol_type = CODING_EOL_UNDECIDED;
      coding->common_flags = CODING_REQUIRE_DETECTION_MASK;
    }
  else if (XFASTINT (eol_type) == 1)
    {
      coding->eol_type = CODING_EOL_CRLF;
      coding->common_flags
	= CODING_REQUIRE_DECODING_MASK | CODING_REQUIRE_ENCODING_MASK;
    }
  else if (XFASTINT (eol_type) == 2)
    {
      coding->eol_type = CODING_EOL_CR;
      coding->common_flags
	= CODING_REQUIRE_DECODING_MASK | CODING_REQUIRE_ENCODING_MASK;
    }
  else
    coding->eol_type = CODING_EOL_LF;

  coding_type = XVECTOR (coding_spec)->contents[0];
  /* Try short cut.  */
  if (SYMBOLP (coding_type))
    {
      if (EQ (coding_type, Qt))
	{
	  coding->type = coding_type_undecided;
	  coding->common_flags |= CODING_REQUIRE_DETECTION_MASK;
	}
      else
	coding->type = coding_type_no_conversion;
      return 0;
    }

  /* Initialize remaining fields.  */
  coding->composing = 0;
  coding->composed_chars = 0;

  /* Get values of coding system properties:
     `post-read-conversion', `pre-write-conversion',
     `translation-table-for-decode', `translation-table-for-encode'.  */
  plist = XVECTOR (coding_spec)->contents[3];
  coding->post_read_conversion = Fplist_get (plist, Qpost_read_conversion);
  coding->pre_write_conversion = Fplist_get (plist, Qpre_write_conversion);
  val = Fplist_get (plist, Qtranslation_table_for_decode);
  if (SYMBOLP (val))
    val = Fget (val, Qtranslation_table_for_decode);
  coding->translation_table_for_decode = CHAR_TABLE_P (val) ? val : Qnil;
  val = Fplist_get (plist, Qtranslation_table_for_encode);
  if (SYMBOLP (val))
    val = Fget (val, Qtranslation_table_for_encode);
  coding->translation_table_for_encode = CHAR_TABLE_P (val) ? val : Qnil;
  val = Fplist_get (plist, Qcoding_category);
  if (!NILP (val))
    {
      val = Fget (val, Qcoding_category_index);
      if (INTEGERP (val))
	coding->category_idx = XINT (val);
      else
	goto label_invalid_coding_system;
    }
  else
    goto label_invalid_coding_system;
  
  val = Fplist_get (plist, Qsafe_charsets);
  if (EQ (val, Qt))
    {
      for (i = 0; i <= MAX_CHARSET; i++)
	coding->safe_charsets[i] = 1;
    }
  else
    {
      bzero (coding->safe_charsets, MAX_CHARSET + 1);
      while (CONSP (val))
	{
	  if ((i = get_charset_id (XCONS (val)->car)) >= 0)
	    coding->safe_charsets[i] = 1;
	  val = XCONS (val)->cdr;
	}
    }

  switch (XFASTINT (coding_type))
    {
    case 0:
      coding->type = coding_type_emacs_mule;
      if (!NILP (coding->post_read_conversion))
	coding->common_flags |= CODING_REQUIRE_DECODING_MASK;
      if (!NILP (coding->pre_write_conversion))
	coding->common_flags |= CODING_REQUIRE_ENCODING_MASK;
      break;

    case 1:
      coding->type = coding_type_sjis;
      coding->common_flags
	|= CODING_REQUIRE_DECODING_MASK | CODING_REQUIRE_ENCODING_MASK;
      break;

    case 2:
      coding->type = coding_type_iso2022;
      coding->common_flags
	|= CODING_REQUIRE_DECODING_MASK | CODING_REQUIRE_ENCODING_MASK;
      {
	Lisp_Object val, temp;
	Lisp_Object *flags;
	int i, charset, reg_bits = 0;

	val = XVECTOR (coding_spec)->contents[4];

	if (!VECTORP (val) || XVECTOR (val)->size != 32)
	  goto label_invalid_coding_system;

	flags = XVECTOR (val)->contents;
	coding->flags
	  = ((NILP (flags[4]) ? 0 : CODING_FLAG_ISO_SHORT_FORM)
	     | (NILP (flags[5]) ? 0 : CODING_FLAG_ISO_RESET_AT_EOL)
	     | (NILP (flags[6]) ? 0 : CODING_FLAG_ISO_RESET_AT_CNTL)
	     | (NILP (flags[7]) ? 0 : CODING_FLAG_ISO_SEVEN_BITS)
	     | (NILP (flags[8]) ? 0 : CODING_FLAG_ISO_LOCKING_SHIFT)
	     | (NILP (flags[9]) ? 0 : CODING_FLAG_ISO_SINGLE_SHIFT)
	     | (NILP (flags[10]) ? 0 : CODING_FLAG_ISO_USE_ROMAN)
	     | (NILP (flags[11]) ? 0 : CODING_FLAG_ISO_USE_OLDJIS)
	     | (NILP (flags[12]) ? 0 : CODING_FLAG_ISO_NO_DIRECTION)
	     | (NILP (flags[13]) ? 0 : CODING_FLAG_ISO_INIT_AT_BOL)
	     | (NILP (flags[14]) ? 0 : CODING_FLAG_ISO_DESIGNATE_AT_BOL)
	     | (NILP (flags[15]) ? 0 : CODING_FLAG_ISO_SAFE)
	     | (NILP (flags[16]) ? 0 : CODING_FLAG_ISO_LATIN_EXTRA)
	     );

	/* Invoke graphic register 0 to plane 0.  */
	CODING_SPEC_ISO_INVOCATION (coding, 0) = 0;
	/* Invoke graphic register 1 to plane 1 if we can use full 8-bit.  */
	CODING_SPEC_ISO_INVOCATION (coding, 1)
	  = (coding->flags & CODING_FLAG_ISO_SEVEN_BITS ? -1 : 1);
	/* Not single shifting at first.  */
	CODING_SPEC_ISO_SINGLE_SHIFTING (coding) = 0;
	/* Beginning of buffer should also be regarded as bol. */
	CODING_SPEC_ISO_BOL (coding) = 1;

	for (charset = 0; charset <= MAX_CHARSET; charset++)
	  CODING_SPEC_ISO_REVISION_NUMBER (coding, charset) = 255;
	val = Vcharset_revision_alist;
	while (CONSP (val))
	  {
	    charset = get_charset_id (Fcar_safe (XCONS (val)->car));
	    if (charset >= 0
		&& (temp = Fcdr_safe (XCONS (val)->car), INTEGERP (temp))
		&& (i = XINT (temp), (i >= 0 && (i + '@') < 128)))
	      CODING_SPEC_ISO_REVISION_NUMBER (coding, charset) = i;
	    val = XCONS (val)->cdr;
	  }

	/* Checks FLAGS[REG] (REG = 0, 1, 2 3) and decide designations.
	   FLAGS[REG] can be one of below:
		integer CHARSET: CHARSET occupies register I,
		t: designate nothing to REG initially, but can be used
		  by any charsets,
		list of integer, nil, or t: designate the first
		  element (if integer) to REG initially, the remaining
		  elements (if integer) is designated to REG on request,
		  if an element is t, REG can be used by any charsets,
		nil: REG is never used.  */
	for (charset = 0; charset <= MAX_CHARSET; charset++)
	  CODING_SPEC_ISO_REQUESTED_DESIGNATION (coding, charset)
	    = CODING_SPEC_ISO_NO_REQUESTED_DESIGNATION;
	for (i = 0; i < 4; i++)
	  {
	    if (INTEGERP (flags[i])
		&& (charset = XINT (flags[i]), CHARSET_VALID_P (charset))
		|| (charset = get_charset_id (flags[i])) >= 0)
	      {
		CODING_SPEC_ISO_INITIAL_DESIGNATION (coding, i) = charset;
		CODING_SPEC_ISO_REQUESTED_DESIGNATION (coding, charset) = i;
	      }
	    else if (EQ (flags[i], Qt))
	      {
		CODING_SPEC_ISO_INITIAL_DESIGNATION (coding, i) = -1;
		reg_bits |= 1 << i;
		coding->flags |= CODING_FLAG_ISO_DESIGNATION;
	      }
	    else if (CONSP (flags[i]))
	      {
		Lisp_Object tail;
		tail = flags[i];

		coding->flags |= CODING_FLAG_ISO_DESIGNATION;
		if (INTEGERP (XCONS (tail)->car)
		    && (charset = XINT (XCONS (tail)->car),
			CHARSET_VALID_P (charset))
		    || (charset = get_charset_id (XCONS (tail)->car)) >= 0)
		  {
		    CODING_SPEC_ISO_INITIAL_DESIGNATION (coding, i) = charset;
		    CODING_SPEC_ISO_REQUESTED_DESIGNATION (coding, charset) =i;
		  }
		else
		  CODING_SPEC_ISO_INITIAL_DESIGNATION (coding, i) = -1;
		tail = XCONS (tail)->cdr;
		while (CONSP (tail))
		  {
		    if (INTEGERP (XCONS (tail)->car)
			&& (charset = XINT (XCONS (tail)->car),
			    CHARSET_VALID_P (charset))
			|| (charset = get_charset_id (XCONS (tail)->car)) >= 0)
		      CODING_SPEC_ISO_REQUESTED_DESIGNATION (coding, charset)
			= i;
		    else if (EQ (XCONS (tail)->car, Qt))
		      reg_bits |= 1 << i;
		    tail = XCONS (tail)->cdr;
		  }
	      }
	    else
	      CODING_SPEC_ISO_INITIAL_DESIGNATION (coding, i) = -1;
	    
	    CODING_SPEC_ISO_DESIGNATION (coding, i)
	      = CODING_SPEC_ISO_INITIAL_DESIGNATION (coding, i);
	  }

	if (reg_bits && ! (coding->flags & CODING_FLAG_ISO_LOCKING_SHIFT))
	  {
	    /* REG 1 can be used only by locking shift in 7-bit env.  */
	    if (coding->flags & CODING_FLAG_ISO_SEVEN_BITS)
	      reg_bits &= ~2;
	    if (! (coding->flags & CODING_FLAG_ISO_SINGLE_SHIFT))
	      /* Without any shifting, only REG 0 and 1 can be used.  */
	      reg_bits &= 3;
	  }

	if (reg_bits)
	  for (charset = 0; charset <= MAX_CHARSET; charset++)
	    {
	      if (CHARSET_VALID_P (charset))
		{
		  /* There exist some default graphic registers to be
		     used CHARSET.  */

		  /* We had better avoid designating a charset of
		     CHARS96 to REG 0 as far as possible.  */
		  if (CHARSET_CHARS (charset) == 96)
		    CODING_SPEC_ISO_REQUESTED_DESIGNATION (coding, charset)
		      = (reg_bits & 2
			 ? 1 : (reg_bits & 4 ? 2 : (reg_bits & 8 ? 3 : 0)));
		  else
		    CODING_SPEC_ISO_REQUESTED_DESIGNATION (coding, charset)
		      = (reg_bits & 1
			 ? 0 : (reg_bits & 2 ? 1 : (reg_bits & 4 ? 2 : 3)));
		}
	    }
      }
      coding->common_flags |= CODING_REQUIRE_FLUSHING_MASK;
      coding->spec.iso2022.last_invalid_designation_register = -1;
      break;

    case 3:
      coding->type = coding_type_big5;
      coding->common_flags
	|= CODING_REQUIRE_DECODING_MASK | CODING_REQUIRE_ENCODING_MASK;
      coding->flags
	= (NILP (XVECTOR (coding_spec)->contents[4])
	   ? CODING_FLAG_BIG5_HKU
	   : CODING_FLAG_BIG5_ETEN);
      break;

    case 4:
      coding->type = coding_type_ccl;
      coding->common_flags
	|= CODING_REQUIRE_DECODING_MASK | CODING_REQUIRE_ENCODING_MASK;
      {
	Lisp_Object val;
	Lisp_Object decoder, encoder;

	val = XVECTOR (coding_spec)->contents[4];
	if (CONSP  (val)
	    && SYMBOLP (XCONS (val)->car)
	    && !NILP (decoder = Fget (XCONS (val)->car, Qccl_program_idx))
	    && !NILP (decoder = Fcdr (Faref (Vccl_program_table, decoder)))
	    && SYMBOLP (XCONS (val)->cdr)
	    && !NILP (encoder = Fget (XCONS (val)->cdr, Qccl_program_idx))
	    && !NILP (encoder = Fcdr (Faref (Vccl_program_table, encoder))))
	  {
	    setup_ccl_program (&(coding->spec.ccl.decoder), decoder);
	    setup_ccl_program (&(coding->spec.ccl.encoder), encoder);
	  }
	else
	  goto label_invalid_coding_system;

	bzero (coding->spec.ccl.valid_codes, 256);
	val = Fplist_get (plist, Qvalid_codes);
	if (CONSP (val))
	  {
	    Lisp_Object this;

	    for (; CONSP (val); val = XCONS (val)->cdr)
	      {
		this = XCONS (val)->car;
		if (INTEGERP (this)
		    && XINT (this) >= 0 && XINT (this) < 256)
		  coding->spec.ccl.valid_codes[XINT (this)] = 1;
		else if (CONSP (this)
			 && INTEGERP (XCONS (this)->car)
			 && INTEGERP (XCONS (this)->cdr))
		  {
		    int start = XINT (XCONS (this)->car);
		    int end = XINT (XCONS (this)->cdr);

		    if (start >= 0 && start <= end && end < 256)
		      while (start <= end)
			coding->spec.ccl.valid_codes[start++] = 1;
		  }
	      }
	  }
      }
      coding->common_flags |= CODING_REQUIRE_FLUSHING_MASK;
      break;

    case 5:
      coding->type = coding_type_raw_text;
      break;

    default:
      goto label_invalid_coding_system;
    }
  return 0;

 label_invalid_coding_system:
  coding->type = coding_type_no_conversion;
  coding->category_idx = CODING_CATEGORY_IDX_BINARY;
  coding->common_flags = 0;
  coding->eol_type = CODING_EOL_LF;
  coding->pre_write_conversion = coding->post_read_conversion = Qnil;
  return -1;
}

/* Setup raw-text or one of its subsidiaries in the structure
   coding_system CODING according to the already setup value eol_type
   in CODING.  CODING should be setup for some coding system in
   advance.  */

void
setup_raw_text_coding_system (coding)
     struct coding_system *coding;
{
  if (coding->type != coding_type_raw_text)
    {
      coding->symbol = Qraw_text;
      coding->type = coding_type_raw_text;
      if (coding->eol_type != CODING_EOL_UNDECIDED)
	{
	  Lisp_Object subsidiaries;
	  subsidiaries = Fget (Qraw_text, Qeol_type);

	  if (VECTORP (subsidiaries)
	      && XVECTOR (subsidiaries)->size == 3)
	    coding->symbol
	      = XVECTOR (subsidiaries)->contents[coding->eol_type];
	}
      setup_coding_system (coding->symbol, coding);
    }
  return;
}

/* Emacs has a mechanism to automatically detect a coding system if it
   is one of Emacs' internal format, ISO2022, SJIS, and BIG5.  But,
   it's impossible to distinguish some coding systems accurately
   because they use the same range of codes.  So, at first, coding
   systems are categorized into 7, those are:

   o coding-category-emacs-mule

   	The category for a coding system which has the same code range
	as Emacs' internal format.  Assigned the coding-system (Lisp
	symbol) `emacs-mule' by default.

   o coding-category-sjis

	The category for a coding system which has the same code range
	as SJIS.  Assigned the coding-system (Lisp
	symbol) `japanese-shift-jis' by default.

   o coding-category-iso-7

   	The category for a coding system which has the same code range
	as ISO2022 of 7-bit environment.  This doesn't use any locking
	shift and single shift functions.  This can encode/decode all
	charsets.  Assigned the coding-system (Lisp symbol)
	`iso-2022-7bit' by default.

   o coding-category-iso-7-tight

	Same as coding-category-iso-7 except that this can
	encode/decode only the specified charsets.

   o coding-category-iso-8-1

   	The category for a coding system which has the same code range
	as ISO2022 of 8-bit environment and graphic plane 1 used only
	for DIMENSION1 charset.  This doesn't use any locking shift
	and single shift functions.  Assigned the coding-system (Lisp
	symbol) `iso-latin-1' by default.

   o coding-category-iso-8-2

   	The category for a coding system which has the same code range
	as ISO2022 of 8-bit environment and graphic plane 1 used only
	for DIMENSION2 charset.  This doesn't use any locking shift
	and single shift functions.  Assigned the coding-system (Lisp
	symbol) `japanese-iso-8bit' by default.

   o coding-category-iso-7-else

   	The category for a coding system which has the same code range
	as ISO2022 of 7-bit environemnt but uses locking shift or
	single shift functions.  Assigned the coding-system (Lisp
	symbol) `iso-2022-7bit-lock' by default.

   o coding-category-iso-8-else

   	The category for a coding system which has the same code range
	as ISO2022 of 8-bit environemnt but uses locking shift or
	single shift functions.  Assigned the coding-system (Lisp
	symbol) `iso-2022-8bit-ss2' by default.

   o coding-category-big5

   	The category for a coding system which has the same code range
	as BIG5.  Assigned the coding-system (Lisp symbol)
	`cn-big5' by default.

   o coding-category-ccl

	The category for a coding system of which encoder/decoder is
	written in CCL programs.  The default value is nil, i.e., no
	coding system is assigned.

   o coding-category-binary

   	The category for a coding system not categorized in any of the
	above.  Assigned the coding-system (Lisp symbol)
	`no-conversion' by default.

   Each of them is a Lisp symbol and the value is an actual
   `coding-system's (this is also a Lisp symbol) assigned by a user.
   What Emacs does actually is to detect a category of coding system.
   Then, it uses a `coding-system' assigned to it.  If Emacs can't
   decide only one possible category, it selects a category of the
   highest priority.  Priorities of categories are also specified by a
   user in a Lisp variable `coding-category-list'.

*/

static
int ascii_skip_code[256];

/* Detect how a text of length SRC_BYTES pointed by SOURCE is encoded.
   If it detects possible coding systems, return an integer in which
   appropriate flag bits are set.  Flag bits are defined by macros
   CODING_CATEGORY_MASK_XXX in `coding.h'.

   How many ASCII characters are at the head is returned as *SKIP.  */

static int
detect_coding_mask (source, src_bytes, priorities, skip)
     unsigned char *source;
     int src_bytes, *priorities, *skip;
{
  register unsigned char c;
  unsigned char *src = source, *src_end = source + src_bytes;
  unsigned int mask;
  int i;

  /* At first, skip all ASCII characters and control characters except
     for three ISO2022 specific control characters.  */
  ascii_skip_code[ISO_CODE_SO] = 0;
  ascii_skip_code[ISO_CODE_SI] = 0;
  ascii_skip_code[ISO_CODE_ESC] = 0;

 label_loop_detect_coding:
  while (src < src_end && ascii_skip_code[*src]) src++;
  *skip = src - source;

  if (src >= src_end)
    /* We found nothing other than ASCII.  There's nothing to do.  */
    return 0;

  c = *src;
  /* The text seems to be encoded in some multilingual coding system.
     Now, try to find in which coding system the text is encoded.  */
  if (c < 0x80)
    {
      /* i.e. (c == ISO_CODE_ESC || c == ISO_CODE_SI || c == ISO_CODE_SO) */
      /* C is an ISO2022 specific control code of C0.  */
      mask = detect_coding_iso2022 (src, src_end);
      if (mask == 0)
	{
	  /* No valid ISO2022 code follows C.  Try again.  */
	  src++;
	  if (c == ISO_CODE_ESC)
	    ascii_skip_code[ISO_CODE_ESC] = 1;
	  else
	    ascii_skip_code[ISO_CODE_SO] = ascii_skip_code[ISO_CODE_SI] = 1;
	  goto label_loop_detect_coding;
	}
      if (priorities)
	goto label_return_highest_only;
    }
  else
    {
      int try;

      if (c < 0xA0)
	{
	  /* C is the first byte of SJIS character code,
	     or a leading-code of Emacs' internal format (emacs-mule).  */
	  try = CODING_CATEGORY_MASK_SJIS | CODING_CATEGORY_MASK_EMACS_MULE;

	  /* Or, if C is a special latin extra code,
	     or is an ISO2022 specific control code of C1 (SS2 or SS3), 
	     or is an ISO2022 control-sequence-introducer (CSI),
	     we should also consider the possibility of ISO2022 codings.  */
	  if ((VECTORP (Vlatin_extra_code_table)
	       && !NILP (XVECTOR (Vlatin_extra_code_table)->contents[c]))
	      || (c == ISO_CODE_SS2 || c == ISO_CODE_SS3)
	      || (c == ISO_CODE_CSI
		  && (src < src_end
		      && (*src == ']'
			  || ((*src == '0' || *src == '1' || *src == '2')
			      && src + 1 < src_end
			      && src[1] == ']')))))
	    try |= (CODING_CATEGORY_MASK_ISO_8_ELSE
		     | CODING_CATEGORY_MASK_ISO_8BIT);
	}
      else
	/* C is a character of ISO2022 in graphic plane right,
	   or a SJIS's 1-byte character code (i.e. JISX0201),
	   or the first byte of BIG5's 2-byte code.  */
	try = (CODING_CATEGORY_MASK_ISO_8_ELSE
		| CODING_CATEGORY_MASK_ISO_8BIT
		| CODING_CATEGORY_MASK_SJIS
		| CODING_CATEGORY_MASK_BIG5);

      /* Or, we may have to consider the possibility of CCL.  */
      if (coding_system_table[CODING_CATEGORY_IDX_CCL]
	  && (coding_system_table[CODING_CATEGORY_IDX_CCL]
	      ->spec.ccl.valid_codes)[c])
	try |= CODING_CATEGORY_MASK_CCL;

      mask = 0;
      if (priorities)
	{
	  for (i = 0; i < CODING_CATEGORY_IDX_MAX; i++)
	    {
	      if (priorities[i] & try & CODING_CATEGORY_MASK_ISO)
		mask = detect_coding_iso2022 (src, src_end);
	      else if (priorities[i] & try & CODING_CATEGORY_MASK_SJIS)
		mask = detect_coding_sjis (src, src_end);
	      else if (priorities[i] & try & CODING_CATEGORY_MASK_BIG5)
		mask = detect_coding_big5 (src, src_end);      
	      else if (priorities[i] & try & CODING_CATEGORY_MASK_EMACS_MULE)
		mask = detect_coding_emacs_mule (src, src_end);      
	      else if (priorities[i] & try & CODING_CATEGORY_MASK_CCL)
		mask = detect_coding_ccl (src, src_end);
	      else if (priorities[i] & CODING_CATEGORY_MASK_RAW_TEXT)
		mask = CODING_CATEGORY_MASK_RAW_TEXT;
	      else if (priorities[i] & CODING_CATEGORY_MASK_BINARY)
		mask = CODING_CATEGORY_MASK_BINARY;
	      if (mask)
		goto label_return_highest_only;
	    }
	  return CODING_CATEGORY_MASK_RAW_TEXT;
	}
      if (try & CODING_CATEGORY_MASK_ISO)
	mask |= detect_coding_iso2022 (src, src_end);
      if (try & CODING_CATEGORY_MASK_SJIS)
	mask |= detect_coding_sjis (src, src_end);
      if (try & CODING_CATEGORY_MASK_BIG5)
	mask |= detect_coding_big5 (src, src_end);      
      if (try & CODING_CATEGORY_MASK_EMACS_MULE)
	mask |= detect_coding_emacs_mule (src, src_end);
      if (try & CODING_CATEGORY_MASK_CCL)
	mask |= detect_coding_ccl (src, src_end);
    }
  return (mask | CODING_CATEGORY_MASK_RAW_TEXT | CODING_CATEGORY_MASK_BINARY);

 label_return_highest_only:
  for (i = 0; i < CODING_CATEGORY_IDX_MAX; i++)
    {
      if (mask & priorities[i])
	return priorities[i];
    }
  return CODING_CATEGORY_MASK_RAW_TEXT;
}

/* Detect how a text of length SRC_BYTES pointed by SRC is encoded.
   The information of the detected coding system is set in CODING.  */

void
detect_coding (coding, src, src_bytes)
     struct coding_system *coding;
     unsigned char *src;
     int src_bytes;
{
  unsigned int idx;
  int skip, mask, i;
  Lisp_Object val;

  val = Vcoding_category_list;
  mask = detect_coding_mask (src, src_bytes, coding_priorities, &skip);
  coding->heading_ascii = skip;

  if (!mask) return;

  /* We found a single coding system of the highest priority in MASK.  */
  idx = 0;
  while (mask && ! (mask & 1)) mask >>= 1, idx++;
  if (! mask)
    idx = CODING_CATEGORY_IDX_RAW_TEXT;

  val = XSYMBOL (XVECTOR (Vcoding_category_table)->contents[idx])->value;

  if (coding->eol_type != CODING_EOL_UNDECIDED)
    {
      Lisp_Object tmp;

      tmp = Fget (val, Qeol_type);
      if (VECTORP (tmp))
	val = XVECTOR (tmp)->contents[coding->eol_type];
    }
  setup_coding_system (val, coding);
  /* Set this again because setup_coding_system reset this member.  */
  coding->heading_ascii = skip;
}

/* Detect how end-of-line of a text of length SRC_BYTES pointed by
   SOURCE is encoded.  Return one of CODING_EOL_LF, CODING_EOL_CRLF,
   CODING_EOL_CR, and CODING_EOL_UNDECIDED.

   How many non-eol characters are at the head is returned as *SKIP.  */

#define MAX_EOL_CHECK_COUNT 3

static int
detect_eol_type (source, src_bytes, skip)
     unsigned char *source;
     int src_bytes, *skip;
{
  unsigned char *src = source, *src_end = src + src_bytes;
  unsigned char c;
  int total = 0;		/* How many end-of-lines are found so far.  */
  int eol_type = CODING_EOL_UNDECIDED;
  int this_eol_type;

  *skip = 0;

  while (src < src_end && total < MAX_EOL_CHECK_COUNT)
    {
      c = *src++;
      if (c == '\n' || c == '\r')
	{
	  if (*skip == 0)
	    *skip = src - 1 - source;
	  total++;
	  if (c == '\n')
	    this_eol_type = CODING_EOL_LF;
	  else if (src >= src_end || *src != '\n')
	    this_eol_type = CODING_EOL_CR;
	  else
	    this_eol_type = CODING_EOL_CRLF, src++;

	  if (eol_type == CODING_EOL_UNDECIDED)
	    /* This is the first end-of-line.  */
	    eol_type = this_eol_type;
	  else if (eol_type != this_eol_type)
	    {
	      /* The found type is different from what found before.  */
	      eol_type = CODING_EOL_INCONSISTENT;
	      break;
	    }
	}
    }

  if (*skip == 0)
    *skip = src_end - source;
  return eol_type;
}

/* Detect how end-of-line of a text of length SRC_BYTES pointed by SRC
   is encoded.  If it detects an appropriate format of end-of-line, it
   sets the information in *CODING.  */

void
detect_eol (coding, src, src_bytes)
     struct coding_system *coding;
     unsigned char *src;
     int src_bytes;
{
  Lisp_Object val;
  int skip;
  int eol_type = detect_eol_type (src, src_bytes, &skip);

  if (coding->heading_ascii > skip)
    coding->heading_ascii = skip;
  else
    skip = coding->heading_ascii;

  if (eol_type == CODING_EOL_UNDECIDED)
    return;
  if (eol_type == CODING_EOL_INCONSISTENT)
    {
#if 0
      /* This code is suppressed until we find a better way to
	 distinguish raw text file and binary file.  */

      /* If we have already detected that the coding is raw-text, the
	 coding should actually be no-conversion.  */
      if (coding->type == coding_type_raw_text)
	{
	  setup_coding_system (Qno_conversion, coding);
	  return;
	}
      /* Else, let's decode only text code anyway.  */
#endif /* 0 */
      eol_type = CODING_EOL_LF;
    }

  val = Fget (coding->symbol, Qeol_type);
  if (VECTORP (val) && XVECTOR (val)->size == 3)
    {
      setup_coding_system (XVECTOR (val)->contents[eol_type], coding);
      coding->heading_ascii = skip;
    }
}

#define CONVERSION_BUFFER_EXTRA_ROOM 256

#define DECODING_BUFFER_MAG(coding)					     \
  (coding->type == coding_type_iso2022					     \
   ? 3									     \
   : ((coding->type == coding_type_sjis || coding->type == coding_type_big5) \
      ? 2								     \
      : (coding->type == coding_type_raw_text				     \
	 ? 1								     \
	 : (coding->type == coding_type_ccl				     \
	    ? coding->spec.ccl.decoder.buf_magnification		     \
	    : 2))))

/* Return maximum size (bytes) of a buffer enough for decoding
   SRC_BYTES of text encoded in CODING.  */

int
decoding_buffer_size (coding, src_bytes)
     struct coding_system *coding;
     int src_bytes;
{
  return (src_bytes * DECODING_BUFFER_MAG (coding)
	  + CONVERSION_BUFFER_EXTRA_ROOM);
}

/* Return maximum size (bytes) of a buffer enough for encoding
   SRC_BYTES of text to CODING.  */

int
encoding_buffer_size (coding, src_bytes)
     struct coding_system *coding;
     int src_bytes;
{
  int magnification;

  if (coding->type == coding_type_ccl)
    magnification = coding->spec.ccl.encoder.buf_magnification;
  else
    magnification = 3;

  return (src_bytes * magnification + CONVERSION_BUFFER_EXTRA_ROOM);
}

#ifndef MINIMUM_CONVERSION_BUFFER_SIZE
#define MINIMUM_CONVERSION_BUFFER_SIZE 1024
#endif

char *conversion_buffer;
int conversion_buffer_size;

/* Return a pointer to a SIZE bytes of buffer to be used for encoding
   or decoding.  Sufficient memory is allocated automatically.  If we
   run out of memory, return NULL.  */

char *
get_conversion_buffer (size)
     int size;
{
  if (size > conversion_buffer_size)
    {
      char *buf;
      int real_size = conversion_buffer_size * 2;

      while (real_size < size) real_size *= 2;
      buf = (char *) xmalloc (real_size);
      xfree (conversion_buffer);
      conversion_buffer = buf;
      conversion_buffer_size = real_size;
    }
  return conversion_buffer;
}

int
ccl_coding_driver (coding, source, destination, src_bytes, dst_bytes, encodep)
     struct coding_system *coding;
     unsigned char *source, *destination;
     int src_bytes, dst_bytes, encodep;
{
  struct ccl_program *ccl
    = encodep ? &coding->spec.ccl.encoder : &coding->spec.ccl.decoder;
  int result;

  ccl->last_block = coding->mode & CODING_MODE_LAST_BLOCK;

  coding->produced = ccl_driver (ccl, source, destination,
				 src_bytes, dst_bytes, &(coding->consumed));
  coding->produced_char
    = (encodep
       ? coding->produced
       : multibyte_chars_in_text (destination, coding->produced));
  coding->consumed_char
    = multibyte_chars_in_text (source, coding->consumed);

  switch (ccl->status)
    {
    case CCL_STAT_SUSPEND_BY_SRC:
      result = CODING_FINISH_INSUFFICIENT_SRC;
      break;
    case CCL_STAT_SUSPEND_BY_DST:
      result = CODING_FINISH_INSUFFICIENT_DST;
      break;
    case CCL_STAT_QUIT:
    case CCL_STAT_INVALID_CMD:
      result = CODING_FINISH_INTERRUPT;
      break;
    default:
      result = CODING_FINISH_NORMAL;
      break;
    }
  return result;
}

/* See "GENERAL NOTES about `decode_coding_XXX ()' functions".  Before
   decoding, it may detect coding system and format of end-of-line if
   those are not yet decided.

   This function does not make full use of DESTINATION buffer.  For
   instance, if coding->type is coding_type_iso2022, it uses only
   (DST_BYTES - 7) bytes of DESTINATION buffer.  In the case that
   DST_BYTES is decided by the function decoding_buffer_size, it
   contains extra 256 bytes (defined by CONVERSION_BUFFER_EXTRA_ROOM).
   So, this function can decode the full SOURCE.  But, in the other
   case, if you want to avoid carry over, you must supply at least 7
   bytes more area in DESTINATION buffer than expected maximum bytes
   that will be produced by this function.  */

int
decode_coding (coding, source, destination, src_bytes, dst_bytes)
     struct coding_system *coding;
     unsigned char *source, *destination;
     int src_bytes, dst_bytes;
{
  int result;

  if (src_bytes <= 0
      && coding->type != coding_type_ccl
      && ! (coding->mode & CODING_MODE_LAST_BLOCK
	    && CODING_REQUIRE_FLUSHING (coding)))
    {
      coding->produced = coding->produced_char = 0;
      coding->consumed = coding->consumed_char = 0;
      coding->fake_multibyte = 0;
      return CODING_FINISH_NORMAL;
    }

  if (coding->type == coding_type_undecided)
    detect_coding (coding, source, src_bytes);

  if (coding->eol_type == CODING_EOL_UNDECIDED)
    detect_eol (coding, source, src_bytes);

  switch (coding->type)
    {
    case coding_type_emacs_mule:
    case coding_type_undecided:
    case coding_type_raw_text:
      if (coding->eol_type == CODING_EOL_LF
	  ||  coding->eol_type == CODING_EOL_UNDECIDED)
	goto label_no_conversion;
      result = decode_eol (coding, source, destination, src_bytes, dst_bytes);
      break;

    case coding_type_sjis:
      result = decode_coding_sjis_big5 (coding, source, destination,
					src_bytes, dst_bytes, 1);
      break;

    case coding_type_iso2022:
      result = decode_coding_iso2022 (coding, source, destination,
				      src_bytes, dst_bytes);
      break;

    case coding_type_big5:
      result = decode_coding_sjis_big5 (coding, source, destination,
					src_bytes, dst_bytes, 0);
      break;

    case coding_type_ccl:
      result = ccl_coding_driver (coding, source, destination,
				  src_bytes, dst_bytes, 0);
      break;

    default:			/* i.e. case coding_type_no_conversion: */
    label_no_conversion:
      if (dst_bytes && src_bytes > dst_bytes)
	{
	  coding->produced = dst_bytes;
	  result = CODING_FINISH_INSUFFICIENT_DST;
	}
      else
	{
	  coding->produced = src_bytes;
	  result = CODING_FINISH_NORMAL;
	}
      if (dst_bytes)
	bcopy (source, destination, coding->produced);
      else
	safe_bcopy (source, destination, coding->produced);
      coding->fake_multibyte = 1;
      coding->consumed
	= coding->consumed_char = coding->produced_char = coding->produced;
      break;
    }

  return result;
}

/* See "GENERAL NOTES about `encode_coding_XXX ()' functions".

   This function does not make full use of DESTINATION buffer.  For
   instance, if coding->type is coding_type_iso2022, it uses only
   (DST_BYTES - 20) bytes of DESTINATION buffer.  In the case that
   DST_BYTES is decided by the function encoding_buffer_size, it
   contains extra 256 bytes (defined by CONVERSION_BUFFER_EXTRA_ROOM).
   So, this function can encode the full SOURCE.  But, in the other
   case, if you want to avoid carry over, you must supply at least 20
   bytes more area in DESTINATION buffer than expected maximum bytes
   that will be produced by this function.  */

int
encode_coding (coding, source, destination, src_bytes, dst_bytes)
     struct coding_system *coding;
     unsigned char *source, *destination;
     int src_bytes, dst_bytes;
{
  int result;

  if (src_bytes <= 0
      && ! (coding->mode & CODING_MODE_LAST_BLOCK
	    && CODING_REQUIRE_FLUSHING (coding)))
    {
      coding->produced = coding->produced_char = 0;
      coding->consumed = coding->consumed_char = 0;
      coding->fake_multibyte = 0;
      return CODING_FINISH_NORMAL;
    }

  switch (coding->type)
    {
    case coding_type_emacs_mule:
    case coding_type_undecided:
    case coding_type_raw_text:
      if (coding->eol_type == CODING_EOL_LF
	  ||  coding->eol_type == CODING_EOL_UNDECIDED)
	goto label_no_conversion;
      result = encode_eol (coding, source, destination, src_bytes, dst_bytes);
      break;

    case coding_type_sjis:
      result = encode_coding_sjis_big5 (coding, source, destination,
					src_bytes, dst_bytes, 1);
      break;

    case coding_type_iso2022:
      result = encode_coding_iso2022 (coding, source, destination,
				      src_bytes, dst_bytes);
      break;

    case coding_type_big5:
      result = encode_coding_sjis_big5 (coding, source, destination,
					src_bytes, dst_bytes, 0);
      break;

    case coding_type_ccl:
      result = ccl_coding_driver (coding, source, destination,
				  src_bytes, dst_bytes, 1);
      break;

    default:			/* i.e. case coding_type_no_conversion: */
    label_no_conversion:
      if (dst_bytes && src_bytes > dst_bytes)
	{
	  coding->produced = dst_bytes;
	  result = CODING_FINISH_INSUFFICIENT_DST;
	}
      else
	{
	  coding->produced = src_bytes;
	  result = CODING_FINISH_NORMAL;
	}
      if (dst_bytes)
	bcopy (source, destination, coding->produced);
      else
	safe_bcopy (source, destination, coding->produced);
      if (coding->mode & CODING_MODE_SELECTIVE_DISPLAY)
	{
	  unsigned char *p = destination, *pend = p + coding->produced;
	  while (p < pend)
	    if (*p++ == '\015') p[-1] = '\n';
	}
      coding->fake_multibyte = 1;
      coding->consumed
	= coding->consumed_char = coding->produced_char = coding->produced;
      break;
    }

  return result;
}

/* Scan text in the region between *BEG and *END (byte positions),
   skip characters which we don't have to decode by coding system
   CODING at the head and tail, then set *BEG and *END to the region
   of the text we actually have to convert.  The caller should move
   the gap out of the region in advance.

   If STR is not NULL, *BEG and *END are indices into STR.  */

static void
shrink_decoding_region (beg, end, coding, str)
     int *beg, *end;
     struct coding_system *coding;
     unsigned char *str;
{
  unsigned char *begp_orig, *begp, *endp_orig, *endp, c;
  int eol_conversion;
  Lisp_Object translation_table;

  if (coding->type == coding_type_ccl
      || coding->type == coding_type_undecided
      || !NILP (coding->post_read_conversion))
    {
      /* We can't skip any data.  */
      return;
    }
  else if (coding->type == coding_type_no_conversion)
    {
      /* We need no conversion, but don't have to skip any data here.
         Decoding routine handles them effectively anyway.  */
      return;
    }

  translation_table = coding->translation_table_for_decode;
  if (NILP (translation_table) && !NILP (Venable_character_translation))
    translation_table = Vstandard_translation_table_for_decode;
  if (CHAR_TABLE_P (translation_table))
    {
      int i;
      for (i = 0; i < 128; i++)
	if (!NILP (CHAR_TABLE_REF (translation_table, i)))
	  break;
      if (i < 128)
	/* Some ASCII character should be tranlsated.  We give up
	   shrinking.  */
	return;
    }

  eol_conversion = (coding->eol_type != CODING_EOL_LF);

  if ((! eol_conversion) && (coding->heading_ascii >= 0))
    /* Detection routine has already found how much we can skip at the
       head.  */
    *beg += coding->heading_ascii;

  if (str)
    {
      begp_orig = begp = str + *beg;
      endp_orig = endp = str + *end;
    }
  else
    {
      begp_orig = begp = BYTE_POS_ADDR (*beg);
      endp_orig = endp = begp + *end - *beg;
    }

  switch (coding->type)
    {
    case coding_type_emacs_mule:
    case coding_type_raw_text:
      if (eol_conversion)
	{
	  if (coding->heading_ascii < 0)
	    while (begp < endp && *begp != '\r' && *begp < 0x80) begp++;
	  while (begp < endp && endp[-1] != '\r' && endp[-1] < 0x80)
	    endp--;
	  /* Do not consider LF as ascii if preceded by CR, since that
             confuses eol decoding. */
	  if (begp < endp && endp < endp_orig && endp[-1] == '\r' && endp[0] == '\n')
	    endp++;
	}
      else
	begp = endp;
      break;

    case coding_type_sjis:
    case coding_type_big5:
      /* We can skip all ASCII characters at the head.  */
      if (coding->heading_ascii < 0)
	{
	  if (eol_conversion)
	    while (begp < endp && *begp < 0x80 && *begp != '\r') begp++;
	  else
	    while (begp < endp && *begp < 0x80) begp++;
	}
      /* We can skip all ASCII characters at the tail except for the
	 second byte of SJIS or BIG5 code.  */
      if (eol_conversion)
	while (begp < endp && endp[-1] < 0x80 && endp[-1] != '\r') endp--;
      else
	while (begp < endp && endp[-1] < 0x80) endp--;
      /* Do not consider LF as ascii if preceded by CR, since that
	 confuses eol decoding. */
      if (begp < endp && endp < endp_orig && endp[-1] == '\r' && endp[0] == '\n')
	endp++;
      if (begp < endp && endp < endp_orig && endp[-1] >= 0x80)
	endp++;
      break;

    default:		/* i.e. case coding_type_iso2022: */
      if (CODING_SPEC_ISO_INITIAL_DESIGNATION (coding, 0) != CHARSET_ASCII)
	/* We can't skip any data.  */
	break;
      if (coding->heading_ascii < 0)
	{
	  /* We can skip all ASCII characters at the head except for a
	     few control codes.  */
	  while (begp < endp && (c = *begp) < 0x80
		 && c != ISO_CODE_CR && c != ISO_CODE_SO
		 && c != ISO_CODE_SI && c != ISO_CODE_ESC
		 && (!eol_conversion || c != ISO_CODE_LF))
	    begp++;
	}
      switch (coding->category_idx)
	{
	case CODING_CATEGORY_IDX_ISO_8_1:
	case CODING_CATEGORY_IDX_ISO_8_2:
	  /* We can skip all ASCII characters at the tail.  */
	  if (eol_conversion)
	    while (begp < endp && (c = endp[-1]) < 0x80 && c != '\r') endp--;
	  else
	    while (begp < endp && endp[-1] < 0x80) endp--;
	  /* Do not consider LF as ascii if preceded by CR, since that
             confuses eol decoding. */
	  if (begp < endp && endp < endp_orig && endp[-1] == '\r' && endp[0] == '\n')
	    endp++;
	  break;

	case CODING_CATEGORY_IDX_ISO_7:
	case CODING_CATEGORY_IDX_ISO_7_TIGHT:
	  {
	    /* We can skip all charactes at the tail except for 8-bit
	       codes and ESC and the following 2-byte at the tail.  */
	    unsigned char *eight_bit = NULL;

	    if (eol_conversion)
	      while (begp < endp
		     && (c = endp[-1]) != ISO_CODE_ESC && c != '\r')
		{
		  if (!eight_bit && c & 0x80) eight_bit = endp;
		  endp--;
		}
	    else
	      while (begp < endp
		     && (c = endp[-1]) != ISO_CODE_ESC)
		{
		  if (!eight_bit && c & 0x80) eight_bit = endp;
		  endp--;
		}
	    /* Do not consider LF as ascii if preceded by CR, since that
	       confuses eol decoding. */
	    if (begp < endp && endp < endp_orig
		&& endp[-1] == '\r' && endp[0] == '\n')
	      endp++;
	    if (begp < endp && endp[-1] == ISO_CODE_ESC)
	      {
		if (endp + 1 < endp_orig && end[0] == '(' && end[1] == 'B')
		  /* This is an ASCII designation sequence.  We can
		     surely skip the tail.  But, if we have
		     encountered an 8-bit code, skip only the codes
		     after that.  */
		  endp = eight_bit ? eight_bit : endp + 2;
		else
		  /* Hmmm, we can't skip the tail.  */
		  endp = endp_orig;
	      }
	    else if (eight_bit)
	      endp = eight_bit;
	  }
	}
    }
  *beg += begp - begp_orig;
  *end += endp - endp_orig;
  return;
}

/* Like shrink_decoding_region but for encoding.  */

static void
shrink_encoding_region (beg, end, coding, str)
     int *beg, *end;
     struct coding_system *coding;
     unsigned char *str;
{
  unsigned char *begp_orig, *begp, *endp_orig, *endp;
  int eol_conversion;
  Lisp_Object translation_table;

  if (coding->type == coding_type_ccl)
    /* We can't skip any data.  */
    return;
  else if (coding->type == coding_type_no_conversion)
    {
      /* We need no conversion.  */
      *beg = *end;
      return;
    }

  translation_table = coding->translation_table_for_encode;
  if (NILP (translation_table) && !NILP (Venable_character_translation))
    translation_table = Vstandard_translation_table_for_encode;
  if (CHAR_TABLE_P (translation_table))
    {
      int i;
      for (i = 0; i < 128; i++)
	if (!NILP (CHAR_TABLE_REF (translation_table, i)))
	  break;
      if (i < 128)
	/* Some ASCII character should be tranlsated.  We give up
	   shrinking.  */
	return;
    }

  if (str)
    {
      begp_orig = begp = str + *beg;
      endp_orig = endp = str + *end;
    }
  else
    {
      begp_orig = begp = BYTE_POS_ADDR (*beg);
      endp_orig = endp = begp + *end - *beg;
    }

  eol_conversion = (coding->eol_type == CODING_EOL_CR
		    || coding->eol_type == CODING_EOL_CRLF);

  /* Here, we don't have to check coding->pre_write_conversion because
     the caller is expected to have handled it already.  */
  switch (coding->type)
    {
    case coding_type_undecided:
    case coding_type_emacs_mule:
    case coding_type_raw_text:
      if (eol_conversion)
	{
	  while (begp < endp && *begp != '\n') begp++;
	  while (begp < endp && endp[-1] != '\n') endp--;
	}
      else
	begp = endp;
      break;

    case coding_type_iso2022:
      if (CODING_SPEC_ISO_INITIAL_DESIGNATION (coding, 0) != CHARSET_ASCII)
	/* We can't skip any data.  */
	break;
      if (coding->flags & CODING_FLAG_ISO_DESIGNATE_AT_BOL)
	{
	  unsigned char *bol = begp; 
	  while (begp < endp && *begp < 0x80)
	    {
	      begp++;
	      if (begp[-1] == '\n')
		bol = begp;
	    }
	  begp = bol;
	  goto label_skip_tail;
	}
      /* fall down ... */

    default:
      /* We can skip all ASCII characters at the head and tail.  */
      if (eol_conversion)
	while (begp < endp && *begp < 0x80 && *begp != '\n') begp++;
      else
	while (begp < endp && *begp < 0x80) begp++;
    label_skip_tail:
      if (eol_conversion)
	while (begp < endp && endp[-1] < 0x80 && endp[-1] != '\n') endp--;
      else
	while (begp < endp && *(endp - 1) < 0x80) endp--;
      break;
    }

  *beg += begp - begp_orig;
  *end += endp - endp_orig;
  return;
}

/* As shrinking conversion region requires some overhead, we don't try
   shrinking if the length of conversion region is less than this
   value.  */
static int shrink_conversion_region_threshhold = 1024;

#define SHRINK_CONVERSION_REGION(beg, end, coding, str, encodep)	\
  do {									\
    if (*(end) - *(beg) > shrink_conversion_region_threshhold)		\
      {									\
        if (encodep) shrink_encoding_region (beg, end, coding, str);	\
        else shrink_decoding_region (beg, end, coding, str);		\
      }									\
  } while (0)

/* Decode (if ENCODEP is zero) or encode (if ENCODEP is nonzero) the
   text from FROM to TO (byte positions are FROM_BYTE and TO_BYTE) by
   coding system CODING, and return the status code of code conversion
   (currently, this value has no meaning).

   How many characters (and bytes) are converted to how many
   characters (and bytes) are recorded in members of the structure
   CODING.

   If REPLACE is nonzero, we do various things as if the original text
   is deleted and a new text is inserted.  See the comments in
   replace_range (insdel.c) to know what we are doing.  */

int
code_convert_region (from, from_byte, to, to_byte, coding, encodep, replace)
     int from, from_byte, to, to_byte, encodep, replace;
     struct coding_system *coding;
{
  int len = to - from, len_byte = to_byte - from_byte;
  int require, inserted, inserted_byte;
  int head_skip, tail_skip, total_skip;
  Lisp_Object saved_coding_symbol;
  int multibyte = !NILP (current_buffer->enable_multibyte_characters);
  int first = 1;
  int fake_multibyte = 0;
  unsigned char *src, *dst;
  Lisp_Object deletion;
  int orig_point = PT, orig_len = len;
  int prev_Z;

  deletion = Qnil;
  saved_coding_symbol = Qnil;

  if (from < PT && PT < to)
    {
      TEMP_SET_PT_BOTH (from, from_byte);
      orig_point = from;
    }

  if (replace)
    {
      int saved_from = from;

      prepare_to_modify_buffer (from, to, &from);
      if (saved_from != from)
	{
	  to = from + len;
	  if (multibyte)
	    from_byte = CHAR_TO_BYTE (from), to_byte = CHAR_TO_BYTE (to);
	  else
	    from_byte = from, to_byte = to;
	  len_byte = to_byte - from_byte;
	}
    }

  if (! encodep && CODING_REQUIRE_DETECTION (coding))
    {
      /* We must detect encoding of text and eol format.  */

      if (from < GPT && to > GPT)
	move_gap_both (from, from_byte);
      if (coding->type == coding_type_undecided)
	{
	  detect_coding (coding, BYTE_POS_ADDR (from_byte), len_byte);
	  if (coding->type == coding_type_undecided)
	    /* It seems that the text contains only ASCII, but we
	       should not left it undecided because the deeper
	       decoding routine (decode_coding) tries to detect the
	       encodings again in vain.  */
	    coding->type = coding_type_emacs_mule;
	}
      if (coding->eol_type == CODING_EOL_UNDECIDED)
	{
	  saved_coding_symbol = coding->symbol;
	  detect_eol (coding, BYTE_POS_ADDR (from_byte), len_byte);
	  if (coding->eol_type == CODING_EOL_UNDECIDED)
	    coding->eol_type = CODING_EOL_LF;
	  /* We had better recover the original eol format if we
	     encounter an inconsitent eol format while decoding.  */
	  coding->mode |= CODING_MODE_INHIBIT_INCONSISTENT_EOL;
	}
    }

  coding->consumed_char = len, coding->consumed = len_byte;

  if (encodep
      ? ! CODING_REQUIRE_ENCODING (coding)
      : ! CODING_REQUIRE_DECODING (coding))
    {
      coding->produced = len_byte;
      if (multibyte
	  && ! replace
	  /* See the comment of the member heading_ascii in coding.h.  */
	  && coding->heading_ascii < len_byte)
	{
	  /* We still may have to combine byte at the head and the
             tail of the text in the region.  */
	  if (from < GPT && GPT < to)
	    move_gap_both (to, to_byte);
	  len = multibyte_chars_in_text (BYTE_POS_ADDR (from_byte), len_byte);
	  adjust_after_insert (from, from_byte, to, to_byte, len);
	  coding->produced_char = len;
	}
      else
	{
	  if (!replace)
	    adjust_after_insert (from, from_byte, to, to_byte, len_byte);
	  coding->produced_char = len_byte;
	}
      return 0;
    }

  /* Now we convert the text.  */

  /* For encoding, we must process pre-write-conversion in advance.  */
  if (encodep
      && ! NILP (coding->pre_write_conversion)
      && SYMBOLP (coding->pre_write_conversion)
      && ! NILP (Ffboundp (coding->pre_write_conversion)))
    {
      /* The function in pre-write-conversion may put a new text in a
         new buffer.  */
      struct buffer *prev = current_buffer;
      Lisp_Object new;

      call2 (coding->pre_write_conversion,
	     make_number (from), make_number (to));
      if (current_buffer != prev)
	{
	  len = ZV - BEGV;
	  new = Fcurrent_buffer ();
	  set_buffer_internal_1 (prev);
	  del_range_2 (from, from_byte, to, to_byte);
	  TEMP_SET_PT_BOTH (from, from_byte);
	  insert_from_buffer (XBUFFER (new), 1, len, 0);
	  Fkill_buffer (new);
	  if (orig_point >= to)
	    orig_point += len - orig_len;
	  else if (orig_point > from)
	    orig_point = from;
	  orig_len = len;
	  to = from + len;
	  from_byte = multibyte ? CHAR_TO_BYTE (from) : from_byte;
	  to_byte = multibyte ? CHAR_TO_BYTE (to) : to;
	  len_byte = to_byte - from_byte;
	  TEMP_SET_PT_BOTH (from, from_byte);
	}
    }

  if (replace)
    deletion = make_buffer_string_both (from, from_byte, to, to_byte, 1);

  /* Try to skip the heading and tailing ASCIIs.  */
  {
    int from_byte_orig = from_byte, to_byte_orig = to_byte;

    if (from < GPT && GPT < to)
      move_gap_both (from, from_byte);
    SHRINK_CONVERSION_REGION (&from_byte, &to_byte, coding, NULL, encodep);
    if (from_byte == to_byte
	&& coding->type != coding_type_ccl
	&& ! (coding->mode & CODING_MODE_LAST_BLOCK
	      && CODING_REQUIRE_FLUSHING (coding)))
      {
	coding->produced = len_byte;
	coding->produced_char = multibyte ? len : len_byte;
	if (!replace)
	  /* We must record and adjust for this new text now.  */
	  adjust_after_insert (from, from_byte_orig, to, to_byte_orig, len);
	return 0;
      }

    head_skip = from_byte - from_byte_orig;
    tail_skip = to_byte_orig - to_byte;
    total_skip = head_skip + tail_skip;
    from += head_skip;
    to -= tail_skip;
    len -= total_skip; len_byte -= total_skip;
  }

  /* The code conversion routine can not preserve text properties for
     now.  So, we must remove all text properties in the region.
     Here, we must suppress all modification hooks.  */
  if (replace)
    {
      int saved_inhibit_modification_hooks = inhibit_modification_hooks;
      inhibit_modification_hooks = 1;
      Fset_text_properties (make_number (from), make_number (to), Qnil, Qnil);
      inhibit_modification_hooks = saved_inhibit_modification_hooks;
    }

  /* For converion, we must put the gap before the text in addition to
     making the gap larger for efficient decoding.  The required gap
     size starts from 2000 which is the magic number used in make_gap.
     But, after one batch of conversion, it will be incremented if we
     find that it is not enough .  */
  require = 2000;

  if (GAP_SIZE  < require)
    make_gap (require - GAP_SIZE);
  move_gap_both (from, from_byte);

  inserted = inserted_byte = 0;
  src = GAP_END_ADDR, dst = GPT_ADDR;

  GAP_SIZE += len_byte;
  ZV -= len;
  Z -= len;
  ZV_BYTE -= len_byte;
  Z_BYTE -= len_byte;

  if (GPT - BEG < beg_unchanged)
    beg_unchanged = GPT - BEG;
  if (Z - GPT < end_unchanged)
    end_unchanged = Z - GPT;

  for (;;)
    {
      int result;

      /* The buffer memory is changed from:
	 +--------+converted-text+---------+-------original-text------+---+
	 |<-from->|<--inserted-->|---------|<-----------len---------->|---|
		  |<------------------- GAP_SIZE -------------------->|  */
      if (encodep)
	result = encode_coding (coding, src, dst, len_byte, 0);
      else
	result = decode_coding (coding, src, dst, len_byte, 0);
      /* to:
	 +--------+-------converted-text--------+--+---original-text--+---+
	 |<-from->|<--inserted-->|<--produced-->|--|<-(len-consumed)->|---|
		  |<------------------- GAP_SIZE -------------------->|  */
      if (coding->fake_multibyte)
	fake_multibyte = 1;

      if (!encodep && !multibyte)
	coding->produced_char = coding->produced;
      inserted += coding->produced_char;
      inserted_byte += coding->produced;
      len_byte -= coding->consumed;
      src += coding->consumed;
      dst += coding->produced;

      if (result == CODING_FINISH_NORMAL)
	{
	  src += len_byte;
	  break;
	}
      if (! encodep && result == CODING_FINISH_INCONSISTENT_EOL)
	{
	  unsigned char *pend = dst, *p = pend - inserted_byte;
	  Lisp_Object eol_type;

	  /* Encode LFs back to the original eol format (CR or CRLF).  */
	  if (coding->eol_type == CODING_EOL_CR)
	    {
	      while (p < pend) if (*p++ == '\n') p[-1] = '\r';
	    }
	  else
	    {
	      int count = 0;

	      while (p < pend) if (*p++ == '\n') count++;
	      if (src - dst < count)
		{
		  /* We don't have sufficient room for encoding LFs
		     back to CRLF.  We must record converted and
		     not-yet-converted text back to the buffer
		     content, enlarge the gap, then record them out of
		     the buffer contents again.  */
		  int add = len_byte + inserted_byte;

		  GAP_SIZE -= add;
		  ZV += add; Z += add; ZV_BYTE += add; Z_BYTE += add;
		  GPT += inserted_byte; GPT_BYTE += inserted_byte;
		  make_gap (count - GAP_SIZE);
		  GAP_SIZE += add;
		  ZV -= add; Z -= add; ZV_BYTE -= add; Z_BYTE -= add;
		  GPT -= inserted_byte; GPT_BYTE -= inserted_byte;
		  /* Don't forget to update SRC, DST, and PEND.  */
		  src = GAP_END_ADDR - len_byte;
		  dst = GPT_ADDR + inserted_byte;
		  pend = dst;
		}
	      inserted += count;
	      inserted_byte += count;
	      coding->produced += count;
	      p = dst = pend + count;
	      while (count)
		{
		  *--p = *--pend;
		  if (*p == '\n') count--, *--p = '\r';
		}
	    }

	  /* Suppress eol-format conversion in the further conversion.  */
	  coding->eol_type = CODING_EOL_LF;

	  /* Set the coding system symbol to that for Unix-like EOL.  */
	  eol_type = Fget (saved_coding_symbol, Qeol_type);
	  if (VECTORP (eol_type)
	      && XVECTOR (eol_type)->size == 3
	      && SYMBOLP (XVECTOR (eol_type)->contents[CODING_EOL_LF]))
	    coding->symbol = XVECTOR (eol_type)->contents[CODING_EOL_LF];
	  else
	    coding->symbol = saved_coding_symbol;
	  
	  continue;
	}
      if (len_byte <= 0)
	{
	  if (coding->type != coding_type_ccl
	      || coding->mode & CODING_MODE_LAST_BLOCK)
	    break;
	  coding->mode |= CODING_MODE_LAST_BLOCK;
	  continue;
	}
      if (result == CODING_FINISH_INSUFFICIENT_SRC)
	{
	  /* The source text ends in invalid codes.  Let's just
	     make them valid buffer contents, and finish conversion.  */
	  inserted += len_byte;
	  inserted_byte += len_byte;
	  while (len_byte--)
	    *dst++ = *src++;
	  fake_multibyte = 1;
	  break;
	}
      if (result == CODING_FINISH_INTERRUPT)
	{
	  /* The conversion procedure was interrupted by a user.  */
	  fake_multibyte = 1;
	  break;
	}
      /* Now RESULT == CODING_FINISH_INSUFFICIENT_DST  */
      if (coding->consumed < 1)
	{
	  /* It's quite strange to require more memory without
	     consuming any bytes.  Perhaps CCL program bug.  */
	  fake_multibyte = 1;
	  break;
	}
      if (first)
	{
	  /* We have just done the first batch of conversion which was
	     stoped because of insufficient gap.  Let's reconsider the
	     required gap size (i.e. SRT - DST) now.

	     We have converted ORIG bytes (== coding->consumed) into
	     NEW bytes (coding->produced).  To convert the remaining
	     LEN bytes, we may need REQUIRE bytes of gap, where:
		REQUIRE + LEN_BYTE = LEN_BYTE * (NEW / ORIG)
		REQUIRE = LEN_BYTE * (NEW - ORIG) / ORIG
	     Here, we are sure that NEW >= ORIG.  */
	  float ratio = coding->produced - coding->consumed;
	  ratio /= coding->consumed;
	  require = len_byte * ratio;
	  first = 0;
	}
      if ((src - dst) < (require + 2000))
	{
	  /* See the comment above the previous call of make_gap.  */
	  int add = len_byte + inserted_byte;

	  GAP_SIZE -= add;
	  ZV += add; Z += add; ZV_BYTE += add; Z_BYTE += add;
	  GPT += inserted_byte; GPT_BYTE += inserted_byte;
	  make_gap (require + 2000);
	  GAP_SIZE += add;
	  ZV -= add; Z -= add; ZV_BYTE -= add; Z_BYTE -= add;
	  GPT -= inserted_byte; GPT_BYTE -= inserted_byte;
	  /* Don't forget to update SRC, DST.  */
	  src = GAP_END_ADDR - len_byte;
	  dst = GPT_ADDR + inserted_byte;
	}
    }
  if (src - dst > 0) *dst = 0; /* Put an anchor.  */

  if (multibyte
      && (encodep
	  || fake_multibyte
	  || (to - from) != (to_byte - from_byte)))
    inserted = multibyte_chars_in_text (GPT_ADDR, inserted_byte);

  /* If we have shrinked the conversion area, adjust it now.  */ 
  if (total_skip > 0)
    {
      if (tail_skip > 0)
	safe_bcopy (GAP_END_ADDR, GPT_ADDR + inserted_byte, tail_skip);
      inserted += total_skip; inserted_byte += total_skip;
      GAP_SIZE += total_skip;
      GPT -= head_skip; GPT_BYTE -= head_skip;
      ZV -= total_skip; ZV_BYTE -= total_skip;
      Z -= total_skip; Z_BYTE -= total_skip;
      from -= head_skip; from_byte -= head_skip;
      to += tail_skip; to_byte += tail_skip;
    }

  prev_Z = Z;
  adjust_after_replace (from, from_byte, deletion, inserted, inserted_byte);
  inserted = Z - prev_Z;

  if (! encodep && ! NILP (coding->post_read_conversion))
    {
      Lisp_Object val;

      if (from != PT)
	TEMP_SET_PT_BOTH (from, from_byte);
      prev_Z = Z;
      val = call1 (coding->post_read_conversion, make_number (inserted));
      CHECK_NUMBER (val, 0);
      inserted += Z - prev_Z;
    }

  if (orig_point >= from)
    {
      if (orig_point >= from + orig_len)
	orig_point += inserted - orig_len;
      else
	orig_point = from;
      TEMP_SET_PT (orig_point);
    }

  signal_after_change (from, to - from, inserted);

  {
    coding->consumed = to_byte - from_byte;
    coding->consumed_char = to - from;
    coding->produced = inserted_byte;
    coding->produced_char = inserted;
  }

  return 0;
}

Lisp_Object
code_convert_string (str, coding, encodep, nocopy)
     Lisp_Object str;
     struct coding_system *coding;
     int encodep, nocopy;
{
  int len;
  char *buf;
  int from = 0, to = XSTRING (str)->size;
  int to_byte = STRING_BYTES (XSTRING (str));
  struct gcpro gcpro1;
  Lisp_Object saved_coding_symbol;
  int result;

  saved_coding_symbol = Qnil;
  if (encodep && !NILP (coding->pre_write_conversion)
      || !encodep && !NILP (coding->post_read_conversion))
    {
      /* Since we have to call Lisp functions which assume target text
         is in a buffer, after setting a temporary buffer, call
         code_convert_region.  */
      int count = specpdl_ptr - specpdl;
      struct buffer *prev = current_buffer;

      record_unwind_protect (Fset_buffer, Fcurrent_buffer ());
      GCPRO1 (str);
      temp_output_buffer_setup (" *code-converting-work*");
      UNGCPRO;
      set_buffer_internal (XBUFFER (Vstandard_output));
      if (encodep)
	insert_from_string (str, 0, 0, to, to_byte, 0);
      else
	{
	  /* We must insert the contents of STR as is without
             unibyte<->multibyte conversion.  */
	  current_buffer->enable_multibyte_characters = Qnil;
	  insert_from_string (str, 0, 0, to_byte, to_byte, 0);
	  current_buffer->enable_multibyte_characters = Qt;
	}
      code_convert_region (BEGV, BEGV_BYTE, ZV, ZV_BYTE, coding, encodep, 1);
      if (encodep)
	/* We must return the buffer contents as unibyte string.  */
	current_buffer->enable_multibyte_characters = Qnil;
      str = make_buffer_string (BEGV, ZV, 0);
      set_buffer_internal (prev);
      return unbind_to (count, str);
    }

  if (! encodep && CODING_REQUIRE_DETECTION (coding))
    {
      /* See the comments in code_convert_region.  */
      if (coding->type == coding_type_undecided)
	{
	  detect_coding (coding, XSTRING (str)->data, to_byte);
	  if (coding->type == coding_type_undecided)
	    coding->type = coding_type_emacs_mule;
	}
      if (coding->eol_type == CODING_EOL_UNDECIDED)
	{
	  saved_coding_symbol = coding->symbol;
	  detect_eol (coding, XSTRING (str)->data, to_byte);
	  if (coding->eol_type == CODING_EOL_UNDECIDED)
	    coding->eol_type = CODING_EOL_LF;
	  /* We had better recover the original eol format if we
	     encounter an inconsitent eol format while decoding.  */
	  coding->mode |= CODING_MODE_INHIBIT_INCONSISTENT_EOL;
	}
    }

  if (encodep
      ? ! CODING_REQUIRE_ENCODING (coding)
      : ! CODING_REQUIRE_DECODING (coding))
    from = to_byte;
  else
    {
      /* Try to skip the heading and tailing ASCIIs.  */
      SHRINK_CONVERSION_REGION (&from, &to_byte, coding, XSTRING (str)->data,
				encodep);
    }
  if (from == to_byte
      && coding->type != coding_type_ccl)
    return (nocopy ? str : Fcopy_sequence (str));

  if (encodep)
    len = encoding_buffer_size (coding, to_byte - from);
  else
    len = decoding_buffer_size (coding, to_byte - from);
  len += from + STRING_BYTES (XSTRING (str)) - to_byte;
  GCPRO1 (str);
  buf = get_conversion_buffer (len);
  UNGCPRO;

  if (from > 0)
    bcopy (XSTRING (str)->data, buf, from);
  result = (encodep
	    ? encode_coding (coding, XSTRING (str)->data + from,
			     buf + from, to_byte - from, len)
	    : decode_coding (coding, XSTRING (str)->data + from,
			     buf + from, to_byte - from, len));
  if (! encodep && result == CODING_FINISH_INCONSISTENT_EOL)
    {
      /* We simple try to decode the whole string again but without
         eol-conversion this time.  */
      coding->eol_type = CODING_EOL_LF;
      coding->symbol = saved_coding_symbol;
      return code_convert_string (str, coding, encodep, nocopy);
    }

  bcopy (XSTRING (str)->data + to_byte, buf + from + coding->produced,
	 STRING_BYTES (XSTRING (str)) - to_byte);

  len = from + STRING_BYTES (XSTRING (str)) - to_byte;
  if (encodep)
    str = make_unibyte_string (buf, len + coding->produced);
  else
    {
      int chars= (coding->fake_multibyte
		  ? multibyte_chars_in_text (buf + from, coding->produced)
		  : coding->produced_char);
      str = make_multibyte_string (buf, len + chars, len + coding->produced);
    }

  return str;
}


#ifdef emacs
/*** 8. Emacs Lisp library functions ***/

DEFUN ("coding-system-p", Fcoding_system_p, Scoding_system_p, 1, 1, 0,
  "Return t if OBJECT is nil or a coding-system.\n\
See the documentation of `make-coding-system' for information\n\
about coding-system objects.")
  (obj)
     Lisp_Object obj;
{
  if (NILP (obj))
    return Qt;
  if (!SYMBOLP (obj))
    return Qnil;
  /* Get coding-spec vector for OBJ.  */
  obj = Fget (obj, Qcoding_system);
  return ((VECTORP (obj) && XVECTOR (obj)->size == 5)
	  ? Qt : Qnil);
}

DEFUN ("read-non-nil-coding-system", Fread_non_nil_coding_system,
       Sread_non_nil_coding_system, 1, 1, 0,
  "Read a coding system from the minibuffer, prompting with string PROMPT.")
  (prompt)
     Lisp_Object prompt;
{
  Lisp_Object val;
  do
    {
      val = Fcompleting_read (prompt, Vcoding_system_alist, Qnil,
			      Qt, Qnil, Qcoding_system_history, Qnil, Qnil);
    }
  while (XSTRING (val)->size == 0);
  return (Fintern (val, Qnil));
}

DEFUN ("read-coding-system", Fread_coding_system, Sread_coding_system, 1, 2, 0,
  "Read a coding system from the minibuffer, prompting with string PROMPT.\n\
If the user enters null input, return second argument DEFAULT-CODING-SYSTEM.")
  (prompt, default_coding_system)
     Lisp_Object prompt, default_coding_system;
{
  Lisp_Object val;
  if (SYMBOLP (default_coding_system))
    XSETSTRING (default_coding_system, XSYMBOL (default_coding_system)->name);
  val = Fcompleting_read (prompt, Vcoding_system_alist, Qnil,
			  Qt, Qnil, Qcoding_system_history,
			  default_coding_system, Qnil);
  return (XSTRING (val)->size == 0 ? Qnil : Fintern (val, Qnil));
}

DEFUN ("check-coding-system", Fcheck_coding_system, Scheck_coding_system,
       1, 1, 0,
  "Check validity of CODING-SYSTEM.\n\
If valid, return CODING-SYSTEM, else signal a `coding-system-error' error.\n\
It is valid if it is a symbol with a non-nil `coding-system' property.\n\
The value of property should be a vector of length 5.")
  (coding_system)
     Lisp_Object coding_system;
{
  CHECK_SYMBOL (coding_system, 0);
  if (!NILP (Fcoding_system_p (coding_system)))
    return coding_system;
  while (1)
    Fsignal (Qcoding_system_error, Fcons (coding_system, Qnil));
}

Lisp_Object
detect_coding_system (src, src_bytes, highest)
     unsigned char *src;
     int src_bytes, highest;
{
  int coding_mask, eol_type;
  Lisp_Object val, tmp;
  int dummy;

  coding_mask = detect_coding_mask (src, src_bytes, NULL, &dummy);
  eol_type  = detect_eol_type (src, src_bytes, &dummy);
  if (eol_type == CODING_EOL_INCONSISTENT)
    eol_type = CODING_EOL_UNDECIDED;

  if (!coding_mask)
    {
      val = Qundecided;
      if (eol_type != CODING_EOL_UNDECIDED)
	{
	  Lisp_Object val2;
	  val2 = Fget (Qundecided, Qeol_type);
	  if (VECTORP (val2))
	    val = XVECTOR (val2)->contents[eol_type];
	}
      return (highest ? val : Fcons (val, Qnil));
    }

  /* At first, gather possible coding systems in VAL.  */
  val = Qnil;
  for (tmp = Vcoding_category_list; !NILP (tmp); tmp = XCONS (tmp)->cdr)
    {
      int idx
	= XFASTINT (Fget (XCONS (tmp)->car, Qcoding_category_index));
      if (coding_mask & (1 << idx))
	{
	  val = Fcons (Fsymbol_value (XCONS (tmp)->car), val);
	  if (highest)
	    break;
	}
    }
  if (!highest)
    val = Fnreverse (val);

  /* Then, replace the elements with subsidiary coding systems.  */
  for (tmp = val; !NILP (tmp); tmp = XCONS (tmp)->cdr)
    {
      if (eol_type != CODING_EOL_UNDECIDED
	  && eol_type != CODING_EOL_INCONSISTENT)
	{
	  Lisp_Object eol;
	  eol = Fget (XCONS (tmp)->car, Qeol_type);
	  if (VECTORP (eol))
	    XCONS (tmp)->car = XVECTOR (eol)->contents[eol_type];
	}
    }
  return (highest ? XCONS (val)->car : val);
}  

DEFUN ("detect-coding-region", Fdetect_coding_region, Sdetect_coding_region,
       2, 3, 0,
  "Detect coding system of the text in the region between START and END.\n\
Return a list of possible coding systems ordered by priority.\n\
\n\
If only ASCII characters are found, it returns a list of single element\n\
`undecided' or its subsidiary coding system according to a detected\n\
end-of-line format.\n\
\n\
If optional argument HIGHEST is non-nil, return the coding system of\n\
highest priority.")
  (start, end, highest)
     Lisp_Object start, end, highest;
{
  int from, to;
  int from_byte, to_byte;

  CHECK_NUMBER_COERCE_MARKER (start, 0);
  CHECK_NUMBER_COERCE_MARKER (end, 1);

  validate_region (&start, &end);
  from = XINT (start), to = XINT (end);
  from_byte = CHAR_TO_BYTE (from);
  to_byte = CHAR_TO_BYTE (to);

  if (from < GPT && to >= GPT)
    move_gap_both (to, to_byte);

  return detect_coding_system (BYTE_POS_ADDR (from_byte),
			       to_byte - from_byte,
			       !NILP (highest));
}

DEFUN ("detect-coding-string", Fdetect_coding_string, Sdetect_coding_string,
       1, 2, 0,
  "Detect coding system of the text in STRING.\n\
Return a list of possible coding systems ordered by priority.\n\
\n\
If only ASCII characters are found, it returns a list of single element\n\
`undecided' or its subsidiary coding system according to a detected\n\
end-of-line format.\n\
\n\
If optional argument HIGHEST is non-nil, return the coding system of\n\
highest priority.")
  (string, highest)
     Lisp_Object string, highest;
{
  CHECK_STRING (string, 0);

  return detect_coding_system (XSTRING (string)->data,
			       STRING_BYTES (XSTRING (string)),
			       !NILP (highest));
}

Lisp_Object
code_convert_region1 (start, end, coding_system, encodep)
     Lisp_Object start, end, coding_system;
     int encodep;
{
  struct coding_system coding;
  int from, to, len;

  CHECK_NUMBER_COERCE_MARKER (start, 0);
  CHECK_NUMBER_COERCE_MARKER (end, 1);
  CHECK_SYMBOL (coding_system, 2);

  validate_region (&start, &end);
  from = XFASTINT (start);
  to = XFASTINT (end);

  if (NILP (coding_system))
    return make_number (to - from);

  if (setup_coding_system (Fcheck_coding_system (coding_system), &coding) < 0)
    error ("Invalid coding system: %s", XSYMBOL (coding_system)->name->data);

  coding.mode |= CODING_MODE_LAST_BLOCK;
  code_convert_region (from, CHAR_TO_BYTE (from), to, CHAR_TO_BYTE (to),
		       &coding, encodep, 1);
  Vlast_coding_system_used = coding.symbol;
  return make_number (coding.produced_char);
}

DEFUN ("decode-coding-region", Fdecode_coding_region, Sdecode_coding_region,
       3, 3, "r\nzCoding system: ",
  "Decode the current region by specified coding system.\n\
When called from a program, takes three arguments:\n\
START, END, and CODING-SYSTEM.  START and END are buffer positions.\n\
This function sets `last-coding-system-used' to the precise coding system\n\
used (which may be different from CODING-SYSTEM if CODING-SYSTEM is\n\
not fully specified.)\n\
It returns the length of the decoded text.")
  (start, end, coding_system)
     Lisp_Object start, end, coding_system;
{
  return code_convert_region1 (start, end, coding_system, 0);
}

DEFUN ("encode-coding-region", Fencode_coding_region, Sencode_coding_region,
       3, 3, "r\nzCoding system: ",
  "Encode the current region by specified coding system.\n\
When called from a program, takes three arguments:\n\
START, END, and CODING-SYSTEM.  START and END are buffer positions.\n\
This function sets `last-coding-system-used' to the precise coding system\n\
used (which may be different from CODING-SYSTEM if CODING-SYSTEM is\n\
not fully specified.)\n\
It returns the length of the encoded text.")
  (start, end, coding_system)
     Lisp_Object start, end, coding_system;
{
  return code_convert_region1 (start, end, coding_system, 1);
}

Lisp_Object
code_convert_string1 (string, coding_system, nocopy, encodep)
     Lisp_Object string, coding_system, nocopy;
     int encodep;
{
  struct coding_system coding;

  CHECK_STRING (string, 0);
  CHECK_SYMBOL (coding_system, 1);

  if (NILP (coding_system))
    return (NILP (nocopy) ? Fcopy_sequence (string) : string);

  if (setup_coding_system (Fcheck_coding_system (coding_system), &coding) < 0)
    error ("Invalid coding system: %s", XSYMBOL (coding_system)->name->data);

  coding.mode |= CODING_MODE_LAST_BLOCK;
  Vlast_coding_system_used = coding.symbol;
  return code_convert_string (string, &coding, encodep, !NILP (nocopy));
}

DEFUN ("decode-coding-string", Fdecode_coding_string, Sdecode_coding_string,
       2, 3, 0,
  "Decode STRING which is encoded in CODING-SYSTEM, and return the result.\n\
Optional arg NOCOPY non-nil means it is ok to return STRING itself\n\
if the decoding operation is trivial.\n\
This function sets `last-coding-system-used' to the precise coding system\n\
used (which may be different from CODING-SYSTEM if CODING-SYSTEM is\n\
not fully specified.)")
  (string, coding_system, nocopy)
     Lisp_Object string, coding_system, nocopy;
{
  return code_convert_string1 (string, coding_system, nocopy, 0);
}

DEFUN ("encode-coding-string", Fencode_coding_string, Sencode_coding_string,
       2, 3, 0,
  "Encode STRING to CODING-SYSTEM, and return the result.\n\
Optional arg NOCOPY non-nil means it is ok to return STRING itself\n\
if the encoding operation is trivial.\n\
This function sets `last-coding-system-used' to the precise coding system\n\
used (which may be different from CODING-SYSTEM if CODING-SYSTEM is\n\
not fully specified.)")
  (string, coding_system, nocopy)
     Lisp_Object string, coding_system, nocopy;
{
  return code_convert_string1 (string, coding_system, nocopy, 1);
}

/* Encode or decode STRING according to CODING_SYSTEM.
   Do not set Vlast_coding_system_used.  */

Lisp_Object
code_convert_string_norecord (string, coding_system, encodep)
     Lisp_Object string, coding_system;
     int encodep;
{
  struct coding_system coding;

  CHECK_STRING (string, 0);
  CHECK_SYMBOL (coding_system, 1);

  if (NILP (coding_system))
    return string;

  if (setup_coding_system (Fcheck_coding_system (coding_system), &coding) < 0)
    error ("Invalid coding system: %s", XSYMBOL (coding_system)->name->data);

  coding.mode |= CODING_MODE_LAST_BLOCK;
  return code_convert_string (string, &coding, encodep, Qt);
}

DEFUN ("decode-sjis-char", Fdecode_sjis_char, Sdecode_sjis_char, 1, 1, 0,
  "Decode a Japanese character which has CODE in shift_jis encoding.\n\
Return the corresponding character.")
  (code)
     Lisp_Object code;
{
  unsigned char c1, c2, s1, s2;
  Lisp_Object val;

  CHECK_NUMBER (code, 0);
  s1 = (XFASTINT (code)) >> 8, s2 = (XFASTINT (code)) & 0xFF;
  if (s1 == 0)
    {
      if (s2 < 0x80)
	XSETFASTINT (val, s2);
      else if (s2 >= 0xA0 || s2 <= 0xDF)
	XSETFASTINT (val,
		     MAKE_NON_ASCII_CHAR (charset_katakana_jisx0201, s2, 0));
      else
	error ("Invalid Shift JIS code: %x", XFASTINT (code));
    }
  else
    {
      if ((s1 < 0x80 || s1 > 0x9F && s1 < 0xE0 || s1 > 0xEF)
	  || (s2 < 0x40 || s2 == 0x7F || s2 > 0xFC))
	error ("Invalid Shift JIS code: %x", XFASTINT (code));
      DECODE_SJIS (s1, s2, c1, c2);
      XSETFASTINT (val, MAKE_NON_ASCII_CHAR (charset_jisx0208, c1, c2));
    }
  return val;
}

DEFUN ("encode-sjis-char", Fencode_sjis_char, Sencode_sjis_char, 1, 1, 0,
  "Encode a Japanese character CHAR to shift_jis encoding.\n\
Return the corresponding code in SJIS.")
  (ch)
     Lisp_Object ch;
{
  int charset, c1, c2, s1, s2;
  Lisp_Object val;

  CHECK_NUMBER (ch, 0);
  SPLIT_CHAR (XFASTINT (ch), charset, c1, c2);
  if (charset == CHARSET_ASCII)
    {
      val = ch;
    }
  else if (charset == charset_jisx0208
	   && c1 > 0x20 && c1 < 0x7F && c2 > 0x20 && c2 < 0x7F)
    {
      ENCODE_SJIS (c1, c2, s1, s2);
      XSETFASTINT (val, (s1 << 8) | s2);
    }
  else if (charset == charset_katakana_jisx0201
	   && c1 > 0x20 && c2 < 0xE0)
    {
      XSETFASTINT (val, c1 | 0x80);
    }
  else
    error ("Can't encode to shift_jis: %d", XFASTINT (ch));
  return val;
}

DEFUN ("decode-big5-char", Fdecode_big5_char, Sdecode_big5_char, 1, 1, 0,
  "Decode a Big5 character which has CODE in BIG5 coding system.\n\
Return the corresponding character.")
  (code)
     Lisp_Object code;
{
  int charset;
  unsigned char b1, b2, c1, c2;
  Lisp_Object val;

  CHECK_NUMBER (code, 0);
  b1 = (XFASTINT (code)) >> 8, b2 = (XFASTINT (code)) & 0xFF;
  if (b1 == 0)
    {
      if (b2 >= 0x80)
	error ("Invalid BIG5 code: %x", XFASTINT (code));
      val = code;
    }
  else
    {
      if ((b1 < 0xA1 || b1 > 0xFE)
	  || (b2 < 0x40 || (b2 > 0x7E && b2 < 0xA1) || b2 > 0xFE))
	error ("Invalid BIG5 code: %x", XFASTINT (code));
      DECODE_BIG5 (b1, b2, charset, c1, c2);
      XSETFASTINT (val, MAKE_NON_ASCII_CHAR (charset, c1, c2));
    }
  return val;
}

DEFUN ("encode-big5-char", Fencode_big5_char, Sencode_big5_char, 1, 1, 0,
  "Encode the Big5 character CHAR to BIG5 coding system.\n\
Return the corresponding character code in Big5.")
  (ch)
     Lisp_Object ch;
{
  int charset, c1, c2, b1, b2;
  Lisp_Object val;

  CHECK_NUMBER (ch, 0);
  SPLIT_CHAR (XFASTINT (ch), charset, c1, c2);
  if (charset == CHARSET_ASCII)
    {
      val = ch;
    }
  else if ((charset == charset_big5_1
	    && (XFASTINT (ch) >= 0x250a1 && XFASTINT (ch) <= 0x271ec))
	   || (charset == charset_big5_2
	       && XFASTINT (ch) >= 0x290a1 && XFASTINT (ch) <= 0x2bdb2))
    {
      ENCODE_BIG5 (charset, c1, c2, b1, b2);
      XSETFASTINT (val, (b1 << 8) | b2);
    }
  else
    error ("Can't encode to Big5: %d", XFASTINT (ch));
  return val;
}

DEFUN ("set-terminal-coding-system-internal",
       Fset_terminal_coding_system_internal,
       Sset_terminal_coding_system_internal, 1, 1, 0, "")
  (coding_system)
     Lisp_Object coding_system;
{
  CHECK_SYMBOL (coding_system, 0);
  setup_coding_system (Fcheck_coding_system (coding_system), &terminal_coding);
  /* We had better not send unsafe characters to terminal.  */
  terminal_coding.flags |= CODING_FLAG_ISO_SAFE;

  return Qnil;
}

DEFUN ("set-safe-terminal-coding-system-internal",
       Fset_safe_terminal_coding_system_internal,
       Sset_safe_terminal_coding_system_internal, 1, 1, 0, "")
  (coding_system)
     Lisp_Object coding_system;
{
  CHECK_SYMBOL (coding_system, 0);
  setup_coding_system (Fcheck_coding_system (coding_system),
		       &safe_terminal_coding);
  return Qnil;
}

DEFUN ("terminal-coding-system",
       Fterminal_coding_system, Sterminal_coding_system, 0, 0, 0,
  "Return coding system specified for terminal output.")
  ()
{
  return terminal_coding.symbol;
}

DEFUN ("set-keyboard-coding-system-internal",
       Fset_keyboard_coding_system_internal,
       Sset_keyboard_coding_system_internal, 1, 1, 0, "")
  (coding_system)
     Lisp_Object coding_system;
{
  CHECK_SYMBOL (coding_system, 0);
  setup_coding_system (Fcheck_coding_system (coding_system), &keyboard_coding);
  return Qnil;
}

DEFUN ("keyboard-coding-system",
       Fkeyboard_coding_system, Skeyboard_coding_system, 0, 0, 0,
  "Return coding system specified for decoding keyboard input.")
  ()
{
  return keyboard_coding.symbol;
}


DEFUN ("find-operation-coding-system", Ffind_operation_coding_system,
       Sfind_operation_coding_system,  1, MANY, 0,
  "Choose a coding system for an operation based on the target name.\n\
The value names a pair of coding systems: (DECODING-SYSTEM . ENCODING-SYSTEM).\n\
DECODING-SYSTEM is the coding system to use for decoding\n\
\(in case OPERATION does decoding), and ENCODING-SYSTEM is the coding system\n\
for encoding (in case OPERATION does encoding).\n\
\n\
The first argument OPERATION specifies an I/O primitive:\n\
  For file I/O, `insert-file-contents' or `write-region'.\n\
  For process I/O, `call-process', `call-process-region', or `start-process'.\n\
  For network I/O, `open-network-stream'.\n\
\n\
The remaining arguments should be the same arguments that were passed\n\
to the primitive.  Depending on which primitive, one of those arguments\n\
is selected as the TARGET.  For example, if OPERATION does file I/O,\n\
whichever argument specifies the file name is TARGET.\n\
\n\
TARGET has a meaning which depends on OPERATION:\n\
  For file I/O, TARGET is a file name.\n\
  For process I/O, TARGET is a process name.\n\
  For network I/O, TARGET is a service name or a port number\n\
\n\
This function looks up what specified for TARGET in,\n\
`file-coding-system-alist', `process-coding-system-alist',\n\
or `network-coding-system-alist' depending on OPERATION.\n\
They may specify a coding system, a cons of coding systems,\n\
or a function symbol to call.\n\
In the last case, we call the function with one argument,\n\
which is a list of all the arguments given to this function.")
  (nargs, args)
     int nargs;
     Lisp_Object *args;
{
  Lisp_Object operation, target_idx, target, val;
  register Lisp_Object chain;

  if (nargs < 2)
    error ("Too few arguments");
  operation = args[0];
  if (!SYMBOLP (operation)
      || !INTEGERP (target_idx = Fget (operation, Qtarget_idx)))
    error ("Invalid first arguement");
  if (nargs < 1 + XINT (target_idx))
    error ("Too few arguments for operation: %s",
	   XSYMBOL (operation)->name->data);
  target = args[XINT (target_idx) + 1];
  if (!(STRINGP (target)
	|| (EQ (operation, Qopen_network_stream) && INTEGERP (target))))
    error ("Invalid %dth argument", XINT (target_idx) + 1);

  chain = ((EQ (operation, Qinsert_file_contents)
	    || EQ (operation, Qwrite_region))
	   ? Vfile_coding_system_alist
	   : (EQ (operation, Qopen_network_stream)
	      ? Vnetwork_coding_system_alist
	      : Vprocess_coding_system_alist));
  if (NILP (chain))
    return Qnil;

  for (; CONSP (chain); chain = XCONS (chain)->cdr)
    {
      Lisp_Object elt;
      elt = XCONS (chain)->car;

      if (CONSP (elt)
	  && ((STRINGP (target)
	       && STRINGP (XCONS (elt)->car)
	       && fast_string_match (XCONS (elt)->car, target) >= 0)
	      || (INTEGERP (target) && EQ (target, XCONS (elt)->car))))
	{
	  val = XCONS (elt)->cdr;
	  /* Here, if VAL is both a valid coding system and a valid
             function symbol, we return VAL as a coding system.  */
	  if (CONSP (val))
	    return val;
	  if (! SYMBOLP (val))
	    return Qnil;
	  if (! NILP (Fcoding_system_p (val)))
	    return Fcons (val, val);
	  if (! NILP (Ffboundp (val)))
	    {
	      val = call1 (val, Flist (nargs, args));
	      if (CONSP (val))
		return val;
	      if (SYMBOLP (val) && ! NILP (Fcoding_system_p (val)))
		return Fcons (val, val);
	    }
	  return Qnil;
	}
    }
  return Qnil;
}

DEFUN ("update-coding-systems-internal",  Fupdate_coding_systems_internal,
       Supdate_coding_systems_internal, 0, 0, 0,
  "Update internal database for ISO2022 and CCL based coding systems.\n\
When values of the following coding categories are changed, you must\n\
call this function:\n\
  coding-category-iso-7, coding-category-iso-7-tight,\n\
  coding-category-iso-8-1, coding-category-iso-8-2,\n\
  coding-category-iso-7-else, coding-category-iso-8-else,\n\
  coding-category-ccl")
  ()
{
  int i;

  for (i = CODING_CATEGORY_IDX_ISO_7; i <= CODING_CATEGORY_IDX_CCL; i++)
    {
      Lisp_Object val;

      val = XSYMBOL (XVECTOR (Vcoding_category_table)->contents[i])->value;
      if (!NILP (val))
	{
	  if (! coding_system_table[i])
	    coding_system_table[i] = ((struct coding_system *)
				      xmalloc (sizeof (struct coding_system)));
	  setup_coding_system (val, coding_system_table[i]);
	}
      else if (coding_system_table[i])
	{
	  xfree (coding_system_table[i]);
	  coding_system_table[i] = NULL;
	}
    }

  return Qnil;
}

DEFUN ("set-coding-priority-internal", Fset_coding_priority_internal,
       Sset_coding_priority_internal, 0, 0, 0,
  "Update internal database for the current value of `coding-category-list'.\n\
This function is internal use only.")
  ()
{
  int i = 0, idx;
  Lisp_Object val;

  val = Vcoding_category_list;

  while (CONSP (val) && i < CODING_CATEGORY_IDX_MAX)
    {
      if (! SYMBOLP (XCONS (val)->car))
	break;
      idx = XFASTINT (Fget (XCONS (val)->car, Qcoding_category_index));
      if (idx >= CODING_CATEGORY_IDX_MAX)
	break;
      coding_priorities[i++] = (1 << idx);
      val = XCONS (val)->cdr;
    }
  /* If coding-category-list is valid and contains all coding
     categories, `i' should be CODING_CATEGORY_IDX_MAX now.  If not,
     the following code saves Emacs from craching.  */
  while (i < CODING_CATEGORY_IDX_MAX)
    coding_priorities[i++] = CODING_CATEGORY_MASK_RAW_TEXT;

  return Qnil;
}

#endif /* emacs */


/*** 9. Post-amble ***/

void
init_coding ()
{
  conversion_buffer = (char *) xmalloc (MINIMUM_CONVERSION_BUFFER_SIZE);
}

void
init_coding_once ()
{
  int i;

  /* Emacs' internal format specific initialize routine.  */ 
  for (i = 0; i <= 0x20; i++)
    emacs_code_class[i] = EMACS_control_code;
  emacs_code_class[0x0A] = EMACS_linefeed_code;
  emacs_code_class[0x0D] = EMACS_carriage_return_code;
  for (i = 0x21 ; i < 0x7F; i++)
    emacs_code_class[i] = EMACS_ascii_code;
  emacs_code_class[0x7F] = EMACS_control_code;
  emacs_code_class[0x80] = EMACS_leading_code_composition;
  for (i = 0x81; i < 0xFF; i++)
    emacs_code_class[i] = EMACS_invalid_code;
  emacs_code_class[LEADING_CODE_PRIVATE_11] = EMACS_leading_code_3;
  emacs_code_class[LEADING_CODE_PRIVATE_12] = EMACS_leading_code_3;
  emacs_code_class[LEADING_CODE_PRIVATE_21] = EMACS_leading_code_4;
  emacs_code_class[LEADING_CODE_PRIVATE_22] = EMACS_leading_code_4;

  /* ISO2022 specific initialize routine.  */
  for (i = 0; i < 0x20; i++)
    iso_code_class[i] = ISO_control_code;
  for (i = 0x21; i < 0x7F; i++)
    iso_code_class[i] = ISO_graphic_plane_0;
  for (i = 0x80; i < 0xA0; i++)
    iso_code_class[i] = ISO_control_code;
  for (i = 0xA1; i < 0xFF; i++)
    iso_code_class[i] = ISO_graphic_plane_1;
  iso_code_class[0x20] = iso_code_class[0x7F] = ISO_0x20_or_0x7F;
  iso_code_class[0xA0] = iso_code_class[0xFF] = ISO_0xA0_or_0xFF;
  iso_code_class[ISO_CODE_CR] = ISO_carriage_return;
  iso_code_class[ISO_CODE_SO] = ISO_shift_out;
  iso_code_class[ISO_CODE_SI] = ISO_shift_in;
  iso_code_class[ISO_CODE_SS2_7] = ISO_single_shift_2_7;
  iso_code_class[ISO_CODE_ESC] = ISO_escape;
  iso_code_class[ISO_CODE_SS2] = ISO_single_shift_2;
  iso_code_class[ISO_CODE_SS3] = ISO_single_shift_3;
  iso_code_class[ISO_CODE_CSI] = ISO_control_sequence_introducer;

  conversion_buffer_size = MINIMUM_CONVERSION_BUFFER_SIZE;

  setup_coding_system (Qnil, &keyboard_coding);
  setup_coding_system (Qnil, &terminal_coding);
  setup_coding_system (Qnil, &safe_terminal_coding);
  setup_coding_system (Qnil, &default_buffer_file_coding);

  bzero (coding_system_table, sizeof coding_system_table);

  bzero (ascii_skip_code, sizeof ascii_skip_code);
  for (i = 0; i < 128; i++)
    ascii_skip_code[i] = 1;

#if defined (MSDOS) || defined (WINDOWSNT)
  system_eol_type = CODING_EOL_CRLF;
#else
  system_eol_type = CODING_EOL_LF;
#endif
}

#ifdef emacs

void
syms_of_coding ()
{
  Qtarget_idx = intern ("target-idx");
  staticpro (&Qtarget_idx);

  Qcoding_system_history = intern ("coding-system-history");
  staticpro (&Qcoding_system_history);
  Fset (Qcoding_system_history, Qnil);

  /* Target FILENAME is the first argument.  */
  Fput (Qinsert_file_contents, Qtarget_idx, make_number (0));
  /* Target FILENAME is the third argument.  */
  Fput (Qwrite_region, Qtarget_idx, make_number (2));

  Qcall_process = intern ("call-process");
  staticpro (&Qcall_process);
  /* Target PROGRAM is the first argument.  */
  Fput (Qcall_process, Qtarget_idx, make_number (0));

  Qcall_process_region = intern ("call-process-region");
  staticpro (&Qcall_process_region);
  /* Target PROGRAM is the third argument.  */
  Fput (Qcall_process_region, Qtarget_idx, make_number (2));

  Qstart_process = intern ("start-process");
  staticpro (&Qstart_process);
  /* Target PROGRAM is the third argument.  */
  Fput (Qstart_process, Qtarget_idx, make_number (2));

  Qopen_network_stream = intern ("open-network-stream");
  staticpro (&Qopen_network_stream);
  /* Target SERVICE is the fourth argument.  */
  Fput (Qopen_network_stream, Qtarget_idx, make_number (3));

  Qcoding_system = intern ("coding-system");
  staticpro (&Qcoding_system);

  Qeol_type = intern ("eol-type");
  staticpro (&Qeol_type);

  Qbuffer_file_coding_system = intern ("buffer-file-coding-system");
  staticpro (&Qbuffer_file_coding_system);

  Qpost_read_conversion = intern ("post-read-conversion");
  staticpro (&Qpost_read_conversion);

  Qpre_write_conversion = intern ("pre-write-conversion");
  staticpro (&Qpre_write_conversion);

  Qno_conversion = intern ("no-conversion");
  staticpro (&Qno_conversion);

  Qundecided = intern ("undecided");
  staticpro (&Qundecided);

  Qcoding_system_p = intern ("coding-system-p");
  staticpro (&Qcoding_system_p);

  Qcoding_system_error = intern ("coding-system-error");
  staticpro (&Qcoding_system_error);

  Fput (Qcoding_system_error, Qerror_conditions,
	Fcons (Qcoding_system_error, Fcons (Qerror, Qnil)));
  Fput (Qcoding_system_error, Qerror_message,
	build_string ("Invalid coding system"));

  Qcoding_category = intern ("coding-category");
  staticpro (&Qcoding_category);
  Qcoding_category_index = intern ("coding-category-index");
  staticpro (&Qcoding_category_index);

  Vcoding_category_table
    = Fmake_vector (make_number (CODING_CATEGORY_IDX_MAX), Qnil);
  staticpro (&Vcoding_category_table);
  {
    int i;
    for (i = 0; i < CODING_CATEGORY_IDX_MAX; i++)
      {
	XVECTOR (Vcoding_category_table)->contents[i]
	  = intern (coding_category_name[i]);
	Fput (XVECTOR (Vcoding_category_table)->contents[i],
	      Qcoding_category_index, make_number (i));
      }
  }

  Qtranslation_table = intern ("translation-table");
  staticpro (&Qtranslation_table);
  Fput (Qtranslation_table, Qchar_table_extra_slots, make_number (1));

  Qtranslation_table_id = intern ("translation-table-id");
  staticpro (&Qtranslation_table_id);

  Qtranslation_table_for_decode = intern ("translation-table-for-decode");
  staticpro (&Qtranslation_table_for_decode);

  Qtranslation_table_for_encode = intern ("translation-table-for-encode");
  staticpro (&Qtranslation_table_for_encode);

  Qsafe_charsets = intern ("safe-charsets");
  staticpro (&Qsafe_charsets);

  Qvalid_codes = intern ("valid-codes");
  staticpro (&Qvalid_codes);

  Qemacs_mule = intern ("emacs-mule");
  staticpro (&Qemacs_mule);

  Qraw_text = intern ("raw-text");
  staticpro (&Qraw_text);

  defsubr (&Scoding_system_p);
  defsubr (&Sread_coding_system);
  defsubr (&Sread_non_nil_coding_system);
  defsubr (&Scheck_coding_system);
  defsubr (&Sdetect_coding_region);
  defsubr (&Sdetect_coding_string);
  defsubr (&Sdecode_coding_region);
  defsubr (&Sencode_coding_region);
  defsubr (&Sdecode_coding_string);
  defsubr (&Sencode_coding_string);
  defsubr (&Sdecode_sjis_char);
  defsubr (&Sencode_sjis_char);
  defsubr (&Sdecode_big5_char);
  defsubr (&Sencode_big5_char);
  defsubr (&Sset_terminal_coding_system_internal);
  defsubr (&Sset_safe_terminal_coding_system_internal);
  defsubr (&Sterminal_coding_system);
  defsubr (&Sset_keyboard_coding_system_internal);
  defsubr (&Skeyboard_coding_system);
  defsubr (&Sfind_operation_coding_system);
  defsubr (&Supdate_coding_systems_internal);
  defsubr (&Sset_coding_priority_internal);

  DEFVAR_LISP ("coding-system-list", &Vcoding_system_list,
    "List of coding systems.\n\
\n\
Do not alter the value of this variable manually.  This variable should be\n\
updated by the functions `make-coding-system' and\n\
`define-coding-system-alias'.");
  Vcoding_system_list = Qnil;

  DEFVAR_LISP ("coding-system-alist", &Vcoding_system_alist,
    "Alist of coding system names.\n\
Each element is one element list of coding system name.\n\
This variable is given to `completing-read' as TABLE argument.\n\
\n\
Do not alter the value of this variable manually.  This variable should be\n\
updated by the functions `make-coding-system' and\n\
`define-coding-system-alias'.");
  Vcoding_system_alist = Qnil;

  DEFVAR_LISP ("coding-category-list", &Vcoding_category_list,
    "List of coding-categories (symbols) ordered by priority.");
  {
    int i;

    Vcoding_category_list = Qnil;
    for (i = CODING_CATEGORY_IDX_MAX - 1; i >= 0; i--)
      Vcoding_category_list
	= Fcons (XVECTOR (Vcoding_category_table)->contents[i],
		 Vcoding_category_list);
  }

  DEFVAR_LISP ("coding-system-for-read", &Vcoding_system_for_read,
    "Specify the coding system for read operations.\n\
It is useful to bind this variable with `let', but do not set it globally.\n\
If the value is a coding system, it is used for decoding on read operation.\n\
If not, an appropriate element is used from one of the coding system alists:\n\
There are three such tables, `file-coding-system-alist',\n\
`process-coding-system-alist', and `network-coding-system-alist'.");
  Vcoding_system_for_read = Qnil;

  DEFVAR_LISP ("coding-system-for-write", &Vcoding_system_for_write,
    "Specify the coding system for write operations.\n\
Programs bind this variable with `let', but you should not set it globally.\n\
If the value is a coding system, it is used for encoding of output,\n\
when writing it to a file and when sending it to a file or subprocess.\n\
\n\
If this does not specify a coding system, an appropriate element\n\
is used from one of the coding system alists:\n\
There are three such tables, `file-coding-system-alist',\n\
`process-coding-system-alist', and `network-coding-system-alist'.\n\
For output to files, if the above procedure does not specify a coding system,\n\
the value of `buffer-file-coding-system' is used.");
  Vcoding_system_for_write = Qnil;

  DEFVAR_LISP ("last-coding-system-used", &Vlast_coding_system_used,
    "Coding system used in the latest file or process I/O.");
  Vlast_coding_system_used = Qnil;

  DEFVAR_BOOL ("inhibit-eol-conversion", &inhibit_eol_conversion,
    "*Non-nil means always inhibit code conversion of end-of-line format.\n\
See info node `Coding Systems' and info node `Text and Binary' concerning\n\
such conversion.");
  inhibit_eol_conversion = 0;

  DEFVAR_BOOL ("inherit-process-coding-system", &inherit_process_coding_system,
    "Non-nil means process buffer inherits coding system of process output.\n\
Bind it to t if the process output is to be treated as if it were a file\n\
read from some filesystem.");
  inherit_process_coding_system = 0;

  DEFVAR_LISP ("file-coding-system-alist", &Vfile_coding_system_alist,
    "Alist to decide a coding system to use for a file I/O operation.\n\
The format is ((PATTERN . VAL) ...),\n\
where PATTERN is a regular expression matching a file name,\n\
VAL is a coding system, a cons of coding systems, or a function symbol.\n\
If VAL is a coding system, it is used for both decoding and encoding\n\
the file contents.\n\
If VAL is a cons of coding systems, the car part is used for decoding,\n\
and the cdr part is used for encoding.\n\
If VAL is a function symbol, the function must return a coding system\n\
or a cons of coding systems which are used as above.\n\
\n\
See also the function `find-operation-coding-system'\n\
and the variable `auto-coding-alist'.");
  Vfile_coding_system_alist = Qnil;

  DEFVAR_LISP ("process-coding-system-alist", &Vprocess_coding_system_alist,
    "Alist to decide a coding system to use for a process I/O operation.\n\
The format is ((PATTERN . VAL) ...),\n\
where PATTERN is a regular expression matching a program name,\n\
VAL is a coding system, a cons of coding systems, or a function symbol.\n\
If VAL is a coding system, it is used for both decoding what received\n\
from the program and encoding what sent to the program.\n\
If VAL is a cons of coding systems, the car part is used for decoding,\n\
and the cdr part is used for encoding.\n\
If VAL is a function symbol, the function must return a coding system\n\
or a cons of coding systems which are used as above.\n\
\n\
See also the function `find-operation-coding-system'.");
  Vprocess_coding_system_alist = Qnil;

  DEFVAR_LISP ("network-coding-system-alist", &Vnetwork_coding_system_alist,
    "Alist to decide a coding system to use for a network I/O operation.\n\
The format is ((PATTERN . VAL) ...),\n\
where PATTERN is a regular expression matching a network service name\n\
or is a port number to connect to,\n\
VAL is a coding system, a cons of coding systems, or a function symbol.\n\
If VAL is a coding system, it is used for both decoding what received\n\
from the network stream and encoding what sent to the network stream.\n\
If VAL is a cons of coding systems, the car part is used for decoding,\n\
and the cdr part is used for encoding.\n\
If VAL is a function symbol, the function must return a coding system\n\
or a cons of coding systems which are used as above.\n\
\n\
See also the function `find-operation-coding-system'.");
  Vnetwork_coding_system_alist = Qnil;

  DEFVAR_LISP ("eol-mnemonic-unix", &eol_mnemonic_unix,
    "*String displayed in mode line for UNIX-like (LF) end-of-line format.");
  eol_mnemonic_unix = build_string (":");

  DEFVAR_LISP ("eol-mnemonic-dos", &eol_mnemonic_dos,
    "*String displayed in mode line for DOS-like (CRLF) end-of-line format.");
  eol_mnemonic_dos = build_string ("\\");

  DEFVAR_LISP ("eol-mnemonic-mac", &eol_mnemonic_mac,
    "*String displayed in mode line for MAC-like (CR) end-of-line format.");
  eol_mnemonic_mac = build_string ("/");

  DEFVAR_LISP ("eol-mnemonic-undecided", &eol_mnemonic_undecided,
    "*String displayed in mode line when end-of-line format is not yet determined.");
  eol_mnemonic_undecided = build_string (":");

  DEFVAR_LISP ("enable-character-translation", &Venable_character_translation,
    "*Non-nil enables character translation while encoding and decoding.");
  Venable_character_translation = Qt;

  DEFVAR_LISP ("standard-translation-table-for-decode",
    &Vstandard_translation_table_for_decode,
    "Table for translating characters while decoding.");
  Vstandard_translation_table_for_decode = Qnil;

  DEFVAR_LISP ("standard-translation-table-for-encode",
    &Vstandard_translation_table_for_encode,
    "Table for translationg characters while encoding.");
  Vstandard_translation_table_for_encode = Qnil;

  DEFVAR_LISP ("charset-revision-table", &Vcharset_revision_alist,
    "Alist of charsets vs revision numbers.\n\
While encoding, if a charset (car part of an element) is found,\n\
designate it with the escape sequence identifing revision (cdr part of the element).");
  Vcharset_revision_alist = Qnil;

  DEFVAR_LISP ("default-process-coding-system",
	       &Vdefault_process_coding_system,
    "Cons of coding systems used for process I/O by default.\n\
The car part is used for decoding a process output,\n\
the cdr part is used for encoding a text to be sent to a process.");
  Vdefault_process_coding_system = Qnil;

  DEFVAR_LISP ("latin-extra-code-table", &Vlatin_extra_code_table,
    "Table of extra Latin codes in the range 128..159 (inclusive).\n\
This is a vector of length 256.\n\
If Nth element is non-nil, the existence of code N in a file\n\
\(or output of subprocess) doesn't prevent it to be detected as\n\
a coding system of ISO 2022 variant which has a flag\n\
`accept-latin-extra-code' t (e.g. iso-latin-1) on reading a file\n\
or reading output of a subprocess.\n\
Only 128th through 159th elements has a meaning.");
  Vlatin_extra_code_table = Fmake_vector (make_number (256), Qnil);

  DEFVAR_LISP ("select-safe-coding-system-function",
	       &Vselect_safe_coding_system_function,
    "Function to call to select safe coding system for encoding a text.\n\
\n\
If set, this function is called to force a user to select a proper\n\
coding system which can encode the text in the case that a default\n\
coding system used in each operation can't encode the text.\n\
\n\
The default value is `select-safe-coding-system' (which see).");
  Vselect_safe_coding_system_function = Qnil;

}

#endif /* emacs */
