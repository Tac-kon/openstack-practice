#!/bin/bash

# mv /etc/nova/nova.conf /etc/nova/nova.conf.org
# cat << EOF > /etc/nova/nova.conf
# [DEFAULT]
# osapi_compute_listen = 127.0.0.1
# osapi_compute_listen_port = 8774
# metadata_listen = 127.0.0.1
# metadata_listen_port = 8775
# state_path = /var/lib/nova
# enabled_apis = osapi_compute,metadata
# log_dir = /var/log/nova
# # RabbitMQ サーバー接続情報
# transport_url = rabbit://openstack:password@dlp.srv.world

# [api]
# auth_strategy = keystone

# [vnc]
# enabled = True
# novncproxy_host = 127.0.0.1
# novncproxy_port = 6080
# novncproxy_base_url = https://dlp.srv.world:6080/vnc_auto.html

# # Glance サーバー接続情報
# [glance]
# api_servers = https://dlp.srv.world:9292

# [oslo_concurrency]
# lock_path = $state_path/tmp

# # MariaDB サーバー接続情報
# [api_database]
# connection = mysql+pymysql://nova:password@dlp.srv.world/nova_api

# [database]
# connection = mysql+pymysql://nova:password@dlp.srv.world/nova

# # Keystone サーバー接続情報
# [keystone_authtoken]
# www_authenticate_uri = https://dlp.srv.world:5000
# auth_url = https://dlp.srv.world:5000
# memcached_servers = dlp.srv.world:11211
# auth_type = password
# project_domain_name = default
# user_domain_name = default
# project_name = service
# username = nova
# password = servicepassword
# # Apache2 Keystone で自己署名の証明書を使用の場合は [true]
# insecure = true

# [placement]
# auth_url = https://dlp.srv.world:5000
# os_region_name = RegionOne
# auth_type = password
# project_domain_name = default
# user_domain_name = default
# project_name = service
# username = placement
# password = servicepassword
# # Apache2 Keystone で自己署名の証明書を使用の場合は [true]
# insecure = true

# [wsgi]
# api_paste_config = /etc/nova/api-paste.ini

# [oslo_policy]
# enforce_new_defaults = true
# EOF

# chmod 640 /etc/nova/nova.conf
# chgrp nova /etc/nova/nova.conf
# mv /etc/placement/placement.conf /etc/placement/placement.conf.org

# cat <<EOF > /etc/placement/placement.conf
# [DEFAULT]
# debug = false

# [api]
# auth_strategy = keystone

# [keystone_authtoken]
# www_authenticate_uri = https://dlp.srv.world:5000
# auth_url = https://dlp.srv.world:5000
# memcached_servers = dlp.srv.world:11211
# auth_type = password
# project_domain_name = default
# user_domain_name = default
# project_name = service
# username = placement
# password = servicepassword
# # Apache2 Keystone で自己署名の証明書を使用の場合は [true]
# insecure = true

# [placement_database]
# connection = mysql+pymysql://placement:password@dlp.srv.world/placement
# EOF

# vi /etc/apache2/sites-enabled/placement-api.conf
# # 1行目 : 変更
# Listen 127.0.0.1:8778
# chmod 640 /etc/placement/placement.conf
# chgrp placement /etc/placement/placement.conf

su -s /bin/bash placement -c "placement-manage db sync"
su -s /bin/bash nova -c "nova-manage api_db sync"
su -s /bin/bash nova -c "nova-manage cell_v2 map_cell0"
su -s /bin/bash nova -c "nova-manage db sync"
su -s /bin/bash nova -c "nova-manage cell_v2 create_cell --name cell1"
systemctl restart nova-api nova-conductor nova-scheduler nova-novncproxy
systemctl enable nova-api nova-conductor nova-scheduler nova-novncproxy
systemctl restart apache2 nginx
# 状態確認
openstack --insecure compute service list