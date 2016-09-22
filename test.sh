#!/bin/bash
set -xe
DISTRO=${1:-ubuntu}
# Install the master
if [ "$DISTRO" = "ubuntu" ]; then
    # curl -sSL https://get.docker.com/ | sh && \
    # ubuntu package variant below v  docker official images variant above ^
    common_setup="apt-get install -y docker.io && \
            apt-get install -y socat && \
            curl -s -L 'https://www.dropbox.com/s/tso6dc7b94ch2sk/debs-5ab576.txz?dl=1' | tar xJv && \
            dpkg -i debian/bin/unstable/xenial/*.deb"
elif [ "$DISTRO" = "centos" ]; then
    common_setup="cat <<EOF > /etc/yum.repos.d/k8s.repo
[kubelet]
name=kubelet
baseurl=http://files.rm-rf.ca/rpms/kubelet/
enabled=1
gpgcheck=0
EOF
setenforce 0
yum install -y kubelet kubeadm kubectl kubernetes-cni docker
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
