#!/bin/sh

set -e

REDIS_HOST=172.18.0.2
OMP_NUM_THREADS=1
TF_NUM_INTEROP_THREADS='1'
TF_NUM_INTRAOP_THREADS='1'
ONEDNN_ISA_AVX512="AVX512_CORE"
ONEDNN_ISA_AMX="AVX512_CORE_AMX"

docker_setup_cnap() {
    systemctl restart containerd
    systemctl restart docker

    docker network create --subnet=172.18.0.0/16 cnap-network

    docker run -d --name=redis --net cnap-network --ip ${REDIS_HOST} --rm redis:7.0

    docker run -d --name=streaming-non --net cnap-network --rm -e REDIS_HOST=${REDIS_HOST} \
        -e QUEUE_HOST=${REDIS_HOST} -e INFER_DEVICE="cpu" hulongyin/cnap-streaming:2023WW44.4

    docker run -d --name=inference-non --net cnap-network --rm -e QUEUE_HOST=${REDIS_HOST} \
        -e BROKER_HOST=${REDIS_HOST} -e REDIS_HOST=${REDIS_HOST} \
        -e OMP_NUM_THREADS=${OMP_NUM_THREADS} -e TF_NUM_INTEROP_THREADS=${TF_NUM_INTEROP_THREADS} \
        -e TF_NUM_INTRAOP_THREADS=${TF_NUM_INTRAOP_THREADS} -e INFER_DEVICE="cpu" \
        -e ONEDNN_MAX_CPU_ISA=${ONEDNN_ISA_AVX512} hulongyin/cnap-inference:2023WW44.4

    docker run -d --name=streaming-amx --net cnap-network --rm -e REDIS_HOST=${REDIS_HOST} \
        -e QUEUE_HOST=${REDIS_HOST} -e INFER_DEVICE="cpu-amx" hulongyin/cnap-streaming:2023WW44.4

    docker run -d --name=inference-amx --net cnap-network --rm -e QUEUE_HOST=${REDIS_HOST} \
        -e BROKER_HOST=${REDIS_HOST} -e REDIS_HOST=${REDIS_HOST} \
        -e OMP_NUM_THREADS=${OMP_NUM_THREADS} -e TF_NUM_INTEROP_THREADS=${TF_NUM_INTEROP_THREADS} \
        -e TF_NUM_INTRAOP_THREADS=${TF_NUM_INTRAOP_THREADS} -e INFER_DEVICE="cpu-amx" \
        -e ONEDNN_MAX_CPU_ISA=${ONEDNN_ISA_AMX} hulongyin/cnap-inference:2023WW44.4
}

docker_setup_cnap
