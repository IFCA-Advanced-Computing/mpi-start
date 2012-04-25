#!/bin/sh
# testing script for configuring WN on sl5 

CONFIG_PROFILES="-n MPI_CE -n creamCE -n TORQUE_server"

configure_ok() {
    /opt/glite/yaim/bin/yaim -s /etc/yaim/site-info.def -c $CONFIG_PROFILES
    if [ $? -ne 0 ] ; then
        echo "******************************************************"
        echo "ERROR Configuring CE" 
        echo "******************************************************"
        exit 1
    fi
}

configure_and_fail () {
    /opt/glite/yaim/bin/yaim -s /etc/yaim/site-info.def -c $CONFIG_PROFILES
    if [ $? -eq 0 ] ; then
        echo "******************************************************"
        echo "Expected ERROR Configuring CE, and was success"
        echo "******************************************************"
        exit 1
    fi
}

diff_configs() {
    # let the ldap server start up
    sleep 2m
    ldapsearch -x -h localhost -p 2170 -b mds-vo-name=resource,o=grid objectClass=GlueSubCluster | grep MPI | cut -f2 -d":" | tr -d " " | sort > /tmp/ldap.out
    diff $1 /tmp/ldap.out
    if [ $? -ne 0 ] ; then
        echo "******************************************************"
        echo "ERROR in resulting ldap after configuration"
        echo "******************************************************"
        exit 1
    fi
}

#################
# CONFIGURATION #
#################

#unalias cp
echo "*"
echo "* Configuration"
echo "*"

echo "** MUNGE"
create-munge-key
service munge start

echo "** Get yaim profiles"
wget -q http://devel.ifca.es/~enol/depot/yaim.tgz --no-check-certificate -O - | tar xzf - -C /etc/

chmod -R 750 /etc/yaim

# Add our host to wn-list
echo "test14.egi.cesga.es" > /etc/yaim/wn-list.conf
echo "test15.egi.cesga.es" >> /etc/yaim/wn-list.conf


echo "MYSQL_PASSWORD=mySq1_${RANDOM}_long_password" >> /etc/yaim/site-info.def
echo "CREAM_DB_PASSWORD=Cr34m_${RANDOM}_long_password" >> /etc/yaim/site-info.def
echo "CE_HOST=`hostname -f`" >> /etc/yaim/site-info.def
echo "CEMON_HOST=`hostname -f`" >> /etc/yaim/site-info.def
echo "BATCH_SERVER=`hostname -f`" >> /etc/yaim/site-info.def

# back up original config
cp /etc/yaim/site-info.def /etc/yaim/site-info.def.orig

# Basic configuration
echo "*"
echo "** Configure basic CE (no MPI variables)"
echo "*"
configure_ok 
rm -f /tmp/env
touch /tmp/env
diff_configs /tmp/env


echo "*"
echo "** Configure basic CE with MPI"
echo "*"

echo "*******************************************"
echo " 1 MPI Flavour"
echo "*******************************************"
# Add one MPI flavour
cat /etc/yaim/site-info.def.orig > /etc/yaim/site-info.def
cat >> /etc/yaim/site-info.def << EOF
#### MPI CONFIGURATION
MPI_OPENMPI_ENABLE="yes"
MPI_OPENMPI_VERSION="2.3.4"
EOF
cat /etc/yaim/site-info.def | grep MPI
configure_ok 
cat > /tmp/env << EOF
MPI_NO_SHARED_HOME
MPI-START
MPI-START-1.3.0
OPENMPI
OPENMPI-2.3.4
EOF
diff_configs /tmp/env

# Shared home to yes
echo "*******************************************"
echo " SHARED HOME = yes"
echo "*******************************************"
cat /etc/yaim/site-info.def.orig > /etc/yaim/site-info.def
cat >> /etc/yaim/site-info.def << EOF
#### MPI CONFIGURATION
MPI_OPENMPI_ENABLE="yes"
MPI_OPENMPI_VERSION="2.3.4"
MPI_SHARED_HOME="yes"
EOF
cat /etc/yaim/site-info.def | grep MPI
configure_ok 
cat > /tmp/env << EOF
MPI_SHARED_HOME
MPI-START
MPI-START-1.3.0
OPENMPI
OPENMPI-2.3.4
EOF
diff_configs /tmp/env

# Force mpi-start version (bug #52)
echo "*******************************************"
echo " Force MPI-START version"
echo "*******************************************"
cat /etc/yaim/site-info.def.orig > /etc/yaim/site-info.def
cat >> /etc/yaim/site-info.def << EOF
#### MPI CONFIGURATION
MPI_OPENMPI_ENABLE="yes"
MPI_OPENMPI_VERSION="2.3.4"
MPI_START_VERSION="2.6b.2"
EOF
cat /etc/yaim/site-info.def | grep MPI
configure_ok 
cat > /tmp/env << EOF
MPI_NO_SHARED_HOME
MPI-START
MPI-START-2.6b.2
OPENMPI
OPENMPI-2.3.4
EOF
diff_configs /tmp/env

# Try removing mpi-start package (bug #52)
echo "*******************************************"
echo " Force MPI-START version (without package)"
echo "*******************************************"
yum remove -y mpi-start
cat /etc/yaim/site-info.def.orig > /etc/yaim/site-info.def
cat >> /etc/yaim/site-info.def << EOF
#### MPI CONFIGURATION
MPI_OPENMPI_ENABLE="yes"
MPI_OPENMPI_VERSION="2.3.4"
MPI_START_VERSION="2.6b.2"
EOF
cat /etc/yaim/site-info.def | grep MPI
configure_ok 
cat > /tmp/env << EOF
MPI_NO_SHARED_HOME
MPI-START
MPI-START-2.6b.2
OPENMPI
OPENMPI-2.3.4
EOF
diff_configs /tmp/env


# Again without mpi-start package and without version (bug #52)
echo "*******************************************"
echo " No MPI-START version (without package)"
echo "*******************************************"
cat /etc/yaim/site-info.def.orig > /etc/yaim/site-info.def
cat >> /etc/yaim/site-info.def << EOF
#### MPI CONFIGURATION
MPI_OPENMPI_ENABLE="yes"
MPI_OPENMPI_VERSION="2.3.4"
EOF
cat /etc/yaim/site-info.def | grep MPI
configure_ok 
cat > /tmp/env << EOF
MPI_NO_SHARED_HOME
MPI-START
OPENMPI
OPENMPI-2.3.4
EOF
diff_configs /tmp/env

# install again emi-mpi
yum -y install emi-mpi

# Test the torque filter
echo "*******************************************"
echo " Torque submit filter test" 
echo "*******************************************"


cat /etc/yaim/site-info.def.orig > /etc/yaim/site-info.def
cat >> /etc/yaim/site-info.def << EOF
#### MPI CONFIGURATION
MPI_OPENMPI_ENABLE="yes"
MPI_OPENMPI_VERSION="1.2.3"
MPI_SUBMIT_FILTER="yes"
EOF
if [ "x$OSTYPE" = "xsl6" ] ; then
    TORQUE_VAR_DIR=/var/lib/torque
    echo "TORQUE_VAR_DIR=/var/lib/torque" > /etc/yaim/site-info.def
else
    TORQUE_VAR_DIR=/var/torque
fi
cat /etc/yaim/site-info.def | grep MPI
configure_ok 
echo "submit filter:"
cat $TORQUE_VAR_DIR/torque.cfg | grep SUBMITFILTER 
if [ $? -ne 0 ] ; then 
    echo "******************************************************"
    echo "Error in submit filter!?"
    echo "******************************************************"
    exit 1
fi
echo "#PBS -l nodes=4" | $TORQUE_VAR_DIR/submit_filter | grep "PBS -l nodes=2:ppn=2$" > /dev/null
if [ $? -ne 0 ] ; then 
    echo "******************************************************"
    echo "Error in submit filter!?"
    echo "******************************************************"
    exit 1
fi

echo "******************************************************"
echo " CONFIGURATION SUCCEDED!"
echo "******************************************************"
exit 0
