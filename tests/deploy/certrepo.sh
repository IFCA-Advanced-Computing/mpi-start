#!/bin/sh

################
# REPO CONFIG  #
################

echo "*"
echo "* Certification REPO"
echo "*"

# 1, 2
EMIRELEASE=$1 
# sl5, sl6
OSTYPE=$2
# ce, wn
TYPE=$3

cp cert-emi$EMIRELEASE-$OSTYPE.repo /etc/yum.repos.d/cert.repo

echo "** EMI $EMIRELEASE $OSTYPE RC ->"
cat /etc/yum.repos.d/cert.repo

yum -q -y update

echo "******************************************************"
echo " CERTIFICATION REPO CONFIG OK!"
echo "******************************************************"
exit 0
