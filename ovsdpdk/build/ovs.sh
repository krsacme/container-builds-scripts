#!/bin/bash

set -ex

setenforce 0
yum config-manager --set-enabled PowerTools

yum install -y wget make gcc numactl-devel kernel-devel git autoconf automake libtool  libcap-ng-devel python3 rpm-build openssl-devel unbound unbound-devel selinux-policy-devel graphviz gcc-c++ desktop-file-utils procps-ng python3-devel libpcap-devel libmnl-devel  glibc groff python3-sphinx libibverbs libibverbs-devel elfutils-libelf-devel dpdk dpdk-devel

# Centos 8 in kubevirt CI has DPDK 19.11 version
#yum install -y dpdk dpdk-devel

cd $HOME
git clone --depth 1 --single-branch --branch branch-2.13 https://github.com/openvswitch/ovs.git
cd ovs/ 
./boot.sh
./configure --with-dpdk=/usr/share/dpdk/x86_64-default-linux-gcc/ --prefix=/usr --localstatedir=/var --sysconfdir=/etc

# virtio driver does not support MQ
sed -i 's/ETH_MQ_RX_RSS/ETH_MQ_RX_NONE/g' lib/netdev-dpdk.c

make rpm-fedora RPMBUILD_OPT="--with dpdk --without check"

mkdir -p /opt/ovsdpdk
cp rpm/rpmbuild/RPMS/x86_64/openvswitch-2.13.* /opt/ovsdpdk
