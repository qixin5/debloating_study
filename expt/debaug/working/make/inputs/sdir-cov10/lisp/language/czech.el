;;; czech.el -- support for Czech -*- coding: iso-2022-7bit; -*-

;; Copyright (C) 1998 Free Software Foundation.

;; Maintainer: Milan Zamazal <pdm@fi.muni.cz>
;; Keywords: multilingual, Czech

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

;; Czech ISO 8859-2 environment.

;;; Code:

(defun setup-czech-environment ()
  "Setup multilingual environment (MULE) for Czech."
  (interactive)
  (set-language-environment "Latin-2"))

(set-language-info-alist
 "Czech" '((charset . (ascii latin-iso8859-2))
	   (coding-system . (iso-8859-2))
	   (coding-priority . (iso-8859-2))
	   (input-method . "czech")
	   (nonascii-translation . latin-iso8859-2)
	   (unibyte-syntax . "latin-2")
	   (unibyte-display . iso-8859-2)
	   (tutorial . "TUTORIAL.cs")
	   (sample-text . "P,Bx(Bejeme v,Ba(Bm hezk,B}(B den!")
	   (documentation . t))
 '("European"))

(provide 'czech)

;; czech.el ends here
