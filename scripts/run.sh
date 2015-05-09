#!/bin/bash

export DDD_WORKDIR=${DDD_WORKDIR:-"${HOME}/ddd-workdir"}
export PATH=$PATH:$DDD_WORKDIR/tools/dib-dev-deploy/scripts
export DDD_ELEMENTS_PATH=${DDD_ELEMENTS_PATH:-"${DDD_WORKDIR}/elements"}
export DIB_HOSTNAME=${DIB_HOSTNAME:-'allinone'}
export DDD_VM_TEMPLATE=${DDD_VM_TEMPLATE:-"${DDD_WORKDIR}/templates/allinone-vm.xml"}

source "${DDD_WORKDIR}/scripts/sshvm"

### Define networks

for i in $(seq 0 3) ; do
  virsh net-define "${DDD_WORKDIR}/templates/allinone-${i}-net.xml"
done

### Initialize tools

ddd-pull-tools

### Build and install image

image_path="${DDD_WORKDIR}/images/$DIB_HOSTNAME.qcow2"
ddd-create-image local-config ubuntu hostname puppet post-boot -o $image_path
ddd-define-vm $DIB_HOSTNAME $image_path
virsh start $DIB_HOSTNAME
echo "Waiting for vm to boot"
sleep 20
sshvm $DIB_HOSTNAME
