#!/bin/sh

echo "*"
echo "* Installation "
echo "*"

# install mpi packages
echo "** Install MPI Packages"
apt-get -qq -y install openmpi-dev openmpi-bin mpich2 mpich-bin libmpich2-dev libmpich1.0-dev lam-dev lam-runtime

echo "** Install CAs"
apt-get -qq -y install ca-policy-egi-core

# install emi-mpi
echo "** emi-mpi"
apt-get -y --force-yes install emi-mpi
if [ $? -ne 0 ] ; then
    echo "******************************************************"
    echo "ERROR installing emi-mpi!"
    echo "******************************************************"
    exit 1
fi

# emi-wn is not available, install glite-yaim-clients instead
# and other dependencies: gawk, fetch-crl
echo "** emi-wn"
apt-get -qq -y --force-yes install glite-yaim-clients gawk fetch-crl

echo "** Patching yaim for debian!"
wget --no-check-certificate http://devel.ifca.es/~enol/depot/debian.patch -O /tmp/debian.patch
patch -d /opt/glite/yaim -p1 -i /tmp/debian.patch
if [ $? -ne 0 ] ; then
    echo "******************************************************"
    echo "ERROR installing emi-mpi!"
    echo "******************************************************"
    exit 1
fi

echo "******************************************************"
echo " INSTALLATION SUCCEDED!"
echo "******************************************************"
exit 0
