#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

setup_gitlab(){
    local APP_MANIFEST="$SCRIPT_DIR/../conf/gitlab/"
    local APP_VOLUME="$APP_MANIFEST/volume.yaml"
    local APP_SERVICE="$APP_MANIFEST/service.yaml"
    local APP_DEPLOYMENT="$APP_MANIFEST/deployment.yaml"

    echo "Setting up gitlab..."
    if ! kubectl get ns | grep -i "gitlab" >/dev/null; then
        kubectl create namespace gitlab
    fi

    kubectl apply -f "$APP_VOLUME","$APP_DEPLOYMENT","$APP_SERVICE"
}

wait_gitlab(){
    local GITLAB_SERVER="http://localhost:32000"

    until curl $GITLAB_SERVER &> /dev/null; do
        echo "Waiting gitlab to be up..."
        sleep 42 
    done

    POD_NAME=$(kubectl get pods -n gitlab -o jsonpath='{.items[0].metadata.name}')
    PASSWD=$(kubectl exec -ti $POD_NAME -n gitlab -- grep -i "password:" /etc/gitlab/initial_root_password)
    echo "$PASSWD"
    kubectl get pods -n gitlab
    kubectl top pods -n gitlab
}

setup_argocd(){
    local ARGOCD_MANIFEST="$SCRIPT_DIR/../conf/argocd/install.yaml"

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
    setup_gitlab
    wait_gitlab
    setup_argocd
}

main