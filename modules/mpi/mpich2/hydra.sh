#!/bin/bash

#
# Copyright (c) 2009-2010 Instituto de Fisica de Cantabria - CSIC. 
#


# start an mpi job with hydra
mpiexec_with_hydra () {
    debug_msg "Using hydra for starting mpi job"
    mpi_start_mktemp
    MACHINES=$MPI_START_TEMP_FILE
    if test "x${MPI_START_NPHOST}" != "x" ; then
        debug_msg "Creating machine file for per node option"
        for host in `cat $MPI_START_HOSTFILE` ; do 
            echo $host:$MPI_START_NPHOST >> $MACHINES
        done
    else
        # in the case of oversuscribing, hydra should know how to deal with it
        cat "$MPI_START_HOST_SLOTS_FILE" | tr " " ":" > $MACHINES
    fi
    MPI_GLOBAL_PARAMS="$MPI_GLOBAL_PARAMS $HYDRA_EXTRA_PARAMS -f $MACHINES"
    if test "x$MPI_START_DISABLE_LRMS_INTEGRATION" != "xyes"; then
        if test "x${MPI_START_SCHEDULER}" = "xpbs" ; then
            MPI_GLOBAL_PARAMS="-rmk pbs $MPI_GLOBAL_PARAMS"
        fi
    fi

    MPI_LOCAL_PARAMS="-n $MPI_START_NP"
    # set the environment variables
    if test "x${MPI_START_ENV_VARIABLES}" != "x" ; then
        local envparam=""
        local first=1
        for var in ${MPI_START_ENV_VARIABLES}; do
            if test $first -eq 0 ; then
                envparam="${envparam},${var}"
            else
                envparam="-envlist $var"
                first=0
            fi
        done
        MPI_LOCAL_PARAMS="${MPI_LOCAL_PARAMS} ${envparam}"
    fi
    mpi_start_get_plugin "generic_mpiexec.sh" 1
    . $MPI_START_PLUGIN_FILES
    generic_mpiexec
    err=$?

    return $err
}

