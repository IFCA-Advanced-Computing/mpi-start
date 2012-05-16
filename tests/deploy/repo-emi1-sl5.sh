#!/bin/sh
# installation script for WN on sl5 + emi2 

################
# REPO CONFIG  #
################

echo "*"
echo "* Repository Configuration"
echo "*"

echo "** Epel"
wget http://download.fedoraproject.org/pub/epel/5/i386/epel-release-5-4.noarch.rpm
yum --nogpg -q -y localinstall epel-release-5-4.noarch.rpm
if [ $? -ne 0 ] ; then exit 1; fi

echo "** Trust Anchors"
wget http://repository.egi.eu/sw/production/cas/1/current/repo-files/egi-trustanchors.repo -O /etc/yum.repos.d/egi-trust.repo

echo "***          emi 1"
wget http://emisoft.web.cern.ch/emisoft/dist/EMI/1/sl5/x86_64/updates/emi-release-1.0.1-1.sl5.noarch.rpm 
yum --nogpg -q -y localinstall emi-release-1.0.1-1.sl5.noarch.rpm
if [ $? -ne 0 ] ; then exit 1; fi

## update 
echo "** YUM Update + install CAs"
yum --nogpg -q -y update
yum --nogpg -q -y install ca-policy-egi-core
if [ $? -ne 0 ] ; then exit 1; fi

echo "******************************************************"
echo " REPO CONFIG OK!"
echo "******************************************************"
exit 0
