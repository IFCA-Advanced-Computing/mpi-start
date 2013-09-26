#!/bin/bash
# Test for https://github.com/IFCA/mpi-start/issues/1

oneTimeSetUp () {
    export I2G_MPI_START_ENABLE_TESTING="TEST"
    # source the mpi-start code to have all functions
    . $I2G_MPI_START
    mpi_start_check_options
}

oneTimeTearDown () {
    for f in $MPI_START_CLEANUP_FILES; do
        [ -f "$f" ] && rm -f $f
        [ -d "$f" ] && rm -rf $f
    done
}

fake_osc_mpiexec() {
    echo "fake OSC mpiexec, no options" 1>&2
}

fake_mpiexec() {
    echo "fake mpiexec -np option" 1>&2
}

fake_hydra_mpiexec() {
    echo "fake hydra mpiexec, fake no options" 1>&2
}

testValidOSCmpiexec() {
    export MPI_MPIEXEC=fake_osc_mpiexec
    mpi_start_get_plugin "osc_mpiexec.sh" 1
    . $MPI_START_PLUGIN_FILES
    assertEquals "1" "$OSC_MPIEXEC"
}

testInvalidOSCmpiexec() {
    export MPI_MPIEXEC=fake_mpiexec
    mpi_start_get_plugin "osc_mpiexec.sh" 1
    . $MPI_START_PLUGIN_FILES
    assertEquals "0" "$OSC_MPIEXEC"
}

testHydrampiexec() {
    export MPI_MPIEXEC=fake_hydra_mpiexec
    mpi_start_get_plugin "osc_mpiexec.sh" 1
    . $MPI_START_PLUGIN_FILES
    assertEquals "0" "$OSC_MPIEXEC"
}


. $SHUNIT2
