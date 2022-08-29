;;; msb.el --- Customizable buffer-selection with multiple menus.

;; Copyright (C) 1993, 94, 95, 97, 98, 99 Free Software Foundation, Inc.

;; Author: Lars Lindberg <Lars.G.Lindberg@capgemini.se>
;; Created: 8 Oct 1993
;; Lindberg's last update version: 3.34
;; Keywords: mouse buffer menu

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

;; Purpose of this package:
;;   1. Offer a function for letting the user choose buffer,
;;      not necessarily for switching to it.
;;   2. Make a better mouse-buffer-menu.  This is done as a global
;;      minor mode, msb-mode.
;;
;; Customization:
;;   Look at the variable `msb-menu-cond' for deciding what menus you
;;   want.  It's not that hard to customize, despite my not-so-good
;;   doc-string.  Feel free to send me a better doc-string.
;;   There are some constants for you to try here:
;;   msb--few-menus
;;   msb--very-many-menus (default)
;;   
;;   Look at the variable `msb-item-handling-function' for customization
;;   of the appearance of every menu item.  Try for instance setting
;;   it to `msb-alon-item-handler'.
;;  
;;   Look at the variable `msb-item-sort-function' for customization
;;   of sorting the menus.  Set it to t for instance, which means no
;;   sorting - you will get latest used buffer first.
;;
;;   Also check out the variable `msb-display-invisible-buffers-p'.

;; Known bugs:
;; - Files-by-directory
;;   + No possibility to show client/changed buffers separately.
;;   + All file buffers only appear in a file sub-menu, they will
;;     for instance not appear in the Mail sub-menu.

;; Future enhancements:

;;; Thanks goes to
;;  Mark Brader <msb@sq.com>
;;  Jim Berry <m1jhb00@FRB.GOV>
;;  Hans Chalupsky <hans@cs.Buffalo.EDU>
;;  Larry Rosenberg <ljr@ictv.com>
;;  Will Henney <will@astroscu.unam.mx>
;;  Jari Aalto <jaalto@tre.tele.nokia.fi>
;;  Michael Kifer <kifer@sbkifer.cs.sunysb.edu>
;;  Gael Marziou <gael@gnlab030.grenoble.hp.com>
;;  Dave Gillespie <daveg@thymus.synaptics.com>
;;  Alon Albert <alon@milcse.rtsg.mot.com>
;;  Kevin Broadey, <KevinB@bartley.demon.co.uk>
;;  Ake Stenhof <ake@cadpoint.se>
;;  Richard Stallman <rms@gnu.ai.mit.edu>
;;  Steve Fisk <fisk@medved.bowdoin.edu>

;; This version turned into a global minor mode by Dave Love.
;;; Code:

(require 'cl)

;;;
;;; Some example constants to be used for `msb-menu-cond'.  See that
;;; variable for more information.  Please note that if the condition
;;; returns `multi', then the buffer can appear in several menus.
;;;
(defconst msb--few-menus
  '(((and (boundp 'server-buffer-clients)
	  server-buffer-clients
	  'multi)
     3030
     "Clients (%d)")
    ((and msb-display-invisible-buffers-p
	  (msb-invisible-buffer-p)
	  'multi)
     3090
     "Invisible buffers (%d)")
    ((eq major-mode 'dired-mode)
     2010
     "Dired (%d)"
     msb-dired-item-handler
     msb-sort-by-directory)
    ((eq major-mode 'Man-mode)
     4090
     "Manuals (%d)")
    ((eq major-mode 'w3-mode)
     4020
     "WWW (%d)")
    ((or (memq major-mode '(rmail-mode rmail-edit-mode vm-summary-mode vm-mode mail-mode))
	 (memq major-mode '(mh-letter-mode
			    mh-show-mode
			    mh-folder-mode))
	 (memq major-mode '(gnus-summary-mode
			    news-reply-mode
			    gnus-group-mode
			    gnus-article-mode
			    gnus-kill-file-mode
			    gnus-browse-killed-mode)))
     4010
     "Mail (%d)")
    ((not buffer-file-name)
     4099
     "Buffers (%d)")
    ('no-multi
     1099
     "Files (%d)")))

(defconst msb--very-many-menus
  '(((and (boundp 'server-buffer-clients)
	  server-buffer-clients
	  'multi)
     1010
     "Clients (%d)")
    ((and (boundp 'vc-mode) vc-mode 'multi)
     1020
     "Version Control (%d)")
    ((and buffer-file-name
	  (buffer-modified-p)
	  'multi)
     1030
     "Changed files (%d)")
    ((and (get-buffer-process (current-buffer))
	  'multi)
     1040
     "Processes (%d)")
    ((and msb-display-invisible-buffers-p
	  (msb-invisible-buffer-p)
	  'multi)
     1090
     "Invisible buffers (%d)")
    ((eq major-mode 'dired-mode)
     2010
     "Dired (%d)"
     ;; Note this different menu-handler
     msb-dired-item-handler
     ;; Also note this item-sorter
     msb-sort-by-directory)
    ((eq major-mode 'Man-mode)
     5030
     "Manuals (%d)")
    ((eq major-mode 'w3-mode)
     5020
     "WWW (%d)")
    ((or (memq major-mode '(rmail-mode rmail-edit-mode vm-summary-mode vm-mode mail-mode))
	 (memq major-mode '(mh-letter-mode
			    mh-show-mode
			    mh-folder-mode))
	 (memq major-mode '(gnus-summary-mode
			    news-reply-mode
			    gnus-group-mode
			    gnus-article-mode
			    gnus-kill-file-mode
			    gnus-browse-killed-mode)))
     5010
     "Mail (%d)")
    ;; Catchup for all non-file buffers
    ((and (not buffer-file-name)
	  'no-multi)
     5099
     "Other non-file buffers (%d)")
    ((and (string-match "/\\.[^/]*$" buffer-file-name)
	  'multi)
     3090
     "Hidden Files (%d)")
    ((memq major-mode '(c-mode c++-mode))
     3010
     "C/C++ Files (%d)")
    ((eq major-mode 'emacs-lisp-mode)
     3020
     "Elisp Files (%d)")
    ((eq major-mode 'latex-mode)
     3030
     "LaTex Files (%d)")
    ('no-multi
     3099
     "Other files (%d)")))

;; msb--many-menus is obsolete
(defvar msb--many-menus msb--very-many-menus)

;;;
;;; Customizable variables
;;;

(defgroup msb nil
  "Customizable buffer-selection with multiple menus."
  :prefix "msb-"
  :group 'mouse)

;;;###autoload
(defcustom msb-mode nil
  "Toggle msb-mode.
Setting this variable directly does not take effect;
use either \\[customize] or the function `msb-mode'."
  :set (lambda (symbol value)
	 (msb-mode (or value 0)))
  :initialize 'custom-initialize-default
  :version "20.4"
  :type    'boolean
  :group   'msb
  :require 'msb)

(defun msb-custom-set (symbol value)
  "Set the value of custom variables for msb."
  (set symbol value)
  (if (featurep 'msb)
      ;; wait until package has been loaded before bothering to update
      ;; the buffer lists.
      (menu-bar-update-buffers t))
)

(defcustom msb-menu-cond msb--very-many-menus
  "*List of criteria for splitting the mouse buffer menu.
The elements in the list should be of this type:
 (CONDITION MENU-SORT-KEY MENU-TITLE ITEM-HANDLING-FN ITEM-SORT-FN).

When making the split, the buffers are tested one by one against the
CONDITION, just like a Lisp cond: When hitting a true condition, the
other criteria are *not* tested and the buffer name will appear in the
menu with the menu-title corresponding to the true condition.

If the condition returns the symbol `multi', then the buffer will be
added to this menu *and* tested for other menus too.  If it returns
`no-multi', then the buffer will only be added if it hasn't been added
to any other menu.

During this test, the buffer in question is the current buffer, and
the test is surrounded by calls to `save-excursion' and
`save-match-data'.

The categories are sorted by MENU-SORT-KEY.  Smaller keys are on top.
nil means don't display this menu.

MENU-TITLE is really a format.  If you add %d in it, the %d is
replaced with the number of items in that menu.

ITEM-HANDLING-FN, is optional.  If it is supplied and is a function,
than it is used for displaying the items in that particular buffer
menu, otherwise the function pointed out by
`msb-item-handling-function' is used.

ITEM-SORT-FN, is also optional.
If it is not supplied, the function pointed out by
`msb-item-sort-function' is used.
If it is nil, then no sort takes place and the buffers are presented
in least-recently-used order.
If it is t, then no sort takes place and the buffers are presented in
most-recently-used order.
If it is supplied and non-nil and not t than it is used for sorting
the items in that particular buffer menu.

Note1: There should always be a `catch-all' as last element, in this
list.  That is an element like (t TITLE ITEM-HANDLING-FUNCTION).
Note2: A buffer menu appears only if it has at least one buffer in it.
Note3: If you have a CONDITION that can't be evaluated you will get an
error every time you do \\[msb]."
  :type `(choice (const :tag "long" :value ,msb--very-many-menus)
		 (const :tag "short" :value ,msb--few-menus))
  :set 'msb-custom-set
  :group 'msb)

(defcustom msb-modes-key 4000
  "The sort key for files sorted by mode."
  :type 'integer
  :set 'msb-custom-set
  :group 'msb
  :version "20.3")

(defcustom msb-separator-diff 100
  "*Non-nil means use separators.
The separators will appear between all menus that have a sorting key
that differs by this value or more."
  :type '(choice integer (const nil))
  :set 'msb-custom-set
  :group 'msb)

(defvar msb-files-by-directory-sort-key 0
  "*The sort key for files sorted by directory.")

(defcustom msb-max-menu-items 15
  "*The maximum number of items in a menu.
If this variable is set to 15 for instance, then the submenu will be
split up in minor parts, 15 items each.  Nil means no limit."
  :type '(choice integer (const nil))
  :set 'msb-custom-set
  :group 'msb)

(defcustom msb-max-file-menu-items 10
  "*The maximum number of items from different directories.

When the menu is of type `file by directory', this is the maximum
number of buffers that are clumped together from different
directories.

Set this to 1 if you want one menu per directory instead of clumping
them together.

If the value is not a number, then the value 10 is used."
  :type 'integer
  :set 'msb-custom-set
  :group 'msb)

(defcustom msb-most-recently-used-sort-key -1010
  "*Where should the menu with the most recently used buffers be placed?"
  :type 'integer
  :set 'msb-custom-set
  :group 'msb)

(defcustom msb-display-most-recently-used 15
  "*How many buffers should be in the most-recently-used menu.
No buffers at all if less than 1 or nil (or any non-number)."
  :type 'integer
  :set 'msb-custom-set
  :group 'msb)

(defcustom msb-most-recently-used-title "Most recently used (%d)"
  "*The title for the most-recently-used menu."
  :type 'string
  :set 'msb-custom-set
  :group 'msb)
 
(defvar msb-horizontal-shift-function '(lambda () 0)
  "*Function that specifies how many pixels to shift the top menu leftwards.")

(defcustom msb-display-invisible-buffers-p nil
  "*Show invisible buffers or not.
Non-nil means that the buffer menu should include buffers that have
names that starts with a space character."
  :type 'boolean
  :set 'msb-custom-set
  :group 'msb)

(defvar msb-item-handling-function 'msb-item-handler
  "*The appearance of a buffer menu.

The default function to call for handling the appearance of a menu
item.  It should take to arguments, BUFFER and MAX-BUFFER-NAME-LENGTH,
where the latter is the max length of all buffer names.

The function should return the string to use in the menu.

When the function is called, BUFFER is the current buffer.  This
function is called for items in the variable `msb-menu-cond' that have
nil as ITEM-HANDLING-FUNCTION.  See `msb-menu-cond' for more
information.")

(defcustom msb-item-sort-function 'msb-sort-by-name
  "*The order of items in a buffer menu.

The default function to call for handling the order of items in a menu
item.  This function is called like a sort function.  The items look
like (ITEM-NAME . BUFFER).

ITEM-NAME is the name of the item that will appear in the menu.
BUFFER is the buffer, this is not necessarily the current buffer.

Set this to nil or t if you don't want any sorting (faster)."
  :type '(choice (const msb-sort-by-name)
		 (const :tag "Newest first" t)
		 (const :tag "Oldest first" nil))
  :set 'msb-custom-set
  :group 'msb
)
		
(defcustom msb-files-by-directory nil
  "*Non-nil means that files should be sorted by directory.
This is instead of the groups in `msb-menu-cond'."
  :type 'boolean
  :set 'msb-custom-set
  :group 'msb)

(defcustom msb-after-load-hooks nil
  "Hooks to be run after the msb package has been loaded."
  :type 'hook
  :set 'msb-custom-set
  :group 'msb)

;;;
;;; Internal variables
;;;

;; Home directory for the current user
(defconst msb--home-dir
  (condition-case nil
      (substitute-in-file-name "$HOME")
    ;; If $HOME isn't defined, use nil
    (error nil)))

;; The last calculated menu.
(defvar msb--last-buffer-menu nil)

;; If this is non-nil, then it is a string that describes the error.
(defvar msb--error nil)

;;;
;;; Some example function to be used for `msb-item-handling-function'.
;;;
(defun msb-item-handler (buffer &optional maxbuf)
  "Create one string item, concerning BUFFER, for the buffer menu.
The item looks like:
*% <buffer-name>
The `*' appears only if the buffer is marked as modified.
The `%' appears only if the buffer is read-only.
Optional second argument MAXBUF is completely ignored."
  (let ((name (buffer-name))
	(modified (if (buffer-modified-p) "*" " "))
	(read-only (if buffer-read-only "%" " ")))
    (format "%s%s %s" modified read-only name)))


(eval-when-compile (require 'dired))

;; `dired' can be called with a list of the form (directory file1 file2 ...)
;; which causes `dired-directory' to be in the same form.
(defun msb--dired-directory ()
  (cond ((stringp dired-directory)
	 (abbreviate-file-name (expand-file-name dired-directory)))
	((consp dired-directory)
	 (abbreviate-file-name (expand-file-name (car dired-directory))))
	(t
	 (error "Unknown type of `dired-directory' in buffer %s"
		(buffer-name)))))

(defun msb-dired-item-handler (buffer &optional maxbuf)
  "Create one string item, concerning a dired BUFFER, for the buffer menu.
The item looks like:
*% <buffer-name>
The `*' appears only if the buffer is marked as modified.
The `%' appears only if the buffer is read-only.
Optional second argument MAXBUF is completely ignored."
  (let ((name (msb--dired-directory))
	(modified (if (buffer-modified-p) "*" " "))
	(read-only (if buffer-read-only "%" " ")))
    (format "%s%s %s" modified read-only name)))

(defun msb-alon-item-handler (buffer maxbuf)
  "Create one string item for the buffer menu.
The item looks like:
<buffer-name> *%# <file-name>
The `*' appears only if the buffer is marked as modified.
The `%' appears only if the buffer is read-only.
The `#' appears only version control file (SCCS/RCS)."
  (format (format "%%%ds  %%s%%s%%s  %%s" maxbuf)
          (buffer-name buffer)
          (if (buffer-modified-p) "*" " ")
          (if buffer-read-only "%" " ")
          (if (and (boundp 'vc-mode) vc-mode) "#" " ")
          (or buffer-file-name "")))

;;;
;;; Some example function to be used for `msb-item-sort-function'.
;;;
(defun msb-sort-by-name (item1 item2)
  "Sort the items ITEM1 and ITEM2 by their `buffer-name'.
An item looks like (NAME . BUFFER)."
  (string-lessp (buffer-name (cdr item1))
		(buffer-name (cdr item2))))


(defun msb-sort-by-directory (item1 item2)
  "Sort the items ITEM1 and ITEM2 by directory name.  Made for dired.
An item look like (NAME . BUFFER)."
  (string-lessp (save-excursion (set-buffer (cdr item1))
				(msb--dired-directory))
		(save-excursion (set-buffer (cdr item2))
				(msb--dired-directory))))

;;;
;;; msb
;;;
;;; This function can be used instead of (mouse-buffer-menu EVENT)
;;; function in "mouse.el".
;;;
(defun msb (event)
  "Pop up several menus of buffers for selection with the mouse.
This command switches buffers in the window that you clicked on, and
selects that window.

See the function `mouse-select-buffer' and the variable
`msb-menu-cond' for more information about how the menus are split."
  (interactive "e")
  (let ((old-window (selected-window))
	(window (posn-window (event-start event))))
    (unless (framep window) (select-window window))
    (let ((buffer (mouse-select-buffer event)))
      (if buffer
	  (switch-to-buffer buffer)
	(select-window old-window))))
  nil)

;;;
;;; Some supportive functions
;;;
(defun msb-invisible-buffer-p (&optional buffer)
  "Return t if optional BUFFER is an \"invisible\" buffer.
If the argument is left out or nil, then the current buffer is considered."
  (and (> (length (buffer-name buffer)) 0)
       (eq ?\ (aref (buffer-name buffer) 0))))

;; Strip one hierarchy level from the end of DIR.
(defun msb--strip-dir (dir)
  (file-name-directory (directory-file-name dir)))

;; Create an alist with all buffers from LIST that lies under the same
;; directory will be in the same item as the directory string.
;; ((PATH1 . (BUFFER-1 BUFFER-2 ...)) (PATH2 . (BUFFER-K BUFFER-K+1...)) ...)
(defun msb--init-file-alist (list)
  (let ((buffer-alist
	 ;; Make alist that looks like
	 ;; ((PATH-1 BUFFER-1) (PATH-2 BUFFER-2) ...)
	 ;; sorted on PATH-x
	 (sort (mapcan
		(lambda (buffer)
		  (let ((file-name (expand-file-name (buffer-file-name buffer))))
		    (when file-name
		      (list (cons (msb--strip-dir file-name) buffer)))))
		list)
	       (lambda (item1 item2)
		 (string< (car item1) (car item2))))))
    ;; Now clump buffers together that have the same path
    ;; Make alist that looks like
    ;; ((PATH1 . (BUFFER-1 BUFFER-2 ...)) (PATH2 . (BUFFER-K)) ...)
    (let ((path nil)
	  (buffers nil))
      (nconc
       (mapcan (lambda (item)
		 (cond
		  ((and path
			(string= path (car item)))
		   ;; The same path as earlier: Add to current list of
		   ;; buffers.
		   (push (cdr item) buffers)
		   ;; This item should not be added to list
		   nil)
		  (t
		   ;; New path
		   (let ((result (and path (cons path buffers))))
		     (setq path (car item))
		     (setq buffers (list (cdr item)))
		     ;; Add the last result the list.
		     (and result (list result))))))
	       buffer-alist)
       ;; Add the last result to the list
       (list (cons path buffers))))))

;; Format a suitable title for the menu item.
(defun msb--format-title (top-found-p path number-of-items)
  (let ((new-path path))
    (when (and msb--home-dir
	       (string-match (concat "^" msb--home-dir) path))
      (setq new-path (concat "~"
			     (substring path (match-end 0)))))
    (format (if top-found-p "%s... (%d)" "%s (%d)")
	    new-path number-of-items)))

;; Variables for debugging.
(defvar msb--choose-file-menu-list)
(defvar msb--choose-file-menu-arg-list)

;; Choose file-menu with respect to directory for every buffer in LIST.
(defun msb--choose-file-menu (list)
  (setq msb--choose-file-menu-arg-list list)
  (let ((buffer-alist (msb--init-file-alist list))
	(final-list nil)
	(max-clumped-together (if (numberp msb-max-file-menu-items)
				  msb-max-file-menu-items
				10))
	(top-found-p nil)
	(last-path nil)
	first rest path buffers old-path)
    ;; Prepare for looping over all items in buffer-alist
    (setq first (car buffer-alist)
	  rest (cdr buffer-alist)
	  path (car first)
	  buffers (cdr first))
    (setq msb--choose-file-menu-list (copy-list rest))
    ;; This big loop tries to clump buffers together that have a
    ;; similar name. Remember that buffer-alist is sorted based on the
    ;; path for the buffers.
    (while rest
      (let ((found-p nil)
	    (tmp-rest rest)
	    result
	    new-path item)
	(setq item (car tmp-rest))
	;; Clump together the "rest"-buffers that have a path that is
	;; a subpath of the current one.
	(while (and tmp-rest
		    (<= (length buffers) max-clumped-together)
		    (>= (length (car item)) (length path))
		    (string= path (substring (car item) 0 (length path))))
	  (setq found-p t)
	  (setq buffers (append buffers (cdr item))) ;nconc is faster than append
	  (setq tmp-rest (cdr tmp-rest)
		item (car tmp-rest)))
	(cond
	 ((> (length buffers) max-clumped-together)
	  ;; Oh, we failed. Too many buffers clumped together.
	  ;; Just use the original ones for the result.
	  (setq last-path (car first))
	  (push (cons (msb--format-title top-found-p
					 (car first)
					 (length (cdr first)))
		      (cdr first))
		final-list)
	  (setq top-found-p nil)
	  (setq first (car rest)
		rest (cdr rest)
		path (car first)
		buffers (cdr first)))
	 (t
	  ;; The first pass of clumping together worked out, go ahead
	  ;; with this result.
	  (when found-p
	    (setq top-found-p t)
	    (setq first (cons path buffers)
		  rest tmp-rest))
	  ;; Now see if we can clump more buffers together if we go up
	  ;; one step in the file hierarchy.
	  ;; If path isn't changed by msb--strip-dir, we are looking
	  ;; at the machine name component of an ange-ftp filename.
	  (setq old-path path)
	  (setq path (msb--strip-dir path)
		buffers (cdr first))
	  (if (equal old-path path)
	      (setq last-path path))
	  (when (and last-path
		     (or (and (>= (length path) (length last-path))
			      (string= last-path
				       (substring path 0 (length last-path))))
			 (and (< (length path) (length last-path))
			      (string= path
				       (substring last-path 0 (length path))))))
	    ;; We have reached the same place in the file hierarchy as
	    ;; the last result, so we should quit at this point and
	    ;; take what we have as result.
	    (push (cons (msb--format-title top-found-p
					   (car first)
					   (length (cdr first)))
			(cdr first))
		  final-list)
	    (setq top-found-p nil)
	    (setq first (car rest)
		  rest (cdr rest)
		  path (car first)
		  buffers (cdr first)))))))
    ;; Now take care of the last item.
    (when first
      (push (cons (msb--format-title top-found-p
				     (car first)
				     (length (cdr first)))
		  (cdr first))
	    final-list))
    (setq top-found-p nil)
    (nreverse final-list)))

;; Create a vector as:
;; [BUFFER-LIST-VARIABLE CONDITION MENU-SORT-KEY MENU-TITLE ITEM-HANDLER SORTER)
;; from an element in `msb-menu-cond'.  See that variable for a
;; description of its elements.
(defun msb--create-function-info (menu-cond-elt)
  (let* ((list-symbol (make-symbol "-msb-buffer-list"))
	 (tmp-ih (and (> (length menu-cond-elt) 3)
		      (nth 3 menu-cond-elt)))
	 (item-handler (if (and tmp-ih (fboundp tmp-ih))
			   tmp-ih
			 msb-item-handling-function))
	 (tmp-s (if (> (length menu-cond-elt) 4)
		    (nth 4 menu-cond-elt)
		  msb-item-sort-function))
	 (sorter (if (or (fboundp tmp-s)
			 (null tmp-s)
			 (eq tmp-s t))
		    tmp-s
		   msb-item-sort-function)))
    (when (< (length menu-cond-elt) 3)
      (error "Wrong format of msb-menu-cond"))
    (when (and (> (length menu-cond-elt) 3)
	       (not (fboundp tmp-ih)))
      (signal 'invalid-function (list tmp-ih)))
    (when (and (> (length menu-cond-elt) 4)
	       tmp-s
	       (not (fboundp tmp-s))
	       (not (eq tmp-s t)))
      (signal 'invalid-function (list tmp-s)))
    (set list-symbol ())
    (vector list-symbol			;BUFFER-LIST-VARIABLE
	    (nth 0 menu-cond-elt)	;CONDITION
	    (nth 1 menu-cond-elt)	;SORT-KEY
	    (nth 2 menu-cond-elt)	;MENU-TITLE
	    item-handler		;ITEM-HANDLER
	    sorter)			;SORTER
    ))

;; This defsubst is only used in `msb--choose-menu' below.  It was
;; pulled out merely to make the code somewhat clearer.  The indentation
;; level was too big.
(defsubst msb--collect (function-info-vector)
  (let ((result nil)
	(multi-flag nil)
	function-info-list)
    (setq function-info-list
	  (loop for fi
		across function-info-vector
		if (and (setq result
			      (eval (aref fi 1))) ;Test CONDITION
			(not (and (eq result 'no-multi)
				  multi-flag))
			(progn (when (eq result 'multi)
				 (setq multi-flag t))
			       t))
		collect fi
		until (and result
			   (not (eq result 'multi)))))
    (when (and (not function-info-list)
	       (not result))
      (error "No catch-all in msb-menu-cond!"))
    function-info-list))

;; Adds BUFFER to the menu depicted by FUNCTION-INFO
;; All side-effects.  Adds an element of form (BUFFER-TITLE . BUFFER)
;; to the buffer-list variable in function-info.
(defun msb--add-to-menu (buffer function-info max-buffer-name-length)
  (let ((list-symbol (aref function-info 0))) ;BUFFER-LIST-VARIABLE
    ;; Here comes the hairy side-effect!
    (set list-symbol
	 (cons (cons (funcall (aref function-info 4) ;ITEM-HANDLER
			      buffer
			      max-buffer-name-length)
		     buffer)
	       (eval list-symbol)))))
 
;; Selects the appropriate menu for BUFFER.
;; This is all side-effects, folks!
;; This should be optimized.
(defsubst msb--choose-menu (buffer function-info-vector max-buffer-name-length)
  (unless (and (not msb-display-invisible-buffers-p)
	       (msb-invisible-buffer-p buffer))
    (condition-case nil
	(save-excursion
	  (set-buffer buffer)
	  ;; Menu found.  Add to this menu
	  (mapc (lambda (function-info)
		  (msb--add-to-menu buffer function-info max-buffer-name-length))
		(msb--collect function-info-vector)))
      (error (unless msb--error
	       (setq msb--error
		     (format
		      "In msb-menu-cond, error for buffer `%s'."
		      (buffer-name buffer)))
	       (error "%s" msb--error))))))

;; Return (SORT-KEY TITLE . BUFFER-LIST) or nil if the
;; buffer-list is empty.
(defun msb--create-sort-item (function-info)
  (let ((buffer-list (eval (aref function-info 0))))
    (when buffer-list
      (let ((sorter (aref function-info 5)) ;SORTER
	    (sort-key (aref function-info 2))) ;MENU-SORT-KEY
	(when sort-key
	  (cons sort-key
		(cons (format (aref function-info 3) ;MENU-TITLE
			      (length buffer-list))
		      (cond
		       ((null sorter)
			buffer-list)
		       ((eq sorter t)
			(nreverse buffer-list))
		       (t
			(sort buffer-list sorter))))))))))

;; Return ALIST as a sorted, aggregated alist, where all items with
;; the same car element (according to SAME-PREDICATE) are aggregated
;; together. The alist is first sorted by SORT-PREDICATE.
;; Example:
;; (msb--aggregate-alist
;;  '((a . a1) (a . a2) (b . b1) (c . c3) (a . a4) (a . a3) (b . b3) (b . b2))
;;  (function string=)
;;  (lambda (item1 item2)
;;    (string< (symbol-name item1) (symbol-name item2))))
;; results in
;; ((a a1 a2 a4 a3) (b b1 b3 b2) (c c3))
(defun msb--aggregate-alist (alist same-predicate sort-predicate)
  (when (not (null alist))
    (let (result
	  same
	  tmp-old-car
	  tmp-same
	  (first-time-p t)
	  old-car)
      (nconc
       (mapcan (lambda (item)
		 (cond
		  (first-time-p
		   (push (cdr item) same)
		   (setq first-time-p nil)
		   (setq old-car (car item))
		   nil)
		  ((funcall same-predicate (car item) old-car)
		   (push (cdr item) same)
		   nil)
		  (t
		   (setq tmp-same same
			 tmp-old-car old-car)
		   (setq same (list (cdr item))
			 old-car (car item))
		   (list (cons tmp-old-car (nreverse tmp-same))))))
	       (sort alist (lambda (item1 item2)
			     (funcall sort-predicate (car item1) (car item2)))))
       (list (cons old-car (nreverse same)))))))


(defun msb--mode-menu-cond ()
  (let ((key msb-modes-key))
    (mapcar (lambda (item)
	      (incf key)
	      (list `( eq major-mode (quote ,(car item)))
		    key
		    (concat (cdr item) " (%d)")))
	    (sort
	     (let ((mode-list nil))
	       (mapc (lambda (buffer)
		       (save-excursion
			 (set-buffer buffer)
			 (when (and (not (msb-invisible-buffer-p))
				    (not (assq major-mode mode-list))
				    (push (cons major-mode mode-name)
					  mode-list)))))
		     (cdr (buffer-list)))
	       mode-list)
	     (lambda (item1 item2)
	       (string< (cdr item1) (cdr item2)))))))

;; Returns a list on the form ((TITLE . BUFFER-LIST)) for
;; the most recently used buffers.
(defun msb--most-recently-used-menu (max-buffer-name-length)
  (when (and (numberp msb-display-most-recently-used)
 	     (> msb-display-most-recently-used 0))
    (let* ((buffers (cdr (buffer-list)))
	   (most-recently-used
	    (loop with n = 0
		  for buffer in buffers
		  if (save-excursion
		       (set-buffer buffer)
		       (and (not (msb-invisible-buffer-p))
			    (not (eq major-mode 'dired-mode))))
		  collect (save-excursion
			    (set-buffer buffer)
			    (cons (funcall msb-item-handling-function
					   buffer
					   max-buffer-name-length)
				  buffer))
		  and do (incf n)
		  until (>= n msb-display-most-recently-used))))
      (cons (if (stringp msb-most-recently-used-title)
		(format msb-most-recently-used-title
			(length most-recently-used))
	      (signal 'wrong-type-argument (list msb-most-recently-used-title)))
	    most-recently-used))))

(defun msb--create-buffer-menu-2 ()
  (let ((max-buffer-name-length 0)
	file-buffers
	function-info-vector)
    ;; Calculate the longest buffer name.
    (mapc
     (lambda (buffer)
       (if (or msb-display-invisible-buffers-p
	       (not (msb-invisible-buffer-p)))
	   (setq max-buffer-name-length
		 (max max-buffer-name-length
		      (length (buffer-name buffer))))))
     (buffer-list))
    ;; Make a list with elements of type
    ;; (BUFFER-LIST-VARIABLE
    ;;  CONDITION
    ;;  MENU-SORT-KEY
    ;;  MENU-TITLE
    ;;  ITEM-HANDLER
    ;;  SORTER)
    ;; Uses "function-global" variables:
    ;; function-info-vector
    (setq function-info-vector
	  (apply (function vector)
		 (mapcar (function msb--create-function-info)
			 (append msb-menu-cond (msb--mode-menu-cond)))))
    ;; Split the buffer-list into several lists; one list for each
    ;; criteria.  This is the most critical part with respect to time.
    (mapc (lambda (buffer)
	    (cond ((and msb-files-by-directory
			(buffer-file-name buffer)
			;; exclude ange-ftp buffers
			;;(not (string-match "\\/[^/:]+:"
			;;		   (buffer-file-name buffer)))
			)
		   (push buffer file-buffers))
		  (t
		   (msb--choose-menu buffer
				     function-info-vector
				     max-buffer-name-length))))
	  (buffer-list))
    (when file-buffers
      (setq file-buffers
	    (mapcar (lambda (buffer-list)
		      (cons msb-files-by-directory-sort-key
			    (cons (car buffer-list)
				  (sort
				   (mapcar (function
					    (lambda (buffer)
					      (cons (save-excursion
						      (set-buffer buffer)
						      (funcall msb-item-handling-function
							       buffer
							       max-buffer-name-length))
						    buffer)))
					   (cdr buffer-list))
				   (function
				    (lambda (item1 item2)
				      (string< (car item1) (car item2))))))))
		     (msb--choose-file-menu file-buffers))))
    ;; Now make the menu - a list of (TITLE . BUFFER-LIST)
    (let* (menu
	   (most-recently-used
	    (msb--most-recently-used-menu max-buffer-name-length))
	   (others (nconc file-buffers
			   (loop for elt
				 across function-info-vector
				 for value = (msb--create-sort-item elt)
				 if value collect value))))
      (setq menu
	    (mapcar 'cdr		;Remove the SORT-KEY
		    ;; Sort the menus - not the items.
		    (msb--add-separators
		    (sort
		     ;; Get a list of (SORT-KEY TITLE . BUFFER-LIST)
		     ;; Also sorts the items within the menus.
		     (if (cdr most-recently-used)
			 (cons
			  ;; Add most recent used buffers
			  (cons msb-most-recently-used-sort-key
				most-recently-used)
			  others)
		       others)
		     (lambda (elt1 elt2)
		       (< (car elt1) (car elt2)))))))
      ;; Now make it a keymap menu
      (append
       '(keymap "Select Buffer")
       (msb--make-keymap-menu menu)
       (when msb-separator-diff
	 (list (list 'separator "--")))
       (list (cons 'toggle
		   (cons
		   (if msb-files-by-directory
		       "*Files by type*"
		     "*Files by directory*")
		   'msb--toggle-menu-type)))))))

(defun msb--create-buffer-menu  ()
  (save-match-data
    (save-excursion
      (msb--create-buffer-menu-2))))

;;;
;;; Multi purpose function for selecting a buffer with the mouse.
;;;
(defun msb--toggle-menu-type ()
  (interactive)
  (setq msb-files-by-directory (not msb-files-by-directory))
  ;; This gets a warning, but it is correct,
  ;; because this file redefines menu-bar-update-buffers.
  (menu-bar-update-buffers t))

(defun mouse-select-buffer (event)
  "Pop up several menus of buffers, for selection with the mouse.
Returns the selected buffer or nil if no buffer is selected.

The way the buffers are split is conveniently handled with the
variable `msb-menu-cond'."
  ;; Popup the menu and return the selected buffer.
  (when (or msb--error
	    (not msb--last-buffer-menu)
	    (not (fboundp 'frame-or-buffer-changed-p))
	    (frame-or-buffer-changed-p))
    (setq msb--error nil)
    (setq msb--last-buffer-menu (msb--create-buffer-menu)))
  (let ((position event)
	choice)
    (when (and (fboundp 'posn-x-y)
	       (fboundp 'posn-window))
      (let ((posX (car (posn-x-y (event-start event))))
	    (posY (cdr (posn-x-y (event-start event))))
	    (posWind (posn-window (event-start event))))
	;; adjust position
	(setq posX (- posX (funcall msb-horizontal-shift-function))
	      position (list (list posX posY) posWind))))
    ;; This `sit-for' magically makes the menu stay up if the mouse
    ;; button is released within 0.1 second.
    (sit-for 0 100)
    ;; Popup the menu
    (setq choice (x-popup-menu position msb--last-buffer-menu))
    (cond
     ((eq (car choice) 'toggle)
      ;; Bring up the menu again with type toggled.
      (msb--toggle-menu-type)
      (mouse-select-buffer event))
     ((and (numberp (car choice))
	   (null (cdr choice)))
      (let ((msb--last-buffer-menu (nthcdr 3 (assq (car choice) msb--last-buffer-menu))))
	(mouse-select-buffer event)))
     ((while (numberp (car choice))
	(setq choice (cdr choice))))
     ((and (stringp (car choice))
	   (null (cdr choice)))
      (car choice))
     ((null choice)
      choice)
     (t
      (error "Unknown form for buffer: %s" choice)))))

;; Add separators
(defun msb--add-separators (sorted-list)
  (cond
   ((or (not msb-separator-diff)
	(not (numberp msb-separator-diff)))
    sorted-list)
   (t
    (let ((last-key nil))
      (mapcan
       (lambda (item)
	 (cond
	  ((and msb-separator-diff
		last-key
		(> (- (car item) last-key)
		   msb-separator-diff))
	   (setq last-key (car item))
	   (list (cons last-key 'separator)
		 item))
	  (t
	   (setq last-key (car item))
	   (list item))))
       sorted-list)))))

(defun msb--split-menus-2 (list mcount result)
  (cond
   ((> (length list) msb-max-menu-items)
    (let ((count 0)
	  sub-name
	  (tmp-list nil))
      (while (< count msb-max-menu-items)
	(push (pop list) tmp-list)
	(incf count))
    (setq tmp-list (nreverse tmp-list))
    (setq sub-name (concat (car (car tmp-list)) "..."))
    (push (nconc (list mcount sub-name
		       'keymap sub-name)
		  tmp-list)
	  result))
    (msb--split-menus-2 list (1+ mcount) result))
   ((null result)
    list)
   (t
    (let (sub-name)
      (setq sub-name (concat (car (car list)) "..."))
      (push (nconc (list mcount sub-name
			 'keymap sub-name)
		  list)
	  result))
    (nreverse result))))

(defun msb--split-menus (list)
  (if (and (integerp msb-max-menu-items)
	   (> msb-max-menu-items 0))
      (msb--split-menus-2 list 0 nil)
    list))

(defun msb--make-keymap-menu (raw-menu)
  (let ((end (cons '(nil) 'menu-bar-select-buffer))
	(mcount 0))
    (mapcar
     (lambda (sub-menu)
       (cond
	((eq 'separator sub-menu)
	 (list 'separator "--"))
	(t
	 (let ((buffers (mapcar (function
				 (lambda (item)
				   (let ((string (car item))
					 (buffer (cdr item)))
				     (cons (buffer-name buffer)
					   (cons string end)))))
				(cdr sub-menu))))
	   (nconc (list (incf mcount) (car sub-menu)
			'keymap (car sub-menu))
		  (msb--split-menus buffers))))))
     raw-menu)))

(defun menu-bar-update-buffers (&optional arg)
  ;; If user discards the Buffers item, play along.
  (when (and (lookup-key (current-global-map) [menu-bar buffer])
	     (or (not (fboundp 'frame-or-buffer-changed-p))
		 (frame-or-buffer-changed-p)
		 arg))
    (let ((frames (frame-list))
	  buffers-menu frames-menu)
      ;; Make the menu of buffers proper.
      (setq msb--last-buffer-menu (msb--create-buffer-menu))
      (setq buffers-menu msb--last-buffer-menu)
      ;; Make a Frames menu if we have more than one frame.
      (when (cdr frames)
	(let* ((frame-length (length frames))
	       (f-title  (format "Frames (%d)" frame-length)))
	  ;; List only the N most recently selected frames
	  (when (and (integerp msb-max-menu-items)
		     (>  msb-max-menu-items 1)
		     (> frame-length msb-max-menu-items))
	    (setcdr (nthcdr msb-max-menu-items frames) nil))
	  (setq frames-menu
		(nconc
		 (list 'frame f-title '(nil) 'keymap f-title)
		 (mapcar
		  (lambda (frame)
		    (nconc
		     (list frame
			   (cdr (assq 'name
				      (frame-parameters frame)))
			   (cons nil nil))
		     'menu-bar-select-frame))
		  frames)))))
      (define-key (current-global-map) [menu-bar buffer]
	(cons "Buffers"
	      (if (and buffers-menu frames-menu)
		  ;; Combine Frame and Buffers menus with separator between
		  (nconc (list 'keymap "Buffers and Frames" frames-menu
			       (and msb-separator-diff '(separator "--")))
			 (cddr buffers-menu))
		(or buffers-menu 'undefined)))))))

;; Snarf current bindings of `mouse-buffer-menu' (normally
;; C-down-mouse-1).
(defvar msb-mode-map
  (let ((map (make-sparse-keymap)))
    (mapcar (lambda (key)
	      (define-key map key #'msb))
	    (where-is-internal 'mouse-buffer-menu (make-sparse-keymap)))
    map))

;;;###autoload
(defun msb-mode (&optional arg)
  "Toggle Msb mode.
With arg, turn Msb mode on if and only if arg is positive.
This mode overrides the binding(s) of `mouse-buffer-menu' to provide a
different buffer menu using the function `msb'."
  (interactive "P")
  (setq msb-mode (if arg
		     (> (prefix-numeric-value arg) 0)
		   (not msb-mode)))
  (if msb-mode
      (add-hook 'menu-bar-update-hook 'menu-bar-update-buffers)
    (remove-hook 'menu-bar-update-hook 'menu-bar-update-buffers)))

(add-to-list 'minor-mode-map-alist (cons 'msb-mode msb-mode-map))

(provide 'msb)
(eval-after-load 'msb (run-hooks 'msb-after-load-hooks))

;;; msb.el ends here
