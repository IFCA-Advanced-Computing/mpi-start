#!/bin/bash

oneTimeSetUp () {
    export I2G_MPI_START_ENABLE_TESTING="TEST"
    # source the mpi-start code to have all functions
    . $I2G_MPI_START
    mpi_start_find_mktemp
}

oneTimeTearDown () {
    clean_up
}

testLocalTempDir() {
    mpi_start_mktemp
    st=$?
    assertEquals "0" "$?"
    DIR_TEMP_FILE_1=`dirname $MPI_START_TEMP_FILE`
    DIR_TEMP_FILE=`dirname $DIR_TEMP_FILE_1`
    assertEquals "$PWD" "$DIR_TEMP_FILE"
}

testFakeTempDir () {
    TEMP_DIR=`$MYMKTEMP -d`
    MPI_START_TEMP_DIR=$TEMP_DIR mpi_start_mktemp
    st=$?
    assertEquals "0" "$?"
    DIR_TEMP_FILE=`dirname $MPI_START_TEMP_FILE`
    assertEquals "$TEMP_DIR" "$DIR_TEMP_FILE"
    rm -rf $TEMP_DIR
}

. $SHUNIT2
