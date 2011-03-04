# Makefile for MPI_START
VERSION=1.0.4
PACKAGE=kk
destdir=
exec_prefix=$(prefix)
bindir=$(exec_prefix)/bin
datadir=$(prefix)/share
docdir=$(datadir)/doc/$(PACKAGE)
moduledir=$(sysconfdir)/${name_prefix}mpi-start
sysconfdir=$(prefix)/etc
name_prefix=
prefix=/usr/local

all:
	sed -e s/@VERSION@/$(VERSION)/  < mpi-start.in > mpi-start 
	chmod 0755 mpi-start 

clean:
	rm -f mpi-start

install:
	echo $(prefix)
	echo $(exec_prefix)
	install -m 0755 mpi-start $(destdir)/$(bindir)/
#	install -m 0755 mpi-sh $(destdir)/$(bindir)

