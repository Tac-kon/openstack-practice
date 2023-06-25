#!/bin/bash
# 公式ディスクイメージをダウンロード
# wget http://cloud-images.ubuntu.com/releases/22.04/release/ubuntu-22.04-server-cloudimg-amd64.img
# # ディスクイメージ内の設定を変更したい場合は以下
# # ディスクイメージ マウント
# modprobe nbd
# qemu-nbd --connect=/dev/nbd0 ubuntu-22.04-server-cloudimg-amd64.img
# mount /dev/nbd0p1 /mnt
# vi /mnt/etc/cloud/cloud.cfg
# # 13行目 : 追記
# # SSH パスワード認証も許可する場合は設定
# ssh_pwauth: true
# # 99行目 : 変更
# # [ubuntu] ユーザーのパスワード認証を許可する場合は設定
# system_info:
#    # This will affect which distro class gets used
#    distro: ubuntu
#    # Default user name + that default users groups (if added/used)
#    default_user:
#      name: ubuntu
#      lock_passwd: False
#      gecos: Ubuntu

# umount /mnt
# qemu-nbd --disconnect /dev/nbd0p1
# /dev/nbd0p1 disconnected
# # Glance へ登録
openstack --insecure image create "Ubuntu2204" --file ubuntu-22.04-server-cloudimg-amd64.img --disk-format qcow2 --container-format bare --public
openstack --insecure image list