#!/bin/bash

echo "setting up the cluster"

setup_argocd(){
    if kubectl get ns | grep -i "argocd" >> /dev/null; then
        echo "argocd already setted"
        return 0
    fi

    echo "setting up argocd..."
    kubectl create namespace argocd
    kubectl apply -n argocd --server-side --force-conflicts -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

    #wait for argocd to be ready
    kubectl wait --for=condition=available deployment \
        -l app.kubernetes.io/name=argocd-server \
        -n argocd \
        --timeout=420s

    #linking argocd to the repo
}

setup_argocd
