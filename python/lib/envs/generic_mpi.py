import os
import common
import logging
import subprocess
import envs.generic_starter as starter

def activate_mpi(prefix, mods=None):
    logging.debug("Activating MPI in %s, mods %s" % (prefix, mods))
    if mods: 
        logging.debug("activate MPI via modules...")
        for mod in mods:
            logging.debug("+ module load: %s" % mod)
            #module load mod
    else:
        path = common.get_from_env('PATH')
        os.environ['PATH'] = os.path.join(prefix, 'bin') + os.path.pathsep + path 
        lib_path = common.get_from_env('LD_LIBRARY_PATH')
        os.environ['LD_LIBRARY_PATH'] = os.path.join(prefix, 'bin') + os.path.pathsep + lib_path 

def start_job():
    config = common.config
    if 'I2G_USE_MARMOT' in os.environ:
        marmot_installation = '/opt/i2g/marmot'
        os.environ['LD_PRELOAD'] = '%s/lib/shared/libmarmot-profile.so %s/lib/shared/lib/marmot-core.so /usr/lib/libstdc++.so.5' % marmot_installation
        os.environ['MARMOT_LOGFILE_PATH'] = '/tmp'
    if 'I2G_USE_MPITRACE' in os.environ:
        mpitrace_installation = '/opt/i2g/mpitrace'
        config['parallel_env'] = '%s/bin/mpitrace' % mpitrace_installation + config['parallel_env']
    st = starter.start_job(config['pre_command'], config['parallel_env'], config['user_app'],
                           config['user_app_args'], config['stdin'], config['stdout'], config['stderr'])
    return st
