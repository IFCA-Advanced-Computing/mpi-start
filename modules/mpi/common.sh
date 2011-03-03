#!/bin/bash

#======================================================================
# Look for the appropriate mpirun/mpiexec  
#======================================================================
mpi_start_search_mpiexec () {

    MPI_SPECIFIC_PARAMS=""
    MPI_MPIEXEC=""
    MPI_MPIRUN=""

    MPI_TYPE=`echo $I2G_MPI_TYPE | tr "[:lower:]" "[:upper:]" | tr "-" "_"`

    VALUE=`eval echo \\$MPI_${MPI_TYPE}_MPIEXEC`
    if test ! -z "$VALUE" ; then
        MPI_MPIEXEC=$VALUE
        debug_msg "using user supplied mpiexec: '$MPI_MPIEXEC'"
    else
        VALUE=`eval echo \\$MPI_${MPI_TYPE}_MPIRUN`
        if test ! -z "$VALUE" ; then
            MPI_MPIRUN=$VALUE
            debug_msg "using user supplied mpirun: '$MPI_MPIRUN'"
        else
            # define both 
            MPI_MPIEXEC=`which mpiexec 2> /dev/null`
            if test $? -eq 0 ; then
                debug_msg "using system default mpiexec: '$MPI_MPIEXEC'"
            fi
            MPI_MPIRUN=`which mpirun 2> /dev/null`
            if test $? -eq 0 ; then
                debug_msg "using system default mpirun: '$MPI_MPIRUN'"
            fi
        fi
    fi
    if test "x$MPI_MPIEXEC" != "x"; then
        MPI_SPECIFIC_MPIEXEC_PARAMS=`eval echo \\$MPI_${MPI_TYPE}_MPIEXEC_PARAMS`
    elif test "x$MPI_MPIRUN" != "x"; then
        MPI_SPECIFIC_MPIRUN_PARAMS=`eval echo \\$MPI_${MPI_TYPE}_MPIRUN_PARAMS`
    else
        debug_msg "no mpiexec/mpirun found!"
    fi
}
