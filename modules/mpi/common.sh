#!/bin/sh

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
            MPI_MPIEXEC=`which mpiexec 2> /dev/null`
            if test $? -ne 0 ; then
                MPI_MPIRUN=`which mpirun 2> /dev/null`
                debug_msg "using system default mpirun: '$MPI_MPIRUN'"
            else
                debug_msg "using system default mpiexec: '$MPI_MPIEXEC'"
            fi
        fi
    fi
    if test "x$MPI_MPIEXEC" != "x"; then
        MPI_SPECIFIC_PARAMS=`eval echo \\$MPI_${MPI_TYPE}_MPIEXEC_PARAMS`
    elif test "x$MPI_MPIRUN" != "x"; then
        MPI_SPECIFIC_PARAMS=`eval echo \\$MPI_${MPI_TYPE}_MPIRUN_PARAMS`
    else
        debug_msg "no mpiexec/mpirun found!"
    fi
}
