#!/bin/bash
set -xe
DISTRO=${1:-ubuntu}
# Install the master
if [ "$DISTRO" = "ubuntu" ]; then
    # common stuff
    for X in {1..3}; do
        tugboat ssh kubeadm-$DISTRO-$X -c "curl -sSL https://get.docker.com/ | sh && \
            curl -s -L 'https://www.dropbox.com/s/xxk6wn82319p8bs/debs-ea9013.txz?dl=1' | tar xJv && \
            dpkg -i debian/bin/unstable/xenial/*.deb"
    done
elif [ "$DISTRO" = "fedora" ]; then
    for X in {1..3}; do
        tugboat ssh kubeadm-$DISTRO-$X -c "cat <<EOF > /etc/yum.repos.d/k8s.repo
[kubelet]
name=kubelet
baseurl=http://files.rm-rf.ca/rpms/kubelet/
enabled=1
gpgcheck=0
EOF
setenforce 0
yum install kubelet kubeadm kubectl kubernetes-cni
systemctl enable docker && systemctl start docker
systemctl enable kubelet && systemctl start kubelet"
    done
fi

# install the master
cmd=`tugboat ssh kubeadm-$DISTRO-$X -c "kubeadm init" |tail -n 1`
# run the command the master gave us on the nodes
for X in {2..3}; do
    tugboat ssh kubeadm-$DISTRO-$X -c "$cmd"
done
