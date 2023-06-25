#!/bin/bash
openstack --insecure flavor create --id 1 --vcpus 1 --ram 2048 --disk 32 m1.small
openstack --insecure flavor create --id 2 --vcpus 2 --ram 4096 --disk 64 --ephemeral 10 m1.large
openstack --insecure flavor list