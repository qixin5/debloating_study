;;; add-log.el --- change log maintenance commands for Emacs

;; Copyright (C) 1985, 86, 88, 93, 94, 97, 1998 Free Software Foundation, Inc.

;; Keywords: tools

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

;; This facility is documented in the Emacs Manual.

;;; Code:

(eval-when-compile (require 'fortran))

(defgroup change-log nil
  "Change log maintenance"
  :group 'tools
  :link '(custom-manual "(emacs)Change Log")
  :prefix "change-log-"
  :prefix "add-log-")


(defcustom change-log-default-name nil
  "*Name of a change log file for \\[add-change-log-entry]."
  :type '(choice (const :tag "default" nil)
		 string)
  :group 'change-log)

(defcustom add-log-current-defun-function nil
  "\
*If non-nil, function to guess name of current function from surrounding text.
\\[add-change-log-entry] calls this function (if nil, `add-log-current-defun'
instead) with no arguments.  It returns a string or nil if it cannot guess."
  :type 'function
  :group 'change-log)

;;;###autoload
(defcustom add-log-full-name nil
  "*Full name of user, for inclusion in ChangeLog daily headers.
This defaults to the value returned by the `user-full-name' function."
  :type '(choice (const :tag "Default" nil)
		 string)
  :group 'change-log)

;;;###autoload
(defcustom add-log-mailing-address nil
  "*Electronic mail address of user, for inclusion in ChangeLog daily headers.
This defaults to the value of `user-mail-address'."
  :type '(choice (const :tag "Default" nil)
		 string)
  :group 'change-log)

(defcustom add-log-time-format 'add-log-iso8601-time-string
  "*Function that defines the time format.
For example, `add-log-iso8601-time-string', which gives the
date in international ISO 8601 format,
and `current-time-string' are two valid values."
  :type '(radio (const :tag "International ISO 8601 format"
		       add-log-iso8601-time-string)
		(const :tag "Old format, as returned by `current-time-string'"
		       current-time-string)
		(function :tag "Other"))
  :group 'change-log)

(defcustom add-log-keep-changes-together nil
  "*If non-nil, normally keep day's log entries for one file together.

Log entries for a given file made with \\[add-change-log-entry] or
\\[add-change-log-entry-other-window] will only be added to others \
for that file made
today if this variable is non-nil or that file comes first in today's
entries.  Otherwise another entry for that file will be started.  An
original log:

	* foo (...): ...
	* bar (...): change 1

in the latter case, \\[add-change-log-entry-other-window] in a \
buffer visiting `bar', yields:

	* bar (...): -!-
	* foo (...): ...
	* bar (...): change 1

and in the former:

	* foo (...): ...
	* bar (...): change 1
	(...): -!-

The NEW-ENTRY arg to `add-change-log-entry' can override the effect of
this variable."
  :version "20.3"
  :type 'boolean
  :group 'change-log)

(defcustom add-log-file-name-function nil
  "*If non-nil, function to call to identify the filename for a ChangeLog entry.
This function is called with one argument, `buffer-file-name' in that buffer.
If this is nil, the default is to use the file's name
relative to the directory of the change log file."
  :type 'function
  :group 'change-log)

(defvar change-log-font-lock-keywords
  '(;;
    ;; Date lines, new and old styles.
    ("^\\sw.........[0-9:+ ]*"
     (0 font-lock-string-face)
     ;; Name and e-mail; some people put e-mail in parens, not angles.
     ("\\([^<(]+\\)[(<]\\([A-Za-z0-9_.-]+@[A-Za-z0-9_.-]+\\)[>)]" nil nil
      (1 font-lock-constant-face)
      (2 font-lock-variable-name-face)))
    ;;
    ;; File names.
    ("^\t\\* \\([^ ,:([\n]+\\)"
     (1 font-lock-function-name-face)
     ;; Possibly further names in a list:
     ("\\=, \\([^ ,:([\n]+\\)" nil nil (1 font-lock-function-name-face))
     ;; Possibly a parenthesized list of names:
     ("\\= (\\([^) ,:\n]+\\)" nil nil (1 font-lock-keyword-face))
     ("\\=, *\\([^) ,:\n]+\\)" nil nil (1 font-lock-keyword-face)))
    ;;
    ;; Function or variable names.
    ("^\t(\\([^) ,:\n]+\\)"
     (1 font-lock-keyword-face)
     ("\\=, *\\([^) ,:\n]+\\)" nil nil (1 font-lock-keyword-face)))
    ;;
    ;; Conditionals.
    ("\\[!?\\([^]\n]+\\)\\]\\(:\\| (\\)" (1 font-lock-variable-name-face))
    ;;
    ;; Acknowledgements.
    ("^\t\\(From\\|Patch\\(es\\)? by\\|Report\\(ed by\\| from\\)\\|Suggest\\(ed by\\|ion from\\)\\)"
     1 font-lock-comment-face)
    ("  \\(From\\|Patch\\(es\\)? by\\|Report\\(ed by\\| from\\)\\|Suggest\\(ed by\\|ion from\\)\\)"
     1 font-lock-comment-face))
  "Additional expressions to highlight in Change Log mode.")

(defvar change-log-mode-map nil
  "Keymap for Change Log major mode.")
(if change-log-mode-map
    nil
  (setq change-log-mode-map (make-sparse-keymap)))

(defvar change-log-time-zone-rule nil
  "Time zone used for calculating change log time stamps.
It takes the same format as the TZ argument of `set-time-zone-rule'.
If nil, use local time.")

(defvar add-log-debugging)

(defun add-log-iso8601-time-zone (time)
  (let* ((utc-offset (or (car (current-time-zone time)) 0))
	 (sign (if (< utc-offset 0) ?- ?+))
	 (sec (abs utc-offset))
	 (ss (% sec 60))
	 (min (/ sec 60))
	 (mm (% min 60))
	 (hh (/ min 60)))
    (format (cond ((not (zerop ss)) "%c%02d:%02d:%02d")
		  ((not (zerop mm)) "%c%02d:%02d")
		  (t "%c%02d"))
	    sign hh mm ss)))

(defun add-log-iso8601-time-string ()
  (if change-log-time-zone-rule
      (let ((tz (getenv "TZ"))
	    (now (current-time)))
	(unwind-protect
	    (progn
	      (set-time-zone-rule
	       change-log-time-zone-rule)
	      (concat
	       (format-time-string "%Y-%m-%d " now)
	       (add-log-iso8601-time-zone now)))
	  (set-time-zone-rule tz)))
    (format-time-string "%Y-%m-%d")))

(defun change-log-name ()
  (or change-log-default-name
      (if (eq system-type 'vax-vms)
	  "$CHANGE_LOG$.TXT"
	"ChangeLog")))

;;;###autoload
(defun prompt-for-change-log-name ()
  "Prompt for a change log name."
  (let* ((default (change-log-name))
	 (name (expand-file-name
		(read-file-name (format "Log file (default %s): " default)
				nil default))))
    ;; Handle something that is syntactically a directory name.
    ;; Look for ChangeLog or whatever in that directory.
    (if (string= (file-name-nondirectory name) "")
	(expand-file-name (file-name-nondirectory default)
			  name)
      ;; Handle specifying a file that is a directory.
      (if (file-directory-p name)
	  (expand-file-name (file-name-nondirectory default)
			    (file-name-as-directory name))
	name))))

;;;###autoload
(defun find-change-log (&optional file-name)
  "Find a change log file for \\[add-change-log-entry] and return the name.

Optional arg FILE-NAME specifies the file to use.
If FILE-NAME is nil, use the value of `change-log-default-name'.
If 'change-log-default-name' is nil, behave as though it were 'ChangeLog'
\(or whatever we use on this operating system).

If 'change-log-default-name' contains a leading directory component, then
simply find it in the current directory.  Otherwise, search in the current
directory and its successive parents for a file so named.

Once a file is found, `change-log-default-name' is set locally in the
current buffer to the complete file name."
  ;; If user specified a file name or if this buffer knows which one to use,
  ;; just use that.
  (or file-name
      (setq file-name (and change-log-default-name
			   (file-name-directory change-log-default-name)
			   change-log-default-name))
      (progn
	;; Chase links in the source file
	;; and use the change log in the dir where it points.
	(setq file-name (or (and buffer-file-name
				 (file-name-directory
				  (file-chase-links buffer-file-name)))
			    default-directory))
	(if (file-directory-p file-name)
	    (setq file-name (expand-file-name (change-log-name) file-name)))
	;; Chase links before visiting the file.
	;; This makes it easier to use a single change log file
	;; for several related directories.
	(setq file-name (file-chase-links file-name))
	(setq file-name (expand-file-name file-name))
	;; Move up in the dir hierarchy till we find a change log file.
	(let ((file1 file-name)
	      parent-dir)
	  (while (and (not (or (get-file-buffer file1) (file-exists-p file1)))
		      (progn (setq parent-dir
				   (file-name-directory
				    (directory-file-name
				     (file-name-directory file1))))
			     ;; Give up if we are already at the root dir.
			     (not (string= (file-name-directory file1)
					   parent-dir))))
	    ;; Move up to the parent dir and try again.
	    (setq file1 (expand-file-name
			 (file-name-nondirectory (change-log-name))
			 parent-dir)))
	  ;; If we found a change log in a parent, use that.
	  (if (or (get-file-buffer file1) (file-exists-p file1))
	      (setq file-name file1)))))
  ;; Make a local variable in this buffer so we needn't search again.
  (set (make-local-variable 'change-log-default-name) file-name)
  file-name)

;;;###autoload
(defun add-change-log-entry (&optional whoami file-name other-window new-entry)
  "Find change log file and add an entry for today.
Optional arg WHOAMI (interactive prefix) non-nil means prompt for user
name and site.

Second arg is FILE-NAME of change log.  If nil, uses `change-log-default-name'.
Third arg OTHER-WINDOW non-nil means visit in other window.
Fourth arg NEW-ENTRY non-nil means always create a new entry at the front;
never append to an existing entry.  Option `add-log-keep-changes-together'
otherwise affects whether a new entry is created.

Today's date is calculated according to `change-log-time-zone-rule' if
non-nil, otherwise in local time."
  (interactive (list current-prefix-arg
		     (prompt-for-change-log-name)))
  (or add-log-full-name
      (setq add-log-full-name (user-full-name)))
  (or add-log-mailing-address
      (setq add-log-mailing-address user-mail-address))
  (if whoami
      (progn
	(setq add-log-full-name (read-input "Full name: " add-log-full-name))
	 ;; Note that some sites have room and phone number fields in
	 ;; full name which look silly when inserted.  Rather than do
	 ;; anything about that here, let user give prefix argument so that
	 ;; s/he can edit the full name field in prompter if s/he wants.
	(setq add-log-mailing-address
	      (read-input "Mailing address: " add-log-mailing-address))))
  (let ((defun (funcall (or add-log-current-defun-function
			    'add-log-current-defun)))
	bound entry)

    (setq file-name (expand-file-name (find-change-log file-name)))

    ;; Set ENTRY to the file name to use in the new entry.
    (and buffer-file-name
	 ;; Never want to add a change log entry for the ChangeLog file itself.
	 (not (string= buffer-file-name file-name))
	 (setq entry
	       (if add-log-file-name-function
		   (funcall add-log-file-name-function buffer-file-name)
		 (if (string-match
		      (concat "^" (regexp-quote (file-name-directory
						 file-name)))
		      buffer-file-name)
		     (substring buffer-file-name (match-end 0))
		   (file-name-nondirectory buffer-file-name)))))

    (let ((buffer (find-buffer-visiting file-name)))
      (setq add-log-debugging (list (gap-position) (gap-size))))
    (if (and other-window (not (equal file-name buffer-file-name)))
	(find-file-other-window file-name)
      (find-file file-name))
    (or (eq major-mode 'change-log-mode)
	(change-log-mode))
    (undo-boundary)
    (goto-char (point-min))
    (let ((new-entry (concat (funcall add-log-time-format)
			     "  " add-log-full-name
			     "  <" add-log-mailing-address ">")))
      (if (looking-at (regexp-quote new-entry))
	  (forward-line 1)
	(insert new-entry "\n\n")))

    (setq bound
	  (progn
            (if (looking-at "\n*[^\n* \t]")
                (skip-chars-forward "\n")
	      (if add-log-keep-changes-together
		  (forward-page)	; page delimits entries for date
		(forward-paragraph)))	; paragraph delimits entries for file
	    (point)))
    (goto-char (point-min))
    ;; Now insert the new line for this entry.
    (cond ((re-search-forward "^\\s *\\*\\s *$" bound t)
	   ;; Put this file name into the existing empty entry.
	   (if entry
	       (insert entry)))
	  ((and (not new-entry)
		(let (case-fold-search)
		  (re-search-forward
		   (concat (regexp-quote (concat "* " entry))
			   ;; Don't accept `foo.bar' when
			   ;; looking for `foo':
			   "\\(\\s \\|[(),:]\\)")
		   bound t)))
	   ;; Add to the existing entry for the same file.
	   (re-search-forward "^\\s *$\\|^\\s \\*")
	   (goto-char (match-beginning 0))
	   ;; Delete excess empty lines; make just 2.
	   (while (and (not (eobp)) (looking-at "^\\s *$"))
	     (delete-region (point) (save-excursion (forward-line 1) (point))))
	   (insert "\n\n")
	   (forward-line -2)
	   (indent-relative-maybe))
	  (t
	   ;; Make a new entry.
	   (forward-line 1)
	   (while (looking-at "\\sW")
	     (forward-line 1))
	   (while (and (not (eobp)) (looking-at "^\\s *$"))
	     (delete-region (point) (save-excursion (forward-line 1) (point))))
	   (insert "\n\n\n")
	   (forward-line -2)
	   (indent-to left-margin)
	   (insert "* " (or entry ""))))
    ;; Now insert the function name, if we have one.
    ;; Point is at the entry for this file,
    ;; either at the end of the line or at the first blank line.
    (if defun
	(progn
	  ;; Make it easy to get rid of the function name.
	  (undo-boundary)
	  (insert (if (save-excursion
			(beginning-of-line 1)
			(looking-at "\\s *$"))
		      ""
		    " ")
		  "(" defun "): "))
      ;; No function name, so put in a colon unless we have just a star.
      (if (not (save-excursion
		 (beginning-of-line 1)
		 (looking-at "\\s *\\(\\*\\s *\\)?$")))
	  (insert ": ")))))

;;;###autoload
(defun add-change-log-entry-other-window (&optional whoami file-name)
  "Find change log file in other window and add an entry for today.
Optional arg WHOAMI (interactive prefix) non-nil means prompt for user
name and site.
Second optional arg FILE-NAME is file name of change log.
If nil, use `change-log-default-name'.

Affected by the same options as `add-change-log-entry'."
  (interactive (if current-prefix-arg
		   (list current-prefix-arg
			 (prompt-for-change-log-name))))
  (add-change-log-entry whoami file-name t))
;;;###autoload (define-key ctl-x-4-map "a" 'add-change-log-entry-other-window)

;;;###autoload
(defun change-log-mode ()
  "Major mode for editing change logs; like Indented Text Mode.
Prevents numeric backups and sets `left-margin' to 8 and `fill-column' to 74.
New log entries are usually made with \\[add-change-log-entry] or \\[add-change-log-entry-other-window].
Each entry behaves as a paragraph, and the entries for one day as a page.
Runs `change-log-mode-hook'."
  (interactive)
  (kill-all-local-variables)
  (indented-text-mode)
  (setq major-mode 'change-log-mode
	mode-name "Change Log"
	left-margin 8
	fill-column 74
	indent-tabs-mode t
	tab-width 8)
  (use-local-map change-log-mode-map)
  (set (make-local-variable 'fill-paragraph-function)
       'change-log-fill-paragraph)
  ;; We really do want "^" in paragraph-start below: it is only the
  ;; lines that begin at column 0 (despite the left-margin of 8) that
  ;; we are looking for.  Adding `* ' allows eliding the blank line
  ;; between entries for different files.
  (set (make-local-variable 'paragraph-start) "\\s *$\\|\f\\|^\\<")
  (set (make-local-variable 'paragraph-separate) paragraph-start)
  ;; Match null string on the date-line so that the date-line
  ;; is grouped with what follows.
  (set (make-local-variable 'page-delimiter) "^\\<\\|^\f")
  (set (make-local-variable 'version-control) 'never)
  (set (make-local-variable 'adaptive-fill-regexp) "\\s *")
  (set (make-local-variable 'font-lock-defaults)
       '(change-log-font-lock-keywords t))
  (run-hooks 'change-log-mode-hook))

;; It might be nice to have a general feature to replace this.  The idea I
;; have is a variable giving a regexp matching text which should not be
;; moved from bol by filling.  change-log-mode would set this to "^\\s *\\s(".
;; But I don't feel up to implementing that today.
(defun change-log-fill-paragraph (&optional justify)
  "Fill the paragraph, but preserve open parentheses at beginning of lines.
Prefix arg means justify as well."
  (interactive "P")
  (let ((end (progn (forward-paragraph) (point)))
	(beg (progn (backward-paragraph) (point)))
	(paragraph-start (concat paragraph-start "\\|\\s *\\s(")))
    (fill-region beg end justify)
    t))

(defcustom add-log-current-defun-header-regexp
  "^\\([A-Z][A-Z_ ]*[A-Z_]\\|[-_a-zA-Z]+\\)[ \t]*[:=]"
  "*Heuristic regexp used by `add-log-current-defun' for unknown major modes."
  :type 'regexp
  :group 'change-log)

;;;###autoload
(defvar add-log-lisp-like-modes
    '(emacs-lisp-mode lisp-mode scheme-mode dsssl-mode lisp-interaction-mode)
  "*Modes that look like Lisp to `add-log-current-defun'.")

;;;###autoload
(defvar add-log-c-like-modes
    '(c-mode c++-mode c++-c-mode objc-mode)
  "*Modes that look like C to `add-log-current-defun'.")

;;;###autoload
(defvar add-log-tex-like-modes
    '(TeX-mode plain-TeX-mode LaTeX-mode plain-tex-mode latex-mode)
  "*Modes that look like TeX to `add-log-current-defun'.")

;;;###autoload
(defun add-log-current-defun ()
  "Return name of function definition point is in, or nil.

Understands C, Lisp, LaTeX (\"functions\" are chapters, sections, ...),
Texinfo (@node titles), Perl, and Fortran.

Other modes are handled by a heuristic that looks in the 10K before
point for uppercase headings starting in the first column or
identifiers followed by `:' or `=', see variable
`add-log-current-defun-header-regexp'.

Has a preference of looking backwards."
  (condition-case nil
      (save-excursion
	(let ((location (point)))
	  (cond ((memq major-mode add-log-lisp-like-modes)
		 ;; If we are now precisely at the beginning of a defun,
		 ;; make sure beginning-of-defun finds that one
		 ;; rather than the previous one.
		 (or (eobp) (forward-char 1))
		 (beginning-of-defun)
		 ;; Make sure we are really inside the defun found, not after it.
		 (when (and (looking-at "\\s(")
			    (progn (end-of-defun)
				   (< location (point)))
			    (progn (forward-sexp -1)
				   (>= location (point))))
		   (if (looking-at "\\s(")
		       (forward-char 1))
		   ;; Skip the defining construct name, typically "defun"
		   ;; or "defvar".
		   (forward-sexp 1)
		   ;; The second element is usually a symbol being defined.
		   ;; If it is not, use the first symbol in it.
		   (skip-chars-forward " \t\n'(")
		   (buffer-substring (point)
				     (progn (forward-sexp 1)
					    (point)))))
		((and (memq major-mode add-log-c-like-modes)
		      (save-excursion
			(beginning-of-line)
			;; Use eq instead of = here to avoid
			;; error when at bob and char-after
			;; returns nil.
			(while (eq (char-after (- (point) 2)) ?\\)
			  (forward-line -1))
			(looking-at "[ \t]*#[ \t]*define[ \t]")))
		 ;; Handle a C macro definition.
		 (beginning-of-line)
		 (while (eq (char-after (- (point) 2)) ?\\) ;not =; note above
		   (forward-line -1))
		 (search-forward "define")
		 (skip-chars-forward " \t")
		 (buffer-substring (point)
				   (progn (forward-sexp 1) (point))))
		((memq major-mode add-log-c-like-modes)
		 (beginning-of-line)
		 ;; See if we are in the beginning part of a function,
		 ;; before the open brace.  If so, advance forward.
		 (while (not (looking-at "{\\|\\(\\s *$\\)"))
		   (forward-line 1))
		 (or (eobp)
		     (forward-char 1))
		 (beginning-of-defun)
		 (if (progn (end-of-defun)
			    (< location (point)))
		     (progn
		       (backward-sexp 1)
		       (let (beg tem)

			 (forward-line -1)
			 ;; Skip back over typedefs of arglist.
			 (while (and (not (bobp))
				     (looking-at "[ \t\n]"))
			   (forward-line -1))
			 ;; See if this is using the DEFUN macro used in Emacs,
			 ;; or the DEFUN macro used by the C library.
			 (if (condition-case nil
				 (and (save-excursion
					(end-of-line)
					(while (= (preceding-char) ?\\)
					  (end-of-line 2))
					(backward-sexp 1)
					(beginning-of-line)
					(setq tem (point))
					(looking-at "DEFUN\\b"))
				      (>= location tem))
			       (error nil))
			     (progn
			       (goto-char tem)
			       (down-list 1)
			       (if (= (char-after (point)) ?\")
				   (progn
				     (forward-sexp 1)
				     (skip-chars-forward " ,")))
			       (buffer-substring (point)
						 (progn (forward-sexp 1) (point))))
                           (if (looking-at "^[+-]")
                               (change-log-get-method-definition)
                             ;; Ordinary C function syntax.
                             (setq beg (point))
                             (if (and (condition-case nil
					  ;; Protect against "Unbalanced parens" error.
					  (progn
					    (down-list 1) ; into arglist
					    (backward-up-list 1)
					    (skip-chars-backward " \t")
					    t)
					(error nil))
				      ;; Verify initial pos was after
				      ;; real start of function.
				      (save-excursion
					(goto-char beg)
					;; For this purpose, include the line
					;; that has the decl keywords.  This
					;; may also include some of the
					;; comments before the function.
					(while (and (not (bobp))
						    (save-excursion
						      (forward-line -1)
						      (looking-at "[^\n\f]")))
					  (forward-line -1))
					(>= location (point)))
                                          ;; Consistency check: going down and up
                                          ;; shouldn't take us back before BEG.
                                          (> (point) beg))
				 (let (end middle)
				   ;; Don't include any final newline
				   ;; in the name we use.
				   (if (= (preceding-char) ?\n)
				       (forward-char -1))
				   (setq end (point))
				   (backward-sexp 1)
				   ;; Now find the right beginning of the name.
				   ;; Include certain keywords if they
				   ;; precede the name.
				   (setq middle (point))
				   (forward-word -1)
				   ;; Ignore these subparts of a class decl
				   ;; and move back to the class name itself.
				   (while (looking-at "public \\|private ")
				     (skip-chars-backward " \t:")
				     (setq end (point))
				     (backward-sexp 1)
				     (setq middle (point))
				     (forward-word -1))
				   (and (bolp)
					(looking-at "struct \\|union \\|class ")
					(setq middle (point)))
				   (goto-char end)
				   (when (eq (preceding-char) ?=)
				     (forward-char -1)
				     (skip-chars-backward " \t")
				     (setq end (point)))
				   (buffer-substring middle end)))))))))
		((memq major-mode add-log-tex-like-modes)
		 (if (re-search-backward
		      "\\\\\\(sub\\)*\\(section\\|paragraph\\|chapter\\)" nil t)
		     (progn
		       (goto-char (match-beginning 0))
		       (buffer-substring (1+ (point));; without initial backslash
					 (progn
					   (end-of-line)
					   (point))))))
		((eq major-mode 'texinfo-mode)
		 (if (re-search-backward "^@node[ \t]+\\([^,\n]+\\)" nil t)
		     (buffer-substring (match-beginning 1)
				       (match-end 1))))
		((eq major-mode 'perl-mode)
		 (if (re-search-backward "^sub[ \t]+\\([^ \t\n]+\\)" nil t)
		     (buffer-substring (match-beginning 1)
				       (match-end 1))))
                ((or (eq major-mode 'fortran-mode)
		     ;; Needs work for f90, but better than nothing.
		     (eq major-mode 'f90-mode))
                 ;; must be inside function body for this to work
                 (beginning-of-fortran-subprogram)
                 (let ((case-fold-search t)) ; case-insensitive
                   ;; search for fortran subprogram start
                   (if (re-search-forward
                        "^[ \t]*\\(program\\|subroutine\\|function\
\\|[ \ta-z0-9*()]*[ \t]+function\\|\\(block[ \t]*data\\)\\)"
                        (save-excursion (end-of-fortran-subprogram)
                                        (point))
                        t)
                       (or (match-string 2)
                           (progn
                             ;; move to EOL or before first left paren
                             (if (re-search-forward "[(\n]" nil t)
				 (progn (backward-char)
                                        (skip-chars-backward " \t"))
                               (end-of-line))
                             ;; Use the name preceding that.
                             (buffer-substring (point)
					       (progn (backward-sexp)
						      (point)))))
		     "main")))
		(t
		 ;; If all else fails, try heuristics
		 (let (case-fold-search)
		   (end-of-line)
		   (if (re-search-backward add-log-current-defun-header-regexp
					   (- (point) 10000)
					   t)
		       (buffer-substring (match-beginning 1)
					 (match-end 1))))))))
    (error nil)))

(defvar change-log-get-method-definition-md)

;; Subroutine used within change-log-get-method-definition.
;; Add the last match in the buffer to the end of `md',
;; followed by the string END; move to the end of that match.
(defun change-log-get-method-definition-1 (end)
  (setq change-log-get-method-definition-md
	(concat change-log-get-method-definition-md
		(buffer-substring (match-beginning 1) (match-end 1))
		end))
  (goto-char (match-end 0)))

;; For objective C, return the method name if we are in a method.
(defun change-log-get-method-definition ()
  (let ((change-log-get-method-definition-md "["))
    (save-excursion
      (if (re-search-backward "^@implementation\\s-*\\([A-Za-z_]*\\)" nil t)
	  (change-log-get-method-definition-1 " ")))
    (save-excursion
      (cond
       ((re-search-forward "^\\([-+]\\)[ \t\n\f\r]*\\(([^)]*)\\)?\\s-*" nil t)
	(change-log-get-method-definition-1 "")
	(while (not (looking-at "[{;]"))
	  (looking-at
	   "\\([A-Za-z_]*:?\\)\\s-*\\(([^)]*)\\)?[A-Za-z_]*[ \t\n\f\r]*")
	  (change-log-get-method-definition-1 ""))
	(concat change-log-get-method-definition-md "]"))))))


(provide 'add-log)

;;; add-log.el ends here
