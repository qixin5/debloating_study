;;; smtpmail.el --- simple SMTP protocol (RFC 821) for sending mail

;; Copyright (C) 1995, 1996 Free Software Foundation, Inc.

;; Author: Tomoji Kagatani <kagatani@rbc.ncl.omron.co.jp>
;; Maintainer: Brian D. Carlstrom <bdc@ai.mit.edu>
;; ESMTP support: Simon Leinen <simon@switch.ch>
;; Keywords: mail

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

;; Send Mail to smtp host from smtpmail temp buffer.

;; Please add these lines in your .emacs(_emacs) or use customize.
;;
;;(setq send-mail-function 'smtpmail-send-it) ; if you use `mail'
;;(setq message-send-mail-function 'smtpmail-send-it) ; if you use `message'
;;(setq smtpmail-default-smtp-server "YOUR SMTP HOST")
;;(setq smtpmail-local-domain "YOUR DOMAIN NAME")
;;(setq smtpmail-debug-info t) ; only to debug problems

;; To queue mail, set smtpmail-queue-mail to t and use 
;; smtpmail-send-queued-mail to send.


;;; Code:

(require 'sendmail)
(require 'time-stamp)

;;;
(defgroup smtpmail nil
  "SMTP protocol for sending mail."
  :group 'mail)


(defcustom smtpmail-default-smtp-server nil
  "*Specify default SMTP server."
  :type '(choice (const nil) string)
  :group 'smtpmail)

(defcustom smtpmail-smtp-server 
  (or (getenv "SMTPSERVER") smtpmail-default-smtp-server)
  "*The name of the host running SMTP server."
  :type '(choice (const nil) string)
  :group 'smtpmail)

(defcustom smtpmail-smtp-service 25
  "*SMTP service port number. smtp or 25 ."
  :type 'integer
  :group 'smtpmail)

(defcustom smtpmail-local-domain nil
  "*Local domain name without a host name.
If the function (system-name) returns the full internet address,
don't define this value."
  :type '(choice (const nil) string)
  :group 'smtpmail)

(defcustom smtpmail-debug-info nil
  "*smtpmail debug info printout. messages and process buffer."
  :type 'boolean
  :group 'smtpmail)

(defcustom smtpmail-code-conv-from nil ;; *junet*
  "*smtpmail code convert from this code to *internal*..for tiny-mime.."
  :type 'boolean
  :group 'smtpmail)

(defcustom smtpmail-queue-mail nil 
  "*Specify if mail is queued (if t) or sent immediately (if nil).
If queued, it is stored in the directory `smtpmail-queue-dir'
and sent with `smtpmail-send-queued-mail'."
  :type 'boolean
  :group 'smtpmail)

(defcustom smtpmail-queue-dir "~/Mail/queued-mail/"
  "*Directory where `smtpmail.el' stores queued mail."
  :type 'directory
  :group 'smtpmail)

(defvar smtpmail-queue-index-file "index"
  "File name of queued mail index,
This is relative to `smtpmail-queue-dir'.")

(defvar smtpmail-address-buffer)
(defvar smtpmail-recipient-address-list)

;; Buffer-local variable.
(defvar smtpmail-read-point)

(defvar smtpmail-queue-index (concat smtpmail-queue-dir
				     smtpmail-queue-index-file))

;;;
;;;
;;;

;;;###autoload
(defun smtpmail-send-it ()
  (require 'mail-utils)
  (let ((errbuf (if mail-interactive
		    (generate-new-buffer " smtpmail errors")
		  0))
	(tembuf (generate-new-buffer " smtpmail temp"))
	(case-fold-search nil)
	delimline
	(mailbuf (current-buffer))
	(smtpmail-code-conv-from
	 (if enable-multibyte-characters
	     (let ((sendmail-coding-system smtpmail-code-conv-from))
	       (select-message-coding-system)))))
    (unwind-protect
	(save-excursion
	  (set-buffer tembuf)
	  (erase-buffer)
	  (insert-buffer-substring mailbuf)
	  (goto-char (point-max))
	  ;; require one newline at the end.
	  (or (= (preceding-char) ?\n)
	      (insert ?\n))
	  ;; Change header-delimiter to be what sendmail expects.
	  (mail-sendmail-undelimit-header)
	  (setq delimline (point-marker))
;;	  (sendmail-synch-aliases)
	  (if mail-aliases
	      (expand-mail-aliases (point-min) delimline))
	  (goto-char (point-min))
	  ;; ignore any blank lines in the header
	  (while (and (re-search-forward "\n\n\n*" delimline t)
		      (< (point) delimline))
	    (replace-match "\n"))
	  (let ((case-fold-search t))
	    ;; We used to process Resent-... headers here,
	    ;; but it was not done properly, and the job
	    ;; is done correctly in smtpmail-deduce-address-list.
	    ;; Don't send out a blank subject line
	    (goto-char (point-min))
	    (if (re-search-forward "^Subject:\\([ \t]*\n\\)+\\b" delimline t)
		(replace-match "")
	      ;; This one matches a Subject just before the header delimiter.
	      (if (and (re-search-forward "^Subject:\\([ \t]*\n\\)+" delimline t)
		       (= (match-end 0) delimline))
		  (replace-match "")))
	    ;; Put the "From:" field in unless for some odd reason
	    ;; they put one in themselves.
	    (goto-char (point-min))
	    (if (not (re-search-forward "^From:" delimline t))
		(let* ((login user-mail-address)
		       (fullname (user-full-name)))
		  (cond ((eq mail-from-style 'angles)
			 (insert "From: " fullname)
			 (let ((fullname-start (+ (point-min) 6))
			       (fullname-end (point-marker)))
			   (goto-char fullname-start)
			   ;; Look for a character that cannot appear unquoted
			   ;; according to RFC 822.
			   (if (re-search-forward "[^- !#-'*+/-9=?A-Z^-~]"
						  fullname-end 1)
			       (progn
				 ;; Quote fullname, escaping specials.
				 (goto-char fullname-start)
				 (insert "\"")
				 (while (re-search-forward "[\"\\]"
							   fullname-end 1)
				   (replace-match "\\\\\\&" t))
				 (insert "\""))))
			 (insert " <" login ">\n"))
			((eq mail-from-style 'parens)
			 (insert "From: " login " (")
			 (let ((fullname-start (point)))
			   (insert fullname)
			   (let ((fullname-end (point-marker)))
			     (goto-char fullname-start)
			     ;; RFC 822 says \ and nonmatching parentheses
			     ;; must be escaped in comments.
			     ;; Escape every instance of ()\ ...
			     (while (re-search-forward "[()\\]" fullname-end 1)
			       (replace-match "\\\\\\&" t))
			     ;; ... then undo escaping of matching parentheses,
			     ;; including matching nested parentheses.
			     (goto-char fullname-start)
			     (while (re-search-forward 
				     "\\(\\=\\|[^\\]\\(\\\\\\\\\\)*\\)\\\\(\\(\\([^\\]\\|\\\\\\\\\\)*\\)\\\\)"
				     fullname-end 1)
			       (replace-match "\\1(\\3)" t)
			       (goto-char fullname-start))))
			 (insert ")\n"))
			((null mail-from-style)
			 (insert "From: " login "\n")))))
	    ;; Insert an extra newline if we need it to work around
	    ;; Sun's bug that swallows newlines.
	    (goto-char (1+ delimline))
	    (if (eval mail-mailer-swallows-blank-line)
		(newline))
	    ;; Find and handle any FCC fields.
	    (goto-char (point-min))
	    (if (re-search-forward "^FCC:" delimline t)
		(mail-do-fcc delimline))
	    (if mail-interactive
		(save-excursion
		  (set-buffer errbuf)
		  (erase-buffer))))
	  ;;
	  ;;
	  ;;
	  (setq smtpmail-address-buffer (generate-new-buffer "*smtp-mail*"))
	  (setq smtpmail-recipient-address-list
		    (smtpmail-deduce-address-list tembuf (point-min) delimline))
	  (kill-buffer smtpmail-address-buffer)
	  
	  (smtpmail-do-bcc delimline)
	  ; Send or queue
	  (if (not smtpmail-queue-mail)
	      (if (not (null smtpmail-recipient-address-list))
		  (if (not (smtpmail-via-smtp 
			    smtpmail-recipient-address-list tembuf))
		      (error "Sending failed; SMTP protocol error"))
		(error "Sending failed; no recipients"))
	    (let* ((file-data (concat 
			       smtpmail-queue-dir
			       (concat (time-stamp-yyyy-mm-dd)
				       "_" (time-stamp-hh:mm:ss))))
		      (file-data (convert-standard-filename file-data))
		      (file-elisp (concat file-data ".el"))
		   (buffer-data (create-file-buffer file-data))
		   (buffer-elisp (create-file-buffer file-elisp))
		   (buffer-scratch "*queue-mail*"))
	      (save-excursion
		(set-buffer buffer-data)
		(erase-buffer)
		(insert-buffer tembuf)
		(write-file file-data)
		(set-buffer buffer-elisp)
		(erase-buffer)
		(insert (concat
			 "(setq smtpmail-recipient-address-list '"
			 (prin1-to-string smtpmail-recipient-address-list)
			 ")\n"))	    	    
		(write-file file-elisp)
		(set-buffer (generate-new-buffer buffer-scratch))
		(insert (concat file-data "\n"))
		(append-to-file (point-min) 
				(point-max) 
				smtpmail-queue-index)
		)
	      (kill-buffer buffer-scratch)
	      (kill-buffer buffer-data)
	      (kill-buffer buffer-elisp))))
      (kill-buffer tembuf)
      (if (bufferp errbuf)
	  (kill-buffer errbuf)))))

(defun smtpmail-send-queued-mail ()
  "Send mail that was queued as a result of setting `smtpmail-queue-mail'."
  (interactive)
  ;;; Get index, get first mail, send it, get second mail, etc...
  (let ((buffer-index (find-file-noselect smtpmail-queue-index))
	(file-msg "")
	(tembuf nil))
    (save-excursion
      (set-buffer buffer-index)
      (beginning-of-buffer)
      (while (not (eobp))
	(setq file-msg (buffer-substring (point) (save-excursion
						   (end-of-line)
						   (point))))
	(load file-msg)
	(setq tembuf (find-file-noselect file-msg))
	(if (not (null smtpmail-recipient-address-list))
	    (if (not (smtpmail-via-smtp smtpmail-recipient-address-list 
					tembuf))
		(error "Sending failed; SMTP protocol error"))
	  (error "Sending failed; no recipients"))  
	(delete-file file-msg)
	(delete-file (concat file-msg ".el"))
	(kill-buffer tembuf)
	(kill-line 1))      
      (set-buffer buffer-index)
      (save-buffer smtpmail-queue-index)
      (kill-buffer buffer-index)
      )))

;(defun smtpmail-via-smtp (host,port,sender,destination,smtpmail-text-buffer)

(defun smtpmail-fqdn ()
  (if smtpmail-local-domain
      (concat (system-name) "." smtpmail-local-domain)
    (system-name)))

(defun smtpmail-via-smtp (recipient smtpmail-text-buffer)
  (let ((process nil)
	(host (or smtpmail-smtp-server
		  (error "`smtpmail-smtp-server' not defined")))
	(port smtpmail-smtp-service)
	response-code
	greeting
	process-buffer
	(supported-extensions '()))
    (unwind-protect
	(catch 'done
	  ;; get or create the trace buffer
	  (setq process-buffer
		(get-buffer-create (format "*trace of SMTP session to %s*" host)))

	  ;; clear the trace buffer of old output
	  (save-excursion
	    (set-buffer process-buffer)
	    (erase-buffer))

	  ;; open the connection to the server
	  (setq process (open-network-stream "SMTP" process-buffer host port))
	  (and (null process) (throw 'done nil))

	  ;; set the send-filter
	  (set-process-filter process 'smtpmail-process-filter)

	  (save-excursion
	    (set-buffer process-buffer)
	    (set-buffer-process-coding-system 'raw-text-unix 'raw-text-unix)
	    (make-local-variable 'smtpmail-read-point)
	    (setq smtpmail-read-point (point-min))

	    
	    (if (or (null (car (setq greeting (smtpmail-read-response process))))
		    (not (integerp (car greeting)))
		    (>= (car greeting) 400))
		(throw 'done nil)
	      )

	    ;; EHLO
	    (smtpmail-send-command process (format "EHLO %s" (smtpmail-fqdn)))

	    (if (or (null (car (setq response-code (smtpmail-read-response process))))
		    (not (integerp (car response-code)))
		    (>= (car response-code) 400))
		(progn
		  ;; HELO
		  (smtpmail-send-command process (format "HELO %s" (smtpmail-fqdn)))

		  (if (or (null (car (setq response-code (smtpmail-read-response process))))
			  (not (integerp (car response-code)))
			  (>= (car response-code) 400))
		      (throw 'done nil)))
	      (let ((extension-lines (cdr (cdr response-code))))
		(while extension-lines
		  (let ((name (intern (downcase (car (split-string (substring (car extension-lines) 4) "[ ]"))))))
		    (and name
			 (cond ((memq name '(verb xvrb 8bitmime onex xone
						  expn size dsn etrn
						  help xusr))
				(setq supported-extensions
				      (cons name supported-extensions)))
			       (t (message "unknown extension %s"
					   name)))))
		  (setq extension-lines (cdr extension-lines)))))

	    (if (or (member 'onex supported-extensions)
		    (member 'xone supported-extensions))
		(progn
		  (smtpmail-send-command process (format "ONEX"))
		  (if (or (null (car (setq response-code (smtpmail-read-response process))))
			  (not (integerp (car response-code)))
			  (>= (car response-code) 400))
		      (throw 'done nil))))

	    (if (and smtpmail-debug-info
		     (or (member 'verb supported-extensions)
			 (member 'xvrb supported-extensions)))
		(progn
		  (smtpmail-send-command process (format "VERB"))
		  (if (or (null (car (setq response-code (smtpmail-read-response process))))
			  (not (integerp (car response-code)))
			  (>= (car response-code) 400))
		      (throw 'done nil))))

	    (if (member 'xusr supported-extensions)
		(progn
		  (smtpmail-send-command process (format "XUSR"))
		  (if (or (null (car (setq response-code (smtpmail-read-response process))))
			  (not (integerp (car response-code)))
			  (>= (car response-code) 400))
		      (throw 'done nil))))

	    ;; MAIL FROM: <sender>
	    (let ((size-part
		   (if (member 'size supported-extensions)
		       (format " SIZE=%d"
			       (save-excursion
				 (set-buffer smtpmail-text-buffer)
				 ;; size estimate:
				 (+ (- (point-max) (point-min))
				    ;; Add one byte for each change-of-line
				    ;; because or CR-LF representation:
				    (count-lines (point-min) (point-max))
				    ;; For some reason, an empty line is
				    ;; added to the message.  Maybe this
				    ;; is a bug, but it can't hurt to add
				    ;; those two bytes anyway:
				    2)))
		     ""))
		  (body-part
		   (if (member '8bitmime supported-extensions)
		       ;; FIXME:
		       ;; Code should be added here that transforms
		       ;; the contents of the message buffer into
		       ;; something the receiving SMTP can handle.
		       ;; For a receiver that supports 8BITMIME, this
		       ;; may mean converting BINARY to BASE64, or
		       ;; adding Content-Transfer-Encoding and the
		       ;; other MIME headers.  The code should also
		       ;; return an indication of what encoding the
		       ;; message buffer is now, i.e. ASCII or
		       ;; 8BITMIME.
		       (if nil
			   " BODY=8BITMIME"
			 "")
		     "")))
;	      (smtpmail-send-command process (format "MAIL FROM:%s@%s" (user-login-name) (smtpmail-fqdn)))
	      (smtpmail-send-command process (format "MAIL FROM: <%s>%s%s"
						     user-mail-address
						     size-part
						     body-part))

	      (if (or (null (car (setq response-code (smtpmail-read-response process))))
		      (not (integerp (car response-code)))
		      (>= (car response-code) 400))
		  (throw 'done nil)
		))
	    
	    ;; RCPT TO: <recipient>
	    (let ((n 0))
	      (while (not (null (nth n recipient)))
		(smtpmail-send-command process (format "RCPT TO: <%s>" (nth n recipient)))
		(setq n (1+ n))

		(setq response-code (smtpmail-read-response process))
		(if (or (null (car response-code))
			(not (integerp (car response-code)))
			(>= (car response-code) 400))
		    (throw 'done nil)
		  )
		))
	    
	    ;; DATA
	    (smtpmail-send-command process "DATA")

	    (if (or (null (car (setq response-code (smtpmail-read-response process))))
		    (not (integerp (car response-code)))
		    (>= (car response-code) 400))
		(throw 'done nil)
	      )

	    ;; Mail contents
	    (smtpmail-send-data process smtpmail-text-buffer)

	    ;;DATA end "."
	    (smtpmail-send-command process ".")

	    (if (or (null (car (setq response-code (smtpmail-read-response process))))
		    (not (integerp (car response-code)))
		    (>= (car response-code) 400))
		(throw 'done nil)
	      )

	    ;;QUIT
;	    (smtpmail-send-command process "QUIT")
;	    (and (null (car (smtpmail-read-response process)))
;		 (throw 'done nil))
	    t ))
      (if process
	  (save-excursion
	    (set-buffer (process-buffer process))
	    (smtpmail-send-command process "QUIT")
	    (smtpmail-read-response process)

;	    (if (or (null (car (setq response-code (smtpmail-read-response process))))
;		    (not (integerp (car response-code)))
;		    (>= (car response-code) 400))
;		(throw 'done nil)
;	      )
	    (delete-process process))))))


(defun smtpmail-process-filter (process output)
  (save-excursion
    (set-buffer (process-buffer process))
    (goto-char (point-max))
    (insert output)))

(defun smtpmail-read-response (process)
  (let ((case-fold-search nil)
	(response-strings nil)
	(response-continue t)
	(return-value '(nil ()))
	match-end)

    (while response-continue
      (goto-char smtpmail-read-point)
      (while (not (search-forward "\r\n" nil t))
	(accept-process-output process)
	(goto-char smtpmail-read-point))

      (setq match-end (point))
      (setq response-strings
	    (cons (buffer-substring smtpmail-read-point (- match-end 2))
		  response-strings))
	
      (goto-char smtpmail-read-point)
      (if (looking-at "[0-9]+ ")
	  (let ((begin (match-beginning 0))
		(end (match-end 0)))
	    (if smtpmail-debug-info
		(message "%s" (car response-strings)))

	    (setq smtpmail-read-point match-end)

	    ;; ignore lines that start with "0"
	    (if (looking-at "0[0-9]+ ")
		nil
	      (setq response-continue nil)
	      (setq return-value
		    (cons (string-to-int 
			   (buffer-substring begin end)) 
			  (nreverse response-strings)))))
	
	(if (looking-at "[0-9]+-")
	    (progn (if smtpmail-debug-info
		     (message "%s" (car response-strings)))
		   (setq smtpmail-read-point match-end)
		   (setq response-continue t))
	  (progn
	    (setq smtpmail-read-point match-end)
	    (setq response-continue nil)
	    (setq return-value 
		  (cons nil (nreverse response-strings)))
	    )
	  )))
    (setq smtpmail-read-point match-end)
    return-value))


(defun smtpmail-send-command (process command)
  (goto-char (point-max))
  (if (= (aref command 0) ?P)
      (insert "PASS <omitted>\r\n")
    (insert command "\r\n"))
  (setq smtpmail-read-point (point))
  (process-send-string process command)
  (process-send-string process "\r\n"))

(defun smtpmail-send-data-1 (process data)
  (goto-char (point-max))

  (if (and (multibyte-string-p data)
	   smtpmail-code-conv-from)
      (setq data (string-as-multibyte
		  (encode-coding-string data smtpmail-code-conv-from))))
	
  (if smtpmail-debug-info
      (insert data "\r\n"))

  (setq smtpmail-read-point (point))
  ;; Escape "." at start of a line
  (if (eq (string-to-char data) ?.)
      (process-send-string process "."))
  (process-send-string process data)
  (process-send-string process "\r\n")
  )

(defun smtpmail-send-data (process buffer)
  (let
      ((data-continue t)
       (sending-data nil)
       this-line
       this-line-end)

    (save-excursion
      (set-buffer buffer)
      (goto-char (point-min)))

    (while data-continue
      (save-excursion
	(set-buffer buffer)
	(beginning-of-line)
	(setq this-line (point))
	(end-of-line)
	(setq this-line-end (point))
	(setq sending-data nil)
	(setq sending-data (buffer-substring this-line this-line-end))
	(if (/= (forward-line 1) 0)
	    (setq data-continue nil)))

      (smtpmail-send-data-1 process sending-data)
      )
    )
  )
    

(defun smtpmail-deduce-address-list (smtpmail-text-buffer header-start header-end)
  "Get address list suitable for smtp RCPT TO: <address>."
  (require 'mail-utils)  ;; pick up mail-strip-quoted-names
    
  (unwind-protect
      (save-excursion
	(set-buffer smtpmail-address-buffer) (erase-buffer)
	(let
	    ((case-fold-search t)
	     (simple-address-list "")
	     this-line
	     this-line-end
	     addr-regexp)
	  (insert-buffer-substring smtpmail-text-buffer header-start header-end)
	  (goto-char (point-min))
	  ;; RESENT-* fields should stop processing of regular fields.
	  (save-excursion
	    (if (re-search-forward "^Resent-\\(to\\|cc\\|bcc\\):" header-end t)
		(setq addr-regexp "^Resent-\\(to\\|cc\\|bcc\\):")
	      (setq addr-regexp  "^\\(To:\\|Cc:\\|Bcc:\\)")))

	  (while (re-search-forward addr-regexp header-end t)
	    (replace-match "")
	    (setq this-line (match-beginning 0))
	    (forward-line 1)
	    ;; get any continuation lines
	    (while (and (looking-at "^[ \t]+") (< (point) header-end))
	      (forward-line 1))
	    (setq this-line-end (point-marker))
	    (setq simple-address-list
		  (concat simple-address-list " "
			  (mail-strip-quoted-names (buffer-substring this-line this-line-end))))
	    )
	  (erase-buffer)
	  (insert-string " ")
	  (insert-string simple-address-list)
	  (insert-string "\n")
	  (subst-char-in-region (point-min) (point-max) 10 ?  t);; newline --> blank
	  (subst-char-in-region (point-min) (point-max) ?, ?  t);; comma   --> blank
	  (subst-char-in-region (point-min) (point-max)  9 ?  t);; tab     --> blank

	  (goto-char (point-min))
	  ;; tidyness in case hook is not robust when it looks at this
	  (while (re-search-forward "[ \t]+" header-end t) (replace-match " "))

	  (goto-char (point-min))
	  (let (recipient-address-list)
	    (while (re-search-forward " \\([^ ]+\\) " (point-max) t)
	      (backward-char 1)
	      (setq recipient-address-list (cons (buffer-substring (match-beginning 1) (match-end 1))
						 recipient-address-list))
	      )
	    (setq smtpmail-recipient-address-list recipient-address-list))

	  )
	)
    )
  )


(defun smtpmail-do-bcc (header-end)
  "Delete [Resent-]BCC: and their continuation lines from the header area.
There may be multiple BCC: lines, and each may have arbitrarily
many continuation lines."
  (let ((case-fold-search t))
    (save-excursion
      (goto-char (point-min))
      ;; iterate over all BCC: lines
      (while (re-search-forward "^\\(RESENT-\\)?BCC:" header-end t)
	(delete-region (match-beginning 0)
		       (progn (forward-line 1) (point)))
	;; get rid of any continuation lines
	(while (and (looking-at "^[ \t].*\n") (< (point) header-end))
	  (replace-match ""))))))


(provide 'smtpmail)

;;; smtpmail.el ends here
