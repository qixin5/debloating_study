# Generated automatically from Makefile.in by configure.
# Makefile.in generated automatically by automake 1.4 from Makefile.am

# Copyright (C) 1994, 1995-8, 1999 Free Software Foundation, Inc.
# This Makefile.in is free software; the Free Software Foundation
# gives unlimited permission to copy and/or distribute it,
# with or without modifications, as long as this notice is preserved.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY, to the extent permitted by law; without
# even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE.

# Makefile for PO directories.
# Fran�ois Pinard <pinard@iro.umontreal.ca>, 1998.


SHELL = /bin/sh

srcdir = .
top_srcdir = ..
prefix = /usr/local
exec_prefix = ${prefix}

bindir = ${exec_prefix}/bin
sbindir = ${exec_prefix}/sbin
libexecdir = ${exec_prefix}/libexec
datadir = ${prefix}/share
sysconfdir = ${prefix}/etc
sharedstatedir = ${prefix}/com
localstatedir = ${prefix}/var
libdir = ${exec_prefix}/lib
infodir = ${prefix}/info
mandir = ${prefix}/man
includedir = ${prefix}/include
oldincludedir = /usr/include

DESTDIR =

pkgdatadir = $(datadir)/make
pkglibdir = $(libdir)/make
pkgincludedir = $(includedir)/make

top_builddir = ..

ACLOCAL = aclocal
AUTOCONF = autoconf
AUTOMAKE = automake
AUTOHEADER = autoheader

INSTALL = /usr/bin/install -c
INSTALL_PROGRAM = ${INSTALL} $(AM_INSTALL_PROGRAM_FLAGS)
INSTALL_DATA = ${INSTALL} -m 644
INSTALL_SCRIPT = ${INSTALL_PROGRAM}
transform = s,x,x,

NORMAL_INSTALL = :
PRE_INSTALL = :
POST_INSTALL = :
NORMAL_UNINSTALL = :
PRE_UNINSTALL = :
POST_UNINSTALL = :
host_alias = x86_64-unknown-linux-gnu
host_triplet = 
ALL_LINGUAS = de es fr ko nl pl ru
AR = ar
CC = gcc
CPP = gcc -E
GETCONF = getconf
GLOBDIR = glob
GLOBINC = -I$(srcdir)/glob
GLOBLIB = glob/libglob.a
LIBOBJS =  gettext.o
MAKEINFO = /home/qxin6/debaug_expt/debaug/working/make/originals/make-3.79/missing makeinfo
MAKE_HOST = 
PACKAGE = make
PERL = perl
RANLIB = ranlib
REMOTE = stub
VERSION = 3.79

AUTOMAKE_OPTIONS = gnits

localedir = $(prefix)/share/locale

ALL_POFILES =  de.po es.po fr.po ko.po nl.po pl.po ru.po
ALL_MOFILES =  de.mo es.mo fr.mo ko.mo nl.mo pl.mo ru.mo
MOFILES =  de.mo es.mo fr.mo ko.mo nl.mo pl.mo ru.mo

EXTRA_DIST = $(PACKAGE).pot $(ALL_POFILES) $(ALL_MOFILES)

MSGFMT = msgfmt
MSGMERGE = msgmerge
XGETTEXT = xgettext

SUFFIXES = .po .pox .mo

MAINTAINER_CLEAN = $(PACKAGE).pot $(MOFILES)
mkinstalldirs = $(SHELL) $(top_srcdir)/mkinstalldirs
CONFIG_HEADER = ../config.h
CONFIG_CLEAN_FILES = 
CFLAGS = -g -O2
COMPILE = $(CC) $(DEFS) $(INCLUDES) $(AM_CPPFLAGS) $(CPPFLAGS) $(AM_CFLAGS) $(CFLAGS)
CCLD = $(CC)
LINK = $(CCLD) $(AM_CFLAGS) $(CFLAGS) $(LDFLAGS) -o $@
DIST_COMMON =  Makefile.am Makefile.in


DISTFILES = $(DIST_COMMON) $(SOURCES) $(HEADERS) $(TEXINFOS) $(EXTRA_DIST)

TAR = tar
GZIP_ENV = --best
all: all-redirect
.SUFFIXES:
.SUFFIXES: .mo .po .pox
$(srcdir)/Makefile.in: Makefile.am $(top_srcdir)/configure.in $(ACLOCAL_M4) 
	cd $(top_srcdir) && $(AUTOMAKE) --gnits --include-deps i18n/Makefile

Makefile: $(srcdir)/Makefile.in  $(top_builddir)/config.status
	cd $(top_builddir) \
	  && CONFIG_FILES=$(subdir)/$@ CONFIG_HEADERS= $(SHELL) ./config.status

tags: TAGS
TAGS:


distdir = $(top_builddir)/$(PACKAGE)-$(VERSION)/$(subdir)

subdir = i18n

distdir: $(DISTFILES)
	@for file in $(DISTFILES); do \
	  d=$(srcdir); \
	  if test -d $$d/$$file; then \
	    cp -pr $$/$$file $(distdir)/$$file; \
	  else \
	    test -f $(distdir)/$$file \
	    || ln $$d/$$file $(distdir)/$$file 2> /dev/null \
	    || cp -p $$d/$$file $(distdir)/$$file || :; \
	  fi; \
	done
info-am:
info: info-am
dvi-am:
dvi: dvi-am
check-am: all-am
check: check-am
installcheck-am:
installcheck: installcheck-am
install-exec-am:
install-exec: install-exec-am

install-data-am: install-data-local
install-data: install-data-am

install-am: all-am
	@$(MAKE) $(AM_MAKEFLAGS) install-exec-am install-data-am
install: install-am
uninstall-am: uninstall-local
uninstall: uninstall-am
all-am: Makefile
all-redirect: all-am
install-strip:
	$(MAKE) $(AM_MAKEFLAGS) AM_INSTALL_PROGRAM_FLAGS=-s install
installdirs:


mostlyclean-generic:

clean-generic:

distclean-generic:
	-rm -f Makefile $(CONFIG_CLEAN_FILES)
	-rm -f config.cache config.log stamp-h stamp-h[0-9]*

maintainer-clean-generic:
mostlyclean-am:  mostlyclean-generic

mostlyclean: mostlyclean-am

clean-am:  clean-generic mostlyclean-am

clean: clean-am

distclean-am:  distclean-generic clean-am

distclean: distclean-am

maintainer-clean-am:  maintainer-clean-generic distclean-am
	@echo "This command is intended for maintainers to use;"
	@echo "it deletes files that may require special tools to rebuild."

maintainer-clean: maintainer-clean-am

.PHONY: tags distdir info-am info dvi-am dvi check check-am \
installcheck-am installcheck install-exec-am install-exec \
install-data-local install-data-am install-data install-am install \
uninstall-local uninstall-am uninstall all-redirect all-am all \
installdirs mostlyclean-generic distclean-generic clean-generic \
maintainer-clean-generic clean mostlyclean distclean maintainer-clean


.po.pox:
	$(MAKE) $(PACKAGE).pot
	$(MSGMERGE) $< $(srcdir)/$(PACKAGE).pot -o $*.pox

.po.mo:
	file=$(srcdir)/`echo $* | sed 's,.*/,,'`.mo \
	  && rm -f $$file && $(MSGFMT) -o $$file $<

all: $(ALL_MOFILES)

install-data-local: $(MOFILES)
	files='$(MOFILES)'; \
	for file in $$files; do \
	  base=`basename $$file`; \
	  langdir=$(DESTDIR)$(localedir)/`echo $$base | sed 's/\.mo$$//'`/LC_MESSAGES; \
	  $(mkinstalldirs) $$langdir; \
	  echo " $(INSTALL_DATA) $(srcdir)/$$file $$langdir/$(PACKAGE).mo"; \
	  $(INSTALL_DATA) $(srcdir)/$$file $$langdir/$(PACKAGE).mo; \
	done

uninstall-local:
	files='$(MOFILES)'; \
	for file in $$files; do \
	  base=`basename $$file`; \
	  langdir=$(DESTDIR)$(localedir)/`echo $$base | sed 's/\.mo$$//'`/LC_MESSAGES; \
	  rm -f $$langdir/$(PACKAGE).mo; \
	done

$(srcdir)/$(PACKAGE).pot: $(top_srcdir)/stamp-pot
	$(XGETTEXT) --default-domain=$(PACKAGE) --directory=$(top_srcdir) \
	  --add-comments --keyword=_ --keyword=N_ `cat $(top_srcdir)/stamp-pot`
	test ! -f $(PACKAGE).po || ( rm -f $@ && mv $(PACKAGE).po $@ )

update-po: Makefile
	$(MAKE) $(PACKAGE).pot
	files='$(ALL_MOFILES)'; \
	for file in $$files; do \
	  base=`basename $$file`; \
	  lang=`echo $$base | sed 's/\.mo$$//'`; \
	  mv $(srcdir)/$$lang.po $(srcdir)/$$lang.old.po; \
	  echo "$$lang:"; \
	  cd $(srcdir) \
	    && if $(MSGMERGE) $$lang.old.po $(PACKAGE).pot -o $$lang.po; then \
	      rm -f $$lang.old.po; \
	    else \
	      echo "msgmerge for $$file failed!"; \
	      rm -f $$lang.po; \
	      mv $$lang.old.po $$lang.po; \
	    fi; \
	done

# Tell versions [3.59,3.63) of GNU make to not export all variables.
# Otherwise a system limit (for SysV at least) may be exceeded.
.NOEXPORT:
