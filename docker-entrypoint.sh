#!/bin/bash -x
set -e

# Check for the required variables to make the user.
if [ -z "${NAME}" ]; then
	echo "! Error, no NAME variable specified !"
	exit 1
elif [ -z "${USERNAME}" ]; then
	echo "! Error, no USERNAME variable specified !"
	exit 1
elif [ -z "${PASSWORD}" ]; then
	echo "! Error, no PASSWORD variable specified !"
	exit 1
fi

# Check for the optional variables, print info about them.
if [ -z "${USERSHELL}" ]; then
	echo "# No shell specified, defaul BASH shell used."
	useradd -s "/bin/bash" -G sudo "${USERNAME}"
else
	SHELLUSED="/bin/"${USERSHELL}
	useradd -s "${SHELLUSED}" -G sudo "${USERNAME}"
fi

# Setting the password.
echo "${USERNAME}:$PASSWORD" | chpasswd
PASSWORD=""

# Passwordless sudo
if [ "${PASSWORDLESS_SUDO}" == "yes" ]; then
	echo "%sudo ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers
fi

# Check for ssh keys from the user, if not regenerate new ssh keys.
if [ -z "${SSH_PRIVKEY}" ] || [ -z "${SSH_PUBKEY}" ] ; then
	echo "# No SSH_PRIVKEY and/or SSH_PUBKEY specified, generating the SSH keys."
	ssh-keygen -b 521 -t ecdsa -q -f /etc/ssh/ssh_host_ecdsa_key -N "" -y
	mkdir -p /home/"${USERNAME}"/.ssh
	cp /etc/ssh/ssh_host_ecdsa_key /home/"${USERNAME}"/.ssh/id_ecdsa
	cp /etc/ssh/ssh_host_ecdsa_key.pub /home/"${USERNAME}"/.ssh/id_ecdsa.pub
	echo "# The public ssh-key"
	cat /home/"${USERNAME}"/.ssh/id_ecdsa.pub
else
	echo "# SSH_PRIVKEY and SSH_PUBKEY specified, using these keys."
	echo "$SSH_PUBKEY" > /etc/ssh/ssh_host_ecdsa_key.pub
	echo "$SSH_PRIVKEY" > /etc/ssh/ssh_host_ecdsa_key
	mkdir -p /home/"${USERNAME}"/.ssh
	cp /etc/ssh/ssh_host_ecdsa_key /home/"${USERNAME}"/.ssh/id_ecdsa
	cp /etc/ssh/ssh_host_ecdsa_key.pub /home/"${USERNAME}"/.ssh/id_ecdsa.pub
fi

# Set the authorized_keys for the user
if [ -n "$SSH_AUTHKEY" ]; then
	echo "# Set authorized keys for the user."
	mkdir -p /root/.ssh
	echo "$SSH_AUTHKEY" | tr ";" "\n" > /home/"$USERNAME"/.ssh/authorized_keys
fi

# Create a .gitconfig file from environment variables.
if [ ! -f "$HOME/.gitconfig" ] && [ "$GIT_NAME" != "" ] && [ "$GIT_NAME" != "" ]; then
	echo "# No gitconfig found, creating it"
	echo "[user]" > ~/.gitconfig
	echo "	name = $GIT_NAME" >> ~/.gitconfig
	echo "	email = $GIT_EMAIL" >> ~/.gitconfig
elif [ ! -f "$HOME/.gitconfig" ]; then
	echo "# No .gitconfig found, also no GIT_NAME and/or GIT_EMAIL variable so not creating .gitconfig"
else
	echo "# .gitconfig found, not editing it"
fi

echo "# Starting the OpenSSH server daemon"
/usr/sbin/sshd -De
