#!/bin/sh

K3S_TOKEN_FILE="/vagrant/token"
if [ ! -f $K3S_TOKEN_FILE ];then
    echo "token to join cluster not found"
fi
K3S_TOKEN=$(cat $K3S_TOKEN_FILE)
echo $K3S_TOKEN

# load overlay module into kernel
modprobe overlay

# install latest stable k3s
curl -sfL https://get.k3s.io -o k3s-install.sh
K3S_URL=https://192.168.56.110:6443 K3S_TOKEN="$K3S_TOKEN" INSTALL_K3S_EXEC="agent --node-ip 192.168.56.111 --flannel-iface eth1" sh k3s-install.sh 
