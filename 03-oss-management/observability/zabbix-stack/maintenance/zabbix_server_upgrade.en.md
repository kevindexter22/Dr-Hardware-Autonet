<h6 align="right">Leia esta página em <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/03-oss-management/observability/zabbix-stack/maintenance/zabbix_server_upgrade.md" target="_blank" rel="noopener noreferrer">🇧🇷 Português</a></h6>

# 🔄 SOP: Zabbix Server Update

### 📝 Description

This document is the Standard Operating Procedure (SOP) to update packages and versions of the corporate **Zabbix Server** in the cloud (ARM64 environment). 

The goal of this procedure is to apply security fixes and performance improvements in the stable version (like 7.0.x LTS). It makes sure we do not break the relational database or overwrite custom configuration files.

##

### 🛡️ Step 1: Security Backup (Pre-Upgrade)

Before you change any packages, you must make a backup of the service and historical data:

```bash
# 1. Backup of the Zabbix configuration folder
sudo cp -a /etc/zabbix /etc/zabbix_backup_$(date +%F)

# 2. Backup of the relational database (MySQL/MariaDB)
# Change 'root' to the correct user, if necessary
mysqldump -u root -p zabbix > ~/zabbix_db_backup_$(date +%F).sql
```

##

### 🛑 Step 2: Stop the Service

To avoid saving bad data while changing files, stop the main process:

```bash
sudo systemctl stop zabbix-server
```

##

### 🚀 Step 3: Selective Package Update

To be safe, update only the Zabbix components. Do not update the whole operating system right now:

```bash
# Update the repository lists
sudo apt update

# Force the upgrade only for Zabbix packages
sudo apt install --only-upgrade zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-agent
``` 

**⚠️ Configuration Warning (APT Prompt):**

If the package manager asks if you want to replace the /etc/zabbix/zabbix_server.conf file with a new version, choose N (Keep the currently installed version).

##

### 🔄 Step 4: Start and Check

After the download and installation are complete, start the service again and check the logs:

```bash
# Start the Zabbix Server core process
sudo systemctl start zabbix-server

# Check the service status in systemd
sudo systemctl status zabbix-server

# Look at the last 50 lines of the log for database or connection errors
sudo tail -n 50 /var/log/zabbix/zabbix_server.log
```

***Analysis Note:*** *After updates, the web panel might take a moment to sync. If necessary, clear your browser cache (Ctrl + F5) and restart the web server with sudo systemctl restart apache2.*

##

###### ℹ️ Part of the Dr. Hardware Autonet project - Licensed under the MIT license.
