#!/bin/bash

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
    unset MPI_START_DUMMY_SCH_SLOTS
    unset MPI_START_DUMMY_SCH_HOSTS
    export MPI_START_SHARED_FS=1
    export MPI_START_DUMMY_SCHEDULER=0
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


testSchedulerError () {
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

testDummySchedulerNSlots () {
    export MPI_START_DUMMY_SCHEDULER=1
    export I2G_MPI_APPLICATION=`$MYMKTEMP`
    export MPI_START_DUMMY_SCH_SLOTS=2
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
    assertEquals 2 $slots
    assertEquals 1 $hosts
    assertEquals 2 $sperhosts
    assertEquals 3 $np
    assertEquals 0 $st
    rm -f $I2G_MPI_APPLICATION
}


testDummySchedulerNHosts() {
    export MPI_START_DUMMY_SCHEDULER=1
    export I2G_MPI_APPLICATION=`$MYMKTEMP`
    export MPI_START_DUMMY_SCH_HOSTS="host1 host2 host3"
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
    assertEquals 3 $slots
    assertEquals 3 $hosts
    assertEquals 1 $sperhosts
    assertEquals 9 $np
    assertEquals 0 $st
    rm -f $I2G_MPI_APPLICATION
}


testDummySchedulerNHostsNSlots() {
    export MPI_START_DUMMY_SCHEDULER=1
    export I2G_MPI_APPLICATION=`$MYMKTEMP`
    export MPI_START_DUMMY_SCH_SLOTS=2
    export MPI_START_DUMMY_SCH_HOSTS="host1 host2 host3"
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
    assertEquals 6 $slots
    assertEquals 3 $hosts
    assertEquals 2 $sperhosts
    assertEquals 9 $np
    assertEquals 0 $st
    rm -f $I2G_MPI_APPLICATION
}
. $SHUNIT2
