#!/bin/bash

#
# Tests for PBS and MPI-Start.
#

. ./test_scheduler.sh

setUp () {
    export I2G_MPI_TYPE="dummy"
    unset I2G_MPI_NP
    unset I2G_MPI_APPLICATION
    unset I2G_MPI_START_DEBUG
    unset I2G_MPI_START_VERBOSE
    unset I2G_MPI_START_TRACE
    unset I2G_MPI_SINGLE_PROCESS
    unset I2G_MPI_NP
    unset I2G_MPI_PER_NODE
    export MPI_START_SHARED_FS=1
    export MPI_START_DUMMY_SCHEDULER=0
    export PBS_NODEFILE=`$MYMKTEMP`
    cat > $PBS_NODEFILE << EOF
host2
host2
host1
host1
host3
host3
host3
host3
EOF
}

tearDown () {
    rm -f $PBS_NODEFILE
    unset PBS_NODEFILE
}

testAllSlots() {
    count_app_all_slots "pbs" 
}

testNP() {
    count_app_np "pbs"
}

test1PerHost() {
    count_app_1slot_per_host "pbs"
}

test3PerHost() {
    count_app_3_per_host "pbs"
}

testNPAndPnode() {
    count_app_np_pnode "pbs"
}

testHostOrder() {
    check_host_order
}

. $SHUNIT2
