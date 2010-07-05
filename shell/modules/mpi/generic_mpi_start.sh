#!/bin/sh
#
# Copyright (c) 2006-2007 High Performance Computing Center Stuttgart, 
#                         University of Stuttgart.  All rights reserved. 
#


generic_mpi_start () {
    info_msg "start program with mpirun"

    # source hook file
    . $MPI_START_PREFIX/../etc/mpi-start/mpi-start.hooks

    # call pre run hook
    mpi_start_pre_run_hook

    if test "x$I2G_MPI_START_VERBOSE" = "x1" ; then
        echo "=[START]================================================================"
    fi

    # start it
    mpi_exec
    err=$?

    if test "x$I2G_MPI_START_VERBOSE" = "x1" ; then
        echo "=[FINISHED]============================================================="
    fi

    # call pre run hook
    mpi_start_post_run_hook

    return $err
}

