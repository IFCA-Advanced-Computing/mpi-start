#!/bin/sh
# installation script for WN on sl5 + emi2 

################
# INSTALLATION #
################

echo "*"
echo "* Installation "
echo "*"

echo "** Get Repos:"
echo "***          Epel"
## epel
wget http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-5.noarch.rpm
yum -q -y localinstall epel-release-6-5.noarch.rpm
if [ $? -ne 0 ] ; then exit 1; fi

echo "***          Trust Anchors"
## Trust Anchors
wget http://repository.egi.eu/sw/production/cas/1/current/repo-files/egi-trustanchors.repo -O /etc/yum.repos.d/egi-trust.repo

echo "***          emi 2 (rc4)"
# enable repos: emi 2
wget --no-check-certificate  https://twiki.cern.ch/twiki/pub/EMI/EMI-2/emi-2-rc4-sl6.repo -O /etc/yum.repos.d/emi2.repo
if [ $? -ne 0 ] ; then exit 1; fi


## update 
echo "** YUM Update"
yum -q -y update
# install lcg-ca 
echo "** Install CAs"
yum -q -y install ca-policy-egi-core
if [ $? -ne 0 ] ; then exit 1; fi

# install mpi packages
echo "** Install MPI Packages"
yum -q -y install openmpi-devel mpich2-devel gcc 
if [ $? -ne 0 ] ; then exit 1; fi

## install emi-mpi
echo "** EMI-MPI"
yum -y install emi-mpi
if [ $? -ne 0 ] ; then
    echo "******************************************************"
    echo "ERROR installing emi-mpi!"
    echo "******************************************************"
    exit 1
fi

echo "** EMI-WN"
# Install needed tools for WN
yum -q -y install emi-wn 

echo "******************************************************"
echo " INSTALLATION SUCCEDED!"
echo "******************************************************"
exit 0
