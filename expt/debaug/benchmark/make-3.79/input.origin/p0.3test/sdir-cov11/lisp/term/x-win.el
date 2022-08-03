;;; x-win.el --- parse switches controlling interface with X window system

;; Copyright (C) 1993, 1994 Free Software Foundation, Inc.

;; Author: FSF
;; Keywords: terminals

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

;; X-win.el:  this file is loaded from ../lisp/startup.el when it recognizes
;; that X windows are to be used.  Command line switches are parsed and those
;; pertaining to X are processed and removed from the command line.  The
;; X display is opened and hooks are set for popping up the initial window.

;; startup.el will then examine startup files, and eventually call the hooks
;; which create the first window (s).

;;; Code:

;; These are the standard X switches from the Xt Initialize.c file of
;; Release 4.

;; Command line		Resource Manager string

;; +rv			*reverseVideo
;; +synchronous		*synchronous
;; -background		*background
;; -bd			*borderColor
;; -bg			*background
;; -bordercolor		*borderColor
;; -borderwidth		.borderWidth
;; -bw			.borderWidth
;; -display		.display
;; -fg			*foreground
;; -fn			*font
;; -font		*font
;; -foreground		*foreground
;; -geometry		.geometry
;; -i			.iconType
;; -itype		.iconType
;; -iconic		.iconic
;; -name		.name
;; -reverse		*reverseVideo
;; -rv			*reverseVideo
;; -selectionTimeout    .selectionTimeout
;; -synchronous		*synchronous
;; -xrm

;; An alist of X options and the function which handles them.  See
;; ../startup.el.

(if (not (eq window-system 'x))
    (error "%s: Loading x-win.el but not compiled for X" (invocation-name)))
	 
(require 'frame)
(require 'mouse)
(require 'scroll-bar)
(require 'faces)
(require 'select)
(require 'menu-bar)
(if (fboundp 'new-fontset)
    (require 'fontset))

(defvar x-invocation-args)

(defvar x-command-line-resources nil)

;; Handler for switches of the form "-switch value" or "-switch".
(defun x-handle-switch (switch)
  (let ((aelt (assoc switch command-line-x-option-alist)))
    (if aelt
	(let ((param (nth 3 aelt))
	      (value (nth 4 aelt)))
	  (if value
	      (setq default-frame-alist
		    (cons (cons param value)
			  default-frame-alist))
	    (setq default-frame-alist
		  (cons (cons param
			      (car x-invocation-args))
			default-frame-alist)
		  x-invocation-args (cdr x-invocation-args)))))))

;; Handler for switches of the form "-switch n"
(defun x-handle-numeric-switch (switch)
  (let ((aelt (assoc switch command-line-x-option-alist)))
    (if aelt
	(let ((param (nth 3 aelt)))
	  (setq default-frame-alist
		(cons (cons param
			    (string-to-int (car x-invocation-args)))
		      default-frame-alist)
		x-invocation-args
		(cdr x-invocation-args))))))

;; Make -iconic apply only to the initial frame!
(defun x-handle-iconic (switch)
  (setq initial-frame-alist
	(cons '(visibility . icon) initial-frame-alist)))

;; Handle the -xrm option.
(defun x-handle-xrm-switch (switch)
  (or (consp x-invocation-args)
      (error "%s: missing argument to `%s' option" (invocation-name) switch))
  (setq x-command-line-resources (car x-invocation-args))
  (setq x-invocation-args (cdr x-invocation-args)))

;; Handle the geometry option
(defun x-handle-geometry (switch)
  (let ((geo (x-parse-geometry (car x-invocation-args))))
    (setq initial-frame-alist
	  (append initial-frame-alist
		  (if (or (assq 'left geo) (assq 'top geo))
		      '((user-position . t)))
		  (if (or (assq 'height geo) (assq 'width geo))
		      '((user-size . t)))
		  geo)
	  x-invocation-args (cdr x-invocation-args))))

;; Handle the -name option.  Set the variable x-resource-name
;; to the option's operand; set the name of
;; the initial frame, too.
(defun x-handle-name-switch (switch)
  (or (consp x-invocation-args)
      (error "%s: missing argument to `%s' option" (invocation-name) switch))
  (setq x-resource-name (car x-invocation-args)
	x-invocation-args (cdr x-invocation-args))
  (setq initial-frame-alist (cons (cons 'name x-resource-name)
				  initial-frame-alist)))

(defvar x-display-name nil
  "The X display name specifying server and X frame.")

(defun x-handle-display (switch)
  (setq x-display-name (car x-invocation-args)
	x-invocation-args (cdr x-invocation-args))
  ;; Make subshell programs see the same DISPLAY value Emacs really uses.
  ;; Note that this isn't completely correct, since Emacs can use
  ;; multiple displays.  However, there is no way to tell an already
  ;; running subshell which display the user is currently typing on.
  (setenv "DISPLAY" x-display-name))

(defun x-handle-args (args)
  "Process the X-related command line options in ARGS.
This is done before the user's startup file is loaded.  They are copied to
`x-invocation-args', from which the X-related things are extracted, first
the switch (e.g., \"-fg\") in the following code, and possible values
\(e.g., \"black\") in the option handler code (e.g., x-handle-switch).
This function returns ARGS minus the arguments that have been processed."
  ;; We use ARGS to accumulate the args that we don't handle here, to return.
  (setq x-invocation-args args
	args nil)
  (while (and x-invocation-args
	      (not (equal (car x-invocation-args) "--")))
    (let* ((this-switch (car x-invocation-args))
	   (orig-this-switch this-switch)
	   completion argval aelt handler)
      (setq x-invocation-args (cdr x-invocation-args))
      ;; Check for long options with attached arguments
      ;; and separate out the attached option argument into argval.
      (if (string-match "^--[^=]*=" this-switch)
	  (setq argval (substring this-switch (match-end 0))
		this-switch (substring this-switch 0 (1- (match-end 0)))))
      ;; Complete names of long options.
      (if (string-match "^--" this-switch)
	  (progn
	    (setq completion (try-completion this-switch command-line-x-option-alist))
	    (if (eq completion t)
		;; Exact match for long option.
		nil
	      (if (stringp completion)
		  (let ((elt (assoc completion command-line-x-option-alist)))
		    ;; Check for abbreviated long option.
		    (or elt
			(error "Option `%s' is ambiguous" this-switch))
		    (setq this-switch completion))))))
      (setq aelt (assoc this-switch command-line-x-option-alist))
      (if aelt (setq handler (nth 2 aelt)))
      (if handler
	  (if argval
	      (let ((x-invocation-args
		     (cons argval x-invocation-args)))
		(funcall handler this-switch))
	    (funcall handler this-switch))
	(setq args (cons orig-this-switch args)))))
  (nconc (nreverse args) x-invocation-args))

;;
;; Standard X cursor shapes, courtesy of Mr. Fox, who wanted ALL of them.
;;

(defconst x-pointer-X-cursor 0)
(defconst x-pointer-arrow 2)
(defconst x-pointer-based-arrow-down 4)
(defconst x-pointer-based-arrow-up 6)
(defconst x-pointer-boat 8)
(defconst x-pointer-bogosity 10)
(defconst x-pointer-bottom-left-corner 12)
(defconst x-pointer-bottom-right-corner 14)
(defconst x-pointer-bottom-side 16)
(defconst x-pointer-bottom-tee 18)
(defconst x-pointer-box-spiral 20)
(defconst x-pointer-center-ptr 22)
(defconst x-pointer-circle 24)
(defconst x-pointer-clock 26)
(defconst x-pointer-coffee-mug 28)
(defconst x-pointer-cross 30)
(defconst x-pointer-cross-reverse 32)
(defconst x-pointer-crosshair 34)
(defconst x-pointer-diamond-cross 36)
(defconst x-pointer-dot 38)
(defconst x-pointer-dotbox 40)
(defconst x-pointer-double-arrow 42)
(defconst x-pointer-draft-large 44)
(defconst x-pointer-draft-small 46)
(defconst x-pointer-draped-box 48)
(defconst x-pointer-exchange 50)
(defconst x-pointer-fleur 52)
(defconst x-pointer-gobbler 54)
(defconst x-pointer-gumby 56)
(defconst x-pointer-hand1 58)
(defconst x-pointer-hand2 60)
(defconst x-pointer-heart 62)
(defconst x-pointer-icon 64)
(defconst x-pointer-iron-cross 66)
(defconst x-pointer-left-ptr 68)
(defconst x-pointer-left-side 70)
(defconst x-pointer-left-tee 72)
(defconst x-pointer-leftbutton 74)
(defconst x-pointer-ll-angle 76)
(defconst x-pointer-lr-angle 78)
(defconst x-pointer-man 80)
(defconst x-pointer-middlebutton 82)
(defconst x-pointer-mouse 84)
(defconst x-pointer-pencil 86)
(defconst x-pointer-pirate 88)
(defconst x-pointer-plus 90)
(defconst x-pointer-question-arrow 92)
(defconst x-pointer-right-ptr 94)
(defconst x-pointer-right-side 96)
(defconst x-pointer-right-tee 98)
(defconst x-pointer-rightbutton 100)
(defconst x-pointer-rtl-logo 102)
(defconst x-pointer-sailboat 104)
(defconst x-pointer-sb-down-arrow 106)
(defconst x-pointer-sb-h-double-arrow 108)
(defconst x-pointer-sb-left-arrow 110)
(defconst x-pointer-sb-right-arrow 112)
(defconst x-pointer-sb-up-arrow 114)
(defconst x-pointer-sb-v-double-arrow 116)
(defconst x-pointer-shuttle 118)
(defconst x-pointer-sizing 120)
(defconst x-pointer-spider 122)
(defconst x-pointer-spraycan 124)
(defconst x-pointer-star 126)
(defconst x-pointer-target 128)
(defconst x-pointer-tcross 130)
(defconst x-pointer-top-left-arrow 132)
(defconst x-pointer-top-left-corner 134)
(defconst x-pointer-top-right-corner 136)
(defconst x-pointer-top-side 138)
(defconst x-pointer-top-tee 140)
(defconst x-pointer-trek 142)
(defconst x-pointer-ul-angle 144)
(defconst x-pointer-umbrella 146)
(defconst x-pointer-ur-angle 148)
(defconst x-pointer-watch 150)
(defconst x-pointer-xterm 152)

;;
;; Available colors
;;

(defvar x-colors '("aquamarine"
		   "Aquamarine"
		   "medium aquamarine"
		   "MediumAquamarine"
		   "black"
		   "Black"
		   "blue"
		   "Blue"
		   "cadet blue"
		   "CadetBlue"
		   "cornflower blue"
		   "CornflowerBlue"
		   "dark slate blue"
		   "DarkSlateBlue"
		   "light blue"
		   "LightBlue"
		   "light steel blue"
		   "LightSteelBlue"
		   "medium blue"
		   "MediumBlue"
		   "medium slate blue"
		   "MediumSlateBlue"
		   "midnight blue"
		   "MidnightBlue"
		   "navy blue"
		   "NavyBlue"
		   "navy"
		   "Navy"
		   "sky blue"
		   "SkyBlue"
		   "slate blue"
		   "SlateBlue"
		   "steel blue"
		   "SteelBlue"
		   "coral"
		   "Coral"
		   "cyan"
		   "Cyan"
		   "firebrick"
		   "Firebrick"
		   "brown"
		   "Brown"
		   "gold"
		   "Gold"
		   "goldenrod"
		   "Goldenrod"
		   "green"
		   "Green"
		   "dark green"
		   "DarkGreen"
		   "dark olive green"
		   "DarkOliveGreen"
		   "forest green"
		   "ForestGreen"
		   "lime green"
		   "LimeGreen"
		   "medium sea green"
		   "MediumSeaGreen"
		   "medium spring green"
		   "MediumSpringGreen"
		   "pale green"
		   "PaleGreen"
		   "sea green"
		   "SeaGreen"
		   "spring green"
		   "SpringGreen"
		   "yellow green"
		   "YellowGreen"
		   "dark slate grey"
		   "DarkSlateGrey"
		   "dark slate gray"
		   "DarkSlateGray"
		   "dim grey"
		   "DimGrey"
		   "dim gray"
		   "DimGray"
		   "light grey"
		   "LightGrey"
		   "light gray"
		   "LightGray"
		   "gray"
		   "grey"
		   "Gray"
		   "Grey"
		   "khaki"
		   "Khaki"
		   "magenta"
		   "Magenta"
		   "maroon"
		   "Maroon"
		   "orange"
		   "Orange"
		   "orchid"
		   "Orchid"
		   "dark orchid"
		   "DarkOrchid"
		   "medium orchid"
		   "MediumOrchid"
		   "pink"
		   "Pink"
		   "plum"
		   "Plum"
		   "red"
		   "Red"
		   "indian red"
		   "IndianRed"
		   "medium violet red"
		   "MediumVioletRed"
		   "orange red"
		   "OrangeRed"
		   "violet red"
		   "VioletRed"
		   "salmon"
		   "Salmon"
		   "sienna"
		   "Sienna"
		   "tan"
		   "Tan"
		   "thistle"
		   "Thistle"
		   "turquoise"
		   "Turquoise"
		   "dark turquoise"
		   "DarkTurquoise"
		   "medium turquoise"
		   "MediumTurquoise"
		   "violet"
		   "Violet"
		   "blue violet"
		   "BlueViolet"
		   "wheat"
		   "Wheat"
		   "white"
		   "White"
		   "yellow"
		   "Yellow"
		   "green yellow"
		   "GreenYellow")
  "The list of X colors from the `rgb.txt' file.")

(defun x-defined-colors (&optional frame)
  "Return a list of colors supported for a particular frame.
The argument FRAME specifies which frame to try.
The value may be different for frames on different X displays."
  (or frame (setq frame (selected-frame)))
  (let ((all-colors x-colors)
	(this-color nil)
	(defined-colors nil))
    (while all-colors
      (setq this-color (car all-colors)
	    all-colors (cdr all-colors))
      (and (face-color-supported-p frame this-color t)
	   (setq defined-colors (cons this-color defined-colors))))
    defined-colors))

;;;; Function keys

(defun iconify-or-deiconify-frame ()
  "Iconify the selected frame, or deiconify if it's currently an icon."
  (interactive)
  (if (eq (cdr (assq 'visibility (frame-parameters))) t)
      (iconify-frame)
    (make-frame-visible)))

(substitute-key-definition 'suspend-emacs 'iconify-or-deiconify-frame
			   global-map)

;; Map certain keypad keys into ASCII characters
;; that people usually expect.
(define-key function-key-map [backspace] [127])
(define-key function-key-map [delete] [127])
(define-key function-key-map [tab] [?\t])
(define-key function-key-map [linefeed] [?\n])
(define-key function-key-map [clear] [?\C-l])
(define-key function-key-map [return] [?\C-m])
(define-key function-key-map [escape] [?\e])
(define-key function-key-map [M-backspace] [?\M-\d])
(define-key function-key-map [M-delete] [?\M-\d])
(define-key function-key-map [M-tab] [?\M-\t])
(define-key function-key-map [M-linefeed] [?\M-\n])
(define-key function-key-map [M-clear] [?\M-\C-l])
(define-key function-key-map [M-return] [?\M-\C-m])
(define-key function-key-map [M-escape] [?\M-\e])
(define-key function-key-map [iso-lefttab] [backtab])

;; These tell read-char how to convert
;; these special chars to ASCII.
(put 'backspace 'ascii-character 127)
(put 'delete 'ascii-character 127)
(put 'tab 'ascii-character ?\t)
(put 'linefeed 'ascii-character ?\n)
(put 'clear 'ascii-character 12)
(put 'return 'ascii-character 13)
(put 'escape 'ascii-character ?\e)

(defun vendor-specific-keysyms (vendor)
  "Return the appropriate value of system-key-alist for VENDOR.
VENDOR is a string containing the name of the X Server's vendor,
as returned by (x-server-vendor)."
  (cond ((string-equal vendor "Apollo Computer Inc.")
	 '((65280 . linedel)
	   (65281 . chardel)
	   (65282 . copy)
	   (65283 . cut)
	   (65284 . paste)
	   (65285 . move)
	   (65286 . grow)
	   (65287 . cmd)
	   (65288 . shell)
	   (65289 . leftbar)
	   (65290 . rightbar)
	   (65291 . leftbox)
	   (65292 . rightbox)
	   (65293 . upbox)
	   (65294 . downbox)
	   (65295 . pop)
	   (65296 . read)
	   (65297 . edit)
	   (65298 . save)
	   (65299 . exit)
	   (65300 . repeat)))
	((or (string-equal vendor "Hewlett-Packard Incorporated")
	     (string-equal vendor "Hewlett-Packard Company"))
	 '((  168 . mute-acute)
	   (  169 . mute-grave)
	   (  170 . mute-asciicircum)
	   (  171 . mute-diaeresis)
	   (  172 . mute-asciitilde)
	   (  175 . lira)
	   (  190 . guilder)
	   (  252 . block)
	   (  256 . longminus)
	   (65388 . reset)
	   (65389 . system)
	   (65390 . user)
	   (65391 . clearline)
	   (65392 . insertline)
	   (65393 . deleteline)
	   (65394 . insertchar)
	   (65395 . deletechar)
	   (65396 . backtab)
	   (65397 . kp-backtab)))
	((or (string-equal vendor "X11/NeWS - Sun Microsystems Inc.")
	     (string-equal vendor "X Consortium"))
	 '((392976 . f36)
	   (392977 . f37)
	   (393056 . req)
	   ;; These are for Sun under X11R6
	   (393072 . props)
	   (393073 . front)
	   (393074 . copy)
	   (393075 . open)
	   (393076 . paste)
	   (393077 . cut)))
	(t
	 ;; This is used by DEC's X server.
	 '((65280 . remove)))))


;;;; Selections and cut buffers

;;; We keep track of the last text selected here, so we can check the
;;; current selection against it, and avoid passing back our own text
;;; from x-cut-buffer-or-selection-value.
(defvar x-last-selected-text nil)

;;; It is said that overlarge strings are slow to put into the cut buffer.
;;; Note this value is overridden below.
(defvar x-cut-buffer-max 20000
  "Max number of characters to put in the cut buffer.")

(defvar x-select-enable-clipboard nil
  "Non-nil means cutting and pasting uses the clipboard.
This is in addition to the primary selection.")

;;; Make TEXT, a string, the primary X selection.
;;; Also, set the value of X cut buffer 0, for backward compatibility
;;; with older X applications.
;;; gildea@lcs.mit.edu says it's not desirable to put kills
;;; in the clipboard.
(defun x-select-text (text &optional push)
  ;; Don't send the cut buffer too much text.
  ;; It becomes slow, and if really big it causes errors.
  (if (< (length text) x-cut-buffer-max)
      (x-set-cut-buffer text push)
    (x-set-cut-buffer "" push))
  (x-set-selection 'PRIMARY text)
  (if x-select-enable-clipboard
      (x-set-selection 'CLIPBOARD text))
  (setq x-last-selected-text text))

;;; Return the value of the current X selection.
;;; Consult the selection, then the cut buffer.  Treat empty strings
;;; as if they were unset.
;;; If this function is called twice and finds the same text,
;;; it returns nil the second time.  This is so that a single
;;; selection won't be added to the kill ring over and over.
(defun x-cut-buffer-or-selection-value ()
  (let (text)
    (when x-select-enable-clipboard
      (if (null text) 
	  (condition-case c
	      (setq text (x-get-selection 'CLIPBOARD 'COMPOUND_TEXT))
	    (error nil)))
      (if (null text) 
	  (condition-case c
	      (setq text (x-get-selection 'CLIPBOARD 'STRING))
	    (error nil)))
      (if (string= text "") (setq text nil)))

    ;; Don't die if x-get-selection signals an error.
    (if (null text) 
	(condition-case c
	    (setq text (x-get-selection 'PRIMARY 'COMPOUND_TEXT))
	  (error nil)))
    (if (null text) 
	(condition-case c
	    (setq text (x-get-selection 'PRIMARY 'STRING))
	  (error nil)))
    (if (string= text "") (setq text nil))

    (or text (setq text (x-get-cut-buffer 0)))
    (if (string= text "") (setq text nil))

    (cond
     ((not text) nil)
     ((eq text x-last-selected-text) nil)
     ((string= text x-last-selected-text)
      ;; Record the newer string, so subsequent calls can use the `eq' test.
      (setq x-last-selected-text text)
      nil)
     (t
      (setq x-last-selected-text text)))))


;;; Do the actual X Windows setup here; the above code just defines
;;; functions and variables that we use now.

(setq command-line-args (x-handle-args command-line-args))

;;; Make sure we have a valid resource name.
(or (stringp x-resource-name)
    (let (i)
      (setq x-resource-name (invocation-name))

      ;; Change any . or * characters in x-resource-name to hyphens,
      ;; so as not to choke when we use it in X resource queries.
      (while (setq i (string-match "[.*]" x-resource-name))
	(aset x-resource-name i ?-))))

;; For the benefit of older Emacses (19.27 and earlier) that are sharing
;; the same lisp directory, don't pass the third argument unless we seem
;; to have the multi-display support.
(if (fboundp 'x-close-connection)
    (x-open-connection (or x-display-name
			   (setq x-display-name (getenv "DISPLAY")))
		       x-command-line-resources
		       ;; Exit Emacs with fatal error if this fails.
		       t)
  (x-open-connection (or x-display-name
			 (setq x-display-name (getenv "DISPLAY")))
		     x-command-line-resources))

(setq frame-creation-function 'x-create-frame-with-faces)

(setq x-cut-buffer-max (min (- (/ (x-server-max-request-size) 2) 100)
			    x-cut-buffer-max))

(if (fboundp 'new-fontset)
    (progn
      ;; Create the standard fontset.
      (create-fontset-from-fontset-spec standard-fontset-spec t)

      ;; Create fontset specified in X resources "Fontset-N" (N is 0, 1, ...).
      (create-fontset-from-x-resource)

      ;; Try to create a fontset from a font specification which comes
      ;; from initial-frame-alist, default-frame-alist, or X resource.
      ;; A font specification in command line argument (i.e. -fn XXXX)
      ;; should be already in default-frame-alist as a `font'
      ;; parameter.  However, any font specifications in site-start
      ;; library, user's init file (.emacs), and default.el are not
      ;; yet handled here.

      (let ((font (or (cdr (assq 'font initial-frame-alist))
		      (cdr (assq 'font default-frame-alist))
		      (x-get-resource "font" "Font")))
	    xlfd-fields resolved-name)
	(if (and font
		 (not (query-fontset font))
		 (setq resolved-name (x-resolve-font-name font))
		 (setq xlfd-fields (x-decompose-font-name font)))
	    (if (string= "fontset"
			 (aref xlfd-fields xlfd-regexp-registry-subnum))
		(new-fontset font (x-complement-fontset-spec xlfd-fields nil))
	      ;; Create a fontset from FONT.  The fontset name is
	      ;; generated from FONT.  Create style variants of the
	      ;; fontset too.  Font names in the variants are
	      ;; generated automatially unless X resources
	      ;; XXX.attribyteFont explicitly specify them.
	      (let ((styles (mapcar 'car x-style-funcs-alist))
		    (faces '(bold italic bold-italic))
		    face face-font fontset fontset-spec)
		(while faces
		  (setq face (car faces))
		  (setq face-font (x-get-resource (concat (symbol-name face)
							  ".attributeFont")
						  "Face.AttributeFont"))
		  (if face-font
		      (setq styles (cons (cons face face-font)
					 (delq face styles))))
		  (setq faces (cdr faces)))
		(aset xlfd-fields xlfd-regexp-foundry-subnum nil)
		(aset xlfd-fields xlfd-regexp-family-subnum nil)
		(aset xlfd-fields xlfd-regexp-registry-subnum "fontset")
		(aset xlfd-fields xlfd-regexp-encoding-subnum "startup")
		;; The fontset name should have concrete values in
		;; weight and slant field.
		(let ((weight (aref xlfd-fields xlfd-regexp-weight-subnum))
		      (slant (aref xlfd-fields xlfd-regexp-slant-subnum))
		      xlfd-temp)
		  (if (and (or (not weight) (string-match "[*?]*" weight))
			   (setq xlfd-temp
				 (x-decompose-font-name resolved-name)))
		      (aset xlfd-fields xlfd-regexp-weight-subnum
			    (aref xlfd-temp xlfd-regexp-weight-subnum)))
		  (if (and (or (not slant) (string-match "[*?]*" slant))
			   (or xlfd-temp
			       (setq xlfd-temp
				     (x-decompose-font-name resolved-name))))
		      (aset xlfd-fields xlfd-regexp-slant-subnum
			    (aref xlfd-temp xlfd-regexp-slant-subnum))))
		(setq fontset (x-compose-font-name xlfd-fields))
		(create-fontset-from-fontset-spec
		 (concat fontset ", ascii:" font) styles)
		))))))

;; Sun expects the menu bar cut and paste commands to use the clipboard.
;; This has ,? to match both on Sunos and on Solaris.
(if (string-match "Sun Microsystems,? Inc\\."
		  (x-server-vendor))
    (menu-bar-enable-clipboard))

;; Apply a geometry resource to the initial frame.  Put it at the end
;; of the alist, so that anything specified on the command line takes
;; precedence.
(let* ((res-geometry (x-get-resource "geometry" "Geometry"))
       parsed)
  (if res-geometry
      (progn
	(setq parsed (x-parse-geometry res-geometry))
	;; If the resource specifies a position,
	;; call the position and size "user-specified".
	(if (or (assq 'top parsed) (assq 'left parsed))
	    (setq parsed (cons '(user-position . t)
			       (cons '(user-size . t) parsed))))
	;; All geometry parms apply to the initial frame.
	(setq initial-frame-alist (append initial-frame-alist parsed))
	;; The size parms apply to all frames.
	(if (assq 'height parsed)
	    (setq default-frame-alist
		  (cons (cons 'height (cdr (assq 'height parsed)))
			default-frame-alist)))
	(if (assq 'width parsed)
	    (setq default-frame-alist
		  (cons (cons 'width (cdr (assq 'width parsed)))
			default-frame-alist))))))

;; Check the reverseVideo resource.
(let ((case-fold-search t))
  (let ((rv (x-get-resource "reverseVideo" "ReverseVideo")))
    (if (and rv
	     (string-match "^\\(true\\|yes\\|on\\)$" rv))
	(setq default-frame-alist
	      (cons '(reverse . t) default-frame-alist)))))

;; Set x-selection-timeout, measured in milliseconds.
(let ((res-selection-timeout
       (x-get-resource "selectionTimeout" "SelectionTimeout")))
  (setq x-selection-timeout 20000)
  (if res-selection-timeout
      (setq x-selection-timeout (string-to-number res-selection-timeout))))

(defun x-win-suspend-error ()
  (error "Suspending an emacs running under X makes no sense"))
(add-hook 'suspend-hook 'x-win-suspend-error)

;;; Arrange for the kill and yank functions to set and check the clipboard.
(setq interprogram-cut-function 'x-select-text)
(setq interprogram-paste-function 'x-cut-buffer-or-selection-value)

;;; Turn off window-splitting optimization; X is usually fast enough
;;; that this is only annoying.
(setq split-window-keep-point t)

;; Don't show the frame name; that's redundant with X.
(setq-default mode-line-frame-identification "  ")

;;; Motif direct handling of f10 wasn't working right,
;;; So temporarily we've turned it off in lwlib-Xm.c
;;; and turned the Emacs f10 back on.
;;; ;; Motif normally handles f10 itself, so don't try to handle it a second time.
;;; (if (featurep 'motif)
;;;     (global-set-key [f10] 'ignore))

;;; x-win.el ends here
