#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "setting up the cluster"

setup_argocd(){
    local app_manifest="$SCRIPT_DIR/../conf/application.yaml"

    if kubectl get ns | grep -i "argocd" >> /dev/null; then
        echo "argocd already setted"
        return 0
    fi

    echo "setting up argocd..."
    kubectl create namespace dev
    kubectl create namespace argocd
    kubectl apply -n argocd --server-side --force-conflicts -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

    #wait for argocd to be ready
    kubectl wait --for=condition=available deployment \
        -l app.kubernetes.io/name=argocd-server \
        -n argocd \
        --timeout=420s
    
    #linking argocd to the repo
    kubectl apply -f $app_manifest
    
    #forword argocd and app port
    if [ -n "$SUDO_USER" ]; then
        echo "forwarding argocd default ports to 8080..."
        sudo -u $SUDO_USER kubectl port-forward svc/argocd-server -n argocd 8080:443 &

        # echo "forwarding app default ports to 8888..."
        # sudo -u $SUDO_USER kubectl port-forward svc/p3-svc -n dev 8888:8888 &

    fi
}

setup_argocd
