#!/bin/bash
# Test for https://github.com/IFCA/mpi-start/issues/1

oneTimeSetUp () {
    export I2G_MPI_START_ENABLE_TESTING="TEST"
    # source the mpi-start code to have all functions
    . $I2G_MPI_START
    mpi_start_check_options
}

oneTimeTearDown () {
    for f in $MPI_START_CLEANUP_FILES; do
        [ -f "$f" ] && rm -f $f
        [ -d "$f" ] && rm -rf $f
    done
}


testHostLocalhost() {
    mpi_start_get_plugin "ssh.filedist" 1
    . $MPI_START_PLUGIN_FILES
    is_localhost "localhost"
    assertEquals "0" "$?"
}

testHostHostname() {
    mpi_start_get_plugin "ssh.filedist" 1
    . $MPI_START_PLUGIN_FILES
    is_localhost `hostname` 
    assertEquals "0" "$?"
}

testHostHostnameS() {
    mpi_start_get_plugin "ssh.filedist" 1
    . $MPI_START_PLUGIN_FILES
    is_localhost `hostname -s` 
    assertEquals "0" "$?"
}

testHostHostnameF() {
    mpi_start_get_plugin "ssh.filedist" 1
    . $MPI_START_PLUGIN_FILES
    is_localhost `hostname -f` 
    assertEquals "0" "$?"
}

. $SHUNIT2
