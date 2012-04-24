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
yum -q -y localinstall epel-release-5-4.noarch.rpm
if [ $? -ne 0 ] ; then exit 1; fi

#echo "***          Trust Anchors"
## Trust Anchors
wget http://repository.egi.eu/sw/production/cas/1/current/repo-files/egi-trustanchors.repo -O /etc/yum.repos.d/egi-trust.repo

#echo "***          emi 2 (rc4)"
# enable repos: emi 2
wget --no-check-certificate  https://twiki.cern.ch/twiki/pub/EMI/EMI-2/emi-2-rc4-sl5.repo -O /etc/yum.repos.d/emi2.repo
if [ $? -ne 0 ] ; then exit 1; fi

## update 
echo "** YUM Update"
yum -q -y update
 install lcg-ca 
echo "** Install CAs"
yum -q -y install ca-policy-egi-core
if [ $? -ne 0 ] ; then exit 1; fi


echo "** EMI-CREAM + Torque"
# Install needed tools for CE
yum -y install emi-cream-ce emi-torque-server emi-torque-utils
if [ $? -ne 0 ] ; then
    echo "******************************************************"
    echo "ERROR installing cream!"
    echo "******************************************************"
    exit 1
fi

## install emi-mpi
echo "** EMI-MPI"
yum -y install emi-mpi
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
