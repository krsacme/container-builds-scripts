FROM fedora:31

RUN sudo yum install -y wget make gcc numactl-devel kernel-devel git autoconf automake libtool  libcap-ng-devel python3 rpm-build openssl-devel unbound-devel selinux-policy-devel groff graphviz gcc-c++ desktop-file-utils python3-sphinx libpcap-devel python3-devel unbound procps-ng

RUN sudo yum install -y https://rpmfind.net/linux/fedora/linux/updates/testing/32/Everything/x86_64/Packages/d/dpdk-19.11.1-1.fc32.x86_64.rpm

RUN sudo yum install -y https://rpmfind.net/linux/fedora/linux/updates/testing/32/Everything/x86_64/Packages/d/dpdk-devel-19.11.1-1.fc32.x86_64.rpm

RUN git clone --depth 1 https://github.com/openvswitch/ovs.git

WORKDIR ovs/

CMD ./boot.sh && \
    ./configure --with-dpdk=/usr/share/dpdk/x86_64-default-linux-gcc/ --prefix=/usr --localstatedir=/var --sysconfdir=/etc && \
    make rpm-fedora RPMBUILD_OPT="--with dpdk --without check" && \
    cp rpm/rpmbuild/RPMS/x86_64/openvswitch-2.* /host

