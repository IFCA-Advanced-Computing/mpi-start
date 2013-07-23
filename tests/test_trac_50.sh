#!/bin/bash

#
# Tests for ticket #50
#

oneTimeSetUp() {
    MYTMPDIR=`$MYMKTEMP -d`
    cat > $MYTMPDIR/mpdboot << EOF
#!/bin/sh
echo "$*"
exit 0
EOF
    chmod +x $MYTMPDIR/mpdboot
    cp $MYTMPDIR/mpdboot $MYTMPDIR/mpdallexit
    oldPATH="$PATH"
    export PATH=$MYTMPDIR:$PATH
}

setUp () {
    unset I2G_MPI_NP
    unset I2G_MPI_APPLICATION
    unset I2G_MPI_START_DEBUG
    unset I2G_MPI_START_VERBOSE
    unset I2G_MPI_START_TRACE
    unset I2G_MPI_SINGLE_PROCESS
    unset MPI_MPICH2_MPIEXEC_PARAMS
    unset MPI_MPICH2_MPIEXEC
    unset MPI_MPICH2_DISABLE_HYDRA
    export MPI_START_SHARED_FS=1
    export I2G_MPI_TYPE=mpich2
}

oneTimeTearDown (){
    export PATH="$oldPATH"
    rm -rf $MYTMPDIR
}

testBug50_OSC() {
    export MPI_MPICH2_MPIEXEC_PARAMS="kkuue"
    export MPI_MPICH2_MPIEXEC=`$MYMKTEMP`
    cat > $MPI_MPICH2_MPIEXEC << EOF
#/bin/sh
echo \$* 
exit 0
EOF
    chmod +x $MPI_MPICH2_MPIEXEC
    OUTPUT=`$I2G_MPI_START -np 2`
    assertEquals "0" "$?"
    echo $OUTPUT | grep $MPI_MPICH2_MPIEXEC_PARAMS > /dev/null
    assertEquals "0" "$?"
    rm -f $MPI_MPICH2_MPIEXEC
}

testBug50_MPD() {
    export MPI_MPICH2_DISABLE_HYDRA=1
    export MPI_MPICH2_MPIEXEC_PARAMS="kkuue"
    export MPI_MPICH2_MPIEXEC=`$MYMKTEMP`
    cat > $MPI_MPICH2_MPIEXEC << EOF
#/bin/sh
echo -np
echo \$* 
exit 0
EOF
    chmod +x $MPI_MPICH2_MPIEXEC
    OUTPUT=`$I2G_MPI_START -np 2`
    assertEquals "0" "$?"
    echo $OUTPUT | grep $MPI_MPICH2_MPIEXEC_PARAMS > /dev/null
    assertEquals "0" "$?"
    rm -f $MPI_MPICH2_MPIEXEC
}

testBug50_Hydra() {
    export MPI_MPICH2_MPIEXEC_PARAMS="kkuue"
    OUTPUT=`$I2G_MPI_START -np 2 2>&1`
    assertNotEquals "0" "$?"
    echo $OUTPUT | grep $MPI_MPICH2_MPIEXEC_PARAMS > /dev/null
    assertEquals "0" "$?"
}

. $SHUNIT2

