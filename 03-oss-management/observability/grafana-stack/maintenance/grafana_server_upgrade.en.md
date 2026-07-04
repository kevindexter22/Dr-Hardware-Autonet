<h6 align="right">Leia esta página em <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/03-oss-management/observability/grafana-stack/maintenance/grafana_server_upgrade.md" target="_blank" rel="noopener noreferrer">🇧🇷 Português</a></h6>

# 🔄 SOP: Grafana Server and Modules Update

### 📝 Description

This document is the Standard Operating Procedure (SOP) to update the **Grafana Server** and manage its integration plugins (Data Sources).

In the new stable versions, the old command-line tool `grafana-cli` is deprecated (not used anymore). This guide shows the new way to use the tool (`grafana cli`). It also shows the steps to keep the reverse proxy and SSL settings safe in the global configuration file.

##

### 🛡️ Step 1: Data Backup (Pre-Upgrade)

Make a copy of the configuration files and the internal SQLite3 database before you continue:

```bash
# 1. Backup of the network and security configuration file
sudo cp -a /etc/grafana/grafana.ini /etc/grafana/grafana.ini.backup_$(date +%F)

# 2. Backup of the internal database for Dashboards and Users
sudo cp -a /var/lib/grafana/grafana.db /var/lib/grafana/grafana.db.backup_$(date +%F)
```

##

### 🛑 Step 2: Stop the Process

Stop the Grafana web server:

```bash
sudo systemctl stop grafana-server
```
##

### 🚀 Step 3: Core Update and Scope Rules

Update only the Grafana package using the system package manager:

```bash
# Synchronize the repositories
sudo apt update

# Update only the Grafana package
sudo apt install --only-upgrade grafana
```

***⚠️ Important Warning:*** *During the installation, the operating system might ask if you want to replace the `/etc/grafana/grafana.ini` file. You must answer `N (or Keep your currently-installed version)`. This keeps the root_url and domain settings working for the Reverse Proxy with SSL.

##

### 🔌 Step 4: Plugin Update with New CLI

If the drop-down menus or integration hosts do not show correctly after the Core update, reinstall or update the plugin. Use the new syntax (without the hyphen):

```bash
# Use the new CLI to force the installation of the updated connector
sudo grafana cli plugins install alexanderzobnin-zabbix-app
```

##

### 🔄 Step 5: Restart the Service

Start Grafana and check if the application is working correctly:

```ash
# Restart the service in the system
sudo systemctl start grafana-server

# Check if the status returned to active (running)
sudo systemctl status grafana-server
```

##

###### ℹ️ Part of the Dr. Hardware Autonet project - Licensed under the MIT license.
