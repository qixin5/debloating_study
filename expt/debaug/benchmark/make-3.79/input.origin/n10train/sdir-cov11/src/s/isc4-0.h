#include "isc3-0.h"

#undef LIBS_SYSTEM
#define LIBS_SYSTEM -linet -lcposix

#define ISC4_0

/* fmcphers@csugrad.cs.vt.edu reported this was necessary.
   He used GCC.  I don't know what is needed with other compilers.  */
#ifdef __GNUC__
#undef LIBX11_SYSTEM
#define LIBX11_SYSTEM -lpt -lnls -lnsl_s -lcposix -lc
#endif

/* Tobias Herbert <herbert@clipper.ikp.physik.th-darmstadt.de>
   says this is needed.  */

#ifndef POSIX_SIGNALS
#ifndef sigblock
#ifndef SIG_BLOCK
#define SIG_BLOCK 0
#endif
#define sigblock(sig) (sigprocmask (SIG_BLOCK, SIGEMPTYMASK | sig, NULL))
#endif
#endif /* not POSIX_SIGNALS */
