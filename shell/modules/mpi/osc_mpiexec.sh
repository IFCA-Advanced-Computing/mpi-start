#!/bin/sh
#
# Copyright (c) 2006-2007 High Performance Computing Center Stuttgart, 
#                         University of Stuttgart.  All rights reserved. 
# Copyright (c) 2009-2010 Instituto de Fisica de Cantabria,
#                         CSIC-UC. All rights reserved.
#

osc_mpiexec() {

    #check if Marmot should be used
    if test "x$I2G_USE_MARMOT" = "x1" ; then
        MARMOT_INSTALLATION=/opt/i2g/marmot
        export LD_PRELOAD="$MARMOT_INSTALLATION/lib/shared/libmarmot-profile.so $MARMOT_INSTALLATION/lib/shared/libmarmot-core.so /usr/lib/libstdc++.so.5"
        #this is the path of the logfile on the last worker node
        export MARMOT_LOGFILE_PATH=/tmp
	fi

    if test "x$I2G_USE_MPITRACE" = "x1" ; then
        MPITRACE_INSTALLATION=/opt/i2g/mpitrace
        MPIEXEC="$MPITRACE_INSTALLATION/bin/mpitrace $MPIEXEC"
    fi
    CMD="$I2G_MPI_PRECOMMAND $MPIEXEC $MPI_SPECIFIC_PARAMS $I2G_MACHINEFILE_AND_NP $I2G_MPI_APPLICATION $I2G_MPI_APPLICATION_ARGS"
    debug_msg "=> MPI_SPECIFIC_PARAMS=$MPI_SPECIFIC_PARAMS"
    debug_msg $CMD
    if [ "x$I2G_MPI_APPLICATION_STDIN" != "x" -a "x$I2G_MPI_APPLICATION_STDOUT" != "x" ] ; then
        debug_msg "redirecting stdin and stdout"
        $CMD \> $I2G_MPI_APPLICATION_STDOUT < $I2G_MPI_APPLICATION_STDIN
    else
        $CMD
    fi
    err=$?
    return $err
}
