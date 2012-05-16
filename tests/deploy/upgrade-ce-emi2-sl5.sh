#!/bin/sh
# update script for WN on sl5 + emi2 

################
# UPGRADE      #
################

echo "*"
echo "* Upgrade"
echo "*"

## update 
echo "** YUM Update mpi packages"
yum update glite-mpi mpi-start glite-yaim-mpi

rpm -q emi-mpi

if [ $? -ne 0 ] ; then
    echo "******************************************************"
    echo "emi-mpi not found?!"
    echo "******************************************************"
    exit 1
fi

echo "** YUM update"
# just to have everything uptodate.
yum -q -y update 

echo "******************************************************"
echo " INSTALLATION SUCCEDED!"
echo "******************************************************"
exit 0
