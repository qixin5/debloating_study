# Generated automatically from Makefile.in by configure.
#
# Makefile for the Bash library
#
#
# Copyright (C) 1998 Free Software Foundation, Inc.     

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2, or (at your option)
# any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111 USA.

srcdir = .
VPATH = .:.
topdir = ../..
BUILD_DIR = /home/qxin6/debaug_expt/debaug/working/bash/source

BASHINCDIR = ${topdir}/include

INSTALL = /usr/bin/install -c
INSTALL_PROGRAM = ${INSTALL}
INSTALL_DATA = ${INSTALL} -m 644

CC = gcc
RANLIB = ranlib
AR = ar
ARFLAGS = cr
RM = rm -f
CP = cp
MV = mv

SHELL = /bin/sh

CFLAGS = -g -O2
LOCAL_CFLAGS = 
CPPFLAGS =  -D_LARGEFILE64_SOURCE
LDFLAGS =   

PROFILE_FLAGS = 

DEFS = -DHAVE_CONFIG_H
LOCAL_DEFS = -DSHELL

INCLUDES = -I. -I../.. -I$(topdir) -I$(topdir)/lib -I$(BASHINCDIR) -I$(srcdir)

CCFLAGS = ${PROFILE_FLAGS} ${INCLUDES} $(DEFS) $(LOCAL_DEFS) $(LOCAL_CFLAGS) \
	  $(CFLAGS) $(CPPFLAGS) 

.c.o:
	$(CC) -c $(CCFLAGS) $<

# The name of the library target.
LIBRARY_NAME = libsh.a

# The C code source files for this library.
CSOURCES = clktck.c clock.c getcwd.c getenv.c oslib.c setlinebuf.c \
	   strcasecmp.c strerror.c strtod.c strtol.c strtoul.c \
	   vprint.c itos.c rename.c zread.c zwrite.c shtty.c \
	   inet_aton.c netopen.c strpbrk.c timeval.c makepath.c pathcanon.c \
	   pathphys.c tmpfile.c stringlist.c stringvec.c spell.c \
	   shquote.c strtrans.c strindex.c

# The header files for this library.
HSOURCES = 

# The object files contained in $(LIBRARY_NAME)
OBJECTS = clktck.o clock.o getcwd.o getenv.o oslib.o setlinebuf.o \
	  strcasecmp.o strerror.o strtod.o strtol.o strtoul.o \
	  vprint.o itos.o rename.o zread.o zwrite.o shtty.o \
	  inet_aton.o netopen.o strpbrk.o timeval.o makepath.o pathcanon.o \
	  pathphys.o tmpfile.o stringlist.o stringvec.o spell.o shquote.o \
	  strtrans.o strindex.o

SUPPORT = Makefile

all: $(LIBRARY_NAME)

$(LIBRARY_NAME): $(OBJECTS)
	$(RM) $@
	$(AR) $(ARFLAGS) $@ $(OBJECTS)
	-test -n "$(RANLIB)" && $(RANLIB) $@

force:

# The rule for 'includes' is written funny so that the if statement
# always returns TRUE unless there really was an error installing the
# include files.
install:

clean:
	$(RM) $(OBJECTS) $(LIBRARY_NAME)

realclean distclean maintainer-clean: clean
	$(RM) Makefile

mostlyclean: clean

# Dependencies

# rules for losing makes, like SunOS
clktck.o: clktck.c
clock.o: clock.c
getcwd.o: getcwd.c
getenv.o: getenv.c
inet_aton.o: inet_aton.c
itos.o: itos.c
makepath.o: makepath.c
netopen.o: netopen.c
oslib.o: oslib.c
pathcanon.o: pathcanon.c
pathphys.o: pathphys.c
rename.o: rename.c
setlinebuf.o: setlinebuf.c
shquote.o: shquote.c
shtty.o: shtty.c
spell.o: spell.c
strcasecmp.o: strcasecmp.c
strerror.o: strerror.c
strindex.o: strindex.c
stringlist.o: stringlist.c
stringvec.o: stringvec.c
strpbrk.o: strpbrk.c
strtod.o: strtod.c
strtol.o: strtol.c
strtoul.o: strtoul.c
strtrans.o: strtrans.c
times.o: times.c
timeval.o: timeval.c
tmpfile.o: tmpfile.c
vprint.o: vprint.c
zread.o: zread.c
zwrite.o: zwrite.c

# all files in the library depend on config.h
clktck.o: ${BUILD_DIR}/config.h
clock.o: ${BUILD_DIR}/config.h
getcwd.o: ${BUILD_DIR}/config.h
getenv.o: ${BUILD_DIR}/config.h
inet_aton.o: ${BUILD_DIR}/config.h
itos.o: ${BUILD_DIR}/config.h
makepath.o: ${BUILD_DIR}/config.h
netopen.o: ${BUILD_DIR}/config.h
oslib.o: ${BUILD_DIR}/config.h
pathcanon.o: ${BUILD_DIR}/config.h
pathphys.o: ${BUILD_DIR}/config.h
rename.o: ${BUILD_DIR}/config.h
setlinebuf.o: ${BUILD_DIR}/config.h
shquote.o: ${BUILD_DIR}/config.h
shtty.o: ${BUILD_DIR}/config.h
spell.o: ${BUILD_DIR}/config.h
strcasecmp.o: ${BUILD_DIR}/config.h
strerror.o: ${BUILD_DIR}/config.h
strindex.o: ${BUILD_DIR}/config.h
stringlist.o: ${BUILD_DIR}/config.h
stringvec.o: ${BUILD_DIR}/config.h
strpbrk.o: ${BUILD_DIR}/config.h
strtod.o: ${BUILD_DIR}/config.h
strtol.o: ${BUILD_DIR}/config.h
strtoul.o: ${BUILD_DIR}/config.h
strtrans.o: ${BUILD_DIR}/config.h
times.o: ${BUILD_DIR}/config.h
timeval.o: ${BUILD_DIR}/config.h
tmpfile.o: ${BUILD_DIR}/config.h
vprint.o: ${BUILD_DIR}/config.h
zread.o: ${BUILD_DIR}/config.h
zwrite.o: ${BUILD_DIR}/config.h

clktck.o: ${topdir}/bashtypes.h

getcwd.o: ${topdir}/bashtypes.h ${topdir}/bashansi.h ${BASHINCDIR}/maxpath.h
getcwd.o: ${BASHINCDIR}/posixstat.h ${BASHINCDIR}/posixdir.h
getcwd.o: ${BASHINCDIR}/memalloc.h ${BASHINCDIR}/ansi_stdlib.h

getenv.o: ${topdir}/bashansi.h ${BASHINCDIR}/ansi_stdlib.h
getenv.o: ${topdir}/shell.h ${topdir}/syntax.h ${topdir}/bashjmp.h ${BASHINCDIR}/posixjmp.h
getenv.o: ${topdir}/command.h ${BASHINCDIR}/stdc.h ${topdir}/error.h
getenv.o: ${topdir}/general.h ${topdir}/bashtypes.h ${topdir}/variables.h
getenv.o: ${topdir}/array.h ${topdir}/hashlib.h ${topdir}/quit.h
getenv.o: ${topdir}/unwind_prot.h ${topdir}/dispose_cmd.h
getenv.o: ${topdir}/make_cmd.h ${topdir}/subst.h ${topdir}/sig.h
getenv.o: ${topdir}/pathnames.h ${topdir}/externs.h

inet_aton.o: ${topdir}/bashansi.h ${BASHINCDIR}/ansi_stdlib.h
inet_aton.o: ${BASHINCDIR}/stdc.h

itos.o: ${topdir}/bashansi.h ${BASHINCDIR}/ansi_stdlib.h
itos.o: ${topdir}/shell.h ${topdir}/syntax.h ${topdir}/bashjmp.h ${BASHINCDIR}/posixjmp.h
itos.o: ${topdir}/command.h ${BASHINCDIR}/stdc.h ${topdir}/error.h
itos.o: ${topdir}/general.h ${topdir}/bashtypes.h ${topdir}/variables.h
itos.o: ${topdir}/array.h ${topdir}/hashlib.h ${topdir}/quit.h
itos.o: ${topdir}/unwind_prot.h ${topdir}/dispose_cmd.h
itos.o: ${topdir}/make_cmd.h ${topdir}/subst.h ${topdir}/sig.h
itos.o: ${topdir}/pathnames.h ${topdir}/externs.h

makepath.o: ${topdir}/bashansi.h ${BASHINCDIR}/ansi_stdlib.h
makepath.o: ${topdir}/shell.h ${topdir}/syntax.h ${topdir}/bashjmp.h ${BASHINCDIR}/posixjmp.h
makepath.o: ${topdir}/command.h ${BASHINCDIR}/stdc.h ${topdir}/error.h
makepath.o: ${topdir}/general.h ${topdir}/bashtypes.h ${topdir}/variables.h
makepath.o: ${topdir}/array.h ${topdir}/hashlib.h ${topdir}/quit.h
makepath.o: ${topdir}/unwind_prot.h ${topdir}/dispose_cmd.h
makepath.o: ${topdir}/make_cmd.h ${topdir}/subst.h ${topdir}/sig.h
makepath.o: ${topdir}/pathnames.h ${topdir}/externs.h

netopen.o: ${topdir}/bashansi.h ${BASHINCDIR}/ansi_stdlib.h

oslib.o: ${topdir}/bashtypes.h ${topdir}/bashansi.h ${BASHINCDIR}/maxpath.h
oslib.o: ${topdir}/shell.h ${topdir}/syntax.h ${topdir}/bashjmp.h ${BASHINCDIR}/posixjmp.h
oslib.o: ${topdir}/command.h ${BASHINCDIR}/stdc.h ${topdir}/error.h
oslib.o: ${topdir}/general.h ${topdir}/bashtypes.h ${topdir}/variables.h
oslib.o: ${topdir}/array.h ${topdir}/hashlib.h ${topdir}/quit.h
oslib.o: ${topdir}/unwind_prot.h ${topdir}/dispose_cmd.h
oslib.o: ${topdir}/make_cmd.h ${topdir}/subst.h ${topdir}/sig.h
oslib.o: ${topdir}/pathnames.h ${topdir}/externs.h
oslib.o: ${BASHINCDIR}/posixstat.h ${BASHINCDIR}/filecntl.h
oslib.o: ${BASHINCDIR}/ansi_stdlib.h

pathcanon.o: ${topdir}/bashtypes.h ${topdir}/bashansi.h ${BASHINCDIR}/maxpath.h
pathcanon.o: ${topdir}/shell.h ${topdir}/syntax.h ${topdir}/bashjmp.h ${BASHINCDIR}/posixjmp.h
pathcanon.o: ${topdir}/command.h ${BASHINCDIR}/stdc.h ${topdir}/error.h
pathcanon.o: ${topdir}/general.h ${topdir}/bashtypes.h ${topdir}/variables.h
pathcanon.o: ${topdir}/array.h ${topdir}/hashlib.h ${topdir}/quit.h
pathcanon.o: ${topdir}/unwind_prot.h ${topdir}/dispose_cmd.h
pathcanon.o: ${topdir}/make_cmd.h ${topdir}/subst.h ${topdir}/sig.h
pathcanon.o: ${topdir}/pathnames.h ${topdir}/externs.h
pathcanon.o: ${BASHINCDIR}/posixstat.h ${BASHINCDIR}/filecntl.h
pathcanon.o: ${BASHINCDIR}/ansi_stdlib.h

pathphys.o: ${topdir}/bashtypes.h ${topdir}/bashansi.h ${BASHINCDIR}/maxpath.h
pathphys.o: ${topdir}/shell.h ${topdir}/syntax.h ${topdir}/bashjmp.h ${BASHINCDIR}/posixjmp.h
pathphys.o: ${topdir}/command.h ${BASHINCDIR}/stdc.h ${topdir}/error.h
pathphys.o: ${topdir}/general.h ${topdir}/bashtypes.h ${topdir}/variables.h
pathphys.o: ${topdir}/array.h ${topdir}/hashlib.h ${topdir}/quit.h
pathphys.o: ${topdir}/unwind_prot.h ${topdir}/dispose_cmd.h
pathphys.o: ${topdir}/make_cmd.h ${topdir}/subst.h ${topdir}/sig.h
pathphys.o: ${topdir}/pathnames.h ${topdir}/externs.h
pathphys.o: ${BASHINCDIR}/posixstat.h ${BASHINCDIR}/filecntl.h
pathphys.o: ${BASHINCDIR}/ansi_stdlib.h

rename.o: ${topdir}/bashtypes.h ${BASHINCDIR}/stdc.h

shtty.o: ${BASHINCDIR}/shtty.h
shtty.o: ${BASHINCDIR}/stdc.h

spell.o: ${topdir}/bashtypes.h
spell.o: ${BASHINCDIR}/posixstat.h ${BASHINCDIR}/posixdir.h
spell.o: ${BASHINCDIR}/ansi_stdlib.h

strcasecmp.o: ${BASHINCDIR}/stdc.h ${topdir}/bashansi.h
strcasecmp.o: ${BASHINCDIR}/ansi_stdlib.h

strerror.o: ${topdir}/bashtypes.h
strerror.o: ${topdir}/shell.h ${topdir}/syntax.h ${topdir}/bashjmp.h ${BASHINCDIR}/posixjmp.h
strerror.o: ${topdir}/command.h ${BASHINCDIR}/stdc.h ${topdir}/error.h
strerror.o: ${topdir}/general.h ${topdir}/bashtypes.h ${topdir}/variables.h
strerror.o: ${topdir}/array.h ${topdir}/hashlib.h ${topdir}/quit.h
strerror.o: ${topdir}/unwind_prot.h ${topdir}/dispose_cmd.h
strerror.o: ${topdir}/make_cmd.h ${topdir}/subst.h ${topdir}/sig.h
strerror.o: ${topdir}/pathnames.h ${topdir}/externs.h

strindex.o: ${BASHINCDIR}/stdc.h ${topdir}/bashansi.h
strindex.o: ${BASHINCDIR}/ansi_stdlib.h

stringlist.o: ${topdir}/bashansi.h
stringlist.o: ${topdir}/shell.h ${topdir}/syntax.h ${topdir}/bashjmp.h ${BASHINCDIR}/posixjmp.h
stringlist.o: ${topdir}/command.h ${BASHINCDIR}/stdc.h ${topdir}/error.h
stringlist.o: ${topdir}/general.h ${topdir}/bashtypes.h ${topdir}/variables.h
stringlist.o: ${topdir}/array.h ${topdir}/hashlib.h ${topdir}/quit.h
stringlist.o: ${topdir}/unwind_prot.h ${topdir}/dispose_cmd.h
stringlist.o: ${topdir}/make_cmd.h ${topdir}/subst.h ${topdir}/sig.h
stringlist.o: ${topdir}/pathnames.h ${topdir}/externs.h

stringvec.o: ${topdir}/bashansi.h
stringvec.o: ${topdir}/shell.h ${topdir}/syntax.h ${topdir}/bashjmp.h ${BASHINCDIR}/posixjmp.h
stringvec.o: ${topdir}/command.h ${BASHINCDIR}/stdc.h ${topdir}/error.h
stringvec.o: ${topdir}/general.h ${topdir}/bashtypes.h ${topdir}/variables.h
stringvec.o: ${topdir}/array.h ${topdir}/hashlib.h ${topdir}/quit.h
stringvec.o: ${topdir}/unwind_prot.h ${topdir}/dispose_cmd.h
stringvec.o: ${topdir}/make_cmd.h ${topdir}/subst.h ${topdir}/sig.h
stringvec.o: ${topdir}/pathnames.h ${topdir}/externs.h

strpbrk.o: ${BASHINCDIR}/stdc.h

strtod.o: ${topdir}/bashansi.h
strtod.o: ${BASHINCDIR}/ansi_stdlib.h

strtol.o: ${topdir}/bashansi.h
strtol.o: ${BASHINCDIR}/ansi_stdlib.h

strtoul.o: ${topdir}/bashansi.h
strtoul.o: ${BASHINCDIR}/ansi_stdlib.h

strtrans.o: ${topdir}/bashansi.h
strtrans.o: ${BASHINCDIR}/ansi_stdlib.h
strtrans.o: ${topdir}/shell.h ${topdir}/syntax.h ${topdir}/bashjmp.h ${BASHINCDIR}/posixjmp.h
strtrans.o: ${topdir}/command.h ${BASHINCDIR}/stdc.h ${topdir}/error.h
strtrans.o: ${topdir}/general.h ${topdir}/bashtypes.h ${topdir}/variables.h
strtrans.o: ${topdir}/array.h ${topdir}/hashlib.h ${topdir}/quit.h
strtrans.o: ${topdir}/unwind_prot.h ${topdir}/dispose_cmd.h
strtrans.o: ${topdir}/make_cmd.h ${topdir}/subst.h ${topdir}/sig.h
strtrans.o: ${topdir}/pathnames.h ${topdir}/externs.h

times.o: ${BASHINCDIR}/systimes.h
times.o: ${BASHINCDIR}/posixtime.h

timeval.o: ${BASHINCDIR}/posixtime.h

tmpfile.o: ${topdir}/bashtypes.h
tmpfile.o: ${BASHINCDIR}/posixstat.h
tmpfile.o: ${BASHINCDIR}/filecntl.h

clock.o: ${BASHINCDIR}/posixtime.h
