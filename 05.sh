#!/bin/bash


openstack --insecure user create --domain default --project service --password servicepassword glance

# [glance] ユーザーを [admin] ロール に追加
openstack --insecure role add --project service --user glance admin
# [glance] 用サービスエントリー作成
openstack --insecure service create --name glance --description "OpenStack Image service" image

# Glance API ホストを定義
export controller=dlp.srv.world
# [glance] 用エンドポイント作成 (public)
openstack --insecure endpoint create --region RegionOne image public https://$controller:9292

# [glance] 用エンドポイント作成 (internal)
openstack --insecure endpoint create --region RegionOne image internal https://$controller:9292

# [glance] 用エンドポイント作成 (admin)
openstack --insecure endpoint create --region RegionOne image admin https://$controller:9292

mysql << EOS
create database glance; 
grant all privileges on glance.* to glance@'localhost' identified by 'password'; 
grant all privileges on glance.* to glance@'%' identified by 'password'; 
flush privileges; 
EOS

apt -y install glance
mv /etc/glance/glance-api.conf /etc/glance/glance-api.conf.org

cat << EOF > /etc/glance/glance-api.conf
[DEFAULT]
bind_host = 127.0.0.1
transport_url = rabbit://openstack:password@dlp.srv.world

[glance_store]
stores = file,http
default_store = file
filesystem_store_datadir = /var/lib/glance/images/

[database]
connection = mysql+pymysql://glance:password@dlp.srv.world/glance

[keystone_authtoken]
www_authenticate_uri = https://dlp.srv.world:5000
auth_url = https://dlp.srv.world:5000
memcached_servers = dlp.srv.world:11211
auth_type = password
project_domain_name = default
user_domain_name = default
project_name = service
username = glance
password = servicepassword
insecure = true

[paste_deploy]
flavor = keystone

[oslo_policy]
enforce_new_defaults = true
EOF

chmod 640 /etc/glance/glance-api.conf
chown root:glance /etc/glance/glance-api.conf
su -s /bin/bash glance -c "glance-manage db_sync"
systemctl restart glance-api
systemctl enable glance-api

cat << EOF >> /etc/nginx/nginx.conf
stream {
    upstream glance-api {
        server 127.0.0.1:9292;
    }
    server {
        listen 192.168.1.101:9292 ssl;
        proxy_pass glance-api;
    }
    ssl_certificate "/etc/letsencrypt/live/dlp.srv.world/fullchain.pem";
    ssl_certificate_key "/etc/letsencrypt/live/dlp.srv.world/privkey.pem";
}
EOF

systemctl restart nginx