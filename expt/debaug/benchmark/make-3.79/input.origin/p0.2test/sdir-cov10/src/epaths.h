/* Hey Emacs, this is -*- C -*- code!  */

/* The default search path for Lisp function "load".
   This sets load-path.  */
#define PATH_LOADSEARCH "/usr/local/share/emacs/20.7/site-lisp:/usr/local/share/emacs/site-lisp:/usr/local/share/emacs/20.7/leim:/usr/local/share/emacs/20.7/lisp"

/* Like PATH_LOADSEARCH, but used only when Emacs is dumping.  This
   path is usually identical to PATH_LOADSEARCH except that the entry
   for the directory containing the installed lisp files has been
   replaced with ../lisp.  */
#define PATH_DUMPLOADSEARCH "/nfs/spectre/u6/ruthruff/research/subjects/make/inputs/sdir-cov10/lisp"

/* The extra search path for programs to invoke.  This is appended to
   whatever the PATH environment variable says to set the Lisp
   variable exec-path and the first file name in it sets the Lisp
   variable exec-directory.  exec-directory is used for finding
   executables and other architecture-dependent files.  */
#define PATH_EXEC "/usr/local/libexec/emacs/20.7/sparc-sun-solaris2.8"

/* Where Emacs should look for its architecture-independent data
   files, like the NEWS file.  The lisp variable data-directory
   is set to this value.  */
#define PATH_DATA "/usr/local/share/emacs/20.7/etc"

/* Where Emacs should look for X bitmap files.
   The lisp variable x-bitmap-file-path is set based on this value.  */
#define PATH_BITMAPS "/usr/openwin/include/X11/bitmaps"

/* Where Emacs should look for its docstring file.  The lisp variable
   doc-directory is set to this value.  */
#define PATH_DOC "/usr/local/share/emacs/20.7/etc"

/* Where the configuration process believes the info tree lives.  The
   lisp variable configure-info-directory gets its value from this
   macro, and is then used to set the Info-default-directory-list.  */
#define PATH_INFO "/usr/local/info"

/* Where Emacs should look for the application default file. */
#define PATH_X_DEFAULTS "/usr/openwin/lib/X11/%L/%T/%N%C%S:/usr/openwin/lib/X11/%L/%T/%N%C%S:/X11/%l/%T/%N%C%S:/usr/openwin/lib/X11/%T/%N%C%S:/usr/openwin/lib/X11/%L/%T/%N%S:/usr/openwin/lib/X11/%l/%T/%N%S:/usr/openwin/lib/X11/%T/%N%S"
