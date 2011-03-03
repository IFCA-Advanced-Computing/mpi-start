all:
	$(MAKE) -C openmpi all
	$(MAKE) -C pacx all
	$(MAKE) -C mpich2 all
	$(MAKE) -C lam all
	$(MAKE) -C mpich all
	$(MAKE) -C generic all
	$(MAKE) -C dummy all

clean:
	$(MAKE) -C openmpi clean
	$(MAKE) -C pacx clean
	$(MAKE) -C mpich2 clean
	$(MAKE) -C lam clean
	$(MAKE) -C mpich clean
	$(MAKE) -C generic clean
	$(MAKE) -C dummy clean

install:
	mkdir -p $(DESTDIR)/$(MODULEPREFIX)
	install -m 0755 generic_mpiexec.sh $(DESTDIR)/$(MODULEPREFIX)/
	install -m 0755 generic_mpi_start.sh $(DESTDIR)/$(MODULEPREFIX)/
	install -m 0755 common.sh $(DESTDIR)/$(MODULEPREFIX)/
	$(MAKE) -C openmpi install
	$(MAKE) -C pacx install
	$(MAKE) -C mpich2 install
	$(MAKE) -C lam install
	$(MAKE) -C mpich install
	$(MAKE) -C generic install
	$(MAKE) -C dummy install
