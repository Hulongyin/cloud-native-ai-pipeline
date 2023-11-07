#!/bin/bash

set -e

DOCKER_NETWORK_NAME="cnap-network"

docker_stop_cnap() {
    if [[ -n $(docker ps | grep cnap-streaming-non) ]]; then
        docker stop cnap-streaming-non
    fi

    if [[ -n $(docker ps | grep cnap-inference-non) ]]; then
        docker stop cnap-inference-non
    fi

    if [[ -n $(docker ps | grep cnap-streaming-amx) ]]; then
        docker stop cnap-streaming-amx
    fi

    if [[ -n $(docker ps | grep cnap-inference-amx) ]]; then
        docker stop cnap-inference-amx
    fi

    if [[ -n $(docker ps | grep cnap-redis) ]]; then
        docker stop cnap-redis
    fi

    if [[ -n $(docker network ls | grep ${DOCKER_NETWORK_NAME}) ]]; then
        docker network rm ${DOCKER_NETWORK_NAME}
    fi
}

docker_stop_cnap
