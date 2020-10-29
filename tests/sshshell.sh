#!/bin/bash

source ./tests/testfunctions.sh

echo_ok "Cleanup from potential failure of last run"
docker rm -f openssh-server > /dev/null 2>&1

for TESTSHELL in zsh sh bash
do
    echo ""
    echo_ok "Starting the container with $TESTSHELL"
    SSH_KEY=$(cat "$HOME"/.ssh/id_ecdsa.pub)
    export SSH_KEY
    docker run -d --rm -p 2222:22 --name openssh-server -e NAME=test -e USERNAME=test -e PASSWORD=password -e SSH_AUTHKEY="$(cat "$HOME"/.ssh/id_ecdsa.pub)" -e USERSHELL="$TESTSHELL" openssh-server > /dev/null

    if ! docker ps | grep -q openssh-server > /tmp/output 2>&1; then
        echo_failed "Error, container is not running."
        exit 1
    else
        echo_ok "Container is running"
    fi

    check=$(ssh -q test@0.0.0.0 -o StrictHostKeyChecking=no -o "UserKnownHostsFile /dev/null" -p 2222 echo \"\$SHELL\")

    if [ "$check" != "/bin/$TESTSHELL" ]; then
        echo_failed "Error, $TESTSHELL Shell check is not successful."
        exit 1
    else
        echo_ok "User test is able to login with a $TESTSHELL shell"
    fi

    docker rm -f openssh-server > /dev/null 2>&1
    echo_ok "Container has been deleted"
done

echo ""
echo_ok "Tests for shells completed succesfully"
exit 0