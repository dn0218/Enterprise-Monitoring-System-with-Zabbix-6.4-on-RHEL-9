#!/bin/bash

# ========================
# Zabbix Server Installation
# ========================

DB_NAME="zabbix"
DB_USER="zabbix"

# ===== sudo check =====
if [ "$EUID" -ne 0 ]; then
    SUDO="sudo"
else
    SUDO=""
fi

echo "== Enter new password=="
read -s DB_PASS
echo
echo "== Confirm the password =="
read -s DB_PASS_CONFIRM
echo

if [ "$DB_PASS" != "$DB_PASS_CONFIRM" ]; then
    echo "❌ Password not match! Exit"
    exit 1
fi

echo "== 1. Install Zabbix Repo =="
$SUDO rpm -Uvh https://repo.zabbix.com/zabbix/6.4/rhel/9/x86_64/zabbix-release-6.4-1.el9.noarch.rpm
$SUDO dnf clean all

echo "== 2. Install modules =="
$SUDO dnf install -y \
zabbix-server-mysql \
zabbix-web-mysql \
zabbix-apache-conf \
zabbix-sql-scripts \
zabbix-selinux-policy \
zabbix-agent \
mariadb-server

echo "== 3. Starting the database=="
$SUDO systemctl enable --now mariadb

echo "== 4. Configuring Database =="
$SUDO mysql <<EOF
CREATE DATABASE IF NOT EXISTS ${DB_NAME} CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';
SET GLOBAL log_bin_trust_function_creators = 1;
FLUSH PRIVILEGES;
EOF

echo "== 5. Import Zabbix data=="
zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | \
$SUDO mysql --default-character-set=utf8mb4 -u${DB_USER} -p${DB_PASS} ${DB_NAME}

echo "== 6. Configuring Zabbix Server =="
$SUDO sed -i "s/# DBPassword=/DBPassword=${DB_PASS}/" /etc/zabbix/zabbix_server.conf

echo "== 7. Enable Zabbix Service =="
$SUDO systemctl restart zabbix-server zabbix-agent httpd php-fpm
$SUDO systemctl enable zabbix-server zabbix-agent httpd php-fpm

echo "== 8. Allow firewall on Zabbix Ports =="
$SUDO firewall-cmd --add-service={http,https} --permanent
$SUDO firewall-cmd --add-port=10051/tcp --permanent
$SUDO firewall-cmd --reload

# ===== Final=====
echo
echo "======================================="
echo "🎉 Zabbix Server Installed！"
echo "======================================="
echo "📌 Visit link: http://<YourServer IP>/zabbix"
echo
echo "📌 Please noted your Database info："
echo "DB_NAME : ${DB_NAME}"
echo "DB_USER : ${DB_USER}"
echo "DB_PASS : (Your new password)"
echo
echo "⚠️

