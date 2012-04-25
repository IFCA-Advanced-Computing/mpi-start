#!/bin/sh
# installation script for WN on sl5 + emi2 

################
# REPO CONFIG  #
################
set -x

echo "*"
echo "* Repository Configuration"
echo "*"

echo "** Epel"
wget http://download.fedoraproject.org/pub/epel/5/i386/epel-release-5-4.noarch.rpm
yum --nogpg -q -y localinstall epel-release-5-4.noarch.rpm
if [ $? -ne 0 ] ; then exit 1; fi

#echo "** Trust Anchors"
#wget http://repository.egi.eu/sw/production/cas/1/current/repo-files/egi-trustanchors.repo -O /etc/yum.repos.d/egi-trust.repo

echo "** emi 2"
wget --no-check-certificate  https://twiki.cern.ch/twiki/pub/EMI/EMI-2/emi-2-rc4-sl5.repo -O /etc/yum.repos.d/emi2.repo
if [ $? -ne 0 ] ; then exit 1; fi

## update 
if [ "x$1" != "xNOUPDATE"  ] ; then 
    echo "** YUM Update + install CAs"
    yum --nogpg -q -y update
    yum --nogpg -q -y install ca-policy-egi-core
    if [ $? -ne 0 ] ; then exit 1; fi
fi

echo "******************************************************"
echo " REPO CONFIG OK!"
echo "******************************************************"
exit 0
