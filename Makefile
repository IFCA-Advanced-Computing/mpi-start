# Makefile for MPI_START
VERSION=$(shell cat VERSION)
DESTDIR=
PREFIX=
NAME_PREFIX=emi
USRPREFIX=
binDIR=bin
docDIR=share/doc/mpi-start-$(VERSION)
shareDIR=share/mpi-start/
BINPREFIX=$(PREFIX)/$(binDIR)
DOCPREFIX=$(PREFIX)/$(docDIR)
MODULEPREFIX=$(PREFIX)/$(shareDIR)
ifeq ("$(PREFIX)","")
	BINPREFIX=/usr/$(binDIR)
	DOCPREFIX=/usr/$(docDIR)
	MODULEPREFIX=/usr/$(shareDIR)
endif
ETCPREFIX=$(PREFIX)/etc/mpi-start

all:
	$(MAKE) -C src all 
	$(MAKE) -C modules all
	$(MAKE) -C templates all
	$(MAKE) -C docs all
	$(MAKE) -C tests all 

clean:
	rm -f *.tar.gz
	rm -rf bin etc
	$(MAKE) -C src clean
	$(MAKE) -C modules clean
	$(MAKE) -C templates clean
	$(MAKE) -C docs clean
	$(MAKE) -C tests clean

distclean:clean

install: all
	mkdir -p $(DESTDIR)/$(BINPREFIX)
	#mkdir -p $(DESTDIR)/$(ETCPREFIX)
	mkdir -p $(DESTDIR)/$(MODULEPREFIX)
	mkdir -p $(DESTDIR)/$(DOCPREFIX)
	mkdir -p $(DESTDIR)/etc
	install -m 0644 README $(DESTDIR)/$(DOCPREFIX)
	$(MAKE) -C src install
	$(MAKE) -C modules install
	$(MAKE) -C templates install
	$(MAKE) -C docs install
	$(MAKE) -C tests install 
	mkdir -p $(DESTDIR)/etc/profile.d
	echo "export I2G_MPI_START=$(BINPREFIX)/mpi-start" > $(DESTDIR)/etc/profile.d/mpi_start.sh
	echo "setenv I2G_MPI_START $(BINPREFIX)/mpi-start" > $(DESTDIR)/etc/profile.d/mpi_start.csh

tarball:all
	$(MAKE) install PREFIX="/" DESTDIR=`pwd` 
	tar czvf mpi-start-$(VERSION).tar.gz bin/* etc/*

dist:	
	rm -rf $(NAME_PREFIX)-mpi-start-$(VERSION)
	hg archive $(NAME_PREFIX)-mpi-start-$(VERSION)
	sed -e "s/@NAME_PREFIX@/$(NAME_PREFIX)-/" -e "s/@VERSION@/$(VERSION)/" mpi-start.spec.in > $(NAME_PREFIX)-mpi-start-$(VERSION)/$(NAME_PREFIX)-mpi-start-$(VERSION).spec
	tar cvzf $(NAME_PREFIX)-mpi-start-$(VERSION).tar.gz $(NAME_PREFIX)-mpi-start-$(VERSION)
	rm -rf $(NAME_PREFIX)-mpi-start-$(VERSION)

rpm: dist 
	mkdir -p rpm/SOURCES rpm/SRPMS rpm/SPECS rpm/BUILD rpm/RPMS
	rpmbuild --define "_topdir `pwd`/rpm" --define "mpi-start-prefix $(PREFIX)" -ta $(NAME_PREFIX)-mpi-start-$(VERSION).tar.gz

export VERSION
export PREFIX
export DESTDIR
export ETCPREFIX
export BINPREFIX
export DOCPREFIX
export MODULEPREFIX

