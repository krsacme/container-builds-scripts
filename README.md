This repository contains scripts to build helper docker images.

Kubevirt OvS-DPDK Helper Images
-------------------------------
In order to deploy OvS-DPDK with kubevirt in a virtualized envioronment for
kubevirtci, following are required:

* OvS with DPDK - OvS RPM should be built with DPDK enabled. The default
  packages on upstream does not have DPDK enabled.

* PMD Driver - Kernel module `igb_uio`, which is part of DPDK source code,
  should be built in order to use DPDK in virtualized environment.

It is possible to build the requirements from source code directly in the CI
environment, but it will take a chunk of time to complete the build. And the
RPM and driver has no specific dependency to build it every time, it can be
built once and used multiple times, given that same kernel is used for the
build and the deployment.

The helper scripts addded in the directory `ovsdpdk` simulates the same
vagrant based CentOS 8 (Stream) images and repos, which will be used in the
kubevirtci environment. It reduces the CI run time for OvS-DPDK Jobs.

Alternatively, it is possible to create a OvS-DPDK provisioned docker image,
which will be oned only for the DPDK worker nodes. Till the feasibility of
this option is explored, above stop-gap arragement works well.
