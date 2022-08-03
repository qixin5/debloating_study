;;; mule-cmds.el --- Commands for mulitilingual environment

;; Copyright (C) 1995 Electrotechnical Laboratory, JAPAN.
;; Licensed to the Free Software Foundation.

;; Keywords: mule, multilingual

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

;;; Code:

;;; MULE related key bindings and menus.

(defvar mule-keymap (make-sparse-keymap)
  "Keymap for Mule (Multilingual environment) specific commands.")

;; Keep "C-x C-m ..." for mule specific commands.
(define-key ctl-x-map "\C-m" mule-keymap)

(define-key mule-keymap "f" 'set-buffer-file-coding-system)
(define-key mule-keymap "t" 'set-terminal-coding-system)
(define-key mule-keymap "k" 'set-keyboard-coding-system)
(define-key mule-keymap "p" 'set-buffer-process-coding-system)
(define-key mule-keymap "x" 'set-selection-coding-system)
(define-key mule-keymap "X" 'set-next-selection-coding-system)
(define-key mule-keymap "\C-\\" 'set-input-method)
(define-key mule-keymap "c" 'universal-coding-system-argument)
(define-key mule-keymap "l" 'set-language-environment)

(define-key help-map "\C-L" 'describe-language-environment)
(define-key help-map "L" 'describe-language-environment)
(define-key help-map "\C-\\" 'describe-input-method)
(define-key help-map "I" 'describe-input-method)
(define-key help-map "C" 'describe-coding-system)
(define-key help-map "h" 'view-hello-file)

(defvar mule-menu-keymap (make-sparse-keymap "Mule")
  "Keymap for Mule (Multilingual environment) menu specific commands.")

(define-key global-map [menu-bar mule]
  `(menu-item "Mule" ,mule-menu-keymap
	      :visible default-enable-multibyte-characters))

(setq menu-bar-final-items (cons 'mule menu-bar-final-items))

(defvar describe-language-environment-map
  (make-sparse-keymap "Describe Language Environment"))

(defvar setup-language-environment-map
  (make-sparse-keymap "Set Language Environment"))

(defvar set-coding-system-map
  (make-sparse-keymap "Set Coding System"))

(define-key-after mule-menu-keymap [describe-language-environment]
  (cons "Describe Language Environment" describe-language-environment-map)
  t)
(define-key-after mule-menu-keymap [set-language-environment]
  (cons "Set Language Environment" setup-language-environment-map)
  t)
(define-key-after mule-menu-keymap [mouse-set-font]
  '("Set Font/Fontset" . mouse-set-font)
  t)
(define-key-after mule-menu-keymap [separator-mule]
  '("--")
  t)
(define-key-after mule-menu-keymap [toggle-input-method]
  '("Toggle Input Method" . toggle-input-method)
  t)
(define-key-after mule-menu-keymap [set-input-method]
  '("Select Input Method" . set-input-method)
  t)
(define-key-after mule-menu-keymap [describe-input-method]
  '("Describe Input Method" . describe-input-method)
  t)
(define-key-after mule-menu-keymap [separator-input-method]
  '("--")
  t)
(define-key-after mule-menu-keymap [describe-coding-system]
  '("Describe Coding Systems" . describe-coding-system)
  t)
(define-key-after mule-menu-keymap [set-various-coding-system]
  (cons "Set Coding System" set-coding-system-map)
  t)
(define-key-after mule-menu-keymap [separator-coding-system]
  '("--")
  t)
(define-key-after mule-menu-keymap [mule-diag]
  '("Show All of Mule Status" . mule-diag)
  t)
(define-key-after mule-menu-keymap [view-hello-file]
  '("Show Script Examples" . view-hello-file)
  t)

(define-key-after set-coding-system-map [set-buffer-file-coding-system]
  '("Buffer File" . set-buffer-file-coding-system)
  t)
(define-key-after set-coding-system-map [universal-coding-system-argument]
  '("Next Command" . universal-coding-system-argument)
  t)
(define-key-after set-coding-system-map [set-terminal-coding-system]
  '("Terminal" . set-terminal-coding-system)
  t)
(define-key-after set-coding-system-map [set-keyboard-coding-system]
  '("Keyboard" . set-keyboard-coding-system)
  t)
(define-key-after set-coding-system-map [set-buffer-process-coding-system]
  '("Buffer Process" . set-buffer-process-coding-system)
  t)
(define-key-after set-coding-system-map [set-selection-coding-system]
  '("X Selection" . set-selection-coding-system)
  t)
(define-key-after set-coding-system-map [set-next-selection-coding-system]
  '("Next X Selection" . set-next-selection-coding-system)
  t)
(define-key setup-language-environment-map
  [Default] '("Default" . setup-specified-language-environment))

;; These are meaningless when running under X and W32.
(put 'set-terminal-coding-system 'menu-enable
     '(or (not window-system) (eq window-system 'pc)))
(put 'set-keyboard-coding-system 'menu-enable
     '(or (not window-system) (eq window-system 'pc)))
;; This is meaningless when the current buffer has no process.
(put 'set-buffer-process-coding-system 'menu-enable
     '(get-buffer-process (current-buffer)))
;; These are meaningless when running under terminal.
(put 'set-selection-coding-system 'menu-enable
     'window-system)
(put 'set-next-selection-coding-system 'menu-enable
     'window-system)

;; This should be a single character key binding because users use it
;; very frequently while editing multilingual text.  Now we can use
;; only two such keys: "\C-\\" and "\C-^", but the latter is not
;; convenient because it requires shifting on most keyboards.  An
;; alternative is "\C-\]" which is now bound to `abort-recursive-edit'
;; but it won't be used that frequently.
(define-key global-map "\C-\\" 'toggle-input-method)

;;; This is no good because people often type Shift-SPC
;;; meaning to type SPC.  -- rms.
;;; ;; Here's an alternative key binding for X users (Shift-SPACE).
;;; (define-key global-map [?\S- ] 'toggle-input-method)

(defun coding-system-change-eol-conversion (coding-system eol-type)
  "Return a coding system which differs from CODING-SYSTEM in eol conversion.
The returned coding system converts end-of-line by EOL-TYPE
but text as the same way as CODING-SYSTEM.
EOL-TYPE should be `unix', `dos', `mac', or nil.
If EOL-TYPE is nil, the returned coding system detects
how end-of-line is formatted automatically while decoding.

EOL-TYPE can be specified by an integer 0, 1, or 2.
They means `unix', `dos', and `mac' respectively."
  (if (symbolp eol-type)
      (setq eol-type (cond ((eq eol-type 'unix) 0)
			   ((eq eol-type 'dos) 1)
			   ((eq eol-type 'mac) 2)
			   (t eol-type))))
  (let ((orig-eol-type (coding-system-eol-type coding-system)))
    (if (vectorp orig-eol-type)
	(if (not eol-type)
	    coding-system
	  (aref orig-eol-type eol-type))
      (let ((base (coding-system-base coding-system)))
	(if (not eol-type)
	    base
	  (if (= eol-type orig-eol-type)
	      coding-system
	    (setq orig-eol-type (coding-system-eol-type base))
	    (if (vectorp orig-eol-type)
		(aref orig-eol-type eol-type))))))))

(defun coding-system-change-text-conversion (coding-system coding)
  "Return a coding system which differs from CODING-SYSTEM in text conversion.
The returned coding system converts text by CODING
but end-of-line as the same way as CODING-SYSTEM.
If CODING is nil, the returned coding system detects
how text is formatted automatically while decoding."
  (if (not coding)
      (coding-system-base coding-system)
    (let ((eol-type (coding-system-eol-type coding-system)))
      (coding-system-change-eol-conversion
       coding
       (if (numberp eol-type) (aref [unix dos mac] eol-type))))))

(defun toggle-enable-multibyte-characters (&optional arg)
  "Change whether this buffer uses multibyte characters.
With arg, use multibyte characters if the arg is positive.

Note that this command does not convert the byte contents of
the buffer; it only changes the way those bytes are interpreted.
In general, therefore, this command *changes* the sequence of
characters that the current buffer contains.

We suggest you avoid using use this command unless you know what you
are doing.  If you use it by mistake, and the buffer is now displayed
wrong, use this command again to toggle back to the right mode."
  (interactive "P")
  (let ((new-flag
	 (if (null arg) (null enable-multibyte-characters)
	   (> (prefix-numeric-value arg) 0))))
    (set-buffer-multibyte new-flag))
  (force-mode-line-update))

(defun view-hello-file ()
  "Display the HELLO file which list up many languages and characters."
  (interactive)
  ;; We have to decode the file in any environment.
  (let ((default-enable-multibyte-characters t)
	(coding-system-for-read 'iso-2022-7bit))
    (find-file-read-only (expand-file-name "HELLO" data-directory))))

(defun universal-coding-system-argument ()
  "Execute an I/O command using the specified coding system."
  (interactive)
  (let* ((default (and buffer-file-coding-system
		       (not (eq (coding-system-type buffer-file-coding-system)
				t))
		       buffer-file-coding-system))
	 (coding-system (read-coding-system
			 (if default
			     (format "Coding system for following command (default, %s): " default)
			   "Coding system for following command: ")
			 default))
	 (keyseq (read-key-sequence
		  (format "Command to execute with %s:" coding-system)))
	 (cmd (key-binding keyseq)))
    (let ((coding-system-for-read coding-system)
	  (coding-system-for-write coding-system))
      (message "")
      (call-interactively cmd))))

(defun set-default-coding-systems (coding-system)
  "Set default value of various coding systems to CODING-SYSTEM.
This sets the following coding systems:
  o coding system of a newly created buffer
  o default coding system for subprocess I/O
This also sets the following values:
  o default value used as file-name-coding-system for converting file names.
  o default value for the command `set-terminal-coding-system' (not on MSDOS)
  o default value for the command `set-keyboard-coding-system'."
  (check-coding-system coding-system)
  (setq-default buffer-file-coding-system coding-system)
  (if default-enable-multibyte-characters
      (setq default-file-name-coding-system coding-system))
  ;; If coding-system is nil, honor that on MS-DOS as well, so
  ;; that they could reset the terminal coding system.
  (unless (and (eq window-system 'pc) coding-system)
    (setq default-terminal-coding-system coding-system))
  (setq default-keyboard-coding-system coding-system)
  (setq default-process-coding-system (cons coding-system coding-system)))

(defalias 'update-iso-coding-systems 'update-coding-systems-internal)
(make-obsolete 'update-iso-coding-systems 'update-coding-systems-internal)

(defun prefer-coding-system (coding-system)
  "Add CODING-SYSTEM at the front of the priority list for automatic detection.
This also sets the following coding systems:
  o coding system of a newly created buffer
  o default coding system for subprocess I/O
This also sets the following values:
  o default value used as file-name-coding-system for converting file names.
  o default value for the command `set-terminal-coding-system' (not on MSDOS)
  o default value for the command `set-keyboard-coding-system'

If CODING-SYSTEM specifies a certain type of EOL conversion, the coding
systems set by this function will use that type of EOL conversion.

This command does not change the default value of terminal coding system
for MS-DOS terminal, because DOS terminals only support a single coding
system, and Emacs automatically sets the default to that coding system at
startup."
  (interactive "zPrefer coding system: ")
  (if (not (and coding-system (coding-system-p coding-system)))
      (error "Invalid coding system `%s'" coding-system))
  (let ((coding-category (coding-system-category coding-system))
	(base (coding-system-base coding-system))
	(eol-type (coding-system-eol-type coding-system)))
    (if (not coding-category)
	;; CODING-SYSTEM is no-conversion or undecided.
	(error "Can't prefer the coding system `%s'" coding-system))
    (set coding-category (or base coding-system))
    (update-coding-systems-internal)
    (or (eq coding-category (car coding-category-list))
	;; We must change the order.
	(set-coding-priority (list coding-category)))
    (if (and base (interactive-p))
	(message "Highest priority is set to %s (base of %s)"
		 base coding-system))
    ;; If they asked for specific EOL conversion, honor that.
    (if (memq eol-type '(0 1 2))
	(setq coding-system
	      (coding-system-change-eol-conversion base eol-type))
      (setq coding-system base))
    (set-default-coding-systems coding-system)))

(defun find-coding-systems-region-subset-p (list1 list2)
  "Return non-nil if all elements in LIST1 are included in LIST2.
Comparison done with EQ."
  (catch 'tag
    (while list1
      (or (memq (car list1) list2)
	  (throw 'tag nil))
      (setq list1 (cdr list1)))
    t))

(defun find-coding-systems-region (from to)
  "Return a list of proper coding systems to encode a text between FROM and TO.
All coding systems in the list can safely encode any multibyte characters
in the text.

If the text contains no multibyte characters, return a list of a single
element `undecided'."
  (find-coding-systems-for-charsets (find-charset-region from to)))

(defun find-coding-systems-string (string)
  "Return a list of proper coding systems to encode STRING.
All coding systems in the list can safely encode any multibyte characters
in STRING.

If STRING contains no multibyte characters, return a list of a single
element `undecided'."
  (find-coding-systems-for-charsets (find-charset-string string)))

(defun find-coding-systems-for-charsets (charsets)
  "Return a list of proper coding systems to encode characters of CHARSETS.
CHARSETS is a list of character sets."
  (if (or (null charsets)
	  (and (= (length charsets) 1)
	       (eq 'ascii (car charsets))))
      '(undecided)
    (setq charsets (delq 'composition charsets))
    (let ((l (coding-system-list 'base-only))
	  (charset-preferred-codings
	   (mapcar (function
		    (lambda (x)
		      (if (eq x 'unknown)
			  'raw-text
			(get-charset-property x 'preferred-coding-system))))
		   charsets))
	  (priorities (mapcar (function (lambda (x) (symbol-value x)))
			      coding-category-list))
	  codings coding safe)
      (if (memq 'unknown charsets)
	  ;; The region contains invalid multibyte characters.
	  (setq l '(raw-text)))
      (while l
	(setq coding (car l) l (cdr l))
	(if (and (setq safe (coding-system-get coding 'safe-charsets))
		 (or (eq safe t)
		     (find-coding-systems-region-subset-p charsets safe)))
	    ;; We put the higher priority to coding systems included
	    ;; in CHARSET-PREFERRED-CODINGS, and within them, put the
	    ;; higher priority to coding systems which support smaller
	    ;; number of charsets.
	    (let ((priority
		   (+ (if (coding-system-get coding 'mime-charset) 4096 0)
		      (lsh (length (memq coding priorities)) 7)
		      (if (memq coding charset-preferred-codings) 64 0)
		      (if (> (coding-system-type coding) 0) 32 0)
		      (if (consp safe) (- 32 (length safe)) 0))))
	      (setq codings (cons (cons priority coding) codings)))))
      (mapcar 'cdr
	      (sort codings (function (lambda (x y) (> (car x) (car y))))))
      )))

(defun find-multibyte-characters (from to &optional maxcount excludes)
  "Find multibyte characters in the region specified by FROM and TO.
If FROM is a string, find multibyte characters in the string.
The return value is an alist of the following format:
  ((CHARSET COUNT CHAR ...) ...)
where
  CHARSET is a character set,
  COUNT is a number of characters,
  CHARs are found characters of the character set.
Optional 3rd arg MAXCOUNT limits how many CHARs are put in the above list.
Optional 4th arg EXCLUDE is a list of character sets to be ignored.

For invalid characters, CHARs are actually strings."
  (let ((chars nil)
	charset char)
    (if (stringp from)
	(let ((idx 0))
	  (while (setq idx (string-match "[^\000-\177]" from idx))
	    (setq char (aref from idx)
		  charset (char-charset char))
	    (if (eq charset 'unknown)
		(setq char (match-string 0)))
	    (if (or (eq charset 'unknown)
		    (not (or (eq excludes t) (memq charset excludes))))
		(let ((slot (assq charset chars)))
		  (if slot
		      (if (not (memq char (nthcdr 2 slot)))
			  (let ((count (nth 1 slot)))
			    (setcar (cdr slot) (1+ count))
			    (if (or (not maxcount) (< count maxcount))
				(nconc slot (list char)))))
		    (setq chars (cons (list charset 1 char) chars)))))
	    (setq idx (1+ idx))))
      (save-excursion
	(goto-char from)
	(while (re-search-forward "[^\000-\177]" to t)
	  (setq char (preceding-char)
		charset (char-charset char))
	  (if (eq charset 'unknown)
	      (setq char (match-string 0)))
	  (if (or (eq charset 'unknown)
		  (not (or (eq excludes t) (memq charset excludes))))
	      (let ((slot (assq charset chars)))
		(if slot
		    (if (not (member char (nthcdr 2 slot)))
			(let ((count (nth 1 slot)))
			  (setcar (cdr slot) (1+ count))
			  (if (or (not maxcount) (< count maxcount))
			      (nconc slot (list char)))))
		  (setq chars (cons (list charset 1 char) chars))))))))
    (nreverse chars)))

(defvar last-coding-system-specified nil
  "Most recent coding system explicitly specified by the user when asked.
This variable is set whenever Emacs asks the user which coding system
to use in order to write a file.  If you set it to nil explicitly,
then call `write-region', then afterward this variable will be non-nil
only if the user was explicitly asked and specified a coding system.")

(defun select-safe-coding-system (from to &optional default-coding-system)
  "Ask a user to select a safe coding system from candidates.
The candidates of coding systems which can safely encode a text
between FROM and TO are shown in a popup window.

Optional arg DEFAULT-CODING-SYSTEM specifies a coding system to be
checked at first.  If omitted, buffer-file-coding-system of the
current buffer is used.

If the text can be encoded safely by DEFAULT-CODING-SYSTEM, it is
returned without any user interaction.

Kludgy feature: if FROM is a string, the string is the target text,
and TO is ignored."
  (or default-coding-system
      (setq default-coding-system buffer-file-coding-system))
  (let* ((charsets (if (stringp from) (find-charset-string from)
		     (find-charset-region from to)))
	 (safe-coding-systems (find-coding-systems-for-charsets charsets)))
    (if (or (not enable-multibyte-characters)
	    (eq (car safe-coding-systems) 'undecided)
	    (eq default-coding-system 'no-conversion)
	    (and default-coding-system
		 (memq (coding-system-base default-coding-system)
		       safe-coding-systems)))
	default-coding-system

      ;; At first, change each coding system to the corresponding
      ;; mime-charset name if it is also a coding system.
      (let ((l safe-coding-systems)
	    mime-charset)
	(while l
	  (setq mime-charset (coding-system-get (car l) 'mime-charset))
	  (if (and mime-charset (coding-system-p mime-charset))
	      (setcar l mime-charset))
	  (setq l (cdr l))))

      (let ((non-safe-chars (find-multibyte-characters
			     from to 3
			     (and default-coding-system
				  (coding-system-get default-coding-system
						     'safe-charsets))))
	    show-position overlays)
	(save-excursion
	  ;; Highlight characters that default-coding-system can't encode.
	  (when (integerp from)
	    (goto-char from)
	    (let ((found nil))
	      (while (and (not found)
			  (re-search-forward "[^\000-\177]" to t))
		(setq found (assq (char-charset (preceding-char))
				  non-safe-chars))))
	    (forward-line -1)
	    (setq show-position (point))
	    (save-excursion
	      (while (and (< (length overlays) 256)
			  (re-search-forward "[^\000-\177]" to t))
		(let* ((char (preceding-char))
		       (charset (char-charset char)))
		  (when (assq charset non-safe-chars)
		    (setq overlays (cons (make-overlay (1- (point)) (point))
					 overlays))
		    (overlay-put (car overlays) 'face 'highlight))))))

	  ;; At last, ask a user to select a proper coding system.  
	  (unwind-protect
	      (save-window-excursion
		(when show-position
		  ;; At first, be sure to show the current buffer.
		  (let ((win (or (get-buffer-window (current-buffer))
				 (display-buffer (current-buffer)))))
		    (set-window-start win show-position)))
		;; Then, show a helpful message.
		(with-output-to-temp-buffer "*Warning*"
		  (save-excursion
		    (set-buffer standard-output)
		    (insert "The target text contains the following non ASCII character(s):\n")
		    (let ((len (length non-safe-chars))
			  (shown 0))
		      (while (and non-safe-chars (< shown 3))
			(when (> (length (car non-safe-chars)) 2)
			  (setq shown (1+ shown))
			  (insert (format "%25s: " (car (car non-safe-chars))))
			  (let ((l (nthcdr 2 (car non-safe-chars))))
			    (while l
			      (if (or (stringp (car l)) (char-valid-p (car l)))
				  (insert (car l)))
			      (setq l (cdr l))))
			  (if (> (nth 1 (car non-safe-chars)) 3)
			      (insert "..."))
			  (insert "\n"))
			(setq non-safe-chars (cdr non-safe-chars)))
		      (if (< shown len)
			  (insert (format "%27s\n" "..."))))
		    (insert (format "\
These can't be encoded safely by the coding system %s.

Please select one from the following safe coding systems:\n"
				    default-coding-system))
		    (let ((pos (point))
			  (fill-prefix "  "))
		      (mapcar (function (lambda (x) (princ "  ") (princ x)))
			      safe-coding-systems)
		      (fill-region-as-paragraph pos (point)))))

		;; Read a coding system.
		(let* ((safe-names (mapcar (lambda (x) (list (symbol-name x)))
					   safe-coding-systems))
		       (name (completing-read
			      (format "Select coding system (default %s): "
				      (car safe-coding-systems))
			      safe-names nil t nil nil
			      (car (car safe-names)))))
		  (setq last-coding-system-specified (intern name))
		  (if (integerp (coding-system-eol-type default-coding-system))
		      (setq last-coding-system-specified
			    (coding-system-change-eol-conversion
			     last-coding-system-specified
			     (coding-system-eol-type default-coding-system))))
		  last-coding-system-specified))
	    (if (get-buffer "*Warning*")
		(kill-buffer "*Warning*"))
	    (while overlays
	      (delete-overlay (car overlays))
	      (setq overlays (cdr overlays)))))))))

(setq select-safe-coding-system-function 'select-safe-coding-system)

(defun select-message-coding-system ()
  "Return a coding system to encode the outgoing message of the current buffer.
It at first tries the first coding system found in these variables
in this order:
  (1) local value of `buffer-file-coding-system'
  (2) value of `sendmail-coding-system'
  (3) value of `default-buffer-file-coding-system'
  (4) value of `default-sendmail-coding-system'
If the found coding system can't encode the current buffer,
or none of them are bound to a coding system,
it asks the user to select a proper coding system."
  (let ((coding (or (and (local-variable-p 'buffer-file-coding-system)
			 buffer-file-coding-system)
		    sendmail-coding-system
		    default-buffer-file-coding-system
		    default-sendmail-coding-system)))
    (if (eq coding 'no-conversion)
	;; We should never use no-conversion for outgoing mails.
	(setq coding nil))
    (if (fboundp select-safe-coding-system-function)
	(funcall select-safe-coding-system-function
		 (point-min) (point-max) coding)
      coding)))

;;; Language support stuff.

(defvar language-info-alist nil
  "Alist of language environment definitions.
Each element looks like:
	(LANGUAGE-NAME . ((KEY . INFO) ...))
where LANGUAGE-NAME is a string, the name of the language environment,
KEY is a symbol denoting the kind of information, and
INFO is the data associated with KEY.
Meaningful values for KEY include

  documentation      value is documentation of what this language environment
			is meant for, and how to use it.
  charset	     value is a list of the character sets used by this
			language environment.
  sample-text	     value is one line of text,
			written using those character sets,
			appropriate for this language environment.
  setup-function     value is a function to call to switch to this
			language environment.
  exit-function      value is a function to call to leave this
		        language environment.
  coding-system      value is a list of coding systems that are good
			for saving text written in this language environment.
			This list serves as suggestions to the user;
			in effect, as a kind of documentation.
  coding-priority    value is a list of coding systems for this language
			environment, in order of decreasing priority.
			This is used to set up the coding system priority
			list when you switch to this language environment.
  nonascii-translation
		     value is a translation table to be set in the
			variable `nonascii-translation-table' in this
			language environment, or a character set from
			which `nonascii-insert-offset' is calculated.
  input-method       value is a default input method for this language
			environment.
  features           value is a list of features requested in this
			language environment.

The following keys take effect only when multibyte characters are
globally disabled, i.e. the value of `default-enable-multibyte-characters'
is nil.

  unibyte-syntax     value is a library name to load to set
			unibyte 8-bit character syntaxes for this
			language environment.

  unibyte-display    value is a coding system to encode characters
			for the terminal.  Characters in the range
			of 160 to 255 display not as octal escapes,
			but as non-ASCII characters in this language
			environment.")

(defun get-language-info (lang-env key)
  "Return information listed under KEY for language environment LANG-ENV.
KEY is a symbol denoting the kind of information.
For a list of useful values for KEY and their meanings,
see `language-info-alist'."
  (if (symbolp lang-env)
      (setq lang-env (symbol-name lang-env)))
  (let ((lang-slot (assoc-ignore-case lang-env language-info-alist)))
    (if lang-slot
	(cdr (assq key (cdr lang-slot))))))

(defun set-language-info (lang-env key info)
  "Modify part of the definition of language environment LANG-ENV.
Specifically, this stores the information INFO under KEY
in the definition of this language environment.
KEY is a symbol denoting the kind of information.
INFO is the value for that information.

For a list of useful values for KEY and their meanings,
see `language-info-alist'."
  (if (symbolp lang-env)
      (setq lang-env (symbol-name lang-env)))
  (let (lang-slot key-slot)
    (setq lang-slot (assoc lang-env language-info-alist))
    (if (null lang-slot)		; If no slot for the language, add it.
	(setq lang-slot (list lang-env)
	      language-info-alist (cons lang-slot language-info-alist)))
    (setq key-slot (assq key lang-slot))
    (if (null key-slot)			; If no slot for the key, add it.
	(progn
	  (setq key-slot (list key))
	  (setcdr lang-slot (cons key-slot (cdr lang-slot)))))
    (setcdr key-slot info)))

(defun set-language-info-alist (lang-env alist &optional parents)
  "Store ALIST as the definition of language environment LANG-ENV.
ALIST is an alist of KEY and INFO values.  See the documentation of
`set-language-info' for the meanings of KEY and INFO.

Optional arg PARENTS is a list of parent menu names; it specifies
where to put this language environment in the 
Describe Language Environment and Set Language Environment menus.
For example, (\"European\") means to put this language environment
in the European submenu in each of those two menus."
  (if (symbolp lang-env)
      (setq lang-env (symbol-name lang-env)))
  (let ((describe-map describe-language-environment-map)
	(setup-map setup-language-environment-map))
    (if parents
	(let ((l parents)
	      map parent-symbol parent)
	  (while l
	    (if (symbolp (setq parent-symbol (car l)))
		(setq parent (symbol-name parent))
	      (setq parent parent-symbol parent-symbol (intern parent)))
	    (setq map (lookup-key describe-map (vector parent-symbol)))
	    (if (not map)
		(progn
		  (setq map (intern (format "describe-%s-environment-map"
					    (downcase parent))))
		  (define-prefix-command map)
		  (define-key-after describe-map (vector parent-symbol)
		    (cons parent map) t)))
	    (setq describe-map (symbol-value map))
	    (setq map (lookup-key setup-map (vector parent-symbol)))
	    (if (not map)
		(progn
		  (setq map (intern (format "setup-%s-environment-map"
					    (downcase parent))))
		  (define-prefix-command map)
		  (define-key-after setup-map (vector parent-symbol)
		    (cons parent map) t)))
	    (setq setup-map (symbol-value map))
	    (setq l (cdr l)))))

    ;; Set up menu items for this language env.
    (let ((doc (assq 'documentation alist)))
      (when doc
	(define-key-after describe-map (vector (intern lang-env))
	  (cons lang-env 'describe-specified-language-support) t)))
    (define-key-after setup-map (vector (intern lang-env))
      (cons lang-env 'setup-specified-language-environment) t)

    (while alist
      (set-language-info lang-env (car (car alist)) (cdr (car alist)))
      (setq alist (cdr alist)))))

(defun read-language-name (key prompt &optional default)
  "Read a language environment name which has information for KEY.
If KEY is nil, read any language environment.
Prompt with PROMPT.  DEFAULT is the default choice of language environment.
This returns a language environment name as a string."
  (let* ((completion-ignore-case t)
	 (name (completing-read prompt
				language-info-alist
				(and key
				     (function (lambda (elm) (assq key elm))))
				t nil nil default)))
    (if (and (> (length name) 0)
	     (or (not key)
		 (get-language-info name key)))
	name)))

;;; Multilingual input methods.

(defconst leim-list-file-name "leim-list.el"
  "Name of LEIM list file.
This file contains a list of libraries of Emacs input methods (LEIM)
in the format of Lisp expression for registering each input method.
Emacs loads this file at startup time.")

(defvar leim-list-header (format "\
;;; %s -- list of LEIM (Library of Emacs Input Method)
;;
;; This file contains a list of LEIM (Library of Emacs Input Method)
;; in the same directory as this file.  Loading this file registers
;; the whole input methods in Emacs.
;;
;; Each entry has the form:
;;   (register-input-method
;;    INPUT-METHOD LANGUAGE-NAME ACTIVATE-FUNC
;;    TITLE DESCRIPTION
;;    ARG ...)
;; See the function `register-input-method' for the meanings of arguments.
;;
;; If this directory is included in load-path, Emacs automatically
;; loads this file at startup time.

"
				 leim-list-file-name)
  "Header to be inserted in LEIM list file.")

(defvar leim-list-entry-regexp "^(register-input-method"
  "Regexp matching head of each entry in LEIM list file.
See also the variable `leim-list-header'")

(defvar update-leim-list-functions
  '(quail-update-leim-list-file)
  "List of functions to call to update LEIM list file.
Each function is called with one arg, LEIM directory name.")

(defun update-leim-list-file (&rest dirs)
  "Update LEIM list file in directories DIRS."
  (let ((functions update-leim-list-functions))
    (while functions
      (apply (car functions) dirs)
      (setq functions (cdr functions)))))

(defvar current-input-method nil
  "The current input method for multilingual text.
If nil, that means no input method is activated now.")
(make-variable-buffer-local 'current-input-method)
(put 'current-input-method 'permanent-local t)

(defvar current-input-method-title nil
  "Title string of the current input method shown in mode line.")
(make-variable-buffer-local 'current-input-method-title)
(put 'current-input-method-title 'permanent-local t)

(defcustom default-input-method nil
  "*Default input method for multilingual text (a string).
This is the input method activated automatically by the command
`toggle-input-method' (\\[toggle-input-method])."
  :group 'mule
  :type '(choice (const nil) string))

(put 'input-method-function 'permanent-local t)

(defvar input-method-history nil
  "History list for some commands that read input methods.")
(make-variable-buffer-local 'input-method-history)
(put 'input-method-history 'permanent-local t)

(defvar inactivate-current-input-method-function nil
  "Function to call for inactivating the current input method.
Every input method should set this to an appropriate value when activated.
This function is called with no argument.

This function should never change the value of `current-input-method'.
It is set to nil by the function `inactivate-input-method'.")
(make-variable-buffer-local 'inactivate-current-input-method-function)
(put 'inactivate-current-input-method-function 'permanent-local t)

(defvar describe-current-input-method-function nil
  "Function to call for describing the current input method.
This function is called with no argument.")
(make-variable-buffer-local 'describe-current-input-method-function)
(put 'describe-current-input-method-function 'permanent-local t)

(defvar input-method-alist nil
  "Alist of input method names vs how to use them.
Each element has the form:
   (INPUT-METHOD LANGUAGE-ENV ACTIVATE-FUNC TITLE DESCRIPTION ARGS...)
See the function `register-input-method' for the meanings of the elements.")

(defun register-input-method (input-method lang-env &rest args)
  "Register INPUT-METHOD as an input method for language environment ENV.
INPUT-METHOD and LANG-ENV are symbols or strings.

The remaining arguments are:
	ACTIVATE-FUNC, TITLE, DESCRIPTION, and ARGS...
ACTIVATE-FUNC is a function to call to activate this method.
TITLE is a string to show in the mode line when this method is active.
DESCRIPTION is a string describing this method and what it is good for.
The ARGS, if any, are passed as arguments to ACTIVATE-FUNC.
All told, the arguments to ACTIVATE-FUNC are INPUT-METHOD and the ARGS.

This function is mainly used in the file \"leim-list.el\" which is
created at building time of emacs, registering all quail input methods
contained in the emacs distribution.

In case you want to register a new quail input method by yourself, be
careful to use the same input method title as given in the third
parameter of `quail-define-package' (if the values are different, the
string specified in this function takes precedence).

The commands `describe-input-method' and `list-input-methods' need
this duplicated values to show some information about input methods
without loading the affected quail packages."
  (if (symbolp lang-env)
      (setq lang-env (symbol-name lang-env)))
  (if (symbolp input-method)
      (setq input-method (symbol-name input-method)))
  (let ((info (cons lang-env args))
	(slot (assoc input-method input-method-alist)))
    (if slot
	(setcdr slot info)
      (setq slot (cons input-method info))
      (setq input-method-alist (cons slot input-method-alist)))))

(defun read-input-method-name (prompt &optional default inhibit-null)
  "Read a name of input method from a minibuffer prompting with PROMPT.
If DEFAULT is non-nil, use that as the default,
  and substitute it into PROMPT at the first `%s'.
If INHIBIT-NULL is non-nil, null input signals an error.

The return value is a string."
  (if default
      (setq prompt (format prompt default)))
  (let* ((completion-ignore-case t)
	 ;; This binding is necessary because input-method-history is
	 ;; buffer local.
	 (input-method (completing-read prompt input-method-alist
					nil t nil 'input-method-history
					default)))
    (if (and input-method (symbolp input-method))
 	(setq input-method (symbol-name input-method)))
    (if (> (length input-method) 0)
	input-method
      (if inhibit-null
	  (error "No valid input method is specified")))))

(defun activate-input-method (input-method)
  "Switch to input method INPUT-METHOD for the current buffer.
If some other input method is already active, turn it off first.
If INPUT-METHOD is nil, deactivate any current input method."
  (if (and input-method (symbolp input-method))
      (setq input-method (symbol-name input-method)))
  (if (and current-input-method
	   (not (string= current-input-method input-method)))
      (inactivate-input-method))
  (unless (or current-input-method (null input-method))
    (let ((slot (assoc input-method input-method-alist)))
      (if (null slot)
	  (error "Can't activate input method `%s'" input-method))
      (let ((func (nth 2 slot)))
	(if (functionp func)
	    (apply (nth 2 slot) input-method (nthcdr 5 slot))
	  (if (and (consp func) (symbolp (car func)) (symbolp (cdr func)))
	      (progn
		(require (cdr func))
		(apply (car func) input-method (nthcdr 5 slot)))
	    (error "Can't activate input method `%s'" input-method))))
      (setq current-input-method input-method)
      (setq current-input-method-title (nth 3 slot))
      (unwind-protect
	  (run-hooks 'input-method-activate-hook)
	(force-mode-line-update)))))

(defun inactivate-input-method ()
  "Turn off the current input method."
  (when current-input-method
    (if input-method-history
	(unless (string= current-input-method (car input-method-history))
	  (setq input-method-history
		(cons current-input-method
		      (delete current-input-method input-method-history))))
      (setq input-method-history (list current-input-method)))
    (unwind-protect
	(funcall inactivate-current-input-method-function)
      (unwind-protect
	  (run-hooks 'input-method-inactivate-hook)
	(setq current-input-method nil
	      current-input-method-title nil)
	(force-mode-line-update)))))

(defun set-input-method (input-method)
  "Select and activate input method INPUT-METHOD for the current buffer.
This also sets the default input method to the one you specify."
  (interactive
   (let* ((default (or (car input-method-history) default-input-method)))
     (list (read-input-method-name
	    (if default "Select input method (default %s): " "Select input method: ")
	    default t))))
  (activate-input-method input-method)
  (setq default-input-method input-method))

(defun toggle-input-method (&optional arg)
  "Turn on or off a multilingual text input method for the current buffer.

With no prefix argument, if an input method is currently activated,
turn it off.  Otherwise, activate an input method -- the one most
recently used, or the one specified in `default-input-method', or
the one read from the minibuffer.

With a prefix argument, read an input method from the minibuffer and
turn it on.

The default is to use the most recent input method specified
\(not including the currently active input method, if any)."
  (interactive "P")
  (if (and current-input-method (not arg))
      (inactivate-input-method)
    (let ((default (or (car input-method-history) default-input-method)))
      (if (and arg default (equal current-input-method default)
	       (> (length input-method-history) 1))
	  (setq default (nth 1 input-method-history)))
      (activate-input-method
       (if (or arg (not default))
	   (progn
	     (read-input-method-name
	      (if default "Input method (default %s): " "Input method: " )
	      default t))
	 default))
      (or default-input-method
	  (setq default-input-method current-input-method)))))

(defun describe-input-method (input-method)
  "Describe input method INPUT-METHOD."
  (interactive
   (list (read-input-method-name
	  "Describe input method (default, current choice): ")))
  (if (and input-method (symbolp input-method))
      (setq input-method (symbol-name input-method)))
  (if (null input-method)
      (describe-current-input-method)
    (with-output-to-temp-buffer "*Help*"
      (let ((elt (assoc input-method input-method-alist)))
	(princ (format "Input method: %s (`%s' in mode line) for %s\n  %s\n"
		       input-method (nth 3 elt) (nth 1 elt) (nth 4 elt)))))))

(defun describe-current-input-method ()
  "Describe the input method currently in use."
  (if current-input-method
      (if (and (symbolp describe-current-input-method-function)
	       (fboundp describe-current-input-method-function))
	  (funcall describe-current-input-method-function)
	(message "No way to describe the current input method `%s'"
		 current-input-method)
	(ding))
    (error "No input method is activated now")))

(defun read-multilingual-string (prompt &optional initial-input input-method)
  "Read a multilingual string from minibuffer, prompting with string PROMPT.
The input method selected last time is activated in minibuffer.
If optional second arg INITIAL-INPUT is non-nil, insert it in the minibuffer
initially.
Optional 3rd argument INPUT-METHOD specifies the input method
to be activated instead of the one selected last time.  It is a symbol
or a string."
  (setq input-method
	(or input-method
	    current-input-method
	    default-input-method
	    (read-input-method-name "Input method: " nil t)))
  (if (and input-method (symbolp input-method))
      (setq input-method (symbol-name input-method)))
  (let ((prev-input-method current-input-method))
    (unwind-protect
	(progn
	  (activate-input-method input-method)
	  (read-string prompt initial-input nil nil t))
      (activate-input-method prev-input-method))))

;; Variables to control behavior of input methods.  All input methods
;; should react to these variables.

(defcustom input-method-verbose-flag 'default
  "*A flag to control extra guidance given by input methods.
The value should be nil, t, `complex-only', or `default'.

The extra guidance is done by showing list of available keys in echo
area.  When you use the input method in the minibuffer, the guidance
is shown at the bottom short window (split from the existing window).

If the value is t, extra guidance is always given, if the value is
nil, extra guidance is always suppressed.

If the value is `complex-only', only complex input methods such as
`chinese-py' and `japanese' give extra guidance.

If the value is `default', complex input methods always give extra
guidance, but simple input methods give it only when you are not in
the minibuffer.

See also the variable `input-method-highlight-flag'."
  :type '(choice (const t) (const nil) (const complex-only) (const default))
  :group 'mule)

(defcustom input-method-highlight-flag t
  "*If this flag is non-nil, input methods highlight partially-entered text.
For instance, while you are in the middle of a Quail input method sequence,
the text inserted so far is temporarily underlined.
The underlining goes away when you finish or abort the input method sequence.
See also the variable `input-method-verbose-flag'."
  :type 'boolean
  :group 'mule)

(defvar input-method-activate-hook nil
  "Normal hook run just after an input method is activated.

The variable `current-input-method' keeps the input method name
just activated.")

(defvar input-method-inactivate-hook nil
  "Normal hook run just after an input method is inactivated.

The variable `current-input-method' still keeps the input method name
just inactivated.")

(defvar input-method-after-insert-chunk-hook nil
  "Normal hook run just after an input method insert some chunk of text.")

(defvar input-method-exit-on-first-char nil
  "This flag controls a timing when an input method returns.
Usually, the input method does not return while there's a possibility
that it may find a different translation if a user types another key.
But, it this flag is non-nil, the input method returns as soon as
the current key sequence gets long enough to have some valid translation.")

(defvar input-method-use-echo-area nil
  "This flag controls how an input method shows an intermediate key sequence.
Usually, the input method inserts the intermediate key sequence,
or candidate translations corresponding to the sequence,
at point in the current buffer.
But, if this flag is non-nil, it displays them in echo area instead.")

(defvar input-method-exit-on-invalid-key nil
  "This flag controls the behaviour of an input method on invalid key input.
Usually, when a user types a key which doesn't start any character
handled by the input method, the key is handled by turning off the
input method temporarily.  After that key, the input method is re-enabled.
But, if this flag is non-nil, the input method is never back on.")


(defvar set-language-environment-hook nil
  "Normal hook run after some language environment is set.

When you set some hook function here, that effect usually should not
be inherited to another language environment.  So, you had better set
another function in `exit-language-environment-hook' (which see) to
cancel the effect.")

(defvar exit-language-environment-hook nil
  "Normal hook run after exiting from some language environment.
When this hook is run, the variable `current-language-environment'
is still bound to the language environment being exited.

This hook is mainly used for canceling the effect of
`set-language-environment-hook' (which-see).")

(put 'setup-specified-language-environment 'apropos-inhibit t)

(defun setup-specified-language-environment ()
  "Switch to a specified language environment."
  (interactive)
  (let (language-name)
    (if (and (symbolp last-command-event)
	     (or (not (eq last-command-event 'Default))
		 (setq last-command-event 'English))
	     (setq language-name (symbol-name last-command-event)))
	(set-language-environment language-name)
      (error "Bogus calling sequence"))))

(defcustom current-language-environment "English"
  "The last language environment specified with `set-language-environment'.
This variable should be set only with \\[customize], which is equivalent
to using the function `set-language-environment'."
  :link '(custom-manual "(emacs)Language Environments")
  :set (lambda (symbol value) (set-language-environment value))
  :get (lambda (x)
	 (or (car-safe (assoc-ignore-case
			(if (symbolp current-language-environment)
			    (symbol-name current-language-environment)
			  current-language-environment)
			language-info-alist))
	     "English"))
  :type (cons 'choice (mapcar (lambda (lang)
				(list 'const (car lang)))
			      language-info-alist))
  :initialize 'custom-initialize-default
  :group 'mule
  :type 'string)

(defun reset-language-environment ()
  "Reset multilingual environment of Emacs to the default status.

The default status is as follows:

  The default value of buffer-file-coding-system is nil.
  The default coding system for process I/O is nil.
  The default value for the command `set-terminal-coding-system' is nil.
  The default value for the command `set-keyboard-coding-system' is nil.

  The order of priorities of coding categories and the coding system
  bound to each category are as follows
	coding category			coding system
	--------------------------------------------------
	coding-category-iso-8-2		iso-latin-1
	coding-category-iso-8-1		iso-latin-1
	coding-category-iso-7-tight	iso-2022-jp
	coding-category-iso-7		iso-2022-7bit
	coding-category-iso-7-else	iso-2022-7bit-lock
	coding-category-iso-8-else	iso-2022-8bit-ss2
	coding-category-emacs-mule 	emacs-mule
	coding-category-raw-text	raw-text
	coding-category-sjis		japanese-shift-jis
	coding-category-big5		chinese-big5
	coding-category-ccl		nil
	coding-category-binary		no-conversion
"
  (interactive)
  ;; This function formerly set default-enable-multibyte-characters to t,
  ;; but that is incorrect.  It should not alter the unibyte/multibyte choice.

  (setq coding-category-iso-7-tight	'iso-2022-jp
	coding-category-iso-7		'iso-2022-7bit
	coding-category-iso-8-1		'iso-latin-1
	coding-category-iso-8-2		'iso-latin-1
	coding-category-iso-7-else	'iso-2022-7bit-lock
	coding-category-iso-8-else	'iso-2022-8bit-ss2
	coding-category-emacs-mule	'emacs-mule
	coding-category-raw-text	'raw-text
	coding-category-sjis		'japanese-shift-jis
	coding-category-big5		'chinese-big5
	coding-category-ccl		nil
	coding-category-binary		'no-conversion)

  (set-coding-priority
   '(coding-category-iso-8-1
     coding-category-iso-8-2
     coding-category-iso-7-tight
     coding-category-iso-7
     coding-category-iso-7-else
     coding-category-iso-8-else
     coding-category-emacs-mule 
     coding-category-raw-text
     coding-category-sjis
     coding-category-big5
     coding-category-ccl
     coding-category-binary))

  (update-coding-systems-internal)

  (set-default-coding-systems nil)
  ;; Don't alter the terminal and keyboard coding systems here.
  ;; The terminal still supports the same coding system
  ;; that it supported a minute ago.
;;;  (set-terminal-coding-system-internal nil)
;;;  (set-keyboard-coding-system-internal nil)

  (setq nonascii-translation-table nil
	nonascii-insert-offset 0))

(defun set-language-environment (language-name)
  "Set up multi-lingual environment for using LANGUAGE-NAME.
This sets the coding system priority and the default input method
and sometimes other things.  LANGUAGE-NAME should be a string
which is the name of a language environment.  For example, \"Latin-1\"
specifies the character set for the major languages of Western Europe."
  (interactive (list (read-language-name
		      nil
		      "Set language environment (default, English): ")))
  (if language-name
      (if (symbolp language-name)
	  (setq language-name (symbol-name language-name)))
    (setq language-name "English"))
  (or (assoc-ignore-case language-name language-info-alist)
      (error "Language environment not defined: %S" language-name))
  (if current-language-environment
      (let ((func (get-language-info current-language-environment
				     'exit-function)))
	(run-hooks 'exit-language-environment-hook)
	(if (fboundp func) (funcall func))))
  (let ((default-eol-type (coding-system-eol-type
			   default-buffer-file-coding-system)))
    (reset-language-environment)

    (setq current-language-environment language-name)
    (set-language-environment-coding-systems language-name default-eol-type))
  (let ((input-method (get-language-info language-name 'input-method)))
    (when input-method
      (setq default-input-method input-method)
      (if input-method-history
	  (setq input-method-history
		(cons input-method
		      (delete input-method input-method-history))))))
  (let ((nonascii (get-language-info language-name 'nonascii-translation))
	(dos-table
	 (if (eq window-system 'pc)
	     (intern
	      (concat "cp" dos-codepage "-nonascii-translation-table")))))
    (cond
     ((char-table-p nonascii)
      (setq nonascii-translation-table nonascii))
     ((and (eq window-system 'pc) (boundp dos-table))
      ;; DOS terminals' default is to use a special non-ASCII translation
      ;; table as appropriate for the installed codepage.
      (setq nonascii-translation-table (symbol-value dos-table)))
     ((charsetp nonascii)
      (setq nonascii-insert-offset (- (make-char nonascii) 128)))))

  (setq charset-origin-alist
	(get-language-info language-name 'charset-origin-alist))

  ;; Unibyte setups if necessary.
  (unless default-enable-multibyte-characters
    ;; Syntax and case table.
    (let ((syntax (get-language-info language-name 'unibyte-syntax)))
      (if syntax
	  (let ((set-case-syntax-set-multibyte nil))
	    (load syntax nil t))
	;; No information for syntax and case.  Reset to the defaults.
	(let ((syntax-table (standard-syntax-table))
	      (case-table (standard-case-table))
	      (ch (if (eq window-system 'pc) 128 160)))
	  (while (< ch 256)
	    (modify-syntax-entry ch " " syntax-table)
	    (aset case-table ch ch)
	    (setq ch (1+ ch)))
	  (set-char-table-extra-slot case-table 0 nil)
	  (set-char-table-extra-slot case-table 1 nil)
	  (set-char-table-extra-slot case-table 2 nil))
	(set-standard-case-table (standard-case-table))
	(let ((list (buffer-list)))
	  (while list
	    (with-current-buffer (car list)
	      (set-case-table (standard-case-table)))
	    (setq list (cdr list))))))
    ;; Display table and coding system for terminal.
    (let ((coding (get-language-info language-name 'unibyte-display)))
      (if coding
	  (standard-display-european-internal)
	(standard-display-default (if (eq window-system 'pc) 128 160) 255)
	(aset standard-display-table 146 nil))
      (or (eq window-system 'pc)
	  (set-terminal-coding-system coding))))

  (let ((required-features (get-language-info language-name 'features)))
    (while required-features
      (require (car required-features))
      (setq required-features (cdr required-features))))
  (let ((func (get-language-info language-name 'setup-function)))
    (if (fboundp func)
	(funcall func)))
  (run-hooks 'set-language-environment-hook)
  (force-mode-line-update t))

(defun standard-display-european-internal ()
  ;; Actually set up direct output of non-ASCII characters.
  (standard-display-8bit (if (eq window-system 'pc) 128 160) 255)
  ;; Unibyte Emacs on MS-DOS wants to display all 8-bit characters with
  ;; the native font, and codes 160 and 146 stand for something very
  ;; different there.
  (or (and (eq window-system 'pc) (not default-enable-multibyte-characters))
      (progn
	;; Make non-line-break space display as a plain space.
	;; Most X fonts do the wrong thing for code 160.
	(aset standard-display-table 160 [32])
	;; Most Windows programs send out apostrophe's as \222.  Most X fonts
	;; don't contain a character at that position.  Map it to the ASCII
	;; apostrophe.
	(aset standard-display-table 146 [39]))))

(defun set-language-environment-coding-systems (language-name
						&optional eol-type)
  "Do various coding system setups for language environment LANGUAGE-NAME.

The optional arg EOL-TYPE specifies the eol-type of the default value
of buffer-file-coding-system set by this function."
  (let* ((priority (get-language-info language-name 'coding-priority))
	 (default-coding (car priority)))
    (if priority
	(let ((categories (mapcar 'coding-system-category priority)))
	  (set-default-coding-systems
	   (if (memq eol-type '(0 1 2 unix dos mac))
	       (coding-system-change-eol-conversion default-coding eol-type)
	     default-coding))
	  (setq default-sendmail-coding-system default-coding)
	  (set-coding-priority categories)
	  (while priority
	    (set (car categories) (car priority))
	    (setq priority (cdr priority) categories (cdr categories)))
	  (update-coding-systems-internal)))))

;; Print all arguments with `princ', then print "\n".
(defsubst princ-list (&rest args)
  (while args (princ (car args)) (setq args (cdr args)))
  (princ "\n"))

(put 'describe-specified-language-support 'apropos-inhibit t)

;; Print a language specific information such as input methods,
;; charsets, and coding systems.  This function is intended to be
;; called from the menu:
;;   [menu-bar mule describe-language-environment LANGUAGE]
;; and should not run it by `M-x describe-current-input-method-function'.
(defun describe-specified-language-support ()
  "Describe how Emacs supports the specified language environment."
  (interactive)
  (let (language-name)
    (if (not (and (symbolp last-command-event)
		  (setq language-name (symbol-name last-command-event))))
	(error "Bogus calling sequence"))
    (describe-language-environment language-name)))

(defun describe-language-environment (language-name)
  "Describe how Emacs supports language environment LANGUAGE-NAME."
  (interactive
   (list (read-language-name
	  'documentation
	  "Describe language environment (default, current choice): ")))
  (if (null language-name)
      (setq language-name current-language-environment))
  (if (or (null language-name)
	  (null (get-language-info language-name 'documentation)))
      (error "No documentation for the specified language"))
  (if (symbolp language-name)
      (setq language-name (symbol-name language-name)))
  (let ((doc (get-language-info language-name 'documentation)))
    (with-output-to-temp-buffer "*Help*"
      (princ-list language-name " language environment" "\n")
      (if (stringp doc)
	  (progn
	    (princ-list doc)
	    (terpri)))
      (let ((str (get-language-info language-name 'sample-text)))
	(if (stringp str)
	    (progn
	      (princ "Sample text:\n")
	      (princ-list "  " str)
	      (terpri))))
      (let ((input-method (get-language-info language-name 'input-method))
	    (l (copy-sequence input-method-alist)))
	(princ "Input methods")
	(when input-method
	  (princ (format " (default, %s)" input-method))
	  (setq input-method (assoc input-method input-method-alist))
	  (setq l (cons input-method (delete input-method l))))
	(princ ":\n")
	(while l
	  (if (string= language-name (nth 1 (car l)))
	      (princ-list "  " (car (car l))
			  (format " (`%s' in mode line)" (nth 3 (car l)))))
	  (setq l (cdr l))))
      (terpri)
      (princ "Character sets:\n")
      (let ((l (get-language-info language-name 'charset)))
	(if (null l)
	    (princ-list "  nothing specific to " language-name)
	  (while l
	    (princ-list "  " (car l) ": "
			(charset-description (car l)))
	    (setq l (cdr l)))))
      (terpri)
      (princ "Coding systems:\n")
      (let ((l (get-language-info language-name 'coding-system)))
	(if (null l)
	    (princ-list "  nothing specific to " language-name)
	  (while l
	    (princ (format "  %s (`%c' in mode line):\n\t%s\n"
			   (car l)
			   (coding-system-mnemonic (car l))
			   (coding-system-doc-string (car l))))
	    (let ((aliases (coding-system-get (car l) 'alias-coding-systems)))
	      (when aliases
		(princ "\t")
		(princ (cons 'alias: (cdr aliases)))
		(terpri)))
	    (setq l (cdr l))))))))

;;; Charset property

(defun get-charset-property (charset propname)
  "Return the value of CHARSET's PROPNAME property.
This is the last value stored with
 (put-charset-property CHARSET PROPNAME VALUE)."
  (and (not (eq charset 'composition))
       (plist-get (charset-plist charset) propname)))

(defun put-charset-property (charset propname value)
  "Store CHARSETS's PROPNAME property with value VALUE.
It can be retrieved with `(get-charset-property CHARSET PROPNAME)'."
  (or (eq charset 'composition)
      (set-charset-plist charset
			 (plist-put (charset-plist charset) propname value))))

;;; Character code property
(put 'char-code-property-table 'char-table-extra-slots 0)

(defvar char-code-property-table
  (make-char-table 'char-code-property-table)
  "Char-table containing a property list of each character code.

See also the documentation of `get-char-code-property' and
`put-char-code-property'.")

(defun get-char-code-property (char propname)
  "Return the value of CHAR's PROPNAME property in `char-code-property-table'."
  (let ((plist (aref char-code-property-table char)))
    (if (listp plist)
	(car (cdr (memq propname plist))))))

(defun put-char-code-property (char propname value)
  "Store CHAR's PROPNAME property with VALUE in `char-code-property-table'.
It can be retrieved with `(get-char-code-property CHAR PROPNAME)'."
  (let ((plist (aref char-code-property-table char)))
    (if plist
	(let ((slot (memq propname plist)))
	  (if slot
	      (setcar (cdr slot) value)
	    (nconc plist (list propname value))))
      (aset char-code-property-table char (list propname value)))))


;; Pretty description of encoded string

;; Alist of ISO 2022 control code vs the corresponding mnemonic string.
(defvar iso-2022-control-alist
  '((?\x1b . "ESC")
    (?\x0e . "SO")
    (?\x0f . "SI")
    (?\x8e . "SS2")
    (?\x8f . "SS3")
    (?\x9b . "CSI")))

(defun encoded-string-description (str coding-system)
  "Return a pretty description of STR that is encoded by CODING-SYSTEM."
  (setq str (string-as-unibyte str))
  (let ((char (aref str 0))
	desc)
    (when (< char 128)
      (setq desc (or (cdr (assq char iso-2022-control-alist))
		     (char-to-string char)))
      (let ((i 1)
	    (len (length str))) 
	(while (< i len)
	  (setq char (aref str i))
	  (if (>= char 128)
	      (setq desc nil i len)
	    (setq desc (concat desc " "
			       (or (cdr (assq char iso-2022-control-alist))
				   (char-to-string char)))
		  i (1+ i))))))
    (or desc
	(mapconcat (function (lambda (x) (format "0x%02x" x))) str " "))))

(defun encode-coding-char (char coding-system)
  "Encode CHAR by CODING-SYSTEM and return the resulting string.
If CODING-SYSTEM can't safely encode CHAR, return nil."
  (if (cmpcharp char)
      (setq char (car (decompose-composite-char char 'list))))
  (let ((str1 (char-to-string char))
	(str2 (make-string 2 char))
	(safe-charsets (and coding-system
			    (coding-system-get coding-system 'safe-charsets)))
	enc1 enc2 i1 i2)
    (when (or (eq safe-charsets t)
	      (memq (char-charset char) safe-charsets))
      ;; We must find the encoded string of CHAR.  But, just encoding
      ;; CHAR will put extra control sequences (usually to designate
      ;; ASCII charaset) at the tail if type of CODING is ISO 2022.
      ;; To exclude such tailing bytes, we at first encode one-char
      ;; string and two-char string, then check how many bytes at the
      ;; tail of both encoded strings are the same.

      (setq enc1 (string-as-unibyte (encode-coding-string str1 coding-system))
	    i1 (length enc1)
	    enc2 (string-as-unibyte (encode-coding-string str2 coding-system))
	    i2 (length enc2))
      (while (and (> i1 0) (= (aref enc1 (1- i1)) (aref enc2 (1- i2))))
	(setq i1 (1- i1) i2 (1- i2)))

      ;; Now (substring enc1 i1) and (substring enc2 i2) are the same,
      ;; and they are the extra control sequences at the tail to
      ;; exclude.
      (substring enc2 0 i2))))


;;; mule-cmds.el ends here
