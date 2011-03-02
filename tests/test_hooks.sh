#!/bin/sh

#
# Tests for MPI-Start with dummy environment
#

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

testPreHookOK () {
    myhook=`$MYMKTEMP`
    cat > $myhook << EOF
#!/bin/sh

pre_run_hook () {
    echo "PRE HOOK OK"
}
EOF
    output=`$I2G_MPI_START -t dummy -pre $myhook true 2>&1`
    st=$?
    assertEquals 0 $st
    assertEquals "PRE HOOK OK" "$output"
    rm -f $myhook
}

testPostHookOK () {
    myhook=`$MYMKTEMP`
    cat > $myhook << EOF
#!/bin/sh

post_run_hook () {
    echo "POST HOOK OK"
}
EOF
    output=`$I2G_MPI_START -t dummy -post $myhook true 2>&1`
    st=$?
    assertEquals 0 $st
    assertEquals "POST HOOK OK" "$output"
    rm -f $myhook
}

testFaultyPreHook () {
    myhook=/dev/null
    output=`$I2G_MPI_START -t dummy -pre $myhook true 2>&1`
    st=$?
    assertEquals 0 $st
    assertEquals "" "$output"
}

testFaultyPostHook () {
    myhook=/dev/null
    output=`$I2G_MPI_START -t dummy -post $myhook true 2>&1`
    st=$?
    assertEquals 0 $st
    assertEquals "" "$output"
}

testPreHookNon0 () {
    myhook=`$MYMKTEMP`
    cat > $myhook << EOF
#!/bin/sh

pre_run_hook () {
    echo "PRE HOOK BAD"
    return 5
}
EOF
    output=`$I2G_MPI_START -t dummy -pre $myhook true 2> /dev/null`
    st=$?
    assertEquals 5 $st
    assertEquals "PRE HOOK BAD" "$output"
    rm -f $myhook
}

testPreHookNon0 () {
    myhook=`$MYMKTEMP`
    cat > $myhook << EOF
#!/bin/sh

post_run_hook () {
    echo "POST HOOK BAD"
    return 6
}
EOF
    output=`$I2G_MPI_START -t dummy -post $myhook true 2> /dev/null`
    st=$?
    assertEquals 6 $st
    assertEquals "POST HOOK BAD" "$output"
    rm -f $myhook
}

testNonExistingPreHook () {
    myhook=/a/b/c/d/nonexists
    output=`$I2G_MPI_START -t dummy -pre $myhook true 2>&1`
    st=$?
    assertEquals 0 $st
    assertEquals "" "$output"
}

testNonExistingPostHook () {
    myhook=/a/b/c/d/nonexists
    output=`$I2G_MPI_START -t dummy -post $myhook true 2>&1`
    st=$?
    assertEquals 0 $st
    assertEquals "" "$output"
}

. $SHUNIT2
