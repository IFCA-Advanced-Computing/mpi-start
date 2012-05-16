#!/bin/sh
# installation script for WN on sl5 + emi2 

################
# INSTALLATION #
################

echo "*"
echo "* Installation"
echo "*"

# install mpi packages
echo "** Install MPI Packages"
yum -q -y install openmpi-devel mpich2-devel gcc 
if [ $? -ne 0 ] ; then exit 1; fi

## install emi-mpi
echo "** EMI-WN"
# Install needed tools for WN
yum -q -y install emi-wn 
if [ $? -ne 0 ] ; then exit 1; fi

echo "** EMI-MPI"
yum -y install emi-mpi
if [ $? -ne 0 ] ; then
    echo "******************************************************"
    echo "ERROR installing emi-mpi!"
    echo "******************************************************"
    exit 1
fi

echo "******************************************************"
echo " INSTALLATION OK!"
echo "******************************************************"
exit 0
