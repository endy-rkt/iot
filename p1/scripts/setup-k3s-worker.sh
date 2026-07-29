#!/bin/sh

K3S_TOKEN_FILE="./conf/token"
if [ ! -f $K3S_TOKEN_FILE ];then
    echo "token to join cluster not found"
fi
K3S_TOKEN=$(cat $K3S_TOKEN_FILE)

# load overlay module into kernel
modprobe overlay

# install latest stable k3s
curl -sfL https://get.k3s.io -o k3s-install.sh
K3S_URL=https://192.168.56.110:6443 K3S_TOKEN=TOKEN sh k3s-install.sh

#wait for k3s to be ready
until k3s kubectl get nodes 2>/dev/null | grep -q "Ready"; do
    echo "waiting k3s to be ready..."
    sleep 2
done

# check the current node
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
k3s kubectl get nodes
