;;; sgml-mode.el --- SGML- and HTML-editing modes

;; Copyright (C) 1992, 1995, 1996, 1998 Free Software Foundation, Inc.

;; Author: James Clark <jjc@jclark.com>
;; Adapted-By: ESR, Daniel Pfeiffer <occitan@esperanto.org>,
;;             F.Potorti@cnuce.cnr.it
;; Keywords: wp, hypermedia, comm, languages

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

;; Configurable major mode for editing document in the SGML standard general
;; markup language.  As an example contains a mode for editing the derived
;; HTML hypertext markup language.

;;; Code:

(eval-when-compile (require 'skeleton))

(defgroup sgml nil
  "SGML editing mode"
  :group 'languages)

(defcustom sgml-transformation 'identity
  "*Default value for `skeleton-transformation' (which see) in SGML mode."
  :type 'function
  :group 'sgml)

(put 'sgml-transformation 'variable-interactive
     "aTransformation function: ")

;; As long as Emacs' syntax can't be complemented with predicates to context
;; sensitively confirm the syntax of characters, we have to live with this
;; kludgy kind of tradeoff.
(defvar sgml-specials '(?\")
  "List of characters that have a special meaning for SGML mode.
This list is used when first loading the sgml-mode library.
The supported characters and potential disadvantages are:

  ?\\\"	Makes \" in text start a string.
  ?'	Makes ' in text start a string.
  ?-	Makes -- in text start a comment.

When only one of ?\\\" or ?' are included, \"'\" or '\"', as can be found in
DTDs, start a string.  To partially avoid this problem this also makes these
self insert as named entities depending on `sgml-quick-keys'.

Including ?- has the problem of affecting dashes that have nothing to do
with comments, so we normally turn it off.")

(defvar sgml-quick-keys nil
  "Use <, >, &, SPC and `sgml-specials' keys \"electrically\" when non-nil.
This takes effect when first loading the sgml-mode library.")


(defvar sgml-mode-map
  (let ((map (list 'keymap (make-vector 256 nil)))
	(menu-map (make-sparse-keymap "SGML")))
    (define-key map "\t" 'indent-relative-maybe)
    (define-key map "\C-c\C-i" 'sgml-tags-invisible)
    (define-key map "/" 'sgml-slash)
    (define-key map "\C-c\C-n" 'sgml-name-char)
    (define-key map "\C-c\C-t" 'sgml-tag)
    (define-key map "\C-c\C-a" 'sgml-attributes)
    (define-key map "\C-c\C-b" 'sgml-skip-tag-backward)
    (define-key map [?\C-c left] 'sgml-skip-tag-backward)
    (define-key map "\C-c\C-f" 'sgml-skip-tag-forward)
    (define-key map [?\C-c right] 'sgml-skip-tag-forward)
    (define-key map "\C-c\C-d" 'sgml-delete-tag)
    (define-key map "\C-c\^?" 'sgml-delete-tag)
    (define-key map "\C-c?" 'sgml-tag-help)
    (define-key map "\C-c8" 'sgml-name-8bit-mode)
    (define-key map "\C-c\C-v" 'sgml-validate)
    (if sgml-quick-keys
	(progn
	  (define-key map "&" 'sgml-name-char)
	  (define-key map "<" 'sgml-tag)
	  (define-key map " " 'sgml-auto-attributes)
	  (define-key map ">" 'sgml-maybe-end-tag)
	  (if (memq ?\" sgml-specials)
	      (define-key map "\"" 'sgml-name-self))
	  (if (memq ?' sgml-specials)
	      (define-key map "'" 'sgml-name-self))))
    (let ((c 127)
	  (map (nth 1 map)))
      (while (< (setq c (1+ c)) 256)
	(aset map c 'sgml-maybe-name-self)))
    (define-key map [menu-bar sgml] (cons "SGML" menu-map))
    (define-key menu-map [sgml-validate] '("Validate" . sgml-validate))
    (define-key menu-map [sgml-name-8bit-mode]
      '("Toggle 8 Bit Insertion" . sgml-name-8bit-mode))
    (define-key menu-map [sgml-tags-invisible]
      '("Toggle Tag Visibility" . sgml-tags-invisible))
    (define-key menu-map [sgml-tag-help]
      '("Describe Tag" . sgml-tag-help))
    (define-key menu-map [sgml-delete-tag]
      '("Delete Tag" . sgml-delete-tag))
    (define-key menu-map [sgml-skip-tag-forward]
      '("Forward Tag" . sgml-skip-tag-forward))
    (define-key menu-map [sgml-skip-tag-backward]
      '("Backward Tag" . sgml-skip-tag-backward))
    (define-key menu-map [sgml-attributes]
      '("Insert Attributes" . sgml-attributes))
    (define-key menu-map [sgml-tag] '("Insert Tag" . sgml-tag))
    map)
  "Keymap for SGML mode.  See also `sgml-specials'.")


(defvar sgml-mode-syntax-table
  (let ((table (copy-syntax-table text-mode-syntax-table)))
    (modify-syntax-entry ?< "(>" table)
    (modify-syntax-entry ?> ")<" table)
    (if (memq ?- sgml-specials)
	(modify-syntax-entry ?- "_ 1234" table))
    (if (memq ?\" sgml-specials)
	(modify-syntax-entry ?\" "\"\"" table))
    (if (memq ?' sgml-specials)
	(modify-syntax-entry ?\' "\"'" table))
    table)
  "Syntax table used in SGML mode.  See also `sgml-specials'.")


(defcustom sgml-name-8bit-mode nil
  "*When non-nil, insert 8 bit characters with their names."
  :type 'boolean
  :group 'sgml)

(defvar sgml-char-names
  [nil nil nil nil nil nil nil nil
   nil nil nil nil nil nil nil nil
   nil nil nil nil nil nil nil nil
   nil nil nil nil nil nil nil nil
   "nbsp" "excl" "quot" "num" "dollar" "percnt" "amp" "apos"
   "lpar" "rpar" "ast" "plus" "comma" "hyphen" "period" "sol"
   nil nil nil nil nil nil nil nil
   nil nil "colon" "semi" "lt" "eq" "gt" "quest"
   "commat" nil nil nil nil nil nil nil
   nil nil nil nil nil nil nil nil
   nil nil nil nil nil nil nil nil
   nil nil nil "lsqb" nil "rsqb" "uarr" "lowbar"
   "lsquo" nil nil nil nil nil nil nil
   nil nil nil nil nil nil nil nil
   nil nil nil nil nil nil nil nil
   nil nil nil "lcub" "verbar" "rcub" "tilde" nil
   nil nil nil nil nil nil nil nil
   nil nil nil nil nil nil nil nil
   nil nil nil nil nil nil nil nil
   nil nil nil nil nil nil nil nil
   "nbsp" "iexcl" "cent" "pound" "curren" "yen" "brvbar" "sect"
   "uml" "copy" "ordf" "laquo" "not" "shy" "reg" "macr"
   "ring" "plusmn" "sup2" "sup3" "acute" "micro" "para" "middot"
   "cedil" "sup1" "ordm" "raquo" "frac14" "half" "frac34" "iquest"
   "Agrave" "Aacute" "Acirc" "Atilde" "Auml" "Aring" "AElig" "Ccedil"
   "Egrave" "Eacute" "Ecirc" "Euml" "Igrave" "Iacute" "Icirc" "Iuml"
   "ETH" "Ntilde" "Ograve" "Oacute" "Ocirc" "Otilde" "Ouml" nil
   "Oslash" "Ugrave" "Uacute" "Ucirc" "Uuml" "Yacute" "THORN" "szlig"
   "agrave" "aacute" "acirc" "atilde" "auml" "aring" "aelig" "ccedil"
   "egrave" "eacute" "ecirc" "euml" "igrave" "iacute" "icirc" "iuml"
   "eth" "ntilde" "ograve" "oacute" "ocirc" "otilde" "ouml" "divide"
   "oslash" "ugrave" "uacute" "ucirc" "uuml" "yacute" "thorn" "yuml"]
  "Vector of symbolic character names without `&' and `;'.")


;; sgmls is a free SGML parser available from
;; ftp.uu.net:pub/text-processing/sgml
;; Its error messages can be parsed by next-error.
;; The -s option suppresses output.

(defcustom sgml-validate-command "sgmls -s"
  "*The command to validate an SGML document.
The file name of current buffer file name will be appended to this,
separated by a space."
  :type 'string
  :group 'sgml)

(defvar sgml-saved-validate-command nil
  "The command last used to validate in this buffer.")


;;; I doubt that null end tags are used much for large elements,
;;; so use a small distance here.
(defcustom sgml-slash-distance 1000
  "*If non-nil, is the maximum distance to search for matching `/'."
  :type '(choice (const nil) integer)
  :group 'sgml)

(defconst sgml-start-tag-regex
  "<[A-Za-z]\\([-.A-Za-z0-9= \n\t]\\|\"[^\"]*\"\\|'[^']*'\\)*"
  "Regular expression that matches a non-empty start tag.
Any terminating `>' or `/' is not matched.")


;; internal
(defconst sgml-font-lock-keywords-1
  '(("<\\([!?][a-z][-.a-z0-9]*\\)" 1 font-lock-keyword-face)
    ("<\\(/?[a-z][-.a-z0-9]*\\)" 1 font-lock-function-name-face)
    ("[&%][a-z][-.a-z0-9]*;?" . font-lock-variable-name-face)
    ("<! *--.*-- *>" . font-lock-comment-face)))

(defconst sgml-font-lock-keywords-2 ())

;; for font-lock, but must be defvar'ed after
;; sgml-font-lock-keywords-1 and sgml-font-lock-keywords-2 above
(defvar sgml-font-lock-keywords sgml-font-lock-keywords-1
  "*Rules for highlighting SGML code.  See also `sgml-tag-face-alist'.")

;; internal
(defvar sgml-face-tag-alist ()
  "Alist of face and tag name for facemenu.")

(defvar sgml-tag-face-alist ()
  "Tag names and face or list of faces to fontify with when invisible.
When `font-lock-maximum-decoration' is 1 this is always used for fontifying.
When more these are fontified together with `sgml-font-lock-keywords'.")


(defvar sgml-display-text ()
  "Tag names as lowercase symbols, and display string when invisible.")

;; internal
(defvar sgml-tags-invisible nil)


(defcustom sgml-tag-alist
  '(("![" ("ignore" t) ("include" t))
    ("!attlist")
    ("!doctype")
    ("!element")
    ("!entity"))
  "*Alist of tag names for completing read and insertion rules.
This alist is made up as

  ((\"tag\" . TAGRULE)
   ...)

TAGRULE is a list of optionally `t' (no endtag) or `\\n' (separate endtag by
newlines) or a skeleton with `nil', `t' or `\\n' in place of the interactor
followed by an ATTRIBUTERULE (for an always present attribute) or an
attribute alist.

The attribute alist is made up as

  ((\"attribute\" . ATTRIBUTERULE)
   ...)

ATTRIBUTERULE is a list of optionally `t' (no value when no input) followed by
an optional alist of possible values."
  :type '(repeat (cons (string :tag "Tag Name")
		       (repeat :tag "Tag Rule" sexp)))
  :group 'sgml)

(defcustom sgml-tag-help
  '(("!" . "Empty declaration for comment")
    ("![" . "Embed declarations with parser directive")
    ("!attlist" . "Tag attributes declaration")
    ("!doctype" . "Document type (DTD) declaration")
    ("!element" . "Tag declaration")
    ("!entity" . "Entity (macro) declaration"))
  "*Alist of tag name and short description."
  :type '(repeat (cons (string :tag "Tag Name")
		       (string :tag "Description")))
  :group 'sgml)

(defvar v2)				; free for skeleton

(defun sgml-mode-common (sgml-tag-face-alist sgml-display-text)
  "Common code for setting up `sgml-mode' and derived modes.
SGML-TAG-FACE-ALIST is used for calculating `sgml-font-lock-keywords-2'.
SGML-DISPLAY-TEXT sets up alternate text for when tags are invisible (see
varables of same name)."
  (setq local-abbrev-table text-mode-abbrev-table)
  (set-syntax-table sgml-mode-syntax-table)
  (make-local-variable 'indent-line-function)
  (make-local-variable 'paragraph-start)
  (make-local-variable 'paragraph-separate)
  (make-local-variable 'adaptive-fill-regexp)
  (make-local-variable 'sgml-saved-validate-command)
  (make-local-variable 'comment-start)
  (make-local-variable 'comment-end)
  (make-local-variable 'comment-indent-function)
  (make-local-variable 'comment-start-skip)
  (make-local-variable 'comment-indent-function)
  (make-local-variable 'sgml-tags-invisible)
  (make-local-variable 'skeleton-transformation)
  (make-local-variable 'skeleton-further-elements)
  (make-local-variable 'skeleton-end-hook)
  (make-local-variable 'font-lock-defaults)
  (make-local-variable 'sgml-font-lock-keywords-1)
  (make-local-variable 'sgml-font-lock-keywords-2)
  (make-local-variable 'facemenu-add-face-function)
  (make-local-variable 'facemenu-end-add-face)
  ;;(make-local-variable 'facemenu-remove-face-function)
  (and sgml-tag-face-alist
       (not (assq 1 sgml-tag-face-alist))
       (nconc sgml-tag-face-alist
	      `((1 (,(concat "<\\("
			     (mapconcat 'car sgml-tag-face-alist "\\|")
			     "\\)\\([ \t].+\\)?>\\(.+\\)</\\1>")
		    3 (cdr (assoc (downcase (match-string 1))
                                  ',sgml-tag-face-alist)))))))
  (setq indent-line-function 'indent-relative-maybe
	;; A start or end tag by itself on a line separates a paragraph.
	;; This is desirable because SGML discards a newline that appears
	;; immediately after a start tag or immediately before an end tag.
	paragraph-separate "[ \t]*$\\|\
\[ \t]*</?\\([A-Za-z]\\([-.A-Za-z0-9= \t\n]\\|\"[^\"]*\"\\|'[^']*'\\)*\\)?>$"
	paragraph-start "[ \t]*$\\|\
\[ \t]*</?\\([A-Za-z]\\([-.A-Za-z0-9= \t\n]\\|\"[^\"]*\"\\|'[^']*'\\)*\\)?>$"
	adaptive-fill-regexp "[ \t]*"
	comment-start "<!-- "
	comment-end " -->"
	comment-indent-function 'sgml-comment-indent
	;; This will allow existing comments within declarations to be
	;; recognized.
	comment-start-skip "--[ \t]*"
	skeleton-transformation sgml-transformation
	skeleton-further-elements '((completion-ignore-case t))
	skeleton-end-hook (lambda ()
			    (or (eolp)
				(not (or (eq v2 '\n)
					 (eq (car-safe v2) '\n)))
				(newline-and-indent)))
	sgml-font-lock-keywords-2 (append
				   sgml-font-lock-keywords-1
				   (cdr (assq 1 sgml-tag-face-alist)))
	font-lock-defaults '((sgml-font-lock-keywords
			      sgml-font-lock-keywords-1
			      sgml-font-lock-keywords-2)
			     nil
			     t)
	facemenu-add-face-function 'sgml-mode-facemenu-add-face-function)
  (while sgml-display-text
    (put (car (car sgml-display-text)) 'before-string
	 (cdr (car sgml-display-text)))
    (setq sgml-display-text (cdr sgml-display-text))))


(defun sgml-mode-facemenu-add-face-function (face end)
  (if (setq face (cdr (assq face sgml-face-tag-alist)))
      (progn
	(setq face (funcall skeleton-transformation face))
	(setq facemenu-end-add-face (concat "</" face ">"))
	(concat "<" face ">"))
    (error "Face not configured for %s mode." mode-name)))


;;;###autoload
(defun sgml-mode (&optional function)
  "Major mode for editing SGML documents.
Makes > match <.  Makes / blink matching /.
Keys <, &, SPC within <>, \" and ' can be electric depending on
`sgml-quick-keys'.

An argument of N to a tag-inserting command means to wrap it around
the next N words.  In Transient Mark mode, when the mark is active,
N defaults to -1, which means to wrap it around the current region.

If you like upcased tags, put (setq sgml-transformation 'upcase) in
your `.emacs' file.

Use \\[sgml-validate] to validate your document with an SGML parser.

Do \\[describe-variable] sgml- SPC to see available variables.
Do \\[describe-key] on the following bindings to discover what they do.
\\{sgml-mode-map}"
  (interactive)
  (kill-all-local-variables)
  (setq mode-name "SGML"
	major-mode 'sgml-mode)
  (sgml-mode-common sgml-tag-face-alist sgml-display-text)
  ;; Set imenu-generic-expression here, rather than in sgml-mode-common,
  ;; because this definition probably is not useful in HTML mode.
  (make-local-variable 'imenu-generic-expression)
  (setq imenu-generic-expression
	"<!\\(element\\|entity\\)[ \t\n]+%?[ \t\n]*\\([A-Za-z][-A-Za-z.0-9]*\\)")
  (use-local-map sgml-mode-map)
  (run-hooks 'text-mode-hook 'sgml-mode-hook))


(defun sgml-comment-indent ()
  (if (and (looking-at "--")
	   (not (and (eq (preceding-char) ?!)
		     (eq (char-after (- (point) 2)) ?<))))
      (progn
	(skip-chars-backward " \t")
	(max comment-column (1+ (current-column))))
    0))



(defun sgml-slash (arg)
  "Insert `/' and display any previous matching `/'.
Two `/'s are treated as matching if the first `/' ends a net-enabling
start tag, and the second `/' is the corresponding null end tag."
  (interactive "p")
  (insert-char ?/ arg)
  (if (> arg 0)
      (let ((oldpos (point))
	    (blinkpos)
	    (level 0))
	(save-excursion
	  (save-restriction
	    (if sgml-slash-distance
		(narrow-to-region (max (point-min)
				       (- (point) sgml-slash-distance))
				  oldpos))
	    (if (and (re-search-backward sgml-start-tag-regex (point-min) t)
		     (eq (match-end 0) (1- oldpos)))
		()
	      (goto-char (1- oldpos))
	      (while (and (not blinkpos)
			  (search-backward "/" (point-min) t))
		(let ((tagend (save-excursion
				(if (re-search-backward sgml-start-tag-regex
							(point-min) t)
				    (match-end 0)
				  nil))))
		  (if (eq tagend (point))
		      (if (eq level 0)
			  (setq blinkpos (point))
			(setq level (1- level)))
		    (setq level (1+ level)))))))
	  (if blinkpos
	      (progn
		(goto-char blinkpos)
		(if (pos-visible-in-window-p)
		    (sit-for 1)
		  (message "Matches %s"
			   (buffer-substring (progn
					       (beginning-of-line)
					       (point))
					     (1+ blinkpos))))))))))


(defun sgml-name-char (&optional char)
  "Insert a symbolic character name according to `sgml-char-names'.
8 bit chars may be inserted with the meta key as in M-SPC for no break space,
or M-- for a soft hyphen."
  (interactive "*")
  (insert ?&)
  (or char
      (setq char (read-quoted-char "Enter char or octal number")))
  (delete-backward-char 1)
  (insert char)
  (undo-boundary)
  (delete-backward-char 1)
  (insert ?&
	  (or (aref sgml-char-names char)
	      (format "#%d" char))
	  ?\;))


(defun sgml-name-self ()
  "Insert a symbolic character name according to `sgml-char-names'."
  (interactive "*")
  (sgml-name-char last-command-char))


(defun sgml-maybe-name-self ()
  "Insert a symbolic character name according to `sgml-char-names'."
  (interactive "*")
  (if sgml-name-8bit-mode
      (sgml-name-char last-command-char)
    (self-insert-command 1)))


(defun sgml-name-8bit-mode ()
  "Toggle insertion of 8 bit characters."
  (interactive)
  (setq sgml-name-8bit-mode (not sgml-name-8bit-mode))
  (message "sgml name 8 bit mode  is now %s"
	   (if sgml-name-8bit-mode "ON" "OFF")))


;; When an element of a skeleton is a string "str", it is passed
;; through skeleton-transformation and inserted.  If "str" is to be
;; inserted literally, one should obtain it as the return value of a
;; function, e.g. (identity "str").

(define-skeleton sgml-tag
  "Prompt for a tag and insert it, optionally with attributes.
Completion and configuration are done according to `sgml-tag-alist'.
If you like tags and attributes in uppercase do \\[set-variable]
skeleton-transformation RET upcase RET, or put this in your `.emacs':
  (setq sgml-transformation 'upcase)"
  (funcall skeleton-transformation
	   (completing-read "Tag: " sgml-tag-alist))
  ?< (setq v1 (eval str)) |
  (("") -1 '(undo-boundary) (identity "&lt;")) |	; see comment above
  (("") '(setq v2 (sgml-attributes v1 t)) ?>
   (if (string= "![" v1)
       (prog1 '(("") " [ " _ " ]]")
	 (backward-char))
     (if (or (eq v2 t)
	     (string-match "^[/!?]" v1))
	 ()
       (if (symbolp v2)
	   '(("") v2 _ v2 "</" v1 ?>)
	 (if (eq (car v2) t)
	     (cons '("") (cdr v2))
	   (append '(("") (car v2))
		   (cdr v2)
		   '(resume: (car v2) _ "</" v1 ?>))))))))

(autoload 'skeleton-read "skeleton")

(defun sgml-attributes (tag &optional quiet)
  "When at top level of a tag, interactively insert attributes.

Completion and configuration of TAG are done according to `sgml-tag-alist'.
If QUIET, do not print a message when there are no attributes for TAG."
  (interactive (list (save-excursion (sgml-beginning-of-tag t))))
  (or (stringp tag) (error "Wrong context for adding attribute"))
  (if tag
      (let ((completion-ignore-case t)
	    (alist (cdr (assoc (downcase tag) sgml-tag-alist)))
	    car attribute i)
	(if (or (symbolp (car alist))
		(symbolp (car (car alist))))
	    (setq car (car alist)
		  alist (cdr alist)))
	(or quiet
	    (message "No attributes configured."))
	(if (stringp (car alist))
	    (progn
	      (insert (if (eq (preceding-char) ? ) "" ? )
		      (funcall skeleton-transformation (car alist)))
	      (sgml-value alist))
	  (setq i (length alist))
	  (while (> i 0)
	    (insert ? )
	    (insert (funcall skeleton-transformation
			     (setq attribute
				   (skeleton-read '(completing-read
						    "Attribute: "
						    alist)))))
	    (if (string= "" attribute)
		(setq i 0)
	      (sgml-value (assoc (downcase attribute) alist))
	      (setq i (1- i))))
	  (if (eq (preceding-char) ? )
	      (delete-backward-char 1)))
	car)))

(defun sgml-auto-attributes (arg)
  "Self insert the character typed; at top level of tag, prompt for attributes.
With prefix argument, only self insert."
  (interactive "*P")
  (let ((point (point))
	tag)
    (if (or arg
	    (not sgml-tag-alist)	; no message when nothing configured
	    (symbolp (setq tag (save-excursion (sgml-beginning-of-tag t))))
	    (eq (aref tag 0) ?/))
	(self-insert-command (prefix-numeric-value arg))
      (sgml-attributes tag)
      (setq last-command-char ? )
      (or (> (point) point)
	  (self-insert-command 1)))))


(defun sgml-tag-help (&optional tag)
  "Display description of tag TAG.  If TAG is omitted, use the tag at point."
  (interactive)
  (or tag
      (save-excursion
	(if (eq (following-char) ?<)
	    (forward-char))
	(setq tag (sgml-beginning-of-tag))))
  (or (stringp tag)
      (error "No tag selected"))
  (setq tag (downcase tag))
  (message "%s"
	   (or (cdr (assoc (downcase tag) sgml-tag-help))
	       (and (eq (aref tag 0) ?/)
		    (cdr (assoc (downcase (substring tag 1)) sgml-tag-help)))
	       "No description available")))


(defun sgml-maybe-end-tag ()
  "Name self unless in position to end a tag."
  (interactive)
  (or (condition-case nil
	  (save-excursion (up-list -1))
	(error
	 (sgml-name-self)
	 t))
      (condition-case nil
	  (progn
	    (save-excursion (up-list 1))
	    (sgml-name-self))
	(error (self-insert-command 1)))))


(defun sgml-skip-tag-backward (arg)
  "Skip to beginning of tag or matching opening tag if present.
With prefix argument ARG, repeat this ARG times."
  (interactive "p")
  (while (>= arg 1)
    (search-backward "<" nil t)
    (if (looking-at "</\\([^ \n\t>]+\\)")
	;; end tag, skip any nested pairs
	(let ((case-fold-search t)
	      (re (concat "</?" (regexp-quote (match-string 1)))))
	  (while (and (re-search-backward re nil t)
		      (eq (char-after (1+ (point))) ?/))
	    (forward-char 1)
	    (sgml-skip-tag-backward 1))))
    (setq arg (1- arg))))

(defun sgml-skip-tag-forward (arg &optional return)
  "Skip to end of tag or matching closing tag if present.
With prefix argument ARG, repeat this ARG times.
Return t iff after a closing tag."
  (interactive "p")
  (setq return t)
  (while (>= arg 1)
    (skip-chars-forward "^<>")
    (if (eq (following-char) ?>)
	(up-list -1))
    (if (looking-at "<\\([^/ \n\t>]+\\)")
	;; start tag, skip any nested same pairs _and_ closing tag
	(let ((case-fold-search t)
	      (re (concat "</?" (regexp-quote (match-string 1))))
	      point close)
	  (forward-list 1)
	  (setq point (point))
	  (while (and (re-search-forward re nil t)
		      (not (setq close
				 (eq (char-after (1+ (match-beginning 0))) ?/)))
		      (not (up-list -1))
		      (sgml-skip-tag-forward 1))
	    (setq close nil))
	  (if close
	      (up-list 1)
	    (goto-char point)
	    (setq return)))
      (forward-list 1))
    (setq arg (1- arg)))
  return)

(defun sgml-delete-tag (arg)
  "Delete tag on or after cursor, and matching closing or opening tag.
With prefix argument ARG, repeat this ARG times."
  (interactive "p")
  (while (>= arg 1)
    (save-excursion
      (let* (close open)
	(if (looking-at "[ \t\n]*<")
	    ;; just before tag
	    (if (eq (char-after (match-end 0)) ?/)
		;; closing tag
		(progn
		  (setq close (point))
		  (goto-char (match-end 0))))
	  ;; on tag?
	  (or (save-excursion (setq close (sgml-beginning-of-tag)
				    close (and (stringp close)
					       (eq (aref close 0) ?/)
					       (point))))
	      ;; not on closing tag
	      (let ((point (point)))
		(sgml-skip-tag-backward 1)
		(if (or (not (eq (following-char) ?<))
			(save-excursion
			  (forward-list 1)
			  (<= (point) point)))
		    (error "Not on or before tag")))))
	(if close
	    (progn
	      (sgml-skip-tag-backward 1)
	      (setq open (point))
	      (goto-char close)
	      (kill-sexp 1))
	  (setq open (point))
	  (sgml-skip-tag-forward 1)
	  (backward-list)
	  (forward-char)
	  (if (eq (aref (sgml-beginning-of-tag) 0) ?/)
	      (kill-sexp 1)))
	(goto-char open)
	(kill-sexp 1)))
    (setq arg (1- arg))))

;; Put read-only last to enable setting this even when read-only enabled.
(or (get 'sgml-tag 'invisible)
    (setplist 'sgml-tag
	      (append '(invisible t
			intangible t
			point-entered sgml-point-entered
			rear-nonsticky t
			read-only t)
		      (symbol-plist 'sgml-tag))))

(defun sgml-tags-invisible (arg)
  "Toggle visibility of existing tags."
  (interactive "P")
  (let ((modified (buffer-modified-p))
	(inhibit-read-only t)
	;; This is needed in case font lock gets called,
	;; since it moves point and might call sgml-point-entered.
	(inhibit-point-motion-hooks t)
	symbol)
    (save-excursion
      (goto-char (point-min))
      (if (setq sgml-tags-invisible
		(if arg
		    (>= (prefix-numeric-value arg) 0)
		  (not sgml-tags-invisible)))
	  (while (re-search-forward "<\\([!/?A-Za-z][-A-Za-z0-9]*\\)"
				    nil t)
	    (setq symbol (intern-soft (downcase (match-string 1))))
	    (goto-char (match-beginning 0))
	    (and (get symbol 'before-string)
		 (not (overlays-at (point)))
		 (overlay-put (make-overlay (point)
					    (match-beginning 1))
			      'category symbol))
	    (put-text-property (point)
			       (progn (forward-list) (point))
			       'category 'sgml-tag))
	(let ((pos (point)))
	  (while (< (setq pos (next-overlay-change pos)) (point-max))
	    (delete-overlay (car (overlays-at pos)))))
	(remove-text-properties (point-min) (point-max)
				'(category sgml-tag intangible t))))
    (set-buffer-modified-p modified)
    (run-hooks 'sgml-tags-invisible-hook)
    (message "")))

(defun sgml-point-entered (x y)
  ;; Show preceding or following hidden tag, depending of cursor direction.
  (let ((inhibit-point-motion-hooks t))
    (save-excursion
      (message "Invisible tag: %s"
	       (buffer-substring
		(point)
		(if (or (and (> x y)
			     (not (eq (following-char) ?<)))
			(and (< x y)
			     (eq (preceding-char) ?>)))
		    (backward-list)
		  (forward-list)))))))

(autoload 'compile-internal "compile")

(defun sgml-validate (command)
  "Validate an SGML document.
Runs COMMAND, a shell command, in a separate process asynchronously
with output going to the buffer `*compilation*'.
You can then use the command \\[next-error] to find the next error message
and move to the line in the SGML document that caused it."
  (interactive
   (list (read-string "Validate command: "
		      (or sgml-saved-validate-command
			  (concat sgml-validate-command
				  " "
				  (let ((name (buffer-file-name)))
				    (and name
					 (file-name-nondirectory name))))))))
  (setq sgml-saved-validate-command command)
  (save-some-buffers (not compilation-ask-about-save) nil)
  (compile-internal command "No more errors"))


(defun sgml-beginning-of-tag (&optional top-level)
  "Skip to beginning of tag and return its name.
If this can't be done, return t."
  (or (if top-level
	  (condition-case nil
	      (up-list -1)
	    (error t))
	(>= (point)
	    (if (search-backward "<" nil t)
		(save-excursion
		  (forward-list)
		  (point))
	      0)))
      (if (looking-at "<[!?/]?[[A-Za-z][A-Za-z0-9]*")
	  (buffer-substring-no-properties
	   (1+ (point))
	   (match-end 0))
	t)))

(defun sgml-value (alist)
  "Interactively insert value taken from attributerule ALIST.
See `sgml-tag-alist' for info about attributerules.."
  (setq alist (cdr alist))
  (if (stringp (car alist))
      (insert "=\"" (car alist) ?\")
    (if (eq (car alist) t)
	(if (cdr alist)
	    (progn
	      (insert "=\"")
	      (setq alist (skeleton-read '(completing-read
					   "Value: " (cdr alist))))
	      (if (string< "" alist)
		  (insert alist ?\")
		(delete-backward-char 2))))
      (insert "=\"")
      (if alist
	  (insert (skeleton-read '(completing-read "Value: " alist))))
      (insert ?\"))))

(provide 'sgml-mode)

(defvar html-quick-keys sgml-quick-keys
  "Use C-c X combinations for quick insertion of frequent tags when non-nil.
This defaults to `sgml-quick-keys'.
This takes effect when first loading the library.")

(defvar html-mode-map
  (let ((map (nconc (make-sparse-keymap) sgml-mode-map))
	(menu-map (make-sparse-keymap "HTML")))
    (define-key map "\C-c6" 'html-headline-6)
    (define-key map "\C-c5" 'html-headline-5)
    (define-key map "\C-c4" 'html-headline-4)
    (define-key map "\C-c3" 'html-headline-3)
    (define-key map "\C-c2" 'html-headline-2)
    (define-key map "\C-c1" 'html-headline-1)
    (define-key map "\C-c\r" 'html-paragraph)
    (define-key map "\C-c\n" 'html-line)
    (define-key map "\C-c\C-c-" 'html-horizontal-rule)
    (define-key map "\C-c\C-co" 'html-ordered-list)
    (define-key map "\C-c\C-cu" 'html-unordered-list)
    (define-key map "\C-c\C-cr" 'html-radio-buttons)
    (define-key map "\C-c\C-cc" 'html-checkboxes)
    (define-key map "\C-c\C-cl" 'html-list-item)
    (define-key map "\C-c\C-ch" 'html-href-anchor)
    (define-key map "\C-c\C-cn" 'html-name-anchor)
    (define-key map "\C-c\C-ci" 'html-image)
    (if html-quick-keys
	(progn
	  (define-key map "\C-c-" 'html-horizontal-rule)
	  (define-key map "\C-co" 'html-ordered-list)
	  (define-key map "\C-cu" 'html-unordered-list)
	  (define-key map "\C-cr" 'html-radio-buttons)
	  (define-key map "\C-cc" 'html-checkboxes)
	  (define-key map "\C-cl" 'html-list-item)
	  (define-key map "\C-ch" 'html-href-anchor)
	  (define-key map "\C-cn" 'html-name-anchor)
	  (define-key map "\C-ci" 'html-image)))
    (define-key map "\C-c\C-s" 'html-autoview-mode)
    (define-key map "\C-c\C-v" 'browse-url-of-buffer)
    (define-key map [menu-bar html] (cons "HTML" menu-map))
    (define-key menu-map [html-autoview-mode]
      '("Toggle Autoviewing" . html-autoview-mode))
    (define-key menu-map [browse-url-of-buffer]
      '("View Buffer Contents" . browse-url-of-buffer))
    (define-key menu-map [nil] '("--"))
    ;;(define-key menu-map "6" '("Heading 6" . html-headline-6))
    ;;(define-key menu-map "5" '("Heading 5" . html-headline-5))
    ;;(define-key menu-map "4" '("Heading 4" . html-headline-4))
    (define-key menu-map "3" '("Heading 3" . html-headline-3))
    (define-key menu-map "2" '("Heading 2" . html-headline-2))
    (define-key menu-map "1" '("Heading 1" . html-headline-1))
    (define-key menu-map "l" '("Radio Buttons" . html-radio-buttons))
    (define-key menu-map "c" '("Checkboxes" . html-checkboxes))
    (define-key menu-map "l" '("List Item" . html-list-item))
    (define-key menu-map "u" '("Unordered List" . html-unordered-list))
    (define-key menu-map "o" '("Ordered List" . html-ordered-list))
    (define-key menu-map "-" '("Horizontal Rule" . html-horizontal-rule))
    (define-key menu-map "\n" '("Line Break" . html-line))
    (define-key menu-map "\r" '("Paragraph" . html-paragraph))
    (define-key menu-map "i" '("Image" . html-image))
    (define-key menu-map "h" '("Href Anchor" . html-href-anchor))
    (define-key menu-map "n" '("Name Anchor" . html-name-anchor))
    map)
  "Keymap for commands for use in HTML mode.")


(defvar html-face-tag-alist
  '((bold . "b")
    (italic . "i")
    (underline . "u")
    (modeline . "rev"))
  "Value of `sgml-face-tag-alist' for HTML mode.")

(defvar html-tag-face-alist
  '(("b" . bold)
    ("big" . bold)
    ("blink" . highlight)
    ("cite" . italic)
    ("em" . italic)
    ("h1" bold underline)
    ("h2" bold-italic underline)
    ("h3" italic underline)
    ("h4" . underline)
    ("h5" . underline)
    ("h6" . underline)
    ("i" . italic)
    ("rev"  . modeline)
    ("s" . underline)
    ("small" . default)
    ("strong" . bold)
    ("title" bold underline)
    ("tt" . default)
    ("u" . underline)
    ("var" . italic))
  "Value of `sgml-tag-face-alist' for HTML mode.")


(defvar html-display-text
  '((img . "[/]")
    (hr . "----------")
    (li . "o "))
  "Value of `sgml-display-text' for HTML mode.")

;; should code exactly HTML 3 here when that is finished
(defvar html-tag-alist
  (let* ((1-7 '(("1") ("2") ("3") ("4") ("5") ("6") ("7")))
	 (1-9 '(,@1-7 ("8") ("9")))
	 (align '(("align" ("left") ("center") ("right"))))
	 (valign '(("top") ("middle") ("bottom") ("baseline")))
	 (rel '(("next") ("previous") ("parent") ("subdocument") ("made")))
	 (href '("href" ("ftp:") ("file:") ("finger:") ("gopher:") ("http:")
		 ("mailto:") ("news:") ("rlogin:") ("telnet:") ("tn3270:")
		 ("wais:") ("/cgi-bin/")))
	 (name '("name"))
	 (link `(,href
		 ("rel" ,@rel)
		 ("rev" ,@rel)
		 ("title")))
	 (list '((nil \n ( "List item: "
			   "<li>" str \n))))
	 (cell `(t
		 ,align
		 ("valign" ,@valign)
		 ("colspan" ,@1-9)
		 ("rowspan" ,@1-9)
		 ("nowrap" t))))
    ;; put ,-expressions first, else byte-compile chokes (as of V19.29)
    ;; and like this it's more efficient anyway
    `(("a" ,name ,@link)
      ("base" t ,@href)
      ("dir" ,@list)
      ("font" nil "size" ("-1") ("+1") ("-2") ("+2") ,@1-7)
      ("form" (\n _ \n "<input type=\"submit\" value=\"\">")
       ("action" ,@(cdr href)) ("method" ("get") ("post")))
      ("h1" ,@align)
      ("h2" ,@align)
      ("h3" ,@align)
      ("h4" ,@align)
      ("h5" ,@align)
      ("h6" ,@align)
      ("hr" t ("size" ,@1-9) ("width") ("noshade" t) ,@align)
      ("img" t ("align" ,@valign ("texttop") ("absmiddle") ("absbottom"))
       ("src") ("alt") ("width" "1") ("height" "1")
       ("border" "1") ("vspace" "1") ("hspace" "1") ("ismap" t))
      ("input" t ("size" ,@1-9) ("maxlength" ,@1-9) ("checked" t) ,name
       ("type" ("text") ("password") ("checkbox") ("radio")
	("submit") ("reset"))
       ("value"))
      ("link" t ,@link)
      ("menu" ,@list)
      ("ol" ,@list ("type" ("A") ("a") ("I") ("i") ("1")))
      ("p" t ,@align)
      ("select" (nil \n
		     ("Text: "
		      "<option>" str \n))
       ,name ("size" ,@1-9) ("multiple" t))
      ("table" (nil \n
		    ((completing-read "Cell kind: " '(("td") ("th"))
				      nil t "t")
		     "<tr><" str ?> _ \n))
       ("border" t ,@1-9) ("width" "10") ("cellpadding"))
      ("td" ,@cell)
      ("textarea" ,name ("rows" ,@1-9) ("cols" ,@1-9))
      ("th" ,@cell)
      ("ul" ,@list ("type" ("disc") ("circle") ("square")))

      ,@sgml-tag-alist

      ("abbrev")
      ("acronym")
      ("address")
      ("array" (nil \n
		    ("Item: " "<item>" str \n))
       "align")
      ("au")
      ("b")
      ("big")
      ("blink")
      ("blockquote" \n)
      ("body" \n ("background" ".gif") ("bgcolor" "#") ("text" "#")
       ("link" "#") ("alink" "#") ("vlink" "#"))
      ("box" (nil _ "<over>" _))
      ("br" t ("clear" ("left") ("right")))
      ("caption" ("valign" ("top") ("bottom")))
      ("center" \n)
      ("cite")
      ("code" \n)
      ("dd" t)
      ("del")
      ("dfn")
      ("dl" (nil \n
		 ( "Term: "
		   "<dt>" str "<dd>" _ \n)))
      ("dt" (t _ "<dd>"))
      ("em")
      ;("fn" "id" "fn")  ; ???
      ("head" \n)
      ("html" (\n
	       "<head>\n"
	       "<title>" (setq str (read-input "Title: ")) "</title>\n"
	       "</head>\n"
	       "<body>\n<h1>" str "</h1>\n" _
	       "\n<address>\n<a href=\"mailto:"
	       user-mail-address
	       "\">" (user-full-name) "</a>\n</address>\n"
	       "</body>"
		))
      ("i")
      ("ins")
      ("isindex" t ("action") ("prompt"))
      ("kbd")
      ("lang")
      ("li" t)
      ("math" \n)
      ("nobr")
      ("option" t ("value") ("label") ("selected" t))
      ("over" t)
      ("person")
      ("pre" \n)
      ("q")
      ("rev")
      ("s")
      ("samp")
      ("small")
      ("strong")
      ("sub")
      ("sup")
      ("title")
      ("tr" t)
      ("tt")
      ("u")
      ("var")
      ("wbr" t)))
  "*Value of `sgml-tag-alist' for HTML mode.")

(defvar html-tag-help
  `(,@sgml-tag-help
    ("a" . "Anchor of point or link elsewhere")
    ("abbrev" . "?")
    ("acronym" . "?")
    ("address" . "Formatted mail address")
    ("array" . "Math array")
    ("au" . "?")
    ("b" . "Bold face")
    ("base" . "Base address for URLs")
    ("big" . "Font size")
    ("blink" . "Blinking text")
    ("blockquote" . "Indented quotation")
    ("body" . "Document body")
    ("box" . "Math fraction")
    ("br" . "Line break")
    ("caption" . "Table caption")
    ("center" . "Centered text")
    ("changed" . "Change bars")
    ("cite" . "Citation of a document")
    ("code" . "Formatted source code")
    ("dd" . "Definition of term")
    ("del" . "?")
    ("dfn" . "?")
    ("dir" . "Directory list (obsolete)")
    ("dl" . "Definition list")
    ("dt" . "Term to be definined")
    ("em" . "Emphasised") 
    ("embed" . "Embedded data in foreign format")
    ("fig" . "Figure")
    ("figa" . "Figure anchor")
    ("figd" . "Figure description")
    ("figt" . "Figure text")
    ;("fn" . "?")  ; ???
    ("font" . "Font size")
    ("form" . "Form with input fields")
    ("group" . "Document grouping")
    ("h1" . "Most important section headline")
    ("h2" . "Important section headline")
    ("h3" . "Section headline")
    ("h4" . "Minor section headline")
    ("h5" . "Unimportant section headline")
    ("h6" . "Least important section headline")
    ("head" . "Document header")
    ("hr" . "Horizontal rule")
    ("html" . "HTML Document")
    ("i" . "Italic face")
    ("img" . "Graphic image")
    ("input" . "Form input field")
    ("ins" . "?")
    ("isindex" . "Input field for index search")
    ("kbd" . "Keybard example face")
    ("lang" . "Natural language")
    ("li" . "List item")
    ("link" . "Link relationship")
    ("math" . "Math formula")
    ("menu" . "Menu list (obsolete)")
    ("mh" . "Form mail header")
    ("nextid" . "Allocate new id")
    ("nobr" . "Text without line break")
    ("ol" . "Ordered list")
    ("option" . "Selection list item")
    ("over" . "Math fraction rule")
    ("p" . "Paragraph start")
    ("panel" . "Floating panel")
    ("person" . "?")
    ("pre" . "Preformatted fixed width text")
    ("q" . "?")
    ("rev" . "Reverse video")
    ("s" . "?")
    ("samp" . "Sample text")
    ("select" . "Selection list")
    ("small" . "Font size")
    ("sp" . "Nobreak space")
    ("strong" . "Standout text")
    ("sub" . "Subscript")
    ("sup" . "Superscript")
    ("table" . "Table with rows and columns")
    ("tb" . "Table vertical break")
    ("td" . "Table data cell")
    ("textarea" . "Form multiline edit area")
    ("th" . "Table header cell")
    ("title" . "Document title")
    ("tr" . "Table row separator")
    ("tt" . "Typewriter face")
    ("u" . "Underlined text")
    ("ul" . "Unordered list")
    ("var" . "Math variable face")
    ("wbr" . "Enable <br> within <nobr>"))
"*Value of `sgml-tag-help' for HTML mode.")

;;;###autoload
(defun html-mode ()
  "Major mode based on SGML mode for editing HTML documents.
This allows inserting skeleton constructs used in hypertext documents with
completion.  See below for an introduction to HTML.  Use
\\[browse-url-of-buffer] to see how this comes out.  See also `sgml-mode' on
which this is based.

Do \\[describe-variable] html- SPC and \\[describe-variable] sgml- SPC to see available variables.

To write fairly well formatted pages you only need to know few things.  Most
browsers have a function to read the source code of the page being seen, so
you can imitate various tricks.  Here's a very short HTML primer which you
can also view with a browser to see what happens:

<title>A Title Describing Contents</title> should be on every page.  Pages can
have <h1>Very Major Headlines</h1> through <h6>Very Minor Headlines</h6>
<hr> Parts can be separated with horizontal rules.

<p>Paragraphs only need an opening tag.  Line breaks and multiple spaces are
ignored unless the text is <pre>preformatted.</pre>  Text can be marked as
<b>bold</b>, <i>italic</i> or <u>underlined</u> using the normal  M-g  or
Edit/Text Properties/Face commands.

Pages can have <a name=\"SOMENAME\">named points</a> and can link other points
to them with <a href=\"#SOMENAME\">see also somename</a>.  In the same way <a
href=\"URL\">see also URL</a> where URL is a filename relative to current
directory, or absolute as in `http://www.cs.indiana.edu/elisp/w3/docs.html'.

Images in many formats can be inlined with <img src=\"URL\">.

If you mainly create your own documents, `sgml-specials' might be
interesting.  But note that some HTML 2 browsers can't handle `&apos;'.
To work around that, do:
   (eval-after-load \"sgml-mode\" '(aset sgml-char-names ?' nil))

\\{html-mode-map}"
  (interactive)
  (kill-all-local-variables)
  (setq mode-name "HTML"
        major-mode 'html-mode)
  (sgml-mode-common html-tag-face-alist html-display-text)
  (use-local-map html-mode-map)
  (make-local-variable 'sgml-tag-alist)
  (make-local-variable 'sgml-face-tag-alist)
  (make-local-variable 'sgml-tag-help)
  (make-local-variable 'outline-regexp)
  (make-local-variable 'outline-heading-end-regexp)
  (make-local-variable 'outline-level)
  (make-local-variable 'sentence-end)
  (setq sentence-end
	(if sentence-end-double-space
	    "[.?!][]\"')}]*\\(<[^>]*>\\)*\\($\\| $\\|\t\\|  \\)[ \t\n]*"
	    
	  "[.?!][]\"')}]*\\(<[^>]*>\\)*\\($\\| \\|\t\\)[ \t\n]*"))
  (setq sgml-tag-alist html-tag-alist
	sgml-face-tag-alist html-face-tag-alist
	sgml-tag-help html-tag-help
	outline-regexp "^.*<[Hh][1-6]\\>"
	outline-heading-end-regexp "</[Hh][1-6]>"
	outline-level (lambda ()
			(char-after (1- (match-end 0)))))
  (setq imenu-create-index-function 'html-imenu-index)
  (make-local-variable 'imenu-sort-function)
  (setq imenu-sort-function nil) ; sorting the menu defeats the purpose
  (run-hooks 'text-mode-hook 'sgml-mode-hook 'html-mode-hook))

(defvar html-imenu-regexp
  "\\s-*<h\\([1-9]\\)[^\n<>]*>\\(<[^\n<>]*>\\)*\\s-*\\([^\n<>]*\\)"
  "*A regular expression matching a head line to be added to the menu.
The first `match-string' should be a number from 1-9.
The second `match-string' matches extra tags and is ignored.
The third `match-string' will be the used in the menu.")

(defun html-imenu-index ()
  "Return an table of contents for an HTML buffer for use with Imenu."
  (let (toc-index)
    (save-excursion
      (goto-char (point-min))
      (while (re-search-forward html-imenu-regexp nil t)
	(setq toc-index
	      (cons (cons (concat (make-string
				   (* 2 (1- (string-to-number (match-string 1))))
				   ?\ )
				  (match-string 3))
			  (save-excursion (beginning-of-line) (point)))
		    toc-index))))
    (nreverse toc-index)))

(defun html-autoview-mode (&optional arg)
  "Toggle automatic viewing via `html-viewer' upon saving buffer.
With positive prefix ARG always turns viewing on, with negative ARG always off.
Can be used as a value for `html-mode-hook'."
  (interactive "P")
  (if (setq arg (if arg
		    (< (prefix-numeric-value arg) 0)
		  (and (boundp 'after-save-hook)
		       (memq 'browse-url-of-buffer after-save-hook))))
      (setq after-save-hook (delq 'browse-url-of-buffer after-save-hook))
    (make-local-hook 'after-save-hook)
    (add-hook 'after-save-hook 'browse-url-of-buffer nil t))
  (message "Autoviewing turned %s."
	   (if arg "off" "on")))

(define-skeleton html-href-anchor
  "HTML anchor tag with href attribute."
  "URL: "
  '(setq input "http:")
  "<a href=\"" str "\">" _ "</a>")

(define-skeleton html-name-anchor
  "HTML anchor tag with name attribute."
  "Name: "
  "<a name=\"" str "\">" _ "</a>")

(define-skeleton html-headline-1
  "HTML level 1 headline tags."
  nil
  "<h1>" _ "</h1>")

(define-skeleton html-headline-2
  "HTML level 2 headline tags."
  nil
  "<h2>" _ "</h2>")

(define-skeleton html-headline-3
  "HTML level 3 headline tags."
  nil
  "<h3>" _ "</h3>")

(define-skeleton html-headline-4
  "HTML level 4 headline tags."
  nil
  "<h4>" _ "</h4>")

(define-skeleton html-headline-5
  "HTML level 5 headline tags."
  nil
  "<h5>" _ "</h5>")

(define-skeleton html-headline-6
  "HTML level 6 headline tags."
  nil
  "<h6>" _ "</h6>")

(define-skeleton html-horizontal-rule
  "HTML horizontal rule tag."
  nil
  "<hr>" \n)

(define-skeleton html-image
  "HTML image tag."
  nil
  "<img src=\"" _ "\">")

(define-skeleton html-line
  "HTML line break tag."
  nil
  "<br>" \n)

(define-skeleton html-ordered-list
  "HTML ordered list tags."
  nil
  "<ol>" \n
  "<li>" _ \n
  "</ol>")

(define-skeleton html-unordered-list
  "HTML unordered list tags."
  nil
  "<ul>" \n
  "<li>" _ \n
  "</ul>")

(define-skeleton html-list-item
  "HTML list item tag."
  nil
  (if (bolp) nil '\n)
  "<li>")

(define-skeleton html-paragraph
  "HTML paragraph tag."
  nil
  (if (bolp) nil ?\n)
  \n "<p>")

(define-skeleton html-checkboxes
  "Group of connected checkbox inputs."
  nil
  '(setq v1 nil
	 v2 nil)
  ("Value: "
   "<input type=\"" (identity "checkbox") ; see comment above about identity
   "\" name=\"" (or v1 (setq v1 (skeleton-read "Name: ")))
   "\" value=\"" str ?\"
   (if (y-or-n-p "Set \"checked\" attribute? ")
        (funcall skeleton-transformation " checked")) ">"
   (skeleton-read "Text: " (capitalize str))
   (or v2 (setq v2 (if (y-or-n-p "Newline after text? ")
		       (funcall skeleton-transformation "<br>")
		     "")))
   \n))

(define-skeleton html-radio-buttons
  "Group of connected radio button inputs."
  nil
  '(setq v1 nil
	 v2 (cons nil nil))
  ("Value: "
   "<input type=\"" (identity "radio") ; see comment above about identity
   "\" name=\"" (or (car v2) (setcar v2 (skeleton-read "Name: ")))
   "\" value=\"" str ?\"
   (if (and (not v1) (setq v1 (y-or-n-p "Set \"checked\" attribute? ")))
       (funcall skeleton-transformation " checked") ">")
   (skeleton-read "Text: " (capitalize str))
   (or (cdr v2) (setcdr v2 (if (y-or-n-p "Newline after text? ")
			       (funcall skeleton-transformation "<br>")
			     "")))
   \n))

;;; sgml-mode.el ends here
