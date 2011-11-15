#!/bin/bash

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
#include <string.h>

int main (int argc, char *argv[]) {
    int myid, numprocs;
    int err=0;

    MPI_Init(&argc,&argv);
    MPI_Comm_size(MPI_COMM_WORLD,&numprocs);
    MPI_Comm_rank(MPI_COMM_WORLD,&myid);
    if (myid == 0) {
        printf("NP = %d", numprocs);
    }

    if (argc > 1) {
        /* Environ variable checks */
        int i;
        for (i = 1; i < argc; i += 2) {
            char *env = getenv(argv[i]);
            if (!env) {
                fprintf(stderr, "%s not defined!\n", argv[i]);
                err=51;
            } else {
                if (i + 1 >= argc) continue;
                if (strcmp(env, argv[i + 1])) {
                    fprintf(stderr, "%s value is not %s!\n", argv[i], argv[i+1]);
                    err=51;
                }
            }
        }
    }
    MPI_Finalize();
    return err;
}
EOF
    myhook=$MPI_TEST_DIR/hook.sh
    cat > $myhook << EOF
pre_run_hook () {
    export I2G_MPI_APPLICATION=\$MPI_TEST_DIR/app
    \$MPI_MPICC \$MPICC_OPTS -x c \$MPI_SRC_CODE -o \$I2G_MPI_APPLICATION
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
    unset I2G_MPI_APPLICATION_ARGS
    export MPI_START_SHARED_FS=1
}

testMPILocation() {
    otherhook=$MPI_TEST_DIR/otherhook.sh
    cat > $otherhook << EOF
pre_run_hook () {
    echo \$MPI_START_MPI_PREFIX
    return 1
}
EOF
    OUTPUT=`$I2G_MPI_START -pre $otherhook 2> /dev/null`
    st=$?
    assertNotNull "$OUTPUT"
    assertEquals 1 $st
    echo "Using $OUTPUT as MPI prefix"
}


testMPICompiler() {
    otherhook=$MPI_TEST_DIR/otherhook.sh
    cat > $otherhook << EOF
pre_run_hook () {
    echo \$MPI_MPICC
    return 1
}
EOF
    OUTPUT=`$I2G_MPI_START -pre $otherhook 2> /dev/null`
    st=$?
    assertNotNull "$OUTPUT"
    assertEquals 1 $st
    echo "Using $OUTPUT for compiling the application"
}


testMPISource() {
    unset FOOBARVAR
    export I2G_MPI_APPLICATION_ARGS="FOOBARVAR foo"
    ERR=`$MYMKTEMP`
    OUTPUT=`$I2G_MPI_START -x FOOBARVAR=foo -np 2 -e $ERR -pre $myhook`
    st=$?
    if [ $I2G_MPI_TYPE = "mpich" ] ; then
        assertEquals "NP = 2" "$OUTPUT"
    else
        assertEquals 0 $st
        assertEquals "NP = 2" "$OUTPUT"
        assertNull "`cat $ERR`"
    fi
    rm -rf $ERR
}

# this test goes after the source test so we have the application compiled in the right env.
testMPIBinary () {
    unset FOOBARVAR
    export I2G_MPI_APPLICATION_ARGS="FOOBARVAR foo"
    ERR=`$MYMKTEMP`
    OUTPUT=`$I2G_MPI_START -x FOOBARVAR=foo -np 2 -e $ERR $MPI_TEST_DIR/app`
    st=$?
    if [ $I2G_MPI_TYPE = "mpich" ] ; then
        assertEquals "NP = 2" "$OUTPUT"
    else
        assertEquals 0 $st
        assertEquals "NP = 2" "$OUTPUT"
        assertNull "`cat $ERR`"
    fi
    rm -rf $ERR
}

. $SHUNIT2
