#!/bin/sh

main(){
    local INTERFACE_USED="eth1"
    local WORKER_IP="192.168.56.111"
    local K3S_TOKEN_FILE="/vagrant/token"
    local SERVER_URL="https://192.168.56.110:6443"

    if [ ! -f $K3S_TOKEN_FILE ]; then
        echo "Error token to join cluster not found!"
        exit 1
    fi

    K3S_TOKEN=$(cat $K3S_TOKEN_FILE)

    echo "token: $K3S_TOKEN"

    # load overlay module into kernel
    modprobe overlay

    # install latest stable k3s
    curl -sfL https://get.k3s.io -o k3s-install.sh
    K3S_URL=$SERVER_URL K3S_TOKEN="$K3S_TOKEN" INSTALL_K3S_EXEC="agent --node-ip $WORKER_IP --flannel-iface $INTERFACE_USED" sh k3s-install.sh 
}

main
