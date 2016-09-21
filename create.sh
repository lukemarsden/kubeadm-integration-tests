#!/bin/bash
# usage: ./create.sh ubuntu (defaults to ubuntu)
#        ./create.sh fedora
set -xe
DISTRO=${1:-ubuntu}
for X in {1..3}; do
    tugboat create -s 2gb -i ubuntu-16-04-x64 -r lon1 kubeadm-$DISTRO-$X
done
