#!/bin/bash

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run with root priv"
    exit 1
fi

destroy_resources()
{
    local ARGOCD_PORT=8080
    
    echo "Destroying resources..."
    if ! k3d cluster list | grep -i "p3-cluster" >/dev/null; then
        echo "Cluster is already deleted!"
        return 0
    fi

    kubectl delete all --all -n dev
    kubectl delete apps --all -n argocd
    kubectl delete ns dev argocd
    k3d cluster delete p3-cluster
}

main(){
    destroy_resources
}

main