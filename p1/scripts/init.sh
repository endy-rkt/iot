#! /bin/bash

#this script is to run with root privilege
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run with root priv"
    exit 1
fi

install_vagrant(){

    #skip installation if vagrant ok
    if vagrant --version; then
        return 0
    fi

    wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    apt update && apt install -y vagrant

    #check if vagrant is installed successfully
    if vagrant --version > /dev/null; then
        echo "Vagrant installed successfully!"
    else
        echo "Error no vagrant installed!"
        exit 1
    fi
}

#install vm provider libvirt
install_libvirt(){
    #skip installation if libvirt ok
    if virsh list --all > /dev/null; then
        return 0
    fi

    apt update && apt install -y qemu-kvm libvirt-daemon-system libvirt-clients virtinst virt-manager libvirt-dev ruby-dev
    systemctl enable --now libvirtd
    usermod -aG libvirt $USER && usermod -aG libvirt $SUDO_USER

    #check if it is installed successfully
    if virsh list --all > /dev/null; then
        echo "libvirt installed successfully!"
    else
        echo "Error no libvirt installed"
        exit 1
    fi

    vagrant plugin install vagrant-libvirt
    echo "vagrant libvirt plugin installed"
}

init_vagrant_file(){
    export VAGRANT_VAGRANTFILE=$(dirname ${BASH_SOURCE[0]})/..
    
    if [ -f $VAGRANT_VAGRANTFILE/Vagrantfile ]; then
        echo "Vagrantfile already exist!"
        return 0
    fi
    
    cd $VAGRANT_VAGRANTFILE && vagrant init
}

echo "installing vagrant..."
install_vagrant

echo "installing libvirt for vm provisionning..."
install_libvirt
init_vagrant_file
