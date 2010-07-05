import os
import logging
import common
import subprocess
import envs.generic_starter as starter

name = "ssh"

def start_job():
    config = common.config
    final_st = 0
    for hosts in config['scheduler'].get_hosts().items():
        for it in xrange(hosts[1]):
            if hosts[0] not in common.thishost:
                config['parallel_env'] = ['ssh', '%s' % hosts[0]]
            else:
                config['parallel_env'] = []
            st = starter.start_job()
            if st != 0:
                final_st = st
    return final_st



