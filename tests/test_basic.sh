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
    export MPI_START_SHARED_FS=1
}

testI2G_MPI_START_Unset () {
    TEMP_MPI_START=$I2G_MPI_START 
    export I2G_MPI_APPLICATION=/bin/true
    unset I2G_MPI_START
    $TEMP_MPI_START 
    st=$?
    assertEquals 0 $st
    export I2G_MPI_START=$TEMP_MPI_START
}

testBadCommandLine () {
    output=`$I2G_MPI_START -flu 2>&1`
    st=$?
    assertEquals 1 $st
    echo $output | grep "Invalid option" > /dev/null
    st=$?
    assertEquals 0 $st
}

testCommandLineHelp () {
    $I2G_MPI_START -h 2> /dev/null
    st=$?
    assertEquals 0 $st
}

testCommandLineVersion() {
    version=`$I2G_MPI_START -V 2>&1`
    st=$?
    assertEquals 0 $st
    echo $version | grep "mpi-start v[0-9]\.[0-9]\.[0-9]" > /dev/null
    st=$?
    assertEquals 0 $st
}

testChmodApp() {
    unset I2G_MPI_TYPE
    myapp=`mktemp`
    cat > $myapp << EOF
#!/bin/sh
echo \${I2G_MPI_TYPE}
EOF
    output=`$I2G_MPI_START -t dummy -- $myapp`
    st=$?
    assertEquals "dummy" "$output"
    assertEquals 0 $st
    rm -f $myapp
}

testCommandLineTypeAndApp() {
    unset I2G_MPI_TYPE
    myapp=`mktemp`
    cat > $myapp << EOF
#!/bin/sh
echo \${I2G_MPI_TYPE}
EOF
    chmod +x $myapp
    output=`$I2G_MPI_START -t dummy -- $myapp`
    st=$?
    assertEquals "dummy" "$output"
    assertEquals 0 $st
    rm -f $myapp
}

testCommandLineVerbose() {
    output=`$I2G_MPI_START -v /bin/true 2>&1`
    st=$?
    assertEquals 0 $st
    echo $output | grep "INFO" > /dev/null
    st=$?
    assertEquals 0 $st
}

testCommandLineDebug() {
    output=`$I2G_MPI_START -vv /bin/true 2>&1`
    st=$?
    assertEquals 0 $st
    echo $output | grep "DEBUG" > /dev/null
    st=$?
    assertEquals 0 $st
}

testCommandLineTrace() {
    myapp=`mktemp`
    cat > $myapp << EOF
#!/bin/sh
echo \${I2G_MPI_START_TRACE}
EOF
    chmod +x $myapp
    output=`$I2G_MPI_START -vvv $myapp 2> /dev/null`
    st=$?
    assertEquals 0 $st
    assertEquals 1 $output
    rm -f $myapp
}

testCommandLineHook() {
    myapp=`mktemp`
    cat > $myapp << EOF
#!/bin/sh
echo "\${I2G_MPI_PRE_RUN_HOOK};\${I2G_MPI_POST_RUN_HOOK};"
EOF
    chmod +x $myapp

    output=`$I2G_MPI_START -pre mypre -post mypost $myapp`
    st=$?
    assertEquals 0 $st
    prehook=`echo $output | cut -f1 -d";"`
    posthook=`echo $output | cut -f2 -d";"`
    assertEquals "mypre" "$prehook"
    assertEquals "mypost" "$posthook"
    rm -f $myapp
}

. $SHUNIT2
