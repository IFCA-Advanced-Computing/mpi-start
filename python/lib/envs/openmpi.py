import os
import logging
import common
import shlex
import envs.generic_mpi as starter

name = "openmpi"

# default config values
openmpi_prefix = '/usr'

logging.debug("loading open mpi environment")
if 'I2G_OPENMPI_PREFIX' in os.environ:
    openmpi_prefix = os.environ['I2G_OPENMPI_PREFIX']
    logging.debug("use user provided prefix: %s" % openmpi_prefix)
elif 'MPI_OPENMPI_PATH' in os.environ:
    openmpi_prefix = os.environ['MPI_OPENMPI_PATH']
    logging.debug("use user provided prefix: %s" % openmpi_prefix)
elif 'MPI_START_MPI_PREFIX' in os.environ:
    openmpi_prefix = os.environ['MPI_START_MPI_PREFIX']
    logging.debug("use user provided prefix: %s" % openmpi_prefix)
else:
    logging.debug("use default installation: %s" % openmpi_prefix)

starter.activate_mpi(openmpi_prefix)

def start_job():
    config = common.config
    scheduler = config['scheduler']
    # find out which mpiexec to use
    pe = []
    if 'MPI_OPENMPI_MPIEXEC' in os.environ:
        pe += [os.environ['MPI_OPENMPI_MPIEXEC']]
        if 'I2G_MPI_MPIEXEC_PARAMS' in os.environ:
            pe += shlex.split(os.environ['I2G_MPI_MPIEXEC_PARAMS'])
    elif 'MPI_OPENMPI_MPIRUN' in os.environ:
        pe += [os.environ['MPI_OPENMPI_MPIRUN']]
        if 'I2G_OPENMPI_MPIRUN_PARAMS' in os.environ:
            pe += shlex.split(os.environ['I2G_OPENMPI_MPIRUN_PARAMS'])
    else:
        pe += ['mpiexec']

    if scheduler.name != 'pbs':
        logging.debug("found openmpi and a non-PBS batch system, set machinefile and np parameters")
        pe = pe + ['-machinefile', '%s' % scheduler.get_machinefile(),
                   '-np', '%s' % scheduler.get_np()]
    else:
        logging.debug("found openmpi and PBS, don't set machinefile")
        pe = pe + ['-np', '%s' % scheduler.get_np()]
    pe += ['-wdir', os.path.realpath(os.path.curdir)]
    if 'I2G_USE_MARMOT' in os.environ and os.environ['I2G_USE_MARMOT'] == '1':
        logging.debug("export LD_PRELOAD for Open MPI")
        pe += "-x LD_PRELOAD -x MARMOT_MAX_TIMEOUT_DEADLOCK -x MARMOT_LOGFILE_PATH".split()
    if 'X509_USER_PROXY' in os.environ:
        pe += ['-x', 'X509_USER_PROXY']
    pe += ['--prefix', '%s' % openmpi_prefix]
    config['parallel_env'] =  pe
    return starter.start_job()


