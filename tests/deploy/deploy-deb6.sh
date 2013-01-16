#!/bin/bash

EMIRELEASE=3
OSTYPE=deb6
TYPE=wn

echo "*"
echo "* Base repo configuration"
echo "*"

wget -q -O - https://dist.eugridpma.info/distribution/igtf/current/GPG-KEY-EUGridPMA-RPM-3 | apt-key add -
echo "deb http://repository.egi.eu/sw/production/cas/1/current egi-igtf core" > /etc/apt/sources.list.d/egi-cas.list
apt-get -qq update


echo "** apt-get upgrade"
apt-get -y -qq upgrade > /dev/null

echo "** Install CAs"
apt-get -y -qq install ca-policy-egi-core > /dev/null
if [ $? -ne 0 ] ; then exit 1; fi

echo "******************************************************"
echo " BASIC REPO CONFIG OK!"
echo "******************************************************"

echo "*"
echo "* Certification REPO"
echo "*"

cp cert-emi$EMIRELEASE-$OSTYPE.list /etc/apt/sources.list.d/cert.list

echo "** EMI $EMIRELEASE $OSTYPE RC ->"
cat  /etc/apt/sources.list.d/cert.list

apt-get -qq -y update > /dev/null

echo "******************************************************"
echo " CERTIFICATION REPO CONFIG OK!"
echo "******************************************************"

echo "*"
echo "* PRE - Installation "
echo "*"

echo "** yaim clients + fetch crl"
apt-get -qq -y install fetch-crl gawk > /dev/null
apt-get -qq -y --force-yes install glite-yaim-clients  > /dev/null
if [ $? -ne 0 ] ; then exit 1; fi

echo "** Install MPI Flavors"
apt-get -qq -y install libopenmpi-dev openmpi-bin  libmpich2-dev  mpich2 mpich-bin libmpich1.0-dev > /dev/null

echo "******************************************************"
echo " PRE INSTALLATION SUCCEDED!"
echo "******************************************************"

echo "*"
echo "* emi MPI Installation "
echo "*"

echo "** EMI-MPI"
apt-get -y --force-yes install emi-mpi
if [ $? -ne 0 ] ; then
    echo "******************************************************"
    echo "ERROR installing emi-mpi!"
    echo "******************************************************"
    exit 1
fi

echo "******************************************************"
echo " INSTALLATION SUCCEDED!"
echo "******************************************************"

echo "Yaim unsupported in deb6, skipping!"

echo "** Run mpi-start tests" 
rm -rf /tmp/*mpi-start*
wget -q https://bitbucket.org/enolfc/mpi-start/get/tip.tar.gz --no-check-certificate -O - | tar -xzf - -C /tmp
mv /tmp/*mpi-start-* /tmp/mpi-start
cat /tmp/mpi-start/tests/run_tests.sh | \
    sed 's/RUN_OMP_TESTS=0/RUN_OMP_TESTS=1/' > /tmp/mpi-start/tests/runner.sh
for f in OPENMPI MPICH MPICH2; do 
    cat /tmp/mpi-start/tests/run_tests.sh | \
        sed "s/RUN_${f}_TESTS=0/RUN_${f}_TESTS=1/" > /tmp/mpi-start/tests/runner.sh
    cat /tmp/mpi-start/tests/runner.sh > /tmp/mpi-start/tests/run_tests.sh
done
chmod +x /tmp/mpi-start/tests/runner.sh

# 

id emitester &> /dev/null
if [ $? -eq 1 ] ; then
    useradd -m emitester
    # create ssh key for user and add it to authorized keys
    su - emitester -c "mkdir .ssh; ssh-keygen -P \"\" -f .ssh/id_rsa; cat .ssh/id_rsa.pub > .ssh/authorized_keys2"
fi

chown -R emitester /tmp/mpi-start/

su - emitester -c "cd /tmp/mpi-start/tests; ./runner.sh"
if [ $? -ne 0 ] ; then
    echo "******************************************************"
    echo "MPI-START Tests failed!!"
    echo "******************************************************"
    exit 1
fi

echo "******************************************************"
echo " TESTS SUCCEDED!"
echo "******************************************************"

exit $?
