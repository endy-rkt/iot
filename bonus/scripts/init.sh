#!/bin/bash

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run with root priv!"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

install_docker(){
    echo "Installing docker..."
    apt update && apt install -y curl
    curl -fsSL https://get.docker.com -o get-docker.sh
    chmod +x get-docker.sh && ./get-docker.sh
    rm get-docker.sh
}

setup_docker(){
    if docker ps &> /dev/null; then
        echo "Docker is already installed!"
        return 0
    fi

    install_docker
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
    if ! k3d version &>/dev/null; then
        echo "Installing k3d..."
        wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
    fi
}

merge_k3d_config(){
    if [ -n "$SUDO_USER" ]; then
        echo "Merging k3d config with kubectl for rootless user..."
        mkdir -p /home/$SUDO_USER/.kube
        k3d kubeconfig merge --all --output /home/$SUDO_USER/.kube/config --overwrite
        chown -R $SUDO_USER:$SUDO_USER /home/$SUDO_USER/.kube
        chmod 600 /home/$SUDO_USER/.kube/config
    fi
}

install_kubectl(){
    if ! kubectl version --client &>/dev/null; then
        echo "Installing kubectl..."
        curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
        chmod +x kubectl && mv kubectl /usr/bin
    fi 
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

manage_volume(){
    local SHARE_USER="vboxsf"
    local DATA_DIR="/media/sf_iot_volumes"

    mkdir -p $DATA_DIR/{gitlab_config,gitlab_logs,gitlab_data}
    chown $SUDO_USER:$SHARE_USER -R $DATA_DIR
}

main(){
    setup_docker
    install_k3d
    install_kubectl
    manage_cluster
    merge_k3d_config
    manage_volume
}

main