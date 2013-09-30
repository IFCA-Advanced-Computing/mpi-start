#
# OSC mpiexec launcher
#

export OSC_MPIEXEC=0
unset I2G_MPIEXEC_COMM

# detect OSC mpiexec
if test "x$MPI_MPIEXEC" != "x"; then
    local VERSION_INFO=`$MPI_MPIEXEC -version 2>&1`
    st=$?
    if test $st -eq 0 ; then
        echo $VERSION_INFO | grep -i "hydra" > /dev/null 2>&1
        st=$?
        if test $st -ne 0 ; then
            # for sure not hydra, check that we do not have -np option
            $MPI_MPIEXEC 2>&1 | grep -e "-\<np\>" > /dev/null 2>&1
            st=$?
            if test $st -ne 0 ; then
                export OSC_MPIEXEC=1
            fi
        fi
    fi
fi

# start job with OSC mpiexec
# if I2G_MPIEXEC_COMM is defined it sets it as comminucator 
osc_mpiexec () {
    # OSC mpiexec! 
    # if a comm method has already been requested don't set
    if `echo $MPI_GLOBAL_PARAMS | grep -vq "comm=" 2> /dev/null`; then
        if test "x$I2G_MPIEXEC_COMM" != "x" -a "x$MPIEXEC_COMM" = "x" ; then
            MPI_GLOBAL_PARAMS="$MPI_GLOBAL_PARAMS --comm=$I2G_MPIEXEC_COMM"
        fi
    fi
    if test "x$MPI_START_NPHOST" = "x1" ; then
        MPI_GLOBAL_PARAMS="$MPI_GLOBAL_PARAMS -pernode"
    elif test "x${I2G_MPI_PER_NODE}" != "x" ; then
        warn_msg "Per node option ignored when using OSC mpiexec"
    fi
    mpi_start_get_plugin "generic_mpiexec.sh" 1
    . $MPI_START_PLUGIN_FILES
    generic_mpiexec
}
