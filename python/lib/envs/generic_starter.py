import os
import logging
import subprocess

def start_job(pre_command, parallel_env, user_app, user_app_args, stdin, stdout, stderr):
    cmd = pre_command + parallel_env + user_app + user_app_args
    logging.debug("Executing %s" % ' '.join(cmd))
    fstdin = None
    fstdout = None
    fstderr = None
    if stdin:
        try:
            fstdin = open(stdin, 'r')
        except Exception, e:
            logging.warn("Could not open stdin %s, continue without it", stdin)
    if stdout:
        try:
            fstdout = open(stdout, 'r')
        except Exception, e:
            logging.warn("Could not open stdout %s, continue without it", stdout)
    if stderr:
        if stdout == stderr:
            fstderr = fstdout
        else:
            try:
                fstderr = open(stderr, 'r')
            except Exception, e:
                logging.warn("Could not open stdout %s, continue without it", stderr)
    st = subprocess.call(cmd, stdin=fstdin, stdout=fstdout)
    if st != 0:
        if st & 0x00FF:
            return st & 0x00FF
        else:
            return (st & 0xFF00) >> 8
    return st


#    if 'I2G_USE_MARMOT' in os.environ:
#        marmot_installation = '/opt/i2g/marmot'
#        os.environ['LD_PRELOAD'] = '%s/lib/shared/libmarmot-profile.so %s/lib/shared/lib/marmot-core.so /usr/lib/libstdc++.so.5' % marmot_installation
#        os.environ['MARMOT_LOGFILE_PATH'] = '/tmp'
#    if 'I2G_USE_MPITRACE' in os.environ:
#        mpitrace_installation = '/opt/i2g/mpitrace'
#        starter_args.insert(0, '%s/bin/mpitrace')
#    if 'I2G_MPI_PRECOMMAND' in os.environ:
#        starter_args.insert(0, os.environ['I2G_MPI_PRECOMMAND'])
#    starter_args.extend(user_app_args)
#
#    logging.debug("execute: %s" % starter_args)
#    #CMD="$I2G_MPI_PRECOMMAND $MPIEXEC $MPI_SPECIFIC_PARAMS $I2G_MACHINEFILE_AND_NP $I2G_MPI_APPLICATION $I2G_MPI_APPLICATION_ARGS"
#
#start_job([])

