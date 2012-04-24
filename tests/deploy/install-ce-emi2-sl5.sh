#!/bin/sh

################
# INSTALLATION #
################

echo "*"
echo "* Installation "
echo "*"

echo "** EMI-CREAM + Torque"
yum -q -y install emi-cream-ce emi-torque-server emi-torque-utils
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
