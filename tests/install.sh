#!/bin/bash

echo "# Start the install of the buildenv"
echo "# Install the required tools"
packages=$(sudo apt update && sudo apt install -y sshpass 2>&1)
if [ "$?" != 0 ]; then
    echo "! Error, install packages failed"
    echo "$packages"
    exit 1
else
    echo "# packages installed"
fi

mkdir -p $HOME/.ssh
key=$(ssh-keygen -b 521 -t ecdsa -q -f $HOME/.ssh/id_ecdsa -N "")
if [ "$?" != 0 ]; then
    echo "! Error, SSH key cannot be created"
    echo "$key"
    exit 1
else
    echo "# Key generated"
fi

build=$(docker build -t openssh-server .)
if [ "$?" != 0 ]; then
    echo "! Error, Build not succesful"
    echo "$build"
    exit 1
else
    echo "# Container is build"
fi
run=$(docker run -d -p 2222:22 --name openssh-server -e NAME=test -e USERNAME=test -e PASSWORD=password openssh-server)
docker ps | grep -q openssh-server
sleep 2
if [ "$?" != 0 ]; then
    echo "! Error, container is not running."
    echo "$run"
    exit 1
else
    echo "# Container is running"
fi

docker rm -f openssh-server
echo "# Container has been deleted, test succesful"
exit r