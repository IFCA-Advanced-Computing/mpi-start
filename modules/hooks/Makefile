all:
	$(MAKE) -C file-dist all

clean:

install:
	mkdir -p $(DESTDIR)/$(PREFIX)/etc/mpi-start
	install -m 0644 mpi-start.hooks $(DESTDIR)/$(PREFIX)/etc/mpi-start/
	install -m 0644 mpi-start.hooks.local $(DESTDIR)/$(PREFIX)/etc/mpi-start/
	install -m 0644 compiler.hook $(DESTDIR)/$(PREFIX)/etc/mpi-start/
	install -m 0644 marmot.hook $(DESTDIR)/$(PREFIX)/etc/mpi-start/
	install -m 0644 mpitrace.hook $(DESTDIR)/$(PREFIX)/etc/mpi-start/
	install -m 0644 openmp.hook $(DESTDIR)/$(PREFIX)/etc/mpi-start/
	$(MAKE) -C file-dist install

