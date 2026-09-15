#!/bin/bash

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run with root priv"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

launch_demo(){
    local DEMO_CONF="$SCRIPT_DIR/../conf"
    local DEMO_APP="$DEMO_CONF/app/application.yaml"
    local DEMO_SECRET="$DEMO_CONF/argocd/secret.yaml"

    echo "Launching demo app..."
    kubectl apply -f "$DEMO_SECRET","$DEMO_APP"
}

main(){
    launch_demo
}

main