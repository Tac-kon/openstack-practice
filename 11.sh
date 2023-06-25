#!/bin/bash
# apt update
# apt -y install neutron-server neutron-plugin-ml2 neutron-ovn-metadata-agent python3-neutronclient ovn-central ovn-host openvswitch-switch

# mv /etc/neutron/neutron.conf /etc/neutron/neutron.conf.org

# cat << EOF > /etc/neutron/neutron.conf
# [DEFAULT]
# bind_host = 127.0.0.1
# bind_port = 9696
# core_plugin = ml2
# service_plugins = ovn-router
# auth_strategy = keystone
# state_path = /var/lib/neutron
# allow_overlapping_ips = True
# notify_nova_on_port_status_changes = True
# notify_nova_on_port_data_changes = True
# transport_url = rabbit://openstack:password@dlp.srv.world

# [keystone_authtoken]
# www_authenticate_uri = https://dlp.srv.world:5000
# auth_url = https://dlp.srv.world:5000
# memcached_servers = dlp.srv.world:11211
# auth_type = password
# project_domain_name = default
# user_domain_name = default
# project_name = service
# username = neutron
# password = servicepassword
# insecure = true

# [database]
# connection = mysql+pymysql://neutron:password@dlp.srv.world/neutron_ml2

# [nova]
# auth_url = https://dlp.srv.world:5000
# auth_type = password
# project_domain_name = default
# user_domain_name = default
# region_name = RegionOne
# project_name = service
# username = nova
# password = servicepassword
# insecure = true

# [oslo_concurrency]
# lock_path = $state_path/tmp

# [oslo_policy]
# enforce_new_defaults = true
# EOF

# chmod 640 /etc/neutron/neutron.conf

# chgrp neutron /etc/neutron/neutron.conf
# mv /etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugins/ml2/ml2_conf.ini.org
# cat << EOF > /etc/neutron/plugins/ml2/ml2_conf.ini
# [DEFAULT]
# debug = false

# [ml2]
# type_drivers = flat,geneve
# tenant_network_types = geneve
# mechanism_drivers = ovn
# extension_drivers = port_security
# overlay_ip_version = 4

# [ml2_type_geneve]
# vni_ranges = 1:65536
# max_header_size = 38

# [ml2_type_flat]
# flat_networks = *

# [securitygroup]
# enable_security_group = True
# firewall_driver = neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver

# [ovn]
# ovn_nb_connection = tcp:192.168.1.101:6641
# ovn_sb_connection = tcp:192.168.1.101:6642
# ovn_l3_scheduler = leastloaded
# ovn_metadata_enabled = True
# EOF

# chmod 640 /etc/neutron/plugins/ml2/ml2_conf.ini
# chgrp neutron /etc/neutron/plugins/ml2/ml2_conf.ini

systemctl restart openvswitch-switch
ovs-vsctl add-br br-int
ln -s /etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugin.ini
su -s /bin/bash neutron -c "neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugin.ini upgrade head"
systemctl restart ovn-central ovn-northd ovn-controller ovn-host
ovn-nbctl set-connection ptcp:6641:192.168.1.101 -- set connection . inactivity_probe=60000
ovn-sbctl set-connection ptcp:6642:192.168.1.101 -- set connection . inactivity_probe=60000
ovs-vsctl set open . external-ids:ovn-remote=tcp:192.168.1.101:6642
ovs-vsctl set open . external-ids:ovn-encap-type=geneve
ovs-vsctl set open . external-ids:ovn-encap-ip=192.168.1.101
systemctl restart neutron-server neutron-ovn-metadata-agent nova-api nova-compute nginx
# 動作確認
openstack network agent list --insecure