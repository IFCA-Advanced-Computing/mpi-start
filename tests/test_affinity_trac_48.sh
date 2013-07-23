#!/bin/bash

# MPI-Start affinity tests

oneTimeSetUp () {
    export I2G_MPI_START_ENABLE_TESTING="TEST"
    # source the mpi-start code to have all functions
    . $I2G_MPI_START
}

setUp () {
    unset I2G_MPI_NP
    unset I2G_MPI_APPLICATION
    unset I2G_MPI_START_DEBUG
    unset I2G_MPI_START_VERBOSE
    unset I2G_MPI_START_TRACE
    unset I2G_MPI_SINGLE_PROCESS
    export MPI_START_SOCKETS=1
    export MPI_START_COREPERSOCKET=1
    export MPICH2_PARAMS=''
    unset I2G_MPI_PER_NODE
    unset I2G_MPI_PER_SOCKET
    unset I2G_MPI_PER_CORE
}

tearDown() {
    clean_up
}

testNoAffinity() {
    # load options, to get mpi_start_get_plugin
    mpi_start_check_options
    # load hook file 
    mpi_start_get_plugin "affinity.hook" 1
    . $MPI_START_PLUGIN_FILES 
    MPI_USE_AFFINITY=0
    tmpdir=`$MYMKTEMP -d`
    env > $tmpdir/e1
    pre_run_hook
    status=$?
    env > $tmpdir/e2
    assertEquals "0" "$status"
    diff $tmpdir/e1 $tmpdir/e2 > /dev/null
    status=$?
    assertEquals "0" "$status"
}

testAffinityUnsupported() {
    # load options, to get mpi_start_get_plugin
    mpi_start_check_options
    # load hook file 
    mpi_start_get_plugin "affinity.hook" 1
    . $MPI_START_PLUGIN_FILES 
    MPI_USE_AFFINITY=1
    I2G_MPI_TYPE=dummy
    tmpdir=`$MYMKTEMP -d`
    env > $tmpdir/e1
    pre_run_hook
    status=$?
    env > $tmpdir/e2
    assertEquals "0" "$status"
    diff $tmpdir/e1 $tmpdir/e2 > /dev/null
    status=$?
    assertEquals "0" "$status"
}

testAffinityMPICH21Slot() {
    # load options, to get mpi_start_get_plugin
    mpi_start_check_options
    # load flavour
    I2G_MPI_TYPE=mpich2
    mpi_start_load_execenv
    # load hook file 
    mpi_start_get_plugin "affinity.hook" 1
    . $MPI_START_PLUGIN_FILES 
    MPI_USE_AFFINITY=1
    tmpdir=`$MYMKTEMP -d`
    env > $tmpdir/e1
    pre_run_hook
    status=$?
    env > $tmpdir/e2
    assertEquals "0" "$status"
    diff $tmpdir/e1 $tmpdir/e2 > /dev/null
    status=$?
    assertEquals "0" "$status"
}

testAffinityMPICH2NOP() {
    # load options, to get mpi_start_get_plugin
    mpi_start_check_options
    # load flavour
    I2G_MPI_TYPE=mpich2
    mpi_start_load_execenv
    # load hook file 
    mpi_start_get_plugin "affinity.hook" 1
    . $MPI_START_PLUGIN_FILES 
    MPI_USE_AFFINITY=1
    export MPI_START_SOCKETS=2
    export MPI_START_COREPERSOCKET=4
    tmpdir=`$MYMKTEMP -d`
    export MPI_START_HOSTFILE=$tmpdir/hosts
    cat > $MPI_START_HOSTFILE << EOF
host1
host2
host3
EOF
    env > $tmpdir/e1
    pre_run_hook
    status=$?
    env > $tmpdir/e2
    assertEquals "0" "$status"
    diff $tmpdir/e1 $tmpdir/e2 > /dev/null
    status=$?
    assertEquals "0" "$status"
}

testAffinityMPICH2Node() {
    # load options, to get mpi_start_get_plugin
    mpi_start_check_options
    # load flavour
    I2G_MPI_TYPE=mpich2
    mpi_start_load_execenv
    # load hook file 
    mpi_start_get_plugin "affinity.hook" 1
    . $MPI_START_PLUGIN_FILES 
    MPI_USE_AFFINITY=1
    export MPI_START_SOCKETS=2
    export MPI_START_COREPERSOCKET=4
    tmpdir=`$MYMKTEMP -d`
    export MPI_START_HOSTFILE=$tmpdir/hosts
    cat > $MPI_START_HOSTFILE << EOF
host1
host2
host3
EOF
    export I2G_MPI_PER_NODE=1
    env > $tmpdir/e1
    pre_run_hook
    status=$?
    assertEquals "0" "$status"
    env > $tmpdir/e2
    diff $tmpdir/e1 $tmpdir/e2 > /dev/null
    status=$?
    assertEquals "0" "$status"
}

testAffinityMPICH2NodeOversuscribe() {
    # load options, to get mpi_start_get_plugin
    mpi_start_check_options
    # load flavour
    I2G_MPI_TYPE=mpich2
    mpi_start_load_execenv
    # load hook file 
    mpi_start_get_plugin "affinity.hook" 1
    . $MPI_START_PLUGIN_FILES 
    MPI_USE_AFFINITY=1
    export MPI_START_SOCKETS=2
    export MPI_START_COREPERSOCKET=4
    tmpdir=`$MYMKTEMP -d`
    export MPI_START_HOSTFILE=$tmpdir/hosts
    cat > $MPI_START_HOSTFILE << EOF
host1
host2
host3
EOF
    export I2G_MPI_PER_NODE=3
    env > $tmpdir/e1
    pre_run_hook
    status=$?
    env > $tmpdir/e2
    assertEquals "0" "$status"
    diff $tmpdir/e1 $tmpdir/e2 > /dev/null
    status=$?
    assertEquals "0" "$status"
}

testAffinityMPICH2Socket() {
    # load options, to get mpi_start_get_plugin
    mpi_start_check_options
    # load flavour
    I2G_MPI_TYPE=mpich2
    mpi_start_load_execenv
    # load hook file 
    mpi_start_get_plugin "affinity.hook" 1
    . $MPI_START_PLUGIN_FILES 
    MPI_USE_AFFINITY=1
    export MPI_START_SOCKETS=2
    export MPI_START_COREPERSOCKET=4
    tmpdir=`$MYMKTEMP -d`
    export MPI_START_HOSTFILE=$tmpdir/hosts
    cat > $MPI_START_HOSTFILE << EOF
host1
host2
host3
EOF
    export I2G_MPI_PER_SOCKET=1
    env > $tmpdir/e1
    pre_run_hook
    status=$?
    env > $tmpdir/e2
    assertEquals "0" "$status"
    diff $tmpdir/e1 $tmpdir/e2 > /dev/null
    status=$?
    assertEquals "1" "$status"
    echo "$MPICH2_PARAMS" | grep -e "-binding cpu:sockets" > /dev/null
    status=$?
    assertEquals "0" "$status"
}

testAffinityMPICH2SocketOversuscribe() {
    # load options, to get mpi_start_get_plugin
    mpi_start_check_options
    # load flavour
    I2G_MPI_TYPE=mpich2
    mpi_start_load_execenv
    # load hook file 
    mpi_start_get_plugin "affinity.hook" 1
    . $MPI_START_PLUGIN_FILES 
    MPI_USE_AFFINITY=1
    export MPI_START_SOCKETS=2
    export MPI_START_COREPERSOCKET=4
    tmpdir=`$MYMKTEMP -d`
    export MPI_START_HOSTFILE=$tmpdir/hosts
    cat > $MPI_START_HOSTFILE << EOF
host1
host2
host3
EOF
    export I2G_MPI_PER_SOCKET=3
    env > $tmpdir/e1
    pre_run_hook
    status=$?
    env > $tmpdir/e2
    assertEquals "0" "$status"
    diff $tmpdir/e1 $tmpdir/e2 > /dev/null
    status=$?
    assertEquals "1" "$status"
    echo "$MPICH2_PARAMS" | grep -e "-binding cpu:sockets" > /dev/null
    status=$?
    assertEquals "0" "$status"
}

testAffinityMPICH2Core() {
    # load options, to get mpi_start_get_plugin
    mpi_start_check_options
    # load flavour
    I2G_MPI_TYPE=mpich2
    mpi_start_load_execenv
    # load hook file 
    mpi_start_get_plugin "affinity.hook" 1
    . $MPI_START_PLUGIN_FILES 
    MPI_USE_AFFINITY=1
    export MPI_START_SOCKETS=2
    export MPI_START_COREPERSOCKET=4
    tmpdir=`$MYMKTEMP -d`
    export MPI_START_HOSTFILE=$tmpdir/hosts
    cat > $MPI_START_HOSTFILE << EOF
host1
host2
host3
EOF
    export I2G_MPI_PER_CORE=1
    env > $tmpdir/e1
    pre_run_hook
    status=$?
    env > $tmpdir/e2
    assertEquals "0" "$status"
    diff $tmpdir/e1 $tmpdir/e2 > /dev/null
    status=$?
    assertEquals "1" "$status"
    echo "$MPICH2_PARAMS" | grep -e "-binding cpu:cores" > /dev/null
    status=$?
    assertEquals "0" "$status"
}

testAffinityMPICH2CoreOversuscribe() {
    # load options, to get mpi_start_get_plugin
    mpi_start_check_options
    # load flavour
    I2G_MPI_TYPE=mpich2
    mpi_start_load_execenv
    # load hook file 
    mpi_start_get_plugin "affinity.hook" 1
    . $MPI_START_PLUGIN_FILES 
    MPI_USE_AFFINITY=1
    export MPI_START_SOCKETS=2
    export MPI_START_COREPERSOCKET=4
    tmpdir=`$MYMKTEMP -d`
    export MPI_START_HOSTFILE=$tmpdir/hosts
    cat > $MPI_START_HOSTFILE << EOF
host1
host2
host3
EOF
    export I2G_MPI_PER_CORE=2
    env > $tmpdir/e1
    pre_run_hook
    status=$?
    env > $tmpdir/e2
    assertEquals "0" "$status"
    diff $tmpdir/e1 $tmpdir/e2 > /dev/null
    status=$?
    assertEquals "1" "$status"
    echo "$MPICH2_PARAMS" | grep -e "-binding cpu:cores" > /dev/null
    status=$?
    assertEquals "0" "$status"
}


. $SHUNIT2
