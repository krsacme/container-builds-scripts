#!/bin/bash

yum config-manager --set-enabled PowerTools

yum install -y wget make gcc numactl-devel kernel-devel git autoconf automake libtool  libcap-ng-devel python3 rpm-build openssl-devel unbound unbound-devel selinux-policy-devel graphviz gcc-c++ desktop-file-utils procps-ng python3-devel libpcap-devel libmnl-devel  glibc groff python3-sphinx libibverbs libibverbs-devel elfutils-libelf-devel

DPDK=19.11.2
export DPDK_DIR=$PWD/dpdk-stable-$DPDK
export DPDK_TARGET=x86_64-native-linuxapp-gcc
export DPDK_BUILD=$DPDK_DIR/build
wget https://fast.dpdk.org/rel/dpdk-$DPDK.tar.xz
tar xf dpdk-$DPDK.tar.xz
cd $DPDK_DIR
make config T=$DPDK_TARGET

# igb_uio.ko kernel module is required from DPDK build
# Reduce the build time, by reducing unwanted libraries
sed -i -E 's/(CONFIG_RTE.*=)y/\1n/g' $DPDK_BUILD/.config
sed -i -E 's/(CONFIG_RTE_EAL_IGB_UIO=).*/\1y/g' $DPDK_BUILD/.config
sed -i -E 's/(CONFIG_RTE_LIBRTE_EAL=).*/\1y/g' $DPDK_BUILD/.config
sed -i -E 's/(CONFIG_RTE_EAL_VFIO=).*/\1y/g' $DPDK_BUILD/.config
sed -i -E 's/(CONFIG_RTE_ARCH_X86_64=).*/\1y/g' $DPDK_BUILD/.config
sed -i -E 's/(CONFIG_RTE_ARCH_X86=).*/\1y/g' $DPDK_BUILD/.config
sed -i -E 's/(CONFIG_RTE_ARCH_64=).*/\1y/g' $DPDK_BUILD/.config
sed -i -E 's/(CONFIG_RTE_TOOLCHAIN_GCC=).*/\1y/g' $DPDK_BUILD/.config
sed -i -E 's/(CONFIG_RTE_EXEC_ENV_LINUX=).*/\1y/g' $DPDK_BUILD/.config
sed -i -E 's/(CONFIG_RTE_EXEC_ENV_LINUXAPP=).*/\1y/g' $DPDK_BUILD/.config
sed -i -E 's/(CONFIG_RTE_EAL_NUMA_AWARE_HUGEPAGES=).*/\1y/g' $DPDK_BUILD/.config
sed -i -E 's/(CONFIG_RTE_LIBRTE_PCI=).*/\1y/g' $DPDK_BUILD/.config
sed -i -E 's/(CONFIG_RTE_LIBRTE_KVARGS=).*/\1y/g' $DPDK_BUILD/.config
sed -i -E 's/(CONFIG_RTE_LIBRTE_ETHER=).*/\1y/g' $DPDK_BUILD/.config
sed -i -E 's/(CONFIG_RTE_ETHDEV_RXTX_CALLBACKS=).*/\1y/g' $DPDK_BUILD/.config
sed -i -E 's/(CONFIG_RTE_BACKTRACE=).*/\1y/g' $DPDK_BUILD/.config
sed -i -E 's/(CONFIG_RTE_LIBRTE_NET=).*/\1y/g' $DPDK_BUILD/.config
sed -i -E 's/(CONFIG_RTE_LIBRTE_MBUF=).*/\1y/g' $DPDK_BUILD/.config
sed -i -E 's/(CONFIG_RTE_LIBRTE_MEMPOOL=).*/\1y/g' $DPDK_BUILD/.config
sed -i -E 's/(CONFIG_RTE_LIBRTE_RING=).*/\1y/g' $DPDK_BUILD/.config
sed -i -E 's/(CONFIG_RTE_LIBRTE_METER=).*/\1y/g' $DPDK_BUILD/.config

cd $DPDK_BUILD
make T=$DPDK_TARGET

mkdir -p /opt/ovsdpdk
cp $DPDK_BUILD/kmod/igb_uio.ko /opt/ovsdpdk

