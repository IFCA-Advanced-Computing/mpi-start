import os
import tempfile
import common

name="lsf"

machine_file = None
machines = []
hosts = {}

def scheduler_available():
    try:
        hostfile = os.environ['LSB_HOSTS']
        return True
    except KeyError:
        return False 

def get_machinefile():
    global machine_file
    global machines
    global hosts
    if not machine_file:
        for hostname in os.environ['LSB_HOSTS'].split():
            try:
                hosts[hostname] += 1
            except KeyError:
                hosts[hostname] = 1
        # create machinefile
        machine_file = tempfile.NamedTemporaryFile()
        for host_info in hosts.items():
            if common.config['single_process']:
                nhosts = 1
            else:
                nhosts = host_info[1]
            for i in xrange(nhosts):
                machine_file.write('%s\n' % host_info[0])
                machines.append(host_info[0])
            machine_file.file.flush()
        os.environ['MPI_START_MACHINEFILE'] = machine_file.name
    return machine_file.name

def get_hosts():
    return hosts

def get_np():
    return len(machines)
