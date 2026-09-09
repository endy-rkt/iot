#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "setting up the cluster..."

setup_gitlab(){
    local APP_MANIFEST="$SCRIPT_DIR/../conf/gitlab/"
    local APP_VOLUME="$APP_MANIFEST/volume.yaml"
    local APP_SERVICE="$APP_MANIFEST/service.yaml"
    local APP_DEPLOYMENT="$APP_MANIFEST/deployment.yaml"

    echo "setting up gitlab..."
    if ! kubectl get ns | grep -i "gitlab" >/dev/null; then
        kubectl create namespace gitlab
    fi

    kubectl apply -f "$APP_VOLUME","$APP_DEPLOYMENT","$APP_SERVICE"
}

setup_argocd(){
    local ARGOCD_PORT=8080
    local app_manifest="$SCRIPT_DIR/../conf/argocd/application.yaml"

    echo "setting up argocd..."
    #create app namespace
    if ! kubectl get ns | grep -i "dev" >/dev/null; then
        kubectl create namespace dev
    fi

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
    
    #take the password
    local PASSWD=$(kubectl -n argocd get secrets argocd-initial-admin-secret -o yaml  | grep "==" | awk '{print $2}'| base64 -d)
    echo "password: $PASSWD"
    
    #linking argocd to the repo
    kubectl apply -f $app_manifest
    
    #forword argocd and app port
    if [ -n "$SUDO_USER" ]; then
        if lsof -i :$ARGOCD_PORT > /dev/null; then
            echo "cleaning argocd port $ARGOCD_PORT..."
            PID=$(lsof -i :$ARGOCD_PORT | grep LISTEN | head -n 1| awk '{print $2}')
            kill -9 $PID
            sleep 3
        fi

        echo "forwarding argocd default ports to $ARGOCD_PORT..."
        sudo -u $SUDO_USER kubectl port-forward svc/argocd-server -n argocd $ARGOCD_PORT:443 &
    fi
}

setup_gitlab
# setup_argocd
