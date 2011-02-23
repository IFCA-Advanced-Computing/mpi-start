all:
	$(MAKE) -C file-dist all

clean:

install:
	mkdir -p $(DESTDIR)/$(ETCPREFIX)
	install -m 0644 mpi-start.hooks $(DESTDIR)/$(ETCPREFIX)
	install -m 0644 mpi-start.hooks.local $(DESTDIR)/$(ETCPREFIX)
	install -m 0644 compiler.hook $(DESTDIR)/$(ETCPREFIX)
	install -m 0644 marmot.hook $(DESTDIR)/$(ETCPREFIX)
	install -m 0644 mpitrace.hook $(DESTDIR)/$(ETCPREFIX)
	install -m 0644 openmp.hook $(DESTDIR)/$(ETCPREFIX)
	$(MAKE) -C file-dist install

