#!/bin/bash

set -e

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

while :
do
    containerd_docker_proxy
    configure_container
    ./docker_image_manager.sh -a build -r "cnap" -g "latest" -c cnap-streaming -f

    docker_process=$(docker ps -aq)
    if [[ -n $docker_process ]]; then
        docker stop ${docker_process}
    fi
    docker_process_stopped=$(docker ps -aq)
    if [[ -n $docker_process_stopped ]]; then
        docker rm ${docker_process_stopped}
    fi
    docker_images=$(docker images -q)
    if [[ -n $docker_images ]]; then
        docker rmi ${docker_images}
    fi

    rm /etc/containerd/config.toml
    rm -rf /etc/systemd/system/containerd.service.d/
    rm -rf /etc/systemd/system/docker.service.d/

    systemctl daemon-reload
    systemctl restart containerd
    systemctl enable containerd
    systemctl restart docker
    systemctl enable docker
    sleep 20
done
