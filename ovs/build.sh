#!/bin/bash

set -eux

docker build . -t quay.io/krsacme/ovs-rpmbuild-f31:latest

docker run -v $PWD:/host quay.io/krsacme/ovs-rpmbuild-f31:latest
