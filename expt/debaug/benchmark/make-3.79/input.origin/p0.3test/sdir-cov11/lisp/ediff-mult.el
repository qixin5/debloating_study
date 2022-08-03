;;; ediff-mult.el --- support for multi-file/multi-buffer processing in Ediff

;; Copyright (C) 1995, 1996, 1997 Free Software Foundation, Inc.

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

;;; Commentary:

;; Users are encouraged to add functionality to this file.
;; The present file contains all the infrastructure needed for that.
;;
;; Generally, to to implement a new multisession capability within Ediff,
;; you need to tell it 
;;
;;	1. How to display the session group buffer.
;;	   This function must indicate which Ediff sessions are active (+) and
;;	   which are finished (-).
;;	   See ediff-redraw-directory-group-buffer for an example.
;;	   In all likelihood, ediff-redraw-directory-group-buffer can be used
;;	   directly or after a small modification.
;;	2. What action to take when the user clicks button 2 or types v,e, or
;;	   RET.  See ediff-filegroup-action.
;;	3. Provide a list of pairs or triples of file names (or buffers,
;;	   depending on the particular Ediff operation you want to invoke)
;;	   in the following format:
;;	  	(descriptor (obj1 obj2 obj3) (...) ...)
;;	   Actually, the format of this list is pretty much up to the
;;	   developer. The only thing is that it must be a list of lists,
;;	   and the first list must describe the meta session, and subsequent
;;	   elements must describe individual sessions.
;;	   This descriptor must be a list of two, three, or four elements (nil
;;	   or string). The function ediff-redraw-registry-buffer displays the
;;	   second through last of these in the registry buffer. 
;;	   Also, keep in mind that the function ediff-prepare-meta-buffer
;;	   (which see) prepends the session group buffer to the descriptor and
;;	   nil in front of each subsequent list (i.e., the above list 
;;	   will become
;;              ((meta-buf descriptor) (nil obj1 obj2 obj3) (nil ...) ...)
;;	   Ediff expects that your function (in 2 above) will arrange to
;;	   replace this prepended nil (via setcar) with the actual ediff
;;	   control buffer associated with an appropriate Ediff session.
;;	   This is arranged through internal startup hooks that can be passed
;;	   to any of Ediff major entries (such as ediff-files, epatch, etc.).
;;	   See how this is done in ediff-filegroup-action.
;;
;;	   Session descriptions are of the form (obj1 obj2 obj3), which
;;	   describe objects relevant to the session. Usually they are names of
;;	   files, but sometimes they may be other things. For instance, obj3 is
;;	   nil for jobs that involve only two files. For patch jobs, obj2 and
;;	   obj3 are markers that specify the patch corresponding to the file
;;	   (whose name is obj1).
;;	4. Write a function that makes a call to ediff-prepare-meta-buffer
;;	   passing all this info. 
;;	   You may be able to use ediff-directories-internal as a template.
;;	5. If you intend to add several related pieces of functionality,
;;	   you may want to keep the function in 4 as an internal version
;;	   and then write several top-level interactive functions that call it
;;	   with different parameters.
;;	   See how ediff-directories, ediff-merge-directories, and
;;	   ediff-merge-directories-with-ancestor all use
;;	   ediff-directories-internal. 
;;
;; A useful addition here could be session groups selected by patterns
;; (which are different in each directory). For instance, one may want to
;; compare files of the form abc{something}.c to files old{something}.d
;; which may be in the same or different directories. Or, one may want to
;; compare all files of the form {something} to files of the form {something}~.
;;
;; Implementing this requires writing an collating function, which should pair
;; up appropriate files. It will also require a generalization of the functions
;; that do the layout of the meta- and differences buffers and of
;; ediff-filegroup-action.

;;; Code:

(provide 'ediff-mult)

(defgroup ediff-mult nil
  "Multi-file and multi-buffer processing in Ediff"
  :prefix "ediff-"
  :group 'ediff)


;; compiler pacifier
(eval-when-compile
  (let ((load-path (cons (expand-file-name ".") load-path)))
    (or (featurep 'ediff-init)
	(load "ediff-init.el" nil nil 'nosuffix))
    (or (featurep 'ediff-util)
	(load "ediff-util.el" nil nil 'nosuffix))
    ))
;; end pacifier

(require 'ediff-init)
(require 'ediff-util)

;; meta-buffer
(ediff-defvar-local ediff-meta-buffer nil "")
(ediff-defvar-local ediff-parent-meta-buffer nil "")
;; the registry buffer
(defvar ediff-registry-buffer nil)

(defconst ediff-meta-buffer-message "This is an Ediff Session Group Panel: %s

Useful commands:
     button2, v, or RET over session record:   start that Ediff session
     M:\tin sessions invoked from here, brings back this group panel
     R:\tdisplay the registry of active Ediff sessions
     h:\tmark session for hiding (toggle)
     x:\thide marked sessions; with prefix arg: unhide
     m:\tmark session for a non-hiding operation (toggle)
 uh/um:\tunmark all sessions marked for hiding/operation
 n,SPC:\tnext session
 p,DEL:\tprevious session
     E:\tbrowse Ediff on-line manual
     T:\ttoggle truncation of long file names
     q:\tquit this session group
")

(ediff-defvar-local ediff-meta-buffer-map nil
  "The keymap for the meta buffer.")
(defvar ediff-dir-diffs-buffer-map (make-sparse-keymap)
  "The keymap to be installed in the buffer showing differences between
directories.")

;; Variable specifying the action to take when the use invokes ediff in the
;; meta buffer. This is usually ediff-registry-action or ediff-filegroup-action
(ediff-defvar-local ediff-meta-action-function nil "")
;; Tells ediff-update-meta-buffer how to redraw it
(ediff-defvar-local ediff-meta-redraw-function nil "")
;; Tells ediff-filegroup-action and similar procedures how to invoke Ediff for
;; the sessions in a given session group
(ediff-defvar-local ediff-session-action-function nil "")

(ediff-defvar-local ediff-metajob-name nil "")

;; buffer used to collect custom diffs from individual sessions in the group
(ediff-defvar-local ediff-meta-diff-buffer nil "")

;; history var to use for filtering groups
(defvar ediff-filtering-regexp-history nil "")

;; This has the form ((meta-buf regexp dir1 dir2 dir3 merge-auto-store-dir)
;; (ctl-buf session-status (file1 . eq-status) (file2 . eq-status) (file3
;; . eq-status)) (ctl-buf session-status (file1 . eq-status) (file2
;; . eq-status)) ...)
;; If ctl-buf is nil, the file-pair hasn't processed yet. If it is
;; killed-buffer object, the file pair has been processed. If it is a live
;; buffer, this means ediff is still working on the pair.
;; Eq-status of a file is t if the file equals some other file in the same
;; group.
(ediff-defvar-local ediff-meta-list nil "")

(ediff-defvar-local ediff-meta-session-number nil "")


;; the difference list between directories in a directory session group
(ediff-defvar-local ediff-dir-difference-list nil "")
(ediff-defvar-local ediff-dir-diffs-buffer nil "")

;; The registry of Ediff sessions. A list of control buffers.
(defvar ediff-session-registry nil)

(defcustom ediff-meta-truncate-filenames t
  "*If non-nil, truncate long file names in the session group buffers.
This can be toggled with `ediff-toggle-filename-truncation'."
  :type 'hook
  :group 'ediff-mult)
(defcustom ediff-registry-setup-hook nil
  "*Hooks run just after the registry control panel is set up."
  :type 'hook
  :group 'ediff-mult)
(defcustom ediff-session-group-setup-hook nil
  "*Hooks run just after a meta-buffer controlling a session group, such as
ediff-directories, is run."
  :type 'hook
  :group 'ediff-mult)
(defcustom ediff-quit-session-group-hook nil
  "*Hooks run just before exiting a session group."
  :type 'hook
  :group 'ediff-mult)
(defcustom ediff-show-registry-hook nil
  "*Hooks run just after the registry buffer is shown."
  :type 'hook
  :group 'ediff-mult)
(defcustom ediff-show-session-group-hook nil
  "*Hooks run just after a session group buffer is shown."
  :type 'hook
  :group 'ediff-mult)
(defcustom ediff-meta-buffer-keymap-setup-hook nil
  "*Hooks run just after setting up the ediff-meta-buffer-map.
This keymap controls key bindings in the meta buffer and is a local variable.
This means that you can set different bindings for different kinds of meta
buffers."
  :type 'hook
  :group 'ediff-mult)

;; buffer holding the multi-file patch. local to the meta buffer
(ediff-defvar-local ediff-meta-patchbufer nil "")

;;; API for ediff-meta-list

;; group buffer/regexp
(defsubst ediff-get-group-buffer (meta-list)
  (nth 0 (car meta-list)))

(defsubst ediff-get-group-regexp (meta-list)
  (nth 1 (car meta-list)))
;; group objects
(defsubst ediff-get-group-objA (meta-list)
  (nth 2 (car meta-list)))
(defsubst ediff-get-group-objB (meta-list)
  (nth 3 (car meta-list)))
(defsubst ediff-get-group-objC (meta-list)
  (nth 4 (car meta-list)))
(defsubst ediff-get-group-merge-autostore-dir (meta-list)
  (nth 5 (car meta-list)))

;; session buffer
(defsubst ediff-get-session-buffer (elt)
  (nth 0 elt))
(defsubst ediff-get-session-status (elt)
  (nth 1 elt))
(defsubst ediff-set-session-status (session-info new-status)
  (setcar (cdr session-info) new-status))
;; session objects
(defsubst ediff-get-session-objA (elt)
  (nth 2 elt))
(defsubst ediff-get-session-objB (elt)
  (nth 3 elt))
(defsubst ediff-get-session-objC (elt)
  (nth 4 elt))
(defsubst ediff-get-session-objA-name (elt)
  (car (nth 2 elt)))
(defsubst ediff-get-session-objB-name (elt)
  (car (nth 3 elt)))
(defsubst ediff-get-session-objC-name (elt)
  (car (nth 4 elt)))
;; equality indicators
(defsubst ediff-get-file-eqstatus (elt)
  (nth 1 elt))
(defsubst ediff-set-file-eqstatus (elt value)
  (setcar (cdr elt) value))

;; The activity marker is either or + (active session, i.e., ediff is currently
;; run in it), or - (finished session, i.e., we've ran ediff in it and then
;; exited). Return nil, if session is neither active nor finished
(defun ediff-get-session-activity-marker (session)
  (let ((session-buf (ediff-get-session-buffer session)))
    (cond ((null session-buf) nil) ; virgin session
	  ((ediff-buffer-live-p session-buf) ?+) ;active session
	  (t ?-))))

;; checks if the session is a meta session
(defun ediff-meta-session-p (session-info)
  (and (stringp (ediff-get-session-objA-name session-info))
       (file-directory-p (ediff-get-session-objA-name session-info)) 
       (stringp (ediff-get-session-objB-name session-info))
       (file-directory-p (ediff-get-session-objB-name session-info))
       (if (stringp (ediff-get-session-objC-name session-info))
	   (file-directory-p (ediff-get-session-objC-name session-info)) t)))

;; set up the keymap in the meta buffer
(defun ediff-setup-meta-map()
  (setq ediff-meta-buffer-map (make-sparse-keymap))
  (suppress-keymap ediff-meta-buffer-map)
  (define-key ediff-meta-buffer-map "q" 'ediff-quit-meta-buffer)
  (define-key ediff-meta-buffer-map "T" 'ediff-toggle-filename-truncation)
  (define-key ediff-meta-buffer-map "R" 'ediff-show-registry)
  (define-key ediff-meta-buffer-map "E" 'ediff-documentation)
  (define-key ediff-meta-buffer-map "v" ediff-meta-action-function)
  (define-key ediff-meta-buffer-map "\C-m" ediff-meta-action-function)
  (define-key ediff-meta-buffer-map  " "  'ediff-next-meta-item)
  (define-key ediff-meta-buffer-map  "n"  'ediff-next-meta-item)
  (define-key ediff-meta-buffer-map  "\C-?"  'ediff-previous-meta-item)
  (define-key ediff-meta-buffer-map  "p"  'ediff-previous-meta-item)
  (define-key ediff-meta-buffer-map  [delete]  'ediff-previous-meta-item)
  (define-key ediff-meta-buffer-map  [backspace]  'ediff-previous-meta-item)
  (or (ediff-one-filegroup-metajob)
      (progn
	(define-key ediff-meta-buffer-map "=" nil)
	(define-key ediff-meta-buffer-map "==" 'ediff-meta-mark-equal-files)
	(define-key ediff-meta-buffer-map "=m" 'ediff-meta-mark-equal-files)
	(define-key ediff-meta-buffer-map "=h" 'ediff-meta-mark-equal-files)))
  (if ediff-no-emacs-help-in-control-buffer
      (define-key ediff-meta-buffer-map  "\C-h"  'ediff-previous-meta-item))
  (if ediff-emacs-p
      (define-key ediff-meta-buffer-map [mouse-2] ediff-meta-action-function)
    (define-key ediff-meta-buffer-map [button2] ediff-meta-action-function))

  (use-local-map ediff-meta-buffer-map)
  ;; modify ediff-meta-buffer-map here
  (run-hooks 'ediff-meta-buffer-keymap-setup-hook))

(defun ediff-meta-mode ()
  "This mode controls all operations on Ediff session groups.
It is entered through one of the following commands:
	`ediff-directories'
	`edirs'
	`ediff-directories3'
	`edirs3'
	`ediff-merge-directories'
	`edirs-merge'
	`ediff-merge-directories-with-ancestor'
	`edirs-merge-with-ancestor'
	`ediff-directory-revisions'
	`edir-revisions'
	`ediff-merge-directory-revisions'
	`edir-merge-revisions'
	`ediff-merge-directory-revisions-with-ancestor'
	`edir-merge-revisions-with-ancestor'

Commands:
\\{ediff-meta-buffer-map}"
  (kill-all-local-variables)
  (setq major-mode 'ediff-meta-mode)
  (setq mode-name "MetaEdiff"))


;; the keymap for the buffer showing directory differences
(suppress-keymap ediff-dir-diffs-buffer-map)
(define-key ediff-dir-diffs-buffer-map "q" 'ediff-bury-dir-diffs-buffer)
(define-key ediff-dir-diffs-buffer-map " " 'next-line)
(define-key ediff-dir-diffs-buffer-map "n" 'next-line)
(define-key ediff-dir-diffs-buffer-map "\C-?" 'previous-line)
(define-key ediff-dir-diffs-buffer-map "p" 'previous-line)
(define-key ediff-dir-diffs-buffer-map [delete] 'previous-line)
(define-key ediff-dir-diffs-buffer-map [backspace] 'previous-line)

(defun ediff-next-meta-item (count)
  "Move to the next item in Ediff registry or session group buffer.
Moves in circular fashion. With numeric prefix arg, skip this many items."
  (interactive "p")
  (or count (setq count 1))
  (let (overl)
    (while (< 0 count)
      (setq count (1- count))
      (ediff-next-meta-item1)
      (setq overl (ediff-get-meta-overlay-at-pos (point)))
      ;; skip invisible ones
      (while (and overl (ediff-overlay-get overl 'invisible))
	(ediff-next-meta-item1)
	(setq overl (ediff-get-meta-overlay-at-pos (point)))))))

;; Move to the next meta item
(defun ediff-next-meta-item1 ()
  (let (pos)
    (setq pos (ediff-next-meta-overlay-start (point)))
    (if pos (goto-char pos))
    (if (eq ediff-metajob-name 'ediff-registry)
	(if (and (ediff-get-meta-info (current-buffer) pos 'noerror)
		 (search-forward "*Ediff" nil t))
	    (skip-chars-backward "a-zA-Z*"))
      (if (> (skip-chars-forward "-+?H* \t0-9") 0)
	  (backward-char 1)))))


(defun ediff-previous-meta-item (count)
  "Move to the previous item in Ediff registry or session group buffer.
Moves in circular fashion. With numeric prefix arg, skip this many items."
  (interactive "p")
  (or count (setq count 1))
  (let (overl)
    (while (< 0 count)
      (setq count (1- count))
      (ediff-previous-meta-item1)
      (setq overl (ediff-get-meta-overlay-at-pos (point)))
      ;; skip invisible ones
      (while (and overl (ediff-overlay-get overl 'invisible))
	(ediff-previous-meta-item1)
	(setq overl (ediff-get-meta-overlay-at-pos (point)))))))

(defun ediff-previous-meta-item1 ()
  (let (pos)
    (setq pos (ediff-previous-meta-overlay-start (point)))
;;;	;; skip deleted
;;;    (while (ediff-get-session-status
;;;	    (ediff-get-meta-info (current-buffer) pos 'noerror))
;;;      (setq pos (ediff-previous-meta-overlay-start pos)))
    
    (if pos (goto-char pos))
    (if (eq ediff-metajob-name 'ediff-registry)
	(if (and (ediff-get-meta-info (current-buffer) pos 'noerror)
		 (search-forward "*Ediff" nil t))
	    (skip-chars-backward "a-zA-Z*"))
      (if (> (skip-chars-forward "-+?H* \t0-9") 0)
	  (backward-char 1)))
    ))

(defsubst ediff-add-slash-if-directory (dir file)
  (if (file-directory-p (concat dir file))
      (file-name-as-directory file)
    file))

(defun ediff-toggle-filename-truncation ()
  "Toggle truncation of long file names in session group buffers.
Set `ediff-meta-truncate-filenames' variable if you want to change the default
behavior."
  (interactive)
  (setq ediff-meta-truncate-filenames (not ediff-meta-truncate-filenames))
  (ediff-update-meta-buffer (current-buffer) 'must-redraw))


;; DIR1, DIR2, DIR3 are directories. DIR3 can be nil.
;; OUTPUT-DIR is a directory for auto-storing the results of merge jobs.
;;	      Can be nil.
;; REGEXP is a regexp used to filter out files in the directories.
;; If a file is a directory in dir1 but not dir2 (or vice versa), it is not
;; included in the intersection. However, a regular file that is a dir in dir3
;; is included, since dir3 files are supposed to be ancestors for merging.
;; Returns a list of the form:
;;	((dir1 dir2 dir3) (f1 f2 f3) (f1 f2 f3) ...)
;; dir3, f3 can be nil if intersecting only 2 directories.
;; If COMPARISON-FUNC is given, use it. Otherwise, use string=
;; DIFF-VAR contains the name of the variable in which to return the
;; difference list (which represents the differences among the contents of
;; directories). The diff list is of the form:
;;	((dir1 dir2 dir3) (file . num) (file . num)...)
;; where num encodes the set of dirs where the file is found:
;; 2 - only dir1; 3 - only dir2; 5 - only dir3; 6 - dir1&2; 10 - dir1&3; etc.
(defun ediff-intersect-directories (jobname
				    diff-var regexp dir1 dir2
				    &optional
				    dir3 merge-autostore-dir comparison-func)
  (setq comparison-func (or comparison-func 'string=))
  (let (lis1 lis2 lis3 common auxdir1 auxdir2 auxdir3 difflist)

    (setq auxdir1	(file-name-as-directory dir1)
	  lis1		(directory-files auxdir1 nil regexp)
	  lis1 		(delete "."  lis1)
	  lis1 		(delete ".." lis1)
	  lis1 		(mapcar 
			 (function 
			  (lambda (elt)
				  (ediff-add-slash-if-directory auxdir1 elt)))
			 lis1)
	  auxdir2	(file-name-as-directory dir2)
	  lis2		(mapcar 
			 (function
			  (lambda (elt)
				  (ediff-add-slash-if-directory auxdir2 elt)))
			 (directory-files auxdir2 nil regexp)))

    (if (stringp dir3)
	(setq auxdir3	(file-name-as-directory dir3)
	      lis3	(mapcar 
			 (function
			  (lambda (elt)
				  (ediff-add-slash-if-directory auxdir3 elt)))
			 (directory-files auxdir3 nil regexp))))

    (if (stringp merge-autostore-dir)
	(setq merge-autostore-dir
	      (file-name-as-directory merge-autostore-dir)))
    (setq common (ediff-intersection lis1 lis2 comparison-func))

    ;; In merge with ancestor jobs, we don't intersect with lis3.
    ;; If there is no ancestor, we'll offer to merge without the ancestor.
    ;; So, we intersect with lis3 only when we are doing 3-way file comparison
    (if (and lis3 (ediff-comparison-metajob3 jobname))
	(setq common (ediff-intersection common lis3 comparison-func)))

    ;; copying is needed because sort sorts via side effects
    (setq common (sort (ediff-copy-list common) 'string-lessp))

    ;; compute difference list
    (setq difflist (ediff-set-difference
		    (ediff-union (ediff-union lis1 lis2 comparison-func)
				 lis3
				 comparison-func)
		    common
		    comparison-func)
	  difflist (delete "."  difflist)
	  ;; copying is needed because sort sorts via side effects
	  difflist (sort (ediff-copy-list (delete ".." difflist))
			 'string-lessp))

    (setq difflist (mapcar (function (lambda (elt) (cons elt 1))) difflist))

    ;; check for files belonging to lis1/2/3
    (mapcar (function (lambda (elt) 
			(if (member (car elt) lis1)
			    (setcdr elt (* (cdr elt) 2)))
			(if (member (car elt) lis2)
			    (setcdr elt (* (cdr elt) 3)))
			(if (member (car elt) lis3)
			    (setcdr elt (* (cdr elt) 5)))
			))
	    difflist)
    (setq difflist (cons (list regexp auxdir1 auxdir2 auxdir3) difflist))
    
    ;; return the difference list back to the calling function
    (set diff-var difflist)

    ;; return result
    (cons (list regexp auxdir1 auxdir2 auxdir3 merge-autostore-dir)
	  (mapcar
	   (function
	    (lambda (elt) 
	      (list (concat auxdir1 elt)
		    (concat auxdir2 elt)
		    (if lis3
			(progn
			  ;; The following is done because:
			  ;;   In merging with ancestor, we don't intersect
			  ;;   with lis3. So, it is possible that elt is a
			  ;;   file in auxdir1/2 but a directory in auxdir3
			  ;;   Or elt may not exist in auxdir3 at all.
			  ;;   In the first case, we add a slash at the end.
			  ;;   In the second case, we insert nil.
			  (setq elt (ediff-add-slash-if-directory auxdir3 elt))
			  (if (file-exists-p (concat auxdir3 elt))
			      (concat auxdir3 elt)))))))
	   common))
    ))

;; find directory files that are under revision.  Include subdirectories, since
;; we may visit them recursively.  DIR1 is the directory to inspect.
;; MERGE-AUTOSTORE-DIR is the directory where to auto-store the results of
;; merges. Can be nil.
(defun ediff-get-directory-files-under-revision (jobname
						 regexp dir1
						 &optional merge-autostore-dir)
  (let (lis1 elt common auxdir1)
    (setq auxdir1 (file-name-as-directory dir1)
	  lis1	  (directory-files auxdir1 nil regexp))

    (if (stringp merge-autostore-dir)
	(setq merge-autostore-dir
	      (file-name-as-directory merge-autostore-dir)))

    (while lis1
      (setq elt  (car lis1)
	    lis1 (cdr lis1))
      ;; take files under revision control
      (cond ((file-directory-p (concat auxdir1 elt))
	     (setq common
		   (cons (ediff-add-slash-if-directory auxdir1 elt) common)))
	    ((file-exists-p (concat auxdir1 elt ",v"))
	     (setq common (cons elt common)))
	    ((file-exists-p (concat auxdir1 "RCS/" elt ",v"))
	     (setq common (cons elt common)))
	    ) ; cond
      ) ; while

    (setq common (delete "./"  common)
	  common (delete "../" common)
	  common (delete "RCS" common))

    ;; copying is needed because sort sorts via side effects
    (setq common (sort (ediff-copy-list common) 'string-lessp))

    ;; return result
    (cons (list regexp auxdir1 nil nil merge-autostore-dir)
	  (mapcar (function (lambda (elt) 
			      (list (concat auxdir1 elt)
				    nil nil)))
		  common))
    ))
      

;; If file groups selected by patterns will ever be implemented, this
;; comparison function might become useful.
;;;; uses external variables PAT1 PAT2 to compare str1/2
;;;; patterns must be of the form ???*???? where ??? are strings of chars
;;;; containing no *.
;;(defun ediff-pattern= (str1 str2)
;;  (let (pos11 pos12 pos21 pos22 len1 len2)
;;    (setq pos11 0
;;	  len  (length epat1)
;;	  pos12 len)
;;    (while (and (< pos11 len) (not (= (aref epat1 pos11) ?*)))
;;      (setq pos11 (1+ pos11)))
;;    (while (and (> pos12 0) (not (= (aref epat1 (1- pos12)) ?*)))
;;      (setq pos12 (1- pos12)))
;;
;;    (setq pos21 0
;;	  len  (length epat2)
;;	  pos22 len)
;;    (while (and (< pos21 len) (not (= (aref epat2 pos21) ?*)))
;;      (setq pos21 (1+ pos21)))
;;    (while (and (> pos22 0) (not (= (aref epat2 (1- pos22)) ?*)))
;;      (setq pos22 (1- pos22)))
;;
;;    (if (and (> (length str1) pos12) (>= pos12 pos11) (> pos11 -1)
;;	     (> (length str2) pos22) (>= pos22 pos21) (> pos21 -1))
;;	(string= (substring str1 pos11 pos12)
;;		 (substring str2 pos21 pos22)))
;;    ))


;; Prepare meta-buffer in accordance with the argument-function and
;; redraw-function. Must return the created  meta-buffer.
(defun ediff-prepare-meta-buffer (action-func meta-list
				  meta-buffer-name redraw-function
				  jobname &optional startup-hooks)
  (let* ((meta-buffer-name 
	  (ediff-unique-buffer-name meta-buffer-name "*"))
	 (meta-buffer (get-buffer-create meta-buffer-name)))
    (ediff-with-current-buffer meta-buffer

      ;; comes first
      (ediff-meta-mode)

      (setq ediff-meta-action-function action-func
	    ediff-meta-redraw-function redraw-function
	    ediff-metajob-name jobname
	    ediff-meta-buffer meta-buffer)

      ;; comes after ediff-meta-action-function is set
      (ediff-setup-meta-map)
      
      (if (eq ediff-metajob-name 'ediff-registry)
	  (progn
	    (setq ediff-registry-buffer meta-buffer
		  ediff-meta-list meta-list)
	    ;; this func is used only from registry buffer, not from other
	    ;; meta-buffs.
	    (define-key
	      ediff-meta-buffer-map "M" 'ediff-show-meta-buff-from-registry))
	;; Initialize the meta list -- don't do this for registry.
	;;
	;; We prepend '(nil nil) to all elts of meta-list, except the first.
	;; The first nil will later be replaced by the session buffer. The
	;; second is reserved for session status.
	;;
	;; (car ediff-meta-list) gets cons'ed with the session group buffer.
	;; Also, session objects A/B/C are turned into lists of the form
	;; (obj eq-indicator). Eq-indicator is either nil or =. Initialized to
	;; nil. If later it is discovered that this file is = to some other
	;; file in the same session, eq-indicator is changed to `='.
	;; For now, the eq-indicator is used only for 2 and 3-file jobs.
	(setq ediff-meta-list
	      (cons (cons meta-buffer (car meta-list))
		    (mapcar
		     (function
		      (lambda (elt)
			(cons nil
			      (cons nil
				    ;; convert each obj to (obj nil),
				    ;; where nil is the initial value
				    ;; for eq-indicator -- see above
				    (mapcar
				     (function (lambda (obj) (list obj nil)))
				     elt)))))
		     (cdr meta-list)))))
	
      (or (eq meta-buffer ediff-registry-buffer)
	  (setq ediff-session-registry
		(cons meta-buffer ediff-session-registry)))
	
      ;; redraw-function uses ediff-meta-list
      (funcall redraw-function ediff-meta-list)
      
      ;; set read-only/non-modified
      (setq buffer-read-only t)
      (set-buffer-modified-p nil)

      (run-hooks 'startup-hooks)

      ;; Arrange to show directory contents differences
      ;; Must be after run startup-hooks, since ediff-dir-difference-list is
      ;; set inside these hooks
      (if (eq action-func 'ediff-filegroup-action)
	  (progn
	    ;; put meta buffer in (car ediff-dir-difference-list)
	    (setq ediff-dir-difference-list
		  (cons (cons meta-buffer (car ediff-dir-difference-list))
			(cdr ediff-dir-difference-list)))

	    (or (ediff-one-filegroup-metajob jobname)
		(ediff-draw-dir-diffs ediff-dir-difference-list))
	    (define-key 
	      ediff-meta-buffer-map "h" 'ediff-mark-for-hiding-at-pos)
	    (define-key ediff-meta-buffer-map "x" 'ediff-hide-marked-sessions)
	    (define-key 
	      ediff-meta-buffer-map "m" 'ediff-mark-for-operation-at-pos)
	    (define-key ediff-meta-buffer-map "u" nil)
	    (define-key
	      ediff-meta-buffer-map "um" 'ediff-unmark-all-for-operation)
	    (define-key 
	      ediff-meta-buffer-map "uh" 'ediff-unmark-all-for-hiding)
	    (cond ((ediff-collect-diffs-metajob jobname)
		   (define-key
		     ediff-meta-buffer-map "P" 'ediff-collect-custom-diffs))
		  ((ediff-patch-metajob jobname)
		   (define-key
		     ediff-meta-buffer-map "P" 'ediff-meta-show-patch)))
	    (define-key ediff-meta-buffer-map "^" 'ediff-up-meta-hierarchy)
	    (define-key ediff-meta-buffer-map "D" 'ediff-show-dir-diffs)))

      (if (eq ediff-metajob-name 'ediff-registry)
	  (run-hooks 'ediff-registry-setup-hook)
	(run-hooks 'ediff-session-group-setup-hook))
      ) ; eval in meta-buffer
    meta-buffer))

;; Insert the activity marker for session SESSION in the meta buffer at point
;; The activity marker is either SPC (untouched session), or + (active session,
;; i.e., ediff is currently run in it), or - (finished session, i.e., we've ran
;; ediff in it and then exited)
(defun ediff-insert-session-activity-marker-in-meta-buffer (session)
  (insert
   (cond ((ediff-get-session-activity-marker session))
	 ;; virgin session
	 (t " "))))

;; Insert session status at point. Status is either ?H (marked for hiding), or
;; ?I (hidden or invalid), or ?* (meaning marked for an operation; currently,
;; such op can only be checking for equality)), or SPC (meaning neither marked
;; nor invalid) 
(defun ediff-insert-session-status-in-meta-buffer (session)
  (insert
   (cond ((ediff-get-session-status session)) ; session has status: ?H, ?I, ?*
	 ;; normal session, no marks or hidings
	 (t " "))))

;; If NEW-MARKER is non-nil, use it to substitute the current activity marker
;; in the meta buffer. If nil, use SPC
(defun ediff-replace-session-activity-marker-in-meta-buffer (point new-marker)
  (let* ((overl (ediff-get-meta-overlay-at-pos point))
	 (session-info (ediff-overlay-get overl 'ediff-meta-info))
	 (activity-marker (ediff-get-session-activity-marker session-info))
	 buffer-read-only)
    (or new-marker activity-marker (setq new-marker ?\ ))
    (goto-char (ediff-overlay-start overl))
    (if (eq (char-after (point)) new-marker)
	() ; if marker shown in buffer is the same as new-marker, do nothing
      (insert new-marker)
      (delete-char 1)
      (set-buffer-modified-p nil))))

;; If NEW-STATUS is non-nil, use it to substitute the current status marker in
;; the meta buffer. If nil, use SPC
(defun ediff-replace-session-status-in-meta-buffer (point new-status)
  (let* ((overl (ediff-get-meta-overlay-at-pos point))
	 (session-info (ediff-overlay-get overl 'ediff-meta-info))
	 (status (ediff-get-session-status session-info))
	 buffer-read-only)
    (setq new-status (or new-status status ?\ ))
    (goto-char (ediff-overlay-start overl))
    (forward-char 1) ; status is the second char in session record
    (if (eq (char-after (point)) new-status)
	() ; if marker shown in buffer is the same as new-marker, do nothing
      (insert new-status)
      (delete-char 1)
      (set-buffer-modified-p nil))))

;; insert all file info in meta buffer for a given session
(defun ediff-insert-session-info-in-meta-buffer (session-info sessionNum)
  (let ((f1 (ediff-get-session-objA session-info))
	(f2 (ediff-get-session-objB session-info))
	(f3 (ediff-get-session-objC session-info))
	(pt (point))
	(hidden (eq (ediff-get-session-status session-info) ?I)))
    ;; insert activity marker, i.e., SPC, - or +
    (ediff-insert-session-activity-marker-in-meta-buffer session-info)
    ;; insert session status, i.e., *, H
    (ediff-insert-session-status-in-meta-buffer session-info)
    (insert "  Session " (int-to-string sessionNum) ":\n")
    (ediff-meta-insert-file-info1 f1)
    (ediff-meta-insert-file-info1 f2)
    (ediff-meta-insert-file-info1 f3)
    (ediff-set-meta-overlay pt (point) session-info sessionNum hidden)))


;; this is a setup function for ediff-directories
;; must return meta-buffer
(defun ediff-redraw-directory-group-buffer (meta-list)
  ;; extract directories
  (let ((meta-buf (ediff-get-group-buffer meta-list))
	(empty t)
	(sessionNum 0)
	regexp elt merge-autostore-dir
	point tmp-list buffer-read-only)
    (ediff-with-current-buffer meta-buf
      (setq point (point))
      (erase-buffer)
      ;; delete phony overlays that used to represent sessions before the buff
      ;; was redrawn
      (if ediff-emacs-p
	  (mapcar 'delete-overlay (overlays-in 1 1))
	(map-extents 'delete-extent))
      
      (insert (format ediff-meta-buffer-message
		      (ediff-abbrev-jobname ediff-metajob-name)))

      (setq regexp (ediff-get-group-regexp meta-list)
	    merge-autostore-dir
	    (ediff-get-group-merge-autostore-dir meta-list))
      
      (cond ((ediff-collect-diffs-metajob)
	     (insert
	      "     P:\tcollect custom diffs of all marked sessions\n"))
	    ((ediff-patch-metajob)
	     (insert
	      "     P:\tshow patch appropriately for the context (session or group)\n")))
      (insert
       "     ^:\tshow parent session group\n")
      (or (ediff-one-filegroup-metajob)
	  (insert
	   "     D:\tshow differences among directories\n"
	   "    ==:\tfor each session, show which files are identical\n"
	   "    =h:\tlike ==, but also marks those sessions for hiding\n"
	   "    =m:\tlike ==, but also marks those sessions for operation\n\n"))

      (insert "\n")
      (if (and (stringp regexp) (> (length regexp) 0))
	  (insert
	   (format "*** Filter-through regular expression: %s\n" regexp)))
      (ediff-insert-dirs-in-meta-buffer meta-list)
      (if (and ediff-autostore-merges (ediff-merge-metajob)
	       (stringp merge-autostore-dir))
	  (insert (format
		   "\nMerge results are automatically stored in:\n\t%s\n"
		   merge-autostore-dir)))
      (insert "\n
        Size   Last modified           Name
    ----------------------------------------------

")
      
      ;; discard info on directories and regexp
      (setq meta-list (cdr meta-list)
	    tmp-list meta-list)
      (while (and tmp-list empty)
	(if (and (car tmp-list)
		 (not (eq (ediff-get-session-status (car tmp-list)) ?I)))
	    (setq empty nil))
	(setq tmp-list (cdr tmp-list)))

      (if empty
	  (insert
	   "     ******   ******   This session group has no members\n"))
      
      ;; now organize file names like this:
      ;;     use-mark sizeA dateA  sizeB dateB  filename
      ;; make sure directories are displayed with a trailing slash.
      (while meta-list
	(setq elt (car meta-list)
	      meta-list (cdr meta-list)
	      sessionNum (1+ sessionNum))
	(if (eq (ediff-get-session-status elt) ?I)
	    ()
	  (ediff-insert-session-info-in-meta-buffer elt sessionNum)))
      (set-buffer-modified-p nil)
      (goto-char point)
      meta-buf)))

(defun ediff-update-markers-in-dir-meta-buffer (meta-list)
  (let ((meta-buf (ediff-get-group-buffer meta-list))
	session-info point overl buffer-read-only)
    (ediff-with-current-buffer meta-buf
      (setq point (point))
      (goto-char (point-min))
      (ediff-next-meta-item1)
      (while (not (bobp))
	(setq session-info (ediff-get-meta-info meta-buf (point) 'no-error)
	      overl (ediff-get-meta-overlay-at-pos (point)))
	(if session-info
	    (progn
	      (cond ((eq (ediff-get-session-status session-info) ?I)
		     ;; Do hiding
		     (if overl (ediff-overlay-put overl 'invisible t)))
		    ((and (eq (ediff-get-session-status session-info) ?H)
			  overl (ediff-overlay-get overl 'invisible))
		     ;; Do unhiding
		     (ediff-overlay-put overl 'invisible nil))
		    (t (ediff-replace-session-activity-marker-in-meta-buffer
			(point)
			(ediff-get-session-activity-marker session-info))
		       (ediff-replace-session-status-in-meta-buffer
			(point)
			(ediff-get-session-status session-info))))))
	(ediff-next-meta-item1) ; advance to the next item
	) ; end while
      (set-buffer-modified-p nil)
      (goto-char point))
    meta-buf))

(defun ediff-update-session-marker-in-dir-meta-buffer (session-num)
  (let (buffer-meta-overlays session-info overl buffer-read-only)
    (setq overl
	  (if ediff-xemacs-p
	      (map-extents
	       (function
		(lambda (ext maparg)
		  (if (and
		       (ediff-overlay-get ext 'ediff-meta-info)
		       (eq (ediff-overlay-get ext 'ediff-meta-session-number)
			   session-num))
		      ext))))
	    ;; Emacs doesn't have map-extents, so try harder
	    ;; Splice overlay lists to get all buffer overlays
	    (setq buffer-meta-overlays (overlay-lists)
		  buffer-meta-overlays (append (car buffer-meta-overlays)
					       (cdr buffer-meta-overlays)))
	    (car
	     (delq nil
		   (mapcar
		    (function
		     (lambda (overl)
		       (if (and
			    (ediff-overlay-get overl 'ediff-meta-info)
			    (eq (ediff-overlay-get
				 overl 'ediff-meta-session-number)
				session-num))
			   overl)))
		    buffer-meta-overlays)))))
    (or overl
	(error
	 "Bug in ediff-update-session-marker-in-dir-meta-buffer: no overlay with given number %S"
	 session-num))
    (setq session-info (ediff-overlay-get overl 'ediff-meta-info))
    (goto-char (ediff-overlay-start overl))
    (ediff-replace-session-activity-marker-in-meta-buffer
     (point)
     (ediff-get-session-activity-marker session-info))
    (ediff-replace-session-status-in-meta-buffer
     (point)
     (ediff-get-session-status session-info)))
  (ediff-next-meta-item1))



;; Check if this is a problematic session.
;; Return nil if not. Otherwise, return symbol representing the problem
;; At present, problematic sessions occur only in -with-ancestor comparisons
;; when the ancestor is a directory rather than a file, or when there is no
;; suitable ancestor file in the ancestor directory
(defun ediff-problematic-session-p (session)
  (let ((f1 (ediff-get-session-objA-name session))
	(f2 (ediff-get-session-objB-name session))
	(f3 (ediff-get-session-objC-name session)))
    (cond ((and (stringp f1) (not (file-directory-p f1))
		(stringp f2) (not (file-directory-p f2))
		;; either invalid file name or a directory
		(or (not (stringp f3)) (file-directory-p f3))
		(ediff-ancestor-metajob))
	   ;; more may be added later
	   'ancestor-is-dir)
	  (t nil))))

(defun ediff-meta-insert-file-info1 (fileinfo)
  (let ((fname (car fileinfo))
	(feq (ediff-get-file-eqstatus fileinfo))
	(max-filename-width (if ediff-meta-truncate-filenames
				(- (window-width) 41)
			      500))
	file-modtime file-size)
    (cond ((not (stringp fname)) (setq file-size -2)) ; file doesn't exits
	  ((not (ediff-file-remote-p fname))
	   (if (file-exists-p fname)
	       ;; set real size and modtime
	       (setq file-size (ediff-file-size fname)
		     file-modtime (ediff-file-modtime fname))
	     (setq file-size -2)))  ; file doesn't exist
	  ( t (setq file-size -1))) ; remote file
    (if (stringp fname)
	(insert
	 (format
	  "%s  %s   %-20s   %s\n"
	  (if feq "=" " ") ; equality indicator
	  (format "%10s" (cond ((= file-size -1) "--")
			       ((< file-size -1) "--")
			       (t file-size)))
	  (cond ((= file-size -1) "*remote file*")
		((< file-size -1) "*file doesn't exist*")
		(t (ediff-format-date (decode-time file-modtime))))

	  ;; dir names in meta lists have training slashes, so we just
	  ;; abbreviate the file name, if file exists
	  (if (and (not (stringp fname)) (< file-size -1))
	      "-------"		; file doesn't exist
	    (ediff-truncate-string-left
	     (ediff-abbreviate-file-name fname)
	     max-filename-width)))))))

(defconst ediff-months '((1 . "Jan") (2 . "Feb") (3 . "Mar") (4 . "Apr")
			(5 . "May") (6 . "Jun") (7 . "Jul") (8 . "Aug")
			(9 . "Sep") (10 . "Oct") (11 . "Nov") (12 . "Dec"))
  "Months' associative array.")

;; returns 2char string
(defsubst ediff-fill-leading-zero (num)
  (if (< num 10)
      (format "0%d" num)
    (number-to-string num)))

;; TIME is like the output of decode-time
(defun ediff-format-date (time)
  (format "%s %2d %4d %s:%s:%s"
	  (cdr (assoc (nth 4 time) ediff-months)) ; month
	  (nth 3 time) ; day
	  (nth 5 time) ; year
	  (ediff-fill-leading-zero (nth 2 time)) ; hour
	  (ediff-fill-leading-zero (nth 1 time)) ; min
	  (ediff-fill-leading-zero (nth 0 time)) ; sec
	  ))

;; Draw the directories
(defun ediff-insert-dirs-in-meta-buffer (meta-list)
  (let* ((dir1 (ediff-abbreviate-file-name (ediff-get-group-objA meta-list)))
	 (dir2 (ediff-get-group-objB meta-list))
	 (dir2 (if (stringp dir2) (ediff-abbreviate-file-name dir2)))
	 (dir3 (ediff-get-group-objC meta-list))
	 (dir3 (if (stringp dir3) (ediff-abbreviate-file-name dir3))))
    (insert "*** Directory A: " dir1 "\n")
    (if dir2 (insert "*** Directory B: " dir2 "\n"))
    (if dir3 (insert "*** Directory C: " dir3 "\n"))
    (insert "\n")))

(defun ediff-draw-dir-diffs (diff-list)
  (if (null diff-list) (error "Lost difference info on these directories"))
  (let* ((buf-name (ediff-unique-buffer-name
		    "*Ediff File Group Differences" "*"))
	 (regexp (ediff-get-group-regexp diff-list))
	 (dir1 (ediff-abbreviate-file-name (ediff-get-group-objA diff-list)))
	 (dir2 (ediff-abbreviate-file-name (ediff-get-group-objB diff-list)))
	 (dir3 (ediff-get-group-objC diff-list))
	 (dir3 (if (stringp dir3) (ediff-abbreviate-file-name dir3)))
	 (meta-buf (ediff-get-group-buffer diff-list))
	 (underline (make-string 26 ?-))
	 file code 
	 buffer-read-only)
    ;; skip the directory part
    (setq diff-list (cdr diff-list))
    (setq ediff-dir-diffs-buffer (get-buffer-create buf-name))
    (ediff-with-current-buffer ediff-dir-diffs-buffer
      (use-local-map ediff-dir-diffs-buffer-map)
      (erase-buffer)
      (setq ediff-meta-buffer meta-buf)
      (insert "\t\t*** Directory Differences ***\n")
      (insert "
Useful commands:
     `q': hide this buffer
   n,SPC: next line
   p,DEL: previous line\n\n")

      (if (and (stringp regexp) (> (length regexp) 0))
	  (insert
	   (format "\n*** Filter-through regular expression: %s\n" regexp)))
      (insert "\n")
      (insert (format "\n%-27s%-26s"
		      (ediff-truncate-string-left
		       (ediff-abbreviate-file-name
			(file-name-as-directory dir1))
		       25)
		      (ediff-truncate-string-left
		       (ediff-abbreviate-file-name
			(file-name-as-directory dir2))
		       25)))
      (if dir3
	  (insert (format " %-25s\n"
			  (ediff-truncate-string-left
			   (ediff-abbreviate-file-name
			    (file-name-as-directory dir3))
			   25)))
	(insert "\n"))
      (insert (format "%s%s" underline underline))
      (if (stringp dir3)
	  (insert (format "%s\n\n" underline))
	(insert "\n\n"))

      (if (null diff-list)
	  (insert "\n\t***  No differences  ***\n"))

      (while diff-list
	(setq file (car (car diff-list))
	      code (cdr (car diff-list))
	      diff-list (cdr diff-list))
	(if (= (mod code 2) 0) ; dir1
	    (insert (format "%-27s"
			    (ediff-truncate-string-left
			     (ediff-abbreviate-file-name
			      (if (file-directory-p (concat dir1 file))
				  (file-name-as-directory file)
				file))
			     24)))
	  (insert (format "%-27s" "---")))
	(if (= (mod code 3) 0) ; dir2
	    (insert (format "%-26s"
			    (ediff-truncate-string-left
			     (ediff-abbreviate-file-name
			      (if (file-directory-p (concat dir2 file))
				  (file-name-as-directory file)
				file))
			     24)))
	  (insert (format "%-26s" "---")))
	(if (stringp dir3)
	    (if (= (mod code 5) 0) ; dir3
		(insert (format " %-25s" 
				(ediff-truncate-string-left
				 (ediff-abbreviate-file-name
				  (if (file-directory-p (concat dir3 file))
				      (file-name-as-directory file)
				    file))
				 24)))
	      (insert (format " %-25s" "---"))))
	(insert "\n"))
      (setq buffer-read-only t)
      (set-buffer-modified-p nil)) ; eval in diff buffer
  ))

(defun ediff-bury-dir-diffs-buffer ()
  "Bury the directory difference buffer. Display the meta buffer instead."
  (interactive)
  (let ((buf ediff-meta-buffer)
	wind)
    (bury-buffer)
    (if (setq wind (ediff-get-visible-buffer-window buf))
	(select-window wind)
      (set-window-buffer (selected-window) buf))))

;; executes in dir session group buffer
;; show buffer differences
(defun ediff-show-dir-diffs ()
  "Display differences among the directories involved in session group."
  (interactive)
  (if (ediff-one-filegroup-metajob)
      (error "This command is inapplicable in the present context"))
  (or (ediff-buffer-live-p ediff-dir-diffs-buffer)
      (ediff-draw-dir-diffs ediff-dir-difference-list))
  (let ((buf ediff-dir-diffs-buffer))
    (other-window 1)
    (set-window-buffer (selected-window) buf)
    (goto-char (point-min))))

(defun ediff-up-meta-hierarchy ()
  "Go to the parent session group buffer."
  (interactive)
  (if (ediff-buffer-live-p ediff-parent-meta-buffer)
      (ediff-show-meta-buffer
       ediff-parent-meta-buffer ediff-meta-session-number)
    (error "This session group has no parent")))
  

;; argument is ignored
(defun ediff-redraw-registry-buffer (&optional ignore)
  (ediff-with-current-buffer ediff-registry-buffer
    (let ((point (point))
	  elt bufAname bufBname bufCname cur-diff total-diffs pt
	  job-name meta-list registry-list buffer-read-only)
      (erase-buffer)
      ;; delete phony overlays that used to represent sessions before the buff
      ;; was redrawn
      (if ediff-emacs-p
	  (mapcar 'delete-overlay (overlays-in 1 1))
	(map-extents 'delete-extent))

      (insert "This is a registry of all active Ediff sessions.

Useful commands:
     button2, `v', RET over a session record:  switch to that session
     M over a session record:  display the associated session group
     R in any Ediff session:   display session registry
     n,SPC: next session
     p,DEL: previous session
         E: browse Ediff on-line manual
         q: bury registry


\t\tActive Ediff Sessions:
\t\t----------------------

")
      ;; purge registry list from dead buffers
      (mapcar (function (lambda (elt)
			  (if (not (ediff-buffer-live-p elt))
			      (setq ediff-session-registry
				    (delq elt ediff-session-registry)))))
	      ediff-session-registry)

      (if (null ediff-session-registry)
	  (insert "       ******* No active Ediff sessions *******\n"))

      (setq registry-list ediff-session-registry)
      (while registry-list
	(setq elt (car registry-list)
	      registry-list (cdr registry-list))
	
	(if (ediff-buffer-live-p elt)
	    (if (ediff-with-current-buffer elt
		  (setq job-name ediff-metajob-name
			meta-list ediff-meta-list)
		  (and ediff-metajob-name
		       (not (eq ediff-metajob-name 'ediff-registry))))
		(progn
		  (setq pt (point))
		  (insert (format "  *group*\t%s: %s\n"
				  (buffer-name elt)
				  (ediff-abbrev-jobname job-name)))
		  (insert (format "\t\t   %s   %s   %s\n"
				  (ediff-abbreviate-file-name
				   (ediff-get-group-objA meta-list))
				  (ediff-abbreviate-file-name
				   (if (stringp
					(ediff-get-group-objB meta-list))
				       (ediff-get-group-objB meta-list)
				       ""))
				  (ediff-abbreviate-file-name
				   (if (stringp
					(ediff-get-group-objC meta-list))
				       (ediff-get-group-objC meta-list)
				       ""))))
		  (ediff-set-meta-overlay pt (point) elt))
	      (progn
		(ediff-with-current-buffer elt
		  (setq bufAname (if (ediff-buffer-live-p ediff-buffer-A)
				     (buffer-name ediff-buffer-A)
				   "!!!killed buffer!!!")
			bufBname (if (ediff-buffer-live-p ediff-buffer-B)
				     (buffer-name ediff-buffer-B)
				   "!!!killed buffer!!!")
			bufCname (cond ((not (ediff-3way-job))
					"")
				       ((ediff-buffer-live-p ediff-buffer-C)
					(buffer-name ediff-buffer-C))
				       (t "!!!killed buffer!!!")))
		  (setq total-diffs (format "%-4d" ediff-number-of-differences)
			cur-diff
			(cond ((= ediff-current-difference -1) "   _")
			      ((= ediff-current-difference
				  ediff-number-of-differences)
			       "   $")
			      (t (format
				  "%4d" (1+ ediff-current-difference))))
			job-name ediff-job-name))
		;; back in the meta buf
		(setq pt (point))
		(insert cur-diff "/" total-diffs "\t"
			(buffer-name elt)
			(format ": %s" 	(ediff-abbrev-jobname job-name)))
		(insert
		 "\n\t\t   " bufAname "   " bufBname "   " bufCname "\n")
		(ediff-set-meta-overlay pt (point) elt))))
	) ; while
      (set-buffer-modified-p nil)
      (goto-char point)
      )))

;; Sets overlay around a meta record with 'ediff-meta-info property PROP
;; If optional SESSION-NUMBER, make it a property of the overlay,
;; ediff-meta-session-number
(defun ediff-set-meta-overlay (b e prop &optional session-number hidden)
  (let (overl)
    (setq overl (ediff-make-overlay b e))
    (if ediff-emacs-p
	(ediff-overlay-put overl 'mouse-face 'highlight)
      (ediff-overlay-put overl 'highlight t))
    (ediff-overlay-put overl 'ediff-meta-info prop)
    (ediff-overlay-put overl 'invisible hidden)
    (if (numberp session-number)
	(ediff-overlay-put overl 'ediff-meta-session-number session-number))))

(defun ediff-mark-for-hiding-at-pos (unmark)
  "Mark session for hiding. With prefix arg, unmark."
  (interactive "P")
  (let* ((pos (ediff-event-point last-command-event))
	 (meta-buf (ediff-event-buffer last-command-event))
	 ;; ediff-get-meta-info gives error if meta-buf or pos are invalid
	 (info (ediff-get-meta-info meta-buf pos))
	 (session-number (ediff-get-session-number-at-pos pos)))
    (ediff-mark-session-for-hiding info unmark)
    (ediff-next-meta-item 1)
    (save-excursion
      (ediff-update-meta-buffer meta-buf nil session-number))
    ))

;; Returns whether session was marked or unmarked
(defun ediff-mark-session-for-hiding (info unmark)
  (let ((session-buf (ediff-get-session-buffer info))
	ignore)
    (cond ((eq unmark 'mark) (setq unmark nil))
	  ((eq (ediff-get-session-status info) ?H) (setq unmark t))
	  (unmark  ; says unmark, but the marker is different from H
	   (setq ignore t)))
    (cond (ignore)
	  (unmark (ediff-set-session-status info nil))
;;;   (if (ediff-buffer-live-p session-buf)
;;;	  (error "Can't hide active session, %s" (buffer-name session-buf)))
	  (t (ediff-set-session-status info ?H))))
  unmark)
  

(defun ediff-mark-for-operation-at-pos (unmark)
  "Mark session for a group operation. With prefix arg, unmark."
  (interactive "P")
  (let* ((pos (ediff-event-point last-command-event))
	 (meta-buf (ediff-event-buffer last-command-event))
	 ;; ediff-get-meta-info gives error if meta-buf or pos are invalid
	 (info (ediff-get-meta-info meta-buf pos))
	 (session-number (ediff-get-session-number-at-pos pos)))
    (ediff-mark-session-for-operation info unmark)
    (ediff-next-meta-item 1)
    (save-excursion
      (ediff-update-meta-buffer meta-buf nil session-number))
    ))


;; returns whether session was unmarked.
;; remember: this is a toggle op
(defun ediff-mark-session-for-operation (info unmark)
  (let (ignore)
    (cond ((eq unmark 'mark) (setq unmark nil))
	  ((eq (ediff-get-session-status info) ?*) (setq unmark t))
	  (unmark  ; says unmark, but the marker is different from *
	   (setq ignore t)))
    (cond (ignore)
	  (unmark (ediff-set-session-status info nil))
	  (t (ediff-set-session-status info ?*))))
  unmark)


(defun ediff-hide-marked-sessions (unhide)
  "Hide marked sessions. With prefix arg, unhide."
  (interactive "P")
  (let ((grp-buf (ediff-get-group-buffer ediff-meta-list))
	(meta-list (cdr ediff-meta-list))
	(from (if unhide ?I ?H))
	(to (if unhide ?H ?I))
	(numMarked 0)
	active-sessions-exist session-buf elt)
    (while meta-list
      (setq elt (car meta-list)
	    meta-list (cdr meta-list)
	    session-buf (ediff-get-session-buffer elt))

      (if (eq (ediff-get-session-status elt) from)
	  (progn
	    (setq numMarked (1+ numMarked))
	    (if (and (eq to ?I) (buffer-live-p session-buf))
		;; shouldn't hide active sessions
		(setq active-sessions-exist t)
	      (ediff-set-session-status elt to)))))
    (if (> numMarked 0)
	(ediff-update-meta-buffer grp-buf)
      (beep)
      (if unhide
	  (message "Nothing to reveal...")
	(message "Nothing to hide...")))
    (if active-sessions-exist
	(message "Note: Ediff didn't hide active sessions!"))
    ))

;; Apply OPERATION to marked sessions. Operation expects one argument of type
;; meta-list member (not the first one), i.e., a regular session description.
;; Returns number of marked sessions on which operation was performed
(defun ediff-operate-on-marked-sessions (operation)
  (let ((grp-buf (ediff-get-group-buffer ediff-meta-list))
	(meta-list (cdr ediff-meta-list))
	(marksym ?*)
	(numMarked 0)
	(sessionNum 0)
	(diff-buffer ediff-meta-diff-buffer)
	session-buf elt)
    (while meta-list
      (setq elt (car meta-list)
	    meta-list (cdr meta-list)
	    sessionNum (1+ sessionNum))
      (cond ((eq (ediff-get-session-status elt) marksym)
	     (save-excursion
	       (setq numMarked (1+ numMarked))
	       (funcall operation elt sessionNum)))
	    ((and  (ediff-meta-session-p elt) 
		   (ediff-buffer-live-p 
		    (setq session-buf (ediff-get-session-buffer elt))))
	     (setq numMarked
		   (+ numMarked 
		      (ediff-with-current-buffer session-buf
			;; pass meta-diff along
			(setq ediff-meta-diff-buffer diff-buffer)
			;; collect diffs in child group
			(ediff-operate-on-marked-sessions operation)))))))
    (ediff-update-meta-buffer grp-buf 'must-redraw) ; just in case
    numMarked
    ))

(defun ediff-append-custom-diff (session sessionNum)
  (or (ediff-collect-diffs-metajob)
      (error "Hmm, I'd hate to do it to you ..."))
  (let ((session-buf (ediff-get-session-buffer session))
	(meta-diff-buff ediff-meta-diff-buffer)
	(metajob ediff-metajob-name)
	tmp-buf custom-diff-buf)
    (if (ediff-buffer-live-p session-buf)
	(ediff-with-current-buffer session-buf
	  (if (eq ediff-control-buffer session-buf) ; individual session
	      (progn
		(ediff-compute-custom-diffs-maybe)
		(setq custom-diff-buf ediff-custom-diff-buffer)))))

    (or (ediff-buffer-live-p meta-diff-buff)
	(error "Ediff: something wrong--no multiple diffs buffer"))

    (cond ((ediff-buffer-live-p custom-diff-buf)
	   (save-excursion
	     (set-buffer meta-diff-buff)
	     (goto-char (point-max))
	     (insert-buffer custom-diff-buf)
	     (insert "\n")))
	  ((memq metajob '(ediff-directories 
			   ediff-merge-directories
			   ediff-merge-directories-with-ancestor))
	   ;; get diffs by calling shell command on ediff-custom-diff-program
	   (save-excursion
	     (set-buffer (setq tmp-buf (get-buffer-create ediff-tmp-buffer)))
	     (erase-buffer)
	     (shell-command
	      (format "%s %s %s %s"
		      ediff-custom-diff-program ediff-custom-diff-options
		      (ediff-get-session-objA-name session)
		      (ediff-get-session-objB-name session))
	      t))
	   (save-excursion
	     (set-buffer meta-diff-buff)
	     (goto-char (point-max))
	     (insert-buffer tmp-buf)
	     (insert "\n")))
	  (t
	   (error "Can't make context diff for Session %d" sessionNum )))
    ))

(defun ediff-collect-custom-diffs ()
  "Collect custom diffs of marked sessions in buffer `*Ediff Multifile Diffs*'.
This operation is defined only for `ediff-directories' and
`ediff-directory-revisions', since its intent is to produce
multifile patches. For `ediff-directory-revisions', we insist that
all marked sessions must be active."
  (interactive)
  (or (ediff-buffer-live-p ediff-meta-diff-buffer)
      (setq ediff-meta-diff-buffer
	    (get-buffer-create
	     (ediff-unique-buffer-name "*Ediff Multifile Diffs" "*"))))
  (ediff-with-current-buffer ediff-meta-diff-buffer
    (erase-buffer))
  (if (> (ediff-operate-on-marked-sessions 'ediff-append-custom-diff) 0)
      ;; did something
      (display-buffer ediff-meta-diff-buffer 'not-this-window)
    (beep)
    (message "No marked sessions found")))

(defun ediff-meta-show-patch ()
  "Show the multi-file patch associated with this group session."
  (interactive)
  (let* ((pos (ediff-event-point last-command-event))
	 (meta-buf (ediff-event-buffer last-command-event))
	 (info (ediff-get-meta-info meta-buf pos 'noerror))
	 (patchbuffer ediff-meta-patchbufer))
    (if (ediff-buffer-live-p patchbuffer)
	(ediff-with-current-buffer patchbuffer
	  (save-restriction
	    (if (not info)
		(widen)
	      (narrow-to-region
	       (ediff-get-session-objB-name info)
	       (ediff-get-session-objC-name info)))
	    (set-buffer (get-buffer-create ediff-tmp-buffer))
	    (erase-buffer)
	    (insert-buffer patchbuffer)
	    (display-buffer ediff-tmp-buffer 'not-this-window)
	    ))
      (error "The patch buffer wasn't found"))))

	      
;; This function executes in meta buffer. It knows where event happened.
(defun ediff-filegroup-action ()
  "Execute appropriate action for the selected session."
  (interactive)
  (let* ((pos (ediff-event-point last-command-event))
	 (meta-buf (ediff-event-buffer last-command-event))
	 ;; ediff-get-meta-info gives error if meta-buf or pos are invalid
	 (info (ediff-get-meta-info meta-buf pos))
	 (session-buf (ediff-get-session-buffer info))
	 (session-number (ediff-get-session-number-at-pos pos meta-buf))
	 merge-autostore-dir file1 file2 file3 regexp)

    (setq file1 (ediff-get-session-objA-name info)
	  file2 (ediff-get-session-objB-name info)
	  file3 (ediff-get-session-objC-name info))

    ;; make sure we don't start on hidden sessions
    ;; ?H means marked for hiding. ?I means invalid (hidden).
    (if (memq (ediff-get-session-status info) '(?I))
	(progn
	  (beep)
	  (if (y-or-n-p "This session is marked as hidden, unmark? ")
	      (progn
		(ediff-set-session-status info nil)
		(ediff-update-meta-buffer meta-buf nil session-number))
	    (error "Aborted"))))

    (ediff-with-current-buffer meta-buf
      (setq merge-autostore-dir
	    (ediff-get-group-merge-autostore-dir ediff-meta-list))
      (goto-char pos) ; if the user clicked on session--move point there
      ;; First handle sessions involving directories (which are themselves
      ;; session groups)
      ;; After that handle individual sessions
      (cond ((ediff-meta-session-p info)
	     ;; do ediff/ediff-merge on subdirectories
	     (if (ediff-buffer-live-p session-buf)
		 (ediff-show-meta-buffer session-buf)
	       (setq regexp (read-string "Filter through regular expression: " 
					 nil 'ediff-filtering-regexp-history))
	       (ediff-directories-internal
		file1 file2 file3 regexp
		ediff-session-action-function
		ediff-metajob-name 
		;; make it update car info after startup
		(` (list (lambda () 
			   ;; child session group should know its parent
			   (setq ediff-parent-meta-buffer
				 (quote (, ediff-meta-buffer))
				 ediff-meta-session-number
				 (, session-number))
			   ;; and parent will know its child
			   (setcar (quote (, info)) ediff-meta-buffer)))))))

	    ;; Do ediff-revision on a subdirectory
	    ((and (ediff-one-filegroup-metajob)
		  (ediff-revision-metajob)
		  (file-directory-p file1))
	     (if (ediff-buffer-live-p session-buf)
		 (ediff-show-meta-buffer session-buf)
	       (setq regexp (read-string "Filter through regular expression: " 
					 nil 'ediff-filtering-regexp-history))
	       (ediff-directory-revisions-internal
		file1 regexp
		ediff-session-action-function ediff-metajob-name
		;; make it update car info after startup
		(` (list (lambda () 
			   ;; child session group should know its parent and
			   ;; its number
			   (setq ediff-parent-meta-buffer
				 (quote (, ediff-meta-buffer))
				 ediff-meta-session-number
				 (, session-number))
			   ;; and parent will know its child
			   (setcar (quote (, info)) ediff-meta-buffer)))))))

	    ;; From here on---only individual session handlers

	    ;; handle an individual session with a live control buffer
	    ((ediff-buffer-live-p session-buf)
	     (ediff-with-current-buffer session-buf
	       (setq ediff-mouse-pixel-position (mouse-pixel-position))
	       (ediff-recenter 'no-rehighlight)))

	    ((ediff-problematic-session-p info)
	     (beep)
	     (if (y-or-n-p
		  "This session has no ancestor. Merge without the ancestor? ")
		 (ediff-merge-files
		  file1 file2
		  ;; provide startup hooks 
		  (` (list (lambda () 
			     (setq ediff-meta-buffer (, (current-buffer))
				   ediff-meta-session-number
				   (, session-number))
			     (setq ediff-merge-store-file
				   (, (concat
				       merge-autostore-dir
				       "merge_"
				       (file-name-nondirectory file1))))
			     ;; make ediff-startup pass
			     ;; ediff-control-buffer back to the meta
			     ;; level; see below
			     (setcar
			      (quote (, info)) ediff-control-buffer)))))
	       (error "Aborted")))
	    ((ediff-one-filegroup-metajob) 	; needs 1 file arg
	     (funcall ediff-session-action-function
		      file1
		      ;; provide startup hooks 
		      (` (list (lambda () 
				 (setq ediff-meta-buffer (, (current-buffer))
				       ediff-meta-session-number
				       (, session-number))
				 (setq ediff-merge-store-file
				       (, (concat
					   merge-autostore-dir
					   "merge_"
					   (file-name-nondirectory file1))))
				 ;; make ediff-startup pass
				 ;; ediff-control-buffer back to the meta
				 ;; level; see below
				 (setcar
				  (quote (, info)) ediff-control-buffer))))))
	    ((not (ediff-metajob3))      ; need 2 file args
	     (funcall ediff-session-action-function
		      file1 file2
		      ;; provide startup hooks 
		      (` (list (lambda () 
				 (setq ediff-meta-buffer (, (current-buffer))
				       ediff-meta-session-number
				       (, session-number))
				 (setq ediff-merge-store-file
				       (, (concat
					   merge-autostore-dir
					   "merge_"
					   (file-name-nondirectory file1))))
				 ;; make ediff-startup pass
				 ;; ediff-control-buffer back to the meta
				 ;; level; see below
				 (setcar
				  (quote (, info)) ediff-control-buffer))))))
	    ((ediff-metajob3)      ; need 3 file args
	     (funcall ediff-session-action-function
		      file1 file2 file3
		      ;; arrange startup hooks 
		      (` (list (lambda () 
				 (setq ediff-merge-store-file
				       (, (concat
					   merge-autostore-dir
					   "merge_"
					   (file-name-nondirectory file1))))
				 (setq ediff-meta-buffer (, (current-buffer))
				       ediff-meta-session-number
				       (, session-number))
				 ;; this arranges that ediff-startup will pass
				 ;; the value of ediff-control-buffer back to
				 ;; the meta level, to the record in the meta
				 ;; list containing the information about the
				 ;; session associated with that
				 ;; ediff-control-buffer
				 (setcar
				  (quote (, info)) ediff-control-buffer))))))
	    ) ; cond
      ) ; eval in meta-buf
    ))

(defun ediff-registry-action ()
  "Switch to a selected session."
  (interactive)
  (let* ((pos (ediff-event-point last-command-event))
	 (buf (ediff-event-buffer last-command-event))
	 (ctl-buf (ediff-get-meta-info buf pos)))

    (if (ediff-buffer-live-p ctl-buf)
	;; check if this is ediff-control-buffer or ediff-meta-buffer
	(if (ediff-with-current-buffer ctl-buf
	      (eq (key-binding "q") 'ediff-quit-meta-buffer))
	    ;; it's a meta-buffer -- last action should just display it
	    (ediff-show-meta-buffer ctl-buf t)
	  ;; it's a session buffer -- invoke go back to session
	  (ediff-with-current-buffer ctl-buf
	    (setq ediff-mouse-pixel-position (mouse-pixel-position))
	    (ediff-recenter 'no-rehighlight)))
      (beep)
      (message "You've selected a stale session --- try again")
      (ediff-update-registry))
    (ediff-with-current-buffer buf
      (goto-char pos))
    ))


;; If session number is t, means don't update meta buffer
(defun ediff-show-meta-buffer (&optional meta-buf session-number)
  "Show the session group buffer."
  (interactive)
  (let (wind frame silent)
    (if meta-buf (setq silent t))

    (setq meta-buf (or meta-buf ediff-meta-buffer))
    (cond ((not (bufferp meta-buf))
	   (error "This Ediff session is not part of a session group"))
	  ((not (ediff-buffer-live-p meta-buf))
	   (error
	    "Can't find this session's group panel -- session itself is ok")))

    (cond ((numberp session-number)
	   (ediff-update-meta-buffer meta-buf nil session-number))
	  ;; if session-number is t, don't update
	  (session-number)
	  (t (ediff-cleanup-meta-buffer meta-buf)))

    (ediff-with-current-buffer meta-buf
      (save-excursion
	(cond ((setq wind (ediff-get-visible-buffer-window meta-buf))
	       (or silent
		   (message
		    "Already showing the group panel for this session"))
	       (set-window-buffer wind meta-buf)
	       (select-window wind))
	      ((window-live-p (setq wind ediff-window-C)) ;in merge--merge buf
	       (set-window-buffer ediff-window-C meta-buf)
	       (select-window wind))
	      ((window-live-p (setq wind ediff-window-A))
	       (set-window-buffer ediff-window-A meta-buf)
	       (select-window wind))
	      ((window-live-p (setq wind ediff-window-B))
	       (set-window-buffer ediff-window-B meta-buf)
	       (select-window wind))
	      ((and
		(setq wind
		      (ediff-get-visible-buffer-window ediff-registry-buffer))
		(ediff-window-display-p))
	       (select-window wind)
	       (other-window 1)
	       (set-window-buffer (selected-window) meta-buf))
	      (t (ediff-skip-unsuitable-frames 'ok-unsplittable)
		 (set-window-buffer (selected-window) meta-buf)))
	))
    (if (and (ediff-window-display-p)
	     (window-live-p 
	      (setq wind (ediff-get-visible-buffer-window meta-buf))))
	(progn
	  (setq frame (window-frame wind))
	  (raise-frame frame)
	  (ediff-reset-mouse frame)))
    (run-hooks 'ediff-show-session-group-hook)
    ))

(defun ediff-show-current-session-meta-buffer ()
  (interactive)
  (ediff-show-meta-buffer nil ediff-meta-session-number))

(defun ediff-show-meta-buff-from-registry ()
  "Display the session group buffer for a selected session group."
  (interactive)
  (let* ((pos (ediff-event-point last-command-event))
	 (meta-buf (ediff-event-buffer last-command-event))
	 (info (ediff-get-meta-info meta-buf pos))
	 (meta-or-session-buf info))
    (ediff-with-current-buffer meta-or-session-buf
      (ediff-show-meta-buffer nil t))))

;;;###autoload
(defun ediff-show-registry ()
  "Display Ediff's registry."
  (interactive)
  (ediff-update-registry)
  (if (not (ediff-buffer-live-p ediff-registry-buffer))
      (error "No active Ediff sessions or corrupted session registry"))
  (let (wind frame)
    ;; for some reason, point moves in ediff-registry-buffer, so we preserve it
    ;; explicitly
    (ediff-with-current-buffer ediff-registry-buffer
      (save-excursion
	(cond  ((setq wind
		      (ediff-get-visible-buffer-window ediff-registry-buffer))
		(message "Already showing the registry")
		(set-window-buffer wind ediff-registry-buffer)
		(select-window wind))
	       ((window-live-p ediff-window-C)
		(set-window-buffer ediff-window-C ediff-registry-buffer)
		(select-window ediff-window-C))
	       ((window-live-p ediff-window-A)
		(set-window-buffer ediff-window-A ediff-registry-buffer)
		(select-window ediff-window-A))
	       ((window-live-p ediff-window-B)
		(set-window-buffer ediff-window-B ediff-registry-buffer)
		(select-window ediff-window-B))
	       ((and (setq wind
			   (ediff-get-visible-buffer-window ediff-meta-buffer))
		     (ediff-window-display-p))
		(select-window wind)
		(other-window 1)
		(set-window-buffer (selected-window) ediff-registry-buffer))
	       (t (ediff-skip-unsuitable-frames 'ok-unsplittable)
		  (set-window-buffer (selected-window) ediff-registry-buffer)))
	))
    (if (ediff-window-display-p)
	(progn
	  (setq frame 
		(window-frame
		 (ediff-get-visible-buffer-window ediff-registry-buffer)))
	  (raise-frame frame)
	  (ediff-reset-mouse frame)))
    (run-hooks 'ediff-show-registry-hook)
    ))

;;;###autoload
(defalias 'eregistry 'ediff-show-registry)

;; If meta-buf doesn't exist, it is created. In that case, id doesn't have a
;; parent meta-buf
;; Check if META-BUF exists before calling this function
;; Optional MUST-REDRAW, if non-nil, would force redrawal of the whole meta
;; buffer. Otherwise, it will just go over the buffer and update activity marks
;; and session status.
;; SESSION-NUMBER, if specified, says which session caused the update.
(defun ediff-update-meta-buffer (meta-buf &optional must-redraw session-number)
  (if (ediff-buffer-live-p meta-buf)
      (ediff-with-current-buffer meta-buf
	(cond (must-redraw ; completely redraw the meta buffer
	       (funcall ediff-meta-redraw-function ediff-meta-list))
	      ((numberp session-number) ; redraw only for the given session
	       (ediff-update-session-marker-in-dir-meta-buffer session-number))
	      (t ; update only what's changed, but scan the entire meta buffer
	       (ediff-update-markers-in-dir-meta-buffer ediff-meta-list)))
	)))

(defun ediff-update-registry ()
  (ediff-with-current-buffer (current-buffer)
    (if (ediff-buffer-live-p ediff-registry-buffer)
	(ediff-redraw-registry-buffer)
      (ediff-prepare-meta-buffer 
       'ediff-registry-action
       ediff-session-registry
       "*Ediff Registry"
       'ediff-redraw-registry-buffer
       'ediff-registry))
    ))

;; If meta-buf exists, it is redrawn along with parent. 
;; Otherwise, nothing happens.
(defun ediff-cleanup-meta-buffer (meta-buffer)
  (if (ediff-buffer-live-p meta-buffer)
      (ediff-with-current-buffer meta-buffer
	(ediff-update-meta-buffer meta-buffer)
	(if (ediff-buffer-live-p ediff-parent-meta-buffer)
	    (ediff-update-meta-buffer
	     ediff-parent-meta-buffer nil ediff-meta-session-number)))))

;; t if no session is in progress
(defun ediff-safe-to-quit (meta-buffer)
  (if (ediff-buffer-live-p meta-buffer)
      (let ((lis ediff-meta-list)
	    (cont t)
	    buffer-read-only)
	;;(ediff-update-meta-buffer meta-buffer)
	(ediff-with-current-buffer meta-buffer
	  (setq lis (cdr lis)) ; discard the description part of meta-list
	  (while (and cont lis)
	    (if (ediff-buffer-live-p
		 (ediff-get-group-buffer lis)) ; in progress
		(setq cont nil))
	    (setq lis (cdr lis)))
	  cont))))

(defun ediff-quit-meta-buffer ()
  "If the group has no active session, delete the meta buffer.
If no session is in progress, ask to confirm before deleting meta buffer.
Otherwise, bury the meta buffer.
If this is a session registry buffer then just bury it."
  (interactive)
  (let* ((buf (current-buffer))
	 (dir-diffs-buffer ediff-dir-diffs-buffer)
	 (meta-diff-buffer ediff-meta-diff-buffer)
	 (session-number ediff-meta-session-number)
	 (parent-buf ediff-parent-meta-buffer)
	 (dont-show-registry (eq buf ediff-registry-buffer)))
    (if dont-show-registry
	(bury-buffer)
      ;;(ediff-cleanup-meta-buffer buf)
      (cond ((and (ediff-safe-to-quit buf)
		  (y-or-n-p "Quit this session group? "))
	     (run-hooks 'ediff-quit-session-group-hook)
	     (message "")
	     (ediff-dispose-of-meta-buffer buf))
	    ((ediff-safe-to-quit buf)
	     (bury-buffer))
	    (t
	     (error
	      "This session group has active sessions---cannot exit")))
      (ediff-update-meta-buffer parent-buf nil session-number)
      (ediff-kill-buffer-carefully dir-diffs-buffer)
      (ediff-kill-buffer-carefully meta-diff-buffer)
      (if (ediff-buffer-live-p parent-buf)
	  (progn
	    (setq dont-show-registry t)
	    (ediff-show-meta-buffer parent-buf session-number)))
      )
    (or dont-show-registry
	(ediff-show-registry))))

(defun ediff-dispose-of-meta-buffer (buf)
  (setq ediff-session-registry (delq buf ediff-session-registry))
  (ediff-with-current-buffer buf
    (if (ediff-buffer-live-p ediff-dir-diffs-buffer)
	(kill-buffer ediff-dir-diffs-buffer)))
  (kill-buffer buf))
    

;; Obtain information on a meta record where the user clicked or typed
;; BUF is the buffer where this happened and POINT is the position
;; If optional NOERROR arg is given, don't report error and return nil if no
;; meta info is found on line.
(defun ediff-get-meta-info (buf point &optional noerror)
  (let (result olist tmp)
    (if (and point (ediff-buffer-live-p buf))
	(ediff-with-current-buffer buf
	  (if ediff-xemacs-p
	      (setq result
		    (if (setq tmp (extent-at point buf 'ediff-meta-info))
			(ediff-overlay-get tmp 'ediff-meta-info)))
	    (setq olist (overlays-at point))
	    (setq olist
		  (mapcar (function (lambda (elt)
				      (overlay-get elt 'ediff-meta-info)))
			  olist))
	    (while (and olist (null (car olist))
			(overlay-get (car olist) 'invisible))
	      (setq olist (cdr olist)))
	    (setq result (car olist)))))
    (if result
	result
      (if noerror
	  nil
	(ediff-update-registry)
	(error "No session info in this line")))))


(defun ediff-get-meta-overlay-at-pos (point)
  (if ediff-xemacs-p
      (extent-at point (current-buffer) 'ediff-meta-info)
    (let* ((overl-list (overlays-at point))
	   (overl (car overl-list)))
      (while (and overl (null (overlay-get overl 'ediff-meta-info)))
	(setq overl-list (cdr overl-list)
	      overl (car overl-list)))
      overl)))

(defsubst ediff-get-session-number-at-pos (point &optional meta-buffer)
  (setq meta-buffer (if (ediff-buffer-live-p meta-buffer)
			meta-buffer
		      (current-buffer)))
  (ediff-with-current-buffer meta-buffer
    (ediff-overlay-get
     (ediff-get-meta-overlay-at-pos point) 'ediff-meta-session-number)))


;; Return location of the next meta overlay after point
(defun ediff-next-meta-overlay-start (point)
  (if (eobp)
      (goto-char (point-min))
    (let ((overl (ediff-get-meta-overlay-at-pos point)))
      (if ediff-xemacs-p
	  (progn
	    (if overl
		(setq overl (next-extent overl))
	      (setq overl (next-extent (current-buffer))))
	    (if overl
		(extent-start-position overl)
	      (point-max)))
	(if overl
	    ;; note: end of current overlay is the beginning of the next one
	    (overlay-end overl)
	  (next-overlay-change point))))
    ))


(defun ediff-previous-meta-overlay-start (point)
  (if (bobp)
      (goto-char (point-max))
    (let ((overl (ediff-get-meta-overlay-at-pos point)))
      (if ediff-xemacs-p
	  (progn
	    (if overl
		(setq overl (previous-extent overl))
	      (setq overl (previous-extent (current-buffer))))
	    (if overl
		(extent-start-position overl)
	      (point-min)))
	(if overl (setq point (overlay-start overl)))
	;; to get to the beginning of prev overlay
	(if (not (bobp))
	    ;; trick to overcome an emacs bug--doesn't always find previous
	    ;; overlay change correctly
	    (setq point (1- point)))
	(setq point (previous-overlay-change point))
	;; If we are not over an overlay after subtracting 1, it means we are
	;; in the description area preceding session records. In this case,
	;; goto the top of the registry buffer.
	(or (car (overlays-at point))
	    (setq point (point-min)))
	point))))

;; this is the action invoked when the user selects a patch from the meta
;; buffer.
(defun ediff-patch-file-form-meta (file &optional startup-hooks)
  (let* ((pos (ediff-event-point last-command-event))
	 (meta-buf (ediff-event-buffer last-command-event))
	 ;; ediff-get-meta-info gives error if meta-buf or pos are invalid
	 (info (ediff-get-meta-info meta-buf pos))
	 (meta-patchbuf ediff-meta-patchbufer)
	 session-buf beg-marker end-marker)

    (if (or (file-directory-p file) (string-match "/dev/null" file))
	(error "`%s' is not an ordinary file" (file-name-as-directory file)))
    (setq session-buf (ediff-get-session-buffer info)
	  beg-marker (ediff-get-session-objB-name info)
	  end-marker (ediff-get-session-objC-name info))

    (or (ediff-buffer-live-p session-buf) ; either an active patch session
	(null session-buf)  		  ; or it is a virgin session
	(error
	 "Patch has been already applied to this file--cannot be repeated!"))

    (ediff-with-current-buffer meta-patchbuf
      (save-restriction
	(widen)
	(narrow-to-region beg-marker end-marker)
	(ediff-patch-file-internal meta-patchbuf file startup-hooks)))))


(defun ediff-unmark-all-for-operation ()
  "Unmark all sessions marked for operation."
  (interactive)
  (let ((list (cdr ediff-meta-list)))
    (while (setq elt (car list))
      (ediff-mark-session-for-operation elt 'unmark)
      (setq list (cdr list))))
  (ediff-update-meta-buffer (current-buffer) 'must-redraw))

(defun ediff-unmark-all-for-hiding ()
  "Unmark all sessions marked for hiding."
  (interactive)
  (let ((list (cdr ediff-meta-list)))
    (while (setq elt (car list))
      (ediff-mark-session-for-hiding elt 'unmark)
      (setq list (cdr list))))
  (ediff-update-meta-buffer (current-buffer) 'must-redraw))


(defun ediff-meta-mark-equal-files ()
  "Run though the session list and mark identical files.
This is used only for sessions that involve 2 or 3 files at the same time."
  (interactive)
  (let ((list (cdr ediff-meta-list))
	marked1 marked2 marked3
	fileinfo1 fileinfo2 fileinfo3 elt)
    (while (setq elt (car list))
      (setq fileinfo1 (ediff-get-session-objA elt)
	    fileinfo2 (ediff-get-session-objB elt)
	    fileinfo3 (ediff-get-session-objC elt))
      (ediff-set-file-eqstatus fileinfo1 nil)
      (ediff-set-file-eqstatus fileinfo2 nil)
      (ediff-set-file-eqstatus fileinfo3 nil)

      (setq marked1 t
	    marked2 t
	    marked3 t)
      (or (ediff-mark-if-equal fileinfo1 fileinfo2)
	  (setq marked1 nil))
      (if (ediff-metajob3)
	  (progn
	    (or (ediff-mark-if-equal fileinfo1 fileinfo3)
		(setq marked2 nil))
	    (or (ediff-mark-if-equal fileinfo2 fileinfo3)
		(setq marked3 nil))))
      (if (and marked1 marked2 marked3)
	  (cond ((eq last-command-char ?h)
		 (ediff-mark-session-for-hiding elt 'mark))
		((eq last-command-char ?m)
		 (ediff-mark-session-for-operation elt 'mark))
		))
      (setq list (cdr list))))
  (ediff-update-meta-buffer (current-buffer) 'must-redraw))

;; mark files 1 and 2 as equal, if they are.
;; returns t, if something was marked
(defun ediff-mark-if-equal (fileinfo1 fileinfo2)
  (let ((f1 (car fileinfo1))
	(f2 (car fileinfo2)))
    (cond ((file-directory-p f1) nil)
	  ((file-directory-p f2) nil)
	  ((ediff-same-file-contents f1 f2)
	   (ediff-set-file-eqstatus fileinfo1 t)
	   (ediff-set-file-eqstatus fileinfo2 t)
	   t))
    ))



;;; Local Variables:
;;; eval: (put 'ediff-defvar-local 'lisp-indent-hook 'defun)
;;; eval: (put 'ediff-with-current-buffer 'lisp-indent-hook 1)
;;; eval: (put 'ediff-with-current-buffer 'edebug-form-spec '(form body))
;;; End:

;;; ediff-mult.el ends here
