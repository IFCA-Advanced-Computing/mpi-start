#!/bin/bash

#
# Tests for ticket #38. 
#

export I2G_MPI_START_ENABLE_TESTING="TEST"
# source the mpi-start code to have all functions
. $I2G_MPI_START
mpi_start_check_options

export MPI_OPENMPI_MPIEXEC=`$MYMKTEMP`
cat > $MPI_OPENMPI_MPIEXEC << EOF
#/bin/sh
exit 0
EOF
chmod +x $MPI_OPENMPI_MPIEXEC

MPI_START_SCHEDULER="pbs"
MPI_START_DISABLE_LRMS_INTEGRATION="no"


testBug38() {
    # load openmpi
    . $MPI_START_ETC/openmpi.mpi
    mpi_exec
    $MPI_OPENMPI_INFO --parseable | grep "pls:tm" &> /dev/null
    if test $? -eq 0 ; then
        out=`echo $MPI_GLOBAL_PARAMS | grep -v "machinefile"`
    else
        out=`echo $MPI_GLOBAL_PARAMS | grep "machinefile"`
    fi
    assertNotNull "$out"
    rm $MPI_OPENMPI_MPIEXEC
}

. $SHUNIT2
