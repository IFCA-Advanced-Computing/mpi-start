#!/bin/sh
# installation script for WN on sl5 + emi2 

################
# INSTALLATION #
################

echo "*"
echo "* Installation "
echo "*"

# install mpi packages
echo "** Install MPI Packages"
yum -q -y install openmpi-devel mpich2-devel gcc 
if [ $? -ne 0 ] ; then exit 1; fi

## disable security repo and install lam ?!
yum -q -y install lam-devel 
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
yum -q -y  install emi-wn 

echo "******************************************************"
echo " INSTALLATION SUCCEDED!"
echo "******************************************************"
exit 0
