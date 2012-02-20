#!/bin/sh
# script for generating the etics build artifacts
set -x

prefix=$1

if [ "x$prefix" != "x" ] ; then
    shift
    version=$1
fi

if [ "x$version" = "x" ] ; then
    version=`cat VERSION`
fi
BASEDIR=$PWD

debian_package() {
    # dest dir: debs
    DESTDIR=debs
    mkdir $BASEDIR/$DESTDIR
    make deb
    mv ../mpi-start_*.dsc $DESTDIR
    mv ../mpi-start_*.tar.gz $DESTDIR
    mv ../mpi-start_*.deb $DESTDIR
    mv ../mpi-start_*.changes $DESTDIR
}

rpm_package() {
    if [ "x$prefix" = "x" ] ; then
        echo "Unable to build without a prefix"
        exit 1
    fi

    # delete old artifacts
    rm -rf $BASEDIR/tgz $BASEDIR/RPMS

    # create destination directories
    mkdir $BASEDIR/tgz
    mkdir $BASEDIR/RPMS 

    # Binary tarball
    cd $prefix
    tar -pczf $BASEDIR/tgz/mpi-start-$version.tar.gz *
    cd $BASEDIR

    # Source tarball
    make dist
    distname=`ls *tar.gz | tail -1`
    srcname=`echo $distname | sed 's/.tar.gz/.src.tar.gz/'`
    mv $distname $BASEDIR/tgz/$srcname

    # RPMs
    make rpm
    mv rpms/RPMS/noarch/*.rpm $BASEDIR/RPMS
    mv rpms/SRPMS/*.rpm $BASEDIR/RPMS
}

DEBIAN=0
which lsb_release > /dev/null
if [ $? -eq 0 ] ; then
    lsb_release -a | egrep -i "debian|ubuntu" > /dev/null
    if [ $? -eq 0 ] ; then
        DEBIAN=1
    fi
else
    cat /etc/issue | egrep -i "debian|ubuntu" > /dev/null 
    if [ $? -eq 0 ] ; then
        DEBIAN=1
    fi
fi

if [ $DEBIAN -eq 1 ] ; then
    debian_package
else
    rpm_package
fi

exit 0
