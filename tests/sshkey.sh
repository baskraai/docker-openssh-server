#!/bin/bash
echo "# Starting the container"
SSH_KEY=$(cat "$HOME"/.ssh/id_ecdsa.pub)
export SSH_KEY
docker run -d --rm -p 2222:22 --name openssh-server -e NAME=test -e USERNAME=test -e PASSWORD=password -e SSH_AUTHKEY="$(cat "$HOME"/.ssh/id_ecdsa.pub)" openssh-server

if ! docker ps | grep -q openssh-server; then
    echo "! Error, container is not running."
    exit 1
else
    echo "# Container is running"
fi

if ! ssh test@0.0.0.0 -o StrictHostKeyChecking=no -p 2222 whoami; then
    echo "! Error, sshpass command is not successful."
    exit 1
else
    echo "# User test is able to login with a ssh_key"
fi

docker rm -f openssh-server
echo "# Container has been deleted, test succesful"
exit 0