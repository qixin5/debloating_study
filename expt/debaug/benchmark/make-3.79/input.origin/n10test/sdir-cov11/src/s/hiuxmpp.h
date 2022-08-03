/* System description file for HI-UX.  */

#define BSD 198911   /* system version (year & month) */
#define DBL_DIG 15   /* same as the definition of <float.h> */
#include "bsd4-3.h"

/* Identify OSF1 for the m- files. */

#define OSF1

/* To avoid to include the non-existant header file <sys/vlimit.h>,
    we define BSD4_2.
    This definition does not mean that the OS is based on BSD 4.2.  */
#define BSD4_2

/* Define _BSD to tell the include files we're running under
   the BSD universe and not the SYSV universe.  
   Define HITACHI and OSF for Xt's Boolean type as int intead of char.  
   (But for these defines, /usr/include/X11/Intrinsic.h defines 
   Boolean as char, but libXt.a on HI-UX/MPP requires it as int.)  */

#define C_SWITCH_SYSTEM	-D_BSD -DHITACHI -DOSF
#define LIBS_SYSTEM	-lbsd

#define GETPGRP_NO_ARG

#define read sys_read
#define write sys_write
#define open sys_open
#define close sys_close

#define INTERRUPTIBLE_OPEN
#define INTERRUPTIBLE_CLOSE
#define INTERRUPTIBLE_IO

#define SYSV_SYSTEM_DIR

/* If your system uses COFF (Common Object File Format) then define the
   preprocessor symbol "COFF". */

/* #define COFF */

/* Here is how to find X Windows.  LD_SWITCH_X_SITE_AUX gives an -R option
   says where to find X windows at run time.  We convert it to a -rpath option
   which is what OSF1 uses.  */
#define LD_SWITCH_SYSTEM 

#undef KERNEL_FILE
#define KERNEL_FILE "/mach_kernel"

#undef LDAV_SYMBOL
#define LDAV_SYMBOL "avenrun"

