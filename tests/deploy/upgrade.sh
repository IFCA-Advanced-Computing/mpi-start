#!/bin/sh
# update script for WN on sl5 + emi2 

################
# UPGRADE      #
################

echo "*"
echo "* Upgrade"
echo "*"

# 1, 2
EMIRELEASE=$1 
# sl5, sl6
OSTYPE=$2
# ce, wn
TYPE=$3

## update 
echo "** YUM Update mpi packages"

if [ "$EMIRELEASE" = "1" ] ; then
    MPI_RPM=glite-mpi
else
    MPI_RPM=emi-mpi
fi

yum -y update $MPI_RPM mpi-start glite-yaim-mpi

echo "** Installed versions:"
rpm -q emi-mpi
rpm -q mpi-start
rpm -q glite-yaim-mpi 

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
