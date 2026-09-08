#!/bin/bash

#this script is to run with root privilege
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run with root priv"
    exit 1
fi

#create folder for volumes
DATA_DIR="/home/$SUDO_USER/data"
mkdir -p $DATA_DIR/{gitlab_config,gitlab_logs,gitlab_data}
chown $SUDO_USER:$SUDO_USER -R $DATA_DIR

