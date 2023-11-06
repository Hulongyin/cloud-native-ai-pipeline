#!/bin/sh

set -e

disable_swap() {
    swapoff -a
    sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
}

configure_kernel() {
    tee /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF
    modprobe overlay
    modprobe br_netfilter
    tee /etc/sysctl.d/kubernetes.conf <<EOF
net.bridge.bridge-nf-call-ip6tables=1
net.bridge.bridge-nf-call-iptables=1
net.ipv4.ip_forward=1
EOF
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
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --no-default-keyring --keyring gnupg-ring:/etc/apt/trusted.gpg.d/kubernetes-archive-keyring.gpg --import --batch --yes
    chmod 644 /etc/apt/trusted.gpg.d/kubernetes-archive-keyring.gpg
    apt-add-repository -y "deb http://apt.kubernetes.io/ kubernetes-xenial main"
    apt-get update
}

install_container() {
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
}

containerd_proxy() {
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
}

configure_container() {
    mkdir -p /etc/containerd
    containerd config default | tee /etc/containerd/config.toml >/dev/null 2>&1
    sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
    systemctl daemon-reload
    systemctl restart containerd
    systemctl enable containerd
}

install_kubernetes() {
    # read -rp "Enter Kubernetes version (default: 1.28.2-00): " k8s_version
    k8s_version=${k8s_version:-"1.28.2-00"}

    apt-get install -y kubelet=${k8s_version} kubeadm=${k8s_version} kubectl=${k8s_version} --allow-change-held-packages
    apt-mark hold kubelet kubeadm kubectl
}

pull_image() {
    crictl --runtime-endpoint=unix:///run/containerd/containerd.sock --image-endpoint=unix:///run/containerd/containerd.sock pull hulongyin/cnap-inference:2023WW44.4
    crictl --runtime-endpoint=unix:///run/containerd/containerd.sock --image-endpoint=unix:///run/containerd/containerd.sock pull hulongyin/cnap-ppdb:2023WW44.4
    crictl --runtime-endpoint=unix:///run/containerd/containerd.sock --image-endpoint=unix:///run/containerd/containerd.sock pull hulongyin/cnap-spa:2023WW44.4
    crictl --runtime-endpoint=unix:///run/containerd/containerd.sock --image-endpoint=unix:///run/containerd/containerd.sock pull hulongyin/cnap-streaming:2023WW44.4
    crictl --runtime-endpoint=unix:///run/containerd/containerd.sock --image-endpoint=unix:///run/containerd/containerd.sock pull hulongyin/cnap-wss:2023WW44.4
}

disable_swap
configure_kernel
install_pre_requisites
install_container
containerd_proxy
configure_container
install_kubernetes
pull_image
