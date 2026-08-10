#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

install_docker(){
    if docker ps >> /dev/null 2> /dev/null; then
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
    if k3d version >> /dev/null 2>/dev/null; then
        echo "k3d is already installed..."
        return 0
    fi

    echo "installing k3d"
    wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
    k3d cluster create p3-cluster
    if [ -n "$SUDO_USER" ]; then
        k3d kubeconfig merge --all --output /home/$SUDO_USER/.kube/config
        chown -R $SUDO_USER:$SUDO_USER /home/$SUDO_USER/.kube
    fi

    #install kubectl
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x kubectl && mv kubectl /usr/bin
}

install_docker
install_k3d
chmod +x $SCRIPT_DIR/setup-cluster.sh && $SCRIPT_DIR/setup-cluster.sh
