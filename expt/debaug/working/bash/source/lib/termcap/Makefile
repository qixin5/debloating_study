# Generated automatically from Makefile.in by configure.
## -*- text -*- ####################################################
#								   #
# Makefile for termcap replacement libbrary.			   #
#								   #
####################################################################

# Copyright (C) 1996 Free Software Foundation, Inc.     

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
CPPFLAGS =  -D_LARGEFILE64_SOURCE
LDFLAGS =  

DEFS = -DHAVE_CONFIG_H

INCLUDES = -I. -I../.. -I$(topdir) -I$(topdir)/lib -I$(srcdir)

CCFLAGS = $(CFLAGS) $(DEFS) $(CPPFLAGS) ${INCLUDES}

# Here is a rule for making .o files from .c files that doesn't force
# the type of the machine (like -sun3) into the flags.
.c.o:
	$(CC) -c $(CCFLAGS) $<

SOURCES = termcap.c tparam.c
OBJECTS = termcap.o tparam.o

DOCUMENTATION = termcap.texinfo

THINGS_TO_TAR = $(SOURCES) $(DOCUMENTATION)

##########################################################################

all: libtermcap.a

libtermcap.a:	$(OBJECTS)
	$(RM) -f $@
	$(AR) $(ARFLAGS) $@ $(OBJECTS)
	-test -n "$(RANLIB)" && $(RANLIB) $@

install:	

clean:
	$(RM) *.o *.a *.log *.cp *.tp *.vr *.fn *.aux *.pg *.toc

mostlyclean: clean

distclean maintainer-clean: clean
	$(RM) Makefile

$(DESTDIR)/libtermcap.a: libtermcap.a
	${INSTALL_DATA} -c -m 644 libtermcap.a $@
	-test -n "$(RANLIB)" && $(RANLIB) -t $@

termcap.o: $(BUILD_DIR)/config.h
tparam.o: $(BUILD_DIR)/config.h
version.o: $(BUILD_DIR)/config.h
