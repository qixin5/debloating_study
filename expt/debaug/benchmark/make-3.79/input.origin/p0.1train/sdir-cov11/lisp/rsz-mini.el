;;; rsz-mini.el --- dynamically resize minibuffer to display entire contents

;; Copyright (C) 1990, 1993-1995, 1997 Free Software Foundation, Inc.

;; Author: Noah Friedman <friedman@splode.com>
;;         Roland McGrath <roland@gnu.org>
;; Maintainer: Noah Friedman <friedman@splode.com>
;; Keywords: minibuffer, window, frame, display

;; $Id: rsz-mini.el,v 1.26 1999/04/27 18:59:36 fx Exp $

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

;; This package allows the entire contents (or as much as possible) of the
;; minibuffer to be visible at once when typing.  As the end of a line is
;; reached, the minibuffer will resize itself.  When the user is done
;; typing, the minibuffer will return to its original size.

;; In window systems where it is possible to have a frame in which the
;; minibuffer is the only window, the frame itself can be resized.  In
;; Emacs 19.22 and earlier, the frame may not be properly returned to
;; its original size after it ceases to be active because
;; `minibuffer-exit-hook' didn't exist until version 19.23.
;;
;; Prior to Emacs 19.26, minibuffer-exit-hook wasn't called after exiting
;; from the minibuffer by hitting the quit char.  That meant that the
;; frame size restoration function wasn't being called in that case.  In
;; 19.26 or later, minibuffer-exit-hook should be called anyway.

;; Note that the minibuffer and echo area are not the same!  They simply
;; happen to occupy roughly the same place on the frame.  Messages put in
;; the echo area will not cause any resizing by this package.

;; This package is considered a minor mode but it doesn't put anything in
;; minor-mode-alist because this mode is specific to the minibuffer, which
;; has no mode line.

;; To enable or disable this mode, use M-x resize-minibuffer-mode.

;;; Code:


(defgroup resize-minibuffer nil
  "Dynamically resize minibuffer to display entire contents"
  :group 'frames)

;;;###autoload
(defcustom resize-minibuffer-mode nil
  "Toggle resizing the minibuffer so its entire contents are visible.
Setting this variable directly does not take effect;
use either \\[customize] or the function `resize-minibuffer-mode'."
  :set (lambda (symbol value)
	 (resize-minibuffer-mode (if value 1 -1)))
  :initialize 'custom-initialize-default
  :type 'boolean
  :group 'resize-minibuffer
  :require 'rsz-mini)

;;;###autoload
(defcustom resize-minibuffer-window-max-height nil
  "*Maximum size the minibuffer window is allowed to become.
If less than 1 or not a number, the limit is the height of the frame in
which the active minibuffer window resides."
  :type '(choice (const nil) integer)
  :group 'resize-minibuffer)

;;;###autoload
(defcustom resize-minibuffer-window-exactly t
  "*Allow making minibuffer exactly the size to display all its contents.
If `nil', the minibuffer window can temporarily increase in size but
never get smaller while it is active.  Any other value allows exact
resizing."
  :type 'boolean
  :group 'resize-minibuffer)

;;;###autoload
(defcustom resize-minibuffer-frame nil
  "*Allow changing the frame height of minibuffer frames.
If non-`nil' and the active minibuffer is the sole window in its frame,
allow changing the frame height."
  :type 'boolean
  :group 'resize-minibuffer)

;;;###autoload
(defcustom resize-minibuffer-frame-max-height nil
  "*Maximum size the minibuffer frame is allowed to become.
If less than 1 or not a number, there is no limit.")

;;;###autoload
(defcustom resize-minibuffer-frame-exactly t
  "*Allow making minibuffer frame exactly the size to display all its contents.
If `nil', the minibuffer frame can temporarily increase in size but
never get smaller while it is active.  Any other value allows exact
resizing."
  :type 'boolean
  :group 'resize-minibuffer)

;; Variable used to store the height of the minibuffer frame
;; on entry, so it can be restored on exit.  It is made local before it is
;; modified.  Do not use it yourself.
(defvar resize-minibuffer-frame-original-height nil)


;;;###autoload
(defun resize-minibuffer-mode (&optional prefix)
  "Toggle resize-minibuffer mode.
With argument, enable resize-minibuffer mode if and only if argument
is positive.

When this minor mode is enabled, the minibuffer is dynamically resized to
contain the entire region of text put in it as you type.

The variable `resize-minibuffer-mode' is set to t or nil depending on
whether this mode is active or not.

The maximum height to which the minibuffer can grow is controlled by the
variable `resize-minibuffer-window-max-height'.

The variable `resize-minibuffer-window-exactly' determines whether the
minibuffer window should ever be shrunk to make it no larger than needed to
display its contents.

When using a window system, it is possible for a minibuffer to be the sole
window in a frame.  Since that window is already its maximum size, the only
way to make more text visible at once is to increase the size of the frame.
The variable `resize-minibuffer-frame' controls whether this should be
done.  The variables `resize-minibuffer-frame-max-height' and
`resize-minibuffer-frame-exactly' are analogous to their window
counterparts."
  (interactive "P")
  (setq resize-minibuffer-mode
	(if prefix
	    (> (prefix-numeric-value prefix) 0)
	  (not resize-minibuffer-mode)))
  (add-hook 'minibuffer-setup-hook 'resize-minibuffer-setup))

(defun resize-minibuffer-setup ()
  (cond
   (resize-minibuffer-mode
    (cond
     ((and window-system
           (eq 'only (cdr (assq 'minibuffer (frame-parameters)))))
      ;; Checking for resize-minibuffer-frame is done outside the cond
      ;; predicate because that should always be t if this is a minibuffer
      ;; frame; it just shouldn't do anything if this flag is nil.
      (and resize-minibuffer-frame
           (progn
             ;; Can't trust the height stored in minibuffer-frame-alist
             ;; since the frame can be resized by the window manager and
             ;; that variable isn't updated.
             (make-local-variable 'resize-minibuffer-frame-original-height)
             (setq resize-minibuffer-frame-original-height (frame-height))

             (make-local-hook 'post-command-hook)
             (add-hook 'post-command-hook 'resize-minibuffer-frame 'append t)

             (make-local-hook 'minibuffer-exit-hook)
             (add-hook 'minibuffer-exit-hook 'resize-minibuffer-frame-restore
		       nil t)

             (resize-minibuffer-frame))))
     (t
      (make-local-variable 'post-command-hook)
      ;; Copy this because add-hook modifies the list structure.
      (setq post-command-hook (copy-sequence post-command-hook))
      (add-hook 'post-command-hook 'resize-minibuffer-window 'append)

      (make-local-variable 'minibuffer-exit-hook)
      (add-hook 'minibuffer-exit-hook 'resize-minibuffer-window-restore)

      (resize-minibuffer-window))))))

(defun resize-minibuffer-count-window-lines (&optional start end)
  "Return number of window lines occupied by text in region.
The number of window lines may be greater than the number of actual lines
in the buffer if any wrap on the display due to their length.

Optional arguments START and END default to point-min and point-max,
respectively."
  (or start (setq start (point-min)))
  (or end   (setq end   (point-max)))
  (if (= start end)
      0
    (save-excursion
      (save-restriction
        (widen)
	(narrow-to-region start end)
	(goto-char start)
        (vertical-motion (buffer-size))))))


;; Resize the minibuffer window to contain the minibuffer's contents.
(defun resize-minibuffer-window ()
  (and (eq (selected-window) (minibuffer-window))
       (let ((height (window-height))
             (lines (1+ (resize-minibuffer-count-window-lines))))
         (and (numberp resize-minibuffer-window-max-height)
              (> resize-minibuffer-window-max-height 0)
              (setq lines (min lines resize-minibuffer-window-max-height)))
         (or (if resize-minibuffer-window-exactly
                 (= lines height)
               (<= lines height))
             (enlarge-window (- lines height))))))

;; This resizes the minibuffer back to one line as soon as it is exited
;; (e.g. when the user hits RET).  This way, subsequent messages put in the
;; echo area aren't cluttered with leftover minibuffer text.
;; It should be called by minibuffer-exit-hook.
;;
;; Note that because it calls sit-for to force a screen update, strange
;; things may happen in the minibuffer, such as unexpanded partial
;; completions by complete.el showing their completion.
;; If this bothers you, just redefine this function to do nothing, in, say,
;; your after-load-alist.  Perhaps there should be an option variable,
;; but I don't know if there's really any demand for it.
;; (Clobbering this definition is harmless because eventually emacs restores
;; its idea of the minibuffer window size when the minibuffer isn't in use
;; anyway; this is just a kludge because of the timing for that update).
(defun resize-minibuffer-window-restore ()
  (cond
   ((not (eq (minibuffer-window) (selected-window))))
   ((> (window-height) 1)
    (enlarge-window (- 1 (window-height)))
    (sit-for 0))))


;; Resize the minibuffer frame to contain the minibuffer's contents.
;; The minibuffer frame must be the current frame.
(defun resize-minibuffer-frame ()
  (let ((height (frame-height))
        (lines (1+ (resize-minibuffer-count-window-lines))))
    (and (numberp resize-minibuffer-frame-max-height)
         (> resize-minibuffer-frame-max-height 0)
         (setq lines (min lines resize-minibuffer-frame-max-height)))
    (cond
     ((> lines height)
      (set-frame-size (window-frame (minibuffer-window)) (frame-width) lines))
     ((and resize-minibuffer-frame-exactly
           (> height resize-minibuffer-frame-original-height)
           (< lines height))
      (set-frame-size (window-frame (minibuffer-window))
		      (frame-width) lines)))))

;; Restore the original height of the frame.
;; resize-minibuffer-frame-original-height is set in
;; resize-minibuffer-setup.
(defun resize-minibuffer-frame-restore ()
  (set-frame-size (window-frame (minibuffer-window))
                  (frame-width)
                  resize-minibuffer-frame-original-height))

(if resize-minibuffer-mode
    (resize-minibuffer-mode 1))

(provide 'rsz-mini)

;; rsz-mini.el ends here
