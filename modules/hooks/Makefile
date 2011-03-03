all:
	$(MAKE) -C file-dist all

clean:

install:
	mkdir -p $(DESTDIR)/$(MODULEPREFIX)
	install -m 0644 mpi-start.hooks $(DESTDIR)/$(MODULEPREFIX)
	install -m 0644 mpi-start.hooks.local $(DESTDIR)/$(MODULEPREFIX)
	install -m 0644 compiler.hook $(DESTDIR)/$(MODULEPREFIX)
	install -m 0644 marmot.hook $(DESTDIR)/$(MODULEPREFIX)
	install -m 0644 mpitrace.hook $(DESTDIR)/$(MODULEPREFIX)
	install -m 0644 openmp.hook $(DESTDIR)/$(MODULEPREFIX)
	$(MAKE) -C file-dist install

