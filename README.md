# 📊 Enterprise Monitoring System with Zabbix 6.4 on RHEL 9

[![Platform](https://img.shields.io/badge/OS-RHEL%209%20%7C%20Rocky%2010%20%7C%20Ubuntu-red)](https://www.redhat.com/)
[![Zabbix](https://img.shields.io/badge/Zabbix-6.4%20LTS-blue)](https://www.zabbix.com/)

## 📖 Project Overview
This repository documents the end-to-end deployment of a centralized monitoring solution. The project focuses on enterprise-level stability, security (SELinux/Firewalld), and cross-distribution management.

**Target Environment:**
- **Server:** RHEL 9 (running on Rocky 9 Repos)
- **Database:** MariaDB 10.x
- **Agents:** Rocky Linux 10, Ubuntu 22.04

---

## 🏗️ Architecture & Security


The setup follows the **Principle of Least Privilege**:
- **Zabbix Server (Port 10051):** Collects data from agents.
- **Zabbix Agent (Port 10050):** Listens for server queries.
- **Security:** SELinux is kept in `Enforcing` mode with specific boolean policies applied.

---

## 🚀 Deployment Highlights

### 1. Handling GPG Key Expiration (Production Issue)
During the installation on RHEL/Rocky, I encountered a GPG signature verification failure (Expired July 2024). 
**Solution:**
```bash
sudo rpm --import [https://repo.zabbix.com/RPM-GPG-KEY-ZABBIX-08EFA7DD](https://repo.zabbix.com/RPM-GPG-KEY-ZABBIX-08EFA7DD)
sudo dnf clean all

2. SELinux Policy Hardening
enabled specific permissions for the Zabbix stack

setsebool -P httpd_can_connect_zabbix on
setsebool -P zabbix_can_network on

Case Study: Real-World Troubleshooting
Scenario: The ZBX availability icon was Red for the Rocky 10 node.

