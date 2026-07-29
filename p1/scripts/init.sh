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

#install vm provider virtualbox
install_vbox(){
    if vboxmanage --version; then
        return 0
    fi

    wget https://download.virtualbox.org/virtualbox/7.2.14/virtualbox-7.2_7.2.14-174565~Debian~trixie_amd64.deb && dpkg -i virtualbox-7.2_7.2.14-174565~Debian~trixie_amd64.deb && rm virtualbox-7.2_7.2.14-174565~Debian~trixie_amd64.deb

    if vboxmanage --version > /dev/null; then
        echo "virtualbox installed successfully"
    else
        #note that there are many step to do to make it work
        echo "Error when installing vbox"
        exit 1
    fi
}

init_vagrant_file(){
    export VAGRANT_VAGRANTFILE=$(dirname ${BASH_SOURCE[0]})/..

    if [ -f $VAGRANT_VAGRANTFILE/Vagrantfile ]; then
        echo "Vagrantfile already exist!"
        return 0
    fi
    
    cd $VAGRANT_VAGRANTFILE && vagrant init
}

echo "Unload kvm"
rmmod kvm_intel kvm

echo "installing vagrant..."
install_vagrant

echo "installing vbox for vm provisionning..."
install_vbox

init_vagrant_file
