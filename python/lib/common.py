#
# Copyright (c) 2010 Instituto de Fisica de Cantabria, 
#                    CSIC-UC. All rights reserved.
# common functionality for mpi-start

import os
import sys
import imp
import logging
import socket
import time
import shlex

version = '0.1.0'
config = {'scheduler': None,
          'pe': None,
          'pre_command': None,
          'user_app': None,
          'user_app_args': None,
          'stdin': None,
          'stdout': None,
          'stderr': None,
          'single_process': False,
         }

tempfiles = []

common_path = os.path.dirname(sys.modules[__name__].__file__)
etc_path = os.path.realpath(os.path.join(common_path, '..', 'etc'))
schedulers_dir = os.path.join(common_path, 'schedulers')
envs_dir = os.path.join(common_path, 'envs')

thishost = ['localhost', socket.getfqdn(), socket.gethostname()]

def do_exit(ret, app = 0):
    for f in tempfiles:
        f.close()
    if ret:
        logging.debug("Dump environment:")
        for v in os.environ:
            logging.debug("=> %s=%s" % (v, os.environ[v]))
        logging.debug("Exiting mpi-start, status: %s" % ret)
        sys.exit(ret)
    else:
        sys.exit(app)

def configure_logging():
    level = logging.ERROR 
    try:
        if os.environ['I2G_MPI_START_VERBOSE'] == '1':
            level=logging.INFO
            try:
                if os.environ['I2G_MPI_START_DEBUG'] == '1':
                    level=logging.DEBUG
            except KeyError, e:
                pass
    except KeyError, e:
        pass
    logging.basicConfig(level=level,
            format="mpi-start [%(levelname)-7s]: %(message)s")

def get_from_env(varname):
    try:
        return os.environ[varname]
    except:
        return ''

def init_config():
    try:
        config['single_process'] = os.environ['I2G_MPI_SINGLE_PROCESS'] == '1' 
    except KeyError:
        config['single_process'] = False
    config['pre_command'] = shlex.split(get_from_env('I2G_MPI_PRECOMMAND'))
    config['user_app'] = shlex.split(get_from_env('I2G_MPI_APPLICATION'))
    config['user_app_args'] = shlex.split(get_from_env('I2G_MPI_APPLICATION_ARGS'))
    config['stdin'] = get_from_env('I2G_MPI_APPLICATION_STDIN')
    config['stdout'] = get_from_env('I2G_MPI_APPLICATION_STDOUT')
    config['stderr'] = get_from_env('I2G_MPI_APPLICATION_STDERR')
    logging.debug('Dump env configuration')
    for v in os.environ:
        if v.startswith('I2G_MPI_'):
            logging.debug("=> %s=%s" % (v, os.environ[v]))
    logging.debug('Dump my configuration:')
    for i in config.items():
        logging.debug("=> %s=%s" % (i[0], i[1]))

def scheduler_mod_load(name, path):
    try:
        logging.debug('name %s path %s' % (name, path))
        mod = imp.load_source(name, path)
        logging.debug(" checking module: %s" % mod.__name__)
        if mod.scheduler_available():
            logging.debug(" activate support for %s" % mod.__name__)
            if mod.get_machinefile():
                config['scheduler'] = mod
                return True
    except Exception, e:
        logging.warn("Error while trying to load scheduler %s:" % name)
        logging.warn(" => %s" % e)
        import traceback
        logging.debug(traceback.format_exc())
    return False

def load_dir(path, load_func):
    if not os.path.isdir(path):
        logging.warn('Trying to load %s, and it is not a directory' % path)
        return
    for f in os.listdir(path):
        if f.startswith("__") or not f.endswith(".py"):
            continue
        fnopy = f.split('.')[0] 
        mod_path = os.path.join(path, f)
        #mod_name = os.path.join(path, fnopy)
        #if load_func(mod_name, mod_path):
        if load_func(fnopy, mod_path):
            break

def load_scheduler():
    logging.debug("Search for scheduler")
    load_dir(schedulers_dir, scheduler_mod_load)
    if not config['scheduler']:
        logging.error("No scheduler found")
        do_exit(1)
    logging.info("Module %s loaded", config['scheduler'].__name__)

def load_pe():
    logging.debug("Checking parallel environment")
    try:
        pe_name = os.environ['I2G_MPI_TYPE']
        logging.debug(" using user requested environment")
    except KeyError:
        try:
            pe_name = os.environ['MPI_DEFAULT_FLAVOUR']
            logging.debug(" using default environment")
        except KeyError:
            logging.error(' no parallel environment specified')
            do_exit(1)
    logging.debug(" activate support for '%s'" % pe_name)
    fname = os.path.join(envs_dir, pe_name + '.py')
    if not os.path.exists(fname):
        logging.error("%s not found!" % fname)
        do_exit(1)
    try:
        config['pe'] = imp.load_source(pe_name, fname)
    except Exception, e:
        logging.error("Error while trying to load environment %s:" % pe_name)
        logging.error(" => %s" % e)
        do_exit(1)
    logging.info("Module %s loaded", config['pe'].__name__)

def start_job():
    import hooks
    pre_command = shlex.split(get_from_env('I2G_MPI_PRECOMMAND'))
    user_app = shlex.split(get_from_env('I2G_MPI_APPLICATION'))
    user_app_args = shlex.split(get_from_env('I2G_MPI_APPLICATION_ARGS'))
    stdin = get_from_env('I2G_MPI_APPLICATION_STDIN')
    stdout = get_from_env('I2G_MPI_APPLICATION_STDOUT')
    stderr = get_from_env('I2G_MPI_APPLICATION_STDERR')
    res = hooks.pre_run_hook()
    if res != 0:
        do_exit(res)
    logging.info('=[START]================================================================')
    app_res = config['pe'].start_job()
    logging.info('=[FINISHED]=============================================================')
    res = hooks.post_run_hook()
    if res != 0:
        do_exit(res)
    return app_res 

def main():
    configure_logging()

    logging.info('*'*50)
    import getpass
    logging.info('UID            = %s' % getpass.getuser())
    logging.info('HOST           = %s' % socket.getfqdn())
    logging.info('DATE           = %s' % time.asctime())
    logging.info('VERSION        = %s' % version)
    logging.info('PYTHON VERSION = %s' % sys.version)
    logging.info('*'*50)

    init_config()
    load_scheduler()
    load_pe()
    do_exit(0, start_job())
