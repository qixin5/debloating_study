;;; gnus-nocem.el --- NoCeM pseudo-cancellation treatment
;; Copyright (C) 1995,96,97,98 Free Software Foundation, Inc.

;; Author: Lars Magne Ingebrigtsen <larsi@gnus.org>
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

;;; Code:

(eval-when-compile (require 'cl))

(eval-when-compile (require 'cl))

(require 'gnus)
(require 'nnmail)
(require 'gnus-art)
(require 'gnus-sum)
(require 'gnus-range)

(defgroup gnus-nocem nil
  "NoCeM pseudo-cancellation treatment"
  :group 'gnus-score)

(defcustom gnus-nocem-groups
  '("news.lists.filters" "news.admin.net-abuse.bulletins"
    "alt.nocem.misc" "news.admin.net-abuse.announce")
  "*List of groups that will be searched for NoCeM messages."
  :group 'gnus-nocem
  :type '(repeat (string :tag "Group")))

(defcustom gnus-nocem-issuers
  '("AutoMoose-1" "Automoose-1"		; CancelMoose[tm]
    "rbraver@ohww.norman.ok.us"		; Robert Braver
    "clewis@ferret.ocunix.on.ca"	; Chris Lewis
    "jem@xpat.com"			; Despammer from Korea
    "snowhare@xmission.com"		; Benjamin "Snowhare" Franz
    "red@redpoll.mrfs.oh.us (Richard E. Depew)" ; ARMM! ARMM!
    )
  "*List of NoCeM issuers to pay attention to.

This can also be a list of `(ISSUER CONDITIONS)' elements."
  :group 'gnus-nocem
  :type '(repeat (choice string sexp)))

(defcustom gnus-nocem-directory
  (nnheader-concat gnus-article-save-directory "NoCeM/")
  "*Directory where NoCeM files will be stored."
  :group 'gnus-nocem
  :type 'directory)

(defcustom gnus-nocem-expiry-wait 15
  "*Number of days to keep NoCeM headers in the cache."
  :group 'gnus-nocem
  :type 'integer)

(defcustom gnus-nocem-verifyer 'mc-verify
  "*Function called to verify that the NoCeM message is valid.
One likely value is `mc-verify'.  If the function in this variable
isn't bound, the message will be used unconditionally."
  :group 'gnus-nocem
  :type '(radio (function-item mc-verify)
		(function :tag "other")))

(defcustom gnus-nocem-liberal-fetch nil
  "*If t try to fetch all messages which have @@NCM in the subject.
Otherwise don't fetch messages which have references or whose message-id
matches an previously scanned and verified nocem message."
  :group 'gnus-nocem
  :type 'boolean)

;;; Internal variables

(defvar gnus-nocem-active nil)
(defvar gnus-nocem-alist nil)
(defvar gnus-nocem-touched-alist nil)
(defvar gnus-nocem-hashtb nil)
(defvar gnus-nocem-seen-message-ids nil)

;;; Functions

(defun gnus-nocem-active-file ()
  (concat (file-name-as-directory gnus-nocem-directory) "active"))

(defun gnus-nocem-cache-file ()
  (concat (file-name-as-directory gnus-nocem-directory) "cache"))

;;
;; faster lookups for group names:
;;

(defvar gnus-nocem-real-group-hashtb nil
  "Real-name mappings of subscribed groups.")

(defun gnus-fill-real-hashtb ()
  "Fill up a hash table with the real-name mappings from the user's active file."
  (setq gnus-nocem-real-group-hashtb (gnus-make-hashtable
				      (length gnus-newsrc-alist)))
  (mapcar (lambda (group)
	    (setq group (gnus-group-real-name (car group)))
	    (gnus-sethash group t gnus-nocem-real-group-hashtb))
	  gnus-newsrc-alist))

(defun gnus-nocem-scan-groups ()
  "Scan all NoCeM groups for new NoCeM messages."
  (interactive)
  (let ((groups gnus-nocem-groups)
	(gnus-inhibit-demon t)
	group active gactive articles)
    (gnus-make-directory gnus-nocem-directory)
    ;; Load any previous NoCeM headers.
    (gnus-nocem-load-cache)
    ;; Get the group name mappings:
    (gnus-fill-real-hashtb)
    ;; Read the active file if it hasn't been read yet.
    (and (file-exists-p (gnus-nocem-active-file))
	 (not gnus-nocem-active)
	 (ignore-errors
	   (load (gnus-nocem-active-file) t t t)))
    ;; Go through all groups and see whether new articles have
    ;; arrived.
    (while (setq group (pop groups))
      (if (not (setq gactive (gnus-activate-group group)))
	  ()				; This group doesn't exist.
	(setq active (nth 1 (assoc group gnus-nocem-active)))
	(when (and (not (< (cdr gactive) (car gactive))) ; Empty group.
		   (or (not active)
		       (< (cdr active) (cdr gactive))))
	  ;; Ok, there are new articles in this group, se we fetch the
	  ;; headers.
	  (save-excursion
	    (let ((dependencies (make-vector 10 nil))
		  headers header)
	      (nnheader-temp-write nil
		(setq headers
		      (if (eq 'nov
			      (gnus-retrieve-headers
			       (setq articles
				     (gnus-uncompress-range
				      (cons
				       (if active (1+ (cdr active))
					 (car gactive))
				       (cdr gactive))))
			       group))
			  (gnus-get-newsgroup-headers-xover
			   articles nil dependencies)
			(gnus-get-newsgroup-headers dependencies)))
		(while (setq header (pop headers))
		  ;; We take a closer look on all articles that have
		  ;; "@@NCM" in the subject.  Unless we already read
		  ;; this cross posted message.  Nocem messages
		  ;; are not allowed to have references, so we can
		  ;; ignore scanning followups.
		  (and (string-match "@@NCM" (mail-header-subject header))
		       (or gnus-nocem-liberal-fetch
			   (and (or (string= "" (mail-header-references
						 header))
				    (null (mail-header-references header)))
				(not (member (mail-header-message-id header)
					     gnus-nocem-seen-message-ids))))
		       (gnus-nocem-check-article group header)))))))
	(setq gnus-nocem-active
	      (cons (list group gactive)
		    (delq (assoc group gnus-nocem-active)
			  gnus-nocem-active)))))
    ;; Save the results, if any.
    (gnus-nocem-save-cache)
    (gnus-nocem-save-active)))

(defun gnus-nocem-check-article (group header)
  "Check whether the current article is an NCM article and that we want it."
  ;; Get the article.
  (gnus-message 7 "Checking article %d in %s for NoCeM..."
		(mail-header-number header) group)
  (let ((date (mail-header-date header))
	issuer b e type)
    (when (or (not date)
	      (nnmail-time-less
	       (nnmail-time-since (nnmail-date-to-time date))
	       (nnmail-days-to-time gnus-nocem-expiry-wait)))
      (gnus-request-article-this-buffer (mail-header-number header) group)
      (goto-char (point-min))
      (when (re-search-forward "-----BEGIN PGP MESSAGE-----" nil t)
	(delete-region (point-min) (match-beginning 0)))
      (when (re-search-forward "-----END PGP MESSAGE-----\n?" nil t)
	(delete-region (match-end 0) (point-max)))
      (goto-char (point-min))
      ;; The article has to have proper NoCeM headers.
      (when (and (setq b (search-forward "\n@@BEGIN NCM HEADERS\n" nil t))
		 (setq e (search-forward "\n@@BEGIN NCM BODY\n" nil t)))
	;; We get the name of the issuer.
	(narrow-to-region b e)
	(setq issuer (mail-fetch-field "issuer")
	      type (mail-fetch-field "issuer"))
	(widen)
	(if (not (gnus-nocem-message-wanted-p issuer type))
	    (message "invalid NoCeM issuer: %s" issuer)
	  (and (gnus-nocem-verify-issuer issuer) ; She is who she says she is.
	       (gnus-nocem-enter-article) ; We gobble the message.
	       (push (mail-header-message-id header) ; But don't come back for
		     gnus-nocem-seen-message-ids))))))) ; second helpings.

(defun gnus-nocem-message-wanted-p (issuer type)
  (let ((issuers gnus-nocem-issuers)
	wanted conditions condition)
    (cond
     ;; Do the quick check first.
     ((member issuer issuers)
      t)
     ((setq conditions (cdr (assoc issuer issuers)))
      ;; Check whether we want this type.
      (while (setq condition (pop conditions))
	(cond
	 ((stringp condition)
	  (setq wanted (string-match condition type)))
	 ((and (consp condition)
	       (eq (car condition) 'not)
	       (stringp (cadr condition)))
	  (setq wanted (not (string-match (cadr condition) type))))
	 (t
	  (error "Invalid NoCeM condition: %S" condition))))
      wanted))))

(defun gnus-nocem-verify-issuer (person)
  "Verify using PGP that the canceler is who she says she is."
  (if (fboundp gnus-nocem-verifyer)
      (ignore-errors
	(funcall gnus-nocem-verifyer))
    ;; If we don't have Mailcrypt, then we use the message anyway.
    t))

(defun gnus-nocem-enter-article ()
  "Enter the current article into the NoCeM cache."
  (goto-char (point-min))
  (let ((b (search-forward "\n@@BEGIN NCM BODY\n" nil t))
	(e (search-forward "\n@@END NCM BODY\n" nil t))
	(buf (current-buffer))
	ncm id group)
    (when (and b e)
      (narrow-to-region b (1+ (match-beginning 0)))
      (goto-char (point-min))
      (while (search-forward "\t" nil t)
	(cond
	 ((not (ignore-errors
		 (setq group (let ((obarray gnus-active-hashtb)) (read buf)))))
	  ;; An error.
	  )
	 ((not (symbolp group))
	  ;; Ignore invalid entries.
	  )
	 ((not (boundp group))
	  ;; Make sure all entries in the hashtb are bound.
	  (set group nil))
	 (t
	  (when (gnus-gethash (gnus-group-real-name (symbol-name group))
			      gnus-nocem-real-group-hashtb)
	    ;; Valid group.
	    (beginning-of-line)
	    (while (= (following-char) ?\t)
	      (forward-line -1))
	    (setq id (buffer-substring (point) (1- (search-forward "\t"))))
	    (unless (gnus-gethash id gnus-nocem-hashtb)
	      ;; only store if not already present
	      (gnus-sethash id t gnus-nocem-hashtb)
	      (push id ncm))
	    (forward-line 1)
	    (while (= (following-char) ?\t)
	      (forward-line 1))))))
      (when ncm
	(setq gnus-nocem-touched-alist t)
	(push (cons (let ((time (current-time))) (setcdr (cdr time) nil) time)
		    ncm)
	      gnus-nocem-alist))
      t)))

(defun gnus-nocem-load-cache ()
  "Load the NoCeM cache."
  (interactive)
  (unless gnus-nocem-alist
    ;; The buffer doesn't exist, so we create it and load the NoCeM
    ;; cache.
    (when (file-exists-p (gnus-nocem-cache-file))
      (load (gnus-nocem-cache-file) t t t)
      (gnus-nocem-alist-to-hashtb))))

(defun gnus-nocem-save-cache ()
  "Save the NoCeM cache."
  (when (and gnus-nocem-alist
	     gnus-nocem-touched-alist)
    (nnheader-temp-write (gnus-nocem-cache-file)
      (gnus-prin1 `(setq gnus-nocem-alist ',gnus-nocem-alist)))
    (setq gnus-nocem-touched-alist nil)))

(defun gnus-nocem-save-active ()
  "Save the NoCeM active file."
  (nnheader-temp-write (gnus-nocem-active-file)
    (gnus-prin1 `(setq gnus-nocem-active ',gnus-nocem-active))))

(defun gnus-nocem-alist-to-hashtb ()
  "Create a hashtable from the Message-IDs we have."
  (let* ((alist gnus-nocem-alist)
	 (pprev (cons nil alist))
	 (prev pprev)
	 (expiry (nnmail-days-to-time gnus-nocem-expiry-wait))
	 entry)
    (setq gnus-nocem-hashtb (gnus-make-hashtable (* (length alist) 51)))
    (while (setq entry (car alist))
      (if (not (nnmail-time-less (nnmail-time-since (car entry)) expiry))
	  ;; This entry has expired, so we remove it.
	  (setcdr prev (cdr alist))
	(setq prev alist)
	;; This is ok, so we enter it into the hashtable.
	(setq entry (cdr entry))
	(while entry
	  (gnus-sethash (car entry) t gnus-nocem-hashtb)
	  (setq entry (cdr entry))))
      (setq alist (cdr alist)))))

(gnus-add-shutdown 'gnus-nocem-close 'gnus)

(defun gnus-nocem-close ()
  "Clear internal NoCeM variables."
  (setq gnus-nocem-alist nil
	gnus-nocem-hashtb nil
	gnus-nocem-active nil
	gnus-nocem-touched-alist nil
	gnus-nocem-seen-message-ids nil
	gnus-nocem-real-group-hashtb nil))

(defun gnus-nocem-unwanted-article-p (id)
  "Say whether article ID in the current group is wanted."
  (and gnus-nocem-hashtb
       (gnus-gethash id gnus-nocem-hashtb)))

(provide 'gnus-nocem)

;;; gnus-nocem.el ends here
