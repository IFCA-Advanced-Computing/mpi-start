#!/bin/sh

set -x

echo "Print environment"
env

if test "x$AUTOBUILD_PACKAGE_ROOT" = "x" ; then
    export AUTOBUILD_PACKAGE_ROOT=build
fi 

for dir in SPECS RPMS SRPMS; do
    if test ! -d "$AUTOBUILD_PACKAGE_ROOT/$dir" ; then
        mkdir -p "$AUTOBUILD_PACKAGE_ROOT/$dir"
    fi
done

VERSION=`cat VERSION`

TMPDIR=/tmp
if test "x$AUTOBUILD_INSTALL_ROOT" != "x" ; then
    TMPDIR=$AUTOBUILD_INSTALL_ROOT
fi

make dist
rpmbuild --define "_topdir $AUTOBUILD_PACKAGE_ROOT/rpm/" --define "_tmppath $TMPDIR" -ta i2g-mpi-start-$VERSION.tar.gz

