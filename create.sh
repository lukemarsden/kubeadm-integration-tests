#!/bin/bash
# usage: ./create.sh xenial distro 0/1 (default, uses docker in xenial)
#        ./create.sh xenial upstream 0/1 (uses docker from dockerproject.org)
#        ./create.sh centos7 distro 0/1
#        ./create.sh centos7 upstream 0/1
set -xe
DISTRO=${1:-"xenial"}
DOCKER=${2:-"upstream"}
MULTINODE=${3:-"0"} # multinode, 0 = off, 1 = on

if [ $MULTINODE -eq 1 ]; then
    ALLNODES="1 2 3"
else
    ALLNODES="1"
fi

for X in $ALLNODES; do
    if [ "$DISTRO" = "xenial" ]; then
        img="ubuntu-16-04-x64"
    elif [ "$DISTRO" = "centos7" ]; then
        img="centos-7-x64"
    fi
    tugboat create -s 2gb -i $img -r lon1 kubeadm-$DISTRO-$DOCKER-$X
done
