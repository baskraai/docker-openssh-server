#!/bin/bash

echo "# Cleanup from potential failure of last run"
docker rm -f openssh-server > /dev/null 2>&1

echo "# Starting the container"
docker run -d --rm -p 2222:22 --name openssh-server -e NAME="test" -e USERNAME="test" -e PASSWORD="password" openssh-server > /dev/null

if ! docker ps | grep -q openssh-server; then
    echo "! Error, container is not running."
    exit 1
else
    echo "# Container is running"
fi

export SSHPASS="password"
if ! sshpass -e ssh test@0.0.0.0 -o StrictHostKeyChecking=no -p 2222 whoami; then
    echo "! Error, ssh command is not successful."
    exit 1
else
    echo "# User test is able to login with a password"
fi

docker rm -f openssh-server > /dev/null 2>&1
echo "# Container has been deleted, test succesful"
exit 0