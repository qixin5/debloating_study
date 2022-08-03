/* Fundamental definitions for GNU Emacs Lisp interpreter.
   Copyright (C) 1985,86,87,93,94,95,97,1998 Free Software Foundation, Inc.

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


/* These are default choices for the types to use.  */
#ifndef EMACS_INT
#define EMACS_INT int
#define BITS_PER_EMACS_INT BITS_PER_INT
#endif
#ifndef EMACS_UINT
#define EMACS_UINT unsigned int
#endif

/* Define the fundamental Lisp data structures.  */

/* This is the set of Lisp data types.  */

enum Lisp_Type
  {
    /* Integer.  XINT (obj) is the integer value.  */
    Lisp_Int,

    /* Symbol.  XSYMBOL (object) points to a struct Lisp_Symbol.  */
    Lisp_Symbol,

    /* Miscellaneous.  XMISC (object) points to a union Lisp_Misc,
       whose first member indicates the subtype.  */
    Lisp_Misc,

    /* String.  XSTRING (object) points to a struct Lisp_String.
       The length of the string, and its contents, are stored therein.  */
    Lisp_String,

    /* Vector of Lisp objects, or something resembling it.
       XVECTOR (object) points to a struct Lisp_Vector, which contains
       the size and contents.  The size field also contains the type
       information, if it's not a real vector object.  */
    Lisp_Vectorlike,

    /* Cons.  XCONS (object) points to a struct Lisp_Cons.  */
    Lisp_Cons,

#ifdef LISP_FLOAT_TYPE
    Lisp_Float,
#endif /* LISP_FLOAT_TYPE */

    /* This is not a type code.  It is for range checking.  */
    Lisp_Type_Limit
  };

/* This is the set of datatypes that share a common structure.
   The first member of the structure is a type code from this set.
   The enum values are arbitrary, but we'll use large numbers to make it
   more likely that we'll spot the error if a random word in memory is
   mistakenly interpreted as a Lisp_Misc.  */
enum Lisp_Misc_Type
  {
    Lisp_Misc_Free = 0x5eab,
    Lisp_Misc_Marker,
    Lisp_Misc_Intfwd,
    Lisp_Misc_Boolfwd,
    Lisp_Misc_Objfwd,
    Lisp_Misc_Buffer_Objfwd,
    Lisp_Misc_Buffer_Local_Value,
    Lisp_Misc_Some_Buffer_Local_Value,
    Lisp_Misc_Overlay,
    Lisp_Misc_Kboard_Objfwd,
    /* Currently floats are not a misc type,
       but let's define this in case we want to change that.  */
    Lisp_Misc_Float,
    /* This is not a type code.  It is for range checking.  */
    Lisp_Misc_Limit
  };

/* These values are overridden by the m- file on some machines.  */
#ifndef VALBITS
#define VALBITS 28
#endif

#ifndef GCTYPEBITS
#define GCTYPEBITS 3
#endif

/* Make these values available in GDB, which sees enums but not macros.  */

enum gdb_lisp_params
{
  gdb_valbits = VALBITS,
  gdb_gctypebits = GCTYPEBITS,
  gdb_emacs_intbits = sizeof (EMACS_INT) * BITS_PER_CHAR,
#ifdef DATA_SEG_BITS
  gdb_data_seg_bits = DATA_SEG_BITS
#else
  gdb_data_seg_bits = 0
#endif
};

#ifndef NO_UNION_TYPE

#ifndef WORDS_BIG_ENDIAN

/* Definition of Lisp_Object for little-endian machines.  */

typedef
union Lisp_Object
  {
    /* Used for comparing two Lisp_Objects;
       also, positive integers can be accessed fast this way.  */
    int i;

    struct
      {
	int val: VALBITS;
	int type: GCTYPEBITS+1;
      } s;
    struct
      {
	unsigned int val: VALBITS;
	int type: GCTYPEBITS+1;
      } u;
    struct
      {
	unsigned int val: VALBITS;
	enum Lisp_Type type: GCTYPEBITS;
	/* The markbit is not really part of the value of a Lisp_Object,
	   and is always zero except during garbage collection.  */
	unsigned int markbit: 1;
      } gu;
  }
Lisp_Object;

#else /* If WORDS_BIG_ENDIAN */

typedef
union Lisp_Object
  {
    /* Used for comparing two Lisp_Objects;
       also, positive integers can be accessed fast this way.  */
    int i;

    struct
      {
	int type: GCTYPEBITS+1;
	int val: VALBITS;
      } s;
    struct
      {
	int type: GCTYPEBITS+1;
	unsigned int val: VALBITS;
      } u;
    struct
      {
	/* The markbit is not really part of the value of a Lisp_Object,
	   and is always zero except during garbage collection.  */
	unsigned int markbit: 1;
	enum Lisp_Type type: GCTYPEBITS;
	unsigned int val: VALBITS;
      } gu;
  }
Lisp_Object;

#endif /* WORDS_BIG_ENDIAN */

#endif /* NO_UNION_TYPE */


/* If union type is not wanted, define Lisp_Object as just a number.  */

#ifdef NO_UNION_TYPE
#define Lisp_Object EMACS_INT
#endif /* NO_UNION_TYPE */

#ifndef VALMASK
#define VALMASK ((((EMACS_INT) 1)<<VALBITS) - 1)
#endif
#define GCTYPEMASK ((((EMACS_INT) 1)<<GCTYPEBITS) - 1)

/* Two flags that are set during GC.  On some machines, these flags
   are defined differently by the m- file.  */

/* This is set in the car of a cons and in the plist slot of a symbol
   to indicate it is marked.  Likewise in the plist slot of an interval,
   the chain slot of a marker, the type slot of a float, and the name
   slot of a buffer.

   In strings, this bit in the size field indicates that the string
   is a "large" one, one which was separately malloc'd
   rather than being part of a string block.  */

#ifndef MARKBIT
#define MARKBIT ((int) ((unsigned int) 1 << (VALBITS + GCTYPEBITS)))
#endif /*MARKBIT */

/* In the size word of a vector, this bit means the vector has been marked.
   In the size word of a large string, likewise.  */

#ifndef ARRAY_MARK_FLAG
#define ARRAY_MARK_FLAG ((MARKBIT >> 1) & ~MARKBIT)
#endif /* no ARRAY_MARK_FLAG */

/* In the size word of a struct Lisp_Vector, this bit means it's really
   some other vector-like object.  */
#ifndef PSEUDOVECTOR_FLAG
#define PSEUDOVECTOR_FLAG ((ARRAY_MARK_FLAG >> 1) & ~ARRAY_MARK_FLAG)
#endif

/* In a pseudovector, the size field actually contains a word with one
   PSEUDOVECTOR_FLAG bit set, and exactly one of the following bits to
   indicate the actual type.  */
enum pvec_type
{
  PVEC_NORMAL_VECTOR = 0,
  PVEC_PROCESS = 0x200,
  PVEC_FRAME = 0x400,
  PVEC_COMPILED = 0x800,
  PVEC_WINDOW = 0x1000,
  PVEC_WINDOW_CONFIGURATION = 0x2000,
  PVEC_SUBR = 0x4000,
  PVEC_CHAR_TABLE = 0x8000,
  PVEC_BOOL_VECTOR = 0x10000,
  PVEC_BUFFER = 0x20000,
  PVEC_TYPE_MASK = 0x3fe00,
  PVEC_FLAG = PSEUDOVECTOR_FLAG
};

/* For convenience, we also store the number of elements in these bits.  */
#define PSEUDOVECTOR_SIZE_MASK 0x1ff

/* These macros extract various sorts of values from a Lisp_Object.
 For example, if tem is a Lisp_Object whose type is Lisp_Cons,
 XCONS (tem) is the struct Lisp_Cons * pointing to the memory for that cons.  */

#ifdef NO_UNION_TYPE

/* One need to override this if there must be high bits set in data space
   (doing the result of the below & ((1 << (GCTYPE + 1)) - 1) would work
    on all machines, but would penalise machines which don't need it)
 */
#ifndef XTYPE
#define XTYPE(a) ((enum Lisp_Type) ((a) >> VALBITS))
#endif

#ifndef XSETTYPE
#define XSETTYPE(a, b) ((a)  =  XUINT (a) | ((EMACS_INT)(b) << VALBITS))
#endif

/* For integers known to be positive, XFASTINT provides fast retrieval
   and XSETFASTINT provides fast storage.  This takes advantage of the
   fact that Lisp_Int is 0.  */
#define XFASTINT(a) ((a) + 0)
#define XSETFASTINT(a, b) ((a) = (b))

/* Extract the value of a Lisp_Object as a signed integer.  */

#ifndef XINT   /* Some machines need to do this differently.  */
#define XINT(a) (((a) << (BITS_PER_INT-VALBITS)) >> (BITS_PER_INT-VALBITS))
#endif

/* Extract the value as an unsigned integer.  This is a basis
   for extracting it as a pointer to a structure in storage.  */

#ifndef XUINT
#define XUINT(a) ((a) & VALMASK)
#endif

#ifndef XPNTR
#ifdef HAVE_SHM
/* In this representation, data is found in two widely separated segments.  */
extern int pure_size;
#define XPNTR(a) \
  (XUINT (a) | (XUINT (a) > pure_size ? DATA_SEG_BITS : PURE_SEG_BITS))
#else /* not HAVE_SHM */
#ifdef DATA_SEG_BITS
/* This case is used for the rt-pc.
   In the diffs I was given, it checked for ptr = 0
   and did not adjust it in that case.
   But I don't think that zero should ever be found
   in a Lisp object whose data type says it points to something.  */
#define XPNTR(a) (XUINT (a) | DATA_SEG_BITS)
#else
#define XPNTR(a) XUINT (a)
#endif
#endif /* not HAVE_SHM */
#endif /* no XPNTR */

#ifndef XSET
#define XSET(var, type, ptr) \
   ((var) = ((EMACS_INT)(type) << VALBITS) + ((EMACS_INT) (ptr) & VALMASK))
#endif

/* Convert a C integer into a Lisp_Object integer.  */

#define make_number(N)		\
  ((((EMACS_INT) (N)) & VALMASK) | ((EMACS_INT) Lisp_Int) << VALBITS)

/* During garbage collection, XGCTYPE must be used for extracting types
 so that the mark bit is ignored.  XMARKBIT accesses the markbit.
 Markbits are used only in particular slots of particular structure types.
 Other markbits are always zero.
 Outside of garbage collection, all mark bits are always zero.  */

#ifndef XGCTYPE
#define XGCTYPE(a) ((enum Lisp_Type) (((a) >> VALBITS) & GCTYPEMASK))
#endif

#if VALBITS + GCTYPEBITS == BITS_PER_EMACS_INT - 1
/* Make XMARKBIT faster if mark bit is sign bit.  */
#ifndef XMARKBIT
#define XMARKBIT(a) ((a) < 0)
#endif
#endif /* markbit is sign bit */

#ifndef XMARKBIT
#define XMARKBIT(a) ((a) & MARKBIT)
#endif

#ifndef XSETMARKBIT
#define XSETMARKBIT(a,b) ((a) = ((a) & ~MARKBIT) | ((b) ? MARKBIT : 0))
#endif

#ifndef XMARK
#define XMARK(a) ((a) |= MARKBIT)
#endif

#ifndef XUNMARK
#define XUNMARK(a) ((a) &= ~MARKBIT)
#endif

#endif /* NO_UNION_TYPE */

#ifndef NO_UNION_TYPE

#define XTYPE(a) ((enum Lisp_Type) (a).u.type)
#define XSETTYPE(a, b) ((a).u.type = (char) (b))

/* For integers known to be positive, XFASTINT provides fast retrieval
   and XSETFASTINT provides fast storage.  This takes advantage of the
   fact that Lisp_Int is 0.  */
#define XFASTINT(a) ((a).i + 0)
#define XSETFASTINT(a, b) ((a).i = (b))

#ifdef EXPLICIT_SIGN_EXTEND
/* Make sure we sign-extend; compilers have been known to fail to do so.  */
#define XINT(a) (((a).i << (BITS_PER_INT-VALBITS)) >> (BITS_PER_INT-VALBITS))
#else
#define XINT(a) ((a).s.val)
#endif /* EXPLICIT_SIGN_EXTEND */

#define XUINT(a) ((a).u.val)
#define XPNTR(a) ((a).u.val)

#define XSET(var, vartype, ptr) \
   (((var).s.type = ((char) (vartype))), ((var).s.val = ((int) (ptr))))

extern Lisp_Object make_number ();

/* During garbage collection, XGCTYPE must be used for extracting types
 so that the mark bit is ignored.  XMARKBIT access the markbit.
 Markbits are used only in particular slots of particular structure types.
 Other markbits are always zero.
 Outside of garbage collection, all mark bits are always zero.  */

#define XGCTYPE(a) ((a).gu.type)
#define XMARKBIT(a) ((a).gu.markbit)
#define XSETMARKBIT(a,b) (XMARKBIT(a) = (b))
#define XMARK(a) (XMARKBIT(a) = 1)
#define XUNMARK(a) (XMARKBIT(a) = 0)

#endif /* NO_UNION_TYPE */

/* Extract a value or address from a Lisp_Object.  */

#define XCONS(a) ((struct Lisp_Cons *) XPNTR(a))
#define XVECTOR(a) ((struct Lisp_Vector *) XPNTR(a))
#define XSTRING(a) ((struct Lisp_String *) XPNTR(a))
#define XSYMBOL(a) ((struct Lisp_Symbol *) XPNTR(a))
#define XFLOAT(a) ((struct Lisp_Float *) XPNTR(a))

/* Misc types.  */
#define XMISC(a)   ((union Lisp_Misc *) XPNTR(a))
#define XMISCTYPE(a)   (XMARKER (a)->type)
#define XMARKER(a) (&(XMISC(a)->u_marker))
#define XINTFWD(a) (&(XMISC(a)->u_intfwd))
#define XBOOLFWD(a) (&(XMISC(a)->u_boolfwd))
#define XOBJFWD(a) (&(XMISC(a)->u_objfwd))
#define XBUFFER_OBJFWD(a) (&(XMISC(a)->u_buffer_objfwd))
#define XBUFFER_LOCAL_VALUE(a) (&(XMISC(a)->u_buffer_local_value))
#define XOVERLAY(a) (&(XMISC(a)->u_overlay))
#define XKBOARD_OBJFWD(a) (&(XMISC(a)->u_kboard_objfwd))

/* Pseudovector types.  */
#define XPROCESS(a) ((struct Lisp_Process *) XPNTR(a))
#define XWINDOW(a) ((struct window *) XPNTR(a))
#define XSUBR(a) ((struct Lisp_Subr *) XPNTR(a))
#define XBUFFER(a) ((struct buffer *) XPNTR(a))
#define XCHAR_TABLE(a) ((struct Lisp_Char_Table *) XPNTR(a))
#define XBOOL_VECTOR(a) ((struct Lisp_Bool_Vector *) XPNTR(a))


/* Construct a Lisp_Object from a value or address.  */

#define XSETINT(a, b) XSET (a, Lisp_Int, b)
#define XSETCONS(a, b) XSET (a, Lisp_Cons, b)
#define XSETVECTOR(a, b) XSET (a, Lisp_Vectorlike, b)
#define XSETSTRING(a, b) XSET (a, Lisp_String, b)
#define XSETSYMBOL(a, b) XSET (a, Lisp_Symbol, b)
#define XSETFLOAT(a, b) XSET (a, Lisp_Float, b)

/* Misc types.  */
#define XSETMISC(a, b) XSET (a, Lisp_Misc, b)
#define XSETMARKER(a, b) (XSETMISC (a, b), XMISCTYPE (a) = Lisp_Misc_Marker)

/* Pseudovector types.  */
#define XSETPSEUDOVECTOR(a, b, code) \
  (XSETVECTOR (a, b), XVECTOR (a)->size |= PSEUDOVECTOR_FLAG | (code))
#define XSETWINDOW_CONFIGURATION(a, b) \
  (XSETPSEUDOVECTOR (a, b, PVEC_WINDOW_CONFIGURATION))
#define XSETPROCESS(a, b) (XSETPSEUDOVECTOR (a, b, PVEC_PROCESS))
#define XSETWINDOW(a, b) (XSETPSEUDOVECTOR (a, b, PVEC_WINDOW))
#define XSETSUBR(a, b) (XSETPSEUDOVECTOR (a, b, PVEC_SUBR))
#define XSETCOMPILED(a, b) (XSETPSEUDOVECTOR (a, b, PVEC_COMPILED))
#define XSETBUFFER(a, b) (XSETPSEUDOVECTOR (a, b, PVEC_BUFFER))
#define XSETCHAR_TABLE(a, b) (XSETPSEUDOVECTOR (a, b, PVEC_CHAR_TABLE))
#define XSETBOOL_VECTOR(a, b) (XSETPSEUDOVECTOR (a, b, PVEC_BOOL_VECTOR))

#ifdef USE_TEXT_PROPERTIES
/* Basic data type for use of intervals.  See the macros in intervals.h.  */

struct interval
{
  /* The first group of entries deal with the tree structure.  */

  unsigned int total_length;	/* Length of myself and both children.  */
  unsigned int position;	/* Cache of interval's character position.  */
				/* This field is usually updated
				   simultaneously with an interval
				   traversal, there is no guaranty
				   that it is valid for a random
				   interval.  */
  struct interval *left;	/* Intervals which precede me.  */
  struct interval *right;	/* Intervals which succeed me.  */

  /* Parent in the tree, or the Lisp_Object containing this interval tree.

     The mark bit on the root interval of an interval tree says
     whether we have started (and possibly finished) marking the
     tree.  If GC comes across an interval tree whose root's parent
     field has its markbit set, it leaves the tree alone.

     You'd think we could store this information in the parent object
     somewhere (after all, that should be visited once and then
     ignored too, right?), but strings are GC'd strangely.  */
  struct interval *parent;

  /* The remaining components are `properties' of the interval.
     The first four are duplicates for things which can be on the list,
     for purposes of speed.  */

  unsigned char write_protect;	    /* Non-zero means can't modify.  */
  unsigned char visible;	    /* Zero means don't display.  */
  unsigned char front_sticky;	    /* Non-zero means text inserted just
				       before this interval goes into it.  */
  unsigned char rear_sticky;	    /* Likewise for just after it.  */

  /* Properties of this interval.
     The mark bit on this field says whether this particular interval
     tree node has been visited.  Since intervals should never be
     shared, GC aborts if it seems to have visited an interval twice.  */
  Lisp_Object plist;
};

typedef struct interval *INTERVAL;

/* Complain if object is not string or buffer type */
#define CHECK_STRING_OR_BUFFER(x, i) \
  { if (!STRINGP ((x)) && !BUFFERP ((x))) \
      x = wrong_type_argument (Qbuffer_or_string_p, (x)); }

/* Macro used to conditionally compile intervals into certain data
   structures.  See, e.g., struct Lisp_String below.  */
#define DECLARE_INTERVALS INTERVAL intervals;

/* Macro used to conditionally compile interval initialization into
   certain code.  See, e.g., alloc.c.  */
#define INITIALIZE_INTERVAL(ptr,val) ptr->intervals = val

#else  /* No text properties */

/* If no intervals are used, make the above definitions go away.  */

#define CHECK_STRING_OR_BUFFER(x, i)

#define INTERVAL
#define DECLARE_INTERVALS
#define INITIALIZE_INTERVAL(ptr,val)

#endif /* USE_TEXT_PROPERTIES */

/* In a cons, the markbit of the car is the gc mark bit */

struct Lisp_Cons
  {
    Lisp_Object car, cdr;
  };

/* Take the car or cdr of something known to be a cons cell.  */
#define XCAR(c) (XCONS ((c))->car)
#define XCDR(c) (XCONS ((c))->cdr)

/* Take the car or cdr of something whose type is not known.  */
#define CAR(c)					\
 (CONSP ((c)) ? XCAR ((c))			\
  : NILP ((c)) ? Qnil				\
  : wrong_type_argument (Qlistp, (c)))

#define CDR(c)					\
 (CONSP ((c)) ? XCDR ((c))			\
  : NILP ((c)) ? Qnil				\
  : wrong_type_argument (Qlistp, (c)))

/* Like a cons, but records info on where the text lives that it was read from */
/* This is not really in use now */

struct Lisp_Buffer_Cons
  {
    Lisp_Object car, cdr;
    struct buffer *buffer;
    int bufpos;
  };

/* Nonzero if STR is a multibyte string.  */
#define STRING_MULTIBYTE(STR)  \
  (XSTRING (STR)->size_byte >= 0)

/* Return the length in bytes of STR.  */
#define STRING_BYTES(STR)  \
  ((STR)->size_byte < 0 ? (STR)->size : (STR)->size_byte)

/* Set the length in bytes of STR.  */
#define SET_STRING_BYTES(STR, SIZE)  ((STR)->size_byte = (SIZE))

/* In a string or vector, the sign bit of the `size' is the gc mark bit */

struct Lisp_String
  {
    EMACS_INT size;
    EMACS_INT size_byte;
    DECLARE_INTERVALS		/* `data' field must be last.  */
    unsigned char data[1];
  };

/* If a struct is made to look like a vector, this macro returns the length
   of the shortest vector that would hold that struct.  */
#define VECSIZE(type) ((sizeof (type) - (sizeof (struct Lisp_Vector)  \
                                         - sizeof (Lisp_Object))      \
                        + sizeof(Lisp_Object) - 1) /* round up */     \
		       / sizeof (Lisp_Object))

struct Lisp_Vector
  {
    EMACS_INT size;
    struct Lisp_Vector *next;
    Lisp_Object contents[1];
  };

/* A char table is a kind of vectorlike, with contents are like a
   vector but with a few other slots.  For some purposes, it makes
   sense to handle a chartable with type struct Lisp_Vector.  An
   element of a char table can be any Lisp objects, but if it is a sub
   char-table, we treat it a table that contains information of a
   group of characters of the same charsets or a specific character of
   a charset.  A sub char-table has the same structure as a char table
   except for that the former omits several slots at the tail.  A sub
   char table appears only in an element of a char table, and there's
   no way to access it directly from Emacs Lisp program.  */

/* This is the number of slots that apply to characters or character
   sets.  The first 128 are for ASCII, the next 128 are for 8-bit
   European characters, and the last 128 are for multibyte characters.
   The first 256 are indexed by the code itself, but the last 128 are
   indexed by (charset-id + 128).  */
#define CHAR_TABLE_ORDINARY_SLOTS 384

/* This is the number of slots that apply to characters of ASCII and
   8-bit Europeans only.  */
#define CHAR_TABLE_SINGLE_BYTE_SLOTS 256

/* This is the number of slots that every char table must have.  This
   counts the ordinary slots and the top, defalt, parent, and purpose
   slots.  */
#define CHAR_TABLE_STANDARD_SLOTS (CHAR_TABLE_ORDINARY_SLOTS + 4)

/* This is the number of slots that apply to position-code-1 and
   position-code-2 of a multibyte character at the 2nd and 3rd level
   sub char tables respectively.  */
#define SUB_CHAR_TABLE_ORDINARY_SLOTS 128

/* This is the number of slots that every sub char table must have.
   This counts the ordinary slots and the top and defalt slot.  */
#define SUB_CHAR_TABLE_STANDARD_SLOTS (SUB_CHAR_TABLE_ORDINARY_SLOTS + 2)

/* Return the number of "extra" slots in the char table CT.  */

#define CHAR_TABLE_EXTRA_SLOTS(CT)	\
  (((CT)->size & PSEUDOVECTOR_SIZE_MASK) - CHAR_TABLE_STANDARD_SLOTS)

/* Almost equivalent to Faref (CT, IDX) with optimization for ASCII
   and 8-bit Europeans characters.  For these characters, do not check
   validity of CT.  Do not follow parent.  */
#define CHAR_TABLE_REF(CT, IDX)				\
  ((IDX) >= 0 && (IDX) < CHAR_TABLE_SINGLE_BYTE_SLOTS	\
   ? (!NILP (XCHAR_TABLE (CT)->contents[IDX])		\
      ? XCHAR_TABLE (CT)->contents[IDX]			\
      : XCHAR_TABLE (CT)->defalt)			\
   : Faref (CT, make_number (IDX)))

/* Almost equivalent to Faref (CT, IDX) with optimization for ASCII
   and 8-bit Europeans characters.  However, if the result is nil,
   return IDX.

   For these characters, do not check validity of CT
   and do not follow parent.  */
#define CHAR_TABLE_TRANSLATE(CT, IDX)			\
  ((IDX) < CHAR_TABLE_SINGLE_BYTE_SLOTS			\
   ? (!NILP (XCHAR_TABLE (CT)->contents[IDX])		\
      ? XINT (XCHAR_TABLE (CT)->contents[IDX])		\
      : IDX)						\
   : char_table_translate (CT, IDX))

/* Equivalent to Faset (CT, IDX, VAL) with optimization for ASCII and
   8-bit Europeans characters.  Do not check validity of CT.  */
#define CHAR_TABLE_SET(CT, IDX, VAL)			\
  do {							\
    if (XFASTINT (IDX) < CHAR_TABLE_SINGLE_BYTE_SLOTS)	\
      XCHAR_TABLE (CT)->contents[XFASTINT (IDX)] = VAL;	\
    else						\
      Faset (CT, IDX, VAL);				\
  } while (0)

struct Lisp_Char_Table
  {
    /* This is the vector's size field, which also holds the
       pseudovector type information.  It holds the size, too.
       The size counts the top, defalt, purpose, and parent slots.
       The last three are not counted if this is a sub char table.  */
    EMACS_INT size;
    struct Lisp_Vector *next;
    /* This holds a flag to tell if this is a top level char table (t)
       or a sub char table (nil).  */
    Lisp_Object top;
    /* This holds a default value,
       which is used whenever the value for a specific character is nil.  */
    Lisp_Object defalt;
    /* This holds an actual value of each element.  A sub char table
       has only SUB_CHAR_TABLE_ORDINARY_SLOTS number of elements.  */
    Lisp_Object contents[CHAR_TABLE_ORDINARY_SLOTS];

    /* A sub char table doesn't has the following slots.  */

    /* This points to another char table, which we inherit from
       when the value for a specific character is nil.
       The `defalt' slot takes precedence over this.  */
    Lisp_Object parent;
    /* This should be a symbol which says what kind of use
       this char-table is meant for.
       Typically now the values can be `syntax-table' and `display-table'.  */
    Lisp_Object purpose;
    /* These hold additional data.  */
    Lisp_Object extras[1];
  };

/* A boolvector is a kind of vectorlike, with contents are like a string.  */
struct Lisp_Bool_Vector
  {
    /* This is the vector's size field.  It doesn't have the real size,
       just the subtype information.  */
    EMACS_INT vector_size;
    struct Lisp_Vector *next;
    /* This is the size in bits.  */
    EMACS_INT size;
    /* This contains the actual bits, packed into bytes.  */
    unsigned char data[1];
  };

/* In a symbol, the markbit of the plist is used as the gc mark bit */

struct Lisp_Symbol
  {
    struct Lisp_String *name;
    Lisp_Object value;
    Lisp_Object function;
    Lisp_Object plist;
    Lisp_Object obarray;
    struct Lisp_Symbol *next;	/* -> next symbol in this obarray bucket */
  };

/* This structure describes a built-in function.
   It is generated by the DEFUN macro only.
   defsubr makes it into a Lisp object.

   This type is treated in most respects as a pseudovector,
   but since we never dynamically allocate or free them,
   we don't need a next-vector field.  */

struct Lisp_Subr
  {
    EMACS_INT size;
    Lisp_Object (*function) ();
    short min_args, max_args;
    char *symbol_name;
    char *prompt;
    char *doc;
  };

/* These structures are used for various misc types.  */

/* A miscellaneous object, when it's on the free list.  */
struct Lisp_Free
  {
    int type : 16;	/* = Lisp_Misc_Free */
    int spacer : 16;
    union Lisp_Misc *chain;
  };

/* In a marker, the markbit of the chain field is used as the gc mark bit.  */
struct Lisp_Marker
{
  int type : 16;		/* = Lisp_Misc_Marker */
  int spacer : 15;
  /* 1 means normal insertion at the marker's position
     leaves the marker after the inserted text.  */
  unsigned int insertion_type : 1;
  /* This is the buffer that the marker points into,
     or 0 if it points nowhere.  */
  struct buffer *buffer;

  /* The remaining fields are meaningless in a marker that
     does not point anywhere.  */

  /* For markers that point somewhere,
     this is used to chain of all the markers in a given buffer.  */
  Lisp_Object chain;
  /* This is the char position where the marker points.  */
  int charpos;
  /* This is the byte position.  */
  int bytepos;
};

/* Forwarding pointer to an int variable.
   This is allowed only in the value cell of a symbol,
   and it means that the symbol's value really lives in the
   specified int variable.  */
struct Lisp_Intfwd
  {
    int type : 16;	/* = Lisp_Misc_Intfwd */
    int spacer : 16;
    int *intvar;
  };

/* Boolean forwarding pointer to an int variable.
   This is like Lisp_Intfwd except that the ostensible
   "value" of the symbol is t if the int variable is nonzero,
   nil if it is zero.  */
struct Lisp_Boolfwd
  {
    int type : 16;	/* = Lisp_Misc_Boolfwd */
    int spacer : 16;
    int *boolvar;
  };

/* Forwarding pointer to a Lisp_Object variable.
   This is allowed only in the value cell of a symbol,
   and it means that the symbol's value really lives in the
   specified variable.  */
struct Lisp_Objfwd
  {
    int type : 16;	/* = Lisp_Misc_Objfwd */
    int spacer : 16;
    Lisp_Object *objvar;
  };

/* Like Lisp_Objfwd except that value lives in a slot in the
   current buffer.  Value is byte index of slot within buffer.  */
struct Lisp_Buffer_Objfwd
  {
    int type : 16;	/* = Lisp_Misc_Buffer_Objfwd */
    int spacer : 16;
    int offset;
  };

/* Used in a symbol value cell when the symbol's value is per-buffer.
   The actual contents resemble a cons cell which starts a list like this:
   (REALVALUE BUFFER CURRENT-ALIST-ELEMENT . DEFAULT-VALUE).

   The cons-like structure is for historical reasons; it might be better
   to just put these elements into the struct, now.

   BUFFER is the last buffer for which this symbol's value was
   made up to date.

   CURRENT-ALIST-ELEMENT is a pointer to an element of BUFFER's
   local_var_alist, that being the element whose car is this
   variable.  Or it can be a pointer to the
   (CURRENT-ALIST-ELEMENT . DEFAULT-VALUE),
   if BUFFER does not have an element in its alist for this
   variable (that is, if BUFFER sees the default value of this
   variable).

   If we want to examine or set the value and BUFFER is current,
   we just examine or set REALVALUE.  If BUFFER is not current, we
   store the current REALVALUE value into CURRENT-ALIST-ELEMENT,
   then find the appropriate alist element for the buffer now
   current and set up CURRENT-ALIST-ELEMENT.  Then we set
   REALVALUE out of that element, and store into BUFFER.

   If we are setting the variable and the current buffer does not
   have an alist entry for this variable, an alist entry is
   created.

   Note that REALVALUE can be a forwarding pointer.  Each time it
   is examined or set, forwarding must be done.  Each time we
   switch buffers, buffer-local variables which forward into C
   variables are swapped immediately, so the C code can assume
   that they are always up to date.

   Lisp_Misc_Buffer_Local_Value and Lisp_Misc_Some_Buffer_Local_Value
   use the same substructure.  The difference is that with the latter,
   merely setting the variable while some buffer is current
   does not cause that buffer to have its own local value of this variable.
   Only make-local-variable does that.  */
struct Lisp_Buffer_Local_Value
  {
    int type : 16;      /* = Lisp_Misc_Buffer_Local_Value
			   or Lisp_Misc_Some_Buffer_Local_Value */
    int spacer : 13;
    unsigned int check_frame : 1;
    unsigned int found_for_buffer : 1;
    unsigned int found_for_frame : 1;
    Lisp_Object realvalue;
    Lisp_Object buffer, frame;
    Lisp_Object cdr;
  };

/* In an overlay object, the mark bit of the plist is used as the GC mark.
   START and END are markers in the overlay's buffer, and
   PLIST is the overlay's property list.  */
struct Lisp_Overlay
  {
    int type : 16;	/* = Lisp_Misc_Overlay */
    int spacer : 16;
    Lisp_Object start, end, plist;
  };

/* Like Lisp_Objfwd except that value lives in a slot in the
   current kboard.  */
struct Lisp_Kboard_Objfwd
  {
    int type : 16;	/* = Lisp_Misc_Kboard_Objfwd */
    int spacer : 16;
    int offset;
  };


/* To get the type field of a union Lisp_Misc, use XMISCTYPE.
   It uses one of these struct subtypes to get the type field.  */

union Lisp_Misc
  {
    struct Lisp_Free u_free;
    struct Lisp_Marker u_marker;
    struct Lisp_Intfwd u_intfwd;
    struct Lisp_Boolfwd u_boolfwd;
    struct Lisp_Objfwd u_objfwd;
    struct Lisp_Buffer_Objfwd u_buffer_objfwd;
    struct Lisp_Buffer_Local_Value u_buffer_local_value;
    struct Lisp_Overlay u_overlay;
    struct Lisp_Kboard_Objfwd u_kboard_objfwd;
  };

#ifdef LISP_FLOAT_TYPE
/* Optional Lisp floating point type */
struct Lisp_Float
  {
    Lisp_Object type;		/* essentially used for mark-bit
				   and chaining when on free-list */
    double data;
  };
#endif /* LISP_FLOAT_TYPE */

/* A character, declared with the following typedef, is a member
   of some character set associated with the current buffer.  */
#ifndef _UCHAR_T  /* Protect against something in ctab.h on AIX.  */
#define _UCHAR_T
typedef unsigned char UCHAR;
#endif

/* Meanings of slots in a Lisp_Compiled:  */

#define COMPILED_ARGLIST 0
#define COMPILED_BYTECODE 1
#define COMPILED_CONSTANTS 2
#define COMPILED_STACK_DEPTH 3
#define COMPILED_DOC_STRING 4
#define COMPILED_INTERACTIVE 5

/* Flag bits in a character.  These also get used in termhooks.h.
   Richard Stallman <rms@gnu.ai.mit.edu> thinks that MULE
   (MUlti-Lingual Emacs) might need 22 bits for the character value
   itself, so we probably shouldn't use any bits lower than 0x0400000.  */
#define CHAR_ALT   (0x0400000)
#define CHAR_SUPER (0x0800000)
#define CHAR_HYPER (0x1000000)
#define CHAR_SHIFT (0x2000000)
#define CHAR_CTL   (0x4000000)
#define CHAR_META  (0x8000000)

/* Actually, the current Emacs uses 19 bits for the character value
   itself.  */
#define CHARACTERBITS 19

#ifdef USE_X_TOOLKIT
#ifdef NO_UNION_TYPE
/* Use this for turning a (void *) into a Lisp_Object, as when the
   Lisp_Object is passed into a toolkit callback function.  */
#define VOID_TO_LISP(larg,varg) \
  do { ((larg) = ((Lisp_Object) (varg))); } while (0)
#define CVOID_TO_LISP VOID_TO_LISP

/* Use this for turning a Lisp_Object into a  (void *), as when the
   Lisp_Object is passed into a toolkit callback function.  */
#define LISP_TO_VOID(larg) ((void *) (larg))
#define LISP_TO_CVOID(varg) ((const void *) (larg))

#else /* not NO_UNION_TYPE */
/* Use this for turning a (void *) into a Lisp_Object, as when the
  Lisp_Object is passed into a toolkit callback function.  */
#define VOID_TO_LISP(larg,varg) \
  do { ((larg).v = (void *) (varg)); } while (0)
#define CVOID_TO_LISP(larg,varg) \
  do { ((larg).cv = (const void *) (varg)); } while (0)

/* Use this for turning a Lisp_Object into a  (void *), as when the
   Lisp_Object is passed into a toolkit callback function.  */
#define LISP_TO_VOID(larg) ((larg).v)
#define LISP_TO_CVOID(larg) ((larg).cv)
#endif /* not NO_UNION_TYPE */
#endif /* USE_X_TOOLKIT */


/* The glyph datatype, used to represent characters on the display.  */

/* The low 19 bits (CHARACTERBITS) are the character code, and the
   bits above them except for the topmost two bits are the numeric
   face ID.  If FID is the face ID of a glyph on a frame F, then
   F->display.x->faces[FID] contains the description of that face.
   This is an int instead of a short, so we can support a good bunch
   of face ID's (i.e. 2^(32 - 19 - 2) = 2048 ID's) ; given that we
   have no mechanism for tossing unused frame face ID's yet, we'll
   probably run out of 255 pretty quickly.  */
#define GLYPH unsigned int

/* Mask bit for a glyph of a character which should be written from
   right to left.  */
#define GLYPH_MASK_REV_DIR 0x80000000
/* Mask bit for a padding glyph of a multi-column character.  */
#define GLYPH_MASK_PADDING 0x40000000
/* Mask bits for face.  */
#define GLYPH_MASK_FACE    0x3FF80000
/* Mask bits for character code.  */
#define GLYPH_MASK_CHAR    0x0007FFFF /* The lowest 19 bits */

#ifdef HAVE_FACES
/* The FAST macros assume that we already know we're in an X window.  */

/* Given a character code and a face ID, return the appropriate glyph.  */
#define FAST_MAKE_GLYPH(char, face) ((char) | ((face) << CHARACTERBITS))

/* Return a glyph's character code.  */
#define FAST_GLYPH_CHAR(glyph) ((glyph) & GLYPH_MASK_CHAR)

/* Return a glyph's face ID.  */
#define FAST_GLYPH_FACE(glyph) (((glyph) & GLYPH_MASK_FACE) >> CHARACTERBITS)

/* Slower versions that test the frame type first.  */
#define MAKE_GLYPH(f, char, face) (FRAME_TERMCAP_P (f) ? (char) \
				   : FAST_MAKE_GLYPH (char, face))
#define GLYPH_CHAR(f, g) (FRAME_TERMCAP_P (f) ? (g) : FAST_GLYPH_CHAR (g))
#define GLYPH_FACE(f, g) (FRAME_TERMCAP_P (f) ? (0) : FAST_GLYPH_FACE (g))
#else /* not HAVE_FACES */
#define MAKE_GLYPH(f, char, face) (char)
#define FAST_MAKE_GLYPH(char, face) (char)
#define GLYPH_CHAR(f, g) ((g) & GLYPH_MASK_CHAR)
#define FAST_GLYPH_CHAR(g) ((g) & GLYPH_MASK_CHAR)
#define GLYPH_FACE(f, g) ((g) & GLYPH_MASK_FACE)
#define FAST_GLYPH_FACE(g) ((g) & GLYPH_MASK_FACE)
#endif /* not HAVE_FACES */

/* Return 1 iff GLYPH contains valid character code.  */
#define GLYPH_CHAR_VALID_P(glyph) \
  ((GLYPH) (FAST_GLYPH_CHAR (glyph)) <= MAX_CHAR)

/* The ID of the mode line highlighting face.  */
#define GLYPH_MODE_LINE_FACE 1

/* Data type checking */

#define NILP(x)  (XFASTINT (x) == XFASTINT (Qnil))
#define GC_NILP(x) GC_EQ (x, Qnil)

#ifdef LISP_FLOAT_TYPE
#define NUMBERP(x) (INTEGERP (x) || FLOATP (x))
#define GC_NUMBERP(x) (GC_INTEGERP (x) || GC_FLOATP (x))
#else
#define NUMBERP(x) (INTEGERP (x))
#define GC_NUMBERP(x) (GC_INTEGERP (x))
#endif
#define NATNUMP(x) (INTEGERP (x) && XINT (x) >= 0)
#define GC_NATNUMP(x) (GC_INTEGERP (x) && XINT (x) >= 0)

#define INTEGERP(x) (XTYPE ((x)) == Lisp_Int)
#define GC_INTEGERP(x) (XGCTYPE ((x)) == Lisp_Int)
#define SYMBOLP(x) (XTYPE ((x)) == Lisp_Symbol)
#define GC_SYMBOLP(x) (XGCTYPE ((x)) == Lisp_Symbol)
#define MISCP(x) (XTYPE ((x)) == Lisp_Misc)
#define GC_MISCP(x) (XGCTYPE ((x)) == Lisp_Misc)
#define VECTORLIKEP(x) (XTYPE ((x)) == Lisp_Vectorlike)
#define GC_VECTORLIKEP(x) (XGCTYPE ((x)) == Lisp_Vectorlike)
#define STRINGP(x) (XTYPE ((x)) == Lisp_String)
#define GC_STRINGP(x) (XGCTYPE ((x)) == Lisp_String)
#define CONSP(x) (XTYPE ((x)) == Lisp_Cons)
#define GC_CONSP(x) (XGCTYPE ((x)) == Lisp_Cons)

#ifdef LISP_FLOAT_TYPE
#define FLOATP(x) (XTYPE ((x)) == Lisp_Float)
#define GC_FLOATP(x) (XGCTYPE ((x)) == Lisp_Float)
#else
#define FLOATP(x) (0)
#define GC_FLOATP(x) (0)
#endif
#define VECTORP(x) (VECTORLIKEP (x) && !(XVECTOR (x)->size & PSEUDOVECTOR_FLAG))
#define GC_VECTORP(x) (GC_VECTORLIKEP (x) && !(XVECTOR (x)->size & PSEUDOVECTOR_FLAG))
#define OVERLAYP(x) (MISCP (x) && XMISCTYPE (x) == Lisp_Misc_Overlay)
#define GC_OVERLAYP(x) (GC_MISCP (x) && XMISCTYPE (x) == Lisp_Misc_Overlay)
#define MARKERP(x) (MISCP (x) && XMISCTYPE (x) == Lisp_Misc_Marker)
#define GC_MARKERP(x) (GC_MISCP (x) && XMISCTYPE (x) == Lisp_Misc_Marker)
#define INTFWDP(x) (MISCP (x) && XMISCTYPE (x) == Lisp_Misc_Intfwd)
#define GC_INTFWDP(x) (GC_MISCP (x) && XMISCTYPE (x) == Lisp_Misc_Intfwd)
#define BOOLFWDP(x) (MISCP (x) && XMISCTYPE (x) == Lisp_Misc_Boolfwd)
#define GC_BOOLFWDP(x) (GC_MISCP (x) && XMISCTYPE (x) == Lisp_Misc_Boolfwd)
#define OBJFWDP(x) (MISCP (x) && XMISCTYPE (x) == Lisp_Misc_Objfwd)
#define GC_OBJFWDP(x) (GC_MISCP (x) && XMISCTYPE (x) == Lisp_Misc_Objfwd)
#define BUFFER_OBJFWDP(x) (MISCP (x) && XMISCTYPE (x) == Lisp_Misc_Buffer_Objfwd)
#define GC_BUFFER_OBJFWDP(x) (GC_MISCP (x) && XMISCTYPE (x) == Lisp_Misc_Buffer_Objfwd)
#define BUFFER_LOCAL_VALUEP(x) (MISCP (x) && XMISCTYPE (x) == Lisp_Misc_Buffer_Local_Value)
#define GC_BUFFER_LOCAL_VALUEP(x) (GC_MISCP (x) && XMISCTYPE (x) == Lisp_Misc_Buffer_Local_Value)
#define SOME_BUFFER_LOCAL_VALUEP(x) (MISCP (x) && XMISCTYPE (x) == Lisp_Misc_Some_Buffer_Local_Value)
#define GC_SOME_BUFFER_LOCAL_VALUEP(x) (GC_MISCP (x) && XMISCTYPE (x) == Lisp_Misc_Some_Buffer_Local_Value)
#define KBOARD_OBJFWDP(x) (MISCP (x) && XMISCTYPE (x) == Lisp_Misc_Kboard_Objfwd)
#define GC_KBOARD_OBJFWDP(x) (GC_MISCP (x) && XMISCTYPE (x) == Lisp_Misc_Kboard_Objfwd)


/* True if object X is a pseudovector whose code is CODE.  */
#define PSEUDOVECTORP(x, code)					\
  (VECTORLIKEP (x)						\
   && (((XVECTOR (x)->size & (PSEUDOVECTOR_FLAG | (code))))	\
       == (PSEUDOVECTOR_FLAG | (code))))

/* True if object X is a pseudovector whose code is CODE.
   This one works during GC.  */
#define GC_PSEUDOVECTORP(x, code)				\
  (GC_VECTORLIKEP (x)						\
   && (((XVECTOR (x)->size & (PSEUDOVECTOR_FLAG | (code))))	\
       == (PSEUDOVECTOR_FLAG | (code))))

/* Test for specific pseudovector types.  */
#define WINDOW_CONFIGURATIONP(x) PSEUDOVECTORP (x, PVEC_WINDOW_CONFIGURATION)
#define GC_WINDOW_CONFIGURATIONP(x) GC_PSEUDOVECTORP (x, PVEC_WINDOW_CONFIGURATION)
#define PROCESSP(x) PSEUDOVECTORP (x, PVEC_PROCESS)
#define GC_PROCESSP(x) GC_PSEUDOVECTORP (x, PVEC_PROCESS)
#define WINDOWP(x) PSEUDOVECTORP (x, PVEC_WINDOW)
#define GC_WINDOWP(x) GC_PSEUDOVECTORP (x, PVEC_WINDOW)
#define SUBRP(x) PSEUDOVECTORP (x, PVEC_SUBR)
#define GC_SUBRP(x) GC_PSEUDOVECTORP (x, PVEC_SUBR)
#define COMPILEDP(x) PSEUDOVECTORP (x, PVEC_COMPILED)
#define GC_COMPILEDP(x) GC_PSEUDOVECTORP (x, PVEC_COMPILED)
#define BUFFERP(x) PSEUDOVECTORP (x, PVEC_BUFFER)
#define GC_BUFFERP(x) GC_PSEUDOVECTORP (x, PVEC_BUFFER)
#define CHAR_TABLE_P(x) PSEUDOVECTORP (x, PVEC_CHAR_TABLE)
#define GC_CHAR_TABLE_P(x) GC_PSEUDOVECTORP (x, PVEC_CHAR_TABLE)
#define BOOL_VECTOR_P(x) PSEUDOVECTORP (x, PVEC_BOOL_VECTOR)
#define GC_BOOL_VECTOR_P(x) GC_PSEUDOVECTORP (x, PVEC_BOOL_VECTOR)
#define FRAMEP(x) PSEUDOVECTORP (x, PVEC_FRAME)
#define GC_FRAMEP(x) GC_PSEUDOVECTORP (x, PVEC_FRAME)

#define SUB_CHAR_TABLE_P(x) (CHAR_TABLE_P (x) && NILP (XCHAR_TABLE (x)->top))

#define EQ(x, y) (XFASTINT (x) == XFASTINT (y))
#define GC_EQ(x, y) (XGCTYPE (x) == XGCTYPE (y) && XPNTR (x) == XPNTR (y))

#define CHECK_LIST(x, i) \
  do { if (!CONSP ((x)) && !NILP (x)) x = wrong_type_argument (Qlistp, (x)); } while (0)

#define CHECK_STRING(x, i) \
  do { if (!STRINGP ((x))) x = wrong_type_argument (Qstringp, (x)); } while (0)

#define CHECK_CONS(x, i) \
  do { if (!CONSP ((x))) x = wrong_type_argument (Qconsp, (x)); } while (0)

#define CHECK_SYMBOL(x, i) \
  do { if (!SYMBOLP ((x))) x = wrong_type_argument (Qsymbolp, (x)); } while (0)

#define CHECK_CHAR_TABLE(x, i) \
  do { if (!CHAR_TABLE_P ((x)))	\
	 x = wrong_type_argument (Qchar_table_p, (x)); } while (0)

#define CHECK_VECTOR(x, i) \
  do { if (!VECTORP ((x))) x = wrong_type_argument (Qvectorp, (x)); } while (0)

#define CHECK_VECTOR_OR_CHAR_TABLE(x, i)				\
  do { if (!VECTORP ((x)) && !CHAR_TABLE_P ((x)))			\
	 x = wrong_type_argument (Qvector_or_char_table_p, (x));	\
     } while (0)

#define CHECK_BUFFER(x, i) \
  do { if (!BUFFERP ((x))) x = wrong_type_argument (Qbufferp, (x)); } while (0)

#define CHECK_WINDOW(x, i) \
  do { if (!WINDOWP ((x))) x = wrong_type_argument (Qwindowp, (x)); } while (0)

/* This macro rejects windows on the interior of the window tree as
   "dead", which is what we want; this is an argument-checking macro, and
   the user should never get access to interior windows.

   A window of any sort, leaf or interior, is dead iff the buffer,
   vchild, and hchild members are all nil.  */

#define CHECK_LIVE_WINDOW(x, i)				\
  do {							\
    if (!WINDOWP ((x))					\
	|| NILP (XWINDOW ((x))->buffer))		\
      x = wrong_type_argument (Qwindow_live_p, (x));	\
  } while (0)

#define CHECK_PROCESS(x, i) \
  do { if (!PROCESSP ((x))) x = wrong_type_argument (Qprocessp, (x)); } while (0)

#define CHECK_NUMBER(x, i) \
  do { if (!INTEGERP ((x))) x = wrong_type_argument (Qintegerp, (x)); } while (0)

#define CHECK_NATNUM(x, i) \
  do { if (!NATNUMP (x)) x = wrong_type_argument (Qwholenump, (x)); } while (0)

#define CHECK_MARKER(x, i) \
  do { if (!MARKERP ((x))) x = wrong_type_argument (Qmarkerp, (x)); } while (0)

#define CHECK_NUMBER_COERCE_MARKER(x, i) \
  do { if (MARKERP ((x))) XSETFASTINT (x, marker_position (x)); \
    else if (!INTEGERP ((x))) x = wrong_type_argument (Qinteger_or_marker_p, (x)); } while (0)

#ifdef LISP_FLOAT_TYPE

#define XFLOATINT(n) extract_float((n))

#define CHECK_FLOAT(x, i)		\
  do { if (!FLOATP (x))			\
    x = wrong_type_argument (Qfloatp, (x)); } while (0)

#define CHECK_NUMBER_OR_FLOAT(x, i)	\
  do { if (!FLOATP (x) && !INTEGERP (x))	\
    x = wrong_type_argument (Qnumberp, (x)); } while (0)

#define CHECK_NUMBER_OR_FLOAT_COERCE_MARKER(x, i) \
  do { if (MARKERP (x)) XSETFASTINT (x, marker_position (x));	\
  else if (!INTEGERP (x) && !FLOATP (x))		\
    x = wrong_type_argument (Qnumber_or_marker_p, (x)); } while (0)

#else  /* Not LISP_FLOAT_TYPE */

#define CHECK_NUMBER_OR_FLOAT CHECK_NUMBER

#define CHECK_NUMBER_OR_FLOAT_COERCE_MARKER CHECK_NUMBER_COERCE_MARKER

#define XFLOATINT(n) XINT((n))
#endif /* LISP_FLOAT_TYPE */

#define CHECK_OVERLAY(x, i) \
  do { if (!OVERLAYP ((x))) x = wrong_type_argument (Qoverlayp, (x));} while (0)

/* Cast pointers to this type to compare them.  Some machines want int.  */
#ifndef PNTR_COMPARISON_TYPE
#define PNTR_COMPARISON_TYPE unsigned int
#endif

/* Define a built-in function for calling from Lisp.
 `lname' should be the name to give the function in Lisp,
    as a null-terminated C string.
 `fnname' should be the name of the function in C.
    By convention, it starts with F.
 `sname' should be the name for the C constant structure
    that records information on this function for internal use.
    By convention, it should be the same as `fnname' but with S instead of F.
    It's too bad that C macros can't compute this from `fnname'.
 `minargs' should be a number, the minimum number of arguments allowed.
 `maxargs' should be a number, the maximum number of arguments allowed,
    or else MANY or UNEVALLED.
    MANY means pass a vector of evaluated arguments,
	 in the form of an integer number-of-arguments
	 followed by the address of a vector of Lisp_Objects
	 which contains the argument values.
    UNEVALLED means pass the list of unevaluated arguments
 `prompt' says how to read arguments for an interactive call.
    See the doc string for `interactive'.
    A null string means call interactively with no arguments.
 `doc' is documentation for the user.  */

#if !defined (__STDC__) || defined (USE_NONANSI_DEFUN)
#define DEFUN(lname, fnname, sname, minargs, maxargs, prompt, doc)	\
  Lisp_Object fnname ();						\
  struct Lisp_Subr sname =						\
    { PVEC_SUBR | (sizeof (struct Lisp_Subr) / sizeof (EMACS_INT)),	\
      fnname, minargs, maxargs, lname, prompt, 0};			\
  Lisp_Object fnname

#else

/* This version of DEFUN declares a function prototype with the right
   arguments, so we can catch errors with maxargs at compile-time.  */
#define DEFUN(lname, fnname, sname, minargs, maxargs, prompt, doc)	\
  Lisp_Object fnname DEFUN_ARGS_ ## maxargs ;				\
  struct Lisp_Subr sname =						\
    { PVEC_SUBR | (sizeof (struct Lisp_Subr) / sizeof (EMACS_INT)),	\
      fnname, minargs, maxargs, lname, prompt, 0};			\
  Lisp_Object fnname

/* Note that the weird token-substitution semantics of ANSI C makes
   this work for MANY and UNEVALLED.  */
#define DEFUN_ARGS_MANY		(int, Lisp_Object *)
#define DEFUN_ARGS_UNEVALLED	(Lisp_Object)
#define DEFUN_ARGS_0	(void)
#define DEFUN_ARGS_1	(Lisp_Object)
#define DEFUN_ARGS_2	(Lisp_Object, Lisp_Object)
#define DEFUN_ARGS_3	(Lisp_Object, Lisp_Object, Lisp_Object)
#define DEFUN_ARGS_4	(Lisp_Object, Lisp_Object, Lisp_Object, Lisp_Object)
#define DEFUN_ARGS_5	(Lisp_Object, Lisp_Object, Lisp_Object, Lisp_Object, \
			 Lisp_Object)
#define DEFUN_ARGS_6	(Lisp_Object, Lisp_Object, Lisp_Object, Lisp_Object, \
			 Lisp_Object, Lisp_Object)
#define DEFUN_ARGS_7	(Lisp_Object, Lisp_Object, Lisp_Object, Lisp_Object, \
			 Lisp_Object, Lisp_Object, Lisp_Object)
#define DEFUN_ARGS_8	(Lisp_Object, Lisp_Object, Lisp_Object, Lisp_Object, \
			 Lisp_Object, Lisp_Object, Lisp_Object, Lisp_Object)
#endif

/* Declare the prototype for a general external function.  */
#if defined (__STDC__) || defined (WINDOWSNT)
#define P_(proto) proto
#else
#define P_(proto) ()
#endif

/* defsubr (Sname);
 is how we define the symbol for function `name' at start-up time.  */
extern void defsubr P_ ((struct Lisp_Subr *));

#define MANY -2
#define UNEVALLED -1

extern void defvar_lisp P_ ((char *, Lisp_Object *));
extern void defvar_lisp_nopro P_ ((char *, Lisp_Object *));
extern void defvar_bool P_ ((char *, int *));
extern void defvar_int P_ ((char *, int *));
extern void defvar_per_buffer P_ ((char *, Lisp_Object *, Lisp_Object, char *));
extern void defvar_kboard P_ ((char *, int));

/* Macros we use to define forwarded Lisp variables.
   These are used in the syms_of_FILENAME functions.  */

#define DEFVAR_LISP(lname, vname, doc) defvar_lisp (lname, vname)
#define DEFVAR_LISP_NOPRO(lname, vname, doc) defvar_lisp_nopro (lname, vname)
#define DEFVAR_BOOL(lname, vname, doc) defvar_bool (lname, vname)
#define DEFVAR_INT(lname, vname, doc) defvar_int (lname, vname)
#define DEFVAR_PER_BUFFER(lname, vname, type, doc)  \
 defvar_per_buffer (lname, vname, type, 0)
#define DEFVAR_KBOARD(lname, vname, doc) \
 defvar_kboard (lname, \
		(int)((char *)(&current_kboard->vname) \
		      - (char *)current_kboard))

/* Structure for recording Lisp call stack for backtrace purposes.  */

/* The special binding stack holds the outer values of variables while
   they are bound by a function application or a let form, stores the
   code to be executed for Lisp unwind-protect forms, and stores the C
   functions to be called for record_unwind_protect.

   If func is non-zero, undoing this binding applies func to old_value;
      This implements record_unwind_protect.
   If func is zero and symbol is nil, undoing this binding evaluates
      the list of forms in old_value; this implements Lisp's unwind-protect
      form.
   Otherwise, undoing this binding stores old_value as symbol's value; this
      undoes the bindings made by a let form or function call.  */
struct specbinding
  {
    Lisp_Object symbol, old_value;
    Lisp_Object (*func) P_ ((Lisp_Object));
    Lisp_Object unused;		/* Dividing by 16 is faster than by 12 */
  };

extern struct specbinding *specpdl;
extern struct specbinding *specpdl_ptr;
extern int specpdl_size;

/* Everything needed to describe an active condition case.  */
struct handler
  {
    /* The handler clauses and variable from the condition-case form.  */
    Lisp_Object handler;
    Lisp_Object var;
    /* Fsignal stores here the condition-case clause that applies,
       and Fcondition_case thus knows which clause to run.  */
    Lisp_Object chosen_clause;

    /* Used to effect the longjump out to the handler.  */
    struct catchtag *tag;

    /* The next enclosing handler.  */
    struct handler *next;
  };

extern struct handler *handlerlist;

extern struct catchtag *catchlist;
extern struct backtrace *backtrace_list;

extern Lisp_Object memory_signal_data;

/* An address near the bottom of the stack.
   Tells GC how to save a copy of the stack.  */
extern char *stack_bottom;

/* Check quit-flag and quit if it is non-nil.  */

#define QUIT \
  if (!NILP (Vquit_flag) && NILP (Vinhibit_quit)) \
    { Vquit_flag = Qnil; Fsignal (Qquit, Qnil); }

/* Nonzero if ought to quit now.  */

#define QUITP (!NILP (Vquit_flag) && NILP (Vinhibit_quit))

/* Variables used locally in the following case handling macros.  */
extern int case_temp1;
extern Lisp_Object case_temp2;

/* Current buffer's map from characters to lower-case characters.  */

#define DOWNCASE_TABLE current_buffer->downcase_table

/* Current buffer's map from characters to upper-case characters.  */

#define UPCASE_TABLE current_buffer->upcase_table

/* Downcase a character, or make no change if that cannot be done.  */

#define DOWNCASE(CH)						\
  ((case_temp1 = (CH),						\
    case_temp2 = CHAR_TABLE_REF (DOWNCASE_TABLE, case_temp1),	\
    NATNUMP (case_temp2))					\
   ? XFASTINT (case_temp2) : case_temp1)

/* 1 if CH is upper case.  */

#define UPPERCASEP(CH) (DOWNCASE (CH) != (CH))

/* 1 if CH is neither upper nor lower case.  */

#define NOCASEP(CH) (UPCASE1 (CH) == (CH))

/* 1 if CH is lower case.  */

#define LOWERCASEP(CH) (!UPPERCASEP (CH) && !NOCASEP(CH))

/* Upcase a character, or make no change if that cannot be done.  */

#define UPCASE(CH) (!UPPERCASEP (CH) ? UPCASE1 (CH) : (CH))

/* Upcase a character known to be not upper case.  */

#define UPCASE1(CH)						\
  ((case_temp1 = (CH),						\
    case_temp2 = CHAR_TABLE_REF (UPCASE_TABLE, case_temp1),	\
    NATNUMP (case_temp2))					\
   ? XFASTINT (case_temp2) : case_temp1)

extern Lisp_Object Vascii_downcase_table;

/* Number of bytes of structure consed since last GC.  */

extern int consing_since_gc;

/* Threshold for doing another gc.  */

extern int gc_cons_threshold;

/* Structure for recording stack slots that need marking.  */

/* This is a chain of structures, each of which points at a Lisp_Object variable
 whose value should be marked in garbage collection.
 Normally every link of the chain is an automatic variable of a function,
 and its `val' points to some argument or local variable of the function.
 On exit to the function, the chain is set back to the value it had on entry.
 This way, no link remains in the chain when the stack frame containing the
 link disappears.

 Every function that can call Feval must protect in this fashion all
 Lisp_Object variables whose contents will be used again.  */

extern struct gcpro *gcprolist;

struct gcpro
  {
    struct gcpro *next;
    Lisp_Object *var;		/* Address of first protected variable */
    int nvars;			/* Number of consecutive protected variables */
  };

#define GCPRO1(varname) \
 {gcpro1.next = gcprolist; gcpro1.var = &varname; gcpro1.nvars = 1; \
  gcprolist = &gcpro1; }

#define GCPRO2(varname1, varname2) \
 {gcpro1.next = gcprolist; gcpro1.var = &varname1; gcpro1.nvars = 1; \
  gcpro2.next = &gcpro1; gcpro2.var = &varname2; gcpro2.nvars = 1; \
  gcprolist = &gcpro2; }

#define GCPRO3(varname1, varname2, varname3) \
 {gcpro1.next = gcprolist; gcpro1.var = &varname1; gcpro1.nvars = 1; \
  gcpro2.next = &gcpro1; gcpro2.var = &varname2; gcpro2.nvars = 1; \
  gcpro3.next = &gcpro2; gcpro3.var = &varname3; gcpro3.nvars = 1; \
  gcprolist = &gcpro3; }

#define GCPRO4(varname1, varname2, varname3, varname4) \
 {gcpro1.next = gcprolist; gcpro1.var = &varname1; gcpro1.nvars = 1; \
  gcpro2.next = &gcpro1; gcpro2.var = &varname2; gcpro2.nvars = 1; \
  gcpro3.next = &gcpro2; gcpro3.var = &varname3; gcpro3.nvars = 1; \
  gcpro4.next = &gcpro3; gcpro4.var = &varname4; gcpro4.nvars = 1; \
  gcprolist = &gcpro4; }

#define GCPRO5(varname1, varname2, varname3, varname4, varname5) \
 {gcpro1.next = gcprolist; gcpro1.var = &varname1; gcpro1.nvars = 1; \
  gcpro2.next = &gcpro1; gcpro2.var = &varname2; gcpro2.nvars = 1; \
  gcpro3.next = &gcpro2; gcpro3.var = &varname3; gcpro3.nvars = 1; \
  gcpro4.next = &gcpro3; gcpro4.var = &varname4; gcpro4.nvars = 1; \
  gcpro5.next = &gcpro4; gcpro5.var = &varname5; gcpro5.nvars = 1; \
  gcprolist = &gcpro5; }

/* Call staticpro (&var) to protect static variable `var'.  */

void staticpro P_ ((Lisp_Object *));

#define UNGCPRO (gcprolist = gcpro1.next)

/* Evaluate expr, UNGCPRO, and then return the value of expr.  */
#define RETURN_UNGCPRO(expr)			\
if (1)						\
    {						\
      Lisp_Object ret_ungc_val;			\
      ret_ungc_val = (expr);			\
      UNGCPRO;					\
      return ret_ungc_val;			\
    }						\
else

/* Declare a Lisp-callable function.  The MAXARGS parameter has the same
   meaning as in the DEFUN macro, and is used to construct a prototype.  */
#if !defined (__STDC__) || defined (USE_NONANSI_DEFUN)
#define EXFUN(fnname, maxargs) \
  extern Lisp_Object fnname ()
#else
/* We can use the same trick as in the DEFUN macro to generate the
   appropriate prototype.  */
#define EXFUN(fnname, maxargs) \
  extern Lisp_Object fnname DEFUN_ARGS_ ## maxargs
#endif

/* Forward declarations for prototypes.  */
struct window;
struct frame;

/* Defined in data.c */
extern Lisp_Object Qnil, Qt, Qquote, Qlambda, Qsubr, Qunbound;
extern Lisp_Object Qerror_conditions, Qerror_message, Qtop_level;
extern Lisp_Object Qerror, Qquit, Qwrong_type_argument, Qargs_out_of_range;
extern Lisp_Object Qvoid_variable, Qvoid_function;
extern Lisp_Object Qsetting_constant, Qinvalid_read_syntax;
extern Lisp_Object Qinvalid_function, Qwrong_number_of_arguments, Qno_catch;
extern Lisp_Object Qend_of_file, Qarith_error;
extern Lisp_Object Qbeginning_of_buffer, Qend_of_buffer, Qbuffer_read_only;
extern Lisp_Object Qmark_inactive;

extern Lisp_Object Qrange_error, Qdomain_error, Qsingularity_error;
extern Lisp_Object Qoverflow_error, Qunderflow_error;

extern Lisp_Object Qintegerp, Qnumberp, Qnatnump, Qwholenump;
extern Lisp_Object Qsymbolp, Qlistp, Qconsp;
extern Lisp_Object Qstringp, Qarrayp, Qsequencep, Qbufferp;
extern Lisp_Object Qchar_or_string_p, Qmarkerp, Qvectorp;
extern Lisp_Object Qinteger_or_marker_p, Qnumber_or_marker_p;
extern Lisp_Object Qchar_table_p, Qvector_or_char_table_p;
extern Lisp_Object Qboundp, Qfboundp;
extern Lisp_Object Qbuffer_or_string_p;
extern Lisp_Object Qcdr;

#ifdef LISP_FLOAT_TYPE
extern Lisp_Object Qfloatp, Qinteger_or_floatp, Qinteger_or_float_or_marker_p;
#endif /* LISP_FLOAT_TYPE */

extern Lisp_Object Qframep;

EXFUN (Feq, 2);
EXFUN (Fnull, 1);
EXFUN (Flistp, 1);
EXFUN (Fconsp, 1);
EXFUN (Fatom, 1);
EXFUN (Fnlistp, 1);
EXFUN (Fintegerp, 1);
EXFUN (Fnatnump, 1);
EXFUN (Fsymbolp, 1);
EXFUN (Fvectorp, 1);
EXFUN (Fstringp, 1);
EXFUN (Fmultibyte_string_p, 1);
EXFUN (Farrayp, 1);
EXFUN (Fsequencep, 1);
EXFUN (Fbufferp, 1);
EXFUN (Fmarkerp, 1);
EXFUN (Fsubrp, 1);
EXFUN (Fchar_or_string_p, 1);
EXFUN (Finteger_or_marker_p, 1);
#ifdef LISP_FLOAT_TYPE
EXFUN (Ffloatp, 1);
EXFUN (Finteger_or_floatp, 1);
EXFUN (Finteger_or_float_or_marker_p, 1);
#endif /* LISP_FLOAT_TYPE */

EXFUN (Fcar, 1);
EXFUN (Fcar_safe, 1);
EXFUN (Fcdr, 1);
EXFUN (Fcdr_safe, 1);
EXFUN (Fsetcar, 2);
EXFUN (Fsetcdr, 2);
EXFUN (Fboundp, 1);
EXFUN (Ffboundp, 1);
EXFUN (Fmakunbound, 1);
EXFUN (Ffmakunbound, 1);
EXFUN (Fsymbol_function, 1);
EXFUN (Fsymbol_plist, 1);
EXFUN (Fsymbol_name, 1);
extern Lisp_Object indirect_function P_ ((Lisp_Object));
EXFUN (Findirect_function, 1);
EXFUN (Ffset, 2);
EXFUN (Fsetplist, 2);
EXFUN (Fsymbol_value, 1);
extern Lisp_Object find_symbol_value P_ ((Lisp_Object));
EXFUN (Fset, 2);
EXFUN (Fdefault_value, 1);
EXFUN (Fset_default, 2);
EXFUN (Fdefault_boundp, 1);
EXFUN (Fmake_local_variable, 1);
EXFUN (Flocal_variable_p, 2);
EXFUN (Flocal_variable_if_set_p, 2);

EXFUN (Faref, 2);
EXFUN (Faset, 3);

EXFUN (Fstring_to_number, 2);
EXFUN (Fnumber_to_string, 1);
EXFUN (Feqlsign, 2);
EXFUN (Fgtr, 2);
EXFUN (Flss, 2);
EXFUN (Fgeq, 2);
EXFUN (Fleq, 2);
EXFUN (Fneq, 2);
EXFUN (Fzerop, 1);
EXFUN (Fplus, MANY);
EXFUN (Fminus, MANY);
EXFUN (Ftimes, MANY);
EXFUN (Fquo, MANY);
EXFUN (Frem, 2);
EXFUN (Fmax, MANY);
EXFUN (Fmin, MANY);
EXFUN (Flogand, MANY);
EXFUN (Flogior, MANY);
EXFUN (Flogxor, MANY);
EXFUN (Flognot, 1);
EXFUN (Flsh, 2);
EXFUN (Fash, 2);

EXFUN (Fadd1, 1);
EXFUN (Fsub1, 1);

extern Lisp_Object long_to_cons P_ ((unsigned long));
extern unsigned long cons_to_long P_ ((Lisp_Object));
extern void args_out_of_range P_ ((Lisp_Object, Lisp_Object));
extern void args_out_of_range_3 P_ ((Lisp_Object, Lisp_Object, Lisp_Object));
extern Lisp_Object wrong_type_argument P_ ((Lisp_Object, Lisp_Object));
extern void store_symval_forwarding P_ ((Lisp_Object, Lisp_Object, Lisp_Object));
extern Lisp_Object do_symval_forwarding P_ ((Lisp_Object));
extern Lisp_Object set_internal P_ ((Lisp_Object, Lisp_Object, int));
extern void syms_of_data P_ ((void));
extern void init_data P_ ((void));

/* Defined in cmds.c */
EXFUN (Fend_of_line, 1);
EXFUN (Fforward_char, 1);
EXFUN (Fforward_line, 1);
extern int forward_point P_ ((int));
extern int internal_self_insert P_ ((int, int));
extern void syms_of_cmds P_ ((void));
extern void keys_of_cmds P_ ((void));

/* Defined in coding.c */
EXFUN (Fcoding_system_p, 1);
EXFUN (Fcheck_coding_system, 1);
EXFUN (Fread_coding_system, 2);
EXFUN (Fread_non_nil_coding_system, 1);
EXFUN (Ffind_operation_coding_system, MANY);
EXFUN (Fencode_coding_string, 3);
EXFUN (Fdecode_coding_string, 3);
extern Lisp_Object detect_coding_system P_ ((unsigned char *, int, int));
extern void init_coding P_ ((void));
extern void init_coding_once P_ ((void));
extern void syms_of_coding P_ ((void));

/* Defined in charset.c */
extern int nonascii_insert_offset;
extern Lisp_Object Vnonascii_translation_table;
EXFUN (Fchar_bytes, 1);
EXFUN (Fchar_width, 1);
extern int chars_in_text P_ ((unsigned char *, int));
extern int multibyte_chars_in_text P_ ((unsigned char *, int));
extern int unibyte_char_to_multibyte P_ ((int));
extern int multibyte_char_to_unibyte P_ ((int, Lisp_Object));
extern Lisp_Object Qcharset;
extern void init_charset_once P_ ((void));
extern void syms_of_charset P_ ((void));

/* Defined in syntax.c */
EXFUN (Fforward_word, 1);
EXFUN (Fskip_chars_forward, 2);
EXFUN (Fskip_chars_backward, 2);
EXFUN (Fsyntax_table_p, 1);
EXFUN (Fsyntax_table, 0);
EXFUN (Fset_syntax_table, 1);
extern void init_syntax_once P_ ((void));
extern void syms_of_syntax P_ ((void));

/* Defined in fns.c */
extern Lisp_Object Qstring_lessp;
extern Lisp_Object Vfeatures;
EXFUN (Fidentity, 1);
EXFUN (Frandom, 1);
EXFUN (Flength, 1);
EXFUN (Fsafe_length, 1);
EXFUN (Fappend, MANY);
EXFUN (Fconcat, MANY);
EXFUN (Fvconcat, MANY);
EXFUN (Fcopy_sequence, 1);
EXFUN (Fstring_make_multibyte, 1);
EXFUN (Fstring_make_unibyte, 1);
EXFUN (Fstring_as_multibyte, 1);
EXFUN (Fstring_as_unibyte, 1);
EXFUN (Fsubstring, 3);
extern Lisp_Object substring_both P_ ((Lisp_Object, int, int, int, int));
EXFUN (Fnth, 2);
EXFUN (Fnthcdr, 2);
EXFUN (Fmemq, 2);
EXFUN (Fassq, 2);
EXFUN (Fassoc, 2);
EXFUN (Felt, 2);
EXFUN (Fmember, 2);
EXFUN (Frassq, 2);
EXFUN (Fdelq, 2);
EXFUN (Fsort, 2);
EXFUN (Freverse, 1);
EXFUN (Fnreverse, 1);
EXFUN (Fget, 2);
EXFUN (Fput, 3);
EXFUN (Fequal, 2);
EXFUN (Ffillarray, 2);
EXFUN (Fnconc, MANY);
EXFUN (Fmapcar, 2);
EXFUN (Fmapconcat, 3);
EXFUN (Fy_or_n_p, 1);
extern Lisp_Object do_yes_or_no_p P_ ((Lisp_Object));
EXFUN (Ffeaturep, 1);
EXFUN (Frequire, 3);
EXFUN (Fprovide, 1);
extern Lisp_Object concat2 P_ ((Lisp_Object, Lisp_Object));
extern Lisp_Object concat3 P_ ((Lisp_Object, Lisp_Object, Lisp_Object));
extern Lisp_Object nconc2 P_ ((Lisp_Object, Lisp_Object));
extern Lisp_Object assq_no_quit P_ ((Lisp_Object, Lisp_Object));
extern void clear_string_char_byte_cache P_ (());
extern int string_char_to_byte P_ ((Lisp_Object, int));
extern int string_byte_to_char P_ ((Lisp_Object, int));
extern Lisp_Object string_make_multibyte P_ ((Lisp_Object));
extern Lisp_Object string_make_unibyte P_ ((Lisp_Object));
EXFUN (Fcopy_alist, 1);
EXFUN (Fplist_get, 2);
EXFUN (Fset_char_table_parent, 2);
EXFUN (Fchar_table_extra_slot, 2);
EXFUN (Fset_char_table_extra_slot, 3);
EXFUN (Frassoc, 2);
EXFUN (Fstring_equal, 2);
EXFUN (Fcompare_strings, 7);
EXFUN (Fstring_lessp, 2);
extern int char_table_translate P_ ((Lisp_Object, int));
extern void map_char_table P_ ((void (*) (Lisp_Object, Lisp_Object, Lisp_Object),
				Lisp_Object, Lisp_Object, Lisp_Object, int,
				Lisp_Object *));
extern void syms_of_fns P_ ((void));

/* Defined in floatfns.c */
#ifdef LISP_FLOAT_TYPE
extern double extract_float P_ ((Lisp_Object));
EXFUN (Ffloat, 1);
#endif /* LISP_FLOAT_TYPE */
EXFUN (Ftruncate, 2);
extern void init_floatfns P_ ((void));
extern void syms_of_floatfns P_ ((void));

/* Defined in insdel.c */
extern void move_gap P_ ((int));
extern void move_gap_both P_ ((int, int));
extern void make_gap P_ ((int));
extern int copy_text P_ ((unsigned char *, unsigned char *, int, int, int));
extern int count_size_as_multibyte P_ ((unsigned char *, int));
extern int count_combining_before P_ ((unsigned char *, int, int, int));
extern int count_combining_after P_ ((unsigned char *, int, int, int));
extern void insert P_ ((unsigned char *, int));
extern void insert_and_inherit P_ ((unsigned char *, int));
extern void insert_1 P_ ((unsigned char *, int, int, int, int));
extern void insert_1_both P_ ((unsigned char *, int, int, int, int, int));
extern void insert_from_string P_ ((Lisp_Object, int, int, int, int, int));
extern void insert_from_buffer P_ ((struct buffer *, int, int, int));
extern void insert_char P_ ((int));
extern void insert_string P_ ((char *));
extern void insert_before_markers P_ ((unsigned char *, int));
extern void insert_before_markers_and_inherit P_ ((unsigned char *, int));
extern void insert_from_string_before_markers P_ ((Lisp_Object, int, int, int, int, int));
extern void del_range P_ ((int, int));
extern void del_range_1 P_ ((int, int, int));
extern void del_range_byte P_ ((int, int, int));
extern void del_range_both P_ ((int, int, int, int, int));
extern void del_range_2 P_ ((int, int, int, int));
extern void modify_region P_ ((struct buffer *, int, int));
extern void prepare_to_modify_buffer P_ ((int, int, int *));
extern void signal_before_change P_ ((int, int, int *));
extern void signal_after_change P_ ((int, int, int));
extern void adjust_after_replace P_ ((int, int, Lisp_Object, int, int));
extern void adjust_after_insert P_ ((int, int, int, int, int));
extern void replace_range P_ ((int, int, Lisp_Object, int, int, int));
extern void syms_of_insdel P_ ((void));

/* Defined in dispnew.c */
EXFUN (Fding, 1);
EXFUN (Fredraw_display, 0);
EXFUN (Fsleep_for, 2);
EXFUN (Fsit_for, 3);
extern Lisp_Object sit_for P_ ((int, int, int, int, int));
extern void quit_error_check P_ ((void));
extern void init_display P_ ((void));
extern void syms_of_display P_ ((void));

/* Defined in xdisp.c */
extern Lisp_Object Qinhibit_redisplay;
extern Lisp_Object Vmessage_log_max;
extern int message_enable_multibyte;
extern void message P_ ((/* char *, ... */));
extern void message_nolog P_ ((/* char *, ... */));
extern void message1 P_ ((char *));
extern void message1_nolog P_ ((char *));
extern void message2 P_ ((char *, int, int));
extern void message2_nolog P_ ((char *, int, int));
extern void message_dolog P_ ((char *, int, int, int));
extern void message_with_string P_ ((char *, Lisp_Object, int));
extern void message_log_maybe_newline P_ ((void));
extern void update_echo_area P_ ((void));
extern void truncate_echo_area P_ ((int));
extern void redisplay P_ ((void));
extern void redisplay_preserve_echo_area P_ ((void));
extern void mark_window_display_accurate P_ ((Lisp_Object, int));
extern int invisible_p P_ ((Lisp_Object, Lisp_Object));
extern void prepare_menu_bars P_ ((void));
extern void syms_of_xdisp P_ ((void));
extern void init_xdisp P_ ((void));

/* Defined in alloc.c */
extern void malloc_warning P_ ((char *));
extern void memory_full P_ ((void));
extern void buffer_memory_full P_ ((void));
extern Lisp_Object Vpurify_flag;
EXFUN (Fcons, 2);
EXFUN (list2, 2);
EXFUN (list3, 3);
EXFUN (list4, 4);
EXFUN (list5, 5);
EXFUN (Flist, MANY);
EXFUN (Fmake_list, 2);
extern Lisp_Object allocate_misc P_ ((void));
EXFUN (Fmake_vector, 2);
EXFUN (Fvector, MANY);
EXFUN (Fmake_symbol, 1);
EXFUN (Fmake_marker, 0);
EXFUN (Fmake_string, 2);
extern Lisp_Object build_string P_ ((char *));
extern Lisp_Object make_string P_ ((char *, int));
extern Lisp_Object make_unibyte_string P_ ((char *, int));
extern Lisp_Object make_multibyte_string P_ ((char *, int, int));
extern Lisp_Object make_event_array P_ ((int, Lisp_Object *));
extern Lisp_Object make_uninit_string P_ ((int));
extern Lisp_Object make_uninit_multibyte_string P_ ((int, int));
extern Lisp_Object make_string_from_bytes P_ ((char *, int, int));
extern Lisp_Object make_specified_string P_ ((char *, int, int, int));
EXFUN (Fpurecopy, 1);
extern Lisp_Object make_pure_string P_ ((char *, int, int, int));
extern Lisp_Object pure_cons P_ ((Lisp_Object, Lisp_Object));
extern Lisp_Object make_pure_vector P_ ((EMACS_INT));
EXFUN (Fgarbage_collect, 0);
EXFUN (Fmake_byte_code, MANY);
EXFUN (Fmake_bool_vector, 2);
EXFUN (Fmake_char_table, 2);
extern Lisp_Object make_sub_char_table P_ ((Lisp_Object));
extern Lisp_Object Qchar_table_extra_slots;
extern struct Lisp_Vector *allocate_vectorlike P_ ((EMACS_INT));
extern int gc_in_progress;
#ifdef LISP_FLOAT_TYPE
extern Lisp_Object make_float P_ ((double));
#endif /* LISP_FLOAT_TYPE */
extern void display_malloc_warning P_ ((void));
extern int inhibit_garbage_collection P_ ((void));
extern void free_marker P_ ((Lisp_Object));
extern void free_cons P_ ((struct Lisp_Cons *));
extern void init_alloc_once P_ ((void));
extern void init_alloc P_ ((void));
extern void syms_of_alloc P_ ((void));

/* Defined in print.c */
extern Lisp_Object Vprin1_to_string_buffer;
EXFUN (Fprin1, 2);
EXFUN (Fprin1_to_string, 2);
EXFUN (Fprinc, 2);
EXFUN (Fterpri, 1);
EXFUN (Fprint, 2);
EXFUN (Ferror_message_string, 1);
extern Lisp_Object Vstandard_output, Qstandard_output;
extern Lisp_Object Qexternal_debugging_output;
extern void temp_output_buffer_setup P_ ((char *));
extern int print_level, print_escape_newlines;
extern Lisp_Object Qprint_escape_newlines;
extern void write_string P_ ((char *, int));
extern void write_string_1 P_ ((char *, int, Lisp_Object));
extern void print_error_message P_ ((Lisp_Object, Lisp_Object));
extern Lisp_Object internal_with_output_to_temp_buffer
	P_ ((char *, Lisp_Object (*) (Lisp_Object), Lisp_Object));
extern void float_to_string P_ ((unsigned char *, double));
extern void syms_of_print P_ ((void));

/* Defined in doprnt.c */
extern int doprnt P_ ((char *, int, char *, char *, int, char **));
extern int doprnt_lisp P_ ((char *, int, char *, char *, int, char **));

/* Defined in lread.c */
extern Lisp_Object Qvariable_documentation, Qstandard_input;
extern Lisp_Object Vobarray, initial_obarray, Vstandard_input;
EXFUN (Fread, 1);
EXFUN (Fread_from_string, 3);
EXFUN (Fintern, 2);
EXFUN (Fintern_soft, 2);
EXFUN (Fload, 5);
EXFUN (Fget_file_char, 0);
EXFUN (Fread_char, 2);
EXFUN (Fread_event, 2);
extern Lisp_Object read_filtered_event P_ ((int, int, int, int));
EXFUN (Feval_region, 4);
extern Lisp_Object intern P_ ((char *));
extern Lisp_Object make_symbol P_ ((char *));
extern Lisp_Object oblookup P_ ((Lisp_Object, char *, int, int));
#define LOADHIST_ATTACH(x) \
 if (initialized) Vcurrent_load_list = Fcons (x, Vcurrent_load_list)
extern Lisp_Object Vcurrent_load_list;
extern Lisp_Object Vload_history;
extern int openp P_ ((Lisp_Object, Lisp_Object, char *, Lisp_Object *, int));
extern int isfloat_string P_ ((char *));
extern void map_obarray P_ ((Lisp_Object, void (*) (Lisp_Object, Lisp_Object),
			     Lisp_Object));
extern void dir_warning P_ ((char *, Lisp_Object));
extern void close_load_descs P_ ((void));
extern void init_obarray P_ ((void));
extern void init_lread P_ ((void));
extern void syms_of_lread P_ ((void));

/* Defined in eval.c */
extern Lisp_Object Qautoload, Qexit, Qinteractive, Qcommandp, Qdefun, Qmacro;
extern Lisp_Object Vinhibit_quit, Qinhibit_quit, Vquit_flag;
extern Lisp_Object Vmocklisp_arguments, Qmocklisp, Qmocklisp_arguments;
extern Lisp_Object Vautoload_queue;
extern Lisp_Object Vdebug_on_error;
/* To run a normal hook, use the appropriate function from the list below.
   The calling convention:

   if (!NILP (Vrun_hooks))
     call1 (Vrun_hooks, Qmy_funny_hook);

   should no longer be used.  */
extern Lisp_Object Vrun_hooks;
EXFUN (Frun_hooks, MANY);
EXFUN (Frun_hook_with_args, MANY);
EXFUN (Frun_hook_with_args_until_success, MANY);
EXFUN (Frun_hook_with_args_until_failure, MANY);
extern Lisp_Object run_hook_list_with_args P_ ((Lisp_Object, int, Lisp_Object *));
extern void run_hook_with_args_2 P_ ((Lisp_Object, Lisp_Object, Lisp_Object));
EXFUN (Fand, UNEVALLED);
EXFUN (For, UNEVALLED);
EXFUN (Fif, UNEVALLED);
EXFUN (Fprogn, UNEVALLED);
EXFUN (Fprog1, UNEVALLED);
EXFUN (Fprog2, UNEVALLED);
EXFUN (Fsetq, UNEVALLED);
EXFUN (Fquote, UNEVALLED);
EXFUN (Fuser_variable_p, 1);
EXFUN (Finteractive_p, 0);
EXFUN (Fdefun, UNEVALLED);
EXFUN (Flet, UNEVALLED);
EXFUN (FletX, UNEVALLED);
EXFUN (Fwhile, UNEVALLED);
EXFUN (Fcatch, UNEVALLED);
EXFUN (Fthrow, 2);
EXFUN (Funwind_protect, UNEVALLED);
EXFUN (Fcondition_case, UNEVALLED);
EXFUN (Fsignal, 2);
EXFUN (Fautoload, 5);
EXFUN (Fcommandp, 1);
EXFUN (Feval, 1);
EXFUN (Fapply, MANY);
EXFUN (Ffuncall, MANY);
EXFUN (Fbacktrace, 0);
extern Lisp_Object apply1 P_ ((Lisp_Object, Lisp_Object));
extern Lisp_Object call0 P_ ((Lisp_Object));
extern Lisp_Object call1 P_ ((Lisp_Object, Lisp_Object));
extern Lisp_Object call2 P_ ((Lisp_Object, Lisp_Object, Lisp_Object));
extern Lisp_Object call3 P_ ((Lisp_Object, Lisp_Object, Lisp_Object, Lisp_Object));
extern Lisp_Object call4 P_ ((Lisp_Object, Lisp_Object, Lisp_Object, Lisp_Object, Lisp_Object));
extern Lisp_Object call5 P_ ((Lisp_Object, Lisp_Object, Lisp_Object, Lisp_Object, Lisp_Object, Lisp_Object));
extern Lisp_Object call6 P_ ((Lisp_Object, Lisp_Object, Lisp_Object, Lisp_Object, Lisp_Object, Lisp_Object, Lisp_Object));
EXFUN (Fdo_auto_save, 2);
extern Lisp_Object apply_lambda P_ ((Lisp_Object, Lisp_Object, int));
extern Lisp_Object internal_catch P_ ((Lisp_Object, Lisp_Object (*) (Lisp_Object), Lisp_Object));
extern Lisp_Object internal_condition_case P_ ((Lisp_Object (*) (void), Lisp_Object, Lisp_Object (*) (Lisp_Object)));
extern Lisp_Object internal_condition_case_1 P_ ((Lisp_Object (*) (Lisp_Object), Lisp_Object, Lisp_Object, Lisp_Object (*) (Lisp_Object)));
extern void specbind P_ ((Lisp_Object, Lisp_Object));
extern void record_unwind_protect P_ ((Lisp_Object (*) (Lisp_Object), Lisp_Object));
extern Lisp_Object unbind_to P_ ((int, Lisp_Object));
extern void error P_ ((/* char *, ... */));
extern void do_autoload P_ ((Lisp_Object, Lisp_Object));
extern Lisp_Object un_autoload P_ ((Lisp_Object));
EXFUN (Ffetch_bytecode, 1);
extern void init_eval_once P_ ((void));
extern void init_eval P_ ((void));
extern void syms_of_eval P_ ((void));

/* Defined in editfns.c */
EXFUN (Fgoto_char, 1);
EXFUN (Fpoint_min_marker, 0);
EXFUN (Fpoint_max_marker, 0);
EXFUN (Fpoint_min, 0);
EXFUN (Fpoint_max, 0);
EXFUN (Fpoint, 0);
EXFUN (Fpoint_marker, 0);
EXFUN (Fmark_marker, 0);
EXFUN (Fline_beginning_position, 1);
EXFUN (Fline_end_position, 1);
EXFUN (Ffollowing_char, 0);
EXFUN (Fprevious_char, 0);
EXFUN (Fchar_after, 1);
EXFUN (Finsert, MANY);
EXFUN (Finsert_and_inherit, MANY);
EXFUN (Finsert_before_markers, MANY);
EXFUN (Finsert_buffer_substring, 3);
EXFUN (Finsert_char, 3);
extern void insert1 P_ ((Lisp_Object));
EXFUN (Feolp, 0);
EXFUN (Feobp, 0);
EXFUN (Fbolp, 0);
EXFUN (Fbobp, 0);
EXFUN (Fformat, MANY);
extern Lisp_Object format1 P_ ((/* char *, ... */));
extern Lisp_Object make_buffer_string P_ ((int, int, int));
EXFUN (Fbuffer_substring, 2);
EXFUN (Fbuffer_string, 0);
extern Lisp_Object save_excursion_save P_ ((void));
extern Lisp_Object save_restriction_save P_ ((void));
extern Lisp_Object save_excursion_restore P_ ((Lisp_Object));
extern Lisp_Object save_restriction_restore P_ ((Lisp_Object));
EXFUN (Fchar_to_string, 1);
EXFUN (Fdelete_region, 2);
EXFUN (Fnarrow_to_region, 2);
EXFUN (Fwiden, 0);
EXFUN (Fuser_login_name, 1);
EXFUN (Fsystem_name, 0);
extern int clip_to_bounds P_ ((int, int, int));
extern Lisp_Object make_buffer_string P_ ((int, int, int));
extern Lisp_Object make_buffer_string_both P_ ((int, int, int, int, int));
extern void init_editfns P_ ((void));
extern void syms_of_editfns P_ ((void));

/* defined in buffer.c */
extern void nsberror P_ ((Lisp_Object));
EXFUN (Foverlay_start, 1);
EXFUN (Foverlay_end, 1);
extern void adjust_overlays_for_insert P_ ((int, int));
extern void adjust_overlays_for_delete P_ ((int, int));
extern void fix_overlays_in_range P_ ((int, int));
extern void report_overlay_modification P_ ((Lisp_Object, Lisp_Object, int,
					     Lisp_Object, Lisp_Object, Lisp_Object));
extern int overlay_touches_p P_ ((int));
extern Lisp_Object Vbuffer_alist, Vinhibit_read_only;
EXFUN (Fget_buffer, 1);
EXFUN (Fget_buffer_create, 1);
EXFUN (Fset_buffer, 1);
EXFUN (set_buffer_if_live, 1);
EXFUN (Fbarf_if_buffer_read_only, 0);
EXFUN (Fcurrent_buffer, 0);
EXFUN (Fswitch_to_buffer, 2);
EXFUN (Fpop_to_buffer, 3);
EXFUN (Fother_buffer, 3);
EXFUN (Foverlay_get, 2);
EXFUN (Fbuffer_modified_p, 1);
EXFUN (Fset_buffer_modified_p, 1);
EXFUN (Fkill_buffer, 1);
EXFUN (Fkill_all_local_variables, 0);
EXFUN (Fbuffer_disable_undo, 1);
EXFUN (Fbuffer_enable_undo, 1);
EXFUN (Ferase_buffer, 0);
extern Lisp_Object Qoverlayp;
extern Lisp_Object get_truename_buffer P_ ((Lisp_Object));
extern struct buffer *all_buffers;
EXFUN (Fprevious_overlay_change, 1);
extern void init_buffer_once P_ ((void));
extern void init_buffer P_ ((void));
extern void syms_of_buffer P_ ((void));
extern void keys_of_buffer P_ ((void));

/* defined in marker.c */

EXFUN (Fmarker_position, 1);
EXFUN (Fmarker_buffer, 1);
EXFUN (Fcopy_marker, 2);
EXFUN (Fset_marker, 3);
extern int marker_position P_ ((Lisp_Object));
extern int marker_byte_position P_ ((Lisp_Object));
extern void clear_charpos_cache P_ ((struct buffer *));
extern int charpos_to_bytepos P_ ((int));
extern int buf_charpos_to_bytepos P_ ((struct buffer *, int));
extern int buf_bytepos_to_charpos P_ ((struct buffer *, int));
extern void unchain_marker P_ ((Lisp_Object));
extern Lisp_Object set_marker_restricted P_ ((Lisp_Object, Lisp_Object, Lisp_Object));
extern Lisp_Object set_marker_both P_ ((Lisp_Object, Lisp_Object, int, int));
extern Lisp_Object set_marker_restricted_both P_ ((Lisp_Object, Lisp_Object,
						   int, int));
extern void syms_of_marker P_ ((void));

/* Defined in fileio.c */

extern Lisp_Object Qfile_error;
EXFUN (Ffind_file_name_handler, 2);
EXFUN (Ffile_name_as_directory, 1);
EXFUN (Fexpand_file_name, 2);
EXFUN (Ffile_name_nondirectory, 1);
EXFUN (Fsubstitute_in_file_name, 1);
EXFUN (Ffile_symlink_p, 1);
EXFUN (Fverify_visited_file_modtime, 1);
EXFUN (Ffile_exists_p, 1);
EXFUN (Ffile_name_absolute_p, 1);
EXFUN (Fdirectory_file_name, 1);
EXFUN (Ffile_name_directory, 1);
extern Lisp_Object expand_and_dir_to_file P_ ((Lisp_Object, Lisp_Object));
EXFUN (Ffile_accessible_directory_p, 1);
EXFUN (Funhandled_file_name_directory, 1);
EXFUN (Ffile_directory_p, 1);
EXFUN (Fwrite_region, 7);
EXFUN (Ffile_readable_p, 1);
EXFUN (Ffile_executable_p, 1);
EXFUN (Fread_file_name, 5);
extern void report_file_error P_ ((char *, Lisp_Object));
extern int internal_delete_file P_ ((Lisp_Object));
extern void syms_of_fileio P_ ((void));

/* Defined in abbrev.c */

extern Lisp_Object Vfundamental_mode_abbrev_table;
extern void syms_of_abbrev P_ ((void));

/* defined in search.c */
EXFUN (Fstring_match, 3);
extern void restore_match_data P_ ((void));
EXFUN (Fmatch_data, 2);
EXFUN (Fset_match_data, 1);
EXFUN (Fmatch_beginning, 1);
EXFUN (Fmatch_end, 1);
extern int fast_string_match P_ ((Lisp_Object, Lisp_Object));
extern int fast_c_string_match_ignore_case P_ ((Lisp_Object, char *));
extern int scan_buffer P_ ((int, int, int, int, int *, int));
extern int scan_newline P_ ((int, int, int, int, int, int));
extern int find_next_newline P_ ((int, int));
extern int find_next_newline_no_quit P_ ((int, int));
extern int find_before_next_newline P_ ((int, int, int));
extern void syms_of_search P_ ((void));

/* defined in minibuf.c */

extern Lisp_Object last_minibuf_string;
extern void choose_minibuf_frame P_ ((void));
extern int scmp P_ ((unsigned char *, unsigned char *, int));
EXFUN (Fcompleting_read, 8);
EXFUN (Fread_from_minibuffer, 7);
EXFUN (Fread_variable, 2);
EXFUN (Fread_buffer, 3);
EXFUN (Fread_minibuffer, 2);
EXFUN (Feval_minibuffer, 2);
EXFUN (Fread_string, 5);
EXFUN (Fread_no_blanks_input, 3);
extern Lisp_Object get_minibuffer P_ ((int));
extern void temp_echo_area_glyphs P_ ((char *));
extern void init_minibuf_once P_ ((void));
extern void syms_of_minibuf P_ ((void));
extern void keys_of_minibuf P_ ((void));

/* Defined in callint.c */

extern Lisp_Object Qminus, Qplus, Vcurrent_prefix_arg;
extern Lisp_Object Vcommand_history;
extern Lisp_Object Qcall_interactively, Qmouse_leave_buffer_hook;
EXFUN (Fcall_interactively, 3);
EXFUN (Fprefix_numeric_value, 1);
extern void syms_of_callint P_ ((void));

/* defined in casefiddle.c */

EXFUN (Fdowncase, 1);
EXFUN (Fupcase, 1);
EXFUN (Fcapitalize, 1);
EXFUN (Fupcase_region, 2);
EXFUN (Fupcase_initials, 1);
EXFUN (Fupcase_initials_region, 2);
extern void syms_of_casefiddle P_ ((void));
extern void keys_of_casefiddle P_ ((void));

/* defined in casetab.c */

EXFUN (Fset_case_table, 1);
EXFUN (Fset_standard_case_table, 1);
extern void init_casetab_once P_ ((void));
extern void syms_of_casetab P_ ((void));

/* defined in keyboard.c */

extern Lisp_Object Qdisabled;
extern Lisp_Object Vtty_erase_char, Vhelp_form, Vtop_level;
EXFUN (Fdiscard_input, 0);
EXFUN (Frecursive_edit, 0);
EXFUN (Fcommand_execute, 4);
EXFUN (Finput_pending_p, 0);
extern Lisp_Object menu_bar_items P_ ((Lisp_Object));
extern Lisp_Object Qvertical_scroll_bar;
extern void discard_mouse_events ();
EXFUN (Fevent_convert_list, 1);
EXFUN (Fread_key_sequence, 5);
EXFUN (Fset_input_mode, 4);
extern int detect_input_pending P_ ((void));
extern int detect_input_pending_run_timers P_ ((int));
extern void safe_run_hooks P_ ((Lisp_Object));
extern void cmd_error_internal P_ ((Lisp_Object, char *));
extern Lisp_Object command_loop_1 P_ ((void));
extern Lisp_Object recursive_edit_1 P_ ((void));
extern void record_auto_save P_ ((void));
extern void init_keyboard P_ ((void));
extern void syms_of_keyboard P_ ((void));
extern void keys_of_keyboard P_ ((void));

/* defined in keymap.c */

extern Lisp_Object Qkeymap, Qmenu_bar;
extern Lisp_Object current_global_map;
EXFUN (Fmake_sparse_keymap, 1);
EXFUN (Fcopy_keymap, 1);
EXFUN (Fdefine_key, 3);
EXFUN (Flookup_key, 3);
EXFUN (Fkey_binding, 2);
EXFUN (Fkey_description, 1);
EXFUN (Fsingle_key_description, 1);
EXFUN (Fwhere_is_internal, 4);
extern Lisp_Object access_keymap P_ ((Lisp_Object, Lisp_Object, int, int));
extern Lisp_Object store_in_keymap P_ ((Lisp_Object, Lisp_Object, Lisp_Object));
extern Lisp_Object get_keyelt P_ ((Lisp_Object, int));
extern Lisp_Object get_keymap P_ ((Lisp_Object));
extern Lisp_Object get_keymap_1 P_ ((Lisp_Object, int, int));
extern void describe_vector P_ ((Lisp_Object, Lisp_Object,
				 void (*) (Lisp_Object), int,
				 Lisp_Object, Lisp_Object, int *, int));
extern void describe_map_tree P_ ((Lisp_Object, int, Lisp_Object, Lisp_Object,
				   char *, int, int, int));
extern int current_minor_maps P_ ((Lisp_Object **, Lisp_Object **));
extern void initial_define_key P_ ((Lisp_Object, int, char *));
extern void initial_define_lispy_key P_ ((Lisp_Object, char *, char *));
extern void fix_submap_inheritance P_ ((Lisp_Object, Lisp_Object, Lisp_Object));
extern void syms_of_keymap P_ ((void));
extern void keys_of_keymap P_ ((void));

/* defined in indent.c */
EXFUN (Fvertical_motion, 2);
EXFUN (Findent_to, 2);
EXFUN (Fcurrent_column, 0);
EXFUN (Fmove_to_column, 2);
extern int current_column P_ ((void));
extern void invalidate_current_column P_ ((void));
extern int indented_beyond_p P_ ((int, int, int));
extern void syms_of_indent P_ ((void));

/* defined in window.c */
extern Lisp_Object Qwindowp, Qwindow_live_p;
EXFUN (Fselected_window, 0);
EXFUN (Fnext_window, 3);
EXFUN (Fdelete_window, 1);
EXFUN (Fselect_window, 1);
EXFUN (Fset_window_buffer, 2);
EXFUN (Fget_buffer_window, 2);
EXFUN (Fsave_window_excursion, UNEVALLED);
EXFUN (Fsplit_window, 3);
EXFUN (Fset_window_configuration, 1);
EXFUN (Fcurrent_window_configuration, 1);
extern int compare_window_configurations P_ ((Lisp_Object, Lisp_Object, int));
EXFUN (Fcoordinates_in_window_p, 2);
EXFUN (Fwindow_at, 3);
EXFUN (Fpos_visible_in_window_p, 2);
extern int window_internal_height P_ ((struct window *));
extern int window_internal_width P_ ((struct window *));
EXFUN (Frecenter, 1);
EXFUN (Fscroll_other_window, 1);
EXFUN (Fset_window_start, 3);
extern void temp_output_buffer_show P_ ((Lisp_Object));
extern void replace_buffer_in_all_windows P_ ((Lisp_Object));
extern void init_window_once P_ ((void));
extern void syms_of_window P_ ((void));
extern void keys_of_window P_ ((void));

/* defined in frame.c */
extern Lisp_Object Qvisible;
extern void store_frame_param P_ ((struct frame *, Lisp_Object, Lisp_Object));
extern void store_in_alist P_ ((Lisp_Object *, Lisp_Object, Lisp_Object));
extern Lisp_Object do_switch_frame P_ ((Lisp_Object, Lisp_Object, int));
extern Lisp_Object get_frame_param P_ ((struct frame *, Lisp_Object));
extern Lisp_Object frame_buffer_predicate P_ ((Lisp_Object));
EXFUN (Fframep, 1);
EXFUN (Fselect_frame, 2);
EXFUN (Fselected_frame, 0);
EXFUN (Fwindow_frame, 1);
EXFUN (Fframe_root_window, 1);
EXFUN (Fframe_first_window, 1);
EXFUN (Fframe_selected_window, 1);
EXFUN (Fframe_list, 0);
EXFUN (Fnext_frame, 2);
EXFUN (Fdelete_frame, 2);
EXFUN (Fset_mouse_position, 3);
EXFUN (Fmake_frame_visible, 1);
EXFUN (Fmake_frame_invisible, 2);
EXFUN (Ficonify_frame, 1);
EXFUN (Fframe_visible_p, 1);
EXFUN (Fvisible_frame_list, 0);
EXFUN (Fframe_parameters, 1);
EXFUN (Fmodify_frame_parameters, 2);
EXFUN (Fset_frame_height, 3);
EXFUN (Fset_frame_width, 3);
EXFUN (Fset_frame_size, 3);
EXFUN (Fset_frame_position, 3);
EXFUN (Fraise_frame, 1);
EXFUN (Fredirect_frame_focus, 2);
EXFUN (Fset_frame_selected_window, 2);
extern Lisp_Object frame_buffer_list P_ ((Lisp_Object));
extern void frames_discard_buffer P_ ((Lisp_Object));
extern void set_frame_buffer_list P_ ((Lisp_Object, Lisp_Object));
extern void frames_bury_buffer P_ ((Lisp_Object));
extern void syms_of_frame P_ ((void));
extern void keys_of_frame P_ ((void));

/* defined in emacs.c */
extern Lisp_Object decode_env_path P_ ((char *, char *));
extern Lisp_Object Vinvocation_name, Vinvocation_directory;
extern Lisp_Object Vinstallation_directory;
EXFUN (Fkill_emacs, 1);
void shut_down_emacs P_ ((int, int, Lisp_Object));
/* Nonzero means don't do interactive redisplay and don't change tty modes */
extern int noninteractive;
/* Nonzero means don't do use window-system-specific display code */
extern int inhibit_window_system;
/* Nonzero means that a filter or a sentinel is running.  */
extern int running_asynch_code;

/* defined in process.c */
EXFUN (Fget_process, 1);
EXFUN (Fget_buffer_process, 1);
EXFUN (Fprocessp, 1);
EXFUN (Fprocess_status, 1);
EXFUN (Fkill_process, 2);
EXFUN (Fprocess_send_eof, 1);
EXFUN (Fwaiting_for_user_input_p, 0);
extern Lisp_Object Qprocessp;
extern void kill_buffer_processes P_ ((Lisp_Object));
extern int wait_reading_process_input P_ ((int, int, Lisp_Object, int));
extern void deactivate_process P_ ((Lisp_Object));
extern void add_keyboard_wait_descriptor P_ ((int));
extern void delete_keyboard_wait_descriptor P_ ((int));
extern void close_process_descs P_ ((void));
extern void status_notify P_ ((void));
extern int read_process_output P_ ((Lisp_Object, int));
extern void init_process P_ ((void));
extern void syms_of_process P_ ((void));

/* defined in callproc.c */
extern Lisp_Object Vexec_path, Vexec_directory, Vdata_directory;
extern Lisp_Object Vdoc_directory;
extern int child_setup P_ ((int, int, int, char **, int, Lisp_Object));
extern void init_callproc_1 P_ ((void));
extern void init_callproc P_ ((void));
extern void set_process_environment P_ ((void));
extern void syms_of_callproc P_ ((void));

/* defined in doc.c */
extern Lisp_Object Vdoc_file_name;
EXFUN (Fsubstitute_command_keys, 1);
EXFUN (Fdocumentation, 2);
EXFUN (Fdocumentation_property, 3);
extern Lisp_Object read_doc_string P_ ((Lisp_Object));
extern Lisp_Object get_doc_string P_ ((Lisp_Object, int, int));
extern void syms_of_doc P_ ((void));

/* defined in bytecode.c */
extern Lisp_Object Qbytecode;
EXFUN (Fbyte_code, 3);
extern void syms_of_bytecode P_ ((void));

/* defined in macros.c */
extern Lisp_Object Qexecute_kbd_macro;
EXFUN (Fexecute_kbd_macro, 2);
extern void init_macros P_ ((void));
extern void syms_of_macros P_ ((void));
extern void keys_of_macros P_ ((void));

/* defined in undo.c */
extern Lisp_Object Qinhibit_read_only;
EXFUN (Fundo_boundary, 0);
extern Lisp_Object truncate_undo_list P_ ((Lisp_Object, int, int));
extern void record_marker_adjustment P_ ((Lisp_Object, int));
extern void record_insert P_ ((int, int));
extern void record_delete P_ ((int, Lisp_Object));
extern void record_first_change P_ ((void));
extern void record_change P_ ((int, int));
extern void record_property_change P_ ((int, int, Lisp_Object, Lisp_Object,
					Lisp_Object));
extern void syms_of_undo P_ ((void));

/* defined in textprop.c */
extern Lisp_Object Qmodification_hooks;
extern Lisp_Object Qrear_nonsticky, Qfont;
extern Lisp_Object Qinsert_in_front_hooks, Qinsert_behind_hooks;
EXFUN (Fnext_property_change, 3);
EXFUN (Fnext_single_property_change, 4);
EXFUN (Fprevious_single_property_change, 4);
EXFUN (Fget_text_property, 3);
EXFUN (Fput_text_property, 5);
EXFUN (Fset_text_properties, 4);
EXFUN (Ftext_property_not_all, 5);
EXFUN (Fprevious_char_property_change, 2);
EXFUN (Fnext_char_property_change, 2);
extern void report_interval_modification P_ ((Lisp_Object, Lisp_Object));
extern void syms_of_textprop P_ ((void));

/* defined in intervals.c */
extern Lisp_Object get_local_map P_ ((int, struct buffer *));

/* defined in xmenu.c */
EXFUN (Fx_popup_menu, 2);
EXFUN (Fx_popup_dialog, 2);
extern void syms_of_xmenu P_ ((void));

/* defined in sysdep.c */
extern void init_sigio P_ ((int));
extern void request_sigio P_ ((void));
extern void unrequest_sigio P_ ((void));
extern void reset_sys_modes P_ ((void));
extern void sys_subshell P_ ((void));
extern void sys_suspend P_ ((void));
extern void discard_tty_input P_ ((void));
extern void init_sys_modes P_ ((void));
extern void reset_sys_modes P_ ((void));
extern void get_frame_size P_ ((int *, int *));
extern void wait_for_termination P_ ((int));
extern void flush_pending_output P_ ((int));
extern void child_setup_tty P_ ((int));
extern void setup_pty P_ ((int));
extern int set_window_size P_ ((int, int, int));
extern void create_process P_ ((Lisp_Object, char **, Lisp_Object));
extern int tabs_safe_p P_ ((void));
extern void init_baud_rate P_ ((void));

/* defined in filelock.c */
EXFUN (Funlock_buffer, 0);
EXFUN (Ffile_locked_p, 1);
extern void unlock_all_files P_ ((void));
extern void lock_file P_ ((Lisp_Object));
extern void unlock_file P_ ((Lisp_Object));
extern void unlock_buffer P_ ((struct buffer *));
extern void syms_of_filelock P_ ((void));

/* Defined in category.c */
extern void init_category_once P_ ((void));
extern void syms_of_category P_ ((void));

/* Defined in ccl.c */
extern void syms_of_ccl P_ ((void));

/* Defined in dired.c */
extern void syms_of_dired P_ ((void));

/* Defined in mocklisp.c */
extern void syms_of_mocklisp P_ ((void));

/* Defined in term.c */
extern void syms_of_term P_ ((void));

#ifdef HAVE_X_WINDOWS
/* Defined in fontset.c */
extern void syms_of_fontset P_ ((void));
#endif

/* Defined in xfaces.c */
extern void syms_of_xfaces P_ ((void));

#ifdef HAVE_X_WINDOWS
/* Defined in xfns.c */
extern void syms_of_xfns P_ ((void));
#endif

/* Defined in xselect.c */
extern void syms_of_xselect P_ ((void));

/* Defined in xterm.c */
extern void syms_of_xterm P_ ((void));

/* Nonzero means Emacs has already been initialized.
   Used during startup to detect startup of dumped Emacs.  */
extern int initialized;

extern int immediate_quit;	    /* Nonzero means ^G can quit instantly */

extern char *getenv (), *ctime (), *getwd ();
extern long *xmalloc (), *xrealloc ();
extern void xfree ();

extern char *egetenv P_ ((char *));

/* Set up the name of the machine we're running on.  */
extern void init_system_name P_ ((void));

/* Some systems (e.g., NT) use a different path separator than Unix,
   in addition to a device separator.  Default the path separator
   to '/', and don't test for a device separator in IS_ANY_SEP.  */

#ifdef WINDOWSNT
extern Lisp_Object Vdirectory_sep_char;
#endif

#ifndef DIRECTORY_SEP
#define DIRECTORY_SEP '/'
#endif
#ifndef IS_DIRECTORY_SEP
#define IS_DIRECTORY_SEP(_c_) ((_c_) == DIRECTORY_SEP)
#endif
#ifndef IS_DEVICE_SEP
#ifndef DEVICE_SEP
#define IS_DEVICE_SEP(_c_) 0
#else
#define IS_DEVICE_SEP(_c_) ((_c_) == DEVICE_SEP)
#endif
#endif
#ifndef IS_ANY_SEP
#define IS_ANY_SEP(_c_) (IS_DIRECTORY_SEP (_c_))
#endif

#ifdef SWITCH_ENUM_BUG
#define SWITCH_ENUM_CAST(x) ((int)(x))
#else
#define SWITCH_ENUM_CAST(x) (x)
#endif
