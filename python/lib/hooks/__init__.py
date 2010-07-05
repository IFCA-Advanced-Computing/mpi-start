import os
import logging

import common 
import commands
import tempfile
import imp

filedist_mod = None
filedist_methods = {}

#pre_hooks = [
#    {'name': 'compiler', 'mod': 'hooks.compiler',},
#    {'name': 'local', 'mod': 'hooks.local', 'path': os.path.join(common.base)},
#    {'name': 'user', 'mod': 'hooks.user', 'path': 'I2G_MPI_PRE_RUN_HOOK'},
#]

def detect_shared_fs():
    (status, output) = commands.getstatusoutput('mount')
    if status:
        logging.warn(' could not execute mount to check fs')
        logging.debug(' command output: %s' % output)
    # XXX assuming Linux mount command output, this may change for other OS:
    # /device/ on /mount_point/ type /fstype/ (/options/)
    import re
    p = re.compile(r'^.* on (?P<point>.*) type (?P<type>.*) \((?P<options>.*\))')
    mount_points = {} 
    for line in output.split('\n'):
        result = p.match(line)
        if not result:
            logging.debug(" mount output line does not match our re!")
            logging.debug(" line: %s" % line)
            continue
        mount_points[result.group('point')] = result.group('type')
    logging.debug("dump mount point information")
    for m in mount_points.items():
        logging.debug("=> %s = %s"% (m[0], m[1]))
    # this will resolve sym links for us, no need to check them!
    cwd = os.path.realpath(os.path.curdir)
    logging.debug("current working directory: %s", cwd)
    fs = None
    while not fs:
        if os.path.ismount(cwd):
            try:
                fs = mount_points[cwd]
            except KeyError:
                pass
            break
        if cwd == '/':
            break
        else:
            cwd = os.path.dirname(cwd)
    if not fs: 
        logging.warn("mount fs for '%s' not found, assuming not shared" % cwd)
        return False
    if fs in ['nfs', 'gfs', 'afs', 'smb', 'gpfs', 'lustre']:
        logging.debug("found network fs: %s", fs)
        return True
    else:
        logging.debug("found local fs: %s", fs)
        return False


def filedist_mod_load(name, path):
    try:
        mod = imp.load_source(name, path)
        logging.debug(" checking module: %s" % mod.__name__)
        priority = mod.check_distribution_method()
        filedist_methods[mod.__name__] = [mod, priority]
    except Exception, e:
        logging.warn("Error while trying to load distribution method %s:" % name)
        logging.warn(" => %s" % e)
    return False

def do_file_distribution():
    logging.debug("fs not shared -> distribute binary")

    hosts = common.config['scheduler'].get_hosts()
    if len(hosts) == 1:
        logging.debug("only localhost -> skip distribution")
        return 0

    # create tar
    tarball = tempfile.NamedTemporaryFile()
    try:
        mydir = os.path.dirname(os.environ['EDG_WL_RB_BROKERINFO'])
    except KeyError:
        mydir = os.path.realpath('.')
    try:
        user_proxy = os.environ['X509_USER_PROXY']
    except KeyError:
        user_proxy = '' 
    hidden_files='$PWD/.[a-zA-Z0-9]*'
    (st, out) = commands.getstatusoutput('tar czf %s --ignore-failed-read %s %s %s' 
                             % (tarball.name, mydir, user_proxy, hidden_files))
    if st != 0:
        logging.error("Error creating tarball: %s" % out)
        return st
    global filedist_mod
    # if : 
    common.load_dir(os.path.join(common.common_path, 'hooks', 'filedist'),
                    filedist_mod_load)
    priority = 255
    for method in filedist_methods.items():
        if priority >= method[1][1]:
            priority = method[1][1]
            filedist_mod = method[1][0]
    if not filedist_mod:
        logging.error("No file distribution method found!")
        return 1
    logging.debug("Using %s as file distribution method" % filedist_mod.__name__)
    return filedist_mod.copy(tarball.name, mydir)


def run_shell_hook(hook_script, function):
    base_script = """#!/bin/bash

warn_msg () {
    if test "x$I2G_MPI_START_VERBOSE" = "x1" ; then 
        echo "mpi-hook [WARNING]:" $@ 
    fi
}

error_msg () {
    echo "mpi-hook  [ERROR  ]:" $@ 
}

debug_msg() {
    if test "x$I2G_MPI_START_VERBOSE" = "x1" ; then 
        if test "x$I2G_MPI_START_DEBUG" = "x1"  ; then
            echo "mpi-hook  [DEBUG  ]: "$@ 
        fi
    fi
}

mpi_start_foreach_host() {
    if test "x$1" = "x"  ; then
        error_msg "mpi_start_foreach called without callback function paramater."
        return 1
    fi
    
    # call callback function
    debug_msg "loop over machine file and call user specific callback"
    for i in `cat $MPI_START_MACHINEFILE | sort -u`; do
        CMD="$1 $i"
        debug_msg " call : $CMD"
        $CMD
    done
}

. %(script_file)s 
result=$?

if test $result -ne 0 ; then
    debug_msg " %(script_file)s file not readable as a hook"
    exit 1
fi

type %(function)s > /dev/null 2>&1
result=$?
if test $result -ne 0 ; then
    debug_msg " %(function)s function is not defined, ignoring"
    exit 0
fi

if test "x$I2G_MPI_START_VERBOSE" = "x1" ; then echo "-<START HOOK>--------------------------------------------"; fi
%(function)s
result=$?
if test "x$I2G_MPI_START_VERBOSE" = "x1" ; then echo "-<STOP HOOK>---------------------------------------------"; fi

exit $result"""
    script_file = tempfile.NamedTemporaryFile()
    script_file.write(base_script % {'script_file': hook_script , 'function': function})
    script_file.file.flush()
    logging.debug(" running hook script %s" % hook_script)
    ret = os.system('/bin/sh %s' % script_file.name)
    script_file.close()
    return ret

def pre_run_hook():
    logging.debug("Loading and running PRE run hooks")
    shared_fs = detect_shared_fs()
    os.environ['I2G_MPI_SHARED_FS'] = '%d' % shared_fs
    # XXX find a better way to do this hook thing, theres too much
    # code duplicated
    try:
        import hooks.compiler
        result = hooks.compiler.pre_hook()
        if result != 0:
            logging.error(" compiler hook returned %d" % result)
            return result
    except (ImportError, AttributeError), e:
        print e
        logging.debug(" compiler hooks not found, ignoring")
    try:
        import hooks.local
        result = hooks.local.pre_hook()
        if result != 0:
            logging.error(" local hook returned %d" % result)
            return result
    except (ImportError, AttributeError):
        logging.debug(" python local hooks not found, trying shell hook")
        local_hook_path = os.path.join(common.etc_path, 'mpi-start.hooks.local')
        if os.path.exists(local_hook_path):
            result = run_shell_hook(local_hook_path, 'pre_run_hook')
            if result != 0:
                logging.error(" local hook returned %d" % result)
                return result
        else:
            logging.debug(" python shell local hooks not found either, ignoring")
    try:
        user_hook = os.environ['I2G_MPI_PRE_RUN_HOOK']
        if not os.path.exists(user_hook):
            logging.error(" user hooks file %s not found!", user_hook)
            return 1
        if user_hook.endswith('.py'):
            logging.debug("JARL! no soporto python exts right now!")
            return 1
        else:
            result = run_shell_hook(user_hook, 'pre_run_hook')
            if result != 0:
                logging.error(" user hook returned %d" % result)
                return result
    except KeyError:
        logging.debug(" user hooks not defined, ignoring")
    if not shared_fs:
        res = do_file_distribution()
        if res != 0:
            return res
    return 0

def post_run_hook():
    logging.debug("Loading and running POST run hooks")
    # XXX find a better way to do this hook thing, theres too much
    # code duplicated
    try:
        import hooks.local
        result = hooks.local.post_hook()
        if result != 0:
            logging.error(" local hook returned %d" % result)
            return result
    except (ImportError, AttributeError):
        logging.debug(" python local hooks not found, trying shell hook")
        local_hook_path = os.path.join(common.etc_path, 'mpi-start.hooks.local')
        if os.path.exists(local_hook_path):
            result = run_shell_hook(local_hook_path, 'post_run_hook')
            if result != 0:
                logging.error(" local hook returned %d" % result)
                return result
        else:
            logging.debug(" python shell local hooks not found either, ignoring")
    try:
        user_hook = os.environ['I2G_MPI_POST_RUN_HOOK']
        if not os.path.exists(user_hook):
            logging.error(" user hooks file %s not found!", user_hook)
            return 1
        if user_hook.endswith('.py'):
            logging.debug("JARL! no soporto python exts right now!")
            return 1
        else:
            result = run_shell_hook(user_hook, 'post_run_hook')
            if result != 0:
                logging.error(" user hook returned %d" % result)
                return result
    except KeyError:
        logging.debug(" user hooks not defined, ignoring")
    if filedist_mod:
        logging.debug(" calling clean method of file distribution")
        res = filedist_mod.clean()
        if res != 0:
            return res
    return 0


