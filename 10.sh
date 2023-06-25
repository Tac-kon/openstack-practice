#!/bin/bash
openstack --insecure user create --domain default --project service --password servicepassword neutron

# [neutron] ユーザーを [admin] ロール に加える
openstack --insecure role add --project service --user neutron admin
# [neutron] 用サービスエントリ作成
openstack --insecure service create --name neutron --description "OpenStack Networking service" network

# Neutron API ホストを定義
controller=dlp.srv.world
# [neutron] 用エンドポイント作成 (public)
openstack --insecure endpoint create --region RegionOne network public https://$controller:9696
# [neutron] 用エンドポイント作成 (internal)
openstack --insecure endpoint create --region RegionOne network internal https://$controller:9696

# [neutron] 用エンドポイント作成 (admin)
openstack --insecure endpoint create --region RegionOne network admin https://$controller:9696

mysql << EOS
create database neutron_ml2; 
grant all privileges on neutron_ml2.* to neutron@'localhost' identified by 'password';
grant all privileges on neutron_ml2.* to neutron@'%' identified by 'password'; 
flush privileges; 
EOS