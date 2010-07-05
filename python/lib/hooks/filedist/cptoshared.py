import os
import stat
import common
import socket
import logging
import commands

mydir = None

def check_distribution_method():
    result = 255
    try:
        if os.environ['MPI_SHARED_HOME'] == 'yes':
            logging.debug("Copy to shared path is available!")
            os.environ['MPI_START_SHARED_FS'] = "1"
            result = 0
    except KeyError:
        pass
    return result

def copy(tarball, dir):
    global mydir
    if 'MPI_SHARED_HOME_PATH' not in os.environ:
        logging.error('MPI_SHARED_HOME_PATH is not defined, giving up')
        return 1
    logging.debug("Copying to %s" % os.environ['MPI_SHARED_HOME_PATH'])
    mydir = dir
    if os.path.isabs(dir):
        # will this work under anything not unix??
        dir = dir[1:]
    (st, out) = commands.getstatusoutput('tar xzf %s -C %s' % (tarball, os.environ['MPI_SHARED_HOME_PATH']))
    if st != 0:
        logging.error('failed to untar files in shared directory')
        logging.debug('Output: %s' % out)
        return 1
    if 'EDG_WL_SCRATCH' in os.environ:
        try: 
            os.chmod(os.path.join(os.environ['MPI_SHARED_HOME_PATH'], os.environ['EDG_WL_SCRATCH']),
                     stat.S_IWOTH)
        except Exception, e:
            logging.warn("chmod did not work %s", e)
        try:
            os.chmod(os.path.join(os.environ['MPI_SHARED_HOME_PATH'], os.environ['EDG_WL_SCRATCH'], '.mpi'),
                    stat.S_IWOTH)
        except Exception, e:
            logging.warn("chmod did not work %s", e)
    user_binary = common.config['user_app'][0]
    if not os.path.isabs(user_binary):
        user_binary = os.path.join(os.environ['MPI_SHARED_HOME_PATH'],
                                   dir, user_binary) 
    else:
        if os.path.dirname(user_binary) == os.path.realpath(mydir):
            user_binary = os.path.join(os.environ['MPI_SHARED_HOME_PATH'],
                                       dir, os.path.basename(user_binary))
    common.config['user_app'][0] = user_binary
    os.environ['I2G_MPI_APPLICATION'] = ' '.join(common.config['user_app'])
    os.chdir(os.path.join(os.environ['MPI_SHARED_HOME_PATH'], dir))
    return 0

def clean():
    if not mydir:
        logging.warn('Copy seems not to be done with this module...')
        return 0
    logging.debug("cleaning directory!")
    dir = mydir
    if os.path.isabs(dir):
        # will this work under anything not unix??
        dir = dir[1:]
    shutil.rmtree(os.path.join(os.environ['MPI_SHARED_HOME_PATH'], dir))
    return 0

