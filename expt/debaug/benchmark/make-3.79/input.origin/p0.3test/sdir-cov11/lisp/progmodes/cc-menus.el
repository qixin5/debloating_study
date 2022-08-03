;;; cc-menus.el --- imenu support for CC Mode

;; Copyright (C) 1985,87,92,93,94,95,96,97,98 Free Software Foundation, Inc.

;; Authors:    1998 Barry A. Warsaw and Martin Stjernholm
;;             1992-1997 Barry A. Warsaw
;;             1987 Dave Detlefs and Stewart Clamen
;;             1985 Richard M. Stallman
;; Maintainer: bug-cc-mode@gnu.org
;; Created:    22-Apr-1997 (split from cc-mode.el)
;; Version:    See cc-mode.el
;; Keywords:   c languages oop

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

;; Pull in Imenu when compiling, if it exists
(eval-when-compile
  (condition-case nil
      (require 'imenu)
    (error nil)))


;; imenu integration
(defvar cc-imenu-c-prototype-macro-regexp nil
  "RE matching macro names used to conditionally specify function prototypes.

For example:

    #ifdef __STDC__
      #define _P(x) x
    #else
      #define _P(x) /*nothing*/
    #endif

    int main _P( (int argc, char *argv[]) )

A sample value might look like: `\\(_P\\|_PROTO\\)'.")

(defvar cc-imenu-c++-generic-expression
  (` 
   (
    ;; Try to match ::operator definitions first. Otherwise `X::operator new ()'
    ;; will be incorrectly recognised as function `new ()' because the regexps
    ;; work by backtracking from the end of the definition.
    (nil
     (, 
      (concat
       "^\\<.*"
       "[^a-zA-Z0-9_:<>~]"                    ; match any non-identifier char
                                              ; (note: this can be `\n')
       "\\("
          "\\([a-zA-Z0-9_:<>~]*::\\)?"        ; match an operator
          "operator\\>[ \t]*"
          "\\(()\\|[^(]*\\)"                  ; special case for `()' operator
       "\\)"

       "[ \t]*([^)]*)[ \t]*[^ \t;]"           ; followed by ws, arg list,
                                              ; require something other than
                                              ; a `;' after the (...) to
                                              ; avoid prototypes.  Can't
                                              ; catch cases with () inside
                                              ; the parentheses surrounding
                                              ; the parameters.  e.g.:
                                              ; `int foo(int a=bar()) {...}'
       )) 1)
    ;; Special case to match a line like `main() {}'
    ;; e.g. no return type, not even on the previous line.
    (nil
     (, 
      (concat
       "^"
       "\\([a-zA-Z_][a-zA-Z0-9_:<>~]*\\)"     ; match function name
       "[ \t]*("			      ; see above, BUT
       "[ \t]*\\([^ \t(*][^)]*\\)?)"          ; the arg list must not start
       "[ \t]*[^ \t;(]"                       ; with an asterisk or parentheses
       )) 1)
    ;; General function name regexp
    (nil
     (, 
      (concat
       "^\\<.*"                               ; line MUST start with word char
       "[^a-zA-Z0-9_:<>~]"                    ; match any non-identifier char
       "\\([a-zA-Z_][a-zA-Z0-9_:<>~]*\\)"     ; match function name
       "[ \t]*("			      ; see above, BUT
       "[ \t]*\\([^ \t(*][^)]*\\)?)"          ; the arg list must not start
       "[ \t]*[^ \t;(]"                       ; with an asterisk or parentheses
       )) 1)
    ;; Special case for definitions using phony prototype macros like:
    ;; `int main _PROTO( (int argc,char *argv[]) )'.
    ;; This case is only included if cc-imenu-c-prototype-macro-regexp is set.
    ;; Only supported in c-code, so no `:<>~' chars in function name!
    (,@ (if cc-imenu-c-prototype-macro-regexp
            (` ((nil
                 (,
                  (concat
                   "^\\<.*"                   ; line MUST start with word char
                   "[^a-zA-Z0-9_]"            ; match any non-identifier char
                   "\\([a-zA-Z_][a-zA-Z0-9_]*\\)"       ; match function name
                   "[ \t]*"                   ; whitespace before macro name
                   cc-imenu-c-prototype-macro-regexp
                   "[ \t]*("                  ; ws followed by first paren.
                   "[ \t]*([^)]*)[ \t]*)[ \t]*[^ \t;]" ; see above
                   )) 1)))))
    ;; Class definitions
    ("Class" 
     (, (concat 
         "^"                                  ; beginning of line is required
         "\\(template[ \t]*<[^>]+>[ \t]*\\)?" ; there may be a `template <...>'
         "class[ \t]+"
         "\\("                                ; the string we want to get
         "[a-zA-Z0-9_]+"                      ; class name
         "\\(<[^>]+>\\)?"                     ; possibly explicitely specialized
         "\\)"
         "[ \t]*[:{]"
         )) 2)))
  "Imenu generic expression for C++ mode.  See `imenu-generic-expression'.")
 
(defvar cc-imenu-c-generic-expression
  cc-imenu-c++-generic-expression
  "Imenu generic expression for C mode.  See `imenu-generic-expression'.")

(defvar cc-imenu-java-generic-expression
  (`
   ((nil
     (,
      (concat
       "^\\([ \t]\\)*"
       "\\([A-Za-z0-9_-]+[ \t]+\\)?"	      ; type specs; there can be
        "\\([A-Za-z0-9_-]+[ \t]+\\)?"	      ; more than 3 tokens, right?
       "\\([A-Za-z0-9_-]+[ \t]*[[]?[]]?\\)"
       "\\([ \t]\\)"
       "\\([A-Za-z0-9_-]+\\)"		      ; the string we want to get
       "\\([ \t]*\\)+("
       "[][a-zA-Z,_1-9\n \t]*"   ; arguments
       ")[ \t]*"
;       "[^;(]"
       "[,a-zA-Z_1-9\n \t]*{"               
       )) 6)))
  "Imenu generic expression for Java mode.  See `imenu-generic-expression'.")

;;                        *Warning for cc-mode developers* 
;;
;; `cc-imenu-objc-generic-expression' elements depend on
;; `cc-imenu-c++-generic-expression'. So if you change this
;; expression, you need to change following variables,
;; `cc-imenu-objc-generic-expression-*-index',
;; too. `cc-imenu-objc-function' uses these *-index variables, in
;; order to know where the each regexp *group \\(foobar\\)* elements
;; are started.
;;
;; *-index variables are initialized during `cc-imenu-objc-generic-expression' 
;; being initialized. 
;;

;; Internal variables
(defvar cc-imenu-objc-generic-expression-noreturn-index nil)
(defvar cc-imenu-objc-generic-expression-general-func-index nil)
(defvar cc-imenu-objc-generic-expression-proto-index nil)
(defvar cc-imenu-objc-generic-expression-objc-base-index nil)

(defvar cc-imenu-objc-generic-expression 
  (concat 
   ;;
   ;; For C 
   ;;
   ;; > Special case to match a line like `main() {}'
   ;; > e.g. no return type, not even on the previous line.
   ;; Pick a token by (match-string 1)
   (car (cdr (nth 1 cc-imenu-c++-generic-expression))) ; -> index += 2
   (prog2 (setq cc-imenu-objc-generic-expression-noreturn-index 1) "")
   "\\|"
   ;; > General function name regexp
   ;; Pick a token by  (match-string 3)
   (car (cdr (nth 2 cc-imenu-c++-generic-expression))) ; -> index += 2
   (prog2 (setq cc-imenu-objc-generic-expression-general-func-index 3) "")
   ;; > Special case for definitions using phony prototype macros like:
   ;; > `int main _PROTO( (int argc,char *argv[]) )'.
   ;; Pick a token by  (match-string 5)
   (if cc-imenu-c-prototype-macro-regexp
       (concat    
	"\\|"
	(car (cdr (nth 3 cc-imenu-c++-generic-expression))) ; -> index += 1
	(prog2 (setq cc-imenu-objc-generic-expression-objc-base-index 6) "")
	)
     (prog2 (setq cc-imenu-objc-generic-expression-objc-base-index 5) "")
     "")				; -> index += 0
   (prog2 (setq cc-imenu-objc-generic-expression-proto-index 5) "")
   ;;
   ;; For Objective-C
   ;; Pick a token by (match-string 5 or 6)
   ;;
   "\\|\\("					     
   "^[-+][:a-zA-Z0-9()*_<>\n\t ]*[;{]"        ; Methods
   "\\|" 
   "^@interface[\t ]+[a-zA-Z0-9_]+[\t ]*:"  
   "\\|" 
   "^@interface[\t ]+[a-zA-Z0-9_]+[\t ]*([a-zA-Z0-9_]+)"
   "\\|" 
   ;; For NSObject, NSProxy and Object... They don't have super class.
   "^@interface[\t ]+[a-zA-Z0-9_]+[\t ]*.*$"
   "\\|" 
   "^@implementation[\t ]+[a-zA-Z0-9_]+[\t ]*([a-zA-Z0-9_]+)"
   "\\|" 
   "^@implementation[\t ]+[a-zA-Z0-9_]+"
   "\\|" 
   "^@protocol[\t ]+[a-zA-Z0-9_]+" "\\)")
  "Imenu generic expression for ObjC mode.  See `imenu-generic-expression'.")


;; Imenu support for objective-c uses functions.
(defsubst cc-imenu-objc-method-to-selector (method)
  "Return the objc selector style string of METHOD.
Example: 
- perform: (SEL)aSelector withObject: object1 withObject: object2; /* METHOD */
=>
-perform:withObject:withObject:withObject: /* selector */"
  (let ((return "")			; String to be returned
	(p 0)				; Current scanning position in METHOD  
	(pmax (length method))		; 
	char				; Current scanning target
	(betweenparen 0)		; CHAR is in parentheses.
	argreq				; An argument is required.
	inargvar)			; position of CHAR is in an argument variable.
    (while (< p pmax)
      (setq char (aref method p)
	    p (1+ p))
      (cond
       ;; Is CHAR part of a objc token?
       ((and (not inargvar)     ; Ignore if CHAR is part of an argument variable.
	     (eq 0 betweenparen) ; Ignore if CHAR is in parentheses.
	     (or (and (<= ?a char) (<= char ?z))
		 (and (<= ?A char) (<= char ?Z))
		 (and (<= ?0 char) (<= char ?9))
		 (= ?_ char)))
	(if argreq	
	    (setq inargvar t
		  argreq nil)
	  (setq return (concat return (char-to-string char)))))
       ;; Or a white space?
       ((and inargvar (or (eq ?\  char) (eq ?\n char)) 
	     (setq inargvar nil)))
       ;; Or a method separator?
       ;; If a method separator, the next token will be an argument variable.
       ((eq ?: char)			
	(setq argreq t			
	      return (concat return (char-to-string char))))
       ;; Or an open parentheses?
       ((eq ?\( char)
	(setq betweenparen (1+ betweenparen)))
       ;; Or a close parentheses?
       ((eq ?\) char)
	(setq betweenparen (1- betweenparen)))))
    return))

(defun cc-imenu-objc-remove-white-space  (str)
  "Remove all spaces and tabs from STR."
  (let ((return "")
	(p 0)
	(max (length str)) 
	char)
    (while (< p max)
      (setq char (aref str p))
      (setq p (1+ p))
      (if (or (= char ?\ ) (= char ?\t))
	  ()
	(setq return (concat return (char-to-string char)))))
    return))

(defun cc-imenu-objc-function ()
  "imenu supports for objc-mode."
  (let (methodlist
	clist
	;;
	;; OBJC, Cnoreturn, Cgeneralfunc, Cproto are constants.
	;;
	;;                  *Warning for developers* 
	;; These constants depend on `cc-imenu-c++-generic-expression'.
	;;
	(OBJC cc-imenu-objc-generic-expression-objc-base-index)
	;; Special case to match a line like `main() {}'
	(Cnoreturn cc-imenu-objc-generic-expression-noreturn-index)
	;; General function name regexp
	(Cgeneralfunc cc-imenu-objc-generic-expression-general-func-index)
	;; Special case for definitions using phony prototype macros like:
	(Cproto cc-imenu-objc-generic-expression-proto-index)
	langnum
	;;
	(classcount 0)
	toplist
	stupid
	str
	str2 
	(intflen (length "@interface"))
	(implen  (length "@implementation"))
	(prtlen  (length "@protocol"))
	(func
	 ;;
	 ;; Does this emacs has buffer-substring-no-properties? 
	 ;;
	 (if (fboundp 'buffer-substring-no-properties)
	     'buffer-substring-no-properties
	   'buffer-substring)))
    (goto-char (point-max))
    (imenu-progress-message stupid 0)
    ;;
    (while (re-search-backward cc-imenu-objc-generic-expression nil t)
      (imenu-progress-message stupid)
      (setq langnum (if (match-beginning OBJC) 
			OBJC
		      (cond
		       ((match-beginning Cproto) Cproto)
		       ((match-beginning Cgeneralfunc) Cgeneralfunc)
		       ((match-beginning Cnoreturn) Cnoreturn))))
      (setq str (funcall func (match-beginning langnum) (match-end langnum)))
      ;;
      (cond 
       ;;
       ;; C
       ;;
       ((not (eq langnum OBJC))
	(setq clist (cons (cons str (match-beginning langnum)) clist)))
       ;;
       ;; ObjC
       ;; 
       ;; An instance Method
       ((eq (aref str 0) ?-)
	(setq str (concat "-" (cc-imenu-objc-method-to-selector str)))
	(setq methodlist (cons (cons str
			      (match-beginning langnum))
			methodlist)))
       ;; A factory Method
       ((eq (aref str 0) ?+)
	(setq str (concat "+" (cc-imenu-objc-method-to-selector str)))
	(setq methodlist (cons (cons str
			      (match-beginning langnum))
			methodlist)))
       ;; Interface or implementation or protocol 
       ((eq (aref str 0) ?@)
	(setq classcount (1+ classcount))
	(cond 
	 ((and (> (length str) implen)
	       (string= (substring  str 0 implen) "@implementation"))
	  (setq str (substring str implen)
		str2 "@implementation"))
	 ((string= (substring  str 0 intflen) "@interface")
	  (setq str (substring str intflen)
		str2 "@interface"))
	 ((string= (substring  str 0 prtlen) "@protocol")
	  (setq str (substring str prtlen)
		str2 "@protocol")))
	(setq str (cc-imenu-objc-remove-white-space str))
	(setq methodlist (cons (cons str2
			      (match-beginning langnum))
			       methodlist))
	(setq toplist (cons nil (cons (cons str
					  methodlist) toplist))
	      methodlist nil))))
    ;; 
    (imenu-progress-message stupid 100)
    (if (eq (car toplist) nil)
	(setq toplist (cdr toplist)))

    ;; In this buffer, there is only one or zero @{interface|implementation|protocol}.
    (if (< classcount 2)
	(let ((classname (car (car toplist)))
	      (p (cdr (car (cdr (car toplist)))))
	      last)
	  (setq toplist (cons (cons classname p) (cdr (cdr (car toplist)))))
	  ;; Add C lang token
	  (if clist
	      (progn
		(setq last toplist)
		(while (cdr last)
		  (setq last (cdr last)))
		(setcdr last clist))))
      ;; Add C lang tokens as a sub menu
      (setq toplist (cons (cons "C" clist) toplist)))
    ;;
    toplist
    ))

;(defvar cc-imenu-pike-generic-expression
;  ())
; FIXME: Please contribute one!


(provide 'cc-menus)
;;; cc-menus.el ends here
