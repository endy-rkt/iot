#!/bin/sh

# load overlay module into kernel
modprobe overlay

# install latest stable k3s
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --node-ip 192.168.56.110 --flannel-iface eth1" sh -

#wait for k3s to be ready
until k3s kubectl get nodes 2>/dev/null | grep -q "Ready"; do
    echo "waiting k3s to be ready..."
    sleep 2
done

# check the current node
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
k3s kubectl get nodes

#get the token to join the cluster
mkdir -p /vagrant && touch /vagrant/token
cat /var/lib/rancher/k3s/server/node-token > /vagrant/token
