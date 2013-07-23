#!/bin/bash

# tests for bug #60

oneTimeSetUp() {
    export MYDIR=`$MYMKTEMP -d`
    pushd $MYDIR > /dev/null
    TARBALL=`$MYMKTEMP`
    mkdir -p one/two
    touch one/two/1
    touch testapp
    tar czf $TARBALL $MYDIR 2> /dev/null

    export I2G_MPI_START_ENABLE_TESTING="TEST"
    # source the mpi-start code to have all functions
    . $I2G_MPI_START
    mpi_start_check_options
    mpi_start_get_plugin "cptoshared.filedist" 1
    . $MPI_START_PLUGIN_FILES 
    popd > /dev/null
}

oneTimeTearDown() {
    rm -rf $MYDIR
}

setUp() {
    pushd $MYDIR > /dev/null
    export MPI_SHARED_HOME_PATH=`$MYMKTEMP -d`
    unset I2G_MPI_APPLICATION
}

tearDown() {
    popd > /dev/null
    rm -rf $MPI_SHARED_HOME_PATH
}

testRelativeInGlobalPath() {
    export I2G_MPI_APPLICATION=ls
    copy
    st=$?
    assertEquals "0" "$st"
    assertEquals "ls" "$I2G_MPI_APPLICATION"
}

testRelativeInPWD() {
    export I2G_MPI_APPLICATION=testapp
    copy
    st=$?
    assertEquals "0" "$st"
    assertEquals "$SHARED_BASE_PATH/$MYDIR/testapp" "$I2G_MPI_APPLICATION"
    stat $I2G_MPI_APPLICATION > /dev/null
    st=$?
    assertEquals "0" "$st"
}

testRelativeUnderPWD() {
    export I2G_MPI_APPLICATION=one/two/1
    chmod -x one/two/1
    copy
    st=$?
    assertEquals "0" "$st"
    assertEquals "$SHARED_BASE_PATH/$MYDIR/one/two/1" "$I2G_MPI_APPLICATION"
    stat $I2G_MPI_APPLICATION > /dev/null
    st=$?
    assertEquals "0" "$st"
}

testRelativeInPWDinPATH() {
    oldPATH="$PATH"
    PATH=.:$PATH
    export I2G_MPI_APPLICATION=testapp
    chmod +x testapp
    copy
    st=$?
    assertEquals "0" "$st"
    assertEquals "$SHARED_BASE_PATH/$MYDIR/testapp" "$I2G_MPI_APPLICATION"
    stat $I2G_MPI_APPLICATION > /dev/null
    st=$?
    assertEquals "0" "$st"
    PATH=$oldPATH
}

testRelativeUnderPWDinPATH() {
    export I2G_MPI_APPLICATION=one/two/1
    chmod +x one/two/1
    copy
    st=$?
    assertEquals "0" "$st"
    assertEquals "$SHARED_BASE_PATH/$MYDIR/one/two/1" "$I2G_MPI_APPLICATION"
    stat $I2G_MPI_APPLICATION > /dev/null
    st=$?
    assertEquals "0" "$st"
}

testAbsoluteNotInPWD() {
    export I2G_MPI_APPLICATION=/bin/ls
    copy
    st=$?
    assertEquals "0" "$st"
    assertEquals "/bin/ls" "$I2G_MPI_APPLICATION"
}

testAbsoluteInPWD() {
    export I2G_MPI_APPLICATION=$PWD/testapp
    copy
    st=$?
    assertEquals "0" "$st"
    assertEquals "$SHARED_BASE_PATH/$MYDIR/testapp" "$I2G_MPI_APPLICATION"
    stat $I2G_MPI_APPLICATION > /dev/null
    st=$?
    assertEquals "0" "$st"
}

testAbsoluteUnderPWD() {
    export I2G_MPI_APPLICATION=$PWD/one/two/1
    copy
    st=$?
    assertEquals "0" "$st"
    assertEquals "$SHARED_BASE_PATH/$MYDIR/one/two/1" "$I2G_MPI_APPLICATION"
    stat $I2G_MPI_APPLICATION > /dev/null
    st=$?
    assertEquals "0" "$st"
}

. $SHUNIT2
