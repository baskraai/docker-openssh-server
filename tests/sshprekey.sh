#!/bin/bash

# shellcheck disable=SC1091
source ./tests/testfunctions.sh

echo_info "Cleanup from potential failure of last run"
docker rm -f openssh-server > /dev/null 2>&1

echo_info "Creating the keys for the openssh-server"
if ! ssh-keygen -b 521 -t ecdsa -q -f "$HOME"/id_ecdsa -N ""; then
    echo_failed "Error, SSH key cannot be created"
    exit 1
else
    echo_info "Key generated"
fi

echo_info "Starting the container"
docker run -d --rm -p 2222:22 --name openssh-server -e NAME="test" -e USERNAME="test" -e PASSWORD="password" -e SSH_PRIVKEY="$(cat "$HOME"/id_ecdsa)" -e SSH_PUBKEY="$(cat "$HOME"/id_ecdsa.pub)" -e SSH_AUTHKEY="$(cat "$HOME"/.ssh/id_ecdsa.pub)" -e PASSWORDLESS_SUDO=yes openssh-server

if ! docker ps | grep -q openssh-server; then
    echo_failed "container is not running"
    exit 1
else
    echo_info "Container is running"
fi

pubkey_user=$(ssh -q test@0.0.0.0 -o StrictHostKeyChecking=no -o "UserKnownHostsFile /dev/null" -p 2222 sudo ssh-keygen -l -f \"\$HOME\"/.ssh/id_ecdsa)
pubkey_container=$(ssh -q test@0.0.0.0 -o StrictHostKeyChecking=no -o "UserKnownHostsFile /dev/null" -p 2222 sudo ssh-keygen -l -f /etc/ssh/ssh_host_ecdsa_key)
pubkey_ssh=$(ssh-keygen -l -f "$HOME"/id_ecdsa)


if [ "$pubkey_user" != "$pubkey_ssh" ]; then
    echo_failed "SSH key user in container not same as passed by variables."
    exit 1
elif [ "$pubkey_container" != "$pubkey_ssh" ]; then
    echo_failed "SSH key container in container not same as passed by variables."
    exit 1
else
    echo_ok "SSH key in the container the same as passed by variables"
fi

docker rm -f openssh-server > /dev/null 2>&1
echo_ok "Container has been deleted, test succesful"
exit 0