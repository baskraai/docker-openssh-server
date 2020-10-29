#!/bin/bash

# shellcheck disable=SC1091
source ./tests/testfunctions.sh

echo_info "Cleanup from potential failure of last run"
docker rm -f openssh-server > /dev/null 2>&1

echo_info "Starting the container"
docker run -d --rm -p 2222:22 --name openssh-server -e NAME="test" -e USERNAME="test" -e PASSWORD="password" -e SSH_AUTHKEY="$(cat "$HOME"/.ssh/id_ecdsa.pub)" -e PASSWORDLESS_SUDO=yes -e GIT_NAME="testuser" -e GIT_EMAIL="test@test.nl" openssh-server

if ! docker ps | grep -q openssh-server; then
    echo_failed "container is not running"
    exit 1
else
    echo_info "Container is running"
fi

git_user=$(ssh -q test@0.0.0.0 -o StrictHostKeyChecking=no -o "UserKnownHostsFile /dev/null" -p 2222 git config --global user.name)
git_email=$(ssh -q test@0.0.0.0 -o StrictHostKeyChecking=no -o "UserKnownHostsFile /dev/null" -p 2222 git config --global user.email)


if [ "$git_user" != "testuser" ]; then
    echo_failed "Git Name in container not same as passed by variables."
    exit 1
elif [ "$git_email" != "test@test.nl" ]; then
    echo_failed "Git Email in container not same as passed by variables."
    exit 1
else
    echo_ok "Git Name and Email in the container the same as passed by variables"
fi

docker rm -f openssh-server > /dev/null 2>&1
echo_ok "Container has been deleted, test succesful"
exit 0