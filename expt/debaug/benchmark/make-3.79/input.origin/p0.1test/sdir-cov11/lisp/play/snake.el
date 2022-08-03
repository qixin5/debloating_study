;;; snake.el -- Implementation of Snake for Emacs

;; Copyright (C) 1997 Free Software Foundation, Inc.

;; Author: Glynn Clements <glynn@sensei.co.uk>
;; Created: 1997-09-10
;; Keywords: games

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

(eval-when-compile
  (require 'cl))

(require 'gamegrid)

;; ;;;;;;;;;;;;; customization variables ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defvar snake-use-glyphs t
  "Non-nil means use glyphs when available.")

(defvar snake-use-color t
  "Non-nil means use color when available.")

(defvar snake-buffer-name "*Snake*"
  "Name used for Snake buffer.")

(defvar snake-buffer-width 30
  "Width of used portion of buffer.")

(defvar snake-buffer-height 22
  "Height of used portion of buffer.")

(defvar snake-width 30
  "Width of playing area.")

(defvar snake-height 20
  "Height of playing area.")

(defvar snake-initial-length 5
  "Initial length of snake.")

(defvar snake-initial-x 10
  "Initial X position of snake.")

(defvar snake-initial-y 10
  "Initial Y position of snake.")

(defvar snake-initial-velocity-x 1
  "Initial X velocity of snake.")

(defvar snake-initial-velocity-y 0
  "Initial Y velocity of snake.")

(defvar snake-tick-period 0.2
  "The default time taken for the snake to advance one square.")

(defvar snake-mode-hook nil
  "Hook run upon starting Snake.")

(defvar snake-score-x 0
  "X position of score.")

(defvar snake-score-y snake-height
  "Y position of score.")

(defvar snake-score-file "/tmp/snake-scores"
  "File for holding high scores.")

;; ;;;;;;;;;;;;; display options ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defvar snake-blank-options
  '(((glyph colorize)
     (t ?\040))
    ((color-x color-x)
     (mono-x grid-x)
     (color-tty color-tty))
    (((glyph color-x) [0 0 0])
     (color-tty "black"))))

(defvar snake-snake-options
  '(((glyph colorize)
     (emacs-tty ?O)
     (t ?\040))
    ((color-x color-x)
     (mono-x mono-x)
     (color-tty color-tty)
     (mono-tty mono-tty))
    (((glyph color-x) [1 1 0])
     (color-tty "yellow"))))

(defvar snake-dot-options
  '(((glyph colorize)
     (t ?\*))
    ((color-x color-x)
     (mono-x grid-x)
     (color-tty color-tty))
    (((glyph color-x) [1 0 0])
     (color-tty "red"))))

(defvar snake-border-options
  '(((glyph colorize)
     (t ?\+))
    ((color-x color-x)
     (mono-x grid-x))
    (((glyph color-x) [0.5 0.5 0.5])
     (color-tty "white"))))

(defvar snake-space-options
  '(((t ?\040))
    nil
    nil))

;; ;;;;;;;;;;;;; constants ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defconst snake-blank	0)
(defconst snake-snake	1)
(defconst snake-dot	2)
(defconst snake-border	3)
(defconst snake-space	4)

;; ;;;;;;;;;;;;; variables ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defvar snake-length 0)
(defvar snake-velocity-x 1)
(defvar snake-velocity-y 0)
(defvar snake-positions nil)
(defvar snake-cycle 0)
(defvar snake-score 0)
(defvar snake-paused nil)

(make-variable-buffer-local 'snake-length)
(make-variable-buffer-local 'snake-velocity-x)
(make-variable-buffer-local 'snake-velocity-y)
(make-variable-buffer-local 'snake-positions)
(make-variable-buffer-local 'snake-cycle)
(make-variable-buffer-local 'snake-score)
(make-variable-buffer-local 'snake-paused)

;; ;;;;;;;;;;;;; keymaps ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defvar snake-mode-map
  (make-sparse-keymap 'snake-mode-map))

(define-key snake-mode-map "n"		'snake-start-game)
(define-key snake-mode-map "q"		'snake-end-game)
(define-key snake-mode-map "p"		'snake-pause-game)

(define-key snake-mode-map [left]	'snake-move-left)
(define-key snake-mode-map [right]	'snake-move-right)
(define-key snake-mode-map [up]		'snake-move-up)
(define-key snake-mode-map [down]	'snake-move-down)

(defvar snake-null-map
  (make-sparse-keymap 'snake-null-map))

(define-key snake-null-map "n"		'snake-start-game)

;; ;;;;;;;;;;;;;;;; game functions ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun snake-display-options ()
  (let ((options (make-vector 256 nil)))
    (loop for c from 0 to 255 do
      (aset options c
	    (cond ((= c snake-blank)
		   snake-blank-options)
                  ((= c snake-snake)
		   snake-snake-options)
                  ((= c snake-dot)
		   snake-dot-options)
                  ((= c snake-border)
		   snake-border-options)
                  ((= c snake-space)
		   snake-space-options)
                  (t
		   '(nil nil nil)))))
    options))

(defun snake-update-score ()
  (let* ((string (format "Score:  %05d" snake-score))
	 (len (length string)))
    (loop for x from 0 to (1- len) do
      (gamegrid-set-cell (+ snake-score-x x)
			 snake-score-y
			 (aref string x)))))

(defun snake-init-buffer ()
  (gamegrid-init-buffer snake-buffer-width
			snake-buffer-height
			snake-space)
  (let ((buffer-read-only nil))
    (loop for y from 0 to (1- snake-height) do
	  (loop for x from 0 to (1- snake-width) do
		(gamegrid-set-cell x y snake-border)))
    (loop for y from 1 to (- snake-height 2) do
	  (loop for x from 1 to (- snake-width 2) do
		(gamegrid-set-cell x y snake-blank)))))

(defun snake-reset-game ()
  (gamegrid-kill-timer)
  (snake-init-buffer)
  (setq snake-length		snake-initial-length
	snake-velocity-x	snake-initial-velocity-x
	snake-velocity-y	snake-initial-velocity-y
	snake-positions		nil
	snake-cycle		1
	snake-score		0
	snake-paused		nil)
  (let ((x snake-initial-x)
	(y snake-initial-y))
    (dotimes (i snake-length)
      (gamegrid-set-cell x y snake-snake)
      (setq snake-positions (cons (vector x y) snake-positions))
      (incf x snake-velocity-x)
      (incf y snake-velocity-y)))
  (snake-update-score))

(defun snake-update-game (snake-buffer)
  "Called on each clock tick.
Advances the snake one square, testing for collision."
  (if (and (not snake-paused)
	   (eq (current-buffer) snake-buffer))
      (let* ((pos (car snake-positions))
	     (x (+ (aref pos 0) snake-velocity-x))
	     (y (+ (aref pos 1) snake-velocity-y))
	     (c (gamegrid-get-cell x y)))
	(if (or (= c snake-border)
		(= c snake-snake))
	    (snake-end-game)
	  (cond ((= c snake-dot)
		 (incf snake-length)
		 (incf snake-score)
		 (snake-update-score))
		(t
		 (let* ((last-cons (nthcdr (- snake-length 2)
					   snake-positions))
			(tail-pos (cadr last-cons))
			(x0 (aref tail-pos 0))
			(y0 (aref tail-pos 1)))
		   (gamegrid-set-cell x0 y0
				      (if (= (% snake-cycle 5) 0)
					  snake-dot
					snake-blank))
		   (incf snake-cycle)
		   (setcdr last-cons nil))))
	  (gamegrid-set-cell x y snake-snake)
	  (setq snake-positions
		(cons (vector x y) snake-positions))))))

(defun snake-move-left ()
  "Makes the snake move left"
  (interactive)
  (unless (= snake-velocity-x 1)
    (setq snake-velocity-x -1
	  snake-velocity-y 0)))

(defun snake-move-right ()
  "Makes the snake move right"
  (interactive)
  (unless (= snake-velocity-x -1)
    (setq snake-velocity-x 1
	  snake-velocity-y 0)))

(defun snake-move-up ()
  "Makes the snake move up"
  (interactive)
  (unless (= snake-velocity-y 1)
    (setq snake-velocity-x 0
	  snake-velocity-y -1)))

(defun snake-move-down ()
  "Makes the snake move down"
  (interactive)
  (unless (= snake-velocity-y -1)
    (setq snake-velocity-x 0
	  snake-velocity-y 1)))

(defun snake-end-game ()
  "Terminates the current game"
  (interactive)
  (gamegrid-kill-timer)
  (use-local-map snake-null-map)
  (gamegrid-add-score snake-score-file snake-score))

(defun snake-start-game ()
  "Starts a new game of Snake"
  (interactive)
  (snake-reset-game)
  (use-local-map snake-mode-map)
  (gamegrid-start-timer snake-tick-period 'snake-update-game))

(defun snake-pause-game ()
  "Pauses (or resumes) the current game"
  (interactive)
  (setq snake-paused (not snake-paused))
  (message (and snake-paused "Game paused (press p to resume)")))

(defun snake-active-p ()
  (eq (current-local-map) snake-mode-map))

(put 'snake-mode 'mode-class 'special)

(defun snake-mode ()
  "A mode for playing Snake.

snake-mode keybindings:
   \\{snake-mode-map}
"
  (kill-all-local-variables)

  (make-local-hook 'kill-buffer-hook)
  (add-hook 'kill-buffer-hook 'gamegrid-kill-timer nil t)

  (use-local-map snake-null-map)

  (setq major-mode 'snake-mode)
  (setq mode-name "Snake")

  (setq mode-popup-menu
	'("Snake Commands"
	  ["Start new game"	snake-start-game]
	  ["End game"		snake-end-game
	   (snake-active-p)]
	  ["Pause"		snake-pause-game
	   (and (snake-active-p) (not snake-paused))]
	  ["Resume"		snake-pause-game
	   (and (snake-active-p) snake-paused)]))

  (setq gamegrid-use-glyphs snake-use-glyphs)
  (setq gamegrid-use-color snake-use-color)

  (gamegrid-init (snake-display-options))

  (run-hooks 'snake-mode-hook))

;;;###autoload
(defun snake ()
  "Play the Snake game.
Move the snake around without colliding with its tail or with the border.

Eating dots causes the snake to get longer.

snake-mode keybindings:
   \\<snake-mode-map>
\\[snake-start-game]	Starts a new game of Snake
\\[snake-end-game]	Terminates the current game
\\[snake-pause-game]	Pauses (or resumes) the current game
\\[snake-move-left]	Makes the snake move left
\\[snake-move-right]	Makes the snake move right
\\[snake-move-up]	Makes the snake move up
\\[snake-move-down]	Makes the snake move down

"
  (interactive)

  (switch-to-buffer snake-buffer-name)
  (gamegrid-kill-timer)
  (snake-mode)
  (snake-start-game))

(provide 'snake)

;;; snake.el ends here
