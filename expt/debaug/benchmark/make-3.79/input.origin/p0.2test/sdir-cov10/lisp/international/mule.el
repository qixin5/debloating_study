;;; mule.el --- basic commands for mulitilingual environment

;; Copyright (C) 1995 Electrotechnical Laboratory, JAPAN.
;; Licensed to the Free Software Foundation.

;; Keywords: mule, multilingual, character set, coding system

;; This file is part of GNU Emacs.

;; GNU Emacs is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;;; Code:

(defconst mule-version "4.0 (HANANOEN)" "\
Version number and name of this version of MULE (multilingual environment).")

(defconst mule-version-date "1998.7.1" "\
Distribution date of this version of MULE (multilingual environment).")

(defun load-with-code-conversion (fullname file &optional noerror nomessage)
  "Execute a file of Lisp code named FILE whose absolute name is FULLNAME.
The file contents are decoded before evaluation if necessary.
If optional second arg NOERROR is non-nil,
 report no error if FILE doesn't exist.
Print messages at start and end of loading unless
 optional third arg NOMESSAGE is non-nil.
Return t if file exists."
  (if (null (file-readable-p fullname))
      (and (null noerror)
	   (signal 'file-error (list "Cannot open load file" file)))
    ;; Read file with code conversion, and then eval.
    (let* ((buffer
	    ;; To avoid any autoloading, set default-major-mode to
	    ;; fundamental-mode.
	    ;; So that we don't get completely screwed if the
	    ;; file is encoded in some complicated character set,
	    ;; read it with real decoding, as a multibyte buffer,
	    ;; even if this is a --unibyte Emacs session.
	    (let ((default-major-mode 'fundamental-mode)
		  (default-enable-multibyte-characters t))
	      ;; We can't use `generate-new-buffer' because files.el
	      ;; is not yet loaded.
	      (get-buffer-create (generate-new-buffer-name " *load*"))))
	   (load-in-progress t)
	   (source (save-match-data (string-match "\\.el\\'" fullname))))
      (unless nomessage
	(if source
	    (message "Loading %s (source)..." file)
	  (message "Loading %s..." file)))
      (when purify-flag
	(setq preloaded-file-list (cons file preloaded-file-list)))
      (unwind-protect
	  (let ((load-file-name fullname)
		(set-auto-coding-for-load t)
		(inhibit-file-name-operation nil))
	    (save-excursion
	      (set-buffer buffer)
	      (insert-file-contents fullname)
	      ;; If the loaded file was inserted with no-conversion or
	      ;; raw-text coding system, make the buffer unibyte.
	      ;; Otherwise, eval-buffer might try to interpret random
	      ;; binary junk as multibyte characters.
	      (if (and enable-multibyte-characters
		       (or (eq (coding-system-type last-coding-system-used) 5)
			   (eq last-coding-system-used 'no-conversion)))
		  (set-buffer-multibyte nil))
	      ;; Make `kill-buffer' quiet.
	      (set-buffer-modified-p nil))
	    ;; Have the original buffer current while we eval.
	    (eval-buffer buffer nil file
			 ;; If this Emacs is running with --unibyte,
			 ;; convert multibyte strings to unibyte
			 ;; after reading them.
;;			 (not default-enable-multibyte-characters)
			 ))
	(let (kill-buffer-hook kill-buffer-query-functions)
	  (kill-buffer buffer)))
      (let ((hook (assoc file after-load-alist)))
	(when hook
	  (mapcar (function eval) (cdr hook))))
      (unless (or nomessage noninteractive)
	(if source
	    (message "Loading %s (source)...done" file)
	  (message "Loading %s...done" file)))
      t)))

;; API (Application Program Interface) for charsets.

;; Return t if OBJ is a quoted symbol
;; and the symbol is the name of a standard charset.
(defsubst charset-quoted-standard-p (obj)
  (and (listp obj) (eq (car obj) 'quote)
       (symbolp (car-safe (cdr obj)))
       (let ((vector (get (car-safe (cdr obj)) 'charset)))
	 (and (vectorp vector)
	      (< (aref vector 0) 160)))))

(defsubst charsetp (object)
  "T if OBJECT is a charset."
  (and (symbolp object) (vectorp (get object 'charset))))

(defsubst charset-info (charset)
  "Return a vector of information of CHARSET.
The elements of the vector are:
	CHARSET-ID, BYTES, DIMENSION, CHARS, WIDTH, DIRECTION,
	LEADING-CODE-BASE, LEADING-CODE-EXT,
	ISO-FINAL-CHAR, ISO-GRAPHIC-PLANE,
	REVERSE-CHARSET, SHORT-NAME, LONG-NAME,	DESCRIPTION,
	PLIST,
where
CHARSET-ID (integer) is the identification number of the charset.
BYTES (integer) is the length of multi-byte form of a character in
  the charset: one of 1, 2, 3, and 4.
DIMENSION (integer) is the number of bytes to represent a character of
the charset: 1 or 2.
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
LONG-NAME (string) is the long name to refer to the charset
DESCRIPTION (string) is the description string of the charset.
PLIST (property list) may contain any type of information a user
  want to put and get by functions `put-charset-property' and
  `get-charset-property' respectively."
  (get charset 'charset))

(defmacro charset-id (charset)
  "Return charset identification number of CHARSET."
  (if (charset-quoted-standard-p charset)
      (aref (charset-info (nth 1 charset)) 0)
    `(aref (charset-info ,charset) 0)))

(defmacro charset-bytes (charset)
  "Return bytes of CHARSET.
See the function `charset-info' for more detail."
  (if (charset-quoted-standard-p charset)
      (aref (charset-info (nth 1 charset)) 1)
    `(aref (charset-info ,charset) 1)))

(defmacro charset-dimension (charset)
  "Return dimension of CHARSET.
See the function `charset-info' for more detail."
  (if (charset-quoted-standard-p charset)
      (aref (charset-info (nth 1 charset)) 2)
    `(aref (charset-info ,charset) 2)))

(defmacro charset-chars (charset)
  "Return character numbers contained in a dimension of CHARSET.
See the function `charset-info' for more detail."
  (if (charset-quoted-standard-p charset)
      (aref (charset-info (nth 1 charset)) 3)
    `(aref (charset-info ,charset) 3)))

(defmacro charset-width (charset)
  "Return width (how many column occupied on a screen) of CHARSET.
See the function `charset-info' for more detail."
  (if (charset-quoted-standard-p charset)
      (aref (charset-info (nth 1 charset)) 4)
    `(aref (charset-info ,charset) 4)))

(defmacro charset-direction (charset)
  "Return direction of CHARSET.
See the function `charset-info' for more detail."
  (if (charset-quoted-standard-p charset)
      (aref (charset-info (nth 1 charset)) 5)
    `(aref (charset-info ,charset) 5)))

(defmacro charset-iso-final-char (charset)
  "Return final char of CHARSET.
See the function `charset-info' for more detail."
  (if (charset-quoted-standard-p charset)
      (aref (charset-info (nth 1 charset)) 8)
    `(aref (charset-info ,charset) 8)))

(defmacro charset-iso-graphic-plane (charset)
  "Return graphic plane of CHARSET.
See the function `charset-info' for more detail."
  (if (charset-quoted-standard-p charset)
      (aref (charset-info (nth 1 charset)) 9)
    `(aref (charset-info ,charset) 9)))

(defmacro charset-reverse-charset (charset)
  "Return reverse charset of CHARSET.
See the function `charset-info' for more detail."
  (if (charset-quoted-standard-p charset)
      (aref (charset-info (nth 1 charset)) 10)
    `(aref (charset-info ,charset) 10)))

(defmacro charset-short-name (charset)
  "Return short name of CHARSET.
See the function `charset-info' for more detail."
  (if (charset-quoted-standard-p charset)
      (aref (charset-info (nth 1 charset)) 11)
    `(aref (charset-info ,charset) 11)))

(defmacro charset-long-name (charset)
  "Return long name of CHARSET.
See the function `charset-info' for more detail."
  (if (charset-quoted-standard-p charset)
      (aref (charset-info (nth 1 charset)) 12)
    `(aref (charset-info ,charset) 12)))

(defmacro charset-description (charset)
  "Return description of CHARSET.
See the function `charset-info' for more detail."
  (if (charset-quoted-standard-p charset)
      (aref (charset-info (nth 1 charset)) 13)
    `(aref (charset-info ,charset) 13)))

(defmacro charset-plist (charset)
  "Return list charset property of CHARSET.
See the function `charset-info' for more detail."
  (if (charset-quoted-standard-p charset)
      `(aref ,(charset-info (nth 1 charset)) 14)
    `(aref (charset-info ,charset) 14)))

(defun set-charset-plist (charset plist)
  "Set CHARSET's property list to PLIST, and return PLIST."
  (aset (charset-info  charset) 14 plist))

(defun make-char (charset &optional c1 c2)
  "Return a character of CHARSET and position codes CODE1 and CODE2.
CODE1 and CODE2 are optional, but if you don't supply
sufficient position codes, return a generic character which stands for
all characters or group of characters in the character set.
A generic character can be used to index a char table (e.g. syntax-table)."
  (make-char-internal (charset-id charset) c1 c2))

(put 'make-char 'byte-compile
     (function 
      (lambda (form)
	(let ((charset (nth 1 form)))
	  (if (charset-quoted-standard-p charset)
	      (byte-compile-normal-call
	       (cons 'make-char-internal
		     (cons (charset-id (nth 1 charset)) (nthcdr 2 form))))
	    (byte-compile-normal-call
	     (cons 'make-char-internal
		   (cons (list 'charset-id charset) (nthcdr 2 form)))))))))

(defun charset-list ()
  "Return list of charsets ever defined.

This function is provided for backward compatibility.
Now we have the variable `charset-list'."
  charset-list)

(defsubst generic-char-p (char)
  "Return t if and only if CHAR is a generic character.
See also the documentation of make-char."
  (and (>= char 0400)
       (let ((l (split-char char)))
	 (and (or (= (nth 1 l) 0) (eq (nth 2 l) 0))
	      (not (eq (car l) 'composition))))))


;; Coding system staffs

;; Coding system is a symbol that has the property `coding-system'.
;;
;; The value of the property `coding-system' is a vector of the
;; following format:
;;	[TYPE MNEMONIC DOC-STRING PLIST FLAGS]
;; We call this vector as coding-spec.  See comments in src/coding.c
;; for more detail.  

(defconst coding-spec-type-idx 0)
(defconst coding-spec-mnemonic-idx 1)
(defconst coding-spec-doc-string-idx 2)
(defconst coding-spec-plist-idx 3)
(defconst coding-spec-flags-idx 4)

;; PLIST is a property list of a coding system.  To share PLIST among
;; alias coding systems, a coding system has PLIST in coding-spec
;; instead of having it in normal property list of Lisp symbol.
;; Here's a list of coding system properties currently being used.
;;
;; o coding-category
;;
;; The value is a coding category the coding system belongs to.  The
;; function `make-coding-system' and `define-coding-system-alias' sets
;; this value automatically.
;;
;; o alias-coding-systems
;;
;; The value is a list of coding systems of the same alias group.  The
;; first element is the coding system made at first, which we call as
;; `base coding system'.  The function `make-coding-system' and
;; `define-coding-system-alias' set this value automatically.
;;
;; o post-read-conversion
;;
;; The value is a function to call after some text is inserted and
;; decoded by the coding system itself and before any functions in
;; `after-insert-functions' are called.  The arguments to this
;; function is the same as those of a function in
;; `after-insert-functions', i.e. LENGTH of a text while putting point
;; at the head of the text to be decoded
;;
;; o pre-write-conversion
;;
;; The value is a function to call after all functions in
;; `write-region-annotate-functions' and `buffer-file-format' are
;; called, and before the text is encoded by the coding system itself.
;; The arguments to this function is the same as those of a function
;; in `write-region-annotate-functions', i.e. FROM and TO specifying
;; region of a text.
;;
;; o translation-table-for-decode
;;
;; The value is a translation table to be applied on decoding.  See
;; the function `make-translation-table' for the format of translation
;; table.
;;
;; o translation-table-for-encode
;;
;; The value is a translation table to be applied on encoding.
;;
;; o safe-charsets
;;
;; The value is a list of charsets safely supported by the coding
;; system.  The value t means that all charsets Emacs handles are
;; supported.  Even if some charset is not in this list, it doesn't
;; mean that the charset can't be encoded in the coding system,
;; instead, it just means that some other receiver of a text encoded
;; in the coding system won't be able to handle that charset.
;;
;; o mime-charset
;;
;; The value is a symbol of which name is `MIME-charset' parameter of
;; the coding system.
;;
;; o charset-origin-alist
;;
;; The value is a list of this form:
;;	(CHARSET EXTERNAL-CHARSET-NAME ENCODING-FUNCTION).
;; ENCODING-FUNCTION is a function to encode a character in CHARSET
;; to the code in EXTERNAL-CHARSET-NAME.  The command what-cursor-position
;; uses this information of the buffer-file-coding-system.
;; ENCODING-FUNCTION may be a translation table or a symbol whose
;; property `translation-table' is a translation table.  In these case,
;; the translation table is used to encode the character.
;;
;; o valid-codes (meaningful only for a coding system based on CCL)
;;
;; The value is a list to indicate valid byte ranges of the encoded
;; file.  Each element of the list is an integer or a cons of integer.
;; In the former case, the integer value is a valid byte code.  In the
;; latter case, the integers specifies the range of valid byte codes.


;; Return coding-spec of CODING-SYSTEM
(defsubst coding-system-spec (coding-system)
  (get (check-coding-system coding-system) 'coding-system))

(defun coding-system-type (coding-system)
  "Return the coding type of CODING-SYSTEM.
A coding type is an integer value indicating the encoding method
of CODING-SYSTEM.  See the function `make-coding-system' for more detail."
  (aref (coding-system-spec coding-system) coding-spec-type-idx))

(defun coding-system-mnemonic (coding-system)
  "Return the mnemonic character of CODING-SYSTEM.
The mnemonic character of a coding system is used in mode line
to indicate the coding system.  If the arg is nil, return ?-."
  (let ((spec (coding-system-spec coding-system)))
    (if spec (aref spec coding-spec-mnemonic-idx) ?-)))

(defun coding-system-doc-string (coding-system)
  "Return the documentation string for CODING-SYSTEM."
  (aref (coding-system-spec coding-system) coding-spec-doc-string-idx))

(defun coding-system-plist (coding-system)
  "Return the property list of CODING-SYSTEM."
  (aref (coding-system-spec coding-system) coding-spec-plist-idx))

(defun coding-system-flags (coding-system)
  "Return `flags' of CODING-SYSTEM.
A `flags' of a coding system is a vector of length 32 indicating detailed
information of a coding system.  See the function `make-coding-system'
for more detail."
  (aref (coding-system-spec coding-system) coding-spec-flags-idx))

(defun coding-system-get (coding-system prop)
  "Extract a value from CODING-SYSTEM's property list for property PROP."
  (plist-get (coding-system-plist coding-system) prop))

(defun coding-system-put (coding-system prop val)
  "Change value in CODING-SYSTEM's property list PROP to VAL."
  (let ((plist (coding-system-plist coding-system)))
    (if plist
	(plist-put plist prop val)
      (aset (coding-system-spec coding-system) coding-spec-plist-idx
	    (list prop val)))))

(defun coding-system-category (coding-system)
  "Return the coding category of CODING-SYSTEM."
  (coding-system-get coding-system 'coding-category))

(defun coding-system-base (coding-system)
  "Return the base coding system of CODING-SYSTEM.
A base coding system is what made by `make-coding-system'.
Any alias nor subsidiary coding systems are not base coding system."
  (car (coding-system-get coding-system 'alias-coding-systems)))

(defalias 'coding-system-parent 'coding-system-base)
(make-obsolete 'coding-system-parent 'coding-system-base)

;; Coding system also has a property `eol-type'.
;;
;; This property indicates how the coding system handles end-of-line
;; format.  The value is integer 0, 1, 2, or a vector of three coding
;; systems.  Each integer value 0, 1, and 2 indicates the format of
;; end-of-line LF, CRLF, and CR respectively.  A vector value
;; indicates that the format of end-of-line should be detected
;; automatically.  Nth element of the vector is the subsidiary coding
;; system whose `eol-type' property is N.

(defun coding-system-eol-type (coding-system)
  "Return eol-type of CODING-SYSTEM.
An eol-type is integer 0, 1, 2, or a vector of coding systems.

Integer values 0, 1, and 2 indicate a format of end-of-line; LF,
CRLF, and CR respectively.

A vector value indicates that a format of end-of-line should be
detected automatically.  Nth element of the vector is the subsidiary
coding system whose eol-type is N."
  (get coding-system 'eol-type))

(defun coding-system-lessp (x y)
  (cond ((eq x 'no-conversion) t)
	((eq y 'no-conversion) nil)
	((eq x 'emacs-mule) t)
	((eq y 'emacs-mule) nil)
	((eq x 'undecided) t)
	((eq y 'undecided) nil)
	(t (let ((c1 (coding-system-mnemonic x))
		 (c2 (coding-system-mnemonic y)))
	     (or (< (downcase c1) (downcase c2))
		 (and (not (> (downcase c1) (downcase c2)))
		      (< c1 c2)))))))

;; Add CODING-SYSTEM to coding-system-list while keeping it sorted.
(defun add-to-coding-system-list (coding-system)
  (if (or (null coding-system-list)
	  (coding-system-lessp coding-system (car coding-system-list)))
      (setq coding-system-list (cons coding-system coding-system-list))
    (let ((len (length coding-system-list))
	  mid (tem coding-system-list))
      (while (> len 1)
	(setq mid (nthcdr (/ len 2) tem))
	(if (coding-system-lessp (car mid) coding-system)
	    (setq tem mid
		  len (- len (/ len 2)))
	  (setq len (/ len 2))))
      (setcdr tem (cons coding-system (cdr tem))))))

(defun coding-system-list (&optional base-only)
  "Return a list of all existing coding systems.
If optional arg BASE-ONLY is non-nil, only base coding systems are listed."
  (let* ((codings (copy-sequence coding-system-list))
	 (tail (cons nil codings)))
    ;; Remove subsidiary coding systems (eol variants) and alias
    ;; coding systems (if necessary).
    (while (cdr tail)
      (let* ((coding (car (cdr tail)))
	     (aliases (coding-system-get coding 'alias-coding-systems)))
	(if (or
	     ;; CODING is an eol variant if not in ALIASES.
	     (not (memq coding aliases))
	     ;; CODING is an alias if it is not car of ALIASES.
	     (and base-only (not (eq coding (car aliases)))))
	    (setcdr tail (cdr (cdr tail)))
	  (setq tail (cdr tail)))))
    codings))

;; Make subsidiary coding systems (eol-type variants) of CODING-SYSTEM.
(defun make-subsidiary-coding-system (coding-system)
  (let ((coding-spec (coding-system-spec coding-system))
	(subsidiaries (vector (intern (format "%s-unix" coding-system))
			      (intern (format "%s-dos" coding-system))
			      (intern (format "%s-mac" coding-system))))
	(i 0)
	temp)
    (while (< i 3)
      (put (aref subsidiaries i) 'coding-system coding-spec)
      (put (aref subsidiaries i) 'eol-type i)
      (add-to-coding-system-list (aref subsidiaries i))
      (setq coding-system-alist
	    (cons (list (symbol-name (aref subsidiaries i)))
		  coding-system-alist))
      (setq i (1+ i)))
    subsidiaries))

(defun make-coding-system (coding-system type mnemonic doc-string
					 &optional flags properties)
  "Define a new coding system CODING-SYSTEM (symbol).
Remaining arguments are TYPE, MNEMONIC, DOC-STRING, FLAGS (optional), 
and PROPERTIES (optional) which construct a coding-spec of CODING-SYSTEM
in the following format:
	[TYPE MNEMONIC DOC-STRING PLIST FLAGS]

TYPE is an integer value indicating the type of the coding system as follows:
  0: Emacs internal format,
  1: Shift-JIS (or MS-Kanji) used mainly on Japanese PC,
  2: ISO-2022 including many variants,
  3: Big5 used mainly on Chinese PC,
  4: private, CCL programs provide encoding/decoding algorithm,
  5: Raw-text, which means that text contains random 8-bit codes. 

MNEMONIC is a character to be displayed on mode line for the coding system.

DOC-STRING is a documentation string for the coding system.

FLAGS specifies more detailed information of the coding system as follows:

  If TYPE is 2 (ISO-2022), FLAGS is a list of these elements:
      CHARSET0, CHARSET1, CHARSET2, CHARSET3, SHORT-FORM,
      ASCII-EOL, ASCII-CNTL, SEVEN, LOCKING-SHIFT, SINGLE-SHIFT,
      USE-ROMAN, USE-OLDJIS, NO-ISO6429, INIT-BOL, DESIGNATION-BOL,
      SAFE, ACCEPT-LATIN-EXTRA-CODE.
    CHARSETn are character sets initially designated to Gn graphic registers.
      If CHARSETn is nil, Gn is never used.
      If CHARSETn is t, Gn can be used but nothing designated initially.
      If CHARSETn is a list of character sets, those character sets are
        designated to Gn on output, but nothing designated to Gn initially.
        But, character set `ascii' can be designated only to G0.
    SHORT-FORM non-nil means use short designation sequence on output.
    ASCII-EOL non-nil means designate ASCII to g0 at end of line on output.
    ASCII-CNTL non-nil means designate ASCII to g0 before control codes and
      SPACE on output.
    SEVEN non-nil means use 7-bit code only on output.
    LOCKING-SHIFT non-nil means use locking-shift.
    SINGLE-SHIFT non-nil means use single-shift.
    USE-ROMAN non-nil means designate JIS0201-1976-Roman instead of ASCII.
    USE-OLDJIS non-nil means designate JIS0208-1976 instead of JIS0208-1983.
    NO-ISO6429 non-nil means not use ISO6429's direction specification.
    INIT-BOL non-nil means any designation state is assumed to be reset
      to initial at each beginning of line on output.
    DESIGNATION-BOL non-nil means designation sequences should be placed
      at beginning of line on output.
    SAFE non-nil means convert unsafe characters to `?' on output.
      Unsafe characters are what not specified in SAFE-CHARSET.
    ACCEPT-LATIN-EXTRA-CODE non-nil means code-detection routine accepts
      a code specified in `latin-extra-code-table' (which see) as a valid
      code of the coding system.

  If TYPE is 4 (private), FLAGS should be a cons of CCL programs, for
    decoding and encoding.  CCL programs should be specified by their
    symbols.

PROPERTIES is an alist of properties vs the corresponding values.
These properties are set in PLIST, a property list.  This function
also sets properties `coding-category' and `alias-coding-systems'
automatically.

Kludgy features for backward compatibility:

1. If TYPE is 4 and car or cdr of FLAGS is a vector, the vector is
treated as a compiled CCL code.

2. If PROPERTIES is just a list of character sets, the list is set as
a value of `safe-charsets' in PLIST."
  (if (memq coding-system coding-system-list)
      (error "Coding system %s already exists" coding-system))

  ;; Set a value of `coding-system' property.
  (let ((coding-spec (make-vector 5 nil))
	(no-initial-designation t)
	(no-alternative-designation t)
	coding-category)
    (if (or (not (integerp type)) (< type 0) (> type 5))
	(error "TYPE argument must be 0..5"))
    (if (or (not (integerp mnemonic)) (<= mnemonic ? ) (> mnemonic 127))
	(error "MNEMONIC argument must be an ASCII printable character."))
    (aset coding-spec coding-spec-type-idx type)
    (aset coding-spec coding-spec-mnemonic-idx mnemonic)
    (aset coding-spec coding-spec-doc-string-idx
	  (if (stringp doc-string) doc-string ""))
    (cond ((= type 0)
	   (setq coding-category 'coding-category-emacs-mule))
	  ((= type 1)
	   (setq coding-category 'coding-category-sjis))
	  ((= type 2)			; ISO2022
	   (let ((i 0)
		 (vec (make-vector 32 nil))
		 (g1-designation nil)
		 (fl flags))
	     (while (< i 4)
	       (let ((charset (car fl)))
		 (if (and no-initial-designation
			  (> i 0)
			  (or (charsetp charset)
			      (and (consp charset)
				   (charsetp (car charset)))))
		     (setq no-initial-designation nil))
		 (if (charsetp charset)
		     (if (= i 1) (setq g1-designation charset))
		   (if (consp charset)
		       (let ((tail charset)
			     elt)
			 (while tail
			   (setq elt (car tail))
			   (if (eq elt t)
			       (setq no-alternative-designation nil)
			     (if (and elt (not (charsetp elt)))
				 (error "Invalid charset: %s" elt)))
			   (setq tail (cdr tail)))
			 (setq g1-designation (car charset)))
		     (if charset
			 (if (eq charset t)
			     (setq no-alternative-designation nil)
			   (error "Invalid charset: %s" charset)))))
		 (aset vec i charset))
	       (setq fl (cdr fl) i (1+ i)))
	     (while (and (< i 32) fl)
	       (aset vec i (car fl))
	       (setq fl (cdr fl) i (1+ i)))
	     (aset coding-spec 4 vec)
	     (setq coding-category
		   (if (aref vec 8)	; Use locking-shift.
		       (or (and (aref vec 7) 'coding-category-iso-7-else)
			   'coding-category-iso-8-else)
		     (if (aref vec 7)	; 7-bit only.
			 (if (aref vec 9) ; Use single-shift.
			     'coding-category-iso-7-else
			   (if no-alternative-designation
			       'coding-category-iso-7-tight
			     'coding-category-iso-7))
		       (if (or no-initial-designation
			       (not no-alternative-designation))
			   'coding-category-iso-8-else
			 (if (and (charsetp g1-designation)
				  (= (charset-dimension g1-designation) 2))
			     'coding-category-iso-8-2
			   'coding-category-iso-8-1)))))))
	  ((= type 3)
	   (setq coding-category 'coding-category-big5))
	  ((= type 4)			; private
	   (setq coding-category 'coding-category-ccl)
	   (if (not (consp flags))
	       (error "Invalid FLAGS argument for TYPE 4 (CCL)")
	     (let ((decoder (check-ccl-program
			     (car flags)
			     (intern (format "%s-decoder" coding-system))))
		   (encoder (check-ccl-program
			     (cdr flags)
			     (intern (format "%s-encoder" coding-system)))))
	       (if (and decoder encoder)
		   (aset coding-spec 4 (cons decoder encoder))
		 (error "Invalid FLAGS argument for TYPE 4 (CCL)")))))
	  (t				; i.e. (= type 5)
	   (setq coding-category 'coding-category-raw-text)))

    (let ((plist (list 'coding-category coding-category
		       'alias-coding-systems (list coding-system))))
      (if no-initial-designation
	  (plist-put plist 'no-initial-designation t))
      (if (and properties
	       (or (eq properties t)
		   (not (consp (car properties)))))
	  ;; In the old version, the arg PROPERTIES is a list to be
	  ;; set in PLIST as a value of property `safe-charsets'.
	  (plist-put plist 'safe-charsets properties)
	(let ((l properties))
	  (while l
	    (plist-put plist (car (car l)) (cdr (car l)))
	    (setq l (cdr l)))))
      (aset coding-spec coding-spec-plist-idx plist))
    (put coding-system 'coding-system coding-spec)
    (put coding-category 'coding-systems
	 (cons coding-system (get coding-category 'coding-systems))))

  ;; Next, set a value of `eol-type' property.  The value is a vector
  ;; of subsidiary coding systems, each corresponds to a coding system
  ;; for the detected end-of-line format.
  (put coding-system 'eol-type
       (if (or (<= type 3) (= type 5))
	   (make-subsidiary-coding-system coding-system)
	 0))

  ;; At last, register CODING-SYSTEM in `coding-system-list' and
  ;; `coding-system-alist'.
  (add-to-coding-system-list coding-system)
  (setq coding-system-alist (cons (list (symbol-name coding-system))
				  coding-system-alist))

  ;; For a coding system of cateogory iso-8-1 and iso-8-2, create
  ;; XXX-with-esc variants.
  (let ((coding-category (coding-system-category coding-system)))
    (if (or (eq coding-category 'coding-category-iso-8-1)
	    (eq coding-category 'coding-category-iso-8-2))
	(let ((esc (intern (concat (symbol-name coding-system) "-with-esc")))
	      (doc (format "Same as %s but can handle any charsets by ISO's escape sequences." coding-system)))
	  (make-coding-system esc type mnemonic doc
			      (if (listp (car flags))
				  (cons (append (car flags) '(t)) (cdr flags))
				(cons (list (car flags) t) (cdr flags)))
			      properties)
	  (coding-system-put esc 'mime-charset nil)
	  (coding-system-put esc 'safe-charsets t))))

  coding-system)

(defun define-coding-system-alias (alias coding-system)
  "Define ALIAS as an alias for coding system CODING-SYSTEM."
  (put alias 'coding-system (coding-system-spec coding-system))
  (nconc (coding-system-get alias 'alias-coding-systems) (list alias))
  (add-to-coding-system-list alias)
  (setq coding-system-alist (cons (list (symbol-name alias))
				  coding-system-alist))
  (let ((eol-type (coding-system-eol-type coding-system)))
    (if (vectorp eol-type)
	(put alias 'eol-type (make-subsidiary-coding-system alias))
      (put alias 'eol-type eol-type))))

(defun set-buffer-file-coding-system (coding-system &optional force)
  "Set the file coding-system of the current buffer to CODING-SYSTEM.
This means that when you save the buffer, it will be converted
according to CODING-SYSTEM.  For a list of possible values of CODING-SYSTEM,
use \\[list-coding-systems].

If the buffer's previous file coding-system value specifies end-of-line
conversion, and CODING-SYSTEM does not specify one, CODING-SYSTEM is
merged with the already-specified end-of-line conversion.
However, if the optional prefix argument FORCE is non-nil,
then CODING-SYSTEM is used exactly as specified."
  (interactive "zCoding system for visited file (default, nil): \nP")
  (check-coding-system coding-system)
  (if (null force)
      (let ((x (coding-system-eol-type buffer-file-coding-system))
	    (y (coding-system-eol-type coding-system)))
	(if (and (numberp x) (>= x 0) (<= x 2) (vectorp y))
	    (setq coding-system (aref y x)))))
  (setq buffer-file-coding-system coding-system)
  (set-buffer-modified-p t)
  (force-mode-line-update))

(defvar default-terminal-coding-system nil
  "Default value for the terminal coding system.
This is normally set according to the selected language environment.
See also the command `set-terminal-coding-system'.")

(defun set-terminal-coding-system (coding-system)
  "Set coding system of your terminal to CODING-SYSTEM.
All text output to the terminal will be encoded
with the specified coding system.
For a list of possible values of CODING-SYSTEM, use \\[list-coding-systems].
The default is determined by the selected language environment
or by the previous use of this command."
  (interactive
   (list (let ((default (if (and (not (terminal-coding-system))
				 default-terminal-coding-system)
			    default-terminal-coding-system)))
	   (read-coding-system
	    (format "Coding system for terminal display (default, %s): "
		    default)
	    default))))
  (if (and (not coding-system)
	   (not (terminal-coding-system)))
      (setq coding-system default-terminal-coding-system))
  (if coding-system
      (setq default-terminal-coding-system coding-system))      
  (set-terminal-coding-system-internal coding-system)
  (redraw-frame (selected-frame)))

(defvar default-keyboard-coding-system nil
  "Default value of the keyboard coding system.
This is normally set according to the selected language environment.
See also the command `set-keyboard-coding-system'.")

(defun set-keyboard-coding-system (coding-system)
  "Set coding system for keyboard input to CODING-SYSTEM.
In addition, this command enables Encoded-kbd minor mode.
\(If CODING-SYSTEM is nil, Encoded-kbd mode is turned off.)
For a list of possible values of CODING-SYSTEM, use \\[list-coding-systems].
The default is determined by the selected language environment
or by the previous use of this command."
  (interactive
   (list (let ((default (if (and (not (keyboard-coding-system))
				 default-keyboard-coding-system)
			    default-keyboard-coding-system)))
	   (read-coding-system
	    (format "Coding system for keyboard input (default, %s): "
		    default)
	    default))))
  (if (and (not coding-system)
	   (not (keyboard-coding-system)))
      (setq coding-system default-keyboard-coding-system))
  (if coding-system
      (setq default-keyboard-coding-system coding-system))
  (set-keyboard-coding-system-internal coding-system)
  (encoded-kbd-mode (if coding-system 1 0)))

(defun set-buffer-process-coding-system (decoding encoding)
  "Set coding systems for the process associated with the current buffer.
DECODING is the coding system to be used to decode input from the process,
ENCODING is the coding system to be used to encode output to the process.

For a list of possible values of CODING-SYSTEM, use \\[list-coding-systems]."
  (interactive
   "zCoding-system for process input: \nzCoding-system for process output: ")
  (let ((proc (get-buffer-process (current-buffer))))
    (if (null proc)
	(error "no process")
      (check-coding-system decoding)
      (check-coding-system encoding)
      (set-process-coding-system proc decoding encoding)))
  (force-mode-line-update))

(defalias 'set-clipboard-coding-system 'set-selection-coding-system)

(defun set-selection-coding-system (coding-system)
  "Make CODING-SYSTEM used for communicating with other X clients .
When sending or receiving text via cut_buffer, selection, and clipboard,
the text is encoded or decoded by CODING-SYSTEM."
  (interactive "zCoding system for X selection: ")
  (check-coding-system coding-system)
  (setq selection-coding-system coding-system))

;; Coding system lastly specified by the command
;; set-next-selection-coding-system.
(defvar last-next-selection-coding-system nil)

(defun set-next-selection-coding-system (coding-system)
  "Make CODING-SYSTEM used for the next communication with other X clients.
This setting is effective for the next communication only."
  (interactive
   (list (read-coding-system
	  (if last-next-selection-coding-system
	      (format "Coding system for the next X selection (default, %S): "
		      last-next-selection-coding-system)
	    "Coding system for the next X selection: ")
	  last-next-selection-coding-system)))
  (if coding-system
      (setq last-next-selection-coding-system coding-system)
    (setq coding-system last-next-selection-coding-system))
  (check-coding-system coding-system)

  (setq next-selection-coding-system coding-system))

(defun set-coding-priority (arg)
  "Set priority of coding categories according to LIST.
LIST is a list of coding categories ordered by priority."
  (let ((l arg)
	(current-list (copy-sequence coding-category-list)))
    ;; Check the validity of ARG while deleting coding categories in
    ;; ARG from CURRENT-LIST.  We assume that CODING-CATEGORY-LIST
    ;; contains all coding categories.
    (while l
      (if (or (null (get (car l) 'coding-category-index))
	      (null (memq (car l) current-list)))
	  (error "Invalid or duplicated element in argument: %s" arg))
      (setq current-list (delq (car l) current-list))
      (setq l (cdr l)))
    ;; Update `coding-category-list' and return it.
    (setq coding-category-list (append arg current-list))
    (set-coding-priority-internal)))

;;; FILE I/O

(defvar auto-coding-alist
  '(("\\.\\(arc\\|zip\\|lzh\\|zoo\\|jar\\|tar\\|tgz\\)\\'" . no-conversion)
    ("\\.\\(ARC\\|ZIP\\|LZH\\|ZOO\\|JAR\\|TAR\\|TGZ\\)\\'" . no-conversion))
  "Alist of filename patterns vs corresponding coding systems.
Each element looks like (REGEXP . CODING-SYSTEM).
A file whose name matches REGEXP is decoded by CODING-SYSTEM on reading.

The settings in this alist take priority over `coding:' tags
in the file (see the function `set-auto-coding')
and the contents of `file-coding-system-alist'.")

(defvar set-auto-coding-for-load nil
  "Non-nil means look for `load-coding' property instead of `coding'.
This is used for loading and byte-compiling Emacs Lisp files.")

(defun auto-coding-alist-lookup (filename)
  "Return the coding system specified by `auto-coding-alist' for FILENAME."
  (let ((alist auto-coding-alist)
	(case-fold-search (memq system-type '(vax-vms windows-nt ms-dos)))
	coding-system)
    (while (and alist (not coding-system))
      (if (string-match (car (car alist)) filename)
	  (setq coding-system (cdr (car alist)))
	(setq alist (cdr alist))))
    coding-system))

(defun set-auto-coding (filename size)
  "Return coding system for a file FILENAME of which SIZE bytes follow point.
These bytes should include at least the first 1k of the file
and the last 3k of the file, but the middle may be omitted.

It checks FILENAME against the variable `auto-coding-alist'.
If FILENAME doesn't match any entries in the variable,
it checks for a `coding:' tag in the first one or two lines following
point.  If no `coding:' tag is found, it checks for local variables
list in the last 3K bytes out of the SIZE bytes.

The return value is the specified coding system,
or nil if nothing specified.

The variable `set-auto-coding-function' (which see) is set to this
function by default."
  (save-match-data (set-auto-coding-1 filename size)))

(defun set-auto-coding-1 (filename size)
  (let ((coding-system (auto-coding-alist-lookup filename)))

    (or coding-system
	(let* ((case-fold-search t)
	       (head-start (point))
	       (head-end (+ head-start (min size 1024)))
	       (tail-start (+ head-start (max (- size 3072) 0)))
	       (tail-end (+ head-start size))
	       coding-system head-found tail-found pos)
	  ;; Try a short cut by searching for the string "coding:"
	  ;; and for "unibyte:" at the head and tail of SIZE bytes.
	  (setq head-found (or (search-forward "coding:" head-end t)
			       (search-forward "unibyte:" head-end t)))
	  (if (and head-found (> head-found tail-start))
	      ;; Head and tail are overlapped.
	      (setq tail-found head-found)
	    (goto-char tail-start)
	    (setq tail-found (or (search-forward "coding:" tail-end t)
				 (search-forward "unibyte:" tail-end t))))

	  ;; At first check the head.
	  (when head-found
	    (goto-char head-start)
	    (setq pos (re-search-forward "[\n\r]" head-end t))
	    (if (and pos
		     (= (char-after head-start) ?#)
		     (= (char-after (1+ head-start)) ?!))
		;; If the file begins with "#!" (exec interpreter magic),
		;; look for coding frobs in the first two lines.  You cannot
		;; necessarily put them in the first line of such a file
		;; without screwing up the interpreter invocation.
		(setq pos (search-forward "\n" head-end t)))
	    (if pos (setq head-end pos))
	    (when (< head-found head-end)
	      (goto-char head-start)
	      (when (and set-auto-coding-for-load
			 (re-search-forward
			  "-\\*-\\(.*;\\)?[ \t]*unibyte:[ \t]*\\([^ ;]+\\)"
			  head-end t))
		(setq coding-system 'raw-text))
	      (when (and (not coding-system)
			 (re-search-forward
			  "-\\*-\\(.*;\\)?[ \t]*coding:[ \t]*\\([^ ;]+\\)"
			  head-end t))
		(setq coding-system (intern (match-string 2)))
		(or (coding-system-p coding-system)
		    (setq coding-system nil)))))

	  ;; If no coding: tag in the head, check the tail.
	  (when (and tail-found (not coding-system))
	    (goto-char tail-start)
	    (search-forward "\n\^L" nil t)
	    (if (re-search-forward
		 "^\\(.*\\)[ \t]*Local Variables:[ \t]*\\(.*\\)$" tail-end t)
		;; The prefix is what comes before "local variables:" in its
		;; line.  The suffix is what comes after "local variables:"
		;; in its line.
		(let* ((prefix (regexp-quote (match-string 1)))
		       (suffix (regexp-quote (match-string 2)))
		       (re-coding
			(concat
			 "^" prefix
			 "[ \t]*coding[ \t]*:[ \t]*\\([^ \t]+\\)[ \t]*"
			 suffix "$"))
		       (re-unibyte
			(concat
			 "^" prefix
			 "[ \t]*unibyte[ \t]*:[ \t]*\\([^ \t]+\\)[ \t]*"
			 suffix "$"))
		       (re-end
			(concat "^" prefix "[ \t]*end *:[ \t]*" suffix "$"))
		       (pos (point)))
		  (re-search-forward re-end tail-end 'move)
		  (setq tail-end (point))
		  (goto-char pos)
		  (when (and set-auto-coding-for-load
			     (re-search-forward re-unibyte tail-end t))
		    (setq coding-system 'raw-text))
		  (when (and (not coding-system)
			     (re-search-forward re-coding tail-end t))
		    (setq coding-system (intern (match-string 1)))
		    (or (coding-system-p coding-system)
			(setq coding-system nil))))))
	  coding-system))))

(setq set-auto-coding-function 'set-auto-coding)

;; Set buffer-file-coding-system of the current buffer after some text
;; is inserted.
(defun after-insert-file-set-buffer-file-coding-system (inserted)
  (if last-coding-system-used
      (let ((coding-system
	     (find-new-buffer-file-coding-system last-coding-system-used))
	    (modified-p (buffer-modified-p)))
	(when coding-system
	  (set-buffer-file-coding-system coding-system)
	  (if (and enable-multibyte-characters
		   (or (eq coding-system 'no-conversion)
		       (eq (coding-system-type coding-system) 5))
		   ;; If buffer was unmodified, we must be visiting it.
		   (not modified-p))
	      ;; For coding systems no-conversion and raw-text...,
	      ;; edit the buffer as unibyte.
	      (let ((pos-byte (position-bytes (+ (point) inserted))))
		(set-buffer-multibyte nil)
		(setq inserted (- pos-byte (position-bytes (point))))))
	  (set-buffer-modified-p modified-p))))
  inserted)

(add-hook 'after-insert-file-functions
	  'after-insert-file-set-buffer-file-coding-system)

;; The coding-spec and eol-type of coding-system returned is decided
;; independently in the following order.
;;	1. That of buffer-file-coding-system locally bound.
;;	2. That of CODING.

(defun find-new-buffer-file-coding-system (coding)
  "Return a coding system for a buffer when a file of CODING is inserted.
The local variable `buffer-file-coding-system' of the current buffer
is set to the returned value.
Return nil if there's no need to set `buffer-file-coding-system'."
  (let (local-coding local-eol
	found-coding found-eol
	new-coding new-eol)
    (if (null coding)
	;; Nothing found about coding.
	nil

      ;; Get information of `buffer-file-coding-system' in LOCAL-EOL
      ;; and LOCAL-CODING.
      (setq local-eol (coding-system-eol-type buffer-file-coding-system))
      (if (null (numberp local-eol))
	  ;; But eol-type is not yet set.
	  (setq local-eol nil))
      (if (and buffer-file-coding-system
	       (not (eq (coding-system-type buffer-file-coding-system) t)))
	  ;; This is not `undecided'.
	  (setq local-coding (coding-system-base buffer-file-coding-system)))

      (if (and (local-variable-p 'buffer-file-coding-system)
	       local-eol local-coding)
	  ;; The current buffer has already set full coding-system, we
	  ;; had better not change it.
	  nil

	(setq found-eol (coding-system-eol-type coding))
	(if (null (numberp found-eol))
  	    ;; But eol-type is not found.
	    ;; If EOL conversions are inhibited, force unix eol-type.
	    (setq found-eol (if inhibit-eol-conversion 0)))
	(if (eq (coding-system-type coding) t)
	    (setq found-coding 'undecided)
	  (setq found-coding (coding-system-base coding)))

	(if (and (not found-eol) (eq found-coding 'undecided))
	    ;; No valid coding information found.
	    nil

	  ;; Some coding information (eol or text) found.

	  ;; The local setting takes precedence over the found one.
	  (setq new-coding (if (local-variable-p 'buffer-file-coding-system)
			       (or local-coding found-coding)
			     (or found-coding local-coding)))
	  (setq new-eol (if (local-variable-p 'buffer-file-coding-system)
			    (or local-eol found-eol)
			  (or found-eol local-eol)))

	  (let ((eol-type (coding-system-eol-type new-coding)))
	    (if (and (numberp new-eol) (vectorp eol-type))
		(aref eol-type new-eol)
	      new-coding)))))))

(defun modify-coding-system-alist (target-type regexp coding-system)
  "Modify one of look up tables for finding a coding system on I/O operation.
There are three of such tables, `file-coding-system-alist',
`process-coding-system-alist', and `network-coding-system-alist'.

TARGET-TYPE specifies which of them to modify.
If it is `file', it affects `file-coding-system-alist' (which see).
If it is `process', it affects `process-coding-system-alist' (which see).
If it is `network', it affects `network-coding-system-alist' (which see).

REGEXP is a regular expression matching a target of I/O operation.
The target is a file name if TARGET-TYPE is `file', a program name if
TARGET-TYPE is `process', or a network service name or a port number
to connect to if TARGET-TYPE is `network'.

CODING-SYSTEM is a coding system to perform code conversion on the I/O
operation, or a cons cell (DECODING . ENCODING) specifying the coding systems
for decoding and encoding respectively,
or a function symbol which, when called, returns such a cons cell."
  (or (memq target-type '(file process network))
      (error "Invalid target type: %s" target-type))
  (or (stringp regexp)
      (and (eq target-type 'network) (integerp regexp))
      (error "Invalid regular expression: %s" regexp))
  (if (symbolp coding-system)
      (if (not (fboundp coding-system))
	  (progn
	    (check-coding-system coding-system)
	    (setq coding-system (cons coding-system coding-system))))
    (check-coding-system (car coding-system))
    (check-coding-system (cdr coding-system)))
  (cond ((eq target-type 'file)
	 (let ((slot (assoc regexp file-coding-system-alist)))
	   (if slot
	       (setcdr slot coding-system)
	     (setq file-coding-system-alist
		   (cons (cons regexp coding-system)
			 file-coding-system-alist)))))
	((eq target-type 'process)
	 (let ((slot (assoc regexp process-coding-system-alist)))
	   (if slot
	       (setcdr slot coding-system)
	     (setq process-coding-system-alist
		   (cons (cons regexp coding-system)
			 process-coding-system-alist)))))
	(t
	 (let ((slot (assoc regexp network-coding-system-alist)))
	   (if slot
	       (setcdr slot coding-system)
	     (setq network-coding-system-alist
		   (cons (cons regexp coding-system)
			 network-coding-system-alist)))))))

(defun make-translation-table (&rest args)
  "Make a translation table (char table) from arguments.
Each argument is a list of the form (FROM . TO),
where FROM is a character to be translated to TO.

FROM can be a generic character (see `make-char').  In this case, TO is
a generic character containing the same number of characters, or a
ordinary character.  If FROM and TO are both generic characters, all
characters belonging to FROM are translated to characters belonging to TO
without changing their position code(s)."
  (let ((table (make-char-table 'translation-table))
	revlist)
    (while args
      (let ((elts (car args)))
	(while elts
	  (let* ((from (car (car elts)))
		 (from-i 0)		; degree of freedom of FROM
		 (from-rev (nreverse (split-char from)))
		 (to (cdr (car elts)))
		 (to-i 0)		; degree of freedom of TO
		 (to-rev (nreverse (split-char to))))
	    ;; Check numbers of heading 0s in FROM-REV and TO-REV.
	    (while (eq (car from-rev) 0)
	      (setq from-i (1+ from-i) from-rev (cdr from-rev)))
	    (while (eq (car to-rev) 0)
	      (setq to-i (1+ to-i) to-rev (cdr to-rev)))
	    (if (and (/= from-i to-i) (/= to-i 0))
		(error "Invalid character pair (%d . %d)" from to))
	    ;; If we have already translated TO to TO-ALT, FROM should
	    ;; also be translated to TO-ALT.  But, this is only if TO
	    ;; is a generic character or TO-ALT is not a generic
	    ;; character.
	    (let ((to-alt (aref table to)))
	      (if (and to-alt
		       (or (> to-i 0) (not (generic-char-p to-alt))))
		  (setq to to-alt)))
	    (if (> from-i 0)
		(set-char-table-default table from to)
	      (aset table from to))
	    ;; If we have already translated some chars to FROM, they
	    ;; should also be translated to TO.
	    (let ((l (assq from revlist)))
	      (if l
		  (let ((ch (car l)))
		    (setcar l to)
		    (setq l (cdr l))
		    (while l
		      (aset table ch to)
		      (setq l (cdr l)) ))))
	    ;; Now update REVLIST.
	    (let ((l (assq to revlist)))
	      (if l
		  (setcdr l (cons from (cdr l)))
		(setq revlist (cons (list to from) revlist)))))
	  (setq elts (cdr elts))))
      (setq args (cdr args)))
    ;; Return TABLE just created.
    table))

(defun make-translation-table-from-vector (vec)
  "Make translation table from decoding vector VEC.
VEC is an array of 256 elements to map unibyte codes to multibyte characters.
See also the variable `nonascii-translation-table'."
  (let ((table (make-char-table 'translation-table))
	(rev-table (make-char-table 'translation-table))
	(i 0)
	ch)
    (while (< i 256)
      (setq ch (aref vec i))
      (aset table i ch)
      (if (>= ch 256)
	  (aset rev-table ch i))
      (setq i (1+ i)))
    (set-char-table-extra-slot table 0 rev-table)
    table))

(defun define-translation-table (symbol &rest args)
  "Define SYMBOL as a name of translation table made by ARGS.

If the first element of ARGS is a char-table of which purpose is
translation-table, just define SYMBOL as the name of it.

In the other case, ARGS are the same as arguments to the function
`make-translation-table' (which see).

This function sets properties `translation-table' and
`translation-table-id' of SYMBOL to the created table itself and
identification number of the table respectively."
  (let ((table (if (and (char-table-p (car args))
			(eq (char-table-subtype (car args))
			    'translation-table))
		   (car args)
		 (apply 'make-translation-table args)))
	(len (length translation-table-vector))
	(id 0)
	(done nil))
    (put symbol 'translation-table table)
    (while (not done)
      (if (>= id len)
	  (setq translation-table-vector
		(vconcat translation-table-vector (make-vector len nil))))
      (let ((slot (aref translation-table-vector id)))
	(if (or (not slot)
		(eq (car slot) symbol))
	    (progn
	      (aset translation-table-vector id (cons symbol table))
	      (setq done t))
	  (setq id (1+ id)))))
    (put symbol 'translation-table-id id)
    id))

;;; Initialize some variables.

(put 'use-default-ascent 'char-table-extra-slots 0)
(setq use-default-ascent (make-char-table 'use-default-ascent))
(put 'ignore-relative-composition 'char-table-extra-slots 0)
(setq ignore-relative-composition
      (make-char-table 'ignore-relative-composition))

;;;
(provide 'mule)

;;; mule.el ends here
