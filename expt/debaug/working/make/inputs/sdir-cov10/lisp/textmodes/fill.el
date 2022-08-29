;;; fill.el --- fill commands for Emacs

;; Copyright (C) 1985, 86, 92, 94, 95, 96, 1997 Free Software Foundation, Inc.

;; Keywords: wp

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

;; All the commands for filling text.  These are documented in the Emacs
;; manual.

;;; Code:

(defcustom fill-individual-varying-indent nil
  "*Controls criterion for a new paragraph in `fill-individual-paragraphs'.
Non-nil means changing indent doesn't end a paragraph.
That mode can handle paragraphs with extra indentation on the first line,
but it requires separator lines between paragraphs.
A value of nil means that any change in indentation starts a new paragraph."
  :type 'boolean
  :group 'fill)

(defcustom sentence-end-double-space t
  "*Non-nil means a single space does not end a sentence.

If you change this, you should also change `sentence-end'.
See Info node `Sentences'."
  :type 'boolean
  :group 'fill)

(defcustom colon-double-space nil
  "*Non-nil means put two spaces after a colon when filling."
  :type 'boolean
  :group 'fill)

(defcustom sentence-end-without-period nil
  "*Non-nil means a sentence will end without period.
For example, Thai text ends with double space but without period."
  :type 'boolean
  :group 'fill)

(defvar fill-paragraph-function nil
  "Mode-specific function to fill a paragraph, or nil if there is none.
If the function returns nil, then `fill-paragraph' does its normal work.")

(defvar enable-kinsoku t
  "*Non-nil means enable \"kinsoku\" processing on filling paragraph.
Kinsoku processing is designed to prevent certain characters from being
placed at the beginning or end of a line by filling.
See the documentation of `kinsoku' for more information.")

(defun set-fill-prefix ()
  "Set the fill prefix to the current line up to point.
Filling expects lines to start with the fill prefix and
reinserts the fill prefix in each resulting line."
  (interactive)
  (setq fill-prefix (buffer-substring
		     (save-excursion (move-to-left-margin) (point))
		     (point)))
  (if (equal fill-prefix "")
      (setq fill-prefix nil))
  (if fill-prefix
      (message "fill-prefix: \"%s\"" fill-prefix)
    (message "fill-prefix cancelled")))

(defcustom adaptive-fill-mode t
  "*Non-nil means determine a paragraph's fill prefix from its text."
  :type 'boolean
  :group 'fill)

(defcustom adaptive-fill-regexp "[ \t]*\\([-|#;>*]+ *\\|(?[0-9]+[.)] *\\)*"
  "*Regexp to match text at start of line that constitutes indentation.
If Adaptive Fill mode is enabled, a prefix matching this pattern
on the first and second lines of a paragraph is used as the
standard indentation for the whole paragraph.

If the paragraph has just one line, the indentation is taken from that
line, but in that case `adaptive-fill-first-line-regexp' also plays
a role."
  :type 'regexp
  :group 'fill)

(defcustom adaptive-fill-first-line-regexp "\\`[ \t]*\\'"
  "*Regexp specifying whether to set fill prefix from a one-line paragraph.
When a paragraph has just one line, then after `adaptive-fill-regexp'
finds the prefix at the beginning of the line, if it doesn't
match this regexp, it is replaced with whitespace.

By default, this regexp matches sequences of just spaces and tabs.

However, we never use a prefix from a one-line paragraph
if it would act as a paragraph-starter on the second line."
  :type 'regexp
  :group 'fill)

(defcustom adaptive-fill-function nil
  "*Function to call to choose a fill prefix for a paragraph.
This function is used when `adaptive-fill-regexp' does not match."
  :type 'function
  :group 'fill)

(defun current-fill-column ()
  "Return the fill-column to use for this line.
The fill-column to use for a buffer is stored in the variable `fill-column',
but can be locally modified by the `right-margin' text property, which is
subtracted from `fill-column'.

The fill column to use for a line is the first column at which the column
number equals or exceeds the local fill-column - right-margin difference."
  (save-excursion
    (if fill-column
	(let* ((here (progn (beginning-of-line) (point)))
	       (here-col 0)
	       (eol (progn (end-of-line) (point)))
	       margin fill-col change col)
	  ;; Look separately at each region of line with a different right-margin.
	  (while (and (setq margin (get-text-property here 'right-margin)
			    fill-col (- fill-column (or margin 0))
			    change (text-property-not-all
				    here eol 'right-margin margin))
		      (progn (goto-char (1- change))
			     (setq col (current-column))
			     (< col fill-col)))
	    (setq here change
		  here-col col))
	  (max here-col fill-col)))))

(defun canonically-space-region (beg end)
  "Remove extra spaces between words in region.
Leave one space between words, two at end of sentences or after colons
\(depending on values of `sentence-end-double-space', `colon-double-space',
and `sentence-end-without-period').
Remove indentation from each line."
  (interactive "r")
  (save-excursion
    (goto-char beg)
    ;; Nuke tabs; they get screwed up in a fill.
    ;; This is quick, but loses when a tab follows the end of a sentence.
    ;; Actually, it is difficult to tell that from "Mr.\tSmith".
    ;; Blame the typist.
    (subst-char-in-region beg end ?\t ?\ )
    (while (and (< (point) end)
		(re-search-forward "   *" end t))
      (delete-region
       (+ (match-beginning 0)
	  ;; Determine number of spaces to leave:
	  (save-excursion
	    (skip-chars-backward " ]})\"'")
	    (cond ((and sentence-end-double-space
			(or (memq (preceding-char) '(?. ?? ?!))
			    (and sentence-end-without-period
				 (= (char-syntax (preceding-char)) ?w)))) 2)
		  ((and colon-double-space
			(= (preceding-char) ?:))  2)
		  ((char-equal (preceding-char) ?\n)  0)
		  (t 1))))
       (match-end 0)))
    ;; Make sure sentences ending at end of line get an extra space.
    ;; loses on split abbrevs ("Mr.\nSmith")
    (goto-char beg)
    (while (and (< (point) end)
		(re-search-forward "[.?!][])}\"']*$" end t))
      ;; We insert before markers in case a caller such as
      ;; do-auto-fill has done a save-excursion with point at the end
      ;; of the line and wants it to stay at the end of the line.
      (insert-before-markers-and-inherit ? ))))

(defun fill-context-prefix (from to &optional first-line-regexp)
  "Compute a fill prefix from the text between FROM and TO.
This uses the variables `adaptive-fill-prefix' and `adaptive-fill-function'
and `adaptive-fill-first-line-regexp'.  `paragraph-start' also plays a role;
we reject a prefix based on a one-line paragraph if that prefix would
act as a paragraph-separator."
  (or first-line-regexp
      (setq first-line-regexp adaptive-fill-first-line-regexp))
  (save-excursion
    (goto-char from)
    (if (eolp) (forward-line 1))
    ;; Move to the second line unless there is just one.
    (let ((firstline (point))
	  first-line-prefix
	  ;; Non-nil if we are on the second line.
	  at-second
	  second-line-prefix
	  start)
      (move-to-left-margin)
      (setq start (point))
      (setq first-line-prefix
	    (cond ((looking-at paragraph-start) nil)
		  ((and adaptive-fill-regexp (looking-at adaptive-fill-regexp))
		   (buffer-substring-no-properties start (match-end 0)))
		  (adaptive-fill-function (funcall adaptive-fill-function))))
      (forward-line 1)
      (if (>= (point) to)
	  (goto-char firstline)
	(setq at-second t)
	(move-to-left-margin)
	(setq start (point))
	(setq second-line-prefix
	      (cond ((looking-at paragraph-start) nil)
		    ((and adaptive-fill-regexp (looking-at adaptive-fill-regexp))
		     (buffer-substring-no-properties start (match-end 0)))
		    (adaptive-fill-function (funcall adaptive-fill-function)))))
      (if at-second
	  ;; If we get a fill prefix from the second line,
	  ;; make sure it or something compatible is on the first line too.
	  (and second-line-prefix first-line-prefix
	       ;; If the first line has the second line prefix too, use it.
	       (if (or (string-match (concat "\\`"
					     (regexp-quote second-line-prefix)
					     "\\(\\'\\|[ \t]\\)")
				     first-line-prefix)
		       ;; If the second line prefix is whitespace, use it.
		       (string-match "\\`[ \t]+\\'" second-line-prefix))
		   second-line-prefix
		 ;; If the second line has the first line prefix,
		 ;; plus whitespace, use the part that the first line shares.
		 (if (string-match (concat "\\`"
					     (regexp-quote first-line-prefix)
					     "[ \t]*\\'")
				   second-line-prefix)
		     first-line-prefix)))
	;; If we get a fill prefix from a one-line paragraph,
	;; maybe change it to whitespace,
	;; and check that it isn't a paragraph starter.
	(if first-line-prefix
	    (let ((result
		   ;; If first-line-prefix comes from the first line,
		   ;; see if it seems reasonable to use for all lines.
		   ;; If not, replace it with whitespace.
		   (if (or (and first-line-regexp
				(string-match first-line-regexp
					      first-line-prefix))
			   (and comment-start-skip
				(string-match comment-start-skip
					      first-line-prefix)))
		       first-line-prefix
		     (make-string (string-width first-line-prefix) ?\ ))))
	      ;; But either way, reject it if it indicates the start
	      ;; of a paragraph when text follows it.
	      (if (not (eq 0 (string-match paragraph-start
					   (concat result "a"))))
		  result)))))))

(defvar fill-nobreak-predicate nil
  "If non-nil, a predicate for recognizing places not to break a line.
The predicate is called with no arguments, with point at the place
to be tested.  If it returns t, fill commands do not break the line there.")

;; Put `fill-find-break-point-function' property to charsets which
;; require special functions to find line breaking point.
(let ((alist '((katakana-jisx0201 . kinsoku)
	       (chinese-gb2312 . kinsoku)
	       (japanese-jisx0208 . kinsoku)
	       (japanese-jisx0212 . kinsoku)
	       (chinese-big5-1 . kinsoku)
	       (chinese-big5-2 . kinsoku))))
  (while alist
    (put-charset-property (car (car alist)) 'fill-find-break-point-function
			  (cdr (car alist)))
    (setq alist (cdr alist))))

(defun fill-find-break-point (limit)
  "Move point to a proper line breaking position of the current line.
Don't move back past the buffer position LIMIT.

This function is called when we are going to break the current line
after or before a non-ascii character.  If the charset of the
character has the property `fill-find-break-point-function', this
function calls the property value as a function with one arg LINEBEG.
If the charset has no such property, do nothing."
  (let* ((ch (following-char))
	 (charset (char-charset ch))
	 func)
    (if (eq charset 'ascii)
	(setq ch (preceding-char)
	      charset (char-charset ch)))
    (if (eq charset 'ascii)
	nil
      (if (eq charset 'composition)
	  (setq charset (char-charset (composite-char-component ch 0)))))
    (if (charsetp charset)
	(setq func
	      (get-charset-property charset 'fill-find-break-point-function)))
  (if (and func (fboundp func))
      (funcall func limit))))

(defun fill-region-as-paragraph (from to &optional justify
				      nosqueeze squeeze-after)
  "Fill the region as one paragraph.
It removes any paragraph breaks in the region and extra newlines at the end,
indents and fills lines between the margins given by the
`current-left-margin' and `current-fill-column' functions.
\(In most cases, the variable `fill-column' controls the width.)
It leaves point at the beginning of the line following the paragraph.

Normally performs justification according to the `current-justification'
function, but with a prefix arg, does full justification instead.

From a program, optional third arg JUSTIFY can specify any type of
justification.  Fourth arg NOSQUEEZE non-nil means not to make spaces
between words canonical before filling.  Fifth arg SQUEEZE-AFTER, if non-nil,
means don't canonicalize spaces before that position.

If `sentence-end-double-space' is non-nil, then period followed by one
space does not end a sentence, so don't break a line there."
  (interactive (list (region-beginning) (region-end)
		     (if current-prefix-arg 'full)))
  (unless (memq justify '(t nil none full center left right))
    (setq justify 'full))
  ;; Arrange for undoing the fill to restore point.
  (if (and buffer-undo-list (not (eq buffer-undo-list t)))
      (setq buffer-undo-list (cons (point) buffer-undo-list)))

  ;; Make sure "to" is the endpoint.
  (goto-char (min from to))
  (setq to   (max from to))
  ;; Ignore blank lines at beginning of region.
  (skip-chars-forward " \t\n")

  (let ((from-plus-indent (point))
	(oneleft nil))

    (beginning-of-line)
    (setq from (point))
  
    ;; Delete all but one soft newline at end of region.
    ;; And leave TO before that one.
    (goto-char to)
    (while (and (> (point) from) (eq ?\n (char-after (1- (point)))))
      (if (and oneleft
	       (not (and use-hard-newlines
			 (get-text-property (1- (point)) 'hard))))
	  (delete-backward-char 1)
	(backward-char 1)
	(setq oneleft t)))
    (setq to (point))
;;;     ;; If there was no newline, and there is text in the paragraph, then
;;;     ;; create a newline.
;;;     (if (and (not oneleft) (> to from-plus-indent))
;;; 	(newline))
    (goto-char from-plus-indent))

  (if (not (> to (point)))
      nil ; There is no paragraph, only whitespace: exit now.

    (or justify (setq justify (current-justification)))

    ;; Don't let Adaptive Fill mode alter the fill prefix permanently.
    (let ((fill-prefix fill-prefix))
      ;; Figure out how this paragraph is indented, if desired.
      (if (and adaptive-fill-mode
	       (or (null fill-prefix) (string= fill-prefix "")))
	  (setq fill-prefix (fill-context-prefix from to)))

      (save-restriction
	(goto-char from)
	(beginning-of-line)
	(narrow-to-region (point) to)

	(if (not justify)	    ; filling disabled: just check indentation
	    (progn
	      (goto-char from)
	      (while (not (eobp))
		(if (and (not (eolp))
			 (< (current-indentation) (current-left-margin)))
		    (indent-to-left-margin))
		(forward-line 1)))

	  (if use-hard-newlines
	      (remove-text-properties from (point-max) '(hard nil)))
	  ;; Make sure first line is indented (at least) to left margin...
	  (if (or (memq justify '(right center))
		  (< (current-indentation) (current-left-margin)))
	      (indent-to-left-margin))
	  ;; Delete the fill prefix from every line except the first.
	  ;; The first line may not even have a fill prefix.
	  (goto-char from)
	  (let ((fpre (and fill-prefix (not (equal fill-prefix ""))
			   (concat "[ \t]*"
				   (regexp-quote fill-prefix)
				   "[ \t]*"))))
	    (and fpre
		 (progn
		   (if (>= (+ (current-left-margin) (length fill-prefix))
			   (current-fill-column))
		       (error "fill-prefix too long for specified width"))
		   (goto-char from)
		   (forward-line 1)
		   (while (not (eobp))
		     (if (looking-at fpre)
			 (delete-region (point) (match-end 0)))
		     (forward-line 1))
		   (goto-char from)
		   (if (looking-at fpre)
		       (goto-char (match-end 0)))
		   (setq from (point)))))
	  ;; Remove indentation from lines other than the first.
	  (beginning-of-line 2)
	  (indent-region (point) (point-max) 0)
	  (goto-char from)

	  ;; FROM, and point, are now before the text to fill,
	  ;; but after any fill prefix on the first line.

	  ;; Make sure sentences ending at end of line get an extra space.
	  ;; loses on split abbrevs ("Mr.\nSmith")
	  (while (re-search-forward "[.?!][])}\"']*$" nil t)
	    (or (eobp) (insert-and-inherit ?\ )))

	  (goto-char from)	  
	  (if enable-multibyte-characters
	      ;; Delete unnecessay newlines surrounded by words.  The
	      ;; character category `|' means that we can break a line
	      ;; at the character.  And, charset property
	      ;; `nospace-between-words' tells how to concatenate
	      ;; words.  If the value is non-nil, never put spaces
	      ;; between words, thus delete a newline between them.
	      ;; If the value is nil, delete a newline only when a
	      ;; character preceding a newline has text property
	      ;; `nospace-between-words'.
	      (while (search-forward "\n" nil t)
		(let ((prev (char-before (match-beginning 0)))
		      (next (following-char)))
		  (if (cmpcharp prev)
		      (setq prev (composite-char-component prev 0)))
		  (if (cmpcharp next)
		      (setq next (composite-char-component next 0)))
		  (if (and (or (aref (char-category-set next) ?|)
			       (aref (char-category-set prev) ?|))
			   (or (get-charset-property (char-charset prev)
						     'nospace-between-words)
			       (get-text-property (1- (match-beginning 0))
						  'nospace-between-words)))
		      (delete-char -1)))))

	  (goto-char from)
	  (skip-chars-forward " \t")
	  ;; Then change all newlines to spaces.
	  (subst-char-in-region from (point-max) ?\n ?\ )
	  (if (and nosqueeze (not (eq justify 'full)))
	      nil
	    (canonically-space-region (or squeeze-after (point)) (point-max))
	    (goto-char (point-max))
	    (delete-horizontal-space)
	    (insert-and-inherit " "))
	  (goto-char (point-min))

	  ;; This is the actual filling loop.
	  (let ((prefixcol 0) linebeg)
	    (while (not (eobp))
	      (setq linebeg (point))
	      (move-to-column (1+ (current-fill-column)))
	      (if (eobp)
		  (or nosqueeze (delete-horizontal-space))
		;; Move back to the point where we can break the line
		;; at.  We break the line between word or after/before
		;; the character which has character category `|'.  We
		;; search space, \c| followed by a character, or \c|
		;; following a character.  If not found, place
		;; the point at linebeg.
		(if (re-search-backward " \\|\\c|.\\|.\\c|" linebeg 0)
		    ;; In case of space, we place the point at next to
		    ;; the point where the break occurs acutually,
		    ;; because we don't want to change the following
		    ;; logic of original Emacs.  In case of \c|, the
		    ;; point is at the place where the break occurs.
		    (forward-char 1))
		;; Don't break after a period followed by just one space.
		;; Move back to the previous place to break.
		;; The reason is that if a period ends up at the end of a line,
		;; further fills will assume it ends a sentence.
		;; If we now know it does not end a sentence,
		;; avoid putting it at the end of the line.
		(while (or (and sentence-end-double-space
				(> (point) (+ linebeg 2))
				(eq (preceding-char) ?\ )
				(not (eq (following-char) ?\ ))
				(eq (char-after (- (point) 2)) ?\.)
				(progn (forward-char -2) t))
			   (and fill-nobreak-predicate
				(funcall fill-nobreak-predicate)
				(goto-char (match-beginning 0))))
		  (if (re-search-backward " \\|\\c|.\\|.\\c|" linebeg 0)
		      (forward-char 1)))
		;; If the left margin and fill prefix by themselves
		;; pass the fill-column. or if they are zero
		;; but we have no room for even one word,
		;; keep at least one word or a character which has
		;; category `|'anyway .
		;; This handles ALL BUT the first line of the paragraph.
		(if (if (zerop prefixcol)
			(save-excursion
			  (skip-chars-backward " \t" linebeg)
			  (bolp))
		      (>= prefixcol (current-column)))
		    ;; Ok, skip at least one word or one \c| character.
		    ;; Meanwhile, don't stop at a period followed by one space.
		    (let ((first t))
		      (move-to-column prefixcol)
		      (while (and (not (eobp))
				  (or first
				      (and (not (bobp))
					   sentence-end-double-space
					   (save-excursion (forward-char -1)
							   (and (looking-at "\\. ")
								(not (looking-at "\\.  ")))))
				      (and fill-nobreak-predicate
					   (funcall fill-nobreak-predicate))))
			;; Find a breakable point while ignoring the
			;; following spaces.
			(skip-chars-forward " \t")
			(if (looking-at "\\c|")
			    (forward-char 1)
			  (let ((pos (save-excursion
				       (skip-chars-forward "^ \n\t")
				       (point))))
			    (if (re-search-forward "\\c|" pos t)
				(forward-char -1)
			      (goto-char pos))))
			(setq first nil)))
		  ;; Normally, move back over the single space between the words.
		  (if (= (preceding-char) ?\ ) (forward-char -1))

		  (if enable-multibyte-characters
		      ;; If we are going to break the line after or
		      ;; before a non-ascii character, we may have to
		      ;; run a special function for the charset of the
		      ;; character to find the correct break point.
		      (if (not (and (eq (charset-after (1- (point))) 'ascii)
				    (eq (charset-after (point)) 'ascii)))
			  (fill-find-break-point linebeg))))

		;; If the left margin and fill prefix by themselves
		;; pass the fill-column, keep at least one word.
		;; This handles the first line of the paragraph.
		(if (and (zerop prefixcol)
			 (let ((fill-point (point)) nchars)
			   (save-excursion
			     (move-to-left-margin)
			     (setq nchars (- fill-point (point)))
			     (or (< nchars 0)
				 (and fill-prefix
				      (< nchars (length fill-prefix))
				      (string= (buffer-substring (point) fill-point)
					       (substring fill-prefix 0 nchars)))))))
		    ;; Ok, skip at least one word.  But
		    ;; don't stop at a period followed by just one space.
		    (let ((first t))
		      (while (and (not (eobp))
				  (or first
				      (and (not (bobp))
					   sentence-end-double-space
					   (save-excursion (forward-char -1)
							   (and (looking-at "\\. ")
								(not (looking-at "\\.  ")))))
				      (and fill-nobreak-predicate
					   (funcall fill-nobreak-predicate))))
			;; Find a breakable point while ignoring the
			;; following spaces.
			(skip-chars-forward " \t")
			(if (looking-at "\\c|")
			    (forward-char 1)
			  (let ((pos (save-excursion
				       (skip-chars-forward "^ \n\t")
				       (point))))
			    (if (re-search-forward "\\c|" pos t)
				(forward-char -1)
			      (goto-char pos))))
			(setq first nil))))
		;; Check again to see if we got to the end of the paragraph.
		(if (save-excursion (skip-chars-forward " \t") (eobp))
		    (or nosqueeze (delete-horizontal-space))
		  ;; Replace whitespace here with one newline, then indent to left
		  ;; margin.
		  (skip-chars-backward " \t")
		  (if (and (= (following-char) ?\ )
			   (or (aref (char-category-set (preceding-char)) ?|)
			       (looking-at "[ \t]+\\c|")))
		      ;; We need one space at end of line so that
		      ;; further filling won't delete it.  NOTE: We
		      ;; intentionally leave this one space to
		      ;; distingush the case that user wants to put
		      ;; space between \c| characters.
		      (forward-char 1))
		  (insert ?\n)
		  ;; Give newline the properties of the space(s) it replaces
		  (set-text-properties (1- (point)) (point)
				       (text-properties-at (point)))
		  (indent-to-left-margin)
		  ;; Insert the fill prefix after indentation.
		  ;; Set prefixcol so whitespace in the prefix won't get lost.
		  (and fill-prefix (not (equal fill-prefix ""))
		       (progn
			 (insert-and-inherit fill-prefix)
			 (setq prefixcol (current-column))))))
	      ;; Justify the line just ended, if desired.
	      (if justify
                (if (save-excursion (skip-chars-forward " \t") (eobp))
                    (progn
                      (delete-horizontal-space)
                      (justify-current-line justify t t))
		    (forward-line -1)
		    (justify-current-line justify nil t)
		    (forward-line 1))))))
	;; Leave point after final newline.
	(goto-char (point-max)))
      (unless (eobp)
	(forward-char 1)))))

(defun fill-paragraph (arg)
  "Fill paragraph at or after point.  Prefix arg means justify as well.
If `sentence-end-double-space' is non-nil, then period followed by one
space does not end a sentence, so don't break a line there.
the variable `fill-column' controls the width for filling.

If `fill-paragraph-function' is non-nil, we call it (passing our
argument to it), and if it returns non-nil, we simply return its value."
  (interactive (list (if current-prefix-arg 'full)))
  (or (and fill-paragraph-function
	   (let ((function fill-paragraph-function)
		 fill-paragraph-function)
	     (funcall function arg)))
      (let ((before (point))
	    ;; If fill-paragraph is called recursively,
	    ;; don't give fill-paragraph-function a second chance.
	    fill-paragraph-function)
	(save-excursion
	  (forward-paragraph)
	  (or (bolp) (newline 1))
	  (let ((end (point))
		(beg (progn (backward-paragraph) (point))))
	    (goto-char before)
	    (if use-hard-newlines
		;; Can't use fill-region-as-paragraph, since this paragraph may
		;; still contain hard newlines.  See fill-region.
		(fill-region beg end arg)
	      (fill-region-as-paragraph beg end arg)))))))

(defun fill-region (from to &optional justify nosqueeze to-eop)
  "Fill each of the paragraphs in the region.
A prefix arg means justify as well.
Ordinarily the variable `fill-column' controls the width.

Noninteractively, the third argument JUSTIFY specifies which
kind of justification to do: `full', `left', `right', `center',
or `none' (equivalent to nil).  t means handle each paragraph
as specified by its text properties.

The fourth arg NOSQUEEZE non-nil means to leave
whitespace other than line breaks untouched, and fifth arg TO-EOP
non-nil means to keep filling to the end of the paragraph (or next
hard newline, if `use-hard-newlines' is on).

If `sentence-end-double-space' is non-nil, then period followed by one
space does not end a sentence, so don't break a line there."
  (interactive (list (region-beginning) (region-end)
		     (if current-prefix-arg 'full)))
  (unless (memq justify '(t nil none full center left right))
    (setq justify 'full))
  (let (end beg)
    (save-restriction
      (goto-char (max from to))
      (if to-eop
	  (progn (skip-chars-backward "\n")
		 (forward-paragraph)))
      (setq end (point))
      (goto-char (setq beg (min from to)))
      (beginning-of-line)
      (narrow-to-region (point) end)
      (while (not (eobp))
	(let ((initial (point))
	      end)
	  ;; If using hard newlines, break at every one for filling
	  ;; purposes rather than using paragraph breaks. 
	  (if use-hard-newlines
	      (progn 
		(while (and (setq end (text-property-any (point) (point-max)
							 'hard t))
			    (not (= ?\n (char-after end)))
			    (not (= end (point-max))))
		  (goto-char (1+ end)))
		(setq end (if end (min (point-max) (1+ end)) (point-max)))
		(goto-char initial))
	    (forward-paragraph 1)
	    (setq end (point))
	    (forward-paragraph -1))
	  (if (< (point) beg)
	      (goto-char beg))
	  (if (>= (point) initial)
	      (fill-region-as-paragraph (point) end justify nosqueeze)
	    (goto-char end)))))))


(defcustom default-justification 'left
  "*Method of justifying text not otherwise specified.
Possible values are `left', `right', `full', `center', or `none'.
The requested kind of justification is done whenever lines are filled.
The `justification' text-property  can locally override this variable.
This variable automatically becomes buffer-local when set in any fashion."
  :type '(choice (const left)
		 (const right)
		 (const full)
		 (const center)
		 (const none))
  :group 'fill)
(make-variable-buffer-local 'default-justification)

(defun current-justification ()
  "How should we justify this line?
This returns the value of the text-property `justification',
or the variable `default-justification' if there is no text-property.
However, it returns nil rather than `none' to mean \"don't justify\"."
  (let ((j (or (get-text-property 
		;; Make sure we're looking at paragraph body.
		(save-excursion (skip-chars-forward " \t") 
				(if (and (eobp) (not (bobp)))
				    (1- (point)) (point)))
		'justification)
	       default-justification)))
    (if (eq 'none j)
	nil
      j)))

(defun set-justification (begin end value &optional whole-par)
  "Set the region's justification style.
The kind of justification to use is prompted for.
If the mark is not active, this command operates on the current paragraph.
If the mark is active, the region is used.  However, if the beginning and end
of the region are not at paragraph breaks, they are moved to the beginning and
end of the paragraphs they are in.
If `use-hard-newlines' is true, all hard newlines are taken to be paragraph
breaks.

When calling from a program, operates just on region between BEGIN and END,
unless optional fourth arg WHOLE-PAR is non-nil.  In that case bounds are
extended to include entire paragraphs as in the interactive command."
  (interactive (list (if mark-active (region-beginning) (point))
		     (if mark-active (region-end) (point))
		     (let ((s (completing-read
			       "Set justification to: "
			       '(("left") ("right") ("full")
				 ("center") ("none"))
			       nil t)))
		       (if (equal s "") (error ""))
		       (intern s))
		     t))
  (save-excursion
    (save-restriction
      (if whole-par
	  (let ((paragraph-start (if use-hard-newlines "." paragraph-start))
		(paragraph-ignore-fill-prefix (if use-hard-newlines t 
						paragraph-ignore-fill-prefix)))
	    (goto-char begin)
	    (while (and (bolp) (not (eobp))) (forward-char 1))
	    (backward-paragraph)
	    (setq begin (point))
	    (goto-char end)
	    (skip-chars-backward " \t\n" begin)
	    (forward-paragraph)
	    (setq end (point))))

      (narrow-to-region (point-min) end)
      (unjustify-region begin (point-max))
      (put-text-property begin (point-max) 'justification value)
      (fill-region begin (point-max) nil t))))

(defun set-justification-none (b e)
  "Disable automatic filling for paragraphs in the region.
If the mark is not active, this applies to the current paragraph."
  (interactive (list (if mark-active (region-beginning) (point))
		     (if mark-active (region-end) (point))))
  (set-justification b e 'none t))

(defun set-justification-left (b e)
  "Make paragraphs in the region left-justified.
This is usually the default, but see the variable `default-justification'.
If the mark is not active, this applies to the current paragraph."
  (interactive (list (if mark-active (region-beginning) (point))
		     (if mark-active (region-end) (point))))
  (set-justification b e 'left t))

(defun set-justification-right (b e)
  "Make paragraphs in the region right-justified:
Flush at the right margin and ragged on the left.
If the mark is not active, this applies to the current paragraph."
  (interactive (list (if mark-active (region-beginning) (point))
		     (if mark-active (region-end) (point))))
  (set-justification b e 'right t))

(defun set-justification-full (b e)
  "Make paragraphs in the region fully justified:
This makes lines flush on both margins by inserting spaces between words.
If the mark is not active, this applies to the current paragraph."
  (interactive (list (if mark-active (region-beginning) (point))
		     (if mark-active (region-end) (point))))
  (set-justification b e 'full t))

(defun set-justification-center (b e)
  "Make paragraphs in the region centered.
If the mark is not active, this applies to the current paragraph."
  (interactive (list (if mark-active (region-beginning) (point))
		     (if mark-active (region-end) (point))))
  (set-justification b e 'center t))

;; A line has up to six parts:
;;
;;           >>>                    hello.  		       
;; [Indent-1][FP][    Indent-2     ][text][trailing whitespace][newline]
;;
;; "Indent-1" is the left-margin indentation; normally it ends at column
;;     given by the `current-left-margin' function.
;; "FP" is the fill-prefix.  It can be any string, including whitespace.
;; "Indent-2" is added to justify a line if the `current-justification' is
;;     `center' or `right'.  In `left' and `full' justification regions, any
;;     whitespace there is part of the line's text, and should not be changed.
;; Trailing whitespace is not counted as part of the line length when
;; center- or right-justifying.
;;
;; All parts of the line are optional, although the final newline can 
;;     only be missing on the last line of the buffer.

(defun justify-current-line (&optional how eop nosqueeze)
  "Do some kind of justification on this line.
Normally does full justification: adds spaces to the line to make it end at
the column given by `current-fill-column'.
Optional first argument HOW specifies alternate type of justification:
it can be `left', `right', `full', `center', or `none'.  
If HOW is t, will justify however the `current-justification' function says to.
If HOW is nil or missing, full justification is done by default.
Second arg EOP non-nil means that this is the last line of the paragraph, so
it will not be stretched by full justification.
Third arg NOSQUEEZE non-nil means to leave interior whitespace unchanged,
otherwise it is made canonical."
  (interactive)
  (if (eq t how) (setq how (or (current-justification) 'none))
    (if (null how) (setq how 'full)
      (or (memq how '(none left right center))
	  (setq how 'full))))
  (or (memq how '(none left))  ; No action required for these.
      (let ((fc (current-fill-column))
	    (pos (point-marker))
	    fp-end			; point at end of fill prefix
	    beg				; point at beginning of line's text
	    end				; point at end of line's text
	    indent			; column of `beg'
	    endcol			; column of `end'
	    ncols			; new indent point or offset
	    (nspaces 0)			; number of spaces between words
					; in line (not space characters)
	    fracspace			; fractional amount of space to be
					; added between each words
	    (curr-fracspace 0)		; current fractional space amount
	    count)
	(end-of-line)
	;; Check if this is the last line of the paragraph.
	(if (and use-hard-newlines (null eop) 
		 (get-text-property (point) 'hard))
	    (setq eop t))
	(skip-chars-backward " \t")
	;; Quick exit if it appears to be properly justified already
	;; or there is no text.
	(if (or (bolp)
		(and (memq how '(full right))
		     (= (current-column) fc)))
	    nil
	  (setq end (point))
	  (beginning-of-line)
	  (skip-chars-forward " \t")
	  ;; Skip over fill-prefix.
	  (if (and fill-prefix 
		   (not (string-equal fill-prefix ""))
		   (equal fill-prefix
			  (buffer-substring 
			   (point) (min (point-max) (+ (length fill-prefix)
						       (point))))))
	      (forward-char (length fill-prefix))
	    (if (and adaptive-fill-mode 
		     (looking-at adaptive-fill-regexp))
		(goto-char (match-end 0))))
	  (setq fp-end (point))
	  (skip-chars-forward " \t")
	  ;; This is beginning of the line's text.
	  (setq indent (current-column))
	  (setq beg (point))
	  (goto-char end)
	  (setq endcol (current-column))

	  ;; HOW can't be null or left--we would have exited already
	  (cond ((eq 'right how) 
		 (setq ncols (- fc endcol))
		 (if (< ncols 0)
		     ;; Need to remove some indentation
		     (delete-region 
		      (progn (goto-char fp-end)
			     (if (< (current-column) (+ indent ncols))
				 (move-to-column (+ indent ncols) t))
			     (point))
		      (progn (move-to-column indent) (point)))
		   ;; Need to add some
		   (goto-char beg)
		   (indent-to (+ indent ncols))
		   ;; If point was at beginning of text, keep it there.
		   (if (= beg pos) 
		       (move-marker pos (point)))))

		((eq 'center how)
		 ;; Figure out how much indentation is needed
		 (setq ncols (+ (current-left-margin)
				(/ (- fc (current-left-margin) ;avail. space
				      (- endcol indent)) ;text width
				   2)))
		 (if (< ncols indent)
		     ;; Have too much indentation - remove some
		     (delete-region
		      (progn (goto-char fp-end)
			     (if (< (current-column) ncols)
				 (move-to-column ncols t))
			     (point))
		      (progn (move-to-column indent) (point)))
		   ;; Have too little - add some
		   (goto-char beg)
		   (indent-to ncols)
		   ;; If point was at beginning of text, keep it there.
		   (if (= beg pos)
		       (move-marker pos (point)))))

		((eq 'full how)
		 ;; Insert extra spaces between words to justify line
		 (save-restriction
		   (narrow-to-region beg end)
		   (or nosqueeze
		       (canonically-space-region beg end))
		   (goto-char (point-max))
		   ;; count word spaces in line
		   (while (search-backward " " nil t)
		     (setq nspaces (1+ nspaces))
		     (skip-chars-backward " "))
		   (setq ncols (- fc endcol))
		   ;; Ncols is number of additional space chars needed
		   (if (and (> ncols 0) (> nspaces 0) (not eop))
		       (progn
			 (setq curr-fracspace (+ ncols (/ (1+ nspaces) 2))
			       count nspaces)
			 (while (> count 0)
			   (skip-chars-forward " ")
			   (insert-and-inherit
			    (make-string (/ curr-fracspace nspaces) ?\ ))
			   (search-forward " " nil t)
			   (setq count (1- count)
				 curr-fracspace
				   (+ (% curr-fracspace nspaces) ncols)))))))
		(t (error "Unknown justification value"))))
	(goto-char pos)
	(move-marker pos nil)))
  nil)

(defun unjustify-current-line ()
  "Remove justification whitespace from current line.
If the line is centered or right-justified, this function removes any
indentation past the left margin.  If the line is full-justified, it removes
extra spaces between words.  It does nothing in other justification modes."
  (let ((justify (current-justification)))
    (cond ((eq 'left justify) nil)
	  ((eq  nil  justify) nil)
	  ((eq 'full justify)		; full justify: remove extra spaces
	   (beginning-of-line-text)
	   (canonically-space-region
	    (point) (save-excursion (end-of-line) (point))))
	  ((memq justify '(center right))
	   (save-excursion
	     (move-to-left-margin nil t)
	     ;; Position ourselves after any fill-prefix.
	     (if (and fill-prefix 
		      (not (string-equal fill-prefix ""))
		      (equal fill-prefix
			     (buffer-substring 
			      (point) (min (point-max) (+ (length fill-prefix)
							  (point))))))
		 (forward-char (length fill-prefix)))
	     (delete-region (point) (progn (skip-chars-forward " \t")
					   (point))))))))

(defun unjustify-region (&optional begin end)
  "Remove justification whitespace from region.
For centered or right-justified regions, this function removes any indentation
past the left margin from each line.  For full-justified lines, it removes 
extra spaces between words.  It does nothing in other justification modes.
Arguments BEGIN and END are optional; default is the whole buffer."
  (save-excursion
    (save-restriction
      (if end (narrow-to-region (point-min) end))
      (goto-char (or begin (point-min)))
      (while (not (eobp))
	(unjustify-current-line)
	(forward-line 1)))))


(defun fill-nonuniform-paragraphs (min max &optional justifyp citation-regexp)
  "Fill paragraphs within the region, allowing varying indentation within each.
This command divides the region into \"paragraphs\",
only at paragraph-separator lines, then fills each paragraph
using as the fill prefix the smallest indentation of any line
in the paragraph.

When calling from a program, pass range to fill as first two arguments.

Optional third and fourth arguments JUSTIFY and MAIL-FLAG:
JUSTIFY to justify paragraphs (prefix arg),
When filling a mail message, pass a regexp for CITATION-REGEXP
which will match the prefix of a line which is a citation marker
plus whitespace, but no other kind of prefix.
Also, if CITATION-REGEXP is non-nil,  don't fill header lines."
  (interactive (list (region-beginning) (region-end)
		     (if current-prefix-arg 'full)))
  (let ((fill-individual-varying-indent t))
    (fill-individual-paragraphs min max justifyp citation-regexp)))

(defun fill-individual-paragraphs (min max &optional justify citation-regexp)
  "Fill paragraphs of uniform indentation within the region.
This command divides the region into \"paragraphs\", 
treating every change in indentation level or prefix as a paragraph boundary,
then fills each paragraph using its indentation level as the fill prefix.

There is one special case where a change in indentation does not start
a new paragraph.  This is for text of this form:

   foo>    This line with extra indentation starts
   foo> a paragraph that continues on more lines.

These lines are filled together.

When calling from a program, pass the range to fill
as the first two arguments.

Optional third and fourth arguments JUSTIFY and MAIL-FLAG:
JUSTIFY to justify paragraphs (prefix arg),
When filling a mail message, pass a regexp for CITATION-REGEXP
which will match the prefix of a line which is a citation marker
plus whitespace, but no other kind of prefix.
Also, if CITATION-REGEXP is non-nil,  don't fill header lines."
  (interactive (list (region-beginning) (region-end)
		     (if current-prefix-arg 'full)))
  (save-restriction
    (save-excursion
      (goto-char min)
      (beginning-of-line)
      (narrow-to-region (point) max)
      (if citation-regexp
	  (while (and (not (eobp))
		      (or (looking-at "[ \t]*[^ \t\n]+:")
			  (looking-at "[ \t]*$")))
	    (if (looking-at "[ \t]*[^ \t\n]+:")
		(search-forward "\n\n" nil 'move)
	      (forward-line 1))))
      (narrow-to-region (point) max)
      ;; Loop over paragraphs.
      (while (let ((here (point)))
	       ;; Skip over all paragraph-separating lines
	       ;; so as to not include them in any paragraph.
               (while (and (not (eobp))
			   (progn (move-to-left-margin)
				  (and (not (eobp))
				       (looking-at paragraph-separate))))
                 (forward-line 1))
               (skip-chars-forward " \t\n") (not (eobp)))
	(move-to-left-margin)
	(let ((start (point))
	      fill-prefix fill-prefix-regexp)
	  ;; Find end of paragraph, and compute the smallest fill-prefix
	  ;; that fits all the lines in this paragraph.
	  (while (progn
		   ;; Update the fill-prefix on the first line
		   ;; and whenever the prefix good so far is too long.
		   (if (not (and fill-prefix
				 (looking-at fill-prefix-regexp)))
		       (setq fill-prefix
			     (fill-individual-paragraphs-prefix citation-regexp)
			     fill-prefix-regexp (regexp-quote fill-prefix)))
		   (forward-line 1)
		   (if (bolp)
		       ;; If forward-line went past a newline,
		       ;; move further to the left margin.
		       (move-to-left-margin))
		   ;; Now stop the loop if end of paragraph.
		   (and (not (eobp))
			(if fill-individual-varying-indent
			    ;; If this line is a separator line, with or
			    ;; without prefix, end the paragraph.
			    (and 
			     (not (looking-at paragraph-separate))
			     (save-excursion
			       (not (and (looking-at fill-prefix-regexp)
					 (progn (forward-char (length fill-prefix))
						(looking-at paragraph-separate))))))
			  ;; If this line has more or less indent
			  ;; than the fill prefix wants, end the paragraph.
			  (and (looking-at fill-prefix-regexp)
			       (save-excursion
				 (not (progn (forward-char (length fill-prefix))
					     (or (looking-at "[ \t]")
						 (looking-at paragraph-separate)
						 (looking-at paragraph-start))))))))))
	  ;; Fill this paragraph, but don't add a newline at the end.
	  (let ((had-newline (bolp)))
	    (fill-region-as-paragraph start (point) justify)
	    (if (and (bolp) (not had-newline))
		(delete-char -1))))))))

(defun fill-individual-paragraphs-prefix (citation-regexp)
  (or (let ((adaptive-fill-first-line-regexp "")
	    just-one-line-prefix
	    two-lines-prefix
	    one-line-citation-part
	    two-lines-citation-part
	    adjusted-two-lines-citation-part)
	(setq just-one-line-prefix
	      (fill-context-prefix
	       (point)
	       (save-excursion (forward-line 1)
			       (point))))
	(setq two-lines-prefix
	      (fill-context-prefix
	       (point)
	       (save-excursion (forward-line 2)
			       (point))))
	(when just-one-line-prefix
	  (setq one-line-citation-part
		(if citation-regexp
		    (fill-individual-paragraphs-citation just-one-line-prefix
							 citation-regexp)
		  just-one-line-prefix)))
	(when two-lines-prefix
	  (setq two-lines-citation-part
		(if citation-regexp
		    (fill-individual-paragraphs-citation two-lines-prefix
							 citation-regexp)
		  just-one-line-prefix))
	  (or two-lines-citation-part (setq two-lines-citation-part ""))
	  (setq adjusted-two-lines-citation-part
		(substring two-lines-citation-part 0
			   (string-match "[ \t]*\\'"
					 two-lines-citation-part))))
	;; See if the citation part of JUST-ONE-LINE-PREFIX
	;; is the same as that of TWO-LINES-PREFIX,
	;; except perhaps with longer whitespace.
	(if (and just-one-line-prefix
		 two-lines-prefix
		 (string-match (concat "\\`"
				       (regexp-quote adjusted-two-lines-citation-part)
				       "[ \t]*\\'")
			       one-line-citation-part)
		 (>= (string-width one-line-citation-part)
		     (string-width two-lines-citation-part)))
	    two-lines-prefix
	  just-one-line-prefix))
      (buffer-substring 
       (point)
       (save-excursion (skip-chars-forward " \t")
		       (point)))))

(defun fill-individual-paragraphs-citation (string citation-regexp)
  (string-match citation-regexp
		string)
  (match-string 0 string))  

;;; fill.el ends here
