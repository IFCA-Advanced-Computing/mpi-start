#
# Regular cron jobs for the mpi-start package
#
0 4	* * *	root	[ -x /usr/bin/mpi-start_maintenance ] && /usr/bin/mpi-start_maintenance
