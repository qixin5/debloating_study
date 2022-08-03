;;; cal-move.el --- calendar functions for movement in the calendar

;; Copyright (C) 1995 Free Software Foundation, Inc.

;; Author: Edward M. Reingold <reingold@cs.uiuc.edu>
;; Keywords: calendar
;; Human-Keywords: calendar

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

;; This collection of functions implements movement in the calendar for
;; calendar.el.

;; Comments, corrections, and improvements should be sent to
;;  Edward M. Reingold               Department of Computer Science
;;  (217) 333-6733                   University of Illinois at Urbana-Champaign
;;  reingold@cs.uiuc.edu             1304 West Springfield Avenue
;;                                   Urbana, Illinois 61801

;;; Code:

(require 'calendar)

(defun calendar-goto-today ()
  "Reposition the calendar window so the current date is visible."
  (interactive)
  (let ((today (calendar-current-date)));; The date might have changed.
    (if (not (calendar-date-is-visible-p today))
        (generate-calendar-window)
      (update-calendar-mode-line)
      (calendar-cursor-to-visible-date today))))

(defun calendar-forward-month (arg)
  "Move the cursor forward ARG months.
Movement is backward if ARG is negative."
  (interactive "p")
  (calendar-cursor-to-nearest-date)
  (let* ((cursor-date (calendar-cursor-to-date t))
         (month (extract-calendar-month cursor-date))
         (day (extract-calendar-day cursor-date))
         (year (extract-calendar-year cursor-date)))
    (increment-calendar-month month year arg)
    (let ((last (calendar-last-day-of-month month year)))
      (if (< last day)
        (setq day last)))
    ;; Put the new month on the screen, if needed, and go to the new date.
    (let ((new-cursor-date (list month day year)))
      (if (not (calendar-date-is-visible-p new-cursor-date))
          (calendar-other-month month year))
      (calendar-cursor-to-visible-date new-cursor-date))))

(defun calendar-forward-year (arg)
  "Move the cursor forward by ARG years.
Movement is backward if ARG is negative."
  (interactive "p")
  (calendar-forward-month (* 12 arg)))

(defun calendar-backward-month (arg)
  "Move the cursor backward by ARG months.
Movement is forward if ARG is negative."
  (interactive "p")
  (calendar-forward-month (- arg)))

(defun calendar-backward-year (arg)
  "Move the cursor backward ARG years.
Movement is forward is ARG is negative."
  (interactive "p")
  (calendar-forward-month (* -12 arg)))

(defun scroll-calendar-left (arg)
  "Scroll the displayed calendar left by ARG months.
If ARG is negative the calendar is scrolled right.  Maintains the relative
position of the cursor with respect to the calendar as well as possible."
  (interactive "p")
  (calendar-cursor-to-nearest-date)
  (let ((old-date (calendar-cursor-to-date))
        (today (calendar-current-date)))
    (if (/= arg 0)
        (let ((month displayed-month)
	      (year displayed-year))
          (increment-calendar-month month year arg)
	  (generate-calendar-window month year)
          (calendar-cursor-to-visible-date
           (cond
            ((calendar-date-is-visible-p old-date) old-date)
            ((calendar-date-is-visible-p today) today)
            (t (list month 1 year))))))))

(defun scroll-calendar-right (arg)
  "Scroll the displayed calendar window right by ARG months.
If ARG is negative the calendar is scrolled left.  Maintains the relative
position of the cursor with respect to the calendar as well as possible."
  (interactive "p")
  (scroll-calendar-left (- arg)))

(defun scroll-calendar-left-three-months (arg)
  "Scroll the displayed calendar window left by 3*ARG months.
If ARG is negative the calendar is scrolled right.  Maintains the relative
position of the cursor with respect to the calendar as well as possible."
  (interactive "p")
  (scroll-calendar-left (* 3 arg)))

(defun scroll-calendar-right-three-months (arg)
  "Scroll the displayed calendar window right by 3*ARG months.
If ARG is negative the calendar is scrolled left.  Maintains the relative
position of the cursor with respect to the calendar as well as possible."
  (interactive "p")
  (scroll-calendar-left (* -3 arg)))

(defun calendar-cursor-to-nearest-date ()
  "Move the cursor to the closest date.
The position of the cursor is unchanged if it is already on a date.
Returns the list (month day year) giving the cursor position."
  (let ((date (calendar-cursor-to-date))
        (column (current-column)))
    (if date
        date
      (if (> 3 (count-lines (point-min) (point)))
          (progn
            (goto-line 3)
            (move-to-column column)))
      (if (not (looking-at "[0-9]"))
          (if (and (not (looking-at " *$"))
                   (or (< column 25)
                       (and (> column 27)
                            (< column 50))
                       (and (> column 52)
                            (< column 75))))
              (progn
                (re-search-forward "[0-9]" nil t)
                (backward-char 1))
            (re-search-backward "[0-9]" nil t)))
      (calendar-cursor-to-date))))

(defun calendar-forward-day (arg)
  "Move the cursor forward ARG days.
Moves backward if ARG is negative."
  (interactive "p")
  (if (/= 0 arg)
      (let*
          ((cursor-date (calendar-cursor-to-date))
           (cursor-date (if cursor-date
                            cursor-date
                          (if (> arg 0) (setq arg (1- arg)))
                          (calendar-cursor-to-nearest-date)))
           (new-cursor-date
            (calendar-gregorian-from-absolute
             (+ (calendar-absolute-from-gregorian cursor-date) arg)))
           (new-display-month (extract-calendar-month new-cursor-date))
           (new-display-year (extract-calendar-year new-cursor-date)))
        ;; Put the new month on the screen, if needed, and go to the new date.
        (if (not (calendar-date-is-visible-p new-cursor-date))
            (calendar-other-month new-display-month new-display-year))
        (calendar-cursor-to-visible-date new-cursor-date))))

(defun calendar-backward-day (arg)
  "Move the cursor back ARG days.
Moves forward if ARG is negative."
  (interactive "p")
  (calendar-forward-day (- arg)))

(defun calendar-forward-week (arg)
  "Move the cursor forward ARG weeks.
Moves backward if ARG is negative."
  (interactive "p")
  (calendar-forward-day (* arg 7)))

(defun calendar-backward-week (arg)
  "Move the cursor back ARG weeks.
Moves forward if ARG is negative."
  (interactive "p")
  (calendar-forward-day (* arg -7)))

(defun calendar-beginning-of-week (arg)
  "Move the cursor back ARG calendar-week-start-day's."
  (interactive "p")
  (calendar-cursor-to-nearest-date)
  (let ((day (calendar-day-of-week (calendar-cursor-to-date))))
    (calendar-backward-day
     (if (= day calendar-week-start-day)
         (* 7 arg)
       (+ (mod (- day calendar-week-start-day) 7)
          (* 7 (1- arg)))))))

(defun calendar-end-of-week (arg)
  "Move the cursor forward ARG calendar-week-start-day+6's."
  (interactive "p")
  (calendar-cursor-to-nearest-date)
  (let ((day (calendar-day-of-week (calendar-cursor-to-date))))
    (calendar-forward-day
     (if (= day (mod (1- calendar-week-start-day) 7))
         (* 7 arg)
       (+ (- 6 (mod (- day calendar-week-start-day) 7))
          (* 7 (1- arg)))))))

(defun calendar-beginning-of-month (arg)
  "Move the cursor backward ARG month beginnings."
  (interactive "p")
  (calendar-cursor-to-nearest-date)
  (let* ((date (calendar-cursor-to-date))
         (month (extract-calendar-month date))
         (day (extract-calendar-day date))
         (year (extract-calendar-year date)))
    (if (= day 1)
        (calendar-backward-month arg)
      (calendar-cursor-to-visible-date (list month 1 year))
      (calendar-backward-month (1- arg)))))

(defun calendar-end-of-month (arg)
  "Move the cursor forward ARG month ends."
  (interactive "p")
  (calendar-cursor-to-nearest-date)
  (let* ((date (calendar-cursor-to-date))
         (month (extract-calendar-month date))
         (day (extract-calendar-day date))
         (year (extract-calendar-year date))
         (last-day (calendar-last-day-of-month month year)))
    (if (/= day last-day)
        (progn
          (calendar-cursor-to-visible-date (list month last-day year))
          (setq arg (1- arg))))
    (increment-calendar-month month year arg)
    (let ((last-day (list
                     month
                     (calendar-last-day-of-month month year)
                     year)))
      (if (not (calendar-date-is-visible-p last-day))
          (calendar-other-month month year)
      (calendar-cursor-to-visible-date last-day)))))

(defun calendar-beginning-of-year (arg)
  "Move the cursor backward ARG year beginnings."
  (interactive "p")
  (calendar-cursor-to-nearest-date)
  (let* ((date (calendar-cursor-to-date))
         (month (extract-calendar-month date))
         (day (extract-calendar-day date))
         (year (extract-calendar-year date))
         (jan-first (list 1 1 year)))
    (if (and (= day 1) (= 1 month))
        (calendar-backward-month (* 12 arg))
      (if (and (= arg 1)
               (calendar-date-is-visible-p jan-first))
          (calendar-cursor-to-visible-date jan-first)
        (calendar-other-month 1 (- year (1- arg)))))))

(defun calendar-end-of-year (arg)
  "Move the cursor forward ARG year beginnings."
  (interactive "p")
  (calendar-cursor-to-nearest-date)
  (let* ((date (calendar-cursor-to-date))
         (month (extract-calendar-month date))
         (day (extract-calendar-day date))
         (year (extract-calendar-year date))
         (dec-31 (list 12 31 year)))
    (if (and (= day 31) (= 12 month))
        (calendar-forward-month (* 12 arg))
      (if (and (= arg 1)
               (calendar-date-is-visible-p dec-31))
          (calendar-cursor-to-visible-date dec-31)
        (calendar-other-month 12 (- year (1- arg)))
        (calendar-cursor-to-visible-date (list 12 31 displayed-year))))))

(defun calendar-cursor-to-visible-date (date)
  "Move the cursor to DATE that is on the screen."
  (let* ((month (extract-calendar-month date))
	 (day (extract-calendar-day date))
	 (year (extract-calendar-year date))
	 (first-of-month-weekday (calendar-day-of-week (list month 1 year))))
    (goto-line (+ 3
		  (/ (+ day  -1
                        (mod
                         (- (calendar-day-of-week (list month 1 year))
                            calendar-week-start-day)
                         7))
                     7)))
    (move-to-column (+ 6
		       (* 25
			  (1+ (calendar-interval
			       displayed-month displayed-year month year)))
		       (* 3 (mod
                             (- (calendar-day-of-week date)
                                calendar-week-start-day)
                             7))))))

(defun calendar-goto-date (date)
  "Move cursor to DATE."
  (interactive (list (calendar-read-date)))
  (let ((month (extract-calendar-month date))
        (year (extract-calendar-year date)))
    (if (not (calendar-date-is-visible-p date))
        (calendar-other-month
         (if (and (= month 1) (= year 1))
             2
           month)
         year)))
  (calendar-cursor-to-visible-date date))

(provide 'cal-move)

;;; cal-move.el ends here
