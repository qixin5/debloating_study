;;; scroll-bar.el --- window system-independent scroll bar support.

;; Copyright (C) 1993, 1994, 1995 Free Software Foundation, Inc.

;; Maintainer: FSF
;; Keywords: hardware

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

;; Window-system-independent bindings of mouse clicks on the scroll bar.
;; Presently emulates the scroll-bar behavior of xterm.

;;; Code:

(require 'mouse)


;;;; Utilities.

(defun scroll-bar-event-ratio (event)
  "Given a scroll bar event EVENT, return the scroll bar position as a ratio.
The value is a cons cell (PORTION . WHOLE) containing two integers
whose ratio gives the event's vertical position in the scroll bar, with 0
referring to the top and 1 to the bottom."
  (nth 2 event))

(defun scroll-bar-scale (num-denom whole)
  "Given a pair (NUM . DENOM) and WHOLE, return (/ (* NUM WHOLE) DENOM).
This is handy for scaling a position on a scroll bar into real units,
like buffer positions.  If SCROLL-BAR-POS is the (PORTION . WHOLE) pair
from a scroll bar event, then (scroll-bar-scale SCROLL-BAR-POS
\(buffer-size)) is the position in the current buffer corresponding to
that scroll bar position."
  ;; We multiply before we divide to maintain precision.
  ;; We use floating point because the product of a large buffer size
  ;; with a large scroll bar portion can easily overflow a lisp int.
  (truncate (/ (* (float (car num-denom)) whole) (cdr num-denom))))


;;;; Helpful functions for enabling and disabling scroll bars.

(defvar scroll-bar-mode)

(defvar scroll-bar-mode-explicit nil
  "Non-nil means `set-scroll-bar-mode' should really do something.
This is nil while loading `scroll-bar.el', and t afterward.")

(defun set-scroll-bar-mode-1 (ignore value)
  (set-scroll-bar-mode value))

(defun set-scroll-bar-mode (value)
  "Set `scroll-bar-mode' to VALUE and put the new value into effect."
  (setq scroll-bar-mode value)

  (when scroll-bar-mode-explicit
    ;; Apply it to default-frame-alist.
    (let ((parameter (assq 'vertical-scroll-bars default-frame-alist)))
      (if (consp parameter)
	  (setcdr parameter scroll-bar-mode)
	(setq default-frame-alist
	      (cons (cons 'vertical-scroll-bars scroll-bar-mode)
		    default-frame-alist))))

    ;; Apply it to existing frames.
    (let ((frames (frame-list)))
      (while frames
	(modify-frame-parameters
	 (car frames)
	 (list (cons 'vertical-scroll-bars scroll-bar-mode)))
	(setq frames (cdr frames))))))

(defcustom scroll-bar-mode
  (if (eq system-type 'windows-nt) 'right 'left)
  "*Specify whether to have vertical scroll bars, and on which side.
Possible values are nil (no scroll bars), `left' (scroll bars on left)
and `right' (scroll bars on right).
To set this variable in a Lisp program, use `set-scroll-bar-mode'
to make it take real effect.
Setting the variable with a customization buffer also takes effect."
  :type '(choice (const :tag "none (nil)")
		 (const left)
		 (const right))
  :group 'frames
  :set 'set-scroll-bar-mode-1)

;; We just set scroll-bar-mode, but that was the default.
;; If it is set again, that is for real.
(setq scroll-bar-mode-explicit t)

(defun scroll-bar-mode (flag)
  "Toggle display of vertical scroll bars on all frames.
This command applies to all frames that exist and frames to be
created in the future.
With a numeric argument, if the argument is negative,
turn off scroll bars; otherwise, turn on scroll bars."
  (interactive "P")
  (if flag (setq flag (prefix-numeric-value flag)))

  ;; Tweedle the variable according to the argument.
  (set-scroll-bar-mode (if (null flag) (not scroll-bar-mode)
			 (and (or (not (numberp flag)) (>= flag 0))
			      (if (eq system-type 'windows-nt) 'right 'left)))))

(defun toggle-scroll-bar (arg)
  "Toggle whether or not the selected frame has vertical scroll bars.
With arg, turn vertical scroll bars on if and only if arg is positive.
The variable `scroll-bar-mode' controls which side the scroll bars are on
when they are turned on; if it is nil, they go on the left."
  (interactive "P")
  (if (null arg)
      (setq arg
	    (if (cdr (assq 'vertical-scroll-bars
			   (frame-parameters (selected-frame))))
		-1 1))
    (setq arg (prefix-numeric-value arg)))
  (modify-frame-parameters
   (selected-frame)
   (list (cons 'vertical-scroll-bars
	       (if (> arg 0)
		   (or scroll-bar-mode
		       (if (eq system-type 'windows-nt) 'right 'left)))))))

(defun toggle-horizontal-scroll-bar (arg)
  "Toggle whether or not the selected frame has horizontal scroll bars.
With arg, turn horizontal scroll bars on if and only if arg is positive.
Horizontal scroll bars aren't implemented yet."
  (interactive "P")
  (error "Horizontal scroll bars aren't implemented yet"))

;;;; Buffer navigation using the scroll bar.

;;; This was used for up-events on button 2, but no longer.
(defun scroll-bar-set-window-start (event)
  "Set the window start according to where the scroll bar is dragged.
EVENT should be a scroll bar click or drag event."
  (interactive "e")
  (let* ((end-position (event-end event))
	 (window (nth 0 end-position))
	 (portion-whole (nth 2 end-position)))
    (save-excursion
      (set-buffer (window-buffer window))
      (save-excursion
	(goto-char (+ (point-min)
		      (scroll-bar-scale portion-whole
					(- (point-max) (point-min)))))
	(beginning-of-line)
	(set-window-start window (point))))))

(defun scroll-bar-drag-position (portion-whole)
  "Calculate new window start for drag event."
  (save-excursion
    (goto-char (+ (point-min)
		  (scroll-bar-scale portion-whole
				    (- (point-max) (point-min)))))
    (beginning-of-line)
    (point)))

(defun scroll-bar-maybe-set-window-start (event)
  "Set the window start according to where the scroll bar is dragged.
Only change window start if the new start is substantially different.
EVENT should be a scroll bar click or drag event."
  (interactive "e")
  (let* ((end-position (event-end event))
	 (window (nth 0 end-position))
	 (portion-whole (nth 2 end-position))
	 (next-portion-whole (cons (1+ (car portion-whole))
				   (cdr portion-whole)))
	 portion-start
	 next-portion-start
	 (current-start (window-start window)))
    (save-excursion
      (set-buffer (window-buffer window))
      (setq portion-start (scroll-bar-drag-position portion-whole))
      (setq next-portion-start (max
				(scroll-bar-drag-position next-portion-whole)
				(1+ portion-start)))
      (if (or (>= current-start next-portion-start)
	      (< current-start portion-start))
	  (set-window-start window portion-start)
	;; Always set window start, to ensure scroll bar position is updated.
	(set-window-start window current-start)))))

;; Scroll the window to the proper position for EVENT.
(defun scroll-bar-drag-1 (event)
  (let* ((start-position (event-start event))
	 (window (nth 0 start-position))
	 (portion-whole (nth 2 start-position)))
    (save-excursion
      (set-buffer (window-buffer window))
      ;; Calculate position relative to the accessible part of the buffer.
      (goto-char (+ (point-min)
		    (scroll-bar-scale portion-whole
				      (- (point-max) (point-min)))))
      (beginning-of-line)
      (set-window-start window (point)))))

(defun scroll-bar-drag (event)
  "Scroll the window by dragging the scroll bar slider.
If you click outside the slider, the window scrolls to bring the slider there."
  (interactive "e")
  (let* (done
	 (echo-keystrokes 0)
	 (end-position (event-end event))
	 (window (nth 0 end-position))
	 (before-scroll))
    (with-current-buffer (window-buffer window)
      (setq before-scroll point-before-scroll))
    (save-selected-window
      (select-window window)
      (setq before-scroll
	    (or before-scroll (point))))
    (scroll-bar-drag-1 event)
    (track-mouse
      (while (not done)
	(setq event (read-event))
	(if (eq (car-safe event) 'mouse-movement)
	    (setq event (read-event)))
	(cond ((eq (car-safe event) 'scroll-bar-movement)
	       (scroll-bar-drag-1 event))
	      (t
	       ;; Exit when we get the drag event; ignore that event.
	       (setq done t)))))
    (sit-for 0)
    (with-current-buffer (window-buffer window)
      (setq point-before-scroll before-scroll))))

(defun scroll-bar-scroll-down (event)
  "Scroll the window's top line down to the location of the scroll bar click.
EVENT should be a scroll bar click."
  (interactive "e")
  (let* ((end-position (event-end event))
	 (window (nth 0 end-position))
	 (before-scroll))
    (with-current-buffer (window-buffer window)
      (setq before-scroll point-before-scroll))
    (unwind-protect
	(save-selected-window
	  (let ((portion-whole (nth 2 end-position)))
	    (select-window window)
	    (setq before-scroll
		  (or before-scroll (point)))
	    (scroll-down
	     (scroll-bar-scale portion-whole (1- (window-height)))))
	  (sit-for 0))
      (with-current-buffer (window-buffer window)
	(setq point-before-scroll before-scroll)))))

(defun scroll-bar-scroll-up (event)
  "Scroll the line next to the scroll bar click to the top of the window.
EVENT should be a scroll bar click."
  (interactive "e")
  (let* ((end-position (event-end event))
	 (window (nth 0 end-position))
	 (before-scroll))
    (with-current-buffer (window-buffer window)
      (setq before-scroll point-before-scroll))
    (unwind-protect
	(save-selected-window
	  (let ((portion-whole (nth 2 end-position)))
	    (select-window window)
	    (setq before-scroll
		  (or before-scroll (point)))
	    (scroll-up
	     (scroll-bar-scale portion-whole (1- (window-height)))))
	  (sit-for 0))
      (with-current-buffer (window-buffer window)
	(setq point-before-scroll before-scroll)))))


;;;; Bindings.

;;; For now, we'll set things up to work like xterm.
(global-set-key [vertical-scroll-bar mouse-1] 'scroll-bar-scroll-up)
(global-set-key [vertical-scroll-bar drag-mouse-1] 'scroll-bar-scroll-up)

(global-set-key [vertical-scroll-bar down-mouse-2] 'scroll-bar-drag)

(global-set-key [vertical-scroll-bar mouse-3] 'scroll-bar-scroll-down)
(global-set-key [vertical-scroll-bar drag-mouse-3] 'scroll-bar-scroll-down)


(provide 'scroll-bar)

;;; scroll-bar.el ends here
