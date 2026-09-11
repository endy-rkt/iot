#!/bin/bash

#this script is to run with root privilege
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run with root priv"
    exit 1
fi

SHARE_USER="vboxsf"
DATA_DIR="/media/sf_iot_volumes"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

manage_volume(){
    mkdir -p $DATA_DIR/{gitlab_config,gitlab_logs,gitlab_data}
    chown $SUDO_USER:$SHARE_USER -R $DATA_DIR
}

manage_cluster(){
    if k3d cluster list | grep -i p3-cluster &> /dev/null; then
        echo "deleting p3-cluster..."
        k3d cluster delete p3-cluster
    fi

    if ! k3d cluster list | grep -i bonus-cluster &> /dev/null; then
        echo "creating bonus-cluster..."
        k3d cluster create bonus-cluster -p "32000:32000@server:0" -p "32001:32001@server:0" -p "30042:30042@server:0"
    fi
}

install_docker(){
    if docker ps &> /dev/null; then
        echo "docker is already running..."
        return 0
    fi

    echo "installing docker..."
    apt update && apt install -y curl
    curl -fsSL https://get.docker.com -o get-docker.sh
    chmod +x get-docker.sh && ./get-docker.sh
    rm get-docker.sh

    #enable docker
    systemctl start docker
    systemctl enable docker
    
    #make docker rootless
    groupadd docker
    usermod -aG docker $USER
    if [ -n "$SUDO_USER" ]; then
        usermod -aG docker $SUDO_USER
        sudo -u $SUDO_USER newgrp docker
    fi
}

install_k3d(){
    #install k3d
    if ! k3d version &>/dev/null; then
        echo "installing k3d..."
        wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

        #enable k3d for simple user
        if [ -n "$SUDO_USER" ]; then
            echo "enabling k3d for simple user..."
            mkdir -p /home/$SUDO_USER/.kube
            k3d kubeconfig merge --all --output /home/$SUDO_USER/.kube/config
            chown -R $SUDO_USER:$SUDO_USER /home/$SUDO_USER/.kube
        fi
    fi
}

install_kubectl(){
    if ! kubectl &>/dev/null; then
        echo "installing kubectl..."
        curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
        chmod +x kubectl && mv kubectl /usr/bin
    fi 
}

install_docker
install_k3d
install_kubectl
manage_volume
manage_cluster
chmod +x $SCRIPT_DIR/setup-cluster.sh && $SCRIPT_DIR/setup-cluster.sh
