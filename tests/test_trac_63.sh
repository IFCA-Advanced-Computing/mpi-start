#!/bin/bash

oneTimeSetUp () {
    export I2G_MPI_START_ENABLE_TESTING="TEST"
    # source the mpi-start code to have all functions
    . $I2G_MPI_START
    mpi_start_find_mktemp
}

oneTimeTearDown () {
    for f in $MPI_START_CLEANUP_FILES; do
        [ -f "$f" ] && rm -f $f
        [ -d "$f" ] && rm -rf $f
    done
}

testWrapperinHOME() {
    mpi_start_create_wrapper
    st=$?
    assertEquals "0" "$?"
    DIR_TEMP_FILE_1=`dirname $MPI_START_TEMP_FILE`
    DIR_TEMP_FILE=`dirname $DIR_TEMP_FILE_1`
    assertEquals "$HOME/.mpi_start_tmp" "$DIR_TEMP_FILE"
}

testNoHome() {
    OLDHOME="$HOME"
    unset HOME
    mpi_start_create_wrapper 2> /dev/null
    st=$?
    assertEquals "0" "$?"
    HOME=$OLDHOME
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
