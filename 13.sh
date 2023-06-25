#!/bin/bash

# 任意のプロジェクト追加
openstack --insecure project create --domain default --description "Hiroshima Project" hiroshima

# 任意のユーザー追加
openstack --insecure user create --domain default --project hiroshima --password userpassword serverworld

openstack --insecure role list

# ユーザーを [member] ロールに加える
openstack --insecure role add --project hiroshima --user serverworld member