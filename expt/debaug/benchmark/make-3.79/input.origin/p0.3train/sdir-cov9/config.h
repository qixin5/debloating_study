/* config.h.  Generated automatically by configure.  */
/* config.h.in.  Generated automatically from configure.in by autoheader.  */

/* Define if using alloca.c.  */
/* #undef C_ALLOCA */

/* Define to empty if the keyword does not work.  */
/* #undef const */

/* Define to one of _getb67, GETB67, getb67 for Cray-2 and Cray-YMP systems.
   This function is required for alloca.c support on those systems.  */
/* #undef CRAY_STACKSEG_END */

/* Define if you have alloca, as a function or macro.  */
#define HAVE_ALLOCA 1

/* Define if you have <alloca.h> and it should be used (not on Ultrix).  */
#define HAVE_ALLOCA_H 1

/* Define if you don't have vprintf but do have _doprnt.  */
/* #undef HAVE_DOPRNT */

/* Define if you have a working `mmap' system call.  */
#define HAVE_MMAP 1

/* Define if you have the vprintf function.  */
#define HAVE_VPRINTF 1

/* Define as __inline if that's what the C compiler calls it.  */
/* #undef inline */

/* Define as the return type of signal handlers (int or void).  */
#define RETSIGTYPE void

/* Define to `unsigned' if <sys/types.h> doesn't define.  */
/* #undef size_t */

/* If using the C implementation of alloca, define if you know the
   direction of stack growth for your system; otherwise it will be
   automatically deduced at run-time.
 STACK_DIRECTION > 0 => grows toward higher addresses
 STACK_DIRECTION < 0 => grows toward lower addresses
 STACK_DIRECTION = 0 => direction of growth unknown
 */
/* #undef STACK_DIRECTION */

/* Define if you have the ANSI C header files.  */
#define STDC_HEADERS 1

/* Define if you can safely include both <sys/time.h> and <time.h>.  */
#define TIME_WITH_SYS_TIME 1

/* Define if the X Window System is missing or not being used.  */
/* #undef X_DISPLAY_MISSING */

/* Installation directory (used to determine PKGDATADIR below). */
#define DATADIR "/usr/local/share"

/* Define if you have the gtkextra library (-lgtkextra).  */
/* #undef HAVE_LIBGTKEXTRA */

/* Define if you have the XCopyPlane function.  */
#define HAVE_XCOPYPLANE 1

/* Define if you have the acosf function.  */
/* #undef HAVE_ACOSF */

/* Define if you have the asinf function.  */
/* #undef HAVE_ASINF */

/* Define if you have the atanf function.  */
/* #undef HAVE_ATANF */

/* Define if you have the cosf function.  */
/* #undef HAVE_COSF */

/* Define if you have the fork function.  */
#define HAVE_FORK 1

/* Define if you have the fstat function.  */
#define HAVE_FSTAT 1

/* Define if you have the getdtablesize function.  */
#define HAVE_GETDTABLESIZE 1

/* Define if you have the getlogin function.  */
#define HAVE_GETLOGIN 1

/* Define if you have the getpagesize function.  */
#define HAVE_GETPAGESIZE 1

/* Define if you have the getpwuid function.  */
#define HAVE_GETPWUID 1

/* Define if you have the gettimeofday function.  */
#define HAVE_GETTIMEOFDAY 1

/* Define if you have the isatty function.  */
#define HAVE_ISATTY 1

/* Define if you have the lrint function.  */
/* #undef HAVE_LRINT */

/* Define if you have the random function.  */
#define HAVE_RANDOM 1

/* Define if you have the readv function.  */
#define HAVE_READV 1

/* Define if you have the select function.  */
#define HAVE_SELECT 1

/* Define if you have the setvbuf function.  */
#define HAVE_SETVBUF 1

/* Define if you have the sigaction function.  */
#define HAVE_SIGACTION 1

/* Define if you have the sigblock function.  */
/* #undef HAVE_SIGBLOCK */

/* Define if you have the sigprocmask function.  */
#define HAVE_SIGPROCMASK 1

/* Define if you have the sigvec function.  */
/* #undef HAVE_SIGVEC */

/* Define if you have the sinf function.  */
/* #undef HAVE_SINF */

/* Define if you have the tanf function.  */
/* #undef HAVE_TANF */

/* Define if you have the <fcntl.h> header file.  */
#define HAVE_FCNTL_H 1

/* Define if you have the <gdk/gdkx.h> header file.  */
#define HAVE_GDK_GDKX_H 1

/* Define if you have the <gtkextra/gtksheet.h> header file.  */
/* #undef HAVE_GTKEXTRA_GTKSHEET_H */

/* Define if you have the <limits.h> header file.  */
#define HAVE_LIMITS_H 1

/* Define if you have the <pwd.h> header file.  */
#define HAVE_PWD_H 1

/* Define if you have the <stropts.h> header file.  */
#define HAVE_STROPTS_H 1

/* Define if you have the <sys/file.h> header file.  */
#define HAVE_SYS_FILE_H 1

/* Define if you have the <sys/ioctl.h> header file.  */
#define HAVE_SYS_IOCTL_H 1

/* Define if you have the <sys/mman.h> header file.  */
#define HAVE_SYS_MMAN_H 1

/* Define if you have the <sys/socket.h> header file.  */
#define HAVE_SYS_SOCKET_H 1

/* Define if you have the <sys/stat.h> header file.  */
#define HAVE_SYS_STAT_H 1

/* Define if you have the <sys/time.h> header file.  */
#define HAVE_SYS_TIME_H 1

/* Define if you have the <sys/types.h> header file.  */
#define HAVE_SYS_TYPES_H 1

/* Define if you have the <sys/uio.h> header file.  */
#define HAVE_SYS_UIO_H 1

/* Define if you have the <sys/wait.h> header file.  */
#define HAVE_SYS_WAIT_H 1

/* Define if you have the <unistd.h> header file.  */
#define HAVE_UNISTD_H 1

/* Define if you have the dl library (-ldl).  */
#define HAVE_LIBDL 1

/* Define if you have the gdbm library (-lgdbm).  */
#define HAVE_LIBGDBM 1

/* Define if you have the m library (-lm).  */
#define HAVE_LIBM 1

/* Define if you have the readline library (-lreadline).  */
#define HAVE_LIBREADLINE 1

/* Name of package */
#define PACKAGE "gnubg"

/* Version number of package */
#define VERSION "0.10"

/* Define if you want to use the Guile extensibility language. */
/* #undef USE_GUILE */

/* Define if you have a signbit() macro faster than a compare to 0.0. */
/* #undef HAVE_SIGNBIT */

/* Define if the system supports AC_LOCAL sockets. */
#define HAVE_SOCKETS 1

/* Define if you want to use the ext toolkit and widgets. */
/* #undef USE_EXT */

/* Define if you want to use the GTK toolkit and widgets. */
#define USE_GTK 1

/* Are we using either GUI (ext or GTK)? */
#if USE_EXT || USE_GTK
#define USE_GUI 1
#endif

/* The directory where the weights and databases will be stored. */
#define PKGDATADIR DATADIR "/" PACKAGE

/* Define the obvious signbit() if the C library doesn't. */
#if !HAVE_SIGNBIT
#define signbit(x) ( (x) < 0.0 )
#endif

/* Use the double versions of the math functions if the float ones aren't
   available. */
#if !HAVE_ACOSF
#define acosf acos
#endif

#if !HAVE_ASINF
#define asinf asin
#endif

#if !HAVE_ATANF
#define atanf atan
#endif

#if !HAVE_COSF
#define cosf cos
#endif

#if !HAVE_LRINT
#define lrint(x) ((long) ((x)+0.5))
#endif

#if !HAVE_SINF
#define sinf sin
#endif

#if !HAVE_TANF
#define tanf tan
#endif

#ifndef FALSE
#define FALSE 0
#define TRUE 1
#endif

#ifndef _GNU_SOURCE
#define _GNU_SOURCE 1
#endif
