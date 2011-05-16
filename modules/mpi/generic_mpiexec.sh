#!/bin/bash

#
# Copyright (c) 2006-2007 High Performance Computing Center Stuttgart, 
#                         University of Stuttgart.  All rights reserved. 
#

generic_mpiexec() {
    CMD="$I2G_MPI_PRECOMMAND $MPIEXEC $MPI_GLOBAL_PARAMS $MPI_LOCAL_PARAMS $I2G_MPI_APPLICATION $I2G_MPI_APPLICATION_ARGS"
    debug_msg "=> MPI_GLOBAL_PARAMS=$MPI_GLOBAL_PARAMS"
    debug_msg "=> MPI_LOCAL_PARAMS=$MPI_LOCAL_PARAMS"
    debug_msg $CMD
    mpi_start_execute_wrapper $CMD
    err=$?
    return $err
}
