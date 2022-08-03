;;; cal-iso.el --- calendar functions for the ISO calendar.

;; Copyright (C) 1995, 1997 Free Software Foundation, Inc.

;; Author: Edward M. Reingold <reingold@cs.uiuc.edu>
;; Keywords: calendar
;; Human-Keywords: ISO calendar, calendar, diary

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

;; This collection of functions implements the features of calendar.el and
;; diary.el that deal with the ISO calendar.

;; Technical details of all the calendrical calculations can be found in
;; ``Calendrical Calculations'' by Nachum Dershowitz and Edward M. Reingold,
;; Cambridge University Press (1997).

;; Comments, corrections, and improvements should be sent to
;;  Edward M. Reingold               Department of Computer Science
;;  (217) 333-6733                   University of Illinois at Urbana-Champaign
;;  reingold@cs.uiuc.edu             1304 West Springfield Avenue
;;                                   Urbana, Illinois 61801

;;; Code:

(require 'calendar)

(defun calendar-absolute-from-iso (date)
  "The number of days elapsed between the Gregorian date 12/31/1 BC and DATE.
The `ISO year' corresponds approximately to the Gregorian year, but
weeks start on Monday and end on Sunday.  The first week of the ISO year is
the first such week in which at least 4 days are in a year.  The ISO
commercial DATE has the form (week day year) in which week is in the range
1..52 and day is in the range 0..6 (1 = Monday, 2 = Tuesday, ..., 0 =
Sunday).  The Gregorian date Sunday, December 31, 1 BC is imaginary."
  (let* ((week (extract-calendar-month date))
         (day (extract-calendar-day date))
         (year (extract-calendar-year date)))
    (+ (calendar-dayname-on-or-before
        1 (+ 3 (calendar-absolute-from-gregorian (list 1 1 year))))
       (* 7 (1- week))
       (if (= day 0) 6 (1- day)))))

(defun calendar-iso-from-absolute (date)
  "Compute the `ISO commercial date' corresponding to the absolute DATE.
The ISO year corresponds approximately to the Gregorian year, but weeks
start on Monday and end on Sunday.  The first week of the ISO year is the
first such week in which at least 4 days are in a year.  The ISO commercial
date has the form (week day year) in which week is in the range 1..52 and
day is in the range 0..6 (1 = Monday, 2 = Tuesday, ..., 0 = Sunday).  The
absolute date is the number of days elapsed since the (imaginary) Gregorian
date Sunday, December 31, 1 BC."
  (let* ((approx (extract-calendar-year
                  (calendar-gregorian-from-absolute (- date 3))))
         (year (+ approx
                  (calendar-sum y approx
                      (>= date (calendar-absolute-from-iso (list 1 1 (1+ y))))
                      1))))
    (list
     (1+ (/ (- date (calendar-absolute-from-iso (list 1 1 year))) 7))
     (% date 7)
     year)))

(defun calendar-iso-date-string (&optional date)
  "String of ISO date of Gregorian DATE.
Defaults to today's date if DATE is not given."
  (let* ((d (calendar-absolute-from-gregorian 
             (or date (calendar-current-date))))
         (day (% d 7))
         (iso-date (calendar-iso-from-absolute d)))
    (format "Day %s of week %d of %d"
            (if (zerop day) 7 day)
            (extract-calendar-month iso-date)
            (extract-calendar-year iso-date))))

(defun calendar-print-iso-date ()
  "Show equivalent ISO date for the date under the cursor."
  (interactive)
  (message "ISO date: %s"
           (calendar-iso-date-string (calendar-cursor-to-date t))))

(defun calendar-goto-iso-date (date &optional noecho)
  "Move cursor to ISO DATE; echo ISO date unless NOECHO is t."
  (interactive
   (let* ((today (calendar-current-date))
          (year (calendar-read
                 "ISO calendar year (>0): "
                 '(lambda (x) (> x 0))
                 (int-to-string (extract-calendar-year today))))
          (no-weeks (extract-calendar-month
                     (calendar-iso-from-absolute
                      (1-
                       (calendar-dayname-on-or-before
                        1 (calendar-absolute-from-gregorian
                           (list 1 4 (1+ year))))))))
          (week (calendar-read
                 (format "ISO calendar week (1-%d): " no-weeks)
                 '(lambda (x) (and (> x 0) (<= x no-weeks)))))
          (day (calendar-read
                "ISO day (1-7): "
                '(lambda (x) (and (<= 1 x) (<= x 7))))))
     (list (list week day year))))
  (calendar-goto-date (calendar-gregorian-from-absolute
                       (calendar-absolute-from-iso date)))
  (or noecho (calendar-print-iso-date)))

(defun diary-iso-date ()
  "ISO calendar equivalent of date diary entry."
  (format "ISO date: %s" (calendar-iso-date-string date)))

(provide 'cal-iso)

;;; cal-iso.el ends here
