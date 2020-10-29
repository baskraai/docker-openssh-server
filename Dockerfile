FROM ubuntu:bionic
LABEL Maintainer Bas Kraai <bas@kraai.email>


RUN apt-get update \
    && apt-get install --no-install-recommends -y openssl sudo curl jq vim wget nano git openssh-server zsh powerline fonts-powerline \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /var/run/sshd \
    && sed -i 's/#HostKey \/etc\/ssh\/ssh_host_ecdsa_key/HostKey \/etc\/ssh\/ssh_host_ecdsa_key/' /etc/ssh/sshd_config

EXPOSE 22

COPY ./docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]