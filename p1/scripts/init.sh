#!/bin/bash

#this script is to run with root privilege
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run with root priv"
    exit 1
fi

install_vagrant(){

    #skip installation if vagrant ok
    if vagrant --version 2>/dev/null; then
        echo "vagrant is already installed"
        return 0
    fi
    
    #script from vagrant
    echo "installing vagrant..."
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

    #install vagrant reload plugin
    vagrant plugin install vagrant-reload

    if [ -n "$SUDO_USER" ]; then
        echo "Install vagrant reload for simple user..."
        sudo -u "$SUDO_USER" vagrant plugin install vagrant-reload
    fi
}

#install vm provider virtualbox
install_vbox(){
    local vbox="virtualbox-7.2_7.2.14-174565~Debian~trixie_amd64.deb"

    if vboxmanage --version 2>/dev/nulll; then
        echo "vbox is already installed"
        return 0
    fi

    #install package dependancy
    apt install -y linux-headers-$(uname -r) libqt6core6t64 libqt6dbus6 libqt6gui6 libqt6help6 libqt6printsupport6 libqt6statemachine6 libqt6widgets6 libqt6xml6
    wget https://download.virtualbox.org/virtualbox/7.2.14/$vbox && dpkg -i $vbox && rm $vbox

    if vboxmanage --version > /dev/null; then
        echo "virtualbox installed successfully"
    else
        #note that there are many step to do to make it work
        echo "Error when installing vbox"
        exit 1
    fi
}

init_vagrant_file(){
    local VAGRANT_VAGRANTFILE=$(dirname ${BASH_SOURCE[0]})/..
    
    if [ -f $VAGRANT_VAGRANTFILE/Vagrantfile ]; then
        echo "Vagrantfile already exist!"
        return 0
    fi
    
    cd $VAGRANT_VAGRANTFILE && vagrant init
}

black_list_kvm(){
    if ! grep "blacklist kvm" /etc/modprobe.d/blacklist.conf; then
        echo "Unload kvm temporally" && rmmod kvm_intel kvm
        echo "blacklist kvm_intel" | tee -a /etc/modprobe.d/blacklist.conf
        echo "blacklist kvm" | tee -a /etc/modprobe.d/blacklist.conf
    fi
}

black_list_kvm

echo "Remove vagrant residu"
rm -rf .vagrant

echo "installing vagrant..."
install_vagrant

echo "installing vbox for vm provisionning..."
install_vbox

init_vagrant_file
