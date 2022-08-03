;;; xt-mouse.el --- Support the mouse when emacs run in an xterm.

;; Copyright (C) 1994 Free Software Foundation

;; Author: Per Abrahamsen <abraham@dina.kvl.dk>
;; Keywords: mouse, terminals

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

;;; Comments:

;; Enable mouse support when running inside an xterm or Linux console.

;; This is actually useful when you are running X11 locally, but is
;; working on remote machine over a modem line or through a gateway.

;; It works by translating xterm escape codes into generic emacs mouse
;; events so it should work with any package that uses the mouse.

;; The xterm mouse escape codes are supposedly also supported by the
;; Linux console, but I have not been able to verify this.

;; You don't have to turn off xterm mode to use the normal xterm mouse
;; functionality, it is still available by holding down the SHIFT key
;; when you press the mouse button.

;;; Todo:

;; Support multi-click -- somehow.

;; Clicking on the mode-line does not work, although it should.

;;; Code: 

(define-key function-key-map "\e[M" 'xterm-mouse-translate)

(defvar xterm-mouse-last)

(defun xterm-mouse-translate (event)
  ;; Read a click and release event from XTerm.
  (save-excursion
    (save-window-excursion
      (deactivate-mark)
      (let* ((xterm-mouse-last)
	     (down (xterm-mouse-event))
	     (down-command (nth 0 down))
	     (down-data (nth 1 down))
	     (down-where (nth 1 down-data))
	     (down-binding (key-binding (if (symbolp down-where)
					    (vector down-where down-command)
					  (vector down-command)))))
	(or (and (eq (read-char) ?\e)
		 (eq (read-char) ?\[)
		 (eq (read-char) ?M))
	    (error "Unexpected escape sequence from XTerm"))
	(let* ((click (xterm-mouse-event))
	       (click-command (nth 0 click))
	       (click-data (nth 1 click))
	       (click-where (nth 1 click-data)))
	  (if (memq down-binding '(nil ignore))
	      (if (and (symbolp click-where)
		       (not (eq 'menu-bar click-where)))
		  (vector (list click-where click-data) click)
		(vector click))
	    (setq unread-command-events
		  (if (eq down-where click-where)
		      (list click)
		    (list
		     ;; Cheat `mouse-drag-region' with move event.
		     (list 'mouse-movement click-data)
		     ;; Generate a drag event.
		     (if (symbolp down-where)
			 0
		       (list (intern (format "drag-mouse-%d" (+ 1 xterm-mouse-last)))
			     down-data click-data))
		     )))
	    (if (and (symbolp down-where)
		     (not (eq 'menu-bar down-where)))
		(vector (list down-where down-data) down)
	      (vector down))))))))

(defvar xterm-mouse-x 0
  "Position of last xterm mouse event relative to the frame.")

(defvar xterm-mouse-y 0
  "Position of last xterm mouse event relative to the frame.")

;; Indicator for the xterm-mouse mode.
(defvar xterm-mouse-mode nil)

(defadvice mouse-position (around xterm-mouse activate)
  "Use last key from xterm-mouse-mode if available."
  (let ((answer ad-do-it))
    (setq ad-return-value
	  (if xterm-mouse-mode
	      (cons (car answer) (cons xterm-mouse-x xterm-mouse-y))
	    answer))))

(defun xterm-mouse-event ()
  ;; Convert XTerm mouse event to Emacs mouse event.
  (let* ((type (- (read-char) ? ))
	 (x (- (read-char) ?  1))
	 (y (- (read-char) ?  1))
	 (point (cons x y))
	 (window (window-at x y))
	 (where (if window 
		    (coordinates-in-window-p point window)
		  'menu-bar))
	 (pos (if (consp where)
		  (progn
		    (select-window window)
		    (goto-char (window-start window))
		    (move-to-window-line  (cdr where))
		    (move-to-column (+ (car where) (current-column)
				       (if (string-match "\\` \\*Minibuf"
							 (buffer-name))
					   (- (minibuffer-prompt-width))
					 0)
				       (max 0 (1- (window-hscroll)))))
		    (point))
		where))
	 (mouse (intern (if (eq type 3)
			    (format "mouse-%d" (+ 1 xterm-mouse-last))
			  (setq xterm-mouse-last type)
			  (format "down-mouse-%d" (+ 1 type))))))
    (setq xterm-mouse-x x
	  xterm-mouse-y y)
    (list mouse
	  (list window pos point
		(/ (nth 2 (current-time)) 1000)))))

(or (assq 'xterm-mouse-mode minor-mode-alist)
    (setq minor-mode-alist
	  (cons '(xterm-mouse-mode (" Mouse")) minor-mode-alist)))

;;;###autoload
(defun xterm-mouse-mode (arg)
  "Toggle XTerm mouse mode.
With prefix arg, turn XTerm mouse mode on iff arg is positive.

Turn it on to use emacs mouse commands, and off to use xterm mouse commands."
  (interactive "P")
  (if (or (and (null arg) xterm-mouse-mode)
	  (<= (prefix-numeric-value arg) 0))
      ;; Turn it off
      (if xterm-mouse-mode
	  (progn
	    (turn-off-xterm-mouse-tracking)
	    (setq xterm-mouse-mode nil)
	    (set-buffer-modified-p (buffer-modified-p))))
    ;;Turn it on
    (if xterm-mouse-mode
	()
      (setq xterm-mouse-mode t)
      (turn-on-xterm-mouse-tracking)
      (set-buffer-modified-p (buffer-modified-p)))))

(defun turn-on-xterm-mouse-tracking ()
  ;; Enable emacs mouse tracking in xterm.
  (if xterm-mouse-mode
      (send-string-to-terminal "\e[?1000h")))

(defun turn-off-xterm-mouse-tracking ()
  ;; Disable disable emacs mouse tracking in xterm.
  (if xterm-mouse-mode
      (send-string-to-terminal "\e[?1000l")))

;; Restore normal mouse behaviour outside Emacs.
(add-hook 'suspend-hook 'turn-off-xterm-mouse-tracking)
(add-hook 'suspend-resume-hook 'turn-on-xterm-mouse-tracking)
(add-hook 'kill-emacs-hook 'turn-off-xterm-mouse-tracking)

(provide 'xt-mouse)

;;; xt-mouse.el ends here
