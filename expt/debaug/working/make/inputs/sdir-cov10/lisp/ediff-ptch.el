;;; ediff-ptch.el --- Ediff's  patch support

;; Copyright (C) 1996, 1997 Free Software Foundation, Inc.

;; Author: Michael Kifer <kifer@cs.sunysb.edu>

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
	 
(provide 'ediff-ptch)

(defgroup ediff-ptch nil
  "Ediff patch support"
  :tag "Patch"
  :prefix "ediff-"
  :group 'ediff)

;; compiler pacifier
(defvar ediff-window-A)
(defvar ediff-window-B)
(defvar ediff-window-C)
(defvar ediff-use-last-dir)
(defvar ediff-shell)

(eval-when-compile
  (let ((load-path (cons (expand-file-name ".") load-path)))
    (or (featurep 'ediff-init)
	(load "ediff-init.el" nil nil 'nosuffix))
    (or (featurep 'ediff)
	(load "ediff.el" nil nil 'nosuffix))
    ))
;; end pacifier

(require 'ediff-init)

(defcustom ediff-patch-program  "patch"
  "*Name of the program that applies patches.
It is recommended to use GNU-compatible versions."
  :type 'string
  :group 'ediff-ptch)
(defcustom ediff-patch-options "-f"
  "*Options to pass to ediff-patch-program.

Note: the `-b' option should be specified in `ediff-backup-specs'.

It is recommended to pass the `-f' option to the patch program, so it won't ask
questions. However, some implementations don't accept this option, in which
case the default value for this variable should be changed."
  :type 'string
  :group 'ediff-ptch)

(defvar ediff-last-dir-patch nil
  "Last directory used by an Ediff command for file to patch.")

;; the default backup extension
(defconst ediff-default-backup-extension
  (if (memq system-type '(vax-vms axp-vms emx ms-dos))
      "_orig" ".orig"))
  

(defcustom ediff-backup-extension ediff-default-backup-extension
  "Backup extension used by the patch program.
See also `ediff-backup-specs'."
  :type 'string
  :group 'ediff-ptch)

(defun ediff-test-patch-utility ()
  (cond ((zerop (call-process ediff-patch-program nil nil nil "-z." "-b"))
	 ;; GNU `patch' v. >= 2.2
	 'gnu)
	((zerop (call-process ediff-patch-program nil nil nil "-b"))
	 'posix)
	(t 'traditional)))

(defcustom ediff-backup-specs 
  (let ((type (ediff-test-patch-utility)))
    (cond ((eq type 'gnu)
	   ;; GNU `patch' v. >= 2.2
	   (format "-z%s -b" ediff-backup-extension))
	  ((eq type 'posix)
	   ;; POSIX `patch' -- ediff-backup-extension must be ".orig"
	   (setq ediff-backup-extension ediff-default-backup-extension)
	   "-b")
	  (t
	   ;; traditional `patch'
	   (format "-b %s" ediff-backup-extension))))
  "*Backup directives to pass to the patch program.
Ediff requires that the old version of the file \(before applying the patch\)
be saved in a file named `the-patch-file.extension'. Usually `extension' is
`.orig', but this can be changed by the user and may depend on the system.
Therefore, Ediff needs to know the backup extension used by the patch program.

Some versions of the patch program let you specify `-b backup-extension'.
Other versions only permit `-b', which assumes the extension `.orig'
\(in which case ediff-backup-extension MUST be also `.orig'\). The latest
versions of GNU patch require `-b -z backup-extension'.

Note that both `ediff-backup-extension' and `ediff-backup-specs'
must be set properly. If your patch program takes the option `-b',
but not `-b extension', the variable `ediff-backup-extension' must
still be set so Ediff will know which extension to use.

Ediff tries to guess the appropriate value for this variables. It is believed
to be working for `traditional' patch, all versions of GNU patch, and for POSIX
patch. So, don't change these variables, unless the default doesn't work."
  :type 'string
  :group 'ediff-ptch)


(defcustom ediff-patch-default-directory nil
  "*Default directory to look for patches."
  :type '(choice (const nil) string)
  :group 'ediff-ptch)

(defcustom ediff-context-diff-label-regexp
  (concat "\\(" 	; context diff 2-liner
	  "^\\*\\*\\* \\([^ \t]+\\)[^*]+[\t ]*\n--- \\([^ \t]+\\)"
	  "\\|" 	; GNU unified format diff 2-liner
	  "^--- \\([^ \t]+\\)[\t ]+.*\n\\+\\+\\+ \\([^ \t]+\\)"
	  "\\)")
  "*Regexp matching filename 2-liners at the start of each context diff.
You probably don't want to change that, unless you are using an obscure patch
program."
  :type 'regexp
  :group 'ediff-ptch)

;; The buffer of the patch file. Local to control buffer.
(ediff-defvar-local ediff-patchbufer nil "")

;; The buffer where patch displays its diagnostics.
(ediff-defvar-local ediff-patch-diagnostics nil "")

;; Map of patch buffer. Has the form:
;;    ((filename1 marker1 marker2) (filename2 marker1 marker2) ...)
;; where filenames are files to which patch would have applied the patch;
;; marker1 delimits the beginning of the corresponding patch and marker2 does
;; it for the end.
(ediff-defvar-local ediff-patch-map nil "")

;; strip prefix from filename
;; returns /dev/null, if can't strip prefix
(defsubst ediff-file-name-sans-prefix (filename prefix)
  (save-match-data
    (if (string-match (concat "^" prefix) filename)
	(substring filename (match-end 0))
      (concat "/null/" filename))))



;; no longer used
;; return the number of matches of regexp in buf starting from the beginning
(defun ediff-count-matches (regexp buf)
  (ediff-with-current-buffer buf
    (let ((count 0) opoint)
      (save-excursion
	(goto-char (point-min))
	(while (and (not (eobp))
		    (progn (setq opoint (point))
			   (re-search-forward regexp nil t)))
	  (if (= opoint (point))
	      (forward-char 1)
	    (setq count (1+ count)))))
      count)))

;; Scan BUF (which is supposed to contain a patch) and make a list of the form 
;;    ((filename1 marker1 marker2) (filename2 marker1 marker2) ...)
;; where filenames are files to which patch would have applied the patch;
;; marker1 delimits the beginning of the corresponding patch and marker2 does
;; it for the end. This list is then assigned to ediff-patch-map.
;; Returns the number of elements in the list ediff-patch-map
(defun ediff-map-patch-buffer (buf)
  (ediff-with-current-buffer buf
    (let ((count 0)
	  (mark1 (move-marker (make-marker) (point-min)))
	  (mark1-end (point-min))
	  (possible-file-names '("/dev/null" . "/dev/null"))
	  mark2-end mark2 filenames
	  beg1 beg2 end1 end2
	  patch-map opoint)
      (save-excursion
	(goto-char (point-min))
	(setq opoint (point))
	(while (and (not (eobp))
		    (re-search-forward ediff-context-diff-label-regexp nil t))
	  (if (= opoint (point))
	      (forward-char 1) ; ensure progress towards the end
	    (setq mark2 (move-marker (make-marker) (match-beginning 0))
		  mark2-end (match-end 0)
		  beg1 (or (match-beginning 2) (match-beginning 4))
 		  end1 (or (match-end 2) (match-end 4))
 		  beg2 (or (match-beginning 3) (match-beginning 5))
 		  end2 (or (match-end 3) (match-end 5)))
	    ;; possible-file-names is holding the new file names until we
	    ;; insert the old file name in the patch map
	    ;; It is a pair (filename from 1st header line . fn from 2nd line)
	    (setq possible-file-names
		  (cons (if (and beg1 end1)
			    (buffer-substring beg1 end1)
			  "/dev/null")
			(if (and beg2 end2)
			    (buffer-substring beg2 end2)
			  "/dev/null")))
	    ;; check for any `Index:' or `Prereq:' lines, but don't use them
	    (if (re-search-backward "^Index:" mark1-end 'noerror)
		(move-marker mark2 (match-beginning 0)))
	    (if (re-search-backward "^Prereq:" mark1-end 'noerror)
		(move-marker mark2 (match-beginning 0)))

	    (goto-char mark2-end)
	    
	    (if filenames
		(setq patch-map (cons (list filenames mark1 mark2) patch-map)))
	    (setq mark1 mark2
		  mark1-end mark2-end
		  filenames possible-file-names))
	  (setq opoint (point)
		count (1+ count))))
      (setq mark2 (point-max-marker)
	    patch-map (cons (list possible-file-names mark1 mark2) patch-map))
      (setq ediff-patch-map (nreverse patch-map))
      count)))

;; Fix up the file names in the list using the argument FILENAME
;; Algorithm: find the first file's directory and cut it out from each file
;; name in the patch. Prepend the directory of FILENAME to each file in the
;; patch. In addition, the first file in the patch is replaced by FILENAME.
;; Each file is actually a file-pair of files found in the context diff header
;; In the end, for each pair, we select the shortest existing file.
;; Note: Ediff doesn't recognize multi-file patches that are separated
;; with the `Index:' line. It treats them as a single-file patch.
;;
;; Executes inside the patch buffer
(defun ediff-fixup-patch-map (filename)
  (setq filename (expand-file-name filename))
  (let ((actual-dir (if (file-directory-p filename)
			;; directory part of filename
			(file-name-as-directory filename)
		      (file-name-directory filename)))
	;; directory part of the first file in the patch
	(base-dir1 (file-name-directory (car (car (car ediff-patch-map)))))
	(base-dir2 (file-name-directory (cdr (car (car ediff-patch-map)))))
	)

    ;; chop off base-dirs
    (mapcar (function (lambda (triple)
			(or (string= (car (car triple)) "/dev/null")
			    (setcar (car triple)
				    (ediff-file-name-sans-prefix
				     (car (car triple)) base-dir1)))
			(or (string= (cdr (car triple)) "/dev/null")
			    (setcdr (car triple)
				    (ediff-file-name-sans-prefix
				     (cdr (car triple)) base-dir2)))
			))
	    ediff-patch-map)

    ;; take the given file name into account
    (or (file-directory-p filename)
	(string= "/dev/null" filename)
	(progn
	  (setcar (car ediff-patch-map)
		  (cons (file-name-nondirectory filename)
			(file-name-nondirectory filename)))))

    ;; prepend actual-dir
    (mapcar (function (lambda (triple)
			 (if (and (string-match "^/null/" (car (car triple)))
				  (string-match "^/null/" (cdr (car triple))))
			     ;; couldn't strip base-dir1 and base-dir2
			     ;; hence, something wrong
			     (progn
			       (with-output-to-temp-buffer ediff-msg-buffer
				 (princ
				  (format "
The patch file contains a context diff for
	%s
	%s
However, Ediff cannot infer the name of the actual file
to be patched on your system. If you know the correct file name,
please enter it now.

If you don't know and still would like to apply patches to
other files, enter /dev/null
"
					  (substring (car (car triple)) 6)
					  (substring (cdr (car triple)) 6))))
			       (let ((directory t)
				     user-file)
				 (while directory
				   (setq user-file
					 (read-file-name
					  "Please enter file name: "
					  actual-dir actual-dir t))
				   (if (not (file-directory-p user-file))
				       (setq directory nil)
				     (setq directory t)
				     (beep)
				     (message "%s is a directory" user-file)
				     (sit-for 2)))
				 (setcar triple (cons user-file user-file))))
			   (setcar (car triple)
				   (expand-file-name 
				    (concat actual-dir (car (car triple)))))
			   (setcdr (car triple)
				   (expand-file-name 
				    (concat actual-dir (cdr (car triple))))))
			 ))
	    ediff-patch-map)
    ;; check for the shorter existing file in each pair and discard the other
    ;; one
    (mapcar (function (lambda (triple)
			(let* ((file1 (car (car triple)))
			       (file2 (cdr (car triple)))
			       (f1-exists (file-exists-p file1))
			       (f2-exists (file-exists-p file2)))
			  (cond
			   ((and (< (length file2) (length file1))
				 f2-exists)
			    (setcar triple file2))
			   ((and (< (length file1) (length file2))
				 f1-exists)
			    (setcar triple file1))
			   ((and f1-exists f2-exists
				 (string= file1 file2))
			    (setcar triple file1))
			   ((and f1-exists f2-exists)
			    (with-output-to-temp-buffer ediff-msg-buffer
			      (princ (format "
Ediff has inferred that
	%s
	%s
are two possible targets for applying the patch.
Both files seem to be plausible alternatives.

Please advice:
    Type `y' to use %s as the target;
    Type `n' to use %s as the target.
"
					     file1 file2 file2 file1)))
			    (setcar triple
				    (if (y-or-n-p (format "Use %s ? " file2))
					file2 file1)))
			   (f2-exists (setcar triple file2))
			   (f1-exists (setcar triple file1))
			   (t
			    (with-output-to-temp-buffer ediff-msg-buffer
			      (princ "\nEdiff has inferred that")
			      (if (string= file1 file2)
				  (princ (format "
	%s
is the target for this patch. However, this file does not exist."
						 file1))
				(princ (format "
	%s
	%s
are two possible targets for this patch. However, these files do not exist."
					       file1 file2)))
			      (princ "
\nPlease enter an alternative patch target ...\n"))
			    (let ((directory t)
				  target)
			      (while directory
				(setq target (read-file-name 
					      "Please enter a patch target: "
					      actual-dir actual-dir t))
				(if (not (file-directory-p target))
				    (setq directory nil)
				  (beep)
				  (message "%s is a directory" target)
				  (sit-for 2)))
			      (setcar triple target)))))))
	    ediff-patch-map)
    ))

(defun ediff-show-patch-diagnostics ()
  (interactive)
  (cond ((window-live-p ediff-window-A)
	 (set-window-buffer ediff-window-A ediff-patch-diagnostics))
	((window-live-p ediff-window-B)
	 (set-window-buffer ediff-window-B ediff-patch-diagnostics))
	(t (display-buffer ediff-patch-diagnostics 'not-this-window))))

(defun ediff-get-patch-buffer ()
  "Obtain patch buffer.  If patch is already in a buffer---use it.
Else, read patch file into a new buffer."
  (let ((dir (cond (ediff-patch-default-directory) ; try patch default dir
		   (ediff-use-last-dir ediff-last-dir-patch)
		   (t default-directory)))
	patch-buf)
    (if (let ((last-nonmenu-event t) ; Emacs: don't use dialog box
	      last-command-event)    ; XEmacs: don't use dialog box
	  (y-or-n-p "Is the patch already in a buffer? "))
	(setq patch-buf
	      (get-buffer
	       (read-buffer
		"Which buffer contains the patch? "
		(ediff-other-buffer
		 (if (eq (next-window (selected-window)) (selected-window))
		     ;; only one window in frame --- don't skip current buff
		     ""
		   ;; >1 window --- skip current buff, assuming this is the one
		   ;; to patch, not the one that has the patch
		   (current-buffer)))
		'must-match)))
      (setq patch-buf
	    (find-file-noselect
	     (read-file-name "Which file contains the patch? "
			     dir nil 'must-match))))
    
    (ediff-with-current-buffer patch-buf
      (goto-char (point-min))
      (or (ediff-get-visible-buffer-window patch-buf)
	  (progn
	    (pop-to-buffer patch-buf 'other-window)
	    (select-window (previous-window)))))
    (ediff-map-patch-buffer patch-buf)
    patch-buf))

;; Dispatch the right patch file function: regular or meta-level,
;; depending on how many patches are in the patch file.
;; At present, there is no support for meta-level patches.
;; Should return either the ctl buffer or the meta-buffer
(defun ediff-dispatch-file-patching-job (patch-buf filename
						   &optional startup-hooks)
  (ediff-with-current-buffer patch-buf
    ;; relativize names in the patch with respect to source-file
    (ediff-fixup-patch-map filename)
    (if (< (length ediff-patch-map) 2)
	(ediff-patch-file-internal
	 patch-buf
	 (if (and (not (string-match "^/dev/null" (car (car ediff-patch-map))))
		  (> (length (car (car ediff-patch-map))) 1))
	     (car (car ediff-patch-map))
	   filename)
	 startup-hooks)
      (ediff-multi-patch-internal patch-buf startup-hooks))
    ))


;; When patching a buffer, never change the orig file. Instead, create a new
;; buffer, ***_patched, even if the buff visits a file.
;; Users who want to actually patch the buffer should use
;; ediff-patch-file, not ediff-patch-buffer.
(defun ediff-patch-buffer-internal (patch-buf
				    buf-to-patch-name
				    &optional startup-hooks)
  (let* ((buf-to-patch (get-buffer buf-to-patch-name))
	 (visited-file (if buf-to-patch (buffer-file-name  buf-to-patch)))
	 (buf-mod-status (buffer-modified-p buf-to-patch))
	 (multifile-patch-p (> (length (ediff-with-current-buffer patch-buf
					 ediff-patch-map)) 1))
	 default-dir file-name ctl-buf)
    (if multifile-patch-p
	(error
	 "Can't apply multi-file patches to buffers that visit no files"))

    ;; create a temp file to patch
    (ediff-with-current-buffer buf-to-patch
      (setq default-dir default-directory)
      (setq file-name (ediff-make-temp-file buf-to-patch))
      ;; temporarily switch visited file name, if any
      (set-visited-file-name file-name)
      ;; don't create auto-save file, if buff was visiting a file
      (or visited-file
	  (setq buffer-auto-save-file-name nil))
      ;; don't confuse the user with a new bufname
      (rename-buffer buf-to-patch-name)
      (set-buffer-modified-p nil)
      (set-visited-file-modtime) ; sync buffer and temp file
      (setq default-directory default-dir)
      )
  
    ;; dispatch a patch function
    (setq ctl-buf (ediff-dispatch-file-patching-job
		   patch-buf file-name startup-hooks))
    
    (ediff-with-current-buffer ctl-buf
      (delete-file (buffer-file-name ediff-buffer-A))
      (delete-file (buffer-file-name ediff-buffer-B))
      (ediff-with-current-buffer ediff-buffer-A
	(if default-dir (setq default-directory default-dir))
	(set-visited-file-name visited-file) ; visited-file might be nil
	(rename-buffer buf-to-patch-name)
	(set-buffer-modified-p buf-mod-status))
      (ediff-with-current-buffer ediff-buffer-B
	(setq buffer-auto-save-file-name nil) ; don't create auto-save file
	(if default-dir (setq default-directory default-dir))
	(set-visited-file-name nil)
	(rename-buffer (ediff-unique-buffer-name 
			(concat buf-to-patch-name "_patched") ""))
	(set-buffer-modified-p t)))
    ))


;; Traditional patch has weird return codes.
;; GNU and Posix return 1 if some hanks failed and 2 in case of trouble.
;; 0 is a good code in all cases.
;; We'll do the concervative thing.
(defun ediff-patch-return-code-ok (code)
  (eq code 0))
;;;  (if (eq (ediff-test-patch-utility) 'traditional)
;;;      (eq code 0)
;;;    (not (eq code 2))))

(defun ediff-patch-file-internal (patch-buf source-filename
					    &optional startup-hooks)
  (setq source-filename (expand-file-name source-filename))
  
  (let* ((shell-file-name ediff-shell)
	 (patch-diagnostics (get-buffer-create "*ediff patch diagnostics*"))
	 ;; ediff-find-file may use a temp file to do the patch
	 ;; so, we save source-filename and true-source-filename as a var
	 ;; that initially is source-filename but may be changed to a temp
	 ;; file for the purpose of patching.
	 (true-source-filename source-filename)
	 (target-filename source-filename)
	 target-buf buf-to-patch file-name-magic-p 
	 patch-return-code ctl-buf backup-style aux-wind)
	  
    (if (string-match "V" ediff-patch-options)
	(error
	 "Ediff doesn't take the -V option in `ediff-patch-options'--sorry"))
					
    ;; Make a temp file, if source-filename has a magic file handler (or if
    ;; it is handled via auto-mode-alist and similar magic).
    ;; Check if there is a buffer visiting source-filename and if they are in
    ;; sync; arrange for the deletion of temp file.
    (ediff-find-file 'true-source-filename 'buf-to-patch
		     'ediff-last-dir-patch 'startup-hooks)

    ;; Check if source file name has triggered black magic, such as file name
    ;; handlers or auto mode alist, and make a note of it.
    ;; true-source-filename should be either the original name or a
    ;; temporary file where we put the after-product of the file handler.
    (setq file-name-magic-p (not (equal (file-truename true-source-filename)
					(file-truename source-filename))))
    
    ;; Checkout orig file, if necessary, so that the patched file 
    ;; could be checked back in.
    (ediff-maybe-checkout buf-to-patch)

    (ediff-with-current-buffer patch-diagnostics
      (insert-buffer patch-buf)
      (message "Applying patch ... ")
      ;; fix environment for gnu patch, so it won't make numbered extensions
      (setq backup-style (getenv "VERSION_CONTROL"))
      (setenv "VERSION_CONTROL" nil)
      (setq patch-return-code
	    (call-process-region
	     (point-min) (point-max)
	     shell-file-name
	     t   ; delete region (which contains the patch
	     t   ; insert output (patch diagnostics) in current buffer
	     nil ; don't redisplay
	     shell-command-switch   ; usually -c
	     (format "%s %s %s %s"
		     ediff-patch-program
		     ediff-patch-options
		     ediff-backup-specs
		     (expand-file-name true-source-filename))
	     ))

      ;; restore environment for gnu patch
      (setenv "VERSION_CONTROL" backup-style))

    (message "Applying patch ... done")
    (message "")

    (switch-to-buffer patch-diagnostics)
    (sit-for 0) ; synchronize - let the user see diagnostics
    
    (or (and (ediff-patch-return-code-ok patch-return-code)
	     (file-exists-p
	      (concat true-source-filename ediff-backup-extension)))
	(progn
	  (with-output-to-temp-buffer ediff-msg-buffer
	    (princ (format 
		    "Patch program has failed due to a bad patch file,
it couldn't apply all hunks, OR
it couldn't create the backup for the file being patched.

The former could be caused by a corrupt patch file or because the %S
program doesn't understand the format of the patch file in use.

The second problem might be due to an incompatibility among these settings:
    ediff-patch-program    = %S             ediff-patch-options    = %S
    ediff-backup-extension = %S             ediff-backup-specs     = %S

See Ediff on-line manual for more details on these variables.
In particular, check the documentation for `ediff-backup-specs'. 

In any of the above cases, Ediff doesn't compare files automatically.
However, if the patch was applied partially and the backup file was created,
you can still examine the changes via M-x ediff-files"
			   ediff-patch-program
			   ediff-patch-program
			   ediff-patch-options
			   ediff-backup-extension
			   ediff-backup-specs
			   )))
	  (beep 1)
	  (if (setq aux-wind (get-buffer-window ediff-msg-buffer))
	      (progn
		(select-window aux-wind)
		(goto-char (point-max))))
	  (switch-to-buffer-other-window patch-diagnostics)
	  (error "Patch appears to have failed")))
    
    ;; If black magic is involved, apply patch to a temp copy of the
    ;; file. Otherwise, apply patch to the orig copy.  If patch is applied
    ;; to temp copy, we name the result old-name_patched for local files
    ;; and temp-copy_patched for remote files. The orig file name isn't
    ;; changed, and the temp copy of the original is later deleted.
    ;; Without magic, the original file is renamed (usually into
    ;; old-name_orig) and the result of patching will have the same name as
    ;; the original.
    (if (not file-name-magic-p)
	(ediff-with-current-buffer buf-to-patch
	  (set-visited-file-name
	   (concat source-filename ediff-backup-extension))
	  (set-buffer-modified-p nil))
      
      ;; Black magic in effect.
      ;; If orig file was remote, put the patched file in the temp directory.
      ;; If orig file is local, put the patched file in the directory of
      ;; the orig file.
      (setq target-filename
	    (concat
	     (if (ediff-file-remote-p (file-truename source-filename))
		 true-source-filename
	       source-filename)
	     "_patched"))
      
      (rename-file true-source-filename target-filename t)
      
      ;; arrange that the temp copy of orig will be deleted
      (rename-file (concat true-source-filename ediff-backup-extension)
		   true-source-filename t))
    
    ;; make orig buffer read-only
    (setq startup-hooks
	  (cons 'ediff-set-read-only-in-buf-A startup-hooks))
    
    ;; set up a buf for the patched file
    (setq target-buf (find-file-noselect target-filename))
    
    (setq ctl-buf
	  (ediff-buffers-internal
	   buf-to-patch target-buf nil
	   startup-hooks 'epatch))
    (ediff-with-current-buffer ctl-buf
      (setq ediff-patchbufer patch-buf
	    ediff-patch-diagnostics patch-diagnostics))
  
    (bury-buffer patch-diagnostics)
    (message "Type `P', if you need to see patch diagnostics")
    ctl-buf))

(defun ediff-multi-patch-internal (patch-buf &optional startup-hooks)
  (let (meta-buf)
    (setq startup-hooks
	  ;; this sets various vars in the meta buffer inside
	  ;; ediff-prepare-meta-buffer
	  (cons (` (lambda ()
		     ;; tell what to do if the user clicks on a session record
		     (setq ediff-session-action-function
			   'ediff-patch-file-form-meta
			   ediff-meta-patchbufer patch-buf)
		     ))
		startup-hooks))
    (setq meta-buf (ediff-prepare-meta-buffer 
		    'ediff-filegroup-action
		    (ediff-with-current-buffer patch-buf
		      ;; nil replaces a regular expression
		      (cons (list nil (format "%S" patch-buf))
			    ediff-patch-map))
		    "*Ediff Session Group Panel"
		    'ediff-redraw-directory-group-buffer
		    'ediff-multifile-patch
		    startup-hooks))
    (ediff-show-meta-buffer meta-buf)
    ))

  
      

;;; Local Variables:
;;; eval: (put 'ediff-defvar-local 'lisp-indent-hook 'defun)
;;; eval: (put 'ediff-with-current-buffer 'lisp-indent-hook 1)
;;; eval: (put 'ediff-with-current-buffer 'edebug-form-spec '(form body))
;;; End:

;;; ediff-ptch.el ends here
