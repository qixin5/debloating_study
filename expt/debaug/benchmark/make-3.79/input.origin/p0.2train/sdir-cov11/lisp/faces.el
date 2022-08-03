;;; faces.el --- Lisp interface to the c "face" structure

;; Copyright (C) 1992, 1993, 1994, 1995, 1996 Free Software Foundation, Inc.

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

;; Mostly derived from Lucid.

;;; Code:

(eval-when-compile
 ;; These used to be defsubsts, now they're subrs.  Avoid losing if we're
 ;; being compiled with an old Emacs that still has defsubrs in it.
 (put 'face-name 'byte-optimizer nil)
 (put 'face-id 'byte-optimizer nil)
 (put 'face-font 'byte-optimizer nil)
 (put 'face-font-explicit 'byte-optimizer nil)
 (put 'face-foreground 'byte-optimizer nil)
 (put 'face-background 'byte-optimizer nil)
 (put 'face-stipple 'byte-optimizer nil)
 (put 'face-underline-p 'byte-optimizer nil)
 (put 'set-face-font 'byte-optimizer nil)
 (put 'set-face-font-auto 'byte-optimizer nil)
 (put 'set-face-foreground 'byte-optimizer nil)
 (put 'set-face-background 'byte-optimizer nil)
 (put 'set-face-stipple 'byte-optimizer nil)
 (put 'set-face-underline-p 'byte-optimizer nil))

;;;; Functions for manipulating face vectors.

;;; A face vector is a vector of the form:
;;;    [face NAME ID FONT FOREGROUND BACKGROUND STIPPLE
;;;          UNDERLINE-P INVERSE-VIDEO-P FONT-EXPLICIT-P BOLD-P ITALIC-P]

;;; Type checkers.
(defsubst internal-facep (x)
  (and (vectorp x) (= (length x) 12) (eq (aref x 0) 'face)))

(defun facep (x)
  "Return t if X is a face name or an internal face vector."
  (and (or (internal-facep x)
	   (and (symbolp x) (assq x global-face-data)))
       t))
      
(defmacro internal-check-face (face)
  (` (or (internal-facep (, face))
	 (signal 'wrong-type-argument (list 'internal-facep (, face))))))

;;; Accessors.
(defun face-name (face)
  "Return the name of face FACE."
  (aref (internal-get-face face) 1))

(defun face-id (face)
  "Return the internal ID number of face FACE."
  (aref (internal-get-face face) 2))

(defun face-font (face &optional frame)
  "Return the font name of face FACE, or nil if it is unspecified.
If the optional argument FRAME is given, report on face FACE in that frame.
If FRAME is t, report on the defaults for face FACE (for new frames).
  The font default for a face is either nil, or a list
  of the form (bold), (italic) or (bold italic).
If FRAME is omitted or nil, use the selected frame."
  (aref (internal-get-face face frame) 3))

(defun face-foreground (face &optional frame)
  "Return the foreground color name of face FACE, or nil if unspecified.
If the optional argument FRAME is given, report on face FACE in that frame.
If FRAME is t, report on the defaults for face FACE (for new frames).
If FRAME is omitted or nil, use the selected frame."
  (aref (internal-get-face face frame) 4))

(defun face-background (face &optional frame)
  "Return the background color name of face FACE, or nil if unspecified.
If the optional argument FRAME is given, report on face FACE in that frame.
If FRAME is t, report on the defaults for face FACE (for new frames).
If FRAME is omitted or nil, use the selected frame."
  (aref (internal-get-face face frame) 5))

(defun face-stipple (face &optional frame)
 "Return the stipple pixmap name of face FACE, or nil if unspecified.
If the optional argument FRAME is given, report on face FACE in that frame.
If FRAME is t, report on the defaults for face FACE (for new frames).
If FRAME is omitted or nil, use the selected frame."
 (aref (internal-get-face face frame) 6))

(defalias 'face-background-pixmap 'face-stipple)

(defun face-underline-p (face &optional frame)
 "Return t if face FACE is underlined.
If the optional argument FRAME is given, report on face FACE in that frame.
If FRAME is t, report on the defaults for face FACE (for new frames).
If FRAME is omitted or nil, use the selected frame."
 (aref (internal-get-face face frame) 7))

(defun face-inverse-video-p (face &optional frame)
 "Return t if face FACE is in inverse video.
If the optional argument FRAME is given, report on face FACE in that frame.
If FRAME is t, report on the defaults for face FACE (for new frames).
If FRAME is omitted or nil, use the selected frame."
 (aref (internal-get-face face frame) 8))

(defun face-font-explicit (face &optional frame)
  "Return non-nil if this face's font was explicitly specified."
  (aref (internal-get-face face frame) 9))

(defun face-bold-p (face &optional frame)
  "Return non-nil if the font of FACE is bold.
If the optional argument FRAME is given, report on face FACE in that frame.
If FRAME is t, report on the defaults for face FACE (for new frames).
If FRAME is omitted or nil, use the selected frame."
  (aref (internal-get-face face frame) 10))

(defun face-italic-p (face &optional frame)
  "Return non-nil if the font of FACE is italic.
If the optional argument FRAME is given, report on face FACE in that frame.
If FRAME is t, report on the defaults for face FACE (for new frames).
If FRAME is omitted or nil, use the selected frame."
  (aref (internal-get-face face frame) 11))

(defalias 'face-doc-string 'face-documentation)
(defun face-documentation (face)
  "Get the documentation string for FACE."
  (get face 'face-documentation))

;;; Mutators.

(defun set-face-font (face font &optional frame)
  "Change the font of face FACE to FONT (a string).
If the optional FRAME argument is provided, change only
in that frame; otherwise change each frame."
  (interactive (internal-face-interactive "font"))
  (if (stringp font)
      (setq font (or (resolve-fontset-name font)
		     (x-resolve-font-name font 'default frame))))
  (internal-set-face-1 face 'font font 3 frame)
  ;; Record that this face's font was set explicitly, not automatically,
  ;; unless we are setting it to nil.
  (internal-set-face-1 face nil (not (null font)) 9 frame))

(defun set-face-font-auto (face font &optional frame)
  "Change the font of face FACE to FONT (a string), for an automatic change.
An automatic change means that we don't change the \"explicit\" flag;
if the font was derived from the frame font before, it is now.
If the optional FRAME argument is provided, change only
in that frame; otherwise change each frame."
  (interactive (internal-face-interactive "font"))
  (if (stringp font)
      (setq font (or (resolve-fontset-name font)
		     (x-resolve-font-name font 'default frame))))
  (internal-set-face-1 face 'font font 3 frame))

(defun set-face-font-explicit (face flag &optional frame)
  "Set the explicit-font flag of face FACE to FLAG.
If the optional FRAME argument is provided, change only
in that frame; otherwise change each frame."
  (internal-set-face-1 face nil flag 9 frame))

(defun set-face-foreground (face color &optional frame)
  "Change the foreground color of face FACE to COLOR (a string).
If the optional FRAME argument is provided, change only
in that frame; otherwise change each frame."
  (interactive (internal-face-interactive "foreground" 'color))
  (internal-set-face-1 face 'foreground color 4 frame))

(defvar face-default-stipple "gray3" 
  "Default stipple pattern used on monochrome displays.
This stipple pattern is used on monochrome displays
instead of shades of gray for a face background color.
See `set-face-stipple' for possible values for this variable.")

(defun face-color-gray-p (color &optional frame)
  "Return t if COLOR is a shade of gray (or white or black).
FRAME specifies the frame and thus the display for interpreting COLOR."
  (let* ((values (x-color-values color frame))
	 (r (nth 0 values))
	 (g (nth 1 values))
	 (b (nth 2 values)))
    (and values
	 (< (abs (- r g)) (/ (max 1 (abs r) (abs g)) 20))
	 (< (abs (- g b)) (/ (max 1 (abs g) (abs b)) 20))
	 (< (abs (- b r)) (/ (max 1 (abs b) (abs r)) 20)))))

(defun set-face-background (face color &optional frame)
  "Change the background color of face FACE to COLOR (a string).
If the optional FRAME argument is provided, change only
in that frame; otherwise change each frame."
  (interactive (internal-face-interactive "background" 'color))
  ;; For a specific frame, use gray stipple instead of gray color
  ;; if the display does not support a gray color.
  (if (and frame (not (eq frame t)) color
	   ;; Check for support for foreground, not for background!
	   ;; face-color-supported-p is smart enough to know
	   ;; that grays are "supported" as background
	   ;; because we are supposed to use stipple for them!
	   (not (face-color-supported-p frame color nil)))
      (set-face-stipple face face-default-stipple frame)
    (if (null frame)
	(let ((frames (frame-list)))
	  (while frames
	    (set-face-background (face-name face) color (car frames))
	    (setq frames (cdr frames)))
	  (set-face-background face color t)
	  color)
      (internal-set-face-1 face 'background color 5 frame))))

(defun set-face-stipple (face pixmap &optional frame)
  "Change the stipple pixmap of face FACE to PIXMAP.
PIXMAP should be a string, the name of a file of pixmap data.
The directories listed in the `x-bitmap-file-path' variable are searched.

Alternatively, PIXMAP may be a list of the form (WIDTH HEIGHT DATA)
where WIDTH and HEIGHT are the size in pixels,
and DATA is a string, containing the raw bits of the bitmap.  

If the optional FRAME argument is provided, change only
in that frame; otherwise change each frame."
  (interactive (internal-face-interactive-stipple "stipple"))
  (internal-set-face-1 face 'background-pixmap pixmap 6 frame))

(defalias 'set-face-background-pixmap 'set-face-stipple)

(defun set-face-underline-p (face underline-p &optional frame)
  "Specify whether face FACE is underlined.  (Yes if UNDERLINE-P is non-nil.)
If the optional FRAME argument is provided, change only
in that frame; otherwise change each frame."
  (interactive (internal-face-interactive "underline-p" "underlined"))
  (internal-set-face-1 face 'underline underline-p 7 frame))

(defun set-face-inverse-video-p (face inverse-video-p &optional frame)
  "Specify whether face FACE is in inverse video.
\(Yes if INVERSE-VIDEO-P is non-nil.)
If the optional FRAME argument is provided, change only
in that frame; otherwise change each frame."
  (interactive (internal-face-interactive "inverse-video-p" "inverse-video"))
  (internal-set-face-1 face 'inverse-video inverse-video-p 8 frame))

(defun set-face-bold-p (face bold-p &optional frame)
  "Specify whether face FACE is bold.  (Yes if BOLD-P is non-nil.)
If the optional FRAME argument is provided, change only
in that frame; otherwise change each frame."
  (cond ((eq bold-p nil) (make-face-unbold face frame t))
	(t (make-face-bold face frame t))))

(defun set-face-italic-p (face italic-p &optional frame)
  "Specify whether face FACE is italic.  (Yes if ITALIC-P is non-nil.)
If the optional FRAME argument is provided, change only
in that frame; otherwise change each frame."
  (cond ((eq italic-p nil) (make-face-unitalic face frame t))
	(t (make-face-italic face frame t))))

(defalias 'set-face-doc-string 'set-face-documentation)
(defun set-face-documentation (face string)
  "Set the documentation string for FACE to STRING."
  (put face 'face-documentation string))

(defun modify-face-read-string (face default name alist)
  (let ((value
	 (completing-read
	  (if default
	      (format "Set face %s %s (default %s): "
		      face name (downcase default))
	    (format "Set face %s %s: " face name))
	  alist)))
    (cond ((equal value "none")
	   '(nil))
	  ((equal value "")
	   default)
	  (t value))))

(defun modify-face (face foreground background stipple
		    bold-p italic-p underline-p &optional inverse-p frame)
  "Change the display attributes for face FACE.
If the optional FRAME argument is provided, change only
in that frame; otherwise change each frame.

FOREGROUND and BACKGROUND should be a colour name string (or list of strings to
try) or nil.  STIPPLE should be a stipple pattern name string or nil.
If nil, means do not change the display attribute corresponding to that arg.
If (nil), that means clear out the attribute.

BOLD-P, ITALIC-P, UNDERLINE-P, and INVERSE-P specify whether
the face should be set bold, italic, underlined or in inverse-video,
respectively.  If one of these arguments is neither nil or t, it means do not
change the display attribute corresponding to that argument.

If called interactively, prompts for a face name and face attributes."
  (interactive
   (let* ((completion-ignore-case t)
	  (face		(symbol-name (read-face-name "Modify face: ")))
	  (colors	(mapcar 'list x-colors))
	  (stipples	(mapcar 'list (apply 'nconc
					    (mapcar 'directory-files
						    x-bitmap-file-path))))
	  (foreground	(modify-face-read-string
			 face (face-foreground (intern face))
			 "foreground" colors))
	  (background	(modify-face-read-string
			 face (face-background (intern face))
			 "background" colors))
	  ;; If the stipple value is a list (WIDTH HEIGHT DATA),
	  ;; represent that as a string by printing it out.
	  (old-stipple-string
	   (if (stringp (face-stipple (intern face)))
	       (face-stipple (intern face))
	     (if (face-stipple (intern face))
		 (prin1-to-string (face-stipple (intern face))))))
	  (new-stipple-string
	   (modify-face-read-string
	    face old-stipple-string
	    "stipple" stipples))
	  ;; Convert the stipple value text we read
	  ;; back to a list if it looks like one.
	  ;; This makes the assumption that a pixmap file name
	  ;; won't start with an open-paren.
	  (stipple
	   (and new-stipple-string
		(if (string-match "^(" new-stipple-string)
		    (read new-stipple-string)
		  new-stipple-string)))
	  (bold-p	(y-or-n-p (concat "Should face " face " be bold ")))
	  (italic-p	(y-or-n-p (concat "Should face " face " be italic ")))
	  (underline-p	(y-or-n-p (concat "Should face " face " be underlined ")))
	  (inverse-p	(y-or-n-p (concat "Should face " face " be inverse-video ")))
	  (all-frames-p	(y-or-n-p (concat "Modify face " face " in all frames "))))
     (message "Face %s: %s" face
      (mapconcat 'identity
       (delq nil
	(list (if (equal foreground '(nil))
		  " no foreground"
		(and foreground (concat (downcase foreground) " foreground")))
	      (if (equal background '(nil))
		  " no background"
		(and background (concat (downcase background) " background")))
	      (if (equal stipple '(nil))
		  " no stipple"
		(and stipple (concat (downcase new-stipple-string) " stipple")))
	      (and bold-p "bold") (and italic-p "italic")
	      (and inverse-p "inverse")
	      (and underline-p "underline"))) ", "))
     (list (intern face) foreground background stipple
	   bold-p italic-p underline-p inverse-p
	   (if all-frames-p nil (selected-frame)))))
  ;; Clear this before we install the new foreground and background;
  ;; otherwise, clearing it after would swap them!
  (when (and (or foreground background) (face-inverse-video-p face))
    (set-face-inverse-video-p face nil frame)
    ;; Arrange to restore it after, if we are not setting it now.
    (or (memq inverse-p '(t nil))
	(setq inverse-p t)))
  (condition-case nil
      (face-try-color-list 'set-face-foreground face foreground frame)
    (error nil))
  (condition-case nil
      (face-try-color-list 'set-face-background face background frame)
    (error nil))
  (condition-case nil
      (set-face-stipple face stipple frame)
    (error nil))
  ;; Now that we have the new colors, 
  (if (memq inverse-p '(nil t))
      (set-face-inverse-video-p face inverse-p frame))
  (cond ((eq bold-p nil)
	 (if (face-font face frame)
	     (make-face-unbold face frame t)))
	((eq bold-p t)
	 (make-face-bold face frame t)))
  (cond ((eq italic-p nil)
	 (if (face-font face frame)
	     (make-face-unitalic face frame t)))
	((eq italic-p t) (make-face-italic face frame t)))
  (if (memq underline-p '(nil t))
      (set-face-underline-p face underline-p frame))
  (and (interactive-p) (redraw-display)))

;;;; Associating face names (symbols) with their face vectors.

(defvar global-face-data nil
  "Internal data for face support functions.  Not for external use.
This is an alist associating face names with the default values for
their parameters.  Newly created frames get their data from here.")

(defun face-list ()
  "Returns a list of all defined face names."
  (mapcar 'car global-face-data))

(defun internal-find-face (name &optional frame)
  "Retrieve the face named NAME.  Return nil if there is no such face.
If the optional argument FRAME is given, this gets the face NAME for
that frame; otherwise, it uses the selected frame.
If FRAME is the symbol t, then the global, non-frame face is returned.
If NAME is already a face, it is simply returned."
  (if (and (eq frame t) (not (symbolp name)))
      (setq name (face-name name)))
  (if (symbolp name)
      (cdr (assq name
		 (if (eq frame t)
		     global-face-data
		   (frame-face-alist (or frame (selected-frame))))))
    (internal-check-face name)
    name))

(defun internal-get-face (name &optional frame)
  "Retrieve the face named NAME; error if there is none.
If the optional argument FRAME is given, this gets the face NAME for
that frame; otherwise, it uses the selected frame.
If FRAME is the symbol t, then the global, non-frame face is returned.
If NAME is already a face, it is simply returned."
  (or (internal-find-face name frame)
      (internal-check-face name)))


(defun internal-set-face-1 (face name value index frame)
  (let ((inhibit-quit t))
    (if (null frame)
	(let ((frames (frame-list)))
	  (while frames
	    (internal-set-face-1 (face-name face) name value index (car frames))
	    (setq frames (cdr frames)))
	  (aset (internal-get-face (if (symbolp face) face (face-name face)) t)
		index value)
	  value)
      (let ((internal-face (internal-get-face face frame)))
	(or (eq frame t)
	    (if (eq name 'inverse-video)
		(or (eq value (aref internal-face index))
		    (invert-face face frame))
	      (and name (fboundp 'set-face-attribute-internal)
		   (set-face-attribute-internal (face-id face)
						name value frame))))
	(aset internal-face index value)))))


(defun read-face-name (prompt)
  (let (face)
    (while (= (length face) 0)
      (setq face (completing-read prompt
				  (mapcar '(lambda (x) (list (symbol-name x)))
					  (face-list))
				  nil t)))
    (intern face)))

(defun internal-face-interactive (what &optional bool)
  (let* ((fn (intern (concat "face-" what)))
	 (prompt (concat "Set " what " of face"))
	 (face (read-face-name (concat prompt ": ")))
	 (default (if (fboundp fn)
		      (or (funcall fn face (selected-frame))
			  (funcall fn 'default (selected-frame)))))
	 value)
    (setq value
	  (cond ((eq bool 'color)
		 (completing-read (concat prompt " " (symbol-name face) " to: ")
				  (mapcar (function (lambda (color)
						      (cons color color)))
					  x-colors)
				  nil nil nil nil default))
		(bool
		 (y-or-n-p (concat "Should face " (symbol-name face)
				   " be " bool "? ")))
		(t
		 (read-string (concat prompt " " (symbol-name face) " to: ")
			      nil nil default))))
    (list face (if (equal value "") nil value))))

(defun internal-face-interactive-stipple (what)
  (let* ((fn (intern (concat "face-" what)))
	 (prompt (concat "Set " what " of face"))
	 (face (read-face-name (concat prompt ": ")))
	 (default (if (fboundp fn)
		      (or (funcall fn face (selected-frame))
			  (funcall fn 'default (selected-frame)))))
	 ;; If the stipple value is a list (WIDTH HEIGHT DATA),
	 ;; represent that as a string by printing it out.
	 (old-stipple-string
	  (if (stringp (face-stipple face))
	      (face-stipple face)
	    (if (null (face-stipple face))
		nil
	      (prin1-to-string (face-stipple face)))))
	 (new-stipple-string
	  (read-string
	   (concat prompt " " (symbol-name face) " to: ")
	   old-stipple-string))
	 ;; Convert the stipple value text we read
	 ;; back to a list if it looks like one.
	 ;; This makes the assumption that a pixmap file name
	 ;; won't start with an open-paren.
	 (stipple
	  (if (string-match "^(" new-stipple-string)
	      (read new-stipple-string)
	    new-stipple-string)))
    (list face (if (equal stipple "") nil stipple))))

(defun make-face (name &optional no-resources)
  "Define a new FACE on all frames.  
You can modify the font, color, etc of this face with the set-face- functions.
If NO-RESOURCES is non-nil, then we ignore X resources
and always make a face whose attributes are all nil.

If the face already exists, it is unmodified."
  (interactive "SMake face: ")
  (or (internal-find-face name)
      (let ((face (make-vector 12 nil)))
	(aset face 0 'face)
	(aset face 1 name)
	(let* ((frames (frame-list))
	       (inhibit-quit t)
	       (id (internal-next-face-id)))
	  (if (fboundp 'make-face-internal)
	      (make-face-internal id))
	  (aset face 2 id)
	  (while frames
	    (set-frame-face-alist (car frames)
				  (cons (cons name (copy-sequence face))
					(frame-face-alist (car frames))))
	    (setq frames (cdr frames)))
	  (setq global-face-data (cons (cons name face) global-face-data)))
	;; When making a face after frames already exist
	(or no-resources
	    (if (memq window-system '(x w32))
		(make-face-x-resource-internal face)))
	;; Add to menu of faces.
	(if (fboundp 'facemenu-add-new-face)
	    (facemenu-add-new-face name))
	face))
  name)

(defun make-empty-face (face)
  "Define a new FACE on all frames, which initially reflects the defaults.
You can modify the font, color, etc of this face with the set-face- functions.
If the face already exists, it is unmodified."
  (interactive "SMake empty face: ")
  (make-face face t))

;; Fill in a face by default based on X resources, for all existing frames.
;; This has to be done when a new face is made.
(defun make-face-x-resource-internal (face &optional frame set-anyway)
  (cond ((null frame)
	 (let ((frames (frame-list)))
	   (while frames
	     (if (memq (framep (car frames)) '(x w32))
		 (make-face-x-resource-internal (face-name face)
						(car frames) set-anyway))
	     (setq frames (cdr frames)))))
	(t
	 (setq face (internal-get-face (face-name face) frame))
	 ;;
	 ;; These are things like "attributeForeground" instead of simply
	 ;; "foreground" because people tend to do things like "*foreground",
	 ;; which would cause all faces to be fully qualified, making faces
	 ;; inherit attributes in a non-useful way.  So we've made them slightly
	 ;; less obvious to specify in order to make them work correctly in
	 ;; more random environments.
	 ;;
	 ;; I think these should be called "face.faceForeground" instead of
	 ;; "face.attributeForeground", but they're the way they are for
	 ;; hysterical reasons.
	 ;; 
	 (let* ((name (symbol-name (face-name face)))
		(fn  (or (x-get-resource (concat name ".attributeFont")
					 "Face.AttributeFont")
			 (and set-anyway (face-font face))))
		(fg  (or (x-get-resource (concat name ".attributeForeground")
					 "Face.AttributeForeground")
			 (and set-anyway (face-foreground face))))
		(bg  (or (x-get-resource (concat name ".attributeBackground")
					 "Face.AttributeBackground")
			 (and set-anyway (face-background face))))
		(bgp (or (x-get-resource (concat name ".attributeStipple")
					 "Face.AttributeStipple")
			 (x-get-resource (concat name ".attributeBackgroundPixmap")
					 "Face.AttributeBackgroundPixmap")
			 (and set-anyway (face-stipple face))))
		(ulp (let ((resource (x-get-resource
				      (concat name ".attributeUnderline")
				      "Face.AttributeUnderline")))
		       (if resource
			   (member (downcase resource) '("on" "true"))
			 (and set-anyway (face-underline-p face)))))
		)
	   (if fn
	       (condition-case ()
		   (cond ((string= fn "italic")
			  (make-face-italic face))
			 ((string= fn "bold")
			  (make-face-bold face))
			 ((string= fn "bold-italic")
			  (make-face-bold-italic face))
			 (t
			  (set-face-font face fn frame)))
		 (error
		  (if (member fn '("italic" "bold" "bold-italic"))
		      (message "no %s version found for face `%s'" fn name)
		    (message "font `%s' not found for face `%s'" fn name)))))
	   (if fg
	       (condition-case ()
		   (set-face-foreground face fg frame)
		 (error (message "color `%s' not allocated for face `%s'" fg name))))
	   (if bg
	       (condition-case ()
		   (set-face-background face bg frame)
		 (error (message "color `%s' not allocated for face `%s'" bg name))))
	   (if bgp
	       (condition-case ()
		   (set-face-stipple face bgp frame)
		 (error (message "pixmap `%s' not found for face `%s'" bgp name))))
	   (if (or ulp set-anyway)
	       (set-face-underline-p face ulp frame))
	   )))
  face)

(defun copy-face (old-face new-face &optional frame new-frame)
  "Define a face just like OLD-FACE, with name NEW-FACE.
If NEW-FACE already exists as a face, it is modified to be like OLD-FACE.
If it doesn't already exist, it is created.

If the optional argument FRAME is given as a frame,
NEW-FACE is changed on FRAME only.
If FRAME is t, the frame-independent default specification for OLD-FACE
is copied to NEW-FACE.
If FRAME is nil, copying is done for the frame-independent defaults
and for each existing frame.
If the optional fourth argument NEW-FRAME is given, 
copy the information from face OLD-FACE on frame FRAME
to NEW-FACE on frame NEW-FRAME."
  (or new-frame (setq new-frame frame))
  (let ((inhibit-quit t))
    (if (null frame)
	(let ((frames (frame-list)))
	  (while frames
	    (copy-face old-face new-face (car frames))
	    (setq frames (cdr frames)))
	  (copy-face old-face new-face t))
      (setq old-face (internal-get-face old-face frame))
      (setq new-face (or (internal-find-face new-face new-frame)
			 (make-face new-face)))
      (condition-case nil
	  ;; A face that has a global symbolic font modifier such as `bold'
	  ;; might legitimately get an error here.
	  ;; Use the frame's default font in that case.
	  (set-face-font new-face (face-font old-face frame) new-frame)
	(error
	 (set-face-font new-face nil new-frame)))
      (set-face-font-explicit new-face (face-font-explicit old-face frame)
			      new-frame)
      (set-face-foreground new-face (face-foreground old-face frame) new-frame)
      (set-face-background new-face (face-background old-face frame) new-frame)
      (set-face-stipple new-face
			(face-stipple old-face frame)
			new-frame)
      (set-face-underline-p new-face (face-underline-p old-face frame)
			    new-frame))
    new-face))

(defun face-equal (face1 face2 &optional frame)
  "True if the faces FACE1 and FACE2 display in the same way."
  (setq face1 (internal-get-face face1 frame)
	face2 (internal-get-face face2 frame))
  (and (equal (face-foreground face1 frame) (face-foreground face2 frame))
       (equal (face-background face1 frame) (face-background face2 frame))
       (equal (face-font face1 frame) (face-font face2 frame))
       (eq (face-underline-p face1 frame) (face-underline-p face2 frame))
       (equal (face-stipple face1 frame)
	      (face-stipple face2 frame))))

(defun face-differs-from-default-p (face &optional frame)
  "True if face FACE displays differently from the default face, on FRAME.
A face is considered to be ``the same'' as the default face if it is 
actually specified in the same way (equivalent fonts, etc) or if it is 
fully unspecified, and thus inherits the attributes of any face it 
is displayed on top of.

The optional argument FRAME specifies which frame to test;
if FRAME is t, test the default for new frames.
If FRAME is nil or omitted, test the selected frame."
  (let ((default (internal-get-face 'default frame)))
    (setq face (internal-get-face face frame))
    (not (and (or (equal (face-foreground default frame)
			 (face-foreground face frame))
		  (null (face-foreground face frame)))
	      (or (equal (face-background default frame)
			 (face-background face frame))
		  (null (face-background face frame)))
	      (or (null (face-font face frame))
		  (equal (face-font face frame)
			 (or (face-font default frame)
			     (downcase
			      (cdr (assq 'font (frame-parameters frame)))))))
	      (or (equal (face-stipple default frame)
			 (face-stipple face frame))
		  (null (face-stipple face frame)))
	      (equal (face-underline-p default frame)
		     (face-underline-p face frame))
	      ))))

(defun face-nontrivial-p (face &optional frame)
  "True if face FACE has some non-nil attribute.
The optional argument FRAME specifies which frame to test;
if FRAME is t, test the default for new frames.
If FRAME is nil or omitted, test the selected frame."
  (setq face (internal-get-face face frame))
  (or (face-foreground face frame)
      (face-background face frame)
      (face-font face frame)
      (face-stipple face frame)
      (face-underline-p face frame)))


(defun invert-face (face &optional frame)
  "Swap the foreground and background colors of face FACE.
If the face doesn't specify both foreground and background, then
set its foreground and background to the default background and foreground."
  (interactive (list (read-face-name "Invert face: ")))
  (setq face (internal-get-face face frame))
  (let ((fg (face-foreground face frame))
	(bg (face-background face frame)))
    (if (or fg bg)
	(progn
	  (set-face-foreground face bg frame)
	  (set-face-background face fg frame))
      (let* ((frame-bg (cdr (assq 'background-color (frame-parameters frame))))
	     (default-bg (or (face-background 'default frame)
			     frame-bg))
	     (frame-fg (cdr (assq 'foreground-color (frame-parameters frame))))
	     (default-fg (or (face-foreground 'default frame)
			     frame-fg)))
	(set-face-foreground face default-bg frame)
	(set-face-background face default-fg frame))))
  face)


(defun internal-try-face-font (face font &optional frame)
  "Like set-face-font, but returns nil on failure instead of an error."
  (condition-case ()
      (set-face-font-auto face font frame)
    (error nil)))

;; Manipulating font names.

(defvar x-font-regexp nil)
(defvar x-font-regexp-head nil)
(defvar x-font-regexp-weight nil)
(defvar x-font-regexp-slant nil)

(defconst x-font-regexp-weight-subnum 1)
(defconst x-font-regexp-slant-subnum 2)
(defconst x-font-regexp-swidth-subnum 3)
(defconst x-font-regexp-adstyle-subnum 4)

;;; Regexps matching font names in "Host Portable Character Representation."
;;;
(let ((- 		"[-?]")
      (foundry		"[^-]+")
      (family 		"[^-]+")
      (weight		"\\(bold\\|demibold\\|medium\\)")		; 1
;     (weight\?		"\\(\\*\\|bold\\|demibold\\|medium\\|\\)")	; 1
      (weight\?		"\\([^-]*\\)")					; 1
      (slant		"\\([ior]\\)")					; 2
;     (slant\?		"\\([ior?*]?\\)")				; 2
      (slant\?		"\\([^-]?\\)")					; 2
;     (swidth		"\\(\\*\\|normal\\|semicondensed\\|\\)")	; 3
      (swidth		"\\([^-]*\\)")					; 3
;     (adstyle		"\\(\\*\\|sans\\|\\)")				; 4
      (adstyle		"\\([^-]*\\)")					; 4
      (pixelsize	"[0-9]+")
      (pointsize	"[0-9][0-9]+")
      (resx		"[0-9][0-9]+")
      (resy		"[0-9][0-9]+")
      (spacing		"[cmp?*]")
      (avgwidth		"[0-9]+")
      (registry		"[^-]+")
      (encoding		"[^-]+")
      )
  (setq x-font-regexp
	(concat "\\`\\*?[-?*]"
		foundry - family - weight\? - slant\? - swidth - adstyle -
		pixelsize - pointsize - resx - resy - spacing - avgwidth -
		registry - encoding "\\*?\\'"
		))
  (setq x-font-regexp-head
	(concat "\\`[-?*]" foundry - family - weight\? - slant\?
		"\\([-*?]\\|\\'\\)"))
  (setq x-font-regexp-slant (concat - slant -))
  (setq x-font-regexp-weight (concat - weight -))
  nil)	    

(defun x-resolve-font-name (pattern &optional face frame)
  "Return a font name matching PATTERN.
All wildcards in PATTERN become substantiated.
If PATTERN is nil, return the name of the frame's base font, which never
contains wildcards.
Given optional arguments FACE and FRAME, return a font which is
also the same size as FACE on FRAME, or fail."
  (or (symbolp face)
      (setq face (face-name face)))
  (and (eq frame t)
       (setq frame nil))
  (if pattern
      ;; Note that x-list-fonts has code to handle a face with nil as its font.
      (let ((fonts (x-list-fonts pattern face frame 1)))
	(or fonts
	    (if face
		(if (string-match "\\*" pattern)
		    (if (null (face-font face))
			(error "No matching fonts are the same height as the frame default font")
		      (error "No matching fonts are the same height as face `%s'" face))
		  (if (null (face-font face))
		      (error "Height of font `%s' doesn't match the frame default font"
			     pattern)
		    (error "Height of font `%s' doesn't match face `%s'"
			   pattern face)))
	      (error "No fonts match `%s'" pattern)))
	(car fonts))
    (cdr (assq 'font (frame-parameters (selected-frame))))))

(defun x-frob-font-weight (font which)
  (let ((case-fold-search t))
    (cond ((string-match x-font-regexp font)
	   (concat (substring font 0
			      (match-beginning x-font-regexp-weight-subnum))
		   which
		   (substring font (match-end x-font-regexp-weight-subnum)
			      (match-beginning x-font-regexp-adstyle-subnum))
		   ;; Replace the ADD_STYLE_NAME field with *
		   ;; because the info in it may not be the same
		   ;; for related fonts.
		   "*"
		   (substring font (match-end x-font-regexp-adstyle-subnum))))
	  ((string-match x-font-regexp-head font)
	   (concat (substring font 0 (match-beginning 1)) which
		   (substring font (match-end 1))))
	  ((string-match x-font-regexp-weight font)
	   (concat (substring font 0 (match-beginning 1)) which
		   (substring font (match-end 1)))))))

(defun x-frob-font-slant (font which)
  (let ((case-fold-search t))
    (cond ((string-match x-font-regexp font)
	   (concat (substring font 0
			      (match-beginning x-font-regexp-slant-subnum))
		   which
		   (substring font (match-end x-font-regexp-slant-subnum)
			      (match-beginning x-font-regexp-adstyle-subnum))
		   ;; Replace the ADD_STYLE_NAME field with *
		   ;; because the info in it may not be the same
		   ;; for related fonts.
		   "*"
		   (substring font (match-end x-font-regexp-adstyle-subnum))))
	  ((string-match x-font-regexp-head font)
	   (concat (substring font 0 (match-beginning 2)) which
		   (substring font (match-end 2))))
	  ((string-match x-font-regexp-slant font)
	   (concat (substring font 0 (match-beginning 1)) which
		   (substring font (match-end 1)))))))

(defun x-make-font-bold (font)
  "Given an X font specification, make a bold version of it.
If that can't be done, return nil."
  (x-frob-font-weight font "bold"))

(defun x-make-font-demibold (font)
  "Given an X font specification, make a demibold version of it.
If that can't be done, return nil."
  (x-frob-font-weight font "demibold"))

(defun x-make-font-unbold (font)
  "Given an X font specification, make a non-bold version of it.
If that can't be done, return nil."
  (x-frob-font-weight font "medium"))

(defun x-make-font-italic (font)
  "Given an X font specification, make an italic version of it.
If that can't be done, return nil."
  (x-frob-font-slant font "i"))

(defun x-make-font-oblique (font) ; you say tomayto...
  "Given an X font specification, make an oblique version of it.
If that can't be done, return nil."
  (x-frob-font-slant font "o"))

(defun x-make-font-unitalic (font)
  "Given an X font specification, make a non-italic version of it.
If that can't be done, return nil."
  (x-frob-font-slant font "r"))

(defun x-make-font-bold-italic (font)
  "Given an X font specification, make a bold and italic version of it.
If that can't be done, return nil."
  (and (setq font (x-make-font-bold font))
       (x-make-font-italic font)))

;;; non-X-specific interface

(defun make-face-bold (face &optional frame noerror)
  "Make the font of the given face be bold, if possible.  
If NOERROR is non-nil, return nil on failure."
  (interactive (list (read-face-name "Make which face bold: ")))
  ;; Set the bold-p flag, first of all.
  (internal-set-face-1 face nil t 10 frame)
  (if (and (eq frame t) (listp (face-font face t)))
      (set-face-font face (if (memq 'italic (face-font face t))
			      '(bold italic) '(bold))
		     t)
    (let (font)
      (if (null frame)
	  (let ((frames (frame-list)))
	    ;; Make this face bold in global-face-data.
	    (make-face-bold face t noerror)
	    ;; Make this face bold in each frame.
	    (while frames
	      (make-face-bold face (car frames) noerror)
	      (setq frames (cdr frames))))
	(setq face (internal-get-face face frame))
	(setq font (or (face-font face frame)
		       (face-font face t)))
	(if (listp font)
	    (setq font nil))
	(setq font (or font
		       (face-font 'default frame)
		       (cdr (assq 'font (frame-parameters frame)))))
	(or (and font (make-face-bold-internal face frame font))
	    ;; We failed to find a bold version of the font.
	    noerror
	    (error "No bold version of %S" font))))))

(defun make-face-bold-internal (face frame font)
  (let (f2)
    (or (and (setq f2 (x-make-font-bold font))
	     (internal-try-face-font face f2 frame))
	(and (setq f2 (x-make-font-demibold font))
	     (internal-try-face-font face f2 frame)))))

(defun make-face-italic (face &optional frame noerror)
  "Make the font of the given face be italic, if possible.  
If NOERROR is non-nil, return nil on failure."
  (interactive (list (read-face-name "Make which face italic: ")))
  ;; Set the italic-p flag, first of all.
  (internal-set-face-1 face nil t 11 frame)
  (if (and (eq frame t) (listp (face-font face t)))
      (set-face-font face (if (memq 'bold (face-font face t))
			      '(bold italic) '(italic))
		     t)
    (let (font)
      (if (null frame)
	  (let ((frames (frame-list)))
	    ;; Make this face italic in global-face-data.
	    (make-face-italic face t noerror)
	    ;; Make this face italic in each frame.
	    (while frames
	      (make-face-italic face (car frames) noerror)
	      (setq frames (cdr frames))))
	(setq face (internal-get-face face frame))
	(setq font (or (face-font face frame)
		       (face-font face t)))
	(if (listp font)
	    (setq font nil))
	(setq font (or font
		       (face-font 'default frame)
		       (cdr (assq 'font (frame-parameters frame)))))
	(or (and font (make-face-italic-internal face frame font))
	    ;; We failed to find an italic version of the font.
	    noerror
	    (error "No italic version of %S" font))))))

(defun make-face-italic-internal (face frame font)
  (let (f2)
    (or (and (setq f2 (x-make-font-italic font))
	     (internal-try-face-font face f2 frame))
	(and (setq f2 (x-make-font-oblique font))
	     (internal-try-face-font face f2 frame)))))

(defun make-face-bold-italic (face &optional frame noerror)
  "Make the font of the given face be bold and italic, if possible.  
If NOERROR is non-nil, return nil on failure."
  (interactive (list (read-face-name "Make which face bold-italic: ")))
  ;; Set the bold-p and italic-p flags, first of all.
  (internal-set-face-1 face nil t 10 frame)
  (internal-set-face-1 face nil t 11 frame)
  (if (and (eq frame t) (listp (face-font face t)))
      (set-face-font face '(bold italic) t)
    (let (font)
      (if (null frame)
	  (let ((frames (frame-list)))
	    ;; Make this face bold-italic in global-face-data.
	    (make-face-bold-italic face t noerror)
	    ;; Make this face bold in each frame.
	    (while frames
	      (make-face-bold-italic face (car frames) noerror)
	      (setq frames (cdr frames))))
	(setq face (internal-get-face face frame))
	(setq font (or (face-font face frame)
		       (face-font face t)))
	(if (listp font)
	    (setq font nil))
	(setq font (or font
		       (face-font 'default frame)
		       (cdr (assq 'font (frame-parameters frame)))))
	(or (and font (make-face-bold-italic-internal face frame font))
	    ;; We failed to find a bold italic version.
	    noerror
	    (error "No bold italic version of %S" font))))))

(defun make-face-bold-italic-internal (face frame font)
  (let (f2 f3)
    (or (and (setq f2 (x-make-font-italic font))
	     (not (equal font f2))
	     (setq f3 (x-make-font-bold f2))
	     (not (equal f2 f3))
	     (internal-try-face-font face f3 frame))
	(and (setq f2 (x-make-font-oblique font))
	     (not (equal font f2))
	     (setq f3 (x-make-font-bold f2))
	     (not (equal f2 f3))
	     (internal-try-face-font face f3 frame))
	(and (setq f2 (x-make-font-italic font))
	     (not (equal font f2))
	     (setq f3 (x-make-font-demibold f2))
	     (not (equal f2 f3))
	     (internal-try-face-font face f3 frame))
	(and (setq f2 (x-make-font-oblique font))
	     (not (equal font f2))
	     (setq f3 (x-make-font-demibold f2))
	     (not (equal f2 f3))
	     (internal-try-face-font face f3 frame)))))

(defun make-face-unbold (face &optional frame noerror)
  "Make the font of the given face be non-bold, if possible.  
If NOERROR is non-nil, return nil on failure."
  (interactive (list (read-face-name "Make which face non-bold: ")))
  ;; Clear the bold-p flag, first of all.
  (internal-set-face-1 face nil nil 10 frame)
  (if (and (eq frame t) (listp (face-font face t)))
      (set-face-font face (if (memq 'italic (face-font face t))
			      '(italic) nil)
		     t)
    (let (font font1)
      (if (null frame)
	  (let ((frames (frame-list)))
	    ;; Make this face unbold in global-face-data.
	    (make-face-unbold face t noerror)
	    ;; Make this face unbold in each frame.
	    (while frames
	      (make-face-unbold face (car frames) noerror)
	      (setq frames (cdr frames))))
	(setq face (internal-get-face face frame))
	(setq font1 (or (face-font face frame)
			(face-font face t)))
	(if (listp font1)
	    (setq font1 nil))
	(setq font1 (or font1
			(face-font 'default frame)
			(cdr (assq 'font (frame-parameters frame)))))
	(setq font (and font1 (x-make-font-unbold font1)))
	(or (if font (internal-try-face-font face font frame))
	    noerror
	    (error "No unbold version of %S" font1))))))

(defun make-face-unitalic (face &optional frame noerror)
  "Make the font of the given face be non-italic, if possible.  
If NOERROR is non-nil, return nil on failure."
  (interactive (list (read-face-name "Make which face non-italic: ")))
  ;; Clear the italic-p flag, first of all.
  (internal-set-face-1 face nil nil 11 frame)
  (if (and (eq frame t) (listp (face-font face t)))
      (set-face-font face (if (memq 'bold (face-font face t))
			      '(bold) nil)
		     t)
    (let (font font1)
      (if (null frame)
	  (let ((frames (frame-list)))
	    ;; Make this face unitalic in global-face-data.
	    (make-face-unitalic face t noerror)
	    ;; Make this face unitalic in each frame.
	    (while frames
	      (make-face-unitalic face (car frames) noerror)
	      (setq frames (cdr frames))))
	(setq face (internal-get-face face frame))
	(setq font1 (or (face-font face frame)
			(face-font face t)))
	(if (listp font1)
	    (setq font1 nil))
	(setq font1 (or font1
			(face-font 'default frame)
			(cdr (assq 'font (frame-parameters frame)))))
	(setq font (and font1 (x-make-font-unitalic font1)))
	(or (if font (internal-try-face-font face font frame))
	    noerror
	    (error "No unitalic version of %S" font1))))))

(defvar list-faces-sample-text
  "abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  "*Text string to display as the sample text for `list-faces-display'.")

;; The name list-faces would be more consistent, but let's avoid a conflict
;; with Lucid, which uses that name differently.
(defun list-faces-display ()
  "List all faces, using the same sample text in each.
The sample text is a string that comes from the variable
`list-faces-sample-text'.

It is possible to give a particular face name different appearances in
different frames.  This command shows the appearance in the
selected frame."
  (interactive)
  (let ((faces (sort (face-list) (function string-lessp)))
	(face nil)
	(frame (selected-frame))
	disp-frame window
        (face-name-max-length
         (car (sort (mapcar (function string-width)
			    (mapcar (function symbol-name) (face-list)))
                    (function >)))))
    (with-output-to-temp-buffer "*Faces*"
      (save-excursion
	(set-buffer standard-output)
	(setq truncate-lines t)
	(while faces
	  (setq face (car faces))
	  (setq faces (cdr faces))
	  (insert (format 
                   (format "%%-%ds "
                           face-name-max-length)
                   (symbol-name face)))
	  (let ((beg (point)))
	    (insert list-faces-sample-text)
	    (insert "\n")
	    (put-text-property beg (1- (point)) 'face face)
	    ;; If the sample text has multiple lines, line up all of them.
	    (goto-char beg)
	    (forward-line 1)
	    (while (not (eobp))
	      (insert-char ?  (1+ face-name-max-length))
	      (forward-line 1))))
	(goto-char (point-min)))
      (print-help-return-message))
    ;; If the *Faces* buffer appears in a different frame,
    ;; copy all the face definitions from FRAME,
    ;; so that the display will reflect the frame that was selected.
    (setq window (get-buffer-window (get-buffer "*Faces*") t))
    (setq disp-frame (if window (window-frame window)
		       (car (frame-list))))
    (or (eq frame disp-frame)
	(let ((faces (face-list)))
	  (while faces
	    (copy-face (car faces) (car faces) frame disp-frame)
	    (setq faces (cdr faces)))))))

(defun describe-face (face)
  "Display the properties of face FACE."
  (interactive (list (read-face-name "Describe face: ")))
  (with-output-to-temp-buffer "*Help*"
    (princ "Properties of face `")
    (princ (face-name face))
    (princ "':") (terpri)
    (princ "Foreground: ") (princ (face-foreground face)) (terpri)
    (princ "Background: ") (princ (face-background face)) (terpri)
    (princ "      Font: ") (princ (face-font face)) (terpri)
    (princ "Underlined: ") (princ (if (face-underline-p face) "yes" "no")) (terpri)
    (princ "   Stipple: ") (princ (or (face-stipple face) "none")) (terpri)
    (terpri)
    (princ "Documentation:") (terpri)
    (let ((doc (face-documentation face)))
      (if doc
	  (princ doc)
	(princ "not documented as a face.")))
    (print-help-return-message)))

;;; Setting a face based on a SPEC.

(defun face-attr-match-p (face attrs &optional frame)
  (or frame (setq frame (selected-frame)))
  (and (face-attr-match-1 face frame attrs ':inverse-video
			  'face-inverse-video-p)
       (if (face-inverse-video-p face frame)
	   (and
	    (face-attr-match-1 face frame attrs
			       ':foreground 'face-background
			       (cdr (assq 'foreground-color
					  (frame-parameters frame))))
	    (face-attr-match-1 face frame attrs
			       ':background 'face-foreground 
			       (cdr (assq 'background-color
					  (frame-parameters frame)))))
	 (and
	  (face-attr-match-1 face frame attrs ':foreground 'face-foreground)
	  (face-attr-match-1 face frame attrs ':background 'face-background)))
       (face-attr-match-1 face frame attrs ':stipple 'face-stipple)
       (face-attr-match-1 face frame attrs ':bold 'face-bold-p)
       (face-attr-match-1 face frame attrs ':italic 'face-italic-p)
       (face-attr-match-1 face frame attrs ':underline 'face-underline-p)
))

(defun face-attr-match-1 (face frame plist property function
			       &optional defaultval)
  (while (and plist (not (eq (car plist) property)))
    (setq plist (cdr (cdr plist))))
  (equal (funcall function face frame)
	 (if plist
	     (nth 1 plist)
	   (or defaultval
	       (funcall function 'default frame)))))

(defun face-spec-match-p (face spec &optional frame)
  "Return t if FACE, on FRAME, matches what SPEC says it should look like."
  (face-attr-match-p face (face-spec-choose spec frame) frame))

(defun face-attr-construct (face &optional frame)
  "Return a defface-style attribute list for FACE, as it exists on FRAME." 
  (let (result)
    (if (face-inverse-video-p face frame)
	(progn
	  (setq result (cons ':inverse-video (cons t result)))
	  (or (face-attr-match-1 face frame nil
				 ':foreground 'face-background
				 (cdr (assq 'foreground-color
					    (frame-parameters frame))))
	      (setq result (cons ':foreground
				 (cons (face-foreground face frame) result))))
	  (or (face-attr-match-1 face frame nil
				 ':background 'face-foreground 
				 (cdr (assq 'background-color
					    (frame-parameters frame))))
	      (setq result (cons ':background
				 (cons (face-background face frame) result)))))
      (if (face-foreground face frame)
	  (setq result (cons ':foreground
			     (cons (face-foreground face frame) result))))
      (if (face-background face frame)
	  (setq result (cons ':background
			     (cons (face-background face frame) result)))))
    (if (face-stipple face frame)
	(setq result (cons ':stipple
			   (cons (face-stipple face frame) result))))
    (if (face-bold-p face frame)
	(setq result (cons ':bold
			   (cons (face-bold-p face frame) result))))
    (if (face-italic-p face frame)
	(setq result (cons ':italic
			   (cons (face-italic-p face frame) result))))
    (if (face-underline-p face frame)
	(setq result (cons ':underline
			   (cons (face-underline-p face frame) result))))
    result))
    
;; Choose the proper attributes for FRAME, out of SPEC.
(defun face-spec-choose (spec &optional frame)
  (or frame (setq frame (selected-frame)))
  (let ((tail spec)
	result)
    (while tail
      (let* ((entry (car tail))
	     (display (nth 0 entry))
	     (attrs (nth 1 entry)))
	(setq tail (cdr tail))
	(when (face-spec-set-match-display display frame)
	  (setq result attrs tail nil))))
    result))

(defun face-spec-set (face spec &optional frame)
  "Set FACE's face attributes according to the first matching entry in SPEC.
If optional FRAME is non-nil, set it for that frame only.
If it is nil, then apply SPEC to each frame individually.
See `defface' for information about SPEC."
  (if frame
      (let ((attrs (face-spec-choose spec frame)))
	(when attrs
	  ;; If the font was set automatically, clear it out
	  ;; to allow it to be set it again.
	  (unless (face-font-explicit face frame)
	    (set-face-font face nil frame))
	  (modify-face face '(nil) '(nil) nil nil nil nil nil frame)
	  (face-spec-set-1 face frame attrs ':foreground 'set-face-foreground)
	  (face-spec-set-1 face frame attrs ':background 'set-face-background)
	  (face-spec-set-1 face frame attrs ':stipple 'set-face-stipple)
	  (face-spec-set-1 face frame attrs ':bold 'set-face-bold-p)
	  (face-spec-set-1 face frame attrs ':italic 'set-face-italic-p)
	  (face-spec-set-1 face frame attrs ':underline 'set-face-underline-p)
	  (face-spec-set-1 face frame attrs ':inverse-video
			   'set-face-inverse-video-p)))
    (let ((frames (frame-list))
	  frame)
      (while frames
	(setq frame (car frames)
	      frames (cdr frames))
	(face-spec-set face (or (get face 'saved-face)
				(get face 'face-defface-spec))
		       frame)
	(face-spec-set face spec frame)))))

(defun face-spec-set-1 (face frame plist property function)
  (while (and plist (not (eq (car plist) property)))
    (setq plist (cdr (cdr plist))))
  (if plist
      (funcall function face (nth 1 plist) frame)))

(defun face-spec-set-match-display (display frame)
  "Non-nil iff DISPLAY matches FRAME.
DISPLAY is part of a spec such as can be used in `defface'.
If FRAME is nil, the current FRAME is used."
  (let* ((conjuncts display)
	 conjunct req options
	 ;; t means we have succeeded against all
	 ;; the conjunts in DISPLAY that have been tested so far.
	 (match t))
    (if (eq conjuncts t)
	(setq conjuncts nil))
    (while (and conjuncts match)
      (setq conjunct (car conjuncts)
	    conjuncts (cdr conjuncts)
	    req (car conjunct)
	    options (cdr conjunct)
	    match (cond ((eq req 'type)
			 (memq window-system options))
			((eq req 'class)
			 (memq (frame-parameter frame 'display-type) options))
			((eq req 'background)
			 (memq (frame-parameter frame 'background-mode)
			       options))
			(t
			 (error "Unknown req `%S' with options `%S'" 
				req options)))))
    match))

;; Like x-create-frame but also set up the faces.

(defun x-create-frame-with-faces (&optional parameters)
  ;; Read this frame's geometry resource, if it has an explicit name,
  ;; and put the specs into PARAMETERS.
  (let* ((name (or (cdr (assq 'name parameters))
		   (cdr (assq 'name default-frame-alist))))
	 (x-resource-name name)
	 (res-geometry (if name (x-get-resource "geometry" "Geometry"))))
    (if res-geometry
	(let ((parsed (x-parse-geometry res-geometry)))
	  ;; If the resource specifies a position,
	  ;; call the position and size "user-specified".
	  (if (or (assq 'top parsed) (assq 'left parsed))
	      (setq parsed (append '((user-position . t) (user-size . t))
				   parsed)))
	  ;; Put the geometry parameters at the end.
	  ;; Copy default-frame-alist so that they go after it.
	  (setq parameters (append parameters default-frame-alist parsed)))))

  (if default-enable-multibyte-characters
      ;; If an ASCII font is specified in PARAMETERS, we try to create
      ;; a fontset from it, and use it for the new frame.
      (condition-case nil
	  (let ((font (cdr (assq 'font parameters))))
	    (if (and font
		     (not (query-fontset font)))
		(setq parameters
		      (cons (cons 'font (create-fontset-from-ascii-font font))
			    parameters))))
	(error nil)))

  (let (frame)
    (if (null global-face-data)
	(progn
	  (setq frame (x-create-frame parameters))
	  (frame-set-background-mode frame))
      (let* ((visibility-spec (assq 'visibility parameters))
	     success faces rest)
	(setq frame (x-create-frame (cons '(visibility . nil) parameters)))
	(unwind-protect
	    (progn
	      ;; Copy the face alist, copying the face vectors
	      ;; and emptying out their attributes.
	      (setq faces
		    (mapcar '(lambda (elt)
			       (cons (car elt)
				     (vector 'face
					     (face-name (cdr elt))
					     (face-id (cdr elt))
					     nil
					     nil nil nil nil
					     nil nil nil nil)))
			    global-face-data))
	      (set-frame-face-alist frame faces)

	      ;; Handle the reverse-video frame parameter
	      ;; and X resource.  x-create-frame does not handle this one.
	      (if (cdr (or (assq 'reverse parameters)
			   (assq 'reverse default-frame-alist)
			   (let ((resource (x-get-resource "reverseVideo"
							   "ReverseVideo")))
			     (if resource
				 (cons nil (member (downcase resource)
						   '("on" "true")))))))
		  (let* ((params (frame-parameters frame))
			 (bg (cdr (assq 'foreground-color params)))
			 (fg (cdr (assq 'background-color params))))
		    (modify-frame-parameters frame
					     (list (cons 'foreground-color fg)
						   (cons 'background-color bg)))
		    (if (equal bg (cdr (assq 'border-color params)))
			(modify-frame-parameters frame
						 (list (cons 'border-color fg))))
		    (if (equal bg (cdr (assq 'mouse-color params)))
			(modify-frame-parameters frame
						 (list (cons 'mouse-color fg))))
		    (if (equal bg (cdr (assq 'cursor-color params)))
			(modify-frame-parameters frame
						 (list (cons 'cursor-color fg))))))

	      (frame-set-background-mode frame)

	      (face-set-after-frame-default frame)

	      ;; Make the frame visible, if desired.
	      (if (null visibility-spec)
		  (make-frame-visible frame)
		(modify-frame-parameters frame (list visibility-spec)))
	      (setq success t))
	  (or success
	      (delete-frame frame)))))
    frame))

;; Update a frame's faces after the frame font changes.
;; This is called from modify-frame-parameters
;; as well as from elsewhere in this file.
(defun face-set-after-frame-default (frame)
  (let ((rest (frame-face-alist frame)))
    (while rest
      ;; Set up each face, first from the defface information,
      ;; then the global face data, and then the X resources.
      (let* ((face (car (car rest)))
	     (spec (or (get face 'customized-face)
		       (get face 'saved-face)
		       (get face 'face-defface-spec)))
	     (global (cdr (assq face global-face-data)))
	     (local (cdr (car rest))))
	(when spec
	  (face-spec-set face spec frame))
	(face-fill-in face global frame)
	(make-face-x-resource-internal local frame))
      (setq rest (cdr rest)))))

(defcustom frame-background-mode nil
  "*The brightness of the background.
Set this to the symbol dark if your background color is dark, light if
your background is light, or nil (default) if you want Emacs to
examine the brightness for you."
  :group 'faces
  :set #'(lambda (var value)
	   (set var value)
	   (mapcar 'frame-set-background-mode (frame-list)))
  :initialize 'custom-initialize-changed
  :type '(choice (choice-item dark) 
		 (choice-item light)
		 (choice-item :tag "default" nil)))

(defun frame-set-background-mode (frame)
  "Set up the `background-mode' and `display-type' frame parameters for FRAME."
  (unless (eq (framep frame) t)
    (let ((bg-resource (x-get-resource ".backgroundMode"
				       "BackgroundMode"))
	  (params (frame-parameters frame))
	  (bg-mode))
      (setq bg-mode
	    (cond (frame-background-mode)
		  (bg-resource (intern (downcase bg-resource)))
		  ((< (apply '+ (x-color-values
				 (cdr (assq 'background-color params))
				 frame))
		      ;; Just looking at the screen,
		      ;; colors whose values add up to .6 of the white total
		      ;; still look dark to me.
		      (* (apply '+ (x-color-values "white" frame)) .6))
		   'dark)
		  (t 'light)))
      (modify-frame-parameters frame
			       (list (cons 'background-mode bg-mode)
				     (cons 'display-type
					   (cond ((x-display-color-p frame)
						  'color)
						 ((x-display-grayscale-p frame)
						  'grayscale)
						 (t 'mono))))))))

;; Update a frame's faces when we change its default font.
(defun frame-update-faces (frame) nil)

;; Update the colors of FACE, after FRAME's own colors have been changed.
;; This applies only to faces with global color specifications
;; that are not simple constants.
(defun frame-update-face-colors (frame)
  (frame-set-background-mode frame)
  (let ((faces global-face-data))
    (while faces
      (condition-case nil
	  (let* ((data (cdr (car faces)))
		 (face (car (car faces)))
		 (foreground (face-foreground data))
		 (background (face-background data)))
	    ;; If the global spec is a specific color,
	    ;; which doesn't depend on the frame's attributes,
	    ;; we don't need to recalculate it now.
	    (or (listp foreground)
		(setq foreground nil))
	    (or (listp background)
		(setq background nil))
	    ;; If we are going to frob this face at all,
	    ;; reinitialize it first.
	    (if (or foreground background)
		(progn (set-face-foreground face nil frame)
		       (set-face-background face nil frame)))
	    (if foreground
		(face-try-color-list 'set-face-foreground
				     face foreground frame))
	    (if background
		(face-try-color-list 'set-face-background
				     face background frame)))
	(error nil))
      (setq faces (cdr faces)))))

;; Fill in the face FACE from frame-independent face data DATA.
;; DATA should be the non-frame-specific ("global") face vector
;; for the face.  FACE should be a face name or face object.
;; FRAME is the frame to act on; it must be an actual frame, not nil or t.
(defun face-fill-in (face data frame)
  (condition-case nil
      (let ((foreground (face-foreground data))
	    (background (face-background data))
	    (font (face-font data))
	    (stipple (face-stipple data)))
	(if (face-underline-p data)
	    (set-face-underline-p face (face-underline-p data) frame))
	(if foreground
	    (face-try-color-list 'set-face-foreground
				 face foreground frame))
	(if background
	    (face-try-color-list 'set-face-background
				 face background frame))
	(if (listp font)
	    (let ((bold (memq 'bold font))
		  (italic (memq 'italic font)))
	      (cond ((and bold italic)
		     (make-face-bold-italic face frame))
		    (bold
		     (make-face-bold face frame))
		    (italic
		     (make-face-italic face frame))))
	  (if font
	      (set-face-font face font frame)))
	(if stipple
	    (set-face-stipple face stipple frame)))
    (error nil)))

;; Assuming COLOR is a valid color name,
;; return t if it can be displayed on FRAME.
(defun face-color-supported-p (frame color background-p)
  (and window-system
       (or (x-display-color-p frame)
	   ;; A black-and-white display can implement these.
	   (member color '("black" "white"))
	   ;; A black-and-white display can fake gray for background.
	   (and background-p
		(face-color-gray-p color frame))
	   ;; A grayscale display can implement colors that are gray (more or less).
	   (and (x-display-grayscale-p frame)
		(face-color-gray-p color frame)))))

;; Use FUNCTION to store a color in FACE on FRAME.
;; COLORS is either a single color or a list of colors.
;; If it is a list, try the colors one by one until one of them
;; succeeds.  We signal an error only if all the colors failed.
;; t as COLORS or as an element of COLORS means to invert the face.
;; That can't fail, so any subsequent elements after the t are ignored.
(defun face-try-color-list (function face colors frame)
  (if (stringp colors)
      (if (face-color-supported-p frame colors
				  (eq function 'set-face-background))
	  (funcall function face colors frame))
    (if (eq colors t)
	(set-face-inverse-video-p face t frame)
      (let (done)
	(while (and colors (not done))
	  (if (or (memq (car colors) '(t underline nil))
		  (face-color-supported-p frame (car colors)
					  (eq function 'set-face-background)))
	      (if (cdr colors)
		  ;; If there are more colors to try, catch errors
		  ;; and set `done' if we succeed.
		  (condition-case nil
		      (progn
			(cond ((eq (car colors) t)
			       (set-face-inverse-video-p face t frame))
			      ((eq (car colors) 'underline)
			       (set-face-underline-p face t frame))
			      (t
			       (funcall function face (car colors) frame)))
			(setq done t))
		    (error nil))
		;; If this is the last color, let the error get out if it fails.
		;; If it succeeds, we will exit anyway after this iteration.
		(cond ((eq (car colors) t)
		       (set-face-inverse-video-p face t frame))
		      ((eq (car colors) 'underline)
		       (set-face-underline-p face t frame))
		      (t
		       (funcall function face (car colors) frame)))))
	  (setq colors (cdr colors)))))))

;;; Make the standard faces.
;;; The C code knows the default and modeline faces as faces 0 and 1,
;;; so they must be the first two faces made.
(make-face 'default)
(make-face 'modeline)
(make-face 'highlight)

;; These aren't really special in any way, but they're nice to have around.

(make-face 'bold)
(make-face 'italic)
(make-face 'bold-italic)
(make-face 'region)
(make-face 'secondary-selection)
(make-face 'underline)

(setq region-face (face-id 'region))

(defgroup basic-faces nil
  "The standard faces of Emacs."
  :prefix "huh"
  :group 'faces)

;; Specify how these faces look, and their documentation.
(let ((all '((bold "Use bold font." ((t (:bold t))))
	     (bold-italic "Use bold italic font." ((t (:bold t :italic t))))
	     (italic "Use italic font." ((t (:italic t))))
	     (underline "Underline text." ((t (:underline t))))
	     (default "Used for text not covered by other faces." ((t nil)))
	     (highlight "Highlight text in some way."
			((((class color) (background light))
			  (:background "darkseagreen2"))
			 (((class color) (background dark))
			  (:background "darkolivegreen"))
			 (t (:inverse-video t))))
	     (modeline "Used for displaying the modeline."
		       ((t (:inverse-video t))))
	     (region "Used for displaying the region."
		     ((((class color) (background dark))
		       (:background "blue"))
		      (t (:background "gray"))))
	     (secondary-selection
	      "Used for displaying the secondary selection."
	      ((((class color) (background light))
		(:background "paleturquoise"))
	       (((class color) (background dark))
		(:background "darkslateblue"))
	       (t (:inverse-video t))))))
      entry symbol doc spec)
  (while all
    (setq entry (car all)
	  all (cdr all)
	  symbol (nth 0 entry)
	  doc (nth 1 entry)
	  spec (nth 2 entry))
    (custom-add-to-group 'basic-faces symbol 'custom-face)
    (put symbol 'face-documentation doc)
    (put symbol 'face-defface-spec spec)))

(provide 'faces)

;;; faces.el ends here
