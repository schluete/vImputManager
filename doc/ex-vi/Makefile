#
# This code contains changes by
#      Gunnar Ritter, Freiburg i. Br., Germany, 2002. All rights reserved.
#
# Conditions 1, 2, and 4 and the no-warranty notice below apply
# to these changes.
#
#
# Copyright (c) 1980, 1993
# 	The Regents of the University of California.  All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 3. All advertising materials mentioning features or use of this software
#    must display the following acknowledgement:
# 	This product includes software developed by the University of
# 	California, Berkeley and its contributors.
# 4. Neither the name of the University nor the names of its contributors
#    may be used to endorse or promote products derived from this software
#    without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
#
#
# Copyright(C) Caldera International Inc. 2001-2002. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#   Redistributions of source code and documentation must retain the
#    above copyright notice, this list of conditions and the following
#    disclaimer.
#   Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#   All advertising materials mentioning features or use of this software
#    must display the following acknowledgement:
#      This product includes software developed or owned by Caldera
#      International, Inc.
#   Neither the name of Caldera International, Inc. nor the names of
#    other contributors may be used to endorse or promote products
#    derived from this software without specific prior written permission.
#
# USE OF THE SOFTWARE PROVIDED FOR UNDER THIS LICENSE BY CALDERA
# INTERNATIONAL, INC. AND CONTRIBUTORS ``AS IS'' AND ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL CALDERA INTERNATIONAL, INC. BE
# LIABLE FOR ANY DIRECT, INDIRECT INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
# BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
# OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
# EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
#	from Makefile	7.13.1.3 (2.11BSD GTE) 1996/10/23
#
#	@(#)Makefile	1.51 (gritter) 2/25/07
#

#
# Destinations for installation. $(PRESERVEDIR) is used for recovery files.
# It will get mode 1777.
#
PREFIX		= /usr/local
BINDIR		= $(PREFIX)/bin
LIBEXECDIR	= $(PREFIX)/libexec
MANDIR		= $(PREFIX)/share/man
PRESERVEDIR	= /var/preserve

#
# DESTDIR is prepended to the installation paths. It is mostly useful
# for package building and should be left empty otherwise.
#
DESTDIR		=

#
# A BSD-like install program. GNU install will fit well here, too.
#
INSTALL		= /usr/ucb/install

#
# Compiler and linker flags.
#
# On HP-UX, add -D_INCLUDE__STDC_A1_SOURCE to CPPFLAGS.
#
#CFLAGS	=
#CPPFLAGS =
#LDFLAGS	=
#LDADD	=

#
# All of the following settings are quite recommended, so you should only
# change them if it becomes really necessary.
#
# Remove -DMB to build without multibyte character support. This will be
#     necessary if the compiler complains about a missing wchar.h, wctype.h,
#     mbtowc(), mbrtowc(), btowc(), wcwidth() etc. You will likely also have
#     to use the old regular expression code in these cases (see below).
# Remove -DBIT8 to get a 7bit-only ex. This setting is mostly provided for
#     testing the internationalization code against the older version and
#     should not normally be removed.
# Add -DNO_BE_BACKSLASH to make backslash a regular character inside RE
#     bracket expressions. This is required for POSIX conformance but
#     conflicts with historical practice for ex.
#
# Some historic comments:
#
# Ex is very large - this version will not fit on PDP-11's without overlay
# software.  Things that can be turned off to save
# space include LISPCODE (-l flag, showmatch and lisp options), CHDIR (the 
# previously undocumented chdir command.)
#
# If your system expands tabs to 4 spaces you should -DTABS=4 below
#
FEATURES	= -DLISPCODE -DCHDIR -DFASTTAG -DUCVISUAL -DMB -DBIT8

#
# This disables the LC_CTYPE locale settings and assumes all characters
# upwards from octal 0240 are printable ones, like in ISO 8859-1. It
# should only be used if the system's locales are broken. It cannot be
# used in combination with -DMB.
#
#CHARSET	= -DISO8859_1

#
# If you want LC_MESSAGES support using catgets(), define this. To make
# any practical use of it, you also have to create a message catalogue,
# put it in a proper location and change UNKNOWN to its name. See your
# system's documentation on "gencat" or on language support in general
# for further information. This setting is not interesting at the current
# time unless you want to contribute internationalized message catalogues.
#
#LANGMSG		= -DLANGMSG -DCATNAME='"UNKNOWN"'

#
# For POSIX regular expressions, e.g. the star applied to subexpressions
# as in \(ab\)* and localized regular expressions like [:class:], [.c.],
# and [=c=], you need Caldera's 'UNIX(R) Regular Expression Library' or
# the included derivative of it.
#
# Comment out the three following lines if you do not have it or if it
# does not compile; it needs some advanced multibyte character support
# (wchar.h, wctype.h, btowc() etc.) which is not provided by older
# compilation environments.
#
REINC	= -I./libuxre -DUXRE
RELIB	= -L./libuxre -luxre
RETGT	= uxre

#
# VMUNIX should be correct for any modern Unix.
#
# Historic comments:
#
# VMUNIX makes ex considerably larger, raising 
# many limits and improving speed and simplicity of maintenance.  It is 
# suitable only for a VAX or other large machine, and then probably only in 
# a paged system.
#
# Don't define VFORK unless your system has the VFORK system call,
# which is like fork but the two processes have only one data space until the
# child execs. This speeds up ex by saving the memory copy.
#
#      Note by Gunnar Ritter: vfork() is unreliable and one of the worst
#      hacks in Unix history. Do not define VFORK unless you have a
#      special good reason for that.
#
OSTYPE	= -DVMUNIX

#
# On VMUNIX systems, ex can normally edit files up to 32 MB of size. LARGEF
# raises this limit to around 1 GB, but ex will consume much more of core
# and temp file space then.
#
#LARGEF	= -DLARGEF

# 
# The next setting is a crucial one since it determines the way ex
# gets its knowledge about the terminal's capabilities. If you get
# weird results, try using another library here. Uncomment exactly
# one entry.
#
# On System V, the terminfo library may be more accurate than the termcap
# file. To use it, link against the curses library.
#
#TERMLIB	= curses
#
# You may also get terminfo access by using the ncurses library.
#
#TERMLIB	= ncurses
#
# The preferred choice for ex on Linux distributions, other systems that
# provide a good termcap file, or when setting the TERMCAP environment
# variable is deemed sufficient, is the included 2.11BSD termcap library.
#
TERMLIB	= termlib

#
# Since ex uses sbrk() internally, a conflict with the libc's version of
# malloc() must be avoided. There are two ways to work around this problem.
# The first is to allocate a static pool for all malloc purposes. This will
# work on any kind of system.
#
#MALLOC=malloc.o
#
# If mmap() can be used to allocate anonymous memory, this is the preferred
# choice as it allows to grow memory dynamically as it is needed. This will
# usually work unless you are compiling for a vector machine or another
# unusual enviroment.
MALLOC=mapmalloc.o

###############################################################################
#                                                                             #
# That's it. You do not normally need to change anything below here.          #
#                                                                             #
###############################################################################

#WARN	= -Wall -Wno-parentheses -Werror

STRIP = -s
RECOVER	= -DEXRECOVER=\"$(LIBEXECDIR)/exrecover\" \
			-DEXPRESERVE=\"$(LIBEXECDIR)/expreserve\"
CCFLAGS	= $(CFLAGS) $(WARN) $(CPPFLAGS) $(FEATURES) $(CHARSET) $(OSTYPE) \
		$(LARGEF) $(RECOVER) $(LANGMSG) $(REINC) $(RPMCFLAGS)
TLIB	= libterm/libtermlib.a
INCLUDE	= /usr/include
OBJS	= ex.o ex_addr.o ex_cmds.o ex_cmds2.o ex_cmdsub.o \
		ex_data.o ex_extern.o ex_get.o ex_io.o ex_put.o ex_re.o \
		ex_set.o ex_subr.o ex_tagio.o ex_temp.o ex_tty.o ex_unix.o \
		ex_v.o ex_vadj.o ex_vget.o ex_vmain.o ex_voper.o \
		ex_vops.o ex_vops2.o ex_vops3.o ex_vput.o ex_vwind.o \
		printf.o ex_version.o $(MALLOC)
HDRS	= ex.h ex_argv.h ex_re.h ex_temp.h ex_tty.h ex_tune.h ex_vars.h \
		ex_vis.h libterm/libterm.h
SRC1	= ex.c ex_addr.c ex_cmds.c ex_cmds2.c ex_cmdsub.c
SRC2	= ex_data.c ex_get.c ex_io.c ex_put.c ex_re.c
SRC3	= ex_set.c ex_subr.c ex_tagio.c ex_temp.c ex_tty.c ex_unix.c
SRC4	= ex_v.c ex_vadj.c ex_vget.c ex_vmain.c ex_voper.c
SRC5	= ex_vops.c ex_vops2.c ex_vops3.c ex_vput.c ex_vwind.c
SRC6	= printf.c expreserve.c exrecover.c ex_version.c
SRC7	= mapmalloc.c malloc.c

.SUFFIXES: .o .c
.c.o: ; $(CC) $(CCFLAGS) -c $<

all: $(RETGT) exrecover expreserve ex

ex: $(TLIB) $(OBJS)
	$(CC) -o ex $(LDFLAGS) $(OBJS) $(LDADD) -Llibterm -l$(TERMLIB) $(RELIB)
	size ex

$(TLIB): libterm/termcap.c libterm/tgoto.c libterm/tputs.c libterm/libterm.h
	@cd libterm && $(MAKE) CC="$(CC)" \
		COPT="$(CFLAGS) $(WARN) $(CPPFLAGS) $(OSTYPE)"

exrecover: exrecover.o $(MALLOC)
	$(CC) -o exrecover $(LDFLAGS) exrecover.o $(MALLOC) $(LDADD)

expreserve: expreserve.o
	$(CC) -o expreserve $(LDFLAGS) expreserve.o $(LDADD)

ex_vars.h: ex_data.c
	sh makeoptions $(CCFLAGS)

uxre:
	@cd libuxre && $(MAKE) CC="$(CC)" \
		COPT="$(CFLAGS) $(WARN) $(CPPFLAGS) $(OSTYPE)"

clean:
	@cd libterm && $(MAKE) clean
	@test ! -d libuxre || (cd libuxre && $(MAKE) clean)
#	If we dont have ex we cant make it so don't rm ex_vars.h
	-rm -f ex exrecover expreserve *.o x*.[cs] core errs trace

mrproper: clean
	-rm -f log

# install in standard place

install-man:
	test -d $(DESTDIR)$(PREFIX) || mkdir -p $(DESTDIR)$(PREFIX)
	test -d $(DESTDIR)$(MANDIR) || mkdir -p $(DESTDIR)$(MANDIR)
	test -d $(DESTDIR)$(MANDIR)/man1 || mkdir -p $(DESTDIR)$(MANDIR)/man1
	rm -f $(DESTDIR)$(MANDIR)/man1/ex.1 $(DESTDIR)$(MANDIR)/man1/edit.1 \
		$(DESTDIR)$(MANDIR)/man1/vedit.1 \
		$(DESTDIR)$(MANDIR)/man1/vi.1 \
		$(DESTDIR)$(MANDIR)/man1/view.1
	$(INSTALL) -c -m 644 ex.1 $(DESTDIR)$(MANDIR)/man1/ex.1
	$(INSTALL) -c -m 644 vi.1 $(DESTDIR)$(MANDIR)/man1/vi.1
	ln -s ex.1 $(DESTDIR)$(MANDIR)/man1/edit.1
	ln -s vi.1 $(DESTDIR)$(MANDIR)/man1/vedit.1
	ln -s vi.1 $(DESTDIR)$(MANDIR)/man1/view.1

install: all install-man
	rm -f $(DESTDIR)$(BINDIR)/ex $(DESTDIR)$(BINDIR)/edit \
		$(DESTDIR)$(BINDIR)/vedit $(DESTDIR)$(BINDIR)/vi \
		$(DESTDIR)$(BINDIR)/view
	test -d $(DESTDIR)$(BINDIR) || mkdir -p $(DESTDIR)$(BINDIR)
# special provisions for sticky install
	if test -f $(DESTDIR)$(BINDIR)/ex; \
	then	test -f $(DESTDIR)$(BINDIR)/ex.old.$$$$ && exit 1; \
		chmod 755 $(DESTDIR)$(BINDIR)/ex; \
		echo q | $(DESTDIR)$(BINDIR)/ex; \
		mv $(DESTDIR)$(BINDIR)/ex $(DESTDIR)$(BINDIR)/ex.old.$$$$; \
		rm -f $(DESTDIR)$(BINDIR)/ex.old.$$$$; \
	fi
	$(INSTALL) -c $(STRIP) -m 1755 ex $(DESTDIR)$(BINDIR)/ex
	test -d $(DESTDIR)$(LIBEXECDIR) || mkdir -p $(DESTDIR)$(LIBEXECDIR)
	$(INSTALL) -c $(STRIP) exrecover $(DESTDIR)$(LIBEXECDIR)/exrecover
	$(INSTALL) -c $(STRIP) expreserve $(DESTDIR)$(LIBEXECDIR)/expreserve
	ln -s ex $(DESTDIR)$(BINDIR)/edit
	ln -s ex $(DESTDIR)$(BINDIR)/vedit
	ln -s ex $(DESTDIR)$(BINDIR)/vi
	ln -s ex $(DESTDIR)$(BINDIR)/view
	test -d $(DESTDIR)$(PRESERVEDIR) || mkdir -p $(DESTDIR)$(PRESERVEDIR)
	chmod 1777 $(DESTDIR)$(PRESERVEDIR)

PKGROOT = /var/tmp/heirloom-sh
PKGTEMP = /var/tmp
PKGPROTO = pkgproto

ex.pkg: all
	rm -rf $(PKGROOT)
	mkdir -p $(PKGROOT)
	$(MAKE) ROOT=$(PKGROOT) install
	rm -f $(PKGPROTO)
	echo 'i pkginfo' >$(PKGPROTO)
	(cd $(PKGROOT) && find . -print | pkgproto) | >>$(PKGPROTO) sed 's:^\([df] [^ ]* [^ ]* [^ ]*\) .*:\1 root root:; s:^f\( [^ ]* etc/\):v \1:; s:^f\( [^ ]* var/\):v \1:; s:^\(s [^ ]* [^ ]*=\)\([^/]\):\1./\2:'
	rm -rf $(PKGTEMP)/$@
	pkgmk -a `uname -m` -d $(PKGTEMP) -r $(PKGROOT) -f $(PKGPROTO) $@
	pkgtrans -o -s $(PKGTEMP) `pwd`/$@ $@
	rm -rf $(PKGROOT) $(PKGPROTO) $(PKGTEMP)/$@

ex.o: config.h ex_argv.h ex.h ex_proto.h ex_temp.h ex_tty.h ex_tune.h
ex.o: ex_vars.h libterm/libterm.h
ex_addr.o: config.h ex.h ex_proto.h ex_re.h ex_tune.h ex_vars.h
ex_cmds.o: config.h ex_argv.h ex.h ex_proto.h ex_temp.h ex_tty.h ex_tune.h
ex_cmds.o: ex_vars.h ex_vis.h libterm/libterm.h
ex_cmds2.o: config.h ex_argv.h ex.h ex_proto.h ex_temp.h ex_tty.h ex_tune.h
ex_cmds2.o: ex_vars.h ex_vis.h libterm/libterm.h
ex_cmdsub.o: config.h ex_argv.h ex.h ex_proto.h ex_temp.h ex_tty.h ex_tune.h
ex_cmdsub.o: ex_vars.h ex_vis.h libterm/libterm.h
ex_data.o: config.h ex.h ex_proto.h ex_tty.h ex_tune.h ex_vars.h
ex_data.o: libterm/libterm.h
ex_extern.o: config.h ex_argv.h ex.h ex_proto.h ex_re.h ex_temp.h ex_tty.h
ex_extern.o: ex_tune.h ex_vars.h ex_vis.h libterm/libterm.h
ex_get.o: config.h ex.h ex_proto.h ex_tty.h ex_tune.h ex_vars.h
ex_get.o: libterm/libterm.h
ex_io.o: config.h ex_argv.h ex.h ex_proto.h ex_temp.h ex_tty.h ex_tune.h
ex_io.o: ex_vars.h ex_vis.h libterm/libterm.h
ex_put.o: config.h ex.h ex_proto.h ex_tty.h ex_tune.h ex_vars.h ex_vis.h
ex_put.o: libterm/libterm.h
ex_re.o: config.h ex.h ex_proto.h ex_re.h ex_tune.h ex_vars.h
ex_set.o: config.h ex.h ex_proto.h ex_temp.h ex_tty.h ex_tune.h ex_vars.h
ex_set.o: libterm/libterm.h
ex_subr.o: config.h ex.h ex_proto.h ex_re.h ex_tty.h ex_tune.h ex_vars.h
ex_subr.o: ex_vis.h libterm/libterm.h
ex_tagio.o: config.h ex.h ex_proto.h ex_tune.h ex_vars.h
ex_temp.o: config.h ex.h ex_proto.h ex_temp.h ex_tty.h ex_tune.h ex_vars.h
ex_temp.o: ex_vis.h libterm/libterm.h
ex_tty.o: config.h ex.h ex_proto.h ex_tty.h ex_tune.h ex_vars.h
ex_tty.o: libterm/libterm.h
ex_unix.o: config.h ex.h ex_proto.h ex_temp.h ex_tty.h ex_tune.h ex_vars.h
ex_unix.o: ex_vis.h libterm/libterm.h
ex_v.o: config.h ex.h ex_proto.h ex_re.h ex_tty.h ex_tune.h ex_vars.h ex_vis.h
ex_v.o: libterm/libterm.h
ex_vadj.o: config.h ex.h ex_proto.h ex_tty.h ex_tune.h ex_vars.h ex_vis.h
ex_vadj.o: libterm/libterm.h
ex_vget.o: config.h ex.h ex_proto.h ex_tty.h ex_tune.h ex_vars.h ex_vis.h
ex_vget.o: libterm/libterm.h
ex_vmain.o: config.h ex.h ex_proto.h ex_tty.h ex_tune.h ex_vars.h ex_vis.h
ex_vmain.o: libterm/libterm.h
ex_voper.o: config.h ex.h ex_proto.h ex_re.h ex_tty.h ex_tune.h ex_vars.h
ex_voper.o: ex_vis.h libterm/libterm.h
ex_vops.o: config.h ex.h ex_proto.h ex_tty.h ex_tune.h ex_vars.h ex_vis.h
ex_vops.o: libterm/libterm.h
ex_vops2.o: config.h ex.h ex_proto.h ex_tty.h ex_tune.h ex_vars.h ex_vis.h
ex_vops2.o: libterm/libterm.h
ex_vops3.o: config.h ex.h ex_proto.h ex_tty.h ex_tune.h ex_vars.h ex_vis.h
ex_vops3.o: libterm/libterm.h
ex_vput.o: config.h ex.h ex_proto.h ex_tty.h ex_tune.h ex_vars.h ex_vis.h
ex_vput.o: libterm/libterm.h
ex_vwind.o: config.h ex.h ex_proto.h ex_tty.h ex_tune.h ex_vars.h ex_vis.h
ex_vwind.o: libterm/libterm.h
expreserve.o: config.h
exrecover.o: config.h ex.h ex_proto.h ex_temp.h ex_tty.h ex_tune.h ex_vars.h
exrecover.o: libterm/libterm.h
malloc.o: config.h
mapmalloc.o: config.h
printf.o: config.h
