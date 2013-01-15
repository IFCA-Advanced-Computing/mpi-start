#!/bin/sh
# installation script for WN on sl5 + emi2 

################
# INSTALLATION #
################

echo "*"
echo "* PRE - Installation "
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
    if [ $EMIRELEASE = 3 ]; then
        echo "** yaim clients + fetch crl"
        yum -q -y install fetch-crl
        yum --nogpg -q -y install glite-yaim-clients
    else
        echo "** EMI-WN"
        # Install needed tools for WN
        yum -q -y  install emi-wn 
    fi
    # install mpi packages
    echo "** Install MPI Flavors"
    yum -q -y install openmpi-devel mpich2-devel gcc 
    if [ $? -ne 0 ] ; then exit 1; fi

    if [ "x$OSTYPE" = "xsl5" ] ; then 
        yum --nogpg -q -y install lam-devel 
        if [ $? -ne 0 ] ; then exit 1; fi
    fi
fi

echo "******************************************************"
echo " PRE INSTALLATION SUCCEDED!"
echo "******************************************************"
exit 0

