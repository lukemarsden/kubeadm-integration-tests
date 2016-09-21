#!/bin/bash
set -xe
DISTRO=${1:-ubuntu}
# Install the master
if [ $DISTRO -eq "ubuntu" ]; then
    # common stuff
    for X in {1..3}; do
        tugboat ssh kubeadm-$DISTRO-$X -c "curl -sSL https://get.docker.com/ | sh && \
            curl -s -L 'https://www.dropbox.com/s/xxk6wn82319p8bs/debs-ea9013.txz?dl=1' | tar xJv && \
            dpkg -i debian/bin/unstable/xenial/*.deb"
    done
    # install the master
    # run the same command on the nodes
fi
