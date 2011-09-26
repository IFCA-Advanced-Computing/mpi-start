#!/bin/sh
# script for generating the etics build artifacts
set -x

prefix=$1

if [ "x$prefix" = "x" ] ; then
    echo "Unable to build without a prefix"
    exit 1
fi

shift

version=$1

if [ "x$version" = "x" ] ; then
    version=`cat VERSION`
fi

BASEDIR=$PWD

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

# Debian?

exit 0
