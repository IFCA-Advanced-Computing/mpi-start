#!/bin/sh

SUFFIX=$1
NP=$2

echo "Date: `date --utc`"
echo "DN: `voms-proxy-info -identity`"
echo "WN: `hostname -f`"
echo ""

export GLITE_WMS_RB_BROKERINFO=
if [ -n "$GLOBUS_CE" ]; then
    CE_NAME=$GLOBUS_CE
elif [ -n "$GLITE_CE" ]; then
    CE_NAME=$GLITE_CE
else
    CE_NAME=$(glite-brokerinfo getCE 2>/dev/null || echo $GLITE_WMS_LOG_DESTINATION)
fi
export CE=`echo $CE_NAME |awk '{split ($0, x ,":");print x[1]}' 2>/dev/null`
if [ -z "$CE" ]; then
    echo "Couldn't find/discover CE hostname."
    exit 1
fi
#
## Get the foreignkey
#FOREIGNKEY=`ldapsearch -x -h $CE -p 2170 -b o=grid "(&(objectClass=GlueCE)(GlueCEInfoHostName=$CE))" GlueForeignKey | grep "^GlueForeignKey:" | cut -f2 -d":" | tr -d " "`
#if [ -z "$FOREIGNKEY" ]; then
#    echo "Couldn't find/discover CE foreign key."
#    exit 1
#fi
#TAGS=`ldapsearch -x -h emi-demo13.cnaf.infn.it -p 2170 -b o=grid "(&(objectClass=GlueSubCluster)(GlueChunkKey=$FOREIGNKEY))" GlueHostApplicationSoftwareRunTimeEnvironment | cut -f2 -d":" | tr -d " " | grep MPI` 
#
#if [ $? -ne 0 ] ; then
#    echo "Problem retrieving tags from LDAP server."
#    exit 1 
#fi
#

export TAGS="MPICH2 OPENMPI"

echo "MPI tags were found at $CE: $TAGS"


echo ""
echo "MPI environment was found:"
echo "`env|grep MPI_`"

echo ""
echo "Checking MPI-START availability..."
if [ "x${I2G_MPI_START}" == "x" ] ; then
    I2G_MPI_START=`which mpi-start 2> /dev/null`
    if [ $? -ne 0 ]; then
        echo "mpi-start not found and I2G_MPI_START variable no set!"
        echo "MPI Status: ERROR"
        exit 1
    fi
fi
echo "I2G_MPI_START=$I2G_MPI_START"
echo ""

NPEXEC=`mktemp`
cat > $NPEXEC << EOF
#!/bin/sh

echo \$MPI_START_NP
EOF

chmod +x $NPEXEC
np=`$I2G_MPI_START -t dummy -- $NPEXEC` 
if [ $? -ne 0 ]; then
    echo "unable to execute dummy test!"
    echo "MPI Status: ERROR"
    exit 1
fi

echo "Detected number of proceses: $np"

if [ "x$np" != "x$NP" ] ; then
    echo "mpi-start detected wrong number of processes (expected $NP)"
    echo "MPI Status: ERROR"
    exit 1
fi


echo `date --utc`
zero=0
for flavor in "MPICH" "MPICH2" "OPENMPI" ; do
    echo $TAGS | grep "\<${flavor}\>" > /dev/null
    if [ $? -eq 0 ] ; then
        echo ""
        echo "MPI tag \"$flavor\" was found"
        TYPE=`echo $flavor | tr '[:upper:]' '[:lower:]'`
        CPIEX="cpi-${TYPE}${SUFFIX}"
        wget --no-check-certificate http://devel.ifca.es/~enol/mpi/$CPIEX
        chmod +x $CPIEX 
        $I2G_MPI_START -t $TYPE -- $CPIEX 
        st=$?
        if [ $st -eq 0 ] ; then
            echo "$flavor Status: OK"
        else
            echo "$flavor Status: ERROR"
            zero=$st
        fi
    fi
done

if [ $zero -eq 0 ]; then
    echo "MPI Status: OK"
    echo "summary: MPI Status: OK"
    exit 0
else
    echo "MPI Status: ERROR"
    echo "summary: MPI Status: ERROR"
    exit 1 
fi

exit 0
