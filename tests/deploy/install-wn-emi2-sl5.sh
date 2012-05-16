#!/bin/sh
# installation script for WN (emi2)

echo "*"
echo "* Installation "
echo "*"

# install mpi packages
echo "** Install MPI Packages"
yum --nogpg -q -y install openmpi-devel mpich2-devel gcc 
if [ $? -ne 0 ] ; then exit 1; fi

if [ "x$OSTYPE" = "xsl5" ] ; then 
    yum --nogpg -q -y install lam-devel 
    if [ $? -ne 0 ] ; then exit 1; fi
fi

## install emi-mpi
echo "** EMI-MPI"
yum --nogpg -y install emi-mpi
if [ $? -ne 0 ] ; then
    echo "******************************************************"
    echo "ERROR installing emi-mpi!"
    echo "******************************************************"
    exit 1
fi

echo "** EMI-WN"
# Install needed tools for WN
yum --nogpg -q -y  install emi-wn 

echo "******************************************************"
echo " INSTALLATION SUCCEDED!"
echo "******************************************************"
exit 0
