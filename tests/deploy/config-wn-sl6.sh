#!/bin/sh
# testing script for configuring WN on sl5 

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

#unalias cp
echo "*"
echo "* Configuration"
echo "*"

echo "** Get yaim profiles"
wget http://devel.ifca.es/~enol/depot/yaim.tgz --no-check-certificate -O - | tar xzf - -C /etc/

# Add our host to wn-list
hostname >> /etc/yaim/wn-list.conf

# back up original config
cp /etc/yaim/site-info.def /etc/yaim/site-info.def.orig

# Basic configuration
echo "** Configure basic WN (no MPI)"
configure_ok -n WN


# wrong configurations
# wrong path
echo "** Error cases:"
echo "**             wrong path"
cat /etc/yaim/site-info.def.orig > /etc/yaim/site-info.def
cat >> /etc/yaim/site-info.def << EOF
#### MPI CONFIGURATION
MPI_OPENMPI_ENABLE="yes"
MPI_OPENMPI_PATH="/this/goes/nowhere"
EOF
cat /etc/yaim/site-info.def | grep MPI
configure_and_fail

# unknown flavor
echo "**             unknown flavor"
cat /etc/yaim/site-info.def.orig > /etc/yaim/site-info.def
cat >> /etc/yaim/site-info.def << EOF
#### MPI CONFIGURATION
MPI_FOO_ENABLE="yes"
EOF
cat /etc/yaim/site-info.def | grep MPI
configure_ok
rm -f /tmp/env
touch /tmp/env
diff_configs /tmp/env 

# uninstalled flavor 
echo "**             uninstalled flavor"
cat /etc/yaim/site-info.def.orig > /etc/yaim/site-info.def
cat >> /etc/yaim/site-info.def << EOF
#### MPI CONFIGURATION
MPI_MPICH_ENABLE="yes"
EOF
cat /etc/yaim/site-info.def | grep MPI
configure_and_fail

# just openmpi
echo "** OK cases:"
echo "**          openmpi only"
cat /etc/yaim/site-info.def.orig > /etc/yaim/site-info.def
cat >> /etc/yaim/site-info.def << EOF
#### MPI CONFIGURATION
MPI_OPENMPI_ENABLE="yes"
EOF
cat /etc/yaim/site-info.def | grep MPI
configure_ok
cat > /tmp/env << EOF
I2G_MPI_START=/usr/bin/mpi-start
MPI_DEFAULT_FLAVOUR=openmpi
MPI_OPENMPI_PATH=/usr/lib64/openmpi
MPI_OPENMPI_VERSION=1.5.3
EOF
diff_configs /tmp/env

# openmpi with version
cat /etc/yaim/site-info.def.orig > /etc/yaim/site-info.def
cat >> /etc/yaim/site-info.def << EOF
#### MPI CONFIGURATION
MPI_OPENMPI_ENABLE="yes"
MPI_OPENMPI_VERSION=3.4.5
EOF
cat /etc/yaim/site-info.def | grep MPI
configure_ok
cat > /tmp/env << EOF
I2G_MPI_START=/usr/bin/mpi-start
MPI_DEFAULT_FLAVOUR=openmpi
MPI_OPENMPI_PATH=/usr/lib64/openmpi
MPI_OPENMPI_VERSION=3.4.5
EOF
diff_configs /tmp/env

# openmpi with version and path
cat /etc/yaim/site-info.def.orig > /etc/yaim/site-info.def
cat >> /etc/yaim/site-info.def << EOF
#### MPI CONFIGURATION
MPI_OPENMPI_ENABLE="yes"
MPI_OPENMPI_VERSION=3.4.5
MPI_OPENMPI_PATH=/usr/lib64/openmpi
EOF
configure_ok
cat /etc/yaim/site-info.def | grep MPI
cat > /tmp/env << EOF
I2G_MPI_START=/usr/bin/mpi-start
MPI_DEFAULT_FLAVOUR=openmpi
MPI_OPENMPI_PATH=/usr/lib64/openmpi
MPI_OPENMPI_VERSION=3.4.5
EOF
diff_configs /tmp/env

# shared home: no
cat /etc/yaim/site-info.def.orig > /etc/yaim/site-info.def
cat >> /etc/yaim/site-info.def << EOF
#### MPI CONFIGURATION
MPI_OPENMPI_ENABLE="yes"
MPI_SHARED_HOME=no
EOF
configure_ok
cat /etc/yaim/site-info.def | grep MPI
cat > /tmp/env << EOF
I2G_MPI_START=/usr/bin/mpi-start
MPI_DEFAULT_FLAVOUR=openmpi
MPI_OPENMPI_PATH=/usr/lib64/openmpi/1.4-gcc
MPI_OPENMPI_VERSION=1.4
MPI_SHARED_HOME=no
EOF
diff_configs /tmp/env

# shared home: yes
cat /etc/yaim/site-info.def.orig > /etc/yaim/site-info.def
cat >> /etc/yaim/site-info.def << EOF
#### MPI CONFIGURATION
MPI_OPENMPI_ENABLE="yes"
MPI_SHARED_HOME=yes
EOF
configure_ok
cat /etc/yaim/site-info.def | grep MPI
cat > /tmp/env << EOF
I2G_MPI_START=/usr/bin/mpi-start
MPI_DEFAULT_FLAVOUR=openmpi
MPI_OPENMPI_PATH=/usr/lib64/openmpi/1.4-gcc
MPI_OPENMPI_VERSION=1.4
MPI_START_SHARED_FS=1
EOF
diff_configs /tmp/env

# shared home: yes + path
cat /etc/yaim/site-info.def.orig > /etc/yaim/site-info.def
cat >> /etc/yaim/site-info.def << EOF
#### MPI CONFIGURATION
MPI_OPENMPI_ENABLE="yes"
MPI_SHARED_HOME=yes
MPI_SHARED_HOME_PATH=/tmp
EOF
configure_ok
cat /etc/yaim/site-info.def | grep MPI
cat > /tmp/env << EOF
I2G_MPI_START=/usr/bin/mpi-start
MPI_DEFAULT_FLAVOUR=openmpi
MPI_OPENMPI_PATH=/usr/lib64/openmpi/1.4-gcc
MPI_OPENMPI_VERSION=1.4
MPI_SHARED_HOME_PATH=/tmp
MPI_SHARED_HOME=yes
EOF
diff_configs /tmp/env

# openmpi + mpich2 + lam 
cat /etc/yaim/site-info.def.orig > /etc/yaim/site-info.def
cat >> /etc/yaim/site-info.def << EOF
#### MPI CONFIGURATION
MPI_OPENMPI_ENABLE="yes"
MPI_LAM_ENABLE="yes"
MPI_MPICH2_ENABLE="yes"
EOF
configure_ok
cat /etc/yaim/site-info.def | grep MPI
cat > /tmp/env << EOF
I2G_MPI_START=/usr/bin/mpi-start
MPI_DEFAULT_FLAVOUR=openmpi
MPI_LAM_PATH=/usr/lib64/lam
MPI_LAM_VERSION=7.1.2
MPI_MPICH2_PATH=/usr/lib64/mpich2
MPI_MPICH2_VERSION=1.2.1p1
MPI_OPENMPI_PATH=/usr/lib64/openmpi/1.4-gcc
MPI_OPENMPI_VERSION=1.4
EOF
diff_configs /tmp/env

# complete testing of mpi-start
# version
mpi-start -V

wget https://devel.ifca.es/hg/mpi-start/archive/tip.tar.gz --no-check-certificate -O - | tar -xzf - -C /tmp
mv /tmp/mpi-start-* /tmp/mpi-start
cat /tmp/mpi-start/tests/run_tests.sh | \
    sed 's/RUN_OMP_TESTS=0/RUN_OMP_TESTS=1/' | \
    sed 's/RUN_MPICH2_TESTS=0/RUN_MPICH2_TESTS=1/' |\
    sed 's/RUN_OPENMPI_TESTS=0/RUN_OPENMPI_TESTS=1/' | \
    sed 's/RUN_LAM_TESTS=0/RUN_LAM_TESTS=1/' > /tmp/mpi-start/tests/runner.sh
chmod +x /tmp/mpi-start/tests/runner.sh
chown -R dteam001:dteam /tmp/mpi-start/

su - dteam001 -c "cd /tmp/mpi-start/tests; ./runner.sh"
if [ $? -ne 0 ] ; then
    echo "******************************************************"
    echo "MPI-START Tests failed!!"
    echo "******************************************************"
    exit 1
fi

echo "******************************************************"
echo " TESTS SUCCEDED!"
echo "******************************************************"
exit 0
