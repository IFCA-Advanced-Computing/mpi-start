#!/bin/sh

#
# Tests for MPI-Start with dummy environment
#

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
}

testNoScheduler () {
    export MPI_START_DUMMY_SCHEDULER=0
    export I2G_MPI_APPLICATION=true
    error=`$I2G_MPI_START 2>&1`
    st=$?
    assertNotEquals 0 $st
    echo $error | grep "ERROR.*scheduler" > /dev/null
    st=$?
    assertEquals 0 $st
    unset MPI_START_DUMMY_SCHEDULER
}

count_app_np_pnode () {
    export I2G_MPI_APPLICATION=`$MYMKTEMP`
    export I2G_MPI_NP=5
    export I2G_MPI_PER_NODE=3
    cat > $I2G_MPI_APPLICATION << EOF
#!/bin/sh
echo "\${MPI_START_NSLOTS};\${MPI_START_NHOSTS};\${MPI_START_NSLOTS_PER_HOST};\${MPI_START_NP};\${MPI_START_SCHEDULER}"
exit 0
EOF
    chmod +x $I2G_MPI_APPLICATION
    output=`$I2G_MPI_START`
    st=$?
    slots=`echo $output | cut -f1 -d";"`
    hosts=`echo $output | cut -f2 -d";"`
    sperhosts=`echo $output | cut -f3 -d";"`
    np=`echo $output | cut -f4 -d";"`
    sch=`echo $output | cut -f5 -d";"`
    assertEquals "$1" $sch
    assertEquals 8 $slots
    assertEquals 3 $hosts
    assertEquals 2 $sperhosts
    assertEquals 9 $np
    assertEquals 0 $st
    unset I2G_MPI_NP
    unset I2G_MPI_PER_NODE
    rm -f $I2G_MPI_APPLICATION
}


count_app_np () {
    export I2G_MPI_APPLICATION=`$MYMKTEMP`
    export I2G_MPI_NP=5
    cat > $I2G_MPI_APPLICATION << EOF
#!/bin/sh
echo "\${MPI_START_NSLOTS};\${MPI_START_NHOSTS};\${MPI_START_NSLOTS_PER_HOST};\${MPI_START_NP};\${MPI_START_SCHEDULER}"
exit 0
EOF
    chmod +x $I2G_MPI_APPLICATION
    output=`$I2G_MPI_START`
    st=$?
    slots=`echo $output | cut -f1 -d";"`
    hosts=`echo $output | cut -f2 -d";"`
    sperhosts=`echo $output | cut -f3 -d";"`
    np=`echo $output | cut -f4 -d";"`
    sch=`echo $output | cut -f5 -d";"`
    assertEquals "$1" $sch
    assertEquals 8 $slots
    assertEquals 3 $hosts
    assertEquals 2 $sperhosts
    assertEquals 5 $np
    assertEquals 0 $st
    unset I2G_MPI_NP
    rm -f $I2G_MPI_APPLICATION
}

count_app_all_slots () {
    export I2G_MPI_APPLICATION=`$MYMKTEMP`
    cat > $I2G_MPI_APPLICATION << EOF
#!/bin/sh
echo "\${MPI_START_NSLOTS};\${MPI_START_NHOSTS};\${MPI_START_NSLOTS_PER_HOST};\${MPI_START_NP};\${MPI_START_SCHEDULER}"
exit 0
EOF
    chmod +x $I2G_MPI_APPLICATION
    output=`$I2G_MPI_START`
    st=$?
    slots=`echo $output | cut -f1 -d";"`
    hosts=`echo $output | cut -f2 -d";"`
    sperhosts=`echo $output | cut -f3 -d";"`
    np=`echo $output | cut -f4 -d";"`
    sch=`echo $output | cut -f5 -d";"`
    assertEquals "$1" $sch
    assertEquals 8 $slots
    assertEquals 3 $hosts
    assertEquals 2 $sperhosts
    assertEquals 8 $np
    assertEquals 0 $st
    rm -f $I2G_MPI_APPLICATION
}

count_app_1slot_per_host () {
    export I2G_MPI_SINGLE_PROCESS=1
    export I2G_MPI_APPLICATION=`$MYMKTEMP`
    cat > $I2G_MPI_APPLICATION << EOF
#!/bin/sh
echo "\${MPI_START_NSLOTS};\${MPI_START_NHOSTS};\${MPI_START_NSLOTS_PER_HOST};\${MPI_START_NP};\${MPI_START_SCHEDULER}"
exit 0
EOF
    chmod +x $I2G_MPI_APPLICATION
    output=`$I2G_MPI_START`
    st=$?
    slots=`echo $output | cut -f1 -d";"`
    hosts=`echo $output | cut -f2 -d";"`
    sperhosts=`echo $output | cut -f3 -d";"`
    np=`echo $output | cut -f4 -d";"`
    sch=`echo $output | cut -f5 -d";"`
    assertEquals "$1" $sch
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
    export I2G_MPI_APPLICATION=`$MYMKTEMP`
    cat > $I2G_MPI_APPLICATION << EOF
#!/bin/sh
echo "\${MPI_START_NSLOTS};\${MPI_START_NHOSTS};\${MPI_START_NSLOTS_PER_HOST};\${MPI_START_NP};\${MPI_START_SCHEDULER}"
exit 0
EOF
    chmod +x $I2G_MPI_APPLICATION
    output=`$I2G_MPI_START`
    st=$?
    slots=`echo $output | cut -f1 -d";"`
    hosts=`echo $output | cut -f2 -d";"`
    sperhosts=`echo $output | cut -f3 -d";"`
    np=`echo $output | cut -f4 -d";"`
    sch=`echo $output | cut -f5 -d";"`
    assertEquals "$1" $sch
    assertEquals 8 $slots
    assertEquals 3 $hosts
    assertEquals 2 $sperhosts
    assertEquals 9 $np
    assertEquals 0 $st
    unset I2G_MPI_PER_NODE
    rm -f $I2G_MPI_APPLICATION
}

testSGEScheduler() {
    export PE_HOSTFILE=`$MYMKTEMP`
    cat > $PE_HOSTFILE << EOF
host1 2
host2 2
host3 4
EOF
    count_app_np "sge"
    count_app_all_slots "sge"
    count_app_1slot_per_host "sge"
    count_app_np_pnode "sge"
    rm -f $PE_HOSTFILE
    unset PE_HOSTFILE
}

testSlurmScheduler() {
    MYTMPDIR=`$MYMKTEMP -d`
    export SLURM_JOB_NODELIST=$MYTMPDIR/nodes
    cat > $SLURM_JOB_NODELIST << EOF
host1
host1
host2
host2
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
    count_app_all_slots "slurm"
    rm -f $PE_HOSTFILE
    unset SLURM_JOB_NODELIST
    unset SLURM_NPROCS
    unset SLURM_MNODES
    unset SLURM_TASK_PER_NODE
    export PATH="$oldPATH"
    rm -rf $MYTMPDIR
}


testPBSScheduler () {
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
    count_app_np "pbs"
    count_app_all_slots "pbs"
    count_app_1slot_per_host "pbs"
    count_app_3_per_host "pbs"
    count_app_np_pnode "pbs"
    rm -f $PBS_NODEFILE
    unset PBS_NODEFILE
}

testLSFScheduler () {
    export LSB_HOSTS="host1 host1 host2 host2 host3 host3 host3 host3"
    count_app_np "lsf"
    count_app_all_slots "lsf"
    count_app_1slot_per_host "lsf"
    count_app_np_pnode "lsf"
    unset LSB_HOSTS 
}

testDummyScheduler () {
    export MPI_START_DUMMY_SCHEDULER=1
    export I2G_MPI_APPLICATION=`$MYMKTEMP`
    cat > $I2G_MPI_APPLICATION << EOF
#!/bin/sh
echo "\${MPI_START_NSLOTS};\${MPI_START_NHOSTS};\${MPI_START_NSLOTS_PER_HOST};\${MPI_START_NP};\${MPI_START_SCHEDULER}"
EOF
    chmod +x $I2G_MPI_APPLICATION
    output=`$I2G_MPI_START -npnode 3`
    st=$?
    slots=`echo $output | cut -f1 -d";"`
    hosts=`echo $output | cut -f2 -d";"`
    sperhosts=`echo $output | cut -f3 -d";"`
    np=`echo $output | cut -f4 -d";"`
    sch=`echo $output | cut -f5 -d";"`
    assertEquals "mpi-start-dummy" $sch
    assertEquals 1 $slots
    assertEquals 1 $hosts
    assertEquals 1 $sperhosts
    assertEquals 3 $np
    assertEquals 0 $st
    rm -f $I2G_MPI_APPLICATION
}

. $SHUNIT2
