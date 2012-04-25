#!/bin/bash

OSTYPE=sl5
TYPE=$2
export OSTYPE

bash ./repo-emi1-$OSTYPE.sh
bash ./install-$TYPE-emi1-$OSTYPE.sh
bash ./config-$TYPE.sh

# update and config again!
bash ./repo-$OSTYPE.sh NOUPDATE
bash ./upgrade-$TYPE-emi2-$OSTYPE.sh
bash ./config-$TYPE.sh
