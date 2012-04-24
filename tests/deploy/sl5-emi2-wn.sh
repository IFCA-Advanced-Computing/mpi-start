#!/bin/sh

export OSTYPE=sl5
type=wn

bash ./config-repo-$os.sh
bash ./install-$type-emi2.sh
bash ./config-$type.sh
