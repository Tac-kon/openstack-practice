#!/bin/bash
apt update
apt -y install qemu-kvm libvirt-daemon-system libvirt-daemon virtinst bridge-utils libosinfo-bin


# systemctl restart nova-compute
# # Compute ノード ディスカバー
# su -s /bin/bash nova -c "nova-manage cell_v2 discover_hosts"
# # 動作確認
# openstack --insecure compute service list