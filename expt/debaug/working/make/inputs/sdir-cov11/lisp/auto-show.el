;;; auto-show.el --- perform automatic horizontal scrolling as point moves
;;; This file is in the public domain.

;;; Keywords: scroll display convenience
;;; Author: Pete Ware <ware@cis.ohio-state.edu>
;;; Maintainer: FSF

;;; Commentary:

;;; This file provides functions that
;;; automatically scroll the window horizontally when the point moves
;;; off the left or right side of the window.

;;; Once this library is loaded, automatic horizontal scrolling
;;; occurs whenever long lines are being truncated.
;;; To request truncation of long lines, set the variable
;;; Setting the variable `truncate-lines' to non-nil.
;;; You can do this for all buffers as follows:
;;;
;;; (set-default 'truncate-lines t)

;;; Here is how to do it for C mode only:
;;;
;;; (set-default 'truncate-lines nil)	; this is the original value
;;; (defun my-c-mode-hook ()
;;;   "Run when C-mode starts up.  Changes ..."
;;;   ... set various personal preferences ...
;;;   (setq truncate-lines t))
;;; (add-hook 'c-mode-hook 'my-c-mode-hook)
;;;
;;;
;;; As a finer level of control, you can still have truncated lines but
;;; without the automatic horizontal scrolling by setting the buffer
;;; local variable `auto-show-mode' to nil.  The default value is t.
;;; The command `auto-show-mode' toggles the value of the variable
;;; `auto-show-mode'.

;;; Code:

(defgroup auto-show nil
  "Perform automatic horizontal scrolling as point moves."
  :group 'editing)

;;;###autoload
(defcustom auto-show-mode nil
  "Non-nil means do automatic horizontal scrolling, when lines are truncated.

This variable is automatically local in each buffer where it is set.

Setting this variable directly does not take effect;
use either \\[customize] or the function `auto-show-mode'."
  :set (lambda (symbol value)
	 (setq-default auto-show-mode t)
	 (auto-show-mode (if value 1 0)))
  :require 'auto-show
  :initialize 'custom-initialize-default
  :link '(emacs-commentary-link "auto-show.el")
  :version "20.4"
  :type 'boolean
  :group 'auto-show)

(make-variable-buffer-local 'auto-show-mode)

(defcustom auto-show-shift-amount 8 
  "*Extra columns to scroll. for automatic horizontal scrolling."
  :type 'integer
  :group 'auto-show)

(defcustom auto-show-show-left-margin-threshold 50
  "*Threshold column for automatic horizontal scrolling to the right.
If point is before this column, we try to scroll to make the left margin
visible.  Setting this to 0 disables this feature."
  :type 'integer
  :group 'auto-show)

(defun auto-show-truncationp ()
  "True if line truncation is enabled for the selected window."
  (or truncate-lines 
      (and truncate-partial-width-windows
	   (< (window-width) (frame-width)))))

;;;###autoload
(defun auto-show-mode (arg)
  "Turn automatic horizontal scroll mode on or off.
With arg, turn auto scrolling on if arg is positive, off otherwise.
This mode is enabled or disabled for each buffer individually.
It takes effect only when `truncate-lines' is non-nil."
  (interactive "P")
  (setq auto-show-mode
	(if (null arg)
	    (not auto-show-mode)
	  (> (prefix-numeric-value arg) 0)))
  (when auto-show-mode
    ;; Do auto-scrolling after commands.
    (add-hook 'post-command-hook 'auto-show-make-point-visible)
    ;; Do auto-scrolling in comint buffers after process output also.
    (add-hook 'comint-output-filter-functions
	      'auto-show-make-point-visible t)))
  
(defun auto-show-make-point-visible (&optional ignore-arg)
  "Scroll horizontally to make point visible, if that is enabled.
This function only does something if `auto-show-mode' is non-nil
and longlines are being truncated in the selected window.
See also the command `auto-show-mode'."
  (interactive)
  (if (and auto-show-mode (auto-show-truncationp)
	   (equal (window-buffer) (current-buffer)))
      (let* ((col (current-column))	;column on line point is at
	     (scroll (window-hscroll))	;how far window is scrolled
	     (w-width (- (window-width) 
			 (if (> scroll 0)
			     2 1)))	;how wide window is on the screen
	     (right-col (+ scroll w-width)))
	(if (and (< col auto-show-show-left-margin-threshold)
		 (< col (window-width))
		 (> scroll 0))
	    (scroll-right scroll)
	  (if (< col scroll)		;to the left of the screen
	      (scroll-right (+ (- scroll col) auto-show-shift-amount))
	    (if (or (> col right-col)	;to the right of the screen
		    (and (= col right-col)
			 (not (eolp))))
		(scroll-left (+ auto-show-shift-amount 
				(- col (+ scroll w-width))))))))))

(provide 'auto-show)

;; auto-show.el ends here

