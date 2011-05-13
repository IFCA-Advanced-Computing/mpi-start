#!/bin/sh

#
# helpers for testing schedulers. 
#

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
    output=`$I2G_MPI_START 2> /dev/null`
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
    output=`$I2G_MPI_START 2> /dev/null`
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
    output=`$I2G_MPI_START 2> /dev/null`
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
    output=`$I2G_MPI_START 2> /dev/null`
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
    output=`$I2G_MPI_START 2> /dev/null`
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
