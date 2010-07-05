all:
	$(MAKE) -C file-dist all

clean:

install:
	mkdir -p $(DESTDIR)/$(PREFIX)/etc/mpi-start
	install -m 0644 mpi-start.hooks $(DESTDIR)/$(PREFIX)/etc/mpi-start/
	install -m 0644 mpi-start.hooks.local $(DESTDIR)/$(PREFIX)/etc/mpi-start/
	install -m 0644 compiler.hooks $(DESTDIR)/$(PREFIX)/etc/mpi-start/
	$(MAKE) -C file-dist install

