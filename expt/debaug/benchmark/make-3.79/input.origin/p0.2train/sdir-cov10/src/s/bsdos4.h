/* s/ file for BSDI BSD/OS 4.0 system.  */

#include "bsdos3.h"

/* copied from freebsd.h */
#ifdef __ELF__

#define LD_SWITCH_SYSTEM
#undef START_FILES
#define START_FILES \
	pre-crt0.o /usr/lib/crt1.o /usr/lib/crti.o /usr/lib/crtbegin.o
#define UNEXEC unexelf.o
#define LIB_STANDARD -lgcc -lc -lgcc /usr/lib/crtend.o /usr/lib/crtn.o
#undef LIB_GCC
#define LIB_GCC

#endif /* not __ELF__ */
