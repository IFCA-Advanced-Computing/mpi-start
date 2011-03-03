#!/bin/bash

#
# Copyright (c) 2006-2007 High Performance Computing Center Stuttgart, 
#                         University of Stuttgart.  All rights reserved. 
#


generic_mpi_start () {
    info_msg "start program with mpirun"

    # source hook file
    . $MPI_START_ETC/mpi-start.hooks

    # call pre run hook
    mpi_start_pre_run_hook

    info_msg "=[START]================================================================" 

    # start it
    mpi_exec
    err=$?

    info_msg "=[FINISHED]============================================================="

    # call pre run hook
    mpi_start_post_run_hook

    return $err
}

