#!/bin/sh

# check mktemp
export MYMKTEMP="mktemp"
TMPFILE=`$MYMKTEMP 2> /dev/null`
if test $? -ne 0 ; then
    export MYMKTEMP="mktemp -t MPI_START_TESTS"
    TMPFILE=`$MYMKTEMP 2> /dev/null`
    if test $? -ne 0 ; then
        echo "Unable to find good mktemp!?"
        exit 0
    fi
fi
rm -f $TMPFILE    



DOWNLOAD_MY_SHUNIT=1
REMOVE_MY_SHUNIT=0

# tests to run
RUN_BASIC_TESTS=1
RUN_HOOK_TESTS=1
RUN_SCH_TESTS=1
# if running these tests, ensure you have proper environment loaded!
RUN_OMP_TESTS=0
RUN_MPICH2_TESTS=0
RUN_MPICH_TESTS=0
RUN_OPENMPI_TESTS=0
RUN_LAM_TESTS=0

#
# Check environment variables
#
if test "x${SHUNIT2}" = "x" ; then
    if test "x${DOWNLOAD_MY_SHUNIT}" = "x1"; then
        wget -q http://devel.ifca.es/~enol/depot/shunit2 -O shunit2 --no-check-certificate 
        st=$?
        if test $st -ne 0 ; then
            echo "Could not download shunit, please set SHUNIT2 env variable to the correct location."
            exit 1
        fi
        export SHUNIT2=$PWD/shunit2
        REMOVE_MY_SHUNIT=1
    else
        echo "SHUNIT2 environment variable not defined!"
        echo "Please set it to the location of shunit2 script"
        exit 1
    fi
fi

if test "x${I2G_MPI_START}" = "x" ; then
    type mpi-start &> /dev/null
    if test $? -ne 0 ; then
        echo "I2G_MPI_START environment variable not defined!"
        echo "Please set it to the location of MPI-Start binary"
        exit 1
    else
        export I2G_MPI_START=mpi-start
    fi
fi

echo 
echo "** Using $I2G_MPI_START for testing! **"
echo 

#
# Run all the tests in the directory
#
exitcode=0
if test "x${RUN_BASIC_TESTS}" = "x1" ; then
    echo "*******************"
    echo "    Basic Tests"
    echo "*******************"
    ./test_basic.sh || exitcode=1
fi
if test "x${RUN_HOOK_TESTS}" = "x1" ; then
    echo
    echo "*******************"
    echo "    Hook Tests"
    echo "*******************"
    ./test_hooks.sh || exitcode=1
fi
if test "x${RUN_SCH_TESTS}" = "x1" ; then
    echo
    echo "*******************"
    echo "  Scheduler Tests"
    echo "*******************"
    ./test_scheduler.sh || exitcode=1
fi
if test "x${RUN_OMP_TESTS}" = "x1" ; then
    echo
    echo "*******************"
    echo "     OMP Tests"
    echo "*******************"
    ./test_omp.sh || exitcode=1
fi
if test "x${RUN_MPICH2_TESTS}" = "x1" ; then
    echo
    echo "*******************"
    echo "   MPICH2 Tests"
    echo "*******************"
    export MPICC=mpicc.mpich2
    export MPICC_OPTS=
    export I2G_MPI_TYPE=mpich2
    ./test_mpi.sh || exitcode=1
fi
if test "x${RUN_MPICH_TESTS}" = "x1" ; then
    echo
    echo "*******************"
    echo "     MPICH Tests"
    echo "*******************"
    export MPI_MPICH_PATH=/usr/lib/mpich
    export MPICC=mpicc
    export MPICC_OPTS=
    export I2G_MPI_TYPE=mpich
    ./test_mpi.sh || exitcode=1
fi
if test "x${RUN_OPENMPI_TESTS}" = "x1" ; then
    echo
    echo "*******************"
    echo "  Open MPI Tests"
    echo "*******************"
    export MPICC=mpicc.openmpi
    export MPICC_OPTS=
    export I2G_MPI_TYPE=openmpi
    export MPI_OPENMPI_MPIEXEC=mpiexec.openmpi
    ./test_mpi.sh || exitcode=1
fi
if test "x${RUN_LAM_TESTS}" = "x1" ; then
    echo
    echo "*******************"
    echo "     LAM Tests"
    echo "*******************"
    export MPICC=mpicc.lam
    export MPICC_OPTS=
    export I2G_MPI_TYPE=lam
    export MPI_LAM_MPIRUN=mpirun.lam
    ./test_mpi.sh || exitcode=1
fi


if test $REMOVE_MY_SHUNIT -eq 1 ; then
    rm $SHUNIT2
fi

exit $exitcode 
