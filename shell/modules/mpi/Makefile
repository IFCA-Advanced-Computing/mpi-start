all:
	$(MAKE) -C openmpi all
	$(MAKE) -C pacx all
	$(MAKE) -C mpich2 all
	$(MAKE) -C lam all
	$(MAKE) -C mpich all
	$(MAKE) -C generic all

clean:
	$(MAKE) -C openmpi clean
	$(MAKE) -C pacx clean
	$(MAKE) -C mpich2 clean
	$(MAKE) -C lam clean
	$(MAKE) -C mpich clean
	$(MAKE) -C generic clean

install:
	mkdir -p $(DESTDIR)/$(PREFIX)/etc/mpi-start
	install -m 0644 generic_mpiexec.sh $(DESTDIR)/$(PREFIX)/etc/mpi-start/
	install -m 0644 generic_mpi_start.sh $(DESTDIR)/$(PREFIX)/etc/mpi-start/
	install -m 0644 common.sh $(DESTDIR)/$(PREFIX)/etc/mpi-start/
	$(MAKE) -C openmpi install
	$(MAKE) -C pacx install
	$(MAKE) -C mpich2 install
	$(MAKE) -C lam install
	$(MAKE) -C mpich install
	$(MAKE) -C generic install
