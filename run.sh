#!/bin/bash
set -xe

for DISTRO in xenial centos7; do
    for DOCKER in distro upstream; do
    echo Creating VMs for combo $DISTRO + $DOCKER docker
    ./create.sh $DISTRO $DOCKER

    echo Waiting for them to boot
    sleep 45

    echo Starting tests
    log="$DISTRO-$DOCKER-`date +%s`.log"
    if ./test.sh $DISTRO $DOCKER > $log 2>&1; then
        echo $DISTRO $DOCKER PASS
    else
        echo $DISTRO $DOCKER FAIL, see $log
    fi

    echo Destroying everything
    ./destroy-all.sh
    done
done
