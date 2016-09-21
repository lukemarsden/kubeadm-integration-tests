#!/bin/bash
set -xe
echo Creating VMs
#./create.sh ubuntu
./create.sh centos

echo Waiting for them to boot
sleep 45

echo Starting tests
#./test.sh ubuntu
./test.sh centos

echo Destroying everything
./destroy-all.sh
