FROM fedora:31
RUN dnf -y update nettle && dnf -y install jq iptables iproute dnsmasq qemu openssh-clients socat wget iputils
#ENV BOX="https://cloud.centos.org/centos/8/x86_64/images/CentOS-8-Vagrant-8.0.1905-1.x86_64.vagrant-libvirt.box"
ENV BOX="https://cloud.centos.org/centos/8-stream/x86_64/images/CentOS-Stream-Vagrant-8-20200113.0.x86_64.vagrant-libvirt.box"
RUN wget -O centos8.box -q $BOX
RUN tar -zxf centos8.box
RUN qemu-img convert -O qcow2 box.img box.qcow2
RUN mkdir -p /opt/dpdk
COPY vagrant.key vagrant.key
COPY setup.sh setup.sh
RUN chmod +x /setup.sh
COPY ovs.sh ovs.sh
COPY dpdk.sh dpdk.sh
CMD /setup.sh
