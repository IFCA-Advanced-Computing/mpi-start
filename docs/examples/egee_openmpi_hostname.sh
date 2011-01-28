#!/bin/sh

cp -f /bin/hostname hostname_openmpi

#setup EGEE environment
export MPI_DEFAULT_FLAVOUR=openmpi
export MPI_OPENMPI_PATH=/opt/i2g/openmpi
export MPI_OPENMPI_VERSION=1.1.2
export MPI_OPENMPI_COMPILER=gcc

#export I2G_MPI_TYPE=openmpi
#export I2G_MPI_FLAVOUR=openmpi
export I2G_MPI_APPLICATION=hostname_openmpi
export I2G_MPI_APPLICATION_ARGS=
export I2G_MPI_NP=4
export I2G_MPI_JOB_NUMBER=0
export I2G_MPI_STARTUP_INFO=
export I2G_MPI_PRECOMMAND=
export I2G_MPI_RELAY=

$I2G_MPI_START
