;;; china-util.el --- utilities for Chinese

;; Copyright (C) 1995 Electrotechnical Laboratory, JAPAN.
;; Licensed to the Free Software Foundation.

;; Keywords: mule, multilingual, Chinese

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

;;;###autoload
(defun setup-chinese-gb-environment ()
  "Setup multilingual environment (MULE) for Chinese GB2312 users."
  (interactive)
  (set-language-environment "Chinese-GB"))

;;;###autoload
(defun setup-chinese-big5-environment ()
  "Setup multilingual environment (MULE) for Chinese Big5 users."
  (interactive)
  (set-language-environment "Chinese-BIG5"))

;;;###autoload
(defun setup-chinese-cns-environment ()
  "Setup multilingual environment (MULE) for Chinese CNS11643 family users."
  (interactive)
  (set-language-environment "Chinese-CNS"))

;; Hz/ZW encoding stuffs

;; HZ is an encoding method for Chinese character set GB2312 used
;; widely in Internet.  It is very similar to 7-bit environment of
;; ISO-2022.  The difference is that HZ uses the sequence "~{" and
;; "~}" for designating GB2312 and ASCII respectively, hence, it
;; doesn't uses ESC (0x1B) code.

;; ZW is another encoding method for Chinese character set GB2312.  It
;; encodes Chinese characters line by line by starting each line with
;; the sequence "zW".  It also uses only 7-bit as HZ.

;; ISO-2022 escape sequence to designate GB2312.
(defvar iso2022-gb-designation "\e$A")
;; HZ escape sequence to designate GB2312.
(defvar hz-gb-designnation "~{")
;; ISO-2022 escape sequence to designate ASCII.
(defvar iso2022-ascii-designation "\e(B")
;; HZ escape sequence to designate ASCII.
(defvar hz-ascii-designnation "~}")
;; Regexp of ZW sequence to start GB2312.
(defvar zw-start-gb "^zW")
;; Regexp for start of GB2312 in an encoding mixture of HZ and ZW.
(defvar hz/zw-start-gb
  (concat hz-gb-designnation "\\|" zw-start-gb "\\|[^\0-\177]"))

(defvar decode-hz-line-continuation nil
  "Flag to tell if we should care line continuation convention of Hz.")

(defconst hz-set-msb-table
  (let ((str (make-string 127 0))
	(i 0))
    (while (< i 33)
      (aset str i i)
      (setq i (1+ i)))
    (while (< i 127)
      (aset str i (+ i 128))
      (setq i (1+ i)))
    str))

;;;###autoload
(defun decode-hz-region (beg end)
  "Decode HZ/ZW encoded text in the current region.
Return the length of resulting text."
  (interactive "r")
  (save-excursion
    (save-restriction
      (let (pos ch)
	(narrow-to-region beg end)

	;; We, at first, convert HZ/ZW to `euc-china',
	;; then decode it.

	;; "~\n" -> "\n", "~~" -> "~"
	(goto-char (point-min))
	(while (search-forward "~" nil t)
	  (setq ch (following-char))
	  (if (or (= ch ?\n) (= ch ?~)) (delete-char -1)))

	;; "^zW...\n" -> Chinese GB2312
	;; "~{...~}"  -> Chinese GB2312
	(goto-char (point-min))
	(setq beg nil)
	(while (re-search-forward hz/zw-start-gb nil t)
	  (setq pos (match-beginning 0)
		ch (char-after pos))
	  ;; Record the first position to start conversion.
	  (or beg (setq beg pos))
	  (end-of-line)
	  (setq end (point))
	  (if (>= ch 128)		; 8bit GB2312
	      nil
	    (goto-char pos)
	    (delete-char 2)
	    (setq end (- end 2))
	    (if (= ch ?z)			; ZW -> euc-china
		(progn
		  (translate-region (point) end hz-set-msb-table)
		  (goto-char end))
	      (if (search-forward hz-ascii-designnation
				  (if decode-hz-line-continuation nil end)
				  t)
		  (delete-char -2))
	      (setq end (point))
	      (translate-region pos (point) hz-set-msb-table))))
	(if beg
	    (decode-coding-region beg end 'euc-china)))
      (- (point-max) (point-min)))))

;;;###autoload
(defun decode-hz-buffer ()
  "Decode HZ/ZW encoded text in the current buffer."
  (interactive)
  (decode-hz-region (point-min) (point-max)))

;;;###autoload
(defun encode-hz-region (beg end)
  "Encode the text in the current region to HZ.
Return the length of resulting text."
  (interactive "r")
  (save-excursion
    (save-restriction
      (narrow-to-region beg end)

      ;; "~" -> "~~"
      (goto-char (point-min))
      (while (search-forward "~" nil t)	(insert ?~))

      ;; Chinese GB2312 -> "~{...~}"
      (goto-char (point-min))
      (if (re-search-forward "\\cc" nil t)
	  (let (pos)
	    (goto-char (setq pos (match-beginning 0)))
	    (encode-coding-region pos (point-max) 'iso-2022-7bit)
	    (goto-char pos)
	    (while (search-forward iso2022-gb-designation nil t)
	      (delete-char -3)
	      (insert hz-gb-designnation))
	    (goto-char pos)
	    (while (search-forward iso2022-ascii-designation nil t)
	      (delete-char -3)
	      (insert hz-ascii-designnation))))
      (- (point-max) (point-min)))))

;;;###autoload
(defun encode-hz-buffer ()
  "Encode the text in the current buffer to HZ."
  (interactive)
  (encode-hz-region (point-min) (point-max)))

;;
(provide 'china-util)

;;; china-util.el ends here
