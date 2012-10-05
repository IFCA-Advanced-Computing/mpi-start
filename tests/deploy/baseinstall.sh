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

if [ "$TYPE" = "ce" ] ; then
    echo "** EMI-CREAM + Torque"
    # Install needed tools for CE
    yum --nogpg -q -y install emi-cream-ce emi-torque-server emi-torque-utils
    if [ $? -ne 0 ] ; then
        echo "******************************************************"
        echo "ERROR installing cream!"
        echo "******************************************************"
        exit 1
    fi
else
    echo "** EMI-WN"
    # Install needed tools for WN
    yum -q -y  install emi-wn 

    # install mpi packages
    echo "** Install MPI Flavors"
    yum -q -y install openmpi-devel mpich2-devel gcc 
    if [ $? -ne 0 ] ; then exit 1; fi

    if [ "x$OSTYPE" = "xsl5" ] ; then 
        yum --nogpg -q -y install lam-devel 
        if [ $? -ne 0 ] ; then exit 1; fi
    fi
fi

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
