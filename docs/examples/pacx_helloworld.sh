#!/bin/sh

cd /tmp/pacx

export I2G_MPI_TYPE=pacx
export I2G_MPI_FLAVOUR=openmpi
export I2G_MPI_APPLICATION=/tmp/pacx/hello
export I2G_MPI_APPLICATION_ARGS=
export I2G_MPI_NP=1
export I2G_MPI_JOB_NUMBER=0
export I2G_MPI_STARTUP_INFO=localhost:31500
export I2G_MPI_PRECOMMAND=
export I2G_MPI_RELAY=localhost

$I2G_MPI_START
