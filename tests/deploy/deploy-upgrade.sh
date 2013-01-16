#!/bin/bash

# 1, 2 
EMIRELEASE=$1 
# sl5, sl6
OSTYPE=$2
# ce, wn
TYPE=$3

if [ $EMIRELEASE = 3 ] ; then
    PREEMIRELEASE=2
else
    PREEMIRELEASE=$EMIRELEASE
fi

./baserepo.sh $PREEMIRELEASE $OSTYPE $TYPE && \
    ./preinstall.sh $PREEMIRELEASE $OSTYPE $TYPE && \
    ./baseinstall.sh $PREEMIRELEASE $OSTYPE $TYPE && \
    ./baseconfig-$TYPE.sh $EMIRELEASE $OSTYPE $TYPE && \
    ./certrepo.sh $EMIRELEASE $OSTYPE $TYPE && \
    ./upgrade.sh $EMIRELEASE $OSTYPE $TYPE && \
    ./config-$TYPE.sh $EMIRELEASE $OSTYPE $TYPE
