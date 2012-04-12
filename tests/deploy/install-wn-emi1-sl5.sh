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
wget http://download.fedoraproject.org/pub/epel/5/i386/epel-release-5-4.noarch.rpm
yum -y localinstall epel-release-5-4.noarch.rpm
if [ $? -ne 0 ] ; then exit 1; fi

echo "***          Trust Anchors"
## Trust Anchors
wget http://repository.egi.eu/sw/production/cas/1/current/repo-files/egi-trustanchors.repo -O /etc/yum.repos.d/egi-trust.repo

echo "***          emi 1"
wget http://emisoft.web.cern.ch/emisoft/dist/EMI/1/sl5/x86_64/updates/emi-release-1.0.1-1.sl5.noarch.rpm
yum -y localinstall emi-release-1.0.1-1.sl5.noarch.rpm
if [ $? -ne 0 ] ; then exit 1; fi

## update 
echo "** YUM Update"
yum -y update
# install lcg-ca 
echo "** Install CAs"
yum -y install ca-policy-egi-core
if [ $? -ne 0 ] ; then exit 1; fi

# install mpi packages
echo "** Install MPI Packages"
yum -y install openmpi-devel mpich2-devel gcc 
if [ $? -ne 0 ] ; then exit 1; fi

## disable security repo and install lam ?!
yum -y install lam-devel 
if [ $? -ne 0 ] ; then exit 1; fi

## install emi-mpi
echo "** gLite-MPI"
yum -y install glite-mpi
if [ $? -ne 0 ] ; then
    echo "******************************************************"
    echo "ERROR installing glite-mpi!"
    echo "******************************************************"
    exit 1
fi

echo "** EMI-WN"
# Install needed tools for WN
yum -y  install emi-wn 

echo "******************************************************"
echo " INSTALLATION SUCCEDED!"
echo "******************************************************"
exit 0
