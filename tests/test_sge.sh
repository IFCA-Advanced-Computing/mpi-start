#!/bin/sh

#
# Tests for SGE and MPI-Start.
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
    export PE_HOSTFILE=`$MYMKTEMP`
    cat > $PE_HOSTFILE << EOF
host1 2
host2 2
host3 4
EOF
}

tearDown () {
    rm -f $PE_HOSTFILE
    unset PE_HOSTFILE
}

testAllSlots() {
    count_app_all_slots "sge" 
}

testNP() {
    count_app_np "sge"
}

test1PerHost() {
    count_app_1slot_per_host "sge"
}

test3PerHost() {
    count_app_3_per_host "sge"
}

testNPAndPnode() {
    count_app_np_pnode "sge"
}

. $SHUNIT2
