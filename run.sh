#!/bin/bash
set -xe
./create.sh ubuntu
#./create.sh fedora

./test.sh ubuntu
#./test.sh fedora

./destroy-all.sh
