#!/bin/sh

#
# Tests for MPI-Start with MPI
#

oneTimeSetUp () {
    export MPI_TEST_DIR=`$MYMKTEMP -d`
    export MPI_SRC_CODE=$MPI_TEST_DIR/test.c
    cat > $MPI_SRC_CODE << EOF
#include <mpi.h>
#include <stdio.h>
#include <stdlib.h>

int main (int argc, char *argv[]) {
    int myid, numprocs;

    MPI_Init(&argc,&argv);
    MPI_Comm_size(MPI_COMM_WORLD,&numprocs);
    MPI_Comm_rank(MPI_COMM_WORLD,&myid);

    if (myid == 0) {
        printf("NP = %d", numprocs);
    }

    MPI_Finalize();
    return 0;
}
EOF
    myhook=$MPI_TEST_DIR/hook.sh
    cat > $myhook << EOF
pre_run_hook () {
    export I2G_MPI_APPLICATION=\$MPI_TEST_DIR/app
    \$MPICC \$MPICC_OPTS -x c \$MPI_SRC_CODE -o \$I2G_MPI_APPLICATION
}
EOF
}

oneTimeTearDown () {
    rm -rf $MPI_TEST_DIR
}

setUp () {
    unset I2G_MPI_NP
    unset I2G_MPI_APPLICATION
    unset I2G_MPI_START_DEBUG
    unset I2G_MPI_START_VERBOSE
    unset I2G_MPI_START_TRACE
    unset I2G_MPI_SINGLE_PROCESS
    export MPI_START_SHARED_FS=1
}


testMPISource() {
    OUTPUT=`$I2G_MPI_START -np 2 -e /dev/null -pre $myhook`
    st=$?
    assertEquals 0 $st
    assertEquals "NP = 2" "$OUTPUT"
}

# this test goes after the source test so we have the application compiled in the right env.
testMPIBinary () {
    OUTPUT=`$I2G_MPI_START -np 2 -e /dev/null $MPI_TEST_DIR/app`
    st=$?
    assertEquals 0 $st
    assertEquals "NP = 2" "$OUTPUT"
}

. $SHUNIT2
