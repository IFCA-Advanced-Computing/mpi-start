#!/bin/sh
# update script for WN on sl5 + emi2 

################
# UPGRADE      #
################

echo "*"
echo "* Upgrade"
echo "*"

echo "** Get Repos:"
echo "***          emi 2 (rc4)"
# enable repos: emi 2
wget --no-check-certificate  https://twiki.cern.ch/twiki/pub/EMI/EMI-2/emi-2-rc4-sl5.repo -O /etc/yum.repos.d/emi2.repo
if [ $? -ne 0 ] ; then exit 1; fi

## update 
echo "** YUM Upgrade"
yum -y upgrade

rpm -q emi-mpi

if [ $? -ne 0 ] ; then
    echo "******************************************************"
    echo "emi-mpi not found?!"
    echo "******************************************************"
    exit 1
fi

echo "******************************************************"
echo " INSTALLATION SUCCEDED!"
echo "******************************************************"
exit 0
