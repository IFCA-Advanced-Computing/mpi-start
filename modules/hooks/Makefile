all:
	$(MAKE) -C file-dist all

clean:

install:
	mkdir -p $(DESTDIR)/$(MODULEPREFIX)
	install -m 0755 mpi-start.hooks $(DESTDIR)/$(MODULEPREFIX)
	install -m 0755 mpi-start.hooks.local $(DESTDIR)/$(MODULEPREFIX)
	install -m 0755 compiler.hook $(DESTDIR)/$(MODULEPREFIX)
	install -m 0755 marmot.hook $(DESTDIR)/$(MODULEPREFIX)
	install -m 0755 mpitrace.hook $(DESTDIR)/$(MODULEPREFIX)
	install -m 0755 openmp.hook $(DESTDIR)/$(MODULEPREFIX)
	$(MAKE) -C file-dist install

