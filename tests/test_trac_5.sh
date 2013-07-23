#!/bin/bash

# tests for bug #5

# fake cp and scp
cp () {
    echo cp#${1}#${2}
}
scp () {
    echo scp#${1}#${2}
}


oneTimeSetUp() {
    export I2G_MPI_START_ENABLE_TESTING="TEST"
    # source the mpi-start code to have all functions
    . $I2G_MPI_START
    mpi_start_check_options
}

testCPtoShared () {
    mpi_start_get_plugin "cptoshared.filedist" 1
    . $MPI_START_PLUGIN_FILES 
    out=`copy_from_node n1 src dst`
    st=$?
    assertEquals "0" "$st"
    assertEquals "cp#$PWD/src#dst" "$out" 
}

testSSH() {
    mpi_start_get_plugin "ssh.filedist" 1
    . $MPI_START_PLUGIN_FILES 
    out=`copy_from_node fakenodename src dst`
    st=$?
    assertEquals "0" "$st"
    assertEquals "scp#fakenodename:$PWD/src#dst" "$out" 
    out=`copy_from_node localhost src dst`
    st=$?
    assertEquals "0" "$st"
    assertEquals "cp#$PWD/src#dst" "$out" 
}

testMPI_MT() {
    mpi_start_get_plugin "mpi_mt.filedist" 1
    . $MPI_START_PLUGIN_FILES 
    out=`copy_from_node n1 src dst`
    st=$?
    assertEquals "1" "$st"
}

testMpexec() {
    mpi_start_get_plugin "mpiexec.filedist" 1
    . $MPI_START_PLUGIN_FILES 
    out=`copy_from_node n1 src dst`
    st=$?
    assertEquals "1" "$st"
}

. $SHUNIT2
