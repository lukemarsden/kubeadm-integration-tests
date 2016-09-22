#!/bin/bash
set -e

for DISTRO in xenial centos7; do
    for DOCKER in distro upstream; do
        log="$DISTRO-$DOCKER-`date +%s`.log"
        echo Creating VMs for combo $DISTRO + $DOCKER docker
        echo Logging to $log
        ./create.sh $DISTRO $DOCKER >> $log 2>&1

        echo Waiting for them to boot
        sleep 45

        echo Starting tests
        if ./test.sh $DISTRO $DOCKER >> $log 2>&1; then
            echo $DISTRO $DOCKER PASS, see $log
        else
            echo $DISTRO $DOCKER FAIL, see $log
        fi

        echo Attempting to destroy everything
        ./destroy-all.sh >> $log 2>&1 || true
    done
done
