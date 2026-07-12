<h6 align="right">Leia essa página em <a href="https://github.com/kevindexter22/Dr-Hardware-Autonet/blob/main/01-infrastructure/network-core/services/netbox-stack/netbox-server/netbox_ssl_certificate_domain.md" target="_blank" rel="noopener noreferrer">🇧🇷 Português</a></h6>

# 🛡️ SOP: SSL Provisioning (Let's Encrypt) on NetBox via DNS-01 (Alias Mode)

### 📝 Description and Scope

This document defines the Standard Operating Procedure (SOP) to inject valid SSL/TLS certificates into the Reverse Proxy (Nginx). This proxy protects the NetBox interface (Single Source of Truth).

Because of the Zero Trust network architecture (no Inbound ports open on the router) in the lab, direct integration via HTTP-01 is impossible. This guide uses the acme.sh tool in DNS Delegation mode (Alias Mode). It validates the custom domain (e.g., .click) without exposing the web server to the public internet. It sends the crypto challenge to a support DDNS (DuckDNS).

##

### 🌐 Phase 1: Routing and DNS Delegation

Prepare the logic layer in your public domain provider (e.g., Hostinger).

Local Access (Split-DNS): In your internal DNS server (e.g., Unbound), create the static record for the LXC IP. This stops traffic from going to the internet.

Type: A / Local-Data

Name: netbox.infra.your-domain.com

Target: 10.10.0.250

Security Delegation (ACME Challenge): In the Hostinger public panel (DNS Zone), create a redirect strictly to the root of your support DDNS. This automates the challenge.

Type: CNAME

Name: _acme-challenge.netbox

Target: your-lab.duckdns.org

##

### ⚙️ Phase 2: Tool Installation and Setup

The acme.sh tool connects the DuckDNS API and the Certificate Authority. Access the NetBox LXC terminal (as root):

1. Core Installation:

```bash
curl https://get.acme.sh | sh -s email=your-email@domain.com
source ~/.bashrc
```

2. Reliability Engineering (Vendor Bypass): By default, `acme.sh` uses ZeroSSL.

To keep the Open Source standard in the lab, we force the use of Let's Encrypt as the primary CA:

```bash
/root/.acme.sh/acme.sh --set-default-ca --server letsencrypt
```

##

### 🚀 Phase 3: Certificate Issue and Extraction

1. Export your API Token from the DDNS provider (DuckDNS):

```bash
export DuckDNS_Token="YOUR_TOKEN_HERE"
```

2. Issue Order (Crypto Delegation): We ask for the certificate for the .com domain, but we tell Let's Encrypt to look for the challenge answer in the DuckDNS domain.

```bash
/root/.acme.sh/acme.sh --issue --dns dns_duckdns -d netbox.infra.your-domain.com --challenge-alias your-lab.duckdns.org
```

3. Staging Area (Deployment and Automation): Create a safe folder and install the files.

We add the reload hook (--reloadcmd). This makes sure the certificate renews itself every 60 days with no human action.

```bash
mkdir -p /etc/ssl/netbox
/root/.acme.sh/acme.sh --install-cert -d netbox.infra.your-domain.com \
--key-file       /etc/ssl/netbox/netbox.key  \
--fullchain-file /etc/ssl/netbox/netbox.cer \
--reloadcmd      "systemctl reload nginx"
```

4. Validate the certificate renewal automation

```bash
crontab -l
``` 
*Result: `15 0 * * * "/root/.acme.sh"/acme.sh --cron --home "/root/.acme.sh" > /dev/null`.*

##

### 🔗 Phase 4: Trust Chain Integration in the Proxy (Nginx)

NetBox sends the SSL termination to the web server (Nginx).

We need to point the server directives to the new key vault.

Edit the NetBox route file:

```bash
nano /etc/nginx/sites-available/netbox
```

Adjust the server block to show the exact domain and the absolute paths:

```bash
server {
    listen [::]:443 ssl ipv6only=off;
    
    # Official access name
    server_name netbox.infra.your-domain.com;

    # Fullchain and Private Key paths
    ssl_certificate /etc/ssl/netbox/netbox.cer;
    ssl_certificate_key /etc/ssl/netbox/netbox.key;
    
    client_max_body_size 25m;
    
    # ... (keep the Gunicorn locations below)
}
```

##

### ✅ Phase 5: Certificate Injection and Handover

With the trust chain resolved in the config, run a syntax test to avoid a web service crash:

```bash
nginx -t
```

Graceful Restart: If the command returns syntax is ok, restart the reverse proxy to apply the new topology in the RAM memory:

```bash
systemctl restart nginx
```

Web access to the NetBox panel will now operate with valid and globally recognized TLS encryption (Green Padlock), without security alerts.

To access the interface, use this URL in your browser:

```bash
https://netbox.infra.your-domain.com
```

##

###### ℹ️ Part of the Dr. Hardware Autonet project - Licensed under the MIT license.
