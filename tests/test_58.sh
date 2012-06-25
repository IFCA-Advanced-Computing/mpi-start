#!/bin/bash

# tests for bug #58

export I2G_MPI_START_ENABLE_TESTING="TEST"
# source the mpi-start code to have all functions
. $I2G_MPI_START
mpi_start_check_options
mpi_start_load_execenv

export moduledir=`$MYMKTEMP -d`
cat > $moduledir/module << EOF
#!/bin/sh

if test "x\$1" = "xload"  ; then
    if test "x\$2" != "x" ; then
        echo "\$2"
        exit 0
    fi
fi

exit 1
EOF

chmod +x $moduledir/module

export PATH=$moduledir:$PATH


testModuleVariable() {
    export I2G_MPI_TYPE="dummy"
    export MPI_DUMMY_MODULES="dummy-module"

    mpi_start_load_execenv
    st=$?
    assertEquals "0" "$st"
    assertEquals "$MPI_DUMMY_MODULES" "$MPI_START_MPI_MODULE"
}

testModuleVersionNoModuleVariable() {
    export I2G_MPI_TYPE="dummy"
    export MPI_DUMMY_VERSION="1.2"
    export MPI_DUMMY_MODULES="dummy-module"

    mpi_start_load_execenv
    st=$?
    assertEquals "0" "$st"
    assertEquals "$MPI_DUMMY_MODULES" "$MPI_START_MPI_MODULE"
}

testModuleVersionModuleVariable() {
    export I2G_MPI_TYPE="dummy"
    export MPI_DUMMY_VERSION="1.2"
    export MPI_DUMMY_MODULES="dummy-module"
    export MPI_DUMMY_1__2_MODULES="dummy-1.2.module"

    mpi_start_load_execenv
    st=$?
    assertEquals "0" "$st"
    assertEquals "$MPI_DUMMY_1__2_MODULES" "$MPI_START_MPI_MODULE"
}

testCallModule() {
    unset I2G_MPI_TYPE
    OUT=`mpi_start_activate_mpi "dummy" mod1`
    st=$?
    assertEquals "0" "$st"
    assertEquals "mod1" "$OUT"
}

testCallMultipleModule() {
    unset I2G_MPI_TYPE
    OUT=`mpi_start_activate_mpi "dummy" mod1 mod2`
    st=$?
    assertEquals "0" "$st"
    assertEquals "mod1
mod2" "$OUT"
}



. $SHUNIT2
