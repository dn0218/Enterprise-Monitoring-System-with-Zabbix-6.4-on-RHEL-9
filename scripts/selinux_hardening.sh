#!/bin/bash

echo "== SELinux  =="

setsebool -P httpd_can_connect_zabbix on
setsebool -P httpd_can_network_connect_db on

echo "== 验证上下文 =="
ls -dZ /etc/zabbix/

echo "== Current SELinux State =="
getenforce

echo "✅ SELinux enhanced（Keep Enforcing）"

