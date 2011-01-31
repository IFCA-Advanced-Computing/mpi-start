#!/bin/sh

#
# Tests for MPI-Start with dummy environment
#

# check mktemp
TMPFILE=`mktemp 2> /dev/null`
if test $? -ne 0 ; then
    alias mktemp='mktemp -t MPI_START_TESTS'
    TMPFILE=`mktemp 2> /dev/null`
    if test $? -ne 0 ; then
        echo "Unable to find good mktemp!?"
        exit 0
    fi
fi
rm -f $TMPFILE    

setUp () {
    export I2G_MPI_TYPE="dummy"
    unset I2G_MPI_NP
    unset I2G_MPI_APPLICATION
    unset I2G_MPI_START_DEBUG
    unset I2G_MPI_START_VERBOSE
    unset I2G_MPI_START_TRACE
    unset I2G_MPI_SINGLE_PROCESS
    unset MPI_START_SHARED_FS
}

testPreHook () {
    myhook=`mktemp`
    cat > $myhook << EOF
#!/bin/sh

pre_run_hook () {
    echo "HOOK OK"
}
EOF
    output=`$I2G_MPI_START -pre $myhook /bin/true 2>&1`
    st=$?
    assertEquals 0 $st
    assertEquals "HOOK OK" "$output"
    rm -f $myhook
}

testPostHook () {
    myhook=`mktemp`
    cat > $myhook << EOF
#!/bin/sh

post_run_hook () {
    echo "HOOK OK"
}
EOF
    output=`$I2G_MPI_START -post $myhook /bin/true 2>&1`
    st=$?
    assertEquals 0 $st
    assertEquals "HOOK OK" "$output"
    rm -f $myhook
}

. $SHUNIT2
