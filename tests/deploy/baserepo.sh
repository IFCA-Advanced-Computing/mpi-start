#!/bin/sh
# installation script for WN on sl5 + emi2 

################
# REPO CONFIG  #
################

echo "*"
echo "* Base repo configuration"
echo "*"

# 1, 2
EMIRELEASE=$1 
# sl5, sl6
OSTYPE=$2
# ce, wn
TYPE=$3

echo "** EPEL"
if [ "$OSTYPE" = "sl5" ] ; then
    EPEL_RPM=epel-release-5-4.noarch.rpm
    EPEL_URL=http://download.fedoraproject.org/pub/epel/5/i386
else
    EPEL_URL=http://download.fedoraproject.org/pub/epel/6/x86_64
    EPEL_RPM=epel-release-6-7.noarch.rpm
fi
wget -nv "$EPEL_URL/$EPEL_RPM"
yum -q -y localinstall $EPEL_RPM 
if [ $? -ne 0 ] ; then exit 1; fi

if [ $EMIRELEASE != 3 ] ; then
    echo "** EMI Release repo"
    EMI_URL=http://emisoft.web.cern.ch/emisoft/dist/EMI/$EMIRELEASE/$OSTYPE/x86_64/base
    if [ "$EMIRELEASE" = "1" ] ; then
        EMI_URL=http://emisoft.web.cern.ch/emisoft/dist/EMI/$EMIRELEASE/$OSTYPE/x86_64/updates
        EMI_RPM=emi-release-${EMIRELEASE}.0.1-1.$OSTYPE.noarch.rpm
    else
        EMI_RPM=emi-release-${EMIRELEASE}.0.0-1.$OSTYPE.noarch.rpm
    fi
    wget -nv "$EMI_URL/$EMI_RPM"
    yum -q -y localinstall $EMI_RPM 
    if [ $? -ne 0 ] ; then exit 1; fi
fi

echo "** EGI Trust Anchors"
CA_URL=http://repository.egi.eu/sw/production/cas/1/current/repo-files/egi-trustanchors.repo
DEST=/etc/yum.repos.d/egi-trust.repo
wget -nv $CA_URL -O $DEST 

## update 
echo "** YUM Update"
yum -q -y update
echo "** Install CAs"
yum -q -y install lcg-CA ca-policy-egi-core
if [ $? -ne 0 ] ; then exit 1; fi

echo "******************************************************"
echo " BASIC REPO CONFIG OK!"
echo "******************************************************"
exit 0
