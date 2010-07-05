import os
import common
import socket
import logging
import commands

mydir = None

def check_distribution_method():
    try:
        if os.environ['MPI_SSH_HOST_BASED_AUTH'] == 'yes':
            return 0
    except KeyError:
        # not sure about this, but it is in the older mpi-start
        if common.config['pe'].name == 'openmpi':
            return 128
    return 255

def copy(tarball, dir):
    global mydir
    mydir = dir
    for host in common.config['scheduler'].get_hosts():
        logging.debug('distribute tarball %s to remote node %s' % (tarball, host))
        if host in common.thishost:
            logging.debug('skip local machine')
            continue
        # create dir
        (st, out) = commands.getstatusoutput('ssh %s "mkdir -p %s"' % (host, mydir))
        if st != 0:
            logging.error('failed to create directory on remote machine')
            logging.debug('Output: %s' % out)
            return 1
        # copy tarball
        (st, out) = commands.getstatusoutput('scp %s %s:%s' % (tarball, host, mydir))
        if st != 0:
            logging.error('failed to copy tarball to remote machine')
            logging.debug('Output: %s' % out)
            return 1
        # unpack tarball
        tarball_base = os.path.basename(tarball)
        cmd = 'cd %s && tar xzf %s -C / && rm -f %s' % (mydir, tarball_base, tarball_base)
        (st, out) = commands.getstatusoutput('ssh %s "%s"' % (host, cmd))
        if st != 0:
            logging.error('failed to unpack files on remote machine')
            logging.debug('Output: %s' % out)
            return 1
    return 0

def clean():
    if not mydir:
        logging.warn('Copy seems not to be done with this module...')
        return 0
    for host in common.config['scheduler'].get_hosts():
        logging.debug('clean directory %s in remote node %s' % (mydir, host))
        if host in common.thishost:
            logging.debug('skip local machine')
            continue
        # create dir
        (st, out) = commands.getstatusoutput('ssh %s "rm -rf %s"' % (host, mydir))
        if st != 0:
            logging.error('failed to remove directory on remote machine')
            logging.debug('Output: %s' % out)
            return 1
    return 0
