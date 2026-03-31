## 🚀 Deployment Highlights

### 1. GPG Signature Verification Failed (Package Integrity)
During the installation on RHEL/Rocky, I encountered a GPG signature verification failure (Expired July 2024). 

**Symptoms:**
```bash
error: Verifying a signature using certificate ... invalid: certificate is not alive
error: Key ... invalid: key is not alive
Error: GPG check FAILED
```

**Solution Example:**
````bash 
danny@rocky:~$ sudo rpm -q gpg-pubkey --qf '%{NAME}-%{VERSION}-%{RELEASE}\t%{SUMMARY}\n' | grep -i zabbix
gpg-pubkey-08efa7dd-62c42363	Zabbix LLC (Jul 2022) <packager@zabbix.com> public key
```
⤴️ Check the version of Zabbix public key
```bash
danny@rocky:~$ sudo rpm -e gpg-pubkey-08efa7dd-62c42363
```
⤴️Erase the expired key
```bash
danny@rocky:~$ sudo rpm --import https://repo.zabbix.com/RPM-GPG-KEY-ZABBIX-08EFA7DD
```
⤴️ Get the latest .key
```bash
danny@rocky:~$ gpg --show-keys /etc/pki/rpm-gpg/RPM-GPG-KEY-ZABBIX-08EFA7DD
pub   rsa4096 2022-07-05 [SC] [expires: 2034-06-30]
      D9AA84C2B617479C6E4FCF4D19F2475308EFA7DD
uid                      Zabbix LLC (Jul 2022) <packager@zabbix.com>
sub   rsa4096 2022-07-05 [E] [expires: 2034-06-30]
```
⤴️check the key expiry
```bash
danny@rocky:~$ sudo dnf clean all
sudo rm -rf /var/cache/dnf/*
25 files removed
```
⤴️clean cache
```bash
danny@rocky:sudo dnf install zabbix-agent2 -y
```
⤴️Reinstall&Validate
```bash
Rocky Linux 10 - BaseOS                            1.0 MB/s |  14 MB     00:14    
Rocky Linux 10 - AppStream                         632 kB/s | 2.3 MB     00:03    
Rocky Linux 10 - Extras                            1.3 kB/s | 6.0 kB     00:04    
Zabbix Official Repository - x86_64                7.1 kB/s |  58 kB     00:08    
Zabbix Official Repository non-supported - x86_64  129  B/s | 782  B     00:06    
Dependencies resolved.
===================================================================================
 Package              Architecture  Version                    Repository     Size
===================================================================================
Installing:
 zabbix-agent2        x86_64        6.4.21-release1.el9        zabbix        6.0 M

Transaction Summary
===================================================================================
Install  1 Package

Total download size: 6.0 M
Installed size: 20 M
Downloading Packages:
zabbix-agent2-6.4.21-release1.el9.x86_64.rpm       425 kB/s | 6.0 MB     00:14    
-----------------------------------------------------------------------------------
Total                                              424 kB/s | 6.0 MB     00:14     
Running transaction check
Transaction check succeeded.
Running transaction test
Transaction test succeeded.
Running transaction
  Preparing        :                                                           1/1 
  Running scriptlet: zabbix-agent2-6.4.21-release1.el9.x86_64                  1/1 
  Installing       : zabbix-agent2-6.4.21-release1.el9.x86_64                  1/1 
  Running scriptlet: zabbix-agent2-6.4.21-release1.el9.x86_64                  1/1 

Installed:
  zabbix-agent2-6.4.21-release1.el9.x86_64                                         

Complete!
```

