#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

forward_argocd_port(){
    local ARGOCD_PORT=8080

    if [ -n "$SUDO_USER" ]; then
        if lsof -i :$ARGOCD_PORT > /dev/null; then
            echo "Cleaning argocd port $ARGOCD_PORT..."
            PID=$(lsof -i :$ARGOCD_PORT | grep LISTEN | head -n 1| awk '{print $2}')
            kill -9 $PID
            sleep 5
        fi

        echo "Forwarding argocd default ports to $ARGOCD_PORT..."
        sudo -u $SUDO_USER kubectl port-forward svc/argocd-server -n argocd $ARGOCD_PORT:443 &
    fi
}

setup_argocd(){
    local ARGOCD_MANIFEST="$SCRIPT_DIR/../conf/install.yaml"

    echo "Setting up argocd..."
    kubectl create namespace argocd
    if ! kubectl apply -n argocd --server-side --force-conflicts -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml; then
        echo "Setting up argocd using local install manifest..."
        kubectl apply -n argocd --server-side --force-conflicts -f "$ARGOCD_MANIFEST"
    fi

    #wait for argocd to be ready
    kubectl wait --for=condition=available deployment \
        -l app.kubernetes.io/name=argocd-server \
        -n argocd \
        --timeout=420s
    
    #take the password
    local PASSWD=$(kubectl -n argocd get secrets argocd-initial-admin-secret -o yaml  | grep "==" | awk '{print $2}'| base64 -d)
    echo "password: $PASSWD"    
}

main(){
    local APP_MANIFEST="$SCRIPT_DIR/../conf/application.yaml"

    if ! kubectl get ns | grep -i "dev" >/dev/null; then
        kubectl create namespace dev
    fi

    if kubectl get ns | grep -i "argocd" >> /dev/null; then
        echo "Argocd already setted!"
        return 0
    fi

    setup_argocd
    forward_argocd_port
    
    #link application to argocd
    kubectl apply -f $APP_MANIFEST
}

main