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
    echo "I2G_MPI_START environment variable not defined!"
    echo "Please set it to the location of MPI-Start binary"
    exit 1
fi

#
# Run all the tests in the directory
#
exitcode=0
echo "Basic Tests"
./test_basic.sh || exitcode=1
echo "Hook Tests"
./test_hooks.sh || exitcode=1
echo "Scheduler Tests"
./test_scheduler.sh || exitcode=1
if test "x${RUN_OMP_TESTS}" = "x1" ; then
    echo "Open MP Tests"
    ./test_omp.sh || exitcode=1
fi

if test $REMOVE_MY_SHUNIT -eq 1 ; then
    rm $SHUNIT2
fi

exit $exitcode 
