# 🔗 SOP: Zabbix Server - Enabling Apache2 Proxy

### 📝 Description and Scope

This Standard Operating Procedure (SOP) explains how to configure Apache2 on the Zabbix Server 7.0 LTS. This is necessary to install and connect *Grafana, which will show the dashboards for our network.

##

### ⭐ Phase 1: Enabling Modules (Integration Layer)

Apache needs the proxy and HTTPS modules turned on. This helps Apache read incoming requests and send them to the right place inside the server.

In the terminal of your OCI server, run:

```bash
sudo a2enmod proxy
sudo a2enmod proxy_http
sudo a2enmod ssl
sudo a2enmod rewrite
sudo systemctl restart apache2
```

* ***Note:*** *The commands above use the Debian/Ubuntu standard. If you use Oracle Linux/RHEL, you must enable the modules in the httpd.conf file.*

##

### 🗄️ Phase 2: Virtual Hosts Logic Setup (SNI)

We will create two separate blocks. Apache will receive the request on port 80 (and later on 443). Then, it will send the traffic to the correct place using the Host header.

1. Zabbix Setup (Native Server)

Create a file for Zabbix (for example: /etc/apache2/sites-available/zabbix.conf).

Check the exact DocumentRoot of your installation (it is usually /usr/share/zabbix).

```bash
<VirtualHost *:80>
    ServerName zabbix.your-domain.com
    DocumentRoot /usr/share/zabbix

    <Directory "/usr/share/zabbix">
        Options FollowSymLinks
        AllowOverride None
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/zabbix_error.log
    CustomLog ${APACHE_LOG_DIR}/zabbix_access.log combined
</VirtualHost>
```

***Tip:*** *If you do not have your own domain, replace the domain in ServerName with a DDNS from [Duck DNS](https://www.duckdns.org/).* 

2. Turn on the new site and reload the service:  

```bash
sudo a2ensite zabbix.conf
sudo systemctl reload apache2
```

##

**☢️ Security Alert:**

* Please configure an SSL certificate for Apache.  

##

###### ℹ️ Part of the Dr. Hardware Autonet project - Licensed under the MIT license.
