#!/usr/bin/python

import os
import tempfile
import socket

name="fake"

machine_file = None
machines = []
hosts = {}

def scheduler_available():
    return False

def get_machinefile():
    global machine_file
    if not machine_file:
        machine_file = tempfile.NamedTemporaryFile()
        machine_file.write('%s\n' % socket.getfqdn())
        machine_file.file.flush()
        os.environ['MPI_START_MACHINEFILE'] = machine_file.name
        global machines
        machines.append(socket.getfqdn())
        machines.append('gridui.ifca.es')
        global hosts
        hosts[socket.getfqdn()] = 1
        hosts['gridui.ifca.es'] = 1
    return machine_file.name

def get_hosts():
    return hosts

def get_np():
    return len(machines)
