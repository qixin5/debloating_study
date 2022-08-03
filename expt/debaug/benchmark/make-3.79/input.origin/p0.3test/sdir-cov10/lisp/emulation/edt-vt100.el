;;; edt-vt100.el --- Enhanced EDT Keypad Mode Emulation for VT Series Terminals

;; Copyright (C) 1986, 1992, 1993, 1995 Free Software Foundation, Inc.

;; Author: Kevin Gallagher <kevingal@onramp.net>
;; Maintainer: Kevin Gallagher <kevingal@onramp.net>
;; Keywords: emulations

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

;;; Usage:

;;  See edt-user.doc in the Emacs etc directory.

;; ====================================================================

;; Get keyboard function key mapping to EDT keys.
(load "edt-lk201" nil t)

;; The following functions are called by the EDT screen width commands defined
;; in edt.el.

(defun edt-set-term-width-80 ()
  "Set terminal width to 80 columns."
  (vt100-wide-mode -1))

(defun edt-set-term-width-132 ()
  "Set terminal width to 132 columns."
  (vt100-wide-mode 1))
