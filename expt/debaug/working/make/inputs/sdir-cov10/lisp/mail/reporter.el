;;; reporter.el --- customizable bug reporting of lisp programs

;; Copyright (C) 1993,1994,1995,1996,1997,1998 Free Software Foundation, Inc.

;; Author:          1993-1998 Barry A. Warsaw
;; Maintainer:      tools-help@python.org
;; Created:         19-Apr-1993
;; Version:         3.34
;; Last Modified:   1998/03/19 17:21:16
;; Keywords: maint mail tools

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

;; End User Interface
;; ==================
;; The variable `mail-user-agent' contains a symbol indicating which
;; Emacs mail package end users would like to use to compose outgoing
;; mail.  See that variable for details (it is no longer defined in
;; this file).

;; Lisp Package Authors
;; ====================
;; reporter.el was written primarily for Emacs Lisp package authors so
;; that their users can more easily report bugs.  When invoked,
;; `reporter-submit-bug-report' will set up an outgoing mail buffer
;; with the appropriate bug report address, including a lisp
;; expression the maintainer of the package can evaluate to completely
;; reproduce the environment in which the bug was observed (e.g. by
;; using `eval-last-sexp').  This package proved especially useful
;; during my development of CC Mode, which is highly dependent on its
;; configuration variables.
;;
;; Do a "C-h f reporter-submit-bug-report" for more information.
;; Here's an example usage:
;;
;;(defconst mypkg-version "9.801")
;;(defconst mypkg-maintainer-address "mypkg-help@foo.com")
;;(defun mypkg-submit-bug-report ()
;;  "Submit via mail a bug report on mypkg"
;;  (interactive)
;;  (require 'reporter)
;;  (reporter-submit-bug-report
;;   mypkg-maintainer-address
;;   (concat "mypkg.el " mypkg-version)
;;   (list 'mypkg-variable-1
;;         'mypkg-variable-2
;;         ;; ...
;;         'mypkg-variable-last)))

;; Reporter Users
;; ==============
;; Packages that currently use reporter are: CC Mode, supercite, elp,
;; tcl, ediff, crypt++ (crypt), dired-x, rmailgen, mode-line, vm,
;; mh-e, edebug, archie, viper, w3-mode, framepop, hl319, hilit19,
;; pgp, eos, hm--html, efs, webster19.
;;
;; If you know of others, please email me!

;;; Code:


;; vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
;; Package author interface variables

(defvar reporter-prompt-for-summary-p nil
  "Interface variable controlling prompting for problem summary.
When non-nil, `reporter-submit-bug-report' prompts the user for a
brief summary of the problem, and puts this summary on the Subject:
line.  If this variable is a string, that string is used as the prompt
string.

Default behavior is to not prompt (i.e. nil). If you want reporter to
prompt, you should `let' bind this variable before calling
`reporter-submit-bug-report'.  Note that this variable is not
buffer-local so you should never just `setq' it.")

(defvar reporter-dont-compact-list nil
  "Interface variable controlling compacting of list values.
When non-nil, this must be a list of variable symbols.  When a
variable containing a list value is formatted in the bug report mail
buffer, it normally is compacted so that its value fits one the fewest
number of lines.  If the variable's symbol appears in this list, its
value is printed in a more verbose style, specifically, one elemental
sexp per line.

Note that this variable is not buffer-local so you should never just
`setq' it.  If you want to changes its default value, you should `let'
bind it.")

;; ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
;; End of editable variables


(defvar reporter-eval-buffer nil
  "Buffer to retrieve variable's value from.
This is necessary to properly support the printing of buffer-local
variables.  Current buffer will always be the mail buffer being
composed.")

(defconst reporter-version "3.34"
  "Reporter version number.")

(defvar reporter-initial-text nil
  "The automatically created initial text of a bug report.")
(make-variable-buffer-local 'reporter-initial-text)



;; status feedback to the user
(defvar reporter-status-message nil)
(defvar reporter-status-count nil)

(defun reporter-update-status ()
  ;; periodically output a status message
  (if (zerop (% reporter-status-count 10))
      (progn
	(message reporter-status-message)
	(setq reporter-status-message (concat reporter-status-message "."))))
  (setq reporter-status-count (1+ reporter-status-count)))


;; dumping/pretty printing of values
(defun reporter-beautify-list (maxwidth compact-p)
  ;; pretty print a list
  (reporter-update-status)
  (let ((move t)
	linebreak indent-enclosing-p indent-p here)
    (condition-case nil			;loop exit
	(progn
	  (down-list 1)
	  (setq indent-enclosing-p t)
	  (while move
	    (setq here (point))
	    ;; The following line is how we break out of the while
	    ;; loop, in one of two ways.  Either we've hit the end of
	    ;; the buffer, in which case scan-sexps returns nil, or
	    ;; we've crossed unbalanced parens and it will raise an
	    ;; error we're expecting to catch.
	    (setq move (scan-sexps (point) 1))
	    (goto-char move)
	    (if (<= maxwidth (current-column))
		(if linebreak
		    (progn
		      (goto-char linebreak)
		      (newline-and-indent)
		      (setq linebreak nil))
		  (goto-char here)
		  (setq indent-p (reporter-beautify-list maxwidth compact-p))
		  (goto-char here)
		  (forward-sexp 1)
		  (if indent-p
		      (newline-and-indent))
		  t)
	      (if compact-p
		  (setq linebreak (point))
		(newline-and-indent))
	      ))
	  t)
      (error indent-enclosing-p))))

(defun reporter-lisp-indent (indent-point state)
  ;; a better lisp indentation style for bug reporting
  (save-excursion
    (goto-char (1+ (nth 1 state)))
    (current-column)))

(defun reporter-dump-variable (varsym mailbuf)
  ;; Pretty-print the value of the variable in symbol VARSYM.  MAILBUF
  ;; is the mail buffer being composed
  (reporter-update-status)
  (condition-case nil
      (let ((val (save-excursion
		   (set-buffer reporter-eval-buffer)
		   (symbol-value varsym)))
	    (sym (symbol-name varsym))
	    (print-escape-newlines t)
	    (maxwidth (1- (window-width)))
	    (here (point)))
	(insert "     " sym " "
		(cond
		 ((memq val '(t nil)) "")
		 ((listp val) "'")
		 ((symbolp val) "'")
		 (t ""))
		(prin1-to-string val))
	(lisp-indent-line)
	;; clean up lists, but only if the line as printed was long
	;; enough to wrap
	(if (and val			;nil is a list, but short
		 (listp val)
		 (<= maxwidth (current-column)))
	    (save-excursion
	      (let ((compact-p (not (memq varsym reporter-dont-compact-list)))
		    (lisp-indent-function 'reporter-lisp-indent))
		(goto-char here)
		(reporter-beautify-list maxwidth compact-p))))
	(insert "\n"))
    (void-variable
     (save-excursion
       (set-buffer mailbuf)
       (mail-position-on-field "X-Reporter-Void-Vars-Found")
       (end-of-line)
       (insert (symbol-name varsym) " ")))
    (error
     (error ""))))

(defun reporter-dump-state (pkgname varlist pre-hooks post-hooks)
  ;; Dump the state of the mode specific variables.
  ;; PKGNAME contains the name of the mode as it will appear in the bug
  ;; report (you must explicitly concat any version numbers).

  ;; VARLIST is the list of variables to dump.  Each element in
  ;; VARLIST can be a variable symbol, or a cons cell.  If a symbol,
  ;; this will be passed to `reporter-dump-variable' for insertion
  ;; into the mail buffer.  If a cons cell, the car must be a variable
  ;; symbol and the cdr must be a function which will be `funcall'd
  ;; with arguments the symbol and the mail buffer being composed. Use
  ;; this to write your own custom variable value printers for
  ;; specific variables.

  ;; Note that the global variable `reporter-eval-buffer' will be bound to
  ;; the buffer in which `reporter-submit-bug-report' was invoked.  If you
  ;; want to print the value of a buffer local variable, you should wrap
  ;; the `eval' call in your custom printer inside a `set-buffer' (and
  ;; probably a `save-excursion'). `reporter-dump-variable' handles this
  ;; properly.

  ;; PRE-HOOKS is run after the emacs-version and PKGNAME are inserted, but
  ;; before the VARLIST is dumped.  POST-HOOKS is run after the VARLIST is
  ;; dumped.
  (let ((buffer (current-buffer)))
    (set-buffer buffer)
    (insert "Emacs  : " (emacs-version) "\n")
    (and pkgname
	 (insert "Package: " pkgname "\n"))
    (run-hooks 'pre-hooks)
    (if (not varlist)
	nil
      (insert "\ncurrent state:\n==============\n")
      ;; create an emacs-lisp-mode buffer to contain the output, which
      ;; we'll later insert into the mail buffer
      (condition-case fault
	  (let ((mailbuf (current-buffer))
		(elbuf (get-buffer-create " *tmp-reporter-buffer*")))
	    (save-excursion
	      (set-buffer elbuf)
	      (emacs-lisp-mode)
	      (erase-buffer)
	      (insert "(setq\n")
	      (lisp-indent-line)
	      (mapcar
	       (function
		(lambda (varsym-or-cons-cell)
		  (let ((varsym (or (car-safe varsym-or-cons-cell)
				    varsym-or-cons-cell))
			(printer (or (cdr-safe varsym-or-cons-cell)
				     'reporter-dump-variable)))
		    (funcall printer varsym mailbuf)
		    )))
	       varlist)
	      (lisp-indent-line)
	      (insert ")\n"))
	    (insert-buffer elbuf))
	(error
	 (insert "State could not be dumped due to the following error:\n\n"
		 (format "%s" fault)
		 "\n\nYou should still send this bug report."))))
    (run-hooks 'post-hooks)
    ))


(defun reporter-compose-outgoing ()
  ;; compose the outgoing mail buffer, and return the selected
  ;; paradigm, with the current-buffer tacked onto the beginning of
  ;; the list.
  (let* ((agent mail-user-agent)
	 (compose (get mail-user-agent 'composefunc)))
    ;; Sanity check.  If this fails then we'll try to use the SENDMAIL
    ;; protocol, otherwise we must signal an error.
    (if (not (and compose (functionp compose)))
	(progn
	  (setq agent 'sendmail-user-agent
		compose (get agent 'composefunc))
	  (if (not (and compose (functionp compose)))
	      (error "Could not find a valid `mail-user-agent'")
	    (ding)
	    (message "`%s' is an invalid `mail-user-agent'; using `sendmail-user-agent'"
		     mail-user-agent)
	    )))
    (funcall compose)
    agent))


;;;###autoload
(defun reporter-submit-bug-report
  (address pkgname varlist &optional pre-hooks post-hooks salutation)
  ;; Submit a bug report via mail.

  ;; ADDRESS is the email address for the package's maintainer. PKGNAME is
  ;; the name of the mode (you must explicitly concat any version numbers).
  ;; VARLIST is the list of variables to dump (see `reporter-dump-state'
  ;; for details). Optional PRE-HOOKS and POST-HOOKS are passed to
  ;; `reporter-dump-state'. Optional SALUTATION is inserted at the top of the
  ;; mail buffer, and point is left after the salutation.

  ;; This function will prompt for a summary if
  ;; reporter-prompt-for-summary-p is non-nil.

  ;; The mailer used is described in by the variable `mail-user-agent'.
  (let ((reporter-eval-buffer (current-buffer))
	final-resting-place
	after-sep-pos
	(reporter-status-message "Formatting bug report buffer...")
	(reporter-status-count 0)
	(problem (and reporter-prompt-for-summary-p
		      (read-string (if (stringp reporter-prompt-for-summary-p)
				       reporter-prompt-for-summary-p
				     "(Very) brief summary of problem: "))))
	(agent (reporter-compose-outgoing))
	(mailbuf (current-buffer))
	hookvar)
    ;; do the work
    (require 'sendmail)
    ;; If mailbuf did not get made visible before, make it visible now.
    (let (same-window-buffer-names same-window-regexps)
      (pop-to-buffer mailbuf)
      ;; Just in case the original buffer is not visible now, bring it
      ;; back somewhere
      (and pop-up-windows (display-buffer reporter-eval-buffer)))
    (goto-char (point-min))
    (mail-position-on-field "to")
    (insert address)
    ;; insert problem summary if available
    (if (and reporter-prompt-for-summary-p problem pkgname)
	(progn
	  (mail-position-on-field "subject")
	  (insert pkgname "; " problem)))
    ;; move point to the body of the message
    (mail-text)
    (forward-line 1)
    (setq after-sep-pos (point))
    (and salutation (insert "\n" salutation "\n\n"))
    (unwind-protect
	(progn
	  (setq final-resting-place (point-marker))
	  (insert "\n\n")
	  (reporter-dump-state pkgname varlist pre-hooks post-hooks)
	  (goto-char final-resting-place))
      (set-marker final-resting-place nil))

    ;; save initial text and set up the `no-empty-submission' hook.
    ;; This only works for mailers that support a pre-send hook, and
    ;; for which the paradigm has a non-nil value for the `hookvar'
    ;; key in its agent (i.e. sendmail.el's mail-send-hook).
    (save-excursion
      (goto-char (point-max))
      (skip-chars-backward " \t\n")
      (setq reporter-initial-text (buffer-substring after-sep-pos (point))))
    (if (setq hookvar (get agent 'hookvar))
	(progn
	  (make-variable-buffer-local hookvar)
	  (add-hook hookvar 'reporter-bug-hook)))

    ;; compose the minibuf message and display this.
    (let* ((sendkey-whereis (where-is-internal
			     (get agent 'sendfunc) nil t))
	   (abortkey-whereis (where-is-internal
			      (get agent 'abortfunc) nil t))
	   (sendkey (if sendkey-whereis
			(key-description sendkey-whereis)
		      "C-c C-c"))   ; TBD: BOGUS hardcode
	   (abortkey (if abortkey-whereis
			 (key-description abortkey-whereis)
		       "M-x kill-buffer"))  ; TBD: BOGUS hardcode
	   )
      (message "Please enter your report.  Type %s to send, %s to abort."
	       sendkey abortkey))
    ))

(defun reporter-bug-hook ()
  ;; prohibit sending mail if empty bug report
  (let ((after-sep-pos
	 (save-excursion
	   (rfc822-goto-eoh)
	   (forward-line 1)
	   (point))))
    (save-excursion
      (goto-char (point-max))
      (skip-chars-backward " \t\n")
      (if (and (= (- (point) after-sep-pos)
		  (length reporter-initial-text))
	       (string= (buffer-substring after-sep-pos (point))
			reporter-initial-text))
	  (error "Empty bug report cannot be sent"))
      )))


(provide 'reporter)
;;; reporter.el ends here
