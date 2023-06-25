#!/bin/bash

cat << EOF > ~/keystonerc
export OS_PROJECT_DOMAIN_NAME=default
export OS_USER_DOMAIN_NAME=default
export OS_PROJECT_NAME=hiroshima
export OS_USERNAME=serverworld
export OS_PASSWORD=userpassword
export OS_AUTH_URL=https://dlp.srv.world:5000/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
export PS1='\u@\h \W(keystone)\$ '
EOF

chmod 600 ~/keystonerc
source ~/keystonerc
echo "source ~/keystonerc " >> ~/.bash_profile

openstack --insecure flavor list

# 利用可能なイメージ確認
openstack --insecure image list
# 利用可能なネットワーク確認
openstack --insecure network list
# インスタンス用のセキュリティグループを作成
openstack --insecure security group create secgroup01
openstack --insecure security group list
openstack --insecure security group delete secgroup01

openstack --insecure security group list
ssh-keygen -q -N ""

openstack --insecure keypair create --public-key ~/.ssh/id_rsa.pub mykey
openstack --insecure keypair list
openstack --insecure keypair delete mykey

netID=$(openstack --insecure network list | grep sharednet1 | awk '{ print $2 }')
openstack --insecure server create --flavor m1.small --image Ubuntu2204 --security-group secgroup01 --nic net-id=$netID --key-name mykey Ubuntu-2204

openstack --insecure server list
# openstack --insecure server list

# openstack --insecure security group rule create --protocol icmp --ingress secgroup01
# openstack --insecure security group rule create --protocol tcp --dst-port 22:22 secgroup01

# openstack --insecure security group rule list secgroup01
# openstack --insecure server list