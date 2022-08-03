;;; nnheader.el --- header access macros for Gnus and its backends
;; Copyright (C) 1987,88,89,90,93,94,95,96,97,98 Free Software Foundation, Inc.

;; Author: Masanobu UMEDA <umerin@flab.flab.fujitsu.junet>
;; 	Lars Magne Ingebrigtsen <larsi@gnus.org>
;; Keywords: news

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

;; These macros may look very much like the ones in GNUS 4.1.  They
;; are, in a way, but you should note that the indices they use have
;; been changed from the internal GNUS format to the NOV format.  The
;; makes it possible to read headers from XOVER much faster.
;;
;; The format of a header is now:
;; [number subject from date id references chars lines xref]
;;
;; (That last entry is defined as "misc" in the NOV format, but Gnus
;; uses it for xrefs.)

;;; Code:

(eval-when-compile (require 'cl))

(eval-when-compile (require 'cl))

(require 'mail-utils)

(defvar nnheader-max-head-length 4096
  "*Max length of the head of articles.")

(defvar nnheader-head-chop-length 2048
  "*Length of each read operation when trying to fetch HEAD headers.")

(defvar nnheader-file-name-translation-alist nil
  "*Alist that says how to translate characters in file names.
For instance, if \":\" is illegal as a file character in file names
on your system, you could say something like:

\(setq nnheader-file-name-translation-alist '((?: . ?_)))")

(eval-and-compile
 (autoload 'nnmail-message-id "nnmail")
 (autoload 'mail-position-on-field "sendmail")
 (autoload 'message-remove-header "message")
 (autoload 'cancel-function-timers "timers")
 (autoload 'gnus-point-at-eol "gnus-util")
 (autoload 'gnus-delete-line "gnus-util")
 (autoload 'gnus-buffer-live-p "gnus-util")
 (autoload 'gnus-encode-coding-string "gnus-ems"))

;;; Header access macros.

(defmacro mail-header-number (header)
  "Return article number in HEADER."
  `(aref ,header 0))

(defmacro mail-header-set-number (header number)
  "Set article number of HEADER to NUMBER."
  `(aset ,header 0 ,number))

(defmacro mail-header-subject (header)
  "Return subject string in HEADER."
  `(aref ,header 1))

(defmacro mail-header-set-subject (header subject)
  "Set article subject of HEADER to SUBJECT."
  `(aset ,header 1 ,subject))

(defmacro mail-header-from (header)
  "Return author string in HEADER."
  `(aref ,header 2))

(defmacro mail-header-set-from (header from)
  "Set article author of HEADER to FROM."
  `(aset ,header 2 ,from))

(defmacro mail-header-date (header)
  "Return date in HEADER."
  `(aref ,header 3))

(defmacro mail-header-set-date (header date)
  "Set article date of HEADER to DATE."
  `(aset ,header 3 ,date))

(defalias 'mail-header-message-id 'mail-header-id)
(defmacro mail-header-id (header)
  "Return Id in HEADER."
  `(aref ,header 4))

(defalias 'mail-header-set-message-id 'mail-header-set-id)
(defmacro mail-header-set-id (header id)
  "Set article Id of HEADER to ID."
  `(aset ,header 4 ,id))

(defmacro mail-header-references (header)
  "Return references in HEADER."
  `(aref ,header 5))

(defmacro mail-header-set-references (header ref)
  "Set article references of HEADER to REF."
  `(aset ,header 5 ,ref))

(defmacro mail-header-chars (header)
  "Return number of chars of article in HEADER."
  `(aref ,header 6))

(defmacro mail-header-set-chars (header chars)
  "Set number of chars in article of HEADER to CHARS."
  `(aset ,header 6 ,chars))

(defmacro mail-header-lines (header)
  "Return lines in HEADER."
  `(aref ,header 7))

(defmacro mail-header-set-lines (header lines)
  "Set article lines of HEADER to LINES."
  `(aset ,header 7 ,lines))

(defmacro mail-header-xref (header)
  "Return xref string in HEADER."
  `(aref ,header 8))

(defmacro mail-header-set-xref (header xref)
  "Set article xref of HEADER to xref."
  `(aset ,header 8 ,xref))

(defun make-mail-header (&optional init)
  "Create a new mail header structure initialized with INIT."
  (make-vector 9 init))

(defun make-full-mail-header (&optional number subject from date id
					references chars lines xref)
  "Create a new mail header structure initialized with the parameters given."
  (vector number subject from date id references chars lines xref))

;; fake message-ids: generation and detection

(defvar nnheader-fake-message-id 1)

(defsubst nnheader-generate-fake-message-id ()
  (concat "fake+none+" (int-to-string (incf nnheader-fake-message-id))))

(defsubst nnheader-fake-message-id-p (id)
  (save-match-data			; regular message-id's are <.*>
    (string-match "\\`fake\\+none\\+[0-9]+\\'" id)))

;; Parsing headers and NOV lines.

(defsubst nnheader-header-value ()
  (buffer-substring (match-end 0) (gnus-point-at-eol)))

(defun nnheader-parse-head (&optional naked)
  (let ((case-fold-search t)
	(cur (current-buffer))
	(buffer-read-only nil)
	in-reply-to lines p ref)
    (goto-char (point-min))
    (when naked
      (insert "\n"))
    ;; Search to the beginning of the next header.  Error messages
    ;; do not begin with 2 or 3.
    (prog1
	(when (or naked (re-search-forward "^[23][0-9]+ " nil t))
	  ;; This implementation of this function, with nine
	  ;; search-forwards instead of the one re-search-forward and
	  ;; a case (which basically was the old function) is actually
	  ;; about twice as fast, even though it looks messier.	 You
	  ;; can't have everything, I guess.  Speed and elegance
	  ;; don't always go hand in hand.
	  (vector
	   ;; Number.
	   (if naked
	       (progn
		 (setq p (point-min))
		 0)
	     (prog1
		 (read cur)
	       (end-of-line)
	       (setq p (point))
	       (narrow-to-region (point)
				 (or (and (search-forward "\n.\n" nil t)
					  (- (point) 2))
				     (point)))))
	   ;; Subject.
	   (progn
	     (goto-char p)
	     (if (search-forward "\nsubject: " nil t)
		 (nnheader-header-value) "(none)"))
	   ;; From.
	   (progn
	     (goto-char p)
	     (if (search-forward "\nfrom: " nil t)
		 (nnheader-header-value) "(nobody)"))
	   ;; Date.
	   (progn
	     (goto-char p)
	     (if (search-forward "\ndate: " nil t)
		 (nnheader-header-value) ""))
	   ;; Message-ID.
	   (progn
	     (goto-char p)
	     (if (search-forward "\nmessage-id:" nil t)
		 (buffer-substring
		  (1- (or (search-forward "<" (gnus-point-at-eol) t)
			  (point)))
		  (or (search-forward ">" (gnus-point-at-eol) t) (point)))
	       ;; If there was no message-id, we just fake one to make
	       ;; subsequent routines simpler.
	       (nnheader-generate-fake-message-id)))
	   ;; References.
	   (progn
	     (goto-char p)
	     (if (search-forward "\nreferences: " nil t)
		 (nnheader-header-value)
	       ;; Get the references from the in-reply-to header if there
	       ;; were no references and the in-reply-to header looks
	       ;; promising.
	       (if (and (search-forward "\nin-reply-to: " nil t)
			(setq in-reply-to (nnheader-header-value))
			(string-match "<[^>]+>" in-reply-to))
		   (let (ref2)
		     (setq ref (substring in-reply-to (match-beginning 0)
					  (match-end 0)))
		     (while (string-match "<[^>]+>" in-reply-to (match-end 0))
		       (setq ref2 (substring in-reply-to (match-beginning 0)
					     (match-end 0)))
		       (when (> (length ref2) (length ref))
			 (setq ref ref2)))
                     ref)
		 nil)))
	   ;; Chars.
	   0
	   ;; Lines.
	   (progn
	     (goto-char p)
	     (if (search-forward "\nlines: " nil t)
		 (if (numberp (setq lines (read cur)))
		     lines 0)
	       0))
	   ;; Xref.
	   (progn
	     (goto-char p)
	     (and (search-forward "\nxref: " nil t)
		  (nnheader-header-value)))))
      (when naked
	(goto-char (point-min))
	(delete-char 1)))))

(defmacro nnheader-nov-skip-field ()
  '(search-forward "\t" eol 'move))

(defmacro nnheader-nov-field ()
  '(buffer-substring (point) (if (nnheader-nov-skip-field) (1- (point)) eol)))

(defmacro nnheader-nov-read-integer ()
  '(prog1
       (if (= (following-char) ?\t)
	   0
	 (let ((num (ignore-errors (read (current-buffer)))))
	   (if (numberp num) num 0)))
     (or (eobp) (forward-char 1))))

;; (defvar nnheader-none-counter 0)

(defun nnheader-parse-nov ()
  (let ((eol (gnus-point-at-eol)))
    (vector
     (nnheader-nov-read-integer)	; number
     (nnheader-nov-field)		; subject
     (nnheader-nov-field)		; from
     (nnheader-nov-field)		; date
     (or (nnheader-nov-field)
	 (nnheader-generate-fake-message-id)) ; id
     (nnheader-nov-field)		; refs
     (nnheader-nov-read-integer)	; chars
     (nnheader-nov-read-integer)	; lines
     (if (= (following-char) ?\n)
	 nil
       (nnheader-nov-field))		; misc
     )))

(defun nnheader-insert-nov (header)
  (princ (mail-header-number header) (current-buffer))
  (insert
   "\t"
   (or (mail-header-subject header) "(none)") "\t"
   (or (mail-header-from header) "(nobody)") "\t"
   (or (mail-header-date header) "") "\t"
   (or (mail-header-id header)
       (nnmail-message-id))
   "\t"
   (or (mail-header-references header) "") "\t")
  (princ (or (mail-header-chars header) 0) (current-buffer))
  (insert "\t")
  (princ (or (mail-header-lines header) 0) (current-buffer))
  (insert "\t")
  (when (mail-header-xref header)
    (insert "Xref: " (mail-header-xref header) "\t"))
  (insert "\n"))

(defun nnheader-insert-article-line (article)
  (goto-char (point-min))
  (insert "220 ")
  (princ article (current-buffer))
  (insert " Article retrieved.\n")
  (search-forward "\n\n" nil 'move)
  (delete-region (point) (point-max))
  (forward-char -1)
  (insert "."))

(defun nnheader-nov-delete-outside-range (beg end)
  "Delete all NOV lines that lie outside the BEG to END range."
  ;; First we find the first wanted line.
  (nnheader-find-nov-line beg)
  (delete-region (point-min) (point))
  ;; Then we find the last wanted line.
  (when (nnheader-find-nov-line end)
    (forward-line 1))
  (delete-region (point) (point-max)))

(defun nnheader-find-nov-line (article)
  "Put point at the NOV line that start with ARTICLE.
If ARTICLE doesn't exist, put point where that line
would have been.  The function will return non-nil if
the line could be found."
  ;; This function basically does a binary search.
  (let ((max (point-max))
	(min (goto-char (point-min)))
	(cur (current-buffer))
	(prev (point-min))
	num found)
    (while (not found)
      (goto-char (/ (+ max min) 2))
      (beginning-of-line)
      (if (or (= (point) prev)
	      (eobp))
	  (setq found t)
	(setq prev (point))
	(while (and (not (numberp (setq num (read cur))))
		    (not (eobp)))
	  (gnus-delete-line))
	(cond ((> num article)
	       (setq max (point)))
	      ((< num article)
	       (setq min (point)))
	      (t
	       (setq found 'yes)))))
    ;; We may be at the first line.
    (when (and (not num)
	       (not (eobp)))
      (setq num (read cur)))
    ;; Now we may have found the article we're looking for, or we
    ;; may be somewhere near it.
    (when (and (not (eq found 'yes))
	       (not (eq num article)))
      (setq found (point))
      (while (and (< (point) max)
		  (or (not (numberp num))
		      (< num article)))
	(forward-line 1)
	(setq found (point))
	(or (eobp)
	    (= (setq num (read cur)) article)))
      (unless (eq num article)
	(goto-char found)))
    (beginning-of-line)
    (eq num article)))

;; Various cruft the backends and Gnus need to communicate.

(defvar nntp-server-buffer nil)
(defvar gnus-verbose-backends 7
  "*A number that says how talkative the Gnus backends should be.")
(defvar gnus-nov-is-evil nil
  "If non-nil, Gnus backends will never output headers in the NOV format.")
(defvar news-reply-yank-from nil)
(defvar news-reply-yank-message-id nil)

(defvar nnheader-callback-function nil)

(defun nnheader-init-server-buffer ()
  "Initialize the Gnus-backend communication buffer."
  (save-excursion
    (unless (gnus-buffer-live-p nntp-server-buffer)
      (setq nntp-server-buffer (get-buffer-create " *nntpd*")))
    (set-buffer nntp-server-buffer)
    (erase-buffer)
    (kill-all-local-variables)
    (setq case-fold-search t)		;Should ignore case.
    t))

;;; Various functions the backends use.

(defun nnheader-file-error (file)
  "Return a string that says what is wrong with FILE."
  (format
   (cond
    ((not (file-exists-p file))
     "%s does not exist")
    ((file-directory-p file)
     "%s is a directory")
    ((not (file-readable-p file))
     "%s is not readable"))
   file))

(defun nnheader-insert-head (file)
  "Insert the head of the article."
  (when (file-exists-p file)
    (if (eq nnheader-max-head-length t)
	;; Just read the entire file.
	(nnheader-insert-file-contents file)
      ;; Read 1K blocks until we find a separator.
      (let ((beg 0)
	    format-alist)
	(while (and (eq nnheader-head-chop-length
			(nth 1 (nnheader-insert-file-contents
				file nil beg
				(incf beg nnheader-head-chop-length))))
		    (prog1 (not (search-forward "\n\n" nil t))
		      (goto-char (point-max)))
		    (or (null nnheader-max-head-length)
			(< beg nnheader-max-head-length))))))
    t))

(defun nnheader-article-p ()
  "Say whether the current buffer looks like an article."
  (goto-char (point-min))
  (if (not (search-forward "\n\n" nil t))
      nil
    (narrow-to-region (point-min) (1- (point)))
    (goto-char (point-min))
    (while (looking-at "[A-Z][^ \t]+:.*\n\\([ \t].*\n\\)*\\|From .*\n")
      (goto-char (match-end 0)))
    (prog1
	(eobp)
      (widen))))

(defun nnheader-insert-references (references message-id)
  "Insert a References header based on REFERENCES and MESSAGE-ID."
  (if (and (not references) (not message-id))
      ()				; This is illegal, but not all articles have Message-IDs.
    (mail-position-on-field "References")
    (let ((begin (save-excursion (beginning-of-line) (point)))
	  (fill-column 78)
	  (fill-prefix "\t"))
      (when references
	(insert references))
      (when (and references message-id)
	(insert " "))
      (when message-id
	(insert message-id))
      ;; Fold long References lines to conform to RFC1036 (sort of).
      ;; The region must end with a newline to fill the region
      ;; without inserting extra newline.
      (fill-region-as-paragraph begin (1+ (point))))))

(defun nnheader-replace-header (header new-value)
  "Remove HEADER and insert the NEW-VALUE."
  (save-excursion
    (save-restriction
      (nnheader-narrow-to-headers)
      (prog1
	  (message-remove-header header)
	(goto-char (point-max))
	(insert header ": " new-value "\n")))))

(defun nnheader-narrow-to-headers ()
  "Narrow to the head of an article."
  (widen)
  (narrow-to-region
   (goto-char (point-min))
   (if (search-forward "\n\n" nil t)
       (1- (point))
     (point-max)))
  (goto-char (point-min)))

(defun nnheader-set-temp-buffer (name &optional noerase)
  "Set-buffer to an empty (possibly new) buffer called NAME with undo disabled."
  (set-buffer (get-buffer-create name))
  (buffer-disable-undo (current-buffer))
  (unless noerase
    (erase-buffer))
  (current-buffer))

(defmacro nnheader-temp-write (file &rest forms)
  "Create a new buffer, evaluate FORMS there, and write the buffer to FILE.
Return the value of FORMS.
If FILE is nil, just evaluate FORMS and don't save anything.
If FILE is t, return the buffer contents as a string."
  (let ((temp-file (make-symbol "temp-file"))
	(temp-buffer (make-symbol "temp-buffer"))
	(temp-results (make-symbol "temp-results")))
    `(save-excursion
       (let* ((,temp-file ,file)
	      (default-major-mode 'fundamental-mode)
	      (,temp-buffer
	       (set-buffer
		(get-buffer-create
		 (generate-new-buffer-name " *nnheader temp*"))))
	      ,temp-results)
	 (unwind-protect
	     (progn
	       (setq ,temp-results (progn ,@forms))
	       (cond
		;; Don't save anything.
		((null ,temp-file)
		 ,temp-results)
		;; Return the buffer contents.
		((eq ,temp-file t)
		 (set-buffer ,temp-buffer)
		 (buffer-string))
		;; Save a file.
		(t
		 (set-buffer ,temp-buffer)
		 ;; Make sure the directory where this file is
		 ;; to be saved exists.
		 (when (not (file-directory-p
			     (file-name-directory ,temp-file)))
		   (make-directory (file-name-directory ,temp-file) t))
		 ;; Save the file.
		 (write-region (point-min) (point-max)
			       ,temp-file nil 'nomesg)
		 ,temp-results)))
	   ;; Kill the buffer.
	   (when (buffer-name ,temp-buffer)
	     (kill-buffer ,temp-buffer)))))))

(put 'nnheader-temp-write 'lisp-indent-function 1)
(put 'nnheader-temp-write 'edebug-form-spec '(form body))

(defvar jka-compr-compression-info-list)
(defvar nnheader-numerical-files
  (if (boundp 'jka-compr-compression-info-list)
      (concat "\\([0-9]+\\)\\("
	      (mapconcat (lambda (i) (aref i 0))
			 jka-compr-compression-info-list "\\|")
	      "\\)?")
    "[0-9]+$")
  "Regexp that match numerical files.")

(defvar nnheader-numerical-short-files (concat "^" nnheader-numerical-files)
  "Regexp that matches numerical file names.")

(defvar nnheader-numerical-full-files (concat "/" nnheader-numerical-files)
  "Regexp that matches numerical full file paths.")

(defsubst nnheader-file-to-number (file)
  "Take a file name and return the article number."
  (if (string= nnheader-numerical-short-files "^[0-9]+$")
      (string-to-int file)
    (string-match nnheader-numerical-short-files file)
    (string-to-int (match-string 0 file))))

(defun nnheader-directory-files-safe (&rest args)
  ;; It has been reported numerous times that `directory-files'
  ;; fails with an alarming frequency on NFS mounted file systems.
  ;; This function executes that function twice and returns
  ;; the longest result.
  (let ((first (apply 'directory-files args))
	(second (apply 'directory-files args)))
    (if (> (length first) (length second))
	first
      second)))

(defun nnheader-directory-articles (dir)
  "Return a list of all article files in a directory."
  (mapcar 'nnheader-file-to-number
	  (nnheader-directory-files-safe
	   dir nil nnheader-numerical-short-files t)))

(defun nnheader-article-to-file-alist (dir)
  "Return an alist of article/file pairs in DIR."
  (mapcar (lambda (file) (cons (nnheader-file-to-number file) file))
	  (nnheader-directory-files-safe
	   dir nil nnheader-numerical-short-files t)))

(defun nnheader-fold-continuation-lines ()
  "Fold continuation lines in the current buffer."
  (nnheader-replace-regexp "\\(\r?\n[ \t]+\\)+" " "))

(defun nnheader-translate-file-chars (file &optional full)
  "Translate FILE into something that can be a file name.
If FULL, translate everything."
  (if (null nnheader-file-name-translation-alist)
      ;; No translation is necessary.
      file
    (let* ((i 0)
	   trans leaf path len)
      (if full
	  ;; Do complete translation.
	  (setq leaf (copy-sequence file)
		path "")
	;; We translate -- but only the file name.  We leave the directory
	;; alone.
	(if (string-match "/[^/]+\\'" file)
	    ;; This is needed on NT's and stuff.
	    (setq leaf (substring file (1+ (match-beginning 0)))
		  path (substring file 0 (1+ (match-beginning 0))))
	  ;; Fall back on this.
	  (setq leaf (file-name-nondirectory file)
		path (file-name-directory file))))
      (setq len (length leaf))
      (while (< i len)
	(when (setq trans (cdr (assq (aref leaf i)
				     nnheader-file-name-translation-alist)))
	  (aset leaf i trans))
	(incf i))
      (concat path leaf))))

(defun nnheader-report (backend &rest args)
  "Report an error from the BACKEND.
The first string in ARGS can be a format string."
  (set (intern (format "%s-status-string" backend))
       (if (< (length args) 2)
	   (car args)
	 (apply 'format args)))
  nil)

(defun nnheader-get-report (backend)
  "Get the most recent report from BACKEND."
  (condition-case ()
      (nnheader-message 5 "%s" (symbol-value (intern (format "%s-status-string"
						  backend))))
    (error (nnheader-message 5 ""))))

(defun nnheader-insert (format &rest args)
  "Clear the communication buffer and insert FORMAT and ARGS into the buffer.
If FORMAT isn't a format string, it and all ARGS will be inserted
without formatting."
  (save-excursion
    (set-buffer nntp-server-buffer)
    (erase-buffer)
    (if (string-match "%" format)
	(insert (apply 'format format args))
      (apply 'insert format args))
    t))

(defun nnheader-replace-chars-in-string (string from to)
  "Replace characters in STRING from FROM to TO."
  (let ((string (substring string 0))	;Copy string.
	(len (length string))
	(idx 0))
    ;; Replace all occurrences of FROM with TO.
    (while (< idx len)
      (when (= (aref string idx) from)
	(aset string idx to))
      (setq idx (1+ idx)))
    string))

(defun nnheader-file-to-group (file &optional top)
  "Return a group name based on FILE and TOP."
  (nnheader-replace-chars-in-string
   (if (not top)
       file
     (condition-case ()
	 (substring (expand-file-name file)
		    (length
		     (expand-file-name
		      (file-name-as-directory top))))
       (error "")))
   ?/ ?.))

(defun nnheader-message (level &rest args)
  "Message if the Gnus backends are talkative."
  (if (or (not (numberp gnus-verbose-backends))
	  (<= level gnus-verbose-backends))
      (apply 'message args)
    (apply 'format args)))

(defun nnheader-be-verbose (level)
  "Return whether the backends should be verbose on LEVEL."
  (or (not (numberp gnus-verbose-backends))
      (<= level gnus-verbose-backends)))

(defvar nnheader-pathname-coding-system 'iso-8859-1
  "*Coding system for pathname.")

;; 1997/8/10 by MORIOKA Tomohiko
(defvar nnheader-pathname-coding-system
  'iso-8859-1
  "*Coding system for pathname.")

(defun nnheader-group-pathname (group dir &optional file)
  "Make pathname for GROUP."
  (concat
   (let ((dir (file-name-as-directory (expand-file-name dir))))
     ;; If this directory exists, we use it directly.
     (if (file-directory-p (concat dir group))
	 (concat dir group "/")
       ;; If not, we translate dots into slashes.
       (concat dir
	       (gnus-encode-coding-string
		(nnheader-replace-chars-in-string group ?. ?/)
		nnheader-pathname-coding-system)
	       "/")))
   (cond ((null file) "")
	 ((numberp file) (int-to-string file))
	 (t file))))

(defun nnheader-functionp (form)
  "Return non-nil if FORM is funcallable."
  (or (and (symbolp form) (fboundp form))
      (and (listp form) (eq (car form) 'lambda))))

(defun nnheader-concat (dir &rest files)
  "Concat DIR as directory to FILE."
  (apply 'concat (file-name-as-directory dir) files))

(defun nnheader-ms-strip-cr ()
  "Strip ^M from the end of all lines."
  (save-excursion
    (goto-char (point-min))
    (while (re-search-forward "\r$" nil t)
      (delete-backward-char 1))))

(defun nnheader-file-size (file)
  "Return the file size of FILE or 0."
  (or (nth 7 (file-attributes file)) 0))

(defun nnheader-find-etc-directory (package &optional file)
  "Go through the path and find the \".../etc/PACKAGE\" directory.
If FILE, find the \".../etc/PACKAGE\" file instead."
  (let ((path load-path)
	dir result)
    ;; We try to find the dir by looking at the load path,
    ;; stripping away the last component and adding "etc/".
    (while path
      (if (and (car path)
	       (file-exists-p
		(setq dir (concat
			   (file-name-directory
			    (directory-file-name (car path)))
			   "etc/" package
			   (if file "" "/"))))
	       (or file (file-directory-p dir)))
	  (setq result dir
		path nil)
	(setq path (cdr path))))
    result))

(defvar ange-ftp-path-format)
(defvar efs-path-regexp)
(defun nnheader-re-read-dir (path)
  "Re-read directory PATH if PATH is on a remote system."
  (if (and (fboundp 'efs-re-read-dir) (boundp 'efs-path-regexp))
      (when (string-match efs-path-regexp path)
	(efs-re-read-dir path))
    (when (and (fboundp 'ange-ftp-re-read-dir) (boundp 'ange-ftp-path-format))
      (when (string-match (car ange-ftp-path-format) path)
	(ange-ftp-re-read-dir path)))))

(defvar nnheader-file-coding-system 'raw-text
  "Coding system used in file backends of Gnus.")

;; 1997/5/4 by MORIOKA Tomohiko <morioka@jaist.ac.jp>
(defvar nnheader-file-coding-system nil
  "Coding system used in file backends of Gnus.")

(defun nnheader-insert-file-contents (filename &optional visit beg end replace)
  "Like `insert-file-contents', q.v., but only reads in the file.
A buffer may be modified in several ways after reading into the buffer due
to advanced Emacs features, such as file-name-handlers, format decoding,
find-file-hooks, etc.
  This function ensures that none of these modifications will take place."
  (let ((format-alist nil)
	(auto-mode-alist (nnheader-auto-mode-alist))
	(default-major-mode 'fundamental-mode)
	(enable-local-variables nil)
        (after-insert-file-functions nil)
	(find-file-hooks nil)
	(coding-system-for-read nnheader-file-coding-system))
    (insert-file-contents filename visit beg end replace)))

(defun nnheader-find-file-noselect (&rest args)
  (let ((format-alist nil)
	(auto-mode-alist (nnheader-auto-mode-alist))
	(default-major-mode 'fundamental-mode)
	(enable-local-variables nil)
        (after-insert-file-functions nil)
	(find-file-hooks nil)
	(coding-system-for-read nnheader-file-coding-system))
    (apply 'find-file-noselect args)))

(defun nnheader-auto-mode-alist ()
  "Return an `auto-mode-alist' with only the .gz (etc) thingies."
  (let ((alist auto-mode-alist)
	out)
    (while alist
      (when (listp (cdar alist))
	(push (car alist) out))
      (pop alist))
    (nreverse out)))

(defun nnheader-directory-regular-files (dir)
  "Return a list of all regular files in DIR."
  (let ((files (directory-files dir t))
	out)
    (while files
      (when (file-regular-p (car files))
	(push (car files) out))
      (pop files))
    (nreverse out)))

(defun nnheader-directory-files (&rest args)
  "Same as `directory-files', but prune \".\" and \"..\"."
  (let ((files (apply 'directory-files args))
	out)
    (while files
      (unless (member (file-name-nondirectory (car files)) '("." ".."))
	(push (car files) out))
      (pop files))
    (nreverse out)))

(defmacro nnheader-skeleton-replace (from &optional to regexp)
  `(let ((new (generate-new-buffer " *nnheader replace*"))
	 (cur (current-buffer))
	 (start (point-min)))
     (set-buffer new)
     (buffer-disable-undo (current-buffer))
     (set-buffer cur)
     (goto-char (point-min))
     (while (,(if regexp 're-search-forward 'search-forward)
	     ,from nil t)
       (insert-buffer-substring
	cur start (prog1 (match-beginning 0) (set-buffer new)))
       (goto-char (point-max))
       ,(when to `(insert ,to))
       (set-buffer cur)
       (setq start (point)))
     (insert-buffer-substring
      cur start (prog1 (point-max) (set-buffer new)))
     (copy-to-buffer cur (point-min) (point-max))
     (kill-buffer (current-buffer))
     (set-buffer cur)))

(defun nnheader-replace-string (from to)
  "Do a fast replacement of FROM to TO from point to point-max."
  (nnheader-skeleton-replace from to))

(defun nnheader-replace-regexp (from to)
  "Do a fast regexp replacement of FROM to TO from point to point-max."
  (nnheader-skeleton-replace from to t))

(defun nnheader-strip-cr ()
  "Strip all \r's from the current buffer."
  (nnheader-skeleton-replace "\r"))

(fset 'nnheader-run-at-time 'run-at-time)
(fset 'nnheader-cancel-timer 'cancel-timer)
(fset 'nnheader-cancel-function-timers 'cancel-function-timers)

(when (string-match "XEmacs\\|Lucid" emacs-version)
  (require 'nnheaderxm))

(run-hooks 'nnheader-load-hook)

(provide 'nnheader)

;;; nnheader.el ends here
