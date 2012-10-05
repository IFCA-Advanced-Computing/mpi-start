#!/bin/sh

# 1, 2
EMIRELEASE=$1 
# sl5, sl6
OSTYPE=$2
# ce, wn
TYPE=$3


CONFIG_PROFILES="-n MPI_CE -n creamCE -n TORQUE_server"

configure_ok() {
    /opt/glite/yaim/bin/yaim -s /etc/yaim/site-info.def -c $CONFIG_PROFILES >& /dev/null
    if [ $? -ne 0 ] ; then
        echo "******************************************************"
        echo "ERROR Configuring CE" 
        echo "******************************************************"
        exit 1
    else
        echo "* --> Configuration completed OK" 
    fi
}

configure_and_fail () {
    /opt/glite/yaim/bin/yaim -s /etc/yaim/site-info.def -c $CONFIG_PROFILES >& /dev/null
    if [ $? -eq 0 ] ; then
        echo "******************************************************"
        echo "Expected ERROR Configuring CE, and was success"
        echo "******************************************************"
        exit 1
    else
        echo "* --> Configuration failed as expected" 
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
echo "* Basic configuration (PRE UPDATE)"
echo "*"

mkdir -p /etc/grid-security
cp hostcert.pem  /etc/grid-security/hostcert.pem
cp hostkey.pem /etc/grid-security/hostkey.pem

echo "** MUNGE"
if [ ! -f /etc/munge/munge.key ] ; then
	create-munge-key
fi
service munge restart

echo "** Get yaim profiles"
wget -q http://devel.ifca.es/~enol/depot/yaim.tgz --no-check-certificate -O - | tar xzf - -C /etc/

chmod -R 750 /etc/yaim

# Add our host to wn-list
echo "test14.egi.cesga.es" > /etc/yaim/wn-list.conf
echo "test15.egi.cesga.es" >> /etc/yaim/wn-list.conf

PASSWORDS="MYSQL_PASSWORD  CREAM_DB_PASSWORD"

if [ -f /etc/yaim/site-info.def.orig ] ; then
	for p in $PASSWORDS ; do 
		grep $p /etc/yaim/site-info.def.orig >> /etc/yaim/site-info.def
	done
fi

for p in $PASSWORDS ; do
	grep $p /etc/yaim/site-info.def > /dev/null
	if [ $? -ne 0 ] ; then
		echo "${p}=my_${RANDOM}_long_password" >> /etc/yaim/site-info.def
        fi
done

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

echo "******************************************************"
echo " BASIC CONFIGURATION SUCCEDED!"
echo "******************************************************"
exit 0
