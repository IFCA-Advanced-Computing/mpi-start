#!/bin/bash
# Test for https://github.com/IFCA/mpi-start/issues/1

oneTimeSetUp () {
    export I2G_MPI_START_ENABLE_TESTING="TEST"
    # source the mpi-start code to have all functions
    . $I2G_MPI_START
    mpi_start_check_options
    export I2G_MPI_START_VERBOSE=1
}

setUp() {
    export MPI_START_ETC_LIST=`$MYMKTEMP -d`
    export MPI_LOADED=0
    export MPI_LOADED_2=0
}

tearDown() {
    rm -rf $MPI_START_ETC_LIST
}

oneTimeTearDown () {
    for f in $MPI_START_CLEANUP_FILES; do
        [ -f "$f" ] && rm -f $f
        [ -d "$f" ] && rm -rf $f
    done
}

testConfigDistReleaseArch() {
    echo "export MPI_LOADED=1" > $MPI_START_ETC_LIST/mpi-config.${MPI_START_OS_DIST_TYPE}${MPI_START_OS_RELEASE_MAJOR}-${MPI_START_ARCH}
    assertEquals "0" "$MPI_LOADED"
    assertEquals "0" "$MPI_LOADED_2"
    mpi_start_load_mpi_config
    assertEquals "1" "$MPI_LOADED"
    assertEquals "0" "$MPI_LOADED_2"
}

testConfigDistRelease() {
    echo "export MPI_LOADED=1" > $MPI_START_ETC_LIST/mpi-config.${MPI_START_OS_DIST_TYPE}${MPI_START_OS_RELEASE_MAJOR}
    assertEquals "0" "$MPI_LOADED"
    assertEquals "0" "$MPI_LOADED_2"
    mpi_start_load_mpi_config
    assertEquals "1" "$MPI_LOADED"
    assertEquals "0" "$MPI_LOADED_2"
}

testConfigDist() {
    echo "export MPI_LOADED=1" > $MPI_START_ETC_LIST/mpi-config.${MPI_START_OS_DIST_TYPE}
    assertEquals "0" "$MPI_LOADED"
    assertEquals "0" "$MPI_LOADED_2"
    mpi_start_load_mpi_config
    assertEquals "1" "$MPI_LOADED"
    assertEquals "0" "$MPI_LOADED_2"
}

testConfigUname() {
    echo "export MPI_LOADED=1" > $MPI_START_ETC_LIST/mpi-config.${MPI_START_UNAME}
    assertEquals "0" "$MPI_LOADED"
    assertEquals "0" "$MPI_LOADED_2"
    mpi_start_load_mpi_config
    assertEquals "1" "$MPI_LOADED"
    assertEquals "0" "$MPI_LOADED_2"
}

testConfigLocal() {
    echo "export MPI_LOADED=1" > $MPI_START_ETC_LIST/mpi-config.local
    assertEquals "0" "$MPI_LOADED"
    assertEquals "0" "$MPI_LOADED_2"
    mpi_start_load_mpi_config
    assertEquals "1" "$MPI_LOADED"
    assertEquals "0" "$MPI_LOADED_2"
}

testConfigOrderDistReleaseArch() {
    echo "export MPI_LOADED=1" > $MPI_START_ETC_LIST/mpi-config.local
    echo "export MPI_LOADED_2=1" > $MPI_START_ETC_LIST/mpi-config.${MPI_START_OS_DIST_TYPE}${MPI_START_OS_RELEASE_MAJOR}-${MPI_START_ARCH}
    echo "export MPI_LOADED_2=2" > $MPI_START_ETC_LIST/mpi-config.${MPI_START_OS_DIST_TYPE}${MPI_START_OS_RELEASE_MAJOR}
    echo "export MPI_LOADED_2=3" > $MPI_START_ETC_LIST/mpi-config.${MPI_START_OS_DIST_TYPE}
    echo "export MPI_LOADED_2=4" > $MPI_START_ETC_LIST/mpi-config.${MPI_START_UNAME}
    assertEquals "0" "$MPI_LOADED"
    assertEquals "0" "$MPI_LOADED_2"
    mpi_start_load_mpi_config
    assertEquals "1" "$MPI_LOADED"
    assertEquals "1" "$MPI_LOADED_2"
}

testConfigOrderDistRelease() {
    echo "export MPI_LOADED=1" > $MPI_START_ETC_LIST/mpi-config.local
    echo "export MPI_LOADED_2=2" > $MPI_START_ETC_LIST/mpi-config.${MPI_START_OS_DIST_TYPE}${MPI_START_OS_RELEASE_MAJOR}
    echo "export MPI_LOADED_2=3" > $MPI_START_ETC_LIST/mpi-config.${MPI_START_OS_DIST_TYPE}
    echo "export MPI_LOADED_2=4" > $MPI_START_ETC_LIST/mpi-config.${MPI_START_UNAME}
    assertEquals "0" "$MPI_LOADED"
    assertEquals "0" "$MPI_LOADED_2"
    mpi_start_load_mpi_config
    assertEquals "1" "$MPI_LOADED"
    assertEquals "2" "$MPI_LOADED_2"
}

testConfigOrderDist() {
    echo "export MPI_LOADED=1" > $MPI_START_ETC_LIST/mpi-config.local
    # darwin is not case sensitive for file names!!!!
    echo "export MPI_LOADED_2=4" > $MPI_START_ETC_LIST/mpi-config.${MPI_START_UNAME}
    echo "export MPI_LOADED_2=3" > $MPI_START_ETC_LIST/mpi-config.${MPI_START_OS_DIST_TYPE}
    assertEquals "0" "$MPI_LOADED"
    assertEquals "0" "$MPI_LOADED_2"
    mpi_start_load_mpi_config
    assertEquals "1" "$MPI_LOADED"
    assertEquals "3" "$MPI_LOADED_2"
}

testConfigOrderUname() {
    echo "export MPI_LOADED=1" > $MPI_START_ETC_LIST/mpi-config.local
    echo "export MPI_LOADED_2=4" > $MPI_START_ETC_LIST/mpi-config.${MPI_START_UNAME}
    assertEquals "0" "$MPI_LOADED"
    assertEquals "0" "$MPI_LOADED_2"
    mpi_start_load_mpi_config
    assertEquals "1" "$MPI_LOADED"
    assertEquals "4" "$MPI_LOADED_2"
}

. $SHUNIT2
