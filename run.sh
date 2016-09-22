#!/bin/bash
set -e

for DISTRO in xenial centos7; do
    for DOCKER in distro upstream; do
        log="$DISTRO-$DOCKER-`date +%s`.log"
        echo "--> distro $DISTRO + $DOCKER docker, $log"
        ./create.sh $DISTRO $DOCKER >> $log 2>&1

        echo Waiting for them to boot >> $log
        sleep 45

        echo Starting tests >> $log
        if ./test.sh $DISTRO $DOCKER >> $log 2>&1; then
            echo distro: $DISTRO, docker: $DOCKER, result: PASS
        else
            echo distro: $DISTRO, docker: $DOCKER, result: FAIL
        fi

        echo Attempting to destroy everything >> $log
        ./destroy-all.sh >> $log 2>&1 || true
    done
done
