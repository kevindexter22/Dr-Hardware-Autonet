<h6 align="right">Leia esta página em <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/03-oss-management/observability/zabbix-stack/zabbix-server/zabbix_server_oci_ssl_certificate.md" target="_blank" rel="noopener noreferrer">🇧🇷 Português</a></h6>

# 🛡️ SOP: SSL Provisioning (Certbot) on OCI for Zabbix Server

### 📝 Description and Scope

The idea is to create one certificate for each service on this server. This avoids using a single multi-domain certificate (called SAN - Subject Alternative Name). Because of this, we will run Certbot separately for each service.

The Apache tool will read the files we just created, check the domains using HTTP-01, and change the settings to turn on port 443.

##

### 🌐 Phase 1: Installing Certbot and the Plugin (if you don't have it yet)

1. To install, use this command:

```bash
sudo apt update && sudo apt install certbot python3-certbot-apache -y
```

2. To get a certificate only for the Zabbix Server, run this command:

***Important:*** *The domain here must be exactly the same one used in the ServerName part of your Apache settings.*

```bash
sudo certbot --apache -d zabbix.seu-dominio.com
```

* *While it runs, Certbot will ask if you want to redirect HTTP traffic to HTTPS (Redirect). Choose Yes (Option 2).*
  *This will automatically add Layer 7 security.*

##

### ⚙️ Phase 2: Automation and Life Cycle Management (MTTR)

With Certbot installed from the OS package, we do not need to set up the cron manually (like we did with FreeIPA). The system already adds a systemd timer. This timer runs automatically every 12 hours to check if the certificates have less than 30 days before they expire.

To test if this automation works, you can run the renewal simulator:

```bash
sudo certbot renew --dry-run
```

After this setup, the traffic will arrive at the public IP on OCI. Apache will check the correct TLS key for the requested subdomain. Then, it will show the web interface in a clean, isolated, and highly compatible way.

##

###### ℹ️ Part of the Dr. Hardware Autonet project - Licensed under the MIT license.
