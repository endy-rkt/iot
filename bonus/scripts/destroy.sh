#!/bin/bash

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run with root priv"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

destroy_resources(){
    echo "Destroying resources..."
    if ! k3d cluster list | grep -i "bonus-cluster" >/dev/null; then
        echo "Cluster is already deleted!"
        return 0
    fi
    kubectl delete all --all -n dev
    kubectl delete apps --all -n argocd
    
    kubectl delete all --all -n gitlab
    kubectl delete ns dev argocd gitlab
    k3d cluster delete bonus-cluster
}

main(){
    destroy_resources
}

main