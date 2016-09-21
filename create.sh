#!/bin/bash
# usage: ./create.sh ubuntu (defaults to ubuntu)
#        ./create.sh centos
set -xe
DISTRO=${1:-"ubuntu"}
for X in {1..3}; do
    if [ "$DISTRO" = "ubuntu"]; then
        tugboat create -s 2gb -i ubuntu-16-04-x64 -r lon1 kubeadm-$DISTRO-$X
    elif [ "$DISTRO" = "centos" ]; then
        tugboat create -s 2gb -i centos-7-x64 -r lon1 kubeadm-$DISTRO-$X
    fi
done
