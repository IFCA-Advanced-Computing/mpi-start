# Makefile for MPI_START

all:
	sed -e s/@VERSION@/$(VERSION)/  < mpi-start.in > mpi-start 
	chmod 0755 mpi-start 

clean:
	rm -f mpi-start

install:
	install -m 0755 mpi-start $(DESTDIR)/$(PREFIX)/bin
#	install -m 0755 mpi-sh $(DESTDIR)/$(PREFIX)/bin

