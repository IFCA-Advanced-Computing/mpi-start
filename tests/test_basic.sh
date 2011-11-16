#!/bin/bash

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

testI2G_MPI_START_Unset () {
    TEMP_MPI_START=$I2G_MPI_START 
    export I2G_MPI_APPLICATION=true
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

testCommandLineVersion () {
    version=`$I2G_MPI_START -V 2>&1`
    st=$?
    assertEquals 0 $st
    echo $version | grep "mpi-start v[0-9]\.[0-9]\.[0-9]" > /dev/null
    st=$?
    assertEquals 0 $st
}

testCommandLineTypeAndApp () {
    unset I2G_MPI_TYPE
    myapp=`$MYMKTEMP`
    cat > $myapp << EOF
#!/bin/bash
echo \${I2G_MPI_TYPE}
EOF
    chmod +x $myapp
    output=`$I2G_MPI_START -t dummy -- $myapp`
    st=$?
    assertEquals "dummy" "$output"
    assertEquals 0 $st
    rm -f $myapp
}

testCommandLineVerbose () {
    output=`$I2G_MPI_START -v true 2>&1`
    st=$?
    assertEquals 0 $st
    echo $output | grep "INFO" > /dev/null
    st=$?
    assertEquals 0 $st
}

testCommandLineDebug () {
    output=`$I2G_MPI_START -vv true 2>&1`
    st=$?
    assertEquals 0 $st
    echo $output | grep "DEBUG" > /dev/null
    st=$?
    assertEquals 0 $st
}

testCommandLineTrace () {
    myapp=`$MYMKTEMP`
    cat > $myapp << EOF
#!/bin/bash
echo \${I2G_MPI_START_TRACE}
EOF
    chmod +x $myapp
    output=`$I2G_MPI_START -vvv $myapp 2> /dev/null | grep -v "^=\[START\]" | grep -v "^=\[FINISHED\]"`
    st=$?
    assertEquals 0 $st
    assertEquals 1 $output
    rm -f $myapp
}

testCommandLineHook () {
    myapp=`$MYMKTEMP`
    cat > $myapp << EOF
#!/bin/bash
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

testInputFile () {
    myapp=`$MYMKTEMP`
    cat > $myapp << EOF
#!/bin/bash
while read line ; do
    echo -n \$line
done
echo -n "ERROR" 1>&2
EOF
    chmod +x $myapp
    myin=`$MYMKTEMP`
    echo "OUTPUT" > $myin 
    output=`$I2G_MPI_START -i $myin -- $myapp 2> /dev/null`
    st=$?
    assertEquals 0 $st
    assertEquals "OUTPUT" "$output"
    rm -f $myapp
    rm -f $myin
}

testOutputFile () {
    myapp=`$MYMKTEMP`
    cat > $myapp << EOF
#!/bin/bash
echo -n "OUTPUT"
echo -n "ERROR" 1>&2
EOF
    chmod +x $myapp
    myout=`$MYMKTEMP`
    output=`$I2G_MPI_START -o $myout -- $myapp 2> /dev/null`
    st=$?
    assertEquals 0 $st
    out=`cat $myout`
    assertEquals "OUTPUT" "$out"
    rm -f $myapp
    rm -rf $myout
}

testErrorFile () {
    myapp=`$MYMKTEMP`
    cat > $myapp << EOF
#!/bin/bash
echo -n "OUTPUT"
echo -n "ERROR" 1>&2
EOF
    chmod +x $myapp
    myerr=`$MYMKTEMP`
    output=`$I2G_MPI_START -e $myerr -- $myapp`
    st=$?
    err=`cat $myerr`
    assertEquals 0 $st
    assertEquals "ERROR" "$err"
    assertEquals "OUTPUT" "$output"
    rm -f $myapp
    rm -rf $myerr
}

testInOutputErrorFile () {
    myapp=`$MYMKTEMP`
    cat > $myapp << EOF
#!/bin/bash
while read line ; do
    echo -n \$line
done
echo -n "ERROR" 1>&2
EOF
    chmod +x $myapp
    myin=`$MYMKTEMP`
    echo "OUTPUT" > $myin 
    myerr=`$MYMKTEMP`
    myout=`$MYMKTEMP`
    `$I2G_MPI_START -i $myin -o $myout -e $myerr -- $myapp`
    st=$?
    assertEquals 0 $st
    out=`cat $myout`
    err=`cat $myerr`
    assertEquals "OUTPUT" "$out"
    assertEquals "ERROR" "$err"
    rm -f $myapp
    rm -f $myin
    rm -f $myerr
    rm -f $myout
}

testChmodApp () {
    unset I2G_MPI_TYPE
    myapp=`$MYMKTEMP`
    cat > $myapp << EOF
#!/bin/bash
echo \${I2G_MPI_TYPE}
EOF
    output=`$I2G_MPI_START -t dummy -- $myapp`
    st=$?
    assertEquals "dummy" "$output"
    assertEquals 0 $st
    rm -f $myapp
}

testCleanUp () {
    unset I2G_MPI_TYPE
    myhook=`$MYMKTEMP`
    cat > $myhook << EOF
#!/bin/bash

pre_run_hook() {
    mpi_start_mktemp
    ls -l \$MPI_START_TEMP_FILE > /dev/null
    st=\$?
    echo \$MPI_START_TEMP_FILE
    return \$st
}
EOF
    output=`$I2G_MPI_START -pre $myhook -t dummy -- /bin/true`
    st=$?
    assertEquals 0 $st
    ls $output 2> /dev/null
    assertNotEquals 0 $?
    rm -f $myhook
}
. $SHUNIT2
