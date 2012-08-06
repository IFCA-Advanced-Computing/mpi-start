#!/bin/bash

#
# Test for #61. 
#

setUp () {
    export I2G_MPI_TYPE="dummy"
    unset I2G_MPI_NP
    unset I2G_MPI_APPLICATION
    unset I2G_MPI_PRE_RUN_HOOK
    unset I2G_MPI_START_DEBUG
    unset I2G_MPI_START_VERBOSE
    unset I2G_MPI_START_TRACE
    unset I2G_MPI_SINGLE_PROCESS
    unset I2G_MPI_NP
    unset I2G_MPI_PER_NODE
    unset VAR
    export MPI_START_SHARED_FS=1
    export MPI_START_DUMMY_SCHEDULER=1
}

testVarJustName () {
	export I2G_MPI_PRE_RUN_HOOK=`$MYMKTEMP`
    cat > $I2G_MPI_PRE_RUN_HOOK << EOF
pre_run_hook() {
	[ -n "\${VAR+x}" ]
}
EOF
	$I2G_MPI_START -d VAR -- true
	st=$?
    assertEquals 0 $st
    rm -rf $I2G_MPI_PRE_RUN_HOOK
}

testVarEmpty () {
	export I2G_MPI_PRE_RUN_HOOK=`$MYMKTEMP`
    cat > $I2G_MPI_PRE_RUN_HOOK << EOF
pre_run_hook() {
	[ -n "\${VAR+x}" ]
}
EOF
	$I2G_MPI_START -d VAR= -- true
	st=$?
    assertEquals 0 $st
}

testVarJustNamePredef() {
	export VAR="foo bar"
	export I2G_MPI_PRE_RUN_HOOK=`$MYMKTEMP`
    cat > $I2G_MPI_PRE_RUN_HOOK << EOF
pre_run_hook() {
	[ "x\$VAR" == "x$VAR" ]
}
EOF
	$I2G_MPI_START -d VAR -- true
	st=$?
    assertEquals 0 $st
}

testVarEmptyPredef() {
	export VAR="foo bar"
	export I2G_MPI_PRE_RUN_HOOK=`$MYMKTEMP`
    cat > $I2G_MPI_PRE_RUN_HOOK << EOF
pre_run_hook() {
	[ -n "\${VAR+x}" ] && [ "x\$VAR" == "x" ]
}
EOF
	$I2G_MPI_START -d VAR= -- true
	st=$?
    assertEquals 0 $st
}

testVarSimpleValue() {
	VALUE="1234"
	export I2G_MPI_PRE_RUN_HOOK=`$MYMKTEMP`
    cat > $I2G_MPI_PRE_RUN_HOOK << EOF
pre_run_hook() {
	[ "x\$VAR" == "x$VALUE" ]
}
EOF
	$I2G_MPI_START -d VAR="$VALUE" -- true
	st=$?
    assertEquals 0 $st
}

testVarValueWithSpaces() {
	VALUE="1234 -foo- 1234"
	export I2G_MPI_PRE_RUN_HOOK=`$MYMKTEMP`
    cat > $I2G_MPI_PRE_RUN_HOOK << EOF
pre_run_hook() {
	[ "x\$VAR" == "x$VALUE" ]
}
EOF
	$I2G_MPI_START -d VAR="$VALUE" -- true
	st=$?
    assertEquals 0 $st
}

testWrongSyntax() {
	$I2G_MPI_START -d V-AR="VALUE" -- true 2> /dev/null
	st=$?
    assertEquals 1 $st
}

. $SHUNIT2
