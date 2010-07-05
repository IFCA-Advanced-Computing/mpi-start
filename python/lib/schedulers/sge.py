import os
import tempfile
import common

name="sge"

machine_file = None
machines = []
hosts = {}

def scheduler_available():
    try:
        hostfile = os.environ['PE_HOSTFILE']
        return True
    except KeyError:
        return False 

def get_machinefile():
    global machine_file
    global machines
    global hosts
    if not machine_file:
        machine_file = tempfile.NamedTemporaryFile()
        hostfile = open(os.environ['PE_HOSTFILE'])
        for line in hostfile:
            fields = line.split()
            hostname = fields[0]
            hostcount = int(fields[1])
            hosts[fields[0]] = int(fields[1])
            if common.config['single_process']:
                hostcount = 1
            for i in xrange(hostcount):
                machine_file.write('%s\n' % hostname)
                machines.append(hostname)
            machine_file.file.flush()
        hostfile.close()
        os.environ['MPI_START_MACHINEFILE'] = machine_file.name
    return machine_file.name

def get_hosts():
    return hosts

def get_np():
    return len(machines)
