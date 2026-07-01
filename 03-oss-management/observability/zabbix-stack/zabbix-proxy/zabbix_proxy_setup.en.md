<h6 align="right">Read this page in <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/03-oss-management/obervability/zabbix-stack/zabbix_proxy_setup.md" target="_blank" rel="noopener noreferrer">🇧🇷 Portuguese</a></h6>

# 🛠️ SOP: Installing Zabbix Proxy - Raspberry Pi (ARM64)

### 📝 Description and Scope

This document defines the Standard Operating Procedure (SOP) to install Zabbix Proxy on ARM architecture (Raspberry Pi) with Ubuntu Server. 

The goal is to have a server on the internal network that works as a communication bridge between the Zabbix Server (running on an Oracle Cloud VM) and the hosts and devices on my internal network.

##

### 💾 Phase 1: Install and configure Zabbix Proxy

1. Access the terminal via SSH with root privileges:
   ```bash
   sudo su -
   ```
2. Install the Zabbix repository:
    ```bash
    wget [https://repo.zabbix.com/zabbix/7.0/ubuntu-arm64/pool/main/z/zabbix-release/zabbix-release_latest_7.0+ubuntu24.04_all.deb](https://repo.zabbix.com/zabbix/7.0/ubuntu-arm64/pool/main/z/zabbix-release/zabbix-release_latest_7.0+ubuntu24.04_all.deb)
    dpkg -i zabbix-release_latest_7.0+ubuntu24.04_all.deb
    apt update
    ```
3. Install Zabbix Proxy:
    ```bash
    apt install zabbix-proxy-sqlite3 -y
    ```
4. Configure the database for Zabbix Proxy:
    Edit the file /etc/zabbix/zabbix_proxy.conf and add the DBName parameter to show the directory and name for the database.
    ```bash
    # Example:
    DBName=/var/lib/zabbix/zbxproxy.db
    ```
5. Start the service:
    ```bash
    systemctl restart zabbix-proxy
    systemctl enable zabbix-proxy
    ```
    
##

#### ℹ️ Part of the Dr. Hardware Autonet project - Licensed under the MIT License.
