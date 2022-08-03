;;; cus-start.el --- define customization properties of builtins.
;;
;; Copyright (C) 1997 Free Software Foundation, Inc.
;;
;; Author: Per Abrahamsen <abraham@dina.kvl.dk>
;; Keywords: internal

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
;; This file adds customize support for built-in variables.

;; While dumping Emacs, this file is loaded, but it only records
;; the standard values; it does not do the rest of the job.
;; Later on, if the user makes a customization buffer,
;; this file is loaded again with (require 'cus-start);
;; then it does the whole job.

;;; Code:

(let ((all '(;; abbrev.c 
	     (abbrev-all-caps abbrev-mode boolean)
	     (pre-abbrev-expand-hook abbrev-mode hook)
	     ;; alloc.c
	     (gc-cons-threshold alloc integer)
	     (undo-limit undo integer)
	     (undo-strong-limit undo integer)
	     (garbage-collection-messages alloc boolean)
	     ;; buffer.c
	     (mode-line-format modeline sexp) ;Hard to do right.
	     (default-major-mode internal function)
	     (enable-multibyte-characters mule boolean)
	     (case-fold-search matching boolean)
	     (fill-column fill integer)
	     (left-margin fill integer)
	     (tab-width editing-basics integer)
	     (ctl-arrow display boolean)
	     (truncate-lines display boolean)
	     (selective-display-ellipses display boolean)
	     (transient-mark-mode editing-basics boolean)
	     ;; callint.c
	     (mark-even-if-inactive editing-basics boolean)
	     ;; callproc.c
	     (shell-file-name execute file)
	     (exec-path execute
			(repeat (choice (const :tag "default" nil)
					(file :format "%v"))))
	     ;; coding.c
	     (inhibit-eol-conversion mule boolean)
	     (eol-mnemonic-undecided mule string)
	     (eol-mnemonic-unix mule string)
	     (eol-mnemonic-dos mule string)
	     (eol-mnemonic-mac mule string)
	     ;; dired.c
	     (completion-ignored-extensions dired 
					    (repeat (string :format "%v")))
	     ;; dispnew.el
	     (baud-rate display integer)
	     (inverse-video display boolean)
	     (visible-bell display boolean)
	     (no-redraw-on-reenter display boolean)
	     ;; editfns.c
	     (user-full-name mail string)
	     ;; eval.c
	     (max-specpdl-size limits integer)
	     (max-lisp-eval-depth limits integer)
	     (stack-trace-on-error debug
				   (choice (const :tag "off")
					   (repeat :menu-tag "When"
						   :value (nil)
						   (symbol :format "%v"))
					   (const :tag "always" t)))
	     (debug-on-error debug 
			     (choice (const :tag "off")
				     (repeat :menu-tag "When"
					     :value (nil)
					     (symbol :format "%v"))
				     (const :tag "always" t)))
	     (debug-ignored-errors debug (repeat (choice symbol regexp)))
	     (debug-on-quit debug
			    (choice (const :tag "off")
				    (repeat :menu-tag "When"
					    :value (nil)
					    (symbol :format "%v"))
				    (const :tag "always" t)))
	     ;; fileio.c
	     (insert-default-directory minibuffer boolean)
	     ;; frame.c
	     (default-frame-alist frames
	       (repeat (cons :format "%v"
			     (symbol :tag "Parameter")
			     (sexp :tag "Value"))))
	     ;; indent.c
	     (indent-tabs-mode fill boolean)
	     ;; keyboard.c
	     (meta-prefix-char keyboard character)
	     (auto-save-interval auto-save integer)
	     (auto-save-timeout auto-save (choice (const :tag "off" nil)
						  (integer :format "%v")))
	     (echo-keystrokes minibuffer integer)
	     (polling-period keyboard integer)
	     (double-click-time mouse (restricted-sexp
				       :match-alternatives (integerp 'nil 't)))
	     (inhibit-local-menu-bar-menus menu boolean)
	     (help-char keyboard character)
	     (help-event-list keyboard (repeat (sexp :format "%v")))
	     (menu-prompting menu boolean)
	     (suggest-key-bindings keyboard (choice (const :tag "off" nil)
						    (integer :tag "time" 2)
						    (other :tag "on")))
	     ;; lread.c
	     (load-path environment 
			(repeat (choice :tag "[Current dir?]"
					:format "%[Current dir?%] %v"
					(const :tag " current dir" nil)
					(directory :format "%v"))))
	     ;; minibuf.c
	     (completion-auto-help minibuffer boolean)
	     (enable-recursive-minibuffers minibuffer boolean)
	     (minibuffer-auto-raise minibuffer boolean)
	     ;; msdos.c
	     (dos-unsupported-char-glyph display integer)
	     ;; process.c
	     (delete-exited-processes processes-basics boolean)
	     ;; syntax.c
	     (parse-sexp-ignore-comments editing-basics boolean)
	     (words-include-escapes editing-basics boolean)
	     ;; window.c
	     (temp-buffer-show-function windows function)
	     (display-buffer-function windows function)
	     (pop-up-frames frames boolean)
	     (pop-up-frame-function frames function)
	     (special-display-buffer-names 
	      frames 
	      (repeat (choice :tag "Buffer"
			      :value ""
			      (string :format "%v")
			      (cons :tag "With attributes"
				    :format "%v"
				    :value ("" . nil)
				    (string :format "%v")
				    (repeat :tag "Attributes"
					    (cons :format "%v"
						  (symbol :tag "Parameter")
						  (sexp :tag "Value")))))))
	     (special-display-regexps
	      frames 
	      (repeat (choice :tag "Buffer"
			      :value ""
			      (regexp :format "%v")
			      (cons :tag "With attributes"
				    :format "%v"
				    :value ("" . nil)
				    (regexp :format "%v")
				    (repeat :tag "Attributes"
					    (cons :format "%v"
						  (symbol :tag "Parameter")
						  (sexp :tag "Value")))))))
	     (special-display-function frames function)
	     (same-window-buffer-names windows (repeat (string :format "%v")))
	     (same-window-regexps windows (repeat (regexp :format "%v")))
	     (pop-up-windows windows boolean)
	     (next-screen-context-lines windows integer)
	     (split-height-threshold windows integer)
	     (window-min-height windows integer)
	     (window-min-width windows integer)
	     (scroll-preserve-screen-position windows boolean)
	     ;; xdisp.c
	     (scroll-step windows integer)
	     (scroll-conservatively windows integer)
	     (scroll-margin windows integer)
	     (truncate-partial-width-windows display boolean)
	     (mode-line-inverse-video modeline boolean)
	     (line-number-display-limit display integer)
	     (highlight-nonselected-windows display boolean)
	     (message-log-max debug (choice (const :tag "Disable" nil)
					    (integer :menu-tag "lines"
						     :format "%v")
					    (other :tag "Unlimited" t)))
	     (unibyte-display-via-language-environment mule boolean)
	     ;; xfns.c
	     (x-bitmap-file-path installation
				 (repeat (directory :format "%v")))))
      this symbol group type native-p
      ;; This function turns a value
      ;; into an expression which produces that value.
      (quoter (lambda (sexp)
		(if (or (memq sexp '(t nil))
			(and (symbolp sexp)
			     (eq (aref (symbol-name sexp) 0) ?:))
			(and (listp sexp)
			     (memq (car sexp) '(lambda)))
			(stringp sexp)
			(numberp sexp)
			(and (fboundp 'characterp)
			     (characterp sexp)))
		    sexp
		  (list 'quote sexp)))))
  (while all 
    (setq this (car all)
	  all (cdr all)
	  symbol (nth 0 this)
	  group (nth 1 this)
	  type (nth 2 this)
	  ;; Don't complain about missing variables which are
	  ;; irrelevant to this platform.
	  native-p (save-match-data
		     (cond
		      ((string-match "\\`dos-" (symbol-name symbol))
		       (eq system-type 'ms-dos))
		      ((string-match "\\`w32-" (symbol-name symbol))
		       (eq system-type 'windows-nt))
		      (t t))))
    (if (not (boundp symbol))
	;; If variables are removed from C code, give an error here!
	(and native-p
	     (message "Note, built-in variable `%S' not bound" symbol))
      ;; Save the standard value, unless we already did.
      (or (get symbol 'standard-value)
	  (put symbol 'standard-value 
	       (list (funcall quoter (default-value symbol)))))
      ;; If this is NOT while dumping Emacs,
      ;; set up the rest of the customization info.
      (unless purify-flag
	;; Add it to the right group.
	(custom-add-to-group group symbol 'custom-variable)
	;; Set the type.
	(put symbol 'custom-type type)))))

;; Record cus-start as loaded
;; if we have set up all the info that we can set up.
;; Don't record cus-start as loaded
;; if we have set up only the standard values.
(unless purify-flag
  (provide 'cus-start))

;;; cus-start.el ends here.
