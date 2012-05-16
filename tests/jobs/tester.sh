#!/bin/sh

if [ "x$I2G_MPI_START" != "x" ] ; then 
    echo I2G_MPI_START is defined as $I2G_MPI_START 
fi

mpi-start /bin/hostname
