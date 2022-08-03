;;; characters.el --- set syntax and category for multibyte characters

;; Copyright (C) 1995, 1997 Electrotechnical Laboratory, JAPAN.
;; Licensed to the Free Software Foundation.

;; Keywords: multibyte character, character set, syntax, category

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

;;; Commentary:

;; This file contains multibyte characters.  Save this file always in
;; the coding system `iso-2022-7bit'.

;; This file does not define the syntax for Latin-N character sets;
;; those are defined by the files latin-N.el.

;;; Predefined categories.

;; For each character set.

(define-category ?a "ASCII")
(define-category ?l "Latin")
(define-category ?t "Thai")
(define-category ?g "Greek")
(define-category ?b "Arabic")
(define-category ?w "Hebrew")
(define-category ?y "Cyrillic")
(define-category ?k "Japanese katakana")
(define-category ?r "Japanese roman")
(define-category ?c "Chinese")
(define-category ?j "Japanese")
(define-category ?h "Korean")
(define-category ?e "Ethiopic (Ge'ez)")
(define-category ?v "Vietnamese")
(define-category ?i "Indian")
(define-category ?o "Lao")
(define-category ?q "Tibetan")

;; For each group (row) of 2-byte character sets.

(define-category ?A "Alpha-numeric characters of 2-byte character sets")
(define-category ?C "Chinese (Han) characters of 2-byte character sets")
(define-category ?G "Greek characters of 2-byte character sets")
(define-category ?H "Japanese Hiragana characters of 2-byte character sets")
(define-category ?K "Japanese Katakana characters of 2-byte character sets")
(define-category ?N "Korean Hangul characters of 2-byte character sets")
(define-category ?Y "Cyrillic characters of 2-byte character sets")
(define-category ?I "Indian Glyphs")

;; For phonetic classifications.

(define-category ?0 "consonant")
(define-category ?1 "base (independent) vowel")
(define-category ?2 "upper diacritical mark (including upper vowel)")
(define-category ?3 "lower diacritical mark (including lower vowel)")
(define-category ?4 "tone mark")
(define-category ?5 "symbol")
(define-category ?6 "digit")
(define-category ?7 "vowel-modifying diacritical mark")
(define-category ?8 "vowel-signs")
(define-category ?9 "semivowel lower")

;; For filling.
(define-category ?| "While filling, we can break a line at this character.")

;; For indentation calculation.
(define-category ? 
  "This character counts as a space for indentation purposes.")

;; Keep the following for `kinsoku' processing.  See comments in
;; kinsoku.el.
(define-category ?> "A character which can't be placed at beginning of line.")
(define-category ?< "A character which can't be placed at end of line.")


;;; Setting syntax and category.

;; ASCII

(let ((ch 32))
  (while (< ch 127)			; All ASCII characters have
    (modify-category-entry ch ?a)	; the category `a' (ASCII)
    (modify-category-entry ch ?l)	; and `l' (Latin).
    (setq ch (1+ ch))))

;; Arabic character set

(let ((charsets '(arabic-iso8859-6
		  arabic-digit
		  arabic-1-column
		  arabic-2-column)))
  (while charsets
    (modify-syntax-entry (make-char (car charsets)) "w")
    (modify-category-entry (make-char (car charsets)) ?b)
    (setq charsets (cdr charsets))))

;; Chinese character set (GB2312)

(modify-syntax-entry (make-char 'chinese-gb2312) "w")
(modify-syntax-entry (make-char 'chinese-gb2312 33) "_")
(modify-syntax-entry (make-char 'chinese-gb2312 34) "_")
(modify-syntax-entry (make-char 'chinese-gb2312 41) "_")
(modify-syntax-entry ?\$A!2(B "($A!3(B")
(modify-syntax-entry ?\$A!4(B "($A!5(B")
(modify-syntax-entry ?\$A!6(B "($A!7(B")
(modify-syntax-entry ?\$A!8(B "($A!9(B")
(modify-syntax-entry ?\$A!:(B "($A!;(B")
(modify-syntax-entry ?\$A!<(B "($A!=(B")
(modify-syntax-entry ?\$A!>(B "($A!?(B")
(modify-syntax-entry ?\$A!3(B ")$A!2(B")
(modify-syntax-entry ?\$A!5(B ")$A!4(B")
(modify-syntax-entry ?\$A!7(B ")$A!6(B")
(modify-syntax-entry ?\$A!9(B ")$A!8(B")
(modify-syntax-entry ?\$A!;(B ")$A!:(B")
(modify-syntax-entry ?\$A!=(B ")$A!<(B")
(modify-syntax-entry ?\$A!?(B ")$A!>(B")

(modify-category-entry (make-char 'chinese-gb2312) ?c)
(modify-category-entry (make-char 'chinese-gb2312) ?\|)
(modify-category-entry (make-char 'chinese-gb2312 35) ?A)
(modify-category-entry (make-char 'chinese-gb2312 36) ?H)
(modify-category-entry (make-char 'chinese-gb2312 37) ?K)
(modify-category-entry (make-char 'chinese-gb2312 38) ?G)
(modify-category-entry (make-char 'chinese-gb2312 39) ?Y)
(modify-category-entry (make-char 'chinese-gb2312 35) ?A)
(let ((row 48))
  (while (< row 127)
    (modify-category-entry (make-char 'chinese-gb2312 row) ?C)
    (setq row (1+ row))))

;; Chinese character set (BIG5)

(let ((generic-big5-1-char (make-char 'chinese-big5-1))
      (generic-big5-2-char (make-char 'chinese-big5-2)))
  (modify-syntax-entry generic-big5-1-char "w")
  (modify-syntax-entry generic-big5-2-char "w")

  (modify-category-entry generic-big5-1-char ?c)
  (modify-category-entry generic-big5-2-char ?c)

  (modify-category-entry generic-big5-1-char ?C)
  (modify-category-entry generic-big5-2-char ?C)

  (modify-category-entry generic-big5-1-char ?\|)
  (modify-category-entry generic-big5-2-char ?\|))


;; Chinese character set (CNS11643)

(let ((cns-list '(chinese-cns11643-1
		  chinese-cns11643-2
		  chinese-cns11643-3
		  chinese-cns11643-4
		  chinese-cns11643-5
		  chinese-cns11643-6
		  chinese-cns11643-7))
      generic-char)
  (while cns-list
    (setq generic-char (make-char (car cns-list)))
    (modify-syntax-entry generic-char "w")
    (modify-category-entry generic-char ?c)
    (modify-category-entry generic-char ?C)
    (modify-category-entry generic-char ?|)
    (setq cns-list (cdr cns-list))))

;; Cyrillic character set (ISO-8859-5)

(modify-category-entry (make-char 'cyrillic-iso8859-5) ?y)

(modify-syntax-entry (make-char 'cyrillic-iso8859-5 160) " ")
(modify-syntax-entry ?,L-(B ".")
(modify-syntax-entry ?,Lp(B ".")
(modify-syntax-entry ?,L}(B ".")
(let ((tbl (standard-case-table)))
  (set-case-syntax-pair ?,L!(B ?,Lq(B tbl)
  (set-case-syntax-pair ?,L"(B ?,Lr(B tbl)
  (set-case-syntax-pair ?,L#(B ?,Ls(B tbl)
  (set-case-syntax-pair ?,L$(B ?,Lt(B tbl)
  (set-case-syntax-pair ?,L%(B ?,Lu(B tbl)
  (set-case-syntax-pair ?,L&(B ?,Lv(B tbl)
  (set-case-syntax-pair ?,L'(B ?,Lw(B tbl)
  (set-case-syntax-pair ?,L((B ?,Lx(B tbl)
  (set-case-syntax-pair ?,L)(B ?,Ly(B tbl)
  (set-case-syntax-pair ?,L*(B ?,Lz(B tbl)
  (set-case-syntax-pair ?,L+(B ?,L{(B tbl)
  (set-case-syntax-pair ?,L,(B ?,L|(B tbl)
  (set-case-syntax-pair ?,L.(B ?,L~(B tbl)
  (set-case-syntax-pair ?,L/(B ?,L(B tbl)
  (set-case-syntax-pair ?,L0(B ?,LP(B tbl)
  (set-case-syntax-pair ?,L1(B ?,LQ(B tbl)
  (set-case-syntax-pair ?,L2(B ?,LR(B tbl)
  (set-case-syntax-pair ?,L3(B ?,LS(B tbl)
  (set-case-syntax-pair ?,L4(B ?,LT(B tbl)
  (set-case-syntax-pair ?,L5(B ?,LU(B tbl)
  (set-case-syntax-pair ?,L6(B ?,LV(B tbl)
  (set-case-syntax-pair ?,L7(B ?,LW(B tbl)
  (set-case-syntax-pair ?,L8(B ?,LX(B tbl)
  (set-case-syntax-pair ?,L9(B ?,LY(B tbl)
  (set-case-syntax-pair ?,L:(B ?,LZ(B tbl)
  (set-case-syntax-pair ?,L;(B ?,L[(B tbl)
  (set-case-syntax-pair ?,L<(B ?,L\(B tbl)
  (set-case-syntax-pair ?,L=(B ?,L](B tbl)
  (set-case-syntax-pair ?,L>(B ?,L^(B tbl)
  (set-case-syntax-pair ?,L?(B ?,L_(B tbl)
  (set-case-syntax-pair ?,L@(B ?,L`(B tbl)
  (set-case-syntax-pair ?,LA(B ?,La(B tbl)
  (set-case-syntax-pair ?,LB(B ?,Lb(B tbl)
  (set-case-syntax-pair ?,LC(B ?,Lc(B tbl)
  (set-case-syntax-pair ?,LD(B ?,Ld(B tbl)
  (set-case-syntax-pair ?,LE(B ?,Le(B tbl)
  (set-case-syntax-pair ?,LF(B ?,Lf(B tbl)
  (set-case-syntax-pair ?,LG(B ?,Lg(B tbl)
  (set-case-syntax-pair ?,LH(B ?,Lh(B tbl)
  (set-case-syntax-pair ?,LI(B ?,Li(B tbl)
  (set-case-syntax-pair ?,LJ(B ?,Lj(B tbl)
  (set-case-syntax-pair ?,LK(B ?,Lk(B tbl)
  (set-case-syntax-pair ?,LL(B ?,Ll(B tbl)
  (set-case-syntax-pair ?,LM(B ?,Lm(B tbl)
  (set-case-syntax-pair ?,LN(B ?,Ln(B tbl)
  (set-case-syntax-pair ?,LO(B ?,Lo(B tbl))

;; Devanagari character set

(let ((deflist	'(;; chars	syntax	category
		  ("$(5!!!"!#(B"	"w"	?7) ; vowel-modifying diacritical mark
					    ; chandrabindu, anuswar, visarga
		  ("$(5!$(B-$(5!2(B"	"w"	?1) ; independent vowel
		  ("$(5!3(B-$(5!X(B"	"w"	?0) ; consonant
		  ("$(5!Z(B-$(5!g(B"	"w"	?8) ; matra
		  ("$(5!q(B-$(5!z(B"	"w"	?6) ; digit
		  ))
      elm chars len syntax category to ch i)
  (while deflist
    (setq elm (car deflist))
    (setq chars (car elm)
	  len (length chars)
	  syntax (nth 1 elm)
	  category (nth 2 elm)
	  i 0)
    (while (< i len)
      (if (= (aref chars i) ?-)
	  (setq i (1+ i)
		to (aref chars i))
	(setq ch (aref chars i)
	      to ch))
      (while (<= ch to)
	(modify-syntax-entry ch syntax)
	(modify-category-entry ch category)
	(setq ch (1+ ch)))
      (setq i (1+ i)))
    (setq deflist (cdr deflist))))

;; Ethiopic character set

(modify-category-entry (make-char 'ethiopic) ?e)
(modify-syntax-entry (make-char 'ethiopic) "w")
(let ((chars '(?$(3$h(B ?$(3$i(B ?$(3$j(B ?$(3$k(B ?$(3$l(B ?$(3$m(B ?$(3$n(B ?$(3$o(B ?$(3%i(B ?$(3%t(B ?$(3%u(B ?$(3%v(B ?$(3%w(B ?$(3%x(B)))
  (while chars
    (modify-syntax-entry (car chars) ".")
    (setq chars (cdr chars))))

;; European character set (Latin-1,2,3,4,5)

(modify-category-entry (make-char 'latin-iso8859-1) ?l)
(modify-category-entry (make-char 'latin-iso8859-2) ?l)
(modify-category-entry (make-char 'latin-iso8859-3) ?l)
(modify-category-entry (make-char 'latin-iso8859-4) ?l)
(modify-category-entry (make-char 'latin-iso8859-9) ?l)

(modify-category-entry (make-char 'latin-iso8859-1 160) ?\ )
(modify-category-entry (make-char 'latin-iso8859-2 160) ?\ )
(modify-category-entry (make-char 'latin-iso8859-3 160) ?\ )
(modify-category-entry (make-char 'latin-iso8859-4 160) ?\ )
(modify-category-entry (make-char 'latin-iso8859-9 160) ?\ )

;; Greek character set (ISO-8859-7)

(modify-category-entry (make-char 'greek-iso8859-7) ?g)

(let ((c 182))
  (while (< c 255)
    (modify-syntax-entry (make-char 'greek-iso8859-7 c) "w")
    (setq c (1+ c))))
(modify-syntax-entry (make-char 'greek-iso8859-7 160) "w") ; NBSP
(modify-syntax-entry ?,F7(B ".")
(modify-syntax-entry ?,F;(B ".")
(modify-syntax-entry ?,F=(B ".")

;; Hebrew character set (ISO-8859-8)

(modify-category-entry (make-char 'hebrew-iso8859-8) ?w)

(let ((c 224))
  (while (< c 251)
    (modify-syntax-entry (make-char 'hebrew-iso8859-8 c) "w")
    (setq c (1+ c))))
(modify-syntax-entry (make-char 'hebrew-iso8859-8 160) "w") ; NBSP

;; Indian character set (IS 13194 and other Emacs original Indian charsets)

(modify-category-entry (make-char 'indian-is13194) ?i)
(modify-category-entry (make-char 'indian-2-column) ?I)
(modify-category-entry (make-char 'indian-1-column) ?I)

(let ((deflist	
	'(;; chars	syntax	category
	  ("(5!"#(B"	"w"	?7) ; vowel-modifying diacritical mark
				    ; chandrabindu, anuswar, visarga
	  ("(5$(B-(52(B"	"w"	?1) ; base (independent) vowel
	  ("(53(B-(5X(B"	"w"	?0) ; consonant
	  ("(5Z(B-(5g(B"	"w"	?8) ; matra
	  ("(5q(B-(5z(B"	"w"	?6) ; digit
	  ))
      elm chars len syntax category to ch i)
  (while deflist
    (setq elm (car deflist))
    (setq chars (car elm)
	  len (length chars)
	  syntax (nth 1 elm)
	  category (nth 2 elm)
	  i 0)
    (while (< i len)
      (if (= (aref chars i) ?-)
	  (setq i (1+ i)
		to (aref chars i))
	(setq ch (aref chars i)
	      to ch))
      (while (<= ch to)
	(modify-syntax-entry ch syntax)
	(modify-category-entry ch category)
	(setq ch (1+ ch)))
      (setq i (1+ i)))
    (setq deflist (cdr deflist))))


;; Japanese character set (JISX0201-kana, JISX0201-roman, JISX0208, JISX0212)

(modify-category-entry (make-char 'katakana-jisx0201) ?k)
(modify-category-entry (make-char 'latin-jisx0201) ?r)
(modify-category-entry (make-char 'japanese-jisx0208) ?j)
(modify-category-entry (make-char 'japanese-jisx0212) ?j)
(modify-category-entry (make-char 'katakana-jisx0201) ?\|)
(modify-category-entry (make-char 'japanese-jisx0208) ?\|)
(modify-category-entry (make-char 'japanese-jisx0212) ?\|)

;; JISX0208
(modify-syntax-entry (make-char 'japanese-jisx0208) "w")
(modify-syntax-entry (make-char 'japanese-jisx0208 33) "_")
(modify-syntax-entry (make-char 'japanese-jisx0208 34) "_")
(modify-syntax-entry (make-char 'japanese-jisx0208 40) "_")
(let ((chars '(?$B!<(B ?$B!+(B ?$B!,(B ?$B!3(B ?$B!4(B ?$B!5(B ?$B!6(B ?$B!7(B ?$B!8(B ?$B!9(B ?$B!:(B ?$B!;(B)))
  (while chars
    (modify-syntax-entry (car chars) "w")
    (setq chars (cdr chars))))
(modify-syntax-entry ?\$B!J(B "($B!K(B")
(modify-syntax-entry ?\$B!N(B "($B!O(B")
(modify-syntax-entry ?\$B!P(B "($B!Q(B")
(modify-syntax-entry ?\$B!V(B "($B!W(B")
(modify-syntax-entry ?\$B!X(B "($B!Y(B")
(modify-syntax-entry ?\$B!K(B ")$B!J(B")
(modify-syntax-entry ?\$B!O(B ")$B!N(B")
(modify-syntax-entry ?\$B!Q(B ")$B!P(B")
(modify-syntax-entry ?\$B!W(B ")$B!V(B")
(modify-syntax-entry ?\$B!Y(B ")$B!X(B")

(modify-category-entry (make-char 'japanese-jisx0208 35) ?A)
(modify-category-entry (make-char 'japanese-jisx0208 36) ?H)
(modify-category-entry (make-char 'japanese-jisx0208 37) ?K)
(modify-category-entry (make-char 'japanese-jisx0208 38) ?G)
(modify-category-entry (make-char 'japanese-jisx0208 39) ?Y)
(let ((row 48))
  (while (< row 127)
    (modify-category-entry (make-char 'japanese-jisx0208 row) ?C)
    (setq row (1+ row))))
(modify-category-entry ?$B!<(B ?K)
(let ((chars '(?$B!+(B ?$B!,(B)))
  (while chars
    (modify-category-entry (car chars) ?K)
    (modify-category-entry (car chars) ?H)
    (setq chars (cdr chars))))
(let ((chars '(?$B!3(B ?$B!4(B ?$B!5(B ?$B!6(B ?$B!7(B ?$B!8(B ?$B!9(B ?$B!:(B ?$B!;(B)))
  (while chars
    (modify-category-entry (car chars) ?C)
    (setq chars (cdr chars))))

;; JISX0212
(modify-syntax-entry (make-char 'japanese-jisx0212) "w")
(modify-syntax-entry (make-char 'japanese-jisx0212 33) "_")
(modify-syntax-entry (make-char 'japanese-jisx0212 34) "_")
(modify-syntax-entry (make-char 'japanese-jisx0212 35) "_")

(modify-category-entry (make-char 'japanese-jisx0212 ) ?C)

;; JISX0201-Kana
(modify-syntax-entry (make-char 'katakana-jisx0201) "w")
(let ((chars '(?(I!(B ?(I"(B ?(I#(B ?(I$(B ?(I%(B)))
  (while chars
    (modify-syntax-entry (car chars) ".")
    (setq chars (cdr chars))))

;; Korean character set (KSC5601)

(modify-syntax-entry (make-char 'korean-ksc5601) "w")
(modify-syntax-entry (make-char 'korean-ksc5601 33) "_")
(modify-syntax-entry (make-char 'korean-ksc5601 34) "_")
(modify-syntax-entry (make-char 'korean-ksc5601 38) "_")
(modify-syntax-entry (make-char 'korean-ksc5601 39) "_")
(modify-syntax-entry (make-char 'korean-ksc5601 40) "_")
(modify-syntax-entry (make-char 'korean-ksc5601 41) "_")

(modify-category-entry (make-char 'korean-ksc5601) ?h)
(modify-category-entry (make-char 'korean-ksc5601 35) ?A)
(modify-category-entry (make-char 'korean-ksc5601 37) ?G)
(modify-category-entry (make-char 'korean-ksc5601 42) ?H)
(modify-category-entry (make-char 'korean-ksc5601 43) ?K)
(modify-category-entry (make-char 'korean-ksc5601 44) ?Y)

;; Lao character set

(modify-category-entry (make-char 'lao) ?o)

(let ((deflist	'(;; chars	syntax	category
		  ("(1!(B-(1N(B"	"w"	?0) ; consonant
		  ("(1PRS]`(B-(1d(B"	"w"	?1) ; vowel base
		  ("(1QT(B-(1W[m(B"	"w"	?2) ; vowel upper
		  ("(1XY(B"		"w"	?3) ; vowel lower
		  ("(1h(B-(1l(B"	"w"	?4) ; tone mark 
		  ("(1\(B"		"w"	?9) ; semivowel lower
		  ("(1p(B-(1y(B"	"w"	?6) ; digit
		  ("(1Of(B"		"_"	?0) ; symbol
		  ))
      elm chars len syntax category to ch i)
  (while deflist
    (setq elm (car deflist))
    (setq chars (car elm)
	  len (length chars)
	  syntax (nth 1 elm)
	  category (nth 2 elm)
	  i 0)
    (while (< i len)
      (if (= (aref chars i) ?-)
	  (setq i (1+ i)
		to (aref chars i))
	(setq ch (aref chars i)
	      to ch))
      (while (<= ch to)
	(modify-syntax-entry ch syntax)
	(modify-category-entry ch category)
	(setq ch (1+ ch)))
      (setq i (1+ i)))
    (setq deflist (cdr deflist))))

;; Thai character set (TIS620)

(modify-category-entry (make-char 'thai-tis620) ?t)

(let ((deflist	'(;; chars	syntax	category
		  (",T!(B-,TCEG(B-,TN(B"	"w"	?0) ; consonant
		  (",TDFPRS`(B-,Te(B"	"w"	?1) ; vowel base
		  (",TQT(B-,TWgn(B"	"w"	?2) ; vowel upper
		  (",TX(B-,TZ(B"	"w"	?3) ; vowel lower
		  (",Th(B-,Tm(B"	"w"	?4) ; tone mark 
		  (",Tp(B-,Ty(B"	"w"	?6) ; digit
		  (",TOf_oz{(B"	"_"	?5) ; symbol
		  ))
      elm chars len syntax category to ch i)
  (while deflist
    (setq elm (car deflist))
    (setq chars (car elm)
	  len (length chars)
	  syntax (nth 1 elm)
	  category (nth 2 elm)
	  i 0)
    (while (< i len)
      (if (= (aref chars i) ?-)
	  (setq i (1+ i)
		to (aref chars i))
	(setq ch (aref chars i)
	      to ch))
      (while (<= ch to)
	(modify-syntax-entry ch syntax)
	(modify-category-entry ch category)
	(setq ch (1+ ch)))
      (setq i (1+ i)))
    (setq deflist (cdr deflist))))

;; Tibetan character set

(modify-category-entry (make-char 'tibetan) ?q)
(modify-category-entry (make-char 'tibetan-1-column) ?q)

(let ((deflist	'(;; chars             syntax category
		  ("$(7"!(B-$(7"J(B"        	"w"	?0) ; consonant
		  ("$(7#!(B-$(7#J#P#Q(B"          "w"     ?0) ;
		  ("$(7$!(B-$(7$e(B"              "w"     ?0) ;
		  ("$(7%!(B-$(7%u(B"              "w"     ?0) ;
		  ("$(7"S"["\"]"^"a(B"       "w"	?2) ; upper vowel
		  ("$(7"_"c"d"g"h"i"j"k"l(B" "w"	?2) ; upper modifier
		  ("$(7!I"Q"U"e!e!g(B"       "w"	?3) ; lowel vowel/modifier
		  ("$(7!P(B-$(7!Y!Z(B-$(7!c(B"	        "w"	?6) ; digit
		  ("$(7!;!=(B-$(7!B!D"`(B"        "."     ?|) ; line-break char
		  ("$(8!;!=!?!@!A!D"`(B"            "."     ?|) ;
		  ("$(7!8!;!=(B-$(7!B!D"`!m!d(B"  "."     ?>) ; prohibition
		  ("$(8!;!=!?!@!A!D"`(B"            "."     ?>) ;
		  ("$(7!0(B-$(7!:!l#R#S"f(B"      "."     ?<) ; prohibition
		  ("$(7!C!E(B-$(7!H!J(B-$(7!O!f!h(B-$(7!k!n!o(B" "." ?q) ; others
		  ))
      elm chars len syntax category to ch i)
  (while deflist
    (setq elm (car deflist))
    (setq chars (car elm)
	  len (length chars)
	  syntax (nth 1 elm)
	  category (nth 2 elm)
	  i 0)
    (while (< i len)
      (if (= (aref chars i) ?-)
	  (setq i (1+ i)
		to (aref chars i))
	(setq ch (aref chars i)
	      to ch))
      (while (<= ch to)
	(modify-syntax-entry ch syntax)
	(modify-category-entry ch category)
	(setq ch (1+ ch)))
      (setq i (1+ i)))
    (setq deflist (cdr deflist))))

;; Vietnamese character set

(let ((lower (make-char 'vietnamese-viscii-lower))
      (upper (make-char 'vietnamese-viscii-upper)))
  (modify-syntax-entry lower "w")
  (modify-syntax-entry upper "w")
  (modify-category-entry lower ?v)
  (modify-category-entry upper ?v)
  (modify-category-entry lower ?l)	; To make a word with
  (modify-category-entry upper ?l)	; latin characters.
  )


;;; Setting word boundary.

(setq word-combining-categories
      '((?l . ?l)))

(setq word-separating-categories	;  (2-byte character sets)
      '((?A . ?K)			; Alpha numeric - Katakana
	(?A . ?C)			; Alpha numeric - Chinese
	(?H . ?A)			; Hiragana - Alpha numeric
	(?H . ?K)			; Hiragana - Katakana
	(?H . ?C)			; Hiragana - Chinese
	(?K . ?A)			; Katakana - Alpha numeric
	(?K . ?C)			; Katakana - Chinese
	(?C . ?A)			; Chinese - Alpha numeric
	(?C . ?K)			; Chinese - Katakana
	))


;; For each character set, put the information of the most proper
;; coding system to encode it by `preferred-coding-system' property.

(let ((l '((latin-iso8859-1	. iso-latin-1)
	   (latin-iso8859-2	. iso-latin-2)
	   (latin-iso8859-3	. iso-latin-3)
	   (latin-iso8859-4	. iso-latin-4)
	   (thai-tis620		. thai-tis620)
	   (greek-iso8859-7	. greek-iso-8bit)
	   (arabic-iso8859-6	. iso-2022-7bit)
	   (hebrew-iso8859-8	. hebrew-iso-8bit)
	   (katakana-jisx0201	. japanese-shift-jis)
	   (latin-jisx0201	. japanese-shift-jis)
	   (cyrillic-iso8859-5	. cyrillic-iso-8bit)
	   (latin-iso8859-9	. iso-latin-5)
	   (japanese-jisx0208-1978 . iso-2022-jp)
	   (chinese-gb2312	. cn-gb-2312)
	   (japanese-jisx0208	. iso-2022-jp)
	   (korean-ksc5601	. iso-2022-kr)
	   (japanese-jisx0212	. iso-2022-jp)
	   (chinese-cns11643-1	. iso-2022-cn)
	   (chinese-cns11643-2	. iso-2022-cn)
	   (chinese-big5-1	. chinese-big5)
	   (chinese-big5-2	. chinese-big5)
	   (chinese-sisheng	. iso-2022-7bit)
	   (ipa			. iso-2022-7bit)
	   (vietnamese-viscii-lower . vietnamese-viscii)
	   (vietnamese-viscii-upper . vietnamese-viscii)
	   (arabic-digit	. iso-2022-7bit)
	   (arabic-1-column	. iso-2022-7bit)
	   (ascii-right-to-left	. iso-2022-7bit)
	   (lao			. lao)
	   (arabic-2-column	. iso-2022-7bit)
	   (indian-is13194	. devanagari)
	   (indian-1-column	. devanagari)
	   (tibetan-1-column	. tibetan)
	   (ethiopic		. iso-2022-7bit)
	   (chinese-cns11643-3	. iso-2022-cn)
	   (chinese-cns11643-4	. iso-2022-cn)
	   (chinese-cns11643-5	. iso-2022-cn)
	   (chinese-cns11643-6	. iso-2022-cn)
	   (chinese-cns11643-7	. iso-2022-cn)
	   (indian-2-column	. devanagari)
	   (tibetan		. tibetan))))
  (while l
    (put-charset-property (car (car l)) 'preferred-coding-system (cdr (car l)))
    (setq l (cdr l))))


;; Setup auto-fill-chars for charsets that should invoke auto-filling.
;; SPACE and NEWLIE are already set.  Also put `nospace-between-words'
;; property to the charsets.
(let ((l '(katakana-jisx0201
	   japanese-jisx0208 japanese-jisx0212
	   chinese-gb2312 chinese-big5-1 chinese-big5-2)))
  (while l
    (aset auto-fill-chars (make-char (car l)) t)
    (put-charset-property (car l) 'nospace-between-words t)
    (setq l (cdr l))))

;;; Local Variables:
;;; coding: iso-2022-7bit
;;; End:

;;; end of characters.el
