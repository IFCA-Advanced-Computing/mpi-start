#!/bin/sh

echo "*"
echo "* Repository Configuration"
echo "*"

echo "** CAs"
wget -q -O - \
     https://dist.eugridpma.info/distribution/igtf/current/GPG-KEY-EUGridPMA-RPM-3 \
     | apt-key add -
echo "deb http://repository.egi.eu/sw/production/cas/1/current egi-igtf core" > /etc/apt/sources.list.d/cas.list

echo "** emi 2 (rc4)"
wget --no-check-certificate https://twiki.cern.ch/twiki/pub/EMI/EMI-2/emi-2-rc4-deb6.list -O /etc/apt/sources.list.d/emi2.list

echo "******************************************************"
echo " REPO CONFIG OK!"
echo "******************************************************"
exit 0
