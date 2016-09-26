#!/bin/bash
set -xe
DISTRO=${1:-"xenial"} # or centos7
DOCKER=${2:-"distro"} # or upstream
MULTINODE=${3:-"0"} # multinode, 0 = off, 1 = on

if [ $MULTINODE -eq 1 ]; then
    ALLNODES="1 2 3"
    NODES="2 3"
    EXP_NODES_PLUS_HEADER=4
    EXP_RUNNING_PODS=12
else
    ALLNODES="1"
    NODES=""
    EXP_NODES_PLUS_HEADER=2
    EXP_RUNNING_PODS=8
fi

# Install the master
if [ "$DISTRO" = "xenial" ]; then
    if [ "$DOCKER" = "distro" ]; then
        docker_cmd="apt-get install -y docker.io"
    elif [ "$DOCKER" = "upstream" ]; then
        docker_cmd="curl -sSL https://get.docker.com/ | sh"
    fi
    common_setup="$docker_cmd && \
            apt-get install -y socat && \
            curl -s -L https://storage.googleapis.com/kubeadm/kubernetes-xenial-preview-bundle.txz | tar xJv && \
            dpkg -i kubernetes-xenial-preview-bundle/*.deb"
elif [ "$DISTRO" = "centos7" ]; then
    if [ "$DOCKER" = "distro" ]; then
        docker_cmd="yum install -y docker"
    elif [ "$DOCKER" = "upstream" ]; then
        docker_cmd="curl -sSL https://get.docker.com/ | sh"
    fi
    common_setup="$docker_cmd
cat <<EOF > /etc/yum.repos.d/k8s.repo
[kubelet]
name=kubelet
baseurl=http://files.rm-rf.ca/rpms/kubelet/
enabled=1
gpgcheck=0
EOF
yum install -y kubelet kubeadm kubectl kubernetes-cni
systemctl enable docker && systemctl start docker
systemctl enable kubelet && systemctl start kubelet"
fi

# common setup
parallel -i tugboat ssh kubeadm-$DISTRO-$DOCKER-$MULTINODE-{} -c "$common_setup" -- $ALLNODES

# install the master
tugboat ssh kubeadm-$DISTRO-$DOCKER-$MULTINODE-1 -c "kubeadm init |tee init-output.txt"
join_cmd=`tugboat ssh kubeadm-$DISTRO-$DOCKER-$MULTINODE-1 -c "tail -n 1 init-output.txt" |tail -n 1`

if [ $MULTINODE -eq 0 ]; then
    tugboat ssh kubeadm-$DISTRO-$DOCKER-$MULTINODE-1 -c "kubectl taint master-node -dedicated"
fi

# install pod network
tugboat ssh kubeadm-$DISTRO-$DOCKER-$MULTINODE-1 -c "kubectl apply -f https://git.io/weave-kube"

echo "GOT JOIN COMMAND $join_cmd"
# run the command the master gave us on the nodes
for X in $NODES; do
    tugboat ssh kubeadm-$DISTRO-$DOCKER-$MULTINODE-$X -c "$join_cmd"
done

nodes="0"
while [ $nodes -lt $EXP_NODES_PLUS_HEADER ]; do
    nodes=`tugboat ssh kubeadm-$DISTRO-$DOCKER-$MULTINODE-1 -c "kubectl get nodes |wc -l" |tail -n 1`
    echo "Got $nodes nodes"
done

running_pods="0"
while [ $running_pods -lt $EXP_RUNNING_PODS ]; do
    running_pods=`tugboat ssh kubeadm-$DISTRO-$DOCKER-$MULTINODE-1 -c "kubectl get po --all-namespaces |grep Running |wc -l" |tail -n 1`
    echo "Got $running_pods pods"
done

echo "Success!"
