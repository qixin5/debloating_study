;;; sql.el --- specialized comint.el for SQL interpreters

;; Copyright (C) 1998, 1999  Free Software Foundation, Inc.

;; Author: Alex Schroeder <a.schroeder@bsiag.ch>
;; Maintainer: Alex Schroeder <a.schroeder@bsiag.ch>
;; Version: 1.4.5
;; Keywords: comm languages processes

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

;; Please send bug reports and bug fixes to the mailing list at
;; sql.el@gnu.org so that I can merge them into the master source.  If
;; you want to subscribe to the mailing list, send mail to
;; sql.el-request@gnu.org with 'subscribe' in the subject line.

;; You can get the latest version of this file from my homepage
;; <URL:http://www.geocities.com/TimesSquare/6120/emacs.html>.

;; This file provides a sql-mode and a sql-interactive-mode.  My goals
;; were two simple modes providing syntactic hilighting.  The
;; interactive mode had to provide a command-line history; the other
;; mode had to provide "send region/buffer to SQL interpreter"
;; functions.  "simple" in this context means easy to use, easy to
;; maintain and little or no bells and whistles.  

;; If anybody feels like extending this sql mode, take a look at the
;; above mentioned modes and write a sqlx-mode on top of this one.  If
;; this proves to be difficult, please suggest changes that will
;; facilitate your plans.

;; sql-interactive-mode is used to interact with a SQL interpreter
;; process in a SQLi buffer (usually called `*SQL*').  The SQLi buffer
;; is created by calling a SQL interpreter-specific entry function.  Do
;; *not* call sql-interactive-mode by itself.

;; The list of currently supported interpreters and the corresponding
;; entry function used to create the SQLi buffers is shown with
;; `sql-help' (M-x sql-help).

;; Since sql-interactive-mode is built on top of the general
;; command-interpreter-in-a-buffer mode (comint mode), it shares a
;; common base functionality, and a common set of bindings, with all
;; modes derived from comint mode.  This makes these modes easier to
;; use.

;; sql-mode can be used to enable syntactic hilighting for SQL
;; statements in another buffer.  SQL statements can then be sent to
;; the SQL process in the SQLi buffer.  sql-mode has already been
;; used as a template to a simple PL/SQL mode.

;; For documentation on the functionality provided by comint mode, and
;; the hooks available for customising it, see the file `comint.el'.

;; Hint for newbies: take a look at `dabbrev-expand' and `abbrev-mode'.

;;; Requirements for Emacs 19.34:

;; If you are using Emacs 19.34, you will have to get and install
;; the file regexp-opt.el
;; <URL:ftp://ftp.ifi.uio.no/pub/emacs/emacs-20.3/lisp/emacs-lisp/regexp-opt.el>
;; and the custom package
;; <URL:http://www.dina.kvl.dk/~abraham/custom/>.

;;; Bugs:

;; Using sql-ms (isql by Microsoft): When commands with syntax errors
;; or execution errors are executed, there is no server feedback.
;; This happens in stored procedures for example.  The server messages
;; only appear after the process is exited.  This makes things
;; somewhat unreliable.

;;; To Do:

;; Add better hilight support for other brands; there is a bias towards
;; Oracle because that's what I use at work.  Anybody else just send in
;; your lists of reserved words, keywords and builtin functions!  As
;; long as I don't receive any feedback, everything is hilighted with
;; ANSI keywords only.  I received the list of ANSI keywords from a
;; user; if you know of any changes, let me know.

;; Add different hilighting levels.

;;; Thanks to all the people who helped me out:

;; Kai Blauberg <kai.blauberg@metla.fi>
;; <ibalaban@dalet.com>
;; Yair Friedman <yfriedma@JohnBryce.Co.Il>
;; Gregor Zych <zych@pool.informatik.rwth-aachen.de>
;; nino <nino@inform.dk>



;;; Code:

(require 'comint)
;; Need the following to allow GNU Emacs 19 to compile the file.
(require 'regexp-opt)
(require 'custom)

;;; Allow customization

(defgroup SQL nil
  "Running a SQL interpreter from within Emacs buffers"
  :version "20.4"
  :group 'processes)

;; These three variables will be used as defaults, if set.

(defcustom sql-user ""
  "*Default username."
  :type 'string
  :group 'SQL)

(defcustom sql-password ""
  "*Default password.

Storing your password in a textfile such as ~/.emacs could be dangerous.
Customizing your password will store it in your ~/.emacs file."
  :type 'string
  :group 'SQL)

(defcustom sql-database ""
  "*Default database."
  :type 'string
  :group 'SQL)

(defcustom sql-server ""
  "*Default server or host."
  :type 'string
  :group 'SQL)

(defcustom sql-pop-to-buffer-after-send-region nil
  "*If t, pop to the buffer SQL statements are sent to.

After a call to `sql-send-region' or `sql-send-buffer',
the window is split and the SQLi buffer is shown.  If this
variable is not nil, that buffer's window will be selected
by calling `pop-to-buffer'.  If this variable is nil, that
buffer is shown using `display-buffer'."
  :type 'boolean
  :group 'SQL)

(defcustom sql-input-ring-file-name nil
  "*If non-nil, name of the file to read/write input history.

You have to set this variable if you want the history of your commands
saved from one Emacs session to the next.  If this variable is set,
exiting the SQL interpreter in an SQLi buffer will write the input
history to the specified file.  Starting a new process in a SQLi buffer
will read the input history from the specified file.

This is used to locally set `comint-input-ring-file-name' when reading
or writing the input history."
  :type '(choice (const :tag "none" nil)
		 (file))
  :group 'SQL)

(defcustom sql-input-ring-separator "\n--\n"
  "*Separator between commands in the history file.

If set to \"\\n\", each line in the history file will be interpreted as
one command.  Multi-line commands are split into several commands when
the input ring is initialized from a history file.

This variable used to locally set `comint-input-ring-separator' when
reading or writing the history file.  `comint-input-ring-separator' is
not yet part of Emacs; if your Emacs does not have it, setting
`sql-input-ring-separator' will have no effect.  In that case multiline
commands will be split into several commands when the input history is
read, as if you had set `sql-input-ring-separator' to \"\\n\".

The source code contains a link to a homepage that might have a patch
for comint.el to download."
  :type 'string
  :group 'SQL)

;; The usual hooks

(defcustom sql-interactive-mode-hook '()
  "*Hook for customising `sql-interactive-mode'."
  :type 'hook
  :group 'SQL)

(defcustom sql-mode-hook '()
  "*Hook for customising `sql-mode'."
  :type 'hook
  :group 'SQL)

(defcustom sql-set-sqli-hook '()
  "*Hook for reacting to changes of `sql-buffer'.

This is called by `sql-set-sqli-buffer' when the value of `sql-buffer'
is changed."
  :type 'hook
  :group 'SQL)

;; Customisation for Oracle

(defcustom sql-oracle-program "sqlplus"
  "*Command to start sqlplus by Oracle.

Starts `sql-interactive-mode' after doing some setup.

Under NT, \"sqlplus\" usually starts the sqlplus \"GUI\".  In order to
start the sqlplus console, use \"plus33\" or something similar.  You
will find the file in your Orant\\bin directory.

The program can also specify a TCP connection.  See `make-comint'."
  :type 'file
  :group 'SQL)

;; Customisation for MySql

(defcustom sql-mysql-program "mysql"
  "*Command to start mysql by TcX.

Starts `sql-interactive-mode' after doing some setup.

The program can also specify a TCP connection.  See `make-comint'."
  :type 'file
  :group 'SQL)

;; Customisation for Solid

(defcustom sql-solid-program "solsql"
  "*Command to start SOLID SQL Editor.

Starts `sql-interactive-mode' after doing some setup.

The program can also specify a TCP connection.  See `make-comint'."
  :type 'file
  :group 'SQL)

;; Customisation for SyBase

(defcustom sql-sybase-program "isql"
  "*Command to start isql by SyBase.  

Starts `sql-interactive-mode' after doing some setup.

The program can also specify a TCP connection.  See `make-comint'."
  :type 'file
  :group 'SQL)

;; Customisation for Informix

(defcustom sql-informix-program "dbaccess"
  "*Command to start dbaccess by Informix.  

Starts `sql-interactive-mode' after doing some setup.

The program can also specify a TCP connection.  See `make-comint'."
  :type 'file
  :group 'SQL)

;; Customisation for Ingres

(defcustom sql-ingres-program "sql"
  "*Command to start sql by Ingres.  

Starts `sql-interactive-mode' after doing some setup.

The program can also specify a TCP connection.  See `make-comint'."
  :type 'file
  :group 'SQL)

;; Customisation for Microsoft

(defcustom sql-ms-program "isql"
  "*Command to start isql by Microsoft.  

Starts `sql-interactive-mode' after doing some setup.

The program can also specify a TCP connection.  See `make-comint'."
  :type 'file
  :group 'SQL)

;; Customisation for Postgres

(defcustom sql-postgres-program "psql"
  "Command to start psql by Postgres.  

Starts `sql-interactive-mode' after doing some setup.

The program can also specify a TCP connection.  See `make-comint'."
  :type 'file
  :group 'SQL)



;;; Variables which do not need customization

(defvar sql-user-history nil
  "History of usernames used.")

(defvar sql-database-history nil
  "History of databases used.")

(defvar sql-server-history nil
  "History of servers used.")

;; Passwords are not kept in a history.

(defvar sql-buffer nil
  "Current SQLi buffer.

The global value of sql-buffer is the name of the latest SQLi buffer
created.  Any SQL buffer created will make a local copy of this value.
See `sql-interactive-mode' for more on multiple sessions.  If you want
to change the SQLi buffer a SQL mode sends its SQL strings to, change
the local value of `sql-buffer' using \\[sql-set-sqli-buffer].")

(defvar sql-prompt-regexp nil
  "Prompt used to initialize `comint-prompt-regexp'.

You can change `comint-prompt-regexp' on `sql-interactive-mode-hook'.")

(defvar sql-prompt-length 0
  "Prompt used to set `left-margin' in `sql-interactive-mode'.

You can change it on `sql-interactive-mode-hook'.")

(defvar sql-alternate-buffer-name nil
  "Buffer-local string used to possibly rename the SQLi buffer.

Used by `sql-rename-buffer'.")

;; Keymap for sql-interactive-mode, based on comint-mode-map.

(if (not (string-match "XEmacs\\|Lucid" emacs-version))
    (defvar sql-interactive-mode-map 
      (let ((map (nconc (make-sparse-keymap) comint-mode-map)))
	(define-key map "\C-j" 'sql-accumulate-and-indent)
	(define-key map "\C-c\C-w" 'sql-copy-column)
	map)
      "Mode map used for `sql-interactive-mode'.")
  ;; XEmacs
  (defvar sql-interactive-mode-map nil)
  (if (not sql-interactive-mode-map)
      (let ((map (make-keymap)))
	(set-keymap-parents map (list comint-mode-map))
	(set-keymap-name map 'sql-interactive-mode-map)
	(define-key map "\C-j" 'sql-accumulate-and-indent)
	(define-key map "\C-c\C-w" 'sql-copy-column)
	(setq sql-interactive-mode-map map))))

;; Keymap for sql-mode.

(defvar sql-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map "\C-c\C-c" 'sql-send-paragraph)
    (define-key map "\C-c\C-r" 'sql-send-region)
    (define-key map "\C-c\C-b" 'sql-send-buffer)
    (define-key map "\t" 'indent-relative)
    map)
  "Mode map used for `sql-mode'.")

;; easy menu for sql-mode.

(easy-menu-define 
 sql-mode-menu sql-mode-map 
 "Menu for `sql-mode'."
 '("SQL"
   ["Send Paragraph" sql-send-paragraph (and (buffer-live-p sql-buffer)
					     (get-buffer-process sql-buffer))]
   ["Send Region" sql-send-region (and mark-active 
				       (buffer-live-p sql-buffer)
				       (get-buffer-process sql-buffer))]
   ["Send Buffer" sql-send-buffer (and (buffer-live-p sql-buffer)
				       (get-buffer-process sql-buffer))]
   ["Show SQLi buffer" sql-show-sqli-buffer t]
   ["Set SQLi buffer" sql-set-sqli-buffer t]
   ["Pop to SQLi buffer after send" 
    sql-toggle-pop-to-buffer-after-send-region
    :style toggle
    :selected sql-pop-to-buffer-after-send-region]))

;; easy menu for sql-interactive-mode.

(easy-menu-define 
 sql-interactive-mode-menu sql-interactive-mode-map
 "Menu for `sql-interactive-mode'."
 '("SQL"
   ["Rename Buffer" sql-rename-buffer t]))

;; Abbreviations -- if you want more of them, define them in your
;; ~/.emacs file.  Abbrevs have to be enabled in your ~/.emacs, too.

(defvar sql-mode-abbrev-table nil
  "Abbrev table used in `sql-mode' and `sql-interactive-mode'.")
(if sql-mode-abbrev-table
    ()
  (let ((wrapper))
    (define-abbrev-table 'sql-mode-abbrev-table ())
    (define-abbrev sql-mode-abbrev-table  "ins" "insert" nil)
    (define-abbrev sql-mode-abbrev-table  "upd" "update" nil)
    (define-abbrev sql-mode-abbrev-table  "del" "delete" nil)
    (define-abbrev sql-mode-abbrev-table  "sel" "select" nil)))

;; Syntax Table

(defvar sql-mode-syntax-table 
  (let ((table (make-syntax-table)))
    ;; C-style comments /**/ (see elisp manual "Syntax Flags"))
    (modify-syntax-entry ?/ ". 14" table)
    (modify-syntax-entry ?* ". 23" table)
    ;; double-dash starts comment
    (if (string-match "XEmacs\\|Lucid" emacs-version)
	(modify-syntax-entry ?- ". 56" table)
      (modify-syntax-entry ?- ". 12b" table))
    ;; newline and formfeed end coments
    (modify-syntax-entry ?\n "> b" table)
    (modify-syntax-entry ?\f "> b" table)
    ;; single quotes (') quotes delimit strings
    (modify-syntax-entry ?' "\"" table)
    table)
  "Syntax table used in `sql-mode' and `sql-interactive-mode'.")

;; Font lock support

(defvar sql-mode-ansi-font-lock-keywords nil
  "ANSI SQL keywords used by font-lock.

This variable is used by `sql-mode' and `sql-interactive-mode'.  The
regular expressions are created during compilation by calling the
function `regexp-opt'.  Therefore, take a look at the source before
you define your own sql-mode-ansi-font-lock-keywords.  You may want to
add functions and PL/SQL keywords.")
(if sql-mode-ansi-font-lock-keywords
    ()
  (let ((ansi-keywords (eval-when-compile
			 (concat "\\b"
				 (regexp-opt '(
"authorization" "avg" "begin" "close" "cobol" "commit"
"continue" "count" "declare" "double" "end" "escape"
"exec" "fetch" "foreign" "fortran" "found" "go" "goto" "indicator" 
"key" "language" "max" "min" "module" "numeric" "open" "pascal" "pli"
"precision" "primary" "procedure" "references" "rollback"
"schema" "section" "some" "sqlcode" "sqlerror" "sum" "work") t) "\\b")))
	(ansi-reserved-words (eval-when-compile
			       (concat "\\b"
				       (regexp-opt '(
"all" "and" "any" "as" "asc" "between" "by" "check" "create"
"current" "default" "delete" "desc" "distinct" "exists" "float" "for"
"from" "grant" "group" "having" "in" "insert" "into" "is"
"like" "not" "null" "of" "on" "option" "or" "order" "privileges"
"public" "select" "set" "table" "to" "union" "unique"
"update" "user" "values" "view" "where" "with") t) "\\b")))
	(ansi-types (eval-when-compile
		      (concat "\\b"
			      (regexp-opt '(
;; ANSI Keywords that look like types					  
"character" "cursor" "dec" "int" "real" 
;; ANSI Reserved Word that look like types
"char" "integer" "smallint" ) t) "\\b"))))
    (setq sql-mode-ansi-font-lock-keywords
	  (list (cons ansi-keywords 'font-lock-function-name-face)
		(cons ansi-reserved-words 'font-lock-keyword-face)
		(cons ansi-types 'font-lock-type-face)))))

(defvar sql-mode-oracle-font-lock-keywords nil
  "Oracle SQL keywords used by font-lock.

This variable is used by `sql-mode' and `sql-interactive-mode'.  The
regular expressions are created during compilation by calling the
function `regexp-opt'.  Therefore, take a look at the source before
you define your own sql-mode-oracle-font-lock-keywords.  You may want
to add functions and PL/SQL keywords.")
(if sql-mode-oracle-font-lock-keywords
    ()
  (let ((oracle-keywords (eval-when-compile
			   (concat "\\b"
				   (regexp-opt '(
"admin" "after" "allocate" "analyze" "archive" "archivelog" "backup"
"become" "before" "block" "body" "cache" "cancel" "cascade" "change"
"checkpoint" "compile" "constraint" "constraints" "contents"
"controlfile" "cycle" "database" "datafile" "dba" "disable" "dismount"
"dump" "each" "enable" "events" "except" "exceptions" "execute"
"explain" "extent" "externally" "flush" "force" "freelist" "freelists"
"function" "groups" "including" "initrans" "instance" "layer" "link"
"lists" "logfile" "manage" "manual" "maxdatafiles" "maxinistances"
"maxlogfiles" "maxloghistory" "maxlogmembers" "maxtrans" "maxvalue"
"minextents" "minvalue" "mount" "new" "next" "noarchivelog" "nocache"
"nocycle" "nomaxvalue" "nominvalue" "none" "noorder" "noresetlogs"
"normal" "nosort" "off" "old" "only" "optimal" "own" "package"
"parallel" "pctincrease" "pctused" "plan" "private" "profile" "quota"
"read" "recover" "referencing" "resetlogs" "restricted" "reuse" "role"
"roles" "savepoint" "scn" "segment" "sequence" "shared" "snapshot"
"sort" "statement_id" "statistics" "stop" "storage" "switch" "system"
"tables" "tablespace" "temporary" "thread" "time" "tracing"
"transaction" "triggers" "truncate" "under" "unlimited" "until" "use"
"using" "when" "write") t) "\\b")))
	(oracle-reserved-words (eval-when-compile
				 (concat "\\b"
					 (regexp-opt '(
"access" "add" "alter" "audit" "cluster" "column" "comment" "compress"
"connect" "drop" "else" "exclusive" "file" "grant"
"identified" "immediate" "increment" "index" "initial" "intersect"
"level" "lock" "long" "maxextents" "minus" "mode" "modify" "noaudit"
"nocompress" "nowait" "number" "offline" "online" "pctfree" "prior"
"raw" "rename" "resource" "revoke" "row" "rowlabel" "rownum"
"rows" "session" "share" "size" "start" "successful" "synonym" "sysdate"
"then" "trigger" "uid" "validate" "whenever") t) "\\b")))
	(oracle-types (eval-when-compile
			(concat "\\b"
				(regexp-opt '(
;; Oracle Keywords that look like types
;; Oracle Reserved Words that look like types
"date" "decimal" "rowid" "varchar" "varchar2") t) "\\b")))
	(oracle-builtin-functions (eval-when-compile
			(concat "\\b"
				(regexp-opt '(
;; Misc Oracle builtin functions
"abs" "add_months" "ascii" "avg" "ceil" "chartorowid" "chr" "concat"
"convert" "cos" "cosh" "count" "currval" "decode" "dump" "exp" "floor"
"glb" "greatest" "greatest_lb" "hextoraw" "initcap" "instr" "instrb"
"last_day" "least" "least_ub" "length" "lengthb" "ln" "log" "lower"
"lpad" "ltrim" "lub" "max" "min" "mod" "months_between" "new_time"
"next_day" "nextval" "nls_initcap" "nls_lower" "nls_upper" "nlssort"
"nvl" "power" "rawtohex" "replace" "round" "rowidtochar" "rpad"
"rtrim" "sign" "sin" "sinh" "soundex" "sqlcode" "sqlerrm" "sqrt"
"stddev" "sum" "substr" "substrb" "tan" "tanh" "to_char"
"to_date" "to_label" "to_multi_byte" "to_number" "to_single_byte"
"translate" "trunc" "uid" "upper" "userenv" "variance" "vsize") t) "\\b"))))
    (setq sql-mode-oracle-font-lock-keywords
	  (append sql-mode-ansi-font-lock-keywords
		  (list (cons oracle-keywords 'font-lock-function-name-face)
			(cons oracle-reserved-words 'font-lock-keyword-face)
			;; XEmacs doesn't have font-lock-builtin-face
			(if (string-match "XEmacs\\|Lucid" emacs-version)
			    (cons oracle-builtin-functions 'font-lock-preprocessor-face)
			  ;; GNU Emacs 19 doesn't have it either
			  (if (string-match "GNU Emacs 19" emacs-version)
			      (cons oracle-builtin-functions 'font-lock-function-name-face)
			    ;; Emacs
			    (cons oracle-builtin-functions 'font-lock-builtin-face)))
			(cons oracle-types 'font-lock-type-face))))))

(defvar sql-mode-postgres-font-lock-keywords nil
  "Postgres SQL keywords used by font-lock.

This variable is used by `sql-mode' and `sql-interactive-mode'.  The
regular expressions are created during compilation by calling the
function `regexp-opt'.  Therefore, take a look at the source before
you define your own sql-mode-postgres-font-lock-keywords.")

(if sql-mode-postgres-font-lock-keywords
    ()
  (let ((postgres-reserved-words (eval-when-compile
				 (concat "\\b"
					 (regexp-opt '(
"language"
) t) "\\b")))
	(postgres-types (eval-when-compile 
			  (concat "\\b" 
				  (regexp-opt '( 
"bool" "box" "circle" "char" "char2" "char4" "char8" "char16" "date" 
"float4" "float8" "int2" "int4" "int8" "line" "lseg" "money" "path" 
"point" "polygon" "serial" "text" "time" "timespan" "timestamp" "varchar"
) t)"\\b")))
	(postgres-builtin-functions (eval-when-compile
			(concat "\\b"
				(regexp-opt '(
;; Misc Postgres builtin functions
"abstime" "age" "area" "box" "center" "date_part" "date_trunc"
"datetime" "dexp" "diameter" "dpow" "float" "float4" "height"
"initcap" "integer" "isclosed" "isfinite" "isoldpath" "isopen"
"length" "lower" "lpad" "ltrim" "pclose" "point" "points" "popen"
"position" "radius" "reltime" "revertpoly" "rpad" "rtrim" "substr"
"substring" "text" "timespan" "translate" "trim" "upgradepath"
"upgradepoly" "upper" "varchar" "width"
) t) "\\b"))))
    (setq sql-mode-postgres-font-lock-keywords
	  (append sql-mode-ansi-font-lock-keywords
		  (list (cons postgres-reserved-words 'font-lock-keyword-face)
			;; XEmacs doesn't have 'font-lock-builtin-face
			(if (string-match "XEmacs\\|Lucid" emacs-version)
			    (cons postgres-builtin-functions 'font-lock-preprocessor-face)
			  ;; Emacs
			  (cons postgres-builtin-functions 'font-lock-builtin-face))
			(cons postgres-types 'font-lock-type-face))))))


(defvar sql-mode-font-lock-keywords sql-mode-ansi-font-lock-keywords
  "SQL keywords used by font-lock.

This variable defaults to `sql-mode-ansi-font-lock-keywords'.  This is
used for the default `font-lock-defaults' value in `sql-mode'.  This
can be changed by some entry functions to provide more hilighting.")



;;; Small functions

(defun sql-accumulate-and-indent ()
  "Continue SQL statement on the next line."
  (interactive)
  ;; comint-accumulate is a Emacs 20.X thingie
  (if (not (string-match "XEmacs\\|Lucid\\|GNU Emacs 19" emacs-version))
      (comint-accumulate))
  (indent-according-to-mode))

;;;###autoload
(defun sql-help ()
  "Shows short help for the SQL modes.

Use an entry function to open an interactive SQL buffer.  This buffer is
usually named `*SQL*'.  The name of the major mode is SQLi.

Use the following commands to start a specific SQL interpreter:

    PostGres: \\[sql-postgres]

Other non-free SQL implementations are also supported:

    MySQL: \\[sql-mysql]
    Solid: \\[sql-solid]
    Oracle: \\[sql-oracle]
    Informix: \\[sql-informix]
    Sybase: \\[sql-sybase]
    Ingres: \\[sql-ingres]
    Microsoft: \\[sql-ms]

But we urge you to choose a free implementation instead of these.

Once you have the SQLi buffer, you can enter SQL statements in the
buffer.  The output generated is appended to the buffer and a new prompt
is generated.  See the In/Out menu in the SQLi buffer for some functions
that help you navigate through the buffer, the input history, etc.

Put a line with a call to autoload into your `~/.emacs' file for each
entry function you want to use regularly:

\(autoload 'sql-postgres \"sql\" \"Interactive SQL mode.\" t)

If you have a really complex SQL statement or if you are writing a
procedure, you can do this in a separate buffer.  Put the new buffer in
`sql-mode' by calling \\[sql-mode].  The name of this buffer can be
anything.  The name of the major mode is SQL.

In this SQL buffer (SQL mode), you can send the region or the entire
buffer to the interactive SQL buffer (SQLi mode).  The results are
appended to the SQLi buffer without disturbing your SQL buffer."
  (interactive)
  (describe-function 'sql-help))

(defun sql-read-passwd (prompt &optional default)
  "Read a password using PROMPT.
Optional DEFAULT is password to start with.  This function calls
`read-passwd' if it is available.  If not, function
`ange-ftp-read-passwd' is called.  This should always be available,
even in old versions of Emacs."
  (if (fboundp 'read-passwd)
      (read-passwd prompt nil default)
    (unless (fboundp 'ange-ftp-read-passwd)
      (autoload 'ange-ftp-read-passwd "ange-ftp"))
    (ange-ftp-read-passwd prompt default)))

(defun sql-get-login (&rest what)
  "Get username, password and database from the user.

The variables `sql-user', `sql-password', `sql-server', and
`sql-database' can be customised.  They are used as the default values.
Usernames, servers and databases are stored in `sql-user-history',
`sql-server-history' and `database-history'.  Passwords are not stored
in a history.

Parameter WHAT is a list of the arguments passed to this function.
The function asks for the username if WHAT contains symbol `user', for
the password if it contains symbol `password', for the server if it
contains symbol `server', and for the database if it contains symbol
`database'.

In order to ask the user for username, password and database, call the
function like this: (sql-get-login 'user 'password 'database)."
  (interactive)
  (if (memq 'user what)
      (setq sql-user 
	    (read-from-minibuffer "User: " sql-user nil nil
				  sql-user-history)))
  (if (memq 'password what)
      (setq sql-password 
	    (sql-read-passwd "Password: " sql-password)))
  (if (memq 'server what)
      (setq sql-server 
	    (read-from-minibuffer "Server: " sql-server nil nil
				  sql-server-history)))
  (if (memq 'database what)
      (setq sql-database 
	    (read-from-minibuffer "Database: " sql-database nil nil
				  sql-database-history))))
(defun sql-set-sqli-buffer ()
  "Set the SQLi buffer SQL strings are sent to.

Call this function in a SQL buffer in order to set the SQLi buffer SQL
strings are sent to.  Calling this function sets `sql-buffer' and runs
`sql-set-sqli-hook'.

If you call it from a SQL buffer, this sets the local copy of
`sql-buffer'.  

If you call it from anywhere else, it sets the global copy of
`sql-buffer'."
  (interactive)
  (let ((new-buffer (get-buffer (read-buffer "New SQLi buffer: " nil t))))
    (if new-buffer
	(progn 
	  (setq sql-buffer new-buffer)
	  (run-hooks 'sql-set-sqli-hook)))))

(defun sql-show-sqli-buffer ()
  "Show the name of current SQLi buffer.

This is the buffer SQL strings are sent to.  It is stored in the
variable `sql-buffer'.  See `sql-help' on how to create such a buffer."
  (interactive)
  (if (null (buffer-live-p sql-buffer))
      (message "%s has no SQLi buffer set." (buffer-name (current-buffer)))
    (if (null (get-buffer-process sql-buffer))
	(message "Buffer %s has no process." (buffer-name sql-buffer))
      (message "Current SQLi buffer is %s." (buffer-name sql-buffer)))))

(defun sql-make-alternate-buffer-name ()
  "Return a string that can be used to rename a SQLi buffer.

This is used to set `sql-alternate-buffer-name' within
`sql-interactive-mode'."
  (concat (if (string= "" sql-user)
	      (if (string= "" user-login-name)
		  ()
		(concat user-login-name "/"))
	    (concat sql-user "/"))
	  (if (string= "" sql-database)
	      (if (string= "" sql-server)
		  system-name
		sql-server)
	    sql-database)))

(defun sql-rename-buffer ()
  "Renames a SQLi buffer."
  (interactive)
  (rename-buffer (format "*SQL: %s*" sql-alternate-buffer-name) t))

(defun sql-copy-column ()
  "Copy current column to the end of buffer.
Inserts SELECT or commas if appropriate."
  (interactive)
  (let ((column))
    (save-excursion
      (setq column (buffer-substring
		  (progn (forward-char 1) (backward-sexp 1) (point))
		  (progn (forward-sexp 1) (point))))
      (goto-char (point-max))
      (cond
       ;; if empty command line, insert SELECT
       ((save-excursion (beginning-of-line) 
			(looking-at (concat comint-prompt-regexp "$")))
	(insert "SELECT "))
       ;; else if appending to SELECT or ORDER BY, insert a comma
       ((save-excursion 
	  (re-search-backward "\\b\\(select\\|order by\\) .+"
			      (save-excursion (beginning-of-line) (point)) t))
	(insert ", "))
       ;; else insert a space
       (t
	(if (eq (preceding-char) ? )
	    nil
	  (insert " "))))
      ;; in any case, insert the column
      (insert column)
      (message "%s" column))))



;;; Sending the region to the SQLi buffer.

(defun sql-send-region (start end)
  "Send a region to the SQL process."
  (interactive "r")
  (if (buffer-live-p sql-buffer)
      (save-excursion
	(comint-send-region sql-buffer start end)
	(if (string-match "\n$" (buffer-substring start end))
	    ()
	  (comint-send-string sql-buffer "\n"))
	(message "Sent string to buffer %s." (buffer-name sql-buffer))
	(if sql-pop-to-buffer-after-send-region 
	    (pop-to-buffer sql-buffer)
	  (display-buffer sql-buffer)))
    (message "No SQL process started.")))

(defun sql-send-paragraph ()
  "Send the current paragraph to the SQL process."
  (interactive)
  (let ((start (save-excursion
		 (backward-paragraph)
		 (point)))
	(end (save-excursion
	       (forward-paragraph)
	       (point))))
    (sql-send-region start end)))

(defun sql-send-buffer ()
  "Send the buffer contents to the SQL process."
  (interactive)
  (sql-send-region (point-min) (point-max)))

(defun sql-toggle-pop-to-buffer-after-send-region (&optional value)
  "Toggle `sql-pop-to-buffer-after-send-region'.

If given the optional parameter VALUE, sets
sql-toggle-pop-to-buffer-after-send-region to VALUE."
  (interactive "P")
  (if value
      (setq sql-pop-to-buffer-after-send-region value)
    (setq sql-pop-to-buffer-after-send-region 
	  (null sql-pop-to-buffer-after-send-region ))))



;;; SQL mode -- uses SQL interactive mode

;;;###autoload
(defun sql-mode ()
  "Major mode to edit SQL.

You can send SQL statements to the SQLi buffer using
\\[sql-send-region].  Such a buffer must exist before you can do this.
See `sql-help' on how to create SQLi buffers.

\\{sql-mode-map} 
Customization: Entry to this mode runs the `sql-mode-hook'.

When you put a buffer in SQL mode, the buffer stores the last SQLi
buffer created as its destination in the variable `sql-buffer'.  This
will be the buffer \\[sql-send-region] sends the region to.  If this
SQLi buffer is killed, \\[sql-send-region] is no longer able to
determine where the strings should be sent to.  You can set the
value of `sql-buffer' using \\[sql-set-sqli-buffer].

For information on how to create multiple SQLi buffers, see
`sql-interactive-mode'."
  (interactive)
  (kill-all-local-variables)
  (setq major-mode 'sql-mode)
  (setq mode-name "SQL")
  (use-local-map sql-mode-map)
  (set-syntax-table sql-mode-syntax-table)
  (make-local-variable 'font-lock-defaults)
  (setq font-lock-defaults '(sql-mode-font-lock-keywords 
			     nil t ((95 . "w") (46 . "w"))))
  (make-local-variable 'comment-start)
  (setq comment-start "--")
  ;; Make each buffer in sql-mode remeber the "current" SQLi buffer.
  (make-local-variable 'sql-buffer)
  ;; Make `sql-send-paragraph' work on paragraphs that contain indented
  ;; lines.
  (make-local-variable 'paragraph-separate)
  (make-local-variable 'paragraph-start)
  (setq paragraph-separate "[\f]*$"
	paragraph-start "[\n\f]")
  (setq local-abbrev-table sql-mode-abbrev-table)
  (setq abbrev-all-caps 1)
  (run-hooks 'sql-mode-hook))



;;; SQL interactive mode

(put 'sql-interactive-mode 'mode-class 'special)

(defun sql-interactive-mode ()
  "Major mode to use a SQL interpreter interactively.

Do not call this function by yourself.  The environment must be
initialized by an entry function specific for the SQL interpreter.  See
`sql-help' for a list of available entry functions.

\\[comint-send-input] after the end of the process' output sends the
text from the end of process to the end of the current line.
\\[comint-send-input] before end of process output copies the current
line minus the prompt to the end of the buffer and sends it.
\\[comint-copy-old-input] just copies the current line.
Use \\[sql-accumulate-and-indent] to enter multi-line statements.

If you want to make multiple SQL buffers, rename the `*SQL*' buffer
using \\[rename-buffer] or \\[rename-uniquely] and start a new process.
See `sql-help' for a list of available entry functions.  The last buffer
created by such an entry function is the current SQLi buffer.  SQL
buffers will send strings to the SQLi buffer current at the time of
their creation.  See `sql-mode' for details.

Sample session using two connections:

1. Create first SQLi buffer by calling an entry function.
2. Rename buffer \"*SQL*\" to \"*Connection 1*\".
3. Create a SQL buffer \"test1.sql\".
4. Create second SQLi buffer by calling an entry function.
5. Rename buffer \"*SQL*\" to \"*Connection 2*\".
6. Create a SQL buffer \"test2.sql\".

Now \\[sql-send-region] in buffer \"test1.sql\" will send the region to
buffer \"*Connection 1*\", \\[sql-send-region] in buffer \"test2.sql\"
will send the region to buffer \"*Connection 2*\".

If you accidentally suspend your process, use \\[comint-continue-subjob]
to continue it.  On some operating systems, this will not work because
the signals are not supported.

\\{sql-interactive-mode-map}
Customization: Entry to this mode runs the hooks on `comint-mode-hook'
and `sql-interactive-mode-hook' (in that order).  Before each input, the
hooks on `comint-input-filter-functions' are run.  After each SQL
interpreter output, the hooks on `comint-output-filter-functions' are
run.

Variable `sql-input-ring-file-name' controls the initialisation of the
input ring history.  `comint-input-ring-file-name' is temporarily bound
to `sql-input-ring-file-name' when reading the input history.

Variables `comint-output-filter-functions', a hook, and
`comint-scroll-to-bottom-on-input' and
`comint-scroll-to-bottom-on-output' control whether input and output
cause the window to scroll to the end of the buffer.

If you want to make SQL buffers limited in length, add the function
`comint-truncate-buffer' to `comint-output-filter-functions'.

Here is an example for your .emacs file.  It keeps the SQLi buffer a
certain length.

\(add-hook 'sql-interactive-mode-hook
    \(function (lambda ()
        \(setq comint-output-filter-functions 'comint-truncate-buffer))))

Here is another example.  It will always put point back to the statement
you entered, right above the output it created.

\(setq comint-output-filter-functions 
       \(function (lambda (STR) (comint-show-output))))"
  (comint-mode)
  (setq comint-prompt-regexp sql-prompt-regexp)
  (setq left-margin sql-prompt-length)
  (setq major-mode 'sql-interactive-mode)
  (setq mode-name "SQLi")
  (use-local-map sql-interactive-mode-map)
  (set-syntax-table sql-mode-syntax-table)
  (make-local-variable 'font-lock-defaults)
  ;; Note that making KEYWORDS-ONLY nil will cause havoc if you try
  ;; SELECT 'x' FROM DUAL with SQL*Plus, because the title of the
  ;; column will have just one quote.  Therefore syntactic hilighting
  ;; is disabled for interactive buffers.
  (setq font-lock-defaults '(sql-mode-font-lock-keywords 
			     t t ((95 . "w") (46 . "w"))))
  ;; Enable commenting and uncommenting of the region.
  (make-local-variable 'comment-start)
  (setq comment-start "--")
  ;; Abbreviation table init and case-insensitive.  It is not activatet
  ;; by default.
  (setq local-abbrev-table sql-mode-abbrev-table)
  (setq abbrev-all-caps 1)
  ;; Exiting the process will call sql-stop.
  (set-process-sentinel (get-buffer-process sql-buffer) 'sql-stop)
  ;; Make input-ring stuff buffer local so that people who want a
  ;; different history file for each buffer/process/client/whatever can
  ;; change separator and file-name on the sql-interactive-mode-hook.
  (make-local-variable 'sql-input-ring-separator)
  (make-local-variable 'sql-input-ring-file-name)
  ;; Create a usefull name for renaming this buffer later.
  (make-local-variable 'sql-alternate-buffer-name)
  (setq sql-alternate-buffer-name (sql-make-alternate-buffer-name))
  ;; User stuff.
  (run-hooks 'sql-interactive-mode-hook)
  ;; Calling the hook before calling comint-read-input-ring allows users
  ;; to set comint-input-ring-file-name in sql-interactive-mode-hook.
  ;; While reading the history, file-name and history are rebound...
  (let ((comint-input-ring-file-name sql-input-ring-file-name)
	(comint-input-ring-separator sql-input-ring-separator))
    (comint-read-input-ring t)))

(defun sql-stop (process event)
  "Called when the SQL process is stopped.

Writes the input history to a history file using
`comint-write-input-ring' and inserts a short message in the SQL buffer.
`comint-comint-input-ring-file-name' is temporarily bound to
`sql-input-ring-file-name'.

This function is a sentinel watching the SQL interpreter process.
Sentinels will always get the two parameters PROCESS and EVENT."
  ;; Write history.
  ;; While reading the history, file-name and history are rebound...
  (let ((comint-input-ring-file-name sql-input-ring-file-name)
	(comint-input-ring-separator sql-input-ring-separator))
    (comint-write-input-ring))
  (if (buffer-live-p sql-buffer)
      (insert (format "\nProcess %s %s\n" process event))))



;;; Entry functions for different SQL interpreters.

(defun sql-oracle ()
  "Run sqlplus by Oracle as an inferior process.

If buffer `*SQL*' exists but no process is running, make a new process.
If buffer exists and a process is running, just switch to buffer
`*SQL*'.

Interpreter used comes from variable `sql-oracle-program'.  Login uses
the variables `sql-user', `sql-password', and `sql-database' as
defaults, if set.

The buffer is put in sql-interactive-mode, giving commands for sending
input.  See `sql-interactive-mode'.

To specify a coding system for converting non-ASCII characters
in the input and output to the process, use \\[universal-coding-system-argument]
before \\[sql-oracle].  You can also specify this with \\[set-buffer-process-coding-system]
in the SQL buffer, after you start the process.
The default comes from `process-coding-system-alist' and
`default-process-coding-system'.

\(Type \\[describe-mode] in the SQL buffer for a list of commands.)"
  (interactive)
  (if (comint-check-proc "*SQL*")
      (pop-to-buffer "*SQL*")
    (sql-get-login 'user 'password 'database)
    (message "Login...")
    ;; Produce user/password@database construct.  Password without user
    ;; is meaningless; database without user/password is meaningless,
    ;; because "@param" will ask sqlplus to interpret the script
    ;; "param".
    (let ((parameter nil))
      (if (not (string= "" sql-user))
	  (if (not (string= "" sql-password))
	      (setq parameter (concat sql-user "/" sql-password))
	    (setq parameter sql-user)))
      (if (and parameter (not (string= "" sql-database)))
	  (setq parameter (concat parameter "@" sql-database)))
      (if parameter
	  (set-buffer (make-comint "SQL" sql-oracle-program nil parameter))
	(set-buffer (make-comint "SQL" sql-oracle-program nil))))
    (setq sql-prompt-regexp "^SQL> ")
    (setq sql-prompt-length 5)
    (setq sql-buffer (current-buffer))
    ;; set sql-mode-font-lock-keywords to something different before
    ;; calling sql-interactive-mode.
    (setq sql-mode-font-lock-keywords sql-mode-oracle-font-lock-keywords)
    (sql-interactive-mode)
    (message "Login...done")
    (pop-to-buffer sql-buffer)))



(defun sql-sybase ()
  "Run isql by SyBase as an inferior process.

If buffer `*SQL*' exists but no process is running, make a new process.
If buffer exists and a process is running, just switch to buffer
`*SQL*'.

Interpreter used comes from variable `sql-sybase-program'.  Login uses
the variables `sql-user', `sql-password', and `sql-database' as
defaults, if set.

The buffer is put in sql-interactive-mode, giving commands for sending
input.  See `sql-interactive-mode'.

To specify a coding system for converting non-ASCII characters
in the input and output to the process, use \\[universal-coding-system-argument]
before \\[sql-sybase].  You can also specify this with \\[set-buffer-process-coding-system]
in the SQL buffer, after you start the process.
The default comes from `process-coding-system-alist' and
`default-process-coding-system'.

\(Type \\[describe-mode] in the SQL buffer for a list of commands.)"
  (interactive)
  (if (comint-check-proc "*SQL*")
      (pop-to-buffer "*SQL*")
    (sql-get-login 'user 'password 'database)
    (message "Login...")
    ;; Put all parameters to the program (if defined) in a list and call
    ;; make-comint.
    (let ((params '("-w" "2048" "-n")))
      ;; I had a zillion versions of this using nconc and mapcar,
      ;; mixtures of eval, list and quotes -- you have been warned.
      (if (not (string= "" sql-database))
	  (setq params (append (list "-S" sql-database) params)))
      (if (not (string= "" sql-password))
	  (setq params (append (list "-P" sql-password) params)))
      (if (not (string= "" sql-user))
	  (setq params (append (list "-U" sql-user) params)))
      (set-buffer (apply 'make-comint "SQL" sql-sybase-program 
			 nil params)))
    (setq sql-prompt-regexp "^SQL> ")
    (setq sql-prompt-length 5)
    (setq sql-buffer (current-buffer))
    (sql-interactive-mode)
    (message "Login...done")
    (pop-to-buffer sql-buffer)))



(defun sql-informix ()
  "Run dbaccess by Informix as an inferior process.

If buffer `*SQL*' exists but no process is running, make a new process.
If buffer exists and a process is running, just switch to buffer
`*SQL*'.

Interpreter used comes from variable `sql-informix-program'.  Login uses
the variable `sql-database' as default, if set.

The buffer is put in sql-interactive-mode, giving commands for sending
input.  See `sql-interactive-mode'.

To specify a coding system for converting non-ASCII characters
in the input and output to the process, use \\[universal-coding-system-argument]
before \\[sql-informix].  You can also specify this with \\[set-buffer-process-coding-system]
in the SQL buffer, after you start the process.
The default comes from `process-coding-system-alist' and
`default-process-coding-system'.

\(Type \\[describe-mode] in the SQL buffer for a list of commands.)"
  (interactive)
  (if (comint-check-proc "*SQL*")
      (pop-to-buffer "*SQL*")
    (sql-get-login 'database)
    (message "Login...")
    ;; username and password are ignored.
    (if (string= "" sql-database)
	(set-buffer (make-comint "SQL" sql-informix-program nil))
      (set-buffer (make-comint "SQL" sql-informix-program nil sql-database)))
    (setq sql-prompt-regexp "^SQL> ")
    (setq sql-prompt-length 5)
    (setq sql-buffer (current-buffer))
    (sql-interactive-mode)
    (message "Login...done")
    (pop-to-buffer sql-buffer)))



(defun sql-mysql ()
  "Run mysql by TcX as an inferior process.

Note that the widespread idea that mysql is free software is inaccurate;
its license is too restrictive.  We urge you to use PostGres instead.

If buffer `*SQL*' exists but no process is running, make a new process.
If buffer exists and a process is running, just switch to buffer
`*SQL*'.

Interpreter used comes from variable `sql-mysql-program'.  Login uses
the variables `sql-user', `sql-password', `sql-database', and
`sql-server' as defaults, if set.

The buffer is put in sql-interactive-mode, giving commands for sending
input.  See `sql-interactive-mode'.

To specify a coding system for converting non-ASCII characters
in the input and output to the process, use \\[universal-coding-system-argument]
before \\[sql-mysql].  You can also specify this with \\[set-buffer-process-coding-system]
in the SQL buffer, after you start the process.
The default comes from `process-coding-system-alist' and
`default-process-coding-system'.

\(Type \\[describe-mode] in the SQL buffer for a list of commands.)"
  (interactive)
  (if (comint-check-proc "*SQL*")
      (pop-to-buffer "*SQL*")
    (sql-get-login 'user 'password 'database 'server)
    (message "Login...")
    ;; Put all parameters to the program (if defined) in a list and call
    ;; make-comint.
    (let ((params))
      (if (not (string= "" sql-database))
	  (setq params (append (list sql-database) params)))
      (if (not (string= "" sql-server))
	  (setq params (append (list (concat "--host=" sql-server)) params)))
      (if (not (string= "" sql-password))
	  (setq params (append (list (concat "--password=" sql-password)) params)))
      (if (not (string= "" sql-user))
	  (setq params (append (list (concat "--user=" sql-user)) params)))
      (set-buffer (apply 'make-comint "SQL" sql-mysql-program 
			 nil params)))
    (setq sql-prompt-regexp "^mysql>")
    (setq sql-prompt-length 6)
    (setq sql-buffer (current-buffer))
    (sql-interactive-mode)
    (message "Login...done")
    (pop-to-buffer sql-buffer)))



(defun sql-solid ()
  "Run solsql by Solid as an inferior process.

If buffer `*SQL*' exists but no process is running, make a new process.
If buffer exists and a process is running, just switch to buffer
`*SQL*'.

Interpreter used comes from variable `sql-solid-program'.  Login uses
the variables `sql-user', `sql-password', and `sql-server' as
defaults, if set.

The buffer is put in sql-interactive-mode, giving commands for sending
input.  See `sql-interactive-mode'.

To specify a coding system for converting non-ASCII characters
in the input and output to the process, use \\[universal-coding-system-argument]
before \\[sql-solid].  You can also specify this with \\[set-buffer-process-coding-system]
in the SQL buffer, after you start the process.
The default comes from `process-coding-system-alist' and
`default-process-coding-system'.

\(Type \\[describe-mode] in the SQL buffer for a list of commands.)"
  (interactive)
  (if (comint-check-proc "*SQL*")
      (pop-to-buffer "*SQL*")
    (sql-get-login 'user 'password 'server)
    (message "Login...")
    ;; Put all parameters to the program (if defined) in a list and call
    ;; make-comint.
    (let ((params))
      ;; It only makes sense if both username and password are there.
      (if (not (or (string= "" sql-user)
		   (string= "" sql-password)))
	  (setq params (append (list sql-user sql-password) params)))
      (if (not (string= "" sql-server))
	  (setq params (append (list sql-server) params)))
      (set-buffer (apply 'make-comint "SQL" sql-solid-program 
			 nil params)))
    (setq sql-prompt-regexp "^")
    (setq sql-prompt-length 0)
    (setq sql-buffer (current-buffer))
    (sql-interactive-mode)
    (message "Login...done")
    (pop-to-buffer sql-buffer)))



(defun sql-ingres ()
  "Run sql by Ingres as an inferior process.

If buffer `*SQL*' exists but no process is running, make a new process.
If buffer exists and a process is running, just switch to buffer
`*SQL*'.

Interpreter used comes from variable `sql-ingres-program'.  Login uses
the variable `sql-database' as default, if set.

The buffer is put in sql-interactive-mode, giving commands for sending
input.  See `sql-interactive-mode'.

To specify a coding system for converting non-ASCII characters
in the input and output to the process, use \\[universal-coding-system-argument]
before \\[sql-ingres].  You can also specify this with \\[set-buffer-process-coding-system]
in the SQL buffer, after you start the process.
The default comes from `process-coding-system-alist' and
`default-process-coding-system'.

\(Type \\[describe-mode] in the SQL buffer for a list of commands.)"
  (interactive)
  (if (comint-check-proc "*SQL*")
      (pop-to-buffer "*SQL*")
    (sql-get-login 'database)
    (message "Login...")
    ;; username and password are ignored.
    (if (string= "" sql-database)
	(set-buffer (make-comint "SQL" sql-ingres-program nil))
      (set-buffer (make-comint "SQL" sql-ingres-program nil sql-database)))
    (setq sql-prompt-regexp "^\* ")
    (setq sql-prompt-length 2)
    (setq sql-buffer (current-buffer))
    (sql-interactive-mode)
    (message "Login...done")
    (pop-to-buffer sql-buffer)))



(defun sql-ms ()
  "Run isql by Microsoft as an inferior process.

If buffer `*SQL*' exists but no process is running, make a new process.
If buffer exists and a process is running, just switch to buffer
`*SQL*'.

Interpreter used comes from variable `sql-ms-program'.  Login uses the
variables `sql-user', `sql-password', `sql-database', and `sql-server'
as defaults, if set.

The buffer is put in sql-interactive-mode, giving commands for sending
input.  See `sql-interactive-mode'.

To specify a coding system for converting non-ASCII characters
in the input and output to the process, use \\[universal-coding-system-argument]
before \\[sql-ms].  You can also specify this with \\[set-buffer-process-coding-system]
in the SQL buffer, after you start the process.
The default comes from `process-coding-system-alist' and
`default-process-coding-system'.

\(Type \\[describe-mode] in the SQL buffer for a list of commands.)"
  (interactive)
  (if (comint-check-proc "*SQL*")
      (pop-to-buffer "*SQL*")
    (sql-get-login 'user 'password 'database 'server)
    (message "Login...")
    ;; Put all parameters to the program (if defined) in a list and call
    ;; make-comint.
    (let ((params '("-w 300")))
      (if (not (string= "" sql-server))
        (setq params (append (list "-S" sql-server) params)))
      (if (not (string= "" sql-database))
        (setq params (append (list "-d" sql-database) params)))
      (if (not (string= "" sql-user))
	  (setq params (append (list "-U" sql-user) params)))
      (if (not (string= "" sql-password))
	  (setq params (append (list "-P" sql-password) params))
	;; If -P is passed to ISQL as the last argument without a password,
	;; it's considered null.
	(setq params (append params (list "-P"))))
      (set-buffer (apply 'make-comint "SQL" sql-ms-program
			 nil params)))
    (setq sql-prompt-regexp "^[0-9]*>")
    (setq sql-prompt-length 5)
    (setq sql-buffer (current-buffer))
    (sql-interactive-mode)
    (message "Login...done")
    (pop-to-buffer sql-buffer)))




;;;###autoload
(defun sql-postgres ()
  "Run psql by Postgres as an inferior process.

If buffer `*SQL*' exists but no process is running, make a new process.
If buffer exists and a process is running, just switch to buffer
`*SQL*'.

Interpreter used comes from variable `sql-postgres-program'.  Login uses
the variables `sql-database' and `sql-server' as default, if set.

The buffer is put in sql-interactive-mode, giving commands for sending
input.  See `sql-interactive-mode'.

To specify a coding system for converting non-ASCII characters
in the input and output to the process, use \\[universal-coding-system-argument]
before \\[sql-postgres].  You can also specify this with \\[set-buffer-process-coding-system]
in the SQL buffer, after you start the process.
The default comes from `process-coding-system-alist' and
`default-process-coding-system'.  If your output lines end with ^M, 
your might try undecided-dos as a coding system.  If this doesn't help,
Try to set `comint-output-filter-functions' like this:

\(setq comint-output-filter-functions (append comint-output-filter-functions
					     '(comint-strip-ctrl-m)))

\(Type \\[describe-mode] in the SQL buffer for a list of commands.)"
  (interactive)
  (if (comint-check-proc "*SQL*")
      (pop-to-buffer "*SQL*")
    (sql-get-login 'database 'server)
    (message "Login...")
    ;; username and password are ignored.
    (let ((params))
      (if (not (string= "" sql-database))
	  (setq params (append (list sql-database) params)))
      (if (not (string= "" sql-server))
	  (setq params (append (list "-h" sql-server) params)))
      (set-buffer (apply 'make-comint "SQL" sql-postgres-program 
			 nil params)))
    (setq sql-prompt-regexp "^.*> *")
    (setq sql-prompt-length 5)
    ;; This is a lousy hack to prevent psql from truncating it's output
    ;; and giving stupid warnings. If s.o. knows a way to prevent psql 
    ;; from acting this way, then I would be very thankful to
    ;; incorporate this (Gregor Zych <zych@pool.informatik.rwth-aachen.de>)
    (comint-send-string "*SQL*" "\\o \| cat\n")
    (setq sql-mode-font-lock-keywords sql-mode-postgres-font-lock-keywords)
    (setq sql-buffer (current-buffer))
    (sql-interactive-mode)
    (message "Login...done")
    (pop-to-buffer sql-buffer)))

(provide 'sql)

;;; sql.el ends here
