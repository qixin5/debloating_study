;;; gnus-mule.el --- Provide multilingual environment to GNUS

;; Copyright (C) 1995,1997 Free Software Foundation, Inc.
;; Copyright (C) 1995 Electrotechnical Laboratory, JAPAN.

;; Keywords: gnus, mule

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

;; This package enables Gnus to code convert automatically
;; accoding to a coding system specified for each news group.
;; If you want to specify some coding system for a specific news
;; group, add the fllowing line in your .emacs:
;;	(gnus-mule-add-group "xxx.yyy.zzz" 'some-coding-system)

;; By default, only few news groups are registered as the target of
;; code conversion.  So, each regional users had better set an
;; appropriate coding system for as below:
;;	(gnus-mule-add-group "" 'iso-2022-jp)  ;; the case for Japanese

(require 'nntp)

(defvar gnus-newsgroup-coding-systems nil
  "Assoc list of news groups vs corresponding coding systems.
Each element is has the form (PATTERN CODING-FOR-READ . CODING-FOR-POST),
where,
PATTERN is a regular expression matching news group names,
CODING-FOR-READ is a coding system of articles of the news groups, and
CODING-FOR-POST is a coding system to be encoded for posting articles
to the news groups.")

;;;###autoload
(defun gnus-mule-add-group (name coding-system)
  "Specify that articles of news group NAME are encoded in CODING-SYSTEM.
All news groups deeper than NAME are also the target.
If CODING-SYSTEM is a cons, the car and cdr part are regarded as
coding-system for reading and writing respectively."
  (if (not (consp coding-system))
      (setq coding-system (cons coding-system coding-system)))
  (setq name (concat "^" (regexp-quote name)))
  (let ((group (assoc name gnus-newsgroup-coding-systems)))
    (if group
	(setcdr group coding-system)
      (setq gnus-newsgroup-coding-systems
	    (cons (cons name coding-system) gnus-newsgroup-coding-systems)))))

(defun gnus-mule-get-coding-system (group)
  "Return the coding system for news group GROUP."
  (let ((groups gnus-newsgroup-coding-systems)
	(len -1)
	coding-system)
    ;; Find an entry which matches GROUP the best (i.e. longest).
    (while groups
      (if (and (string-match (car (car groups)) group)
	       (> (match-end 0) len))
	  (setq len (match-end 0)
		coding-system (cdr (car groups))))
      (setq groups (cdr groups)))
    coding-system))

;; Flag to indicate if article buffer is already decoded or not.")
(defvar gnus-mule-article-decoded nil)
;; Coding system for reading articles of the current news group.
(defvar gnus-mule-coding-system nil)
;;(make-variable-buffer-local 'gnus-mule-coding-system)
(defvar gnus-mule-subject nil)
(defvar gnus-mule-decoded-subject nil)
(defvar gnus-mule-original-subject nil)

;; Encode (if ENCODING is t) or decode (if ENCODING is nil)  the
;; region from START to END by CODING-SYSTEM.
(defun gnus-mule-code-convert1 (start end coding-system encoding)
  (if (< start end)
      (save-excursion
       (if encoding
	   (encode-coding-region start end coding-system)
	 (decode-coding-region start end coding-system)))))

;; Encode (if ENCODING is t) or decode (if ENCODING is nil) the
;; current buffer by CODING-SYSTEM.  Try not to move positions of
;; (window-start) and (point).
(defun gnus-mule-code-convert (coding-system encoding)
  (if coding-system
      (let ((win (get-buffer-window (current-buffer))))
	(if win
	    ;; We should keep (point) and (window-start).
	    (save-window-excursion
	      (select-window win)
	      (if encoding
		  ;; Simple way to assure point is on valid character boundary.
		  (beginning-of-line))
	      (gnus-mule-code-convert1 (point-min) (window-start)
				       coding-system encoding)
	      (gnus-mule-code-convert1 (window-start) (point)
				       coding-system encoding)
	      (gnus-mule-code-convert1 (point) (point-max)
				       coding-system encoding)
	      (if (not (pos-visible-in-window-p))
		  ;; point went out of window, move to the bottom of window.
		  (move-to-window-line -1)))
	  ;; No window for the buffer, no need to worry about (point)
	  ;; and (windos-start).
	  (gnus-mule-code-convert1 (point-min) (point-max)
				   coding-system encoding))
	)))

;; Set `gnus-mule-coding-system' to the coding system articles of the
;; current news group is encoded.   This function is set in
;; `gnus-parse-headers-hook'.
(defun gnus-mule-select-coding-system ()
  (if (gnus-buffer-live-p gnus-summary-buffer)
      (save-excursion
	(set-buffer gnus-summary-buffer)
	(let ((coding-system
	       (gnus-mule-get-coding-system gnus-newsgroup-name)))
	  (setq gnus-mule-coding-system
		(if (and coding-system (coding-system-p (car coding-system)))
		    (car coding-system)))))
    'binary))

;; Decode the current article.  This function is set in
;; `gnus-show-traditional-method'.
(defun gnus-mule-decode-article ()
  (gnus-mule-code-convert gnus-mule-coding-system nil)
  (setq gnus-mule-article-decoded t))

(defun gnus-mule-toggle-article-format ()
  "Toggle decoding/encoding of the current article buffer."
  (interactive)
  (let ((buf (get-buffer gnus-article-buffer)))
    (if (and gnus-mule-coding-system buf)
	(save-excursion
	  (set-buffer buf)
	  (let ((modif (buffer-modified-p))
		buffer-read-only)
	    (gnus-mule-code-convert gnus-mule-coding-system
				   gnus-mule-article-decoded)
	    (setq gnus-mule-article-decoded (not gnus-mule-article-decoded))
	    (set-buffer-modified-p modif))))))

;; Encode a news article before sending it.
(defun gnus-mule-message-send-news-function ()
  (let ((groups (message-fetch-field "newsgroups"))
	(idx 0)
	coding-system coding-system-list group-list)
    (if (not groups)
	;; We are not sending the current buffer via news.
	nil
      (while (string-match "[^ ,]+" groups idx)
	(setq idx (match-end 0))
	(setq coding-system
	      (cdr (gnus-mule-get-coding-system
		    (substring groups (match-beginning 0) idx))))
	(if (not (memq coding-system coding-system-list))
	    (setq coding-system-list (cons coding-system coding-system-list))))
      (if (> (length coding-system-list) 1)
	  (setq coding-system (read-coding-system "Coding system: ")))
      (if coding-system
	  (encode-coding-region (point-min) (point-max) coding-system)))))

;; Encode a mail message before sending it.
(defun gnus-mule-message-send-mail-function ()
  (let ((coding (if enable-multibyte-characters
		    (select-message-coding-system))))
    (if coding
	(encode-coding-region (point-min) (point-max) coding))))

;;;###autoload
(defun gnus-mule-initialize ()
  "Do several settings for GNUS to enable automatic code conversion."
  ;; Convenient key definitions
  (define-key gnus-article-mode-map "z" 'gnus-mule-toggle-article-format)
  (define-key gnus-summary-mode-map "z" 'gnus-mule-toggle-article-format)
  ;; Hook definition
  (add-hook 'gnus-parse-headers-hook 'gnus-mule-select-coding-system)
  (add-hook 'message-send-news-hook
	    'gnus-mule-message-send-news-function)
  (add-hook 'message-send-mail-hook
	    'gnus-mule-message-send-mail-function)
  (setq nnheader-file-coding-system 'binary
	nnmail-file-coding-system   'binary)
  )

(gnus-mule-add-group "" 'iso-latin-1)
(gnus-mule-add-group "fj" 'iso-2022-7bit)
(gnus-mule-add-group "tnn" 'iso-2022-7bit)
(gnus-mule-add-group "japan" 'iso-2022-7bit)
(gnus-mule-add-group "pin" 'iso-2022-7bit)
(gnus-mule-add-group "han" 'euc-kr)
(gnus-mule-add-group "alt.chinese.text" 'chinese-hz)
(gnus-mule-add-group "alt.hk" 'chinese-hz)
(gnus-mule-add-group "alt.chinese.text.big5" 'chinese-big5)
(gnus-mule-add-group "soc.culture.vietnamese" '(nil . vietnamese-viqr))
(gnus-mule-add-group "relcom" 'cyrillic-koi8)
(gnus-mule-add-group "tw." 'chinese-big5)

(provide 'gnus-mule)

;; gnus-mule.el ends here
