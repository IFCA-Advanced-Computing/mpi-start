#!/bin/bash

OSTYPE=$1
TYPE=$2
export OSTYPE

bash ./repo-$OSTYPE.sh
bash ./install-$TYPE-emi2-$OSTYPE.sh
bash ./config-$TYPE.sh
