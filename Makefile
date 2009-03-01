#!/usr/bin/make -f
#
# Yocto - An MPD client for the system notification area.
# Copyright (C) 2007-2009 nandhp <nandhp@gmail.com>
#
#    This program is free software; you can redistribute it and/or
#    modify it under the terms of the GNU General Public License as
#    published by the Free Software Foundation; either version 2 of
#    the License, or (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
#
# Makefile for Yocto
#

SHELL = /bin/sh
VERSION = $(shell perl -ne '(print($$1),exit) if m/\$VERSION = ([0-9]+\.[0-9]+);/;' yocto)

prefix      = /usr/local
eprefix     = $(prefix)
bindir      = $(eprefix)/bin
datarootdir = $(prefix)/share
mandir      = $(datarootdir)/man
desktopdir  = $(datarootdir)/applications
datadir     = $(datarootdir)/yocto
pixmapdir   = $(datarootdir)/pixmaps

all: yocto.1

clean:
	rm -f yocto.bin yocto.1 *~
	-fakeroot debian/rules clean

distclean: clean

install: all
	install -d $(bindir)
	install -p -m 755 yocto $(bindir)

	install -d $(mandir)/man1
	install -p -m 644 yocto.1 $(mandir)/man1

	install -d $(desktopdir)
	install -p -m 644 yocto.desktop $(desktopdir)

	install -d $(pixmapdir)
	install -p -m 644 yocto.svg $(pixmapdir)

	install -d $(datadir)
	install -p -m 644 yocto.svg yocto-off.svg $(datadir)

dist: distclean
	rm -rf yocto-$(VERSION)
	mkdir yocto-$(VERSION)
	cp -pr `cat MANIFEST` yocto-$(VERSION)
	tar --exclude=.bzr \
		-czf ../yocto-$(VERSION).tar.gz yocto-$(VERSION)
	rm -rf yocto-$(VERSION)

#yocto.bin: yocto
#	( cat yocto ; echo datadir=$(datadir) ) > yocto.bin
yocto.1: yocto.pod
	pod2man -r "Yocto $(VERSION)" -c "" yocto.pod yocto.1

deb: debfile

debfile:
	perl -e '$$v=shift;$$x=<>;$$x =~ m/\(([0-9.]+)/;$$d=$$1;die "Update changelog.Debian: Real and Debian versions dont match: R$$v D$$d\n" if $$d ne $$v' $(VERSION) debian/changelog
	fakeroot debian/rules binary
