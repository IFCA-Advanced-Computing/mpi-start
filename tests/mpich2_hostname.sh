#!/bin/sh

cp -f /bin/hostname hostname_mpich2

export I2G_MPI_TYPE=mpich2
export I2G_MPI_FLAVOUR=mpich2
export I2G_MPI_APPLICATION=$PWD/hostname_mpich2
export I2G_MPI_APPLICATION_ARGS=
export I2G_MPI_NP=4
export I2G_MPI_JOB_NUMBER=0
export I2G_MPI_STARTUP_INFO=
export I2G_MPI_PRECOMMAND=
export I2G_MPI_RELAY=

$I2G_MPI_START

