#!/bin/bash
mysql << EOS
create database keystone;
grant all privileges on keystone.* to keystone@'localhost' identified by 'password'; 
grant all privileges on keystone.* to keystone@'%' identified by 'password'; 
flush privileges; 
EOS

apt -y install keystone python3-openstackclient apache2 libapache2-mod-wsgi-py3 python3-oauth2client
su -s /bin/bash keystone -c "keystone-manage db_sync"

keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone
keystone-manage credential_setup --keystone-user keystone --keystone-group keystone

controller=dlp.srv.world
keystone-manage bootstrap --bootstrap-password adminpassword \
--bootstrap-admin-url https://$controller:5000/v3/ \
--bootstrap-internal-url https://$controller:5000/v3/ \
--bootstrap-public-url https://$controller:5000/v3/ \
--bootstrap-region-id RegionOne