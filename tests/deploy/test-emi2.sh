#!/bin/bash

OSTYPE=$1
TYPE=$2
export OSTYPE

bash ./config-repo-$os.sh
bash ./install-$type-emi2.sh
bash ./config-$type.sh
