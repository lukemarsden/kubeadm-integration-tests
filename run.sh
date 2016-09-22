#!/bin/bash
set -e

./destroy-all.sh >/dev/null 2>&1 || true

path=${1:-"/var/www/html"}
echo "<html><head><title>kubeadm cowboy CI</title><script>setTimeout(function(){window.location.reload(1);}, 5000);</script></head><body><h1>last started: `date`</h1>" > $path/ci-new.html

for DISTRO in xenial centos7; do
    for DOCKER in distro upstream; do
        for MULTINODE in 0 1; do
            log="$DISTRO-$DOCKER-$MULTINODE-`date +%s`.log"
            echo "--> distro: $DISTRO, docker: $DOCKER, multinode: $MULTINODE, log: $log" |tee -a $path/all-runs.txt
            ./create.sh $DISTRO $DOCKER $MULTINODE >> $path/$log 2>&1

            echo Waiting for them to boot >> $path/$log
            sleep 60

            echo Starting tests >> $log
            if ./test.sh $DISTRO $DOCKER $MULTINODE >> $path/$log 2>&1; then
                echo result: PASS |tee -a $path/all-runs.txt
                echo "<div style='width:48%; height: 20%; background-color:green; font-size:48px; float:left; margin:0.8%;'>PASS distro: $DISTRO, docker: $DOCKER, multinode: $MULTINODE <a href='$log' style='font-size:normal;'>log</a></div>" >> $path/ci-new.html
            else
                echo result: FAIL |tee -a $path/all-runs.txt
                echo "<div style='width:48%; height: 20%; background-color:red; font-size:48px; float:left; margin:0.8%;'>FAIL distro: $DISTRO, docker: $DOCKER, multinode: $MULTINODE <a href='$log' style='font-size:normal;'>log</a></div>" >> $path/ci-new.html
            fi

            docker_version=`tugboat ssh kubeadm-$DISTRO-$DOCKER-1 -c "docker version" |grep Version |head -n 1`
            echo "Docker $docker_version" |tee -a $path/all-runs.txt

            echo Attempting to destroy everything >> $path/$log
            ./destroy-all.sh >> $path/$log 2>&1 || true
        done
    done
done

echo "<a href='https://github.com/lukemarsden/kubeadm-integration-tests'>repo</a></body></html>" >> $path/ci-new.html
mv $path/ci-new.html $path/ci.html
