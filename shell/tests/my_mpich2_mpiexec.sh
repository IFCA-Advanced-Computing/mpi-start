#!/bin/sh

echo "***************************************"
echo " my_mpiexec.sh "
echo "***************************************"


# take care that the ".mpd.conf" file is available
echo "MPD_SECRETWORD=" > $HOME/.mpd.conf
chmod 0600 $HOME/.mpd.conf

# Start MPICH2 daemon.
mpdboot -n `cat $MPI_START_MACHINEFILE | sort -u | wc -l` -f $MPI_START_MACHINEFILE

/opt/mpich2-1.0.5p4/bin/mpiexec $@

# Stop MPICH2 daemons
mpdallexit

