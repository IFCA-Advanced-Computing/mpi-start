#!/bin/bash

# MPI-Start affinity tests

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
    export MPI_START_SOCKETS=1
    export MPI_START_COREPERSOCKET=1
    export OPENMPI_PARAMS=''
    unset I2G_MPI_PER_NODE
    unset I2G_MPI_PER_SOCKET
    unset I2G_MPI_PER_CORE
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

testAffinityNOOpenMPI() {
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

testAffinityOpenMPI1Slot() {
    # load options, to get mpi_start_get_plugin
    mpi_start_check_options
    # load flavour
    I2G_MPI_TYPE=openmpi
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

testAffinityOpenMPINOP() {
    # load options, to get mpi_start_get_plugin
    mpi_start_check_options
    # load flavour
    I2G_MPI_TYPE=openmpi
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

testAffinityOpenMPINode() {
    # load options, to get mpi_start_get_plugin
    mpi_start_check_options
    # load flavour
    I2G_MPI_TYPE=openmpi
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
    if test $OPENMPI_VERSION_MAJOR -eq 1 -a $OPENMPI_VERSION_MINOR -eq 2 ; then
        assertEquals "0" "$status"
    else
        assertEquals "1" "$status"
        RANK=$tmpdir/myrank
        cat > $RANK << EOF
rank 0=host1 slot=0-7
rank 1=host2 slot=0-7
rank 2=host3 slot=0-7
EOF
        rankfile=`echo $OPENMPI_PARAMS | cut -f2 -d" " `
        diff $rankfile $RANK
        status=$?
        assertEquals "0" "$status"
    fi
}

testAffinityOpenMPINodeOversuscribe() {
    # load options, to get mpi_start_get_plugin
    mpi_start_check_options
    # load flavour
    I2G_MPI_TYPE=openmpi
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
    if test $OPENMPI_VERSION_MAJOR -eq 1 -a $OPENMPI_VERSION_MINOR -eq 2 ; then
        assertEquals "0" "$status"
    else
        assertEquals "1" "$status"
        RANK=$tmpdir/myrank
        cat > $RANK << EOF
rank 0=host1 slot=0-7
rank 1=host1 slot=0-7
rank 2=host1 slot=0-7
rank 3=host2 slot=0-7
rank 4=host2 slot=0-7
rank 5=host2 slot=0-7
rank 6=host3 slot=0-7
rank 7=host3 slot=0-7
rank 8=host3 slot=0-7
EOF
        rankfile=`echo $OPENMPI_PARAMS | cut -f2 -d" " `
        diff -u $rankfile $RANK
        status=$?
        assertEquals "0" "$status"
    fi
}

testAffinityOpenMPISocket() {
    # load options, to get mpi_start_get_plugin
    mpi_start_check_options
    # load flavour
    I2G_MPI_TYPE=openmpi
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
    if test $OPENMPI_VERSION_MAJOR -eq 1 -a $OPENMPI_VERSION_MINOR -eq 2 ; then
        assertEquals "0" "$status"
    else
        assertEquals "1" "$status"
        RANK=$tmpdir/myrank
        cat > $RANK << EOF
rank 0=host1 slot=0:0-3
rank 1=host1 slot=1:0-3
rank 2=host2 slot=0:0-3
rank 3=host2 slot=1:0-3
rank 4=host3 slot=0:0-3
rank 5=host3 slot=1:0-3
EOF
        rankfile=`echo $OPENMPI_PARAMS | cut -f2 -d" " `
        diff $rankfile $RANK
        status=$?
        assertEquals "0" "$status"
    fi
}

testAffinityOpenMPISocketOversuscribe() {
    # load options, to get mpi_start_get_plugin
    mpi_start_check_options
    # load flavour
    I2G_MPI_TYPE=openmpi
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
    if test $OPENMPI_VERSION_MAJOR -eq 1 -a $OPENMPI_VERSION_MINOR -eq 2 ; then
        assertEquals "0" "$status"
    else
        assertEquals "1" "$status"
        RANK=$tmpdir/myrank
        cat > $RANK << EOF
rank 0=host1 slot=0:0-3
rank 1=host1 slot=0:0-3
rank 2=host1 slot=0:0-3
rank 3=host1 slot=1:0-3
rank 4=host1 slot=1:0-3
rank 5=host1 slot=1:0-3
rank 6=host2 slot=0:0-3
rank 7=host2 slot=0:0-3
rank 8=host2 slot=0:0-3
rank 9=host2 slot=1:0-3
rank 10=host2 slot=1:0-3
rank 11=host2 slot=1:0-3
rank 12=host3 slot=0:0-3
rank 13=host3 slot=0:0-3
rank 14=host3 slot=0:0-3
rank 15=host3 slot=1:0-3
rank 16=host3 slot=1:0-3
rank 17=host3 slot=1:0-3
EOF
        rankfile=`echo $OPENMPI_PARAMS | cut -f2 -d" " `
        diff -u $rankfile $RANK
        status=$?
        assertEquals "0" "$status"
    fi
}

testAffinityOpenMPICore() {
    # load options, to get mpi_start_get_plugin
    mpi_start_check_options
    # load flavour
    I2G_MPI_TYPE=openmpi
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
    if test $OPENMPI_VERSION_MAJOR -eq 1 -a $OPENMPI_VERSION_MINOR -eq 2 ; then
        assertEquals "1" "$status"
        echo "$OPENMPI_PARAMS" | grep "mpi_paffinity_alone" > /dev/null
        assertEquals "0" "$?"
    else
        assertEquals "1" "$status"
        RANK=$tmpdir/myrank
        cat > $RANK << EOF
rank 0=host1 slot=0:0
rank 1=host1 slot=0:1
rank 2=host1 slot=0:2
rank 3=host1 slot=0:3
rank 4=host1 slot=1:0
rank 5=host1 slot=1:1
rank 6=host1 slot=1:2
rank 7=host1 slot=1:3
rank 8=host2 slot=0:0
rank 9=host2 slot=0:1
rank 10=host2 slot=0:2
rank 11=host2 slot=0:3
rank 12=host2 slot=1:0
rank 13=host2 slot=1:1
rank 14=host2 slot=1:2
rank 15=host2 slot=1:3
rank 16=host3 slot=0:0
rank 17=host3 slot=0:1
rank 18=host3 slot=0:2
rank 19=host3 slot=0:3
rank 20=host3 slot=1:0
rank 21=host3 slot=1:1
rank 22=host3 slot=1:2
rank 23=host3 slot=1:3
EOF
        rankfile=`echo $OPENMPI_PARAMS | cut -f2 -d" " `
        diff $rankfile $RANK
        status=$?
        assertEquals "0" "$status"
    fi
}

testAffinityOpenMPICoreOversuscribe() {
    # load options, to get mpi_start_get_plugin
    mpi_start_check_options
    # load flavour
    I2G_MPI_TYPE=openmpi
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
    if test $OPENMPI_VERSION_MAJOR -eq 1 -a $OPENMPI_VERSION_MINOR -eq 2 ; then
        assertEquals "1" "$status"
        echo "$OPENMPI_PARAMS" | grep "mpi_paffinity_alone" > /dev/null
        assertEquals "0" "$?"
    else
        assertEquals "1" "$status"
        RANK=$tmpdir/myrank
        cat > $RANK << EOF
rank 0=host1 slot=0:0
rank 1=host1 slot=0:0
rank 2=host1 slot=0:1
rank 3=host1 slot=0:1
rank 4=host1 slot=0:2
rank 5=host1 slot=0:2
rank 6=host1 slot=0:3
rank 7=host1 slot=0:3
rank 8=host1 slot=1:0
rank 9=host1 slot=1:0
rank 10=host1 slot=1:1
rank 11=host1 slot=1:1
rank 12=host1 slot=1:2
rank 13=host1 slot=1:2
rank 14=host1 slot=1:3
rank 15=host1 slot=1:3
rank 16=host2 slot=0:0
rank 17=host2 slot=0:0
rank 18=host2 slot=0:1
rank 19=host2 slot=0:1
rank 20=host2 slot=0:2
rank 21=host2 slot=0:2
rank 22=host2 slot=0:3
rank 23=host2 slot=0:3
rank 24=host2 slot=1:0
rank 25=host2 slot=1:0
rank 26=host2 slot=1:1
rank 27=host2 slot=1:1
rank 28=host2 slot=1:2
rank 29=host2 slot=1:2
rank 30=host2 slot=1:3
rank 31=host2 slot=1:3
rank 32=host3 slot=0:0
rank 33=host3 slot=0:0
rank 34=host3 slot=0:1
rank 35=host3 slot=0:1
rank 36=host3 slot=0:2
rank 37=host3 slot=0:2
rank 38=host3 slot=0:3
rank 39=host3 slot=0:3
rank 40=host3 slot=1:0
rank 41=host3 slot=1:0
rank 42=host3 slot=1:1
rank 43=host3 slot=1:1
rank 44=host3 slot=1:2
rank 45=host3 slot=1:2
rank 46=host3 slot=1:3
rank 47=host3 slot=1:3
EOF
        rankfile=`echo $OPENMPI_PARAMS | cut -f2 -d" " `
        diff -u $rankfile $RANK
        status=$?
        assertEquals "0" "$status"
    fi
}
. $SHUNIT2
