;;; w32-fns.el --- Lisp routines for Windows NT.

;; Copyright (C) 1994 Free Software Foundation, Inc.

;; Author: Geoff Voelker <voelker@cs.washington.edu>

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

;; (August 12, 1993)
;; Created.

;; (November 21, 1994)
;; [C-M-backspace] defined.
;; mode-line-format defined to show buffer file type.
;; audio bell initialized.

;;; Code:

;; Map delete and backspace
(define-key function-key-map [backspace] "\177")
(define-key function-key-map [delete] "\C-d")
(define-key function-key-map [M-backspace] [?\M-\177])
(define-key function-key-map [C-M-backspace] [\C-\M-delete])

;; Ignore language-change events in isearch.
(define-key isearch-mode-map [language-change] nil)

;; Ignore case on file-name completion
(setq completion-ignore-case t)

;; Map all versions of a filename (8.3, longname, mixed case) to the 
;; same buffer.
(setq find-file-visit-truename t)

(defvar w32-system-shells '("cmd" "cmd.exe" "command" "command.com"
			    "4nt" "4nt.exe" "4dos" "4dos.exe"
			    "ndos" "ndos.exe")
  "List of strings recognized as Windows NT/9X system shells.")

(defun w32-using-nt ()
  "Return t if literally running on Windows NT (i.e., not Windows 9X)."
  (and (eq system-type 'windows-nt) (getenv "SystemRoot")))

(defun w32-shell-name ()
  "Return the name of the shell being used."
  (or (and (boundp 'explicit-shell-file-name) explicit-shell-file-name)
      (getenv "ESHELL")
      (getenv "SHELL")
      (and (w32-using-nt) "cmd.exe")
      "command.com"))

(defun w32-system-shell-p (shell-name)
  (and shell-name
       (member (downcase (file-name-nondirectory shell-name)) 
	       w32-system-shells)))

(defun w32-shell-dos-semantics ()
  "Return t if the interactive shell being used expects msdos shell semantics."
  (or (w32-system-shell-p (w32-shell-name))
      (and (member (downcase (file-name-nondirectory (w32-shell-name)))
		   '("cmdproxy" "cmdproxy.exe"))
	   (w32-system-shell-p (getenv "COMSPEC")))))

(defvar w32-allow-system-shell nil
  "*Disable startup warning when using \"system\" shells.")

(defun w32-check-shell-configuration ()
  "Check the configuration of shell variables on Windows NT/9X.
This function is invoked after loading the init files and processing
the command line arguments.  It issues a warning if the user or site
has configured the shell with inappropriate settings."
  (interactive)
  (let ((prev-buffer (current-buffer))
	(buffer (get-buffer-create "*Shell Configuration*"))
	(system-shell))
    (set-buffer buffer)
    (erase-buffer)
    (if (w32-system-shell-p (getenv "ESHELL"))
	(insert (format "Warning! The ESHELL environment variable uses %s.
You probably want to change it so that it uses cmdproxy.exe instead.\n\n" 
			(getenv "ESHELL"))))
    (if (w32-system-shell-p (getenv "SHELL"))
	(insert (format "Warning! The SHELL environment variable uses %s.
You probably want to change it so that it uses cmdproxy.exe instead.\n\n" 
			(getenv "SHELL"))))
    (if (w32-system-shell-p shell-file-name)
	(insert (format "Warning! shell-file-name uses %s.
You probably want to change it so that it uses cmdproxy.exe instead.\n\n" 
			shell-file-name)))
    (if (and (boundp 'explicit-shell-file-name)
	     (w32-system-shell-p explicit-shell-file-name))
	(insert (format "Warning! explicit-shell-file-name uses %s.
You probably want to change it so that it uses cmdproxy.exe instead.\n\n"
			explicit-shell-file-name)))
    (setq system-shell (> (buffer-size) 0))

    ;; Allow user to specify that they really do want to use one of the
    ;; "system" shells, despite the drawbacks, but still warn if
    ;; shell-command-switch doesn't match.
    (if w32-allow-system-shell
	(erase-buffer))

    (cond (system-shell
	   ;; System shells.
	   (if (string-equal "-c" shell-command-switch)
	       (insert "Warning! shell-command-switch is \"-c\".
You should set this to \"/c\" when using a system shell.\n\n"))
	   (if w32-quote-process-args
	       (insert "Warning! w32-quote-process-args is t.
You should set this to nil when using a system shell.\n\n")))
	  ;; Non-system shells.
	  (t
	   (if (string-equal "/c" shell-command-switch)
	       (insert "Warning! shell-command-switch is \"/c\".
You should set this to \"-c\" when using a non-system shell.\n\n"))
	   (if (not w32-quote-process-args)
	       (insert "Warning! w32-quote-process-args is nil.
You should set this to t when using a non-system shell.\n\n"))))
    (if (> (buffer-size) 0)
	(display-buffer buffer)
      (kill-buffer buffer))
    (set-buffer prev-buffer)))

(add-hook 'after-init-hook 'w32-check-shell-configuration)

;;; Override setting chosen at startup.
(defun set-default-process-coding-system ()
  ;; Most programs on Windows will accept Unix line endings on input
  ;; (and some programs ported from Unix require it) but most will
  ;; produce DOS line endings on output.
  (setq default-process-coding-system
	(if default-enable-multibyte-characters
	    '(undecided-dos . undecided-unix)
	  '(raw-text-dos . raw-text-unix)))
  (or (w32-using-nt)
      ;; On Windows 9x, make cmdproxy default to using DOS line endings
      ;; for input, because command.com requires this.
      (setq process-coding-system-alist
	    `(("[cC][mM][dD][pP][rR][oO][xX][yY]"
	       . ,(if default-enable-multibyte-characters
		      '(undecided-dos . undecided-dos)
		    '(raw-text-dos . raw-text-dos)))))))

(add-hook 'before-init-hook 'set-default-process-coding-system)


;;; Basic support functions for managing Emacs' locale setting

(defvar w32-valid-locales nil
  "List of locale ids known to be supported.")

;;; This is the brute-force version; an efficient version is now
;;; built-in though.
(if (not (fboundp 'w32-get-valid-locale-ids))
    (defun w32-get-valid-locale-ids ()
      "Return list of all valid Windows locale ids."
      (let ((i 65535)
	    locales)
	(while (> i 0)
	  (if (w32-get-locale-info i)
	      (setq locales (cons i locales)))
	  (setq i (1- i)))
	locales)))

(defun w32-list-locales ()
  "List the name and id of all locales supported by Windows."
  (interactive)
  (if (null w32-valid-locales)
      (setq w32-valid-locales (w32-get-valid-locale-ids)))
  (switch-to-buffer-other-window (get-buffer-create "*Supported Locales*"))
  (erase-buffer)
  (insert "LCID\tAbbrev\tFull name\n\n")
  (insert (mapconcat
	   '(lambda (x)
	      (format "%d\t%s\t%s"
		      x
		      (w32-get-locale-info x)
		      (w32-get-locale-info x t)))
	   w32-valid-locales "\n"))
  (insert "\n")
  (goto-char (point-min)))


;;; Setup Info-default-directory-list to include the info directory
;;; near where Emacs executable was installed.  We used to set INFOPATH,
;;; but when this is set Info-default-directory-list is ignored.  We
;;; also cannot rely upon what is set in paths.el because they assume
;;; that configuration during build time is correct for runtime.
(defun w32-init-info ()
  (let* ((instdir (file-name-directory invocation-directory))
	 (dir1 (expand-file-name "../info/" instdir))
	 (dir2 (expand-file-name "../../../info/" instdir)))
    (if (file-exists-p dir1)
	(setq Info-default-directory-list 
	      (append Info-default-directory-list (list dir1)))
      (if (file-exists-p dir2)
	  (setq Info-default-directory-list
		(append Info-default-directory-list (list dir2)))))))

(add-hook 'before-init-hook 'w32-init-info)

;;; The variable source-directory is used to initialize Info-directory-list.
;;; However, the common case is that Emacs is being used from a binary
;;; distribution, and the value of source-directory is meaningless in that
;;; case.  Even worse, source-directory can refer to a directory on a drive
;;; on the build machine that happens to be a removable drive on the user's
;;; machine.  When this happens, Emacs tries to access the removable drive
;;; and produces the abort/retry/ignore dialog.  Since we do not use
;;; source-directory, set it to something that is a reasonable approximation
;;; on the user's machine.

(add-hook 'before-init-hook 
	  '(lambda ()
	     (setq source-directory (file-name-as-directory 
				     (expand-file-name ".." exec-directory)))))

;; Avoid creating auto-save file names containing invalid characters.
(fset 'original-make-auto-save-file-name
      (symbol-function 'make-auto-save-file-name))

(defun make-auto-save-file-name ()
  "Return file name to use for auto-saves of current buffer.
Does not consider `auto-save-visited-file-name' as that variable is checked
before calling this function.  You can redefine this for customization.
See also `auto-save-file-name-p'."
  (convert-standard-filename (original-make-auto-save-file-name)))

(defun convert-standard-filename (filename)
  "Convert a standard file's name to something suitable for the current OS.
This function's standard definition is trivial; it just returns the argument.
However, on some systems, the function is redefined
with a definition that really does change some file names."
  (let ((name (copy-sequence filename))
	(start 0))
    ;; leave ':' if part of drive specifier
    (if (eq (aref name 1) ?:)
	(setq start 2))
    ;; destructively replace invalid filename characters with !
    (while (string-match "[?*:<>|\"\000-\037]" name start)
      (aset name (match-beginning 0) ?!)
      (setq start (match-end 0)))
    ;; convert directory separators to Windows format
    ;; (but only if the shell in use requires it)
    (if (w32-shell-dos-semantics)
	(while (string-match "/" name start)
	  (aset name (match-beginning 0) ?\\)
	  (setq start (match-end 0))))
      name))

;;; Fix interface to (X-specific) mouse.el
(defun x-set-selection (type data)
  (or type (setq type 'PRIMARY))
  (put 'x-selections type data))

(defun x-get-selection (&optional type data-type)
  (or type (setq type 'PRIMARY))
  (get 'x-selections type))

(defun set-w32-system-coding-system (coding-system)
  "Set the coding system used by the Windows System to CODING-SYSTEM.
This is used for things like passing font names with non-ASCII
characters in them to the system. For a list of possible values of
CODING-SYSTEM, use \\[list-coding-systems]."
  (interactive
   (list (let ((default w32-system-coding-system))
           (read-coding-system
            (format "Coding system for system calls (default, %s): "
                    default)
            default))))
  (check-coding-system coding-system)
  (setq w32-system-coding-system coding-system))
;; Set system coding system initially to iso-latin-1
(set-w32-system-coding-system 'iso-latin-1)

;;; Set to a system sound if you want a fancy bell.
(set-message-beep nil)

;;; The "Windows" keys on newer keyboards bring up the Start menu
;;; whether you want it or not - make Emacs ignore these keystrokes
;;; rather than beep.
(global-set-key [lwindow] 'ignore)
(global-set-key [rwindow] 'ignore)

;; Map certain keypad keys into ASCII characters
;; that people usually expect.
(define-key function-key-map [tab] [?\t])
(define-key function-key-map [linefeed] [?\n])
(define-key function-key-map [clear] [11])
(define-key function-key-map [return] [13])
(define-key function-key-map [escape] [?\e])
(define-key function-key-map [M-tab] [?\M-\t])
(define-key function-key-map [M-linefeed] [?\M-\n])
(define-key function-key-map [M-clear] [?\M-\013])
(define-key function-key-map [M-return] [?\M-\015])
(define-key function-key-map [M-escape] [?\M-\e])

;; These don't do the right thing (voelker)
;(define-key function-key-map [backspace] [127])
;(define-key function-key-map [delete] [127])
;(define-key function-key-map [M-backspace] [?\M-\d])
;(define-key function-key-map [M-delete] [?\M-\d])

;; These tell read-char how to convert
;; these special chars to ASCII.
(put 'tab 'ascii-character ?\t)
(put 'linefeed 'ascii-character ?\n)
(put 'clear 'ascii-character 12)
(put 'return 'ascii-character 13)
(put 'escape 'ascii-character ?\e)
(put 'backspace 'ascii-character 127)
(put 'delete 'ascii-character 127)

;;; w32-fns.el ends here
