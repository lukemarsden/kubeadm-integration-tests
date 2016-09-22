#!/bin/bash
set -x
for DISTRO in xenial centos7; do
    for DOCKER in distro upstream; do
        for X in {1..3}; do yes |tugboat destroy kubeadm-$DISTRO-$DOCKER-$X; done
    done
done
