;;; message.el --- composing mail and news messages
;; Copyright (C) 1996,97,98 Free Software Foundation, Inc.

;; Author: Lars Magne Ingebrigtsen <larsi@gnus.org>
;; Keywords: mail, news

;; This file is part of GNU Emacs.

;; GNU Emacs is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	 See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;;; Commentary:

;; This mode provides mail-sending facilities from within Emacs.  It
;; consists mainly of large chunks of code from the sendmail.el,
;; gnus-msg.el and rnewspost.el files.

;;; Code:

(eval-when-compile (require 'cl))

(require 'mailheader)
(require 'nnheader)
(require 'timezone)
(require 'easymenu)
(require 'custom)
(if (string-match "XEmacs\\|Lucid" emacs-version)
    (require 'mail-abbrevs)
  (require 'mailabbrev))

(defgroup message '((user-mail-address custom-variable)
		    (user-full-name custom-variable))
  "Mail and news message composing."
  :link '(custom-manual "(message)Top")
  :group 'mail
  :group 'news)

(put 'user-mail-address 'custom-type 'string)
(put 'user-full-name 'custom-type 'string)

(defgroup message-various nil
  "Various Message Variables"
  :link '(custom-manual "(message)Various Message Variables")
  :group 'message)

(defgroup message-buffers nil
  "Message Buffers"
  :link '(custom-manual "(message)Message Buffers")
  :group 'message)

(defgroup message-sending nil
  "Message Sending"
  :link '(custom-manual "(message)Sending Variables")
  :group 'message)

(defgroup message-interface nil
  "Message Interface"
  :link '(custom-manual "(message)Interface")
  :group 'message)

(defgroup message-forwarding nil
  "Message Forwarding"
  :link '(custom-manual "(message)Forwarding")
  :group 'message-interface)

(defgroup message-insertion nil
  "Message Insertion"
  :link '(custom-manual "(message)Insertion")
  :group 'message)

(defgroup message-headers nil
  "Message Headers"
  :link '(custom-manual "(message)Message Headers")
  :group 'message)

(defgroup message-news nil
  "Composing News Messages"
  :group 'message)

(defgroup message-mail nil
  "Composing Mail Messages"
  :group 'message)

(defgroup message-faces nil
  "Faces used for message composing."
  :group 'message
  :group 'faces)

(defcustom message-directory "~/Mail/"
  "*Directory from which all other mail file variables are derived."
  :group 'message-various
  :type 'directory)

(defcustom message-max-buffers 10
  "*How many buffers to keep before starting to kill them off."
  :group 'message-buffers
  :type 'integer)

(defcustom message-send-rename-function nil
  "Function called to rename the buffer after sending it."
  :group 'message-buffers
  :type 'function)

(defcustom message-fcc-handler-function 'message-output
  "*A function called to save outgoing articles.
This function will be called with the name of the file to store the
article in.  The default function is `message-output' which saves in Unix
mailbox format."
  :type '(radio (function-item message-output)
		(function :tag "Other"))
  :group 'message-sending)

(defcustom message-courtesy-message
  "The following message is a courtesy copy of an article\nthat has been posted to %s as well.\n\n"
  "*This is inserted at the start of a mailed copy of a posted message.
If the string contains the format spec \"%s\", the Newsgroups
the article has been posted to will be inserted there.
If this variable is nil, no such courtesy message will be added."
  :group 'message-sending
  :type 'string)

(defcustom message-ignored-bounced-headers "^\\(Received\\|Return-Path\\):"
  "*Regexp that matches headers to be removed in resent bounced mail."
  :group 'message-interface
  :type 'regexp)

;;;###autoload
(defcustom message-from-style 'default
  "*Specifies how \"From\" headers look.

If `nil', they contain just the return address like:
	king@grassland.com
If `parens', they look like:
	king@grassland.com (Elvis Parsley)
If `angles', they look like:
	Elvis Parsley <king@grassland.com>

Otherwise, most addresses look like `angles', but they look like
`parens' if `angles' would need quoting and `parens' would not."
  :type '(choice (const :tag "simple" nil)
		 (const parens)
		 (const angles)
		 (const default))
  :group 'message-headers)

(defcustom message-syntax-checks nil
  ; Guess this one shouldn't be easy to customize...
  "*Controls what syntax checks should not be performed on outgoing posts.
To disable checking of long signatures, for instance, add
 `(signature . disabled)' to this list.

Don't touch this variable unless you really know what you're doing.

Checks include subject-cmsg multiple-headers sendsys message-id from
long-lines control-chars size new-text redirected-followup signature
approved sender empty empty-headers message-id from subject
shorten-followup-to existing-newsgroups buffer-file-name unchanged."
  :group 'message-news)

(defcustom message-required-news-headers
  '(From Newsgroups Subject Date Message-ID
	 (optional . Organization) Lines
	 (optional . X-Newsreader))
  "*Headers to be generated or prompted for when posting an article.
RFC977 and RFC1036 require From, Date, Newsgroups, Subject,
Message-ID.  Organization, Lines, In-Reply-To, Expires, and
X-Newsreader are optional.  If don't you want message to insert some
header, remove it from this list."
  :group 'message-news
  :group 'message-headers
  :type '(repeat sexp))

(defcustom message-required-mail-headers
  '(From Subject Date (optional . In-Reply-To) Message-ID Lines
	 (optional . X-Mailer))
  "*Headers to be generated or prompted for when mailing a message.
RFC822 required that From, Date, To, Subject and Message-ID be
included.  Organization, Lines and X-Mailer are optional."
  :group 'message-mail
  :group 'message-headers
  :type '(repeat sexp))

(defcustom message-deletable-headers '(Message-ID Date Lines)
  "Headers to be deleted if they already exist and were generated by message previously."
  :group 'message-headers
  :type 'sexp)

(defcustom message-ignored-news-headers
  "^NNTP-Posting-Host:\\|^Xref:\\|^[BGF]cc:\\|^Resent-Fcc:"
  "*Regexp of headers to be removed unconditionally before posting."
  :group 'message-news
  :group 'message-headers
  :type 'regexp)

(defcustom message-ignored-mail-headers "^[GF]cc:\\|^Resent-Fcc:\\|^Xref:"
  "*Regexp of headers to be removed unconditionally before mailing."
  :group 'message-mail
  :group 'message-headers
  :type 'regexp)

(defcustom message-ignored-supersedes-headers "^Path:\\|^Date\\|^NNTP-Posting-Host:\\|^Xref:\\|^Lines:\\|^Received:\\|^X-From-Line:\\|^X-Trace:\\|^X-Complaints-To:\\|Return-Path:\\|^Supersedes:\\|^X-Trace:\\|^X-Complaints-To:\\|^NNTP-Posting-Date:"
  "*Header lines matching this regexp will be deleted before posting.
It's best to delete old Path and Date headers before posting to avoid
any confusion."
  :group 'message-interface
  :type 'regexp)

(defcustom message-subject-re-regexp "^[ \t]*\\([Rr][Ee]:[ \t]*\\)*[ \t]*"
  "*Regexp matching \"Re: \" in the subject line."
  :group 'message-various
  :type 'regexp)

;;;###autoload
(defcustom message-signature-separator "^-- *$"
  "Regexp matching the signature separator."
  :type 'regexp
  :group 'message-various)

(defcustom message-elide-elipsis "\n[...]\n\n"
  "*The string which is inserted for elided text."
  :type 'string
  :group 'message-various)

(defcustom message-interactive nil
  "Non-nil means when sending a message wait for and display errors.
nil means let mailer mail back a message to report errors."
  :group 'message-sending
  :group 'message-mail
  :type 'boolean)

(defcustom message-generate-new-buffers t
  "*Non-nil means that a new message buffer will be created whenever `message-setup' is called.
If this is a function, call that function with three parameters:  The type,
the to address and the group name.  (Any of these may be nil.)  The function
should return the new buffer name."
  :group 'message-buffers
  :type '(choice (const :tag "off" nil)
		 (const :tag "on" t)
		 (function fun)))

(defcustom message-kill-buffer-on-exit nil
  "*Non-nil means that the message buffer will be killed after sending a message."
  :group 'message-buffers
  :type 'boolean)

(defvar gnus-local-organization)
(defcustom message-user-organization
  (or (and (boundp 'gnus-local-organization)
	   (stringp gnus-local-organization)
	   gnus-local-organization)
      (getenv "ORGANIZATION")
      t)
  "*String to be used as an Organization header.
If t, use `message-user-organization-file'."
  :group 'message-headers
  :type '(choice string
		 (const :tag "consult file" t)))

;;;###autoload
(defcustom message-user-organization-file "/usr/lib/news/organization"
  "*Local news organization file."
  :type 'file
  :group 'message-headers)

(defcustom message-forward-start-separator
  "------- Start of forwarded message -------\n"
  "*Delimiter inserted before forwarded messages."
  :group 'message-forwarding
  :type 'string)

(defcustom message-forward-end-separator
  "------- End of forwarded message -------\n"
  "*Delimiter inserted after forwarded messages."
  :group 'message-forwarding
  :type 'string)

(defcustom message-signature-before-forwarded-message t
  "*If non-nil, put the signature before any included forwarded message."
  :group 'message-forwarding
  :type 'boolean)

(defcustom message-included-forward-headers
  "^From:\\|^Newsgroups:\\|^Subject:\\|^Date:\\|^Followup-To:\\|^Reply-To:\\|^Organization:\\|^Summary:\\|^Keywords:\\|^To:\\|^Cc:\\|^Posted-To:\\|^Mail-Copies-To:\\|^Apparently-To:\\|^Gnus-Warning:\\|^Resent-\\|^Message-ID:\\|^References:\\|^Content-Transfer-Encoding:\\|^Content-Type:\\|^Mime-Version:"
  "*Regexp matching headers to be included in forwarded messages."
  :group 'message-forwarding
  :type 'regexp)

(defcustom message-make-forward-subject-function
  'message-forward-subject-author-subject
 "*A list of functions that are called to generate a subject header for forwarded messages.
The subject generated by the previous function is passed into each
successive function.

The provided functions are:

* message-forward-subject-author-subject (Source of article (author or
      newsgroup)), in brackets followed by the subject
* message-forward-subject-fwd (Subject of article with 'Fwd:' prepended
      to it."
 :group 'message-forwarding
 :type '(radio (function-item message-forward-subject-author-subject)
	       (function-item message-forward-subject-fwd)))

(defcustom message-wash-forwarded-subjects nil
  "*If non-nil, try to remove as much old cruft as possible from the subject of messages before generating the new subject of a forward."
  :group 'message-forwarding
  :type 'boolean)

(defcustom message-ignored-resent-headers "^Return-receipt"
  "*All headers that match this regexp will be deleted when resending a message."
  :group 'message-interface
  :type 'regexp)

(defcustom message-ignored-cited-headers "."
  "*Delete these headers from the messages you yank."
  :group 'message-insertion
  :type 'regexp)

(defcustom message-cancel-message "I am canceling my own article."
  "Message to be inserted in the cancel message."
  :group 'message-interface
  :type 'string)

;; Useful to set in site-init.el
;;;###autoload
(defcustom message-send-mail-function 'message-send-mail-with-sendmail
  "Function to call to send the current buffer as mail.
The headers should be delimited by a line whose contents match the
variable `mail-header-separator'.

Legal values include `message-send-mail-with-sendmail' (the default),
`message-send-mail-with-mh', `message-send-mail-with-qmail' and
`smtpmail-send-it'."
  :type '(radio (function-item message-send-mail-with-sendmail)
		(function-item message-send-mail-with-mh)
		(function-item message-send-mail-with-qmail)
		(function-item smtpmail-send-it)
		(function :tag "Other"))
  :group 'message-sending
  :group 'message-mail)

(defcustom message-send-news-function 'message-send-news
  "Function to call to send the current buffer as news.
The headers should be delimited by a line whose contents match the
variable `mail-header-separator'."
  :group 'message-sending
  :group 'message-news
  :type 'function)

(defcustom message-reply-to-function nil
  "Function that should return a list of headers.
This function should pick out addresses from the To, Cc, and From headers
and respond with new To and Cc headers."
  :group 'message-interface
  :type 'function)

(defcustom message-wide-reply-to-function nil
  "Function that should return a list of headers.
This function should pick out addresses from the To, Cc, and From headers
and respond with new To and Cc headers."
  :group 'message-interface
  :type 'function)

(defcustom message-followup-to-function nil
  "Function that should return a list of headers.
This function should pick out addresses from the To, Cc, and From headers
and respond with new To and Cc headers."
  :group 'message-interface
  :type 'function)

(defcustom message-use-followup-to 'ask
  "*Specifies what to do with Followup-To header.
If nil, always ignore the header.  If it is t, use its value, but
query before using the \"poster\" value.  If it is the symbol `ask',
always query the user whether to use the value.  If it is the symbol
`use', always use the value."
  :group 'message-interface
  :type '(choice (const :tag "ignore" nil)
		 (const use)
		 (const ask)))

;; stuff relating to broken sendmail in MMDF
(defcustom message-sendmail-f-is-evil nil
  "*Non-nil means that \"-f username\" should not be added to the sendmail
command line, because it is even more evil than leaving it out."
  :group 'message-sending
  :type 'boolean)

;; qmail-related stuff
(defcustom message-qmail-inject-program "/var/qmail/bin/qmail-inject"
  "Location of the qmail-inject program."
  :group 'message-sending
  :type 'file)

(defcustom message-qmail-inject-args nil
  "Arguments passed to qmail-inject programs.
This should be a list of strings, one string for each argument.

For e.g., if you wish to set the envelope sender address so that bounces
go to the right place or to deal with listserv's usage of that address, you
might set this variable to '(\"-f\" \"you@some.where\")."
  :group 'message-sending
  :type '(repeat string))

(defvar gnus-post-method)
(defvar gnus-select-method)
(defcustom message-post-method
  (cond ((and (boundp 'gnus-post-method)
	      (listp gnus-post-method)
	      gnus-post-method)
	 gnus-post-method)
	((boundp 'gnus-select-method)
	 gnus-select-method)
	(t '(nnspool "")))
  "*Method used to post news.
Note that when posting from inside Gnus, for instance, this
variable isn't used."
  :group 'message-news
  :group 'message-sending
  ;; This should be the `gnus-select-method' widget, but that might
  ;; create a dependence to `gnus.el'.
  :type 'sexp)

(defcustom message-generate-headers-first nil
  "*If non-nil, generate all possible headers before composing."
  :group 'message-headers
  :type 'boolean)

(defcustom message-setup-hook nil
  "Normal hook, run each time a new outgoing message is initialized.
The function `message-setup' runs this hook."
  :group 'message-various
  :type 'hook)

(defcustom message-signature-setup-hook nil
  "Normal hook, run each time a new outgoing message is initialized.
It is run after the headers have been inserted and before
the signature is inserted."
  :group 'message-various
  :type 'hook)

(defcustom message-mode-hook nil
  "Hook run in message mode buffers."
  :group 'message-various
  :type 'hook)

(defcustom message-header-hook nil
  "Hook run in a message mode buffer narrowed to the headers."
  :group 'message-various
  :type 'hook)

(defcustom message-header-setup-hook nil
  "Hook called narrowed to the headers when setting up a message buffer."
  :group 'message-various
  :type 'hook)

;;;###autoload
(defcustom message-citation-line-function 'message-insert-citation-line
  "*Function called to insert the \"Whomever writes:\" line."
  :type 'function
  :group 'message-insertion)

;;;###autoload
(defcustom message-yank-prefix "> "
  "*Prefix inserted on the lines of yanked messages.
nil means use indentation."
  :type 'string
  :group 'message-insertion)

(defcustom message-indentation-spaces 3
  "*Number of spaces to insert at the beginning of each cited line.
Used by `message-yank-original' via `message-yank-cite'."
  :group 'message-insertion
  :type 'integer)

;;;###autoload
(defcustom message-cite-function 'message-cite-original
  "*Function for citing an original message.
Predefined functions include `message-cite-original' and
`message-cite-original-without-signature'.
Note that `message-cite-original' uses `mail-citation-hook' if that is non-nil."
  :type '(radio (function-item message-cite-original)
		(function-item sc-cite-original)
		(function :tag "Other"))
  :group 'message-insertion)

;;;###autoload
(defcustom message-indent-citation-function 'message-indent-citation
  "*Function for modifying a citation just inserted in the mail buffer.
This can also be a list of functions.  Each function can find the
citation between (point) and (mark t).  And each function should leave
point and mark around the citation text as modified."
  :type 'function
  :group 'message-insertion)

(defvar message-abbrevs-loaded nil)

;;;###autoload
(defcustom message-signature t
  "*String to be inserted at the end of the message buffer.
If t, the `message-signature-file' file will be inserted instead.
If a function, the result from the function will be used instead.
If a form, the result from the form will be used instead."
  :type 'sexp
  :group 'message-insertion)

;;;###autoload
(defcustom message-signature-file "~/.signature"
  "*File containing the text inserted at end of message buffer."
  :type 'file
  :group 'message-insertion)

(defcustom message-distribution-function nil
  "*Function called to return a Distribution header."
  :group 'message-news
  :group 'message-headers
  :type 'function)

(defcustom message-expires 14
  "Number of days before your article expires."
  :group 'message-news
  :group 'message-headers
  :link '(custom-manual "(message)News Headers")
  :type 'integer)

(defcustom message-user-path nil
  "If nil, use the NNTP server name in the Path header.
If stringp, use this; if non-nil, use no host name (user name only)."
  :group 'message-news
  :group 'message-headers
  :link '(custom-manual "(message)News Headers")
  :type '(choice (const :tag "nntp" nil)
		 (string :tag "name")
		 (sexp :tag "none" :format "%t" t)))

(defvar message-reply-buffer nil)
(defvar message-reply-headers nil)
(defvar message-newsreader nil)
(defvar message-mailer nil)
(defvar message-sent-message-via nil)
(defvar message-checksum nil)
(defvar message-send-actions nil
  "A list of actions to be performed upon successful sending of a message.")
(defvar message-exit-actions nil
  "A list of actions to be performed upon exiting after sending a message.")
(defvar message-kill-actions nil
  "A list of actions to be performed before killing a message buffer.")
(defvar message-postpone-actions nil
  "A list of actions to be performed after postponing a message.")

(define-widget 'message-header-lines 'text
  "All header lines must be LFD terminated."
  :format "%t:%n%v"
  :valid-regexp "^\\'"
  :error "All header lines must be newline terminated")

(defcustom message-default-headers ""
  "*A string containing header lines to be inserted in outgoing messages.
It is inserted before you edit the message, so you can edit or delete
these lines."
  :group 'message-headers
  :type 'message-header-lines)

(defcustom message-default-mail-headers ""
  "*A string of header lines to be inserted in outgoing mails."
  :group 'message-headers
  :group 'message-mail
  :type 'message-header-lines)

(defcustom message-default-news-headers ""
  "*A string of header lines to be inserted in outgoing news
articles."
  :group 'message-headers
  :group 'message-news
  :type 'message-header-lines)

;; Note: could use /usr/ucb/mail instead of sendmail;
;; options -t, and -v if not interactive.
(defcustom message-mailer-swallows-blank-line
  (if (and (string-match "sparc-sun-sunos\\(\\'\\|[^5]\\)"
			 system-configuration)
	   (file-readable-p "/etc/sendmail.cf")
	   (let ((buffer (get-buffer-create " *temp*")))
	     (unwind-protect
		 (save-excursion
		   (set-buffer buffer)
		   (insert-file-contents "/etc/sendmail.cf")
		   (goto-char (point-min))
		   (let ((case-fold-search nil))
		     (re-search-forward "^OR\\>" nil t)))
	       (kill-buffer buffer))))
      ;; According to RFC822, "The field-name must be composed of printable
      ;; ASCII characters (i. e., characters that have decimal values between
      ;; 33 and 126, except colon)", i. e., any chars except ctl chars,
      ;; space, or colon.
      '(looking-at "[ \t]\\|[][!\"#$%&'()*+,-./0-9;<=>?@A-Z\\\\^_`a-z{|}~]+:"))
  "*Set this non-nil if the system's mailer runs the header and body together.
\(This problem exists on Sunos 4 when sendmail is run in remote mode.)
The value should be an expression to test whether the problem will
actually occur."
  :group 'message-sending
  :type 'sexp)

;; Ignore errors in case this is used in Emacs 19.
;; Don't use ignore-errors because this is copied into loaddefs.el.
;;;###autoload
(condition-case nil
    (define-mail-user-agent 'message-user-agent
      'message-mail 'message-send-and-exit
      'message-kill-buffer 'message-send-hook)
  (error nil))

(defvar message-mh-deletable-headers '(Message-ID Date Lines Sender)
  "If non-nil, delete the deletable headers before feeding to mh.")

(defvar message-send-method-alist
  '((news message-news-p message-send-via-news)
    (mail message-mail-p message-send-via-mail))
  "Alist of ways to send outgoing messages.
Each element has the form

  \(TYPE PREDICATE FUNCTION)

where TYPE is a symbol that names the method; PREDICATE is a function
called without any parameters to determine whether the message is
a message of type TYPE; and FUNCTION is a function to be called if
PREDICATE returns non-nil.  FUNCTION is called with one parameter --
the prefix.")

(defvar message-mail-alias-type 'abbrev
  "*What alias expansion type to use in Message buffers.
The default is `abbrev', which uses mailabbrev.  nil switches
mail aliases off.")

(defcustom message-auto-save-directory
  (nnheader-concat message-directory "drafts/")
  "*Directory where Message auto-saves buffers if Gnus isn't running.
If nil, Message won't auto-save."
  :group 'message-buffers
  :type 'directory)

;;; Internal variables.
;;; Well, not really internal.

(defvar message-mode-syntax-table
  (let ((table (copy-syntax-table text-mode-syntax-table)))
    (modify-syntax-entry ?% ". " table)
    table)
  "Syntax table used while in Message mode.")

(defvar message-mode-abbrev-table text-mode-abbrev-table
  "Abbrev table used in Message mode buffers.
Defaults to `text-mode-abbrev-table'.")
(defgroup message-headers nil
  "Message headers."
  :link '(custom-manual "(message)Variables")
  :group 'message)

(defface message-header-to-face
  '((((class color)
      (background dark))
     (:foreground "green2" :bold t))
    (((class color)
      (background light))
     (:foreground "MidnightBlue" :bold t))
    (t
     (:bold t :italic t)))
  "Face used for displaying From headers."
  :group 'message-faces)

(defface message-header-cc-face
  '((((class color)
      (background dark))
     (:foreground "green4" :bold t))
    (((class color)
      (background light))
     (:foreground "MidnightBlue"))
    (t
     (:bold t)))
  "Face used for displaying Cc headers."
  :group 'message-faces)

(defface message-header-subject-face
  '((((class color)
      (background dark))
     (:foreground "green3"))
    (((class color)
      (background light))
     (:foreground "navy blue" :bold t))
    (t
     (:bold t)))
  "Face used for displaying subject headers."
  :group 'message-faces)

(defface message-header-newsgroups-face
  '((((class color)
      (background dark))
     (:foreground "yellow" :bold t :italic t))
    (((class color)
      (background light))
     (:foreground "blue4" :bold t :italic t))
    (t
     (:bold t :italic t)))
  "Face used for displaying newsgroups headers."
  :group 'message-faces)

(defface message-header-other-face
  '((((class color)
      (background dark))
     (:foreground "#b00000"))
    (((class color)
      (background light))
     (:foreground "steel blue"))
    (t
     (:bold t :italic t)))
  "Face used for displaying newsgroups headers."
  :group 'message-faces)

(defface message-header-name-face
  '((((class color)
      (background dark))
     (:foreground "DarkGreen"))
    (((class color)
      (background light))
     (:foreground "cornflower blue"))
    (t
     (:bold t)))
  "Face used for displaying header names."
  :group 'message-faces)

(defface message-header-xheader-face
  '((((class color)
      (background dark))
     (:foreground "blue"))
    (((class color)
      (background light))
     (:foreground "blue"))
    (t
     (:bold t)))
  "Face used for displaying X-Header headers."
  :group 'message-faces)

(defface message-separator-face
  '((((class color)
      (background dark))
     (:foreground "blue3"))
    (((class color)
      (background light))
     (:foreground "brown"))
    (t
     (:bold t)))
  "Face used for displaying the separator."
  :group 'message-faces)

(defface message-cited-text-face
  '((((class color)
      (background dark))
     (:foreground "red"))
    (((class color)
      (background light))
     (:foreground "red"))
    (t
     (:bold t)))
  "Face used for displaying cited text names."
  :group 'message-faces)

(defvar message-font-lock-keywords
  (let* ((cite-prefix "A-Za-z")
	 (cite-suffix (concat cite-prefix "0-9_.@-"))
	 (content "[ \t]*\\(.+\\(\n[ \t].*\\)*\\)"))
    `((,(concat "^\\([Tt]o:\\)" content)
       (1 'message-header-name-face)
       (2 'message-header-to-face nil t))
      (,(concat "^\\(^[GBF]?[Cc][Cc]:\\|^[Rr]eply-[Tt]o:\\)" content)
       (1 'message-header-name-face)
       (2 'message-header-cc-face nil t))
      (,(concat "^\\([Ss]ubject:\\)" content)
       (1 'message-header-name-face)
       (2 'message-header-subject-face nil t))
      (,(concat "^\\([Nn]ewsgroups:\\|Followup-[Tt]o:\\)" content)
       (1 'message-header-name-face)
       (2 'message-header-newsgroups-face nil t))
      (,(concat "^\\([A-Z][^: \n\t]+:\\)" content)
       (1 'message-header-name-face)
       (2 'message-header-other-face nil t))
      (,(concat "^\\(X-[A-Za-z0-9-]+\\|In-Reply-To\\):" content)
       (1 'message-header-name-face)
       (2 'message-header-name-face))
      ,@(if (and mail-header-separator
		 (not (equal mail-header-separator "")))
	    `((,(concat "^\\(" (regexp-quote mail-header-separator) "\\)$")
	       1 'message-separator-face))
	  nil)
      (,(concat "^[ \t]*"
		"\\([" cite-prefix "]+[" cite-suffix "]*\\)?"
		"[:>|}].*")
       (0 'message-cited-text-face))))
  "Additional expressions to highlight in Message mode.")

;; XEmacs does it like this.  For Emacs, we have to set the
;; `font-lock-defaults' buffer-local variable.
(put 'message-mode 'font-lock-defaults '(message-font-lock-keywords t))

(defvar message-face-alist
  '((bold . bold-region)
    (underline . underline-region)
    (default . (lambda (b e)
		 (unbold-region b e)
		 (ununderline-region b e))))
  "Alist of mail and news faces for facemenu.
The cdr of ech entry is a function for applying the face to a region.")

(defcustom message-send-hook nil
  "Hook run before sending messages."
  :group 'message-various
  :options '(ispell-message)
  :type 'hook)

(defcustom message-send-mail-hook nil
  "Hook run before sending mail messages."
  :group 'message-various
  :type 'hook)

(defcustom message-send-news-hook nil
  "Hook run before sending news messages."
  :group 'message-various
  :type 'hook)

(defcustom message-sent-hook nil
  "Hook run after sending messages."
  :group 'message-various
  :type 'hook)

(defvar message-send-coding-system 'binary
  "Coding system to encode outgoing mail.")

;;; Internal variables.

(defvar message-buffer-list nil)
(defvar message-this-is-news nil)
(defvar message-this-is-mail nil)
(defvar message-draft-article nil)

;; Byte-compiler warning
(defvar gnus-active-hashtb)
(defvar gnus-read-active-file)

;;; Regexp matching the delimiter of messages in UNIX mail format
;;; (UNIX From lines), minus the initial ^.  It should be a copy
;;; of rmail.el's rmail-unix-mail-delimiter.
(defvar message-unix-mail-delimiter
  (let ((time-zone-regexp
	 (concat "\\([A-Z]?[A-Z]?[A-Z][A-Z]\\( DST\\)?"
		 "\\|[-+]?[0-9][0-9][0-9][0-9]"
		 "\\|"
		 "\\) *")))
    (concat
     "From "

     ;; Many things can happen to an RFC 822 mailbox before it is put into
     ;; a `From' line.  The leading phrase can be stripped, e.g.
     ;; `Joe <@w.x:joe@y.z>' -> `<@w.x:joe@y.z>'.  The <> can be stripped, e.g.
     ;; `<@x.y:joe@y.z>' -> `@x.y:joe@y.z'.  Everything starting with a CRLF
     ;; can be removed, e.g.
     ;;		From: joe@y.z (Joe	K
     ;;			User)
     ;; can yield `From joe@y.z (Joe 	K Fri Mar 22 08:11:15 1996', and
     ;;		From: Joe User
     ;;			<joe@y.z>
     ;; can yield `From Joe User Fri Mar 22 08:11:15 1996'.
     ;; The mailbox can be removed or be replaced by white space, e.g.
     ;;		From: "Joe User"{space}{tab}
     ;;			<joe@y.z>
     ;; can yield `From {space}{tab} Fri Mar 22 08:11:15 1996',
     ;; where {space} and {tab} represent the Ascii space and tab characters.
     ;; We want to match the results of any of these manglings.
     ;; The following regexp rejects names whose first characters are
     ;; obviously bogus, but after that anything goes.
     "\\([^\0-\b\n-\r\^?].*\\)? "

     ;; The time the message was sent.
     "\\([^\0-\r \^?]+\\) +"				; day of the week
     "\\([^\0-\r \^?]+\\) +"				; month
     "\\([0-3]?[0-9]\\) +"				; day of month
     "\\([0-2][0-9]:[0-5][0-9]\\(:[0-6][0-9]\\)?\\) *"	; time of day

     ;; Perhaps a time zone, specified by an abbreviation, or by a
     ;; numeric offset.
     time-zone-regexp

     ;; The year.
     " \\([0-9][0-9]+\\) *"

     ;; On some systems the time zone can appear after the year, too.
     time-zone-regexp

     ;; Old uucp cruft.
     "\\(remote from .*\\)?"

     "\n"))
  "Regexp matching the delimiter of messages in UNIX mail format.")

(defvar message-unsent-separator
  (concat "^ *---+ +Unsent message follows +---+ *$\\|"
	  "^ *---+ +Returned message +---+ *$\\|"
	  "^Start of returned message$\\|"
	  "^ *---+ +Original message +---+ *$\\|"
	  "^ *--+ +begin message +--+ *$\\|"
	  "^ *---+ +Original message follows +---+ *$\\|"
	  "^|? *---+ +Message text follows: +---+ *|?$")
  "A regexp that matches the separator before the text of a failed message.")

(defvar message-header-format-alist
  `((Newsgroups)
    (To . message-fill-address)
    (Cc . message-fill-address)
    (Subject)
    (In-Reply-To)
    (Fcc)
    (Bcc)
    (Date)
    (Organization)
    (Distribution)
    (Lines)
    (Expires)
    (Message-ID)
    (References . message-shorten-references)
    (X-Mailer)
    (X-Newsreader))
  "Alist used for formatting headers.")

(eval-and-compile
  (autoload 'message-setup-toolbar "messagexmas")
  (autoload 'mh-new-draft-name "mh-comp")
  (autoload 'mh-send-letter "mh-comp")
  (autoload 'gnus-point-at-eol "gnus-util")
  (autoload 'gnus-point-at-bol "gnus-util")
  (autoload 'gnus-output-to-mail "gnus-util")
  (autoload 'gnus-output-to-rmail "gnus-util")
  (autoload 'mail-abbrev-in-expansion-header-p "mailabbrev")
  (autoload 'nndraft-request-associate-buffer "nndraft")
  (autoload 'nndraft-request-expire-articles "nndraft")
  (autoload 'gnus-open-server "gnus-int")
  (autoload 'gnus-request-post "gnus-int")
  (autoload 'gnus-alive-p "gnus-util")
  (autoload 'rmail-output "rmail"))



;;;
;;; Utility functions.
;;;

(defmacro message-y-or-n-p (question show &rest text)
  "Ask QUESTION, displaying the rest of the arguments in a temp. buffer if SHOW"
  `(message-talkative-question 'y-or-n-p ,question ,show ,@text))

;; Delete the current line (and the next N lines.);
(defmacro message-delete-line (&optional n)
  `(delete-region (progn (beginning-of-line) (point))
		  (progn (forward-line ,(or n 1)) (point))))

(defun message-tokenize-header (header &optional separator)
  "Split HEADER into a list of header elements.
\",\" is used as the separator."
  (if (not header)
      nil
    (let ((regexp (format "[%s]+" (or separator ",")))
	  (beg 1)
	  (first t)
	  quoted elems paren)
      (save-excursion
	(message-set-work-buffer)
	(insert header)
	(goto-char (point-min))
	(while (not (eobp))
	  (if first
	      (setq first nil)
	    (forward-char 1))
	  (cond ((and (> (point) beg)
		      (or (eobp)
			  (and (looking-at regexp)
			       (not quoted)
			       (not paren))))
		 (push (buffer-substring beg (point)) elems)
		 (setq beg (match-end 0)))
		((= (following-char) ?\")
		 (setq quoted (not quoted)))
		((and (= (following-char) ?\()
		      (not quoted))
		 (setq paren t))
		((and (= (following-char) ?\))
		      (not quoted))
		 (setq paren nil))))
	(nreverse elems)))))

(defun message-mail-file-mbox-p (file)
  "Say whether FILE looks like a Unix mbox file."
  (when (and (file-exists-p file)
	     (file-readable-p file)
	     (file-regular-p file))
    (nnheader-temp-write nil
      (nnheader-insert-file-contents file)
      (goto-char (point-min))
      (looking-at message-unix-mail-delimiter))))

(defun message-fetch-field (header &optional not-all)
  "The same as `mail-fetch-field', only remove all newlines."
  (let* ((inhibit-point-motion-hooks t)
	 (value (mail-fetch-field header nil (not not-all))))
    (when value
      (nnheader-replace-chars-in-string value ?\n ? ))))

(defun message-add-header (&rest headers)
  "Add the HEADERS to the message header, skipping those already present."
  (while headers
    (let (hclean)
      (unless (string-match "^\\([^:]+\\):[ \t]*[^ \t]" (car headers))
	(error "Invalid header `%s'" (car headers)))
      (setq hclean (match-string 1 (car headers)))
    (save-restriction
      (message-narrow-to-headers)
      (unless (re-search-forward (concat "^" (regexp-quote hclean) ":") nil t)
	(insert (car headers) ?\n))))
    (setq headers (cdr headers))))

(defun message-fetch-reply-field (header)
  "Fetch FIELD from the message we're replying to."
  (when (and message-reply-buffer
	     (buffer-name message-reply-buffer))
    (save-excursion
      (set-buffer message-reply-buffer)
      (message-fetch-field header))))

(defun message-set-work-buffer ()
  (if (get-buffer " *message work*")
      (progn
	(set-buffer " *message work*")
	(erase-buffer))
    (set-buffer (get-buffer-create " *message work*"))
    (kill-all-local-variables)
    (buffer-disable-undo (current-buffer))))

(defun message-functionp (form)
  "Return non-nil if FORM is funcallable."
  (or (and (symbolp form) (fboundp form))
      (and (listp form) (eq (car form) 'lambda))
      (byte-code-function-p form)))

(defun message-strip-subject-re (subject)
  "Remove \"Re:\" from subject lines."
  (if (string-match message-subject-re-regexp subject)
      (substring subject (match-end 0))
    subject))

(defun message-remove-header (header &optional is-regexp first reverse)
  "Remove HEADER in the narrowed buffer.
If REGEXP, HEADER is a regular expression.
If FIRST, only remove the first instance of the header.
Return the number of headers removed."
  (goto-char (point-min))
  (let ((regexp (if is-regexp header (concat "^" (regexp-quote header) ":")))
	(number 0)
	(case-fold-search t)
	last)
    (while (and (not (eobp))
		(not last))
      (if (if reverse
	      (not (looking-at regexp))
	    (looking-at regexp))
	  (progn
	    (incf number)
	    (when first
	      (setq last t))
	    (delete-region
	     (point)
	     ;; There might be a continuation header, so we have to search
	     ;; until we find a new non-continuation line.
	     (progn
	       (forward-line 1)
	       (if (re-search-forward "^[^ \t]" nil t)
		   (goto-char (match-beginning 0))
		 (point-max)))))
	(forward-line 1)
	(if (re-search-forward "^[^ \t]" nil t)
	    (goto-char (match-beginning 0))
	  (point-max))))
    number))

(defun message-narrow-to-headers ()
  "Narrow the buffer to the head of the message."
  (widen)
  (narrow-to-region
   (goto-char (point-min))
   (if (re-search-forward
	(concat "^" (regexp-quote mail-header-separator) "\n") nil t)
       (match-beginning 0)
     (point-max)))
  (goto-char (point-min)))

(defun message-narrow-to-head ()
  "Narrow the buffer to the head of the message."
  (widen)
  (narrow-to-region
   (goto-char (point-min))
   (if (search-forward "\n\n" nil 1)
       (1- (point))
     (point-max)))
  (goto-char (point-min)))

(defun message-news-p ()
  "Say whether the current buffer contains a news message."
  (and (not message-this-is-mail)
       (or message-this-is-news
	   (save-excursion
	     (save-restriction
	       (message-narrow-to-headers)
	       (and (message-fetch-field "newsgroups")
		    (not (message-fetch-field "posted-to"))))))))

(defun message-mail-p ()
  "Say whether the current buffer contains a mail message."
  (and (not message-this-is-news)
       (or message-this-is-mail
	   (save-excursion
	     (save-restriction
	       (message-narrow-to-headers)
	       (or (message-fetch-field "to")
		   (message-fetch-field "cc")
		   (message-fetch-field "bcc")))))))

(defun message-next-header ()
  "Go to the beginning of the next header."
  (beginning-of-line)
  (or (eobp) (forward-char 1))
  (not (if (re-search-forward "^[^ \t]" nil t)
	   (beginning-of-line)
	 (goto-char (point-max)))))

(defun message-sort-headers-1 ()
  "Sort the buffer as headers using `message-rank' text props."
  (goto-char (point-min))
  (sort-subr
   nil 'message-next-header
   (lambda ()
     (message-next-header)
     (unless (bobp)
       (forward-char -1)))
   (lambda ()
     (or (get-text-property (point) 'message-rank)
	 10000))))

(defun message-sort-headers ()
  "Sort the headers of the current message according to `message-header-format-alist'."
  (interactive)
  (save-excursion
    (save-restriction
      (let ((max (1+ (length message-header-format-alist)))
	    rank)
	(message-narrow-to-headers)
	(while (re-search-forward "^[^ \n]+:" nil t)
	  (put-text-property
	   (match-beginning 0) (1+ (match-beginning 0))
	   'message-rank
	   (if (setq rank (length (memq (assq (intern (buffer-substring
						       (match-beginning 0)
						       (1- (match-end 0))))
					      message-header-format-alist)
					message-header-format-alist)))
	       (- max rank)
	     (1+ max)))))
      (message-sort-headers-1))))



;;;
;;; Message mode
;;;

;;; Set up keymap.

(defvar message-mode-map nil)

(unless message-mode-map
  (setq message-mode-map (copy-keymap text-mode-map))
  (define-key message-mode-map "\C-c?" 'describe-mode)

  (define-key message-mode-map "\C-c\C-f\C-t" 'message-goto-to)
  (define-key message-mode-map "\C-c\C-f\C-b" 'message-goto-bcc)
  (define-key message-mode-map "\C-c\C-f\C-w" 'message-goto-fcc)
  (define-key message-mode-map "\C-c\C-f\C-c" 'message-goto-cc)
  (define-key message-mode-map "\C-c\C-f\C-s" 'message-goto-subject)
  (define-key message-mode-map "\C-c\C-f\C-r" 'message-goto-reply-to)
  (define-key message-mode-map "\C-c\C-f\C-n" 'message-goto-newsgroups)
  (define-key message-mode-map "\C-c\C-f\C-d" 'message-goto-distribution)
  (define-key message-mode-map "\C-c\C-f\C-f" 'message-goto-followup-to)
  (define-key message-mode-map "\C-c\C-f\C-k" 'message-goto-keywords)
  (define-key message-mode-map "\C-c\C-f\C-u" 'message-goto-summary)
  (define-key message-mode-map "\C-c\C-b" 'message-goto-body)
  (define-key message-mode-map "\C-c\C-i" 'message-goto-signature)

  (define-key message-mode-map "\C-c\C-t" 'message-insert-to)
  (define-key message-mode-map "\C-c\C-n" 'message-insert-newsgroups)

  (define-key message-mode-map "\C-c\C-y" 'message-yank-original)
  (define-key message-mode-map "\C-c\C-q" 'message-fill-yanked-message)
  (define-key message-mode-map "\C-c\C-w" 'message-insert-signature)
  (define-key message-mode-map "\C-c\C-r" 'message-caesar-buffer-body)
  (define-key message-mode-map "\C-c\C-o" 'message-sort-headers)
  (define-key message-mode-map "\C-c\M-r" 'message-rename-buffer)

  (define-key message-mode-map "\C-c\C-c" 'message-send-and-exit)
  (define-key message-mode-map "\C-c\C-s" 'message-send)
  (define-key message-mode-map "\C-c\C-k" 'message-kill-buffer)
  (define-key message-mode-map "\C-c\C-d" 'message-dont-send)

  (define-key message-mode-map "\C-c\C-e" 'message-elide-region)
  (define-key message-mode-map "\C-c\C-v" 'message-delete-not-region)
  (define-key message-mode-map "\C-c\C-z" 'message-kill-to-signature)
  (define-key message-mode-map "\M-\r" 'message-newline-and-reformat)

  (define-key message-mode-map "\t" 'message-tab))

(easy-menu-define
 message-mode-menu message-mode-map "Message Menu."
 '("Message"
   ["Sort Headers" message-sort-headers t]
   ["Yank Original" message-yank-original t]
   ["Fill Yanked Message" message-fill-yanked-message t]
   ["Insert Signature" message-insert-signature t]
   ["Caesar (rot13) Message" message-caesar-buffer-body t]
   ["Caesar (rot13) Region" message-caesar-region (mark t)]
   ["Elide Region" message-elide-region (mark t)]
   ["Delete Outside Region" message-delete-not-region (mark t)]
   ["Kill To Signature" message-kill-to-signature t]
   ["Newline and Reformat" message-newline-and-reformat t]
   ["Rename buffer" message-rename-buffer t]
   ["Spellcheck" ispell-message t]
   "----"
   ["Send Message" message-send-and-exit t]
   ["Abort Message" message-dont-send t]
   ["Kill Message" message-kill-buffer t]))

(easy-menu-define
 message-mode-field-menu message-mode-map ""
 '("Field"
   ["Fetch To" message-insert-to t]
   ["Fetch Newsgroups" message-insert-newsgroups t]
   "----"
   ["To" message-goto-to t]
   ["Subject" message-goto-subject t]
   ["Cc" message-goto-cc t]
   ["Reply-To" message-goto-reply-to t]
   ["Summary" message-goto-summary t]
   ["Keywords" message-goto-keywords t]
   ["Newsgroups" message-goto-newsgroups t]
   ["Followup-To" message-goto-followup-to t]
   ["Distribution" message-goto-distribution t]
   ["Body" message-goto-body t]
   ["Signature" message-goto-signature t]))

(defvar facemenu-add-face-function)
(defvar facemenu-remove-face-function)

;;;###autoload
(defun message-mode ()
  "Major mode for editing mail and news to be sent.
Like Text Mode but with these additional commands:
C-c C-s  message-send (send the message)    C-c C-c  message-send-and-exit
C-c C-f  move to a header field (and create it if there isn't):
	 C-c C-f C-t  move to To	C-c C-f C-s  move to Subject
	 C-c C-f C-c  move to Cc	C-c C-f C-b  move to Bcc
	 C-c C-f C-w  move to Fcc	C-c C-f C-r  move to Reply-To
	 C-c C-f C-u  move to Summary	C-c C-f C-n  move to Newsgroups
	 C-c C-f C-k  move to Keywords	C-c C-f C-d  move to Distribution
	 C-c C-f C-f  move to Followup-To
C-c C-t  message-insert-to (add a To header to a news followup)
C-c C-n  message-insert-newsgroups (add a Newsgroup header to a news reply)
C-c C-b  message-goto-body (move to beginning of message text).
C-c C-i  message-goto-signature (move to the beginning of the signature).
C-c C-w  message-insert-signature (insert `message-signature-file' file).
C-c C-y  message-yank-original (insert current message, if any).
C-c C-q  message-fill-yanked-message (fill what was yanked).
C-c C-e  message-elide-region (elide the text between point and mark).
C-c C-z  message-kill-to-signature (kill the text up to the signature).
C-c C-r  message-caesar-buffer-body (rot13 the message body)."
  (interactive)
  (kill-all-local-variables)
  (make-local-variable 'message-reply-buffer)
  (setq message-reply-buffer nil)
  (make-local-variable 'message-send-actions)
  (make-local-variable 'message-exit-actions)
  (make-local-variable 'message-kill-actions)
  (make-local-variable 'message-postpone-actions)
  (make-local-variable 'message-draft-article)
  (make-local-hook 'kill-buffer-hook)
  (set-syntax-table message-mode-syntax-table)
  (use-local-map message-mode-map)
  (setq local-abbrev-table message-mode-abbrev-table)
  (setq major-mode 'message-mode)
  (setq mode-name "Message")
  (setq buffer-offer-save t)
  (make-local-variable 'facemenu-add-face-function)
  (make-local-variable 'facemenu-remove-face-function)
  (setq facemenu-add-face-function
	(lambda (face end)
	  (let ((face-fun (cdr (assq face message-face-alist))))
	    (if face-fun
		(funcall face-fun (point) end)
	      (error "Face %s not configured for %s mode" face mode-name)))
	  "")
	facemenu-remove-face-function t)
  (make-local-variable 'paragraph-separate)
  (make-local-variable 'paragraph-start)
  ;; `-- ' precedes the signature.  `-----' appears at the start of the
  ;; lines that delimit forwarded messages.
  ;; Lines containing just >= 3 dashes, perhaps after whitespace,
  ;; are also sometimes used and should be separators.
  (setq paragraph-start (concat (regexp-quote mail-header-separator)
 				"$\\|[ \t]*[a-z0-9A-Z]*>+[ \t]*$\\|[ \t]*$\\|"
 				"-- $\\|---+$\\|"
 				page-delimiter))
  (setq paragraph-separate paragraph-start)
  (make-local-variable 'message-reply-headers)
  (setq message-reply-headers nil)
  (make-local-variable 'message-newsreader)
  (make-local-variable 'message-mailer)
  (make-local-variable 'message-post-method)
  (make-local-variable 'message-sent-message-via)
  (setq message-sent-message-via nil)
  (make-local-variable 'message-checksum)
  (setq message-checksum nil)
  ;;(when (fboundp 'mail-hist-define-keys)
  ;;  (mail-hist-define-keys))
  (when (string-match "XEmacs\\|Lucid" emacs-version)
    (message-setup-toolbar))
  (easy-menu-add message-mode-menu message-mode-map)
  (easy-menu-add message-mode-field-menu message-mode-map)
  (make-local-variable 'adaptive-fill-regexp)
  (setq adaptive-fill-regexp
	(concat "[ \t]*[-a-z0-9A-Z]*>+[ \t]*\\|" adaptive-fill-regexp))
  (make-local-variable 'adaptive-fill-first-line-regexp)
  (setq adaptive-fill-first-line-regexp
	(concat "[ \t]*[-a-z0-9A-Z]*>+[ \t]*\\|"
		adaptive-fill-first-line-regexp))
  ;; Allow mail alias things.
  (when (eq message-mail-alias-type 'abbrev)
    (if (fboundp 'mail-abbrevs-setup)
	(mail-abbrevs-setup)
      (mail-aliases-setup)))
  (message-set-auto-save-file-name)
  (unless (string-match "XEmacs" emacs-version)
    (set (make-local-variable 'font-lock-defaults)
	 '(message-font-lock-keywords t)))
  (make-local-variable 'adaptive-fill-regexp)
  (setq adaptive-fill-regexp
	(concat "[ \t]*[-a-z0-9A-Z]*>+[ \t]*\\|" adaptive-fill-regexp))
  (unless (boundp 'adaptive-fill-first-line-regexp)
    (setq adaptive-fill-first-line-regexp nil))
  (make-local-variable 'adaptive-fill-first-line-regexp)
  (setq adaptive-fill-first-line-regexp
	(concat "[ \t]*[-a-z0-9A-Z]*>+[ \t]*\\|"
		adaptive-fill-first-line-regexp))
  (run-hooks 'text-mode-hook 'message-mode-hook))



;;;
;;; Message mode commands
;;;

;;; Movement commands

(defun message-goto-to ()
  "Move point to the To header."
  (interactive)
  (message-position-on-field "To"))

(defun message-goto-subject ()
  "Move point to the Subject header."
  (interactive)
  (message-position-on-field "Subject"))

(defun message-goto-cc ()
  "Move point to the Cc header."
  (interactive)
  (message-position-on-field "Cc" "To"))

(defun message-goto-bcc ()
  "Move point to the Bcc  header."
  (interactive)
  (message-position-on-field "Bcc" "Cc" "To"))

(defun message-goto-fcc ()
  "Move point to the Fcc header."
  (interactive)
  (message-position-on-field "Fcc" "To" "Newsgroups"))

(defun message-goto-reply-to ()
  "Move point to the Reply-To header."
  (interactive)
  (message-position-on-field "Reply-To" "Subject"))

(defun message-goto-newsgroups ()
  "Move point to the Newsgroups header."
  (interactive)
  (message-position-on-field "Newsgroups"))

(defun message-goto-distribution ()
  "Move point to the Distribution header."
  (interactive)
  (message-position-on-field "Distribution"))

(defun message-goto-followup-to ()
  "Move point to the Followup-To header."
  (interactive)
  (message-position-on-field "Followup-To" "Newsgroups"))

(defun message-goto-keywords ()
  "Move point to the Keywords header."
  (interactive)
  (message-position-on-field "Keywords" "Subject"))

(defun message-goto-summary ()
  "Move point to the Summary header."
  (interactive)
  (message-position-on-field "Summary" "Subject"))

(defun message-goto-body ()
  "Move point to the beginning of the message body."
  (interactive)
  (if (looking-at "[ \t]*\n") (expand-abbrev))
  (goto-char (point-min))
  (search-forward (concat "\n" mail-header-separator "\n") nil t))

(defun message-goto-eoh ()
  "Move point to the end of the headers."
  (interactive)
  (message-goto-body)
  (forward-line -2))

(defun message-goto-signature ()
  "Move point to the beginning of the message signature.
If there is no signature in the article, go to the end and
return nil."
  (interactive)
  (goto-char (point-min))
  (if (re-search-forward message-signature-separator nil t)
      (forward-line 1)
    (goto-char (point-max))
    nil))



(defun message-insert-to (&optional force)
  "Insert a To header that points to the author of the article being replied to.
If the original author requested not to be sent mail, the function signals
an error.
With the prefix argument FORCE, insert the header anyway."
  (interactive "P")
  (let ((co (message-fetch-reply-field "mail-copies-to")))
    (when (and (null force)
	       co
	       (equal (downcase co) "never"))
      (error "The user has requested not to have copies sent via mail")))
  (when (and (message-position-on-field "To")
	     (mail-fetch-field "to")
	     (not (string-match "\\` *\\'" (mail-fetch-field "to"))))
    (insert ", "))
  (insert (or (message-fetch-reply-field "reply-to")
	      (message-fetch-reply-field "from") "")))

(defun message-insert-newsgroups ()
  "Insert the Newsgroups header from the article being replied to."
  (interactive)
  (when (and (message-position-on-field "Newsgroups")
	     (mail-fetch-field "newsgroups")
	     (not (string-match "\\` *\\'" (mail-fetch-field "newsgroups"))))
    (insert ","))
  (insert (or (message-fetch-reply-field "newsgroups") "")))



;;; Various commands

(defun message-delete-not-region (beg end)
  "Delete everything in the body of the current message that is outside of the region."
  (interactive "r")
  (save-excursion
    (goto-char end)
    (delete-region (point) (if (not (message-goto-signature))
			       (point)
			     (forward-line -2)
			     (point)))
    (insert "\n")
    (goto-char beg)
    (delete-region beg (progn (message-goto-body)
			      (forward-line 2)
			      (point))))
  (when (message-goto-signature)
    (forward-line -2)))

(defun message-kill-to-signature ()
  "Deletes all text up to the signature."
  (interactive)
  (let ((point (point)))
    (message-goto-signature)
    (unless (eobp)
      (forward-line -2))
    (kill-region point (point))
    (unless (bolp)
      (insert "\n"))))

(defun message-newline-and-reformat ()
  "Insert four newlines, and then reformat if inside quoted text."
  (interactive)
  (let ((point (point))
	quoted)
    (save-excursion
      (beginning-of-line)
      (setq quoted (looking-at (regexp-quote message-yank-prefix))))
    (insert "\n\n\n\n")
    (when quoted
      (insert message-yank-prefix))
    (fill-paragraph nil)
    (goto-char point)
    (forward-line 2)))

(defun message-insert-signature (&optional force)
  "Insert a signature.  See documentation for the `message-signature' variable."
  (interactive (list 0))
  (let* ((signature
	  (cond
	   ((and (null message-signature)
		 (eq force 0))
	    (save-excursion
	      (goto-char (point-max))
	      (not (re-search-backward
		    message-signature-separator nil t))))
	   ((and (null message-signature)
		 force)
	    t)
	   ((message-functionp message-signature)
	    (funcall message-signature))
	   ((listp message-signature)
	    (eval message-signature))
	   (t message-signature)))
	 (signature
	  (cond ((stringp signature)
		 signature)
		((and (eq t signature)
		      message-signature-file
		      (file-exists-p message-signature-file))
		 signature))))
    (when signature
      (goto-char (point-max))
      ;; Insert the signature.
      (unless (bolp)
	(insert "\n"))
      (insert "\n-- \n")
      (if (eq signature t)
	  (insert-file-contents message-signature-file)
	(insert signature))
      (goto-char (point-max))
      (or (bolp) (insert "\n")))))

(defun message-elide-region (b e)
  "Elide the text between point and mark.
An ellipsis (from `message-elide-elipsis') will be inserted where the
text was killed."
  (interactive "r")
  (kill-region b e)
  (unless (bolp)
    (insert "\n"))
  (insert message-elide-elipsis))

(defvar message-caesar-translation-table nil)

(defun message-caesar-region (b e &optional n)
  "Caesar rotation of region by N, default 13, for decrypting netnews."
  (interactive
   (list
    (min (point) (or (mark t) (point)))
    (max (point) (or (mark t) (point)))
    (when current-prefix-arg
      (prefix-numeric-value current-prefix-arg))))

  (setq n (if (numberp n) (mod n 26) 13)) ;canonize N
  (unless (or (zerop n)			; no action needed for a rot of 0
	      (= b e))			; no region to rotate
    ;; We build the table, if necessary.
    (when (or (not message-caesar-translation-table)
	      (/= (aref message-caesar-translation-table ?a) (+ ?a n)))
	(setq message-caesar-translation-table
	      (message-make-caesar-translation-table n)))
    ;; Then we translate the region.  Do it this way to retain
    ;; text properties.
    (while (< b e)
      (subst-char-in-region
       b (1+ b) (char-after b)
       (aref message-caesar-translation-table (char-after b)))
      (incf b))))

(defun message-make-caesar-translation-table (n)
  "Create a rot table with offset N."
  (let ((i -1)
	(table (make-string 256 0)))
    (while (< (incf i) 256)
      (aset table i i))
    (concat
     (substring table 0 ?A)
     (substring table (+ ?A n) (+ ?A n (- 26 n)))
     (substring table ?A (+ ?A n))
     (substring table (+ ?A 26) ?a)
     (substring table (+ ?a n) (+ ?a n (- 26 n)))
     (substring table ?a (+ ?a n))
     (substring table (+ ?a 26) 255))))

(defun message-caesar-buffer-body (&optional rotnum)
  "Caesar rotates all letters in the current buffer by 13 places.
Used to encode/decode possiblyun offensive messages (commonly in net.jokes).
With prefix arg, specifies the number of places to rotate each letter forward.
Mail and USENET news headers are not rotated."
  (interactive (if current-prefix-arg
		   (list (prefix-numeric-value current-prefix-arg))
		 (list nil)))
  (save-excursion
    (save-restriction
      (when (message-goto-body)
	(narrow-to-region (point) (point-max)))
      (message-caesar-region (point-min) (point-max) rotnum))))

(defun message-pipe-buffer-body (program)
  "Pipe the message body in the current buffer through PROGRAM."
  (save-excursion
    (save-restriction
      (when (message-goto-body)
        (narrow-to-region (point) (point-max)))
      (let ((body (buffer-substring (point-min) (point-max))))
        (unless (equal 0 (call-process-region
                           (point-min) (point-max) program t t))
            (insert body)
            (message "%s failed." program))))))

(defun message-rename-buffer (&optional enter-string)
  "Rename the *message* buffer to \"*message* RECIPIENT\".
If the function is run with a prefix, it will ask for a new buffer
name, rather than giving an automatic name."
  (interactive "Pbuffer name: ")
  (save-excursion
    (save-restriction
      (goto-char (point-min))
      (narrow-to-region (point)
			(search-forward mail-header-separator nil 'end))
      (let* ((mail-to (or
		       (if (message-news-p) (message-fetch-field "Newsgroups")
			 (message-fetch-field "To"))
		       ""))
	     (mail-trimmed-to
	      (if (string-match "," mail-to)
		  (concat (substring mail-to 0 (match-beginning 0)) ", ...")
		mail-to))
	     (name-default (concat "*message* " mail-trimmed-to))
	     (name (if enter-string
		       (read-string "New buffer name: " name-default)
		     name-default)))
	(rename-buffer name t)))))

(defun message-fill-yanked-message (&optional justifyp)
  "Fill the paragraphs of a message yanked into this one.
Numeric argument means justify as well."
  (interactive "P")
  (save-excursion
    (goto-char (point-min))
    (search-forward (concat "\n" mail-header-separator "\n") nil t)
    (let ((fill-prefix message-yank-prefix))
      (fill-individual-paragraphs (point) (point-max) justifyp
				  mail-citation-prefix-regexp))))

(defun message-indent-citation ()
  "Modify text just inserted from a message to be cited.
The inserted text should be the region.
When this function returns, the region is again around the modified text.

Normally, indent each nonblank line `message-indentation-spaces' spaces.
However, if `message-yank-prefix' is non-nil, insert that prefix on each line."
  (let ((start (point)))
    ;; Remove unwanted headers.
    (when message-ignored-cited-headers
      (let (all-removed)
	(save-restriction
	  (narrow-to-region
	   (goto-char start)
	   (if (search-forward "\n\n" nil t)
	       (1- (point))
	     (point)))
	  (message-remove-header message-ignored-cited-headers t)
	  (when (= (point-min) (point-max))
	    (setq all-removed t))
	  (goto-char (point-max)))
	(if all-removed
	    (goto-char start)
	  (forward-line 1))))
    ;; Delete blank lines at the start of the buffer.
    (while (and (point-min)
		(eolp)
		(not (eobp)))
      (message-delete-line))
    ;; Delete blank lines at the end of the buffer.
    (goto-char (point-max))
    (unless (eolp)
      (insert "\n"))
    (while (and (zerop (forward-line -1))
		(looking-at "$"))
      (message-delete-line))
    ;; Do the indentation.
    (if (null message-yank-prefix)
	(indent-rigidly start (mark t) message-indentation-spaces)
      (save-excursion
	(goto-char start)
	(while (< (point) (mark t))
	  (insert message-yank-prefix)
	  (forward-line 1))))
    (goto-char start)))

(defun message-yank-original (&optional arg)
  "Insert the message being replied to, if any.
Puts point before the text and mark after.
Normally indents each nonblank line ARG spaces (default 3).  However,
if `message-yank-prefix' is non-nil, insert that prefix on each line.

This function uses `message-cite-function' to do the actual citing.

Just \\[universal-argument] as argument means don't indent, insert no
prefix, and don't delete any headers."
  (interactive "P")
  (let ((modified (buffer-modified-p)))
    (when (and message-reply-buffer
	       message-cite-function)
      (delete-windows-on message-reply-buffer t)
      (insert-buffer message-reply-buffer)
      (funcall message-cite-function)
      (message-exchange-point-and-mark)
      (unless (bolp)
	(insert ?\n))
      (unless modified
	(setq message-checksum (message-checksum))))))

(defun message-cite-original-without-signature ()
  "Cite function in the standard Message manner."
  (let ((start (point))
	(end (mark t))
	(functions
	 (when message-indent-citation-function
	   (if (listp message-indent-citation-function)
	       message-indent-citation-function
	     (list message-indent-citation-function)))))
    (goto-char end)
    (when (re-search-backward "^-- $" start t)
      ;; Also peel off any blank lines before the signature.
      (forward-line -1)
      (while (looking-at "^[ \t]*$")
	(forward-line -1))
      (forward-line 1)
      (delete-region (point) end))
    (goto-char start)
    (while functions
      (funcall (pop functions)))
    (when message-citation-line-function
      (unless (bolp)
	(insert "\n"))
      (funcall message-citation-line-function))))

(defvar mail-citation-hook) ;Compiler directive
(defun message-cite-original ()
  "Cite function in the standard Message manner."
  (if (and (boundp 'mail-citation-hook)
 	   mail-citation-hook)
      (run-hooks 'mail-citation-hook)
    (let ((start (point))
 	  (functions
 	   (when message-indent-citation-function
 	     (if (listp message-indent-citation-function)
 		 message-indent-citation-function
 	       (list message-indent-citation-function)))))
      (goto-char start)
      (while functions
 	(funcall (pop functions)))
      (when message-citation-line-function
 	(unless (bolp)
 	  (insert "\n"))
 	(funcall message-citation-line-function)))))

(defun message-insert-citation-line ()
  "Function that inserts a simple citation line."
  (when message-reply-headers
    (insert (mail-header-from message-reply-headers) " writes:\n\n")))

(defun message-position-on-field (header &rest afters)
  (let ((case-fold-search t))
    (save-restriction
      (narrow-to-region
       (goto-char (point-min))
       (progn
	 (re-search-forward
	  (concat "^" (regexp-quote mail-header-separator) "$"))
	 (match-beginning 0)))
      (goto-char (point-min))
      (if (re-search-forward (concat "^" (regexp-quote header) ":") nil t)
	  (progn
	    (re-search-forward "^[^ \t]" nil 'move)
	    (beginning-of-line)
	    (skip-chars-backward "\n")
	    t)
	(while (and afters
		    (not (re-search-forward
			  (concat "^" (regexp-quote (car afters)) ":")
			  nil t)))
	  (pop afters))
	(when afters
	  (re-search-forward "^[^ \t]" nil 'move)
	  (beginning-of-line))
	(insert header ": \n")
	(forward-char -1)
	nil))))

(defun message-remove-signature ()
  "Remove the signature from the text between point and mark.
The text will also be indented the normal way."
  (save-excursion
    (let ((start (point))
	  mark)
      (if (not (re-search-forward message-signature-separator (mark t) t))
	  ;; No signature here, so we just indent the cited text.
	  (message-indent-citation)
	;; Find the last non-empty line.
	(forward-line -1)
	(while (looking-at "[ \t]*$")
	  (forward-line -1))
	(forward-line 1)
	(setq mark (set-marker (make-marker) (point)))
	(goto-char start)
	(message-indent-citation)
	;; Enable undoing the deletion.
	(undo-boundary)
	(delete-region mark (mark t))
	(set-marker mark nil)))))



;;;
;;; Sending messages
;;;

(defun message-send-and-exit (&optional arg)
  "Send message like `message-send', then, if no errors, exit from mail buffer."
  (interactive "P")
  (let ((buf (current-buffer))
	(actions message-exit-actions))
    (when (and (message-send arg)
	       (buffer-name buf))
      (if message-kill-buffer-on-exit
	  (kill-buffer buf)
	(bury-buffer buf)
	(when (eq buf (current-buffer))
	  (message-bury buf)))
      (message-do-actions actions)
      t)))

(defun message-dont-send ()
  "Don't send the message you have been editing."
  (interactive)
  (set-buffer-modified-p t)
  (save-buffer)
  (let ((actions message-postpone-actions))
    (message-bury (current-buffer))
    (message-do-actions actions)))

(defun message-kill-buffer ()
  "Kill the current buffer."
  (interactive)
  (when (or (not (buffer-modified-p))
	    (yes-or-no-p "Message modified; kill anyway? "))
    (let ((actions message-kill-actions))
      (setq buffer-file-name nil)
      (kill-buffer (current-buffer))
      (message-do-actions actions))))

(defun message-bury (buffer)
  "Bury this mail buffer."
  (let ((newbuf (other-buffer buffer)))
    (bury-buffer buffer)
    (if (and (fboundp 'frame-parameters)
	     (cdr (assq 'dedicated (frame-parameters)))
	     (not (null (delq (selected-frame) (visible-frame-list)))))
	(delete-frame (selected-frame))
      (switch-to-buffer newbuf))))

(defun message-send (&optional arg)
  "Send the message in the current buffer.
If `message-interactive' is non-nil, wait for success indication
or error messages, and inform user.
Otherwise any failure is reported in a message back to
the user from the mailer."
  (interactive "P")
  ;; Disabled test.
  (when (or (buffer-modified-p)
	    (message-check-element 'unchanged)
	    (y-or-n-p "No changes in the buffer; really send? "))
    ;; Make it possible to undo the coming changes.
    (undo-boundary)
    (let ((inhibit-read-only t))
      (put-text-property (point-min) (point-max) 'read-only nil))
    (message-fix-before-sending)
    (run-hooks 'message-send-hook)
    (message "Sending...")
    (let ((alist message-send-method-alist)
	  (success t)
	  elem sent)
      (while (and success
		  (setq elem (pop alist)))
	(when (and (or (not (funcall (cadr elem)))
		       (and (or (not (memq (car elem)
					   message-sent-message-via))
				(y-or-n-p
				 (format
				  "Already sent message via %s; resend? "
				  (car elem))))
			    (setq success (funcall (caddr elem) arg)))))
	  (setq sent t)))
      (when (and success sent)
	(message-do-fcc)
	;;(when (fboundp 'mail-hist-put-headers-into-history)
	;; (mail-hist-put-headers-into-history))
	(run-hooks 'message-sent-hook)
	(message "Sending...done")
	;; Mark the buffer as unmodified and delete auto-save.
	(set-buffer-modified-p nil)
	(delete-auto-save-file-if-necessary t)
	(message-disassociate-draft)
	;; Delete other mail buffers and stuff.
	(message-do-send-housekeeping)
	(message-do-actions message-send-actions)
	;; Return success.
	t))))

(defun message-send-via-mail (arg)
  "Send the current message via mail."
  (message-send-mail arg))

(defun message-send-via-news (arg)
  "Send the current message via news."
  (funcall message-send-news-function arg))

(defun message-fix-before-sending ()
  "Do various things to make the message nice before sending it."
  ;; Make sure there's a newline at the end of the message.
  (goto-char (point-max))
  (unless (bolp)
    (insert "\n"))
  ;; Make all invisible text visible.
  ;;(when (text-property-any (point-min) (point-max) 'invisible t)
  ;;  (put-text-property (point-min) (point-max) 'invisible nil)
  ;;  (unless (yes-or-no-p "Invisible text found and made visible; continue posting?")
  ;;    (error "Invisible text found and made visible")))
  )

(defun message-add-action (action &rest types)
  "Add ACTION to be performed when doing an exit of type TYPES."
  (let (var)
    (while types
      (set (setq var (intern (format "message-%s-actions" (pop types))))
	   (nconc (symbol-value var) (list action))))))

(defun message-do-actions (actions)
  "Perform all actions in ACTIONS."
  ;; Now perform actions on successful sending.
  (while actions
    (ignore-errors
      (cond
       ;; A simple function.
       ((message-functionp (car actions))
	(funcall (car actions)))
       ;; Something to be evaled.
       (t
	(eval (car actions)))))
    (pop actions)))

(defun message-send-mail (&optional arg)
  (require 'mail-utils)
  (let ((tembuf (message-generate-new-buffer-clone-locals " message temp"))
	(case-fold-search nil)
	(news (message-news-p))
	(mailbuf (current-buffer)))
    (save-restriction
      (message-narrow-to-headers)
      ;; Insert some headers.
      (let ((message-deletable-headers
	     (if news nil message-deletable-headers)))
	(message-generate-headers message-required-mail-headers))
      ;; Let the user do all of the above.
      (run-hooks 'message-header-hook))
    (unwind-protect
	(save-excursion
	  (set-buffer tembuf)
	  (erase-buffer)
	  ;; Avoid copying text props.
	  (insert (format
		   "%s" (save-excursion
			  (set-buffer mailbuf)
			  (buffer-string))))
	  ;; Remove some headers.
	  (save-restriction
	    (message-narrow-to-headers)
	    ;; Remove some headers.
	    (message-remove-header message-ignored-mail-headers t))
	  (goto-char (point-max))
	  ;; require one newline at the end.
	  (or (= (preceding-char) ?\n)
	      (insert ?\n))
	  (when (and news
		     (or (message-fetch-field "cc")
			 (message-fetch-field "to")))
	    (message-insert-courtesy-copy))
	  (funcall message-send-mail-function))
      (kill-buffer tembuf))
    (set-buffer mailbuf)
    (push 'mail message-sent-message-via)))

(defun message-send-mail-with-sendmail ()
  "Send off the prepared buffer with sendmail."
  (let ((errbuf (if message-interactive
		    (generate-new-buffer " sendmail errors")
		  0))
	resend-to-addresses delimline)
    (let ((case-fold-search t))
      (save-restriction
	(message-narrow-to-headers)
	(setq resend-to-addresses (message-fetch-field "resent-to")))
      ;; Change header-delimiter to be what sendmail expects.
      (goto-char (point-min))
      (re-search-forward
       (concat "^" (regexp-quote mail-header-separator) "\n"))
      (replace-match "\n")
      (backward-char 1)
      (setq delimline (point-marker))
      (run-hooks 'message-send-mail-hook)
      ;; Insert an extra newline if we need it to work around
      ;; Sun's bug that swallows newlines.
      (goto-char (1+ delimline))
      (when (eval message-mailer-swallows-blank-line)
	(newline))
      (when message-interactive
	(save-excursion
	  (set-buffer errbuf)
	  (erase-buffer))))
    (let ((default-directory "/")
 	  (coding-system-for-write message-send-coding-system))
      (apply 'call-process-region
	     (append (list (point-min) (point-max)
			   (if (boundp 'sendmail-program)
			       sendmail-program
			     "/usr/lib/sendmail")
			   nil errbuf nil "-oi")
		     ;; Always specify who from,
		     ;; since some systems have broken sendmails.
		     ;; But some systems are more broken with -f, so
		     ;; we'll let users override this.
		     (if (null message-sendmail-f-is-evil)
			 (list "-f" (user-login-name)))
		     ;; These mean "report errors by mail"
		     ;; and "deliver in background".
		     (if (null message-interactive) '("-oem" "-odb"))
		     ;; Get the addresses from the message
		     ;; unless this is a resend.
		     ;; We must not do that for a resend
		     ;; because we would find the original addresses.
		     ;; For a resend, include the specific addresses.
		     (if resend-to-addresses
			 (list resend-to-addresses)
		       '("-t")))))
    (when message-interactive
      (save-excursion
	(set-buffer errbuf)
	(goto-char (point-min))
	(while (re-search-forward "\n\n* *" nil t)
	  (replace-match "; "))
	(if (not (zerop (buffer-size)))
	    (error "Sending...failed to %s"
		   (buffer-substring (point-min) (point-max)))))
      (when (bufferp errbuf)
	(kill-buffer errbuf)))))

(defun message-send-mail-with-qmail ()
  "Pass the prepared message buffer to qmail-inject.
Refer to the documentation for the variable `message-send-mail-function'
to find out how to use this."
  ;; replace the header delimiter with a blank line
  (goto-char (point-min))
  (re-search-forward
   (concat "^" (regexp-quote mail-header-separator) "\n"))
  (replace-match "\n")
  (run-hooks 'message-send-mail-hook)
  ;; send the message
  (case
      (let ((coding-system-for-write message-send-coding-system))
	(apply
	 'call-process-region 1 (point-max) message-qmail-inject-program
	 nil nil nil
	 ;; qmail-inject's default behaviour is to look for addresses on the
	 ;; command line; if there're none, it scans the headers.
	 ;; yes, it does The Right Thing w.r.t. Resent-To and it's kin.
	 ;;
	 ;; in general, ALL of qmail-inject's defaults are perfect for simply
	 ;; reading a formatted (i. e., at least a To: or Resent-To header)
	 ;; message from stdin.
	 ;;
	 ;; qmail also has the advantage of not having been raped by
	 ;; various vendors, so we don't have to allow for that, either --
	 ;; compare this with message-send-mail-with-sendmail and weep
	 ;; for sendmail's lost innocence.
	 ;;
	 ;; all this is way cool coz it lets us keep the arguments entirely
	 ;; free for -inject-arguments -- a big win for the user and for us
	 ;; since we don't have to play that double-guessing game and the user
	 ;; gets full control (no gestapo'ish -f's, for instance).  --sj
	 message-qmail-inject-args))
    ;; qmail-inject doesn't say anything on it's stdout/stderr,
    ;; we have to look at the retval instead
    (0 nil)
    (1   (error "qmail-inject reported permanent failure"))
    (111 (error "qmail-inject reported transient failure"))
    ;; should never happen
    (t   (error "qmail-inject reported unknown failure"))))

(defun message-send-mail-with-mh ()
  "Send the prepared message buffer with mh."
  (let ((mh-previous-window-config nil)
	(name (mh-new-draft-name)))
    (setq buffer-file-name name)
    ;; MH wants to generate these headers itself.
    (when message-mh-deletable-headers
      (let ((headers message-mh-deletable-headers))
	(while headers
	  (goto-char (point-min))
	  (and (re-search-forward
		(concat "^" (symbol-name (car headers)) ": *") nil t)
	       (message-delete-line))
	  (pop headers))))
    (run-hooks 'message-send-mail-hook)
    ;; Pass it on to mh.
    (mh-send-letter)))

(defun message-send-news (&optional arg)
  (let ((tembuf (message-generate-new-buffer-clone-locals " *message temp*"))
	(case-fold-search nil)
	(method (if (message-functionp message-post-method)
		    (funcall message-post-method arg)
		  message-post-method))
	(messbuf (current-buffer))
	(message-syntax-checks
	 (if arg
	     (cons '(existing-newsgroups . disabled)
		   message-syntax-checks)
	   message-syntax-checks))
	result)
    (save-restriction
      (message-narrow-to-headers)
      ;; Insert some headers.
      (message-generate-headers message-required-news-headers)
      ;; Let the user do all of the above.
      (run-hooks 'message-header-hook))
    (message-cleanup-headers)
    (if (not (message-check-news-syntax))
	(progn
	  ;;(message "Posting not performed")
	  nil)
      (unwind-protect
	  (save-excursion
	    (set-buffer tembuf)
	    (buffer-disable-undo (current-buffer))
	    (erase-buffer)
	    ;; Avoid copying text props.
	    (insert (format
		     "%s" (save-excursion
			    (set-buffer messbuf)
			    (buffer-string))))
	    ;; Remove some headers.
	    (save-restriction
	      (message-narrow-to-headers)
	      ;; Remove some headers.
	      (message-remove-header message-ignored-news-headers t))
	    (goto-char (point-max))
	    ;; require one newline at the end.
	    (or (= (preceding-char) ?\n)
		(insert ?\n))
	    (let ((case-fold-search t))
	      ;; Remove the delimiter.
	      (goto-char (point-min))
	      (re-search-forward
	       (concat "^" (regexp-quote mail-header-separator) "\n"))
	      (replace-match "\n")
	      (backward-char 1))
	    (run-hooks 'message-send-news-hook)
	    ;;(require (car method))
	    ;;(funcall (intern (format "%s-open-server" (car method)))
	    ;;(cadr method) (cddr method))
	    ;;(setq result
	    ;;	  (funcall (intern (format "%s-request-post" (car method)))
	    ;;		   (cadr method)))
	    (gnus-open-server method)
	    (setq result (gnus-request-post method)))
	(kill-buffer tembuf))
      (set-buffer messbuf)
      (if result
	  (push 'news message-sent-message-via)
	(message "Couldn't send message via news: %s"
		 (nnheader-get-report (car method)))
	nil))))

;;;
;;; Header generation & syntax checking.
;;;

(defmacro message-check (type &rest forms)
  "Eval FORMS if TYPE is to be checked."
  `(or (message-check-element ,type)
       (save-excursion
	 ,@forms)))

(put 'message-check 'lisp-indent-function 1)
(put 'message-check 'edebug-form-spec '(form body))

(defun message-check-element (type)
  "Returns non-nil if this type is not to be checked."
  (if (eq message-syntax-checks 'dont-check-for-anything-just-trust-me)
      t
    (let ((able (assq type message-syntax-checks)))
      (and (consp able)
	   (eq (cdr able) 'disabled)))))

(defun message-check-news-syntax ()
  "Check the syntax of the message."
  (save-excursion
    (save-restriction
      (widen)
      (and
       ;; We narrow to the headers and check them first.
       (save-excursion
	 (save-restriction
	   (message-narrow-to-headers)
	   (message-check-news-header-syntax)))
       ;; Check the body.
       (message-check-news-body-syntax)))))

(defun message-check-news-header-syntax ()
  (and
   ;; Check the Subject header.
   (message-check 'subject
     (let* ((case-fold-search t)
	    (subject (message-fetch-field "subject")))
       (or
	(and subject
	     (not (string-match "\\`[ \t]*\\'" subject)))
	(ignore
	 (message
	  "The subject field is empty or missing.  Posting is denied.")))))
   ;; Check for commands in Subject.
   (message-check 'subject-cmsg
     (if (string-match "^cmsg " (message-fetch-field "subject"))
	 (y-or-n-p
	  "The control code \"cmsg\" is in the subject.  Really post? ")
       t))
   ;; Check for multiple identical headers.
   (message-check 'multiple-headers
     (let (found)
       (while (and (not found)
		   (re-search-forward "^[^ \t:]+: " nil t))
	 (save-excursion
	   (or (re-search-forward
		(concat "^"
			(regexp-quote
			 (setq found
			       (buffer-substring
				(match-beginning 0) (- (match-end 0) 2))))
			":")
		nil t)
	       (setq found nil))))
       (if found
	   (y-or-n-p (format "Multiple %s headers.  Really post? " found))
	 t)))
   ;; Check for Version and Sendsys.
   (message-check 'sendsys
     (if (re-search-forward "^Sendsys:\\|^Version:" nil t)
	 (y-or-n-p
	  (format "The article contains a %s command.  Really post? "
		  (buffer-substring (match-beginning 0)
				    (1- (match-end 0)))))
       t))
   ;; See whether we can shorten Followup-To.
   (message-check 'shorten-followup-to
     (let ((newsgroups (message-fetch-field "newsgroups"))
	   (followup-to (message-fetch-field "followup-to"))
	   to)
       (when (and newsgroups
		  (string-match "," newsgroups)
		  (not followup-to)
		  (not
		   (zerop
		    (length
		     (setq to (completing-read
			       "Followups to: (default all groups) "
			       (mapcar (lambda (g) (list g))
				       (cons "poster"
					     (message-tokenize-header
					      newsgroups)))))))))
	 (goto-char (point-min))
	 (insert "Followup-To: " to "\n"))
       t))
   ;; Check "Shoot me".
   (message-check 'shoot
     (if (re-search-forward
	  "Message-ID.*.i-did-not-set--mail-host-address--so-shoot-me" nil t)
	 (y-or-n-p "You appear to have a misconfigured system.  Really post? ")
       t))
   ;; Check for Approved.
   (message-check 'approved
     (if (re-search-forward "^Approved:" nil t)
	 (y-or-n-p "The article contains an Approved header.  Really post? ")
       t))
   ;; Check the Message-ID header.
   (message-check 'message-id
     (let* ((case-fold-search t)
	    (message-id (message-fetch-field "message-id" t)))
       (or (not message-id)
	   ;; Is there an @ in the ID?
	   (and (string-match "@" message-id)
		;; Is there a dot in the ID?
		(string-match "@[^.]*\\." message-id)
		;; Does the ID end with a dot?
		(not (string-match "\\.>" message-id)))
	   (y-or-n-p
	    (format "The Message-ID looks strange: \"%s\".  Really post? "
		    message-id)))))
   ;; Check the Newsgroups & Followup-To headers.
   (message-check 'existing-newsgroups
     (let* ((case-fold-search t)
	    (newsgroups (message-fetch-field "newsgroups"))
	    (followup-to (message-fetch-field "followup-to"))
	    (groups (message-tokenize-header
		     (if followup-to
			 (concat newsgroups "," followup-to)
		       newsgroups)))
	    (hashtb (and (boundp 'gnus-active-hashtb)
			 gnus-active-hashtb))
	    errors)
       (if (or (not hashtb)
	       (not (boundp 'gnus-read-active-file))
	       (not gnus-read-active-file)
	       (eq gnus-read-active-file 'some))
	   t
	 (while groups
	   (when (and (not (boundp (intern (car groups) hashtb)))
		      (not (equal (car groups) "poster")))
	     (push (car groups) errors))
	   (pop groups))
	 (if (not errors)
	     t
	   (y-or-n-p
	    (format
	     "Really post to %s unknown group%s: %s "
	     (if (= (length errors) 1) "this" "these")
	     (if (= (length errors) 1) "" "s")
	     (mapconcat 'identity errors ", ")))))))
   ;; Check the Newsgroups & Followup-To headers for syntax errors.
   (message-check 'valid-newsgroups
     (let ((case-fold-search t)
	   (headers '("Newsgroups" "Followup-To"))
	   header error)
       (while (and headers (not error))
	 (when (setq header (mail-fetch-field (car headers)))
	   (if (or
		(not
		 (string-match
		  "\\`\\([-+_&.a-zA-Z0-9]+\\)?\\(,[-+_&.a-zA-Z0-9]+\\)*\\'"
		  header))
		(memq
		 nil (mapcar
		      (lambda (g)
			(not (string-match "\\.\\'\\|\\.\\." g)))
		      (message-tokenize-header header ","))))
	       (setq error t)))
	 (unless error
	   (pop headers)))
       (if (not error)
	   t
	 (y-or-n-p
	  (format "The %s header looks odd: \"%s\".  Really post? "
		  (car headers) header)))))
   (message-check 'repeated-newsgroups
     (let ((case-fold-search t)
	   (headers '("Newsgroups" "Followup-To"))
	   header error groups group)
       (while (and headers
		   (not error))
	 (when (setq header (mail-fetch-field (pop headers)))
	   (setq groups (message-tokenize-header header ","))
	   (while (setq group (pop groups))
	     (when (member group groups)
	       (setq error group
		     groups nil)))))
       (if (not error)
	   t
	 (y-or-n-p
	  (format "Group %s is repeated in headers.  Really post? " error)))))
   ;; Check the From header.
   (message-check 'from
     (let* ((case-fold-search t)
	    (from (message-fetch-field "from"))
	    (ad (nth 1 (mail-extract-address-components from))))
       (cond
	((not from)
	 (message "There is no From line.  Posting is denied.")
	 nil)
	((or (not (string-match "@[^\\.]*\\." ad)) ;larsi@ifi
	     (string-match "\\.\\." ad) ;larsi@ifi..uio
	     (string-match "@\\." ad)	;larsi@.ifi.uio
	     (string-match "\\.$" ad)	;larsi@ifi.uio.
	     (not (string-match "^[^@]+@[^@]+$" ad)) ;larsi.ifi.uio
	     (string-match "(.*).*(.*)" from)) ;(lars) (lars)
	 (message
	  "Denied posting -- the From looks strange: \"%s\"." from)
	 nil)
	(t t))))))

(defun message-check-news-body-syntax ()
  (and
   ;; Check for long lines.
   (message-check 'long-lines
     (goto-char (point-min))
     (re-search-forward
      (concat "^" (regexp-quote mail-header-separator) "$"))
     (while (and
	     (progn
	       (end-of-line)
	       (< (current-column) 80))
	     (zerop (forward-line 1))))
     (or (bolp)
	 (eobp)
	 (y-or-n-p
	  "You have lines longer than 79 characters.  Really post? ")))
   ;; Check whether the article is empty.
   (message-check 'empty
     (goto-char (point-min))
     (re-search-forward
      (concat "^" (regexp-quote mail-header-separator) "$"))
     (forward-line 1)
     (let ((b (point)))
       (goto-char (point-max))
       (re-search-backward message-signature-separator nil t)
       (beginning-of-line)
       (or (re-search-backward "[^ \n\t]" b t)
	   (y-or-n-p "Empty article.  Really post? "))))
   ;; Check for control characters.
   (message-check 'control-chars
     (if (re-search-forward "[\000-\007\013\015-\037\200-\237]" nil t)
	 (y-or-n-p
	  "The article contains control characters.  Really post? ")
       t))
   ;; Check excessive size.
   (message-check 'size
     (if (> (buffer-size) 60000)
	 (y-or-n-p
	  (format "The article is %d octets long.  Really post? "
		  (buffer-size)))
       t))
   ;; Check whether any new text has been added.
   (message-check 'new-text
     (or
      (not message-checksum)
      (not (eq (message-checksum) message-checksum))
      (y-or-n-p
       "It looks like no new text has been added.  Really post? ")))
   ;; Check the length of the signature.
   (message-check 'signature
     (goto-char (point-max))
     (if (or (not (re-search-backward message-signature-separator nil t))
	     (search-forward message-forward-end-separator nil t))
	 t
       (if (> (count-lines (point) (point-max)) 5)
	   (y-or-n-p
	    (format
	     "Your .sig is %d lines; it should be max 4.  Really post? "
	     (1- (count-lines (point) (point-max)))))
	 t)))))

(defun message-checksum ()
  "Return a \"checksum\" for the current buffer."
  (let ((sum 0))
    (save-excursion
      (goto-char (point-min))
      (re-search-forward
       (concat "^" (regexp-quote mail-header-separator) "$"))
      (while (not (eobp))
	(when (not (looking-at "[ \t\n]"))
 	  (setq sum (logxor (ash sum 1) (if (natnump sum) 0 1)
 			    (following-char))))
	(forward-char 1)))
    sum))

(defun message-do-fcc ()
  "Process Fcc headers in the current buffer."
  (let ((case-fold-search t)
	(buf (current-buffer))
	list file)
    (save-excursion
      (set-buffer (get-buffer-create " *message temp*"))
      (buffer-disable-undo (current-buffer))
      (erase-buffer)
      (insert-buffer-substring buf)
      (save-restriction
	(message-narrow-to-headers)
	(while (setq file (message-fetch-field "fcc"))
	  (push file list)
	  (message-remove-header "fcc" nil t)))
      (goto-char (point-min))
      (re-search-forward (concat "^" (regexp-quote mail-header-separator) "$"))
      (replace-match "" t t)
      ;; Process FCC operations.
      (while list
	(setq file (pop list))
	(if (string-match "^[ \t]*|[ \t]*\\(.*\\)[ \t]*$" file)
	    ;; Pipe the article to the program in question.
	    (call-process-region (point-min) (point-max) shell-file-name
				 nil nil nil shell-command-switch
				 (match-string 1 file))
	  ;; Save the article.
	  (setq file (expand-file-name file))
	  (unless (file-exists-p (file-name-directory file))
	    (make-directory (file-name-directory file) t))
	  (if (and message-fcc-handler-function
		   (not (eq message-fcc-handler-function 'rmail-output)))
	      (funcall message-fcc-handler-function file)
	    (if (and (file-readable-p file) (mail-file-babyl-p file))
		(rmail-output file 1 nil t)
	      (let ((mail-use-rfc822 t))
		(rmail-output file 1 t t))))))

      (kill-buffer (current-buffer)))))

(defun message-output (filename)
  "Append this article to Unix/babyl mail file.."
  (if (and (file-readable-p filename)
	   (mail-file-babyl-p filename))
      (gnus-output-to-rmail filename t)
    (gnus-output-to-mail filename t)))

(defun message-cleanup-headers ()
  "Do various automatic cleanups of the headers."
  ;; Remove empty lines in the header.
  (save-restriction
    (message-narrow-to-headers)
    ;; Remove blank lines.
    (while (re-search-forward "^[ \t]*\n" nil t)
      (replace-match "" t t))

    ;; Correct Newsgroups and Followup-To headers:  Change sequence of
    ;; spaces to comma and eliminate spaces around commas.  Eliminate
    ;; embedded line breaks.
    (goto-char (point-min))
    (while (re-search-forward "^\\(Newsgroups\\|Followup-To\\): +" nil t)
      (save-restriction
	(narrow-to-region
	 (point)
	 (if (re-search-forward "^[^ \t]" nil t)
	     (match-beginning 0)
	   (forward-line 1)
	   (point)))
	(goto-char (point-min))
	(while (re-search-forward "\n[ \t]+" nil t)
	  (replace-match " " t t))	;No line breaks (too confusing)
	(goto-char (point-min))
	(while (re-search-forward "[ \t\n]*,[ \t\n]*\\|[ \t]+" nil t)
	  (replace-match "," t t))
	(goto-char (point-min))
	;; Remove trailing commas.
	(when (re-search-forward ",+$" nil t)
	  (replace-match "" t t))))))

(defun message-make-date ()
  "Make a valid data header."
  (let ((now (current-time)))
    (timezone-make-date-arpa-standard
     (current-time-string now) (current-time-zone now))))

(defun message-make-message-id ()
  "Make a unique Message-ID."
  (concat "<" (message-unique-id)
	  (let ((psubject (save-excursion (message-fetch-field "subject")))
		(psupersedes
		 (save-excursion (message-fetch-field "supersedes"))))
	    (if (or
		 (and message-reply-headers
		      (mail-header-references message-reply-headers)
		      (mail-header-subject message-reply-headers)
		      psubject
		      (mail-header-subject message-reply-headers)
		      (not (string=
			    (message-strip-subject-re
			     (mail-header-subject message-reply-headers))
			    (message-strip-subject-re psubject))))
		 (and psupersedes
		      (string-match "_-_@" psupersedes)))
		"_-_" ""))
	  "@" (message-make-fqdn) ">"))

(defvar message-unique-id-char nil)

;; If you ever change this function, make sure the new version
;; cannot generate IDs that the old version could.
;; You might for example insert a "." somewhere (not next to another dot
;; or string boundary), or modify the "fsf" string.
(defun message-unique-id ()
  ;; Don't use microseconds from (current-time), they may be unsupported.
  ;; Instead we use this randomly inited counter.
  (setq message-unique-id-char
	(% (1+ (or message-unique-id-char (logand (random t) (1- (lsh 1 20)))))
	   ;; (current-time) returns 16-bit ints,
	   ;; and 2^16*25 just fits into 4 digits i base 36.
	   (* 25 25)))
  (let ((tm (current-time)))
    (concat
     (if (memq system-type '(ms-dos emx vax-vms))
	 (let ((user (downcase (user-login-name))))
	   (while (string-match "[^a-z0-9_]" user)
	     (aset user (match-beginning 0) ?_))
	   user)
       (message-number-base36 (user-uid) -1))
     (message-number-base36 (+ (car   tm)
			       (lsh (% message-unique-id-char 25) 16)) 4)
     (message-number-base36 (+ (nth 1 tm)
			       (lsh (/ message-unique-id-char 25) 16)) 4)
     ;; Append the newsreader name, because while the generated
     ;; ID is unique to this newsreader, other newsreaders might
     ;; otherwise generate the same ID via another algorithm.
     ".fsf")))

(defun message-number-base36 (num len)
  (if (if (< len 0)
	  (<= num 0)
	(= len 0))
      ""
    (concat (message-number-base36 (/ num 36) (1- len))
	    (char-to-string (aref "zyxwvutsrqponmlkjihgfedcba9876543210"
				  (% num 36))))))

(defun message-make-organization ()
  "Make an Organization header."
  (let* ((organization
	  (when message-user-organization
		(if (message-functionp message-user-organization)
		    (funcall message-user-organization)
		  message-user-organization))))
    (save-excursion
      (message-set-work-buffer)
      (cond ((stringp organization)
	     (insert organization))
	    ((and (eq t organization)
		  message-user-organization-file
		  (file-exists-p message-user-organization-file))
	     (insert-file-contents message-user-organization-file)))
      (goto-char (point-min))
      (while (re-search-forward "[\t\n]+" nil t)
	(replace-match "" t t))
      (unless (zerop (buffer-size))
	(buffer-string)))))

(defun message-make-lines ()
  "Count the number of lines and return numeric string."
  (save-excursion
    (save-restriction
      (widen)
      (goto-char (point-min))
      (re-search-forward
       (concat "^" (regexp-quote mail-header-separator) "$"))
      (forward-line 1)
      (int-to-string (count-lines (point) (point-max))))))

(defun message-make-in-reply-to ()
  "Return the In-Reply-To header for this message."
  (when message-reply-headers
    (let ((from (mail-header-from message-reply-headers))
	  (date (mail-header-date message-reply-headers)))
      (when from
	(let ((stop-pos
	       (string-match "  *at \\|  *@ \\| *(\\| *<" from)))
	  (concat (if (and stop-pos
			   (not (zerop stop-pos)))
		      (substring from 0 stop-pos) from)
		  "'s message of \""
		  (if (or (not date) (string= date ""))
		      "(unknown date)" date)
		  "\""))))))

(defun message-make-distribution ()
  "Make a Distribution header."
  (let ((orig-distribution (message-fetch-reply-field "distribution")))
    (cond ((message-functionp message-distribution-function)
	   (funcall message-distribution-function))
	  (t orig-distribution))))

(defun message-make-expires ()
  "Return an Expires header based on `message-expires'."
  (let ((current (current-time))
	(future (* 1.0 message-expires 60 60 24)))
    ;; Add the future to current.
    (setcar current (+ (car current) (round (/ future (expt 2 16)))))
    (setcar (cdr current) (+ (nth 1 current) (% (round future) (expt 2 16))))
    ;; Return the date in the future in UT.
    (timezone-make-date-arpa-standard
     (current-time-string current) (current-time-zone current) '(0 "UT"))))

(defun message-make-path ()
  "Return uucp path."
  (let ((login-name (user-login-name)))
    (cond ((null message-user-path)
	   (concat (system-name) "!" login-name))
	  ((stringp message-user-path)
	   ;; Support GENERICPATH.  Suggested by vixie@decwrl.dec.com.
	   (concat message-user-path "!" login-name))
	  (t login-name))))

(defun message-make-from ()
  "Make a From header."
  (let* ((style message-from-style)
	 (login (message-make-address))
	 (fullname
	  (or (and (boundp 'user-full-name)
		   user-full-name)
	      (user-full-name))))
    (when (string= fullname "&")
      (setq fullname (user-login-name)))
    (save-excursion
      (message-set-work-buffer)
      (cond
       ((or (null style)
	    (equal fullname ""))
	(insert login))
       ((or (eq style 'angles)
	    (and (not (eq style 'parens))
		 ;; Use angles if no quoting is needed, or if parens would
		 ;; need quoting too.
		 (or (not (string-match "[^- !#-'*+/-9=?A-Z^-~]" fullname))
		     (let ((tmp (concat fullname nil)))
		       (while (string-match "([^()]*)" tmp)
			 (aset tmp (match-beginning 0) ?-)
			 (aset tmp (1- (match-end 0)) ?-))
		       (string-match "[\\()]" tmp)))))
	(insert fullname)
	(goto-char (point-min))
	;; Look for a character that cannot appear unquoted
	;; according to RFC 822.
	(when (re-search-forward "[^- !#-'*+/-9=?A-Z^-~]" nil 1)
	  ;; Quote fullname, escaping specials.
	  (goto-char (point-min))
	  (insert "\"")
	  (while (re-search-forward "[\"\\]" nil 1)
	    (replace-match "\\\\\\&" t))
	  (insert "\""))
	(insert " <" login ">"))
       (t				; 'parens or default
	(insert login " (")
	(let ((fullname-start (point)))
	  (insert fullname)
	  (goto-char fullname-start)
	  ;; RFC 822 says \ and nonmatching parentheses
	  ;; must be escaped in comments.
	  ;; Escape every instance of ()\ ...
	  (while (re-search-forward "[()\\]" nil 1)
	    (replace-match "\\\\\\&" t))
	  ;; ... then undo escaping of matching parentheses,
	  ;; including matching nested parentheses.
	  (goto-char fullname-start)
	  (while (re-search-forward
		  "\\(\\=\\|[^\\]\\(\\\\\\\\\\)*\\)\\\\(\\(\\([^\\]\\|\\\\\\\\\\)*\\)\\\\)"
		  nil 1)
	    (replace-match "\\1(\\3)" t)
	    (goto-char fullname-start)))
	(insert ")")))
      (buffer-string))))

(defun message-make-sender ()
  "Return the \"real\" user address.
This function tries to ignore all user modifications, and
give as trustworthy answer as possible."
  (concat (user-login-name) "@" (system-name)))

(defun message-make-address ()
  "Make the address of the user."
  (or (message-user-mail-address)
      (concat (user-login-name) "@" (message-make-domain))))

(defun message-user-mail-address ()
  "Return the pertinent part of `user-mail-address'."
  (when user-mail-address
    (if (string-match " " user-mail-address)
	(nth 1 (mail-extract-address-components user-mail-address))
      user-mail-address)))

(defun message-make-fqdn ()
  "Return user's fully qualified domain name."
  (let ((system-name (system-name))
	(user-mail (message-user-mail-address)))
    (cond
     ((string-match "[^.]\\.[^.]" system-name)
      ;; `system-name' returned the right result.
      system-name)
     ;; Try `mail-host-address'.
     ((and (boundp 'mail-host-address)
	   (stringp mail-host-address)
	   (string-match "\\." mail-host-address))
      mail-host-address)
     ;; We try `user-mail-address' as a backup.
     ((and user-mail
	   (string-match "\\." user-mail)
	   (string-match "@\\(.*\\)\\'" user-mail))
      (match-string 1 user-mail))
     ;; Default to this bogus thing.
     (t
      (concat system-name ".i-did-not-set--mail-host-address--so-shoot-me")))))

(defun message-make-host-name ()
  "Return the name of the host."
  (let ((fqdn (message-make-fqdn)))
    (string-match "^[^.]+\\." fqdn)
    (substring fqdn 0 (1- (match-end 0)))))

(defun message-make-domain ()
  "Return the domain name."
  (or mail-host-address
      (message-make-fqdn)))

(defun message-generate-headers (headers)
  "Prepare article HEADERS.
Headers already prepared in the buffer are not modified."
  (save-restriction
    (message-narrow-to-headers)
    (let* ((Date (message-make-date))
	   (Message-ID (message-make-message-id))
	   (Organization (message-make-organization))
	   (From (message-make-from))
	   (Path (message-make-path))
	   (Subject nil)
	   (Newsgroups nil)
	   (In-Reply-To (message-make-in-reply-to))
	   (To nil)
	   (Distribution (message-make-distribution))
	   (Lines (message-make-lines))
	   (X-Newsreader message-newsreader)
	   (X-Mailer (and (not (message-fetch-field "X-Newsreader"))
			  message-mailer))
	   (Expires (message-make-expires))
	   (case-fold-search t)
	   header value elem)
      ;; First we remove any old generated headers.
      (let ((headers message-deletable-headers))
	(unless (buffer-modified-p)
	  (setq headers (delq 'Message-ID (copy-sequence headers))))
	(while headers
	  (goto-char (point-min))
	  (and (re-search-forward
		(concat "^" (symbol-name (car headers)) ": *") nil t)
	       (get-text-property (1+ (match-beginning 0)) 'message-deletable)
	       (message-delete-line))
	  (pop headers)))
      ;; Go through all the required headers and see if they are in the
      ;; articles already.  If they are not, or are empty, they are
      ;; inserted automatically - except for Subject, Newsgroups and
      ;; Distribution.
      (while headers
	(goto-char (point-min))
	(setq elem (pop headers))
	(if (consp elem)
	    (if (eq (car elem) 'optional)
		(setq header (cdr elem))
	      (setq header (car elem)))
	  (setq header elem))
	(when (or (not (re-search-forward
			(concat "^"
				(regexp-quote
				 (downcase
				  (if (stringp header)
				      header
				    (symbol-name header))))
				":")
			nil t))
		  (progn
		    ;; The header was found.  We insert a space after the
		    ;; colon, if there is none.
		    (if (/= (following-char) ? ) (insert " ") (forward-char 1))
		    ;; Find out whether the header is empty...
		    (looking-at "[ \t]*$")))
	  ;; So we find out what value we should insert.
	  (setq value
		(cond
		 ((and (consp elem) (eq (car elem) 'optional))
		  ;; This is an optional header.  If the cdr of this
		  ;; is something that is nil, then we do not insert
		  ;; this header.
		  (setq header (cdr elem))
		  (or (and (fboundp (cdr elem)) (funcall (cdr elem)))
		      (and (boundp (cdr elem)) (symbol-value (cdr elem)))))
		 ((consp elem)
		  ;; The element is a cons.  Either the cdr is a
		  ;; string to be inserted verbatim, or it is a
		  ;; function, and we insert the value returned from
		  ;; this function.
		  (or (and (stringp (cdr elem)) (cdr elem))
		      (and (fboundp (cdr elem)) (funcall (cdr elem)))))
		 ((and (boundp header) (symbol-value header))
		  ;; The element is a symbol.  We insert the value
		  ;; of this symbol, if any.
		  (symbol-value header))
		 (t
		  ;; We couldn't generate a value for this header,
		  ;; so we just ask the user.
		  (read-from-minibuffer
		   (format "Empty header for %s; enter value: " header)))))
	  ;; Finally insert the header.
	  (when (and value
		     (not (equal value "")))
	    (save-excursion
	      (if (bolp)
		  (progn
		    ;; This header didn't exist, so we insert it.
		    (goto-char (point-max))
		    (insert (if (stringp header) header (symbol-name header))
			    ": " value "\n")
		    (forward-line -1))
		;; The value of this header was empty, so we clear
		;; totally and insert the new value.
		(delete-region (point) (gnus-point-at-eol))
		(insert value))
	      ;; Add the deletable property to the headers that require it.
	      (and (memq header message-deletable-headers)
		   (progn (beginning-of-line) (looking-at "[^:]+: "))
		   (add-text-properties
		    (point) (match-end 0)
		    '(message-deletable t face italic) (current-buffer)))))))
      ;; Insert new Sender if the From is strange.
      (let ((from (message-fetch-field "from"))
	    (sender (message-fetch-field "sender"))
	    (secure-sender (message-make-sender)))
	(when (and from
		   (not (message-check-element 'sender))
		   (not (string=
			 (downcase
			  (cadr (mail-extract-address-components from)))
			 (downcase secure-sender)))
		   (or (null sender)
		       (not
			(string=
			 (downcase
			  (cadr (mail-extract-address-components sender)))
			 (downcase secure-sender)))))
	  (goto-char (point-min))
	  ;; Rename any old Sender headers to Original-Sender.
	  (when (re-search-forward "^\\(Original-\\)*Sender:" nil t)
	    (beginning-of-line)
	    (insert "Original-")
	    (beginning-of-line))
	  (when (or (message-news-p)
		    (string-match "@.+\\.." secure-sender))
	    (insert "Sender: " secure-sender "\n")))))))

(defun message-insert-courtesy-copy ()
  "Insert a courtesy message in mail copies of combined messages."
  (let (newsgroups)
    (save-excursion
      (save-restriction
	(message-narrow-to-headers)
	(when (setq newsgroups (message-fetch-field "newsgroups"))
	  (goto-char (point-max))
	  (insert "Posted-To: " newsgroups "\n")))
      (forward-line 1)
      (when message-courtesy-message
	(cond
	 ((string-match "%s" message-courtesy-message)
	  (insert (format message-courtesy-message newsgroups)))
	 (t
	  (insert message-courtesy-message)))))))

;;;
;;; Setting up a message buffer
;;;

(defun message-fill-address (header value)
  (save-restriction
    (narrow-to-region (point) (point))
    (insert (capitalize (symbol-name header))
	    ": "
	    (if (consp value) (car value) value)
	    "\n")
    (narrow-to-region (point-min) (1- (point-max)))
    (let (quoted last)
      (goto-char (point-min))
      (while (not (eobp))
	(skip-chars-forward "^,\"" (point-max))
	(if (or (= (following-char) ?,)
		(eobp))
	    (when (not quoted)
	      (if (and (> (current-column) 78)
		       last)
		  (progn
		    (save-excursion
		      (goto-char last)
		      (insert "\n\t"))
		    (setq last (1+ (point))))
		(setq last (1+ (point)))))
	  (setq quoted (not quoted)))
	(unless (eobp)
	  (forward-char 1))))
    (goto-char (point-max))
    (widen)
    (forward-line 1)))

(defun message-fill-header (header value)
  (let ((begin (point))
	(fill-column 990)
	(fill-prefix "\t"))
    (insert (capitalize (symbol-name header))
	    ": "
	    (if (consp value) (car value) value)
	    "\n")
    (save-restriction
      (narrow-to-region begin (point))
      (fill-region-as-paragraph begin (point))
      ;; Tapdance around looong Message-IDs.
      (forward-line -1)
      (when (looking-at "[ \t]*$")
	(message-delete-line))
      (goto-char begin)
      (re-search-forward ":" nil t)
      (when (looking-at "\n[ \t]+")
	(replace-match " " t t))
      (goto-char (point-max)))))

(defun message-shorten-references (header references)
  "Limit REFERENCES to be shorter than 988 characters."
  (let ((max 988)
	(cut 4)
	refs)
    (nnheader-temp-write nil
      (insert references)
      (goto-char (point-min))
      (while (re-search-forward "<[^>]+>" nil t)
	(push (match-string 0) refs))
      (setq refs (nreverse refs))
      (while (> (length (mapconcat 'identity refs " ")) max)
	(when (< (length refs) (1+ cut))
	  (decf cut))
	(setcdr (nthcdr cut refs) (cddr (nthcdr cut refs)))))
    (insert (capitalize (symbol-name header)) ": "
	    (mapconcat 'identity refs " ") "\n")))

(defun message-position-point ()
  "Move point to where the user probably wants to find it."
  (message-narrow-to-headers)
  (cond
   ((re-search-forward "^[^:]+:[ \t]*$" nil t)
    (search-backward ":" )
    (widen)
    (forward-char 1)
    (if (= (following-char) ? )
	(forward-char 1)
      (insert " ")))
   (t
    (goto-char (point-max))
    (widen)
    (forward-line 1)
    (unless (looking-at "$")
      (forward-line 2)))
   (sit-for 0)))

(defun message-buffer-name (type &optional to group)
  "Return a new (unique) buffer name based on TYPE and TO."
  (cond
   ;; Check whether `message-generate-new-buffers' is a function,
   ;; and if so, call it.
   ((message-functionp message-generate-new-buffers)
    (funcall message-generate-new-buffers type to group))
   ;; Generate a new buffer name The Message Way.
   (message-generate-new-buffers
    (generate-new-buffer-name
     (concat "*" type
	     (if to
		 (concat " to "
			 (or (car (mail-extract-address-components to))
			     to) "")
	       "")
	     (if (and group (not (string= group ""))) (concat " on " group) "")
	     "*")))
   ;; Use standard name.
   (t
    (format "*%s message*" type))))

(defun message-pop-to-buffer (name)
  "Pop to buffer NAME, and warn if it already exists and is modified."
  (let ((buffer (get-buffer name)))
    (if (and buffer
	     (buffer-name buffer))
	(progn
	  (set-buffer (pop-to-buffer buffer))
	  (when (and (buffer-modified-p)
		     (not (y-or-n-p
			   "Message already being composed; erase? ")))
	    (error "Message being composed")))
      (set-buffer (pop-to-buffer name)))
    (erase-buffer)
    (message-mode)))

(defun message-do-send-housekeeping ()
  "Kill old message buffers."
  ;; We might have sent this buffer already.  Delete it from the
  ;; list of buffers.
  (setq message-buffer-list (delq (current-buffer) message-buffer-list))
  (while (and message-max-buffers
              message-buffer-list
	      (>= (length message-buffer-list) message-max-buffers))
    ;; Kill the oldest buffer -- unless it has been changed.
    (let ((buffer (pop message-buffer-list)))
      (when (and (buffer-name buffer)
		 (not (buffer-modified-p buffer)))
	(kill-buffer buffer))))
  ;; Rename the buffer.
  (if message-send-rename-function
      (funcall message-send-rename-function)
    (when (string-match "\\`\\*" (buffer-name))
      (rename-buffer
       (concat "*sent " (substring (buffer-name) (match-end 0))) t)))
  ;; Push the current buffer onto the list.
  (when message-max-buffers
    (setq message-buffer-list
	  (nconc message-buffer-list (list (current-buffer))))))

(defvar mc-modes-alist)
(defun message-setup (headers &optional replybuffer actions)
  (when (and (boundp 'mc-modes-alist)
	     (not (assq 'message-mode mc-modes-alist)))
    (push '(message-mode (encrypt . mc-encrypt-message)
			 (sign . mc-sign-message))
	  mc-modes-alist))
  (when actions
    (setq message-send-actions actions))
  (setq message-reply-buffer replybuffer)
  (goto-char (point-min))
  ;; Insert all the headers.
  (mail-header-format
   (let ((h headers)
	 (alist message-header-format-alist))
     (while h
       (unless (assq (caar h) message-header-format-alist)
	 (push (list (caar h)) alist))
       (pop h))
     alist)
   headers)
  (delete-region (point) (progn (forward-line -1) (point)))
  (when message-default-headers
    (insert message-default-headers)
    (or (bolp) (insert ?\n)))
  (put-text-property
   (point)
   (progn
     (insert mail-header-separator "\n")
     (1- (point)))
   'read-only nil)
  (forward-line -1)
  (when (message-news-p)
    (when message-default-news-headers
      (insert message-default-news-headers)
      (or (bolp) (insert ?\n)))
    (when message-generate-headers-first
      (message-generate-headers
       (delq 'Lines
	     (delq 'Subject
		   (copy-sequence message-required-news-headers))))))
  (when (message-mail-p)
    (when message-default-mail-headers
      (insert message-default-mail-headers)
      (or (bolp) (insert ?\n)))
    (when message-generate-headers-first
      (message-generate-headers
       (delq 'Lines
	     (delq 'Subject
		   (copy-sequence message-required-mail-headers))))))
  (run-hooks 'message-signature-setup-hook)
  (message-insert-signature)
  (save-restriction
    (message-narrow-to-headers)
    (run-hooks 'message-header-setup-hook))
  (set-buffer-modified-p nil)
  (setq buffer-undo-list nil)
  (run-hooks 'message-setup-hook)
  (message-position-point)
  (undo-boundary))

(defun message-set-auto-save-file-name ()
  "Associate the message buffer with a file in the drafts directory."
  (when message-auto-save-directory
    (if (gnus-alive-p)
	(setq message-draft-article
	      (nndraft-request-associate-buffer "drafts"))
      (setq buffer-file-name (expand-file-name "*message*"
					       message-auto-save-directory))
      (setq buffer-auto-save-file-name (make-auto-save-file-name)))
    (clear-visited-file-modtime)))

(defun message-disassociate-draft ()
  "Disassociate the message buffer from the drafts directory."
  (when message-draft-article
    (nndraft-request-expire-articles
     (list message-draft-article) "drafts" nil t)))



;;;
;;; Commands for interfacing with message
;;;

;;;###autoload
(defun message-mail (&optional to subject
			       other-headers continue switch-function
			       yank-action send-actions)
  "Start editing a mail message to be sent.
OTHER-HEADERS is an alist of header/value pairs."
  (interactive)
  (let ((message-this-is-mail t))
    (message-pop-to-buffer (message-buffer-name "mail" to))
    (message-setup
     (nconc
      `((To . ,(or to "")) (Subject . ,(or subject "")))
      (when other-headers other-headers)))))

;;;###autoload
(defun message-news (&optional newsgroups subject)
  "Start editing a news article to be sent."
  (interactive)
  (let ((message-this-is-news t))
    (message-pop-to-buffer (message-buffer-name "news" nil newsgroups))
    (message-setup `((Newsgroups . ,(or newsgroups ""))
		     (Subject . ,(or subject ""))))))

;;;###autoload
(defun message-reply (&optional to-address wide)
  "Start editing a reply to the article in the current buffer."
  (interactive)
  (let ((cur (current-buffer))
	from subject date reply-to to cc
	references message-id follow-to
	(inhibit-point-motion-hooks t)
	mct never-mct gnus-warning)
    (save-restriction
      (message-narrow-to-head)
      ;; Allow customizations to have their say.
      (if (not wide)
	  ;; This is a regular reply.
	  (if (message-functionp message-reply-to-function)
	      (setq follow-to (funcall message-reply-to-function)))
	;; This is a followup.
	(if (message-functionp message-wide-reply-to-function)
	    (save-excursion
	      (setq follow-to
		    (funcall message-wide-reply-to-function)))))
      ;; Find all relevant headers we need.
      (setq from (message-fetch-field "from")
	    date (message-fetch-field "date")
	    subject (or (message-fetch-field "subject") "none")
	    to (message-fetch-field "to")
	    cc (message-fetch-field "cc")
	    mct (message-fetch-field "mail-copies-to")
	    reply-to (message-fetch-field "reply-to")
	    references (message-fetch-field "references")
	    message-id (message-fetch-field "message-id" t))
      ;; Remove any (buggy) Re:'s that are present and make a
      ;; proper one.
      (when (string-match message-subject-re-regexp subject)
	(setq subject (substring subject (match-end 0))))
      (setq subject (concat "Re: " subject))

      (when (and (setq gnus-warning (message-fetch-field "gnus-warning"))
		 (string-match "<[^>]+>" gnus-warning))
	(setq message-id (match-string 0 gnus-warning)))

      ;; Handle special values of Mail-Copies-To.
      (when mct
	(cond ((equal (downcase mct) "never")
	       (setq never-mct t)
	       (setq mct nil))
	      ((equal (downcase mct) "always")
	       (setq mct (or reply-to from)))))

      (unless follow-to
	(if (or (not wide)
		to-address)
	    (progn
	      (setq follow-to (list (cons 'To (or to-address reply-to from))))
	      (when (and wide mct)
		(push (cons 'Cc mct) follow-to)))
	  (let (ccalist)
	    (save-excursion
	      (message-set-work-buffer)
	      (unless never-mct
		(insert (or reply-to from "")))
	      (insert (if to (concat (if (bolp) "" ", ") to "") ""))
	      (insert (if mct (concat (if (bolp) "" ", ") mct) ""))
	      (insert (if cc (concat (if (bolp) "" ", ") cc) ""))
	      (goto-char (point-min))
	      (while (re-search-forward "[ \t]+" nil t)
		(replace-match " " t t))
	      ;; Remove addresses that match `rmail-dont-reply-to-names'.
	      (insert (prog1 (rmail-dont-reply-to (buffer-string))
			(erase-buffer)))
	      (goto-char (point-min))
	      ;; Perhaps Mail-Copies-To: never removed the only address?
	      (when (eobp)
		(insert (or reply-to from "")))
	      (setq ccalist
		    (mapcar
		     (lambda (addr)
		       (cons (mail-strip-quoted-names addr) addr))
		     (message-tokenize-header (buffer-string))))
	      (let ((s ccalist))
		(while s
		  (setq ccalist (delq (assoc (car (pop s)) s) ccalist)))))
	    (setq follow-to (list (cons 'To (cdr (pop ccalist)))))
	    (when ccalist
	      (let ((ccs (cons 'Cc (mapconcat
				    (lambda (addr) (cdr addr)) ccalist ", "))))
		(when (string-match "^ +" (cdr ccs))
		  (setcdr ccs (substring (cdr ccs) (match-end 0))))
		(push ccs follow-to))))))
      (widen))

    (message-pop-to-buffer (message-buffer-name
			    (if wide "wide reply" "reply") from
			    (if wide to-address nil)))

    (setq message-reply-headers
	  (vector 0 subject from date message-id references 0 0 ""))

    (message-setup
     `((Subject . ,subject)
       ,@follow-to
       ,@(if (or references message-id)
	     `((References . ,(concat (or references "") (and references " ")
				      (or message-id ""))))
	   nil))
     cur)))

;;;###autoload
(defun message-wide-reply (&optional to-address)
  "Make a \"wide\" reply to the message in the current buffer."
  (interactive)
  (message-reply to-address t))

;;;###autoload
(defun message-followup (&optional to-newsgroups)
  "Follow up to the message in the current buffer.
If TO-NEWSGROUPS, use that as the new Newsgroups line."
  (interactive)
  (let ((cur (current-buffer))
	from subject date reply-to mct
	references message-id follow-to
	(inhibit-point-motion-hooks t)
	(message-this-is-news t)
	followup-to distribution newsgroups gnus-warning posted-to)
    (save-restriction
      (narrow-to-region
       (goto-char (point-min))
       (if (search-forward "\n\n" nil t)
	   (1- (point))
	 (point-max)))
      (when (message-functionp message-followup-to-function)
	(setq follow-to
	      (funcall message-followup-to-function)))
      (setq from (message-fetch-field "from")
	    date (message-fetch-field "date")
	    subject (or (message-fetch-field "subject") "none")
	    references (message-fetch-field "references")
	    message-id (message-fetch-field "message-id" t)
	    followup-to (message-fetch-field "followup-to")
	    newsgroups (message-fetch-field "newsgroups")
	    posted-to (message-fetch-field "posted-to")
	    reply-to (message-fetch-field "reply-to")
	    distribution (message-fetch-field "distribution")
	    mct (message-fetch-field "mail-copies-to"))
      (when (and (setq gnus-warning (message-fetch-field "gnus-warning"))
		 (string-match "<[^>]+>" gnus-warning))
	(setq message-id (match-string 0 gnus-warning)))
      ;; Remove bogus distribution.
      (when (and (stringp distribution)
		 (let ((case-fold-search t))
		   (string-match "world" distribution)))
	(setq distribution nil))
      ;; Remove any (buggy) Re:'s that are present and make a
      ;; proper one.
      (when (string-match message-subject-re-regexp subject)
	(setq subject (substring subject (match-end 0))))
      (setq subject (concat "Re: " subject))
      (widen))

    (message-pop-to-buffer (message-buffer-name "followup" from newsgroups))

    (message-setup
     `((Subject . ,subject)
       ,@(cond
	  (to-newsgroups
	   (list (cons 'Newsgroups to-newsgroups)))
	  (follow-to follow-to)
	  ((and followup-to message-use-followup-to)
	   (list
	    (cond
	     ((equal (downcase followup-to) "poster")
	      (if (or (eq message-use-followup-to 'use)
		      (message-y-or-n-p "Obey Followup-To: poster? " t "\
You should normally obey the Followup-To: header.

`Followup-To: poster' sends your response via e-mail instead of news.

A typical situation where `Followup-To: poster' is used is when the poster
does not read the newsgroup, so he wouldn't see any replies sent to it."))
		  (progn
		    (setq message-this-is-news nil)
		    (cons 'To (or reply-to from "")))
		(cons 'Newsgroups newsgroups)))
	     (t
	      (if (or (equal followup-to newsgroups)
		      (not (eq message-use-followup-to 'ask))
		      (message-y-or-n-p
		       (concat "Obey Followup-To: " followup-to "? ") t "\
You should normally obey the Followup-To: header.

	`Followup-To: " followup-to "'
directs your response to " (if (string-match "," followup-to)
			       "the specified newsgroups"
			     "that newsgroup only") ".

If a message is posted to several newsgroups, Followup-To is often
used to direct the following discussion to one newsgroup only,
because discussions that are spread over several newsgroup tend to
be fragmented and very difficult to follow.

Also, some source/announcement newsgroups are not indented for discussion;
responses here are directed to other newsgroups."))
		  (cons 'Newsgroups followup-to)
		(cons 'Newsgroups newsgroups))))))
	  (posted-to
	   `((Newsgroups . ,posted-to)))
	  (t
	   `((Newsgroups . ,newsgroups))))
       ,@(and distribution (list (cons 'Distribution distribution)))
       ,@(if (or references message-id)
	     `((References . ,(concat (or references "") (and references " ")
				      (or message-id "")))))
       ,@(when (and mct
		    (not (equal (downcase mct) "never")))
	   (list (cons 'Cc (if (equal (downcase mct) "always")
			       (or reply-to from "")
			     mct)))))

     cur)

    (setq message-reply-headers
	  (vector 0 subject from date message-id references 0 0 ""))))


;;;###autoload
(defun message-cancel-news ()
  "Cancel an article you posted."
  (interactive)
  (unless (message-news-p)
    (error "This is not a news article; canceling is impossible"))
  (when (yes-or-no-p "Do you really want to cancel this article? ")
    (let (from newsgroups message-id distribution buf sender)
      (save-excursion
	;; Get header info. from original article.
	(save-restriction
	  (message-narrow-to-head)
	  (setq from (message-fetch-field "from")
		sender (message-fetch-field "sender")
		newsgroups (message-fetch-field "newsgroups")
		message-id (message-fetch-field "message-id" t)
		distribution (message-fetch-field "distribution")))
	;; Make sure that this article was written by the user.
	(unless (or (and sender
			 (string-equal
			  (downcase sender)
			  (downcase (message-make-sender))))
		    (string-equal
		     (downcase (cadr (mail-extract-address-components from)))
		     (downcase (cadr (mail-extract-address-components
				      (message-make-from))))))
	  (error "This article is not yours"))
	;; Make control message.
	(setq buf (set-buffer (get-buffer-create " *message cancel*")))
	(buffer-disable-undo (current-buffer))
	(erase-buffer)
	(insert "Newsgroups: " newsgroups "\n"
		"From: " (message-make-from) "\n"
		"Subject: cmsg cancel " message-id "\n"
		"Control: cancel " message-id "\n"
		(if distribution
		    (concat "Distribution: " distribution "\n")
		  "")
		mail-header-separator "\n"
		message-cancel-message)
	(message "Canceling your article...")
	(if (let ((message-syntax-checks
		   'dont-check-for-anything-just-trust-me))
	      (funcall message-send-news-function))
	    (message "Canceling your article...done"))
	(kill-buffer buf)))))

;;;###autoload
(defun message-supersede ()
  "Start composing a message to supersede the current message.
This is done simply by taking the old article and adding a Supersedes
header line with the old Message-ID."
  (interactive)
  (let ((cur (current-buffer))
	(sender (message-fetch-field "sender"))
	(from (message-fetch-field "from")))
    ;; Check whether the user owns the article that is to be superseded.
    (unless (or (and sender
		     (string-equal
		      (downcase sender)
		      (downcase (message-make-sender))))
		(string-equal
		 (downcase (cadr (mail-extract-address-components from)))
		 (downcase (cadr (mail-extract-address-components
				  (message-make-from))))))
      (error "This article is not yours"))
    ;; Get a normal message buffer.
    (message-pop-to-buffer (message-buffer-name "supersede"))
    (insert-buffer-substring cur)
    (message-narrow-to-head)
    ;; Remove unwanted headers.
    (when message-ignored-supersedes-headers
      (message-remove-header message-ignored-supersedes-headers t))
    (goto-char (point-min))
    (if (not (re-search-forward "^Message-ID: " nil t))
	(error "No Message-ID in this article")
      (replace-match "Supersedes: " t t))
    (goto-char (point-max))
    (insert mail-header-separator)
    (widen)
    (forward-line 1)))

;;;###autoload
(defun message-recover ()
  "Reread contents of current buffer from its last auto-save file."
  (interactive)
  (let ((file-name (make-auto-save-file-name)))
    (cond ((save-window-excursion
	     (if (not (eq system-type 'vax-vms))
		 (with-output-to-temp-buffer "*Directory*"
		   (buffer-disable-undo standard-output)
		   (let ((default-directory "/"))
		     (call-process
		      "ls" nil standard-output nil "-l" file-name))))
	     (yes-or-no-p (format "Recover auto save file %s? " file-name)))
	   (let ((buffer-read-only nil))
	     (erase-buffer)
	     (insert-file-contents file-name nil)))
	  (t (error "message-recover cancelled")))))

;;; Washing Subject:

(defun message-wash-subject (subject)
  "Remove junk like \"Re:\", \"(fwd)\", etc. that was added to the subject by previous forwarders, replyers, etc."
  (nnheader-temp-write nil
    (insert-string subject)
    (goto-char (point-min))
    ;; strip Re/Fwd stuff off the beginning
    (while (re-search-forward
	    "\\([Rr][Ee]:\\|[Ff][Ww][Dd]\\(\\[[0-9]*\\]\\)?:\\|[Ff][Ww]:\\)" nil t)
      (replace-match ""))

    ;; and gnus-style forwards [foo@bar.com] subject
    (goto-char (point-min))
    (while (re-search-forward "\\[[^ \t]*\\(@\\|\\.\\)[^ \t]*\\]" nil t)
      (replace-match ""))

    ;; and off the end
    (goto-char (point-max))
    (while (re-search-backward "([Ff][Ww][Dd])" nil t)
      (replace-match ""))

    ;; and finally, any whitespace that was left-over
    (goto-char (point-min))
    (while (re-search-forward "^[ \t]+" nil t)
      (replace-match ""))
    (goto-char (point-max))
    (while (re-search-backward "[ \t]+$" nil t)
      (replace-match ""))

    (buffer-string)))

;;; Forwarding messages.

(defun message-forward-subject-author-subject (subject)
  "Generate a subject for a forwarded message.
The form is: [Source] Subject, where if the original message was mail,
Source is the sender, and if the original message was news, Source is
the list of newsgroups is was posted to."
  (concat "["
	  (or (message-fetch-field
	       (if (message-news-p) "newsgroups" "from"))
	      "(nowhere)")
	  "] " subject))

(defun message-forward-subject-fwd (subject)
  "Generate a subject for a forwarded message.
The form is: Fwd: Subject, where Subject is the original subject of
the message."
  (concat "Fwd: " subject))

(defun message-make-forward-subject ()
  "Return a Subject header suitable for the message in the current buffer."
  (save-excursion
    (save-restriction
      (current-buffer)
      (message-narrow-to-head)
      (let ((funcs message-make-forward-subject-function)
	    (subject (if message-wash-forwarded-subjects
			 (message-wash-subject
			  (or (message-fetch-field "Subject") ""))
		       (or (message-fetch-field "Subject") ""))))
	;; Make sure funcs is a list.
	(and funcs
	     (not (listp funcs))
	     (setq funcs (list funcs)))
	;; Apply funcs in order, passing subject generated by previous
	;; func to the next one.
	(while funcs
	  (when (message-functionp (car funcs))
	    (setq subject (funcall (car funcs) subject)))
	  (setq funcs (cdr funcs)))
	subject))))

;;;###autoload
(defun message-forward (&optional news)
  "Forward the current message via mail.
Optional NEWS will use news to forward instead of mail."
  (interactive "P")
  (let ((cur (current-buffer))
	(subject (message-make-forward-subject))
	art-beg)
    (if news (message-news nil subject) (message-mail nil subject))
    ;; Put point where we want it before inserting the forwarded
    ;; message.
    (if message-signature-before-forwarded-message
	(goto-char (point-max))
      (message-goto-body))
    ;; Make sure we're at the start of the line.
    (unless (eolp)
      (insert "\n"))
    ;; Narrow to the area we are to insert.
    (narrow-to-region (point) (point))
    ;; Insert the separators and the forwarded buffer.
    (insert message-forward-start-separator)
    (setq art-beg (point))
    (insert-buffer-substring cur)
    (goto-char (point-max))
    (insert message-forward-end-separator)
    (set-text-properties (point-min) (point-max) nil)
    ;; Remove all unwanted headers.
    (goto-char art-beg)
    (narrow-to-region (point) (if (search-forward "\n\n" nil t)
				  (1- (point))
				(point)))
    (goto-char (point-min))
    (message-remove-header message-included-forward-headers t nil t)
    (widen)
    (message-position-point)))

;;;###autoload
(defun message-resend (address)
  "Resend the current article to ADDRESS."
  (interactive "sResend message to: ")
  (message "Resending message to %s..." address)
  (save-excursion
    (let ((cur (current-buffer))
	  beg)
      ;; We first set up a normal mail buffer.
      (set-buffer (get-buffer-create " *message resend*"))
      (buffer-disable-undo (current-buffer))
      (erase-buffer)
      (message-setup `((To . ,address)))
      ;; Insert our usual headers.
      (message-generate-headers '(From Date To))
      (message-narrow-to-headers)
      ;; Rename them all to "Resent-*".
      (while (re-search-forward "^[A-Za-z]" nil t)
	(forward-char -1)
	(insert "Resent-"))
      (widen)
      (forward-line)
      (delete-region (point) (point-max))
      (setq beg (point))
      ;; Insert the message to be resent.
      (insert-buffer-substring cur)
      (goto-char (point-min))
      (search-forward "\n\n")
      (forward-char -1)
      (save-restriction
	(narrow-to-region beg (point))
	(message-remove-header message-ignored-resent-headers t)
	(goto-char (point-max)))
      (insert mail-header-separator)
      ;; Rename all old ("Also-")Resent headers.
      (while (re-search-backward "^\\(Also-\\)*Resent-" beg t)
	(beginning-of-line)
	(insert "Also-"))
      ;; Quote any "From " lines at the beginning.
      (goto-char beg)
      (when (looking-at "From ")
	(replace-match "X-From-Line: "))
      ;; Send it.
      (message-send-mail)
      (kill-buffer (current-buffer)))
    (message "Resending message to %s...done" address)))

;;;###autoload
(defun message-bounce ()
  "Re-mail the current message.
This only makes sense if the current message is a bounce message than
contains some mail you have written which has been bounced back to
you."
  (interactive)
  (let ((cur (current-buffer))
	boundary)
    (message-pop-to-buffer (message-buffer-name "bounce"))
    (insert-buffer-substring cur)
    (undo-boundary)
    (message-narrow-to-head)
    (if (and (message-fetch-field "Mime-Version")
	     (setq boundary (message-fetch-field "Content-Type")))
	(if (string-match "boundary=\"\\([^\"]+\\)\"" boundary)
	    (setq boundary (concat (match-string 1 boundary) " *\n"
				   "Content-Type: message/rfc822"))
	  (setq boundary nil)))
    (widen)
    (goto-char (point-min))
    (search-forward "\n\n" nil t)
    (or (and boundary
	     (re-search-forward boundary nil t)
	     (forward-line 2))
	(and (re-search-forward message-unsent-separator nil t)
	     (forward-line 1))
	(re-search-forward "^Return-Path:.*\n" nil t))
    ;; We remove everything before the bounced mail.
    (delete-region
     (point-min)
     (if (re-search-forward "^[^ \n\t]+:" nil t)
	 (match-beginning 0)
       (point)))
    (save-restriction
      (message-narrow-to-head)
      (message-remove-header message-ignored-bounced-headers t)
      (goto-char (point-max))
      (insert mail-header-separator))
    (message-position-point)))

;;;
;;; Interactive entry points for new message buffers.
;;;

;;;###autoload
(defun message-mail-other-window (&optional to subject)
  "Like `message-mail' command, but display mail buffer in another window."
  (interactive)
  (let ((pop-up-windows t)
	(special-display-buffer-names nil)
	(special-display-regexps nil)
	(same-window-buffer-names nil)
	(same-window-regexps nil))
    (message-pop-to-buffer (message-buffer-name "mail" to)))
  (let ((message-this-is-mail t))
    (message-setup `((To . ,(or to "")) (Subject . ,(or subject ""))))))

;;;###autoload
(defun message-mail-other-frame (&optional to subject)
  "Like `message-mail' command, but display mail buffer in another frame."
  (interactive)
  (let ((pop-up-frames t)
	(special-display-buffer-names nil)
	(special-display-regexps nil)
	(same-window-buffer-names nil)
	(same-window-regexps nil))
    (message-pop-to-buffer (message-buffer-name "mail" to)))
  (let ((message-this-is-mail t))
    (message-setup `((To . ,(or to "")) (Subject . ,(or subject ""))))))

;;;###autoload
(defun message-news-other-window (&optional newsgroups subject)
  "Start editing a news article to be sent."
  (interactive)
  (let ((pop-up-windows t)
	(special-display-buffer-names nil)
	(special-display-regexps nil)
	(same-window-buffer-names nil)
	(same-window-regexps nil))
    (message-pop-to-buffer (message-buffer-name "news" nil newsgroups)))
  (let ((message-this-is-news t))
    (message-setup `((Newsgroups . ,(or newsgroups ""))
		     (Subject . ,(or subject ""))))))

;;;###autoload
(defun message-news-other-frame (&optional newsgroups subject)
  "Start editing a news article to be sent."
  (interactive)
  (let ((pop-up-frames t)
	(special-display-buffer-names nil)
	(special-display-regexps nil)
	(same-window-buffer-names nil)
	(same-window-regexps nil))
    (message-pop-to-buffer (message-buffer-name "news" nil newsgroups)))
  (let ((message-this-is-news t))
    (message-setup `((Newsgroups . ,(or newsgroups ""))
		     (Subject . ,(or subject ""))))))

;;; underline.el

;; This code should be moved to underline.el (from which it is stolen).

;;;###autoload
(defun bold-region (start end)
  "Bold all nonblank characters in the region.
Works by overstriking characters.
Called from program, takes two arguments START and END
which specify the range to operate on."
  (interactive "r")
  (save-excursion
    (let ((end1 (make-marker)))
      (move-marker end1 (max start end))
      (goto-char (min start end))
      (while (< (point) end1)
	(or (looking-at "[_\^@- ]")
	    (insert (following-char) "\b"))
	(forward-char 1)))))

;;;###autoload
(defun unbold-region (start end)
  "Remove all boldness (overstruck characters) in the region.
Called from program, takes two arguments START and END
which specify the range to operate on."
  (interactive "r")
  (save-excursion
    (let ((end1 (make-marker)))
      (move-marker end1 (max start end))
      (goto-char (min start end))
      (while (re-search-forward "\b" end1 t)
	(if (eq (following-char) (char-after (- (point) 2)))
	    (delete-char -2))))))

(defalias 'message-exchange-point-and-mark 'exchange-point-and-mark)

;; Support for toolbar
(when (string-match "XEmacs\\|Lucid" emacs-version)
  (require 'messagexmas))

;;; Group name completion.

(defvar message-newgroups-header-regexp
  "^\\(Newsgroups\\|Followup-To\\|Posted-To\\|Gcc\\):"
  "Regexp that match headers that lists groups.")

(defun message-tab ()
  "Expand group names in Newsgroups and Followup-To headers.
Do a `tab-to-tab-stop' if not in those headers."
  (interactive)
  (if (let ((mail-abbrev-mode-regexp message-newgroups-header-regexp))
	(mail-abbrev-in-expansion-header-p))
      (message-expand-group)
    (tab-to-tab-stop)))

(defvar gnus-active-hashtb)
(defun message-expand-group ()
  "Expand the group name under point."
  (let* ((b (save-excursion
	      (save-restriction
		(narrow-to-region
		 (save-excursion
		   (beginning-of-line)
		   (skip-chars-forward "^:")
		   (1+ (point)))
		 (point))
		(skip-chars-backward "^, \t\n") (point))))
	 (completion-ignore-case t)
	 (string (buffer-substring b (progn (skip-chars-forward "^,\t\n ")
					    (point))))
	 (hashtb (and (boundp 'gnus-active-hashtb) gnus-active-hashtb))
	 (completions (all-completions string hashtb))
	 comp)
    (delete-region b (point))
    (cond
     ((= (length completions) 1)
      (if (string= (car completions) string)
	  (progn
	    (insert string)
	    (message "Only matching group"))
	(insert (car completions))))
     ((and (setq comp (try-completion string hashtb))
	   (not (string= comp string)))
      (insert comp))
     (t
      (insert string)
      (if (not comp)
	  (message "No matching groups")
	(save-selected-window
	  (pop-to-buffer "*Completions*")
	  (buffer-disable-undo (current-buffer))
	  (let ((buffer-read-only nil))
	    (erase-buffer)
	    (let ((standard-output (current-buffer)))
	      (display-completion-list (sort completions 'string<)))
	    (goto-char (point-min))
	    (delete-region (point) (progn (forward-line 3) (point))))))))))

;;; Help stuff.

(defun message-talkative-question (ask question show &rest text)
  "Call FUNCTION with argument QUESTION; optionally display TEXT... args.
If SHOW is non-nil, the arguments TEXT... are displayed in a temp buffer.
The following arguments may contain lists of values."
  (if (and show
	   (setq text (message-flatten-list text)))
      (save-window-excursion
	(save-excursion
	  (with-output-to-temp-buffer " *MESSAGE information message*"
	    (set-buffer " *MESSAGE information message*")
	    (mapcar 'princ text)
	    (goto-char (point-min))))
	(funcall ask question))
    (funcall ask question)))

(defun message-flatten-list (list)
  "Return a new, flat list that contains all elements of LIST.

\(message-flatten-list '(1 (2 3 (4 5 (6))) 7))
=> (1 2 3 4 5 6 7)"
  (cond ((consp list)
	 (apply 'append (mapcar 'message-flatten-list list)))
	(list
	 (list list))))

(defun message-generate-new-buffer-clone-locals (name &optional varstr)
  "Create and return a buffer with a name based on NAME using generate-new-buffer.
Then clone the local variables and values from the old buffer to the
new one, cloning only the locals having a substring matching the
regexp varstr."
  (let ((oldbuf (current-buffer)))
    (save-excursion
      (set-buffer (generate-new-buffer name))
      (message-clone-locals oldbuf)
      (current-buffer))))

(defun message-clone-locals (buffer)
  "Clone the local variables from BUFFER to the current buffer."
  (let ((locals (save-excursion
		  (set-buffer buffer)
		  (buffer-local-variables)))
	(regexp "^gnus\\|^nn\\|^message"))
    (mapcar
     (lambda (local)
       (when (and (consp local)
		  (car local)
		  (string-match regexp (symbol-name (car local))))
	 (ignore-errors
	   (set (make-local-variable (car local))
		(cdr local)))))
     locals)))

;;; Miscellaneous functions

;; stolen (and renamed) from nnheader.el
(defun message-replace-chars-in-string (string from to)
  "Replace characters in STRING from FROM to TO."
  (let ((string (substring string 0))	;Copy string.
	(len (length string))
	(idx 0))
    ;; Replace all occurrences of FROM with TO.
    (while (< idx len)
      (when (= (aref string idx) from)
	(aset string idx to))
      (setq idx (1+ idx)))
    string))

(run-hooks 'message-load-hook)

(provide 'message)

;;; message.el ends here
