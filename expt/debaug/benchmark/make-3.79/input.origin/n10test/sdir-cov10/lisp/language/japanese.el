;;; japanese.el --- Japanese support -*- coding: iso-2022-7bit; -*-

;; Copyright (C) 1995 Electrotechnical Laboratory, JAPAN.
;; Licensed to the Free Software Foundation.

;; Keywords: multilingual, Japanese

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

;; For Japanese, character sets JISX0201, JISX0208, JISX0212 are
;; supported.

;;; Code:

(make-coding-system
 'iso-2022-jp 2 ?J
 "ISO 2022 based 7bit encoding for Japanese (MIME:ISO-2022-JP)"
 '((ascii japanese-jisx0208-1978 japanese-jisx0208
	  latin-jisx0201 japanese-jisx0212 katakana-jisx0201) nil nil nil
   short ascii-eol ascii-cntl seven)
 '((safe-charsets ascii japanese-jisx0208-1978 japanese-jisx0208
		  latin-jisx0201 japanese-jisx0212 katakana-jisx0201)
   (mime-charset . iso-2022-jp)))

(define-coding-system-alias 'junet 'iso-2022-jp)

(make-coding-system
 'iso-2022-jp-2 2 ?J
 "ISO 2022 based 7bit encoding for CJK, Latin-1, and Greek (MIME:ISO-2022-JP-2)"
 '((ascii japanese-jisx0208-1978 japanese-jisx0208
	  latin-jisx0201 japanese-jisx0212 katakana-jisx0201
	  chinese-gb2312 korean-ksc5601) nil
	  (nil latin-iso8859-1 greek-iso8859-7) nil
 short ascii-eol ascii-cntl seven nil single-shift)
 '((safe-charsets ascii japanese-jisx0208-1978 japanese-jisx0208
		  latin-jisx0201 japanese-jisx0212 katakana-jisx0201
		  chinese-gb2312 korean-ksc5601
		  latin-iso8859-1 greek-iso8859-7)
   (mime-charset . iso-2022-jp-2)))

(make-coding-system
 'japanese-shift-jis 1 ?S
 "Shift-JIS 8-bit encoding for Japanese (MIME:SHIFT_JIS)"
 nil
 '((safe-charsets ascii japanese-jisx0208 japanese-jisx0208-1978
		  latin-jisx0201 katakana-jisx0201)
   (mime-charset . shift_jis)
   (charset-origin-alist (japanese-jisx0208 "SJIS" encode-sjis-char)
			 (katakana-jisx0201 "SJIS" encode-sjis-char))))

(define-coding-system-alias 'shift_jis 'japanese-shift-jis)
(define-coding-system-alias 'sjis 'japanese-shift-jis)

(make-coding-system
 'japanese-iso-7bit-1978-irv 2 ?j
 "ISO 2022 based 7-bit encoding for Japanese JISX0208-1978 and JISX0201-Roman"
 '((ascii japanese-jisx0208-1978 japanese-jisx0208
	  latin-jisx0201 japanese-jisx0212 katakana-jisx0201 t) nil nil nil
   short ascii-eol ascii-cntl seven nil nil use-roman use-oldjis)
 '(ascii japanese-jisx0208-1978 japanese-jisx0208 latin-jisx0201))

(define-coding-system-alias 'iso-2022-jp-1978-irv 'japanese-iso-7bit-1978-irv)
(define-coding-system-alias 'old-jis 'japanese-iso-7bit-1978-irv)

(make-coding-system
 'japanese-iso-8bit 2 ?E
 "ISO 2022 based EUC encoding for Japanese (MIME:EUC-JP)"
 '(ascii japanese-jisx0208 katakana-jisx0201 japanese-jisx0212
   short ascii-eol ascii-cntl nil nil single-shift)
 '((safe-charsets ascii latin-jisx0201 japanese-jisx0208 japanese-jisx0208-1978
		 katakana-jisx0201 japanese-jisx0212)
   (mime-charset . euc-jp)))

(define-coding-system-alias 'euc-japan-1990 'japanese-iso-8bit)
(define-coding-system-alias 'euc-japan 'japanese-iso-8bit)
(define-coding-system-alias 'euc-jp 'japanese-iso-8bit)

(set-language-info-alist
 "Japanese" '((setup-function . setup-japanese-environment-internal)
	      (exit-function . exit-japanese-environment)
	      (tutorial . "TUTORIAL.ja")
	      (charset japanese-jisx0208 japanese-jisx0208-1978
		       japanese-jisx0212 latin-jisx0201 katakana-jisx0201)
	      (coding-system iso-2022-jp japanese-iso-8bit
			     japanese-shift-jis japanese-iso-7bit-1978-irv)
	      (coding-priority iso-2022-jp japanese-iso-8bit
			       japanese-shift-jis iso-2022-jp-2)
	      (input-method . "japanese")
	      (features japan-util)
	      (sample-text . "Japanese ($BF|K\8l(B)	$B$3$s$K$A$O(B, (I:]FAJ(B")
	      (documentation . t)))

;;; japanese.el ends here
