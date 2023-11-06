#!/bin/sh

set -e

initialize_cluster() {
    swapoff -a
    systemctl restart containerd

    # read -rp "Enter Pod Network CIDR (default: 10.244.0.0/16): " pod_network_cidr
    k8s_version="1.28.2"
    pod_network_cidr=${pod_network_cidr:-"10.244.0.0/16"}
    kubeadm init --pod-network-cidr=${pod_network_cidr} --kubernetes-version=${k8s_version}
    
    mkdir -p $HOME/.kube
    cp /etc/kubernetes/admin.conf $HOME/.kube/config
    chown $(id -u):$(id -g) $HOME/.kube/config
    kubectl taint nodes --all node-role.kubernetes.io/control-plane-

    enable_kubectl_autocompletion
    
    echo "Cluster initialized with Pod Network CIDR $pod_network_cidr"
}

enable_kubectl_autocompletion() {
    apt-get install -y bash-completion
    echo 'source <(kubectl completion bash)' >> ~/.bashrc
}

install_cni() {
    # read -rp "Do you want to setup a Container Network Interface (CNI)? Enter 'yes' to setup or 'no' to skip (default: yes): " cni_choice
    cni_choice=${cni_choice:-"yes"}

    if [ $cni_choice = 'no' ]; then
        echo "Skipping CNI setup."
        return
    fi
    
    echo "Choose a CNI plugin:"
    echo "1: Calico"
    echo "2: Flannel"
    # read -rp "Enter choice (default: 1): " cni_plugin_choice
    cni_plugin_choice=${cni_plugin_choice:-'2'}
    
    if [ $cni_plugin_choice = '1' ]; then
        calico_url="https://projectcalico.docs.tigera.io/manifests/calico.yaml"
        kubectl apply -f $calico_url
        echo "Calico CNI plugin has been installed."
    elif [ $cni_plugin_choice = '2' ]; then
        flannel_url="https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml"
        kubectl apply -f $flannel_url
        echo "Flannel CNI plugin has been installed."
    else
        echo "Invalid choice. Exiting."
        exit 1
    fi
}

install_helm() {
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
    chmod 700 get_helm.sh
    ./get_helm.sh
}

setup_kube_prometheus() {
    git clone https://github.com/prometheus-operator/kube-prometheus.git
    cd kube-prometheus
    kubectl apply --server-side -f manifests/setup
    kubectl wait --for condition=Established --all CustomResourceDefinition --namespace=monitoring
    kubectl apply -f manifests/
    cd ..
}

setup_cnap() {
    git clone -b cnap-setup https://github.com/Hulongyin/cloud-native-ai-pipeline.git
    cd cloud-native-ai-pipeline
    kubectl create ns cnap
    ./tools/helm_manager.sh -i -r hulongyin -g 2023WW44.4 -n cnap
}

initialize_cluster
install_cni
install_helm
setup_kube_prometheus
setup_cnap
