# 🔌 SOP: Grafana & Zabbix Integration (Data Source)

### 📝 Description

This document is the Standard Operating Procedure (SOP) to connect **Grafana** (visualization and dashboards layer) to the **Zabbix Server** (telemetry and data collection layer).

The integration uses the official plugin and the Zabbix JSON-RPC API. Both services run on the same server, so they communicate internally using `localhost`. This stops external traffic, makes queries faster, and increases the security of the architecture.

##

### 🛠️ Step 1: Plugin Installation (CLI)

Access the server terminal via SSH and install the connector directly from the Grafana repository:

***Note:*** *If you already installed it using the update document in this repository, the installation is done. In this case, you can skip to the next step.*

```bash
# Install the official Zabbix plugin (by Alexander Zobnin)
sudo grafana-cli plugins install alexanderzobnin-zabbix-app

# Restart the service to apply the installation
sudo systemctl restart grafana-server
```

##

### 🌐 Step 2: Activation on the Web Panel

After the installation on the operating system level, you must activate the module in the Grafana interface:

1. Open the Grafana web panel and log in as admin.

2. In the left side menu, go to Administration > Plugins and data > Plugins.

3. In the search bar, type `Zabbix` and click on the correct card.

4. Click the blue Enable button to activate the plugin in the system.

##

### 🔗 Step 3: Data Source Configuration

With the plugin active, connect the two platforms:

1. In the Grafana side menu, go to Connections > Data sources.

2. Click the Add data source button and choose Zabbix.

3. In the HTTP settings, fill the URL field with the local API path:
   * `http://localhost/zabbix/api_jsonrpc.php`

***Architecture Note:*** *Using HTTP via localhost bypasses the reverse proxy (Apache/SSL). This avoids unnecessary encryption processing for internal traffic on the machine.*

4. Scroll down the page to find the Zabbix API details section.

5. Fill in the login credentials:
   * Username: User with read permission in Zabbix (example: Admin).
  * Password: Access password or Token.

***Security Best Practice:*** *For production environments (Zabbix 7.0+), it is recommended to go to Zabbix under Users > API tokens and generate an authentication token with no expiration date just for Grafana. Use this token instead of the traditional password.*

6. Scroll to the bottom of the page and click Save & Test.

##

### ✅ Success Criterion:

A green notification box will show that the connection is successful and display the detected API version (example: `Zabbix API version: 7.0.x`). Now, the data is ready to use for building Dashboards.

##

###### ℹ️ Part of the Dr. Hardware Autonet project - Licensed under the MIT license.
