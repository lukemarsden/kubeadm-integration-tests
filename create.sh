#!/bin/bash
# usage: ./create.sh xenial distro (default, uses docker in xenial)
#        ./create.sh xenial upstream (uses docker from dockerproject.org)
#        ./create.sh centos7 distro
#        ./create.sh centos7 upstream
set -xe
DISTRO=${1:-"xenial"}
DOCKER=${2:-"upstream"}
for X in {1..3}; do
    if [ "$DISTRO" = "xenial" ]; then
        img="ubuntu-16-04-x64"
    elif [ "$DISTRO" = "centos7" ]; then
        img="centos-7-x64"
    fi
    tugboat create -s 2gb -i $img -r lon1 kubeadm-$DISTRO-$DOCKER-$X
done
