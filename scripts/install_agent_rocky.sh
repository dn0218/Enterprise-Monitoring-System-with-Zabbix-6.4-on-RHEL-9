#!/bin/bash

# ========================
# Zabbix Agent2 Installation
# ========================

# ===== sudo Check =====
if [ "$EUID" -ne 0 ]; then
    SUDO="sudo"
else
    SUDO=""
fi

# ===== Gain server IP=====
LOCAL_IP=$(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v '^127' | head -n1)

echo "======================================="
echo "📡 Checking your server IP: ${LOCAL_IP}"
echo "======================================="

# ===== Enter Zabbix Server IP =====
echo "== Please Enter Zabbix Server IP =="
read ZABBIX_SERVER_IP

if [ -z "$ZABBIX_SERVER_IP" ]; then
    echo "❌ Server IP Cannot Be Blank"
    exit 1
fi

# ===== Prompt Hostname =====
echo
echo "⚠️ Important Note："
echo "Hostname must be Align with Zabbix Server Web created hostname！"
echo

echo "== Enter Hostname =="
read HOSTNAME_INPUT

if [ -z "$HOSTNAME_INPUT" ]; then
    echo "❌ Hostname Cannot Be Blank"
    exit 1
fi

echo
echo "📌 Confirm Info："
echo "Zabbix Server IP : $ZABBIX_SERVER_IP"
echo "Agent Hostname   : $HOSTNAME_INPUT"
echo "Local IP         : $LOCAL_IP"
echo

read -p "Proceed？(yes/no): " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
    echo "Cancel Installation"
    exit 0
fi

echo "== 1. Install Repo =="
$SUDO rpm -Uvh https://repo.zabbix.com/zabbix/6.4/rhel/9/x86_64/zabbix-release-6.4-1.el9.noarch.rpm

echo "== 2. Import GPG Key=="
$SUDO rpm --import https://repo.zabbix.com/RPM-GPG-KEY-ZABBIX-08EFA7DD

$SUDO dnf clean all

echo "== 3. Install Agent2 =="
$SUDO dnf install -y zabbix-agent2

echo "== 4. Configure Agent =="

# Configuration of config file
$SUDO sed -i "s/^Server=.*/Server=${ZABBIX_SERVER_IP}/" /etc/zabbix/zabbix_agent2.conf
$SUDO sed -i "s/^ServerActive=.*/ServerActive=${ZABBIX_SERVER_IP}/" /etc/zabbix/zabbix_agent2.conf
$SUDO sed -i "s/^Hostname=.*/Hostname=${HOSTNAME_INPUT}/" /etc/zabbix/zabbix_agent2.conf

echo "== 5. Enable Zabbix Agent Service =="
$SUDO systemctl enable --now zabbix-agent2

echo "== 6. Allow ports =="
$SUDO firewall-cmd --add-port=10050/tcp --permanent
$SUDO firewall-cmd --reload

echo
echo "======================================="
echo "🎉 Zabbix Agent 2 Installation Completed！"
echo "======================================="
echo "📌 Server IP : ${ZABBIX_SERVER_IP}"
echo "📌 Hostname  : ${HOSTNAME_INPUT}"
echo "📌 Local IP  : ${LOCAL_IP}"
echo
echo "⚠️ Please create a new host with EXACTLY SAME hostname in Zabbix Web for monitoring！"
echo "======================================="

