# Makefile for MPI_START
VERSION=@VERSION@
destdir=
prefix=@prefix@
exec_prefix=@exec_prefix@
bindir=@bindir@
datadir=@datadir@
docdir=@docdir@
moduledir=@moduledir@
sysconfdir=@sysconfdir@
name_prefix=@name_prefix@

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
	mkdir -p $(destdir)/$(bindir)
	mkdir -p $(destdir)/$(sysconfdir)
	mkdir -p $(destdir)/$(moduledir)
	mkdir -p $(destdir)/$(docdir)
	install -m 0644 README $(destdir)/$(docdir)
	install -m 0644 ChangeLog $(destdir)/$(docdir)
	$(MAKE) -C src install
	$(MAKE) -C modules install
	$(MAKE) -C templates install
	$(MAKE) -C docs install
	$(MAKE) -C tests install 
	mkdir -p $(destdir)/$(sysconfdir)/profile.d
	echo "export I2G_MPI_START=$(bindir)/mpi-start" > \
					$(destdir)/$(sysconfdir)/profile.d/mpi_start.sh
	echo "setenv I2G_MPI_START $(bindir)/mpi-start" > \
					$(destdir)/$(sysconfdir)/profile.d/mpi_start.csh

tarball:all
	mkdir -p bin
	mkdir -p etc
	$(MAKE) -C src install destdir=`pwd` prefix="/" 
	$(MAKE) -C modules install destdir=`pwd` prefix="/" 
	tar czvf mpi-start-$(VERSION).tar.gz bin/* etc/*

DISTFILES=src\
modules\
docs\
templates \
tests \
ChangeLog \
Makefile \
README \
VERSION

dist:	
	rm -rf $(name_prefix)mpi-start-$(VERSION)
	# what if hg is not here!
	# hg archive $(name_prefix)mpi-start-$(VERSION)
	mkdir $(name_prefix)mpi-start-$(VERSION)
	cp -a $(DISTFILES) $(name_prefix)mpi-start-$(VERSION)
	sed -e "s/@name_prefix@/$(name_prefix)/" \
		-e "s/@VERSION@/$(VERSION)/" mpi-start.spec.in \
		> $(name_prefix)mpi-start-$(VERSION)/$(name_prefix)mpi-start.spec
	tar cvzf $(name_prefix)mpi-start-$(VERSION).tar.gz $(name_prefix)mpi-start-$(VERSION)
	rm -rf $(name_prefix)mpi-start-$(VERSION)

rpm: dist 
	mkdir -p rpm/SOURCES rpm/SRPMS rpm/SPECS rpm/BUILD rpm/RPMS
	rpmbuild --define "_topdir `pwd`/rpm" -ta $(name_prefix)mpi-start-$(VERSION).tar.gz

export VERSION
export prefix
export destdir
export exec_prefix
export bindir
export datadir
export docdir
export moduledir
export sysconfdir
export name_prefix

