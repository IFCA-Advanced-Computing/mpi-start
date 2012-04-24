#!/bin/sh

################
# INSTALLATION #
################

echo "*"
echo "* Installation "
echo "*"

echo "** Get Repos:"

echo "***          CAs"
wget -q -O - \
     https://dist.eugridpma.info/distribution/igtf/current/GPG-KEY-EUGridPMA-RPM-3 \
     | apt-key add -
echo "deb http://repository.egi.eu/sw/production/cas/1/current egi-igtf core" > /etc/apt/sources.list.d/cas.list


echo "***          emi 2 (rc4)"
wget --no-check-certificate https://twiki.cern.ch/twiki/pub/EMI/EMI-2/emi-2-rc4-deb6.list -O /etc/apt/sources.list.d/emi2.list


echo "** apt-get Update"
apt-get -q update

# install mpi packages
echo "** Install MPI Packages"
apt-get -q -y install openmpi-devel openmpi-bin mpich2 mpich-bin libmpich2-dev  libmpich1.0-dev lam-dev  lam-runtime

echo "** Install CAs"
apt-get -q -y install ca-policy-egi-core

# install emi-mpi
echo "** emi-mpi"
apt-get -y install emi-mpi
if [ $? -ne 0 ] ; then
    echo "******************************************************"
    echo "ERROR installing emi-mpi!"
    echo "******************************************************"
    exit 1
fi

# emi-wn is not available, install glite-yaim-clients instead
# and other dependencies: gawk, fetch-crl
echo "** emi-wn"
apt-get -q -y install glite-yaim-clients gawk fetch-crl

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
