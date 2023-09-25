#!/usr/bin/env bash

set -x

#Ensure NOT Ran as Sudo
sudo_check=$(env | grep -i sudo_user)
if [[ ${sudo_check} ]] ; then
   echo "This script must be ran as user. Not root or sudo."
   exit 1
fi

SETUPDIR="company_setups"

sudo $SETUPDIR/install_docker.sh
sudo $SETUPDIR/install_docker_compose.sh
sudo $SETUPDIR/install_gc_sdk.sh
gcloud auth login
gcloud auth application-default login
sudo $SETUPDIR/install_gcsfuse.sh
