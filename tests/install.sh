#!/bin/bash

echo "# Start the install of the buildenv"
echo "# Install the required tools"
sudo apt update > /dev/null 2>&1
sudo apt install -y sshpass

echo "# Pull the required images"
if ! docker pull hadolint/hadolint; then
    echo "! HaDoLint could not be pulled"
    exit 1
else
    echo "# Pulled HaDoLint"
fi

mkdir -p "$HOME"/.ssh
if ! ssh-keygen -b 521 -t ecdsa -q -f "$HOME"/.ssh/id_ecdsa -N ""; then
    echo "! Error, SSH key cannot be created"
    exit 1
else
    echo "# Key generated"
fi


if ! docker build -t openssh-server .; then
    echo "! Error, Build not succesful"
    exit 1
else
    echo "# Container is build"
fi
run=$(docker run -d -p 2222:22 --name openssh-server -e NAME=test -e USERNAME=test -e PASSWORD=password openssh-server 2>&1)

if ! docker ps | grep -q openssh-server; then
    echo "! Error, container is not running."
    echo "$run"
    exit 1
else
    echo "# Container is running"
fi

docker rm -f openssh-server
echo "# Container has been deleted, test succesful"
exit 0