#!/bin/bash

# tests for bug #32

setUp () {
    export MYPWD=$PWD
    export MYDIR=`$MYMKTEMP -d`
    export I2G_MPI_TYPE="dummy"
    unset I2G_MPI_NP
    unset I2G_MPI_APPLICATION
    unset I2G_MPI_START_DEBUG
    unset I2G_MPI_START_VERBOSE
    unset I2G_MPI_START_TRACE
    unset I2G_MPI_SINGLE_PROCESS
    unset I2G_MPI_NP
    unset I2G_MPI_PER_NODE
    export MPI_START_SHARED_FS=0
    export MPI_START_DUMMY_SCHEDULER=0
    export PBS_NODEFILE=`$MYMKTEMP`
    cat > $PBS_NODEFILE << EOF
host1
host1
host2
host2
host3
host3
host3
host3
EOF
}

tearDown () {
    rm -f $PBS_NODEFILE
    unset PBS_NODEFILE
    cd $MYPWD
    rm -rf $MYDIR
}

testCopyAndCleanCall() {
    cd $MYDIR
    export I2G_MPI_FILE_DIST=cptoshared
    export MPI_SHARED_HOME_PATH=$MYDIR
    mkdir -p one/two
    touch one/two/1
    export I2G_MPI_APPLICATION="mpiapp"
    cat > $I2G_MPI_APPLICATION << EOF
#!/bin/sh
echo "\${SHARED_BASE_PATH}"
/bin/ls \${SHARED_BASE_PATH} > /dev/null
EOF
    SHARED_DIR=`$I2G_MPI_START`
    assertEquals "0" "$?"
    # the directory should not exist
    ls $SHARED_DIR 2> /dev/null
    st=$?
    assertNotEquals "0" "$st"
}

. $SHUNIT2
