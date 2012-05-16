#!/bin/sh
# testing script for sl5 + emi1 installation

bash ./install-wn-emi1-sl5.sh
bash ./config-wn-sl5.sh
bash ./upgrade-wn-emi2-sl5.sh
bash ./config-wn-sl5.sh
