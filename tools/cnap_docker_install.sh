#!/bin/sh

set -e

configure_kernel() {
    tee /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF
    modprobe overlay
    modprobe br_netfilter
    sysctl --system
}

install_pre_requisites() {
    apt --fix-broken install -y
    apt-get update
    apt-get install -y apt-transport-https ca-certificates curl gnupg software-properties-common debian-keyring debian-archive-keyring
    mkdir -p -m 755 /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --no-default-keyring --keyring gnupg-ring:/etc/apt/trusted.gpg.d/docker-archive-keyring.gpg --import --batch --yes
    chmod 644 /etc/apt/trusted.gpg.d/docker-archive-keyring.gpg
    add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    apt-get update
}

install_container() {
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
}

containerd_docker_proxy() {
    # export env var
    while read env_var; do
        export "$env_var"
    done < /etc/environment

    # config proxy
    HTTPS_PROXY=$(echo $HTTPS_PROXY)
    if [ -z $HTTPS_PROXY ]; then
        HTTPS_PROXY=$(echo $https_proxy)
    fi

    HTTP_PROXY=$(echo $HTTP_PROXY)
    if [ -z $HTTP_PROXY ]; then
        HTTP_PROXY=$(echo $http_proxy)
    fi

    NO_PROXY=$(echo $NO_PROXY)
    if [ -z $NO_PROXY ]; then
        NO_PROXY=$(echo $no_proxy)
    fi

    mkdir -p /etc/systemd/system/containerd.service.d/
    tee /etc/systemd/system/containerd.service.d/http-proxy.conf <<EOF
[Service]
Environment="HTTP_PROXY=${HTTP_PROXY}"
Environment="HTTPS_PROXY=${HTTPS_PROXY}"
Environment="NO_PROXY=${NO_PROXY}"
EOF

    mkdir -p /etc/systemd/system/docker.service.d/
    tee /etc/systemd/system/docker.service.d/http-proxy.conf <<EOF
[Service]
Environment="HTTP_PROXY=${HTTP_PROXY}"
Environment="HTTPS_PROXY=${HTTPS_PROXY}"
Environment="NO_PROXY=${NO_PROXY}"
EOF
}

configure_container() {
    mkdir -p /etc/containerd
    containerd config default | tee /etc/containerd/config.toml >/dev/null 2>&1
    sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
    systemctl daemon-reload
    systemctl restart containerd
    systemctl enable containerd
    systemctl restart docker
    systemctl enable docker
}

pull_image() {
    docker pull hulongyin/cnap-inference:2023WW44.4
    docker pull hulongyin/cnap-streaming:2023WW44.4
    docker pull redis:7.0
}

configure_kernel
install_pre_requisites
install_container
containerd_docker_proxy
configure_container
pull_image
