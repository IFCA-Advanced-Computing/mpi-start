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
    output=`echo $output | cut -f2 -d':' | tr -d " "`  
    st=$?
    assertEquals 0 $st
    assertEquals "test" "$output"
}

testWarningEnabled () {
    export I2G_MPI_START_VERBOSE=1
    output=`warn_msg "test" 2>&1`
    output=`echo $output | cut -f2 -d':' | tr -d " "`
    st=$?
    assertEquals 0 $st
    assertEquals "test" "$output"
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

testPluginLoader() {
    MPI_START_ETC=`$MYMKTEMP -d`
    touch $MPI_START_ETC/1.hi
    touch $MPI_START_ETC/2.hi
    touch $MPI_START_ETC/3.hi
    mpi_start_check_options
    mpi_start_get_plugin "*.hi"
    echo $MPI_START_PLUGIN_FILES  | grep 1.hi > /dev/null
    assertEquals 0 $?
    echo $MPI_START_PLUGIN_FILES  | grep 2.hi > /dev/null
    assertEquals 0 $?
    echo $MPI_START_PLUGIN_FILES  | grep 3.hi > /dev/null
    assertEquals 0 $?
    touch $MPI_START_ETC/openmpi.mpi
    mpi_start_get_plugin "openmpi.mpi" 1
    assertEquals $MPI_START_ETC/openmpi.mpi $MPI_START_PLUGIN_FILES
    mpi_start_get_plugin "*.hi" 1
    W=`echo $MPI_START_PLUGIN_FILES | wc -w`
    assertEquals 1 $W
    rm -rf $MPI_START_ETC
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
    mpi_start_mktemp
    st=$?
    file=$MPI_START_TEMP_FILE
    assertEquals 0 $st
    echo $MPI_START_CLEANUP_FILES | grep $file > /dev/null
    assertEquals 0 $st
    assertTrue "[ -f $file ]"
    rm -f $file
}

testMktempDir () {
    mpi_start_find_mktemp
    mpi_start_mktemp -d
    st=$?
    dir=$MPI_START_TEMP_FILE
    assertEquals 0 $st
    echo $MPI_START_CLEANUP_FILES | grep $dir > /dev/null
    assertEquals 0 $st
    assertTrue "[ -d $dir ]"
    rm -rf $dir
}

testCreateWrapper () {
    unset MPI_START_MPI_WRAPPER
    mpi_start_create_wrapper
    assertNotNull "$MPI_START_MPI_WRAPPER"
    st=$?
    assertEquals 0 $st
    assertTrue "[ -f $MPI_START_MPI_WRAPPER ]"
}

testExportVariable() {
    export MYVAR=23
    mpi_start_export_variable MYVAR
    st=$?
    assertEquals 0 $st
    mpi_start_create_wrapper
    cat $MPI_START_MPI_WRAPPER | grep "^export MYVAR$" > /dev/null
    st=$?
    assertEquals 0 $st
    mpi_start_export_variable OTHERVAR "VALUE"
    st=$?
    assertEquals 0 $st
    mpi_start_create_wrapper
    cat $MPI_START_MPI_WRAPPER | grep "^export OTHERVAR=\"VALUE\"$" > /dev/null
    st=$?
    assertEquals 0 $st
    cat $MPI_START_MPI_WRAPPER | grep "^export MYVAR$" > /dev/null
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

testHookOrder() {
    MPI_START_ETC=`$MYMKTEMP -d`
    # load options, to be able to load anything later
    mpi_start_check_options
    echo $MPI_START_ETC_LIST | grep $MPI_START_ETC > /dev/null
    assertEquals 0 $?
    # load hooks
    mpi_start_get_plugin "mpi-start.hooks" 1
    . $MPI_START_PLUGIN_FILES 
    # change the dir to load hooks
    MPI_START_ETC_LIST=$MPI_START_ETC
    # change MPI_START_ETC to tmp, so I can define which hooks to load
    echo "echo -n 1" >> $MPI_START_ETC/1.hook
    echo "echo -n 2" >> $MPI_START_ETC/2.hook
    echo "echo -n 3" >> $MPI_START_ETC/mpi-start.hooks.local
    I2G_MPI_PRE_RUN_HOOK=$MPI_START_ETC/user
    echo "echo -n 4" >> $I2G_MPI_PRE_RUN_HOOK
    I2G_MPI_POST_RUN_HOOK=$I2G_MPI_PRE_RUN_HOOK
    # now test the hooks
    output=`mpi_start_pre_run_hook`
    assertEquals "1234" "$output"
    output=`mpi_start_post_run_hook`
    assertEquals "1234" "$output"
    rm -rf $mydir
}


. $SHUNIT2

