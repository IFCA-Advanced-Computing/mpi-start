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

testNoScheduler () {
    export MPI_START_DUMMY_SCHEDULER=0
    export I2G_MPI_APPLICATION=/bin/true
    error=`$I2G_MPI_START 2>&1`
    st=$?
    assertNotEquals 0 $st
    echo $error | grep "ERROR.*scheduler" > /dev/null
    st=$?
    assertEquals 0 $st
    unset MPI_START_DUMMY_SCHEDULER
}


count_app_np () {
    export I2G_MPI_APPLICATION=`mktemp`
    export I2G_MPI_NP=5
    cat > $I2G_MPI_APPLICATION << EOF
#!/bin/sh
echo "\${MPI_START_NSLOTS};\${MPI_START_NHOSTS};\${MPI_START_NSLOTS_PER_HOST};\${MPI_START_NP}"
exit 0
EOF
    chmod +x $I2G_MPI_APPLICATION
    output=`$I2G_MPI_START`
    st=$?
    slots=`echo $output | cut -f1 -d";"`
    hosts=`echo $output | cut -f2 -d";"`
    sperhosts=`echo $output | cut -f3 -d";"`
    np=`echo $output | cut -f4 -d";"`
    assertEquals 8 $slots
    assertEquals 3 $hosts
    assertEquals 2 $sperhosts
    assertEquals 5 $np
    assertEquals 0 $st
    unset I2G_MPI_NP
    rm -f $I2G_MPI_APPLICATION
}

count_app_all_slots () {
    export I2G_MPI_APPLICATION=`mktemp`
    cat > $I2G_MPI_APPLICATION << EOF
#!/bin/sh
echo "\${MPI_START_NSLOTS};\${MPI_START_NHOSTS};\${MPI_START_NSLOTS_PER_HOST};\${MPI_START_NP}"
exit 0
EOF
    chmod +x $I2G_MPI_APPLICATION
    output=`$I2G_MPI_START`
    st=$?
    slots=`echo $output | cut -f1 -d";"`
    hosts=`echo $output | cut -f2 -d";"`
    sperhosts=`echo $output | cut -f3 -d";"`
    np=`echo $output | cut -f4 -d";"`
    assertEquals 8 $slots
    assertEquals 3 $hosts
    assertEquals 2 $sperhosts
    assertEquals 8 $np
    assertEquals 0 $st
    rm -f $I2G_MPI_APPLICATION
}

count_app_1slot_per_host () {
    export I2G_MPI_SINGLE_PROCESS=1
    export I2G_MPI_APPLICATION=`mktemp`
    cat > $I2G_MPI_APPLICATION << EOF
#!/bin/sh
echo "\${MPI_START_NSLOTS};\${MPI_START_NHOSTS};\${MPI_START_NSLOTS_PER_HOST};\${MPI_START_NP}"
exit 0
EOF
    chmod +x $I2G_MPI_APPLICATION
    output=`$I2G_MPI_START`
    st=$?
    slots=`echo $output | cut -f1 -d";"`
    hosts=`echo $output | cut -f2 -d";"`
    sperhosts=`echo $output | cut -f3 -d";"`
    np=`echo $output | cut -f4 -d";"`
    assertEquals 8 $slots
    assertEquals 3 $hosts
    assertEquals 2 $sperhosts
    assertEquals 3 $np
    assertEquals 0 $st
    unset I2G_MPI_SINGLE_PROCESS
    rm -f $I2G_MPI_APPLICATION
}

count_app_3_per_host () {
    export I2G_MPI_PER_NODE=3
    export I2G_MPI_APPLICATION=`mktemp`
    cat > $I2G_MPI_APPLICATION << EOF
#!/bin/sh
echo "\${MPI_START_NSLOTS};\${MPI_START_NHOSTS};\${MPI_START_NSLOTS_PER_HOST};\${MPI_START_NP}"
exit 0
EOF
    chmod +x $I2G_MPI_APPLICATION
    output=`$I2G_MPI_START`
    st=$?
    slots=`echo $output | cut -f1 -d";"`
    hosts=`echo $output | cut -f2 -d";"`
    sperhosts=`echo $output | cut -f3 -d";"`
    np=`echo $output | cut -f4 -d";"`
    assertEquals 8 $slots
    assertEquals 3 $hosts
    assertEquals 2 $sperhosts
    assertEquals 9 $np
    assertEquals 0 $st
    unset I2G_MPI_PER_NODE
    rm -f $I2G_MPI_APPLICATION
}

testSGEScheduler() {
    export PE_HOSTFILE=`mktemp`
    cat > $PE_HOSTFILE << EOF
host1 2
host2 2
host3 4
EOF
    count_app_np
    count_app_all_slots
    count_app_1slot_per_host
    rm -f $PE_HOSTFILE
    unset PE_HOSTFILE
}

testPBSScheduler () {
    export PBS_NODEFILE=`mktemp`
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
    count_app_np
    count_app_all_slots
    count_app_1slot_per_host
    count_app_3_per_host
    rm -f $PBS_NODEFILE
    unset PBS_NODEFILE
}

testLSFScheduler () {
    export LSB_HOSTS="host1 host1 host2 host2 host3 host3 host3 host3"
    count_app_np
    count_app_all_slots
    count_app_1slot_per_host
    unset LSB_HOSTS 
}

testDummyScheduler () {
    export I2G_MPI_APPLICATION=`mktemp`
    cat > $I2G_MPI_APPLICATION << EOF
#!/bin/sh
echo "\${MPI_START_NSLOTS};\${MPI_START_NHOSTS};\${MPI_START_NSLOTS_PER_HOST};\${MPI_START_NP}"
EOF
    chmod +x $I2G_MPI_APPLICATION
    output=`$I2G_MPI_START -npnode 3`
    st=$?
    slots=`echo $output | cut -f1 -d";"`
    hosts=`echo $output | cut -f2 -d";"`
    sperhosts=`echo $output | cut -f3 -d";"`
    np=`echo $output | cut -f4 -d";"`
    assertEquals 1 $slots
    assertEquals 1 $hosts
    assertEquals 1 $sperhosts
    assertEquals 3 $np
    assertEquals 0 $st
    rm -f $I2G_MPI_APPLICATION
}

. $SHUNIT2
