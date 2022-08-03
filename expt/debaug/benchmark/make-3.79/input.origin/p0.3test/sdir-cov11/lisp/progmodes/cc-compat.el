;;; cc-compat.el --- cc-mode compatibility with c-mode.el confusion

;; Copyright (C) 1985,87,92,93,94,95,96,97,98 Free Software Foundation, Inc.

;; Author:     1994-1997 Barry A. Warsaw
;; Maintainer: bug-cc-mode@gnu.org
;; Created:    August 1994, split from cc-mode.el
;; Version:    See cc-mode.el
;; Keywords:   c languages oop

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
;;
;; Boring old c-mode.el (BOCM) is confusion and brain melt. cc-mode.el
;; is clarity of thought and purity of chi. If you are still unwilling
;; to accept enlightenment, this might help, or it may prolong your
;; agony.
;;
;; To use, add the following to your c-mode-hook:
;;
;; (require 'cc-compat)
;; (c-set-style "BOCM")

;;; Code:

(eval-when-compile
  (require 'cc-defs)
  (require 'cc-styles)
  (require 'cc-engine))


;; In case c-mode.el isn't loaded
(defvar c-indent-level 2
  "*Indentation of C statements with respect to containing block.")
(defvar c-brace-imaginary-offset 0
  "*Imagined indentation of a C open brace that actually follows a statement.")
(defvar c-brace-offset 0
  "*Extra indentation for braces, compared with other text in same context.")
(defvar c-argdecl-indent 5
  "*Indentation level of declarations of C function arguments.")
(defvar c-label-offset -2
  "*Offset of C label lines and case statements relative to usual indentation.")
(defvar c-continued-statement-offset 2
  "*Extra indent for lines not starting new statements.")
(defvar c-continued-brace-offset 0
  "*Extra indent for substatements that start with open-braces.
This is in addition to c-continued-statement-offset.")



;; these offsets are taken by brute force testing c-mode.el, since
;; there's no logic to what it does.
(let* ((offsets	'(c-offsets-alist .
		    ((defun-block-intro     . cc-block-intro-offset)
		     (statement-block-intro . cc-block-intro-offset)
		     (defun-open            . 0)
		     (class-open            . 0)
		     (inline-open           . c-brace-offset)
		     (block-open            . c-brace-offset)
		     (block-close           . cc-block-close-offset)
		     (brace-list-open       . c-brace-offset)
		     (substatement-open     . cc-substatement-open-offset)
		     (substatement          . c-continued-statement-offset)
		     (knr-argdecl-intro     . c-argdecl-indent)
		     (case-label            . c-label-offset)
		     (access-label          . c-label-offset)
		     (label                 . c-label-offset)
		     ))))
  (c-add-style "BOCM" offsets))


(defun cc-block-intro-offset (langelem)
  ;; taken directly from calculate-c-indent confusion
  (save-excursion
    (c-backward-syntactic-ws)
    (if (eq (char-before) ?{)
	(forward-char -1)
      (goto-char (cdr langelem)))
    (let* ((curcol (save-excursion 
		     (goto-char (cdr langelem))
		     (current-column)))
	  (bocm-lossage
	   ;; If no previous statement, indent it relative to line
	   ;; brace is on.  For open brace in column zero, don't let
	   ;; statement start there too.  If c-indent-level is zero,
	   ;; use c-brace-offset + c-continued-statement-offset
	   ;; instead.  For open-braces not the first thing in a line,
	   ;; add in c-brace-imaginary-offset.
	   (+ (if (and (bolp) (zerop c-indent-level))
		  (+ c-brace-offset c-continued-statement-offset)
		c-indent-level)
	      ;; Move back over whitespace before the openbrace.  If
	      ;; openbrace is not first nonwhite thing on the line,
	      ;; add the c-brace-imaginary-offset.
	      (progn (skip-chars-backward " \t")
		     (if (bolp) 0 c-brace-imaginary-offset))
	      ;; If the openbrace is preceded by a parenthesized exp,
	      ;; move to the beginning of that; possibly a different
	      ;; line
	      (progn
		(if (eq (char-before) ?\))
		    (c-forward-sexp -1))
		;; Get initial indentation of the line we are on.
		(current-indentation)))))
      (- bocm-lossage curcol))))


(defun cc-block-close-offset (langelem)
  (save-excursion
    (let* ((here (point))
	   bracep 
	   (curcol (progn
		     (goto-char (cdr langelem))
		     (current-column)))
	   (bocm-lossage (progn
			   (goto-char (cdr langelem))
			   (if (eq (char-after) ?{)
			       (setq bracep t)
			     (goto-char here)
			     (beginning-of-line)
			     (backward-up-list 1)
			     (forward-char 1)
			     (c-forward-syntactic-ws))
			   (current-column))))
      (- bocm-lossage curcol
	 (if bracep 0 c-indent-level)))))
      

(defun cc-substatement-open-offset (langelem)
  (+ c-continued-statement-offset c-continued-brace-offset))


(provide 'cc-compat)
;;; cc-compat.el ends here
