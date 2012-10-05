#!/bin/sh
# testing script for configuring WN on sl5 

# 1, 2
EMIRELEASE=$1 
# sl5, sl6
OSTYPE=$2
# ce, wn
TYPE=$3


configure_ok() {
    /opt/glite/yaim/bin/yaim -s /etc/yaim/site-info.def -c -n MPI_WN $*
    if [ $? -ne 0 ] ; then
        echo "******************************************************"
        echo "ERROR Configuring WN"
        echo "******************************************************"
        exit 1
    fi
}

configure_and_fail () {
    /opt/glite/yaim/bin/yaim -s /etc/yaim/site-info.def -c -n MPI_WN $*
    if [ $? -eq 0 ] ; then
        echo "******************************************************"
        echo "Expected ERROR Configuring WN, and was success"
        echo "******************************************************"
        exit 1
    fi
}

diff_configs() {
    su - dteam001 -c "env | grep MPI|sort > /tmp/env.out"
    diff $1 /tmp/env.out
    if [ $? -ne 0 ] ; then
        echo "******************************************************"
        echo "ERROR in resulting environment after configuration"
        echo "******************************************************"
        exit 1
    fi
}

#################
# CONFIGURATION #
#################

echo "*"
echo "* Basic Configuration (for Update)"
echo "*"

echo "** Get yaim profiles"
wget -q http://devel.ifca.es/~enol/depot/yaim.tgz --no-check-certificate -O - | tar xzf - -C /etc/

chmod -R 750 /etc/yaim

# Add our host to wn-list
hostname -f >> /etc/yaim/wn-list.conf

# Add a fake CE_HOST
echo "CE_HOST=gridce01.ifca.es" >> /etc/yaim/site-info.def

# back up original config
cp /etc/yaim/site-info.def /etc/yaim/site-info.def.orig

# Basic configuration
echo "*"
echo "** Configure basic WN (no MPI variables)"
echo "*"
configure_ok -n WN

echo "******************************************************"
echo " TESTS SUCCEDED!"
echo "******************************************************"
exit 0
