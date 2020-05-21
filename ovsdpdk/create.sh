#!/bin/bash

set -ex
OVSDPDK_IMG="quay.io/krsacme/kubevirt-ovsdpdk-builder:latest"
docker build build/ -t $OVSDPDK_IMG
mkdir -p $PWD/files/
docker run -v $PWD/files:/host --privileged $OVSDPDK_IMG
docker push $OVSDPDK_IMG

IMG="quay.io/krsacme/kubevirt-ovsdpdk-helpers:latest"
docker build . -t $IMG
docker push $IMG
