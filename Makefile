# Makefile for MPI_START
VERSION=$(shell cat VERSION)
DESTDIR=
PREFIX=/opt/i2g

all:
	$(MAKE) -C src all 
	$(MAKE) -C modules all
	$(MAKE) -C templates all
	$(MAKE) -C docs all


clean:
	rm -f *.tar.gz
	$(MAKE) -C src clean
	$(MAKE) -C modules clean
	$(MAKE) -C templates clean
	$(MAKE) -C docs clean

distclean:clean

install:
	mkdir -p $(DESTDIR)/$(PREFIX)/bin
	mkdir -p $(DESTDIR)/$(PREFIX)/etc/mpi-start
	install COPYING $(DESTDIR)/$(PREFIX)/bin
	install COPYING $(DESTDIR)/$(PREFIX)/etc/mpi-start
	$(MAKE) -C src install
	$(MAKE) -C modules install
	$(MAKE) -C templates install
	$(MAKE) -C docs install

tarball:all
	$(MAKE) install PREFIX=`pwd`
	tar czvf mpi-start-$(VERSION).tar.gz bin/* etc/*

dist:	
	rm -rf i2g-mpi-start-$(VERSION)
	svn export . i2g-mpi-start-$(VERSION)
	sed -e "s/@NAME_PREFIX@/i2g-/" -e "s/@VERSION@/$(VERSION)/" mpi-start.spec.in > i2g-mpi-start-$(VERSION)/i2g-mpi-start-$(VERSION).spec
	tar cvzf i2g-mpi-start-$(VERSION).tar.gz i2g-mpi-start-$(VERSION)
	rm -rf i2g-mpi-start-$(VERSION)

export VERSION
export PREFIX
export DESTDIR
