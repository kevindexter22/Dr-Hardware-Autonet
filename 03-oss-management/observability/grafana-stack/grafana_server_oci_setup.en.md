<h6 align="right">Leia esta página em <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/03-oss-management/observability/grafana-stack/grafana_server_oci_setup.md" target="_blank" rel="noopener noreferrer">🇧🇷 Português</a></h6>

# 📊 SOP: Installing Grafana Server (Oracle Cloud - OCI)

### 📝 Description and Scope

This Standard Operating Procedure (SOP) explains how to install Grafana Server (using Apache as frontend). We will install it on an Ubuntu 24.04 server hosted on Oracle Cloud Infrastructure (OCI).

This server is the core of our monitoring system. It will host the dashboards we create using data collected by Zabbix.

##

### 🛠️ Phase 1: Deploying the Application (Grafana OSS)

We will install Grafana on its default port (TCP/3000). This prevents conflicts with the Zabbix frontend, which runs on PHP-FPM/Apache.

1. Import the Security Key and Repository:

This ensures the software packages are safe and complete.

```bash
sudo apt install -y apt-transport-https software-properties-common wget
sudo wget -q -O /usr/share/keyrings/grafana.key https://apt.grafana.com/gpg.key
echo "deb [signed-by=/usr/share/keyrings/grafana.key] https://apt.grafana.com stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
```

2. Install and Set Up the Service:

```bash
sudo apt update
sudo apt install grafana -y
```

2. Enable the Service (systemd):

Set the service to start automatically if the OCI server reboots. This helps recover the system faster.

```bash
sudo systemctl daemon-reload
sudo systemctl enable grafana-server
sudo systemctl start grafana-server
```

##

### 🔀 Phase 2: Routing Logic Setup (Reverse Proxy)

We will configure Apache to work as an Application Gateway for the Grafana domain.

1. Enable Integration Modules:

Make sure the Apache proxy tool is enabled to forward HTTP traffic.

***Note:*** *If you already installed Zabbix Server on this same machine using our guide, these modules are already enabled. You can skip to the next step.*

```bash
sudo a2enmod proxy
sudo a2enmod proxy_http
sudo a2enmod ssl
sudo a2enmod rewrite
sudo systemctl restart apache2
```

2. Create the Virtual Host (SNI):

Create a specific routing config file for Grafana.

```bash
sudo nano /etc/apache2/sites-available/grafana.conf
```

3. Insert the code block below (replace grafana.your-domain.com with your real subdomain):

```bash
<VirtualHost *:80>
    ServerName grafana.your-domain.com

    # Keeps the original HTTP request header
    ProxyPreserveHost On

    # Forwards Layer 7 traffic to the local Grafana port
    ProxyPass / http://localhost:3000/
    ProxyPassReverse / http://localhost:3000/

    # Failure Management: Isolates Logs
    ErrorLog ${APACHE_LOG_DIR}/grafana_error.log
    CustomLog ${APACHE_LOG_DIR}/grafana_access.log combined
</VirtualHost>
```

* ***Tip:*** *If you do not have your own domain, replace the domain in ServerName with a DDNS from [Duck DNS](https://www.duckdns.org/).*

4. Apply the Routing (Graceful Reload):

Turn on the new site and reload Apache without disconnecting active Zabbix users.

```bash
sudo a2ensite grafana.conf
sudo systemctl reload apache2
```

##

### 🔒 Phase 3: Cryptographic Setup (TLS/SSL)

Now that the HTTP routing works, we will add security to encrypt the admin interface traffic.

1. Issue an Isolated Certificate:

Use Certbot (already installed on your server) to run the HTTP-01 challenge. This generates a certificate only for your Grafana subdomain.

```bash
sudo certbot --apache -d grafana.your-domain.com
```

* ***Note:*** *When Certbot asks if you want to redirect traffic (Redirect HTTP to HTTPS), choose Yes.* <br>
  *This forces end-to-end encryption.*

##

### 🧩 Phase 4: System Integration (Zabbix-Grafana API)

To let Grafana read data from your local Zabbix Server, you must install the official data plugin.

1. Installing the Alexander Zobnin Plugin:

```bash
sudo grafana-cli plugins install alexanderzobnin-zabbix-app
sudo systemctl restart grafana-server
```

##

### ✅ Post-Deployment Check:

* Go to https://grafana.your-domain.com and do the first login.
  * Default Grafana Credentials (First Access): Username: admin | Password: admin
  * Configure the Data Source pointing to your local Zabbix API (http://localhost/zabbix/api_jsonrpc.php or your internal URL).

##

###### ℹ️ Part of the Dr. Hardware Autonet project - Licensed under the MIT license.
