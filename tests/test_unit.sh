#!/bin/bash

# MPI-Start unit tests for mpi-start main code

export I2G_MPI_START_ENABLE_TESTING="TEST"
# source the mpi-start code to have all functions
. $I2G_MPI_START

setUp () {
    unset I2G_MPI_NP
    unset I2G_MPI_APPLICATION
    unset I2G_MPI_START_DEBUG
    unset I2G_MPI_START_VERBOSE
    unset I2G_MPI_START_TRACE
    unset I2G_MPI_SINGLE_PROCESS
}

testWarningDisabled () {
    export I2G_MPI_START_VERBOSE=0
    output=`warn_msg "test" 2>&1`
    st=$?
    assertEquals 0 $st
    assertNull "$output"
}

testWarningEnabled () {
    export I2G_MPI_START_VERBOSE=1
    output=`warn_msg "test" 2>&1`
    output=`echo $output | cut -f2 -d':'`
    st=$?
    assertEquals 0 $st
    assertEquals "test" $output
}

testDebugDisabled () {
    export I2G_MPI_START_VERBOSE=0
    export I2G_MPI_START_DEBUG=0
    output=`debug_msg "test" 2>&1`
    st=$?
    assertEquals 0 $st
    assertNull "$output"
    export I2G_MPI_START_VERBOSE=1
    export I2G_MPI_START_DEBUG=0
    output=`debug_msg "test" 2>&1`
    st=$?
    assertEquals 0 $st
    assertNull "$output"
    export I2G_MPI_START_VERBOSE=0
    export I2G_MPI_START_DEBUG=1
    output=`debug_msg "test" 2>&1`
    st=$?
    assertEquals 0 $st
    assertNull "$output"
}

testDebugEnabled () {
    export I2G_MPI_START_VERBOSE=1
    export I2G_MPI_START_DEBUG=1
    output=`debug_msg "test" 2>&1`
    output=`echo $output | cut -f2 -d':'`
    st=$?
    assertEquals 0 $st
    assertEquals "test" $output
}

testInfoDisabled () {
    export I2G_MPI_START_VERBOSE=0
    output=`info_msg "test" 2>&1`
    st=$?
    assertEquals 0 $st
    assertNull "$output"
}

testInfoEnabled () {
    export I2G_MPI_START_VERBOSE=1
    output=`info_msg "test" 2>&1`
    output=`echo $output | cut -f2 -d':'`
    st=$?
    assertEquals 0 $st
    assertEquals "test" $output
}

testActivateMPI () {
    export oldPATH="$PATH"
    export oldLDPATH="$LD_LIBRARY_PATH"
    export PATH="1"; export LD_LIBRARY_PATH="2"
    mpi_start_activate_mpi "a/b/c/nonexisting" 
    st=$?
    newPATH=$PATH
    newLDPATH=$LD_LIBRARY_PATH
    export PATH=$oldPATH
    export LD_LIBRARY_PATH=$oldLDPATH
    assertEquals 0 $st
    assertEquals "1" $newPATH
    assertEquals "2" $newLDPATH
    export PATH="1"; export LD_LIBRARY_PATH="2"
    mpi_start_activate_mpi "$PWD" 
    st=$?
    newPATH=$PATH
    newLDPATH=$LD_LIBRARY_PATH
    export PATH=$oldPATH
    export LD_LIBRARY_PATH=$oldLDPATH
    assertEquals 0 $st
    assertEquals "$PWD/bin:1" $newPATH
    assertEquals "$PWD/lib:2" $newLDPATH
}

testMktempFile () {
    mpi_start_find_mktemp
    file=`mpi_start_mktemp`
    st=$?
    assertEquals 0 $st
    assertTrue "[ -f $file ]"
    rm -f $file
}

testMktempDir () {
    mpi_start_find_mktemp
    dir=`mpi_start_mktemp -d`
    st=$?
    assertEquals 0 $st
    assertTrue "[ -d $dir ]"
    rm -rf $dir
}

testCreateWrapper () {
    unset MPI_START_MPI_WRAPPER
    mpi_start_create_wrapper
    assertNotNull "$MPI_START_MPI_WRAPPER"
    echo $MPI_START_CLEANUP_FILES | grep "$MPI_START_MPI_WRAPPER" > /dev/null
    st=$?
    assertEquals 0 $st
    assertTrue "[ -f $MPI_START_MPI_WRAPPER ]"
    oldWrapper=$MPI_START_MPI_WRAPPER
    mpi_start_create_wrapper
    assertEquals "$MPI_START_MPI_WRAPPER" "$oldWrapper"
}

testExportVariable() {
    export MYVAR=23
    mpi_start_export_variable MYVAR
    echo $MPI_START_ENV_VARIABLES | grep MYVAR > /dev/null
    st=$?
    assertEquals 0 $st
    cat $MPI_START_MPI_WRAPPER | grep "^export MYVAR$" > /dev/null
    st=$?
    assertEquals 0 $st
    mpi_start_export_variable OTHERVAR "VALUE"
    st=$?
    assertEquals 0 $st
    cat $MPI_START_MPI_WRAPPER | grep "^export OTHERVAR=\"VALUE\"$" > /dev/null
    st=$?
    assertEquals 0 $st
}

testExecuteWrapperNoWrapper () {
    export MPI_START_DO_NOT_USE_WRAPPER=1
    output=`mpi_start_execute_wrapper /bin/echo "hello world"`
    st=$?
    assertEquals 0 $st
    assertEquals "hello world" "$output"
    unset MPI_START_DO_NOT_USE_WRAPPER
}

testExecuteWrapper () {
    output=`mpi_start_execute_wrapper /bin/echo "hello world"`
    st=$?
    assertEquals 0 $st
    assertEquals "hello world" "$output"
}


. $SHUNIT2

