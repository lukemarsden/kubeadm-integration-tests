#!/bin/bash
set -xe
for DISTRO in ubuntu fedora; do
    for X in {1..3}; do yes |tugboat destroy kubeadm-ubuntu-$X; done
    for X in {1..3}; do yes |tugboat destroy kubeadm-fedora-$X; done
done
