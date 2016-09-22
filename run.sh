#!/bin/bash
set -e

echo "<html><head><title>kubeadm cowboy CI</title><script>setTimeout(function(){window.location.reload(1);}, 5000);</script></head><body><h1>last started: `date`</h1>" > index-new.html

for DISTRO in xenial centos7; do
    for DOCKER in distro upstream; do
        log="$DISTRO-$DOCKER-`date +%s`.log"
        echo "--> distro: $DISTRO, docker: $DOCKER, log: $log" |tee -a all-runs.txt
        ./create.sh $DISTRO $DOCKER >> $log 2>&1

        echo Waiting for them to boot >> $log
        sleep 45

        echo Starting tests >> $log
        if ./test.sh $DISTRO $DOCKER >> $log 2>&1; then
            echo result: PASS |tee -a all-runs.txt
            echo "<div style='width:48%; height: 40%; background-color:green; font-size:64px; float:left; margin:0.8%;'>PASS distro: $DISTRO, docker: $DOCKER <a href='$log' style='font-size:normal;'>log</a></div>" >> index-new.html
        else
            echo result: FAIL |tee -a all-runs.txt
            echo "<div style='width:48%; height: 40%; background-color:red; font-size:64px; float:left; margin:0.8%;'>FAIL distro: $DISTRO, docker: $DOCKER <a href='$log' style='font-size:normal;'>log</a></div>" >> index-new.html
        fi

        docker_version=`tugboat ssh kubeadm-$DISTRO-$DOCKER-1 -c "docker version" |grep Version |head -n 1`
        echo "Docker $docker_version" |tee -a all-runs.txt

        echo Attempting to destroy everything >> $log
        ./destroy-all.sh >> $log 2>&1 || true
    done
done

echo "<a href='https://github.com/lukemarsden/kubeadm-integration-tests'>repo</a></body></html>" >> index-new.html
mv index-new.html index.html
