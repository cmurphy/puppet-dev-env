#!/bin/bash

set -eux

set_hostname() {
  local hostname=$1
  sshvm $hostname "echo $hostname > /etc/hostname"
  sshvm $hostname "hostname $hostname"
}

sudo true
export DDD_WORKDIR=${DDD_WORKDIR:-"${HOME}/ddd-workdir"}
export PATH=$PATH:$DDD_WORKDIR/tools/dib-dev-deploy/scripts
export DDD_ELEMENTS_PATH=${DDD_ELEMENTS_PATH:-"${DDD_WORKDIR}/elements"}
export DIB_HOSTNAME=${DIB_HOSTNAME:-'allinone'}
export DIB_OS=${DIB_OS:-'ubuntu'}
export DDD_VM_TEMPLATE=${DDD_VM_TEMPLATE:-"${DDD_WORKDIR}/templates/allinone-vm.xml"}
export DDD_VM_MEMORY=${DDD_VM_MEMORY:-8192}
export DDD_VM_CPUS=${DDD_VM_CPUS:-2}

source "${DDD_WORKDIR}/scripts/sshvm"

### Define networks

for i in $(seq 0 3) ; do
  virsh net-define "${DDD_WORKDIR}/templates/allinone-${i}-net.xml"
done

### Initialize tools

ddd-pull-tools

### Build and install image

image_path="${DDD_WORKDIR}/images/${DIB_HOSTNAME}.qcow2"
ddd-create-image $DIB_OS dhcp-all-interfaces local-config puppet post-boot -o $image_path --image-size 40
ddd-define-vm $DIB_HOSTNAME $image_path
virsh start $DIB_HOSTNAME
set_hostname $DIB_HOSTNAME
sshvm $DIB_HOSTNAME
