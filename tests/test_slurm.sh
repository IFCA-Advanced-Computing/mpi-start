#!/bin/bash

#
# Tests for SLURM and MPI-Start.
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
    MYTMPDIR=`$MYMKTEMP -d`
    export SLURM_JOB_NODELIST=$MYTMPDIR/nodes
    cat > $SLURM_JOB_NODELIST << EOF
host2
host2
host1
host1
host3
host3
host3
host3
EOF
    # create fake commands
    cat > $MYTMPDIR/sl_get_machine_list << EOF
#!/bin/sh
cat $SLURM_JOB_NODELIST
EOF
    cat > $MYTMPDIR/srun << EOF
#!/bin/sh
$*
EOF
    # export fake variables
    export SLURM_NPROCS=8
    export SLURM_NNODES=3
    export SLURM_TASK_PER_NODE="2(2"
    chmod +x $MYTMPDIR/sl_get_machine_list 
    chmod +x $MYTMPDIR/srun
    # add them to path
    oldPATH="$PATH"
    export PATH=$MYTMPDIR:$PATH
}

tearDown () {
    unset SLURM_JOB_NODELIST
    unset SLURM_NPROCS
    unset SLURM_MNODES
    unset SLURM_TASK_PER_NODE
    export PATH="$oldPATH"
    rm -rf $MYTMPDIR
}

testAllSlots() {
    count_app_all_slots "slurm" 
}

testNP() {
    count_app_np "slurm"
}

test1PerHost() {
    count_app_1slot_per_host "slurm"
}

test3PerHost() {
    count_app_3_per_host "slurm"
}

testNPAndPnode() {
    count_app_np_pnode "slurm"
}

testHostOrder() {
    check_host_order
}

. $SHUNIT2
