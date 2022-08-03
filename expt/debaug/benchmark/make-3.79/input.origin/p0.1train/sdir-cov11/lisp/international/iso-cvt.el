;;; iso-cvt.-el -- translate ISO 8859-1 from/to various encodings
;; This file was formerly called gm-lingo.el.

;; Copyright (C) 1993, 1994, 1995, 1996, 1998 Free Software Foundation, Inc.

;; Author: Michael Gschwind <mike@vlsivie.tuwien.ac.at>
;; Keywords: tex, iso, latin, i18n

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
;; This lisp code is a general framework for translating various
;; representations of the same data.
;; among other things it can be used to translate TeX, HTML, and compressed
;; files to ISO 8859-1.  It can also be used to translate different charsets
;; such as IBM PC, Macintosh or HP Roman8.
;; Note that many translations use the GNU recode tool to do the actual
;; conversion.  So you might want to install that tool to get the full
;; benefit of iso-cvt.el
;

; TO DO:
; Cover more cases for translation (There is an infinite number of ways to
; represent accented characters in TeX)

;; SEE ALSO:
; If you are interested in questions related to using the ISO 8859-1
; characters set (configuring emacs, Unix, etc. to use ISO), then you
; can get the ISO 8859-1 FAQ via anonymous ftp from
; ftp.vlsivie.tuwien.ac.at in /pub/bit/FAQ-ISO-8859-1

;;; Code:

(provide 'iso-cvt)
(require 'format)

(defvar iso-spanish-trans-tab
  '(
    ("~n" "�")
    ("\([a-zA-Z]\)#" "\\1�")
    ("~N" "�")
    ("\\([-a-zA-Z\"`]\\)\"u" "\\1�")
    ("\\([-a-zA-Z\"`]\\)\"U" "\\1�")
    ("\\([-a-zA-Z]\\)'o" "\\1�")
    ("\\([-a-zA-Z]\\)'O" "\\�")
    ("\\([-a-zA-Z]\\)'e" "\\1�")
    ("\\([-a-zA-Z]\\)'E" "\\1�")
    ("\\([-a-zA-Z]\\)'a" "\\1�")
    ("\\([-a-zA-Z]\\)'A" "\\1A")
    ("\\([-a-zA-Z]\\)'i" "\\1�")
    ("\\([-a-zA-Z]\\)'I" "\\1�")
    )
  "Spanish translation table.")

(defun iso-translate-conventions (from to trans-tab)
  "Use the translation table TRANS-TAB to translate the current buffer."
  (save-excursion
    (save-restriction
      (narrow-to-region from to)
      (goto-char from)
      (let ((work-tab trans-tab)
	    (buffer-read-only nil)
	    (case-fold-search nil))
	(while work-tab
	  (save-excursion
	    (let ((trans-this (car work-tab)))
	      (while (re-search-forward (car trans-this) nil t)
		(replace-match (car (cdr trans-this)) t nil)))
	    (setq work-tab (cdr work-tab)))))
      (point-max))))

;;;###autoload
(defun iso-spanish (from to &optional buffer)
  "Translate net conventions for Spanish to ISO 8859-1.
The region between FROM and TO is translated using the table TRANS-TAB.
Optional arg BUFFER is ignored (so that the function can can be used in
`format-alist')."
  (interactive "*r")
  (iso-translate-conventions from to iso-spanish-trans-tab))

(defvar iso-aggressive-german-trans-tab
  '(
    ("\"a" "�")
    ("\"A" "�")
    ("\"o" "�")
    ("\"O" "�")
    ("\"u" "�")
    ("\"U" "�")
    ("\"s" "�")
    ("\\\\3" "�")
    )
  "German translation table.
This table uses an aggressive translation approach and may erroneously
translate too much.")

(defvar iso-conservative-german-trans-tab
  '(
    ("\\([-a-zA-Z\"`]\\)\"a" "\\1�")
    ("\\([-a-zA-Z\"`]\\)\"A" "\\1�")
    ("\\([-a-zA-Z\"`]\\)\"o" "\\1�")
    ("\\([-a-zA-Z\"`]\\)\"O" "\\1�")
    ("\\([-a-zA-Z\"`]\\)\"u" "\\1�")
    ("\\([-a-zA-Z\"`]\\)\"U" "\\1�")
    ("\\([-a-zA-Z\"`]\\)\"s" "\\1�")
    ("\\([-a-zA-Z\"`]\\)\\\\3" "\\1�")
    )
  "German translation table.
This table uses a conservative translation approach and may translate too
little.")

(defvar iso-german-trans-tab iso-aggressive-german-trans-tab
  "Currently active translation table for German.")

;;;###autoload
(defun iso-german (from to &optional buffer)
 "Translate net conventions for German to ISO 8859-1.
The region between FROM and TO is translated using the table TRANS-TAB.
Optional arg BUFFER is ignored (so that the function can can be used in
`format-alist')."
 (interactive "*r")
 (iso-translate-conventions from to iso-german-trans-tab))
 
(defvar iso-iso2tex-trans-tab
  '(
    ("�" "{\\\\\"a}")
    ("�" "{\\\\`a}")
    ("�" "{\\\\'a}")
    ("�" "{\\\\~a}")
    ("�" "{\\\\^a}")
    ("�" "{\\\\\"e}")
    ("�" "{\\\\`e}")
    ("�" "{\\\\'e}")
    ("�" "{\\\\^e}")
    ("�" "{\\\\\"\\\\i}")
    ("�" "{\\\\`\\\\i}")
    ("�" "{\\\\'\\\\i}")
    ("�" "{\\\\^\\\\i}")
    ("�" "{\\\\\"o}")
    ("�" "{\\\\`o}")
    ("�" "{\\\\'o}")
    ("�" "{\\\\~o}")
    ("�" "{\\\\^o}")
    ("�" "{\\\\\"u}")
    ("�" "{\\\\`u}")
    ("�" "{\\\\'u}")
    ("�" "{\\\\^u}")
    ("�" "{\\\\\"A}")
    ("�" "{\\\\`A}")
    ("�" "{\\\\'A}")
    ("�" "{\\\\~A}")
    ("�" "{\\\\^A}")
    ("�" "{\\\\\"E}")
    ("�" "{\\\\`E}")
    ("�" "{\\\\'E}")
    ("�" "{\\\\^E}")
    ("�" "{\\\\\"I}")
    ("�" "{\\\\`I}")
    ("�" "{\\\\'I}")
    ("�" "{\\\\^I}")
    ("�" "{\\\\\"O}")
    ("�" "{\\\\`O}")
    ("�" "{\\\\'O}")
    ("�" "{\\\\~O}")
    ("�" "{\\\\^O}")
    ("�" "{\\\\\"U}")
    ("�" "{\\\\`U}")
    ("�" "{\\\\'U}")
    ("�" "{\\\\^U}")
    ("�" "{\\\\~n}")
    ("�" "{\\\\~N}")
    ("�" "{\\\\c c}")
    ("�" "{\\\\c C}")
    ("�" "{\\\\ss}")
    ("\306" "{\\\\AE}")
    ("\346" "{\\\\ae}")
    ("\305" "{\\\\AA}")
    ("\345" "{\\\\aa}")
    ("\251" "{\\\\copyright}")
    ("�" "{\\\\pounds}")
    ("�" "{\\\\P}")
    ("�" "{\\\\S}")
    ("�" "{?`}")
    ("�" "{!`}")
    )
  "Translation table for translating ISO 8859-1 characters to TeX sequences.")

;;;###autoload
(defun iso-iso2tex (from to &optional buffer)
 "Translate ISO 8859-1 characters to TeX sequences.
The region between FROM and TO is translated using the table TRANS-TAB.
Optional arg BUFFER is ignored (so that the function can can be used in
`format-alist')."
 (interactive "*r")
 (iso-translate-conventions from to iso-iso2tex-trans-tab))

(defvar iso-tex2iso-trans-tab
  '(
    ("{\\\\\"a}" "�")
    ("{\\\\`a}" "�")
    ("{\\\\'a}" "�")
    ("{\\\\~a}" "�")
    ("{\\\\^a}" "�")
    ("{\\\\\"e}" "�")
    ("{\\\\`e}" "�")
    ("{\\\\'e}" "�")
    ("{\\\\^e}" "�")
    ("{\\\\\"\\\\i}" "�")
    ("{\\\\`\\\\i}" "�")
    ("{\\\\'\\\\i}" "�")
    ("{\\\\^\\\\i}" "�")
    ("{\\\\\"i}" "�")
    ("{\\\\`i}" "�")
    ("{\\\\'i}" "�")
    ("{\\\\^i}" "�")
    ("{\\\\\"o}" "�")
    ("{\\\\`o}" "�")
    ("{\\\\'o}" "�")
    ("{\\\\~o}" "�")
    ("{\\\\^o}" "�")
    ("{\\\\\"u}" "�")
    ("{\\\\`u}" "�")
    ("{\\\\'u}" "�")
    ("{\\\\^u}" "�")
    ("{\\\\\"A}" "�")
    ("{\\\\`A}" "�")
    ("{\\\\'A}" "�")
    ("{\\\\~A}" "�")
    ("{\\\\^A}" "�")
    ("{\\\\\"E}" "�")
    ("{\\\\`E}" "�")
    ("{\\\\'E}" "�")
    ("{\\\\^E}" "�")
    ("{\\\\\"I}" "�")
    ("{\\\\`I}" "�")
    ("{\\\\'I}" "�")
    ("{\\\\^I}" "�")
    ("{\\\\\"O}" "�")
    ("{\\\\`O}" "�")
    ("{\\\\'O}" "�")
    ("{\\\\~O}" "�")
    ("{\\\\^O}" "�")
    ("{\\\\\"U}" "�")
    ("{\\\\`U}" "�")
    ("{\\\\'U}" "�")
    ("{\\\\^U}" "�")
    ("{\\\\~n}" "�")
    ("{\\\\~N}" "�")
    ("{\\\\c c}" "�")
    ("{\\\\c C}" "�")
    ("\\\\\"a" "�")
    ("\\\\`a" "�")
    ("\\\\'a" "�")
    ("\\\\~a" "�")
    ("\\\\^a" "�")
    ("\\\\\"e" "�")
    ("\\\\`e" "�")
    ("\\\\'e" "�")
    ("\\\\^e" "�")
    ("\\\\\"\\\\i" "�")
    ("\\\\`\\\\i" "�")
    ("\\\\'\\\\i" "�")
    ("\\\\^\\\\i" "�")
    ("\\\\\"i" "�")
    ("\\\\`i" "�")
    ("\\\\'i" "�")
    ("\\\\^i" "�")
    ("\\\\\"o" "�")
    ("\\\\`o" "�")
    ("\\\\'o" "�")
    ("\\\\~o" "�")
    ("\\\\^o" "�")
    ("\\\\\"u" "�")
    ("\\\\`u" "�")
    ("\\\\'u" "�")
    ("\\\\^u" "�")
    ("\\\\\"A" "�")
    ("\\\\`A" "�")
    ("\\\\'A" "�")
    ("\\\\~A" "�")
    ("\\\\^A" "�")
    ("\\\\\"E" "�")
    ("\\\\`E" "�")
    ("\\\\'E" "�")
    ("\\\\^E" "�")
    ("\\\\\"I" "�")
    ("\\\\`I" "�")
    ("\\\\'I" "�")
    ("\\\\^I" "�")
    ("\\\\\"O" "�")
    ("\\\\`O" "�")
    ("\\\\'O" "�")
    ("\\\\~O" "�")
    ("\\\\^O" "�")
    ("\\\\\"U" "�")
    ("\\\\`U" "�")
    ("\\\\'U" "�")
    ("\\\\^U" "�")
    ("\\\\~n" "�")
    ("\\\\~N" "�")
    ("\\\\\"{a}" "�")
    ("\\\\`{a}" "�")
    ("\\\\'{a}" "�")
    ("\\\\~{a}" "�")
    ("\\\\^{a}" "�")
    ("\\\\\"{e}" "�")
    ("\\\\`{e}" "�")
    ("\\\\'{e}" "�")
    ("\\\\^{e}" "�")
    ("\\\\\"{\\\\i}" "�")
    ("\\\\`{\\\\i}" "�")
    ("\\\\'{\\\\i}" "�")
    ("\\\\^{\\\\i}" "�")
    ("\\\\\"{i}" "�")
    ("\\\\`{i}" "�")
    ("\\\\'{i}" "�")
    ("\\\\^{i}" "�")
    ("\\\\\"{o}" "�")
    ("\\\\`{o}" "�")
    ("\\\\'{o}" "�")
    ("\\\\~{o}" "�")
    ("\\\\^{o}" "�")
    ("\\\\\"{u}" "�")
    ("\\\\`{u}" "�")
    ("\\\\'{u}" "�")
    ("\\\\^{u}" "�")
    ("\\\\\"{A}" "�")
    ("\\\\`{A}" "�")
    ("\\\\'{A}" "�")
    ("\\\\~{A}" "�")
    ("\\\\^{A}" "�")
    ("\\\\\"{E}" "�")
    ("\\\\`{E}" "�")
    ("\\\\'{E}" "�")
    ("\\\\^{E}" "�")
    ("\\\\\"{I}" "�")
    ("\\\\`{I}" "�")
    ("\\\\'{I}" "�")
    ("\\\\^{I}" "�")
    ("\\\\\"{O}" "�")
    ("\\\\`{O}" "�")
    ("\\\\'{O}" "�")
    ("\\\\~{O}" "�")
    ("\\\\^{O}" "�")
    ("\\\\\"{U}" "�")
    ("\\\\`{U}" "�")
    ("\\\\'{U}" "�")
    ("\\\\^{U}" "�")
    ("\\\\~{n}" "�")
    ("\\\\~{N}" "�")
    ("\\\\c{c}" "�")
    ("\\\\c{C}" "�")
    ("{\\\\ss}" "�")
    ("{\\\\AE}" "\306")
    ("{\\\\ae}" "\346")
    ("{\\\\AA}" "\305")
    ("{\\\\aa}" "\345")
    ("{\\\\copyright}" "\251")
    ("\\\\copyright{}" "\251")
    ("{\\\\pounds}" "�" )
    ("{\\\\P}" "�" )
    ("{\\\\S}" "�" )
    ("\\\\pounds{}" "�" )
    ("\\\\P{}" "�" )
    ("\\\\S{}" "�" )
    ("{\\?`}" "�")
    ("{!`}" "�")
    ("\\?`" "�")
    ("!`" "�")
    )
  "Translation table for translating TeX sequences to ISO 8859-1 characters.
This table is not exhaustive (and due to TeX's power can never be).  It only
contains commonly used sequences.")

;;;###autoload
(defun iso-tex2iso (from to &optional buffer)
 "Translate TeX sequences to ISO 8859-1 characters.
The region between FROM and TO is translated using the table TRANS-TAB.
Optional arg BUFFER is ignored (so that the function can can be used in
`format-alist')."
 (interactive "*r")
 (iso-translate-conventions from to iso-tex2iso-trans-tab))

(defvar iso-gtex2iso-trans-tab
  '(
    ("{\\\\\"a}" "�")
    ("{\\\\`a}" "�")
    ("{\\\\'a}" "�")
    ("{\\\\~a}" "�")
    ("{\\\\^a}" "�")
    ("{\\\\\"e}" "�")
    ("{\\\\`e}" "�")
    ("{\\\\'e}" "�")
    ("{\\\\^e}" "�")
    ("{\\\\\"\\\\i}" "�")
    ("{\\\\`\\\\i}" "�")
    ("{\\\\'\\\\i}" "�")
    ("{\\\\^\\\\i}" "�")
    ("{\\\\\"i}" "�")
    ("{\\\\`i}" "�")
    ("{\\\\'i}" "�")
    ("{\\\\^i}" "�")
    ("{\\\\\"o}" "�")
    ("{\\\\`o}" "�")
    ("{\\\\'o}" "�")
    ("{\\\\~o}" "�")
    ("{\\\\^o}" "�")
    ("{\\\\\"u}" "�")
    ("{\\\\`u}" "�")
    ("{\\\\'u}" "�")
    ("{\\\\^u}" "�")
    ("{\\\\\"A}" "�")
    ("{\\\\`A}" "�")
    ("{\\\\'A}" "�")
    ("{\\\\~A}" "�")
    ("{\\\\^A}" "�")
    ("{\\\\\"E}" "�")
    ("{\\\\`E}" "�")
    ("{\\\\'E}" "�")
    ("{\\\\^E}" "�")
    ("{\\\\\"I}" "�")
    ("{\\\\`I}" "�")
    ("{\\\\'I}" "�")
    ("{\\\\^I}" "�")
    ("{\\\\\"O}" "�")
    ("{\\\\`O}" "�")
    ("{\\\\'O}" "�")
    ("{\\\\~O}" "�")
    ("{\\\\^O}" "�")
    ("{\\\\\"U}" "�")
    ("{\\\\`U}" "�")
    ("{\\\\'U}" "�")
    ("{\\\\^U}" "�")
    ("{\\\\~n}" "�")
    ("{\\\\~N}" "�")
    ("{\\\\c c}" "�")
    ("{\\\\c C}" "�")
    ("\\\\\"a" "�")
    ("\\\\`a" "�")
    ("\\\\'a" "�")
    ("\\\\~a" "�")
    ("\\\\^a" "�")
    ("\\\\\"e" "�")
    ("\\\\`e" "�")
    ("\\\\'e" "�")
    ("\\\\^e" "�")
    ("\\\\\"\\\\i" "�")
    ("\\\\`\\\\i" "�")
    ("\\\\'\\\\i" "�")
    ("\\\\^\\\\i" "�")
    ("\\\\\"i" "�")
    ("\\\\`i" "�")
    ("\\\\'i" "�")
    ("\\\\^i" "�")
    ("\\\\\"o" "�")
    ("\\\\`o" "�")
    ("\\\\'o" "�")
    ("\\\\~o" "�")
    ("\\\\^o" "�")
    ("\\\\\"u" "�")
    ("\\\\`u" "�")
    ("\\\\'u" "�")
    ("\\\\^u" "�")
    ("\\\\\"A" "�")
    ("\\\\`A" "�")
    ("\\\\'A" "�")
    ("\\\\~A" "�")
    ("\\\\^A" "�")
    ("\\\\\"E" "�")
    ("\\\\`E" "�")
    ("\\\\'E" "�")
    ("\\\\^E" "�")
    ("\\\\\"I" "�")
    ("\\\\`I" "�")
    ("\\\\'I" "�")
    ("\\\\^I" "�")
    ("\\\\\"O" "�")
    ("\\\\`O" "�")
    ("\\\\'O" "�")
    ("\\\\~O" "�")
    ("\\\\^O" "�")
    ("\\\\\"U" "�")
    ("\\\\`U" "�")
    ("\\\\'U" "�")
    ("\\\\^U" "�")
    ("\\\\~n" "�")
    ("\\\\~N" "�")
    ("\\\\\"{a}" "�")
    ("\\\\`{a}" "�")
    ("\\\\'{a}" "�")
    ("\\\\~{a}" "�")
    ("\\\\^{a}" "�")
    ("\\\\\"{e}" "�")
    ("\\\\`{e}" "�")
    ("\\\\'{e}" "�")
    ("\\\\^{e}" "�")
    ("\\\\\"{\\\\i}" "�")
    ("\\\\`{\\\\i}" "�")
    ("\\\\'{\\\\i}" "�")
    ("\\\\^{\\\\i}" "�")
    ("\\\\\"{i}" "�")
    ("\\\\`{i}" "�")
    ("\\\\'{i}" "�")
    ("\\\\^{i}" "�")
    ("\\\\\"{o}" "�")
    ("\\\\`{o}" "�")
    ("\\\\'{o}" "�")
    ("\\\\~{o}" "�")
    ("\\\\^{o}" "�")
    ("\\\\\"{u}" "�")
    ("\\\\`{u}" "�")
    ("\\\\'{u}" "�")
    ("\\\\^{u}" "�")
    ("\\\\\"{A}" "�")
    ("\\\\`{A}" "�")
    ("\\\\'{A}" "�")
    ("\\\\~{A}" "�")
    ("\\\\^{A}" "�")
    ("\\\\\"{E}" "�")
    ("\\\\`{E}" "�")
    ("\\\\'{E}" "�")
    ("\\\\^{E}" "�")
    ("\\\\\"{I}" "�")
    ("\\\\`{I}" "�")
    ("\\\\'{I}" "�")
    ("\\\\^{I}" "�")
    ("\\\\\"{O}" "�")
    ("\\\\`{O}" "�")
    ("\\\\'{O}" "�")
    ("\\\\~{O}" "�")
    ("\\\\^{O}" "�")
    ("\\\\\"{U}" "�")
    ("\\\\`{U}" "�")
    ("\\\\'{U}" "�")
    ("\\\\^{U}" "�")
    ("\\\\~{n}" "�")
    ("\\\\~{N}" "�")
    ("\\\\c{c}" "�")
    ("\\\\c{C}" "�")
    ("{\\\\ss}" "�")
    ("{\\\\AE}" "\306")
    ("{\\\\ae}" "\346")
    ("{\\\\AA}" "\305")
    ("{\\\\aa}" "\345")
    ("{\\\\copyright}" "\251")
    ("\\\\copyright{}" "\251")
    ("{\\\\pounds}" "�" )
    ("{\\\\P}" "�" )
    ("{\\\\S}" "�" )
    ("\\\\pounds{}" "�" )
    ("\\\\P{}" "�" )
    ("\\\\S{}" "�" )
    ("?`" "�")
    ("!`" "�")
    ("{?`}" "�")
    ("{!`}" "�")
    ("\"a" "�")
    ("\"A" "�")
    ("\"o" "�")
    ("\"O" "�")
    ("\"u" "�")
    ("\"U" "�")
    ("\"s" "�")
    ("\\\\3" "�")
    )
  "Translation table for translating German TeX sequences to ISO 8859-1.
This table is not exhaustive (and due to TeX's power can never be).  It only
contains commonly used sequences.")

(defvar iso-iso2gtex-trans-tab
  '(
    ("�" "\"a")
    ("�" "{\\\\`a}")
    ("�" "{\\\\'a}")
    ("�" "{\\\\~a}")
    ("�" "{\\\\^a}")
    ("�" "{\\\\\"e}")
    ("�" "{\\\\`e}")
    ("�" "{\\\\'e}")
    ("�" "{\\\\^e}")
    ("�" "{\\\\\"\\\\i}")
    ("�" "{\\\\`\\\\i}")
    ("�" "{\\\\'\\\\i}")
    ("�" "{\\\\^\\\\i}")
    ("�" "\"o")
    ("�" "{\\\\`o}")
    ("�" "{\\\\'o}")
    ("�" "{\\\\~o}")
    ("�" "{\\\\^o}")
    ("�" "\"u")
    ("�" "{\\\\`u}")
    ("�" "{\\\\'u}")
    ("�" "{\\\\^u}")
    ("�" "\"A")
    ("�" "{\\\\`A}")
    ("�" "{\\\\'A}")
    ("�" "{\\\\~A}")
    ("�" "{\\\\^A}")
    ("�" "{\\\\\"E}")
    ("�" "{\\\\`E}")
    ("�" "{\\\\'E}")
    ("�" "{\\\\^E}")
    ("�" "{\\\\\"I}")
    ("�" "{\\\\`I}")
    ("�" "{\\\\'I}")
    ("�" "{\\\\^I}")
    ("�" "\"O")
    ("�" "{\\\\`O}")
    ("�" "{\\\\'O}")
    ("�" "{\\\\~O}")
    ("�" "{\\\\^O}")
    ("�" "\"U")
    ("�" "{\\\\`U}")
    ("�" "{\\\\'U}")
    ("�" "{\\\\^U}")
    ("�" "{\\\\~n}")
    ("�" "{\\\\~N}")
    ("�" "{\\\\c c}")
    ("�" "{\\\\c C}")
    ("�" "\"s")
    ("\306" "{\\\\AE}")
    ("\346" "{\\\\ae}")
    ("\305" "{\\\\AA}")
    ("\345" "{\\\\aa}")
    ("\251" "{\\\\copyright}")
    ("�" "{\\\\pounds}")
    ("�" "{\\\\P}")
    ("�" "{\\\\S}")
    ("�" "{?`}")
    ("�" "{!`}")
    )
  "Translation table for translating ISO 8859-1 characters to German TeX.")

;;;###autoload
(defun iso-gtex2iso (from to &optional buffer)
 "Translate German TeX sequences to ISO 8859-1 characters.
The region between FROM and TO is translated using the table TRANS-TAB.
Optional arg BUFFER is ignored (so that the function can can be used in
`format-alist')."
 (interactive "*r")
 (iso-translate-conventions from to iso-gtex2iso-trans-tab))

;;;###autoload
(defun iso-iso2gtex (from to &optional buffer)
 "Translate ISO 8859-1 characters to German TeX sequences.
The region between FROM and TO is translated using the table TRANS-TAB.
Optional arg BUFFER is ignored (so that the function can can be used in
`format-alist')."
 (interactive "*r")
 (iso-translate-conventions from to iso-iso2gtex-trans-tab))

(defvar iso-iso2duden-trans-tab
  '(("�" "ae")
    ("�" "Ae")
    ("�" "oe")
    ("�" "Oe")
    ("�" "ue")
    ("�" "Ue")
    ("�" "ss")))

;;;###autoload
(defun iso-iso2duden (from to &optional buffer)
 "Translate ISO 8859-1 characters to German TeX sequences.
The region between FROM and TO is translated using the table TRANS-TAB.
Optional arg BUFFER is ignored (so that the function can can be used in
`format-alist')."
 (interactive "*r")
 (iso-translate-conventions from to iso-iso2duden-trans-tab))

;;;###autoload
(defun iso-cvt-read-only ()
  "Warn that format is read-only."
  (interactive)
  (error "This format is read-only; specify another format for writing"))

;;;###autoload
(defun iso-cvt-write-only ()
  "Warn that format is write-only."
  (interactive)
  (error "This format is write-only"))
			 
;;;###autoload
(defun iso-cvt-define-menu ()
  "Add submenus to the Files menu, to convert to and from various formats."
  (interactive)

  (define-key menu-bar-files-menu [load-as-separator] '("--"))

  (define-key menu-bar-files-menu [load-as] '("Load As..."  . load-as))
  (defvar load-as-menu-map (make-sparse-keymap "Load As..."))
  (fset 'load-as load-as-menu-map)

  ;;(define-key menu-bar-files-menu [insert-as] '("Insert As..."  . insert-as))
  (defvar insert-as-menu-map (make-sparse-keymap "Insert As..."))
  (fset 'insert-as insert-as-menu-map)

  (define-key menu-bar-files-menu [write-as] '("Write As..."  . write-as))
  (defvar write-as-menu-map (make-sparse-keymap "Write As..."))
  (fset 'write-as write-as-menu-map)

  (define-key menu-bar-files-menu [translate-separator] '("--"))

  (define-key menu-bar-files-menu [translate-to] '("Translate to..."  . translate-to))
  (defvar translate-to-menu-map (make-sparse-keymap "Translate to..."))
  (fset 'translate-to translate-to-menu-map)

  (define-key menu-bar-files-menu [translate-from] '("Translate from..."  . translate-from))
  (defvar translate-from-menu-map (make-sparse-keymap "Translate from..."))
  (fset 'translate-from translate-from-menu-map)

  (let ((file-types (reverse format-alist))
	name
	str-name)
    (while file-types
      (setq name (car (car file-types))
	    str-name (car (cdr (car file-types)))
	    file-types (cdr file-types))
      (if (stringp str-name)
	  (progn
	    (define-key load-as-menu-map (vector name)
	      (cons str-name
		    (list 'lambda '(file) (list 'interactive (format "FFind file (as %s): " name))
			  (list 'format-find-file 'file (list 'quote name)))))
	    (define-key insert-as-menu-map (vector name)
	      (cons str-name
		    (list 'lambda '(file) (list 'interactive (format "FInsert file (as %s): " name))
			  (list 'format-insert-file 'file (list 'quote name)))))
	    (define-key write-as-menu-map (vector name)
	      (cons str-name
		    (list 'lambda '(file) (list 'interactive (format "FWrite file (as %s): " name))
			  (list 'format-write-file 'file (list 'quote (list name))))))
	    (define-key translate-to-menu-map (vector name)
	      (cons str-name
		    (list 'lambda '() '(interactive)
			  (list 'format-encode-buffer (list 'quote name)))))
	    (define-key translate-from-menu-map (vector name)
	      (cons str-name
		    (list 'lambda '() '(interactive)
			  (list 'format-decode-buffer (list 'quote (list name))))))
	    )))))

;;; iso-cvt.el ends here
