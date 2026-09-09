#!/bin/bash

#this script is to run with root privilege
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run with root priv"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

destroy_object(){
    local APP_MANIFEST="$SCRIPT_DIR/../conf/gitlab/"
    local APP_SERVICE="$APP_MANIFEST/service.yaml"
    local APP_DEPLOYMENT="$APP_MANIFEST/deployment.yaml"

    echo "destroying the cluster..."
    kubectl apply -f "$APP_DEPLOYMENT","$APP_SERVICE"
    k3d cluster delete bonus-cluster
}

destroy_object
