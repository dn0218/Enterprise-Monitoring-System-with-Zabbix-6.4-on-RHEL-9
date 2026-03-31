## Architecture

Zabbix Server (RHEL 9)
│
├── MariaDB (Database)
├── Apache + PHP (Web UI)
│
└── Zabbix Agent 2 (Rocky Linux 10)

🚀 Deployment Steps
1️⃣ Install Zabbix Repository

[danny@rhel /]$ sudo rpm -Uvh https://repo.zabbix.com/zabbix/6.4/rhel/9/x86_64/zabbix-release-6.4-1.el9.noarch.rpm
Retrieving https://repo.zabbix.com/zabbix/6.4/rhel/9/x86_64/zabbix-release-6.4-1.el9.noarch.rpm
warning: /var/tmp/rpm-tmp.Jvci5y: Header V4 RSA/SHA512 Signature, key ID 08efa7dd: NOKEY
Verifying...                          ################################# [100%]
Preparing...                          ################################# [100%]
Updating / installing...
   1:zabbix-release-6.4-1.el9         ################################# [100%]

[danny@rhel /]$ sudo dnf clean all
Updating Subscription Management repositories.
Unable to read consumer identity

This system is not registered with an entitlement server. You can use "rhc" or "subscription-manager" to register.

22 files removed

2️⃣ Install Zabbix Server Components
We will use MariaDB as Database，Apache as Web server.

[danny@rhel /]$ sudo dnf install zabbix-server-mysql zabbix-web-mysql zabbix-apache-conf zabbix-sql-scripts zabbix-selinux-policy zabbix-agent -y
Updating Subscription Management repositories.
Unable to read consumer identity
This system is not registered with an entitlement server. You can use "rhc" or "subscription-manager" to register.

Rocky Linux 9 - BaseOS                          1.8 MB/s |  17 MB     00:09    
Rocky Linux 9 - AppStream                       2.0 MB/s |  17 MB     00:08    
Rocky Linux 9 - Extras                           19 kB/s |  17 kB     00:00    
Zabbix Official Repository - x86_64             110 kB/s | 340 kB     00:03    
Zabbix Official Repository non-supported - x86_ 519  B/s | 1.1 kB     00:02    
Dependencies resolved.
# All kind of installation and downloads......

3️⃣ Install and Configure MariaDB
[danny@rhel /]$ sudo dnf install mariadb-server -y
Updating Subscription Management repositories.
Unable to read consumer identity

This system is not registered with an entitlement server. You can use "rhc" or "subscription-manager" to register.

Last metadata expiration check: 0:02:42 ago on Tue 31 Mar 2026 10:45:30 AM +08.
Dependencies resolved.
# All kind of installation and downloads......

[danny@rhel /]$ sudo systemctl enable --now mariadb
Created symlink /etc/systemd/system/mysql.service → /usr/lib/systemd/system/mariadb.service.
Created symlink /etc/systemd/system/mysqld.service → /usr/lib/systemd/system/mariadb.service.
Created symlink /etc/systemd/system/multi-user.target.wants/mariadb.service → /usr/lib/systemd/system/mariadb.service.

**Create Database**
[danny@rhel /]$ sudo mysql -uroot -p
Enter password: 
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 4
Server version: 10.5.29-MariaDB MariaDB Server

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> create database zabbix character set utf8mb4 collate utf8mb4_bin;
Query OK, 1 row affected (0.000 sec)

MariaDB [(none)]> create user zabbix@localhost identified by 'danny0218';
Query OK, 0 rows affected (0.001 sec)

MariaDB [(none)]> grant all privileges on zabbix.* to zabbix@localhost;
Query OK, 0 rows affected (0.001 sec)

MariaDB [(none)]> set global log_bin_trust_function_creators = 1;
Query OK, 0 rows affected (0.000 sec)

MariaDB [(none)]> quit;
Bye

4️⃣ Import Initial Schema

[danny@rhel /]$ zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql --default-character-set=utf8mb4 -uzabbix -p zabbix
Enter password: 

5️⃣ Configure Zabbix Server
[danny@rhel /]$ sudo sed -i 's/# DBPassword=/DBPassword=<Enter your password>/g' /etc/zabbix/zabbix_server.conf

6️⃣ Start Services
[danny@rhel /]$ sudo systemctl restart zabbix-server zabbix-agent httpd php-fpm
[danny@rhel /]$ sudo systemctl enable zabbix-server zabbix-agent httpd php-fpm
Created symlink /etc/systemd/system/multi-user.target.wants/zabbix-server.service → /usr/lib/systemd/system/zabbix-server.service.
Created symlink /etc/systemd/system/multi-user.target.wants/zabbix-agent.service → /usr/lib/systemd/system/zabbix-agent.service.
Created symlink /etc/systemd/system/multi-user.target.wants/httpd.service → /usr/lib/systemd/system/httpd.service.
Created symlink /etc/systemd/system/multi-user.target.wants/php-fpm.service → /usr/lib/systemd/system/php-fpm.service.

🖥️ Agent Setup (Rocky Linux 10)

**Install Agent 2**

danny@rocky:~$ sudo rpm -Uvh https://repo.zabbix.com/zabbix/6.4/rhel/9/x86_64/zabbix-release-6.4-1.el9.noarch.rpm
[sudo] password for danny: 
Retrieving https://repo.zabbix.com/zabbix/6.4/rhel/9/x86_64/zabbix-release-6.4-1.el9.noarch.rpm
warning: /var/tmp/rpm-tmp.jhS4tq: Header V4 RSA/SHA512 Signature, key ID 08efa7dd: NOKEY
Verifying...                          ################################# [100%]
Preparing...                          ################################# [100%]
Updating / installing...
   1:zabbix-release-6.4-1.el9         ################################# [100%]
danny@rocky:~$ sudo dnf install zabbix-agent2 -y
Rocky Linux 10 - BaseOS                            858  B/s | 4.3 kB     00:05    
Rocky Linux 10 - AppStream                         667  B/s | 4.3 kB     00:06    
Rocky Linux 10 - AppStream                         1.3 MB/s | 2.3 MB     00:01    
Rocky Linux 10 - Extras                            2.6 kB/s | 3.1 kB     00:01    
Rocky Linux 10 - Extras                            4.9 kB/s | 6.0 kB     00:01    
Zabbix Official Repository - x86_64                 13 kB/s |  58 kB     00:04    
Zabbix Official Repository non-supported - x86_64  354  B/s | 782  B     00:02    
Dependencies resolved.

**Configure Agent**
sudo vi /etc/zabbix/zabbix_agent2.conf

#Server=<Zabbix_Server_IP>
#ServerActive=<Zabbix_Server_IP>
#Hostname=<Your_Hostname>

**Start Agent**
sudo systemctl enable --now zabbix-agent2

🔐 Security Hardening 
**SELinux Configuration**
[danny@rhel /]$ sudo setsebool -P httpd_can_connect_zabbix on
[danny@rhel /]$ sudo setsebool -P httpd_can_network_connect_db on
[danny@rhel /]$ ls -dZ /etc/zabbix/
system_u:object_r:etc_t:s0 /etc/zabbix/

**Firewall Configuration**
[danny@rhel /]$ sudo firewall-cmd --add-service={http,https} --permanent
Warning: ALREADY_ENABLED: http
Warning: ALREADY_ENABLED: https
success
[danny@rhel /]$ sudo firewall-cmd --add-port=10051/tcp --permanent
success
[danny@rhel /]$ sudo firewall-cmd --reload
success

🌐 Web Setup





