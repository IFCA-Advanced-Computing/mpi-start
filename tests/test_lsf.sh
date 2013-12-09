#!/bin/bash

#
# Tests for LSF and MPI-Start.
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
    export LSB_HOSTS="host2 host2 host1 host1 host3 host3 host3 host3"
}

tearDown () {
    unset LSB_HOSTS 
}

testAllSlots() {
    count_app_all_slots "lsf" 
}

testNP() {
    count_app_np "lsf"
}

test1PerHost() {
    count_app_1slot_per_host "lsf"
}

test3PerHost() {
    count_app_3_per_host "lsf"
}

testNPAndPnode() {
    count_app_np_pnode "lsf"
}

testHostOrder() {
    check_host_order
}

. $SHUNIT2
