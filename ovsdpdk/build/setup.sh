#!/bin/bash

set -ex

ip link add br0 type bridge
ip link set dev br0 up
ip addr add dev br0 192.168.201.02/24

n=01
ip tuntap add dev tap${n} mode tap user $(whoami)
ip link set tap${n} master br0
ip link set dev tap${n} up

DHCP_HOSTS="${DHCP_HOSTS} --dhcp-host=52:55:00:d1:54:${n},192.168.201.1${n},node${n},infinite"
dnsmasq -d ${DHCP_HOSTS} --dhcp-range=192.168.201.10,192.168.201.200,infinite &

# Make sure that all VMs can reach the internet
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i br0 -o eth0 -j ACCEPT

# Route SSH
iptables -t nat -A POSTROUTING ! -s 192.168.201.0/16 --out-interface br0 -j MASQUERADE
iptables -A FORWARD --in-interface eth0 -j ACCEPT
iptables -t nat -A PREROUTING -p tcp -i eth0 -m tcp --dport 22${n} -j DNAT --to-destination 192.168.201.1${n}:22

mkdir /opt/files
qemu-img create -f qcow2 -o backing_file=box.qcow2 /disk01.qcow2 10G
MEMORY=4096
QEMU_ARGS=""
CPU=4
qemu-system-x86_64 -enable-kvm -drive format=qcow2,file=/disk01.qcow2,if=virtio,cache=unsafe \
  -device virtio-net-pci,netdev=network0,mac=52:55:00:d1:54:${n} \
  -netdev tap,id=network0,ifname=tap${n},script=no,downscript=no \
  -device virtio-rng-pci \
  -vnc :${n} -cpu host -m ${MEMORY} -smp ${CPU} ${QEMU_ARGS} \
  -virtfs local,path=/opt/files,mount_tag=host0,security_model=passthrough,id=host0 \
  -serial pty &

TIMEOUT=20
sleep $TIMEOUT
SSH="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no vagrant@192.168.201.101 -i vagrant.key -p 22"
$SSH "sudo yum update -y kernel"
set +e
$SSH "sudo reboot"
set -e
sleep $TIMEOUT

$SSH sudo sh < ./ovs.sh
$SSH sudo sh < ./dpdk.sh

$SSH "sudo yum config-manager --set-enabled centosplus"
$SSH "sudo yum install -y kernel-plus kernel-plus-devel"
$SSH "sudo grubby --set-default=$(sudo grubby --info=ALL | grep 'kernel=' | grep plus | cut -d= -f2 | sed 's/"//g')"
set +e
$SSH "sudo reboot"
set -e
sleep $TIMEOUT

$SSH "sudo modprobe 9pnet && sudo modprobe 9pnet_virtio"
$SSH "sudo mkdir -p /opt/files && sudo mount -t 9p -o trans=virtio,version=9p2000.L host0 /opt/files"
$SSH "sudo cp /opt/ovsdpdk/* /opt/files/"

if [[ -d /host ]]; then
    echo "Copying files to /host directory"
    cp /opt/files/* /host
fi
echo "Done"
