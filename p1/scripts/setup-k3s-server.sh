#!/bin/sh

rootless_kubectl(){
    local VAGRANT_HOME="/home/vagrant"
    local KUBE_DIR="$VAGRANT_HOME/.kube"
    local KUBE_CONFIG="$KUBE_DIR/config"

    mkdir -p "$KUBE_DIR"
    chown vagrant:vagrant "$KUBE_DIR"

    cp /etc/rancher/k3s/k3s.yaml "$KUBE_CONFIG"

    chown vagrant:vagrant "$KUBE_CONFIG"
    chmod 600 "$KUBE_CONFIG"

    export KUBECONFIG=$KUBE_CONFIG

    #make permanent for bash
    echo "export KUBECONFIG=$KUBE_CONFIG" >> $VAGRANT_HOME/.bashrc
    source $VAGRANT_HOME/.bashrc

    #make permaent for sh
    echo "KUBECONFIG=$KUBE_CONFIG" >> $VAGRANT_HOME/.profile
    echo "export KUBECONFIG" >> $VAGRANT_HOME/.profile
    . $VAGRANT_HOME/.profile
}

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

# make kubectl rootless for vagrant user
rootless_kubectl

#get the token to join the cluster
mkdir -p /vagrant && touch /vagrant/token
cat /var/lib/rancher/k3s/server/node-token > /vagrant/token
