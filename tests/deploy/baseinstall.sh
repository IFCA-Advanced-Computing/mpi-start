#!/bin/sh
# installation script for WN on sl5 + emi2 

################
# INSTALLATION #
################

echo "*"
echo "* Installation (pre UPDATE)"
echo "*"

# 1, 2
EMIRELEASE=$1 
# sl5, sl6
OSTYPE=$2
# ce, wn
TYPE=$3

if [ "$EMIRELEASE" = "1" ] ; then
    MPI_RPM=glite-mpi
else
    MPI_RPM=emi-mpi
fi

## install emi-mpi
echo "** $MPI_RPM"
yum --nogpg -y install $MPI_RPM 
if [ $? -ne 0 ] ; then
    echo "******************************************************"
    echo "ERROR installing $MPI_RPM!"
    echo "******************************************************"
    exit 1
fi

echo "******************************************************"
echo " INSTALLATION SUCCEDED!"
echo "******************************************************"
exit 0
