#!/bin/bash

# 1, 2 
EMIRELEASE=$1 
# sl5, sl6
OSTYPE=$2
# ce, wn
TYPE=$3

./baserepo.sh $EMIRELEASE $OSTYPE $TYPE && \
    ./preinstall.sh $EMIRELEASE $OSTYPE $TYPE && \
    ./certrepo.sh $EMIRELEASE $OSTYPE $TYPE && \
    ./install.sh $EMIRELEASE $OSTYPE $TYPE && \
    ./config-$TYPE.sh $EMIRELEASE $OSTYPE $TYPE
