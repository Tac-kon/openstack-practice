#!/bin/bash
# # [service] プロジェクト所属で [nova] ユーザーを作成
# openstack --insecure user create --domain default --project service --password servicepassword nova

# # [nova] ユーザーを [admin] ロール に加える
# openstack --insecure role add --project service --user nova admin
# # [service] プロジェクト所属で [placement] ユーザーを作成
# openstack --insecure user create --domain default --project service --password servicepassword placement

# # [placement] ユーザーを [admin] ロール に加える
# openstack --insecure role add --project service --user placement admin
# # [nova] 用サービスエントリ作成
# openstack --insecure service create --name nova --description "OpenStack Compute service" compute

# # [placement] 用サービスエントリ作成
# openstack --insecure service create --name placement --description "OpenStack Compute Placement service" placement
# # Nova API ホストを定義
# controller=dlp.srv.world
# # [nova] 用エンドポイント作成 (public)
# openstack --insecure endpoint create --region RegionOne compute public https://$controller:8774/v2.1/%\(tenant_id\)s

# # [nova] 用エンドポイント作成 (internal)
# openstack --insecure endpoint create --region RegionOne compute internal https://$controller:8774/v2.1/%\(tenant_id\)s

# # [nova] 用エンドポイント作成 (admin)
# openstack --insecure endpoint create --region RegionOne compute admin https://$controller:8774/v2.1/%\(tenant_id\)s

# # [placement] 用エンドポイント作成 (public)
# openstack --insecure endpoint create --region RegionOne placement public https://$controller:8778

# # [placement] 用エンドポイント作成 (internal)
# openstack --insecure endpoint create --region RegionOne placement internal https://$controller:8778

# # [placement] 用エンドポイント作成 (admin)
# openstack --insecure endpoint create --region RegionOne placement admin https://$controller:8778


mysql << EOS
create database nova; 
grant all privileges on nova.* to nova@'localhost' identified by 'password'; 
grant all privileges on nova.* to nova@'%' identified by 'password'; 
create database nova_api; 
grant all privileges on nova_api.* to nova@'localhost' identified by 'password'; 
grant all privileges on nova_api.* to nova@'%' identified by 'password'; 
create database placement; 
grant all privileges on placement.* to placement@'localhost' identified by 'password'; 
grant all privileges on placement.* to placement@'%' identified by 'password'; 
create database nova_cell0; 
grant all privileges on nova_cell0.* to nova@'localhost' identified by 'password'; 
grant all privileges on nova_cell0.* to nova@'%' identified by 'password'; 
flush privileges; 
EOS