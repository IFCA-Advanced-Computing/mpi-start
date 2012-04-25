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

echo "*"
echo "* Configuration"
echo "*"


if [ "x$OSTYPE" = "xsl5" ] ; then
    OPENMPI_PATH=/usr/lib64/openmpi/1.4-gcc
    OPENMPI_VERSION=1.4
    FLAVOURS="OPENMPI LAM MPICH2"
    MPICH2_PATH=
    MPICH2_VERSION=
    LAM_PATH=
    LAM_VERSION=
elif [ "x$OSTYPE" = "xsl6" ] ; then
    OPENMPI_PATH=/usr/lib64/openmpi
    OPENMPI_VERSION=1.5.3
    FLAVOURS="OPENMPI MPICH2"
    MPICH2_PATH=/usr/lib64/mpich2
    MPICH2_VERSION=1.2.1
else
    # debian
    FLAVOURS="OPENMPI MPICH2 LAM MPICH"
    LAM_PATH=/usr
    LAM_VERSION=7.1.2
    MPICH2_PATH=/usr
    MPICH2_VERSION=1.2.1.1
    MPICH_PATH=/usr/lib/mpich
    MPICH_VERSION=1.2.7
    OPENMPI_PATH=/usr
    OPENMPI_VERSION=1.4.2
fi

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
echo "** Configure basic CE (no MPI variables)"
echo "*"
configure_ok -n WN


# wrong configurations
# wrong path
echo "*******************************************"
echo " wrong path"
echo "*******************************************"
cat /etc/yaim/site-info.def.orig > /etc/yaim/site-info.def
cat >> /etc/yaim/site-info.def << EOF
#### MPI CONFIGURATION
MPI_OPENMPI_ENABLE="yes"
MPI_OPENMPI_PATH="/this/goes/nowhere"
EOF
cat /etc/yaim/site-info.def | grep MPI
configure_and_fail

# unknown flavor
echo "*******************************************"
echo " unknown flavor"
echo "*******************************************"
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
echo "*******************************************"
echo " uninstalled flavor"
echo "*******************************************"

if [ "x$OSTYPE" = "xdeb6" ] ; then
    # uninstall the flavor
    apt-get -qy remove mpich-bin
fi

cat /etc/yaim/site-info.def.orig > /etc/yaim/site-info.def
cat >> /etc/yaim/site-info.def << EOF
#### MPI CONFIGURATION
MPI_MPICH_ENABLE="yes"
EOF
cat /etc/yaim/site-info.def | grep MPI
configure_and_fail

if [ "x$OSTYPE" = "xdeb6" ] ; then
    # uninstall the flavor
    apt-get -qy install mpich-bin
fi

# just openmpi
echo "*******************************************"
echo " openmpi only"
echo "*******************************************"
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
MPI_OPENMPI_PATH=$OPENMPI_PATH
MPI_OPENMPI_VERSION=$OPENMPI_VERSION
EOF
diff_configs /tmp/env

# openmpi with version
echo "*******************************************"
echo " openmpi + version"
echo "*******************************************"
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
MPI_OPENMPI_PATH=$OPENMPI_PATH
MPI_OPENMPI_VERSION=3.4.5
EOF
diff_configs /tmp/env

# openmpi with version and path
echo "*******************************************"
echo " openmpi + version + path"
echo "*******************************************"
cat /etc/yaim/site-info.def.orig > /etc/yaim/site-info.def
cat >> /etc/yaim/site-info.def << EOF
#### MPI CONFIGURATION
MPI_OPENMPI_ENABLE="yes"
MPI_OPENMPI_VERSION=3.4.5
MPI_OPENMPI_PATH=$OPENMPI_PATH
EOF
configure_ok
cat /etc/yaim/site-info.def | grep MPI
cat > /tmp/env << EOF
I2G_MPI_START=/usr/bin/mpi-start
MPI_DEFAULT_FLAVOUR=openmpi
MPI_OPENMPI_PATH=$OPENMPI_PATH
MPI_OPENMPI_VERSION=3.4.5
EOF
diff_configs /tmp/env

# shared home: no
echo "*******************************************"
echo " no shared path" 
echo "*******************************************"
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
MPI_OPENMPI_PATH=$OPENMPI_PATH
MPI_OPENMPI_VERSION=$OPENMPI_VERSION
MPI_SHARED_HOME=no
EOF
diff_configs /tmp/env

# shared home: yes
echo "*******************************************"
echo " shared path" 
echo "*******************************************"
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
MPI_OPENMPI_PATH=$OPENMPI_PATH
MPI_OPENMPI_VERSION=$OPENMPI_VERSION
MPI_START_SHARED_FS=1
EOF
diff_configs /tmp/env

# shared home: yes + path
echo "*******************************************"
echo " shared path + path" 
echo "*******************************************"
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
MPI_OPENMPI_PATH=$OPENMPI_PATH
MPI_OPENMPI_VERSION=$OPENMPI_VERSION
MPI_SHARED_HOME_PATH=/tmp
MPI_SHARED_HOME=yes
EOF
diff_configs /tmp/env

# all available flavours (openmpi + mpich2 + lam + mpich)
echo "*******************************************"
echo " All available flavors: $FLAVOURS" 
echo "*******************************************"
cat /etc/yaim/site-info.def.orig > /etc/yaim/site-info.def
for f in $FLAVOURS; do
    echo "MPI_${f}_ENABLE=yes" >>  /etc/yaim/site-info.def 
done
configure_ok
cat /etc/yaim/site-info.def | grep MPI
cat > /tmp/env << EOF
I2G_MPI_START=/usr/bin/mpi-start
MPI_DEFAULT_FLAVOUR=openmpi
EOF
for f in $FLAVOURS; do
    VALUE=`eval echo \\$${f}_PATH`
    echo "MPI_${f}_PATH=$VALUE" >>  /tmp/env
    VALUE=`eval echo \\$${f}_VERSION`
    echo "MPI_${f}_VERSION=$VALUE" >>  /tmp/env
done
sort /tmp/env > /tmp/env2
diff_configs /tmp/env2

echo "*"
echo "* Testing"
echo "*"
# complete testing of mpi-start
# version
echo "** mpi-start version"
mpi-start -V

echo "** Run mpi-start tests" 
wget -q https://devel.ifca.es/hg/mpi-start/archive/tip.tar.gz --no-check-certificate -O - | tar -xzf - -C /tmp
mv /tmp/mpi-start-* /tmp/mpi-start
cat /tmp/mpi-start/tests/run_tests.sh | \
    sed 's/RUN_OMP_TESTS=0/RUN_OMP_TESTS=1/' > /tmp/mpi-start/tests/runner.sh
for f in $FLAVOURS; do 
    cat /tmp/mpi-start/tests/run_tests.sh | \
        sed "s/RUN_${f}_TESTS=0/RUN_${f}_TESTS=1/" > /tmp/mpi-start/tests/runner.sh
done
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
