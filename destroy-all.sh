#!/bin/bash
set -x
for DISTRO in xenial centos7; do
    for DOCKER in distro upstream; do
        for MULTINODE in 0 1 ; do
            for X in {1..3}; do yes |tugboat destroy kubeadm-$DISTRO-$DOCKER-$MULTINODE-$X; done
        done
    done
done
