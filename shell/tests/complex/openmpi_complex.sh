#!/bin/sh

cp -f /bin/hostname my_hostname
cp -f /bin/date     my_date

echo "#!/bin/sh"      > complex.sh
echo "./my_hostname" >> complex.sh
echo "sleep 30"       >> complex.sh
echo "./my_date"     >> complex.sh

chmod +x complex.sh

export I2G_MPI_TYPE=openmpi
export I2G_MPI_FLAVOUR=openmpi
export I2G_MPI_APPLICATION=complex.sh
export I2G_MPI_APPLICATION_ARGS=
export I2G_MPI_NP=4
export I2G_MPI_JOB_NUMBER=0
export I2G_MPI_STARTUP_INFO=
export I2G_MPI_PRECOMMAND=
export I2G_MPI_RELAY=

$I2G_MPI_START
