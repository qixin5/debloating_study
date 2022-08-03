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


SHELL = /bin/sh

srcdir = .
top_srcdir = .
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

pkgdatadir = $(datadir)/gnubg
pkglibdir = $(libdir)/gnubg
pkgincludedir = $(includedir)/gnubg

top_builddir = .

ACLOCAL = /nfs/spectre/u6/ruthruff/research/subjects/make/inputs/sdir-test/missing aclocal
AUTOCONF = autoconf
AUTOMAKE = /nfs/spectre/u6/ruthruff/research/subjects/make/inputs/sdir-test/missing automake
AUTOHEADER = autoheader

INSTALL = /usr/local/bin/install -c
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
AWK = gawk
BISON = bison
CC = gcc
FLEX = flex
GNUPLOT = gnuplot
GTK_CFLAGS = -I/usr/local/lib/glib/include -I/usr/local/include -I/usr/local/X11R6.4/include
GTK_CONFIG = /usr/local/bin/gtk-config
GTK_LIBS = -L/usr/local/lib -L/usr/local/X11R6.4/lib -R/usr/local/X11R6.4/lib -lgtk -lgdk -lgmodule -lglib -ldl -lXext -lX11 -lsocket -lnsl -lm
GUILE_CFLAGS = 
GUILE_CONFIG = no
GUILE_LDFLAGS = 
LN_S = ln -s
MAKEINFO = makeinfo
PACKAGE = gnubg
PNGTOPNM = 
PNMTOPS = 
RANLIB = ranlib
TR = tr
VERSION = 0.10
SUBDIRS = lib doc ext
SUBDIRS = lib doc

COMMON_INCS = -I$(srcdir)/lib 
COMMON_LIBS = -Llib -levent 
COMMON_SOURCES = backgammon.h gnubg.c getopt.h getopt.c getopt1.c eval.h 	eval.c play.c positionid.h positionid.c drawboard.h drawboard.c 	pub_eval.c set.c show.c database.h database.c dice.c dice.h 	rollout.c rollout.h copying.c kleinman.c matchequity.c matchequity.h 	analysis.h analysis.c sgf.c sgf.h sgfp.c sgfp.h sgfl.c guile.c         guile.h import.c import.h external.c external.h

COMMON_DEPS = lib/libevent.a

bin_PROGRAMS = gnubg
INCLUDES = $(COMMON_INCS) -I/usr/local/lib/glib/include -I/usr/local/include -I/usr/local/X11R6.4/include
#INCLUDES = $(COMMON_INCS) -I$(srcdir)/ext 
#INCLUDES = $(COMMON_INCS)
gnubg_SOURCES = $(COMMON_SOURCES) gtkboard.c gtkboard.h gtkgame.c gtkgame.h 	gdkgetrgb.c gdkgetrgb.h gtkprefs.c gtkprefs.h gnu.xpm question.xpm 	nextgame.xpm nextmove.xpm prevgame.xpm prevmove.xpm
#gnubg_SOURCES = $(COMMON_SOURCES) xboard.c xboard.h xgame.c xgame.h
#gnubg_SOURCES = $(COMMON_SOURCES)
gnubg_LDADD = -L/usr/local/lib -L/usr/local/X11R6.4/lib -R/usr/local/X11R6.4/lib -lgtk -lgdk -lgmodule -lglib -ldl -lXext -lX11 -lsocket -lnsl -lm $(COMMON_LIBS)
#gnubg_LDADD = -Lext -lext   -lXmu  -lX11 	$(COMMON_LIBS)
#gnubg_LDADD = $(COMMON_LIBS)
gnubg_DEPENDENCIES = $(COMMON_DEPS)
#gnubg_DEPENDENCIES = $(COMMON_DEPS) ext/libext.a
#gnubg_DEPENDENCIES = $(COMMON_DEPS)

pkgdata_DATA = gnubg.bd gnubg.wd gnubg.scm

man_MANS = gnubg.6

noinst_PROGRAMS = makebearoff makeweights

makebearoff_SOURCES = makebearoff.c eval.h eval.c positionid.h positionid.c 	pub_eval.c matchequity.c

makebearoff_LDADD = -Llib -levent
makebearoff_DEPENDENCIES = lib/libevent.a

makeweights_SOURCES = makeweights.c
makeweights_LDADD = -Llib -levent
makeweights_DEPENDENCIES = lib/libevent.a

TESTS = gnubgtest

EXTRA_DIST = userrng.c copying.awk gnubgtest sgf.l sgf.y gnubg.6 gnubg.scm
ACLOCAL_M4 = $(top_srcdir)/aclocal.m4
mkinstalldirs = $(SHELL) $(top_srcdir)/mkinstalldirs
CONFIG_HEADER = config.h
CONFIG_CLEAN_FILES = 
PROGRAMS =  $(bin_PROGRAMS) $(noinst_PROGRAMS)


DEFS = -DHAVE_CONFIG_H -I. -I$(srcdir) -I.
CPPFLAGS = 
LDFLAGS = 
LIBS = -lsocket -ldl -lgdbm -lreadline -ltermcap -lm  -L/usr/local/lib -L/usr/local/X11R6.4/lib -R/usr/local/X11R6.4/lib -lgtk -lgdk -lgmodule -lglib -ldl -lXext -lX11 -lsocket -lnsl -lm
X_CFLAGS = 
X_LIBS = 
X_EXTRA_LIBS = 
X_PRE_LIBS = 
#gnubg_OBJECTS =  gnubg.o getopt.o getopt1.o \
#eval.o play.o positionid.o drawboard.o \
#pub_eval.o set.o show.o database.o dice.o \
#rollout.o copying.o kleinman.o \
#matchequity.o analysis.o sgf.o sgfp.o \
#sgfl.o guile.o import.o external.o \
#xboard.o xgame.o
gnubg_OBJECTS =  gnubg.o getopt.o getopt1.o eval.o play.o \
positionid.o drawboard.o pub_eval.o set.o show.o \
database.o dice.o rollout.o copying.o kleinman.o \
matchequity.o analysis.o sgf.o sgfp.o sgfl.o guile.o \
import.o external.o gtkboard.o gtkgame.o gdkgetrgb.o \
gtkprefs.o
#gnubg_OBJECTS =  gnubg.o getopt.o \
#getopt1.o eval.o play.o positionid.o \
#drawboard.o pub_eval.o set.o show.o \
#database.o dice.o rollout.o copying.o \
#kleinman.o matchequity.o analysis.o sgf.o \
#sgfp.o sgfl.o guile.o import.o external.o
gnubg_LDFLAGS = 
makebearoff_OBJECTS =  makebearoff.o eval.o positionid.o pub_eval.o \
matchequity.o
makebearoff_LDFLAGS = 
makeweights_OBJECTS =  makeweights.o
makeweights_LDFLAGS = 
CFLAGS = -g -O2
COMPILE = $(CC) $(DEFS) $(INCLUDES) $(AM_CPPFLAGS) $(CPPFLAGS) $(AM_CFLAGS) $(CFLAGS)
CCLD = $(CC)
LINK = $(CCLD) $(AM_CFLAGS) $(CFLAGS) $(LDFLAGS) -o $@
man6dir = $(mandir)/man6
MANS = $(man_MANS)

NROFF = nroff
DATA =  $(pkgdata_DATA)

DIST_COMMON =  README ./stamp-h.in AUTHORS COPYING ChangeLog INSTALL \
Makefile.am Makefile.in NEWS TODO acconfig.h acinclude.m4 aclocal.m4 \
config.h.in configure configure.in install-sh missing mkinstalldirs


DISTFILES = $(DIST_COMMON) $(SOURCES) $(HEADERS) $(TEXINFOS) $(EXTRA_DIST)

TAR = gtar
GZIP_ENV = --best
DIST_SUBDIRS =  lib doc ext lib doc
SOURCES = $(gnubg_SOURCES) $(makebearoff_SOURCES) $(makeweights_SOURCES)
OBJECTS = $(gnubg_OBJECTS) $(makebearoff_OBJECTS) $(makeweights_OBJECTS)

all: all-redirect
.SUFFIXES:
.SUFFIXES: .S .c .o .s
$(srcdir)/Makefile.in: Makefile.am $(top_srcdir)/configure.in $(ACLOCAL_M4) 
	cd $(top_srcdir) && $(AUTOMAKE) --gnu --include-deps Makefile

Makefile: $(srcdir)/Makefile.in  $(top_builddir)/config.status
	cd $(top_builddir) \
	  && CONFIG_FILES=$@ CONFIG_HEADERS= $(SHELL) ./config.status

$(ACLOCAL_M4):  configure.in  acinclude.m4
	cd $(srcdir) && $(ACLOCAL)

config.status: $(srcdir)/configure $(CONFIG_STATUS_DEPENDENCIES)
	$(SHELL) ./config.status --recheck
$(srcdir)/configure: $(srcdir)/configure.in $(ACLOCAL_M4) $(CONFIGURE_DEPENDENCIES)
	cd $(srcdir) && $(AUTOCONF)

config.h: stamp-h
	@if test ! -f $@; then \
		rm -f stamp-h; \
		$(MAKE) stamp-h; \
	else :; fi
stamp-h: $(srcdir)/config.h.in $(top_builddir)/config.status
	cd $(top_builddir) \
	  && CONFIG_FILES= CONFIG_HEADERS=config.h \
	     $(SHELL) ./config.status
	@echo timestamp > stamp-h 2> /dev/null
$(srcdir)/config.h.in: $(srcdir)/stamp-h.in
	@if test ! -f $@; then \
		rm -f $(srcdir)/stamp-h.in; \
		$(MAKE) $(srcdir)/stamp-h.in; \
	else :; fi
$(srcdir)/stamp-h.in: $(top_srcdir)/configure.in $(ACLOCAL_M4) acconfig.h
	cd $(top_srcdir) && $(AUTOHEADER)
	@echo timestamp > $(srcdir)/stamp-h.in 2> /dev/null

mostlyclean-hdr:

clean-hdr:

distclean-hdr:
	-rm -f config.h

maintainer-clean-hdr:

mostlyclean-binPROGRAMS:

clean-binPROGRAMS:
	-test -z "$(bin_PROGRAMS)" || rm -f $(bin_PROGRAMS)

distclean-binPROGRAMS:

maintainer-clean-binPROGRAMS:

install-binPROGRAMS: $(bin_PROGRAMS)
	@$(NORMAL_INSTALL)
	$(mkinstalldirs) $(DESTDIR)$(bindir)
	@list='$(bin_PROGRAMS)'; for p in $$list; do \
	  if test -f $$p; then \
	    echo "  $(INSTALL_PROGRAM) $$p $(DESTDIR)$(bindir)/`echo $$p|sed 's/$(EXEEXT)$$//'|sed '$(transform)'|sed 's/$$/$(EXEEXT)/'`"; \
	     $(INSTALL_PROGRAM) $$p $(DESTDIR)$(bindir)/`echo $$p|sed 's/$(EXEEXT)$$//'|sed '$(transform)'|sed 's/$$/$(EXEEXT)/'`; \
	  else :; fi; \
	done

uninstall-binPROGRAMS:
	@$(NORMAL_UNINSTALL)
	list='$(bin_PROGRAMS)'; for p in $$list; do \
	  rm -f $(DESTDIR)$(bindir)/`echo $$p|sed 's/$(EXEEXT)$$//'|sed '$(transform)'|sed 's/$$/$(EXEEXT)/'`; \
	done

mostlyclean-noinstPROGRAMS:

clean-noinstPROGRAMS:
	-test -z "$(noinst_PROGRAMS)" || rm -f $(noinst_PROGRAMS)

distclean-noinstPROGRAMS:

maintainer-clean-noinstPROGRAMS:

.c.o:
	$(COMPILE) -c $<

.s.o:
	$(COMPILE) -c $<

.S.o:
	$(COMPILE) -c $<

mostlyclean-compile:
	-rm -f *.o core *.core

clean-compile:

distclean-compile:
	-rm -f *.tab.c

maintainer-clean-compile:

gnubg: $(gnubg_OBJECTS) $(gnubg_DEPENDENCIES)
	@rm -f gnubg
	$(LINK) $(gnubg_LDFLAGS) $(gnubg_OBJECTS) $(gnubg_LDADD) $(LIBS)

makebearoff: $(makebearoff_OBJECTS) $(makebearoff_DEPENDENCIES)
	@rm -f makebearoff
	$(LINK) $(makebearoff_LDFLAGS) $(makebearoff_OBJECTS) $(makebearoff_LDADD) $(LIBS)

makeweights: $(makeweights_OBJECTS) $(makeweights_DEPENDENCIES)
	@rm -f makeweights
	$(LINK) $(makeweights_LDFLAGS) $(makeweights_OBJECTS) $(makeweights_LDADD) $(LIBS)

install-man6:
	$(mkinstalldirs) $(DESTDIR)$(man6dir)
	@list='$(man6_MANS)'; \
	l2='$(man_MANS)'; for i in $$l2; do \
	  case "$$i" in \
	    *.6*) list="$$list $$i" ;; \
	  esac; \
	done; \
	for i in $$list; do \
	  if test -f $(srcdir)/$$i; then file=$(srcdir)/$$i; \
	  else file=$$i; fi; \
	  ext=`echo $$i | sed -e 's/^.*\\.//'`; \
	  inst=`echo $$i | sed -e 's/\\.[0-9a-z]*$$//'`; \
	  inst=`echo $$inst | sed '$(transform)'`.$$ext; \
	  echo " $(INSTALL_DATA) $$file $(DESTDIR)$(man6dir)/$$inst"; \
	  $(INSTALL_DATA) $$file $(DESTDIR)$(man6dir)/$$inst; \
	done

uninstall-man6:
	@list='$(man6_MANS)'; \
	l2='$(man_MANS)'; for i in $$l2; do \
	  case "$$i" in \
	    *.6*) list="$$list $$i" ;; \
	  esac; \
	done; \
	for i in $$list; do \
	  ext=`echo $$i | sed -e 's/^.*\\.//'`; \
	  inst=`echo $$i | sed -e 's/\\.[0-9a-z]*$$//'`; \
	  inst=`echo $$inst | sed '$(transform)'`.$$ext; \
	  echo " rm -f $(DESTDIR)$(man6dir)/$$inst"; \
	  rm -f $(DESTDIR)$(man6dir)/$$inst; \
	done
install-man: $(MANS)
	@$(NORMAL_INSTALL)
	$(MAKE) $(AM_MAKEFLAGS) install-man6
uninstall-man:
	@$(NORMAL_UNINSTALL)
	$(MAKE) $(AM_MAKEFLAGS) uninstall-man6

install-pkgdataDATA: $(pkgdata_DATA)
	@$(NORMAL_INSTALL)
	$(mkinstalldirs) $(DESTDIR)$(pkgdatadir)
	@list='$(pkgdata_DATA)'; for p in $$list; do \
	  if test -f $(srcdir)/$$p; then \
	    echo " $(INSTALL_DATA) $(srcdir)/$$p $(DESTDIR)$(pkgdatadir)/$$p"; \
	    $(INSTALL_DATA) $(srcdir)/$$p $(DESTDIR)$(pkgdatadir)/$$p; \
	  else if test -f $$p; then \
	    echo " $(INSTALL_DATA) $$p $(DESTDIR)$(pkgdatadir)/$$p"; \
	    $(INSTALL_DATA) $$p $(DESTDIR)$(pkgdatadir)/$$p; \
	  fi; fi; \
	done

uninstall-pkgdataDATA:
	@$(NORMAL_UNINSTALL)
	list='$(pkgdata_DATA)'; for p in $$list; do \
	  rm -f $(DESTDIR)$(pkgdatadir)/$$p; \
	done

# This directory's subdirectories are mostly independent; you can cd
# into them and run `make' without going through this Makefile.
# To change the values of `make' variables: instead of editing Makefiles,
# (1) if the variable is set in `config.status', edit `config.status'
#     (which will cause the Makefiles to be regenerated when you run `make');
# (2) otherwise, pass the desired values on the `make' command line.



all-recursive install-data-recursive install-exec-recursive \
installdirs-recursive install-recursive uninstall-recursive  \
check-recursive installcheck-recursive info-recursive dvi-recursive:
	@set fnord $(MAKEFLAGS); amf=$$2; \
	dot_seen=no; \
	target=`echo $@ | sed s/-recursive//`; \
	list='$(SUBDIRS)'; for subdir in $$list; do \
	  echo "Making $$target in $$subdir"; \
	  if test "$$subdir" = "."; then \
	    dot_seen=yes; \
	    local_target="$$target-am"; \
	  else \
	    local_target="$$target"; \
	  fi; \
	  (cd $$subdir && $(MAKE) $(AM_MAKEFLAGS) $$local_target) \
	   || case "$$amf" in *=*) exit 1;; *k*) fail=yes;; *) exit 1;; esac; \
	done; \
	if test "$$dot_seen" = "no"; then \
	  $(MAKE) $(AM_MAKEFLAGS) "$$target-am" || exit 1; \
	fi; test -z "$$fail"

mostlyclean-recursive clean-recursive distclean-recursive \
maintainer-clean-recursive:
	@set fnord $(MAKEFLAGS); amf=$$2; \
	dot_seen=no; \
	rev=''; list='$(SUBDIRS)'; for subdir in $$list; do \
	  rev="$$subdir $$rev"; \
	  test "$$subdir" = "." && dot_seen=yes; \
	done; \
	test "$$dot_seen" = "no" && rev=". $$rev"; \
	target=`echo $@ | sed s/-recursive//`; \
	for subdir in $$rev; do \
	  echo "Making $$target in $$subdir"; \
	  if test "$$subdir" = "."; then \
	    local_target="$$target-am"; \
	  else \
	    local_target="$$target"; \
	  fi; \
	  (cd $$subdir && $(MAKE) $(AM_MAKEFLAGS) $$local_target) \
	   || case "$$amf" in *=*) exit 1;; *k*) fail=yes;; *) exit 1;; esac; \
	done && test -z "$$fail"
tags-recursive:
	list='$(SUBDIRS)'; for subdir in $$list; do \
	  test "$$subdir" = . || (cd $$subdir && $(MAKE) $(AM_MAKEFLAGS) tags); \
	done

tags: TAGS

ID: $(HEADERS) $(SOURCES) $(LISP)
	list='$(SOURCES) $(HEADERS)'; \
	unique=`for i in $$list; do echo $$i; done | \
	  awk '    { files[$$0] = 1; } \
	       END { for (i in files) print i; }'`; \
	here=`pwd` && cd $(srcdir) \
	  && mkid -f$$here/ID $$unique $(LISP)

TAGS: tags-recursive $(HEADERS) $(SOURCES) config.h.in $(TAGS_DEPENDENCIES) $(LISP)
	tags=; \
	here=`pwd`; \
	list='$(SUBDIRS)'; for subdir in $$list; do \
   if test "$$subdir" = .; then :; else \
	    test -f $$subdir/TAGS && tags="$$tags -i $$here/$$subdir/TAGS"; \
   fi; \
	done; \
	list='$(SOURCES) $(HEADERS)'; \
	unique=`for i in $$list; do echo $$i; done | \
	  awk '    { files[$$0] = 1; } \
	       END { for (i in files) print i; }'`; \
	test -z "$(ETAGS_ARGS)config.h.in$$unique$(LISP)$$tags" \
	  || (cd $(srcdir) && etags $(ETAGS_ARGS) $$tags config.h.in $$unique $(LISP) -o $$here/TAGS)

mostlyclean-tags:

clean-tags:

distclean-tags:
	-rm -f TAGS ID

maintainer-clean-tags:

distdir = $(PACKAGE)-$(VERSION)
top_distdir = $(distdir)

# This target untars the dist file and tries a VPATH configuration.  Then
# it guarantees that the distribution is self-contained by making another
# tarfile.
distcheck: dist
	-rm -rf $(distdir)
	GZIP=$(GZIP_ENV) $(TAR) zxf $(distdir).tar.gz
	mkdir $(distdir)/=build
	mkdir $(distdir)/=inst
	dc_install_base=`cd $(distdir)/=inst && pwd`; \	$(MAKE) $(AM_MAKEFLAGS) distcheck-hook
	cd $(distdir)/=build \
	  && ../configure --srcdir=.. --prefix=$$dc_install_base \
	  && $(MAKE) $(AM_MAKEFLAGS) \
	  && $(MAKE) $(AM_MAKEFLAGS) dvi \
	  && $(MAKE) $(AM_MAKEFLAGS) check \
	  && $(MAKE) $(AM_MAKEFLAGS) install \
	  && $(MAKE) $(AM_MAKEFLAGS) installcheck \
	  && $(MAKE) $(AM_MAKEFLAGS) dist
	-rm -rf $(distdir)
	@banner="$(distdir).tar.gz is ready for distribution"; \
	dashes=`echo "$$banner" | sed s/./=/g`; \
	echo "$$dashes"; \
	echo "$$banner"; \
	echo "$$dashes"
dist: distdir
	-chmod -R a+r $(distdir)
	GZIP=$(GZIP_ENV) $(TAR) chozf $(distdir).tar.gz $(distdir)
	-rm -rf $(distdir)
dist-all: distdir
	-chmod -R a+r $(distdir)
	GZIP=$(GZIP_ENV) $(TAR) chozf $(distdir).tar.gz $(distdir)
	-rm -rf $(distdir)
distdir: $(DISTFILES)
	-rm -rf $(distdir)
	mkdir $(distdir)
	-chmod 777 $(distdir)
	@for file in $(DISTFILES); do \
	  d=$(srcdir); \
	  if test -d $$d/$$file; then \
	    cp -pr $$d/$$file $(distdir)/$$file; \
	  else \
	    test -f $(distdir)/$$file \
	    || ln $$d/$$file $(distdir)/$$file 2> /dev/null \
	    || cp -p $$d/$$file $(distdir)/$$file || :; \
	  fi; \
	done
	for subdir in $(DIST_SUBDIRS); do \
	  if test "$$subdir" = .; then :; else \
	    test -d $(distdir)/$$subdir \
	    || mkdir $(distdir)/$$subdir \
	    || exit 1; \
	    chmod 777 $(distdir)/$$subdir; \
	    (cd $$subdir && $(MAKE) $(AM_MAKEFLAGS) top_distdir=../$(distdir) distdir=../$(distdir)/$$subdir distdir) \
	      || exit 1; \
	  fi; \
	done
analysis.o: analysis.c config.h backgammon.h lib/list.h eval.h \
	drawboard.h positionid.h analysis.h
copying.o: copying.c
database.o: database.c config.h backgammon.h lib/list.h eval.h dice.h \
	database.h positionid.h rollout.h
dice.o: dice.c config.h getopt.h backgammon.h lib/list.h eval.h dice.h \
	lib/md5.h lib/mt19937int.h lib/isaac.h lib/isaacs.h gtkgame.h
drawboard.o: drawboard.c config.h drawboard.h positionid.h
eval.o: eval.c config.h lib/cache.h lib/neuralnet.h getopt.h eval.h \
	positionid.h matchequity.h
external.o: external.c config.h getopt.h backgammon.h lib/list.h eval.h \
	drawboard.h external.h
gdkgetrgb.o: gdkgetrgb.c gdkgetrgb.h
getopt1.o: getopt1.c config.h getopt.h
getopt.o: getopt.c config.h
gnubg.o: gnubg.c config.h getopt.h backgammon.h lib/list.h eval.h dice.h \
	drawboard.h positionid.h rollout.h matchequity.h analysis.h \
	import.h guile.h gtkboard.h gtkgame.h gtkprefs.h
gtkboard.o: gtkboard.c config.h lib/isaac.h lib/isaacs.h backgammon.h \
	lib/list.h eval.h drawboard.h gdkgetrgb.h gtkboard.h gtkprefs.h \
	positionid.h
gtkgame.o: gtkgame.c config.h getopt.h backgammon.h lib/list.h eval.h \
	dice.h drawboard.h gtkboard.h gtkgame.h gtkprefs.h \
	matchequity.h positionid.h prevgame.xpm prevmove.xpm \
	nextmove.xpm nextgame.xpm gnu.xpm question.xpm
gtkprefs.o: gtkprefs.c config.h backgammon.h lib/list.h eval.h \
	gtkboard.h gtkgame.h gtkprefs.h
guile.o: guile.c config.h getopt.h backgammon.h lib/list.h eval.h \
	guile.h positionid.h rollout.h
import.o: import.c config.h backgammon.h lib/list.h eval.h import.h
kleinman.o: kleinman.c
makebearoff.o: makebearoff.c config.h eval.h positionid.h
makeweights.o: makeweights.c config.h lib/neuralnet.h getopt.h eval.h
matchequity.o: matchequity.c matchequity.h eval.h
play.o: play.c config.h getopt.h backgammon.h lib/list.h eval.h dice.h \
	drawboard.h external.h positionid.h matchequity.h gtkgame.h
positionid.o: positionid.c positionid.h
pub_eval.o: pub_eval.c
rollout.o: rollout.c config.h backgammon.h lib/list.h eval.h dice.h \
	gtkgame.h positionid.h rollout.h
set.o: set.c config.h getopt.h backgammon.h lib/list.h eval.h dice.h \
	gtkprefs.h gtkboard.h matchequity.h positionid.h
sgfl.o: sgfl.c lib/list.h sgf.h sgfp.h
sgf.o: sgf.c config.h backgammon.h lib/list.h eval.h positionid.h sgf.h
sgfp.o: sgfp.c lib/list.h sgf.h
show.o: show.c config.h getopt.h backgammon.h lib/list.h eval.h \
	drawboard.h dice.h matchequity.h gtkboard.h gtkgame.h

check-TESTS: $(TESTS)
	@failed=0; all=0; \
	srcdir=$(srcdir); export srcdir; \
	for tst in $(TESTS); do \
	  if test -f $$tst; then dir=.; \
	  else dir="$(srcdir)"; fi; \
	  if $(TESTS_ENVIRONMENT) $$dir/$$tst; then \
	    all=`expr $$all + 1`; \
	    echo "PASS: $$tst"; \
	  elif test $$? -ne 77; then \
	    all=`expr $$all + 1`; \
	    failed=`expr $$failed + 1`; \
	    echo "FAIL: $$tst"; \
	  fi; \
	done; \
	if test "$$failed" -eq 0; then \
	  banner="All $$all tests passed"; \
	else \
	  banner="$$failed of $$all tests failed"; \
	fi; \
	dashes=`echo "$$banner" | sed s/./=/g`; \
	echo "$$dashes"; \
	echo "$$banner"; \
	echo "$$dashes"; \
	test "$$failed" -eq 0
info-am:
info: info-recursive
dvi-am:
dvi: dvi-recursive
check-am: all-am
	$(MAKE) $(AM_MAKEFLAGS) check-TESTS
check: check-recursive
installcheck-am:
installcheck: installcheck-recursive
all-recursive-am: config.h
	$(MAKE) $(AM_MAKEFLAGS) all-recursive

install-exec-am: install-binPROGRAMS
install-exec: install-exec-recursive

install-data-am: install-man install-pkgdataDATA
install-data: install-data-recursive

install-am: all-am
	@$(MAKE) $(AM_MAKEFLAGS) install-exec-am install-data-am
install: install-recursive
uninstall-am: uninstall-binPROGRAMS uninstall-man uninstall-pkgdataDATA
uninstall: uninstall-recursive
all-am: Makefile $(PROGRAMS) $(MANS) $(DATA) config.h
all-redirect: all-recursive-am
install-strip:
	$(MAKE) $(AM_MAKEFLAGS) AM_INSTALL_PROGRAM_FLAGS=-s install
installdirs: installdirs-recursive
installdirs-am:
	$(mkinstalldirs)  $(DESTDIR)$(bindir) $(DESTDIR)$(mandir)/man6 \
		$(DESTDIR)$(pkgdatadir)


mostlyclean-generic:

clean-generic:

distclean-generic:
	-rm -f Makefile $(CONFIG_CLEAN_FILES)
	-rm -f config.cache config.log stamp-h stamp-h[0-9]*

maintainer-clean-generic:
mostlyclean-am:  mostlyclean-hdr mostlyclean-binPROGRAMS \
		mostlyclean-noinstPROGRAMS mostlyclean-compile \
		mostlyclean-tags mostlyclean-generic

mostlyclean: mostlyclean-recursive

clean-am:  clean-hdr clean-binPROGRAMS clean-noinstPROGRAMS \
		clean-compile clean-tags clean-generic mostlyclean-am

clean: clean-recursive

distclean-am:  distclean-hdr distclean-binPROGRAMS \
		distclean-noinstPROGRAMS distclean-compile \
		distclean-tags distclean-generic clean-am

distclean: distclean-recursive
	-rm -f config.status

maintainer-clean-am:  maintainer-clean-hdr maintainer-clean-binPROGRAMS \
		maintainer-clean-noinstPROGRAMS \
		maintainer-clean-compile maintainer-clean-tags \
		maintainer-clean-generic distclean-am
	@echo "This command is intended for maintainers to use;"
	@echo "it deletes files that may require special tools to rebuild."

maintainer-clean: maintainer-clean-recursive
	-rm -f config.status

.PHONY: mostlyclean-hdr distclean-hdr clean-hdr maintainer-clean-hdr \
mostlyclean-binPROGRAMS distclean-binPROGRAMS clean-binPROGRAMS \
maintainer-clean-binPROGRAMS uninstall-binPROGRAMS install-binPROGRAMS \
mostlyclean-noinstPROGRAMS distclean-noinstPROGRAMS \
clean-noinstPROGRAMS maintainer-clean-noinstPROGRAMS \
mostlyclean-compile distclean-compile clean-compile \
maintainer-clean-compile install-man6 uninstall-man6 install-man \
uninstall-man uninstall-pkgdataDATA install-pkgdataDATA \
install-data-recursive uninstall-data-recursive install-exec-recursive \
uninstall-exec-recursive installdirs-recursive uninstalldirs-recursive \
all-recursive check-recursive installcheck-recursive info-recursive \
dvi-recursive mostlyclean-recursive distclean-recursive clean-recursive \
maintainer-clean-recursive tags tags-recursive mostlyclean-tags \
distclean-tags clean-tags maintainer-clean-tags distdir check-TESTS \
info-am info dvi-am dvi check check-am installcheck-am installcheck \
all-recursive-am install-exec-am install-exec install-data-am \
install-data install-am install uninstall-am uninstall all-redirect \
all-am all installdirs-am installdirs mostlyclean-generic \
distclean-generic clean-generic maintainer-clean-generic clean \
mostlyclean distclean maintainer-clean

distcheck-hook:
	-cp $(srcdir)/gnubg.bd $(srcdir)/gnubg.weights $(distdir)/

sgfp.h sgfp.c: sgf.y
	$(BISON) -o $@ -p sgf -d $<

sgfl.c: sgf.l
	$(FLEX) -o$@ -Psgf $<

copying.c: COPYING copying.awk
	$(AWK) -f $(srcdir)/copying.awk < $< > $@

gnubg.bd:
	@[ -s $@ ] || if [ -s $(srcdir)/gnubg.bd ]; then \
	$(LN_S) $(srcdir)/gnubg.bd $@; else $(MAKE) bd.message; fi

bd.message:
	@echo ' ** NOTE: For full strength in bearoff moves, GNU'
	@echo ' ** Backgammon requires a "gnubg.bd" file containing a'
	@echo ' ** database of endgame positions.  See the README'
	@echo ' ** file for details.'

#bearoff-database: makebearoff
#	@echo ' ** NOTE: Since you are cross-compiling GNU Backgammon,'
#	@echo ' ** it is not possible to generate the bearoff database'
#	@echo ' ** on the build system.  To create this file manually,'
#	@echo ' ** use a command like:'
#	@echo ' **   makebearoff > gnubg.bd'
#	@echo ' ** on the host system.'
bearoff-database: makebearoff
	./makebearoff > $(srcdir)/gnubg.bd; $(MAKE) gnubg.bd

.PHONY: bd.message bearoff-database

weights.message:
	@echo ' ** NOTE: For proper operation, GNU Backgammon requires'
	@echo ' ** a "gnubg.weights" file containing neural net'
	@echo ' ** parameters.  See the README file for details.'

.PHONY: weights.message

gnubg.weights:
	@[ -s $(srcdir)/gnubg.weights ] || $(MAKE) weights.message

#gnubg.wd: gnubg.weights makeweights
#	@echo ' ** NOTE: Since you are cross-compiling GNU Backgammon,'
#	@echo ' ** it is not possible to generate the gnubg.wd file'
#	@echo ' ** on the build system.  To create this file manually,'
#	@echo ' ** use a command like:'
#	@echo ' **   makeweights < gnubg.weights > gnubg.wd'
#	@echo ' ** on the host system.'
gnubg.wd: gnubg.weights makeweights
	-./makeweights < $< > $@

.DELETE_ON_ERROR:

# Tell versions [3.59,3.63) of GNU make to not export all variables.
# Otherwise a system limit (for SysV at least) may be exceeded.
.NOEXPORT:
