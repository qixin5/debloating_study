# Generated automatically from Makefile.in by configure.
# This Makefile is for the Bash/documentation directory -*- text -*-.
#
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

#
SHELL = /bin/sh
RM	    = rm -f

topdir = ..
srcdir = .
VPATH = .:.

prefix = /usr/local
exec_prefix = /home/qxin6/debaug_expt/debaug/working/bash/source

infodir = /home/qxin6/debaug_expt/debaug/working/bash/source/info

# set this to a directory name to have the HTML files installed
htmldir = 

mandir = /home/qxin6/debaug_expt/debaug/working/bash/source/man
manpfx = man

man1ext = 1
man1dir = $(mandir)/$(manpfx)$(man1ext)
man3ext = 3
man3dir = $(mandir)/$(manpfx)$(man3ext) 

INSTALL = /usr/bin/install -c
INSTALL_DATA = ${INSTALL} -m 644
BUILD_DIR = /home/qxin6/debaug_expt/debaug/working/bash/source

# bad style
RL_LIBDIR = $(topdir)/lib/readline

# unused
TEXINDEX    = texindex
TEX	    = tex

MAKEINFO    = makeinfo
TEXI2DVI    = ${topdir}/support/texi2dvi
TEXI2HTML   = ${topdir}/support/texi2html
MAN2HTML    = ${BUILD_DIR}/support/man2html
HTMLPOST    = ${srcdir}/htmlpost.sh
QUIETPS	    = #set this to -q to shut up dvips
PAPERSIZE   = letter	# change to a4 for A4-size paper
PSDPI       = 300	# could be 600 if you like
DVIPS	    = dvips -D ${PSDPI} $(QUIETPS) -t ${PAPERSIZE} -o $@	# tricky
TEXINPUTDIR = $(RL_LIBDIR)/doc

MKDIRS      = ${topdir}/support/mkdirs

# This should be a program that converts troff to an ascii-readable format
NROFF	    = groff -Tascii

# This should be a program that converts troff to postscript
GROFF	    = groff

HSUSER      = $(RL_LIBDIR)/doc/hsuser.texinfo
RLUSER      = $(RL_LIBDIR)/doc/rluser.texinfo

.SUFFIXES:	.0 .1 .3 .ms .ps .txt .dvi .html

.1.ps:
	$(RM) $@
	-${GROFF} -man $< > $@

.1.0:
	$(RM) $@
	-${NROFF} -man $< > $@

.1.html:
	$(RM) $@
	-${MAN2HTML} $< | ${HTMLPOST} > $@

.ms.ps:
	$(RM) $@
	-${GROFF} -ms $< > $@

.ms.txt:
	$(RM) $@
	-${NROFF} -ms $< > $@

.3.ps:
	$(RM) $@
	-${GROFF} -man $< > $@

.3.0:
	$(RM) $@
	-${NROFF} -man $< > $@

.3.html:
	$(RM) $@
	-${MAN2HTML} $< > $@

all: ps info dvi text html
nodvi: ps info text html

PSFILES = bash.ps bashbug.ps article.ps builtins.ps rbash.ps
DVIFILES = bashref.dvi bashref.ps
INFOFILES = bashref.info
MAN0FILES = bash.0 bashbug.0 builtins.0 rbash.0
HTMLFILES = bashref.html bash.html

ps: ${PSFILES}
dvi: ${DVIFILES}
info: ${INFOFILES}
text: ${MAN0FILES}
html: ${HTMLFILES}

bashref.dvi: $(srcdir)/bashref.texi $(HSUSER) $(RLUSER)
	TEXINPUTS=.:$(TEXINPUTDIR):$$TEXINPUTS $(TEXI2DVI) $(srcdir)/bashref.texi

bashref.ps: bashref.dvi
	$(RM) $@
	$(DVIPS) bashref.dvi

bashref.info: $(srcdir)/bashref.texi $(HSUSER) $(RLUSER)
	$(MAKEINFO) --no-split -I$(TEXINPUTDIR) $(srcdir)/bashref.texi

bashref.html: bashref.texi $(HSUSER) $(RLUSER)
	$(TEXI2HTML) -menu -monolithic -I $(TEXINPUTDIR) $(srcdir)/bashref.texi

new-bashref.dvi: $(srcdir)/new-bashref.texi $(HSUSER) $(RLUSER)
	TEXINPUTS=.:$(TEXINPUTDIR):$$TEXINPUTS $(TEXI2DVI) $(srcdir)/new-bashref.texi

new-bashref.ps: new-bashref.dvi
	$(RM) $@
	$(DVIPS) new-bashref.dvi

new-bashref.info: $(srcdir)/new-bashref.texi $(HSUSER) $(RLUSER)
	$(MAKEINFO) --no-split -I$(TEXINPUTDIR) $(srcdir)/new-bashref.texi

bash.dvi: bash.texinfo $(HSUSER) $(RLUSER)
	TEXINPUTS=.:$(TEXINPUTDIR):$$TEXINPUTS $(TEXI2DVI) bash.texinfo

bashman.ps: bash.dvi
	$(RM) $@
	$(DVIPS) bash.dvi

bash.txt: bash.1
bash.ps: bash.1
bash.html: bash.1 $(MAN2HTML)
bashbug.ps: bashbug.1
builtins.ps: builtins.1 bash.1
rbash.ps: rbash.1 bash.1
bash.0: bash.1
bashbug.0: bashbug.1
builtins.0: builtins.1 bash.1
rbash.0: rbash.1 bash.1
article.ps: article.ms

$(MAN2HTML):	${topdir}/support/man2html.c
	-( cd ${BUILD_DIR}/support ; ${MAKE} ${MFLAGS} man2html)

CREATED_FAQ = faq.news faq.news2 faq.mail faq.version

faq:	${CREATED_FAQ}

faq.version:	FAQ.version FAQ
	sh mkfaqvers FAQ.version > $@

faq.headers.mail: FAQ.headers.mail FAQ
	sh mkfaqvers FAQ.headers.mail > $@

faq.headers.news: FAQ.headers.news FAQ
	sh mkfaqvers FAQ.headers.news > $@

faq.headers.news2: FAQ.headers.news2 FAQ
	sh mkfaqvers FAQ.headers.news2 > $@

faq.news: FAQ faq.headers.news faq.version
	$(RM) $@
	cat faq.headers.news faq.version FAQ > $@

faq.news2: FAQ faq.headers.news2 faq.version
	$(RM) $@
	cat faq.headers.news2 faq.version FAQ > $@

faq.mail: FAQ faq.headers.mail faq.version
	$(RM) $@
	cat faq.headers.mail faq.version FAQ > $@

clean:
	$(RM) *.aux *.bak *.cp *.fn *.ky *.log *.pg *.toc *.tp *.vr *.cps \
		*.pgs *.bt *.bts *.rw *.rws *.fns *.kys *.tps *.vrs *.o
	${RM} core *.core

distclean mostlyclean: clean
	$(RM) Makefile

maintainer-clean:	clean
	${RM} ${PSFILES} ${DVIFILES} ${INFOFILES} ${MAN0FILES} ${HTMLFILES}
	${RM} ${CREATED_FAQ}
	$(RM) Makefile

installdirs:
	-test -d $(man1dir) || $(SHELL) ${MKDIRS} $(man1dir)
	-test -d $(infodir) || $(SHELL) ${MKDIRS} $(infodir)
	-if [ -n "$(htmldir)" ]; then \
		test -d $(htmldir) || $(SHELL) ${MKDIRS} $(htmldir) ; \
	fi
	
install: info installdirs
	-$(INSTALL_DATA) $(srcdir)/bash.1 $(man1dir)/bash.${man1ext}
	-$(INSTALL_DATA) $(srcdir)/bashbug.1 $(man1dir)/bashbug.${man1ext}
# uncomment the next line to install the builtins man page
#	$(INSTALL_DATA) $(srcdir)/builtins.1 $(man1dir)/bash_builtins.${man1ext}
	-$(INSTALL_DATA) $(srcdir)/bashref.info $(infodir)/bash.info
# run install-info if it is present to update the info directory
	if $(SHELL) -c 'install-info --version' >/dev/null 2>&1; then \
		install-info --dir-file=$(infodir)/dir $(infodir)/bash.info; \
	else true; fi
# if htmldir is set, install the html files into that directory
	-if [ -n "${htmldir}" ]; then \
		$(INSTALL_DATA) $(srcdir)/bash.html $(htmldir) ; \
		$(INSTALL_DATA) $(srcdir)/bashref.html $(htmldir) ; \
	fi

uninstall:
	-$(RM) $(man1dir)/bash.${man1ext} $(man1dir)/bashbug.${man1ext}
	$(RM) $(infodir)/bash.info
	-if [ -n "$(htmldir)" ]; then \
		$(RM) $(htmldir)/bash.html ; \
		$(RM) $(htmldir)/bashref.html ; \
	fi

# for use by chet
inst:	bashref.texi
	$(SHELL) ./mkinstall
	cmp -s INSTALL ../INSTALL || mv INSTALL ../INSTALL
	$(RM) INSTALL

posix:	bashref.texi
	$(SHELL) ./mkposix
	cmp -s POSIX.NOTES ../CWRU/POSIX.NOTES || mv POSIX.NOTES ../CWRU/POSIX.NOTES
	$(RM) POSIX.NOTES

xdist: inst posix
