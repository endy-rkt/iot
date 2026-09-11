#!/bin/bash

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run with root priv!"
    exit 1
fi

install_vagrant(){
    echo "Installing vagrant..."
    wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    apt update && apt install -y vagrant
}

setup_vagrant(){

    if vagrant --version 2>/dev/null; then
        echo "Vagrant is already installed"
        return 0
    fi
    
    install_vagrant

    #check if vagrant is installed successfully
    if vagrant --version &> /dev/null; then
        echo "Vagrant installed successfully!"
    else
        echo "Error when installing vagrant!"
        exit 1
    fi

    #install vagrant reload plugin
    vagrant plugin install vagrant-reload

    if [ -n "$SUDO_USER" ]; then
        echo "Installing vagrant-reload plugin for non root user..."
        sudo -u "$SUDO_USER" vagrant plugin install vagrant-reload
    fi
}

install_vbox(){
    local VBOX="virtualbox-7.2_7.2.14-174565~Debian~trixie_amd64.deb"

    if vboxmanage --version 2>/dev/nulll; then
        echo "Vbox is already installed!"
        return 0
    fi

    #install package dependancy
    apt install -y linux-headers-$(uname -r) libqt6core6t64 libqt6dbus6 libqt6gui6 libqt6help6 libqt6printsupport6 libqt6statemachine6 libqt6widgets6 libqt6xml6
    wget https://download.virtualbox.org/virtualbox/7.2.14/$VBOX && dpkg -i $VBOX && rm $VBOX

    if vboxmanage --version > /dev/null; then
        echo "virtualbox installed successfully"
    else
        echo "Error when installing vbox!"
        exit 1
    fi
}

init_vagrant_file(){
    local VAGRANT_VAGRANTFILE=$(dirname ${BASH_SOURCE[0]})/..
    
    if [ -f $VAGRANT_VAGRANTFILE/Vagrantfile ]; then
        echo "Vagrantfile already exist!"
        return 0
    fi
    
    echo "Initiating vagrantfile..."
    cd $VAGRANT_VAGRANTFILE && vagrant init
}

blacklist_kvm(){
    if ! grep "blacklist kvm" /etc/modprobe.d/blacklist.conf &> /dev/null; then
        echo "Unload kvm temporally" && rmmod kvm_intel kvm
        echo "blacklist kvm_intel" | tee -a /etc/modprobe.d/blacklist.conf
        echo "blacklist kvm" | tee -a /etc/modprobe.d/blacklist.conf
    fi
}

main(){
    blacklist_kvm
    echo "Removing vagrant residents..."
    rm -rf .vagrant
    setup_vagrant
    install_vbox
    init_vagrant_file
}

main