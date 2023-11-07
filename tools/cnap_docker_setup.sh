#!/bin/bash

set -e

REDIS_HOST=17.17.0.2
PROVIDER_PATHNAME="store-aisle-detection.mp4"
OMP_NUM_THREADS=1
TF_NUM_INTEROP_THREADS='1'
TF_NUM_INTRAOP_THREADS='1'
ONEDNN_ISA_AVX512="AVX512_CORE"
ONEDNN_ISA_AMX="AVX512_CORE_AMX"
DOCKER_NETWORK_NAME="cnap-network"
IMAGE_REGISTRY="cnap"
IMGAE_TAG="latest"

start_containerd_docker() {
    systemctl start containerd
    systemctl start docker
    sleep 2
}

add_redis_conf() {
    tee ./redis.conf <<EOF
# Disable protected mode
protected-mode no
# Disable RDB persistence
save ""
EOF
}

docker_setup_cnap() {
    if [[ -z $(docker network ls | grep ${DOCKER_NETWORK_NAME}) ]]; then
        docker network create --subnet=${REDIS_HOST}/16 ${DOCKER_NETWORK_NAME}
    fi

    if [[ -n $(docker ps | grep cnap-redis) ]]; then
        docker stop cnap-redis
        sleep 2
    fi
    docker run -d --name=cnap-redis \
        --net ${DOCKER_NETWORK_NAME} \
        --ip ${REDIS_HOST} \
        -v ./redis.conf:/etc/redis.conf \
        --rm redis:7.0 \
        redis-server /etc/redis.conf

    if [[ -n $(docker ps | grep cnap-streaming-non) ]]; then
        docker stop cnap-streaming-non
        sleep 2
    fi
    docker run -d --name=cnap-streaming-non \
        --net ${DOCKER_NETWORK_NAME} \
        -e REDIS_HOST=${REDIS_HOST} \
        -e QUEUE_HOST=${REDIS_HOST} \
        -e INFER_DEVICE="cpu" \
        -e PROVIDER_PATHNAME=${PROVIDER_PATHNAME} \
        --rm ${IMAGE_REGISTRY}/cnap-streaming:${IMGAE_TAG}

    if [[ -n $(docker ps | grep cnap-inference-non) ]]; then
        docker stop cnap-inference-non
        sleep 2
    fi
    docker run -d --name=cnap-inference-non \
        --net ${DOCKER_NETWORK_NAME} \
        -e QUEUE_HOST=${REDIS_HOST} \
        -e BROKER_HOST=${REDIS_HOST} \
        -e REDIS_HOST=${REDIS_HOST} \
        -e OMP_NUM_THREADS=${OMP_NUM_THREADS} \
        -e TF_NUM_INTEROP_THREADS=${TF_NUM_INTEROP_THREADS} \
        -e TF_NUM_INTRAOP_THREADS=${TF_NUM_INTRAOP_THREADS} \
        -e INFER_DEVICE="cpu" \
        -e ONEDNN_MAX_CPU_ISA=${ONEDNN_ISA_AVX512} \
        --rm ${IMAGE_REGISTRY}/cnap-inference:${IMGAE_TAG}

    if [[ -n $(docker ps | grep cnap-streaming-amx) ]]; then
        docker stop cnap-streaming-amx
        sleep 2
    fi
    docker run -d --name=cnap-streaming-amx \
        --net ${DOCKER_NETWORK_NAME} \
        -e REDIS_HOST=${REDIS_HOST} \
        -e QUEUE_HOST=${REDIS_HOST} \
        -e INFER_DEVICE="cpu-amx" \
        -e PROVIDER_PATHNAME=${PROVIDER_PATHNAME} \
        --rm ${IMAGE_REGISTRY}/cnap-streaming:${IMGAE_TAG}

    if [[ -n $(docker ps | grep cnap-inference-amx) ]]; then
        docker stop cnap-inference-amx
        sleep 2
    fi
    docker run -d --name=cnap-inference-amx \
        --net ${DOCKER_NETWORK_NAME} \
        -e QUEUE_HOST=${REDIS_HOST} \
        -e BROKER_HOST=${REDIS_HOST} \
        -e REDIS_HOST=${REDIS_HOST} \
        -e OMP_NUM_THREADS=${OMP_NUM_THREADS} \
        -e TF_NUM_INTEROP_THREADS=${TF_NUM_INTEROP_THREADS} \
        -e TF_NUM_INTRAOP_THREADS=${TF_NUM_INTRAOP_THREADS} \
        -e INFER_DEVICE="cpu-amx" \
        -e ONEDNN_MAX_CPU_ISA=${ONEDNN_ISA_AMX} \
        --rm ${IMAGE_REGISTRY}/cnap-inference:${IMGAE_TAG}
}

start_containerd_docker
add_redis_conf
docker_setup_cnap
