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
    export I2G_MPI_START=../bin/mpi-start
    export I2G_MPI_TYPE="dummy"
    unset I2G_MPI_APPLICATION
    unset I2G_MPI_START_DEBUG
    unset I2G_MPI_START_VERBOSE
    unset I2G_MPI_START_TRACE
    unset I2G_MPI_SINGLE_PROCESS
    unset MPI_START_SHARED_FS
}

testI2G_MPI_START_Unset () {
    TEMP_MPI_START=$I2G_MPI_START 
    unset I2G_MPI_START
    $TEMP_MPI_START 2>&1 | grep "ERROR.*I2G_MPI_START not set" > /dev/null
    st=$?
    assertEquals 0 $st
}

testNoScheduler () {
    $TEMP_MPI_START 2>&1 | grep "ERROR.*cannot find scheduler" > /dev/null
    st=$?
    assertEquals 0 $st
}

count_app_all_slots () {
    # disable the copy!
    export MPI_START_SHARED_FS=1
    export I2G_MPI_APPLICATION=`mktemp`
    cat > $I2G_MPI_APPLICATION << EOF
#!/bin/sh
echo "\${MPI_START_NSLOTS};\${MPI_START_NHOSTS};\${MPI_START_NSLOTS_PER_HOST};\${I2G_MPI_NP}"
EOF
    chmod +x $I2G_MPI_APPLICATION
    output=`$I2G_MPI_START`
    slots=`echo $output | cut -f1 -d";"`
    hosts=`echo $output | cut -f2 -d";"`
    sperhosts=`echo $output | cut -f3 -d";"`
    np=`echo $output | cut -f4 -d";"`
    assertEquals 8 $slots
    assertEquals 3 $hosts
    assertEquals 2 $sperhosts
    assertEquals 8 $np
    rm -f $I2G_MPI_APPLICATION
}

count_app_1slot_per_host () {
    # disable the copy!
    export MPI_START_SHARED_FS=1
    export I2G_MPI_SINGLE_PROCESS=1
    export I2G_MPI_APPLICATION=`mktemp`
    cat > $I2G_MPI_APPLICATION << EOF
#!/bin/sh
echo "\${MPI_START_NSLOTS};\${MPI_START_NHOSTS};\${MPI_START_NSLOTS_PER_HOST};\${I2G_MPI_NP}"
EOF
    chmod +x $I2G_MPI_APPLICATION
    output=`$I2G_MPI_START`
    slots=`echo $output | cut -f1 -d";"`
    hosts=`echo $output | cut -f2 -d";"`
    sperhosts=`echo $output | cut -f3 -d";"`
    np=`echo $output | cut -f4 -d";"`
    assertEquals 8 $slots
    assertEquals 3 $hosts
    assertEquals 2 $sperhosts
    assertEquals 3 $np
    rm -f $I2G_MPI_APPLICATION
}

testSGEScheduler() {
    export PE_HOSTFILE=`mktemp`
    cat > $PE_HOSTFILE << EOF
host1 2
host2 2
host3 4
EOF
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
    count_app_all_slots
    count_app_1slot_per_host
    rm -f $PBS_NODEFILE
    unset PBS_NODEFILE
}

testLSFScheduler () {
    export LSB_HOSTS="host1 host1 host2 host2 host3 host3 host3 host3"
    count_app_all_slots
    count_app_1slot_per_host
    unset LSB_HOSTS 
}

# XXX slurm plugin uses some slurm tools not found in the test environment!
#testSLURMscheduler () {
#
#}

. $SHUNIT2
