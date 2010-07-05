#!/bin/sh

set -x

echo "Print environment"
env

echo "List : $AUTOBUILD_PACKAGE_ROOT"
ls -al $AUTOBUILD_PACKAGE_ROOT

VERSION=`cat VERSION`

TMPDIR=/var/tmp
if test "x$AUTOBUILD_INSTALL_ROOT" != "x" ; then
    TMPDIR=$AUTOBUILD_INSTALL_ROOT
fi

make dist
rpmbuild --define "_topdir $AUTOBUILD_PACKAGE_ROOT/rpm/" --define "_tmppath $TMPDIR" -ta i2g-mpi-start-$VERSION.tar.gz

