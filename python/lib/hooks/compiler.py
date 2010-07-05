import os
import logging
import tempfile
import subprocess
import shlex 
import shutil
import common

# return values
#  0: flags ok
#  1: flags broken
# -1: mpicc broken
def check_mpicc_flags():
    logging.debug("checking compiler flags")
    tempdir = tempfile.mkdtemp()
    src = os.path.join(tempdir, 'src.c')
    src_file = open(src, 'w+')
    src_file.write("""
#include <mpi.h>
int main(int argc, char **argv) { MPI_Init(&argc, &argv); return 0; }""")
    src_file.close()
    cmd = 'mpicc '
    if 'MPI_MPICC_OPTS' in os.environ:
        cmd += os.environ['MPI_MPICC_OPTS']
    cmd += ' %s -o %s' % (src, os.path.join(tempdir, 'exe')) 
    nullfile = open(os.devnull, 'w')
    ret = 0
    try:
        logging.debug("Trying to compile: %s" % cmd)
        ret = subprocess.call(shlex.split(cmd), stdout=nullfile, stderr=nullfile)
        logging.debug("Result is %s" % ret)
        if ret != 0:
            ret = 1
    except OSError:
        ret = -1   # probably command not found, cannot compile
    shutil.rmtree(tempdir)
    return ret 

def is_64bit():
    if common.config['pe'].name == 'openmpi':
        try:
            # try with opal_info
            p = subprocess.Popen(['opal_info', '--parseable', '--arch'], stdout=subprocess.PIPE)
            (out, err) = p.communicate()
            if p.returncode == 0:
                return (out.find('x86_64') >= 0)
        except OSError:
            pass
        try: 
            # try with omp_info
            p = subprocess.Popen(['ompi_info', '--parseable', '--arch'], stdout=subprocess.PIPE)
            (out, err) = p.communicate()
            if p.returncode == 0:
                return (out.find('x86_64') >= 0) 
        except OSError:
            pass 
    if common.config['pe'].name.find('mpich') >= 0:
        try:
            p = subprocess.Popen(['mpicc', '-dumpmachine'], stdout=subprocess.PIPE)
            (out, err) = p.communicate()
            if p.returncode == 0:
                return (out.find('x86_64') >= 0) 
        except OSError:
            pass
    # last resort, try with uname
    try:
        return (os.uname()[4].find('x85_64') >= 0)
    except AttributeError:
        # no uname?!
        return False

def sub_compiler_flags():
    if is_64bit():
        change = ('-m32', '-m64')
    else:
        change = ('-m64', '-m32')
    for var in ['MPI_MPICC_OPTS', 'MPI_MPICXX_OPTS', 
                'MPI_MPIF90_OPTS', 'MPI_MPIF70_OPTS']:
        if var in os.environ:
            os.environ[var] = os.environ[var].replace(change[0], change[1])

def pre_hook():
    check = check_mpicc_flags()
    if check > 0:
        sub_compiler_flags()
    return 0

def post_hook():
    return 0
