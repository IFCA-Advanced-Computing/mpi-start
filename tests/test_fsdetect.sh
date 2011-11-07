#!/bin/bash

# MPI-Start affinity tests

export I2G_MPI_START_ENABLE_TESTING="TEST"
# source the mpi-start code to have all functions
. $I2G_MPI_START
mpi_start_check_options
# load hooks
mpi_start_get_plugin "mpi-start.hooks" 1
. $MPI_START_PLUGIN_FILES 

setUp () {
    export I2G_MPI_START_DEBUG=1
    export I2G_MPI_START_VERBOSE=1
    unset MPI_START_SHARED_FS
    export MYTMPDIR=`$MYMKTEMP -d`
}

tearDown() {
    rm -rf "$MYTMPDIR"
    for file in $MPI_START_CLEANUP_FILES; do
        [ -f $file ] && rm -f $file
    done
}

testDisabledFSDetection() {
    export MPI_START_SHARED_FS=1
    env > $MYTMPDIR/e1
    mpi_start_detect_shared_fs
    status=$?
    env > $MYTMPDIR/e2
    assertEquals "0" "$status"
    diff $MYTMPDIR/e1 $MYTMPDIR/e2 > /dev/null
    status=$?
    assertEquals "0" "$status"
}

testRelativeLink() {
    CURD=$PWD
    cd $MYTMPDIR
    mkdir test1
    ln -s test1 test2
    cd test2
    env > $MYTMPDIR/e1
    mpi_start_detect_shared_fs 2> $MYTMPDIR/output
    status=$?
    env > $MYTMPDIR/e2
    assertEquals "0" "$status"
    diff $MYTMPDIR/e1 $MYTMPDIR/e2 > /dev/null
    status=$?
    assertEquals "1" "$status"
    assertNotNull "$MPI_START_SHARED_FS"
    cat $MYTMPDIR/output | grep "$MYTMPDIR/test2 -> test1" > /dev/null
    assertEquals "0" "$?"
    cat $MYTMPDIR/output | grep "to $MYTMPDIR/test1" > /dev/null
    assertEquals "0" "$?"
    cd $CURD
}

testAbsoluteLink() {
    CURD=$PWD
    cd $MYTMPDIR
    mkdir test1
    ln -s $MYTMPDIR/test1 test2
    cd test2
    env > $MYTMPDIR/e1
    mpi_start_detect_shared_fs 2> $MYTMPDIR/output
    status=$?
    env > $MYTMPDIR/e2
    assertEquals "0" "$status"
    diff $MYTMPDIR/e1 $MYTMPDIR/e2 > /dev/null
    status=$?
    assertEquals "1" "$status"
    assertNotNull "$MPI_START_SHARED_FS"
    cat $MYTMPDIR/output | grep "$MYTMPDIR/test2 -> $MYTMPDIR/test1" > /dev/null
    assertEquals "0" "$?"
    cat $MYTMPDIR/output | grep "to $MYTMPDIR/test1" > /dev/null
    assertEquals "0" "$?"
    cd $CURD
}

createMount ()  {
    if test "$MPI_START_UNAME" = "darwin" ; then 
        cat > $MYTMPDIR/mount << EOF
#!/bin/sh

cat << EOF
/fake on $MYTMPDIR/test1 (nfs, whatever)
/fake2 on / (hfs, whatever)
EOF
    else
        cat > $MYTMPDIR/mount << EOF
#!/bin/sh

cat << EOF
/fake on $MYTMPDIR/test1 type nfs 
/fake2 on / type ext4 
EOF
    fi
    chmod +x $MYTMPDIR/mount
}

testFakeMountNotShared() {
    CURD=$PWD
    createMount
    oldPATH=$PATH
    export PATH=$MYTMPDIR:$PATH
    mkdir -p $MYTMPDIR/test1/test2/test3
    cd $MYTMPDIR/test1/test2
    ln -s $MYTMPDIR test4
    cd test4 
    env > $MYTMPDIR/e1
    mpi_start_detect_shared_fs 2> /dev/null
    status=$?
    env > $MYTMPDIR/e2
    assertEquals "0" "$status"
    diff $MYTMPDIR/e1 $MYTMPDIR/e2 > /dev/null
    status=$?
    assertEquals "1" "$status"
    assertEquals "0" "$MPI_START_SHARED_FS"
    cd $CURD
    export PATH=$oldPATH
}

testFakeMountShared() {
    CURD=$PWD
    createMount
    oldPATH=$PATH
    export PATH=$MYTMPDIR:$PATH
    mkdir -p $MYTMPDIR/test1/test2/test3
    cd $MYTMPDIR/test1/test2
    ln -s test3 test4
    cd test4 
    env > $MYTMPDIR/e1
    mpi_start_detect_shared_fs 2> /dev/null
    status=$?
    env > $MYTMPDIR/e2
    assertEquals "0" "$status"
    diff $MYTMPDIR/e1 $MYTMPDIR/e2 > /dev/null
    status=$?
    assertEquals "1" "$status"
    assertEquals "1" "$MPI_START_SHARED_FS"
    cd $CURD
    export PATH=$oldPATH
}

. $SHUNIT2
