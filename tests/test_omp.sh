#!/bin/bash

#
# Tests for MPI-Start with OpenMP 
#

oneTimeSetUp () {
    OMP_SRC_CODE=`$MYMKTEMP`
    cat > $OMP_SRC_CODE << EOF
#include <omp.h>
#include <stdio.h>
#include <stdlib.h>
#define CHUNKSIZE   10
#define N       100

int main (int argc, char *argv[]) {
    int nthreads, tid, i, chunk;
    float a[N], b[N], c[N];

    /* Some initializations */
    for (i=0; i < N; i++)
        a[i] = b[i] = i * 1.0;
    chunk = CHUNKSIZE;

    #pragma omp parallel shared(a,b,c,nthreads,chunk) private(i,tid)
    {
        tid = omp_get_thread_num();
        if (tid == 0)
        {
            nthreads = omp_get_num_threads();
            printf("Number of threads = %d\n", nthreads);
        }
        fprintf(stderr, "Thread %d starting...\n",tid);

        #pragma omp for schedule(dynamic,chunk)
        for (i=0; i<N; i++)
        {
            c[i] = a[i] + b[i];
            fprintf(stderr, "Thread %d: c[%d]= %f\n",tid,i,c[i]);
        }
    }  /* end of parallel section */
    return 0;
}
EOF
    OMP_BIN=`$MYMKTEMP`
    gcc -fopenmp -x c $OMP_SRC_CODE -o $OMP_BIN
}

oneTimeTearDown () {
    rm -f $OMP_SRC_CODE $OMP_BIN
}

setUp () {
    export I2G_MPI_TYPE="dummy"
    unset I2G_MPI_NP
    unset I2G_MPI_APPLICATION
    unset I2G_MPI_START_DEBUG
    unset I2G_MPI_START_VERBOSE
    unset I2G_MPI_START_TRACE
    unset I2G_MPI_SINGLE_PROCESS
    export MPI_START_SHARED_FS=1
}

testPreCompiledOMP () {
    # force the number of threads? 
    OUTPUT=`$I2G_MPI_START -d MPI_USE_OMP=1 -t dummy -d MPI_DUMMY_SCH_SLOTS=2 -e /dev/null $OMP_BIN`
    st=$?
    assertEquals 0 $st
    assertEquals "Number of threads = 2" "$OUTPUT"
}

testUnCompiledOMP () {
    myhook=`$MYMKTEMP`
    cat > $myhook << EOF
pre_run_hook () {
    export I2G_MPI_APPLICATION=`$MYMKTEMP`
    gcc -fopenmp -x c $OMP_SRC_CODE -o \$I2G_MPI_APPLICATION
}

post_run_hook () {
    rm \$I2G_MPI_APPLICATION
}
EOF
    # force the number of threads? 
    OUTPUT=`$I2G_MPI_START -d MPI_USE_OMP=1 -t dummy -d MPI_DUMMY_SCH_SLOTS=2 \
            -pre $myhook -post $myhook -e /dev/null`
    st=$?
    assertEquals 0 $st
    assertEquals "Number of threads = 2" "$OUTPUT"
    rm -f $myhook
}

. $SHUNIT2
