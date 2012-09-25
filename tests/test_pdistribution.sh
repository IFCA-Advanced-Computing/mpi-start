#!/bin/bash

#
# Tests for MPI-Start process distribution features 
#

oneTimeSetUp () {
    export I2G_MPI_START_ENABLE_TESTING="TEST"
    # source the mpi-start code to have all functions
    . $I2G_MPI_START
    mpi_start_find_mktemp
}

oneTimeTearDown () {
    clean_up
}

setUp () {
    export I2G_MPI_TYPE="dummy"
    # force a number of sockets/cores so we know exactly
    # what to get as result.
    export MPI_START_NSLOTS=5
    export MPI_START_SOCKETS=2
    export MPI_START_COREPERSOCKET=4
    export MPI_START_NHOSTS=3
    unset I2G_MPI_APPLICATION
    unset MPI_START_NPHOST
    export I2G_MPI_START_DEBUG=0
    export I2G_MPI_START_VERBOSE=0
    unset I2G_MPI_START_TRACE
    unset I2G_MPI_SINGLE_PROCESS
    unset I2G_MPI_NP
    unset I2G_MPI_PER_NODE
    unset I2G_MPI_PER_CORE
    unset I2G_MPI_PER_SOCKET
    export MPI_START_SHARED_FS=1
    export MPI_START_DUMMY_SCHEDULER=1
}

testPnodeSingle() {
    export I2G_MPI_PER_NODE=1
    mpi_start_np_setup
    assertEquals "3" "$MPI_START_NP"
    assertEquals "1" "$MPI_START_NPHOST"
}

testPnodeMultiple() {
    export I2G_MPI_PER_NODE=4
    mpi_start_np_setup
    assertEquals "12" "$MPI_START_NP"
    assertEquals "4" "$MPI_START_NPHOST"
}

testPCoreSingle() {
    export I2G_MPI_PER_CORE=1
    mpi_start_np_setup
    assertEquals "24" "$MPI_START_NP"
    assertEquals "8" "$MPI_START_NPHOST"
}

testPCoreMultiple() {
    export I2G_MPI_PER_CORE=2
    mpi_start_np_setup
    assertEquals "48" "$MPI_START_NP"
    assertEquals "16" "$MPI_START_NPHOST"
}

testPSocketSingle() {
    export I2G_MPI_PER_SOCKET=1
    mpi_start_np_setup
    assertEquals "6" "$MPI_START_NP"
    assertEquals "2" "$MPI_START_NPHOST"
}

testPSocketMultiple() {
    export I2G_MPI_PER_SOCKET=4
    mpi_start_np_setup
    assertEquals "24" "$MPI_START_NP"
    assertEquals "8" "$MPI_START_NPHOST"
}

testPNP() {
    export I2G_MPI_NP=4
    mpi_start_np_setup
    assertEquals "4" "$MPI_START_NP"
    assertNull "$MPI_START_NPHOST"
}

testPDefault() {
    mpi_start_np_setup
    assertEquals "$MPI_START_NSLOTS" "$MPI_START_NP"
    assertNull "$MPI_START_NPHOST"
}

testMultipleNodeCore() {
    export I2G_MPI_START_VERBOSE=0
    export I2G_MPI_PER_NODE=1
    export I2G_MPI_PER_CORE=2
    mpi_start_np_setup
    assertEquals "3" "$MPI_START_NP"
    assertEquals "1" "$MPI_START_NPHOST"
}

testMultipleNodeSocket() {
    export I2G_MPI_START_VERBOSE=0
    export I2G_MPI_PER_NODE=1
    export I2G_MPI_PER_SOCKET=2
    mpi_start_np_setup
    assertEquals "3" "$MPI_START_NP"
    assertEquals "1" "$MPI_START_NPHOST"
}

testMultipleNodeNP() {
    export I2G_MPI_START_VERBOSE=0
    export I2G_MPI_PER_NODE=1
    export I2G_MPI_NP=2
    mpi_start_np_setup
    assertEquals "3" "$MPI_START_NP"
    assertEquals "1" "$MPI_START_NPHOST"
}

testMultipleNodeCoreSocketNP() {
    export I2G_MPI_START_VERBOSE=0
    export I2G_MPI_PER_NODE=1
    export I2G_MPI_NP=2
    export I2G_MPI_PER_SOCKET=2
    export I2G_MPI_PER_CORE=2
    mpi_start_np_setup
    assertEquals "3" "$MPI_START_NP"
    assertEquals "1" "$MPI_START_NPHOST"
}

testMultipleCoreSocket() {
    export I2G_MPI_START_VERBOSE=0
    export I2G_MPI_PER_SOCKET=2
    export I2G_MPI_PER_CORE=2
    mpi_start_np_setup
    assertEquals "12" "$MPI_START_NP"
    assertEquals "4" "$MPI_START_NPHOST"
}

testMultipleCoreSocketNP() {
    export I2G_MPI_START_VERBOSE=0
    export I2G_MPI_NP=2
    export I2G_MPI_PER_SOCKET=2
    export I2G_MPI_PER_CORE=2
    mpi_start_np_setup
    assertEquals "12" "$MPI_START_NP"
    assertEquals "4" "$MPI_START_NPHOST"
}

testMultipleCoreNP() {
    export I2G_MPI_START_VERBOSE=0
    export I2G_MPI_NP=2
    export I2G_MPI_PER_CORE=2
    mpi_start_np_setup
    assertEquals "48" "$MPI_START_NP"
    assertEquals "16" "$MPI_START_NPHOST"
}

. $SHUNIT2
