# SaltStack Master Container

This is a container with a basic OpenSSH server.
The purpose of this container is a out-of-the-box bastion-like host.

## Ports

This containers exposes the following ports:

| Port | usage |
| :---: | --- |
| 22 | OpenSSH server |

## Storage

You can save the data from the Salt Master and Salt Minion outside of the container:

- `/home/<username>` = de thuismap van de gebruiker

## Usage

You can use this image with docker run and docker-compose.
Below are examples for both.

### Docker run

The most basic docker run config is:

```bash

docker run --name "openssh-server" -e NAME="Full name" -e USERNAME="username" -e PASSWORD="password" baskraai/openssh-server

```

### Parameters

You can use the following parameters with this container:

| Parameter | meaning |
| :---: | --- |
| --hostname | Used to set the minion and master name |

### Environment variables

You can use the following environment variables with this container:

| Variable | Required | meaning | values |
| :---: | --- | --- | --- |
| NAME | Required | Name of the user | string
| USERNAME | Required | Username of the user | string
| PASSWORD | Required | Password of the user | string
| USERSHELL | Optional | Shell used for the user | sh, bash or zsh
| PASSWORDLESS_SUDO | Optional | Allow the user to use sudo without a password | yes or no
| SSH_PRIVKEY | Optional | The SSH private key of the user | string
| SSH_PUBKEY | Optional | The SSH public key of the user | string
| SSH_AUTHKEY | Optional | A list of authorized ssh keys seperated with ';' | string
| GIT_NAME | Optional | The name used for git commits of the user | string
| GIT_EMAIL | Optional | The email used for git commits of the user | string

## Extend image

```Dockerfile
FROM baskraai/openssh-server:stable
RUN apt-get update \
    && apt-get install -y <packages> \
    && rm -rf /var/lib/apt/lists/
```

With this Dockerfile the rest of the container keeps working as expected.

### Todo
