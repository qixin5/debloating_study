;;; rect.el --- rectangle functions for GNU Emacs.

;; Copyright (C) 1985, 1994 Free Software Foundation, Inc.

;; Maintainer: FSF
;; Keywords: internal

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

;; This package provides the operations on rectangles that are ocumented
;; in the Emacs manual.

;;; Code:

;;;###autoload
(defun move-to-column-force (column)
  "Move point to column COLUMN rigidly in the current line.
If COLUMN is within a multi-column character, replace it by
spaces and tab."
  (let ((col (move-to-column column t)))
    (if (> col column)
	(let (pos)
	  (delete-char -1)
	  (insert-char ?  (- column (current-column)))
	  (setq pos (point))
	  (indent-to col)
	  (goto-char pos)))
    column))

;; extract-rectangle-line stores lines into this list
;; to accumulate them for extract-rectangle and delete-extract-rectangle.
(defvar operate-on-rectangle-lines)

(defun operate-on-rectangle (function start end coerce-tabs)
  "Call FUNCTION for each line of rectangle with corners at START, END.
If COERCE-TABS is non-nil, convert multi-column characters
that span the starting or ending columns on any line
to multiple spaces before calling FUNCTION.
FUNCTION is called with three arguments:
 position of start of segment of this line within the rectangle,
 number of columns that belong to rectangle but are before that position,
 number of columns that belong to rectangle but are after point.
Point is at the end of the segment of this line within the rectangle."
  (let (startcol startlinepos endcol endlinepos)
    (save-excursion
     (goto-char start)
     (setq startcol (current-column))
     (beginning-of-line)
     (setq startlinepos (point)))
    (save-excursion
     (goto-char end)
     (setq endcol (current-column))
     (forward-line 1)
     (setq endlinepos (point-marker)))
    (if (< endcol startcol)
	(setq startcol (prog1 endcol (setq endcol startcol))))
    (save-excursion
     (goto-char startlinepos)
     (while (< (point) endlinepos)
       (let (startpos begextra endextra)
	 (if coerce-tabs
	     (move-to-column-force startcol)
	   (move-to-column startcol))
	 (setq begextra (- (current-column) startcol))
	 (setq startpos (point))
	 (if coerce-tabs
	     (move-to-column-force endcol)
	   (move-to-column endcol))
	 ;; If we overshot, move back one character
	 ;; so that endextra will be positive.
	 (if (and (not coerce-tabs) (> (current-column) endcol))
	     (backward-char 1))
	 (setq endextra (- endcol (current-column)))
	 (if (< begextra 0)
	     (setq endextra (+ endextra begextra)
		   begextra 0))
	 (funcall function startpos begextra endextra))
       (forward-line 1)))
    (- endcol startcol)))

(defun delete-rectangle-line (startdelpos ignore ignore)
  (delete-region startdelpos (point)))

(defun delete-extract-rectangle-line (startdelpos begextra endextra)
  (save-excursion
   (extract-rectangle-line startdelpos begextra endextra))
  (delete-region startdelpos (point)))

(defun extract-rectangle-line (startdelpos begextra endextra)
  (let ((line (buffer-substring startdelpos (point)))
	(end (point)))
    (goto-char startdelpos)
    (while (search-forward "\t" end t)
      (let ((width (- (current-column)
		      (save-excursion (forward-char -1)
				      (current-column)))))
	(setq line (concat (substring line 0 (- (point) end 1))
			   (spaces-string width)
			   (substring line (+ (length line) (- (point) end)))))))
    (if (or (> begextra 0) (> endextra 0))
	(setq line (concat (spaces-string begextra)
			   line
			   (spaces-string endextra))))
    (setq operate-on-rectangle-lines (cons line operate-on-rectangle-lines))))

(defconst spaces-strings
  '["" " " "  " "   " "    " "     " "      " "       " "        "])

(defun spaces-string (n)
  (if (<= n 8) (aref spaces-strings n)
    (let ((val ""))
      (while (> n 8)
	(setq val (concat "        " val)
	      n (- n 8)))
      (concat val (aref spaces-strings n)))))
    
;;;###autoload
(defun delete-rectangle (start end)
  "Delete (don't save) text in rectangle with point and mark as corners.
The same range of columns is deleted in each line starting with the line
where the region begins and ending with the line where the region ends."
  (interactive "r")
  (operate-on-rectangle 'delete-rectangle-line start end t))

;;;###autoload
(defun delete-extract-rectangle (start end)
  "Delete contents of rectangle and return it as a list of strings.
Arguments START and END are the corners of the rectangle.
The value is list of strings, one for each line of the rectangle."
  (let (operate-on-rectangle-lines)
    (operate-on-rectangle 'delete-extract-rectangle-line
			  start end t)
    (nreverse operate-on-rectangle-lines)))

;;;###autoload
(defun extract-rectangle (start end)
  "Return contents of rectangle with corners at START and END.
Value is list of strings, one for each line of the rectangle."
  (let (operate-on-rectangle-lines)
    (operate-on-rectangle 'extract-rectangle-line start end nil)
    (nreverse operate-on-rectangle-lines)))

(defvar killed-rectangle nil
  "Rectangle for yank-rectangle to insert.")

;;;###autoload
(defun kill-rectangle (start end)
  "Delete rectangle with corners at point and mark; save as last killed one.
Calling from program, supply two args START and END, buffer positions.
But in programs you might prefer to use `delete-extract-rectangle'."
  (interactive "r")
  (if buffer-read-only
      (progn
	(setq killed-rectangle (extract-rectangle start end))
	(barf-if-buffer-read-only)))
  (setq killed-rectangle (delete-extract-rectangle start end)))

;;;###autoload
(defun yank-rectangle ()
  "Yank the last killed rectangle with upper left corner at point."
  (interactive)
  (insert-rectangle killed-rectangle))

;;;###autoload
(defun insert-rectangle (rectangle)
  "Insert text of RECTANGLE with upper left corner at point.
RECTANGLE's first line is inserted at point, its second
line is inserted at a point vertically under point, etc.
RECTANGLE should be a list of strings.
After this command, the mark is at the upper left corner
and point is at the lower right corner."
  (let ((lines rectangle)
	(insertcolumn (current-column))
	(first t))
    (push-mark)
    (while lines
      (or first
	  (progn
	   (forward-line 1)
	   (or (bolp) (insert ?\n))
	   (move-to-column-force insertcolumn)))
      (setq first nil)
      (insert (car lines))
      (setq lines (cdr lines)))))

;;;###autoload
(defun open-rectangle (start end)
  "Blank out rectangle with corners at point and mark, shifting text right.
The text previously in the region is not overwritten by the blanks,
but instead winds up to the right of the rectangle."
  (interactive "r")
  (operate-on-rectangle 'open-rectangle-line start end nil)
  (goto-char start))

(defun open-rectangle-line (startpos begextra endextra)
  ;; Column where rectangle ends.
  (let ((endcol (+ (current-column) endextra))
	whitewidth)
    (goto-char startpos)
    ;; Column where rectangle begins.
    (let ((begcol (- (current-column) begextra)))
      (if (> begextra 0)
	  (move-to-column-force begcol))
      (skip-chars-forward " \t")
      ;; Width of whitespace to be deleted and recreated.
      (setq whitewidth (- (current-column) begcol)))
    ;; Delete the whitespace following the start column.
    (delete-region startpos (point))
    ;; Open the desired width, plus same amount of whitespace we just deleted.
    (indent-to (+ endcol whitewidth))))

;;;###autoload (defalias 'close-rectangle 'delete-whitespace-rectangle) ;; Old name
;;;###autoload
(defun delete-whitespace-rectangle (start end)
  "Delete all whitespace following a specified column in each line.
The left edge of the rectangle specifies the position in each line
at which whitespace deletion should begin.  On each line in the
rectangle, all continuous whitespace starting at that column is deleted."
  (interactive "r")
  (operate-on-rectangle '(lambda (startpos begextra endextra)
			   (save-excursion
			     (goto-char startpos)
			     (delete-region (point)
					    (progn
					      (skip-syntax-forward " ")
					      (point)))))
			start end t))

;; string-rectangle uses this variable to pass the string
;; to string-rectangle-line.
(defvar string-rectangle-string)

;;;###autoload
(defun string-rectangle (start end string)
  "Replace rectangle contents with STRING on each line.
The length of STRING need not be the same as the rectangle width.

Called from a program, takes three args; START, END and STRING."
  (interactive "r\nsString rectangle: ")
  (let ((string-rectangle-string string))
    (operate-on-rectangle 'string-rectangle-line start end t)))

(defun string-rectangle-line (startpos begextra endextra)
  (let (whitespace)
    ;; Delete the width of the rectangle.
    (delete-region startpos (point))
    ;; Compute horizontal width of following whitespace.
    (let ((ocol (current-column)))
      (skip-chars-forward " \t")
      (setq whitespace (- (current-column) ocol)))
    ;; Delete the following whitespace.
    (delete-region startpos (point))
    ;; Insert the desired string.
    (insert string-rectangle-string)
    ;; Insert the same width of whitespace that we had before.
    (indent-to (+ (current-column) whitespace))))

;;;###autoload
(defun clear-rectangle (start end)
  "Blank out rectangle with corners at point and mark.
The text previously in the region is overwritten by the blanks.
When called from a program, requires two args which specify the corners."
  (interactive "r")
  (operate-on-rectangle 'clear-rectangle-line start end t))

(defun clear-rectangle-line (startpos begextra endextra)
  ;; Find end of whitespace after the rectangle.
  (skip-chars-forward " \t")
  (let ((column (+ (current-column) endextra)))
    ;; Delete the text in the rectangle, and following whitespace.
    (delete-region (point)
                   (progn (goto-char startpos)
			  (skip-chars-backward " \t")
			  (point)))
    ;; Reindent out to same column that we were at.
    (indent-to column)))

(provide 'rect)

;;; rect.el ends here
