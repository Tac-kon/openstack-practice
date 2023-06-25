#!/bin/bash

# vi /etc/systemd/network/eth1.network
# [Match]
# Name=eth1

# [Network]
# LinkLocalAddressing=no
# IPv6AcceptRA=no

# ip link set eth1 up
# # ブリッジ作成 (名称は任意)
# ovs-vsctl add-br br-eth1
# # 追加したブリッジのポートに [eth1] を追加
# # [eth1] は環境によって異なるため自身の環境に置き換え
# ovs-vsctl add-port br-eth1 eth1
# # ブリッジと [physnet1] をマッピング ([physnet1] の名称は任意)
# ovs-vsctl set open . external-ids:ovn-bridge-mappings=physnet1:br-eth1

projectID=$(openstack --insecure project list | grep service | awk '{print $2}')
# [sharednet1] という名称の仮想ネットワーク作成
openstack --insecure network create --project $projectID \
--share --provider-network-type flat --provider-physical-network physnet1 sharednet1

openstack --insecure subnet create subnet1 --network sharednet1 \
--project $projectID --subnet-range 192.168.1.0/24 \
--allocation-pool start=192.168.1.121,end=192.168.1.150 \
--gateway 192.168.1.1 --dns-nameserver 192.168.1.1

openstack --insecure network list
openstack --insecure subnet list