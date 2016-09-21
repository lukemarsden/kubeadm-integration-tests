#!/bin/bash
set -x
for DISTRO in ubuntu centos; do
    for X in {1..3}; do yes |tugboat destroy kubeadm-ubuntu-$X; done
    for X in {1..3}; do yes |tugboat destroy kubeadm-centos-$X; done
done
