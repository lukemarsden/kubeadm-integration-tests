#!/bin/bash
set -xe
DISTRO=${1:-xenial} # or centos7
DOCKER=${2:-distro} # or upstream
# Install the master
if [ "$DISTRO" = "xenial" ]; then
    if [ "$DOCKER" = "distro" ]; then
        docker_cmd="curl -sSL https://get.docker.com/ | sh"
    elif [ "$DOCKER" = "upstream" ]; then
        docker_cmd="apt-get install -y docker.io"
    fi
    common_setup="$docker_cmd && \
            apt-get install -y socat && \
            curl -s -L 'https://www.dropbox.com/s/tso6dc7b94ch2sk/debs-5ab576.txz?dl=1' | tar xJv && \
            dpkg -i debian/bin/unstable/xenial/*.deb"
elif [ "$DISTRO" = "centos7" ]; then
    if [ "$DOCKER" = "distro" ]; then
        docker_cmd="curl -sSL https://get.docker.com/ | sh"
    elif [ "$DOCKER" = "upstream" ]; then
        docker_cmd="yum install -y docker"
    fi
    common_setup="$docker_cmd
cat <<EOF > /etc/yum.repos.d/k8s.repo
[kubelet]
name=kubelet
baseurl=http://files.rm-rf.ca/rpms/kubelet/
enabled=1
gpgcheck=0
EOF
setenforce 0
yum install -y kubelet kubeadm kubectl kubernetes-cni
systemctl enable docker && systemctl start docker
systemctl enable kubelet && systemctl start kubelet"
fi

# common setup
parallel -i tugboat ssh kubeadm-$DISTRO-{} -c "$common_setup" -- {1..3}

# install the master
tugboat ssh kubeadm-$DISTRO-1 -c "kubeadm init |tee init-output.txt"
join_cmd=`tugboat ssh kubeadm-$DISTRO-1 -c "tail -n 1 init-output.txt" |tail -n 1`
echo "GOT JOIN COMMAND $join_cmd"
# run the command the master gave us on the nodes
for X in {2..3}; do
    tugboat ssh kubeadm-$DISTRO-$X -c "$join_cmd"
done

nodes="0"
while [ $nodes -ne 4 ]; do
    nodes=`tugboat ssh kubeadm-$DISTRO-1 -c "kubectl get nodes |wc -l"`
    echo "Got $nodes nodes"
done

echo "Success!"
