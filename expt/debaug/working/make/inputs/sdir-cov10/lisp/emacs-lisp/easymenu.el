;;; easymenu.el --- support the easymenu interface for defining a menu.

;; Copyright (C) 1994, 1996, 1998 Free Software Foundation, Inc.

;; Keywords: emulations
;; Author: rms

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

;; This is compatible with easymenu.el by Per Abrahamsen
;; but it is much simpler as it doesn't try to support other Emacs versions.
;; The code was mostly derived from lmenu.el.

;;; Code:

(defcustom easy-menu-precalculate-equivalent-keybindings t
  "Determine when equivalent key bindings are computed for easy-menu menus.
It can take some time to calculate the equivalent key bindings that are shown
in a menu.  If the variable is on, then this calculation gives a (maybe
noticeable) delay when a mode is first entered.  If the variable is off, then
this delay will come when a menu is displayed the first time.  If you never use
menus, turn this variable off, otherwise it is probably better to keep it on."
  :type 'boolean
  :group 'menu
  :version "20.3")

;;;###autoload
(defmacro easy-menu-define (symbol maps doc menu)
  "Define a menu bar submenu in maps MAPS, according to MENU.
The menu keymap is stored in symbol SYMBOL, both as its value
and as its function definition.   DOC is used as the doc string for SYMBOL.

The first element of MENU must be a string.  It is the menu bar item name.
It may be followed by the following keyword argument pairs

   :filter FUNCTION

FUNCTION is a function with one argument, the menu.  It returns the actual
menu displayed.

   :visible INCLUDE

INCLUDE is an expression; this menu is only visible if this
expression has a non-nil value.  `:include' is an alias for `:visible'.

   :active ENABLE

ENABLE is an expression; the menu is enabled for selection
whenever this expression's value is non-nil.

The rest of the elements in MENU, are menu items.

A menu item is usually a vector of three elements:  [NAME CALLBACK ENABLE]

NAME is a string--the menu item name.

CALLBACK is a command to run when the item is chosen,
or a list to evaluate when the item is chosen.

ENABLE is an expression; the item is enabled for selection
whenever this expression's value is non-nil.

Alternatively, a menu item may have the form: 

   [ NAME CALLBACK [ KEYWORD ARG ] ... ]

Where KEYWORD is one of the symbols defined below.

   :keys KEYS

KEYS is a string; a complex keyboard equivalent to this menu item.
This is normally not needed because keyboard equivalents are usually
computed automatically.
KEYS is expanded with `substitute-command-keys' before it is used.

   :key-sequence KEYS

KEYS is nil a string or a vector; nil or a keyboard equivalent to this
menu item.
This is a hint that will considerably speed up Emacs first display of
a menu.  Use `:key-sequence nil' when you know that this menu item has no
keyboard equivalent.

   :active ENABLE

ENABLE is an expression; the item is enabled for selection
whenever this expression's value is non-nil.

   :included INCLUDE

INCLUDE is an expression; this item is only visible if this
expression has a non-nil value.

   :suffix NAME

NAME is a string; the name of an argument to CALLBACK.

   :style STYLE
   
STYLE is a symbol describing the type of menu item.  The following are
defined:  

toggle: A checkbox.
        Prepend the name with `(*) ' or `( ) ' depending on if selected or not.
radio: A radio button.
       Prepend the name with `[X] ' or `[ ] ' depending on if selected or not.
button: Surround the name with `[' and `]'. Use this for an item in the
        menu bar itself.
anything else means an ordinary menu item.

   :selected SELECTED

SELECTED is an expression; the checkbox or radio button is selected
whenever this expression's value is non-nil.

A menu item can be a string.  Then that string appears in the menu as
unselectable text.  A string consisting solely of hyphens is displayed
as a solid horizontal line.

A menu item can be a list with the same format as MENU.  This is a submenu."
  `(progn
     (defvar ,symbol nil ,doc)
     (easy-menu-do-define (quote ,symbol) ,maps ,doc ,menu)))

;;;###autoload
(defun easy-menu-do-define (symbol maps doc menu)
  ;; We can't do anything that might differ between Emacs dialects in
  ;; `easy-menu-define' in order to make byte compiled files
  ;; compatible.  Therefore everything interesting is done in this
  ;; function. 
  (set symbol (easy-menu-create-menu (car menu) (cdr menu)))
  (fset symbol (` (lambda (event) (, doc) (interactive "@e")
		    (x-popup-menu event (, symbol)))))
  (mapcar (function (lambda (map) 
	    (define-key map (vector 'menu-bar (intern (car menu)))
	      (cons (car menu) (symbol-value symbol)))))
	  (if (keymapp maps) (list maps) maps)))

(defun easy-menu-filter-return (menu)
 "Convert MENU to the right thing to return from a menu filter.
MENU is a menu as computed by `easy-menu-define' or `easy-menu-create-menu' or
a symbol whose value is such a menu.
In Emacs a menu filter must return a menu (a keymap), in XEmacs a filter must
return a menu items list (without menu name and keywords).
This function returns the right thing in the two cases."
 (easy-menu-get-map menu nil))		; Get past indirections.

;;;###autoload
(defun easy-menu-create-menu (menu-name menu-items)
  "Create a menu called MENU-NAME with items described in MENU-ITEMS.
MENU-NAME is a string, the name of the menu.  MENU-ITEMS is a list of items
possibly preceded by keyword pairs as described in `easy-menu-define'."
  (let ((menu (make-sparse-keymap menu-name))
	prop keyword arg label enable filter visible)
    ;; Look for keywords.
    (while (and menu-items (cdr menu-items)
		(symbolp (setq keyword (car menu-items)))
		(= ?: (aref (symbol-name keyword) 0)))
      (setq arg (cadr menu-items))
      (setq menu-items (cddr menu-items))
      (cond
       ((eq keyword :filter) (setq filter arg))
       ((eq keyword :active) (setq enable (or arg ''nil)))
       ((eq keyword :label) (setq label arg))
       ((or (eq keyword :included) (eq keyword :visible))
	(setq visible (or arg ''nil)))))
    (if (equal visible ''nil) nil	; Invisible menu entry, return nil.
      (if (and visible (not (easy-menu-always-true visible)))
	  (setq prop (cons :visible (cons visible prop))))
      (if (and enable (not (easy-menu-always-true enable)))
	  (setq prop (cons :enable (cons enable prop))))
      (if filter (setq prop (cons :filter (cons filter prop))))
      (if label (setq prop (cons nil (cons label prop))))
      (while menu-items
	(easy-menu-do-add-item menu (car menu-items))
	(setq menu-items (cdr menu-items)))
      (when prop
	(setq menu (easy-menu-make-symbol menu))
	(put menu 'menu-prop prop))
      menu)))


;; Known button types.
(defvar easy-menu-button-prefix
  '((radio . :radio) (toggle . :toggle)))

(defun easy-menu-do-add-item (menu item &optional before)
  ;; Parse an item description and add the item to a keymap.  This is
  ;; the function that is used for item definition by the other easy-menu
  ;; functions.
  ;; MENU is a sparse keymap i.e. a list starting with the symbol `keymap'.
  ;; ITEM defines an item as in `easy-menu-define'.
  ;; Optional argument BEFORE is nil or a key in MENU.  If BEFORE is not nil
  ;; put item before BEFORE in MENU, otherwise if item is already present in
  ;; MENU, just change it, otherwise put it last in MENU.
  (let (name command label prop remove)
    (cond
     ((stringp item)			; An unselectable string.
      (setq label
	    (if (string-match	; If an XEmacs separator
		 "^\\(-+\\|\
--:\\(\\(no\\|\\(sing\\|doub\\)le\\(Dashed\\)?\\)Line\\|\
shadow\\(Double\\)?Etched\\(In\\|Out\\)\\(Dash\\)?\\)\\)$"
		 item) ""		; use a single line separator.
	      item)))
     ((consp item)			; A sub-menu.
      (setq label (setq name (car item)))
      (setq command (cdr item))
      (if (not (keymapp command))
	  (setq command (easy-menu-create-menu name command)))
      (if (null command)
	  ;; Invisible menu item. Don't insert into keymap.
	  (setq remove t)
	(when (and (symbolp command) (setq prop (get command 'menu-prop)))
	  (when (null (car prop))
	    (setq label (cadr prop))
	    (setq prop (cddr prop)))
	  (setq command (symbol-function command)))))
     ((vectorp item)			; An item.
      (let* ((ilen (length item))
	     (active (if (> ilen 2) (or (aref item 2) ''nil) t))
	     (no-name (not (symbolp (setq command (aref item 1)))))
	     cache cache-specified)
	(setq label (setq name (aref item 0)))
	(if no-name (setq command (easy-menu-make-symbol command)))
	(if (and (symbolp active) (= ?: (aref (symbol-name active) 0)))
	    (let ((count 2)
		  keyword arg suffix visible style selected keys)
	      (setq active nil)
	      (while (> ilen count)
		(setq keyword (aref item count))
		(setq arg (aref item (1+ count)))
		(setq count (+ 2 count))
		(cond
		 ((or (eq keyword :included) (eq keyword :visible))
		  (setq visible (or arg ''nil)))
		 ((eq keyword :key-sequence)
		  (setq cache arg cache-specified t))
		 ((eq keyword :keys) (setq keys arg no-name nil))
		 ((eq keyword :label) (setq label arg))
		 ((eq keyword :active) (setq active (or arg ''nil)))
		 ((eq keyword :suffix) (setq suffix arg))
		 ((eq keyword :style) (setq style arg))
		 ((eq keyword :selected) (setq selected (or arg ''nil)))))
	      (if suffix
		  (setq label
			(if (stringp suffix)
			    (if (stringp label) (concat label " " suffix)
			      (list 'concat label (concat " " suffix)))
			  (if (stringp label)
			      (list 'concat (concat label " ") suffix)
			    (list 'concat label " " suffix)))))
	      (cond
	       ((eq style 'button)
		(setq label (if (stringp label) (concat "[" label "]")
			      (list 'concat "[" label "]"))))
	       ((and selected
		     (setq style (assq style easy-menu-button-prefix)))
		(setq prop (cons :button
				 (cons (cons (cdr style) selected) prop)))))
	      (when (stringp keys)
		 (if (string-match "^[^\\]*\\(\\\\\\[\\([^]]+\\)]\\)[^\\]*$"
				   keys)
		     (let ((prefix
			    (if (< (match-beginning 0) (match-beginning 1))
				(substring keys 0 (match-beginning 1))))
			   (postfix
			    (if (< (match-end 1) (match-end 0))
				(substring keys (match-end 1))))
			   (cmd (intern (substring keys (match-beginning 2)
						   (match-end 2)))))
		       (setq keys (and (or prefix postfix)
				       (cons prefix postfix)))
		       (setq keys
			     (and (or keys (not (eq command cmd)))
				  (cons cmd keys))))
		   (setq cache-specified nil))
		 (if keys (setq prop (cons :keys (cons keys prop)))))
	      (if (and visible (not (easy-menu-always-true visible)))
		  (if (equal visible ''nil)
		      ;; Invisible menu item. Don't insert into keymap.
		      (setq remove t)
		    (setq prop (cons :visible (cons visible prop)))))))
	(if (and active (not (easy-menu-always-true active)))
	    (setq prop (cons :enable (cons active prop))))
	(if (and (or no-name cache-specified)
		 (or (null cache) (stringp cache) (vectorp cache)))
	    (setq prop (cons :key-sequence (cons cache prop))))))
     (t (error "Invalid menu item in easymenu")))
    (easy-menu-define-key-intern menu name
				 (and (not remove)
				      (cons 'menu-item
					    (cons label
						  (and name
						       (cons command prop)))))
				 before)))

(defun easy-menu-define-key-intern (menu key item &optional before)
  ;; This is the same as easy-menu-define-key, but it interns KEY and
  ;; BEFORE if they are strings.
  (easy-menu-define-key menu (if (stringp key) (intern key) key) item
			(if (stringp before) (intern before) before)))

(defun easy-menu-define-key (menu key item &optional before)
  ;; Add binding in MENU for KEY => ITEM.  Similar to `define-key-after'.
  ;; If KEY is not nil then delete any duplications. If ITEM is nil, then
  ;; don't insert, only delete.
  ;; Optional argument BEFORE is nil or a key in MENU.  If BEFORE is not nil
  ;; put binding before BEFORE in MENU, otherwise if binding is already
  ;; present in MENU, just change it, otherwise put it last in MENU.
  ;; KEY and BEFORE don't have to be symbols, comparison is done with equal
  ;; not with eq.
  (let ((inserted (null item))		; Fake already inserted.
	tail done)
    (while (not done)
      (cond
       ((or (setq done (or (null (cdr menu)) (keymapp (cdr menu))))
	    (and before (equal (car-safe (cadr menu)) before)))
	;; If key is nil, stop here, otherwise keep going past the
	;; inserted element so we can delete any duplications that come
	;; later.
	(if (null key) (setq done t))
	(unless inserted		; Don't insert more than once.
	  (setcdr menu (cons (cons key item) (cdr menu)))
	  (setq inserted t)
	  (setq menu (cdr menu)))
	(setq menu (cdr menu)))
       ((and key (equal (car-safe (cadr menu)) key))
	(if (or inserted		; Already inserted or
		(and before		;  wanted elsewhere and
		     (setq tail (cddr menu)) ; not last item and not
		     (not (keymapp tail))
		     (not (equal (car-safe (car tail)) before)))) ; in position
	    (setcdr menu (cddr menu))	; Remove item.
	  (setcdr (cadr menu) item)	; Change item.
	  (setq inserted t)
	  (setq menu (cdr menu))))
       (t (setq menu (cdr menu)))))))
       
(defun easy-menu-always-true (x)
  ;; Return true if X never evaluates to nil.
  (if (consp x) (and (eq (car x) 'quote) (cadr x))
    (or (eq x t) (not (symbolp x)))))

(defvar easy-menu-item-count 0)

(defun easy-menu-make-symbol (callback)
  ;; Return a unique symbol with CALLBACK as function value.
  (let ((command
	 (make-symbol (format "menu-function-%d" easy-menu-item-count))))
    (setq easy-menu-item-count (1+ easy-menu-item-count))
    (fset command
	  (if (keymapp callback) callback
	    `(lambda () (interactive) ,callback)))
    command))

;;;###autoload
(defun easy-menu-change (path name items &optional before)
  "Change menu found at PATH as item NAME to contain ITEMS.
PATH is a list of strings for locating the menu containing NAME in the
menu bar.  ITEMS is a list of menu items, as in `easy-menu-define'.
These items entirely replace the previous items in that map.
If NAME is not present in the menu located by PATH, then add item NAME to
that menu. If the optional argument BEFORE is present add NAME in menu
just before BEFORE, otherwise add at end of menu.

Either call this from `menu-bar-update-hook' or use a menu filter,
to implement dynamic menus."
  (easy-menu-add-item nil path (cons name items) before))

;; XEmacs needs the following two functions to add and remove menus.
;; In Emacs this is done automatically when switching keymaps, so
;; here easy-menu-remove is a noop and easy-menu-add only precalculates
;; equivalent keybindings (if easy-menu-precalculate-equivalent-keybindings
;; is on).
(defun easy-menu-remove (menu))

(defun easy-menu-add (menu &optional map)
  "Maybe precalculate equivalent key bindings.
Do it if `easy-menu-precalculate-equivalent-keybindings' is on,"
  (when easy-menu-precalculate-equivalent-keybindings
    (if (and (symbolp menu) (not (keymapp menu)) (boundp menu))
	(setq menu (symbol-value menu)))
    (if (keymapp menu) (x-popup-menu nil menu))))

(defun easy-menu-add-item (map path item &optional before)
  "To the submenu of MAP with path PATH, add ITEM.
If ITEM is already present in this submenu, then this item will be changed.
otherwise ITEM will be added at the end of the submenu, unless the optional
argument BEFORE is present, in which case ITEM will instead be added
before the item named BEFORE.

MAP should normally be a keymap; nil stands for the global menu-bar keymap.
It can also be a symbol, which has earlier been used as the first
argument in a call to `easy-menu-define', or the value of such a symbol.

PATH is a list of strings for locating the submenu where ITEM is to be
added.  If PATH is nil, MAP itself is used.  Otherwise, the first
element should be the name of a submenu directly under MAP.  This
submenu is then traversed recursively with the remaining elements of PATH.

ITEM is either defined as in `easy-menu-define' or a non-nil value returned
by `easy-menu-item-present-p' or `easy-menu-remove-item' or a menu defined
earlier by `easy-menu-define' or `easy-menu-create-menu'."
  (setq map (easy-menu-get-map map path))
  (if (and (consp item) (consp (cdr item)) (eq (cadr item) 'menu-item))
      ;; This is a value returned by `easy-menu-item-present-p' or
      ;; `easy-menu-remove-item'.
      (easy-menu-define-key-intern map (car item) (cdr item) before)
    (if (or (keymapp item)
	    (and (symbolp item) (keymapp (symbol-value item))))
	;; Item is a keymap, find the prompt string and use as item name.
	(let ((tail (easy-menu-get-map item nil)) name)
	  (if (not (keymapp item)) (setq item tail))
	  (while (and (null name) (consp (setq tail (cdr tail)))
		      (not (keymapp tail)))
	    (if (stringp (car tail)) (setq name (car tail)) ; Got a name.
	      (setq tail (cdr tail))))
	  (setq item (cons name item))))
    (easy-menu-do-add-item map item before)))

(defun easy-menu-item-present-p (map path name)
  "In submenu of MAP with path PATH, return true iff item NAME is present.
MAP and PATH are defined as in `easy-menu-add-item'.
NAME should be a string, the name of the element to be looked for."
  (easy-menu-return-item (easy-menu-get-map map path) name))

(defun easy-menu-remove-item (map path name)
  "From submenu of MAP with path PATH remove item NAME.
MAP and PATH are defined as in `easy-menu-add-item'.
NAME should be a string, the name of the element to be removed."
  (setq map (easy-menu-get-map map path))
  (let ((ret (easy-menu-return-item map name)))
    (if ret (easy-menu-define-key-intern map name nil))
    ret))

(defun easy-menu-return-item (menu name)
  ;; In menu MENU try to look for menu item with name NAME.
  ;; If a menu item is found, return (NAME . item), otherwise return nil.
  ;; If item is an old format item, a new format item is returned.
  (let ((item (lookup-key menu (vector (intern name))))
	ret enable cache label)
    (cond
     ((or (keymapp item) (eq (car-safe item) 'menu-item))
      (cons name item))			; Keymap or new menu format
     ((stringp (car-safe item))
      ;; This is the old menu format. Convert it to new format.
      (setq label (car item))
      (when (stringp (car (setq item (cdr item)))) ; Got help string
	(setq ret (list :help (car item)))
	(setq item (cdr item)))
      (when (and (consp item) (consp (car item))
		 (or (null (caar item)) (numberp (caar item))))
	(setq cache (car item))		; Got cache
	(setq item (cdr item)))
      (and (symbolp item) (setq enable (get item 'menu-enable))	; Got enable
	   (setq ret (cons :enable (cons enable ret))))
      (if cache (setq ret (cons cache ret)))
      (cons name (cons 'menu-enable (cons label (cons item ret))))))))

(defun easy-menu-get-map (map path)
  ;; Return a sparse keymap in which to add or remove an item.
  ;; MAP and PATH are as defined in `easy-menu-add-item'.
  (if (null map)
      (let ((local (and (current-local-map)
			(lookup-key (current-local-map)
				    (vconcat '(menu-bar) (mapcar 'intern path)))))
	    (global (lookup-key global-map
				(vconcat '(menu-bar) (mapcar 'intern path)))))
	(if (and local (not (integerp local)))
	    (setq map local)
	  (if (and global (not (integerp global)))
	      (setq map global)
	    (setq map (make-sparse-keymap))
	    (define-key (current-local-map)
	      (vconcat '(menu-bar) (mapcar 'intern path)) map))))
    (if (and (symbolp map) (not (keymapp map)))
	(setq map (symbol-value map)))
    (if path (setq map (lookup-key map (vconcat (mapcar 'intern path))))))
  (while (and (symbolp map) (keymapp map))
    (setq map (symbol-function map)))
  (unless map
    (error "Menu specified in easy-menu is not defined"))
  (or (keymapp map) (error "Malformed menu in easy-menu: (%s)" map))
  map)

(provide 'easymenu)

;;; easymenu.el ends here
