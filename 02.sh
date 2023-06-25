#!/bin/bash

apt -y install software-properties-common
add-apt-repository cloud-archive:antelope
apt update
apt -y upgrade

apt -y install rabbitmq-server memcached python3-pymysql nginx libnginx-mod-stream

rabbitmqctl add_user openstack password
rabbitmqctl set_permissions openstack ".*" ".*" ".*"